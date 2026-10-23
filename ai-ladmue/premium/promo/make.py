"""Build promo clips for the paid pack. usage: python make.py <name> ; env PW=<playwright-core path>, WORK=<tmp dir>"""
import asyncio, json, os, subprocess, sys, wave, shutil
import edge_tts

HERE = os.path.dirname(os.path.abspath(__file__))
WORK = os.environ.get('WORK', os.path.join(HERE, '_work'))
VOICE = 'th-TH-NiwatNeural'
O, P, V = '#FF8A3D', '#FF4D6D', '#7C5CFF'

CLIPS = {
 # 1) POV chat style
 'promo1-pov-chat': [
  ('POV แม่ค้า ทุ่มนึงแล้ว แชทเด้งรัวๆ 😵 ตอบเรื่องเดิมซ้ำเป็นสิบรอบ',
   dict(type='title', lines=['POV แม่ค้า 🛒', '<span class="hl">3 ทุ่มแล้ว</span>', 'แชทเด้งไม่หยุด 😵'])),
  ('ลูกค้าถามราคา แล้วก็ขอลดราคา ตอบยังไงดีไม่ให้เสียลูกค้า',
   dict(type='chat', head='ร้านขนมบ้านใบเตย', demo=True, msgs=[
     ('c', 'พี่ราคาเท่าไหร่คะ'), ('c', 'ลดหน่อยได้ไหมคะ 🥺'),
     ('s', 'ขนมชั้นใบเตย 6 ชิ้น 120 บาทค่ะ ลดราคาไม่ได้นะคะ แต่ซื้อ 2 กล่อง ส่งฟรีค่ะ 😊')])),
  ('ให้เอไอร่างข้อความให้ คุณแค่ตรวจให้ตรงกับร้าน แล้วกดส่ง',
   dict(type='title', lines=['ให้ <span class="hl">AI</span> ร่างให้', 'คุณแค่ <span class="gn">ตรวจ</span>', 'แล้วกดส่ง ✅'])),
  ('ในชุดมีหกสิบคำสั่ง ครอบคลุมหกหมวด ตั้งแต่โพสต์ขาย ตอบแชท โปร ไปจนถึงงานหลังร้าน',
   dict(type='list', head='60 คำสั่ง 6 หมวด', sm=True, tiles=[
     (O, '📝', 'โพสต์ขาย'), (P, '💬', 'ตอบแชท'), (V, '🎁', 'โปรโมชัน'),
     (O, '🎬', 'คลิปและไลฟ์'), (P, '📊', 'วิเคราะห์ร้าน'), (V, '📦', 'งานหลังร้าน')])),
  ('อยากดูรายละเอียด คอมเมนต์คำว่า โปร',
   dict(type='cta', top='อยากดูรายละเอียด', word='pro', sub='เดี๋ยวส่งให้ทางแชท 💌')),
 ],
 # 2) before/after compare
 'promo2-before-after': [
  ('ทำไมเอไอเขียนโพสต์ขายของ ไม่เหมือนร้านคุณสักที',
   dict(type='title', lines=['ทำไม <span class="hl">AI</span> เขียนโพสต์', 'ไม่เหมือน<span class="pk">ร้านคุณ</span>', 'สักที? 🤔'])),
  ('เพราะสั่งสั้นๆ ก็ได้โพสต์กลางๆ ที่ใครก็เขียนได้',
   dict(type='split', demo=True, cards=[('bad', '❌ สั่งสั้นๆ', '“ช่วยเขียนโพสต์ขายขนม”<br><span class="pk">→ ขนมอร่อย ราคาถูก สั่งเลย!!</span>')])),
  ('ความลับคือกรอกข้อมูลร้านครั้งเดียว ชื่อร้าน ลูกค้า จุดเด่นจริง และสิ่งที่ห้ามพูด',
   dict(type='list', head='กรอกครั้งเดียว ใช้ได้ทุกคำสั่ง', sm=True, tiles=[
     (O, '🏪', 'ชื่อร้าน + สินค้า'), (P, '👥', 'กลุ่มลูกค้า'), (V, '✅', 'จุดเด่นจริง'), (O, '🚫', 'สิ่งที่ห้ามพูด')])),
  ('แล้วเอไอก็เขียนตรงกับร้านคุณมากขึ้น',
   dict(type='split', demo=True, cards=[('good', '✅ ใส่ข้อมูลร้านแล้ว', '<span class="hl">ขนมชั้นใบเตย</span> กล่องละ 120 บาท 6 ชิ้น<br>ทำเองในครัวบ้าน ส่งแบบแช่เย็น<br>สั่งได้ทางแชทเลยค่ะ 🌿')])),
  ('เอไอให้ร่างแรก คุณยังเป็นเจ้าของคำพูดสุดท้าย',
   dict(type='title', size='mid', lines=['AI ให้ <span class="hl">ร่างแรก</span>', 'คุณคือ <span class="gn">เจ้าของคำพูดสุดท้าย</span> ✍️'])),
  ('อยากดูรายละเอียดชุด หกสิบคำสั่งสำหรับแม่ค้า คอมเมนต์คำว่า โปร',
   dict(type='cta', top='ชุด 60 คำสั่งสำหรับแม่ค้า', word='pro', sub='ดูรายละเอียดทางแชท 💌')),
 ],
 # 3) warning list
 'promo3-three-donts': [
  ('สามอย่างที่แม่ค้า ห้ามปล่อยให้เอไอทำเอง',
   dict(type='title', lines=['⚠️ 3 อย่างที่แม่ค้า', '<span class="pk">ห้าม</span>ปล่อยให้ AI', 'ทำเอง'])),
  ('หนึ่ง แต่งรีวิวปลอม ใช้เฉพาะรีวิวจริงที่ลูกค้าอนุญาต',
   dict(type='list', tiles=[('#E5484D', '1', 'แต่งรีวิวปลอม', 'ใช้รีวิวจริงที่ลูกค้าอนุญาตเท่านั้น')])),
  ('สอง เติมจุดเด่นที่ร้านไม่มี เอไออาจแต่งเพิ่มเอง ต้องตรวจก่อนโพสต์',
   dict(type='list', tiles=[('#E5484D', '1', 'แต่งรีวิวปลอม'), ('#F59E0B', '2', 'เติมจุดเด่นที่ร้านไม่มี', 'AI อาจแต่งเพิ่มเอง ตรวจก่อนโพสต์')], )),
  ('สาม คิดเลขแล้วไม่ตรวจ กดเครื่องคิดเลขซ้ำทุกครั้ง',
   dict(type='list', tiles=[('#E5484D', '1', 'แต่งรีวิวปลอม'), ('#F59E0B', '2', 'เติมจุดเด่นที่ไม่มีจริง'), (V, '3', 'คิดราคาแล้วไม่ตรวจ', 'กดเครื่องคิดเลขซ้ำทุกครั้ง')])),
  ('ในชุดมีเช็กลิสต์แปดข้อ ก่อนกดโพสต์ กดส่ง',
   dict(type='title', lines=['ในชุดมี <span class="hl">เช็กลิสต์ 8 ข้อ</span>', 'ก่อนกดโพสต์/ส่ง ✅'])),
  ('อยากดูรายละเอียด คอมเมนต์คำว่า โปร',
   dict(type='cta', top='อยากดูรายละเอียดชุด', word='pro', sub='ไม่มีสัญญายอดขาย มีแต่เครื่องมือ 🙏')),
 ],
}


