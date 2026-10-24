const THREE=window.THREE;
const cv=document.getElementById('c');
const R=new THREE.WebGLRenderer({canvas:cv,antialias:true,preserveDrawingBuffer:true});
R.setPixelRatio(1);R.shadowMap.enabled=true;R.shadowMap.type=THREE.PCFSoftShadowMap;
R.toneMapping=THREE.ACESFilmicToneMapping;R.toneMappingExposure=1.2;R.outputColorSpace=THREE.SRGBColorSpace;
const sc=new THREE.Scene();sc.background=new THREE.Color(0x2a1a10);sc.fog=new THREE.Fog(0x2a1a10,8,16);
const cam=new THREE.PerspectiveCamera(45,9/16,0.1,50);
const M=(c,o={})=>new THREE.MeshStandardMaterial(Object.assign({color:c,flatShading:true,roughness:0.75,metalness:0.02},o));
const S=(c,o={})=>M(c,Object.assign({flatShading:false,roughness:0.6},o));
const add=(g,m,x=0,y=0,z=0,p=sc,sh=true)=>{const o=new THREE.Mesh(g,m);o.position.set(x,y,z);o.castShadow=sh;o.receiveShadow=true;p.add(o);return o};
const box=(w,h,d,m,x,y,z,p)=>add(new THREE.BoxGeometry(w,h,d),m,x,y,z,p);
const cl=x=>Math.min(1,Math.max(0,x)),sm=x=>x*x*(3-2*x),lerp=(a,b,t)=>a+(b-a)*t;
// ---------- room
const floorTex=(()=>{const c=document.createElement('canvas');c.width=512;c.height=512;const g=c.getContext('2d');for(let i=0;i<8;i++){g.fillStyle=i%2?'#8a5a36':'#7d4f2e';g.fillRect(0,i*64,512,64);g.fillStyle='#00000030';g.fillRect(0,i*64,512,3)}const t=new THREE.CanvasTexture(c);t.colorSpace=THREE.SRGBColorSpace;t.wrapS=t.wrapT=THREE.RepeatWrapping;t.repeat.set(2,2);return t})();
add(new THREE.PlaneGeometry(10,12),new THREE.MeshStandardMaterial({map:floorTex,roughness:0.8}),0,0,1.5).rotation.x=-Math.PI/2;
box(10,3.4,0.15,M(0x7a4a2c),0,1.7,-2.6);box(0.15,3.4,10,M(0x6b4128),-3.2,1.7,1.5);box(0.15,3.4,10,M(0x6b4128),3.2,1.7,1.5);box(10,0.12,0.2,M(0x3b2314),0,0.06,-2.5);
const winM=new THREE.MeshStandardMaterial({color:0x1d2b54,emissive:0x2a4a9a,emissiveIntensity:0.9});
box(1.05,1.3,0.1,M(0x2a1a10),1.15,1.85,-2.5);add(new THREE.PlaneGeometry(0.9,1.15),winM,1.15,1.85,-2.44,sc,false);
box(0.05,1.15,0.04,M(0x2a1a10),1.15,1.85,-2.42);box(0.9,0.05,0.04,M(0x2a1a10),1.15,1.85,-2.42);
add(new THREE.PlaneGeometry(0.9,0.35),new THREE.MeshBasicMaterial({color:0xe58a4a,transparent:true,opacity:0.5}),1.15,1.4,-2.43,sc,false);
for(let i=0;i<4;i++)for(let j=0;j<2;j++){box(0.38,0.38,0.12,M(((i+j)%2)?0x2f2f40:0x3a3a52),-0.65+i*0.42,2.35+j*0.42,-2.5)}
box(1.1,0.05,0.28,M(0x3b2314),-1.15,1.75,-2.35);
[[0x3e7cb1,.26],[0xd96c4a,.2],[0xe8b04a,.3],[0x6baa75,.22],[0x8e5ba8,.28],[0xd94f70,.2],[0x4a90a4,.25]].forEach((b,i)=>box(0.07,b[1],0.2,M(b[0]),-1.55+i*0.1,1.775+b[1]/2,-2.35));
{const g=new THREE.Group();g.position.set(-2.2,0,-1.8);sc.add(g);add(new THREE.CylinderGeometry(0.2,0.15,0.35,8),M(0x6e4325),0,0.18,0,g);
 for(let i=0;i<7;i++){const l=add(new THREE.ConeGeometry(0.09,0.7,5),M(i%2?0x4c9a5a:0x5cb06a),Math.sin(i)*0.08,0.65,0,g);l.rotation.z=((i*37)%10/10-0.5)*0.9+((i%2)?0.35:-0.35);l.rotation.y=i*0.9}}
