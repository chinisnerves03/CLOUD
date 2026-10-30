# Changelog

## Tailpipe flame flash and tip fireball (r30 candidate)

- New `flameLight.lua` + GameEngine extension `turbocraftFlameLight`: every afterfire flame on the
  overrun/hardcut/drift profiles briefly lights the bumper and road with a point light on the exhaust
  tip node (follows the car, fades in ~0.1 s). Colour by situation: orange on low gears/downshifts,
  yellow-white mid gears, blue-white for small pops in 5th gear and up above ~126 km/h.
- Native flames leave the pipe slower (x0.8 instead of x1.25; limiter bursts 4-11 instead of 10-25)
  so the fireball forms on the tailpipe tip instead of a jet trailing behind it.
- NOT TESTED IN GAME: light API names, brightness and flame position need a live check.

## Rev-limiter whine (drift/hardcut profiles; r29 candidate)

- New `popBang.lua` limiter whine: when held throttle reaches the rev limiter on the
  Drift/Track or hard-cut afterfire profile, one of two original synthesized rising whine
  samples plays per cut (`tools/make_limiter_whine.py`). Other profiles are unchanged.
- NOT TESTED IN GAME: pitch, loudness and whether the cut chatter sounds right need a live check.

## Blower realism, pop/bang and anti-lag audio (2026-10-28; r28 candidate)

- Roots and centrifugal (ProCharger-style) loops re-synthesised so their octave-band
  envelope and tonality match measurements of real-car recordings (Hellcat supercharger,
  ProCharger; only the measured numbers are used, no recording is copied). The old loops
  were near-pure tones with spectral holes, peaking at 0.22 FS; new peak is 0.5 FS (about +7 dB).
- New `popBang.lua`: overrun pop/bang/burble sequences on throttle lift above 3000 rpm
  (intensity from rpm and boost; skipped for diesel) using 16 new original one-shot samples
  with random variant/pitch selection. `turbocraftPopBangVolume` (0-2, default 1) scales or
  disables it. Sound only; no fuel, spark or boost physics change.
- Gear changes add an anti-lag layer on top of the native shift cue: separate upshift
  (hard burst) and downshift (ragged crackle) sample families, three variants each.
- NOT TESTED IN GAME: audible quality, loudness balance and timing need a live check.

## Limiter, shift effects, sound and controls (2026-10-28; source candidate)

- Replaced the R25 temporary native limiter timer override with a capped
  repeating valve/flutter cue while the fitted turbo has positive measured
  boost and the driver holds throttle near the limiter. Native lift-off events
  keep their own timing. The historical default BOV ID now has an audible
  standard event; saved part IDs remain stable.
- Easy/Hard-Cut exhaust profiles now emit a short tailpipe flame and pop on
  held-throttle limiter cadence. Supported gearbox upshifts and downshifts
  emit a tailpipe flame with the existing shift cue. A fitted TurboCraft kit
  with an unclassified gearbox can use a generic cue when a numeric gear
  transition is available. This uses the real fitted
  exhaust endpoints, respects water, Flame Chance 0, minimum flame RPM and
  diesel exclusion. It is an audio/visual effect, not anti-lag combustion or
  a torque/boost change. Vehicles with zero valid exhaust endpoints cannot
  place a flame.
- Added a separately capped peak-boost turbo voice driven by measured boost
  and shaft RPM. Retuned original Roots synthesis toward stronger mechanical
  whine and less airflow; centrifugal ProCharger synthesis remains separate.
  User references are comparison targets only; no recorded audio is shipped.
- Renamed BOV and afterfire parts, tuning labels and Monitor diagnostics in
  plain English. New gasoline kits default to Easy Pops & Flames; old saved
  selections remain selected. No ZIP was built or installed and no in-game
  audio, flame or visual acceptance was performed.

## Allow native BOV/flutter on hard-limiter cuts (2026-10-28; source update)

- The native turbo suppresses BOV/flutter while `revLimiterWasActiveTimer` is
  at or below 0.1 seconds. On a hard limiter that timer can be zero exactly
  when the held-throttle load cut occurs, so simply forwarding native updates
  did not restore the burnout event.
- TurboCraft now temporarily opens that native permission window only above
  25% requested throttle and within 90% of the engine limiter, then restores
  the original timer even if the native update errors. Native event timing,
  selected sample and volume remain BeamNG-owned; limiter cycling may chatter.
