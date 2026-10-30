local M = {}
local core = require("turbocraft/core")
local enabled = false
local config
local cabinInside = false
local cache, loopSources = {}, {}
local loopLevels, loopPitches, loopPlaying = {}, {}, {}
local status = "disabled"

local function finite(value) return core.isFinite(tonumber(value)) and tonumber(value) or nil end

local function stop()
  if config then config.previousLoad, config.previousPressure = nil, nil end
  if obj then
    for key, source in pairs(loopSources) do
      if type(obj.setVolumePitch) == "function" then obj:setVolumePitch(source, 0, 1) end
      if loopPlaying[key] and type(obj.stopSFX) == "function" then obj:stopSFX(source) end
    end
  end
  loopLevels, loopPitches, loopPlaying = {}, {}, {}
end

local function unavailable(reason)
  stop()
  status = reason
  if log then log("W", "TurboCraftAudio", reason) end
  return false, reason
end

local function tierFor(kit)
  local family = tostring(kit and kit.family or "")
  return family:find("large_", 1, true) == 1 and "large"
    or family:find("big_", 1, true) == 1 and "big" or "small"
end

local function getSource(file, description, node)
  local key = file .. ":" .. description .. ":" .. tostring(node)
  local id = cache[key]
  if id ~= nil then return id end
  local ok, created = pcall(obj.createSFXSource2, obj, file, description,
    "TurboCraftOriginal_" .. file:gsub("[^%w]", "_"), node, -1)
  if not ok or not finite(created) or created < 0 then
    return nil, "original_audio_source_creation_failed:" .. tostring(created)
  end
  cache[key] = created
  return created
end

local function addLoop(file, node)
  local source, err = getSource("art/sound/turbocraft/" .. file .. ".wav",
    "AudioDefaultLoop3D", node)
  if not source then return nil, err end
  return source
end

