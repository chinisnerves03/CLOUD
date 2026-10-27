"""Voice stage: voice table, content-addressed clip cache, ElevenLabs call, ffprobe/silencedetect.

The API key is read from ELEVENLABS_API_KEY at call time only. It is never written to disk,
logged, or put in the cache metadata.
"""
import hashlib, json, math, os, re, subprocess, sys, time, urllib.request, urllib.error, wave, zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "audio" / "cache"
MOCK = ROOT / "audio" / "mock"
MODEL = "eleven_v3"
# Script speaker -> first words of the role cell in 04_voice_cast.md
ROLE_CELL = {"narrator": "Narrator", "pip": "Pip Thimble", "juno": "Juno Quill", "brass": "Inspector Gaffer Brass",
             "velvet": "Madame Velvet Ravel", "cog": "Professor Cog", "fuzz": "Fuzz", "collector": "The Collector"}
CREDITS_PER_CHAR = 1.0  # eleven_v3 billed per character (my understanding; UNVERIFIED against the account's plan)


def load_voices():
    md = (ROOT / "04_voice_cast.md").read_text(encoding="utf-8")
    table = {}
    for row in md.splitlines():
        cells = [c.strip() for c in row.strip().strip("|").split("|")]
        if len(cells) >= 3 and re.fullmatch(r"`[A-Za-z0-9]{20}`", cells[2]):
            table[cells[0]] = {"name": cells[1], "voice_id": cells[2].strip("`")}
    out = {}
    for spk, cell in ROLE_CELL.items():
        hit = next((v for k, v in table.items() if k.startswith(cell)), None)
        if not hit:
            raise SystemExit(f"voice for '{spk}' not found in 04_voice_cast.md")
        out[spk] = hit
    return out


def clip_key(voice_id, text, model=MODEL):
    return hashlib.sha256(f"{model}\x1f{voice_id}\x1f{text}".encode()).hexdigest()[:20]


def cached_path(voice_id, text):
    return CACHE / (clip_key(voice_id, text) + ".mp3")


def plan(entry, voices):
    """Return per-line cache status and the credit estimate for what is missing."""
    rows, need_chars = [], 0
    for l in entry["lines"]:
        v = voices[l["speaker"]]
        p = cached_path(v["voice_id"], l["text"])
        hit = p.exists()
        rows.append({"id": l["id"], "speaker": l["speaker"], "voice": v["name"], "chars": len(l["text"]), "cached": hit})
        if not hit:
            need_chars += len(l["text"])
    return rows, need_chars, math.ceil(need_chars * CREDITS_PER_CHAR)


def generate(voice_id, text, dest):
    key = os.environ.get("ELEVENLABS_API_KEY")
    if not key:
        raise SystemExit("ELEVENLABS_API_KEY is not set in the environment; cannot generate voice.")
    body = json.dumps({"text": text, "model_id": MODEL}).encode()
    req = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}?output_format=mp3_44100_128", data=body,
        headers={"xi-api-key": key, "Content-Type": "application/json", "Accept": "audio/mpeg"})
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            data = r.read()
    except urllib.error.HTTPError as e:  # no retry: a retry would be a second paid generation
        raise SystemExit(f"ElevenLabs HTTP {e.code}: {e.read()[:300].decode('utf-8','replace')}")
    if len(data) < 1000:
        raise SystemExit("ElevenLabs returned an unexpectedly small body; not caching it.")
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(".part")
    tmp.write_bytes(data)
    tmp.rename(dest)


def write_meta(dest, voice, text, source):
    dest.with_suffix(".json").write_text(json.dumps({
        "voice": voice["name"], "voice_id": voice["voice_id"], "model": MODEL, "text": text, "chars": len(text),
        "source": source, "created": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}, indent=1), encoding="utf-8")


def ensure_real_clips(entry, voices, approved_credits):
    rows, need_chars, credits = plan(entry, voices)
    if credits and approved_credits < credits:
        raise SystemExit(f"{credits} credits needed for uncached lines; approval given for {approved_credits}. "
                         f"Re-run with --approve-credits {credits} after the user approves.")
    paths = {}
    for l in entry["lines"]:
        v = voices[l["speaker"]]
        p = cached_path(v["voice_id"], l["text"])
        if not p.exists():
            print(f"  voicing {l['id']} ({v['name']}, {len(l['text'])} chars)", flush=True)
            generate(v["voice_id"], l["text"], p)
            write_meta(p, v, l["text"], "elevenlabs")
        paths[l["id"]] = p
    return paths


