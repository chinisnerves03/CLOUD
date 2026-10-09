# Preview (development only — not part of the Roblox game)

Renders the models from `ItemModels.lua` without Roblox Studio: the builders run against a small Roblox API mock (`mock.luau`) and three.js draws the result.

```bash
npm install && npm run setup
LUAU=/path/to/luau ./build.sh            # writes parts.jsonl (Plot1 + plaza) and prints part counts per item
python3 -m http.server 8765 &
node shoot.mjs '{"overview":"eye=-130,100,-25&at=-130,0,82"}'   # saves shots/overview.png
./shot.sh name 'eye=..&at=..'           # same for one view (Chromium in /opt/pw-browsers by default)
LUAU=... ./items.sh L02 L11              # '#SIZE' of every item (studs + metres), and a solo row of L02, L11 next to a 5.5-stud person
python3 check_pads.py                    # every PadSpot on free floor (0.5 stud clear of earlier items + fixed props)
```

Camera coordinates are world space. Plot1's floor center is at (-130, 1, 85) (world = plot space + (-130, 1, 85)) and its front faces -Z.
Add `&clip=Y` to cut away everything above height Y (to look inside buildings). Set `CHROME=/path/to/chrome` if Playwright cannot find a browser.
