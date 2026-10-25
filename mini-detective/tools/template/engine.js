// Pip Thimble scene engine (ep01 look: SVG paper cut-outs, 540x960 world, rendered at 2x). seek(t) is deterministic.
const $=id=>document.getElementById(id),NS='http://www.w3.org/2000/svg';
const clamp=(v,a=0,b=1)=>Math.min(b,Math.max(a,v)),mix=(a,b,k)=>a+(b-a)*k;
const E={lin:x=>x,in2:x=>x*x,out2:x=>1-(1-x)*(1-x),out3:x=>1-Math.pow(1-x,3),io3:x=>x<.5?4*x*x*x:1-Math.pow(-2*x+2,3)/2,
 back:x=>{const c=1.70158,d=c+1;return 1+d*Math.pow(x-1,3)+c*Math.pow(x-1,2)}};
const R=(t,a,b,e=E.io3)=>e(clamp((t-a)/(b-a)));
function rnd(s){let x=Math.sin(s*127.1)*43758.5453;return x-Math.floor(x)}
const f2=n=>(+n).toFixed(2);
const LAYERS=[['sky',.9],['bg',.6],['mid',1],['back',1],['actors',1],['front',1],['fg',1.38]];
let SHOT=null,CUR=-1,TICK=null,ACT=[],PROP=[];

// numeric fields lerp (eased), others step; later keys were forward-filled by the builder
function track(keys,t){if(!keys||!keys.length)return{};if(t<=keys[0].t)return keys[0];const last=keys[keys.length-1];if(t>=last.t)return last;
 for(let i=0;i<keys.length-1;i++){const a=keys[i],b=keys[i+1];if(t>=a.t&&t<=b.t){const u=E.io3((t-a.t)/Math.max(1e-6,b.t-a.t)),o={};
  for(const k in a)o[k]=(typeof a[k]==='number'&&typeof b[k]==='number'&&k!=='t')?mix(a[k],b[k],u):a[k];for(const k in b)if(!(k in o))o[k]=b[k];return o}}return last}

function init(){
 if(EP.aspect==='4:5')document.body.classList.add('a45');
 $('tableLines').innerHTML=Array.from({length:30},(_,i)=>`<path d="M0 ${i*34} L540 ${i*34+(i%2?5:-5)}"/>`).join('');
}
function cam(t){const c=SHOT.cam&&SHOT.cam.length?track(SHOT.cam,t):{};return[c.x??270,c.y??540,c.z??1]}
function layerTf(id,p,c,jx,jy,sx,sy){const[cx,cy,z]=c,zz=1+(z-1)*p,ax=270+(cx-270)*p,ay=480+(cy-480)*p;
 $(id).setAttribute('transform',`translate(${270+jx+sx} ${480+jy+sy}) scale(${zz.toFixed(4)}) translate(${f2(-ax)} ${f2(-ay)})`)}

function buildShot(i){SHOT=EP.shots[i];CUR=i;
 for(const[n]of LAYERS)$(n).innerHTML='';
 const bg=BG[SHOT.bg];if(!bg)throw new Error('unknown bg '+SHOT.bg);TICK=bg($,SHOT)||null;
 ACT=(SHOT.actors||[]).map(a=>{const g=document.createElementNS(NS,'g');g.setAttribute('filter','url(#paper)');$('actors').appendChild(g);return{a,g}});
 PROP=(SHOT.props||[]).map(p=>{const g=document.createElementNS(NS,'g');g.setAttribute('filter',p.nofilter?'url(#paperNoOutline)':'url(#paper)');(p.layer==='fg'?$('fg'):p.layer==='back'?$('back'):p.layer==='bg'?$('bg'):$('front')).appendChild(g);return{p,g}});
}
function lineState(t){for(const id of EP.order){const L=EP.lines[id];if(t>=L.start&&t<=L.end){let q=false;for(const[s,e]of L.pauses)if(t>=s&&t<=e)q=true;
  return{id,speaker:L.speaker,mouth:q?0:.2+.8*Math.abs(Math.sin((t-L.start)*17))}}}return null}

function drawActors(t,ct){const ls=lineState(t);
 for(const A of ACT){const k=track(A.a.keys,t);if(k.vis===0){A.g.innerHTML='';continue}
  const st=Object.assign({},k,{t,ct,mood:k.mood||'neutral',mouth:(ls&&ls.speaker===A.a.who)?ls.mouth:0,blink:(ct%3.1)<.12});
  const s=k.s??1,fl=k.flip?-1:1;
  A.g.setAttribute('transform',`translate(${f2(k.x??270)} ${f2(k.y??760)}) rotate(${f2(k.rot??0)}) scale(${f2(s*fl)} ${f2(s)})`);
  A.g.innerHTML=CHAR[A.a.who](st)}}
