local M = {}
local tracked = setmetatable({}, {__mode = "k"})
local status, endpointCount = "native_afterfire_unchanged", 0
local lastWarning
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < math.huge end

function M.update(engine, data)
  local definition = engine and data and data[engine.name] or {}
  local profile = definition and definition.turbocraftEffectsProfile
  local target = definition and tonumber(definition.turbocraftAfterfireVisualCoef)
  local minimum = definition and definition.turbocraftAfterfireMinRPM
  local gated = profile == "drift" and minimum ~= nil
  local blocked, warning = false, nil
  if gated then
    if not finite(minimum) or minimum < 0 then
      blocked, warning = true, "native_afterfire_min_rpm_invalid"
    elseif minimum > 0 then
      local av = engine and engine.outputAV1
      if not finite(av) then
        blocked, warning = true, "native_afterfire_rpm_unavailable"
      else
        blocked = math.abs(av) < minimum * math.pi / 30
      end
    end
  end
  if warning and warning ~= lastWarning and log then log("W", "TurboCraftAfterfire", warning) end
  lastWarning = warning
  local active = (profile == "overrun" or profile == "hardcut" or profile == "drift") and (finite(target) or gated)
    and engine.requiredEnergyType ~= "diesel"
  local ends = engine and engine.thermals and engine.thermals.exhaustEndNodes
  endpointCount = 0
  if type(ends) ~= "table" then
    status = active and "native_afterfire_endpoints_unavailable" or "native_afterfire_unchanged"
    return
  end
  if finite(target) then target = math.max(0, math.min(1, target)) end
  for _, node in pairs(ends) do
    if type(node) == "table" and finite(node.start) and finite(node.finish)
      and node.start >= 0 and node.finish >= 0 and node.start ~= node.finish
      and finite(node.afterFireVisualCoef) then
      local previous = tracked[node]
      if active then
        -- Only the native endpoint's visual transmission changes, never its fuel or location.
        if not previous or node.afterFireVisualCoef ~= previous.applied then
          previous = {baseline = node.afterFireVisualCoef}
          tracked[node] = previous
        end
        local applied = blocked and 0 or target or previous.baseline
        node.afterFireVisualCoef = applied
        previous.applied = applied
        endpointCount = endpointCount + 1
      elseif previous then
        if node.afterFireVisualCoef == previous.applied then node.afterFireVisualCoef = previous.baseline end
        tracked[node] = nil
      end
    end
  end
  status = active and (endpointCount > 0 and "native_afterfire_endpoints_applied" or "native_afterfire_endpoints_unavailable")
    or "native_afterfire_unchanged"
  if active and endpointCount > 0 and blocked then
    status = warning or "native_afterfire_below_min_rpm"
  end
end

function M.getStatus() return status end
function M.getEndpointCount() return endpointCount end
return M
