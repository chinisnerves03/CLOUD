-- PlotService: จองฐาน, แสดงของตามเลเวล, รายได้เข้าตู้, เหยียบแผ่นเพื่อซื้อ, เหยียบตู้เพื่อเก็บเงิน
-- ทุกอย่างคำนวณที่เซิร์ฟเวอร์ ไคลเอนต์อ่านผลจาก Attribute บนตัวผู้เล่น:
--   Cash, Stored, Level, Income, Plot

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local DevPlotBuilder = require(script.Parent:WaitForChild("DevPlotBuilder"))

local PlotService = {}

local COLOR_ACTIVE = Color3.fromRGB(46, 204, 113)
local COLOR_PREVIEW = Color3.fromRGB(120, 120, 120)
local COLOR_EMPTY = Color3.fromRGB(80, 80, 80)
local PAD_MARGIN = 0.5 -- ยืนเลยขอบแผ่นได้นิดหน่อย
local PAD_HEIGHT = 7 -- ความสูงเหนือแผ่นที่ยังนับว่า "ยืนอยู่"

type PlotState = {
	Model: Model,
	Name: string,
	Pads: { BasePart },
	PadLabels: { TextLabel },
	Register: BasePart,
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
}

local Monetization
local notifyRemote: RemoteEvent
local plots: { PlotState } = {}
local owners: { [Player]: OwnerState } = {}

---------------------------------------------------------------------------
-- ตัวช่วย
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
	gui.MaxDistance = 80
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

---------------------------------------------------------------------------
-- การแสดงผลของฐาน
---------------------------------------------------------------------------
local function refreshPads(plot: PlotState)
	local state = plot.Owner and owners[plot.Owner]
	for i, pad in plot.Pads do
		local labelText = plot.PadLabels[i]
		if not state then
			pad.Transparency = 0
			pad.Color = COLOR_EMPTY
			labelText.Text = ""
			continue
		end

		local item = Config.GetItem(state.Data.Level + i)
		if not item then
			-- ซื้อครบแล้ว ซ่อนแผ่นที่เหลือ
			pad.Transparency = 1
			labelText.Text = ""
		elseif i == 1 then
			pad.Transparency = 0
			pad.Color = COLOR_ACTIVE
			labelText.TextColor3 = Color3.new(1, 1, 1)
			labelText.Text = item.Name .. "\n" .. Config.FormatMoney(item.Price)
		else
			pad.Transparency = 0.4
			pad.Color = COLOR_PREVIEW
			labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
			labelText.Text = "ถัดไป: " .. item.Name .. "\n" .. Config.FormatMoney(item.Price)
		end
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
-- เตรียมฐานตอนเริ่มเซิร์ฟเวอร์
---------------------------------------------------------------------------
local function setupPlot(model: Model, storageRoot: Folder): PlotState?
	local padSlots = model:FindFirstChild("PadSlots")
	local register = model:FindFirstChild("Register")
	if not padSlots or not (register and register:IsA("BasePart")) then
		warn("[PlotService] " .. model.Name .. " ไม่มี PadSlots หรือ Register — ข้ามฐานนี้")
		return nil
	end

	local pads: { BasePart } = {}
	local padLabels: { TextLabel } = {}
	for i = 1, Config.PAD_COUNT do
		local pad = padSlots:FindFirstChild("Pad" .. i)
		if not (pad and pad:IsA("BasePart")) then
			warn("[PlotService] " .. model.Name .. " ไม่มี PadSlots.Pad" .. i .. " — ข้ามฐานนี้")
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

	-- ย้ายของทั้งหมดไปซ่อนใน ServerStorage ก่อน (ตำแหน่งเดิมไม่เปลี่ยน)
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
		warn("[PlotService] " .. model.Name .. " ยังไม่มีโมเดล: " .. table.concat(missing, ", ")
			.. " (ซื้อได้ปกติ แต่จะไม่มีอะไรโผล่)")
	end

	local sign = model:FindFirstChild("Sign")
	local signLabel = sign and sign:FindFirstChildWhichIsA("TextLabel", true)

	local plot: PlotState = {
		Model = model,
		Name = model.Name,
		Pads = pads,
		PadLabels = padLabels,
		Register = register,
		SignLabel = signLabel,
		ItemsFolder = itemsFolder :: Folder,
		Storage = storage,
		Owner = nil,
	}
	setSign(plot, "ฐานว่าง")
	refreshPads(plot)
	return plot
end

---------------------------------------------------------------------------
-- ซื้อ / เก็บเงิน
---------------------------------------------------------------------------
function PlotService.GetIncomePerSecond(player: Player): number
	local state = owners[player]
	if not state then
		return 0
	end
	return Config.GetIncome(state.Data.Level) * Monetization.IncomeMultiplier(player)
