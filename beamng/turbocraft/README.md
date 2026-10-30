# TurboCraft Universal Framework v1.0.2 private audio candidate

**Easy drift/track preset:** select **Drift / Track - Easy Audio** in Turbo
Sound Level for turbo kits, or **Drift / Track - Easy Blower Audio** in the
Roots Supercharger / ProCharger sound selector. Select **Drift / Track - Easy
Afterfire** in Afterfire / Rev Limiter. The Afterfire sliders are **Flame
Sensitivity**, **Afterfire Sound Volume**, and **Minimum RPM for Flames** under
**TurboCraft Afterfire - Easy**. No fuel/limiter tuning is required. Existing
parts, saved IDs and defaults remain unchanged. Native fueled bursts only; no
new fuel or synthetic bangs. Native flame particles are made denser and given
a small outward-velocity increase without moving the exhaust endpoint.
Detected DCT, manual and automatic gear changes at any forward gear count also
use a transmission-specific shift profile over the selected engine's native
shift sample. Eight-speed automatics use the ZF8 profile; other automatics use
the general automatic profile. Unknown gearbox types stay unchanged; this adds
no shift fuel or artificial flame.
**Flame appearance and shift audio are not tested in game**.
See [quick setup and limits](docs/v1.0.2/EASY_DRIFT.md).

**Header physics / original hardware foundation:** the new offline engineering
tool calculates dimensioned pipe pressure/heat losses and distinguishes gas
residence from acoustic transit; it does not invent a spool delay or replace
native turbo physics. The original TC-S60 mesh prototype has corrected blade
winding and OBJ/Collada exports, but no engine fitment yet. Current in-game
header coefficients remain approximations, not real compressor-map simulation.
See [inputs, proof and remaining limits](docs/v1.0.2/HARDWARE_PHYSICS.md).

This source-only follow-up keeps TurboCraft induction loops separate from the
vehicle's native BOV/flutter and afterfire events. The Parts menu distinguishes
**Sharp Atmospheric BOV · Valve Release** from **Compressor Flutter · No BOV**;
their existing saved-config IDs are unchanged. The auxiliary induction overlay
does not create synthetic valve or afterfire one-shots. Sound quality and the
S15 reference match remain **NOT TESTED IN GAME**. See
[BOV/flutter event ownership](docs/v1.0.2/BOV_FLUTTER_EVENT_OWNERSHIP.md).

**v1.0.1 audio development candidate:** original size-tiered Roots/Centrifugal
and turbo whine/hiss, BOV-type one-shots, and cosmetic afterfire-cue audio are
available through an opt-in overlay. Synthetic sound does not create or
synchronize flame/combustion and remains **NOT TESTED IN GAME**. See
[audio candidate notes](docs/v1.0.1/AUDIO_CANDIDATE.md).

**2026-10-25 source follow-up:** visible D-Series headers and D-Series/ETK-C
exhausts now contribute different native EQ/attenuation profiles according to
part type. No extra loop replaces the engine sound.
[Scope, exact coefficients and limitations](docs/v1.0.0/EXHAUST_SOUND.md).
Runtime acoustic configuration and pull/lift checks now pass all nine D-Series
pairs across an incomplete initial session plus a focused completed retry.
[Test details](docs/v1.0.0/EXHAUST_SOUND_TEST_REPORT.md).
Audible quality remains **NOT TESTED IN GAME**; older candidate ZIPs predate
this change. A separate 20261025 sound-test candidate was used.

**PARTIAL IN-GAME VALIDATION. Not release-ready.** The real 0.40.3 harness tested
all 12 default families: 11 initial passes and a Large Twin RPM-coverage failure;
the separately retained longer-pull retry passed. See
[actual measured results and remaining untested checks](docs/v1.0.0/INGAME_HARNESS_REPORT.md).
Sound/flame appearance and live Monitor/CSV agreement remain NOT TESTED IN GAME.
This candidate continues the inspected
latest v0.9.9 bridge package, not an assumed fully tested release.
See [delivery status and v0.9.9 comparison](docs/v1.0.0/RELEASE_STATUS.md),
[test report](docs/TEST_REPORT.md), and [current game-test procedure](docs/IN_GAME_TEST_PLAN.md).

