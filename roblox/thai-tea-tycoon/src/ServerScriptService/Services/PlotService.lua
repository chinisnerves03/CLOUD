-- PlotService: claims plots, shows items by level, and runs the money loop:
--   the shop sells by itself from the start (counter sales) → brew by hand at the Brew Station to earn faster
--   → hire staff who sell for you → upgrade recipe and speed
--   → walk to the green pad (placed behind each new item's spot) to grow the shop (or own Auto Build). Everything is computed on the server; the client only reads
-- these player Attributes: Cash, Level, Income (per second from counter sales + staff), BrewValue (per cup),
-- BrewCooldown, Staff, Recipe, Speed, Plot

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local DevPlotBuilder = require(script.Parent:WaitForChild("DevPlotBuilder"))
local ItemModels = require(script.Parent:WaitForChild("ItemModels"))

local PlotService = {}

local COLOR_ACTIVE = Color3.fromRGB(46, 204, 113)
local COLOR_EMPTY = Color3.fromRGB(80, 80, 80)
local PAD_MARGIN = 0.5 -- a little slack past the pad edge
local PAD_HEIGHT = 7 -- height above the pad that still counts as "standing on it"

type PlotState = {
	Model: Model,
	Name: string,
	Floor: CFrame?, -- floor center of the plot; nil for custom plots without a Base
	Pads: { BasePart },
	PadLabels: { TextLabel },
	PadGlow: BasePart,
	UpgradePads: { [string]: BasePart },
	UpgradeLabels: { [string]: TextLabel },
	StaffModels: { Model }, -- hired barista carts (index = hire order), parked in Storage until hired
	VipModel: Model?,
	Kettle: BasePart?,
	BrewPad: BasePart?, -- where the brewer stands (behind the counter); nil = brew from anywhere near the Kettle
	SignLabel: TextLabel?,
	ItemsFolder: Folder,
	Storage: Folder,
	Owner: Player?,
}

type OwnerState = {
	Plot: PlotState,
	Data: any,
	OnPad: { boolean },
	OnUpgrade: { [string]: boolean },
	LastBrew: number,
}

local Monetization
local notifyRemote: RemoteEvent
local plots: { PlotState } = {}
local owners: { [Player]: OwnerState } = {}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
function PlotService.Notify(player: Player, kind: string, text: string)
	if player.Parent then
		notifyRemote:FireClient(player, kind, text)
	end
end

local function setAttr(player: Player, name: string, value: any)
	if player:GetAttribute(name) ~= value then
		player:SetAttribute(name, value)
	end
end

local function isStandingOn(part: BasePart, position: Vector3): boolean
	local rel = part.CFrame:PointToObjectSpace(position)
	local half = part.Size / 2
	return math.abs(rel.X) <= half.X + PAD_MARGIN
		and math.abs(rel.Z) <= half.Z + PAD_MARGIN
		and rel.Y >= -1
		and rel.Y <= half.Y + PAD_HEIGHT
end

local function makeLabel(pad: BasePart, height: number): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = "PadLabel"
	-- sized in studs (not pixels) so labels of neighboring pads never overlap from far away
	gui.Size = UDim2.fromScale(pad.Size.X + 1.5, 2.4)
	gui.StudsOffset = Vector3.new(0, height, 0)
	gui.MaxDistance = 120
	gui.AlwaysOnTop = true
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.2
	text.Text = ""
	text.Parent = gui
	gui.Parent = pad
	return text
end

-- a soft green light column over the buy pad so it is easy to spot across the plot
local function makePadGlow(pad: BasePart): BasePart
	local glow = Instance.new("Part")
	glow.Name = "PadGlow"
	glow.Shape = Enum.PartType.Cylinder
	glow.Size = Vector3.new(10, 5, 5)
	glow.Anchored = true
	glow.CanCollide = false
	glow.CanTouch = false
	glow.CanQuery = false
	glow.CastShadow = false
	glow.Material = Enum.Material.Neon
	glow.Color = COLOR_ACTIVE
	glow.Transparency = 0.85
	glow.Parent = pad.Parent
	return glow
end

local function cashMultiplier(player: Player): number
	return Monetization.IncomeMultiplier(player)
end

-- cash per cup (items raise the base value, Better Recipe multiplies it)
local function cupValue(player: Player, data): number
	return Config.GetBrewValue(data.Level) * Config.RecipeMultiplier(data.Recipe) * cashMultiplier(player)
end

local function brewCooldown(data): number
	return Config.BREW_COOLDOWN / Config.SpeedMultiplier(data.Speed)
end

-- cash per second that arrives without brewing by hand: counter sales, staff and the VIP barista
local function autoIncome(player: Player, data): number
	local speed = Config.SpeedMultiplier(data.Speed)
	local cup = cupValue(player, data)
	local perSecond = data.Staff * cup * speed / Config.STAFF_INTERVAL
	if Monetization.HasPass(player, "VipBarista") then
		perSecond += cup * speed / Config.VIP_INTERVAL
	end
	local counter = Config.GetPassive(data.Level) * Config.RecipeMultiplier(data.Recipe) * speed * cashMultiplier(player)
	return perSecond + counter
end

function PlotService.GetIncomePerSecond(player: Player): number
	local state = owners[player]
	return if state then autoIncome(player, state.Data) else 0
end

-- full-strength income per second (the pacing curve), used to size Cash Boost products
function PlotService.GetBaseIncome(player: Player): number
	local state = owners[player]
	if not state then
		return 0
	end
	return Config.GetIncome(state.Data.Level) * cashMultiplier(player)
end

---------------------------------------------------------------------------
-- Plot visuals
---------------------------------------------------------------------------
local function refreshPads(plot: PlotState)
	local state = plot.Owner and owners[plot.Owner]
	for i, pad in plot.Pads do
		local labelText = plot.PadLabels[i]
		local item = state and Config.GetItem(state.Data.Level + i)
		if not item then
			-- empty plot or everything bought: park the pad
			pad.Transparency = if state then 1 else 0
			pad.Color = COLOR_EMPTY
			labelText.Text = ""
			plot.PadGlow.Transparency = 1
			continue
		end
		-- move the pad to its spot behind where this item will appear
		local spot = plot.Floor and ItemModels.PadIn(item.Key, plot.Floor)
		if spot then
			pad.CFrame = spot * CFrame.new(0, pad.Size.Y / 2, 0)
		end
		pad.Transparency = 0
		pad.Color = COLOR_ACTIVE
		labelText.Text = item.Name .. "\n" .. Config.FormatMoney(item.Price)
		plot.PadGlow.CFrame = pad.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 0, math.rad(90))
		plot.PadGlow.Transparency = 0.85
	end

	for key, pad in plot.UpgradePads do
		local label = plot.UpgradeLabels[key]
		local u = Config.UPGRADES[key]
		if not state then
			pad.Transparency = 0.6
			label.Text = ""
			continue
		end
		local owned = state.Data[key]
		local cost = Config.UpgradeCost(key, owned)
		pad.Transparency = if cost then 0 else 0.6
		label.Text = string.format("%s (%d/%d)\n%s", u.Name, owned, u.Max, if cost then Config.FormatMoney(cost) else "MAX")
	end

	-- hired baristas stand at their carts; the rest wait in storage
	for i, model in plot.StaffModels do
		model.Parent = if state and i <= state.Data.Staff then plot.Model else plot.Storage
	end
	if plot.VipModel then
		local vip = state and Monetization.HasPass(plot.Owner :: Player, "VipBarista")
		plot.VipModel.Parent = if vip then plot.Model else plot.Storage
	end
