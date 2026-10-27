"""Parse 06_scripts_ep01-10.md into structured lines.

Line ids follow the ep01 clip naming: n1.. (narrator), pip1.., juno1.., brass1.., velvet1..,
fuzz1.., cog1.., col1.. (Collector and the finale VOICE line).
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

SPEAKERS = {  # script label -> (key, id prefix)
    "NARRATOR": ("narrator", "n"),
    "PIP": ("pip", "pip"),
    "JUNO": ("juno", "juno"),
    "BRASS": ("brass", "brass"),
    "VELVET": ("velvet", "velvet"),
    "FUZZ": ("fuzz", "fuzz"),
    "COG": ("cog", "cog"),
    "COLLECTOR": ("collector", "col"),
}
SPEAK_RE = re.compile(r"^(NARRATOR|PIP|JUNO|BRASS|VELVET|FUZZ|COG|COLLECTOR|VOICE \(Collector[^)]*\)):\s*(.*)$")
TAG_RE = re.compile(r"\[[^\]]*\]")


def strip_tags(text):
    return re.sub(r"\s+", " ", TAG_RE.sub("", text)).strip()


def parse_entry(n, path=None):
    path = Path(path) if path else ROOT / "06_scripts_ep01-10.md"
    md = path.read_text(encoding="utf-8")
    m = re.search(r"^## ENTRY %d\b[^\n]*\n(.*?)(?=^## ENTRY \d+\b|\Z)" % n, md, re.S | re.M)
    if not m:
        raise SystemExit(f"entry {n} not found in {path.name}")
    head = re.search(r"^## ENTRY %d\s*[—-]\s*([^\n]*)" % n, md, re.M)
    title = re.sub(r"\s*\(.*\)$", "", head.group(1)).strip() if head else f"Entry {n}"
    lines, counters, visual, sfx, end_card = [], {}, [], "", ""
    for raw in m.group(1).splitlines():
        s = raw.strip()
        if not s or s == "---":
            continue
        if s.startswith("VISUAL"):
            visual.append(s.split(":", 1)[1].strip())
            continue
        if s.startswith("SFX:"):
            sfx = s[4:].strip()
            continue
        if s.startswith("END CARD:"):
            end_card = s.split(":", 1)[1].strip().strip('"')
            continue
        sm = SPEAK_RE.match(s)
        if not sm:
            continue
        label = "COLLECTOR" if sm.group(1).startswith("VOICE") else sm.group(1)
        key, prefix = SPEAKERS[label]
        counters[prefix] = counters.get(prefix, 0) + 1
        text = sm.group(2).strip()
        lines.append({
            "id": f"{prefix}{counters[prefix]}", "speaker": key, "text": text,
            "spoken": strip_tags(text), "visual": " ".join(visual),
        })
        visual = []
    if not lines:
        raise SystemExit(f"entry {n}: no spoken lines parsed")
    return {"entry": n, "title": title, "lines": lines, "end_card": end_card, "sfx_notes": sfx}


def word_count(entry):
    return sum(len(l["spoken"].split()) for l in entry["lines"])
