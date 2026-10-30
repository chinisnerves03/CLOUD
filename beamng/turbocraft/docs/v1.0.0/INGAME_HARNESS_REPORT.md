# Actual BeamNG harness — 2026-10-24

**Automated fitment/pull/lift checks completed. Full release acceptance remains
PARTIAL, not a claim that sound, flames, Monitor visuals or realism are proved.**

User explicitly requested harness testing. Launched Steam's existing BeamNG
installation using fresh `-userpath` folders inside this workspace, Gridmap V2;
no main-profile Mods change, existing-game termination or publishing.
Both owned launcher/game pairs were stopped after the results finished and
their PIDs were confirmed absent.

## Exact tested candidate and conditions

`dist/TurboCraft_Universal_Framework_v1.0.0-20261024-candidate.zip`
SHA-256 `2D0FE9A475D15B82BB460031BA3A7AE91DFEABBB37F39151A9B9015A9E9CA581`.
The tested mod ZIP is preserved unchanged. The harness was separate.

- Actual game build reported by runtime: **0.40.3.0.290897**.
- D-Series `vehicles/pickup/d15_4wd_M.pc`, V8 4.5L, Ultra internals,
  manual third-gear full-throttle pulls followed by two-second lift/braking.
- Same cast header and street exhaust; requested tuning/target 20 PSI.
  A target is not a pressure clamp for a monitor-only blower.
- Each requested default family/size part ID was confirmed in actual selected
  parts. Full per-run partsTree/variables/device settings are in `raw_results.json`.
- No temperature stabilization was measured/proved. These are road-pull shaft
  output samples, not certified crank/chassis dyno results or a thermally
  controlled v0.9.9-versus-1.0.0 comparison.
- Original synthesized blower overlay stayed **OFF**. It was not audibly tested.

## Actual results

First sweep: **11 PASS, 1 FAIL**. Large Twin hit the 28-second pull limit at
4949.96 RPM, missing the unchanged 5000 RPM coverage requirement.
The failed result is retained, not relabeled.

Retest: only that same Large Twin hardware, with a bounded **45-second** pull
allowance; same 30 PSI / 5450 RPM / broken-engine stop guards.
Reached 5450.17 RPM and **PASS**. No hardware physics, target, gear or coverage
threshold was weakened to make it pass. The retry is a separate run, not a
replacement row secretly merged into the first sweep.

| Family / default | Run | Result | Peak measured PSI | Peak shaft Nm | Peak shaft kW |
|---|---|---|---:|---:|---:|
| Single 60 mm | Initial | PASS | 20.96 | 742.1 | 288.9 |
| Legacy Twin 60 mm each | Initial | PASS | 21.61 | 747.7 | 290.1 |
| Big Single 70 mm | Initial | PASS | 20.93 | 718.7 | 288.6 |
| Large Single 100 mm | Initial | PASS | 21.60 | 563.5 | 270.5 |
| Big Twin 70 mm each | Initial | PASS | 8.67 | 443.8 | 183.2 |
| Large Twin 100 mm each | Initial | FAIL: RPM coverage | 0.83 | 368.1 | 125.4 |
| Large Twin 100 mm each | Extended retry | PASS | 1.30 | 328.8 | 125.0 |
| Roots R19 | Initial | PASS | 21.02 | 567.4 | 241.9 |
| Centrifugal CF1275 | Initial | PASS | 10.98 | 434.6 | 177.0 |
| Big Roots BR26 | Initial | PASS | 21.03 | 561.9 | 239.2 |
| Large Roots LR38 | Initial | PASS | 23.41 | 569.6 | 242.4 |
| Big centrifugal BCF1800 | Initial | PASS | 13.04 | 445.4 | 182.1 |
| Large centrifugal LCF2400 | Initial | PASS | 15.43 | 449.3 | 185.1 |

Maxima may occur at different RPM/timestamps; they are not one operating point.
CSV and graphs also include mechanical HP converted directly from measured
shaft kW using 1 HP = 0.7456998715822702 kW. It is a unit conversion, not
estimated engine efficiency, an extra sensor or a claimed crank dyno.
Oversized twins make little boost on this engine; this was measured rather
than compensated with a fake gain. Blower measurements differ substantially
from earlier offline illustrations, confirming those were **not native-model
predictions**. Do not calibrate or advertise real-vehicle power from either set.

Checks require fitted IDs, at least 20 valid WOT samples, third gear, measured
lift, RPM coverage, no broken-engine flag and no pressure above the 30 PSI
abort threshold. Across initial/retry, every family has a passing measured
pull/lift record. This does not test every one of the 40 hardware sizes.

## Console findings, not a clean-console claim

No `|E|` line containing TurboCraft/tcSweep was found.
However the game console was **not error-free**:

| Scope | Initial | Retry |
|---|---:|---:|
| Input binding descriptions (`engine::ActionMap::addBinding`) | 502 | 70 |
| DLSS NGX initialization (`0xbad00001`) | 1 | 1 |
| Gridmap `track_builder_pieces/items.level.json` missing path | 1 | 1 |

These are recorded in the JSON reports. Without a clean-profile baseline run,
their independence from the candidate is not certified. Generator startup
logged 76 intake slots / 5297 JBeam files scanned / 193 parsed / 31 generated
files, approximately 1.86 seconds; that is a startup observation, not a general
performance benchmark.

## Evidence / reproduction

- `ingame/initial/`: full raw result, fail-closed `report.json`, measured CSV and
  four SVGs (boost, shaft torque, shaft kW and converted mechanical HP).
- `ingame/large_twin_retry/`: separate raw result, PASS report, CSV and SVGs.
- Initial raw SHA-256:
  `CE7D856C35409BCD1B80278D79914C2659762E1B4E79A6153E812B16FC4CE0AD`.
  Each report includes its own raw SHA; profile logs remain local in `test_runs`.
- Profiles: `test_runs/tc100-20261024-234515-210` and
  `test_runs/tc100-20261024-235522-928`.
- Runner: `tests\ingame\run_v100.ps1`; analyzer:
  `tools\report_ingame_v100.py`. Use `--plan` with the retry plan when analyzing
  only the retry. Full console analysis requires the original adjacent
  `beamng.log`; redistributed result-only reanalysis cannot prove console state.

## Still NOT TESTED IN GAME

Audible quality/loudness/pitch/BOV timing; opt-in synthesized-audio playback;
visible afterfire conditions/tip/color/brightness/duration/FPS; Monitor display
against real CSV including manifold vacuum; LOW/MED/HIGH UI persistence and
reset/stale recovery; large/twin visual clearance; thermal/airflow fidelity;
controlled new-versus-old game graphs. Respawns between pulls exercised loading
but do not prove all UI/reset behavior. These remain release blockers.
