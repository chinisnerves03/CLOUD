-- DataService: DataStore load/save for player data, with a session lock.
-- The saved document carries SessionLock = { Id = this server's id, Time = last heartbeat }. A server only loads a
-- save when no other server holds a fresh lock (it waits up to LOCK_WAIT seconds, then takes it over: the other
-- server has crashed or is still finishing its final save), and only writes while it still owns the lock. If another
-- server took the lock (the player joined elsewhere), this server stops saving and kicks the stale session, so a
-- player in two servers at once can never overwrite newer progress.

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local DataService = {}

local MAX_RECEIPTS = 50
local RETRIES = 3
local SERVER_ID = HttpService:GenerateGUID(false) -- game.JobId is empty in Studio
-- seconds to wait for another server to release a save before taking it over. Studio is quick: pressing Stop ends
-- the test server before it can release its lock, and the next test should not wait half a minute for itself.
local LOCK_WAIT = if game:GetService("RunService"):IsStudio() then 3 else 30
local LOCK_STALE = 600 -- a lock without a heartbeat for this long is ignored right away

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
				DataService.Save(player, true)
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
		local started = os.clock()
		local loaded, failed, gaveUp, lastError = nil, false, false, nil
		while true do
			local takeOver = os.clock() - started >= LOCK_WAIT
			local blocked = false
			local ok, result = withRetries(function()
				return (store :: DataStore):UpdateAsync(key(player), function(saved)
					local lock = type(saved) == "table" and saved.SessionLock or nil
					if type(lock) == "table" and lock.Id ~= SERVER_ID and not takeOver
						and os.time() - (tonumber(lock.Time) or 0) < LOCK_STALE then
						blocked = true
						return nil -- another server still has this player: cancel and try again
					end
					if type(saved) ~= "table" then
						saved = {}
					end
					saved.SessionLock = { Id = SERVER_ID, Time = os.time() }
					return saved
				end)
			end)
			if not ok then
				failed, lastError = true, result
				break
			end
			if not blocked then
				loaded = result
				if takeOver then
					warn("[DataService] Took over the save of " .. player.Name .. " from another server")
				end
				break
			end
			if not player:IsDescendantOf(Players) then
				gaveUp = true -- left while waiting: we never got the lock, so never write
				break
			end
			task.wait(3)
		end
		if gaveUp then
			data = defaultData()
			data.NoSave = true
		elseif failed then
			data = defaultData()
			-- load failed: never overwrite, or the real save would be lost
			data.NoSave = true
			warnStore("could not load data for " .. player.Name .. ": " .. tostring(lastError))
		else
			-- a brand-new player comes back as { SessionLock = ... } and reconciles to the defaults
			data = reconcile(loaded)
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

-- returns true when the save succeeded. release = true also gives up the session lock (player left)
function DataService.Save(player: Player, release: boolean?): boolean
	local data = sessions[player]
	if not data or data.NoSave or not store then
		return false
	end
	data.LastSeen = os.time()

	local snapshot = { Bag = 0, Stored = 0, Receipts = table.clone(data.Receipts), Codes = table.clone(data.Codes) }
	for _, field in SAVED_FIELDS do
		snapshot[field] = data[field]
	end
	snapshot.SessionLock = if release then nil else { Id = SERVER_ID, Time = os.time() }
	local lostLock = false
	local ok, err = withRetries(function()
		return (store :: DataStore):UpdateAsync(key(player), function(saved)
			local lock = type(saved) == "table" and saved.SessionLock or nil
			if type(lock) == "table" and lock.Id ~= SERVER_ID then
				lostLock = true
				return nil -- another server owns this save now: never overwrite it
			end
			return snapshot
		end)
	end)
	if lostLock then
		data.NoSave = true
		warn("[DataService] " .. player.Name .. " is playing in another server; this session stops saving")
		if player:IsDescendantOf(Players) then
			player:Kick("You joined the game from another server. Your progress continues there.")
		end
		return false
	end
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
	DataService.Save(player, true)
	sessions[player] = nil
end

return DataService
