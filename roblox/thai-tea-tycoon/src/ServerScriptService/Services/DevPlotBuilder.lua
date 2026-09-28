-- DevPlotBuilder: สร้างฐานจำลอง 6 ฐาน (บล็อกสีตามขั้น) ไว้ทดสอบ ก่อนมีโมเดลจริง
-- โครงสร้างที่สร้างตรงกับที่ PlotService ต้องการ:
--   Workspace.Plots.PlotN { Base, Items{L02..L45}, PadSlots{Pad1..Pad3}, Register, Sign{SurfaceGui.TextLabel} }

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local DevPlotBuilder = {}

local PLOT_SIZE = 60
local ROW_OFFSET = 50 -- ระยะจากกลางลานถึงกลางฐาน (แกน Z)
local COLUMN_GAP = 70 -- ระยะห่างฐานแต่ละฐาน (แกน X)
local FLOOR_TOP = 1 -- ความสูงผิวพื้นฐาน

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

local function label(parent: Instance, text: string, offsetY: number, maxDistance: number)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(160, 36)
	gui.StudsOffset = Vector3.new(0, offsetY, 0)
	gui.MaxDistance = maxDistance
	local text_ = Instance.new("TextLabel")
	text_.Size = UDim2.fromScale(1, 1)
	text_.BackgroundTransparency = 1
	text_.Text = text
	text_.TextScaled = true
	text_.Font = Enum.Font.GothamBold
	text_.TextColor3 = Color3.new(1, 1, 1)
	text_.TextStrokeTransparency = 0.3
	text_.Parent = gui
	gui.Parent = parent
end

local function buildPlot(index: number, origin: CFrame): Model
	local plot = Instance.new("Model")
	plot.Name = "Plot" .. index

	local base = part({
		Name = "Base",
		Size = Vector3.new(PLOT_SIZE, 1, PLOT_SIZE),
		CFrame = origin * CFrame.new(0, FLOOR_TOP - 0.5, 0),
		Color = Color3.fromRGB(196, 164, 132),
		Material = Enum.Material.WoodPlanks,
	})
	base.Parent = plot
	plot.PrimaryPart = base

	-- แผ่นซื้อของด้านหน้า (ฝั่ง -Z ของฐาน = ฝั่งลานกลาง)
	local pads = Instance.new("Folder")
	pads.Name = "PadSlots"
	pads.Parent = plot
	for i = 1, Config.PAD_COUNT do
		part({
			Name = "Pad" .. i,
			Size = Vector3.new(9, 0.6, 9),
			CFrame = origin * CFrame.new((i - 2) * 14, FLOOR_TOP + 0.3, -22),
			Color = Color3.fromRGB(46, 204, 113),
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
		}).Parent = pads
	end

	part({
		Name = "Register",
		Size = Vector3.new(7, 0.6, 7),
		CFrame = origin * CFrame.new(23, FLOOR_TOP + 0.3, -12),
		Color = Color3.fromRGB(255, 196, 0),
		Material = Enum.Material.Neon,
		CanCollide = false,
	}).Parent = plot

	local sign = part({
		Name = "Sign",
		Size = Vector3.new(30, 6, 1),
		CFrame = origin * CFrame.new(0, FLOOR_TOP + 11, 29),
		Color = Color3.fromRGB(120, 60, 20),
		Material = Enum.Material.Wood,
	})
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 20
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBlack
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(255, 240, 200)
	text.Text = "ฐานว่าง"
	text.Parent = surface
	surface.Parent = sign
	sign.Parent = plot

	-- เสาค้ำป้าย
	for _, x in { -13, 13 } do
		part({
			Name = "SignPost",
			Size = Vector3.new(1, 8, 1),
			CFrame = origin * CFrame.new(x, FLOOR_TOP + 4, 29),
			Color = Color3.fromRGB(90, 45, 15),
		}).Parent = plot
	end

	-- ของ 44 ชิ้น: ตาราง 11 คอลัมน์ × 4 แถว
	local items = Instance.new("Folder")
	items.Name = "Items"
	items.Parent = plot
	for level = 2, Config.MAX_LEVEL do
		local item = Config.Items[level]
		local n = level - 2
		local column, row = n % 11, math.floor(n / 11)
		local height = 1.5 + item.Tier * 1.2
		local model = Instance.new("Model")
		model.Name = item.Key
		local block = part({
			Name = "Block",
			Size = Vector3.new(3.6, height, 3.6),
			CFrame = origin * CFrame.new(-25 + column * 5, FLOOR_TOP + height / 2, -3 + row * 7),
			Color = Config.TIERS[item.Tier].Color,
			Material = Enum.Material.SmoothPlastic,
		})
		block.Parent = model
		model.PrimaryPart = block
		label(block, item.Name, height / 2 + 1.2, 45)
		model.Parent = items
	end

	return plot
end

-- สร้าง Workspace.Plots พร้อมจุดเกิดกลางลาน
function DevPlotBuilder.Build(): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Plots"

	local perRow = math.ceil(Config.PLOT_COUNT / 2)
	for i = 1, Config.PLOT_COUNT do
		local topRow = i <= perRow
		local column = (i - 1) % perRow
		local x = (column - (perRow - 1) / 2) * COLUMN_GAP
		local z = if topRow then ROW_OFFSET else -ROW_OFFSET
		-- ด้านหน้าของฐาน (-Z ในตัวฐาน) ต้องหันเข้าลานกลาง: แถวล่างหมุน 180°
		local origin = CFrame.new(x, 0, z) * CFrame.Angles(0, if topRow then 0 else math.pi, 0)
		buildPlot(i, origin).Parent = folder
	end

	if not workspace:FindFirstChildWhichIsA("SpawnLocation", true) then
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "PlazaSpawn"
		spawn.Anchored = true
		spawn.Size = Vector3.new(12, 1, 12)
		spawn.Position = Vector3.new(0, 0.5, 0)
		spawn.Duration = 0
		spawn.Parent = workspace
	end

	folder.Parent = workspace
	print("[DevPlotBuilder] สร้างฐานจำลอง " .. Config.PLOT_COUNT .. " ฐานแล้ว")
	return folder
end

return DevPlotBuilder
