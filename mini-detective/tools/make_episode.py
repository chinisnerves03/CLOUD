#!/usr/bin/env python3
"""One-command episode builder:  python3 tools/make_episode.py N

script (06_scripts) + shot list (shots/epNN.json) + voices (ElevenLabs, cached)
  -> out/epNN.mp4  and  out/epNN_captions.md

Voice generation spends credits, so uncached lines are only generated when --approve-credits >= the estimate.
Use --tts mock for a scratch (non-speech) voice to test visuals/timing for free; output is named epNN_scratch.mp4.
"""
import argparse, json, os, re, shutil, subprocess, sys, time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import pt_script, pt_voice, pt_sfx  # noqa: E402

ROOT = HERE.parent
OUT = ROOT / "out"
FPS = 30
REF = re.compile(r"^(?:(\w+)\.)?(start|end|mid|pause(\d+)|resume(\d+))?([+-]\d+(?:\.\d+)?)?$")


def die(msg): sys.exit(f"error: {msg}")


def load_shots(n):
    p = ROOT / "shots" / f"ep{n:02d}.json"
    if not p.exists():
        die(f"{p.relative_to(ROOT)} missing - write the shot list first")
    return json.loads(p.read_text(encoding="utf-8"))


def make_resolver(tl, shot_t0, shot_t1):
    def resolve(ref):
        if isinstance(ref, (int, float)):
            return shot_t0 + float(ref)
        m = REF.match(str(ref))
        if not m or not (m.group(2) or m.group(5) or m.group(1)):
            die(f"bad time reference '{ref}'")
        line, what, dt = m.group(1), m.group(2), float(m.group(5) or 0)
        if line is None:
            base = shot_t0 if what in (None, "start") else shot_t1
            return base + dt
        if line not in tl:
            die(f"time reference '{ref}' names unknown line '{line}'")
        L = tl[line]
        if what in (None, "start"): base = L["start"]
        elif what == "end": base = L["end"]
        elif what == "mid": base = (L["start"] + L["end"]) / 2
        else:
            k = int((m.group(3) or m.group(4))) - 1
            if k >= len(L["pauses"]):  # never fail after voices are paid for: fall back to a proportional guess
                frac = (k + 1) / (k + 2)
                print(f"  WARNING: '{ref}': only {len(L['pauses'])} pause(s) detected in {line}; using {frac:.0%} of the line (unverified timing)")
                base = L["start"] + L["len"] * frac
            else:
                base = L["start"] + L["pauses"][k][0 if m.group(3) else 1]
        return base + dt
    return resolve


def ffill(keys):
    """Keyframes are states: a field omitted in a later key keeps its previous value."""
    keys = sorted(keys, key=lambda k: k["t"]); cur, out = {}, []
    for k in keys:
        cur = {**cur, **k}; out.append(dict(cur))
    return out


def build_ep(entry, shotcfg, tl, speech_end, total, captions):
    lines_by_id = {l["id"]: l for l in entry["lines"]}
    order = [l["id"] for l in entry["lines"]]
    # absolute pause times for the engine (mouths close during pauses)
    EPL = {i: {"speaker": lines_by_id[i]["speaker"], "spoken": lines_by_id[i]["spoken"], "start": tl[i]["start"], "end": tl[i]["end"],
               "pauses": [[round(tl[i]["start"] + s, 3), round(tl[i]["start"] + e, 3)] for s, e in tl[i]["pauses"]]} for i in order}
    shots, covered = [], []
    for si, sh in enumerate(shotcfg["shots"]):
        for lid in sh["lines"]:
            if lid not in tl: die(f"shot {sh['id']}: unknown line '{lid}'")
        covered += sh["lines"]
    if covered != order:
        die(f"shots must cover every line once, in order. script order: {order}; shots: {covered}")
    t0s = [0.0] + [round(tl[sh["lines"][0]]["start"] - sh.get("pre", 0.12), 3) for sh in shotcfg["shots"][1:]]
    t1s = t0s[1:] + [total]
    sfx_events = []
    for sh, t0, t1 in zip(shotcfg["shots"], t0s, t1s):
        rs = make_resolver(tl, t0, t1)
        out = {"id": sh["id"], "t0": t0, "t1": t1, "bg": sh["bg"], "bgopts": sh.get("bgopts", {}), "cam": [], "actors": [], "props": [], "cues": []}
        for k in sh.get("cam", []):
            d = {kk: vv for kk, vv in k.items() if kk != "at"}; d["t"] = rs(k["at"]); out["cam"].append(d)
        out["cam"] = ffill(out["cam"])
        for key, tgt in (("actors", "actors"), ("props", "props")):
            for a in sh.get(key, []):
                d = {kk: vv for kk, vv in a.items() if kk != "keys"}
                d["keys"] = ffill([dict({kk: vv for kk, vv in k.items() if kk != "at"}, t=rs(k["at"])) for k in a.get("keys", [])])
                out[tgt].append(d)
        for c in sh.get("cues", []):
            t = rs(c["at"])
            if c["do"] == "sfx":
                sfx_events.append({"t": round(t, 3), "name": c["name"], "gain": c.get("gain", -8)}); continue
            d = {kk: vv for kk, vv in c.items() if kk not in ("at", "until")}; d["t"] = round(t, 3)
            d["dur"] = round(rs(c["until"]) - t, 3) if "until" in c else c.get("dur", 2.0)
            out["cues"].append(d)
            if c["do"] == "clue":
                sfx_events.append({"t": round(t, 3), "name": "paper_tear", "gain": -5})
        for key in ("overlay", "shake"):
            if key in sh:
                out[key] = ffill([dict({kk: vv for kk, vv in k.items() if kk != "at"}, t=rs(k["at"])) for k in sh[key]])
        for cue in sh.get("sfx", []):  # shorthand: [{"at":..,"name":..}]
            sfx_events.append({"t": round(rs(cue["at"]), 3), "name": cue["name"], "gain": cue.get("gain", -8)})
        shots.append(out)
    ep = {"entry": entry["entry"], "title": entry["title"], "fps": FPS, "total": total, "speech_end": speech_end,
          "end_card": entry["end_card"], "captions": captions, "order": order, "lines": EPL, "shots": shots}
    return ep, sfx_events


