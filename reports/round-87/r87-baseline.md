# game-dev-3d round 87 — freeze @ af15a52 + battery replay + post-commit re-verification (seat: baseline)

Baseline replay for the r87 move. Declared invariant under test (per the
r86-closed contract, restated in the r87 baseline brief): **prior 195 Godot
rows byte-identical at identical positions (stdout+stderr bytes), prior 134
ARM rows (bpy) byte-identical, three.js 31/31, fixture digests pinned; any
r87 cells must land insertion-only (new cells appended).**

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (built 2026-09-01),
`/usr/bin/godot` = 4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7,
Node v24.21.0, three.js 0.186.1 (tracked lockfile pins `"three": "0.186.1"`),
32 cores. Single host, shared: a sibling lane (game-dev-2d r78-reviewer)
ran its own Godot battery concurrently during the frozen Godot run.

## PHASE 1 — Frozen tree (pre-move baseline @ af15a52)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r87-baseline/frozen/frozen-tree.tar

- Frozen commit: `af15a5265668d43560c9ee1aaa79d7ab8d6828b0`
  (`r86 report-last: adjudicator + LOG + SCORECARD + seat reports`) — the
  last pre-r87 commit; contains the r86 arm (`4e65726` four new cells,
  `dd1737a` folds, `af15a52` report-last) and the committed r87 scout
  report (`reports/round-87/r87-scout-dss.md`).
- Archive sha256
  `91921c10c91edf935d6d3c21002bb3c67e48d5db98e16801025ba634b5b08765`,
  **437 tar members = 400 file members + 37 dir entries**; file-member
  list vs `git ls-files` (LC_ALL=C sorted): `comm -23` **0 lines**,
  `comm -13` **0 lines** (both directions clean).
- Extract dir `frozen-extract/` = exactly the 400 tar file members
  (`find` vs member list, 0 diff; + gitignored
  `corpus/fixtures/three/node_modules` copied in for the Node suites —
  see the three.js note below).
- Frozen fixture digests `frozen/fixture-digests.txt` (**55 files**:
  49 `.gd` + 4 `.py` + `project.godot` + `README.md`): live worktree vs
  frozen extract → **all 55 identical** (`diff` empty); receipt
  `seed_digests` cross-checked against **`HEAD` blobs** (`git show
  HEAD:corpus/fixtures/<name>`, 55/55) **and** the live worktree
  (55/55) → **0 mismatches** — the battery measured the committed bytes.
- `git status --porcelain` at freeze (21:20Z): **empty — zero pre-existing
  dirty state, tracked or untracked**; the only dirty-capable roots are
  gitignored (`corpus/fixtures/__pycache__/`,
  `corpus/fixtures/three/node_modules/`, `corpus/live/`). The r86 seat
  reported sibling report paths as pre-move churn; at r87 the scout report
  was already committed, so there is none.
- All writes confined to gitignored `corpus/live/r87-baseline/` + this
  report. No git mutations performed by this seat.
