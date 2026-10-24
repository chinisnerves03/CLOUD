import sys; sys.path.insert(0, '/home/user/CLOUD/ai-ladmue/clips')
from hfkit import *
DUR = 26.2
OUT = '/home/user/CLOUD/ai-ladmue/clips/c29/hf'
# scene boundaries (from word timestamps of v1.mp3)
SC = [('a', 0, 3.7), ('b', 3.7, 12.5), ('c', 12.5, 14.4), ('d', 14.4, 18.55), ('e', 18.55, 22.95), ('f', 22.95, DUR)]

def rb(face, uid, scale, left, top, cls='', id_=''):
    return f'<div class="ab {cls}" id="{id_}" style="left:{left}px;top:{top}px;transform:scale({scale});transform-origin:0 0">{robot(face, uid=uid)}</div>'

# ---- A: expectation -> doubt
a = '''<div class="bg" style="background:#ffe66b"></div><div class="dots"></div>
<div class="hd" id="a1">ทีม <span>AI</span><br>ต้องมี prompt เทพๆ<br>แน่เลย</div>
<div class="hd2" id="a2">จริงเหรอ<span>?</span></div>
''' + rb('proud', 'ra', 1.5, 300, 1050, id_='ra') + '<div class="star" id="s1">✨</div><div class="star" id="s2" style="right:120px;top:1000px">✨</div>'
# ---- B: real prompts
msgs = [('ทำให้ดูดีๆ หน่อย', 5.38), ('ไม่ใช่แบบนี้', 6.88), ('เอาแบบเมื่อกี้', 8.18), ('ยาวไป', 9.32), ('สั้นไป', 10.36), ('ทำให้ดีสิ!', 11.28)]
bub = ''.join(f'<div class="msg m{i%2}" id="m{i}" style="top:{300+i*160}px">{t}</div>' for i, (t, _) in enumerate(msgs))
faces = [('proud', 3.7), ('worried', 6.88), ('dazed', 9.32), ('sleepy', 11.28)]
fz = ''.join(rb(f, f'rb{i}', 1.3, 400, 1250, cls='fc', id_=f'fb{i}') for i, (f, _) in enumerate(faces))
b = f'''<div class="bg" style="background:#1b1f3b"></div><div class="dots"></div>
<div class="tag" id="bt">Prompt ระดับโปร<br><span>(ของจริง)</span></div>{bub}{fz}
<div class="note">* มุกสมมติ ไม่ใช่แชทจริงของใคร</div>'''
# ---- C: AI can't read minds
c = '''<div class="bg" style="background:#9dff7a"></div><div class="dots"></div>
<div class="hd" id="c1" style="top:330px">AI <span>อ่านใจ</span><br>ไม่ได้นะ</div>
''' + rb('cool', 'rc', 1.5, 300, 1000, id_='rc') + '<div class="q" id="q1" style="left:140px;top:900px">?</div><div class="q" id="q2" style="right:150px;top:1050px">?</div>'
# ---- D: 3 things
def chip(n, t, col, tid, top):
    return f'<div class="chip" id="{tid}" style="top:{top}px;background:{col}"><b>{n}</b>{t}</div>'
d = '''<div class="bg" style="background:#ff8a3d"></div><div class="dots"></div>
<div class="hd" id="d1" style="top:150px">บอกแค่ <span>3 อย่าง</span></div>''' + \
    chip(1, 'ใครอ่าน', '#7c5cff', 'd2', 560) + chip(2, 'ให้ทำอะไร', '#ff3d81', 'd3', 800) + chip(3, 'ยาวเท่าไหร่', '#18b6d9', 'd4', 1040) + rb('happy', 'rd', 1.3, 400, 1250, id_='rd')
# ---- E: example
def row(tid, lid, txt, col, lab, labcol):
    return f'<div class="row" id="{tid}"><span class="rt" style="color:{col}">{txt}</span><span class="rl" id="{lid}" style="background:{labcol}">{lab}</span></div>'
