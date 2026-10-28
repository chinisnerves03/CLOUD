import sys; sys.path.insert(0, '/home/user/CLOUD/ai-ladmue/clips')
from hfkit import *
DUR = 16.5
OUT = '/home/user/CLOUD/ai-ladmue/clips/c30/hf'
# scene boundaries (rehearsal: estimated from pauses in v1.mp3, refine with word timestamps)
SC = [('a', 0, 1.8), ('b', 1.8, 3.0), ('c', 3.0, 5.6), ('d', 5.6, 8.2), ('e', 8.2, 10.3), ('f', 10.3, 12.8), ('g', 12.8, DUR)]
# caption phrases: (text, start, end) -- one pop per word, active word highlighted
CAPS = [('หยุดพิมพ์ว่า ช่วยหน่อย', 0.05, 1.75), ('ให้ AI ได้แล้ว!', 1.85, 2.95), ('AI จะเก่ง ก็ต่อเมื่อ คำสั่งชัด', 3.0, 5.55),
        ('ผมรวมคำสั่งที่ใช้จริง ไว้ 20 แบบ', 5.6, 8.15), ('เขียนอีเมล สรุปงาน คิดคอนเทนต์', 8.2, 10.25),
        ('ก๊อปไปวาง แก้วงเล็บ ใช้ได้เลย', 10.3, 12.75), ('อยากได้ฟรี คอมเมนต์ว่า prompt', 12.8, 16.4)]

def rb(face, uid, scale, left, top, cls='', id_=''):
    return f'<div class="ab {cls}" id="{id_}" style="left:{left}px;top:{top}px;transform:scale({scale});transform-origin:0 0">{robot(face, uid=uid)}</div>'

# ---- A: hook -- the lazy prompt gets crossed out
a = '''<div class="bg" style="background:#1b1f3b"></div><div class="dots"></div>
<div class="msg m0" id="a1" style="left:120px;top:420px;font-size:110px">ช่วยหน่อย</div>
<div class="xx" id="a2">✕</div>''' + rb('worried', 'ra', 1.0, 380, 800, id_='ra')
# ---- B: payoff of the hook
b = '''<div class="bg" style="background:#ffe66b"></div><div class="dots"></div>
<div class="hd" id="b1" style="top:420px;font-size:150px">ให้ <span>AI</span><br>ได้แล้ว!</div>'''
# ---- C: vague vs clear (chat mockup)
c = '''<div class="bg" style="background:#9dff7a"></div><div class="dots"></div>
<div class="tag" id="c0" style="color:#111;top:110px">AI เก่งแค่ไหน<br><span style="color:#d62839">ขึ้นกับคำสั่ง</span></div>
<div class="msg m1" id="c1" style="top:520px;right:50px;background:#fff;font-size:70px">ช่วยเขียนโพสต์</div>
<div class="reply bad" id="c2">😕 กลางๆ ใช้ไม่ได้</div>
<div class="msg m0" id="c3" style="top:860px;left:50px;max-width:900px;font-size:58px">เขียนโพสต์ขายกาแฟเย็น<br>3 บรรทัด โทนเป็นกันเอง</div>
<div class="reply good" id="c4">🤩 ใช้ได้ทันที</div>'''
# ---- D: big 20
d = '''<div class="bg" style="background:#7c5cff"></div><div class="burst2"></div>
<div class="big" id="d1">20</div>
<div class="hd" id="d2" style="top:240px;font-size:84px;color:#fff">คำสั่งที่ผม<span style="background:#ffe66b;color:#111">ใช้จริง</span></div>
<div class="pdf" id="d3"><b>PROMPT PACK</b><i>20 แบบ</i></div>'''
# ---- E: three use cases pop in
def chip(t, col, tid, top):
    return f'<div class="chip" id="{tid}" style="top:{top}px;background:{col}">{t}</div>'
e = '''<div class="bg" style="background:#ff8a3d"></div><div class="dots"></div>
<div class="hd" id="e0" style="top:120px;font-size:92px">ใช้ได้กับ</div>''' + \
    chip('📧 เขียนอีเมล', '#7c5cff', 'e1', 420) + chip('📝 สรุปงาน', '#ff3d81', 'e2', 680) + chip('💡 คิดคอนเทนต์', '#18b6d9', 'e3', 940)
# ---- F: copy -> paste -> edit -> go
def step(n, t, tid, top):
    return f'<div class="chip st" id="{tid}" style="top:{top}px;background:#111;color:#ffe66b"><b>{n}</b>{t}</div>'
f = '''<div class="bg" style="background:#18b6d9"></div><div class="dots"></div>
<div class="hd" id="f0" style="top:100px;font-size:96px">ง่ายแค่ <span>3 ขั้น</span></div>''' + \
    step(1, 'ก๊อป', 'f1', 400) + step(2, 'แก้ [วงเล็บ]', 'f2', 650) + step(3, 'ใช้เลย!', 'f3', 900)
