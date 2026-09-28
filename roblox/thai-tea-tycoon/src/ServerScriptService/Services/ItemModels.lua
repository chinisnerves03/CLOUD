-- ItemModels: โมเดลของที่ซื้อได้ทั้ง 44 ชิ้น (L02..L45) สร้างจาก Part ล้วน ไม่ต้องใช้ไฟล์โมเดล
-- ใช้โดย DevPlotBuilder: ItemModels.Build(key, origin) คืน Model ที่วางไว้ตำแหน่ง origin แล้ว
-- ผังตำแหน่งในฐานอยู่ใน ItemModels.Layout (พิกัดในฐาน: ด้านหน้า = -Z หันเข้าลานกลาง, y = 0 คือผิวพื้น)

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
-- ตัวช่วยประกอบ Part (ตำแหน่งทั้งหมดเป็นพิกัดเทียบกับจุดตั้งของโมเดล)
---------------------------------------------------------------------------
local Builder = {}
Builder.__index = Builder

local function newBuilder(model: Model, origin: CFrame)
	return setmetatable({ Model = model, Origin = origin, Count = 0 }, Builder)
end

-- opts: t = ความโปร่งใส, solid = บังคับชน/ไม่ชน, name = ชื่อ, refl = การสะท้อน
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

function Builder:Box(size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, opts): Part
	return self:_part("Part", size, cf, color, material, opts)
end

-- ทรงกระบอกตั้ง (สูง h, เส้นผ่านศูนย์กลาง d)
function Builder:Cyl(h: number, d: number, cf: CFrame, color: Color3, material: Enum.Material?, opts): Part
	local p = self:_part("Part", V3(h, d, d), cf * ANG(0, 0, rad(90)), color, material, opts)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- ทรงกระบอกนอน แกนตามแกน X ของ cf
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

-- ทรงรี (ยืด/บีบได้ทุกแกน) ใช้ SpecialMesh ทรงกลม
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

-- ลิ่ม: ด้านสูงอยู่หลัง (+Z) ลาดลงมาด้านหน้า (-Z)
function Builder:Wedge(size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, opts): WedgePart
	return self:_part("WedgePart", size, cf, color, material, opts)
end

-- แท่งจากจุด a ไปจุด b
function Builder:Rod(a: Vector3, b: Vector3, thick: number, color: Color3, material: Enum.Material?, opts): Part
	local length = (b - a).Magnitude
	opts = opts or {}
	if opts.solid == nil then
		opts.solid = false
	end
	return self:_part("Part", V3(thick, thick, length), CFrame.lookAt((a + b) / 2, b), color, material, opts)
end

-- ท่อกลมจากจุด a ไปจุด b
function Builder:Tube(a: Vector3, b: Vector3, d: number, color: Color3, material: Enum.Material?, opts): Part
	local length = (b - a).Magnitude
	opts = opts or {}
	if opts.solid == nil then
		opts.solid = false
	end
	return self:HCyl(length, d, CFrame.lookAt((a + b) / 2, b) * ANG(0, rad(90), 0), color, material, opts)
end

-- ข้อความบนหน้า Part (opts: color, bg, bgT, glow, font, region = {x, y, w, h} เป็นสัดส่วน, ppu)
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

-- คนแบบบล็อก สูง ~5.5 หันหน้าไป -Z
-- style: shirt, pants, apron, cap, skin, left/right = {pitch, yaw} (องศา: pitch > 0 = ยกแขนไปด้านหน้า, yaw = หุบแขนเข้าหาตัว)
-- คืนตำแหน่งมือ (พิกัดโมเดล) ไว้วางของที่ถือ
function Builder:Person(cf: CFrame, style)
	style = style or {}
	local skin = style.skin or PAL.skin
	local shirt = style.shirt or PAL.white
	local pants = style.pants or PAL.black
	local apron = style.apron or PAL.tea

	for _, x in { -0.5, 0.5 } do
		self:Box(V3(0.9, 2, 0.9), cf * CF(x, 1, 0), pants, nil, { solid = false })
		self:Box(V3(0.95, 0.35, 1.2), cf * CF(x, 0.18, -0.12), PAL.black, nil, { solid = false })
	end
	self:Box(V3(2, 2, 1), cf * CF(0, 3, 0), shirt)
	self:Box(V3(1.7, 2.3, 0.1), cf * CF(0, 2.45, -0.56), apron, M.Fabric, { solid = false })
	self:Box(V3(0.6, 0.4, 0.05), cf * CF(0, 3.1, -0.62), PAL.cream, nil, { solid = false })

	local hands = {}
	for side, key in { [-1] = "left", [1] = "right" } do
		local pose = style[key] or { 25, 0 }
		-- yaw บวก = หุบเข้ากลางตัว ทั้งสองข้าง
		local shoulder = cf * CF(side * 1.45, 3.85, 0) * ANG(0, rad((pose[2] or 0) * side), 0) * ANG(rad(pose[1]), 0, 0)
		self:Box(V3(0.85, 1.05, 0.85), shoulder * CF(0, -0.5, 0), shirt, nil, { solid = false })
		self:Box(V3(0.75, 1.1, 0.75), shoulder * CF(0, -1.5, 0), skin, nil, { solid = false })
		hands[key] = (shoulder * CF(0, -2.2, 0)).Position
	end

	self:Ball(1.3, cf * CF(0, 4.7, 0), skin, nil, { solid = false })
	self:Ellipsoid(V3(1.4, 0.8, 1.4), cf * CF(0, 5.1, 0.12), PAL.hair)
	for _, x in { -0.25, 0.25 } do
		self:Box(V3(0.14, 0.2, 0.05), cf * CF(x, 4.8, -0.64), PAL.black, nil, { solid = false })
	end
	self:Box(V3(0.4, 0.07, 0.05), cf * CF(0, 4.45, -0.62), rgb(170, 90, 80), nil, { solid = false })
	if style.cap then
		self:Cyl(0.4, 1.45, cf * CF(0, 5.3, 0.05), style.cap)
		self:Box(V3(1.1, 0.1, 0.7), cf * CF(0, 5.15, -0.75), style.cap, nil, { solid = false })
	elseif style.chefHat then
		self:Cyl(0.8, 1.3, cf * CF(0, 5.55, 0.05), PAL.white)
		self:Ellipsoid(V3(1.6, 0.7, 1.6), cf * CF(0, 6.0, 0.05), PAL.white)
	elseif style.ngob then -- งอบชาวไร่
		self:Ellipsoid(V3(2.4, 0.5, 2.4), cf * CF(0, 5.35, 0.05), rgb(215, 185, 120))
		self:Ellipsoid(V3(1.1, 0.6, 1.1), cf * CF(0, 5.6, 0.05), rgb(200, 165, 100))
	end
	return hands
end

-- แก้วชาไทย (ก้นแก้วอยู่ที่ cf)
function Builder:TeaCup(cf: CFrame, scale: number?, drink: Color3?)
	local s = scale or 1
	self:Cyl(0.9 * s, 0.45 * s, cf * CF(0, 0.45 * s, 0), drink or PAL.tea)
	self:Cyl(0.15 * s, 0.47 * s, cf * CF(0, 0.95 * s, 0), PAL.milk)
	self:Ellipsoid(V3(0.47, 0.25, 0.47) * s, cf * CF(0, 1.05 * s, 0), PAL.white, M.Glass, { t = 0.4 })
	self:Rod(V3(0, 1.0 * s, 0), V3(0.12 * s, 1.75 * s, 0.05 * s), 0.08 * s, PAL.green)
end

-- ต้นไม้ในกระถาง
function Builder:Plant(cf: CFrame, height: number?)
	local h = height or 2
	self:Cyl(1.1, 1.1, cf * CF(0, 0.55, 0), rgb(190, 100, 60))
	self:Cyl(0.1, 0.95, cf * CF(0, 1.1, 0), rgb(80, 55, 35))
	self:Ellipsoid(V3(1.5, h, 1.5), cf * CF(0, 1.1 + h / 2, 0), PAL.leaf)
	self:Ellipsoid(V3(1.0, h * 0.7, 1.0), cf * CF(0.3, 1.3 + h * 0.6, -0.2), PAL.leafDark)
end

-- ขาโต๊ะ/ขาตู้ 4 ขา
function Builder:Legs(width: number, depth: number, height: number, thick: number, cf: CFrame, color: Color3)
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			self:Box(V3(thick, height, thick), cf * CF(x * width / 2, height / 2, z * depth / 2), color, M.Metal, { solid = false })
		end
	end
end

-- อาคารกลวงเดินเข้าได้: พื้น + ผนัง 4 ด้าน (เจาะประตู/หน้าต่าง) + หลังคาแบน
-- spec: w, d, h, t (ความหนาผนัง), wall, wallMat, wallT, floor, floorMat, roof (false = ไม่ทำ), roofColor
--       openings = { { side = "Front"|"Back"|"Left"|"Right", x = กึ่งกลางตามแนวผนัง, y = ขอบล่าง, w, h, glass = true/false } }
-- ประตูที่เดินผ่านได้: glass = false, y = 0, h >= 7
function Builder:Shell(cf: CFrame, spec)
	local w, d, h = spec.w, spec.d, spec.h
	local t = spec.t or 0.6
	local wallOpts = { t = spec.wallT, solid = true }
	self:Box(V3(w - 2 * t, 0.2, d - 2 * t), cf * CF(0, 0.1, 0), spec.floor or PAL.concrete, spec.floorMat or M.Concrete, { solid = true })

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
		self:Box(V3(w, 0.6, d), cf * CF(0, h + 0.3, 0), spec.roofColor or spec.wall, spec.wallMat)
	end
