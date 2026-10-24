"""Synthesized sound effects, room beds and the final mix. Everything here is generated from math
(no samples), so there is nothing to license. Quality is placeholder-grade: unverified by ear."""
import math, subprocess, wave, json
from pathlib import Path
import numpy as np

SR = 44100
rng = np.random.default_rng(311)


def _t(d): return np.arange(int(SR * d)) / SR
def _put(out, s, y):
    y = y[:max(0, len(out) - s)]; out[s:s+len(y)] += y


def _env(n, a=0.005, r=0.1):
    e = np.ones(n); na, nr = max(1, int(SR * a)), max(1, int(SR * r))
    e[:na] = np.linspace(0, 1, na); e[-nr:] *= np.linspace(1, 0, min(nr, n)); return e
def _lp(x, k):  # moving-average low-pass, k samples
    k = max(1, int(k)); return np.convolve(x, np.ones(k) / k, mode="same")
def _hp(x, k): return x - _lp(x, k)
def _noise(d): return rng.standard_normal(int(SR * d))
def _pluck(f, d=0.5, bright=3):
    t = _t(d); y = sum(np.sin(2 * np.pi * f * h * t) / h**1.4 for h in range(1, bright + 1))
    return y * np.exp(-t * 7) * 0.5
def _bell(f, d=1.2):
    t = _t(d); return (np.sin(2*np.pi*f*t) + .4*np.sin(2*np.pi*f*2.76*t) + .2*np.sin(2*np.pi*f*5.4*t)) * np.exp(-t*3.2) * .45


def paper_tear(): n = _noise(.5); y = _hp(n, 6) * (rng.random(len(n)) > .55) * _env(len(n), .004, .25); return y * 1.2
def tick3():
    out = np.zeros(int(SR * .8))
    for i, f in enumerate((1568, 1175, 880)):
        s = int(SR * .2 * i); p = _pluck(f, .18, 2); _put(out, s, p)
    return out
def whoosh(): n = _noise(.7); sw = _lp(n, 40) - _lp(n, 6); return sw * np.sin(np.pi * np.linspace(0, 1, len(n)))**2 * 3
def thread_shimmer():
    t = _t(.9); f = 2400 + 800 * np.sin(2*np.pi*5*t); return np.sin(2*np.pi*np.cumsum(f)/SR) * (0.6+0.4*np.sin(2*np.pi*14*t)) * np.exp(-t*3) * .25
def thread_twang():
    t = _t(.9); return np.sin(2*np.pi*(196*t + 0.0)) * np.exp(-t*4) * .5 + np.sin(2*np.pi*392*t) * np.exp(-t*6) * .25
def dust_puff(): n = _noise(.35); return _lp(n, 25) * _env(len(n), .02, .3) * 4
def pat(): t = _t(.14); return np.sin(2*np.pi*90*t) * np.exp(-t*30) * .9 + _lp(_noise(.14), 30) * np.exp(-t*40)
def door_slam(): t = _t(.5); return (np.sin(2*np.pi*55*t) * np.exp(-t*9) + _lp(_noise(.5), 18) * np.exp(-t*14)) * 1.1
def _click():
    t = _t(.03); return _hp(_noise(.03), 4) * np.exp(-t*160)
def lock_click():
    out = np.zeros(int(SR*.5)); c = _click(); _put(out, 0, c*1.5); s = int(SR*.18); _put(out, s, c*1.1); return out
def wool_squelch(): n = _noise(.4); t = _t(.4); return _lp(n, 55) * (0.5 + 0.5*np.sin(2*np.pi*9*t)) * _env(len(n), .02, .25) * 5
def coin_clink():
    a, b = _bell(2093, .5) * .5, _bell(3136, .5) * .25; return a + b
def crumb(): return _lp(_noise(.08), 12) * np.exp(-_t(.08)*50) * 4
def glider_whoosh(): return whoosh() * .8
def music_notes(): # three slow music-box notes (the tune Pip half-recognises) - placeholder melody
    out = np.zeros(int(SR * 2.4))
    for i, f in enumerate((659.3, 587.3, 783.99)):
        s = int(SR * .7 * i); b = _bell(f, 1.4); _put(out, s, b)
    return out
def piano_soft():
    out = np.zeros(int(SR * 4))
    for s, f in ((0, 261.6), (1.0, 329.6), (2.0, 392.0), (3.0, 349.2)):
        p = _pluck(f, 1.6, 4) * .6; a = int(SR * s); _put(out, a, p)
    return out
def heartbeat(): t = _t(.5); return np.sin(2*np.pi*48*t)*np.exp(-t*14)*.9
def birds():
    out = np.zeros(int(SR * 2.4))
    for s in (0.1, 0.5, 1.2, 1.5, 1.9):
        t = _t(.12); f = 3200 + 900*np.sin(2*np.pi*(14+s*3)*t); y = np.sin(2*np.pi*np.cumsum(f)/SR)*np.exp(-t*18)*.18
        a = int(SR*s); _put(out, a, y)
    return out

ONESHOTS = {k: v for k, v in globals().items() if k in (
    "paper_tear tick3 whoosh thread_shimmer thread_twang dust_puff pat door_slam lock_click wool_squelch coin_clink crumb "
    "glider_whoosh music_notes piano_soft heartbeat birds").split()}


