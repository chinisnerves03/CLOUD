# Easy drift / track setup

## Current source candidate (2026-10-28)

For a new gasoline TurboCraft kit, **Easy Pops & Flames** is selected by
default. Parts now show **Blow-Off Valve Sound** and **Exhaust Flames & Pops**.
Choose **Standard BOV · Audible**, **Sharp BOV · Loud Release**, or **Turbo
Flutter · No Valve**. Tuning shows **TurboCraft Easy Effects** with Flame
Chance, Pop & Bang Volume, and Minimum Flame RPM. Advanced effects remain
available under **TurboCraft Advanced Effects**. Existing saved configurations
keep their selected part IDs, so choose Easy Pops & Flames manually there.

The current source adds bounded pop/flame effects on held-throttle limiter
cycles and supported upshifts/downshifts. Effects use fitted exhaust endpoints
and are disabled for missing ends, submerged ends, diesel, Flame Chance 0,
or RPM below the chosen minimum. Flame Chance 100% emits on every eligible
scripted event; lower settings deterministically emit fewer events. They do
not change fuel, torque or boost.
The new peak-boost voice uses measured boost and turbo shaft RPM. Roots and
ProCharger loops remain separate, with the Roots synthesis revised. Actual
sound, flame appearance and UI layout still require an in-game check.

The original notes below describe the earlier R25 behavior.

Offline source checks cover the menu wiring and audio-control behavior. The
perceived sound, loudness, clipping, flame appearance and live game behavior
remain **NOT TESTED IN GAME** unless separately stated in a current test record.

## Quick setup

With a TurboCraft turbo fitted, open Parts under the turbo hardware:

1. Turbo Sound Level -> **Drift / Track - Easy Audio**.
2. Afterfire / Rev Limiter -> **Drift / Track - Easy Afterfire**.
3. Blow-Off Valve -> **Sharp Atmospheric BOV - Valve Release** for a single
   release, or **Compressor Flutter - No BOV** for native flutter.
   The actual Parts labels use a middle dot rather than the hyphen shown here.

No manual fuel, limiter or boost changes are required for these presets.
Do not replace the host engine or exhaust sample bank. For a first comparison,
keep the same engine, gear, actual boost, exhaust, camera and game master volume.
The effects selector is offered on gasoline kits, not diesel-dominant slots.
Roots and ProCharger kits have separate **Roots Supercharger Sound Level** and
**ProCharger Sound Level** selectors, each independent of Turbo Sound Level.
Both provide Low, Medium, Loud, Adjustable - Tuning and Drift / Track - Easy
Blower Audio choices. The adjustable part exposes independent whine, airflow
and cabin-balance sliders; these affect only TurboCraft overlay gain.

## Easy controls

Audio controls are under Tuning -> **TurboCraft Easy**.
Afterfire has its own **TurboCraft Afterfire - Easy** category with only
three plainly labelled sliders; no fuel, sustain or limiter controls.

| Control | Default | Range | Effect |
| --- | --- | --- | --- |
| Sound Presence | 100% | 0-125% | One knob for induction and native BOV/flutter levels |
| Cabin Balance | 6 dB | 0-12 dB | Extra induction gain only when the camera is inside |
| Flames Appear More Often | 100% | 0-100% | Higher values lower the native fuel threshold; real fueled bursts can appear more often |
| Exhaust Pop Volume | 110% | 0-150% | 0 = pops muted; 100 = standard native sound level; does not affect BOV or flutter |
| Minimum RPM to Show Flames | 0 RPM | 0-15,000 RPM, steps of 100 | 0 = all RPM; below the setting hides burst flames only |

For example, set **Minimum RPM for Flames = 4,000 RPM**: visible flames are
permitted at or above 4,000 RPM, only with real native afterfire fuel. RPM
alone never triggers a flame. Native afterfire sound remains independent.
The check uses current engine shaft RPM at the vehicle graphics update, not
the RPM when fuel first left combustion; native exhaust fuel delay still applies.
This is not a physics-substep-exact event cutoff. Missing RPM with a positive
minimum suppresses visible flames and reports a warning/status instead of
inventing RPM. Setting a minimum above the engine redline can prevent flames.
This profile gates the endpoint's visual transmission, including any other
mod's continuous flame through that same endpoint while below the minimum.

