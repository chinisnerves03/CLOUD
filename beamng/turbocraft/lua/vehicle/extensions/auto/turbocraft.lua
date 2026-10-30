local M = {}
local core = require("turbocraft/core")
local adapters = require("turbocraft/adapters")
local boostReader = require("turbocraft/boostReader")
local originalAudio = require("turbocraft/originalAudio")
local exhaustAudio = require("turbocraft/exhaustAudio")
local afterfireRouting = require("turbocraft/afterfireRouting")
local afterfireParticles = require("turbocraft/afterfireParticles")
local shiftAudio = require("turbocraft/shiftAudio")
local eventEffects = require("turbocraft/eventEffects")
local popBang = require("turbocraft/popBang")
local flameLight = require("turbocraft/flameLight")

local SAMPLE_PERIOD = 0.05
local sampleAccumulator = 0
local elapsed = 0
local targetBoostPsi = 8
local sampleSequence = 0
local engine
local adapterId = "universal"
local adapterName = "Universal adapter"
local controlStatus = "monitor_only"
local controlError = "turbo_not_detected"
local baseWastegatePsi
local retryAccumulator = 0
local turboSize
local turboSizeMm, coverAR, turbineAR, bovType
local pressureContract, inductionKit

local function vehicleId()
  if not obj then return nil end
  local getter = obj.getID or obj.getId
  if type(getter) ~= "function" then return nil end
  local ok, id = pcall(getter, obj)
  return ok and id or nil
end

local function configuredTurboSize()
  for _, section in pairs(v and v.data or {}) do
    if type(section) == "table" and core.isFinite(tonumber(section.turbocraftSize)) then
      return tonumber(section.turbocraftSize), tonumber(section.turbocraftSizeMm),
        tonumber(section.turbocraftCoverAR), tonumber(section.turbocraftTurbineAR), section.turbocraftBov
    end
  end
  return nil, nil, nil, nil, nil
end

local function findEngine()
  if powertrain and powertrain.getDevice then engine = powertrain.getDevice("mainEngine") end
  if not engine and powertrain and powertrain.getDevicesByCategory then
    for _, device in pairs(powertrain.getDevicesByCategory("engine") or {}) do
      engine = device
      break
    end
  end
  return engine
end

local function scan()
  findEngine()
  adapterId, adapterName = adapters.classify(
    adapters.vehicleDirectoryFromRuntime(), adapters.selectedPartsFromRuntime())
  controlStatus = "monitor_only"
  controlError = engine and "live_wastegate_setter_unavailable" or "engine_not_detected"
  baseWastegatePsi = nil
  retryAccumulator = 0
  turboSize, turboSizeMm, coverAR, turbineAR, bovType = configuredTurboSize()
  local data = v and v.data or {}
  afterfireParticles.configure(data)
  inductionKit = (data.turbocharger or {}).turbocraftKit or (data.supercharger or {}).turbocraftKit
  shiftAudio.configure(data, inductionKit ~= nil)
  pressureContract = data.turbocraftPressureSignals
  if not pressureContract and engine and engine.supercharger and engine.supercharger.isExisting then
    pressureContract = {gaugeKey = "superchargerBoost", gaugeUnit = "PSI",
      vacuumAvailable = false, measurementKind = "compressor_gauge"}
  end
  if pressureContract and not boostReader.validContract(pressureContract) then
    log("W", "TurboCraft", "invalid pressure signal contract; native boost-only fallback")
  end
  local ref = data.refNodes and data.refNodes[0]
  local audioNode = engine and engine.engineNodeID or ref and ref.ref
  if (data.turbocharger or {}).turbocraftManagedInductionAudio
    or (data.supercharger or {}).turbocraftManagedInductionAudio then
    originalAudio.setEnabled(true, data, audioNode)
  else
    originalAudio.configure(data, audioNode)
  end
  popBang.configure(data, audioNode)
end

local function turboObject()
  return engine and engine.turbocharger or nil
end

