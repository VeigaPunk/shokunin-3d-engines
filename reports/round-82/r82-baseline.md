# game-dev-3d round 82 — frozen before-state + battery replay + post-commit re-verification (seat: baseline)

Baseline replay for the r82 move: two arms declared (g3d-author brief) —
(A) evalcat residual fold, xconnector X7: ~6 bare classes folded inside
`arm_evalcat` before `closed` under the closed-set falsifier
(`violations=0` must hold), and (B) parser-hazard pinned cells,
xconnector X6: forged `violations=0` mid-stream, `dup_flush` physical
last-wins, binjunk decode behavior, detach-child EOF-hold — contract
pins of measured parser behavior, not safety claims. Declared
invariant under test: **prior 118 ARM rows byte-identical; falsifier
liveness re-verified**.

This round the work commits *did* land during the measurement window:
freeze + full replay ran on pre-move HEAD `31cf56a` (clean `git
archive` extract), then post-commit re-verification ran on the live
worktree as `0619300`, `7b4615b`, and `e79e004` landed in sequence.
Cell-by-cell drift table below.

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (built 2026-09-01 —
same build as r79/r80/r81), `/usr/bin/godot` =
4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7, Node v24.21.0,
three.js 0.186.1 (tracked lockfile).

## Frozen tree (pre-move baseline @ 31cf56a)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r82-baseline/frozen/frozen-tree.tar

- Frozen commit: `31cf56a6321cb406c181f190e3008fe7ce5dcf96`
  (`r81 report-last: adjudicator ADMIT (reorder+parse-survival on bpy,
  evalcat 8->14), verifier 6/6 AGREE on fd75567, reviewer LOW-only; r80
  late seat reports folded`) — the last pre-r82 commit; contains the
  r81 arms (`65b2f26` X1 reorder fabrication + 6 evalcat ext rows) and
  the r81 simplifier-fold (`fd75567`).
- Archive sha256
  `8311012f71dcd20fa28f4526f0691d606129e3cf0bec7c1e470fcaf58cf868a3`,
  377 tar members (346 files + 31 dir entries); file-member list
  `comm`-clean vs `git ls-files` — **0 diff lines both directions** on
  the extract at `corpus/live/r82-baseline/frozen-extract/`.
- Frozen fixture digests (pre-move): `bpy_sync_probe.py` sha256
  `a4b1f94bff08af47c63b86df0fac3f9fa0e481ad5aa6d48aa81947d342a52023`
  (1262 lines, reorder arm + evalcat ext present), `bpy_battery.py`
  sha256 `111568eec55fe1e489cc8ec6d41b8c2934611466537749d0dace68601fb44e4e`
  (409 lines; 74 cases per receipt), `run_battery.py` sha256
  `22a1966dac431a5dddcd071b990911254ac572f1942dd1d374027529938c8bdb`
  (890 lines), `timeout_descendant.py` sha256
  `c3a52834c19bf6c6ed8bf177b59bbfd541f08192141786d35c8303bed181e460`.
  All four identical to the r82-simplifier seat's recorded arrival SHAs
  (`corpus/live/r82-simplifier/arrival-shas.txt`, taken 2026-10-14
  12:19 -03:00) — two-seat corroboration of the pre-move surface.
- All writes confined to gitignored `corpus/live/r82-baseline/`
  (`corpus/.gitignore:1` → `live/`; `git check-ignore -v` confirmed)
  plus this report path. No git mutations performed by this seat.

## bpy battery — frozen pre-move — 74/74, byte-identical to prior receipts

    cd corpus/live/r82-baseline/frozen-extract
    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r82-baseline/runs

Receipt `runs/bpy-20261014T152042504539Z/verdicts.json`:

- `verdict` **PASS**; `totals: cases=74 pass=74 fail=0 (signal_fail=0
  quirk_drift=0)`; `launch_ok` implied by `probe_exit=0`,
  `done_marker=true`, `fatal_arms=[]`, `n_arm_lines=122`;
  `probe.stderr.txt` 0 bytes; `probe.stdout.txt` 11235 bytes / 128
  physical lines.
- `probe.stdout.txt` **byte-identical** (`diff` empty) to BOTH newest
  prior receipts on the same HEAD state:
  `corpus/live/runs/bpy-20261014T150509341880Z` (15:05 worktree run)
  and the sibling's own baseline
  `corpus/live/r82-simplifier/baseline-runs/bpy-20261014T151911682463Z`
  (15:19). Tuple comparison of all 74 (case → verdict, observed) rows
  vs each receipt: **0 mismatches**. Three-way cross-seat agreement on
  the pre-move ARM surface.
