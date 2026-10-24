const fs=require('fs');
const T=JSON.parse(fs.readFileSync('lines_t.json','utf8'));
const TXT=['อยากมีเงินหนึ่งล้านบาท ใน สามปี ต้องเก็บวันละเท่าไหร่นะ?','ง่ายนิดเดียว! หนึ่งล้าน หาร หนึ่งพันเก้าสิบห้าวัน ได้ประมาณ เก้าร้อยสิบสามบาทต่อวัน!','เก้าร้อยกว่าบาทต่อวัน?! โอ้โห แล้วถ้าต่อเดือนล่ะ?','ประมาณ สองหมื่นเจ็ดพันแปดร้อยบาท ต่อเดือน ยังไม่รวมดอกเบี้ยนะ','เข้าใจแล้ว! แล้วจะวางแผนยังไงดี?','บอก AI สี่อย่าง รายได้ รายจ่าย เป้าหมาย และเวลา แล้วให้ช่วยทำตาราง แต่ตรวจตัวเลขเองด้วยนะ!','เซฟไว้เลย! อยากได้ชุดคำสั่งฟรี คอมเมนต์คำว่า prompt'];
const lines=T.lines.map((l,i)=>({...l,t:TXT[i]}));
const D=T.D;
const html=`<!doctype html><html lang="th"><head><meta charset="utf-8"><title>AI ลัดมือ 3D</title><style>
@font-face{font-family:P;font-weight:500;src:url(../../video/prompt-thai-500-normal.woff2)}
@font-face{font-family:P;font-weight:700;src:url(../../video/prompt-thai-700-normal.woff2)}
@font-face{font-family:P;font-weight:800;src:url(../../video/prompt-thai-800-normal.woff2)}
*{box-sizing:border-box;margin:0}html,body{width:1080px;height:1920px;overflow:hidden;font-family:P,sans-serif;background:#120a1c;color:#fff}
#c{position:absolute;left:0;top:0;width:1080px;height:1920px}
#bloom{position:absolute;left:-40px;top:-40px;width:1160px;height:2000px;filter:blur(26px);mix-blend-mode:screen;opacity:.62;z-index:2}
.vig{position:absolute;inset:0;z-index:3;background:radial-gradient(ellipse 75% 62% at 50% 46%,transparent 55%,rgba(8,2,18,.62) 100%)}
.grade{position:absolute;inset:0;z-index:3;background:linear-gradient(180deg,rgba(90,60,200,.12),transparent 30%,transparent 70%,rgba(255,140,60,.10));mix-blend-mode:soft-light}
.brand{position:absolute;top:70px;left:80px;display:flex;align-items:center;gap:20px;font-weight:700;font-size:40px;z-index:20;text-shadow:0 2px 10px #000a}
.brand img{width:76px;height:76px;border-radius:20px}
.bar{position:absolute;left:0;bottom:0;height:14px;z-index:20;width:0;background:linear-gradient(90deg,#FFC83A,#FF4D8D)}
.gl{position:absolute;left:80px;right:80px;z-index:15;border-radius:44px;padding:34px 44px 40px;text-align:center;background:linear-gradient(160deg,rgba(255,255,255,.2),rgba(255,255,255,.07));border:2px solid rgba(255,255,255,.34);box-shadow:0 24px 70px rgba(10,0,30,.55),inset 0 1px 0 rgba(255,255,255,.5);backdrop-filter:blur(18px);opacity:0}
.gl .k{font-weight:700;font-size:38px;color:#ffe9b8;letter-spacing:.5px}
.gl .big{font-weight:800;font-size:128px;line-height:1.1;color:#fff;text-shadow:0 0 40px rgba(255,200,60,.55),0 6px 0 rgba(0,0,0,.25)}
.gl .big small{font-size:56px;font-weight:700;margin-left:12px;color:#ffe9b8}
.gl .mid{font-weight:800;font-size:64px;line-height:1.25}
.gold{color:#FFD23F}
.pill{display:inline-block;margin-top:14px;padding:6px 26px;border-radius:999px;background:#FFD23F;color:#3a2000;font-weight:800;font-size:40px}
.eq{font-weight:800;font-size:70px;line-height:1.2}
.eq span{color:#FFD23F}
.list{margin-top:10px;text-align:left}
.list div{font-weight:800;font-size:60px;line-height:1.5;opacity:0;display:flex;align-items:center;gap:22px}
.list em{font-style:normal;width:84px;height:84px;border-radius:24px;display:inline-flex;align-items:center;justify-content:center;font-size:48px;background:rgba(255,255,255,.18)}
.warn{position:absolute;left:110px;right:110px;z-index:15;border-radius:36px;padding:26px 30px;text-align:center;background:#FFF1B8;color:#3a2a00;font-weight:800;font-size:54px;line-height:1.3;box-shadow:0 18px 50px #000a;opacity:0}
.cta{position:absolute;left:0;right:0;z-index:15;text-align:center;opacity:0}
.cta .p{display:inline-block;font-weight:800;font-size:128px;background:linear-gradient(90deg,#FFC83A,#FF4D8D);padding:20px 70px;border-radius:60px;box-shadow:0 18px 60px rgba(255,80,140,.6);color:#fff}
.cta .s{font-weight:800;font-size:60px;margin-bottom:20px;text-shadow:0 3px 12px #000a}
.disc{position:absolute;left:60px;right:60px;top:1800px;z-index:16;text-align:center;font-weight:500;font-size:30px;color:#ffffffcc;text-shadow:0 2px 8px #000;opacity:0}
#sub{position:absolute;left:50px;right:50px;top:1470px;z-index:18;text-align:center}
#sub .chip{display:inline-block;font-weight:800;font-size:38px;padding:4px 22px;border-radius:999px;margin-bottom:14px}
#sub .l{display:block;background:#000b;border-radius:28px;padding:20px 30px;font-weight:800;font-size:62px;line-height:1.35;white-space:pre-wrap}
#sub .w.on{color:#FFD23F}
</style></head><body>
<canvas id="c" width="1080" height="1920"></canvas>
<canvas id="bloom" width="270" height="480"></canvas><div class="vig"></div><div class="grade"></div>
<div class="brand"><img src="../../avatar.svg">AI ลัดมือ</div>
<div class="gl" style="top:200px" data-a="0.3" data-b="4.55" data-k="pop"><div class="k">เป้าหมาย</div><div class="mid">เก็บเงิน <span class="gold">1,000,000 บาท</span><br>ภายใน <span class="gold">3 ปี</span></div><div class="pill" data-a="3.0" data-b="4.6" data-k="pop">ต้องเก็บวันละเท่าไหร่?</div></div>
<div class="gl" style="top:200px" data-a="4.95" data-b="16.1" data-k="pop"><div class="k">คิดง่ายๆ</div><div class="eq" data-a="6.2" data-k="fade"><span>1,000,000</span> ÷ 1,095 วัน</div><div class="big" data-a="8.74" data-k="pop"><span data-count="0,913,8.74,9.7,">0</span><small>บาท/วัน</small></div></div>
<div class="gl" style="top:200px" data-a="16.5" data-b="21.1" data-k="pop"><div class="k">ถ้าคิดเป็นต่อเดือน</div><div class="big"><span data-count="0,27800,16.6,17.8,,">0</span><small>บาท/เดือน</small></div><div class="pill" data-a="19.68" data-b="21.0" data-k="pop">ยังไม่รวมดอกเบี้ย</div></div>
<div class="gl" style="top:200px" data-a="24.25" data-b="31.9" data-k="pop"><div class="k">บอก AI 4 อย่าง</div><div class="list">
<div data-a="25.69" data-k="slide"><em>💰</em>รายได้</div><div data-a="26.51" data-k="slide"><em>🧾</em>รายจ่าย</div><div data-a="27.39" data-k="slide"><em>🎯</em>เป้าหมาย</div><div data-a="28.15" data-k="slide"><em>⏱</em>เวลา</div></div>
<div class="pill" data-a="29.1" data-b="31.9" data-k="pop">แล้วให้ช่วยทำตาราง</div></div>
<div class="warn" style="top:1290px" data-a="30.5" data-b="32.1" data-k="pop">⚠️ ตรวจตัวเลขเองทุกครั้งนะ</div>
<div class="cta" style="top:260px" data-a="32.5" data-k="pop"><div class="s">รับชุดคำสั่งฟรี คอมเมนต์คำว่า</div><div class="p">prompt</div></div>
<div class="disc" data-a="5.0" data-b="21.2" data-k="fade">ตัวเลขประมาณการเท่านั้น ไม่รวมดอกเบี้ย/เงินเฟ้อ ไม่ใช่คำแนะนำการลงทุน</div>
<div class="disc" data-a="32.5" data-k="fade">ตัวเลขประมาณการเท่านั้น ไม่ใช่คำแนะนำการลงทุน • AI ช่วยวางแผน แต่ต้องตรวจเอง</div>
<div id="sub"></div><div class="bar" id="bar"></div>
<script src="../three.iife.js"></script>
<script>const DUR=${D};</script>
<script src="env.js"></script><script src="../../clips/lib.js"></script>
<script>const LINES=${JSON.stringify(lines)};</script>
<script src="scene.js"></script>
<script>const __s=window.seek;const cnt=[...document.querySelectorAll('[data-count]')];
window.seek=function(t){__s(t);cnt.forEach(e=>{const [a,b,s,f]=e.dataset.count.split(',').map(Number);const u=clamp((t-s)/(f-s));const v=Math.round(a+(b-a)*ease(u));e.textContent=v.toLocaleString('en-US')})};seek(0);</script>
</body></html>`;
fs.writeFileSync('clip.html',html);console.log('ok');
