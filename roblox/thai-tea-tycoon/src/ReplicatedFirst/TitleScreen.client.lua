-- TitleScreen: the first thing a player sees. Replaces Roblox's loading screen with a Thai-tea themed one, then
-- shows the title menu (PLAY, HOW TO PLAY) over a slow camera flight around the player's own shop.
-- While it is up, the other HUDs and the Roblox top bar are hidden and the character stands still; PLAY hands
-- everything back and puts the camera behind the character, facing the shop.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TEA = Color3.fromRGB(233, 124, 38)
local BROWN = Color3.fromRGB(52, 32, 20)
local CREAM = Color3.fromRGB(255, 244, 222)
local YELLOW = Color3.fromRGB(255, 212, 40)
local TITLE_FONT = Enum.Font.FredokaOne

---------------------------------------------------------------------------
-- Screen (built right away, before the game has loaded)
---------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "TitleScreen"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local shade = Instance.new("Frame")
shade.Name = "Shade"
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = BROWN
shade.BorderSizePixel = 0
shade.Parent = gui
local shadeGradient = Instance.new("UIGradient")
shadeGradient.Color = ColorSequence.new(Color3.fromRGB(120, 55, 18), BROWN)
shadeGradient.Rotation = 90
shadeGradient.Parent = shade

local function label(parent: Instance, props): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = TITLE_FONT
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextScaled = true
	for k, v in props do
		(l :: any)[k] = v
	end
	l.Parent = parent
	return l
end

-- logo: a bobbing cup over the name
local cup = label(gui, {
	Name = "Cup", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.17),
	Size = UDim2.fromScale(0.12, 0.13), Text = "🥤",
})
local title = label(gui, {
	Name = "Title", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.25),
	Size = UDim2.fromScale(0.85, 0.17), Text = "THAI TEA TYCOON", TextColor3 = YELLOW,
})
local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(120, 50, 10)
titleStroke.Thickness = 4
titleStroke.Parent = title
local subtitle = label(gui, {
	Name = "Subtitle", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.43),
	Size = UDim2.fromScale(0.6, 0.045), Text = "Brew, build and grow the biggest Thai tea empire!", TextColor3 = CREAM,
})
for _, l in { title, subtitle } do
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = if l == title then 150 else 34
	limit.Parent = l
end

-- loading bar
local barBack = Instance.new("Frame")
barBack.Name = "LoadingBar"
barBack.AnchorPoint = Vector2.new(0.5, 1)
barBack.Position = UDim2.new(0.5, 0, 1, -60)
barBack.Size = UDim2.new(0.4, 0, 0, 14)
barBack.BackgroundColor3 = Color3.fromRGB(30, 18, 10)
barBack.BorderSizePixel = 0
barBack.Parent = gui
Instance.new("UICorner", barBack).CornerRadius = UDim.new(1, 0)
local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0.05, 1)
barFill.BackgroundColor3 = TEA
barFill.BorderSizePixel = 0
barFill.Parent = barBack
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
local status = label(gui, {
	Name = "Status", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -80),
	Size = UDim2.new(0.5, 0, 0, 24), Font = Enum.Font.GothamBold, TextColor3 = CREAM, Text = "Brewing the tea...",
})
label(gui, {
	Name = "Version", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -14, 1, -10),
	Size = UDim2.new(0, 160, 0, 18), Font = Enum.Font.GothamBold, TextColor3 = CREAM, TextTransparency = 0.4,
	TextXAlignment = Enum.TextXAlignment.Right, Text = "v1.0",
})

gui.Parent = playerGui

local function setProgress(fraction: number, text: string)
	status.Text = text
	TweenService:Create(barFill, TweenInfo.new(0.35), { Size = UDim2.fromScale(math.clamp(fraction, 0.05, 1), 1) }):Play()
end

-- the cup bobs and tilts while we wait
local clock = 0
local bobConnection = RunService.RenderStepped:Connect(function(dt)
	clock += dt
	cup.Position = UDim2.fromScale(0.5, 0.17 + math.sin(clock * 2) * 0.01)
	cup.Rotation = math.sin(clock * 1.3) * 8
end)

