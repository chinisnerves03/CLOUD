import sys, wave; sys.path.insert(0, '/home/user/CLOUD/ai-ladmue/clips')
from hfkit import *
import numpy as np
DUR = 37.0
L = {1: (0.10, 5.49), 2: (5.80, 4.68), 3: (10.70, 7.71), 4: (18.65, 7.08), 5: (25.95, 5.49), 6: (31.65, 4.91)}
SUBS = {1: 'หนี้สามก้อนเดิม จ่ายคนละลำดับ ดอกเบี้ยต่างกัน สองพันกว่าบาท!', 2: 'ใส่ยอดหนี้ ดอกเบี้ย กับค่างวดขั้นต่ำ ไฟล์คำนวณให้เอง',
        3: 'เลือกจ่ายดอกเบี้ยสูงสุดก่อน หมดหนี้ 17 เดือน ดอกเบี้ยรวม 17,565 บาท', 4: 'ถ้าเลือกยอดน้อยสุดก่อน ก็หมดใน 17 เดือนเหมือนกัน แต่ดอกเบี้ยรวม 19,620 บาท',
        5: 'ต่างกัน 2,056 บาท! เปลี่ยนวิธีเดียว ตัวเลขเปลี่ยนทันที', 6: 'อยากได้ไฟล์ คอมเมนต์คำว่า แผน แล้วกดลิงก์ในโปรไฟล์ได้เลย'}
js = []
def hl(i, text, a, b, size=116, color='#fff', first=False, extra=''):
    """headline block shown a..b, per-char entrance (not at frame 0 for first)."""
    html = f'<div class="hl" id="hl{i}" style="font-size:{size}px;color:{color};{"" if first else "opacity:0;"}{extra}">{chars(text)}</div>'
    if first:
        js.append(f'tl.to("#hl{i}",{{opacity:0,duration:0.2}},{b-0.2:.2f});')
    else:
        js.append(f'tl.set("#hl{i}",{{opacity:1}},{a:.2f});tl.from("#hl{i} .ch",{{y:70,opacity:0,scale:0.6,stagger:0.025,duration:0.4,ease:"back.out(2.2)"}},{a:.2f});tl.to("#hl{i}",{{opacity:0,duration:0.2}},{b-0.2:.2f});')
    return html
heads = ''.join([
    hl(1, 'หนี้ 3 ก้อนเดิม', 0.1, 1.55, 122, '#fff', first=True),
    hl(2, 'จ่ายคนละลำดับ', 1.55, 4.0, 122, '#ffd60a'),
    hl(3, 'ต่างกัน 2,056 บาท', 4.0, 5.75, 112, '#ff7a59'),
    hl(4, 'กรอกแค่ 3 ช่อง', 5.8, 10.65, 118, '#fff'),
    hl(5, 'ดอกเบี้ยสูงสุดก่อน', 10.7, 18.6, 108, '#5eead4'),
    hl(6, 'ยอดน้อยสุดก่อน', 18.65, 25.9, 112, '#ffb347'),
    hl(7, 'ต่างกัน 2,056 บาท!', 25.95, 31.6, 112, '#ff7a59'),
])
# ---- window
rows = [('บัตรเครดิต A', '45,000', '2,250', '16%'), ('ผ่อนมือถือ', '12,000', '1,500', '0%'), ('สินเชื่อส่วนบุคคล', '60,000', '2,800', '25%')]
tbl = '<div class="th"><span style="flex:2.2">ชื่อหนี้</span><span>ยอดคงเหลือ</span><span>ขั้นต่ำ/เดือน</span><span>ดอกเบี้ย/ปี</span></div>'
for i, (n, a, m, r) in enumerate(rows):
    tbl += f'<div class="tr" id="row{i}"><span class="c" style="flex:2.2">{n}</span><span class="c y" id="cb{i}">{a}</span><span class="c y" id="cm{i}">{m}</span><span class="c y" id="cr{i}">{r}</span></div>'
