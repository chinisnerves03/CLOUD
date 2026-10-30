#!/usr/bin/env python3
"""Turn an audio or video file into things Claude can read: a report, metrics and spectrogram images.

Usage: python3 listen.py INPUT OUTDIR [--start SEC] [--end SEC] [--no-speech]

Needs ffmpeg and numpy. Pillow draws the spectrograms (skipped without it).
faster-whisper or openai-whisper, when installed, adds a speech transcript.
"""
import argparse, json, os, subprocess, sys, wave
import numpy as np

RATE = 22050          # analysis rate: keeps content up to ~11 kHz
HOP_S, WIN_S = 0.025, 0.05
SEG_S = 0.5           # labelled segment length


def extract(src, dst, start, end):
    cmd = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y"]
    if start is not None:
        cmd += ["-ss", str(start)]
    cmd += ["-i", src]
    if end is not None:
        cmd += ["-t", str(end - (start or 0))]
    cmd += ["-vn", "-ac", "1", "-ar", str(RATE), "-c:a", "pcm_s16le", dst]
    subprocess.run(cmd, check=True)
    with wave.open(dst) as w:
        return np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(np.float32) / 32768


def frames(x):
    hop, win = int(RATE * HOP_S), int(RATE * WIN_S)
    if len(x) < win:
        x = np.pad(x, (0, win - len(x)))
    n = 1 + (len(x) - win) // hop
    idx = np.arange(win)[None, :] + hop * np.arange(n)[:, None]
    spec = np.abs(np.fft.rfft(x[idx] * np.hanning(win), axis=1))
    freqs = np.fft.rfftfreq(win, 1 / RATE)
    return spec, freqs, np.arange(n) * HOP_S


def per_frame(spec, freqs, x):
    hop, win = int(RATE * HOP_S), int(RATE * WIN_S)
    n = spec.shape[0]
    rms = np.array([np.sqrt(np.mean(x[i * hop:i * hop + win] ** 2) + 1e-12) for i in range(n)])
    db = 20 * np.log10(rms + 1e-9)
    power = spec ** 2 + 1e-12
    band = (freqs >= 60) & (freqs <= 8000)
    dom = freqs[band][np.argmax(spec[:, band], axis=1)]
    centroid = (power * freqs).sum(1) / power.sum(1)
    flatness = np.exp(np.mean(np.log(power[:, band]), 1)) / np.mean(power[:, band], 1)
    voice = power[:, (freqs >= 300) & (freqs <= 3400)].sum(1) / power.sum(1)
    flux = np.r_[0, np.maximum(0, np.diff(np.log(power[:, band]), axis=0)).mean(1)]
    return db, dom, centroid, flatness, voice, flux


def transients(db, flux, t):
    """Sharp loudness jumps: pops, bangs, clicks, hits, door slams."""
    events, last = [], -1.0
    thresh = np.median(flux) + 3 * np.std(flux)
    for i in range(len(db)):
        prev = db[max(0, i - 4):i]
        base = -90.0 if i < 4 else prev.min()   # treat time before the file as silence
        if len(prev):
            base = min(base, prev.min())
        jump = db[i] - base
        if (flux[i] > thresh or i == 0) and jump > 8 and db[i] > -40 and t[i] - last > 0.08:
            events.append({"t": round(float(t[i]), 2), "db": round(float(db[i]), 1), "jump_db": round(float(jump), 1)})
            last = t[i]
    return events


