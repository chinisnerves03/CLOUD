# Compatibility matrix

**v1.0.0 candidate: every runtime row below is NOT TESTED IN GAME for this
candidate.** A running game window identified 0.40.3.0.290897, but this candidate
was not loaded. Historical v0.6.x runs do not validate v0.9.9 or v1.0.0.
Offline coverage now includes every catalog family, with missing-signal,
active-supercharger, reset/switch, stale and CSV fallback cases.

| Target | Adapter | Offline | In game | Notes |
|---|---|---|---|---|
| Any vehicle | `universal` | Covered by mocks | NOT RUN | Reads supported electrics and fails safely |
| Gavril D-Series, engine unconfirmed | `gavril_dseries_generic` | Detection tested | NOT RUN | Does not claim V8 compatibility |
| Gavril D-Series V8 | `gavril_dseries_v8` | Detection and JBeam structure tested | NOT RUN | Includes physics-only `pickup_intake_v8` turbo part; requires in-game validation |

Live target application tries the native turbocharger `setWastegateOffset`
method relative to the selected part's wastegate setting, falling back to
`electrics.turboBoostMax` when that setting is unavailable. A vehicle with no
supported runtime setter operates in monitor-only mode; TurboCraft turbo size
parts can still be adjusted through Vehicle Configuration > Tuning.
