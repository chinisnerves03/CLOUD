// Pip Thimble scene engine. Deterministic: seek(t) draws the frame for time t (seconds) from window.EP.
const NS = 'http://www.w3.org/2000/svg';
const C = {kraft:'#C89B6D',kraftD:'#A97C50',kraftL:'#DDBB90',navy:'#1F2A44',ink:'#141A2E',must:'#E0A526',mustD:'#B9841B',
  tom:'#C8452F',tomD:'#9E3322',cream:'#F3E9D2',creamD:'#E3D5B5',teal:'#2F8F8B',tealD:'#226B68',skin:'#EBCB9F',sticker:'#FBF7EC',
  silver:'#BFC6CF',silverD:'#98A1AD'};
function el(tag, attrs, parent){const e=document.createElementNS(NS,tag);for(const k in (attrs||{}))e.setAttribute(k,attrs[k]);if(parent)parent.appendChild(e);return e;}
function rnd(seed){let a=seed>>>0;return function(){a|=0;a=a+0x6D2B79F5|0;let t=Math.imul(a^a>>>15,1|a);t=t+Math.imul(t^t>>>7,61|t)^t;return((t^t>>>14)>>>0)/4294967296;};}
const clamp=(x,a=0,b=1)=>Math.max(a,Math.min(b,x));
const lerp=(a,b,u)=>a+(b-a)*u;
const smooth=u=>u*u*(3-2*u);
function ell(cx,cy,rx,ry,n=26){const p=[];for(let i=0;i<n;i++){const a=i/n*Math.PI*2;p.push([cx+Math.cos(a)*rx,cy+Math.sin(a)*ry]);}return p;}
function rectP(x,y,w,h){return [[x,y],[x+w,y],[x+w,y+h],[x,y+h]];}
function jag(pts,amp=3,step=16,seed=1){const r=rnd(seed);let d='',n=pts.length;for(let i=0;i<n;i++){const a=pts[i],b=pts[(i+1)%n];const len=Math.hypot(b[0]-a[0],b[1]-a[1]);const k=Math.max(1,Math.round(len/step));for(let j=0;j<k;j++){const u=j/k;const x=a[0]+(b[0]-a[0])*u+(j?(r()-.5)*amp*2:0),y=a[1]+(b[1]-a[1])*u+(j?(r()-.5)*amp*2:0);d+=(d?'L':'M')+x.toFixed(1)+' '+y.toFixed(1);}}return d+'Z';}
function cut(parent,pts,fill,o={}){const d=typeof pts==='string'?pts:jag(pts,o.amp??2.2,o.step??15,o.seed??7);
  const a={d,fill};if(o.sw!==0){a.stroke=o.stroke||C.sticker;a['stroke-width']=o.sw??5;a['stroke-linejoin']='round';a['paint-order']='stroke';}
  if(o.op!=null)a.opacity=o.op;return el('path',a,parent);}
function line(parent,x1,y1,x2,y2,col,w,o={}){return el('line',Object.assign({x1,y1,x2,y2,stroke:col,'stroke-width':w,'stroke-linecap':'round'},o),parent);}
function G(parent,tf,extra){return el('g',Object.assign({transform:tf||''},extra||{}),parent);}
function txt(parent,s,x,y,size,fill,o={}){const t=el('text',Object.assign({x,y,'font-size':size,fill,'font-weight':o.w||800,'text-anchor':o.anchor||'middle'},o.serif?{style:"font-family:Georgia,'DejaVu Serif',serif"}:{},o.attrs||{}),parent);t.textContent=s;return t;}
function wrapText(s,maxc){const w=s.split(/\s+/),L=[];let cur='';for(const x of w){if((cur+' '+x).trim().length>maxc&&cur){L.push(cur);cur=x;}else cur=(cur+' '+x).trim();}if(cur)L.push(cur);return L;}

