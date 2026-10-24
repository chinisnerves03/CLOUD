const fs=require('fs');
const T=JSON.parse(fs.readFileSync('timeline.json','utf8'));
const {lines,tips,D,B0,SP,H2S}=T;
const RB=t=>+(B0+t/SP).toFixed(2);
const cards=tips.map((x,i)=>`<div class="card" data-a="${x[0]}" data-b="${x[1]}" data-k="pop"><div class="hd"><i></i><i></i><i></i><span>prompt • ข้อ ${i+1}/5</span></div><div class="pbar"><div style="width:${(i+1)*20}%"></div></div><div class="tx">${x[2]}</div></div>`).join('');
const html=`<!doctype html><html lang="th"><head><meta charset="utf-8"><title>AI ลัดมือ 3D</title><style>
@font-face{font-family:P;font-weight:500;src:url(../../video/prompt-thai-500-normal.woff2)}
@font-face{font-family:P;font-weight:700;src:url(../../video/prompt-thai-700-normal.woff2)}
@font-face{font-family:P;font-weight:800;src:url(../../video/prompt-thai-800-normal.woff2)}
*{box-sizing:border-box;margin:0}html,body{width:1080px;height:1920px;overflow:hidden;font-family:P,sans-serif;background:#1B120C;color:#fff}
#c{position:absolute;left:0;top:0;width:1080px;height:1920px}
.brand{position:absolute;top:70px;left:80px;display:flex;align-items:center;gap:20px;font-weight:700;font-size:40px;z-index:20;text-shadow:0 2px 10px #000a}
.brand img{width:76px;height:76px;border-radius:20px}
.bar{position:absolute;left:0;bottom:0;height:14px;z-index:20;width:0;background:linear-gradient(90deg,#FF8A3D,#FF4D6D)}
.card{position:absolute;left:90px;right:90px;top:230px;z-index:15;background:#FFF6E8;color:#2B1B10;border-radius:36px;box-shadow:0 18px 50px #000a;overflow:hidden;opacity:0}
.hd{height:70px;background:#E7D5BC;display:flex;align-items:center;gap:12px;padding:0 26px;font-weight:700;font-size:32px;color:#6B5240}
.hd i{width:22px;height:22px;border-radius:50%;display:block;background:#FF5F57}.hd i:nth-child(2){background:#FEBC2E}.hd i:nth-child(3){background:#28C840}.hd span{margin-left:12px}
.pbar{height:12px;background:#EAD9C2}.pbar div{height:100%;background:linear-gradient(90deg,#FF8A3D,#FF4D6D)}
.tx{padding:40px 44px 46px;font-weight:800;font-size:68px;line-height:1.3;text-align:center}
.hook{position:absolute;left:90px;right:90px;top:230px;z-index:15;background:#FFF6E8;color:#2B1B10;border-radius:36px;box-shadow:0 18px 50px #000a;overflow:hidden;opacity:0}
.hook .tx{font-size:56px;text-align:left;padding-bottom:120px}.stamp{position:absolute;right:36px;bottom:26px;transform:rotate(-6deg);border:8px solid #E53935;color:#E53935;font-weight:800;font-size:64px;padding:2px 26px;border-radius:16px;background:#FFF6E8}
.warn{position:absolute;left:90px;right:90px;top:260px;z-index:15;background:#FFF1B8;color:#2B1B10;border-radius:36px;box-shadow:0 18px 50px #000a;padding:44px;font-weight:800;font-size:64px;line-height:1.35;text-align:center;opacity:0}
.cta{position:absolute;left:0;right:0;top:230px;z-index:15;text-align:center;opacity:0}
.cta .p{display:inline-block;font-weight:800;font-size:130px;background:linear-gradient(90deg,#FF8A3D,#FF4D6D);padding:20px 70px;border-radius:60px;box-shadow:0 18px 50px #000a}
.cta .s{font-weight:800;font-size:60px;margin-bottom:20px;text-shadow:0 3px 12px #000a}
#sub{position:absolute;left:50px;right:50px;top:1500px;z-index:18;text-align:center}
#sub .chip{display:inline-block;font-weight:800;font-size:38px;padding:4px 22px;border-radius:999px;margin-bottom:14px}
#sub .l{display:block;background:#000b;border-radius:28px;padding:20px 30px;font-weight:800;font-size:64px;line-height:1.35;white-space:pre-wrap}
#sub .w.on{color:#FFD23F}
</style></head><body>
<canvas id="c" width="${process.env.RW||720}" height="${process.env.RH||1280}"></canvas>
<div class="brand"><img src="../../avatar.svg">AI ลัดมือ</div>
<div class="hook" data-a="0.2" data-b="3.6" data-k="pop"><div class="hd"><i></i><i></i><i></i><span>แชต AI</span></div><div class="tx">หนังสือ “เคล็ดลับพันล้านใน 7 วัน” โดย ดร.สมมติ นามสกุลสมมติ</div><div class="stamp">ไม่มีอยู่จริง!</div></div>
${cards}
<div class="warn" data-a="${RB(0.1)}" data-b="${RB(2.2)}" data-k="pop">⚠️ ลดโอกาสผิด<br>ไม่ได้ทำให้ถูก 100%<br><span style="color:#C0392B">ต้องตรวจเองด้วย</span></div>
<div class="cta" data-a="${RB(2.5)}" data-k="pop"><div class="s">คอมเมนต์คำว่า</div><div class="p">prompt</div></div>
<div id="sub"></div><div class="bar" id="bar"></div>

<script src="../three.iife.js"></script>
<script>const DUR=${D};</script>
<script src="env.js"></script><script src="../../clips/lib.js"></script>
<script>const LINES=${JSON.stringify(lines)};</script>
<script src="scene.js"></script>
</body></html>`;
fs.writeFileSync('clip.html',html);console.log('ok');
