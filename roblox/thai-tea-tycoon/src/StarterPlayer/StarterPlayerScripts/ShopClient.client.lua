-- ShopClient: the in-game shop. A SHOP button on the left opens a window with the 4 Game Passes and 2 Cash Boost
-- products from Config. Buying only opens Roblox's purchase prompt; MonetizationService grants everything on the server.
-- Pass ownership comes from the player's Pass_* attributes, so a card flips to "Owned" as soon as the server grants it.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local player = Players.LocalPlayer

-- the left button column (DAILY, SHOP, Music, Codes) sits a little higher on touch screens so it clears the
-- on-screen thumbstick in the bottom-left corner (ShopClient and RetentionClient use the same offset)
local UserInputService = game:GetService("UserInputService")
local COLUMN_Y = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then -70 else 0
local playerGui = player:WaitForChild("PlayerGui")

local BROWN = Color3.fromRGB(40, 25, 15)
local CARD = Color3.fromRGB(62, 42, 28)
local ORANGE = Color3.fromRGB(230, 126, 34)
local GREEN = Color3.fromRGB(46, 204, 113)
local GREY = Color3.fromRGB(110, 110, 110)
local YELLOW = Color3.fromRGB(255, 214, 10)

local gui = Instance.new("ScreenGui")
gui.Name = "ShopGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.Parent = playerGui

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function stroke(parent: Instance, color: Color3, thickness: number)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
end

local function text(parent: Instance, props): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	for k, v in props do
		(label :: any)[k] = v
	end
	label.Parent = parent
	return label
end

---------------------------------------------------------------------------
-- Shop button (left edge, middle)
---------------------------------------------------------------------------
local UIStyle = require(ReplicatedStorage:WaitForChild("UIStyle"))

local shopButton = UIStyle.button(gui, "🛒 SHOP", UIStyle.Colors.Tea, UDim2.fromOffset(78, 78), UDim2.new(0, 12, 0.5, COLUMN_Y), Vector2.new(0, 0.5))
shopButton.Name = "ShopButton"

-- styled buttons click on their own (UIStyle); the shop cards below use this
local function click()
	UIStyle.click()
end

---------------------------------------------------------------------------
-- Settings (music / sound effects) and Home
---------------------------------------------------------------------------
local settingsButton = UIStyle.button(gui, "⚙️ Settings", UIStyle.Colors.Grey, UDim2.fromOffset(78, 30), UDim2.new(0, 12, 0.5, COLUMN_Y + 50))
settingsButton.Name = "SettingsButton"
local homeButton = UIStyle.button(gui, "🏠 Home", UIStyle.Colors.Blue, UDim2.fromOffset(78, 30), UDim2.new(0, 12, 0.5, COLUMN_Y + 122))
homeButton.Name = "HomeButton"

local settings = Instance.new("Frame")
settings.Name = "SettingsWindow"
settings.AnchorPoint = Vector2.new(0.5, 0.5)
settings.Position = UDim2.fromScale(0.5, 0.45)
settings.Size = UDim2.fromOffset(320, 210)
settings.Visible = false
settings.Parent = gui
UIStyle.panel(settings)
local settingsTitle = Instance.new("TextLabel")
settingsTitle.BackgroundTransparency = 1
settingsTitle.Position = UDim2.fromOffset(18, 10)
settingsTitle.Size = UDim2.new(1, -80, 0, 36)
settingsTitle.Font = UIStyle.Font
settingsTitle.TextScaled = true
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.TextColor3 = UIStyle.Colors.Yellow
settingsTitle.Text = "Settings"
settingsTitle.Parent = settings
local closeSettings = UIStyle.button(settings, "X", UIStyle.Colors.Red, UDim2.fromOffset(38, 38), UDim2.new(1, -12, 0, 10), Vector2.new(1, 0))

-- a toggle row: label on the left, ON/OFF button on the right; state lives in a SoundService attribute
local function toggleRow(y: number, text: string, attribute: string, apply: (boolean) -> ())
	local rowLabel = settingsTitle:Clone()
	rowLabel.Position = UDim2.fromOffset(18, y)
	rowLabel.Size = UDim2.new(1, -150, 0, 30)
	rowLabel.Font = UIStyle.BodyFont
	rowLabel.TextScaled = false
	rowLabel.TextSize = 22
	rowLabel.TextColor3 = UIStyle.Colors.Cream
	rowLabel.Text = text
	rowLabel.Parent = settings
	local toggle = UIStyle.button(settings, "ON", UIStyle.Colors.Green, UDim2.fromOffset(100, 40), UDim2.new(1, -18, 0, y - 5), Vector2.new(1, 0))
	local function refresh()
		local muted = SoundService:GetAttribute(attribute) == true
		toggle.Text = if muted then "OFF" else "ON"
		toggle.BackgroundColor3 = if muted then UIStyle.Colors.Grey else UIStyle.Colors.Green
		apply(not muted)
	end
	toggle.Activated:Connect(function()
		SoundService:SetAttribute(attribute, SoundService:GetAttribute(attribute) ~= true)
		refresh()
	end)
	refresh()
