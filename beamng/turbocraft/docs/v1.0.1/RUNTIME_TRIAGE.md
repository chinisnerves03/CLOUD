# TurboCraft v1.0.1 audio and afterfire runtime triage

Status: **NOT TESTED IN GAME** for audio and afterfire behavior. BeamNG
0.40.3.0.290897 was visible on 2026-10-25. The in-game Mods Manager listed
`turbocraft_universal_framework` under Active Mods, but its detail pane did
not show a version or ZIP filename. The loaded car was an ETK K-Series Kc8x
ttSport 2+2 (DCT), with TurboCraft fitment unverified. At idle the TurboCraft
Monitor displayed `NO PRESSURE SIGNAL` and another boost HUD displayed
`0.0 PSI`; these are only idle observations of that car.

The session opened the UDC Career menu. Attempting to leave showed an
unsaved-progress warning (`Last save: 7 minutes ago`), so the exit was
cancelled. No D-Series part selection, loaded pull, console telemetry,
audible playback, or flame was observed. Wait for the user's saved Freeroam
session before claiming runtime acceptance.

## First controlled run

1. Record BeamNG build, active TurboCraft ZIP hash, map, car, engine, exact
   TurboCraft part IDs and tuning, BOV type, and selected exhaust. Use one
   stock D-Series V8 and a known TurboCraft single-turbo kit before widening
   the matrix. Confirm the selected intake actually fitted.
2. With the engine running, capture TurboCraft telemetry at idle, loaded pull,
   and lift: `rpm`, `throttle_or_load`, `measured_boost_psi`, `turbo_rpm`,
   `turboDetected`, `induction_family`, and `original_audio_status`. The last
   field is published by `auto/turbocraft.lua`; it is a code state, not proof
   that audio was heard.
3. Compare the overlay OFF and deliberate vehicle-Lua opt-in
   `extensions.turbocraft.setOriginalAudioEnabled(true)` under the same load.
   Record the return values and `original_audio_status`; inspect the console
   for `TurboCraftAudio`, SFX source and sound-file errors. Listen outside and
   inside at idle, load and lift. Return it to OFF after the audition.
4. Test native afterfire separately: choose street, race, then open exhaust,
   with the same engine and driving condition. Record whether a native event
   occurs, whether a flame appears at the connected exhaust tip, and any
   console errors. A synthetic afterfire sound cue does not establish an event.

## Source observations that require runtime confirmation

- `originalAudio.lua` starts with `enabled = false`, so installing the ZIP
  does not enable the new WAV overlay.
- The turbo loop requires a positive `electrics.values.turboRPM` variant;
  without it the overlay whine target is zero. Hiss requires positive
  `turboBoost` and load. The SFX source and playback APIs are only mocked by
  offline tests; they have not been verified against BeamNG 0.40.3.
- `gen_sizes.py` attenuates native afterfire visual coefficients to 0.08
  (street), 0.35 (race), and 0.70 (open). These modify native exhaust nodes
  only; they cannot create a combustion event by themselves.
- `originalAudio.lua` places each source on the vehicle reference node. Its
  distance and direction relative to the turbo or exhaust tip remain unknown.

Only change gains, fallback signals, SFX calls, or exhaust coefficients after
the controlled run identifies which path fails. Re-run the existing Lua,
syntax, audio-asset, header/exhaust, and package checks after a source fix.