end

local function showItem(plot: PlotState, level: number)
	local item = Config.GetItem(level)
	if not item then
		return
	end
	local model = plot.Storage:FindFirstChild(item.Key)
	if model then
		model.Parent = plot.ItemsFolder
	end
end

local function hideAllItems(plot: PlotState)
	for _, child in plot.ItemsFolder:GetChildren() do
		child.Parent = plot.Storage
	end
end

local function setSign(plot: PlotState, text: string)
	if plot.SignLabel then
		plot.SignLabel.Text = text
	end
end

---------------------------------------------------------------------------
-- Brewing / buying / upgrading
---------------------------------------------------------------------------
function PlotService.AddCash(player: Player, amount: number)
	local state = owners[player]
	if state then
		state.Data.Cash += amount
	end
end

function PlotService.Refresh(player: Player)
	local state = owners[player]
	if state then
		refreshPads(state.Plot)
	end
end

local function brew(player: Player, plot: PlotState)
	local state = owners[player]
	if not state or state.Plot ~= plot then
		PlotService.Notify(player, "Error", "This is not your shop — brew at your own Brew Station")
		return
	end
	local now = os.clock()
	if now - state.LastBrew < brewCooldown(state.Data) then
		return
	end
	-- brewing happens from behind the counter (standing on BrewPad), customers queue at the front
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if plot.BrewPad and not (root and isStandingOn(plot.BrewPad, root.Position)) then
		PlotService.Notify(player, "Error", "Go behind the counter (orange mat) to brew")
		return
	end
	state.LastBrew = now
	local value = cupValue(player, state.Data)
	state.Data.Cash += value
	PlotService.Notify(player, "Brew", "+" .. Config.FormatMoney(value))
