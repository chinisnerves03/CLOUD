// Backgrounds (parallax layers), props, clue cards. All flat paper shapes, no gradients.
const BG={};
let CLIPN=0;
function R(x,y,w,h,fill,g,o){return cut(g,rectP(x,y,w,h),fill,Object.assign({sw:0,amp:2,step:30,seed:(x*7+y*3)|0},o||{}));}
function grainLines(g,x0,x1,y0,y1,n,col,op,seed){const r=rnd(seed);for(let i=0;i<n;i++){const y=y0+r()*(y1-y0),x=x0+r()*(x1-x0);el('path',{d:`M${x} ${y} q${60+r()*80} ${(r()-.5)*14} ${160+r()*200} ${(r()-.5)*8}`,stroke:col,'stroke-width':2+r()*2,fill:'none',opacity:op,'stroke-linecap':'round'},g);}}
function striped(g,cx,cy,rx,ry,c1,c2,seed,tilt=0){const id='cp'+(CLIPN++);const cp=el('clipPath',{id},g);el('path',{d:jag(ell(cx,cy,rx,ry,24),5,18,seed)},cp);
  const body=G(g,'');cut(body,ell(cx,cy,rx,ry,24),c1,{amp:5,step:18,seed,sw:5});const s=G(body,'',{'clip-path':`url(#${id})`});
  for(let k=-3;k<=3;k++)el('rect',{x:cx-rx-10,y:cy+k*ry*.5-ry*.12,width:rx*2+20,height:ry*.24,fill:c2,transform:`rotate(${tilt} ${cx} ${cy})`},s);}
function fogBand(g,y,op,seed,col=C.cream){const r=rnd(seed);const p=[];for(let x=-300;x<1500;x+=150)p.push([x,y+(r()-.5)*40]);for(let x=1500;x>=-300;x-=150)p.push([x,y+110+(r()-.5)*40]);return cut(g,p,col,{sw:0,amp:12,step:40,seed,op});}
function footprint(g,x,y,rot,col,op){const f=G(g,`translate(${x} ${y}) rotate(${rot})`,{opacity:op});el('ellipse',{cx:0,cy:0,rx:15,ry:26,fill:col},f);for(let i=-2;i<=2;i++)el('ellipse',{cx:i*8,cy:-34-Math.abs(i)*-3,rx:4.4,ry:6,fill:col},f);}

// --- Plaza wall: floor, wall, and the underside of a shelf up top with dusty footprints ---
BG.plaza_wall=function(L){
  R(-700,-1500,2500,3400,C.kraftD,L.far);grainLines(L.far,-600,1700,-1300,1500,60,C.kraft,.35,3);
  const M=L.main;
  R(-700,-1500,2500,1780,C.navy,M);                                          // shelf underside (ceiling) ends at y=280 (world)
  R(-700,240,2500,40,C.ink,M,{seed:5});
  grainLines(M,-600,1700,-1400,220,26,'#2d3a5c',.8,4);
  const r=rnd(8);for(let i=0;i<13;i++){const x=-120+i*120+(r()-.5)*10,y=120+(i%2?44:-10)+Math.sin(i*.7)*22;bootprint(M,x,y,90+(r()-.5)*10,C.creamD,.8);}
  R(-700,280,2500,980,C.kraft,M,{seed:9});grainLines(M,-600,1700,300,1240,70,C.kraftD,.5,12);
  for(let x=-200;x<1500;x+=270)el('rect',{x,y:280,width:5,height:980,fill:C.kraftD,opacity:.45},M);
  R(-700,1200,2500,70,C.kraftD,M,{seed:3});
  R(-700,1260,2500,700,C.cream,M,{seed:4});
  for(let x=-260;x<1500;x+=320)cut(M,ell(x,1310,70,14,14),C.creamD,{sw:0});
  keyholeEye(G(M,'translate(150 790)'),0,0,34,C.kraftD,1,1);              // hidden scratched eye
  el('path',{d:'M900 280 q-8 130 6 260 q14 120 -4 240',stroke:C.must,'stroke-width':4,fill:'none',opacity:.9},M);
  for(let i=0;i<6;i++)el('circle',{cx:905,cy:320+i*80,r:3.5,fill:'#FFF3B0'},M);
  const Q=L.mid;
  for(const x of [140,860]){line(Q,x,400,x,900,C.navy,8);cut(Q,ell(x,380,26,26,12),C.must,{seed:x,sw:4});}
  el('path',{d:'M-100 460 Q540 580 1180 460',stroke:C.navy,'stroke-width':4,fill:'none'},Q);
  [C.tom,C.teal,C.must,C.tom,C.teal,C.must,C.tom].forEach((c,i)=>{const x=60+i*160;cut(Q,[[x,500],[x+54,512],[x+22,572]],c,{sw:3,seed:i});});
  const F=L.front;
  cut(F,rectP(-80,1640,260,56),C.kraftL,{seed:6});cut(F,rectP(-60,1696,220,200),C.teal,{seed:7});cut(F,rectP(-80,1860,260,40),C.kraftL,{seed:8});
  cut(F,ell(900,1790,230,24,18),C.tom,{sw:0,seed:2});cut(F,ell(560,1900,380,30,18),C.kraftL,{sw:0,seed:3});
};
function bootprint(g,x,y,rot,col,op){const f=G(g,`translate(${x} ${y}) rotate(${rot}) scale(1.35)`,{opacity:op});
  el('path',{d:'M-13 -34 q16 -10 26 2 q8 16 2 40 q-4 12 -14 12 q-10 0 -14 -12 q-6 -24 0 -42Z',fill:col},f);el('ellipse',{cx:0,cy:46,rx:11,ry:9,fill:col},f);}
