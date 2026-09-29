-- Main: server entry point that wires every service together
-- Join order: DataService.Load → Monetization.LoadPasses → PlotService.AddPlayer → RetentionService.AddPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Services = script.Parent:WaitForChild("Services")
local DataService = require(Services:WaitForChild("DataService"))
local PlotService = require(Services:WaitForChild("PlotService"))
local MonetizationService = require(Services:WaitForChild("MonetizationService"))
local RetentionService = require(Services:WaitForChild("RetentionService"))
local LeaderboardService = require(Services:WaitForChild("LeaderboardService"))

-- Channel for client notifications (kind, text)
local notifyRemote = Instance.new("RemoteEvent")
notifyRemote.Name = "TycoonNotify"
notifyRemote.Parent = ReplicatedStorage

-- Channel for client requests (action, arg): "Rebirth", "ClaimDaily", "Redeem" — validated by RetentionService
local actionRemote = Instance.new("RemoteEvent")
actionRemote.Name = "TycoonAction"
actionRemote.Parent = ReplicatedStorage

if Config.PRINT_ECONOMY_CHECK then
	print(string.format("[Config] %d levels, first item %s, final item %s, cup value %s → %s",
		Config.MAX_LEVEL,
		Config.FormatMoney(Config.Items[2].Price),
		Config.FormatMoney(Config.Items[Config.MAX_LEVEL].Price),
		Config.FormatMoney(Config.BrewValue[1]),
		Config.FormatMoney(Config.BrewValue[Config.MAX_LEVEL])))
end

-- Warm afternoon look: soft shadows, light haze, gentle bloom and a little extra color.
-- (Set Lighting.LightingStyle = Realistic and PrioritizeLightingQuality in Studio for the best result; scripts cannot change them.)
local function setupLighting()
	local Lighting = game:GetService("Lighting")
	Lighting.ClockTime = 15.2
	Lighting.GeographicLatitude = 20
	Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(90, 80, 70)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 140, 130)
	Lighting.EnvironmentDiffuseScale = 0.8
	Lighting.EnvironmentSpecularScale = 0.8
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.25
	local function effect(className: string, props)
		local existing = Lighting:FindFirstChildOfClass(className)
		local obj = existing or Instance.new(className)
		for key, value in props do
			(obj :: any)[key] = value
		end
		obj.Parent = Lighting
	end
	effect("Atmosphere", { Density = 0.28, Offset = 0.1, Color = Color3.fromRGB(255, 236, 214), Decay = Color3.fromRGB(180, 150, 120), Glare = 0.3, Haze = 1.2 })
	effect("BloomEffect", { Intensity = 0.35, Size = 28, Threshold = 0.92 })
	effect("ColorCorrectionEffect", { Brightness = 0.02, Contrast = 0.08, Saturation = 0.18, TintColor = Color3.fromRGB(255, 248, 238) })
	effect("SunRaysEffect", { Intensity = 0.05, Spread = 0.6 })
end
if Config.SETUP_LIGHTING then
	setupLighting()
end

-- Customer templates for the Brew Station queue: clients clone and animate them locally (no network traffic).
do
	local ItemModels = require(Services:WaitForChild("ItemModels"))
	local templates = Instance.new("Folder")
	templates.Name = "CustomerTemplates"
	for variant = 1, 6 do
		local model = ItemModels.BuildDecor("Customer", CFrame.new(), variant)
		if model then
			model.Name = "Customer" .. variant
			model.WorldPivot = CFrame.new() -- pivot at the feet, facing -Z
			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored = true
					part.CanCollide = false
					part.CanQuery = false
					part.CanTouch = false
					part:SetAttribute("T0", part.Transparency)
				end
			end
			model.Parent = templates
		end
	end
	templates.Parent = ReplicatedStorage
end

DataService.Init()
PlotService.Init(MonetizationService, notifyRemote)
MonetizationService.Init(DataService, PlotService)
RetentionService.Init(DataService, PlotService, actionRemote)
LeaderboardService.Init(DataService)

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
	if PlotService.AddPlayer(player, data) then
		RetentionService.AddPlayer(player)
	end
end

local function onPlayerRemoving(player: Player)
	PlotService.RemovePlayer(player)
	LeaderboardService.RemovePlayer(player)
	DataService.Release(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end
