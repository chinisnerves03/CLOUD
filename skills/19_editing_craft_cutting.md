---
name: editing-craft-cutting
description: Detailed video-cutting craft for BeamNG mod clips: cut types, retention edit, rhythm, speed ramps, sound-led cuts, text timing, vertical reframing, ffmpeg recipes, and a self-review checklist. Use when editing any clip; complements 10 and 11.
---

# Editing craft: how to cut

Platform behaviour and tool menus change **[verify]**. Only the hook-retention lesson comes from a source link (see file 10); the rest is general editing knowledge.

## 1. Retention-first edit (the order of work)
1. Pick the payoff (best crash/drift/jump). Write it as the last beat.
2. Pick the hook (a striking frame or a question) for 0-1 s.
3. Fill the middle only with beats that raise a new question or escalate. Delete anything else.
4. Cut right after the payoff.
5. Watch the retention graph; re-cut the biggest drop in the next video.

## 2. Cut types
| Cut | Use |
|-----|-----|
| Hard cut on action | default; cut mid-motion (steering, impact) so the eye is carried |
| Match cut | same shape/motion in A and B (wheel -> clock, drift arc -> next drift) for flow |
| Jump cut | trim dead air in talking or repeated angle; use with a zoom change so it feels intentional |
| J-cut / L-cut | audio leads or trails the picture; makes montage feel smooth |
| Smash cut | silence/quiet -> loud impact for shock or humour |
| Cutaway | insert a detail (wheel, gauge) to hide a trim or add information |
| Speed ramp | 100% -> 20% -> 100% around impact; ramp curve eased, never linear |

## 3. Rhythm
- Shots 0.7-2 s in shorts, 1.5-3 s in trailers; slow a shot only when something is happening in it.
- Cut on the beat or on a snare/impact; place the biggest visual on the strongest beat.
- Vary shot size (wide, medium, close) and camera direction; never three similar angles in a row.
- Leave 1 breath (0.3-0.5 s) before the payoff so it lands.

## 4. Sound-led editing
- Edit to audio first: lay music + SFX, then cut picture to it.
- Whoosh on transitions, impact hit on crashes, riser into the payoff, silence for 0.2 s before a big hit.
- Fade/ duck music under voice; final loudness near -14 LUFS **[verify target]**.

## 5. Text and captions
- Hook text appears at frame 0, stays 1.5-2.5 s, max 6 words.
- Subtitles: 1-2 lines, high contrast, within safe zone (not bottom 20%, not far right).
- Highlight keywords with colour; animate in 4-6 frames, not slow.

## 6. Vertical reframing (9:16 from 16:9)
Re-frame per shot: keep the car and the point of action in the centre third; scale 120-180% and keyframe a gentle pan to follow. Do not just crop the centre.

## 7. Colour and finish
Match shots by exposure first, then grade; same LUT across a series; slight vignette; sharpen lightly after scaling.

## 8. ffmpeg recipes (free, scriptable) **[verify flags on your version]**
```
# trim without re-encode (cut at keyframes)
ffmpeg -ss 00:00:05 -to 00:00:12 -i in.mp4 -c copy cut.mp4
# 16:9 -> 9:16 centre crop + scale
ffmpeg -i in.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" -c:a copy vert.mp4
# slow motion 50% (video only)
ffmpeg -i in.mp4 -filter:v "setpts=2.0*PTS" -an slow.mp4
# loudness normalise to -14 LUFS
ffmpeg -i in.mp4 -af loudnorm=I=-14:TP=-1:LRA=11 -c:v copy out.mp4
# burn in subtitles
ffmpeg -i in.mp4 -vf subtitles=subs.srt out.mp4
```

## 9. Self-review checklist
- [ ] Hook visible in frame 0 without sound
- [ ] Every shot earns its place; nothing between hook and payoff is explanation
- [ ] Cut ends within 1 s of the payoff
- [ ] Cuts land on beats/impacts
- [ ] Text readable on a phone, inside safe zone
- [ ] Audio peaks clean, loudness ok
- [ ] Watched once on a phone at arm's length
