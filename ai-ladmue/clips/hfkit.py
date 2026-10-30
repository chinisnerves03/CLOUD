"""Shared helpers for HyperFrames clips (robots as inline SVG, synthesized SFX, composition writer)."""
import wave
import numpy as np

_src = open('/home/user/CLOUD/ai-ladmue/clips/c16/build.py', encoding='utf-8').read()
_def = _src[_src.index('def robot('):_src.index('scenes = {}')]
_def = _def.replace("eyes = {\n", "eyes = {\n        'angry': '<ellipse cx=\"112\" cy=\"136\" rx=\"22\" ry=\"18\" fill=\"#ff6a6a\"/><ellipse cx=\"188\" cy=\"136\" rx=\"22\" ry=\"18\" fill=\"#ff6a6a\"/><path d=\"M82 96 L136 118 M218 96 L164 118\" stroke=\"#ff6a6a\" stroke-width=\"11\" stroke-linecap=\"round\"/>',\n", 1)
_def = _def.replace("mouth = {\n", "mouth = {\n        'angry': '<path d=\"M120 190 Q150 168 180 190\" stroke=\"#ff7aa2\" stroke-width=\"9\" stroke-linecap=\"round\" fill=\"none\"/>',\n", 1)
exec(_def, globals())

SR = 44100


class Sfx:
    def __init__(self, dur):
        self.dur = dur; self.N = int(SR * dur); self.X = np.zeros(self.N); self.rs = np.random.RandomState(3)

    def tone(self, f0, d, w='sin', f1=None, env=8.0, vol=1.0):
        n = int(SR * d); t = np.arange(n) / SR
        f = f0 if f1 is None else f0 + (f1 - f0) * (t / d)
        ph = np.cumsum(np.ones(n) * f) / SR
        y = np.sin(2 * np.pi * ph) if w == 'sin' else (2 * (ph % 1) - 1 if w == 'saw' else np.where((ph % 1) < 0.5, 1.0, -1.0))
        return y * np.exp(-t * env) * vol

    def noise(self, d, env=20, lp=1, vol=1.0):
        n = int(SR * d); y = self.rs.uniform(-1, 1, n)
        if lp > 1: y = np.convolve(y, np.ones(lp) / lp, mode='same')
        return y * np.exp(-np.arange(n) / SR * env) * vol

    @staticmethod
    def add(*xs):
        n = max(len(x) for x in xs); o = np.zeros(n)
        for x in xs: o[:len(x)] += x
        return o

    def put(self, x, at, v=1.0):
        i = int(at * SR)
        if i >= self.N: return
        m = min(len(x), self.N - i); self.X[i:i + m] += x[:m] * v

    def ding(self, at, f=1318): self.put(self.add(self.tone(f, 0.5, env=6, vol=0.5), self.tone(f * 2, 0.35, env=9, vol=0.2)), at)
    def whoosh(self, at, d=0.35): self.put(self.noise(d, env=7, lp=40, vol=0.55) * np.linspace(0.2, 1, int(SR * d)), at)
    def thud(self, at): self.put(self.add(self.tone(80, 0.5, env=7, vol=0.9), self.noise(0.18, env=20, lp=6, vol=0.5)), at)
    def pop(self, at, f=700): self.put(self.tone(f, 0.12, f1=f * 1.8, env=18, vol=0.4), at)
    def scratch(self, at): self.put(self.tone(1800, 0.28, 'saw', f1=250, env=4, vol=0.45), at)
    def chaching(self, at):
        self.put(self.add(self.noise(0.05, env=60, lp=2, vol=0.5), self.tone(2093, 0.12, env=12, vol=0.4)), at); self.put(self.tone(3136, 0.35, env=7, vol=0.4), at + 0.09)

    def womp(self, at):
        x = 0
        for f, d in [(233, 0.22), (220, 0.22), (208, 0.22), (185, 0.7)]:
            self.put(np.convolve(self.tone(f, d, 'saw', env=1.5, vol=0.5), np.ones(5) / 5, mode='same'), at + x); x += d

    def save(self, path):
        pcm = (np.clip(np.tanh(self.X), -1, 1) * 30000).astype('<i2')
        with wave.open(path, 'wb') as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())


