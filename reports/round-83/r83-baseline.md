# game-dev-3d round 83 — frozen before-state + battery replay + post-commit re-verification (seat: baseline)

Baseline replay for the r83 move: one arm declared (g3d-author brief) —
Godot PhysicsServer3D generated-event two-tier lattice (xconnector X5):
queries edge-0 same-turn while generated events (contact signals,
`body_test_motion` results, `cast_motion`, `intersect_shape`) bind at the
physics tick, plus a `run_on_separate_thread=true` inline→deferred
conversion cell, gated on a Jolt-availability check first. Declared
invariant under test: **prior 134 ARM rows byte-identical (bpy battery
untouched); prior 176 Godot case tuples preserved; three.js 31/31;
falsifier liveness re-verified.**

RECOVERY GENERATION: prior baseline generation died ~16:10Z. Its scratch
(`corpus/live/r83-baseline/`: freeze + three completed family replays) was
verified before reuse per dispatch — frozen sha confirmed == HEAD
`f8a088c`, archive member list comm-clean vs `git ls-files`, all receipts
re-checked cell-by-cell below. Nothing was re-frozen or re-run where the
inherited evidence already proved the invariant.

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (built 2026-09-01),
`/usr/bin/godot` = 4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7,
Node v24.21.0, three.js 0.186.1 (tracked lockfile). Single host.

## Frozen tree (pre-move baseline @ f8a088c)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r83-baseline/frozen/frozen-tree.tar

- Frozen commit: `f8a088c5ceb32552721100c59fb677de2eb1b6d7`
  (`r82 report-last: adjudicator ADMIT (evalcat 14->20 + hazard contract
  pinned), verifier AGREE 8/8 on e79e004, baseline 118/118 prior rows
  byte-identical`) — the last pre-r83 commit; contains the r82 work
  (`0619300` evalcat+hazard, `7b4615b` fflush banner fix, `e79e004`
  simplifier-fold).
- `frozen/frozen-head.txt` = `f8a088c5…b6d7` — **sha re-confirmed against
  live `git rev-parse HEAD` this generation before any reuse**.
- Archive sha256
  `a224bebd06b585266f2241ddb4bc044a793a9ef7dd07691c7bc4d5ef02de4f2b`,
  388 tar members = **356 file members + 32 dir entries**; file-member
  list vs `git ls-files`: `comm -23` **0 lines**, `comm -13` **0 lines**
  (both directions clean). `node_modules`/`frozen`/`live` members in tar:
  **0** — no recursive embedding.
- Extract dir `frozen-extract/` = exactly the 356 tar members
  (`find` vs member list, 0 diff; + gitignored
  `corpus/fixtures/three/node_modules` from `npm ci`).
- Frozen fixture digests `frozen/fixture-digests.txt` (53 files, `.gd` +
  `.py` + `project.godot`): cross-verified against the Godot run's own
  `seed_digests` (54 entries incl. `README.md`) — **0 hash mismatches**,
  and against the live worktree (`sha256sum corpus/fixtures/*`): **all
  53 identical**, `git status --porcelain -- corpus/fixtures` empty.
  Key pins: `run_battery.py` `22a1966d…` (176 CASES), `bpy_battery.py`
  `045102a8…` (83 CASES), `bpy_sync_probe.py` `07ec83e3…`,
  `timeout_descendant.py` `c3a52834…`, `project.godot` `1fda90d4…`.
- All writes confined to gitignored `corpus/live/r83-baseline/` +
  this report. No git mutations performed by this seat.

## bpy battery — frozen pre-move — 83/83, stdout byte-identical to r82-final

Inherited receipt `runs/bpy-20261014T160431295444Z/` (started 16:04:31Z,
before the generation died — verified complete: `verdicts.json` +
`probe.stdout.txt` + `probe.stderr.txt` all present):

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r83-baseline/runs

- `verdict` **PASS**; `totals: cases=83 pass=83 fail=0 (signal_fail=0
  quirk_drift=0)`; `probe_exit=0`, `done_marker=true`, `fatal_arms=[]`,
  `n_arm_lines=131`, `probe_elapsed_s=4.63`; `probe.stderr.txt` 0 bytes.
