# TurboCraft 1.0.0 development candidate — delivery status

Date: 2026-10-24. **RELEASE BLOCKED. PARTIAL IN-GAME VALIDATION.**
After the initial offline delivery, the user requested harness testing.
Two workspace-isolated profiles ran the actual candidate under 0.40.3.0.290897.
All 12 default families now have passing fitment/pull/lift evidence across an
initial 11-PASS/1-FAIL sweep and a separately retained Large Twin retry.
See [actual report](INGAME_HARNESS_REPORT.md); audio/flame appearance and
Monitor/CSV/vacuum acceptance remain NOT TESTED IN GAME.
No Patreon/ModLand post, main-profile installed mod or external game file was
changed. Only owned test-profile vehicles/processes were driven/stopped.

## Baseline actually inspected

Latest workspace package by modification time:
`dist/TurboCraft_v0.9.9-udc-ai-bridge-20261021-candidate.zip`.
28 unique entries, full decompression/CRC clean.
SHA-256: `D4CC303428196DC0BA6655044D39CA7C5C994766F358C446DD8E7C64A6B7E314`.
Pre-edit runtime source matched the archive; only README differed.
Baseline offline result: Lua 9 syntax-clean files, 82 passed / 0 failed, plus
UI/catalog/header profile checks. This does **not** certify v0.9.9 in game.

## v0.9.9 versus candidate

| Surface | Inspected v0.9.9 | 1.0.0 source candidate | Acceptance |
|---|---|---|---|
| Hardware catalog | 6 families / 24 kits | 12 families / 40 kits, same old IDs/slots/defaults | Offline checked |
| Big/Large twins | Absent | 70–98 / 100–150 mm each, parallel energy-split approximation | NOT TESTED IN GAME |
| Big/Large Roots | Absent | 2.65/3.1 and 3.8/4.5 L/rev fictional classes | NOT TESTED IN GAME |
| Big/Large centrifugal | Absent | 1800/2100 and 2400/2800 nominal CFM classes | NOT TESTED IN GAME |
| Native pressure/drive behavior | Existing turbo and roots/centrifugal devices | New ratios, shaft inertia, loss and response; no equal power multipliers | Native blower calibration pending |
| Visual housing/drive fitment | Existing donor geometry | Geometry unchanged; new choices labeled physics-only | No large/twin mesh or clearance proof |
| Larger single | Up to 150 mm | No expansion without geometry evidence | Deferred deliberately |
| Thermal physics | Native inherited model | No verified new runtime heat coupling | NOT IMPLEMENTED / NOT TESTED IN GAME |
| Airflow | Inherited scalar/shaft approximation | Native turbo shaft load differs by layout; CFM is a nominal class, no compressor maps | Real MAF/flow validation pending |
| Headers | RPM-shaped exhaust energy | Separate RPM-shaped engine efficiency too; donor torque tables retained | NOT TESTED IN GAME |
| Afterfire | Donor coefficients, generally visual=1 | Street/race/open damping of native combustion/exhaust events | NOT TESTED IN GAME |
| Turbo/BOV audio | Size-dependent native events | Coefficients bounded by each modeled shaft/PSI envelope | NOT TESTED IN GAME |
| Blower/exhaust audio | Native/donor engine sound | EQ retained; 12 original synthesized WAVs, experimental blower-only overlay OFF by default | NOT TESTED IN GAME |
| Gauge | Digital ring, guessed MAP units/ambient fallback | Numbered PSI/vacuum sector, measured pointer; no unit/ambient guesses | Source tests only |
| Vacuum fallback | Could infer MAP from standard atmosphere | Boost-only warning when MAP/ambient missing; no fake vacuum | Native manifold source still unverified |
| Update/filter | 10Hz, no pointer | 20Hz raw display, 45ms pointer transition, 500ms stale watchdog | Settings, not measured live latency |
| LOW/MED/HIGH | Persisted presets | Retained; rapid edits cannot cancel other modes | Offline checked |
| CSV | v1 columns, inferred MAP possible | v2 appends provenance/real shaft signals; original prefix retained; 10Hz | Live agreement NOT TESTED IN GAME |
| UDC bridge / monitor-only | Existing read-only competition snapshot | Retained; stale samples do not advertise applied control | Offline checked |

