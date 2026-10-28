---
name: beamng-modding-fundamentals
description: Core workflow for BeamNG.drive mods: user folder, mod folder layout, unpacked vs zipped testing, console, logs, common failure causes. Use before any vehicle, map, or script work.
---

# BeamNG modding fundamentals

## Where things live **[verify paths for your game version]**
- User folder (Windows): `%LocalAppData%\BeamNG\BeamNG.drive\<version>\` (older: `Documents\BeamNG.drive\`).
- Unpacked mods for testing: `<user folder>\mods\unpacked\<modname>\` — files here load without zipping.
- Zipped mods: `<user folder>\mods\<modname>.zip`.
- Logs: `<user folder>\beamng.log` (and `beamng.previous.log`). Read it first on every crash or missing asset.
- Game content for reference: the install folder `content\` (zips) — extract a stock car/map to study how the game's own files are laid out.

## Mod folder layout (zip root = game root)
```
vehicles/<modname>/        jbeam, dae, materials.json, info.json, preview images
levels/<mapname>/          level data, terrain, materials, info.json
art/ , lua/ , ui/          shared assets, scripts, UI apps
mod_info/<modid>/info.json repository metadata (title, tag line, version)
```
The zip must NOT have an extra top folder: opening it must show `vehicles/`, `levels/`, etc. at the top. Most "mod doesn't show up" reports are this mistake.

## Fast test loop
1. Work in `mods/unpacked/<modname>/`.
2. Edit jbeam / lua / json → in game reload the vehicle (`Ctrl+R` reloads the vehicle **[verify]**) instead of restarting.
3. Open the in-game console (`~` **[verify]**) and watch for red errors.
4. Edit models/textures → reload content or restart; keep texture sizes sane while iterating.
5. Before release: zip, delete the unpacked copy, test the zip on its own.

## Typical failures
| Symptom | Likely cause |
|---------|-------------|
| Mod missing in menu | extra top folder in zip, bad `info.json`, JSON syntax error |
| White/pink textures | wrong path in `materials.json`, wrong extension, missing file |
| Car explodes on spawn | node/beam mistakes, nodes too close, wrong weights, missing group |
| JSON error | trailing comma is OK in jbeam, but missing comma / quote is not; use a JSON-aware editor |
| Works for you only | absolute paths, or dependency on a file in your unpacked folder |

## Habits that save days
- Version-control the mod folder with git; commit before every big change.
- Copy a stock vehicle/map as a base and change one thing at a time.
- Keep a `TODO.md` and a `CHANGELOG.md` from day one (feeds the release page).
- Test on low settings and on a clean profile (no other mods) before claiming "works".
- Read the official modding docs and the BeamNG forum modding subforum; the community knowledge there beats memory **[verify]**.
