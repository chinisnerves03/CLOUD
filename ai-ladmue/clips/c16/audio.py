import numpy as np, wave
SR=44100; DUR=38.6
N=int(SR*DUR)
rs=np.random.RandomState(11)
def add(*xs):
    n=max(len(x) for x in xs);o=np.zeros(n)
    for x in xs:o[:len(x)]+=x
    return o
def tone(f0,d,w='sin',f1=None,env=8.0,vol=1.0,duty=0.5):
    n=int(SR*d);t=np.arange(n)/SR
    f=f0 if f1 is None else f0+(f1-f0)*(t/d)
    ph=np.cumsum(np.ones(n)*f if np.isscalar(f) else f)/SR
    if w=='sin':y=np.sin(2*np.pi*ph)
    elif w=='tri':y=2*np.abs(2*(ph%1)-1)-1
    elif w=='saw':y=2*(ph%1)-1
    else:y=np.where((ph%1)<duty,1.0,-1.0)
    return y*np.exp(-t*env)*vol
def noise(d,env=20,lp=1,vol=1.0):
    n=int(SR*d);y=rs.uniform(-1,1,n)
    if lp>1:y=np.convolve(y,np.ones(lp)/lp,mode='same')
    return y*np.exp(-np.arange(n)/SR*env)*vol
def put(buf,x,at,v=1.0):
    i=int(at*SR)
    if i>=N:return
    m=min(len(x),N-i);buf[i:i+m]+=x[:m]*v
mf=lambda m:440*2**((m-69)/12)
# ---------- bgm: upbeat plucks, C G Am F, 112 bpm
B=np.zeros(N);beat=60/112
prog=[(48,[60,64,67]),(55,[59,62,67]),(57,[60,64,69]),(53,[60,65,69])]
bars=int(DUR/(4*beat))+1
for bar in range(bars):
    r,ch=prog[bar%4]
    for b in range(4):
        at=bar*4*beat+b*beat
        put(B,tone(mf(r),beat*0.9,'tri',env=3.5,vol=0.5),at)
        put(B,tone(mf(ch[b%3]+12),0.3,'sin',env=7,vol=0.28),at+beat/2)
        put(B,tone(mf(ch[(b+1)%3]+12),0.3,'sin',env=7,vol=0.22),at)
        if b%2==1:put(B,noise(0.05,env=70,lp=2,vol=0.25),at)
B*=0.4
# ---------- sfx
X=np.zeros(N)
def whoosh(at):put(X,noise(0.4,env=6,lp=40,vol=0.7)*np.linspace(0.2,1,int(SR*0.4)),at)
def ding(at,f=1318):put(X,add(tone(f,0.5,'sin',env=6,vol=0.5),tone(f*2,0.35,'sin',env=9,vol=0.2)),at)
def scratch(at):put(X,tone(1800,0.28,'saw',f1=250,env=4,vol=0.45)+0*noise(0.28),at)
def womp(at):
    x=0
    for f,d in [(233,0.22),(220,0.22),(208,0.22),(185,0.6)]:
        y=np.convolve(tone(f,d,'saw',env=1.5,vol=0.5),np.ones(5)/5,mode='same');put(X,y,at+x);x+=d
def boom(at):put(X,add(tone(70,0.7,'sin',f1=35,env=4,vol=1.0),noise(0.25,env=14,lp=6,vol=0.5)),at)
whoosh(0.05); ding(2.0,1568)
for p in (3.5,10.9,16.85,23.9):ding(p+0.02)
for r in (6.8,13.5,19.75,26.6):scratch(r-0.02);boom(r+0.22);womp(r+0.35)
# r1 alarm beeps
for i in range(14):put(X,tone(2400,0.12,'sq',env=3,vol=0.18),7.6+i*0.28)
# r2 sizzle
put(X,noise(2.6,env=0.6,lp=3,vol=0.35),14.0)
for i in range(6):put(X,tone(500,0.12,'sin',f1=300,env=12,vol=0.3),14.0+0.5+i*0.4)
# p3 coins / r3 cha-ching
for i in range(3):put(X,tone(1976,0.15,'sin',env=10,vol=0.4)+0,17.55+i*0.45)
ding(21.4,2093);put(X,tone(1568,0.3,'sin',env=7,vol=0.35),21.5)
# p4 typing
for i in range(18):put(X,noise(0.03,env=120,lp=2,vol=0.5),24.4+i*0.13)
# r4 laugh-ish blips
for i in range(10):put(X,tone(600+(i%3)*80,0.09,'sq',env=14,vol=0.2),27.4+i*0.22)
ding(34.8,1760);ding(30.2,1175)
def save(buf,name,g=1.0):
    buf=np.tanh(buf*g)
    pcm=(np.clip(buf,-1,1)*30000).astype('<i2')
    with wave.open(name,'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())
d='/home/user/CLOUD/ai-ladmue/clips/c16/hf/assets/'
save(B,d+'bgm.wav',1.0);save(X,d+'sfx.wav',1.0);print('ok')
