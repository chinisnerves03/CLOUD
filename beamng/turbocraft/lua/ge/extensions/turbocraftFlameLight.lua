-- GameEngine side of the tailpipe flame flash: a small pool of point lights that sit on the
-- exhaust tip node, flare up and fade within ~0.1 s. Every engine call is guarded so a missing
-- or renamed API only disables the flash and is reported once in the log.
local M = {}

local POOL_SIZE = 8
local STYLES = {
  orange = {color = {1.0, 0.42, 0.10}, brightness = 3.0, radius = 3.2, duration = .13},
  white = {color = {1.0, 0.82, 0.55}, brightness = 2.6, radius = 2.6, duration = .10},
  blue = {color = {0.45, 0.65, 1.0}, brightness = 2.0, radius = 2.0, duration = .08},
}

local pool, active = {}, {}
local failed = false

local function warn(message)
  if failed then return end
  failed = true
  log("W", "TurboCraftFlameLight", message)
end

local function tipPosition(vehicleId, node)
  local ok, pos = pcall(function()
    local veh = be:getObjectByID(vehicleId)
    if not veh then return nil end
    return veh:getPosition() + veh:getNodePosition(node)
  end)
  return ok and pos or nil
end

local function setLight(light, style, brightness, pos)
  local c = style.color
  light:setField("color", 0, string.format("%f %f %f 1", c[1], c[2], c[3]))
  light:setField("brightness", 0, tostring(brightness))
  light:setField("radius", 0, tostring(style.radius))
  if pos then light:setPosition(pos) end
end

local function acquire()
  for _, light in ipairs(pool) do
    if not active[light] then return light end
  end
  if #pool >= POOL_SIZE then return nil end
  local ok, light = pcall(function()
    local l = createObject("PointLight")
    l:setField("castShadows", 0, "0")
    l:setField("brightness", 0, "0")
    l:registerObject("")
    return l
  end)
  if not ok or not light then
    warn("point_light_creation_failed:" .. tostring(light))
    return nil
  end
  pool[#pool + 1] = light
  return light
end

function M.flash(vehicleId, node, kind)
  if failed then return end
  local style = STYLES[kind] or STYLES.white
  local pos = tipPosition(vehicleId, node)
  if not pos then return end
  local light = acquire()
  if not light then return end
  -- slight flicker so consecutive pops never look identical
  local peak = style.brightness * (0.8 + 0.4 * math.random())
  local ok, err = pcall(setLight, light, style, peak, pos)
  if not ok then return warn("point_light_update_failed:" .. tostring(err)) end
  active[light] = {vehicleId = vehicleId, node = node, style = style, peak = peak, age = 0}
end

function M.onUpdate(dtReal, dtSim)
  dtSim = tonumber(dtSim) or 0
  for light, state in pairs(active) do
    state.age = state.age + dtSim
    local left = 1 - state.age / state.style.duration
    local ok
    if left <= 0 then
      ok = pcall(light.setField, light, "brightness", 0, "0")
      active[light] = nil
    else
      -- follow the tip: at 200 km/h the car moves several metres during one flash
      ok = pcall(setLight, light, state.style, state.peak * left * left, tipPosition(state.vehicleId, state.node))
    end
    if not ok then active[light] = nil end
  end
end

local function clear()
  for _, light in ipairs(pool) do pcall(light.delete, light) end
  pool, active = {}, {}
end

M.onClientEndMission = clear
M.onExtensionUnloaded = clear
return M
