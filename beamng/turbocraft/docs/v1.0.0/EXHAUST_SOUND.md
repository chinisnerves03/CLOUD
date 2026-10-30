# Exhaust character follow-up — 2026-10-25

**Follow-up runtime configuration checks PASS for all nine D-Series pairs.**
See [actual results and timeout/retry](EXHAUST_SOUND_TEST_REPORT.md).
Audible quality remains **NOT TESTED IN GAME**. Existing older candidate ZIPs and their
previous harness measurements predate these acoustic changes; they are not
proof of the new sound. A separate 20261025 sound-test candidate was built
and tested; no audio recording or external sample was added.

## Current supported parts

Visible D-Series headers apply small additive native exhaust EQ offsets:

| Header | Additional high shelf gain |
|---|---:|
| Cast | -2 dB |
| Tubular | -1 dB |
| Equal-Length | 0 dB |

This intentionally darkens Cast relative to the more open profiles without
positive-gain boosting. It does not simulate individual exhaust pulses, firing
order, equal-length timing, primary length, tuned resonance or a real header's
measured spectrum. Native engine sound configuration remains unchanged.

Visible D-Series and ETK-C exhausts use their **existing** exhaust-tree
modifier nodes with explicit native `exhaustAudioGainChange`:

| Profile | Local modifier gain |
|---|---:|
| Street | -9 dB |
| Race (ETK-C Sport) | -4 dB |
| Open (ETK-C Race) | -2 dB |

These are node-local simulation attenuation values, not measured cabin SPL,
final mixer levels or certified differences between cars. Multiple paths,
native mixer behavior and other components determine the final sound.
Existing donor `soundConfigExhaust` EQ, `exhaustAudioMufflingCoef`, tree routing,
node positions, beams and original engine sound remain unchanged. Header EQ
and exhaust gain therefore combine through the native engine/exhaust path,
not a second sound loop. Street/Race/Open retain their different donor EQ
shapes, rather than sharing one loop played louder.

RPM, load, lift-off and exhaust damage routing remain native. This update does
not invent RPM/load samples, change pitch based on Target PSI, add artificial
backfire audio or increase flame probability.

## Unsupported surfaces remain explicit

Universal physics-only Header/Exhaust selectors retain the host vehicle's
native sound. They have no verified per-vehicle exhaust emitter mapping, so
this update does **not** claim that they change sound universally.
Future diameter/length/muffler/resonator choices are not implemented by this
change. Such choices need source data, compatible geometry/routing and
separately validated acoustic effects; adding names does not simulate them.

## Verification and live acceptance

Generator and workspace-only sync share the same profiles. Regression checks
verify exact profile values, ordering, no positive local gains, refusal of
missing modifier nodes or conflicting donor header EQ, preservation of donor
exhaust EQ/geometry/routing and native muffling fields. Generated game-profile
files under `test_runs` are not source JSON validation inputs.

Still required in game: same car/engine/camera/audio settings across all nine
existing header/exhaust combinations; idle, cruise, WOT, lift-off and damaged
pipe states; clipping, spectral character, cabin/exterior falloff and engine
identity. Native EQ merging must be confirmed on the supported game build.
Do not claim a new hardware layout or a recorded real-car match.

## 2026-10-25 current-source follow-up

Universal sound profiles are now implemented through the fitted engine's native
exhaust EQ API. See docs/v1.0.2/EXHAUST_CHARACTER.md for current behavior and
limits. The older runtime report above does not validate this new revision.
