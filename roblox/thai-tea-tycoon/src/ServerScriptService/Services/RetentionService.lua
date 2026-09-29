-- RetentionService: rebirth, daily reward, codes, short quests and the player-list leaderstats.
-- Clients ask through the RemoteEvent ReplicatedStorage.TycoonAction ("Rebirth" | "ClaimDaily" | "Redeem", code);
-- everything is checked here. State for the UI goes out as player Attributes:
--   Rebirths, DailyAt (unix time the next daily reward unlocks), DailyStreak,
--   QuestText, QuestProgress, QuestTarget, QuestReward

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local RetentionService = {}

local DataService
local PlotService
local lastAction: { [Player]: number } = {}

local ACTION_COOLDOWN = 0.5
local HOUR = 3600

local function setAttr(player: Player, name: string, value: any)
	if player:GetAttribute(name) ~= value then
		player:SetAttribute(name, value)
	end
end

-- a reward worth `seconds` of the player's base income, at least `min`
local function rewardFor(player: Player, seconds: number, min: number): number
	return math.floor(math.max(min, PlotService.GetBaseIncome(player) * seconds))
end

local function grant(player: Player, amount: number, text: string, kind: string?)
	PlotService.AddCash(player, amount)
	PlotService.Notify(player, kind or "Buy", text .. ": +" .. Config.FormatMoney(amount))
end

---------------------------------------------------------------------------
-- Daily reward
---------------------------------------------------------------------------
local function dailyStreakIfClaimed(data): number
	local since = os.time() - data.LastDaily
	if data.LastDaily == 0 or since > Config.DAILY.STREAK_HOURS * HOUR then
		return 1
	end
	return math.min(data.DailyStreak + 1, Config.DAILY.MAX_STREAK)
end

local function updateDailyAttrs(player: Player, data)
	setAttr(player, "DailyAt", data.LastDaily + Config.DAILY.COOLDOWN_HOURS * HOUR)
	setAttr(player, "DailyStreak", dailyStreakIfClaimed(data))
end

local function claimDaily(player: Player, data)
	local readyAt = data.LastDaily + Config.DAILY.COOLDOWN_HOURS * HOUR
	if os.time() < readyAt then
		PlotService.Notify(player, "Error", "Daily reward is ready in " .. Config.FormatTime(readyAt - os.time()))
		return
	end
	local streak = dailyStreakIfClaimed(data)
	data.DailyStreak = streak
	data.LastDaily = os.time()
	local amount = rewardFor(player, Config.DAILY.SECONDS * streak, Config.DAILY.MIN * streak)
	grant(player, amount, string.format("Daily reward (day %d)", streak), "Collect")
	updateDailyAttrs(player, data)
	DataService.Save(player)
end

---------------------------------------------------------------------------
-- Codes
---------------------------------------------------------------------------
local function redeem(player: Player, data, raw: any)
	if type(raw) ~= "string" or #raw == 0 or #raw > 32 then
		return
	end
	local code = raw:upper():gsub("%s", "")
	local spec = Config.CODES[code]
	if not spec or (spec.Expires and os.time() > spec.Expires) then
		PlotService.Notify(player, "Error", "That code doesn't work")
		return
	end
	if table.find(data.Codes, code) then
		PlotService.Notify(player, "Error", "You already used this code")
		return
	end
	table.insert(data.Codes, code)
	grant(player, rewardFor(player, spec.Seconds, spec.Min), "Code " .. code)
	DataService.Save(player)
end

