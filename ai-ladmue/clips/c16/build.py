#!/usr/bin/env python3
"""Generates the HyperFrames composition (hf/index.html) for clip 16: plan vs reality."""
import json

W, H = 1080, 1920
# ---- timeline (global seconds)
SC = [  # id, start, end
    ('s0', 0.0, 3.5), ('p1', 3.5, 6.8), ('r1', 6.8, 10.9), ('p2', 10.9, 13.5), ('r2', 13.5, 16.85),
    ('p3', 16.85, 19.75), ('r3', 19.75, 23.9), ('p4', 23.9, 26.6), ('r4', 26.6, 30.1), ('s5', 30.1, 38.6)]
VOICES = [('hook', 0.2, 3.08), ('p1', 3.6, 3.08), ('r1', 6.95, 3.79), ('p2', 10.95, 2.35), ('r2', 13.55, 3.16),
          ('p3', 16.9, 2.59), ('r3', 19.8, 3.97), ('p4', 23.95, 2.35), ('r4', 26.65, 3.16), ('out', 30.2, 7.63)]
DUR = 38.6
S = {k: (a, b) for k, a, b in SC}


def robot(face, body='#ff8a3d', head='#ffa05a', dark='#c4561a', acc='#ffe3c2', legs=False, tie=False, uid='r'):
    eyes = {
        'happy': '<path d="M78 140 Q112 98 146 140" stroke="#9dff7a" stroke-width="14" stroke-linecap="round" fill="none"/><path d="M154 140 Q188 98 222 140" stroke="#9dff7a" stroke-width="14" stroke-linecap="round" fill="none"/>',
        'cool': '<rect x="70" y="112" width="160" height="34" rx="14" fill="#9dff7a"/><rect x="70" y="112" width="160" height="10" rx="5" fill="#d8ffc8"/>',
        'sleepy': '<path d="M80 134 L142 134" stroke="#9dff7a" stroke-width="12" stroke-linecap="round"/><path d="M158 134 L220 134" stroke="#9dff7a" stroke-width="12" stroke-linecap="round"/>',
        'worried': '<ellipse cx="112" cy="130" rx="22" ry="30" fill="#9dff7a"/><ellipse cx="188" cy="130" rx="22" ry="30" fill="#9dff7a"/><circle cx="119" cy="122" r="6" fill="#10142a"/><circle cx="195" cy="122" r="6" fill="#10142a"/><path d="M86 102 L134 86 M214 102 L166 86" stroke="#9dff7a" stroke-width="9" stroke-linecap="round"/>',
        'dazed': '<circle cx="112" cy="130" r="26" fill="none" stroke="#9dff7a" stroke-width="9"/><circle cx="112" cy="130" r="10" fill="#9dff7a"/><circle cx="188" cy="130" r="26" fill="none" stroke="#9dff7a" stroke-width="9"/><circle cx="188" cy="130" r="10" fill="#9dff7a"/>',
        'proud': '<path d="M80 142 Q112 108 144 142" stroke="#9dff7a" stroke-width="14" stroke-linecap="round" fill="none"/><path d="M156 142 Q188 108 220 142" stroke="#9dff7a" stroke-width="14" stroke-linecap="round" fill="none"/>',
    }[face]
    mouth = {
        'happy': '<path d="M116 170 Q150 204 184 170" stroke="#ff7aa2" stroke-width="9" stroke-linecap="round" fill="none"/>',
        'cool': '<path d="M124 178 Q150 190 176 176" stroke="#ff7aa2" stroke-width="9" stroke-linecap="round" fill="none"/>',
        'sleepy': '<ellipse cx="150" cy="182" rx="14" ry="10" fill="#7a2a4a"/>',
        'worried': '<path d="M120 184 Q135 168 150 182 Q165 196 180 182" stroke="#ff7aa2" stroke-width="9" stroke-linecap="round" fill="none"/>',
        'dazed': '<path d="M124 182 L176 182" stroke="#ff7aa2" stroke-width="9" stroke-linecap="round"/>',
        'proud': '<path d="M112 168 Q150 208 188 168 Z" fill="#7a2a4a" stroke="#ff7aa2" stroke-width="6" stroke-linejoin="round"/>',
    }[face]
    leg = ''
    if legs:
        leg = f'''<g id="{uid}-legL" style="transform-origin:112px 410px"><rect x="98" y="404" width="30" height="86" rx="12" fill="{dark}"/><rect x="88" y="480" width="54" height="22" rx="10" fill="#fff"/></g>
<g id="{uid}-legR" style="transform-origin:190px 410px"><rect x="172" y="404" width="30" height="86" rx="12" fill="{dark}"/><rect x="162" y="480" width="54" height="22" rx="10" fill="#fff"/></g>'''
    torso_extra = ('<polygon points="138,246 162,246 170,274 150,364 130,274" fill="#d62839" stroke="#7a1420" stroke-width="5"/>' if tie else
                   '<rect x="118" y="282" width="64" height="60" rx="16" fill="#10142a"/><path d="M150 330 C122 308 130 290 150 302 C170 290 178 308 150 330Z" fill="#ff6f91"/>')
    return f'''<svg viewBox="0 0 300 520" width="300" height="520" style="overflow:visible">{leg}
<g id="{uid}-body"><line x1="150" y1="14" x2="150" y2="54" stroke="{dark}" stroke-width="8" stroke-linecap="round"/><circle cx="150" cy="14" r="14" fill="#ff6f91"/>
<g id="{uid}-head"><rect x="28" y="108" width="20" height="56" rx="9" fill="{dark}"/><rect x="252" y="108" width="20" height="56" rx="9" fill="{dark}"/>
<rect x="40" y="50" width="220" height="172" rx="56" fill="{head}" stroke="{dark}" stroke-width="6"/><rect x="64" y="76" width="172" height="122" rx="40" fill="#10142a"/>{eyes}{mouth}
<ellipse cx="92" cy="172" rx="16" ry="9" fill="#ff7aa2" opacity=".45"/><ellipse cx="208" cy="172" rx="16" ry="9" fill="#ff7aa2" opacity=".45"/></g>
<rect x="124" y="218" width="52" height="22" fill="{dark}"/>
<path d="M62 262 Q150 232 238 262 L248 420 L52 420 Z" fill="{body}" stroke="{dark}" stroke-width="6"/>{torso_extra}
<g id="{uid}-armL" style="transform-origin:78px 268px"><path d="M78 268 L38 350" stroke="{dark}" stroke-width="44" stroke-linecap="round"/><path d="M78 268 L38 350" stroke="{body}" stroke-width="34" stroke-linecap="round"/><circle cx="36" cy="354" r="22" fill="{acc}" stroke="{dark}" stroke-width="5"/></g>
<g id="{uid}-armR" style="transform-origin:222px 268px"><path d="M222 268 L262 350" stroke="{dark}" stroke-width="44" stroke-linecap="round"/><path d="M222 268 L262 350" stroke="{body}" stroke-width="34" stroke-linecap="round"/><circle cx="264" cy="354" r="22" fill="{acc}" stroke="{dark}" stroke-width="5"/></g></g></svg>'''


