#!/usr/bin/env bash
# Mix entry 1 voices + synthesized SFX into mix.m4a (53.2 s). Run from mini-detective/.
A=audio_ep01
ffmpeg -y -hide_banner -loglevel error \
 -i "$A/n1.mp3" -i "$A/n2.mp3" -i "$A/pip1.mp3" -i "$A/juno.mp3" -i "$A/n3.mp3" -i "$A/pip2.mp3" -i "$A/n4.mp3" \
 -f lavfi -i "anoisesrc=d=14:c=brown:a=0.5:r=44100" -f lavfi -i "sine=f=95:d=0.2:r=44100" \
 -f lavfi -i "anoisesrc=d=0.5:c=white:a=0.6:r=44100" -f lavfi -i "anoisesrc=d=0.9:c=pink:a=0.6:r=44100" \
 -f lavfi -i "sine=f=1200:d=0.06:r=44100" -f lavfi -i "sine=f=880:d=0.08:r=44100" -f lavfi -i "sine=f=988:d=0.08:r=44100" -f lavfi -i "sine=f=1175:d=0.14:r=44100" \
 -filter_complex "[0]adelay=1000|1000[v0];[1]adelay=9900|9900[v1];[2]adelay=18900|18900[v2];[3]adelay=22200|22200[v3];[4]adelay=27300|27300[v4];[5]adelay=37900|37900[v5];[6]adelay=41400|41400[v6];[7]lowpass=f=420,volume=0.35,afade=t=in:d=1.5,afade=t=out:st=12:d=2,adelay=3000|3000[mur];[8]afade=t=out:st=0.05:d=0.15,volume=0.9,adelay=37350|37350[thump];[9]highpass=f=2500,afade=t=in:d=0.02,afade=t=out:st=0.1:d=0.4,volume=0.12,adelay=37900|37900[tear];[10]bandpass=f=1400:width_type=h:w=1800,afade=t=in:d=0.3,afade=t=out:st=0.4:d=0.5,volume=0.2,adelay=21900|21900[woosh];[11]afade=t=out:st=0.02:d=0.04,volume=0.25,adelay=35130|35130[tk];[12]afade=t=out:st=0.03:d=0.05,volume=0.22,adelay=45050|45050[t1];[13]afade=t=out:st=0.03:d=0.05,volume=0.22,adelay=45150|45150[t2];[14]afade=t=out:st=0.05:d=0.09,volume=0.22,adelay=45250|45250[t3];[v0][v1][v2][v3][v4][v5][v6][mur][thump][tear][woosh][tk][t1][t2][t3]amix=inputs=15:normalize=0:duration=longest,apad=whole_dur=53.2,atrim=0:53.2,loudnorm=I=-14:TP=-1.5:LRA=11[out]" \
 -map "[out]" -ar 44100 -c:a aac -b:a 192k mix.m4a
