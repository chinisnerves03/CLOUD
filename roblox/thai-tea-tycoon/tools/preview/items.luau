-- Measure every item built alone at CFrame.new() (min/max of part bounds, not GetBoundingBox) and lay the
-- requested items out in a row next to a 5.5-stud reference person; writes the same JSON lines as dump.luau
-- (item = key) plus "#SIZE key w h d parts" lines. Used by items.sh.
local ItemModels = require(script.Parent:WaitForChild("ItemModels"))

local function bounds(model)
	local lo, hi = Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9)
	local n = 0
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and (d.Transparency or 0) < 1 then
			n += 1
			local cf, s = d.CFrame, d.Size / 2
			for _, sx in { -1, 1 } do
				for _, sy in { -1, 1 } do
					for _, sz in { -1, 1 } do
						local p = cf * Vector3.new(sx * s.X, sy * s.Y, sz * s.Z)
						lo, hi = lo:Min(p), hi:Max(p)
					end
				end
			end
		end
	end
	return lo, hi, n
end

local keys = {}
for i = 2, 45 do
	table.insert(keys, string.format("L%02d", i))
end
for _, k in keys do
	local m = ItemModels.Build(k, CFrame.new())
	local lo, hi, n = bounds(m)
	local s = hi - lo
	print(string.format("#SIZE %s w=%.1f h=%.1f d=%.1f (%.2f x %.2f x %.2f m) parts=%d minY=%.2f", k, s.X, s.Y, s.Z,
		s.X * 0.318, s.Y * 0.318, s.Z * 0.318, n, lo.Y))
end

-- solo row: SHOW is set by items.sh
local root = Instance.new("Folder")
root.Name = "Plot1"
local x = 0
for _, k in SHOW do
	local m0 = ItemModels.Build(k, CFrame.new())
	local lo, hi = bounds(m0)
	local w = hi.X - lo.X
	local m = ItemModels.Build(k, CFrame.new(x - lo.X, 0, 0))
	m.Parent = root
	x += w + 4
end
local ref = Instance.new("Model")
ref.Name = "Ref"
ref.Parent = root
ItemModels.BuildDecor("Customer", CFrame.new(-3, 0, -3), 1).Parent = ref

local function num(n) return string.format("%.4f", n) end
local function col(c) return "[" .. num(c.R) .. "," .. num(c.G) .. "," .. num(c.B) .. "]" end
local function esc(s) return (s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")) end
for _, obj in root:GetDescendants() do
	if obj:IsA("BasePart") then
		local item = "x"
		local p = obj.Parent
		while p and p ~= root do
			if p.ClassName == "Model" then item = p.Name end
			p = p.Parent
		end
		local cf = obj.CFrame
		local r = cf.r
		local shape = obj.Shape and obj.Shape.Name or "Block"
		if obj.ClassName == "WedgePart" then shape = "Wedge" end
		if obj:FindFirstChildWhichIsA("SpecialMesh") then shape = "Ellipsoid" end
		local texts = {}
		for _, g in obj:GetChildren() do
			if g.ClassName == "SurfaceGui" then
				for _, l in g:GetChildren() do
					if l.ClassName == "TextLabel" then
						local reg = { l.Position[1], l.Position[3], l.Size[1], l.Size[3] }
						table.insert(texts, string.format('{"face":"%s","text":"%s","color":%s,"glow":%s,"region":[%s,%s,%s,%s],"bgT":%s,"bg":%s}',
							g.Face.Name, esc(l.Text), col(l.TextColor3), tostring(g.LightInfluence == 0),
							num(reg[1]), num(reg[2]), num(reg[3]), num(reg[4]), num(l.BackgroundTransparency or 0), col(l.BackgroundColor3 or Color3.new(0, 0, 0))))
					end
				end
			end
		end
		print(string.format('{"item":"%s","name":"%s","shape":"%s","size":[%s,%s,%s],"pos":[%s,%s,%s],"rot":[%s],"color":%s,"t":%s,"mat":"%s","texts":[%s],"light":null}',
			item, esc(obj.Name), shape, num(obj.Size.X), num(obj.Size.Y), num(obj.Size.Z), num(cf.p.X), num(cf.p.Y), num(cf.p.Z),
			table.concat({ num(r[1]), num(r[2]), num(r[3]), num(r[4]), num(r[5]), num(r[6]), num(r[7]), num(r[8]), num(r[9]) }, ","),
			col(obj.Color or Color3.new(0.6, 0.6, 0.6)), num(obj.Transparency or 0), obj.Material and obj.Material.Name or "Plastic", table.concat(texts, ",")))
	end
end
print(string.format("#ROW width=%.1f", x))