end

toggleRow(70, "🎵 Music", "MusicMuted", function(on: boolean)
	local music = SoundService:FindFirstChild("BackgroundMusic") :: Sound?
	if music then
		music.Volume = if on then Config.MUSIC_VOLUME else 0
	end
end)
toggleRow(130, "🔊 Sound effects", "SfxMuted", function() end)

settingsButton.Activated:Connect(function()
	settings.Visible = not settings.Visible
end)
closeSettings.Activated:Connect(function()
	settings.Visible = false
end)

-- Home: back to the entrance of your own shop, facing in (the character is client-owned, so this replicates)
homeButton.Activated:Connect(function()
	local plots = workspace:FindFirstChild("Plots")
	local plot = plots and plots:FindFirstChild(tostring(player:GetAttribute("Plot")))
	local base = plot and plot:FindFirstChild("Base")
	local character = player.Character
	if not (base and base:IsA("BasePart") and character) then
		return
	end
	local spot = base.CFrame * CFrame.new(0, base.Size.Y / 2 + 3.5, -base.Size.Z / 2 - 7)
	local inward = -base.CFrame.LookVector
	character:PivotTo(CFrame.lookAt(spot.Position, spot.Position + inward))
	local camera = workspace.CurrentCamera
	if camera then
		camera.CFrame = CFrame.lookAt(spot.Position - inward * 14 + Vector3.new(0, 6, 0), spot.Position + inward * 20)
	end
end)

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------
local window = Instance.new("Frame")
window.Name = "ShopWindow"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.fromScale(0.92, 0.82)
window.BackgroundColor3 = BROWN
window.BackgroundTransparency = 0.05
window.Visible = false
window.Parent = gui
corner(window, 18)
stroke(window, ORANGE, 3)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(720, 520)
limit.Parent = window
local windowScale = Instance.new("UIScale")
windowScale.Parent = window

text(window, {
	Name = "Title", Position = UDim2.fromOffset(20, 10), Size = UDim2.new(1, -90, 0, 40),
	Font = UIStyle.Font, TextColor3 = YELLOW, TextXAlignment = Enum.TextXAlignment.Left, Text = "🛒 Thai Tea Shop",
})

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -12, 0, 10)
closeButton.Size = UDim2.fromOffset(40, 40)
closeButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
closeButton.Font = Enum.Font.GothamBlack
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 22
closeButton.Parent = window
corner(closeButton, 10)

local list = Instance.new("ScrollingFrame")
list.Name = "List"
list.Position = UDim2.fromOffset(12, 58)
list.Size = UDim2.new(1, -24, 1, -70)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = window
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = list

