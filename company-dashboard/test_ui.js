const { chromium } = require('/opt/node-tools/node_modules/playwright');
const { execFileSync } = require('child_process');
const path = require('path');
execFileSync('python3', [path.join(__dirname, 'build.py')]);
const URL = 'file://' + path.join(__dirname, 'dashboard.html');

const STUB = `
(() => {
  const opts = window.__OPTS || {};
  const data = JSON.parse(JSON.stringify(opts.seed || {}));
  const subs = {};
  const snap = c => ({ docs: Object.entries(data[c] || {}).map(([id, d]) => ({ id, exists: true, data: () => JSON.parse(JSON.stringify(d)) })), size: 0, empty: false });
  const fire = c => (subs[c] || []).forEach(f => f(snap(c)));
  let n = 0;
  const db = {
    collection: c => ({
      onSnapshot(next) { (subs[c] = subs[c] || []).push(next); next(snap(c)); return () => {}; },
      async add(d) { const id = c + '_' + (++n); (data[c] = data[c] || {})[id] = { ...d }; window.__log.push(['add', c, id]); fire(c); return { id }; },
    }),
    doc: p => { const [c, id] = p.split('/'); return {
      async get() { const d = (data[c] || {})[id]; return { id, exists: !!d, data: () => d && { ...d } }; },
      async set(d) { (data[c] = data[c] || {})[id] = { ...d }; window.__log.push(['set', c, id]); fire(c); },
      async update(d) { Object.assign(data[c][id], d); window.__log.push(['update', c, id, JSON.stringify(d)]); fire(c); },
      async delete() { delete data[c][id]; fire(c); } }; },
  };
  window.__log = []; window.__data = data; window.__fast = true;
  const mcp = opts.mcp === 'null' ? null : {
    async callTool(server, tool, input) {
      window.__log.push(['mcp', server, tool, JSON.stringify(input)]);
      if (server === 'vidIQ') { const q = (opts.vidiq || {})[tool]; const r = q && q.length > 1 ? q.shift() : q && q[0]; if (r === undefined) throw { code: 'tool_error', message: 'no stub for ' + tool }; return { content: [{ type: 'text', text: '' }], payload: r }; }
      if (opts.mcp === 'reject') throw { code: 'tool_error', message: 'boom' };
      return { content: [{ type: 'text', text: 'ok' }], payload: { session_id: 'sess_1' } };
    } };
  const ns = { db, user: { isOwner: async () => opts.owner !== false }, mcp, sample: null };
  window.claude = { use: async name => (name in ns ? ns[name] : null) };
})();`;

async function run(name, opts, fn) {
  const b = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
  const ctx = await b.newContext({ viewport: { width: 390, height: 844 } });
  const pg = await ctx.newPage();
  const errors = [];
  pg.on('pageerror', e => errors.push(String(e)));
  await pg.addInitScript('window.__OPTS = ' + JSON.stringify(opts || {}) + ';' + STUB);
  await pg.goto(URL);
  await pg.waitForFunction(() => document.getElementById('who').textContent !== 'กำลังเชื่อมต่อ…');
  try { await fn(pg); if (errors.length) throw new Error('page errors: ' + errors.join('; ')); console.log('PASS', name); }
  catch (e) { console.log('FAIL', name, '-', e.message); process.exitCode = 1; }
  await b.close();
}
const eq = (a, b, m) => { if (a !== b) throw new Error(`${m}: got ${a}, want ${b}`); };
const tab = (pg, t) => pg.click(`nav.tabs button[data-go="${t}"]`);
const text = (pg, t) => pg.textContent('#t-' + t);
const logs = (pg, kind, coll) => pg.evaluate(([k, c]) => window.__log.filter(l => l[0] === k && (!c || l[1] === c)).length, [kind, coll]);
const send = async (pg, agent, prompt) => { await tab(pg, 'command'); await pg.selectOption('#cmd-agent', agent); await pg.fill('#cmd-prompt', prompt); };

