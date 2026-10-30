-- TurboCraft turbocharger: fits the TurboCraft turbo to the engine it is bolted to, then runs BeamNG's own
-- powertrain/turbocharger with the scaled data. Selected by the TurboCraft intake through
-- mainEngine.turbochargerLuaFileName, so no game file is replaced.
--
-- The turbo numbers are calibrated on the reference engine (Gavril 4.5 V8, 5600 rpm runtime limit).
--   rpm:    the housing curves (engineDef) are stretched to this engine's rev range, so a matched turbo
--           spools at the same fraction of redline on a 7000 rpm I4 as on a 3800 rpm diesel.
--   energy: maxExhaustPower follows the engine's airflow (power proxy = max torque * rpm) relative to the
--           engine the slot's parts were sized for (turbocraftSlotPower), so a 6.9 V8 spools a given wheel
--           sooner than the 4.5 sharing its intake slot.
local M = {}
local bovAudio = require("turbocraft/bovAudio")

M.REF_MAX_RPM = 5600
local MIN_ENERGY, MAX_ENERGY = 0.25, 4
local vanilla

local function finiteNumber(value)
  value = tonumber(value)
  return value and value == value and value ~= math.huge and value ~= -math.huge and value or nil
end

-- max torque * rpm over a jbeam torque table ([["rpm","torque"], [0, 0], ...] or rows of {rpm=, torque=})
function M.powerProxy(rows, maxRPM)
  local best = 0
  for _, r in ipairs(type(rows) == "table" and rows or {}) do
    local rpm, tq
    if type(r) == "table" then
      rpm, tq = r.rpm or r[1], r.torque or r[2]
    end
    if type(rpm) == "number" and type(tq) == "number" and (not maxRPM or rpm <= maxRPM) then
      best = math.max(best, rpm * tq)
    end
  end
  return best
end

local function validateEnergyCurve(curve, name)
  if type(curve) ~= "table" or #curve < 2 then
    return nil, name .. "_invalid_shape"
  end
  local previous = -1
  for _, row in ipairs(curve) do
    if type(row) ~= "table" or type(row[1]) ~= "number" or type(row[2]) ~= "number"
      or row[1] ~= row[1] or row[1] == math.huge or row[1] == -math.huge
      or row[1] < 0 or row[1] > 1 or row[1] <= previous
      or row[2] <= 0 or row[2] ~= row[2] or row[2] == math.huge then
      return nil, name .. "_invalid_point"
    end
    previous = row[1]
  end
  return curve
end

