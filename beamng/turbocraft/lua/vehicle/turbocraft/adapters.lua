local M = {}

local function lower(value)
  return string.lower(tostring(value or ""))
end

function M.classify(vehicleDirectory, selectedParts)
  local directory = lower(vehicleDirectory):gsub("\\", "/")
  local isPickup = directory:find("/pickup/?$", 1, false) ~= nil or directory == "pickup"
  local hasV8 = false
  for key, value in pairs(selectedParts or {}) do
    local joined = lower(key) .. " " .. lower(value)
    if joined:find("v8", 1, true) and joined:find("engine", 1, true) then
      hasV8 = true
      break
    end
  end
  if isPickup and hasV8 then
    return "gavril_dseries_v8", "Gavril D-Series V8"
  end
  if isPickup then return "gavril_dseries_generic", "Gavril D-Series (engine unconfirmed)" end
  local model = directory:match("/vehicles/([^/]+)/?$") or ""
  return "universal", model ~= "" and ("Universal adapter (" .. model .. ")") or "Universal adapter"
end

-- BeamNG 0.39 stores the selection as a slot tree (v.config.partsTree); older builds used a flat v.config.parts.
function M.partsFromTree(node, result)
  result = result or {}
  for slotId, child in pairs(type(node) == "table" and node.children or {}) do
    if type(child) == "table" then
      if type(child.chosenPartName) == "string" and child.chosenPartName ~= "" then result[slotId] = child.chosenPartName end
      M.partsFromTree(child, result)
    end
  end
  return result
end

function M.selectedPartsFromRuntime()
  local result = {}
  if v and v.config and type(v.config.partsTree) == "table" then
    M.partsFromTree(v.config.partsTree, result)
  end
  if v and v.config and type(v.config.parts) == "table" then
    for key, value in pairs(v.config.parts) do
      if result[key] == nil then result[key] = value end
    end
  end
  return result
end

function M.vehicleDirectoryFromRuntime()
  if v and v.data then return v.data.vehicleDirectory or v.data.vehiclePath or "" end
  return ""
end

return M

