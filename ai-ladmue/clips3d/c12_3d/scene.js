const THREE=window.THREE;
const cv=document.getElementById('c');
const R=new THREE.WebGLRenderer({canvas:cv,antialias:true,preserveDrawingBuffer:true});
R.setPixelRatio(1);R.shadowMap.enabled=true;R.shadowMap.type=THREE.PCFSoftShadowMap;
R.toneMapping=THREE.ACESFilmicToneMapping;R.toneMappingExposure=1.28;R.outputColorSpace=THREE.SRGBColorSpace;
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
const lap=new THREE.Group();lap.position.set(-0.6,0.815,-0.1);lap.rotation.y=Math.PI;lap.scale.setScalar(0.8);sc.add(lap);
const alu=M(0xc9d0d6,{metalness:0.5,roughness:0.4});
box(0.5,0.02,0.34,alu,0,0,0,lap);
{const lid=new THREE.Group();lid.position.set(0,0.01,-0.17);lid.rotation.x=-0.5;lap.add(lid);
 box(0.5,0.32,0.014,alu,0,0.16,0,lid);add(new THREE.PlaneGeometry(0.44,0.27),new THREE.MeshBasicMaterial({color:0x5a8fe0}),0,0.16,0.009,lid,false);
 const lg=add(new THREE.OctahedronGeometry(0.03,0),new THREE.MeshBasicMaterial({color:0xffffff}),0,0.16,-0.012,lid,false);lg.scale.set(1,1.3,0.2)}
{const g=new THREE.Group();g.position.set(-1.15,0.815,0.3);sc.add(g);add(new THREE.CylinderGeometry(0.1,0.12,0.02,10),M(0x222233),0,0,0,g);add(new THREE.CylinderGeometry(0.012,0.012,0.45,6),M(0x222233),0,0.23,0,g);add(new THREE.CapsuleGeometry(0.04,0.1,3,8),M(0x666677,{metalness:0.5}),0,0.5,0,g)}
box(0.5,0.06,0.5,M(0x2d2d3a),-0.6,0.46,-0.45);box(0.5,0.55,0.06,M(0x2d2d3a),-0.6,0.78,-0.7);add(new THREE.CylinderGeometry(0.03,0.03,0.4,6),M(0x111118),-0.6,0.23,-0.45);
// ---------- human v3 (rebuilt from scratch)
const H=new THREE.Group();H.position.set(-0.6,0.1,-0.4);H.rotation.y=0.1;sc.add(H);
const PM=(c,o={})=>new THREE.MeshPhysicalMaterial(Object.assign({color:c,roughness:0.6,metalness:0},o));
const skin=PM(0xf0bc98,{roughness:0.55,sheen:0.5,sheenColor:new THREE.Color(0xffd0b0),sheenRoughness:0.5,emissive:0x4a1f10,emissiveIntensity:0.16});
const hoodM=PM(0x2f5d7c,{roughness:0.85,sheen:1,sheenColor:new THREE.Color(0x8fc0de),sheenRoughness:0.7});
const hoodD=PM(0x244a63,{roughness:0.9});
const hairM=PM(0x2a1b14,{roughness:0.5,sheen:0.7,sheenColor:new THREE.Color(0x9a7a60),sheenRoughness:0.5,side:THREE.DoubleSide});
const jeans=PM(0x2c3350,{roughness:0.9}),shoeM=PM(0xf1f1f1,{roughness:0.7}),darkM=PM(0x1d1d27,{roughness:0.5});
// torso: extruded sloped-shoulder silhouette
const torso=(()=>{const Lp=[[-0.165,0.56],[-0.18,0.66],[-0.188,0.78],[-0.2,0.9],[-0.222,0.975],[-0.2,1.04],[-0.12,1.072],[-0.06,1.09]];
 const pts=Lp.map(p=>new THREE.Vector3(p[0],p[1],0)).concat(Lp.slice().reverse().map(p=>new THREE.Vector3(-p[0],p[1],0)));
 const curve=new THREE.CatmullRomCurve3(pts,true,'centripetal');const sh=new THREE.Shape(curve.getPoints(90).map(v=>new THREE.Vector2(v.x,v.y)));
 const g=new THREE.ExtrudeGeometry(sh,{depth:0.1,bevelEnabled:true,bevelSize:0.05,bevelThickness:0.06,bevelSegments:6,curveSegments:1});
 g.translate(0,-0.84,-0.05);g.computeVertexNormals();const m=new THREE.Mesh(g,hoodM);m.position.set(0,0.798,0);m.scale.set(0.9,0.85,0.9);m.castShadow=true;m.receiveShadow=true;H.add(m);return m})();