e = '''<div class="bg" style="background:#bfe9ff"></div><div class="dots"></div>
<div class="hd" id="e1" style="top:110px;font-size:92px">ลองแบบนี้ <span>👇</span></div>
<div class="code" id="e2">''' + row('e3', 'l3', 'เขียนอีเมลขอเลื่อนส่งงาน', '#ff9cba', 'ให้ทำอะไร', '#ff3d81') + row('e4', 'l4', 'ถึงหัวหน้า', '#7ee6ff', 'ใครอ่าน', '#7c5cff') + row('e5', 'l5', 'สุภาพ สามบรรทัด', '#ffe66b', 'ยาวเท่าไหร่', '#18b6d9') + '''</div>''' + rb('happy', 'rh', 1.2, 410, 1290, id_='re') + '<div class="note" style="color:#111">* ตรวจเนื้อหาที่ AI เขียนก่อนส่งจริงทุกครั้ง</div>'
# ---- F: CTA
f = '''<div class="bg" style="background:#ff3d81"></div><div class="burst"></div>
<div class="hd" id="f1" style="top:200px;color:#fff">เซฟไว้ก่อน!</div>
<div class="cta" id="f2">คอมเมนต์ <b>prompt</b><br>รับชุดคำสั่งฟรี</div>''' + rb('proud', 'rf', 1.4, 330, 1020, id_='rf')
bodies = dict(zip('abcdef', [a, b, c, d, e, f]))
sections = ''.join(section(k, s, t, f'<div class="cam" id="cam-{k}">{bodies[k]}</div>') for k, s, t in SC)

css = AE_CSS + '''
.dots{position:absolute;inset:0;background-image:radial-gradient(#00000022 3px,transparent 3.5px);background-size:22px 22px}
.hd,.hd2{position:absolute;left:30px;right:30px;top:200px;text-align:center;font-weight:800;font-size:100px;line-height:1.2;color:#111}
.hd span,.hd2 span{background:#111;color:#ffe66b;padding:0 24px;border-radius:16px;display:inline-block}
.hd2{top:420px;font-size:200px}.hd2 span{background:none;color:#d62839;padding:0}
.tag{position:absolute;left:40px;right:40px;top:70px;text-align:center;font-weight:800;font-size:92px;line-height:1.15;color:#fff}.tag span{font-size:60px;color:#9dff7a}
.msg{position:absolute;max-width:760px;font-weight:800;font-size:78px;padding:14px 40px;border:8px solid #111;border-radius:40px;box-shadow:8px 8px 0 #111;color:#111;z-index:3}
.m0{left:60px;background:#ffe66b}.m1{right:60px;background:#fff}
.fc{opacity:0}
.q{position:absolute;font-weight:800;font-size:150px;color:#111;transform:rotate(-10deg)}
.star{position:absolute;left:140px;top:1000px;font-size:120px}
.chip{position:absolute;left:90px;right:90px;height:190px;border:10px solid #111;border-radius:36px;box-shadow:10px 10px 0 #111;font-weight:800;font-size:100px;color:#fff;display:flex;align-items:center;padding-left:40px;text-shadow:5px 5px 0 #111}
.chip b{width:120px;height:120px;border-radius:60px;background:#fff;color:#111;border:8px solid #111;display:flex;align-items:center;justify-content:center;margin-right:36px;text-shadow:none;font-size:80px}
.code{position:absolute;left:50px;right:50px;top:330px;background:#111;border-radius:36px;padding:30px 40px;box-shadow:12px 12px 0 #0a3b6b}
.row{padding:22px 0;border-bottom:4px dashed #ffffff33}.row:last-child{border-bottom:0}
.rt{display:block;font-weight:800;font-size:70px;line-height:1.25;white-space:nowrap}
.rl{display:inline-block;margin-top:8px;font-weight:800;font-size:46px;color:#fff;padding:2px 26px;border-radius:30px;border:6px solid #fff}
.note{position:absolute;left:40px;right:40px;bottom:50px;text-align:center;font-weight:700;font-size:38px;color:#ffffffaa}
.burst{position:absolute;inset:-300px;background:repeating-conic-gradient(#ff3d81 0 10deg,#ff7aa8 10deg 20deg);opacity:.6}
.cta{position:absolute;left:60px;right:60px;top:480px;text-align:center;font-weight:800;font-size:96px;line-height:1.25;background:#fff;color:#111;border:12px solid #111;box-shadow:12px 12px 0 #111;border-radius:36px;padding:34px 20px}.cta b{background:#111;color:#ffe66b;padding:0 20px;border-radius:14px}
'''
js = []
# A
js.append('tl.from("#a1",{scale:0.4,opacity:0,rotation:-6,duration:0.45,ease:"back.out(2)"},0.08);')
js.append('tl.to("#a1",{opacity:0,y:-60,duration:0.18},2.85);tl.from("#a2",{scale:3,opacity:0,rotation:-15,duration:0.3,ease:"power4.in"},3.0);')
js.append('tl.to("#ra",{y:-18,duration:0.35,yoyo:true,repeat:7,ease:"sine.inOut"},0.2);tl.from("#s1",{scale:0,rotation:-90,duration:0.4,ease:"back.out(3)"},1.2);tl.from("#s2",{scale:0,rotation:90,duration:0.4,ease:"back.out(3)"},1.5);')
# B
js.append('tl.from("#bt",{y:-120,opacity:0,duration:0.4,ease:"back.out(1.8)"},3.8);')
for i, (t, at) in enumerate(msgs):
    side = -400 if i % 2 == 0 else 400
    js.append(f'tl.from("#m{i}",{{x:{side},opacity:0,scale:0.7,duration:0.28,ease:"back.out(1.7)"}},{at:.2f});')