end

-- ชั้นวางของติดผนัง: ยาวตามแกน X ของ cf, ของบนชั้นมาจาก fill(ช่องที่, x, yบนชั้น)
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

-- ตัวสุ่มแบบกำหนดผลได้ (ให้ทุกฐานหน้าตาเหมือนกัน)
local function seeded(seed: number)
	local state = seed
	return function(): number
		state = (state * 1103515245 + 12345) % 2147483648
		return state / 2147483648
	end
end

---------------------------------------------------------------------------
-- ผังวางของในฐาน { x, y, z, หมุนรอบแกน Y (องศา) }
-- ฐานกว้าง 100 (x -50..50) ลึก 130 (z -65 หน้า .. 65 หลัง)
---------------------------------------------------------------------------
ItemModels.Layout = {
	-- ขั้น 1: รถเข็นชาไทย (หน้าซ้าย)
	L02 = { -20, 0, -41, 0 },
	L03 = { -25.4, 0, -41, 0 },
	L04 = { -14.2, 0, -40.5, 0 },
	L05 = { -13.8, 0, -35.5, 0 },
	L06 = { -18.4, 3, -41, 0 },
	L07 = { -20, 0, -38.4, 0 },
	L08 = { -27, 0, -46.5, 0 },
	L09 = { -21.6, 3, -41, 0 },
	L10 = { -31.5, 0, -37, 0 },
	-- ขั้น 2: ร้านเล็กริมทาง (หน้าขวา)
	L11 = { 20, 0, -37, 0 },
	L12 = { 24.8, 3.5, -36.6, 0 },
	L13 = { 19.5, 3.5, -37, 0 },
	L14 = { 23.5, 0, -32.2, 0 },
	L15 = { 20, 0, -41.8, 0 },
	L16 = { 32.5, 0, -45, 0 },
	L17 = { 22, 0, -39, 0 },
	L18 = { 14.2, 3.5, -37, 0 },
	L19 = { 17.5, 0, -33.6, 0 },
	-- ขั้น 3: คาเฟ่ (กลาง)
	L20 = { -31, 0, -19, 0 },
	L21 = { -19, 0, -6, 0 },
	L22 = { -23.5, 0, -19, 0 },
	L23 = { 16.5, 0, -16, 0 },
	L24 = { 31, 0, -9, 0 },
	L25 = { -37.2, 0, -8, 0 },
	L26 = { -29.5, 0, -4.5, 0 },
	L27 = { 0, 0, -13, 0 },
	L28 = { 0, 0, -3.5, 0 },
	-- ขั้น 4: ครัวกลาง + โลจิสติกส์ (อาคารเดินเข้าได้)
	L29 = { -38, 0, 16, 0 },
	L30 = { -22, 0, 16, 0 },
	L31 = { 12, 0, 11, 0 },
	L32 = { 12, 0, 18, 0 },
	L33 = { 35, 0, -59, 0 },
	L34 = { 35, 0, 16, 0 },
	L35 = { -6, 0, 16, 0 },
	L36 = { 0, 0, -9.7, 0 },
	L37 = { 33.5, 0, -21, 0 },
	-- ขั้น 5: อาณาจักรชาไทย (แถวหลังสุด อาคารเดินเข้าได้)
	L38 = { -41.5, 0, 50, 0 },
	L39 = { -26.5, 0, 46, 0 },
	L40 = { -12.5, 0, 48, 0 },
	L41 = { 13, 0, 52, 0 },
	L42 = { 26.5, 0, 48, 0 },
	L43 = { 42, 0, 44, 0 },
	L44 = { 0, 0, 40, 0 },
	L45 = { 0, 0, 54, 0 },
}

---------------------------------------------------------------------------
-- โมเดลแต่ละชิ้น
---------------------------------------------------------------------------
local Build = {}

-- ขั้น 1 ---------------------------------------------------------------

Build.L02 = function(b) -- โต๊ะพับ + ผ้าคลุมหน้าร้าน
	b:Legs(5.4, 2.1, 2.75, 0.18, CF(), PAL.steel)
	b:Box(V3(5.4, 0.12, 0.12), CF(0, 0.8, 1.05), PAL.steel, M.Metal)
	b:Box(V3(6, 0.2, 2.6), CF(0, 2.8, 0), PAL.white)
	b:Box(V3(6.1, 0.1, 2.7), CF(0, 2.95, 0), PAL.cream, M.Fabric)
	local skirt = b:Box(V3(6.1, 1.5, 0.08), CF(0, 2.2, -1.36), PAL.tea, M.Fabric)
	b:Text(skirt, FACE.Front, "ชาไทย ชาเย็น", { color = PAL.white })
	for _, x in { -3.05, 3.05 } do
		b:Box(V3(0.08, 1.5, 2.7), CF(x, 2.2, 0), PAL.tea, M.Fabric)
	end
	b:Box(V3(6.12, 0.18, 0.1), CF(0, 1.45, -1.37), PAL.white, M.Fabric)
	-- เก้าอี้พลาสติกคนขาย
	b:Box(V3(1.3, 0.2, 1.3), CF(0.8, 1.4, 2.5), PAL.red)
	b:Legs(1.0, 1.0, 1.3, 0.2, CF(0.8, 0, 2.5), PAL.red)
end

Build.L03 = function(b) -- กระติกน้ำแข็งบนเก้าอี้
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
	-- น้ำแข็งบนฝา
	b:Box(V3(0.4, 0.4, 0.4), CF(0.4, 4.2, 0.3) * ANG(0, rad(20), 0), PAL.glass, M.Glass, { t = 0.35 })
end

Build.L04 = function(b) -- หม้อต้มชาบนเตาแก๊ส
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
		b:Ball(d, CF(0.15 * i - 0.2, 3.9 + i * 0.6, 0.1 * i), PAL.white, nil, { t = 0.6, solid = false })
	end
	-- ถังแก๊ส
	b:Cyl(1.8, 1.1, CF(1.9, 0.9, 0.4), PAL.red)
	b:Ball(1.1, CF(1.9, 1.8, 0.4), PAL.red)
	b:Cyl(0.3, 0.35, CF(1.9, 2.4, 0.4), PAL.steel, M.Metal)
	b:Rod(V3(1.9, 2.4, 0.4), V3(0.9, 1.75, 0), 0.1, PAL.black)
end

Build.L05 = function(b) -- ถุงกรองชา (ถุงผ้าชักชา) บนขาตั้ง
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
end

Build.L06 = function(b) -- แก้วพลาสติก (วางบนโต๊ะ)
	b:Box(V3(2.6, 0.08, 1.0), CF(0, 0.04, -0.45), PAL.steel, M.Metal)
	for i, x in { -0.9, -0.3, 0.3, 0.9 } do
		b:TeaCup(CF(x, 0.08, -0.45), 1, if i == 3 then rgb(120, 180, 90) else nil)
	end
	for _, x in { -0.6, 0, 0.6 } do
		b:Cyl(1.4, 0.5, CF(x, 0.7, 0.55), PAL.white, M.Glass, { t = 0.45 })
		b:Cyl(0.06, 0.56, CF(x, 1.4, 0.55), PAL.white, M.Glass, { t = 0.3 })
	end
end

Build.L07 = function(b) -- ร่มกันแดด 8 แฉก
	b:Cyl(0.4, 1.4, CF(0, 0.2, 0), PAL.steelDark, M.Concrete)
	b:Cyl(8.4, 0.25, CF(0, 4.2, 0), PAL.white, M.Metal)
	for k = 0, 7 do
		local color = if k % 2 == 0 then PAL.tea else PAL.white
		b:Wedge(V3(4.15, 1.6, 5), CF(0, 7, 0) * ANG(0, rad(45 * k), 0) * CF(0, 0.8, -2.5), color, M.Fabric, { solid = false })
		-- ชายร่ม
		b:Box(V3(4.1, 0.35, 0.06), CF(0, 7, 0) * ANG(0, rad(45 * k), 0) * CF(0, -0.15, -4.98), color, M.Fabric, { solid = false })
	end
	b:Ball(0.45, CF(0, 8.75, 0), PAL.tea)
end