# ---- G: CTA -- IG comment box typing "prompt"
g = '''<div class="bg" style="background:#ff3d81"></div><div class="burst"></div>
<div class="hd" id="g1" style="top:150px;color:#fff;font-size:120px">ฟรี!</div>
<div class="cbox" id="g2"><span class="who">@คุณ</span><span id="typ"></span><span class="cur">|</span></div>
<div class="dm" id="g3">📩 ส่งใน DM ให้เลย</div>'''
bodies = dict(zip('abcdefg', [a, b, c, d, e, f, g]))
sections = ''.join(section(k, s, t, f'<div class="cam" id="cam-{k}">{bodies[k]}</div>') for k, s, t in SC)

# captions: one div per phrase, one span per word
cap_html = ''
cap_js = []
for i, (txt, s, t) in enumerate(CAPS):
    words = txt.split(' ')
    wts = [max(len(w), 2) for w in words]; tot = sum(wts); acc = 0
    spans = ''
    for j, w in enumerate(words):
        spans += f'<span class="cw" id="cw{i}_{j}">{w}</span> '
        at = s + (t - s) * acc / tot; acc += wts[j]
        nxt = s + (t - s) * acc / tot
        cap_js.append(f'tl.set("#cw{i}_{j}",{{opacity:1,color:"#ffe66b",scale:1.12}},{at:.2f});tl.to("#cw{i}_{j}",{{scale:1,duration:0.12,ease:"back.out(3)"}},{at+0.001:.2f});tl.set("#cw{i}_{j}",{{color:"#fff"}},{nxt:.2f});')
    cap_html += f'<div class="cap" id="cap{i}">{spans}</div>'
    cap_js.append(f'tl.set("#cap{i}",{{opacity:1}},{s:.2f});tl.set("#cap{i}",{{opacity:0}},{t:.2f});')
sections += f'<section id="sc-cap" class="clip sc" data-start="0" data-duration="{DUR}" data-track-index="4" style="pointer-events:none">{cap_html}</section>\n'

css = AE_CSS + '''
.dots{position:absolute;inset:0;background-image:radial-gradient(#00000022 3px,transparent 3.5px);background-size:22px 22px}
.hd{position:absolute;left:30px;right:30px;top:200px;text-align:center;font-weight:800;font-size:100px;line-height:1.2;color:#111}
.hd span{background:#111;color:#ffe66b;padding:0 24px;border-radius:16px;display:inline-block}
.tag{position:absolute;left:40px;right:40px;top:70px;text-align:center;font-weight:800;font-size:84px;line-height:1.15;color:#fff}
.msg{position:absolute;max-width:760px;font-weight:800;font-size:78px;padding:14px 40px;border:8px solid #111;border-radius:40px;box-shadow:8px 8px 0 #111;color:#111;z-index:3}
.m0{background:#ffe66b}.m1{background:#fff}
.xx{position:absolute;left:90px;top:300px;font-size:520px;font-weight:800;color:#ff3b30;line-height:1;opacity:0;text-shadow:10px 10px 0 #111;z-index:5}
.reply{position:absolute;left:50px;right:50px;font-weight:800;font-size:64px;padding:14px 30px;border-radius:30px;border:8px solid #111;text-align:center}
.reply.bad{top:720px;background:#ff9cba}.reply.good{top:1090px;background:#fff}
.big{position:absolute;left:0;right:0;top:380px;text-align:center;font-weight:800;font-size:560px;line-height:1;color:#ffe66b;text-shadow:16px 16px 0 #111}
.pdf{position:absolute;left:340px;top:980px;width:400px;height:260px;background:#fff;border:10px solid #111;border-radius:24px;box-shadow:12px 12px 0 #111;transform:rotate(-6deg);display:flex;flex-direction:column;align-items:center;justify-content:center;font-weight:800;color:#111}
.pdf b{font-size:52px}.pdf i{font-style:normal;font-size:90px;color:#7c5cff}
.chip{position:absolute;left:90px;right:90px;height:200px;border:10px solid #111;border-radius:36px;box-shadow:10px 10px 0 #111;font-weight:800;font-size:92px;color:#fff;display:flex;align-items:center;padding-left:50px;text-shadow:5px 5px 0 #111}
.chip b{width:120px;height:120px;border-radius:60px;background:#ffe66b;color:#111;border:8px solid #111;display:flex;align-items:center;justify-content:center;margin-right:36px;text-shadow:none;font-size:80px}
.burst,.burst2{position:absolute;inset:-300px;background:repeating-conic-gradient(#ff3d81 0 10deg,#ff7aa8 10deg 20deg);opacity:.6}
.burst2{background:repeating-conic-gradient(#7c5cff 0 10deg,#a48bff 10deg 20deg)}
.cbox{position:absolute;left:60px;right:60px;top:520px;background:#fff;border:10px solid #111;border-radius:40px;box-shadow:12px 12px 0 #111;padding:34px 40px;font-weight:800;font-size:90px;color:#111;white-space:nowrap}
.cbox .who{color:#7c5cff;margin-right:24px;font-size:60px}.cur{opacity:.6}
.dm{position:absolute;left:120px;right:120px;top:860px;text-align:center;font-weight:800;font-size:76px;background:#9dff7a;color:#111;border:10px solid #111;border-radius:36px;box-shadow:10px 10px 0 #111;padding:20px}
#sc-cap{z-index:20}
.cap{position:absolute;left:40px;right:40px;top:1330px;text-align:center;opacity:0;font-weight:800;font-size:92px;line-height:1.25;color:#fff;-webkit-text-stroke:10px #111;paint-order:stroke fill;text-shadow:0 8px 0 #111}
.cw{display:inline-block;opacity:0;color:#fff}
'''
js = []
# A: hook
js.append('tl.from("#a1",{scale:0.4,opacity:0,rotation:-8,duration:0.25,ease:"back.out(2.4)"},0.05);tl.set("#a2",{opacity:1},0.75);tl.from("#a2",{scale:3,duration:0.2,ease:"power4.in"},0.75);tl.to("#ra",{y:-14,duration:0.2,yoyo:true,repeat:6,ease:"sine.inOut"},0.2);')
# B
js.append('tl.from("#b1",{scale:2.4,opacity:0,rotation:6,duration:0.3,ease:"power4.out"},1.85);')
# C
js.append('tl.from("#c0",{y:-100,opacity:0,duration:0.3,ease:"back.out(1.8)"},3.0);tl.from("#c1",{x:400,opacity:0,duration:0.28,ease:"back.out(1.7)"},3.35);tl.from("#c2",{scale:0,duration:0.25,ease:"back.out(3)"},3.95);tl.from("#c3",{x:-400,opacity:0,duration:0.28,ease:"back.out(1.7)"},4.3);tl.from("#c4",{scale:0,duration:0.25,ease:"back.out(3)"},5.0);')
# D
js.append('tl.from("#d1",{scale:0.2,opacity:0,rotation:-14,duration:0.4,ease:"back.out(2.6)"},5.65);tl.from("#d2",{y:-120,opacity:0,duration:0.3,ease:"back.out(1.8)"},6.3);tl.from("#d3",{y:300,opacity:0,rotation:20,duration:0.4,ease:"back.out(1.6)"},7.0);tl.fromTo(".burst2",{rotation:0},{rotation:40,duration:2.6,ease:"none"},5.6);')
# E
js.append('tl.from("#e0",{y:-80,opacity:0,duration:0.25},8.25);')
for tid, at in (('e1', 8.4), ('e2', 9.1), ('e3', 9.7)):
    js.append(f'tl.from("#{tid}",{{x:-700,opacity:0,duration:0.3,ease:"back.out(1.6)"}},{at});')
