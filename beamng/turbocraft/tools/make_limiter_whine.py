# Original synthesis (CC0): rev-limiter whine, a rising buzzy "yin" with a slight flutter.
import hashlib, sys, wave
import numpy as np

RATE, DUR = 44100, 0.8

def whine(f0, f1, flutter_hz, flutter_depth, seed):
    rng = np.random.default_rng(seed)
    n = int(RATE * DUR)
    t = np.arange(n) / RATE
    sweep = f0 * (f1 / f0) ** (t / DUR)
    sweep *= 1 + flutter_depth * np.sin(2 * np.pi * flutter_hz * t)
    phase = 2 * np.pi * np.cumsum(sweep) / RATE
    buzz = sum(np.sin(k * phase) / k for k in range(1, 7))
    hiss = np.convolve(rng.standard_normal(n), np.ones(4) / 4, mode="same")
    tone = buzz + 0.04 * hiss
    attack = np.minimum(1, t / 0.02)
    decay = (1 - t / DUR) ** 0.6
    x = tone * attack * decay
    return x / np.max(np.abs(x)) * 0.5

def write(path, x):
    pcm = (np.clip(x, -1, 1) * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        w.writeframes(pcm.tobytes())
    return hashlib.sha256(open(path, "rb").read()).hexdigest().upper()

out = sys.argv[1]
for name, args in {"limiter_whine_a": (1100, 2600, 24, 0.015, 1),
                   "limiter_whine_b": (1400, 3000, 30, 0.02, 2)}.items():
    x = whine(*args[:4], seed=args[4])
    digest = write(f"{out}/{name}.wav", x)
    print(name, digest, float(np.max(np.abs(x))), float(np.sqrt(np.mean(x**2))))