// ---- keyframe tracks: numeric fields lerp (smoothstep), others step ----
function track(keys,t){if(!keys||!keys.length)return {};if(t<=keys[0].t)return keys[0];const last=keys[keys.length-1];if(t>=last.t)return last;
  for(let i=0;i<keys.length-1;i++){const a=keys[i],b=keys[i+1];if(t>=a.t&&t<=b.t){const u=smooth((t-a.t)/Math.max(1e-6,b.t-a.t));const o={};
    for(const k in a){o[k]=(typeof a[k]==='number'&&typeof b[k]==='number'&&k!=='t')?lerp(a[k],b[k],u):a[k];}
    for(const k in b){if(!(k in o))o[k]=b[k];}return o;}}return last;}

let STAGE,WORLD,HUD,LAY={},CUR=-1,SHOT=null,ACT=[],PROP=[],BGTICK=null;
const LAYERS=[['far',.25],['mid',.6],['main',1],['stuff',1],['front',1.35]];

function init(){
  const wrap=document.getElementById('wrap');
  STAGE=el('svg',{width:1080,height:1920,viewBox:'0 0 1080 1920',xmlns:NS},wrap);
  const defs=el('defs',{},STAGE);
  const f=el('filter',{id:'sh',x:'-30%',y:'-30%',width:'160%',height:'170%'},defs);
  el('feDropShadow',{dx:5,dy:9,stdDeviation:5,'flood-color':'#1F2A44','flood-opacity':.38},f);
  const f2=el('filter',{id:'sh2',x:'-20%',y:'-20%',width:'140%',height:'150%'},defs);
  el('feDropShadow',{dx:3,dy:5,stdDeviation:3,'flood-color':'#1F2A44','flood-opacity':.3},f2);
  // paper grain tile (static raster, generated deterministically)
  const cv=document.createElement('canvas');cv.width=cv.height=256;const cx=cv.getContext('2d'),r=rnd(99);
  for(let i=0;i<2600;i++){cx.fillStyle=r()<.5?'rgba(90,64,36,'+(.05+r()*.07)+')':'rgba(255,248,230,'+(.05+r()*.08)+')';cx.fillRect(r()*256,r()*256,1+r()*1.6,1+r()*1.6);}
  for(let i=0;i<70;i++){cx.strokeStyle='rgba(120,90,55,'+(.04+r()*.05)+')';cx.lineWidth=1;cx.beginPath();const x=r()*256,y=r()*256;cx.moveTo(x,y);cx.lineTo(x+(r()-.5)*26,y+(r()-.5)*26);cx.stroke();}
  const pat=el('pattern',{id:'grain',width:256,height:256,patternUnits:'userSpaceOnUse'},defs);
  el('image',{href:cv.toDataURL(),width:256,height:256},pat);
  WORLD=el('g',{},STAGE);
  for(const [n] of LAYERS)LAY[n]=el('g',{},WORLD);
  HUD=el('g',{},STAGE);
}

function camAt(t){const k=SHOT.cam&&SHOT.cam.length?track(SHOT.cam,t):{x:540,y:960,z:1};return {x:k.x??540,y:k.y??960,z:k.z??1};}
function applyCam(t){const c=camAt(t);let sx=0,sy=0;
  for(const e of (SHOT.shake||[])){if(t>=e.t&&t<=e.t+e.dur){const u=1-(t-e.t)/e.dur;sx+=Math.sin(t*90)*e.amp*u;sy+=Math.cos(t*77)*e.amp*u;}}
  for(const [n,p] of LAYERS){const k=1+(c.z-1)*p;LAY[n].setAttribute('transform',`translate(${540+sx} ${960+sy}) scale(${k}) translate(${-540-(c.x-540)*p} ${-960-(c.y-960)*p})`);}}

function buildShot(i){
  SHOT=EP.shots[i];CUR=i;for(const [n] of LAYERS)LAY[n].replaceChildren();ACT=[];PROP=[];BGTICK=null;
  const bg=BG[SHOT.bg];if(!bg)throw new Error('unknown bg '+SHOT.bg);
  BGTICK=bg(LAY,SHOT)||null;
  for(const a of SHOT.actors||[])ACT.push({a,g:G(LAY.stuff,'',{filter:'url(#sh)'})});
  for(const p of SHOT.props||[])PROP.push({p,g:G(LAY[p.layer||'stuff'],'')});
}

