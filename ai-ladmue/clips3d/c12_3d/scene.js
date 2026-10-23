const THREE=window.THREE;
const cv=document.getElementById('c');
const R=new THREE.WebGLRenderer({canvas:cv,antialias:true,preserveDrawingBuffer:true});
R.setPixelRatio(1);R.shadowMap.enabled=true;R.shadowMap.type=THREE.PCFSoftShadowMap;
R.toneMapping=THREE.ACESFilmicToneMapping;R.toneMappingExposure=1.15;R.outputColorSpace=THREE.SRGBColorSpace;
const sc=new THREE.Scene();sc.background=new THREE.Color(0x2a1a10);sc.fog=new THREE.Fog(0x2a1a10,8,16);
const cam=new THREE.PerspectiveCamera(45,9/16,0.1,50);
const M=(c,o={})=>new THREE.MeshStandardMaterial(Object.assign({color:c,flatShading:true,roughness:0.75,metalness:0.02},o));
const add=(g,m,x=0,y=0,z=0,p=sc,sh=true)=>{const o=new THREE.Mesh(g,m);o.position.set(x,y,z);o.castShadow=sh;o.receiveShadow=true;p.add(o);return o};
const box=(w,h,d,m,x,y,z,p)=>add(new THREE.BoxGeometry(w,h,d),m,x,y,z,p);
// ---- room
const floorTex=(()=>{const c=document.createElement('canvas');c.width=512;c.height=512;const g=c.getContext('2d');for(let i=0;i<8;i++){g.fillStyle=i%2?'#8a5a36':'#7d4f2e';g.fillRect(0,i*64,512,64);g.fillStyle='#00000030';g.fillRect(0,i*64,512,3)}const t=new THREE.CanvasTexture(c);t.colorSpace=THREE.SRGBColorSpace;t.wrapS=t.wrapT=THREE.RepeatWrapping;t.repeat.set(2,2);return t})();
add(new THREE.PlaneGeometry(10,12),new THREE.MeshStandardMaterial({map:floorTex,roughness:0.8}),0,0,1.5).rotation.x=-Math.PI/2;
box(10,3.4,0.15,M(0x7a4a2c),0,1.7,-2.6);
box(0.15,3.4,10,M(0x6b4128),-3.2,1.7,1.5);box(0.15,3.4,10,M(0x6b4128),3.2,1.7,1.5);
box(10,0.12,0.2,M(0x3b2314),0,0.06,-2.5);
// window (night)
const winM=new THREE.MeshStandardMaterial({color:0x1d2b54,emissive:0x2a4a9a,emissiveIntensity:0.9});
box(1.05,1.3,0.1,M(0x2a1a10),1.15,1.85,-2.5);add(new THREE.PlaneGeometry(0.9,1.15),winM,1.15,1.85,-2.44,sc,false);
box(0.05,1.15,0.04,M(0x2a1a10),1.15,1.85,-2.42);box(0.9,0.05,0.04,M(0x2a1a10),1.15,1.85,-2.42);
add(new THREE.PlaneGeometry(0.9,0.35),new THREE.MeshBasicMaterial({color:0xe58a4a,transparent:true,opacity:0.5}),1.15,1.4,-2.43,sc,false);
// acoustic foam panels
for(let i=0;i<4;i++)for(let j=0;j<2;j++){const m=M(((i+j)%2)?0x2f2f40:0x3a3a52);box(0.38,0.38,0.12,m,-0.45+i*0.42-0.2,2.35+j*0.42,-2.5)}
// shelf + books
box(1.1,0.05,0.28,M(0x3b2314),-1.15,1.75,-2.35);
[[0x3e7cb1,.26],[0xd96c4a,.2],[0xe8b04a,.3],[0x6baa75,.22],[0x8e5ba8,.28],[0xd94f70,.2],[0x4a90a4,.25]].forEach((b,i)=>box(0.07,b[1],0.2,M(b[0]),-1.55+i*0.1,1.775+b[1]/2,-2.35));
// plant
box(0.0,0,0,M(0),0,0,0);
{const g=new THREE.Group();g.position.set(-2.2,0,-1.8);sc.add(g);add(new THREE.CylinderGeometry(0.2,0.15,0.35,8),M(0x6e4325),0,0.18,0,g);
 for(let i=0;i<7;i++){const l=add(new THREE.ConeGeometry(0.09,0.7,5),M(i%2?0x4c9a5a:0x5cb06a),0,0.65,0,g);l.rotation.z=(Math.random()-0.5)*0.9+((i%2)?0.35:-0.35);l.rotation.y=i*0.9;l.position.x=Math.sin(i)*0.08}}
