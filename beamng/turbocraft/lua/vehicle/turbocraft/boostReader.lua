local core = require("turbocraft/core")
local M = {}

local UNIT_TO_PA = {Pa = 1, kPa = 1000, bar = 100000}

local function number(value)
  value = tonumber(value)
  return core.isFinite(value) and value or nil
end

local function absolute(values, key, unit)
  local value = key and number(values[key])
  local factor = UNIT_TO_PA[unit]
  if value and factor and value > 0 and core.isFinite(value * factor) then return value * factor end
end

-- Unqualified MAP names have no universal unit contract. An adapter must supply
-- verified keys/units; never infer units from magnitude (deep vacuum is ambiguous).
function M.read(values, contract)
  values = values or {}
  contract = contract or {}
  local errors = {}
  if type(contract) ~= "table" or (next(contract) and not M.validContract(contract)) then
    contract = {}
    errors[#errors + 1] = "pressure_contract_invalid"
  end
  local ambientPa = absolute(values, contract.ambientKey, contract.ambientUnit)
  local manifoldPa = absolute(values, contract.manifoldKey, contract.manifoldUnit)
  local state = {
    valid = false, ambientPa = ambientPa, manifoldAbsPa = manifoldPa,
    ambientSource = ambientPa and ("electrics." .. contract.ambientKey) or "unavailable",
    manifoldSource = manifoldPa and ("electrics." .. contract.manifoldKey) or "unavailable",
    signalSource = "none", measurementKind = "unavailable", vacuumAvailable = false
  }
  if manifoldPa and ambientPa then
    state.measuredBoostPsi = core.paToPsi(manifoldPa - ambientPa)
    state.signalSource = state.manifoldSource .. "-" .. state.ambientSource
    state.measurementKind, state.vacuumAvailable = "manifold_gauge", true
  else
    if contract.manifoldKey or values.manifoldPressure or values.intakePressure then
      errors[#errors + 1] = "map_contract_or_ambient_unavailable"
    end
    -- These native forced-induction electrics are gauge PSI, but do not prove
    -- manifold vacuum. A zero here must not be converted into invented vacuum.
    local keys = contract.gaugeKey and {contract.gaugeKey} or {"turboBoost", "superchargerBoost"}
    for _, key in ipairs(keys) do
      local value = number(values[key])
      if value then
        state.measuredBoostPsi, state.signalSource = value, "electrics." .. key
        state.measurementKind = contract.gaugeKey and (contract.measurementKind or "adapter_gauge") or "compressor_gauge"
        state.vacuumAvailable = contract.gaugeKey ~= nil and contract.vacuumAvailable == true
        break
      end
    end
    if not state.vacuumAvailable then errors[#errors + 1] = "manifold_vacuum_unavailable" end
  end
  state.valid = core.isFinite(state.measuredBoostPsi)
  if not state.valid then errors[#errors + 1] = "boost_signal_missing" end
  if not ambientPa then errors[#errors + 1] = "ambient_unavailable" end
  state.errorFlags = table.concat(errors, "|")
  return state
end

function M.validContract(contract)
  if type(contract) ~= "table" then return false end
  if contract.gaugeKey then
    return type(contract.gaugeKey) == "string" and contract.gaugeUnit == "PSI"
  end
  return type(contract.manifoldKey) == "string" and UNIT_TO_PA[contract.manifoldUnit] ~= nil
    and type(contract.ambientKey) == "string" and UNIT_TO_PA[contract.ambientUnit] ~= nil
end

return M