for(let i=0;i<14;i++){const x=-2.6+i*0.4,y=3.0-Math.sin(i/13*Math.PI)*0.28;add(new THREE.IcosahedronGeometry(0.035,0),new THREE.MeshBasicMaterial({color:0xffe3a0}),x,y,-2.45,sc,false)}
{const r=add(new THREE.CylinderGeometry(1.8,1.8,0.02,24),M(0x3b5a6b),0,0.015,0.2);r.castShadow=false}
{const g=new THREE.Group();g.position.set(-2.55,0,-0.6);sc.add(g);add(new THREE.CylinderGeometry(0.02,0.02,1.4,6),M(0x2a1a10),0,0.7,0,g);add(new THREE.CylinderGeometry(0.12,0.24,0.3,8,1,true),new THREE.MeshStandardMaterial({color:0xe8b04a,emissive:0xffb347,emissiveIntensity:0.8,side:THREE.DoubleSide,flatShading:true}),0,1.5,0,g,false)}
// ---------- desk, laptop (screen faces the person), mic (left side, out of the way)
box(2.7,0.07,0.95,M(0xa8693a),0.0,0.78,0.15);[[-1.25,-0.25],[1.25,-0.25],[-1.25,0.5],[1.25,0.5]].forEach(p=>box(0.07,0.75,0.07,M(0x6b3f20),p[0],0.375,p[1]));
const lap=new THREE.Group();lap.position.set(-0.6,0.815,0.2);lap.rotation.y=Math.PI;sc.add(lap);
const alu=M(0xc9d0d6,{metalness:0.5,roughness:0.4});
box(0.5,0.02,0.34,alu,0,0,0,lap);
{const lid=new THREE.Group();lid.position.set(0,0.01,-0.17);lid.rotation.x=-0.28;lap.add(lid);
 box(0.5,0.32,0.014,alu,0,0.16,0,lid);add(new THREE.PlaneGeometry(0.44,0.27),new THREE.MeshBasicMaterial({color:0x5a8fe0}),0,0.16,0.009,lid,false);
 const lg=add(new THREE.OctahedronGeometry(0.03,0),new THREE.MeshBasicMaterial({color:0xffffff}),0,0.16,-0.012,lid,false);lg.scale.set(1,1.3,0.2)}
{const g=new THREE.Group();g.position.set(-1.15,0.815,0.3);sc.add(g);add(new THREE.CylinderGeometry(0.1,0.12,0.02,10),M(0x222233),0,0,0,g);add(new THREE.CylinderGeometry(0.012,0.012,0.45,6),M(0x222233),0,0.23,0,g);add(new THREE.CapsuleGeometry(0.04,0.1,3,8),M(0x666677,{metalness:0.5}),0,0.5,0,g)}
box(0.5,0.06,0.5,M(0x2d2d3a),-0.6,0.46,-0.45);box(0.5,0.55,0.06,M(0x2d2d3a),-0.6,0.78,-0.7);add(new THREE.CylinderGeometry(0.03,0.03,0.4,6),M(0x111118),-0.6,0.23,-0.45);
// ---------- human (rebuilt)
const H=new THREE.Group();H.position.set(-0.6,0,-0.45);H.rotation.y=0.12;sc.add(H);
const skin=S(0xf0c39a),hoodM=S(0xd96c4a),jeans=S(0x2f3f6a),hairM=S(0x2b1b14,{roughness:0.9}),tealM=S(0x2e8b7a,{roughness:0.9}),tealD=S(0x226b5f,{roughness:0.9});
const torso=(()=>{const Lp=[[-0.165,0.56],[-0.18,0.66],[-0.188,0.78],[-0.2,0.9],[-0.222,0.975],[-0.2,1.04],[-0.12,1.072],[-0.06,1.09]];
 const pts=Lp.map(p=>new THREE.Vector3(p[0],p[1],0)).concat(Lp.slice().reverse().map(p=>new THREE.Vector3(-p[0],p[1],0)));
 const curve=new THREE.CatmullRomCurve3(pts,true,'centripetal');const sh=new THREE.Shape(curve.getPoints(90).map(v=>new THREE.Vector2(v.x,v.y)));
 const g=new THREE.ExtrudeGeometry(sh,{depth:0.1,bevelEnabled:true,bevelSize:0.05,bevelThickness:0.06,bevelSegments:6,curveSegments:1});
 g.translate(0,-0.84,-0.05);g.computeVertexNormals();const m=new THREE.Mesh(g,hoodM);m.position.set(0,0.84,0);m.castShadow=true;m.receiveShadow=true;H.add(m);return m})();

