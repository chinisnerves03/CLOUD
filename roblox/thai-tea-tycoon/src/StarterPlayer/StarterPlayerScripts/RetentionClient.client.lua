-- RetentionClient: DAILY button, Codes window, quest panel and the Rebirth button + confirm dialog.
-- Reads the player Attributes set by RetentionService (DailyAt, DailyStreak, Quest*, Rebirths, Level) and sends
-- requests through ReplicatedStorage.TycoonAction. Display only: the server checks everything.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local actionRemote = ReplicatedStorage:WaitForChild("TycoonAction") :: RemoteEvent

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BROWN = Color3.fromRGB(40, 25, 15)
local GREEN = Color3.fromRGB(46, 204, 113)
local GREY = Color3.fromRGB(95, 85, 80)
local PURPLE = Color3.fromRGB(155, 89, 182)
local YELLOW = Color3.fromRGB(255, 214, 10)

local gui = Instance.new("ScreenGui")
gui.Name = "RetentionGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 4
gui.Parent = playerGui

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function button(props): TextButton
	local b = Instance.new("TextButton")
	b.Font = Enum.Font.GothamBlack
	b.TextColor3 = Color3.new(1, 1, 1)
	b.AutoButtonColor = true
	for k, v in props do
		if k ~= "Radius" then
			(b :: any)[k] = v
		end
	end
	b.Parent = props.Parent or gui
	corner(b, props.Radius or 10)
	return b
end

local function text(parent: Instance, props): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamBold
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextScaled = true
	for k, v in props do
		(l :: any)[k] = v
	end
	l.Parent = parent
	return l
end

local function send(action: string, arg: any?)
	actionRemote:FireServer(action, arg)
end

local function serverNow(): number
	return workspace:GetServerTimeNow()
end

---------------------------------------------------------------------------
-- DAILY button (above SHOP)
---------------------------------------------------------------------------
local dailyButton = button({
	Name = "DailyButton", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 0.5, -46),
	Size = UDim2.fromOffset(78, 46), BackgroundColor3 = GREY, TextSize = 14, Text = "DAILY",
})
dailyButton.Activated:Connect(function()
	send("ClaimDaily")
end)

---------------------------------------------------------------------------
-- Codes button (below Music) + window
---------------------------------------------------------------------------
local codesButton = button({
	Name = "CodesButton", Position = UDim2.new(0, 12, 0.5, 86), Size = UDim2.fromOffset(78, 30),
	BackgroundColor3 = BROWN, BackgroundTransparency = 0.25, Font = Enum.Font.GothamBold, TextSize = 14, Text = "Codes",
	Radius = 8,
})

local codesWindow = Instance.new("Frame")
codesWindow.Name = "CodesWindow"
codesWindow.AnchorPoint = Vector2.new(0.5, 0.5)
codesWindow.Position = UDim2.fromScale(0.5, 0.45)
codesWindow.Size = UDim2.fromOffset(320, 160)
codesWindow.BackgroundColor3 = BROWN
codesWindow.Visible = false
codesWindow.Parent = gui
corner(codesWindow, 14)
local codesStroke = Instance.new("UIStroke")
codesStroke.Color = Color3.fromRGB(230, 126, 34)
codesStroke.Thickness = 3
codesStroke.Parent = codesWindow
text(codesWindow, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -70, 0, 30), TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = YELLOW, Font = Enum.Font.GothamBlack, Text = "Enter a code" })
local codesClose = button({ Parent = codesWindow, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10),
	Size = UDim2.fromOffset(32, 32), BackgroundColor3 = Color3.fromRGB(231, 76, 60), TextSize = 18, Text = "X", Radius = 8 })
local codeBox = Instance.new("TextBox")
codeBox.Position = UDim2.fromOffset(16, 54)
codeBox.Size = UDim2.new(1, -32, 0, 40)
codeBox.BackgroundColor3 = Color3.fromRGB(245, 235, 220)
codeBox.TextColor3 = Color3.fromRGB(40, 25, 15)
codeBox.PlaceholderText = "Type a code..."
codeBox.PlaceholderColor3 = Color3.fromRGB(140, 120, 100)
codeBox.Font = Enum.Font.GothamBold
codeBox.TextSize = 20
codeBox.Text = ""
codeBox.ClearTextOnFocus = false
codeBox.Parent = codesWindow
corner(codeBox, 8)
local redeemButton = button({ Parent = codesWindow, Position = UDim2.fromOffset(16, 104), Size = UDim2.new(1, -32, 0, 40),
	BackgroundColor3 = GREEN, TextSize = 18, Text = "Redeem", Radius = 8 })

local function redeem()
	local code = codeBox.Text:gsub("%s", "")
	if code ~= "" then
		send("Redeem", code)
		codeBox.Text = ""
		codesWindow.Visible = false
	end
end
codesButton.Activated:Connect(function()
	codesWindow.Visible = not codesWindow.Visible
end)
codesClose.Activated:Connect(function()
	codesWindow.Visible = false
end)
redeemButton.Activated:Connect(redeem)
codeBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		redeem()
	end
end)

---------------------------------------------------------------------------
-- Quest panel (under the cash panel, right edge)
---------------------------------------------------------------------------
local quest = Instance.new("Frame")
quest.Name = "QuestPanel"
quest.AnchorPoint = Vector2.new(1, 0)
quest.Position = UDim2.new(1, -12, 0.5, 6)
quest.Size = UDim2.fromOffset(250, 62)
quest.BackgroundColor3 = BROWN
quest.BackgroundTransparency = 0.25
quest.Parent = gui
corner(quest, 8)
local questTitle = text(quest, { Position = UDim2.fromOffset(10, 5), Size = UDim2.new(1, -20, 0, 20),
	TextXAlignment = Enum.TextXAlignment.Left, Text = "Quest" })
