import json, pathlib, re, subprocess, sys
root = pathlib.Path(__file__).parent
agents = sorted((root / 'agents').glob('*.md'))
assert len(agents) == 4, f'expected 4 agent files, got {len(agents)}'
for a in agents:
    t = a.read_text(encoding='utf-8')
    assert t.startswith('# '), f'{a.name}: missing title'
    assert '## หน้าที่' in t and '## กติกา' in t, f'{a.name}: missing sections'
    assert 'ไม่เดาตัวเลข' in t and 'ห้ามโพสต์ออกภายนอกเอง' in t, f'{a.name}: missing global rules'
clips = json.loads((root / 'seed' / 'clips.json').read_text(encoding='utf-8'))
assert len(clips) >= 14, 'seed needs >= 14 clips'
nums = [c['number'] for c in clips]
assert len(nums) == len(set(nums)), 'duplicate clip numbers'
for c in clips:
    assert {'number', 'style', 'topic', 'durationSec', 'file'} <= set(c), c
subprocess.run([sys.executable, str(root / 'build.py')], check=True)
html = (root / 'dashboard.html').read_text(encoding='utf-8')
assert '/*__AGENTS__*/' not in html, 'marker left in built html'
m = re.search(r'const AGENTS = (\{.*?\});', html, re.S)
assert m, 'AGENTS object missing'
data = json.loads(m.group(1))
assert set(data) == {'scout', 'clipmaker', 'packager', 'analyst'}, data.keys()
assert all({'name', 'role', 'prompt', 'creditHint'} <= set(v) for v in data.values())
print('OK', len(clips), 'clips', len(data), 'agents')
