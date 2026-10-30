// Characters in the ep01 style. Origin = centre of feet. Pip and Juno are ported from ep01_preview.src.html.
const CHAR={};
const BROW={neutral:'M-12 -28 Q-8 -30 -4 -28 M4 -28 Q8 -30 12 -28',curious:'M-12 -28 Q-8 -30 -4 -28 M4 -33 Q8 -36 12 -33',
 surprised:'M-12 -33 Q-8 -36 -4 -33 M4 -33 Q8 -36 12 -33',worried:'M-12 -26 L-4 -30 M4 -30 L12 -26',determined:'M-12 -31 L-4 -27 M4 -27 L12 -31',
 whisper:'M-12 -29 Q-8 -31 -4 -29 M4 -29 Q8 -31 12 -29',shout:'M-12 -31 L-4 -27 M4 -27 L12 -31',smirk:'M-12 -28 Q-8 -30 -4 -28 M4 -31 Q8 -34 12 -31',sly:'M-12 -29 L-4 -27 M4 -31 Q8 -34 12 -31'};
// generic face for the new cast: centre (0,0), head radius r
function face(r,st,col='#14141c'){const m=st.mood||'neutral',mo=st.mouth||0,px=1.8+(st.lx||0)*1.6,py=(st.ly||0)*1.5,k=r/21,bl=st.blink?.12:1;
 const rx=m==='surprised'?3.2:3.4+mo*.8,ry=m==='surprised'?3.8:.8+mo*3.6;
 return `<g transform="scale(${k.toFixed(3)})"><g transform="translate(-8 -20) scale(1 ${bl})"><ellipse rx="4.3" ry="5.2" fill="#fff"/><circle cx="${px}" cy="${py}" r="2.5" fill="#1F2A44"/></g>
 <g transform="translate(8 -20) scale(1 ${bl})"><ellipse rx="4.3" ry="5.2" fill="#fff"/><circle cx="${px}" cy="${py}" r="2.5" fill="#1F2A44"/></g>
 <path d="${BROW[m]||BROW.neutral}" stroke="${col}" stroke-width="1.6" fill="none" stroke-linecap="round"/>
 <circle cx="-13" cy="-12" r="3.6" fill="#C8452F" opacity=".22"/><circle cx="13" cy="-12" r="3.6" fill="#C8452F" opacity=".22"/>
 <ellipse cx="1" cy="-9" rx="${rx}" ry="${ry}" fill="#7a2f2a"/></g>`}
const arm=(x,y,rot,col='#b5864f',hand='#f1cfaa',extra='')=>`<g transform="translate(${x} ${y}) rotate(${f2(rot)})"><rect x="-4" y="0" width="8" height="26" rx="4" fill="${col}"/><circle cy="28" r="4.8" fill="${hand}"/>${extra}</g>`;
const HOLD={lens:`<g transform="translate(0 30) rotate(-25)"><rect x="-2" y="0" width="4" height="14" rx="2" fill="#E0A526"/><circle cy="26" r="12" fill="rgba(255,255,255,.28)" stroke="#1F2A44" stroke-width="2.6"/></g>`,
 tweezers:`<path d="M-1 32 L-2 50 M2 32 L2 50" stroke="#8e96a3" stroke-width="1.8" stroke-linecap="round"/>`,
 strand:`<path d="M-1 32 L-2 50 M2 32 L2 50" stroke="#8e96a3" stroke-width="1.8" stroke-linecap="round"/><path d="M0 50 q8 6 14 -2 t14 2" stroke="#fff3b0" stroke-width="1.6" fill="none"/><circle cx="14" cy="47" r="1.3" fill="#E0A526"/><circle cx="26" cy="50" r="1.3" fill="#E0A526"/>`};