const hoodBack=add(new THREE.TorusGeometry(0.12,0.055,8,16,Math.PI*1.2),hoodM,0,1.07,-0.07,H);hoodBack.rotation.set(Math.PI/2-0.5,0,Math.PI*0.9);
add(new THREE.CylinderGeometry(0.052,0.06,0.12,10),skin,0,1.13,0.01,H);
const chest=box(0.05,0.2,0.01,S(0xf0e6d8),0,0.9,0.145,H);chest.scale.set(0.6,1,1); // hoodie pocket line
const head=new THREE.Group();head.position.set(0,1.31,0.02);H.add(head);
const skull=add(new THREE.SphereGeometry(0.15,28,20),skin,0,0,0,head);skull.scale.set(0.93,1.06,0.98);
const jaw=add(new THREE.SphereGeometry(0.12,20,14),skin,0,-0.055,0.025,head);jaw.scale.set(0.9,0.8,0.9);
add(new THREE.SphereGeometry(0.024,10,8),S(0xe8b48c),0,-0.018,0.148,head).scale.set(1,1.1,1.1);
[-1,1].forEach(s=>{const e=add(new THREE.SphereGeometry(0.032,10,8),S(0xe8b48c),s*0.142,0.0,0,head);e.scale.set(0.5,1,0.8)});
// hair + beanie
add(new THREE.SphereGeometry(0.158,24,16,0,Math.PI*2,0,Math.PI*0.56),hairM,0,0.012,-0.012,head).rotation.x=-0.28;
[-1,1].forEach(s=>{const h=add(new THREE.SphereGeometry(0.05,10,8),hairM,s*0.135,0.03,0.0,head);h.scale.set(0.7,1.2,1)});
const bang=add(new THREE.SphereGeometry(0.1,14,10,0,Math.PI,0,Math.PI*0.5),hairM,0,0.085,0.075,head);bang.rotation.x=1.1;bang.scale.set(1.05,0.6,0.7);
const bean=add(new THREE.SphereGeometry(0.168,24,16,0,Math.PI*2,0,Math.PI*0.46),tealM,0,0.07,-0.015,head);bean.rotation.x=-0.18;bean.scale.set(1,1.05,1);
add(new THREE.TorusGeometry(0.162,0.024,8,24),tealD,0,0.07,-0.012,head).rotation.x=Math.PI/2-0.18;
add(new THREE.SphereGeometry(0.04,10,8),tealM,0,0.245,-0.04,head);
// eyes
const eyeG=[];const sclera=new THREE.MeshStandardMaterial({color:0xfdfdfd,roughness:0.3}),pup=new THREE.MeshBasicMaterial({color:0x1b1210}),shine=new THREE.MeshBasicMaterial({color:0xffffff});
const pupils=[];
[-1,1].forEach(s=>{const g=new THREE.Group();g.position.set(s*0.058,0.012,0.128);head.add(g);eyeG.push(g);
 const sc2=add(new THREE.SphereGeometry(0.03,14,10),sclera,0,0,0,g,false);sc2.scale.set(1,1.12,0.55);
 const p=add(new THREE.SphereGeometry(0.019,12,9),pup,0,0,0.012,g,false);p.scale.set(1,1,0.5);pupils.push(p);
 add(new THREE.SphereGeometry(0.006,6,5),shine,0.006,0.007,0.022,g,false);
 const rim=add(new THREE.TorusGeometry(0.043,0.0055,6,18),S(0x2b1b14),s*0.058,0.012,0.138,head);rim.castShadow=false});