Build.L08 = function(b) -- ป้ายร้านแบบกระดานพับ
	local front = CF(0, 1.6, -0.42) * ANG(rad(15), 0, 0)
	local back = CF(0, 1.6, 0.42) * ANG(rad(-15), 0, 0)
	b:Box(V3(2.6, 3.4, 0.12), front, PAL.woodDark, M.Wood)
	b:Box(V3(2.6, 3.4, 0.12), back, PAL.woodDark, M.Wood)
	local board = b:Box(V3(2.2, 3.0, 0.05), front * CF(0, 0, -0.08), rgb(40, 50, 45), nil, { solid = false })
	b:Text(board, FACE.Front, "ชาไทย\nแก้วละ 25.-\nหวาน มัน\nชื่นใจ", { color = PAL.cream, font = Enum.Font.GothamBold })
	local board2 = b:Box(V3(2.2, 3.0, 0.05), back * CF(0, 0, 0.08), rgb(40, 50, 45), nil, { solid = false })
	b:Text(board2, FACE.Back, "ชาเขียว\nชามะนาว\nโกโก้", { color = PAL.cream, font = Enum.Font.GothamBold })
	b:Box(V3(2.7, 0.2, 0.3), CF(0, 3.2, 0), PAL.woodDark, M.Wood)
end

Build.L09 = function(b) -- เครื่องซีลแก้ว (วางบนโต๊ะ)
	b:Box(V3(1.2, 0.2, 1.3), CF(0, 0.1, 0), PAL.white)
	b:Box(V3(1.2, 1.8, 0.45), CF(0, 1.1, 0.42), PAL.white)
	b:Box(V3(1.2, 0.5, 1.2), CF(0, 2.05, 0), PAL.white)
	b:Cyl(0.7, 0.55, CF(0, 0.55, -0.1), PAL.steelDark, M.Metal)
	b:TeaCup(CF(0, 0.2, -0.1), 0.9)
	b:HCyl(1.3, 0.45, CF(0, 2.55, 0.25), rgb(215, 230, 240))
	b:Box(V3(0.5, 0.22, 0.04), CF(0, 2.05, -0.62), rgb(255, 60, 60), M.Neon)
	b:Rod(V3(0.66, 2.0, 0.1), V3(0.66, 2.5, -0.9), 0.1, PAL.black)
	b:Ball(0.25, CF(0.66, 2.5, -0.9), PAL.red)
end

Build.L10 = function(b) -- ตู้เย็นเล็กฝากระจก
	local body = PAL.red
	for _, x in { -1.2, 1.2 } do
		b:Box(V3(0.2, 5.4, 2.4), CF(x, 2.7, 0), body)
	end
	b:Box(V3(2.6, 5.4, 0.2), CF(0, 2.7, 1.1), body)
	b:Box(V3(2.6, 0.9, 2.4), CF(0, 4.95, 0), body)
	b:Box(V3(2.6, 0.6, 2.4), CF(0, 0.3, 0), body)
	b:Box(V3(2.2, 3.9, 0.05), CF(0, 2.55, 0.98), PAL.white)
	local logo = b:Box(V3(2.4, 0.6, 0.06), CF(0, 5.0, -1.22), PAL.white, M.Neon, { solid = false })
	b:Text(logo, FACE.Front, "ชาไทยเย็น", { color = PAL.red })
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
end

-- ขั้น 2 ---------------------------------------------------------------

Build.L11 = function(b) -- เคาน์เตอร์ไม้
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
	b:Text(logo, FACE.Front, "ชาไทย", { color = PAL.cream })
end

Build.L12 = function(b) -- เครื่องชงชาไฟฟ้า (บนเคาน์เตอร์)
	b:Box(V3(1.6, 0.3, 1.6), CF(0, 0.15, 0.3), PAL.steelDark, M.Metal)
	b:Cyl(2.2, 1.5, CF(0, 1.4, 0.3), PAL.steel, M.Metal)
	b:Ellipsoid(V3(1.5, 0.7, 1.5), CF(0, 2.5, 0.3), PAL.steel, M.Metal)
	b:Ball(0.3, CF(0, 2.9, 0.3), PAL.black)
	b:Box(V3(0.3, 0.3, 0.5), CF(0, 0.7, -0.6), PAL.black)
	b:Box(V3(0.12, 1.4, 0.05), CF(0.45, 1.5, -0.47), PAL.tea, M.Glass, { t = 0.2 })
	b:Ball(0.16, CF(-0.45, 2.0, -0.45), rgb(255, 60, 60), M.Neon)
	b:TeaCup(CF(0, 0.3, -0.75), 0.8)
	-- กาต้มน้ำร้อน
	b:Box(V3(1, 1.6, 1), CF(1.35, 0.8, 0.3), PAL.white)
	b:Box(V3(0.5, 0.25, 0.04), CF(1.35, 1.2, -0.21), rgb(80, 170, 255), M.Neon)
end

Build.L13 = function(b) -- ตู้ท็อปปิ้ง (บนเคาน์เตอร์)
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
	b:Text(strip, FACE.Front, "ท็อปปิ้ง", { color = PAL.white })
end

Build.L14 = function(b) -- หม้อไข่มุก
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
		b:Ball(d, CF(0.3 - 0.1 * i, 3.9 + i * 0.6, 0.1), PAL.white, nil, { t = 0.65, solid = false })
	end
	local sack = b:Box(V3(1.1, 1.3, 0.9), CF(2.1, 0.65, 0.2), PAL.cream, M.Fabric)
	b:Text(sack, FACE.Front, "ไข่มุก", { color = PAL.teaDark })
end

Build.L15 = function(b) -- เก้าอี้บาร์ 4 ตัว
	for _, x in { -6, -2, 2, 6 } do
		b:Cyl(0.15, 1.4, CF(x, 0.08, 0), PAL.steelDark, M.Metal)
		b:Cyl(2.4, 0.25, CF(x, 1.3, 0), PAL.steel, M.Metal)
		b:Cyl(0.08, 1.1, CF(x, 1.0, 0), PAL.steel, M.Metal)
		b:Cyl(0.12, 1.65, CF(x, 2.45, 0), PAL.black)
		b:Cyl(0.35, 1.6, CF(x, 2.65, 0), PAL.tea)
	end
end

Build.L16 = function(b) -- โต๊ะกลมหน้าร้าน + เก้าอี้ 4 ตัว
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
end

Build.L17 = function(b) -- ไฟประดับ (เสา 4 ต้น + สายไฟหย่อน)
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
end

Build.L18 = function(b) -- เครื่องคิดเงิน + ป้ายสแกนจ่าย (บนเคาน์เตอร์)
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
	b:Text(qr, FACE.Front, "สแกนจ่าย", { color = rgb(20, 60, 140), region = { 0, 0, 1, 0.25 } })
	b:Box(V3(0.55, 0.55, 0.02), CF(-1.2, 0.5, -0.26) * ANG(rad(10), 0, 0), PAL.black, nil, { solid = false })
	b:Box(V3(0.8, 0.1, 0.3), CF(-1.2, 0.05, -0.1), PAL.black)
end

Build.L19 = function(b) -- พนักงานชงชา ท่าชักชา (ยืนบนแท่นไม้ให้พ้นเคาน์เตอร์)
	b:Box(V3(3, 0.6, 2.2), CF(0, 0.3, 0), PAL.woodDark, M.WoodPlanks)
	local hands = b:Person(CF(0, 0.6, 0), {
		apron = PAL.tea, cap = PAL.tea, shirt = PAL.white,
		right = { 150, 20 }, left = { 60, 30 },
	})
	b:Cyl(0.6, 0.5, CF(hands.right) * CF(0, -0.1, 0), PAL.steel, M.Metal)
	b:TeaCup(CF(hands.left) * CF(0, -0.2, 0), 1.2)
	b:Rod(hands.right - V3(0, 0.4, 0), hands.left + V3(0, 0.9, 0), 0.14, PAL.tea, M.Glass, { t = 0.15 })
end

-- ขั้น 3 ---------------------------------------------------------------

Build.L20 = function(b) -- เครื่องทำน้ำแข็ง
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
	-- ถาดน้ำแข็ง
	b:Box(V3(1.8, 0.4, 1.2), CF(1.1, 5.2, -0.3), PAL.white, M.Glass, { t = 0.5 })
	local rand = seeded(20)
	for _ = 1, 5 do
		b:Box(V3(0.35, 0.35, 0.35), CF(0.5 + rand() * 1.2, 5.5, -0.7 + rand() * 0.8) * ANG(0, rand() * 3, 0), PAL.glass, M.Glass, { t = 0.3 })
	end
end

Build.L21 = function(b) -- เมนูบอร์ดไฟ
	for _, x in { -3.6, 3.6 } do
		b:Box(V3(0.4, 8, 0.4), CF(x, 4, 0), PAL.woodDark, M.Wood)
	end
	b:Box(V3(8, 5, 0.4), CF(0, 5.2, 0), PAL.woodDark, M.Wood)
	local board = b:Box(V3(7.4, 4.4, 0.1), CF(0, 5.2, -0.22), rgb(30, 35, 32), nil, { solid = false })
	b:Text(board, FACE.Front,
		"ชาไทย ............ 35\nชาเขียว .......... 40\nชามะนาว ........ 30\nโกโก้ ............. 40\nกาแฟโบราณ ..... 35",
		{ color = PAL.cream, glow = true, font = Enum.Font.GothamBold })
	local header = b:Box(V3(8.2, 0.9, 0.5), CF(0, 8.1, 0), PAL.tea)
	b:Text(header, FACE.Front, "เมนูแนะนำ", { color = PAL.white })
	local strip = b:Box(V3(7, 0.12, 0.3), CF(0, 7.6, -0.4), PAL.warm, M.Neon, { solid = false })
	b:Light(strip, PAL.warm, 8, 0.7)