// --- Brass's desk, seen from above ---
BG.desk=function(L){
  R(-800,-800,2700,3600,C.kraftD,L.far);
  R(-700,-700,2500,3300,C.kraft,L.main);grainLines(L.main,-600,1700,-600,2500,120,C.kraftD,.55,21);
  for(let i=0;i<260;i++){const r=rnd(i+400);el('circle',{cx:-500+r()*2200,cy:-300+r()*2400,r:1.5+r()*3.5,fill:C.creamD,opacity:.5+r()*.4},L.main);}
  // clean rectangle where the badge lay (dust wiped off)
  cut(L.main,rectP(330,820,420,300),C.kraftD,{amp:2,seed:5,sw:0});
  cut(L.main,rectP(346,836,388,268),C.kraft,{amp:2,seed:6,sw:0});
  // desk clutter: pencil stub, ink bottle, 'CASE CLOSED' stamp
  const m=L.mid;cut(m,[[60,300],[420,330],[420,352],[60,324]],C.must,{seed:3,sw:4});cut(m,[[420,330],[470,341],[420,352]],C.cream,{sw:3,seed:4});
  cut(m,ell(120,1500,70,70,16),C.navy,{seed:5});cut(m,rectP(90,1400,60,40),C.ink,{seed:6});
  const st=G(m,'translate(880 1560) rotate(-8)');cut(st,rectP(-120,-70,240,140),C.tom,{seed:7});txt(st,'CASE',0,-6,44,C.cream);txt(st,'CLOSED!',0,40,44,C.cream);cut(st,rectP(-30,-130,60,60),C.kraftD,{seed:8});
  return t=>{};
};
// --- Tin Lounge ---
BG.lounge=function(L,shot){const dark=shot.bgopts&&shot.bgopts.dark;
  R(-700,-600,2500,3200,C.ink,L.far);
  cut(L.far,ell(540,700,760,900,36),C.navy,{sw:0,amp:6});
  cut(L.mid,ell(540,1520,720,150,30),C.kraftD,{sw:5,seed:3}); // stage lid
  cut(L.mid,ell(540,1480,660,120,30),C.kraft,{sw:0,seed:4});
  R(-700,1580,2500,500,C.tomD,L.main,{seed:5});
  for(const sx of [-1,1]){const x0=sx<0?-80:880;cut(L.main,[[x0,-120],[x0+280,-120],[x0+240,1500],[x0+20,1560]],C.tom,{seed:sx+5,sw:5});
    for(let k=1;k<5;k++)line(L.main,x0+k*52,-80,x0+k*44,1500,C.tomD,5,{opacity:.55});}
  cut(L.main,[[330,-60],[750,-60],[1000,1500],[80,1500]],C.cream,{sw:0,op:dark?.08:.2}); // spotlight
  // bottle-cap booths + audience
  [[120,1700,C.teal],[960,1710,C.tom],[540,1790,C.must]].forEach(([x,y,c],i)=>{cut(L.front,ell(x,y,150,46,22),c,{seed:i+9});cut(L.front,ell(x,y,115,28,22),'#00000022',{sw:0});
    cut(L.front,ell(x,y-70,34,40,14),C.ink,{sw:0});cut(L.front,ell(x+60,y-56,30,36,14),C.ink,{sw:0});});
  keyholeEye(G(L.far,'translate(930 420)'),0,0,44,C.navy,1,1);  // hidden symbol on the tin wall
  if(dark)R(-700,-600,2500,3200,C.ink,L.front,{sw:0,op:.45});
};
// --- Sock Marsh ---
BG.marsh=function(L,shot){const o=shot.bgopts||{};const r=rnd(33);
  R(-700,-600,2700,3200,C.navy,L.far);cut(L.far,ell(540,500,900,300,30),C.teal,{sw:0,op:.35,amp:8});cut(L.far,ell(780,330,150,150,30),C.cream,{sw:0,op:.16,amp:5});
  for(let i=0;i<30;i++){const q=rnd(900+i);el('circle',{cx:-300+q()*1800,cy:-300+q()*1200,r:2+q()*3,fill:C.cream,opacity:.25+q()*.3},L.far);}
  for(const x of [160,420,980]){line(L.far,x,-400,x,260+x%140,C.cream,2.5,{opacity:.35});}
  const cols=[[C.tom,C.cream],[C.teal,C.must],[C.must,C.navy],[C.cream,C.tom],[C.navy,C.teal]];
  for(let i=0;i<9;i++){const c=cols[i%5];striped(L.far,-100+i*200+r()*40,1050+r()*80,150+r()*50,100+r()*40,c[0],c[1],40+i,r()*20-10);}
  fogBand(L.far,1050,.5,3);
  for(let i=0;i<7;i++){const c=cols[(i+2)%5];striped(L.mid,-60+i*230+r()*60,1380+r()*40,190+r()*50,120+r()*30,c[0],c[1],60+i,r()*16-8);}
  fogBand(L.mid,1330,.45,5);
  if(o.building){const g=G(L.mid,'translate(640 900)');cut(g,rectP(-300,-60,600,380),C.kraft,{seed:3,sw:6});cut(g,[[-330,-60],[330,-60],[300,-130],[-290,-120]],C.kraftD,{seed:4});
    cut(g,rectP(-60,100,120,220),C.ink,{seed:5,sw:4});cut(g,ell(-190,40,20,20,12),C.must,{seed:6});cut(g,ell(190,40,20,20,12),C.must,{seed:7});
    keyholeEye(G(g,'translate(0 -10)'),0,0,36,C.navy,1,1);}
  R(-700,1480,2700,700,C.tealD,L.main,{seed:8});grainLines(L.main,-600,1700,1500,2000,60,C.teal,.5,9);
  for(let i=0;i<14;i++){const x=-80+i*130+(i%2)*30,y=1560+(i%3)*8;cut(L.main,ell(x,y,52,19,18),C.must,{seed:i,sw:4});cut(L.main,ell(x,y,34,11,16),C.mustD,{sw:0});}
  for(const [x,y,c,s] of [[60,1500,C.tom,1],[980,1480,C.kraft,1.1],[880,1540,C.teal,.8]]){const g=G(L.main,`translate(${x} ${y}) scale(${s})`);
    cut(g,[[-30,0],[30,0],[34,-90],[-34,-90]],c,{seed:x});for(let f=0;f<4;f++)cut(g,[[-34+f*20,-90],[-20+f*20,-90],[-16+f*20,-170-(f%2)*18],[-36+f*20,-168]],c,{seed:x+f,sw:3});}
  fogBand(L.front,1650,.32,7);
  return t=>{L.far.setAttribute('opacity','1');L.front.setAttribute('transform',L.front.getAttribute('transform')+` translate(${Math.sin(t*.5)*30} 0)`);};
};
// --- Warehouse interior: shelves sorted by colour, each item tagged with the keyhole eye ---
BG.warehouse_int=function(L,shot){
  R(-700,-600,2700,3200,C.ink,L.far);R(-700,-400,2700,2800,C.navy,L.mid);R(-700,1530,2700,700,C.kraftD,L.front,{seed:3});
  const rows=[[C.tom,520],[C.must,820],[C.teal,1120],[C.cream,1420]];const r=rnd(5);
  rows.forEach(([col,y],ri)=>{R(-200,y+110,1500,36,C.kraftD,L.main,{seed:ri});
    for(let i=0;i<9;i++){const x=-110+i*135+r()*20,kind=i%3;const h=70+r()*50;
      if(kind===0)cut(L.main,ell(x,y+110-42,42,42,16),col,{seed:ri*9+i});else if(kind===1)cut(L.main,rectP(x-34,y+110-h,68,h),col,{seed:ri*9+i});else cut(L.main,[[x-40,y+108],[x+40,y+108],[x,y+110-h]],col,{seed:ri*9+i});
      cut(L.main,rectP(x-14,y+110-44,28,26),C.sticker,{sw:0,amp:.8});keyholeEye(G(L.main,`translate(${x} ${y+110-31})`),0,0,10,C.ink,1,0);}});
  for(const x of [-60,1140])R(x,-400,30,2600,C.kraftD,L.main,{seed:x});
  cut(L.mid,ell(540,100,70,70,16),C.must,{sw:6,seed:4});line(L.mid,540,-300,540,40,C.kraftD,6);
  cut(L.mid,[[300,160],[780,160],[1000,1900],[80,1900]],C.cream,{sw:0,op:shot.bgopts&&shot.bgopts.light===0?0:.08});
};
// ---------------- props ----------------
PROPS.glider=function(g,p){const tl=p.tilt??0;const a=G(g,`rotate(${tl})`);cut(a,[[-120,10],[120,-6],[-30,40]],C.cream,{seed:2});cut(a,[[-120,10],[120,-6],[-30,-22]],C.creamD,{seed:3,sw:4});line(a,-120,10,120,-6,C.kraftD,3);
  const r=a.ownerDocument;};
