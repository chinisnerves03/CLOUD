"""Caption stage: copy captions/epNN.md to out/epNN_captions.md after linting, or write a clearly-marked DRAFT."""
import re
from pathlib import Path

DISCLOSURE = "Voices in this series are AI generated."


def secret_terms(root):
    p = root / "tools" / "secret_terms.txt"
    return [l.strip().lower() for l in p.read_text(encoding="utf-8").splitlines() if l.strip() and not l.startswith("#")]


def lint(text, root):
    problems = [f"secret-canon term: '{t}'" for t in secret_terms(root) if t in text.lower()]
    for sec in re.split(r"^## ", text, flags=re.M)[1:]:
        title, _, body = sec.partition("\n")
        tags = re.findall(r"(?<!\w)#\w+", body)
        if title.strip().lower().startswith("instagram") and len(body) > 2200: problems.append("IG caption > 2200 chars")
        if title.strip().lower().startswith("instagram") and len(tags) > 30: problems.append("IG > 30 hashtags")
        if title.strip().lower().startswith("youtube") and DISCLOSURE.lower() not in body.lower(): problems.append("YouTube description lacks the AI-voice disclosure line")
    return problems


def emit_captions(entry, root, out, scratch):
    n = entry["entry"]
    src = root / "captions" / f"ep{n:02d}.md"
    dst = out / f"ep{n:02d}_captions.md"
    if src.exists():
        text = src.read_text(encoding="utf-8")
        status = "authored"
    else:
        nxt = entry["end_card"]
        text = (f"# Entry {n} - {entry['title']}  (DRAFT - not yet authored in captions/ep{n:02d}.md)\n\n"
                f"## Instagram\nLost and Found Log, entry {n}. Where does this one end? Tell us below.\n{nxt}\n"
                f"What did YOU lose that never came back?\n\n#PipThimble #TinyDetective #MysterySeries #Shorts\n\n"
                f"## TikTok\nEntry {n}: {entry['title']}. {nxt}\n\n#tinydetective #animation #mystery\n\n"
                f"## Facebook\nLost and Found Log, entry {n}. {nxt}\n\n"
                f"## YouTube\nTitle: Pip Thimble, Entry {n}: {entry['title']} #Shorts\n\nDescription:\n{nxt}\n\n{DISCLOSURE}\n")
        status = "DRAFT"
    probs = lint(text, root)
    head = f"<!-- status: {status}; lint: {'PASS' if not probs else 'FAIL: ' + '; '.join(probs)} -->\n"
    dst.write_text(head + text, encoding="utf-8")
    if probs:
        print("  caption lint problems:", "; ".join(probs))
    return dst
