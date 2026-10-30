# Exhaust sound runtime test — 2026-10-25

**PASS: native acoustic configuration merge and driving coverage, nine
header/exhaust combinations. NOT TESTED: perceived audio quality.**

Actual BeamNG **0.40.3.0.290897**, Gridmap V2, D-Series `d15_4wd_M` V8 4.5L,
Ultra internals, Single TC-S60, manual third gear, 20 PSI requested.
Latest source test package:
`dist/TurboCraft_v1.0.0-exhaust-sound-20261025-test-candidate.zip`
SHA-256 `579777E9FF6E138CA8AA436BB00582A10C329A5E615D2370D3D9F25AE5BDDAF9`.
CRC and every runtime/JBeam/UI/audio byte match current source.

## Execution and preserved timeout

Initial workspace profile `test_runs/tc100-20261025-021744-142` reached the
14-minute wall timeout with eight completed combinations. It remains an
**incomplete/timeout session**, not an all-pass run. The unusually long first
run/startup was not diagnosed; no performance claim is made.

Retested only Equal-Length/Open in a fresh workspace profile,
`test_runs/tc100-20261025-023158-802`, with the identical package. It completed.
Combined coverage is **9/9 configurations, 2550 recorded samples**; both raw
sessions remain separate under `exhaust_sound_evidence/`.
No product physics/sound parameter or acceptance threshold was changed during
testing. Both owned launcher/game process pairs were stopped and absence
confirmed; main profile and other games were not modified.

## Native parameters actually loaded

Values below are runtime `v.data.soundConfigExhaust.highShelfGain`, not just
the source modifiers. Host engine EQ contributes too.

| Header | Street | Race | Open |
|---|---:|---:|---:|
| Cast | -7 | -1 | 0 |
| Tubular | -6 | 0 | +1 |
| Equal-Length | -5 | +1 | +2 |

Pipe modifier nodes actually reported gain **-9 / -4 / -2 dB** respectively,
with original muffling values **0.50 / 0.60 / 0.66**. Left/right nodes in dual
paths were checked individually. Existing native `V8_cross_exhaust` sample
remained selected. Positive final high-shelf values above include the host
engine contribution; our header modifiers themselves remain nonpositive.

Subtracting each declared part contribution yields the same host EQ residual
across all nine combinations: low shelf -13, high shelf +3, fundamental -4,
low EQ 0. This verifies relative additive behavior, not an independent
measurement of the engine's sound without exhaust parts.

Every combination confirmed fitted header/exhaust IDs, at least 20 valid
full-load pressure samples, third gear, low-to->5000 RPM coverage and recorded
lift-off. No broken-engine flag or >30 PSI abort excursion was recorded.
Per-pair peak boost ranged **21.01–22.65 PSI**; different temperatures and
uncontrolled drive conditions prevent using these peaks as a calibrated
performance ranking or claiming that EQ caused any power change.

## Errors and limitations

No console error containing sound/audio/TurboCraft/tcSweep was found across
the two logs. The logs are **not clean overall**: combined DLSS errors 2,
binding-description errors 455, Gridmap missing-path errors 2 and another
ActionMap error 1. No baseline test proves those independent of this mod.

**Audible loudness/timbre/clipping, final mixer spectrum/SPL, cabin/exterior
falloff, damaged-pipe routing and visible afterfire remain NOT TESTED IN GAME.**
No sound capture/listening evidence was obtained. Correct native configuration
does not prove that differences are sufficiently audible, realistic or pleasant.
ETK-C live acoustic behavior and universal physics-only sound were not tested.

Details: `exhaust_sound_runtime_report.json`; analyzer
`tools/report_exhaust_sound.py`; runner `tests/ingame/run_v100.ps1`.
The report records original incomplete status, supplemental completion, both
raw SHA-256 values, every merged EQ/node and console categories.

Focused offline checks also passed: header/exhaust profiles, legacy
geometry/donor-audio preservation, full syntax 19 Lua / 7 JS.
