---
name: 3d-for-promo-and-mods
description: 3D skills beyond game assets: Blender scenes for cinematic renders, turntables, camera and lighting, materials, animation basics, rendering speed, and compositing 3D with game footage.
---

# 3D for promo (and mod assets) **[Blender versions differ; verify]**

## Scene setup
- Units metric. Import the car (or a proxy), set a ground plane with a shadow catcher, light with an HDRI (outdoor/studio) plus one key area light for rim highlights.
- Camera: focal length 35-85 mm for cars (long lens flatters); f-stop 2.8-5.6 for depth of field; focus on the front wheel/headlight.

## Shots
- Turntable 360 (12 s loop, linear rotation, so it loops cleanly).
- Slow push-in 3/4 front low.
- Detail macros (wheel, light, badge).
- Exploded view: parts fly apart with ease-out and stagger, for "how it's built" clips.

## Materials & lighting
- Principled BSDF: car paint = base colour + clearcoat 1.0 + clearcoat roughness 0.03-0.1; glass with IOR 1.45; rubber rough 0.6-0.8.
- Reflection control with large soft boxes; avoid blown highlights.

## Animation basics
- Keyframe location/rotation, set interpolation to Bezier with ease; use the graph editor to remove robotic speed.
- Rig wheels with a driver or constraint so they spin with travel distance.
- Use motion blur in render for speed.

## Render speed
- Eevee for quick; Cycles + denoise (OIDN/OptiX) at 64-256 samples for quality; render PNG sequence (crash-safe), then encode with ffmpeg.
- GPU rendering if available; reduce resolution for tests (50%).

## Combine with game footage
- Render with transparent background (Film > Transparent) or use shadow catcher; overlay on gameplay as an intro, or use 3D for title cards.
- Match the colour/contrast so the cut between 3D and gameplay isn't jarring.

## Reuse
The same Blender model feeds thumbnails, turntables, mod previews, and 3D text. Keep a clean scene file as a template.