- A stale r86-baseline watcher (PID 1575441, started 17:06 local) is still
  polling and appending to `corpus/live/r86-baseline/watch.log`; left
  untouched (other seat's process).

### bpy battery — frozen — 83/83, stdout byte-identical ×11

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r87-baseline/runs        (cwd = frozen-extract)

- Receipt `runs/bpy-20261014T212001098256Z/verdicts.json` (started
  21:20:10Z, verdict written 21:20:08Z local = 21:20:08Z — 7 s wall):
  `verdict` **PASS**; `totals: cases=83 pass=83 fail=0 (signal_fail=0
  quirk_drift=0)`; `launch_ok=true`, `done_marker=true`, `fatal_arms=[]`,
  `n_arm_lines=131`; `probe.stderr.txt` 0 bytes (sha `e3b0c442…`, empty).
- `probe.stdout.txt` sha256
  `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
  **byte-identical to all nine prior receipts** (r82 ×2, r83 frozen +
  post, r84 frozen + post, r85 frozen + post, r86 frozen + post) — 11
  identical receipts total.
- Prior-134 check (`tools/postcommit_verify.py` vs
  `prior-134-arm-rows.txt`, sha256 `7b19c058…` **unchanged** from
  r83/r84/r85/r86): **ordered-subsequence PASS 134/134, all at identical
  ARM positions, 0 inserted rows**; 134 physical `^ARM` lines / 131
  unique keys.

### Godot battery — frozen — 195/195 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r87-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout                        (cwd = frozen-extract)

- Receipt `runs/20261014T212001121842Z/verdicts.json` (started
  21:20:11Z, verdict written 21:23:40Z — 3 m 29 s wall under sibling
  lane contention): `verdict` **PASS**; `totals: cases=195 pass=195
  fail=0 ordinary=149 negative_controls=46`; `seeds_unchanged=true`; all
  four probes armed and ok (`crash_probe_ok`/`stream_probe_ok`/
  `tree_probe_ok` true, mutation probe detected=true); `seed` =
  `…/corpus/live/r87-baseline/frozen-extract/corpus/fixtures` — ran
  against the frozen bytes; `godot_version`
  `4.7.2.stable.arch_linux.ed1daf0bf`.
- `seed_digests` (55 entries) cross-verified against `HEAD` blobs and the
  live worktree: **0 mismatches** (above).
- Prior-191 check (`tools/postcommit_verify_godot_prior.py` vs the r86
  canonical `prior-191-godot-rows.json`, sha256 `6d784726…`):
  **ordered-subsequence PASS 191/191, all at identical positions**;
  exactly **4 inserted rows at indices 192–195** — the r86 arm cells
  (`phys3d_events_script_size_gate`, `phys3d_events_deferred_hang`,
  `phys3d_events_backend_tier`, `phys3d_events_dummy_floor`), each PASS
  `actual_exit=0`.
- Full-row continuity: frozen 195 rows vs the r86 post-commit receipt
  (`../r86-baseline/runs-post/20261014T203735129154Z/verdicts.json`) —
  **195/195 index-identical on [case, verdict, actual_exit, marker,
  stdout lines, stderr lines]**. The r86 folds + report-last commits
  (`dd1737a`, `af15a52`) moved no verdict row and changed no captured
  stdout/stderr byte.
- New r87 reference built: `prior-195-godot-rows.json` (195 tuples,
  sha256 `dd8812be27345f2921c687cbf0a60adfe48dc1c644a51966ba803ddef2964781`)
  and the strict reference `prior-195-godot-rows-full.json` (195 rows
  incl. stdout/stderr line lists, sha256
  `ea95352797c6655d97c14919f0dab8cbfc382b682804eb22f870fb61a350af1d`),
  both built by `tools/build_prior_rows{,_full}.py` from this frozen
  receipt.
- **Strict-comparison methodology validated on r86 data before use**:
  `tools/verify_prior_rows_full.py` applied to r86 frozen→post
  (different scratch paths, different run timestamps) reports
  **191/191 index-identical including stdout+stderr bytes** + the 4
  declared insertions. So the r87 Phase-2 strict check is safe: prior
  case stdout/stderr do not embed the timestamped scratch path.

### Node three.js suites — frozen — 31/31

Six receipts `receipts/frozen-run_*.json` (sha256s in
`receipts/frozen-shas.txt`… see Receipts section):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0, three=0.186.1 — 31/31

Disclosed deviation: `frozen-extract/corpus/fixtures/three/node_modules`
was **copied from the live tree** (three@0.186.1 verified by `npm ls` on
both sides; the tracked `package-lock.json` pins `"three": "0.186.1"`)
instead of running `npm ci`, because `node_modules` is gitignored and
therefore absent from the archive. The suites' own seed digests cover the
tracked suite files only (`*.mjs`, `package.json`, `package-lock.json`),
so the copied dep tree does not affect the pinned surface.

### Pre-move status at freeze

- HEAD `af15a52`; `git status --porcelain` **empty** from 21:20:12Z
  onward (all-dirty=0, fix_dirty=0, fix_untracked=0 in `watch.log`).
- `tools/watch_commits.sh` (20 s poll, frozen commit pinned) running from
  21:20:12Z → `watch.log`; `tools/wait_commit.sh` (15 s poll, bounded
  `MAX_S` default 7200) available for the Phase-2 wait.

## PHASE 2 — Post-commit re-verification — commit `c57fa40c` (landed 21:51:06Z)

`watch.log` brackets the full write window: `head=af15a52 fix_dirty=0`
21:20:12Z→21:26:53Z; `fix_dirty=1` (`phys3d_events.gd`) from 21:27:13Z;
`fix_dirty=2` from 21:30:13Z; `fix_dirty=3` (+`README.md`) from 21:30:33Z;
last pre-commit line 21:50:53Z; **`head=c57fa40 fix_dirty=0` from
21:51:13Z** through filing. One r87 work commit landed:

    c57fa40c3b560b8f26e13231eb8b90e4c4ab8526  (commit ts 18:51:06 -03:00
    = 21:51:06Z)
    r87 work: body-tier direct-state lattice — 6 arms
    "body_handle identity/acq-vs-use split/step-stamped getters/write-loss
     bounded race/body_tier GP-vs-Jolt split/freed_space crash tail.
     201/201 x3, prior 195 rows byte-stable; scouts' write-loss did not
     replicate — pinned as accounted tally, race=bounded."

`git show --numstat`: **4 files, +1378/−4** —
`corpus/fixtures/phys3d_events.gd` +876/−4 (six new arms + their child
bodies — the arm's own file, not a prior fixture), `run_battery.py`
+14/−0 (exactly **6 CASES rows appended** + a 2-line comment, no harness
edits), `README.md` +90/−0, `reports/round-87/r87-author.md` +398/−0.
**No `bpy_battery.py`/`bpy_sync_probe.py`/`timeout_descendant.py`, no
other prior `.gd` fixture, no `three/` file touched** — sibling-battery
surfaces pinned.

All post-commit runs below executed on the settled worktree
(`head=c57fa40 fix_dirty=0` from 21:51:13Z onward per `watch.log`).

### bpy — live worktree replay @ `c57fa40c` — 83/83, stdout byte-identical

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r87-baseline/runs-post   (cwd = live tree)

Receipt `runs-post/bpy-20261014T215112235224Z/verdicts.json` (started
21:51:12Z, after the commit): `verdict` **PASS**; `totals: cases=83
pass=83 fail=0 (signal_fail=0 quirk_drift=0)`; `done_marker=true`,
`fatal_arms=[]`, `n_arm_lines=131`; stderr 0 bytes.
`probe.stdout.txt` sha256 `6a98c570…defc3` — **byte-identical to the
frozen pre-move receipt AND all ten prior r82–r86 receipts**
(12 identical receipts total). `tools/postcommit_verify.py` vs
`prior-134-arm-rows.txt`: **ordered-subsequence PASS 134/134, all at
identical ARM positions, 0 inserted rows.**

### Godot — live worktree replay @ `c57fa40c` — 201/201 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r87-baseline/runs-post \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout                        (cwd = live tree)

Receipt `runs-post/20261014T215119929090Z/verdicts.json` (started
21:51:19Z, settled worktree; `seed` = live `corpus/fixtures`):
`verdict` **PASS**; `totals: cases=201 pass=201 fail=0 ordinary=155
negative_controls=46`; `seeds_unchanged=true`; all four probes ok
(crash/stream/tree + mutation detected); `seed_digests` vs `HEAD` blobs
**0 mismatches** — the battery measured the committed bytes.
`tools/verify_prior_rows_full.py` vs `prior-195-godot-rows-full.json`
(sha256 `ea953527…`, built this round from the frozen 195-row receipt):

- **Index-identical: PASS — 195/195 prior rows byte-identical at
  IDENTICAL positions, comparing case, verdict, actual_exit, marker AND
  the captured stdout/stderr line lists** (strictest form: clean append,
  nothing moved, 0 dropped, 0 re-verdicted, no captured byte changed).
- **6 inserted rows at indices 196–201** — exactly the declared arm
  cells, all PASS, `actual_exit=0`:
  - `phys3d_events_body_handle` → `PASS phys3d_events body_handle
    if_same=true ss_same=true detach=nil held_live=true reattach=true
    twin=true two_fetch=true dummy_cb=never child_exit=0`
  - `phys3d_events_acq_use` → `PASS phys3d_events acq_use gate=refused
    out_of_phase=8 held_read=live write=ungated reps=8 child_exit=0`
  - `phys3d_events_step_stamp` → `PASS phys3d_events step_stamp
    gp_step_pre=0.001 gp_grav_pre=zero jolt_step_pre=0.0
    jolt_grav_pre=real step_post=0.016667 cc_off=0 cc_on=4 last_step=4,0
    child_exit=0`
  - `phys3d_events_write_loss` → `PASS phys3d_events write_loss
    gate=refused reps=8 same_turn=8 tally=8 race=bounded child_exit=0`
  - `phys3d_events_body_tier` → `PASS phys3d_events body_tier
    gp_impulse=zero jolt_impulse=real gp_lshape=-1 jolt_lshape=0
    gp_sleep_lv=kept jolt_sleep_lv=zeroed dummy_cc=0
    detach_write=silent,loud,silent child_exit=0`
  - `phys3d_events_freed_space` → `PASS phys3d_events freed_space
    gp=crash jolt=crash dummy=empty child_exit=0` (crash-class row, last
    in CASES as declared)
- 0 dropped cases, 0 case-name/tuple collisions, 0 verdict flips.
- `postcommit_verify_godot_prior.py` cross-view vs
  `prior-195-godot-rows.json`: **ordered-subsequence PASS 195/195, all at
  identical positions, 6 inserted** — agrees with the strict tool.
- `seed_digests` frozen-vs-post: **exactly 3 differing entries —
  `phys3d_events.gd`, `run_battery.py`, `README.md`** (the declared arm
  files); the other **52 seed files byte-identical**.
- The arm's independent claim (commit message: "201/201") **reproduces
  on this seat**: 195 → 201 cases, all PASS.

### New cells are deterministic here — 3 reps each, byte-identical

The six inserted cells were re-run 3× each (`--only`, three fresh
receipts `runs-post/reps/20261014T2156{1316,3589,5926}…`, `reps.txt`):
every cell's `[verdict, actual_exit, marker, stdout, stderr]` row is
**identical across all three reps and identical to the post receipt row**:

    body_handle c8ff29eea20b · acq_use 9ad22ccd16e1 · step_stamp 5915307769a7
    write_loss  277277f0b853 · body_tier 54ef99ad5fb7 · freed_space a2de81d1c993
    (marker_sha = sha256 of the row's marker+stdout+stderr, first 12 hex)

No flake observed on this host for the declared bounded-race cell
(`write_loss`: `same_turn=8 tally=8 race=bounded`, 3/3) — corroborating
the author's own note that the scouts' write-loss did not replicate.
Disclosed scope: the author's "201/201 x3" full-battery claim is their
own; this seat independently reproduced 201/201 once on the settled tree
plus 3× stability on the six new cells.

### jolt_threaded / new child logs — map compare (the r86 brief's explicit mode)

    python3 tools/child_log_map.py --compare \
      childlogs/frozen-<proj>.child.log childlogs/post-<proj>.child.log

- **All 15 shared child logs: map PASS (identical)** — `thrproj`,
  `joltproj`, `joltthrproj`, `dummyproj`, `szminproj`, `szplainproj`,
  `szpadproj`, `szfxproj`, `hangproj`, `hangdummyproj`, `tierplainproj`,
  `tierjoltproj`, `tierdummyproj`, `floordummyproj`, `floorrealproj`:
  CHILD_RESULT pairs + CHILD_NOTE lines unchanged (bytes differ only in
  the embedded scratch path / backtrace line numbers, as designed).
- 14 new-cell child logs captured (`post-{bhplain,bhjolt,bhdummy,
  auplain,aujolt,wl,btplain,btjolt,btdummy,fsplain,fsjolt,fsdummy,
  ssplain,ssjolt}proj.child.log`, shas in `childlogs/post-shas.txt`) —
  no frozen counterpart; new cells.

### three.js — live worktree re-run @ `c57fa40c` — 31/31

Six suites re-run on the live tree (`run_*.mjs --receipt
receipts/*.post.json`; `three/` untouched by `c57fa40c`):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0, three=0.186.1 — 31/31

## Byte-stability summary (cell-by-cell)

| surface | pre-move frozen @ `af15a52` | post-commit @ `c57fa40c` | drift |
|---|---|---|---|
| bpy cases | 83/83 PASS | 83/83 PASS | none |
| bpy stdout sha256 | `6a98c570…defc3` | `6a98c570…defc3` (byte-identical ×12 receipts incl. r82–r86's) | none |
| prior 134 ARM rows | 134/134 at identical positions, 0 inserted | 134/134 byte-identical at identical positions, 0 inserted | none |
| Godot battery | 195/195 + 4 probes | 201/201 + 4 probes; prior-195 195/195 index-identical incl. stdout+stderr | none in prior; +6 declared cells appended @196–201 |
| new cells (6) | n/a | 3 reps each, row byte-identical, all PASS, match receipt | none |
| Godot seed digests | 55-entry map == live digests @ freeze | 55-entry map == committed bytes; frozen-vs-post diff = exactly `phys3d_events.gd`, `run_battery.py`, `README.md` | none outside declared arm (52/55 identical) |
| child logs | 15 frozen logs captured | all 15 shared logs map **identical**; 14 new-cell logs captured | map none; bytes differ only by scratch path/line numbers |
| three.js | 31/31, seeds unchanged | 31/31, seeds unchanged | none |
| fixtures (siblings) | digests above | `run_battery.py` +14/−0 (6 CASES rows appended); `phys3d_events.gd` +876/−4 (own arm); `README.md` +90/−0; bpy/three/prior `.gd` untouched | none outside the declared arm |
| worktree churn | clean @ freeze | `fix_dirty=1` 21:27:13Z, `2` 21:30:13Z, `3` 21:30:33Z on `af15a52` → clean `c57fa40` from 21:51:13Z | window fully bracketed by `watch.log` |

## Receipts / scratch (all inside write scope)

- `corpus/live/r87-baseline/frozen/frozen-tree.tar` — `git archive HEAD`
  @ `af15a52`, sha256 `91921c10…` (437 members / 400 files, comm-clean)
- `frozen/frozen-head.txt`, `fixture-digests.txt` (55),
  `three-digests.txt` (16), `tar-members.txt`,
  `tar-file-members.txt`, `git-files.txt`, `git-files-sorted.txt`,
  `extract-files.txt`, `start.txt` (21:20:01Z)
- `corpus/live/r87-baseline/frozen-extract/` — replay scratch tree
  (400 tracked files + copied `three/node_modules`)
- `runs/bpy-20261014T212001098256Z` (frozen bpy 83/83, stdout sha
  `6a98c570…`), `runs/20261014T212001121842Z` (frozen godot 195/195 +
  4 probes + mutation verdict)
- `runs-post/bpy-20261014T215112235224Z` (bpy 83/83 @ `c57fa40c`, stdout
  sha `6a98c570…` byte-identical), `runs-post/20261014T215119929090Z`
  (godot 201/201 @ `c57fa40c` + 4 probe verdicts + mutation verdict)
- `runs-post/reps/20261014T2156{13169304,35893278,59268511}Z` — 3 × 6
  new-cell reps; `reps.txt`, `reps-{1,2,3}.log`
- `receipts/frozen-run_cases.json` sha `939b8568…`,
  `frozen-run_layer_cases.json` sha `19363f57…`,
  `frozen-run_order_cases.json` sha `fff3c4a3…`,
  `frozen-run_camera_cases.json` sha `a97211d8…`,
  `frozen-run_ortho_cases.json` sha `cd0576ba…`,
  `frozen-run_ray_cases.json` sha `fd09a008…` — 31/31 frozen;
  `receipts/run_cases.post.json` sha `46bb981a…`,
  `run_layer_cases.post.json` sha `85cbde53…`,
  `run_order_cases.post.json` sha `ab821db3…`,
  `run_camera_cases.post.json` sha `de99bbed…`,
  `run_ortho_cases.post.json` sha `5bf3093f…`,
  `run_ray_cases.post.json` sha `5ccaaafc…` — 31/31 @ `c57fa40c`
- `childlogs/frozen-*` (15 files) + `childlogs/post-*` (29 files: the 15
  shared + 14 new-cell), shas in `childlogs/{frozen,post}-shas.txt`
- `prior-134-arm-rows.txt` sha256 `7b19c058…` (unchanged);
  `prior-195-godot-rows.json` sha256 `dd8812be…`;
  `prior-195-godot-rows-full.json` sha256 `ea953527…` (new r87
  references)
- `post-head.txt`, `post-commit-show.txt`, `post-commit-numstat.txt`,
  `post-commit-files.txt` — landed commit `c57fa40c` metadata
- `tools/{postcommit_verify.py, postcommit_verify_godot_prior.py,
  child_log_map.py, build_prior_rows.py, build_prior_rows_full.py,
  verify_prior_rows_full.py, watch_commits.sh, wait_commit.sh,
  phase2_run.sh}`, `watch.log`, `wait_commit.log`,
  `frozen-bpy.log` (sha `e4a80fbe…`), `frozen-godot.log` (sha
  `e92f9977…`), `post-bpy.log`, `post-godot.log`

## Limits

- Single host, single Blender/Godot/Node build; one frozen replay per
  surface, one post-commit replay per surface, plus 3 reps on the six new
  cells — zero case failures on any completed run, no flake-retry needed
  or observed. The sibling 2d lane ran concurrently during Phase 1 (Godot
  wall time 3 m 29 s vs r86's ~2 m 30 s) — contention affects timing only,
  not verdicts.
- Phase 2 coverage is exactly the one r87 work commit (`c57fa40c`, landed
  21:51:06Z, verified through `watch.log` + `git show`). Any later fixture
  change (r87 folds / report-last) needs its own re-check — the checkers
  are mechanical:
  `python3 tools/postcommit_verify.py <new probe.stdout.txt>
  prior-134-arm-rows.txt`, `python3 tools/verify_prior_rows_full.py
  <new verdicts.json> prior-195-godot-rows-full.json` (strict) or
  `python3 tools/postcommit_verify_godot_prior.py <new verdicts.json>
  prior-195-godot-rows.json` (ordered-subsequence), and the child.log
  check is `python3 tools/child_log_map.py --compare <a> <b>`.
- The r87 arm's semantics (held-handle identity, acquisition-vs-use split,
  step-stamped getters, write-loss race, backend split, freed-space crash)
  are the author's cells; this seat verifies the arm as *data* — prior rows
  byte-stable, new markers matching their declared expected lines under the
  tracked gate — not the claim's interpretation. The crash-class row's
  `gp=crash jolt=crash` is a child-process exit class observed by the
  parent, not a re-derived crash taxonomy.
- Jolt/Dummy measurements are one build's answer
  (`4.7.2.stable.arch_linux.ed1daf0bf`); other builds may gate differently.
- Persistent processes left behind by this seat: the r87 watcher
  (`tools/watch_commits.sh`, 20 s poll → `corpus/live/r87-baseline/watch.log`)
  is still running at filing so a later fold/report-last commit remains
  bracketed; the stale r86 watcher (PID 1575441) was left untouched.
- `corpus/live/` is gitignored; "prior receipt" comparisons are against
  on-disk runs retained under `corpus/live/r8{1..6}-baseline/` — not
  committed blobs.
