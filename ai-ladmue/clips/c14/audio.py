import numpy as np, wave
SR=44100; DUR=31.4
N=int(SR*DUR); L=np.zeros(N)
rs=np.random.RandomState(5)
def add(*xs):
    n=max(len(x) for x in xs);o=np.zeros(n)
    for x in xs:o[:len(x)]+=x
    return o
def tone(f0,d,w='sq',duty=0.5,f1=None,env=8.0,vol=1.0,vib=0):
    n=int(SR*d); t=np.arange(n)/SR
    f=(f0 if f1 is None else f0+(f1-f0)*(t/d))*(1+vib*np.sin(2*np.pi*6*t))
    ph=np.cumsum(f)/SR
    if w=='sq': y=np.where((ph%1)<duty,1.0,-1.0)
    elif w=='tri': y=2*np.abs(2*(ph%1)-1)-1
    elif w=='saw': y=2*(ph%1)-1
    else: y=np.sin(2*np.pi*ph)
    return y*np.exp(-t*env)*vol
def noise(d,env=20,lp=1,vol=1.0):
    n=int(SR*d); y=rs.uniform(-1,1,n)
    if lp>1: y=np.convolve(y,np.ones(lp)/lp,mode='same')
    return y*np.exp(-np.arange(n)/SR*env)*vol
def put(x,at,v=1.0):
    i=int(at*SR)
    if i>=N: return
    m=min(len(x),N-i); L[i:i+m]+=x[:m]*v
mf=lambda m:440*2**((m-69)/12)
# tape hiss + hum
L+=rs.uniform(-1,1,N)*0.012
tt=np.arange(N)/SR; L+=np.sin(2*np.pi*60*tt)*0.008
# underscore: light bass + pluck, 100 bpm
beat=0.6; prog=[48,53,55,48]; 
for bar in range(int(DUR/(4*beat))+1):
    r=prog[bar%4]
    for b in range(4):
        at=bar*4*beat+b*beat
        put(tone(mf(r-12),beat*0.8,'tri',env=3,vol=0.5),at)
        put(tone(mf(r+12+[0,4,7,4][b]),0.25,'sq',duty=0.3,env=9,vol=0.1),at+beat/2)
L*=0.35
# intro jingle
for i,m in enumerate([67,71,74,79]): put(tone(mf(m),0.18,'sq',duty=0.4,env=5,vol=0.3),0.0+i*0.12)
# glitch bursts at cuts
for c in [3.8,7.2,13.3,14.4,17.2,18.3,28.3]:
    put(noise(0.18,env=14,lp=2,vol=0.5),c-0.02)
# error buzz
put(tone(110,0.6,'sq',env=2,vol=0.35)*(0.6+0.4*np.sign(np.sin(2*np.pi*14*np.arange(int(SR*0.6))/SR))),13.32)
# ?! boing
put(tone(300,0.35,'sin',f1=900,env=4,vol=0.5,vib=0.03),14.5)
# womp womp (sad trombone)
x=0.0
for f,d,v in [(233,0.30,0),(220,0.30,0),(208,0.30,0),(185,0.9,0.02)]:
    y=tone(f,d,'saw',env=1.2,vol=0.5,vib=v)
    y=np.convolve(y,np.ones(5)/5,mode='same')
    put(y,17.25+x); x+=d
# sticky pops and CTA ding
for a in [18.9,21.65]: put(tone(880,0.1,'sq',env=12,vol=0.3),a); put(tone(1320,0.15,'sq',env=10,vol=0.3),a+0.08)
put(tone(1318,0.15,'sin',env=6,vol=0.4),28.3); put(tone(1760,0.4,'sin',env=5,vol=0.4),28.42)
# rewind
n=int(SR*0.4); t=np.arange(n)/SR; ph=np.cumsum(900+t*3000)/SR
put((np.sign(np.sin(2*np.pi*ph*2))*0.15+rs.uniform(-1,1,n)*0.25)*(1-t/0.4*0.3),24.6)
L=np.tanh(L*1.1)
pcm=(np.clip(L,-1,1)*30000).astype('<i2')
with wave.open('/tmp/claude-0/-home-user-CLOUD/fea08458-65f5-522c-bce6-c540bdc038b5/scratchpad/fx14.wav','wb') as w:
    w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())
print('ok')