// string lights
const bulbs=[];for(let i=0;i<14;i++){const x=-2.6+i*0.4,y=3.0-Math.sin(i/13*Math.PI)*0.28;const b=add(new THREE.IcosahedronGeometry(0.035,0),new THREE.MeshBasicMaterial({color:0xffe3a0}),x,y,-2.45,sc,false);bulbs.push(b)}
// rug
{const r=add(new THREE.CylinderGeometry(1.8,1.8,0.02,24),M(0x3b5a6b,{flatShading:true}),0,0.015,0.2);r.castShadow=false}
// lamp (floor)
{const g=new THREE.Group();g.position.set(-2.55,0,-0.6);sc.add(g);add(new THREE.CylinderGeometry(0.02,0.02,1.4,6),M(0x2a1a10),0,0.7,0,g);add(new THREE.CylinderGeometry(0.12,0.24,0.3,8,1,true),new THREE.MeshStandardMaterial({color:0xe8b04a,emissive:0xffb347,emissiveIntensity:0.8,side:THREE.DoubleSide,flatShading:true}),0,1.5,0,g,false)}
// desk
const wood=M(0xa8693a);
box(2.7,0.07,0.95,wood,0.0,0.78,0.15);[[-1.25,-0.25],[1.25,-0.25],[-1.25,0.5],[1.25,0.5]].forEach(p=>box(0.07,0.75,0.07,M(0x6b3f20),p[0],0.375,p[1]));
// laptop
const lap=new THREE.Group();lap.position.set(-0.6,0.815,0.15);sc.add(lap);box(0.5,0.02,0.34,M(0xb8c1c9,{metalness:0.4}),0,0,0,lap);
{const s=box(0.5,0.32,0.015,M(0xb8c1c9,{metalness:0.4}),0,0.17,-0.17,lap);s.rotation.x=-0.22;const sm=add(new THREE.PlaneGeometry(0.44,0.27),new THREE.MeshBasicMaterial({color:0x2a4a7a}),0,0,0.01,s,false)}
// mic
{const g=new THREE.Group();g.position.set(0.15,0.815,0.25);sc.add(g);add(new THREE.CylinderGeometry(0.1,0.12,0.02,10),M(0x222233),0,0,0,g);add(new THREE.CylinderGeometry(0.012,0.012,0.45,6),M(0x222233),0,0.23,0,g);add(new THREE.CapsuleGeometry(0.04,0.1,3,8),M(0x666677,{metalness:0.5}),0,0.5,0,g)}
// chair
box(0.5,0.06,0.5,M(0x2d2d3a),-0.6,0.46,-0.45);box(0.5,0.55,0.06,M(0x2d2d3a),-0.6,0.78,-0.7);add(new THREE.CylinderGeometry(0.03,0.03,0.4,6),M(0x111118),-0.6,0.23,-0.45);
// ---- human
const H=new THREE.Group();H.position.set(-0.6,0,-0.45);H.rotation.y=0.38;sc.add(H);
const skin=M(0xf2c9a0),hood=M(0xd96c4a),jeans=M(0x2f3f6a),teal=M(0x2e8b7a);
const torso=add(new THREE.CylinderGeometry(0.2,0.17,0.55,8),hood,0,0.78,0,H);torso.scale.z=0.75;
box(0.1,0.07,0.1,skin,0,1.12,0,H);
add(new THREE.CylinderGeometry(0.06,0.06,0.06,6),skin,0,1.08,0,H);
const head=new THREE.Group();head.position.set(0,1.28,0);H.add(head);
const hd=add(new THREE.IcosahedronGeometry(0.17,1),skin,0,0,0,head);hd.scale.set(1,1.06,1);
const bean=add(new THREE.SphereGeometry(0.185,10,7,0,Math.PI*2,0,Math.PI*0.5),teal,0,0.05,0,head);bean.rotation.x=-0.12;
add(new THREE.TorusGeometry(0.18,0.025,5,12),M(0x256f62),0,0.045,0,head).rotation.x=Math.PI/2+0.0;
add(new THREE.IcosahedronGeometry(0.04,0),teal,0,0.245,-0.02,head);
const eyeM=new THREE.MeshBasicMaterial({color:0x2b1b10});
const eyeL=add(new THREE.SphereGeometry(0.018,8,6),eyeM,-0.065,0.01,0.158,head,false),eyeR=add(new THREE.SphereGeometry(0.018,8,6),eyeM,0.065,0.01,0.158,head,false);
[-1,1].forEach(s=>{const g=add(new THREE.TorusGeometry(0.048,0.007,5,12),M(0x3b2a20),s*0.065,0.012,0.165,head);g.castShadow=false});
box(0.04,0.006,0.006,M(0x3b2a20),0,0.015,0.168,head);
const browL=box(0.06,0.012,0.01,M(0x2b1b10),-0.065,0.065,0.16,head),browR=box(0.06,0.012,0.01,M(0x2b1b10),0.065,0.065,0.16,head);
const mouth=add(new THREE.SphereGeometry(0.028,8,6),new THREE.MeshBasicMaterial({color:0x7a2e2e}),0,-0.07,0.158,head,false);mouth.scale.set(1,0.3,0.4);
// arms
function limb(a,b,r,m,mesh){const d=new THREE.Vector3().subVectors(b,a),len=d.length();mesh.position.copy(a).addScaledVector(d,0.5);mesh.scale.set(1,len,1);mesh.quaternion.setFromUnitVectors(new THREE.Vector3(0,1,0),d.clone().normalize())}
const armGeo=new THREE.CylinderGeometry(0.055,0.05,1,6);
const armL=add(armGeo,hood,0,0,0,sc),armR=add(armGeo,hood,0,0,0,sc);
const handL=add(new THREE.IcosahedronGeometry(0.055,1),skin,0,0,0,sc),handR=add(new THREE.IcosahedronGeometry(0.055,1),skin,0,0,0,sc);
// legs
box(0.17,0.17,0.5,jeans,-0.7,0.56,-0.15);box(0.17,0.17,0.5,jeans,-0.45,0.56,-0.15);box(0.14,0.5,0.14,jeans,-0.7,0.28,0.1);box(0.14,0.5,0.14,jeans,-0.45,0.28,0.1);
// ---- robot
const RB_=new THREE.Group();RB_.position.set(0.7,1.38,-0.5);sc.add(RB_);
const rbody=add(new THREE.IcosahedronGeometry(0.3,2),new THREE.MeshStandardMaterial({color:0xff8a3d,roughness:0.35,metalness:0.1,flatShading:true}),0,0,0,RB_);
const faceCv=document.createElement('canvas');faceCv.width=512;faceCv.height=300;const fg=faceCv.getContext('2d');const faceTex=new THREE.CanvasTexture(faceCv);faceTex.colorSpace=THREE.SRGBColorSpace;
const face=add(new THREE.SphereGeometry(0.303,24,14,Math.PI/2-0.85,1.7,Math.PI/2-0.5,1.0),new THREE.MeshBasicMaterial({map:faceTex}),0,0,0,RB_,false);
add(new THREE.CylinderGeometry(0.012,0.012,0.12,6),M(0xb85f1e),0,0.34,0,RB_);
const bulb=add(new THREE.SphereGeometry(0.035,8,6),new THREE.MeshBasicMaterial({color:0xffd23f}),0,0.42,0,RB_,false);
[-1,1].forEach(s=>{const e=add(new THREE.CylinderGeometry(0.07,0.07,0.06,10),M(0xb85f1e),s*0.31,0,0,RB_);e.rotation.z=Math.PI/2});
const rShadow=add(new THREE.CircleGeometry(0.28,16),new THREE.MeshBasicMaterial({color:0x000000,transparent:true,opacity:0.25}),0.7,0.8185,-0.5,sc,false);rShadow.rotation.x=-Math.PI/2;rShadow.visible=false;
// ---- lights
sc.add(new THREE.HemisphereLight(0xffd9b0,0x3a2414,0.9));
const key=new THREE.DirectionalLight(0xffc98a,2.2);key.position.set(2.5,4,4);key.castShadow=true;key.shadow.mapSize.set(1024,1024);key.shadow.camera.left=-3;key.shadow.camera.right=3;key.shadow.camera.top=3.5;key.shadow.camera.bottom=-1;key.shadow.camera.near=1;key.shadow.camera.far=12;key.shadow.bias=-0.0006;sc.add(key);
const rim=new THREE.PointLight(0x6fa0ff,6,6);rim.position.set(1.2,1.9,-1.8);sc.add(rim);
const lampL=new THREE.PointLight(0xffb347,5,5);lampL.position.set(-2.4,1.5,-0.5);sc.add(lampL);
const fillR=new THREE.PointLight(0x6ff0ff,0.0,3);fillR.position.set(0.7,1.4,0.2);sc.add(fillR);
// ---- camera keys (same logic as 2.5D version)
const SHOTS={wide:{pos:[0,1.5,4.3],tg:[0,1.2,-0.5],f:44},H:{pos:[-0.45,1.38,1.55],tg:[-0.62,1.3,-0.5],f:40},R:{pos:[0.72,1.42,1.6],tg:[0.7,1.38,-0.5],f:40}};
const keys=[{t:0,...SHOTS.H,sh:'H'}];
LINES.forEach(l=>keys.push({t:Math.max(0,l.a-0.1),...SHOTS[l.s],sh:l.s}));
keys.push({t:DUR-4.5,...SHOTS.wide,sh:'wide'});keys.sort((a,b)=>a.t-b.t);
const sm=x=>x*x*(3-2*x),cl=x=>Math.min(1,Math.max(0,x));
const lerp=(a,b,t)=>a+(b-a)*t;
function camAt(t){let i=0;while(i+1<keys.length&&keys[i+1].t<=t)i++;const k=keys[i],p=i>0?keys[i-1]:keys[0];const b=sm(cl((t-k.t)/0.55));
 const P=[0,1,2].map(j=>lerp(p.pos[j],k.pos[j],b)),Tg=[0,1,2].map(j=>lerp(p.tg[j],k.tg[j],b));return{P,Tg,f:lerp(p.f,k.f,b)}}
