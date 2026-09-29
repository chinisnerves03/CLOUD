-- Minimal Roblox API mock: enough to run Config / ItemModels / DevPlotBuilder and dump parts.

-- Vector3 ------------------------------------------------------------------
local V3mt = {}
local function V3(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, V3mt) end
V3mt.__add = function(a, b) return V3(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
V3mt.__sub = function(a, b) return V3(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
V3mt.__unm = function(a) return V3(-a.X, -a.Y, -a.Z) end
V3mt.__mul = function(a, b)
	if type(a) == "number" then return V3(b.X * a, b.Y * a, b.Z * a) end
	if type(b) == "number" then return V3(a.X * b, a.Y * b, a.Z * b) end
	return V3(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
V3mt.__div = function(a, b)
	if type(b) == "number" then return V3(a.X / b, a.Y / b, a.Z / b) end
	return V3(a.X / b.X, a.Y / b.Y, a.Z / b.Z)
end
V3mt.__index = function(v, k)
	if k == "Magnitude" then return math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z) end
	if k == "Unit" then local m = math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z); return V3(v.X / m, v.Y / m, v.Z / m) end
	if k == "Lerp" then return function(a, b, t) return a + (b - a) * t end end
	if k == "Dot" then return function(a, b) return a.X * b.X + a.Y * b.Y + a.Z * b.Z end end
	if k == "Cross" then return function(a, b) return V3(a.Y * b.Z - a.Z * b.Y, a.Z * b.X - a.X * b.Z, a.X * b.Y - a.Y * b.X) end end
	if k == "Abs" then return function(a) return V3(math.abs(a.X), math.abs(a.Y), math.abs(a.Z)) end end
	if k == "Min" then return function(a, b) return V3(math.min(a.X, b.X), math.min(a.Y, b.Y), math.min(a.Z, b.Z)) end end
	if k == "Max" then return function(a, b) return V3(math.max(a.X, b.X), math.max(a.Y, b.Y), math.max(a.Z, b.Z)) end end
	error("Vector3 has no member " .. tostring(k))
end
Vector3 = { new = V3, zero = V3(0, 0, 0) }

-- CFrame (R stored row-major: r[1..9]) --------------------------------------
local CFmt = {}
local function mkCF(p, r) return setmetatable({ p = p, r = r }, CFmt) end
local ID = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }
local function mulR(a, b)
	local r = {}
	for i = 0, 2 do
		for j = 0, 2 do
			local s = 0
			for k = 0, 2 do s += a[i * 3 + k + 1] * b[k * 3 + j + 1] end
			r[i * 3 + j + 1] = s
		end
	end
	return r
end
local function rotV(r, v)
	return V3(r[1] * v.X + r[2] * v.Y + r[3] * v.Z, r[4] * v.X + r[5] * v.Y + r[6] * v.Z, r[7] * v.X + r[8] * v.Y + r[9] * v.Z)
end
CFmt.__mul = function(a, b)
	if getmetatable(b) == CFmt then return mkCF(rotV(a.r, b.p) + a.p, mulR(a.r, b.r)) end
	return rotV(a.r, b) + a.p
end
CFmt.__add = function(a, v) return mkCF(a.p + v, a.r) end
local function transpose(r) return { r[1], r[4], r[7], r[2], r[5], r[8], r[3], r[6], r[9] } end
CFmt.__index = function(cf, k)
	if k == "Position" then return cf.p end
	if k == "X" then return cf.p.X end
	if k == "Y" then return cf.p.Y end
	if k == "Z" then return cf.p.Z end
	if k == "LookVector" then return V3(-cf.r[3], -cf.r[6], -cf.r[9]) end
	if k == "RightVector" then return V3(cf.r[1], cf.r[4], cf.r[7]) end
	if k == "UpVector" then return V3(cf.r[2], cf.r[5], cf.r[8]) end
	if k == "Rotation" then return mkCF(V3(0, 0, 0), cf.r) end
	if k == "ToObjectSpace" then
		return function(self, other)
			local inv = transpose(self.r)
			return mkCF(rotV(inv, other.p - self.p), mulR(inv, other.r))
		end
	end
	if k == "PointToObjectSpace" then
		return function(self, v)
			local d = v - self.p
			local r = self.r
			return V3(r[1] * d.X + r[4] * d.Y + r[7] * d.Z, r[2] * d.X + r[5] * d.Y + r[8] * d.Z, r[3] * d.X + r[6] * d.Y + r[9] * d.Z)
		end
	end
	error("CFrame has no member " .. tostring(k))
