# Prompt to paste into a new cloud Claude Code session (v2)

Repo: chinisnerves03/CLOUD, branch `claude/pip-thimble-series-production-c7b8ah` (draft PR #3), folder `mini-detective/`.
Everything below is already pushed on that branch, including the entry 1 files (merged from `claude/beautiful-rubin-03hsmj`).

```
You are continuing the animated series "Pip Thimble, Tiny Detective" in mini-detective/. Read in order: 00_MASTER_PRIMER.md, 01_series_bible.md, 02_characters.md, 03_locations.md, 04_voice_cast.md, 05_episodes_01-10.md, 06_scripts_ep01-10.md, 08_knowledge_base.md, 09_shotlist_ep01.md, 10_captions_ep01.md, README.md, then 11_cloud_handoff_prompt.md (original task list and rules, still valid) and this file.

THE MOST IMPORTANT RULE: every new entry must look EXACTLY like entry 1. The user was upset when a first attempt used different characters. The look is defined by ep01_preview.src.html (SVG paper cut-outs, 540x960 world rendered at 2x, feTurbulence torn-edge + cream outline + drop-shadow filters, sky gradients, vignette, film grain, Georgia captions in a navy bar like "PIP: Huh. That's... interesting.", pencil-stub clock tower, thimble-roof houses, button plaza, crowd cut-outs, Pip with big white eyes + silver dotted thimble + map-pattern coat + red tie, Juno with teal hood, yellow goggles, crossed arms, envelope bag, long red scarf, folded-paper glider). Reference screenshots are in ref/. Reuse code from ep01_preview.src.html; do not redesign Pip or Juno.

STATE (what exists on the branch)
- Entry 1 is finished: ep01_preview.src.html + build_ep01.py -> ep01_preview.html, audio_ep01/ (n1-n4 narrator George, pip1-pip2 Pip/Jesse, juno Juno/Ruby B), pip_thimble_ep01.mp4, captions 10_captions_ep01.md. Final cut is ~53 s (goal 30-45 s).
- Pipeline code that is done and tested (with a scratch tone voice, never with real voice yet): tools/pt_script.py (parses 06 scripts; line ids n1.., pip1.., juno1.., brass1.., velvet1.., fuzz1.., col1..), tools/pt_voice.py (voice table from 04_voice_cast.md, content-addressed cache audio/cache/, ElevenLabs call using ELEVENLABS_API_KEY from env only, credit gate, ffprobe + silencedetect timeline, scratch voice via --tts mock), tools/pt_sfx.py (synthesized sfx/beds/music, numpy mix, two-pass loudnorm -14 LUFS), tools/pt_captions.py + tools/secret_terms.txt (caption lint), tools/make_episode.py (orchestrator: python3 tools/make_episode.py N [--plan] [--tts mock] [--approve-credits C] [--stills t1 t2 ..]), tools/render_worker.mjs (Playwright worker; NOTE: it is written for a 1080x1920 viewport and must be changed to viewport 540x960 with deviceScaleFactor 2 for the new template), shots/ep02.json, ep03.json, ep04.json (shot lists; their coordinates were written for an OLD 1080-wide template and must be rewritten for the 540x960 world).
- The scene TEMPLATE is mid-rewrite. tools/template/ currently holds the NEW ep01-faithful version: scene.html, defs.frag (filters/gradients copied from ep01), engine.js (seek(t), cameras, caption chunks, clue-card scene, end card), art_chars.js (Pip and Juno ported from ep01; Brass, Velvet, Fuzz, Cog, Collector drawn in the same style). STILL MISSING: tools/template/art_bg.js defining BG[name]($, shot) and PROPS[kind](state) and CARD[type](u). Needed: plaza (port from ep01, plus an option to draw boot-prints on the shelf underside and tilt the camera up to them), desk (kraft wood, clean rectangle, eye mark, CASE CLOSED stamp), lounge (Tin Lounge: curtains, spotlight, stage, bottle-cap booths, audience; dark option), marsh (striped sock hills, coin stepping stones, glove reeds, fog; building option), warehouse_int (colour-sorted shelves with keyhole-eye tags). Props: coin, redbutton, tag, stucksock, crumb, pole, musicbox, eyemark. Card types: eye (ep01 card), thread (gold silk), seal, ledger. The engine calls BG[name]($, shot) which must fill $('sky'), $('bg'), $('mid'), $('fg') and may return tick(t, ct).
- Nothing has been rendered with the new template yet, so it is untested. Old contact sheets from the abandoned first template are NOT the target look.

TASKS (do in this order, commit after each)
1. Finish the template (art_bg.js), update tools/render_worker.mjs, make_episode.py works end to end. Check that entry 1's look is matched by rendering a still of the plaza next to ep01 and comparing.
2. Rewrite shots/ep02-04.json for the 540x960 world, run `--tts mock` stills, then show the user. Before ANY real voice generation run `python3 tools/make_episode.py N --plan` for N=2,3,4 and state the line count and credits (entries 2, 3, 4 = 9 + 8 + 8 = 25 lines, 520 + 497 + 439 = 1456 characters, estimate ~1456 credits at 1 credit/char, UNVERIFIED) and WAIT for explicit approval. No ELEVENLABS_API_KEY was set in the cloud container, so the user may have to provide one through the environment settings; never write it to a file. One take per line.
3. Trim entry 1 to <= 45 s by cutting words (about 67 words max at the measured pace); keep the clue and cliffhanger; re-voice only changed lines (cached clips never repaid; adopt the existing audio_ep01 clips into audio/cache by content hash only if the text is unchanged).
4. Captions for every entry in the same shape as 10_captions_ep01.md (IG, TikTok, Facebook, YouTube), saved as captions/epNN.md; run the lint.
5. posting_plan.md: one entry per day at the same time each day.
Also estimated runtimes at ep01's pace (0.67 s/word): ep2 ~46 s, ep3 ~49 s (+2 s hum), ep4 ~42 s. Recommend trimming 2 and 3 before spending credits, and ask.

RULES
- Never post anything, never create accounts, never enter passwords or tokens. The user posts by hand.
- Credits cost money: state line count and estimate, wait for approval.
- Secret canon in 08_knowledge_base.md must not appear in any caption, script or comment.
- Keep palette kraft #C89B6D, navy #1F2A44, mustard #E0A526, tomato #C8452F, cream #F3E9D2, teal #2F8F8B. Each entry opens "Lost and Found Log, entry N", has one clue, ends on a cliffhanger.
- Mark anything unverified (voice by ear, timing by stopwatch, sfx by ear) as unverified. Voices are AI generated; keep the disclosure line in YouTube descriptions.
- The user writes Thai; answer them in Thai, keep files in English.
- Chromium + Playwright are preinstalled in the container (use NODE_PATH=$(npm root -g)); it has 4 cores, so use 4 render workers, and run long renders in the background with a log (a foreground command is killed after a few minutes).
```
