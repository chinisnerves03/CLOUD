#!/usr/bin/env python3
"""Put an already-paid voice clip into the cache so make_episode.py never pays for it again.
usage: adopt_clip.py ENTRY LINE_ID FILE.mp3 [--source elevenlabs-connector]
The line text and voice come from the script, so the cache key matches what make_episode.py looks up."""
import shutil, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import pt_script, pt_voice

n, lid, src = int(sys.argv[1]), sys.argv[2], Path(sys.argv[3])
entry, voices = pt_script.parse_entry(n), pt_voice.load_voices()
line = next((l for l in entry["lines"] if l["id"] == lid), None) or sys.exit(f"no line {lid} in entry {n}")
voice = voices[line["speaker"]]
dest = pt_voice.cached_path(voice["voice_id"], line["text"])
dest.parent.mkdir(parents=True, exist_ok=True)
shutil.copyfile(src, dest)
pt_voice.write_meta(dest, voice, line["text"], "elevenlabs-connector")
print(f"{lid}: {dest.name} ({pt_voice.probe_duration(dest):.2f}s)")
