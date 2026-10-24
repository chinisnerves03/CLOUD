# Prompt to paste into a cloud Claude Code session

Repo: chinisnerves03/CLOUD, branch claude/beautiful-rubin-03hsmj (PR #1), folder mini-detective/.
All files listed below are already in this folder (pushed together with this prompt), so no copying is needed.

---

```
You are continuing the animated series "Pip Thimble, Tiny Detective" in the folder mini-detective/ of this repo. Read these first, in order: 00_MASTER_PRIMER.md, 01_series_bible.md, 02_characters.md, 03_locations.md, 04_voice_cast.md, 05_episodes_01-10.md, 06_scripts_ep01-10.md, 08_knowledge_base.md, 09_shotlist_ep01.md, 10_captions_ep01.md, README.md.

STATE
- Entry 1 is finished as a self-contained HTML animation (ep01_preview.src.html + build_ep01.py -> ep01_preview.html) with ElevenLabs voice clips in audio_ep01/ (n1,n2,n3,n4 = narrator George; pip1,pip2 = Pip, Jesse; juno = Juno, Ruby B).
- The animation is an SVG paper-cut-out scene driven by a seek(t) function. A time-warp table WP maps real time to the animation's internal time so visuals follow the real voice timing. Voice start times are in the VO list, captions in CAP, sound effects in EV.
- Final cut of entry 1 is about 53 s, longer than the 30-45 s goal.
- Render pipeline used: headless Chrome via puppeteer-core, 12 parallel workers, each calling seek(t) and screenshotting #wrap at 1080x1920, 30 fps, then ffmpeg joins frames with a mixed audio track (voices plus synthesized effects), loudnorm to -14 LUFS. Scripts are render_worker.mjs, mix_audio.sh, make_mp4.sh in this folder.
- Captions for IG, TikTok, Facebook, YouTube are in 10_captions_ep01.md and were linted (caption.py READY, ig-human PASS).
- Profile picture: avatar_pip.png. Accounts created by the user: Instagram det28176 (to be renamed pipthimble), YouTube @PipThimble.

TASKS (do in this order, commit after each)
1. Build a one-command tool, tools/make_episode.py, that takes an episode number N and produces out/epNN.mp4 plus out/epNN_captions.md. Inputs: the script for entry N in 06_scripts_ep01-10.md. Steps: parse lines; generate voice per line with the ElevenLabs API using ELEVENLABS_API_KEY from the environment (never write the key in any file); measure each clip with ffprobe and find word pauses with ffmpeg silencedetect; build the scene HTML from a reusable template (generalize ep01_preview.src.html: shots data driven from a JSON shot list per entry); render frames; mix audio; encode MP4. Cache voice clips so a re-run never pays twice.
2. Write the shot list JSON and run the tool for entries 2 to 4 first. Show the user the result before doing 5 to 10.
3. Trim entry 1 to 45 s or less by cutting words in the script, keeping the clue and the cliffhanger. Re-voice only changed lines.
4. Write captions for every entry in the same shape as 10_captions_ep01.md (IG, TikTok, Facebook, YouTube).
5. Write a posting calendar (one entry per day, same time each day) as posting_plan.md.

RULES
- Never post anything, never create accounts, never enter passwords or tokens. The user posts and schedules by hand in Meta Business Suite, YouTube Studio and TikTok.
- ElevenLabs credits cost money. Before any batch of generations, state the line count and estimated credits and wait for approval. One take per line unless the user asks for more.
- Secret canon in 08_knowledge_base.md must not appear in any public caption, script or comment. Entry 1 mentions only the keyhole eye and the thread.
- Keep the look: paper cut-out, palette kraft #C89B6D, navy #1F2A44, mustard #E0A526, tomato #C8452F, cream #F3E9D2, teal #2F8F8B. Each entry opens with "Lost and Found Log, entry N", has one clue, ends on a cliffhanger that leads into the next entry.
- Mark anything not verified (voice by ear, timing by stopwatch) as unverified in your report.
- Voices are AI generated; keep the disclosure line in YouTube descriptions.
```

---

## Files that exist only on the user's PC (copy into mini-detective/ before the cloud session)
- ep01_preview.src.html, build_ep01.py, ep01_preview.html
- audio_ep01/ (7 mp3 files)
- avatar_pip.html, avatar_pip.png
- 09_shotlist_ep01.md, 10_captions_ep01.md, 11_cloud_handoff_prompt.md
- render_worker.mjs, mix_audio.sh, make_mp4.sh

## ElevenLabs generations already paid for (flows in the user's workspace)
7 clips for entry 1, about 564 credits. Audio files were downloaded, so there is no need to regenerate them.
