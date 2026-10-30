-- TurboCraft part generator core (pure Lua, no game API): finds every combustion engine's intake slot in the
-- loaded jbeam files and adds ONE "TurboCraft" part to every existing intake slot.  That part carries
-- the donor turbo mesh and a "TurboCraft System" child slot holding the fixed system + Stage kits;
-- every kit owns its complete turbo/supercharger preset, so the game's Intake list stays short.
-- The GE extension turbocraftGen does the file IO. Physics scaling to the exact engine happens at spawn time in
-- lua/vehicle/turbocraft/turbocharger.lua.
local M = {}

M.PREFIX = "turbocraft_auto_"
M.MAX_MANIFOLDS = 6
M.SYSTEM_PREFIX = "turbocraft_system_"

local function lower(s) return string.lower(tostring(s or "")) end
local function isIntakeType(t) return type(t) == "string" and lower(t):find("intake", 1, true) ~= nil end
local function key(s) return (lower(s):gsub("[^%w]", "_")) end
local function isEnginePart(name, part)
  return (lower(name) .. " " .. lower(part.slotType)):find("engine", 1, true) ~= nil
end

local function copy(t)
  if type(t) ~= "table" then return t end
  local r = {}
  for k, v in pairs(t) do r[k] = copy(v) end
  return r
end

-- BeamNG 0.39 can store a part name as a localization object instead of a string, e.g.
-- {txt = "ui.vehicleconfig.information.name.BRAND Intake", ctx = {brand1 =
-- "ui.vehicleconfig.brand.Rennspecht"}}.  Generated JBeam cannot prefix that table directly,
-- because tostring(table) produces the user-visible "table: 0x..." label.
local function localizationTail(value)
  if type(value) ~= "string" then return nil end
  return value:match("([^%.]+)$") or value
end

function M.displayName(value, fallback)
  if type(value) == "string" and value ~= "" then return value end
  if type(value) == "table" then
    local label = localizationTail(value.txt)
    if label then
      for contextKey, contextValue in pairs(type(value.ctx) == "table" and value.ctx or {}) do
        local token = string.upper(tostring(contextKey):gsub("%d+$", ""))
        local replacement = localizationTail(contextValue)
        if token ~= "" and replacement then label = label:gsub(token, replacement) end
      end
      if label ~= "" then return label end
    end
    for _, candidate in ipairs({value.name, value.default, value.en, value[1]}) do
      if type(candidate) == "string" and candidate ~= "" then return localizationTail(candidate) end
    end
  end
  return tostring(fallback or "Unknown Intake")
end

function M.namespaceOf(filename)
  return string.match(lower(filename):gsub("\\", "/"), "^/?vehicles/([^/]+)/")
end

-- defaults of a raw jbeam "variables" table: {["$torque"] = 1.0, ...}
function M.variableDefaults(part)
  local vars = {}
  local tbl = type(part) == "table" and part.variables
  if type(tbl) == "table" and type(tbl[1]) == "table" then
    local col = {}
    for i, name in ipairs(tbl[1]) do if type(name) == "string" then col[name] = i end end
    for i = 2, #tbl do
      local row = tbl[i]
      if type(row) == "table" and type(row[col.name or 1]) == "string" then
        local def = tonumber(row[col.default or 5])
        if def then vars[row[col.name or 1]] = def end
      end
    end
  end
  return vars
end

-- a number, or a jbeam "$=" expression / "$var" using the part's variable defaults; nil if it cannot be resolved
function M.evalNumber(value, vars)
  if type(value) == "number" then return value end
  if type(value) ~= "string" then return nil end
  local expr = value:gsub("^%$=", "")
  expr = expr:gsub("%$[%w_]+", function(name) return vars[name] and string.format("(%.17g)", vars[name]) or nil end)
  if not expr:match("^[%d%.%s%+%-%*/%(%)eE]+$") then return nil end
  local fn = (loadstring or load)("return " .. expr) -- digits and operators only (checked above)
  if not fn then return nil end
  local ok, n = pcall(fn)
  return ok and type(n) == "number" and n == n and math.abs(n) < 1e12 and n or nil
