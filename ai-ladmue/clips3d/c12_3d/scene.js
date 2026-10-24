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
// ---------- second robot "น้องฟ้า" (replaces the human)
const H=new THREE.Group();H.position.set(-0.6,0.1,-0.4);H.rotation.y=0.1;sc.add(H);
const PM=(c,o={})=>new THREE.MeshPhysicalMaterial(Object.assign({color:c,roughness:0.6,metalness:0},o));
const skin=PM(0xf2f6f8,{roughness:0.3,clearcoat:0.5,clearcoatRoughness:0.3});
const tealM=PM(0x2fc4b8,{roughness:0.28,metalness:0.1,clearcoat:0.7,clearcoatRoughness:0.2});
const tealD=PM(0x1b9a90,{roughness:0.45});
const whiteM=PM(0xf2f6f8,{roughness:0.3,clearcoat:0.5});
const hoodD=PM(0x1b9a90,{roughness:0.45});
const jeans=PM(0x3a4660,{roughness:0.6}),shoeM=PM(0xf1f1f1,{roughness:0.5}),darkM=PM(0x1d1d27,{roughness:0.5});
function rrShape(w,h,r){const sh=new THREE.Shape();const x=-w/2,y=-h/2;sh.moveTo(x+r,y);sh.lineTo(x+w-r,y);sh.quadraticCurveTo(x+w,y,x+w,y+r);sh.lineTo(x+w,y+h-r);sh.quadraticCurveTo(x+w,y+h,x+w-r,y+h);sh.lineTo(x+r,y+h);sh.quadraticCurveTo(x,y+h,x,y+h-r);sh.lineTo(x,y+r);sh.quadraticCurveTo(x,y,x+r,y);return sh}
function rbox(w,h,d,r,bv){const g=new THREE.ExtrudeGeometry(rrShape(w-2*bv,h-2*bv,Math.max(0.005,r-bv)),{depth:d-2*bv,bevelEnabled:true,bevelSize:bv,bevelThickness:bv,bevelSegments:6,curveSegments:10});g.translate(0,0,-(d-2*bv)/2);g.computeVertexNormals();return g}
// body: chubby capsule with glowing heart panel
const torso=add(new THREE.CapsuleGeometry(0.15,0.12,10,28),tealM,0,0.78,0,H);torso.scale.set(1.1,1,0.9);
const chCv=document.createElement('canvas');chCv.width=256;chCv.height=256;{const g=chCv.getContext('2d');g.fillStyle='#10142a';g.fillRect(0,0,256,256);g.fillStyle='#ff6f91';g.shadowColor='#ff6f91';g.shadowBlur=30;g.beginPath();g.moveTo(128,196);g.bezierCurveTo(30,130,60,50,128,98);g.bezierCurveTo(196,50,226,130,128,196);g.fill()}
const chTex=new THREE.CanvasTexture(chCv);chTex.colorSpace=THREE.SRGBColorSpace;
add(new THREE.CircleGeometry(0.07,32),new THREE.MeshBasicMaterial({map:chTex}),0,0.78,0.1385,H,false);
add(new THREE.TorusGeometry(0.073,0.008,8,32),whiteM,0,0.78,0.1375,H);
add(new THREE.CylinderGeometry(0.05,0.06,0.08,16),tealD,0,0.99,0.0,H);
// head: rounded-square with visor and expressive face screen
const head=new THREE.Group();head.position.set(0,1.12,0.02);H.add(head);
add(rbox(0.38,0.3,0.27,0.11,0.035),tealM,0,0,0,head);
add(rbox(0.31,0.225,0.03,0.075,0.008),whiteM,0,0,0.128,head);
const fcv=document.createElement('canvas');fcv.width=560;fcv.height=400;const fx=fcv.getContext('2d');const ftex=new THREE.CanvasTexture(fcv);ftex.colorSpace=THREE.SRGBColorSpace;
add(new THREE.PlaneGeometry(0.285,0.2),new THREE.MeshBasicMaterial({map:ftex,transparent:true}),0,0,0.1445,head,false);
[-1,1].forEach(s=>{const e=add(new THREE.CylinderGeometry(0.055,0.055,0.035,24),whiteM,s*0.2,-0.005,0,head);e.rotation.z=Math.PI/2;const r=add(new THREE.TorusGeometry(0.05,0.007,8,28),PM(0xff6f91,{roughness:0.35}),s*0.2,-0.005,0,head);r.rotation.y=Math.PI/2;r.position.x=s*0.2175});
add(new THREE.CylinderGeometry(0.009,0.009,0.075,8),tealD,0,0.185,0,head);
const antBall=add(new THREE.SphereGeometry(0.028,18,14),new THREE.MeshBasicMaterial({color:0xff6f91}),0,0.236,0,head,false);
function drawBot2(t,st){const g=fx;g.clearRect(0,0,560,400);
 g.fillStyle='#10142a';g.beginPath();if(g.roundRect)g.roundRect(0,0,560,400,120);else g.rect(0,0,560,400);g.fill();
 const gr=g.createLinearGradient(0,0,0,400);gr.addColorStop(0,'rgba(90,130,255,0.2)');gr.addColorStop(1,'rgba(0,0,0,0)');g.fillStyle=gr;g.fill();
 const col='#9dff7a';g.fillStyle=col;g.strokeStyle=col;g.lineCap='round';
 const ey=160;[165,395].forEach((x,i)=>{const px=x+st.gx*16,sgn=i?1:-1;
  if(st.happy){g.lineWidth=24;g.beginPath();g.arc(px,ey+34,52,Math.PI*1.1,Math.PI*1.9);g.stroke()}
  else{const h=Math.max(8,92*(1-st.blink)*(st.worried?1.1:1)),w=st.worried?60:54;g.beginPath();g.ellipse(px,ey,w/2,h/2,0,0,Math.PI*2);g.fill();
   if(st.blink<0.5){g.fillStyle='#10142a';g.beginPath();g.arc(px+11,ey-18,9,0,Math.PI*2);g.fill();g.fillStyle=col}}
  if(st.worried&&!st.happy){g.lineWidth=13;g.beginPath();g.moveTo(x-sgn*(-34),ey-70-(sgn>0?0:18));g.lineTo(x+sgn*(-34),ey-70-(sgn>0?18:0));g.stroke()}});
 g.fillStyle='rgba(255,122,162,0.5)';[[95,262],[465,262]].forEach(c=>{g.beginPath();g.ellipse(c[0],c[1],42,24,0,0,Math.PI*2);g.fill()});
 g.fillStyle='#ff7aa2';g.strokeStyle='#ff7aa2';
 if(st.open>0.12){const w=34+st.open*26,h=12+st.open*68;g.beginPath();g.ellipse(280,292,w,h/2+4,0,0,Math.PI*2);g.fill();g.fillStyle='#8a2f4d';g.beginPath();g.ellipse(280,292+h*0.18,w*0.7,h*0.22,0,0,Math.PI*2);g.fill()}
 else if(st.worried&&!st.happy){g.lineWidth=14;g.beginPath();g.moveTo(230,292);g.quadraticCurveTo(255,276,280,292);g.quadraticCurveTo(305,308,330,292);g.stroke()}
 else{g.lineWidth=15;g.beginPath();g.arc(280,262,(st.happy?60:50),Math.PI*0.14,Math.PI*0.86);g.stroke()}
 ftex.needsUpdate=true}
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
const sleeveM=PM(0x2fc4b8,{roughness:0.3,clearcoat:0.6,clearcoatRoughness:0.25,side:THREE.DoubleSide}),cuffM=PM(0xf2f6f8,{roughness:0.3});
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
 const pole=arm.pole?arm.pole.clone():new THREE.Vector3(arm.s*0.55,-1,-0.35);pole.sub(dir.clone().multiplyScalar(pole.dot(dir))).normalize();
 const E=Sw.clone().addScaledVector(dir,a).addScaledVector(pole,h);const W=Sw.clone().addScaledVector(dir,dist);
 const P=arm.curve.points;P[0].copy(Sw).addScaledVector(dir,-0.03);P[1].copy(E);P[2].copy(W);
 updateTube(arm.geo,arm.curve,[0.054,0.046,0.04]);
 const fd=new THREE.Vector3().subVectors(W,E).normalize();
 const raise=sm(cl((fd.y-0.15)/0.5));
 arm.hand.position.copy(W).addScaledVector(fd,0.004);arm.hand.up.set(lerp(-arm.s*0.35,0,raise),lerp(1,0,raise),lerp(0,-1,raise)).normalize();
 const hd=new THREE.Vector3(fd.x,THREE.MathUtils.clamp(fd.y,-0.35,1),fd.z).lerp(new THREE.Vector3(0,1,0.25),raise*0.8).normalize();
 arm.hand.lookAt(W.clone().add(hd));
 if(arm.poseDir){arm.hand.up.copy(arm.poseUp).normalize();arm.hand.lookAt(W.clone().add(arm.poseDir))}
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
// ---------- pose library (coordinates local to the character, hand pos / finger dir / palm-up vector / curl)
const mk=(Lp,Ld,Lu,Lc,Rp,Rd,Ru,Rc,lean=0,roll=0,nod=0)=>({L:{p:Lp,d:Ld,u:Lu,c:Lc},R:{p:Rp,d:Rd,u:Ru,c:Rc},lean,roll,nod});
const TYPEL={p:[-0.12,0.755,0.24],d:[0,-0.1,1],u:[0.35,1,0],c:0.5},TYPER={p:[0.12,0.755,0.24],d:[0,-0.1,1],u:[-0.35,1,0],c:0.5};
const PS={
 type:   mk(TYPEL.p,TYPEL.d,TYPEL.u,0.5, TYPER.p,TYPER.d,TYPER.u,0.5),
 cheeks: mk([-0.21,1.07,0.15],[0.05,1,0.3],[-1,0,0],0.2, [0.21,1.07,0.15],[-0.05,1,0.3],[1,0,0],0.2, -0.05,0.06,-0.06),
 facepalm:mk([-0.2,0.8,0.3],[0,0,1],[0.35,1,0],0.4, [0.02,1.18,0.17],[0,1,-0.25],[0,0,1],0.25, 0.06,-0.1,0.16),
 chin:   mk([-0.14,0.77,0.25],[0,-0.1,1],[0.35,1,0],0.5, [0.045,0.97,0.17],[-0.3,1,0.15],[-0.5,0,1],0.75, 0.04,0.14,0.02),
 cheer:  mk([-0.25,1.22,0.07],[-0.1,1,0.1],[0,0,-1],0.1, [0.25,1.22,0.07],[0.1,1,0.1],[0,0,-1],0.1, -0.05,0.0,-0.06),
 shrug:  mk([-0.31,0.93,0.26],[-0.25,0.1,1],[0,-1,0],0.25, [0.31,0.93,0.26],[0.25,0.1,1],[0,-1,0],0.25, 0.04,0.14,0.0),
 wave:   mk(TYPEL.p,TYPEL.d,TYPEL.u,0.5, [0.3,1.17,0.1],[0.1,1,0.1],[0,0,-1],0.1, 0.0,-0.06,-0.02)
};
const SEGS=[[0,'cheeks'],[1.7,'facepalm'],[3.3,'type'],[9.4,'chin'],[12.6,'type'],[15.6,'chin'],[19.3,'type'],[22.35,'cheer'],[24.2,'shrug'],[25.6,'type'],[27.9,'wave']];
const mixArr=(a,b,k)=>a.map((v,i)=>lerp(v,b[i],k));
function mixPose(a,b,k){const o={L:{},R:{}};['L','R'].forEach(h=>{['p','d','u'].forEach(f=>o[h][f]=mixArr(a[h][f],b[h][f],k));o[h].c=lerp(a[h].c,b[h].c,k)});o.lean=lerp(a.lean,b.lean,k);o.roll=lerp(a.roll,b.roll,k);o.nod=lerp(a.nod,b.nod,k);return o}
function poseAt(t){let i=0;while(i+1<SEGS.length&&SEGS[i+1][0]<=t)i++;const cur=PS[SEGS[i][1]],prev=i>0?PS[SEGS[i-1][1]]:cur;return mixPose(prev,cur,sm(cl((t-SEGS[i][0])/0.5)))}
const NODS=LINES.filter(l=>l.s==='R').map(l=>l.a+0.12);
window.seek=function(t){
 base(t);
 const act=LINES.find(l=>t>=l.a&&t<=l.b),spk=act?act.s:null;
 const aH=envAt(E.h,t),aR=envAt(E.r,t);
 const c=camAt(t);cam.position.set(c.P[0],c.P[1],c.P[2]);cam.fov=c.f;cam.updateProjectionMatrix();cam.lookAt(c.Tg[0],c.Tg[1],c.Tg[2]);
 // robot
 RBG.position.y=1.38+Math.sin(t*1.9)*0.025;RBG.rotation.y=-0.3+Math.sin(t*0.7)*0.07+aR*0.04;RBG.rotation.z=Math.sin(t*1.3)*0.03;
 bulb.material.color.set(aR>0.15?0xffee88:0xffb300);fillR.intensity=aR*2.0;drawFace(t,aR);
 // second robot animation
 const hg=envAt(E.hg,t),worried=t<3.7,happy=t>25.66,listening=spk==='R',speakH=spk==='H';
 const BL=[1.2,3.9,6.1,8.8,9.1,11.4,13.7,16.3,18.9,21.2,24.1,26.6,29.3];
 let blink=0;BL.forEach(bt=>{const d=t-bt;if(d>=0&&d<0.16)blink=Math.max(blink,Math.sin(d/0.16*Math.PI))});
 const hy=yawAt(t);head.rotation.y=hy;
 head.rotation.x=-0.02+hg*0.06+Math.sin(t*1.1)*0.012+Math.sin(t*0.37)*0.01+(worried?-0.05:0)+(listening?Math.max(0,Math.sin(t*2.3))*0.05:0);
 head.rotation.z=Math.sin(t*0.8)*0.02+(worried?0.05:0)+(speakH?Math.sin(t*3.1)*0.025:0);
 const br=Math.sin(t*1.6)*0.01;torso.scale.set(1.1*(1+br*0.4),1+br,0.9*(1+br*0.6));head.position.y=1.12+br*0.8+Math.sin(t*2.2)*0.004;
 const eyeYaw=-hy*0.65+THREE.MathUtils.clamp((yawAt(t+0.12)-hy)*2.5,-0.3,0.3);
 drawBot2(t,{blink,open:Math.min(1,aH*1.3),worried,happy:(happy||(t>22.35&&t<24.2)),listening,gx:THREE.MathUtils.clamp(eyeYaw*2.5,-1,1)});
 antBall.material.color.set(speakH?0xffe27a:0xff6f91);antBall.position.y=0.236+Math.sin(t*5)*0.003*(speakH?3:1);
 // pose-driven arms, body and head
 const P=poseAt(t);
 const shake=1-sm(cl((t-1.3)/0.5)),waveAmt=sm(cl((t-27.9)/0.4)),happyNow=(t>22.35&&t<24.2)||t>25.66;
 let nodP=0;NODS.forEach(n=>{nodP+=0.11*Math.exp(-(((t-n)/0.17)**2))});
 head.rotation.x+=P.nod+nodP;head.rotation.z+=P.roll;head.rotation.y+=Math.sin(t*11)*0.07*shake;
 head.position.z=0.02+P.lean*0.12;torso.rotation.x=P.lean;
 const lp=P.L.p.slice(),rp=P.R.p.slice(),ld=P.L.d.slice(),rd=P.R.d.slice();
 lp[0]+=Math.sin(t*16)*0.011*shake;rp[0]+=Math.sin(t*16+1)*0.011*shake;lp[1]+=Math.sin(t*13)*0.008*shake;rp[1]+=Math.sin(t*13+2)*0.008*shake;
 rp[0]+=Math.sin(t*7)*0.04*waveAmt;rd[0]+=Math.sin(t*7)*0.45*waveAmt;rp[1]+=Math.abs(Math.sin(t*3.5))*0.012*waveAmt;
 const tw=THREE.MathUtils.clamp(1-Math.hypot(P.L.p[0]-TYPEL.p[0],P.L.p[1]-TYPEL.p[1],P.L.p[2]-TYPEL.p[2])*7,0,1)*(speakH?0.4:1);
 const tap=Math.sin(t*9)*0.004*tw;lp[1]+=tap;rp[1]-=tap;
 H.updateMatrixWorld(true);
 const sw=s=>new THREE.Vector3(s*0.175,0.92+P.lean*-0.05,0.0).applyMatrix4(H.matrixWorld);
 const wp=v=>H.localToWorld(new THREE.Vector3(v[0],v[1],v[2])),wv=v=>new THREE.Vector3(v[0],v[1],v[2]).applyQuaternion(H.quaternion);
 arms[0].poseDir=wv(ld);arms[0].poseUp=wv(P.L.u);arms[1].poseDir=wv(rd);arms[1].poseUp=wv(P.R.u);
 solve(arms[0],sw(-1),wp(lp));solve(arms[1],sw(1),wp(rp));
 arms.forEach((a,i)=>{const hp=i?P.R:P.L;a.hand.userData.fingers.forEach((f,j)=>{const c=hp.c+(j%2?0.07:0)+Math.sin(t*1.3+j*0.8)*0.02+(tw>0.2?Math.max(0,Math.sin(t*9+j*1.9+i*2))*0.16*tw:0);f.rotation.x=c;f.userData.dist.rotation.x=c*1.15});const th=a.hand.userData.thumb;th.rotation.x=0.15+hp.c*0.25;th.userData.dist.rotation.x=hp.c*0.4});
 // orange robot: squash/stretch with its voice, leans toward its friend
 RBG.scale.set(1+aR*0.025,1-aR*0.03,1+aR*0.025);RBG.rotation.x=aR*-0.04;
 R.render(sc,cam);
 if(act){const col=act.s==='H'?'#4D8BFF':'#FF8A3D';let h='<span class="chip" style="background:'+col+'">'+(act.s==='H'?'น้องฟ้า':'หุ่น AI')+'</span><span class="l">';
  act.w.forEach(x=>{const on=t>=x.s&&t<x.e;h+=x.sp?' ':'<span class="w'+(on?' on':'')+'">'+x.w+'</span>'});h+='</span>';if(sub._h!==h){sub.innerHTML=h;sub._h=h}sub.style.opacity=1}else sub.style.opacity=0;
};
seek(0);
