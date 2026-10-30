# TurboCraft v1.0.1 audio development candidate

The generated CC0 assets cover Roots and centrifugal whine, turbo whine/hiss,
size tiers, atmospheric/tuned/recirculating BOV one-shots, and three cosmetic
afterfire-cue sizes. Two earlier BOV WAVs remain in the archive as explicitly
unreferenced legacy assets. The current deterministic synthesis profiles
differ by family, size, and BOV routing; they are designed sounds, not
recordings or measured vehicle spectra.

## Runtime behavior

The synthetic overlay is disabled by default and can be opted into with:

```lua
extensions.turbocraft.setOriginalAudioEnabled(true)
```

Disable it with `false`. Roots/centrifugal pitch follows engine shaft speed and
the configured simulation drive ratio. Roots rotor sound unloads strongly with
load; centrifugal mechanical sound remains at light load. Both have a separate
intake layer driven by RPM/load, with measured pressure adding gain. Turbo
whine requires live turbo RPM. Its intake layer is present before boost using
an RPM/load proxy, and measured positive pressure adds compressor rush. This
proxy is not measured air mass flow. One-shot BOV/cue sounds are gated by a
measured boost plus a high-to-low throttle transition. BOV type selects a
distinct synthesized profile; recirculating routing is quieter. The BOV and
afterfire cue thresholds are software gates, not evidence of measured valve,
combustion, fueling, or exhaust-temperature events. Target PSI is not used.

The source is anchored to the vehicle reference node, not a verified
turbo/blower/exhaust location. It can overlap native induction, BOV, or
afterfire sounds. Keep the overlay off unless deliberately auditioning it.
Playback API behavior, one-shot restart/timing, and native-audio interaction
are not confirmed in BeamNG.

## Flame and anti-lag scope

TurboCraft does not create a flame particle or claim that the synthetic
afterfire-cue sound corresponds to combustion or a visible flame. Any visible
flame remains controlled by BeamNG's native afterfire path and is not
synchronized by this cue. No anti-lag engine, fuel, or thermal physics are
added; this is **not an anti-lag system**.

## Provenance and acceptance

All added WAVs are deterministic mathematical synthesis authored in this
workspace under CC0-1.0; no recordings or third-party audio are used. File
peak/RMS values are digital file levels, not game loudness or real-world SPL.
The profiles are design approximations, not claims of matching real hardware.

Offline acceptance covers reproducible PCM assets, SHA-256, finite level,
loop seams, silent one-shot endpoints, Lua gating/state handling, and syntax.
Perceived timbre, loudness, clipping, cabin/exterior falloff, Doppler,
pause/reset behavior, one-shot playback, native sound overlap, and flame
appearance are **NOT TESTED IN GAME**.