def teal(face, uid):
    return robot(face, '#2fc4b8', '#4fd9cc', '#1b9a90', '#f2f6f8', uid=uid)


def clock(txt, uid, x, y, size=210, bg='#fff'):
    return f'''<div id="{uid}" class="prop" style="left:{x}px;top:{y}px;width:{size}px;height:{size}px"><svg viewBox="0 0 200 200" width="{size}" height="{size}"><circle cx="100" cy="100" r="92" fill="{bg}" stroke="#222" stroke-width="10"/><circle cx="100" cy="100" r="6" fill="#222"/><line x1="100" y1="100" x2="100" y2="44" stroke="#222" stroke-width="8" stroke-linecap="round"/><line x1="100" y1="100" x2="140" y2="116" stroke="#222" stroke-width="8" stroke-linecap="round"/></svg><div class="clk">{txt}</div></div>'''


scenes = {}
# ---- hook
scenes['s0'] = f'''<div class="bg" style="background:linear-gradient(160deg,#6a2cff,#ff5a8a)"></div>
<div class="ttl" id="s0-t1" style="top:300px">แผนชีวิตปีใหม่</div>
<div class="ttl big" id="s0-t2" style="top:430px;color:#ffd23f">VS ความจริง</div>
<div class="pos" id="s0-a" style="left:50px;top:880px;width:420px;transform:scale(1.65);transform-origin:0 0">{robot('cool', uid='s0a')}</div>
<div class="pos" id="s0-b" style="left:600px;top:960px;width:420px;transform:scale(1.5);transform-origin:0 0">{teal('worried', 's0b')}</div>
<div class="lbl ok" style="left:90px;top:810px" id="s0-l1">แผน</div><div class="lbl bad" style="right:90px;top:810px" id="s0-l2">ความจริง</div>'''
# ---- round 1
scenes['p1'] = f'''<div class="bg" style="background:linear-gradient(#ffd28a,#ff9a6b 45%,#7ad7ff)"></div>
<div class="pos" id="p1-sun" style="left:340px;top:560px"><svg width="400" height="400"><circle cx="200" cy="200" r="170" fill="#fff3b0" opacity=".9"/><circle cx="200" cy="200" r="120" fill="#ffd23f"/></svg></div>
{clock('05:00','p1-clk',70,230)}
<div class="ground" style="background:#6bbf59"></div>
<div class="pos" id="p1-bot" style="left:290px;top:860px;transform:scale(1.35);transform-origin:0 0">{robot('happy', legs=True, uid='p1')}</div>'''
scenes['r1'] = f'''<div class="bg" style="background:linear-gradient(#2a2f4a,#14172a)"></div>
{clock('11:47','r1-clk',720,250)}
<div class="pos" id="r1-bot" style="left:250px;top:830px;transform:scale(1.35);transform-origin:0 0">{robot('sleepy', uid='r1')}</div>
<div class="blanket" id="r1-bl"></div>
<div class="zz" id="r1-z1" style="left:700px;top:760px">Z</div><div class="zz" id="r1-z2" style="left:780px;top:690px;font-size:90px">Z</div><div class="zz" id="r1-z3" style="left:850px;top:620px;font-size:120px">Z</div>
<div class="badge" id="r1-bd" style="left:80px;top:300px">เลื่อนปลุก x9</div>'''
# ---- round 2
scenes['p2'] = f'''<div class="bg" style="background:linear-gradient(#d7ffd0,#8be08a)"></div>
<div class="pos" id="p2-bot" style="left:250px;top:760px;transform:scale(1.35);transform-origin:0 0">{robot('proud', uid='p2')}</div>
<div class="pos" id="p2-bowl" style="left:300px;top:1340px"><svg width="460" height="260" viewBox="0 0 460 260"><path d="M20 80 Q230 300 440 80 Z" fill="#fff" stroke="#222" stroke-width="8"/><circle cx="110" cy="70" r="44" fill="#4caf50"/><circle cx="190" cy="50" r="48" fill="#8bc34a"/><circle cx="270" cy="62" r="50" fill="#66bb6a"/><circle cx="350" cy="72" r="42" fill="#43a047"/><circle cx="240" cy="40" r="22" fill="#ff5252"/><circle cx="150" cy="40" r="18" fill="#ff5252"/></svg></div>'''
scenes['r2'] = f'''<div class="bg" style="background:linear-gradient(#ff7a3d,#7a1d0e)"></div>
<div class="pos" id="r2-bot" style="left:250px;top:700px;transform:scale(1.35);transform-origin:0 0">{robot('happy', uid='r2')}</div>
<div class="pos" id="r2-pot" style="left:150px;top:1320px"><svg width="780" height="300" viewBox="0 0 780 300"><ellipse cx="390" cy="150" rx="370" ry="110" fill="#d8dce6" stroke="#222" stroke-width="8"/><ellipse cx="390" cy="130" rx="320" ry="80" fill="#c1121f"/><circle cx="260" cy="130" r="26" fill="#ffd9c4"/><circle cx="360" cy="120" r="30" fill="#f4a08a"/><circle cx="470" cy="135" r="28" fill="#ffd9c4"/><circle cx="560" cy="120" r="24" fill="#f4a08a"/></svg></div>
<div class="plates" id="r2-pl"><i></i><i></i><i></i><i></i><i></i><i></i></div>
<div class="steam" id="r2-st1" style="left:300px;top:1180px"></div><div class="steam" id="r2-st2" style="left:520px;top:1150px"></div><div class="steam" id="r2-st3" style="left:720px;top:1190px"></div>'''
# ---- round 3
scenes['p3'] = f'''<div class="bg" style="background:linear-gradient(#bfe8ff,#7bb8ff)"></div>
<div class="pos" id="p3-bot" style="left:120px;top:780px;transform:scale(1.35);transform-origin:0 0">{robot('proud', uid='p3')}</div>
<div class="pos" id="p3-pig" style="left:520px;top:1190px"><svg width="470" height="360" viewBox="0 0 470 360"><ellipse cx="230" cy="200" rx="190" ry="130" fill="#ff9ec1" stroke="#222" stroke-width="8"/><circle cx="395" cy="190" r="60" fill="#ff9ec1" stroke="#222" stroke-width="8"/><ellipse cx="420" cy="195" rx="26" ry="20" fill="#ff7aa2" stroke="#222" stroke-width="6"/><circle cx="380" cy="160" r="9" fill="#222"/><polygon points="340,100 372,60 395,110" fill="#ff9ec1" stroke="#222" stroke-width="7"/><rect x="170" y="86" width="110" height="16" rx="8" fill="#222"/><rect x="130" y="305" width="30" height="55" fill="#ff7aa2" stroke="#222" stroke-width="6"/><rect x="290" y="305" width="30" height="55" fill="#ff7aa2" stroke="#222" stroke-width="6"/></svg></div>
<div class="coin" id="p3-c"></div>
<div class="badge ok" id="p3-bd" style="left:90px;top:300px;font-size:120px">5,000</div>'''
scenes['r3'] = f'''<div class="bg" style="background:linear-gradient(#ffd0e6,#ff7ab8)"></div>
<div class="pos" id="r3-bot" style="left:110px;top:760px;transform:scale(1.35);transform-origin:0 0">{robot('dazed', uid='r3')}</div>
<div class="pos" id="r3-cart" style="left:500px;top:1150px"><svg width="520" height="400" viewBox="0 0 520 400"><path d="M20 40 L100 40 L150 260 L430 260 L480 90 L120 90" fill="none" stroke="#222" stroke-width="14" stroke-linejoin="round" stroke-linecap="round"/><rect x="170" y="110" width="90" height="90" rx="10" fill="#ffd23f" stroke="#222" stroke-width="6"/><rect x="270" y="130" width="80" height="70" rx="10" fill="#4ad2ff" stroke="#222" stroke-width="6"/><rect x="360" y="100" width="90" height="100" rx="10" fill="#9dff7a" stroke="#222" stroke-width="6"/><circle cx="200" cy="320" r="30" fill="#222"/><circle cx="390" cy="320" r="30" fill="#222"/></svg></div>
<div class="badge bad" id="r3-bd" style="left:80px;top:300px">ตะกร้า 47 ชิ้น</div>
<div class="badge" id="r3-bd2" style="right:70px;top:480px;font-size:56px;transform:rotate(6deg)">แค่ดูเฉยๆ...</div>'''
# ---- round 4
scenes['p4'] = f'''<div class="bg" style="background:linear-gradient(#e7e1ff,#b9a8ff)"></div>
{clock('11:30','p4-clk',770,220,200)}
<div class="pos" id="p4-bot" style="left:150px;top:760px;transform:scale(1.35);transform-origin:0 0">{robot('cool', uid='p4')}</div>
<div class="pos" id="p4-lap" style="left:430px;top:1260px"><svg width="560" height="360" viewBox="0 0 560 360"><rect x="60" y="0" width="440" height="270" rx="20" fill="#2b2f44" stroke="#222" stroke-width="8"/><rect x="82" y="22" width="396" height="226" rx="10" fill="#0b1020"/><path d="M180 140 L250 200 L390 70" stroke="#9dff7a" stroke-width="26" stroke-linecap="round" stroke-linejoin="round" fill="none"/><path d="M0 290 L560 290 L520 340 L40 340 Z" fill="#c9ced9" stroke="#222" stroke-width="8"/></svg></div>'''
scenes['r4'] = f'''<div class="bg" style="background:linear-gradient(#3a2a6a,#1a1236)"></div>
{clock('15:00','r4-clk',770,220,200)}
<div class="pos" id="r4-bot" style="left:110px;top:760px;transform:scale(1.35);transform-origin:0 0">{robot('happy', uid='r4')}</div>
<div class="pos" id="r4-ph" style="left:640px;top:1090px"><svg width="360" height="560" viewBox="0 0 360 560"><rect x="10" y="10" width="340" height="540" rx="46" fill="#111" stroke="#9dff7a" stroke-width="8"/><circle cx="180" cy="230" r="110" fill="#ffd23f"/><path d="M110 200 Q135 170 160 200 M200 200 Q225 170 250 200" stroke="#222" stroke-width="10" fill="none" stroke-linecap="round"/><path d="M110 250 Q180 360 250 250 Z" fill="#7a2a1a" stroke="#222" stroke-width="8"/><rect x="60" y="400" width="240" height="22" rx="11" fill="#444"/><rect x="60" y="400" width="190" height="22" rx="11" fill="#ff3d81"/></svg></div>
<div class="badge bad" id="r4-bd" style="left:80px;top:300px">ชั่วโมงที่ 3</div>'''
# ---- outro
scenes['s5'] = f'''<div class="bg" style="background:linear-gradient(160deg,#1b1230,#4a1f7a)"></div>
<div class="pos" id="s5-a" style="left:40px;top:640px;transform:scale(1.15);transform-origin:0 0">{robot('happy', uid='s5a')}</div>
<div class="pos" id="s5-b" style="left:650px;top:660px;transform:scale(1.15);transform-origin:0 0">{teal('happy', 's5b')}</div>
<div class="card" id="s5-c1" style="top:230px">เหมือนคุณไหม?</div>
<div class="card" id="s5-c2" style="top:230px;background:#ffd23f;color:#000">กดเซฟไว้ แล้วมาเช็กกันปีหน้า</div>
<div class="card cta" id="s5-c3" style="top:1130px">ถ้าอยากให้ AI ช่วยวางแผน<br><span class="kw">คอมเมนต์คำว่า prompt</span></div>'''

