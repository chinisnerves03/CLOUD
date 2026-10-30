L=open('scene.js').read().split('\n')
def rep(n,new):  # 1-indexed
    L[n-1]=new
# renderer/bg
rep(3,"const R=new THREE.WebGLRenderer({canvas:cv,antialias:true,preserveDrawingBuffer:true});")
rep(5,"R.toneMapping=THREE.ACESFilmicToneMapping;R.toneMappingExposure=1.18;R.outputColorSpace=THREE.SRGBColorSpace;")
rep(6,"const sc=new THREE.Scene();sc.background=new THREE.Color(0x120a1c);sc.fog=new THREE.Fog(0x1a0f26,7,17);")
# floor+rug
rep(14,"""const mkc=(w,h,fn)=>{const c=document.createElement('canvas');c.width=w;c.height=h;const g=c.getContext('2d');fn(g,w,h);const t=new THREE.CanvasTexture(c);t.colorSpace=THREE.SRGBColorSpace;t.anisotropy=4;return t};
let rs=7;const rnd=()=>{rs=(rs*16807)%2147483647;return rs/2147483647};
const floorTex=mkc(1024,1024,(g,w,h)=>{for(let i=0;i<10;i++){const l=40+rnd()*10;g.fillStyle='hsl(26,'+(38+rnd()*8)+'%,'+(l-8)+'%)';g.fillRect(0,i*102.4,w,102.4);for(let k=0;k<60;k++){g.fillStyle='rgba(0,0,0,'+(rnd()*0.07)+')';g.fillRect(rnd()*w,i*102.4+rnd()*100,60+rnd()*200,1.4)}g.fillStyle='rgba(0,0,0,.4)';g.fillRect(0,i*102.4,w,3);for(let k=0;k<3;k++){g.fillRect(rnd()*w,i*102.4,3,102.4)}}});floorTex.wrapS=floorTex.wrapT=THREE.RepeatWrapping;floorTex.repeat.set(1.4,1.4);""")
rep(15,"""add(new THREE.PlaneGeometry(10,12),new THREE.MeshStandardMaterial({map:floorTex,roughness:0.42,metalness:0.05}),0,0,1.5).rotation.x=-Math.PI/2;""")
# walls: wallpaper
rep(16,"""const wallTex=mkc(512,512,(g,w,h)=>{g.fillStyle='#4a2f58';g.fillRect(0,0,w,h);for(let x=0;x<w;x+=64){g.fillStyle='rgba(255,255,255,0.045)';g.fillRect(x,0,32,h)}for(let k=0;k<2200;k++){g.fillStyle='rgba(255,255,255,'+rnd()*0.035+')';g.fillRect(rnd()*w,rnd()*h,2,2)}g.fillStyle='rgba(0,0,0,.28)';g.fillRect(0,h*0.72,w,h*0.28);g.fillStyle='rgba(255,210,160,.25)';g.fillRect(0,h*0.72,w,3)});wallTex.wrapS=wallTex.wrapT=THREE.RepeatWrapping;wallTex.repeat.set(3,1);
const wallM=new THREE.MeshStandardMaterial({map:wallTex,roughness:0.9});
add(new THREE.PlaneGeometry(10,3.6),wallM,0,1.8,-2.6,sc,false).receiveShadow=true;const sideW=new THREE.MeshStandardMaterial({color:0x3a2447,roughness:0.9});box(0.15,3.6,10,sideW,-3.2,1.8,1.5);box(0.15,3.6,10,sideW,3.2,1.8,1.5);box(10,0.14,0.14,M(0x241530),0,0.07,-2.55);box(10,0.09,0.1,M(0xd8b88a),0,3.5,-2.55);""")
# window: night city
rep(17,"""const cityTex=mkc(512,640,(g,w,h)=>{const gr=g.createLinearGradient(0,0,0,h);gr.addColorStop(0,'#0b1030');gr.addColorStop(0.55,'#3a2a6a');gr.addColorStop(0.9,'#ff8a5a');gr.addColorStop(1,'#ffb36b');g.fillStyle=gr;g.fillRect(0,0,w,h);for(let k=0;k<70;k++){g.fillStyle='rgba(255,255,255,'+(0.3+rnd()*0.6)+')';g.fillRect(rnd()*w,rnd()*h*0.5,2,2)}g.fillStyle='#fff3c8';g.beginPath();g.arc(380,120,34,0,7);g.fill();g.fillStyle='rgba(255,243,200,.18)';g.beginPath();g.arc(380,120,70,0,7);g.fill();
 for(let L2=0;L2<3;L2++){let x=-20;while(x<w){const bw=40+rnd()*70,bh=120+rnd()*(180+L2*60);const y=h-bh*(1-L2*0.18)-L2*10;g.fillStyle=['#1a1230','#241a40','#2f2352'][L2];g.fillRect(x,y,bw,h-y);for(let wy=y+10;wy<h-10;wy+=16)for(let wx=x+6;wx<x+bw-8;wx+=14){if(rnd()<0.42){g.fillStyle=rnd()<0.2?'#9fe8ff':'#ffd27a';g.globalAlpha=0.5+rnd()*0.5;g.fillRect(wx,wy,6,8);g.globalAlpha=1}}x+=bw+rnd()*8}}});
const winM=new THREE.MeshBasicMaterial({map:cityTex});""")
rep(18,"""box(1.55,1.85,0.12,M(0x1c1226),1.5,1.95,-2.52);add(new THREE.PlaneGeometry(1.4,1.7),winM,1.5,1.95,-2.455,sc,false);""")
rep(19,"""box(0.06,1.7,0.05,M(0x1c1226),1.5,1.95,-2.44);box(1.4,0.06,0.05,M(0x1c1226),1.5,1.95,-2.44);box(1.7,0.07,0.2,M(0x241530),1.5,1.0,-2.42);""")
rep(20,"""[[-1,0xc0407a],[1,0x3d6fc0]].forEach(c=>{const cu=add(new THREE.BoxGeometry(0.24,2.0,0.1),M(c[1],{roughness:0.95}),1.5+c[0]*0.93,1.95,-2.38);cu.scale.x=1})""")
# wall neon sign + frames (replaces grid)
rep(21,"""const neonTex=mkc(512,200,(g,w,h)=>{g.clearRect(0,0,w,h);g.font='800 150px Prompt, sans-serif';g.textAlign='center';g.textBaseline='middle';g.shadowColor='#ff4fa3';g.shadowBlur=36;g.fillStyle='#ffd0ec';g.strokeStyle='#ff4fa3';g.lineWidth=6;g.strokeText('฿1,000,000',w/2,h/2+6);g.fillText('฿1,000,000',w/2,h/2+6)});
const neon=add(new THREE.PlaneGeometry(1.5,0.585),new THREE.MeshBasicMaterial({map:neonTex,transparent:true,toneMapped:false}),-0.55,2.55,-2.5,sc,false);
[[-1.55,2.55,0xffc86b],[-1.9,2.3,0x6fd0ff]].forEach((f,i)=>{box(0.42,0.54,0.04,M(0x1c1226),f[0],f[1],-2.52);add(new THREE.PlaneGeometry(0.34,0.46),new THREE.MeshStandardMaterial({color:f[2],emissive:f[2],emissiveIntensity:0.25}),f[0],f[1],-2.495,sc,false)});""")
# string lights keep (26) but make glowing brighter
rep(26,"for(let i=0;i<22;i++){const x=-2.9+i*0.28,y=3.2-Math.sin(i/21*Math.PI)*0.3;add(new THREE.SphereGeometry(0.035,10,8),new THREE.MeshBasicMaterial({color:[0xffd27a,0xff8fc0,0x8fe8ff][i%3],toneMapped:false}),x,y,-2.45,sc,false)}")
rep(27,"""{const rg=mkc(512,512,(g,w,h)=>{g.fillStyle='#2b4f63';g.fillRect(0,0,w,h);g.strokeStyle='#e8c07a';g.lineWidth=14;g.strokeRect(24,24,w-48,h-48);g.lineWidth=5;for(let i=0;i<6;i++){g.strokeRect(60+i*16,60+i*16,w-120-i*32,h-120-i*32)}g.fillStyle='rgba(255,255,255,.06)';for(let k=0;k<1500;k++)g.fillRect(rnd()*w,rnd()*h,2,2)});const r=add(new THREE.CylinderGeometry(1.9,1.9,0.02,48),new THREE.MeshStandardMaterial({map:rg,roughness:0.95}),0,0.012,0.2);r.castShadow=false}""")
rep(28,"""{const g=new THREE.Group();g.position.set(-2.55,0,-0.6);sc.add(g);add(new THREE.CylinderGeometry(0.025,0.025,1.4,8),M(0x120a18),0,0.7,0,g);add(new THREE.CylinderGeometry(0.28,0.28,0.04,24),M(0x120a18),0,0.02,0,g);add(new THREE.CylinderGeometry(0.13,0.26,0.32,16,1,true),new THREE.MeshStandardMaterial({color:0xffe0a0,emissive:0xffa347,emissiveIntensity:1.6,side:THREE.DoubleSide,toneMapped:false}),0,1.5,0,g,false)}""")
open('scene.js','w').write('\n'.join(L))