local barBack = Instance.new("Frame")
barBack.Position = UDim2.fromOffset(10, 29)
barBack.Size = UDim2.new(1, -20, 0, 10)
barBack.BackgroundColor3 = Color3.fromRGB(20, 12, 8)
barBack.Parent = quest
corner(barBack, 5)
local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = GREEN
barFill.Parent = barBack
corner(barFill, 5)
local questInfo = text(quest, { Position = UDim2.fromOffset(10, 42), Size = UDim2.new(1, -20, 0, 15),
	TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(220, 210, 200), Font = Enum.Font.Gotham, Text = "" })

---------------------------------------------------------------------------
-- Rebirth button + confirm dialog
---------------------------------------------------------------------------
local rebirthButton = button({
	Name = "RebirthButton", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24),
	Size = UDim2.fromOffset(280, 54), BackgroundColor3 = PURPLE, TextSize = 20, Text = "REBIRTH", Visible = false, Radius = 14,
})
local rebirthStroke = Instance.new("UIStroke")
rebirthStroke.Color = YELLOW
rebirthStroke.Thickness = 3
rebirthStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
rebirthStroke.Parent = rebirthButton

local confirm = Instance.new("Frame")
confirm.Name = "RebirthConfirm"
confirm.AnchorPoint = Vector2.new(0.5, 0.5)
confirm.Position = UDim2.fromScale(0.5, 0.5)
confirm.Size = UDim2.fromOffset(380, 210)
confirm.BackgroundColor3 = BROWN
confirm.Visible = false
confirm.Parent = gui
corner(confirm, 14)
local confirmStroke = rebirthStroke:Clone()
confirmStroke.Parent = confirm
text(confirm, { Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 0, 34), Font = Enum.Font.GothamBlack,
	TextColor3 = YELLOW, Text = "Rebirth?" })
local confirmBody = text(confirm, { Position = UDim2.fromOffset(20, 52), Size = UDim2.new(1, -40, 0, 86), Font = Enum.Font.Gotham,
	TextWrapped = true, Text = "" })
local yesButton = button({ Parent = confirm, Position = UDim2.new(0, 20, 1, -58), Size = UDim2.new(0.5, -26, 0, 42),
	BackgroundColor3 = PURPLE, TextSize = 18, Text = "Rebirth!" })
local noButton = button({ Parent = confirm, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 1, -58),
	Size = UDim2.new(0.5, -26, 0, 42), BackgroundColor3 = GREY, TextSize = 18, Text = "Not yet" })

local function multText(rebirths: number): string
	return "x" .. (string.format("%.1f", Config.RebirthMultiplier(rebirths)):gsub("%.0$", ""))
end

rebirthButton.Activated:Connect(function()
	local rebirths = tonumber(player:GetAttribute("Rebirths")) or 0
	confirmBody.Text = string.format(
		"Your shop goes back to level 1 with no cash or upgrades, but all income goes from %s to %s forever.",
		multText(rebirths), multText(rebirths + 1))
	confirm.Visible = true
end)
yesButton.Activated:Connect(function()
	confirm.Visible = false
	send("Rebirth")
end)
noButton.Activated:Connect(function()
	confirm.Visible = false
end)

-- slow glow on buttons that want attention
task.spawn(function()
	local info = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	TweenService:Create(rebirthStroke, info, { Thickness = 6 }):Play()
end)

---------------------------------------------------------------------------
-- Refresh from attributes
---------------------------------------------------------------------------
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.25 then
		return
	end
	elapsed = 0

	local ready = player:GetAttribute("DailyAt")
	if type(ready) == "number" then
		local left = ready - serverNow()
		if left <= 0 then
			dailyButton.Text = "DAILY!\nDay " .. tostring(player:GetAttribute("DailyStreak") or 1)
			dailyButton.BackgroundColor3 = GREEN
		else
			dailyButton.Text = "Daily\n" .. Config.FormatTime(left)
			dailyButton.BackgroundColor3 = GREY
		end
	end

	local target = tonumber(player:GetAttribute("QuestTarget")) or 0
	quest.Visible = target > 0
	if target > 0 then
		local progress = tonumber(player:GetAttribute("QuestProgress")) or 0
		local questName = tostring(player:GetAttribute("QuestText") or "")
		questTitle.Text = "Quest: " .. questName
		barFill.Size = UDim2.fromScale(math.clamp(progress / target, 0, 1), 1)
		local shown = if questName:match("^Earn") then Config.FormatMoney(progress) .. " / " .. Config.FormatMoney(target)
			else string.format("%d / %d", progress, target)
		questInfo.Text = shown .. "  ·  Reward " .. Config.FormatMoney(tonumber(player:GetAttribute("QuestReward")) or 0)
	end

	local level = tonumber(player:GetAttribute("Level")) or 1
	local canRebirth = level >= Config.REBIRTH.MIN_LEVEL
	rebirthButton.Visible = canRebirth
	if canRebirth then
		rebirthButton.Text = "REBIRTH → " .. multText((tonumber(player:GetAttribute("Rebirths")) or 0) + 1) .. " income"
	else
		confirm.Visible = false
	end
end)
