import sys; sys.path.insert(0, '/home/user/CLOUD/ai-ladmue/clips')
from hfkit import *
DUR = 14.3
INK, RED, YEL, CYA, WHT = '#0c0c12', '#ff3b30', '#ffd60a', '#29e5ff', '#ffffff'
SC = [('k0', 0, 1.25, RED), ('k1', 1.25, 2.85, INK), ('k2', 2.85, 5.75, YEL), ('k3', 5.75, 8.3, CYA), ('k4', 8.3, 10.75, '#b6ff5c'), ('k5', 10.75, 11.65, RED), ('k6', 11.65, DUR, INK)]
# (sid, line id, text, top, size, colour, start-time, extra class)
LINES = [
 ('k0', 'a', 'AI', 470, 330, WHT, None, ''), ('k0', 'b', 'ตอบมั่ว?', 840, 250, WHT, None, ''),
 ('k1', 'a', 'ลองสั่ง', 560, 220, WHT, 1.27, ''), ('k1', 'b', '3 ประโยค', 880, 250, YEL, 1.75, ''),
 ('k2', 'a', 'ถ้าไม่แน่ใจ', 880, 160, INK, 3.45, ''), ('k2', 'b', 'ให้บอกว่า', 1075, 130, INK, 4.1, ''), ('k2', 'c', '“ไม่แน่ใจ”', 1250, 190, YEL, 4.6, 'pill'),
 ('k3', 'a', 'ใช้เฉพาะ', 880, 180, INK, 6.45, ''), ('k3', 'b', 'ข้อมูลที่', 1075, 180, INK, 6.95, ''), ('k3', 'c', 'ฉันให้', 1270, 220, CYA, 7.35, 'pill'),
 ('k4', 'a', 'ก่อนตอบ', 880, 180, INK, 8.95, ''), ('k4', 'b', 'ตรวจซ้ำ', 1075, 180, INK, 9.55, ''), ('k4', 'c', 'อีกรอบ', 1270, 220, '#b6ff5c', 10.05, 'pill'),
 ('k5', 'a', 'เซฟไว้!', 740, 330, WHT, 10.77, ''),
 ('k6', 'a', 'คอมเมนต์คำว่า', 480, 130, WHT, 11.67, ''), ('k6', 'c', 'รับชุดคำสั่งฟรี', 1230, 120, YEL, 13.2, ''),
]
NUM = {'k2': '1', 'k3': '2', 'k4': '3'}
FG = {'k0': WHT, 'k1': WHT, 'k2': INK, 'k3': INK, 'k4': INK, 'k5': WHT, 'k6': WHT}
GEO = {'k0': WHT, 'k1': YEL, 'k2': INK, 'k3': INK, 'k4': INK, 'k5': WHT, 'k6': YEL}
sections = ''
for sid, a, b, bg in SC:
    ls = ''
    for (s2, lid, text, top, size, col, t0, cls) in LINES:
        if s2 != sid: continue
        if cls == 'pill':
            ls += f'<div class="ln pill" id="{sid}-{lid}p" style="top:{top-20}px;background:{INK if bg!=INK else YEL}"></div>'
        ls += f'<div class="ln" id="{sid}-{lid}" style="top:{top}px;font-size:{size}px;color:{col}"><div class="echo" style="-webkit-text-stroke:3px {col}">{chars(text)}</div><div class="main">{chars(text)}</div></div>'
    if sid == 'k6':
        ls += f'<div class="kw" id="k6-b"><div class="kwi">{chars("prompt")}</div></div>'
    if sid in NUM:
        ls += f'<div class="num" id="{sid}-n" style="color:{INK}"><div class="echo" style="-webkit-text-stroke:5px {INK}">{NUM[sid]}</div><div class="main">{NUM[sid]}</div></div>'
    geo = f'<div class="geo g1" id="{sid}-g1" style="border-color:{GEO[sid]}"></div><div class="geo g2" id="{sid}-g2" style="border-color:{GEO[sid]}"></div><div class="ring" id="{sid}-r" style="border-color:{GEO[sid]}"></div>'
    pts = particles_html(26, hash(sid) % 1000, sid)
    sections += section(sid, a, b, f'<div class="bg" style="background:{bg}"></div><div class="cam" id="cam-{sid}">{geo}{pts}{ls}<div class="hdl" style="color:{FG[sid]}">@ailadmue</div></div>')