def label_segments(t, db, dom, centroid, flatness, voice, events):
    per = int(SEG_S / HOP_S)
    out = []
    for s in range(0, len(t), per):
        sl = slice(s, s + per)
        loud = db[sl] > -45
        seg = {"start": round(float(t[s]), 2), "end": round(float(t[s] + SEG_S), 2),
               "db": round(float(np.max(db[sl])), 1)}
        if loud.sum() < per * 0.3:
            seg["label"] = "silence/very quiet"
            out.append(seg)
            continue
        f = dom[sl][loud]
        fl = float(np.median(flatness[sl][loud]))
        seg.update(dominant_hz=int(np.median(f)), centroid_hz=int(np.median(centroid[sl][loud])),
                   flatness=round(fl, 3), voice_band=round(float(np.median(voice[sl][loud])), 2))
        n_tr = sum(1 for e in events if seg["start"] <= e["t"] < seg["end"])
        tags = []
        if fl < 0.08:
            tags.append("tonal")
            steps = np.abs(np.diff(np.log2(f + 1)))
            # argmax hops between harmonics on rich sounds; only trust a trend when the track is steady
            if len(f) > 3 and np.mean(steps > 0.25) < 0.15:
                slope = np.polyfit(np.arange(len(f)), np.log2(f + 1), 1)[0] / HOP_S  # octaves/s
                if slope > 0.6:
                    tags.append("pitch rising")
                elif slope < -0.6:
                    tags.append("pitch falling")
        elif fl > 0.3:
            tags.append("noisy/broadband")
        else:
            tags.append("mixed tone+noise")
        if seg["voice_band"] > 0.6 and 0.02 < fl < 0.3:
            tags.append("speech-like band")
        if n_tr >= 3:
            tags.append(f"{n_tr} transients (pops/bangs/hits)")
        elif n_tr:
            tags.append(f"{n_tr} transient")
        seg["label"] = ", ".join(tags)
        out.append(seg)
    return out


def merge(segments):
    """Join neighbouring segments with the same label so the timeline reads like a summary."""
    merged = []
    for seg in segments:
        if merged and merged[-1]["label"] == seg["label"]:
            merged[-1]["end"] = seg["end"]
            merged[-1]["db"] = max(merged[-1]["db"], seg["db"])
        else:
            merged.append(dict(seg))
    return merged


def spectrograms(spec, freqs, t, outdir, chunk_s=30):
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        return []
    lo_hz, hi_hz = 50, 8000
    s_db = 20 * np.log10(spec + 1e-9)
    floor, top = np.percentile(s_db[:, freqs <= hi_hz], [40, 99.7])
    norm = np.clip((s_db - floor) / max(top - floor, 1e-6), 0, 1) ** 1.5
    paths, per = [], int(chunk_s / HOP_S)
    for k, start in enumerate(range(0, len(t), per)):
        block = norm[start:start + per]
        h, w = 400, max(200, min(1200, block.shape[0] * 2))
        # log-frequency rows, high frequencies at the top
        row_hz = lo_hz * (hi_hz / lo_hz) ** np.linspace(1, 0, h)
        rows = np.clip(np.searchsorted(freqs, row_hz), 0, len(freqs) - 1)
        cols = np.linspace(0, block.shape[0] - 1, w).astype(int)
        v = block[cols][:, rows].T
        rgb = np.stack([np.clip(v * 3, 0, 1), np.clip(v * 3 - 1, 0, 1), np.clip(v * 3 - 2, 0, 1)], -1)
        pad_l, pad_b = 46, 22
        canvas = Image.new("RGB", (w + pad_l, h + pad_b), "white")
        canvas.paste(Image.fromarray((rgb * 255).astype(np.uint8)), (pad_l, 0))
        d = ImageDraw.Draw(canvas)
        for hz in (100, 250, 500, 1000, 2000, 4000, 8000):
            y = int((1 - np.log(hz / lo_hz) / np.log(hi_hz / lo_hz)) * (h - 1))
            d.line([(pad_l - 4, y), (pad_l, y)], fill="black")
            d.text((2, max(0, y - 6)), f"{hz // 1000}k" if hz >= 1000 else str(hz), fill="black")
        dur = block.shape[0] * HOP_S
        t0 = start * HOP_S
        step = 5 if dur > 10 else 1
        for sec in np.arange(0, dur + 1e-6, step):
            x = pad_l + int(sec / max(dur, 1e-6) * (w - 1))
            d.line([(x, h), (x, h + 4)], fill="black")
            d.text((x - 8, h + 6), f"{t0 + sec:.0f}s", fill="black")
        path = os.path.join(outdir, f"spectrogram_{k:02d}.png")
        canvas.save(path)
        paths.append(path)
    return paths


