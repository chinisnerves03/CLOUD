#!/usr/bin/env python3
"""Check Plot1 in parts.jsonl (run build.sh first): every buy pad spot (6x6) must sit on free floor, i.e. clear of the
floor-level parts of every earlier item and of the fixed props (Brew Station, staff carts, upgrade pads); also lists
items whose floor footprints overlap each other. Floor-level = the part's bottom is below 1.5 studs above the floor.
usage: python3 check_pads.py [margin]"""
import json, re, sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "../../src/ServerScriptService/Services/ItemModels.lua")
MARGIN = float(sys.argv[1]) if len(sys.argv) > 1 else 0.5
ORIGIN = (-130.0, 1.0, 85.0)  # Plot1 floor centre in world space (plot space x, z = world - origin)

lua = open(SRC).read()
block = re.search(r"ItemModels\.PadSpots = \{(.*?)\n\}", lua, re.S).group(1)
pads = {k: (float(x), float(z)) for k, x, z in re.findall(r"(L\d\d) = \{ (-?[\d.]+), (-?[\d.]+) \}", block)}

rects = {}  # item -> list of (x0, x1, z0, z1) in plot space
FIXED = ("BrewStation", "VipBarista", "UpgradeFrame", "RegisterBooth")
for line in open(os.path.join(HERE, "parts.jsonl")):
    if not line.startswith("{"):
        continue
    p = json.loads(line)
    item = p["item"]
    if not (re.match(r"L\d\d$", item) or item.startswith("Staff") or item in FIXED):
        continue
    if p["t"] >= 1:
        continue
    sx, sy, sz = (v / 2 for v in p["size"])
    r = p["rot"]
    cx, cy, cz = p["pos"]
    hx = abs(r[0]) * sx + abs(r[1]) * sy + abs(r[2]) * sz
    hy = abs(r[3]) * sx + abs(r[4]) * sy + abs(r[5]) * sz
    hz = abs(r[6]) * sx + abs(r[7]) * sy + abs(r[8]) * sz
    if cy - hy - ORIGIN[1] > 1.5:
        continue
    x, z = cx - ORIGIN[0], cz - ORIGIN[2]
    rects.setdefault(item, []).append((x - hx, x + hx, z - hz, z + hz))

def hit(a, b, m=0.0):
    return a[0] - m < b[1] and b[0] - m < a[1] and a[2] - m < b[3] and b[2] - m < a[3]

bad = 0
keys = sorted(pads)
for i, key in enumerate(keys):
    px, pz = pads[key]
    pad = (px - 3, px + 3, pz - 3, pz + 3)
    blockers = [k for k in keys[:i] if k in rects] + [k for k in rects if not k.startswith("L")]
    for other in blockers:
        if any(hit(pad, r, MARGIN) for r in rects[other]):
            print(f"PAD {key} at {pads[key]} overlaps {other}")
            bad += 1
items = sorted(rects)
for i, a in enumerate(items):
    for b in items[i + 1:]:
        if any(hit(r1, r2) for r1 in rects[a] for r2 in rects[b]):
            print(f"overlap: {a} / {b}")
print(f"{bad} pad problems")
