# game-dev-3d round 85 — freeze @ ac025b2 + battery replay + post-commit re-verification (seat: baseline)

Baseline replay for the r85 move. Declared invariant under test (per the
r84-closed contract): **prior 188 Godot rows byte-identical (186-case r83
prefix + the two r84 cells), prior 134 ARM rows (bpy) byte-identical,
three.js 31/31, falsifier liveness re-verified; any r85 cells must land
insertion-only.**

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (built 2026-09-01),
`/usr/bin/godot` = 4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7,
Node v24.21.0, three.js 0.186.1 (tracked lockfile). Single host.

## PHASE 1 — Frozen tree (pre-move baseline @ ac025b2)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r85-baseline/frozen/frozen-tree.tar

- Frozen commit: `ac025b26a7ad41507736a7bd6837b167cb1c36e6`
  (`r84 report-last: 9 seat reports + adjudicator + LOG/SCORECARD`) —
  the last pre-r85 commit; contains the r84 arm (`01f7d4f` jolt_edge +
  phase_delta cells + `a56f683` folds + `ac025b2` report-last).
- Archive sha256
  `4981e2021502832e93a840e075f14688bedd3b475a4e03bd5f8c861435a37e09`,
  411 tar members = **377 file members + 34 dir entries**; file-member
  list vs `git ls-files`: `comm -23` **0 lines**, `comm -13` **0 lines**
  (both directions clean).
- Extract dir `frozen-extract/` = exactly the 377 tar file members
  (`find` vs member list, 0 diff; + gitignored
  `corpus/fixtures/three/node_modules` from `npm ci`).
- Frozen fixture digests `frozen/fixture-digests.txt` (**55 files**:
  `.gd` + `.py` + `project.godot`): cross-verified against the live
  worktree (`sha256sum corpus/fixtures/*` → `diff` empty, **all 55
  identical**), `git status --porcelain -- corpus/fixtures` = 0 at
  freeze (18:22Z).
- All writes confined to gitignored `corpus/live/r85-baseline/` +
  this report. No git mutations performed by this seat.

### bpy battery — frozen — 83/83, stdout byte-identical ×7

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r85-baseline/runs        (cwd = frozen-extract)

- Receipt `runs/bpy-20261014T182310617256Z/verdicts.json` (started
  18:23:10Z): `verdict` **PASS**; `totals: cases=83 pass=83 fail=0
  (signal_fail=0 quirk_drift=0)`; `probe_exit=0`, `done_marker=true`,
  `fatal_arms=[]`, `n_arm_lines=131`; `probe.stderr.txt` 0 bytes.
