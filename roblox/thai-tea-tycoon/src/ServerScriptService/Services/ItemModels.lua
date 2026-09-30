-- ItemModels: all 44 purchasable item models (L02..L45) built purely from Parts — no model files needed
-- Used by DevPlotBuilder: ItemModels.Build(key, origin) returns a Model already placed at origin
-- Plot placement lives in ItemModels.Layout (plot space: front = -Z facing the plaza, y = 0 is the floor)

local ItemModels = {}

local V3 = Vector3.new
local CF = CFrame.new
local ANG = CFrame.Angles
local rgb = Color3.fromRGB
local rad = math.rad
local M = Enum.Material
local FACE = Enum.NormalId

local PAL = {
	tea = rgb(232, 119, 46),
	teaDark = rgb(170, 80, 30),
	milk = rgb(250, 238, 215),
	cream = rgb(245, 228, 196),
	wood = rgb(164, 116, 73),
	woodDark = rgb(105, 64, 38),
	woodLight = rgb(212, 170, 120),
	steel = rgb(200, 204, 210),
	steelDark = rgb(105, 110, 118),
	black = rgb(35, 35, 38),
	white = rgb(246, 246, 244),
	green = rgb(34, 139, 94),
	greenDark = rgb(22, 92, 62),
	leaf = rgb(84, 160, 70),
	leafDark = rgb(55, 120, 50),
	red = rgb(205, 55, 50),
	blue = rgb(60, 120, 200),
	glass = rgb(175, 215, 235),
	gold = rgb(235, 185, 50),
	pink = rgb(240, 150, 175),
	yellow = rgb(250, 205, 60),
	skin = rgb(234, 190, 150),
	hair = rgb(45, 32, 25),
	pearl = rgb(58, 38, 30),
	concrete = rgb(214, 210, 202),
	warm = rgb(255, 214, 140),
}
ItemModels.Palette = PAL

---------------------------------------------------------------------------
-- Part-building helpers (every position is relative to the model origin)
---------------------------------------------------------------------------
local Builder = {}
Builder.__index = Builder

local function newBuilder(model: Model, origin: CFrame)
	return setmetatable({ Model = model, Origin = origin, Count = 0, Round = true }, Builder)
end

-- opts: t = transparency, solid = force collision on/off, name = part name, refl = reflectance
function Builder:_part(class: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, opts)
	local p = Instance.new(class) :: any
	p.Anchored = true
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = size
	p.CFrame = self.Origin * cf
	p.Color = color
	p.Material = material or M.SmoothPlastic
	local solid = size.X >= 1 and size.Y >= 1 and size.Z >= 1
	if self.InShell then
		p:SetAttribute("Structure", true) -- ItemModels.Stretch scales these with the building
	end
	if opts then
		if opts.t then
			p.Transparency = opts.t
		end
		if opts.refl then
			p.Reflectance = opts.refl
		end
		if opts.solid ~= nil then
			solid = opts.solid
		end
		if opts.name then
			p.Name = opts.name
		end
	end
	p.CanCollide = solid
	if math.max(size.X, size.Y, size.Z) < 1.5 then
		p.CastShadow = false
	end
	if not solid then
		p.CanQuery = false
	end
	if not self.Model.PrimaryPart then
		self.Model.PrimaryPart = p
	end
	p.Parent = self.Model
	self.Count += 1
	return p
end

-- Furniture-sized opaque boxes get rounded vertical edges (two crossed boxes + four corner cylinders)
-- so the shop looks softer than plain blocks. Pass opts.flat = true to keep a sharp box.
local function shouldRound(size: Vector3, opts): boolean
	if opts and (opts.flat or (opts.t and opts.t > 0)) then
		return false
	end
	return math.min(size.X, size.Z) >= 1.2 and size.Y >= 0.6 and math.max(size.X, size.Y, size.Z) <= 20
end

function Builder:Box(size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, opts): Part
	if not (self.Round and shouldRound(size, opts)) then
		return self:_part("Part", size, cf, color, material, opts)
	end
	local r = math.min(0.6, math.min(size.X, size.Z) * 0.2)
	-- the returned part spans the full depth, so Front/Back text and lights attach to it
	local main = self:_part("Part", V3(size.X - 2 * r, size.Y, size.Z), cf, color, material, opts)
	local sideOpts = { solid = opts and opts.solid }
	self:_part("Part", V3(size.X, size.Y, size.Z - 2 * r), cf, color, material, sideOpts)
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			local corner = self:_part("Part", V3(size.Y, 2 * r, 2 * r),
				cf * CF(sx * (size.X / 2 - r), 0, sz * (size.Z / 2 - r)) * ANG(0, 0, rad(90)), color, material, { solid = false })
			corner.Shape = Enum.PartType.Cylinder
		end
	end
	return main
end

-- upright cylinder (height h, diameter d)
function Builder:Cyl(h: number, d: number, cf: CFrame, color: Color3, material: Enum.Material?, opts): Part
	local p = self:_part("Part", V3(h, d, d), cf * ANG(0, 0, rad(90)), color, material, opts)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- lying cylinder along the X axis of cf
function Builder:HCyl(len: number, d: number, cf: CFrame, color: Color3, material: Enum.Material?, opts): Part
	local p = self:_part("Part", V3(len, d, d), cf, color, material, opts)
	p.Shape = Enum.PartType.Cylinder
	return p
end

function Builder:Ball(d: number, cf: CFrame, color: Color3, material: Enum.Material?, opts): Part
	local p = self:_part("Part", V3(d, d, d), cf, color, material, opts)
	p.Shape = Enum.PartType.Ball
	return p
end

-- ellipsoid (stretch any axis) via a sphere SpecialMesh
function Builder:Ellipsoid(size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, opts): Part
	opts = opts or {}
	if opts.solid == nil then
		opts.solid = false
	end
	local p = self:_part("Part", size, cf, color, material, opts)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

-- wedge: tall side at the back (+Z), sloping down toward the front (-Z)
function Builder:Wedge(size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, opts): WedgePart
	return self:_part("WedgePart", size, cf, color, material, opts)
end

-- square rod from point a to point b
function Builder:Rod(a: Vector3, b: Vector3, thick: number, color: Color3, material: Enum.Material?, opts): Part
	local length = (b - a).Magnitude
	opts = opts or {}
	if opts.solid == nil then
		opts.solid = false
	end
	return self:_part("Part", V3(thick, thick, length), CFrame.lookAt((a + b) / 2, b), color, material, opts)
end

-- round tube from point a to point b
function Builder:Tube(a: Vector3, b: Vector3, d: number, color: Color3, material: Enum.Material?, opts): Part
	local length = (b - a).Magnitude
	opts = opts or {}
	if opts.solid == nil then
		opts.solid = false
	end
	return self:HCyl(length, d, CFrame.lookAt((a + b) / 2, b) * ANG(0, rad(90), 0), color, material, opts)
end

-- text on a part face (opts: color, bg, bgT, glow, font, region = {x, y, w, h} as fractions, ppu)
function Builder:Text(part: BasePart, face: Enum.NormalId, text: string, opts)
	opts = opts or {}
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = opts.ppu or 40
	if opts.glow then
		gui.LightInfluence = 0
		gui.Brightness = 1.5
	end
	local label = Instance.new("TextLabel")
	local region = opts.region or { 0, 0, 1, 1 }
	label.Position = UDim2.fromScale(region[1], region[2])
	label.Size = UDim2.fromScale(region[3], region[4])
	label.BackgroundColor3 = opts.bg or PAL.black
	label.BackgroundTransparency = opts.bgT or 1
	label.BorderSizePixel = 0
	label.Font = opts.font or Enum.Font.GothamBlack
	label.Text = text
	label.TextColor3 = opts.color or PAL.white
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
	gui.Parent = part
	return label
end

function Builder:Light(part: BasePart, color: Color3, range: number, brightness: number?)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range
	light.Brightness = brightness or 1
	light.Shadows = false
	light.Parent = part
	return light
end

-- person, ~5.5 studs tall, facing -Z: rounded shoes, belt, collar, apron with straps and pocket,
-- sleeves + forearms + hands, and a face with ears, nose, eyes (white, pupil, shine), brows, cheeks and a smile
-- style: shirt, pants, apron (same color as the shirt = no apron, e.g. customers), cap, chefHat, ngob, hair,
--        long (ponytail), skin, left/right = {pitch, yaw} (degrees: pitch > 0 raises the arm forward, yaw swings it inward)
-- returns hand positions (model space) for placing held objects
function Builder:Person(cf: CFrame, style)
	style = style or {}
	local skin = style.skin or PAL.skin
	local shirt = style.shirt or PAL.white
	local pants = style.pants or PAL.black
	local apron = style.apron or PAL.tea
	local hair = style.hair or PAL.hair
	local hasApron = apron ~= shirt
	local ghost = { solid = false }

	-- legs, shoes (rounded toe + sole), belt with buckle
	for _, x in { -0.5, 0.5 } do
		self:Box(V3(0.9, 2, 0.9), cf * CF(x, 1, 0), pants, nil, ghost)
		self:Box(V3(0.95, 0.12, 1.25), cf * CF(x, 0.06, -0.12), PAL.white, nil, ghost)
		self:Ellipsoid(V3(0.95, 0.5, 1.3), cf * CF(x, 0.3, -0.14), PAL.black)
	end
	self:Box(V3(2.04, 0.22, 1.04), cf * CF(0, 2.1, 0), PAL.black, nil, ghost)
	self:Box(V3(0.3, 0.2, 0.05), cf * CF(0, 2.1, -0.53), PAL.gold, M.Metal, ghost)

	-- torso with rounded shoulders, neck and collar
	self:Box(V3(2, 2, 1), cf * CF(0, 3.1, 0), shirt)
	for _, x in { -0.8, 0.8 } do
		self:Ellipsoid(V3(0.7, 0.55, 1.0), cf * CF(x, 4.0, 0), shirt)
	end
	self:Cyl(0.35, 0.62, cf * CF(0, 4.15, 0), skin, nil, ghost)
	for _, x in { -1, 1 } do
		self:Box(V3(0.42, 0.28, 0.06), cf * CF(x * 0.22, 3.98, -0.52) * ANG(0, 0, rad(x * 28)), if hasApron then PAL.white else shirt, nil, ghost)
	end
	if hasApron then
		-- apron: bib + skirt, neck straps, waist tie, pocket with pens, little tea-leaf logo
		self:Box(V3(1.3, 1.1, 0.08), cf * CF(0, 3.25, -0.54), apron, M.Fabric, ghost)
		self:Box(V3(1.8, 1.6, 0.08), cf * CF(0, 1.95, -0.56), apron, M.Fabric, ghost)
		for _, x in { -1, 1 } do
			self:Rod(V3(x * 0.58, 3.8, -0.55), V3(x * 0.35, 4.08, -0.2), 0.1, apron, M.Fabric)
		end
		self:Box(V3(2.06, 0.12, 1.06), cf * CF(0, 2.45, 0), apron, M.Fabric, ghost)
		self:Box(V3(0.8, 0.45, 0.04), cf * CF(0, 1.75, -0.61), apron:Lerp(PAL.black, 0.2), M.Fabric, ghost)
		self:Box(V3(0.06, 0.3, 0.04), cf * CF(-0.2, 2.02, -0.62), PAL.blue, nil, ghost)
		self:Ellipsoid(V3(0.35, 0.22, 0.05), cf * CF(0, 3.35, -0.59) * ANG(0, 0, rad(30)), PAL.white)
	end
	self:Box(V3(0.4, 0.14, 0.04), cf * CF(0.55, 3.72, if hasApron then -0.6 else -0.52), PAL.gold, M.Metal, ghost)

	-- arms: sleeve, cuff, forearm, hand
	local hands = {}
	for side, key in { [-1] = "left", [1] = "right" } do
		local pose = style[key] or { 25, 0 }
		-- positive yaw swings toward the body center on both sides
		local shoulder = cf * CF(side * 1.4, 3.85, 0) * ANG(0, rad((pose[2] or 0) * side), 0) * ANG(rad(pose[1]), 0, 0)
		self:Box(V3(0.82, 1.0, 0.82), shoulder * CF(0, -0.45, 0), shirt, nil, ghost)
		self:Box(V3(0.86, 0.14, 0.86), shoulder * CF(0, -0.95, 0), if hasApron then PAL.white else shirt:Lerp(PAL.black, 0.15), nil, ghost)
		self:Box(V3(0.64, 0.95, 0.64), shoulder * CF(0, -1.45, 0), skin, nil, ghost)
		self:Ellipsoid(V3(0.66, 0.6, 0.62), shoulder * CF(0, -2.05, 0), skin)
		hands[key] = (shoulder * CF(0, -2.2, 0)).Position
	end

	-- head and face
	local head = cf * CF(0, 4.8, 0)
	self:Ball(1.35, head, skin, nil, ghost)
	for _, x in { -1, 1 } do
		self:Ellipsoid(V3(0.18, 0.36, 0.3), head * CF(x * 0.67, -0.02, 0.02), skin)
		self:Ellipsoid(V3(0.26, 0.3, 0.08), head * CF(x * 0.26, 0.08, -0.6), PAL.white)
		self:Ellipsoid(V3(0.16, 0.21, 0.06), head * CF(x * 0.25, 0.07, -0.635), PAL.black)
		self:Ball(0.06, head * CF(x * 0.23, 0.12, -0.665), PAL.white, M.Neon, ghost)
		self:Box(V3(0.3, 0.07, 0.05), head * CF(x * 0.27, 0.31, -0.56) * ANG(0, 0, rad(-x * 8)), hair, nil, ghost)
		self:Ellipsoid(V3(0.22, 0.13, 0.05), head * CF(x * 0.38, -0.17, -0.53), rgb(240, 150, 150), nil, { t = 0.35 })
		self:Rod((head * CF(x * 0.17, -0.3, -0.585)).Position, (head * CF(0, -0.37, -0.6)).Position, 0.06, rgb(150, 70, 60))
	end
	self:Ellipsoid(V3(0.16, 0.2, 0.14), head * CF(0, -0.07, -0.66), skin:Lerp(PAL.black, 0.04))
	-- hair: crown, back, fringe (optional ponytail)
	self:Ellipsoid(V3(1.45, 0.85, 1.45), head * CF(0, 0.33, 0.1), hair)
	self:Ellipsoid(V3(1.42, 1.0, 0.8), head * CF(0, 0.05, 0.36), hair)
	self:Ellipsoid(V3(1.15, 0.32, 0.5), head * CF(0.12, 0.45, -0.42) * ANG(0, 0, rad(-8)), hair)
	if style.long then
		self:Ellipsoid(V3(0.55, 1.2, 0.55), head * CF(0, -0.25, 0.85) * ANG(rad(20), 0, 0), hair)
	end

	if style.cap then
		self:Cyl(0.4, 1.45, head * CF(0, 0.5, 0.05), style.cap)
		self:Box(V3(1.1, 0.1, 0.7), head * CF(0, 0.35, -0.75), style.cap, nil, ghost)
		self:Ellipsoid(V3(0.4, 0.25, 0.05), head * CF(0, 0.52, -0.68), PAL.white)
		self:Ball(0.2, head * CF(0, 0.72, 0.05), style.cap, nil, ghost)
	elseif style.chefHat then
		self:Cyl(0.8, 1.3, head * CF(0, 0.75, 0.05), PAL.white)
		self:Ellipsoid(V3(1.6, 0.7, 1.6), head * CF(0, 1.2, 0.05), PAL.white)
	elseif style.ngob then -- farmer's straw hat
		self:Ellipsoid(V3(2.4, 0.5, 2.4), head * CF(0, 0.55, 0.05), rgb(215, 185, 120))
		self:Ellipsoid(V3(1.1, 0.6, 1.1), head * CF(0, 0.8, 0.05), rgb(200, 165, 100))
	end
	return hands
end

-- Thai tea cup (bottom of the cup at cf)
function Builder:TeaCup(cf: CFrame, scale: number?, drink: Color3?)
	local s = scale or 1
	self:Cyl(0.9 * s, 0.45 * s, cf * CF(0, 0.45 * s, 0), drink or PAL.tea)
	self:Cyl(0.15 * s, 0.47 * s, cf * CF(0, 0.95 * s, 0), PAL.milk)
	self:Ellipsoid(V3(0.47, 0.25, 0.47) * s, cf * CF(0, 1.05 * s, 0), PAL.white, M.Glass, { t = 0.4 })
	self:Cyl(0.14 * s, 0.47 * s, cf * CF(0, 0.5 * s, 0), PAL.cream, nil, { solid = false })
	self:Rod(V3(0, 1.0 * s, 0), V3(0.12 * s, 1.75 * s, 0.05 * s), 0.08 * s, PAL.green)
end

-- potted plant
function Builder:Plant(cf: CFrame, height: number?)
	local h = height or 2
	self:Cyl(1.1, 1.1, cf * CF(0, 0.55, 0), rgb(190, 100, 60))
	self:Cyl(0.1, 0.95, cf * CF(0, 1.1, 0), rgb(80, 55, 35))
	self:Ellipsoid(V3(1.5, h, 1.5), cf * CF(0, 1.1 + h / 2, 0), PAL.leaf)
	self:Ellipsoid(V3(1.0, h * 0.7, 1.0), cf * CF(0.3, 1.3 + h * 0.6, -0.2), PAL.leafDark)
end

-- 4 table/cabinet legs
function Builder:Legs(width: number, depth: number, height: number, thick: number, cf: CFrame, color: Color3)
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			self:Box(V3(thick, height, thick), cf * CF(x * width / 2, height / 2, z * depth / 2), color, M.Metal, { solid = false })
		end
	end
end

-- walk-in hollow building: floor + 4 walls (with door/window openings) + flat roof
-- spec: w, d, h, t (wall thickness), wall, wallMat, wallT, floor, floorMat, roof (false = none), roofColor
--       openings = { { side = "Front"|"Back"|"Left"|"Right", x = center along the wall, y = bottom edge, w, h, glass = true/false } }
-- walkable doors: glass = false, y = 0, h >= 7
function Builder:Shell(cf: CFrame, spec)
	self.InShell = true
	self:_Shell(cf, spec)
	self.InShell = false
end

function Builder:_Shell(cf: CFrame, spec)
	local w, d, h = spec.w, spec.d, spec.h
	local t = spec.t or 0.6
	local wallOpts = { t = spec.wallT, solid = true, flat = true }
	self:Box(V3(w - 2 * t, 0.2, d - 2 * t), cf * CF(0, 0.1, 0), spec.floor or PAL.concrete, spec.floorMat or M.Concrete, { solid = true, flat = true })

	local sides = {
		Front = { length = w, place = function(u, y, len, hgt) return V3(len, hgt, t), CF(u, y, -d / 2 + t / 2) end },
		Back = { length = w, place = function(u, y, len, hgt) return V3(len, hgt, t), CF(u, y, d / 2 - t / 2) end },
		Left = { length = d - 2 * t, place = function(u, y, len, hgt) return V3(t, hgt, len), CF(-w / 2 + t / 2, y, u) end },
		Right = { length = d - 2 * t, place = function(u, y, len, hgt) return V3(t, hgt, len), CF(w / 2 - t / 2, y, u) end },
	}
	for sideName, side in sides do
		local openings = {}
		for _, o in spec.openings or {} do
			if o.side == sideName then
				table.insert(openings, o)
			end
		end
		table.sort(openings, function(a, b)
			return a.x < b.x
		end)
		local function piece(u0: number, u1: number, y0: number, y1: number)
			if u1 - u0 > 0.01 and y1 - y0 > 0.01 then
				local size, at = side.place((u0 + u1) / 2, (y0 + y1) / 2, u1 - u0, y1 - y0)
				self:Box(size, cf * at, spec.wall, spec.wallMat, wallOpts)
			end
		end
		local cursor = -side.length / 2
		for _, o in openings do
			local a, b = o.x - o.w / 2, o.x + o.w / 2
			piece(cursor, a, 0, h)
			piece(a, b, 0, o.y)
			piece(a, b, o.y + o.h, h)
			if o.glass then
				local size, at = side.place(o.x, o.y + o.h / 2, o.w, o.h)
				local pane = if sideName == "Front" or sideName == "Back" then V3(size.X, size.Y, 0.15) else V3(0.15, size.Y, size.Z)
				self:Box(pane, cf * at, PAL.glass, M.Glass, { t = 0.45, solid = true })
			end
			cursor = b
		end
		piece(cursor, side.length / 2, 0, h)
	end

	if spec.roof ~= false then
		self:Box(V3(w, 0.6, d), cf * CF(0, h + 0.3, 0), spec.roofColor or spec.wall, spec.wallMat, { flat = true })
	end
end

