# Test report — v1.0.0 development candidate

2026-10-24 follow-up: **PARTIAL IN-GAME VALIDATION. Release blocked.**
Actual BeamNG **0.40.3.0.290897** harness completed all 12 default families:
11 initial PASS and one Large Twin RPM-coverage FAIL; a separate extended-pull
retry passed without changing hardware/gear/targets or safety/coverage gates.
See [measured results, console errors and remaining gates](v1.0.0/INGAME_HARNESS_REPORT.md).
Raw data, measured CSV and eight actual-sample SVGs accompany that report
(mechanical HP is an explicit unit conversion from measured shaft kW).

The following offline summary predates that live follow-up.
See [complete status](v1.0.0/RELEASE_STATUS.md) and actual captured offline
command output in `v1.0.0/verification.json`.

Confirmed results: runtime Lua syntax 10 files / 0 errors; Lua
126 passed / 0 failed; measured/vacuum gauge lifecycle tests; actual universal
catalog integration (40 kits / 12 families); catalog, header/exhaust profile
and legacy ID/geometry preservation gates; synthetic evidence-tool tests;
12 original WAVs reproduce exactly with verified SHA/PCM/levels/seams; all
19 Lua (including test harness) and 7 JavaScript files are syntax-clean.
Original blower audio is opt-in and disabled by default, not live-validated.
The synthetic fixtures are not native/runtime measurements.

Eight generated SVG graphs and 960 CSV rows are labeled **OFFLINE ESTIMATES**.
Turbo modeling is approximate; blower/heat/flow/torque illustrations are not
verified native predictions. They do not pass the requested new in-game
same-engine/gearbox/condition comparison.

Initial window-title inspection preceded the subsequent actual harness runs.
Audio, flame appearance and live Monitor/CSV comparison are still
**NOT TESTED IN GAME**. Console findings and fitment/driving measurements are
now available in the linked report; no clean-console claim is made.
Historical results below apply only to their stated builds, not v0.9.9 or 1.0.0.

---

# Historical test report — v0.9.1 header/exhaust RPM curves

Date: 19 October 2026. These curves are simulation-only profiles, not measured
dyno data. The RPM/boost values below come from `tools/turbo_model.py`, not from
an in-game run.

## Offline — PASS

- Lua syntax: 9 files, 0 errors; TurboCraft Lua suite: 60 passed, 0 failed.
- `tests/header_exhaust_curve_test.py`: profile ordering, representative boost
  curves, and generator/JBeam curve synchronization passed.
- `tests/stage_profile_test.py`: physical hardware catalog profiles passed.
- `tools/package.py --validate-only`: source/package layout and curve
  synchronization passed; no archive was written by this validation command.
- Updated pickup, shared, and ETK-C JBeam files parsed as JSON: 3/3.

Representative modeled boost from each isolated curve (66 mm turbo, baseline
cover/turbine, PSI at 2,000 / 3,000 / 5,000 engine RPM). These values show the
RPM-curve effect only; installed parts also apply their existing scalar flow,
back-pressure, and friction modifiers:

| Profile | PSI |
|---|---|
| Cast header | 1.0 / 13.6 / 37.0 |
| Tubular header | 0.9 / 13.6 / 39.9 |
| Equal-length header | 0.9 / 13.9 / 40.7 |
| Street exhaust | 1.0 / 13.6 / 36.7 |
| Sport exhaust | 0.9 / 13.6 / 39.2 |
| Race exhaust | 0.9 / 13.7 / 39.5 |
| Open downpipe | 0.9 / 13.7 / 40.2 |

## Not run in game

- No BeamNG load, Parts-menu check, or dyno sweep was performed for these new
  profiles. In-game response and compatibility remain unverified.

---

# Test report — v0.6.2 (5-slot build)

Date: 12 October 2026 (Asia/Bangkok). BeamNG.drive 0.39.4.0.20972, isolated
test profile (only TurboCraft + an automated harness), Gridmap V2.
Raw data: `tests/ingame/results/sweep2/` and `tests/ingame/results/run5/`.

## Offline — PASS

- `gen_sizes.py` output unchanged; Lua syntax 6 files 0 errors; 25 tests passed,
  0 failed; packaging gate clean.

## Dyno sweep — PASS (manual D-Series `d15_4wd_M`, 3rd gear, Ultra long block, wastegate open)

Engine rpm where boost reaches 5 and 15 PSI, game / `turbo_model.py`:

| Wheel / cover / turbine | 5 PSI | 15 PSI |
|---|---|---|
| 42 mm / 0.60 / 0.82 | 1846 / 1800 (+3 %) | 2327 / 2300 (+1 %) |
| 66 mm / 0.60 / 0.82 | 2420 / 2400 (+1 %) | 3126 / 3100 (+1 %) |
| 90 mm / 0.60 / 0.82 | 3207 / 3158 (+2 %) | 4047 / 4008 (+1 %) |
| 114 mm / 0.60 / 0.82 | 3953 / 3900 (+1 %) | 5039 / 5000 (+1 %) |
| 66 mm / turbine 0.48 | 2190 / 2175 (+1 %) | 2967 / 2960 (+0 %) |
| 66 mm / turbine 1.32 | 2602 / 2562 (+2 %) | 3234 / 3210 (+1 %) |
| 66 mm / cover 0.42 | 2361 / 2338 (+1 %) | 3025 / 3008 (+1 %) |
| 66 mm / cover 0.95 | 2506 / 2483 (+1 %) | 3310 / 3306 (+0 %) |