end

Build.L22 = function(b) -- สถานีปั่น
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
end

Build.L23 = function(b) -- ตู้เค้ก
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
end

Build.L24 = function(b) -- มุมถ่ายรูปผนังดอกไม้
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
	b:Text(sign, FACE.Front, "ชาไทยฟินเวอร์ ♥", { color = rgb(255, 120, 170), glow = true })
	b:Box(V3(4, 0.35, 1.4), CF(0, 1.5, 1.4), PAL.woodLight, M.Wood)
	b:Box(V3(4, 1.2, 0.2), CF(0, 2.3, 2.05), PAL.woodLight, M.Wood)
	b:Legs(3.5, 1.1, 1.35, 0.2, CF(0, 0, 1.4), PAL.woodDark)
	b:Plant(CF(-3.5, 0, 0.8), 2.2)
	b:Plant(CF(3.5, 0, 0.8), 2.2)
	b:Box(V3(8, 0.06, 4), CF(0, 0.03, 0.8), PAL.pink, M.Fabric, { solid = false })
	-- ไฟวงแหวนถ่ายรูป
	b:Cyl(4, 0.15, CF(2.2, 2, -2.6), PAL.black)
	local ring = b:HCyl(0.15, 1.4, CF(2.2, 4.4, -2.6) * ANG(0, rad(90), 0), PAL.white, M.Neon, { solid = false })
	b:Light(ring, PAL.white, 8, 0.6)
end

Build.L25 = function(b) -- แอร์ตั้งพื้น + คอมเพรสเซอร์
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
end

Build.L26 = function(b) -- ชั้นวางใบชา
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
	b:Text(sign, FACE.Front, "ใบชาคัดพิเศษ", { color = PAL.cream })
end

Build.L27 = function(b) -- บาร์ชงโชว์ + โคมไฟห้อย + เคาน์เตอร์หลัง
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
	-- เคาน์เตอร์หลัง
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
	-- โครงโคมไฟ
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
end

Build.L28 = function(b) -- ผนังอิฐ + ป้ายไฟนีออนรูปแก้ว
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
	b:Text(left, FACE.Front, "ชาไทย", { color = rgb(255, 170, 90), glow = true })
	local right = b:Box(V3(5, 2.2, 0.05), CF(5.2, 5, -0.53), PAL.white, nil, { t = 1, solid = false })
	b:Text(right, FACE.Front, "THAI TEA", { color = rgb(120, 240, 170), glow = true })
	local glow = b:Box(V3(0.1, 0.1, 0.1), CF(0, 5, -1.5), neon, nil, { t = 1, solid = false })
	b:Light(glow, neon, 14, 1.2)
end

-- ขั้น 4 ---------------------------------------------------------------

Build.L29 = function(b) -- ครัวกลาง (เดินเข้าได้: เตา หม้อต้มชา เครื่องดูดควัน โต๊ะเตรียม พ่อครัว)
	local W, D, H = 20, 16, 9
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
	-- ภายนอก
	local band = b:Box(V3(W + 0.4, 0.9, D + 0.4), CF(0, H + 1.05, 0), PAL.tea)
	b:Text(band, FACE.Front, "ครัวกลาง  CENTRAL KITCHEN", { color = PAL.white, region = { 0.15, 0.05, 0.7, 0.9 } })
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
		b:Ball(d, CF(6 + i * 0.2, H + 4.6 + i * 0.9, 4), PAL.white, nil, { t = 0.6, solid = false })
	end
	b:Box(V3(3, 1.4, 2), CF(-6, H + 2.2, -3.5), PAL.steel, M.Metal)

	-- ไลน์เตาหลังห้อง
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
		b:Ball(1, CF(x + 0.2, 6.1, 6.1), PAL.white, nil, { t = 0.6, solid = false })
	end
	b:Box(V3(12, 3.5, 0.1), CF(-2, 5, 7.35), PAL.white, M.Marble, { solid = false })
	b:Box(V3(13, 1.2, 3), CF(-2, 7.8, 6.0), PAL.steel, M.Metal)
	b:Box(V3(2.4, 0.8, 2), CF(-2, 8.6, 6.3), PAL.steel, M.Metal)
	b:Box(V3(11, 0.1, 0.4), CF(-2, 7.15, 4.7), PAL.warm, M.Neon, { solid = false })
	b:Box(V3(4, 0.05, 1.6), CF(-2, 0.23, 3.9), PAL.black, nil, { solid = false })

	-- อ่างล้าง
	b:Box(V3(4, 3, 2.4), CF(6.5, 1.7, 6.2), PAL.steel, M.Metal)
	b:Box(V3(3, 0.1, 1.6), CF(6.5, 3.22, 6.1), PAL.steelDark, M.Metal, { solid = false })
	b:Cyl(1, 0.2, CF(6.5, 3.7, 7.0), PAL.steel, M.Metal)
	b:Tube(V3(6.5, 4.2, 7.0), V3(6.5, 4.2, 6.3), 0.15, PAL.steel, M.Metal)
	for i = 0, 3 do
		b:Box(V3(0.1, 0.9, 0.9), CF(5.1 + i * 0.25, 3.7, 5.6), PAL.white, nil, { solid = false })
	end

	-- ชั้นวางวัตถุดิบ (ผนังซ้าย)
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

	-- โต๊ะเตรียม 2 ตัว
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

	-- พ่อครัว 2 คน
	local chef1 = b:Person(CF(-4, 0.2, 3.3) * ANG(0, rad(180), 0), { shirt = PAL.white, apron = PAL.white, chefHat = true, right = { 75, 10 }, left = { 40, 0 } })
	b:Rod(chef1.right, V3(-3.8, 5.2, 6.1), 0.12, PAL.woodDark, M.Wood)
	b:Person(CF(4, 0.2, 0.8), { shirt = PAL.white, apron = PAL.tea, chefHat = true, right = { 60, 25 }, left = { 60, 25 } })

	-- ไฟเพดาน
	for i, z in { -4, 0.5, 4.5 } do
		local strip = b:Box(V3(8, 0.15, 0.7), CF(0, H - 0.1, z), PAL.white, M.Neon, { solid = false })
		if i == 2 then
			b:Light(strip, PAL.white, 18, 0.8)
		end
	end
end

Build.L30 = function(b) -- รถส่งของ (หัวรถหันหน้าออกลาน)
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
		b:Text(panel, face, "ชาไทย DELIVERY", { color = PAL.tea })
	end
	b:Box(V3(0.06, 4.2, 0.06), CF(0, 4.0, 5.32), PAL.steelDark, nil, { solid = false })
	b:Box(V3(4.8, 0.4, 0.3), CF(0, 1.5, 5.4), PAL.black)
	for _, x in { -2, 2 } do
		b:Box(V3(0.5, 0.4, 0.1), CF(x, 2.0, 5.32), PAL.red, M.Neon, { solid = false })
	end
end

Build.L31 = function(b) -- สายพานแก้ว
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
	for i = 0, 8 do
		local x = -6 + i * 1.5
		b:Cyl(0.9, 0.45, CF(x, 3.45, 0), PAL.tea)
		b:Ellipsoid(V3(0.47, 0.25, 0.47), CF(x, 3.95, 0), PAL.white, M.Glass, { t = 0.3 })
	end
	b:Box(V3(1.2, 1.2, 1.2), CF(7.4, 2.0, 1.5), PAL.steelDark, M.Metal)
	for _, z in { -1.1, 1.1 } do
		b:Box(V3(0.2, 2, 0.2), CF(-3, 3.9, z), PAL.steelDark, M.Metal, { solid = false })
	end
	b:Box(V3(0.4, 0.3, 2.4), CF(-3, 4.95, 0), PAL.steelDark, M.Metal)
	b:Box(V3(0.3, 0.1, 1.6), CF(-3, 4.75, 0), rgb(90, 230, 120), M.Neon, { solid = false })
end

Build.L32 = function(b) -- เครื่องชงอัตโนมัติ
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
end