add(new THREE.CylinderGeometry(0.05,0.06,0.07,16),skin,0,1.0,0.008,H);
add(new THREE.TorusGeometry(0.085,0.022,10,28),hoodD,0,0.985,0.006,H).rotation.x=Math.PI/2;
[-1,1].forEach(s=>{const d=add(new THREE.CylinderGeometry(0.0035,0.0035,0.16,6),PM(0xf0f0f0),s*0.03,0.9,0.118,H);d.rotation.x=0.12;add(new THREE.SphereGeometry(0.007,8,6),PM(0xf0f0f0),s*0.032,0.82,0.126,H)});
// headphones hanging around the neck
{const hp=add(new THREE.TorusGeometry(0.108,0.011,8,36),darkM,0,0.97,0.0,H);hp.rotation.x=Math.PI/2;
 [-1,1].forEach(s=>{const c=add(new THREE.CylinderGeometry(0.04,0.04,0.026,18),darkM,s*0.118,0.9,0.1,H);c.rotation.z=Math.PI/2;c.rotation.y=-s*0.25;const r=add(new THREE.TorusGeometry(0.036,0.005,6,20),PM(0xff8a3d),s*0.132,0.9,0.1,H);r.rotation.y=Math.PI/2-s*0.25})}
// head (chibi mascot style: big smooth head, minimal face)
const head=new THREE.Group();head.position.set(0,1.1,0.02);H.add(head);
{const g=new THREE.SphereGeometry(1,64,48);const p=g.attributes.position,v=new THREE.Vector3();
 for(let i=0;i<p.count;i++){v.fromBufferAttribute(p,i);let x=v.x,y=v.y,z=v.z;const jt=THREE.MathUtils.smoothstep(-y,0.1,1.0);x*=1-0.1*jt;p.setXYZ(i,x*0.152,y*0.135,z*0.14)}
 g.computeVertexNormals();add(g,skin,0,0,0,head)}
[-1,1].forEach(s=>{const e=add(new THREE.SphereGeometry(0.03,12,10),skin,s*0.15,-0.01,0.0,head);e.scale.set(0.4,1,0.75)});
[-1,1].forEach(s=>{const c=add(new THREE.CircleGeometry(0.022,22),new THREE.MeshBasicMaterial({color:0xff7d86,transparent:true,opacity:0.42}),s*0.088,-0.04,0.1155,head,false);c.rotation.y=s*0.62});
// hair: smooth rounded cap + clean fringe + side locks + ahoge
const hcap=add(new THREE.SphereGeometry(1,64,44,0,Math.PI*2,0,Math.PI*0.58),hairM,0,0.012,-0.012,head);hcap.scale.set(0.158,0.148,0.152);hcap.rotation.x=-0.42;
const fr=add(new THREE.SphereGeometry(1,32,20),hairM,0,0.078,0.101,head);fr.scale.set(0.108,0.036,0.05);fr.rotation.x=0.45;
[-1,1].forEach(s=>{const l=add(new THREE.CapsuleGeometry(0.018,0.05,4,10),hairM,s*0.117,0.012,0.082,head);l.rotation.z=s*0.15;l.scale.set(0.9,1,0.8)});
{const cv=new THREE.QuadraticBezierCurve3(new THREE.Vector3(0,0,0),new THREE.Vector3(0.012,0.032,0),new THREE.Vector3(0.034,0.046,0));add(new THREE.TubeGeometry(cv,14,0.0075,8),hairM,0.004,0.148,0.0,head)}
// eyes: glossy black ovals with two highlights
const blackM=new THREE.MeshPhysicalMaterial({color:0x07060a,roughness:0.12,clearcoat:1,clearcoatRoughness:0.05}),shineM=new THREE.MeshBasicMaterial({color:0xffffff});
const eyes=[-1,1].map(s=>{const g=new THREE.Group();g.position.set(s*0.056,-0.012,0.1275);head.add(g);
 const inn=new THREE.Group();g.add(inn);const el=add(new THREE.SphereGeometry(0.0185,24,18),blackM,0,0,0,inn,false);el.scale.set(0.8,1.22,0.5);
 add(new THREE.SphereGeometry(0.0058,10,8),shineM,0.0048,0.0085,0.0072,inn,false);add(new THREE.SphereGeometry(0.0027,8,6),shineM,-0.0045,-0.0075,0.0072,inn,false);
 return{g,inn,s}});
