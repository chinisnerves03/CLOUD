// Backgrounds, props, clue-card faces. Plaza is ported from ep01_preview.src.html.
const BG={},PROPS={};
function wood(){let s='';for(let i=0;i<46;i++){const y=i*22+rnd(i)*14;let d=`M-40 ${y}`;for(let x=0;x<=600;x+=60)d+=` Q${x+30} ${y+(rnd(i*9+x)-.5)*16} ${x+60} ${y+(rnd(i*3+x)-.5)*10}`;
 s+=`<path d="${d}" fill="none" stroke="${i%3?'#b58557':'#a2744a'}" stroke-width="${1.2+rnd(i+4)*2.2}" opacity=".7"/>`}
 for(let i=0;i<14;i++)s+=`<ellipse cx="${rnd(i+30)*540}" cy="${rnd(i+60)*960}" rx="${8+rnd(i)*16}" ry="${3+rnd(i+2)*5}" fill="#9a6c43" opacity=".35"/>`;return s}
function city(){let s='';const cols=['#1F2A44','#2F8F8B','#C8452F','#E0A526','#6d5d86'];
 [[-30,80,130],[40,60,100],[100,70,150],[170,60,90],[470,70,140],[540,60,100],[600,80,150],[380,60,100]].forEach(([x,w,hh],i)=>{const col=cols[i%5];
  s+=`<rect x="${x}" y="${560-hh}" width="${w}" height="${hh}" fill="${col}"/><path d="M${x-8} ${560-hh+4} Q${x+w/2} ${560-hh-52} ${x+w+8} ${560-hh+4}Z" fill="#c9ced6" stroke="#8e96a3" stroke-width="2"/><g fill="#f6d98a" opacity=".9"><rect x="${x+10}" y="${560-hh+22}" width="12" height="16" rx="2"/><rect x="${x+w-24}" y="${560-hh+22}" width="12" height="16" rx="2"/></g>`;
  for(let k=0;k<5;k++)s+=`<circle cx="${x+w/2+(k-2)*9}" cy="${560-hh-14-Math.abs(k-2)*-3}" r="1.6" fill="#8e96a3"/>`});
 return s+`<g><rect x="365" y="250" width="58" height="310" fill="#E0A526"/><path d="M365 250 L394 160 L423 250Z" fill="#e9c58f"/><path d="M381 205 L394 160 L407 205Z" fill="#33343c"/><path d="M386 250 V560 M402 250 V560" stroke="#b88618" stroke-width="2"/><circle cx="394" cy="300" r="21" fill="#F3E9D2" stroke="#1F2A44" stroke-width="4"/><path d="M394 300 V286 M394 300 L404 305" stroke="#1F2A44" stroke-width="3" stroke-linecap="round"/></g>`}
const bootprint=(x,y,rot)=>`<g transform="translate(${x} ${y}) rotate(${rot}) scale(1.7)" opacity=".85"><path d="M-6 -17 q8 -5 13 1 q4 8 1 20 q-2 6 -7 6 q-5 0 -7 -6 q-3 -12 0 -21Z" fill="#cbb994"/><ellipse cy="23" rx="5.5" ry="4.5" fill="#cbb994"/></g>`;

