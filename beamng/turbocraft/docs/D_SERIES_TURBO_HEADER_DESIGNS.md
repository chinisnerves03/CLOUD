# D-Series 4.5 L V8 TurboCraft hot-side designs

This is an offline visual design for the Gavril D-Series 4.5 L V8 only. It
does not claim compatibility with other engines or vehicle families.

## Real hardware references (26 October 2026)

These references guide shape only. None establishes D-Series dimensions,
port coordinates, clearance, flow, or spool. No reference asset is included
in the mod. Product photographs were inspected directly in a background
browser; this is separate from the local Qwen vision check of Blender previews.

| Reference | Observed shape or documented guidance | Design implication |
| --- | --- | --- |
| [GizFab K11 log manifold](https://www.gizfab.com/products/nissan-micra-k11-log-turbo-manifold), close-up `3D_PRINTED_GT1752_3.jpg` | Short branches blend into a thick shared gallery and formed turbo outlet. | Keep log branches compact and distinguish the shared gallery from four separate tubular primaries. |
| [1320 Performance S2000 sidewinder](https://1320performance.com/products/s2000-sidewinder-t3-turbo-manifold-kit-ap1-ap2-pre-1965-vehicle-with-f20c-f22c-swap), photographs `DSC_2666...jpg` and `000000000001_852x.jpg` | Straight stubs leave a flat head flange, followed by broad bends and parallel runs into a compact collector. The maker identifies equal-length runners and a true 4-1 merge. | Follow each measured D-Series port normal before bending; join runners gradually and measure centerline lengths rather than infer equality from appearance. |
| [Speedway Motors SBC twin-turbo kit](https://www.speedwaymotors.com/SBC-Twin-Turbo-Kit-W-66mm-T4-Turbos-Headers-Hot-Cold-Pipes,569981.html), header-pair photograph `91607082_L1600_d2be1461-22da-41f1-96bf-e1d360a00a02.jpg` | Separate four-primary bank headers use broad bends, tapered collectors, and circular V-band lips. | Twin routing needs one continuous bank-to-turbine path per side and credible flange transitions. This photograph does not prove mirrored D-Series clearance. |
| [Garrett Turbo Systems 102 Advanced](https://www.garrettmotion.com/wp-content/uploads/2019/10/GAM_Turbo-Systems-102_Advanced.pdf), page 5 | Source text recommends generous bend radii, gradual area changes and shallow convergence at the collector; it distinguishes cast log and welded tubular construction. | Avoid abrupt direction/diameter steps at runner-to-collector and collector-to-turbo connections. Garrett PDF text was read; its picture pixels were unavailable in the browser/PDF tools. |

The photo observations above are qualitative. The only permitted source for
D-Series port locations and exit planes remains the copied D-Series geometry
in this workspace; intermediate routes and dimensions remain design estimates.

### User-supplied reference photographs

Fifteen supplied images are preserved for authoring under
`work/turbocraft_models_20261026/user_header_references/`. They are not shipped
as game assets. References 01–03 show a single turbo with a compact bank log
and a crossover beneath the engine front; 07 shows individually curved
primaries feeding a tapered collector; 09 guides the compact front-corner
twin layout. References 10–12 guide runner stacking only. References 13–15,
explicitly identified by the user as equal-length single turbo, guide the
separate looping primaries and gradual collector approach. Exact equality
cannot be measured from photographs; source centerline lengths are checked
numerically. The supplied images were inspected directly in the chat.
`tools/see.py` was attempted on every supplied image but the local Qwen
endpoint refused the connection (WinError 10061).

The TC-S60 center is now `(-0.47, -1.60, 0.88)` m on the right, mirrored for
the twin left unit: 150 mm inward, 200 mm forward and 100 mm higher than the
previous layout. This is a design position selected against copied D-Series
geometry, not a transferred mounting coordinate from the photographs.
Housing-only clearance to the right bank's measured bounding box is about
76 mm; the feed extends closer. The existing sampled mesh-AABB and estimated
mount/frame capsule checks remain active. No body-panel or heat-clearance
claim follows from those checks.

The user additionally supplied `reference_16_large_big.jpg` through
`reference_28_large_big.jpg` as shape references for Large/Big single and twin
turbo concepts. These show compact log/tubular branches, crossovers and
substantially larger front/side turbo housings in other V8 builds. They guide
future size-specific visual proportions only: no D-Series Large/Big mesh,
housing dimension or in-game fitment is established by those photographs.
They remain in the workspace authoring folder and are not packaged as assets.
Local Qwen inspection of these images also failed with WinError 10061; their
visible features were reviewed directly from the user's attachments.

## Selectable concepts

| Turbo layout | Header choices | Outlet-pipe choices |
| --- | --- | --- |
| Single TC-S60 | Compact log, tubular 4-1, equal-length 4-1 | Compact, swept |
| Twin 2x TC-S60 | Compact log, tubular 4-1, equal-length 4-1 | Compact, swept |

The header meshes start at the eight port boundary rings extracted from the
copied D-Series race-header COLLADA mesh (four per bank; measured radius about
24.93 mm). Single layouts merge both banks to one turbo feed; twin layouts
route each bank to its own turbo. The outlet pipes use the copied JBeam
`exm1r`/`exm1l` endpoints.

## Geometry and physics limits

Header choices reuse the node and beam tables of the corresponding existing
TurboCraft cast, tubular, or equal-length header. No additional physics nodes
or beams are introduced. Outlet-pipe and twin-turbo visual parts are
flexbody-only.

The revised single-bank crossover stays near the engine front and the TC-S60
turbine feed. Tubular primaries sweep directly to a four-way collector; the
equal-length version uses shorter separate loops with approximately 552 mm
centerlines. The collector mouth is 110 mm OD, and the 38 mm OD primaries
depart each measured port along its normal for the first 30 mm. These tube
diameters and intermediate routes are visual design choices, not measured
production specifications or a flow analysis.

The manifest records minimum vertex-to-capsule gaps for the current meshes:
about 18.1 mm across all headers, 49.7 mm for compact pipes, 55.9 mm for
swept pipes, and 112.4 mm for the twin TC-S60 visual. These are static
estimates, not proof of fitment: the capsule radius is estimated at 60 mm and
the left frame rail is mirrored from copied right-side JBeam nodes.
Body-panel, steering, deformation, heat, and in-game clearance are not
verified.

## Verification status

- Header tests pass 16/16: port extraction, JBeam physics parity, asset and
  material links, shape distinctions, and estimated frame-capsule clearance.
- Blender generated 12 paired comparison renders, six unobstructed header
  views, four detail views, and an editable scene under
  `work/turbocraft_models_20261026/dseries_v8_header_designs_r2/`.
  Saved-scene mesh coordinates and triangle faces match the exported DAE
  sources for all 12 checked nodes.
- Offline Blender BVH review found zero nonlocal self-intersecting components
  across 77 pieces and no engine/gasparts contacts outside the first runner
  rings at the measured port mounts. This does not check welded flow passages
  between separate mesh pieces or full vehicle body clearance.
- `python tools/see.py` was attempted on the final render but did not inspect
  it: the local Qwen endpoint refused the connection (WinError 10061). The
  rendered previews were opened and examined directly.
- Release compatibility and `tools/package.py --validate-only` pass; the
  latter wrote no ZIP.
- **NOT TESTED IN GAME.** Appearance, fitment, sound, exhaust flow, spool, and
  vehicle stability still require an in-game test.