# F
js.append('tl.from("#f0",{scale:0.5,opacity:0,duration:0.3,ease:"back.out(2)"},10.35);')
for tid, at in (('f1', 10.55), ('f2', 11.2), ('f3', 11.95)):
    js.append(f'tl.from("#{tid}",{{x:700,opacity:0,duration:0.3,ease:"back.out(1.6)"}},{at});')
# G: typing "prompt" then DM bubble
js.append('tl.from("#g1",{scale:0.3,opacity:0,rotation:-8,duration:0.35,ease:"back.out(2.4)"},12.85);tl.from("#g2",{y:120,opacity:0,duration:0.3},13.4);')
for k, ch in enumerate('prompt'):
    js.append(f'tl.call(function(){{document.getElementById("typ").textContent="{"prompt"[:k+1]}"}},[],{14.0 + k*0.12:.2f});')
js.append('tl.fromTo(".cur",{opacity:0},{opacity:0.8,duration:0.2,yoyo:true,repeat:9},13.5);tl.from("#g3",{y:200,opacity:0,scale:0.6,duration:0.4,ease:"back.out(1.8)"},14.6);tl.fromTo(".burst",{rotation:0},{rotation:40,duration:3.7,ease:"none"},12.8);')
for k, s, t in SC:
    js += cam_js(k, s, t, rot=0.5, push=0.05)
cuts = [s for k, s, t in SC[1:]]
sections += ae_overlay_html(('#ff3b30', '#ffe66b', '#111')).replace('__DUR__', str(DUR))
js += ae_overlay_js(DUR, cuts)
js += cap_js
# zoom punches on emphasis beats
for sel, at in (('#b1', 1.85), ('#d1', 6.0), ('#g1', 13.15), ('#g3', 14.9)):
    js += punch_js(sel, at, 0.06)
audio = audio_el(0, 'v1', 0.0, 16.5) + bed_audio(DUR, 0.22)
import os; os.makedirs(OUT + '/assets', exist_ok=True)
write_index(OUT + '/index.html', 'Prompt Pack ฟรี', css, sections, audio, js, DUR)
s = Sfx(DUR)
for t in cuts: s.whoosh(t - 0.05, 0.25); s.pop(t, 520)
s.scratch(0.75); s.ding(5.8, 1175)
for at in (8.4, 9.1, 9.7): s.pop(at, 900)
for at in (10.55, 11.2, 11.95): s.pop(at, 700)
for k in range(6): s.pop(14.0 + k * 0.12, 1200)
s.ding(14.6, 1760); s.chaching(15.5)
s.save(OUT + '/assets/sfx.wav'); print('ok')
