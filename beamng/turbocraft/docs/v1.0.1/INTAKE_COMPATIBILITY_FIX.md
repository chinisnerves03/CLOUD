# Intake compatibility source fix — 2026-10-25

The user's Barstow 291 V8 Parts screenshot shows no TurboCraft choice under
Intake. An earlier isolated profile's generated state has a Barstow I6 intake
but no Barstow V8 intake. The current generator required the Intake slot and
`mainEngine.torque` on the same raw JBeam part. A split engine/long-block
layout can therefore be skipped even though the game's Parts menu has Intake.
This is a source-level explanation consistent with the screenshot, not a
confirmed reading of the main profile's live generator log.

`gen.collect` now accepts Intake slots on an engine part without a local
torque table, and infers otherwise unclassified slots from intake parts that
modify `mainEngine` or carry forced-induction data. Unknown power uses the
existing reference-power fallback; the fitted engine is scaled at spawn.
The GE generator version was raised to 8 and its cached output list is
checked for completeness before skipping a run.

Offline verification: Lua tests **139 passed, 0 failed** including split
long-block and nonstandard mod-engine fixtures; syntax **19 Lua / 7 JS**;
package source validation **PASS**. No ZIP or main-profile generated files
were changed. The fix is **NOT TESTED IN GAME** and is not installed.

Coverage is limited to mounted vehicle JBeam with an identifiable Intake
slot or engine-related intake part. A vehicle with no Intake slot, an
electric powertrain, malformed JBeam, or nonstandard mechanics cannot be
promised an interchangeable TurboCraft part. A generated parent without a
compatible forced-induction donor can lack a vehicle-specific visible mesh.
Test the Barstow 291 V8, D-Series V8, and a representative third-party mod
after a new candidate package is approved and installed.
