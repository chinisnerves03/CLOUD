#!/usr/bin/env python3
"""Clip 19: remake of the fortune-teller POV with a frame-0 hook (everything visible at t=0, voice from 0.05s)."""
import re, wave
import numpy as np
src = open('/home/user/CLOUD/ai-ladmue/clips/c16/build.py', encoding='utf-8').read()
exec(src[src.index('def robot('):src.index('scenes = {}')])

W, H, DUR = 1080, 1920, 20.6
SC = [('a', 0.0, 3.4), ('b', 3.4, 7.1), ('c', 7.1, 11.6), ('d', 11.6, 15.2), ('e', 15.2, DUR)]
S = {k: (x, y) for k, x, y in SC}
VOICES = [('v1', 0.05, 3.24), ('v2', 3.5, 3.47), ('v3', 7.3, 4.21), ('v4', 11.7, 3.32), ('v5', 15.3, 4.83)]
HEAD = {'a': 'หมอดูทัก<br>เงินจะหาย!', 'b': 'แก้เคล็ด!', 'c': '1 เดือนต่อมา...', 'd': 'ผลลัพธ์:'}
CAP = {'a': 'หมอดูทักว่าเดือนนี้เงินจะหาย! ผมเลยรีบแก้เคล็ด!', 'b': 'เครื่องราง! ผ้ายันต์! กำไลนำโชค! ชุดเสริมดวง!',
       'c': 'ผ่านไปหนึ่งเดือน... เงินหายจริง เจ็ดพันกว่าบาท!', 'd': 'หมอดูแม่นมาก... แต่ผมทำหายเอง'}
FACE = {'a': 'worried', 'b': 'happy', 'c': 'dazed', 'd': 'dazed'}
def cam(sid):
    return f'<div class="cam" id="{sid}-cam"><div class="camin">{robot(FACE[sid], uid=sid + "c")}</div><div class="rec">REC</div></div>'
def phone(inner, sid):
    return f'<div class="phone" id="{sid}-ph"><div class="notch"></div><div class="screen">{inner}</div></div>'
bal = lambda sid, txt, col='#1fae6a': f'<div class="balbox" id="{sid}-bal"><div class="bl">ยอดเงินคงเหลือ</div><div class="bv" id="{sid}-bv" style="color:{col}">{txt}</div></div>'
ball = """<svg width="300" height="330" viewBox="0 0 300 330"><ellipse cx="150" cy="300" rx="110" ry="24" fill="#4b2c7a"/><path d="M80 290 L100 250 L200 250 L220 290 Z" fill="#6a3fb0"/><circle cx="150" cy="150" r="110" fill="#b79cff" opacity=".85"/><circle cx="150" cy="150" r="110" fill="none" stroke="#e8dcff" stroke-width="6"/><ellipse cx="110" cy="100" rx="30" ry="18" fill="#fff" opacity=".5"/><path d="M95 160 Q130 120 160 170 Q190 120 210 150" stroke="#fff" stroke-width="7" fill="none" opacity=".8" stroke-linecap="round"/></svg>"""
sc = {}
sc['a'] = phone(f'<div class="app">หมอดูออนไลน์</div><div class="pos2" id="a-ball" style="left:300px;top:150px">{ball}</div><div class="bubble" id="a-bub">เดือนนี้ ระวังเงินหายนะลูก</div>' + bal('a', '฿12,480'), 'a')
items = [('เครื่องรางกันเงินหาย', '฿1,999', '#ffd23f'), ('ผ้ายันต์ขนาดใหญ่', '฿899', '#ff7ab8'), ('กำไลนำโชค', '฿2,499', '#4ad2ff'), ('ชุดเสริมดวงครบเซ็ต', '฿1,999', '#9dff7a')]
rows = ''.join(f'<div class="row" id="b-r{i}"><span class="dot" style="background:{c}"></span><span class="nm">{n}</span><span class="pr">{p}</span></div>' for i, (n, p, c) in enumerate(items))
sc['b'] = phone('<div class="app">ช้อปแก้เคล็ด</div>' + bal('b', '฿12,480') + f'<div class="rows">{rows}</div>', 'b')
sc['c'] = phone('<div class="app">ปฏิทิน</div><div class="cal" id="c-cal"><div class="calm">+1 เดือน</div></div>' + bal('c', '฿5,084', '#d62839') + '<div class="down c" id="c-dn">▼ -฿7,396</div>', 'c')
sc['d'] = phone('<div class="app">แอปธนาคาร</div>' + bal('d', '฿5,084', '#d62839') + '<div class="stamp big" id="d-st">หมอดูแม่นมาก</div>', 'd')
html = ''
for sid, a, b in SC:
    if sid == 'e':
        body = f"""<div class="bg2"></div>
<div class="pos2" id="e-a" style="left:40px;top:640px;transform:scale(1.15);transform-origin:0 0">{robot('happy', uid='ea')}</div>
<div class="pos2" id="e-b" style="left:650px;top:660px;transform:scale(1.15);transform-origin:0 0">{teal('happy', 'eb')}</div>
<div class="card" id="e-c1" style="top:230px">อยากวางแผนเงินเอง<br>ไม่ต้องพึ่งหมอดู?</div>
<div class="card cta" id="e-c3" style="top:1130px">คอมเมนต์คำว่า<br><span class="kw">prompt</span><br><small>รับชุดคำสั่งฟรี</small></div>"""
    else:
        body = f'<div class="bg2"></div><div class="head big" id="{sid}-hd">{HEAD[sid]}</div>{sc[sid]}{cam(sid)}<div class="cap" id="{sid}-cap">{CAP[sid]}</div>'
    html += f'<section id="sc-{sid}" class="clip sc" data-start="{a}" data-duration="{round(b-a,2)}" data-track-index="1">{body}</section>\n'