def bed(kind, d):
    n = int(SR * d); t = np.arange(n) / SR
    if kind == "room":  # dusty quiet room
        return _lp(rng.standard_normal(n), 60) * 0.9 + 0.05 * np.sin(2*np.pi*60*t)
    if kind == "crowd":  # murmur: several band-limited noises with slow modulation
        y = sum(_lp(rng.standard_normal(n), k) * (0.6 + 0.4*np.sin(2*np.pi*r*t + p)) for k, r, p in ((14, .31, 0), (22, .23, 2), (9, .4, 4)))
        return y * 1.2
    if kind == "fog":   # low beating drone
        return (np.sin(2*np.pi*98*t) + np.sin(2*np.pi*99.6*t) + .5*np.sin(2*np.pi*147*t)) * .25 + _lp(rng.standard_normal(n), 90) * .8
    if kind == "lounge":  # warm murmur + soft sustained pad
        return bed("crowd", d) * .6 + (np.sin(2*np.pi*130.8*t) + .6*np.sin(2*np.pi*196*t)) * .12
    if kind == "wind":
        return _lp(rng.standard_normal(n), 30) * (0.7 + 0.3*np.sin(2*np.pi*.2*t)) * 1.3
    raise ValueError(f"unknown bed {kind}")


def pluck_music(d, bpm=72):
    """Sparse pizzicato in A minor pentatonic - own composition, nothing to license."""
    n = int(SR * d); out = np.zeros(n); beat = 60 / bpm; scale = (220, 261.6, 293.7, 329.6, 392.0, 440)
    r = np.random.default_rng(72); t = 0.0; i = 0
    while t < d - 0.5:
        if r.random() < .55:
            p = _pluck(scale[int(r.integers(0, len(scale)))], .5, 3) * (.7 + .3 * r.random()); a = int(SR * t)
            _put(out, a, p)
        t += beat / 2; i += 1
    return out


def db(g): return 10 ** (g / 20)


def mix(timeline, entry_cfg, total, out_wav, music=True, voice_gain_db=0.0):
    """Mix trimmed voice clips + cue SFX + beds. Beds duck under speech."""
    n = int(SR * (total + .5)); voice = np.zeros(n); sfx = np.zeros(n); beds = np.zeros(n)
    for lid, tl in timeline.items():
        clip = _decode(tl["clip"]); a, b = int(SR * tl["cut_in"]), int(SR * tl["cut_out"]); seg = clip[a:b]
        fi = min(len(seg), int(SR * .01)); seg = seg.copy(); seg[:fi] *= np.linspace(0, 1, fi); seg[-fi:] *= np.linspace(1, 0, fi)
        s = int(SR * tl["start"]); voice[s:s+len(seg)] += seg[:max(0, n-s)] * db(voice_gain_db)
    for cue in entry_cfg["sfx_events"]:
        fn = ONESHOTS[cue["name"]]; y = fn() * db(cue.get("gain", -8)); s = int(SR * cue["t"])
        y = y[:max(0, n - s)]; sfx[s:s+len(y)] += y
    for b in entry_cfg["beds"]:
        a, z = b["from"], min(b["to"], total); y = bed(b["name"], z - a + .2)[:int(SR * (z - a))] * db(b.get("gain", -34))
        y *= _env(len(y), .8, 1.0); s = int(SR * a); beds[s:s+len(y)] += y
    if music:
        m = pluck_music(total) * db(entry_cfg.get("music_gain", -30)); beds[:len(m)] += m
    # duck beds ~4 dB under voice (smoothed envelope)
    ve = _lp(np.abs(voice), int(SR * .12)); duck = 1 - np.clip(ve * 14, 0, 1) * (1 - db(-4)); beds *= duck
    y = voice + sfx + beds
    pk = np.max(np.abs(y)) or 1; y = y / max(pk / .89, 1)
    with wave.open(str(out_wav), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((y * 32767).astype("<i2").tobytes())
    return out_wav


def _decode(path):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "f32le", "-ac", "1", "-ar", str(SR), "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype="<f4").astype(np.float64)


def loudnorm(src, dst, target=-14.0, tp=-1.5, lra=11):
    """Two-pass EBU R128 normalisation; returns measured stats of the result."""
    flt = f"loudnorm=I={target}:TP={tp}:LRA={lra}"
    r = subprocess.run(["ffmpeg", "-hide_banner", "-i", str(src), "-af", flt + ":print_format=json", "-f", "null", "-"],
                       capture_output=True, text=True)
    m = json.loads(r.stderr[r.stderr.rindex("{"):r.stderr.rindex("}") + 1])
    flt2 = (flt + f":measured_I={m['input_i']}:measured_TP={m['input_tp']}:measured_LRA={m['input_lra']}"
            f":measured_thresh={m['input_thresh']}:offset={m['target_offset']}:linear=true")
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(src), "-af", flt2, "-ar", "44100", str(dst)], check=True)
    r = subprocess.run(["ffmpeg", "-hide_banner", "-i", str(dst), "-af", "ebur128=peak=true", "-f", "null", "-"], capture_output=True, text=True)
    summ = r.stderr[r.stderr.rindex("Summary:"):]
    return {"integrated_lufs": float(__import__("re").search(r"I:\s+(-?[\d.]+) LUFS", summ).group(1)),
            "true_peak_dbtp": float(__import__("re").search(r"Peak:\s+(-?[\d.]+) dBFS", summ).group(1))}
