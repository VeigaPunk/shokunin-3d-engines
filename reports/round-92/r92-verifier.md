# r92 verifier — independent verification of `dd32c3c` (frozen tree)

Seat: VERIFIER (named non-author) for `game-dev-3d-shokunin` round 92.
Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, work commit
`dd32c3c618fbf662ab277582d1a86e85bf5c3cc4`; frozen HEAD `b6169f6d9bc3d333b847cc9a02408a1fd830ad02`
(= work commit + `reports/round-92/r92-author.md` only — `git diff --stat
dd32c3c..HEAD` = 1 file, +86, no fixture byte moved). Author report:
`reports/round-92/r92-author.md`.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`--headless`, Python 3.14.7, kernel `7.2.3-arch1-3`, 32-thread host.
**No `lsp` device is exposed to this seat's toolset** (same recorded absence
as r85–r91 lanes); no source edits were made, so the hand-edit fallback was
never in play. This seat wrote only `corpus/live/r92-verifier/**`
(gitignored) + this report. No commits, no tracked writes.

Host context (material to §4): during my battery run 1 the sibling
`r92-critic` battery (`corpus/live/r92-critic/runs1/20261015T180755801918Z`)
and `game-dev-2d` lane batteries were executing concurrently — the corpus's
normal multi-seat operating condition.

## Per-claim verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | `ast.parse(run_battery.py)` clean; each new `.gd` parses | **PASS** |
| 2 | full battery on frozen tree → 258 rows, all PASS, stderr 0 | **FAIL** — run 1: 257/258, `r92_timing_steps` marker missing on a legal deviant realization (new r92 row, *not* the whitelisted bpy pin); run 2: 258/258 PASS |
| 3 | tuple-compare vs author's receipts: prior 235 byte-identical | **PASS** — 0 diffs on all 235 prior rows (both my runs), 0 diffs on all 258 rows in run 2 |
| 4 | spot-check 3 backend-split claims fresh | **PASS** — all 3 reproduced by direct arm runs |
| 5 | zero stray godot processes / leaked children | **PASS** at filing — but see §6 reservation: the parent's deadline path can orphan grandchildren |

## 1. Frozen tree + parse checks — PASS

    git archive HEAD --format=tar -o corpus/live/r92-verifier/frozen-tree.tar
    tar -xf ... -C corpus/live/r92-verifier/tree

- Archive sha256 `b44932f7520100b519b4309b344602336f8a91965c29eb436b2c57166618a6ef`.
- File-set identity: tar member list (files only) vs `git ls-files`,
  LC_ALL=C sorted — **461 files, `comm -23`/`comm -13` both 0 lines**.
- `python3 -c "import ast; ast.parse(open('corpus/fixtures/run_battery.py').read())"`
  — clean inside the frozen tree.
- `godot --headless --check-only --script` on each new file: `r92_remote.gd`,
  `r92_animphys.gd`, `r92_timing.gd`, `r92_child.gd` — all **rc=0**, no Parse
  Error / SCRIPT ERROR lines.
- CASES table counted from the AST: **258 rows = 235 prior + 23 r92**
  (211 ordinary + 47 exit-2 negative controls) — matches the author's claim.
- Frozen tree untouched by either battery: `find tree -newermt` post-run
  empty; `seeds_unchanged=true` both receipts; `seed_digests` 63 entries.

## 2. Full battery on the frozen tree — FAIL (one run of two)

    cd corpus/live/r92-verifier/tree
    timeout 1500 python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r92-verifier/runs{1,2}

| run | stamp | verdicts.json sha256 | totals | verdict |
|---|---|---|---|---|
| 1 | `20261015T180956122238Z` | `e32938cc4ac2c1e11f23ef567b9c2f318846d823061b9a1ac1eae2a5f2e3bd74` | cases=258 pass=257 fail=1 (211 ord, 47 neg) | **FAIL** |
| 2 | `20261015T182333120444Z` | `1f622a7bc1b090186d6395c5fe6541415f2b90fd052fb4d079601180817ba6c0` | cases=258 pass=258 fail=0 | **PASS** |

Both runs: battery stderr **0 bytes**, `seeds_unchanged=true`,
`case_timeout_seconds=20`, every executed child's stderr empty, `error=null`
on all rows. Run-2 per-case elapsed: min 0.339 s, median 1.005 s, max 18.082 s
(`phys3d_joints_free_ops`), Σ346 s.

