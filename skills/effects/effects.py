#!/usr/bin/env python3
"""/effects: ffmpeg-only video effects for vertical reels (1080x1920).
Usage:
  effects.py magazine IN OUT --title "MASTHEAD" --headline "Big headline" [--dur 2.5]
  effects.py beforeafter IN OUT [--before-grade] [--after IN2] [--wipe 3]
  effects.py orbit IN OUT [--zoom 1.25] [--period 4]
Needs ffmpeg and DejaVu fonts (override with --font).
"""
import argparse, subprocess, sys

FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"
FIT = "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1"


def esc(t):
    return t.replace("\\", "\\\\").replace(":", "\\:").replace("'", "’").replace("%", "\\%")


def run(args, fc, out, extra=()):
    cmd = ["ffmpeg", "-y", "-loglevel", "error", *args, "-filter_complex", fc,
           "-map", "[v]", "-map", "0:a?", "-c:v", "libx264", "-pix_fmt", "yuv420p",
           "-crf", "18", "-c:a", "aac", *extra, out]
    subprocess.run(cmd, check=True)


def magazine(a):
    f, d = a.font, a.dur
    en = f"enable='between(t,0,{d})'"
    fc = (f"[0:v]{FIT},"
          f"drawbox=x=0:y=0:w=1080:h=330:color=black@0.45:t=fill:{en},"
          f"drawbox=x=40:y=40:w=1000:h=1840:color=white@0.9:t=8:{en},"
          f"drawtext=fontfile={f}:text='{esc(a.title)}':fontsize=170:fontcolor=white:x=(w-text_w)/2:y=90:{en},"
          f"drawbox=x=0:y=1450:w=1080:h=330:color=black@0.55:t=fill:{en},"
          f"drawtext=fontfile={f}:text='{esc(a.headline)}':fontsize=76:fontcolor=#E0A526:x=(w-text_w)/2:y=1560:{en}[v]")
    run(["-i", a.inp], fc, a.out)


def beforeafter(a):
    P = a.wipe
    # B = before (left of line is 'after'), line sweeps left to right then holds
    expr = f"min(T/{P},1)*W"
    graded = ("eq=saturation=0.35:contrast=0.9:brightness=-0.04" if a.before_grade else "null")
    if a.after:
        ins = ["-i", a.inp, "-i", a.after]
        fc = f"[0:v]{FIT},{graded}[b];[1:v]{FIT}[a];"
    else:
        ins = ["-i", a.inp]
        fc = f"[0:v]{FIT},split[x][y];[x]{graded}[b];[y]eq=saturation=1.3:contrast=1.08[a];"
    ln = f"lt(abs(X-{expr}),4)"
    fc += (f"[a][b]blend=c0_expr='if({ln},235,if(lt(X,{expr}),A,B))':"
           f"c1_expr='if({ln},128,if(lt(X,{expr}),A,B))':"
           f"c2_expr='if({ln},128,if(lt(X,{expr}),A,B))'[v]")
    run(ins, fc, a.out)


def orbit(a):
    z, p = a.zoom, a.period
    w, h = 1080, 1920
    zw, zh = int(w * z), int(h * z)
    fc = (f"[0:v]{FIT},scale={zw}:{zh},"
          f"crop={w}:{h}:x=({zw}-{w})/2*(1+sin(2*PI*t/{p})):"
          f"y=({zh}-{h})/2*(1+cos(2*PI*t/{p})),setsar=1[v]")
    run(["-i", a.inp], fc, a.out)


def main():
    ap = argparse.ArgumentParser()
    sp = ap.add_subparsers(dest="cmd", required=True)
    for n in ("magazine", "beforeafter", "orbit"):
        s = sp.add_parser(n); s.add_argument("inp"); s.add_argument("out")
        s.add_argument("--font", default=FONT)
    m = sp.choices["magazine"]
    m.add_argument("--title", default="MOD WEEKLY"); m.add_argument("--headline", default="THE MOD EVERYONE'S TALKING ABOUT")
    m.add_argument("--dur", type=float, default=2.5)
    b = sp.choices["beforeafter"]
    b.add_argument("--before-grade", action="store_true"); b.add_argument("--after"); b.add_argument("--wipe", type=float, default=3)
    o = sp.choices["orbit"]
    o.add_argument("--zoom", type=float, default=1.25); o.add_argument("--period", type=float, default=4)
    a = ap.parse_args()
    {"magazine": magazine, "beforeafter": beforeafter, "orbit": orbit}[a.cmd](a)


if __name__ == "__main__":
    main()
