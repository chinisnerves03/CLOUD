-- MotionClient: small local animations that make the world feel alive (nothing here touches the server)
--   * "Anim" groups built by ItemModels (Builder:Group): Spin (roaster drum, globe, orbiting cups),
--     Bob (balloons), Sway (hanging lanterns) and Lean (tree canopies in the wind)
--   * parts named "Beacon" pulse; the fountain "Spout" sprays water
--   * R15 NPCs (NpcService) look around, turn their head toward you when you come close and sometimes wave;
--     the ones working (Busy) keep pouring or stirring, and baristas reach forward as they hand over a cup
-- Only things within MOTION_RANGE of the camera are animated.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local MOTION_RANGE = 140
local NPC_RANGE = 90
local SETTLE_TIME = 1 -- wait for an item's pop-in to finish before reading its resting pose
local GREET_RANGE = 14 -- NPCs notice you within this distance
local WAVE_COOLDOWN = 30

type Group = { Model: Model, Kind: string, Axis: Vector3, Speed: number, Pivot: CFrame, Phase: number }
type Npc = { Humanoid: Humanoid, Root: BasePart, Neck: Motor6D?, NeckC0: CFrame, Arm: Motor6D?, ArmC0: CFrame, Busy: boolean,
	Phase: number, Look: number, WavedAt: number, NextIdle2: number }

local groups: { [Model]: Group } = {}
local beacons: { [BasePart]: number } = {}
local npcs: { [Humanoid]: Npc } = {}

local function registerGroup(model: Model)
	if groups[model] or not model:IsDescendantOf(workspace) then
		return
	end
	local cf, size = model:GetBoundingBox()
	local kind = tostring(model:GetAttribute("Kind") or "Spin")
	local pivotPos = if kind == "Sway" then cf.Position + Vector3.new(0, size.Y / 2, 0)
		elseif kind == "Lean" then cf.Position - Vector3.new(0, size.Y / 2, 0)
		else cf.Position
	local pivot = CFrame.new(pivotPos)
	model.WorldPivot = pivot
	local axis = model:GetAttribute("Axis")
	groups[model] = {
		Model = model,
		Kind = kind,
		Axis = if typeof(axis) == "Vector3" and axis.Magnitude > 0 then axis.Unit else Vector3.yAxis,
		Speed = tonumber(model:GetAttribute("Speed")) or 1,
		Pivot = pivot,
		Phase = math.random() * math.pi * 2,
	}
end

local function addSpray(spout: BasePart)
	if spout:FindFirstChild("Spray") then
		return
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "Spray"
	attachment.Position = Vector3.new(0, spout.Size.Y / 2, 0)
	local water = Instance.new("ParticleEmitter")
	water.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	water.Color = ColorSequence.new(Color3.fromRGB(200, 235, 255), Color3.fromRGB(120, 190, 240))
	water.LightEmission = 0.4
	water.Transparency = NumberSequence.new(0.2, 0.9)
	water.Size = NumberSequence.new(0.35, 0.15)
	water.Lifetime = NumberRange.new(0.9, 1.3)
	water.Rate = 45
	water.Speed = NumberRange.new(9, 12)
	water.SpreadAngle = Vector2.new(16, 16)
	water.Acceleration = Vector3.new(0, -28, 0)
	water.EmissionDirection = Enum.NormalId.Top
	water.Parent = attachment
	attachment.Parent = spout
end

local tracks: { [Humanoid]: { [string]: AnimationTrack | boolean } } = {}
local function playNpc(humanoid: Humanoid, name: string)
	local cache = tracks[humanoid]
	if not cache then
		cache = {}
		tracks[humanoid] = cache
	end
	local track = cache[name]
	if track == nil then
		track = false
		local animator = humanoid:FindFirstChildOfClass("Animator")
		local id = ReplicatedStorage:GetAttribute("Npc" .. name .. "Animation")
		if animator and type(id) == "string" then
			local animation = Instance.new("Animation")
			animation.AnimationId = id
			local ok, loaded = pcall(animator.LoadAnimation, animator, animation)
			if ok then
				loaded.Looped = false
				loaded.Priority = if name == "Idle2" then Enum.AnimationPriority.Idle else Enum.AnimationPriority.Action
				track = loaded
			end
		end
		cache[name] = track
	end
	if track then
		(track :: AnimationTrack):Play(0.2)
	end
end

local function registerNpc(humanoid: Humanoid)
	if npcs[humanoid] then
		return
	end
	local rig = humanoid.Parent
	local root = rig and rig:FindFirstChild("HumanoidRootPart")
	local head = rig and rig:FindFirstChild("Head")
	local arm = rig and rig:FindFirstChild("RightUpperArm")
	if not (root and root:IsA("BasePart")) then
		return
	end
	local neck = head and head:FindFirstChild("Neck")
	local shoulder = arm and arm:FindFirstChild("RightShoulder")
	npcs[humanoid] = {
		Humanoid = humanoid,
		Look = 0,
		WavedAt = 0,
		NextIdle2 = os.clock() + 5 + math.random() * 20,
		Root = root,
		Neck = if neck and neck:IsA("Motor6D") then neck else nil,
		NeckC0 = if neck and neck:IsA("Motor6D") then neck.C0 else CFrame.identity,
		Arm = if shoulder and shoulder:IsA("Motor6D") then shoulder else nil,
		ArmC0 = if shoulder and shoulder:IsA("Motor6D") then shoulder.C0 else CFrame.identity,
		Busy = humanoid:GetAttribute("Busy") == true,
		Phase = math.random() * math.pi * 2,
	}