- `probe.stdout.txt` sha256
  `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
  **byte-identical to all six prior receipts** (r82 @ `7b4615b` and
  `e79e004`, r83 frozen @ `f8a088c` + post @ `e9145d9`, r84 frozen @
  `c4b2fa2` + post @ `01f7d4f`) — 7 identical receipts total.
- Prior-134 check (`tools/postcommit_verify.py` vs
  `prior-134-arm-rows.txt`, sha256 `7b19c058…` unchanged from r83/r84):
  **ordered-subsequence PASS 134/134, all at identical ARM positions,
  0 inserted rows**; 134 physical `^ARM` lines / 131 unique keys.

### Godot battery — frozen — 188/188 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r85-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout                        (cwd = frozen-extract)

- Receipt `runs/20261014T182310632331Z/verdicts.json` (started
  18:23:10Z): `verdict` **PASS**; `totals: cases=188 pass=188 fail=0
  ordinary=142 negative_controls=46`; `seeds_unchanged=true`; all four
  probes armed and ok (`crash_probe_ok`/`stream_probe_ok`/
  `tree_probe_ok` true); `seed` = `frozen-extract/corpus/fixtures`
  — ran against the frozen bytes; `godot_version`
  `4.7.2.stable.arch_linux.ed1daf0bf`.
- `seed_digests` (55 entries) cross-verified against the live worktree
  shas taken at freeze: **0 mismatches** — the battery measured the
  committed bytes.
- **Normalized prior-186 prefix**: results[0:186] as
  `[case, verdict, actual_exit, marker]` tuples, `json.dumps` default
  separators → sha256
  `25e46f4f27da641b2e7be45f99b59cf8e6f4bda03743bb5bd9336f68d1cb2fd0` —
  **byte-identical to r84's canonical `prior-186-godot-rows.json`**.
  `tools/postcommit_verify_godot.py` vs that reference:
  **ordered-subsequence PASS 186/186, all at identical positions, 0
  dropped, 0 drift**; exactly **2 inserted rows at indices 187–188**.
- **The two r84 rows** (positions 187–188, both PASS, `actual_exit=0`):
  - `phys3d_events_phase_delta` →
    `PASS phys3d_events phase_delta proc_delta=2 phys_delta=1`
  - `phys3d_events_jolt_edge` →
    `PASS phys3d_events jolt_edge backend=Jolt isect=same
    cast=constants btm=constants contact_stale=same
    static_nopair=inverts child_exit=0`
- New r85 post-commit reference built:
  `prior-188-godot-rows.json` (188 tuples) sha256
  `bab5dc6f2f4b4d322048acd8b5c6c35d3ba8e124be09cffeb2da66a5987a5ac3`.

### Node three.js suites — frozen — 31/31

Six receipts `receipts/run_*.json` (after `npm ci` inside
`frozen-extract/corpus/fixtures/three`; three@0.186.1 per tracked
lockfile):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0 — total 31/31

### Pre-move status at freeze

- HEAD `ac025b2`; `git status --porcelain` clean apart from sibling
  seat/report paths; fixture surface clean (`fix_dirty=0` from
  18:22:53Z onward).
- `tools/watch_commits.sh` (20 s poll) running from 18:22:5xZ →
  `watch.log`.

## PHASE 2 — Post-commit re-verification — commit `f230443` (landed ~19:33:24Z)

`watch.log` brackets the full write window: `head=ac025b2
fix_dirty=0` 18:22:53Z→18:40:13Z; `fix_dirty=1`
(`phys3d_events.gd`) from 18:40:33Z; `fix_dirty=2` (+
`run_battery.py`) from 19:29:34Z; **`head=f230443 fix_dirty=0` from
19:33:29Z** through filing (19:36:54Z). One r85 work commit landed:

    f23044360e8b063329b7d128b63cd38f0d512963  (commit ts 16:33:24 -03:00
    = 19:33:24Z)
    r85: backend cross-product — jolt_threaded + dummy_refused +
    srv_phase_delta  "191/191 x2 battery runs, all tuples identical"

`git show --numstat`: **3 files, +765/−146** —
`corpus/fixtures/phys3d_events.gd` +373/−146 (three new arms +
`_spawn_child`/`_child_split` spawn-site refactor — the arm's own
file, not a prior fixture), `run_battery.py` +6/−0 (exactly **3 CASES
rows appended**, no harness edits),
`reports/round-85/r85-author.md` +386. **No `bpy_battery.py`/
`bpy_sync_probe.py`/`timeout_descendant.py`, no other prior `.gd`
fixture, no `three/` file touched** — sibling-battery surfaces pinned.

All post-commit runs below executed on the settled worktree
(`head=f230443 fix_dirty=0` from 19:33:29Z onward per `watch.log`).

### bpy — live worktree replay @ `f230443` — 83/83, stdout byte-identical

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r85-baseline/runs-post   (cwd = live tree)

Receipt `runs-post/bpy-20261014T193334573281Z/verdicts.json` (started
19:33:34Z, after the commit): `verdict` **PASS**; `totals: cases=83
pass=83 fail=0`; `done_marker=true`, `fatal_arms=[]`; stderr 0 bytes.
`probe.stdout.txt` sha256 `6a98c570…defc3` — **byte-identical to the
frozen pre-move receipt AND all six r82/r83/r84 receipts** (8 identical
receipts total). `tools/postcommit_verify.py` vs
`prior-134-arm-rows.txt`: **ordered-subsequence PASS 134/134, all at
identical ARM positions, 0 inserted rows.**

### Godot — live worktree replay @ `f230443` — 191/191 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r85-baseline/runs-post \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout                        (cwd = live tree)

Receipt `runs-post/20261014T193334590923Z/verdicts.json` (started
19:33:34Z, settled worktree; `seed` = live `corpus/fixtures`):
`verdict` **PASS**; `totals: cases=191 pass=191 fail=0 ordinary=145
negative_controls=46`; `seeds_unchanged=true`; all four probes ok.
`seed_digests` (55 entries) carries `phys3d_events.gd` `4bcde2bf…`
and `run_battery.py` `991c6c8a…` — matching committed worktree shas
(0/55 mismatches), i.e. the battery measured the committed bytes.
`tools/postcommit_verify_godot_188.py` vs `prior-188-godot-rows.json`
(sha256 `bab5dc6f…`, built this round from the frozen 188-row receipt):

- **Ordered-subsequence: PASS — 188/188 prior tuples present,
  byte-identical, at IDENTICAL positions** (strictest form: clean
  append, nothing moved).
- **3 inserted rows at indices 189–191** — exactly the declared arm
  cells, all PASS, `actual_exit=0`:
  - `phys3d_events_jolt_threaded` → `PASS phys3d_events jolt_threaded
    backend=Jolt threaded=true isect=same cast=constants
    btm=constants contact_stale=same static_nopair=inverts
    child_exit=0` — Jolt under threading produces the **same per-arm
    verdict map as `jolt_edge`** (backend split threading-invariant).
  - `phys3d_events_dummy_refused` → `PASS phys3d_events dummy_refused
    backend=Dummy isect=unexpected cast=unexpected btm=unexpected
    contact_stale=unexpected static_nopair=unexpected child_exit=0` —
    Dummy backend earns `unexpected` on all five queries (refused-shape
    negative control).
  - `phys3d_events_srv_phase_delta` → `PASS phys3d_events
    srv_phase_delta srv_proc_delta=2 srv_phys_delta=1` — server-path
    write binds the same phase-delta split (proc→2, phys→1).
- 0 dropped cases, 0 case-name/tuple collisions, 0 verdict flips.
- `seed_digests` frozen-vs-post: **exactly 2 differing entries —
  `phys3d_events.gd` and `run_battery.py`** (the declared arm files);
  all other 53 seed files byte-identical.
- The arm's independent claim (commit message: "191/191 x2 battery
  runs, all tuples identical") **reproduces on this seat**.

### three.js — live worktree re-run @ `f230443` — 31/31

Six suites re-run on the live tree (`run_*.mjs --receipt
receipts/*.post.json`; `three/` untouched by `f230443`):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0 — total 31/31

## Byte-stability summary (cell-by-cell)

| surface | pre-move frozen @ `ac025b2` | post-commit @ `f230443` | drift |
|---|---|---|---|
| bpy cases | 83/83 PASS | 83/83 PASS | none |
| bpy stdout sha256 | `6a98c570…defc3` | `6a98c570…defc3` (byte-identical ×8 receipts incl. r82/r83/r84's) | none |
| prior 134 ARM rows | 134/134 at identical positions, 0 inserted | 134/134 byte-identical at identical positions, 0 inserted | none |
| Godot battery | 188/188 + 4 probes | 191/191 + 4 probes; prior-188 188/188 at identical positions | none in prior; +3 declared cells appended @189–191 |
| Godot seed digests | 55-entry map == live digests @ freeze | 55-entry map == committed bytes (`phys3d_events.gd` `4bcde2bf…`, `run_battery.py` `991c6c8a…`); frozen-vs-post diff = exactly those 2 files | none outside declared arm |
| three.js | 31/31, seeds unchanged | 31/31, seeds unchanged | none |
| fixtures (siblings) | digests above | `run_battery.py` +6/−0; `phys3d_events.gd` +373/−146 (own arm); bpy/three/prior `.gd` untouched | none outside the declared arm |
| worktree churn | clean @ freeze | `fix_dirty=0`→`1` 18:40:33Z, `1`→`2` 19:29:34Z on `ac025b2` → clean `f230443` from 19:33:29Z | window fully bracketed by `watch.log` |

## Receipts / scratch (all inside write scope)

- `corpus/live/r85-baseline/frozen/frozen-tree.tar` — `git archive HEAD`
  @ `ac025b2`, sha256 `4981e202…` (411 members / 377 files, comm-clean)
- `corpus/live/r85-baseline/frozen/frozen-head.txt`,
  `frozen/fixture-digests.txt` (55), `frozen/tar-members.txt`,
  `frozen/git-files.txt`, `frozen/extract-files.txt`,
  `frozen/prior-186-prefix.from-frozen.json`
- `corpus/live/r85-baseline/frozen-extract/` — replay scratch tree
- `corpus/live/r85-baseline/runs/` —
  `bpy-20261014T182310617256Z` (frozen bpy 83/83, stdout sha
  `6a98c570…`), `20261014T182310632331Z` (frozen godot 188/188 + 4
  probe verdicts)
- `corpus/live/r85-baseline/runs-post/` —
  `bpy-20261014T193334573281Z` (bpy 83/83 @ `f230443`, stdout sha
  `6a98c570…` byte-identical), `20261014T193334590923Z` (godot
  191/191 @ `f230443` + 4 probe verdicts + `mutation-verdicts.json`)
- `corpus/live/r85-baseline/receipts/run_*.json` — six Node suite
  receipts (frozen, 31/31) + `run_*.post.json` (post-commit @
  `f230443`, 31/31)
- `corpus/live/r85-baseline/prior-134-arm-rows.txt` sha256
  `7b19c058e2f733236f8ad6bd6e49ced14f4fef2b5accfdc69664766a08d7b8e8`;
  `prior-186-godot-rows.json` sha256 `25e46f4f…` (r84 canonical);
  `prior-188-godot-rows.json` sha256 `bab5dc6f…` (new r85 reference,
  built from this round's frozen receipt)
- `corpus/live/r85-baseline/tools/{postcommit_verify.py,
  postcommit_verify_godot.py,postcommit_verify_godot_188.py,
  watch_commits.sh}`, `watch.log` (18:22:53Z → filing)

## Limits

- Single host, single Blender/Godot/Node build; one replay per surface
  per commit — zero case failures on any completed run, no flake-retry
  needed or observed.
- Post-commit coverage is exactly one work commit (`f230443`, landed
  19:33:24Z, verified through `watch.log` + `git show`). Any later
  fixture change needs its own re-check — the checkers are mechanical:
  `python3 tools/postcommit_verify.py <new probe.stdout.txt>
  prior-134-arm-rows.txt` and `python3
  tools/postcommit_verify_godot_188.py <new verdicts.json>
  prior-188-godot-rows.json`.
- The arm's internal semantics (Jolt-threaded child re-exec, the
  Dummy-backend `unexpected` classification, ClassDB 3-way positive
  evidence, the `srv_phase_delta` write path) are the author's cells;
  this seat verified the arm as *data* — the 3 new markers match their
  declared expected lines and PASS under the tracked gate — not the
  physics/backend claim's interpretation. Jolt/Dummy measurements are
  one build's answer (4.7.2.stable.arch_linux.ed1daf0bf); other builds
  may gate differently.
- `corpus/live/` is gitignored; "prior receipt" comparisons are against
  on-disk runs retained under `corpus/live/r8{1,2,3,4}-baseline/` —
  not committed blobs.
