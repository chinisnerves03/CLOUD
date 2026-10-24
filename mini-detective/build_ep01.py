import base64,json,sys
d='audio_ep01/'
vo={k:'data:audio/mpeg;base64,'+base64.b64encode(open(d+k+'.mp3','rb').read()).decode() for k in ['n1','n2','pip1','juno','n3','pip2','n4']}
s=open('ep01_preview.src.html',encoding='utf-8').read().replace('/*VOSRC*/{}',json.dumps(vo))
open('ep01_preview.html','w',encoding='utf-8').write(s)
print('built',len(s)//1024,'KB')