PROPS.strand=function(g,p){const s=p.sparkle??1;el('path',{d:'M-90 0 q30 -60 60 -10 t60 0 t60 -10 t60 10',stroke:'#F4E6C0','stroke-width':6,fill:'none','stroke-linecap':'round'},g);
  for(let i=0;i<9;i++){const x=-80+i*25;el('circle',{cx:x,cy:-12*Math.sin(i*1.2)-2,r:3.4,fill:C.must},g);}
  for(let i=0;i<4;i++){const q=(p.t*2+i*.25)%1;el('circle',{cx:-60+i*52,cy:-40-q*24,r:4*(1-q)*s,fill:'#FFF3B0',opacity:1-q},g);}};
PROPS.eyemark=function(g,p){const o=p.open??1;keyholeEye(g,0,0,p.w??120,o<.3?C.kraftD:(p.col||C.ink),o,1,p.iris?C.cream:null);};
PROPS.coin=function(g,p){cut(g,ell(0,p.sink??0,54,20,18),C.must,{sw:4,seed:2});cut(g,ell(0,p.sink??0,36,12,16),C.mustD,{sw:0});};
PROPS.redbutton=function(g,p){const s=p.size??1;cut(g,ell(0,0,120*s,120*s,30),C.tom,{seed:5,sw:6});cut(g,ell(0,0,92*s,92*s,28),C.tomD,{sw:0});
  for(const [x,y] of [[-22,-22],[22,-22],[-22,22],[22,22]])cut(g,ell(x*s,y*s,9*s,9*s,10),C.ink,{sw:0});};