function drawProps(t,ct){for(const P of PROP){const k=track(P.p.keys,t);if(k.vis===0){P.g.innerHTML='';continue}
  const s=k.s??1;P.g.setAttribute('transform',`translate(${f2(k.x??0)} ${f2(k.y??0)}) rotate(${f2(k.rot??0)}) scale(${f2(s*(k.flip?-1:1))} ${f2(s)})`);
  P.g.innerHTML=PROPS[P.p.kind](Object.assign({t,ct},k))}}

// ---- captions: split a line into phrases, show them in turn (proportional timing; unverified sync) ----
const CHUNKS={};
function chunkLine(id){if(CHUNKS[id])return CHUNKS[id];const L=EP.lines[id];
 const parts=L.spoken.match(/[^.?!…]+[.?!…]*\s*/g)||[L.spoken];const out=[];
 for(let p of parts){p=p.trim();if(!p)continue;while(p.length>52){let c=p.lastIndexOf(',',48);if(c<14)c=p.lastIndexOf(' ',48);out.push(p.slice(0,c+1).trim());p=p.slice(c+1).trim()}out.push(p)}
 const m=[];for(const c of out){if(m.length&&(m[m.length-1].length+c.length)<=34)m[m.length-1]+=' '+c;else m.push(c)}
 const w=m.map(c=>c.length+8),sum=w.reduce((a,b)=>a+b,0);let acc=0;return CHUNKS[id]=m.map((c,i)=>{acc+=w[i];return{text:c,b:acc/sum}})}
const WHO={pip:'PIP',juno:'JUNO',brass:'BRASS',velvet:'VELVET',fuzz:'FUZZ',cog:'COG',collector:'???'};
function caption(t){let txt='';
 for(const id of EP.order){const L=EP.lines[id];if(t>=L.start-.05&&t<=L.end+.25){const sp=chunkLine(id),u=(t-L.start)/Math.max(.2,L.end-L.start);
  let ch=sp[sp.length-1];for(const c of sp){if(u<=c.b){ch=c;break}}
  let s=ch.text;if(L.speaker!=='narrator'&&ch===sp[0])s=WHO[L.speaker]+': '+s;else if(L.speaker!=='narrator')s=s;txt=s;break}}
 $('cap').textContent=EP.captions?txt:''}

// ---- clue card scene (ep01 card, generalised) ----
const CARD={};
function drawClue(c,t){const u=t-c.t,fall=R(u,0,.2,E.in2);let y=mix(-700,480,fall),sx=1,sy=1,rot=-4;
 if(u>=.2){const b=u-.2,sq=Math.exp(-b*9)*Math.cos(b*30);sy=1-.1*sq;sx=1+.06*sq;y=480-Math.abs(Math.sin(b*14))*Math.exp(-b*7)*18}
 const sh=u>=.2?Math.exp(-(u-.2)*10)*Math.sin((u-.2)*60)*6:0;
 const r=rot+(u>=.2?Math.sin((u-.2)*10)*Math.exp(-(u-.2)*5)*2.5:0);
 $('cardG').setAttribute('transform',`translate(${270+sh} ${y}) rotate(${r}) scale(${sx} ${sy})`);
 $('cardG').innerHTML=`<g filter="url(#paper)"><path d="M-150 -200 L-138 -206 -122 -198 -104 -207 -84 -199 -64 -206 -44 -198 -22 -207 0 -199 22 -206 44 -198 64 -207 86 -199 106 -206 124 -198 142 -206 150 -200 L150 200 L-150 200Z" fill="#F3E9D2"/>
 <rect x="-138" y="-188" width="276" height="376" fill="none" stroke="#d6c59d" stroke-width="3" stroke-dasharray="8 6"/>${(CARD[c.card]||CARD.eye)(u)}
 <text x="0" y="96" text-anchor="middle" font-family="Georgia,serif" font-size="25" letter-spacing="5" fill="#1F2A44">${c.label||('CLUE No. '+EP.entry)}</text>
 <text x="0" y="132" text-anchor="middle" font-family="Georgia,serif" font-size="14" letter-spacing="2" fill="#6a6f82">${c.sub||''}</text>
 <rect x="-44" y="-224" width="88" height="30" fill="#E0A526" opacity=".9" transform="rotate(-5)"/></g>`;
 const z=1+.07*R(u,.8,3.6,E.out2),jx=(rnd(Math.floor(t*12))-.5)*1.4,jy=(rnd(Math.floor(t*12)+99)-.5)*1.4;
 $('S_card').setAttribute('transform',`translate(270 480) scale(${z}) translate(${-270+jx} ${-480+jy})`);
 let s='';for(let i=0;i<8;i++){const k=clamp((u-.2)/.7),a=i/8*Math.PI*2;s+=`<circle cx="${270+Math.cos(a)*(120+k*90)}" cy="${600+Math.sin(a)*14*(1+k)-k*22}" r="${k>0&&k<1?3+k*9:0}" fill="#e8dcc0" opacity="${(1-k)*.7}"/>`}
 $('cdust').innerHTML=s}

