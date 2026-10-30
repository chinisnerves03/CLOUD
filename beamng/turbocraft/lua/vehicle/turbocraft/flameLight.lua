-- Brief light flash at the tailpipe tip for every afterfire flame, so the bumper and road light up.
-- The light itself lives in the GameEngine extension turbocraftFlameLight; this side only decides
-- when and in what colour, and rate-limits per exhaust tip.
local M = {}

local MIN_INTERVAL = .05   -- seconds between flashes from the same tip
local clock = 0
local lastFlash = {}
local status = "flame_light_idle"

local function finite(value)
  value = tonumber(value)
  return value and value == value and math.abs(value) < math.huge and value or nil
end

-- Big rich bangs on low gears/downshifts burn orange; small lean pops at speed in high gears
-- burn blue-white; everything in between is a yellow-white hot core.
local function flameKind()
  local values = electrics and electrics.values or {}
  local gear = finite(values.gearIndex) or 0
  local speed = math.abs(finite(values.wheelspeed) or finite(values.airspeed) or 0)
  if gear >= 5 and speed > 35 then return "blue" end
  if gear <= 2 then return "orange" end
  return "white"
end

local function vehicleId()
  if obj and type(obj.getId) == "function" then
    local ok, id = pcall(obj.getId, obj)
    if ok and finite(id) then return id end
  end
  return finite(objectId)
end

function M.flash(node)
  node = finite(node)
  if not node or node < 0 then return false end
  if lastFlash[node] and clock - lastFlash[node] < MIN_INTERVAL then return false end
  if not obj or type(obj.queueGameEngineLua) ~= "function" then
    status = "flame_light_bridge_unavailable"
    return false
  end
  local id = vehicleId()
  if not id then
    status = "flame_light_vehicle_id_unavailable"
    return false
  end
  lastFlash[node] = clock
  local kind = flameKind()
  obj:queueGameEngineLua(string.format(
    "if turbocraftFlameLight then turbocraftFlameLight.flash(%d, %d, %q) end", id, node, kind))
  status = "flame_light_" .. kind
  return true
end

function M.update(dt)
  clock = clock + (finite(dt) or 0)
end

function M.onReset()
  clock, lastFlash = 0, {}
end

function M.getStatus() return status end
return M
