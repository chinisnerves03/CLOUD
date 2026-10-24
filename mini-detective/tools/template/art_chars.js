// Paper cut-out characters. Origin = centre of feet, y up is negative. Each draws one frame from state st.
function limb(g,sx,sy,ang,len,w,fill,hand,o={}){const a=G(g,`translate(${sx} ${sy}) rotate(${ang})`);
  cut(a,[[-w/2,-4],[w/2,-4],[w/2*.8,len],[-w/2*.8,len]],fill,{amp:1.4,step:14,seed:o.seed||3});
  if(hand)cut(a,ell(0,len+6,w*.62,w*.62,14),hand,{amp:1,seed:2,sw:4});return a;}
function brow(g,x,y,rot,col,w=24,th=7){line(G(g,`translate(${x} ${y}) rotate(${rot})`),-w/2,0,w/2,0,col,th);}
function mouthShape(g,x,y,st,w=15,col=C.ink){
  if(st.mouth>.04||st.mood==='shout'||st.mood==='surprised'){const open=Math.max(st.mouth,st.mood==='shout'?.9:st.mood==='surprised'?.55:0);
    cut(g,ell(x,y+4,w*(st.mood==='surprised'?.7:1),4+open*14,16),col,{sw:0,amp:.6});
    if(open>.35)cut(g,ell(x,y+4+open*8,w*.55,open*5,10),C.tom,{sw:0,amp:.4});return;}
  const m=st.mood;let d;
  if(m==='worried')d=`M${x-w} ${y+4} q${w*.5} -8 ${w} -2 q${w*.5} -6 ${w} 2`;
  else if(m==='smirk')d=`M${x-w} ${y+4} q${w} 6 ${w*1.6} -6`;
  else if(m==='determined')d=`M${x-w*.8} ${y+4} l${w*1.6} 0`;
  else if(m==='whisper')d=`M${x-w*.4} ${y+4} q${w*.4} 3 ${w*.8} 0`;
  else d=`M${x-w*.8} ${y+2} q${w*.8} 9 ${w*1.6} 0`;
  el('path',{d,stroke:col,'stroke-width':6,fill:'none','stroke-linecap':'round'},g);}
function eyes(g,x,y,st,gap=27,col=C.ink){const big=st.mood==='surprised'?1.35:1;const lx=st.look[0]*5,ly=st.look[1]*4;
  const blink=(Math.floor(st.t*10)%37===0);
  for(const sx of [-1,1]){if(blink){line(g,sx*gap-9,y,sx*gap+9,y,col,5);continue;}
    el('ellipse',{cx:sx*gap+x,cy:y,rx:13*big,ry:15*big,fill:'#fff'},g);cut(g,ell(sx*gap+x+lx,y+ly,8*big,8.5*big,12),col,{sw:0,amp:.3});el('circle',{cx:sx*gap+x+lx+2.5,cy:y+ly-3,r:2.8,fill:'#fff'},g);}}
function brows(g,x,y,st,gap=27,col=C.ink){const m=st.mood;
  const T={neutral:[0,0,0,0],curious:[-7,-8,0,0],surprised:[0,-12,0,-12],worried:[12,-3,-12,-3],determined:[-13,2,13,2],smirk:[0,0,-6,-9],shout:[-14,3,14,3],whisper:[0,-2,0,-2]}[m]||[0,0,0,0];
  brow(g,x-gap,y+T[1],T[0],col);brow(g,x+gap,y+T[3],T[2],col);}

