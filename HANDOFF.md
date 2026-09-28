# Handoff: ตัวทำโพสต์ขายขนม (Snack Post Maker)

เอกสารนี้สรุปบทสนทนาเดิมใน claude.ai เพื่อทำงานต่อใน Claude Code / GitHub
เจ้าของโปรเจกต์: CHIN (สื่อสารภาษาไทย ตอบเป็นภาษาไทย)

## ที่มา

- CHIN อยากหาเงินจากการสร้างสินค้าดิจิทัลด้วย AI (ได้ไอเดียจากคลิป "วิธีใช้ Claude หาเงิน แม้มีผู้ติดตาม 0 คน" ของ Jes Mahut ซึ่งขายโปรแกรมทำซับแบบจ่ายครั้งเดียว ใช้ Cloudflare + Stripe + Supabase ส่ง license key อัตโนมัติ และยิงแอด Facebook)
- พิจารณาขาย Chartwright (ระบบเทรด MT5 + Ollama) แล้ว สรุปว่ายังไม่ควรขายทั้งตัว เพราะติดตั้งยาก ต้องใช้ GPU แรง ยังไม่มีสถิติยืนยันสัญญาณ และมีประเด็นกฎหมายเรื่องคำแนะนำการลงทุน ส่วนที่ขายได้เร็วกว่าคือ logger + dashboard บันทึกเทรด
- **ทางที่เลือก:** ทำ "ชุดเครื่องมือหลังร้านอัตโนมัติสำหรับร้านออนไลน์เล็กๆ ในไทย" โดยเริ่มจากร้านขนมจีนของแม่ CHIN (แบรนด์ใหม่ ยังไม่มีชื่อ/โลโก้) เป็นสนามทดสอบ
- เหตุผล: มีร้านจริงให้ทดสอบ, CHIN เคยทำระบบโพสต์อัตโนมัติผ่าน LINE ให้ลูกค้ามาก่อน, แม่ค้าออนไลน์ยอมจ่ายเงินให้ของที่ประหยัดเวลา, CHIN ถนัดการตลาด/ยิงแอด

## แผน 3 เวอร์ชัน

1. **v1 เว็บทำโพสต์ (เสร็จแล้ว ไฟล์ `index.html`)** ใส่รูป ชื่อ ราคา จุดเด่น แล้วได้รูปโพสต์ 3 template + แคปชัน AI 3 แนว
2. **v2 ระบบอัตโนมัติบน Mac mini** (CHIN กำลังเสนอให้แม่ซื้อ Mac mini M6 เป็นเครื่องเปิด 24 ชม. ที่บ้านแม่) โยนรูปใส่โฟลเดอร์ → ลบพื้นหลัง/ปรับแสง/ใส่ template/เขียนแคปชัน → ส่งตัวอย่างให้แม่กดอนุมัติทาง LINE → โพสต์ลงเพจ Facebook / LINE OA ตามเวลา (ต้องมี Meta Business verification, LINE OA มีโควตาข้อความ)
3. **v3 แพ็กขายร้านอื่น** หน้าตั้งค่าโลโก้/สี/template ต่อร้าน + license และรับเงิน (Stripe + Supabase)
- โมเดลรายได้: เริ่มจากรับติดตั้งเป็นบริการ (ค่าติดตั้ง + ค่าดูแลรายเดือน) → แพ็กเป็นสินค้าจ่ายครั้งเดียว → ทำคอนเทนต์เล่าเคสร้านแม่ควบคู่

## สถานะ v1 (`index.html`)

- ไฟล์เดียว HTML/CSS/JS ไม่มี build step ฟอนต์ Mitr (หัวข้อ) + IBM Plex Sans Thai (เนื้อหา) จาก Google Fonts
- วาดโพสต์ด้วย `<canvas>` ขนาด 1080x1080 (โพสต์) และ 1080x1920 (สตอรี่)
- Template: `photo` (รูปเต็ม + ป้ายราคาวงกลม), `kraft` (การ์ดกระดาษ), `promo` (วงกลม + แถบมุม "ราคาพิเศษ"/"มาใหม่")
- สีแบรนด์ชั่วคราว 3 ชุด: หยก, ครั่ง, หมึก (ใน `PALETTES`) ชื่อร้านตัวอย่าง "ขนมบ้านแม่"
- ตัดคำไทยด้วย `Intl.Segmenter('th')` ตอนขึ้นบรรทัดใหม่
- ปุ่ม "ใช้ตัวอย่างไปก่อน" วาดรูปขนมเปี๊ยะจำลองบน canvas