def render(html, framedir, total, workers, quality):
    n = int(total * FPS) + 1
    framedir.mkdir(parents=True, exist_ok=True)
    for f in framedir.glob("f*.jpg"): f.unlink()
    chunk = -(-n // workers)
    procs = [subprocess.Popen(["node", str(HERE / "render_worker.mjs"), str(html), str(framedir), str(i), str(min(n, i + chunk)), str(FPS), str(quality)])
             for i in range(0, n, chunk)]
    rc = [p.wait() for p in procs]
    got = len(list(framedir.glob("f*.jpg")))
    if any(rc) or got != n:
        die(f"render failed (exit codes {rc}, {got}/{n} frames)")
    return n


def encode(framedir, wav, mp4, total):
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-framerate", str(FPS), "-i", str(framedir / "f%05d.jpg"), "-i", str(wav),
                    "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-pix_fmt", "yuv420p", "-r", str(FPS),
                    "-c:a", "aac", "-b:a", "192k", "-t", f"{total:.3f}", "-movflags", "+faststart", str(mp4)], check=True)


def captions_stage(entry, mp4_name, scratch):
    from pt_captions import emit_captions
    return emit_captions(entry, ROOT, OUT, scratch)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("entry", type=int)
    ap.add_argument("--plan", action="store_true", help="print lines, characters, credit estimate, cache hits; spend nothing")
    ap.add_argument("--tts", choices=["elevenlabs", "mock"], default="elevenlabs")
    ap.add_argument("--approve-credits", type=int, default=0, help="credits the user approved for this run")
    ap.add_argument("--workers", type=int, default=min(4, os.cpu_count() or 2))
    ap.add_argument("--no-captions", action="store_true", help="no burned-in subtitles")
    ap.add_argument("--no-music", action="store_true")
    ap.add_argument("--quality", type=int, default=92, help="jpeg quality of rendered frames")
    ap.add_argument("--stills", nargs="*", type=float, help="render only these times (s) to out/epNN_work/still_*.jpg and stop")
    a = ap.parse_args()

    entry = pt_script.parse_entry(a.entry)
    voices = pt_voice.load_voices()
    words = pt_script.word_count(entry)
    rows, need_chars, credits = pt_voice.plan(entry, voices)
    if a.plan:
        print(f"Entry {a.entry} \"{entry['title']}\": {len(rows)} lines, {words} spoken words (~{words * 0.67:.0f}s at ep01's measured pace, UNVERIFIED for this entry)")
        for r in rows:
            print(f"  {r['id']:<8}{r['voice'][:22]:<24}{r['chars']:>4} chars  {'cached' if r['cached'] else 'NEEDS VOICE'}")
        print(f"uncached: {sum(not r['cached'] for r in rows)} lines, {need_chars} chars -> est. {credits} credits (1 credit/char assumed, UNVERIFIED)")
        return

    scratch = a.tts == "mock"
    name = f"ep{a.entry:02d}"
    work = OUT / f"{name}_work"
    work.mkdir(parents=True, exist_ok=True)
    print(f"[1/6] voice ({'SCRATCH tone voice - not real speech' if scratch else 'ElevenLabs, cached'})")
    clips = {l["id"]: pt_voice.mock_clip(l, voices) for l in entry["lines"]} if scratch else pt_voice.ensure_real_clips(entry, voices, a.approve_credits)

    print("[2/6] measure clips, find pauses, build timeline")
    shotcfg = load_shots(a.entry)
    gaps = shotcfg.get("gaps", {})
    tl, speech_end, total = {}, 0, 0
    # build_timeline uses a fixed gap; apply per-line gap overrides by shifting afterwards
    tl, speech_end, total = pt_voice.build_timeline(entry, clips, gap=shotcfg.get("gap", 0.2), lead_in=shotcfg.get("lead_in", 0.5), hold_end=shotcfg.get("hold_end", 2.2))
    if gaps:
        shift = 0.0
        for l in entry["lines"]:
            d = tl[l["id"]]; d["start"] = round(d["start"] + shift, 3); d["end"] = round(d["end"] + shift, 3)
            shift += gaps.get(l["id"], 0.0)
        speech_end = round(speech_end + shift, 3); total = round(total + shift, 3)
    (work / "timeline.json").write_text(json.dumps({"speech_end": speech_end, "total": total, "lines": tl}, indent=1))
    flag = "" if total <= 45 else "  ** OVER the 45 s target **"
    print(f"      speech ends {speech_end:.1f}s, total {total:.1f}s{flag}")

    print("[3/6] build scene html")
    ep, sfx_events = build_ep(entry, shotcfg, tl, speech_end, total, not a.no_captions)
    tpl = (HERE / "template" / "scene.html").read_text(encoding="utf-8")
    tpl = re.sub(r"(?:/\*__|<!--)INLINE:([\w.]+?)(?:__\*/|-->)", lambda m: (HERE / "template" / m.group(1)).read_text(encoding="utf-8"), tpl)
    html = work / "scene.html"
    html.write_text(tpl.replace("/*__EP_DATA__*/null", json.dumps(ep)), encoding="utf-8")
    if a.stills:
        for old in work.glob("still_*.jpg"): old.unlink()
        for t in a.stills:
            subprocess.run(["node", str(HERE / "render_worker.mjs"), str(html), str(work), str(int(t * FPS)), str(int(t * FPS) + 1), str(FPS), "92"], check=True)
            (work / f"f{int(t * FPS):05d}.jpg").rename(work / f"still_{t:07.2f}.jpg")
        try:  # contact sheet for quick review
            from PIL import Image
            fs = sorted(work.glob("still_*.jpg")); cols = min(4, len(fs)); rows_ = -(-len(fs) // cols)
            sheet = Image.new("RGB", (360 * cols, 640 * rows_))
            for i, f in enumerate(fs): sheet.paste(Image.open(f).resize((360, 640)), ((i % cols) * 360, (i // cols) * 640))
            sheet.save(work / "contact.jpg", quality=85)
        except ImportError:
            pass
        print("stills in", work); return

    print(f"[4/6] render {int(total * FPS) + 1} frames with {a.workers} workers")
    t0 = time.time()
    render(html, work / "frames", total, a.workers, a.quality)
    print(f"      done in {time.time() - t0:.0f}s")

    print("[5/6] mix audio (voices + synthesized sfx/beds), loudnorm -14 LUFS")
    cfg = {"sfx_events": sfx_events + shotcfg.get("sfx", []), "beds": [], "music_gain": shotcfg.get("music_gain", -30)}
    for b in shotcfg.get("beds", [{"name": "room", "gain": -34}]):
        cfg["beds"].append({"name": b["name"], "gain": b.get("gain", -34), "from": b.get("from", 0), "to": b.get("to", total)})
    raw = pt_sfx.mix(tl, cfg, total, work / "mix_raw.wav", music=not a.no_music)
    stats = pt_sfx.loudnorm(raw, work / "mix.wav")
    print(f"      loudness {stats['integrated_lufs']} LUFS, true peak {stats['true_peak_dbtp']} dBFS")

    print("[6/6] encode")
    OUT.mkdir(exist_ok=True)
    mp4 = OUT / (f"{name}_scratch.mp4" if scratch else f"{name}.mp4")
    encode(work / "frames", work / "mix.wav", mp4, total)
    caps = captions_stage(entry, mp4.name, scratch)
    dur = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(mp4)], capture_output=True, text=True).stdout)
    print(f"\n{mp4.relative_to(ROOT)}  {dur:.2f}s  {mp4.stat().st_size / 1e6:.1f} MB   captions: {caps.relative_to(ROOT)}")
    if scratch:
        print("NOTE: scratch voice - timing will change when the real voice is generated.")


if __name__ == "__main__":
    main()