CAPS = {
    's0': 'แผนชีวิตปีใหม่ของผม เทียบกับความจริง',
    'p1': 'แผน: ตื่นตีห้า ไปวิ่งทุกเช้า', 'r1': 'ความจริง: ตีห้าปิดนาฬิกา ตื่นอีกทีเที่ยง',
    'p2': 'แผน: กินคลีน ทุกมื้อ', 'r2': 'ความจริง: หมูกระทะ ไม่จำกัดเวลา',
    'p3': 'แผน: เก็บเงินเดือนละ ห้าพันบาท', 'r3': 'ความจริง: ตะกร้าสินค้าเต็ม แต่แค่ดูเฉยๆ',
    'p4': 'แผน: ทำงานให้เสร็จก่อนเที่ยง', 'r4': 'ความจริง: ดูคลิปตลก สามชั่วโมง'}
RN = {'p1': 1, 'r1': 1, 'p2': 2, 'r2': 2, 'p3': 3, 'r3': 3, 'p4': 4, 'r4': 4}

html_scenes = ''
track = 1
for sid, a, b in SC:
    cap = ''
    tag = ''
    if sid in CAPS and sid != 's0':
        isp = sid.startswith('p')
        tag = f'<div class="tag {"ok" if isp else "bad"}" id="{sid}-tag">{"แผน" if isp else "ความจริง"}</div><div class="rnd">ข้อ {RN[sid]}/4</div>'
        cap = f'<div class="cap" id="{sid}-cap">{CAPS[sid].split(": ",1)[1]}</div>'
    html_scenes += f'<section id="sc-{sid}" class="clip sc" data-start="{a}" data-duration="{round(b-a,2)}" data-track-index="1">{scenes[sid]}{tag}{cap}</section>\n'

