-- ClientMain: cash HUD + guidance text + guide arrow + notifications/sounds
-- Reads the Attributes set by the server (Cash, Level, Income, BrewValue, Plot) — display only

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local notifyRemote = ReplicatedStorage:WaitForChild("TycoonNotify") :: RemoteEvent

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local YELLOW = Color3.fromRGB(255, 214, 10)

---------------------------------------------------------------------------
-- Build the UI
---------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "TycoonHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local function makeLabel(parent: Instance, props): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	for k, v in props do
		(label :: any)[k] = v
	end
	label.Parent = parent
	return label
end

-- cash panel, top right
local panel = Instance.new("Frame")
panel.Name = "MoneyPanel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -12, 0, 12)
panel.Size = UDim2.fromOffset(230, 96)
panel.BackgroundColor3 = Color3.fromRGB(40, 25, 15)
panel.BackgroundTransparency = 0.25
panel.Parent = gui
Instance.new("UICorner").Parent = panel
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)
padding.Parent = panel

local cashLabel = makeLabel(panel, {
	Name = "Cash", Size = UDim2.new(1, 0, 0, 40), TextColor3 = YELLOW,
	TextXAlignment = Enum.TextXAlignment.Right, Font = Enum.Font.GothamBlack, Text = "฿0",
})
local incomeLabel = makeLabel(panel, {
	Name = "Income", Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 0, 20),
	TextXAlignment = Enum.TextXAlignment.Right, Text = "+฿3/cup",
})
local levelLabel = makeLabel(panel, {
	Name = "Level", Position = UDim2.fromOffset(0, 64), Size = UDim2.new(1, 0, 0, 20),
	TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(200, 200, 200), Text = "Level 1/45",
})

-- guidance text, top center
local hintLabel = makeLabel(gui, {
	Name = "Hint", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 12),
	Size = UDim2.new(0.5, 0, 0, 34), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45,
	Text = "Setting up your shop...",
})
Instance.new("UICorner").Parent = hintLabel
local hintSizeLimit = Instance.new("UITextSizeConstraint")
hintSizeLimit.MaxTextSize = 24
hintSizeLimit.Parent = hintLabel

-- stacked notifications, center
local toastList = Instance.new("Frame")
toastList.Name = "Toasts"
toastList.AnchorPoint = Vector2.new(0.5, 0)
toastList.Position = UDim2.new(0.5, 0, 0, 56)
toastList.Size = UDim2.new(0.6, 0, 0, 200)
toastList.BackgroundTransparency = 1
toastList.Parent = gui
local layout = Instance.new("UIListLayout")
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = toastList

local TOAST_COLORS = {
	Buy = Color3.fromRGB(46, 204, 113),
	Collect = YELLOW,
	Error = Color3.fromRGB(231, 76, 60),
	Offline = Color3.fromRGB(52, 152, 219),
}
local toastOrder = 0