### สิ่งที่ต้องแก้เมื่อย้ายออกจาก claude.ai (สำคัญ)

ไฟล์นี้เขียนมาสำหรับหน้า Artifact บน claude.ai จึงเรียก:
- `claude.use('sample')` สำหรับเขียนแคปชันด้วย AI
- `claude.use('downloads')` สำหรับบันทึกรูป

**นอก claude.ai สองอย่างนี้จะไม่มี** (โค้ดมี fallback: แคปชันจากแม่แบบ และเปิดรูปในแท็บใหม่) ต้องเปลี่ยนเป็น:
- แคปชัน: ทำ backend เล็กๆ (เช่น Cloudflare Worker หรือ Node/Express) เรียก Anthropic API โดยเก็บ API key ไว้ฝั่งเซิร์ฟเวอร์เท่านั้น ห้ามใส่ key ในหน้าเว็บ ใช้ prompt เดิมในฟังก์ชัน `$('gen').onclick` (ห้าม AI แต่งข้อมูลที่ไม่มี เช่นวันหมดโปร/ของแถม, ตอบเป็น JSON `{"captions":[{"style","text","hashtags"}]}`)
- บันทึกรูป: ใช้ `canvas.toBlob` + `<a download>` ธรรมดา

### สถานะหลังย้ายออกจาก claude.ai (ทำแล้ว)

- หน้าเว็บย้ายไปอยู่ที่ `public/index.html` ไม่เรียก `claude.use(...)` แล้ว
- แคปชัน: หน้าเว็บ `POST /api/captions` ไปที่ Cloudflare Pages Function `functions/api/captions.js` ซึ่งเรียก Anthropic API ด้วย `@anthropic-ai/sdk` (โมเดล `claude-opus-5`, effort `low`, บังคับรูปแบบ JSON ด้วย structured outputs, เปิด server-side fallback) key อยู่ใน env `ANTHROPIC_API_KEY` ฝั่งเซิร์ฟเวอร์เท่านั้น ถ้า backend ใช้ไม่ได้ หน้าเว็บจะใช้แคปชันจากแม่แบบแทน
- บันทึกรูป: `canvas.toBlob` + `<a download>`

### รัน/deploy

```bash
npm install
cp .dev.vars.example .dev.vars   # ใส่ ANTHROPIC_API_KEY
npm run dev                      # เปิด http://localhost:8788
```

Deploy: สร้างโปรเจกต์ Cloudflare Pages เชื่อม repo นี้ (build command เว้นว่าง, output directory `public`) แล้วตั้ง secret `ANTHROPIC_API_KEY` ใน Settings → Variables and Secrets หรือใช้ `npx wrangler pages deploy` + `npx wrangler pages secret put ANTHROPIC_API_KEY`

ข้อควรระวัง: `/api/captions` เปิดให้ใครก็เรียกได้และเสียค่า API ทุกครั้ง ก่อนเปิดให้คนนอกใช้ควรใส่ rate limit (เช่น Cloudflare WAF rate limiting rule) หรือ Cloudflare Access

## ข้อตกลง/ข้อควรระวัง

- UI และข้อความทั้งหมดเป็นภาษาไทย
- แคปชัน AI ต้องให้คนตรวจก่อนโพสต์เสมอ (v2 จึงมีขั้นอนุมัติทาง LINE)
- ยังไม่มีชื่อแบรนด์/โลโก้จริง รอแม่ตัดสินใจ แล้วค่อยทำ template ตามแบรนด์

## งานถัดไปที่แนะนำ

1. สร้าง repo ใหม่ (เช่น `snack-post-maker`) ใส่ `index.html` + `HANDOFF.md`
2. เปลี่ยน `sample`/`downloads` เป็น backend + ดาวน์โหลดปกติตามหัวข้อด้านบน แล้ว deploy (เช่น Cloudflare Pages + Worker)
3. ทดสอบกับรูปขนมจริง ปรับ template
4. เริ่มออกแบบ v2 (โฟลเดอร์ watcher บน Mac mini + LINE approval + Meta Graph API)

## Prompt เริ่มต้นสำหรับ Claude Code

> อ่าน HANDOFF.md และ index.html ใน repo นี้ก่อน แล้วช่วยทำข้อ 2 ใน "งานถัดไปที่แนะนำ": ย้ายการเขียนแคปชันไปเรียก Anthropic API ผ่าน backend (เก็บ key ฝั่งเซิร์ฟเวอร์) และเปลี่ยนการบันทึกรูปเป็นดาวน์โหลดปกติ ตอบฉันเป็นภาษาไทย
