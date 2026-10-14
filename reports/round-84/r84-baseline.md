# game-dev-3d round 84 — frozen before-state + battery replay + post-commit re-verification (seat: baseline)

Baseline replay for the r84 move: one arm declared (g3d-author brief) —
`phys3d_events.gd` backend pinning extension: a `jolt_edge` parent arm
(Jolt-availability gate → generated `physics_engine="Jolt Physics"` child
project → re-exec `--child --arm=jolt_edge` under `timeout -s KILL`, per-arm
verdict map `{same-signature | differs-constants | inverts}`) and a
`phase_delta` arm (process-phase write → event-tier delta=2 vs physics-phase
delta=1, r83 critic C1 as a first-class cell). Declared invariant under
test: **prior 186 Godot rows byte-identical; prior 134 ARM rows (bpy)
byte-identical; three.js 31/31; falsifier liveness re-verified.**

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (built 2026-09-01),
`/usr/bin/godot` = 4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7,
Node v24.21.0, three.js 0.186.1 (tracked lockfile). Single host.

## Frozen tree (pre-move baseline @ c4b2fa2)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r84-baseline/frozen/frozen-tree.tar

- Frozen commit: `c4b2fa2ae1b20becd83a15e1ad4fe5e17e4c54db`
  (`r83 report-last: 9/9 seats — AGREE 18/18, ADMIT-corr (two-tier lattice,
  backend-scoped rules)`) — the last pre-r84 commit; contains the r83 arm
  (`e9145d9` phys3d_events 186-case battery + `4c1c100` folds).
- Archive sha256
  `513ee42b28a2667a8c8d37aebf00dc442fa9d8765b730e651f571c717bf62d8c`,
  400 tar members = **367 file members + 33 dir entries**; file-member
  list vs `git ls-files`: `comm -23` **0 lines**, `comm -13` **0 lines**
  (both directions clean). `node_modules`/`corpus/live/`/`frozen` members
  in tar: **0** — no recursive embedding.
- Extract dir `frozen-extract/` = exactly the 367 tar members
  (`find` vs member list, 0 diff; + gitignored
  `corpus/fixtures/three/node_modules` from `npm ci`).
- Frozen fixture digests `frozen/fixture-digests.txt` (54 files: `.gd` +
  `.py` + `project.godot`; +1 vs r83's 53 = `phys3d_events.gd` now
  tracked): cross-verified against the live worktree
  (`sha256sum corpus/fixtures/*` → `diff` empty, **all 54 identical**),
  `git status --porcelain -- corpus/fixtures` empty at freeze.
- All writes confined to gitignored `corpus/live/r84-baseline/` +
  this report. No git mutations performed by this seat.

## bpy battery — frozen pre-move — 83/83, stdout byte-identical to r82/r83 finals

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r84-baseline/runs        (cwd = frozen-extract)

- Receipt `runs/bpy-20261014T173207689455Z/verdicts.json` (started
  17:32:07Z): `verdict` **PASS**; `totals: cases=83 pass=83 fail=0
  (signal_fail=0 quirk_drift=0)`; `probe_exit=0`, `done_marker=true`,
  `fatal_arms=[]`, `n_arm_lines=131`, `probe_elapsed_s=4.66`;
  `probe.stderr.txt` 0 bytes.