end

function PlotService.AddCash(player: Player, amount: number)
	local state = owners[player]
	if state then
		state.Data.Cash += amount
	end
end

local function tryBuy(player: Player, state: OwnerState, padIndex: number)
	local data = state.Data
	local item = Config.GetItem(data.Level + padIndex)
	if not item then
		return
	end
	if padIndex ~= 1 then
		local nextItem = Config.GetItem(data.Level + 1)
		PlotService.Notify(player, "Error", "ต้องซื้อ " .. (nextItem and nextItem.Name or "ชิ้นก่อนหน้า") .. " ก่อน")
		return
	end
	if data.Cash < item.Price then
		PlotService.Notify(player, "Error", "เงินไม่พอ ขาดอีก " .. Config.FormatMoney(math.ceil(item.Price - data.Cash)))
		return
	end

	local oldIncome = PlotService.GetIncomePerSecond(player)
	data.Cash -= item.Price
	data.Level = item.Level
	showItem(state.Plot, item.Level)
	refreshPads(state.Plot)

	local newIncome = PlotService.GetIncomePerSecond(player)
	PlotService.Notify(player, "Buy", string.format("ซื้อ %s แล้ว! รายได้ %s → %s/วินาที",
		item.Name, Config.FormatMoney(oldIncome), Config.FormatMoney(newIncome)))
	if data.Level >= Config.MAX_LEVEL then
		PlotService.Notify(player, "Buy", "ยินดีด้วย! ร้านชาไทยของคุณครบทุกชิ้นแล้ว")
	end
end

local function updateOwner(player: Player, state: OwnerState, dt: number)
	local data = state.Data
	data.Stored += PlotService.GetIncomePerSecond(player) * dt
	if Monetization.HasPass(player, "AutoCollect") then
		data.Cash += data.Stored
		data.Stored = 0
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if root and humanoid and humanoid.Health > 0 then
		local position = root.Position

		local onRegister = isStandingOn(state.Plot.Register, position)
		if onRegister and data.Stored >= 1 then
			local amount = math.floor(data.Stored)
			data.Cash += amount
			data.Stored -= amount
			if not state.OnRegister then
				PlotService.Notify(player, "Collect", "+" .. Config.FormatMoney(amount))
			end
		end
		state.OnRegister = onRegister

		-- ซื้อเฉพาะตอน "ก้าวขึ้น" แผ่น ยืนค้างไว้ไม่ซื้อซ้ำ ต้องเดินออกก่อน
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
	setAttr(player, "Stored", math.floor(data.Stored))
	setAttr(player, "Level", data.Level)
	setAttr(player, "Income", PlotService.GetIncomePerSecond(player))
end

---------------------------------------------------------------------------
-- ผู้เล่นเข้า/ออก
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
		player:Kick("เซิร์ฟเวอร์เต็ม ไม่มีฐานว่าง ลองเข้าใหม่อีกครั้ง")
		return false
	end

	plot.Owner = player
	local state: OwnerState = { Plot = plot, Data = data, OnPad = {}, OnRegister = false }
	owners[player] = state

	for level = 2, data.Level do
		showItem(plot, level)
	end
	setSign(plot, "ร้านชาไทยของ " .. player.DisplayName)
	refreshPads(plot)
	player:SetAttribute("Plot", plot.Name)

	-- รายได้ออฟไลน์
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
				"ระหว่างที่ไม่อยู่ %s ร้านขายได้ %s", Config.FormatTime(seconds), Config.FormatMoney(earned)))
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
	setSign(plot, "ฐานว่าง")
	refreshPads(plot)
end

---------------------------------------------------------------------------
-- เริ่มระบบ
---------------------------------------------------------------------------
function PlotService.Init(monetization, remote: RemoteEvent)
	Monetization = monetization
	notifyRemote = remote

	local folder = workspace:FindFirstChild("Plots")
	if not folder then
		if Config.BUILD_PLACEHOLDER_PLOTS then
			folder = DevPlotBuilder.Build()
		else
			error("[PlotService] ไม่พบ Workspace.Plots และปิด BUILD_PLACEHOLDER_PLOTS อยู่")
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
	-- เรียง Plot1, Plot2, ... ตามตัวเลข
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
		warn(string.format("[PlotService] มี %d ฐาน แต่ Max Players = %d (ควรตั้งให้เท่ากัน)",
			#plots, Players.MaxPlayers))
	end
	print("[PlotService] พร้อมใช้งาน " .. #plots .. " ฐาน")

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
					warn("[PlotService] อัปเดต " .. player.Name .. " ผิดพลาด: " .. tostring(err))
				end
			end
		end
	end)
end

return PlotService
