# Native afterfire endpoint transmission fix — 2026-10-25

## Confirmed runtime failure

The user selected Hard Cut, Flame100, fuel1.5 and Universal Open yet saw no
flames. Read-only Console output from their actual ETK-C vehicle25863 shows
four real exhaust ends:121->117,121->118,122->120,122->119. Every endpoint has
**afterFireVisualCoef=0**, while afterFireAudioCoef=.8 and gain=-4.5dB.
Evidence is saved outside the package in work/turbocraft_audio_revision_20261025/
afterfire_runtime_read.json. This proves native burst visuals are suppressed
regardless of the requested sensitivity; it does not prove the fuel trace or
an actual combustion event occurred during this idle diagnostic.

Universal Open previously changed physics/EQ metadata without changing native
exhaust-tree visual transmission. The host pipe's suppression remained in
force. The earlier unit tests supplied a nonzero endpoint coefficient and
therefore missed this integration failure.

## Current fix

Pipe parts carry turbocraftAfterfireVisualCoef (.08Street/.35Sport/.70Open)
into the actual engine definition. afterfireRouting.lua applies that visual
transmission to the existing exported native exhaust-end table only when the
user selects Adjustable Afterfire or Hard Cut. Native ECU keeps original
transmission. Removing the tune/pipe restores tracked baseline values.
Diesel and missing/invalid native endpoints are not substituted.

The module never emits particles, creates afterfire fuel, changes tailpipe
IDs/coordinates, alters audio/muffling or bypasses the native engine event,
threshold, sensitivity-zero or underwater checks. Native exhaust damage can
replace its endpoint table; subsequent updates use that actual table. The
Universal selector remains a simulated flow/acoustic profile over host
geometry; it does not install a physically different mesh or catalytic unit.

Gauge SET diagnostics show routing status and the number of applied native
endpoints. 'Applied' means routing configured, not a witnessed flame event.
Generator14 ensures metadata is refreshed after the new archive is loaded.

## Verification

Lua234/234;syntax21Lua/9JS;catalog40kits;UI;reference/control assets;header/
exhaust metadata;legacy IDs/geometry and package validation PASS. The native
thermals integration test now replays the user's captured zero-coefficient
endpoints against the unchanged native burst branch: failure reproduced,
corrected transmission passes a fueled test event at all four native ends,
all other endpoint fields preserved,profile removal restores0,and no-fuel/
zero-sensitivity/water/diesel still suppress expected events.

NOT TESTED IN GAME after applying the fix. The read-only r5 diagnostic is
runtime evidence, but the corrected route and visible flame still require a
new game load and a user-operated test. No statement of source-video flame
shape/size/colour equivalence is made.
