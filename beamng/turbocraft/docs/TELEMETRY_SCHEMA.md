# Telemetry schema

Schema: `turbocraft.telemetry.v2` (original v1 columns retained as ordered prefix)

Columns are emitted in a deterministic order:

`timestamp_s, vehicle, engine_or_adapter, rpm, throttle_or_load,
target_boost_psi, measured_boost_psi, manifold_abs_pa, ambient_pa,
control_or_wastegate, spool_state, valid, error_flags, signal_source,
sample_sequence, measurement_kind, vacuum_available, ambient_source,
manifold_source, turbo_rpm, shaft_torque_nm, shaft_power_kw,
induction_family, hardware_id, afterfire_source`

Vehicle telemetry publishes at 20Hz; the logger retains at most one real sample
per 0.1 simulation seconds, and also accepts the first sample after a time reset.
Control-only pushes do not manufacture log rows. Non-player samples are ignored.
Missing numeric fields serialize empty; they are not filled with zero.
`spool_state` is the native shaft ratio only, not a smoothed fictional spool.
`shaft_power_kw` = real `outputTorque1` (Nm) * real `outputAV1` (rad/s) / 1000.
This is shaft output power, not certified crank/wheel dyno horsepower.

`manifold_gauge` requires verified MAP/ambient keys and units; pressure equals
(MAP - ambient) / 6894.757293168. `compressor_gauge` is native forced-induction
gauge PSI, not proof of manifold vacuum. No standard atmosphere is substituted.
`ambient_source` / `manifold_source` state unavailable explicitly.
`afterfire_source` names the native event route only; it is **not** an afterfire
event counter or proof that a flame occurred.

The gauge uses the same unfiltered `measured_boost_psi` and rounds the digital
display to 0.1 PSI. Compare actual captured gauge snapshots and CSV using
`tools/check_gauge_csv.py`; this requires real matched samples across three
hardware IDs, low/mid/high RPM and measured manifold vacuum. The model-estimate
CSV intentionally has a different schema and cannot pass this gate.

CSV is UTF-8 text, uses a dot decimal separator, RFC-style quote escaping, and
does not silently overwrite a prior session during the same game process.