end

local function tryBuy(player: Player, state: OwnerState)
	local data = state.Data
	local item = Config.GetItem(data.Level + 1)
	if not item then
		return
	end
	if data.Cash < item.Price then
		PlotService.Notify(player, "Error", "Not enough cash — you need " .. Config.FormatMoney(math.ceil(item.Price - data.Cash)) .. " more")
		return
	end
	local oldCup = cupValue(player, data)
	data.Cash -= item.Price
	data.Level = item.Level
	showItem(state.Plot, item.Level)
	refreshPads(state.Plot)
	PlotService.Notify(player, "Buy", string.format("Built %s! Each cup now earns %s (was %s)",
		item.Name, Config.FormatMoney(cupValue(player, data)), Config.FormatMoney(oldCup)))
	if data.Level >= Config.MAX_LEVEL then
		PlotService.Notify(player, "Buy", "Congratulations! Your Thai tea empire is complete!")
	end
end

local UPGRADE_MESSAGES = {
	Staff = "Hired a barista! Your shop now earns %s per second by itself",
	Recipe = "Better recipe! Each cup now earns %s",
	Speed = "Faster service! Brewing and staff are %s faster",
}

local function tryUpgrade(player: Player, state: OwnerState, key: string)
	local data = state.Data
	local cost = Config.UpgradeCost(key, data[key])
	if not cost then
		PlotService.Notify(player, "Error", Config.UPGRADES[key].Name .. " is maxed out")
		return
	end
	if data.Cash < cost then
		PlotService.Notify(player, "Error", "Not enough cash — you need " .. Config.FormatMoney(math.ceil(cost - data.Cash)) .. " more")
		return
	end
	data.Cash -= cost
	data[key] += 1
	refreshPads(state.Plot)
	local detail = if key == "Staff" then Config.FormatRate(autoIncome(player, data))
		elseif key == "Recipe" then Config.FormatMoney(cupValue(player, data))
		else string.format("%d%%", math.floor((Config.SpeedMultiplier(data.Speed) - 1) * 100 + 0.5))
	PlotService.Notify(player, "Buy", string.format(UPGRADE_MESSAGES[key], detail))
end

local function updateOwner(player: Player, state: OwnerState, dt: number)
	local data = state.Data
	data.Cash += autoIncome(player, data) * dt
	local nextItem = Config.GetItem(data.Level + 1)
	if nextItem and data.Cash >= nextItem.Price and Monetization.HasPass(player, "AutoBuild") then
		tryBuy(player, state)
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if root and humanoid and humanoid.Health > 0 then
		local position = root.Position
		-- buy/upgrade only when stepping onto a pad; standing still never re-buys, step off first
		for i, pad in state.Plot.Pads do
			local onPad = pad.Transparency < 1 and isStandingOn(pad, position)
			if onPad and not state.OnPad[i] then
				tryBuy(player, state)
			end
			state.OnPad[i] = onPad
		end
		for key, pad in state.Plot.UpgradePads do
			local on = isStandingOn(pad, position)
			if on and not state.OnUpgrade[key] then
				tryUpgrade(player, state, key)
			end
			state.OnUpgrade[key] = on
		end
	else
		table.clear(state.OnPad)
		table.clear(state.OnUpgrade)
	end

	setAttr(player, "Cash", math.floor(data.Cash))
	setAttr(player, "Level", data.Level)
	setAttr(player, "Income", autoIncome(player, data))
	setAttr(player, "BrewValue", cupValue(player, data))
	setAttr(player, "BrewCooldown", brewCooldown(data))
	setAttr(player, "Staff", data.Staff)
	setAttr(player, "Recipe", data.Recipe)
	setAttr(player, "Speed", data.Speed)
end