local function configuredWastegatePsi()
  local data = v and v.data and v.data.turbocharger
  local configured = type(data) == "table" and tonumber(data.wastegateStart)
  if core.isFinite(configured) then return configured end
  local values = electrics and electrics.values or {}
  local live = tonumber(values.turboBoostMax or values.boostMax)
  return core.isFinite(live) and live or nil
end

local function applyTarget()
  local turbo = turboObject()
  if not turbo or not turbo.isExisting then
    if engine and engine.supercharger and engine.supercharger.isExisting then
      controlStatus, controlError = "pulley_controlled", ""
      return false
    end
    controlStatus, controlError = "monitor_only", "turbo_not_detected"
    return false
  end
  baseWastegatePsi = baseWastegatePsi or configuredWastegatePsi()
  if type(turbo.setWastegateOffset) == "function" then
    if not core.isFinite(baseWastegatePsi) then
      controlStatus, controlError = "monitor_only", "base_wastegate_unavailable"
      return false
    end
    local ok, result = pcall(turbo.setWastegateOffset, targetBoostPsi - baseWastegatePsi)
    if ok and result ~= false then
      controlStatus, controlError = "applied_native_offset", ""
      return true
    end
  end
  local methods = {"setWastegateStart", "setWastegateLimit", "setWastegatePressure", "setBoostLimit"}
  for _, methodName in ipairs(methods) do
    local method = turbo[methodName]
    if type(method) == "function" then
      local ok, result = pcall(method, turbo, targetBoostPsi)
      if ok and result ~= false then
        controlStatus, controlError = "applied", ""
        return true
      end
    end
  end
  controlStatus, controlError = "monitor_only", "live_wastegate_setter_unavailable"
  return false
end

local function makeState()
  local values = electrics and electrics.values or {}
  local boost = boostReader.read(values, pressureContract)
  local turbo = turboObject()
  local turboRpm = tonumber(values.turboRPM or values.turboRpm or values.turborpm)
  local turboRatio = tonumber(values.turboRPMRatio or values.turboRpmRatio or values.turborpmratio)
  local torque = engine and tonumber(engine.outputTorque1)
  local av = engine and tonumber(engine.outputAV1)
  local power = core.isFinite(torque) and core.isFinite(av) and torque * av / 1000 or nil
  local errorFlags = boost.errorFlags or ""
  if controlError ~= "" then errorFlags = errorFlags == "" and controlError or (errorFlags .. "|" .. controlError) end
  return {
    timestamp_s = elapsed,
    vehicle_id = vehicleId(),
    vehicle = adapters.vehicleDirectoryFromRuntime(),
    engine_or_adapter = adapterId,
    adapterName = adapterName,
    rpm = tonumber(values.rpm) or 0,
    throttle_or_load = tonumber(values.throttle or values.engine_load) or 0,
    target_boost_psi = targetBoostPsi,
    measured_boost_psi = boost.measuredBoostPsi,
    manifold_abs_pa = boost.manifoldAbsPa,
    ambient_pa = boost.ambientPa,
    control_or_wastegate = controlStatus,
    spool_state = core.isFinite(turboRatio) and turboRatio or nil,
    turbo_rpm = core.isFinite(turboRpm) and turboRpm or nil,
    shaft_torque_nm = core.isFinite(torque) and torque or nil,
    shaft_power_kw = power,
    sample_sequence = sampleSequence,
    valid = boost.valid,
    error_flags = errorFlags,
    signal_source = boost.signalSource,
    turboDetected = turbo and turbo.isExisting and true or false,
    turbo_size = turboSize,
    turbo_size_mm = turboSizeMm,
    compressor_cover_ar = coverAR,
    turbine_housing_ar = turbineAR,
    bov_type = bovType,
    turbo_size_source = turboSize and "intake_part" or "not_turbocraft_part",
    ambientSource = boost.ambientSource,
    ambient_source = boost.ambientSource,
    manifold_source = boost.manifoldSource,
    measurement_kind = boost.measurementKind,
    vacuum_available = boost.vacuumAvailable,
    induction_family = inductionKit and inductionKit.family,
    hardware_id = inductionKit and inductionKit.hardwareId,
    kit_model = inductionKit and inductionKit.model,
    afterfire_source = "native_engine_exhaust_tree",
    afterfire_routing_status = afterfireRouting.getStatus(),
    afterfire_endpoint_count = afterfireRouting.getEndpointCount(),
    original_audio_status = originalAudio.getStatus(),
    exhaust_audio_status = exhaustAudio.getStatus(),
    shift_audio_profile = shiftAudio.getProfile(),
    shift_audio_status = shiftAudio.getStatus(),
    limiter_effects_status = eventEffects.getStatus(),
    pop_bang_status = popBang.getStatus(),
    flame_light_status = flameLight.getStatus(),
    original_audio = originalAudio.getDiagnostics(),
    pulley_controlled = engine and engine.supercharger and engine.supercharger.isExisting or false,
    pulley_drive_ratio = v and v.data and v.data.supercharger and v.data.supercharger.gearRatio,
    wastegate_profile = v and v.data and v.data.turbocharger and v.data.turbocharger.turbocraftWastegate
  }
