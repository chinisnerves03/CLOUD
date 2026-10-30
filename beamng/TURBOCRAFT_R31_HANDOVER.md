# TurboCraft r30+r31 handover (everything in one file)

Goal: make TurboCraft sound and look like a real anti-lag drift car: fireball at the tailpipe that lights
the bumper, real pops/bangs/burble, turbo held spinning by anti-lag, shifts that don't just cut off.

## What was done, in order
1. **Flame light (r30)**: point-light flash at the exhaust tip for every afterfire flame, colour by gear and
   speed (orange low gears/downshifts, white-hot mid, blue-white small pops at speed in 5th+). Native
   flames slowed x0.8 so the fireball sits on the tip.
2. **Sound sourcing**: Freesound/GitHub/YouTube are blocked in the cloud environment, so the author supplied
   three clips: RB26 S14 anti-lag (14 s), HKS 2JZ GT86 anti-lag/backfire (31 s), 25-min dyno compilation.
3. **Blend v1 (rejected)**: all three clips matched (band-limit 11 kHz, 1/3-octave EQ to a common
   spectrum, level, compressor, shared room) into one 12 s pass. Author: two engines mixed = wrong.
4. **Rule from the author**: ONE car only. Engine pull only at the start; the rest is anti-lag, turbo,
   pops/bangs.
5. **Blend v2 (approved)**: 2JZ GT86 clip only: pull + bangs (5.3-12.7 s), turbo whistle (12.6-16.2 s),
   anti-lag pops (18.2-28.6 s); crossfades, +3 dB at 90 Hz, compressor 2.5:1, -14 LUFS.
6. **Mod sounds re-cut from the 2JZ clip with the v2 chain**: pop_a-d, bang_a-c, burble_a-c,
   antilag_up_a-c, antilag_down_a-c, new antilag_spool_a/b (turbo whistle). limiter_whine_a/b are still
   RB26 (the 2JZ clip has no clean limiter section). Exact cut times: docs/v1.0.0/AUDIO_PROVENANCE.md.
7. **Overrun window (r31, `popBang.lua`)**: lift-off, upshift or downshift opens a window
   (lift 0.8-2.4 s, downshift 0.7-1.9 s, upshift 0.3-0.8 s; longer at high RPM/boost). During it:
   crackle every ~60 ms at high RPM, lazy burble every ~250 ms at low RPM, thinning as the window ends;
   bangs always fire a tailpipe flame, hot pops sometimes; turbo whistle at the start, louder/higher with
   boost; boost at window start keeps counting (anti-lag holds the turbo). Back on throttle ends a lift
   window. Upshift = hard burst + short crackle, downshift = ragged crackle that burbles as revs fall.
8. **Previews** (not game captures): blend v1/v2 audio, a flame mock-up video, and an 11 s simulation of
   the new Lua logic (mocked BeamNG API in lupa).
9. **Tools added**: `tools/blend_reference_audio.py`, `tools/flame_preview_mock.py`.

## Known issues / next
- **Flames look like a light flash only, not a fire jet "whoosh" out of the pipe.** Next: real flame
  particles (custom particle data, longer/larger jet with orange core and blue edge, maybe a short
  "whoosh" sound). Needs the game's particle files [verify].
- The game's own shift-cut sound still plays; if shifts still feel chopped, lower it.
- Nothing tested in game; light API names unverified [verify].
- Recorded sounds have an unknown licence: personal use only until confirmed.

For the local Claude session. The cloud session cannot reach the local machine, so the changes come as
either the git branch or a zip.

## Option A: git (preferred)
```
git fetch origin beamng-mod
git checkout origin/beamng-mod -- beamng/turbocraft   # or copy the files listed below into the local mod
```

## Option B: zip
`TurboCraft_r31_changes.zip` holds only the changed files with their paths inside the mod folder;
unzip it over the local mod root (the folder that contains `mod_info/`, `lua/`, `art/`).
`TurboCraft_r31_full.zip` is the whole mod (without `tools/`) if you'd rather replace it.

## What changed since r29
- r30: tailpipe flame light (`flameLight.lua`, GE extension `turbocraftFlameLight`, loaded in
  `scripts/turbocraft/modScript.lua`), slower native flames (`eventEffects.lua`), limiter whine in `popBang.lua`.
- r31: `popBang.lua` overrun window (RPM-driven burble/pops/bangs, flames, turbo whistle on lift and
  shifts); recorded sounds (2JZ GT86; limiter from RB26) replace the synthesized pop/bang/burble/anti-lag;
  new `antilag_spool_a/b.wav`; `manifest.json`, `LICENSES.md`, `AUDIO_PROVENANCE.md`, `CHANGELOG.md`.

## Merge rules
- If the local copy changed the same Lua file (popBang.lua, eventEffects.lua, shiftAudio.lua,
  afterfireParticles.lua), merge by hand: keep local fixes, add the r31 overrun-window code.
- Some Lua files use CRLF line endings (shiftAudio.lua, eventEffects.lua): keep them.
- Recorded sounds have an unknown licence: fine for personal testing, do not publish the mod until confirmed.
- Nothing here was tested in game. Test: lift at high RPM, upshift under load, downshift off throttle;
  watch for flames + light on the bumper and listen for the turbo whistle.

## Files
- CHANGELOG.md
- LICENSES.md
- art/sound/turbocraft/antilag_down_a.wav
- art/sound/turbocraft/antilag_down_b.wav
- art/sound/turbocraft/antilag_down_c.wav
- art/sound/turbocraft/antilag_spool_a.wav
- art/sound/turbocraft/antilag_spool_b.wav
- art/sound/turbocraft/antilag_up_a.wav
- art/sound/turbocraft/antilag_up_b.wav
- art/sound/turbocraft/antilag_up_c.wav
- art/sound/turbocraft/bang_a.wav
- art/sound/turbocraft/bang_b.wav
- art/sound/turbocraft/bang_c.wav
- art/sound/turbocraft/burble_a.wav
- art/sound/turbocraft/burble_b.wav
- art/sound/turbocraft/burble_c.wav
- art/sound/turbocraft/limiter_whine_a.wav
- art/sound/turbocraft/limiter_whine_b.wav
- art/sound/turbocraft/manifest.json
- art/sound/turbocraft/pop_a.wav
- art/sound/turbocraft/pop_b.wav
- art/sound/turbocraft/pop_c.wav
- art/sound/turbocraft/pop_d.wav
- docs/v1.0.0/AUDIO_PROVENANCE.md
- lua/ge/extensions/turbocraftFlameLight.lua
- lua/vehicle/turbocraft/afterfireParticles.lua
- lua/vehicle/turbocraft/eventEffects.lua
- lua/vehicle/turbocraft/flameLight.lua
- lua/vehicle/turbocraft/popBang.lua
- lua/vehicle/turbocraft/shiftAudio.lua
- scripts/turbocraft/modScript.lua