BG.plaza=function($,shot){const o=shot.bgopts||{};
 let sky=`<rect x="-600" y="-1600" width="1740" height="2300" fill="url(#skyG)"/><circle cx="270" cy="560" r="520" fill="url(#sun)"/>`;
 if(o.ceiling){sky+=`<rect x="-600" y="-760" width="1740" height="360" fill="#2a1d17"/><rect x="-600" y="-410" width="1740" height="10" fill="#4b3326"/>`;
  for(let i=0;i<10;i++)sky+=bootprint(-30+i*66,-545+(i%2?26:-22)+Math.sin(i)*8,90+(rnd(i)-.5)*10);
  sky+=`<g transform="translate(60 -470) scale(.4)" opacity=".5"><use href="#eyeGlyphY"/></g>`}
 else sky+=`<rect x="-600" y="-470" width="1740" height="70" fill="#2a1d17"/><rect x="-600" y="-410" width="1740" height="10" fill="#4b3326"/>`;
 sky+=`<path id="thrBg" d="M${o.threadX||270} -1500 L${o.threadX||270} -720" stroke="#F3E9D2" stroke-width="2.2" fill="none"/>`;
 $('sky').innerHTML=sky;
 $('bg').innerHTML=`<path d="M-600 560 Q-300 470 0 520 T600 500 T1140 520 L1140 700 L-600 700Z" fill="#b98a5d" opacity=".75"/><g filter="url(#paper)">${city()}</g>`;
 const pal=['#1F2A44','#2F8F8B','#6d5d86','#C8452F','#8a6a3d'];let crowd='';
 [[44,712],[78,730],[108,706],[16,738],[428,716],[466,734],[500,708],[520,740],[148,742],[398,745]].forEach(([x,y],i)=>{const c=pal[i%5],sc=.85+rnd(i)*.4;
  crowd+=`<g class="cr" data-i="${i}" data-x="${x}" data-y="${y}" data-s="${sc}"><g filter="url(#paper)"><path d="M-9 0 L-7 -26 Q0 -32 7 -26 L9 0Z" fill="${c}"/><circle cy="-36" r="8.5" fill="#f1cfaa"/><path d="M-9 -38 Q0 -50 9 -38Q0 -44 -9 -38Z" fill="${i%2?'#222':'#8a5a2b'}"/><circle cx="-3" cy="-36" r="1.2" fill="#1F2A44"/><circle cx="3" cy="-36" r="1.2" fill="#1F2A44"/></g></g>`});
 const stalls=[[28,640],[430,630]].map(([x,y],i)=>`<g><rect x="${x}" y="${y}" width="80" height="60" fill="#d0452b"/><rect x="${x+6}" y="${y+10}" width="68" height="32" fill="#F3E9D2"/><path d="M${x-6} ${y} H${x+86} L${x+78} ${y-22} H${x+2}Z" fill="${i?'#2F8F8B':'#E0A526'}"/></g>`).join('');
 $('mid').innerHTML=`<g filter="url(#paperNoOutline)"><ellipse cx="270" cy="790" rx="500" ry="250" fill="#F3E9D2" stroke="#d9c9a3" stroke-width="7"/><ellipse cx="270" cy="790" rx="470" ry="228" fill="none" stroke="#d9c9a3" stroke-width="3"/><g fill="#c9b78d"><ellipse cx="236" cy="800" rx="16" ry="8"/><ellipse cx="304" cy="800" rx="16" ry="8"/><ellipse cx="236" cy="840" rx="16" ry="8"/><ellipse cx="304" cy="840" rx="16" ry="8"/></g></g>
  <g filter="url(#paper)">${stalls}</g>${o.plinth===false?'':`<g filter="url(#paper)"><path d="M190 620 L190 722 A80 20 0 0 0 350 722 L350 620Z" fill="#C89B6D"/><path d="M190 660 L350 660" stroke="#a97d52" stroke-width="2" fill="none"/><ellipse cx="270" cy="620" rx="80" ry="20" fill="#d8b085"/><ellipse cx="270" cy="620" rx="62" ry="13" fill="#C8452F" opacity=".38"/></g>`}
  <g id="crowd">${crowd}</g>`;
 let b='<path d="M-60 140 Q270 215 600 140" fill="none" stroke="#8a6a3d" stroke-width="3"/>';const cl=['#C8452F','#E0A526','#2F8F8B','#F3E9D2'];
 for(let i=0;i<12;i++){const t=i/11,x=-40+t*620,y=140+Math.sin(t*Math.PI)*60*1.12;b+=`<g class="fl" data-i="${i}" data-x="${x}" data-y="${y}"><path d="M-17 0 L17 0 L0 36Z" fill="${cl[i%4]}"/></g>`}
 $('fg').innerHTML=`<g filter="url(#paperNoOutline)">${b}</g><g filter="url(#paper)">${[[-30,930],[570,940]].map(([x,y])=>`<g transform="translate(${x} ${y})"><rect x="-75" y="-95" width="150" height="26" rx="6" fill="#d8b085"/><rect x="-75" y="-18" width="150" height="26" rx="6" fill="#d8b085"/><rect x="-48" y="-72" width="96" height="56" fill="#E0A526"/><path d="M-48 -62 H48 M-48 -48 H48 M-48 -34 H48 M-48 -22 H48" stroke="#b88618" stroke-width="2"/></g>`).join('')}</g>`;
 const cr=[...document.querySelectorAll('.cr')],fl=[...document.querySelectorAll('.fl')];
 return(t,ct)=>{fl.forEach(f=>{const i=+f.dataset.i;f.setAttribute('transform',`translate(${f.dataset.x} ${f.dataset.y}) rotate(${f2(Math.sin(ct*2.2+i)*7)})`)});
  cr.forEach(c=>{const i=+c.dataset.i,bob=(Math.floor(ct*3+i*.37)%2)*-3;c.setAttribute('transform',`translate(${c.dataset.x} ${+c.dataset.y+bob}) rotate(${f2(Math.sin(ct*1.4+i)*2)}) scale(${c.dataset.s})`)});
  const tw=shot.bgopts&&shot.bgopts.twitch?Math.sin(t*8)*3:0;const th=$('thrBg');if(th)th.setAttribute('d',`M${(shot.bgopts&&shot.bgopts.threadX)||270} -1500 Q${((shot.bgopts&&shot.bgopts.threadX)||270)+tw} -1100 ${(shot.bgopts&&shot.bgopts.threadX)||270} -720`)}};