end

-- max torque * rpm (same proxy as the vehicle-side turbocharger wrapper)
function M.powerProxy(rows, maxRPM, vars)
  local best = 0
  for _, r in ipairs(type(rows) == "table" and rows or {}) do
    if type(r) == "table" then
      local rpm, tq = r.rpm or r[1], r.torque or r[2]
      if vars then rpm, tq = M.evalNumber(rpm, vars), M.evalNumber(tq, vars) end
      if type(rpm) == "number" and type(tq) == "number" and (not maxRPM or rpm <= maxRPM) then
        best = math.max(best, rpm * tq)
      end
    end
  end
  return best
end

-- slot rows of a raw jbeam part: {{type=, default=}} for both "slots" and "slots2" formats
function M.slotRows(part)
  local out = {}
  for _, field in ipairs({"slots", "slots2"}) do
    local tbl = part[field]
    if type(tbl) == "table" and type(tbl[1]) == "table" then
      local header = tbl[1]
      local col = {}
      for i, name in ipairs(header) do if type(name) == "string" then col[name] = i end end
      for i = 2, #tbl do
        local row = tbl[i]
        if type(row) == "table" and type(row[1]) == "string" then
          if field == "slots" then
            out[#out + 1] = {types = {row[col.type or 1]}, default = row[col.default or 2]}
          else
            local allow = row[col.allowTypes or 2]
            out[#out + 1] = {types = type(allow) == "table" and allow or {allow}, default = row[col.default or 4]}
          end
        end
      end
    end
  end
  return out
end

local function slotTypesOf(part)
  if type(part.slotType) == "table" then return part.slotType end
  return {part.slotType}
end

local FORCED_WORDS = {"turbo", "supercharg", "twincharg", "blower", "procharg"}
local function isForced(partName, part)
  local me = type(part.mainEngine) == "table" and part.mainEngine or {}
  if me.turbocharger or me.supercharger or part.turbocharger or part.supercharger then return true end
  local n = lower(partName) .. " " .. lower(type(part.information) == "table" and part.information.name)
  for _, w in ipairs(FORCED_WORDS) do if n:find(w, 1, true) then return true end end
  return false
end

-- files: array of {name = "/vehicles/x/y.jbeam", data = parsed table}
function M.collect(files)
  local index = {engines = {}, intakes = {}, covered = {}}
  for _, f in ipairs(files) do
    local ns = M.namespaceOf(f.name)
    local generated = lower(f.name):find("/turbocraft_auto/", 1, true) ~= nil
    if ns and type(f.data) == "table" and not generated then
      for partName, part in pairs(f.data) do
        if type(part) == "table" then
          local me = part.mainEngine
          local intakeSlots = {}
          for _, row in ipairs(M.slotRows(part)) do
            for _, t in ipairs(row.types) do
              if isIntakeType(t) then intakeSlots[#intakeSlots + 1] = {type = t, default = row.default} end
            end
          end
          -- Some vehicles put torque on a long-block child rather than the engine part that owns
          -- Intake.  Keep that slot even when its power is unknown; build() uses refPower until
          -- the fitted engine can be measured and scaled at spawn time.
          if #intakeSlots > 0 and (type(me) == "table" or isEnginePart(partName, part)) then
            local vars = M.variableDefaults(part)
            local maxRPM = M.evalNumber(type(me) == "table" and me.maxRPM, vars)
            index.engines[#index.engines + 1] = {
              ns = ns, name = partName, file = f.name, slots = intakeSlots,
              maxRPM = maxRPM, power = M.powerProxy(type(me) == "table" and me.torque, maxRPM, vars),
              diesel = type(me) == "table" and lower(me.requiredEnergyType) == "diesel",
              label = type(part.information) == "table" and part.information.name or partName,
            }
          end
          for _, st in ipairs(slotTypesOf(part)) do
            if isIntakeType(st) then
              if lower(partName):sub(1, 11) == "turbocraft_" then
                index.covered[st] = true
              else
                index.intakes[st] = index.intakes[st] or {}
                table.insert(index.intakes[st], {ns = ns, name = partName, part = part, forced = isForced(partName, part)})
              end
            end
          end
        end
      end
    end
  end
  local seen = {}
  for _, engine in ipairs(index.engines) do
    for _, slot in ipairs(engine.slots) do seen[slot.type] = true end
  end
  -- Mod engines need not use "engine" in their part name.  An intake part that changes
  -- mainEngine or carries a forced-induction device identifies an engine intake slot even
  -- when its owning engine and torque table cannot be found in the raw JBeam files.
  for slotType, candidates in pairs(index.intakes) do
    if not seen[slotType] and not index.covered[slotType] then
      for _, candidate in ipairs(candidates) do
        local part = candidate.part
        if type(part.mainEngine) == "table" or part.turbocharger or part.supercharger then
          index.engines[#index.engines + 1] = {ns = candidate.ns, name = candidate.name,
            slots = {{type = slotType}}, power = 0, diesel = false, inferred = true}
          break
        end
      end
    end
  end
  return index
end

local function median(list)
  table.sort(list)
  if #list == 0 then return nil end
  return list[math.floor((#list + 1) / 2)]
end

local function interp(rows, x)
  if x <= rows[1][1] then return rows[1][2] end
  for i = 2, #rows do
    if x <= rows[i][1] then
      local a, b = rows[i - 1], rows[i]
      return a[2] + (b[2] - a[2]) * (x - a[1]) / (b[1] - a[1])
    end
  end
  return rows[#rows][2]
end

local function manifoldPart(src, slotType, orderValue)
  local p = copy(src.part)
  -- The generated parent now owns the donor turbo's visible mesh and structure.  Manifold
  -- children retain tuning/sound data only, avoiding duplicate nodes and overlapping meshes.
  for _, k in ipairs({"flexbodies", "nodes", "beams", "triangles", "quads", "props", "hydros", "torsionbars"}) do p[k] = nil end
  p.slotType = slotType
  p.turbocharger, p.supercharger = nil, nil
  if type(p.mainEngine) == "table" then
    for _, k in ipairs({"turbocharger", "supercharger", "turbochargerLuaFileName", "superchargerLuaFileName"}) do p.mainEngine[k] = nil end
  end
  local info = type(p.information) == "table" and p.information or {}
  p.information = {authors = "TurboCraft Project (mesh: " .. tostring(info.authors or "original author") .. ")",
    name = M.displayName(info.name, src.name), value = info.value or orderValue}
  return p
end

-- returns {byNamespace = {ns = {partName = part}}, report = {...}}
function M.build(index, data)
  if type(data) ~= "table" or type(data.hardwareKits) ~= "table" or #data.hardwareKits == 0 then
    error("TurboCraft hardware-size catalog is missing or empty")
  end
  local bySlot = {}
  for _, e in ipairs(index.engines) do
    for _, s in ipairs(e.slots) do
      if not index.covered[s.type] then
        local entry = bySlot[s.type] or {type = s.type, engines = {}, defaults = {}, namespaces = {}}
        bySlot[s.type] = entry
        table.insert(entry.engines, e)
        if s.default then entry.defaults[s.default] = true end
        entry.namespaces[e.ns] = true
      end
    end
  end

  local out, report = {}, {}
  local slotNames = {}
  for st in pairs(bySlot) do slotNames[#slotNames + 1] = st end
  table.sort(slotNames)

  for _, st in ipairs(slotNames) do
    local entry = bySlot[st]
    -- one generated set per slot type; written to common if any engine lives there, else to that vehicle
    local nsList = {}
    for n in pairs(entry.namespaces) do nsList[#nsList + 1] = n end
    table.sort(nsList)
    local ns = entry.namespaces.common and "common" or nsList[1]
    local powers, maxRPMs, diesel = {}, {}, 0
    for _, e in ipairs(entry.engines) do
      if e.power > 0 then powers[#powers + 1] = e.power end
      if e.maxRPM then maxRPMs[#maxRPMs + 1] = e.maxRPM end
      if e.diesel then diesel = diesel + 1 end
    end
    -- unresolvable torque tables (tuning-dependent expressions): size the parts for the reference engine;
    -- the vehicle-side wrapper still scales to the real engine at spawn
    local slotPower = median(powers) or data.refPower
    local repRPM = median(maxRPMs) or data.refMaxRPM
    local isDiesel = diesel * 2 > #entry.engines
    if slotPower > 0 then
      local k = slotPower / data.refPower
      local sk = key(st)
      local base = M.PREFIX .. sk
      local parts = out[ns] or {}
      out[ns] = parts
      -- Reuse a stock forced-induction part as the visual/structural donor.  This makes the
      -- universal kit display vehicle-correct turbos, headers, intercooler and charge pipes.
      local forced = {}
      for _, src in ipairs(index.intakes[st] or {}) do
        if src.forced then forced[#forced + 1] = src end
      end
      table.sort(forced, function(a, b) return a.name < b.name end)
      local donor
      for _, candidate in ipairs(forced) do
        local authors = type(candidate.part.information) == "table" and candidate.part.information.authors or ""
        if lower(authors):find("beamng", 1, true) then donor = candidate break end
      end
      donor = donor or forced[1]
      -- One "TurboCraft" entry in the intake slot (donor mesh, no forced-induction device of its
      -- own) keeps the game's Intake list tidy; systems and size kits live in child slots.
      local intake = donor and copy(donor.part) or {}
      intake.turbocharger, intake.supercharger = nil, nil
      local parentEngine = type(intake.mainEngine) == "table" and intake.mainEngine or {}
      -- The visual donor can select an entirely different engine/exhaust sample bank.
      -- Keep the fitted engine's identity; induction audio is handled independently.
      for _, soundKey in ipairs({"soundConfig", "soundConfigExhaust"}) do
        local donorConfig = parentEngine[soundKey]
        if type(donorConfig) == "string" then intake[donorConfig] = nil end
        parentEngine[soundKey], intake[soundKey] = nil, nil
      end
      for _, keyName in ipairs({"turbocharger", "supercharger", "turbochargerLuaFileName", "superchargerLuaFileName"}) do parentEngine[keyName] = nil end
      intake.mainEngine = next(parentEngine) and parentEngine or nil
      local systemSlot = M.SYSTEM_PREFIX .. sk
      local kits = data.hardwareKits
      local default = kits[1] and (base .. "_" .. kits[1].family) or ""
      intake.information = {authors = "TurboCraft Project", name = "TurboCraft", value = data.kitBaseValue or 300}
      intake.slotType, intake.slots = st, nil
      intake.slots2 = {{"name", "allowTypes", "denyTypes", "default", "description"},
        {systemSlot, {systemSlot}, {}, default, "Forced Induction"}}
      parts[base] = intake
      local families = {}
      for _, preset in ipairs(kits) do
        local familyName = base .. "_" .. preset.family
        local sizeSlot = "turbocraft_size_" .. sk .. "_" .. preset.family
        if not families[preset.family] then
          families[preset.family] = true
          local defaultHardware = preset
          for _, candidate in ipairs(kits) do
            if candidate.family == preset.family and candidate.default then
              defaultHardware = candidate
              break
            end
          end
          local sizeLabel = "Centrifugal Size"
          if preset.device == "turbo" then
            sizeLabel = "Turbo Size"
          elseif preset.supercharger and preset.supercharger.type == "roots" then
            sizeLabel = "Blower Size"
          end
          parts[familyName] = {
            information = {authors = "TurboCraft Project", name = preset.label, value = data.kitBaseValue or 300},
            slotType = systemSlot,
            slots2 = {{"name", "allowTypes", "denyTypes", "default", "description"},
              {sizeSlot, {sizeSlot}, {}, familyName .. "_size_" .. defaultHardware.hardwareId, sizeLabel}}
          }
        end
        local kit = {information = {authors = "TurboCraft Project", value = preset.value, name = preset.name},
          slotType = sizeSlot}
        if preset.device == "supercharger" then
          kit.supercharger = copy(preset.supercharger)
          kit.mainEngine = {supercharger = "supercharger"}
          local audioLabel = preset.supercharger.type == "roots"
            and "Roots Supercharger Sound Level" or "ProCharger Sound Level"
          kit.slots2 = {{"name", "allowTypes", "denyTypes", "default", "description"},
            {data.pulleySlot, {data.pulleySlot}, {}, data.pulleySlot .. "_standard", "Pulley / Drive Ratio"},
            {data.blowerAudioSlot, {data.blowerAudioSlot}, {},
              data.blowerAudioSlot .. "_loud", audioLabel}}
        else
          local turbo = copy(preset.turbocharger)
          local defaultBoost = tonumber(turbo.wastegateStart)
          if defaultBoost then
            kit.variables = {{"name", "type", "unit", "category", "default", "min", "max", "title", "description"},
              {"$turbocraftBoost", "range", "psi", "Engine", defaultBoost, 0, 200,
                "TurboCraft Boost", "Requested wastegate pressure; actual boost depends on the turbo and engine", {stepDis = 0.5}}}
            turbo.wastegateStart = "$turbocraftBoost"
            turbo.wastegateLimit = "$=$turbocraftBoost+0.5"
          end
          turbo.turbocraftSlotPower = slotPower
          turbo.turbocraftSizeMm = preset.wheelMm
          kit.turbocharger = turbo
          kit.mainEngine = {turbocharger = "turbocharger", turbochargerLuaFileName = "turbocraft/turbocharger"}
          kit.slots2 = {{"name", "allowTypes", "denyTypes", "default", "description"},
            {data.headerSlot, {data.headerSlot}, {}, preset.headerDefault, "Header"},
            {data.exhaustSlot, {data.exhaustSlot}, {}, preset.exhaustDefault, "Exhaust"}}
          if data.coverSlot then
            kit.slots2[#kit.slots2 + 1] = {
              data.coverSlot, {data.coverSlot}, {}, preset.coverDefault or data.coverDefault,
              "Compressor Cover · Front A/R"}
          end
          if data.turbineSlot then
            kit.slots2[#kit.slots2 + 1] = {
              data.turbineSlot, {data.turbineSlot}, {}, preset.turbineDefault or data.turbineDefault,
              "Turbine Housing · Rear A/R"}
          end
          kit.slots2[#kit.slots2 + 1] = {
            data.bovSlot, {data.bovSlot}, {}, data.bovSlot .. "_" .. (turbo.turbocraftBov or "tuned"), "Blow-Off Valve Sound"}
          kit.slots2[#kit.slots2 + 1] = {
            data.wastegateSlot, {data.wastegateSlot}, {}, data.wastegateSlot .. "_standard", "Wastegate · Gauge Controlled"}
          kit.slots2[#kit.slots2 + 1] = {
            data.audioSlot, {data.audioSlot}, {}, data.audioSlot .. "_loud", "Turbo Sound Level"}
          if data.responseSlot then
            kit.slots2[#kit.slots2 + 1] = {
              data.responseSlot, {data.responseSlot}, {}, data.responseDefault or data.responseSlot .. "_balanced",
              "Spool Response"}
          end
        end
        if not isDiesel then
          kit.slots2[#kit.slots2 + 1] = {data.effectsSlot, {data.effectsSlot}, {}, data.effectsSlot .. "_drift", "Exhaust Flames & Pops"}
        end
        parts[base .. "_" .. preset.family .. "_size_" .. preset.hardwareId] = kit
      end

      local engineNames = {}
      for _, e in ipairs(entry.engines) do engineNames[#engineNames + 1] = e.ns .. "/" .. e.name end
      table.sort(engineNames)
      report[#report + 1] = {slot = st, ns = ns, engines = engineNames, k = k, rpm = repRPM, diesel = isDiesel, estimated = #powers == 0,
        hardwareOptions = #(data.hardwareKits or {})}
    end
  end
  return {byNamespace = out, report = report}
end

return M
