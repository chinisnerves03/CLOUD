-- SprintClient: hold Shift (or the RUN button on touch screens) to run. Running widens the camera a little and
-- kicks up dust at the feet. The character is client-owned, so WalkSpeed set here replicates.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local WALK_SPEED = 16
local RUN_SPEED = 28
local WALK_FOV = 70
local RUN_FOV = 80

local wantRun = false
local running = false
local humanoid: Humanoid? = nil
local dust: ParticleEmitter? = nil

local function makeDust(root: BasePart): ParticleEmitter
	local attachment = Instance.new("Attachment")
	attachment.Name = "RunDust"
	attachment.Position = Vector3.new(0, -2.8, 0.6)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	emitter.Color = ColorSequence.new(Color3.fromRGB(215, 200, 180))
	emitter.LightInfluence = 0.8
	emitter.Size = NumberSequence.new(0.6, 1.8)
	emitter.Transparency = NumberSequence.new(0.55, 1)
	emitter.Lifetime = NumberRange.new(0.4, 0.7)
	emitter.Rate = 18
	emitter.Speed = NumberRange.new(1, 2)
	emitter.SpreadAngle = Vector2.new(40, 40)
	emitter.EmissionDirection = Enum.NormalId.Back
	emitter.Enabled = false
	emitter.Parent = attachment
	attachment.Parent = root
	return emitter
end

local function onCharacter(character: Model)
	humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	local root = character:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	dust = if root then makeDust(root) else nil
	running = false
end
if player.Character then
	task.spawn(onCharacter, player.Character)
end
player.CharacterAdded:Connect(onCharacter)

local function onSprint(_, state: Enum.UserInputState)
	if state == Enum.UserInputState.Begin then
		wantRun = true
	elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
		wantRun = false
	end
	return Enum.ContextActionResult.Pass
end
ContextActionService:BindAction("Sprint", onSprint, true, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift, Enum.KeyCode.ButtonL3)
ContextActionService:SetTitle("Sprint", "RUN")
ContextActionService:SetPosition("Sprint", UDim2.new(1, -170, 1, -150))

local fovTween: Tween? = nil
local function setFov(fov: number)
	local camera = workspace.CurrentCamera
	if camera and math.abs(camera.FieldOfView - fov) > 0.5 then
		if fovTween then
			fovTween:Cancel()
		end
		fovTween = TweenService:Create(camera, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { FieldOfView = fov })
		fovTween:Play()
	end
end

RunService.RenderStepped:Connect(function()
	local h = humanoid
	if not h or h.Health <= 0 or player:GetAttribute("InMenu") then
		return -- the title screen holds the character still
	end
	local moving = h.MoveDirection.Magnitude > 0.1
	local shouldRun = wantRun and moving
	if shouldRun ~= running then
		running = shouldRun
		h.WalkSpeed = if running then RUN_SPEED else WALK_SPEED
		setFov(if running then RUN_FOV else WALK_FOV)
	end
	if dust then
		dust.Enabled = running and h.FloorMaterial ~= Enum.Material.Air
	end
end)
