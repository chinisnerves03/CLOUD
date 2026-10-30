---
name: audio-sound-design
description: Audio for BeamNG mods and their promo videos: engine sound packs, recording, editing, mixing, loudness targets, music licensing, and trailer sound design.
---

# Audio

## In-game engine sound **[verify the current sound system]**
- BeamNG uses an FMOD-based sound bank system; engine sounds are built from loops at RPM/load layers blended by the game. Reusing a stock engine sound set and tuning pitch/volume/blend parameters is the practical route for most modders.
- Custom sound = good recordings (on-load, off-load, several RPM points, clean loops), seamless loop points, consistent loudness between layers.
- Other cues: turbo whistle, blow-off, gear whine, exhaust pops, tyre squeal, interior vs exterior mix.
- Never ship ripped audio from other games or commercial sound libraries without a licence.

## Recording / editing
- Free tools: Audacity, Reaper (cheap), DaVinci Resolve Fairlight.
- Remove clicks at loop seams (zero-crossing cuts, short crossfades), normalise layers, high-pass below ~30 Hz to remove rumble.

## Promo video audio
- Structure: music bed (-18 to -20 dB under), engine/SFX hits on cuts, voice-over clear on top.
- Duck music under voice with sidechain or keyframes.
- **Loudness target: about -14 LUFS integrated, true peak below -1 dBTP** for YouTube/TikTok/Instagram **[verify; platforms normalise]**.
- Add whooshes/impacts on transitions and crash hits on slow-mo moments; audio sells slow motion.
- Use royalty-free or licensed music (YouTube Audio Library, Pixabay, Epidemic-type subscriptions **[verify licence terms]**). Copyrighted songs risk muting/claims and, on some platforms, removal.

## Voice
- Quiet room, pop filter, mic ~15 cm, record 10 s of room tone, remove noise lightly, compress gently, EQ for clarity.
- AI voices are acceptable if disclosed where platforms require it **[verify policy]**.
