---
name: beamng-map-levels
description: Building BeamNG maps/levels: world editor workflow, terrain, roads, forest and objects, materials, spawn points, navgraph for AI, performance, and what makes a map popular.
---

# Map (level) modding

## Workflow **[verify exact editor menus per version]**
1. Start from the in-game **World Editor** (F11) on an empty or small stock level; save as your own level folder under `levels/<name>/`.
2. **Terrain**: import a heightmap (real-world DEM data or hand-painted greyscale), set terrain size and height scale; check heightmap licensing before using real data.
3. **Materials/painting**: define terrain materials (rock, grass, asphalt edge, dirt) with tiling textures; blend with the paint tool.
4. **Roads**: use the road/decal road tools for asphalt with lane markings; spline-based roads give smooth physics and AI paths. Keep road width and banking realistic.
5. **Objects and vegetation**: place buildings, barriers, signs; use the Forest tool for trees/grass (instanced, cheap) instead of thousands of separate objects.
6. **Spawn points, camera spots, mission/scenario hooks**: provide several spawn points in interesting places.
7. **AI/Navgraph**: build the navgraph so traffic and AI cars can drive.
8. **Lighting/sky**: set time-of-day, fog, sun; test day and night.
9. **Performance pass**: LODs, distance culling, terrain resolution, texture sizes, collision meshes simplified.

## Map concepts that attract downloads
- A *place with a reason to drive*: mountain pass, touge, rally stage, drift park, offroad playground, city with jumps.
- Fast loops: players want to start driving in seconds, and loop without a dead end.
- Landmarks + variety of surface: asphalt, gravel, dirt, curbs, jumps.
- A recognisable name/theme so a thumbnail tells the story.

## Quality checklist
- No holes/floating props, no invisible walls, no sky-high terrain spikes.
- Collision on everything you can hit; nothing "ghost".
- Stable FPS on mid-range PC (publish minimum spec in the description).
- Preview image + short description + an overhead map image.
- Include credits for any third-party assets and confirm their licence allows redistribution.