- Stream anatomy (pins the r82 diff anchors): `^ARM ` lines = 123
  physical / 122 unique `(arm,point,layer)` keys — lines 1–118 are the
  **prior 118 ARM rows** (112 r80-era + 6 r81 ext, ending with
  `ARM evalcat | closed | EDGE | violations=0 …` at line 118); lines
  119–124 the r81 reorder block (5 `^ARM` physical, `dup` key collapses
  to one parsed cell; line 121 `REORDERGLUE::…` fails `^ARM` → dropped,
  not misattributed); lines 125–128 `PROBE_DONE` / version / quit.
  Reference snapshot `corpus/live/r82-baseline/prior-118-arm-rows.txt`
  sha256 `d8907e30aced62b83f3f1bb815fb5b1532c21695ded1f45e0f47656ea8469bfa`.

## Godot battery — frozen — 176/176 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r82-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T152117151755Z/verdicts.json`: `verdict` PASS;
`totals: cases=176 pass=176 fail=0 ordinary=131 negative_controls=45
probes=4`; `seeds_unchanged=true`; Godot
4.7.2.stable.arch_linux.ed1daf0bf. Mutation probe
`mutant_body3d_contact` detected as pinned (`detected=true`,
`seeds_unchanged=true`, bounded_claim intact). Tuple comparison of all
176 (case → verdict, exit, observed) rows vs the r81-baseline run
`corpus/live/r81-baseline/runs/20261014T143659306553Z`: **0
mismatches**.

## Node three.js suites — frozen — 31/31

Post `npm ci` (three@0.186.1 per tracked lockfile; 1 package added, 0
vulnerabilities) inside `frozen-extract/corpus/fixtures/three`;
receipts under `corpus/live/r82-baseline/receipts/run_*.json` via
`--receipt`:

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true — total 31/31

## Post-commit re-verification — three r82 commits

The r82 work landed mid-session as **three** commits (all times UTC,
from `git reflog`):

    0619300370e9008c081a923c3c85384f50763a8f  15:38:26
    r82: evalcat residual fold (update_tag + custom-setter + 4
    witnesses, catalogue 14->20) + parser-hazard pinned cells (forge
    directions, dup_flush, binjunk, detach EOF) + critic fold (split
    forge invariant — genuine-cell check independent of marker)

    7b4615bc8ece9fbb0c6d9f6054e73a950992a8aa  15:48:49
    r82 refinement: pre-redirect fflush preserves the startup banner
    (83/83 green)

    e79e00464463694970f32539b8588cfd02a344ec  15:49:30
    r82 simplifier-fold: dead held param off _ec_edge1 (16 call
    sites), dead dg0 binding, stale line-refs fixed — stdout sha
    6a98c570 byte-identical

`git show --stat` per commit: `0619300` = **2 files, +542/−3**
(`bpy_sync_probe.py` +344, `bpy_battery.py` +198/−3); `7b4615b` = probe
file only, +10/−2; `e79e004` = probe +45/−45-ish fold plus 4-line
battery touch (+25/−24 total). Across all three: **no `.gd` fixture,
`run_battery.py`, `timeout_descendant.py`, or any
`corpus/fixtures/three/` file touched** → sibling-battery surfaces
pinned at the fixture-digest level.

### bpy — live worktree replay ×3 — 83/83, prior 118 rows byte-identical

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r82-baseline/runs-post{,2,3}

Three post-commit receipts, one per commit:

| receipt | HEAD | verdict | cases | n_arm_lines | stdout sha256 |
|---|---|---|---|---|---|
| `runs-post/bpy-20261014T153853939143Z` | `0619300` | PASS | 83/83 | 131 | (banner absent — see below) |
| `runs-post2/bpy-20261014T154906198444Z` | `7b4615b` | PASS | 83/83 | 131 | `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` |
| `runs-post3/bpy-20261014T155258412399Z` | `e79e004` | PASS | 83/83 | 131 | `6a98c570…defc3` — **byte-identical** to `7b4615b` receipt |

- `n_arm_lines=131` = 134 physical `^ARM` lines − 3 key-collisions
  (forged↔genuine `closed`, reorder `dup` ×2, hazard `dup_flush` ×2).
- `e79e004` receipt vs `7b4615b` receipt: `diff` empty — the
  simplifier-fold's "stdout sha 6a98c570 byte-identical" claim
  **independently reproduces** on this seat.