const wseg=new Intl.Segmenter('th',{granularity:'word'}),gseg=new Intl.Segmenter('th',{granularity:'grapheme'});
LINES.forEach(l=>{const ws=[...wseg.segment(l.t)].map(s=>s.segment);const lens=ws.map(w=>w.trim().length?[...gseg.segment(w)].length+0.5:0);const tot=lens.reduce((a,b)=>a+b,0);let acc=0;l.w=ws.map((w,i)=>{const s=l.a+(l.b-l.a)*acc/tot;acc+=lens[i];return{w,s,e:l.a+(l.b-l.a)*acc/tot,sp:!w.trim().length}})});
const sub=document.getElementById('sub');
const base=seek;
function drawFace(t,speaking){fg.fillStyle='#1E1B2E';fg.fillRect(0,0,512,300);
 const blink=(t%3.2)>3.08?0.15:1;fg.fillStyle='#6FF0FF';
 [[150,100],[362,100]].forEach(e=>{const h=70*blink;fg.beginPath();fg.roundRect?fg.roundRect(e[0]-22,e[1]-h/2,44,h,22):fg.rect(e[0]-22,e[1]-h/2,44,h);fg.fill()});
 for(let i=0;i<11;i++){const h=speaking?10+Math.abs(Math.sin(t*14+i*0.9))*70*(0.5+0.5*Math.sin(i*0.7+1)):8;fg.fillRect(120+i*26,225-h/2,14,h)}
 faceTex.needsUpdate=true}
