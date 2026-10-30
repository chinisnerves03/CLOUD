-- TurboCraft part generator (GE): builds the TurboCraft turbo for every engine intake slot of every vehicle the
-- game has mounted, vanilla and mods, and writes it to /vehicles/common/turbocraft_auto/<vehicle>.jbeam in the
-- user folder. Runs at startup and when mods are (de)activated; skipped when no jbeam file changed.
local M = {}

local gen = require("turbocraft/gen")

local OUT_DIR = "/vehicles/common/turbocraft_auto/"
local STATE_FILE = "/settings/turbocraft/gen_state.json"
local DATA_FILE = "/lua/common/turbocraft/gen_data.json"
local GEN_VERSION = 14

local function statSig(filename)
  local ok, st = pcall(function() return FS:stat(filename) end)
  if ok and type(st) == "table" then
    return tostring(st.filesize or st.size or "") .. ":" .. tostring(st.modtime or st.modTime or "")
  end
  return "?"
end

local function listJbeam()
  local files = {}
  for _, f in ipairs(FS:findFiles("/vehicles/", "*.jbeam", -1, false, false) or {}) do
    if not string.lower(f):find(OUT_DIR, 1, true) then files[#files + 1] = f end
  end
  table.sort(files)
  return files
end

-- hash of every file name + size + modtime: changes when any vehicle jbeam is added, removed or edited
local function signature(files)
  local h = 5381
  local parts = {"v" .. GEN_VERSION, "catalog=" .. statSig(DATA_FILE)}
  for _, f in ipairs(files) do parts[#parts + 1] = f .. "=" .. statSig(f) end
  local text = table.concat(parts, "|")
  for i = 1, #text do
    h = (h * 33 + text:byte(i)) % 4294967296 -- stays below 2^38, exact in doubles
  end
  return string.format("%08x:%d:%d", h, #files, #text)
end

local function existingOutputs()
  local res = {}
  for _, f in ipairs(FS:findFiles(OUT_DIR, "*.jbeam", 0, false, false) or {}) do res[f] = true end
  return res
end

local function outputsMatch(state, outputs)
  if type(state.generatedFiles) ~= "table" or #state.generatedFiles == 0 then return false end
  local expected = {}
  for _, path in ipairs(state.generatedFiles) do
    if not outputs[path] then return false end
    expected[path] = true
  end
  for path in pairs(outputs) do if not expected[path] then return false end end
  return true
end

local function notifyJbeam(filename)
  local ok, jbeamIO = pcall(require, "jbeam/io")
  if ok and jbeamIO and jbeamIO.onFileChanged then pcall(jbeamIO.onFileChanged, filename, "modified") end
end

function M.run(force)
  local t0 = os.clock()
  local data = jsonReadFile(DATA_FILE)
  if type(data) ~= "table" then
    log("E", "TurboCraft", "generator data missing: " .. DATA_FILE)
    return
  end
  local files = listJbeam()
  local sig = signature(files)
  local state = jsonReadFile(STATE_FILE) or {}
  local outputs = existingOutputs()
  if not force and state.signature == sig and outputsMatch(state, outputs) then
    log("I", "TurboCraft", string.format("generated parts up to date (%d jbeam files checked, %.2f s)", #files, os.clock() - t0))
    return
  end

  local parsed = {}
  for _, f in ipairs(files) do
    local text = readFile(f)
    if text and string.lower(text):find("intake", 1, true) then
      local ok, tbl = pcall(jsonReadFile, f)
      if ok and type(tbl) == "table" then parsed[#parsed + 1] = {name = f, data = tbl} end
    end
  end
  local okGen, res = pcall(function() return gen.build(gen.collect(parsed), data) end)
  if not okGen then
    log("E", "TurboCraft", "generator failed: " .. tostring(res))
    return
  end

  local written, unchanged = 0, 0
  for ns, parts in pairs(res.byNamespace) do
    local path = OUT_DIR .. ns .. ".jbeam"
    local text = jsonEncodePretty(parts)
    outputs[path] = nil
    if readFile(path) == text then
      unchanged = unchanged + 1
    else
      writeFile(path, text)
      notifyJbeam(path)
      written = written + 1
    end
  end
  for stale in pairs(outputs) do
    FS:removeFile(stale)
    notifyJbeam(stale)
  end

  local generatedFiles = {}
  for ns in pairs(res.byNamespace) do generatedFiles[#generatedFiles + 1] = OUT_DIR .. ns .. ".jbeam" end
  table.sort(generatedFiles)
  jsonWriteFile(STATE_FILE, {signature = sig, version = GEN_VERSION, slots = #res.report,
    generatedFiles = generatedFiles, report = res.report}, true)
  log("I", "TurboCraft", string.format("generated TurboCraft turbos for %d intake slots (%d jbeam files scanned, %d parsed; %d written, %d unchanged, %d removed) in %.2f s",
    #res.report, #files, #parsed, written, unchanged, tableSize(outputs), os.clock() - t0))
end

local function rerun() M.run(false) end

M.onExtensionLoaded = rerun
M.onModActivated = rerun
M.onModDeactivated = function(mod)
  local name = string.lower(tostring(type(mod) == "table" and (mod.modname or mod.filename) or mod))
  if name:find("turbocraft", 1, true) then
    -- TurboCraft itself is being turned off: remove what it generated so no orphan parts stay behind
    for f in pairs(existingOutputs()) do FS:removeFile(f) notifyJbeam(f) end
    FS:removeFile(STATE_FILE)
    return
  end
  rerun()
end

return M