BG.desk=function($,shot){
 $('sky').innerHTML=`<rect x="-300" y="-300" width="1140" height="1560" fill="#C89B6D"/>`;
 $('bg').innerHTML=`<g transform="translate(0 0)">${wood()}</g>`;
 let d='';for(let i=0;i<70;i++)d+=`<circle cx="${-100+rnd(i+200)*740}" cy="${-100+rnd(i+300)*1160}" r="${.8+rnd(i+400)*1.8}" fill="#e8dcc0" opacity="${.3+rnd(i+500)*.4}"/>`;
 $('mid').innerHTML=`${d}<g filter="url(#paper)"><rect x="170" y="440" width="200" height="140" fill="#d3ad82" stroke="#a97d52" stroke-width="3" stroke-dasharray="6 4"/>
  <path d="M30 150 L230 164 L230 178 L30 164Z" fill="#E0A526"/><path d="M230 164 L260 171 L230 178Z" fill="#e9c58f"/>
  <g transform="translate(430 700) rotate(-8)" ${shot.bgopts&&shot.bgopts.clean?'display="none"':''}><rect x="-60" y="-38" width="120" height="76" fill="#C8452F"/><text y="-4" text-anchor="middle" font-family="Georgia,serif" font-size="22" fill="#F3E9D2">CASE</text><text y="26" text-anchor="middle" font-family="Georgia,serif" font-size="22" fill="#F3E9D2">CLOSED!</text><rect x="-14" y="-72" width="28" height="34" fill="#a97d52"/></g></g>`;
 $('fg').innerHTML='';return null};