audio = ''
for i, (n, st, d) in enumerate(VOICES):
    audio += f'<audio id="v-{n}" src="assets/{n}.mp3" data-start="{st}" data-duration="{d+0.05:.2f}" data-track-index="{10+i}" data-volume="1"></audio>\n'
audio += f'<audio id="bgm" src="assets/bgm.wav" data-start="0" data-duration="{DUR}" data-track-index="30" data-volume="0.8"></audio>\n'
audio += f'<audio id="sfx" src="assets/sfx.wav" data-start="0" data-duration="{DUR}" data-track-index="31" data-volume="1"></audio>\n'

# ---- GSAP timeline (global time)
js = []
def T(s): return S[s][0]
def pop(sel, t, d=0.35, **kw):
    js.append(f'tl.from("{sel}",{{scale:0.2,opacity:0,rotation:{kw.get("rot",-8)},duration:{d},ease:"back.out(2)",transformOrigin:"50% 50%"}},{t:.2f});')
for sid, a, b in SC:
    if sid in CAPS and sid != 's0':
        js.append(f'tl.from("#{sid}-tag",{{x:-200,opacity:0,duration:0.3,ease:"power3.out"}},{a+0.05:.2f});')
        js.append(f'tl.from("#{sid}-cap",{{y:60,opacity:0,duration:0.35,ease:"power3.out"}},{a+0.12:.2f});')
