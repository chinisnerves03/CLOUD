"""Blend recorded exhaust clips into one consistent-sounding TurboCraft sound set.

Usage: python3 blend_reference_audio.py RB26.wav 2JZ.wav DYNO.wav OUTDIR
Inputs are mono 44.1 kHz WAVs of the three author-supplied clips (see
docs/v1.0.0/AUDIO_PROVENANCE.md). Writes OUTDIR/demo.wav (one combined pass:
pull -> limiter + anti-lag -> lift-off bangs -> burble tail) and OUTDIR/set/*.wav
(matched one-shots with the mod's file names).

Matching steps, applied to every piece so the sources sound like one car/mic:
1. band-limit to the narrowest source (35 Hz - 11 kHz),
2. EQ each piece toward the average long-term spectrum of all pieces
   (1/3-octave, smoothed, clamped to +-8 dB),
3. loudness-normalise per role, 4. shared soft compression,
5. shared short room (synthetic 0.22 s IR) so all pieces sit in one space.
"""
import sys, wave
import numpy as np

SR = 44100
rng = np.random.default_rng(7)


def load(path):
    w = wave.open(path)
    assert w.getframerate() == SR and w.getnchannels() == 1
    return np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(np.float64) / 32768


def save(path, x):
    x = np.clip(x, -1, 1)
    w = wave.open(path, "wb")
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((x * 32767).astype(np.int16).tobytes())


def cut(x, start, dur):
    return x[int(start * SR):int((start + dur) * SR)].copy()


def fade(x, fin=0.004, fout=0.08):
    a, b = int(fin * SR), int(fout * SR)
    x[:a] *= np.linspace(0, 1, a)
    x[-b:] *= np.linspace(1, 0, b) ** 2
    return x


def spectrum_filter(x, gain_db_fn):
    n = 1 << int(np.ceil(np.log2(len(x) + 4096)))
    X = np.fft.rfft(x, n)
    f = np.fft.rfftfreq(n, 1 / SR)
    X *= 10 ** (gain_db_fn(f) / 20)
    return np.fft.irfft(X, n)[:len(x)]


def bandlimit(x):
    def g(f):
        hp = np.where(f < 35, -60, 0.0)
        lp = np.where(f > 11000, -12 * np.log2(np.maximum(f, 11000) / 11000) * 4, 0.0)
        return np.maximum(hp + lp, -80)
    return spectrum_filter(x, g)


BANDS = 1000 * 2 ** (np.arange(-17, 11) / 3)  # 1/3-octave centres ~20 Hz - 10 kHz


def ltas(x):
    n = 4096
    if len(x) < n:
        x = np.pad(x, (0, n - len(x)))
    fr = x[:len(x) // 1024 * 1024]
    fr = np.lib.stride_tricks.sliding_window_view(fr, n)[::1024] * np.hanning(n)
    P = (np.abs(np.fft.rfft(fr, axis=1)) ** 2).mean(0)
    f = np.fft.rfftfreq(n, 1 / SR)
    out = []
    for c in BANDS:
        m = (f >= c / 2 ** (1 / 6)) & (f < c * 2 ** (1 / 6))
        out.append(10 * np.log10(P[m].mean() + 1e-12) if m.any() else -120)
    out = np.array(out)
    return out - out[(BANDS > 300) & (BANDS < 3000)].mean()


def match(x, target):
    d = np.clip(target - ltas(x), -8, 8)
    d = np.convolve(np.pad(d, 1, mode="edge"), [0.25, 0.5, 0.25], "valid")
    lb = np.log2(BANDS)
    return spectrum_filter(x, lambda f: np.interp(np.log2(np.maximum(f, 1)), lb, d))


def rms_db(x):
    return 20 * np.log10(np.sqrt(np.mean(x ** 2)) + 1e-12)


def set_level(x, db):
    return x * 10 ** ((db - rms_db(x)) / 20)


def compress(x, thr_db=-18, ratio=3.0, att=0.003, rel=0.08):
    env = np.abs(x); a, r = np.exp(-1 / (att * SR)), np.exp(-1 / (rel * SR))
    e = np.empty_like(env); s = 0.0
    for i, v in enumerate(env):
        s = a * s + (1 - a) * v if v > s else r * s + (1 - r) * v
        e[i] = s
    lvl = 20 * np.log10(e + 1e-9)
    gain = np.where(lvl > thr_db, (thr_db - lvl) * (1 - 1 / ratio), 0)
    return x * 10 ** (gain / 20)


IR = None


def room(x, wet=0.12):
    global IR
    if IR is None:
        t = np.arange(int(0.22 * SR)) / SR
        IR = rng.standard_normal(len(t)) * np.exp(-t / 0.05)
        IR = bandlimit(IR); IR /= np.sqrt(np.sum(IR ** 2))
    n = 1 << int(np.ceil(np.log2(len(x) + len(IR))))
    y = np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(IR, n), n)[:len(x)]
    return (1 - wet) * x + wet * y


