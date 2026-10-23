// usage: node render.js spec.json outdir  (needs playwright-core path in PW env var)
const {chromium}=require(process.env.PW);
const fs=require('fs'),path=require('path');
(async()=>{
 const spec=JSON.parse(fs.readFileSync(process.argv[2],'utf8')),out=process.argv[3];
 fs.mkdirSync(out,{recursive:true});
 const b=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 const p=await b.newPage({viewport:{width:1080,height:1920}});
 await p.goto('file:///'+path.resolve(__dirname,'engine.html').replace(/\\/g,'/'));
 await p.evaluate(()=>document.fonts.ready);
 await p.evaluate(s=>build(s),spec);
 const fps=30,total=spec.scenes.reduce((a,s)=>a+s.dur,0),N=Math.ceil(total*fps);
 for(let i=0;i<N;i++){
  await p.evaluate(t=>seek(t),i/fps);
  await p.screenshot({path:path.join(out,String(i).padStart(5,'0')+'.jpg'),type:'jpeg',quality:92});
 }
 await b.close();console.log('frames',N,'total',total.toFixed(2));
})();
