local M = {}
local flameLight = require("turbocraft/flameLight")

local flameTypes = {[61] = true, [62] = true, [63] = true, [64] = true, [65] = true}
local targetObj
local original
local wrapper
local enabled = false
local status = "disabled"

local function logFailure(message)
  status = message
  if log then log("W", "TurboCraftAfterfire", message) end
end

local function restore()
  enabled = false
  if targetObj and wrapper and targetObj.addParticleByNodesRelative == wrapper then
    local ok, err = pcall(function() targetObj.addParticleByNodesRelative = original end)
    if not ok then
      logFailure("native_flame_wrapper_restore_failed:" .. tostring(err))
      return false
    end
  end
  targetObj, original, wrapper = nil, nil, nil
  status = "disabled"
  return true
end

function M.configure(data)
  local engineData = data and data.mainEngine
  local profile = engineData and engineData.turbocraftEffectsProfile
  local shouldEnable = profile == "overrun" or profile == "hardcut" or profile == "drift"
  if not shouldEnable then return restore() end
  if not obj or type(obj.addParticleByNodesRelative) ~= "function" then
    logFailure("native_flame_particle_api_unavailable")
    return false, status
  end

  if targetObj ~= obj and not restore() then return false, status end
  if wrapper and obj.addParticleByNodesRelative ~= wrapper then
    enabled = false
    logFailure("native_flame_particle_wrapper_overridden")
    return false, status
  end
  if not wrapper then
    targetObj = obj
    original = obj.addParticleByNodesRelative
    wrapper = function(self, node1, node2, velocity, particleType, width, count)
      if enabled and flameTypes[particleType] then flameLight.flash(node1) end
      -- Denser but slower native flames: a fireball sitting on the tip instead of a jet past it.
      if enabled and flameTypes[particleType] and type(velocity) == "number" and velocity < 0
          and count == 1 then
        return original(self, node1, node2, velocity * .8, particleType, width, 3)
      end
      return original(self, node1, node2, velocity, particleType, width, count)
    end
    local ok, err = pcall(function() obj.addParticleByNodesRelative = wrapper end)
    if not ok or obj.addParticleByNodesRelative ~= wrapper then
      targetObj, original, wrapper = nil, nil, nil
      logFailure("native_flame_particle_wrapper_unavailable:" .. tostring(err or "assignment rejected"))
      return false, status
    end
  end

  enabled = true
  status = "native_flames_at_tip"
  return true
end

function M.getStatus() return status end
function M.onExtensionUnloaded() restore() end

return M
