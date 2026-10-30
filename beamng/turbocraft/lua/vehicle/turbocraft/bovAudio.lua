-- Sound-only valve controller. BeamNG's turbo remains responsible for pressure and torque.
local M = {}
local state, previousThrottle, previousBoost, openThrottle = "IDLE", nil, 0, nil
local dischargeLeft = 0
local armed = true
local sound, gain, node, enabled

local function finite(value)
  value = tonumber(value)
  return value and value == value and math.abs(value) < math.huge and value or nil
end

function M.configure(data, engine)
  M.reset()
  data = type(data) == "table" and data or {}
  enabled = data.bovEnabled ~= false and type(data.bovSoundFileName) == "string"
  sound = enabled and data.bovSoundFileName or nil
  gain = math.max(0, finite(data.bovSoundVolumeCoef) or 0)
  node = finite(engine and engine.engineNodeID)
end

function M.reset()
  state, previousThrottle, previousBoost, openThrottle = "IDLE", nil, 0, nil
  dischargeLeft, armed = 0, true
end

function M.getState() return state end

function M.update(dt, engine)
  dt = finite(dt) or 0
  if dt <= 0 then return end
  local values = electrics and electrics.values or {}
  -- requestedThrottle stays high on ignition/limiter cuts, unlike engine load.
  local throttle = finite(engine and engine.requestedThrottle) or finite(values.throttle)
  local boost = finite(values.turboBoost)
  if not throttle or not boost or boost < 0 or not engine or engine.isDisabled or engine.isBroken then
    M.reset()
    return
  end
  throttle = math.max(0, math.min(1, throttle))
  local prior = previousThrottle
  local pressure = math.max(boost, previousBoost)
  if throttle >= 0.45 then openThrottle = throttle end
  local closure = openThrottle and math.max(0, openThrottle - throttle) or 0
  local closing = prior and openThrottle and prior > throttle and throttle <= 0.35 and closure >= 0.25
  local differential = pressure * closure

  if state == "DISCHARGING" then
    dischargeLeft = dischargeLeft - dt
    if dischargeLeft <= 0 then state = "RECOVERY" end
  end
  if throttle >= 0.45 then
    armed = true
    if state == "RECOVERY" or state == "IDLE" then state = boost >= 0.75 and "PRESSURIZED" or "IDLE" end
  elseif state == "IDLE" and boost >= 0.75 then
    state = "PRESSURIZED"
  end

  if closing and armed and state ~= "DISCHARGING" and pressure >= 0.75 and differential >= 0.35 then
    state = "THROTTLE_CLOSING"
    armed = false
    -- Native event sample is pitch-scaled: weaker releases are shorter and quieter.
    local intensity = math.sqrt(math.min(1, differential / 14))
    local pitch = 1.22 - 0.35 * intensity
    dischargeLeft = 0.16 + 0.24 * intensity
    if enabled and gain > 0 and node and obj and type(obj.playSFXOnceCT) == "function" then
      obj:playSFXOnceCT(sound, node, math.min(1.5, gain * (0.16 + 0.84 * intensity)), pitch, 1, 0)
    end
    state = "DISCHARGING"
  elseif state == "PRESSURIZED" and boost < 0.45 then
    state = "IDLE"
  end
  previousThrottle, previousBoost = throttle, boost
end

return M
