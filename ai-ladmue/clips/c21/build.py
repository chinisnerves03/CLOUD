import sys; sys.path.insert(0, '/home/user/CLOUD/ai-ladmue/clips')
from hfkit import *
DUR = 16.5
fridge = '''<svg width="420" height="760" viewBox="0 0 420 760"><rect x="10" y="10" width="400" height="740" rx="30" fill="#dfe6f0" stroke="#222" stroke-width="10"/><rect x="40" y="50" width="340" height="330" rx="14" fill="#fffbd6"/><rect x="40" y="410" width="340" height="300" rx="14" fill="#fffbd6"/><rect x="40" y="200" width="340" height="12" fill="#9aa"/><rect x="40" y="560" width="340" height="12" fill="#9aa"/><path d="M60 70 L130 120 M60 120 L130 70" stroke="#bbb" stroke-width="4"/><text x="210" y="320" text-anchor="middle" font-size="60" font-family="P" font-weight="800" fill="#c33">ว่างเปล่า</text><rect x="360" y="420" width="16" height="140" rx="8" fill="#777"/></svg>'''
sections = ''
sub = [(0.0, 0.6, 'ข่าวด่วน!'), (1.0, 2.25, 'พบชายวัยทำงานคนหนึ่ง'), (2.5, 4.6, 'เปิดตู้เย็นสิบรอบ ภายในหนึ่งชั่วโมง'), (4.85, 6.5, 'หวังว่าอาหารจะเกิดใหม่เอง'),
       (7.0, 7.45, 'ล่าสุด'), (7.7, 9.1, 'ยังไม่พบอะไรใหม่ในตู้เย็น'), (9.5, 12.4, 'ผู้เชี่ยวชาญแนะนำ ให้เลิกเปิด'), (12.8, 14.5, 'แล้วสั่งข้าวแทน'), (14.5, 16.0, 'ติดตามข่าวต่อ ที่เพจ AI ลัดมือ')]
chrome = '''<div class="tagr">ข่าวด่วน</div><div class="live"><i></i>LIVE</div><div class="logo">AI ลัดมือ NEWS</div>
'''
studio = '<div class="bg" style="background:linear-gradient(#0b2a5b,#16468f)"></div><div class="grid"></div>'
sc = {}
sc['n0'] = ('<div class="bg" style="background:#d62839"></div><div class="stripes"></div><div class="brk" id="n0-t">ข่าวด่วน</div><div class="brk2" id="n0-t2">BREAKING NEWS</div>', 0, 1.0)
sc['n1'] = (studio + f'<div class="ab" id="n1-scr" style="left:60px;top:300px"><div class="screen2"><svg width="200" height="300" viewBox="0 0 420 760" style="transform:scale(.4);transform-origin:0 0"></svg><div class="st1">เปิดตู้เย็น</div><div class="st2">10 รอบ/ชม.</div></div></div><div class="ab" id="n1-a" style="left:330px;top:640px;transform:scale(1.6);transform-origin:0 0">{teal("cool", "n1a")}</div><div class="desk"></div><div class="lt" id="n1-lt"><b>ชายวัยทำงาน</b>เปิดตู้เย็น 10 รอบ ใน 1 ชั่วโมง</div>', 1.0, 4.8)
sc['n2'] = (studio + f'<div class="ab" id="n2-f" style="left:560px;top:420px">{fridge}</div><div class="ab" id="n2-a" style="left:20px;top:700px;transform:scale(1.5);transform-origin:0 0">{robot("worried", uid="n2a")}</div><div class="mic"></div><div class="stamp2" id="n2-st">ยังไม่พบอะไรใหม่!</div><div class="lt" id="n2-lt"><b>ถ่ายทอดสด</b>หน้าตู้เย็นที่เกิดเหตุ</div>', 4.8, 9.4)
sc['n3'] = (studio + f'<div class="ab" id="n3-a" style="left:330px;top:640px;transform:scale(1.6);transform-origin:0 0">{teal("cool", "n3a")}</div><div class="desk"></div><div class="xx" id="n3-x"><svg width="360" height="360" viewBox="0 0 420 760" preserveAspectRatio="xMidYMid meet"><g transform="scale(.9)">' + '</g></svg>✖</div><div class="lt" id="n3-lt"><b>ผู้เชี่ยวชาญ</b>แนะนำ: เลิกเปิดตู้เย็น!</div>', 9.4, 12.7)
sc['n4'] = (studio + f'<div class="ab" id="n4-a" style="left:40px;top:640px;transform:scale(1.5);transform-origin:0 0">{robot("happy", uid="n4a")}</div><div class="bigtxt" id="n4-t">สั่งข้าวแทน!</div><div class="box" id="n4-box"><svg width="420" height="360" viewBox="0 0 420 360"><path d="M30 110 L210 30 L390 110 L390 320 L30 320 Z" fill="#ffb066" stroke="#222" stroke-width="10"/><path d="M30 110 L210 190 L390 110" fill="none" stroke="#222" stroke-width="10"/><path d="M210 190 L210 320" stroke="#222" stroke-width="10"/></svg></div><div class="endc" id="n4-end">ติดตามข่าวต่อ<br><b>เพจ AI ลัดมือ</b></div>', 12.7, DUR)
for sid, (body, a, b) in sc.items():
    cs = chrome.format(sid=sid) if sid != 'n0' else ''
    sections += section(sid, a, b, body + cs)