const CHAR={};
// ---------- PIP ----------
CHAR.pip=function(g,st){const b=Math.sin(st.t*2.4)*2.5;
  cut(g,rectP(-42,-110,30,110),C.navy,{seed:1});cut(g,rectP(12,-110,30,110),C.navy,{seed:2});
  cut(g,ell(-30,-6,28,13),C.kraftD,{seed:3});cut(g,ell(34,-6,28,13),C.kraftD,{seed:4});
  const t=G(g,`translate(0 ${b})`);
  // far arm (right of viewer): holds lens or points
  limb(t,62,-245,-(st.armR||8),96,34,C.kraftD,C.skin,{seed:5});
  cut(t,[[-64,-258],[64,-258],[96,-72],[-96,-72]],C.kraft,{seed:6});
  for(const [x1,y1,x2,y2] of [[-60,-210,60,-208],[-72,-160,74,-158],[-84,-110,86,-108],[-26,-250,-34,-80],[30,-250,40,-80]])line(t,x1,y1,x2,y2,'#6F93A9',2.4,{opacity:.55});
  cut(t,[[-14,-258],[14,-258],[24,-170],[0,-160],[-24,-170]],C.tom,{seed:8,sw:3}); // red thread tie
  cut(t,[[-30,-262],[0,-232],[-8,-258]],C.cream,{sw:0});cut(t,[[30,-262],[0,-232],[8,-258]],C.cream,{sw:0});
  // near arm
  const arm=limb(t,-62,-245,(st.armL||8),96,34,C.kraft,C.skin,{seed:9});
  if(st.prop==='lens'||st.prop==='tweezers'){const h=G(arm,`translate(0 106) rotate(${st.prop==='lens'?-20:25})`);
    if(st.prop==='lens'){line(h,0,0,0,-50,C.kraftD,7);el('circle',{cx:0,cy:-82,r:38,fill:C.cream,opacity:.75,stroke:C.must,'stroke-width':9},h);line(h,-14,-96,6,-100,'#fff',4,{opacity:.8});}
    else{line(h,-4,0,-8,-90,C.silverD,6);line(h,6,0,10,-90,C.silverD,6);}}
  // head
  const hd=G(t,`translate(0 -330) rotate(${Math.sin(st.t*1.7)*1.2})`);
  cut(hd,ell(-78,6,13,18,10),C.skin,{seed:12,sw:4});cut(hd,ell(78,6,13,18,10),C.skin,{seed:13,sw:4});
  cut(hd,ell(0,0,80,74,30),C.skin,{seed:14});
  cut(hd,[[-82,-14],[-62,-60],[-20,-76],[40,-70],[80,-24],[84,-8],[62,-24],[20,-34],[-30,-26],[-70,-4]],C.ink,{seed:15,sw:4});
  cut(hd,[[-84,-20],[-100,-2],[-80,10]],C.ink,{seed:16,sw:3});
  // thimble hat
  cut(hd,[[-52,-52],[52,-52],[44,-112],[0,-126],[-44,-112]],C.silver,{seed:17});
  for(let r=0;r<3;r++)for(let c=0;c<5-r;c++)el('circle',{cx:-26+c*13+r*6.5,cy:-104+r*17,r:3.2,fill:C.silverD},hd);
  cut(hd,rectP(-62,-56,124,16),C.silverD,{seed:18,amp:1.2,sw:4});
  eyes(hd,0,-6,st);brows(hd,0,-30,st);
  el('circle',{cx:-48,cy:22,r:9,fill:C.tom,opacity:.18},hd);el('circle',{cx:48,cy:22,r:9,fill:C.tom,opacity:.18},hd);
  mouthShape(hd,0,34,st);
};
// ---------- JUNO ----------
CHAR.juno=function(g,st){const b=Math.sin(st.t*3.1)*2;
  cut(g,[[-30,-130],[-6,-130],[-12,0],[-34,0]],C.navy,{seed:1});cut(g,[[6,-130],[30,-130],[34,0],[12,0]],C.navy,{seed:2});
  cut(g,ell(-26,-5,30,11),C.tealD,{seed:3});cut(g,ell(30,-5,30,11),C.tealD,{seed:4});
  const t=G(g,`translate(0 ${b})`);
  limb(t,48,-285,-(st.armR||14),112,24,C.navy,C.skin,{seed:5});
  // scarf tail waving
  const w=Math.sin(st.t*5)*10;
  cut(t,`M-10 -300 q70 ${20+w} 140 ${60+w*1.5} l-20 34 q-60 ${-30+w} -120 -64Z`,C.tom,{seed:6,sw:4});
  cut(t,[[-50,-300],[50,-300],[40,-120],[-40,-120]],C.teal,{seed:7}); // jacket
  cut(t,[[-50,-300],[-10,-300],[-30,-260]],C.tealD,{sw:0});cut(t,[[10,-300],[50,-300],[30,-260]],C.tealD,{sw:0});
  cut(t,[[-62,-215],[-8,-195],[18,-130],[-46,-118]],C.cream,{seed:8,sw:4}); // envelope bag
  line(t,-58,-212,-24,-185,C.kraftD,3);line(t,-4,-197,-24,-185,C.kraftD,3);
  cut(t,ell(0,-300,38,16,12),C.tom,{seed:9,sw:4});
  const arm=limb(t,-48,-285,(st.armL||14),112,24,C.teal,C.skin,{seed:10});
  const hd=G(t,`translate(0 -366) rotate(${Math.sin(st.t*2.1)*1.5})`);
  cut(hd,ell(0,0,56,62,28),C.skin,{seed:11});
  cut(hd,[[-60,-6],[-52,-52],[0,-66],[52,-52],[60,-6],[46,-30],[0,-40],[-46,-30]],C.teal,{seed:12,sw:4}); // cap
  cut(hd,[[-60,-6],[-84,10],[-58,18]],C.teal,{sw:3,seed:2});cut(hd,[[60,-6],[84,10],[58,18]],C.teal,{sw:3,seed:3});
  for(const sx of [-1,1]){cut(hd,ell(sx*20,-36,17,17,12),C.must,{sw:3,seed:4});cut(hd,ell(sx*20,-36,10,10,10),C.cream,{sw:0});}
  eyes(hd,0,0,st,19);brows(hd,0,-20,st,19);
  mouthShape(hd,0,28,st,12);};
