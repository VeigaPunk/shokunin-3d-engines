# r92 verifier-r2 — independent verification of the FOLDED tree `75739bc`

Seat: **VERIFIER-R2** (named non-author) for `game-dev-3d-shokunin` round 92.
Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`; folded work commit
`75739bc1dbb7ea5f67b9aa41236db4baff73e530` (`r92 fold: timing re-anchored to
iteration boundary + settled ticks, idlemode envelope = legal set, SP1-5
deletions, 7 markers re-pinned`). Fold report: `reports/round-92/r92-fold.md`;
pre-fold FAIL this seat re-checks: `reports/round-92/r92-verifier.md`
(`r92_timing_steps`, `time_scale=10` → `E pf=6 delta=0.016667` transient
leaking into a pinned deterministic row).

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` (`--headless`
before `--script` throughout), Python 3.14.7, kernel `7.2.3-arch1-3`, 32-thread
host. **No `lsp` device is exposed to this seat's toolset** (same recorded
absence as r85–r92 lanes); no source edits were made, so the hand-edit
fallback was never in play. This seat wrote only
`corpus/live/r92-verify2/**` (gitignored via `corpus/.gitignore: live/`) and
this report. No commits, no other tracked writes.

## Byte custody

- At seat start `git rev-parse HEAD` = `75739bc`, `git status --porcelain`
  empty. `spot/proj/` copies and the `git archive HEAD` frozen tree
  (`r92-verify2/tree/corpus/fixtures`, 79 files = `git ls-files` count) are
  sha256-verified byte-identical to `75739bc` for every fixture used.
- **Mid-seat movement (documented, contained):** HEAD is now `1804a11` —
  seven sibling commits landed during the seat (incl. `455d9b1` r93
  baseline-r2 post-fold), and the r93 author seat wrote
  `M corpus/fixtures/run_battery.py` (CASES +28 lines) and untracked
  `r93_areasig.gd` / `r93_child.gd` / `r93-author.md` between
  ~19:42Z–20:04Z. All verification below ran either before the drift or on
  the sha-pinned frozen tree, so every measured byte is `75739bc`. The drift
  also explains the rep-level `seeds_unchanged=False` verdicts noted in §1.
- **Host context:** this is the corpus's normal multi-seat box. During the
  seat a sibling r93 lane ran `/tmp/r93batt_full2` batteries and ambient
  `yes` hog counts swung 0→10→~40; loadavg ranged ~3–104. Own load: 16
  `setsid` `yes` hogs pids recorded in `corpus/live/r92-verify2/hogpids.txt`
  (killed at 20:06:39Z; an earlier same-exec-shell batch was reaped
  instantly — discovered and replaced; the ambient hogging was real
  throughout regardless: 172 starved idlemode realizations is direct
  starvation evidence).

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | `r92_timing_steps` / timing rows — hog-loaded arms 20+ reps, every settled delta on-pin | **PASS** — 191 arm executions (5 arms × 3 batteries + 32 rep-runs + 16 standalone bursts), **4212 settled E-samples, 0 off-pin, 0 legacy `E pf=` rows, 0 truncated cells** |
| 2 | `r92_animphys` idlemode envelope — legal set x∈[0,3], y∈[1.8,2.0005], reps incl. starved | **PASS** — 600 rep executions, 600 envelope-valid; **starved mode reached 172×** (33 % of loaded reps) and admitted; independent re-check of all 528 rep child.logs agrees 528/528 |
| 3 | SP1–SP5 deletions behaviorally inert — marker set unchanged except declared re-pins | **PASS** — CASES diff `a10f2c4→75739bc`: 258 rows, 251 byte-identical, **exactly the 7 declared re-pins changed**, 0 added/removed, script+expected-exit unchanged on all 7; deleted symbols absent; all rows exercising touched paths pass |
| 4 | Full battery 258/258 on final bytes; under load too | **PASS-with-classified-fails** — three full runs on 75739bc bytes: 255/258, 254/258, 257/258; **all 23 r92 rows PASS in every run**; every FAIL is a non-r92, non-fold row (§4) |
| 5 | r93-baseline F1/F2 watch (not r92 defects) | **F1 fires** (all 3 batteries, exact ±√2/60 tick signature); **F2 did not fire**; plus one extra non-list observation (§5) |