## Changes to physics and limits

New parallel twins use two identical wheels, the selected diameter **per wheel**.
The aggregate native shaft has twice the inertia, compressor load coefficient
and friction of the corresponding single, with the same total exhaust-energy
input. This is equivalent to halving drive energy per wheel, **not** twice the
boost. It is still one BeamNG turbo device, not two independently modeled shafts.
The older standard Twin profile keeps its v0.9.9 tuned-response calibration for
saved-config behavior; it is not retroactively claimed to be a calibrated
parallel model.

New blowers use native `roots` / `centrifugal` mechanisms with differing drive
ratios, pressure coefficients, pressure-rate limits and crank loss. Their native
pressure/torque/thermal behavior still needs comparison with runtime results.
No compressor efficiency/heat calculation below is injected into game physics
or displayed as measured telemetry.

Headers act through separate exhaust-energy and engine-efficiency columns,
normalized to engine redline. Original pumping-loss/torque tables, donor meshes,
nodes and sound EQ remain. These curves are simulation choices, not measured
runner-length/diameter or dyno specifications.

The afterfire path only modifies existing native exhaust-node coefficients.
Fuel, ignition, load, lift-off, engine state and broken-pipe routing remain the
engine/exhaust system's responsibility. If it emits no afterfire, TurboCraft
emits none. No invented combustion event, constant flame, throttle-only flame,
fuel injection, particle timer or periodic Lua effect is added. Color, brightness,
duration and true exhaust-tip alignment remain native and unverified.
Street/race/open coefficients are simulation attenuation, not flame-energy data.

Twelve original CC0 WAVs were synthesized without external recordings. Six
Roots/centrifugal variants can be explicitly enabled as a bounded experimental
overlay; six turbo/hiss/BOV clips are audition-only. Actual shaft-driven pitch,
available load/pressure gain, reset/mute and missing-data behavior have offline
coverage, but native sound overlap/spatial behavior/loudness still require a
live test. It remains **OFF by default**. See [audio provenance](AUDIO_PROVENANCE.md).

## Reproducible graphs, not a dyno validation

`offline_comparison.json`, `offline_comparison.csv` and eight SVG graphs are
generated by `tools/compare_v100.py`. They contain 64 versioned profiles /
960 estimate rows. Graphs separate turbo and blower mechanisms and compare
boost, estimated shaft torque, estimated shaft horsepower and uncooled discharge
temperature. No image is a game screenshot.

All profiles use the same archived D-Series 4.5L NA shaft-torque anchor,
manual 3rd gear, 1500–5000 RPM, 101325 Pa / 20 C, assumed 85% VE and 70% cooler
effectiveness. Turbo estimates use the same cast/street path, gate shut.
Blowers retain factory drive settings. This is **not** the requested new
same-car controlled in-game experiment and does not establish real horsepower.
The archived anchor was recorded under 0.39.4; hashes/provenance are embedded
in the JSON. Its old successful runs do not validate this candidate.

Turbo estimates use the inherited approximate shaft equation including serialized
catalog/scalar/curve data. Blower shapes are **engineering illustrations**, not
a verified mirror of BeamNG's supercharger Lua. Heat, airflow and torque use
assumed gas/efficiency relations, not native sensors or real dyno data.

Representative **estimated** boost, PSI at 1500 / 3000 / 5000 RPM:

| Default family | Modeled PSI | Qualification |
|---|---:|---|
| Single 60 mm | 0.01 / 18.53 / 32.82 | Gate shut, not normal 8 PSI control |
| Legacy Twin 60 mm each | 0.01 / 18.53 / 32.82 | Same equilibrium, different transient |
| Big Single 70 mm | 0.00 / 12.60 / 31.27 | Turbo shaft approximation |
| Large Single 100 mm | 0.00 / 0.00 / 6.63 | Very late spool |
| Big Twin 70 mm each | 0.00 / 4.57 / 9.36 | Split exhaust drive |
| Large Twin 100 mm each | 0.00 / 0.00 / 0.00 | Does not reach useful boost here; do not silently buff |
| Roots R19 | 4.06 / 4.83 / 5.49 | Engineering illustration, NOT native prediction |
| Centrifugal CF1275 | 0.48 / 1.91 / 5.32 | Engineering illustration |
| Big Roots BR26 | 5.50 / 6.55 / 7.44 | Engineering illustration |
| Large Roots LR38 | 8.22 / 9.78 / 11.11 | Engineering illustration |
| Big centrifugal BCF1800 | 0.68 / 2.73 / 7.57 | Engineering illustration |
| Large centrifugal LCF2400 | 1.01 / 4.04 / 11.23 | Engineering illustration |