box(0.035,0.006,0.006,S(0x2b1b14),0,0.02,0.145,head).castShadow=false;
const brows=[-1,1].map(s=>{const b=box(0.056,0.013,0.012,hairM,s*0.058,0.068,0.137,head);b.castShadow=false;return b});
// mouth
const mouthG=new THREE.Group();mouthG.position.set(0,-0.073,0.135);head.add(mouthG);
const mIn=add(new THREE.SphereGeometry(0.028,12,8),new THREE.MeshBasicMaterial({color:0x5a1f26}),0,0,0,mouthG,false);mIn.scale.set(1,0.15,0.45);
const lipU=add(new THREE.CapsuleGeometry(0.006,0.036,3,6),S(0xc9626e),0,0.0,0.012,mouthG,false);lipU.rotation.z=Math.PI/2;
const lipL=add(new THREE.CapsuleGeometry(0.007,0.034,3,6),S(0xc9626e),0,0,0.012,mouthG,false);lipL.rotation.z=Math.PI/2;
// legs
box(0.17,0.17,0.5,jeans,-0.7,0.56,-0.15);box(0.17,0.17,0.5,jeans,-0.45,0.56,-0.15);box(0.14,0.5,0.14,jeans,-0.7,0.28,0.1);box(0.14,0.5,0.14,jeans,-0.45,0.28,0.1);
[-0.7,-0.45].forEach(x=>box(0.15,0.07,0.24,S(0xf3f3f3),x,0.035,0.17));
// arms: one smooth tapered tube through shoulder-elbow-wrist
const L1=0.27,L2=0.26,TN=18,TM=12;
function makeTube(){const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.BufferAttribute(new Float32Array((TN+1)*TM*3),3));const idx=[];for(let i=0;i<TN;i++)for(let j=0;j<TM;j++){const a=i*TM+j,b=i*TM+(j+1)%TM,c=(i+1)*TM+j,d=(i+1)*TM+(j+1)%TM;idx.push(a,c,b,b,c,d)}g.setIndex(idx);return g}
const vp=new THREE.Vector3(),vt=new THREE.Vector3(),vn=new THREE.Vector3(),vb=new THREE.Vector3(),vref=new THREE.Vector3(1,0,0);
function updateTube(g,curve,rs){const pos=g.attributes.position.array;curve.needsUpdate=true;
 for(let i=0;i<=TN;i++){const u=i/TN;curve.getPointAt(u,vp);curve.getTangentAt(u,vt);vn.crossVectors(vref,vt);if(vn.lengthSq()<1e-4)vn.set(0,0,1);vn.normalize();vb.crossVectors(vt,vn).normalize();
  const rad=u<0.5?lerp(rs[0],rs[1],sm(u*2)):lerp(rs[1],rs[2],sm((u-0.5)*2));
  for(let j=0;j<TM;j++){const an=j/TM*Math.PI*2,cx=Math.cos(an)*rad,sy=Math.sin(an)*rad,k=(i*TM+j)*3;pos[k]=vp.x+vn.x*cx+vb.x*sy;pos[k+1]=vp.y+vn.y*cx+vb.y*sy;pos[k+2]=vp.z+vn.z*cx+vb.z*sy}}
 g.attributes.position.needsUpdate=true;g.computeVertexNormals();g.computeBoundingSphere()}