Build.L33 = function(b) -- จุดรับออร์เดอร์ออนไลน์ + มอเตอร์ไซค์ไรเดอร์
	b:Box(V3(2.4, 6, 1.4), CF(0, 3, 0), PAL.white)
	local head = b:Box(V3(2.6, 0.8, 1.6), CF(0, 6.3, 0), PAL.green)
	b:Text(head, FACE.Front, "สั่งออนไลน์", { color = PAL.white })
	local screen = b:Box(V3(1.8, 2.8, 0.08), CF(0, 3.9, -0.72), rgb(40, 110, 220), M.Neon, { solid = false })
	b:Text(screen, FACE.Front, "สแกน\nสั่งเลย", { color = PAL.white, region = { 0, 0, 1, 0.45 } })
	b:Box(V3(1.0, 1.0, 0.02), CF(0, 3.3, -0.77), PAL.white, nil, { solid = false })
	b:Box(V3(0.7, 0.7, 0.02), CF(0, 3.3, -0.79), PAL.black, nil, { solid = false })
	b:Box(V3(1.2, 0.15, 0.3), CF(0, 1.8, -0.8), PAL.black)
	-- ชั้นวางถุงส่งของ
	for _, x in { -3.4, -1.6 } do
		b:Box(V3(0.15, 3.4, 0.15), CF(x, 1.7, 0), PAL.steelDark, M.Metal, { solid = false })
	end
	for i, y in { 1.2, 2.8 } do
		b:Box(V3(2, 0.12, 1.2), CF(-2.5, y, 0), PAL.steel, M.Metal)
		b:Box(V3(0.7, 0.8, 0.5), CF(-3.0, y + 0.46, 0), if i == 1 then PAL.green else PAL.tea, M.Fabric, { solid = false })
		b:Box(V3(0.7, 0.8, 0.5), CF(-2.1, y + 0.46, 0.1), if i == 1 then PAL.tea else PAL.green, M.Fabric, { solid = false })
	end
	-- มอเตอร์ไซค์ (หันหน้าออกลาน)
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
	b:Text(delivery, FACE.Back, "ชาไทย", { color = PAL.white })
end

Build.L34 = function(b) -- ห้องเย็น (เดินเข้าได้: ม่านพลาสติก ชั้นวางลังนม น้ำแข็ง พัดลมคอยล์เย็น)
	local W, D, H = 14, 14, 9
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
		b:Box(V3(0.08, 8.4, 0.06), CF(x, 4.2, -D / 2 - 0.03), rgb(200, 208, 216), nil, { solid = false })
	end
	local temp = b:Box(V3(1.8, 0.8, 0.1), CF(3.6, 5.4, -D / 2 - 0.05), PAL.black)
	b:Text(temp, FACE.Front, "-18°C", { color = rgb(255, 70, 70), glow = true })
	local sign = b:Box(V3(4.5, 0.9, 0.15), CF(3.6, 6.8, -D / 2 - 0.08), PAL.blue)
	b:Text(sign, FACE.Front, "ห้องเย็น", { color = PAL.white })
	b:Box(V3(4, 1.5, 3), CF(0, H + 2.15, 2), PAL.steel, M.Metal)
	b:Cyl(0.2, 2.2, CF(0, H + 3, 2), PAL.black)
	b:Box(V3(2.6, 0.4, 2.6), CF(4.3, 0.2, -D / 2 - 2), PAL.wood, M.WoodPlanks)
	for _, p in { V3(3.7, 0.95, -9.6), V3(4.9, 0.95, -9.6), V3(3.7, 0.95, -8.4), V3(4.9, 0.95, -8.4), V3(4.3, 2.05, -9.0) } do
		b:Box(V3(1.1, 1.1, 1.1), CF(p), rgb(200, 160, 110))
	end

	-- ชั้นวางผนังหลัง: ลังนม + กล่อง
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
	-- ชั้นวางผนังซ้าย: ของแช่แข็ง
	local left = CF(-5.4, 0.2, -0.5) * ANG(0, rad(90), 0)
	b:Shelf(left, 8, 1.6, { 1.2, 3.2, 5.2 }, PAL.blue, function(level, y)
		for k = 1, 3 do
			local at = left * CF(-2.6 + (k - 1) * 2.6, y, 0)
			b:Box(V3(1.6, 1.1, 1.4), at * CF(0, 0.55, 0), if (k + level) % 2 == 0 then PAL.white else rgb(150, 200, 240), nil, { solid = false })
		end
	end)
	-- ก้อนน้ำแข็ง + พาเลทนม
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
			b:Text(carton, FACE.Front, "นม", { color = PAL.blue })
		end
	end
	-- พัดลมคอยล์เย็น + น้ำแข็งย้อย
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
	-- พนักงานใส่เสื้อกันหนาวยกลัง
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

Build.L35 = function(b) -- โรงคั่วชา (ถังคั่วใต้เพิงหลังคาจั่ว + กระสอบ + คนงานกวาดใบชา)
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
		b:Ball(d, CF(2 + i * 0.2, 9.9 + i * 0.8, 1), PAL.white, nil, { t = 0.65, solid = false })
	end
	b:Cyl(0.5, 3.4, CF(0, 1, -3.4), PAL.steel, M.Metal)
	b:Cyl(0.08, 3.1, CF(0, 1.27, -3.4), rgb(110, 60, 30), nil, { solid = false })
	b:Box(V3(3, 0.1, 0.2), CF(0, 1.4, -3.4) * ANG(0, rad(30), 0), PAL.steelDark, M.Metal, { solid = false })
	b:Legs(2.4, 2.4, 0.75, 0.2, CF(0, 0, -3.4), PAL.black)
	for _, p in { V3(3.6, 0.8, -1.5), V3(3.6, 0.8, -0.4), V3(3.6, 2.4, -0.95), V3(4.8, 0.8, 1.2) } do
		local sack = b:Box(V3(1.2, 1.6, 1.0), CF(p), rgb(200, 175, 130), M.Fabric)
		b:Text(sack, FACE.Front, "TEA", { color = PAL.teaDark, region = { 0.1, 0.3, 0.8, 0.4 } })
	end
	-- เพิงหลังคาจั่ว
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

Build.L36 = function(b) -- ทีมบาริสต้า 3 คน (หลังบาร์)
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
end

Build.L37 = function(b) -- ป้ายบิลบอร์ด
	b:Cyl(13, 1, CF(0, 6.5, 0.4), PAL.steelDark, M.Metal)
	b:Box(V3(2, 0.6, 2), CF(0, 0.3, 0.4), PAL.concrete, M.Concrete)
	b:Box(V3(12, 0.2, 1.4), CF(0, 12.6, -0.8), PAL.steelDark, M.DiamondPlate)
	b:Box(V3(12, 0.1, 0.1), CF(0, 13.4, -1.45), PAL.steelDark, M.Metal, { solid = false })
	b:Box(V3(12.4, 6.4, 0.6), CF(0, 16, 0), PAL.black, M.Metal)
	local face = b:Box(V3(12, 6, 0.1), CF(0, 16, -0.35), PAL.cream)
	b:Text(face, FACE.Front, "ชาไทยเย็น\nหอม หวาน มัน\nแก้วละ 35.-", { color = PAL.teaDark, region = { 0.03, 0.1, 0.6, 0.8 } })
	-- รูปแก้วบนป้าย
	b:Box(V3(2, 2.8, 0.1), CF(-3.6, 15.2, -0.45), PAL.tea, nil, { solid = false })
	b:Box(V3(2.1, 0.6, 0.1), CF(-3.6, 16.8, -0.45), PAL.milk, nil, { solid = false })
	b:Ellipsoid(V3(2.3, 1.1, 0.1), CF(-3.6, 17.1, -0.44), PAL.white)
	b:Box(V3(0.25, 2.4, 0.1), CF(-3.2, 18.0, -0.46) * ANG(0, 0, rad(-20)), PAL.green, nil, { solid = false })
	for _, x in { -4, 0, 4 } do
		b:Rod(V3(x, 12.8, -1.3), V3(x, 13.6, -1.9), 0.3, PAL.black, M.Metal)
		b:Ball(0.35, CF(x, 13.7, -1.95), PAL.warm, M.Neon, { solid = false })
	end
end

-- ขั้น 5 ---------------------------------------------------------------

Build.L38 = function(b) -- ไร่ชาขั้นบันได 5 ชั้น (แถวต้นชา บันได คนเก็บชาใส่งอบ กระท่อม ราวตากใบชา)
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
	-- คนเก็บชา
	for i, spot in { { 3.2, 1 }, { -2.6, 2 } } do
		local z = fronts[spot[2]] + 2.25
		local y = spot[2] * STEP
		local picker = b:Person(CF(spot[1], y, z), { shirt = if i == 1 then PAL.blue else PAL.red, apron = rgb(60, 50, 40), ngob = true, right = { 50, 10 }, left = { 50, 10 } })
		b:Cyl(1.2, 1.3, CF(spot[1], y + 3, z + 0.9), PAL.woodLight, M.Wood, { solid = false })
		b:Ball(0.3, CF(picker.right), PAL.leaf, nil, { solid = false })
	end
	-- กระท่อม + ราวตากใบชา บนชั้นบนสุด
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
	b:Text(sign, FACE.Front, "ไร่ชา", { color = PAL.cream })
	b:Box(V3(0.25, 1.3, 0.25), CF(5, 0.65, -DEPTH / 2 - 0.8), PAL.woodDark, M.Wood, { solid = false })
end