function lineStateAt(t){ // which spoken line is active, and how open the mouth is
  for(const id of EP.order){const L=EP.lines[id];if(t>=L.start&&t<=L.end){let inPause=false;for(const [s,e] of L.pauses)if(t>=s&&t<=e)inPause=true;
    const ph=Math.floor((t-L.start)*11);const r=rnd(ph*131+id.length*7)();return {id,speaker:L.speaker,mouth:inPause?0:(.25+.75*r)};}}
  return null;}

function drawActors(t){const ls=lineStateAt(t);
  for(const A of ACT){const k=track(A.a.keys,t);const st={t,mood:k.mood||A.a.mood||'neutral',look:[k.lx??0,k.ly??0],armL:k.armL??0,armR:k.armR??0,
      prop:k.prop??A.a.prop,speaking:ls&&ls.speaker===A.a.who,mouth:(ls&&ls.speaker===A.a.who)?ls.mouth:0,extra:k,visible:k.vis!==0,pose:k.pose||''};
    const g=A.g;g.replaceChildren();if(!st.visible)continue;
    const j=rnd(Math.floor(t*8)*17+A.a.who.length)();const jx=(j-.5)*2.4,jr=(j-.5)*1.1;
    const s=(k.s??A.a.s??1);const fl=(k.flip??A.a.flip??0)?-1:1;
    g.setAttribute('transform',`translate(${(k.x??0)+jx} ${(k.y??0)}) rotate(${(k.rot??0)+jr}) scale(${s*fl} ${s})`);
    const body=G(g,'');CHAR[A.a.who](body,st);}}

function drawProps(t){for(const P of PROP){const k=track(P.p.keys,t);const g=P.g;g.replaceChildren();if(k.vis===0)continue;
    const j=rnd(Math.floor(t*8)*13+P.p.kind.length)();const jx=P.p.still?0:(j-.5)*1.8;
    g.setAttribute('transform',`translate(${(k.x??0)+jx} ${(k.y??0)}) rotate(${k.rot??0}) scale(${(k.s??1)*((k.flip??0)?-1:1)} ${k.s??1})`);
    PROPS[P.p.kind](g,Object.assign({t},P.p,k));}}

// ---- HUD ----
function drawHUD(t){HUD.replaceChildren();
  // overlays (dim/flash) per shot
  if(SHOT.overlay){const o=track(SHOT.overlay,t);if((o.a||0)>0.001)el('rect',{width:1080,height:1920,fill:o.color||C.ink,opacity:o.a},HUD);}
  // cues
  for(const c of SHOT.cues||[]){if(t<c.t||t>c.t+c.dur)continue;const u=t-c.t;
    if(c.do==='clue')drawClue(c,u);
    if(c.do==='text')drawBigText(c,u);
    if(c.do==='notes')drawNotes(c,u);
    if(c.do==='eye'){const a=clamp(u/.3)*clamp((c.dur-u)/.3);const g=G(HUD,`translate(${c.x} ${c.y})`,{opacity:a});keyholeEye(g,0,0,c.w||140,c.col||C.must,1,0,null);}}
  // title tag (matches the ep01 title card: serif, dashed border, tape)
  const tt=0.15,te=3.9;if(t>=tt&&t<=te){const a=clamp((t-tt)/.25)*clamp((te-t)/.3);const g=G(HUD,`translate(90 190) rotate(-2.5)`,{opacity:a,filter:'url(#sh2)'});
    cut(g,rectP(0,0,540,200),C.cream,{amp:2.5,seed:3});el('rect',{x:12,y:12,width:516,height:176,fill:'none',stroke:C.creamD,'stroke-width':3,'stroke-dasharray':'12 8'},g);
    el('rect',{x:175,y:-20,width:190,height:38,fill:C.must,opacity:.95,transform:'rotate(2 270 0)'},g);
    txt(g,'LOST & FOUND LOG',270,70,32,C.navy,{serif:1,attrs:{'letter-spacing':5}});txt(g,'ENTRY '+EP.entry,270,162,84,C.tom,{serif:1,attrs:{'letter-spacing':4}});}
  // captions
  if(EP.captions){for(const id of EP.order){const L=EP.lines[id];if(t>=L.start-.05&&t<=L.end+.2){drawCaption(L,t);break;}}}
  // end card
  const ec=EP.speech_end+.35;if(t>=ec)drawEndCard(t-ec);
  // paper grain
  el('rect',{width:1080,height:1920,fill:'url(#grain)',style:'mix-blend-mode:multiply',opacity:.9},HUD);
}
const CHUNKS={};
function chunkLine(id){if(CHUNKS[id])return CHUNKS[id];const L=EP.lines[id];
  let parts=L.spoken.match(/[^.?!…]+[.?!…]*\s*/g)||[L.spoken];const out=[];
  for(let p of parts){p=p.trim();if(!p)continue;while(p.length>48){let cut=p.lastIndexOf(',',44);if(cut<12)cut=p.lastIndexOf(' ',44);out.push(p.slice(0,cut+1).trim());p=p.slice(cut+1).trim();}out.push(p);}
  // merge very short neighbours
  const m=[];for(const c of out){if(m.length&&(m[m.length-1].length+c.length)<=28)m[m.length-1]+=' '+c;else m.push(c);}
  const wts=m.map(c=>c.length+8),sum=wts.reduce((a,b)=>a+b,0);let acc=0;const spans=m.map((c,i)=>{const a=acc/sum;acc+=wts[i];return {text:c,a,b:acc/sum};});
  return CHUNKS[id]=spans;}
