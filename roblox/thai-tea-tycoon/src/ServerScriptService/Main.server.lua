-- Main: server entry point that wires every service together
-- Join order: DataService.Load → Monetization.LoadPasses → PlotService.AddPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Services = script.Parent:WaitForChild("Services")
local DataService = require(Services:WaitForChild("DataService"))
local PlotService = require(Services:WaitForChild("PlotService"))
local MonetizationService = require(Services:WaitForChild("MonetizationService"))

-- Channel for client notifications (kind, text)
local notifyRemote = Instance.new("RemoteEvent")
notifyRemote.Name = "TycoonNotify"
notifyRemote.Parent = ReplicatedStorage

if Config.PRINT_ECONOMY_CHECK then
	print(string.format("[Config] %d levels, final price %s, top brew %s/cup, full shop ≈ %.1f min brewing (%.1f min AFK)",
		Config.MAX_LEVEL,
		Config.FormatMoney(Config.Items[Config.MAX_LEVEL].Price),
		Config.FormatMoney(Config.BrewValue[Config.MAX_LEVEL]),
		Config.TotalWaitSeconds(true) / 60,
		Config.TotalWaitSeconds(false) / 60))
end

DataService.Init()
PlotService.Init(MonetizationService, notifyRemote)
MonetizationService.Init(DataService, PlotService)

local function onPlayerAdded(player: Player)
	local data = DataService.Load(player)
	if not player:IsDescendantOf(Players) then
		-- left before loading finished
		DataService.Release(player)
		return
	end
	MonetizationService.LoadPasses(player)
	if not player:IsDescendantOf(Players) then
		DataService.Release(player)
		return
	end
	PlotService.AddPlayer(player, data)
end

local function onPlayerRemoving(player: Player)
	PlotService.RemovePlayer(player)
	DataService.Release(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end
