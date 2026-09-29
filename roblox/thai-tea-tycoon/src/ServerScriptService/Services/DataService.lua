-- DataService: simple DataStore load/save for player data
-- Note: no session locking. Switch to ProfileStore/ProfileService before launch.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local DataService = {}

local MAX_RECEIPTS = 50
local RETRIES = 3

local store: DataStore? = nil
local storeWarned = false
local sessions: { [Player]: any } = {}

local function warnStore(message: string)
	if not storeWarned then
		storeWarned = true
		warn("[DataService] " .. message .. " — the game still works but nothing will be saved "
			.. "(enable Game Settings → Security → Enable Studio Access to API Services)")
	end
end

local function defaultData()
	return {
		Version = 1,
		Cash = Config.START_CASH, -- deposited cash (spendable)
		Bag = 0, -- legacy field (the old carry bag), merged into Cash on load
		Stored = 0, -- legacy field (the old register balance), merged into Cash on load
		Level = 1,
		Staff = 0, -- hired baristas
		Recipe = 0, -- Better Recipe level
		Speed = 0, -- Faster Service level
		LastSeen = os.time(),
		Receipts = {}, -- recent granted PurchaseIds (prevents double grants)
		Rebirths = 0, -- each one adds Config.REBIRTH.BONUS to all income
		TotalEarned = 0, -- lifetime cash from brewing and income (leaderboard)
		LastDaily = 0, -- os.time() of the last daily reward claim
		DailyStreak = 0,
		Codes = {}, -- redeemed codes (upper case)
		QuestIndex = 1, -- position in Config.QUESTS
		QuestProgress = 0,
		QuestTarget = 0, -- 0 = not started yet (set when the quest begins)
	}
end

-- fields copied into every save (everything in defaultData except the legacy ones)
local SAVED_FIELDS = { "Version", "Cash", "Level", "Staff", "Recipe", "Speed", "LastSeen", "Rebirths", "TotalEarned",
	"LastDaily", "DailyStreak", "QuestIndex", "QuestProgress", "QuestTarget" }

-- fill fields missing from older saves and reject malformed values
local function reconcile(saved: any)
	local data = defaultData()
	if type(saved) ~= "table" then
		return data
	end
	for key, value in saved do
		if data[key] ~= nil and type(value) == type(data[key]) then
			data[key] = value
		end
	end
	data.Level = math.clamp(math.floor(data.Level), 1, Config.MAX_LEVEL)
	for key, u in Config.UPGRADES do
		data[key] = math.clamp(math.floor(data[key]), 0, u.Max)
	end
	data.Cash = math.max(0, data.Cash) + math.max(0, data.Stored) + math.max(0, data.Bag)
	data.Stored = 0
	data.Bag = 0
	data.Rebirths = math.max(0, math.floor(data.Rebirths))
	data.TotalEarned = math.max(0, data.TotalEarned)
	data.DailyStreak = math.clamp(math.floor(data.DailyStreak), 0, Config.DAILY.MAX_STREAK)
	data.QuestIndex = math.max(1, math.floor(data.QuestIndex))
	local codes = {}
	for _, code in data.Codes do
		if type(code) == "string" then
			table.insert(codes, code)
		end
	end
	data.Codes = codes
	return data
end

local function key(player: Player): string
	return "u_" .. player.UserId
end

local function withRetries(fn: () -> any): (boolean, any)
	local ok, result
	for attempt = 1, RETRIES do
		ok, result = pcall(fn)
		if ok then
			return true, result
		end
		if attempt < RETRIES then
			task.wait(attempt)
		end
	end
	return false, result
end

function DataService.Init()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Config.DATASTORE_NAME)
	end)
	if ok then
		store = result
	else
		warnStore("could not open DataStore: " .. tostring(result))
	end

	-- autosave
	task.spawn(function()
		while true do
			task.wait(Config.AUTOSAVE_INTERVAL)
			for player in sessions do
				task.spawn(DataService.Save, player)
			end
		end
	end)

	-- server shutdown: save everyone first
	game:BindToClose(function()
		local pending = 0
		for player in sessions do
			pending += 1
			task.spawn(function()
				DataService.Save(player)
				pending -= 1
			end)
		end
		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do
			task.wait(0.1)
		end
	end)
end

-- returns the player's data table (same table for the whole session; mutate it directly)
function DataService.Load(player: Player)
	if sessions[player] then
		return sessions[player]
	end

	local data
	if store then
		local ok, result = withRetries(function()
			return (store :: DataStore):GetAsync(key(player))
		end)
		if ok then
			data = reconcile(result)
		else
			data = defaultData()
			-- load failed: never overwrite, or the real save would be lost
			data.NoSave = true
			warnStore("could not load data for " .. player.Name .. ": " .. tostring(result))
		end
	else
		data = defaultData()
		data.NoSave = true
	end

	sessions[player] = data
	return data
end

function DataService.Get(player: Player)
	return sessions[player]
end

-- remember Developer Product grants
function DataService.HasReceipt(player: Player, purchaseId: string): boolean
	local data = sessions[player]
	return data ~= nil and table.find(data.Receipts, purchaseId) ~= nil
end

function DataService.AddReceipt(player: Player, purchaseId: string)
	local data = sessions[player]
	if not data then
		return
	end
	table.insert(data.Receipts, purchaseId)
	while #data.Receipts > MAX_RECEIPTS do
		table.remove(data.Receipts, 1)
	end
end

-- returns true when the save succeeded
function DataService.Save(player: Player): boolean
	local data = sessions[player]
	if not data or data.NoSave or not store then
		return false
	end
	data.LastSeen = os.time()

	local snapshot = { Bag = 0, Stored = 0, Receipts = table.clone(data.Receipts), Codes = table.clone(data.Codes) }
	for _, field in SAVED_FIELDS do
		snapshot[field] = data[field]
	end
	local ok, err = withRetries(function()
		return (store :: DataStore):UpdateAsync(key(player), function()
			return snapshot
		end)
	end)
	if not ok then
		warn("[DataService] Save failed for " .. player.Name .. ": " .. tostring(err))
	end
	return ok
end

-- player left: final save, then drop from memory
function DataService.Release(player: Player)
	if not sessions[player] then
		return
	end
	DataService.Save(player)
	sessions[player] = nil
end

return DataService