# hook
pop('#s0-t1', 0.2); pop('#s0-t2', 0.9, 0.45)
js.append('tl.from("#s0-a",{y:300,opacity:0,duration:0.5,ease:"back.out(1.6)"},1.2);tl.from("#s0-b",{y:300,opacity:0,duration:0.5,ease:"back.out(1.6)"},1.5);')
pop('#s0-l1', 1.9); pop('#s0-l2', 2.2)
for i, sel in enumerate(['#s0a-body', '#s0b-body']):
    js.append(f'tl.to("{sel}",{{y:-14,duration:0.35,yoyo:true,repeat:6,ease:"sine.inOut"}},{1.8+i*0.1:.2f});')
# r1 plan: sunrise + running
a = T('p1')
js.append(f'tl.from("#p1-sun",{{y:520,duration:2.4,ease:"power2.out"}},{a:.2f});')
js.append(f'tl.from("#p1-clk",{{scale:0,rotation:-60,duration:0.4,ease:"back.out(2)"}},{a+0.3:.2f});')
js.append(f'tl.to("#p1-body",{{y:-26,duration:0.22,yoyo:true,repeat:13,ease:"sine.inOut"}},{a+0.2:.2f});')
js.append(f'tl.to("#p1-legL",{{svgOrigin:"112 410",rotation:34,duration:0.22,yoyo:true,repeat:13,ease:"sine.inOut"}},{a+0.2:.2f});tl.to("#p1-legR",{{svgOrigin:"190 410",rotation:-34,duration:0.22,yoyo:true,repeat:13,ease:"sine.inOut"}},{a+0.2:.2f});')
js.append(f'tl.to("#p1-armL",{{svgOrigin:"78 268",rotation:-50,duration:0.22,yoyo:true,repeat:13,ease:"sine.inOut"}},{a+0.2:.2f});tl.to("#p1-armR",{{svgOrigin:"222 268",rotation:50,duration:0.22,yoyo:true,repeat:13,ease:"sine.inOut"}},{a+0.2:.2f});')
a = T('r1')
js.append(f'tl.from("#r1-bot",{{y:200,opacity:0,duration:0.35,ease:"power3.out"}},{a+0.05:.2f});tl.from("#r1-bl",{{y:400,duration:0.4,ease:"power3.out"}},{a+0.05:.2f});')
js.append(f'tl.to("#r1-clk",{{rotation:8,duration:0.06,yoyo:true,repeat:39,ease:"none"}},{a+0.5:.2f});')
for i in (1, 2, 3):
    js.append(f'tl.from("#r1-z{i}",{{opacity:0,y:60,scale:0.3,duration:0.5,ease:"power2.out"}},{a+0.6+i*0.5:.2f});')