- `0619300`→`7b4615b` stream delta: exactly one non-ARM line — `0a1 >
  Blender 5.2.1 LTS (hash 9e2066aef7ef built 2026-09-01 00:24:57)`.
  At `0619300` the pending C-level startup banner was swallowed by the
  `_ec_x2_instance_refused` fd1→devnull redirect; the `7b4615b`
  pre-redirect `fflush` lands it at line 1. ARM rows unaffected.

Prior-118 check (`tools/postcommit_verify.py` vs
`prior-118-arm-rows.txt`), identical result on all three receipts:

- **Ordered subsequence: PASS — 118/118 prior rows present,
  byte-identical, same relative order.** This is the author-contract
  cell, and it holds.
- Positions: prior rows 1–78 at **identical** positions; row inserted
  at ARM index 79 = the ARM-B forged `closed` row (`violations=0
  forged=parent_midstream`, between the `vis` block and `rna_write`);
  prior rows 79–117 shifted +1 (bytes unchanged); 8 new `ext2_*` rows
  at indices 119–126 (inside evalcat, before `closed`, per the brief);
  prior row 118 (`closed`) byte-identical at new index 127 (+9).
- **Falsifier liveness**: two `evalcat|closed|EDGE` rows share the key
  — forged at 79, genuine at 127 — last-wins resolves the cell to the
  genuine row (`events=evaluated_depsgraph_get|…`, `violations=0`); the
  forgery did not mask it, and `evalcat_closed_set` passes under the
  new genuine-cell check.
- Battery-level: 9 new cases (`evalcat_ext2_update_tag`, `_custom_mw`,
  `_libraries_load`, `_instance_empty`, `_instance_refused`,
  `_batch_remove`, `_evalget_unlinked`, `_evalget_freed`,
  `hazard_dup_flush_lastwins`), 0 dropped; all 74 prior cases keep
  identical (verdict, observed) tuples — **0 mismatches**.
- New hazard stream cells: `ARM hazard | dup_flush | PARSE | src=row1
  v=first` + `src=row2_forged v=forged` (physical last-wins pin;
  resolves to `forged` — the demonstrated hazard, documented as
  contract).

### three.js — live worktree re-run — 31/31

Six suites re-run post-commit on the live tree (suite `.mjs` files +
`package-lock.json` untouched by all three r82 commits): **31/31
PASS, seedsUnchanged=true** — receipts `receipts/*.post.json`. Count
stable.

### Godot — live worktree re-runs — 176/176; first run's FAIL = concurrent-churn trip, second clean

Two post-commit runs:

- `runs-post/20261014T153938654006Z` (started 15:39:38Z, straddling
  `0619300`→`7b4615b`): `totals: cases=176 pass=176 fail=0
  ordinary=131 negative_controls=45 probes=4`; mutation
  `detected=true`, crash/stream/tree probes all ok — but battery
  `verdict` FAIL on `probe.seeds_unchanged=false`. Root cause is
  **concurrent worktree churn, not commit drift**: the probe's own
  before/after digests show exactly one flip — `bpy_sync_probe.py`
  `061cc21e…` (the `0619300` bytes, still in place at its snapshot) →
  `33091ec1…` — the *then-uncommitted* `fflush` edit that became
  `7b4615b` 9 minutes later. The detector did its job; no `.gd`
  fixture and no tracked r82 content changed mid-run.
- `runs-post2/20261014T154923570887Z` (post-settle): `verdict`
  **PASS**; `totals: cases=176 pass=176 fail=0 ordinary=131
  negative_controls=45 probes=4`; `seeds_unchanged=true`,
  `probe.seeds_unchanged=true`, `detected=true`. Tuple comparison of
  all 176 rows vs the frozen run: **0 mismatches**.

(Its seed snapshots read `07ec83e3…`/`045102a8…` — the `e79e004`
values: the commit landed ~7 s into the run, before the harness's own
snapshot window, which is self-consistent — before==after — and all
`.gd` bytes are identical across the boundary anyway.)

## Byte-stability summary (cell-by-cell)