tbl += '<div class="sum">หนี้รวม 117,000 บาท  •  งบจ่ายรวม 8,050 บาท/เดือน</div>'
ranks = {'สินเชื่อส่วนบุคคล': '25% / ปี', 'บัตรเครดิต A': '16% / ปี', 'ผ่อนมือถือ': '0% / ปี'}
snow = {'ผ่อนมือถือ': '12,000 บาท', 'บัตรเครดิต A': '45,000 บาท', 'สินเชื่อส่วนบุคคล': '60,000 บาท'}
rk = ''
for j, n in enumerate(['สินเชื่อส่วนบุคคล', 'บัตรเครดิต A', 'ผ่อนมือถือ']):
    rk += f'<div class="rk" id="rk{j}" data-n="{n}"><b id="rkn{j}">{j+1}</b><span class="rt">{n}</span><span class="rs"><span id="rka{j}">{ranks[n]}</span></span></div>'
winB = f'''<div class="dd"><span class="ddl">วิธีปลดหนี้</span><span class="ddv" id="ddA">ดอกเบี้ยสูงสุดก่อน ▾</span><span class="ddv ddo" id="ddB">ยอดน้อยสุดก่อน ▾</span></div>
<div class="rkw" id="rkw">{rk}</div>
<div class="tiles"><div class="tile"><small>หมดหนี้ใน</small><div><b id="mo">0</b> เดือน</div></div><div class="tile" id="tI"><small>ดอกเบี้ยรวม</small><div><b id="iv">0</b> บาท</div></div></div>'''
winC = '''<div class="cmp"><div class="cb" id="cbA"><div class="bar" id="barA" style="background:#10b981"></div><div class="cl">ดอกเบี้ยสูงสุดก่อน<br><b>17,565</b> บาท</div></div>
<div class="cb" id="cbB"><div class="bar" id="barB" style="background:#f97316"></div><div class="cl">ยอดน้อยสุดก่อน<br><b>19,620</b> บาท</div></div></div>
<div class="diff" id="diff">+2,056 บาท</div><div class="note2" id="note2">เปลี่ยนที่ช่องเดียว  ตัวเลขอัปเดตทันที</div>'''
sub = ''.join(f'<div class="sub" id="sub{k}" style="opacity:{1 if k==1 else 0}">{t}</div>' for k, t in SUBS.items())
cta = '''<div class="cta" id="cta"><div class="c1">คอมเมนต์คำว่า</div><div class="pill" id="pill">แผน</div><div class="c2">แล้วกดลิงก์ในโปรไฟล์</div><div class="url" id="url">ailadmue.netlify.app</div><div class="disc">ตัวเลขเป็นตัวอย่างจากไฟล์ ไม่ใช่คำแนะนำการลงทุนหรือการเงิน</div></div>'''
body = f'''<div class="bg" style="background:linear-gradient(170deg,#0b132b,#1c2541 55%,#0f3b3a)"></div><div class="glow"></div>
<div class="brand">AI ลัดมือ <span>@ailadmue</span></div>
<div class="cam" id="cam-c">
 <div class="headzone">{heads}</div>
 <div class="win" id="win"><div class="wh"><i></i><i></i><i></i><span>แผนเงินของฉัน • ปลดหนี้</span></div>
  <div class="wb"><div class="pane" id="pA">{tbl}</div><div class="pane" id="pB" style="opacity:0">{winB}</div><div class="pane" id="pC" style="opacity:0">{winC}</div></div></div>
 <div class="subz">{sub}</div>
 {cta}
</div>'''
css = AE_CSS + '''
.glow{position:absolute;left:-200px;top:300px;width:1500px;height:900px;background:radial-gradient(ellipse,rgba(94,234,212,.22),transparent 60%)}
.brand{position:absolute;top:70px;left:70px;font-weight:800;font-size:42px;color:#fff;z-index:20}.brand span{font-weight:700;font-size:30px;opacity:.7;margin-left:12px}
.headzone{position:absolute;left:40px;right:40px;top:200px;height:330px}
.hl{position:absolute;left:0;right:0;top:60px;text-align:center;font-weight:800;line-height:1.15;text-shadow:0 8px 40px rgba(0,0,0,.45)}
.win{position:absolute;left:60px;top:560px;width:960px;height:860px;background:#fff;border-radius:34px;overflow:hidden;box-shadow:0 40px 100px rgba(0,0,0,.55)}
.wh{height:84px;background:#1f6f54;display:flex;align-items:center;gap:12px;padding:0 28px;color:#fff;font-weight:800;font-size:34px}
.wh i{width:22px;height:22px;border-radius:50%;background:#ff5f57;display:block}.wh i:nth-child(2){background:#febc2e}.wh i:nth-child(3){background:#28c840}.wh span{margin-left:14px}
.wb{position:relative;height:776px}.pane{position:absolute;inset:0;padding:30px 34px}
.th,.tr{display:flex;gap:10px;align-items:stretch;margin-bottom:12px}.th span{flex:1;background:#1f6f54;color:#fff;text-align:center;font-weight:800;font-size:28px;padding:16px 4px;border-radius:10px;line-height:1.15}
.c{flex:1;background:#f3f4f6;border-radius:10px;padding:22px 10px;font-weight:700;font-size:32px;color:#111;text-align:center}.c.y{background:#fff2a8;color:#0000ff;box-shadow:inset 0 0 0 2px #e5c100}
.sum{margin-top:30px;text-align:center;font-weight:800;font-size:36px;color:#1f6f54;background:#e8f5ee;border-radius:16px;padding:20px}
.dd{display:flex;align-items:center;gap:18px;margin-bottom:22px;position:relative;height:84px}.ddl{font-weight:800;font-size:34px;color:#111;width:230px}
.ddv{position:absolute;left:250px;right:0;top:0;height:84px;background:#fff2a8;color:#0000ff;font-weight:800;font-size:38px;border-radius:14px;box-shadow:inset 0 0 0 3px #e5c100;display:flex;align-items:center;padding:0 24px}
.ddo{opacity:0}
.rkw{position:relative;height:370px}.rk{position:absolute;left:0;right:0;height:108px;background:#f3f4f6;border-radius:16px;display:flex;align-items:center;gap:18px;padding:0 24px;font-size:40px;font-weight:800;color:#111}
.rk b{width:64px;height:64px;border-radius:50%;background:#1f6f54;color:#fff;display:flex;align-items:center;justify-content:center;font-size:36px}.rt{flex:1}.rs{font-size:32px;color:#6b7280}
.tiles{display:flex;gap:20px;margin-top:6px}.tile{flex:1;background:#0b132b;color:#fff;border-radius:22px;padding:18px 22px;font-weight:800;font-size:40px;text-align:center}.tile small{display:block;font-size:28px;color:#94a3b8;font-weight:700}.tile b{font-size:78px;color:#5eead4}
#tI b{color:#5eead4}
.cmp{display:flex;gap:40px;align-items:flex-end;justify-content:center;height:430px;margin-top:20px}.cb{width:380px;text-align:center}
.bar{width:100%;height:0;border-radius:18px 18px 0 0}.cl{margin-top:14px;font-weight:800;font-size:32px;color:#111;line-height:1.3}.cl b{font-size:56px}
.diff{margin:24px auto 0;width:560px;text-align:center;background:#ef4444;color:#fff;font-weight:800;font-size:76px;border-radius:26px;padding:6px 0;transform:scale(0);opacity:0}
.note2{text-align:center;margin-top:20px;font-weight:700;font-size:34px;color:#475569;opacity:0}
.subz{position:absolute;left:50px;right:50px;top:1500px;height:260px}
.sub{position:absolute;left:0;right:0;top:0;text-align:center;font-weight:800;font-size:56px;line-height:1.35;color:#fff;background:rgba(0,0,0,.55);border-radius:30px;padding:22px 30px}
.cta{position:absolute;inset:0;background:linear-gradient(170deg,#0b132b,#0f3b3a);opacity:0;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:26px;z-index:12}
.c1{font-weight:800;font-size:76px;color:#fff}.c2{font-weight:800;font-size:64px;color:#fff}
.pill{font-weight:800;font-size:230px;line-height:1.1;background:linear-gradient(90deg,#fbbf24,#fb7185);color:#fff;padding:10px 100px;border-radius:90px;box-shadow:0 30px 90px rgba(251,113,133,.5)}
.url{font-weight:800;font-size:56px;color:#5eead4;background:#ffffff14;border:3px solid #5eead4;border-radius:26px;padding:14px 36px}
.disc{position:absolute;left:60px;right:60px;bottom:90px;text-align:center;font-weight:700;font-size:30px;color:#ffffffaa}
'''
sections = section('c', 0, DUR, body)
sections += ae_overlay_html(("#14b8a6", "#fbbf24", "#0b132b")).replace('__DUR__', str(DUR))
# ---- animation
for k in range(1, 7):
    a, d = L[k]
    if k > 1:
        js.append(f'tl.set("#sub{k}",{{opacity:1}},{a:.2f});tl.from("#sub{k}",{{y:30,duration:0.3,ease:"power3.out"}},{a:.2f});')
    if k < 6:
        js.append(f'tl.set("#sub{k}",{{opacity:0}},{a+d+0.02:.2f});')