pop('#r1-bd', a + 1.4)
js.append(f'tl.to("#r1-bot",{{y:"+=10",duration:1.0,yoyo:true,repeat:3,ease:"sine.inOut"}},{a+0.6:.2f});')
# r2
a = T('p2')
js.append(f'tl.from("#p2-bot",{{x:-300,opacity:0,duration:0.4,ease:"back.out(1.4)"}},{a+0.05:.2f});tl.from("#p2-bowl",{{y:300,opacity:0,duration:0.4,ease:"back.out(1.6)"}},{a+0.3:.2f});')
js.append(f'tl.to("#p2-body",{{y:-12,duration:0.4,yoyo:true,repeat:5,ease:"sine.inOut"}},{a+0.4:.2f});tl.to("#p2-bowl",{{rotation:6,duration:0.4,yoyo:true,repeat:5,ease:"sine.inOut"}},{a+0.4:.2f});')
a = T('r2')
js.append(f'tl.from("#r2-bot",{{scale:0.5,opacity:0,duration:0.35,ease:"back.out(2)"}},{a+0.05:.2f});tl.from("#r2-pot",{{y:300,opacity:0,duration:0.35,ease:"power3.out"}},{a+0.05:.2f});')
for i in range(6):
    js.append(f'tl.from("#r2-pl i:nth-child({i+1})",{{y:-500,opacity:0,duration:0.3,ease:"bounce.out"}},{a+0.5+i*0.4:.2f});')
for i in (1, 2, 3):
    js.append(f'tl.fromTo("#r2-st{i}",{{y:0,opacity:0}},{{y:-160,opacity:0.8,duration:1.1,repeat:2,ease:"power1.out"}},{a+0.2+i*0.3:.2f});')
