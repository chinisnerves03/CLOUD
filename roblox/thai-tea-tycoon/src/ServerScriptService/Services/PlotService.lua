-- PlotService: claims plots, shows items by level, and runs the money loop:
--   brew tea at the Brew Station → cash goes into the bag → deposit at COLLECT CASH → buy on the pad.
-- Passive income (smaller) goes straight into Cash. The single buy pad moves to the next item's spot.
-- Everything is computed on the server; the client only reads these player Attributes:
--   Cash, Bag, BagMax, Level, Income (passive per second), BrewValue, Plot

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
	Floor: CFrame?, -- floor center of the plot (used to move the pad); nil for custom plots without a Base
	Pads: { BasePart },
	PadLabels: { TextLabel },
	PadGlow: BasePart,
	Register: BasePart,
	Kettle: BasePart?,
	SignLabel: TextLabel?,
	ItemsFolder: Folder,
	Storage: Folder,
	Owner: Player?,
}

type OwnerState = {
	Plot: PlotState,
	Data: any,
	OnPad: { boolean },
	OnRegister: boolean,
	LastBrew: number,
	BagFullWarned: boolean,
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

local function makePadLabel(pad: BasePart): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = "PadLabel"
	gui.Size = UDim2.fromOffset(220, 64)
	gui.StudsOffset = Vector3.new(0, 3.5, 0)
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

-- a soft green light column over the pad so it is easy to spot across the plot
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

local function incomeMultiplier(player: Player): number
	return Monetization.IncomeMultiplier(player)
end

function PlotService.GetIncomePerSecond(player: Player): number
	local state = owners[player]
	if not state then
		return 0
	end
	return Config.GetPassive(state.Data.Level) * incomeMultiplier(player)
end

-- full-strength income per second (brewing + passive pacing), used to size Cash Boost products
function PlotService.GetBaseIncome(player: Player): number
	local state = owners[player]
	if not state then
		return 0
	end
	return Config.GetIncome(state.Data.Level) * incomeMultiplier(player)
end

local function brewValue(player: Player, level: number): number
	return Config.GetBrewValue(level) * incomeMultiplier(player)
end

local function bagCapacity(player: Player, level: number): number
	return Config.GetBagCapacity(level) * incomeMultiplier(player)
end

---------------------------------------------------------------------------
-- Plot visuals
---------------------------------------------------------------------------
local function refreshPads(plot: PlotState)
	local state = plot.Owner and owners[plot.Owner]
	for i, pad in plot.Pads do
		local labelText = plot.PadLabels[i]
		if not state then
			pad.Transparency = 0
			pad.Color = COLOR_EMPTY
			labelText.Text = ""
			plot.PadGlow.Transparency = 1
			continue
		end

		local item = Config.GetItem(state.Data.Level + i)
		if not item then
			-- everything bought: hide the pad
			pad.Transparency = 1
			labelText.Text = ""
			plot.PadGlow.Transparency = 1
			continue
		end

		-- move the pad next to where this item will appear
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
-- Brewing / depositing / buying
---------------------------------------------------------------------------
function PlotService.AddCash(player: Player, amount: number)
	local state = owners[player]
	if state then
		state.Data.Cash += amount
	end
end

local function deposit(player: Player, state: OwnerState, announce: boolean)
	local data = state.Data
	if data.Bag < 1 then
		return
	end
	local amount = math.floor(data.Bag)
	data.Cash += amount
	data.Bag -= amount
	state.BagFullWarned = false
	if announce then
		PlotService.Notify(player, "Collect", "Deposited +" .. Config.FormatMoney(amount))
	end
end

local function brew(player: Player, plot: PlotState)
	local state = owners[player]
	if not state or state.Plot ~= plot then
		PlotService.Notify(player, "Error", "This is not your shop — brew at your own Brew Station")
		return
	end
	local now = os.clock()
	if now - state.LastBrew < Config.BREW_COOLDOWN then
		return
	end
	state.LastBrew = now

	local data = state.Data
	local capacity = bagCapacity(player, data.Level)
	if data.Bag >= capacity then
		PlotService.Notify(player, "Error", "Your bag is full! Deposit at COLLECT CASH")
		return
	end
	local value = brewValue(player, data.Level)
	data.Bag = math.min(capacity, data.Bag + value)
	PlotService.Notify(player, "Brew", "+" .. Config.FormatMoney(value))
	if Monetization.HasPass(player, "AutoCollect") then
		deposit(player, state, false)
	end
end

local function tryBuy(player: Player, state: OwnerState, padIndex: number)
	local data = state.Data
	local item = Config.GetItem(data.Level + padIndex)
	if not item then
		return
	end
	if padIndex ~= 1 then
		return
	end
	if data.Cash < item.Price then
		local missing = math.ceil(item.Price - data.Cash)
		if data.Bag >= missing then
			PlotService.Notify(player, "Error", "Deposit your bag at COLLECT CASH first")
		else
			PlotService.Notify(player, "Error", "Not enough cash — you need " .. Config.FormatMoney(missing))
		end
		return
	end

	local oldBrew = brewValue(player, data.Level)
	data.Cash -= item.Price
	data.Level = item.Level
	showItem(state.Plot, item.Level)
	refreshPads(state.Plot)

	local newBrew = brewValue(player, data.Level)
	PlotService.Notify(player, "Buy", if newBrew > oldBrew
		then string.format("Bought %s! Each cup now earns %s (was %s)", item.Name, Config.FormatMoney(newBrew), Config.FormatMoney(oldBrew))
		else string.format("Bought %s! Your shop earns more every second", item.Name))
	if data.Level >= Config.MAX_LEVEL then
		PlotService.Notify(player, "Buy", "Congratulations! Your Thai tea empire is complete!")
	end
end

local function updateOwner(player: Player, state: OwnerState, dt: number)
	local data = state.Data
	data.Cash += PlotService.GetIncomePerSecond(player) * dt

	local capacity = bagCapacity(player, data.Level)
	if data.Bag >= capacity and not state.BagFullWarned then
		state.BagFullWarned = true
		PlotService.Notify(player, "Error", "Your bag is full! Deposit at COLLECT CASH")
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if root and humanoid and humanoid.Health > 0 then
		local position = root.Position

		-- deposit when stepping onto COLLECT CASH (and keep depositing while standing on it)
		local onRegister = isStandingOn(state.Plot.Register, position)
		if onRegister then
			deposit(player, state, not state.OnRegister)
		end
		state.OnRegister = onRegister

		-- buy only when stepping onto the pad; standing still never re-buys, step off first
		for i, pad in state.Plot.Pads do
			local onPad = pad.Transparency < 1 and isStandingOn(pad, position)
			if onPad and not state.OnPad[i] then
				tryBuy(player, state, i)
			end
			state.OnPad[i] = onPad
		end
	else
		state.OnRegister = false
		table.clear(state.OnPad)
	end

	setAttr(player, "Cash", math.floor(data.Cash))
	setAttr(player, "Bag", math.floor(data.Bag))
	setAttr(player, "BagMax", capacity)
	setAttr(player, "Level", data.Level)
	setAttr(player, "Income", PlotService.GetIncomePerSecond(player))
	setAttr(player, "BrewValue", brewValue(player, data.Level))
end

---------------------------------------------------------------------------
-- Plot setup at server start
---------------------------------------------------------------------------
local function setupPlot(model: Model, storageRoot: Folder): PlotState?
	local padSlots = model:FindFirstChild("PadSlots")
	local register = model:FindFirstChild("Register")
	if not padSlots or not (register and register:IsA("BasePart")) then
		warn("[PlotService] " .. model.Name .. " has no PadSlots or Register — skipping this plot")
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
		table.insert(padLabels, makePadLabel(pad))
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

	-- Brew Station: a ProximityPrompt on its Kettle (press E / tap / click)
	local station = model:FindFirstChild("BrewStation")
	local kettle = station and (station:FindFirstChild("Kettle", true) or (if station:IsA("BasePart") then station else nil))
	if not kettle then
		warn("[PlotService] " .. model.Name .. " has no BrewStation with a Kettle part — players cannot brew here")
	end

	local plot: PlotState = {
		Model = model,
		Name = model.Name,
		Floor = floor,
		Pads = pads,
		PadLabels = padLabels,
		PadGlow = makePadGlow(pads[1]),
		Register = register,
		Kettle = kettle,
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
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.ClickablePrompt = true
		prompt.Parent = kettle
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
	local state: OwnerState = {
		Plot = plot, Data = data, OnPad = {}, OnRegister = false, LastBrew = 0, BagFullWarned = false,
	}
	owners[player] = state

	for level = 2, data.Level do
		showItem(plot, level)
	end
	setSign(plot, player.DisplayName .. "'s Thai Tea")
	refreshPads(plot)
	player:SetAttribute("Plot", plot.Name)

	-- Offline earnings (from passive income)
	local elapsed = os.time() - data.LastSeen
	if elapsed >= Config.OFFLINE.MIN_SECONDS then
		local plus = Monetization.HasPass(player, "OfflinePlus")
		local rate = if plus then Config.OFFLINE.PASS_RATE else Config.OFFLINE.RATE
		local maxHours = if plus then Config.OFFLINE.PASS_MAX_HOURS else Config.OFFLINE.MAX_HOURS
		local seconds = math.min(elapsed, maxHours * 3600)
		local earned = math.floor(PlotService.GetIncomePerSecond(player) * seconds * rate)
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