(async () => {
  await run('empty db renders every tab', {}, async pg => {
    for (const [t, want] of [['overview', 'ยังไม่มีงาน'], ['clips', 'ยังไม่มีคลิป'], ['research', 'ยังไม่มีผลสำรวจ'], ['log', 'ยังไม่มีงาน']]) {
      await tab(pg, t); if (!(await text(pg, t)).includes(want)) throw new Error(t + ' lacks empty state');
    }
    await tab(pg, 'command'); eq(await pg.locator('#cmd-send').count(), 1, 'command form');
  });
  await run('clips tab lists seeded clips', { seed: { clips: { a: { number: 14, style: 's', topic: 't14', durationSec: 31 }, b: { number: 15, style: 's', topic: 't15', durationSec: 29 }, c: { number: 16, style: 's', topic: 't16', durationSec: 38 } } } }, async pg => {
    await tab(pg, 'clips'); eq(await pg.locator('.clip').count(), 3, 'clip cards');
  });
  await run('double tap creates one task and dispatches', {}, async pg => {
    await send(pg, 'packager', 'เขียนแคปชั่นคลิป 27');
    await pg.evaluate(() => { const b = document.getElementById('cmd-send'); b.click(); b.click(); });
    await pg.waitForFunction(() => window.__log.some(l => l[0] === 'mcp'));
    await pg.waitForTimeout(100);
    eq(await logs(pg, 'add', 'tasks'), 1, 'task docs'); eq(await logs(pg, 'mcp'), 1, 'dispatch calls');
    const st = await pg.evaluate(() => Object.values(window.__data.tasks)[0].status); eq(st, 'running', 'status');
  });
  await run('credit task asks for confirmation; cancel makes nothing', {}, async pg => {
    await send(pg, 'clipmaker', 'ทำคลิป'); await pg.click('#cmd-send');
    await pg.waitForSelector('#m-cancel'); await pg.click('#m-cancel'); await pg.waitForTimeout(100);
    eq(await logs(pg, 'add', 'tasks'), 0, 'task docs after cancel');
    await pg.click('#cmd-send'); await pg.waitForSelector('#m-ok'); await pg.click('#m-ok');
    await pg.waitForFunction(() => window.__log.some(l => l[0] === 'mcp')); eq(await logs(pg, 'add', 'tasks'), 1, 'task docs after confirm');
  });
  await run('dispatch error keeps task queued with fallback hint', { mcp: 'reject' }, async pg => {
    await send(pg, 'packager', 'x'); await pg.click('#cmd-send'); await pg.waitForFunction(() => document.getElementById('cmd-msg') && !document.getElementById('cmd-msg').hidden);
    const t = await pg.evaluate(() => Object.values(window.__data.tasks)[0]); eq(t.status, 'queued', 'status'); if (!t.lastError.includes('boom')) throw new Error('lastError missing');
    if (!(await pg.textContent('#cmd-msg')).includes('ทำคิว')) throw new Error('fallback hint missing');
  });
  await run('mcp null keeps task queued', { mcp: 'null' }, async pg => {
    await send(pg, 'analyst', 'x'); await pg.click('#cmd-send'); await pg.waitForFunction(() => document.getElementById('cmd-msg') && !document.getElementById('cmd-msg').hidden);
    eq(await pg.evaluate(() => Object.values(window.__data.tasks)[0].status), 'queued', 'status');
  });
  await run('non-owner cannot see the command form', { owner: false }, async pg => {
    await tab(pg, 'command'); eq(await pg.locator('#cmd-send').count(), 0, 'send button'); if (!(await text(pg, 'command')).includes('เฉพาะเจ้าของ')) throw new Error('no notice');
  });
  await run('very long prompt does not widen the page', { seed: { tasks: { t1: { agent: 'scout', prompt: 'ก'.repeat(2000), status: 'queued', createdAt: 1 } } } }, async pg => {
    for (const t of ['overview', 'log', 'command']) { await tab(pg, t); const w = await pg.evaluate(() => document.documentElement.scrollWidth - window.innerWidth); if (w > 0) throw new Error(t + ' overflows by ' + w); }
  });

  const ACC = [{ platformAccountId: 'A1', username: 'ailadmue', accessLevel: 'owner', publishingAvailable: true }];
  const calls = (pg, tool) => pg.evaluate(t => window.__log.filter(l => l[0] === 'mcp' && l[2] === t).map(l => JSON.parse(l[3] || '{}')), tool);
  await run('IG: no connected account shows how to connect', { vidiq: { vidiq_instagram_connected_accounts: [{ accounts: [] }] } }, async pg => {
    await tab(pg, 'ig'); await pg.click('#ig-check'); await pg.waitForSelector('#ig-msg');
    if (!(await pg.textContent('#ig-msg')).includes('ยังไม่มีบัญชี')) throw new Error('no guidance');
  });
  await run('IG: insights are stored and linked to a clip', { seed: { clips: { c14: { number: 14, style: 's', topic: 'บทที่14', durationSec: 31 } } }, vidiq: { vidiq_instagram_connected_accounts: [{ accounts: ACC }], vidiq_instagram_owner_insights: [{ status: 'ok', media: [{ id: 'r1', caption: 'x', plays: 900, skipRate: 0.62, watchedPercentage: 0.35, shares: 3, saves: 7, timestamp: '2026-10-20T00:00:00Z' }] }] } }, async pg => {
    await tab(pg, 'ig'); await pg.click('#ig-check'); await pg.waitForSelector('#ig-sync:not([disabled])'); await pg.click('#ig-sync');
    await pg.waitForSelector('[data-reel="r1"]');
    const r = await pg.evaluate(() => window.__data.igreels.r1); eq(r.views, 900, 'views'); eq(r.skipPct, 62, 'skipPct'); eq(r.completionPct, 35, 'completionPct');
    await pg.selectOption('#link-r1', '14'); await pg.waitForFunction(() => window.__data.clips.c14.metrics && window.__data.clips.c14.metrics.skipPct === 62);
    eq(await pg.evaluate(() => window.__data.clips.c14.platforms.ig), true, 'ig flag');
  });
  await run('IG: publish asks first, cancel sends nothing, confirm runs upload then publish', { vidiq: { vidiq_instagram_connected_accounts: [{ accounts: ACC }], vidiq_video_upload: [{ videoUrl: 'https://v/hosted.mp4' }], vidiq_instagram_publish_reel: [{ status: 'IN_PROGRESS', containerId: '123' }, { status: 'PUBLISHED', permalink: 'https://ig/p' }] } }, async pg => {
    await tab(pg, 'ig'); await pg.click('#ig-check'); await pg.waitForSelector('#pub-go');
    await pg.fill('#pub-url', 'https://example.com/a.mp4'); await pg.fill('#pub-cap', 'hello');
    await pg.click('#pub-go'); await pg.waitForSelector('#m-cancel'); await pg.click('#m-cancel'); await pg.waitForTimeout(100);
    eq((await calls(pg, 'vidiq_instagram_publish_reel')).length, 0, 'publish calls after cancel');
    await pg.click('#pub-go'); await pg.waitForSelector('#m-ok'); await pg.click('#m-ok');
    await pg.waitForFunction(() => document.getElementById('pub-msg') && document.getElementById('pub-msg').textContent.includes('สำเร็จ'));
    const pub = await calls(pg, 'vidiq_instagram_publish_reel');
    eq(JSON.stringify(pub[0]), JSON.stringify({ platformAccountId: 'A1', videoUrl: 'https://v/hosted.mp4', caption: 'hello' }), 'first publish args');
    eq(JSON.stringify(pub[1]), JSON.stringify({ platformAccountId: 'A1', containerId: '123' }), 'continuation args');
    eq((await calls(pg, 'vidiq_video_upload'))[0].url, 'https://example.com/a.mp4', 'upload url');
  });
  await run('IG: a publish error stops without retrying', { vidiq: { vidiq_instagram_connected_accounts: [{ accounts: ACC }], vidiq_video_upload: [{ videoUrl: 'https://v/h.mp4' }], vidiq_instagram_publish_reel: [{ error: { message: 'bad caption' } }] } }, async pg => {
    await tab(pg, 'ig'); await pg.click('#ig-check'); await pg.waitForSelector('#pub-go');
    await pg.fill('#pub-url', 'https://example.com/a.mp4'); await pg.click('#pub-go'); await pg.waitForSelector('#m-ok'); await pg.click('#m-ok');
    await pg.waitForFunction(() => document.getElementById('pub-msg').textContent.includes('ไม่สำเร็จ'));
    eq((await calls(pg, 'vidiq_instagram_publish_reel')).length, 1, 'publish attempts');
  });
})();
