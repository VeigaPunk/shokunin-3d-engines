# game-dev-3d round 88 — baseline: freeze @ db64943 + post-fold reference receipt + prior-201 drift audit (seat: baseline)

Assignment (`.ufo/waves/shokunin-train-20261101-w20/tasks/g3d-r88-baseline.md`,
verbatim):

> Repo: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin at HEAD (post-r87
> fold). Freeze the full verdicts tuple for the 201 committed rows; run the
> battery once for a post-fold reference receipt; verify prior rows stable vs
> corpus/live/r87-baseline/runs-post/20261014T215119929090Z/verdicts.json
> (compare semantic fields only — scratch paths/elapsed differ by design).
> Also run bpy + three sibling batteries once for continuity. Report ->
> reports/round-88/r88-baseline.md. Read-only on tracked files; scratch in
> corpus/live/r88-baseline/.

Declared invariant under test: the 201 committed rows at HEAD (post-r87 fold
`a11e1ad` + report-last `db64943`) are stable against the r87 post-commit
receipt, with exactly the fold's declared marker re-pins allowed
(simplifier P1 `two_fetch`, P2 `tally` — `r87-adjudicator.md` §Fold
corrections); sibling surfaces (bpy 83, three.js 31) green; fixture bytes
pinned.

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (build 2026-09-01),
`/usr/bin/godot` = 4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7,
Node v24.21.0, three.js 0.186.1 (lockfile-pinned), 32 cores. Single host,
no sibling battery ran concurrently this round (this seat ran solo).
No `lsp` device on this host (same recorded absence as the r85–r87 sibling
lanes); no symbol-aware operation was needed — the behavioral checks here
are the batteries themselves and their row comparators.

## PHASE 1 — Frozen tree (freeze @ `db649433`)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r88-baseline/frozen/frozen-tree.tar

- Frozen commit: `db6494332231fccf90a8d3e18e9fa5d2e0df9e47`
  (`r87 report-last: adjudicator ADMIT-corr + ledger + wave-B reports`) —
  the post-r87-fold HEAD. HEAD was **unchanged at every checkpoint** of this
  seat (pre-freeze, post-run; `git rev-parse HEAD` re-checked at filing).
- Archive sha256
  `05bda5965bff9ca8a9fe5e45bf079c7059c614fe29fb7485d472512039c40082`,
  **445 tar members = 408 file members + 37 dir entries**; file-member list vs
  `git ls-files` (LC_ALL=C sorted): `comm -23` **0 lines**, `comm -13`
  **0 lines** (both directions clean).
- Extract dir `frozen-extract/` = exactly the 408 tar file members
  (`find` vs member list, 0 diff; + gitignored
  `corpus/fixtures/three/node_modules` copied in for the Node suites —
  three@0.186.1 verified by `npm ls` on both sides).
- Frozen fixture digests `frozen/fixture-digests.txt` (**55 files**:
  49 `.gd` + 4 `.py` + `project.godot` + `README.md`, the
  `run_battery.py seed_digests()` selection) — **three-way compare
  frozen-extract vs live worktree vs `HEAD` blob: 55/55 OK, 0 mismatches**
  (`tools/fixture_digests.py`). The battery therefore measured the committed
  bytes, and the live worktree is byte-equal to them.
