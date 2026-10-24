import sys; sys.path.insert(0, '/home/user/CLOUD/ai-ladmue/clips')
from hfkit import *
DUR = 14.6
rows = [('S', '#ff7f7f', 'ฝนตก', 3.76), ('A', '#ffbf7f', 'พรุ่งนี้ค่อยไป', 5.6), ('B', '#ffff7f', 'หาเสื้อไม่เจอ', 7.72), ('F', '#9fa8ff', 'ขี้เกียจ', 10.2)]
board = ''
for i, (lab, col, item, t) in enumerate(rows):
    board += f'<div class="row" style="top:{i*190}px"><div class="lab" style="background:{col}">{lab}</div><div class="cells" style="background:#2a2a35"><div class="chip" id="chip{i}">{item}</div></div></div>'
body = f'''<div class="bg" style="background:linear-gradient(#1b1b22,#0a0a0e)"></div><div class="cone c1" id="c1"></div><div class="cone c2" id="c2"></div>
<div class="title" id="ttl"><div>{chars('จัดอันดับข้ออ้าง')}</div><div class="sp">{chars('ตอนไม่ไปออกกำลังกาย')}</div></div>
<div class="board" id="board">{board}</div>
<div class="ab" id="ra" style="left:40px;top:1210px;transform:scale(0.95);transform-origin:0 0">{robot("sleepy", uid="ra")}</div>
<div class="ab" id="rb" style="left:700px;top:1230px;transform:scale(0.95);transform-origin:0 0">{teal("worried", "rb")}</div>
<div class="stampf" id="stf">ใช้บ่อยที่สุด!</div>
<div class="q" id="q">คุณใช้ข้อไหน?</div>
<div class="cta" id="cta">คอมเมนต์บอกหน่อย!</div>
<div class="sub" id="sub"></div>'''
body = body.replace("<div class=\"title\"", "<div class=\"title\"")
conf = ''.join(f'<i class="cf" style="background:{c}"></i>' for c in ['#ff7f7f','#ffbf7f','#ffff7f','#9fa8ff','#fff','#29e5ff']*5)
sections = section('t', 0, DUR, '<div class="cam" id="cam-t">' + body + conf + '</div>')
css = AE_CSS + '''
.cone{position:absolute;top:-200px;width:700px;height:2300px;background:linear-gradient(#ffffff30,#ffffff00);clip-path:polygon(40% 0,60% 0,100% 100%,0 100%);transform-origin:50% 0}
.c1{left:-100px}.c2{right:-100px}
.title .sp{font-size:76px;color:#ffd60a}
.cf{position:absolute;left:540px;top:520px;width:18px;height:30px;opacity:0}
.title{position:absolute;left:30px;right:30px;top:90px;text-align:center;font-weight:800;font-size:96px;line-height:1.15;color:#fff;text-shadow:6px 6px 0 #000,-3px -3px 0 #000,3px -3px 0 #000,-3px 3px 0 #000}.title span{font-size:76px;color:#ffd23f}
.board{position:absolute;left:60px;top:400px;width:960px;height:760px;border:10px solid #000;box-shadow:12px 12px 0 #000;background:#000}
.row{position:absolute;left:0;width:940px;height:190px;display:flex}
.lab{width:190px;height:190px;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:130px;color:#111;border-bottom:6px solid #000}
.cells{flex:1;height:190px;border-bottom:6px solid #000;position:relative}
.chip{position:absolute;left:30px;top:35px;background:#fff;color:#111;font-weight:800;font-size:68px;padding:8px 36px;border-radius:24px;border:6px solid #000;box-shadow:6px 6px 0 #000}
.stampf{position:absolute;right:50px;top:1010px;font-weight:800;font-size:76px;color:#fff;background:#d62839;border:10px solid #fff;padding:4px 30px;transform:rotate(-8deg);box-shadow:8px 8px 0 #000;z-index:6}
.q{position:absolute;left:0;right:0;top:1560px;text-align:center;font-weight:800;font-size:96px;color:#fff;text-shadow:6px 6px 0 #000}
.cta{position:absolute;left:80px;right:80px;top:1700px;text-align:center;font-weight:800;font-size:78px;color:#111;background:#ffd23f;border:10px solid #000;box-shadow:10px 10px 0 #000;padding:6px}
.sub{position:absolute;left:40px;right:40px;top:1480px;text-align:center}
'''
js = []
import random as _r
_rr = _r.Random(8)
js.append('tl.to("#ttl",{scale:1.04,duration:0.3,yoyo:true,repeat:9,ease:"sine.inOut",transformOrigin:"50% 50%"},0.1);tl.to("#ra-body,#rb-body",{y:-10,duration:0.35,yoyo:true,repeat:39,ease:"sine.inOut"},0.2);')
for i, (lab, col, item, t) in enumerate(rows):
    js.append(f'tl.from("#chip{i}",{{y:-700,opacity:0,rotation:-15,duration:0.45,ease:"bounce.out"}},{t:.2f});')