function M.configure(data, node)
  stop()
  config, loopSources = nil, {}
  if not enabled then status = "disabled"; return false end
  local turbo = data and data.turbocharger
  local sc = data and data.supercharger
  local kit = turbo and turbo.turbocraftKit or sc and sc.turbocraftKit
  local kind = turbo and turbo.turbocraftKit and "turbo"
    or sc and sc.turbocraftKit and (sc.type == "roots" or sc.type == "centrifugal") and "blower"
  if not kind or not kit then return unavailable("original_audio_requires_turbocraft_induction") end
  if not obj or type(obj.createSFXSource2) ~= "function" or type(obj.setVolumePitch) ~= "function"
      or type(obj.playSFX) ~= "function" or type(obj.stopSFX) ~= "function" then
    return unavailable("original_audio_api_unavailable")
  end
  node = finite(node)
  if not node or node < 0 then
    return unavailable("original_audio_drive_or_node_unavailable")
  end

  local tier = tierFor(kit)
  local deviceData = kind == "blower" and sc or turbo
  if deviceData.turbocraftManagedInductionAudio == true then
    local audioKind = kind == "blower" and sc.type or "turbo"
    local airVolume = math.max(0, finite(deviceData.turbocraftAirVolume) or 1)
      * math.max(0, finite(deviceData.turbocraftIntakeVolume) or 1)
    local whine, err = addLoop(audioKind .. "_" .. tier, node)
    if not whine then return unavailable(err) end
    local air, airError = addLoop("hiss_" .. tier, node)
    if not air then return unavailable(airError) end
    loopSources.whine, loopSources.hiss = whine, air
    if kind == "turbo" then
      local peak, peakError = addLoop("turbo_peak", node)
      if not peak then return unavailable(peakError) end
      loopSources.peak = peak
    end
    config = {
      kind = kind, tier = tier, managed = true, blowerType = sc and sc.type,
      spoolVolume = math.max(0, math.min(2, finite(deviceData.turbocraftSpoolVolume) or 1)),
      airVolume = math.min(2, airVolume),
      cabinGain = 10 ^ (math.max(0, math.min(12, finite(deviceData.turbocraftCabinGainDB) or 6)) / 20),
      ratio = finite(sc and sc.gearRatio) or 1,
      audioDriveRatio = finite(sc and sc.turbocraftAudioDriveRatio)
        or (sc and sc.type == "roots" and 2.36 or 4.10),
      audioMaxShaftRPM = finite(sc and sc.turbocraftAudioMaxShaftRPM)
        or (sc and sc.type == "roots" and 14600 or 65000),
      audioInputReferenceRPM = finite(sc and sc.turbocraftAudioInputReferenceRPM) or 4000,
      releaseCount = 0,
      peakBoost = finite(turbo and turbo.wastegateStart) or 8,
      peakHardwareCeiling = turbo and type(turbo.pressurePSI) == "table"
        and type(turbo.pressurePSI[#turbo.pressurePSI]) == "table"
        and finite(turbo.pressurePSI[#turbo.pressurePSI][2]) or nil,
    }
    if kind == "blower" and sc.type == "centrifugal" then
      local releaseFile = "art/sound/turbocraft/bov_atmospheric_" .. tier .. ".wav"
      local releaseSource, releaseError = getSource(releaseFile, "AudioDefault3D", node)
      if releaseSource then
        config.releaseSource = releaseSource
        config.releaseVolume = math.min(1, config.airVolume * .65)
        obj:setVolumePitch(releaseSource, config.releaseVolume, 1)
      elseif log then
        log("W", "TurboCraftAudio", releaseError)
      end
    end
    for _, source in pairs(loopSources) do obj:setVolumePitch(source, 0, 1) end
    status = "ready_managed_original_induction"
    return true
  end
  local fitted = {}
  if kind == "blower" then
    local ratio = finite(sc.gearRatio)
    if not ratio or ratio <= 0 then return unavailable("original_audio_drive_or_node_unavailable") end
    local air, airErr = addLoop("hiss_" .. tier, node)
    if not air then return unavailable(airErr) end
    loopSources.hiss = air
    local whine, err = addLoop(sc.type .. "_" .. tier, node)
    if not whine then return unavailable(err) end
    loopSources.whine = whine
    fitted = {kind = kind, ratio = ratio, tier = tier, blowerType = sc.type,
      spoolVolume = math.max(0, math.min(2, finite(sc.turbocraftSpoolVolume) or 1)),
      airVolume = math.max(0, math.min(2, finite(sc.turbocraftAirVolume) or 1)),
      cabinGain = 10 ^ (math.max(0, math.min(12, finite(sc.turbocraftCabinGainDB) or 6)) / 20)}
  else
    local whine, err = addLoop("turbo_" .. tier, node)
    if not whine then return unavailable(err) end
    loopSources.whine = whine
    local hiss
    hiss, err = addLoop("hiss_" .. tier, node)
    if not hiss then return unavailable(err) end
    loopSources.hiss = hiss
    fitted = {kind = kind, tier = tier}
  end
  for _, source in pairs(loopSources) do obj:setVolumePitch(source, 0, 1) end
  config = fitted
  status = "ready_induction_overlay_native_valve_events"
  return true
end

local function setLoop(key, target, targetPitch, dt, timeConstant)
  local source = loopSources[key]
  if not source then return end
  local current = loopLevels[key] or 0
  current = current + (target - current) * (1 - math.exp(-math.min(dt, .1) / timeConstant))
  local currentPitch = loopPitches[key] or targetPitch
  currentPitch = currentPitch + (targetPitch - currentPitch)
    * (1 - math.exp(-math.min(dt, .1) / .04))
  loopLevels[key] = current
  loopPitches[key] = currentPitch
  obj:setVolumePitch(source, current, currentPitch)
  if current > .001 and not loopPlaying[key] then
    obj:playSFX(source)
    loopPlaying[key] = true
  elseif current <= .001 and loopPlaying[key] then
    obj:stopSFX(source)
    loopPlaying[key] = false
  end
end

local function measuredTurboRPM(values)
  return finite(values.turboRPM or values.turboRpm or values.turborpm)
end

function M.setEnabled(value, data, node)
  if type(value) ~= "boolean" then return false, "original_audio_enable_requires_boolean" end
  enabled = value
  if not value then stop(); config = nil; status = "disabled"; return true end
  return M.configure(data, node)
end

function M.update(dt, engine, values, targetBoostPsi)
  if not enabled or not config then return end
  dt = finite(dt)
  values = values or {}
  local av = engine and finite(engine.outputAV1)
  local load = finite(values.engine_load or values.throttle)
  if not dt or dt <= 0 or not av or not load then
    stop()
    status = "original_audio_rpm_or_load_missing"
    return
  end
  local rpm = math.abs(av) * 30 / math.pi
  local active = config.kind == "blower"
    and engine.supercharger and engine.supercharger.isExisting
    or config.kind == "turbo" and engine.turbocharger and engine.turbocharger.isExisting
  if not active or rpm < 100 or engine.isDisabled or engine.isBroken then
    stop(); status = "silent_engine_stopped_or_induction_inactive"; return
  end

  load = math.max(0, math.min(1, load))
  local engineSpeed = math.min(1, rpm / 6000)
  if config.managed then
      if config.kind == "blower" and config.blowerType == "centrifugal" then
        local pressure = finite(values.superchargerBoost)
        if config.previousLoad and config.previousLoad >= .65 and load <= .25
          and config.previousPressure and config.previousPressure >= 4 and pressure
          and config.releaseSource then
          obj:playSFX(config.releaseSource)
          config.releaseCount = config.releaseCount + 1
        end
        config.previousLoad, config.previousPressure = load, pressure
      end
      local compensation = cabinInside and config.cabinGain or 1
      if config.kind == "blower" and config.blowerType == "roots" then
        -- Hellcat-style twin-screw character: gear/rotor whine follows engine speed
        -- continuously, while the bypass mainly unloads volume. Air rush is kept
        -- below the tonal layer so it does not mask the rising mechanical whine.
        local inputReferenceRPM = math.max(100, config.audioInputReferenceRPM or 4000)
        local rotorRPM = rpm * math.max(.1, config.audioDriveRatio or 2.36)
        local maxRotorRPM = math.max(1000, config.audioMaxShaftRPM or 14600)
        local speed = math.max(0, math.min(1.15, rotorRPM / maxRotorRPM))
        local pitch = math.max(.18, math.min(2.3, rpm / inputReferenceRPM))
        local pressure = finite(values.superchargerBoost)
        local pressureGain = pressure and math.max(0, pressure) / (math.max(0, pressure) + 12) or 0
        local whineLevel = (.02 + .55 * speed ^ 1.25) * (.35 + .65 * load)
        local airLevel = load * (.02 * engineSpeed + .06 * pressureGain)
        local whineTarget = math.min(1.35, whineLevel * config.spoolVolume * compensation)
        local airTarget = math.min(.55, airLevel * config.airVolume * compensation)
        local whineTime = whineTarget < (loopLevels.whine or 0) and .09 or .06
        local airTime = airTarget < (loopLevels.hiss or 0) and .08 or .05
        setLoop("whine", whineTarget, pitch, dt, whineTime)
        setLoop("hiss", airTarget, .82 + .23 * engineSpeed, dt, airTime)
        status = "playing_hellcat_roots_induction"
        return
      end
      if config.kind == "blower" and config.blowerType == "centrifugal" then
        -- Centrifugal impeller whine rises with its audio-only step-up; airflow builds with load/boost.
        local inputReferenceRPM = math.max(100, config.audioInputReferenceRPM or 4000)
        local driveRatio = math.max(.1, config.audioDriveRatio or 4.10)
        local maxShaftRPM = math.max(1000, config.audioMaxShaftRPM or 65000)
        local impellerRPM = rpm * driveRatio
        local speed = math.max(0, math.min(1.15, impellerRPM / maxShaftRPM))
        local pitch = math.max(.18, math.min(2.3, rpm / inputReferenceRPM))
        local pressure = finite(values.superchargerBoost)
        local pressureGain = pressure and math.max(0, pressure) / (math.max(0, pressure) + 12) or 0
        local whineLevel = (.012 + .34 * speed ^ 1.2) * (.45 + .55 * load)
        local airLevel = load * (.06 * engineSpeed + .20 * pressureGain)
        local whineTarget = math.min(.85, whineLevel * config.spoolVolume * compensation)
        local airTarget = math.min(.65, airLevel * config.airVolume * compensation)
        setLoop("whine", whineTarget, pitch, dt, whineTarget < (loopLevels.whine or 0) and .12 or .055)
        setLoop("hiss", airTarget, .82 + .23 * engineSpeed, dt,
          airTarget < (loopLevels.hiss or 0) and .10 or .05)
        status = "playing_procharger_centrifugal_induction"
        return
      end
      local shaftRPM = config.kind == "turbo" and measuredTurboRPM(values) or rpm * config.ratio
      local pressure = finite(values[config.kind == "turbo" and "turboBoost" or "superchargerBoost"])
      local whine = shaftRPM and math.max(0, shaftRPM) / (config.kind == "turbo" and 10000 or 1000) or 0
      local pitch = shaftRPM and math.max(.1, math.min(3, shaftRPM / (config.kind == "turbo" and 100000 or 4000))) or 1
      local whineLevel = config.kind == "turbo" and whine * .14 or whine * .16 * (.25 + .75 * load)
      local rush = pressure and math.max(0, pressure) * .06 * load or 0
      local intake = .18 * load * engineSpeed
      setLoop("whine", math.min(1.6, whineLevel * config.spoolVolume * compensation), pitch, dt, .04)
      setLoop("hiss", math.min(1, (rush + intake) * config.airVolume * compensation), .8 + .3 * engineSpeed, dt, .035)
      if config.kind == "turbo" and loopSources.peak then
        local boost = pressure and math.max(0, pressure) or 0
        local target = finite(targetBoostPsi) or config.peakBoost
        if config.peakHardwareCeiling then target = math.min(target, config.peakHardwareCeiling) end
        local peakStart = math.max(2, target * .72)
        local peakRange = math.max(1, target * .23)
        local peakAmount = target > 0 and math.max(0, math.min(1, (boost - peakStart) / peakRange)) or 0
        local shaftAmount = shaftRPM and math.max(0, math.min(1, (shaftRPM - 60000) / 60000)) or 0
        local peakLevel = .32 * peakAmount * shaftAmount * load * config.spoolVolume * compensation
        setLoop("peak", math.min(.65, peakLevel), math.max(.6, math.min(2.2, (shaftRPM or 0) / 100000)), dt, .08)
      end
      status = shaftRPM and "playing_managed_original_induction" or "managed_shaft_signal_missing"
      return
  end
  if config.kind == "blower" then
    local boost = finite(values.superchargerBoost)
    local boostGain = boost and math.max(0, boost) / (math.max(0, boost) + 12) or 0
    local shaftSpeed = math.min(1, rpm * config.ratio / 6500)
    local roots = config.blowerType == "roots"
    -- Rotor pulses unload with the bypass; centrifugal gear noise persists at light load.
    -- The shaft ratio is the simulation's input drive, not a measured impeller step-up ratio.
    local target = roots and (.008 + .24 * load ^ 1.4 * (.25 + .75 * shaftSpeed))
      or (.012 + .045 * shaftSpeed + .16 * load * shaftSpeed)
    target = target + .035 * boostGain * load
    local targetPitch = math.max(.20, math.min(3, rpm * config.ratio / 3000))
    local gainTime = target < (loopLevels.whine or 0) and .018 or .04
    local airGain = (roots and .12 or .18) * load * engineSpeed * (.6 + .4 * boostGain)
    local compensation = cabinInside and config.cabinGain or 1
    setLoop("hiss", airGain * config.airVolume * compensation, .8 + .35 * engineSpeed, dt, .035)
    setLoop("whine", target * config.spoolVolume * compensation, targetPitch, dt, gainTime)
  else
    local turboRPM = measuredTurboRPM(values)
    if turboRPM and turboRPM > 0 then
      local whinePitch = math.max(.2, math.min(3, turboRPM / 100000))
      local whineGain = .012 + .17 * (.4 + .6 * load) * math.min(1, turboRPM / 100000)
      setLoop("whine", whineGain, whinePitch, dt, .04)
    else
      setLoop("whine", 0, 1, dt, .025)
    end
    local boost = finite(values.turboBoost)
    local pressure = boost and math.max(0, boost) or 0
    -- Intake flow is an RPM/load proxy, audible before boost. Pressure adds compressor rush;
    -- missing pressure contributes zero to that layer and never invents a turbo shaft speed.
    local hissGain = load * (.075 * engineSpeed + .20 * pressure / (pressure + 8))
    setLoop("hiss", hissGain, math.max(.75, math.min(1.25, .8 + (boost or 0) / 100)), dt, .05)
    status = "playing_induction_overlay_native_valve_events"
    return
  end
  status = "playing_induction_overlay_no_synthetic_events"
end

function M.setCabinInside(value) cabinInside = value == true end
function M.getStatus() return status end
function M.getDiagnostics()
  local levels, pitches = {}, {}
  for key, value in pairs(loopLevels) do levels[key] = value end
  for key, value in pairs(loopPitches) do pitches[key] = value end
  return {enabled = enabled, status = status, reference = false,
    levels = levels, pitches = pitches, cabinInside = cabinInside, managed = config and config.managed or false,
    releaseAvailable = config and config.releaseSource ~= nil or false,
    releaseCount = config and config.releaseCount or 0}
end
function M.stop() stop() end
return M