def transcribe(path):
    try:
        from faster_whisper import WhisperModel
        model = WhisperModel("small", compute_type="int8")
        segs, info = model.transcribe(path)
        return {"engine": "faster-whisper small", "language": info.language,
                "segments": [{"start": round(s.start, 2), "end": round(s.end, 2), "text": s.text.strip()} for s in segs]}
    except ImportError:
        pass
    try:
        import whisper
        r = whisper.load_model("small").transcribe(path)
        return {"engine": "openai-whisper small", "language": r.get("language"),
                "segments": [{"start": round(s["start"], 2), "end": round(s["end"], 2), "text": s["text"].strip()} for s in r["segments"]]}
    except ImportError:
        return {"engine": None, "note": "No local speech model (pip install faster-whisper). Use a transcription connector if speech matters."}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input"); ap.add_argument("outdir")
    ap.add_argument("--start", type=float); ap.add_argument("--end", type=float)
    ap.add_argument("--no-speech", action="store_true")
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)
    wav = os.path.join(a.outdir, "audio.wav")
    x = extract(a.input, wav, a.start, a.end)
    if not len(x):
        sys.exit("No audio track found.")
    spec, freqs, t = frames(x)
    db, dom, centroid, flatness, voice, flux = per_frame(spec, freqs, x)
    offset = a.start or 0
    t = t + offset
    events = transients(db, flux, t)
    timeline = merge(label_segments(t, db, dom, centroid, flatness, voice, events))
    speech = {"engine": None, "note": "skipped (--no-speech)"} if a.no_speech else transcribe(wav)
    images = spectrograms(spec, freqs, t - offset, a.outdir)
    report = {
        "input": a.input, "duration_s": round(len(x) / RATE, 2), "offset_s": offset,
        "overall": {"peak_db": round(float(db.max()), 1), "median_db": round(float(np.median(db)), 1),
                    "median_dominant_hz": int(np.median(dom[db > -45])) if (db > -45).any() else None},
        "timeline": timeline, "transients": events, "speech": speech, "spectrograms": images,
        "limits": "Labels are signal heuristics (tone/noise/pitch trend/transients), not a trained sound classifier.",
    }
    with open(os.path.join(a.outdir, "report.json"), "w") as f:
        json.dump(report, f, indent=1, ensure_ascii=False)
    lines = [f"# Listening report: {os.path.basename(a.input)}",
             f"Duration {report['duration_s']} s, peak {report['overall']['peak_db']} dBFS, "
             f"median {report['overall']['median_db']} dBFS, typical dominant {report['overall']['median_dominant_hz']} Hz", "",
             "## Timeline", "| from | to | peak dB | dominant Hz | what it sounds like |", "|---|---|---|---|---|"]
    for s in timeline:
        lines.append(f"| {s['start']:.1f} | {s['end']:.1f} | {s['db']} | {s.get('dominant_hz', '')} | {s['label']} |")
    lines += ["", f"## Transients ({len(events)})", ", ".join(f"{e['t']}s" for e in events[:80]) or "none"]
    lines += ["", "## Speech"]
    if speech.get("segments"):
        lines += [f"Language: {speech.get('language')}"] + [f"- [{s['start']}-{s['end']}] {s['text']}" for s in speech["segments"]]
    else:
        lines.append(speech.get("note", "no speech detected"))
    lines += ["", "## Spectrograms"] + images + ["", report["limits"]]
    with open(os.path.join(a.outdir, "report.md"), "w") as f:
        f.write("\n".join(lines) + "\n")
    print(os.path.join(a.outdir, "report.md"))


if __name__ == "__main__":
    main()
