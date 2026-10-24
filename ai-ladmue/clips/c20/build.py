import sys; sys.path.insert(0, '/home/user/CLOUD/ai-ladmue/clips')
from hfkit import *
DUR = 14.3
SC = [('k0', 0, 1.25, '#ff2d55', '#fff'), ('k1', 1.25, 2.85, '#111', '#fff'), ('k2', 2.85, 5.75, '#ffd23f', '#111'),
      ('k3', 5.75, 8.3, '#4ad2ff', '#111'), ('k4', 8.3, 10.75, '#9dff7a', '#111'), ('k5', 10.75, 11.65, '#ff2d55', '#fff'), ('k6', 11.65, DUR, '#111', '#fff')]
body = {
 'k0': '<div class="big c" id="k0-a" style="top:520px;font-size:300px">AI</div><div class="big c" id="k0-b" style="top:860px;font-size:250px">ตอบมั่ว?</div>',
 'k1': '<div class="big c" id="k1-a" style="top:600px;font-size:200px">ลองสั่ง</div><div class="big c y" id="k1-b" style="top:880px;font-size:230px">3 ประโยค</div>',
 'k2': '<div class="num" id="k2-n">1</div><div class="big c" id="k2-a" style="top:900px;font-size:150px">ถ้าไม่แน่ใจ</div><div class="big c" id="k2-b" style="top:1090px;font-size:130px">ให้บอกว่า</div><div class="big c w" id="k2-c" style="top:1260px;font-size:170px">“ไม่แน่ใจ”</div>',
 'k3': '<div class="num" id="k3-n">2</div><div class="big c" id="k3-a" style="top:900px;font-size:170px">ใช้เฉพาะ</div><div class="big c" id="k3-b" style="top:1090px;font-size:170px">ข้อมูลที่</div><div class="big c w" id="k3-c" style="top:1280px;font-size:200px">ฉันให้</div>',
 'k4': '<div class="num" id="k4-n">3</div><div class="big c" id="k4-a" style="top:900px;font-size:170px">ก่อนตอบ</div><div class="big c" id="k4-b" style="top:1090px;font-size:170px">ตรวจซ้ำ</div><div class="big c w" id="k4-c" style="top:1280px;font-size:200px">อีกรอบ</div>',
 'k5': '<div class="big c" id="k5-a" style="top:780px;font-size:300px">เซฟไว้!</div>',
 'k6': '<div class="big c" id="k6-a" style="top:560px;font-size:140px">คอมเมนต์คำว่า</div><div class="kw" id="k6-b">prompt</div><div class="big c y" id="k6-c" style="top:1180px;font-size:110px">รับชุดคำสั่งฟรี</div>',
}
sections = ''
for sid, a, b, bg, fg in SC:
    sections += section(sid, a, b, f'<div class="bg" style="background:{bg}"></div><div class="ink" style="color:{fg}">{body[sid]}</div><div class="hdl" style="color:{fg}">@ailadmue</div>')
css = '''
.ink{position:absolute;inset:0}
.big{position:absolute;left:0;right:0;text-align:center;font-weight:800;line-height:1.05}
.big.y{color:#ffd23f}.big.w{background:#111;color:#ffd23f;display:block;margin:0 60px;left:0;right:0;border-radius:30px}
.num{position:absolute;left:0;right:0;top:150px;text-align:center;font-weight:800;font-size:650px;line-height:1}
.kw{position:absolute;left:100px;right:100px;top:760px;text-align:center;font-weight:800;font-size:200px;background:#ffd23f;color:#111;border-radius:40px;padding:10px 0}
.hdl{position:absolute;left:0;right:0;top:1780px;text-align:center;font-weight:700;font-size:44px;opacity:.7}
'''
js = []
def slam(sel, t, d=0.28): js.append(f'tl.from("{sel}",{{scale:2.4,opacity:0,duration:{d},ease:"power4.out",transformOrigin:"50% 50%"}},{t:.2f});')
# frame-0 safe: k0 only shakes
js.append('tl.to("#k0-a,#k0-b",{x:12,duration:0.05,yoyo:true,repeat:21,ease:"none"},0.0);')
slam('#k1-a', 1.27); slam('#k1-b', 1.75)
for sid, a, b, bg, fg in SC[2:5]:
    js.append(f'tl.from("#{sid}-n",{{scale:0.2,opacity:0,rotation:-10,duration:0.35,ease:"back.out(2)",transformOrigin:"50% 50%"}},{a+0.02:.2f});')
slam('#k2-a', 3.45); slam('#k2-b', 4.1); slam('#k2-c', 4.6)
slam('#k3-a', 6.45); slam('#k3-b', 6.95); slam('#k3-c', 7.35)
slam('#k4-a', 8.95); slam('#k4-b', 9.55); slam('#k4-c', 10.05)
slam('#k5-a', 10.77, 0.3)
slam('#k6-a', 11.67); slam('#k6-b', 12.6); slam('#k6-c', 13.2)
js.append('tl.to("#k5-a",{scale:1.08,duration:0.2,yoyo:true,repeat:3,ease:"sine.inOut"},11.05);')
audio = audio_el(0, 'v', 0.05, 13.87) + bed_audio(DUR, 0.4)
write_index('/home/user/CLOUD/ai-ladmue/clips/c20/hf/index.html', 'Kinetic', css, sections, audio, js, DUR)
s = Sfx(DUR)
for t in (1.25, 2.85, 5.75, 8.3, 10.75, 11.65): s.whoosh(t - 0.02, 0.25); s.thud(t)
s.ding(10.8, 1568); s.ding(12.6, 1760)
for t in (3.45, 4.1, 4.6, 6.45, 6.95, 7.35, 8.95, 9.55, 10.05): s.pop(t)
s.save('/home/user/CLOUD/ai-ladmue/clips/c20/hf/assets/sfx.wav'); print('ok')
