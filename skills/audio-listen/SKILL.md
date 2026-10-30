---
name: audio-listen
description: Lets Claude "listen" to an audio or video file by turning its sound into a readable report - a timeline of what kind of sound plays when (tonal/whine, rising or falling pitch, noisy, speech-like, pops/bangs/hits), loudness and dominant-frequency numbers, spectrogram images Claude can look at, and a speech transcript when a speech model is available. Use this whenever the user shares or points to an .mp3/.wav/.m4a/.ogg/.flac/.mp4/.mov/.webm (or any clip) and asks what it sounds like, what is said, when a sound happens, whether a sound effect is right, or to compare two sounds - e.g. game/mod sound design, engine/exhaust/turbo noises, music, voice notes, podcasts, meeting recordings, TikTok/YouTube clips saved as files - even if they just say "listen to this" or "can you hear it".
---

# Audio listen

Claude cannot hear. This skill converts sound into evidence Claude can read and see, so be honest about
that in replies: describe what the analysis and spectrogram show, and leave judgements like "does it
sound good/realistic" to the user's ears, offering measurements that help them decide.

## Run it

```bash
python3 <skill-dir>/scripts/listen.py INPUT OUTDIR [--start SEC] [--end SEC] [--no-speech]
```

- INPUT: any audio or video file ffmpeg can read. Only the audio track is used.
- `--start/--end`: analyse one section. Use this when the user names a moment ("around 0:40"); a few
  seconds either side keeps the spectrogram detailed.
- `--no-speech`: skip transcription when the clip clearly has no talking (engine sounds, sound effects),
  because loading a speech model is slow.

Needs `ffmpeg` and `numpy`; Pillow for spectrograms. If `faster-whisper` (or `openai-whisper`) is
installed it transcribes speech; otherwise the report says so. When speech matters and no local model
exists, try `pip install faster-whisper`, or use a speech-to-text connector the session has (for
example an ElevenLabs transcription tool) on the extracted `OUTDIR/audio.wav`.

## Read the results

1. `OUTDIR/report.md` - the summary. Read it first.
2. `OUTDIR/spectrogram_NN.png` - one image per 30 s. **Open them with the image viewer (Read tool)**;
   they carry most of the information. How to read them:
   - x = time (seconds), y = frequency on a log scale (50 Hz-8 kHz); brighter = louder.
   - Stacked parallel lines = a harmonic tone (engine, voice, instrument, whine). Lines sloping up =
     pitch rising (revving, a whine climbing); a sudden drop of all lines = gear change or rev cut.
   - Thin vertical streaks across many frequencies = transients: pops, bangs, clicks, hits.
   - Diffuse wash with no lines = noise: hiss, wind, rain, crowd, tyre/road noise.
   - Speech shows as short bursts of curved harmonic lines with gaps, mostly 100 Hz-4 kHz.
3. `OUTDIR/report.json` - the same data with exact numbers, for comparisons or scripting.

The timeline labels come from simple signal measurements (tone vs noise, pitch trend, sudden loudness
jumps, energy in the voice band). They are hints, not a trained sound classifier; confirm them against
the spectrogram before telling the user what a sound is. A transient at 0.0 s often just means the file
starts on a sound.

## Answering the user

- Lead with what happens in the clip, in time order, citing timestamps ("at 7.4 s there is a short
  bang; from 12-17 s a tone climbs from ~300 to ~700 Hz, then drops at 17.3 s - likely a gear change").
- For speech, quote the transcript with timestamps and its language.
- To compare two sounds (e.g. a mod's sample vs a real recording), run the script on both, then compare
  dominant frequency, pitch trend, duration, loudness and transient rhythm, and show both spectrograms.
- When the user wants to judge quality or realism, give the measurements and the visual comparison, say
  what differs, and ask them to listen for that specific difference.
- Show the user a spectrogram when it explains something better than words (SendUserFile, or attach it
  to an artifact).