// ---------- BRASS ----------
CHAR.brass=function(g,st){const b=Math.sin(st.t*2)*1.5;
  cut(g,rectP(-52,-70,46,70),C.navy,{seed:1});cut(g,rectP(6,-70,46,70),C.navy,{seed:2});
  cut(g,ell(-30,-6,36,14),C.ink,{seed:3});cut(g,ell(32,-6,36,14),C.ink,{seed:4});
  const t=G(g,`translate(0 ${b})`);
  const pat=st.extra.pat?Math.sin(st.t*14)*14:0;
  limb(t,100,-215,-(st.armR||10),86,44,C.navy,C.skin,{seed:5});
  cut(t,[[-100,-250],[100,-250],[118,-60],[-118,-60]],C.navy,{seed:6});
  for(const y of [-215,-170,-125])el('circle',{cx:0,cy:y,r:8,fill:C.must},t);
  if(st.extra.badge!==0){cut(t,ell(-52,-200,22,22,14),C.must,{seed:7,sw:3});cut(t,ell(-52,-200,11,11,10),C.mustD,{sw:0});}
  else cut(t,ell(-52,-200,19,19,12),C.navy,{sw:0,op:.7});
  limb(t,-100,-215,(st.armL||10)+pat,86,44,C.navy,C.skin,{seed:8});
  const hd=G(t,`translate(0 -300) rotate(${Math.sin(st.t*1.3)*1})`);
  cut(hd,ell(0,0,70,60,28),C.skin,{seed:9});
  cut(hd,ell(0,-52,74,48,26),C.must,{seed:10});cut(hd,rectP(-76,-30,152,14),C.mustD,{seed:11,sw:4}); // key-head helmet
  cut(hd,ell(0,-76,14,14,12),C.navy,{sw:0});
  eyes(hd,0,-6,st,24);brows(hd,0,-26,st,24);
  cut(hd,[[-52,16],[-20,6],[0,12],[20,6],[52,16],[40,34],[0,24],[-40,34]],C.kraftD,{seed:12,sw:4}); // bristle moustache
  mouthShape(hd,0,44,st,13);};
// ---------- VELVET ----------
CHAR.velvet=function(g,st){const sway=Math.sin(st.t*1.6)*4;
  const t=G(g,`rotate(${sway*.3})`);
  cut(t,[[-46,-330],[46,-330],[110,0],[-110,0]],C.tom,{seed:1});
  for(const x of [-60,-30,0,30,60])line(t,x*.5,-320,x*1.5,-6,C.tomD,3,{opacity:.6});
  cut(t,[[-46,-330],[46,-330],[34,-300],[-34,-300]],C.cream,{seed:2,sw:3,op:.0});
  limb(t,48,-318,-((st.armR||20)+(st.extra.trem?Math.sin(st.t*55)*5:0)),120,22,C.tom,C.skin,{seed:3});
  limb(t,-48,-318,(st.armL||20),120,22,C.tomD,C.skin,{seed:4});
  if(st.prop==='musicbox'){const m=G(t,'translate(0 -150)');cut(m,rectP(-34,-22,68,44),C.kraft,{seed:5});line(m,34,-6,52,-20,C.must,5);}
  const hd=G(t,`translate(0 -388) rotate(${Math.sin(st.t*1.2)*1.2})`);
  cut(hd,ell(0,-8,60,70,26),C.ink,{seed:7});                       // back hair
  cut(hd,ell(0,6,46,54,26),C.skin,{seed:6});                       // face
  cut(hd,[[-52,-20],[-40,-58],[0,-72],[40,-58],[52,-20],[30,-40],[0,-34],[-30,-40]],C.ink,{seed:8,sw:3}); // fringe
  for(let i=0;i<4;i++){const cx=-24+i*16;el('ellipse',{cx,cy:-84-Math.sin(i*1.4)*8,rx:11,ry:20,fill:'none',stroke:C.silver,'stroke-width':5,transform:`rotate(${(i-1.5)*14} ${cx} -84)`},hd);} // coiled-spring swirl
  for(const sx of [-1,1]){el('circle',{cx:sx*48,cy:22,r:7,fill:C.must,stroke:C.sticker,'stroke-width':2},hd);el('line',{x1:sx*48,y1:12,x2:sx*48,y2:4,stroke:C.mustD,'stroke-width':2},hd);}
  eyes(hd,0,0,st,17);brows(hd,0,-16,st,17);mouthShape(hd,0,26,st,11,C.tomD);};
