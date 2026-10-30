local M = {}

M.PA_PER_PSI = 6894.757293168
M.MIN_TARGET_PSI = 0
M.MAX_TARGET_PSI = 200

local function finite(value)
  return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function M.isFinite(value)
  return finite(value)
end

function M.clampTargetPsi(value)
  value = tonumber(value)
  if not finite(value) then return nil, "target_not_finite" end
  if value < M.MIN_TARGET_PSI then return M.MIN_TARGET_PSI, "target_clamped_low" end
  if value > M.MAX_TARGET_PSI then return M.MAX_TARGET_PSI, "target_clamped_high" end
  return value, nil
end

function M.psiToPa(psi)
  if not finite(psi) then return nil, "psi_not_finite" end
  return psi * M.PA_PER_PSI, nil
end

function M.paToPsi(pa)
  if not finite(pa) then return nil, "pa_not_finite" end
  return pa / M.PA_PER_PSI, nil
end

function M.gaugeBoostPa(manifoldAbsolutePa, ambientPa)
  if not finite(manifoldAbsolutePa) or manifoldAbsolutePa < 0 then
    return nil, "invalid_manifold_pressure"
  end
  if not finite(ambientPa) or ambientPa <= 0 then
    return nil, "invalid_ambient_pressure"
  end
  return manifoldAbsolutePa - ambientPa, nil
end

-- Stable first-order spool approximation used for diagnostics/replay only.
-- It does not overwrite BeamNG's native turbo physics.
function M.updateSpool(state, target, responsePerSecond, dt)
  state = tonumber(state)
  target = tonumber(target)
  responsePerSecond = tonumber(responsePerSecond)
  dt = tonumber(dt)
  if not finite(state) or not finite(target) or not finite(responsePerSecond) or
     not finite(dt) or responsePerSecond < 0 or dt <= 0 then
    return state, "invalid_spool_input"
  end
  local alpha = 1 - math.exp(-responsePerSecond * math.min(dt, 0.25))
  local nextState = state + (target - state) * alpha
  if not finite(nextState) then return state, "invalid_spool_output" end
  return nextState, nil
end

return M

