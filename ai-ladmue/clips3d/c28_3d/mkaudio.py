import subprocess, numpy as np, json, math
D=37.5; FPS=60; SR=44100
L=[('H',0.15,'l1'),('R',4.8,'l2'),('H',11.8,'l3'),('R',16.4,'l4'),('H',21.25,'l5'),('R',24.15,'l6'),('R',32.2,'l7')]
def dec(f):
    r=subprocess.run(['ffmpeg','-v','error','-i','audio/%s.mp3'%f,'-f','f32le','-ac','1','-ar',str(SR),'-'],capture_output=True)
    return np.frombuffer(r.stdout,dtype=np.float32)
N=int(D*FPS)+2
env={'H':np.zeros(N),'R':np.zeros(N)}
mix=np.zeros(int(D*SR))
lines=[]
for s,a,f in L:
    x=dec(f); b=a+len(x)/SR; lines.append((s,a,b))
    i0=int(a*SR); mix[i0:i0+len(x)]+=x*0.9
    for k in range(int(a*FPS),min(N,int(b*FPS)+1)):
        seg=x[int((k/FPS-a)*SR):int(((k+1)/FPS-a)*SR)]
        if len(seg): env[s][k]=math.sqrt(np.mean(seg**2))
out={}
for s in 'HR':
    e=env[s]; p=np.percentile(e[e>0],92); e=np.clip(e/p,0,1)
    sm=np.copy(e)
    for i in range(1,N): sm[i]=max(e[i],sm[i-1]*0.6) if e[i]<sm[i-1] else e[i]*0.7+sm[i-1]*0.3
    out[s]=sm
hg=np.convolve(out['H'],np.ones(30)/30,mode='same')
hg=np.clip(hg/ max(hg.max(),1e-6),0,1)
r=lambda a:[round(float(v),3) for v in a]
open('env.js','w').write('window.ENV='+json.dumps({'fps':FPS,'h':r(out['H']),'r':r(out['R']),'hg':r(hg)})+';')
json.dump({'D':D,'lines':[{'s':s,'a':round(a,2),'b':round(b,2)} for s,a,b in lines]},open('lines_t.json','w'))
np.save('voice.npy',mix)
print([(s,round(a,2),round(b,2)) for s,a,b in lines])
