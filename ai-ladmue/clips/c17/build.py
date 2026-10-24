#!/usr/bin/env python3
"""Clip 17: POV fortune teller - phone screen recording + reaction cam. Builds hf/index.html and hf/assets/sfx.wav."""
import re, wave
import numpy as np

# reuse the robot() SVG helper from clip 16
src = open('/home/user/CLOUD/ai-ladmue/clips/c16/build.py', encoding='utf-8').read()
a = src.index('def robot(')
b = src.index('scenes = {}')
exec(src[a:b])

W, H, DUR = 1080, 1920, 26.5
SC = [('s1', 0.0, 3.7), ('s2', 3.7, 6.1), ('s3', 6.1, 10.8), ('s4', 10.8, 13.9), ('s5', 13.9, 18.9), ('s6', 18.9, DUR)]
S = {k: (x, y) for k, x, y in SC}
VOICES = [('a', 0.3, 3.24), ('b', 3.8, 2.19), ('c', 6.2, 4.44), ('d', 10.9, 2.77), ('e', 14.0, 4.68), ('f', 19.0, 7.0)]

HEAD = {
    's1': 'POV: หมอดูทักว่า<br>เดือนนี้เงินจะหาย',
    's2': 'POV: หมอดูทักว่า<br>เดือนนี้เงินจะหาย',
    's3': 'me: ป้องกันไว้ก่อน',
    's4': 'me: ป้องกันไว้ก่อน',
    's5': 'ผลลัพธ์:',
}
CAP = {
    's1': 'หมอดู: เดือนนี้... ระวังเงินหายนะลูก',
    's2': 'ไม่ได้! ต้องรีบป้องกัน!',
    's3': 'ซื้อเครื่องรางกันเงินหาย! ผ้ายันต์! กำไลนำโชค!',
    's4': 'เรียบร้อย! เงินไม่หายแน่นอน!',
    's5': 'หมอดูแม่นมาก เงินหายจริง... แต่ผมเป็นคนทำหายเอง',
}
FACE = {'s1': 'worried', 's2': 'worried', 's3': 'happy', 's4': 'proud', 's5': 'dazed'}


def cam(sid):
    return f'<div class="cam" id="{sid}-cam"><div class="camin">{robot(FACE[sid], uid=sid + "c")}</div><div class="rec">REC</div></div>'


def phone(inner, sid):
    return f'<div class="phone" id="{sid}-ph"><div class="notch"></div><div class="screen">{inner}</div></div>'


bal = lambda sid, txt: f'<div class="balbox" id="{sid}-bal"><div class="bl">ยอดเงินคงเหลือ</div><div class="bv" id="{sid}-bv">{txt}</div></div>'

ball = '''<svg width="300" height="330" viewBox="0 0 300 330"><ellipse cx="150" cy="300" rx="110" ry="24" fill="#4b2c7a"/><path d="M80 290 L100 250 L200 250 L220 290 Z" fill="#6a3fb0"/><circle cx="150" cy="150" r="110" fill="#b79cff" opacity=".85"/><circle cx="150" cy="150" r="110" fill="none" stroke="#e8dcff" stroke-width="6"/><ellipse cx="110" cy="100" rx="30" ry="18" fill="#fff" opacity=".5"/><path d="M95 160 Q130 120 160 170 Q190 120 210 150" stroke="#fff" stroke-width="7" fill="none" opacity=".8" stroke-linecap="round"/></svg>'''
sc = {}
sc['s1'] = phone(f'<div class="app">หมอดูออนไลน์</div><div class="pos2" id="s1-ball" style="left:300px;top:160px">{ball}</div>'
                 f'<div class="bubble" id="s1-bub">เดือนนี้... ระวังเงินหายนะลูก</div>' + bal('s1', '฿12,480'), 's1')
sc['s2'] = phone('<div class="app">แอปธนาคาร</div>' + bal('s2', '฿12,480') +
                 '<div class="alert" id="s2-al">แจ้งเตือนดวง: เงินอาจหาย!</div>'
                 '<div class="shield" id="s2-sh"><svg width="260" height="300" viewBox="0 0 260 300"><path d="M130 10 L240 50 L240 150 Q240 250 130 290 Q20 250 20 150 L20 50 Z" fill="#2fc4b8" stroke="#0b6b64" stroke-width="12"/><path d="M80 150 L120 195 L190 105" stroke="#fff" stroke-width="22" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg></div>', 's2')
