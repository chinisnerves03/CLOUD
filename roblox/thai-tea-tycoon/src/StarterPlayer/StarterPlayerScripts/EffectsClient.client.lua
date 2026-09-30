-- EffectsClient: purely visual, local effects on the plots (nothing here touches the server)
--   * steam: parts named "Steam" (ItemModels) get a rising steam ParticleEmitter; their static puffs are hidden
--   * conveyor: parts named "BeltCup" on the Cup Conveyor slide along the belt in an endless loop
--   * neon flicker: neon parts of the signs in FLICKER_ITEMS flicker now and then
--   * pop-in: a newly built item on your own plot grows in with a bounce and a burst of sparkles

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local player = Players.LocalPlayer

local STEAM_TEXTURE = "rbxasset://textures/particles/smoke_main.dds"
local SPARKLE_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"
local BELT_SPACING = 1.5 -- distance between cups on the belt (ItemModels Build.L31)
local BELT_SPEED = 1.2 -- studs per second
local FLICKER_ITEMS = { L28 = true, L37 = true } -- neon cup sign, billboard
local EFFECT_RANGE = 150 -- only animate belts and signs near the camera
local POP_TIME = 0.55

---------------------------------------------------------------------------
-- Steam
---------------------------------------------------------------------------
local function addSteam(part: BasePart)
	if part:FindFirstChild("SteamFx") then
		return
	end
	part.Transparency = 1 -- local only: the particles replace the static puff
	local size = math.max(part.Size.X, 0.4)
	local attachment = Instance.new("Attachment")
	attachment.Name = "SteamFx"
	attachment.Position = Vector3.new(0, -size * 0.3, 0)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = STEAM_TEXTURE
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	emitter.LightInfluence = 0.7
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, size * 0.45),
		NumberSequenceKeypoint.new(1, size * 1.7),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0.55),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Lifetime = NumberRange.new(1.6, 2.6)
	emitter.Rate = 5
	emitter.Speed = NumberRange.new(1.2, 2.2)
	emitter.SpreadAngle = Vector2.new(12, 12)
	emitter.Acceleration = Vector3.new(0, 0.8, 0)
	emitter.Drag = 0.6
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-30, 30)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Parent = attachment
	attachment.Parent = part
end

---------------------------------------------------------------------------
-- Conveyor belts and neon signs (registered per item model)
---------------------------------------------------------------------------
type Belt = { Model: Model, Cups: { { Part: BasePart, Origin: CFrame } }, Axis: Vector3 }
type Sign = { Model: Model, Parts: { { Part: BasePart, T0: number } }, Lights: { Light }, NextAt: number }
local belts: { [Model]: Belt } = {}
local signs: { [Model]: Sign } = {}

