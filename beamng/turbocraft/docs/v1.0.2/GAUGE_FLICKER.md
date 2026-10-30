# Gauge alternating readings fix — 2026-10-25

User reports needle/numbers alternating. Reproduced a source defect offline:
all vehicle spawn/reset/replacement hooks, including traffic AI, cleared the
active player's measured state. Other-player switching did the same. Four
regressions failed on r3 behavior and pass after filtering by active vehicle ID
and player0. Real player reset/switch still clears the previous measurement.

Registered the GE stale watchdog at module load instead of defining it only
inside the first telemetry callback. Existing 0.5-second expiry and raw signed
PSI remain unchanged. This fix does not smooth pressure, invent a pressure
sample or keep a stale sample valid. It addresses one demonstrated lifecycle
cause; the reported live setup has not been instrumented.

Lua223/223 and UI measurement/vacuum/scale/stale/mode/lifecycle tests pass.
NOT TESTED IN GAME. Installed r3 needs replacement/restart for this source fix.
