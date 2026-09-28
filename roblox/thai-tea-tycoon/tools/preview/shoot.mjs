import { chromium } from 'playwright';
import { mkdirSync } from "fs"; mkdirSync("shots", { recursive: true });
const views = JSON.parse(process.argv[2]);
const browser = await chromium.launch({ ...(process.env.CHROME ? { executablePath: process.env.CHROME } : {}), args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
page.on('console', m => { if (m.type() === 'error') console.log('console:', m.text()); });
page.on('pageerror', e => console.log('pageerror:', e.message));
for (const [name, qs] of Object.entries(views)) {
  await page.goto(`http://localhost:8765/render.html?${qs}`);
  await page.waitForFunction(() => document.title === 'done', null, { timeout: 280000 });
  await page.screenshot({ path: `shots/${name}.png` });
  console.log('shot', name);
}
await browser.close();
