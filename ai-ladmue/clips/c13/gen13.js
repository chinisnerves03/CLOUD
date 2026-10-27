const fs=require('fs');
const D=22.2;
const lines=[
 {a:0.05,b:2.45,t:'AI ตอบมั่นใจ แต่ผิดได้!',gaps:[[1.41,1.65]]},
 {a:2.86,b:4.55,t:'ก่อนเชื่อ เช็กสามอย่างนี้',gaps:[]},
 {a:5.11,b:9.10,t:'หนึ่ง ชื่อ ตัวเลข วันที่ ค้นหาซ้ำจากแหล่งจริง',gaps:[[5.5,5.8]]},
 {a:9.64,b:13.06,t:'สอง ขอแหล่งอ้างอิง แล้วเปิดดูเองว่ามีอยู่จริง',gaps:[[10.07,10.35]]},
 {a:13.56,b:15.69,t:'สาม ถามซ้ำด้วยคำถามอีกแบบ',gaps:[[13.99,14.26]]},
 {a:16.02,b:18.10,t:'ถ้าคำตอบเปลี่ยน แปลว่าต้องระวัง',gaps:[[16.88,17.07]]},
 {a:18.62,b:22.0,t:'อยากได้ชุดคำสั่งช่วยตรวจ คอมเมนต์คำว่า prompt',gaps:[[20.08,20.32],[21.24,21.45]]}
];
const scenes=[0,2.7,5.0,9.4,13.3,18.4,D+1];
const html=`<!doctype html><html lang="th"><head><meta charset="utf-8"><title>AI ลัดมือ</title><style>
@font-face{font-family:P;font-weight:500;src:url(../../video/prompt-thai-500-normal.woff2)}
@font-face{font-family:P;font-weight:700;src:url(../../video/prompt-thai-700-normal.woff2)}
@font-face{font-family:P;font-weight:800;src:url(../../video/prompt-thai-800-normal.woff2)}
*{box-sizing:border-box;margin:0}html,body{width:1080px;height:1920px;overflow:hidden;font-family:P,sans-serif;color:#1F2340}
body{background:#F7F1E3}
#paper{position:absolute;inset:0;background-color:#F7F1E3;background-image:linear-gradient(#D9D2BE 2px,transparent 2px),linear-gradient(90deg,#D9D2BE 2px,transparent 2px);background-size:54px 54px;background-position:20px 14px}
#margin{position:absolute;left:84px;top:0;bottom:0;width:4px;background:#F2A0A0;opacity:.7}
.tape{position:absolute;width:150px;height:46px;background:#F4D77C;opacity:.85;transform:rotate(-8deg);box-shadow:0 3px 6px #0003}
.brand{position:absolute;top:70px;left:120px;display:flex;align-items:center;gap:20px;font-weight:800;font-size:40px;z-index:20}
.brand img{width:76px;height:76px;border-radius:20px;border:5px solid #fff;box-shadow:0 4px 10px #0003}
.bar{position:absolute;left:0;bottom:0;height:14px;z-index:30;width:0;background:#1F2340}
.s{position:absolute;inset:0;opacity:0}
.stk{position:absolute;background:#fff;border-radius:34px;border:10px solid #fff;box-shadow:0 10px 0 #0002,0 14px 24px #0003;font-weight:800;text-align:center}
.ban{left:150px;right:90px;top:210px;padding:26px 34px;font-size:78px;line-height:1.2;background:#FF5A36;color:#fff;transform:rotate(-1.5deg)}
.chip{display:inline-block;border-radius:22px;padding:6px 26px;margin:6px;font-size:58px;color:#fff;box-shadow:0 6px 0 #0003}
.card{left:150px;right:90px;top:420px;padding:44px 40px;font-size:66px;line-height:1.35;color:#1F2340}
.tag{display:inline-block;background:#FFD23F;color:#1F2340;border-radius:18px;padding:2px 24px;font-size:48px;margin-bottom:18px;transform:rotate(-3deg)}
.arrow{font-size:80px;line-height:1;margin:8px 0;color:#FF5A36}
.mini{display:inline-block;width:44%;margin:8px 1.5%;vertical-align:top;background:#EEF3FF;border:5px solid #1F2340;border-radius:24px;padding:16px;font-size:44px;line-height:1.3;font-weight:700}
.sub{position:absolute;left:100px;right:60px;top:1600px;z-index:25;text-align:center}
.sub .l{display:inline-block;background:#1F2340;border-radius:26px;padding:18px 30px;font-weight:800;font-size:60px;line-height:1.35;color:#fff;box-shadow:0 8px 0 #0004;white-space:pre-wrap}
.sub .w.on{background:#FFD23F;color:#1F2340;border-radius:12px;padding:0 6px;margin:0 -6px}
#swipe{position:absolute;inset:0;z-index:22;background:#F7F1E3;box-shadow:-30px 0 40px #0004;transform:translateX(1200px)}
#robot{position:absolute;left:700px;top:1170px;z-index:12}
</style></head><body>
<div id="paper"></div><div id="margin"></div>
<div class="tape" style="left:40px;top:-6px;"></div><div class="tape" style="right:30px;top:20px;transform:rotate(9deg)"></div>
<div class="brand"><img src="../../avatar.svg">AI ลัดมือ</div>

<div class="s" data-a="0" data-b="2.7" data-k="cut">
 <div class="stk ban" data-a="0.1" data-k="pop">AI ตอบมั่นใจ</div>
 <div class="stk" data-a="1.45" data-k="pop" style="left:220px;right:160px;top:470px;padding:36px;font-size:130px;background:#FFF1B8;color:#E53935;transform:rotate(2deg)">แต่ผิดได้! ⚠️</div>
</div>
<div class="s" data-a="2.7" data-b="5.0" data-k="cut">
 <div class="stk ban" data-a="2.8" data-k="pop" style="background:#3E7CF0">ก่อนเชื่อ เช็ก</div>
 <div class="stk" data-a="3.4" data-k="pop" style="left:260px;right:220px;top:470px;padding:30px;font-size:260px;line-height:1;background:#FFD23F;color:#1F2340;transform:rotate(-3deg)">3<span style="font-size:90px"> อย่าง</span></div>
</div>
<div class="s" data-a="5.0" data-b="9.4" data-k="cut">
 <div class="stk ban" data-a="5.05" data-k="pop" style="background:#12A66B">เช็กที่ 1</div>
 <div class="stk card" data-a="5.7" data-k="pop" style="top:440px">
  <span class="chip" style="background:#3E7CF0" data-a="5.9" data-k="pop">ชื่อ</span><span class="chip" style="background:#E8523B" data-a="6.5" data-k="pop">ตัวเลข</span><span class="chip" style="background:#8E5BA8" data-a="7.0" data-k="pop">วันที่</span>
  <div class="arrow" data-a="7.6" data-k="pop">⬇</div>
  <div data-a="7.8" data-k="pop">ค้นหาซ้ำจาก<span style="color:#12A66B">แหล่งจริง</span> 🔎</div></div>
</div>
<div class="s" data-a="9.4" data-b="13.3" data-k="cut">
 <div class="stk ban" data-a="9.45" data-k="pop" style="background:#8E5BA8">เช็กที่ 2</div>
 <div class="stk card" data-a="10.0" data-k="pop" style="top:440px">
  <div data-a="10.4" data-k="pop">ขอ<span style="color:#8E5BA8">แหล่งอ้างอิง</span> 🔗</div>
  <div class="arrow" data-a="11.3" data-k="pop">⬇</div>
  <div data-a="11.5" data-k="pop">เปิดดูเองว่า<span style="color:#12A66B">มีอยู่จริง</span> ✅</div></div>
</div>
<div class="s" data-a="13.3" data-b="18.4" data-k="cut">
 <div class="stk ban" data-a="13.35" data-k="pop" style="background:#E8523B">เช็กที่ 3</div>
 <div class="stk card" data-a="13.9" data-k="pop" style="top:440px;font-size:56px">
  <div><span class="mini" data-a="14.3" data-k="pop">ถามแบบ A<br>➜ ตอบ <b>ก</b></span><span class="mini" data-a="15.0" data-k="pop" style="background:#FFF1E6">ถามแบบ B<br>➜ ตอบ <b>ข</b></span></div>
  <div data-a="16.2" data-k="pop" style="margin-top:14px;color:#E53935;font-size:78px">ก ≠ ข = <span style="background:#FFD23F;color:#1F2340;border-radius:16px;padding:0 18px">ระวัง!</span></div></div>
</div>
<div class="s" data-a="18.4" data-b="99" data-k="cut">
 <div class="stk ban" data-a="18.5" data-k="pop" style="background:#12A66B">อยากได้ชุดคำสั่งช่วยตรวจ</div>
 <div class="stk" data-a="20.0" data-k="pop" style="left:250px;right:190px;top:470px;padding:20px 20px;font-size:50px;background:#FFF">คอมเมนต์คำว่า</div>
 <div class="stk" data-a="20.35" data-k="pop" style="left:200px;right:140px;top:590px;padding:26px;font-size:150px;background:linear-gradient(90deg,#FF8A3D,#FF4D6D);color:#fff;transform:rotate(-2deg)">prompt</div>
 <div class="stk" data-a="21.2" data-k="pop" style="left:260px;right:170px;top:850px;padding:18px;font-size:48px;background:#FFF1B8">✍️ ตรวจเองด้วยนะ</div>
</div>

<svg id="robot" width="300" height="300" viewBox="0 0 300 300"><g id="rb"><line x1="150" y1="44" x2="150" y2="14" stroke="#B85F1E" stroke-width="8"/><circle cx="150" cy="10" r="12" fill="#FFD23F"/><circle cx="150" cy="160" r="110" fill="#FF8A3D" stroke="#fff" stroke-width="10"/><ellipse cx="150" cy="160" rx="82" ry="60" fill="#1E1B2E"/><rect x="108" y="138" width="20" height="30" rx="10" fill="#6FF0FF"/><rect x="172" y="138" width="20" height="30" rx="10" fill="#6FF0FF"/><path d="M118 186 Q150 206 182 186" stroke="#6FF0FF" stroke-width="8" fill="none" stroke-linecap="round"/></g></svg>

<svg id="pres" style="position:absolute;left:0;top:1060px;z-index:12" width="640" height="540" viewBox="0 0 640 540">
 <g id="armL"></g>
 <rect x="150" y="300" width="220" height="230" rx="46" fill="#fff" stroke="#1F2340" stroke-width="6"/>
 <path d="M170 380 L350 380 L360 530 L160 530Z" fill="#3E7CF0" stroke="#1F2340" stroke-width="6"/><rect x="190" y="340" width="26" height="60" fill="#3E7CF0" stroke="#1F2340" stroke-width="6"/><rect x="304" y="340" width="26" height="60" fill="#3E7CF0" stroke="#1F2340" stroke-width="6"/>
 <rect x="232" y="268" width="56" height="50" fill="#F2C9A0" stroke="#1F2340" stroke-width="6"/>
 <circle cx="260" cy="200" r="104" fill="#F2C9A0" stroke="#1F2340" stroke-width="6"/>
 <path d="M154 205 Q150 92 260 90 Q372 92 366 205 Q350 150 300 140 Q240 156 180 140 Q158 165 154 205Z" fill="#1F2340"/>
 <path d="M150 200 Q140 290 190 300 L192 200Z" fill="#1F2340"/><path d="M370 200 Q380 290 330 300 L328 200Z" fill="#1F2340"/>
 <g id="eyesP"><ellipse cx="222" cy="212" rx="15" ry="19" fill="#1F2340"/><ellipse cx="298" cy="212" rx="15" ry="19" fill="#1F2340"/><circle cx="227" cy="205" r="6" fill="#fff"/><circle cx="303" cy="205" r="6" fill="#fff"/></g>
 <circle cx="190" cy="248" r="16" fill="#FF9AA2" opacity=".7"/><circle cx="330" cy="248" r="16" fill="#FF9AA2" opacity=".7"/>
 <path id="brL" d="M200 182 L242 180" stroke="#1F2340" stroke-width="7" stroke-linecap="round"/><path id="brR" d="M280 180 L322 182" stroke="#1F2340" stroke-width="7" stroke-linecap="round"/>
 <ellipse id="mP" cx="260" cy="262" rx="20" ry="8" fill="#B03A48" stroke="#1F2340" stroke-width="4"/>
 <g id="armR"></g>
</svg>
<div class="sub" id="sub"></div>
<div id="swipe"></div>
<div class="bar" id="bar"></div>
<script>const DUR=${D};</script><script src="../lib.js"></script>
<script>
const LINES=${JSON.stringify(lines)};
const SC=${JSON.stringify(scenes)};
const wseg=new Intl.Segmenter('th',{granularity:'word'}),gseg=new Intl.Segmenter('th',{granularity:'grapheme'});
LINES.forEach(l=>{const ws=[...wseg.segment(l.t)].map(s=>s.segment);const lens=ws.map(w=>w.trim().length?[...gseg.segment(w)].length+0.5:0);const tot=lens.reduce((a,b)=>a+b,0);
 const gl=l.gaps.reduce((a,g)=>a+(g[1]-g[0]),0),act=(l.b-l.a)-gl;
 const real=u=>{let t=l.a+u;for(const g of l.gaps){if(t>=g[0])t+=g[1]-g[0]}return t};
 let acc=0;l.w=ws.map((w,i)=>{const s=real(act*acc/tot);acc+=lens[i];return{w,s,e:real(act*acc/tot),sp:!w.trim().length}})});
const POSE=[[0,'shock'],[2.7,'point'],[9.4,'think'],[13.3,'point'],[18.4,'cheer']];
function arms(p,t){
 const w=Math.sin(t*9)*8;
 const ln=(x1,y1,x2,y2)=>'<path d="M'+x1+' '+y1+' L'+x2+' '+y2+'" stroke="#1F2340" stroke-width="46" stroke-linecap="round"/><path d="M'+x1+' '+y1+' L'+x2+' '+y2+'" stroke="#fff" stroke-width="34" stroke-linecap="round"/><circle cx="'+x2+'" cy="'+y2+'" r="26" fill="#F2C9A0" stroke="#1F2340" stroke-width="6"/>';
 let L='',R='';
 if(p==='shock'){L=ln(165,350,100,180+w);R=ln(355,350,420,180-w)}
 else if(p==='point'){L=ln(165,350,110,430);R=ln(355,345,470,230+w)}
 else if(p==='think'){L=ln(165,350,110,430);R=ln(355,350,320,290)}
 else{L=ln(165,350,100,160+w);R=ln(355,350,420,160-w)}
 return[L,R]}
const sub=document.getElementById('sub'),rb=document.getElementById('rb'),mP=document.getElementById('mP'),armL=document.getElementById('armL'),armR=document.getElementById('armR'),sw=document.getElementById('swipe'),brL=document.getElementById('brL'),brR=document.getElementById('brR'),pres=document.getElementById('pres'),robot=document.getElementById('robot');
const base=seek;let lastPose='';
window.seek=function(t){
 base(t);
 let pose='shock';POSE.forEach(x=>{if(t>=x[0])pose=x[1]});
 const [L,R]=arms(pose,t);armL.innerHTML=L;armR.innerHTML=R;
 const act=LINES.find(l=>t>=l.a&&t<=l.b&&!l.gaps.some(g=>t>=g[0]&&t<=g[1]));
 mP.setAttribute('ry',act?7+Math.abs(Math.sin(t*19))*17:6);
 const shock=pose==='shock',cheer=pose==='cheer';
 brL.setAttribute('d',shock?'M200 170 L242 164':cheer?'M200 176 L242 172':'M200 182 L242 180');brR.setAttribute('d',shock?'M280 164 L322 170':cheer?'M280 172 L322 176':'M280 180 L322 182');
 pres.style.transform='translateY('+(Math.sin(t*3.2)*5)+'px)';
 rb.setAttribute('transform','translate(0,'+(Math.sin(t*2.4)*10)+')');
 robot.style.transform='rotate('+(Math.sin(t*1.7)*4)+'deg)';
 let sx=1200;SC.forEach(s=>{const d=t-s;if(s>0&&d>=-0.02&&d<0.32){sx=1200-(d+0.02)/0.34*2400}});sw.style.transform='translateX('+sx+'px)';
 if(act){let h='<span class="l">';act.w.forEach(x=>{const on=t>=x.s&&t<x.e;h+=x.sp?' ':'<span class="w'+(on?' on':'')+'">'+x.w+'</span>'});h+='</span>';if(sub._h!==h){sub.innerHTML=h;sub._h=h}sub.style.opacity=1}else sub.style.opacity=0;
};
seek(0);
</script></body></html>`;
fs.writeFileSync('clip.html',html);
fs.writeFileSync('timeline.json',JSON.stringify({lines,scenes,D}));
console.log('ok');
