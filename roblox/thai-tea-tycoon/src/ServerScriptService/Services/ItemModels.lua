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
-- ฐานกว้าง 80 (x -40..40) ลึก 100 (z -50 หน้า .. 50 หลัง)
---------------------------------------------------------------------------
ItemModels.Layout = {
	-- ขั้น 1: รถเข็นชาไทย (หน้าซ้าย)
	L02 = { -20, 0, -26, 0 },
	L03 = { -25.4, 0, -26, 0 },
	L04 = { -14.2, 0, -25.5, 0 },
	L05 = { -13.8, 0, -20.5, 0 },
	L06 = { -18.4, 3, -26, 0 },
	L07 = { -20, 0, -23.4, 0 },
	L08 = { -27, 0, -31.5, 0 },
	L09 = { -21.6, 3, -26, 0 },
	L10 = { -31.5, 0, -22, 0 },
	-- ขั้น 2: ร้านเล็กริมทาง (หน้าขวา)
	L11 = { 20, 0, -22, 0 },
	L12 = { 24.8, 3.5, -21.6, 0 },
	L13 = { 19.5, 3.5, -22, 0 },
	L14 = { 23.5, 0, -17.2, 0 },
	L15 = { 20, 0, -26.8, 0 },
	L16 = { 32.5, 0, -30, 0 },
	L17 = { 22, 0, -24, 0 },
	L18 = { 14.2, 3.5, -22, 0 },
	L19 = { 17.5, 0, -18.6, 0 },
	-- ขั้น 3: คาเฟ่ (กลาง)
	L20 = { -31, 0, -4, 0 },
	L21 = { -19, 0, 9, 0 },
	L22 = { -23.5, 0, -4, 0 },
	L23 = { 16.5, 0, -1, 0 },
	L24 = { 31, 0, 6, 0 },
	L25 = { -37.2, 0, 7, 0 },
	L26 = { -29.5, 0, 10.5, 0 },
	L27 = { 0, 0, 2, 0 },
	L28 = { 0, 0, 11.5, 0 },
	-- ขั้น 4: ครัวกลาง (หลังกลาง)
	L29 = { -31, 0, 24, 0 },
	L30 = { -15, 0, 24, 0 },
	L31 = { 12, 0, 20, 0 },
	L32 = { 12, 0, 27, 0 },
	L33 = { 35, 0, -44, 0 },
	L34 = { 31, 0, 24, 0 },
	L35 = { -2.5, 0, 24, 0 },
	L36 = { 0, 0, 5.3, 0 },
	L37 = { 33.5, 0, -6, 0 },
	-- ขั้น 5: อาณาจักรชาไทย (แถวหลังสุด)
	L38 = { -33, 0, 43, 0 },
	L39 = { -19.5, 0, 43, 0 },
	L40 = { -8.5, 0, 43, 0 },
	L41 = { 8.5, 0, 44, 0 },
	L42 = { 20, 0, 43, 0 },
	L43 = { 32.5, 0, 43, 0 },
	L44 = { 0, 0, 34.5, 0 },
	L45 = { 0, 0, 44, 0 },
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

Build.L29 = function(b) -- อาคารครัวกลาง
	b:Box(V3(16.4, 0.6, 14.4), CF(0, 0.3, 0), PAL.steelDark, M.Concrete)
	b:Box(V3(16, 8, 14), CF(0, 4.6, 0), rgb(236, 232, 224), M.Concrete)
	b:Box(V3(16.4, 0.8, 14.4), CF(0, 8.9, 0), PAL.tea)
	b:Box(V3(6, 5, 0.1), CF(-3.5, 3.1, -7.05), PAL.steelDark, M.Metal)
	for i = 1, 9 do
		b:Box(V3(6, 0.06, 0.05), CF(-3.5, 0.9 + i * 0.5, -7.12), PAL.steel, nil, { solid = false })
	end
	b:Box(V3(2, 3.6, 0.1), CF(3, 2.4, -7.05), PAL.glass, M.Glass, { t = 0.3 })
	b:Box(V3(2.4, 0.2, 1.2), CF(3, 4.5, -7.5), PAL.tea)
	for _, x in { -3.5, 4 } do
		b:Box(V3(3.4, 1.6, 0.1), CF(x, 6.4, -7.05), PAL.glass, M.Glass, { t = 0.2 })
	end
	for _, x in { -8.05, 8.05 } do
		for _, z in { -3, 3 } do
			b:Box(V3(0.1, 1.6, 3), CF(x, 6.4, z), PAL.glass, M.Glass, { t = 0.2 })
		end
	end
	local sign = b:Box(V3(9, 1.3, 0.2), CF(0, 8.0, -7.3), PAL.green)
	b:Text(sign, FACE.Front, "ครัวกลาง", { color = PAL.cream })
	for _, x in { -4, 1 } do
		b:Cyl(1, 1.6, CF(x, 9.8, 2), PAL.steel, M.Metal)
		b:Cyl(0.2, 2, CF(x, 10.4, 2), PAL.steelDark, M.Metal)
	end
	b:Cyl(3, 0.8, CF(5.5, 10.8, 4), PAL.steelDark, M.Metal)
	for i, d in { 1.2, 1.6, 2.0 } do
		b:Ball(d, CF(5.5 + i * 0.2, 12.4 + i * 0.9, 4), PAL.white, nil, { t = 0.6, solid = false })
	end
	b:Box(V3(3, 1.4, 2), CF(-5, 9.9, -3.5), PAL.steel, M.Metal)
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

Build.L34 = function(b) -- ห้องเย็น
	b:Box(V3(12, 8, 12), CF(0, 4, 0), rgb(234, 240, 246))
	b:Box(V3(12.1, 0.6, 12.1), CF(0, 7.7, 0), PAL.blue)
	for _, x in { -4.5, -3, 2, 3.5, 5 } do
		b:Box(V3(0.08, 7.4, 0.06), CF(x, 3.7, -6.02), rgb(200, 208, 216), nil, { solid = false })
	end
	b:Box(V3(3, 5.6, 0.3), CF(-0.6, 2.8, -6.1), PAL.steel, M.Metal)
	b:Box(V3(0.25, 1.4, 0.3), CF(0.6, 2.8, -6.35), PAL.steelDark, M.Metal, { solid = false })
	for i = 0, 5 do
		b:Box(V3(0.45, 5.4, 0.03), CF(-1.85 + i * 0.5, 2.8, -6.3), PAL.glass, M.Glass, { t = 0.55, solid = false })
	end
	local temp = b:Box(V3(1.8, 0.8, 0.1), CF(3.4, 5.4, -6.05), PAL.black)
	b:Text(temp, FACE.Front, "-18°C", { color = rgb(255, 70, 70), glow = true })
	b:Box(V3(4, 1.5, 3), CF(0, 8.75, 2), PAL.steel, M.Metal)
	b:Cyl(0.2, 2.2, CF(0, 9.6, 2), PAL.black)
	local sign = b:Box(V3(6, 0.9, 0.15), CF(-2, 6.8, -6.1), PAL.blue)
	b:Text(sign, FACE.Front, "ห้องเย็น", { color = PAL.white })
	b:Box(V3(2.6, 0.4, 2.6), CF(4.3, 0.2, -8.2), PAL.wood, M.WoodPlanks)
	for _, p in { V3(3.7, 0.95, -8.8), V3(4.9, 0.95, -8.8), V3(3.7, 0.95, -7.6), V3(4.9, 0.95, -7.6), V3(4.3, 2.05, -8.2) } do
		b:Box(V3(1.1, 1.1, 1.1), CF(p), rgb(200, 160, 110), M.SmoothPlastic)
	end
end

Build.L35 = function(b) -- โรงคั่วชา (ถังคั่ว + กระสอบใบชา)
	for _, x in { -1.8, 1.8 } do
		for _, z in { -1, 1 } do
			b:Box(V3(0.4, 2, 0.4), CF(x, 1, z), PAL.black, M.Metal)
		end
	end
	b:HCyl(5, 3.2, CF(0, 3.2, 0), PAL.steelDark, M.Metal)
	for _, x in { -2.6, 2.6 } do
		b:HCyl(0.25, 3.4, CF(x, 3.2, 0), PAL.black, M.Metal)
	end
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
	for _, p in { V3(3.6, 0.8, -1.5), V3(3.6, 0.8, -0.4), V3(3.6, 2.4, -0.95) } do
		local sack = b:Box(V3(1.2, 1.6, 1.0), CF(p), rgb(200, 175, 130), M.Fabric)
		b:Text(sack, FACE.Front, "TEA", { color = PAL.teaDark, region = { 0.1, 0.3, 0.8, 0.4 } })
	end
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

Build.L38 = function(b) -- ไร่ชาขั้นบันได + กระท่อม
	local STEP = 1.8
	local layers = {
		{ V3(12, STEP, 12), 0 },
		{ V3(9.5, STEP, 9.5), 1.2 },
		{ V3(7, STEP, 7), 2.4 },
		{ V3(4.5, STEP, 4.5), 3.6 },
	}
	for i, layer in layers do
		b:Box(layer[1], CF(0, (i - 0.5) * STEP, layer[2]), if i == 1 then rgb(120, 90, 60) else rgb(110, 150, 70), if i == 1 then M.Ground else M.Grass)
	end
	local rand = seeded(38)
	for i = 1, 3 do
		local size = layers[i][1]
		local nextSize = layers[i + 1][1]
		local frontEdge = layers[i][2] - size.Z / 2
		local nextFront = layers[i + 1][2] - nextSize.Z / 2
		local z = (frontEdge + nextFront) / 2
		local count = math.floor(size.X / 1.5)
		for k = 0, count - 1 do
			local x = -size.X / 2 + 0.75 + k * 1.5
			b:Ellipsoid(V3(1.3, 0.9 + rand() * 0.3, 1.2), CF(x, i * STEP + 0.35, z), if k % 2 == 0 then PAL.leaf else PAL.leafDark)
		end
	end
	local hut = CF(0, 4 * STEP, 3.6)
	b:Box(V3(2.6, 1.8, 2.2), hut * CF(0, 0.9, 0), PAL.wood, M.WoodPlanks)
	b:Wedge(V3(3.0, 0.9, 1.3), hut * CF(0, 2.25, -0.65), PAL.teaDark, M.Wood)
	b:Wedge(V3(3.0, 0.9, 1.3), hut * CF(0, 2.25, 0.65) * ANG(0, rad(180), 0), PAL.teaDark, M.Wood)
	b:Box(V3(0.8, 1.2, 0.05), hut * CF(0, 0.6, -1.12), PAL.woodDark, nil, { solid = false })
	local sign = b:Box(V3(2.6, 1.0, 0.2), CF(3.8, 1.3, -6.3), PAL.woodDark, M.Wood)
	b:Text(sign, FACE.Front, "ไร่ชา", { color = PAL.cream })
	b:Box(V3(0.2, 1.2, 0.2), CF(3.8, 0.6, -6.3), PAL.woodDark, M.Wood)
end

Build.L39 = function(b) -- โรงงานบรรจุขวด (หลังคาฟันเลื่อย + ไซโล + ขวดยักษ์)
	b:Box(V3(11, 6, 10), CF(0, 3, 1), rgb(200, 196, 190), M.Concrete)
	for i, z in { -2.33, 1, 4.33 } do
		b:Wedge(V3(11, 2, 3.33), CF(0, 7, z), PAL.steelDark, M.Metal)
		b:Box(V3(11, 1.8, 0.08), CF(0, 7, z + 1.7), PAL.glass, M.Glass, { t = 0.3, solid = false })
		if i == 1 then
			b:Box(V3(11.02, 0.3, 10.02), CF(0, 5.9, 1), PAL.tea)
		end
	end
	for _, x in { -4.2, 4.2 } do
		b:Cyl(8, 2.2, CF(x, 4, -5), PAL.steel, M.Metal)
		b:Ellipsoid(V3(2.2, 1.2, 2.2), CF(x, 8, -5), PAL.steel, M.Metal)
		b:Cyl(0.3, 2.3, CF(x, 2.5, -5), PAL.tea)
	end
	b:HCyl(8.4, 0.4, CF(0, 7, -5), rgb(190, 120, 70), M.Metal)
	b:Box(V3(3.4, 3.4, 0.1), CF(0, 1.7, -4.05), PAL.steelDark, M.Metal)
	for i = 1, 5 do
		b:Box(V3(3.4, 0.05, 0.05), CF(0, i * 0.6, -4.12), PAL.steel, nil, { solid = false })
	end
	local sign = b:Box(V3(5, 1, 0.2), CF(0, 4.6, -4.12), PAL.tea)
	b:Text(sign, FACE.Front, "โรงงานบรรจุขวด", { color = PAL.white })
	for _, x in { -2.2, 2.2 } do
		b:Box(V3(1.2, 1.2, 0.1), CF(x, 3.4, -4.05), PAL.glass, M.Glass, { t = 0.2 })
	end
	-- ขวดยักษ์บนหลังคา
	b:Cyl(3, 1.8, CF(0, 9.5, 1), PAL.tea)
	b:Cyl(1, 1.85, CF(0, 9.6, 1), PAL.cream)
	b:Cyl(0.6, 1.2, CF(0, 11.3, 1), PAL.tea)
	b:Cyl(0.8, 0.6, CF(0, 12, 1), PAL.tea, M.Glass, { t = 0.2 })
	b:Cyl(0.3, 0.7, CF(0, 12.55, 1), PAL.red)
end

Build.L40 = function(b) -- ศูนย์กระจายสินค้า + รถยก
	b:Box(V3(8, 5, 12), CF(0, 2.5, 0), rgb(125, 155, 185), M.Metal)
	b:Wedge(V3(12, 1.8, 4), CF(-2, 5.9, 0) * ANG(0, rad(90), 0), rgb(85, 100, 120), M.Metal)
	b:Wedge(V3(12, 1.8, 4), CF(2, 5.9, 0) * ANG(0, rad(-90), 0), rgb(85, 100, 120), M.Metal)
	for _, x in { -2.6, 0, 2.6 } do
		b:Box(V3(2, 3, 0.1), CF(x, 1.5, -6.05), PAL.steelDark, M.Metal)
		for i = 1, 4 do
			b:Box(V3(2, 0.05, 0.05), CF(x, i * 0.6, -6.12), PAL.steel, nil, { solid = false })
		end
		b:Box(V3(0.3, 0.6, 0.3), CF(x - 1.2, 0.8, -6.15), PAL.black, nil, { solid = false })
	end
	local sign = b:Box(V3(7, 0.9, 0.1), CF(0, 4.1, -6.05), PAL.tea)
	b:Text(sign, FACE.Front, "ศูนย์กระจายสินค้า", { color = PAL.white })
	-- รถยก
	local fl = CF(-1.6, 0, -8.4)
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
	-- พาเลทสินค้า
	b:Box(V3(2.4, 0.4, 2.4), CF(1.9, 0.2, -8.4), PAL.wood, M.WoodPlanks)
	for _, p in { V3(1.3, 0.95, -9), V3(2.5, 0.95, -9), V3(1.3, 0.95, -7.8), V3(2.5, 0.95, -7.8), V3(1.9, 2.05, -8.4) } do
		local box = b:Box(V3(1.1, 1.1, 1.1), CF(p), rgb(200, 160, 110), M.SmoothPlastic)
		box.Name = "Carton"
	end
end

Build.L41 = function(b) -- สำนักงานใหญ่ (ตึกกระจก + ลานจอดเฮลิคอปเตอร์)
	b:Box(V3(8, 3, 8), CF(0, 1.5, 0), rgb(120, 170, 200), M.Glass, { t = 0.15 })
	b:Box(V3(2, 2.4, 0.1), CF(0, 1.2, -4.05), PAL.black, M.Glass)
	b:Box(V3(3.4, 0.2, 1.6), CF(0, 2.8, -4.7), PAL.white)
	for k = 1, 6 do
		local y = 3 + (k - 1) * 3
		b:Box(V3(8.2, 0.4, 8.2), CF(0, y + 0.2, 0), PAL.white, M.Concrete)
		b:Box(V3(7.8, 2.6, 7.8), CF(0, y + 1.7, 0), rgb(90, 150, 200), M.Glass, { t = 0.1 })
	end
	b:Box(V3(8.4, 1, 8.4), CF(0, 21.5, 0), PAL.tea)
	local pad = b:Cyl(0.3, 6, CF(0, 22.15, 0), PAL.steelDark, M.Concrete)
	b:Text(pad, FACE.Right, "H", { color = PAL.white })
	local sign = b:Box(V3(6, 1.4, 0.2), CF(0, 20.2, -4.3), PAL.tea)
	b:Text(sign, FACE.Front, "ชาไทย HQ", { color = PAL.white })
	b:Cyl(4, 0.2, CF(3.2, 24, 3.2), PAL.steelDark, M.Metal)
	b:Ball(0.4, CF(3.2, 26.1, 3.2), PAL.red, M.Neon, { solid = false })
end

Build.L42 = function(b) -- สาขาในห้าง
	b:Box(V3(11, 7, 10), CF(0, 3.5, 1), rgb(242, 230, 212), M.Concrete)
	b:Box(V3(11.2, 0.6, 10.2), CF(0, 7.3, 1), PAL.tea)
	b:Box(V3(5, 4.5, 0.1), CF(0, 2.25, -4.05), PAL.glass, M.Glass, { t = 0.3 })
	b:Box(V3(0.1, 4.5, 0.12), CF(0, 2.25, -4.1), PAL.steelDark, M.Metal, { solid = false })
	b:Box(V3(7, 0.3, 2), CF(0, 4.8, -5), PAL.white)
	for _, x in { -3.3, 3.3 } do
		b:Box(V3(0.2, 4.7, 0.2), CF(x, 2.35, -5.8), PAL.steelDark, M.Metal, { solid = false })
	end
	local sign = b:Box(V3(8, 1.2, 0.2), CF(0, 5.9, -4.1), PAL.green)
	b:Text(sign, FACE.Front, "ชาไทย สาขาห้าง", { color = PAL.cream })
	for _, x in { -5.55, 5.55 } do
		b:Box(V3(0.1, 2, 8), CF(x, 4.5, 1), PAL.glass, M.Glass, { t = 0.2 })
	end
	-- แก้วยักษ์บนหลังคา
	b:Cyl(3, 2.2, CF(0, 9.1, -1.5), PAL.tea)
	b:Cyl(0.6, 2.3, CF(0, 10.9, -1.5), PAL.milk)
	b:Ellipsoid(V3(2.3, 1.2, 2.3), CF(0, 11.3, -1.5), PAL.white, M.Glass, { t = 0.35 })
	b:Tube(V3(0.3, 11.2, -1.5), V3(0.8, 13.6, -1.3), 0.3, PAL.green)
	for i, x in { -5, 5 } do
		b:Cyl(6, 0.15, CF(x, 3, -5.6), PAL.steel, M.Metal)
		b:Box(V3(1.6, 1, 0.05), CF(x + 0.85, 5.4, -5.6), if i == 1 then PAL.tea else PAL.green, M.Fabric, { solid = false })
	end
end

Build.L43 = function(b) -- สาขาสนามบิน (อาคาร + หอบังคับการ + เครื่องบิน)
	b:Box(V3(8, 3.5, 5), CF(1, 1.75, -3), PAL.white)
	b:Box(V3(7.6, 2.4, 0.1), CF(1, 1.7, -5.55), PAL.glass, M.Glass, { t = 0.25 })
	b:Box(V3(9, 0.4, 6), CF(1, 3.7, -3), rgb(210, 214, 220), M.Metal)
	b:Wedge(V3(9, 0.8, 1.5), CF(1, 3.7, -6.75), rgb(210, 214, 220), M.Metal)
	local sign = b:Box(V3(6, 0.9, 0.1), CF(1, 4.4, -5.7), PAL.tea)
	b:Text(sign, FACE.Front, "สาขาสนามบิน ✈", { color = PAL.white })
	b:Cyl(8, 1.4, CF(-4.5, 4, -2), PAL.white)
	b:Cyl(1.6, 2.6, CF(-4.5, 8.8, -2), rgb(80, 160, 200), M.Glass, { t = 0.2 })
	b:Cyl(0.3, 2.9, CF(-4.5, 9.75, -2), PAL.white)
	b:Cyl(1.5, 0.12, CF(-4.5, 10.6, -2), PAL.steelDark, M.Metal)
	b:Ball(0.3, CF(-4.5, 11.4, -2), PAL.red, M.Neon, { solid = false })
	-- เครื่องบิน (ลำตัวตามแกน X)
	local plane = CF(1, 0, 3.5)
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
	end
	b:Box(V3(0.5, 0.25, 1.42), plane * CF(-4.2, 2.0, 0), PAL.black, M.Glass, { solid = false })
	for _, x in { -3.5, 1 } do
		b:Box(V3(0.15, 0.9, 0.15), plane * CF(x, 0.45, 0), PAL.black, nil, { solid = false })
	end
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

Build.L45 = function(b) -- ตึกแลนด์มาร์กทรงแก้วชาไทยไข่มุก
	b:Box(V3(8, 0.6, 8), CF(0, 0.3, 0), PAL.white, M.Marble)
	b:Box(V3(6, 0.3, 1), CF(0, 0.15, -4.4), PAL.white, M.Marble)
	b:Cyl(3, 7, CF(0, 2.1, 0), PAL.white, M.Concrete)
	local sign = b:Box(V3(5, 1.1, 0.2), CF(0, 2.4, -3.5), PAL.tea)
	b:Text(sign, FACE.Front, "THAI TEA TOWER", { color = PAL.white })
	local sections = 8
	local top = 3.6
	for i = 0, sections - 1 do
		local d = 5 + i * 0.28
		local color = if i == 0 then PAL.pearl elseif i % 2 == 0 then PAL.tea else rgb(222, 108, 40)
		b:Cyl(3, d, CF(0, top + 1.5, 0), color, M.SmoothPlastic, { solid = true })
		b:Cyl(0.3, d + 0.12, CF(0, top + 3, 0), PAL.warm, M.Neon)
		top += 3
	end
	-- ไข่มุกรอบชั้นล่าง
	for k = 0, 11 do
		local a = rad(k * 30)
		b:Ball(1, CF(math.cos(a) * 2.55, 4.8 + (k % 2) * 0.9, math.sin(a) * 2.55), PAL.pearl, M.Glass)
	end
	b:Cyl(2, 7.3, CF(0, top + 1, 0), PAL.milk)
	b:Ellipsoid(V3(7.5, 4, 7.5), CF(0, top + 2, 0), PAL.white, M.Glass, { t = 0.35 })
	local strawTop = V3(2.4, top + 12, 1.4)
	b:Tube(V3(0.6, top + 2, 0.4), strawTop, 0.9, PAL.green, M.SmoothPlastic)
	local beacon = b:Ball(1, CF(strawTop), PAL.red, M.Neon, { solid = false })
	b:Light(beacon, PAL.red, 20, 1)
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

-- CFrame ของ key ในฐาน เมื่อรู้ CFrame ผิวพื้นตรงกลางฐาน
function ItemModels.PlaceIn(key: string, plotFloor: CFrame): CFrame?
	local spot = ItemModels.Layout[key]
	if not spot then
		return nil
	end
	return plotFloor * CF(spot[1], spot[2], spot[3]) * ANG(0, rad(spot[4]), 0)
end

return ItemModels
