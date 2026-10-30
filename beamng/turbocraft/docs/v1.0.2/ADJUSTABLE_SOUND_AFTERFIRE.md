# Adjustable induction / cabin / afterfire — source revision 2026-10-25

User authorized installation of this revision on 2026-10-25. It is packaged
as private-adjustable-audio-afterfire-r5. The earlier r4 gauge-only archive
does NOT contain these controls. Installation proof is recorded separately
in the workspace install_adjustable_r5_record.json.

## User controls

Parts -> TurboCraft -> hardware -> Turbo Sound Level:
Low / Medium / Loud / Adjustable. Adjustable now exposes Spool, Intake/Air and
BOV/Flutter 0–200%, plus Cabin Induction Compensation 0–12dB (default6dB).
The camera-aware compensation affects only TurboCraft induction. It does not
change global game volumes, the cabin filter, host engine/exhaust bank or
other vehicles' onboard gain. Exterior sound is not given the cabin boost.

Current reference kits route whine and air through one managed owner in
originalAudio.lua, using createSFXSource2 with plain WAV paths at engineNodeID.
Their native whine/hiss coefficients are zero, preventing duplicate loops;
native induction physics and native BOV/flutter events remain active. Managed
whine follows real turbo RPM, or input drive ratio for a blower; missing shaft
speed silences the whine. Air follows actual pressure and RPM/load intake.
Gains are stronger than r3 and limited to1.6whine/1.0air with source peaks0.4;
this bounds each layer, not the whole engine mix. Combined clipping and real
cabin audibility still need a user listening test. Managed induction is new
runtime code and NOT TESTED IN GAME.

Parts -> TurboCraft -> hardware -> Afterfire / Rev Limiter:
- Native ECU / Afterfire: leaves host ECU, limiter and afterfire unchanged.
- Adjustable Afterfire / Native Limiter: native fuel-on-load-drop and sustain
  coefficients, overrun duration, burst flame sensitivity and bang volume.
- Adjustable Afterfire + Hard Cut Limiter: same controls plus a timeBased
  native limiter with0.03–0.20s cut time; enables that limiter, keeps host RPM
  limit. This changes the selected ECU's limiter behavior, not just a sample.

Selecting an adjustable effects part is required to add those tuning controls.
Default is Native; installing a ZIP alone does not enable a competition tune.
Universal diesel-dominant slots do not receive the gasoline effects selector.

## Clearer tailpipe flames (source candidate, 2026-10-28)

Eligible TurboCraft shift and held-limiter flame events now emit three short
pulses from the actual exhaust-end node pair, spaced 55 ms apart. Each pulse
uses five native flame particle types at a bounded count of two, with outward
velocities based on BeamNG's big-afterfire effect. The native flame adapter
uses three particles and 25% more outward velocity for each eligible native
flame call. Smoke and unrelated particles remain unchanged. Flame Chance,
minimum RPM, diesel, water, and missing-endpoint guards still apply.

Check in game with a compatible gasoline exhaust and an adjustable effects
profile: compare upshift, downshift, held limiter, and fueled native afterfire
in daylight and at night. Confirm the flames originate at the tailpipe and
do not overwhelm the scene or reduce frame rate. These visual and performance
checks have not been performed in game. The local reference-video vision tool
refused connection on this pass, so no visual-match claim is made.

Flame sensitivity changes native instant/sustained/shift thresholds. Zero
raises these burst thresholds to1e30. It does not create fuel, call a particle
emitter, bypass underwater checks, invent tailpipe nodes, or set
continuousAfterFireFuel. Other modules' native continuous flames are outside
this burst control. Real native afterfire fuel and working exhaust-tree ends
are required. No guarantee of flame length/colour per brand is claimed.

Viper/Evo/Ferrari/Corvette/Mustang/Supra/R34/RX7 are user reference targets;
choose the real fitted engine and tune its ECU. Its native bank/harmonics,
redline and exhaust path determine its identity. No generic 2JZ engine sample
was substituted for a V8/V10/rotary, and eight measured vehicle-specific flame
models have not been implemented.

## Evidence

User authorized read-only beamng.log plus stock sounds/thermals Lua inspection
and new reference downloads. Authorized audio MRuxpIZpQ8Q is metadata-labelled
900HP2JZ S15,360s; Iimc2c3T0HQ is a528s multi-car compilation. Both full decodes
and SHA/peak/RMS records are in work/.../new_reference_decode_analysis.json.
No new clip entered mod assets. Required see.py16-frame run failed connection
WinError10061; inspected a generated4fps-derived frame contact sheet directly,
including visible bursts near23s,170s,237s,297s and386s. These are source video
observations, not game evidence or a source-RPM/fuel measurement. No auditory
similarity acceptance is claimed.

Read stock native afterfire branch: fuel delayed from combustionEngine is
multiplied by each exhaust-end coefficient and compared with thresholds; a
continuous branch exists separately. Existing TurboCraft pipe coefficients
alone cannot make an engine with no afterfire fuel produce a burst.
Stock cabin DSP uses camera inside status and global AudioInsideModifier;
this revision compensates mod induction rather than rewriting that setting.

Validation:Lua234/234,syntax20Lua/9JS,40kit integration,4audio+3ECU parts,
18reference asset integrity,stage profiles,header/exhaust,legacy geometry/IDs,
package source validation and UI tests PASS. Tests cover camera transitions,
old-player cabin clear,stable ID dedupe,zero sound gains,real signal gating,
voice caps,no extra BOV/afterfire cue. Native BOV guard integration PASS.
Unchanged native thermals burst branch PASS for no fuel,zero sensitivity,
water and fueled instant/shift/sustained events. These are offline fixtures,
not actual in-game combustion or audible/visual acceptance.
