# Prompt to paste into a new cloud Claude Code session (v2, updated after entries 2 and 3)

Repo: chinisnerves03/CLOUD, branch `claude/pip-thimble-series-production-c7b8ah` (draft PR #3), folder `mini-detective/`. Everything below is pushed on that branch, including the entry 1 files.

```
You are continuing the animated series "Pip Thimble, Tiny Detective" in mini-detective/. Read in order: 00_MASTER_PRIMER.md, 01_series_bible.md, 02_characters.md, 03_locations.md, 04_voice_cast.md, 05_episodes_01-10.md, 06_scripts_ep01-10.md, 08_knowledge_base.md, 09_shotlist_ep01.md, 10_captions_ep01.md, captions/ep02.md, README.md, 11_cloud_handoff_prompt.md (original task list and rules, still valid) and this file.

MOST IMPORTANT RULE: every entry must look EXACTLY like entry 1 (ep01_preview.src.html: SVG paper cut-outs, 540x960 world, torn-edge filters, sky gradients, vignette, grain, Georgia captions in a navy bar). The user was upset when an early attempt redesigned the characters. References are in ref/. Never redesign Pip or Juno.

HOW TO MAKE AN ENTRY (works, tested on 2 and 3)
  python3 tools/make_episode.py N --plan                    # lines, characters, credit estimate, cache status. Spends nothing.
  NODE_PATH=$(npm root -g) python3 tools/make_episode.py N --tts mock --stills t1 t2 ...   # free scratch stills + out/epNN_work/contact.jpg
  NODE_PATH=$(npm root -g) python3 tools/make_episode.py N [--aspect 4:5]   # real render; needs all voice clips cached
Run full renders in the background with a log (about 5 min on 4 cores); a foreground command is killed after a few minutes. Needs shots/epNN.json (shot list, 540x960 coordinates; copy the style of shots/ep02.json and ep03.json), art for the entry's backgrounds in tools/template/art_bg.js (BG[name]($, shot), PROPS, CARD), characters in art_chars.js (pip, juno, brass, velvet, fuzz, cog, collector exist). Voice clips are cached by content hash in audio/cache/ (committed). No ELEVENLABS_API_KEY exists in the container; voices were generated with the ElevenLabs connector tool creative_generate_speech (model eleven_v3, generations_count 1, voice ids from 04_voice_cast.md, one flow per entry), then the signed mp3 URLs were downloaded with curl and put in the cache with `python3 tools/adopt_clip.py N LINE_ID file.mp3`. The connector's run-status output is huge; fetch it once per entry.

STATE
- Entry 1: finished earlier by the user (about 53 s, over the 45 s goal).
- Entry 2 "Footprints on the Ceiling": DONE. out/ep02.mp4 (40.9 s, real voices, 520 credits), cover_ep02.png, captions/ep02.md. 
- Entry 3 "Madame Velvet's Silent Night": DONE. out/ep03.mp4 (39.9 s, real voices, 497 credits), cover_ep03.png, captions/ep03.md. A 4:5 (1080x1350) version was started with --aspect 4:5 and finished: out/ep03_4x5.mp4 (39.9 s, 1080x1350).
- Entry 4 "The Sock Marsh": DONE. out/ep04.mp4 (35.4 s, real voices, 439 credits), cover_ep04.png, captions/ep04.md. Marsh and warehouse_int backgrounds now exist in art_bg.js.
- Entries 5-10: not started. Cog and Collector characters are basic.
- Total ElevenLabs credits spent in this project by the assistant: 1,456 (entries 2, 3, 4 = 520+497+439 = 1,456), all user-approved. Entry 1 earlier: about 564 by the user.

REMAINING TASKS (commit and push after each; the repo has a stop hook that demands it)
1. Entries 5-10 (show the user first, e.g. 5-6). State line count and credits and WAIT for approval before generating voices. One take per line.
2. Trim entry 1 to <= 45 s (about 67 words) keeping the clue and cliffhanger; re-voice only changed lines.
3. Captions for entries 1 (exists), 5-10 in captions/epNN.md (IG, TikTok, Facebook, YouTube; same shape as captions/ep02.md; lint with tools/pt_captions.py; no secret canon from 08_knowledge_base.md).
4. posting_plan.md: one entry per day, same time each day, first 14 days per 01_series_bible.md section 9.

RULES
- Never post anything, never create accounts, never enter passwords or tokens. The user posts by hand.
- Credits cost money: state count and estimate, wait for approval. The user typed a bare "approve" once; treat that as approval of the option you stated first.
- Secret canon in 08_knowledge_base.md must never appear in captions, scripts or comments.
- Palette kraft #C89B6D, navy #1F2A44, mustard #E0A526, tomato #C8452F, cream #F3E9D2, teal #2F8F8B. Each entry opens "Lost and Found Log, entry N", one clue, ends on a cliffhanger.
- Mark anything unverified as unverified: voices Boom Mike (Brass), Lyra (Velvet), Callum (Fuzz) were never listened to; synthesized sfx/music never heard; loudness lands at about -15 LUFS (target -14); timing and captions were only checked on still frames, not watched in full.
- Voices are AI generated; keep the disclosure line in YouTube descriptions.
- The user writes Thai; answer in Thai, files in English. Keep replies short; the user asked to save tokens (an optional local mod token-lean was written in this session, it does not persist).
- Other things the user asked about, not done: reproduce an Instagram "AI made this in 40 minutes" style promo reel (needs a decision: promo for the series, or a showcase to sell tools); making money from the series/tool (see earlier discussion: sell a Thai-language kit, build an audience first).
```