---------------------------------------------------------------------------
-- Quests
---------------------------------------------------------------------------
local function questAt(index: number)
	return Config.QUESTS[(index - 1) % #Config.QUESTS + 1]
end

-- quests that cannot be done right now (nothing left to build or upgrade) are skipped
local function questPossible(data, quest): boolean
	if quest.Kind == "Build" then
		return data.Level + (quest.Target or 1) <= Config.MAX_LEVEL
	elseif quest.Kind == "Upgrade" then
		local left = 0
		for key, u in Config.UPGRADES do
			left += u.Max - data[key]
		end
		return left >= (quest.Target or 1)
	end
	return true
end

local function startQuest(player: Player, data)
	for _ = 1, #Config.QUESTS do
		local quest = questAt(data.QuestIndex)
		if questPossible(data, quest) then
			break
		end
		data.QuestIndex += 1
	end
	local quest = questAt(data.QuestIndex)
	data.QuestProgress = 0
	data.QuestTarget = if quest.Kind == "Earn"
		then math.max(100, math.floor(PlotService.GetBaseIncome(player) * (quest.Seconds or 60)))
		else quest.Target or 1
end

local function questText(quest, target: number): string
	if quest.Kind == "Brew" then
		return string.format("Brew %d cups", target)
	elseif quest.Kind == "Build" then
		return if target == 1 then "Build a new item" else string.format("Build %d new items", target)
	elseif quest.Kind == "Upgrade" then
		return if target == 1 then "Buy an upgrade" else string.format("Buy %d upgrades", target)
	end
	return "Earn " .. Config.FormatMoney(target)
end

local function updateQuestAttrs(player: Player, data)
	local quest = questAt(data.QuestIndex)
	setAttr(player, "QuestText", questText(quest, data.QuestTarget))
	setAttr(player, "QuestProgress", math.floor(math.min(data.QuestProgress, data.QuestTarget)))
	setAttr(player, "QuestTarget", data.QuestTarget)
	setAttr(player, "QuestReward", rewardFor(player, quest.Reward, Config.QUEST_MIN_REWARD))
end

local function onProgress(player: Player, kind: string, amount: number)
	local data = DataService.Get(player)
	if not data or data.QuestTarget <= 0 then
		return
	end
	local quest = questAt(data.QuestIndex)
	if quest.Kind ~= kind then
		return
	end
	data.QuestProgress += amount
	if data.QuestProgress >= data.QuestTarget then
		local text = questText(quest, data.QuestTarget)
		local reward = rewardFor(player, quest.Reward, Config.QUEST_MIN_REWARD)
		data.QuestIndex += 1
		startQuest(player, data)
		-- defer: onProgress runs inside PlotService's money loop
		task.defer(grant, player, reward, "Quest done: " .. text)
	end
	updateQuestAttrs(player, data)
end

---------------------------------------------------------------------------
-- leaderstats (the Roblox player list)
---------------------------------------------------------------------------
local function makeLeaderstats(player: Player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Parent = stats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Parent = stats
	stats.Parent = player
	local function sync()
		level.Value = tonumber(player:GetAttribute("Level")) or 1
		rebirths.Value = tonumber(player:GetAttribute("Rebirths")) or 0
	end
	player:GetAttributeChangedSignal("Level"):Connect(sync)
	player:GetAttributeChangedSignal("Rebirths"):Connect(sync)
	sync()
end

---------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------
-- called by Main after PlotService.AddPlayer
function RetentionService.AddPlayer(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	if data.QuestTarget <= 0 then
		startQuest(player, data)
	end
	updateDailyAttrs(player, data)
	updateQuestAttrs(player, data)
	makeLeaderstats(player)
	if os.time() >= data.LastDaily + Config.DAILY.COOLDOWN_HOURS * HOUR then
		task.delay(5, PlotService.Notify, player, "Offline", "Your daily reward is ready! Press DAILY on the left")
	end
end

function RetentionService.Init(dataService, plotService, actionRemote: RemoteEvent)
	DataService = dataService
	PlotService = plotService
	PlotService.OnProgress = onProgress

	actionRemote.OnServerEvent:Connect(function(player: Player, action: any, arg: any)
		local now = os.clock()
		if now - (lastAction[player] or 0) < ACTION_COOLDOWN then
			return
		end
		lastAction[player] = now
		local data = DataService.Get(player)
		if not data or not PlotService.GetData(player) then
			return
		end
		if action == "ClaimDaily" then
			claimDaily(player, data)
		elseif action == "Redeem" then
			redeem(player, data, arg)
		elseif action == "Rebirth" then
			if PlotService.Rebirth(player) then
				startQuest(player, data)
				updateQuestAttrs(player, data)
				DataService.Save(player)
			end
		end
	end)

	-- the quest reward shown in the UI follows income as the shop grows
	task.spawn(function()
		while true do
			task.wait(2)
			for _, player in Players:GetPlayers() do
				local data = DataService.Get(player)
				if data and PlotService.GetData(player) then
					updateQuestAttrs(player, data)
					updateDailyAttrs(player, data)
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastAction[player] = nil
	end)
end

return RetentionService