// brows: tiny soft dashes
const brows=[-1,1].map(s=>{const g=new THREE.Group();g.position.set(s*0.056,0.032,0.123);g.rotation.y=-s*0.4;head.add(g);const c=add(new THREE.CapsuleGeometry(0.0029,0.013,3,6),hairM,0,0,0,g,false);c.rotation.z=Math.PI/2;return g});
// mouth: small smile arc, opens into a soft oval when talking
const mouth=new THREE.Group();mouth.position.set(0,-0.056,0.1275);head.add(mouth);
const smileArc=add(new THREE.TorusGeometry(0.0125,0.0026,6,20,Math.PI),PM(0x5a2a30,{roughness:0.6}),0,0.007,0,mouth,false);smileArc.rotation.z=Math.PI;
const mOpen=add(new THREE.SphereGeometry(0.012,18,12),PM(0x4a1820,{roughness:0.8}),0,0,-0.001,mouth,false);mOpen.scale.set(1,0.05,0.4);
const tongue=add(new THREE.SphereGeometry(0.0075,10,8),PM(0xe0808a,{roughness:0.6}),0,-0.004,0.0,mouth,false);tongue.scale.set(1.3,0.4,0.6);
// seat + legs
box(0.5,0.06,0.5,M(0x2d2d3a),-0.6,0.46,-0.45);box(0.5,0.55,0.06,M(0x2d2d3a),-0.6,0.78,-0.7);add(new THREE.CylinderGeometry(0.03,0.03,0.4,6),M(0x111118),-0.6,0.23,-0.45);
box(0.17,0.17,0.5,jeans,-0.7,0.56,-0.15,H);box(0.17,0.17,0.5,jeans,-0.45,0.56,-0.15,H);box(0.14,0.5,0.14,jeans,-0.7,0.28,0.1,H);box(0.14,0.5,0.14,jeans,-0.45,0.28,0.1,H);
[-0.7,-0.45].forEach(x=>box(0.15,0.07,0.24,shoeM,x,0.035,0.17,H));
// arms: one smooth tapered tube through shoulder-elbow-wrist
const L1=0.18,L2=0.17,TN=18,TM=12;
function makeTube(){const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.BufferAttribute(new Float32Array((TN+1)*TM*3),3));const idx=[];for(let i=0;i<TN;i++)for(let j=0;j<TM;j++){const a=i*TM+j,b=i*TM+(j+1)%TM,c=(i+1)*TM+j,d=(i+1)*TM+(j+1)%TM;idx.push(a,c,b,b,c,d)}g.setIndex(idx);return g}
const vp=new THREE.Vector3(),vt=new THREE.Vector3(),vn=new THREE.Vector3(),vb=new THREE.Vector3(),vref=new THREE.Vector3(1,0,0);
function updateTube(g,curve,rs){const pos=g.attributes.position.array;curve.needsUpdate=true;
 for(let i=0;i<=TN;i++){const u=i/TN;curve.getPointAt(u,vp);curve.getTangentAt(u,vt);vn.crossVectors(vref,vt);if(vn.lengthSq()<1e-4)vn.set(0,0,1);vn.normalize();vb.crossVectors(vt,vn).normalize();
  const rad=u<0.5?lerp(rs[0],rs[1],sm(u*2)):lerp(rs[1],rs[2],sm((u-0.5)*2));
  for(let j=0;j<TM;j++){const an=j/TM*Math.PI*2,cx=Math.cos(an)*rad,sy=Math.sin(an)*rad,k=(i*TM+j)*3;pos[k]=vp.x+vn.x*cx+vb.x*sy;pos[k+1]=vp.y+vn.y*cx+vb.y*sy;pos[k+2]=vp.z+vn.z*cx+vb.z*sy}}
 g.attributes.position.needsUpdate=true;g.computeVertexNormals();g.computeBoundingSphere()}
