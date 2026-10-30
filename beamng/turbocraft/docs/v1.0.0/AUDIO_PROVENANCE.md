# Original-audio provenance — TurboCraft 1.0.0 candidate

Twenty-four **new** WAVs are original deterministic mathematical synthesis, not
recorded vehicles or edited third-party samples. This does not mean every
existing TurboCraft sound is original: normal turbo/BOV/exhaust sounds remain
licensed-game native event references and are not redistributed here.

The private `art/sound/turbocraft/reference_dev/` audition bank is retained only
in the workspace. Its redistribution rights are not cleared, so the package
builder excludes that directory and runtime/JBeam metadata no longer points to
it.

No third-party recording with verified redistribution rights was obtained.
Public code was inspected only to establish API names/signatures, not copied:
https://github.com/OfficialLambdax/BeamNG-Powerups/blob/main/lua/vehicle/extensions/auto/SoundsLib.lua
It demonstrates `createSFXSource2`, `setVolumePitch`, `playSFX`, `stopSFX`,
`AudioDefaultLoop3D` and vehicle ref-node anchoring. This is community API
evidence, **not official API certification or a license for that project's code**.

## Original assets

`art/sound/turbocraft/manifest.json` records each SHA-256, duration, PCM format,
file peak/RMS dBFS and runtime/audition-only status. `tools/make_original_audio.py`
rebuilds all twelve without downloaded samples, models or third-party packages:

- Roots, centrifugal and turbo small/big/large: periodic harmonic whines with
  different fundamentals, harmonic weights and gear/rotor textures.
- Hiss small/big/large: loopable filtered airflow noise.
- BOV and afterfire size classes: shaped-noise one-shots with attack/decay and
  silent endpoints; native turbo BOV and combustion events remain native.

All are mono 16-bit PCM at 44.1kHz, two-second periodic loops except BOV
0.42/0.65 seconds, normalized to approximately -13.15 dBFS peak.
That file level is **not** an in-game loudness or real-world SPL measurement.
Loops have no DC offset or exceptional seam step; this is numerical evidence,
not a listening assessment. No claim of matching an Eaton/ProCharger/real turbo
recording, source spectrum or measured sound pressure is made.

**The new WAVs are dedicated under CC0-1.0:**
https://creativecommons.org/publicdomain/zero/1.0/
This dedication applies only to these synthesized WAVs, not BeamNG sounds,
third-party code or donor JBeam art. The manifest includes the original generator
and provenance, so there is no unknown sample-chain copyright dependency.

## Runtime status: experimental, NOT TESTED IN GAME

Current generated TurboCraft kits automatically use the managed synthetic
whine/airflow loops; audio remains silent when engine RPM/load is missing, the
induction device is inactive, or the engine is stopped/broken. These loops are
audio overlays, not validated real-world recordings or measured shaft sound.
Native turbo BOV/flutter, afterfire, engine and exhaust paths remain unchanged.
A ProCharger/centrifugal kit can play one CC0 atmospheric-release sample when
load falls from at least 0.65 to at most 0.25 after a measured prior boost of at
least 4 PSI; missing boost data cannot trigger it. This is a conservative
experimental heuristic, not a confirmed valve model.

In an isolated test profile, audio can be explicitly disabled or re-enabled
through the vehicle Lua console:

```lua
extensions.turbocraft.setOriginalAudioEnabled(false)
```

Pass `true` to re-enable. Managed audio caches the original 3D loops and varies
bounded pitch/gain using engine RPM, audio-only drive-ratio anchors, load and
available compressor pressure. Drive/impeller RPM is **derived
kinematically**, not a rotor-RPM sensor. It does not use Target PSI. Missing
RPM/load, a stopped/broken engine or absent induction device mutes it. Missing
boost contributes no boost-related gain and cannot trigger the centrifugal
release sample. Reset stops/re-arms the loops.
Source/API/node errors are logged and shown in Monitor Details. Native vehicle
ref-node origin is used; actual blower-node spatial placement remains unverified.

Native induction loop gain is zeroed for managed kits so the synthetic loops
have one audio owner; native turbo valve and engine/exhaust effects are not
replaced. Timbral realism, pitch/range/clipping, pause/reset, API availability,
release audibility, spatial falloff, Doppler and performance still need live
listening in BeamNG. `getStatus()` / telemetry `original_audio_status`
distinguishes disabled, ready, playing and missing-data states; these are not
game-acceptance results.

The local model drafted a provenance note. Its incorrect claims that **all**
induction audio was original and all APIs were officially documented were rejected;
the main agent replaced that draft with this source-verified record.