New physics-only choices: Big Twin (70/80/90/98 mm **per turbo**), Large Twin
(100/115/130/150 mm per turbo), Big Roots (2.65/3.1 L/rev classes), Large Roots
(3.8/4.5 L/rev classes), Big centrifugal (1800/2100 CFM classes) and Large
centrifugal (2400/2800 CFM classes). These are fictional simulation classes,
not manufacturer ratings. They retain the vehicle's existing visual donor:
no larger housing, belt drive or second turbo mesh/clearance is proved.
No single larger than the existing 150 mm option was added without fitment evidence.

New twins model two parallel wheels with shared exhaust energy and doubled
aggregate shaft inertia/drag/friction, not doubled pressure. New belt-driven
sizes differ in native drive ratio, pressure ramp, response rate and crank loss.
The native thermal behavior is not upgraded or validated by this candidate.
Very large twins may produce essentially no boost on the reference 4.5L engine;
their selection does not promise useful boost or safe engine operation.

The gauge adds a measured pointer, numbered PSI scale and a fixed -15 to 0 PSI
vacuum sector. Its number is the raw real sample rounded to 0.1 PSI, with no
startup sweep or simulated pressure. Pointer transition is 45 ms; telemetry is
20 Hz and CSV remains 10 Hz. Missing/stale data hides the pointer/readout and
shows a warning. LOW/MED/HIGH targets, saved settings, logger and monitor-only
control are retained. Gauge/CSV agreement is only offline-tested so far.

**Vacuum is displayed only when the pressure source supports it.** Unqualified
MAP values are no longer guessed as Pa/kPa/bar. An adapter must declare its
verified units and both MAP and ambient sources. Native `turboBoost` /
`superchargerBoost` remain boost-only fallbacks and show **BOOST ONLY - VACUUM
N/A**; absent ambient/MAP columns stay blank, never standard atmosphere or
inferred absolute pressure. Stock universal manifold-vacuum availability is
not established. See [adapter contract](docs/ADAPTER_CONTRACT.md).

Exhaust afterfire now attenuates native engine combustion events through the
existing exhaust node tree (street < race < open). No timer, throttle-only flame,
fuel spoof, independent particle or constant fire is added. Flame location,
color, brightness and duration remain native and **NOT TESTED IN GAME**.
Native turbo/BOV sound coefficients are reduced to conservative modeled
envelopes. Managed induction uses reproducible CC0 synthesized whine/airflow
loops; a ProCharger-style lift after measured boost can trigger one short
synthesized release burst. Native turbo BOV/flutter and combustion events remain
native and are not duplicated by this centrifugal-blower event. Audio-only
drive-ratio/RPM anchors do not alter boost physics. The separate
`reference_dev` bank contains filtered private recordings whose redistribution
rights are not cleared; it remains workspace-only and is excluded by the
packager. Original engine/exhaust samples and the engine-specific sound bank
remain unchanged. See [audio provenance and experimental limits](docs/v1.0.0/AUDIO_PROVENANCE.md).
The sound design is still experimental: timbre, release timing, loudness,
spatial falloff and clipping need in-game listening and tuning.

Reproduce checks with `python tools\verify_v100.py` from this source directory.
The eight SVG comparisons and 960 CSV rows under `docs/v1.0.0` are **OFFLINE
ESTIMATES**, not measured dyno results. Blower and temperature illustrations
are not verified mirrors of the game's native model and never feed the gauge.

Physics-first BeamNG.drive turbo telemetry and control framework.

## Scope

- Universal vehicle-side adapter with a Gavril D-Series V8 specialization.
- Additive D-Series V8 turbo system using the game's own visible intake, header, and exhaust meshes.
- One **TurboCraft** entry in the engine's existing Intake slot. Its **Forced Induction** slot offers
  **Single/Twin Turbo**, **Big/Large Single/Twin Turbo**, **Roots Supercharger**
  and **Centrifugal Supercharger** (including their Big/Large classes).
  Each system's next selector lists its size options from larger to smaller.
  Universal turbo kits offer physics-only Header and Exhaust choices; the vehicle keeps its
  original visible exhaust and sound. Belt-driven kits have no Header or Exhaust choices.
  The D-Series uses its existing visible TurboCraft parts in the engine's Exhaust Manifolds slot.