function drawHUD(t){let s='';
 for(const c of SHOT.cues||[]){if(t<c.t||t>c.t+c.dur)continue;const u=t-c.t;
  if(c.do==='eye'){const a=clamp(u/.3)*clamp((c.dur-u)/.3),bl=(u%2.4>2.2)?.15:1;s+=`<g transform="translate(${c.x} ${c.y}) scale(${c.s||1.4})" opacity="${a}"><g transform="scale(1 ${bl})"><use href="#eyeGlyphY"/></g></g>`}
  if(c.do==='notes'){for(let i=0;i<6;i++){const q=u-i*.28;if(q<0||q>2.4)continue;const x=c.x+Math.sin(q*2+i)*20+i*12,y=c.y-q*70;
   s+=`<g transform="translate(${x} ${y}) rotate(${Math.sin(q*3+i)*14})" opacity="${clamp(1-q/2.4)}" filter="url(#paperNoOutline)"><ellipse rx="9" ry="6.5" fill="#E0A526" transform="rotate(-20)"/><path d="M7 -2 V-30 q13 4 9 17" stroke="#E0A526" stroke-width="3.4" fill="none" stroke-linecap="round"/></g>`}}}
 $('HUD').innerHTML=s}

function seek(t){
 const ct=Math.floor(t*12)/12,qt=Math.floor(t*24)/24,fr=Math.floor(t*12);
 let idx=EP.shots.findIndex((s,i)=>t>=s.t0&&(t<s.t1||i===EP.shots.length-1));if(idx<0)idx=0;if(idx!==CUR)buildShot(idx);
 const clue=(SHOT.cues||[]).find(c=>c.do==='clue'&&t>=c.t&&t<=c.t+c.dur);
 const ended=t>=EP.speech_end+.35;
 $('S_card').style.display=clue&&!ended?'':'none';$('WORLD').style.display=(clue||ended)?'none':'';$('S_end').style.display=ended?'':'none';
 $('pt').setAttribute('seed',3+(Math.floor(t*3)%4));
 if(clue&&!ended)drawClue(clue,t);
 const jx=(rnd(fr)-.5)*1.4,jy=(rnd(fr+99)-.5)*1.4;let sx=0,sy=0;
 for(const e of SHOT.shake||[])if(t>=e.t&&t<=e.t+e.dur){const k=1-(t-e.t)/e.dur;sx+=Math.sin(t*90)*e.amp*k;sy+=Math.cos(t*77)*e.amp*k}
 if(!clue&&!ended){const c=cam(qt);for(const[n,p]of LAYERS)layerTf(n,p,c,jx,jy,sx,sy);
  if(TICK)TICK(t,ct);drawActors(t,ct);drawProps(t,ct)}
 const ov=track(SHOT.overlay,t);$('dim').setAttribute('opacity',(SHOT.overlay&&SHOT.overlay.length)?(ov.a||0):0);
 drawHUD(t);
 if(ended){const k=R(t,EP.speech_end+.35,EP.speech_end+1.05,E.out3);$('endTxt').textContent=EP.end_card;$('endG').setAttribute('opacity',k);$('endG').setAttribute('transform',`translate(0 ${(1-k)*14})`);
  const bl=(t-EP.speech_end>1.2&&t-EP.speech_end<1.45)?.15:1;$('endEye').setAttribute('transform',`scale(1 ${bl})`)}
 $('black').setAttribute('opacity',t<.9?1-R(t,.1,.9,E.io3):0);
 caption(t);
}
window.seek=seek;
