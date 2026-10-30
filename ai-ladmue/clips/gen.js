const fs=require('fs');
const tpl=fs.readFileSync(__dirname+'/tpl.html','utf8');
const T=(n,color,title,sub,at)=>`<div class="tile" data-a="${at}" style="background:${color}"><div class="n">${n}</div><div>${title}${sub?`<small>${sub}</small>`:''}</div></div>`;
const clips={
c2:{dur:24.19,cta:18.9,ctaLine:'อยากได้คำสั่งดีๆ<br>แบบนี้อีก <span class="hl">19 แบบ</span>',c:[20.5,21.0,22.6],scenes:`
 <div class="s" data-a="0" data-b="5.0">
  <div class="big">AI ตอบ<br><span class="pk">ไม่ตรงใจ?</span></div>
  <div class="mid" style="margin-top:60px" data-a="2.0">ไม่ใช่ AI โง่<br><span class="hl">แต่คุณบอกมันไม่พอ</span></div>
 </div>
 <div class="s" data-a="5.0" data-b="10.7">
  <div class="mid" style="margin-bottom:40px">เติมประโยคเดียว<br>ท้ายคำสั่ง</div>
  <div class="card" data-a="7.5" style="border:4px solid #4ADE80;font-size:62px">“ก่อนตอบ <span class="hl">ให้ถามฉันก่อน</span> ถ้าข้อมูลไม่พอ”</div>
 </div>
 <div class="s" data-a="10.7" data-b="16.0">
  <div class="mid" style="margin-bottom:30px">AI จะถามกลับ 🙋</div>
  <div class="chip" data-a="12.7">กลุ่มลูกค้าคือใคร?</div>
  <div class="chip" data-a="13.9" style="background:#FF4D6D">งบเท่าไหร่?</div>
  <div class="chip" data-a="14.8" style="background:#FF8A3D">โทนแบบไหน?</div>
 </div>
 <div class="s" data-a="16.0" data-b="18.9">
  <div class="mid">ตอบแค่ <span class="hl">3 ข้อ</span></div>
  <div class="big gn" style="margin-top:50px" data-a="17.0">งานตรงขึ้น<br>ทันที ⚡</div>
 </div>`},
c3:{dur:25.55,cta:20.9,ctaLine:'อยากได้คำสั่ง<br>ตอบลูกค้าพร้อมใช้',c:[22.3,22.7,24.2],scenes:`
 <div class="s" data-a="0" data-b="6.4">
  <div class="big">ตอบลูกค้า<span class="pk">ช้า</span></div>
  <div class="mid" style="margin-top:50px" data-a="1.5">เสียยอดขายทุกวัน 💸</div>
  <div class="mid hl" style="margin-top:70px" data-a="3.5">ให้ AI ร่างคำตอบให้<br>ใน 3 ขั้นตอน</div>
 </div>
 <div class="s" data-a="6.4" data-b="20.9">
  ${T(1,'#FF8A3D','วางข้อความลูกค้า','',7.0)}
  ${T(2,'#FF4D6D','บอกนโยบายร้าน','เช่น คืนสินค้าได้ใน 7 วัน',9.3)}
  ${T(3,'#7C5CFF','สั่งโทนคำตอบ','สุภาพ ไม่เกิน 3 บรรทัด ไม่สัญญาเกินจริง',14.0)}
  <div class="mid hl" style="margin-top:40px" data-a="18.9">แล้วคุณแค่อ่าน…กดส่ง ✅</div>
 </div>`},
c4:{dur:24.03,cta:19.8,ctaLine:'อยากได้คำสั่งสรุป<br>แบบนี้อีก',c:[21.4,21.8,23.1],scenes:`
 <div class="s" data-a="0" data-b="5.2">
  <div class="big">รายงาน<br><span class="pk">50 หน้า</span></div>
  <div class="mid" style="margin-top:50px" data-a="1.3">อ่านไม่ไหว? 😵</div>
  <div class="mid hl" style="margin-top:50px" data-a="3.0">ให้ AI สรุปใน 10 วิ</div>
 </div>
 <div class="s" data-a="5.2" data-b="7.5">
  <div class="tag" style="background:#FF4D6D55;color:#FF6B8B">❌ แบบแย่</div>
  <div class="card" style="border:4px solid #FF6B8B;font-size:70px">สรุปให้หน่อย</div>
 </div>
 <div class="s" data-a="7.5" data-b="16.5">
  <div class="tag" style="background:#4ADE8033;color:#4ADE80">✅ แบบดี</div>
  <div class="card" style="border:4px solid #4ADE80">
   <span class="hl" data-a="8.0">สรุป 5 ข้อสำคัญ</span><br>
   <span class="pk" data-a="9.5">ภาษาง่ายๆ</span><br>
   <span class="bl" data-a="10.8">บอกสิ่งที่ต้องทำต่อ 2 ข้อ</span>
  </div>
  <div class="mid" style="margin-top:50px" data-a="13.3"><span class="gn">ได้ทั้งสาระ</span><br>และแผนลงมือทำ</div>
 </div>
 <div class="s" data-a="16.5" data-b="19.8">
  <div class="big">⚠️</div>
  <div class="mid" style="margin-top:30px" data-a="17.2">เช็ก<span class="hl">ตัวเลขสำคัญ</span><br>กับต้นฉบับทุกครั้ง</div>
 </div>`},
c5:{dur:25.63,cta:20.3,ctaLine:'อยากได้ชุดคำสั่ง<br>ใช้ AI อย่างปลอดภัย',c:[22.3,22.7,24.2],scenes:`
 <div class="s" data-a="0" data-b="4.2">
  <div class="big">ใช้ AI ทุกวัน?</div>
  <div class="mid pk" style="margin-top:60px" data-a="1.3">อย่าพลาด<br>3 ข้อนี้ ⚠️</div>
 </div>
 <div class="s" data-a="4.2" data-b="20.3">
  ${T('1','#FF4D6D','ห้ามใส่ข้อมูลลับ','เลขบัตร รหัสผ่าน ความลับบริษัท',4.8)}
  ${T('2','#FF8A3D','อย่าเชื่อทันที','ตัวเลขและแหล่งอ้างอิง ต้องตรวจซ้ำ',10.8)}
  ${T('3','#7C5CFF','อ่านก่อนส่งทุกครั้ง','คุณคือคนรับผิดชอบ ไม่ใช่ AI',15.0)}
 </div>`},
c6:{dur:21.71,cta:17.7,ctaLine:'อยากได้คำสั่งเต็ม',c:[18.8,19.2,20.4],scenes:`
 <div class="s" data-a="0" data-b="4.7">
  <div class="big">ไม่รู้จะ<br><span class="pk">โพสต์อะไร?</span></div>
  <div class="mid hl" style="margin-top:60px" data-a="2.2">คำสั่งเดียว<br>ได้ครบ 30 วัน 📅</div>
 </div>
 <div class="s" data-a="4.7" data-b="15.0">
  ${T(1,'#FF8A3D','เพจคุณเกี่ยวกับอะไร','',5.2)}
  ${T(2,'#FF4D6D','ลูกค้าคือใคร','',8.6)}
  ${T(3,'#7C5CFF','ให้ตอบเป็นตาราง','วันที่ | หัวข้อ | รูปแบบ',11.3)}
 </div>
 <div class="s" data-a="15.0" data-b="17.7">
  <div class="big gn">แผนทั้งเดือน</div>
  <div class="mid" style="margin-top:50px" data-a="15.9">ใน<span class="hl">ไม่กี่วินาที</span> ⏱</div>
 </div>`}
};
for(const [k,v] of Object.entries(clips)){
  let h=tpl.replace('<!--SCENES-->',v.scenes).replace('__CTA__',v.cta).replace('__CTALINE__',v.ctaLine)
   .replace('__CTA1__',v.c[0]).replace('__CTA2__',v.c[1]).replace('__CTA3__',v.c[2]).replace('__DUR__',v.dur);
  fs.writeFileSync(`${__dirname}/${k}/clip.html`,h);
}
console.log('ok');