## Real-vehicle / official references

Read directly: [Stellantis/Dodge 2019 Hellcat Redeye release, 28 June 2018](https://www.media.stellantisnorthamerica.com/newsrelease.do?id=19970).
It specifies a 6.2L V8, a 2.7L supercharger versus the standard 2.4L,
14.5 versus 11.6 PSI, and 797 hp / 707 lb-ft for Redeye. It also describes
charge cooling and strengthened engine components. These are **that complete
vehicle's manufacturer specifications**, not TurboCraft output or evidence that
our fictional Roots classes match the Redeye mechanism. No power conversion,
sound/visual match or direct calibration was inferred.

[BeamNG exhaust modifier documentation](https://documentation.beamng.com/modding/vehicle/sections/nodes/exhaust/)
documents native afterfire visual/audio/volume coefficients and exhaust-tree
propagation. The indexed official page was found; direct fetch failed during
this task. Field names also exist in the inspected inherited JBeam. Runtime
behavior on 0.40.3 is not thereby certified.

Direct Eaton/ProCharger reference pages could not be retrieved (timeout / 403).
No new rated speed, max CFM, HP or displacement was taken from unverified search
summaries. New TC capacity classes, drive/loss and sound coefficients are
simulation values. Earlier legacy manufacturer facts remain historical
references, not newly independently verified specs.

## Actual validation and outstanding game gates

Run `python tools\verify_v100.py`; actual command output is persisted in
`verification.json`. The offline suite includes 126 Lua checks, actual-catalog
generation, pressure/vacuum/null/unit/reset/CSV cases, UI lifecycle and mode
edits, all 12 original WAVs, JBeam/JSON parsing, Lua/JS/Python syntax, baseline ID/geometry preservation,
bounded profile coefficients and fail-closed evidence-tool tests.

Before the follow-up, the existing game window title identified **BeamNG.drive
0.40.3.0.290897, Direct3D12**. It was inspected read-only; no car/config was
selected or driven and no candidate content was mounted.
Workspace-only access does not permit changing the external active Mods folder
or reading the installation/profile. Subsequently, explicit harness testing
was requested and a supported Steam `-userpath` launch mounted the candidate
inside new workspace profiles without changing that existing profile. The
following table reflects current acceptance, not the initial blocker.

| Required live gate | Actual result |
|---|---|
| D-Series V8 default from each family selects and pulls/lifts | PASS across initial sweep plus separate Large Twin retry |
| Boost / torque / power samples under same configured hardware | Measured CSV/SVG provided; temperature conditioning and old/new comparison NOT TESTED |
| Turbo/supercharger/BOV/exhaust audible timing, level and identity | NOT TESTED IN GAME |
| Native afterfire conditions, tip alignment, color, duration, brightness, FPS | NOT TESTED IN GAME |
| Gauge vs real CSV across RPM / lift / multiple kits / vacuum | NOT TESTED IN GAME |
| Vehicle respawns and console-error scan | Respawns exercised; no TC-named errors, other engine errors recorded; UI/reset acceptance NOT TESTED |
| Larger hardware physical clearance / correct mesh | NOT IMPLEMENTED / NOT TESTED IN GAME |
| Improved native thermal / airflow feedback | NOT IMPLEMENTED / NOT TESTED IN GAME |

Use the updated sweep harness plus `ingame_sweep_plan.json` in an explicitly
approved isolated profile. Record exact game build, level, vehicle, engine,
gearbox, internals, part IDs, variables, temperatures and archive SHA.
Record sound/flames visually and aurally, not just with automatic samples.
Missing API/data means **unavailable** or no added effect, never a simulated
reading presented as measured physics. Do not publish until these gates pass
or the user explicitly accepts a reduced scope.