PROPS.tag=function(g,p){line(g,0,-60,0,0,C.kraftD,3);cut(g,rectP(-70,0,140,66),C.cream,{seed:2,sw:4});txt(g,p.label||'LOT 17',0,45,34,C.navy);};
PROPS.stucksock=function(g,p){cut(g,'M-50 40 q-10 -80 10 -130 q60 -10 90 10 q10 60 -4 120Z',C.tom,{seed:3,sw:5});
  for(const y of [-60,-20,20])el('rect',{x:-48,y,width:96,height:14,fill:C.cream,opacity:.9,transform:'rotate(-6)'},g);
  cut(g,[[-10,-90],[100,-190],[40,-70]],C.cream,{seed:4,sw:4});};
PROPS.crumb=function(g,p){cut(g,ell(0,0,10,8,8),C.kraftD,{sw:2,amp:1});};
PROPS.fluffpuff=function(g,p){for(let i=0;i<8;i++){const q=((p.t*.9)+i/8)%1;el('circle',{cx:Math.sin(i*2+q*3)*30,cy:-q*90,r:7*(1-q),fill:C.cream,opacity:1-q},g);}};
PROPS.musicbox=function(g,p){cut(g,rectP(-46,-28,92,56),C.kraft,{seed:3});cut(g,rectP(-52,-40,104,20),C.kraftD,{seed:4,sw:4});line(g,46,0,68,-18,C.must,6);};
PROPS.pole=function(g,p){line(g,0,-250,0,0,C.silverD,10);cut(g,ell(0,-250,70,18,18),C.silver,{seed:2,sw:4});cut(g,ell(0,0,50,12,16),C.silverD,{sw:3});};
PROPS.dim=function(g,p){};
// ---------------- clue cards ----------------
CARD.keyhole=function(g,u,c){cut(g,rectP(-330,-300,660,560),'#8E8576',{seed:3,amp:3,sw:0});grainLines(g,-320,320,-290,250,40,'#7A7164',.6,2);grainLines(g,-320,320,-290,250,20,'#A39A8A',.6,3);
  const e=G(g,'translate(0 -20)');keyholeEye(e,3,5,200,'#4E473D',1,1);keyholeEye(e,0,0,200,'#2B261F',1,1);
  txt(g,'scratched into the plinth',0,310,34,C.navy,{w:600});};