local function section(title: string, order: number): Frame
	text(list, {
		Name = title .. "Header", LayoutOrder = order, Size = UDim2.new(1, 0, 0, 26),
		TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(255, 200, 140), Text = title,
	})
	local grid = Instance.new("Frame")
	grid.Name = title .. "Grid"
	grid.LayoutOrder = order + 1
	grid.BackgroundTransparency = 1
	grid.Size = UDim2.new(1, 0, 0, 0)
	grid.AutomaticSize = Enum.AutomaticSize.Y
	grid.Parent = list
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(160, 200)
	layout.CellPadding = UDim2.fromOffset(10, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grid
	return grid
end

type Card = { Button: TextButton, Extra: TextLabel?, Kind: string, Key: string, Price: number? }
local cards: { Card } = {}

local function makeCard(grid: Frame, order: number, kind: string, key: string, info): Card
	local card = Instance.new("Frame")
	card.Name = key
	card.LayoutOrder = order
	card.BackgroundColor3 = CARD
	card.Parent = grid
	corner(card, 14)
	stroke(card, info.Color, 2)

	-- icon: the uploaded image if set, otherwise a colored badge with short text
	if info.Icon ~= "" then
		local image = Instance.new("ImageLabel")
		image.AnchorPoint = Vector2.new(0.5, 0)
		image.Position = UDim2.new(0.5, 0, 0, 10)
		image.Size = UDim2.fromOffset(64, 64)
		image.BackgroundTransparency = 1
		image.Image = info.Icon
		image.Parent = card
	else
		local badge = text(card, {
			AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(64, 64),
			BackgroundTransparency = 0, BackgroundColor3 = info.Color, Font = Enum.Font.GothamBlack, Text = info.Badge,
		})
		corner(badge, 32)
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
		pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 14), UDim.new(0, 14)
		pad.Parent = badge
	end

	text(card, { Position = UDim2.fromOffset(8, 78), Size = UDim2.new(1, -16, 0, 20), Text = info.Name })
	local desc = text(card, {
		Position = UDim2.fromOffset(8, 100), Size = UDim2.new(1, -16, 0, 44), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(220, 210, 200), TextWrapped = true, Text = info.Desc,
	})
	local descLimit = Instance.new("UITextSizeConstraint")
	descLimit.MaxTextSize = 13
	descLimit.Parent = desc

	local extra: TextLabel? = nil
	if kind == "Product" then
		extra = text(card, { Position = UDim2.fromOffset(8, 144), Size = UDim2.new(1, -16, 0, 14), TextColor3 = YELLOW, Text = "" })
	end

	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(0.5, 1)
	button.Position = UDim2.new(0.5, 0, 1, -8)
	button.Size = UDim2.new(1, -16, 0, 32)
	button.BackgroundColor3 = GREY
	button.Font = Enum.Font.GothamBlack
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 16
	button.Text = "..."
	button.Parent = card
	corner(button, 8)

	local entry: Card = { Button = button, Extra = extra, Kind = kind, Key = key, Price = nil }
	button.Activated:Connect(function()
		click()
		if info.Id == 0 then
			return
		end
		if kind == "Pass" then
			if player:GetAttribute("Pass_" .. key) ~= true then
				MarketplaceService:PromptGamePassPurchase(player, info.Id)
			end
		else
			MarketplaceService:PromptProductPurchase(player, info.Id)
		end
	end)
	table.insert(cards, entry)
	return entry
end

local passGrid = section("Game Passes", 1)
for i, key in Config.PASS_ORDER do
	makeCard(passGrid, i, "Pass", key, Config.PASSES[key])
end
local productGrid = section("Cash Boosts", 10)
for i, key in Config.PRODUCT_ORDER do
	makeCard(productGrid, i, "Product", key, Config.PRODUCTS[key])
end

---------------------------------------------------------------------------
-- Prices (fetched once from Roblox) and button states
---------------------------------------------------------------------------
local function infoFor(card: Card)
	return if card.Kind == "Pass" then Config.PASSES[card.Key] else Config.PRODUCTS[card.Key]
end

local function refresh()
	local level = tonumber(player:GetAttribute("Level")) or 1
	local mult = if player:GetAttribute("Pass_DoubleCash") == true then 2 else 1
	for _, card in cards do
		local info = infoFor(card)
		local button = card.Button
		if card.Kind == "Pass" and player:GetAttribute("Pass_" .. card.Key) == true then
			button.Text = "Owned"
			button.BackgroundColor3 = Color3.fromRGB(70, 90, 70)
		elseif info.Id == 0 then
			button.Text = "Coming soon"
			button.BackgroundColor3 = GREY
		else
			button.Text = if card.Price then "R$ " .. card.Price else "Buy"
			button.BackgroundColor3 = GREEN
		end
		if card.Extra then
			local amount = math.max(info.Min, Config.GetIncome(level) * mult * info.Seconds)
			card.Extra.Text = "+" .. Config.FormatMoney(amount) .. " now"
		end
	end
end

task.spawn(function()
	for _, card in cards do
		local info = infoFor(card)
		if info.Id ~= 0 then
			local infoType = if card.Kind == "Pass" then Enum.InfoType.GamePass else Enum.InfoType.Product
			local ok, result = pcall(MarketplaceService.GetProductInfo, MarketplaceService, info.Id, infoType)
			if ok and result and result.PriceInRobux then
				card.Price = result.PriceInRobux
			end
		end
	end
	refresh()
end)

player.AttributeChanged:Connect(function(name)
	if window.Visible and (name == "Level" or name:match("^Pass_")) then
		refresh()
	end
end)

---------------------------------------------------------------------------
-- Open / close
---------------------------------------------------------------------------
local function fitScale()
	local camera = workspace.CurrentCamera
	local height = camera and camera.ViewportSize.Y or 600
	return math.clamp(height / 560, 0.6, 1)
end

local function setOpen(open: boolean)
	if open == window.Visible then
		return
	end
	if open then
		refresh()
		window.Visible = true
		windowScale.Scale = fitScale() * 0.85
		TweenService:Create(windowScale, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Scale = fitScale() }):Play()
	else
		window.Visible = false
	end
end

shopButton.Activated:Connect(function()
	setOpen(not window.Visible)
end)
closeButton.Activated:Connect(function()
	click()
	setOpen(false)
end)