js.append(f'tl.to("#r2-body",{{y:-10,duration:0.18,yoyo:true,repeat:15,ease:"sine.inOut"}},{a+0.3:.2f});')
# r3
a = T('p3')
js.append(f'tl.from("#p3-bot",{{x:-300,opacity:0,duration:0.4,ease:"back.out(1.4)"}},{a+0.05:.2f});tl.from("#p3-pig",{{y:300,opacity:0,duration:0.4,ease:"back.out(1.6)"}},{a+0.2:.2f});')
js.append(f'tl.fromTo("#p3-c",{{y:-120,opacity:1}},{{y:260,duration:0.45,repeat:3,ease:"power2.in"}},{a+0.7:.2f});')
pop('#p3-bd', a + 0.4)
js.append(f'tl.to("#p3-body",{{y:-12,duration:0.4,yoyo:true,repeat:5,ease:"sine.inOut"}},{a+0.4:.2f});')
a = T('r3')
js.append(f'tl.from("#r3-bot",{{x:-300,opacity:0,duration:0.35,ease:"back.out(1.4)"}},{a+0.05:.2f});tl.from("#r3-cart",{{x:500,opacity:0,duration:0.4,ease:"power3.out"}},{a+0.1:.2f});')
pop('#r3-bd', a + 0.5); pop('#r3-bd2', a + 2.0)
js.append(f'tl.to("#r3-cart",{{rotation:-4,duration:0.5,yoyo:true,repeat:5,ease:"sine.inOut",transformOrigin:"50% 100%"}},{a+0.6:.2f});tl.to("#r3-head",{{svgOrigin:"150 222",rotation:6,duration:0.7,yoyo:true,repeat:4,ease:"sine.inOut"}},{a+0.4:.2f});')
# r4
a = T('p4')
js.append(f'tl.from("#p4-bot",{{x:-300,opacity:0,duration:0.4,ease:"back.out(1.4)"}},{a+0.05:.2f});tl.from("#p4-lap",{{y:300,opacity:0,duration:0.4,ease:"back.out(1.6)"}},{a+0.2:.2f});tl.from("#p4-clk",{{scale:0,rotation:-60,duration:0.4,ease:"back.out(2)"}},{a+0.3:.2f});')
js.append(f'tl.to("#p4-armL",{{svgOrigin:"78 268",rotation:-12,duration:0.16,yoyo:true,repeat:9,ease:"sine.inOut"}},{a+0.5:.2f});tl.to("#p4-armR",{{svgOrigin:"222 268",rotation:12,duration:0.16,yoyo:true,repeat:9,ease:"sine.inOut"}},{a+0.5:.2f});')
a = T('r4')
js.append(f'tl.from("#r4-bot",{{x:-300,opacity:0,duration:0.35,ease:"back.out(1.4)"}},{a+0.05:.2f});tl.from("#r4-ph",{{y:500,opacity:0,duration:0.4,ease:"power3.out"}},{a+0.1:.2f});tl.from("#r4-clk",{{scale:0,duration:0.35,ease:"back.out(2)"}},{a+0.3:.2f});')
pop('#r4-bd', a + 1.4)
js.append(f'tl.to("#r4-ph",{{rotation:5,duration:0.25,yoyo:true,repeat:11,ease:"sine.inOut"}},{a+0.6:.2f});tl.to("#r4-body",{{y:-14,duration:0.22,yoyo:true,repeat:13,ease:"sine.inOut"}},{a+0.4:.2f});')
# outro
a = T('s5')
js.append(f'tl.from("#s5-a",{{x:-400,opacity:0,duration:0.45,ease:"back.out(1.4)"}},{a+0.1:.2f});tl.from("#s5-b",{{x:400,opacity:0,duration:0.45,ease:"back.out(1.4)"}},{a+0.2:.2f});')
js.append(f'tl.fromTo("#s5-c1",{{opacity:0,scale:0.3}},{{opacity:1,scale:1,duration:0.35,ease:"back.out(2)"}},{a+0.15:.2f});tl.to("#s5-c1",{{opacity:0,duration:0.15}},{a+1.8:.2f});')
js.append(f'tl.fromTo("#s5-c2",{{opacity:0,scale:0.3}},{{opacity:1,scale:1,duration:0.35,ease:"back.out(2)"}},{a+2.0:.2f});')
js.append(f'tl.fromTo("#s5-c3",{{opacity:0,y:120}},{{opacity:1,y:0,duration:0.4,ease:"power3.out"}},{a+4.6:.2f});')
js.append(f'tl.to("#s5a-body",{{y:-16,duration:0.35,yoyo:true,repeat:19,ease:"sine.inOut"}},{a+0.6:.2f});tl.to("#s5b-body",{{y:-16,duration:0.35,yoyo:true,repeat:19,ease:"sine.inOut"}},{a+0.75:.2f});')