def dur(path):
    with wave.open(path) as w:
        return w.getnframes() / w.getframerate()


async def tts(text, path):
    await edge_tts.Communicate(text, VOICE, rate='+10%').save(path)


def run(*a):
    subprocess.run(a, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def main(name):
    scenes = CLIPS[name]
    d = os.path.join(WORK, name)
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d)
    wavs, spec = [], {'scenes': []}
    for i, (vo, sc) in enumerate(scenes):
        mp3, raw = os.path.join(d, f'{i}.mp3'), os.path.join(d, f'{i}r.wav')
        asyncio.run(tts(vo, mp3))
        run('ffmpeg', '-y', '-i', mp3, '-ar', '44100', '-ac', '1', raw)
        D = round(max(2.2, dur(raw) + 0.45), 2)
        pad = os.path.join(d, f'{i}.wav')
        run('ffmpeg', '-y', '-i', raw, '-af', f'apad=whole_dur={D}', '-ar', '44100', '-ac', '1', pad)
        wavs.append(pad)
        spec['scenes'].append({**sc, 'dur': D})
    lst = os.path.join(d, 'list.txt')
    open(lst, 'w').write(''.join(f"file '{w.replace(chr(92), '/')}'\n" for w in wavs))
    voice = os.path.join(d, 'voice.wav')
    run('ffmpeg', '-y', '-f', 'concat', '-safe', '0', '-i', lst, '-c', 'copy', voice)
    sj = os.path.join(d, 'spec.json')
    json.dump(spec, open(sj, 'w', encoding='utf-8'), ensure_ascii=False)
    fr = os.path.join(d, 'frames')
    subprocess.run(['node', os.path.join(HERE, 'render.js'), sj, fr], check=True)
    out = os.path.join(HERE, name + '.mp4')
    run('ffmpeg', '-y', '-framerate', '30', '-i', os.path.join(fr, '%05d.jpg'), '-i', voice,
        '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20', '-c:a', 'aac', '-b:a', '160k', '-shortest', out)
    print(name, 'ok', sum(s['dur'] for s in spec['scenes']), 's')


if __name__ == '__main__':
    main(sys.argv[1])
