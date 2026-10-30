local M = {}
local csv = require("turbocraft/csv")

local SETTINGS_FILE = "/settings/turbocraft_settings.json"
local TELEMETRY_DIR = "/settings/turbocraft/telemetry"
local MOD_VERSION = "1.0.2"
local APP_NAME = "TurboCraftMonitor"
local APP_PLACEMENT = {width = "220px", height = "220px"}
local LEGACY_APP_SIZES = {
  ["205pxx220px"] = true,
  ["360pxx136px"] = true,
  ["440pxx180px"] = true,
}
local settingsCache
local currentState = {target_boost_psi = 8, valid = false, control_or_wastegate = "waiting_for_vehicle"}
local logger = {active = false, lines = {}, path = nil, sampleCount = 0, writeError = nil}
local sessionCounter = 0
local BOOST_MODES = {"LOW", "MED", "HIGH"}
local telemetryAge = 0
local lastLoggedTime
local cabinAge, cabinVehicle, cabinValue, cabinVehicleId = 0, nil, nil, nil

local function clampTarget(value, fallback)
  value = tonumber(value)
  if not value or value ~= value or value == math.huge or value == -math.huge then value = fallback end
  return math.max(0, math.min(200, value))
end

local function loadSettings()
  if not settingsCache then
    settingsCache = jsonReadFile(SETTINGS_FILE) or {}
    local oldTarget = clampTarget(settingsCache.targetBoostPsi, 8)
    settingsCache.boostTargets = settingsCache.boostTargets or {}
    settingsCache.boostTargets.LOW = clampTarget(settingsCache.boostTargets.LOW, 8)
    settingsCache.boostTargets.MED = clampTarget(settingsCache.boostTargets.MED, oldTarget)
    settingsCache.boostTargets.HIGH = clampTarget(settingsCache.boostTargets.HIGH, math.max(30, oldTarget))
    if not settingsCache.boostTargets[settingsCache.boostMode] then settingsCache.boostMode = "MED" end
    settingsCache.targetBoostPsi = settingsCache.boostTargets[settingsCache.boostMode]
  end
  return settingsCache
end

local function saveSettings()
  jsonWriteFile(SETTINGS_FILE, loadSettings(), true)
end

local function playerVehicle()
  return getPlayerVehicle and getPlayerVehicle(0) or nil
end

local function objectId(vehicle)
  if not vehicle then return nil end
  local getter = vehicle.getID or vehicle.getId
  if type(getter) ~= "function" then return nil end
  local ok, id = pcall(getter, vehicle)
  return ok and id or nil
end

local function vehicleCommand(code)
  local vehicle = playerVehicle()
  if not vehicle then return false end
  -- extensions/auto/turbocraft.lua is loaded at the root as "turbocraft". Asking the extensions table for any
  -- other name (e.g. auto_turbocraft) makes BeamNG load a second copy that publishes duplicate telemetry.
  vehicle:queueLuaCommand("local tc = rawget(_G, 'turbocraft') if tc then " .. code .. " end")
  return true
end

local function loggerState()
  return {active = logger.active, path = logger.path, sampleCount = logger.sampleCount, writeError = logger.writeError}
end

local function pushState()
  local state = deepcopy(currentState or {})
  local settings = loadSettings()
  state.boost_mode = settings.boostMode
  state.boost_targets = deepcopy(settings.boostTargets)
  state.target_boost_psi = settings.targetBoostPsi
  state.logger = loggerState()
  guihooks.trigger("TurboCraftState", state)
end

local function migrateAppPlacement()
  local layouts = extensions and extensions.ui_appLayouts
  if not layouts or type(layouts.getCurrentLayout) ~= "function"
    or type(layouts.applyPlacementPatch) ~= "function"
    or type(layouts.setCurrentLayout) ~= "function" then return end

  local ok, current = pcall(layouts.getCurrentLayout)
  if not ok or type(current) ~= "table" or type(current.filename) ~= "string" then return end

  local changed = false
  for index, app in ipairs(current.apps or {}) do
    local placement = type(app) == "table" and app.appName == APP_NAME and app.placement
    if type(placement) == "table" then
      local oldSize = tostring(placement.width) .. "x" .. tostring(placement.height)
      if LEGACY_APP_SIZES[oldSize] then
        local patch = deepcopy(placement)
        patch.width, patch.height = APP_PLACEMENT.width, APP_PLACEMENT.height
        local patched, result = pcall(layouts.applyPlacementPatch, current.filename, index - 1, patch)
        if patched and result then changed = true end
      end
    end
  end

  if changed then pcall(layouts.setCurrentLayout, current.filename) end