js.append('tl.fromTo("#win",{y:0},{y:-8,duration:2,yoyo:true,repeat:17,ease:"sine.inOut"},0);')
# scene 1: rows pop (visible at 0; subtle pulses)
for i in range(3):
    js.append(f'tl.fromTo("#row{i}",{{x:0}},{{x:0,duration:0.01}},0);tl.to("#row{i}",{{scale:1.03,duration:0.18,yoyo:true,repeat:1,ease:"power2.out"}},{1.7+i*0.7:.2f});')
# scene 2 highlight sweeps on columns
for (t, sel) in [(5.9, 'cb'), (6.9, 'cr'), (8.0, 'cm')]:
    for i in range(3):
        js.append(f'tl.to("#{sel}{i}",{{scale:1.12,backgroundColor:"#ffd60a",duration:0.2,yoyo:true,repeat:1,ease:"power2.out"}},{t+i*0.08:.2f});')
# switch to pane B at 10.7
js.append('tl.to("#pA",{opacity:0,duration:0.25},10.7);tl.to("#pB",{opacity:1,duration:0.25},10.75);')
def place(order, t, dur=0.6):
    return ''.join(f'tl.to("#rk{n}",{{y:{p*120},duration:{dur},ease:"power3.inOut"}},{t:.2f});' for n, p in order.items())