CHAR.pip=function(st){const mv=st.mv?1:0,sw=mv?Math.sin(st.ph||0)*28:0,bob=mv?-Math.abs(Math.sin(st.ph||0))*3.2:0,k=st.kneel||0,mo=st.mouth||0,m=st.mood;
 const px=2.2+(st.lx||0)*1.6,py=(st.ly||0)*1.6,bl=st.blink?.12:1,rx=m==='surprised'?3.2:3.4+mo*.8,ry=m==='surprised'?3.8:.8+mo*3.6;
 const aL=(mv?-sw*1.1:0)+(st.armL||0)+8*k,aR=(mv?sw*1.1:0)-(st.armR||0)-66*k;
 return `<g>
 <g transform="translate(-8 ${-32+k*24}) rotate(${f2(k>0?70*k:sw)})"><rect x="-4" y="0" width="8" height="26" rx="3" fill="#1F2A44"/><ellipse cx="3" cy="28" rx="8" ry="4.5" fill="#2a1d17"/></g>
 <g transform="translate(8 ${-32+k*24}) rotate(${f2(k>0?-22*k:-sw)})"><rect x="-4" y="0" width="8" height="26" rx="3" fill="#1F2A44"/><ellipse cx="3" cy="28" rx="8" ry="4.5" fill="#2a1d17"/></g>
 <g transform="translate(0 ${f2(-32+bob+k*24)}) rotate(${f2(16*k)}) scale(1 ${1-.03*k})">
  <path d="M-18 2 L18 2 L14 -44 L-14 -44Z" fill="#C89B6D" stroke="#9c7248" stroke-width="1.6" stroke-linejoin="round"/>
  <path d="M-11 -12 L9 -16 M-13 -27 L11 -31 M-2 -3 L-4 -40" stroke="#6f93b7" stroke-width="1" opacity=".7" fill="none"/>
  <path d="M-3 -44 L3 -44 L2.5 -30 L0 -25 L-2.5 -30Z" fill="#C8452F"/><path d="M-14 -44 L-4 -44 L-8 -36Z M14 -44 L4 -44 L8 -36Z" fill="#F3E9D2"/>
  <rect x="5" y="-22" width="8" height="10" fill="#e8dcc0" stroke="#9c7248" stroke-width=".8"/>
  ${arm(-16,-40,aL)}
  <g transform="translate(0 -44) rotate(${f2((st.hr||0)+10*k)})">
   <circle cy="-20" r="21" fill="#f3d5b3" stroke="#c79e75" stroke-width="1"/><circle cx="-21" cy="-19" r="4" fill="#f3d5b3"/><circle cx="21" cy="-19" r="4" fill="#f3d5b3"/>
   <path d="M-22 -23 Q-25 -43 -4 -43 Q17 -47 22 -25 Q14 -33 4 -31 Q-8 -35 -22 -23Z" fill="#14141c"/><path d="M-17 -38 L-26 -45 L-12 -42Z M4 -43 L9 -52 L12 -43Z" fill="#14141c"/>
   <g transform="translate(-8 -20) scale(1 ${bl})"><ellipse rx="4.3" ry="5.2" fill="#fff"/><circle cx="${px}" cy="${py}" r="2.5" fill="#1F2A44"/></g>
   <g transform="translate(8 -20) scale(1 ${bl})"><ellipse rx="4.3" ry="5.2" fill="#fff"/><circle cx="${px}" cy="${py}" r="2.5" fill="#1F2A44"/></g>
   <path d="${(BROW[m]||BROW.neutral).replace(/-?\d+(\.\d+)?/g,(n,_,o,s)=>n)}" stroke="#14141c" stroke-width="1.6" fill="none" stroke-linecap="round" transform="translate(0 -1)"/>
   <circle cx="-13" cy="-12" r="3.6" fill="#C8452F" opacity=".22"/><circle cx="13" cy="-12" r="3.6" fill="#C8452F" opacity=".22"/>
   <ellipse cx="1" cy="-9" rx="${rx}" ry="${ry}" fill="#7a2f2a"/>
   <g transform="translate(0 -34) rotate(${f2(-11+Math.sin(st.ct*9)*(mv?3:0))})"><path d="M-16 6 L-13 -13 Q0 -25 13 -13 L16 6Z" fill="#cfd4dc" stroke="#8e96a3" stroke-width="1.6"/><rect x="-18" y="2" width="36" height="6" rx="2.5" fill="#aab1bd"/><g fill="#8e96a3"><circle cx="-6" cy="-8" r="1.2"/><circle cx="2" cy="-12" r="1.2"/><circle cx="8" cy="-5" r="1.2"/><circle cx="-1" cy="-3" r="1.2"/><circle cx="-9" cy="-1" r="1.2"/></g></g>
  </g>
  ${arm(16,-40,aR,'#b5864f','#f1cfaa',HOLD[st.hold]||'')}
 </g></g>`};