sections += ae_overlay_html((RED, YEL, INK)).replace('__DUR__', str(DUR))
css = AE_CSS + '''
.ln{position:absolute;left:0;right:0;text-align:center;font-weight:800;line-height:1.1}
.ln .main{position:relative}.ln .echo{position:absolute;left:0;right:0;top:0;color:transparent;transform:translate(16px,16px);opacity:.55}
.ln.pill{left:70px;right:70px;height:260px;border-radius:40px}
.num{position:absolute;left:0;right:0;top:130px;text-align:center;font-weight:800;font-size:660px;line-height:1}
.num .main{position:relative}.num .echo{position:absolute;left:0;right:0;top:0;color:transparent;transform:translate(26px,26px);opacity:.5}
.geo{position:absolute;border:8px solid;opacity:.35}.g1{left:-120px;top:1200px;width:500px;height:500px;transform:rotate(18deg)}.g2{right:-160px;top:120px;width:560px;height:560px;transform:rotate(-12deg)}
.ring{position:absolute;left:290px;top:660px;width:500px;height:500px;border:10px solid;border-radius:50%;opacity:.4}
.pt{position:absolute;border-radius:50%}
.hdl{position:absolute;left:0;right:0;top:1790px;text-align:center;font-weight:700;font-size:44px;opacity:.7}
.kw{position:absolute;left:90px;right:90px;top:720px;text-align:center;font-weight:800;font-size:220px;background:#ffd60a;color:#0c0c12;border-radius:40px;padding:14px 0;transform-origin:50% 50%}
.kwi{display:inline-block}
'''
js = []
# camera drift on every scene + per-scene shapes
for sid, a, b, bg in SC:
    js += cam_js(sid, a, b)
    js.append(f'tl.fromTo("#{sid}-g1",{{rotation:18}},{{rotation:80,duration:{b-a:.2f},ease:"none"}},{a});tl.fromTo("#{sid}-g2",{{rotation:-12}},{{rotation:-70,duration:{b-a:.2f},ease:"none"}},{a});')
    js.append(f'tl.fromTo("#{sid}-r",{{scale:0.3,opacity:0.6}},{{scale:2.4,opacity:0,duration:{min(1.2,b-a):.2f},ease:"expo.out"}},{a+0.02:.2f});')
    js += particles_js(sid, a, b, 3)
# letters
def reveal(sel, t, stag=0.035):
    js.append(f'tl.from("{sel} .main .ch",{{y:150,opacity:0,rotation:10,scale:0.6,duration:0.5,stagger:{stag},ease:"back.out(2.4)"}},{t:.2f});tl.from("{sel} .echo .ch",{{y:150,opacity:0,duration:0.5,stagger:{stag},ease:"back.out(2.4)"}},{t+0.12:.2f});')
for (sid, lid, text, top, size, col, t0, cls) in LINES:
    if t0 is None: continue
    reveal(f'#{sid}-{lid}', t0)
    if cls == 'pill': js.append(f'tl.from("#{sid}-{lid}p",{{scaleX:0,duration:0.35,ease:"expo.out",transformOrigin:"0 50%"}},{t0-0.05:.2f});')
for sid in NUM:
    a = S = [x for x in SC if x[0] == sid][0][1]
    js.append(f'tl.from("#{sid}-n .main",{{scale:0.2,opacity:0,rotation:-14,duration:0.45,ease:"back.out(2.4)"}},{a+0.03:.2f});tl.from("#{sid}-n .echo",{{scale:0.2,opacity:0,duration:0.5,ease:"back.out(2)"}},{a+0.15:.2f});')
# k0 (frame-0 safe): shake + echo pulse only
js.append('tl.to("#k0-a .main,#k0-b .main",{x:10,duration:0.05,yoyo:true,repeat:21,ease:"none"},0.0);tl.fromTo("#k0-a .echo,#k0-b .echo",{x:-20,y:-20},{x:0,y:0,duration:0.5,ease:"expo.out"},0.0);')
js.append('tl.from("#k6-b",{scaleX:0,duration:0.4,ease:"expo.out"},12.55);tl.from("#k6-b .ch",{y:120,opacity:0,stagger:0.05,duration:0.4,ease:"back.out(2.4)"},12.65);tl.to("#k6-b",{scale:1.05,duration:0.3,yoyo:true,repeat:4,ease:"sine.inOut"},13.2);')
js += punch_js('#cam-k5', 10.77, 0.06)
for t in (3.45, 6.45, 8.95): js += punch_js('#cam-k2' if t < 5 else ('#cam-k3' if t < 8 else '#cam-k4'), t, 0.04)
js += ae_overlay_js(DUR, [c[1] for c in SC[1:]])
audio = audio_el(0, 'v', 0.05, 13.87) + bed_audio(DUR, 0.4)
write_index('/home/user/CLOUD/ai-ladmue/clips/c24/hf/index.html', 'Kinetic AE', css, sections, audio, js, DUR)
s = Sfx(DUR)
for t in (1.25, 2.85, 5.75, 8.3, 10.75, 11.65): s.whoosh(t - 0.05, 0.3); s.thud(t)
s.ding(10.8, 1568); s.ding(12.6, 1760)
for t in (3.45, 4.1, 4.6, 6.45, 6.95, 7.35, 8.95, 9.55, 10.05): s.pop(t)
s.save('/home/user/CLOUD/ai-ladmue/clips/c24/hf/assets/sfx.wav'); print('ok', len(js))
