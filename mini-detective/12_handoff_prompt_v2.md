# Prompt to paste into a new cloud Claude Code session (v3, after entry 4)

Repo: chinisnerves03/CLOUD, branch `claude/pip-thimble-series-production-c7b8ah` (draft PR #3), folder `mini-detective/`.

```
You are continuing the animated series "Pip Thimble, Tiny Detective" in mini-detective/ (repo chinisnerves03/CLOUD, branch claude/pip-thimble-series-production-c7b8ah). Read: 00_MASTER_PRIMER.md, 01_series_bible.md, 02_characters.md, 03_locations.md, 04_voice_cast.md, 05_episodes_01-10.md, 06_scripts_ep01-10.md, 08_knowledge_base.md, captions/ep02.md, README.md, 11_cloud_handoff_prompt.md (original rules, still valid).

LOOK RULE: every entry must look EXACTLY like entry 1 (ep01_preview.src.html; screenshots in ref/): SVG paper cut-outs, 540x960 world rendered at 2x, torn-edge filters, gradients, vignette, grain, Georgia captions in a navy bar. Never redesign Pip or Juno.

TOOL (tested on entries 2-4)
  python3 tools/make_episode.py N --plan                      # lines, chars, credit estimate, cache; spends nothing
  NODE_PATH=$(npm root -g) python3 tools/make_episode.py N --tts mock --stills t1 t2 ...   # free stills + out/epNN_work/contact.jpg
  NODE_PATH=$(npm root -g) python3 tools/make_episode.py N [--aspect 4:5]                  # real render (all voice clips must be cached)
Run renders in the background with a log (~5 min on 4 cores; a foreground command gets killed). Inputs: shots/epNN.json (540x960 coordinates; copy ep02-04 style; key fields carry forward, so give x/y at every key of a walk), tools/template/{engine,art_chars,art_bg}.js (BG[name], PROPS, CARD, CHAR). Existing backgrounds: plaza (with ceiling option), desk, lounge, marsh (building option), warehouse_int. Characters: pip, juno, brass, velvet, fuzz, cog (basic), collector (silhouette). Walk cycle: set "mv":1 on an actor's keys while it moves; leg phase is derived from x. Defaults: gap between lines 0.45 s, shot cut 0.22 s before the next line, end card 0.9 s after the last word, 2.6 s hold. Motion is monotone-cubic interpolated; camera at 30 fps; paper jitter at 12 fps (ep01 style, intentional).
VOICES: no ELEVENLABS_API_KEY in the container. Use the ElevenLabs connector (creative_create_flow, then creative_generate_speech with model eleven_v3, generations_count 1, voice ids from 04_voice_cast.md; the line text must equal the script line incl. tags), fetch signed mp3 URLs once with creative_get_flow_run_status (output is huge), curl them, then `python3 tools/adopt_clip.py N LINE_ID file.mp3` puts each in audio/cache (committed). The credit estimate is 1 credit per character and matched the real cost exactly.

STATE (all pushed)
- Entry 1: user's original (about 53 s, over the 45 s goal).
- Entries 2, 3, 4: DONE with real voices. out/ep02.mp4 (43.3 s), ep03.mp4 and ep03_4x5.mp4 (42.1 s), ep04.mp4 (37.6 s); cover_ep02/03/04.png (cover_epNN.html is the ep01 cover with ENTRY N and the title changed, rendered with Playwright at 1080x1920); captions/ep02-04.md (IG, TikTok, Facebook, YouTube). Credits spent by the assistant: 520 + 497 + 439 = 1,456, all user-approved.
- Not done: entries 5-10 (entry 5 "3:11" needs clock and workshop scenes, about 433 credits est.; 6 needs a locked matchbox workshop and pendulum shaft; 7 Skirting Board Street bench; 8 Bureau and speaking tube with the Collector silhouette; 9 the thread and climb; 10 the Vault and giant keyhole), trimming entry 1 to <= 45 s (about 67 words, keep clue and cliffhanger, re-voice only changed lines), captions for entries 5-10, posting_plan.md (one entry per day, same time, first 14 days per 01_series_bible.md section 9).

RULES
- Never post, never create accounts, never enter passwords or tokens; the user posts by hand.
- Credits cost money: state line count and estimate and WAIT for explicit approval. One take per line. A bare "approve" means the option you listed first.
- Secret canon in 08_knowledge_base.md must never appear in captions, scripts or comments (lint: tools/pt_captions.py with tools/secret_terms.txt, plus read it yourself).
- Palette kraft #C89B6D, navy #1F2A44, mustard #E0A526, tomato #C8452F, cream #F3E9D2, teal #2F8F8B. Each entry opens "Lost and Found Log, entry N", has one clue, ends on a cliffhanger.
- Mark as unverified: voices Boom Mike (Brass), Lyra (Velvet), Callum (Fuzz) were never listened to; synthesized sfx and music never heard; loudness lands near -15 LUFS (target -14); motion and cuts were checked on stills and numbers, not watched in full.
- Voices are AI generated; keep the disclosure line in YouTube descriptions.
- The user writes Thai; answer in Thai, files in English. Keep replies short; the user asked to save tokens and dislikes extra re-renders. Commit and push after each step (a stop hook demands it). pkill -f with your own command text kills your shell; use the [m]ake_episode trick.
- Open ideas the user raised, not done: a promo reel in a kinetic-typography style (needs a decision on purpose), ways to earn money from the series or from selling the tool as a Thai-language kit. A Flick (Creatorberry/flick) skill was copied to ~/.claude/skills in the old container only.
```
