# Preview (development only — not part of the Roblox game)

Renders the models from `ItemModels.lua` without Roblox Studio: the builders run against a small Roblox API mock (`mock.luau`) and three.js draws the result.

```bash
npm install && npm run setup
LUAU=/path/to/luau ./build.sh            # writes parts.jsonl (Plot1 + plaza) and prints part counts per item
python3 -m http.server 8765 &
node shoot.mjs '{"overview":"eye=-110,100,-25&at=-110,0,82"}'   # saves shots/overview.png
```

Camera coordinates are world space. Plot1's floor center is at (-110, 1, 85) and its front faces -Z.
Add `&clip=Y` to cut away everything above height Y (to look inside buildings). Set `CHROME=/path/to/chrome` if Playwright cannot find a browser.
