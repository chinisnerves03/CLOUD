#!/bin/bash
# Measure every item alone and write a solo row of the given items to parts.jsonl (render with render.html)
# usage: LUAU=path/to/luau ./items.sh L02 L03 L04      (sizes print as "#SIZE" lines, studs and metres)
set -e
cd "$(dirname "$0")"
SRC=../../src
LUAU=${LUAU:-luau}
mod() { echo "registerModule(\"$1\", function()"; sed -e 's/^--!strict//' -e 's/^export type/type/' "$2"; echo "end)"; }
show=""
for k in "$@"; do show="$show\"$k\","; done
{ cat mock.luau; mod Config $SRC/ReplicatedStorage/Config.lua; mod ItemModels $SRC/ServerScriptService/Services/ItemModels.lua; echo "SHOW = { $show }"; cat items.luau; } > run.luau
"$LUAU" run.luau > parts.jsonl
grep -E "^#|WARN" parts.jsonl || true