- Normal Single/Twin choices cover 50–70 mm per turbo, with one 48 mm legacy choice retained
  for existing saved configurations. Big Turbo spans 70–98 mm and favors earlier response with a
  small turbine A/R; Large Turbo spans 100–150 mm and favors high-RPM flow, with very late spool at
  low RPM. Large units remain selectable on smaller engines, but their response may be extremely
  slow; higher engine RPM and more exhaust power help them spool.
- Part labels use fictional TurboCraft series codes, not third-party manufacturer names or logos.
  Existing internal part IDs remain stable for saved-config compatibility. Reference links below
  credit the public sources used for legacy hardware facts; they do not imply a partnership or endorsement.
- Target boost control UI from 0 to 200 PSI.
- Runtime boost reader using BeamNG electrics.
- Telemetry logger with CSV export.
- Pure Lua core modules with offline unit and integration tests.
- Additive mod only: no vanilla or third-party vehicle files are modified.

The 0–200 PSI UI range is a control/display range, not a guarantee that a
turbocharger or engine can produce that pressure. If the active turbo runtime
does not expose a supported live wastegate setter, TurboCraft stays in
monitor-only mode and reports that fact.

## Install

For an explicitly approved isolated test only, copy
`TurboCraft_Universal_Framework_v1.0.2-private-native-valve-events-r8-20261025-candidate.zip`
into that BeamNG test user's `mods` directory. This is a private development
candidate, not approved for public redistribution. Runtime folders at the ZIP root include
`lua`, `mod_info`, `scripts`, `ui`, and `vehicles`.

In Freeroam, add the **TurboCraft Monitor** app through UI Apps. Select a
vehicle; the Gavril D-Series V8 adapter is selected automatically when the
vehicle directory is `pickup` and a selected engine part contains `v8`.

The monitor is a floating 220×220 measured-pressure gauge with a blue segmented scale,
numbered ticks, a measured pointer, live PSI readout, red target marker and separate setpoint adjustment. When opened, it
migrates only known previous default sizes (205×220, 360×136, or 440×180) to
the circular footprint while retaining position and other settings. Custom
dimensions are not resized.

To choose a hardware-size kit on a stock D-Series V8:

1. Open **Vehicle Configuration > Parts** and select TurboCraft, a forced-induction
   system, then one of its size choices. The fictional TC-S, TC-B, and TC-L labels show
   compressor wheel diameter; twin choices show diameter per turbo. Roots and centrifugal
   choices show their reference capacity/flow values. The list is ordered largest to smallest
   within each family.

3. In the engine's main **Exhaust Manifolds** slot, select a TurboCraft cast,
   tubular, or equal-length turbo header. Each TurboCraft header exposes a
   **TurboCraft Exhaust** child slot with street dual exhaust, race dual exhaust,
   or open turbo downpipes. These parts reuse BeamNG's D-Series meshes and apply
   distinct turbine-flow physics without replacing any original vehicle file.
4. On turbo kits, the **Compressor Housing** makes a small modeled change to
   boost response. The **Turbine Housing** has the larger low-RPM/high-RPM tradeoff:
   a smaller A/R favors earlier boost, while a larger A/R favors high-RPM flow.
   **Spool Response** changes rotating inertia only: Quick is 25% less than the
   baseline, Balanced is unchanged, and Slow is 35% more. These are experimental
   simulation estimates, not measured curves for every engine or turbo.
5. On Roots-style or centrifugal blower kits, the **Pulley / Drive Ratio** slot
   now has six steps from 75% through 120%. Roots-style means positive
   displacement; centrifugal (ProCharger-style) means a centrifugal blower.
   Fictional large classes include up to 6.0 L/rev Roots capacity and a 3600-CFM
   centrifugal airflow class. These labels describe TurboCraft simulation
   classes, not manufacturer products or measured ratings.

