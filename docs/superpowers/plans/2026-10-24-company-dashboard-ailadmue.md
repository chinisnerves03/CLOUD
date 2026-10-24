# Company Dashboard (AI ลัดมือ) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (native execution chosen by the owner's "start now" instruction).

**Goal:** A phone-first Artifact page where the owner views AI ลัดมือ clips/research/tasks and dispatches work to named agents.

**Architecture:** One self-contained `company-dashboard/dashboard.html` published as an Artifact. State in the `db` capability (collections `tasks, clips, ideas, research, log`). Dispatch through the `mcp` capability (Claude Code Remote `create_session`; vidIQ for research) with a queue-only fallback. Agent prompts live in `company-dashboard/agents/*.md` and are embedded into the page at build time by `company-dashboard/build.py`.

**Tech Stack:** plain HTML/CSS/JS (no libs), Python 3 build script, Node + Playwright for the stub-runtime test.

**Spec:** `docs/superpowers/specs/2026-10-24-company-dashboard-ailadmue-design.md`

## Global Constraints
- Thai UI text, font Prompt (`@font-face` is not available in an Artifact: use system Thai-capable stack `"Prompt","Sarabun",system-ui,sans-serif`)
- Layout works at 390px width, 16px side gutter, no horizontal scroll
- Colors as tokens on `:root`, dark mode via `prefers-color-scheme` and `[data-theme]`
- No secrets, keys or passwords stored in db or page
- Any task with a credit estimate > 0 shows a confirm dialog before dispatch
- Every agent prompt ends with: ไม่เดาตัวเลข, ระบุข้อจำกัด, ห้ามโพสต์ออกภายนอกเอง

## Review Focus
- Empty db (first load): every tab renders an empty state, no exception
- Dispatch fails (`null` mcp / `tool_error`): task stays `queued`, user sees the queue fallback hint
- Non-owner viewer: write controls hidden
- Very long prompt text (2,000 chars): no layout break
- Duplicate taps on "ส่ง": only one task document created

---

### Task 1: Agent prompts, seed data, build script
**Files:** Create `company-dashboard/agents/{scout,clipmaker,packager,analyst}.md`, `company-dashboard/seed/clips.json`, `company-dashboard/build.py`, `company-dashboard/test_build.py`
**Interfaces:** Produces `build.py: main() -> writes company-dashboard/dashboard.html` from `dashboard.src.html` replacing the marker `/*__AGENTS__*/` with a JSON object `{scout:{name,role,prompt,creditHint}, ...}`; `seed/clips.json` is a list of `{number,style,topic,durationSec,file,platforms:{ig:false,yt:false}}`.
- [ ] Step 1: write `test_build.py` asserting each agent file has a `# ` title, a `## หน้าที่` and a `## กติกา` section, `clips.json` parses with ≥ 14 items and unique `number`, and the built html contains no `/*__AGENTS__*/`
- [ ] Step 2: run `python3 company-dashboard/test_build.py`; expected FAIL
- [ ] Step 3: write the four agent files, the seed (clips 14–27 plus 15/16/17/19 metadata), and `build.py`
- [ ] Step 4: re-run test; expected PASS
- [ ] Step 5: commit

### Task 2: Dashboard UI + db views
**Files:** Create `company-dashboard/dashboard.src.html`, `company-dashboard/test_ui.js` (Playwright with an in-memory stub of `window.claude.use("db"|"user"|"mcp")`)
**Interfaces:** Produces page functions `render()`, `addTask({agent,prompt}) -> Promise<id>`, `setClipMetrics(number, {views,completionPct,skipPct,notes})`; tabs `overview, clips, research, command, log`.
- [ ] Step 1: write `test_ui.js`: with empty stub db every tab renders its empty-state text; with 3 stub clips the clips tab lists 3; tapping "ส่ง" twice rapidly creates exactly 1 `tasks` doc; a non-owner stub (`isOwner()=false`) hides the command form
- [ ] Step 2: run `node company-dashboard/test_ui.js`; expected FAIL
- [ ] Step 3: implement the page (tab bar, empty states, forms, `onSnapshot` subscriptions once per collection, debounce on submit)
- [ ] Step 4: run test; expected PASS
- [ ] Step 5: commit

### Task 3: Dispatch (mcp) with confirm and fallback
**Files:** Modify `company-dashboard/dashboard.src.html`, `company-dashboard/test_ui.js`
**Interfaces:** Produces `dispatch(taskId) -> Promise<'running'|'queued'>`; calls mcp server `Claude Code Remote` tool `create_session` with `{title, prompt, source_url:"https://github.com/chinisnerves03/CLOUD"}`; research button calls vidIQ `vidiq_instagram_tiktok_outlier_search` only after confirm.
- [ ] Step 1: add tests: creditHint>0 task shows confirm and does nothing on cancel; mcp stub rejecting `tool_error` leaves status `queued` and shows the fallback hint "สั่งผมในแชทว่า ทำคิว"; mcp `null` behaves the same; success sets `running` and stores `sessionId`
- [ ] Step 2: run; expected FAIL
- [ ] Step 3: implement `dispatch` and the confirm dialog
- [ ] Step 4: run; expected PASS
- [ ] Step 5: commit

### Task 4: Publish, seed, verify
**Files:** none new (artifact + db)
- [ ] Step 1: run `build.py`, publish `dashboard.html` with `capabilities:{db:{},user:{},mcp:{servers:[{server:"Claude Code Remote",tools:["create_session"]},{server:"vidIQ",tools:["vidiq_instagram_tiktok_outlier_search"]}]},sample:{}}`
- [ ] Step 2: seed `clips` from `seed/clips.json` with ArtifactData batch
- [ ] Step 3: `list` each written collection; read `tasks` with a lower `as_level`, expected: no write access shown
- [ ] Step 4: open on phone-width screenshot via Playwright against the stub for the layout check; say plainly what could not be tested (real mcp calls)
- [ ] Step 5: commit and push

### Task 5: Docs and handoff
**Files:** Create `company-dashboard/README.md`
- [ ] Step 1: write README (how to open on iPhone, how to dispatch, fallback "ทำคิว", cost rules, what is untested)
- [ ] Step 2: commit and push; report to the owner
