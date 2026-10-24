import puppeteer from 'puppeteer-core';
const W=+process.argv[2],K=+process.argv[3],FPS=30,DUR=53.2,N=Math.ceil(DUR*FPS);
const b=await puppeteer.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true,args:['--disable-gpu','--hide-scrollbars']});
const p=await b.newPage();
await p.setViewport({width:540,height:1100,deviceScaleFactor:2});
await p.goto('http://localhost:8765/ep01_preview.html',{waitUntil:'load'});
await p.addStyleTag({content:'#ctl{display:none!important}body{padding:0!important;gap:0!important}#wrap{border-radius:0!important}'});
const el=await p.$('#wrap');
for(let i=W;i<N;i+=K){
  const t=Math.min(i/FPS,DUR-0.001);
  await p.evaluate(t=>seek(t),t);
  await el.screenshot({path:`fr/f${String(i).padStart(5,'0')}.jpg`,type:'jpeg',quality:92});
}
await b.close();console.log('W'+W+' DONE');