items = [('เครื่องรางกันเงินหาย', '฿1,999', '#ffd23f'), ('ผ้ายันต์ขนาดใหญ่', '฿899', '#ff7ab8'), ('กำไลนำโชค', '฿2,499', '#4ad2ff'), ('ชุดเสริมดวงครบเซ็ต', '฿1,999', '#9dff7a')]
rows = ''.join(f'<div class="row" id="s3-r{i}"><span class="dot" style="background:{c}"></span><span class="nm">{n}</span><span class="pr">{p}</span></div>' for i, (n, p, c) in enumerate(items))
sc['s3'] = phone('<div class="app">ช้อปแก้เคล็ด</div>' + bal('s3', '฿12,480') + f'<div class="rows">{rows}</div>', 's3')
sc['s4'] = phone('<div class="app">ชำระเงิน</div><div class="okc" id="s4-ok"><svg width="300" height="300" viewBox="0 0 300 300"><circle cx="150" cy="150" r="130" fill="#1fae6a"/><path d="M85 155 L135 205 L220 105" stroke="#fff" stroke-width="28" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg></div><div class="okt" id="s4-okt">ชำระเงินสำเร็จ</div><div class="tot" id="s4-tot">-฿7,396</div><div class="stamp" id="s4-st">กันเงินหายแล้ว!</div>', 's4')
sc['s5'] = phone('<div class="app">แอปธนาคาร</div>' + bal('s5', '฿5,084') + '<div class="down" id="s5-dn">▼ -฿7,396</div><div class="stamp big" id="s5-st">หมอดูแม่นมาก</div>', 's5')

html = ''
for sid, a, b in SC:
    if sid == 's6':
        body = f'''<div class="bg2"></div>
<div class="pos2" id="s6-a" style="left:40px;top:640px;transform:scale(1.15);transform-origin:0 0">{robot('happy', uid='s6a')}</div>
<div class="pos2" id="s6-b" style="left:650px;top:660px;transform:scale(1.15);transform-origin:0 0">{teal('happy', 's6b')}</div>
<div class="card" id="s6-c1" style="top:230px">อยากวางแผนเงิน<br>แบบไม่ต้องพึ่งหมอดู?</div>
<div class="card cta" id="s6-c3" style="top:1130px">ให้ AI ช่วยได้<br><span class="kw">คอมเมนต์คำว่า prompt</span><br><small>รับชุดคำสั่งฟรี</small></div>'''
    else:
        body = f'<div class="bg2"></div><div class="head" id="{sid}-hd">{HEAD[sid]}</div>{sc[sid]}{cam(sid)}<div class="cap" id="{sid}-cap">{CAP[sid]}</div>'
    html += f'<section id="sc-{sid}" class="clip sc" data-start="{a}" data-duration="{round(b-a,2)}" data-track-index="1">{body}</section>\n'
    # note: scene s5 note label
audio = ''.join(f'<audio id="v-{n}" src="assets/{n}.mp3" data-start="{st}" data-duration="{d+0.06:.2f}" data-track-index="{10+i}" data-volume="1"></audio>\n' for i, (n, st, d) in enumerate(VOICES))
audio += f'<audio id="bgm" src="assets/bgm.wav" data-start="0" data-duration="{DUR}" data-track-index="30" data-volume="0.55"></audio>\n'
audio += f'<audio id="sfx" src="assets/sfx.wav" data-start="0" data-duration="{DUR}" data-track-index="31" data-volume="1"></audio>\n'

js = []
def pop(sel, t, d=0.35): js.append(f'tl.from("{sel}",{{scale:0.2,opacity:0,rotation:-6,duration:{d},ease:"back.out(2)",transformOrigin:"50% 50%"}},{t:.2f});')
for sid, a, b in SC[:5]:
    js.append(f'tl.from("#{sid}-hd",{{y:-80,opacity:0,duration:0.35,ease:"power3.out"}},{a+0.02:.2f});')
    js.append(f'tl.from("#{sid}-ph",{{y:120,opacity:0,duration:0.35,ease:"power3.out"}},{a+0.05:.2f});')
    js.append(f'tl.from("#{sid}-cam",{{scale:0,opacity:0,duration:0.35,ease:"back.out(2)",transformOrigin:"0 100%"}},{a+0.2:.2f});')
    js.append(f'tl.from("#{sid}-cap",{{y:50,opacity:0,duration:0.35,ease:"power3.out"}},{a+0.15:.2f});')
    js.append(f'tl.to("#{sid}c-body",{{y:-10,duration:0.3,yoyo:true,repeat:{int((b-a)/0.3/2)-1},ease:"sine.inOut"}},{a+0.3:.2f});')