Build.L39 = function(b) -- โรงงานบรรจุขวด (เดินเข้าได้: สายพาน เครื่องเติม เครื่องปิดฝา ถังผสม นั่งร้าน)
	local W, D, H = 14, 18, 10
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
	-- หลังคาฟันเลื่อย
	for _, z in { -6.75, -2.25, 2.25, 6.75 } do
		b:Wedge(V3(W, 2.4, 4.5), CF(0, H + 1.2, z), PAL.steelDark, M.Metal)
		b:Box(V3(W, 2.2, 0.1), CF(0, H + 1.2, z + 2.3), PAL.glass, M.Glass, { t = 0.3, solid = false })
	end
	for _, z in { -D / 2 - 0.05, D / 2 + 0.05 } do
		b:Box(V3(W + 0.1, 0.5, 0.1), CF(0, H - 1.2, z), PAL.tea, nil, { solid = false })
	end
	-- ไซโล + ท่อ + ป้าย
	for _, x in { -5.3, 5.3 } do
		b:Cyl(9, 2.2, CF(x, 4.5, -D / 2 - 1.3), PAL.steel, M.Metal)
		b:Ellipsoid(V3(2.2, 1.2, 2.2), CF(x, 9, -D / 2 - 1.3), PAL.steel, M.Metal)
		b:Cyl(0.3, 2.3, CF(x, 2.5, -D / 2 - 1.3), PAL.tea)
		b:Cyl(0.3, 2.3, CF(x, 6.5, -D / 2 - 1.3), PAL.tea)
	end
	b:HCyl(10.6, 0.4, CF(0, 9.2, -D / 2 - 1.3), COPPER, M.Metal)
	local sign = b:Box(V3(5.5, 1, 0.2), CF(0, 8.6, -D / 2 - 0.15), PAL.tea)
	b:Text(sign, FACE.Front, "โรงงานบรรจุขวด", { color = PAL.white })
	-- ขวดยักษ์บนหลังคา
	b:Box(V3(3, 0.3, 3), CF(0, H + 2.55, 0), PAL.steelDark, M.Metal)
	b:Cyl(3, 1.8, CF(0, H + 4.2, 0), PAL.tea)
	b:Cyl(1, 1.85, CF(0, H + 4.3, 0), PAL.cream)
	b:Cyl(0.6, 1.2, CF(0, H + 6.0, 0), PAL.tea)
	b:Cyl(0.8, 0.6, CF(0, H + 6.7, 0), PAL.tea, M.Glass, { t = 0.2 })
	b:Cyl(0.3, 0.7, CF(0, H + 7.25, 0), PAL.red)

	-- สายพานบรรจุขวด (วิ่งตามแกน Z ชิดผนังขวา)
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
	-- เครื่องเติม
	for _, v in { -1.5, 1.5 } do
		b:Box(V3(0.4, 5.2, 0.4), line * CF(2, 2.6, v), PAL.steelDark, M.Metal)
	end
	b:Box(V3(2.6, 1.2, 3.6), line * CF(2, 5.8, 0), PAL.steel, M.Metal)
	for _, u in { 1.4, 2, 2.6 } do
		b:Cyl(0.7, 0.25, line * CF(u, 4.9, 0), PAL.black, nil, { solid = false })
	end
	b:Box(V3(2.4, 1.6, 0.1), line * CF(2, 4.2, -1.3), PAL.glass, M.Glass, { t = 0.6, solid = false })
	b:Ball(0.35, line * CF(2, 6.5, -1.8), rgb(90, 230, 120), M.Neon, { solid = false })
	-- เครื่องปิดฝา
	b:Box(V3(1.6, 3.2, 1.6), line * CF(-2.5, 1.8, 1.9), PAL.red)
	b:Box(V3(1.2, 0.9, 1.6), line * CF(-2.5, 3.9, 1.1), PAL.red)
	b:Cyl(1, 1.3, line * CF(-2.5, 4.9, 1.9), PAL.steel, M.Metal)
	for i = 0, 3 do
		b:Ball(0.3, line * CF(-2.9 + i * 0.3, 5.45, 1.9), PAL.red, nil, { solid = false })
	end
	-- ลังขวดที่เสร็จแล้ว
	for i = 0, 1 do
		local crate = CF(1.5, 0.2 + i * 1, -6.6)
		b:Box(V3(2, 0.9, 1.5), crate * CF(0, 0.45, 0), PAL.yellow)
		for k = 0, 5 do
			b:Cyl(0.35, 0.4, crate * CF(-0.6 + (k % 3) * 0.6, 1.05, -0.35 + math.floor(k / 3) * 0.7), PAL.tea, nil, { solid = false })
		end
	end

	-- ถังผสม 2 ใบ + นั่งร้าน + บันได
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
	-- แผงควบคุม
	b:Box(V3(2.2, 2.8, 0.9), CF(-5.2, 1.6, -7.2), PAL.steel, M.Metal)
	local screen = b:Box(V3(1.6, 0.9, 0.05), CF(-5.2, 2.3, -7.68), rgb(40, 110, 220), M.Neon, { solid = false })
	b:Text(screen, FACE.Front, "LINE 1 OK", { color = PAL.white })
	for i, c in { PAL.red, rgb(90, 220, 120), PAL.yellow } do
		b:Ball(0.25, CF(-5.9 + i * 0.35, 1.4, -7.66), c, M.Neon, { solid = false })
	end
	-- คนงาน + เส้นทางเดิน + ป้ายเตือน
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

-- รถยก (ใช้ในศูนย์กระจายสินค้า)
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