- `git status --porcelain` at freeze (23:49:46Z): **only `?? reports/round-88/`**
  (this lane's untracked report dir, pre-existing) — 0 tracked dirty files,
  before and after every run.
- All writes confined to gitignored `corpus/live/r88-baseline/` + this
  report. No git mutation performed by this seat.

## PHASE 2 — Batteries, one run each on the frozen bytes

### Godot battery — 201/201 + 4 probes — REFERENCE receipt

    cd frozen-extract && python3 corpus/fixtures/run_battery.py \
      --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r88-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution \
      --probe-tree-timeout

- Receipt `runs/20261014T235527966109Z/verdicts.json` (started 23:55:27Z,
  verdict written 23:59:50Z — 4 m 23 s wall), sha256
  `24eafef746c07923db058bee13c5235dbcaaf200b39a0847f9367634ea38099e`:
  `verdict` **PASS**; `totals: cases=201 pass=201 fail=0 ordinary=155
  negative_controls=46`; `seeds_unchanged=true`; all four probes armed and ok
  (`crash_probe_ok`/`stream_probe_ok`/`tree_probe_ok` true, mutation
  `detected=true`); `case_timeout_seconds=20`; `seed` =
  `…/corpus/live/r88-baseline/frozen-extract/corpus/fixtures` — ran against
  the frozen bytes; `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`.
- All 201 rows: `actual_exit=0`, `stderr=[]`, `error=null`; last row is the
  crash-class `phys3d_events_freed_space` (`PASS … gp=crash jolt=crash
  dummy=empty child_exit=0`).
- `seed_digests` (55 entries) cross-verified against **`HEAD` blobs**:
  **0 mismatches** — the reference receipt is the committed table's bytes.
- Tree-timeout probe receipt `…/tree-timeout-verdicts.json` sha
  `9963e947bb152f86193530117a3c49531780eff15a908f0847207cdff5f3158d`:
  `witness_verified=true`, `witness_gone=true`,
  `witness_cleanup="SIGTERM to verified detached witness"`,
  `cleanup_exit=-9`, `marker_observed=true` — PASS.
- **This receipt is the r88 post-fold reference.** The 201-row tuples were
  frozen from it (see PHASE 3): `prior-201-godot-rows.json` (4-tuple
  case/verdict/actual_exit/marker) sha
  `f10ea3a20963e459121592aeca52c8c951ff58b5369e38e38aceabe9555c9a67` and
  `prior-201-godot-rows-full.json` (6-tuple incl. stdout/stderr line lists)
  sha `706188e64ff98da54b318a24418127ad17a1fe4bc0581aa271fde3ec107fb379`.

#### Run #1 (diagnostic, superseded): tree-probe FAIL from a relative `--runs` path — seat invocation artifact, not byte drift

The first battery invocation used a **relative** `--runs ../runs`. Receipt
`runs/20261014T235009560889Z/verdicts.json` sha
`cfb293175e7da056b419d7e7f406e2cdfbb6262de8c4084fea9446fc954dfec9`:
cases **201/201 PASS**, mutation detected, crash/stream probes PASS,
`seeds_unchanged=true` — but `tree_probe_ok=false`, so that receipt's
`verdict` is FAIL. Root cause (recorded in `RUN1-DIAGNOSIS.md`):

- Receipt field `scratch` = `../runs/20261014T235009560889Z/scratch` (relative).
- The tree probe verifies the detached witness by requiring the scratch path
  string in the witness's `/proc` cmdline (`run_battery.py:674`, predicate at
  `720-721`, helper at `692-693`). Godot **globalizes** the witness's argv, so
  the real cmdline holds the absolute path
  `…/corpus/live/r88-baseline/runs/…/scratch/timeout-descendant.json` and the
  relative `str(witness_path)` never matches → `witness_verified=false`.
- Cascade: the unverified witness is not SIGTERM'd; it inherits Godot's
  stdout/stderr pipes and sleeps 30 s, so `communicate(timeout=3)` never sees
  EOF → `"Godot cleanup exceeded 3 seconds"` → probe FAIL. The witness
  (pid 1130413) was still live 18 s later (verified via `/proc`); this seat
  SIGTERM'd it and confirmed no `timeout_descendant.py`/`godot` processes
  remain (`pgrep` clean at 00:01Z).
- r87's invocations passed because they used **absolute** `--runs` paths
  (`r87-baseline/tools/phase2_run.sh`: `--runs "$LIVE/runs-post"`).