a = S['s1'][0]
js.append(f'tl.from("#s1-ball",{{scale:0,opacity:0,duration:0.5,ease:"back.out(1.6)"}},{a+0.3:.2f});tl.to("#s1-ball",{{y:-14,duration:0.5,yoyo:true,repeat:5,ease:"sine.inOut"}},{a+0.9:.2f});')
pop('#s1-bub', a + 0.7, 0.4); js.append(f'tl.from("#s1-bal",{{y:150,opacity:0,duration:0.4}},{a+1.9:.2f});')
a = S['s2'][0]
js.append(f'tl.to("#s2-bal",{{x:12,duration:0.05,yoyo:true,repeat:23,ease:"none"}},{a+0.2:.2f});tl.to("#s2-bv",{{color:"#d62839",duration:0.2}},{a+0.2:.2f});')
pop('#s2-al', a + 0.15, 0.3); pop('#s2-sh', a + 0.9, 0.45)
a = S['s3'][0]
tot = [12480]
js.append('const bal3={v:12480};')
price = [1999, 899, 2499, 1999]
cur = 12480
for i, p in enumerate(price):
    t = a + 0.6 + i * 1.0
    cur -= p
    js.append(f'tl.from("#s3-r{i}",{{x:700,opacity:0,duration:0.3,ease:"power3.out"}},{t:.2f});')
    js.append(f'tl.to(bal3,{{v:{cur},duration:0.4,ease:"power1.out",onUpdate:function(){{document.getElementById("s3-bv").textContent="฿"+Math.round(bal3.v).toLocaleString("en-US")}}}},{t+0.1:.2f});')
js.append(f'tl.to("#s3-bv",{{color:"#d62839",duration:0.3}},{a+1.6:.2f});')
a = S['s4'][0]
pop('#s4-ok', a + 0.15, 0.45); pop('#s4-okt', a + 0.55); pop('#s4-tot', a + 0.9); js.append(f'tl.from("#s4-st",{{scale:3,opacity:0,rotation:-25,duration:0.3,ease:"power4.in"}},{a+1.6:.2f});')
a = S['s5'][0]
js.append(f'tl.from("#s5-dn",{{y:-60,opacity:0,duration:0.3,ease:"bounce.out"}},{a+0.4:.2f});tl.from("#s5-st",{{scale:3,opacity:0,rotation:-25,duration:0.3,ease:"power4.in"}},{a+1.0:.2f});')
js.append(f'tl.to("#s5-bal",{{x:8,duration:0.06,yoyo:true,repeat:9,ease:"none"}},{a+0.45:.2f});')
a = S['s6'][0]
js.append(f'tl.from("#s6-a",{{x:-400,opacity:0,duration:0.45,ease:"back.out(1.4)"}},{a+0.1:.2f});tl.from("#s6-b",{{x:400,opacity:0,duration:0.45,ease:"back.out(1.4)"}},{a+0.2:.2f});')
js.append(f'tl.fromTo("#s6-c1",{{opacity:0,scale:0.3}},{{opacity:1,scale:1,duration:0.35,ease:"back.out(2)"}},{a+0.15:.2f});')
js.append(f'tl.fromTo("#s6-c3",{{opacity:0,y:120}},{{opacity:1,y:0,duration:0.4,ease:"power3.out"}},{a+1.6:.2f});')
js.append(f'tl.to("#s6a-body",{{y:-16,duration:0.35,yoyo:true,repeat:17,ease:"sine.inOut"}},{a+0.6:.2f});tl.to("#s6b-body",{{y:-16,duration:0.35,yoyo:true,repeat:17,ease:"sine.inOut"}},{a+0.75:.2f});')

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
out = f'''<!doctype html>
<html lang="th"><head><meta charset="UTF-8"/><meta name="viewport" content="width=1080, height=1920"/><title>POV fortune</title>
<script src="assets/gsap.min.js"></script><style>{CSS}</style></head>
<body><div id="root" data-composition-id="main" data-width="{W}" data-height="{H}" data-duration="{DUR}">
{html}{audio}</div>
<script>
window.__timelines = window.__timelines || {{}};
const tl = gsap.timeline({{ paused: true }});
{chr(10).join(js)}
window.__timelines["main"] = tl;
</script></body></html>
'''
open('/home/user/CLOUD/ai-ladmue/clips/c17/hf/index.html', 'w', encoding='utf-8').write(out)

# ---------------- sfx
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
for i, f in enumerate([1568, 1976, 2349, 2637]): put(tone(f, 0.6, env=4, vol=0.25), 0.4 + i * 0.12)  # crystal chime
put(tone(90, 1.0, env=3, vol=0.5), 0.3)
for i in range(8): put(tone(1200, 0.08, 'sq', env=10, vol=0.2), 3.85 + i * 0.12)  # alarm
for i, t in enumerate([6.7, 7.7, 8.7, 9.7]): chaching(t)
ding(11.5, 1568); put(noise(0.2, env=18, lp=8, vol=0.6), 12.4)  # stamp thud
put(tone(1800, 0.28, 'saw', f1=250, env=4, vol=0.45), 13.88); womp(14.2)
ding(19.0, 1175); ding(20.6, 1760)
for t in (0.05, 3.7, 6.1, 10.8, 13.9, 18.9): put(noise(0.35, env=7, lp=40, vol=0.5) * np.linspace(0.2, 1, int(SR * 0.35)), t)
X = np.tanh(X)
pcm = (np.clip(X, -1, 1) * 30000).astype('<i2')
with wave.open('/home/user/CLOUD/ai-ladmue/clips/c17/hf/assets/sfx.wav', 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
print('ok')
