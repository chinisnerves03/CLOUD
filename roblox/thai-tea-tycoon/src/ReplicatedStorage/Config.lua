--!strict
-- Config: ค่าตั้งทั้งหมดของเกม (ใช้ร่วมกันทั้งเซิร์ฟเวอร์และไคลเอนต์)
-- เศรษฐกิจ: 45 เลเวล, ราคาเลเวล 45 = ฿2.2M, รวมเวลารอประมาณ 52 นาที (ไม่นับเวลาเดิน)

local Config = {}

---------------------------------------------------------------------------
-- สวิตช์สำหรับทดสอบ
---------------------------------------------------------------------------
Config.BUILD_PLACEHOLDER_PLOTS = true -- ไม่มี Workspace.Plots → สร้างฐานจำลอง 6 ฐานให้เอง
Config.STUDIO_GRANT_ALL_PASSES = false -- true = ใน Studio ให้ Game Pass ทุกอัน (ไม่มีผลกับเกมจริง)
Config.PRINT_ECONOMY_CHECK = true -- พิมพ์ตารางราคา/รายได้ลง Output ตอนเริ่มเซิร์ฟเวอร์

---------------------------------------------------------------------------
-- ระบบทั่วไป
---------------------------------------------------------------------------
Config.PLOT_COUNT = 6
Config.PAD_COUNT = 3
Config.TICK = 0.1 -- วินาทีต่อรอบของลูปเซิร์ฟเวอร์
Config.AUTOSAVE_INTERVAL = 60
Config.DATASTORE_NAME = "ThaiTeaTycoon_v1"
Config.CURRENCY = "฿"

Config.OFFLINE = {
	MIN_SECONDS = 60, -- ไม่อยู่น้อยกว่านี้ไม่คิดรายได้ออฟไลน์
	RATE = 0.5, -- ได้ 50% ของรายได้ปกติ
	MAX_HOURS = 8,
	PASS_RATE = 1.0, -- มี Pass OfflinePlus ได้ 100%
	PASS_MAX_HOURS = 24,
}

-- Game Pass: ใส่ ID จาก Creator Dashboard (0 = ยังไม่ได้ตั้ง)
Config.PASSES = {
	DoubleCash = { Id = 0, Name = "รายได้ x2" },
	AutoCollect = { Id = 0, Name = "เก็บเงินอัตโนมัติ" },
	OfflinePlus = { Id = 0, Name = "รายได้ออฟไลน์เต็ม 24 ชม." },
}

-- Developer Product: ให้เงินเท่ากับรายได้ N วินาที (ขั้นต่ำ Min)
Config.PRODUCTS = {
	CashSmall = { Id = 0, Name = "เงินด่วน 10 นาที", Seconds = 600, Min = 100 },
	CashBig = { Id = 0, Name = "เงินด่วน 1 ชั่วโมง", Seconds = 3600, Min = 1000 },
}

-- เสียง: ใส่ "rbxassetid://..." (ว่าง = ไม่เล่นเสียง)
Config.SOUNDS = {
	Buy = "",
	Collect = "",
	Error = "",
}

---------------------------------------------------------------------------
-- เศรษฐกิจ
---------------------------------------------------------------------------
Config.MAX_LEVEL = 45
Config.START_CASH = 0
Config.FIRST_PRICE = 8 -- ราคาเลเวล 2
Config.LAST_PRICE = 2_200_000 -- ราคาเลเวล 45
Config.FIRST_WAIT = 8 -- วินาทีที่ต้องรอซื้อชิ้นแรก
Config.WAIT_GROWTH = 1.083 -- เวลารอแต่ละชิ้นยาวขึ้น 8.3% (รวม ≈ 52 นาที)

-- ชื่อของที่ซื้อ เลเวล 2..45 (44 ชิ้น) แบ่ง 5 ขั้น
Config.TIERS = {
	{ Name = "รถเข็นชาไทย", Color = Color3.fromRGB(230, 126, 34) },
	{ Name = "ร้านเล็กริมทาง", Color = Color3.fromRGB(241, 196, 15) },
	{ Name = "คาเฟ่ชาไทย", Color = Color3.fromRGB(46, 204, 113) },
	{ Name = "ครัวกลาง", Color = Color3.fromRGB(52, 152, 219) },
	{ Name = "อาณาจักรชาไทย", Color = Color3.fromRGB(155, 89, 182) },
}

