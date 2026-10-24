// usage: node render_worker.mjs <scene.html> <outDir> <startFrame> <endFrameExclusive> <fps> [jpegQuality]
// Each worker owns one headless Chromium and screenshots seek(t) for its frame range.
import { createRequire } from 'module';
import { pathToFileURL } from 'url';
const require = createRequire(import.meta.url);
const { chromium } = require('playwright');
const [html, outDir, a, b, fps, q = '92'] = process.argv.slice(2);
const browser = await chromium.launch({ args: ['--font-render-hinting=none', '--disable-lcd-text'] });
const page = await browser.newPage({ viewport: { width: 1080, height: 1920 }, deviceScaleFactor: 1 });
page.on('pageerror', e => { console.error('PAGEERROR', e.message); process.exitCode = 3; });
await page.goto(pathToFileURL(html).href);
for (let f = +a; f < +b; f++) {
  const t = f / +fps;
  await page.evaluate(t => window.seek(t), t);
  await page.screenshot({ path: `${outDir}/f${String(f).padStart(5, '0')}.jpg`, type: 'jpeg', quality: +q });
}
await browser.close();