---------------------------------------------------------------------------
-- Hide the rest of the UI and hold the character still while the menu is up
---------------------------------------------------------------------------
local hidden: { LayerCollector } = {}
local inMenu = true
player:SetAttribute("InMenu", true) -- ClientMain keeps the guide arrow off while this is set

local function hide(child: Instance)
	-- ScreenGuis (HUD, shop) and BillboardGuis in PlayerGui (the guide arrow)
	if inMenu and child:IsA("LayerCollector") and child ~= gui and child.Enabled then
		child.Enabled = false
		table.insert(hidden, child)
	end
end
for _, child in playerGui:GetChildren() do
	hide(child)
end
local guiWatcher = playerGui.ChildAdded:Connect(hide)

local function setCoreGui(enabled: boolean)
	for _ = 1, 20 do
		local ok = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.All, enabled)
		if ok then
			return
		end
		task.wait(0.25)
	end
end
task.spawn(setCoreGui, false)

local blur = Instance.new("BlurEffect")
blur.Name = "TitleBlur"
blur.Size = 14
blur.Parent = Lighting

local function holdCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if humanoid and inMenu then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end
end
if player.Character then
	task.spawn(holdCharacter, player.Character)
end
local charWatcher = player.CharacterAdded:Connect(holdCharacter)

---------------------------------------------------------------------------
-- Loading
---------------------------------------------------------------------------
setProgress(0.2, "Brewing the tea...")
if not game:IsLoaded() then
	game.Loaded:Wait()
end
setProgress(0.55, "Opening the shop...")
local UIStyle = require(ReplicatedStorage:WaitForChild("UIStyle"))

-- wait for the server to give us a plot (the shop is ready once "Plot" is set)
local waited = 0
while not player:GetAttribute("Plot") and waited < 45 do
	waited += task.wait(0.25)
	setProgress(0.55 + math.min(waited / 30, 0.4), "Setting up your Thai tea shop...")
end
setProgress(1, "Ready!")

---------------------------------------------------------------------------
-- Camera flight around the player's shop
---------------------------------------------------------------------------
local camera = workspace.CurrentCamera
local function shopCentre(): Vector3
	local plots = workspace:FindFirstChild("Plots")
	local plot = plots and plots:FindFirstChild(tostring(player:GetAttribute("Plot")))
	local base = plot and plot:FindFirstChild("Base")
	return if base and base:IsA("BasePart") then base.Position else Vector3.zero
end
local centre = shopCentre()
camera.CameraType = Enum.CameraType.Scriptable
local flight = RunService.RenderStepped:Connect(function()
	local angle = clock * 0.08
	local eye = centre + Vector3.new(math.cos(angle) * 150, 75, math.sin(angle) * 150)
	camera.CFrame = CFrame.lookAt(eye, centre + Vector3.new(0, 10, 0))
end)

