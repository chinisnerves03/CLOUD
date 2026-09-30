-- NpcService: turns the NpcSpot markers left by ItemModels (Builder:Person with ItemModels.UseRigs = true) into real
-- Roblox R15 characters: staff baristas, the VIP barista, queueing customers and the people inside the buildings.
-- Base rigs come from Players:CreateHumanoidModelFromDescription (Roblox-made hair from the catalog); each NPC is a
-- clone recoloured to the marker's outfit, with an apron and hat added from parts and the arms posed like the old
-- part-built people. The rigs stand still on an anchored HumanoidRootPart; clients play the idle/walk animations.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemModels = require(script.Parent:WaitForChild("ItemModels"))

local NpcService = {}

-- Roblox-made hair (catalog): short styles alternate by position, long hair for style.long
local SHORT_HAIR = { 63690008, 376548738 } -- Pal Hair, Brown Charmer Hair
local LONG_HAIR = 4041570918 -- Dark Mermaid Hair

type Base = { Rig: Model, FeetToRoot: number }
local bases: { [string]: Base } = {}
local ready = false

local function makeBase(hairId: number): Base?
	local ok, rig = pcall(function()
		local description = Instance.new("HumanoidDescription")
		description.HairAccessory = tostring(hairId)
		return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	if not ok or not rig then
		warn("[NpcService] Could not build an R15 rig: " .. tostring(rig))
		return nil
	end
	for _, d in rig:GetDescendants() do
		-- the default Animate script (clients animate NPCs themselves), and BodyColors/HumanoidDescription, which
		-- would repaint every body part in the description's default (black) colours over our outfit colours
		if d:IsA("LuaSourceContainer") or d:IsA("BodyColors") or d:IsA("HumanoidDescription") then
			d:Destroy()
		end
	end
	local humanoid = rig:FindFirstChildOfClass("Humanoid") :: Humanoid
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.NameDisplayDistance = 0
	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false
	humanoid.EvaluateStateMachine = false
	humanoid:SetAttribute("Npc", true)
	local lowest = math.huge
	for _, part in rig:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = part.Name == "HumanoidRootPart"
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
			part:SetAttribute("NpcPart", true)
			if part.Parent == rig then
				lowest = math.min(lowest, part.Position.Y - part.Size.Y / 2)
			end
		end
	end
	local root = rig:FindFirstChild("HumanoidRootPart") :: BasePart
	root.Transparency = 1
	return { Rig = rig, FeetToRoot = root.Position.Y - lowest }
end

-- build the base rigs once (asset loading yields); call before any Replace
function NpcService.Init()
	for i, id in SHORT_HAIR do
		local base = makeBase(id)
		if base then
			bases["Short" .. i] = base
		end
	end
	bases.Long = makeBase(LONG_HAIR) or bases.Short1
	ready = bases.Short1 ~= nil
	if not ready then
		warn("[NpcService] No R15 rigs available; NPC markers stay invisible")
	end
end

local function weld(part: BasePart, to: BasePart)
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part:SetAttribute("NpcPart", true)
	local w = Instance.new("WeldConstraint")
	w.Part0 = to
	w.Part1 = part
	w.Parent = part
end

local function paint(rig: Model, marker: BasePart)
	local skin = marker:GetAttribute("Skin") or Color3.fromRGB(234, 184, 146)
	local shirt = marker:GetAttribute("Shirt") or Color3.new(1, 1, 1)
	local pants = marker:GetAttribute("Pants") or Color3.fromRGB(30, 30, 30)
	local colors = {
		Head = skin, LeftHand = skin, RightHand = skin, LeftLowerArm = skin, RightLowerArm = skin,
		UpperTorso = shirt, LeftUpperArm = shirt, RightUpperArm = shirt,
		LowerTorso = pants, LeftUpperLeg = pants, RightUpperLeg = pants, LeftLowerLeg = pants, RightLowerLeg = pants,
		LeftFoot = Color3.fromRGB(35, 35, 35), RightFoot = Color3.fromRGB(35, 35, 35),
	}
	for name, color in colors do
		local part = rig:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			part.Color = color
			if part:IsA("MeshPart") then
				part.TextureID = ""
			end
		end
	end
	-- hair tinted to the outfit's hair colour
	local hair = marker:GetAttribute("Hair")
	for _, accessory in rig:GetChildren() do
		local handle = accessory:IsA("Accessory") and accessory:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") and hair then
			handle.Color = hair
			if handle:IsA("MeshPart") then
				handle.TextureID = ""
			end
			local mesh = handle:FindFirstChildOfClass("SpecialMesh")
			if mesh then
				mesh.TextureId = ""
			end
		end
	end
end

local function addApron(rig: Model, color: Color3)
	local upper = rig:FindFirstChild("UpperTorso") :: BasePart?
	local lower = rig:FindFirstChild("LowerTorso") :: BasePart?
	if not upper or not lower then
		return
	end
	local function panel(size: Vector3, cf: CFrame, to: BasePart)
		local p = Instance.new("Part")
		p.Name = "Apron"
		p.Size = size
		p.CFrame = cf
		p.Color = color
		p.Material = Enum.Material.Fabric
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.CastShadow = false
		p.Parent = rig
		weld(p, to)
	end
	panel(Vector3.new(1.3, 1.0, 0.08), upper.CFrame * CFrame.new(0, -0.1, -upper.Size.Z / 2 - 0.05), upper)
	panel(Vector3.new(1.8, 1.5, 0.08), lower.CFrame * CFrame.new(0, -0.55, -lower.Size.Z / 2 - 0.1), lower)
end

local function addHat(rig: Model, marker: BasePart)
	local head = rig:FindFirstChild("Head") :: BasePart?
	if not head then
		return
	end
	local style = {
		cap = marker:GetAttribute("Cap"),
		chefHat = marker:GetAttribute("ChefHat") == true,
		ngob = marker:GetAttribute("Ngob") == true,
	}
	if not (style.cap or style.chefHat or style.ngob) then
		return
	end
	-- the part-built heads were centred 0.1 higher and a bit bigger than the R15 head
	local hat = ItemModels.BuildHat(head.CFrame * CFrame.new(0, -0.05, 0), style)
	for _, part in hat:GetDescendants() do
		if part:IsA("BasePart") then
			part.CastShadow = false
			part.Parent = rig
			weld(part, head)
		end
	end
	hat:Destroy()
	-- hats cover the hair
	for _, accessory in rig:GetChildren() do
		if accessory:IsA("Accessory") then
			accessory:Destroy()
		end
	end
end

-- raise the arms like the part-built pose: pitch swings the arm forward, yaw toward the body centre
local function pose(rig: Model, marker: BasePart)
	for side, joint in { [-1] = "Left", [1] = "Right" } do
		local upper = rig:FindFirstChild(joint .. "UpperArm")
		local motor = upper and upper:FindFirstChild(joint .. "Shoulder")
		local angles = marker:GetAttribute(joint .. "Pose")
		if motor and motor:IsA("Motor6D") and typeof(angles) == "Vector2" then
			motor.C0 = motor.C0 * CFrame.Angles(0, math.rad(angles.Y * side), 0) * CFrame.Angles(math.rad(angles.X), 0, 0)
		end
	end
end

-- a customer holds their cup (the "Cup" model next to the marker) in the right hand
local function holdCup(rig: Model, container: Instance)
	local cup = container:FindFirstChild("Cup")
	local hand = rig:FindFirstChild("RightHand") :: BasePart?
	if not (cup and cup:IsA("Model") and hand) then
		return
	end
	local cf, size = cup:GetBoundingBox()
	cup:PivotTo(CFrame.new(hand.Position + Vector3.new(0, size.Y / 2 - 0.35, 0)) * cf.Rotation)
	for _, part in cup:GetDescendants() do
		if part:IsA("BasePart") then
			weld(part, hand) -- the Cup model stays where ClientMain looks for it (next to the rig)
		end
	end
end

local counter = 0
local function spawnNpc(marker: BasePart)
	counter += 1
	local base = if marker:GetAttribute("Long") == true then bases.Long
		else bases["Short" .. (counter % #SHORT_HAIR + 1)] or bases.Short1
	local rig = base.Rig:Clone()
	rig.Name = "Npc"
	paint(rig, marker)
	local apron = marker:GetAttribute("Apron")
	if typeof(apron) == "Color3" then
		addApron(rig, apron)
	end
	addHat(rig, marker)
	pose(rig, marker)
	-- arms raised to work (pouring, stirring, cooking): clients add a working motion on top of the idle
	local right = marker:GetAttribute("RightPose")
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if humanoid and typeof(right) == "Vector2" then
		humanoid:SetAttribute("Busy", right.X >= 60)
	end
	local feet = marker.CFrame * CFrame.new(0, -marker.Size.Y / 2, 0)
	rig:PivotTo(feet * CFrame.new(0, base.FeetToRoot, 0))
	local container = marker.Parent
	rig.Parent = container
	if container then
		holdCup(rig, container)
	end
	marker:Destroy()
	return rig
end

-- replace every NpcSpot marker under root with an R15 character
function NpcService.Replace(root: Instance): number
	if not ready then
		return 0
	end
	local markers = {}
	for _, d in root:GetDescendants() do
		if d.Name == "NpcSpot" and d:IsA("BasePart") then
			table.insert(markers, d)
		end
	end
	for _, marker in markers do
		spawnNpc(marker)
	end
	return #markers
end

-- ReplicatedStorage is only needed so the client can find the shared animation ids
NpcService.Animations = {
	Idle = "rbxassetid://507766666",
	Walk = "rbxassetid://507777826",
}
ReplicatedStorage:SetAttribute("NpcIdleAnimation", NpcService.Animations.Idle)
ReplicatedStorage:SetAttribute("NpcWalkAnimation", NpcService.Animations.Walk)

return NpcService