function drawCaption(L,t){const id=EP.order.find(i=>EP.lines[i]===L);const sp=chunkLine(id);const u=(t-L.start)/Math.max(.2,L.end-L.start);
  let ch=sp[sp.length-1];for(const c of sp){if(u<=c.b){ch=c;break;}}
  const lines=wrapText(ch.text,23);const h=lines.length*70+40;const y=1425-(lines.length-1)*35;const g=G(HUD,`translate(540 ${y})`,{filter:'url(#sh2)'});
  const w=Math.min(980,Math.max(...lines.map(s=>s.length))*30+90);
  cut(g,rectP(-w/2,-50,w,h),C.cream,{amp:2,seed:11});
  lines.forEach((s,i)=>txt(g,s,0,i*70+4,54,C.navy));
  if(L.speaker!=='narrator'){const nm={pip:'PIP',juno:'JUNO',brass:'INSPECTOR BRASS',velvet:'MADAME VELVET',fuzz:'FUZZ',cog:'PROF. COG',collector:'???'}[L.speaker]||L.speaker.toUpperCase();
    const cw=nm.length*19+40;const tg=G(g,`translate(${-w/2+20} -76) rotate(-2)`);cut(tg,rectP(0,0,cw,44),C.must,{amp:1.5,seed:5,sw:3});txt(tg,nm,cw/2,33,28,C.navy);}}
function drawBigText(c,u){const a=clamp(u/.2)*clamp((c.dur-u)/.25);const g=G(HUD,`translate(${c.x??540} ${c.y??700}) rotate(${c.rot??-3}) scale(${.9+.1*smooth(clamp(u/.25))})`,{opacity:a,filter:'url(#sh2)'});
  const w=c.w??(c.txt.length*c.size*.62+80);cut(g,rectP(-w/2,-c.size*.85,w,c.size*1.35),c.fill||C.cream,{amp:2,seed:21});txt(g,c.txt,0,0,c.size,c.color||C.navy);}
function drawNotes(c,u){const r=rnd(5);for(let i=0;i<6;i++){const s=u-i*.28;if(s<0||s>2.4)continue;const x=c.x+Math.sin(s*2+i)*40+i*22,y=c.y-s*140;
  const g=G(HUD,`translate(${x} ${y}) rotate(${Math.sin(s*3+i)*14})`,{opacity:clamp(1-s/2.4)});
  el('ellipse',{cx:0,cy:0,rx:18,ry:13,fill:c.color||C.must,transform:'rotate(-20)'},g);line(g,15,-4,15,-60,c.color||C.must,7);el('path',{d:'M15 -60 q26 8 18 34',stroke:c.color||C.must,'stroke-width':7,fill:'none','stroke-linecap':'round'},g);}}

