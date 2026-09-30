# Thai Tea Tycoon — notes for Claude

Roblox tycoon game written in Luau. The owner (CHIN) talks in Thai: answer in Thai. In-game text, code and
comments are English; `README.md` is Thai (setup guide for the owner). Push to `main` of `chinisnerves03/cloud`.
Never put a model name in commits, PRs or code.

## Where things are

| Path | What |
|---|---|
| `src/ReplicatedStorage/Config.lua` | every tunable: economy curve, upgrades, passes/products (IDs still 0), sounds + music playlist, offline rules |
| `src/ServerScriptService/Main.server.lua` | entry point: lighting, RemoteEvent `TycoonNotify`, builds `ReplicatedStorage.CustomerTemplates`, wires services |
| `Services/DataService.lua` | DataStore load/save (UpdateAsync) with a session lock (`SessionLock`: wait 30 s then take over; stop saving + kick when another server took it), reconcile of old saves |
| `Services/PlotService.lua` | plot claim, spawn in front of your own plot, money loop (counter sales + staff + VIP pass), brewing (prompt on `BrewPad`, server checks the player stands on it), buy pad, upgrade pads, Auto Build pass, offline earnings, plot `Owned` attribute |
| `Services/MonetizationService.lua` | Game Passes (as player attributes `Pass_*`) + Developer Products (idempotent receipts) |
| `Services/RetentionService.lua` | rebirth (via `PlotService.Rebirth`), daily reward, codes, quests (hooked through `PlotService.OnProgress`), leaderstats; RemoteEvent `TycoonAction` |
| `Services/LeaderboardService.lua` | plaza boards from `Config.LEADERBOARDS`, OrderedDataStore upload + top 10 every `LEADERBOARD_REFRESH` s |
| `Services/NpcService.lua` | turns `NpcSpot` markers (Builder:Person when `ItemModels.UseRigs`) into recoloured R15 rigs with Roblox-made hair, apron, hat and posed arms; anchored root, clients play idle/walk |
| `Services/DevPlotBuilder.lua` | builds 6 plots + plaza when `Workspace.Plots` is missing |
| `Services/ItemModels.lua` | every model built from Parts (Builder DSL), item layout, pad spots, decor (BrewStation, StaffCart, Customer, PlotGround, …) |
| `ReplicatedFirst/TitleScreen.client.lua` | custom loading screen + title menu (PLAY, HOW TO PLAY) over a camera flight; hides other LayerCollectors/CoreGui and sets the local `InMenu` attribute until PLAY |
| `ReplicatedStorage/UIStyle.lua` | shared look: Fredoka One, `styleButton` (neutral gradient multiplies BackgroundColor3, outline, hover UIScale, click honoring `SfxMuted`), `panel`, `button` |
| `StarterPlayerScripts/ClientMain.client.lua` | HUD, hints + guide arrow, toasts, staff "+฿" pops, client-side customer queue animation |
| `StarterPlayerScripts/RetentionClient.client.lua` | DAILY / Codes buttons, quest panel, REBIRTH button + confirm (reads `DailyAt`, `Quest*`, `Rebirths`) |
| `StarterPlayerScripts/EffectsClient.client.lua` | local effects: steam on parts named `Steam` (hides `SteamPuff`), sliding `BeltCup` parts on L31, neon flicker on L28/L37, pop-in (Model:ScaleTo) + sparkles for the newest item on your plot |
| `StarterPlayerScripts/MotionClient.client.lua` | animates `Anim` groups (Builder:Group Spin/Bob/Sway), `Beacon` pulse, fountain `Spout` spray, NPC head glances and Busy arm motion (Motor6D C0) |
| `StarterPlayerScripts/SprintClient.client.lua` | Shift / RUN touch button sprint (16 → 28), FOV kick, run dust; idle while `InMenu` |
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
- Real-world scale: character 5.5 studs ≈ 1.75 m. Small props are built life-size; tier 4-5 buildings are enlarged
  after building (`ItemModels.Footprint`: Shell parts and parts spanning half the building grow in X/Z, other
  parts move as clusters of touching parts and keep their size; `ItemModels.Uniform`: whole-model ScaleTo).
  Walk-in buildings also have 13-14 stud walls (L29/L34/L39/L40/L42/L43) with a decorative `Builder:UpperWindows`
  row; interiors, lamps and people stay at human height. `ItemModels.Uniform` also enlarges the umbrella L07, neon
  wall L28 and billboard L37; `ItemModels.DecorUniform` enlarges arch, lamps, trees and fountains.
  EffectsClient pop-in scales back to the model's own `GetScale()`, never to 1.
- Plot space: 120 wide, z -65 (front) .. 140 (back); Base centred at `ItemModels.PlotCenterZ`, PlotService reads
  the offset from the Base attribute `ItemOriginZ`. Plot centers are 130 apart.
- Part budget: ≈ 5,100 parts per full plot, ≈ 31,000 for the map. StreamingEnabled recommended.

## Conventions

- After moving/enlarging items, recompute tier 4-5 `PadSpots` in Studio (closest free 6x6 spot behind each item,
  1 stud clear of earlier items) and check overlaps with bounding boxes.
