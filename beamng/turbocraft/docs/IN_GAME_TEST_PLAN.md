# In-game test plan

## v1.0.0 — all steps below NOT TESTED IN GAME

Use an explicitly approved **isolated profile**, not a currently used Career
save. Do not run this harness over a user's active car/session. The suite
replaces the test vehicle and applies throttle/brake. It is excluded from the
candidate mod ZIP and included only in the source archive.

Record exact BeamNG build, candidate SHA, Gridmap V2, D-Series
`d15_4wd_M` 4.5L V8, manual gearbox, Ultra internals, all installed part IDs
and tuning variables. The current source contains 12 families / 40 hardware
choices. Legacy 19-wheel / 3-slot instructions below are historical only.

1. Confirm only one TurboCraft candidate is active in the isolated profile;
   validate Parts selection manually for all six new families and each size.
2. For controlled pulls use identical engine/internals/gearbox/gear, fuel,
   temperature, load route, ambient and cast/street header/exhaust. Use the
   candidate `tests/ingame/tcsweep` harness with
   `docs/v1.0.0/ingame_sweep_plan.json` placed as `tc_sweep_plan.json` at that test
   profile's VFS root. The plan covers one default from each family. The updated
   harness sets 20 PSI tuning, checks actual fitted IDs, records full config and
   shaft torque/power, samples lift-off for two seconds, and aborts at 30 PSI,
   high RPM or engine breakage. Do not disable those guards for a prettier graph.
3. A fallback stock part / wrong ID is a **failure**, not a zero-boost pass.
   Independently check the selected engine and strengthened internals actually
   fitted. Preserve low-boost/failed-to-spool results for oversized hardware.
4. Listen at idle/part/full load and during lift-off for each family; compare
   small/large whine, hiss and BOV. No constant BOV at idle, wrong-timing loops,
   clipping or loss of the original engine sound is acceptable.
   Separately audition the original CC0 clips and explicitly opt in to the
   blower overlay per `v1.0.0/AUDIO_PROVENANCE.md`; it is OFF by default.
   Check native-sound overlap, spatial origin, broken/stopped-engine muting and
   reset/re-enable. Do not mark audition-only turbo/hiss/BOV as active replacements.
5. Check street/race/open pipes at idle, WOT, lift and fuel-cut/rev-limit events.
   No constant flames. Confirm native afterfire originates at the connected tip,
   not an old emitter position, and broken pipes reroute natively. Record
   duration/color/brightness and frame-time with/without events. No native event
   means no added flame; record unavailable rather than forge combustion.
6. Compare live gauge and CSV at low/mid/high RPM, spool and lift-off across
   at least three hardware IDs. Capture actual gauge snapshots containing
   `vehicle`, `timestamp_s`, `sample_sequence`, `valid`, `signal_source` and
   `displayed_psi`. The real Angular scope is available from
   `angular.element(document.querySelector('.tc-root')).scope()` in UI devtools;
   use its actual state and `measured()`, never synthesized values. This snapshot
   procedure itself remains untested in the running game.
7. Run `python tools\check_gauge_csv.py REAL.csv REAL_UI_SNAPSHOTS.json`.
   Maximum allowed displayed error is 0.051 PSI (0.1 PSI rounding), at least
   20 matched samples, three hardware IDs, three RPM bands and three actual
   manifold-vacuum samples. Split logs around respawn if identities repeat.
   Compressor-only data cannot pass the vacuum gate; document that blocker.
8. Verify measured and target differ when hardware cannot reach a target;
   LOW/MED/HIGH persists across reset/reload. 0–200 PSI is a requested range,
   never a durability or achievable-boost claim.
9. Reset/reload and switch vehicles; the gauge must clear stale readings and
   recover on real samples. Disable telemetry and confirm warning/dash within
   500ms watchdog plus render scheduling, no startup sweep or frozen valid value.
10. Parse JBeam/Lua/UI/sound errors from that actual run's console/log. Record
    every failure, engine breakage, missing mapping and exact config, even if
    offline tests pass. Native thermal/flow feedback and physical large-hardware
    fitment remain separate blockers, not fulfilled by the offline SVGs.

## Historical pre-catalog procedure (not current acceptance)

Record the exact BeamNG version, enabled mods, D-Series configuration, and ZIP
SHA-256 before running.

1. Start BeamNG and verify TurboCraft appears in Mod Manager without errors.
2. Enter Freeroam and spawn a stock Gavril D-Series V8.
3. Add the TurboCraft Monitor UI app.
4. Verify adapter is `Gavril D-Series V8`; if not, capture selected part names.
5. Verify RPM/throttle update and missing boost displays `N/A`, not a fabricated value.
6. Fit `TurboCraft Physics-Only V8 Turbo` in the D-Series Intake slot.
7. In Vehicle Configuration > Parts, verify Turbo Wheel (19 parts, 42–114 mm),
   Compressor Cover (6 A/R) and Turbine Housing (6 A/R) slots appear under the
   TurboCraft intake.
8. Apply 0.65×, then 1.75×. Confirm the HUD reports each resolved value and
   compare spool response under the same gear, RPM, throttle, and road/load.
9. Verify measured boost changes under load and Target remains visually separate.
10. Set targets at 0, 8, 30, 200, below 0 and above 200; verify UI bounds and status.
11. Start logging, drive for at least 20 seconds, stop logging, and parse the CSV.
    Verify timestamps are not duplicated by telemetry from non-player vehicles.
12. Reset and reload the vehicle; confirm state recovers and no stale logger remains.
13. Review `beamng.log` for TurboCraft Lua/JBeam/UI errors.
14. Disable/remove TurboCraft and confirm the original D-Series still loads.

Until these steps run in the game, status must remain `NOT RUN IN GAME`.
