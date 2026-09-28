#!/bin/bash
# รันโค้ดสร้างโมเดลนอก Studio (ใช้ Roblox API จำลองใน mock.luau) แล้วเขียน parts.jsonl ของ Plot1
set -e
cd "$(dirname "$0")"
SRC=../../src
LUAU=${LUAU:-luau}
mod() { echo "registerModule(\"$1\", function()"; sed -e 's/^--!strict//' -e 's/^export type/type/' "$2"; echo "end)"; }
{ cat mock.luau; mod Config $SRC/ReplicatedStorage/Config.lua; mod ItemModels $SRC/ServerScriptService/Services/ItemModels.lua; mod DevPlotBuilder $SRC/ServerScriptService/Services/DevPlotBuilder.lua; cat dump.luau; } > run.luau
"$LUAU" run.luau > parts.jsonl
grep -E "^#|WARN" parts.jsonl || true