const sleeveM=S(0xd96c4a,{side:THREE.DoubleSide}),cuffM=S(0xb85a3c);
function makeHand(s){
 const g=new THREE.Group();sc.add(g);
 const sh=new THREE.Shape();sh.moveTo(-0.024,0);sh.lineTo(0.024,0);sh.quadraticCurveTo(0.036,0.03,0.038,0.068);sh.lineTo(-0.038,0.068);sh.quadraticCurveTo(-0.036,0.03,-0.024,0);
 const pg=new THREE.ExtrudeGeometry(sh,{depth:0.016,bevelEnabled:true,bevelSize:0.005,bevelThickness:0.005,bevelSegments:3});pg.rotateX(Math.PI/2);pg.translate(0,0.012,0);
 const palm=add(pg,skin,0,0,0,g);
 const mk=(r0,r1,len)=>{const geo=new THREE.CylinderGeometry(r1,r0,len,8);geo.rotateX(Math.PI/2);geo.translate(0,0,len/2);return geo};
 const fingers=[];const L=[[0.03,0.024],[0.034,0.027],[0.031,0.025],[0.025,0.02]],X=[-0.0285,-0.0095,0.0095,0.0285],R=[0.0082,0.0085,0.008,0.0072];
 X.forEach((x,i)=>{const prox=new THREE.Group();prox.position.set(x,0,0.072);prox.rotation.y=(i-1.5)*0.045;g.add(prox);
  add(mk(R[i],R[i]*0.88,L[i][0]),skin,0,0,0,prox);add(new THREE.SphereGeometry(R[i]*0.88,8,6),skin,0,0,L[i][0],prox);
  const dist=new THREE.Group();dist.position.set(0,0,L[i][0]);prox.add(dist);add(mk(R[i]*0.88,R[i]*0.74,L[i][1]),skin,0,0,0,dist);add(new THREE.SphereGeometry(R[i]*0.74,8,6),skin,0,0,L[i][1],dist);
  prox.userData.dist=dist;fingers.push(prox)});
 const th=new THREE.Group();th.position.set(-s*0.036,-0.002,0.02);th.rotation.y=-s*0.75;g.add(th);
 add(mk(0.011,0.0095,0.026),skin,0,0,0,th);add(new THREE.SphereGeometry(0.0095,8,6),skin,0,0,0.026,th);
 const td=new THREE.Group();td.position.set(0,0,0.026);th.add(td);add(mk(0.0095,0.0082,0.022),skin,0,0,0,td);add(new THREE.SphereGeometry(0.0082,8,6),skin,0,0,0.022,td);th.userData.dist=td;
 g.userData={fingers,thumb:th};return g}
const arms=[-1,1].map(s=>{const geo=makeTube();const mesh=add(geo,sleeveM,0,0,0,sc);mesh.frustumCulled=false;
 return{s,geo,mesh,curve:new THREE.CatmullRomCurve3([new THREE.Vector3(),new THREE.Vector3(0,0,0.1),new THREE.Vector3(0,0,0.2)],false,'centripetal'),hand:makeHand(s),cuff:add(new THREE.TorusGeometry(0.043,0.011,8,16),cuffM,0,0,0,sc)}});
