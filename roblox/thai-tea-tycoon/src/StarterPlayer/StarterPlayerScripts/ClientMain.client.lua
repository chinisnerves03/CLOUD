-- ClientMain: cash HUD + guidance text + guide arrow + notifications/sounds + queueing customers
-- Reads the Attributes set by the server (Cash, Level, Income, BrewValue, BrewCooldown, Staff, Recipe, Speed, Plot) — display only

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

-- cash panel, right edge just above the middle (the top right belongs to the Roblox player list / leaderstats)
local panel = Instance.new("Frame")
panel.Name = "MoneyPanel"
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -12, 0.5, 0)
panel.Size = UDim2.fromOffset(250, 118)
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
local upgradesLabel = makeLabel(panel, {
	Name = "Upgrades", Position = UDim2.fromOffset(0, 86), Size = UDim2.new(1, 0, 0, 18),
	TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(150, 200, 255), Text = "Staff 0/6 · Recipe 0 · Speed 0",
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

local SOUND_FOR_KIND = { Buy = "Buy", Collect = "Collect", Offline = "Collect", Error = "Error", Brew = "Brew" }

-- one Sound per effect, played with PlayLocalSound so fast brews can overlap without creating instances
local sounds: { [string]: Sound } = {}
for key, id in Config.SOUNDS do
	if id ~= "" then
		local sound = Instance.new("Sound")
		sound.Name = "Sfx" .. key
		sound.SoundId = id
		sound.Volume = Config.SOUND_VOLUME[key] or 0.6
		sound.Parent = SoundService
		sounds[key] = sound
	end
end

local function playSound(kind: string)
	local sound = sounds[SOUND_FOR_KIND[kind] or ""]
	if sound then
		SoundService:PlayLocalSound(sound)
	end
end

---------------------------------------------------------------------------
-- Background music: shuffled playlist from Config.MUSIC (the music button in ShopClient mutes SoundService.BackgroundMusic)
---------------------------------------------------------------------------
local music = Instance.new("Sound")
music.Name = "BackgroundMusic"
music.Volume = Config.MUSIC_VOLUME
music.Parent = SoundService

if #Config.MUSIC > 0 then
	task.spawn(function()
		local order = table.clone(Config.MUSIC)
		local index = #order
		while true do
			index += 1
			if index > #order then
				-- reshuffle, never repeating the last track right away
				local last = order[#order]
				for i = #order, 2, -1 do
					local j = math.random(i)
					order[i], order[j] = order[j], order[i]
				end
				if #order > 1 and order[1] == last then
					order[1], order[2] = order[2], order[1]
				end
				index = 1
			end
			music.SoundId = order[index]
			music:Play()
			-- wait for the track to end; give up after a while if it never loads
			local ended = false
			local connection = music.Ended:Once(function()
				ended = true
			end)
			local started = os.clock()
			while not ended do
				task.wait(0.5)
				local length = music.TimeLength
				if os.clock() - started > (if length > 0 then length + 5 else 20) then
					break
				end
			end
			connection:Disconnect()
			task.wait(1.5)
		end
	end)
end

-- small "+฿x" that floats up next to the cash panel on every brew (brews are too frequent for toasts)
local function showBrewPop(text: string)
	local pop = makeLabel(gui, {
		Name = "BrewPop", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -250, 0.5, -60),
		Size = UDim2.fromOffset(90, 24), TextColor3 = YELLOW, Text = text,
	})
	TweenService:Create(pop, TweenInfo.new(0.7), { Position = UDim2.new(1, -250, 0.5, -90), TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(0.75, pop.Destroy, pop)
end

---------------------------------------------------------------------------
-- Customers: they walk in from the plaza, queue at the front of each owned plot's Brew Station, get a cup
-- and walk off. The shop serves on its own every few seconds; each brew serves the front customer at once.
-- Purely visual and local to this client (clones of ReplicatedStorage.CustomerTemplates), no network traffic.
---------------------------------------------------------------------------
local customerTemplates: Instance? = nil -- found lazily so the HUD never waits for it
local customerFolder = Instance.new("Folder")
customerFolder.Name = "LocalCustomers"
customerFolder.Parent = workspace

local QUEUE_SIZE = 3
local QUEUE_GAP = 2.6 -- studs between customers in the queue
local WALK_SPEED = 7
local SERVE_EVERY = 2.5 -- seconds between automatic sales (faster with Faster Service on your own plot)
local SPAWN_EVERY = 1.3
local VIEW_RANGE = 170 -- only animate queues near the camera

type Customer = { Model: Model, Pos: Vector3, Facing: Vector3, Path: { Vector3 }, Slot: number, Side: number, Leaving: boolean, Phase: number, Idle: AnimationTrack?, Walk: AnimationTrack? }

-- customers are R15 rigs (NpcService): walk while moving, idle while waiting
local function customerTrack(model: Model, attr: string, speed: number): AnimationTrack?
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local id = ReplicatedStorage:GetAttribute(attr)
	if not animator or type(id) ~= "string" then
		return nil
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = id
	local ok, track = pcall(animator.LoadAnimation, animator, animation)
	if not ok then
		return nil
	end
	track.Looped = true
	track:AdjustSpeed(speed)
	return track
end

local function setWalking(c, walking: boolean)
	local on, off = if walking then c.Walk else c.Idle, if walking then c.Idle else c.Walk
	if off and off.IsPlaying then
		off:Stop(0.2)
	end
	if on and not on.IsPlaying then
		on:Play(0.2)
		on:AdjustSpeed(if walking then WALK_SPEED / 11 else 1)
	end
end
type Queue = { Customers: { Customer }, SpawnIn: number, ServeIn: number, LastServe: number }
local queues: { [Model]: Queue } = {}

local function setCupVisible(model: Model, visible: boolean)
	local cup = model:FindFirstChild("Cup")
	if cup then
		for _, part in cup:GetChildren() do
			if part:IsA("BasePart") then
				part.Transparency = if visible then (part:GetAttribute("T0") or 0) else 1
			end
		end
	end
end

local function queueStart(plot: Instance): BasePart?
	local station = plot:FindFirstChild("BrewStation")
	return station and station:FindFirstChild("QueueStart", true) :: BasePart?
end

local function clearQueue(plot: Model)
	local q = queues[plot]
	if q then
		for _, c in q.Customers do
			c.Model:Destroy()
		end
		queues[plot] = nil
	end
end

-- hand the front customer a cup and send them off; returns false when nobody is waiting at the counter
local function serveFront(q: Queue): boolean
	for _, c in q.Customers do
		if not c.Leaving then
			if c.Slot ~= 1 or #c.Path > 0 then
				return false
			end
			c.Leaving = true
			setCupVisible(c.Model, true)
			c.Path = { Vector3.new(c.Side * 3.2, 0, -1.2), Vector3.new(c.Side * 16, 0, -10) }
			q.LastServe = os.clock()
			return true
		end
	end
	return false
end

local function serveOwnPlot()
	local plots = workspace:FindFirstChild("Plots")
	local name = player:GetAttribute("Plot")
	local plot = plots and type(name) == "string" and plots:FindFirstChild(name)
	local q = plot and queues[plot :: Model]
	if q and os.clock() - q.LastServe > 0.3 and serveFront(q) then
		q.ServeIn = SERVE_EVERY
	end
end

local customerClock, customerStep = 0, 0
RunService.Heartbeat:Connect(function(dt)
	customerStep += dt
	if customerStep < 1 / 30 then
		return
	end
	customerTemplates = customerTemplates or ReplicatedStorage:FindFirstChild("CustomerTemplates")
	if not customerTemplates then
		return
	end
	dt, customerStep = customerStep, 0
	customerClock += dt
	local plots = workspace:FindFirstChild("Plots")
	local camera = workspace.CurrentCamera
	if not plots or not camera then
		return
	end
	local ownName = player:GetAttribute("Plot")
	local templates = (customerTemplates :: Instance):GetChildren()
	for _, plot in plots:GetChildren() do
		local start = queueStart(plot)
		local active = start ~= nil and plot:GetAttribute("Owned") == true and #templates > 0
			and (camera.CFrame.Position - start.Position).Magnitude < VIEW_RANGE
		if not active or not start then
			clearQueue(plot)
			continue
		end
		local q = queues[plot]
		if not q then
			q = { Customers = {}, SpawnIn = 0, ServeIn = SERVE_EVERY, LastServe = 0 }
			queues[plot] = q
		end

		-- keep the queue topped up and move everyone up a slot when the front leaves
		local waiting = 0
		for _, c in q.Customers do
			if not c.Leaving then
				waiting += 1
				if c.Slot ~= waiting then
					c.Slot = waiting
					table.insert(c.Path, Vector3.new(0, 0, -(waiting - 1) * QUEUE_GAP))
				end
			end
		end
		q.SpawnIn -= dt
		if waiting < QUEUE_SIZE and q.SpawnIn <= 0 then
			q.SpawnIn = SPAWN_EVERY + math.random() * 1.5
			local side = if math.random() < 0.5 then -1 else 1
			local model = templates[math.random(#templates)]:Clone()
			setCupVisible(model, false)
			model.Parent = customerFolder
			local slot = waiting + 1
			table.insert(q.Customers, {
				Idle = customerTrack(model, "NpcIdleAnimation", 1), Walk = customerTrack(model, "NpcWalkAnimation", 1),
				Model = model, Pos = Vector3.new(side * 16, 0, -10), Facing = Vector3.new(0, 0, 1), Side = side,
				Slot = slot, Leaving = false, Phase = math.random() * 6,
				Path = { Vector3.new(0, 0, -QUEUE_SIZE * QUEUE_GAP - 1.5), Vector3.new(0, 0, -(slot - 1) * QUEUE_GAP) },
			})
		end
		q.ServeIn -= dt
		if q.ServeIn <= 0 then
			local speed = if plot.Name == ownName then Config.SpeedMultiplier(tonumber(player:GetAttribute("Speed")) or 0) else 1
			q.ServeIn = if serveFront(q) then SERVE_EVERY / speed else 0.3
		end

		-- walk along each path, face the way they walk (or the counter while waiting), bob while moving
		local floor = start.CFrame * CFrame.new(0, -start.Size.Y / 2, 0)
		for i = #q.Customers, 1, -1 do
			local c = q.Customers[i]
			local moving = false
			local target = c.Path[1]
			if target then
				local delta = target - c.Pos
				local step = WALK_SPEED * dt
				if delta.Magnitude <= step then
					c.Pos = target
					table.remove(c.Path, 1)
				else
					c.Pos += delta.Unit * step
				end
				if delta.Magnitude > 0.05 then
					c.Facing = delta.Unit
				end
				moving = true
			elseif c.Leaving then
				c.Model:Destroy()
				table.remove(q.Customers, i)
				continue
			else
				c.Facing = Vector3.new(0, 0, 1)
			end
			setWalking(c, moving)
			-- part-built customers (no rig) bob instead of animating
			local bob = if moving and not c.Walk then math.abs(math.sin(c.Phase + customerClock * 9)) * 0.18 else 0
			c.Model:PivotTo(floor * CFrame.new(c.Pos + Vector3.new(0, bob, 0)) * CFrame.lookAt(Vector3.zero, c.Facing).Rotation)
		end
	end
end)

notifyRemote.OnClientEvent:Connect(function(kind: string, text: string)
	if kind == "Camera" then
		-- the server just placed us in front of our shop: look at it from behind the character
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local camera = workspace.CurrentCamera
		if root and camera then
			local look = root.CFrame.LookVector
			camera.CFrame = CFrame.lookAt(root.Position - look * 14 + Vector3.new(0, 6, 0), root.Position + look * 20)
		end
		return
	end
	if kind == "Brew" then
		showBrewPop(text)
		serveOwnPlot()
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

-- "+฿x" floating above each working barista, in time with their sales (visual only; the server pays)
local staffTimers: { [Instance]: number } = {}
local function floatAbove(model: Model, text: string)
	local anchor = model.PrimaryPart
	if not anchor then
		return
	end
	local board = Instance.new("BillboardGui")
	board.Size = UDim2.fromOffset(90, 30)
	board.StudsOffset = Vector3.new(0, 6.5, 0)
	board.AlwaysOnTop = true
	board.MaxDistance = 90
	local label = makeLabel(board, { Size = UDim2.fromScale(1, 1), TextColor3 = YELLOW, Text = text })
	board.Adornee = anchor
	board.Parent = playerGui
	TweenService:Create(board, TweenInfo.new(0.9), { StudsOffset = Vector3.new(0, 9, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(0.9), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(0.95, board.Destroy, board)
end

local function animateStaff(plot: Model, dt: number, cup: number)
	local speed = Config.SpeedMultiplier(getNumber("Speed"))
	for _, child in plot:GetChildren() do
		if child:IsA("Model") and (child.Name:match("^Staff%d+$") or child.Name == "VipBarista") then
			local interval = (if child.Name == "VipBarista" then Config.VIP_INTERVAL else Config.STAFF_INTERVAL) / speed
			local t = (staffTimers[child] or math.random() * interval) + dt
			if t >= interval then
				t -= interval
				floatAbove(child, "+" .. Config.FormatMoney(cup))
			end
			staffTimers[child] = t
		end
	end
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
	local rebirths = getNumber("Rebirths")
	levelLabel.Text = if rebirths > 0
		then string.format("Level %d/%d · Rebirth %d", level, Config.MAX_LEVEL, rebirths)
		else string.format("Level %d/%d", level, Config.MAX_LEVEL)
	local staff, recipe, speedLevel = getNumber("Staff"), getNumber("Recipe"), getNumber("Speed")
	upgradesLabel.Text = string.format("Staff %d/%d · Recipe %d · Speed %d", staff, Config.UPGRADES.Staff.Max, recipe, speedLevel)

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
	local brewSpot = station and station:FindFirstChild("BrewPad", true) :: BasePart? or kettle
	local upgrades = plot:FindFirstChild("Upgrades")
	animateStaff(plot, dt, perCup)

	-- cheapest upgrade the player can afford right now, and the cheapest one overall
	local affordable, affordableCost, cheapest, cheapestCost = nil, math.huge, nil, math.huge
	for _, key in Config.UPGRADE_ORDER do
		local cost = Config.UpgradeCost(key, getNumber(key))
		if cost and cost < cheapestCost then
			cheapest, cheapestCost = key, cost
		end
		if cost and cost <= cash and cost < affordableCost then
			affordable, affordableCost = key, cost
		end
	end

	if nextItem and cash >= nextItem.Price then
		hintLabel.Text = string.format("Step on the green pad to build %s (%s)", nextItem.Name, Config.FormatMoney(nextItem.Price))
		setTarget(pad)
	elseif affordable and upgrades then
		hintLabel.Text = string.format("Upgrade: step on %s (%s)", Config.UPGRADES[affordable].Name, Config.FormatMoney(affordableCost))
		setTarget(upgrades:FindFirstChild(affordable) :: BasePart?)
	elseif not nextItem and not cheapest then
		hintLabel.Text = "Your Thai tea empire is complete! Press REBIRTH for bigger income"
		setTarget(nil)
	else
		local goalName, goalCost = if nextItem then nextItem.Name else "", if nextItem then nextItem.Price else math.huge
		if cheapest and cheapestCost < goalCost then
			goalName, goalCost = Config.UPGRADES[cheapest].Name, cheapestCost
		end
		local waitText = if income > 0 then " in " .. Config.FormatTime(math.ceil((goalCost - cash) / income)) else ""
		hintLabel.Text = string.format("Your shop earns %s/s — %s%s · brew behind the counter (E) to get there faster",
			Config.FormatRate(income), goalName, waitText)
		setTarget(brewSpot)
	end
end)