audio = ''.join(f'<audio id="{n}" src="assets/{n}.mp3" data-start="{st}" data-duration="{d+0.06:.2f}" data-track-index="{10+i}" data-volume="1"></audio>\n' for i, (n, st, d) in enumerate(VOICES))
audio += f'<audio id="bgm" src="assets/bgm.wav" data-start="0" data-duration="{DUR}" data-track-index="30" data-volume="0.5"></audio>\n<audio id="sfx" src="assets/sfx.wav" data-start="0" data-duration="{DUR}" data-track-index="31" data-volume="1"></audio>\n'
js = []
def pop(sel, t, d=0.3): js.append(f'tl.from("{sel}",{{scale:0.2,opacity:0,rotation:-6,duration:{d},ease:"back.out(2)",transformOrigin:"50% 50%"}},{t:.2f});')
# scene A: fully visible at t=0, only small motion
js.append('tl.to("#a-ball",{y:-14,duration:0.4,yoyo:true,repeat:7,ease:"sine.inOut"},0.1);tl.to("#a-bal",{x:10,duration:0.05,yoyo:true,repeat:39,ease:"none"},0.2);tl.to("#a-hd",{scale:1.05,duration:0.25,yoyo:true,repeat:11,ease:"sine.inOut",transformOrigin:"50% 50%"},0.1);')
for sid, a, b in SC[1:4]:
    js.append(f'tl.from("#{sid}-hd",{{y:-80,opacity:0,duration:0.25,ease:"power3.out"}},{a+0.02:.2f});tl.from("#{sid}-ph",{{y:120,opacity:0,duration:0.3,ease:"power3.out"}},{a+0.03:.2f});tl.from("#{sid}-cap",{{y:50,opacity:0,duration:0.3,ease:"power3.out"}},{a+0.1:.2f});')
js.append('tl.to("#acbody",{y:-10,duration:0.3,yoyo:true,repeat:9,ease:"sine.inOut"},0.1);' if False else '')
for sid, a, b in SC[:4]:
    js.append(f'tl.to("#{sid}c-body",{{y:-10,duration:0.3,yoyo:true,repeat:{max(1,int((b-a)/0.3/2)-1)},ease:"sine.inOut"}},{a+0.1:.2f});')