window.seek=function(t){
 base(t);
 const act=LINES.find(l=>t>=l.a&&t<=l.b),spk=act?act.s:null;
 const c=camAt(t);const dx=Math.sin(t*0.9)*0.012,dy=Math.cos(t*0.7)*0.008;
 cam.position.set(c.P[0]+dx,c.P[1]+dy,c.P[2]);cam.fov=c.f;cam.updateProjectionMatrix();cam.lookAt(c.Tg[0],c.Tg[1],c.Tg[2]);
 // robot
 const bob=Math.sin(t*2.2)*0.03;RB_.position.y=1.38+bob;RB_.rotation.y=-0.35+Math.sin(t*0.8)*0.08+(spk==='R'?Math.sin(t*3)*0.05:0);rShadow.visible=false;
 bulb.material.color.set(spk==='R'?0xffee88:0xffb300);fillR.intensity=spk==='R'?1.5:0.2;
 drawFace(t,spk==='R');
 // human
 const worried=t<4,happy=t>25.66;
 head.rotation.y=(spk==='R'?0.5:spk==='H'?0.12:0.25)+Math.sin(t*1.3)*0.04;head.rotation.x=(spk==='H'?Math.sin(t*6)*0.04:0)+(worried?-0.04:0);
 head.position.y=1.28+(spk==='H'?Math.abs(Math.sin(t*8))*0.006:0);
 mouth.scale.set(1,spk==='H'?0.3+Math.abs(Math.sin(t*20))*1.1:0.3,0.4);
 const blink=(t%3.6)>3.48?0.1:1;eyeL.scale.y=blink;eyeR.scale.y=blink;
 browL.rotation.z=worried?-0.35:happy?0.1:0;browR.rotation.z=worried?0.35:happy?-0.1:0;
 // arms
 H.updateMatrixWorld(true);
 const sh=(s)=>new THREE.Vector3(s*0.22,1.0,0.0).applyMatrix4(H.matrixWorld);
 const gest=spk==='H'?Math.max(0,Math.sin(t*5))*0.2:0;
 const hL=new THREE.Vector3(-0.78,0.9+gest*0.5,0.22),hR=new THREE.Vector3(-0.42,0.9+(spk==='H'?0.25+gest:0),0.2+(spk==='H'?0.0:0));
 if(worried){hL.set(-0.8,1.25,0.15);hR.set(-0.4,1.25,0.15)}
 limb(sh(-1),hL,0.05,0,armL);limb(sh(1),hR,0.05,0,armR);handL.position.copy(hL);handR.position.copy(hR);
 R.render(sc,cam);
 // subtitles
 if(act){const col=act.s==='H'?'#4D8BFF':'#FF8A3D';let h='<span class="chip" style="background:'+col+'">'+(act.s==='H'?'นัท':'หุ่น AI')+'</span><span class="l">';
  act.w.forEach(x=>{const on=t>=x.s&&t<x.e;h+=x.sp?' ':'<span class="w'+(on?' on':'')+'">'+x.w+'</span>'});h+='</span>';if(sub._h!==h){sub.innerHTML=h;sub._h=h}sub.style.opacity=1}else sub.style.opacity=0;
};
seek(0);