// ---- props ----
const eyeSVG=(col,open,s)=>`<g transform="scale(${s} ${f2(s*Math.max(.05,open))})"><path d="M-30 0 Q0 -26 30 0 Q0 26 -30 0Z" fill="none" stroke="${col}" stroke-width="4" stroke-linejoin="round"/>${open>.25?`<circle r="11" fill="${col}"/><circle cy="-2" r="3.6" fill="#F3E9D2"/><path d="M-2 0 L2 0 L3.6 8 L-3.6 8Z" fill="#F3E9D2"/>`:''}</g>`;
PROPS.eyemark=p=>eyeSVG(p.col||'#6d4a2a',p.open??1,p.w??1);
PROPS.glider=p=>`<path d="M-62 4 L60 -6 L46 7 L-42 12Z" fill="#F3E9D2" stroke="#d6c59d" stroke-width="1.5"/><path d="M-42 12 L46 7 L2 24Z" fill="#e3d6b8"/>`;
PROPS.coin=p=>`<ellipse cy="${p.sink||0}" rx="26" ry="9" fill="#E0A526" stroke="#b88618" stroke-width="2"/>`;
PROPS.redbutton=p=>`<circle r="${60*(p.size||1)}" fill="#C8452F"/><circle r="${46*(p.size||1)}" fill="#a83a28"/>${[[-11,-11],[11,-11],[-11,11],[11,11]].map(([x,y])=>`<circle cx="${x}" cy="${y}" r="4.5" fill="#14141c"/>`).join('')}`;
PROPS.tag=p=>`<path d="M0 -30 V0" stroke="#9c7248"/><rect x="-35" y="0" width="70" height="30" fill="#F3E9D2" stroke="#c9b78d"/><text y="22" text-anchor="middle" font-family="Georgia,serif" font-size="15" fill="#1F2A44">${p.label||''}</text>`;
PROPS.crumb=p=>`<ellipse rx="5" ry="4" fill="#a97d52"/>`;
PROPS.pole=p=>`<rect x="-3" y="-125" width="6" height="125" fill="#aab1bd"/><ellipse cy="-125" rx="35" ry="9" fill="#cfd4dc" stroke="#8e96a3"/>`;
PROPS.stucksock=p=>`<path d="M-25 20 Q-30 -40 -15 -62 Q30 -68 45 -55 Q52 -10 40 20Z" fill="#C8452F"/><g fill="#F3E9D2" opacity=".9"><rect x="-24" y="-40" width="62" height="7"/><rect x="-24" y="-20" width="62" height="7"/></g><path d="M-5 -45 L50 -95 L20 -35Z" fill="#F3E9D2"/>`;

// ---- clue-card faces (276 x 376 card, origin centre) ----
CARD.eye=u=>`<use href="#eyeGlyph" transform="translate(0 -32) scale(2.35)"/>`;
CARD.thread=u=>`<g transform="translate(0 -40)">${[0,1,2,3].map(k=>`<path d="M-110 ${-40+k*22} q30 -50 60 -4 t60 0 t60 -4 t50 4" stroke="${k%2?'#e8d9a8':'#F3E9D2'}" stroke-width="${4-k*.5}" fill="none" stroke-linecap="round" style="filter:drop-shadow(0 1px 0 #b9a77a)"/>`).join('')}
 ${Array.from({length:14},(_,i)=>`<circle cx="${-100+rnd(i+3)*200}" cy="${-60+rnd(i+9)*110}" r="${1.8+rnd(i+5)*2}" fill="#E0A526"/>`).join('')}</g>`;
CARD.seal=u=>`<g transform="translate(0 -32)"><circle r="62" fill="#C8452F"/><circle r="46" fill="#9e3322"/><g transform="scale(1.1)"><use href="#eyeGlyphY" opacity=".0"/></g><g transform="scale(1.3)"><path d="M-30 0 Q0 -26 30 0 Q0 26 -30 0Z" fill="none" stroke="#F3E9D2" stroke-width="3"/><circle r="9" fill="#F3E9D2"/><path d="M-2 0 L2 0 L3.6 8 L-3.6 8Z" fill="#9e3322"/></g></g>`;
CARD.ledger=u=>`<g transform="translate(0 -40)">${[0,1,2,3,4].map(k=>`<path d="M-120 ${-90+k*34} H120" stroke="#9db4c0" stroke-width="2"/>`).join('')}<text transform="translate(-4 -40) rotate(-4)" text-anchor="middle" font-family="Georgia,serif" font-size="32" fill="#1F2A44">Collection</text><text transform="translate(0 20) rotate(-4)" text-anchor="middle" font-family="Georgia,serif" font-size="40" fill="#C8452F">17 of 400</text></g>`;

