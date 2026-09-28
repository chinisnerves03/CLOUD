-- DevPlotBuilder: สร้างฐาน 6 ฐานพร้อมโมเดลของทั้ง 44 ชิ้น (จาก ItemModels) ไว้ทดสอบ/ใช้งาน ก่อนมีโมเดลที่ทำเอง
-- โครงสร้างที่สร้างตรงกับที่ PlotService ต้องการ:
--   Workspace.Plots.PlotN { Base, Items{L02..L45}, PadSlots{Pad1..Pad3}, Register, Sign{SurfaceGui.TextLabel} }

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local ItemModels = require(script.Parent:WaitForChild("ItemModels"))

local DevPlotBuilder = {}

local PLOT_WIDTH = 80 -- แกน X
local PLOT_DEPTH = 100 -- แกน Z (ด้านหน้า -Z หันเข้าลาน)
local PLAZA_HALF = 20 -- ครึ่งหนึ่งของความกว้างลานกลาง
local COLUMN_GAP = 90 -- ระยะห่างกึ่งกลางฐานตามแกน X
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

local function billboard(parent: Instance, text: string, offsetY: number)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(160, 40)
	gui.StudsOffset = Vector3.new(0, offsetY, 0)
	gui.MaxDistance = 60
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 214, 10)
	label.TextStrokeTransparency = 0.2
	label.Text = text
	label.Parent = gui
	gui.Parent = parent
end

local function buildPlot(index: number, origin: CFrame): Model
	local plot = Instance.new("Model")
	plot.Name = "Plot" .. index
	local floor = origin * CFrame.new(0, FLOOR_TOP, 0)
	local function at(x: number, y: number, z: number): CFrame
		return floor * CFrame.new(x, y, z)
	end

	local base = part({
		Name = "Base",
		Size = Vector3.new(PLOT_WIDTH, 1, PLOT_DEPTH),
		CFrame = at(0, -0.5, 0),
		Color = Color3.fromRGB(222, 210, 188),
		Material = Enum.Material.Concrete,
	})
	base.Parent = plot
	plot.PrimaryPart = base

	-- ทางเดินหน้าร้าน + แนวพุ่มไม้ข้างฐาน
	part({
		Name = "FrontWalk",
		Size = Vector3.new(PLOT_WIDTH, 0.1, 14),
		CFrame = at(0, 0.05, -PLOT_DEPTH / 2 + 7),
		Color = Color3.fromRGB(150, 140, 130),
		Material = Enum.Material.Pavement,
		CanCollide = false,
	}).Parent = plot
	for _, x in { -PLOT_WIDTH / 2 + 0.6, PLOT_WIDTH / 2 - 0.6 } do
		part({
			Name = "Hedge",
			Size = Vector3.new(1.2, 1.6, 66),
			CFrame = at(x, 0.8, -3),
			Color = Color3.fromRGB(70, 140, 60),
			Material = Enum.Material.Grass,
		}).Parent = plot
	end

	-- แผ่นซื้อของด้านหน้า
	local pads = Instance.new("Folder")
	pads.Name = "PadSlots"
	pads.Parent = plot
	for i = 1, Config.PAD_COUNT do
		part({
			Name = "Pad" .. i,
			Size = Vector3.new(9, 0.6, 9),
			CFrame = at((i - 2) * 14, 0.3, -42),
			Color = Color3.fromRGB(46, 204, 113),
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
		}).Parent = pads
	end

	local register = part({
		Name = "Register",
		Size = Vector3.new(7, 0.6, 7),
		CFrame = at(25, 0.3, -42),
		Color = Color3.fromRGB(255, 196, 0),
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	billboard(register, "ตู้เก็บเงิน", 3)
	register.Parent = plot

	-- ป้ายชื่อเจ้าของร้าน (มุมหน้าซ้าย)
	part({
		Name = "SignPost",
		Size = Vector3.new(1, 8, 1),
		CFrame = at(-33, 4, -46),
		Color = Color3.fromRGB(90, 45, 15),
		Material = Enum.Material.Wood,
	}).Parent = plot
	local sign = part({
		Name = "Sign",
		Size = Vector3.new(13, 4, 0.8),
		CFrame = at(-33, 9, -46),
		Color = Color3.fromRGB(120, 60, 20),
		Material = Enum.Material.Wood,
	})
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 25
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

	-- ของ 44 ชิ้น
	local items = Instance.new("Folder")
	items.Name = "Items"
	items.Parent = plot
	for level = 2, Config.MAX_LEVEL do
		local key = Config.Items[level].Key
		local spot = ItemModels.PlaceIn(key, floor)
		local model = spot and ItemModels.Build(key, spot)
		if model then
			model.Parent = items
		else
			warn("[DevPlotBuilder] ไม่มีโมเดลสำหรับ " .. key)
		end
	end

	return plot
end

-- สร้าง Workspace.Plots พร้อมจุดเกิดกลางลาน
function DevPlotBuilder.Build(): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Plots"

	local perRow = math.ceil(Config.PLOT_COUNT / 2)
	local rowOffset = PLAZA_HALF + PLOT_DEPTH / 2
	for i = 1, Config.PLOT_COUNT do
		local topRow = i <= perRow
		local column = (i - 1) % perRow
		local x = (column - (perRow - 1) / 2) * COLUMN_GAP
		local z = if topRow then rowOffset else -rowOffset
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
	print("[DevPlotBuilder] สร้างฐาน " .. Config.PLOT_COUNT .. " ฐานพร้อมโมเดลของครบ")
	return folder
end

return DevPlotBuilder
