# BOV and compressor-flutter event ownership

## Current source candidate (2026-10-28)

TurboCraft now controls its selected BOV sound from a measured positive
`electrics.values.turboBoost` signal and a fall in `engine.requestedThrottle`.
It mutes the native BOV *sound coefficient* in the scaled turbo data while
leaving the native turbo pressure, valve physics, wastegate and spool code
running. This avoids the native load-drop cue on limiter and ignition cuts.
The held-limiter effects module no longer emits a BOV or flutter sample.
The new sound state machine tracks IDLE, PRESSURIZED, THROTTLE_CLOSING,
DISCHARGING and RECOVERY; the chosen BeamNG event is played once per valid
lift with gain and pitch scaled by boost and throttle drop. A closed throttle
cannot repeat the cue, and a later reopened throttle rearms it. The pitch
change alters the duration of the existing sample; it is not a physical
measurement of how long the valve stays open. Positive compressor boost times
throttle closure is a pressure-differential proxy because this framework has
no verified upstream/downstream pressure pair on every compatible vehicle.
In-game timbre, exact duration and absence of a native residual cue remain
unverified. The older R25 description below is retained as history.

TurboCraft exposes both `Sharp Atmospheric BOV · Valve Release` and
`Compressor Flutter · No BOV` in the existing Blow-Off Valve Parts slot. Their
saved-config IDs remain `turbocraft_bov_sharp` and `turbocraft_bov_none`.
The first selects BeamNG's native BOV event; the second disables BOV and selects
BeamNG's native compressor-flutter event. The adjustable valve-volume part
scales both native coefficients without enabling either event.

`originalAudio.lua` still owns only TurboCraft induction loops. The selected
No BOV / Flutter part retains BeamNG's native compressor flutter behavior;
TurboCraft's BOV sound controller does not emit flutter samples. Native
engine/exhaust logic remains the owner of fueled afterfire sound.

This does not claim the selected vanilla event sounds identical to the S15
reference. Candidate windows in
`work/turbocraft_clip_20261025/bov_candidate_times.json` are spectral leads,
not confirmed BOV/flutter labels. The private audition is not release content.
The referenced recording is not cleared for public redistribution.

Offline regression coverage verifies selector IDs, valve volume, BOV trigger
levels, held-limiter suppression, rapid shift rearming, reset, and separation
from flutter. Actual timbre, audibility, overlap of real one-shot samples,
cabin/exterior balance, and game Parts visibility remain **NOT TESTED IN GAME**.

## Manual listening check

Use an isolated test profile with the same S15 drift-car mod and 2JZ setup as
the reference. Fit the TurboCraft TC-S60 single-turbo kit, standard wastegate,
Tubular header, Race exhaust and Adjustable audio part. Use manual third gear.
First select **Sharp Atmospheric BOV · Valve Release**, then repeat with
**Compressor Flutter · No BOV**; do not change engine/exhaust sample banks or
master volume between runs.

From the driver camera and then an exterior camera, accelerate under full load
until the gauge shows real positive boost, lift the throttle fully once, and
compare the release sound. Repeat once while holding throttle through brief
limiter cycling and confirm no BOV hits. Save the same-run gauge telemetry and note Parts visibility,
console errors, audible clipping, and whether induction is masked in-cabin. Do
not infer combustion or flames from a bang sound.