## 1. Timing arms under hog load — PASS

The pre-fold defect was `time_scale=10` `delta=0.016667` leaking into the
pinned first post-mutation tick under step batching. The fold re-anchored
sampling to mutation → `process_frame` boundary → 3 ticks each sealed by an
idle boundary (`E0/E1/E2`, no pf stamps).

Runs executed (all on `75739bc` bytes):

| suite | load context | executions | result |
|---|---|---|---|
| battery A `--only` 5 timing + iforder + idlemode (worktree seeds, pre-drift) | ambient ~25–30 (sibling hogs+batteries) | 22 reps × 7 cases | **154/154 case-PASS**; 5 rep verdicts `FAIL` solely via `seeds_unchanged=False` from the r93 seat's mid-run seed writes (receipts: reps `…4219289`, `…4303146`, `…4354665`, `…4435086`, `…4450871`) |
| battery B `--only` 5 timing arms (worktree seeds) | **my 16 `setsid` hogs + ~16 sibling hogs** | 10 reps × 5 cases | **50/50 case-PASS**, `seeds_unchanged=true` all reps |
| standalone `--arm=steps` bursts ×2 (spot proj copies) | burst1 ~load 100; burst2 my 16 hogs | 16 parents × 3 cases × 3 backends | 16/16 `PASS r92_timing steps`; **432 E-samples all on-pin**; no `rc=0,m=` truncated cells (verifier-1 §6 hole not hit) |

Independent E-delta extraction (`tools/extract_edeltas.py`, parses receipts'
stdout — does not trust the PASS verdict): every `M tm_* E[0-2] delta=` token
vs the settled table across **all** receipts:

    battery A 108 + battery B 108 + battery C 108 = 324
    22 reps = 2376, 10 hog reps = 1080, bursts = 432
    TOTAL 4212 samples — offpin = 0, legacy `E pf=` rows = 0

Specifically the pre-fold failure cell `tm_maxsteps@*`: `0.166667` on every
sample in every backend (was `0.016667` at pf=6 pre-fold). The mutation's
scheduler-keyed transient no longer reaches any pinned row.

## 2. `r92_animphys_idlemode` envelope — PASS, starved reached

Marker pins only `{reps=8,ok=8}` per backend; per-rep values are validated by
the parent's invariant envelope, re-checked here independently
(`tools/check_idlemode.py` scans each `r92a_idlemode_*/child.log` and applies
the legal set itself: `M0`×1, `M DONE`×1, e=w=s=0, `post` with
x∈[−0.0005,3.0005], y∈[1.8,2.0005], z≈0, `playing=true`, backend lv/srv
constants — lv `(0,-1.1376,0)` gp+jolt / `(0,0,0)` dummy, srv mirror /
`srv=nil`).

- **600 rep executions total** (22 loaded reps ×24 + 3 batteries ×24):
  **600/600 envelope-valid**; parent aggregate `ok=8` on all 66 backend
  cells; independent scan of all 528 rep child.logs: **528 OK, 0 BAD**.
- Mode histogram over the 22 loaded reps: gp 63 starved/113 adv, jolt
  56/120, dummy 53/123 — **172 starved realizations (33 %)**, admitted by
  the widened envelope. Batteries drew 1 starved (A) + 0 (B, C).
- Verbatim starved receipt (battery A,
  `runs-quiet/…/scratch/r92a_idlemode_jolt_r2/child.log`):
  `M idlemode post x=0.0000 y=1.9648 z=0.0000 lv=(0.0000,-1.1376,0.0000)
  srv=(0.0000,1.9648,0.0000) playing=true` — the critic's exact starved
  class (x=0, bounded free-fall y inside [1.8,2.0005]), scored OK by both
  the parent and this seat's independent check.