## Automatic transmission shift sounds

When TurboCraft is fitted, the runtime identifies explicit `dctGearbox` and
`manualGearbox` devices and supports `automaticGearbox` regardless of forward
gear count. An automatic with exactly eight readable forward ratios uses the
requested ZF8-style profile; other automatics use a general automatic profile.
Upshifts play at 30% throttle or higher; downshifts also play on lift-off, using
the selected engine's own native `shiftAfterFireSound` event at its exhaust
ends (or the engine node when exhaust ends are unavailable). DCT, ZF8, other
automatics, and manual profiles use separate level/pitch calibrations. The
downshift cue is audio-only: it does not add anti-lag fuel, combustion or
flames, and it reuses the vehicle's shift-afterfire sample rather than copying
audio from the reference clips.

If the engine already reports native `shiftAfterFireFuel` at the gear change,
TurboCraft leaves that shift event to BeamNG and does not add a second cue.
Sequential boxes are treated as automatic only when their vehicle controller
explicitly declares `automaticModes`; otherwise they remain unclassified.
Multiple or unrecognized transmissions are not guessed or modified. The added
sound does not create afterfire fuel or guarantee a flame; flames still require
real native fueled events. References supplied for
this experiment:
[DSG fart compilation](https://www.youtube.com/watch?v=YTBmAdvc38s),
[BMW DCT shifts](https://www.youtube.com/shorts/aOt9U0Ddv1A), and
[BMW G80 M3 launch control](https://www.youtube.com/watch?v=RPqqZTpRnsc).
The sound was not auditioned or verified in game.

For troubleshooting, open the TurboCraft Monitor's **SET** diagnostics and
check **Shift profile** and **Shift diagnostic** after a gear change. “SFX call
sent” confirms the extension reached the audio API, not that BeamNG rendered an
audible sound; other statuses identify the gate that prevented the call.
If the Monitor says the cue used the engine location because no exhaust end is
available, this fallback is for shift audio only; native exhaust flames still
require actual exhaust endpoints.

Start at defaults. Reduce Presence or Cabin Balance if the engine is masked;
reduce Afterfire Sound Volume if the combined mix distorts. Zero Presence mutes the
managed induction and selected valve gain, not engine/exhaust or other mods.
Zero Flame Sensitivity suppresses these native bursts, not another mod's
continuous-flame path. Zero ความดังเสียง mutes these native bangs.
Presence 100% means the new preset mix, not the old Loud preset.

The original Low/Medium/Loud/Adjustable and Factory/Adjustable/Hard-Cut choices
remain available. Switch back to Loud + Native ECU / Afterfire for the old
defaults. Existing part IDs, default slots and saved tuning are not rewritten.

## Blower reference basis

Roots and centrifugal response use separate managed loops and separate gain
controls. The Roots loop keeps mechanical whine tied to engine RPM while its
airflow layer unloads with throttle/boost. The centrifugal loop uses an
audio-only impeller step-up/RPM anchor and emphasizes boost-dependent airflow.
These values do not replace the simulation `gearRatio`, boost curve, or pulley
physics.

Reference sources: [2016 Dodge Challenger SRT Hellcat - SOUND!](https://www.youtube.com/watch?v=cKx-cb0fzeo),
[ProCharger sound without a hood](https://www.youtube.com/watch?v=FYiQDqvD33Q),
and [2019 Mustang GT P1X install and dyno](https://www.youtube.com/watch?v=4agWJAnY18s).
The manufacturer also publishes [P-1X/D-1X specifications](https://www.procharger.com/p-1x-d-1x-upgrade/)
and a [supercharger specification sheet](https://downloads.procharger.com/uploads/flyers/Supercharger_Specs_1025_v3_Street_Web.pdf):
P-1X uses a 4.10:1 audio reference ratio / 65,000 RPM impeller anchor; D-1X
uses 4.10:1 / 70,000 RPM. Fictional size classes use the P-1X anchor only as
an audio reference, not a hardware rating.

Video titles and their stated hardware were checked, but the clips were not
auditioned during this change. The `reference_dev` bank remains filtered,
mixed recordings with unknown source RPM and rights not cleared for
redistribution. No claim of exact timbre, real-world SPL, or in-game sound
match is made; listen in game before accepting the sound.
Easy flame/bang/presence use new tuning IDs so old advanced fuel/sensitivity
settings do not accidentally override the first selection. Previously saved
Easy values and the shared Cabin Balance value can still override defaults.

## Exact candidate calibration

Audio multiplies the previous Loud mix by 1.20 spool, 1.15 air and 1.40
BOV/flutter at 100% Presence. The master knob scales these together.
The managed loop caps remain 1.6 whine / 1.0 air; higher knob values do not
guarantee increased output once a voice reaches its cap. No whole-mix clipping
guarantee is possible without actual listening.

Afterfire keeps instant native fuel coefficient 1.0, reduces sustained
coefficient from the old adjustable default 0.5 to 0.12, and shortens the
sustain window from 0.4 to 0.15 seconds. This is a native ECU calibration, not
fabricated fuel telemetry or guaranteed flame duration. At default volume,
native lift/sustained/shift gains are 1.10 / 0.66 / 2.75.
No shift-fuel override, continuous fuel, rev-limiter or redline override is
added. The engine must still supply actual native lift or shift fuel.

Endpoint routing recognizes this profile and only changes the native visual-fuel
transmission for valid fitted exhaust endpoints, restoring the original value on
removal. That coefficient affects whether a fueled event crosses the flame
threshold; it does not change particle brightness, shape, or position. Native
muffling, sound events, pipe position, underwater checks and fuel thresholds
remain responsible for the result. The limiter BOV guard, gauge,
engine/exhaust EQ and distinct native BOV/flutter event selections are unchanged.

When a TurboCraft Afterfire profile is selected, the mod wraps only BeamNG's
native flame particle types (61-65): it doubles their particle count and raises
their outward velocity by 15%. That makes the burst denser and lets it project
a little farther past the same tailpipe; the exhaust endpoint and particle
colour/size shader are not changed. No fuel or extra bang is fabricated. If the
engine particle API cannot be safely wrapped, TurboCraft logs a warning and
leaves the native effect unchanged. The visual result and compatibility with
other particle-hooking mods still need an in-game check.

This does not guarantee a particular flame colour, shader brightness, length,
or visibility on every vehicle. Position is still defined by the selected
vehicle's native exhaust nodes and must be checked with the actual exhaust part.
The shorter sustain is intended to avoid constant crackle; native cooldown,
fuel and host configuration determine actual burst timing.

## Checks before acceptance

Offline checks exercise actual preset JBeam expressions through managed audio,
mute/gain/cabin/caps and cached loops, and run the unchanged native thermals
burst branch for all three effects profiles: no fuel, zero sensitivity, water,
native lift/shift/sustain, zero bang gain and endpoint apply/restore, and
minimum-RPM boundaries (3,999/4,000/4,001), zero restriction, missing signal,
unchanged native sound and host-pipe restoration.
Generator parity and existing-part preservation are checked separately.

In game, compare short boosted lifts and actual gear changes inside/outside;
confirm visible bursts originate at the fitted tailpipe, no steady flame or
held-throttle limiter BOV, no clipping, and a real distinction between BOV and
flutter. Also check stock/Native restoration and saved configuration reload.
The isolated launch/control attempt did not establish listening or visual
acceptance. Its preserved `beamng.log` reports a C++ secondary-thread crash;
the root cause is not established. No `tc_r9_results.json` was produced.