Some legacy hardware dimensions, ratings, and fitment references were derived from public
manufacturer product data: [Garrett G25-550](https://www.garrettmotion.com/racing-and-performance/performance-catalog/turbo/g-series-g25-550/),
[Garrett G25-660](https://www.garrettmotion.com/racing-and-performance/performance-catalog/turbo/g-series-g25-660/),
[Garrett G30-825](https://www.garrettmotion.com/racing-and-performance/performance-catalog/turbo/g-series-ii-g30-825-58mm/),
[Eaton TVS R1900](https://www.eaton.com/au/en-gb/catalog/engine-solutions/tvs-r1900.html),
[Eaton TVS R2300](https://www.eaton.com/au/en-gb/catalog/engine-solutions/tvs-r2300.html), and
[ProCharger P-1X / D-1X](https://www.procharger.com/p-1x-d-1x-upgrade/).
The Big/Large series are fictional size classes; their output and spool behavior are simulation
profiles, not manufacturer ratings or compressor-map predictions.
The game's current turbo model is still calibrated to the Gavril 4.5L V8 and does
not load the manufacturers' compressor maps; Roots and centrifugal curves are also
BeamNG approximations. Manufacturer ratings are fitment references, not live
displacement matching or promises of in-game horsepower/boost. Turbo sizing adapts
to the engine's torque/RPM power proxy while preserving the selected physical wheel
diameter; an engine displacement field has not been verified across vehicle data.
The 0–200 PSI control remains a requested target only.
TurboCraft header and pipe choices now shape the turbine exhaust-energy curve by
normalized engine RPM using the same generated graph in the model, JBeam, and
runtime wrapper: compact cast headers favor the lower range, while tubular and
equal-length profiles favor progressively higher flow; street pipes taper more
at high RPM than sport/race or open pipes. The D-Series exhaust parts also
retain their BeamNG donor `torqueModExhaust` curves. Header geometry, thermal,
flow, pulse, turbo sizing, and blower values are simulation estimates; no new
measured dyno data, compressor/turbine maps, or manufacturer accuracy is claimed.
Exact vehicle-specific exhaust geometry is not modeled. Friction and
back-pressure modifiers remain separate.
Older tests used strengthened internals for higher boost; they do not establish
a universally safe pressure for stock or modified long blocks.
The Automation Stage source candidate scales positive engine torque-damage
ratings with its Long Block Stage gain, but that is not a guarantee that an engine
can safely use the full 0–200 PSI target range.
The HUD reports the resolved kit size only when a TurboCraft part is fitted; it
does not pretend a generic or third-party turbo is adjustable.

Telemetry files are written to:

`<BeamNG user folder>/settings/turbocraft/telemetry/`

## Controls and meanings

- **Boost gauge**: a floating digital circular face with a forty-segment cyan
  ring, a live PSI readout, and a separate red target marker. The
  normal display spans -15–40 PSI and expands its positive range when the target or
  measured boost is higher. A central live PSI reading, target adjustment,
  round `−` / `+` controls, and round **SET** / **MODE** buttons remain available.
  **SET** opens separate 0–200 PSI targets for LOW, MED, and HIGH plus diagnostics;
  **MODE** cycles LOW → MED → HIGH and applies that target to the car. The
  `−` / `+` buttons adjust the selected mode. Logging remains available inside
  the SET overlay. Existing single-target settings migrate to MED. Measured boost remains an unclamped live
  runtime value; unavailable readings show a dash rather than a fabricated
  zero.
- **Target**: requested wastegate/boost target, clamped to 0–200 PSI.
- **Measured**: source-qualified live gauge pressure, not target or a spool estimate.
- **Turbo size**: read-only HUD confirmation of the wheel / cover / turbine
  parts fitted under the TurboCraft intake (e.g. `66 mm · C 0.60 · T 0.82`); the parts are changed in Vehicle Configuration >
  Parts so BeamNG rebuilds the powertrain with the new physics.
- **Monitor only**: no supported live turbo setter was found; setting a target
  does not alter vehicle physics. TurboCraft turbo kits also expose
  **TurboCraft Boost** in Vehicle Configuration > Tuning; changing that value
  rebuilds the part with a new wastegate setting.
- **Applied native offset**: BeamNG's native `setWastegateOffset` accepted the
  requested target relative to the selected part's base wastegate setting. This
  still does not guarantee measured boost will reach the target.

## Test status

See `docs/TEST_REPORT.md`. Offline tests and in-game tests are reported
separately. Never infer in-game compatibility from offline test success.
