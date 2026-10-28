---
name: ai-workflow-with-claude
description: Using Claude (and similar AI) to speed up mod development and promotion: scripts, captions, SEO, analytics review, code/jbeam review, content calendars, and the limits to respect.
---

# AI workflow

## Good uses
| Task | Prompt pattern |
|------|----------------|
| Release page copy | "Write a release page for this mod. Facts: <specs>. Tone: honest, enthusiastic. Sections: hook, features, requirements, install, known issues." |
| Video scripts | "30-second trailer script, 5 shots, with on-screen text and VO lines, for <mod> targeting <segment>." |
| Titles/thumbnails | "Give 10 titles ≤ 60 chars, 3 styles, no clickbait lies; propose thumbnail text ≤ 4 words." |
| Captions | "Platform-specific captions for IG/TikTok/FB/YouTube from this script; Thai + English." |
| jbeam/Lua review | Paste the file + the error from `beamng.log`; ask for likely causes. Verify fixes in game. |
| Analytics reading | Paste your sheet; ask for patterns and one experiment per week. |
| Content calendar | "Plan 30 days of posts around the launch of <mod> with these assets." |
| Community replies | Draft polite canned replies to common issues. |
| Refactoring | Ask for a checklist of jbeam properties to compare against a stock vehicle. |

## Rules of thumb
- Give facts and constraints; AI invents specifics if you don't (spec numbers, API names, rules).
- **Verify anything game-specific in the game or official docs.** Treat generated jbeam keys and Lua functions as suggestions to test.
- Keep a prompt file with your brand voice and mod facts and paste it at the start.
- Ask for options, then choose; you own the taste.
- Do not publish AI output blindly: check facts, tone, platform policies, and disclose AI voices/images where required.
- Don't paste secrets, tokens, or private data.

## Automations (optional)
Scripts that resize/convert footage with ffmpeg, make SRT subtitles, batch-render vertical versions, rename files, or build the release zip (a small Python/PowerShell script). Keep them in the repo.

## Cost awareness
Credits and tokens cost money. Draft once, edit manually, regenerate only when needed.