CARD.gold_thread=function(g,u,c){cut(g,rectP(-330,-300,660,560),C.navy,{seed:4,amp:3,sw:0});
  for(let k=0;k<5;k++)el('path',{d:`M-300 ${-120+k*34} q70 -90 140 -10 t140 0 t140 0 t120 -10`,stroke:k%2?'#F4E6C0':'#E8D9A8','stroke-width':6-k*.6,fill:'none','stroke-linecap':'round',opacity:.95},g);
  const r=rnd(7);for(let i=0;i<26;i++)el('circle',{cx:-300+r()*600,cy:-150+r()*330,r:2.5+r()*3.5,fill:C.must,opacity:.85},g);
  for(let i=0;i<5;i++){const q=(u*1.4+i*.2)%1;el('circle',{cx:-200+i*120,cy:40-q*60,r:5*(1-q),fill:'#FFF3B0',opacity:1-q},g);}
  txt(g,'silk, fine as breath, flecked with gold',0,310,30,C.navy,{w:600});};
CARD.seal=function(g,u,c){cut(g,rectP(-330,-300,660,560),C.kraftL,{seed:5,amp:3,sw:0});
  for(let k=0;k<5;k++)line(g,-280,-180+k*46,280,-180+k*46,C.kraft,3,{opacity:.7});
  cut(g,ell(0,-20,130,126,26),C.tom,{seed:3,amp:7,sw:0});cut(g,ell(0,-20,96,92,26),C.tomD,{seed:4,amp:3,sw:0});
  keyholeEye(G(g,'translate(0 -18)'),0,0,70,C.cream,1,1);
  txt(g,'the seal on the letter',0,310,34,C.navy,{w:600});};
CARD.ledger=function(g,u,c){cut(g,rectP(-330,-300,660,560),'#EFE3C4',{seed:6,amp:3,sw:0});for(let k=0;k<9;k++)line(g,-300,-230+k*52,300,-230+k*52,'#9DB4C0',2.5);line(g,-230,-300,-230,250,C.tom,3);
  txt(G(g,'translate(30 -90) rotate(-4)'),'Collection',0,0,92,C.navy,{w:700});txt(G(g,'translate(30 40) rotate(-4)'),'17 of 400',0,0,112,C.tom,{w:800});
  txt(g,'ledger page, Sock Marsh warehouse',0,310,30,C.navy,{w:600});};
