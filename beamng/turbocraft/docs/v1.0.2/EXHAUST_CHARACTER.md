# Native header / exhaust character — 2026-10-25

Source revision, included in the next private controls/exhaust candidate.
Supersedes the universal-audio limitation in docs/v1.0.0/EXHAUST_SOUND.md.
The older runtime report covers its earlier revision only.

| Header | Intended character |
|---|---|
| Cast | Darker, less upper-mid bite |
| Tubular | More upper-mid presence than Cast |
| Equal-Length | Less low-mid/fundamental weight, clearer top end |

| Exhaust | Intended character |
|---|---|
| Street | Stronger upper-frequency attenuation / subdued rasp |
| Sport / Race | Intermediate upper-mid and high-frequency attenuation |
| Open | Least added high-frequency attenuation, leaner low end |

These are attenuation-only simulation EQ choices, not measured runner delays,
actual pulse timing, a new firing order, or recordings of each real header.
Nine header/exhaust combinations have distinct composite EQ profiles.

Visible D-Series headers retain their earlier canonical additive shelf. A new
native exhaust EQ module compensates that shelf when using the canonical
soundConfigExhaust section, so the same header is not counted twice. D-Series
and ETK-C keep existing emitter node positions, muffling/damage routing and
node-local exhaust gain. Universal Header/Exhaust selections now carry native
sound profile metadata too; they do not need invented tailpipe positions.

The module reads the fitted engine's soundConfiguration.exhaust and applies
only five existing EQ gain parameters through its setEngineSoundParameter API.
It retains sample bank, pitch/firing-order metadata, EQ frequency positions,
engine sound, on/off-load behavior, main_gain, muffling and limiter offsets.
No additional exhaust loop, artificial combustion event or flame is created.
Profiles compose without accumulating; source changes/reset parameters rebase
and removed profiles restore their baseline. Missing native sound IDs/APIs
report native_exhaust_audio_unavailable and do not create a substitute loop.
Legacy/custom sound systems lacking this API cannot be promised support.

Current reference-derived turbo loops, native BOV/flutter limiter behavior,
sound level selector and gauge improvements are also included in the next candidate; see
PRIVATE_AUDIO_TEST.md. Generator cache version 12 regenerates universal parts.

Validation: Lua 217/217, nine distinct EQ combinations, repeated-update stability,
profile removal, host bank/gain/frequency preservation, visible-header shelf
compensation, custom-section handling, native reset rebasing and unsupported
API fallback passed offline. Header/exhaust source metadata and physics curves
passed. The legacy source IDs and geometry remain covered by compatibility
checks; no new pipe geometry is claimed.

NOT TESTED IN GAME: audible character, spectral balance against turbo/engine,
clipping, actual EQ API application, part store visibility and damage-route
listening. User will perform live testing; no agent driving test is authorized
by the installation request.