CHAR.juno=function(st){const mo=st.mouth||0,bob=Math.sin(st.ct*2.4)*1.4,pup=1+(st.lx||0)*.8;
 const glider=st.glide?`<g transform="rotate(${f2((st.gt||0)+bob)})"><path d="M-62 4 L60 -6 L46 7 L-42 12Z" fill="#F3E9D2" stroke="#d6c59d" stroke-width="1.5"/><path d="M-62 4 L60 -6" stroke="#bda66f" stroke-width="2"/><path d="M-42 12 L46 7 L2 24Z" fill="#e3d6b8"/></g>`:'';
 const arms=st.armUp?`<g transform="translate(14 -80) rotate(${-st.armUp})"><rect x="-4" y="0" width="8" height="28" rx="4" fill="#26807c"/><circle cy="30" r="4.6" fill="#f3d5b3"/></g><g transform="translate(-14 -80) rotate(${st.armUp*.6})"><rect x="-4" y="0" width="8" height="28" rx="4" fill="#26807c"/><circle cy="30" r="4.6" fill="#f3d5b3"/></g>`
  :`<path d="M-20 -72 L8 -60 L6 -54 L-22 -66Z M20 -72 L-8 -60 L-6 -54 L22 -66Z" fill="#26807c" stroke="#1f6764" stroke-width="1"/>`;
 return `<g>${glider}<g transform="translate(0 ${st.glide?0:0}) rotate(${f2(Math.sin(st.ct*2)*.8)})">
  <path d="M4 -92 Q-26 -88 -46 -78 Q-70 -66 -84 -74" stroke="#C8452F" stroke-width="7" fill="none" stroke-linecap="round" transform="rotate(${f2(Math.sin(st.ct*13)*3)} 4 -92)"/>
  ${(()=>{const sw=st.mv?Math.sin(st.ph||0)*26:0;return `<g transform="rotate(${f2(sw)} -8 -34)"><rect x="-12" y="-34" width="8" height="34" rx="2" fill="#1F2A44"/><path d="M-14 0 H-2 L-2 -6 H-14Z" fill="#2a1d17"/></g><g transform="rotate(${f2(-sw)} 8 -34)"><rect x="4" y="-34" width="8" height="34" rx="2" fill="#1F2A44"/><path d="M2 0 H14 L14 -6 H2Z" fill="#2a1d17"/></g>`})()}
  <path d="M-16 -32 L16 -32 L12 -86 L-12 -86Z" fill="#2F8F8B" stroke="#1f6764" stroke-width="1.5"/>
  <rect x="8" y="-48" width="20" height="14" fill="#F3E9D2" stroke="#c9b78d" stroke-width="1.2"/><path d="M8 -48 L18 -40 L28 -48" fill="none" stroke="#c9b78d"/>
  ${arms}
  <g transform="rotate(${f2(st.hr||0)} 0 -86)"><path d="M-14 -96 L14 -96 L10 -118 L-10 -118Z" fill="#f3d5b3"/><path d="M-13 -92 L13 -92 L0 -78Z" fill="#f3d5b3"/>
   <ellipse cy="-98" rx="16" ry="18" fill="#f3d5b3" stroke="#c79e75" stroke-width="1"/>
   <path d="M-17 -100 Q-19 -122 0 -122 Q19 -122 17 -100 L12 -106 Q0 -112 -12 -106Z" fill="#2F8F8B"/><path d="M-17 -100 L-24 -88 L-14 -90Z M17 -100 L24 -88 L14 -90Z" fill="#26807c"/>
   <rect x="-12" y="-112" width="24" height="7" rx="3.5" fill="#E0A526" stroke="#8e6a14" stroke-width="1"/><circle cx="-6" cy="-108.5" r="2.4" fill="#fff6c6"/><circle cx="6" cy="-108.5" r="2.4" fill="#fff6c6"/>
   <g transform="scale(1 ${st.blink?.15:1})" transform-origin="0 -97"><ellipse cx="-6" cy="-97" rx="3" ry="3.6" fill="#fff"/><ellipse cx="6" cy="-97" rx="3" ry="3.6" fill="#fff"/><circle cx="${f2(-6+pup)}" cy="-97" r="1.9" fill="#1F2A44"/><circle cx="${f2(6+pup)}" cy="-97" r="1.9" fill="#1F2A44"/></g>
   <path d="${{worried:'M-10 -102 L-3 -104 M10 -102 L3 -104',shout:'M-10 -104 L-3 -101 M10 -104 L3 -101',smirk:'M-10 -104 L-3 -102 M10 -105 L3 -104'}[st.mood]||'M-10 -104 L-3 -102 M10 -104 L3 -102'}" stroke="#14141c" stroke-width="1.6" stroke-linecap="round" fill="none"/>
   <ellipse cx="-1" cy="-87" rx="3" ry="${f2(mo*3.4+.7)}" fill="#7a2f2a"/></g></g></g>`};

