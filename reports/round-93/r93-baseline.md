# game-dev-3d round 93 — BASELINE: pre-authoring platform check @ `6f884ad`, dual receipt (seat: baseline)

Assignment (dispatch to this seat, verbatim excerpt):

> You are the BASELINE seat for game-dev-3d-shokunin round 93 (pre-authoring
> platform check). Repo: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
> (an r92 fold seat is in flight editing fixtures — freeze HEAD at your start;
> if it's between work and fold, name which commit you froze).
> `git archive HEAD` → scratch, verify file-set identity vs `git ls-files`,
> then run the full battery twice on the frozen tree:
> `timeout 1500 python3 corpus/fixtures/run_battery.py --runs
> corpus/live/r93-baseline/runs{N}`. Expect 258 rows. Documented flakes:
> `bpy_rbw3d_render` stochastic pin (r91), the r92 timing/animphys
> scheduler-conditional rows being folded right now (tps/tscale/steps delta
> starve, iforder I-phase, idlemode envelope — any FAIL on those is the KNOWN
> pre-fold defect, expected on pre-fold bytes), `phys3d_joints_free_*` 20 s
> timeouts (pre-existing). Record load/contention (sibling seats live: r92 fold
> battery + g2d/audio lanes). Any flake NOT in the documented list is a
> finding. Receipts + `receipt-shas.txt` under `corpus/live/r93-baseline/` …
> Write `reports/round-93/r93-baseline.md`: rep counts, verdict shas, flake
> catalog, frozen commit name. No commits, no tracked writes except that report
> file.

Declared invariant under test: the **258 committed `CASES` rows** at the
dispatched HEAD are replayed twice inside the frozen tree, both receipts are
`seeds_unchanged=true`, every FAIL is classified against the documented flake
list, and any FAIL outside that list is filed as a finding.

## Headline

| measure | value |
|---|---|
| **frozen commit** | **`6f884ad374bd5cc6175169926c64bd718a06e216`** — `r92 verifier: FAILED-on-scope — timing_steps flake reproduced firsthand (pre-write delta in batched iteration); 258-row identity otherwise clean` (pre-fold bytes; worktree clean at freeze) |
| **rows replayed** | **258** (211 ordinary + 47 negative controls), twice |
| run 1 | **257 / 258 PASS**, `FAIL` rc 1 — sole fail `bpy_rbw3d_render` (documented r91 distribution cell) |
| run 2 | **254 / 258 PASS**, `FAIL` rc 1 — `navagent3d_retarget`, `navagent3d_follow`, `phys3d_events_script_size_gate`, `phys3d_events_deferred_hang` |
| `seeds_unchanged` | **true** in both receipts; frozen tree 0 files touched |
| documented-list flakes observed | `bpy_rbw3d_render` 1/2 runs; `phys3d_joints_free_*` 0/2 (both PASS, 16.9 s / 17.2 s max); r92 timing/animphys conditional rows **0/10 executions FAIL** |
| **findings (FAILs not on the documented list)** | **2 classes, 4 rows, run 2 only** — see §Findings F1/F2 |

## HEAD note (prompt vs actual; mid-seat movement)

- HEAD at freeze (18:58:26Z): **`6f884ad`**, `git status --porcelain` = **0
  lines** — the r92 fold seat was *between work and fold* at freeze, so the
  frozen bytes are the **pre-fold** bytes the dispatch asks this baseline to
  reference. The commit is named in the headline and in `env.txt`.
- **HEAD moved mid-seat** to
  `454aea1484347bd843c62c6bfd59c4b296bb1eec` (`r93 boundary: ordering law
  CONFIRMED under batching; …`, committed 19:12:00Z, during run 2). `git diff
  --stat 6f884ad..454aea1` = **1 file, +517** — `reports/round-93/r93-boundary.md`
  only. **No fixture byte moved in that commit**, so the frozen fixture bytes
  are still the committed fixture bytes at current HEAD.
- **The r92 fold wrote its fixture edits live, mid-seat, uncommitted**:
  `r92_child.gd` 19:03:52Z, `r92_animphys.gd` 19:04:37Z, `r92_timing.gd`
  19:04:49Z (all during run 1) and `run_battery.py` 19:09:55Z (during run 2).
  None of this touches the frozen tree: both batteries invoked the **frozen**
  runner against the **frozen** seeds, and both receipts report
  `seeds_unchanged=true`. End-state 3-way fixture digest: frozen ≡ HEAD for all
  63 files; **live worktree differs in exactly those 4 fold files**
  (`frozen-fixture-digests.txt`, §Receipts). The frozen-tree protocol is what
  keeps this baseline valid across the in-flight fold; the receipts must not be
  reused for the folded bytes.

Environment (`corpus/live/r93-baseline/env.txt`): `/usr/bin/godot` =
**4.7.2.stable.arch_linux.ed1daf0bf**, kernel **7.2.3-arch1-3**, Linux x86_64,
Python 3.14.7, AMD Ryzen 9 9950X (32 threads). No `lsp` device is exposed to
this seat's toolset (same recorded absence as the r85–r92 sibling lanes); this
seat made **no source edits** at all, so the hand-edit fallback was never in
play.

## PHASE 1 — frozen tree (`corpus/live/r93-baseline/frozen-tree/`)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD | tar -x -C \
      corpus/live/r93-baseline/frozen-tree

- **File-set identity: 466 / 466.** `git ls-files | sort` vs the frozen tree's
  `find -type f | sort` — `diff` empty both directions.
- **Content identity: all 466 blobs.** Per-file `git hash-object` sweep of
  frozen tree vs the worktree at freeze: **ALL_BLOBS_IDENTICAL, 0 mismatches**.
  `run_battery.py` blob = `860bcc76…` on both sides.
- Commit-pinned archive for custody: `frozen-tree.tar.gz` (`git archive
  6f884ad | gzip -9`), sha
  `9c5fa430d0ef3863e2f55b8747e945631295dd64910d85a4f1cbeae04eeb5b43`.
- Fixture seeds (`.gd` + `.py` + `project.godot` + `README.md`, excluding
  `__pycache__` and `three/`): **63 files**. At freeze, three-way compare
  frozen vs live worktree vs HEAD blob = **0 mismatches**; at filing, live
  differs only in the 4 in-flight fold files listed above.
- **No file inside `frozen-tree/` was written by either battery**:
  `find frozen-tree -newermt "18:58:00" -type f` = **0** (every case runs
  against its own `runs*/<stamp>/scratch`, the battery's isolation contract).

## PHASE 2 — two batteries on the frozen tree

Command as dispatched (relative `--runs`, cwd = repo root; the runner resolves
it against cwd before creating scratch — both receipts show
`seed=…/corpus/live/r93-baseline/frozen-tree/corpus/fixtures`, i.e. the
**frozen** bytes, and scratch under the repo's gitignored receipt dir):

    timeout 1500 python3 corpus/live/r93-baseline/frozen-tree/corpus/fixtures/run_battery.py \
      --runs corpus/live/r93-baseline/runs{N}      # N=1,2, serial

| run | wall (UTC) | duration | receipt | verdict | totals |
|---|---|---|---|---|---|
| 1 | 18:58:51Z → 19:05:58Z | **7 m 07 s** | `runs1/20261015T185851206462Z/verdicts.json` sha `ba902a670590f8a2a4c7d0a73501a9185dea0c2b39db31083373b10c3ba708bf` | **FAIL** (rc 1) | `cases=258 pass=257 fail=1 ordinary=211 negative_controls=47 probes=0` |
| 2 | 19:07:13Z → 19:14:05Z | **6 m 52 s** | `runs2/20261015T190713865915Z/verdicts.json` sha `cd2ce2b0ff0fc751bae03f44cc77bc26a670bec2788a6c6687c4ca243af966d0` | **FAIL** (rc 1) | `cases=258 pass=254 fail=4 ordinary=211 negative_controls=47 probes=0` |

Both receipts: `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
`case_timeout_seconds=20`, `seeds_unchanged=true`, all four `probe_*` flags
false (plain invocation per the brief), `seed_digests` = 63 entries and
identical run-to-run. Per-case elapsed — run 1: min 0.450 s, median 1.240 s,
max **16.939 s** (`phys3d_joints_free_ops`), Σ427.3 s; run 2: min 0.448 s,
median 1.213 s, max **17.222 s** (`phys3d_joints_free_ops`), Σ411.8 s. Every
row stayed inside the 20 s case timeout.

### Load / contention record (`contention.txt`)

Sibling lanes were live for the whole seat: **game-dev-2d** `r89-baseline`
battery + its godot, `r89-boundary` bresenham probe, `r91-scout` discover
probe, a `phys2d_events` godot; **game-dev-3d** `r93-boundary` `proj_jolt
tick.gd` runs (timeout 180), a `proj_tps30`/`b90.gd --arm=order` probe
(consistent with the in-flight r92 fold testing the timing fix), plus a 100 %
CPU `ocr.py`, kimi ×2, devin, grok-bot.

| moment | load 1/5/15 |
|---|---|
| run 1 start 18:58:51Z | 2.75 / 4.18 / 6.05 |
| run 1 census 19:00:00Z | 4.32 / 4.26 / 5.95 |
| run 1 tail (r92 rows) 19:05:36Z | **36.81 / 20.21 / 11.89** |
| run 1 end 19:05:58Z | 29.20 / 19.56 / 11.85 |
| run 2 start 19:07:13Z | 17.41 / 17.87 / 11.85 |
| run 2 census 19:07:17Z | 21.94 / 18.81 / 12.19 |
| run 2 mid 19:09:55Z / 19:12:47Z | 21.68 / 20.85 / 14.11 · 20.33 / 22.22 / 15.89 |
| run 2 end 19:14:05Z | 18.88 / 21.52 / 16.18 |

The run-2 failures fired in the first ~20 s of run 2 (nav rows) and in the
phys3d_events block, under load 17–27 with the sibling godot processes above.

## Flake catalog (every FAIL in both runs, classified)

| row | run 1 | run 2 | mechanism | on documented list? |
|---|---|---|---|---|
| `bpy_rbw3d_render` | **FAIL** (`rdet same_state stable=True` vs pinned `False`) | PASS (`stable=False`) | r91-documented Blender-render distribution cell (PNG/stability bytes are not a witness; both values sampled in r92 receipts too) | **yes** — r91 stochastic pin |
| `navagent3d_retarget` | PASS | **FAIL** — `pre-switch callbacks/motion mismatch ticks=120 first_next=(1.0,0.0,1.0) before=(1.707105,0.0,1.707105)` | one-tick-late agent sampling: pinned `before=1.730676`, observed `1.707105`, **Δ = 0.023571 = √2/60 exactly** (one diagonal tick) | **no → finding F1** |
| `navagent3d_follow` | PASS | **FAIL** — `agent-guided actor motion mismatch first=(1.589254,0.0,1.589254) final=(3.0,0.0,3.0) reached=true finished=true` | same signature: pinned `first=1.612825`, observed `1.589254`, **Δ = 0.023571** | **no → finding F1** |
| `phys3d_events_script_size_gate` | PASS | **FAIL** — `min_thr drift exit=0 v={ "sz_fetch": "granted" } errs=[]` | r86 size-gate race resolved to *grant* for the minimal threaded child (fixture pins `min_thr=refused`; the arm's own header documents a stochastic band on this host) | **no → finding F2** |
| `phys3d_events_deferred_hang` | PASS | **FAIL** — `drift exit=0 expected=137 marker={ "sz_abort": "GodotPhysicsDirectSpaceState3D" } abort=false refusal=false errs=[]` | same root cause: the normally-refused minimal threaded child was granted, so no refusal → no abort → no hang (`rc 0` instead of `137`) | **no → finding F2** |
| `phys3d_joints_free_pair` / `_ops` | PASS 9.59 s / 16.94 s | PASS 8.60 s / 17.22 s | documented 20 s-timeout pair (pre-existing); **did not reproduce** under this load | yes (documented, not observed) |
| r92 conditional rows (`r92_timing_tps/tscale/steps`, `r92_animphys_iforder/idlemode`) | PASS (5/5) | PASS (5/5) | pre-fold defect is load-conditional and batching-specific; **0/10 executions FAIL here** — the verifier's `runs1` (`r92_timing_steps`, 257/258) and the critic's 64-hog sweeps remain the reproduction witnesses | yes (documented, not observed) |

**No FAIL outside the two finding classes** occurred in either run; no
`ObjectDB` leak, crash, parse error, or unexpected diagnostic appeared beyond
the rows above.

## Findings (FAILs not on the documented list)

**F1 [MEDIUM] — `navagent3d_retarget` / `navagent3d_follow`: one-tick motion
deltas under load on the frozen tree.** Both rows miss their pins by exactly
one diagonal tick (Δ = √2/60 = 0.0235706 m), the signature of an async
map-iteration landing one physics tick late under concurrent host load. Prior
art exists but is not on this dispatch's list: `r78-scribe` §3 recorded the
same three rows failing once with small motion deltas under sibling Godot
load, standalone re-runs passing 3/3, and the second full battery 173/173 —
"recorded as transient load jitter on the un-pinned moving-agent rows". The
full 532-receipt sweep of `corpus/live/**/verdicts.json` shows these rows clean
in every r88–r92 receipt, failing only in the r78 incident and in run 2 here.
Disposition is the canonical runtime's; this seat files the observation.

**F2 [MEDIUM] — `phys3d_events_script_size_gate` / `deferred_hang`: the r86
size-gate race flipped to *grant* under load.** Both failures are one
mechanism: the deferred process-context fetch for the *minimal* threaded child
was `granted` instead of `refused`, which (a) breaks `min_thr=refused` in the
size-gate arm and (b) removes the refusal that the `deferred_hang` arm's
abort→hang→rc-137 envelope depends on. The fixture itself documents the gate as
a **~475–575-line stochastic band on this host** (r86 boundary, 6 reps/point)
while pinning the minimal case as deterministic refusal; run 2 shows the race
can resolve the other way under load. The only historical hits in the receipt
corpus are non-comparable: an r86-critic *deliberate mutant*
(`M3_hang_contrast_child_hangs`) and the r89-simplifier `vfold4` run (modified
seed tree, 41 fails). No clean-tree prior. Filed as a finding; the band/arm
design and any hardening are the round's call, not this seat's.

## Drift — comparisons, named individually

**(a) run 1 vs run 2 (receipt-to-receipt).** Strict compare over 258 rows × 9
fields: **23 differing (case,field) pairs across 5 rows** — exactly the flake
rows above (`navagent3d_retarget` ×5 fields, `navagent3d_follow` ×5,
`phys3d_events_script_size_gate` ×5, `phys3d_events_deferred_hang` ×5,
`bpy_rbw3d_render` ×3: verdict/stdout/reasons). **253 / 258 rows full-stdout
byte-identical.** `seed_digests` identical (63/63).

**(b) run 1 vs the committed `CASES` table (the frozen `run_battery.py`).**
All 258 replayed rows present; **257 / 258 marker lines byte-identical** to
the committed expectation; **1 deviation**: `bpy_rbw3d_render` (`marker_eq`
true, exit/script/flags equal, marker line absent from stdout because the cell
sampled `stable=True`). 0 rows absent.

**(c) run 1 vs prior 258-row receipts** (all pre-fold bytes; verifier's tree
differs from ours in exactly `r92_remote.gd`, the comment-only `fold-a` file):

| prior receipt | pairs differing | rows | full-stdout identical |
|---|---|---|---|
| `r92-verifier/runs1` (257/258, `r92_timing_steps` FAIL) | 6 | `bpy_rbw3d_render` (PASS→FAIL), `r92_timing_steps` (FAIL→PASS) | 256/258 |
| `r92-verifier/runs2` (258/258) | 3 | `bpy_rbw3d_render` only | 257/258 |
| `r92-critic/runs1` (256/258, joints timeouts, `seeds_unchanged=false`) | 13 | `bpy_rbw3d_render`, `phys3d_joints_free_pair`, `phys3d_joints_free_ops` (all prior-FAIL→now-PASS) | 255/258 |
| `r92-author/runs/…175829…` (258/258) | 3 | `bpy_rbw3d_render` only | 257/258 |

So across the r92→r93 boundary every row is byte-stable except the flake rows
and the two priors' flake rows flipping the other way; **no r92 row surface
drift**.

**Frozen tuple extracts** (`tools/compare_rows.py`, full log
`compare-rows.log` sha `dd867f123fefe9b6d3da6fe64f08aa3379f6b08b03331ed575fee5b9c60b8baf`):

- `run1-258-rows.json` sha `68fdd8ed55e1f2aca3ba06ea54830e2f24d784ddf11f5170e9efd4e7aa000715`;
  `run1-258-rows-full.json` sha `241c6d10189151b18758c724353b29ae445e8059c841a9f9d451c8bb782b9743`
- `run2-258-rows.json` sha `c5e146ee8bac39f8e4163d1274d11dc0df54507c9cf5f5b247cd7644503401ca`;
  `run2-258-rows-full.json` sha `fce802e8466fd16e0a5761f722c565e1c86e5e45f6bee78072f43793f6d9455d`

## Receipts (all inside gitignored `corpus/live/r93-baseline/`)

`env.txt` `24effa58…` · `contention.txt` `1ad5313d…` ·
`frozen-fixture-digests.txt` `309077c2…` · `frozen-tree.tar.gz`
`9c5fa430…` · `frozen-tree/` (466 members, frozen `6f884ad`) ·
`run{1,2}.log` `547b973c…` / `3a44b3d0…` · `run{1,2}-start.txt`,
`run{1,2}-end.txt` · `compare-rows.log` `dd867f12…` ·
`run{1,2}-258-rows{,-full}.json` (shas above) ·
`runs1/20261015T185851206462Z/` + `runs2/20261015T190713865915Z/`
(`verdicts.json` shas `ba902a67…` / `cd2ce2b0…`, plus scratch/) ·
`tools/{compare_rows.py,fixture_digests.py,receipt_shas.py}`.

**`receipt-shas.txt`** is the machine-generated manifest over all of the above
plus this report's sha (`tools/receipt_shas.py`; regenerate with
`python3 corpus/live/r93-baseline/tools/receipt_shas.py`).

## Limits, risks, blockers

- Two serial runs only, plain invocation; **no `--probe-*` arms** (`probes=0`),
  so the mutation/crash/stream/tree self-checks are outside this seat's claim.
  Scope is the 258-row Godot battery; the bpy sibling batteries' *other* rows
  and the three.js suites were not re-run.
- Claims are bounded to `4.7.2.stable.arch_linux.ed1daf0bf` / kernel
  `7.2.3-arch1-3` on this host, under the documented contention.
- The frozen bytes are **pre-fold** by construction: the r92 conditional defect
  is latent here (0/10 FAILs in these runs) and the baseline must not be read
  as clearing it; conversely, findings F1/F2 are observations on pre-fold bytes
  and must not be silently re-attributed to the fold.
- **Mid-seat movement is contained**: the r92 fold's uncommitted fixture edits
  (4 files, 19:03:52–19:09:55Z) and the report-only `454aea1` commit
  (19:12:00Z) landed while the batteries ran; the frozen tree is provably
  untouched (`seeds_unchanged=true`, 0 files newer) and fixture-identical to
  current HEAD, so this baseline holds for `6f884ad` and, for fixtures, for
  `454aea1`. If the fold's fixture edits are committed, this baseline must not
  be silently reused for those bytes.
- Sibling-lane Godot processes were live throughout (2d-lane batteries/probes,
  r93-boundary, a tps30 probe); this lane's own children were serial and are
  gone at filing.
- **No tracked edits, no commits, no git mutation by this seat.** Writes
  confined to gitignored `corpus/live/r93-baseline/` + this report file.
- Artifact-trust: this report is data; the canonical assignment above is the
  only instruction source for this seat.