local function curveValue(curve, fraction)
  if fraction <= curve[1][1] then return curve[1][2] end
  for i = 2, #curve do
    local left, right = curve[i - 1], curve[i]
    if fraction <= right[1] then
      local amount = (fraction - left[1]) / (right[1] - left[1])
      return left[2] + (right[2] - left[2]) * amount
    end
  end
  return curve[#curve][2]
end

local function applyEnergyCurves(data, deviceMaxRPM, info)
  local profiles = {}
  for _, name in ipairs({"turbocraftHeaderEnergyCurve", "turbocraftPipeEnergyCurve", "turbocraftHeaderEfficiencyCurve"}) do
    if data[name] ~= nil then
      local profile, err = validateEnergyCurve(data[name], name)
      if profile then profiles[#profiles + 1] = {curve = profile, column = name == "turbocraftHeaderEfficiencyCurve" and 2 or 3}
      else info.curveErrors[#info.curveErrors + 1] = err end
      data[name] = nil
    end
  end
  if #profiles == 0 then return end
  if type(data.engineDef) ~= "table" then
    info.curveErrors[#info.curveErrors + 1] = "engineDef_missing"
    return
  end

  local curveMaxRPM = tonumber(deviceMaxRPM)
  if not curveMaxRPM or curveMaxRPM <= 0 then
    for _, row in ipairs(data.engineDef) do
      if type(row) == "table" and type(row[1]) == "number" then
        curveMaxRPM = math.max(curveMaxRPM or 0, row[1])
      end
    end
  end
  if not curveMaxRPM or curveMaxRPM <= 0 then
    info.curveErrors[#info.curveErrors + 1] = "engineDef_rpm_missing"
    return
  end

  for _, row in ipairs(data.engineDef) do
    if type(row) == "table" and type(row[1]) == "number" and type(row[3]) == "number" then
      local fraction = math.max(0, math.min(1, row[1] / curveMaxRPM))
      local factors = {[2] = 1, [3] = 1}
      for _, profile in ipairs(profiles) do
        local column = profile.column
        factors[column] = factors[column] * curveValue(profile.curve, fraction)
      end
      for column, factor in pairs(factors) do
        if type(row[column]) == "number" then row[column] = math.max(0, math.min(1, row[column] * factor)) end
      end
    end
  end
end

-- returns a scaled copy of the TurboCraft turbo data and what was applied
function M.scale(data, engineData, deviceMaxRPM)
  local out = deepcopy(data)
  local info = {energy = 1, rpm = 1, curveErrors = {}}
  if type(out) ~= "table" then return out, info end

  local maxRPM = tonumber(deviceMaxRPM)
  if maxRPM and maxRPM > 0 and out.turbocraftRpmScale ~= false then
    info.rpm = maxRPM / M.REF_MAX_RPM
    if type(out.engineDef) == "table" then
      local rows = {}
      for i, row in ipairs(out.engineDef) do
        if type(row) == "table" and type(row[1]) == "number" then
          rows[#rows + 1] = {row[1] * info.rpm, row[2], row[3]}
        elseif i == 1 then
          rows[#rows + 1] = row -- header row, if the table still has one
        end
      end
      out.engineDef = rows
    end
  end

  applyEnergyCurves(out, maxRPM, info)

  local slotPower = tonumber(out.turbocraftSlotPower)
  if slotPower and slotPower > 0 and type(engineData) == "table" then
    local p = M.powerProxy(engineData.torque, tonumber(engineData.maxRPM))
    if p > 0 then
      info.energy = math.min(MAX_ENERGY, math.max(MIN_ENERGY, p / slotPower))
      info.enginePower = p
    end
  end
  out.maxExhaustPower = (tonumber(out.maxExhaustPower) or 1) * info.energy
  out.turbocraftEnergyScale = info.energy
  out.turbocraftRpmScale = info.rpm
  return out, info
end

function M.updateGFX(dt)
  if vanilla then
    local result = vanilla.updateGFX(dt)
    bovAudio.update(dt, M.turbocraftEngine)
    return result
  end
end

function M.reset(jbeamData)
  bovAudio.configure(jbeamData, M.turbocraftEngine)
  if type(jbeamData) ~= "table" or jbeamData.bovEnabled == false then
    return vanilla.reset(jbeamData)
  end
  local muted = deepcopy(jbeamData)
  muted.bovSoundVolumeCoef = 0
  return vanilla.reset(muted)
end

function M.init(device, jbeamData)
  vanilla = rerequire("powertrain/turbocharger")
  setmetatable(M, {__index = vanilla})
  local engineData = v and v.data and device and v.data[device.name]
  local scaled, info = M.scale(jbeamData, engineData, device and device.maxRPM)
  M.turbocraftEngine = device
  bovAudio.configure(scaled, device)
  -- Keep native valve physics, but mute its load-drop cue. That cue can fire on
  -- limiter/ignition cuts while the driver still holds the throttle open.
  if type(scaled) == "table" and scaled.bovEnabled ~= false then
    scaled.bovSoundVolumeCoef = 0
  end
  M.turbocraftScale = info
  log("I", "TurboCraft", string.format("turbo fitted to %s: rpm x%.3f, exhaust energy x%.3f",
    tostring(device and device.name), info.rpm, info.energy))
  if #info.curveErrors > 0 then
    log("W", "TurboCraft", "exhaust energy profile not applied: " .. table.concat(info.curveErrors, ", "))
  end
  return vanilla.init(device, scaled)
end

return M