42 mm at 5000 rpm: 23.1 / 23.1 PSI (flow limit). Above ~5000 rpm the sweep
hits the rev limiter and wheelspin, so "PSI at 5500" cannot be read cleanly;
the 114 mm reads 12.6 vs 15.0 PSI steady state at 5000 rpm because the sweep is
faster than its spool (a transient replay of the model gives 11–13 PSI).

## Pulls from standstill — PASS (automatic `d15_4wd_A`, Heavy Duty long block, 25 PSI target)

| Setup | 0–100 km/h | km/h at 10 s | Max PSI |
|---|---|---|---|
| Stock NA (reference) | 10.81 s | 95 | 0 |
| 42 mm, cast | 5.84 s | 120 | 23.6 (wheel flow limit) |
| 66 mm, cast | 5.56 s | 123 | 25.8 |
| 114 mm, cast | 8.41 s | 113 | 20.1 (lag) |
| 66 mm, long runner | 6.14 s | 121 | 25.7 |
| 66 mm, short runner | 4.86 s | 143 | 26.0 |
| 66 mm, plenum | 5.14 s | 141 | 25.6 |
| 66 mm, short runner + race header + race exhaust | 4.91 s | — (sim paused at 8.8 s) | 26.0 |

Race header + exhaust: exhaust torque loss −19.5 Nm vs −58 Nm stock; parts were
fitted as chosen (header/exhaust/long block not replaced by TurboCraft).
No engine broke in any run.

## Blow-off valve lift-off — PASS (66 mm, 25 PSI, lift after 5 s)

| BOV | turbo rpm at lift | +0.5 s | +1 s | +2 s |
|---|---|---|---|---|
| atmospheric | 112 186 | 61 064 | 42 635 | 26 585 |
| none | 110 845 | 22 058 | 12 462 | 6 557 |

## Log — PASS

No `event:>Vehicle>Forced_Induction>…` sound load errors, no TurboCraft Lua,
JBeam or UI errors in either run.

## Not verified

- Parts-page / HUD screenshot: the harness's `ChangeState` to the Parts menu
  hit a UI router transition timeout, and the user skipped the screenshot.
  The five slots were confirmed through the fitted `partsTree` in every run.

---

# Earlier test report — v0.6.2 (3-slot build)

Date: 12 October 2026 (Asia/Bangkok). BeamNG.drive 0.39.4.0.20972, isolated
test profile (only TurboCraft + an automated test harness), Gridmap V2, stock
Gavril D-Series `d15_4wd_A` (4.5 V8, automatic).

## Offline — PASS

- Lua syntax: 6 files, 0 errors. Unit/integration suite: 25 passed, 0 failed.
- Packaging gate: wheels cover 42–114 mm and change all four physical fields;
  every compressor cover changes `pressureRatePSI`; every turbine housing has
  its own `engineDef`; every slot has a valid default.

## In game — PASS (automated, three runs)

| Check | Result |
|---|---|
| Intake + 3 slots in Parts (wheel 19, cover 6, turbine 6 choices) | PASS (screenshot) |
| `$*` multipliers resolve on the parent turbo (42 mm: inertia 2.2275, exhaust 267288) | PASS |
| HUD/telemetry reports wheel mm, cover A/R, turbine A/R | PASS |
| Adapter reports `Gavril D-Series V8` | PASS (was "engine unconfirmed" in v0.6.1) |
| Wastegate holds target 8 PSI (stall 7.1–8.9 PSI) | PASS |
| Target bounds 0/8/30/200, −5→0, 250→200, "abc" rejected | PASS |
| Two vehicles, 20 s CSV: 220 rows, 0 duplicate / non-increasing timestamps | PASS (v0.6.1: every row doubled) |
| Logger start/stop return success, no write error | PASS |
| Physics reset: telemetry restarts, no stale logger | PASS |
| Restart without TurboCraft: stock D-Series loads; old TurboCraft config falls back to stock intake | PASS |
| TurboCraft Lua/JBeam/UI errors in log | none |

Brake-stall at full throttle, target 200 PSI, 2.6 s (time to reach boost):

| Wheel / Cover / Turbine | 5 PSI | 40 PSI | Peak |
|---|---|---|---|
| 42 / 0.60 / 0.82 | 0.21 s | 1.01 s | 49.5 |
| 66 / 0.60 / 0.82 | 0.21 s | 1.01 s | 113.8 |
| 114 / 0.60 / 0.82 | 0.31 s | 1.11 s | 111.9 |
| 66 / 0.42 / 0.82 | 0.20 s | 0.71 s | 162.3 |
| 66 / 0.95 / 0.82 | 0.31 s | 1.51 s | 72.1 |
| 66 / 0.60 / 0.48 | 0.27 s | 1.07 s | 113.5 |
| 66 / 0.60 / 1.32 | 0.37 s | 1.07 s | 112.8 |

## Known limits

- Boost rise is capped by `pressureRatePSI` and the turbo shaft reaches speed
  in well under 0.5 s for every wheel, so wheel-size spool differences are
  small (≈0.1 s). The compressor cover changes boost build rate clearly.
- The 66 vs 114 mm and turbine-housing top-end differences are not resolved by
  a 2.6 s brake-stall; a full-gear dyno pull is needed to show them.
- Sustained targets near 200 PSI destroy the stock engine within ~3 s (seen in
  v0.6.1 runs). The 0–200 PSI range is a control range, not a safe range.
- Disabling the mod mid-session and then spawning a D-Series fails inside the
  game's jbeam cache (`nodesMissing`); restarting the game after removing the
  mod works.