-- wall shelf along the X axis of cf; fill(level, shelfTopY) places the goods
function Builder:Shelf(cf: CFrame, length: number, depth: number, levels: { number }, color: Color3, fill)
	local height = levels[#levels] + 1.2
	for _, x in { -length / 2, length / 2 } do
		self:Box(V3(0.25, height, depth), cf * CF(x, height / 2, 0), color, M.Metal)
	end
	for level, y in levels do
		self:Box(V3(length, 0.15, depth), cf * CF(0, y, 0), color, M.Metal, { solid = true })
		if fill then
			fill(level, y + 0.08)
		end
	end
end

-- a row of upper-floor windows on the outside of a Shell (frame, glass pane, sill). sides = { "Front", "Left", … },
-- us = window centres along each wall, y = bottom edge, h = height. Purely decorative (no openings).
function Builder:UpperWindows(cf: CFrame, w: number, d: number, sides: { string }, us: { number }, y: number, h: number, glass: Color3?)
	local pane = glass or rgb(70, 120, 165)
	for _, side in sides do
		for _, u in us do
			local at, size
			if side == "Front" or side == "Back" then
				local z = if side == "Front" then -d / 2 else d / 2
				at, size = function(out: number) return cf * CF(u, 0, z + (if side == "Front" then -out else out)) end, function(a: number, b: number) return V3(a, b, 0.12) end
			else
				local x = if side == "Left" then -w / 2 else w / 2
				at, size = function(out: number) return cf * CF(x + (if side == "Left" then -out else out), 0, u) end, function(a: number, b: number) return V3(0.12, b, a) end
			end
			self:Box(size(2.6, h + 0.4), at(0.05) * CF(0, y + h / 2, 0), PAL.white, nil, { solid = false, flat = true })
			self:Box(size(2.2, h), at(0.12) * CF(0, y + h / 2, 0), pane, M.Glass, { solid = false, flat = true, refl = 0.25 })
			self:Box(size(2.8, 0.2), at(0.2) * CF(0, y - 0.15, 0), PAL.concrete, nil, { solid = false, flat = true })
		end
	end
end

-- deterministic random (every plot looks the same)
local function seeded(seed: number)
	local state = seed
	return function(): number
		state = (state * 1103515245 + 12345) % 2147483648
		return state / 2147483648
	end
end

---------------------------------------------------------------------------
-- item placement in the plot { x, y, z, rotation around Y (degrees) }
-- plot space: 120 wide (x -60..60), z from -65 (front, facing the plaza) to 140 (back).
-- The plot's Base part is centred at z = ItemModels.PlotCenterZ in this space.
---------------------------------------------------------------------------
ItemModels.Layout = {
	-- Tier 1: Thai tea cart (front left)
	L02 = { -20, 0, -41, 0 },
	L03 = { -25.4, 0, -41, 0 },
	L04 = { -14.2, 0, -40.5, 0 },
	L05 = { -13.8, 0, -35.5, 0 },
	L06 = { -18.4, 3, -41, 0 },
	L07 = { -20, 0, -38.4, 0 },
	L08 = { -27, 0, -46.5, 0 },
	L09 = { -21.6, 3, -41, 0 },
	L10 = { -31.5, 0, -37, 0 },
	-- Tier 2: street shop (front right)
	L11 = { 20, 0, -37, 0 },
	L12 = { 24.8, 3.5, -36.6, 0 },
	L13 = { 19.5, 3.5, -37, 0 },
	L14 = { 23.5, 0, -32.2, 0 },
	L15 = { 20, 0, -41.8, 0 },
	L16 = { 32.5, 0, -45, 0 },
	L17 = { 22, 0, -39, 0 },
	L18 = { 14.2, 3.5, -37, 0 },
	L19 = { 17.5, 0, -33.6, 0 },
	-- Tier 3: cafe (middle)
	L20 = { -31, 0, -19, 0 },
	L21 = { -19, 0, -6, 0 },
	L22 = { -23.5, 0, -19, 0 },
	L23 = { 16.5, 0, -16, 0 },
	L24 = { 31, 0, -9, 0 },
	L25 = { -37.2, 0, -8, 0 },
	L26 = { -29.5, 0, -4.5, 0 },
	L27 = { 0, 0, -13, 0 },
	L28 = { 0, 0, -3.5, 0 },
	-- Tier 4: central kitchen + logistics (walk-in buildings)
	L29 = { -42, 0, 21, 0 },
	L30 = { -20, 0, 18, 0 },
	L31 = { -2, 0, 9, 0 },
	L32 = { 17, 0, 17, 0 },
	L33 = { 35, 0, -59, 0 },
	L34 = { 46, 0, 21, 0 },
	L35 = { -2, 0, 24, 0 },
	L36 = { 0, 0, -9.7, 0 },
	L37 = { 33.5, 0, -21, 0 },
	-- Tier 5: Thai tea empire (two back rows, walk-in buildings)
	L38 = { -44, 0, 70, 0 },
	L39 = { -16, 0, 64, 0 },
	L40 = { 8, 0, 66, 0 },
	L41 = { -18, 0, 108, 0 },
	L42 = { 45, 0, 64, 0 },
	L43 = { 44, 0, 104, 0 },
	L44 = { 26, 0, 54, 0 },
	L45 = { 10, 0, 112, 0 },
}

ItemModels.PlotWidth = 120
ItemModels.PlotFront = -65
ItemModels.PlotBack = 140
ItemModels.PlotCenterZ = (ItemModels.PlotFront + ItemModels.PlotBack) / 2

-- Fixed spots in plot space { x, z }: the three upgrade pads, hired staff carts and the VIP barista
ItemModels.UpgradeSpots = { Staff = { -30, -56 }, Recipe = { -21, -56 }, Speed = { -12, -56 } }
ItemModels.StaffSpots = { { 8, -55 }, { 12.5, -55 }, { 17, -55 }, { 21.5, -55 }, { 26, -55 }, { 30.5, -55 } }
ItemModels.VipSpot = { -6.5, -55 }

-- Where the single buy pad sits while that item is the next purchase { x, z } in plot space.
-- Each spot is behind where the item will appear (the side away from the plaza), on open floor clear of
-- every earlier item, the Brew Station, the upgrade pads and the staff carts (tier 4-5 spots were computed in
-- Studio from the real bounding boxes: the closest free 6x6 spot behind the item, 1 stud clear of everything).
ItemModels.PadSpots = {
	L02 = { -20, -34.4 }, L03 = { -25, -36.5 }, L04 = { -14.1, -35.8 }, L05 = { -13.8, -31.2 }, L06 = { -24.4, -36.6 },
	L07 = { -20, -34.2 }, L08 = { -30.6, -42.1 }, L09 = { -27.6, -36.9 }, L10 = { -31.5, -32.3 }, L11 = { 20, -31.9 },
	L12 = { 25.1, -32 }, L13 = { 31.5, -32.7 }, L14 = { 23.5, -27.4 }, L15 = { 32, -37.5 }, L16 = { 32.5, -38.3 },
	L17 = { 22, -25.3 }, L18 = { 8.1, -32.7 }, L19 = { 17.5, -29 }, L20 = { -30.7, -13.2 }, L21 = { -18.3, -2.2 },
	L22 = { -23.5, -14.4 }, L23 = { 16.5, -11.3 }, L24 = { 31, -2.2 }, L25 = { -36.8, -1.6 }, L26 = { -29.4, -0.2 },
	L27 = { 0, -1.9 }, L28 = { 0, 0.5 }, L29 = { -42, 37.3 }, L30 = { -20, 29.9 }, L31 = { -2.1, 15.1 },
	L32 = { 17.1, 22.8 }, L33 = { 35.4, -52.8 }, L34 = { 46, 34.2 }, L35 = { -2, 35.1 }, L36 = { 13.4, -5 },
	L37 = { 33.5, -15.4 }, L38 = { -44, 98 }, L39 = { -16, 82.6 }, L40 = { 8, 86 }, L41 = { -18, 121.5 },
	L42 = { 45, 81.1 }, L43 = { 43, 123.9 }, L44 = { 26, 64.3 }, L45 = { 10, 129.3 },
}

---------------------------------------------------------------------------
-- Item models
---------------------------------------------------------------------------
local Build = {}

-- Tier 1 ---------------------------------------------------------------

Build.L02 = function(b) -- folding table + front skirt
	b:Legs(5.4, 2.1, 2.75, 0.18, CF(), PAL.steel)
	b:Box(V3(5.4, 0.12, 0.12), CF(0, 0.8, 1.05), PAL.steel, M.Metal)
	b:Box(V3(6, 0.2, 2.6), CF(0, 2.8, 0), PAL.white)
	b:Box(V3(6.1, 0.1, 2.7), CF(0, 2.95, 0), PAL.cream, M.Fabric)
	local skirt = b:Box(V3(6.1, 1.5, 0.08), CF(0, 2.2, -1.36), PAL.tea, M.Fabric)
	b:Text(skirt, FACE.Front, "THAI ICED TEA", { color = PAL.white, region = { 0.05, 0.4, 0.9, 0.55 } })
	for _, x in { -3.05, 3.05 } do
		b:Box(V3(0.08, 1.5, 2.7), CF(x, 2.2, 0), PAL.tea, M.Fabric)
	end
	b:Box(V3(6.12, 0.18, 0.1), CF(0, 1.45, -1.37), PAL.white, M.Fabric)
	-- vendor's plastic stool
	b:Box(V3(1.3, 0.2, 1.3), CF(0.8, 1.4, 2.5), PAL.red)
	b:Legs(1.0, 1.0, 1.3, 0.2, CF(0.8, 0, 2.5), PAL.red)
	-- bunting along the skirt, straw holder, syrups, tip jar, napkins, lower shelf with stock
	for i = 0, 7 do
		b:Box(V3(0.35, 0.35, 0.04), CF(-2.62 + i * 0.75, 2.62, -1.42) * ANG(0, 0, rad(45)), if i % 2 == 0 then PAL.white else PAL.green, M.Fabric, { solid = false })
	end
	b:Cyl(0.8, 0.45, CF(-2.65, 3.4, 0.8), PAL.white, M.Glass, { t = 0.5, solid = false })
	for i = 0, 5 do
		local a = rad(i * 60)
		b:Rod(V3(-2.65 + math.cos(a) * 0.1, 3.1, 0.8 + math.sin(a) * 0.1), V3(-2.65 + math.cos(a) * 0.25, 4.25, 0.8 + math.sin(a) * 0.25), 0.07, ({ PAL.red, PAL.green, PAL.yellow })[i % 3 + 1])
	end
	for i, c in { rgb(150, 60, 30), PAL.red } do
		b:Cyl(0.8, 0.32, CF(-0.9 + i * 0.4, 3.4, 0.1), c, M.Glass, { t = 0.15, solid = false })
		b:Cyl(0.25, 0.14, CF(-0.9 + i * 0.4, 3.9, 0.1), PAL.white, nil, { solid = false })
	end
	b:Cyl(0.6, 0.5, CF(-0.4, 3.3, -0.75), PAL.white, M.Glass, { t = 0.5, solid = false })
	b:Cyl(0.15, 0.4, CF(-0.4, 3.1, -0.75), PAL.gold, M.Metal, { solid = false })
	b:Box(V3(0.5, 0.35, 0.4), CF(-0.4, 3.18, 0.95), PAL.white, nil, { solid = false })
	b:Box(V3(5.4, 0.1, 2), CF(0, 0.8, 0.1), PAL.steel, M.Metal, { solid = false })
	b:Box(V3(1.2, 0.9, 0.8), CF(-1.6, 1.3, 0.3), PAL.cream, M.Fabric, { solid = false })
	for i = 0, 5 do
		b:Cyl(0.5, 0.4, CF(0.6 + (i % 3) * 0.45, 1.1, -0.1 + math.floor(i / 3) * 0.45), if i % 2 == 0 then PAL.red else PAL.white, nil, { solid = false })
	end
end

Build.L03 = function(b) -- ice cooler on a stool
	b:Box(V3(2, 0.2, 2), CF(0, 1.4, 0), PAL.blue)
	b:Legs(1.6, 1.6, 1.3, 0.25, CF(), PAL.blue)
	b:Cyl(2.2, 2, CF(0, 2.6, 0), PAL.red)
	b:Cyl(0.3, 2.05, CF(0, 2.2, 0), PAL.white)
	b:Cyl(0.35, 2.15, CF(0, 3.85, 0), PAL.white)
	b:Cyl(0.2, 0.6, CF(0, 4.1, 0), PAL.red)
	for _, x in { -1.05, 1.05 } do
		b:Box(V3(0.2, 0.6, 0.5), CF(x, 3.3, 0), PAL.white)
	end
	b:HCyl(0.5, 0.25, CF(0, 1.95, -1.1) * ANG(0, rad(90), 0), PAL.white)
	b:Cyl(0.25, 0.15, CF(0, 1.75, -1.3), PAL.white)
	-- ice on the lid
	b:Box(V3(0.4, 0.4, 0.4), CF(0.4, 4.2, 0.3) * ANG(0, rad(20), 0), PAL.glass, M.Glass, { t = 0.35 })
	-- drip tray, ice bag, scoop on the lid
	b:Box(V3(0.8, 0.1, 0.6), CF(0, 1.52, -1.2), PAL.steel, M.Metal, { solid = false })
	local bag = b:Box(V3(0.9, 1.2, 0.45), CF(1.35, 0.6, -0.5) * ANG(0, rad(-15), 0), PAL.white, nil, { t = 0.15, solid = false })
	b:Text(bag, FACE.Front, "ICE", { color = PAL.blue })
	b:Cyl(0.35, 0.5, CF(-0.4, 4.2, -0.2), PAL.steel, M.Metal, { solid = false })
	b:Rod(V3(-0.4, 4.25, -0.2), V3(-0.4, 4.3, 0.6), 0.1, PAL.black)
	-- lid hinge + latch, side handles with grips, embossed logo, condensation drips, ice cubes in the tray, cups ready
	b:Box(V3(1.2, 0.18, 0.2), CF(0, 3.72, 1.05), PAL.steelDark, M.Metal, { solid = false })
	b:Box(V3(0.35, 0.4, 0.12), CF(0, 3.55, -1.08), PAL.steelDark, M.Metal, { solid = false })
	for _, x in { -1.2, 1.2 } do
		b:HCyl(0.12, 0.35, CF(x, 3.3, 0) * ANG(0, rad(90), 0), PAL.black, nil, { solid = false })
	end
	local logo = b:Box(V3(1.2, 0.5, 0.05), CF(0, 2.95, -1.02), PAL.white, nil, { solid = false })
	b:Text(logo, FACE.Front, "COLD", { color = PAL.red })
	local rand = seeded(3)
	for _ = 1, 6 do
		local a = rad(200 + rand() * 140)
		b:Ellipsoid(V3(0.08, 0.16, 0.08), CF(math.cos(a) * 1.02, 1.9 + rand() * 1.4, math.sin(a) * 1.02), PAL.glass, M.Glass, { t = 0.3 })
	end
	for i = 0, 3 do
		b:Box(V3(0.22, 0.22, 0.22), CF(-0.25 + (i % 2) * 0.3, 1.63, -1.25 + math.floor(i / 2) * 0.2) * ANG(0, i, 0), PAL.glass, M.Glass, { t = 0.3, solid = false })
	end
	for i = 0, 2 do
		b:Cyl(0.35, 0.5, CF(-1.4, 0.18 + i * 0.3, 0.9), PAL.white, M.Glass, { t = 0.4, solid = false })
	end
end

Build.L04 = function(b) -- tea pot on a gas stove
	b:Legs(1.8, 1.8, 1.6, 0.15, CF(), PAL.steelDark)
	b:Box(V3(2, 0.15, 2), CF(0, 1.6, 0), PAL.black, M.Metal)
	b:Cyl(0.2, 1.4, CF(0, 1.78, 0), PAL.black)
	b:Cyl(0.1, 1.1, CF(0, 1.9, 0), rgb(80, 150, 255), M.Neon)
	b:Cyl(1.8, 2, CF(0, 2.85, 0), PAL.steel, M.Metal)
	b:Cyl(0.12, 2.1, CF(0, 3.74, 0), PAL.steel, M.Metal)
	b:Cyl(0.05, 1.9, CF(0, 3.7, 0), PAL.teaDark)
	for _, x in { -1.1, 1.1 } do
		b:Box(V3(0.3, 0.12, 0.5), CF(x, 3.5, 0), PAL.black)
	end
	b:Rod(V3(0.4, 3.6, 0.1), V3(0.9, 4.9, 0.4), 0.12, PAL.steelDark, M.Metal)
	for i, d in { 0.9, 0.7, 0.5 } do
		b:Ball(d, CF(0.15 * i - 0.2, 3.9 + i * 0.6, 0.1 * i), PAL.white, nil, { t = 0.6, solid = false, name = if i == 1 then "Steam" else "SteamPuff" })
	end
	-- gas tank
	b:Cyl(1.8, 1.1, CF(1.9, 0.9, 0.4), PAL.red)
	b:Ball(1.1, CF(1.9, 1.8, 0.4), PAL.red)
	b:Cyl(0.3, 0.35, CF(1.9, 2.4, 0.4), PAL.steel, M.Metal)
	b:Rod(V3(1.9, 2.4, 0.4), V3(0.9, 1.75, 0), 0.1, PAL.black)
	-- wind shield, tea leaf sack, water bucket, hanging ladles
	for _, spec in { { CF(0, 1.95, 1.0), 2.1 }, { CF(-1.0, 1.95, 0) * ANG(0, rad(90), 0), 2.1 }, { CF(1.0, 1.95, 0) * ANG(0, rad(90), 0), 2.1 } } do
		b:Box(V3(spec[2], 0.6, 0.05), spec[1], PAL.steel, M.Metal, { solid = false })
	end
	local sack = b:Box(V3(1, 1.2, 0.8), CF(-1.8, 0.6, 0.3), PAL.cream, M.Fabric)
	b:Text(sack, FACE.Front, "TEA", { color = PAL.teaDark, region = { 0.1, 0.3, 0.8, 0.4 } })
	b:Cyl(1, 1, CF(-1.7, 0.5, -1.2), PAL.blue)
	b:Cyl(0.05, 0.9, CF(-1.7, 0.95, -1.2), PAL.glass, M.Glass, { t = 0.3, solid = false })
	b:Box(V3(1.6, 0.1, 0.1), CF(0, 1.3, 1.05), PAL.steelDark, M.Metal, { solid = false })
	for i = 0, 2 do
		b:Box(V3(0.06, 0.6, 0.06), CF(-0.5 + i * 0.5, 1.0, 1.1), PAL.steel, M.Metal, { solid = false })
		b:Cyl(0.1, 0.25, CF(-0.5 + i * 0.5, 0.65, 1.1), PAL.steel, M.Metal, { solid = false })
	end
end

Build.L05 = function(b) -- cloth tea filter sock on a stand
	for _, x in { -1.1, 1.1 } do
		b:Box(V3(0.2, 4.4, 0.2), CF(x, 2.2, 0), PAL.woodDark, M.Wood)
		b:Box(V3(0.4, 0.15, 1.6), CF(x, 0.08, 0), PAL.woodDark, M.Wood)
	end
	b:Box(V3(2.6, 0.2, 0.2), CF(0, 4.4, 0), PAL.woodDark, M.Wood)
	b:Box(V3(1.5, 1, 1.5), CF(0, 0.5, 0), PAL.wood, M.WoodPlanks)
	b:Cyl(1, 1.2, CF(0, 1.5, 0), PAL.steel, M.Metal)
	b:Cyl(0.05, 1.1, CF(0, 1.98, 0), PAL.teaDark)
	b:Rod(V3(0, 4.3, 0), V3(0, 3.85, 0), 0.08, PAL.steelDark)
	b:Cyl(0.1, 0.95, CF(0, 3.8, 0), PAL.steel, M.Metal)
	local sock = rgb(215, 150, 95)
	for i, d in { 0.85, 0.72, 0.58, 0.42 } do
		b:Cyl(0.36, d, CF(0, 3.62 - (i - 1) * 0.34, 0), sock, M.Fabric)
	end
	b:Ball(0.16, CF(0, 2.35, 0), PAL.teaDark, M.Glass)
	b:Rod(V3(0, 2.3, 0), V3(0, 2.0, 0), 0.06, PAL.teaDark, M.Glass, { t = 0.3 })
	-- spare sock drying on the bar + pulling pitcher
	b:Rod(V3(0.8, 4.3, 0), V3(0.8, 4.0, 0), 0.06, PAL.steelDark)
	for i, d in { 0.6, 0.5, 0.38 } do
		b:Cyl(0.3, d, CF(0.8, 3.85 - (i - 1) * 0.28, 0), rgb(235, 220, 190), M.Fabric, { solid = false })
	end
	b:Cyl(0.9, 0.55, CF(-0.45, 1.45, 0.45), PAL.steel, M.Metal, { solid = false })
	b:Box(V3(0.1, 0.5, 0.25), CF(-0.78, 1.5, 0.45), PAL.steel, M.Metal, { solid = false })
	-- rope ties, cross brace, drip tray, brewed tea in a jug, tea leaf scoop
	for _, x in { -1.1, 1.1 } do
		b:Box(V3(0.25, 0.1, 0.25), CF(x, 4.2, 0), PAL.cream, M.Fabric, { solid = false })
	end
	b:Rod(V3(-1.1, 0.5, 0.1), V3(1.1, 2.5, 0.1), 0.12, PAL.woodDark, M.Wood)
	b:Box(V3(1.3, 0.06, 1.3), CF(0, 2.03, 0), PAL.steel, M.Metal, { solid = false })
	b:Cyl(0.8, 0.5, CF(0.6, 1.4, -0.5), PAL.white, M.Glass, { t = 0.4, solid = false })
	b:Cyl(0.6, 0.45, CF(0.6, 1.3, -0.5), PAL.tea, nil, { solid = false })
	b:Box(V3(0.12, 0.45, 0.2), CF(0.9, 1.45, -0.5), PAL.white, M.Glass, { t = 0.4, solid = false })
	b:Ellipsoid(V3(0.45, 0.2, 0.35), CF(-0.5, 1.05, -0.55), PAL.steel, M.Metal)
	b:Rod(V3(-0.5, 1.1, -0.55), V3(-0.5, 1.15, -1.05), 0.07, PAL.woodDark)
end

Build.L06 = function(b) -- plastic cups (on the table)
	b:Box(V3(2.6, 0.08, 1.0), CF(0, 0.04, -0.45), PAL.steel, M.Metal)
	for i, x in { -0.9, -0.3, 0.3, 0.9 } do
		b:TeaCup(CF(x, 0.08, -0.45), 1, if i == 3 then rgb(120, 180, 90) else nil)
	end
	for _, x in { -0.6, 0, 0.6 } do
		b:Cyl(1.4, 0.5, CF(x, 0.7, 0.55), PAL.white, M.Glass, { t = 0.45 })
		b:Cyl(0.06, 0.56, CF(x, 1.4, 0.55), PAL.white, M.Glass, { t = 0.3 })
	end
	-- cup lids, straw box, spare cup sleeve
	b:Cyl(0.4, 0.5, CF(-1.25, 0.2, 0.55), PAL.white, M.Glass, { t = 0.35, solid = false })
	local straws = b:Box(V3(0.35, 0.9, 0.35), CF(1.35, 0.45, 0.6), PAL.red, nil, { solid = false })
	straws.Name = "StrawBox"
	for i = 0, 3 do
		b:Rod(V3(1.28 + (i % 2) * 0.14, 0.85, 0.53 + math.floor(i / 2) * 0.14), V3(1.28 + (i % 2) * 0.14, 1.4, 0.53 + math.floor(i / 2) * 0.14), 0.06, if i % 2 == 0 then PAL.green else PAL.yellow)
	end
	b:HCyl(1.4, 0.45, CF(0.1, 0.25, 0.2) * ANG(0, rad(90), 0), PAL.white, M.Glass, { t = 0.5, solid = false })
end

Build.L07 = function(b) -- 8-panel market umbrella
	b:Cyl(0.4, 1.4, CF(0, 0.2, 0), PAL.steelDark, M.Concrete)
	b:Cyl(8.4, 0.25, CF(0, 4.2, 0), PAL.white, M.Metal)
	for k = 0, 7 do
		local color = if k % 2 == 0 then PAL.tea else PAL.white
		b:Wedge(V3(4.15, 1.6, 5), CF(0, 7, 0) * ANG(0, rad(45 * k), 0) * CF(0, 0.8, -2.5), color, M.Fabric, { solid = false })
		-- umbrella valance
		b:Box(V3(4.1, 0.35, 0.06), CF(0, 7, 0) * ANG(0, rad(45 * k), 0) * CF(0, -0.15, -4.98), color, M.Fabric, { solid = false })
	end
	b:Ball(0.45, CF(0, 8.75, 0), PAL.tea)
	-- ribs under the canopy, crank, tassels, pole collar
	for k = 0, 7 do
		local rim = (CF(0, 7, 0) * ANG(0, rad(45 * k + 22.5), 0) * CF(0, 0, -5.3)).Position
		b:Rod(V3(0, 8.2, 0), rim, 0.08, PAL.steelDark, M.Metal)
		b:Rod(V3(0, 5.8, 0), (V3(0, 8.2, 0)):Lerp(rim, 0.5), 0.06, PAL.steelDark, M.Metal)
		b:Ball(0.25, CF(rim) * CF(0, -0.45, 0), if k % 2 == 0 then PAL.tea else PAL.white, nil, { solid = false })
	end
	b:Cyl(0.4, 0.45, CF(0, 5.8, 0), PAL.steelDark, M.Metal)
	b:Cyl(0.2, 0.4, CF(0, 3.2, 0), PAL.steelDark, M.Metal)
	b:Box(V3(0.5, 0.08, 0.08), CF(0.25, 3.2, 0), PAL.black, nil, { solid = false })
end

Build.L08 = function(b) -- A-frame shop sign
	local front = CF(0, 1.6, -0.42) * ANG(rad(15), 0, 0)
	local back = CF(0, 1.6, 0.42) * ANG(rad(-15), 0, 0)
	b:Box(V3(2.6, 3.4, 0.12), front, PAL.woodDark, M.Wood)
	b:Box(V3(2.6, 3.4, 0.12), back, PAL.woodDark, M.Wood)
	local board = b:Box(V3(2.2, 3.0, 0.05), front * CF(0, 0, -0.08), rgb(40, 50, 45), nil, { solid = false })
	b:Text(board, FACE.Front, "THAI TEA\n฿25 a cup\nsweet &\ncreamy", { color = PAL.cream, font = Enum.Font.GothamBold })
	local board2 = b:Box(V3(2.2, 3.0, 0.05), back * CF(0, 0, 0.08), rgb(40, 50, 45), nil, { solid = false })
	b:Text(board2, FACE.Back, "GREEN TEA\nLIME TEA\nCOCOA", { color = PAL.cream, font = Enum.Font.GothamBold })
	b:Box(V3(2.7, 0.2, 0.3), CF(0, 3.2, 0), PAL.woodDark, M.Wood)
	-- chalk tray, clip lamp, little flower pot
	b:Box(V3(2.2, 0.1, 0.25), CF(0, 0.2, -0.85), PAL.woodDark, M.Wood, { solid = false })
	for i, c in { PAL.white, PAL.yellow, PAL.pink } do
		b:Box(V3(0.25, 0.08, 0.08), CF(-0.5 + i * 0.3, 0.28, -0.85), c, nil, { solid = false })
	end
	b:Ball(0.3, CF(0, 3.45, -0.3), PAL.warm, M.Neon, { solid = false })
	b:Cyl(0.5, 0.6, CF(1.7, 0.25, -0.3), rgb(190, 100, 60))
	b:Ellipsoid(V3(0.8, 0.6, 0.8), CF(1.7, 0.75, -0.3), PAL.pink)
	-- hinges, frame edges, chalk drawings (cup + stars + arrow), rope stop between the legs
	for _, x in { -1.1, 1.1 } do
		b:HCyl(0.3, 0.15, CF(x, 3.25, 0), PAL.steelDark, M.Metal, { solid = false })
	end
	for _, spec in { { V3(2.4, 0.1, 0.06), CF(0, 1.5, 0) }, { V3(2.4, 0.1, 0.06), CF(0, -1.5, 0) }, { V3(0.1, 3.0, 0.06), CF(1.15, 0, 0) }, { V3(0.1, 3.0, 0.06), CF(-1.15, 0, 0) } } do
		b:Box(spec[1], front * CF(0, 0, -0.12) * spec[2], PAL.woodLight, M.Wood, { solid = false })
	end
	local art = front * CF(0.7, -1.0, -0.12)
	b:Box(V3(0.35, 0.5, 0.02), art, PAL.tea, nil, { solid = false })
	b:Box(V3(0.4, 0.1, 0.02), art * CF(0, 0.3, 0), PAL.cream, nil, { solid = false })
	b:Box(V3(0.04, 0.35, 0.02), art * CF(0.08, 0.5, 0) * ANG(0, 0, rad(-15)), PAL.leaf, nil, { solid = false })
	for i, x in { -0.8, -0.4 } do
		b:Box(V3(0.14, 0.14, 0.02), front * CF(x, -1.1 + i * 0.08, -0.12) * ANG(0, 0, rad(45)), PAL.yellow, nil, { solid = false })
	end
	b:Rod((CF(0, 0.9, -0.62)).Position, (CF(0, 0.9, 0.62)).Position, 0.05, PAL.cream)
end

Build.L09 = function(b) -- cup sealer (on the table)
	b:Box(V3(1.2, 0.2, 1.3), CF(0, 0.1, 0), PAL.white)
	b:Box(V3(1.2, 1.8, 0.45), CF(0, 1.1, 0.42), PAL.white)
	b:Box(V3(1.2, 0.5, 1.2), CF(0, 2.05, 0), PAL.white)
	b:Cyl(0.7, 0.55, CF(0, 0.55, -0.1), PAL.steelDark, M.Metal)
	b:TeaCup(CF(0, 0.2, -0.1), 0.9)
	b:HCyl(1.3, 0.45, CF(0, 2.55, 0.25), rgb(215, 230, 240))
	b:Box(V3(0.5, 0.22, 0.04), CF(0, 2.05, -0.62), rgb(255, 60, 60), M.Neon)
	b:Rod(V3(0.66, 2.0, 0.1), V3(0.66, 2.5, -0.9), 0.1, PAL.black)
	b:Ball(0.25, CF(0.66, 2.5, -0.9), PAL.red)
	-- sealed cups ready to go, power cord, buttons
	for i = 0, 1 do
		b:TeaCup(CF(-1.0 - i * 0.55, 0.2, 0.3), 0.85)
		b:Cyl(0.03, 0.4, CF(-1.0 - i * 0.55, 1.1, 0.3), rgb(215, 230, 240), nil, { solid = false })
	end
	b:Rod(V3(0, 0.9, 0.66), V3(0.3, 0.05, 1.3), 0.06, PAL.black)
	for i, c in { rgb(90, 220, 120), PAL.red } do
		b:Box(V3(0.14, 0.14, 0.04), CF(-0.2 + i * 0.25, 1.75, -0.62), c, M.Neon, { solid = false })
	end
	-- film roll spindle caps, warning label, cup counter display, rubber feet
	for _, x in { -0.67, 0.67 } do
		b:HCyl(0.08, 0.3, CF(x, 2.55, 0.25), PAL.steelDark, M.Metal, { solid = false })
	end
	local warn = b:Box(V3(0.5, 0.3, 0.02), CF(0, 1.4, -0.21), PAL.yellow, nil, { solid = false })
	b:Text(warn, FACE.Front, "HOT", { color = PAL.black })
	local counter = b:Box(V3(0.45, 0.18, 0.02), CF(0.3, 2.3, -0.61), PAL.black, nil, { solid = false })
	b:Text(counter, FACE.Front, "0128", { color = rgb(90, 220, 120), glow = true })
	for _, x in { -0.5, 0.5 } do
		b:Cyl(0.06, 0.2, CF(x, 0.03, -0.5), PAL.black, nil, { solid = false })
	end
end

Build.L10 = function(b) -- glass-door mini fridge
	local body = PAL.red
	for _, x in { -1.2, 1.2 } do
		b:Box(V3(0.2, 5.4, 2.4), CF(x, 2.7, 0), body)
	end
	b:Box(V3(2.6, 5.4, 0.2), CF(0, 2.7, 1.1), body)
	b:Box(V3(2.6, 0.9, 2.4), CF(0, 4.95, 0), body)
	b:Box(V3(2.6, 0.6, 2.4), CF(0, 0.3, 0), body)
	b:Box(V3(2.2, 3.9, 0.05), CF(0, 2.55, 0.98), PAL.white)
	local logo = b:Box(V3(2.4, 0.6, 0.06), CF(0, 5.0, -1.22), PAL.white, M.Neon, { solid = false })
	b:Text(logo, FACE.Front, "ICED TEA", { color = PAL.red })
	for i, y in { 1.2, 2.25, 3.3 } do
		b:Box(V3(2.2, 0.08, 2.0), CF(0, y, 0), PAL.steel, M.Metal, { solid = false })
		for j, x in { -0.75, -0.25, 0.25, 0.75 } do
			local colors = { PAL.tea, PAL.leaf, rgb(120, 70, 40), PAL.white }
			local c = colors[(i + j) % 4 + 1]
			b:Cyl(0.65, 0.33, CF(x, y + 0.37, -0.35), c, M.Glass, { t = 0.1 })
			b:Cyl(0.12, 0.2, CF(x, y + 0.76, -0.35), PAL.red)
		end
	end
	local door = b:Box(V3(2.3, 4.0, 0.08), CF(0, 2.6, -1.18), PAL.glass, M.Glass, { t = 0.6 })
	b:Light(door, PAL.white, 6, 0.6)
	b:Box(V3(0.12, 1.4, 0.15), CF(0.95, 2.6, -1.3), PAL.steel, M.Metal)
	-- door gasket, kick grille, side logo, sale sticker, thermometer
	for _, spec in { { V3(2.3, 0.08, 0.1), CF(0, 4.62, -1.23) }, { V3(2.3, 0.08, 0.1), CF(0, 0.58, -1.23) }, { V3(0.08, 4.0, 0.1), CF(-1.13, 2.6, -1.23) }, { V3(0.08, 4.0, 0.1), CF(1.13, 2.6, -1.23) } } do
		b:Box(spec[1], spec[2], PAL.black, nil, { solid = false })
	end
	b:Box(V3(2.2, 0.35, 0.05), CF(0, 0.3, -1.22), PAL.black, nil, { solid = false })
	local side = b:Box(V3(0.05, 1.6, 1.8), CF(1.31, 3.3, 0), PAL.white, nil, { solid = false })
	b:Text(side, FACE.Right, "ICED\nTEA", { color = PAL.red })
	local sticker = b:HCyl(0.03, 0.7, CF(-0.6, 3.9, -1.26) * ANG(0, rad(90), 0), PAL.yellow, nil, { solid = false })
	sticker.Name = "Sticker"
	b:Box(V3(0.3, 0.5, 0.04), CF(0.8, 4.3, -1.25), PAL.white, nil, { solid = false })
	b:Box(V3(0.06, 0.35, 0.02), CF(0.8, 4.3, -1.28), PAL.red, nil, { solid = false })
end

-- Tier 2 ---------------------------------------------------------------

Build.L11 = function(b) -- wooden counter
	b:Box(V3(15.8, 0.4, 2.6), CF(0, 0.2, 0.1), PAL.black)
	b:Box(V3(16, 2.9, 2.8), CF(0, 1.85, 0.1), PAL.woodLight, M.WoodPlanks)
	b:Box(V3(16.4, 0.2, 3.2), CF(0, 3.4, 0), PAL.white, M.Marble)
	b:Box(V3(16.02, 0.35, 0.05), CF(0, 3.0, -1.32), PAL.tea)
	for i = 0, 14 do
		local x = -7 + i
		if math.abs(x) > 2.8 then
			b:Box(V3(0.3, 2.3, 0.08), CF(x, 1.65, -1.34), PAL.woodDark, M.Wood, { solid = false })
		end
	end
	local logo = b:Box(V3(5, 1.6, 0.12), CF(0, 1.8, -1.38), PAL.green)
	b:Text(logo, FACE.Front, "THAI TEA", { color = PAL.cream })
	-- brass foot rail, under-lip glow, end caps, plant, tip jar
	b:Tube(V3(-7.6, 0.6, -1.85), V3(7.6, 0.6, -1.85), 0.18, PAL.gold, M.Metal)
	for _, x in { -7, 0, 7 } do
		b:Box(V3(0.12, 0.3, 0.45), CF(x, 0.6, -1.65), PAL.gold, M.Metal, { solid = false })
	end
	b:Box(V3(15.6, 0.08, 0.08), CF(0, 3.22, -1.56), PAL.warm, M.Neon, { solid = false })
	for _, x in { -8.05, 8.05 } do
		b:Box(V3(0.3, 3.3, 3.0), CF(x, 1.65, 0.1), PAL.woodDark, M.Wood)
	end
	b:Cyl(0.6, 0.6, CF(7.4, 3.8, 0.9), PAL.white)
	b:Ellipsoid(V3(0.9, 1.0, 0.9), CF(7.4, 4.5, 0.9), PAL.leaf)
	b:Cyl(0.6, 0.5, CF(2.4, 3.8, -1.0), PAL.white, M.Glass, { t = 0.5, solid = false })
	local tip = b:Box(V3(0.5, 0.2, 0.02), CF(2.4, 3.8, -1.26), PAL.white, nil, { t = 1, solid = false })
	b:Text(tip, FACE.Front, "TIPS", { color = PAL.teaDark })
end

Build.L12 = function(b) -- electric tea brewer (on the counter)
	b:Box(V3(1.6, 0.3, 1.6), CF(0, 0.15, 0.3), PAL.steelDark, M.Metal)
	b:Cyl(2.2, 1.5, CF(0, 1.4, 0.3), PAL.steel, M.Metal)
	b:Ellipsoid(V3(1.5, 0.7, 1.5), CF(0, 2.5, 0.3), PAL.steel, M.Metal)
	b:Ball(0.3, CF(0, 2.9, 0.3), PAL.black)
	b:Box(V3(0.3, 0.3, 0.5), CF(0, 0.7, -0.6), PAL.black)
	b:Box(V3(0.12, 1.4, 0.05), CF(0.45, 1.5, -0.47), PAL.tea, M.Glass, { t = 0.2 })
	b:Ball(0.16, CF(-0.45, 2.0, -0.45), rgb(255, 60, 60), M.Neon)
	b:TeaCup(CF(0, 0.3, -0.75), 0.8)
	-- hot water boiler
	b:Box(V3(1, 1.6, 1), CF(1.35, 0.8, 0.3), PAL.white)
	b:Box(V3(0.5, 0.25, 0.04), CF(1.35, 1.2, -0.21), rgb(80, 170, 255), M.Neon)
	-- cup tower, timer, tea towel
	for i = 0, 2 do
		b:Cyl(0.4, 0.5, CF(-1.0, 0.2 + i * 0.35, 0.4), PAL.white, M.Glass, { t = 0.45, solid = false })
	end
	b:Box(V3(0.4, 0.3, 0.3), CF(-1.0, 0.15, -0.5), PAL.white, nil, { solid = false })
	b:Box(V3(0.25, 0.1, 0.02), CF(-1.0, 0.18, -0.66), rgb(255, 60, 60), M.Neon, { solid = false })
	b:Box(V3(0.8, 0.9, 0.05), CF(1.35, 1.0, -0.23), PAL.red, M.Fabric, { solid = false })
	-- lid handle + hinge, water level window, temperature gauge, feet, drip tray grille, steam puffs, sugar jar
	b:Box(V3(0.5, 0.12, 0.12), CF(0, 2.75, -0.2), PAL.black, nil, { solid = false })
	b:HCyl(0.08, 0.4, CF(0.55, 2.2, -0.4) * ANG(0, rad(90), 0), PAL.white, nil, { solid = false })
	b:Box(V3(0.03, 0.16, 0.02), CF(0.55, 2.24, -0.44) * ANG(0, 0, rad(-35)), PAL.red, nil, { solid = false })
	for _, x in { -0.55, 0.55 } do
		for _, z in { -0.2, 0.8 } do
			b:Cyl(0.1, 0.2, CF(x, 0.35, z), PAL.black, nil, { solid = false })
		end
	end
	for i = -2, 2 do
		b:Box(V3(0.04, 0.02, 0.4), CF(i * 0.1, 0.32, -0.75), PAL.steelDark, M.Metal, { solid = false })
	end
	for i, d in { 0.45, 0.35 } do
		b:Ball(d, CF(0.1 * i, 3.0 + i * 0.35, 0.3), PAL.white, nil, { t = 0.65, solid = false, name = if i == 1 then "Steam" else "SteamPuff" })
	end
	b:Cyl(0.5, 0.4, CF(1.35, 1.85, 0.3), PAL.white, M.Glass, { t = 0.4, solid = false })
	b:Cyl(0.3, 0.35, CF(1.35, 1.75, 0.3), PAL.white, nil, { solid = false })
	b:Cyl(0.1, 0.42, CF(1.35, 2.15, 0.3), PAL.tea, nil, { solid = false })
end

Build.L13 = function(b) -- topping bar (on the counter)
	b:Box(V3(3.6, 0.25, 1.6), CF(0, 0.125, 0), PAL.steel, M.Metal)
	local fills = {
		PAL.pearl, rgb(120, 200, 90), rgb(140, 50, 50),
		rgb(245, 200, 90), rgb(240, 240, 230), rgb(30, 30, 30),
	}
	for i, fill in fills do
		local x = -1.15 + ((i - 1) % 3) * 1.15
		local z = if i <= 3 then -0.35 else 0.4
		b:Box(V3(1.0, 0.35, 0.65), CF(x, 0.42, z), PAL.steel, M.Metal, { solid = false })
		b:Box(V3(0.9, 0.05, 0.55), CF(x, 0.6, z), fill, nil, { solid = false })
	end
	b:Box(V3(3.6, 0.9, 1.6), CF(0, 0.7, 0), PAL.glass, M.Glass, { t = 0.8, solid = false })
	local strip = b:Box(V3(3.6, 0.3, 0.05), CF(0, 1.3, -0.8), PAL.tea, nil, { solid = false })
	b:Text(strip, FACE.Front, "TOPPINGS", { color = PAL.white })
	-- serving scoops and tub labels
	for i = 1, 6 do
		local x = -1.15 + ((i - 1) % 3) * 1.15
		local z = if i <= 3 then -0.35 else 0.4
		b:Rod(V3(x + 0.2, 0.62, z), V3(x + 0.35, 1.05, z + 0.2), 0.06, PAL.steel, M.Metal)
	end
	for i, name in { "PEARL", "JELLY", "BEAN" } do
		local tag = b:Box(V3(0.9, 0.18, 0.02), CF(-1.15 + (i - 1) * 1.15, 0.32, -0.81), PAL.white, nil, { solid = false })
		b:Text(tag, FACE.Front, name, { color = PAL.black })
	end
	-- sneeze-guard frame, tub lids stacked behind, cup of spoons, price flags
	for _, x in { -1.8, 1.8 } do
		b:Box(V3(0.08, 1.0, 0.08), CF(x, 0.7, -0.8), PAL.steel, M.Metal, { solid = false })
		b:Box(V3(0.08, 1.0, 0.08), CF(x, 0.7, 0.8), PAL.steel, M.Metal, { solid = false })
	end
	b:Box(V3(3.66, 0.06, 0.06), CF(0, 1.17, -0.8), PAL.steel, M.Metal, { solid = false })
	b:Box(V3(3.66, 0.06, 0.06), CF(0, 1.17, 0.8), PAL.steel, M.Metal, { solid = false })
	for i = 0, 3 do
		b:Box(V3(1.0, 0.05, 0.65), CF(1.3, 0.3 + i * 0.06, 1.1), PAL.steel, M.Metal, { solid = false })
	end
	b:Cyl(0.5, 0.35, CF(-1.45, 0.5, 1.1), PAL.white, M.Glass, { t = 0.3, solid = false })
	for i = 0, 3 do
		b:Rod(V3(-1.5 + (i % 2) * 0.1, 0.5, 1.05 + math.floor(i / 2) * 0.1), V3(-1.6 + i * 0.07, 1.0, 1.1), 0.05, PAL.steel, M.Metal)
	end
	for i, name in { "+10", "+10", "+15" } do
		local flag = b:Box(V3(0.35, 0.22, 0.02), CF(-1.15 + (i - 1) * 1.15, 1.45, -0.82), PAL.yellow, nil, { solid = false })
		b:Text(flag, FACE.Front, name, { color = PAL.black })
		b:Box(V3(0.03, 0.3, 0.03), CF(-1.15 + (i - 1) * 1.15, 1.25, -0.82), PAL.black, nil, { solid = false })
	end
end

Build.L14 = function(b) -- tapioca pearl pot
	b:Legs(2.2, 2.2, 1.5, 0.2, CF(), PAL.steelDark)
	b:Box(V3(2.5, 0.15, 2.5), CF(0, 1.5, 0), PAL.black, M.Metal)
	b:Cyl(0.1, 1.2, CF(0, 1.62, 0), rgb(80, 150, 255), M.Neon)
	b:Cyl(2, 2.6, CF(0, 2.65, 0), PAL.steelDark, M.Metal)
	b:Cyl(0.12, 2.7, CF(0, 3.62, 0), PAL.steel, M.Metal)
	b:Cyl(0.1, 2.4, CF(0, 3.45, 0), PAL.pearl)
	local rand = seeded(14)
	for _ = 1, 9 do
		local a, r = rand() * math.pi * 2, rand() * 0.95
		b:Ball(0.3, CF(math.cos(a) * r, 3.55, math.sin(a) * r), PAL.pearl, M.Glass)
	end
	b:Rod(V3(-0.5, 3.4, 0), V3(-1.1, 5.2, 0.4), 0.14, PAL.woodDark)
	for i, d in { 1.0, 0.8, 0.55 } do
		b:Ball(d, CF(0.3 - 0.1 * i, 3.9 + i * 0.6, 0.1), PAL.white, nil, { t = 0.65, solid = false, name = if i == 1 then "Steam" else "SteamPuff" })
	end
	local sack = b:Box(V3(1.1, 1.3, 0.9), CF(2.1, 0.65, 0.2), PAL.cream, M.Fabric)
	b:Text(sack, FACE.Front, "PEARLS", { color = PAL.teaDark })
	-- colander, brown sugar syrup pot, timer
	b:Box(V3(1.4, 1.6, 1.2), CF(-2.0, 0.8, 0.2), PAL.steel, M.Metal)
	b:Ellipsoid(V3(1.0, 0.5, 1.0), CF(-2.0, 1.75, 0.2), PAL.steelDark, M.Metal)
	b:Cyl(0.7, 0.8, CF(-2.2, 1.95, -0.2), rgb(120, 60, 30))
	b:Cyl(0.05, 0.7, CF(-2.2, 2.3, -0.2), rgb(90, 45, 20), nil, { solid = false })
	b:Box(V3(0.4, 0.3, 0.3), CF(-1.6, 1.75, 0.6), PAL.white, nil, { solid = false })
	b:Box(V3(0.3, 0.1, 0.02), CF(-1.6, 1.78, 0.44), rgb(255, 60, 60), M.Neon, { solid = false })
end

Build.L15 = function(b) -- 4 bar stools
	for _, x in { -6, -2, 2, 6 } do
		b:Cyl(0.15, 1.4, CF(x, 0.08, 0), PAL.steelDark, M.Metal)
		b:Cyl(2.4, 0.25, CF(x, 1.3, 0), PAL.steel, M.Metal)
		b:Cyl(0.08, 1.1, CF(x, 1.0, 0), PAL.steel, M.Metal)
		b:Cyl(0.12, 1.65, CF(x, 2.45, 0), PAL.black)
		b:Cyl(0.35, 1.6, CF(x, 2.65, 0), PAL.tea)
	end
	-- low backrests
	for _, x in { -6, -2, 2, 6 } do
		b:Box(V3(1.3, 0.7, 0.15), CF(x, 3.35, -0.72), PAL.tea)
		b:Box(V3(0.12, 0.6, 0.12), CF(x, 2.95, -0.7), PAL.steel, M.Metal, { solid = false })
	end
	-- footrest rings, cushion piping, backrest stitched stripe
	for _, x in { -6, -2, 2, 6 } do
		b:Cyl(0.08, 1.3, CF(x, 1.1, 0), PAL.steelDark, M.Metal, { solid = false })
		b:Cyl(0.06, 1.66, CF(x, 2.52, 0), PAL.white, nil, { solid = false })
		b:Box(V3(1.1, 0.08, 0.02), CF(x, 3.35, -0.8), PAL.white, nil, { solid = false })
	end
end

Build.L16 = function(b) -- round patio table + 4 chairs
	b:Cyl(0.15, 1.8, CF(0, 0.08, 0), PAL.black)
	b:Cyl(2.8, 0.3, CF(0, 1.4, 0), PAL.black)
	b:Cyl(0.25, 4, CF(0, 2.9, 0), PAL.white)
	b:TeaCup(CF(-0.6, 3.02, -0.3))
	b:TeaCup(CF(0.7, 3.02, 0.4), 1, rgb(120, 180, 90))
	b:Cyl(0.6, 0.35, CF(0, 3.3, 0.9), PAL.white, M.Glass, { t = 0.3 })
	b:Ball(0.45, CF(0, 3.8, 0.9), PAL.pink)
	for k = 0, 3 do
		local seat = ANG(0, rad(45 + 90 * k), 0) * CF(0, 0, -2.9)
		b:Legs(1.3, 1.3, 1.7, 0.18, seat, PAL.steelDark)
		b:Box(V3(1.6, 0.25, 1.6), seat * CF(0, 1.8, 0), PAL.green)
		b:Box(V3(1.6, 1.8, 0.2), seat * CF(0, 2.8, -0.75), PAL.green)
	end
	-- parasol over the table + napkin holder
	b:Cyl(4.4, 0.15, CF(0, 5.2, 0), PAL.white, M.Metal)
	for k = 0, 7 do
		b:Wedge(V3(2.3, 0.9, 2.8), CF(0, 6.4, 0) * ANG(0, rad(45 * k), 0) * CF(0, 0.45, -1.4), if k % 2 == 0 then PAL.green else PAL.white, M.Fabric, { solid = false })
	end
	b:Ball(0.3, CF(0, 7.4, 0), PAL.green)
	b:Box(V3(0.5, 0.35, 0.3), CF(0.5, 3.2, -0.6), PAL.steel, M.Metal, { solid = false })
end

Build.L17 = function(b) -- string lights (4 poles + sagging wires)
	local w, d, h = 16, 10, 9
	local corners = { V3(-w, h, -d), V3(w, h, -d), V3(w, h, d), V3(-w, h, d) }
	for _, c in corners do
		b:Cyl(h, 0.35, CF(c.X, h / 2, c.Z), PAL.woodDark, M.Wood)
		b:Ball(0.5, CF(c.X, h + 0.2, c.Z), PAL.black)
	end
	local bulbColors = { PAL.warm, PAL.tea, PAL.pink, PAL.yellow }
	local n = 0
	for i = 1, 4 do
		local a, c = corners[i], corners[i % 4 + 1]
		local mid = (a + c) / 2 - V3(0, 1.3, 0)
		b:Rod(a, mid, 0.08, PAL.black)
		b:Rod(mid, c, 0.08, PAL.black)
		local steps = math.floor((c - a).Magnitude / 2.6)
		for s = 1, steps - 1 do
			local t = s / steps
			local sag = 1.3 * (1 - (2 * t - 1) ^ 2)
			local p = a:Lerp(c, t) - V3(0, sag + 0.25, 0)
			n += 1
			local bulb = b:Ball(0.38, CF(p), bulbColors[n % #bulbColors + 1], M.Neon, { solid = false })
			if s == math.floor(steps / 2) then
				b:Light(bulb, PAL.warm, 14, 0.8)
			end
		end
	end
	-- paper lanterns + pennant flags on the front wire
	for i, x in { -8, 0, 8 } do
		local p = V3(x, 9 - 1.3 * (1 - (x / 16) ^ 2) - 0.9, -10)
		b:Box(V3(0.05, 0.6, 0.05), CF(p + V3(0, 0.6, 0)), PAL.black, nil, { solid = false })
		local lantern = b:Ellipsoid(V3(0.9, 1.2, 0.9), CF(p), if i == 2 then PAL.tea else PAL.red, M.Fabric)
		b:Light(lantern, PAL.warm, 8, 0.4)
	end
	for i = 0, 9 do
		local x = -14 + i * 3.1
		local sag = 1.3 * (1 - (x / 16) ^ 2)
		b:Wedge(V3(0.05, 0.7, 0.6), CF(x, 8.4 - sag, 10) * ANG(rad(180), 0, 0), if i % 2 == 0 then PAL.tea else PAL.green, M.Fabric, { solid = false })
	end
end

Build.L18 = function(b) -- cash register + scan-to-pay stand (on the counter)
	b:Box(V3(1.4, 0.5, 1.2), CF(0, 0.25, 0.2), PAL.black)
	b:Box(V3(1.3, 0.05, 0.02), CF(0, 0.25, -0.41), PAL.steelDark, nil, { solid = false })
	b:Box(V3(0.15, 0.6, 0.15), CF(0, 0.75, 0.3), PAL.black)
	local screen = CF(0, 1.3, 0.35) * ANG(0, rad(180), 0) * ANG(rad(15), 0, 0)
	b:Box(V3(1.3, 0.9, 0.1), screen, PAL.black)
	b:Box(V3(1.15, 0.75, 0.02), screen * CF(0, 0, -0.06), rgb(70, 150, 255), M.Neon, { solid = false })
	b:Box(V3(0.6, 0.3, 0.08), CF(0, 0.8, -0.35), rgb(90, 220, 120), M.Neon)
	b:Box(V3(0.6, 0.4, 0.6), CF(1.1, 0.2, 0.2), PAL.white)
	b:Box(V3(0.4, 0.3, 0.02), CF(1.1, 0.5, 0.05) * ANG(rad(-20), 0, 0), PAL.white, nil, { solid = false })
	local qr = b:Box(V3(0.8, 1.1, 0.08), CF(-1.2, 0.6, -0.2) * ANG(rad(10), 0, 0), PAL.white)
	b:Text(qr, FACE.Front, "SCAN TO PAY", { color = rgb(20, 60, 140), region = { 0, 0, 1, 0.25 } })
	b:Box(V3(0.55, 0.55, 0.02), CF(-1.2, 0.5, -0.26) * ANG(rad(10), 0, 0), PAL.black, nil, { solid = false })
	b:Box(V3(0.8, 0.1, 0.3), CF(-1.2, 0.05, -0.1), PAL.black)
	-- card terminal, coin tray, receipt roll
	b:Box(V3(0.35, 0.1, 0.6), CF(0.85, 0.05, -0.55), PAL.black, nil, { solid = false })
	b:Box(V3(0.25, 0.02, 0.2), CF(0.85, 0.11, -0.7), rgb(70, 150, 255), M.Neon, { solid = false })
	b:Box(V3(0.8, 0.08, 0.4), CF(-0.2, 0.04, -0.7), PAL.steel, M.Metal, { solid = false })
	for i = 0, 3 do
		b:Cyl(0.03, 0.14, CF(-0.45 + i * 0.16, 0.1, -0.7), PAL.gold, M.Metal, { solid = false })
	end
	b:HCyl(0.4, 0.3, CF(1.1, 0.55, 0.2), PAL.white, nil, { solid = false })
	-- keypad grid, open cash drawer with notes, receipt paper curl, customer display, card on the terminal
	for r = 0, 2 do
		for c = 0, 3 do
			b:Box(V3(0.16, 0.05, 0.12), CF(-0.36 + c * 0.24, 0.52, -0.05 - r * 0.16), if r == 0 and c == 3 then PAL.red elseif c == 3 then rgb(90, 220, 120) else PAL.white, nil, { solid = false })
		end
	end
	b:Box(V3(1.3, 0.2, 0.5), CF(0, 0.12, -0.55), PAL.black, nil, { solid = false })
	for i = 0, 3 do
		b:Box(V3(0.26, 0.04, 0.35), CF(-0.45 + i * 0.3, 0.22, -0.55), ({ PAL.leaf, PAL.blue, PAL.red, PAL.leaf })[i + 1], nil, { solid = false })
	end
	b:Box(V3(0.3, 0.02, 0.5), CF(1.1, 0.72, -0.05) * ANG(rad(-35), 0, 0), PAL.white, nil, { solid = false })
	b:Box(V3(0.5, 0.3, 0.05), CF(0, 1.05, 0.05), rgb(90, 220, 120), M.Neon, { solid = false })
	b:Box(V3(0.2, 0.02, 0.3), CF(0.85, 0.13, -0.6) * ANG(0, rad(15), 0), PAL.gold, nil, { solid = false })
end

Build.L19 = function(b) -- tea master pulling tea (on a platform to clear the counter)
	b:Box(V3(3, 0.6, 2.2), CF(0, 0.3, 0), PAL.woodDark, M.WoodPlanks)
	local hands = b:Person(CF(0, 0.6, 0), {
		apron = PAL.tea, cap = PAL.tea, shirt = PAL.white,
		right = { 150, 20 }, left = { 60, 30 },
	})
	b:Cyl(0.6, 0.5, CF(hands.right) * CF(0, -0.1, 0), PAL.steel, M.Metal)
	b:TeaCup(CF(hands.left) * CF(0, -0.2, 0), 1.2)
	b:Rod(hands.right - V3(0, 0.4, 0), hands.left + V3(0, 0.9, 0), 0.14, PAL.tea, M.Glass, { t = 0.15 })
	-- towel on the shoulder + name tag
	b:Box(V3(0.8, 0.1, 1.1), CF(-1.1, 4.62, 0), PAL.white, M.Fabric, { solid = false })
	b:Box(V3(0.5, 0.15, 0.03), CF(0.5, 3.9, -0.62), PAL.gold, M.Metal, { solid = false })
end

-- Tier 3 ---------------------------------------------------------------

Build.L20 = function(b) -- ice machine
	b:Box(V3(4, 3, 3), CF(0, 1.5, 0), PAL.steel, M.Metal)
	b:Box(V3(3.4, 1.0, 0.1), CF(0, 2.35, -1.52), PAL.steelDark, M.Metal)
	b:Box(V3(1.6, 0.2, 0.2), CF(0, 2.0, -1.6), PAL.black)
	b:Box(V3(3.6, 2, 2.6), CF(0, 4, 0.1), PAL.steel, M.Metal)
	for i = -2, 2 do
		b:Box(V3(0.12, 1.2, 0.05), CF(i * 0.5 + 0.6, 4.0, -1.22), PAL.steelDark, nil, { solid = false })
	end
	local display = b:Box(V3(0.9, 0.35, 0.05), CF(-1.0, 4.3, -1.22), rgb(70, 170, 255), M.Neon, { solid = false })
	b:Text(display, FACE.Front, "ICE", { color = PAL.white })
	for _, x in { -1.7, 1.7 } do
		for _, z in { -1.3, 1.3 } do
			b:Cyl(0.2, 0.35, CF(x, 0.1, z), PAL.black)
		end
	end
	-- ice tray
	b:Box(V3(1.8, 0.4, 1.2), CF(1.1, 5.2, -0.3), PAL.white, M.Glass, { t = 0.5 })
	local rand = seeded(20)
	for _ = 1, 5 do
		b:Box(V3(0.35, 0.35, 0.35), CF(0.5 + rand() * 1.2, 5.5, -0.7 + rand() * 0.8) * ANG(0, rand() * 3, 0), PAL.glass, M.Glass, { t = 0.3 })
	end
	-- ice bags, water filter, drain hose, sticker
	for i = 0, 2 do
		local bag = b:Box(V3(1.0, 0.8, 0.8), CF(2.7, 0.4 + i * 0.8, -0.5 + (i % 2) * 0.2), PAL.white, nil, { t = 0.2, solid = false })
		if i == 2 then
			b:Text(bag, FACE.Front, "ICE", { color = PAL.blue })
		end
	end
	b:Cyl(1.4, 0.5, CF(-2.3, 3.5, 0.6), PAL.blue)
	b:Tube(V3(-2.3, 2.8, 0.6), V3(-1.8, 2.8, 0.6), 0.1, PAL.white)
	b:Tube(V3(1.6, 0.3, 1.5), V3(1.6, 0.05, 2.3), 0.15, PAL.black)
	b:Box(V3(0.8, 0.8, 0.03), CF(1.3, 2.4, -1.53), PAL.blue, nil, { solid = false })
	-- vent grille on the side, ice scoop hanging on a hook, feet trim, drip tray grid
	for i = 0, 6 do
		b:Box(V3(0.04, 0.1, 2.2), CF(2.02, 1.0 + i * 0.25, 0), PAL.steelDark, nil, { solid = false })
	end
	b:Box(V3(0.1, 0.4, 0.1), CF(-1.9, 2.6, -1.55), PAL.black, nil, { solid = false })
	b:Ellipsoid(V3(0.5, 0.3, 0.4), CF(-1.9, 2.2, -1.65), PAL.steel, M.Metal)
	b:Rod(V3(-1.9, 2.25, -1.65), V3(-1.9, 2.5, -1.6), 0.08, PAL.black)
	for i = -3, 3 do
		b:Box(V3(0.04, 0.03, 0.5), CF(i * 0.2, 1.62, -1.55), PAL.steelDark, M.Metal, { solid = false })
	end
end

Build.L21 = function(b) -- lit menu board
	for _, x in { -3.6, 3.6 } do
		b:Box(V3(0.4, 8, 0.4), CF(x, 4, 0), PAL.woodDark, M.Wood)
	end
	b:Box(V3(8, 5, 0.4), CF(0, 5.2, 0), PAL.woodDark, M.Wood)
	local board = b:Box(V3(7.4, 4.4, 0.1), CF(0, 5.2, -0.22), rgb(30, 35, 32), nil, { solid = false })
	b:Text(board, FACE.Front,
		"Thai Tea ........... 35\nGreen Tea ......... 40\nLime Tea ........... 30\nCocoa .............. 40\nThai Coffee ....... 35",
		{ color = PAL.cream, glow = true, font = Enum.Font.GothamBold })
	local header = b:Box(V3(8.2, 0.9, 0.5), CF(0, 8.1, 0), PAL.tea)
	b:Text(header, FACE.Front, "MENU", { color = PAL.white })
	local strip = b:Box(V3(7, 0.12, 0.3), CF(0, 7.6, -0.4), PAL.warm, M.Neon, { solid = false })
	b:Light(strip, PAL.warm, 8, 0.7)
	-- spot lamps, NEW! starburst, chalk tray, cup art
	for _, x in { -2.5, 2.5 } do
		b:Rod(V3(x, 8.5, 0), V3(x, 8.9, -1.2), 0.1, PAL.black, M.Metal)
		b:Cyl(0.35, 0.4, CF(x, 8.8, -1.3), PAL.black, M.Metal, { solid = false })
		b:Ball(0.25, CF(x, 8.6, -1.3), PAL.warm, M.Neon, { solid = false })
	end
	local star = b:Ellipsoid(V3(1.5, 1.5, 0.1), CF(-3.9, 8.2, -0.45), PAL.yellow)
	b:Text(star, FACE.Front, "NEW!", { color = PAL.red })
	b:Box(V3(7, 0.12, 0.35), CF(0, 2.9, -0.35), PAL.woodDark, M.Wood, { solid = false })
	b:Plant(CF(4.6, 0, -0.4), 1.6)
	-- light wood frame around the board, post feet, small "today's special" easel beside it
	for _, spec in { { V3(7.7, 0.18, 0.12), CF(0, 7.45, -0.25) }, { V3(7.7, 0.18, 0.12), CF(0, 2.95, -0.25) }, { V3(0.18, 4.6, 0.12), CF(-3.8, 5.2, -0.25) }, { V3(0.18, 4.6, 0.12), CF(3.8, 5.2, -0.25) } } do
		b:Box(spec[1], spec[2], PAL.woodLight, M.Wood, { solid = false })
	end
	for _, x in { -3.6, 3.6 } do
		b:Box(V3(0.8, 0.25, 1.4), CF(x, 0.12, 0), PAL.woodDark, M.Wood)
	end
	local easel = CF(-5.2, 1.3, -0.6) * ANG(rad(-12), rad(10), 0)
	b:Box(V3(1.4, 1.8, 0.08), easel, rgb(30, 35, 32), nil, { solid = false })
	local special = b:Box(V3(1.2, 1.6, 0.02), easel * CF(0, 0, -0.05), rgb(30, 35, 32), nil, { solid = false })
	b:Text(special, FACE.Front, "TODAY\nSPECIAL\nMango\nThai Tea", { color = PAL.yellow, font = Enum.Font.GothamBold })
	for _, x in { -0.55, 0.55 } do
		b:Rod((easel * CF(x, 0.9, 0.1)).Position, V3(-5.2 + x, 0, -1.1), 0.1, PAL.woodDark, M.Wood)
	end
	b:Rod((easel * CF(0, 0.9, 0.1)).Position, V3(-5.2, 0, 0.3), 0.1, PAL.woodDark, M.Wood)
end

Build.L22 = function(b) -- blender station
	b:Box(V3(3, 3, 2), CF(0, 1.5, 0), PAL.white)
	b:Box(V3(3.02, 0.3, 2.02), CF(0, 2.6, 0), PAL.tea)
	b:Box(V3(0.05, 2.2, 0.02), CF(0, 1.2, -1.01), PAL.steelDark, nil, { solid = false })
	for _, x in { -0.4, 0.4 } do
		b:Box(V3(0.1, 0.5, 0.1), CF(x, 1.6, -1.05), PAL.steelDark, M.Metal, { solid = false })
	end
	b:Box(V3(3.2, 0.15, 2.2), CF(0, 3.07, 0), PAL.steel, M.Metal)
	for i, x in { -0.75, 0.75 } do
		b:Box(V3(0.7, 0.5, 0.7), CF(x, 3.4, 0), PAL.black)
		b:Ball(0.15, CF(x, 3.4, -0.36), rgb(90, 220, 120), M.Neon, { solid = false })
		b:Cyl(0.6, 0.5, CF(x, 3.95, 0), if i == 1 then PAL.tea else rgb(120, 180, 90))
		b:Cyl(1.1, 0.62, CF(x, 4.2, 0), PAL.white, M.Glass, { t = 0.6 })
		b:Cyl(0.15, 0.66, CF(x, 4.82, 0), PAL.black)
	end
	-- syrup bottles with pumps, lemons, ice bin
	for i, c in { rgb(150, 60, 30), PAL.red, rgb(120, 180, 90) } do
		local x = -1.2 + (i - 1) * 0.3
		b:Cyl(0.7, 0.26, CF(x, 3.5, 0.75), c, M.Glass, { t = 0.1, solid = false })
		b:Cyl(0.3, 0.1, CF(x, 4.0, 0.75), PAL.black, nil, { solid = false })
		b:Box(V3(0.25, 0.06, 0.06), CF(x, 4.15, 0.65), PAL.black, nil, { solid = false })
	end
	for i = 0, 2 do
		b:Ball(0.28, CF(0.9 + i * 0.25, 3.3, 0.8 - (i % 2) * 0.15), PAL.yellow, nil, { solid = false })
	end
	b:Box(V3(1, 0.5, 0.7), CF(1.1, 3.4, -0.55), PAL.steel, M.Metal, { solid = false })
	for i = 0, 3 do
		b:Box(V3(0.25, 0.25, 0.25), CF(0.8 + (i % 2) * 0.35, 3.62, -0.7 + math.floor(i / 2) * 0.3), PAL.glass, M.Glass, { t = 0.3, solid = false })
	end
end

Build.L23 = function(b) -- cake display
	b:Box(V3(5, 2.4, 2.4), CF(0, 1.2, 0), PAL.white)
	b:Box(V3(5.02, 0.4, 2.42), CF(0, 1.9, 0), PAL.pink)
	b:Box(V3(5, 2.2, 2.4), CF(0, 3.5, 0), PAL.glass, M.Glass, { t = 0.75 })
	b:Box(V3(5.1, 0.2, 2.5), CF(0, 4.7, 0), PAL.white)
	b:Box(V3(4.8, 0.08, 2.2), CF(0, 3.55, 0), PAL.white, M.Glass, { t = 0.5, solid = false })
	local cakes = { { PAL.tea, PAL.cream }, { rgb(90, 55, 35), rgb(120, 75, 45) }, { PAL.pink, PAL.white } }
	for i, x in { -1.6, 0, 1.6 } do
		local c = cakes[i]
		b:Cyl(0.3, 1.1, CF(x, 2.55, 0), c[2], nil, { solid = false })
		b:Cyl(0.3, 1.1, CF(x, 2.85, 0), c[1], nil, { solid = false })
		b:Cyl(0.12, 1.14, CF(x, 3.05, 0), PAL.white, nil, { solid = false })
		b:Ball(0.2, CF(x, 3.2, 0), PAL.red, nil, { solid = false })
	end
	for i, x in { -1.8, -0.6, 0.6, 1.8 } do
		local c = cakes[(i - 1) % 3 + 1]
		b:Wedge(V3(0.5, 0.55, 0.8), CF(x, 3.87, 0) * ANG(0, rad(180), 0), c[1], nil, { solid = false })
	end
	local top = b:Box(V3(4.6, 0.1, 0.1), CF(0, 4.55, -0.9), PAL.white, M.Neon, { solid = false })
	b:Light(top, PAL.white, 6, 0.5)
	-- price tags + cake stand under a glass dome on top
	for _, x in { -1.6, 0, 1.6 } do
		local tag = b:Box(V3(0.5, 0.25, 0.02), CF(x, 2.5, -1.21), PAL.white, nil, { solid = false })
		b:Text(tag, FACE.Front, "฿45", { color = PAL.black })
	end
	b:Cyl(0.1, 1.4, CF(1.2, 4.85, 0), PAL.white, nil, { solid = false })
	b:Cyl(0.4, 0.2, CF(1.2, 4.95, 0), PAL.white, nil, { solid = false })
	b:Cyl(0.5, 1.0, CF(1.2, 5.4, 0), PAL.pink, nil, { solid = false })
	b:Ellipsoid(V3(1.3, 1.6, 1.3), CF(1.2, 5.3, 0), PAL.white, M.Glass, { t = 0.6 })
	b:Ball(0.2, CF(1.2, 6.15, 0), PAL.white, M.Glass, { solid = false })
	-- cake slices on plates, doily under each cake, cake server, mirrored back, bakery sign on top
	for _, x in { -1.6, 0, 1.6 } do
		b:Cyl(0.04, 1.35, CF(x, 2.39, 0), PAL.white, nil, { solid = false })
	end
	for i, x in { -1.8, -0.6, 0.6, 1.8 } do
		b:Cyl(0.05, 0.75, CF(x, 3.62, 0), PAL.white, nil, { solid = false })
		b:Ball(0.14, CF(x, 4.18, 0.1), if i % 2 == 0 then PAL.red else PAL.leaf, nil, { solid = false })
	end
	b:Box(V3(4.8, 1.9, 0.05), CF(0, 3.5, 1.15), PAL.white, M.Glass, { refl = 0.35, solid = false })
	b:Rod(V3(-2.3, 2.45, -0.4), V3(-1.9, 2.5, 0.3), 0.1, PAL.steel, M.Metal)
	local sign = b:Box(V3(2.4, 0.6, 0.15), CF(-1.2, 5.15, 0), PAL.pink)
	b:Text(sign, FACE.Front, "CAKES", { color = PAL.white })
end

Build.L24 = function(b) -- flower-wall photo corner
	b:Box(V3(8, 7, 0.5), CF(0, 3.5, 3), PAL.leafDark, M.Grass)
	local rand = seeded(24)
	local colors = { PAL.pink, PAL.white, PAL.tea, PAL.yellow, rgb(255, 110, 150) }
	for i = 1, 46 do
		local x, y = -3.7 + rand() * 7.4, 0.4 + rand() * 6.2
		if not (y > 3.7 and y < 5.4 and math.abs(x) < 3.1) then
			b:Ball(0.35 + rand() * 0.35, CF(x, y, 2.72), colors[i % #colors + 1], nil, { solid = false })
		end
	end
	local sign = b:Box(V3(6, 1.6, 0.05), CF(0, 4.55, 2.7), PAL.white, nil, { t = 1, solid = false })
	b:Text(sign, FACE.Front, "THAI TEA LOVE ♥", { color = rgb(255, 120, 170), glow = true })
	b:Box(V3(4, 0.35, 1.4), CF(0, 1.5, 1.4), PAL.woodLight, M.Wood)
	b:Box(V3(4, 1.2, 0.2), CF(0, 2.3, 2.05), PAL.woodLight, M.Wood)
	b:Legs(3.5, 1.1, 1.35, 0.2, CF(0, 0, 1.4), PAL.woodDark)
	b:Plant(CF(-3.5, 0, 0.8), 2.2)
	b:Plant(CF(3.5, 0, 0.8), 2.2)
	b:Box(V3(8, 0.06, 4), CF(0, 0.03, 0.8), PAL.pink, M.Fabric, { solid = false })
	-- ring light
	b:Cyl(4, 0.15, CF(2.2, 2, -2.6), PAL.black)
	local ring = b:HCyl(0.15, 1.4, CF(2.2, 4.4, -2.6) * ANG(0, rad(90), 0), PAL.white, M.Neon, { solid = false })
	b:Light(ring, PAL.white, 8, 0.6)
	-- balloon cluster + hanging picture frame prop
	for i, spec in { { -3.2, 6.8, PAL.pink }, { -2.6, 7.4, PAL.white }, { -3.7, 7.6, PAL.tea } } do
		b:Ellipsoid(V3(0.9, 1.1, 0.9), CF(spec[1], spec[2], 1.6), spec[3], nil, { t = 0.05 })
		b:Rod(V3(spec[1], spec[2] - 0.55, 1.6), V3(-3.5, 1.3, 0.8), 0.03, PAL.white)
	end
	local frame = CF(2.2, 4.4, 1.8)
	for _, spec in { { V3(2.4, 0.15, 0.1), CF(0, 1, 0) }, { V3(2.4, 0.15, 0.1), CF(0, -1, 0) }, { V3(0.15, 2.1, 0.1), CF(1.15, 0, 0) }, { V3(0.15, 2.1, 0.1), CF(-1.15, 0, 0) } } do
		b:Box(spec[1], frame * spec[2], PAL.gold, M.Metal, { solid = false })
	end
end

Build.L25 = function(b) -- floor air conditioner + outdoor unit
	b:Box(V3(1.6, 5.5, 1.2), CF(0, 2.75, 0), PAL.white)
	for i = 0, 5 do
		b:Box(V3(1.3, 0.08, 0.05), CF(0, 4.2 + i * 0.16, -0.61), PAL.steelDark, nil, { solid = false })
	end
	local display = b:Box(V3(0.55, 0.3, 0.03), CF(0, 3.7, -0.61), rgb(70, 170, 255), M.Neon, { solid = false })
	b:Text(display, FACE.Front, "25°", { color = PAL.white })
	b:Box(V3(1.3, 1.2, 0.03), CF(0, 1.0, -0.61), PAL.steel, nil, { solid = false })
	b:Box(V3(2.4, 2.2, 1.2), CF(0.4, 1.1, 2.3), PAL.steel, M.Metal)
	b:HCyl(0.1, 1.7, CF(0.1, 1.1, 1.66) * ANG(0, rad(90), 0), PAL.black, nil, { solid = false })
	b:HCyl(0.12, 0.4, CF(0.1, 1.1, 1.64) * ANG(0, rad(90), 0), PAL.steelDark, nil, { solid = false })
	b:Tube(V3(0, 0.8, 0.6), V3(0, 0.8, 1.7), 0.15, rgb(190, 120, 70), M.Metal)
	-- vertical louvers, nameplate, outdoor unit fins
	for i = -1, 1 do
		b:Box(V3(0.05, 0.9, 0.08), CF(i * 0.4, 4.6, -0.63), PAL.white, nil, { solid = false })
	end
	local plate = b:Box(V3(0.8, 0.25, 0.02), CF(0, 5.3, -0.61), PAL.steel, nil, { solid = false })
	b:Text(plate, FACE.Front, "COOL", { color = PAL.blue })
	for i = 0, 5 do
		b:Box(V3(0.05, 1.8, 0.05), CF(1.2, 1.1, 1.72 + i * 0.12) * ANG(0, rad(90), 0), PAL.steelDark, nil, { solid = false })
	end
	-- front grille slats, side vents, remote on a wall clip, condensate pipe, rubber feet
	for i = 0, 7 do
		b:Box(V3(1.2, 0.05, 0.04), CF(0, 0.5 + i * 0.13, -0.63), PAL.steelDark, nil, { solid = false })
	end
	for i = 0, 4 do
		b:Box(V3(0.04, 0.05, 0.9), CF(0.81, 3.0 + i * 0.2, 0), PAL.steelDark, nil, { solid = false })
	end
	b:Box(V3(0.3, 0.6, 0.12), CF(-1.1, 3.2, -0.2), PAL.white, nil, { solid = false })
	b:Box(V3(0.2, 0.15, 0.02), CF(-1.1, 3.35, -0.27), rgb(70, 170, 255), M.Neon, { solid = false })
	b:Tube(V3(-0.5, 0.2, 0.62), V3(-0.5, 0.2, 1.8), 0.1, PAL.white)
	for _, x in { -0.6, 0.6 } do
		b:Box(V3(0.3, 0.12, 0.9), CF(x, 0.06, 0), PAL.black, nil, { solid = false })
	end
	for _, x in { -0.6, 1.4 } do
		b:Box(V3(0.25, 0.25, 1.3), CF(x, 0.12, 2.3), PAL.black, nil, { solid = false })
	end
end

Build.L26 = function(b) -- tea leaf shelf
	for _, x in { -3, 3 } do
		b:Box(V3(0.3, 7, 1.6), CF(x, 3.5, 0), PAL.woodDark, M.Wood)
	end
	b:Box(V3(6.3, 0.3, 1.6), CF(0, 7, 0), PAL.woodDark, M.Wood)
	b:Box(V3(6, 7, 0.1), CF(0, 3.5, 0.75), PAL.wood, M.WoodPlanks)
	local leaves = { PAL.teaDark, PAL.leafDark, rgb(60, 40, 30), PAL.leaf }
	for s, y in { 0.2, 1.9, 3.6, 5.3 } do
		b:Box(V3(5.7, 0.2, 1.5), CF(0, y, 0), PAL.wood, M.Wood)
		for k = 1, 4 do
			local x = -2.1 + (k - 1) * 1.4
			if (k + s) % 2 == 0 then
				b:Cyl(1.1, 0.8, CF(x, y + 0.65, -0.1), PAL.white, M.Glass, { t = 0.5, solid = false })
				b:Cyl(0.7, 0.7, CF(x, y + 0.45, -0.1), leaves[(k + s) % 4 + 1], nil, { solid = false })
				b:Cyl(0.15, 0.85, CF(x, y + 1.25, -0.1), PAL.woodDark, nil, { solid = false })
			else
				local box = b:Box(V3(0.9, 1.2, 0.8), CF(x, y + 0.7, -0.1), if s % 2 == 0 then PAL.tea else PAL.green, nil, { solid = false })
				b:Box(V3(0.7, 0.4, 0.02), CF(x, y + 0.75, -0.51), PAL.cream, nil, { solid = false })
				box.Name = "TeaBox"
			end
		end
	end
	local sign = b:Box(V3(5, 0.9, 0.2), CF(0, 7.7, 0), PAL.green)
	b:Text(sign, FACE.Front, "PREMIUM TEA LEAVES", { color = PAL.cream })
	-- rolling ladder + tasting table
	for _, x in { 2.2, 3.2 } do
		b:Rod(V3(x, 0, -1.4), V3(x, 6.8, -0.9), 0.15, PAL.woodDark, M.Wood)
	end
	for i = 1, 6 do
		b:Box(V3(1.0, 0.1, 0.12), CF(2.7, i * 1.0, -1.4 + i * 0.075), PAL.woodDark, M.Wood, { solid = false })
	end
	b:Box(V3(2.6, 0.15, 1.2), CF(-1.4, 2.8, -2.2), PAL.woodLight, M.Wood)
	b:Legs(2.2, 0.9, 2.75, 0.15, CF(-1.4, 0, -2.2), PAL.woodDark)
	for i = 0, 2 do
		b:Cyl(0.2, 0.6, CF(-2.2 + i * 0.8, 2.97, -2.2), PAL.white, nil, { solid = false })
		b:Cyl(0.05, 0.45, CF(-2.2 + i * 0.8, 3.08, -2.2), ({ PAL.teaDark, PAL.leafDark, PAL.pearl })[i + 1], nil, { solid = false })
	end
end

Build.L27 = function(b) -- show bar + pendant lamps + back counter
	b:Box(V3(17.8, 0.4, 3.3), CF(0, 0.2, 0.1), PAL.black)
	b:Box(V3(18, 2.9, 3.4), CF(0, 1.85, 0.1), PAL.tea)
	b:Box(V3(18.4, 0.25, 3.8), CF(0, 3.425, 0), PAL.white, M.Marble)
	for i = 0, 23 do
		local x = -8.6 + i * 0.75
		if math.abs(x) > 3.3 then
			b:Box(V3(0.35, 2.6, 0.1), CF(x, 1.85, -1.66), PAL.woodLight, M.Wood, { solid = false })
		end
	end
	local logo = b:Box(V3(6, 1.6, 0.15), CF(0, 2.0, -1.72), PAL.green)
	b:Text(logo, FACE.Front, "THAI TEA BAR", { color = PAL.cream })
	-- back counter
	b:Box(V3(16, 3.4, 2), CF(0, 1.7, 6.6), PAL.steel, M.Metal)
	for i, x in { -5.5, -3.8, -2.1 } do
		b:Cyl(1.6, 0.9, CF(x, 4.2, 6.6), PAL.steel, M.Metal)
		b:Ellipsoid(V3(0.9, 0.4, 0.9), CF(x, 5.0, 6.6), PAL.steelDark, M.Metal)
		b:Box(V3(0.2, 0.2, 0.3), CF(x, 3.7, 6.0), if i == 2 then PAL.green else PAL.tea)
	end
	for i = 0, 5 do
		b:Cyl(0.6, 0.45, CF(1 + i * 0.8, 3.7, 6.3), PAL.steel, M.Metal, { solid = false })
	end
	b:Box(V3(2, 0.1, 1.2), CF(6.4, 3.45, 6.6), PAL.steelDark, M.Metal)
	-- lamp frame
	for _, x in { -9.8, 9.8 } do
		b:Box(V3(0.4, 10, 0.4), CF(x, 5, 1.6), PAL.black, M.Metal)
	end
	b:Box(V3(20, 0.4, 0.4), CF(0, 10, 1.6), PAL.black, M.Metal)
	for _, x in { -5, 0, 5 } do
		b:Box(V3(0.06, 1.8, 0.06), CF(x, 8.9, 1.6), PAL.black, nil, { solid = false })
		b:Cyl(0.7, 1.3, CF(x, 7.8, 1.6), PAL.black, M.Metal)
		local bulb = b:Ball(0.55, CF(x, 7.4, 1.6), PAL.warm, M.Neon, { solid = false })
		b:Light(bulb, PAL.warm, 12, 0.9)
	end
	-- bar stools, display glasses, shaker row
	for i = 0, 4 do
		local x = -7 + i * 3.5
		b:Cyl(0.15, 1.2, CF(x, 0.08, -3.0), PAL.black, M.Metal)
		b:Cyl(2.5, 0.2, CF(x, 1.35, -3.0), PAL.black, M.Metal)
		b:Cyl(0.3, 1.3, CF(x, 2.75, -3.0), PAL.woodDark, M.Wood)
	end
	for i = 0, 2 do
		b:TeaCup(CF(-7.5 + i * 0.9, 3.55, -0.9), 1.1, if i == 1 then rgb(120, 180, 90) else nil)
	end
	for i = 0, 3 do
		b:Cyl(0.9, 0.4, CF(5.5 + i * 0.6, 4.0, 1.2), PAL.steel, M.Metal, { solid = false })
		b:Cyl(0.25, 0.3, CF(5.5 + i * 0.6, 4.55, 1.2), PAL.steelDark, M.Metal, { solid = false })
	end
end

Build.L28 = function(b) -- brick wall + neon cup sign
	b:Box(V3(16, 9, 1), CF(0, 4.5, 0), rgb(165, 85, 62), M.Brick)
	b:Box(V3(16.2, 0.4, 1.2), CF(0, 9.1, 0), PAL.woodDark, M.Wood)
	local z = -0.6
	local neon = PAL.tea
	local function tube(a: Vector3, c: Vector3, color: Color3?)
		b:Rod(a, c, 0.22, color or neon, M.Neon)
	end
	tube(V3(-1.1, 3, z), V3(-1.5, 6.4, z))
	tube(V3(1.1, 3, z), V3(1.5, 6.4, z))
	tube(V3(-1.1, 3, z), V3(1.1, 3, z))
	tube(V3(-1.7, 6.4, z), V3(1.7, 6.4, z))
	local arc = { V3(-1.6, 6.4, z), V3(-1.1, 7.0, z), V3(0, 7.25, z), V3(1.1, 7.0, z), V3(1.6, 6.4, z) }
	for i = 1, #arc - 1 do
		tube(arc[i], arc[i + 1], PAL.white)
	end
	tube(V3(0.3, 7.2, z), V3(0.9, 8.5, z), rgb(80, 230, 130))
	tube(V3(-1.3, 5.2, z), V3(1.3, 5.2, z), PAL.white)
	for _, p in { V3(-0.5, 3.6, z), V3(0.3, 3.9, z), V3(0.6, 3.4, z), V3(-0.2, 4.2, z) } do
		b:Ball(0.35, CF(p), PAL.white, M.Neon, { solid = false })
	end
	local left = b:Box(V3(5, 2.2, 0.05), CF(-5.2, 5, -0.53), PAL.white, nil, { t = 1, solid = false })
	b:Text(left, FACE.Front, "THAI TEA", { color = rgb(255, 170, 90), glow = true })
	local right = b:Box(V3(5, 2.2, 0.05), CF(5.2, 5, -0.53), PAL.white, nil, { t = 1, solid = false })
	b:Text(right, FACE.Front, "THAI TEA", { color = rgb(120, 240, 170), glow = true })
	local glow = b:Box(V3(0.1, 0.1, 0.1), CF(0, 5, -1.5), neon, nil, { t = 1, solid = false })
	b:Light(glow, neon, 14, 1.2)
	-- floating shelves with plants and jars + wall sconces
	for _, x in { -5.2, 5.2 } do
		b:Box(V3(4, 0.2, 0.8), CF(x, 2.4, -0.9), PAL.woodDark, M.Wood)
		b:Cyl(0.6, 0.5, CF(x - 1.2, 2.8, -0.9), PAL.white)
		b:Ellipsoid(V3(0.8, 0.8, 0.8), CF(x - 1.2, 3.4, -0.9), PAL.leaf)
		for i = 0, 1 do
			b:Cyl(0.7, 0.45, CF(x + 0.3 + i * 0.7, 2.85, -0.9), PAL.white, M.Glass, { t = 0.4, solid = false })
			b:Cyl(0.4, 0.4, CF(x + 0.3 + i * 0.7, 2.7, -0.9), PAL.teaDark, nil, { solid = false })
		end
		b:Box(V3(0.3, 0.6, 0.3), CF(x + (if x < 0 then 2.2 else -2.2), 7.6, -0.65), PAL.black, M.Metal, { solid = false })
		b:Ball(0.35, CF(x + (if x < 0 then 2.2 else -2.2), 7.3, -0.75), PAL.warm, M.Neon, { solid = false })
	end
end

-- Tier 4 ---------------------------------------------------------------

Build.L29 = function(b) -- central kitchen (walk-in: range, tea pots, hood, prep tables, chefs)
	local W, D, H = 20, 16, 13
	b:Shell(CF(), {
		w = W, d = D, h = H, wall = rgb(236, 232, 224), wallMat = M.Concrete,
		floor = rgb(150, 72, 55), floorMat = M.Slate, roofColor = rgb(205, 205, 205),
		openings = {
			{ side = "Front", x = -4.5, y = 0, w = 7, h = 7 },
			{ side = "Front", x = 5, y = 0, w = 3.6, h = 7.2 },
			{ side = "Left", x = -3, y = 3.5, w = 4, h = 2.5, glass = true },
			{ side = "Left", x = 3, y = 3.5, w = 4, h = 2.5, glass = true },
			{ side = "Right", x = -3, y = 3.5, w = 4, h = 2.5, glass = true },
			{ side = "Right", x = 3, y = 3.5, w = 4, h = 2.5, glass = true },
		},
	})
	-- exterior (upper-floor windows on the tall walls)
	b:UpperWindows(CF(), W, D, { "Front" }, { -7.5, -2.5, 2.5, 7.5 }, 9.2, 2.6)
	b:UpperWindows(CF(), W, D, { "Left", "Right" }, { -5, 0, 5 }, 9.2, 2.6)
	local band = b:Box(V3(W + 0.4, 0.9, D + 0.4), CF(0, H + 1.05, 0), PAL.tea)
	b:Text(band, FACE.Front, "CENTRAL KITCHEN", { color = PAL.white, region = { 0.15, 0.05, 0.7, 0.9 } })
	b:HCyl(7.4, 1, CF(-4.5, 7.5, -D / 2 - 0.5), PAL.steelDark, M.Metal)
	for _, x in { -8.1, -0.9 } do
		b:Box(V3(0.25, 7, 0.3), CF(x, 3.5, -D / 2 - 0.15), PAL.steelDark, M.Metal, { solid = false })
	end
	b:Box(V3(4.4, 0.2, 1.6), CF(5, 7.5, -D / 2 - 0.8), PAL.tea)
	local lamp = b:Box(V3(0.8, 0.3, 0.3), CF(5, 7.2, -D / 2 - 0.2), PAL.warm, M.Neon, { solid = false })
	b:Light(lamp, PAL.warm, 10, 0.6)
	for _, x in { -4, 1 } do
		b:Cyl(1, 1.6, CF(x, H + 2, 2), PAL.steel, M.Metal)
		b:Cyl(0.2, 2, CF(x, H + 2.6, 2), PAL.steelDark, M.Metal)
	end
	b:Cyl(3, 0.8, CF(6, H + 3, 4), PAL.steelDark, M.Metal)
	for i, d in { 1.2, 1.6, 2.0 } do
		b:Ball(d, CF(6 + i * 0.2, H + 4.6 + i * 0.9, 4), PAL.white, nil, { t = 0.6, solid = false, name = if i == 1 then "Steam" else "SteamPuff" })
	end
	b:Box(V3(3, 1.4, 2), CF(-6, H + 2.2, -3.5), PAL.steel, M.Metal)

	-- cooking line along the back wall
	b:Box(V3(12, 3, 2.6), CF(-2, 1.7, 6.1), PAL.steel, M.Metal)
	for _, x in { -6, -2, 2 } do
		b:Box(V3(3.2, 1.6, 0.08), CF(x, 1.4, 4.78), PAL.steelDark, M.Metal, { solid = false })
		b:Box(V3(2, 0.12, 0.12), CF(x, 2.35, 4.7), PAL.steel, M.Metal, { solid = false })
	end
	for i, x in { -6.5, -3.5, -0.5, 2.5 } do
		b:Cyl(0.15, 1.8, CF(x, 3.28, 6.1), PAL.black)
		b:Cyl(2, 2.2, CF(x, 4.35, 6.1), PAL.steel, M.Metal)
		b:Cyl(0.12, 2.3, CF(x, 5.3, 6.1), PAL.steelDark, M.Metal)
		b:Cyl(0.05, 2.0, CF(x, 5.22, 6.1), if i == 4 then PAL.pearl else PAL.teaDark)
		b:Ball(1, CF(x + 0.2, 6.1, 6.1), PAL.white, nil, { t = 0.6, solid = false, name = "Steam" })
	end
	b:Box(V3(12, 3.5, 0.1), CF(-2, 5, 7.35), PAL.white, M.Marble, { solid = false })
	b:Box(V3(13, 1.2, 3), CF(-2, 7.8, 6.0), PAL.steel, M.Metal)
	b:Box(V3(2.4, 0.8, 2), CF(-2, 8.6, 6.3), PAL.steel, M.Metal)
	b:Box(V3(1.8, H - 9, 1.6), CF(-2, (9 + H) / 2, 6.3), PAL.steel, M.Metal) -- duct up to the high ceiling
	b:Box(V3(11, 0.1, 0.4), CF(-2, 7.15, 4.7), PAL.warm, M.Neon, { solid = false })
	b:Box(V3(4, 0.05, 1.6), CF(-2, 0.23, 3.9), PAL.black, nil, { solid = false })

	-- sink
	b:Box(V3(4, 3, 2.4), CF(6.5, 1.7, 6.2), PAL.steel, M.Metal)
	b:Box(V3(3, 0.1, 1.6), CF(6.5, 3.22, 6.1), PAL.steelDark, M.Metal, { solid = false })
	b:Cyl(1, 0.2, CF(6.5, 3.7, 7.0), PAL.steel, M.Metal)
	b:Tube(V3(6.5, 4.2, 7.0), V3(6.5, 4.2, 6.3), 0.15, PAL.steel, M.Metal)
	for i = 0, 3 do
		b:Box(V3(0.1, 0.9, 0.9), CF(5.1 + i * 0.25, 3.7, 5.6), PAL.white, nil, { solid = false })
	end

	-- ingredient shelf (left wall)
	local shelf = CF(-W / 2 + 1.5, 0.2, -1) * ANG(0, rad(90), 0)
	b:Shelf(shelf, 8, 1.6, { 1, 2.8, 4.6, 6.4 }, PAL.steel, function(level, y)
		for k = 1, 4 do
			local at = shelf * CF(-3 + (k - 1) * 2, y, 0)
			if (k + level) % 2 == 0 then
				local sack = b:Box(V3(1.4, 1.2, 1.2), at * CF(0, 0.6, 0), PAL.cream, M.Fabric, { solid = false })
				sack.Name = "Sack"
			else
				b:Cyl(1.2, 1.0, at * CF(0, 0.6, 0), PAL.white, M.Glass, { t = 0.5, solid = false })
				b:Cyl(0.8, 0.9, at * CF(0, 0.45, 0), if k == 1 then PAL.teaDark else PAL.leafDark, nil, { solid = false })
			end
		end
	end)
	b:HCyl(0.1, 1.2, CF(-W / 2 + 0.65, 6.8, 5), PAL.white, nil, { solid = false })

	-- 2 prep tables
	for _, x in { -3, 4 } do
		b:Box(V3(6, 0.2, 3), CF(x, 3.1, -1.5), PAL.steel, M.Metal, { solid = true })
		b:Legs(5.6, 2.6, 3, 0.2, CF(x, 0.2, -1.5), PAL.steelDark)
		b:Box(V3(5.6, 0.1, 2.6), CF(x, 1.0, -1.5), PAL.steel, M.Metal, { solid = false })
	end
	b:Box(V3(1.6, 0.1, 1), CF(-4.5, 3.25, -1.5), PAL.woodLight, M.Wood, { solid = false })
	for i = 0, 2 do
		b:Cyl(0.35, 0.9, CF(-2.6 + i * 1, 3.38, -1.8), PAL.white, nil, { solid = false })
		b:Cyl(0.1, 0.75, CF(-2.6 + i * 1, 3.5, -1.8), ({ PAL.teaDark, PAL.leafDark, PAL.pearl })[i + 1], nil, { solid = false })
	end
	b:Cyl(1, 0.7, CF(-1, 3.7, -0.8), PAL.steel, M.Metal, { solid = false })
	for i = 0, 5 do
		b:TeaCup(CF(1.8 + i * 0.9, 3.2, -2.3), 0.9, if i % 3 == 2 then rgb(120, 180, 90) else nil)
	end
	for i = 0, 2 do
		b:Cyl(0.5, 0.4, CF(5.4 + i * 0.5, 3.45, -0.8), if i == 1 then PAL.white else PAL.red, nil, { solid = false })
	end

	-- 2 chefs
	local chef1 = b:Person(CF(-4, 0.2, 3.3) * ANG(0, rad(180), 0), { shirt = PAL.white, apron = PAL.white, chefHat = true, right = { 75, 10 }, left = { 40, 0 } })
	b:Rod(chef1.right, V3(-3.8, 5.2, 6.1), 0.12, PAL.woodDark, M.Wood)
	b:Person(CF(4, 0.2, 0.8), { shirt = PAL.white, apron = PAL.tea, chefHat = true, right = { 60, 25 }, left = { 60, 25 } })

	-- ceiling lights
	for i, z in { -4, 0.5, 4.5 } do
		local strip = b:Box(V3(8, 0.15, 0.7), CF(0, H - 0.1, z), PAL.white, M.Neon, { solid = false })
		if i == 2 then
			b:Light(strip, PAL.white, 18, 0.8)
		end
	end
end

Build.L30 = function(b) -- delivery van (nose toward the plaza)
	b:Box(V3(4.6, 0.8, 10.6), CF(0, 1.3, 0), PAL.black)
	b:Box(V3(5, 4.6, 7), CF(0, 4.0, 1.8), PAL.white)
	b:Box(V3(5.04, 0.6, 7.04), CF(0, 2.5, 1.8), PAL.tea)
	b:Box(V3(5, 3.2, 3.4), CF(0, 3.3, -3.5), PAL.tea)
	b:Box(V3(5, 1.4, 1.8), CF(0, 5.6, -2.7), PAL.tea)
	b:Wedge(V3(4.8, 1.4, 1.6), CF(0, 5.6, -4.4), PAL.glass, M.Glass, { t = 0.25 })
	for _, x in { -2.52, 2.52 } do
		b:Box(V3(0.05, 1.1, 1.4), CF(x, 5.3, -3.2), PAL.glass, M.Glass, { t = 0.25, solid = false })
		b:Box(V3(0.3, 0.5, 0.15), CF(x * 1.08, 5.0, -4.3), PAL.black, nil, { solid = false })
	end
	for _, x in { -1.7, 1.7 } do
		b:Box(V3(0.8, 0.45, 0.1), CF(x, 2.6, -5.25), PAL.warm, M.Neon, { solid = false })
	end
	b:Box(V3(2.2, 0.6, 0.1), CF(0, 2.5, -5.22), PAL.black, nil, { solid = false })
	b:Box(V3(5.1, 0.5, 0.4), CF(0, 1.5, -5.3), PAL.black)
	for _, x in { -2.35, 2.35 } do
		for _, z in { -3.3, 3.4 } do
			b:HCyl(0.8, 1.8, CF(x, 0.9, z), PAL.black)
			b:HCyl(0.85, 0.8, CF(x, 0.9, z), PAL.steel, M.Metal, { solid = false })
		end
	end
	for _, face in { FACE.Left, FACE.Right } do
		local panel = b:Box(V3(5.02, 2.4, 5.6), CF(0, 4.5, 1.8), PAL.white, nil, { t = 1, solid = false })
		b:Text(panel, face, "THAI TEA DELIVERY", { color = PAL.tea })
	end
	b:Box(V3(0.06, 4.2, 0.06), CF(0, 4.0, 5.32), PAL.steelDark, nil, { solid = false })
	b:Box(V3(4.8, 0.4, 0.3), CF(0, 1.5, 5.4), PAL.black)
	for _, x in { -2, 2 } do
		b:Box(V3(0.5, 0.4, 0.1), CF(x, 2.0, 5.32), PAL.red, M.Neon, { solid = false })
	end
	-- license plates, wipers, door handles, roof beacon, fuel cap, mud flaps
	for _, z in { -5.52, 5.63 } do
		local plate = b:Box(V3(1.6, 0.5, 0.05), CF(0, 1.5, z), PAL.white, nil, { solid = false })
		b:Text(plate, if z < 0 then FACE.Front else FACE.Back, "TEA 88", { color = PAL.black })
	end
	for _, x in { -1.1, 1.1 } do
		b:Box(V3(1.4, 0.08, 0.08), CF(x, 4.85, -5.0) * ANG(rad(-40), 0, rad(if x < 0 then 12 else -12)), PAL.black, nil, { solid = false })
	end
	for _, x in { -2.53, 2.53 } do
		b:Box(V3(0.08, 0.15, 0.5), CF(x, 3.8, -2.4), PAL.black, nil, { solid = false })
		b:Box(V3(0.06, 1.0, 0.8), CF(x, 0.9, 4.5), PAL.black, nil, { solid = false })
	end
	b:Box(V3(1.4, 0.3, 0.6), CF(0, 6.35, -2.8), PAL.black, nil, { solid = false })
	b:Box(V3(1.2, 0.25, 0.4), CF(0, 6.6, -2.8), rgb(255, 150, 40), M.Neon, { solid = false })
	b:HCyl(0.05, 0.35, CF(-2.53, 2.2, 1.0), PAL.steelDark, M.Metal, { solid = false })
	-- rounded roof edges, wheel arches, 5-spoke hubs, grille slats, bumper corners, side mirrors
	for _, x in { -2.3, 2.3 } do
		b:HCyl(7.0, 0.6, CF(x * 0.96, 6.12, 1.8) * ANG(0, rad(90), 0), PAL.white)
		for _, z in { -3.3, 3.4 } do
			b:Ellipsoid(V3(0.4, 2.3, 2.6), CF(x * 1.04, 1.4, z), PAL.black)
			for k = 0, 4 do
				b:Box(V3(0.05, 0.12, 0.6), CF(x * 1.2, 0.9, z) * ANG(rad(72 * k), 0, 0) * CF(0, 0, 0.25), PAL.steelDark, M.Metal, { solid = false })
			end
		end
		b:Box(V3(0.12, 0.4, 0.55), CF(x * 1.17, 4.95, -4.3), PAL.glass, M.Glass, { t = 0.1, solid = false })
	end
	for i = 0, 3 do
		b:Box(V3(2.0, 0.07, 0.06), CF(0, 2.28 + i * 0.13, -5.29), PAL.steelDark, M.Metal, { solid = false })
	end
	b:Ellipsoid(V3(0.7, 0.3, 0.12), CF(0, 3.0, -5.24), PAL.white)
	for _, x in { -2.5, 2.5 } do
		b:Cyl(0.5, 0.5, CF(x, 1.5, -5.3), PAL.black, nil, { solid = false })
	end
	-- sliding side door seams + handle, green livery stripe on both sides
	for _, x in { -2.53, 2.53 } do
		b:Box(V3(0.04, 3.6, 0.06), CF(x, 4.1, -0.5), PAL.steel, nil, { solid = false })
		b:Box(V3(0.04, 3.6, 0.06), CF(x, 4.1, 2.3), PAL.steel, nil, { solid = false })
		b:Box(V3(0.06, 0.15, 0.6), CF(x * 1.01, 3.9, 2.0), PAL.black, nil, { solid = false })
		b:Box(V3(0.04, 0.25, 7.0), CF(x, 3.1, 1.8), PAL.green, nil, { solid = false })
	end
	-- roof rack with tea crates, rear door handles
	for _, x in { -1.8, 1.8 } do
		b:Box(V3(0.12, 0.15, 5.4), CF(x, 6.5, 2.3), PAL.steelDark, M.Metal, { solid = false })
	end
	for i = 0, 2 do
		local crate = b:Box(V3(1.5, 0.8, 1.3), CF(-0.9 + (i % 2) * 1.8, 7.0, 0.6 + i * 1.6), PAL.woodLight, M.WoodPlanks, { solid = false })
		if i == 1 then
			b:Text(crate, FACE.Front, "TEA", { color = PAL.teaDark })
		end
	end
	for _, x in { -0.3, 0.3 } do
		b:Box(V3(0.12, 0.5, 0.08), CF(x, 3.9, 5.34), PAL.steel, M.Metal, { solid = false })
	end
end

Build.L31 = function(b) -- cup conveyor
	for _, x in { -6, -2, 2, 6 } do
		for _, z in { -0.9, 0.9 } do
			b:Box(V3(0.3, 2.6, 0.3), CF(x, 1.3, z), PAL.steelDark, M.Metal, { solid = false })
		end
	end
	for _, z in { -1, 1 } do
		b:Box(V3(14, 0.5, 0.2), CF(0, 2.8, z), PAL.steel, M.Metal)
		b:Box(V3(14, 0.08, 0.08), CF(0, 3.7, z * 0.95), PAL.steel, M.Metal, { solid = false })
	end
	b:Box(V3(14, 0.2, 1.8), CF(0, 2.9, 0), PAL.black)
	for _, x in { -7, 7 } do
		b:HCyl(1.9, 0.6, CF(x, 2.8, 0) * ANG(0, rad(90), 0), PAL.steelDark, M.Metal)
	end
	-- cups riding the belt: every part is named BeltCup so clients can slide them along X (EffectsClient)
	for i = 0, 8 do
		local x = -6 + i * 1.5
		b:Cyl(0.9, 0.45, CF(x, 3.45, 0), PAL.tea, nil, { name = "BeltCup" })
		b:Ellipsoid(V3(0.47, 0.25, 0.47), CF(x, 3.95, 0), PAL.white, M.Glass, { t = 0.3, name = "BeltCup" })
	end
	b:Box(V3(1.2, 1.2, 1.2), CF(7.4, 2.0, 1.5), PAL.steelDark, M.Metal)
	for _, z in { -1.1, 1.1 } do
		b:Box(V3(0.2, 2, 0.2), CF(-3, 3.9, z), PAL.steelDark, M.Metal, { solid = false })
	end
	b:Box(V3(0.4, 0.3, 2.4), CF(-3, 4.95, 0), PAL.steelDark, M.Metal)
	b:Box(V3(0.3, 0.1, 1.6), CF(-3, 4.75, 0), rgb(90, 230, 120), M.Neon, { solid = false })
	-- emergency stop, empty cup bin at the start, safety sign
	b:Box(V3(0.6, 0.8, 0.5), CF(-6.9, 3.4, -1.3), PAL.yellow)
	b:Cyl(0.2, 0.35, CF(-6.9, 3.9, -1.3), PAL.red)
	b:Box(V3(1.4, 1.2, 1.4), CF(-8.4, 0.8, 0), PAL.blue)
	for i = 0, 3 do
		b:Cyl(0.6, 0.45, CF(-8.7 + (i % 2) * 0.6, 1.65, -0.3 + math.floor(i / 2) * 0.6), PAL.white, M.Glass, { t = 0.4, solid = false })
	end
	local sign = b:Box(V3(1.4, 0.7, 0.05), CF(0, 1.5, -1.12), PAL.yellow, nil, { solid = false })
	b:Text(sign, FACE.Front, "KEEP HANDS CLEAR", { color = PAL.black })
	-- belt rollers visible under the edge, sealed lids with straws on the moving cups, output tray, control panel
	for i = 0, 13 do
		b:HCyl(1.9, 0.18, CF(-6.5 + i, 2.62, 0) * ANG(0, rad(90), 0), PAL.steel, M.Metal, { solid = false })
	end
	for i = 0, 8 do
		local x = -6 + i * 1.5
		b:Cyl(0.14, 0.47, CF(x, 3.45, 0), PAL.cream, nil, { solid = false, name = "BeltCup" })
		b:Rod(V3(x, 3.9, 0), V3(x + 0.1, 4.5, 0.05), 0.07, PAL.green, nil, { name = "BeltCup" })
	end
	b:Box(V3(1.6, 0.15, 2.2), CF(8.0, 2.75, 0), PAL.steel, M.Metal)
	for _, z in { -0.6, 0, 0.6 } do
		b:Cyl(0.9, 0.45, CF(8.2, 3.3, z), PAL.tea, nil, { solid = false })
	end
	local panel = b:Box(V3(0.8, 0.6, 0.1), CF(-6.9, 4.1, -1.3) * ANG(rad(-20), 0, 0), PAL.black, nil, { solid = false })
	b:Text(panel, FACE.Front, "240/min", { color = rgb(90, 230, 120), glow = true })
end

Build.L32 = function(b) -- auto brewer
	b:Box(V3(8.02, 0.3, 3.52), CF(0, 0.15, 0), PAL.yellow)
	b:Box(V3(8, 4.5, 3.5), CF(0, 2.55, 0), PAL.steel, M.Metal)
	b:Box(V3(8.02, 0.4, 3.52), CF(0, 4.3, 0), PAL.tea)
	local screen = b:Box(V3(2, 1.2, 0.1), CF(-2.4, 3, -1.8), rgb(40, 110, 220), M.Neon, { solid = false })
	b:Text(screen, FACE.Front, "AUTO BREW\n98%", { color = PAL.white })
	for i, c in { PAL.red, rgb(90, 220, 120), PAL.yellow } do
		b:Ball(0.35, CF(-0.9 + i * 0.5, 2.6, -1.78), c, M.Neon, { solid = false })
	end
	for _, x in { -2.5, 0, 2.5 } do
		b:Cyl(2.5, 1.6, CF(x, 6.05, 0), PAL.steel, M.Metal)
		b:Ellipsoid(V3(1.6, 0.7, 1.6), CF(x, 7.3, 0), PAL.steelDark, M.Metal)
		b:Box(V3(0.2, 1.8, 0.05), CF(x, 6.0, -0.81), PAL.tea, M.Glass, { t = 0.2, solid = false })
	end
	b:HCyl(7, 0.3, CF(0, 6.8, 0.9), rgb(190, 120, 70), M.Metal)
	b:Tube(V3(0, 4.8, -1.75), V3(0, 4.8, -7), 0.4, PAL.steel, M.Metal)
	b:Cyl(0.6, 0.5, CF(0, 4.45, -7), PAL.black)
	b:Rod(V3(0, 4.1, -7), V3(0, 3.95, -7), 0.1, PAL.tea, M.Glass)
	for _, x in { -3.6, 3.6 } do
		b:Box(V3(0.1, 0.8, 0.05), CF(x, 0.7, -1.77), PAL.black, nil, { solid = false })
	end
	-- pressure gauges, HOT labels, side ladder
	for _, x in { -2.5, 0, 2.5 } do
		b:HCyl(0.1, 0.5, CF(x, 5.2, -0.85) * ANG(0, rad(90), 0), PAL.white, nil, { solid = false })
		b:Box(V3(0.04, 0.2, 0.02), CF(x, 5.25, -0.91) * ANG(0, 0, rad(-30)), PAL.red, nil, { solid = false })
		local hot = b:Box(V3(0.8, 0.35, 0.02), CF(x, 3.7, -1.77), PAL.yellow, nil, { solid = false })
		b:Text(hot, FACE.Front, "HOT", { color = PAL.red })
	end
	for _, z in { -0.6, 0.6 } do
		b:Box(V3(0.12, 4.6, 0.12), CF(4.15, 2.3, z), PAL.yellow, M.Metal, { solid = false })
	end
	for i = 1, 5 do
		b:Box(V3(0.12, 0.1, 1.2), CF(4.15, i * 0.85, 0), PAL.yellow, M.Metal, { solid = false })
	end
	-- rivet rings round each tank, copper pipes between the tanks
	for _, x in { -2.5, 0, 2.5 } do
		for k = 0, 5 do
			b:Ball(0.12, CF(x, 4.95, 0) * ANG(0, rad(k * 60), 0) * CF(0, 0, -0.8), PAL.steelDark, M.Metal, { solid = false })
		end
		b:Cyl(0.3, 1.7, CF(x, 4.95, 0), PAL.steelDark, M.Metal, { solid = false })
	end
	for _, x in { -1.25, 1.25 } do
		b:HCyl(1.0, 0.25, CF(x, 7.0, 0), rgb(190, 120, 70), M.Metal, { solid = false })
		b:Tube(V3(x, 7.0, 0), V3(x, 7.6, 0), 0.22, rgb(190, 120, 70), M.Metal)
	end
end

Build.L33 = function(b) -- online order kiosk + rider motorbike
	b:Box(V3(2.4, 6, 1.4), CF(0, 3, 0), PAL.white)
	local head = b:Box(V3(2.6, 0.8, 1.6), CF(0, 6.3, 0), PAL.green)
	b:Text(head, FACE.Front, "ORDER ONLINE", { color = PAL.white })
	local screen = b:Box(V3(1.8, 2.8, 0.08), CF(0, 3.9, -0.72), rgb(40, 110, 220), M.Neon, { solid = false })
	b:Text(screen, FACE.Front, "SCAN\nTO ORDER", { color = PAL.white, region = { 0, 0, 1, 0.45 } })
	b:Box(V3(1.0, 1.0, 0.02), CF(0, 3.3, -0.77), PAL.white, nil, { solid = false })
	b:Box(V3(0.7, 0.7, 0.02), CF(0, 3.3, -0.79), PAL.black, nil, { solid = false })
	b:Box(V3(1.2, 0.15, 0.3), CF(0, 1.8, -0.8), PAL.black)
	-- delivery bag rack
	for _, x in { -3.4, -1.6 } do
		b:Box(V3(0.15, 3.4, 0.15), CF(x, 1.7, 0), PAL.steelDark, M.Metal, { solid = false })
	end
	for i, y in { 1.2, 2.8 } do
		b:Box(V3(2, 0.12, 1.2), CF(-2.5, y, 0), PAL.steel, M.Metal)
		b:Box(V3(0.7, 0.8, 0.5), CF(-3.0, y + 0.46, 0), if i == 1 then PAL.green else PAL.tea, M.Fabric, { solid = false })
		b:Box(V3(0.7, 0.8, 0.5), CF(-2.1, y + 0.46, 0.1), if i == 1 then PAL.tea else PAL.green, M.Fabric, { solid = false })
	end
	-- motorbike (facing the plaza)
	local bike = CF(3.4, 0, 0.6)
	for _, z in { -1.4, 1.4 } do
		b:HCyl(0.35, 1.3, bike * CF(0, 0.65, z), PAL.black)
		b:HCyl(0.4, 0.5, bike * CF(0, 0.65, z), PAL.steel, M.Metal, { solid = false })
	end
	b:Box(V3(0.6, 0.7, 2.2), bike * CF(0, 1.3, 0.1), PAL.red)
	b:Box(V3(0.6, 0.25, 1.2), bike * CF(0, 1.75, 0.5), PAL.black)
	b:Rod(V3(3.4, 0.65, -0.8), V3(3.4, 2.3, -0.6), 0.15, PAL.steelDark, M.Metal)
	b:Box(V3(1.4, 0.12, 0.12), bike * CF(0, 2.35, -1.2), PAL.black)
	b:Ball(0.35, bike * CF(0, 1.9, -1.45), PAL.warm, M.Neon, { solid = false })
	local delivery = b:Box(V3(1.4, 1.3, 1.3), bike * CF(0, 2.55, 1.5), PAL.green)
	b:Text(delivery, FACE.Back, "THAI TEA", { color = PAL.white })
	-- rider waiting with a phone, helmet, bike mirrors and plate
	local rider = b:Person(CF(1.9, 0, -1.6) * ANG(0, rad(-20), 0), { shirt = PAL.green, apron = PAL.green, pants = PAL.black, right = { 70, 25 }, left = { 20, 0 } })
	b:Box(V3(0.4, 0.6, 0.08), CF(rider.right) * CF(0, 0.2, 0) * ANG(rad(-30), 0, 0), PAL.black, nil, { solid = false })
	b:Ellipsoid(V3(1.5, 1.2, 1.6), CF(1.9, 5.2, -1.6), PAL.green)
	for _, x in { -0.75, 0.75 } do
		b:Rod(V3(3.4 + x * 0.9, 2.35, -0.6), V3(3.4 + x * 1.1, 2.9, -0.55), 0.06, PAL.black)
		b:Box(V3(0.3, 0.2, 0.05), CF(3.4 + x * 1.1, 2.95, -0.55), PAL.steel, M.Metal, { solid = false })
	end
	local plate = b:Box(V3(0.8, 0.4, 0.05), CF(3.4, 1.2, 2.25), PAL.white, nil, { solid = false })
	b:Text(plate, FACE.Back, "BKK 1", { color = PAL.black })
end

Build.L34 = function(b) -- cold room (walk-in: strip curtain, milk crate racks, ice, evaporator)
	local W, D, H = 14, 14, 13
	local ICE = rgb(190, 230, 250)
	b:Shell(CF(), {
		w = W, d = D, h = H, wall = rgb(234, 240, 246), wallMat = M.SmoothPlastic,
		floor = rgb(205, 220, 230), floorMat = M.Marble,
		openings = { { side = "Front", x = -2, y = 0, w = 4.2, h = 7.4 } },
	})
	b:Box(V3(W + 0.2, 0.8, D + 0.2), CF(0, H + 1.0, 0), PAL.blue)
	for _, x in { -4.35, 0.35 } do
		b:Box(V3(0.5, 7.8, 0.9), CF(x, 3.9, -D / 2 - 0.1), PAL.steel, M.Metal)
	end
	b:Box(V3(5.2, 0.5, 0.9), CF(-2, 7.65, -D / 2 - 0.1), PAL.steel, M.Metal)
	for i = 0, 7 do
		b:Box(V3(0.5, 7.2, 0.05), CF(-3.75 + i * 0.5, 3.8, -D / 2 + 0.5), PAL.glass, M.Glass, { t = 0.5, solid = false })
	end
	for _, x in { -5.5, 1.8, 3.6, 5.4 } do
		b:Box(V3(0.08, H - 0.6, 0.06), CF(x, (H - 0.6) / 2, -D / 2 - 0.03), rgb(200, 208, 216), nil, { solid = false })
	end
	local temp = b:Box(V3(1.8, 0.8, 0.1), CF(3.6, 5.4, -D / 2 - 0.05), PAL.black)
	b:Text(temp, FACE.Front, "-18°C", { color = rgb(255, 70, 70), glow = true })
	local sign = b:Box(V3(4.5, 0.9, 0.15), CF(3.6, 6.8, -D / 2 - 0.08), PAL.blue)
	b:Text(sign, FACE.Front, "COLD ROOM", { color = PAL.white })
	b:Box(V3(4, 1.5, 3), CF(0, H + 2.15, 2), PAL.steel, M.Metal)
	b:Cyl(0.2, 2.2, CF(0, H + 3, 2), PAL.black)
	b:Box(V3(2.6, 0.4, 2.6), CF(4.3, 0.2, -D / 2 - 2), PAL.wood, M.WoodPlanks)
	for _, p in { V3(3.7, 0.95, -9.6), V3(4.9, 0.95, -9.6), V3(3.7, 0.95, -8.4), V3(4.9, 0.95, -8.4), V3(4.3, 2.05, -9.0) } do
		b:Box(V3(1.1, 1.1, 1.1), CF(p), rgb(200, 160, 110))
	end

	-- back wall rack: milk crates + boxes
	local back = CF(0, 0.2, 5.4)
	b:Shelf(back, 11, 1.8, { 1.2, 3.2, 5.2 }, PAL.blue, function(level, y)
		for k = 1, 5 do
			local at = back * CF(-4.4 + (k - 1) * 2.2, y, 0)
			if (k + level) % 2 == 0 then
				b:Box(V3(1.8, 1.0, 1.5), at * CF(0, 0.5, 0), if k % 4 == 0 then PAL.red else PAL.blue, nil, { solid = false })
				b:Box(V3(1.5, 0.12, 1.2), at * CF(0, 1.05, 0), PAL.white, nil, { solid = false })
			else
				b:Box(V3(1.8, 1.3, 1.5), at * CF(0, 0.65, 0), rgb(200, 160, 110), nil, { solid = false })
				b:Box(V3(1.0, 0.4, 0.02), at * CF(0, 0.7, -0.76), PAL.white, nil, { solid = false })
			end
		end
	end)
	-- left wall rack: frozen goods
	local left = CF(-5.4, 0.2, -0.5) * ANG(0, rad(90), 0)
	b:Shelf(left, 8, 1.6, { 1.2, 3.2, 5.2 }, PAL.blue, function(level, y)
		for k = 1, 3 do
			local at = left * CF(-2.6 + (k - 1) * 2.6, y, 0)
			b:Box(V3(1.6, 1.1, 1.4), at * CF(0, 0.55, 0), if (k + level) % 2 == 0 then PAL.white else rgb(150, 200, 240), nil, { solid = false })
		end
	end)
	-- ice blocks + milk pallet
	for i = 0, 5 do
		local x = 3.6 + (i % 2) * 1.4
		local y = 0.85 + math.floor(i / 4) * 1.3
		local z = -4.2 + (math.floor(i / 2) % 2) * 1.4
		b:Box(V3(1.3, 1.3, 1.3), CF(x, y, z), ICE, M.Glass, { t = 0.25 })
	end
	b:Box(V3(2.6, 0.4, 2.6), CF(3.6, 0.4, 1.5), PAL.wood, M.WoodPlanks)
	for i = 0, 7 do
		local x = 3.05 + (i % 2) * 1.1
		local z = 0.95 + (math.floor(i / 2) % 2) * 1.1
		local y = 1.3 + math.floor(i / 4) * 1.45
		local carton = b:Box(V3(1.05, 1.4, 1.05), CF(x, y, z), PAL.white, nil, { solid = false })
		if i % 4 == 0 then
			b:Text(carton, FACE.Front, "MILK", { color = PAL.blue })
		end
	end
	-- evaporator + icicles
	b:Box(V3(6, 1.4, 1.3), CF(0, 7.9, 5.9), PAL.steel, M.Metal)
	for _, x in { -1.5, 1.5 } do
		b:HCyl(0.1, 1.1, CF(x, 7.9, 5.22) * ANG(0, rad(90), 0), PAL.black, nil, { solid = false })
	end
	for i = 0, 5 do
		b:Cyl(0.6, 0.18, CF(-2.5 + i, 6.9, 5.6), PAL.white, M.Glass, { t = 0.2, solid = false })
	end
	for _, p in { V3(-2, 0.22, -2), V3(1.5, 0.22, 3), V3(-3.5, 0.22, 2.5) } do
		b:Box(V3(2, 0.04, 1.5), CF(p), PAL.white, nil, { t = 0.3, solid = false })
	end
	-- worker in a winter jacket carrying a crate
	local jacket = rgb(40, 90, 160)
	local worker = b:Person(CF(-1.5, 0.2, 1) * ANG(0, rad(150), 0), { shirt = jacket, apron = jacket, cap = rgb(200, 40, 40), right = { 70, 20 }, left = { 70, 20 } })
	b:Box(V3(1.6, 1, 1.3), CF((worker.left + worker.right) / 2) * CF(0, 0.4, 0), PAL.blue, nil, { solid = false })
	for i, z in { -2, 2 } do
		local strip = b:Box(V3(6, 0.15, 0.6), CF(0, H - 0.1, z), rgb(200, 235, 255), M.Neon, { solid = false })
		if i == 1 then
			b:Light(strip, rgb(170, 220, 255), 16, 0.9)
		end
	end
end

Build.L35 = function(b) -- tea roastery (drum roaster under a gabled shed + sacks + worker raking leaves)
	for _, x in { -1.8, 1.8 } do
		for _, z in { -1, 1 } do
			b:Box(V3(0.4, 2, 0.4), CF(x, 1, z), PAL.black, M.Metal)
		end
	end
	b:HCyl(5, 3.2, CF(0, 3.2, 0), PAL.steelDark, M.Metal)
	for _, x in { -2.6, 2.6 } do
		b:HCyl(0.25, 3.4, CF(x, 3.2, 0), PAL.black, M.Metal)
	end
	b:HCyl(0.1, 1.2, CF(2.75, 3.2, 0), PAL.steel, M.Metal, { solid = false })
	b:Box(V3(1.4, 3.2, 3), CF(-3.4, 1.6, 0), PAL.black, M.Metal)
	b:Ball(0.35, CF(-3.4, 2.4, -1.55), rgb(255, 120, 40), M.Neon, { solid = false })
	b:Box(V3(1.6, 1.4, 1.6), CF(0.5, 5.3, 0), PAL.steel, M.Metal)
	b:Cyl(6, 0.6, CF(2, 6.8, 1), PAL.black, M.Metal)
	for i, d in { 0.9, 1.3, 1.7 } do
		b:Ball(d, CF(2 + i * 0.2, 9.9 + i * 0.8, 1), PAL.white, nil, { t = 0.65, solid = false, name = if i == 1 then "Steam" else "SteamPuff" })
	end
	b:Cyl(0.5, 3.4, CF(0, 1, -3.4), PAL.steel, M.Metal)
	b:Cyl(0.08, 3.1, CF(0, 1.27, -3.4), rgb(110, 60, 30), nil, { solid = false })
	b:Box(V3(3, 0.1, 0.2), CF(0, 1.4, -3.4) * ANG(0, rad(30), 0), PAL.steelDark, M.Metal, { solid = false })
	b:Legs(2.4, 2.4, 0.75, 0.2, CF(0, 0, -3.4), PAL.black)
	for _, p in { V3(3.6, 0.8, -1.5), V3(3.6, 0.8, -0.4), V3(3.6, 2.4, -0.95), V3(4.8, 0.8, 1.2) } do
		local sack = b:Box(V3(1.2, 1.6, 1.0), CF(p), rgb(200, 175, 130), M.Fabric)
		b:Text(sack, FACE.Front, "TEA", { color = PAL.teaDark, region = { 0.1, 0.3, 0.8, 0.4 } })
	end
	-- gabled shed
	for _, x in { -5.6, 5.6 } do
		for _, z in { -4.4, 4.4 } do
			b:Box(V3(0.5, 7.4, 0.5), CF(x, 3.7, z), PAL.woodDark, M.Wood)
		end
	end
	local roof = rgb(150, 70, 40)
	b:Box(V3(12.6, 0.3, 10.2), CF(0, 7.55, 0), PAL.woodDark, M.Wood)
	b:Wedge(V3(12.6, 1.4, 5.1), CF(0, 8.4, -2.55), roof, M.Wood)
	b:Wedge(V3(12.6, 1.4, 5.1), CF(0, 8.4, 2.55) * ANG(0, rad(180), 0), roof, M.Wood)
	local lantern = b:Ball(0.6, CF(-2.5, 6.6, -2), PAL.warm, M.Neon, { solid = false })
	b:Box(V3(0.05, 0.7, 0.05), CF(-2.5, 7.1, -2), PAL.black, nil, { solid = false })
	b:Light(lantern, PAL.warm, 12, 0.8)
	local worker = b:Person(CF(-1.2, 0, -5.4) * ANG(0, rad(180), 0), { shirt = rgb(90, 110, 80), apron = PAL.teaDark, cap = PAL.teaDark, right = { 55, 10 }, left = { 45, 10 } })
	b:Rod(worker.right, V3(-0.3, 1.35, -3.6), 0.12, PAL.woodDark, M.Wood)
end

Build.L36 = function(b) -- 3 baristas (behind the bar)
	b:Box(V3(15, 0.8, 2.4), CF(0, 0.4, 0), PAL.woodDark, M.WoodPlanks)
	local left = b:Person(CF(-5, 0.8, 0), { apron = PAL.green, cap = PAL.green, right = { 100, 35 }, left = { 100, 35 } })
	local shaker = CF((left.left + left.right) / 2)
	b:Cyl(1.1, 0.55, shaker * CF(0, 0.3, 0), PAL.steel, M.Metal)
	b:Cyl(0.3, 0.45, shaker * CF(0, 1.0, 0), PAL.steelDark, M.Metal)
	local mid = b:Person(CF(0, 0.8, 0), { apron = PAL.tea, cap = PAL.tea, right = { 150, 20 }, left = { 60, 30 } })
	b:Cyl(0.6, 0.5, CF(mid.right) * CF(0, -0.1, 0), PAL.steel, M.Metal)
	b:TeaCup(CF(mid.left) * CF(0, -0.2, 0), 1.2)
	b:Rod(mid.right - V3(0, 0.4, 0), mid.left + V3(0, 0.9, 0), 0.14, PAL.tea, M.Glass, { t = 0.15 })
	local right = b:Person(CF(5, 0.8, 0), { apron = PAL.teaDark, shirt = PAL.cream, right = { 75, 20 }, left = { 75, 20 } })
	b:Box(V3(2.2, 0.1, 1.0), CF((right.left + right.right) / 2) * CF(0, 0.1, 0), PAL.woodDark, M.Wood, { solid = false })
	b:TeaCup(CF((right.left + right.right) / 2) * CF(-0.5, 0.15, 0))
	b:TeaCup(CF((right.left + right.right) / 2) * CF(0.5, 0.15, 0), 1, rgb(120, 180, 90))
	-- mat edge, glass rack, name tags
	b:Box(V3(15, 0.1, 0.3), CF(0, 0.85, -1.2), PAL.yellow, nil, { solid = false })
	b:Box(V3(2, 0.3, 1.2), CF(-7, 0.95, 0.4), PAL.steelDark, M.Metal, { solid = false })
	for i = 0, 5 do
		b:Cyl(0.6, 0.4, CF(-7.6 + (i % 3) * 0.6, 1.4, 0.1 + math.floor(i / 3) * 0.6), PAL.white, M.Glass, { t = 0.5, solid = false })
	end
	for _, x in { -5, 0, 5 } do
		b:Box(V3(0.5, 0.15, 0.03), CF(x + 0.5, 4.7, -0.62), PAL.gold, M.Metal, { solid = false })
	end
end

Build.L37 = function(b) -- billboard
	b:Cyl(13, 1, CF(0, 6.5, 0.4), PAL.steelDark, M.Metal)
	b:Box(V3(2, 0.6, 2), CF(0, 0.3, 0.4), PAL.concrete, M.Concrete)
	b:Box(V3(12, 0.2, 1.4), CF(0, 12.6, -0.8), PAL.steelDark, M.DiamondPlate)
	b:Box(V3(12, 0.1, 0.1), CF(0, 13.4, -1.45), PAL.steelDark, M.Metal, { solid = false })
	b:Box(V3(12.4, 6.4, 0.6), CF(0, 16, 0), PAL.black, M.Metal)
	local face = b:Box(V3(12, 6, 0.1), CF(0, 16, -0.35), PAL.cream)
	b:Text(face, FACE.Front, "THAI ICED TEA\nsweet · creamy · cold\nonly ฿35", { color = PAL.teaDark, region = { 0.03, 0.1, 0.6, 0.8 } })
	-- cup artwork on the board
	b:Box(V3(2, 2.8, 0.1), CF(-3.6, 15.2, -0.45), PAL.tea, nil, { solid = false })
	b:Box(V3(2.1, 0.6, 0.1), CF(-3.6, 16.8, -0.45), PAL.milk, nil, { solid = false })
	b:Ellipsoid(V3(2.3, 1.1, 0.1), CF(-3.6, 17.1, -0.44), PAL.white)
	b:Box(V3(0.25, 2.4, 0.1), CF(-3.2, 18.0, -0.46) * ANG(0, 0, rad(-20)), PAL.green, nil, { solid = false })
	for _, x in { -4, 0, 4 } do
		b:Rod(V3(x, 12.8, -1.3), V3(x, 13.6, -1.9), 0.3, PAL.black, M.Metal)
		b:Ball(0.35, CF(x, 13.7, -1.95), PAL.warm, M.Neon, { solid = false })
	end
	-- maintenance ladder up the pole, top trim with logo, bolts
	for _, x in { -0.35, 0.35 } do
		b:Box(V3(0.1, 12, 0.1), CF(x, 6.4, -0.3), PAL.steel, M.Metal, { solid = false })
	end
	for i = 1, 11 do
		b:Box(V3(0.7, 0.08, 0.08), CF(0, i * 1.1, -0.3), PAL.steel, M.Metal, { solid = false })
	end
	local trim = b:Box(V3(4, 0.8, 0.3), CF(0, 19.6, 0), PAL.tea)
	b:Text(trim, FACE.Front, "THAI TEA", { color = PAL.white })
	for _, x in { -6, 6 } do
		for _, y in { 13, 19 } do
			b:Ball(0.25, CF(x, y, -0.32), PAL.steelDark, M.Metal, { solid = false })
		end
	end
	-- gold border around the board, catwalk rail posts, smiley next to the cup, stars in the corners
	for _, spec in { { V3(12.4, 0.2, 0.2), CF(0, 19.25, -0.35) }, { V3(12.4, 0.2, 0.2), CF(0, 12.75, -0.35) }, { V3(0.2, 6.6, 0.2), CF(-6.25, 16, -0.35) }, { V3(0.2, 6.6, 0.2), CF(6.25, 16, -0.35) } } do
		b:Box(spec[1], spec[2], PAL.gold, M.Metal, { solid = false })
	end
	for i = 0, 6 do
		b:Box(V3(0.1, 0.8, 0.1), CF(-6 + i * 2, 13.1, -1.45), PAL.steelDark, M.Metal, { solid = false })
	end
	local face = CF(-5.2, 14.2, -0.45)
	b:Ellipsoid(V3(1.5, 1.5, 0.1), face, PAL.yellow)
	for _, x in { -0.4, 0.4 } do
		b:Ellipsoid(V3(0.2, 0.28, 0.1), face * CF(x * 0.7, 0.2, -0.03), PAL.black)
	end
	b:Rod((face * CF(-0.38, -0.22, -0.04)).Position, (face * CF(0, -0.45, -0.04)).Position, 0.09, PAL.red)
	b:Rod((face * CF(0.38, -0.22, -0.04)).Position, (face * CF(0, -0.45, -0.04)).Position, 0.09, PAL.red)
	for i, p in { V3(5.4, 18.4, -0.45), V3(-1.9, 18.4, -0.45), V3(5.5, 13.6, -0.45) } do
		b:Box(V3(0.5, 0.5, 0.08), CF(p) * ANG(0, 0, rad(45 + i * 10)), PAL.tea, nil, { solid = false })
	end
end

-- Tier 5 ---------------------------------------------------------------

Build.L38 = function(b) -- 5-level terraced tea plantation (bush rows, steps, pickers in straw hats, hut, drying rack)
	local STEP, W, DEPTH = 1.5, 14, 24
	local fronts = {}
	for i = 1, 5 do
		local front = -DEPTH / 2 + (i - 1) * 4.5
		fronts[i] = front
		local depth = DEPTH / 2 - front
		b:Box(V3(W, STEP, depth), CF(0, (i - 0.5) * STEP, front + depth / 2), if i == 1 then rgb(120, 90, 60) else rgb(110, 150, 70), if i == 1 then M.Ground else M.Grass)
	end
	local rand = seeded(38)
	for i = 1, 4 do
		for _, dz in { 1.2, 3.3 } do
			for k = 0, 9 do
				local x = -6.3 + k * 1.4
				if math.abs(x) > 1 then
					b:Ellipsoid(V3(1.3, 0.9 + rand() * 0.3, 1.2), CF(x, i * STEP + 0.35, fronts[i] + dz), if (k + i) % 2 == 0 then PAL.leaf else PAL.leafDark)
				end
			end
		end
		b:Wedge(V3(1.8, STEP, 2.2), CF(0, i * STEP + STEP / 2, fronts[i + 1] - 1.1), rgb(150, 120, 80), M.Ground)
	end
	-- tea pickers
	for i, spot in { { 3.2, 1 }, { -2.6, 2 } } do
		local z = fronts[spot[2]] + 2.25
		local y = spot[2] * STEP
		local picker = b:Person(CF(spot[1], y, z), { shirt = if i == 1 then PAL.blue else PAL.red, apron = rgb(60, 50, 40), ngob = true, right = { 50, 10 }, left = { 50, 10 } })
		b:Cyl(1.2, 1.3, CF(spot[1], y + 3, z + 0.9), PAL.woodLight, M.Wood, { solid = false })
		b:Ball(0.3, CF(picker.right), PAL.leaf, nil, { solid = false })
	end
	-- hut + drying rack on the top terrace
	local topY = 5 * STEP
	local hut = CF(2.5, topY, 9)
	b:Box(V3(3.4, 2.4, 2.8), hut * CF(0, 1.2, 0), PAL.wood, M.WoodPlanks)
	b:Wedge(V3(3.8, 1.1, 1.6), hut * CF(0, 2.95, -0.8), PAL.teaDark, M.Wood)
	b:Wedge(V3(3.8, 1.1, 1.6), hut * CF(0, 2.95, 0.8) * ANG(0, rad(180), 0), PAL.teaDark, M.Wood)
	b:Box(V3(0.9, 1.5, 0.05), hut * CF(0, 0.75, -1.42), PAL.woodDark, nil, { solid = false })
	b:Box(V3(0.8, 0.6, 0.05), hut * CF(1.1, 1.4, -1.42), PAL.glass, M.Glass, { solid = false })
	local rack = CF(-3.5, topY, 9)
	for _, x in { -1.2, 1.2 } do
		b:Box(V3(0.2, 2.4, 0.2), rack * CF(x, 1.2, 0), PAL.woodDark, M.Wood, { solid = false })
	end
	for i = 0, 2 do
		b:Box(V3(2.4, 0.1, 1.1), rack * CF(0, 0.7 + i * 0.7, 0), PAL.woodLight, M.Wood, { solid = false })
		b:Box(V3(2.2, 0.08, 0.9), rack * CF(0, 0.78 + i * 0.7, 0), rgb(120, 70, 35), nil, { solid = false })
	end
	b:Cyl(0.7, 1, CF(-1, topY + 0.35, 7.2), PAL.woodLight, M.Wood, { solid = false })
	local sign = b:Box(V3(3, 1.1, 0.2), CF(5, 1.4, -DEPTH / 2 - 0.8), PAL.woodDark, M.Wood)
	b:Text(sign, FACE.Front, "TEA PLANTATION", { color = PAL.cream })
	b:Box(V3(0.25, 1.3, 0.25), CF(5, 0.65, -DEPTH / 2 - 0.8), PAL.woodDark, M.Wood, { solid = false })
end

Build.L39 = function(b) -- bottling factory (walk-in: conveyor, filler, capper, mixing tanks, catwalk)
	local W, D, H = 14, 18, 14
	local COPPER = rgb(190, 120, 70)
	b:Shell(CF(), {
		w = W, d = D, h = H, wall = rgb(200, 196, 190), wallMat = M.Concrete,
		floor = rgb(140, 142, 145), floorMat = M.Concrete, roof = false,
		openings = {
			{ side = "Front", x = 0, y = 0, w = 6, h = 7.8 },
			{ side = "Left", x = -5, y = 5, w = 3, h = 2.5, glass = true },
			{ side = "Left", x = 0, y = 5, w = 3, h = 2.5, glass = true },
			{ side = "Left", x = 5, y = 5, w = 3, h = 2.5, glass = true },
			{ side = "Right", x = -5, y = 5, w = 3, h = 2.5, glass = true },
			{ side = "Right", x = 0, y = 5, w = 3, h = 2.5, glass = true },
			{ side = "Right", x = 5, y = 5, w = 3, h = 2.5, glass = true },
		},
	})
	b:UpperWindows(CF(), W, D, { "Front" }, { -2.2, 2.2 }, 10, 2.4)
	b:UpperWindows(CF(), W, D, { "Left", "Right" }, { -5, 0, 5 }, 10, 2.4)
	-- sawtooth roof
	for _, z in { -6.75, -2.25, 2.25, 6.75 } do
		b:Wedge(V3(W, 2.4, 4.5), CF(0, H + 1.2, z), PAL.steelDark, M.Metal)
		b:Box(V3(W, 2.2, 0.1), CF(0, H + 1.2, z + 2.3), PAL.glass, M.Glass, { t = 0.3, solid = false })
	end
	for _, z in { -D / 2 - 0.05, D / 2 + 0.05 } do
		b:Box(V3(W + 0.1, 0.5, 0.1), CF(0, H - 1.2, z), PAL.tea, nil, { solid = false })
	end
	-- silos + pipe + sign
	local SILO = H - 1
	for _, x in { -5.3, 5.3 } do
		b:Cyl(SILO, 2.2, CF(x, SILO / 2, -D / 2 - 1.3), PAL.steel, M.Metal)
		b:Ellipsoid(V3(2.2, 1.2, 2.2), CF(x, SILO, -D / 2 - 1.3), PAL.steel, M.Metal)
		for _, y in { 2.5, 6.5, 10.5 } do
			b:Cyl(0.3, 2.3, CF(x, y, -D / 2 - 1.3), PAL.tea)
		end
	end
	b:HCyl(10.6, 0.4, CF(0, SILO + 0.2, -D / 2 - 1.3), COPPER, M.Metal)
	local sign = b:Box(V3(5.5, 1, 0.2), CF(0, 8.6, -D / 2 - 0.15), PAL.tea)
	b:Text(sign, FACE.Front, "BOTTLING FACTORY", { color = PAL.white })
	-- giant bottle on the roof
	b:Box(V3(3, 0.3, 3), CF(0, H + 2.55, 0), PAL.steelDark, M.Metal)
	b:Cyl(3, 1.8, CF(0, H + 4.2, 0), PAL.tea)
	b:Cyl(1, 1.85, CF(0, H + 4.3, 0), PAL.cream)
	b:Cyl(0.6, 1.2, CF(0, H + 6.0, 0), PAL.tea)
	b:Cyl(0.8, 0.6, CF(0, H + 6.7, 0), PAL.tea, M.Glass, { t = 0.2 })
	b:Cyl(0.3, 0.7, CF(0, H + 7.25, 0), PAL.red)

	-- bottling line (runs along Z by the right wall)
	local line = CF(3.8, 0.2, 0) * ANG(0, rad(90), 0)
	for _, u in { -5.5, 0, 5.5 } do
		for _, v in { -0.8, 0.8 } do
			b:Box(V3(0.3, 2.6, 0.3), line * CF(u, 1.3, v), PAL.steelDark, M.Metal, { solid = false })
		end
	end
	for _, v in { -1, 1 } do
		b:Box(V3(12, 0.5, 0.2), line * CF(0, 2.8, v), PAL.steel, M.Metal)
	end
	b:Box(V3(12, 0.2, 1.8), line * CF(0, 2.9, 0), PAL.black)
	for i = 0, 9 do
		local at = line * CF(-5.4 + i * 1.2, 3.0, 0)
		b:Cyl(1.0, 0.45, at * CF(0, 0.5, 0), PAL.tea, M.Glass, { t = 0.1, solid = false })
		b:Cyl(0.4, 0.22, at * CF(0, 1.2, 0), if i < 5 then PAL.red else PAL.tea, nil, { solid = false })
	end
	-- filler
	for _, v in { -1.5, 1.5 } do
		b:Box(V3(0.4, 5.2, 0.4), line * CF(2, 2.6, v), PAL.steelDark, M.Metal)
	end
	b:Box(V3(2.6, 1.2, 3.6), line * CF(2, 5.8, 0), PAL.steel, M.Metal)
	for _, u in { 1.4, 2, 2.6 } do
		b:Cyl(0.7, 0.25, line * CF(u, 4.9, 0), PAL.black, nil, { solid = false })
	end
	b:Box(V3(2.4, 1.6, 0.1), line * CF(2, 4.2, -1.3), PAL.glass, M.Glass, { t = 0.6, solid = false })
	b:Ball(0.35, line * CF(2, 6.5, -1.8), rgb(90, 230, 120), M.Neon, { solid = false })
	-- capper
	b:Box(V3(1.6, 3.2, 1.6), line * CF(-2.5, 1.8, 1.9), PAL.red)
	b:Box(V3(1.2, 0.9, 1.6), line * CF(-2.5, 3.9, 1.1), PAL.red)
	b:Cyl(1, 1.3, line * CF(-2.5, 4.9, 1.9), PAL.steel, M.Metal)
	for i = 0, 3 do
		b:Ball(0.3, line * CF(-2.9 + i * 0.3, 5.45, 1.9), PAL.red, nil, { solid = false })
	end
	-- finished bottle crates
	for i = 0, 1 do
		local crate = CF(1.5, 0.2 + i * 1, -6.6)
		b:Box(V3(2, 0.9, 1.5), crate * CF(0, 0.45, 0), PAL.yellow)
		for k = 0, 5 do
			b:Cyl(0.35, 0.4, crate * CF(-0.6 + (k % 3) * 0.6, 1.05, -0.35 + math.floor(k / 3) * 0.7), PAL.tea, nil, { solid = false })
		end
	end

	-- 2 mixing tanks + catwalk + ladder
	for _, z in { 4.5, -1 } do
		b:Cyl(6, 3, CF(-3.8, 3.3, z), PAL.steel, M.Metal)
		b:Ellipsoid(V3(3, 1.2, 3), CF(-3.8, 6.3, z), PAL.steel, M.Metal)
		b:Cyl(0.3, 3.05, CF(-3.8, 1.5, z), PAL.tea)
		b:Box(V3(0.2, 3, 0.05), CF(-2.3, 3.5, z), PAL.tea, M.Glass, { t = 0.2, solid = false })
		b:Box(V3(0.05, 3, 0.2), CF(-2.28, 3.5, z), PAL.tea, M.Glass, { t = 0.2, solid = false })
		b:Tube(V3(-2.3, 5.4, z), V3(3.8, 5.6, -2), 0.35, COPPER, M.Metal)
	end
	b:Box(V3(2, 0.25, 9), CF(-1.3, 6.2, 1.75), PAL.steelDark, M.DiamondPlate, { solid = true })
	b:Box(V3(0.12, 0.12, 9), CF(-0.35, 7.3, 1.75), PAL.yellow, M.Metal, { solid = false })
	for _, z in { -2.5, 1.75, 6 } do
		b:Box(V3(0.25, 6.1, 0.25), CF(-0.4, 3.2, z), PAL.steelDark, M.Metal, { solid = false })
		b:Box(V3(0.12, 1.1, 0.12), CF(-0.35, 6.8, z), PAL.yellow, M.Metal, { solid = false })
	end
	for _, x in { -1.9, -0.9 } do
		b:Box(V3(0.15, 6.2, 0.15), CF(x, 3.3, -2.9), PAL.yellow, M.Metal, { solid = false })
	end
	for i = 1, 6 do
		b:Box(V3(1.0, 0.12, 0.12), CF(-1.4, i * 0.95, -2.9), PAL.yellow, M.Metal, { solid = false })
	end
	-- control panel
	b:Box(V3(2.2, 2.8, 0.9), CF(-5.2, 1.6, -7.2), PAL.steel, M.Metal)
	local screen = b:Box(V3(1.6, 0.9, 0.05), CF(-5.2, 2.3, -7.68), rgb(40, 110, 220), M.Neon, { solid = false })
	b:Text(screen, FACE.Front, "LINE 1 OK", { color = PAL.white })
	for i, c in { PAL.red, rgb(90, 220, 120), PAL.yellow } do
		b:Ball(0.25, CF(-5.9 + i * 0.35, 1.4, -7.66), c, M.Neon, { solid = false })
	end
	-- worker + floor lines + warning sign
	b:Person(CF(1.4, 0.2, -2) * ANG(0, rad(-90), 0), { shirt = rgb(60, 90, 140), apron = rgb(60, 90, 140), cap = PAL.yellow, right = { 60, 10 }, left = { 60, 10 } })
	for _, x in { 1.2, -2.9 } do
		b:Box(V3(0.2, 0.03, 16), CF(x, 0.215, 0), PAL.yellow, nil, { solid = false })
	end
	local warnSign = b:Box(V3(0.05, 1.2, 1.2), CF(W / 2 - 0.65, 5, -6), PAL.yellow, nil, { solid = false })
	b:Text(warnSign, FACE.Left, "⚠", { color = PAL.black })
	for i, z in { -4.5, 0, 4.5 } do
		local strip = b:Box(V3(10, 0.15, 0.6), CF(0, H - 0.1, z), PAL.white, M.Neon, { solid = false })
		if i == 2 then
			b:Light(strip, PAL.white, 20, 0.8)
		end
	end
end

-- forklift (used in the distribution center)
local function forklift(b, fl: CFrame)
	b:Box(V3(1.4, 1.2, 2), fl * CF(0, 0.9, 0.2), PAL.yellow)
	for _, x in { -0.65, 0.65 } do
		for _, z in { -0.5, 0.9 } do
			b:HCyl(0.3, 0.7, fl * CF(x, 0.35, z), PAL.black)
		end
		b:Box(V3(0.12, 2.8, 0.12), fl * CF(x * 0.8, 1.9, -0.85), PAL.black, M.Metal, { solid = false })
		b:Box(V3(0.2, 0.08, 1.2), fl * CF(x * 0.5, 0.25, -1.5), PAL.steelDark, M.Metal, { solid = false })
		b:Box(V3(0.1, 1.6, 0.1), fl * CF(x, 2.3, 0.6), PAL.black, M.Metal, { solid = false })
	end
	b:Box(V3(1.4, 0.1, 1.6), fl * CF(0, 3.1, 0.2), PAL.black, M.Metal, { solid = false })
	b:Box(V3(0.8, 0.3, 0.6), fl * CF(0, 1.65, 0.6), PAL.black)
	b:Ball(0.3, fl * CF(0, 3.25, 0.2), rgb(255, 150, 40), M.Neon, { solid = false })
end

Build.L40 = function(b) -- distribution center (walk-in: tall pallet racks, forklift, packing table)
	local W, D, H = 12, 20, 13
	local CARTON = rgb(200, 160, 110)
	b:Shell(CF(), {
		w = W, d = D, h = H, wall = rgb(125, 155, 185), wallMat = M.Metal,
		floor = rgb(165, 165, 160), floorMat = M.Concrete, roofColor = rgb(85, 100, 120),
		openings = {
			{ side = "Front", x = -2.8, y = 0, w = 4.4, h = 7.5 },
			{ side = "Left", x = -5, y = 5.2, w = 2.4, h = 1.2, glass = true },
			{ side = "Left", x = 0, y = 5.2, w = 2.4, h = 1.2, glass = true },
			{ side = "Left", x = 5, y = 5.2, w = 2.4, h = 1.2, glass = true },
			{ side = "Right", x = -5, y = 5.2, w = 2.4, h = 1.2, glass = true },
			{ side = "Right", x = 0, y = 5.2, w = 2.4, h = 1.2, glass = true },
			{ side = "Right", x = 5, y = 5.2, w = 2.4, h = 1.2, glass = true },
		},
	})
	b:Wedge(V3(D, 2.2, W / 2), CF(-W / 4, H + 1.7, 0) * ANG(0, rad(90), 0), rgb(85, 100, 120), M.Metal)
	b:Wedge(V3(D, 2.2, W / 2), CF(W / 4, H + 1.7, 0) * ANG(0, rad(-90), 0), rgb(85, 100, 120), M.Metal)
	b:UpperWindows(CF(), W, D, { "Front" }, { -3.5, 0, 3.5 }, 8.8, 2.4)
	b:UpperWindows(CF(), W, D, { "Left", "Right" }, { -5, 0, 5 }, 8.8, 2.4)
	-- exterior: roller door, sign, dock bumpers
	b:Box(V3(4.4, 6, 0.1), CF(2.8, 3, -D / 2 - 0.08), PAL.steelDark, M.Metal)
	for i = 1, 7 do
		b:Box(V3(4.4, 0.05, 0.05), CF(2.8, i * 0.8, -D / 2 - 0.15), PAL.steel, nil, { solid = false })
	end
	for _, x in { -5.2, -0.4, 0.4, 5.2 } do
		b:Box(V3(0.4, 0.8, 0.3), CF(x, 0.8, -D / 2 - 0.2), PAL.black, nil, { solid = false })
	end
	local sign = b:Box(V3(8, 1, 0.12), CF(0, 7.1, -D / 2 - 0.1), PAL.tea)
	b:Text(sign, FACE.Front, "DISTRIBUTION CENTER", { color = PAL.white })
	for _, x in { -2.8, 2.8 } do
		b:Ball(0.35, CF(x, 6.7, -D / 2 - 0.3), PAL.warm, M.Neon, { solid = false })
	end
	b:Box(V3(2.4, 0.4, 2.4), CF(3.2, 0.2, -D / 2 - 2), PAL.wood, M.WoodPlanks)
	b:Box(V3(2.2, 1.6, 2.2), CF(3.2, 1.2, -D / 2 - 2), PAL.white, nil, { t = 0.2 })

	-- pallet racks on both sides
	for _, side in { -1, 1 } do
		local rack = CF(side * 4.3, 0.2, 1.5) * ANG(0, rad(90), 0)
		b:Shelf(rack, 14, 2, { 2.3, 4.5, 6.6 }, rgb(235, 120, 40), function(level, y)
			for k = 1, 4 do
				local at = rack * CF(-5.25 + (k - 1) * 3.5, y, 0)
				local wrapped = (k + level) % 3 == 0
				b:Box(V3(2.8, 1.5, 1.7), at * CF(0, 0.75, 0), if wrapped then PAL.white else CARTON, nil, { t = if wrapped then 0.15 else 0, solid = false })
			end
		end)
		for _, u in { -3.5, 0, 3.5 } do
			for _, v in { -0.9, 0.9 } do
				b:Box(V3(0.25, 7.6, 0.25), rack * CF(u, 3.8, v), PAL.blue, M.Metal, { solid = false })
			end
		end
		for k = 1, 4 do
			local at = rack * CF(-5.25 + (k - 1) * 3.5, 0, 0)
			b:Box(V3(2.8, 0.3, 1.8), at * CF(0, 0.15, 0), PAL.wood, M.WoodPlanks, { solid = false })
			b:Box(V3(2.6, 1.4, 1.6), at * CF(0, 1.0, 0), CARTON, nil, { solid = false })
		end
	end
	-- forklift + pallet jack + pallet
	forklift(b, CF(0, 0.2, -1.5))
	b:Box(V3(2.4, 0.3, 2.4), CF(0, 0.35, 5), PAL.wood, M.WoodPlanks)
	for i = 0, 3 do
		b:Box(V3(1.1, 1.1, 1.1), CF(-0.6 + (i % 2) * 1.2, 1.05, 4.4 + math.floor(i / 2) * 1.2), CARTON, nil, { solid = false })
	end
	b:Rod(V3(0, 0.4, 6.3), V3(0, 2.4, 7.2), 0.15, PAL.red, M.Metal)
	b:Box(V3(0.8, 0.12, 0.12), CF(0, 2.4, 7.2), PAL.black, nil, { solid = false })
	-- packing table + worker in a hi-vis vest
	b:Box(V3(3.5, 0.2, 1.6), CF(3.4, 3.0, -7.8), PAL.woodLight, M.Wood, { solid = true })
	b:Legs(3.1, 1.2, 2.8, 0.2, CF(3.4, 0.2, -7.8), PAL.steelDark)
	for i = 0, 3 do
		b:Box(V3(0.8, 0.6, 0.6), CF(2.2 + i * 0.8, 3.4, -7.9 + (i % 2) * 0.3), CARTON, nil, { solid = false })
	end
	b:HCyl(0.3, 0.6, CF(4.8, 3.4, -7.4) * ANG(0, rad(90), 0), PAL.tea, nil, { solid = false })
	b:Person(CF(3.4, 0.2, -6.6), { shirt = rgb(240, 120, 40), apron = PAL.yellow, right = { 60, 15 }, left = { 60, 15 } })
	-- pendant lamps + lane lines
	for i, z in { -5, 1, 7 } do
		b:Box(V3(0.06, H - 6.6, 0.06), CF(0, (H + 6.6) / 2, z), PAL.black, nil, { solid = false })
		b:Cyl(0.5, 1.6, CF(0, 6.4, z), PAL.black, M.Metal, { solid = false })
		local bulb = b:Ball(0.5, CF(0, 6.05, z), PAL.warm, M.Neon, { solid = false })
		if i == 2 then
			b:Light(bulb, PAL.warm, 18, 0.9)
		end
	end
	for _, x in { -2.8, 2.8 } do
		b:Box(V3(0.2, 0.03, 14), CF(x, 0.215, 1.5), PAL.yellow, nil, { solid = false })
	end
end

Build.L41 = function(b) -- headquarters (walk-in lobby + 8 glass floors with visible desks + helipad)
	-- real storeys: lobby 11 studs (3.5 m), offices 10 studs (3.2 m) each
	local W, D, LOBBY, FLOORS, STOREY = 10, 10, 11, 8, 10
	local GLASS = rgb(90, 150, 200)
	b:Shell(CF(), {
		w = W, d = D, h = LOBBY, wall = GLASS, wallMat = M.Glass, wallT = 0.35,
		floor = PAL.white, floorMat = M.Marble, roof = false,
		openings = { { side = "Front", x = 0, y = 0, w = 3.2, h = 8 } },
	})
	for _, x in { -W / 2 + 0.1, W / 2 - 0.1 } do
		for _, z in { -D / 2 + 0.1, D / 2 - 0.1 } do
			b:Box(V3(0.6, LOBBY, 0.6), CF(x, LOBBY / 2, z), PAL.white, M.Concrete)
		end
	end
	b:Box(V3(4.4, 0.25, 2.2), CF(0, 8.6, -D / 2 - 1.1), PAL.white)
	b:Box(V3(3.4, 0.1, 0.1), CF(0, 8.45, -D / 2 - 2.1), PAL.tea, M.Neon, { solid = false })
	-- upper floors
	for k = 1, FLOORS do
		local y0 = LOBBY + (k - 1) * STOREY
		b:Box(V3(W + 0.4, 0.4, D + 0.4), CF(0, y0 + 0.2, 0), PAL.white, M.Concrete)
		b:Box(V3(W - 0.2, STOREY - 0.4, D - 0.2), CF(0, y0 + 0.4 + (STOREY - 0.4) / 2, 0), GLASS, M.Glass, { t = 0.3 })
		for _, x in { -2.2, 2.2 } do
			-- office desk (0.75 m) with a monitor, standing on the floor slab
			b:Box(V3(2.4, 2.4, 1.2), CF(x, y0 + 0.4 + 1.2, -1), PAL.woodLight, nil, { solid = false })
			b:Box(V3(1.2, 0.8, 0.1), CF(x, y0 + 0.4 + 2.8, -0.8), PAL.black, nil, { solid = false })
		end
		b:Box(V3(W - 1, 0.12, 0.4), CF(0, y0 + STOREY - 0.3, 0), PAL.white, M.Neon, { solid = false }) -- ceiling light
	end
	local top = LOBBY + FLOORS * STOREY
	b:Box(V3(W + 0.6, 1, D + 0.6), CF(0, top + 0.5, 0), PAL.tea)
	local pad = b:Cyl(0.3, 7, CF(0, top + 1.15, 0), PAL.steelDark, M.Concrete)
	b:Text(pad, FACE.Right, "H", { color = PAL.white })
	local sign = b:Box(V3(7, 1.5, 0.2), CF(0, top - 1.2, -D / 2 - 0.3), PAL.tea)
	b:Text(sign, FACE.Front, "THAI TEA HQ", { color = PAL.white })
	b:Cyl(4, 0.2, CF(3.5, top + 3, 3.5), PAL.steelDark, M.Metal)
	b:Ball(0.4, CF(3.5, top + 5.1, 3.5), PAL.red, M.Neon, { solid = false })

	-- lobby
	b:Box(V3(4.4, 2.4, 1.3), CF(0, 1.4, 1.8), PAL.tea)
	b:Box(V3(4.6, 0.15, 1.5), CF(0, 2.68, 1.8), PAL.white, M.Marble)
	b:Box(V3(0.9, 0.6, 0.08), CF(0.9, 3.05, 2.1), PAL.black, nil, { solid = false })
	local logo = b:Box(V3(6, 3.5, 0.3), CF(0, 3.2, 4.4), PAL.green)
	b:Text(logo, FACE.Front, "THAI TEA\nHQ", { color = PAL.cream })
	b:Person(CF(0, 0.2, 3.0), { shirt = PAL.white, apron = PAL.green, right = { 40, 10 }, left = { 40, 10 } })
	b:Box(V3(1.6, 1.2, 4), CF(-3.6, 0.8, -1.5), rgb(60, 60, 70), M.Fabric)
	b:Box(V3(0.5, 1.5, 4), CF(-4.3, 1.9, -1.5), rgb(60, 60, 70), M.Fabric)
	b:Box(V3(1.4, 0.9, 2), CF(-1.9, 0.65, -1.5), PAL.woodDark, M.Wood)
	b:Box(V3(0.6, 0.05, 0.8), CF(-1.9, 1.12, -1.3), PAL.tea, nil, { solid = false })
	b:Plant(CF(-3.7, 0.2, -3.8), 2.2)
	b:Plant(CF(3.7, 0.2, -3.8), 2.2)
	for _, z in { -2.4, 0.2 } do
		b:Box(V3(0.12, 3.6, 2), CF(W / 2 - 0.45, 2.0, z), PAL.steel, M.Metal, { solid = false })
		b:Box(V3(0.13, 3.6, 0.05), CF(W / 2 - 0.45, 2.0, z), PAL.steelDark, nil, { solid = false })
		b:Box(V3(0.12, 0.35, 0.9), CF(W / 2 - 0.45, 4.1, z), rgb(255, 170, 60), M.Neon, { solid = false })
	end
	for i, x in { -2, 2 } do
		local strip = b:Box(V3(0.4, 0.12, 7), CF(x, LOBBY - 0.1, 0), PAL.white, M.Neon, { solid = false })
		if i == 1 then
			b:Light(strip, PAL.white, 14, 0.7)
		end
	end
end

Build.L42 = function(b) -- mall branch (a real tea shop: counter, lit menus, fridge, seating, customers in line)
	local W, D, H = 14, 16, 13
	b:Shell(CF(), {
		w = W, d = D, h = H, wall = rgb(242, 230, 212), wallMat = M.Concrete,
		floor = PAL.woodLight, floorMat = M.WoodPlanks, roofColor = PAL.white,
		openings = {
			{ side = "Front", x = -3.25, y = 0.4, w = 5.5, h = 5.6, glass = true },
			{ side = "Front", x = 2, y = 0, w = 3, h = 7.2 },
			{ side = "Front", x = 5.25, y = 0.4, w = 2.5, h = 5.6, glass = true },
			{ side = "Left", x = -4, y = 3, w = 4, h = 3, glass = true },
			{ side = "Left", x = 2, y = 3, w = 4, h = 3, glass = true },
		},
	})
	-- exterior (upper-floor windows on the tall walls)
	b:UpperWindows(CF(), W, D, { "Front" }, { -4.5, 0, 4.5 }, 8.8, 2.6)
	b:UpperWindows(CF(), W, D, { "Left", "Right" }, { -4, 2 }, 8.5, 2.6)
	local band = b:Box(V3(W + 0.4, 1.2, D + 0.4), CF(0, H + 1.2, 0), PAL.tea)
	b:Text(band, FACE.Front, "THAI TEA · MALL", { color = PAL.white, region = { 0.2, 0.05, 0.6, 0.9 } })
	for i = 0, 6 do
		b:Box(V3(2, 0.2, 2.2), CF(-6 + i * 2, 7.7, -D / 2 - 1.1) * ANG(rad(-12), 0, 0), if i % 2 == 0 then PAL.tea else PAL.white, M.Fabric, { solid = false })
	end
	b:Cyl(3, 2.2, CF(0, H + 3.3, -1.5), PAL.tea)
	b:Cyl(0.6, 2.3, CF(0, H + 5.1, -1.5), PAL.milk)
	b:Ellipsoid(V3(2.3, 1.2, 2.3), CF(0, H + 5.5, -1.5), PAL.white, M.Glass, { t = 0.35 })
	b:Tube(V3(0.3, H + 5.4, -1.5), V3(0.8, H + 7.8, -1.3), 0.3, PAL.green)
	for i, x in { -6.4, 6.4 } do
		b:Cyl(7, 0.15, CF(x, 3.5, -D / 2 - 2.6), PAL.steel, M.Metal)
		b:Box(V3(1.6, 1, 0.05), CF(x + (if i == 1 then 0.85 else -0.85), 6.4, -D / 2 - 2.6), if i == 1 then PAL.tea else PAL.green, M.Fabric, { solid = false })
	end
	b:Plant(CF(-0.2, 0, -D / 2 - 0.9), 1.8)
	b:Plant(CF(4.2, 0, -D / 2 - 0.9), 1.8)

	-- counter + back equipment + lit menus
	b:Box(V3(9.6, 3.2, 2), CF(0.4, 1.8, 3.8), PAL.tea)
	b:Box(V3(9.9, 0.2, 2.3), CF(0.4, 3.5, 3.8), PAL.white, M.Marble)
	for i = 0, 5 do
		b:Box(V3(0.3, 2.6, 0.08), CF(-3.6 + i * 1.6, 1.8, 2.78), PAL.woodLight, M.Wood, { solid = false })
	end
	b:Box(V3(12, 3.4, 1.2), CF(0, 1.9, 6.7), PAL.steel, M.Metal)
	for _, x in { -4, -2.8 } do
		b:Cyl(1.4, 0.8, CF(x, 4.3, 6.7), PAL.steel, M.Metal)
	end
	b:Box(V3(0.6, 0.5, 0.6), CF(-0.8, 3.85, 6.7), PAL.black)
	b:Cyl(1, 0.5, CF(-0.8, 4.6, 6.7), PAL.white, M.Glass, { t = 0.5, solid = false })
	for i = 0, 3 do
		b:Cyl(1.4, 0.5, CF(1.2 + i * 0.7, 4.3, 6.7), PAL.white, M.Glass, { t = 0.45, solid = false })
	end
	-- ordered left to right as seen from the entrance (+X is the viewer's left)
	local menus = { "Thai Tea 45\nGreen Tea 50", "Bubble Milk Tea 55\nCocoa 50", "TODAY ONLY!\n2nd cup 50% off" }
	for i, x in { 3.6, 0, -3.6 } do
		local board = b:Box(V3(3.2, 2.2, 0.12), CF(x, 6.4, D / 2 - 0.7), PAL.black)
		b:Text(board, FACE.Front, menus[i], { color = if i == 3 then PAL.yellow else PAL.cream, glow = true })
	end
	b:Box(V3(0.7, 0.5, 0.6), CF(-3.2, 3.85, 3.8), PAL.black)
	b:Box(V3(0.6, 0.4, 0.05), CF(-3.2, 4.3, 3.6) * ANG(rad(-20), 0, 0), rgb(70, 150, 255), M.Neon, { solid = false })
	for i = 0, 2 do
		b:TeaCup(CF(1 + i * 0.8, 3.6, 3.4), 1, if i == 1 then rgb(120, 180, 90) else nil)
	end
	b:Cyl(0.7, 0.5, CF(4, 3.95, 3.5), PAL.white, M.Glass, { t = 0.4, solid = false })
	b:Person(CF(-2.5, 0.2, 5.45), { apron = PAL.tea, cap = PAL.tea, right = { 60, 20 }, left = { 60, 20 } })
	local pour = b:Person(CF(2.5, 0.2, 5.45), { apron = PAL.green, cap = PAL.green, right = { 150, 20 }, left = { 60, 30 } })
	b:Cyl(0.6, 0.5, CF(pour.right) * CF(0, -0.1, 0), PAL.steel, M.Metal)
	b:TeaCup(CF(pour.left) * CF(0, -0.2, 0), 1.2)
	b:Rod(pour.right - V3(0, 0.4, 0), pour.left + V3(0, 0.9, 0), 0.14, PAL.tea, M.Glass, { t = 0.15 })

	-- drinks fridge (facing into the shop)
	b:Box(V3(1.4, 5, 2.4), CF(-5.7, 2.7, 2.2), rgb(40, 40, 45))
	local fridgeGlass = b:Box(V3(0.1, 4, 2.0), CF(-4.95, 2.7, 2.2), PAL.glass, M.Glass, { t = 0.55 })
	b:Light(fridgeGlass, PAL.white, 6, 0.5)
	for i = 0, 5 do
		b:Cyl(0.7, 0.35, CF(-5.3, 1.6 + math.floor(i / 3) * 1.6, 1.5 + (i % 3) * 0.7), if i % 2 == 0 then PAL.tea else PAL.leaf, M.Glass, { t = 0.1, solid = false })
	end
	-- customer tables
	for i, spot in { V3(-4, 0.2, -5.2), V3(-4, 0.2, -1.4), V3(5, 0.2, -3.5) } do
		local t = CF(spot)
		b:Cyl(0.15, 1.2, t * CF(0, 0.08, 0), PAL.black)
		b:Cyl(2.4, 0.25, t * CF(0, 1.3, 0), PAL.black)
		b:Cyl(0.15, 2, t * CF(0, 2.6, 0), PAL.white)
		for _, dx in { -1.4, 1.4 } do
			b:Cyl(1.6, 0.2, t * CF(dx, 0.8, 0), PAL.steelDark, M.Metal)
			b:Cyl(0.3, 1, t * CF(dx, 1.75, 0), if i == 2 then PAL.green else PAL.tea)
		end
		b:TeaCup(t * CF(-0.3, 2.68, 0.2), 0.9)
		if i ~= 2 then
			b:TeaCup(t * CF(0.4, 2.68, -0.2), 0.9, rgb(120, 180, 90))
		end
	end
	-- queue barrier + customers
	for _, z in { -1, 1.5 } do
		b:Cyl(2.8, 0.2, CF(0.6, 1.6, z), PAL.gold, M.Metal)
		b:Cyl(0.15, 0.7, CF(0.6, 0.28, z), PAL.gold, M.Metal)
	end
	b:Rod(V3(0.6, 2.6, -1), V3(0.6, 2.6, 1.5), 0.12, PAL.red, M.Fabric)
	b:Person(CF(2.2, 0.2, 1.7) * ANG(0, rad(180), 0), { shirt = PAL.pink, apron = PAL.pink, pants = PAL.blue, left = { 10, 0 }, right = { 10, 0 } })
	b:Person(CF(2.2, 0.2, -0.6) * ANG(0, rad(170), 0), { shirt = PAL.blue, apron = PAL.blue, pants = PAL.black, left = { 40, 20 }, right = { 10, 0 } })
	-- poster + pendant lamps
	local poster = b:Box(V3(0.1, 2.4, 3), CF(-W / 2 + 0.65, 5.2, -3.5), PAL.cream, nil, { solid = false })
	b:Text(poster, FACE.Right, "REAL THAI TEA\nbrewed fresh", { color = PAL.teaDark })
	for i, x in { -3, 0.4, 3.8 } do
		b:Box(V3(0.06, H - 7.2, 0.06), CF(x, (H + 7.2) / 2, 3.8), PAL.black, nil, { solid = false })
		b:Cyl(0.6, 1.1, CF(x, 6.9, 3.8), PAL.tea, M.Metal, { solid = false })
		local bulb = b:Ball(0.45, CF(x, 6.55, 3.8), PAL.warm, M.Neon, { solid = false })
		if i == 2 then
			b:Light(bulb, PAL.warm, 16, 0.9)
		end
	end
end

Build.L43 = function(b) -- airport branch (walk-in terminal + control tower + airplane)
	local W, D, H = 13, 9, 10
	local T = CF(0, 0, -2)
	b:Shell(T, {
		w = W, d = D, h = H, wall = PAL.white, wallMat = M.SmoothPlastic,
		floor = rgb(220, 220, 225), floorMat = M.Marble, roofColor = rgb(210, 214, 220),
		openings = {
			{ side = "Front", x = -3.8, y = 0.5, w = 4.6, h = 5, glass = true },
			{ side = "Front", x = 1, y = 0, w = 3, h = 7 },
			{ side = "Front", x = 4.6, y = 0.5, w = 3.2, h = 5, glass = true },
			{ side = "Back", x = 0, y = 1, w = 9, h = 4.5, glass = true },
		},
	})
	b:UpperWindows(T, W, D, { "Front" }, { -4.5, -1.5, 1.5, 4.5 }, 7, 2.2, rgb(80, 160, 200))
	b:Wedge(V3(W + 1, 0.8, 1.6), T * CF(0, H + 0.2, -D / 2 - 0.8), rgb(210, 214, 220), M.Metal)
	local fascia = b:Box(V3(W + 0.2, 0.9, 0.2), T * CF(0, H + 1.05, -D / 2 + 0.1), PAL.tea)
	b:Text(fascia, FACE.Front, "AIRPORT BRANCH ✈", { color = PAL.white, region = { 0.2, 0, 0.6, 1 } })
	-- control tower
	b:Box(V3(2, 0.4, 2), CF(-7.3, 0.2, -3), PAL.concrete, M.Concrete)
	b:Cyl(12, 1.4, CF(-7.3, 6.2, -3), PAL.white)
	b:Cyl(1.6, 2.6, CF(-7.3, 13, -3), rgb(80, 160, 200), M.Glass, { t = 0.2 })
	b:Cyl(0.3, 2.9, CF(-7.3, 13.95, -3), PAL.white)
	b:Cyl(1.5, 0.12, CF(-7.3, 14.8, -3), PAL.steelDark, M.Metal)
	b:Ball(0.3, CF(-7.3, 15.6, -3), PAL.red, M.Neon, { solid = false })

	-- tea kiosk inside the terminal
	b:Box(V3(4, 3.2, 1.6), T * CF(-3.6, 1.8, 0.4), PAL.tea)
	b:Box(V3(4.2, 0.2, 1.8), T * CF(-3.6, 3.5, 0.4), PAL.white, M.Marble)
	local kiosk = b:Box(V3(3, 0.8, 0.1), T * CF(-3.6, 5.8, 0.4), PAL.green)
	b:Text(kiosk, FACE.Front, "THAI TEA", { color = PAL.cream })
	b:Box(V3(0.06, H - 6.2, 0.06), T * CF(-3.6, (H + 6.2) / 2, 0.4), PAL.black, nil, { solid = false })
	b:Person(T * CF(-3.6, 0.2, 1.65), { apron = PAL.tea, cap = PAL.tea, right = { 60, 20 }, left = { 60, 20 } })
	for i = 0, 2 do
		b:TeaCup(T * CF(-4.6 + i * 0.9, 3.6, 0), 0.9)
	end
	-- departures board
	local board = b:Box(V3(5, 1.8, 0.3), T * CF(2.8, 5.2, 1.4), PAL.black)
	b:Text(board, FACE.Front, "FLIGHT  TO           TIME\nTG101  CHIANG MAI  10:30\nFD202  PHUKET      11:15", { color = PAL.yellow, glow = true, font = Enum.Font.Code })
	for _, x in { 1, 4.6 } do
		b:Box(V3(0.08, H - 6.1, 0.08), T * CF(x, (H + 6.1) / 2, 1.4), PAL.black, nil, { solid = false })
	end
	-- 2 rows of gate seats
	for _, z in { -1.8, -4.2 } do
		local row = T * CF(3.8, 0.2, z)
		b:Box(V3(4.2, 0.2, 0.3), row * CF(0, 0.8, 0), PAL.steelDark, M.Metal, { solid = false })
		for _, x in { -1.6, 1.6 } do
			b:Box(V3(0.2, 1.4, 0.2), row * CF(x, 0.7, 0), PAL.steelDark, M.Metal, { solid = false })
		end
		for k = -1, 1 do
			b:Box(V3(1.2, 0.2, 1.1), row * CF(k * 1.35, 1.6, 0), PAL.blue)
			b:Box(V3(1.2, 1.2, 0.15), row * CF(k * 1.35, 2.3, 0.55), PAL.blue, nil, { solid = false })
		end
	end
	-- suitcases + traveler
	for i, c in { PAL.red, PAL.green, PAL.yellow } do
		local at = T * CF(-3.2 + i * 1.0, 0.2, -5.0)
		b:Box(V3(0.9, 1.3, 0.5), at * CF(0, 0.85, 0), c)
		b:Box(V3(0.5, 0.6, 0.08), at * CF(0, 1.8, 0), PAL.black, nil, { solid = false })
	end
	local traveler = b:Person(T * CF(-0.3, 0.2, -3) * ANG(0, rad(160), 0), { shirt = PAL.yellow, apron = PAL.yellow, pants = PAL.blue, right = { 10, 0 }, left = { 10, 0 } })
	b:Box(V3(0.9, 1.4, 0.5), CF(traveler.right) * CF(0, -0.4, 0), PAL.blue, nil, { solid = false })
	b:Plant(T * CF(-5.4, 0.2, -3.6), 2)
	for i, x in { -2.5, 2.5 } do
		local strip = b:Box(V3(0.5, 0.12, 7), T * CF(x, H - 0.1, 0), PAL.white, M.Neon, { solid = false })
		if i == 1 then
			b:Light(strip, PAL.white, 14, 0.7)
		end
	end

	-- airplane (fuselage along X) parked behind the terminal
	local plane = CF(0, 0, 8)
	b:HCyl(9, 1.4, plane * CF(0, 1.6, 0), PAL.white)
	b:Ball(1.4, plane * CF(-4.5, 1.6, 0), PAL.white)
	b:Ellipsoid(V3(2.4, 1.1, 1.1), plane * CF(4.9, 1.8, 0), PAL.white)
	b:Box(V3(1.6, 0.15, 7), plane * CF(0, 1.3, 0), PAL.white, M.Metal)
	b:Box(V3(1.4, 1.8, 0.15), plane * CF(5, 2.9, 0) * ANG(0, 0, rad(-15)), PAL.tea)
	b:Box(V3(0.8, 0.1, 3), plane * CF(5.3, 1.9, 0), PAL.white, M.Metal)
	for _, z in { -2, 2 } do
		b:HCyl(1.2, 0.6, plane * CF(-0.4, 0.9, z), PAL.steelDark, M.Metal)
	end
	for _, z in { -0.71, 0.71 } do
		b:Box(V3(6, 0.18, 0.02), plane * CF(-0.3, 1.9, z), PAL.black, nil, { solid = false })
		b:Box(V3(6, 0.25, 0.02), plane * CF(-0.3, 1.2, z * 1.001), PAL.tea, nil, { solid = false })
	end
	b:Box(V3(0.5, 0.25, 1.42), plane * CF(-4.2, 2.0, 0), PAL.black, M.Glass, { solid = false })
	for _, x in { -3.5, 1 } do
		b:Box(V3(0.15, 0.9, 0.15), plane * CF(x, 0.45, 0), PAL.black, nil, { solid = false })
	end
	-- baggage tug
	b:Box(V3(1.4, 0.8, 1), plane * CF(-3, 0.6, -2.6), PAL.yellow)
	b:Box(V3(2, 0.2, 1.2), plane * CF(-0.9, 0.5, -2.6), PAL.steelDark, M.Metal)
	b:Box(V3(0.9, 0.8, 0.6), plane * CF(-0.9, 1.0, -2.6), PAL.red, nil, { solid = false })
end

Build.L44 = function(b) -- nationwide franchise (globe on a plinth)
	b:Cyl(1, 6, CF(0, 0.5, 0), PAL.white, M.Marble)
	b:Cyl(0.5, 5, CF(0, 1.25, 0), PAL.white, M.Marble)
	b:Cyl(2, 1.2, CF(0, 2.5, 0), PAL.gold, M.Metal)
	b:Ball(4.4, CF(0, 5.6, 0), rgb(60, 130, 210))
	local land = {
		{ 0, 20, 1.8 }, { 70, -10, 1.4 }, { 150, 35, 1.6 }, { 220, -25, 1.2 },
		{ 290, 10, 1.7 }, { 110, 55, 1.0 }, { 330, -45, 1.1 },
	}
	for _, l in land do
		b:Ellipsoid(V3(l[3], l[3] * 0.7, 0.5), CF(0, 5.6, 0) * ANG(0, rad(l[1]), 0) * ANG(rad(l[2]), 0, 0) * CF(0, 0, -2.05), PAL.leaf)
	end
	for k = 0, 17 do
		local a = rad(k * 20)
		local p = CF(0, 5.6, 0) * ANG(rad(20), 0, 0) * CF(math.cos(a) * 3.1, 0, math.sin(a) * 3.1)
		b:Ball(0.3, p, PAL.gold, M.Neon, { solid = false })
	end
	for _, pin in { { 10, 30 }, { 60, 5 }, { -30, -10 }, { 160, 20 } } do
		local base = CF(0, 5.6, 0) * ANG(0, rad(pin[1]), 0) * ANG(rad(pin[2]), 0, 0)
		b:Box(V3(0.08, 0.08, 0.6), base * CF(0, 0, -2.4), PAL.black, nil, { solid = false })
		b:Ball(0.4, base * CF(0, 0, -2.75), PAL.red, nil, { solid = false })
	end
	local plaque = b:Box(V3(2.6, 0.7, 0.2), CF(0, 0.55, -3.05), PAL.gold, M.Metal)
	b:Text(plaque, FACE.Front, "NATIONWIDE FRANCHISE", { color = PAL.black })
	-- flag poles and planters around the plinth
	for k = 0, 3 do
		local a = rad(45 + k * 90)
		local x, z = math.cos(a) * 4.2, math.sin(a) * 4.2
		b:Cyl(5, 0.15, CF(x, 2.5, z), PAL.steel, M.Metal)
		b:Box(V3(1.3, 0.8, 0.05), CF(x, 4.4, z) * ANG(0, -a, 0) * CF(0.65, 0, 0), ({ PAL.tea, PAL.green, PAL.red, PAL.blue })[k + 1], M.Fabric, { solid = false })
		b:Plant(CF(math.cos(a + rad(45)) * 4.3, 0, math.sin(a + rad(45)) * 4.3), 1.4)
	end
	-- latitude/longitude rings, polar axis, orbiting tea cups, gold star on top, steps around the plinth
	b:HCyl(0.12, 4.9, CF(0, 5.6, 0) * ANG(0, 0, rad(90)) * ANG(rad(23), 0, 0), PAL.gold, M.Metal, { solid = false })
	b:Tube(V3(0, 2.9, 0), V3(0, 8.3, 0), 0.15, PAL.gold, M.Metal)
	for k = 0, 2 do
		local a = rad(k * 120)
		b:TeaCup(CF(0, 5.6, 0) * ANG(rad(20), 0, 0) * CF(math.cos(a) * 3.3, -0.5, math.sin(a) * 3.3), 1.1)
	end
	b:Ball(0.6, CF(0, 8.5, 0), PAL.yellow, M.Neon, { solid = false })
	b:Cyl(0.35, 7.2, CF(0, 0.18, 0), PAL.white, M.Marble)
end

Build.L45 = function(b) -- bubble-tea cup landmark tower (walk-in lobby + gift shop + observation lift)
	-- real scale: 3.5 m lobby with 2.5 m doors, then a ~30 m cup rising above it
	local LW, LH, SEGMENT = 12, 11, 9
	b:Box(V3(14, 0.4, 14), CF(0, 0.2, 0), PAL.white, M.Marble)
	b:Box(V3(6, 0.2, 1), CF(0, 0.1, -7.4), PAL.white, M.Marble)
	local lobby = CF(0, 0.4, 0)
	b:Shell(lobby, {
		w = LW, d = LW, h = LH, wall = PAL.white, wallMat = M.Concrete,
		floor = rgb(235, 225, 210), floorMat = M.Marble, roofColor = PAL.white,
		openings = {
			{ side = "Front", x = 0, y = 0, w = 4, h = 8 },
			{ side = "Front", x = -4, y = 0.6, w = 3, h = 8, glass = true },
			{ side = "Front", x = 4, y = 0.6, w = 3, h = 8, glass = true },
			{ side = "Left", x = 0, y = 0.6, w = 8, h = 8, glass = true },
			{ side = "Right", x = 0, y = 0.6, w = 8, h = 8, glass = true },
		},
	})
	local sign = b:Box(V3(6, 1, 0.2), CF(0, LH + 0.1, -LW / 2 - 0.15), PAL.tea)
	b:Text(sign, FACE.Front, "THAI TEA TOWER", { color = PAL.white })
	for _, x in { -6.4, 6.4 } do
		b:Plant(CF(x, 0.4, -6.6), 2.4)
	end

	-- cup-shaped tower
	local base = 0.4 + LH + 0.6
	b:Cyl(0.8, 11, CF(0, base + 0.4, 0), PAL.white, M.Concrete)
	local top = base + 0.8
	for i = 0, 7 do
		local d = 10 + i * 0.8 -- the cup flares out toward the rim like a real plastic cup
		local color = if i == 0 then PAL.pearl elseif i % 2 == 0 then PAL.tea else rgb(222, 108, 40)
		b:Cyl(SEGMENT, d, CF(0, top + SEGMENT / 2, 0), color, M.SmoothPlastic, { solid = true })
		b:Cyl(0.4, d + 0.12, CF(0, top + SEGMENT, 0), PAL.warm, M.Neon)
		top += SEGMENT
	end
	for k = 0, 11 do
		local a = rad(k * 30)
		b:Ball(2.4, CF(math.cos(a) * 4, base + 2.8 + (k % 2) * 2.2, math.sin(a) * 4), PAL.pearl, M.Glass)
	end
	b:Cyl(2, 16, CF(0, top + 1, 0), PAL.milk)
	b:Ellipsoid(V3(16.2, 7, 16.2), CF(0, top + 2, 0), PAL.white, M.Glass, { t = 0.35 })
	local strawTop = V3(4, top + 22, 2.4)
	b:Tube(V3(1, top + 3, 0.6), strawTop, 2, PAL.green, M.SmoothPlastic)
	local beacon = b:Ball(1, CF(strawTop), PAL.red, M.Neon, { solid = false })
	b:Light(beacon, PAL.red, 20, 1)

	-- lobby: info desk, gold lift, gift shop, pearl seats
	local f = 0.6
	b:Box(V3(3.4, 2.4, 1.2), CF(0, f + 1.2, 0.8), PAL.tea)
	b:Box(V3(3.6, 0.15, 1.4), CF(0, f + 2.45, 0.8), PAL.white, M.Marble)
	b:Person(CF(0, f, 2.2), { apron = PAL.tea, shirt = PAL.white, right = { 45, 15 }, left = { 30, 0 } })
	b:Box(V3(2.8, 7, 0.15), CF(0, f + 3.5, LW / 2 - 0.7), PAL.gold, M.Metal, { solid = false })
	b:Box(V3(0.06, 7, 0.16), CF(0, f + 3.5, LW / 2 - 0.71), PAL.woodDark, nil, { solid = false })
	local lift = b:Box(V3(3.2, 0.7, 0.1), CF(0, f + 7.6, LW / 2 - 0.75), PAL.black, nil, { solid = false })
	b:Text(lift, FACE.Front, "OBSERVATION DECK ↑", { color = PAL.yellow, glow = true })
	local gifts = CF(-LW / 2 + 1.3, f, 0) * ANG(0, rad(90), 0)
	b:Shelf(gifts, 6, 1.2, { 1.0, 2.4, 3.8 }, PAL.woodLight, function(level, y)
		for k = 1, 3 do
			local at = gifts * CF(-2 + (k - 1) * 2, y, 0)
			if (k + level) % 2 == 0 then
				b:TeaCup(at, 0.9)
			else
				b:Ball(0.8, at * CF(0, 0.4, 0), PAL.pearl, nil, { solid = false })
			end
		end
	end)
	for _, p in { V3(3.2, f + 0.7, -2.2), V3(4.6, f + 0.7, -3.4), V3(3.4, f + 0.7, -4.4) } do
		b:Ball(1.4, CF(p), PAL.pearl, M.Fabric)
	end
	b:Box(V3(1.2, 1.2, 1.2), CF(3.8, f + 0.6, 3), PAL.white, M.Marble)
	b:TeaCup(CF(3.8, f + 1.2, 3), 2.2)
	for i, x in { -3, 3 } do
		local strip = b:Box(V3(0.4, 0.12, 9), CF(x, 0.4 + LH - 0.1, 0), PAL.white, M.Neon, { solid = false })
		if i == 1 then
			b:Light(strip, PAL.warm, 14, 0.8)
		end
	end
end

---------------------------------------------------------------------------
-- shared decor (not purchasable): path lamps, trees, benches, bins, fountain
---------------------------------------------------------------------------
local Decor = {}

Decor.Lamp = function(b)
	b:Cyl(0.3, 1.2, CF(0, 0.15, 0), PAL.black, M.Metal)
	b:Cyl(9, 0.35, CF(0, 4.8, 0), PAL.black, M.Metal)
	b:Box(V3(0.2, 0.2, 1.6), CF(0, 9.1, -0.7), PAL.black, M.Metal, { solid = false })
	b:Box(V3(0.9, 0.5, 0.9), CF(0, 8.9, -1.4), PAL.black, M.Metal, { solid = false })
	local bulb = b:Box(V3(0.7, 0.15, 0.7), CF(0, 8.6, -1.4), PAL.warm, M.Neon, { solid = false })
	b:Light(bulb, PAL.warm, 16, 0.7)
end

Decor.Tree = function(b)
	b:Cyl(0.4, 2.4, CF(0, 0.2, 0), rgb(120, 110, 100), M.Cobblestone)
	b:Cyl(5, 0.8, CF(0, 2.5, 0), PAL.woodDark, M.Wood)
	b:Ellipsoid(V3(5, 3.6, 5), CF(0, 6.2, 0), PAL.leaf)
	b:Ellipsoid(V3(3.6, 2.8, 3.6), CF(0.8, 7.6, -0.5), PAL.leafDark)
	b:Ellipsoid(V3(3, 2.4, 3), CF(-1, 7.2, 0.8), rgb(100, 175, 80))
end

Decor.Bench = function(b)
	for _, x in { -1.6, 1.6 } do
		b:Box(V3(0.3, 1.5, 1.4), CF(x, 0.75, 0), PAL.black, M.Metal)
	end
	for i = 0, 2 do
		b:Box(V3(4, 0.15, 0.4), CF(0, 1.55, -0.45 + i * 0.45), PAL.wood, M.Wood)
	end
	for i = 0, 1 do
		b:Box(V3(4, 0.4, 0.12), CF(0, 2.1 + i * 0.5, 0.75), PAL.wood, M.Wood, { solid = false })
	end
end

Decor.Bin = function(b)
	b:Cyl(2, 1.1, CF(0, 1, 0), PAL.green)
	b:Cyl(0.2, 1.2, CF(0, 2.1, 0), PAL.greenDark)
end

Decor.Fountain = function(b)
	local WATER = rgb(90, 170, 220)
	b:Cyl(1.2, 13, CF(0, 0.6, 0), rgb(215, 205, 190), M.Marble)
	b:Cyl(0.2, 11.6, CF(0, 1.1, 0), WATER, M.Glass, { t = 0.25 })
	b:Cyl(3.4, 1.8, CF(0, 2.8, 0), rgb(215, 205, 190), M.Marble)
	b:Cyl(0.6, 5.5, CF(0, 4.6, 0), rgb(215, 205, 190), M.Marble)
	b:Cyl(0.1, 5, CF(0, 4.9, 0), WATER, M.Glass, { t = 0.25, solid = false })
	b:Ellipsoid(V3(5.4, 3, 5.4), CF(0, 3.3, 0), PAL.white, M.Glass, { t = 0.75 })
	b:Cyl(1.2, 0.8, CF(0, 5.5, 0), rgb(215, 205, 190), M.Marble)
	-- Thai tea cup on top of the fountain
	b:TeaCup(CF(0, 6.1, 0), 2.4)
	for k = 0, 7 do
		local a = rad(k * 45)
		b:Ball(0.5, CF(math.cos(a) * 5.4, 1.4, math.sin(a) * 5.4), PAL.white, nil, { t = 0.5, solid = false })
	end
end

-- plot entrance arch with a Thai-style roof
Decor.Arch = function(b)
	for _, x in { -24, 24 } do
		b:Box(V3(2.6, 0.8, 2.6), CF(x, 0.4, 0), PAL.white, M.Marble)
		b:Box(V3(2, 11.6, 2), CF(x, 6.6, 0), PAL.tea)
		b:Box(V3(2.4, 0.6, 2.4), CF(x, 12.1, 0), PAL.gold, M.Metal)
		for _, y in { 3, 6, 9 } do
			b:Box(V3(2.05, 0.2, 2.05), CF(x, y, 0), PAL.teaDark, nil, { solid = false })
		end
	end
	local beam = b:Box(V3(50, 2.4, 1.6), CF(0, 13.6, 0), PAL.greenDark)
	b:Text(beam, FACE.Front, "THAI TEA TYCOON", { color = PAL.gold, region = { 0.25, 0.05, 0.5, 0.9 } })
	b:Text(beam, FACE.Back, "THANK YOU · COME AGAIN", { color = PAL.gold, region = { 0.25, 0.1, 0.5, 0.8 } })
	b:Wedge(V3(52, 1.4, 1.4), CF(0, 15.5, -0.7), PAL.red, M.SmoothPlastic)
	b:Wedge(V3(52, 1.4, 1.4), CF(0, 15.5, 0.7) * ANG(0, rad(180), 0), PAL.red, M.SmoothPlastic)
	for _, x in { -26, 26 } do
		b:Wedge(V3(0.4, 1.6, 1.2), CF(x, 15.9, 0) * ANG(0, rad(if x < 0 then 90 else -90), 0), PAL.gold, M.Metal, { solid = false })
	end
	b:Box(V3(48, 0.15, 0.2), CF(0, 12.35, -0.85), PAL.warm, M.Neon, { solid = false })
	for i, x in { -15, -5, 5, 15 } do
		b:Box(V3(0.05, 0.8, 0.05), CF(x, 12.0, 0), PAL.black, nil, { solid = false })
		local lantern = b:Ellipsoid(V3(1.1, 1.4, 1.1), CF(x, 11.0, 0), if i % 2 == 0 then PAL.red else PAL.tea, M.Fabric)
		if i == 2 then
			b:Light(lantern, PAL.warm, 18, 0.7)
		end
	end
end

-- dark frame + corner studs around a 9x9 buy pad
Decor.PadFrame = function(b)
	for _, spec in { { V3(10, 0.5, 0.5), CF(0, 0.25, -4.75) }, { V3(10, 0.5, 0.5), CF(0, 0.25, 4.75) }, { V3(0.5, 0.5, 9), CF(-4.75, 0.25, 0) }, { V3(0.5, 0.5, 9), CF(4.75, 0.25, 0) } } do
		b:Box(spec[1], spec[2], PAL.black, M.Metal, { solid = false })
	end
	for _, x in { -4.75, 4.75 } do
		for _, z in { -4.75, 4.75 } do
			b:Box(V3(0.7, 0.3, 0.7), CF(x, 0.6, z), PAL.gold, M.Metal, { solid = false })
		end
	end
end

-- cash booth behind the register pad with a giant coin
Decor.RegisterBooth = function(b)
	b:Box(V3(3.4, 3.2, 1.8), CF(0, 1.6, 0), PAL.gold, M.Metal)
	b:Box(V3(3.6, 0.3, 2), CF(0, 3.35, 0), PAL.teaDark)
	b:Box(V3(1.2, 0.15, 0.05), CF(0, 2.4, -0.92), PAL.black, nil, { solid = false })
	local label = b:Box(V3(3, 0.8, 0.05), CF(0, 1.2, -0.92), PAL.white, nil, { t = 1, solid = false })
	b:Text(label, FACE.Front, "CASH", { color = PAL.teaDark })
	b:Cyl(1.2, 0.4, CF(0, 4.1, 0), PAL.steelDark, M.Metal)
	local coin = b:HCyl(0.45, 3, CF(0, 6.2, 0) * ANG(0, rad(90), 0), PAL.gold, M.Metal)
	b:Text(coin, FACE.Right, "฿", { color = PAL.teaDark })
	b:Text(coin, FACE.Left, "฿", { color = PAL.teaDark })
	b:Light(coin, PAL.gold, 10, 0.6)
end

-- spot lamps over the owner sign
Decor.SignLamps = function(b)
	for _, x in { -4.5, 0, 4.5 } do
		b:Rod(V3(x, 2.1, 0.2), V3(x, 2.8, -1.0), 0.12, PAL.black, M.Metal)
		b:Cyl(0.4, 0.45, CF(x, 2.7, -1.1), PAL.black, M.Metal, { solid = false })
		b:Ball(0.3, CF(x, 2.45, -1.1), PAL.warm, M.Neon, { solid = false })
	end
	b:Box(V3(13.6, 0.3, 1.1), CF(0, 2.15, 0), PAL.woodDark, M.Wood)
	b:Box(V3(13.6, 0.3, 1.1), CF(0, -2.15, 0), PAL.woodDark, M.Wood)
end

-- the Brew Station: a tea cart where the player brews by hand (the "Kettle" part holds the prompt)
-- Brew Station: customers queue at the front (-Z), the player brews from behind the counter (+Z) standing on
-- BrewPad. QueueStart (invisible) marks where the first customer waits; the queue runs toward -Z from it.
Decor.BrewStation = function(b)
	local pad = b:Box(V3(6, 0.4, 3.4), CF(0, 0.2, 4.2), PAL.tea, M.SmoothPlastic, { solid = false, name = "BrewPad", flat = true })
	b:Text(pad, FACE.Top, "BREW HERE", { color = PAL.white, region = { 0.1, 0.25, 0.8, 0.5 } })
	b:Box(V3(0.2, 0.2, 0.2), CF(0, 0.1, -1.6), PAL.white, nil, { t = 1, solid = false, name = "QueueStart" })

	-- counter: customers see the THAI TEA front, the brewer works on top from behind
	b:Box(V3(5, 3, 2.4), CF(0, 1.9, 1.2), PAL.woodLight, M.WoodPlanks)
	b:Box(V3(5.3, 0.25, 2.7), CF(0, 3.5, 1.2), PAL.white, M.Marble)
	local front = b:Box(V3(5, 1.2, 0.08), CF(0, 2.3, -0.04), PAL.green, nil, { solid = false })
	b:Text(front, FACE.Front, "THAI TEA", { color = PAL.cream })
	local order = b:Box(V3(2.2, 0.45, 0.08), CF(0, 1.3, -0.04), PAL.tea, nil, { solid = false })
	b:Text(order, FACE.Front, "ORDER HERE", { color = PAL.white })
	b:Cyl(0.3, 1.8, CF(-1.2, 3.75, 1.3), PAL.black)
	b:Cyl(0.1, 1.4, CF(-1.2, 3.92, 1.3), rgb(80, 150, 255), M.Neon, { solid = false })
	local kettle = b:Cyl(1.6, 1.6, CF(-1.2, 4.75, 1.3), PAL.steel, M.Metal, { name = "Kettle" })
	b:Ellipsoid(V3(1.6, 0.6, 1.6), CF(-1.2, 5.55, 1.3), PAL.steel, M.Metal)
	b:Tube(V3(-0.5, 5.0, 1.0), V3(0.2, 5.5, 0.6), 0.2, PAL.steel, M.Metal)
	b:Box(V3(0.2, 0.9, 0.2), CF(-1.2, 4.9, 2.15), PAL.black, nil, { solid = false })
	b:Ball(0.8, CF(-1.0, 6.3, 1.3), PAL.white, nil, { t = 0.6, solid = false, name = "Steam" })
	for i = 0, 2 do
		b:TeaCup(CF(0.8 + i * 0.6, 3.62, 0.6), 1, if i == 1 then rgb(120, 180, 90) else nil)
	end
	b:Cyl(1.3, 0.5, CF(2.1, 3.62 + 0.65, 1.9), PAL.white, M.Glass, { t = 0.45, solid = false })
	b:Ellipsoid(V3(0.4, 0.3, 0.4), CF(0.9, 3.75, 1.9), PAL.gold, M.Metal)
	b:Box(V3(0.6, 0.6, 0.06), CF(2.15, 3.3, -0.08), PAL.white, M.Fabric, { solid = false })
	b:Box(V3(0.6, 0.1, 0.07), CF(2.15, 3.1, -0.09), PAL.red, M.Fabric, { solid = false })

	-- back bench behind the brewer: condensed milk, sugar jar, strainer
	b:Box(V3(4.8, 3, 1.2), CF(0, 1.5, 6.5), PAL.woodDark, M.Wood)
	b:Box(V3(5.0, 0.2, 1.4), CF(0, 3.1, 6.5), PAL.white, M.Marble, { flat = true })
	for i = 0, 1 do
		b:Cyl(0.45, 0.4, CF(-1.6 + i * 0.45, 3.42, 6.5), PAL.white, M.Metal, { solid = false })
		b:Cyl(0.2, 0.41, CF(-1.6 + i * 0.45, 3.42, 6.5), PAL.blue, nil, { solid = false })
	end
	b:Cyl(0.55, 0.45, CF(-0.3, 3.47, 6.5), PAL.white, M.Glass, { t = 0.4, solid = false })
	b:Cyl(0.35, 0.4, CF(-0.3, 3.37, 6.5), PAL.white, nil, { solid = false })
	b:Ellipsoid(V3(0.55, 0.3, 0.55), CF(1.0, 3.35, 6.5), rgb(215, 150, 95), M.Fabric)
	b:Rod(V3(1.0, 3.4, 6.5), V3(1.3, 3.9, 6.0), 0.07, PAL.woodDark)
	for i = 0, 2 do
		b:Cyl(0.4, 0.5, CF(1.9, 3.4 + i * 0.3, 6.5), PAL.white, M.Glass, { t = 0.45, solid = false })
	end

	-- frame over the back bench: posts, canister shelf, bunting, lamp, sign, price board
	for _, x in { -2.7, 2.7 } do
		b:Box(V3(0.25, 7.8, 0.25), CF(x, 3.9, 6.9), PAL.woodDark, M.Wood)
	end
	b:Box(V3(5.2, 0.15, 0.6), CF(0, 5.4, 6.8), PAL.woodDark, M.Wood, { solid = false })
	for i, spec in { { PAL.tea, "TEA" }, { PAL.green, "GREEN" }, { PAL.red, "ROSE" }, { PAL.teaDark, "COCOA" } } do
		local x = -1.65 + (i - 1) * 1.1
		local can = b:Cyl(0.9, 0.6, CF(x, 5.93, 6.8), spec[1], M.Metal, { solid = false })
		b:Cyl(0.12, 0.64, CF(x, 6.44, 6.8), PAL.steel, M.Metal, { solid = false })
		local label = b:Box(V3(0.5, 0.3, 0.02), CF(x, 5.9, 6.49), PAL.cream, nil, { solid = false })
		b:Text(label, FACE.Front, spec[2], { color = PAL.black })
		can.Name = "Canister"
	end
	b:Rod(V3(-2.7, 7.3, 6.75), V3(2.7, 7.3, 6.75), 0.04, PAL.black)
	for i = 0, 7 do
		b:Wedge(V3(0.05, 0.45, 0.4), CF(-2.3 + i * 0.65, 7.05, 6.75) * ANG(rad(180), rad(90), 0), if i % 2 == 0 then PAL.tea else PAL.white, M.Fabric, { solid = false })
	end
	local sign = b:Box(V3(5.8, 1.1, 0.25), CF(0, 8.2, 6.9), PAL.tea)
	b:Text(sign, FACE.Front, "BREW STATION", { color = PAL.white })
	local lamp = b:Ball(0.4, CF(0, 7.5, 6.6), PAL.warm, M.Neon, { solid = false })
	b:Light(lamp, PAL.warm, 12, 0.7)
	b:Box(V3(0.7, 0.1, 0.1), CF(-3.1, 6.0, 6.9), PAL.black, M.Metal, { solid = false })
	local price = b:Box(V3(1.1, 1.4, 0.08), CF(-3.4, 5.2, 6.9), rgb(30, 35, 32), nil, { solid = false })
	b:Text(price, FACE.Front, "HOT\nICED\nBIG", { color = PAL.cream, font = Enum.Font.GothamBold })

	-- queue mat in front, ice bucket and tea sacks at the sides
	local mat = b:Box(V3(2.6, 0.05, 7.4), CF(0, 0.03, -5.0), PAL.red, M.Fabric, { flat = true, solid = false })
	b:Text(mat, FACE.Top, "QUEUE", { color = PAL.white, region = { 0.1, 0.35, 0.8, 0.3 } })
	b:Cyl(1.0, 1.1, CF(3.3, 0.5, 1.4), PAL.steel, M.Metal)
	for i = 0, 3 do
		b:Box(V3(0.25, 0.25, 0.25), CF(3.1 + (i % 2) * 0.35, 1.05, 1.25 + math.floor(i / 2) * 0.3) * ANG(0, i, 0), PAL.glass, M.Glass, { t = 0.3, solid = false })
	end
	b:Rod(V3(3.3, 1.0, 1.4), V3(3.6, 1.5, 1.9), 0.08, PAL.steel, M.Metal)
	for i = 0, 1 do
		local sack = b:Box(V3(1.1, 1.2, 0.9), CF(-3.3, 0.6, 1.9 - i * 1.0) * ANG(0, rad(i * 12), 0), PAL.cream, M.Fabric)
		if i == 1 then
			b:Text(sack, FACE.Front, "TEA", { color = PAL.teaDark, region = { 0.1, 0.3, 0.8, 0.4 } })
		end
	end
	return kettle
end

-- a customer for the Brew Station queue (animated on each player's client). variant picks the outfit.
-- The "Cup" sub-model is hidden until the customer is served (each part keeps its own transparency in T0).
Decor.Customer = function(b, variant)
	local outfits = {
		{ PAL.pink, PAL.blue, PAL.hair, false }, { PAL.blue, PAL.black, rgb(120, 70, 40), true },
		{ PAL.yellow, PAL.blue, PAL.hair, true }, { PAL.green, PAL.cream, rgb(200, 150, 80), false },
		{ PAL.red, PAL.black, PAL.hair, true }, { PAL.white, rgb(90, 110, 80), rgb(120, 70, 40), false },
	}
	local o = outfits[((variant or 1) - 1) % #outfits + 1]
	local hands = b:Person(CF(), { shirt = o[1], apron = o[1], pants = o[2], hair = o[3], long = o[4], right = { 55, 15 }, left = { 10, 0 } })
	local cupModel = Instance.new("Model")
	cupModel.Name = "Cup"
	cupModel.Parent = b.Model
	local cb = newBuilder(cupModel, b.Origin)
	cb.Round = false
	cb:TeaCup(CF(hands.right) * CF(0, -0.35, 0), 0.9, if (variant or 1) % 3 == 0 then rgb(120, 180, 90) else nil)
	for _, part in cupModel:GetChildren() do
		part.Name = "Cup"
	end
end

-- plot ground: a floor for each zone (flat, walk-through, 0.04 thick), grout/lane lines, the central brick path
-- and flower beds. Origin = plot floor center (front = -Z). Built once per plot, before anything is bought.
local function zone(b, x0: number, x1: number, z0: number, z1: number, color: Color3, material: Enum.Material, trim: Color3)
	local cx, cz, w, d = (x0 + x1) / 2, (z0 + z1) / 2, x1 - x0, z1 - z0
	b:Box(V3(w, 0.04, d), CF(cx, 0.02, cz), color, material, { flat = true, solid = false })
	for _, side in { -1, 1 } do
		b:Box(V3(w + 0.6, 0.06, 0.3), CF(cx, 0.03, cz + side * d / 2), trim, nil, { flat = true, solid = false })
		b:Box(V3(0.3, 0.06, d), CF(cx + side * w / 2, 0.03, cz), trim, nil, { flat = true, solid = false })
	end
end

local function flowerBed(b, cf: CFrame, seed: number)
	b:Box(V3(3.2, 0.8, 3.2), cf * CF(0, 0.4, 0), PAL.woodDark, M.Wood)
	b:Box(V3(2.8, 0.1, 2.8), cf * CF(0, 0.8, 0), rgb(80, 55, 35), nil, { flat = true, solid = false })
	b:Ellipsoid(V3(2.2, 1.4, 2.2), cf * CF(0, 1.3, 0), PAL.leaf)
	local rand = seeded(seed)
	local colors = { PAL.pink, PAL.yellow, PAL.white, rgb(255, 110, 150), PAL.tea }
	for i = 1, 7 do
		local a, r = rand() * math.pi * 2, 0.5 + rand() * 0.6
		b:Ball(0.35, cf * CF(math.cos(a) * r, 1.5 + rand() * 0.5, math.sin(a) * r), colors[i % #colors + 1], nil, { solid = false })
	end
end

Decor.PlotGround = function(b)
	-- tier 1: terracotta street tiles under the tea cart
	zone(b, -36, -8, -50, -28, rgb(200, 128, 96), M.Brick, rgb(150, 90, 65))
	-- tier 2: wooden deck under the street shop
	zone(b, 8, 40, -50, -26, rgb(190, 145, 100), M.WoodPlanks, PAL.woodDark)
	-- tier 3: cream cafe tiles with grout lines every 4 studs
	zone(b, -42, 42, -25, 1, rgb(242, 232, 214), M.SmoothPlastic, PAL.woodDark)
	for x = -38, 38, 4 do
		b:Box(V3(0.08, 0.05, 26), CF(x, 0.03, -12), rgb(215, 200, 178), nil, { flat = true, solid = false })
	end
	for z = -21, -3, 4 do
		b:Box(V3(84, 0.05, 0.08), CF(0, 0.03, z), rgb(215, 200, 178), nil, { flat = true, solid = false })
	end
	-- tier 4: asphalt yard with yellow edge lines and a dashed lane behind the buildings
	zone(b, -58, 58, 4, 40, rgb(70, 72, 78), M.Asphalt, PAL.yellow)
	for x = -55, 55, 6 do
		b:Box(V3(3, 0.05, 0.3), CF(x, 0.03, 39), PAL.white, nil, { flat = true, solid = false })
	end
	-- tier 5: lawn around the big buildings
	zone(b, -58, 58, 42, 139, rgb(96, 170, 80), M.Grass, rgb(70, 130, 60))
	-- brick path from the entrance to the cafe (between the cart and the shop)
	zone(b, -5, 5, -50, -25, rgb(180, 95, 70), M.Brick, PAL.concrete)
	for z = -47, -29, 6 do
		b:Box(V3(3, 0.06, 1.2), CF(0, 0.04, z), PAL.concrete, nil, { flat = true, solid = false })
	end
	-- flower beds beside the path entrance and along the side hedges
	for i, spot in { { -7.5, -49 }, { 7.5, -49 }, { -55, -35 }, { 55, -35 }, { -55, -15 }, { 55, -15 } } do
		flowerBed(b, CF(spot[1], 0, spot[2]), 40 + i)
	end
end

-- frame + corner lights around an upgrade pad (pad is 6 x 6, frame sits on the floor around it)
Decor.UpgradeFrame = function(b, variant)
	local colors = { PAL.blue, PAL.tea, rgb(170, 90, 220) }
	local glow = colors[variant or 1] or PAL.white
	for _, side in { -1, 1 } do
		b:Box(V3(7.2, 0.35, 0.6), CF(0, 0.18, side * 3.3), PAL.black, nil, { flat = true, solid = false })
		b:Box(V3(0.6, 0.35, 6), CF(side * 3.3, 0.18, 0), PAL.black, nil, { flat = true, solid = false })
	end
	for _, x in { -3.3, 3.3 } do
		for _, z in { -3.3, 3.3 } do
			b:Cyl(0.5, 0.5, CF(x, 0.35, z), glow, M.Neon, { solid = false })
		end
	end
end

-- a hired barista with a small tea cart; variant picks the apron color (0 = gold VIP barista)
Decor.StaffCart = function(b, variant)
	local aprons = { PAL.tea, PAL.green, PAL.blue, PAL.red, PAL.pink, PAL.teaDark }
	local vip = variant == 0
	local apron = if vip then PAL.gold else aprons[((variant or 1) - 1) % #aprons + 1]
	b:Box(V3(3.2, 2.9, 1.6), CF(0, 1.45, 0.4), if vip then PAL.gold else PAL.woodLight, if vip then M.Metal else M.WoodPlanks)
	b:Box(V3(3.4, 0.2, 1.8), CF(0, 3.0, 0.4), PAL.white, M.Marble, { flat = true })
	local front = b:Box(V3(3.0, 0.8, 0.06), CF(0, 2.1, -0.42), apron, nil, { solid = false })
	b:Text(front, FACE.Front, if vip then "VIP" else "THAI TEA", { color = PAL.white })
	b:Cyl(1.0, 0.9, CF(-0.9, 3.6, 0.6), PAL.steel, M.Metal)
	b:Ellipsoid(V3(0.9, 0.4, 0.9), CF(-0.9, 4.15, 0.6), PAL.steel, M.Metal)
	b:TeaCup(CF(0.4, 3.1, 0.2), 0.9)
	b:TeaCup(CF(1.0, 3.1, 0.2), 0.9, rgb(120, 180, 90))
	local hands = b:Person(CF(0, 0, 1.9), { apron = apron, cap = apron, right = { 150, 20 }, left = { 60, 30 } })
	b:Cyl(0.6, 0.5, CF(hands.right) * CF(0, -0.1, 0), PAL.steel, M.Metal)
	b:TeaCup(CF(hands.left) * CF(0, -0.2, 0), 1.1)
	b:Rod(hands.right - V3(0, 0.4, 0), hands.left + V3(0, 0.8, 0), 0.12, PAL.tea, M.Glass, { t = 0.15 })
	-- wheels with hubs, push handle, mini canopy on a pole, cup stack and a service bell
	for _, x in { -1.35, 1.35 } do
		b:HCyl(0.25, 1.0, CF(x * 1.12, 0.5, -0.1), PAL.black, nil, { solid = false })
		b:HCyl(0.27, 0.35, CF(x * 1.12, 0.5, -0.1), PAL.steel, M.Metal, { solid = false })
	end
	b:Tube(V3(-1.4, 2.9, 1.3), V3(1.4, 2.9, 1.3), 0.12, PAL.steel, M.Metal)
	b:Cyl(7.3, 0.15, CF(-1.75, 3.65, 2.4), PAL.white, M.Metal, { solid = false })
	for k = 0, 3 do
		b:Wedge(V3(3.6, 0.7, 1.8), CF(-1.75, 7.3, 2.4) * ANG(0, rad(90 * k), 0) * CF(0, 0.35, -0.9), if k % 2 == 0 then apron else PAL.white, M.Fabric, { solid = false })
	end
	b:Ball(0.3, CF(-1.75, 8.05, 2.4), apron, nil, { solid = false })
	for i = 0, 2 do
		b:Cyl(0.4, 0.5, CF(-1.3, 3.3 + i * 0.3, 0.9), PAL.white, M.Glass, { t = 0.45, solid = false })
	end
	b:Ellipsoid(V3(0.4, 0.3, 0.4), CF(1.4, 3.25, 0.9), PAL.gold, M.Metal)
	if vip then
		local crown = b:Ball(0.5, CF(0, 6.2, 1.9), PAL.gold, M.Neon, { solid = false })
		b:Light(crown, PAL.gold, 8, 0.6)
	end
end

---------------------------------------------------------------------------
-- Real-world size. A character is ~5.5 studs (1.75 m), so 1 stud ≈ 0.32 m. The small props are built at that
-- scale; the big buildings were built too small, so they are enlarged after building:
--   Footprint: walls, floors, roofs (Shell parts) and parts spanning half the building grow in X/Z by the factor;
--              everything else (people, counters, tables, cups, shelves...) keeps its size and is only moved,
--              one cluster of touching parts at a time, so rooms get bigger while the furniture stays life-size.
--              Heights stay the same (a storey is already ~3 m).
--   Uniform:   the whole model grows (vehicles).
---------------------------------------------------------------------------
ItemModels.Footprint = {
	L29 = 1.5, -- central kitchen
	L34 = 1.3, -- cold room
	L35 = 1.4, -- tea roastery
	L38 = 2.0, -- tea plantation
	L39 = 1.6, -- bottling factory
	L40 = 1.6, -- distribution center
	L41 = 1.8, -- headquarters
	L42 = 1.6, -- mall branch
	L43 = 1.6, -- airport branch
	L44 = 1.3, -- nationwide franchise
	L45 = 1.9, -- thai tea tower
}
ItemModels.Uniform = {
	L07 = 1.3, -- market umbrella
	L28 = 1.25, -- brick wall + neon sign
	L30 = 1.4, -- delivery van
	L37 = 1.5, -- billboard
}
-- decor that should read big from the plaza, scaled the same way
ItemModels.DecorUniform = { Arch = 1.3, Lamp = 1.3, Tree = 1.5, Fountain = 1.4 }

local CLUSTER_GAP = 0.5 -- parts closer than this belong to the same piece of furniture

-- local axis-aligned bounds of a part (relative to origin)
local function localBounds(cf: CFrame, size: Vector3): (Vector3, Vector3)
	local half = (cf.RightVector * size.X):Abs() / 2 + (cf.UpVector * size.Y):Abs() / 2 + (cf.LookVector * size.Z):Abs() / 2
	return cf.Position - half, cf.Position + half
end

-- target { local CFrame, size } for every part, computed once per item key (every plot builds the same model)
local stretchCache: { [string]: { { CFrame | Vector3 } } } = {}

local function planStretch(parts: { BasePart }, origin: CFrame, k: number): { { CFrame | Vector3 } }
	local n = #parts
	local cfs, mins, maxs = table.create(n), table.create(n), table.create(n)
	local lo, hi = Vector3.new(math.huge, 0, math.huge), Vector3.new(-math.huge, 0, -math.huge)
	for i, part in parts do
		cfs[i] = origin:ToObjectSpace(part.CFrame)
		mins[i], maxs[i] = localBounds(cfs[i], part.Size)
		lo, hi = lo:Min(mins[i]), hi:Max(maxs[i])
	end
	local span = math.min(hi.X - lo.X, hi.Z - lo.Z)
	local structure = table.create(n, false)
	for i, part in parts do
		local extent = math.max(maxs[i].X - mins[i].X, maxs[i].Z - mins[i].Z)
		structure[i] = part:GetAttribute("Structure") == true or extent >= span * 0.5
	end

	-- union-find over touching non-structure parts (grid hash keeps it fast)
	local parent = table.create(n, 0)
	for i = 1, n do
		parent[i] = i
	end
	local function find(i: number): number
		while parent[i] ~= i do
			parent[i] = parent[parent[i]]
			i = parent[i]
		end
		return i
	end
	local CELL = 4
	local grid: { [string]: { number } } = {}
	for i = 1, n do
		if not structure[i] then
			for gx = math.floor((mins[i].X - CLUSTER_GAP) / CELL), math.floor((maxs[i].X + CLUSTER_GAP) / CELL) do
				for gz = math.floor((mins[i].Z - CLUSTER_GAP) / CELL), math.floor((maxs[i].Z + CLUSTER_GAP) / CELL) do
					local key = gx .. "," .. gz
					local bucket = grid[key]
					if not bucket then
						bucket = {}
						grid[key] = bucket
					end
					for _, j in bucket do
						if mins[i].X - CLUSTER_GAP <= maxs[j].X and mins[j].X - CLUSTER_GAP <= maxs[i].X
							and mins[i].Y - CLUSTER_GAP <= maxs[j].Y and mins[j].Y - CLUSTER_GAP <= maxs[i].Y
							and mins[i].Z - CLUSTER_GAP <= maxs[j].Z and mins[j].Z - CLUSTER_GAP <= maxs[i].Z then
							parent[find(i)] = find(j)
						end
					end
					table.insert(bucket, i)
				end
			end
		end
	end
	local sums: { [number]: Vector3 } = {}
	local counts: { [number]: number } = {}
	for i = 1, n do
		if not structure[i] then
			local root = find(i)
			sums[root] = (sums[root] or Vector3.zero) + (mins[i] + maxs[i]) / 2
			counts[root] = (counts[root] or 0) + 1
		end
	end

	local plan = table.create(n)
	for i, part in parts do
		local cf = cfs[i]
		if structure[i] then
			-- grow along whichever local axes lie flat; keep heights
			local size = part.Size
			local function grow(axis: Vector3, length: number): number
				return if math.abs(axis.Y) < 0.7 then length * k else length
			end
			local newSize = Vector3.new(grow(cf.RightVector, size.X), grow(cf.UpVector, size.Y), grow(cf.LookVector, size.Z))
			local p = cf.Position
			plan[i] = { CFrame.new(p.X * k, p.Y, p.Z * k) * cf.Rotation, newSize }
		else
			local root = find(i)
			local center = sums[root] / counts[root]
			local shift = Vector3.new(center.X * (k - 1), 0, center.Z * (k - 1))
			plan[i] = { cf + shift, part.Size }
		end
	end
	return plan
end

local function stretch(key: string, model: Model, origin: CFrame, k: number)
	local parts = {}
	for _, d in model:GetChildren() do
		if d:IsA("BasePart") then
			table.insert(parts, d)
		end
	end
	local plan = stretchCache[key]
	if not plan or #plan ~= #parts then
		plan = planStretch(parts, origin, k)
		stretchCache[key] = plan
	end
	for i, part in parts do
		local target = plan[i]
		part.Size = target[2] :: Vector3
		part.CFrame = origin * (target[1] :: CFrame)
	end
end

---------------------------------------------------------------------------
-- API
---------------------------------------------------------------------------
function ItemModels.Has(key: string): boolean
	return Build[key] ~= nil
end

-- build the model for key at origin (world CFrame); returns an unparented Model
function ItemModels.Build(key: string, origin: CFrame): Model?
	local build = Build[key]
	if not build then
		return nil
	end
	local model = Instance.new("Model")
	model.Name = key
	local b = newBuilder(model, origin)
	build(b)
	if ItemModels.Footprint[key] then
		stretch(key, model, origin, ItemModels.Footprint[key])
	elseif ItemModels.Uniform[key] then
		model.WorldPivot = origin
		model:ScaleTo(ItemModels.Uniform[key])
	end
	model.WorldPivot = origin
	return model
end

-- build a decor piece (Lamp, Tree, Bench, Bin, Fountain); returns an unparented Model
function ItemModels.BuildDecor(kind: string, origin: CFrame, variant: number?): Model?
	local build = Decor[kind]
	if not build then
		return nil
	end
	local model = Instance.new("Model")
	model.Name = kind
	build(newBuilder(model, origin), variant)
	local k = ItemModels.DecorUniform[kind]
	if k then
		model.WorldPivot = origin
		model:ScaleTo(k)
	end
	return model
end

-- world CFrame of the buy pad spot for key (on the floor), or nil
function ItemModels.PadIn(key: string, plotFloor: CFrame): CFrame?
	local spot = ItemModels.PadSpots[key]
	if not spot then
		return nil
	end
	return plotFloor * CF(spot[1], 0, spot[2])
end

-- world CFrame for key, given the CFrame of the plot's floor center
function ItemModels.PlaceIn(key: string, plotFloor: CFrame): CFrame?
	local spot = ItemModels.Layout[key]
	if not spot then
		return nil
	end
	return plotFloor * CF(spot[1], spot[2], spot[3]) * ANG(0, rad(spot[4]), 0)
end

return ItemModels
