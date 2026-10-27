import sys; sys.path.insert(0, '/home/user/CLOUD/ai-ladmue/clips')
from hfkit import *
DUR = 17.7
doc = '<svg width="150" height="190" viewBox="0 0 150 190"><rect x="8" y="8" width="134" height="174" rx="8" fill="#fff" stroke="#111" stroke-width="7"/>' + ''.join(f'<rect x="26" y="{30+i*22}" width="{98 if i%3 else 70}" height="9" fill="#999"/>' for i in range(7)) + '</svg>'
body = f'''<div class="bg" style="background:#ffe66b"></div><div class="dots"></div>
<div class="hd" id="hd">สั่ง AI ว่า<br><span>“ย่อให้สั้นลง”</span></div>
<div class="pn" id="p1" style="left:40px;top:340px;background:#bfe9ff"><div class="dots2"></div>
 <div class="ab" style="left:200px;top:210px;transform:scale(.62);transform-origin:0 0">{teal("happy", "p1a")}</div><div class="ab" id="p1d" style="left:40px;top:300px;transform:scale(1.4);transform-origin:0 0">{doc}</div>
 <div class="bub" id="b1" style="left:20px;top:20px;width:420px">ช่วยย่อบทความนี้ ให้สั้นลงหน่อย</div></div>
<div class="pn" id="p2" style="left:560px;top:340px;background:#ffd9b0"><div class="dots2"></div>
 <div class="ab" style="left:30px;top:215px;transform:scale(.62);transform-origin:0 0">{robot("proud", uid="p2a")}</div>
 <div class="ab" id="p2d" style="left:290px;top:330px;transform-origin:50% 100%">{doc}</div><div class="oneword" id="ow">ดี</div>
 <div class="bub r" id="b2" style="left:20px;top:20px;width:420px">ได้ครับ! สรุปคือ... ดี.</div></div>
<div class="pn" id="p3" style="left:40px;top:1020px;background:#ff8a8a"><div class="burst"></div>
 <div class="ab" id="p3a" style="left:130px;top:200px;transform:scale(.7);transform-origin:0 0">{teal("angry", "p3a")}</div>
 <div class="bub" id="b3" style="left:20px;top:20px;width:420px;font-size:54px">ผมหมายถึง สามบรรทัด!</div><div class="pow" id="pow">!!!</div></div>
<div class="pn" id="p4" style="left:560px;top:1020px;background:#b9ffb0"><div class="dots2"></div>
 <div class="tip" id="tp">เคล็ดลับ!<br><span>สั่งให้ระบุความยาว</span></div>
 <div class="code" id="cd">“สรุปเป็น<br>สามบรรทัด”</div>
</div>
<div class="cta" id="cta">เซฟไว้! คอมเมนต์ <b>prompt</b> รับชุดคำสั่งฟรี</div>'''
sections = section('c', 0, DUR, '<div class="cam" id="cam-c">' + body + '</div>')
css = AE_CSS + '''
.pn{transform-style:preserve-3d}
.dots,.dots2{position:absolute;inset:0;background-image:radial-gradient(#00000022 3px,transparent 3.5px);background-size:22px 22px}
.hd{position:absolute;left:30px;right:30px;top:90px;text-align:center;font-weight:800;font-size:92px;line-height:1.1;color:#111}.hd span{background:#111;color:#ffe66b;padding:0 24px;border-radius:16px;display:inline-block;margin-top:8px}
.pn{position:absolute;width:480px;height:640px;border:12px solid #111;box-shadow:10px 10px 0 #111;overflow:hidden}
.bub{position:absolute;background:#fff;border:8px solid #111;border-radius:30px;font-weight:800;font-size:46px;line-height:1.2;padding:16px 18px;color:#111;text-align:center;z-index:4}
.bub.r{background:#fff6c4}
.oneword{position:absolute;left:30px;top:430px;width:200px;text-align:center;font-weight:800;font-size:120px;color:#d62839;background:#fff;border:8px solid #111;border-radius:20px}
.burst{position:absolute;inset:-40px;background:repeating-conic-gradient(#ff3b3b 0 10deg,#ffb3b3 10deg 20deg);opacity:.55}
.pow{position:absolute;right:20px;top:240px;font-weight:800;font-size:150px;color:#ffe66b;text-shadow:8px 8px 0 #111,-4px -4px 0 #111,4px -4px 0 #111,-4px 4px 0 #111;transform:rotate(12deg);z-index:5}
.tip{position:absolute;left:20px;right:20px;top:30px;text-align:center;font-weight:800;font-size:76px;line-height:1.15;color:#111}.tip span{font-size:56px;background:#111;color:#b9ffb0;padding:0 14px;border-radius:12px;display:inline-block;margin-top:8px}
.code{position:absolute;left:30px;right:30px;top:290px;background:#111;color:#9dff7a;font-weight:800;font-size:72px;line-height:1.2;text-align:center;border-radius:24px;padding:26px 10px;font-family:P,monospace}
.cta{position:absolute;left:40px;right:40px;top:1700px;text-align:center;font-weight:800;font-size:54px;background:#ff3d81;color:#fff;border:10px solid #111;box-shadow:10px 10px 0 #111;padding:14px;z-index:9}.cta b{background:#fff;color:#111;padding:0 18px;border-radius:10px}
'''
js = []
js.append('tl.to("#hd",{scale:1.03,duration:0.3,yoyo:true,repeat:7,ease:"sine.inOut",transformOrigin:"50% 50%"},0.1);tl.to("#p1a-body",{y:-8,duration:0.3,yoyo:true,repeat:5,ease:"sine.inOut"},0.2);')
def panel(sel, t): js.append(f'tl.from("{sel}",{{rotationY:90,scale:0.6,opacity:0,transformPerspective:900,duration:0.5,ease:"back.out(1.6)",transformOrigin:"50% 50%"}},{t:.2f});')
panel('#p2', 2.65); panel('#p3', 7.0); panel('#p4', 9.05)
js.append('tl.to("#p2d",{scaleY:0.2,scaleX:0.5,duration:1.2,ease:"power2.in"},4.75);tl.from("#ow",{scale:3,opacity:0,rotation:-20,duration:0.3,ease:"power4.in"},6.05);')
js.append('tl.to("#p3a",{x:10,duration:0.06,yoyo:true,repeat:19,ease:"none"},7.2);tl.from("#pow",{scale:0.1,opacity:0,rotation:-40,duration:0.35,ease:"back.out(3)"},8.0);')
js.append('tl.from("#tp",{y:-80,opacity:0,duration:0.3,ease:"power3.out"},9.5);tl.from("#cd",{scale:0.3,opacity:0,duration:0.35,ease:"back.out(2)"},12.5);')
js.append('tl.from("#cta",{y:200,opacity:0,duration:0.35,ease:"back.out(1.6)"},14.05);')
sections += ae_overlay_html(("#ff3b30", "#ffe66b", "#111")).replace('__DUR__', str(DUR))
js += ae_overlay_js(DUR, [2.65, 7.0, 9.05, 14.05])
# AE camera: push into whichever panel is talking, pull back between
for (t0, t1, ox, oy) in [(2.7, 6.9, 800, 660), (7.05, 9.0, 280, 1340), (9.1, 13.9, 800, 1340)]:
    js.append(f'tl.set("#cam-c",{{transformOrigin:"{ox}px {oy}px"}},{t0-0.05:.2f});tl.to("#cam-c",{{scale:1.38,x:{540-ox},y:{int((960-oy)*0.7)},duration:0.5,ease:"expo.out"}},{t0:.2f});tl.to("#cam-c",{{scale:1,x:0,y:0,duration:0.45,ease:"expo.inOut"}},{t1:.2f});')
js.append('tl.to("#cam-c",{rotation:0.8,duration:17.7,ease:"none"},0);')
js.append('tl.fromTo(".burst",{rotation:0},{rotation:60,duration:6,ease:"none"},7.0);')
audio = audio_el(0, 'v1', 0.05, 2.27) + audio_el(1, 'v2', 2.7, 4.05) + audio_el(2, 'v3', 7.0, 10.27) + bed_audio(DUR, 0.35)
write_index('/home/user/CLOUD/ai-ladmue/clips/c27/hf/index.html', 'Comic', css, sections, audio, js, DUR)
s = Sfx(DUR)
for t in (2.65, 7.0, 9.05): s.whoosh(t - 0.02, 0.25); s.pop(t, 500)
s.put(s.tone(1400, 1.2, 'sin', f1=300, env=1.5, vol=0.3), 4.75); s.scratch(6.05); s.womp(6.3)
s.thud(8.0); s.put(s.noise(0.3, env=10, lp=5, vol=0.7), 8.0)
s.ding(12.5, 1568); s.ding(14.05, 1760)
s.save('/home/user/CLOUD/ai-ladmue/clips/c27/hf/assets/sfx.wav'); print('ok')