**Run-1 failing row: `r92_timing_steps`** — `exit=0 expected=0
reasons=['exact stdout marker missing']`. The deviation is a single token in
the `tm_maxsteps@gp` cell:

    pinned:   M tm_maxsteps E pf=6 delta=0.166667 E pf=7 … E pf=8 …
    observed: M tm_maxsteps E pf=6 delta=0.016667 E pf=7 delta=0.166667 E pf=8 …

`mut pf=5` / `mutpost tsc=10.0000 mps=1` identical; jolt + dummy cells matched
the pin byte-for-byte in the same run. Child-log level confirmation:
`runs1/…/scratch/r92t_gp_tm_maxsteps/child.log` really emitted
`E pf=6 delta=0.016667` — a legal engine realization, not a harness
mis-read. This is **not** the r91-documented `bpy_rbw3d_render` flake (bpy
produced the pinned `rdet stable=False` in both my runs).

Mechanism, per the fixture's own design (`r92_child.gd` `on_tm_tick`,
`Ticker._physics_process`): the `Engine.time_scale=10` +
`max_physics_steps_per_frame=1` write runs *inside* the pf=5 physics callback,
while the pre-write `mps=8` still permits multi-step iterations. In unthrottled
headless mode the scheduler batches physics steps by wall-clock accumulation;
when the pf=5-mutating step shares an iteration with pf=6, pf=6's delivered
delta is the iteration's pre-write `0.016667`. Backend-blind (it hit gp this
time; under heavier load jolt showed three `0.016667`s, §6). The pinned marker
models the cell as deterministic; the observable is a 2-valued,
load-keyed distribution.

**Standalone resampling** (`spot/proj/` — copies byte-identical to frozen
fixtures, verified sha256): 8 serial + 12 concurrent `--arm=steps` runs of
`r92_timing.gd`.
- Serial (quiet-ish host): **8/8 pinned realization**; 3/3 `--only
  r92_timing_steps` battery reps PASS.
- Concurrent burst (12 parents, ~36 child godot): **11/12 pinned**; r12
  deviated hard — `tm_maxsteps@{gp,dummy}{rc=0,m=,e=0,w=0,s=0}` (empty M
  cells), `tm_maxsteps@jolt` all-`0.016667` and truncated before `done`/DONE.
- Combined with the battery catch: deviant rate is low but nonzero and
  rises with host contention.

