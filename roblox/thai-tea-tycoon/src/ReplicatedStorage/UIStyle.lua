-- UIStyle: one look for every menu (title screen, HUD buttons, shop, dialogs).
-- Rounded chunky buttons with a soft top-to-bottom gradient, a white outline and a little
-- grow on hover/press, in the Thai tea palette.

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local UIStyle = {}

UIStyle.Font = Enum.Font.FredokaOne
UIStyle.BodyFont = Enum.Font.GothamBold
UIStyle.Colors = {
	Tea = Color3.fromRGB(233, 124, 38),
	TeaDark = Color3.fromRGB(150, 70, 20),
	Cream = Color3.fromRGB(255, 244, 222),
	Brown = Color3.fromRGB(52, 32, 20),
	Green = Color3.fromRGB(46, 190, 96),
	Blue = Color3.fromRGB(52, 140, 230),
	Purple = Color3.fromRGB(150, 80, 200),
	Red = Color3.fromRGB(225, 70, 60),
	Yellow = Color3.fromRGB(255, 212, 40),
	Grey = Color3.fromRGB(110, 100, 95),
}

function UIStyle.corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = parent
	return c
end

function UIStyle.stroke(parent: Instance, color: Color3?, thickness: number?, transparency: number?)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.new(1, 1, 1)
	s.Thickness = thickness or 2
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

-- soft top-to-bottom shading. It multiplies whatever BackgroundColor3 the object has, so buttons can change colour
-- later (e.g. DAILY turning green) and keep the same shading.
function UIStyle.gradient(parent: Instance, _color: Color3?)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(205, 205, 205))
	g.Rotation = 90
	g.Parent = parent
	return g
end

-- dark translucent card used for panels and windows
function UIStyle.panel(frame: GuiObject, accent: Color3?)
	frame.BackgroundColor3 = UIStyle.Colors.Brown
	frame.BackgroundTransparency = 0.12
	UIStyle.corner(frame, 14)
	UIStyle.stroke(frame, accent or UIStyle.Colors.Tea, 3)
	return frame
end

local clickSound: Sound? = nil
function UIStyle.click()
	if not clickSound then
		clickSound = Instance.new("Sound")
		clickSound.Name = "UIClick"
		clickSound.SoundId = "rbxassetid://12221967" -- button.wav (Roblox)
		clickSound.Volume = 0.5
		clickSound.Parent = SoundService
	end
	if SoundService:GetAttribute("SfxMuted") ~= true then
		SoundService:PlayLocalSound(clickSound :: Sound)
	end
end

-- chunky game button: gradient face, white outline, grows a little on hover and squashes on press
function UIStyle.styleButton(button: GuiButton, color: Color3, textSize: number?)
	button.BackgroundColor3 = color
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	if button:IsA("TextButton") then
		button.Font = UIStyle.Font
		button.TextColor3 = Color3.new(1, 1, 1)
		button.TextStrokeTransparency = 0.6
		if textSize then
			button.TextSize = textSize
		end
	end
	UIStyle.corner(button, 12)
	UIStyle.gradient(button, color)
	UIStyle.stroke(button, Color3.new(1, 1, 1), 2, 0.25)
	local scale = Instance.new("UIScale")
	scale.Parent = button
	local function tweenTo(value: number)
		TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Scale = value }):Play()
	end
	button.MouseEnter:Connect(function()
		tweenTo(1.06)
	end)
	button.MouseLeave:Connect(function()
		tweenTo(1)
	end)
	button.MouseButton1Down:Connect(function()
		tweenTo(0.94)
	end)
	button.MouseButton1Up:Connect(function()
		tweenTo(1.06)
	end)
	button.Activated:Connect(UIStyle.click)
	return button
end

-- build a styled TextButton in one call
function UIStyle.button(parent: Instance, text: string, color: Color3, size: UDim2, position: UDim2?, anchor: Vector2?): TextButton
	local b = Instance.new("TextButton")
	b.Text = text
	b.Size = size
	b.Position = position or UDim2.new()
	b.AnchorPoint = anchor or Vector2.zero
	b.TextScaled = true
	b.ZIndex = 2
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0.08, 0), UDim.new(0.08, 0)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0.18, 0), UDim.new(0.18, 0)
	pad.Parent = b
	UIStyle.styleButton(b, color)
	b.Parent = parent
	return b
end

return UIStyle