end
local function rx(a) local c, s = math.cos(a), math.sin(a); return { 1, 0, 0, 0, c, -s, 0, s, c } end
local function ry(a) local c, s = math.cos(a), math.sin(a); return { c, 0, s, 0, 1, 0, -s, 0, c } end
local function rz(a) local c, s = math.cos(a), math.sin(a); return { c, -s, 0, s, c, 0, 0, 0, 1 } end
CFrame = {
	new = function(x, y, z)
		if type(x) == "table" then return mkCF(x, ID) end
		return mkCF(V3(x or 0, y or 0, z or 0), ID)
	end,
	Angles = function(a, b, c) return mkCF(V3(0, 0, 0), mulR(mulR(rx(a), ry(b)), rz(c))) end,
	lookAt = function(pos, target)
		local look = (target - pos).Unit
		local up0 = V3(0, 1, 0)
		if math.abs(look.Y) > 0.999 then up0 = V3(0, 0, 1) end
		local right = look:Cross(up0).Unit
		local up = right:Cross(look)
		return mkCF(pos, { right.X, up.X, -look.X, right.Y, up.Y, -look.Y, right.Z, up.Z, -look.Z })
	end,
}

-- Misc datatypes -----------------------------------------------------------
local ColorMT = {}
ColorMT.__index = ColorMT
function ColorMT:Lerp(o, t) return setmetatable({ R = self.R + (o.R - self.R) * t, G = self.G + (o.G - self.G) * t, B = self.B + (o.B - self.B) * t }, ColorMT) end
Color3 = {
	fromRGB = function(r, g, b) return setmetatable({ R = r / 255, G = g / 255, B = b / 255 }, ColorMT) end,
	new = function(r, g, b) return setmetatable({ R = r, G = g, B = b }, ColorMT) end,
}
UDim2 = {
	new = function(a, b, c, d) return { a, b, c, d } end,
	fromScale = function(a, b) return { a, 0, b, 0 } end,
	fromOffset = function(a, b) return { 0, a, 0, b } end,
}
UDim = { new = function(a, b) return { a, b } end }
Vector2 = { new = function(a, b) return { a, b } end }
Enum = setmetatable({}, {
	__index = function(_, typeName)
		return setmetatable({}, { __index = function(_, name) return { EnumType = typeName, Name = name } end })
	end,
})
warn = function(...) print("WARN", ...) end

-- Instances ----------------------------------------------------------------
local BASEPARTS = { Part = true, WedgePart = true, SpawnLocation = true }
local Inst = {}
local function newInstance(className)
	local obj = { _props = { ClassName = className, Name = className }, _children = {} }
	return setmetatable(obj, Inst)
end
local methods = {}
Inst.__index = function(obj, k)
	if methods[k] then return methods[k] end
	return obj._props[k]
end
Inst.__newindex = function(obj, k, v)
	if k == "Parent" then
		local old = obj._props.Parent
		if old then
			for i, c in old._children do
				if c == obj then table.remove(old._children, i) break end
			end
		end
		if v then table.insert(v._children, obj) end
	end
	obj._props[k] = v
end
function methods.GetChildren(self) return table.clone(self._children) end
function methods.SetAttribute(self, k, v) self._attrs = self._attrs or {}; self._attrs[k] = v end
function methods.GetAttribute(self, k) return self._attrs and self._attrs[k] end
-- uniform scale about WorldPivot (enough for ItemModels.Uniform)
function methods.ScaleTo(self, k)
	local pivot = self.WorldPivot
	for _, d in self:GetDescendants() do
		if d:IsA("BasePart") then
			local rel = pivot:ToObjectSpace(d.CFrame)
			d.CFrame = pivot * mkCF(rel.p * k, rel.r)
			d.Size = d.Size * k
		end
	end
end
function methods.FindFirstChild(self, name)
	for _, c in self._children do if c.Name == name then return c end end
	return nil
end
function methods.IsA(self, class)
	local cn = self.ClassName
	if class == "BasePart" then return BASEPARTS[cn] == true end
	return cn == class
end
function methods.FindFirstChildWhichIsA(self, class, recursive)
	for _, c in self._children do
		if c:IsA(class) then return c end
		if recursive then
			local f = c:FindFirstChildWhichIsA(class, true)
			if f then return f end
		end
	end
	return nil
end
function methods.GetDescendants(self)
	local out = {}
	local function walk(o)
		for _, c in o._children do
			table.insert(out, c)
			walk(c)
		end
	end
	walk(self)
	return out
end
Instance = { new = newInstance }

workspace = newInstance("Workspace")
local modules = {}
local services = {}
game = {
	GetService = function(_, name)
		if not services[name] then
			local s = newInstance(name)
			services[name] = s
		end
		return services[name]
	end,
}
methods.WaitForChild = function(self, name)
	local found = self:FindFirstChild(name)
	if found then return found end
	if modules[name] then return modules[name] end
	error("WaitForChild: " .. name .. " not found")
end
local function registerModule(name, fn)
	modules[name] = { __module = name, __fn = fn }
end
local loaded = {}
local function require(m)
	if loaded[m.__module] == nil then loaded[m.__module] = m.__fn() end
	return loaded[m.__module]
end
local scriptParent = newInstance("Folder")
script = { Parent = scriptParent }