- Added regressions using the in-workspace native turbo source and a hard
  limiter timer of zero. Source only; no package or in-game sound test recorded.

## Play native shift cue on low-load downshifts (2026-10-28; source update)

- Downshifts now reuse the selected engine's shift-afterfire sample even below
  the 30% throttle gate; upshifts keep the existing load gate.
- Native fueled shift events still suppress the fallback cue. This is
  audio-only and does not create anti-lag fuel, combustion or flames.
- Added endpoint and engine-node fallback regressions. Source only; no package
  or in-game sound test recorded.

## Restore native BOV/flutter on limiter hits (2026-10-27; source update)

- Removed the TurboCraft wrapper that hid recent limiter history from BeamNG's
  turbo update. Native BOV/flutter can play on held-throttle limiter cuts again,
  including during burnout; repeated hits may also restore limiter chatter.
- Added a focused pass-through regression and updated the native-event ownership
  and audio test notes. No package or in-game test is recorded yet.

## Broaden shift audio runtime compatibility (2026-10-27; source update)

- Gearbox classification now reads both raw JBeam arrays and runtime arrays
  without the JBeam header row. A `sequentialGearbox` is treated as automatic
  only when `vehicleController.automaticModes` is explicitly set.
- When a vehicle has no native exhaust endpoint but does expose a valid engine
  node, shift audio falls back to that node and reports the fallback in the
  Monitor. This is audio only; it does not invent an exhaust endpoint or flame.
- Added runtime-shape and fallback regressions. Source only; no
  package/install/game test is recorded yet.

## Automatic shift sounds for every gear count (2026-10-27; source update)

- Automatic gearboxes now receive shift audio at any forward gear count. Eight
  readable forward ratios keep the ZF8 profile; other automatics use the
  general automatic profile. DCT, MT, unknown-type gating, native event reuse
  and duplicate prevention remain unchanged.
- Added three-, six-, and ten-speed automatic regressions, plus malformed-ratio
  handling. Source only; no ZIP/install/game test is recorded in this entry.
- TurboCraft Monitor SET diagnostics now expose the detected shift profile and
  the last shift-audio gate/result, including whether SFX calls were issued.

## Native flame shaping and detected shift sounds (2026-10-27; source only)

- Native afterfire flame particles keep their original exhaust nodes and
  receive a 15% outward-velocity increase plus twice the particle count.
  Smoke, engine sound, native fuel, thresholds, and emitter position are
  unchanged; the shader's colour/size controls are not exposed here.