end

local function ensureDirectory()
  if FS and FS.directoryExists then
    local ok, exists = pcall(function() return FS:directoryExists(TELEMETRY_DIR) end)
    if not ok then return false end
    if exists then return true end
  end
  if FS and FS.directoryCreate then
    local ok, result = pcall(function() return FS:directoryCreate(TELEMETRY_DIR, true) end)
    return ok and result ~= false
  end
  return false
end

local function writeText(path, text)
  if writeFile then
    local ok, result = pcall(writeFile, path, text)
    return ok and result ~= false
  end
  if FS and FS.writeFile then
    local ok, result = pcall(function() return FS:writeFile(path, text) end)
    return ok and result ~= false
  end
  return false
end

local function flushLogger()
  if not logger.path then return false end
  local ok = writeText(logger.path, table.concat(logger.lines, "\n") .. "\n")
  if ok then logger.writeError = nil else logger.writeError = "csv_write_failed" end
  return ok
end

local function newSessionPath()
  if not FS or type(FS.fileExists) ~= "function" then return nil, "csv_collision_check_unavailable" end
  local stamp = os and os.date and os.date("%Y%m%d_%H%M%S") or "session"
  for _ = 1, 1000 do
    sessionCounter = sessionCounter + 1
    local path = string.format("%s/turbocraft_%s_%03d.csv", TELEMETRY_DIR, stamp, sessionCounter)
    if not FS:fileExists(path) then return path end
  end
  return nil, "csv_session_path_exhausted"
end

function M.setTargetBoost(value)
  value = tonumber(value)
  if not value or value ~= value or value == math.huge or value == -math.huge then return false end
  value = clampTarget(value, 8)
  local settings = loadSettings()
  settings.boostTargets[settings.boostMode] = value
  settings.targetBoostPsi = value
  saveSettings()
  currentState.target_boost_psi = value
  vehicleCommand(string.format("tc.setTargetBoost(%.9g)", value))
  pushState()
  return true
end

function M.setBoostTarget(mode, value)
  if mode ~= "LOW" and mode ~= "MED" and mode ~= "HIGH" then return false end
  value = tonumber(value)
  if not value or value ~= value or value == math.huge or value == -math.huge then return false end
  local settings = loadSettings()
  settings.boostTargets[mode] = clampTarget(value, 8)
  saveSettings()
  if mode == settings.boostMode then
    return M.setTargetBoost(settings.boostTargets[mode])
  end
  pushState()
  return true
end

