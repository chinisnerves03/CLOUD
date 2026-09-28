# Preview (ใช้ตอนพัฒนา ไม่ต้องใส่ใน Roblox)

วาดรูปตัวอย่างโมเดลจาก `ItemModels.lua` โดยไม่ต้องเปิด Studio: รันโค้ดกับ Roblox API จำลอง (`mock.luau`) แล้ววาดด้วย three.js

```bash
npm install && npm run setup
LUAU=/path/to/luau ./build.sh            # เขียน parts.jsonl (Plot1) + พิมพ์จำนวน Part ต่อชิ้น
python3 -m http.server 8765 &
node shoot.mjs '{"overview":"eye=-90,75,-15&at=-90,0,62"}'   # บันทึกรูปลง shots/
```
พิกัดกล้องเป็นพิกัดโลก Plot1 อยู่กลางที่ (-90, 1, 70) ด้านหน้าหัน -Z
