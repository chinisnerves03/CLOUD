# Prompt Library

Copy-paste prompts. They work with any chat model, cloud (Claude, etc.) or local (Ollama, LM Studio). For best results start every session by pasting `00_MASTER_PRIMER.md` first.

Placeholders are in `[SQUARE BRACKETS]`.

---

## A. STORY PROMPTS

### A1. Write the next episode
```
Using the canon in the MASTER PRIMER, write Entry [N]: "[TITLE]".
Previous entry's cliffhanger: [PASTE].
Requirements: 90-110 spoken words, one clue, one twist, ends on a cliffhanger, opens with "Lost and Found Log, entry [N]." Include ElevenLabs v3 audio tags in square brackets, VISUAL and SFX lines per beat, and an end card line.
Then list: the clue (1 line), the cliffhanger (1 line), canon changes (bullets).
```

### A2. Plan a mini-arc (5 entries)
```
Plan Entries [N] to [N+4] of Pip Thimble. Use the season arc in the primer. For each entry give: title, hook, one-line case, clue, twist, cliffhanger. Make sure each cliffhanger leads directly into the next hook. Do not reveal anything listed under "Secret canon". Keep the case small and the mystery big.
```

### A3. Hook generator
```
Give me 10 alternative opening lines (max 12 words each) for Entry [N] of Pip Thimble. Each must work in the first 3 seconds, start with or follow "Lost and Found Log, entry [N].", and contain one strange fact or unanswered question. Mark the 3 strongest.
```

### A4. Cliffhanger sharpener
```
Here is my draft ending: [PASTE]. Give 5 stronger cliffhangers that (1) stay in canon, (2) raise a question the viewer must see answered, (3) cost nothing extra to animate. Rank them.
```

### A5. Continuity check
```
Check this script against canon. List every contradiction with the primer or earlier entries (names, rules, times, objects, relationships). Quote the line and give the fix. Also flag anything that explains too much too early.
SCRIPT:
[PASTE]
```

### A6. Tighten to length
```
Cut this script to 95 spoken words without losing the clue or the cliffhanger. Remove jokes before clues. Keep audio tags. Return only the revised script and the new word count.
[PASTE]
```

### A7. Side-case (filler episode that still moves the arc)
```
Write a standalone Pip Thimble case about [LOST OBJECT TYPE, e.g. a single glove, an umbrella, a house key]. It must be solvable in 40 seconds, include the keyhole-eye symbol in the background, and drop one new tiny clue to the Season arc without resolving it.
```

---

## B. IMAGE PROMPTS (any image model)

### B1. Style prefix (prepend to every image)
```
Paper cut-out collage, flat construction-paper shapes with torn edges and visible paper grain, thin white sticker outline, soft drop shadow, no gradients, no text, palette: kraft brown #C89B6D, navy #1F2A44, mustard #E0A526, tomato red #C8452F, cream #F3E9D2, teal #2F8F8B.
```

### B2. Character sheet
```
[STYLE PREFIX] Character sheet of [CHARACTER DESCRIPTION from 02_characters.md]. Front view neutral pose with separate arms and legs for rigging, plus five facial expressions. Plain cream background.
```

### B3. Background layers
```
[STYLE PREFIX] [LOCATION add-on from 03_locations.md]. Vertical 9:16. Generate as: (1) background only, (2) midground props only on transparent or plain background, (3) foreground silhouettes only. Same camera angle for all three.
```

### B4. Clue card
```
[STYLE PREFIX] Extreme close-up on [CLUE, e.g. a keyhole-shaped eye scratched into stone]. Dramatic side lighting, large and centered, 9:16.
```

### B5. Negative prompt (if your model supports it)
```
photorealistic, 3d render, glossy, gradients, lens flare, text, watermark, logo, extra fingers, existing cartoon characters, brand names
```

### B6. Consistency trick
Generate the character sheet once, then use that image as the reference for every later image of the character. Never describe the character differently in later prompts; always paste the same description from `02_characters.md`.

---

## C. ANIMATION PROMPTS / DIRECTIONS

### C1. Shot list generator
```
Turn this script into a shot list for 9:16 paper cut-out animation. For each shot: time range, camera move (parallax drift, push-in, tilt), which layers move, character pose, SFX cue. Prefer simple moves: slides, rotations, scale pulses. Maximum 1 new asset per shot. Script:
[PASTE]
```

### C2. Standard moves (keep it cheap)
- **Slide-in:** 6 frames ease-out from off-screen.
- **Paper wobble:** ±2° rotation at 8 fps on idle characters.
- **Clue reveal:** hold on scene → paper-tear wipe → clue card scales from 90% to 100% over 12 frames.
- **Thread twitch:** the thread layer shifts 4 px every 3 frames for 12 frames.
- **Blink:** swap eye layer every 3–5 seconds, 3 frames closed.
- **Lip sync:** 5 mouth shapes timed to the audio waveform; you do not need all visemes.
- **Frame rate:** animate "on twos" (12 fps look) for the stop-motion paper feel.

### C3. Tool options (pick any; all optional)
CapCut (easiest), DaVinci Resolve, After Effects, Cavalry, Blender (2D). The rig template names in `02_characters.md` work in any of them.

### C4. Video-model prompt (if you use an AI video generator for B-roll only)
```
Paper cut-out stop-motion style, [SHOT DESCRIPTION], slow parallax camera drift, flat paper layers, soft shadows, 24 fps, vertical. No text, no realistic people, original characters only.
```

---

## D. ELEVENLABS PROMPTS

### D1. Line-by-line call
For each spoken line: voice from `04_voice_cast.md`, model `eleven_v3`, text exactly as in the script (tags included). One line per call.

### D2. Script-to-lines converter (LLM)
```
Convert this script into a table: line number | speaker | voice name | text with audio tags only (no VISUAL/SFX). Merge consecutive lines of the same speaker. Keep order.
[PASTE SCRIPT]
```

### D3. Voice design prompt (if you want to create a custom voice later)
```
Narrator for a cozy mystery: warm, patient, slightly dry British storyteller, mid-low pitch, close-mic, calm pace with deliberate pauses, never theatrical. Age 50s.
```
(Use only the description; the line to speak should come from the script.)

---

## E. PUBLISHING PROMPTS

### E1. Caption + hashtags
```
Write 3 captions for Entry [N] of Pip Thimble. Each: line 1 is a question about the cliffhanger, line 2 says "Entry [N+1] tomorrow.", line 3 is a comment prompt such as "What did YOU lose that never came back?". Add 5 relevant hashtags for animated mystery, cartoon storytelling and paper art. No emoji overload.
```

### E2. Comment replies in character
```
Write 5 short replies to viewer comments as "the Log" (dry, warm narrator): [PASTE COMMENTS]. Never reveal anything under "Secret canon".
```

### E3. Performance review
```
Here are the stats for Entries 1-[N]: [PASTE: views, avg watch time %, followers gained]. Rank the entries, say what the top 3 have in common (hook type, length, clue style), and give 3 changes for the next 3 entries.
```

---

## F. LOCAL vs CLOUD QUICK GUIDE

| Need | Local (Ollama / LM Studio) | Cloud (Claude etc.) |
|---|---|---|
| Daily script drafts | Good with a primer pasted first | Best quality and continuity |
| Continuity checks over many entries | Limited by context size; paste only relevant entries | Easy |
| Image generation | Stable Diffusion / Flux locally if you have the GPU | Hosted image models |
| Voice | Not covered here | ElevenLabs |
| Storage | Same folder in git | Same repo on GitHub |

Keep one source of truth: this folder in git. Edit locally, push, and the cloud session sees the same canon.
