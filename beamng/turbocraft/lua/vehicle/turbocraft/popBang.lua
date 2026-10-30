-- Overrun pop/bang and anti-lag shift sounds. Sound only: no fuel, spark or boost physics are changed.
-- Samples are original synthesis (tools/make_original_audio.py); variants are picked at random so
-- repeated lifts and shifts never sound like the same clip.
local M = {}

local DIR = "art/sound/turbocraft/"
local POOLS = {
  pop = {"pop_a", "pop_b", "pop_c", "pop_d"},
  bang = {"bang_a", "bang_b", "bang_c"},
  burble = {"burble_a", "burble_b", "burble_c"},
  up = {"antilag_up_a", "antilag_up_b", "antilag_up_c"},
  down = {"antilag_down_a", "antilag_down_b", "antilag_down_c"},
  whine = {"limiter_whine_a", "limiter_whine_b"},
}
local MIN_RPM, COOLDOWN = 3000, 1.0
local WHINE_COOLDOWN = .35

local sources, lastPick = {}, {}
local ready, volumeCoef, status = false, 1, "pop_bang_off"
local queue, clock = {}, 0
local armed, cooldown = false, 0
local limiterHeld, whineCooldown = false, 0

local function finite(value)
  value = tonumber(value)
  return value and value == value and math.abs(value) < math.huge and value or nil
end

local function clamp(value, low, high) return math.max(low, math.min(high, value)) end

local function pick(pool)
  local names = POOLS[pool]
  local index = math.random(#names)
  if #names > 1 and index == lastPick[pool] then index = index % #names + 1 end
  lastPick[pool] = index
  return sources[names[index]]
end

local function play(source, volume, pitch)
  if not source or volume <= 0 then return end
  obj:setVolumePitch(source, clamp(volume * volumeCoef, 0, 1.5), pitch)
  obj:playSFX(source)
end

function M.configure(data, node)
  M.onReset()
  sources, lastPick, ready = {}, {}, false
  local engineData = type(data) == "table" and data.mainEngine or {}
  local kit = type(data) == "table" and ((data.turbocharger or {}).turbocraftKit or (data.supercharger or {}).turbocraftKit)
  if not kit then status = "pop_bang_requires_turbocraft_kit"; return false end
  volumeCoef = clamp(finite(engineData.turbocraftPopBangVolume) or 1, 0, 2)
  if volumeCoef <= 0 then status = "pop_bang_disabled_by_volume"; return false end
  node = finite(node)
  if not node or node < 0 or not obj or type(obj.createSFXSource2) ~= "function"
      or type(obj.setVolumePitch) ~= "function" or type(obj.playSFX) ~= "function" then
    status = "pop_bang_audio_api_unavailable"
    return false
  end
  for _, names in pairs(POOLS) do
    for _, name in ipairs(names) do
      local ok, id = pcall(obj.createSFXSource2, obj, DIR .. name .. ".wav", "AudioDefault3D",
        "TurboCraftPop_" .. name, node, -1)
      if not ok or not finite(id) or id < 0 then
        sources = {}
        status = "pop_bang_source_creation_failed:" .. name
        return false
      end
      sources[name] = id
    end
  end
  ready, status = true, "pop_bang_ready"
  return true
end

local function enqueue(delay, pool, volume, pitch)
  queue[#queue + 1] = {at = clock + delay, pool = pool, volume = volume, pitch = pitch}
end

local function schedule(intensity)
  local t = .03
  if intensity >= .6 then
    enqueue(t, "bang", .62 + .38 * intensity, .95 + math.random() * .1)
    t = t + .14 + math.random() * .08
  end
  if intensity >= .35 then
    enqueue(t, "burble", .5 + .4 * intensity, .96 + math.random() * .1)
    t = t + .2 + math.random() * .12
  end
  local volume = .75 + .25 * intensity
  for _ = 1, 2 + math.floor(intensity * 5) do
    enqueue(t, "pop", volume, .9 + math.random() * .2)
    t = t + .07 + math.random() * .15
    volume = volume * .86
  end
end

function M.update(dt, engine, values, data)
  dt = finite(dt) or 0
  if not ready or dt <= 0 then return end
  clock = clock + dt
  cooldown = math.max(0, cooldown - dt)
  values = values or {}
  local throttle = finite(engine and engine.requestedThrottle) or finite(values.throttle)
  local av = finite(engine and engine.outputAV1)
  local rpm = av and math.abs(av) * 30 / math.pi
  if not throttle or not rpm or engine.isDisabled or engine.isBroken
      or engine.requiredEnergyType == "diesel" or rpm < 1800 then
    queue, armed = {}, false
    return
  end
  -- Held-throttle rev-limiter cut on drift/hardcut profiles: one rising whine per cut.
  local profile = data and data.mainEngine and data.mainEngine.turbocraftEffectsProfile
  local limit = finite(engine.revLimiterAV)
  local cutting = limit and limit > 0 and math.abs(av) >= limit * .97 and throttle >= .5
  whineCooldown = math.max(0, whineCooldown - dt)
  if cutting and not limiterHeld and whineCooldown <= 0 and (profile == "hardcut" or profile == "drift") then
    play(pick("whine"), .8 + .15 * math.random(), .96 + math.random() * .08)
    whineCooldown = WHINE_COOLDOWN
    status = "limiter_whine"
  end
  limiterHeld = cutting

  if throttle >= .4 then queue = {} end
  if throttle >= .55 then armed = true end
  if armed and throttle <= .12 and cooldown <= 0 then
    armed = false
    if rpm >= MIN_RPM then
      local boost = math.max(0, finite(values.turboBoost) or finite(values.superchargerBoost) or 0)
      local intensity = clamp(clamp((rpm - 2800) / 3700, 0, 1) * .6 + clamp(boost / 15, 0, 1) * .4, 0, 1)
      schedule(intensity)
      cooldown = COOLDOWN
      status = "pop_bang_sequence_queued"
    end
  end
  local index = 1
  while index <= #queue do
    local item = queue[index]
    if item.at <= clock then
      table.remove(queue, index)
      play(pick(item.pool), item.volume, item.pitch)
    else
      index = index + 1
    end
  end
end

-- Gear-change anti-lag: upshifts get a short hard burst, downshifts a ragged trailing crackle.
function M.playShift(kind, load)
  if not ready then return false end
  local pool = kind == "down" and "down" or "up"
  play(pick(pool), .55 + .45 * clamp(finite(load) or 0, 0, 1), .96 + math.random() * .1)
  status = "pop_bang_shift_" .. pool
  return true
end

function M.onReset()
  queue, clock, armed, cooldown = {}, 0, false, 0
  limiterHeld, whineCooldown = false, 0
end

function M.getStatus() return status end

return M