// --- Tin Lounge (entry 3) ---
BG.lounge=function($,shot){const dark=!!(shot.bgopts&&shot.bgopts.dark);
 $('sky').innerHTML=`<rect x="-600" y="-600" width="1740" height="2200" fill="url(#loungeG)"/>`;
 const fold=(x0,dir)=>{let s='';for(let k=0;k<5;k++)s+=`<path d="M${x0+dir*k*22} -200 Q${x0+dir*(k*22+8)} 300 ${x0+dir*(k*20+14)} 800" stroke="#9e3322" stroke-width="3" fill="none" opacity=".7"/>`;return s};
 $('bg').innerHTML=`<g filter="url(#paperNoOutline)"><ellipse cx="270" cy="360" rx="430" ry="560" fill="#243052" stroke="#C89B6D" stroke-width="12"/><ellipse cx="270" cy="360" rx="400" ry="530" fill="none" stroke="#1a2340" stroke-width="3"/></g>
  <g filter="url(#paper)"><path d="M-100 -200 L120 -200 Q110 300 150 790 L-100 800Z" fill="#C8452F"/>${fold(-80,1)}<path d="M640 -200 L420 -200 Q430 300 390 790 L640 800Z" fill="#C8452F"/>${fold(620,-1)}</g>
  <path d="M190 -200 L350 -200 L560 800 L-20 800Z" fill="#F3E9D2" opacity="${dark?.06:.15}"/>
  <g filter="url(#paper)"><g transform="translate(270 40)"><circle r="16" fill="#E0A526"/><path d="M0 -240 V-16" stroke="#8e6a14" stroke-width="3"/></g></g>
  <g transform="translate(60 300) scale(.5)" opacity=".5"><use href="#eyeGlyphY"/></g>`;
 $('mid').innerHTML=`<g filter="url(#paper)"><ellipse cx="270" cy="790" rx="360" ry="80" fill="#a97d52"/><ellipse cx="270" cy="778" rx="330" ry="66" fill="#C89B6D"/></g><rect x="-100" y="830" width="740" height="300" fill="#7a2a1f"/>`;
 let aud='';[[60,930,'#2F8F8B'],[470,940,'#C8452F'],[270,990,'#E0A526']].forEach(([x,y,c],i)=>{aud+=`<ellipse cx="${x}" cy="${y}" rx="85" ry="26" fill="${c}"/><ellipse cx="${x}" cy="${y-6}" rx="64" ry="15" fill="rgba(0,0,0,.18)"/><circle cx="${x-18}" cy="${y-44}" r="17" fill="#141A2E"/><circle cx="${x+20}" cy="${y-38}" r="15" fill="#141A2E"/>`});
 $('fg').innerHTML=`<g filter="url(#paper)">${aud}</g>${dark?'<rect x="-300" y="-300" width="1140" height="1700" fill="#05070d" opacity=".42"/>':''}`;
 return null};
PROPS.notes=p=>'';

// --- Sock Marsh + warehouse (entry 4) ---
let CP=0;
function sockHill(cx,cy,rx,ry,c1,c2,seed){const id='sk'+(CP++);let sd=seed*13;const r=()=>rnd(sd++);const pts=[];for(let i=0;i<26;i++){const a=i/26*Math.PI*2;pts.push([cx+Math.cos(a)*rx*(1+(r()-.5)*.06),cy+Math.sin(a)*ry*(1+(r()-.5)*.08)])}
 const d='M'+pts.map(p=>p[0].toFixed(1)+' '+p[1].toFixed(1)).join('L')+'Z';let st='';for(let k=-3;k<=3;k++)st+=`<rect x="${cx-rx-8}" y="${cy+k*ry*.42-ry*.1}" width="${rx*2+16}" height="${ry*.21}" fill="${c2}" transform="rotate(${(r()-.5)*10} ${cx} ${cy})"/>`;
 return `<clipPath id="${id}"><path d="${d}"/></clipPath><path d="${d}" fill="${c1}"/><g clip-path="url(#${id})">${st}</g>`}
