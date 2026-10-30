# Adapter contract

An adapter identifies a vehicle configuration and reports runtime capabilities.
The core never assumes a vehicle-specific slot name.

Required behavior:

1. Classify from vehicle directory and selected parts.
2. Read signals without mutating the vehicle.
3. Attempt control only through a discovered callable runtime setter.
4. Fall back to `monitor_only` when a capability is missing.
5. Reset all cached vehicle objects on spawn/reset/reload.

The initial specialization is `gavril_dseries_v8`, selected only when the
runtime vehicle directory is `pickup` and an installed engine part identifies
itself as V8. Otherwise the universal or unconfirmed D-Series adapter is used.

## Explicit pressure signals (v1.0.0 candidate)

`v.data.turbocraftPressureSignals` may declare a **verified** source mapping:

```json
{
  "manifoldKey": "verifiedMapSignal",
  "manifoldUnit": "kPa",
  "ambientKey": "verifiedAmbientSignal",
  "ambientUnit": "Pa"
}
```

Keys above are placeholders, **not BeamNG signal names to copy into a vehicle**.
Pa, kPa and bar are supported explicitly; pressure magnitude never selects a
unit. Alternatively a verified gauge source can declare `gaugeKey`, `gaugeUnit:
"PSI"` and `vacuumAvailable`. This is data-only capability metadata, not an
invitation to fabricate readings. Invalid mappings are logged and surfaced.

Without a verified MAP mapping, native `turboBoost`/`superchargerBoost` are
compressor-gauge PSI fallbacks. Active supercharger selection prevents a stale
zero turbo reading from shadowing its real pressure. No ambient or absolute MAP
is reconstructed; no vacuum is promised. Generic `boost` requires an explicit
unit contract now. A native manifold-vacuum mapping remains unverified on 0.40.3.