end

local function onDescendant(d: Instance)
	if d:IsA("Model") and d.Name == "Anim" then
		task.delay(SETTLE_TIME, registerGroup, d)
	elseif d:IsA("BasePart") and d.Name == "Beacon" then
		beacons[d] = d.Transparency
	elseif d:IsA("BasePart") and d.Name == "Spout" then
		addSpray(d)
	elseif d:IsA("Humanoid") and d:GetAttribute("Npc") then
		task.delay(SETTLE_TIME, registerNpc, d)
	end
end

for _, name in { "Plots", "PlazaDecor" } do
	task.spawn(function()
		local root = workspace:WaitForChild(name, 60)
		if root then
			for _, d in root:GetDescendants() do
				onDescendant(d)
			end
			root.DescendantAdded:Connect(onDescendant)
		end
	end)
end

local clock = 0
RunService.RenderStepped:Connect(function(dt)
	clock += dt
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local eye = camera.CFrame.Position

	for model, g in groups do
		if not model:IsDescendantOf(workspace) then
			groups[model] = nil
		elseif (g.Pivot.Position - eye).Magnitude < MOTION_RANGE then
			local t = clock * g.Speed
			local cf
			if g.Kind == "Spin" then
				cf = g.Pivot * CFrame.fromAxisAngle(g.Axis, t)
			elseif g.Kind == "Lean" then
				-- a slow sway plus a faster flutter, like gusts of wind
				local a = math.sin(t * math.pi * 2 + g.Phase) * 0.045 + math.sin(t * math.pi * 5.3 + g.Phase * 2) * 0.012
				cf = g.Pivot * CFrame.fromAxisAngle(g.Axis, a)
			elseif g.Kind == "Bob" then
				cf = g.Pivot + Vector3.new(0, math.sin(t * math.pi * 2 + g.Phase) * 0.35, 0)
			else -- Sway
				cf = g.Pivot * CFrame.fromAxisAngle(g.Axis, math.sin(t * math.pi * 2 + g.Phase) * 0.14)
			end
			model:PivotTo(cf)
		end
	end

	local pulse = 0.5 + 0.5 * math.sin(clock * 4)
	for part, t0 in beacons do
		if not part:IsDescendantOf(workspace) then
			beacons[part] = nil
		else
			part.Transparency = t0 + (1 - t0) * 0.6 * pulse
			local light = part:FindFirstChildWhichIsA("PointLight")
			if light then
				light.Brightness = 0.3 + 1.2 * (1 - pulse)
			end
		end
	end

	local character = player.Character
	local me = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local now = os.clock()
	for humanoid, n in npcs do
		if not humanoid:IsDescendantOf(workspace) then
			npcs[humanoid] = nil
			tracks[humanoid] = nil
		elseif (n.Root.Position - eye).Magnitude < NPC_RANGE then
			local p = n.Phase
			-- is the player close and in front? then look at them (and maybe wave)
			local lookTarget = math.sin(clock * 0.35 + p) * 0.4 -- idle glances left and right
			if me then
				local offset = n.Root.CFrame:PointToObjectSpace(me.Position)
				local distance = offset.Magnitude
				if distance < GREET_RANGE and offset.Z < 2 then
					lookTarget = math.clamp(math.atan2(-offset.X, -offset.Z), -1, 1)
					if not n.Busy and now - n.WavedAt > WAVE_COOLDOWN and distance < GREET_RANGE * 0.7 then
						n.WavedAt = now
						if math.random() < 0.6 then
							playNpc(humanoid, "Wave")
						end
					end
				end
			end
			n.Look += (lookTarget - n.Look) * math.min(1, dt * 4)
			if n.Neck then
				n.Neck.C0 = n.NeckC0 * CFrame.Angles(math.sin(clock * 0.7 + p) * 0.06, n.Look, 0)
			end
			if n.Arm then
				-- baristas reach forward as the cup is handed over (ClientMain sets ServeAt on each sale)
				local serveAt = tonumber(humanoid:GetAttribute("ServeAt")) or -10
				local reach = math.clamp((now - serveAt) / 0.5, 0, 1)
				local serve = if reach < 1 then math.sin(reach * math.pi) * 0.9 else 0
				if n.Busy then
					-- pouring / stirring rhythm on top of the posed arm
					n.Arm.C0 = n.ArmC0 * CFrame.Angles(math.sin(clock * 3.2 + p) * 0.22 - serve, 0, math.sin(clock * 1.6 + p) * 0.08)
				elseif serve > 0 then
					-- arm hanging down: lift it forward (raised working arms lower forward instead, above)
					n.Arm.C0 = n.ArmC0 * CFrame.Angles(serve, 0, 0)
				end
			end
			-- now and then an idle variation (looking around, shifting weight)
			if now >= n.NextIdle2 then
				n.NextIdle2 = now + 15 + math.random() * 25
				playNpc(humanoid, "Idle2")
			end
		end
	end
end)