const fogBand=(y,op)=>`<path d="M-700 ${y+20} Q-300 ${y-24} 0 ${y+6} T540 ${y-4} T1240 ${y+10} L1240 ${y+110} L-700 ${y+110}Z" fill="#F3E9D2" opacity="${op}"/>`;
BG.marsh=function($,shot){const o=shot.bgopts||{};const cols=[['#C8452F','#F3E9D2'],['#2F8F8B','#E0A526'],['#E0A526','#1F2A44'],['#F3E9D2','#C8452F'],['#1F2A44','#2F8F8B']];
 $('sky').innerHTML=`<rect x="-600" y="-600" width="1740" height="1500" fill="url(#marshG)"/><circle cx="400" cy="140" r="70" fill="#F3E9D2" opacity=".16"/>`+Array.from({length:22},(_,i)=>`<circle cx="${rnd(i+7)*640-50}" cy="${rnd(i+3)*400-100}" r="${1+rnd(i)*2}" fill="#F3E9D2" opacity="${.2+rnd(i+1)*.3}"/>`).join('');
 let far='';for(let i=0;i<7;i++){const c=cols[i%5];far+=sockHill(-40+i*100+rnd(i)*20,560+rnd(i+2)*30,80+rnd(i+4)*25,55+rnd(i+6)*15,c[0],c[1],40+i)}
 $('bg').innerHTML=`<g filter="url(#paper)">${far}</g>${fogBand(640,.32)}`;
 let mid='';for(let i=0;i<5;i++){const c=cols[(i+2)%5];mid+=sockHill(i*140+rnd(i+9)*30,700+rnd(i+11)*20,100+rnd(i+13)*25,62+rnd(i+15)*10,c[0],c[1],60+i)}
 let bld='';if(o.building){bld=`<g filter="url(#paper)" transform="translate(330 520)"><rect x="-150" y="-30" width="300" height="190" fill="#C89B6D"/><path d="M-165 -30 L165 -30 L150 -66 L-145 -62Z" fill="#a97d52"/><rect x="-30" y="50" width="60" height="110" fill="#141A2E"/><circle cx="-95" cy="20" r="10" fill="#E0A526"/><circle cx="95" cy="20" r="10" fill="#E0A526"/><g transform="translate(0 -4) scale(.6)"><use href="#eyeGlyphN"/></g></g>`}
 let coins='';for(let i=0;i<9;i++)coins+=`<ellipse cx="${-20+i*68}" cy="${772+(i%2)*6}" rx="26" ry="9" fill="#E0A526" stroke="#b88618" stroke-width="2"/>`;
 let reeds='';[[40,770,'#C8452F'],[500,760,'#C89B6D'],[440,790,'#2F8F8B']].forEach(([x,y,c])=>{reeds+=`<g transform="translate(${x} ${y})"><path d="M-14 0 L14 0 L16 -46 L-16 -46Z" fill="${c}"/>${[0,1,2,3].map(f=>`<path d="M${-16+f*9} -46 L${-10+f*9} -46 L${-8+f*9} ${-84-(f%2)*8} L${-17+f*9} ${-82}Z" fill="${c}"/>`).join('')}</g>`});
 $('mid').innerHTML=`<g filter="url(#paper)">${mid}${bld}</g><rect x="-100" y="790" width="740" height="400" fill="#226B68"/><rect x="-100" y="780" width="740" height="14" fill="#2F8F8B"/><g filter="url(#paperNoOutline)">${coins}</g><g filter="url(#paper)">${reeds}</g>`;
 $('fg').innerHTML=fogBand(830,.3)+fogBand(900,.22);
 return(t)=>{const f=$('fg');f.setAttribute('transform',`translate(${Math.sin(t*.5)*14} 0)`+(f.getAttribute('transform')||'').replace(/^translate\([^)]*\)/,''))}};