---------------------------------------------------------------------------
-- Menu
---------------------------------------------------------------------------
TweenService:Create(shade, TweenInfo.new(0.8), { BackgroundTransparency = 0.55 }):Play()
TweenService:Create(barBack, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
TweenService:Create(barFill, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
status.Text = ""

local playButton = UIStyle.button(gui, "▶  PLAY", UIStyle.Colors.Green, UDim2.new(0, 340, 0, 90), UDim2.fromScale(0.5, 0.58), Vector2.new(0.5, 0.5))
local helpButton = UIStyle.button(gui, "❓ HOW TO PLAY", UIStyle.Colors.Tea, UDim2.new(0, 260, 0, 58), UDim2.fromScale(0.5, 0.58), Vector2.new(0.5, 0))
helpButton.Position = UDim2.new(0.5, 0, 0.58, 64)

-- PLAY's outline gently pulses (its UIScale belongs to the hover effect)
local playStroke = playButton:FindFirstChildOfClass("UIStroke")
if playStroke then
	playStroke.Transparency = 0
	TweenService:Create(playStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Thickness = 6 }):Play()
end

-- how to play card
local help = Instance.new("Frame")
help.Name = "HowToPlay"
help.AnchorPoint = Vector2.new(0.5, 0.5)
help.Position = UDim2.fromScale(0.5, 0.52)
help.Size = UDim2.new(0, 560, 0, 400)
help.Visible = false
help.ZIndex = 5
help.Parent = gui
UIStyle.panel(help)
help.BackgroundTransparency = 0.02
local helpSize = Instance.new("UISizeConstraint")
helpSize.MaxSize = Vector2.new(560, 420)
helpSize.Parent = help
local fit = Instance.new("UIScale")
fit.Parent = help
label(help, { Position = UDim2.fromOffset(20, 12), Size = UDim2.new(1, -90, 0, 44), TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = YELLOW, Text = "How to play", ZIndex = 6 })
local steps = {
	{ "🥤", "Your shop sells tea by itself. Stand on the orange mat behind the counter and press E to brew faster." },
	{ "🟩", "Step on the green pad to build the next item. Grow from a street cart into a Thai tea empire." },
	{ "⬆️", "Blue, orange and purple pads hire staff, improve your recipe and speed up service." },
	{ "🎁", "Claim your DAILY reward, finish quests, and REBIRTH at level 45 for bigger income forever." },
}
for i, step in steps do
	local y = 64 + (i - 1) * 80
	label(help, { Position = UDim2.fromOffset(20, y), Size = UDim2.fromOffset(56, 56), Text = step[1], ZIndex = 6 })
	label(help, { Position = UDim2.fromOffset(88, y), Size = UDim2.new(1, -108, 0, 64), Font = Enum.Font.GothamBold,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = CREAM, Text = step[2], ZIndex = 6 })
end
local closeHelp = UIStyle.button(help, "X", UIStyle.Colors.Red, UDim2.fromOffset(44, 44), UDim2.new(1, -12, 0, 12), Vector2.new(1, 0))
closeHelp.ZIndex = 6

local function fitHelp()
	local height = camera.ViewportSize.Y
	fit.Scale = math.clamp(height / 520, 0.55, 1)
end
fitHelp()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitHelp)

-- the card replaces the menu while it is open
local function showHelp(open: boolean)
	help.Visible = open
	playButton.Visible = not open
	helpButton.Visible = not open
	subtitle.Visible = not open
end
helpButton.Activated:Connect(function()
	showHelp(true)
end)
closeHelp.Activated:Connect(function()
	showHelp(false)
end)

local started = false
playButton.Activated:Connect(function()
	if started then
		return
	end
	started = true
	inMenu = false
	player:SetAttribute("InMenu", false)
	guiWatcher:Disconnect()
	charWatcher:Disconnect()
	flight:Disconnect()

	-- fade out the menu, bring the game back
	for _, d in gui:GetDescendants() do
		if d:IsA("TextLabel") or d:IsA("TextButton") then
			TweenService:Create(d, TweenInfo.new(0.35), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
		if d:IsA("GuiObject") and d.BackgroundTransparency < 1 then
			TweenService:Create(d, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
		end
		if d:IsA("UIStroke") then
			TweenService:Create(d, TweenInfo.new(0.35), { Transparency = 1 }):Play()
		end
	end
	TweenService:Create(shade, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(blur, TweenInfo.new(0.5), { Size = 0 }):Play()

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end
	camera.CameraType = Enum.CameraType.Custom
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		local look = root.CFrame.LookVector
		camera.CFrame = CFrame.lookAt(root.Position - look * 14 + Vector3.new(0, 6, 0), root.Position + look * 20)
	end
	for _, other in hidden do
		other.Enabled = true
	end
	task.spawn(setCoreGui, true)

	task.wait(0.6)
	bobConnection:Disconnect()
	blur:Destroy()
	gui:Destroy()
end)
