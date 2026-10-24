import re
S=open('scene.js').read()
L=S.split('\n')
PRE={135: 'sc.add(new THREE.HemisphereLight(0xffd9b', 136: 'const key=new THREE.DirectionalLight(0xf', 137: 'const rim=new THREE.PointLight(0x6fa0ff,', 138: 'const lampL=new THREE.PointLight(0xffb34', 139: 'const faceFill=new THREE.PointLight(0xff', 140: 'const fillR=new THREE.PointLight(0x6ff0f', 142: 'const SHOTS={wide:{pos:[0,1.5,4.3],tg:[0', 143: 'const keys=[{time:0,...SHOTS.H}];', 144: 'LINES.forEach(l=>keys.push({time:Math.ma', 145: 'keys.push({time:DUR-4.5,...SHOTS.wide});'}
def rep(n,new):
    for i,l in enumerate(L):
        if l.startswith(PRE[n]):
            L[i]=new;return
    raise Exception('nf %d'%n)
# neon font fix
for i,l in enumerate(L):
    if l.startswith("const neonTex="):
        L[i]=l.replace("Prompt, sans-serif","P, sans-serif").replace("const neonTex=mkc(512,200,(g,w,h)=>{","const neonDraw=(g,w,h)=>{").replace("g.fillText('฿1,000,000',w/2,h/2+6)});","g.fillText('฿1,000,000',w/2,h/2+6)};\nconst neonTex=mkc(512,200,neonDraw);let neonOK=false;")
        break
# lights block 135-140
rep(135,"sc.add(new THREE.HemisphereLight(0xb9a0ff,0x3a2414,0.55));")
rep(136,"const key=new THREE.DirectionalLight(0xffc98a,2.1);key.position.set(2.5,4,4);key.castShadow=true;key.shadow.mapSize.set(2048,2048);key.shadow.radius=3;key.shadow.camera.left=-3;key.shadow.camera.right=3;key.shadow.camera.top=3.5;key.shadow.camera.bottom=-1;key.shadow.camera.near=1;key.shadow.camera.far=12;key.shadow.bias=-0.0004;key.shadow.normalBias=0.02;sc.add(key);")
rep(137,"const rim=new THREE.PointLight(0x7aa0ff,9,7);rim.position.set(1.4,1.9,-1.9);sc.add(rim);const rim2=new THREE.PointLight(0xff4fa3,5,5);rim2.position.set(-0.6,2.3,-1.9);sc.add(rim2);")
rep(138,"const lampL=new THREE.PointLight(0xffb347,7,5.5);lampL.position.set(-2.3,1.5,-0.5);sc.add(lampL);")
rep(139,"const faceFill=new THREE.PointLight(0xfff0dd,3.2,3.2);faceFill.position.set(-0.3,1.6,1.4);sc.add(faceFill);const goldL=new THREE.PointLight(0xffd23f,0,2.2);goldL.position.set(0.6,1.05,0.5);sc.add(goldL);")
# camera plan 142-149
rep(142,"const SHOTS={wide:{pos:[0.1,1.55,4.2],tg:[0.05,1.15,-0.4],f:44},two:{pos:[0.15,1.4,3.0],tg:[0.05,1.12,-0.3],f:42},H:{pos:[-0.5,1.3,1.65],tg:[-0.6,1.14,-0.4],f:41},Hc:{pos:[-0.56,1.2,1.3],tg:[-0.6,1.15,-0.4],f:40},R:{pos:[0.72,1.42,1.7],tg:[0.7,1.38,-0.5],f:38},Rp:{pos:[0.75,1.15,1.9],tg:[0.62,1.05,0.05],f:40}};")
rep(143,"const keys=[[0,'H'],[4.7,'R'],[8.2,'two'],[11.7,'Hc'],[16.3,'R'],[19.8,'Rp'],[21.1,'H'],[24.0,'two'],[28.4,'Rp'],[32.0,'R'],[34.8,'wide']].map(a=>({time:a[0],...SHOTS[a[1]]}));")
rep(144,"")
rep(145,"")
# camAt handheld
for i,l in enumerate(L):
    if l.startswith("const push=0.1*cl"):
        L[i]=l  # unchanged