local function registerBelt(model: Model)
	local cups = {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and d.Name == "BeltCup" then
			table.insert(cups, { Part = d, Origin = d.CFrame })
		end
	end
	-- the belt runs along the line through the cups: the farthest pair of same-sized cup parts
	local axis, best = nil, 0
	for _, a in cups do
		for _, b in cups do
			if a.Part.Size == b.Part.Size then
				local delta = b.Origin.Position - a.Origin.Position
				if delta.Magnitude > best and delta.X >= 0 then
					best, axis = delta.Magnitude, delta.Unit
				end
			end
		end
	end
	if axis then
		belts[model] = { Model = model, Cups = cups, Axis = axis }
	end
end

local function registerSign(model: Model)
	local parts, lights = {}, {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and d.Material == Enum.Material.Neon then
			table.insert(parts, { Part = d, T0 = d.Transparency })
		elseif d:IsA("Light") then
			table.insert(lights, d)
		end
	end
	if #parts > 0 then
		signs[model] = { Model = model, Parts = parts, Lights = lights, NextAt = os.clock() + math.random() * 4 }
	end
end

local function setSignOn(sign: Sign, on: boolean)
	for _, entry in sign.Parts do
		entry.Part.Transparency = if on then entry.T0 else math.max(entry.T0, 0.8)
	end
	for _, light in sign.Lights do
		light.Enabled = on
	end
end

-- a short burst of 3-5 blinks, then back on
local function flicker(sign: Sign)
	task.spawn(function()
		for _ = 1, math.random(3, 5) do
			setSignOn(sign, false)
			task.wait(0.04 + math.random() * 0.08)
			setSignOn(sign, true)
			task.wait(0.05 + math.random() * 0.15)
		end
	end)
end

---------------------------------------------------------------------------
-- Pop-in for newly built items on your own plot
---------------------------------------------------------------------------
local levelChangedAt = 0
player:GetAttributeChangedSignal("Level"):Connect(function()
	levelChangedAt = os.clock()
end)

local function sparkleBurst(model: Model, color: Color3)
	local cf, size = model:GetBoundingBox()
	local holder = Instance.new("Part")
	holder.Anchored = true
	holder.CanCollide = false
	holder.CanQuery = false
	holder.CanTouch = false
	holder.Transparency = 1
	holder.Size = Vector3.new(math.min(size.X, 30), 0.2, math.min(size.Z, 30))
	holder.CFrame = cf * CFrame.new(0, -size.Y / 2 + 0.5, 0)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = SPARKLE_TEXTURE
	emitter.Color = ColorSequence.new(color, Color3.new(1, 1, 1))
	emitter.LightEmission = 0.8
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
	emitter.Lifetime = NumberRange.new(0.7, 1.3)
	emitter.Speed = NumberRange.new(8, 16)
	emitter.SpreadAngle = Vector2.new(40, 40)
	emitter.Acceleration = Vector3.new(0, -20, 0)
	emitter.Rate = 0
	emitter.Parent = holder
	holder.Parent = workspace
	emitter:Emit(math.clamp(math.floor(size.Magnitude * 2), 25, 80))
	task.delay(2, holder.Destroy, holder)
end

-- models mid pop-in (their scale is changing, so the belt/sign scan skips them)
local popping: { [Model]: boolean } = {}

local function popIn(model: Model)
	local item
	for level = 2, Config.MAX_LEVEL do
		if Config.Items[level].Key == model.Name then
			item = Config.Items[level]
			break
		end
	end
	if not item then
		return
	end
	-- items can be built bigger than 1 (ItemModels.Uniform: van, billboard, ...): pop back to that size
	local base = model:GetScale()
	local ok = pcall(function()
		model:ScaleTo(base * 0.05)
	end)
	if not ok then
		return
	end
	popping[model] = true
	local start = os.clock()
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local t = math.clamp((os.clock() - start) / POP_TIME, 0, 1)
		-- ease out back: overshoots a little, then settles at full size
		local c1, c3 = 1.70158, 2.70158
		local eased = 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
		if t >= 1 or not model.Parent then
			connection:Disconnect()
			popping[model] = nil
			if model.Parent then
				model:ScaleTo(base)
			end
			return
		end
		model:ScaleTo(base * math.max(0.05, eased))
	end)
	sparkleBurst(model, Config.TIERS[item.Tier].Color)
end

---------------------------------------------------------------------------
-- Watch the plots: items move between ServerStorage and each plot's Items folder, and stream in and out
---------------------------------------------------------------------------
local function onDescendant(d: Instance)
	if d:IsA("BasePart") then
		if d.Name == "Steam" then
			addSteam(d)
		elseif d.Name == "SteamPuff" then
			d.Transparency = 1
		end
	elseif d:IsA("Model") and d.Parent and d.Parent.Name == "Items" then
		local ownPlot = player:GetAttribute("Plot")
		local plot = d.Parent.Parent
		if plot and plot.Name == ownPlot and os.clock() - levelChangedAt < 3 then
			local key = Config.Items[tonumber(player:GetAttribute("Level")) or 1]
			if key and key.Key == d.Name then
				task.defer(popIn, d)
			end
		end
	end
end

local function watch(plots: Instance)
	for _, d in plots:GetDescendants() do
		onDescendant(d)
	end
	plots.DescendantAdded:Connect(onDescendant)
end

task.spawn(function()
	watch(workspace:WaitForChild("Plots"))
end)

-- belts and signs are (re)registered from a slow scan, so pop-ins and streaming never leave stale positions
local scanAt = 0
RunService.Heartbeat:Connect(function()
	local now = os.clock()
	local camera = workspace.CurrentCamera
	local plots = workspace:FindFirstChild("Plots")
	if not camera or not plots then
		return
	end

	if now >= scanAt then
		scanAt = now + 1
		for model in belts do
			if not model:IsDescendantOf(plots) then
				belts[model] = nil
			end
		end
		for model in signs do
			if not model:IsDescendantOf(plots) then
				signs[model] = nil
			end
		end
		for _, plot in plots:GetChildren() do
			local items = plot:FindFirstChild("Items")
			if items then
				for _, model in items:GetChildren() do
					if model:IsA("Model") and not popping[model :: Model] then
						if model.Name == "L31" and not belts[model] then
							registerBelt(model :: Model)
						elseif FLICKER_ITEMS[model.Name] and not signs[model] then
							registerSign(model :: Model)
						end
					end
				end
			end
		end
	end

	local eye = camera.CFrame.Position
	local shift = (now * BELT_SPEED) % BELT_SPACING
	for _, belt in belts do
		local first = belt.Cups[1]
		if first and (first.Origin.Position - eye).Magnitude < EFFECT_RANGE then
			local offset = belt.Axis * shift
			for _, cup in belt.Cups do
				cup.Part.CFrame = cup.Origin + offset
			end
		end
	end
	for _, sign in signs do
		if now >= sign.NextAt then
			sign.NextAt = now + 2.5 + math.random() * 4
			local pivot = sign.Model:GetPivot().Position
			if (pivot - eye).Magnitude < EFFECT_RANGE then
				flicker(sign)
			end
		end
	end
end)
