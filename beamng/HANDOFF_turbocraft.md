# TurboCraft handoff (branch `beamng-mod`, PR #4)

User writes Thai: answer in Thai, files in English. Token saving is priority #1 (see CLAUDE.md).

## Goal
Make the user's BeamNG.drive mod **TurboCraft Universal Framework v1.0.2** (`beamng/turbocraft/`) look and
sound like the reference clip "BeamNG.drive + Volumetric Backfire mod" (TikTok @rawsippa22):
- volumetric fireball at the tailpipe tip that lights the bumper/road; orange on low gears/downshifts,
  white-hot mid gears, blue-white small pops at speed in high gears
- drift-car style sound when the engine hits the rev limiter, plus realistic pops/bangs
Do not copy files from the Volumetric Backfire mod (someone else's work); recreate the look.

## Done
- `lua/vehicle/turbocraft/flameLight.lua` + `lua/ge/extensions/turbocraftFlameLight.lua` (loaded in
  `scripts/turbocraft/modScript.lua`): point-light flash on the exhaust tip node per afterfire flame,
  colour by gear/speed, follows the car, fades ~0.1 s. Triggered from the flame wrapper in
  `afterfireParticles.lua`.
- Native flames slowed (x0.8; limiter bursts in `eventEffects.lua` 4-11) so the fireball sits on the tip.
- `popBang.lua`: limiter whine (`limiter_whine_a/b.wav`, synthesized by `tools/make_limiter_whine.py`)
  on drift/hardcut profiles, one per cut, 0.35 s cooldown.
- Some mod Lua files use CRLF line endings: preserve them when editing.
- Checks: Lua syntax OK on all files (lupa), flame-light modules run against mocked APIs.
  **Nothing tested in game** (no game here). Light API names (`createObject("PointLight")`,
  `veh:getNodePosition`, `setField`) are unverified [verify].
- `skills/audio-listen/`: ffmpeg+numpy listening report (timeline, transients, spectrograms).

## Findings
- earshot (github.com/Leonxlnx/earshot, MIT, CLAP+AST models ~1.1 GB, CPU) is the better "ears":
  install `pip install -e "<clone>[mcp]"` (needs CPU torch from download.pytorch.org), check `earshot doctor --load`.
- earshot says the synthesized limiter whine is **no match** for "drift car rev limiter" (sounds like a
  chime/buzz) -> replace with real recordings.
- Reference clip audio: Demucs split shows background music (~130 BPM glitch hop, confirmed by earshot);
  engine harmonics land in the "other" stem; the pop extraction failed (earshot: squelch/speech).
- Clip frames: flames are short glowing balls with bloom, lighting the bumper.

## Next steps
- 2026-10-30: author supplied 3 clips (RB26 S14 anti-lag, 2JZ GT86 backfire, 25-min dyno compilation;
  uploads, not in git, licence unknown). 12 mod WAVs now cut from RB26/2JZ (see AUDIO_PROVENANCE.md).
  `tools/blend_reference_audio.py` matches all 3 sources (band-limit, LTAS EQ, level, comp, room) ->
  demo.wav + matched set (incl. burble_a/b/c from dyno 477.5 s). Blend v1 sent for approval; if it passes,
  copy set/*.wav into art/sound/turbocraft, update manifest, then merge with the user's local "R29" work.
  Old TikTok reference audio is not in this container.
- User rejected Blend v1 (two engines mixed). Rule: ONE car only; engine pull only at the start, rest =
  anti-lag, turbo, pops/bangs. Blend v2 = 2JZ GT86 clip only (5.3-12.7 pull+bangs, 12.6-16.2 turbo,
  18.2-28.6 anti-lag), ffmpeg xfades, low shelf +3 dB, light comp, -14 LUFS. APPROVED by user.
  Flame mock-up video (tools/flame_preview_mock.py) synced to v2 sent; awaiting feedback. Todo: re-cut
  antilag_up/limiter from the 2JZ clip so the whole mod is one car.
0. 2026-10-30: blocked. Env network policy denies freesound.org, cdn.freesound.org and github.com
   (proxy 403; earshot clone also blocked). Key is set. User must add these hosts under the environment's
   Network access -> Allowed domains (https://code.claude.com/docs/en/cloud-environments#network-access).
1. Get real CC0 car sounds via Freesound API (`FREESOUND_API_KEY` env var; send it as
   `Authorization: Token $FREESOUND_API_KEY`, use an honest User-Agent, download `previews.preview-hq-mp3`).
   Never print or commit the key. Candidates (all CC0, found via Openverse):
   675723 Car backfires reverberant (craigsmith), 105351 BACKFIRE.ogg (CeebFrack),
   351738 backfiring vehicle (nsstudios), 478756 Supercar rev and 478757 Supercar Day (richwise).
   Also search Freesound for rev limiter / drift limiter / anti-lag (cc0 only; avoid BY-NC).
2. Use earshot `find`/`match`/`ab` to pick and trim the best moments; replace or blend the synthesized
   limiter whine and pops; record credits in `docs/v1.0.0/AUDIO_PROVENANCE.md` and `LICENSES.md`.
3. Optional: custom particle data for real orange/blue flame colours (needs the game's particle files).
4. Package: zip the contents of `beamng/turbocraft/` (not the folder itself) and send it to the user.
5. Commit and push after each step; keep PR #4 updated.