- `probe.stdout.txt` sha256
  `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
  **byte-identical** to all four prior receipts (r82 @ `7b4615b` and
  `e79e004`, r83 frozen @ `f8a088c`, r83 post @ `e9145d9`). Banner
  `Blender 5.2.1 LTS` at line 1 (r82 `fflush` pin holding), tail
  `Blender quit`; 134 physical `^ARM` lines / 131 unique keys.
- Prior-134 check (`tools/postcommit_verify.py` vs
  `prior-134-arm-rows.txt`, sha256 `7b19c058…` = r83's canonical file,
  re-verified this round): **ordered-subsequence PASS 134/134, all at
  identical ARM positions, 0 inserted rows.**

## Godot battery — frozen — 186/186 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r84-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout                        (cwd = frozen-extract)

- Receipt `runs/20261014T173215587842Z/verdicts.json` (started
  17:32:15Z): `verdict` **PASS**; `totals: cases=186 pass=186 fail=0
  ordinary=140 negative_controls=46`; `seeds_unchanged=true`; all four
  probes armed and ok (`crash_probe_ok`/`stream_probe_ok`/
  `tree_probe_ok` true); `seed` field = `frozen-extract/corpus/fixtures`
  — ran against the frozen bytes.
- Tuple comparison `(case, verdict, actual_exit, marker)` of all 186
  `results` rows vs `prior-186-godot-rows.json`: **186/186 matched,
  all at identical positions, 0 inserted, 0 dropped, 0 drift.**
- Reference provenance (built this round): extracted from r83-baseline's
  post-commit receipt (`r83-baseline/runs-post/20261014T165757784619Z`),
  cross-verified **IDENTICAL** against four more sibling 186-row
  receipts — r83-verifier `…165952Z`, r83-reviewer `…165831Z`,
  r83-author `…165207Z` and `…164612Z` (author `…164857Z` also identical
  at row level despite its top-level FAIL verdict field). Reference
  sha256 `25e46f4f27da641b2e7be45f99b59cf8e6f4bda03743bb5bd9336f68d1cb2fd0` —
  five-receipt consensus, zero ambiguity.

## Node three.js suites — frozen — 31/31

Six receipts `receipts/run_*.json` (after `npm ci` inside
`frozen-extract/corpus/fixtures/three`; three@0.186.1 per tracked
lockfile):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0 — total 31/31

## Pre-move status at freeze

- HEAD `c4b2fa2`; `git status --porcelain` = `?? reports/round-84/` only
  (sibling seat reports; fixture surface clean).
- Live worktree fixture surface identical to frozen (54/54 digests).
- `tools/watch_commits.sh` (20 s poll) running from ~17:32Z →
  `watch.log`: `head=c4b2fa2 fix_dirty=0` through 17:36:42Z;
  `fix_dirty=1` (`phys3d_events.gd`) from 17:37:02Z; `fix_dirty=3`
  (`phys3d_events.gd` + `run_battery.py` + `README.md`) 17:39–17:50:42Z;
  `head=01f7d4f fix_dirty=0` from 17:51:02Z — write window fully
  bracketed.

## Post-commit re-verification — commit `01f7d4f` (landed ~17:50:4xZ)

One r84 work commit landed during the measurement window:

    01f7d4f4c537e1beb4ca2317bfd857413fed5217  (commit ts 14:50:47 -03:00
    = 17:50:47Z)
    r84: backend pinning — jolt_edge child re-exec + phase_delta
    first-class cell  "188/188 x2 byte-identical; prior 186 rows
    byte-identical (insertion-only)"

`git show --stat`: **4 files, +617/−6**:
`corpus/fixtures/phys3d_events.gd` +402/−3 (jolt_edge + phase_delta arms;
the −3 are the `--child` dispatch refactor selecting on `--arm` plus its
comment — the arm's own file, not a prior fixture), `run_battery.py`
+4/−0 (2 CASES rows appended + harness line), `README.md` +28/−3
(stale "Jolt unprobed" comment lines replaced by probed documentation),
`reports/round-84/r84-author.md` +189. **No `bpy_battery.py`/
`bpy_sync_probe.py`/`timeout_descendant.py`, no other prior `.gd`
fixture, no `three/` file touched** — sibling-battery surfaces pinned.

All post-commit runs below executed on the settled worktree
(`head=01f7d4f fix_dirty=0` from 17:51:02Z onward per `watch.log`).

### bpy — live worktree replay @ `01f7d4f` — 83/83, stdout byte-identical

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r84-baseline/runs-post   (cwd = live tree)

Receipt `runs-post/bpy-20261014T175128061493Z/verdicts.json` (started
17:51:28Z, after the commit): `verdict` **PASS**; `totals: cases=83
pass=83 fail=0`; `done_marker=true`, `fatal_arms=[]`; stderr 0 bytes.
`probe.stdout.txt` sha256 `6a98c570…defc3` — **byte-identical to the
frozen pre-move receipt AND all four r82/r83 receipts** (6 identical
receipts total): `diff` empty. `tools/postcommit_verify.py` vs
`prior-134-arm-rows.txt`: **ordered-subsequence PASS 134/134, all at
identical ARM positions, 0 inserted rows.**

### Godot — live worktree replay @ `01f7d4f` — 188/188 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r84-baseline/runs-post \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout                        (cwd = live tree)

Receipt `runs-post/20261014T175135960951Z/verdicts.json` (started
17:51:35Z, settled worktree; `seed` = live `corpus/fixtures`):
`verdict` **PASS**; `totals: cases=188 pass=188 fail=0 ordinary=142
negative_controls=46`; `seeds_unchanged=true`; all four probes ok;
`seed_digests` (55 entries) carries `phys3d_events.gd` `255dcab5…` and
`run_battery.py` `8c88aa33…` — matching live worktree shas, i.e. the
battery measured the committed bytes. `tools/postcommit_verify_godot.py`
vs `prior-186-godot-rows.json`:

- **Ordered-subsequence: PASS — 186/186 prior tuples present,
  byte-identical, at IDENTICAL positions** (strictest form: clean append,
  nothing moved).
- **2 inserted rows at indices 187–188** — exactly the declared arm
  cells, both PASS:
  - `phys3d_events_phase_delta` → `PASS phys3d_events phase_delta
    proc_delta=2 phys_delta=1` — the r83 critic-C1 write-phase correction
    landed as a first-class cell and reproduces: process-phase write
    binds at delta=2, physics-phase at delta=1.
  - `phys3d_events_jolt_edge` → `PASS phys3d_events jolt_edge
    backend=Jolt isect=same cast=constants btm=constants
    contact_stale=same static_nopair=inverts child_exit=0` — **Jolt is
    available on this build** (no `blocked` row); the per-arm map
    matches the carried guard: `static_nopair` **inverts** under Jolt,
    `cast`/`btm` differ on constants, `isect`/`contact_stale`
    same-signature.
- 0 dropped cases, 0 case-name/tuple collisions, 0 verdict flips.
- The arm's independent claim (commit message: "188/188 x2
  byte-identical; prior 186 rows byte-identical") **reproduces on this
  seat**.

### three.js — live worktree re-run @ `01f7d4f` — 31/31

Six suites re-run on the live tree (`run_*.mjs --receipt
receipts/*.post.json` after `npm ci`; `three/` untouched by `01f7d4f`):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0 — total 31/31

## Byte-stability summary (cell-by-cell)

| surface | pre-move frozen @ `c4b2fa2` | post-commit @ `01f7d4f` | drift |
|---|---|---|---|
| bpy cases | 83/83 PASS | 83/83 PASS | none |
| bpy stdout sha256 | `6a98c570…defc3` | `6a98c570…defc3` (byte-identical ×6 receipts incl. r82/r83's) | none |
| prior 134 ARM rows | 134 physical / 131 keys | 134/134 byte-identical at identical positions, 0 inserted | none |
| Godot battery | 186/186 + 4 probes | 188/188 + 4 probes; 186/186 prior at identical positions | none in prior; +2 declared cells appended @187–188 |
| Godot seed digests | 54-file map == live digests @ freeze | 55-entry map; carried hashes == committed bytes (`phys3d_events.gd` `255dcab5…`, `run_battery.py` `8c88aa33…`) | none |
| three.js | 31/31, seeds unchanged | 31/31, seeds unchanged | none |
| fixtures (siblings) | digests above | `run_battery.py` +4/−0; `phys3d_events.gd` +402/−3 (own arm); `README.md` +28/−3; bpy/three/prior `.gd` untouched | none outside the declared arm |
| worktree churn | clean @ freeze | `fix_dirty=1`→`3` 17:37–17:50:42Z on `c4b2fa2` → clean `01f7d4f` from 17:51:02Z | window fully bracketed by `watch.log` |

## Receipts / scratch (all inside write scope)

- `corpus/live/r84-baseline/frozen/frozen-tree.tar` — `git archive HEAD`
  @ `c4b2fa2`, sha256 `513ee42b…` (400 members / 367 files, comm-clean)
- `corpus/live/r84-baseline/frozen/frozen-head.txt`,
  `frozen/fixture-digests.txt` (54), `frozen/tar-members.txt`,
  `frozen/git-files.txt`, `frozen/extract-files.txt`
- `corpus/live/r84-baseline/frozen-extract/` — replay scratch tree
  (gitignored; + `three/node_modules` via `npm ci`)
- `corpus/live/r84-baseline/runs/` —
  `bpy-20261014T173207689455Z` (frozen bpy 83/83, stdout sha
  `6a98c570…`), `20261014T173215587842Z` (frozen godot 186/186 + 4
  probe verdicts)
- `corpus/live/r84-baseline/runs-post/` —
  `bpy-20261014T175128061493Z` (bpy 83/83 @ `01f7d4f`, stdout sha
  `6a98c570…` byte-identical), `20261014T175135960951Z` (godot
  188/188 @ `01f7d4f` + 4 probe verdicts + `mutation-verdicts.json`)
- `corpus/live/r84-baseline/receipts/run_*.json` — six Node suite
  receipts (frozen, 31/31) + `run_*.post.json` (post-commit @
  `01f7d4f`, 31/31)
- `corpus/live/r84-baseline/prior-134-arm-rows.txt` — canonical
  prior-row reference, sha256
  `7b19c058e2f733236f8ad6bd6e49ced14f4fef2b5accfdc69664766a08d7b8e8`
  (r83's file re-verified); `prior-186-godot-rows.json` sha256
  `25e46f4f27da641b2e7be45f99b59cf8e6f4bda03743bb5bd9336f68d1cb2fd0`
  (new this round, five-receipt consensus)
- `corpus/live/r84-baseline/tools/postcommit_verify.py` (ARM
  subsequence/position checker, inherited),
  `tools/postcommit_verify_godot.py` (Godot tuple-subsequence checker,
  updated to 186-row references), `tools/watch_commits.sh`, `watch.log`

## Limits

- Single host, single Blender/Godot/Node build; one replay per surface
  per commit — zero case failures on any completed run, no flake-retry
  needed or observed.
- Post-commit coverage is exactly one work commit (`01f7d4f`, landed
  ~17:50:47Z, verified through `watch.log` + `git show`). Any later
  fixture change needs its own re-check — the checkers are mechanical:
  `python3 tools/postcommit_verify.py <new probe.stdout.txt>
  prior-134-arm-rows.txt` and `python3 tools/postcommit_verify_godot.py
  <new verdicts.json> prior-186-godot-rows.json`.
- The arm's internal semantics (per-arm Jolt verdict classification,
  the impersonation guard's `jolt_backend=unexpected` path, child
  re-exec mechanics) are the author's cells; this seat verified the arm
  as *data* — the 2 new markers match their declared expected lines and
  PASS under the tracked gate — not the physics/backend claim's
  interpretation. The Jolt measurements are one build's answer
  (4.7.2.stable.arch_linux.ed1daf0bf); other builds may gate `blocked`.
- `corpus/live/` is gitignored; "prior receipt" comparisons are against
  on-disk runs retained under `corpus/live/r8{1,2,3}-baseline/runs*/`
  and sibling `r83-*` seat dirs — not committed blobs.