| surface | pre-move frozen @ `31cf56a` | post-commit (`0619300`→`7b4615b`→`e79e004`) | drift |
|---|---|---|---|
| bpy cases | 74/74 PASS | 83/83 PASS on all three receipts | +9 cases (8 ext2 + 1 hazard), 0 dropped, 0/74 prior tuple mismatches |
| prior 118 ARM rows | snapshot sha `d8907e30…` | 118/118 byte-identical ordered subsequence on all three receipts | none in bytes; positions +1 for rows 79–117 (forge @79), `closed` +9 — all attributable to declared insertions |
| ARM stream size | 122 keys / 123 `^ARM` physical | 131 keys / 134 physical | +9 keys (8 ext2 + 1 hazard), +11 physical (incl. 2 `closed`-key, 2 `dup_flush`-key rows) |
| falsifier | `closed violations=0` live | genuine survives forged `violations=0` @79 via last-wins + genuine-cell check | holds on all three |
| reorder block (r81) | rows 119–124, glue dropped | same 5 `^ARM` rows + `REORDERGLUE` drop, indices 128–133 | shifted, byte-identical |
| non-ARM stdout | version line tail-anchored @126 | banner absent @`0619300`; banner at line 1 @`7b4615b`/`e79e004` | one line, explained by the fflush refinement; stdout sha `6a98c570…` stable across the last two commits |
| Godot battery | 176/176 + 4 probes | post-settle 176/176 + 4 probes PASS, 0/176 tuple mismatches | none; interim FAIL was seed-detector tripping on the pre-commit `fflush` edit mid-run |
| three.js | 31/31, seeds unchanged | 31/31, seeds unchanged | none |
| fixtures (siblings) | digests above | `run_battery.py`/`timeout_descendant.py`/all `.gd`/three/* untouched by all three commits | none |

## Receipts / scratch (all inside write scope)

- `corpus/live/r82-baseline/frozen/frozen-tree.tar` — `git archive
  HEAD` @ `31cf56a`, sha256 `8311012f…` (377 members / 346 files,
  comm-clean)
- `corpus/live/r82-baseline/frozen-extract/` — replay scratch tree
  (gitignored; + gitignored `node_modules` via `npm ci`)
- `corpus/live/r82-baseline/runs/` —
  `bpy-20261014T152042504539Z` (frozen bpy 74/74),
  `20261014T152117151755Z` (frozen godot 176/176 + 4 probe verdicts)
- `corpus/live/r82-baseline/runs-post/` —
  `bpy-20261014T153853939143Z` (bpy 83/83 @ `0619300`),
  `20261014T153938654006Z` (godot 176/176, seed-trip FAIL — concurrent
  churn)
- `corpus/live/r82-baseline/runs-post2/` —
  `bpy-20261014T154906198444Z` (bpy 83/83 @ `7b4615b`, stdout sha
  `6a98c570…`), `20261014T154923570887Z` (godot 176/176 PASS,
  post-settle)
- `corpus/live/r82-baseline/runs-post3/` —
  `bpy-20261014T155258412399Z` (bpy 83/83 @ `e79e004`, stdout
  byte-identical to post2)
- `corpus/live/r82-baseline/receipts/run_*.json` (frozen) +
  `*.post.json` (post-commit) — twelve Node suite receipts
- `corpus/live/r82-baseline/prior-118-arm-rows.txt` — canonical
  prior-row reference, sha256 `d8907e30…`
- `corpus/live/r82-baseline/tools/postcommit_verify.py` — the
  subsequence/position checker used above

## Limits

- Single host, single Blender/Godot/Node build; one replay per surface
  per commit — zero case failures on any completed run, no flake-retry
  needed.
- The `0619300` bpy receipt's emission (~15:38:5xZ) precedes the proven
  flip window (≥15:39:38Z, per the Godot probe's own before/after
  digests); a small uninstrumented gap remains between emission and
  the `seed_digests_before` snapshot — bounded, not proven to the
  second. The `7b4615b`/`e79e004` receipts ran on a settled worktree
  (no `M` under `corpus/fixtures/` at their times).
- The interim Godot FAIL is reported as measured: the seed detector
  tripped on a concurrent **then-uncommitted** sibling edit (the
  `7b4615b` content arriving pre-commit). It is not evidence about
  committed bytes — before-digest held the `0619300` value — and the
  post-settle re-run is clean PASS with 0/176 tuple drift.
- `binjunk` and `detach EOF` hazard cells: declared in the commit
  subject; this seat verified the *stream-level* prior-row invariant
  and battery pass, not each hazard probe's internal mechanics —
  bounded to what the receipts show (2 `dup_flush` physical rows,
  forged `closed` row @79).
- Post-commit verification covers the three work commits through
  `e79e004` (last fixture-touching commit seen at report time;
  `LOG.md`/`SCORECARD.md` were mid-edit by siblings and are outside
  the battery surface). Any later fixture change needs its own
  re-check against `prior-118-arm-rows.txt` — the checker is
  mechanical: `python3 tools/postcommit_verify.py <new
  probe.stdout.txt> prior-118-arm-rows.txt`.
- `corpus/live/` is gitignored; "prior receipt" comparisons are
  against on-disk runs retained under `corpus/live/runs/`,
  `corpus/live/r81-baseline/runs/`, and
  `corpus/live/r82-simplifier/baseline-runs/`, not committed blobs.