# B: shopping, quick
a = S['b'][0]
js.append('const balb={v:12480};')
price = [1999, 899, 2499, 1999]; cur = 12480
for i, p in enumerate(price):
    t = a + 0.25 + i * 0.8; cur -= p
    js.append(f'tl.from("#b-r{i}",{{x:700,opacity:0,duration:0.25,ease:"power3.out"}},{t:.2f});')
    js.append(f'tl.to(balb,{{v:{cur},duration:0.3,ease:"power1.out",onUpdate:function(){{document.getElementById("b-bv").textContent="฿"+Math.round(balb.v).toLocaleString("en-US")}}}},{t+0.08:.2f});')
js.append(f'tl.to("#b-bv",{{color:"#d62839",duration:0.3}},{a+1.0:.2f});')
a = S['c'][0]
js.append(f'tl.from("#c-cal",{{rotationX:90,opacity:0,duration:0.4,ease:"back.out(1.6)",transformOrigin:"50% 0"}},{a+0.15:.2f});tl.from("#c-bal",{{y:150,opacity:0,duration:0.3}},{a+0.9:.2f});tl.from("#c-dn",{{y:-60,opacity:0,duration:0.3,ease:"bounce.out"}},{a+1.6:.2f});tl.to("#c-bal",{{x:10,duration:0.05,yoyo:true,repeat:19,ease:"none"}},{a+1.7:.2f});')
a = S['d'][0]
js.append(f'tl.from("#d-st",{{scale:3,opacity:0,rotation:-25,duration:0.3,ease:"power4.in"}},{a+0.9:.2f});tl.to("#d-bal",{{x:8,duration:0.06,yoyo:true,repeat:9,ease:"none"}},{a+0.5:.2f});')
a = S['e'][0]
js.append(f'tl.from("#e-a",{{x:-400,opacity:0,duration:0.4,ease:"back.out(1.4)"}},{a+0.05:.2f});tl.from("#e-b",{{x:400,opacity:0,duration:0.4,ease:"back.out(1.4)"}},{a+0.12:.2f});tl.fromTo("#e-c1",{{opacity:0,scale:0.3}},{{opacity:1,scale:1,duration:0.3,ease:"back.out(2)"}},{a+0.1:.2f});tl.fromTo("#e-c3",{{opacity:0,y:120}},{{opacity:1,y:0,duration:0.35,ease:"power3.out"}},{a+1.8:.2f});')
js.append(f'tl.to("#ea-body",{{y:-16,duration:0.35,yoyo:true,repeat:13,ease:"sine.inOut"}},{a+0.5:.2f});tl.to("#eb-body",{{y:-16,duration:0.35,yoyo:true,repeat:13,ease:"sine.inOut"}},{a+0.6:.2f});')
CSS = '''
@font-face{font-family:P;font-weight:700;src:url(assets/prompt-thai-700-normal.woff2)}
@font-face{font-family:P;font-weight:800;src:url(assets/prompt-thai-800-normal.woff2)}
*{box-sizing:border-box;margin:0}
body{margin:0;background:#000;font-family:P,sans-serif}
#root{position:relative;width:1080px;height:1920px;overflow:hidden;background:#000}
.sc{position:absolute;left:0;top:0;width:1080px;height:1920px;overflow:hidden}
.bg2{position:absolute;inset:0;background:radial-gradient(ellipse at 30% 20%,#3a2a6a,#150f2c 70%)}
.pos2{position:absolute}
.head{position:absolute;left:40px;right:40px;top:90px;text-align:center;font-weight:800;font-size:76px;line-height:1.2;color:#fff;text-shadow:6px 6px 0 #000,-3px -3px 0 #000,3px -3px 0 #000,-3px 3px 0 #000}
.phone{position:absolute;left:110px;top:330px;width:860px;height:1010px;border-radius:90px;background:#f4f6fa;border:16px solid #0d0d12;box-shadow:0 30px 60px #0008;overflow:hidden}
.notch{position:absolute;left:50%;top:14px;width:200px;height:34px;margin-left:-100px;background:#0d0d12;border-radius:20px;z-index:5}
.screen{position:absolute;inset:0;padding-top:70px}
.app{text-align:center;font-weight:800;font-size:48px;color:#3a2a6a;padding:14px}
.balbox{position:absolute;left:50px;right:50px;top:720px;background:#fff;border-radius:40px;padding:26px 40px;box-shadow:0 8px 0 #0002;border:4px solid #e0e4f0}
.bl{font-size:34px;color:#667;font-weight:700}.bv{font-size:104px;font-weight:800;color:#1fae6a;line-height:1.15}
.bubble{position:absolute;left:60px;right:60px;top:530px;text-align:center;font-weight:800;font-size:52px;color:#fff;background:#6a3fb0;border-radius:36px;padding:20px}
.alert{position:absolute;left:50px;right:50px;top:130px;background:#ffe2e2;border:6px solid #d62839;border-radius:30px;padding:20px;text-align:center;font-weight:800;font-size:48px;color:#d62839}
.shield{position:absolute;left:290px;top:330px}
.rows{position:absolute;left:30px;right:30px;top:130px}
.row{display:flex;align-items:center;background:#fff;border-radius:28px;border:4px solid #e0e4f0;margin-bottom:18px;padding:18px 24px;font-size:42px;font-weight:700;color:#222;box-shadow:0 6px 0 #0001}
.dot{width:56px;height:56px;border-radius:16px;margin-right:22px;border:4px solid #222;flex:none}
.nm{flex:1}.pr{font-weight:800;color:#d62839}
.okc{position:absolute;left:280px;top:130px}
.okt{position:absolute;left:0;right:0;top:470px;text-align:center;font-weight:800;font-size:64px;color:#1fae6a}
.tot{position:absolute;left:0;right:0;top:570px;text-align:center;font-weight:800;font-size:120px;color:#d62839}
.stamp{position:absolute;left:100px;top:780px;font-weight:800;font-size:60px;color:#d62839;border:10px solid #d62839;border-radius:20px;padding:6px 26px;transform:rotate(-8deg);background:#fff}
.stamp.big{top:430px;left:90px;font-size:84px}
.down{position:absolute;left:0;right:0;top:230px;text-align:center;font-weight:800;font-size:110px;color:#d62839}
.cam{position:absolute;left:50px;top:1420px;width:360px;height:360px;border-radius:50px;border:10px solid #fff;box-shadow:8px 8px 0 #000;overflow:hidden;background:linear-gradient(#5b3fa8,#2a1c55)}
.camin{position:absolute;left:25px;top:20px;transform:scale(1.05);transform-origin:0 0}
.rec{position:absolute;right:16px;top:12px;font-family:monospace;font-weight:800;font-size:32px;color:#fff;background:#d62839;padding:0 12px;border-radius:10px}
.cap{position:absolute;left:440px;right:40px;top:1440px;font-weight:800;font-size:60px;line-height:1.25;color:#fff;text-shadow:5px 5px 0 #000,-3px -3px 0 #000,3px -3px 0 #000,-3px 3px 0 #000}
.card{position:absolute;left:60px;right:60px;text-align:center;font-weight:800;font-size:84px;line-height:1.25;padding:26px 20px;background:#ffd23f;color:#000;border:10px solid #000;box-shadow:12px 12px 0 #000}
.card.cta{background:#ff3d81;color:#fff;font-size:64px}
.card small{font-size:48px;font-weight:700}
.kw{display:inline-block;background:#fff;color:#000;border:8px solid #000;padding:0 24px;margin:12px 0;font-size:70px}
'''
extra = '.cal{position:absolute;left:100px;right:100px;top:130px;height:300px;background:#fff;border:8px solid #d62839;border-radius:30px;display:flex;align-items:center;justify-content:center}.calm{font-weight:800;font-size:110px;color:#d62839}.head.big{font-size:104px;top:80px;line-height:1.1}.phone{top:400px!important;height:960px!important}.down.c{top:470px!important}.balbox{top:650px!important}'
out = f"""<!doctype html>
<html lang="th"><head><meta charset="UTF-8"/><meta name="viewport" content="width=1080, height=1920"/><title>POV fortune v3</title>
<script src="assets/gsap.min.js"></script><style>{CSS}{extra}</style></head>
<body><div id="root" data-composition-id="main" data-width="{W}" data-height="{H}" data-duration="{DUR}">
{html}{audio}</div>
<script>
window.__timelines = window.__timelines || {{}};
const tl = gsap.timeline({{ paused: true }});
{chr(10).join(js)}
window.__timelines["main"] = tl;
</script></body></html>
"""
open('/home/user/CLOUD/ai-ladmue/clips/c19/hf/index.html', 'w', encoding='utf-8').write(out)
SR = 44100; N = int(SR * DUR)
rs = np.random.RandomState(7)
X = np.zeros(N)
def tone(f0, d, w='sin', f1=None, env=8.0, vol=1.0):
    n = int(SR * d); t = np.arange(n) / SR
    f = f0 if f1 is None else f0 + (f1 - f0) * (t / d)
    ph = np.cumsum(np.ones(n) * f) / SR
    y = np.sin(2 * np.pi * ph) if w == 'sin' else (2 * (ph % 1) - 1 if w == 'saw' else np.where((ph % 1) < 0.5, 1.0, -1.0))
    return y * np.exp(-t * env) * vol
