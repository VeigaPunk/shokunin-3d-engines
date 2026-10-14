# game-dev-3d round 86 — freeze @ 3d42f77 + battery replay + post-commit re-verification (seat: baseline)

Baseline replay for the r86 move. Declared invariant under test (per the
r85-closed contract): **prior 191 Godot rows byte-identical at identical
positions, prior 134 ARM rows (bpy) byte-identical, three.js 31/31,
falsifier liveness re-verified; any r86 cells must land insertion-only;
the `jolt_threaded` child.log is compared as a *map*, never as bytes.**

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (built 2026-09-01),
`/usr/bin/godot` = 4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7,
Node v24.21.0, three.js 0.186.1 (tracked lockfile), 32 cores. Single host.

## PHASE 1 — Frozen tree (pre-move baseline @ 3d42f77)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r86-baseline/frozen/frozen-tree.tar

- Frozen commit: `3d42f77544e1288c002fce1ed875304c4984c195`
  (`r85 report-last: adjudicator ADMIT-corr + 8 seat reports + ledger`) —
  the last pre-r86 commit; contains the r85 arm (`f230443` jolt_threaded +
  dummy_refused + srv_phase_delta cells, `4e6fbe3` folds, `3d42f77`
  report-last).
- Archive sha256
  `a826a2ba3827eda0ae13e6b4d8d7dfac04f5ac26e1286dbff1150a9c4e7bcd37`,
  426 tar members = **390 file members + 36 dir entries**; file-member
  list vs `git ls-files`: `comm -23` **0 lines**, `comm -13` **0 lines**
  (both directions clean).
- Extract dir `frozen-extract/` = exactly the 390 tar file members
  (`find` vs member list, 0 diff; + gitignored
  `corpus/fixtures/three/node_modules` from `npm ci`).
- Frozen fixture digests `frozen/fixture-digests.txt` (**55 files**:
  49 `.gd` + 4 `.py` + `project.godot` + `README.md`): cross-verified
  against the live worktree (`sha256sum corpus/fixtures/*` → `diff`
  empty, **all 55 identical**) and against the battery receipt's
  `seed_digests` map (**0/55 mismatches**), `git status --porcelain --
  corpus/fixtures` = 0 at freeze (20:06Z).
- The landed r85 fixture revision at this commit is
  `phys3d_events.gd` sha `23bb2e27…` (`run_battery.py` `2e1a3242…`) —
  the `4bcde2bf…` sha r86-scout read mid-flight is the pre-fold
  `f230443` revision, superseded by the r85 folds commit `4e6fbe3`.
- All writes confined to gitignored `corpus/live/r86-baseline/` +
  this report. No git mutations performed by this seat.

### bpy battery — frozen — 83/83, stdout byte-identical ×9

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r86-baseline/runs        (cwd = frozen-extract)

- Receipt `runs/bpy-20261014T200631933709Z/verdicts.json` (started
  20:06:31Z): `verdict` **PASS**; `totals: cases=83 pass=83 fail=0
  (signal_fail=0 quirk_drift=0)`; `probe_exit=0`, `done_marker=true`,
  `fatal_arms=[]`, `n_arm_lines=131`; `probe.stderr.txt` 0 bytes.
