local M = {}
-- Attenuation-only voicing over the fitted engine's native exhaust bank.
local headers = {
  cast = {eq_b_gain = -5, eq_d_gain = -2},
  tubular = {eq_b_gain = -2, eq_d_gain = -.5, eq_e_gain = -.5},
  equal_length = {eq_c_gain = -2, eq_e_gain = -1}
}
local pipes = {
  street = {eq_b_gain = -9, eq_d_gain = -4},
  sport = {eq_b_gain = -4, eq_d_gain = -1.5, eq_a_gain = -.5, eq_e_gain = -.5},
  open = {eq_a_gain = -1, eq_e_gain = -1}
}
local owner, paramTable, baseline, applied = nil, nil, {}, {}
local status = "no_turbocraft_exhaust_profile"
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < math.huge end

function M.update(engine, data)
  local definition = engine and data and data[engine.name] or {}
  local header = definition and definition.turbocraftHeaderSound
  local pipe = definition and definition.turbocraftExhaustSound
  if pipe == "race" then pipe = "sport" end
  local config = engine and engine.soundConfiguration and engine.soundConfiguration.exhaust
  local params = config and config.params
  if not params or not engine.engineSoundIDExhaust or type(engine.setEngineSoundParameter) ~= "function" then
    status = (header or pipe) and "native_exhaust_audio_unavailable" or "no_turbocraft_exhaust_profile"
    return
  end
  if owner ~= engine or paramTable ~= params then
    owner, paramTable, baseline, applied = engine, params, {}, {}
  end
  local delta = {}
  for _, profile in pairs({headers[header] or {}, pipes[pipe] or {}}) do
    for key, value in pairs(profile) do delta[key] = (delta[key] or 0) + value end
  end
  -- D-Series's canonical sound section already includes its additive header shelf.
  if headers[header] and definition.soundConfigExhaust == "soundConfigExhaust"
    and finite(definition.turbocraftHeaderStaticHighShelf) then
    delta.eq_b_gain = (delta.eq_b_gain or 0) - definition.turbocraftHeaderStaticHighShelf
  end
  for _, key in ipairs({"eq_a_gain", "eq_b_gain", "eq_c_gain", "eq_d_gain", "eq_e_gain"}) do
    local current = params[key]
    if finite(current) then
      if applied[key] == nil or current ~= applied[key] then baseline[key] = current end
      local value = baseline[key] + (delta[key] or 0)
      if current ~= value then
        engine:setEngineSoundParameter(engine.engineSoundIDExhaust, key, value, "exhaust")
      end
      applied[key] = value
    end
  end
  status = (headers[header] or pipes[pipe]) and ("native_exhaust_eq:" .. (header or "stock") .. "/" .. (pipe or "stock"))
    or "no_turbocraft_exhaust_profile"
end

function M.getStatus() return status end
return M