CHAR.brass=function(st){const mo=st.mouth||0,pat=st.pat?Math.sin(st.ct*14)*12:0;
 return `<g>${(()=>{const sw=st.mv?Math.sin(st.ph||0)*24:0;return `<g transform="rotate(${f2(sw)} -10 -24)"><rect x="-17" y="-24" width="13" height="24" rx="3" fill="#1F2A44"/><path d="M-20 0 H-2 V-5 H-20Z" fill="#14141c"/></g><g transform="rotate(${f2(-sw)} 10 -24)"><rect x="4" y="-24" width="13" height="24" rx="3" fill="#1F2A44"/><path d="M2 0 H20 V-5 H2Z" fill="#14141c"/></g>`})()}
  <path d="M-30 -20 L30 -20 L26 -70 L-26 -70Z" fill="#1F2A44" stroke="#14192b" stroke-width="1.5"/>
  <g fill="#E0A526"><circle cy="-60" r="2.6"/><circle cy="-48" r="2.6"/><circle cy="-36" r="2.6"/></g><rect x="-30" y="-27" width="60" height="5" fill="#14192b"/>
  ${st.badge===0?`<circle cx="-14" cy="-58" r="6" fill="#14192b" opacity=".5"/>`:`<circle cx="-14" cy="-58" r="6" fill="#E0A526" stroke="#b88618" stroke-width="1.2"/>`}
  ${arm(-30,-66,(st.armL||6)+pat,'#1F2A44','#f1cfaa')}${arm(30,-66,-((st.armR||6)+pat),'#1F2A44','#f1cfaa')}
  <g transform="translate(0 -72)"><circle cy="-14" r="20" fill="#f3d5b3" stroke="#c79e75" stroke-width="1"/><circle cx="-20" cy="-13" r="3.6" fill="#f3d5b3"/><circle cx="20" cy="-13" r="3.6" fill="#f3d5b3"/>
   <g transform="translate(0 6)">${face(20,st)}</g>
   <path d="M-17 -6 Q-8 -12 0 -8 Q8 -12 17 -6 Q10 3 0 -2 Q-10 3 -17 -6Z" fill="#8a5a2b" transform="translate(0 2)"/>
   <path d="M-22 -22 Q-22 -46 0 -46 Q22 -46 22 -22Z" fill="#E0A526" stroke="#b88618" stroke-width="1.5"/><rect x="-25" y="-26" width="50" height="6" rx="3" fill="#b88618"/><circle cy="-40" r="6" fill="none" stroke="#b88618" stroke-width="3"/></g></g>`};

CHAR.velvet=function(st){const tr=st.trem?Math.sin(st.ct*55)*5:0;
 return `<g><path d="M-14 -108 L14 -108 L36 0 L-36 0Z" fill="#C8452F" stroke="#9e3322" stroke-width="1.5"/><path d="M-6 -104 L-18 -2 M0 -104 L0 -2 M6 -104 L18 -2" stroke="#9e3322" stroke-width="1.2" opacity=".7"/>
  ${st.hold==='musicbox'?'<rect x="-12" y="-62" width="24" height="16" fill="#C89B6D" stroke="#9c7248" stroke-width="1.2"/><path d="M12 -54 l10 -8" stroke="#E0A526" stroke-width="2"/>':''}
  ${arm(-16,-102,(st.armL||12)+tr,'#9e3322','#f1cfaa')}${arm(16,-102,-((st.armR||12)+tr),'#C8452F','#f1cfaa')}
  <g transform="translate(0 -108)"><circle cy="-20" r="23" fill="#14141c"/><circle cy="-16" r="19" fill="#f3d5b3" stroke="#c79e75" stroke-width="1"/><g transform="translate(0 4)">${face(19,st)}</g>
   <path d="M-19 -22 Q-20 -40 0 -40 Q20 -40 19 -22 Q10 -30 0 -28 Q-10 -30 -19 -22Z" fill="#14141c"/>
   <path d="M-4 -44 q-10 -10 0 -16 t14 4 t-8 10 t-10 -4" stroke="#cfd4dc" stroke-width="2.6" fill="none" stroke-linecap="round"/>
   <circle cx="-21" cy="-8" r="2.8" fill="#E0A526"/><circle cx="21" cy="-8" r="2.8" fill="#E0A526"/></g></g>`};