// ---------- FUZZ ----------
CHAR.fuzz=function(g,st){const f=Math.sin(st.t*2.3)*8;const t=G(g,`translate(0 ${-130+f})`);
  const grays=['#9AA0A6','#B8BCC0','#D3D5D8','#AEB3B8'];
  const bl=[[-90,0,80,70],[80,6,86,72],[0,-50,100,80],[-60,-70,60,50],[56,-76,64,52],[0,40,110,60],[-100,40,56,40],[100,44,56,40]];
  bl.forEach((b,i)=>cut(t,ell(b[0],b[1]+Math.sin(st.t*3+i)*2,b[2],b[3],18),grays[i%4],{seed:20+i,amp:7,step:14,sw:4}));
  for(const sx of [-1,1]){const e=G(t,`translate(${sx*34} -14)`);el('circle',{r:19,fill:C.ink,stroke:C.cream,'stroke-width':4},e);el('circle',{cx:-5,cy:-4,r:3,fill:C.cream},e);el('circle',{cx:5,cy:-4,r:3,fill:C.cream},e);
    const lx=st.look[0]*4;el('circle',{cx:lx+7,cy:-8,r:3,fill:'#fff'},e);}
  const m=st.mood;const mw=st.mouth>.05?`M-26 30 q26 ${14+st.mouth*18} 52 0`:(m==='sly'?'M-30 28 q20 14 56 -10':'M-26 28 q26 12 52 0');
  el('path',{d:mw,stroke:C.ink,'stroke-width':5,fill:'none','stroke-linecap':'round'},t);
  for(let i=-3;i<=3;i++)line(t,i*8-3,26,i*8+3,36,C.ink,3);
  // shedding fluff
  for(let i=0;i<6;i++){const s=(st.t*.5+i/6)%1;el('circle',{cx:-120+i*48+Math.sin(s*6+i)*18,cy:70+s*140,r:6-s*4,fill:C.cream,opacity:1-s},t);}};
// ---------- COG (basic) ----------
CHAR.cog=function(g,st){const t=G(g,`rotate(${Math.sin(st.t*3)*1.2})`);
  cut(t,rectP(-34,-130,26,130),C.navy,{seed:1});cut(t,rectP(8,-130,26,130),C.navy,{seed:2});
  cut(t,[[-54,-340],[54,-340],[70,-120],[-70,-120]],C.kraftL,{seed:3});cut(t,[[-40,-260],[40,-260],[44,-130],[-44,-130]],C.cream,{seed:4,sw:3});
  limb(t,58,-320,-(st.armR||12),120,24,C.kraftL,C.skin,{seed:5});limb(t,-58,-320,(st.armL||12),120,24,C.kraftL,C.skin,{seed:6});
  const hd=G(t,`translate(0 -400)`);cut(hd,ell(0,-30,86,78,18),C.cream,{amp:9,seed:7,sw:4});cut(hd,ell(0,0,50,60,24),C.skin,{seed:8});
  for(const sx of [-1,1]){el('circle',{cx:sx*22,cy:-4,r:19,fill:'none',stroke:C.silverD,'stroke-width':7},hd);}
  eyes(hd,0,-4,st,22);brows(hd,0,-26,st,22);mouthShape(hd,0,34,st,11);};
// ---------- COLLECTOR (silhouette only) ----------
CHAR.collector=function(g,st){cut(g,[[-30,0],[30,0],[44,-420],[0,-470],[-44,-420]],C.ink,{seed:1,sw:0});
  cut(g,[[-110,-470],[110,-470],[40,-510],[0,-560],[-40,-510]],C.ink,{seed:2,sw:0});
  keyholeEye(g,0,-450,34,C.must,1,0);};

// props (drawn in prop local coordinates)
const PROPS={};
const CARD={};
