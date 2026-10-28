---
name: effects
description: Use when the user types /effects <name> or asks to apply a reel effect (magazine cover, before/after slider, orbiting camera) to a raw vertical or horizontal clip. Runs effects.py (ffmpeg only) and returns the edited mp4.
---

# /effects

Script: `skills/effects/effects.py` (needs ffmpeg + DejaVu fonts; output 1080x1920, H.264, audio kept).

| Command | Result |
|---------|--------|
| `/effects magazine` | magazine-cover frame (white border, masthead, headline) for the first N s |
| `/effects beforeafter` | a line sweeps across; "before" side desaturated, "after" boosted (or pass a second clip) |
| `/effects orbit` | zoomed camera drifting in a circle around the centre |

```
python3 skills/effects/effects.py magazine IN.mp4 OUT.mp4 --title "MODZINE" --headline "THE CAR THAT SURVIVES" --dur 2.5
python3 skills/effects/effects.py beforeafter IN.mp4 OUT.mp4 --before-grade [--after AFTER.mp4] --wipe 3
python3 skills/effects/effects.py orbit IN.mp4 OUT.mp4 --zoom 1.25 --period 4
```

## Rules
- Run only what the user asked; write output next to the input as `<name>_<effect>.mp4`.
- Never overwrite the input. Show the user the output path.
- Tested on a synthetic clip, one still frame per effect; not tested on real footage and not watched in motion. Say so.
- "Orbit" is a camera-drift approximation, not a subject-cutout orbit (that needs a masking tool).
- More effects ("5 more") are not built yet: ideas = punch-in zoom on beat, glitch flash, split screen, countdown title, subtitle pop-ins.