- `probe.stdout.txt` sha256
  `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
  **byte-identical to all eight prior receipts** (r82 ×2, r83 frozen +
  post, r84 frozen + post, r85 frozen + post) — 9 identical receipts
  total.
- Prior-134 check (`tools/postcommit_verify.py` vs
  `prior-134-arm-rows.txt`, sha256 `7b19c058…` unchanged from r83/r84/r85):
  **ordered-subsequence PASS 134/134, all at identical ARM positions,
  0 inserted rows**; 134 physical `^ARM` lines / 131 unique keys.

### Godot battery — frozen — 191/191 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r86-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout                        (cwd = frozen-extract)

- Receipt `runs/20261014T200631955691Z/verdicts.json` (started
  20:06:31Z): `verdict` **PASS**; `totals: cases=191 pass=191 fail=0
  ordinary=145 negative_controls=46`; `seeds_unchanged=true`; all four
  probes armed and ok (`crash_probe_ok`/`stream_probe_ok`/
  `tree_probe_ok` true, mutation probe detected=true); `seed` =
  `frozen-extract/corpus/fixtures` — ran against the frozen bytes;
  `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`.
- `seed_digests` (55 entries) cross-verified against the live worktree
  shas taken at freeze: **0 mismatches** — the battery measured the
  committed bytes.
- Prior-188 check (`tools/postcommit_verify_godot_prior.py` vs the r85
  canonical `prior-188-godot-rows.json`): **ordered-subsequence PASS
  188/188, all at identical positions, 0 dropped, 0 drift**; exactly
  **3 inserted rows at indices 189–191** — the r85 arm cells
  (`phys3d_events_jolt_threaded`, `phys3d_events_dummy_refused`,
  `phys3d_events_srv_phase_delta`), each PASS `actual_exit=0`.
- New r86 post-commit reference built:
  `prior-191-godot-rows.json` (191 tuples) sha256
  `6d784726ce77e1d4721b581440aebd107418d24b1e8003640f3fee49e7726f05`.
- **Reference continuity across the r85 folds**: the frozen 191 rows are
  **row-identical to r85's own post-commit receipt** @ `f230443`
  (`../r85-baseline/runs-post/20261014T193334590923Z/verdicts.json`,
  zip-compare → 0 diffs) even though `4e6fbe3` edited
  `phys3d_events.gd` (+19/−12 lines: comments/regex/folds). So the r85
  folds changed fixture text only — no verdict row moved — and the r86
  comparison base is the same tuple set r85 closed on.

### Node three.js suites — frozen — 31/31

Six receipts `receipts/run_*.json` (after `npm ci` inside
`frozen-extract/corpus/fixtures/three`; three@0.186.1 per tracked
lockfile):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0 — total 31/31

### jolt_threaded child.log — byte-instability measured, map is the unit

The r86 brief pins the child.log compare as map-only. Measured on the
frozen bytes (same scratch, 3 reps, then a renamed scratch copy):

| rep | scratch path | child.log sha256 | CHILD_RESULT map |
|---|---|---|---|
| frozen battery | `…/runs/20261014T200631955691Z/scratch` | `200299a1…` | 8 pairs |
| rep 1/2/3 (same path) | same | `200299a1…` ×3 (**byte-identical**) | identical |
| path-shift rep | `/tmp/r86-pathcheck-scratch` | `c6189006…` (**differs**) | **identical** |

- The only byte difference is the absolute script path embedded in the
  refusal backtrace (`_child_jolt_threaded (…/phys3d_events.gd:1003)`,
  10 lines); `CHILD_NOTE` set (6 lines) and the 8-pair CHILD_RESULT map
  are identical across all four runs, and stdout marker + stdout sha
  (`249fe984…` ×3) are identical.
- So child.log byte drift across a round boundary is **expected and
  fully explained** (new timestamped scratch path, plus any line-number
  shift above line 1003 from the r86 arm) — the map is the evidence.
- Tool: `tools/child_log_map.py` (extract + `--compare`).

### Pre-move status at freeze

- HEAD `3d42f77`; `git status --porcelain` clean apart from sibling
  seat/report paths; fixture surface clean (`fix_dirty=0` from
  20:06:29Z onward).
- `tools/watch_commits.sh` (20 s poll) running from 20:06:29Z →
  `watch.log`; `tools/wait_commit.sh` (15 s poll, bounded) → `wait_commit.log`.

## PHASE 2 — Post-commit re-verification — commit `4e657267` (landed 20:37:24Z)

`watch.log` brackets the full write window: `head=3d42f77
fix_dirty=0` 20:06:29Z→20:13:49Z; `fix_dirty=1` (README.md) from
20:14:09Z; `fix_dirty=2` (+`phys3d_events.gd`) from 20:16:29Z;
`fix_dirty=3` (+`run_battery.py`) from 20:24:09Z; **`head=4e65726
fix_dirty=0` from 20:37:29Z** through filing. One r86 work commit landed:

    4e657267fdb116579741ecce028e3f5c4511aa3d  (commit ts 17:37:18 -03:00
    = 20:37:18Z)
    r86 work: size-gate, deferred-hang, backend-tier, dummy-floor cells
    "4 arms, 191 -> 195 cases. … Nav cell deliberately not landed"

`git show --numstat`: **6 files, +2033/−8** —
`corpus/fixtures/phys3d_events.gd` +615/−7 (four new arms + their child
bodies — the arm's own file, not a prior fixture), `run_battery.py`
+8/−0 (exactly **4 CASES rows appended**, no harness edits),
`README.md` +59/−1, `reports/round-86/{r86-author,r86-boundary,
r86-scribe}.md` +478/+475/+398. **No `bpy_battery.py`/
`bpy_sync_probe.py`/`timeout_descendant.py`, no other prior `.gd`
fixture, no `three/` file touched** — sibling-battery surfaces pinned.

All post-commit runs below executed on the settled worktree
(`head=4e65726 fix_dirty=0` from 20:37:29Z onward per `watch.log`).

### bpy — live worktree replay @ `4e657267` — 83/83, stdout byte-identical

    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs …/corpus/live/r86-baseline/runs-post   (cwd = live tree)

Receipt `runs-post/bpy-20261014T203732322457Z/verdicts.json` (started
20:37:32Z, after the commit): `verdict` **PASS**; `totals: cases=83
pass=83 fail=0`; `done_marker=true`, `fatal_arms=[]`; stderr 0 bytes.
`probe.stdout.txt` sha256 `6a98c570…defc3` — **byte-identical to the
frozen pre-move receipt AND all eight r82/r83/r84/r85 receipts**
(10 identical receipts total). `tools/postcommit_verify.py` vs
`prior-134-arm-rows.txt`: **ordered-subsequence PASS 134/134, all at
identical ARM positions, 0 inserted rows.**

### Godot — live worktree replay @ `4e657267` — 195/195 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs …/corpus/live/r86-baseline/runs-post \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout                        (cwd = live tree)

Receipt `runs-post/20261014T203735129154Z/verdicts.json` (started
20:37:35Z, settled worktree; `seed` = live `corpus/fixtures`):
`verdict` **PASS**; `totals: cases=195 pass=195 fail=0 ordinary=149
negative_controls=46`; `seeds_unchanged=true`; all four probes ok
(crash/stream/tree + mutation detected).
`tools/postcommit_verify_godot_prior.py` vs `prior-191-godot-rows.json`
(sha256 `6d784726…`, built this round from the frozen 191-row receipt):

- **Ordered-subsequence: PASS — 191/191 prior tuples present,
  byte-identical, at IDENTICAL positions** (strictest form: clean
  append, nothing moved, 0 dropped, 0 re-verdicted).
- **4 inserted rows at indices 192–195** — exactly the declared arm
  cells, all PASS, `actual_exit=0`:
  - `phys3d_events_script_size_gate` → `PASS phys3d_events
    script_size_gate min_thr=refused min_plain=granted pad_thr=granted
    fixture_thr=granted child_exit=0`
  - `phys3d_events_deferred_hang` → `PASS phys3d_events deferred_hang
    threaded_rc=137 abort=true no_marker=true dummy_rc=0
    floor_no_hang=true child_exit=0`
  - `phys3d_events_backend_tier` → `PASS phys3d_events backend_tier
    plain=honors jolt=ignores dummy=floor margin=inert,binds,empty
    sepray=same,differs,floor child_exit=0`
  - `phys3d_events_dummy_floor` → `PASS phys3d_events dummy_floor
    dummy=silent-floor dummy_errs=0 real=real-values real_errs=2
    child_exit=0`
- 0 dropped cases, 0 case-name/tuple collisions, 0 verdict flips.
- `seed_digests` frozen-vs-post: **exactly 3 differing entries —
  `phys3d_events.gd`, `run_battery.py`, `README.md`** (the declared arm
  files); the other **52 seed files byte-identical**.
- The arm's independent claim (commit message: "191 → 195 cases")
  **reproduces on this seat**.

### jolt_threaded child.log — map compare (the r86 brief's explicit mode)

    python3 tools/child_log_map.py --compare \
      childlogs/frozen-jolt_threaded.child.log \
      childlogs/post-jolt_threaded.child.log

- **Map: PASS (identical)** — the 8 CHILD_RESULT pairs
  (`jt_backend=Jolt Physics`, `jt_threaded=true`,
  `jt_dss_class=JoltPhysicsDirectSpaceState3D`, `jt_isect=same-signature`,
  `jt_cast=differs-constants`, `jt_btm=differs-constants`,
  `jt_contact_stale=same-signature`, `jt_static_nopair=inverts`),
  the 6 `CHILD_NOTE` lines, and the 50 other non-empty lines all match.
- **Bytes differ, as the brief warns** — sha256 `200299a1…` (frozen) vs
  `2fb1c2ed…` (post), 26 diff lines = **13 changed lines, every one of
  them the refusal backtrace only**: the absolute script path changed
  (`…/runs/20261014T200631955691Z/scratch/…` →
  `…/runs-post/20261014T203735129154Z/scratch/…`) **and the line number
  moved 1003 → 1390** because the r86 arm added 387 lines above the
  refusal site. No semantic line moved — the parent's own verdict compare
  (which reads exactly these pairs) passed on both runs.
- The post scratch also carries the four new cells' child logs
  (`szminproj`/`szplainproj`/`szpadproj`/`szfxproj`, `hangproj`/
  `hangdummyproj`, `floordummyproj`/`floorrealproj`) — new cells, no
  frozen counterpart to compare.

### three.js — live worktree re-run @ `4e657267` — 31/31

Six suites re-run on the live tree (`run_*.mjs --receipt
receipts/*.post.json`; `three/` untouched by `4e657267`):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0 — total 31/31

### New cells are deterministic here — 3 reps each, byte-identical

The four inserted cells were re-run 3× each on a copy of the settled
scratch (`/tmp/r86-newcells-scratch`; `newcells-reps.txt`) — stdout
sha256 identical across all three reps per arm, and identical to the
receipt marker:

    script_size_gate 3/3 sha 4c5f1b9f… · deferred_hang 3/3 sha 529c43f4…
    backend_tier     3/3 sha 08511333… · dummy_floor   3/3 sha f1391f7f…

No flake observed on this host for the stochastic-looking size-gate cell
(the scout's band result reproduces as `min_thr=refused` /
`pad_thr=granted` / `fixture_thr=granted`, 3/3).

## Byte-stability summary (cell-by-cell)

| surface | pre-move frozen @ `3d42f77` | post-commit @ `4e657267` | drift |
|---|---|---|---|
| bpy cases | 83/83 PASS | 83/83 PASS | none |
| bpy stdout sha256 | `6a98c570…defc3` | `6a98c570…defc3` (byte-identical ×10 receipts incl. r82–r85's) | none |
| prior 134 ARM rows | 134/134 at identical positions, 0 inserted | 134/134 byte-identical at identical positions, 0 inserted | none |
| Godot battery | 191/191 + 4 probes | 195/195 + 4 probes; prior-191 191/191 at identical positions | none in prior; +4 declared cells appended @192–195 |
| new cells (4) | n/a | 3 reps each, stdout byte-identical, all PASS | none |
| Godot seed digests | 55-entry map == live digests @ freeze | 55-entry map == committed bytes; frozen-vs-post diff = exactly `phys3d_events.gd`, `run_battery.py`, `README.md` | none outside declared arm (52/55 identical) |
| jolt_threaded child.log | map: 8 pairs + 6 notes; bytes `200299a1…` | map **identical**; bytes `2fb1c2ed…` (13 lines = backtrace path + line 1003→1390) | map none; bytes differ exactly as the brief warns |
| three.js | 31/31, seeds unchanged | 31/31, seeds unchanged | none |
| fixtures (siblings) | digests above | `run_battery.py` +8/−0; `phys3d_events.gd` +615/−7 (own arm); `README.md` +59/−1; bpy/three/prior `.gd` untouched | none outside the declared arm |
| worktree churn | clean @ freeze | `fix_dirty=0`→`1` 20:14:09Z, `2` 20:16:29Z, `3` 20:24:09Z on `3d42f77` → clean `4e65726` from 20:37:29Z | window fully bracketed by `watch.log` |

## Receipts / scratch (all inside write scope)

- `corpus/live/r86-baseline/frozen/frozen-tree.tar` — `git archive HEAD`
  @ `3d42f77`, sha256 `a826a2ba…` (426 members / 390 files, comm-clean)
- `corpus/live/r86-baseline/frozen/frozen-head.txt`,
  `fixture-digests.txt` (55), `tar-members.txt`, `git-files.txt`,
  `extract-files.txt`
- `corpus/live/r86-baseline/frozen-extract/` — replay scratch tree
- `corpus/live/r86-baseline/runs/bpy-20261014T200631933709Z` (frozen bpy
  83/83, stdout sha `6a98c570…`), `runs/20261014T200631955691Z` (frozen
  godot 191/191 + 4 probes + mutation verdict)
- `corpus/live/r86-baseline/runs-post/bpy-20261014T203732322457Z` (bpy
  83/83 @ `4e657267`, stdout sha `6a98c570…` byte-identical),
  `runs-post/20261014T203735129154Z` (godot 195/195 @ `4e657267` + 4
  probe verdicts + mutation verdict)
- `corpus/live/r86-baseline/receipts/run_*.json` — six Node suite
  receipts (frozen, 31/31) + `run_*.post.json` (post-commit @ `4e657267`,
  31/31)
- `corpus/live/r86-baseline/childlogs/` — `frozen-jolt_threaded.child.log`
  (`200299a1…`), `frozen-rep{1,2,3}.child.log` (byte-identical),
  `pathshift.child.log` (`c6189006…`), `post-jolt_threaded.child.log`
  (`2fb1c2ed…`), stdout captures
- `corpus/live/r86-baseline/prior-134-arm-rows.txt` sha256 `7b19c058…`
  (unchanged); `prior-191-godot-rows.json` sha256 `6d784726…` (new r86
  reference, built from this round's frozen receipt)
- `corpus/live/r86-baseline/tools/{postcommit_verify.py,
  postcommit_verify_godot.py,postcommit_verify_godot_prior.py,
  child_log_map.py,watch_commits.sh,wait_commit.sh}`, `watch.log`,
  `wait_commit.log`, `newcells-reps.txt`

## Limits

- Single host, single Blender/Godot/Node build; one replay per surface
  per commit, plus 3 reps on the four new cells — zero case failures on
  any completed run, no flake-retry needed or observed.
- Phase 2 coverage is exactly the one r86 work commit (`4e657267`, landed
  20:37:24Z, verified through `watch.log` + `git show`). Any later
  fixture change (r86 folds / report-last) needs its own re-check — the
  checkers are mechanical:
  `python3 tools/postcommit_verify.py <new probe.stdout.txt>
  prior-134-arm-rows.txt` and `python3
  tools/postcommit_verify_godot_prior.py <new verdicts.json>
  prior-191-godot-rows.json`; the child.log check is
  `python3 tools/child_log_map.py --compare <a> <b>`.
- The r86 arm's internal semantics (size-gated fetch cell, hang class,
  backend-write tier matrix, Dummy floor) are the author's cells; this
  seat verifies the arm as *data* — new markers matching their declared
  expected lines under the tracked gate — not the claim's interpretation.
  Jolt/Dummy measurements are one build's answer
  (4.7.2.stable.arch_linux.ed1daf0bf); other builds may gate differently.
- `corpus/live/` is gitignored; "prior receipt" comparisons are against
  on-disk runs retained under `corpus/live/r8{1,2,3,4,5}-baseline/` —
  not committed blobs.