CSS = '''
@font-face{font-family:P;font-weight:700;src:url(assets/prompt-thai-700-normal.woff2)}
@font-face{font-family:P;font-weight:800;src:url(assets/prompt-thai-800-normal.woff2)}
*{box-sizing:border-box;margin:0}
body{margin:0;background:#000;font-family:P,sans-serif}
#root{position:relative;width:1080px;height:1920px;overflow:hidden;background:#000}
.sc{position:absolute;left:0;top:0;width:1080px;height:1920px;overflow:hidden}
.bg{position:absolute;inset:0}
.pos{position:absolute}.prop{position:absolute}
.ground{position:absolute;left:0;right:0;top:1440px;height:480px}
.ttl{position:absolute;left:0;right:0;text-align:center;font-weight:800;font-size:110px;color:#fff;text-shadow:6px 6px 0 #000,-3px -3px 0 #000,3px -3px 0 #000,-3px 3px 0 #000}
.ttl.big{font-size:150px}
.lbl{position:absolute;font-weight:800;font-size:60px;padding:6px 36px;border:8px solid #000;box-shadow:8px 8px 0 #000;color:#fff}
.ok{background:#1fae6a;color:#fff}.bad{background:#d62839;color:#fff}
.tag{position:absolute;left:50px;top:70px;font-weight:800;font-size:76px;padding:6px 40px;border:8px solid #000;box-shadow:8px 8px 0 #000;color:#fff}
.rnd{position:absolute;right:50px;top:84px;font-weight:800;font-size:54px;color:#fff;text-shadow:4px 4px 0 #000,-2px -2px 0 #000}
.cap{position:absolute;left:50px;right:50px;top:1640px;text-align:center;font-weight:800;font-size:76px;line-height:1.25;color:#fff;text-shadow:6px 6px 0 #000,-3px -3px 0 #000,3px -3px 0 #000,-3px 3px 0 #000}
.clk{position:absolute;left:0;right:0;top:66px;text-align:center;font-weight:800;font-size:38px;color:#111;font-family:monospace}
.blanket{position:absolute;left:150px;top:1290px;width:780px;height:330px;background:#5a6bd1;border-radius:60px 60px 0 0;border:8px solid #2b3578}
.zz{position:absolute;font-weight:800;font-size:70px;color:#9dc4ff;text-shadow:4px 4px 0 #000}
.badge{position:absolute;font-weight:800;font-size:80px;padding:6px 36px;background:#ffd23f;color:#000;border:8px solid #000;box-shadow:8px 8px 0 #000;transform:rotate(-3deg)}
.badge.ok{background:#1fae6a;color:#fff}.badge.bad{background:#d62839;color:#fff}
.plates{position:absolute;left:760px;top:1020px;width:200px}
.plates i{display:block;width:200px;height:34px;border-radius:50%;background:#fff;border:6px solid #222;margin-top:-6px}
.steam{position:absolute;width:40px;height:170px;border-radius:30px;background:linear-gradient(#ffffffcc,#ffffff00)}
.coin{position:absolute;left:630px;top:1040px;width:80px;height:80px;border-radius:50%;background:#ffd23f;border:8px solid #222}
.card{position:absolute;left:60px;right:60px;text-align:center;font-weight:800;font-size:88px;padding:26px 20px;background:#fff;color:#000;border:10px solid #000;box-shadow:12px 12px 0 #000}
.card.cta{background:#ff3d81;color:#fff;font-size:64px;line-height:1.3}
.kw{display:inline-block;background:#fff;color:#000;border:8px solid #000;padding:0 24px;margin-top:14px;font-size:76px}
'''
head_vars = ''
out = f'''<!doctype html>
<html lang="th">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=1080, height=1920"/>
<title>Plan vs Reality</title>
<script src="assets/gsap.min.js"></script>
<style>{CSS}</style>
</head>
<body>
<div id="root" data-composition-id="main" data-width="{W}" data-height="{H}" data-duration="{DUR}">
{html_scenes}{audio}</div>
<script>
window.__timelines = window.__timelines || {{}};
const tl = gsap.timeline({{ paused: true }});
{chr(10).join(js)}
window.__timelines["main"] = tl;
</script>
</body>
</html>
'''
open('/home/user/CLOUD/ai-ladmue/clips/c16/hf/index.html', 'w', encoding='utf-8').write(out)
print('ok', len(out))