sections += f'<section id="sc-sub" class="clip sc" data-start="0" data-duration="{DUR}" data-track-index="2" style="pointer-events:none"><div class="ticker" id="tkb"><div class="tk" id="tk">ข่าวด่วน: พบชายเปิดตู้เย็นซ้ำสิบรอบ ★ อาหารยังไม่เกิดใหม่ ★ ผู้เชี่ยวชาญแนะนำให้สั่งข้าว ★ ติดตามได้ที่ AI ลัดมือ ★ ข่าวด่วน: พบชายเปิดตู้เย็นซ้ำสิบรอบ ★ อาหารยังไม่เกิดใหม่ ★</div></div>' + ''.join(f'<div class="sbt" id="sb{i}">{t}</div>' for i, (a, b, t) in enumerate(sub)) + '</section>\n'
css = '''
.grid{position:absolute;inset:0;background:repeating-linear-gradient(90deg,#ffffff10 0 2px,transparent 2px 90px),repeating-linear-gradient(0deg,#ffffff10 0 2px,transparent 2px 90px)}
.stripes{position:absolute;inset:0;background:repeating-linear-gradient(135deg,#00000030 0 60px,transparent 60px 120px)}
.brk{position:absolute;left:0;right:0;top:640px;text-align:center;font-weight:800;font-size:250px;color:#fff;text-shadow:10px 10px 0 #000}
.brk2{position:absolute;left:0;right:0;top:960px;text-align:center;font-weight:800;font-size:90px;color:#ffd23f;letter-spacing:10px;text-shadow:5px 5px 0 #000}
.tagr{position:absolute;left:0;top:80px;background:#d62839;color:#fff;font-weight:800;font-size:64px;padding:6px 40px 6px 40px;border-right:10px solid #fff;z-index:5}
.live{position:absolute;left:0;top:190px;background:#000;color:#fff;font-weight:800;font-size:44px;padding:4px 28px;z-index:5}.live i{display:inline-block;width:24px;height:24px;border-radius:50%;background:#f33;margin-right:12px}
.logo{position:absolute;right:30px;top:90px;background:#fff;color:#16468f;font-weight:800;font-size:44px;padding:6px 22px;border-radius:12px;z-index:5}
.ticker{position:absolute;left:0;right:0;top:1800px;height:100px;background:#111;overflow:hidden;z-index:6;border-top:6px solid #ffd23f}
.tk{position:absolute;left:0;top:14px;white-space:nowrap;font-weight:800;font-size:54px;color:#fff}
.lt{position:absolute;left:0;right:100px;top:1320px;background:#fff;color:#111;font-weight:800;font-size:56px;padding:14px 30px;border-left:30px solid #d62839;z-index:5;box-shadow:10px 10px 0 #0006}.lt b{display:block;font-size:40px;color:#d62839}
.desk{position:absolute;left:0;right:0;top:1180px;height:120px;background:linear-gradient(#e6e9f0,#aab);border-top:10px solid #fff;z-index:2}
.sbt{position:absolute;left:60px;right:60px;top:1560px;text-align:center;font-weight:800;font-size:68px;line-height:1.2;color:#fff;background:#000b;border-radius:20px;padding:14px;z-index:9;opacity:0}
.screen2{width:330px;height:420px;background:#0b1020;border:10px solid #fff;border-radius:16px;position:relative}.st1{position:absolute;top:100px;left:0;right:0;text-align:center;font-weight:800;font-size:60px;color:#ffd23f}.st2{position:absolute;top:210px;left:0;right:0;text-align:center;font-weight:800;font-size:64px;color:#fff}
.mic{position:absolute;left:380px;top:1000px;width:40px;height:150px;background:#222;border-radius:20px;border:8px solid #888;transform:rotate(-30deg);z-index:3}
.stamp2{position:absolute;left:60px;top:300px;font-weight:800;font-size:78px;color:#d62839;border:10px solid #d62839;background:#fff;padding:6px 26px;border-radius:20px;transform:rotate(-8deg);z-index:6}
.xx{position:absolute;left:90px;top:360px;font-weight:800;font-size:380px;color:#ff3b4a;line-height:1;text-shadow:8px 8px 0 #000;z-index:4}
.bigtxt{position:absolute;left:0;right:0;top:340px;text-align:center;font-weight:800;font-size:150px;color:#ffd23f;text-shadow:8px 8px 0 #000;z-index:4}
.box{position:absolute;left:560px;top:760px;z-index:3}
.endc{position:absolute;left:90px;right:90px;top:1180px;background:#ffd23f;border:10px solid #000;box-shadow:12px 12px 0 #000;text-align:center;font-weight:800;font-size:64px;color:#000;padding:20px;z-index:7}.endc b{font-size:90px}
'''
js = []
js.append('tl.to("#n0-t",{scale:1.08,duration:0.12,yoyo:true,repeat:7,ease:"none",transformOrigin:"50% 50%"},0.0);')
for sid, (body, a, b) in sc.items():
    if sid != 'n0':
        js.append(f'tl.from("#{sid}-lt",{{x:-900,duration:0.35,ease:"power3.out"}},{a+0.2:.2f});')