const sleeveM=PM(0x2f5d7c,{roughness:0.85,sheen:1,sheenColor:new THREE.Color(0x8fc0de),side:THREE.DoubleSide}),cuffM=hoodD;
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
 updateTube(arm.geo,arm.curve,[0.054,0.046,0.04]);
 const fd=new THREE.Vector3().subVectors(W,E).normalize();
 const raise=sm(cl((fd.y-0.15)/0.5));
 arm.hand.position.copy(W).addScaledVector(fd,0.004);arm.hand.up.set(lerp(-arm.s*0.35,0,raise),lerp(1,0,raise),lerp(0,-1,raise)).normalize();
 const hd=new THREE.Vector3(fd.x,THREE.MathUtils.clamp(fd.y,-0.35,1),fd.z).lerp(new THREE.Vector3(0,1,0.25),raise*0.8).normalize();
 arm.hand.lookAt(W.clone().add(hd));
 arm.cuff.position.copy(W).addScaledVector(fd,-0.04);arm.cuff.quaternion.setFromUnitVectors(new THREE.Vector3(0,0,1),fd)}
// ---------- robot
const RBG=new THREE.Group();RBG.position.set(0.7,1.38,-0.5);sc.add(RBG);
add(new THREE.SphereGeometry(0.3,64,40),new THREE.MeshPhysicalMaterial({color:0xff8a3d,roughness:0.28,metalness:0.1,clearcoat:0.6,clearcoatRoughness:0.25}),0,0,0,RBG);
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
const faceFill=new THREE.PointLight(0xfff0dd,3.6,3.2);faceFill.position.set(-0.3,1.6,1.4);sc.add(faceFill);
const fillR=new THREE.PointLight(0x6ff0ff,0,3);fillR.position.set(0.7,1.4,0.2);sc.add(fillR);
// ---------- camera plan (slow eased moves + gentle push-in)
const SHOTS={wide:{pos:[0,1.5,4.3],tg:[0,1.2,-0.5],f:44},H:{pos:[-0.5,1.3,1.55],tg:[-0.6,1.14,-0.4],f:40},R:{pos:[0.72,1.42,1.7],tg:[0.7,1.38,-0.5],f:38}};
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
 // human v3
 const hg=envAt(E.hg,t),worried=t<3.7,happy=t>25.66,listening=spk==='R',speakH=spk==='H';
 const BL=[1.2,3.9,6.1,8.8,9.1,11.4,13.7,16.3,18.9,21.2,24.1,26.6,29.3];
 let blink=0;BL.forEach(b=>{const d=t-b;if(d>=0&&d<0.16)blink=Math.max(blink,Math.sin(d/0.16*Math.PI))});
 const hy=yawAt(t);head.rotation.y=hy;
 head.rotation.x=-0.02+hg*0.06+Math.sin(t*1.1)*0.012+Math.sin(t*0.37)*0.01+(worried?-0.06:0)+(listening?Math.max(0,Math.sin(t*2.3))*0.045:0);
 head.rotation.z=Math.sin(t*0.8)*0.015+(worried?0.05:0)+(speakH?Math.sin(t*3.1)*0.02:0);
 const br=Math.sin(t*1.6)*0.01;torso.scale.set(0.9*(1+br*0.4),0.85*(1+br),0.9*(1+br*0.6));head.position.y=1.1+br*0.8;
 const openL=cl((worried?1.0:happy?0.7:0.92)*(1-blink));
 const eyeYaw=-hy*0.65+THREE.MathUtils.clamp((yawAt(t+0.12)-hy)*2.5,-0.3,0.3)+Math.sin(t*7.3)*0.015,eyePitch=(worried?0.05:0)+Math.sin(t*5.1)*0.01;
 eyes.forEach(e=>{e.g.scale.y=Math.max(0.1,openL);e.inn.position.set(eyeYaw*0.012,eyePitch*0.012,0)});
 const raise=0.004*hg+(worried?0.009:0)+(happy?0.002:0),tilt=worried?0.3:(happy?-0.05:0.04*hg);
 brows.forEach((b,i)=>{const s=i?1:-1;b.position.y=0.032+raise*0.8;b.rotation.z=-s*tilt});
 const open=Math.min(1,aH*1.3),smile=happy?1:(listening?0.7:0.5);
 mOpen.scale.set(1+open*0.1,0.05+open*1.2,0.4);mOpen.position.y=-open*0.0072;tongue.visible=open>0.35;tongue.position.y=-0.004-open*0.0085;
 smileArc.visible=open<0.14;smileArc.scale.set(1+smile*0.1,0.8+smile*0.5,1);
 // arms
 H.updateMatrixWorld(true);
 const sw=s=>new THREE.Vector3(s*0.175,0.92,0.0).applyMatrix4(H.matrixWorld);
 const g1=sm(cl(hg*2.2))*(speakH?1:0),wave=Math.sin(t*2.4)*0.025;
 const idleTap=(!speakH&&!worried)?1:0,tap=Math.sin(t*9)*0.004*idleTap;
 const restL=new THREE.Vector3(-0.72,0.855,-0.16),restR=new THREE.Vector3(-0.48,0.855,-0.16);
 let tL=restL.clone(),tR=restR.clone();
 if(worried){const w=0.5+0.5*Math.sin(t*5);tL.set(-0.84,1.27+w*0.015,-0.22);tR.set(-0.36,1.27+w*0.015,-0.22)}
 else{tR.set(lerp(restR.x,-0.33,g1),lerp(restR.y,1.14,g1)+wave*g1+tap,lerp(restR.z,-0.13,g1));tL.set(lerp(restL.x,-0.82,g1*0.5),lerp(restL.y,1.06,g1*0.5)-tap,lerp(restL.z,-0.15,g1*0.5))}
 if(listening){tL.y+=Math.sin(t*2)*0.004}
 solve(arms[0],sw(-1),tL);solve(arms[1],sw(1),tR);
 arms.forEach((a,i)=>{const curl=worried?0.18:(i===1?lerp(0.5,0.12,g1):0.5);a.hand.userData.fingers.forEach((f,j)=>{const c=curl+(j%2?0.07:0)+Math.sin(t*1.3+j*0.8)*0.02+(idleTap?Math.max(0,Math.sin(t*9+j*1.9+i*2))*0.16:0);f.rotation.x=c;f.userData.dist.rotation.x=c*1.15});const th=a.hand.userData.thumb;th.rotation.x=0.15+curl*0.25;th.userData.dist.rotation.x=curl*0.4});
 R.render(sc,cam);
 if(act){const col=act.s==='H'?'#4D8BFF':'#FF8A3D';let h='<span class="chip" style="background:'+col+'">'+(act.s==='H'?'นัท':'หุ่น AI')+'</span><span class="l">';
  act.w.forEach(x=>{const on=t>=x.s&&t<x.e;h+=x.sp?' ':'<span class="w'+(on?' on':'')+'">'+x.w+'</span>'});h+='</span>';if(sub._h!==h){sub.innerHTML=h;sub._h=h}sub.style.opacity=1}else sub.style.opacity=0;
};
seek(0);