S='\n'.join(L)
S=S.replace("return{P:P.map((v,j)=>v+(Tg[j]-v)*push),Tg,f:lerp(p.f,k.f,b)}}","return{P:P.map((v,j)=>v+(Tg[j]-v)*push+[Math.sin(t*0.9)*0.012,Math.sin(t*1.3+1)*0.009,Math.sin(t*0.7+2)*0.01][j]),Tg,f:lerp(p.f,k.f,b)}}")
# poses/timing
S=S.replace("const SEGS=[[0,'cheeks'],[1.7,'facepalm'],[3.3,'type'],[9.4,'chin'],[12.6,'type'],[15.6,'chin'],[19.3,'type'],[22.35,'cheer'],[24.2,'shrug'],[25.6,'type'],[27.9,'wave']];","const SEGS=[[0,'chin'],[4.7,'type'],[11.7,'cheeks'],[16.7,'chin'],[21.1,'cheer'],[23.1,'chin'],[24.0,'type'],[32.3,'wave']];")
S=S.replace("worried=t<3.7,happy=t>25.66,","worried=(t>11.7&&t<17.4),happy=((t>21.1&&t<23.1)||t>32.3),")
S=S.replace("const BL=[1.2,3.9,6.1,8.8,9.1,11.4,13.7,16.3,18.9,21.2,24.1,26.6,29.3];","const BL=[1.2,3.9,6.1,8.8,9.1,11.4,13.7,16.3,18.9,21.2,24.1,26.6,29.3,31.5,34.2,36.4];")
S=S.replace("happy:(happy||(t>22.35&&t<24.2))","happy:happy")
S=S.replace("const shake=1-sm(cl((t-1.3)/0.5)),waveAmt=sm(cl((t-27.9)/0.4)),happyNow=(t>22.35&&t<24.2)||t>25.66;","const shake=0,waveAmt=sm(cl((t-32.4)/0.4)),happyNow=happy;")
S=S.replace("fillR.intensity=aR*2.0;","fillR.intensity=aR*2.4;")
# extras insertion before seek definition marker
extra = r"""
// ---------- piggy bank + coin tower + dust + bloom
const PG=new THREE.Group();PG.position.set(0.5,0.815,0.3);PG.rotation.y=-0.45;sc.add(PG);
{const pink=PM(0xff9eb5,{roughness:0.32,clearcoat:0.6,clearcoatRoughness:0.2}),pinkD=PM(0xf0829f,{roughness:0.4});
 const bd=add(new THREE.SphereGeometry(0.115,40,28),pink,0,0.14,0,PG);bd.scale.set(1,0.9,1.22);
 const sn=add(new THREE.CylinderGeometry(0.04,0.045,0.05,20),pinkD,0,0.135,0.15,PG);sn.rotation.x=Math.PI/2;
 [-1,1].forEach(s=>{add(new THREE.CylinderGeometry(0.006,0.006,0.012,8),PM(0x3a1020),s*0.014,0.135,0.177,PG).rotation.x=Math.PI/2;
  const ear=add(new THREE.ConeGeometry(0.034,0.06,4),pinkD,s*0.06,0.235,0.07,PG);ear.rotation.z=-s*0.35;
  add(new THREE.SphereGeometry(0.015,12,10),PM(0x1b0a14,{roughness:0.2,clearcoat:1}),s*0.062,0.178,0.11,PG);
  [-0.06,0.07].forEach(z=>add(new THREE.CylinderGeometry(0.026,0.03,0.07,12),pinkD,s*0.065,0.04,z,PG))});
 add(new THREE.BoxGeometry(0.085,0.004,0.014),PM(0x3a1020),0,0.252,-0.02,PG);
 const tail=add(new THREE.TorusGeometry(0.025,0.006,8,16,Math.PI*1.5),pinkD,0,0.15,-0.15,PG);tail.rotation.y=Math.PI/2}
const goldM=new THREE.MeshStandardMaterial({color:0xffc83a,emissive:0x8a5a00,emissiveIntensity:0.9,roughness:0.28,metalness:0.6});
const coinG=new THREE.CylinderGeometry(0.036,0.036,0.009,24);
const NCOIN=30,COIN_T=[];for(let i=0;i<NCOIN;i++)COIN_T.push(5.1+i*1.04);
const coins=COIN_T.map(()=>{const c=new THREE.Mesh(coinG,goldM);c.castShadow=true;sc.add(c);return c});
const tower=COIN_T.map((_,i)=>{const c=new THREE.Mesh(coinG,goldM);c.castShadow=true;c.position.set(0.98+Math.sin(i*2.1)*0.004,0.8195+i*0.0095,0.3);c.rotation.y=i;sc.add(c);return c});
const dustN=140,dustP=new Float32Array(dustN*3),dustB=[];for(let i=0;i<dustN;i++){const b=[(rnd()-0.5)*5,0.3+rnd()*2.4,-2+rnd()*3.6,rnd()*6.28,0.2+rnd()*0.4];dustB.push(b)}
const dustG=new THREE.BufferGeometry();dustG.setAttribute('position',new THREE.BufferAttribute(dustP,3));
const dust=new THREE.Points(dustG,new THREE.PointsMaterial({color:0xffe2b0,size:0.014,transparent:true,opacity:0.55,depthWrite:false,blending:THREE.AdditiveBlending}));dust.frustumCulled=false;sc.add(dust);
const bl=document.getElementById('bloom'),bg=bl.getContext('2d');
function bloomPass(){bg.filter='brightness(0.62) contrast(2.4) saturate(1.5)';bg.drawImage(cv,0,0,bl.width,bl.height);bg.filter='none'}
let pigPulse=0,lastLand=-1;
function updateExtras(t){
 let land=0;
 coins.forEach((c,i)=>{const t0=COIN_T[i],u=(t-t0)/0.5;
  if(u>=0&&u<1){c.visible=true;c.position.set(0.5+(0.0)*u,lerp(1.35,1.07,u*u),0.3-0.03*0);c.position.x=0.5-Math.sin(0.45)*0.0;c.rotation.set(Math.PI/2*0+u*9,0,u*3);c.position.set(PG.position.x+0.0,lerp(1.4,1.075,u*u),PG.position.z+0.0)}
  else c.visible=false;
  const d=t-(t0+0.5);if(d>=0&&d<0.35)land=Math.max(land,Math.exp(-d*9))});
 tower.forEach((c,i)=>{c.visible=t>=COIN_T[i]+0.5});
 pigPulse=land;PG.scale.set(1+land*0.07,1-land*0.09,1+land*0.07);PG.rotation.y=-0.45+Math.sin(t*1.2)*0.03;PG.position.y=0.815+land*0.012;
 goldL.intensity=land*3.2+((t>8.7&&t<9.6)?(Math.sin((t-8.7)/0.9*Math.PI))*2.5:0)+((t>16.4&&t<17.4)?(Math.sin((t-16.4)/1.0*Math.PI))*2.5:0);
 const a=dust.geometry.attributes.position.array;dustB.forEach((b,i)=>{a[i*3]=b[0]+Math.sin(t*b[4]+b[3])*0.18;a[i*3+1]=b[1]+Math.sin(t*b[4]*0.8+b[3]*2)*0.12+((t*0.03*b[4])%0.4);a[i*3+2]=b[2]+Math.cos(t*b[4]+b[3])*0.15});dust.geometry.attributes.position.needsUpdate=true;
 if(!neonOK&&document.fonts.check('800 150px P')){neonOK=true;const c=neonTex.image.getContext('2d');neonDraw(c,512,200);neonTex.needsUpdate=true}
 neon.material.opacity=0.92+Math.sin(t*23)*0.03*(Math.sin(t*0.9)>0.97?4:0.4);
 rim2.intensity=5+Math.sin(t*2)*0.6;
}
"""
S=S.replace("// ---------- subtitles",extra+"// ---------- subtitles")
S=S.replace(" R.render(sc,cam);\n"," updateExtras(t);R.render(sc,cam);bloomPass();\n")
open('scene.js','w').write(S)
