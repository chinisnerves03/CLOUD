"""Build the playable browser demo (web-demo.html) from the preview part dump.

Run tools/preview/build.sh first (it writes tools/preview/parts.jsonl), then:
    python3 build.py
The page loads three.js r128 from cdnjs and embeds every part of Plot1 plus the plaza.
"""
import json
import pathlib
import re

HERE = pathlib.Path(__file__).parent
SRC = HERE.parent / "preview" / "parts.jsonl"
SHAPES = ["Block", "Cylinder", "Ball", "Ellipsoid", "Wedge"]


def index(values, value):
    if value not in values:
        values.append(value)
    return values.index(value)


def main():
    parts = [json.loads(line) for line in SRC.open(encoding="utf-8") if line.startswith("{")]
    items, mats, out, texts, special = [], [], [], [], {}
    r = lambda x: round(x, 3)
    for p in parts:
        if p["t"] >= 1 and not p["texts"]:
            continue
        c = p["color"]
        color = (round(c[0] * 255) << 16) | (round(c[1] * 255) << 8) | round(c[2] * 255)
        n = len(out)
        if p["item"] == "base" and p["name"] in ("Pad1", "Staff", "Recipe", "Speed"):
            special[p["name"]] = n
        if p["item"] == "BrewStation" and p["name"] in ("Kettle", "BrewPad"):
            special[p["name"]] = n
        for t in p["texts"]:
            hex_color = "#%02x%02x%02x" % tuple(round(x * 255) for x in t["color"])
            texts.append([n, t["face"], t["text"], hex_color, 1 if t["glow"] else 0, [r(v) for v in t["region"]]])
        out.append([index(items, p["item"]), SHAPES.index(p["shape"])]
                   + [r(v) for v in p["size"]] + [r(v) for v in p["pos"]] + [r(v) for v in p["rot"]]
                   + [color, r(p["t"]), index(mats, p["mat"])])
    models = (HERE.parent.parent / "src" / "ServerScriptService" / "Services" / "ItemModels.lua").read_text(encoding="utf-8")
    body = models.split("ItemModels.PadSpots = {")[1].split("\n}\n")[0]
    pad_spots = {k: [float(x), float(z)] for k, x, z in re.findall(r"(L\d\d) = \{ (-?[\d.]+), (-?[\d.]+) \}", body)}
    data = json.dumps({"items": items, "mats": mats, "parts": out, "texts": texts, "special": special, "padSpots": pad_spots},
                      separators=(",", ":"), ensure_ascii=False).replace("</", "<\\/")
    html = (HERE / "template.html").read_text(encoding="utf-8").replace("__DATA__", data)
    (HERE / "web-demo.html").write_text(html, encoding="utf-8")
    print(f"web-demo.html: {len(out)} parts, {len(texts)} texts, {len(html) // 1024} KB")


if __name__ == "__main__":
    main()
