#!/usr/bin/env bash
# Join rendered frames (fr/fNNNNN.jpg, 30 fps) with mix.m4a into pip_thimble_ep01.mp4. Run from mini-detective/.
ffmpeg -y -hide_banner -loglevel error -framerate 30 -i fr/f%05d.jpg -i mix.m4a \
 -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -c:a copy -movflags +faststart -shortest pip_thimble_ep01.mp4
