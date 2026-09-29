--!strict
-- Config: every game setting, shared by the server and the client.
-- Economy: 45 levels, level 45 costs ฿22M. About 40 minutes when you brew along with your staff,
-- about 70 minutes without ever brewing (simulated with a buy-the-cheapest-upgrade player).
-- Money loop: the shop sells tea by itself from the start (money never stops) → brew by hand to earn faster
-- → hire staff, upgrade recipe and speed → walk to the green pad (behind each new item's spot) to grow the shop.

local Config = {}

---------------------------------------------------------------------------
-- Testing switches
---------------------------------------------------------------------------
Config.BUILD_PLACEHOLDER_PLOTS = true -- no Workspace.Plots → build 6 plots with generated models
Config.STUDIO_GRANT_ALL_PASSES = false -- true = grant every Game Pass while testing in Studio (live game unaffected)
Config.PRINT_ECONOMY_CHECK = true -- print the price/income summary to Output when the server starts
Config.SETUP_LIGHTING = true -- warm afternoon lighting + atmosphere, bloom and color grading (set false to keep your own)

---------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------
Config.PLOT_COUNT = 6
Config.PAD_COUNT = 1 -- one buy pad that moves to wherever the next item will appear
Config.TICK = 0.1 -- seconds per server loop step
Config.AUTOSAVE_INTERVAL = 60
Config.DATASTORE_NAME = "ThaiTeaTycoon_v1"
Config.CURRENCY = "฿"

Config.OFFLINE = {
	MIN_SECONDS = 60, -- shorter absences earn nothing
	RATE = 0.5, -- 50% of normal income
	MAX_HOURS = 8,
	PASS_RATE = 1.0, -- 100% with the OfflinePlus pass
	PASS_MAX_HOURS = 24,
}

-- Game Passes: put the IDs from the Creator Dashboard here (0 = not set yet)
Config.PASSES = {
	DoubleCash = { Id = 0, Name = "2x Income" },
	VipBarista = { Id = 0, Name = "VIP Barista" }, -- a golden barista who sells a cup every VIP_INTERVAL seconds
	OfflinePlus = { Id = 0, Name = "Full Offline Income (24h)" },
	AutoBuild = { Id = 0, Name = "Auto Build" }, -- builds the next item the moment you can afford it
}

-- Developer Products: grant cash equal to N seconds of income (at least Min)
Config.PRODUCTS = {
	CashSmall = { Id = 0, Name = "Cash Boost (10 min)", Seconds = 600, Min = 1000 },
	CashBig = { Id = 0, Name = "Cash Boost (1 hour)", Seconds = 3600, Min = 10000 },
}

-- Sounds: "rbxassetid://..." (empty = no sound)
Config.SOUNDS = {
	Brew = "",
	Buy = "",
	Collect = "",
	Error = "",
}

---------------------------------------------------------------------------
-- Economy
---------------------------------------------------------------------------
Config.MAX_LEVEL = 45
Config.START_CASH = 0
Config.FIRST_PRICE = 80 -- price of level 2
Config.LAST_PRICE = 22_000_000 -- price of level 45
Config.FIRST_WAIT = 8 -- seconds of waiting for the first item
Config.WAIT_GROWTH = 1.083 -- each item takes 8.3% longer to afford

-- "Base income" below is the pacing curve; the player gets it as:
Config.BREW_COOLDOWN = 0.35 -- seconds between brews (≈ 2.9 brews per second when spamming)
Config.BREW_SHARE = 0.15 -- cash per cup = 15% of the base income curve
Config.PASSIVE_SHARE = 0.25 -- counter sales: the shop sells 25% of the base curve per second by itself,
-- from the very start and wherever you are (Better Recipe, Faster Service and 2x Income boost it too)
Config.STAFF_INTERVAL = 3 -- each hired barista sells one cup every 3 seconds (faster with Faster Service)
Config.VIP_INTERVAL = 1 -- the VIP Barista pass sells one cup per second

-- Repeatable upgrades bought on the pads next to the Brew Station. Cost = Base × Growth^owned.
Config.UPGRADES = {
	Staff = { Name = "Hire Staff", Base = 300, Growth = 3.5, Max = 6 },
	Recipe = { Name = "Better Recipe", Base = 800, Growth = 3.0, Max = 15, Step = 0.10 }, -- +10% per cup each level
	Speed = { Name = "Faster Service", Base = 1500, Growth = 3.2, Max = 10, Step = 0.08 }, -- +8% brewing speed each level
}
Config.UPGRADE_ORDER = { "Staff", "Recipe", "Speed" }

-- Purchasable items for levels 2..45 (44 items) in 5 tiers
Config.TIERS = {
	{ Name = "Thai Tea Cart", Color = Color3.fromRGB(230, 126, 34) },
	{ Name = "Street Shop", Color = Color3.fromRGB(241, 196, 15) },
	{ Name = "Thai Tea Cafe", Color = Color3.fromRGB(46, 204, 113) },
	{ Name = "Central Kitchen", Color = Color3.fromRGB(52, 152, 219) },
	{ Name = "Thai Tea Empire", Color = Color3.fromRGB(155, 89, 182) },
}

local ITEM_LIST: { { string | number } } = {
	-- Tier 1
	{ "Folding Table", 1 }, { "Ice Cooler", 1 }, { "Tea Pot", 1 },
	{ "Tea Filter Sock", 1 }, { "Plastic Cups", 1 }, { "Market Umbrella", 1 },
	{ "Shop Sign", 1 }, { "Cup Sealer", 1 }, { "Mini Fridge", 1 },
	-- Tier 2
	{ "Wooden Counter", 2 }, { "Tea Brewer", 2 }, { "Topping Bar", 2 },
	{ "Pearl Pot", 2 }, { "Bar Stools", 2 }, { "Patio Table", 2 },
	{ "String Lights", 2 }, { "Cash Register", 2 }, { "Tea Master", 2 },
	-- Tier 3
	{ "Ice Machine", 3 }, { "Menu Board", 3 }, { "Blender Station", 3 },
	{ "Cake Display", 3 }, { "Photo Corner", 3 }, { "Air Conditioner", 3 },
	{ "Tea Leaf Shelf", 3 }, { "Show Bar", 3 }, { "Neon Sign", 3 },
	-- Tier 4
	{ "Central Kitchen", 4 }, { "Delivery Van", 4 }, { "Cup Conveyor", 4 },
	{ "Auto Brewer", 4 }, { "Online Order Kiosk", 4 }, { "Cold Room", 4 },
	{ "Tea Roastery", 4 }, { "Barista Team", 4 }, { "Billboard", 4 },
	-- Tier 5
	{ "Tea Plantation", 5 }, { "Bottling Factory", 5 }, { "Distribution Center", 5 },
	{ "Headquarters", 5 }, { "Mall Branch", 5 }, { "Airport Branch", 5 },
	{ "Nationwide Franchise", 5 }, { "Thai Tea Tower", 5 },
}

export type Item = { Level: number, Key: string, Name: string, Tier: number, Price: number }

-- Round to 2 significant digits (e.g. 1,234 → 1,200)
local function nice(n: number): number
	if n < 100 then
		return math.max(1, math.floor(n + 0.5))
	end
	local mag = 10 ^ (math.floor(math.log10(n)) - 1)
	return math.floor(n / mag + 0.5) * mag
end

-- Config.Items[level] = the item unlocked at that level (levels 2..45)
-- Config.Income[level] = base income per second at that level (levels 1..45), the pacing curve
-- Config.BrewValue[level] = cash per brewed cup, Config.Passive[level] = passive cash per second
Config.Items = {} :: { [number]: Item }
Config.Income = {} :: { [number]: number }
Config.BrewValue = {} :: { [number]: number }
Config.Passive = {} :: { [number]: number }

do
	local steps = Config.MAX_LEVEL - 2
	local priceGrowth = (Config.LAST_PRICE / Config.FIRST_PRICE) ^ (1 / steps)
	local incomeGrowth = priceGrowth / Config.WAIT_GROWTH
	assert(#ITEM_LIST == Config.MAX_LEVEL - 1, "ITEM_LIST must have " .. (Config.MAX_LEVEL - 1) .. " items")

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
		local income = nice(firstIncome * incomeGrowth ^ (level - 1))
		Config.Income[level] = income
		Config.BrewValue[level] = nice(income * Config.BREW_SHARE)
		Config.Passive[level] = income * Config.PASSIVE_SHARE
	end
end

function Config.GetItem(level: number): Item?
	return Config.Items[level]
end

function Config.GetIncome(level: number): number
	return Config.Income[math.clamp(level, 1, Config.MAX_LEVEL)]
end

function Config.GetBrewValue(level: number): number
	return Config.BrewValue[math.clamp(level, 1, Config.MAX_LEVEL)]
end

function Config.GetPassive(level: number): number
	return Config.Passive[math.clamp(level, 1, Config.MAX_LEVEL)]
end

-- cost of the next level of an upgrade, or nil when it is maxed out
function Config.UpgradeCost(key: string, owned: number): number?
	local u = (Config.UPGRADES :: any)[key]
	if not u or owned >= u.Max then
		return nil
	end
	return nice(u.Base * u.Growth ^ owned)
end

-- multipliers from upgrade levels
function Config.RecipeMultiplier(recipe: number): number
	return 1 + Config.UPGRADES.Recipe.Step * recipe
end

function Config.SpeedMultiplier(speed: number): number
	return 1 + Config.UPGRADES.Speed.Step * speed
end

---------------------------------------------------------------------------
-- Number formatting
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

-- per-second rates can be fractional (e.g. ฿2.5/s), so keep one decimal for small values
function Config.FormatRate(n: number): string
	if n < 100 and n ~= math.floor(n) then
		return Config.CURRENCY .. string.format("%.1f", n)
	end
	return Config.FormatMoney(n)
end

function Config.FormatTime(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	if seconds < 60 then
		return seconds .. "s"
	elseif seconds < 3600 then
		return math.floor(seconds / 60) .. "m " .. (seconds % 60) .. "s"
	end
	return math.floor(seconds / 3600) .. "h " .. math.floor(seconds % 3600 / 60) .. "m"
end

return Config
