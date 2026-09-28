--!strict
-- Config: every game setting, shared by the server and the client.
-- Economy: 45 levels, level 45 costs ฿22M, about 50 minutes of active brewing (≈ 3.5 hours AFK).
-- Money loop: brew tea at the Brew Station → cash goes straight into your balance → walk to the green pad to upgrade.

local Config = {}

---------------------------------------------------------------------------
-- Testing switches
---------------------------------------------------------------------------
Config.BUILD_PLACEHOLDER_PLOTS = true -- no Workspace.Plots → build 6 plots with generated models
Config.STUDIO_GRANT_ALL_PASSES = false -- true = grant every Game Pass while testing in Studio (live game unaffected)
Config.PRINT_ECONOMY_CHECK = true -- print the price/income summary to Output when the server starts

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
	AutoBrew = { Id = 0, Name = "Auto Brew" }, -- brews one cup every AUTO_BREW_INTERVAL seconds, anywhere
	OfflinePlus = { Id = 0, Name = "Full Offline Income (24h)" },
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

-- Brewing (the main way to earn). "Base income" below is the pacing curve; the player gets it as:
Config.BREW_COOLDOWN = 0.35 -- seconds between brews (≈ 2.9 brews per second when spamming)
Config.BREW_SHARE = 0.3 -- cash per brew = 30% of the base income (active play ≈ base income overall)
Config.PASSIVE_SHARE = 0.25 -- passive income = 25% of the base income, paid straight into Cash
Config.AUTO_BREW_INTERVAL = 1 -- Auto Brew pass: one free cup per second

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

-- Total time (seconds) from level 1 to the last level without passes.
-- active = brewing nonstop; otherwise AFK on passive income only
function Config.TotalWaitSeconds(active: boolean?): number
	local total = 0
	for level = 2, Config.MAX_LEVEL do
		local rate = Config.Passive[level - 1]
		if active ~= false then
			rate += Config.BrewValue[level - 1] / Config.BREW_COOLDOWN
		end
		total += Config.Items[level].Price / rate
	end
	return total
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