def place(bed, x, t):
    i = int(t * SR); j = min(len(bed), i + len(x))
    bed[i:j] += x[:j - i]


def xfade_concat(parts, xf=0.15):
    n = int(xf * SR); out = parts[0]
    for p in parts[1:]:
        k = np.linspace(0, np.pi / 2, n)
        mid = out[-n:] * np.cos(k) + p[:n] * np.sin(k)
        out = np.concatenate([out[:-n], mid, p[n:]])
    return out


def main(rb, jz, dy, outdir):
    import os
    rb, jz, dy = load(rb), load(jz), load(dy)
    # (name, source, start s, dur s, role)
    pieces = {
        "pull": (dy, 556.0, 3.6, "bed"),
        "limiter_whine_a": (rb, 2.00, 0.80, "bed"), "limiter_whine_b": (rb, 9.40, 0.80, "bed"),
        "limiter_bed": (rb, 1.90, 2.70, "bed"),
        "antilag_up_a": (rb, 3.98, 0.65, "crackle"), "antilag_up_b": (rb, 5.10, 0.65, "crackle"),
        "antilag_up_c": (rb, 6.28, 0.70, "crackle"),
        "bang_a": (jz, 25.20, 0.75, "bang"), "bang_b": (jz, 3.80, 0.75, "bang"),
        "bang_c": (dy, 560.20, 0.75, "bang"), "bang_d": (dy, 561.88, 0.75, "bang"),
        "pop_a": (jz, 2.00, 0.35, "pop"), "pop_b": (jz, 21.99, 0.35, "pop"),
        "pop_c": (jz, 22.93, 0.35, "pop"), "pop_d": (dy, 959.20, 0.35, "pop"),
        "burble_a": (dy, 477.5, 1.6, "burble"), "burble_b": (dy, 479.1, 1.6, "burble"),
        "burble_c": (dy, 480.7, 1.6, "burble"), "burble_tail": (dy, 477.5, 5.5, "burble"),
    }
    level = {"bed": -17, "crackle": -16, "bang": -12, "pop": -14, "burble": -18}
    raw = {k: bandlimit(cut(s, a, d)) for k, (s, a, d, _) in pieces.items()}
    target = np.mean([ltas(v) for v in raw.values()], axis=0)
    done = {}
    for k, v in raw.items():
        role = pieces[k][3]
        y = set_level(match(v, target), level[role])
        y = room(compress(y))
        done[k] = fade(y, fout=0.12 if role in ("bang", "pop") else 0.08)
    os.makedirs(f"{outdir}/set", exist_ok=True)
    for k, v in done.items():
        if k not in ("pull", "limiter_bed", "burble_tail", "bang_d"):
            save(f"{outdir}/set/{k}.wav", v / max(1, np.abs(v).max() / 0.79))

    # one combined pass
    done["burble_tail"] = fade(done["burble_tail"], fout=1.2)
    bed =xfade_concat([done["pull"], done["limiter_bed"], done["burble_tail"]], 0.18)
    bed = np.concatenate([bed, np.zeros(SR)])
    t_lim = len(done["pull"]) / SR - 0.18
    t_lift = t_lim + len(done["limiter_bed"]) / SR - 0.18
    for name, t in [("antilag_up_a", 0.35), ("antilag_up_c", 1.15), ("antilag_up_b", 1.85)]:
        place(bed, done[name] * 0.8, t_lim + t)
    for name, dt in [("bang_c", 0.0), ("pop_a", 0.32), ("bang_a", 0.55), ("pop_c", 0.95),
                     ("bang_d", 1.25), ("pop_b", 1.7), ("bang_b", 2.1), ("pop_d", 2.6)]:
        place(bed, done[name], t_lift + dt)
    bed = compress(bed, thr_db=-14, ratio=2.5)
    bed *= 0.89 / np.abs(bed).max()
    save(f"{outdir}/demo.wav", bed)
    print("demo", round(len(bed) / SR, 2), "s; set", len(os.listdir(f"{outdir}/set")), "files")


if __name__ == "__main__":
    main(*sys.argv[1:5])