js.append('tl.set(".rk",{y:0},0);' + ''.join(f'tl.set("#rk{j}",{{y:{j*120}}},0);' for j in range(3)))
js.append(f'tl.from("#rk0",{{x:-200,opacity:0,duration:0.4,ease:"power3.out"}},11.2);tl.from("#rk1",{{x:-200,opacity:0,duration:0.4,ease:"power3.out"}},11.5);tl.from("#rk2",{{x:-200,opacity:0,duration:0.4,ease:"power3.out"}},11.8);')
js.append('var mo={v:0},iv={v:0};')
js.append('tl.to(mo,{v:17,duration:0.8,ease:"power2.out",onUpdate:()=>{document.getElementById("mo").textContent=Math.round(mo.v)}},13.7);')
js.append('tl.to(iv,{v:17565,duration:2.6,ease:"power2.out",onUpdate:()=>{document.getElementById("iv").textContent=Math.round(iv.v).toLocaleString("en-US")}},14.95);')
js.append('tl.to("#tI",{scale:1.06,duration:0.2,yoyo:true,repeat:1},17.7);')
# scene 4: dropdown swap, reorder (rank order: มือถือ, บัตร, สินเชื่อ) rk0=สินเชื่อ->pos2, rk1=บัตร->pos1, rk2=มือถือ->pos0
js.append('tl.to("#ddA",{opacity:0,duration:0.2},19.0);tl.to("#ddB",{opacity:1,duration:0.2},19.0);tl.fromTo("#ddB",{boxShadow:"inset 0 0 0 3px #e5c100"},{boxShadow:"inset 0 0 0 8px #f97316",duration:0.25,yoyo:true,repeat:1},19.0);')
js.append(place({0: 2, 1: 1, 2: 0}, 19.7))
js.append('tl.set("#rka0",{innerHTML:"60,000 บาท"},19.9);tl.set("#rka1",{innerHTML:"45,000 บาท"},19.9);tl.set("#rka2",{innerHTML:"12,000 บาท"},19.9);')
js.append('tl.set("#rkn0",{innerHTML:"3"},19.9);tl.set("#rkn2",{innerHTML:"1"},19.9);')
js.append('tl.to("#mo",{scale:1.3,duration:0.2,yoyo:true,repeat:1},20.5);')
js.append('tl.to(iv,{v:19620,duration:2.0,ease:"power1.inOut",onUpdate:()=>{document.getElementById("iv").textContent=Math.round(iv.v).toLocaleString("en-US")}},23.3);tl.to("#iv",{color:"#fb923c",duration:0.4},23.3);')
# scene 5
js.append('tl.to("#pB",{opacity:0,duration:0.25},25.9);tl.to("#pC",{opacity:1,duration:0.25},25.95);')
js.append('tl.to("#barA",{height:300,duration:0.7,ease:"power3.out"},26.2);tl.to("#barB",{height:336,duration:0.7,ease:"power3.out"},26.5);')
js.append('tl.set("#diff",{opacity:1},26.9);tl.to("#diff",{scale:1,duration:0.45,ease:"back.out(3)"},26.9);tl.to("#diff",{x:8,duration:0.05,yoyo:true,repeat:9,ease:"none"},27.4);')
js.append('tl.to("#note2",{opacity:1,duration:0.4},28.8);')
# scene 6 CTA
js.append('tl.set("#cta",{opacity:1},31.65);tl.from("#cta .c1",{y:60,opacity:0,duration:0.4,ease:"back.out(2)"},31.7);tl.from("#pill",{scale:0.2,opacity:0,rotation:-12,duration:0.5,ease:"back.out(2.4)"},32.7);tl.from("#cta .c2",{y:60,opacity:0,duration:0.4},34.3);tl.from("#url",{scale:0.6,opacity:0,duration:0.45,ease:"back.out(2)"},34.7);')
js.append('tl.to("#pill",{scale:1.06,duration:0.45,yoyo:true,repeat:5,ease:"sine.inOut"},33.3);')
js += cam_js('c', 0, DUR, rot=0.4, push=0.03)
sections_ae = ae_overlay_js(DUR, [5.8, 10.7, 18.65, 25.95, 31.65])
js += sections_ae
# audio
audio = ''.join(audio_el(k - 1, f'v{k}', L[k][0], L[k][1]) for k in range(1, 7)) + bed_audio(DUR, 0.30)
write_index('/home/user/CLOUD/ai-ladmue/clips/c29/hf/index.html', 'P1 Debt', css, sections, audio, js, DUR)
# sfx + bgm
s = Sfx(DUR)
for t in (5.8, 10.7, 18.65, 25.95, 31.65): s.whoosh(t - 0.05, 0.3); s.pop(t, 520)
for t in (11.2, 11.5, 11.8): s.pop(t, 800)
s.ding(13.7, 1318); s.ding(17.7, 1568); s.ding(19.0, 988)
s.thud(26.9); s.ding(26.95, 1760); s.ding(32.7, 1568); s.ding(34.7, 1760)
s.save('/home/user/CLOUD/ai-ladmue/clips/c29/hf/assets/sfx.wav')
SR = 44100; t = np.arange(int(DUR * SR)) / SR; pad = np.zeros_like(t)
for f, g in [(110, .5), (164.8, .4), (220, .4), (261.6, .3), (329.6, .25)]: pad += np.sin(2 * np.pi * f * t + np.sin(t * .3 + f)) * g
pad *= 0.12 * np.minimum(1, t / 1.5) * np.minimum(1, (DUR - t) / 1.5)
beat = np.zeros_like(t)
for b in np.arange(0, DUR, 0.5):
    i = int(b * SR); n = int(0.06 * SR); beat[i:i + n] += np.random.RandomState(int(b * 10)).randn(len(beat[i:i + n])) * np.exp(-np.arange(len(beat[i:i + n])) / (0.012 * SR)) * 0.05
out = np.tanh(pad + beat)
with wave.open('/home/user/CLOUD/ai-ladmue/clips/c29/hf/assets/bgm.wav', 'wb') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((out * 30000).astype('<i2').tobytes())
make_grain('/home/user/CLOUD/ai-ladmue/clips/c29/hf/assets/grain.png')
print('ok')