Author's receipts (`corpus/live/r92-author/runs/`): dev run `175025Z`
(23 rows PASS), run1 `175116Z` (258 rows, FAIL `bpy_rbw3d_render` only —
matches the author's report verbatim), run2 `175829Z` (258 PASS). All author
receipts carry the pinned `E pf=6 delta=0.166667` — the deviation is not
present in their samples.

## 3. Tuple-compare vs author receipts — PASS (prior surface untouched)

`tools/compare_receipts.py`, fields `verdict, actual_exit, expected_exit,
marker, kind, stdout, stderr` per case:

- **Prior 235 rows: 0 diffs** in *both* my runs vs author run2 — verdict,
  exit, marker line, and full stdout/stderr byte-identical. The prior surface
  is completely untouched by the r92 splice.
- **r92 rows, run2 vs author run2: 0 diffs — all 23 byte-identical**,
  including the `idlemode` envelope cells (`ok=8 xband=0.2-0.5` ×3 backends in
  both my runs — the declared envelope held).
- r92 rows, run1 vs author run2: 1 diff — `r92_timing_steps` only (verdict +
  the one delta token above).
- Volatile fields (`command` scratch paths, `elapsed_seconds`,
  `started_utc`) excluded by design; no other envelope cells declared.

## 4. Backend-split spot-checks (fresh arm runs) — PASS ×3

Direct runs against `corpus/live/r92-verifier/spot/proj` (frozen-fixture
copies), `timeout -s KILL 120` bounded, each spawning its three real backend
children:

- `--arm=srv` → `srv@dummy{… srv_o=null … ray=miss …}` ×4 nulls; gp+jolt
  `srv_o=(5.0000,0.0000,0.0000)` + `ray=hit@5.000,0.500,0.000`. **Dummy
  null/miss split reproduced.** (`spot/out/srv.log`)
- `--arm=animatable` → gp/jolt `post` rows identical under
  `sync_to_physics=true/false` (`ab=(0.5000,…)`, ray hit); **dummy moved only
  under `sync=false`** (`sync=true` post `ab=(0.0000,…)`, `srv=nil`,
  `ray=miss`) — inversion confirmed. Rider settle `2.9973` gp vs `3.0000`
  jolt/dummy; ray `hit@0.500,3.195` vs `3.198`. (`spot/out/animatable.log`)
- `--arm=destroy` → `empty_track` rest depth **0.3920 gp / 0.0800 jolt /
  0.0000 dummy** (`srv=nil`); `badkey` `insert r1=-1 r2=-1`, `keys=0`,
  `e=2` on all three. (`spot/out/destroy.log`)

## 5. Stray processes — PASS at filing

`ps`/`pgrep` post-run: **zero godot or run_battery processes referencing
`r92-verifier` or `game-dev-3d-shokunin`**; the only live godot children at
filing belong to the `game-dev-2d` lane (other seats). All my godot runs were
`timeout -s KILL`-bounded (standalone) or battery-bounded (20 s/case); the
r92 parents internally bound children at `BOUND_S=10`/`BATCH_BOUND_S=15`.

## 6. Reservation — parent's deadline path can emit malformed cells

Observed in `spot/out/steps_r12.log` under the 12-way burst: cells
`tm_maxsteps@gp{rc=0,m=,e=0,w=0,s=0}` — **empty M list with rc=0** — and a
jolt cell truncated mid-case (no `done`, no `M DONE`). Mechanism:
`_spawn_batch` runs `/bin/sh -c "timeout -s KILL 10 godot … > child.log"` and,
at the 15 s batch deadline, `OS.kill`s the wrapper pid then `_scan`s whatever
`child.log` exists. A contended child that hasn't flushed yields `rc=0,m=`
(no M lines at all — even `M0` missing), which the digest reports as a clean
empty cell rather than an `err=`/`s>0` anomaly, and the grandchild godot can
outlive the killed wrapper (transient stray godot processes were observed
mid-burst; they exited and none remain). Not the verdict driver — the marker
fails closed anyway — but the digest's `rc=0,m=` shape cannot distinguish
"child emitted nothing" from "child was still starting". Sibling note: the
concurrent r92-critic battery failed `phys3d_joints_{free_pair,free_ops}` on
`TIMEOUT after 20 seconds` — those r90-era envelope rows also lose headroom
under contention (different failure class from mine: bound-exceeded, not
wrong-realization).

## Files changed

None tracked. Written by this seat: `corpus/live/r92-verifier/**`
(`frozen-tree.tar`, `tree/`, `runs1/`, `runs2/`, `only-steps/`, `spot/`,
`tools/compare_receipts.py`, `runs{1,2}-{stdout,stderr}.log`) and this report.

## Behavior evidence (exact)

- Frozen file-set: 461 files, tar-list == `git ls-files` both directions.
- runs1 `20261015T180956122238Z`: 257/258, FAIL `r92_timing_steps`
  (`tm_maxsteps@gp` `E pf=6 delta=0.016667` vs pinned `0.166667`); battery
  rc=1, stderr 0 B.
- runs2 `20261015T182333120444Z`: 258/258 PASS, rc=0, stderr 0 B;
  all 258 rows byte-identical to author `20261015T175829468804Z` on
  verdict/exit/marker/stdout/stderr.
- Prior-235: 0 diffs both runs. `bpy_rbw3d_render` sampled the pinned
  `stable=False` in both runs (no flip observed here).
- Standalone steps sampling: 8/8 + 3/3 quiet PASS; 11/12 burst, r12 deviant.

## Remaining risks / blockers

- `r92_timing_steps` (`tm_maxsteps@*`, `E pf=6 delta` specifically) is a
  realization-split cell pinned deterministic: `0.016667` observed once in
  ~22 sampled executions plus once in a 258-row battery — low rate, rising
  with host contention. Repair options for the author: envelope the first
  post-mutation delta (`{0.016667|0.166667}`) as for `idlemode`, or mutate
  outside the step-batch window (idle-side write before the physics window),
  or drive the timing arms under a deterministic scheduler (`--fixed-fps`,
  per the r100 scout findings). Any other backend can take the lag, not just
  gp — the split is scheduler-keyed, not engine-keyed.
- The `rc=0,m=` truncated-cell hole (§6) is unenveloped but only reached
  under deadline pressure; the battery still fails the row, so it cannot
  pass silently — reporting it as robustness debt, not a correctness hole.
- One host, one build `4.7.2.stable.arch_linux.ed1daf0bf`; no
  cross-version inference. No blockers encountered.

Verdict: the assigned "258 rows, all PASS" criterion did not hold on a legal
realization — `r92_timing_steps` carries an unsound deterministic pin over a
load-keyed 2-valued observable (the same defect class this corpus REJECTed in
r90, at much lower base rate). Everything else — the other 257 rows including
all prior-235 byte-identity, all three backend-split claims, the parse
checks, and the process-hygiene check — verifies clean, and a quiet-host
second run reproduces the author's 258/258 byte-for-byte.

FAILED