function solve(arm,Sw,T){
 const d=new THREE.Vector3().subVectors(T,Sw);let dist=Math.min(d.length(),L1+L2-0.002);const dir=d.clone().normalize();
 const a=(L1*L1-L2*L2+dist*dist)/(2*dist),h=Math.sqrt(Math.max(L1*L1-a*a,0));
 const pole=new THREE.Vector3(arm.s*0.55,-1,-0.35);pole.sub(dir.clone().multiplyScalar(pole.dot(dir))).normalize();
 const E=Sw.clone().addScaledVector(dir,a).addScaledVector(pole,h);const W=Sw.clone().addScaledVector(dir,dist);
 const P=arm.curve.points;P[0].copy(Sw).addScaledVector(dir,-0.03);P[1].copy(E);P[2].copy(W);
 updateTube(arm.geo,arm.curve,[0.06,0.047,0.04]);
 const fd=new THREE.Vector3().subVectors(W,E).normalize();
 const raise=sm(cl((fd.y-0.15)/0.5));
 arm.hand.position.copy(W).addScaledVector(fd,0.004);arm.hand.up.set(lerp(-arm.s*0.35,0,raise),lerp(1,0,raise),lerp(0,-1,raise)).normalize();
 const hd=new THREE.Vector3(fd.x,THREE.MathUtils.clamp(fd.y,-0.35,1),fd.z).lerp(new THREE.Vector3(0,1,0.25),raise*0.8).normalize();
 arm.hand.lookAt(W.clone().add(hd));
 arm.cuff.position.copy(W).addScaledVector(fd,-0.04);arm.cuff.quaternion.setFromUnitVectors(new THREE.Vector3(0,0,1),fd)}
// ---------- robot
const RBG=new THREE.Group();RBG.position.set(0.7,1.38,-0.5);sc.add(RBG);
add(new THREE.IcosahedronGeometry(0.3,3),new THREE.MeshStandardMaterial({color:0xff8a3d,roughness:0.3,metalness:0.12,flatShading:true}),0,0,0,RBG);
const faceCv=document.createElement('canvas');faceCv.width=512;faceCv.height=300;const fg=faceCv.getContext('2d');const faceTex=new THREE.CanvasTexture(faceCv);faceTex.colorSpace=THREE.SRGBColorSpace;
add(new THREE.SphereGeometry(0.303,28,16,Math.PI/2-0.85,1.7,Math.PI/2-0.5,1.0),new THREE.MeshBasicMaterial({map:faceTex}),0,0,0,RBG,false);
add(new THREE.CylinderGeometry(0.012,0.012,0.12,6),M(0xb85f1e),0,0.34,0,RBG);
const bulb=add(new THREE.SphereGeometry(0.035,10,8),new THREE.MeshBasicMaterial({color:0xffd23f}),0,0.42,0,RBG,false);
[-1,1].forEach(s=>{const e=add(new THREE.CylinderGeometry(0.07,0.07,0.06,12),M(0xb85f1e),s*0.31,0,0,RBG);e.rotation.z=Math.PI/2});
// ---------- lights
sc.add(new THREE.HemisphereLight(0xffd9b0,0x3a2414,0.95));
const key=new THREE.DirectionalLight(0xffc98a,2.3);key.position.set(2.5,4,4);key.castShadow=true;key.shadow.mapSize.set(1024,1024);key.shadow.camera.left=-3;key.shadow.camera.right=3;key.shadow.camera.top=3.5;key.shadow.camera.bottom=-1;key.shadow.camera.near=1;key.shadow.camera.far=12;key.shadow.bias=-0.0006;sc.add(key);
const rim=new THREE.PointLight(0x6fa0ff,6,6);rim.position.set(1.2,1.9,-1.8);sc.add(rim);
const lampL=new THREE.PointLight(0xffb347,5,5);lampL.position.set(-2.4,1.5,-0.5);sc.add(lampL);
const faceFill=new THREE.PointLight(0xfff0dd,2.2,3);faceFill.position.set(-0.3,1.6,1.4);sc.add(faceFill);
const fillR=new THREE.PointLight(0x6ff0ff,0,3);fillR.position.set(0.7,1.4,0.2);sc.add(fillR);
// ---------- camera plan (slow eased moves + gentle push-in)
const SHOTS={wide:{pos:[0,1.5,4.3],tg:[0,1.2,-0.5],f:44},H:{pos:[-0.5,1.36,1.7],tg:[-0.6,1.3,-0.45],f:38},R:{pos:[0.72,1.42,1.7],tg:[0.7,1.38,-0.5],f:38}};
const keys=[{time:0,...SHOTS.H}];
LINES.forEach(l=>keys.push({time:Math.max(0,l.a-0.15),...SHOTS[l.s]}));
keys.push({time:DUR-4.5,...SHOTS.wide});keys.sort((a,b)=>a.time-b.time);
const ease3=x=>x<0.5?4*x*x*x:1-Math.pow(-2*x+2,3)/2;
function camAt(t){let i=0;while(i+1<keys.length&&keys[i+1].time<=t)i++;const k=keys[i],p=i>0?keys[i-1]:keys[0];const b=ease3(cl((t-k.time)/0.8));
 const P=[0,1,2].map(j=>lerp(p.pos[j],k.pos[j],b)),Tg=[0,1,2].map(j=>lerp(p.tg[j],k.tg[j],b));
 const push=0.1*cl((t-k.time)/3.0);return{P:P.map((v,j)=>v+(Tg[j]-v)*push),Tg,f:lerp(p.f,k.f,b)}}