for i, (fc, at) in enumerate(faces):
    nxt = faces[i + 1][1] if i + 1 < len(faces) else 12.5
    js.append(f'tl.set("#fb{i}",{{opacity:1}},{at:.2f});tl.set("#fb{i}",{{opacity:0}},{nxt:.2f});')
js.append('tl.to("#fb1",{x:-14,duration:0.07,yoyo:true,repeat:25,ease:"none"},6.9);tl.to("#fb2",{rotation:8,duration:0.25,yoyo:true,repeat:12,ease:"sine.inOut"},9.35);tl.to("#fb3",{y:12,duration:0.5,yoyo:true,repeat:5,ease:"sine.inOut"},11.3);')
# C
js.append('tl.from("#c1",{scale:0.3,opacity:0,duration:0.4,ease:"back.out(2)"},12.74);tl.from("#q1",{scale:0,duration:0.3,ease:"back.out(3)"},13.3);tl.from("#q2",{scale:0,duration:0.3,ease:"back.out(3)"},13.6);tl.to("#rc",{y:-15,duration:0.3,yoyo:true,repeat:4,ease:"sine.inOut"},12.8);')
# D
js.append('tl.from("#d1",{y:-100,opacity:0,duration:0.35,ease:"back.out(2)"},14.6);')
for tid, at in (('d2', 15.8), ('d3', 16.68), ('d4', 17.72)):
    js.append(f'tl.from("#{tid}",{{x:-700,opacity:0,duration:0.35,ease:"back.out(1.5)"}},{at - 0.15:.2f});')
# E
js.append('tl.from("#e1",{scale:0.5,opacity:0,duration:0.3,ease:"back.out(2)"},18.7);tl.from("#e2",{y:60,opacity:0,duration:0.3},18.7);')
for tid, at in (('e3', 18.74), ('e4', 20.5), ('e5', 21.38)):
    js.append(f'tl.from("#{tid}",{{opacity:0,y:20,duration:0.25}},{at:.2f});')
for tid, at in (('l3', 19.9), ('l4', 20.9), ('l5', 22.0)):
    js.append(f'tl.from("#{tid}",{{scale:0,duration:0.3,ease:"back.out(3)"}},{at:.2f});')
js.append('tl.to("#rd",{y:-14,duration:0.3,yoyo:true,repeat:9,ease:"sine.inOut"},14.7);tl.to("#re",{y:-14,duration:0.3,yoyo:true,repeat:9,ease:"sine.inOut"},18.8);')
# F
js.append('tl.from("#f1",{scale:0.3,opacity:0,rotation:-8,duration:0.4,ease:"back.out(2.4)"},23.0);tl.from("#f2",{y:200,opacity:0,duration:0.4,ease:"back.out(1.6)"},23.9);tl.to("#rf",{y:-18,duration:0.3,yoyo:true,repeat:7,ease:"sine.inOut"},23.1);tl.fromTo(".burst",{rotation:0},{rotation:50,duration:3.3,ease:"none"},22.95);')
for k, s, t in SC:
    js += cam_js(k, s, t, rot=0.6, push=0.05)
cuts = [s for k, s, t in SC[1:]]
sections += ae_overlay_html(('#ff3b30', '#ffe66b', '#111')).replace('__DUR__', str(DUR))
js += ae_overlay_js(DUR, cuts)
# punches on each bubble
for i, (t, at) in enumerate(msgs):
    js += punch_js(f'#m{i}', at + 0.28, 0.06)
audio = audio_el(0, 'v1', 0.0, 26.2) + bed_audio(DUR, 0.30)
import os; os.makedirs(OUT + '/assets', exist_ok=True)
write_index(OUT + '/index.html', 'Prompt ระดับโปร', css, sections, audio, js, DUR)
s = Sfx(DUR)
for t in cuts: s.whoosh(t - 0.05, 0.3); s.pop(t, 520)
s.scratch(3.0); s.womp(3.45)
for _, at in msgs: s.pop(at + 0.05, 640 + int(at * 20))
s.thud(6.9); s.ding(12.78, 1175)
for at in (15.8, 16.68, 17.72): s.pop(at, 900)
for at in (18.74, 20.5, 21.38): s.ding(at, 1568)
s.ding(23.9, 1760); s.chaching(24.3)
s.save(OUT + '/assets/sfx.wav'); print('ok')
