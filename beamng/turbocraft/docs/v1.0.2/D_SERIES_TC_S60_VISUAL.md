# D-Series TC-S60 visual hardware

The original TurboCraft TC-S60 visual assembly is packaged only for the Gavril
D-Series 4.5 L V8. It is selectable as a child part of the matching
`Single Turbo > TC-S60 · 60 mm` kit; other turbo sizes and induction families
do not expose this visual part. The assembly is a flexbody bound to the
D-Series 4.5 V8's existing `pickup_engine` deform group. It adds no physical
nodes or beams.

The turbo and bay reference geometry came from the installed D-Series 4.5 V8
game data and a Blender fitting scene is saved in the workspace work area.
Clearance checks use the extracted mesh bounds and real engine, exhaust,
frame and firewall node coordinates. Capsule radii and the 11 mm header-feed
gap remain explicitly estimated; hood, fender and body-panel clearance is not
covered by the available reference data. Do not treat these offline checks as
proof of in-game fitment, deformation behavior, or appearance.

**NOT TESTED IN GAME.** Verify the selected TC-S60 appears in the engine bay
and check clearance around the hood, fenders, radiator and headers in-game.