BASE_CSS = '''
@font-face{font-family:P;font-weight:700;src:url(assets/prompt-thai-700-normal.woff2)}
@font-face{font-family:P;font-weight:800;src:url(assets/prompt-thai-800-normal.woff2)}
*{box-sizing:border-box;margin:0}
body{margin:0;background:#000;font-family:P,sans-serif}
#root{position:relative;width:1080px;height:1920px;overflow:hidden;background:#000}
.sc{position:absolute;left:0;top:0;width:1080px;height:1920px;overflow:hidden}
.bg{position:absolute;inset:0}
.ab{position:absolute}
'''


def write_index(path, title, css, sections, audio, js, dur):
    out = f'''<!doctype html>
<html lang="th"><head><meta charset="UTF-8"/><meta name="viewport" content="width=1080, height=1920"/><title>{title}</title>
<script src="assets/gsap.min.js"></script><style>{BASE_CSS}{css}</style></head>
<body><div id="root" data-composition-id="main" data-width="1080" data-height="1920" data-duration="{dur}">
{sections}{audio}</div>
<script>
window.__timelines = window.__timelines || {{}};
const tl = gsap.timeline({{ paused: true }});
{chr(10).join(js)}
window.__timelines["main"] = tl;
</script></body></html>
'''
    open(path, 'w', encoding='utf-8').write(out)


def section(sid, a, b, body, track=1):
    return f'<section id="sc-{sid}" class="clip sc" data-start="{a}" data-duration="{round(b - a, 2)}" data-track-index="{track}">{body}</section>\n'


def audio_el(i, name, start, dur, vol=1, track=None):
    track = track if track is not None else 10 + i
    return f'<audio id="{name}" src="assets/{name}.mp3" data-start="{start}" data-duration="{dur + 0.06:.2f}" data-track-index="{track}" data-volume="{vol}"></audio>\n'


def bed_audio(dur, bgm_vol=0.45):
    return (f'<audio id="bgm" src="assets/bgm.wav" data-start="0" data-duration="{dur}" data-track-index="30" data-volume="{bgm_vol}"></audio>\n'
            f'<audio id="sfx" src="assets/sfx.wav" data-start="0" data-duration="{dur}" data-track-index="31" data-volume="1"></audio>\n')


# ---------------- After-Effects-style helpers ----------------
import random as _random
import os as _os

_COMB = set(chr(c) for c in list(range(0x0E31, 0x0E32)) + list(range(0x0E34, 0x0E3B)) + list(range(0x0E47, 0x0E4F)) + [0x0E33])
_LEAD = set('เแโใไ')


def clusters(s):
    out = []; pend = ''
    for c in s:
        if c in _COMB and out:
            out[-1] += c
        elif c in _LEAD:
            pend += c
        else:
            out.append(pend + c); pend = ''
    if pend: out.append(pend)
    return out


def chars(s, cls=''):
    """text -> inline-block grapheme spans (for per-letter stagger)."""
    return ''.join(f'<span class="ch {cls}">{c if c != " " else "&nbsp;"}</span>' for c in clusters(s))


def make_grain(path, seed=2):
    from PIL import Image
    import numpy as np
    rs = np.random.RandomState(seed)
    a = rs.randint(0, 255, (512, 512), dtype='uint8')
    img = Image.fromarray(a, 'L').convert('RGBA')
    img.putalpha(Image.fromarray(rs.randint(40, 120, (512, 512), dtype='uint8'), 'L'))
    img.save(path)