end

local function publish()
  if not obj or not obj.queueGameEngineLua then return end
  sampleSequence = sampleSequence + 1
  obj:queueGameEngineLua("if turbocraftUI then turbocraftUI.onVehicleTelemetry(" .. serialize(makeState()) .. ") end")
end

function M.setTargetBoost(value)
  local clamped, err = core.clampTargetPsi(value)
  if not clamped then
    controlStatus, controlError = "monitor_only", err
    publish()
    return false
  end
  targetBoostPsi = clamped
  applyTarget()
  publish()
  return true
end

function M.requestState()
  publish()
end

function M.setCabinAudioState(inside) originalAudio.setCabinInside(inside) end

function M.setOriginalAudioEnabled(value)
  local data = v and v.data or {}
  local ref = data.refNodes and data.refNodes[0]
  local ok, reason = originalAudio.setEnabled(value, data, engine and engine.engineNodeID or ref and ref.ref)
  if not ok then log("W", "TurboCraftAudio", tostring(reason)) end
  publish()
  return ok, reason
end

function M.updateGFX(dt)
  dt = tonumber(dt) or 0
  if dt <= 0 then return end
  flameLight.update(dt)
  exhaustAudio.update(engine, v and v.data or {})
  afterfireRouting.update(engine, v and v.data or {})
  shiftAudio.update(engine, electrics and electrics.values or {}, v and v.data or {})
  eventEffects.update(dt, engine, electrics and electrics.values or {}, v and v.data or {})
  popBang.update(dt, engine, electrics and electrics.values or {}, v and v.data or {})
  originalAudio.update(dt, engine, electrics and electrics.values or {}, targetBoostPsi)
  elapsed = elapsed + dt
  if controlStatus == "monitor_only" then retryAccumulator = retryAccumulator + dt end
  sampleAccumulator = sampleAccumulator + dt
  if sampleAccumulator >= SAMPLE_PERIOD then
    sampleAccumulator = sampleAccumulator % SAMPLE_PERIOD
    if controlStatus == "monitor_only" then
      if retryAccumulator >= 1 then
        retryAccumulator = 0
        findEngine()
        applyTarget()
      end
    end
    publish()
  end
end

function M.onReset()
  sampleAccumulator, elapsed, sampleSequence = 0, 0, 0
  scan()
  shiftAudio.onReset()
  eventEffects.onReset()
  popBang.onReset()
  flameLight.onReset()
  applyTarget()
  publish()
end

function M.onExtensionUnloaded()
  afterfireParticles.onExtensionUnloaded()
  shiftAudio.onReset()
  eventEffects.onReset()
  popBang.onReset()
  originalAudio.stop()
end

function M.onExtensionLoaded()
  scan()
  applyTarget()
  publish()
end

return M