- `probe.stdout.txt` 13,495 bytes, sha256
  `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
  **byte-identical** (`diff` empty) to r82's settled receipts at
  `7b4615b` (`runs-post2/bpy-20261014T154906198444Z`) and `e79e004`
  (`runs-post3/bpy-20261014T155258412399Z`). Stream anatomy identical:
  banner `Blender 5.2.1 LTS` at line 1 (r82 `fflush` pin holding),
  134 physical `^ARM` lines / 131 unique keys, reorder block +
  `REORDERGLUE` drop, `ARM hazard | dup_flush` row-pair, tail
  `PROBE_DONE` / `Blender quit`.
- Prior-134 check (`tools/postcommit_verify.py` vs
  `prior-134-arm-rows.txt`): **ordered-subsequence PASS 134/134, all at
  identical ARM positions, 0 inserted rows** — strictest form (no
  insertions expected pre-move, none observed).

## Godot battery — frozen — 176/176 + 4 probes

Inherited receipt `runs/20261014T160506798300Z/` (started 16:05:06Z;
`scratch` + `seed` fields confirm it ran inside `frozen-extract`):

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r83-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout

- `verdict` **PASS**; `totals: cases=176 pass=176 fail=0 ordinary=131
  negative_controls=45`; `seeds_unchanged=true`; all four probes armed
  and ok (`probe_failing/crash_exit/stream_attribution/tree_timeout`
  true, `crash_probe_ok`/`stream_probe_ok`/`tree_probe_ok` true); Godot
  `4.7.2.stable.arch_linux.ed1daf0bf`.
- Tuple comparison `(case, verdict, actual_exit, marker)` of all 176
  `results` rows vs `prior-176-godot-rows.json`: **0 mismatches, case
  order identical**. The reference file itself was re-verified this
  generation to equal the r81-baseline (`…/r81-baseline/runs/
  20261014T143659306553Z`) and r82-baseline (`…/r82-baseline/runs/
  20261014T152117151755Z`) frozen-run rows — three-round stability.
- Mutation probe `mutation-scratch/` present in the run dir;
  `crash-exit-verdicts.json`, `stream-attribution-verdicts.json`,
  `tree-timeout-verdicts.json`, `mutation-verdicts.json` all written.

## Node three.js suites — frozen — 31/31

Six receipts under `receipts/run_*.json` (written via `--receipt` after
`npm ci` inside `frozen-extract/corpus/fixtures/three`; three@0.186.1
per tracked lockfile):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0 — total 31/31

## Pre-move status at freeze

- HEAD `f8a088c`; `git status --porcelain` = `?? reports/round-83/` only.
- Live worktree fixture surface identical to frozen (53/53 digests) —
  the frozen replay and any live-tree comparison start from the same
  bytes.
- `tools/watch_commits.sh` (20 s poll, dedup'd) restarted at ~16:33Z —
  logs HEAD + `corpus/fixtures` dirty/untracked deltas to `watch.log`
  (log gap 16:10:58Z→16:32:54Z = the dead-generation window; the
  inherited watch was dead on arrival and was restarted).
- Independent corroboration (scribe report's landings audit, sibling
  receipts as data): `r83-verifier` bpy 83/83 + Godot 176/176,
  `r83-reviewer`/`r83-boundary`/`r83-simplifier` Godot baseline runs all
  PASS 176 — five seats' pre-move runs agree.

## Post-commit re-verification — commit `e9145d9` (landed ~16:57:2xZ)

One r83 work commit landed during the measurement window:

    e9145d9c22551851f9eb063f1f36e689b6ead2a4  (git show; commit ts
    13:57:26 -03:00 = 16:57:26Z)
    r83: PhysicsServer3D two-tier lattice — queries edge-0 vs events
    tick-bound; Jolt gate + ST access-window
    "phys3d_events.gd 10-arm probe + 10 CASES rows (pure insertion;
    prior 176 byte-identical) … 186/186 x2 seeds_unchanged"

`git show --stat`: **4 files, +867/−0 — zero deletions**:
`corpus/fixtures/phys3d_events.gd` +597 (new 10-arm probe),
`corpus/fixtures/run_battery.py` +20 (10 CASES rows appended after the
prior 176, before the mutation-probe comment — diff `f8a088c..e9145d9`
has **0 deletion lines**), `corpus/fixtures/README.md` +28 (arm
documentation), `reports/round-83/r83-author.md` +222. **No
`bpy_battery.py`/`bpy_sync_probe.py`/`timeout_descendant.py`, no prior
`.gd` fixture, no `three/` file touched** — sibling-battery surfaces
pinned at the fixture-digest level.

`watch.log` brackets the write window: `fix_dirty=3 fix_untracked=1`
on `f8a088c` from ≤16:46:30Z (first seen) through 16:57:14Z;
`head=e9145d9 fix_dirty=0` from 16:57:34Z onward — all post-commit
runs below executed on a settled worktree.

### bpy — live worktree replay @ `e9145d9` — 83/83, stdout byte-identical

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r83-baseline/runs-post

Receipt `runs-post/bpy-20261014T165743526312Z/verdicts.json`
(started 16:57:43Z, after the commit): `verdict` **PASS**; `totals:
cases=83 pass=83 fail=0`; `done_marker=true`, `fatal_arms=[]`.
`probe.stdout.txt` sha256 `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
**byte-identical to the frozen pre-move receipt AND to both r82
receipts**: the r83 commit produced zero observable change on the bpy
surface. `tools/postcommit_verify.py` vs `prior-134-arm-rows.txt`:
**ordered-subsequence PASS 134/134, all at identical ARM positions,
0 inserted rows** — the strongest form of the insertion-only contract
(not merely insertion-preserving: nothing moved).