The corrected re-run above (absolute `--runs`, r87's own invocation shape) is
the reference; run #1 is retained as diagnostic evidence only. **Named
harness observation for the lane:** a relative `--runs` path makes the
tree-timeout probe fail spuriously *and* leaks the witness until killed —
later r88 seats must invoke `run_battery.py` with an absolute `--runs` path
or read a spurious tree-probe FAIL as drift.

### bpy battery — 83/83, stdout byte-identical (13th identical receipt)

    cd frozen-extract && python3 corpus/fixtures/bpy_battery.py \
      --blender /usr/bin/blender --runs …/corpus/live/r88-baseline/runs

- Receipt `runs/bpy-20261014T234953346775Z/verdicts.json` (started 23:49:53Z,
  verdict written 23:50:01Z — 8 s), sha
  `b32e04a412712323a49a6b8304c9b041ae741a9ab92498fa7d833171c2d09cc9`:
  `verdict` **PASS**; `totals: cases=83 pass=83 fail=0 (signal_fail=0
  quirk_drift=0)`; `done_marker=true`, `fatal_arms=[]`, `n_arm_lines=131`;
  `probe.stderr.txt` 0 bytes (sha `e3b0c442…`).
- `probe.stdout.txt` sha256
  `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3` —
  **byte-identical to all twelve prior receipts** (r82 ×2, r83–r87 frozen +
  post) — 13 identical receipts total.
- Prior-134 check (`tools/postcommit_verify.py` vs
  `prior-134-arm-rows.txt`, sha256 `7b19c058…` **unchanged** from
  r83–r87): **ordered-subsequence PASS 134/134, all at identical ARM
  positions, 0 inserted rows**; 134 physical `^ARM` lines / 131 unique keys.

### Node three.js suites — 31/31

Six receipts `receipts/frozen-run_*.json` (all on the frozen extract with the
copied `node_modules`, three@0.186.1 verified both sides):

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seedsUnchanged=true, node=v24.21.0, three=0.186.1 — 31/31

Receipt shas: `frozen-run_cases.json` `94d3324e…`, `frozen-run_layer_cases.json`
`7175c06d…`, `frozen-run_order_cases.json` `1251923c…`,
`frozen-run_camera_cases.json` `9faabc1f…`, `frozen-run_ortho_cases.json`
`f68c4239…`, `frozen-run_ray_cases.json` `f508046f…`.

## PHASE 3 — prior-201 drift audit vs the r87 post receipt

Comparison target (the brief's named receipt):
`corpus/live/r87-baseline/runs-post/20261014T215119929090Z/verdicts.json`,
sha256 `81f480678b33a5d9413e22297167b78eb7a77bf020db68a6bb43c703689d966c`
(201 rows at `c57fa40`, live tree).

Tool `tools/r88_compare_prior.py` compares **all semantic row fields** (every
row key except `command`, which embeds the timestamped scratch path, and
`elapsed_seconds`) index-by-index, plus the strict tuple
`[case, verdict, actual_exit, marker, stdout, stderr]`; log
`frozen-compare-prior.log`. Result:

- **199/201 prior rows strictly identical** (case, verdict, actual_exit,
  marker, stdout, stderr) at identical positions; **0 inserted rows**;
  0 case-name collisions; 201=201.
- **Exactly 2 drifted rows — both declared marker-line re-pins** (stdout
  differs only on the marker line, stderr identical, every other semantic
  field identical):
  - idx 196 `phys3d_events_body_handle`: marker loses `two_fetch=true`
    (simplifier P1) — the only removed token;
  - idx 199 `phys3d_events_write_loss`: marker loses `tally=8`
    (simplifier P2) — the only removed token.
- **0 drift beyond the declared re-pins.** The fold's own diff
  (`git diff c57fa40 db64943 -- corpus/fixtures/run_battery.py`) is exactly
  those two CASES marker edits (+2/−2); `git show a11e1ad --numstat` =
  `phys3d_events.gd` 171/138, `run_battery.py` 2/2, `README.md` 15/6.
- **CASES cross-check: 0 mismatches** — every new row's (case, marker,
  expected_exit, actual_exit) equals the committed `CASES` table at HEAD
  (imported from the frozen `run_battery.py`, 201 entries). The receipt is
  the committed table's own expectation, not a re-stated claim.

Independent cross-views:

- 4-tuple ordered-subsequence view (`tools/postcommit_verify_godot_prior.py`
  vs `r87-post-201-rows.json`, sha `3710fdfd…`): **195/201 at identical
  positions**, naming the same 2 re-pins as DRIFT and 2 inserted/new rows.
  Caveat: that r87-era tool's greedy scan cannot resync after a marker
  change, so it also prints prior rows 197/198/200/201 as "MISSING" — those
  four are **byte-identical** in the strict tool; the strict view is
  authoritative. (`frozen-subsequence-view.log`.)
- Child-log map compare (`tools/child_log_map.py --compare`, the r86/r87
  mode) over all **29 shared generated-project child logs** (frozen run vs
  r87 post run): **25/29 map PASS (identical CHILD_RESULT pairs + notes)**;
  the 4 differing logs are exactly the fold's declared edits —
  `bhplainproj`/`bhjoltproj`/`bhdummyproj` add `bh_*_ss_fired` (F5 pin:
  `>0`/`>0`/`0`) and drop `bh_*_two_fetch` (P1; the `CHILD_NOTE` loses the
  same token), `wlproj` drops `wl_plain_tally` (P2, note identical).
  **No undeclared child-log drift.** (`childlogs/map-compare.log`.)
- Focused determinism rep of the three fold-touched rows
  (`--only phys3d_events_body_handle,phys3d_events_write_loss,phys3d_events_freed_space`,
  receipt `runs-only/20261015T000029269758Z/verdicts.json` sha
  `d8d109a7…`, 3/3 PASS + 3 probes ok): each row **identical to the
  reference receipt over `[verdict, actual_exit, marker, stdout, stderr,
  reasons, error]`**.

## Byte-stability summary (cell-by-cell)

| surface | r87 runs-post @ `c57fa40` | r88 frozen reference @ `db64943` | drift |
|---|---|---|---|
| Godot rows | 201/201 PASS | 201/201 PASS + 4 probes | none; prior 199/201 byte-identical, 2 declared re-pins |
| `body_handle` marker | `…twin=true two_fetch=true dummy_cb=never…` | `…twin=true dummy_cb=never…` | declared (P1 `two_fetch`) |
| `write_loss` marker | `…same_turn=8 tally=8 race=bounded…` | `…same_turn=8 race=bounded…` | declared (P2 `tally`) |
| other 199 rows | — | byte-identical tuple (incl. stdout/stderr) at identical positions | none |
| Godot seed digests | 55 live files | 55/55 == frozen extract == live == HEAD blob | none |
| child logs (29) | 29 captured | 25 map-identical; 4 differ by declared P1/P2/F5 only | declared only |
| bpy | 83/83, stdout `6a98c570…` | 83/83, stdout `6a98c570…` (13th identical) | none |
| prior 134 ARM rows | 134/134 identical positions | 134/134 identical positions, 0 inserted | none |
| three.js | 31/31, seeds unchanged | 31/31, seeds unchanged | none |
| fixtures | — | 55/55 frozen == live == HEAD; tracked tree 0 dirty | none |

## Receipts / scratch (all inside write scope)

- `frozen/frozen-tree.tar` sha `05bda596…` (445 members / 408 files,
  comm-clean both directions); `frozen/frozen-head.txt`,
  `frozen/fixture-digests.txt` (55), `frozen/tar-members.txt`,
  `frozen/tar-file-members{,-sorted}.txt`, `frozen/git-files{,-sorted}.txt`,
  `frozen/extract-files.txt`, `frozen/git-status-at-freeze.txt`,
  `frozen/start.txt` (23:49:34Z), `frozen/frozen-at.txt` (23:49:46Z)
- `frozen-extract/` — replay scratch tree (408 tracked files + copied
  `three/node_modules`)
- Godot: `runs/20261014T235527966109Z` (**reference**, sha `24eafef7…`,
  tree-probe sha `9963e947…`), `runs/20261014T235009560889Z` (run #1
  diagnostic, sha `cfb29317…`, tree-probe sha `6a85172c…`),
  `runs-only/20261015T000029269758Z` (focused rep, sha `d8d109a7…`)
- bpy: `runs/bpy-20261014T234953346775Z` (sha `b32e04a4…`, stdout sha
  `6a98c570…`, stderr empty)
- three.js: `receipts/frozen-run_{cases,layer_cases,order_cases,camera_cases,ortho_cases,ray_cases}.json`
  (shas above) + `.log`
- References: `prior-201-godot-rows.json` sha `f10ea3a2…`,
  `prior-201-godot-rows-full.json` sha `706188e6…`,
  `r87-post-201-rows.json` sha `3710fdfd…`, `prior-134-arm-rows.txt` sha
  `7b19c058…`, `receipt-shas.txt`
- Comparators/logs: `tools/{r88_compare_prior.py, fixture_digests.py,
  build_prior_rows.py, build_prior_rows_full.py, postcommit_verify.py,
  postcommit_verify_godot_prior.py, verify_prior_rows_full.py,
  child_log_map.py}`, `frozen-compare-prior.log`,
  `frozen-subsequence-view.log`, `childlogs/` (29 frozen logs + shas +
  `map-compare.log`), `frozen-bpy.log`, `frozen-godot.log` (run #1),
  `frozen-godot-ref.log` (reference), `frozen-godot-only.log`,
  `frozen-bpy.log`, `RUN1-DIAGNOSIS.md`

## Limits, risks, blockers

- **One frozen replay per surface** (per the brief's "once"), plus one
  focused 3-row rep. No case failure on any completed run; no flake observed
  in the 201 rows. The reference receipt is a single run — the r87 verifier
  already established row determinism for the pre-fold tree, and the
  fold-touched rows re-ran identical here.
- **Run #1's tree-probe FAIL is an invocation artifact** (relative `--runs`),
  fully root-caused and superseded; both receipts retained. Residual risk:
  the harness's witness-identity check is path-form-sensitive and leaks the
  witness on a failed verification. Fixing `run_battery.py` is outside this
  read-only seat's scope — flagged for the lane.
- The 4-tuple subsequence cross-view cannot resync after a marker change;
  its "MISSING" tail is a tool artifact (strict tool shows those rows
  byte-identical). Methodology note for later seats.
- All claims bounded to `4.7.2.stable.arch_linux.ed1daf0bf` / Blender 5.2.1 /
  node v24.21.0 / three 0.186.1 on this host; no cross-version inference.
- Scratch hygiene: the run-#1 witness (pid 1130413) was terminated by this
  seat; `pgrep` shows no leftover `godot`/`timeout_descendant.py` processes
  at filing. `git status`: only untracked `reports/round-88/`; 0 tracked
  dirty; HEAD `db64943` unchanged — no commits, pushes, or tracked writes by
  this seat.
- No `labrat` probe dispatched: the assignment is a direct freeze + drift
  audit with no open falsifiable hypothesis beyond the measurements above
  (frozen probeParent allowance unused, not needed).
- Artifact-trust: this report is data; the canonical assignment above is the
  only instruction source for this seat.
