> Current uninstalled source revision: see ADJUSTABLE_SOUND_AFTERFIRE.md. Managed induction/cabin controls supersede the historical native-whine routing below.

> Historical private-candidate report only: current managed loops use original
> CC0 synthesis, and the private `reference_dev` bank is excluded from packages.
> See `docs/v1.0.0/AUDIO_PROVENANCE.md` for current runtime behavior and limits.

# Private main-profile audio and controls test

This development candidate is for the requesting user's local game only.
The reference-derived recordings are not cleared for public redistribution.
See LICENSES.md and the reference_dev bank manifest for source credits,
selection intervals, hashes and processing. Source shaft RPM is unknown;
pitch anchors of 4,000 input RPM / 100,000 turbo RPM are audition calibration,
not measured values from the clips.

## Audio

Native BeamNG 0.40.3 induction devices play filtered Hellcat/ProCharger/turbo
reference loops via whineLoopEvent. Native shaft speed and compressor pressure
drive pitch and gain at the engine's sound node. A small separate RPM/load
intake layer fills the period before boost and is enabled automatically for
these TurboCraft kits. It does not invent shaft speed or pressure.

The native BOV path handles valve events. The default reference mode adds no
synthetic BOV, afterfire cue, or flame. Original engine/exhaust sample banks
remain owned by the fitted engine, rather than its visual induction donor.
The Roots simulation hardware retains its original physics; its audition
sound target is the user's Hellcat clip (IHI twin-screw), not a claim that
Roots and twin-screw hardware are identical.

## Menus and control

- Turbo hardware owns seven BOV choices: race atmospheric, tuned, quiet
  recirculating, sharp, deep, compact and no BOV/native flutter. These use
  existing native events verified in stock 0.40.3 JBeam; labels do not claim
  an exact branded recording. HKS/TiAL/Turbosmart links are reference research.
- Wastegate owns 0.25 / 0.5 / 1.5 PSI opening-band choices. They change the
  native wastegateLimit band while preserving the single wastegateStart
  baseline used by the existing LOW/MED/HIGH gauge setWastegateOffset call.
  These are control-response bands, not fabricated valve diameters.
- Blowers own 90% / 100% / 110% pulley-drive parts. Their gearRatio multiplier
  changes native blower speed, pressure generation and crank loss. They no
  longer offer a pressure-slope slider pretending to be a wastegate.
- The same gauge reads actual blower pressure and shows pulley drive ratio.
  Turbo target controls are disabled on a blower; no false live PSI actuation.

## Acceptance

File/unit checks cover source hashes/PCM/seams, every catalog slot/default,
pulley drive multipliers and gauge offset continuity. In-game and sensory
results are recorded separately after installation. Do not treat passing
offline checks as evidence that a source is audible or reference-matched.

## 2026-10-25 source-only audibility revision

User reported induction being masked by engine audio, and separately instructed
that the agent stop touching the game. No game, main-profile files, or existing
ZIPs were accessed or changed for this revision.

- Replaced the failed file:> FMOD-style loop URIs with plain art/sound/... WAV
  paths passed through native induction configuration. This is a proposed fix
  based on the captured load failure; playback remains NOT TESTED IN GAME.
- Raised native reference whine/hiss coefficients by 1.6x (about +4.1 dB), with
  matching bounded envelopes of 0.96 whine and 0.80 hiss. Doubled the small
  pre-boost RPM/load intake overlay (about +6 dB). No engine-bank gain, boost,
  pulley physics, BOV event or afterfire behavior was changed.
- Regenerated source catalog/JBeam only. Plain paths and asset existence are
  checked for both whine and hiss. Lua 148/148; full syntax 19 Lua / 7 JS;
  reference assets, stage profiles, catalog integration and package source
  validation PASS. No new ZIP was built or installed.

The installed private candidate still has its earlier paths/mix. Audibility,
clipping in the combined game mix and reference similarity require a future
user-authorized in-game check. A source change is not an installed fix.

## Source revision: limiter BOV, sound levels and gauge (2026-10-25)

Not installed. No game control or live testing was performed for this revision.

### BOV

The authorized read-only inspection of stock BeamNG 0.40.3 turbocharger.lua
shows BOV is triggered by low engine load / a load drop, gated by
`revLimiterWasActiveTimer > 0.1`. A hard limiter can set that timer to zero
during the load cut, suppressing the native valve event. TurboCraft now raises
the timer to 0.11 only inside its native turbo update when requested throttle is
at least 25%, engine speed is within 90% of the limiter, and the live timer is
at or below 0.1; it restores the original value immediately, even if the native
update errors. The event, sample and volume remain native. Offline regression
uses the unchanged native update body and confirms this limiter path; the
user's in-game audio result remains unverified.

Limiter chatter is intentionally allowed for burnout behavior; TurboCraft does
not rewrite limiter physics.

### Sound selection

Parts / Parts Store path: TurboCraft -> turbo hardware -> Turbo Sound Level.
Four shared audio parts exist for every generated turbo kit and the D-Series:
Low (35%), Medium (65%), Loud (100%, default retaining r2 loudness), Adjustable.
With Adjustable selected, Tuning -> TurboCraft Audio exposes three independent
0–150% sliders: Turbo Spool, Turbo Intake / Air, BOV / Flutter. At 0%, that
layer is silent; 100% equals Loud. These adjust sound coefficients only, with
no boost/torque/wastegate changes. Blower kits retain their pulley controls;
this sound selector is specifically for turbo kits. Preset/default tuning may
be overridden by saved vehicle tuning; verify selections in-game.

### Gauge

Kept existing 220px circular face. Normal positive range is now 0–20 PSI for
readability, expanding to 40/60/80/100/150/200+ as required. New state targets
are processed before scale selection. Blower scale and LED markers ignore
stored turbo targets. Needle now uses a 90 ms CSS-transform transition and a
short outer pointer so it does not cross the numeric readout; digital PSI
still follows actual samples without numeric smoothing. Missing/stale signals
remain a dash, not zero. Missing pulley ratio is a dash. Reduced-motion support
is retained. Workspace-only preview checks five simulated signal states;
this is not game telemetry or a live gauge measurement test.

### Validation

Lua 150/150; syntax 19 Lua / 8 JS; native BOV reproduction and guard/lift-off/
flutter/pressure/wastegate/error-cleanup/reset test PASS; 18 reference assets,
4 audio parts and slider/control coverage PASS; 40-kit universal integration,
stage profiles, original assets, header/exhaust curves and package source
validation PASS. Generator cache version 11 forces new selector generation
when a future candidate is installed. No ZIP was built or installed here.
Runtime BOV behavior, menu visibility, actual sound levels and gauge motion
remain NOT TESTED IN GAME. The stock source snapshot used for offline tests
stays under work/, outside packaged mod contents.
