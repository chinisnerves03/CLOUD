---
name: motion-graphics
description: Motion graphics for mod promos: animation principles, kinetic typography, lower-thirds, logo stings, transitions, spec-sheet animations, tools (After Effects, DaVinci Fusion, Blender, CapCut, HTML/Canvas), and render settings.
---

# Motion graphics **[tool menus change; verify]**

## Principles (apply to every animation)
- **Easing**: never linear. Ease-out for entrances (fast then settle), ease-in for exits, ease in-out for moves.
- **Anticipation + overshoot**: a small move back before, a 5-10% overshoot after; feels alive.
- **Stagger**: offset elements 2-4 frames so groups cascade, not pop together.
- **Hierarchy**: one hero element moves at a time; the rest supports.
- **Timing**: 8-12 frames for UI-type moves at 30 fps, 15-24 for titles; hold readable text >= 1 s per 3 words.
- **Consistency**: same easing, fonts (1-2), colours, corner radii across the series.

## Building blocks for mod videos
| Element | Notes |
|---------|-------|
| Logo sting (1-2 s) | mask reveal + sound hit; keep under 2 s |
| Title card | mod name big, tagline small, slide + blur-in |
| Spec sheet | power, weight, drivetrain counters ticking up, bars growing |
| Lower-third | config name, appears 0.3 s after shot starts |
| Kinetic text | words timed to voice; emphasise 1 keyword per line with colour/scale |
| Speed lines / shake | short camera shake (4-8 frames) on impact; don't overuse |
| Transitions | whip pan, zoom, wheel-spin wipe, flash-frame; <= 8 frames |
| Callouts | arrow/line pointing to a car detail, draws on in 10 frames |

## Tools
- After Effects (paid): industry standard. DaVinci Resolve Fusion (free). Blender (free, also for 3D). CapCut for fast templates. Code route: HTML/CSS/SVG/Canvas rendered frame-by-frame to video with headless Chromium + ffmpeg (scriptable, repeatable).
- Keep a template project: fonts, colour swatches, reusable comps; export transparent assets (ProRes 4444 / PNG sequence / WebM alpha) **[verify support]**.

## Render
Match project fps (30/60), 1080x1920 for vertical, H.264 high bitrate; keep a clean alpha version for re-use. Check text at phone size.

## Review checklist
- [ ] Easing on everything, no linear moves
- [ ] Text safe zones respected
- [ ] Sound hit on each key motion
- [ ] Nothing animates longer than it is readable
