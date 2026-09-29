-- LeaderboardService: global top-10 boards in the plaza (Config.LEADERBOARDS), backed by OrderedDataStores.
-- Every LEADERBOARD_REFRESH seconds it uploads the score of everyone in the server, then redraws each board.
-- Boards are built from Parts unless Workspace.Leaderboards already has a model with the board's Name.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local LeaderboardService = {}

local ROWS = 10
local BOARD_SIZE = Vector3.new(14, 17, 0.6)
local WOOD = Color3.fromRGB(95, 60, 35)
local ORANGE = Color3.fromRGB(230, 126, 34)

type Board = { Spec: any, Store: OrderedDataStore?, Rows: { TextLabel }, Status: TextLabel }

local DataService
local boards: { Board } = {}
local names: { [number]: string } = {}
local warned = false

local function part(props): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

local function label(parent: Instance, props): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamBold
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextScaled = true
	for k, v in props do
		(l :: any)[k] = v
	end
	l.Parent = parent
	return l
end

-- a wooden sign on two posts; returns the model and the board part carrying the SurfaceGui (front = -Z)
local function buildBoard(spec): (Model, BasePart)
	local model = Instance.new("Model")
	model.Name = spec.Name
	local base: CFrame = spec.CFrame
	local boardCf = base * CFrame.new(0, 3 + BOARD_SIZE.Y / 2, 0)
	local board = part({ Name = "Board", Size = BOARD_SIZE, CFrame = boardCf, Color = Color3.fromRGB(45, 30, 20), Material = Enum.Material.Wood })
	board.Parent = model
	part({ Name = "Frame", Size = BOARD_SIZE + Vector3.new(0.8, 0.8, -0.2), CFrame = boardCf * CFrame.new(0, 0, 0.2), Color = WOOD, Material = Enum.Material.WoodPlanks }).Parent = model
	part({ Name = "Header", Size = Vector3.new(BOARD_SIZE.X + 1.6, 1.2, 1.2), CFrame = boardCf * CFrame.new(0, BOARD_SIZE.Y / 2 + 0.6, 0), Color = ORANGE, Material = Enum.Material.SmoothPlastic }).Parent = model
	for _, x in { -BOARD_SIZE.X / 2 + 1, BOARD_SIZE.X / 2 - 1 } do
		local height = 3 + BOARD_SIZE.Y
		part({ Name = "Post", Size = Vector3.new(0.8, height, 0.8), CFrame = base * CFrame.new(x, height / 2, 0.6), Color = WOOD, Material = Enum.Material.Wood }).Parent = model
	end
	model.PrimaryPart = board
	return model, board
end

local function setupBoard(spec, folder: Folder): Board
	local model = folder:FindFirstChild(spec.Name)
	local board: BasePart
	if model and model:IsA("Model") and model:FindFirstChild("Board") then
		board = model:FindFirstChild("Board") :: BasePart
	else
		local built
		built, board = buildBoard(spec)
		built.Parent = folder
	end

	local gui = Instance.new("SurfaceGui")
	gui.Name = "LeaderboardGui"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.LightInfluence = 0.2
	gui.Parent = board
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = gui
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 16)
	pad.PaddingLeft = UDim.new(0, 18)
	pad.PaddingRight = UDim.new(0, 18)
	pad.Parent = gui

	label(gui, { Name = "Title", LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 58), Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 214, 10), Text = spec.Title })
	local status = label(gui, { Name = "Status", LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 26), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(200, 190, 180), Text = "Loading..." })
	local rows = {}
	for i = 1, ROWS do
		local row = label(gui, { Name = "Row" .. i, LayoutOrder = 1 + i, Size = UDim2.new(1, 0, 0, 34),
			TextXAlignment = Enum.TextXAlignment.Left, Text = "",
			TextColor3 = if i == 1 then Color3.fromRGB(255, 215, 90) elseif i <= 3 then Color3.fromRGB(230, 230, 240) else Color3.new(1, 1, 1) })
		table.insert(rows, row)
	end

	local store: OrderedDataStore? = nil
	local ok, result = pcall(function()
		return DataStoreService:GetOrderedDataStore(Config.LEADERBOARD_STORE, spec.Stat)
	end)
	if ok then
		store = result
	end
	return { Spec = spec, Store = store, Rows = rows, Status = status }
end

local function nameFor(userId: number): string
	if names[userId] then
		return names[userId]
	end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	names[userId] = if ok and name then name else "Player"
	return names[userId]
end

local function upload(board: Board)
	if not board.Store then
		return
	end
	for _, player in Players:GetPlayers() do
		local data = DataService.Get(player)
		-- a failed load (NoSave) would upload 0 over the real score
		if data and not data.NoSave then
			local score = math.floor(tonumber(data[board.Spec.Stat]) or 0)
			if score > 0 then
				pcall(function()
					(board.Store :: OrderedDataStore):SetAsync("u_" .. player.UserId, score)
				end)
			end
		end
	end
end

local function redraw(board: Board)
	if not board.Store then
		board.Status.Text = "Leaderboard offline"
		return
	end
	local ok, pages = pcall(function()
		return (board.Store :: OrderedDataStore):GetSortedAsync(false, ROWS)
	end)
	if not ok then
		board.Status.Text = "Leaderboard offline"
		if not warned then
			warned = true
			warn("[Leaderboard] " .. tostring(pages))
		end
		return
	end
	local entries = pages:GetCurrentPage()
	for i, row in board.Rows do
		local entry = entries[i]
		if entry then
			local userId = tonumber(tostring(entry.key):match("%d+")) or 0
			local value = if board.Spec.Money then Config.FormatMoney(entry.value) else tostring(entry.value)
			row.Text = string.format("%d. %s  —  %s", i, nameFor(userId), value)
		else
			row.Text = ""
		end
	end
	board.Status.Text = if #entries == 0 then "Be the first on the board!" else "Updates every few minutes"
end

function LeaderboardService.Init(dataService)
	DataService = dataService
	local folder = workspace:FindFirstChild("Leaderboards")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Leaderboards"
		folder.Parent = workspace
	end
	for _, spec in Config.LEADERBOARDS do
		table.insert(boards, setupBoard(spec, folder :: Folder))
	end

	task.spawn(function()
		task.wait(10) -- let the first players load
		while true do
			for _, board in boards do
				upload(board)
				redraw(board)
			end
			task.wait(Config.LEADERBOARD_REFRESH)
		end
	end)
end

-- final upload when a player leaves (called before DataService.Release)
function LeaderboardService.RemovePlayer(player: Player)
	local data = DataService.Get(player)
	if not data or data.NoSave then
		return
	end
	for _, board in boards do
		local score = math.floor(tonumber(data[board.Spec.Stat]) or 0)
		if board.Store and score > 0 then
			task.spawn(pcall, function()
				(board.Store :: OrderedDataStore):SetAsync("u_" .. player.UserId, score)
			end)
		end
	end
end

return LeaderboardService