AE_CSS = '''
.ch{display:inline-block;white-space:pre;will-change:transform}
.cam{position:absolute;left:0;top:0;width:1080px;height:1920px;transform-origin:50% 50%}
#ovl{position:absolute;left:0;top:0;width:1080px;height:1920px;pointer-events:none}
#grain{position:absolute;left:-200px;top:-300px;width:1500px;height:2500px;background-image:url(assets/grain.png);background-size:512px 512px;opacity:.16;mix-blend-mode:overlay}
#vig{position:absolute;inset:0;background:radial-gradient(ellipse at 50% 45%,transparent 52%,rgba(0,0,0,.55) 100%)}
#leak{position:absolute;left:-700px;top:-300px;width:900px;height:2600px;background:linear-gradient(90deg,transparent,rgba(255,120,60,.55),rgba(255,60,120,.35),transparent);mix-blend-mode:screen;opacity:0;transform:rotate(14deg)}
#flash{position:absolute;inset:0;background:#fff;opacity:0}
.wipe{position:absolute;top:-200px;height:2400px;width:1500px;transform:skewX(-14deg);left:-1700px}
'''


def ae_overlay_html(colors=('#ff3b30', '#ffd60a', '#111')):
    wipes = ''.join(f'<div class="wipe w{i}" style="background:{c}"></div>' for i, c in enumerate(colors))
    return f'<section id="sc-ovl" class="clip sc" data-start="0" data-duration="__DUR__" data-track-index="5" style="pointer-events:none"><div id="ovl"><div id="leak"></div><div id="vig"></div><div id="grain"></div>{wipes}<div id="flash"></div></div></section>\n'


def ae_overlay_js(dur, cuts, seed=5):
    """grain jitter at 12 fps, light-leak sweeps, white flash + colour-bar wipe on every cut."""
    r = _random.Random(seed); js = []
    for k in range(int(dur * 12)):
        js.append(f'tl.set("#grain",{{x:{r.randint(-150,0)},y:{r.randint(-250,0)}}},{k/12:.3f});')
    for i, c in enumerate(cuts):
        js.append(f'tl.set("#flash",{{opacity:0.7}},{c:.2f});tl.to("#flash",{{opacity:0,duration:0.22,ease:"power2.out"}},{c+0.001:.2f});')
        t0 = max(0.0, c - 0.2)
        js.append(f'tl.set("#leak",{{x:0,opacity:0.9}},{t0:.2f});tl.to("#leak",{{x:1900,duration:0.9,ease:"power2.inOut"}},{t0+0.001:.2f});tl.set("#leak",{{opacity:0}},{t0+0.95:.2f});')
    return js


def cam_js(sid, a, b, rot=0.8, push=0.07):
    return [f'tl.fromTo("#cam-{sid}",{{scale:1.0,rotation:{-rot}}},{{scale:{1+push},rotation:{rot},duration:{b-a:.2f},ease:"none"}},{a:.2f});']


def punch_js(sel, t, amt=0.05):
    return [f'tl.to("{sel}",{{scale:{1+amt},duration:0.07,ease:"power2.out"}},{t:.2f});tl.to("{sel}",{{scale:1,duration:0.35,ease:"elastic.out(1,0.4)"}},{t+0.07:.2f});']


def particles_html(n, seed, sid, colors=('#fff', '#ffd60a', '#29e5ff'), area=(0, 0, 1080, 1920)):
    r = _random.Random(seed); out = ''
    for i in range(n):
        x = r.randint(area[0], area[2]); y = r.randint(area[1], area[3]); s = r.randint(5, 16); c = r.choice(colors)
        out += f'<i class="pt pt-{sid}" style="left:{x}px;top:{y}px;width:{s}px;height:{s}px;background:{c};opacity:{r.uniform(.25,.8):.2f}"></i>'
    return out


def particles_js(sid, a, b, seed):
    r = _random.Random(seed + 9)
    return [f'tl.fromTo(".pt-{sid}",{{y:0}},{{y:-420,duration:{b-a:.2f},ease:"none",stagger:{{each:0.015}}}},{a:.2f});']
