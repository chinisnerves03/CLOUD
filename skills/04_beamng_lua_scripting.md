---
name: beamng-lua-scripting
description: Lua scripting for BeamNG: game-engine Lua vs vehicle Lua, extensions, UI apps, scenarios/missions, input and AI hooks, debugging. Use for non-geometry mod features.
---

# Lua scripting in BeamNG **[verify API names against current docs; they change]**

## Two Lua contexts
- **Game-engine (GE) Lua**: global systems, UI, scenarios, level logic, spawning. Lives under `lua/ge/` (extensions in `lua/ge/extensions/`).
- **Vehicle Lua**: runs per vehicle, close to physics (controllers, electronics, powertrain). Lives under `lua/vehicle/`. Communicates with GE via queue commands (`obj:queueGameEngineLua(...)`, `be:queueAllObjectLua(...)` style calls **[verify]**).

## Extensions
- A file in `lua/ge/extensions/` exposing a table `M` with functions; load it with `extensions.load("name")` and call `extensions.name.func()`.
- Hook functions the engine calls for you: `onExtensionLoaded`, `onUpdate(dt)`, `onClientStartMission`, `onClientEndMission`, `onVehicleSpawned` **[verify list]**.
- Keep `onUpdate` cheap; avoid allocating tables every frame.

## Controllers (vehicle side)
Custom controllers (turbo logic, drift assist, launch control, hybrid, active aero) are Lua files referenced from jbeam `controller` sections. Start by reading a stock controller of similar function.

## UI
- Custom UI apps are HTML/JS (AngularJS-era apps and newer UI frameworks **[verify which the current version uses]**) under `ui/`.
- Keep apps optional and unobtrusive; telemetry/speed displays and drift scores are popular.

## Scenarios / missions / challenges
Time attacks, drift scoring, delivery, stunts. A simple playable objective inside your map or car multiplies its content value (clips, challenges).

## Debugging
- Console (`~`) shows `log()` output and Lua errors with file/line.
- `dump(table)` prints structures; `log("I","tag","message")` for leveled logs.
- Reload with the console command `Lua.reload()` / vehicle reload **[verify]**.

## Safe practice
- Never `os.execute` or touch files outside the mod; players trust mods.
- Namespace your globals; avoid overriding stock functions unless you must (breaks with updates).
- Document hooks and keybinds in the readme.
