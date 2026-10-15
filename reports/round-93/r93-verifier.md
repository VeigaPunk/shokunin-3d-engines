# r93 verifier — wave-B gate on committed `661749f`

Seat: **VERIFIER** (non-author) for `game-dev-3d-shokunin` round 93. Assigned
tree: `661749f2039a4435da6a4cc85c850d829fa10fe6` ("r93 author: 7 areasig rows
(265 total) — in_step signal law, queue_free post-E, monitoring-in-dispatch
refusal, GP/Jolt splits, Dummy vacuity"). Author report:
`reports/round-93/r93-author.md`.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`
(`--headless` before `--script` throughout), Python 3.14.7, 32-thread host.
**No `lsp` device is exposed to this seat's toolset** (same recorded absence
as r85–r92 lanes); no source edits were made, so the hand-edit fallback was
never in play. This seat wrote only `corpus/live/r93-verifier/**` (gitignored
via `corpus/.gitignore: live/`) and this report. No commits, no other tracked
writes.

## Byte custody

- At seat start `git rev-parse HEAD` = `661749f`, `git status --porcelain`
  empty; `sha256sum` of `r93_areasig.gd` (`e4b04006…`), `r93_child.gd`
  (`fac6b439…`), `run_battery.py` (`81fb07ff…`) all byte-match the commit.
- **Mid-seat movement (documented, contained):** sibling seats committed
  `88c143e` (r93-scribe, report-only — `git diff 661749f 88c143e --stat` =
  `r93-scribe.md` only) and an r94 lane wrote untracked seeds
  (`r94_cannon.gd`, `r94_child.mjs`, `r94vendor/*`) at 18:45 local, inside my
  full-battery window. After my runs completed (18:52 local, post-report
  drafting) the same r94 lane appended its `r94_cannon_*` rows to the
  worktree `run_battery.py` (uncommitted `M`, 38 lines) — all r93-armed
  measurements below predate that edit, and `r93_areasig.gd` /
  `r93_child.gd` still sha-match `661749f` at filing. Every measured r93
  byte is `661749f`'s; the CASES diff in §1 was computed on committed blobs
  (`git show`), not the drifting worktree.
- **Host context:** this is the corpus's normal multi-seat box; during the
  seat, four sibling batteries ran concurrently (r93-critic frozen-tree,
  r93-simplifier, r93-reviewer, r94 tests). loadavg ranged ~100–127 — the
  "under load" condition was ambient and real throughout, no own hogs needed.

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | CASES diff is insertion-only, +7 rows, 265 total | **PASS** — AST `literal_eval` of `CASES` at `661749f^` vs `661749f`: 258→265, added = exactly the 7 `r93_areasig_*` tuples appended after `r92_timing_steps` (the former last row); removed=0, changed=0, dup-names=0; `script`/`flags`/`expected_exit` sane on all 7 |
| 2 | All 7 r93 rows pass on committed bytes, under load | **PASS** — `--only` battery at loadavg ~110: **7/7 PASS**, `seeds_unchanged=true`, parent stderr 0 lines each; full battery at loadavg ~100–127: **7/7 r93 rows PASS** (elapsed 1.8–4.6 s each, bound is 20 s) |
| 3 | Rep-stability: digest surface deterministic | **PASS** — 8 reps × 7 arms standalone under ambient load: **56/56 executions rc=0, stderr empty, stdout byte-identical per arm**, and each rep's `PASS` line byte-equals the pinned `CASES` marker (56/56 — checked against the marker strings directly, not the battery's own verdict) |
| 4 | Jolt order instability stays unpinned & confined | **PASS** — flip **reproduced live**: `multi_jolt` rep 5 emitted `pf21=[…@b2,…@b1]` / `pf35=[b2,b1]` vs `b1,b2` in the other 7; `^M` lines byte-identical across all 8 jolt reps (sha `e34bebb4…`); canonical M-surface absorbs the flip exactly as designed (`seqeq=-`,`pairs=-` on jolt+dummy; `seqeq=0 pairs=1` pinned on gp — gp order `entry b2,b1` vs `exit b1,b2` was deterministic across all reps) |
| 5 | Full battery 265 rows on final bytes | **PASS-with-classified-fails** — 259/265; all 7 r93 rows PASS; every FAIL is a non-r93 row (§3); `seeds_unchanged=False` caused solely by ambient r94 untracked writes (§2) |
| 6 | Fixture hygiene / red flags | **PASS** — bounded machinery (`timeout -s KILL 10` per child, `BATCH_BOUND_S=20` poll loop, per-case tick budgets, `_finish` → `quit(0)`); dirname charset validation on generated child dirs; children write only under `res://` of the per-run scratch project; `s=` counts SCRIPT ERROR/Parse/leak/crash lines; no `seq=` or F-multiplicity in M rows |

## 1. Marker surface — insertion verified, cells well-formed

`tools/compare_cases.py` (AST diff of `CASES` at `661749f^`→`661749f`):
258→265, single `insert` op of the 7 r93 tuples at the tail. Cell counts
9+12+6+9+6+9+3 = **54 child cells** = 18 cases × 3 backends, matching the
author report. Spot-pinned semantics verified in the markers themselves:
`freeq` pins `cls=post_e` + stale `ovn=ball` + `dup=body_shape_exited@25`;
`monsig` pins `e=1,et=Function blocked during in/out signal. Use
set_deferred("monitoring", true/false).`; `monoff0@dummy` pins `e=116` with
the two `Can't find overlapping …` texts; `telefr` pins `detected=0` gp vs
`detected=1 cls=no_if` jolt; `multi@dummy` pins full vacuity
(`entry_bodies=- … seteq=- seqeq=- pairs=-`, `nif=0`, `nsig=0`); `pre_if=0`
in every census. The `monsig@dummy` cell correctly shows `refused=0` (no
dispatch on Dummy → the write inside the handler never runs) — consistent
with the child's logic, not a pin error.

## 2. Batteries executed (all on `661749f` bytes)

| run | context | totals | notes |
|---|---|---|---|
| `--only` r93, `runs/20261015T213930782661Z` | loadavg ~110 | **7/7 PASS**, `seeds_unchanged=true` | verdicts `33dd2486…` |
| full, `runs/20261015T213926567519Z` | loadavg ~100–127, 4 sibling batteries | **259/265**, Σ544.5 s, max 20.03 s | verdicts `c78e028a…`; `seeds_unchanged=False` |
| rep sweep `reps/` | same ambient | 56 standalone arm executions, all byte-identical | incl. live jolt flip (§ table row 4) |

`seeds_unchanged=False` on the full run is pure ambient drift, byte-proven:
diffing `verdicts.json`'s `seed_digests` (before) against the post-run tree
yields **added = exactly the 6 untracked r94-lane files** (`r94_cannon.gd`,
`r94_child.mjs`, `r94vendor/{cannon-es.js,package.json,three.core.js,
three.module.js}`), **removed = 0, changed = 0**. Same documented mode as
r92-verifier2's mid-seat drift; non-causal for any FAIL.

## 3. Non-r93 failures — classification

| case | signature | class |
|---|---|---|
| `navagent3d_retarget` | `before=1.754246` vs pinned `1.730676`, Δ=+√2/60 | **documented F1** navagent 1-tick miss (identical value to r92-verifier2 run A) |
| `navagent3d_retarget_fixed` | same internal `before=1.754246` misfire | F1 |
| `navagent3d_follow` | `first=1.636395` | F1 (identical value to r92-verifier2) |
| `phys3d_events_script_size_gate` | `min_thr drift … sz_fetch granted` | **documented F2** granted-under-load (r93-author runs 2/3 saw same) |
| `phys3d_joints_free_ops` | TIMEOUT at the 20 s bound | **documented** bound row under ~load-120 |
| `navagent3d_detour_mut_ladder_region` | `step2 idx=0 expected=1` (exit 1) | **extra observation** — navagent-family conditional (map-publish tick quantization class, fc6d033 mechanism) on an r75–r78-era row byte-untouched by `661749f`; **not on the documented flake list** and no prior FAIL record found in `reports/`. One firing in ~load-120. Same not-an-r93-defect class as r92-verifier2's `race_class` note; disposition is the canonical runtime's |

`phys3d_events_deferred_hang` (third documented-trio member) and
`bpy_rbw3d_render` both held their pins in this run. All 23 r92 rows PASS —
the r92 fold's surface is undisturbed by the r93 landing.

## 4. Static review notes (non-blocking)

- Author report's arm→case table groups `moncycle` under `exits` and
  `monif`/`monoff` under `dispatch`; the committed `ARM_CASES` (and battery
  rows) put `moncycle`/`monoff0` under `dispatch` and `monif`/`monoff` under
  `writes`. Same 18-case union, same cells — doc-text nit only.
- `#` order diagnostics exist for gp (`entry b2,b1` / `exit b1,b2` — stable
  8/8) and dummy (empty) too; only the jolt instability is unpinned.
- Child `budget()` covers every case with a hard tick cap; `_sig_cls`
  `pre_if` exists as the law-violation class and stayed `0` everywhere.

## Files changed

None tracked beyond this report. Written by this seat (all gitignored):
`corpus/live/r93-verifier/{runs/…,reps/…,spot/proj,tools/{compare_cases.py,
rep_sweep.sh},MANIFEST.txt}` — 1181 receipt files hashed in `MANIFEST.txt`
(includes generated `r93t_*` child dirs and per-rep `multi_{gp,jolt,dummy}`
child.log archives).

Key receipt shas:
- r93-only verdicts `33dd2486…` (7/7, seeds_unchanged=true)
- full verdicts `c78e028a…` (259/265 under ~load 100–127)
- jolt multi M-lines, 8/8 reps `e34bebb4…`

## Remaining risks / blockers

- `navagent3d_detour_mut_ladder_region` fired once (§3) — new-name member of
  the documented navagent conditional family; not r93-attributable.
- The r93 surface pins a specific engine build
  (`4.7.2.stable.arch_linux.ed1daf0bf`); no cross-version inference. Jolt
  flip observed once in 8 reps (~12 %, consistent with boundary's rate).
- One doc-text nit (§4 arm grouping) — cosmetic.
- Stray-process check at filing: zero godot/`timeout`/`sh` processes
  referencing `r93-verifier`, `r93t_`, or my run dirs; live godot/battery
  processes all belong to sibling seats.

## Verdict

The insertion is clean (258→265, zero prior rows touched), every r93 cell is
byte-pinned and reproduced **byte-exactly on 64 independent executions**
(7 battery + 56 rep + 1 full-battery pass each per row) under sustained
~load 100–127, the one documented instability (Jolt per-body order) was
reproduced live and verified confined to `#` diagnostics with an identical
M-surface, and all six non-r93 FAILs classify to documented load-conditional
rows plus one navagent-family observation on an untouched legacy row.

**VERIFIED** — committed `661749f` clears the wave-B gate.
