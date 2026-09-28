-- run builders + dump parts as JSON lines
local DevPlotBuilder = require(modules.DevPlotBuilder or script.Parent:WaitForChild("DevPlotBuilder"))
local ItemModels = require(script.Parent:WaitForChild("ItemModels"))
local folder = DevPlotBuilder.Build()

local function num(n) return string.format("%.4f", n) end
local function col(c) return "[" .. num(c.R) .. "," .. num(c.G) .. "," .. num(c.B) .. "]" end
local function esc(s) return (s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")) end

local counts = {}
local total = 0
local groups = folder:GetChildren()
local plaza = workspace:FindFirstChild("PlazaDecor")
if plaza then
	plaza.Name = "Plot1"
	table.insert(groups, plaza)
end
for _, plot in groups do
	local plotName = plot.Name
	for _, obj in plot:GetDescendants() do
		if obj:IsA("BasePart") then
			total += 1
			local item = "base"
			local p = obj.Parent
			while p and p ~= plot do
				if p.ClassName == "Model" then item = p.Name end
				p = p.Parent
			end
			if plotName == "Plot1" then
				counts[item] = (counts[item] or 0) + 1
				local cf = obj.CFrame
				local r = cf.r
				local shape = obj.Shape and obj.Shape.Name or "Block"
				if obj.ClassName == "WedgePart" then shape = "Wedge" end
				local mesh = obj:FindFirstChild("Mesh") or obj:FindFirstChildWhichIsA("SpecialMesh")
				if mesh then shape = "Ellipsoid" end
				local texts = {}
				for _, g in obj:GetChildren() do
					if g.ClassName == "SurfaceGui" then
						for _, l in g:GetChildren() do
							if l.ClassName == "TextLabel" then
								local reg = l.Position and l.Size and { l.Position[1], l.Position[3], l.Size[1], l.Size[3] } or { 0, 0, 1, 1 }
								table.insert(texts, string.format('{"face":"%s","text":"%s","color":%s,"glow":%s,"region":[%s,%s,%s,%s],"bgT":%s,"bg":%s}',
									g.Face.Name, esc(l.Text), col(l.TextColor3), tostring(g.LightInfluence == 0),
									num(reg[1]), num(reg[2]), num(reg[3]), num(reg[4]), num(l.BackgroundTransparency or 0), col(l.BackgroundColor3 or Color3.new(0,0,0))))
							end
						end
					end
				end
				local light = obj:FindFirstChildWhichIsA("PointLight")
				print(string.format('{"item":"%s","name":"%s","shape":"%s","size":[%s,%s,%s],"pos":[%s,%s,%s],"rot":[%s],"color":%s,"t":%s,"mat":"%s","texts":[%s],"light":%s}',
					item, esc(obj.Name), shape, num(obj.Size.X), num(obj.Size.Y), num(obj.Size.Z),
					num(cf.p.X), num(cf.p.Y), num(cf.p.Z),
					table.concat({ num(r[1]), num(r[2]), num(r[3]), num(r[4]), num(r[5]), num(r[6]), num(r[7]), num(r[8]), num(r[9]) }, ","),
					col(obj.Color or Color3.new(0.6, 0.6, 0.6)), num(obj.Transparency or 0), obj.Material and obj.Material.Name or "Plastic",
					table.concat(texts, ","), light and col(light.Color) or "null"))
			end
		end
	end
end
local keys = {}
for k in counts do table.insert(keys, k) end
table.sort(keys)
local line = {}
for _, k in keys do table.insert(line, k .. "=" .. counts[k]) end
print("#COUNTS " .. table.concat(line, " "))
print("#TOTAL all plots parts=" .. total)
