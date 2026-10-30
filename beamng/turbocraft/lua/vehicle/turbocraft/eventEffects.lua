-- Short, repeatable tailpipe effects for held-throttle limiter cuts.
local M = {}
local cadence = 0
local flameBudget = 0
local status = "idle"
local burstEnds = nil
local burstPulses = 0
local burstDelay = 0
-- Low speeds keep the limiter fireball at the tailpipe tip; the spread gives it depth.
local flameVelocities = {-8, -5, -11, -4, -6}

local function finite(value)
  value = tonumber(value)
  return value and value == value and math.abs(value) < math.huge and value or nil
end

local function endsOf(engine)
  local ends = engine and engine.thermals and engine.thermals.exhaustEndNodes
  return type(ends) == "table" and ends or nil
end

local function emitFlame(endpoint)
  if not obj or type(obj.addParticleByNodesRelative) ~= "function" then return false end
  local start, finish = finite(endpoint.start), finite(endpoint.finish)
  if not start or not finish or start < 0 or finish < 0 or start == finish then return false end
  if type(obj.inWater) == "function" and obj:inWater(finish) then return false end
  for index, velocity in ipairs(flameVelocities) do
    obj:addParticleByNodesRelative(finish, start, velocity, 60 + index, 0, 2)
  end
  return true
end

function M.flame(engine, data)
  local profile = data and data.mainEngine and data.mainEngine.turbocraftEffectsProfile
  if profile ~= "overrun" and profile ~= "hardcut" and profile ~= "drift" then return 0 end
  if engine and engine.requiredEnergyType == "diesel" then return 0 end
  local definition = data.mainEngine
  local threshold = finite(definition.afterFireVisualThresholdShift)
  if threshold and threshold >= 1e20 then return 0 end
  local chance = math.max(0, math.min(100, finite(definition.turbocraftFlameChance) or 100))
  if chance == 0 then return 0 end
  local minimumRPM = finite(definition.turbocraftAfterfireMinRPM) or 0
  local rpm = finite(engine and engine.outputAV1)
  if minimumRPM > 0 and (not rpm or math.abs(rpm) * 30 / math.pi < minimumRPM) then return 0 end
  flameBudget = flameBudget + chance * .01
  if flameBudget < 1 then return 0 end
  flameBudget = flameBudget - 1
  local emitted = 0
  local eligibleEnds = {}
  for _, endpoint in pairs(endsOf(engine) or {}) do
    if type(endpoint) == "table" and emitFlame(endpoint) then
      emitted = emitted + 1
      eligibleEnds[#eligibleEnds + 1] = endpoint
    end
  end
  if emitted > 0 then
    burstEnds = eligibleEnds
    burstPulses = 2
    burstDelay = .055
  end
  return emitted
end

function M.update(dt, engine, values, data)
  dt = finite(dt) or 0
  if dt <= 0 then return end
  if burstPulses > 0 then
    burstDelay = burstDelay - dt
    while burstPulses > 0 and burstDelay <= 0 do
      for _, endpoint in ipairs(burstEnds or {}) do emitFlame(endpoint) end
      burstPulses = burstPulses - 1
      burstDelay = burstDelay + .055
    end
    if burstPulses == 0 then burstEnds = nil end
  end
  values = values or {}
  data = data or {}
  local rpm, limit = finite(engine and engine.outputAV1), finite(engine and engine.revLimiterAV)
  local throttle = finite(engine and engine.requestedThrottle) or finite(values.throttle) or 0
  local active = engine and not engine.isDisabled and not engine.isBroken
    and rpm and limit and limit > 0 and math.abs(rpm) >= limit * .9 and throttle >= .5
  if not active then cadence = 0; status = "idle"; return end
  cadence = cadence - dt
  if cadence > 0 then return end
  cadence = .28
  local profile = data.mainEngine and data.mainEngine.turbocraftEffectsProfile
  if profile == "hardcut" or profile == "drift" then
    local count = M.flame(engine, data)
    if count > 0 and obj and type(obj.playSFXOnceCT) == "function" then
      local sound = data.mainEngine.instantAfterFireSound or "event:>Vehicle>Afterfire>01_Single_EQ1"
      local volume = math.max(0, math.min(3, finite(data.mainEngine.instantAfterFireVolumeCoef) or 1))
      for _, endpoint in pairs(endsOf(engine) or {}) do
        if type(endpoint) == "table" and finite(endpoint.finish) then
          obj:playSFXOnceCT(sound, endpoint.finish, volume * (finite(endpoint.afterFireVolumeCoef) or 1), 1, 1, 0)
        end
      end
      status = "limiter_pop_flame"
    end
  end
end

function M.onReset()
  cadence = 0; flameBudget = 0; status = "idle"
  burstEnds = nil; burstPulses = 0; burstDelay = 0
end
function M.getStatus() return status end
return M
