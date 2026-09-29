# Thai Tea Tycoon — notes for Claude

Roblox tycoon game written in Luau. The owner (CHIN) talks in Thai: answer in Thai. In-game text, code and
comments are English; `README.md` is Thai (setup guide for the owner). Push to `main` of `chinisnerves03/cloud`.
Never put a model name in commits, PRs or code.

## Where things are

| Path | What |
|---|---|
| `src/ReplicatedStorage/Config.lua` | every tunable: economy curve, upgrades, passes/products (IDs still 0), sounds + music playlist, offline rules |
| `src/ServerScriptService/Main.server.lua` | entry point: lighting, RemoteEvent `TycoonNotify`, builds `ReplicatedStorage.CustomerTemplates`, wires services |
| `Services/DataService.lua` | DataStore load/save (UpdateAsync), reconcile of old saves |
| `Services/PlotService.lua` | plot claim, money loop (counter sales + staff + VIP pass), brewing (prompt on `BrewPad`, server checks the player stands on it), buy pad, upgrade pads, Auto Build pass, offline earnings, plot `Owned` attribute |
| `Services/MonetizationService.lua` | Game Passes (as player attributes `Pass_*`) + Developer Products (idempotent receipts) |
| `Services/RetentionService.lua` | rebirth (via `PlotService.Rebirth`), daily reward, codes, quests (hooked through `PlotService.OnProgress`), leaderstats; RemoteEvent `TycoonAction` |
| `Services/LeaderboardService.lua` | plaza boards from `Config.LEADERBOARDS`, OrderedDataStore upload + top 10 every `LEADERBOARD_REFRESH` s |
| `Services/DevPlotBuilder.lua` | builds 6 plots + plaza when `Workspace.Plots` is missing |
| `Services/ItemModels.lua` | every model built from Parts (Builder DSL), item layout, pad spots, decor (BrewStation, StaffCart, Customer, PlotGround, …) |
| `StarterPlayerScripts/ClientMain.client.lua` | HUD, hints + guide arrow, toasts, staff "+฿" pops, client-side customer queue animation |
| `StarterPlayerScripts/RetentionClient.client.lua` | DAILY / Codes buttons, quest panel, REBIRTH button + confirm (reads `DailyAt`, `Quest*`, `Rebirths`) |
| `StarterPlayerScripts/ShopClient.client.lua` | SHOP button + window: pass/product cards from `Config.PASS_ORDER`/`PRODUCT_ORDER`, prices via GetProductInfo, "Owned" from `Pass_*` attributes |
| `default.project.json` | Rojo project (syncs `src/` into Studio, leaves other instances alone) |
| `tools/preview/` | runs the builders against a Roblox API mock (`mock.luau`) → `parts.jsonl` → three.js render (`render.html`, `shoot.mjs`) |
| `tools/web-demo/` | `build.py` turns `parts.jsonl` into a playable browser demo (`template.html` mirrors the game rules) |
| `preview/*.png` | renders referenced by the README |

## Game rules (keep Roblox code, web demo and README in sync)

- The shop sells by itself from the start: counter sales = 25% of the base income curve per second × recipe × speed × 2x pass.
- Brewing by hand (behind the Brew Station counter, on the orange `BrewPad`) adds a cup per 0.35 s ÷ speed.
- Upgrades on 3 pads: Hire Staff (max 6), Better Recipe (+10%/level), Faster Service (+8%/level).
- One green buy pad moves to `ItemModels.PadSpots[next item]` (behind each item). Auto Build pass buys automatically.
- Customers (client-only clones) queue in front of each owned plot's Brew Station; served every 2.5 s or on each brew.
- Rebirth at level 45: reset level/cash/upgrades for +50% income per rebirth (multiplies cup value, counter sales,
  staff, offline and Cash Boost size). Rewards (daily, codes, quests) are base income × seconds, with a floor.
- The Roblox player list shows leaderstats (Level, Rebirths), so the HUD cash panel sits mid-right, not top-right.
- Pacing target (simulated): ~40 min to finish when brewing, ~70 min without. First item ≈ 30 s.
- Part budget: ≈ 4,950 parts per full plot, ≈ 30,000 for the map. StreamingEnabled recommended.

## Conventions

- Builder DSL in `ItemModels.lua`: `Box/Cyl/HCyl/Ball/Ellipsoid/Wedge/Rod/Tube/Text/Light` plus `Person`, `TeaCup`,
  `Plant`, `Legs`, `Shell`, `Shelf`. Models face -Z (toward the plaza), y = 0 is the floor. Wedges: tall edge +Z.
  Boxes ≥ 1.2 wide get rounded corners automatically; pass `{ flat = true }` for a sharp box.
- After model changes, check pads still sit on free floor and nothing overlaps text (render it).
- `Config.lua` is `--!strict`.

## Local setup (Windows PC with Roblox Studio)

1. Clone: `git clone https://github.com/chinisnerves03/cloud` and work in `roblox/thai-tea-tycoon`.
2. Rojo: install the CLI (https://rojo.space, or `aftman`/`rokit add rojo-rbx/rojo`) and the Rojo Studio plugin;
   run `rojo serve` in this folder, then Plugins → Rojo → Connect in Studio.
3. Studio settings: Game Settings → Security → Enable Studio Access to API Services (click in Studio);
   Max Players 6 now lives on the Creator Hub (Places → Configure Place); Workspace.StreamingEnabled is set by the
   Rojo project; Lighting uses LightingStyle = Realistic + PrioritizeLightingQuality (Technology is deprecated and
   cannot be read or written from the MCP run_code context).
4. To let Claude drive Studio (run the game, read Output), install Roblox's Studio MCP server
   (https://github.com/Roblox/studio-rust-mcp-server) and add it to Claude Code. Check its README for current steps.
5. Preview tools need a `luau` binary (https://github.com/luau-lang/luau/releases): `LUAU=path/to/luau tools/preview/build.sh`.

## To do (priority order)

1. ~~First real run in Studio~~ — done 2026-09-29: README checklist passes, no red errors. Test by driving Studio
   MCP `run_script_in_play_mode` (server-side script that teleports the character onto pads and logs attributes);
   press E through the real client for brewing (the prompt only triggers on a key held ~0.15 s).
2. ~~In-game shop UI~~ — done (`ShopClient`). Cards say "Coming soon" until the IDs are set.
3. ~~Sounds~~ — done: `Config.SOUNDS` (Roblox / ProSoundEffects / APM only, verified to load), shuffled `Config.MUSIC`,
   Music ON/OFF button. Find more with the toolbox API (`apis.roblox.com/toolbox-service/v1/marketplace/3?keyword=`)
   and keep to creators Roblox, ProSoundEffects or APMOfficial.
4. **Creator Dashboard**: create the passes/products, put their IDs in `Config.PASSES` / `Config.PRODUCTS`.
5. **Icon + thumbnail** for the game page.
6. ~~Retention~~ — done: rebirth, daily reward, codes, quests, plaza leaderboards. Next ideas: world 2, pet/mascot.
   Play-test scripts must back up and restore the owner's save (they share the owner's DataStore key).
7. **Polish**: steam/particles, moving conveyor, neon flicker, pop-in when an item is bought, seasonal events.
