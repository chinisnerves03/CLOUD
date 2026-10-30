local M = {}
local eventEffects = require("turbocraft/eventEffects")
local popBang = require("turbocraft/popBang")

local STYLES = {
  dct = {volume = 1.0, pitch = 1.06},
  zf8 = {volume = 0.88, pitch = 0.98},
  automatic = {volume = 0.88, pitch = 0.98},
  mt = {volume = 0.68, pitch = 1.02},
  generic = {volume = 0.8, pitch = 1},
}
local DEFAULT_SHIFT_SOUND = "event:>Vehicle>Afterfire>01_Shift_EQ1"
local profile
local lastGear
local status = "transmission_unclassified"

local function finite(value)
  value = tonumber(value)
  return type(value) == "number" and value == value and math.abs(value) < math.huge and value or nil
end

local function forwardGearCount(data, deviceName)
  local device = data[deviceName] or data.gearbox
  local gearbox = device and (device.gearbox or device)
  local ratios = gearbox and gearbox.gearRatios
  if type(ratios) ~= "table" then return nil end
  if #ratios < 3 or not finite(ratios[1]) or finite(ratios[1]) >= 0
      or finite(ratios[2]) ~= 0 then return nil end
  for index = 3, #ratios do
    if not finite(ratios[index]) or finite(ratios[index]) <= 0 then return nil end
  end
  local count = #ratios - 2
  return count > 0 and count or nil
end

function M.classify(data)
  local powertrain = data and data.powertrain
  if type(powertrain) ~= "table" then return nil end
  local controller = data.vehicleController
  local hasAutomaticModes = type(controller) == "table"
    and type(controller.automaticModes) == "string" and controller.automaticModes ~= ""
  local gearboxCount, detected = 0, nil
  for _, row in pairs(powertrain) do
    if type(row) == "table" then
      local deviceType, deviceName = row[1] or row.type, row[2] or row.name
      if deviceType == "dctGearbox" or deviceType == "manualGearbox"
          or deviceType == "automaticGearbox" or deviceType == "sequentialGearbox"
          or deviceType == "cvtGearbox" then
        gearboxCount = gearboxCount + 1
        local candidate
        if deviceType == "dctGearbox" then candidate = "dct"
        elseif deviceType == "manualGearbox" then candidate = "mt"
        elseif deviceType == "automaticGearbox" or deviceType == "sequentialGearbox" and hasAutomaticModes then
          candidate = forwardGearCount(data, deviceName) == 8 and "zf8" or "automatic"
        end
        if not candidate or detected then return nil end
        detected = candidate
      end
    end
  end
  return gearboxCount == 1 and detected or nil
end

function M.configure(data, allowGeneric)
  profile = M.classify(data) or (allowGeneric and "generic" or nil)
  lastGear = nil
  status = profile == "generic" and "shift_audio_generic_ready"
    or profile and "shift_audio_profile_ready" or "transmission_unclassified"
  return profile ~= nil
end

function M.update(engine, values, data)
  values = values or {}
  local gear = finite(values.gearIndex)
  if not profile then status = "transmission_unclassified"; return end
  if not gear then lastGear = nil; status = "shift_gear_signal_unavailable"; return end
  local previousGear = lastGear
  lastGear = gear
  if not previousGear or previousGear <= 0 or gear <= 0 or gear == previousGear then return end

  local downshift = gear < previousGear
  local throttle = finite(values.throttle or engine and engine.instantEngineLoad)
  if not downshift and (not throttle or throttle < 0.3) then
    status = "shift_skipped_low_or_missing_load"
    return
  end
  eventEffects.flame(engine, data)
  popBang.playShift(downshift and "down" or "up", throttle or 0)
  if not obj or type(obj.playSFXOnceCT) ~= "function" then
    status = "shift_audio_api_unavailable"
    return
  end

  local engineData = data and data.mainEngine or {}
  local event = type(engineData.shiftAfterFireSound) == "string" and engineData.shiftAfterFireSound ~= ""
    and engineData.shiftAfterFireSound or DEFAULT_SHIFT_SOUND
  local baseVolume = math.max(0, math.min(8, finite(engineData.shiftAfterFireVolumeCoef) or 4))
  local audibleThreshold = math.max(0, finite(engineData.afterFireAudibleThresholdShift) or 250000)
  local nativeShiftFuel = math.max(0, finite(engine and engine.shiftAfterFireFuel) or 0)
  local style = STYLES[profile]
  local endpoints = engine and engine.thermals and engine.thermals.exhaustEndNodes
  if type(endpoints) ~= "table" or #endpoints == 0 then
    local engineNode = finite(engine and engine.engineNodeID)
    if engineNode then
      obj:playSFXOnceCT(event, engineNode, baseVolume * style.volume, style.pitch, 1, 0)
      status = "shift_audio_play_call_issued_engine_fallback"
    else
      status = "shift_exhaust_endpoints_unavailable"
    end
    return
  end

  local played, nativeOwned = 0, false
  for _, endpoint in ipairs(endpoints) do
    if type(endpoint) == "table" and finite(endpoint.finish) then
      local submerged = type(obj.inWater) == "function" and obj:inWater(endpoint.finish)
      if not submerged then
        local audioCoef = math.max(0, finite(endpoint.afterFireAudioCoef) or 1)
        if nativeShiftFuel * audioCoef > audibleThreshold then
          nativeOwned = true
        else
          local volume = baseVolume * style.volume * math.max(0, finite(endpoint.afterFireVolumeCoef) or 1)
          local muffling = math.max(0, math.min(1, finite(endpoint.afterFireMufflingCoef) or 0))
          obj:playSFXOnceCT(event, endpoint.finish, volume, style.pitch, 1 - muffling, 0)
          played = played + 1
        end
      end
    end
  end
  status = played > 0 and ("shift_audio_play_call_issued_" .. played)
    or nativeOwned and "native_shift_afterfire_owns_event"
    or "shift_exhaust_unavailable_or_submerged"
end

function M.onReset()
  lastGear = nil
end

function M.getProfile() return profile end
function M.getStatus() return status end

return M
