# Induction audio source revision — 2026-10-25

The user requests clearer intake/turbo sound and more convincing supercharger
and centrifugal sound. Supplied targets:

- Hellcat: https://www.youtube.com/watch?v=cKx-cb0fzeo
- ProCharger: https://www.youtube.com/watch?v=FYiQDqvD33Q
- Additional reference: https://www.facebook.com/watch/?v=1866698847581304

After the user explicitly authorized reference downloads and installing
yt-dlp inside the workspace, 15 reference recordings were downloaded and
fully decoded. References now include rotary 13B, BMW B58/S58/S65, LS3,
Mercedes 4.0 V8, Coyote 5.0, Voodoo 5.2, Godzilla 7.3, Ferrari 296 V6/458 V8
and R35 VR38. They are catalogued with original titles, channels, URLs,
durations and SHA-256 in the workspace review folder. The Facebook fetch was
throttled. No downloaded reference was used in generated mod assets.
The agent did not hear the recordings; FFT analysis is not listening or proof
of an isolated induction sound. A reference match is not established.

## Source changes

- Added an intake loop for both blower families. Roots gain drops strongly on
  unloading; centrifugal mechanical sound remains at light load.
- Turbo airflow is audible before boost using an RPM/load proxy. Measured
  pressure adds rush with a saturating curve; whine still requires actual
  turbo RPM. Requested PSI never creates audio shaft speed or actual boost.
- Replaced sparse fixed-tone hiss with periodic filtered broadband noise.
  Revised mechanical synthesis with rotor-order pulses, gear-mesh tones and
  broadband texture. These remain designed synthetic sounds.
- Corrected turbo sample metadata to a 100,000 RPM reference. Blower sample
  reference remains 3,000 simulation input-shaft RPM; no manufacturer impeller
  step-up ratio is claimed.
- Generated visual donors no longer copy their engine/exhaust sound-config
  links or banks, preserving the fitted engine's existing sample identity.

## Verification and audition

Lua tests: **144 passed, 0 failed**. Complete syntax: **19 Lua / 7 JS**.
Audio asset test: **24 generated + 2 legacy PASS**, including reproducibility,
hashes, PCM, levels, loop boundaries and endpoints. Package source validation
passes without writing a ZIP.

`tools/preview_induction_audio.py` renders three offline A/B WAVs in
`work/turbocraft_audio_revision_20261025` at the workspace root. Each is 9.5 s:
old 0–4.5 s, silence 4.5–5 s, revised 5–9.5 s. Both halves use the same +12 dB
audition gain, with no per-half normalization. Maximum file peaks range from
-11.64 to -11.20 dBFS. These are authored sweeps, not gameplay, engine
performance measurements or reference recordings.

The revised source/assets are not installed or packaged. Overlay is still
opt-in. Audible quality, reference similarity and game mixing remain
**NOT TESTED IN GAME** for this revision.

The review folder also contains `reference_catalog.json`, full-recording
`reference_analysis.json`, per-frame FFT CSVs, and `listen.html`. Reference
analysis uses mono 22.05 kHz, 4096-point Hann FFT, 2048-sample hop. Recordings
are mixed source material with no verified RPM/load annotations; the 11.4 s
S58 clip and discussion-heavy dyno clips are not complete engine sample
banks. Download metadata did not provide licenses. Three Wikimedia pages
identify possible CC BY recordings but external-license review is pending;
these remain candidates, not cleared release assets.

The review page was opened at `http://127.0.0.1:8774/listen.html`; browser
play/pause controls were verified on the first reference. This proves page
playback, not agent listening or game playback. Loopback server session
20884 serves only the review folder.

## Separate low-boost report

The user identified a 572 CUI Chevy Big Block RR in a Barstow Parts screenshot;
the menu also offers a separate RR Turbocharged engine. A later read-only live
screen observation during the user's driving showed roughly 6,400 RPM,
100% throttle, 1.9 PSI on both TurboCraft and UGP gauges, target 7 PSI, and
about 200 km/h. The exact fitted turbo, current engine variant, wastegate
status and shaft RPM were not established. This is evidence of low positive
boost at that instant, not proof of the cause. No boost physics changed.

No matching 572 RR engine source was found in workspace JBeam searches or
the workspace PGP engine-pack archive. The uploaded screenshot was copied to
the evidence folder; required `tools/see.py` failed with WinError 10061 and
the attached image was inspected directly.
