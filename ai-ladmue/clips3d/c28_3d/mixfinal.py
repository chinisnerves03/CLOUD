import numpy as np, json, subprocess
SR=44100;D=37.5
v=np.load('voice.npy');out=np.zeros(int(D*SR));out[:len(v)]+=v
def put(x,t,g=1.0):
    i=int(t*SR);x=x[:len(out)-i];out[i:i+len(x)]+=x*g
tt=lambda d:np.arange(int(d*SR))/SR
def ping(f=1568):
    t=tt(0.5);return (np.sin(2*np.pi*f*t)*np.exp(-t*12)+0.5*np.sin(2*np.pi*f*1.5*t)*np.exp(-t*16))*0.22
def pop(f=520):
    t=tt(0.18);return np.sin(2*np.pi*f*t*(1+0.4*np.exp(-t*30)))*np.exp(-t*24)*0.35
def whoosh():
    t=tt(0.35);n=np.random.RandomState(1).randn(len(t));k=np.convolve(n,np.ones(40)/40,mode='same');return k*np.sin(np.pi*t/0.35)**2*0.5
for i in range(30): put(ping(1568 if i%2 else 1760),5.1+i*1.04+0.5,0.8)
for a in [0.3,4.95,16.5,24.25,32.5]: put(pop(),a,1.0);put(whoosh(),a-0.1,0.5)
for a in [6.2,8.74,19.68,25.69,26.51,27.39,28.15,29.1,30.5]: put(pop(700),a,0.7)
# soft pad
t=tt(D);pad=np.zeros_like(t)
for f,g in [(110,0.5),(164.8,0.4),(220,0.4),(277.2,0.3),(329.6,0.25)]:
    pad+=np.sin(2*np.pi*f*t+np.sin(t*0.3+f))*g
pad*=0.022*(0.75+0.25*np.sin(2*np.pi*t/4.0))
pad*=np.minimum(1,t/1.5)*np.minimum(1,(D-t)/1.5)
out+=pad
out=np.tanh(out*1.1)
import wave
w=wave.open('mix.wav','wb');w.setnchannels(1);w.setsampwidth(2);w.setframerate(SR);w.writeframes((np.clip(out,-1,1)*32767).astype('<i2').tobytes());w.close()
