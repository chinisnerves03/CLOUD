local M = {}

M.SCHEMA_VERSION = "turbocraft.telemetry.v2"
M.COLUMNS = {
  "timestamp_s", "vehicle", "engine_or_adapter", "rpm", "throttle_or_load",
  "target_boost_psi", "measured_boost_psi", "manifold_abs_pa", "ambient_pa",
  "control_or_wastegate", "spool_state", "valid", "error_flags", "signal_source",
  "sample_sequence", "measurement_kind", "vacuum_available", "ambient_source",
  "manifold_source", "turbo_rpm", "shaft_torque_nm", "shaft_power_kw",
  "induction_family", "hardware_id", "afterfire_source"
}

local function scalar(value)
  if value == nil then return "" end
  if type(value) == "boolean" then return value and "true" or "false" end
  if type(value) == "number" then
    if value ~= value or value == math.huge or value == -math.huge then return "" end
    return string.format("%.9g", value)
  end
  return tostring(value)
end

function M.escape(value)
  local text = scalar(value)
  if text:find('[,\r\n"]') then
    return '"' .. text:gsub('"', '""') .. '"'
  end
  return text
end

function M.header()
  return table.concat(M.COLUMNS, ",")
end

function M.row(record)
  local fields = {}
  for i, key in ipairs(M.COLUMNS) do fields[i] = M.escape(record[key]) end
  return table.concat(fields, ",")
end

function M.metadata(modVersion, gameVersion)
  return "# schema=" .. M.SCHEMA_VERSION .. ",mod=" .. M.escape(modVersion or "unknown") ..
    ",game=" .. M.escape(gameVersion or "unknown")
end

return M