BG.warehouse_int=function($,shot){
 $('sky').innerHTML=`<rect x="-600" y="-600" width="1740" height="1700" fill="url(#whG)"/>`;
 const rows=[['#C8452F',150],['#E0A526',310],['#2F8F8B',470],['#F3E9D2',630]];let sh='';
 rows.forEach(([col,y],ri)=>{sh+=`<rect x="-60" y="${y+58}" width="660" height="16" fill="#a97d52"/>`;for(let i=0;i<8;i++){const x=-20+i*72+rnd(ri*9+i)*10,k=i%3,h=34+rnd(ri*7+i)*20;
  if(k==0)sh+=`<circle cx="${x}" cy="${y+58-20}" r="20" fill="${col}"/>`;else if(k==1)sh+=`<rect x="${x-16}" y="${y+58-h}" width="32" height="${h}" fill="${col}"/>`;else sh+=`<path d="M${x-20} ${y+58} L${x+20} ${y+58} L${x} ${y+58-h}Z" fill="${col}"/>`;
  sh+=`<rect x="${x-7}" y="${y+58-24}" width="14" height="12" fill="#FBF7EC"/><g transform="translate(${x} ${y+58-18}) scale(.16)"><use href="#eyeGlyphN"/></g>`}});
 $('bg').innerHTML=`<path d="M170 -100 L370 -100 L520 770 L20 770Z" fill="#F3E9D2" opacity=".07"/><g filter="url(#paper)">${sh}</g><rect x="-60" y="-100" width="16" height="900" fill="#a97d52"/><rect x="584" y="-100" width="16" height="900" fill="#a97d52"/>`;
 $('mid').innerHTML=`<rect x="-100" y="766" width="740" height="400" fill="#a97d52"/><rect x="-100" y="760" width="740" height="10" fill="#C89B6D"/>`;
 $('fg').innerHTML='';return null};
PROPS.coin=p=>`<ellipse cy="${p.sink||0}" rx="26" ry="9" fill="#E0A526" stroke="#b88618" stroke-width="2"/>`;

// ---- entry 5: clock and workshop ----
const clockHands=(h,m,len)=>{const am=m*6,ah=(h%12)*30+m*.5;return `<path d="M0 8 L-5 0 L0 ${-len*.62} L5 0Z" fill="#1F2A44" transform="rotate(${ah})"/><path d="M0 10 L-3.5 0 L0 ${-len*.92} L3.5 0Z" fill="#1F2A44" transform="rotate(${am})"/>`};
const clockFace=(r,h,m,sec)=>{let t='';for(let i=0;i<12;i++)t+=`<rect x="-3" y="${-r+6}" width="6" height="${i%3?10:18}" fill="#1F2A44" transform="rotate(${i*30})"/>`;
 return `<circle r="${r+10}" fill="#a97d52"/><circle r="${r}" fill="#F3E9D2" stroke="#1F2A44" stroke-width="5"/>${t}${clockHands(h,m,r)}${sec==null?'':`<path d="M0 12 V${-r*.9}" stroke="#C8452F" stroke-width="2.5" transform="rotate(${sec*6})"/>`}<circle r="7" fill="#C8452F"/>`};