CHAR.fuzz=function(st){const f=Math.sin(st.ct*2.3)*4,mo=st.mouth||0,g=['#9AA0A6','#B8BCC0','#D3D5D8','#AEB3B8'];
 const bl=[[-30,0,28,24],[28,2,30,25],[0,-18,34,28],[-20,-26,20,17],[20,-28,22,18],[0,14,38,20],[-34,14,19,14],[34,15,19,14]];
 let s=bl.map((b,i)=>`<ellipse cx="${b[0]}" cy="${f2(b[1]+Math.sin(st.ct*3+i)*1.5)}" rx="${b[2]}" ry="${b[3]}" fill="${g[i%4]}"/>`).join('');
 const lx=(st.lx||0)*2;
 const eye=sx=>`<g transform="translate(${sx*13} -6)"><circle r="7" fill="#14141c" stroke="#F3E9D2" stroke-width="1.6"/><circle cx="-2" cy="-1.4" r="1.1" fill="#F3E9D2"/><circle cx="2" cy="-1.4" r="1.1" fill="#F3E9D2"/><circle cx="${2.4+lx}" cy="-3" r="1.1" fill="#fff"/></g>`;
 const mouth=mo>.05?`<path d="M-9 11 q9 ${5+mo*6} 18 0" stroke="#14141c" stroke-width="1.8" fill="none" stroke-linecap="round"/>`:(st.mood==='sly'?`<path d="M-10 10 q7 5 19 -4" stroke="#14141c" stroke-width="1.8" fill="none" stroke-linecap="round"/>`:`<path d="M-9 10 q9 4 18 0" stroke="#14141c" stroke-width="1.8" fill="none" stroke-linecap="round"/>`);
 let fl='';for(let i=0;i<5;i++){const q=(st.ct*.5+i/5)%1;fl+=`<circle cx="${-40+i*20+Math.sin(q*6+i)*6}" cy="${28+q*50}" r="${2.4-q*1.6}" fill="#F3E9D2" opacity="${1-q}"/>`}
 return `<g transform="translate(0 ${f2(-48+f)})">${s}${eye(-1)}${eye(1)}${mouth}${fl}</g>`};

CHAR.cog=function(st){return `<g><rect x="-10" y="-40" width="8" height="40" fill="#1F2A44"/><rect x="2" y="-40" width="8" height="40" fill="#1F2A44"/><path d="M-20 -38 L20 -38 L17 -100 L-17 -100Z" fill="#E3D5B5" stroke="#9c7248" stroke-width="1.4"/>
 ${arm(-18,-94,st.armL||10,'#E3D5B5','#f1cfaa')}${arm(18,-94,-(st.armR||10),'#E3D5B5','#f1cfaa')}
 <g transform="translate(0 -104)"><path d="M-24 -26 Q-26 -50 0 -52 Q26 -50 24 -26 Q18 -40 0 -38 Q-18 -40 -24 -26Z" fill="#F3E9D2"/><circle cy="-18" r="18" fill="#f3d5b3" stroke="#c79e75" stroke-width="1"/><g transform="translate(0 2)">${face(18,st)}</g>
 <circle cx="-8" cy="-22" r="8" fill="none" stroke="#8e96a3" stroke-width="2.4"/><circle cx="8" cy="-22" r="8" fill="none" stroke="#8e96a3" stroke-width="2.4"/></g></g>`};
CHAR.collector=function(st){return `<g><path d="M-10 0 L10 0 L14 -120 L0 -140 L-14 -120Z" fill="#05070d"/><path d="M-34 -138 L34 -138 L14 -150 L0 -170 L-14 -150Z" fill="#05070d"/><g transform="translate(0 -128) scale(.5)"><use href="#eyeGlyphY"/></g></g>`};