function drawClue(c,u){const pop=smooth(clamp(u/.28)),out=clamp((c.dur-u)/.25);const sc=(.55+.45*pop)*(1+.03*Math.sin(clamp(u/.28)*Math.PI));
  const g=G(HUD,`translate(540 ${c.y??780}) rotate(${-3+(1-pop)*-8}) scale(${sc})`,{opacity:Math.min(pop*1.5,1)*out,filter:'url(#sh)'});
  cut(g,rectP(-380,-380,760,760),C.cream,{amp:3.5,step:22,seed:c.card.length+5,sw:7});
  // torn lower edge accent
  cut(g,'M-380 330 L-300 352 L-210 328 L-120 356 L-30 330 L70 354 L170 330 L270 352 L380 332 L380 380 L-380 380Z',C.creamD,{sw:0});
  CARD[c.card]?.(g,u,c);
  const lab=G(g,'translate(-130 -420) rotate(-3)');cut(lab,rectP(0,0,260,66),C.must,{amp:1.5,seed:2,sw:3});txt(lab,c.label||'CLUE',130,48,40,C.navy,{attrs:{'letter-spacing':4}});}
function drawEndCard(u){const p=smooth(clamp(u/.4));const g=G(HUD,`translate(0 ${(1-p)*-1960})`);
  cut(g,'M0 0 L1080 0 L1080 1900 L1010 1925 L940 1898 L860 1926 L780 1900 L700 1924 L620 1899 L540 1926 L460 1898 L380 1924 L300 1900 L220 1925 L140 1899 L70 1924 L0 1900Z',C.cream,{sw:0});
  keyholeEye(G(g,'translate(540 780)'),0,0,120,C.tom,1,0);
  const lines=wrapText(EP.end_card||'',16);lines.forEach((s,i)=>txt(g,s,540,1010+i*118,100,C.navy,{serif:1}));
  el('rect',{x:60,y:60,width:960,height:1780,fill:'none',stroke:C.creamD,'stroke-width':4,'stroke-dasharray':'16 10'},g);
  txt(g,'LOST & FOUND LOG',540,1560,36,C.kraftD,{serif:1,attrs:{'letter-spacing':6}});}

// keyhole-eye symbol. open: 0..1 eyelid, scratch: 1 = rough carved look
function keyholeEye(g,cx,cy,w,col,open=1,scratch=0,iris=null){const h=w*.62*clamp(open,.04,1);const G2=G(g,`translate(${cx} ${cy})`);
  const lid=`M${-w} 0 Q0 ${-h*1.7} ${w} 0 Q0 ${h*1.7} ${-w} 0Z`;
  if(iris){el('path',{d:lid,fill:iris},G2);}
  el('path',{d:lid,fill:iris?'none':'none',stroke:col,'stroke-width':scratch?w*.075:w*.09,'stroke-linejoin':'round','stroke-linecap':'round'},G2);
  if(open>.2){const r=w*.36;if(iris)el('circle',{r,fill:C.must,stroke:col,'stroke-width':w*.05},G2);
    el('circle',{cx:0,cy:-r*.18,r:r*.42,fill:col},G2);el('path',{d:`M${-r*.2} ${r*.1} L${-r*.34} ${r*.78} L${r*.34} ${r*.78} L${r*.2} ${r*.1}Z`,fill:col},G2);}
  return G2;}

// ---- main seek ----
function seek(t){
  let idx=EP.shots.findIndex((s,i)=>t>=s.t0&&(t<s.t1||i===EP.shots.length-1));if(idx<0)idx=0;
  if(idx!==CUR)buildShot(idx);
  applyCam(t);if(BGTICK)BGTICK(t);drawActors(t);drawProps(t);drawHUD(t);
}
window.seek=seek;