---------------------------------------------------------------------------
-- Plot setup at server start
---------------------------------------------------------------------------
local function setupPlot(model: Model, storageRoot: Folder): PlotState?
	local padSlots = model:FindFirstChild("PadSlots")
	if not padSlots then
		warn("[PlotService] " .. model.Name .. " has no PadSlots — skipping this plot")
		return nil
	end

	local pads: { BasePart } = {}
	local padLabels: { TextLabel } = {}
	for i = 1, Config.PAD_COUNT do
		local pad = padSlots:FindFirstChild("Pad" .. i)
		if not (pad and pad:IsA("BasePart")) then
			warn("[PlotService] " .. model.Name .. " has no PadSlots.Pad" .. i .. " — skipping this plot")
			return nil
		end
		pad.Anchored = true
		pad.CanCollide = false
		table.insert(pads, pad)
		table.insert(padLabels, makeLabel(pad, 3.5))
	end

	local upgradePads: { [string]: BasePart } = {}
	local upgradeLabels: { [string]: TextLabel } = {}
	local upgrades = model:FindFirstChild("Upgrades")
	for _, key in Config.UPGRADE_ORDER do
		local pad = upgrades and upgrades:FindFirstChild(key)
		if pad and pad:IsA("BasePart") then
			pad.Anchored = true
			pad.CanCollide = false
			upgradePads[key] = pad
			upgradeLabels[key] = makeLabel(pad, 3.5)
		else
			warn("[PlotService] " .. model.Name .. " has no Upgrades." .. key .. " pad — that upgrade cannot be bought here")
		end
	end

	local itemsFolder = model:FindFirstChild("Items")
	if not itemsFolder then
		itemsFolder = Instance.new("Folder")
		itemsFolder.Name = "Items"
		itemsFolder.Parent = model
	end

	-- hide every item in ServerStorage first (positions are kept)
	local storage = Instance.new("Folder")
	storage.Name = model.Name
	storage.Parent = storageRoot
	for _, child in itemsFolder:GetChildren() do
		child.Parent = storage
	end

	local missing = {}
	for level = 2, Config.MAX_LEVEL do
		local key = Config.Items[level].Key
		if not storage:FindFirstChild(key) then
			table.insert(missing, key)
		end
	end
	if #missing > 0 then
		warn("[PlotService] " .. model.Name .. " is missing models: " .. table.concat(missing, ", ")
			.. " (they can still be bought, nothing will appear)")
	end

	local sign = model:FindFirstChild("Sign")
	local signLabel = sign and sign:FindFirstChildWhichIsA("TextLabel", true)
	local base = model:FindFirstChild("Base")
	local floor = if base and base:IsA("BasePart") then base.CFrame * CFrame.new(0, base.Size.Y / 2, 0) else nil

	-- staff carts (built once, shown as the owner hires) and the VIP barista
	local staffModels: { Model } = {}
	local vipModel: Model? = nil
	if floor then
		for i, spot in ItemModels.StaffSpots do
			local cart = ItemModels.BuildDecor("StaffCart", floor * CFrame.new(spot[1], 0, spot[2]), i)
			if cart then
				cart.Name = "Staff" .. i
				cart.Parent = storage
				table.insert(staffModels, cart)
			end
		end
		local vipSpot = ItemModels.VipSpot
		vipModel = ItemModels.BuildDecor("StaffCart", floor * CFrame.new(vipSpot[1], 0, vipSpot[2]), 0)
		if vipModel then
			vipModel.Name = "VipBarista"
			vipModel.Parent = storage
		end
	end

	-- Brew Station: a ProximityPrompt on its Kettle (press E / tap / click)
	local station = model:FindFirstChild("BrewStation")
	local kettle = station and (station:FindFirstChild("Kettle", true) or (if station:IsA("BasePart") then station else nil))
	if not kettle then
		warn("[PlotService] " .. model.Name .. " has no BrewStation with a Kettle part — players cannot brew here")
	end
	local brewPad = station and station:FindFirstChild("BrewPad", true) :: BasePart?

	local plot: PlotState = {
		Model = model,
		Name = model.Name,
		Floor = floor,
		Pads = pads,
		PadLabels = padLabels,
		PadGlow = makePadGlow(pads[1]),
		UpgradePads = upgradePads,
		UpgradeLabels = upgradeLabels,
		StaffModels = staffModels,
		VipModel = vipModel,
		Kettle = kettle,
		BrewPad = brewPad,
		SignLabel = signLabel,
		ItemsFolder = itemsFolder :: Folder,
		Storage = storage,
		Owner = nil,
	}

	if kettle then
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "BrewPrompt"
		prompt.ActionText = "Brew Tea"
		prompt.ObjectText = "Brew Station"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.HoldDuration = 0
		-- on the mat behind the counter when there is one (only reachable from the brewer's side)
		prompt.MaxActivationDistance = if brewPad then 4.5 else 12
		prompt.RequiresLineOfSight = false
		prompt.ClickablePrompt = true
		prompt.Parent = brewPad or kettle
		prompt.Triggered:Connect(function(player)
			brew(player, plot)
		end)
	end

	setSign(plot, "Empty Plot")
	refreshPads(plot)
	return plot
end

---------------------------------------------------------------------------
-- Players joining / leaving
---------------------------------------------------------------------------
function PlotService.AddPlayer(player: Player, data): boolean
	local plot: PlotState? = nil
	for _, candidate in plots do
		if not candidate.Owner then
			plot = candidate
			break
		end
	end
	if not plot then
		player:Kick("This server is full (no free plot). Please try another server.")
		return false
	end

	plot.Owner = player
	plot.Model:SetAttribute("Owned", true) -- clients animate queueing customers on owned plots
	local state: OwnerState = { Plot = plot, Data = data, OnPad = {}, OnUpgrade = {}, LastBrew = 0 }
	owners[player] = state

	for level = 2, data.Level do
		showItem(plot, level)
	end
	setSign(plot, player.DisplayName .. "'s Thai Tea")
	refreshPads(plot)
	player:SetAttribute("Plot", plot.Name)

	-- Offline earnings (staff keep selling while you are away, at the offline rate)
	local elapsed = os.time() - data.LastSeen
	if elapsed >= Config.OFFLINE.MIN_SECONDS then
		local plus = Monetization.HasPass(player, "OfflinePlus")
		local rate = if plus then Config.OFFLINE.PASS_RATE else Config.OFFLINE.RATE
		local maxHours = if plus then Config.OFFLINE.PASS_MAX_HOURS else Config.OFFLINE.MAX_HOURS
		local seconds = math.min(elapsed, maxHours * 3600)
		local earned = math.floor(autoIncome(player, data) * seconds * rate)
		if earned > 0 then
			data.Cash += earned
			task.delay(3, PlotService.Notify, player, "Offline", string.format(
				"While you were away (%s) your shop earned %s", Config.FormatTime(seconds), Config.FormatMoney(earned)))
		end
	end
	data.LastSeen = os.time()

	updateOwner(player, state, 0)
	return true
end

function PlotService.RemovePlayer(player: Player)
	local state = owners[player]
	if not state then
		return
	end
	owners[player] = nil
	state.Data.LastSeen = os.time()

	local plot = state.Plot
	plot.Owner = nil
	plot.Model:SetAttribute("Owned", false)
	hideAllItems(plot)
	setSign(plot, "Empty Plot")
	refreshPads(plot)
end

---------------------------------------------------------------------------
-- Startup
---------------------------------------------------------------------------
function PlotService.Init(monetization, remote: RemoteEvent)
	Monetization = monetization
	notifyRemote = remote

	local folder = workspace:FindFirstChild("Plots")
	if not folder then
		if Config.BUILD_PLACEHOLDER_PLOTS then
			folder = DevPlotBuilder.Build()
		else
			error("[PlotService] Workspace.Plots not found and BUILD_PLACEHOLDER_PLOTS is off")
		end
	end

	local storageRoot = Instance.new("Folder")
	storageRoot.Name = "PlotItemStorage"
	storageRoot.Parent = ServerStorage

	local models = {}
	for _, child in folder:GetChildren() do
		if child:IsA("Model") then
			table.insert(models, child)
		end
	end
	-- sort Plot1, Plot2, ... numerically
	table.sort(models, function(a, b)
		local na = tonumber(a.Name:match("%d+")) or 0
		local nb = tonumber(b.Name:match("%d+")) or 0
		return if na == nb then a.Name < b.Name else na < nb
	end)
	for _, model in models do
		local plot = setupPlot(model, storageRoot)
		if plot then
			table.insert(plots, plot)
		end
	end

	if #plots < Players.MaxPlayers then
		warn(string.format("[PlotService] %d plots but Max Players = %d (they should match)",
			#plots, Players.MaxPlayers))
	end
	print("[PlotService] Ready with " .. #plots .. " plots")

	task.spawn(function()
		local last = os.clock()
		while true do
			task.wait(Config.TICK)
			local now = os.clock()
			local dt = math.min(now - last, 1)
			last = now
			for player, state in owners do
				local ok, err = pcall(updateOwner, player, state, dt)
				if not ok then
					warn("[PlotService] Update failed for " .. player.Name .. ": " .. tostring(err))
				end
			end
		end
	end)
end

return PlotService