def noise(d, env=20, lp=1, vol=1.0):
    n = int(SR * d); y = rs.uniform(-1, 1, n)
    if lp > 1: y = np.convolve(y, np.ones(lp) / lp, mode='same')
    return y * np.exp(-np.arange(n) / SR * env) * vol
def put(x, at, v=1.0):
    i = int(at * SR)
    if i >= N: return
    m = min(len(x), N - i); X[i:i + m] += x[:m] * v
def add(*xs):
    n = max(len(x) for x in xs); o = np.zeros(n)
    for x in xs: o[:len(x)] += x
    return o
def ding(at, f=1318): put(add(tone(f, 0.5, env=6, vol=0.5), tone(f * 2, 0.35, env=9, vol=0.2)), at)
def chaching(at):
    put(add(noise(0.05, env=60, lp=2, vol=0.5), tone(2093, 0.12, env=12, vol=0.4)), at); put(tone(3136, 0.35, env=7, vol=0.4), at + 0.09)
def womp(at):
    x = 0
    for f, d in [(233, 0.22), (220, 0.22), (208, 0.22), (185, 0.7)]:
        put(np.convolve(tone(f, d, 'saw', env=1.5, vol=0.5), np.ones(5) / 5, mode='same'), at + x); x += d

for i, f in enumerate([2093, 2637, 3136]): put(tone(f, 0.25, env=8, vol=0.4), 0.0 + i * 0.05)   # stinger on frame 0
for i, t in enumerate([3.65, 4.45, 5.25, 6.05]): chaching(t)
put(noise(0.35, env=7, lp=40, vol=0.5) * np.linspace(0.2, 1, int(SR * 0.35)), 7.1)
put(tone(1800, 0.28, 'saw', f1=250, env=4, vol=0.45), 9.0); womp(9.35)
put(noise(0.2, env=18, lp=8, vol=0.6), 12.5); put(noise(0.3, env=8, lp=30, vol=0.4), 11.6)
ding(15.2, 1175); ding(17.0, 1760)
X = np.tanh(X)
pcm = (np.clip(X, -1, 1) * 30000).astype('<i2')
with wave.open('/home/user/CLOUD/ai-ladmue/clips/c19/hf/assets/sfx.wav', 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
print('ok')