function M.nextBoostMode()
  local settings = loadSettings()
  local index = 1
  for i, mode in ipairs(BOOST_MODES) do if mode == settings.boostMode then index = i break end end
  settings.boostMode = BOOST_MODES[index % #BOOST_MODES + 1]
  settings.targetBoostPsi = settings.boostTargets[settings.boostMode]
  saveSettings()
  vehicleCommand(string.format("tc.setTargetBoost(%.9g)", settings.targetBoostPsi))
  pushState()
  return settings.boostMode
end

function M.requestState()
  migrateAppPlacement()
  vehicleCommand(string.format("tc.setTargetBoost(%.9g); tc.requestState()", loadSettings().targetBoostPsi))
  pushState()
end

function M.startLogger()
  if logger.active then return true end
  if not ensureDirectory() then
    logger.writeError = "csv_directory_unavailable"
    pushState()
    return false
  end
  logger.path, logger.writeError = newSessionPath()
  if not logger.path then pushState() return false end
  logger.active = true
  logger.sampleCount = 0
  lastLoggedTime = nil
  logger.writeError = nil
  logger.lines = {csv.metadata(MOD_VERSION, beamng_version or "unknown"), csv.header()}
  if not flushLogger() then logger.active = false end
  pushState()
  return logger.writeError == nil
end

function M.stopLogger()
  if logger.active then flushLogger() end
  logger.active = false
  pushState()
  return logger.writeError == nil
end

function M.toggleLogger()
  if logger.active then return M.stopLogger() end
  return M.startLogger()
end

function M.onVehicleTelemetry(state)
  if type(state) ~= "table" then return end
  local activeId = objectId(playerVehicle())
  if activeId ~= nil and state.vehicle_id ~= activeId then return end
  currentState = state
  telemetryAge = 0
  local timestamp = tonumber(state.timestamp_s)
  if logger.active and timestamp and (not lastLoggedTime or timestamp < lastLoggedTime
    or timestamp - lastLoggedTime >= 0.099) then
    logger.lines[#logger.lines + 1] = csv.row(state)
    lastLoggedTime = timestamp
    logger.sampleCount = logger.sampleCount + 1
    if logger.sampleCount % 10 == 0 then flushLogger() end
  end

  pushState()
end

local function updateCabinAudio(dt)
  cabinAge = cabinAge + dt
  if cabinAge < .1 or not core_camera or not core_camera.isCameraInside or not core_camera.getPositionXYZ or not vec3 then return end
  cabinAge = 0
  local vehicle = playerVehicle()
  local ok, inside = pcall(function()
    return core_camera.isCameraInside(0, vec3(core_camera.getPositionXYZ()))
  end)
  if not ok then return end
  inside = inside == true or (tonumber(inside) or 0) > .5
  local id = objectId(vehicle)
  if cabinVehicleId ~= id then
    if cabinVehicle then pcall(function() cabinVehicle:queueLuaCommand("local tc=rawget(_G,'turbocraft') if tc then tc.setCabinAudioState(false) end") end) end
    cabinValue = nil
  end
  if vehicle and (cabinValue ~= inside or cabinVehicleId ~= id) then
    vehicleCommand("tc.setCabinAudioState(" .. tostring(inside) .. ")")
  end
  cabinVehicle, cabinValue, cabinVehicleId = vehicle, inside, id
end

function M.onUpdate(dtReal)
  updateCabinAudio(math.max(0, tonumber(dtReal) or 0))
  telemetryAge = telemetryAge + math.max(0, tonumber(dtReal) or 0)
  if telemetryAge > 0.5 and currentState.valid then
    currentState.valid = false
    currentState.measured_boost_psi = nil
    currentState.manifold_abs_pa = nil
    currentState.error_flags = "telemetry_stale"
    currentState.control_or_wastegate = "monitor_only_stale"
    currentState.turboDetected = false
    pushState()
  end
end

-- Read-only race snapshot; the caller must check vehicle_id and applied control status.
function M.getCompetitionState()
  return {vehicle_id = currentState.vehicle_id, turboDetected = currentState.turboDetected,
    target_boost_psi = loadSettings().targetBoostPsi,
    control_or_wastegate = currentState.control_or_wastegate}
end

local function scheduleVehicleApply()
  currentState = {valid = false, control_or_wastegate = "waiting_for_vehicle",
    error_flags = "waiting_for_vehicle"}
  telemetryAge, lastLoggedTime = 0, nil
  pushState()
  vehicleCommand(string.format("tc.setTargetBoost(%.9g); tc.requestState()", loadSettings().targetBoostPsi))
end

local function applyForPlayerVehicle(vehicleId)
  -- Traffic/race vehicles raise the same hooks; they must not clear the player's live sample.
  if vehicleId ~= nil and vehicleId ~= objectId(playerVehicle()) then return end
  scheduleVehicleApply()
end

M.onVehicleSpawned = applyForPlayerVehicle
M.onVehicleResetted = applyForPlayerVehicle
M.onVehicleReplaced = applyForPlayerVehicle
M.onVehicleSwitched = function(oldId, newId, player)
  if player ~= nil and player ~= 0 then return end
  applyForPlayerVehicle(newId)
end
M.onClientPostStartMission = scheduleVehicleApply
M.onExtensionUnloaded = function() if logger.active then M.stopLogger() end end

return M
