---
name: blender-3d-pipeline
description: 3D asset pipeline for BeamNG mods: Blender modelling, scale and axes, UV unwrap, PBR textures, LODs, naming, exporting COLLADA (.dae), material JSON, and preview renders.
---

# Blender → BeamNG pipeline **[verify exporter/addon details for your versions]**

## Setup
- Units: metres, scale 1.0. Car forward axis and up axis must match what the game expects (check a stock model imported into Blender and mirror its orientation).
- Blender is free; community add-ons exist for BeamNG import/export and jbeam editing — search the BeamNG forum for the currently maintained ones.

## Modelling
- Reference sheets/blueprints on separate image planes; model real-car proportions (wheelbase, track, height) to the millimetre-ish.
- Separate meshes by function: body, doors, hood, trunk, glass, wheels, interior, lights. Detach what must deform or move separately.
- Quads, clean topology, supports for subdivision; apply modifiers before export.
- Budget: aim for a few hundred thousand triangles for a hero car total, far less for props; provide **LODs** (lower-poly versions for distance).

## UV & textures
- Non-overlapping UVs for baked maps; consistent texel density.
- Maps: base colour, normal, roughness/metallic (or the packed format the game uses **[verify]**), AO, emissive for lights.
- Texture sizes: 2048 for main parts, 1024 for small; DDS/PNG per game's expectation **[verify]**; power-of-two sizes.
- Build a separate **paint** material so players can recolour the car.

## Materials
Each mesh material needs an entry in `materials.json` (or `*.materials.json`) pointing to texture paths relative to the mod root. Name materials uniquely (prefix with mod name) to avoid clashes.

## Export
- Export COLLADA `.dae` (one file or a few); named nodes match jbeam `flexbodies` mesh names exactly — typos are the #1 cause of invisible parts.
- Re-import the .dae into a fresh Blender scene to verify nothing flipped.

## Renders for marketing
Render turntable and 3/4 front shots with a clean HDRI in Blender Cycles/Eevee, 4K, then compress. Marketing visuals are covered in `capture_and_cinematography` and `youtube_seo_thumbnails`.