// ---------- subtitles
const wseg=new Intl.Segmenter('th',{granularity:'word'}),gseg=new Intl.Segmenter('th',{granularity:'grapheme'});
LINES.forEach(l=>{const ws=[...wseg.segment(l.t)].map(s=>s.segment);const lens=ws.map(w=>w.trim().length?[...gseg.segment(w)].length+0.5:0);const tot=lens.reduce((a,b)=>a+b,0);let acc=0;l.w=ws.map((w,i)=>{const s=l.a+(l.b-l.a)*acc/tot;acc+=lens[i];return{w,s,e:l.a+(l.b-l.a)*acc/tot,sp:!w.trim().length}})});
const sub=document.getElementById('sub');
const YEV=[{t:0,v:0.1}];LINES.forEach(l=>{YEV.push({t:l.a-0.1,v:l.s==='R'?0.62:0.1});YEV.push({t:l.b+0.15,v:0.32})});YEV.sort((a,b)=>a.t-b.t);
function yawAt(t){let i=0;while(i+1<YEV.length&&YEV[i+1].t<=t)i++;const k=YEV[i],p=i>0?YEV[i-1]:YEV[0];return lerp(p.v,k.v,ease3(cl((t-k.t)/0.4)))}
const E=window.ENV;const envAt=(arr,t)=>{const x=t*E.fps,i=Math.floor(x),f=x-i;return lerp(arr[Math.min(arr.length-1,i)]||0,arr[Math.min(arr.length-1,i+1)]||0,f)};
const base=seek;
function drawFace(t,amp){fg.fillStyle='#1E1B2E';fg.fillRect(0,0,512,300);
 const bl=(t%3.2)>3.1?0.15:1;fg.fillStyle='#6FF0FF';
 [[150,100],[362,100]].forEach(e=>{const h=70*bl;fg.beginPath();fg.roundRect?fg.roundRect(e[0]-22,e[1]-h/2,44,h,22):fg.rect(e[0]-22,e[1]-h/2,44,h);fg.fill()});
 for(let i=0;i<11;i++){const h=8+amp*(10+70*(0.45+0.55*Math.abs(Math.sin(t*5+i*0.8))));fg.fillRect(120+i*26,225-h/2,14,h)}
 faceTex.needsUpdate=true}