### Godot — live worktree replay @ `e9145d9` — 186/186 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r83-baseline/runs-post \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout

Receipt `runs-post/20261014T165757784619Z/verdicts.json` (started
16:57:57Z, settled worktree): `verdict` **PASS**; `totals: cases=186
pass=186 fail=0 ordinary=140 negative_controls=46 probes=4`;
`seeds_unchanged=true`; all four probes ok; `seed_digests` carries
`phys3d_events.gd` `6ddf4aefde97…` and `run_battery.py` `0381b7500d…` —
matching live worktree shas, i.e. the battery measured the committed
bytes. `tools/postcommit_verify_godot.py` vs
`prior-176-godot-rows.json`:

- **Ordered-subsequence: PASS — 176/176 prior tuples present,
  byte-identical, at IDENTICAL positions** (author appended cleanly;
  not merely order-preserved).
- **10 inserted rows at indices 177–186** — exactly the declared
  generated-event cells, all PASS: `phys3d_events_{isect,cast,btm,
  pp_queries,contact_stale,contact_sig,sync_cb,srv_area_cb,
  threaded_edge}` ordinary + `phys3d_events_static_nopair` negative
  control (`NEGATIVE REJECTED`, expected exit 2).
- 0 dropped cases, 0 case-name/tuple collisions, 0 verdict flips.
- The arm's independent claim (commit message: "186/186 x2
  seeds_unchanged") **reproduces on this seat**.

### three.js — live worktree re-run @ `e9145d9` — 31/31

Six suites re-run on the live tree (`run_*.mjs --receipt
receipts/*.post.json`; `three/` untouched by `e9145d9`):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0 — total 31/31

## Byte-stability summary (cell-by-cell)