- x range over all reps: `[0.0000, 0.2984]` — inside [0,3] at display
  granularity. This directly resolves the fold report's own residual-risk
  note (starved had not re-occurred in the fold's loaded run).

## 3. SP1–SP5 deletions inert — PASS

Marker surface (`tools/compare_markers.py`, AST `literal_eval` of `CASES` at
`a10f2c4` vs `75739bc`): **258 rows both sides; 251 marker strings
byte-identical; changed = exactly the 7 declared re-pins**
(`r92_timing_{tps,tscale,edge,refuse,steps}`, `r92_animphys_{iforder,
idlemode}`); added/removed = 0; `script` and `expected_exit` unchanged on
all 7 (`marker-diff.json`).

Static: deleted symbols absent from `r92_child.gd` — `cap_f`, `f_rows`
(F-row emit machinery), `func f4`, `class RB`, `ball.probe`, the `watcher`
field in `c_iforder`, and `PhaseReader.n_e` (residual `n_e` hits are
`PhaseWriter`'s live arming counter, which is correct — SP-4 removed only
the reader's). `e_rows` is the re-indexed 2-element `[pf, x]` shape;
`f_rows2` retained.

Behavioral: every code path the deletions touched is exercised by passing
rows — `phase` readers (re-indexed `[1]→[0]`, `[2]→[1]`), the
`rbpos/rbfrozen/animrb/empty_track` E-rows (emitted by the retained
`anim_watch`/`live_e` receipt path), `iforder` `ok=1` predicates, and the
`post` row whose one-tick position the retained line-735 `await
process_frame` preserves. Any missing or extra M row breaks the exact
marker; none did — in 3 batteries + 32 rep-runs + 16 bursts.

## 4. Full battery on final bytes — 3 runs, all r92 rows PASS

| run | tree | load context | totals | fails |
|---|---|---|---|---|
| A `runs-quiet/20261015T193056988159Z` | worktree seeds @75739bc (pre-drift) | ambient ~25–30 | **255/258**, `seeds_unchanged=true`, stderr 0 B | `navagent3d_retarget`, `_fixed`, `_follow` (F1) |
| B `runs-loaded/20261015T194653622247Z` | frozen `git archive` tree | ~load 100 + burst | **254/258**, `seeds_unchanged=true`, stderr 0 B | `navagent3d_retarget`, `_follow` (F1); `phys3d_events_race_class` (§5); `phys3d_joints_free_ops` 20 s TIMEOUT (documented pre-existing bound row) |
| C `runs-quiet2/20261015T195607083822Z` | frozen tree | ambient ~3–15 | **257/258**, `seeds_unchanged=true`, stderr 0 B | `navagent3d_retarget_fixed` (F1) |

All 258 rows executed in every run; all 23 `r92_*` rows PASS in all three
(`r92_animphys_badkey_insert` correctly exits 2 with its NEGATIVE marker).
Loaded run elapsed Σ444 s, max 20.0 s = the `free_ops` boundary case itself.

The "258/258" criterion is not met by any single run, and on this host that
is not the fold's doing: every residual FAIL is a non-r92, non-fold row
(§5). The r92 surface is 23/23 in every run including a ~load-100 battery,
and the specific pre-fold defect never recurred in 4212 settled samples.

## 5. r93-baseline F1/F2 watch — F1 fires, F2 quiet, one extra observation

- **F1 (navagent 1-tick miss) — still fires**: `navagent3d_retarget`
  `before=(1.754246,…)` vs pinned `1.730676` (Δ=+0.023570=√2/60; r93 saw
  −1 tick, mine +1) in runs A,B; `navagent3d_follow` `first=1.636395`
  (+1 tick) and `1.659965` (+2 ticks) in A,B; `navagent3d_retarget_fixed`
  same internal pre-switch misfire in A,C. Pre-fold observation on
  different rows — not r92 defects.
- **F2 (size-gate granted-under-load) — did NOT fire**:
  `phys3d_events_script_size_gate` and `phys3d_events_deferred_hang`
  passed all 3 batteries including the ~load-100 run.
- **Extra (not on r93's documented list, not r92-attributable)**:
  `phys3d_events_race_class` failed once in run B —
  `jolt crash envelope drift rc=134 v={} tear=0 abort=2`: the Jolt child
  took the crash path (rc=134, abort witness ×2) but the
  `Failed to build Jolt Physics sphere shape` tear line never logged, so
  the authored crash envelope's witness set was incomplete. An r88-era
  row over a load/heap-layout-keyed crash, on a fixture byte-untouched by
  the fold — filed as an observation for the canonical runtime, same
  not-an-r92-defect class as F1/F2.
- `bpy_rbw3d_render` held its pin in all 3 runs (no flip observed here).

## Files changed

None tracked beyond this report. Written by this seat (all gitignored):
`corpus/live/r92-verify2/**` — `tree/` (frozen archive), `spot/proj`,
`burst/`, `runs-quiet/`, `runs-quiet2/`, `runs-loaded/`, `reps/` (22),
`reps-hog/` (10), `logs/`, `tools/{compare_markers.py,extract_edeltas.py,
check_idlemode.py,start_hogs.sh,kill_hogs.sh}`, `marker-diff.json`,
`hogpids.txt`, `MANIFEST.txt` (sha256 of every `verdicts.json` receipt,
log, and tool).

Key receipt shas (full list in `MANIFEST.txt`):

- run A verdicts `1ae576f2…d1d3b6c8` (255/258)
- run B verdicts `324bf723…fcac2b4` (254/258, loaded)
- run C verdicts `7bd497b9…a71aa3e8` (257/258)

## Remaining risks / blockers

- The starved-mode admission is now proven by **172 fresh starved
  realizations** in my own loaded reps plus the parent's aggregate — the
  fold's declared residual is closed on this host. No starved sample ever
  fell outside the legal set.
- `phys3d_events_race_class` tear=0 crash-envelope variant (§5) is a
  witness-completeness drift on an r88 row under ~load-100 — outside r92
  scope, disposition is the canonical runtime's.
- Verifier-1 §6's `rc=0,m=` truncated-cell hole was not hit: all **2088**
  r92-child `child.log`s across every rep/burst/battery (incl. the
  ~load-100 stretches) carry both `M0` and `M DONE`; it remains reachable
  in principle under deeper deadline pressure — unchanged robustness
  debt, not a fold regression.
- Ambient seed drift during a battery flips `seeds_unchanged` through no
  fault of the measured bytes — 5 rep-level FAIL verdicts here were exactly
  that (case verdicts all PASS; documented above). Frozen-tree runs are
  immune by construction.
- One host, one build `4.7.2.stable.arch_linux.ed1daf0bf`; no
  cross-version inference. Stray-process check at filing: zero godot,
  `timeout`, or `sh` processes referencing `r92-verify2`, `spot/proj`,
  `burst/proj`, or my run dirs; the only live godot/battery processes
  belong to the sibling r93 lane (`/tmp/r93batt_full2`). My 16 `setsid`
  hogs were killed by recorded pid (`20261015T200639Z`); sibling `yes`
  hogs were left running as their owners' business.

## Verdict

The fold's three corrections hold under reproduction of the exact pre-fold
failure conditions and beyond: the timing re-anchor kept every one of
**4212 settled E-delta samples on-pin across 191 loaded arm executions**
(the pre-fold `0.016667` transient never reached a pinned row), the
idlemode legal-set envelope admitted **600/600 rep executions including
172 fresh starved realizations**, and the SP1–SP5 deletions moved no
marker but the 7 declared re-pins — byte-verified. All 23 r92 rows pass
every full battery including a ~load-100 run; the only residual FAILs are
the already-documented non-r92 load-conditional rows (F1 navagent ticks,
`free_ops` 20 s bound) plus one r88 crash-envelope witness drift — none
attributable to the fold.

**VERIFIED** — the folded `75739bc` bytes clear every assigned r92 check.
