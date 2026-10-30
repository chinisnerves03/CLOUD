---
name: release-packaging-repository
description: Packaging and publishing a BeamNG mod: zip structure, metadata, versioning, release page copy, changelog, screenshots, pre-release test, post-release support.
---

# Release & repository

## Pre-release checklist
- [ ] Zip root contains `vehicles/` / `levels/` / `mod_info/` directly (no wrapper folder)
- [ ] Tested from the **zip** on a clean profile with no other mods
- [ ] No errors/red lines in `beamng.log` at spawn and after 10 min of play
- [ ] Preview images and `info.json` complete, correct names/specs
- [ ] No third-party assets without permission; credits file included
- [ ] File size sensible (compress textures; remove unused files)
- [ ] Version number set and CHANGELOG updated

## Versioning
`MAJOR.MINOR.PATCH` (e.g. 1.0.0 → 1.0.1 hotfix → 1.1.0 new config). Put the version in the zip name, in `info.json`, and in the release page title for each update.

## Release page copy (structure)
1. One-line hook: *what it is + why it's fun* ("1994 Japanese touge hero with 5 configs, tuned for drifting").
2. 3–6 best screenshots/GIF first; a trailer video link right under.
3. Feature bullets (configs, parts, sounds, special systems).
4. Requirements: game version, DLC needed, other mods needed, PC spec.
5. Install steps (usually "subscribe in-game" or "drop the zip in mods").
6. Known issues (honesty builds trust).
7. Changelog.
8. Credits & licence.
9. Links: Discord, video channel, support/donation (see legal skill).

## Where to publish **[verify current rules]**
- Official BeamNG Resources/Repository (best discoverability; follow its content and naming rules).
- Mirror pages for downloads outside the game (a personal page, GitHub Releases, etc.), but keep one canonical page so updates and comments stay in one place.

## Launch-day mechanics
- Upload page + trailer + screenshots; post the trailer; reply to every comment in the first 48 h.
- Plan a patch within 7–14 days: bugs found by many players are free marketing when fixed visibly ("v1.0.1 — fixed X you reported").

## Support
- Pin a "known issues + how to report" post. Require game version, mod version, log file, steps to reproduce.
- Triage: crash > mod doesn't load > physics oddities > cosmetic.
