#!/usr/bin/env python3
"""Builds dashboard.html from dashboard.src.html by embedding the agent prompts."""
import json, pathlib, re
root = pathlib.Path(__file__).parent
ORDER = ['scout', 'clipmaker', 'packager', 'analyst']


def parse(path):
    text = path.read_text(encoding='utf-8')
    name = text.splitlines()[0][2:].strip()
    role = re.search(r'## หน้าที่\n(.*?)(?:\n\n|\n## )', text, re.S).group(1).strip()
    m = re.search(r'เครดิต: (\d+)', text)
    return {'name': name, 'role': role, 'prompt': text.strip(), 'creditHint': int(m.group(1)) if m else 0}


def main():
    agents = {k: parse(root / 'agents' / f'{k}.md') for k in ORDER}
    src = (root / 'dashboard.src.html').read_text(encoding='utf-8')
    out = src.replace('/*__AGENTS__*/', json.dumps(agents, ensure_ascii=False))
    (root / 'dashboard.html').write_text(out, encoding='utf-8')


if __name__ == '__main__':
    main()
