# Merge TurboCraft r30+r31 into the local copy (R29)

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