| surface | pre-move frozen @ `f8a088c` | post-commit @ `e9145d9` | drift |
|---|---|---|---|
| bpy cases | 83/83 PASS | 83/83 PASS | none |
| bpy stdout sha256 | `6a98c570…defc3` | `6a98c570…defc3` (byte-identical ×4 receipts incl. r82's) | none |
| prior 134 ARM rows | 134 physical / 131 keys | 134/134 byte-identical at identical positions, 0 inserted | none |
| falsifier + hazard cells | `closed` last-wins genuine, `dup_flush` forged pair | same stream bytes — same cells | none |
| Godot battery | 176/176 + 4 probes | 186/186 + 4 probes; 176/176 prior at identical positions | none in prior; +10 declared cells appended @177–186 |
| Godot seed digests | 54-file map == frozen digests | map + `phys3d_events.gd`; all carried hashes == committed bytes | none |
| three.js | 31/31, seeds unchanged | 31/31, seeds unchanged | none |
| fixtures (siblings) | digests above | `run_battery.py` +20/−0 append-only; `README.md` +28; `phys3d_events.gd` new; bpy/three/prior `.gd` untouched | none outside the declared arm |
| worktree churn | clean @ freeze | `fix_dirty=3/untracked=1` 16:46–16:57Z on `f8a088c` → clean `e9145d9` | window fully bracketed by `watch.log` |

## Receipts / scratch (all inside write scope)

- `corpus/live/r83-baseline/frozen/frozen-tree.tar` — `git archive HEAD`
  @ `f8a088c`, sha256 `a224bebd…` (388 members / 356 files, comm-clean)
- `corpus/live/r83-baseline/frozen/frozen-head.txt`,
  `frozen/fixture-digests.txt` (53)
- `corpus/live/r83-baseline/frozen-extract/` — replay scratch tree
  (gitignored; + `three/node_modules` via `npm ci`)
- `corpus/live/r83-baseline/runs/` —
  `bpy-20261014T160431295444Z` (frozen bpy 83/83, stdout sha
  `6a98c570…`), `20261014T160506798300Z` (frozen godot 176/176 + 4
  probe verdicts)
- `corpus/live/r83-baseline/runs-post/` —
  `bpy-20261014T165743526312Z` (bpy 83/83 @ `e9145d9`, stdout sha
  `6a98c570…` byte-identical), `20261014T165757784619Z` (godot
  186/186 @ `e9145d9` + 4 probe verdicts), `godot-battery-outerr.log`
- `corpus/live/r83-baseline/receipts/run_*.json` — six Node suite
  receipts (frozen, 31/31) + `run_*.post.json` (post-commit @
  `e9145d9`, 31/31)
- `corpus/live/r83-baseline/prior-134-arm-rows.txt` — canonical
  prior-row reference, sha256 `7b19c058e2f733236f8ad6bd6e49ced14f4fef2b5accfdc69664766a08d7b8e8`;
  `prior-176-godot-rows.json` sha256
  `922fc11404a877ab2bb83a2fc957a599b4e797915569caeb21d2cd8d7ed37d61`
  (176-file verified == r81 + r82 frozen runs)
- `corpus/live/r83-baseline/tools/postcommit_verify.py` (ARM
  subsequence/position checker, inherited),
  `tools/postcommit_verify_godot.py` (Godot tuple-subsequence checker,
  new this generation), `tools/watch_commits.sh`, `watch.log`

## Limits

- Single host, single Blender/Godot/Node build; one replay per surface
  per commit — zero case failures on any completed run, no flake-retry
  needed or observed.
- The inherited pre-move bpy receipt's worktree-of-origin isn't recorded
  in `verdicts.json`; the claim rests on its stdout sha `6a98c570…`
  being byte-identical to two r82 receipts whose provenance (live tree @
  `7b4615b`/`e79e004` bytes — identical fixture bytes to `f8a088c`) is
  recorded. Fixture bytes, not directory path, determine the stream.
- Post-commit coverage is exactly one work commit (`e9145d9`, landed
  ~16:57:2xZ, verified through `watch.log` + `git show`). Any later
  fixture change needs its own re-check — the checkers are mechanical:
  `python3 tools/postcommit_verify.py <new probe.stdout.txt>
  prior-134-arm-rows.txt` and `python3 tools/postcommit_verify_godot.py
  <new verdicts.json> prior-176-godot-rows.json`.
- The arm's internal semantics (which event binds at which tier, Jolt
  vs DEFAULT solver constants, ST DSS-refusal majority) are the
  author's cells; this seat verified the arm as *data* — the 10 new
  markers match their declared expected lines and all PASS under the
  tracked gate — not the physics claim's interpretation. Jolt-selectable
  builds' identical-lattice claim is bounded to the author's live-only
  note (header comment, `phys3d_events.gd:5-7`).
- `corpus/live/` is gitignored; "prior receipt" comparisons are against
  on-disk runs retained under `corpus/live/runs/`,
  `corpus/live/r8{1,2}-baseline/runs/`, and sibling `r83-*` seat dirs —
  not committed blobs.
