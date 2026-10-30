# Mock-up video of the target flame look synced to an audio file (not game code).
# Usage: python3 flame_preview_mock.py WORKDIR  (expects WORKDIR/blend/v2.wav and demo_v2.mp3)
import numpy as np,wave,sys,subprocess
S=sys.argv[1];sr=44100
x=np.frombuffer(wave.open(S+"/blend/v2.wav").readframes(10**9),np.int16)/32768
h=256;n=1024;N=(len(x)-n)//h
idx=np.arange(n)[None,:]+h*np.arange(N)[:,None]
F=np.abs(np.fft.rfft(x[idx]*np.hanning(n),axis=1))**2;f=np.fft.rfftfreq(n,1/sr)
e=10*np.log10(F[:,(f>800)&(f<8000)].sum(1)+1e-9);lo=10*np.log10(F[:,(f>40)&(f<300)].sum(1)+1e-9)
k=int(.25*sr/h);base=np.array([np.median(e[max(0,i-k):i+1]) for i in range(N)]);c=e-base
ev=[];last=-9
for i in range(1,N-1):
  if c[i]>3.5 and c[i]>=c[i-1] and c[i]>=c[i+1]:
    t=i*h/sr
    if t-last>.07: ev.append((t,c[i],lo[i:i+10].max()));last=t
cs=np.array([v[1] for v in ev]);q1,q2=np.percentile(cs,[40,75])
events=[]
for t,cc,l in ev:
  if t<7.2: kind="orange" if cc>q1 else "white"
  elif t<10.6: kind="blue"
  else: kind="orange" if cc>q2 else ("white" if cc>q1 else "blue")
  size={"orange":1.0,"white":.7,"blue":.45}[kind]*min(1.3,.6+cc/25)
  events.append((t,kind,size))
print(len(events),"flames")
col={"orange":np.array([1.0,.45,.08]),"white":np.array([1.0,.85,.6]),"blue":np.array([.25,.45,1.0])}
core={"orange":np.array([1,.8,.4]),"white":np.array([1,1,.92]),"blue":np.array([.85,.92,1])}
W,H=360,640;fps=30;dur=len(x)/sr
yy,xx=np.mgrid[0:H,0:W].astype(np.float32)
px,py=W*.68,H*.52
# static scene
bg=np.zeros((H,W,3),np.float32)+np.array([.015,.017,.025])
road=yy>H*.6;bg[road]=np.array([.03,.03,.035])
bump=(np.abs(xx-W/2)<W*.46)&(yy>H*.3)&(yy<H*.5)
bg[bump]=np.array([.035,.037,.045])
pipe=((xx-px)**2/1.0+(yy-py)**2/0.5)<14**2
rng=np.random.default_rng(1)
p=subprocess.Popen(["ffmpeg","-v","error","-y","-f","rawvideo","-pix_fmt","rgb24","-s",f"{W}x{H}","-r",str(fps),"-i","-","-i",S+"/blend/demo_v2.mp3","-vf","scale=540:960:flags=lanczos","-c:v","libx264","-pix_fmt","yuv420p","-crf","23","-c:a","aac","-b:a","160k","-shortest",S+"/blend/flames_v2.mp4"],stdin=subprocess.PIPE)
for fi in range(int(dur*fps)):
  t=fi/fps;img=bg.copy();light=np.zeros(3,np.float32);glow=np.zeros((H,W,3),np.float32)
  for te,kind,size in events:
    a=t-te
    if a<0 or a>.16: continue
    life=np.exp(-a/.05)*(1+.25*rng.standard_normal())
    r=(45+70*size)*(.6+a*5)
    cx=px+rng.normal(0,3);cy=py+a*120*size  # ball rolls out toward camera/down
    ang=np.arctan2(yy-cy,xx-cx);ph=rng.uniform(0,6.3,3)
    wob=1+.13*np.sin(3*ang+ph[0])+.08*np.sin(5*ang+ph[1])+.05*np.sin(8*ang+ph[2])
    d0=((xx-cx)**2+((yy-cy)*1.15)**2);d2=d0/wob**2
    glow+=life*(np.exp(-d2/(2*(r*.35)**2))[...,None]*core[kind]*(1.2 if kind=="blue" else 2.6)+np.exp(-d2/(2*r**2))[...,None]*col[kind]*1.4+np.exp(-d0/(2*(r*3)**2))[...,None]*col[kind]*.25)
    light+=life*size*col[kind]
  # bumper and road lit by the flash
  d=np.sqrt((xx-px)**2+(yy-py)**2)
  fall=np.exp(-d/90)
  img+=(bump|road)[...,None]*fall[...,None]*light*.6
  img[pipe]=np.array([.02,.02,.02])+light*.15
  img+=glow
  img=1-np.exp(-img*1.4)  # tonemap with bloom-ish rolloff
  p.stdin.write((np.clip(img,0,1)*255).astype(np.uint8).tobytes())
p.stdin.close();p.wait();print("done")
