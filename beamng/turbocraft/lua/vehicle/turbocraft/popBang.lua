-- Overrun pop/bang, burble and anti-lag shift sounds. Sound only: no fuel, spark or boost physics are changed.
-- Samples are cut from one recorded car (docs/v1.0.0/AUDIO_PROVENANCE.md); variants are picked at random
-- so repeated lifts and shifts never sound like the same clip.
-- A lift-off or gear change opens an "overrun window": for a time that grows with RPM the exhaust keeps
-- burbling, popping and banging (with tailpipe flames), the turbo whistles as if anti-lag holds it spinning,
-- and the crackle thins out as the window runs down or RPM falls. Back on the throttle ends a lift window.
local M = {}
local eventEffects = require("turbocraft/eventEffects")

local DIR = "art/sound/turbocraft/"
local POOLS = {
  pop = {"pop_a", "pop_b", "pop_c", "pop_d"},
  bang = {"bang_a", "bang_b", "bang_c"},
  burble = {"burble_a", "burble_b", "burble_c"},
  up = {"antilag_up_a", "antilag_up_b", "antilag_up_c"},
  down = {"antilag_down_a", "antilag_down_b", "antilag_down_c"},
  whine = {"limiter_whine_a", "limiter_whine_b"},
  spool = {"antilag_spool_a", "antilag_spool_b"},
}
local MIN_RPM, COOLDOWN = 3000, 1.0
local WHINE_COOLDOWN = .35

local sources, lastPick = {}, {}
local ready, volumeCoef, status = false, 1, "pop_bang_off"
local queue, clock = {}, 0
local armed, cooldown = false, 0
local limiterHeld, whineCooldown = false, 0
-- overrun window: mode ("lift"/"up"/"down"), time left/total, next event time, last burble/flame times
local window
local lastEngine, lastData, lastRpm, lastBoost = nil, nil, 0, 0
local FLAME_GAP = .09

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

local function rpmIntensity(rpm, boost)
  return clamp(clamp((rpm - 2800) / 3700, 0, 1) * .6 + clamp(boost / 15, 0, 1) * .4, 0, 1)
end

local function flame()
  if not window or clock - window.lastFlame < FLAME_GAP or not lastEngine then return end
  window.lastFlame = clock
  eventEffects.flame(lastEngine, lastData)
end

local DURATION = {lift = {.8, 1.6}, down = {.7, 1.2}, up = {.3, .5}}

local function openWindow(mode, intensity)
  local d = DURATION[mode]
  local total = d[1] + d[2] * intensity
  if window and window.left > total then return end  -- a longer window is already running
  window = {mode = mode, total = total, left = total, nextAt = clock + .02, boost = lastBoost,
    lastBurble = -1, lastFlame = window and window.lastFlame or -1}
  if intensity >= .25 then
    play(pick("spool"), .35 + .55 * intensity, .92 + .16 * intensity + math.random() * .04)
  end
end

-- One event of the running window: rate, size and flame chance follow live RPM and fade with time left.
local function stepWindow()
  local fade = clamp(window.left / window.total, 0, 1)
  -- anti-lag holds the turbo spinning, so boost from the moment the window opened keeps counting
  local heat = rpmIntensity(lastRpm, math.max(lastBoost, window.boost * fade)) * (.35 + .65 * fade)
  local r = math.random()
  if r < .08 + .22 * heat then
    play(pick("bang"), .55 + .45 * heat, .94 + math.random() * .1)
    flame()
  elseif clock - window.lastBurble > .45 and r < .55 then
    window.lastBurble = clock
    play(pick("burble"), .45 + .45 * heat, .94 + math.random() * .12)
  else
    play(pick("pop"), .4 + .55 * heat, .88 + math.random() * .24)
    if math.random() < heat * .6 then flame() end
  end
  -- high RPM: dense crackle every ~60 ms; low RPM or late in the window: lazy burble every ~250 ms
  window.nextAt = clock + (.26 - .22 * heat) * (.7 + math.random() * .6)
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
    queue, armed, window = {}, false, nil
    return
  end
  lastEngine, lastData, lastRpm = engine, data, rpm
  lastBoost = math.max(0, finite(values.turboBoost) or finite(values.superchargerBoost) or 0)
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

  if throttle >= .4 then
    queue = {}
    if window and window.mode == "lift" then window = nil end
  end
  if throttle >= .55 then armed = true end
  if armed and throttle <= .12 and cooldown <= 0 then
    armed = false
    if rpm >= MIN_RPM then
      openWindow("lift", rpmIntensity(rpm, lastBoost))
      cooldown = COOLDOWN
      status = "pop_bang_overrun_window"
    end
  end
  if window then
    window.left = window.left - dt
    if window.left <= 0 or rpm < MIN_RPM * .8 then
      window = nil
    elseif clock >= window.nextAt then
      stepWindow()
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

-- Gear-change anti-lag: upshifts get a short hard burst then a brief crackle and turbo whistle,
-- downshifts a ragged crackle that keeps burbling while the revs fall.
function M.playShift(kind, load)
  if not ready then return false end
  local pool = kind == "down" and "down" or "up"
  local intensity = rpmIntensity(lastRpm, lastBoost)
  play(pick(pool), .55 + .45 * clamp(finite(load) or 0, 0, 1), .96 + math.random() * .1)
  if lastRpm >= MIN_RPM then openWindow(pool, intensity) end
  status = "pop_bang_shift_" .. pool
  return true
end

function M.onReset()
  queue, clock, armed, cooldown = {}, 0, false, 0
  limiterHeld, whineCooldown = false, 0
  window, lastEngine, lastData, lastRpm, lastBoost = nil, nil, nil, 0, 0
end

function M.getStatus() return status end

return M
