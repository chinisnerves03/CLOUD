import numpy as np, wave
SR=44100; DUR=29.6
N=int(SR*DUR); L=np.zeros(N); 
def tone(f0,d,wave='sq',duty=0.5,f1=None,env=8.0,vol=1.0):
    n=int(SR*d); t=np.arange(n)/SR
    f=f0 if f1 is None else f0+(f1-f0)*(t/d)
    ph=np.cumsum(f)/SR
    if wave=='sq': y=np.where((ph%1)<duty,1.0,-1.0)
    elif wave=='tri': y=2*np.abs(2*(ph%1)-1)-1
    else: y=np.random.uniform(-1,1,n)
    return y*np.exp(-t*env)*vol
def put(x,at,v=1.0):
    i=int(at*SR); 
    if i>=N: return
    m=min(len(x),N-i); L[i:i+m]+=x[:m]*v
def noise(d,env=20,lp=0.3,vol=1.0):
    n=int(SR*d); y=np.random.uniform(-1,1,n)
    k=int(1/lp) ; y=np.convolve(y,np.ones(max(1,k))/max(1,k),mode='same')
    return y*np.exp(-np.arange(n)/SR*env)*vol
def add(*xs):
    n=max(len(x) for x in xs);o=np.zeros(n)
    for x in xs:o[:len(x)]+=x
    return o
np.random.seed(3)
# ---- music: 140 BPM, Am F C G
bpm=140; beat=60/bpm
prog=[(57,[57,60,64]),(53,[53,57,60]),(48,[48,52,55]),(55,[55,59,62])]
mf=lambda m:440*2**((m-69)/12)
t0=0.0;bar=0
while t0<DUR-0.1:
    root,ch=prog[bar%4]
    for b in range(8):
        at=t0+b*beat/2
        put(tone(mf(root-12 if b%2==0 else root),beat/2*0.9,'tri',env=3,vol=0.5),at)
        put(tone(mf(ch[b%3]+12),beat/2*0.85,'sq',duty=0.25,env=6,vol=0.16),at)
    for b in range(4):
        put(noise(0.04,env=80,lp=0.9,vol=0.25),t0+b*beat+beat/2)
        if b%2==0: put(tone(150,0.12,'tri',f1=45,env=18,vol=0.9),t0+b*beat)
    t0+=4*beat; bar+=1
L*=0.55
# ---- sfx
def sfx(x,at,v=1.0): put(x,at,v)
sfx(tone(660,0.5,'sq',f1=990,env=5,vol=0.5),0.3)
sfx(add(tone(80,0.8,'tri',f1=40,env=3,vol=1.0),noise(0.3,env=9,lp=0.5,vol=0.5)),2.6)
for i,f in enumerate([523,659,784,1047]): sfx(tone(f,0.12,'sq',env=6,vol=0.4),4.0+i*0.1)
punch=lambda: add(noise(0.25,env=14,lp=0.15,vol=1.0),tone(120,0.2,'tri',f1=50,env=12,vol=1.0))
sfx(punch(),6.4,0.7); sfx(tone(500,0.15,'sq',f1=250,env=14,vol=0.4),9.6)
for i,b in enumerate([13.83,15.47,17.18,18.91]):
    sfx(tone(660*2**(i/6),0.09,'sq',env=10,vol=0.4),b); sfx(tone(990*2**(i/6),0.16,'sq',env=8,vol=0.4),b+0.09)
    sfx(punch(),b+0.5,1.0)
sfx(add(tone(60,1.4,'tri',f1=30,env=2.2,vol=1.2),noise(0.7,env=5,lp=0.4,vol=0.9),tone(440,0.8,'sq',f1=110,env=3,vol=0.4)),20.9)
for i,f in enumerate([523,659,784,1047,784,1047]): sfx(tone(f,0.14,'sq',env=5,vol=0.4),21.84+i*0.13)
sfx(tone(1318,0.12,'sq',env=8,vol=0.4),26.06); sfx(tone(1760,0.3,'sq',env=6,vol=0.4),26.18)
L=np.tanh(L*1.2)
pcm=(np.clip(L,-1,1)*30000).astype('<i2')
with wave.open('/tmp/claude-0/-home-user-CLOUD/fea08458-65f5-522c-bce6-c540bdc038b5/scratchpad/fx15.wav','wb') as w:
    w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())
print('ok')