const tmp=new THREE.Vector3();
window.seek=function(t){
 base(t);
 const act=LINES.find(l=>t>=l.a&&t<=l.b),spk=act?act.s:null;
 const aH=envAt(E.h,t),aR=envAt(E.r,t);
 const c=camAt(t);cam.position.set(c.P[0],c.P[1],c.P[2]);cam.fov=c.f;cam.updateProjectionMatrix();cam.lookAt(c.Tg[0],c.Tg[1],c.Tg[2]);
 // robot
 RBG.position.y=1.38+Math.sin(t*1.9)*0.025;RBG.rotation.y=-0.3+Math.sin(t*0.7)*0.07+aR*0.04;RBG.rotation.z=Math.sin(t*1.3)*0.03;
 bulb.material.color.set(aR>0.15?0xffee88:0xffb300);fillR.intensity=aR*2.0;drawFace(t,aR);
 // human
 const worried=t<3.7,happy=t>25.66;
 const target=spk==='R'?0.62:(act&&act.s==='H'?0.1:0.32);
 head.rotation.y=yawAt(t);
 head.rotation.x=-0.02+envAt(E.hg,t)*0.05+Math.sin(t*1.1)*0.015+(worried?-0.05:0);head.rotation.z=Math.sin(t*0.8)*0.02+(worried?0.04:0);
 head.position.y=1.31+Math.sin(t*1.6)*0.004;torso.scale.y=1+Math.sin(t*1.7)*0.012;
 const open=Math.min(1,aH*1.25);
 mIn.scale.set(1+open*0.08,0.12+open*1.1,0.45);lipU.position.y=0.006+open*0.014;lipL.position.y=-0.006-open*0.026;mouthG.position.y=-0.073-open*0.008;
 if(!act||spk==='R'){const smile=happy?1:0.3;lipU.rotation.z=Math.PI/2;lipL.rotation.z=Math.PI/2;}
 const blink=(t%3.7)>3.6?0.08:1;eyeG.forEach(g=>g.scale.y=blink);
 // gaze: look to robot when it speaks, else to camera
 const gx=spk==='R'?0.011:0.0,gy=worried?-0.004:0.0;pupils.forEach(p=>p.position.set(gx,gy,0.012));
 brows[0].rotation.z=worried?0.38:happy?-0.12:0.0;brows[1].rotation.z=worried?-0.38:happy?0.12:0.0;brows.forEach(b=>b.position.y=0.068+(worried?0.012:0)+(happy?0.006:0));
 // arms
 H.updateMatrixWorld(true);
 const sw=s=>new THREE.Vector3(s*0.2,0.99,0.0).applyMatrix4(H.matrixWorld);
 const hg=envAt(E.hg,t),g1=sm(cl(hg*2.2))*(spk==='H'?1:0),wave=Math.sin(t*2.4)*0.025;
 const restL=new THREE.Vector3(-0.72,0.86,0.2),restR=new THREE.Vector3(-0.48,0.86,0.2);
 let tL=restL.clone(),tR=restR.clone();
 if(worried){const w=0.5+0.5*Math.sin(t*5);tL.set(-0.76,1.36+w*0.015,0.2);tR.set(-0.44,1.36+w*0.015,0.2)}
 else{tR.set(lerp(restR.x,-0.3,g1),lerp(restR.y,1.08,g1)+wave*g1,lerp(restR.z,0.3,g1));tL.set(lerp(restL.x,-0.86,g1*0.5),lerp(restL.y,0.98,g1*0.5),lerp(restL.z,0.25,g1*0.5))}
 if(spk==='R'){tL.y+=Math.sin(t*2)*0.004;}
 solve(arms[0],sw(-1),tL);solve(arms[1],sw(1),tR);
 arms.forEach((a,i)=>{const curl=worried?0.18:(i===1?lerp(0.5,0.12,g1):0.5);a.hand.userData.fingers.forEach((f,j)=>{const c=curl+(j%2?0.07:0)+Math.sin(t*1.3+j*0.8)*0.02;f.rotation.x=c;f.userData.dist.rotation.x=c*1.15});const th=a.hand.userData.thumb;th.rotation.x=0.15+curl*0.25;th.userData.dist.rotation.x=curl*0.4});
 R.render(sc,cam);
 if(act){const col=act.s==='H'?'#4D8BFF':'#FF8A3D';let h='<span class="chip" style="background:'+col+'">'+(act.s==='H'?'นัท':'หุ่น AI')+'</span><span class="l">';
  act.w.forEach(x=>{const on=t>=x.s&&t<x.e;h+=x.sp?' ':'<span class="w'+(on?' on':'')+'">'+x.w+'</span>'});h+='</span>';if(sub._h!==h){sub.innerHTML=h;sub._h=h}sub.style.opacity=1}else sub.style.opacity=0;
};
seek(0);