local function showToast(kind: string, text: string)
	toastOrder += 1
	local duration = if kind == "Offline" then 8 else 2.5
	local toast = makeLabel(toastList, {
		Name = "Toast", LayoutOrder = toastOrder, Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35,
		TextColor3 = TOAST_COLORS[kind] or Color3.new(1, 1, 1), Text = text,
	})
	Instance.new("UICorner").Parent = toast
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 22
	limit.Parent = toast

	-- keep at most 4
	local toasts = {}
	for _, child in toastList:GetChildren() do
		if child:IsA("TextLabel") then
			table.insert(toasts, child)
		end
	end
	table.sort(toasts, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	for i = 1, #toasts - 4 do
		toasts[i]:Destroy()
	end

	task.delay(duration, function()
		if toast.Parent then
			local fade = TweenInfo.new(0.4)
			TweenService:Create(toast, fade, { TextTransparency = 1, BackgroundTransparency = 1, TextStrokeTransparency = 1 }):Play()
			task.wait(0.4)
			toast:Destroy()
		end
	end)
end

local SOUND_FOR_KIND = { Buy = "Buy", Collect = "Collect", Error = "Error", Brew = "Brew" }

local function playSound(kind: string)
	local soundKey = SOUND_FOR_KIND[kind]
	local id = soundKey and Config.SOUNDS[soundKey]
	if id and id ~= "" then
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = 0.6
		sound.Parent = SoundService
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		sound:Play()
	end
end

-- small "+฿x" that floats up next to the cash panel on every brew (brews are too frequent for toasts)
local function showBrewPop(text: string)
	local pop = makeLabel(gui, {
		Name = "BrewPop", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -250, 0, 70),
		Size = UDim2.fromOffset(90, 24), TextColor3 = YELLOW, Text = text,
	})
	TweenService:Create(pop, TweenInfo.new(0.7), { Position = UDim2.new(1, -250, 0, 40), TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(0.75, pop.Destroy, pop)
end

notifyRemote.OnClientEvent:Connect(function(kind: string, text: string)
	if kind == "Brew" then
		showBrewPop(text)
	else
		showToast(kind, text)
	end
	playSound(kind)
end)

---------------------------------------------------------------------------
-- Guide: yellow arrow above the target + a beam from the character to it
---------------------------------------------------------------------------
local arrowGui = Instance.new("BillboardGui")
arrowGui.Name = "GuideArrow"
arrowGui.Size = UDim2.fromOffset(60, 60)
arrowGui.AlwaysOnTop = true
arrowGui.StudsOffset = Vector3.new(0, 5, 0)
arrowGui.Enabled = false
arrowGui.Parent = playerGui
makeLabel(arrowGui, {
	Size = UDim2.fromScale(1, 1), Text = "▼", TextColor3 = YELLOW, TextStrokeTransparency = 0,
})

local targetAttachment = Instance.new("Attachment")
targetAttachment.Name = "GuideTarget"

local beam = Instance.new("Beam")
beam.Name = "GuideBeam"
beam.Color = ColorSequence.new(YELLOW)
beam.Transparency = NumberSequence.new(0.35)
beam.Width0 = 0.5
beam.Width1 = 0.5
beam.FaceCamera = true
beam.LightEmission = 0.5
beam.Attachment1 = targetAttachment
beam.Enabled = false

local function setTarget(part: BasePart?)
	if not part then
		arrowGui.Enabled = false
		beam.Enabled = false
		return
	end
	arrowGui.Adornee = part
	arrowGui.Enabled = true
	if targetAttachment.Parent ~= part then
		targetAttachment.Parent = part
		targetAttachment.Position = Vector3.new(0, part.Size.Y / 2 + 0.2, 0)
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		local rootAttachment = root:FindFirstChild("GuideSource") :: Attachment?
		if not rootAttachment then
			rootAttachment = Instance.new("Attachment")
			rootAttachment.Name = "GuideSource"
			rootAttachment.Position = Vector3.new(0, -2, 0)
			rootAttachment.Parent = root
		end
		beam.Attachment0 = rootAttachment
		-- keep the Beam under the camera, not the character (characters are destroyed on death)
		if beam.Parent ~= workspace.CurrentCamera then
			beam.Parent = workspace.CurrentCamera
		end
		-- hide the beam once close to the target
		beam.Enabled = ((root :: BasePart).Position - part.Position).Magnitude > 8
	else
		beam.Enabled = false
	end
end

---------------------------------------------------------------------------
-- Per-frame update
---------------------------------------------------------------------------
local function getNumber(name: string): number
	return tonumber(player:GetAttribute(name)) or 0
end

local function getPlot(): Model?
	local plotName = player:GetAttribute("Plot")
	local plots = workspace:FindFirstChild("Plots")
	if type(plotName) ~= "string" or not plots then
		return nil
	end
	return plots:FindFirstChild(plotName) :: Model?
end

local bob = 0

RunService.RenderStepped:Connect(function(dt)
	bob += dt
	arrowGui.StudsOffset = Vector3.new(0, 5 + math.sin(bob * 4) * 0.6, 0)

	local cash = getNumber("Cash")
	local level = math.max(1, getNumber("Level"))
	local income = getNumber("Income")
	local perCup = getNumber("BrewValue")

	cashLabel.Text = Config.FormatMoney(cash)
	incomeLabel.Text = "+" .. Config.FormatMoney(perCup) .. "/cup · +" .. Config.FormatRate(income) .. "/s"
	levelLabel.Text = string.format("Level %d/%d", level, Config.MAX_LEVEL)

	local plot = getPlot()
	if not plot then
		hintLabel.Text = "Setting up your shop..."
		setTarget(nil)
		return
	end

	local nextItem = Config.GetItem(level + 1)
	local padSlots = plot:FindFirstChild("PadSlots")
	local pad = padSlots and padSlots:FindFirstChild("Pad1") :: BasePart?
	local station = plot:FindFirstChild("BrewStation")
	local kettle = station and station:FindFirstChild("Kettle", true) :: BasePart?

	if not nextItem then
		hintLabel.Text = "Your Thai tea empire is complete!"
		setTarget(nil)
	elseif cash >= nextItem.Price then
		hintLabel.Text = string.format("Step on the green pad to buy %s (%s)", nextItem.Name, Config.FormatMoney(nextItem.Price))
		setTarget(pad)
	else
		local missing = nextItem.Price - cash
		hintLabel.Text = string.format("Brew tea at the Brew Station (press E) — %s more for %s",
			Config.FormatMoney(math.ceil(missing)), nextItem.Name)
		setTarget(kettle)
	end
end)