PROPS.pocketwatch=p=>{const s=(Math.floor(p.ct||0)%60);return `<path d="M-8 -118 h16 v18 h-16Z" fill="#E0A526"/><circle cy="-120" r="14" fill="none" stroke="#E0A526" stroke-width="6"/><g transform="scale(1.3)"><circle r="92" fill="#E0A526" stroke="#b88618" stroke-width="5"/>${clockFace(78,3,11,p.tick?s:null)}</g>`};
PROPS.gear=p=>{let t='';for(let i=0;i<10;i++)t+=`<rect x="-8" y="-46" width="16" height="14" fill="#b88618" transform="rotate(${i*36})"/>`;return `<g transform="rotate(${(p.ct||0)*(p.spin||20)})"><circle r="38" fill="#E0A526" stroke="#b88618" stroke-width="3"/>${t}<circle r="12" fill="#a97d52"/></g>`};
PROPS.notebook=p=>`<g transform="rotate(-3)"><rect x="-150" y="-100" width="300" height="200" fill="#F3E9D2" stroke="#c9b78d" stroke-width="3"/><path d="M0 -100 V100" stroke="#c9b78d" stroke-width="3"/>${[0,1,2,3,4].map(k=>`<path d="M-135 ${-60+k*30} H-12" stroke="#9db4c0" stroke-width="1.5"/>`).join('')}<text x="-130" y="-70" font-family="Georgia,serif" font-style="italic" font-size="17" fill="#1F2A44">clue: 3:11 ...</text><text x="20" y="-20" font-family="Georgia,serif" font-style="italic" font-size="19" fill="#C8452F" opacity="${p.a??1}">Don't wait up.</text><text x="20" y="8" font-family="Georgia,serif" font-style="italic" font-size="19" fill="#C8452F" opacity="${p.a??1}">— P.</text></g>`;
BG.wall=function($,shot){const pins=[[110,260],[300,200],[430,340],[170,470],[390,560],[250,640]];
 $('sky').innerHTML=`<rect x="-300" y="-300" width="1140" height="1560" fill="#8a6a46"/>`;
 let th='',pn='';pins.forEach(([x,y],i)=>{const [x2,y2]=pins[(i+1)%pins.length];th+=`<path d="M${x} ${y} L${x2} ${y2}" stroke="#C8452F" stroke-width="3.5" fill="none"/>`;
  pn+=`<g transform="translate(${x} ${y})"><rect x="-34" y="-8" width="68" height="40" fill="#F3E9D2" stroke="#c9b78d" transform="rotate(${(i%3-1)*4})"/><text y="22" text-anchor="middle" font-family="Georgia,serif" font-size="22" fill="#1F2A44">3:11</text><circle cy="-8" r="8" fill="#C8452F"/></g>`});
 $('bg').innerHTML=`<g filter="url(#paper)"><rect x="40" y="120" width="460" height="700" fill="#C89B6D" stroke="#6d4a2a" stroke-width="12"/>${th}${pn}</g>`;$('mid').innerHTML='';$('fg').innerHTML='';return null};
BG.workshop=function($,shot){const o=shot.bgopts||{};const hh=o.h??3,mm=o.m??0;
 $('sky').innerHTML=`<rect x="-300" y="-300" width="1140" height="1560" fill="#3a2a1e"/>`;
 let g='';for(let i=0;i<7;i++)g+=`<g transform="translate(${40+i*78} ${620+(i%2)*24})" opacity=".9"><circle r="${20+i%3*8}" fill="${i%2?'#E0A526':'#2F8F8B'}" stroke="#1F2A44" stroke-width="3"/><circle r="6" fill="#3a2a1e"/></g>`;
 $('bg').innerHTML=`<g filter="url(#paper)"><rect x="-100" y="-100" width="740" height="1100" fill="#4b3326"/><g transform="translate(270 300)">${clockFace(170,hh,mm,o.stopped?null:(shot.ct||0))}</g><rect x="-100" y="740" width="740" height="300" fill="#6d4a2a"/>${g}</g>`;
 $('mid').innerHTML='';$('fg').innerHTML=o.empty?'':'';return null};
CARD.clock=u=>`<g transform="translate(0 -40)"><circle r="82" fill="#F3E9D2" stroke="#1F2A44" stroke-width="5"/>${[0,1,2,3,4,5,6,7,8,9,10,11].map(i=>`<rect x="-2.5" y="-74" width="5" height="${i%3?8:14}" fill="#1F2A44" transform="rotate(${i*30})"/>`).join('')}${clockHands(3,11,78)}<circle r="6" fill="#C8452F"/></g>`;