js.append('tl.from("#stf",{scale:3,opacity:0,rotation:-25,duration:0.3,ease:"power4.in"},10.7);tl.from("#q",{scale:0.2,opacity:0,duration:0.3,ease:"back.out(2)"},12.0);tl.from("#cta",{y:200,opacity:0,duration:0.35,ease:"back.out(1.6)"},13.05);')
# hide q before cta so layout does not collide
js.append('tl.to("#q",{opacity:0,duration:0.1},13.0);')
sections += ae_overlay_html(("#ff7f7f", "#ffff7f", "#111")).replace('__DUR__', str(DUR))
js += cam_js('t', 0, DUR, 0.5, 0.06)
js += ae_overlay_js(DUR, [3.76, 5.6, 7.72, 10.2, 12.0])
js.append('tl.fromTo("#c1",{rotation:-22},{rotation:22,duration:14.6,ease:"sine.inOut"},0);tl.fromTo("#c2",{rotation:22},{rotation:-22,duration:14.6,ease:"sine.inOut"},0);')
js.append('tl.from("#ttl .ch",{y:120,opacity:0,rotation:8,duration:0.5,stagger:0.03,ease:"back.out(2.2)"},0.0) if False else None') if False else None
js.append('tl.from("#ttl .sp .ch",{y:80,opacity:0,duration:0.4,stagger:0.02,ease:"back.out(2)"},0.3);')
for _t in (3.76, 5.6, 7.72, 10.2):
    js.append(f'tl.fromTo("#chip{[3.76,5.6,7.72,10.2].index(_t)}",{{scaleY:1}},{{scaleY:0.7,duration:0.08,yoyo:true,repeat:1,ease:"power2.out",transformOrigin:"50% 100%"}},{_t+0.42:.2f});')
for k in range(30):
    ang = _rr.uniform(-3.14, 0.0); dist = _rr.uniform(300, 700)
    import math
    js.append(f'tl.fromTo(".cf:nth-of-type({k+1})",{{x:0,y:0,opacity:1,rotation:0}},{{x:{math.cos(ang)*dist:.0f},y:{math.sin(ang)*dist+500:.0f},opacity:0,rotation:{_rr.randint(-540,540)},duration:1.4,ease:"power2.out"}},3.9);')
audio = audio_el(0, 'v', 0.05, 14.1) + bed_audio(DUR, 0.4)
write_index('/home/user/CLOUD/ai-ladmue/clips/c26/hf/index.html', 'Tier', css, sections, audio, js, DUR)
s = Sfx(DUR)
for t in (3.76, 5.6, 7.72, 10.2): s.thud(t); s.pop(t + 0.2, 500)
s.scratch(10.7); s.womp(10.95); s.ding(13.05, 1760); s.pop(12.0)
for t in (2.76, 4.58, 6.8, 9.07): s.whoosh(t, 0.25)
s.save('/home/user/CLOUD/ai-ladmue/clips/c26/hf/assets/sfx.wav'); print('ok')