- Added shift-event sounds for explicit DCT/manual gearboxes and automatic
  gearboxes with exactly eight forward ratios (the user's ZF8 definition).
  They reuse each engine's native shift sample with separate profile gain/pitch.
  Unknown gearbox types stay silent; detected native shift-fuel events are not
  double-played. No fuel or flame is fabricated.
- Dedicated offline Lua regressions pass. Real particle appearance, audible
  timbre/timing and other-mod hook compatibility remain **NOT TESTED IN GAME**.
  Source only; no ZIP was built or installed.

## Native exhaust flame shaping (2026-10-27; source only)

- Added a fail-visible wrapper for BeamNG's native flame particle calls when a
  TurboCraft Afterfire profile is selected. Flame particles keep the same
  exhaust node IDs, use twice the particle count, and receive 15% more outward
  velocity; smoke, sound, native fuel thresholds, and emitter position are
  untouched.
- If the native particle API is unavailable or another hook replaces TurboCraft's
  wrapper, the mod logs the condition and preserves the engine's original call.
- Offline wrapper and lifecycle regression passed. In-game brightness, flame
  reach, and other-mod hook compatibility remain unverified; source only, no ZIP.

## Selectable turbo housings and expanded blower tuning (2026-10-27; source only)

- Wired Compressor Cover · Front A/R and Turbine Housing · Rear A/R as
  independent child selections on D-Series and generated universal turbo kits.
  Rear housings now exclusively own `engineDef`; the turbo-size part no longer
  appends a competing RPM table. Preset defaults retain their former calibrated
  cover/turbine settings.
- Added Quick / Balanced / Longer Spool selections using deterministic inertia
  multipliers. Added six blower pulley ratios (75–120%) and fictional larger
  capacity classes through 6.0 L/rev Roots and 3600-CFM centrifugal.
- Clarified positive-displacement Roots versus centrifugal / ProCharger-style
  labels while preserving existing IDs and defaults. Header, wheel, housing,
  spool, pulley, and capacity regressions exercise their model/source paths.
- Header/turbo/blower behavior remains a BeamNG simulation estimate: no new
  measured dyno data or manufacturer compressor/turbine maps were added.
  SOURCE ONLY / NOT TESTED IN GAME; no release ZIP was built.

## Easy afterfire minimum RPM (2026-10-25; source only)

- Added an independent minimum-flame-RPM slider (0-15,000, step 100; default
  0 retains unrestricted behavior). Blocks endpoint visual transmission below
  current shaft RPM, not native bang audio or fuel generation. RPM alone
  never triggers flames; native fuel/water/threshold conditions still apply.
- Restores native host endpoint transmission on removal; missing RPM with an
  active minimum fails closed with diagnostics. Sampled at vehicle GFX update,
  not a physics-substep timing guarantee. NOT INSTALLED / NOT TESTED IN GAME.

## Easy drift/track source presets (2026-10-25; not installed)

- Added opt-in Easy Audio and Easy Afterfire parts with two controls each,
  grouped under TurboCraft Easy. Kept all previous parts, IDs and defaults.
- Easy Audio raises the relative spool/air/valve mix without changing native
  BOV versus flutter selection, induction physics or the managed voice caps.
- Easy Afterfire uses a shorter, lower sustained-fuel calibration and louder
  native lift/shift bangs; retains the host limiter and redline. No continuous
  fuel, custom emitter, one-shot overlay or new flame artwork.
- These are candidate calibrations, not measured realism or reference-match
  claims. Source only; **NOT TESTED IN GAME**. See `docs/v1.0.2/EASY_DRIFT.md`.

## v1.0.2 private audio follow-up (2026-10-25)

- Split the BOV Parts labels into **Sharp Atmospheric BOV · Valve Release**
  and **Compressor Flutter · No BOV** while preserving the existing `sharp`
  and `none` part IDs and native event definitions.
- Removed auxiliary one-shot BOV and cosmetic afterfire playback from
  `originalAudio.lua`; it owns only induction loops. Native valve and engine
  afterfire events remain the sole event owners, avoiding duplicate release
  sounds or a bang cue that could be mistaken for combustion.
- Added a private six-window audition from the user-provided S15 reference.
  Its times are unconfirmed spectral candidates; the recording and audition
  are not included in the candidate ZIP or cleared for redistribution.
- Offline Lua, limiter/BOV, selector, reference-control, gauge, header/exhaust,
  native-afterfire and package checks pass. Audible timbre, clarity, clipping,
  and actual Parts visibility remain **NOT TESTED IN GAME**.

## v1.0.1 audio development candidate (2026-10-25)

- Added original size-tiered turbo whine/hiss, BOV profiles for atmospheric,
  tuned and recirculating routing, and explicitly cosmetic afterfire-cue audio.
- Smoothed loop pitch response over 40 ms and made lift-off gain release faster
  (18 ms) than attack (40 ms); measured signals, not target boost, drive audio.
- Kept all synthetic audio OFF by default. Native engine/exhaust events remain;
  the sound cue does not create or synchronize flame or combustion.
- Synthetic timbre, loudness, falloff, one-shot playback, native overlap and
  flame appearance are **NOT TESTED IN GAME**. See `docs/v1.0.1/AUDIO_CANDIDATE.md`.

## Source follow-up: exhaust character (2026-10-25)

- D-Series Cast/Tubular/Equal-Length headers now contribute conservative
  native exhaust high-shelf offsets (-2/-1/0 dB).
- Visible D-Series and ETK-C Street/Race/Open equivalents use distinct native
  exhaust-node attenuation (-9/-4/-2 dB), retaining donor exhaust EQ, muffling,
  routing and the original engine sound. No duplicate audio loop is added.
- Generator and workspace sync use the same profiles; tests assert declared
  acoustic changes and preservation of unrelated donor data.
- Universal physics-only selectors are not claimed to alter host sound.
  This does not implement the proposed extra diameter/muffler/resonator catalog.
- SOURCE ONLY / NOT TESTED IN GAME. Previous candidate ZIPs and harness results
  predate this change. See `docs/v1.0.0/EXHAUST_SOUND.md`.

## v1.0.0 development candidate (2026-10-24; release blocked)

- Added six families / 16 hardware choices, for 12 families / 40 choices total:
  Big/Large Twin Turbo, Big/Large Roots, Big/Large centrifugal. New parallel twins
  split turbine energy with aggregate inertia/drag instead of doubling boost.
- New blower classes vary drive ratio, pressure coefficient, response rate and
  parasitic loss. Fictional capacities only; visual fitment is not established.
- Added RPM-shaped header efficiency separately from exhaust energy; retained
  donor torque tables, original meshes/nodes and every v0.9.9 JBeam ID/slot/default.
- Attenuated native afterfire through existing exhaust modifiers. No custom
  flame timer/particle or forged combustion signal.
- Limited native turbo whine/hiss/BOV coefficients using each profile's modeled
  envelope. Actual volume, timing and blower sound remain unverified.
- Created 12 original CC0 synthesized WAVs with reproducible formulas and
  SHA/PCM/level/seam checks. Added an opt-in Roots/centrifugal overlay tied to
  actual shaft RPM, load and available boost, with silent startup/reset/missing
  data handling. It remains OFF by default; original turbo/hiss/BOV files are
  audition-only to avoid unverified replacement timing and double playback.
- Gauge: numbered PSI/vacuum scale, real-sample pointer, raw digital value,
  separate targets, 500ms stale warning, no startup sweep or ambient/unit guessing.
  Missing MAP support explicitly displays boost-only fallback.
- Fixed rapid edits of different LOW/MED/HIGH presets canceling one another;
  reset/switch clears stale data. Preserved UDC competition bridge.
- CSV v2 retains all original columns as an ordered prefix, appends provenance,
  fitted hardware and measured shaft torque/power. UI 20Hz, CSV 10Hz; blank
  fields stay missing. Logger errors and filename collisions are surfaced.
  Existing output directories are reused and nested creation is recursive.
- Added actual-catalog integration, baseline preservation and evidence-tool
  regressions, eight clearly labeled offline estimate graphs, and a modernized
  D-Series sweep plan. Generator cache version 7 includes catalog signature.
- NOT TESTED IN GAME. Runtime heat/flow coupling, physical fitment and required
  audio/flame/gauge comparisons are not accepted. No publishing/install occurred.

## v0.9.9 segmented digital boost gauge (source candidate)

- Replaced the analog needle face with a round cyan segmented digital scale inspired by the supplied boost-gauge reference; live PSI remains numeric and unclamped.
- Kept the 0–200 PSI target control, adaptive scale, red setpoint marker, target adjustment, logging and diagnostics.
- Not installed or tested in game.

## v0.9.8 adaptive analog boost gauge (source candidate)

- Added a graduated analog PSI dial with a smooth live needle, vacuum arc,
  amber target marker and a normal 0–40 PSI scale that expands for higher
  targets or live readings.
- Retained the separate 0–200 PSI target range, unclamped live measurement,
  logging, diagnostics and missing-signal fallback.
- Focused UI, Lua behavior/syntax and package checks pass. Not installed or
  tested in game.

## v0.9.7 floating circular gauge (source candidate)

- Replaced the rectangular controller card with a floating 220×220 circular boost gauge and circular diagnostics overlay.
- Kept live PSI, target adjustment, SET range/diagnostics, MODE logging, and live-reading fallback behavior.
- Migrates only known released defaults (205×220, 360×136, and 440×180), preserving placement anchors and user-sized layouts.
- Focused UI, Lua behavior/syntax, and package-source checks pass. Not installed or tested in game yet.

## v0.9.6 saved-layout migration (source candidate)

- On the app's first state request, migrates only TurboCraft Monitor placements exactly matching the known 205×220 or 360×136 defaults to 440×180.
- Copies all existing placement keys before patching width/height; positions and custom dimensions remain untouched.
- Focused UI, Lua behavior/syntax, and package-source checks pass. Not packaged, installed, or tested in game.

## v0.9.5 hard-case boost controller (source candidate)

- Rebuilt the monitor as a wide, hard-edged controller housing with subtle case screws, a left digital live-boost screen, center stacked blue SET/MODE buttons, and a metallic blue-ring target dial.
- The dial shows the target, not a duplicate measured reading or a detached needle. Details/range overlay the screen without changing the controller silhouette.
- Increased the manifest default to 440×180 (2.44:1).
- Focused UI, syntax, and package-source checks pass. Not packaged, installed, or tested in game.

## v0.9.4 horizontal boost dial (source candidate)

- Refined the TurboCraft Monitor silhouette to a left digital screen, stacked SET/MODE round controls, and a prominent blue-ring boost dial on the right.
- The dial repeats the real measured PSI and shows the requested target separately; adjustment, logger, and diagnostics/range access remain available.
- Focused UI, syntax, and package-source checks pass. Not packaged, installed, or tested in game.

## v0.9.3 horizontal boost controller (source candidate)

- Replaced the analog boost needle with a large live numeric display, avoiding the detached-needle transform and keeping measured boost separate from the target.
- Reworked the single TurboCraft Monitor into a compact horizontal dark-screen controller with circular target, logger, and diagnostics controls.
- Kept the target range, live telemetry, logging, and diagnostics inside the existing app.
- Focused UI and package-source validation pass. Not packaged, installed, or tested in game.

## Unreleased — Big/Large Turbo and fictional product labels

- Added regular 50–70 mm choices, Big Turbo sizes 70–98 mm, and Large Turbo sizes 100–150 mm.
- Big Turbo defaults favor earlier spool; Large Turbo profiles trade low-RPM response for high-RPM
  flow. These remain modeled BeamNG behavior, not measured compressor maps or engine guarantees.
- Replaced visible third-party product names with fictional TurboCraft series labels; retained old
  internal part IDs for saved-config compatibility and kept public spec sources in the README.
- Not packaged, installed, or tested in game.

## v0.9.1 header and exhaust curve profiles (source candidate)

- Added normalized-RPM exhaust-energy curves for cast, tubular, and equal-length headers and street, sport/race, and open pipes.
- The turbo wrapper applies the selected profiles to the turbine's `engineDef` exhaust-energy column after scaling it to the host engine's rev range. Invalid profile data is reported and not applied.
- Preserved the D-Series and ETK-C donor `torqueModExhaust` curves; new header/pipe profiles affect the turbo response without appending competing torque-modifier tables.
- These profiles are modeled BeamNG approximations, not manufacturer specifications or measured header dyno curves; the current game model remains calibrated to the Gavril 4.5L V8.
- Offline curve, Lua, catalog, and package-source checks pass. Not installed or tested in game.

## v0.9.0 hardware-size redesign (source candidate)

- Replaced TurboCraft Stage 1–5 selections with size-based catalogs ordered largest to smallest.
- Added source-derived turbo, Roots, and centrifugal hardware choices with manufacturer-referenced
  ratings. Current visible names use fictional TurboCraft labels; sources remain linked in README.
- Twin turbo entries identify the wheel size per turbo and show the doubled catalog ranges.
- Turbo hardware labels now keep the physical wheel diameter when the universal generator adapts
  exhaust energy to the host engine's torque/RPM power proxy.
- Manufacturer specs are fitment references; the BeamNG curves remain approximations and do not
  consume manufacturer compressor maps. No universal engine-displacement runtime field was verified.
- Not installed or tested in game.

## v0.8.2

- Nested selection: Intake > TurboCraft > Forced Induction > Stage.
- Universal turbo Stages offer physics-only Header and Exhaust choices while retaining the car's
  visible exhaust and sound. Belt-driven Stages have no exhaust choices; the D-Series uses its
  existing visible Exhaust Manifolds parts.
- Kit part names remain stable for Career inventory. Saves using the old kit slot fall back to
  defaults; choose the family and Stage again.

## v0.8.1

- The Intake list now shows a single **TurboCraft** entry instead of 20 system/stage kits.
  Pick the system and Stage in its **TurboCraft System** slot (D-Series and every generated vehicle).
- Kits keep their part names and prices; physics unchanged.
- Vehicles saved with a TurboCraft kit fitted directly in Intake fall back to that slot's default
  intake on load; fit **TurboCraft** in Intake again and choose the kit.

## v0.8.0

- Universal kits now reuse a vehicle's stock turbo hardware as their visible model.
- Added Air Filter, Charge Pipe, and Header choices to generated universal kits.
- Added three visible TurboCraft exhaust choices for the ETK-C V8.
- Manifold tuning is now physics-only under the visible turbo kit to avoid duplicate meshes and nodes.

## v0.7.3

- Shortened all TurboCraft part and slot labels for the Vehicle Config menu.
- Simplified the TurboCraft Monitor labels and translated internal status codes into readable states.
- Kept all turbo, airflow, manifold, header, and exhaust physics unchanged.

## v0.7.2

- Fixed universal manifold names sourced from BeamNG localization objects showing as `table: 0x...`.
- Regenerates cached universal vehicle parts so corrected names appear after the next game start.

## v0.7.1

- Added selectable **Air Intake / Filter** and **Charge Piping** parts beneath
  the TurboCraft D-Series V8 intake.
- Added three visible TurboCraft headers to the D-Series engine's main
  **Exhaust Manifolds** slot.
- Added street, race, and open-downpipe TurboCraft exhaust choices beneath each
  TurboCraft header.
- Reused BeamNG's original D-Series meshes and nodes; no vanilla files are
  overwritten.

## v0.6.2

- Five slots under the TurboCraft V8 intake (Vehicle Configuration > Parts):
  **Intake Manifold**, **Turbo Wheel**, **Compressor Cover**, **Turbine Housing**
  and **Blow-Off Valve**.
  - **Intake Manifold** (vanilla meshes): cast (stock), long runner (low-end
    torque), ported, short runner (top end), plenum.
  - **Turbo Wheel** 42–114 mm: each wheel has its own calibrated `pressurePSI`
    curve (boost onset 1800 rpm for 42 mm up to 3900 rpm for 114 mm; flow limit
    24–90 PSI) and the game's built-in turbo whine/hiss events by size.
  - **Blow-Off Valve**: atmospheric / tuned / recirculating / none. With no BOV
    the compressor surges and the turbo slows much faster on lift-off.
- All turbo numbers come from `tools/turbo_model.py`; the in-game dyno sweep
  matches it within 3 % (boost onset at 5 and 15 PSI for every wheel and
  housing).
- Respects the vehicle's own header, exhaust and long block choices.

### Earlier v0.6.2 build (3 slots)

- The turbo is now built from three parts in slots directly under the
  TurboCraft V8 intake (Vehicle Configuration > Parts); the Vehicle Tuning
  slider was removed:
  - **Turbo Wheel**: compressor inducer 42–114 mm in 4 mm steps (default
    66 mm = v0.6.1's 1.00×). Scales `inertia`, `maxExhaustPower`,
    `frictionCoef` and `backPressureCoef` with s = mm / 66.
  - **Compressor Cover** (front housing): A/R 0.42–0.95 (default 0.60).
    Smaller builds boost faster (`pressureRatePSI` × 0.60/A/R).
  - **Turbine Housing** (rear housing): A/R 0.48–1.32 (default 0.82). Owns the
    exhaust-energy curve (`engineDef`): small A/R moves energy below 3500 rpm
    and chokes above it; large A/R the opposite.
  The intake holds the baseline turbo and child parts apply BeamNG `$*`
  multipliers, so every combination stacks on one baseline.
- HUD shows the fitted combination, e.g. `66 mm · C 0.60 · T 0.82`; telemetry
  adds `turbo_size_mm`, `compressor_cover_ar`, `turbine_housing_ar`.
- Fixed duplicate telemetry: the GE bridge addressed the vehicle extension as
  `auto_turbocraft`, which made BeamNG load a second copy next to the real
  `turbocraft` extension. Both copies published every 0.1 s, so CSV rows were
  doubled and the reported target flipped back to 8 PSI.
- Fixed the CSV logger always reporting `csv_write_failed` (`ok and nil or x`
  always yields `x`).
- Fixed the D-Series V8 adapter never matching on BeamNG 0.39: parts are read
  from `v.config.partsTree` (slot tree) with the old flat `v.config.parts` as
  fallback.

## v0.6.1

- Added a visible `Turbo Size` tuning variable (0.65×–1.75×) to the additive
  D-Series V8 TurboCraft intake.
- Connected turbo size to rotating inertia, exhaust-energy capacity, friction,
  and compressor back-pressure instead of treating it as a cosmetic value.
- Added read-only configured-size confirmation to the TurboCraft Monitor.
- Filtered vehicle telemetry by the current player vehicle ID to prevent stale
  or secondary vehicles from duplicating CSV rows and target values.
- Added packaging checks proving the size variable is wired to all required
  physical fields.

## v0.6.0

- Added pure physics/units core with finite-value guards.
- Added universal adapter contract and Gavril D-Series V8 detection.
- Added an additive, physics-only D-Series V8 turbo intake using the native
  BeamNG 0.39 turbocharger model and `pickup_intake_v8` slot.
- Added measured boost reader and explicit signal-source reporting.
- Added 0–200 PSI target UI with Target/Measured separation.
- Added telemetry logger and deterministic CSV schema.
- Added offline unit/integration tests and packaging validation.
- No 3D models or vehicle textures were added.
- No original vehicle files are modified.