# ---- scratch voice: NOT a real voice, only to test timing/animation/mix without spending credits ----
def mock_clip(line, voices):
    MOCK.mkdir(parents=True, exist_ok=True)
    p = MOCK / (clip_key("mock", line["text"]) + ".wav")
    if p.exists():
        return p
    import numpy as np
    sr, rng = 44100, np.random.default_rng(zlib.crc32(line["spoken"].encode()))
    base = {"narrator": 110, "pip": 150, "juno": 190, "brass": 95, "velvet": 170, "fuzz": 120, "cog": 140, "collector": 80}[line["speaker"]]
    chunks, t_total = [np.zeros(int(sr * 0.06))], 0
    tokens = re.findall(r"\[[^\]]*\]|[^\s\[\]]+", line["text"])
    for tok in tokens:
        if tok.startswith("["):
            gap = {"[pause]": .35, "[short pause]": .2, "[long pause]": .7}.get(tok.lower(), 0)
            chunks.append(np.zeros(int(sr * gap)))
            continue
        word = re.sub(r"\W", "", tok) or "x"
        dur = 0.07 * len(word) + 0.08
        n = int(sr * dur)
        t = np.arange(n) / sr
        f0 = base * (1 + 0.15 * math.sin(len(chunks)))
        sig = sum(np.sin(2 * np.pi * f0 * k * t) / k for k in (1, 2, 3, 4))
        env = np.minimum(1, np.minimum(t / 0.02, (dur - t) / 0.03)) * (0.8 + 0.2 * np.sin(2 * np.pi * 4 * t))
        chunks.append(0.25 * sig * env)
        chunks.append(np.zeros(int(sr * (0.16 if tok[-1] in ".?!…," else 0.05))))
    chunks.append(np.zeros(int(sr * 0.1)))
    y = np.concatenate(chunks)
    with wave.open(str(p), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
        w.writeframes((np.clip(y, -1, 1) * 32767).astype("<i2").tobytes())
    return p


# ---- measurement ----
def probe_duration(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(path)],
                         capture_output=True, text=True, check=True).stdout.strip()
    return float(out)


def silences(path, noise_db=-32, min_d=0.12):
    r = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(path), "-af",
                        f"silencedetect=noise={noise_db}dB:d={min_d}", "-f", "null", "-"], capture_output=True, text=True)
    starts = [float(x) for x in re.findall(r"silence_start: (-?[\d.]+)", r.stderr)]
    ends = [float(x) for x in re.findall(r"silence_end: ([\d.]+)", r.stderr)]
    if len(starts) > len(ends):  # silence runs to end of file
        ends.append(None)
    return list(zip(starts, ends))


def analyse(path, min_pause=0.18):
    """Duration, leading/trailing silence, and interior word pauses (clip-local seconds)."""
    dur = probe_duration(path)
    lead, trail, pauses = 0.0, 0.0, []
    for s, e in silences(path):
        s = max(s, 0.0)
        if e is None:
            e = dur
        if s <= 0.02:
            lead = e
        elif e >= dur - 0.02:
            trail = dur - s
        elif e - s >= min_pause:
            pauses.append([round(s, 3), round(e, 3)])
    return {"dur": round(dur, 3), "lead": round(lead, 3), "trail": round(trail, 3), "pauses": pauses}


def build_timeline(entry, clip_paths, gap=0.2, lead_in=0.5, hold_end=2.2, keep_lead=0.04, keep_trail=0.12):
    """Place trimmed clips back to back. Times are absolute seconds in the final video."""
    t, tl = lead_in, {}
    for l in entry["lines"]:
        a = analyse(clip_paths[l["id"]])
        cut_in = max(0.0, a["lead"] - keep_lead)
        cut_out = min(a["dur"], a["dur"] - a["trail"] + keep_trail)
        length = cut_out - cut_in
        tl[l["id"]] = {"start": round(t, 3), "end": round(t + length, 3), "len": round(length, 3),
                       "cut_in": round(cut_in, 3), "cut_out": round(cut_out, 3), "clip": str(clip_paths[l["id"]]),
                       "pauses": [[round(s - cut_in, 3), round(e - cut_in, 3)] for s, e in a["pauses"]
                                  if cut_in < s and e < cut_out]}
        t += length + gap
    speech_end = max(v["end"] for v in tl.values())
    return tl, round(speech_end, 3), round(speech_end + hold_end, 3)