local ITEM_LIST: { { string | number } } = {
	-- ขั้น 1
	{ "โต๊ะพับ", 1 }, { "กระติกน้ำแข็ง", 1 }, { "หม้อต้มชา", 1 },
	{ "ถุงกรองชา", 1 }, { "แก้วพลาสติก", 1 }, { "ร่มกันแดด", 1 },
	{ "ป้ายร้าน", 1 }, { "เครื่องซีลแก้ว", 1 }, { "ตู้เย็นเล็ก", 1 },
	-- ขั้น 2
	{ "เคาน์เตอร์ไม้", 2 }, { "เครื่องชงชาไฟฟ้า", 2 }, { "ตู้ท็อปปิ้ง", 2 },
	{ "หม้อไข่มุก", 2 }, { "เก้าอี้ลูกค้า", 2 }, { "โต๊ะหน้าร้าน", 2 },
	{ "ไฟประดับ", 2 }, { "เครื่องคิดเงิน", 2 }, { "พนักงานชงชา", 2 },
	-- ขั้น 3
	{ "เครื่องทำน้ำแข็ง", 3 }, { "เมนูบอร์ดไฟ", 3 }, { "เครื่องปั่น", 3 },
	{ "ตู้เค้ก", 3 }, { "มุมถ่ายรูป", 3 }, { "แอร์", 3 },
	{ "ชั้นวางใบชา", 3 }, { "บาร์ชงโชว์", 3 }, { "ป้ายไฟนีออน", 3 },
	-- ขั้น 4
	{ "ครัวกลาง", 4 }, { "รถส่งของ", 4 }, { "สายพานแก้ว", 4 },
	{ "เครื่องชงอัตโนมัติ", 4 }, { "จุดรับออร์เดอร์ออนไลน์", 4 }, { "ห้องเย็น", 4 },
	{ "โรงคั่วชา", 4 }, { "ทีมบาริสต้า", 4 }, { "ป้ายบิลบอร์ด", 4 },
	-- ขั้น 5
	{ "ไร่ชา", 5 }, { "โรงงานบรรจุขวด", 5 }, { "ศูนย์กระจายสินค้า", 5 },
	{ "สำนักงานใหญ่", 5 }, { "สาขาในห้าง", 5 }, { "สาขาสนามบิน", 5 },
	{ "แฟรนไชส์ทั่วประเทศ", 5 }, { "ตึกชาไทยแลนด์มาร์ก", 5 },
}

export type Item = { Level: number, Key: string, Name: string, Tier: number, Price: number }

-- ปัดเป็นเลขสวย 2 หลักสำคัญ (เช่น 1,234 → 1,200)
local function nice(n: number): number
	if n < 100 then
		return math.max(1, math.floor(n + 0.5))
	end
	local mag = 10 ^ (math.floor(math.log10(n)) - 1)
	return math.floor(n / mag + 0.5) * mag
end

-- Config.Items[level] = ของที่ได้เมื่อถึงเลเวลนั้น (level 2..45)
-- Config.Income[level] = รายได้ต่อวินาทีเมื่ออยู่เลเวลนั้น (level 1..45)
Config.Items = {} :: { [number]: Item }
Config.Income = {} :: { [number]: number }

do
	local steps = Config.MAX_LEVEL - 2
	local priceGrowth = (Config.LAST_PRICE / Config.FIRST_PRICE) ^ (1 / steps)
	local incomeGrowth = priceGrowth / Config.WAIT_GROWTH
	assert(#ITEM_LIST == Config.MAX_LEVEL - 1, "ITEM_LIST ต้องมี " .. (Config.MAX_LEVEL - 1) .. " ชิ้น")

	for level = 2, Config.MAX_LEVEL do
		local entry = ITEM_LIST[level - 1]
		local price = if level == Config.MAX_LEVEL
			then Config.LAST_PRICE
			else nice(Config.FIRST_PRICE * priceGrowth ^ (level - 2))
		Config.Items[level] = {
			Level = level,
			Key = string.format("L%02d", level),
			Name = entry[1] :: string,
			Tier = entry[2] :: number,
			Price = price,
		}
	end

	local firstIncome = Config.FIRST_PRICE / Config.FIRST_WAIT
	for level = 1, Config.MAX_LEVEL do
		Config.Income[level] = nice(firstIncome * incomeGrowth ^ (level - 1))
	end
end

function Config.GetItem(level: number): Item?
	return Config.Items[level]
end

function Config.GetIncome(level: number): number
	return Config.Income[math.clamp(level, 1, Config.MAX_LEVEL)]
end

-- เวลารอรวม (วินาที) ตั้งแต่เลเวล 1 ถึงเลเวลสุดท้าย ถ้าไม่มี Pass
function Config.TotalWaitSeconds(): number
	local total = 0
	for level = 2, Config.MAX_LEVEL do
		total += Config.Items[level].Price / Config.Income[level - 1]
	end
	return total
end

---------------------------------------------------------------------------
-- แสดงตัวเลขเงิน
---------------------------------------------------------------------------
local SUFFIXES = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }

local function withCommas(n: number): string
	local s = tostring(math.floor(n))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if out:sub(1, 1) == "," then
		out = out:sub(2)
	end
	return out
end

function Config.FormatMoney(n: number): string
	n = math.floor(n)
	if n >= 100_000 then
		for _, pair in SUFFIXES do
			local value, suffix = pair[1] :: number, pair[2] :: string
			if n >= value then
				local short = string.format("%.2f", n / value):gsub("%.?0+$", "")
				return Config.CURRENCY .. short .. suffix
			end
		end
	end
	return Config.CURRENCY .. withCommas(n)
end

function Config.FormatTime(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	if seconds < 60 then
		return seconds .. " วินาที"
	elseif seconds < 3600 then
		return math.floor(seconds / 60) .. " นาที " .. (seconds % 60) .. " วินาที"
	end
	return math.floor(seconds / 3600) .. " ชม. " .. math.floor(seconds % 3600 / 60) .. " นาที"
end

return Config