- Rojo can leave stale duplicate scripts in the saved place (it keeps unknown instances): after reconnecting, check
  for duplicate LuaSourceContainers by name and delete the ones whose Source differs from the files, then save.
- Emoji in UI: 🧋 and ✕ do not render in Roblox fonts; 🥤 🛒 🎁 ⚙️ 🔑 🏠 ❓ do.
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

## Handoff — state on 2026-09-30 (read this first in a new chat)

Everything is pushed to `main`. The game runs in Studio with no red errors on server or client. The owner's own
save is around Level 33: play-test scripts must back up and restore `PlotService.GetData(player)` (they share the
owner's DataStore key) and never leave test values saved.

Done so far (newest first):
- Interior upgrades: purple `InteriorPad` in the 8 walk-in buildings, 3 levels (Decor / More staff / Premium),
  +5% income each (`Config.INTERIOR`, `Interiors` save field, PlotService applyInterior/tryInterior, ItemModels
  `furnishInterior`, which runs after the footprint stretch and fills free 2-stud grid cells).
- Customers walk like people: own pace, smooth accel/decel and turning, walk cycle speed = speed / 8.
- Sprint (SprintClient: Shift / RUN touch button, 28 studs/s, FOV 80, dust); customer cheer/laugh/point; barista
  serve reach; NPC head-look + wave; player brew arm swing + kettle splash; tree canopies lean.
- Title screen (ReplicatedFirst/TitleScreen), UIStyle, Settings (music / sfx), Home button.
- Every person is an R15 rig (NpcService, Roblox catalog hair); MotionClient animates Anim groups and NPCs.
- Life-size buildings (Footprint stretch); HQ ~31 m and Thai Tea Tower ~34 m with real storeys.
- Session-locked saves (DataService); spawn in front of your plot facing in (the camera follows).
- Shop UI, sounds/music, rebirth, daily, codes, quests, leaderboards, effects (earlier).

## To do (priority order)

1. **Owner's newest request (not started): make all models more three-dimensional, and make the small shops
   (tier 1-3: cart, street shop, cafe) more realistic in size.** Measure first (character 5.5 studs = 1.75 m,
   1 stud ≈ 0.32 m). Build each key at `CFrame.new()` and take min/max of part bounds; do not trust
   `GetBoundingBox`, which follows the primary part's rotation. Ideas: give flat boxes depth (bevels, trims,
   recessed panels, overhangs, window frames, thicker awnings), vary heights, and check tier 1-3 sizes against real
   furniture (counter ~1 m, table 0.75 m, cart ~1.8 m long). Keep the part budget (~30k map) in mind, recompute
   tier 1-3 `PadSpots` if footprints change, and keep pads on free floor.
2. **Creator Dashboard (the owner does it on the web)**: Max Players = 6 (Places → Configure Place); create the 4
   passes + 2 products and send the IDs → put them in `Config.PASSES` / `Config.PRODUCTS`, then test a purchase.
3. **Icon + thumbnail** for the game page (a title-screen capture works as a thumbnail).
4. Multiplayer test in Studio (Test → Clients and Servers, 2 players): separate plots, leaving frees the plot.
5. Mobile check with the Device Emulator (the left column is raised 70 px on touch; RUN button position).
6. Ideas: world 2, pets/mascot, seasonal events, pedestrians wandering the plaza.

## Working on the owner's PC (Windows, Studio + Rojo + Studio MCP)

- Repo: `C:/Users/User/Documents/cloud` (branch main; origin's default branch is a claude/* branch). Always
  `git pull --ff-only` first: another (cloud) session also pushes to main.
- Tools in `C:/Users/User/tools/bin` (rojo 7.7.0, luau, luau-compile, rbx-studio-mcp.exe). Compile-check every
  edited file with `luau-compile.exe --text <file>`.
- `rojo serve` (port 34872) runs as a detached minimized process. Restart it after editing `default.project.json`
  and reconnect in Studio (Rojo toast → Connect). Read Rojo's confirm dialog before Accept.
- Rojo keeps unknown instances, so stale duplicate scripts can appear in the saved place after reconnecting:
  list LuaSourceContainers by name, delete the ones whose Source differs from the files, then Ctrl+S.
- Studio MCP tools (`run_code`, `run_script_in_play_mode`, `start_stop_play`) work; run_code runs in the edit
  DataModel. Client-side checks: during play, type Lua into Studio's command bar that writes results into a
  ScreenGui label, then capture the Studio window with `C:/Users/User/tools/studio-mcp/shot.ps1` (PrintWindow;
  works even when other windows cover Studio; the screen is 4K at 300%, click frame = physical px × 0.3792).
  In edit mode, select a model (Selection:Set) and press F in the viewport to move the camera.
- The owner also has an unrelated car project in Studio's experience list: never open, connect or edit it.
- Emoji that render in Roblox fonts: 🥤 🛒 🎁 ⚙️ 🔑 🏠 ❓. 🧋 and ✕ do not.
- Python heredocs turned Lua `\n` escapes into real newlines several times: re-check with luau-compile.
