---
name: beamng-vehicle-jbeam
description: Building and tuning BeamNG vehicles: soft-body nodes/beams, jbeam part structure, slots, powertrain, suspension, collision, configs, and how to test handling and crash behaviour.
---

# Vehicle modding (jbeam)

## Concept
BeamNG vehicles are a soft-body physics skeleton (**nodes** joined by **beams**) plus a visual mesh bound to it. Quality = how well the skeleton behaves, not how pretty the mesh is.

## Part system
- A vehicle is many **parts** (`.jbeam` files), each declaring a `slotType`; parts plug into **slots** of other parts (body → doors, engine → turbo, etc.).
- A **config** (`.pc`) picks parts and tuning values; ship several configs (stock, sport, drift, offroad) — they become the list players browse.
- Use `refNodes`, node groups, and `flexbodies` (visual mesh groups bound to node groups) as in stock cars; copy their structure.

## Skeleton rules of thumb **[verify values by comparing with stock cars]**
- Node spacing roughly 10–25 cm on bodywork; closer nodes need stiffer/shorter timestep behaviour and can jitter.
- Triangulate: every panel needs diagonal beams, or it collapses like a box with no braces.
- Use `beamSpring`, `beamDamp`, `beamDeform`, `beamStrength` per section: soft for crumple zones, strong for the cabin.
- Add `collision triangles` for body so it interacts with the world and other cars.
- Mass: give real total mass; distribute per node via `nodeWeight`. Wrong mass is the most common cause of "feels like a toy".

## Powertrain & chassis
- Engine torque curve → gearbox ratios → differential(s) → wheels; check the stock vehicle with the closest layout (FR, FF, 4WD) and edit its numbers.
- Suspension: choose a stock type close to the real car, then tune spring rate, damper, anti-roll, ride height, camber.
- Tyres/wheels: set radius/width, friction, and brake torque to match car class.
- Provide `info.json` per config with brand, name, years, body style, power/torque, price, country, and a **preview image** — these drive filters and the first impression.

## Test checklist
1. Spawn on flat ground: does it sit level, doors open, no jitter after 30 s?
2. Slow drive, full lock turn, brake test.
3. Crash tests at 30/60/100 km/h: front, side, rear, roof, rollover — look for beams stretching like rubber (too weak) or nothing deforming (too strong).
4. Jump/landing test, curb hit, water.
5. Different weather/surfaces; AI driving (`AI mode`) for a few km.
6. Frame-rate check with several copies spawned; high node/beam counts hurt FPS.

## Quality bar that gets features and downloads
- Plausible handling and crashes over perfect looks.
- Clean interior, working lights, wipers, horn, signals, gauges.
- Proper preview renders and an honest spec table.
- Multiple configs including a fun one (drift/rally/race) — most viral clips come from these.
