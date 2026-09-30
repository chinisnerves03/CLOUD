-- DevPlotBuilder: builds 6 plots with all 44 item models (from ItemModels) plus plot and plaza decor
-- The structure matches what PlotService expects:
--   Workspace.Plots.PlotN { Base, Items{L02..L45}, PadSlots{Pad1}, Upgrades{Staff,Recipe,Speed}, BrewStation{Kettle}, Sign{SurfaceGui.TextLabel} }

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local ItemModels = require(script.Parent:WaitForChild("ItemModels"))

local DevPlotBuilder = {}

-- plot space (ItemModels): x across, z from the front edge (facing the plaza, -Z) to the back
local PLOT_WIDTH = ItemModels.PlotWidth -- X axis
local FRONT = ItemModels.PlotFront -- front edge of the plot
local SIGN_X = -40.5 -- owner sign, left of the (scaled) entrance arch post
local BACK = ItemModels.PlotBack
local PLOT_DEPTH = BACK - FRONT -- Z axis
local CENTER_Z = ItemModels.PlotCenterZ -- where the Base part is centred
local PLAZA_HALF = 20 -- half the plaza width
local COLUMN_GAP = PLOT_WIDTH + 10 -- distance between plot centers along X
local FLOOR_TOP = 1 -- height of the plot floor surface

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
		CFrame = at(0, -0.5, CENTER_Z),
		Color = Color3.fromRGB(222, 210, 188),
		Material = Enum.Material.Concrete,
	})
	-- PlotService places items relative to the Base centre moved by this much along Z
	base:SetAttribute("ItemOriginZ", -CENTER_Z)
	base.Parent = plot
	plot.PrimaryPart = base

	-- front walkway + side hedges + path lamps
	part({
		Name = "FrontWalk",
		Size = Vector3.new(PLOT_WIDTH, 0.1, 14),
		CFrame = at(0, 0.05, FRONT + 7),
		Color = Color3.fromRGB(150, 140, 130),
		Material = Enum.Material.Pavement,
		CanCollide = false,
	}).Parent = plot
	for _, x in { -PLOT_WIDTH / 2 + 0.6, PLOT_WIDTH / 2 - 0.6 } do
		part({
			Name = "Hedge",
			Size = Vector3.new(1.2, 1.6, BACK - FRONT - 16),
			CFrame = at(x, 0.8, (FRONT + 15 + BACK - 1) / 2),
			Color = Color3.fromRGB(70, 140, 60),
			Material = Enum.Material.Grass,
		}).Parent = plot
	end

	local decor = Instance.new("Folder")
	decor.Name = "Decor"
	decor.Parent = plot
	local ground = ItemModels.BuildDecor("PlotGround", floor)
	if ground then
		ground.Parent = decor
	end
	for _, side in { -1, 1 } do
		for _, z in { -45, -25, -5, 30, 70, 110 } do
			-- lamp heads face the middle of the plot
			local lamp = ItemModels.BuildDecor("Lamp", at(side * (PLOT_WIDTH / 2 - 2.2), 0, z) * CFrame.Angles(0, side * math.pi / 2, 0))
			if lamp then
				lamp.Parent = decor
			end
		end
	end
	for _, spot in { { -44, FRONT + 4, "Bench" }, { 44, FRONT + 4, "Bench" }, { -36, FRONT + 4, "Bin" }, { 40, FRONT + 4, "Bin" } } do
		local model = ItemModels.BuildDecor(spot[3], at(spot[1], 0, spot[2]))
		if model then
			model.Parent = decor
		end
	end

	-- the single buy pad (PlotService moves it to ItemModels.PadSpots for the next item)
	local pads = Instance.new("Folder")
	pads.Name = "PadSlots"
	pads.Parent = plot
	for i = 1, Config.PAD_COUNT do
		part({
			Name = "Pad" .. i,
			Size = Vector3.new(6, 0.5, 6),
			CFrame = at(-20, 0.25, -48),
			Color = Color3.fromRGB(46, 204, 113),
			Material = Enum.Material.Neon,
			CanCollide = false,
		}).Parent = pads
	end

	-- upgrade pads next to the Brew Station (repeatable: Hire Staff, Better Recipe, Faster Service)
	local upgrades = Instance.new("Folder")
	upgrades.Name = "Upgrades"
	upgrades.Parent = plot
	local upgradeColors = {
		Staff = Color3.fromRGB(60, 140, 230),
		Recipe = Color3.fromRGB(240, 150, 40),
		Speed = Color3.fromRGB(170, 90, 220),
	}
	for i, key in Config.UPGRADE_ORDER do
		local spot = ItemModels.UpgradeSpots[key]
		local frame = ItemModels.BuildDecor("UpgradeFrame", at(spot[1], 0, spot[2]), i)
		if frame then
			frame.Parent = decor
		end
		part({
			Name = key,
			Size = Vector3.new(6, 0.5, 6),
			CFrame = at(spot[1], 0.25, spot[2]),
			Color = upgradeColors[key],
			Material = Enum.Material.Neon,
			CanCollide = false,
		}).Parent = upgrades
	end

	-- Brew Station: players brew tea here by hand (PlotService adds the prompt to its Kettle part)
	local brew = ItemModels.BuildDecor("BrewStation", at(0, 0, FRONT + 10))
	if brew then
		brew.Name = "BrewStation"
		brew.Parent = plot
	end

	for _, spec in { { "SignLamps", at(SIGN_X, 9, FRONT + 4) }, { "Arch", at(0, 0, FRONT + 1) } } do
		local model = ItemModels.BuildDecor(spec[1], spec[2])
		if model then
			model.Parent = decor
		end
	end

	-- owner name sign (front corner)
	part({
		Name = "SignPost",
		Size = Vector3.new(1, 8, 1),
		CFrame = at(SIGN_X, 4, FRONT + 4),
		Color = Color3.fromRGB(90, 45, 15),
		Material = Enum.Material.Wood,
	}).Parent = plot
	local sign = part({
		Name = "Sign",
		Size = Vector3.new(13, 4, 0.8),
		CFrame = at(SIGN_X, 9, FRONT + 4),
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
	text.Text = "Empty Plot"
	text.Parent = surface
	surface.Parent = sign
	sign.Parent = plot

	-- the 44 items
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
			warn("[DevPlotBuilder] No model for " .. key)
		end
	end

	return plot
end

-- build Workspace.Plots plus a plaza spawn
function DevPlotBuilder.Build(): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Plots"

	local perRow = math.ceil(Config.PLOT_COUNT / 2)
	local rowOffset = PLAZA_HALF - FRONT -- plot space origin, so the front edge meets the plaza
	for i = 1, Config.PLOT_COUNT do
		local topRow = i <= perRow
		local column = (i - 1) % perRow
		local x = (column - (perRow - 1) / 2) * COLUMN_GAP
		local z = if topRow then rowOffset else -rowOffset
		-- plot space front (local -Z) must face the plaza: rotate the bottom row 180°
		local origin = CFrame.new(x, 0, z) * CFrame.Angles(0, if topRow then 0 else math.pi, 0)
		buildPlot(i, origin).Parent = folder
	end

	-- plaza: fountains between plots, trees, benches, lamps
	local plaza = Instance.new("Folder")
	plaza.Name = "PlazaDecor"
	local function place(kind: string, cf: CFrame)
		local model = ItemModels.BuildDecor(kind, cf)
		if model then
			model.Parent = plaza
		end
	end
	for _, x in { -COLUMN_GAP / 2, COLUMN_GAP / 2 } do
		place("Fountain", CFrame.new(x, 0, 0))
		-- benches face the fountain
		place("Bench", CFrame.new(x, 0, -10) * CFrame.Angles(0, math.pi, 0))
		place("Bench", CFrame.new(x, 0, 10))
	end
	for _, x in { -COLUMN_GAP - 30, -COLUMN_GAP + 30, -35, 35, COLUMN_GAP - 30, COLUMN_GAP + 30 } do
		for _, z in { -14, 14 } do
			place("Tree", CFrame.new(x, 0, z))
		end
	end
	for _, x in { -COLUMN_GAP, 0, COLUMN_GAP } do
		for _, z in { -16, 16 } do
			place("Lamp", CFrame.new(x + 12, 0, z) * CFrame.Angles(0, if z < 0 then math.pi else 0, 0))
			place("Lamp", CFrame.new(x - 12, 0, z) * CFrame.Angles(0, if z < 0 then math.pi else 0, 0))
		end
	end
	plaza.Parent = workspace

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
	print("[DevPlotBuilder] Built " .. Config.PLOT_COUNT .. " plots with all item models")
	return folder
end

return DevPlotBuilder