Build.L40 = function(b) -- ศูนย์กระจายสินค้า (เดินเข้าได้: ชั้นพาเลทสูง รถยก โต๊ะแพ็กของ)
	local W, D, H = 12, 20, 8
	local CARTON = rgb(200, 160, 110)
	b:Shell(CF(), {
		w = W, d = D, h = H, wall = rgb(125, 155, 185), wallMat = M.Metal,
		floor = rgb(165, 165, 160), floorMat = M.Concrete, roofColor = rgb(85, 100, 120),
		openings = {
			{ side = "Front", x = -2.8, y = 0, w = 4.4, h = 6.5 },
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
	-- ภายนอก: ประตูม้วน ป้าย กันชนท่าโหลด
	b:Box(V3(4.4, 6, 0.1), CF(2.8, 3, -D / 2 - 0.08), PAL.steelDark, M.Metal)
	for i = 1, 7 do
		b:Box(V3(4.4, 0.05, 0.05), CF(2.8, i * 0.8, -D / 2 - 0.15), PAL.steel, nil, { solid = false })
	end
	for _, x in { -5.2, -0.4, 0.4, 5.2 } do
		b:Box(V3(0.4, 0.8, 0.3), CF(x, 0.8, -D / 2 - 0.2), PAL.black, nil, { solid = false })
	end
	local sign = b:Box(V3(8, 1, 0.12), CF(0, 7.1, -D / 2 - 0.1), PAL.tea)
	b:Text(sign, FACE.Front, "ศูนย์กระจายสินค้า", { color = PAL.white })
	for _, x in { -2.8, 2.8 } do
		b:Ball(0.35, CF(x, 6.7, -D / 2 - 0.3), PAL.warm, M.Neon, { solid = false })
	end
	b:Box(V3(2.4, 0.4, 2.4), CF(3.2, 0.2, -D / 2 - 2), PAL.wood, M.WoodPlanks)
	b:Box(V3(2.2, 1.6, 2.2), CF(3.2, 1.2, -D / 2 - 2), PAL.white, nil, { t = 0.2 })

	-- ชั้นพาเลทสองข้าง
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
	-- รถยก + แฮนด์ลิฟต์ + พาเลท
	forklift(b, CF(0, 0.2, -1.5))
	b:Box(V3(2.4, 0.3, 2.4), CF(0, 0.35, 5), PAL.wood, M.WoodPlanks)
	for i = 0, 3 do
		b:Box(V3(1.1, 1.1, 1.1), CF(-0.6 + (i % 2) * 1.2, 1.05, 4.4 + math.floor(i / 2) * 1.2), CARTON, nil, { solid = false })
	end
	b:Rod(V3(0, 0.4, 6.3), V3(0, 2.4, 7.2), 0.15, PAL.red, M.Metal)
	b:Box(V3(0.8, 0.12, 0.12), CF(0, 2.4, 7.2), PAL.black, nil, { solid = false })
	-- โต๊ะแพ็กของ + พนักงานเสื้อกั๊กสะท้อนแสง
	b:Box(V3(3.5, 0.2, 1.6), CF(3.4, 3.0, -7.8), PAL.woodLight, M.Wood, { solid = true })
	b:Legs(3.1, 1.2, 2.8, 0.2, CF(3.4, 0.2, -7.8), PAL.steelDark)
	for i = 0, 3 do
		b:Box(V3(0.8, 0.6, 0.6), CF(2.2 + i * 0.8, 3.4, -7.9 + (i % 2) * 0.3), CARTON, nil, { solid = false })
	end
	b:HCyl(0.3, 0.6, CF(4.8, 3.4, -7.4) * ANG(0, rad(90), 0), PAL.tea, nil, { solid = false })
	b:Person(CF(3.4, 0.2, -6.6), { shirt = rgb(240, 120, 40), apron = PAL.yellow, right = { 60, 15 }, left = { 60, 15 } })
	-- ไฟห้อย + เส้นช่องทาง
	for i, z in { -5, 1, 7 } do
		b:Box(V3(0.06, 1.4, 0.06), CF(0, H - 0.7, z), PAL.black, nil, { solid = false })
		b:Cyl(0.5, 1.6, CF(0, H - 1.6, z), PAL.black, M.Metal, { solid = false })
		local bulb = b:Ball(0.5, CF(0, H - 1.95, z), PAL.warm, M.Neon, { solid = false })
		if i == 2 then
			b:Light(bulb, PAL.warm, 18, 0.9)
		end
	end
	for _, x in { -2.8, 2.8 } do
		b:Box(V3(0.2, 0.03, 14), CF(x, 0.215, 1.5), PAL.yellow, nil, { solid = false })
	end
end

Build.L41 = function(b) -- สำนักงานใหญ่ (ล็อบบี้เดินเข้าได้ + 7 ชั้นกระจกเห็นโต๊ะทำงาน + ลานเฮลิคอปเตอร์)
	local W, D, LOBBY, FLOORS, STOREY = 10, 10, 6, 7, 3
	local GLASS = rgb(90, 150, 200)
	b:Shell(CF(), {
		w = W, d = D, h = LOBBY, wall = GLASS, wallMat = M.Glass, wallT = 0.35,
		floor = PAL.white, floorMat = M.Marble, roof = false,
		openings = { { side = "Front", x = 0, y = 0, w = 3.2, h = 5 } },
	})
	for _, x in { -W / 2 + 0.1, W / 2 - 0.1 } do
		for _, z in { -D / 2 + 0.1, D / 2 - 0.1 } do
			b:Box(V3(0.6, LOBBY, 0.6), CF(x, LOBBY / 2, z), PAL.white, M.Concrete)
		end
	end
	b:Box(V3(4.4, 0.25, 2.2), CF(0, 5.4, -D / 2 - 1.1), PAL.white)
	b:Box(V3(3.4, 0.1, 0.1), CF(0, 5.25, -D / 2 - 2.1), PAL.tea, M.Neon, { solid = false })
	-- ชั้นบน
	for k = 1, FLOORS do
		local y0 = LOBBY + (k - 1) * STOREY
		b:Box(V3(W + 0.4, 0.4, D + 0.4), CF(0, y0 + 0.2, 0), PAL.white, M.Concrete)
		b:Box(V3(W - 0.2, STOREY - 0.4, D - 0.2), CF(0, y0 + 0.4 + (STOREY - 0.4) / 2, 0), GLASS, M.Glass, { t = 0.3 })
		for _, x in { -2.2, 2.2 } do
			b:Box(V3(2.4, 0.9, 1.2), CF(x, y0 + 0.85, -1), PAL.woodLight, nil, { solid = false })
			b:Box(V3(0.8, 0.6, 0.1), CF(x, y0 + 1.6, -0.6), PAL.black, nil, { solid = false })
		end
	end
	local top = LOBBY + FLOORS * STOREY
	b:Box(V3(W + 0.6, 1, D + 0.6), CF(0, top + 0.5, 0), PAL.tea)
	local pad = b:Cyl(0.3, 7, CF(0, top + 1.15, 0), PAL.steelDark, M.Concrete)
	b:Text(pad, FACE.Right, "H", { color = PAL.white })
	local sign = b:Box(V3(7, 1.5, 0.2), CF(0, top - 1.2, -D / 2 - 0.3), PAL.tea)
	b:Text(sign, FACE.Front, "ชาไทย HQ", { color = PAL.white })
	b:Cyl(4, 0.2, CF(3.5, top + 3, 3.5), PAL.steelDark, M.Metal)
	b:Ball(0.4, CF(3.5, top + 5.1, 3.5), PAL.red, M.Neon, { solid = false })

	-- ล็อบบี้
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

Build.L42 = function(b) -- สาขาในห้าง (ร้านชาจริง: เคาน์เตอร์ เมนูไฟ ตู้เย็น ที่นั่ง ลูกค้าต่อคิว)
	local W, D, H = 14, 16, 9
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
	-- ภายนอก
	local band = b:Box(V3(W + 0.4, 1.2, D + 0.4), CF(0, H + 1.2, 0), PAL.tea)
	b:Text(band, FACE.Front, "ชาไทย สาขาห้าง", { color = PAL.white, region = { 0.2, 0.05, 0.6, 0.9 } })
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

	-- เคาน์เตอร์ + อุปกรณ์หลังร้าน + เมนูไฟ
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
	-- เรียงจากซ้ายไปขวาเมื่อมองจากหน้าร้าน (+X อยู่ซ้ายมือคนดู)
	local menus = { "ชาไทย 45\nชาเขียว 50", "ชานมไข่มุก 55\nโกโก้ 50", "โปรวันนี้!\nแก้วที่ 2 ลด 50%" }
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

	-- ตู้เย็นเครื่องดื่ม (หันเข้าร้าน)
	b:Box(V3(1.4, 5, 2.4), CF(-5.7, 2.7, 2.2), rgb(40, 40, 45))
	local fridgeGlass = b:Box(V3(0.1, 4, 2.0), CF(-4.95, 2.7, 2.2), PAL.glass, M.Glass, { t = 0.55 })
	b:Light(fridgeGlass, PAL.white, 6, 0.5)
	for i = 0, 5 do
		b:Cyl(0.7, 0.35, CF(-5.3, 1.6 + math.floor(i / 3) * 1.6, 1.5 + (i % 3) * 0.7), if i % 2 == 0 then PAL.tea else PAL.leaf, M.Glass, { t = 0.1, solid = false })
	end
	-- โต๊ะลูกค้า
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
	-- ที่กั้นคิว + ลูกค้า
	for _, z in { -1, 1.5 } do
		b:Cyl(2.8, 0.2, CF(0.6, 1.6, z), PAL.gold, M.Metal)
		b:Cyl(0.15, 0.7, CF(0.6, 0.28, z), PAL.gold, M.Metal)
	end
	b:Rod(V3(0.6, 2.6, -1), V3(0.6, 2.6, 1.5), 0.12, PAL.red, M.Fabric)
	b:Person(CF(2.2, 0.2, 1.7) * ANG(0, rad(180), 0), { shirt = PAL.pink, apron = PAL.pink, pants = PAL.blue, left = { 10, 0 }, right = { 10, 0 } })
	b:Person(CF(2.2, 0.2, -0.6) * ANG(0, rad(170), 0), { shirt = PAL.blue, apron = PAL.blue, pants = PAL.black, left = { 40, 20 }, right = { 10, 0 } })
	-- โปสเตอร์ + ไฟห้อย
	local poster = b:Box(V3(0.1, 2.4, 3), CF(-W / 2 + 0.65, 5.2, -3.5), PAL.cream, nil, { solid = false })
	b:Text(poster, FACE.Right, "ชาไทยแท้\nชงสดทุกแก้ว", { color = PAL.teaDark })
	for i, x in { -3, 0.4, 3.8 } do
		b:Box(V3(0.06, 1.4, 0.06), CF(x, H - 0.7, 3.8), PAL.black, nil, { solid = false })
		b:Cyl(0.6, 1.1, CF(x, H - 1.6, 3.8), PAL.tea, M.Metal, { solid = false })
		local bulb = b:Ball(0.45, CF(x, H - 1.95, 3.8), PAL.warm, M.Neon, { solid = false })
		if i == 2 then
			b:Light(bulb, PAL.warm, 16, 0.9)
		end
	end
end

Build.L43 = function(b) -- สาขาสนามบิน (อาคารผู้โดยสารเดินเข้าได้ + หอบังคับการ + เครื่องบิน)
	local W, D, H = 13, 9, 7
	local T = CF(0, 0, -2)
	b:Shell(T, {
		w = W, d = D, h = H, wall = PAL.white, wallMat = M.SmoothPlastic,
		floor = rgb(220, 220, 225), floorMat = M.Marble, roofColor = rgb(210, 214, 220),
		openings = {
			{ side = "Front", x = -3.8, y = 0.5, w = 4.6, h = 5, glass = true },
			{ side = "Front", x = 1, y = 0, w = 3, h = 6.5 },
			{ side = "Front", x = 4.6, y = 0.5, w = 3.2, h = 5, glass = true },
			{ side = "Back", x = 0, y = 1, w = 9, h = 4.5, glass = true },
		},
	})
	b:Wedge(V3(W + 1, 0.8, 1.6), T * CF(0, H + 0.2, -D / 2 - 0.8), rgb(210, 214, 220), M.Metal)
	local fascia = b:Box(V3(W + 0.2, 0.9, 0.2), T * CF(0, H + 1.05, -D / 2 + 0.1), PAL.tea)
	b:Text(fascia, FACE.Front, "สาขาสนามบิน ✈", { color = PAL.white, region = { 0.2, 0, 0.6, 1 } })
	-- หอบังคับการ
	b:Box(V3(2, 0.4, 2), CF(-7.3, 0.2, -3), PAL.concrete, M.Concrete)
	b:Cyl(8, 1.4, CF(-7.3, 4.2, -3), PAL.white)
	b:Cyl(1.6, 2.6, CF(-7.3, 9, -3), rgb(80, 160, 200), M.Glass, { t = 0.2 })
	b:Cyl(0.3, 2.9, CF(-7.3, 9.95, -3), PAL.white)
	b:Cyl(1.5, 0.12, CF(-7.3, 10.8, -3), PAL.steelDark, M.Metal)
	b:Ball(0.3, CF(-7.3, 11.6, -3), PAL.red, M.Neon, { solid = false })

	-- ร้านชาในอาคาร
	b:Box(V3(4, 3.2, 1.6), T * CF(-3.6, 1.8, 0.4), PAL.tea)
	b:Box(V3(4.2, 0.2, 1.8), T * CF(-3.6, 3.5, 0.4), PAL.white, M.Marble)
	local kiosk = b:Box(V3(3, 0.8, 0.1), T * CF(-3.6, 5.8, 0.4), PAL.green)
	b:Text(kiosk, FACE.Front, "ชาไทย", { color = PAL.cream })
	b:Box(V3(0.06, 1.0, 0.06), T * CF(-3.6, 6.7, 0.4), PAL.black, nil, { solid = false })
	b:Person(T * CF(-3.6, 0.2, 1.65), { apron = PAL.tea, cap = PAL.tea, right = { 60, 20 }, left = { 60, 20 } })
	for i = 0, 2 do
		b:TeaCup(T * CF(-4.6 + i * 0.9, 3.6, 0), 0.9)
	end
	-- ป้ายเที่ยวบิน
	local board = b:Box(V3(5, 1.8, 0.3), T * CF(2.8, 5.2, 1.4), PAL.black)
	b:Text(board, FACE.Front, "เที่ยวบิน  ปลายทาง  เวลา\nTG101  เชียงใหม่  10:30\nFD202  ภูเก็ต  11:15", { color = PAL.yellow, glow = true, font = Enum.Font.Code })
	for _, x in { 1, 4.6 } do
		b:Box(V3(0.08, 0.9, 0.08), T * CF(x, 6.55, 1.4), PAL.black, nil, { solid = false })
	end
	-- เก้าอี้รอขึ้นเครื่อง 2 แถว
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
	-- กระเป๋าเดินทาง + ผู้โดยสาร
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

	-- เครื่องบิน (ลำตัวตามแกน X) จอดหลังอาคาร
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
	-- รถลากกระเป๋า
	b:Box(V3(1.4, 0.8, 1), plane * CF(-3, 0.6, -2.6), PAL.yellow)
	b:Box(V3(2, 0.2, 1.2), plane * CF(-0.9, 0.5, -2.6), PAL.steelDark, M.Metal)
	b:Box(V3(0.9, 0.8, 0.6), plane * CF(-0.9, 1.0, -2.6), PAL.red, nil, { solid = false })
end

Build.L44 = function(b) -- แฟรนไชส์ทั่วประเทศ (ลูกโลกบนแท่น)
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
	b:Text(plaque, FACE.Front, "แฟรนไชส์ทั่วประเทศ", { color = PAL.black })
end

Build.L45 = function(b) -- ตึกแลนด์มาร์กทรงแก้วชาไทยไข่มุก (ล็อบบี้เดินเข้าได้ + ร้านของที่ระลึก + ลิฟต์ชมวิว)
	local LW, LH = 12, 6
	b:Box(V3(14, 0.4, 14), CF(0, 0.2, 0), PAL.white, M.Marble)
	b:Box(V3(6, 0.2, 1), CF(0, 0.1, -7.4), PAL.white, M.Marble)
	local lobby = CF(0, 0.4, 0)
	b:Shell(lobby, {
		w = LW, d = LW, h = LH, wall = PAL.white, wallMat = M.Concrete,
		floor = rgb(235, 225, 210), floorMat = M.Marble, roofColor = PAL.white,
		openings = {
			{ side = "Front", x = 0, y = 0, w = 4, h = 5.2 },
			{ side = "Front", x = -4, y = 0.6, w = 3, h = 4.4, glass = true },
			{ side = "Front", x = 4, y = 0.6, w = 3, h = 4.4, glass = true },
			{ side = "Left", x = 0, y = 0.6, w = 8, h = 4.4, glass = true },
			{ side = "Right", x = 0, y = 0.6, w = 8, h = 4.4, glass = true },
		},
	})
	local sign = b:Box(V3(6, 1, 0.2), CF(0, LH + 0.1, -LW / 2 - 0.15), PAL.tea)
	b:Text(sign, FACE.Front, "THAI TEA TOWER", { color = PAL.white })
	for _, x in { -6.4, 6.4 } do
		b:Plant(CF(x, 0.4, -6.6), 2.4)
	end

	-- ตัวตึกทรงแก้ว
	local base = 0.4 + LH + 0.6
	b:Cyl(0.8, 8, CF(0, base + 0.4, 0), PAL.white, M.Concrete)
	local top = base + 0.8
	for i = 0, 7 do
		local d = 5 + i * 0.28
		local color = if i == 0 then PAL.pearl elseif i % 2 == 0 then PAL.tea else rgb(222, 108, 40)
		b:Cyl(3, d, CF(0, top + 1.5, 0), color, M.SmoothPlastic, { solid = true })
		b:Cyl(0.3, d + 0.12, CF(0, top + 3, 0), PAL.warm, M.Neon)
		top += 3
	end
	for k = 0, 11 do
		local a = rad(k * 30)
		b:Ball(1, CF(math.cos(a) * 2.55, base + 2 + (k % 2) * 0.9, math.sin(a) * 2.55), PAL.pearl, M.Glass)
	end
	b:Cyl(2, 7.3, CF(0, top + 1, 0), PAL.milk)
	b:Ellipsoid(V3(7.5, 4, 7.5), CF(0, top + 2, 0), PAL.white, M.Glass, { t = 0.35 })
	local strawTop = V3(2.4, top + 12, 1.4)
	b:Tube(V3(0.6, top + 2, 0.4), strawTop, 0.9, PAL.green, M.SmoothPlastic)
	local beacon = b:Ball(1, CF(strawTop), PAL.red, M.Neon, { solid = false })
	b:Light(beacon, PAL.red, 20, 1)

	-- ล็อบบี้: เคาน์เตอร์ข้อมูล ลิฟต์ทอง ร้านของที่ระลึก เก้าอี้ไข่มุก
	local f = 0.6
	b:Box(V3(3.4, 2.4, 1.2), CF(0, f + 1.2, 0.8), PAL.tea)
	b:Box(V3(3.6, 0.15, 1.4), CF(0, f + 2.45, 0.8), PAL.white, M.Marble)
	b:Person(CF(0, f, 2.2), { apron = PAL.tea, shirt = PAL.white, right = { 45, 15 }, left = { 30, 0 } })
	b:Box(V3(2.8, 4.4, 0.15), CF(0, f + 2.2, LW / 2 - 0.7), PAL.gold, M.Metal, { solid = false })
	b:Box(V3(0.06, 4.4, 0.16), CF(0, f + 2.2, LW / 2 - 0.71), PAL.woodDark, nil, { solid = false })
	local lift = b:Box(V3(3.2, 0.7, 0.1), CF(0, f + 4.9, LW / 2 - 0.75), PAL.black, nil, { solid = false })
	b:Text(lift, FACE.Front, "ขึ้นชมวิว ↑", { color = PAL.yellow, glow = true })
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
-- ของตกแต่งส่วนกลาง (ไม่ต้องซื้อ): ไฟทางเดิน ต้นไม้ ม้านั่ง ถังขยะ น้ำพุ
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
	-- แก้วชาไทยบนยอดน้ำพุ
	b:TeaCup(CF(0, 6.1, 0), 2.4)
	for k = 0, 7 do
		local a = rad(k * 45)
		b:Ball(0.5, CF(math.cos(a) * 5.4, 1.4, math.sin(a) * 5.4), PAL.white, nil, { t = 0.5, solid = false })
	end
end

---------------------------------------------------------------------------
-- API
---------------------------------------------------------------------------
function ItemModels.Has(key: string): boolean
	return Build[key] ~= nil
end

-- สร้างโมเดลตาม key วางที่ origin (CFrame โลก) คืน Model ที่ยังไม่ได้ใส่ Parent
function ItemModels.Build(key: string, origin: CFrame): Model?
	local build = Build[key]
	if not build then
		return nil
	end
	local model = Instance.new("Model")
	model.Name = key
	local b = newBuilder(model, origin)
	build(b)
	return model
end

-- สร้างของตกแต่ง (Lamp, Tree, Bench, Bin, Fountain) คืน Model ที่ยังไม่ได้ใส่ Parent
function ItemModels.BuildDecor(kind: string, origin: CFrame): Model?
	local build = Decor[kind]
	if not build then
		return nil
	end
	local model = Instance.new("Model")
	model.Name = kind
	build(newBuilder(model, origin))
	return model
end

-- CFrame ของ key ในฐาน เมื่อรู้ CFrame ผิวพื้นตรงกลางฐาน
function ItemModels.PlaceIn(key: string, plotFloor: CFrame): CFrame?
	local spot = ItemModels.Layout[key]
	if not spot then
		return nil
	end
	return plotFloor * CF(spot[1], spot[2], spot[3]) * ANG(0, rad(spot[4]), 0)
end

return ItemModels
