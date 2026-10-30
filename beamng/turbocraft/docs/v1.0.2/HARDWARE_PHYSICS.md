# Header engineering and original hardware prototype

2026-10-25. **OFFLINE ENGINEERING FOUNDATION, NOT A NEW IN-GAME PHYSICS MODEL.**
No runtime header, turbo, BOV, afterfire, gauge, saved ID or default was changed
by this work. No new ZIP or installation was made for these engineering tools.

## What the current game model actually does

The wrapper delegates shaft motion, wastegate, damage and valve events to the
native BeamNG turbocharger. Its engine-power proxy and normalized-RPM header
curves remain calibrated approximations, not measured mass flow or a compressor
map. The native `maxExhaustPower` parameter must not be interpreted as measured
turbine watts.

Header choices already differ, but the old isolated-curve test is not proof
that a complete Cast assembly always spools earlier. At 25% of redline, the
current header energy factors including the static multipliers are:

- Cast: `0.94 * 1.04 = 0.9776`.
- Equal-length: `1.12 * 0.97 = 1.0864`.

Those products precede efficiency, exhaust, engine friction and wastegate
effects; they are not boost or spool measurements. No coefficient was changed
merely to force a desired ranking. Equal length alone does not specify volume,
flow area, thermal behavior or useful pulse grouping.

## Dimensioned model

`tools/header_physics.py` evaluates identical parallel runners followed by one
collector. Caller-supplied inputs use SI units:

| Input | Unit / meaning |
| --- | --- |
| Runner and collector length, inside diameter, wall roughness | metres |
| Wall temperature | Kelvin, prescribed boundary condition |
| Heat-transfer coefficient | W/(m2 K), supplied, not inferred from a material label |
| Minor-loss coefficient | dimensionless; collector value must include merge losses |
| Gas constant, specific heat, dynamic viscosity | J/(kg K), J/(kg K), Pa s |
| Total exhaust mass flow | kg/s, divided among runners before the collector |
| Inlet pressure / gas temperature | absolute Pa / Kelvin |
| Runner count | positive integer; not a firing-order model |

Relations are Darcy-Weisbach plus minor losses, `64/Re` for laminar flow and
the Haaland turbulent approximation; Newton cooling integrated along each
constant-wall-temperature duct; ideal-gas density and sound speed.
The mean gas temperature is integrated analytically, with a stable adiabatic
limit. Collector inlet conditions come from the runner outlet, not the engine
inlet. Total heat loss sums all runners and the collector.

Outputs include pressure loss, outlet temperature, heat loss, Reynolds number,
friction factor, maximum endpoint Mach number, internal volume, nominal gas
residence time, and downstream acoustic transit time. **Neither time is turbo
lag.** The model deliberately has no `spool_time_s` output.

Unsupported inputs raise explicit errors: zero/invalid flow, invalid dimensions,
transitional Reynolds numbers (2300-4000), Mach at least 0.3, or a pressure loss
of at least 10% in a section. This limited, low-Mach mean-flow calculation is
not suitable for silently replacing compressible exhaust blowdown dynamics.

## Reproducible synthetic example

These are **test dimensions, not measurements of the game's Cast/Tubular/Equal-
Length parts**. Four identical runners: 35 mm bore, 0.045 mm roughness, minor-loss
coefficient 0.4. Collector: 120 mm long, 65 mm bore, same roughness, minor-loss
coefficient 0.6. Both have 650 K walls and heat-transfer coefficient 75 W/(m2 K).
Boundary conditions: 0.10 kg/s total, 200,000 Pa absolute, 1000 K.
Constant gas properties: R=287 J/(kg K), cp=1100 J/(kg K), viscosity=0.00004 Pa s.

| Runner length | Total pressure loss | Collector outlet | Total heat loss | Internal volume |
| --- | --- | --- | --- | --- |
| 350 mm | 724.813 Pa | 959.906 K | 4410.380 W | 1.745155 L |
| 700 mm | 835.362 Pa | 929.027 K | 7806.983 W | 3.092113 L |

Only length changes in this comparison. Separate tests show that a larger
bore can reduce pressure loss while increasing volume/residence, so there is
no universal "bigger" or "equal-length" spool bonus. No dyno or spool conclusion
can be derived from this table alone.

Run from the workspace root:

```powershell
python TurboCraft_v0.7.0_source\tests\header_physics_test.py
```

Nine tests cover independent Darcy/Poiseuille references, heat conservation,
collector continuity, geometry/roughness/flow/parallel-runner effects, time
diagnostics, hot-wall and adiabatic limits, and explicit unsupported cases.

## What is still required for runtime use

Actual per-part internal dimensions, material/wall thermal data and verified
exhaust mass-flow/temperature/pressure signals are not established. Firing order,
runner routing and divided turbine pairing are required before claiming useful
twin-scroll pulse separation. Unsteady wave reflection, valve timing, wall
thermal inertia and choking are not solved here. Rotating inertia, turbine and
compressor maps, compressor load and bearing losses are also needed to predict
shaft response rather than invent a delay.

Keep the current runtime calibration until a bounded integration and a
same-engine/same-gear/same-boost header comparison are validated. Do not assign
these synthetic dimensions to every engine, relabel old graphs as physical
measurements, or apply a second loss factor to an already calibrated curve
without checking double counting.

Background references: [BorgWarner twin-scroll explanation](https://www.borgwarner.com/aftermarket/thermal-management/news/2021/04/12/tech-tip-twin-scroll-turbo-housing)
describes firing-order/pulse separation, not an equal-length guarantee;
[MIT engine heat-transfer lecture](https://ocw.mit.edu/courses/2-61-internal-combustion-engines-spring-2017/df96f507776900c0dde50a4b50f422ce_MIT2_61S17_lec18.pdf)
is background reading, not validation of the constant-property inputs above.

## Original TC-S60 visual prototype

`tools/build_turbo_mesh.py` creates original OBJ/MTL/Collada geometry with no donor
assets. Corrected output is under
`work\turbocraft_models_20261025\tc_s60_r2` at workspace level; the earlier
`tc_s60` export remains preserved. Both contain 12 objects / 16,944 triangles,
metre scale, Z up, Y shaft axis and a 60 mm inlet opening.

The r2 correction reverses the blade end-cap winding: the first version had 96
inconsistent directed edges in the compressor wheel. Tests now require closed
two-face edges, opposing adjacent edge directions and positive signed volume,
in addition to dimensions, normals and OBJ/DAE export checks. The corrected
three-view preview was rendered from the actual exported OBJ and inspected
directly. The prescribed local vision attempt failed with connection refused;
no local visual-model endorsement is claimed.

This is not production CAD or a validated flow geometry. It has no engine-bay
mounting, clearance proof, JBeam, UV textures, LOD or all-engine fitment. The first
fitment target remains D-Series 4.5 V8; it is **NOT FITTED / NOT TESTED IN GAME**.
