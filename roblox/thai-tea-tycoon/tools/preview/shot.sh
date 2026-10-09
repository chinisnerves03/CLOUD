#!/bin/bash
# usage: ./shot.sh name 'eye=x,y,z&at=x,y,z' : render parts.jsonl to shots/name.png (python3 -m http.server 8765 must run)
cd "$(dirname "$0")"
CHROME=${CHROME:-/opt/pw-browsers/chromium} node shoot.mjs "{\"$1\":\"$2\"}" 2>&1 | grep -v "404" || true
