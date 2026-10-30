# Licenses and provenance

## Private local audio test bank (not packaged)

`art/sound/turbocraft/reference_dev/` contains filtered excerpts of the user's
three selected YouTube references (Hellcat, ProCharger and turbo compilation).
This separate bank is **not CC0**, and recording rights have not been cleared
for redistribution. It is retained in the source workspace for private
comparison only; `tools/package.py` excludes the entire directory from packages.
Do not publish or redistribute the bank. The manifest records source URLs,
recording hashes, extraction intervals and processing.
Source recording credits: Visual Car Reviews, Nemesis5Zero and AdamC3046.
This section supersedes the earlier no-recordings statement for this private
bank only. The original synthetic assets below remain CC0.

TurboCraft Lua/UI/tools are project source. The inherited additive D-Series and
ETK-C JBeam contain BeamNG-derived donor node/beam structures and references to
the licensed game's meshes; they are not wholly original vehicle art. No mesh,
texture, audio bank, recorded car sound, third-party sound pack or game Lua
binary/source file is added by this candidate.

Twenty-four current original procedurally synthesized WAVs and two retained
unreferenced legacy BOV WAVs under `art/sound/turbocraft/` are dedicated under
**CC0-1.0**:
https://creativecommons.org/publicdomain/zero/1.0/
They contain no sampled recordings. Their source formulas, individual hashes,
levels and limitations are provided by `tools/make_original_audio.py`,
the asset manifest and `docs/v1.0.0/AUDIO_PROVENANCE.md`. This dedication applies only to those twenty-six original WAVs. The manifest
lists the current 24 generated profiles and identifies the legacy files as
unused; no runtime feature refers to the legacy files.

The implementation uses BeamNG's documented mod extension, UI app, and package
interfaces. BeamNG.drive and its names remain the property of their respective
owners.

BeamNG-native engine, induction, BOV, and exhaust audio remains resolved by the
installed licensed game and is not redistributed here. Native audio is retained
by default; original synthetic overlays are experimental and opt-in. No claim
of a recorded sound library, real-vehicle audio match or manufacturer
endorsement is made. Official vehicle specifications are cited as facts in
`docs/v1.0.0/RELEASE_STATUS.md`, not copied as manuals or used as sound licenses.