js.append('tl.set("#tkb",{opacity:0},0);tl.set("#tkb",{opacity:1},1.0);tl.fromTo("#tk",{x:1080},{x:-3200,duration:15.5,ease:"none"},1.0);')
js.append('tl.to("#n1a-body,#n3a-body",{y:-8,duration:0.35,yoyo:true,repeat:9,ease:"sine.inOut"},1.1);')
js.append('tl.from("#n1-a",{y:300,opacity:0,duration:0.4,ease:"back.out(1.4)"},1.02);tl.from("#n1-scr",{x:-400,opacity:0,duration:0.4},1.1);')
js.append('tl.from("#n2-f",{x:500,opacity:0,duration:0.4,ease:"power3.out"},4.85);tl.from("#n2-a",{x:-500,opacity:0,duration:0.4,ease:"back.out(1.4)"},4.9);tl.to("#n2a-body",{y:-8,duration:0.3,yoyo:true,repeat:11,ease:"sine.inOut"},5.2);')
js.append('tl.from("#n2-st",{scale:3,opacity:0,rotation:-25,duration:0.3,ease:"power4.in"},7.75);')
js.append('tl.from("#n3-a",{y:300,opacity:0,duration:0.4,ease:"back.out(1.4)"},9.42);tl.from("#n3-x",{scale:0,rotation:-40,duration:0.4,ease:"back.out(2)"},10.2);')
js.append('tl.from("#n4-a",{x:-500,opacity:0,duration:0.4,ease:"back.out(1.4)"},12.75);tl.from("#n4-t",{scale:2.5,opacity:0,duration:0.3,ease:"power4.out"},12.85);tl.from("#n4-box",{y:400,opacity:0,duration:0.4,ease:"bounce.out"},13.1);tl.from("#n4-end",{scale:0.2,opacity:0,duration:0.35,ease:"back.out(2)"},14.5);tl.to("#n4a-body",{y:-14,duration:0.3,yoyo:true,repeat:9,ease:"sine.inOut"},13.0);')
for i, (a, b, t) in enumerate(sub):
    js.append(f'tl.to("#sb{i}",{{opacity:1,duration:0.08}},{a:.2f});tl.to("#sb{i}",{{opacity:0,duration:0.08}},{b:.2f});')
audio = audio_el(0, 'v', 0.05, 15.96) + bed_audio(DUR, 0.35)
write_index('/home/user/CLOUD/ai-ladmue/clips/c21/hf/index.html', 'News', css, sections, audio, js, DUR)
s = Sfx(DUR)
for k in range(4): s.put(s.tone(900, 0.2, 'sq', env=4, vol=0.25), 0.0 + k * 0.25)
s.thud(0.02); 
for t in (1.0, 4.8, 9.4, 12.7): s.whoosh(t - 0.03); s.thud(t)
s.scratch(7.7); s.ding(7.75, 1568)
s.womp(8.0); s.ding(14.5, 1760); s.pop(13.1)
s.save('/home/user/CLOUD/ai-ladmue/clips/c21/hf/assets/sfx.wav'); print('ok')
