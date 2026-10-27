const seg=new Intl.Segmenter('th',{granularity:'grapheme'});
const clamp=x=>Math.min(1,Math.max(0,x));
const ease=x=>1-Math.pow(1-x,3);
const back=x=>{const c1=1.70158,c3=c1+1;return 1+c3*Math.pow(x-1,3)+c1*Math.pow(x-1,2)};
const all=[...document.querySelectorAll('[data-a]')];
const typed=[...document.querySelectorAll('[data-type]')];
typed.forEach(e=>{e._full=[...seg.segment(e.textContent)].map(s=>s.segment)});
function seek(t){
  all.forEach(e=>{
    const a=+e.dataset.a,b=e.dataset.b?+e.dataset.b:1e9,d=e.dataset.d?+e.dataset.d:0.35,k=e.dataset.k||'fade';
    const p=clamp((t-a)/d), live=t>=a&&t<b;
    let o=0,tr='none';
    if(k==='cut'){o=live?1:0}
    else if(k==='pop'){o=live?1:0;const q=back(p);tr=`scale(${q}) rotate(${(1-p)*-7}deg)`}
    else if(k==='wipe'){o=t>=a?1:0;e.style.clipPath=`inset(${(1-ease(p))*100}% 0 0 0)`}
    else if(k==='slide'){o=live?ease(p):0;tr=`translateX(${(1-ease(p))*-120}px)`}
    else{o=t>=a?ease(p):0;if(t>b-0.2)o*=clamp((b-t)/0.2);tr=`translateY(${(1-ease(p))*40}px) scale(${0.94+0.06*ease(p)})`}
    if(e.dataset.shake&&live){tr+=` translate(${Math.sin(t*55)*7}px,${Math.cos(t*47)*7}px)`}
    e.style.opacity=o;e.style.transform=tr;
  });
  typed.forEach(e=>{
    const [s,f]=e.dataset.type.split(',').map(Number);
    const n=Math.round(e._full.length*clamp((t-s)/(f-s)));
    e.textContent=e._full.slice(0,n).join('');
  });
  document.querySelectorAll('[data-fill]').forEach(e=>{
    const [s,f,v0,v1]=e.dataset.fill.split(',').map(Number);
    e.style.width=(v0+(v1-v0)*ease(clamp((t-s)/(f-s))))+'%';
  });
  const bar=document.getElementById('bar'); if(bar)bar.style.width=(t/DUR*100)+'%';
}
