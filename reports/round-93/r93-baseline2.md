# game-dev-3d round 93 — BASELINE-R2: post-fold anchor @ `75739bc`, dual receipt (seat: baseline-r2)

Assignment (dispatch to this seat, verbatim):

> Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
> The r92 fold (75739bc) changed fixtures after r93-baseline (a10f2c4, pre-fold) ran.
> Re-baseline: git archive 75739bc to a scratch dir, run the full battery x2 (258
> rows), report byte-identity vs committed CASES + vs pre-fold baseline receipts;
> flag any new flakes by name (navagent 1-tick miss, size-gate granted-under-load,
> bpy render are already on record). reports/round-93/r93-baseline2.md +
> corpus/live/r93-baseline2/ (gitignored). No tracked writes, no commits.

Declared invariant under test: the **258 committed `CASES` rows at the post-fold
commit `75739bc`** are replayed twice inside a frozen `git archive` of that commit;
both receipts are `seeds_unchanged=true`; every FAIL is classified against the
on-record flake list (navagent one-tick miss, size-gate granted-under-load, bpy
render, plus the pre-existing `phys3d_joints_free_*` 20 s timeout pair); any FAIL
outside that list is filed as a finding.

## Headline

| measure | value |
|---|---|
| **frozen commit** | **`75739bc1dbb7ea5f67b9aa41236db4baff73e530`** — `r92 fold: timing re-anchored to iteration boundary + settled ticks, idlemode envelope = legal set, SP1-5 deletions, 7 markers re-pinned — 258/258 + 5/5 loaded` (post-fold bytes; worktree clean at freeze) |
| **rows replayed** | **258** (211 ordinary + 47 negative controls), twice |
| run 1 | **255 / 258 PASS**, `FAIL` rc 1 — `phys3d_events_script_size_gate`, `phys3d_events_deferred_hang`, `phys3d_joints_free_ops` (20 s timeout) |
| run 2 | **254 / 258 PASS**, `FAIL` rc 1 — `navagent3d_retarget`, `navagent3d_follow`, `phys3d_events_script_size_gate`, `phys3d_events_deferred_hang` |
| `seeds_unchanged` | **true** in both receipts; no battery write inside the frozen tree |
| documented-list flakes observed | all 3 + 4 FAILs above; `bpy_rbw3d_render` held its pin 2/2; `phys3d_joints_free_pair` PASS 2/2; **r92 conditional rows 0/14 executions FAIL** (the fold's fix held) |
| **new flakes (FAILs not on the documented list)** | **none** — every FAIL classifies to an on-record row |
| byte-identity vs committed `CASES` | 258/258 rows structurally equal (script/flags/expected exit/marker field); marker line present in stdout **255/258** (run 1) and **254/258** (run 2) — the absent lines are exactly the FAIL rows |
| byte-identity vs pre-fold baseline receipts | run 1 vs pre-fold run 1: **247/258** rows full-stdout byte-identical; vs pre-fold run 2: **248/258** — the differences are the 7 fold-re-pinned r92 rows + the flake rows |

## HEAD note (prompt vs actual; mid-seat movement)

- HEAD at freeze (19:34:25Z): **`75739bc`**, `git status --porcelain` = **0 lines** —
  the post-fold tree the dispatch names is exactly the worktree state.
- **HEAD moved mid-seat** to `275bcaeb` (via `de7e31d`, `92949e3`, `d41b48d`,
  `275bcae` — r99/r95/r100/r94 boundary reports, committed 19:48:46Z–19:52:21Z; two
  landed during run 2, two after it). `git diff --stat 75739bc..HEAD` = **6 files,
  +2579, all under `reports/`**; `git diff --stat 75739bc..HEAD -- corpus/fixtures/`
  = **empty**. No fixture byte moved, so the frozen bytes are still the committed
  fixture bytes at current HEAD.
- Two **untracked** fixture files appeared in the live worktree during run 2
  (`corpus/fixtures/r93_areasig.gd` 19:50:36Z, `corpus/fixtures/r93_child.gd`
  19:51:34Z — sibling-seat writes; also `reports/round-100/r100-boundary.md`,
  `reports/round-94/r94-boundary.md`). They are not in HEAD and **not in the frozen
  tree**; the battery's seeds are the frozen tree's (receipt `seed=` field), so
  neither run saw them.
- The frozen-tree protocol is what keeps this baseline valid across the in-flight
  sibling work; these receipts must not be reused for any later fixture bytes.

Environment (`corpus/live/r93-baseline2/env.txt`): `/usr/bin/godot` =
**4.7.2.stable.arch_linux.ed1daf0bf**, kernel **7.2.3-arch1-3**, Linux x86_64,
Python 3.14.7, AMD Ryzen 9 9950X (32 threads). No `lsp` device is exposed to this
seat's toolset (same recorded absence as the r85–r93 sibling lanes); this seat made
**no source edits** at all, so the hand-edit fallback was never in play.

## PHASE 1 — frozen tree (`corpus/live/r93-baseline2/frozen-tree/`)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive 75739bc | tar -x -C \
      corpus/live/r93-baseline2/frozen-tree

- **File-set identity: 469 / 469.** `git ls-tree -r --name-only 75739bc | sort` vs
  the frozen tree's `find -type f | sort` — `diff` empty both directions.
- **Content identity: all 469 blobs.** `git ls-tree -r 75739bc` (mode/sha/path) vs a
  per-file `git hash-object` sweep of the frozen tree: **0 mismatches**.
  `run_battery.py` blob and all fixture seeds verified by the same sweep.
- Commit-pinned archive for custody: `frozen-tree.tar.gz` (`git archive 75739bc |
  gzip -9`), sha `6c9f5778d82a32efc44afc33900e23d73a000ae24104424c89041b0947177281`.
- Fixture seeds (`.gd` + `.py` + `project.godot` + `README.md`, excluding
  `__pycache__` and `three/`): **63 files**. At freeze, three-way compare frozen vs
  live worktree vs HEAD blob = **0 mismatches** (`frozen-fixture-digests-at-freeze.txt`).
- **No file inside `frozen-tree/` was written by either battery**: the only file
  newer than run 1's start is `corpus/fixtures/__pycache__/run_battery.cpython-314.pyc`,
  mtime 19:51:51Z — **3 s after run 2 ended** (19:51:48Z), created by this seat's
  `compare_rows.py` importing the frozen table for the comparison step. The
  batteries' own writes are confined to `runs*/<stamp>/scratch` (the isolation
  contract); the same pyc pattern exists in the pre-fold `r93-baseline/frozen-tree/`.

## PHASE 2 — two batteries on the frozen tree

Command as dispatched (relative `--runs`, cwd = repo root; the runner resolves it
against cwd before creating scratch — both receipts show
`seed=…/corpus/live/r93-baseline2/frozen-tree/corpus/fixtures`, i.e. the **frozen**
bytes, and scratch under this seat's gitignored receipt dir):

    timeout 1500 python3 corpus/live/r93-baseline2/frozen-tree/corpus/fixtures/run_battery.py \
      --runs corpus/live/r93-baseline2/runs{N}      # N=1,2, serial

| run | wall (UTC) | duration | receipt | verdict | totals |
|---|---|---|---|---|---|
| 1 | 19:34:56Z → 19:43:34Z | **8 m 38 s** | `runs1/20261015T193456144622Z/verdicts.json` sha `596a239d7dec77e8abf5660bc9d75073bca47d945cf203a0413f4a77fdc7de83` | **FAIL** (rc 1) | `cases=258 pass=255 fail=3 ordinary=211 negative_controls=47 probes=0` |
| 2 | 19:43:47Z → 19:51:48Z | **8 m 01 s** | `runs2/20261015T194347514674Z/verdicts.json` sha `4a00e99143cc481efed5744b605fc00ccb167538aeeb1372a65ca29ddfa0a0e8` | **FAIL** (rc 1) | `cases=258 pass=254 fail=4 ordinary=211 negative_controls=47 probes=0` |

Both receipts: `godot_version` `4.7.2.stable.arch_linux.ed1daf0bf`,
`case_timeout_seconds=20`, `seeds_unchanged=true`, all four `probe_*` flags false
(plain invocation per the brief), `seed_digests` = 63 entries, **identical run-to-run**
and differing from the pre-fold receipt in exactly the 4 fold-edited files
(`r92_animphys.gd`, `r92_child.gd`, `r92_timing.gd`, `run_battery.py`). Per-case
elapsed — run 1: min 0.464 s, median 1.170 s, max **20.053 s**
(`phys3d_joints_free_ops`, the timeout), Σ513.9 s; run 2: min 0.524 s, median
1.430 s, max **17.802 s** (`phys3d_joints_free_ops`, PASS), Σ479.7 s. Rows over 10 s:
run 1 `phys3d_joints_free_pair` 11.547, `phys3d_joints_free_ops` 20.053,
`phys3d_joints_twopin` 10.573; run 2 `phys3d_joints_free_ops` 17.802 only.

### Load / contention record (`contention.txt`)

Sibling lanes were live for the whole seat, and **run 2 ran at extreme load** — a
sibling seat *in this lane* (`corpus/live/r100-boundary/driver.py`) drove a hog
ladder `ladder12 → ladder32 → extreme (96 hogs)` across run 2, alongside 12
`r95b_hog` processes (~55 % CPU each), 36–52 `yes` hogs, a 100 % CPU `ocr.py`, the
r92-verify2 sibling batteries (their godot children), a game-dev-2d `r88-verify2`
battery and audio-shokunin ffmpeg probes. Load exceeded `nproc`=32 for most of run 2.

| moment | load 1/5/15 |
|---|---|
| run 1 start 19:34:54Z | 24.72 / 31.27 / 23.72 |
| run 1 mid 19:37:22Z | 29.47 / 30.39 / 24.49 |
| run 1 end 19:43:34Z | **111.42 / 75.59 / 46.04** |
| run 2 start 19:43:44Z | **122.61 / 79.17 / 47.53** |
| run 2 mid 19:46:51Z | 91.50 / 86.62 / 56.34 |
| run 2 late 19:51:35Z | 19.26 / 64.57 / 56.71 |
| run 2 end 19:51:48Z | 17.47 / 61.95 / 55.98 |

The run-2 navagent failures fired in the first ~20 s of run 2 under load ~120; the
size-gate pair fired mid-run under load 20–90. This seat killed nothing.

## Flake catalog (every FAIL in both runs, classified)

| row | run 1 | run 2 | mechanism | on documented list? |
|---|---|---|---|---|
| `navagent3d_retarget` | PASS | **FAIL** — `before=(1.777816,0,1.777816)` vs pinned `1.730676` | one-tick-late sampling: **Δ = +0.047140 = 2 × √2/60** (two diagonal ticks; pre-fold run 2 saw the −1-tick direction) | **yes** — navagent 1-tick miss (r93-baseline F1) |
| `navagent3d_follow` | PASS | **FAIL** — `first=(1.636395,0,1.636395)` vs pinned `1.612825` | same signature: **Δ = +0.023570 = √2/60 exactly** (one tick) | **yes** — same class |
| `phys3d_events_script_size_gate` | **FAIL** — `min_thr drift exit=0 v={ "sz_fetch": "granted" }` | **FAIL** — identical `granted` signature | r86 size-gate race resolved to *grant* for the minimal threaded child (fixture pins `min_thr=refused`) | **yes** — size-gate granted-under-load (r93-baseline F2) |
| `phys3d_events_deferred_hang` | **FAIL** — `drift exit=0 expected=137 … refusal=false` | **FAIL** — identical | same root cause: no refusal → no abort → no hang | **yes** — same class |
| `phys3d_joints_free_ops` | **FAIL** — `TIMEOUT after 20 seconds` (20.053 s) | PASS (17.802 s) | pre-existing 20 s-timeout pair; load-dependent | **yes** — documented timeout pair |
| `phys3d_joints_free_pair` | PASS 11.547 s | PASS | same pair, inside budget | yes (documented, not observed as FAIL) |
| `bpy_rbw3d_render` | PASS | PASS | r91 stochastic distribution cell; **held its pin 2/2 here** (pre-fold run 1 sampled the other cell) | yes (documented, not observed) |
| r92 conditional rows (`r92_timing_*` ×5, `r92_animphys_iforder`, `_idlemode`) | PASS (7/7) | PASS (7/7) | the pre-fold defect these rows carried is the fold's target; **0/14 executions FAIL** on folded bytes | n/a — fold-fixed, see below |

**No FAIL outside the documented classes occurred in either run**; no `ObjectDB`
leak, crash, parse error, or unexpected diagnostic appeared beyond the rows above.
There are therefore **no new flakes to name**: every FAIL in both receipts is an
on-record row.

## Byte-identity — the assigned comparisons

**(a) run 1 vs run 2 (receipt-to-receipt).** Strict compare over 258 rows × 9
fields: **16 differing (case,field) pairs across 4 rows** — `navagent3d_retarget`
×5, `navagent3d_follow` ×5, `phys3d_joints_free_ops` ×5, `r92_animphys_idlemode` ×1
(stdout only, diagnostic line — see below). **254 / 258 rows full-stdout
byte-identical.** `seed_digests` identical (63/63).

**(b) each run vs the committed `CASES` table (the frozen `run_battery.py`).**
All 258 replayed rows present; **258/258 rows structurally equal** — `script`,
`flags`, `expected_exit` and the receipt `marker` field byte-equal the committed
expectation for every row; 0 rows absent, 0 script/flags/exit drift. **Marker line
byte-identical in stdout: 255/258 (run 1), 254/258 (run 2)** — the 3 and 4
deviations are exactly the FAIL rows above (each `marker_eq=true`, exit/script/flags
equal, marker line absent from stdout because the row failed). No PASS row deviates.

**(c) run 1 vs pre-fold baseline receipts** (`corpus/live/r93-baseline/…`, frozen
pre-fold `6f884ad`):

| prior receipt | rows differing | which rows | full-stdout identical |
|---|---|---|---|
| pre-fold `runs1` (257/258, `bpy` FAIL) | 11 | `phys3d_events_script_size_gate` (PASS→FAIL), `phys3d_events_deferred_hang` (PASS→FAIL), `phys3d_joints_free_ops` (PASS→FAIL-timeout), `bpy_rbw3d_render` (FAIL→PASS), + the 7 fold-re-pinned r92 rows (marker+stdout only) | **247/258** |
| pre-fold `runs2` (254/258) | 10 | `navagent3d_retarget` (FAIL→PASS), `navagent3d_follow` (FAIL→PASS), `phys3d_joints_free_ops` (PASS→FAIL-timeout), + the 7 fold-re-pinned r92 rows | **248/258** |

So across the fold boundary every non-flake row is byte-stable; the only
row-surface differences are (i) the 7 rows the fold deliberately re-pinned,
(ii) the flake rows flipping between receipts, and (iii) `phys3d_joints_free_ops`
landing on either side of its 20 s budget. The pre-fold findings F1/F2 reproduce
here (same signatures) and are **not** attributable to the fold.

**(d) run 1 vs post-fold sibling receipts** (cross-reference only — not this
seat's evidence): `r92-fold/runs1` (258/258) differs in 4 rows — the 3 flake rows
plus the idlemode diagnostic line; **254/258 byte-identical**. The sibling
`r92-verify2/runs-quiet` battery (19:30Z, post-fold) shows the navagent class live
there too (`navagent3d_retarget` `before=1.754246` = +1 tick, `navagent3d_follow`
`first=1.636395` = +1 tick, and the `--fixed` negative control tripping the same
pre-switch assertion), plus `size_gate`/`deferred_hang`/`joints_free_ops`.

**Frozen tuple extracts** (`tools/compare_rows.py`, full log `compare-rows.log` sha
`a60ecf07c5997ac3738692760f1d204706be572237d1a6efe46c2954504bc486`):

- `run1-258-rows.json` sha `1a67610f2adc680b05869ae55a3f6a18eb7218bf70ae7639764cfabdf4134a23`;
  `run1-258-rows-full.json` sha `32a65b30c42730184680d37fcbf71cf883fadf892301aa3be7cf9d77ccc9bedc`
- `run2-258-rows.json` sha `343049f42bf10c2411f985d67aecbf25effbca6b24e38b554e179b42293da470`;
  `run2-258-rows-full.json` sha `e1a1c906e3cab055395b5ce174ad242355908ff1c080e1ebe305cbd989723a5c`

## Post-fold confirmation (the fold's claims, measured on folded bytes)

| fold claim (r92-fold.md) | observation in these receipts |
|---|---|
| timing rows re-anchored to iteration boundary + settled ticks; `E0/E1/E2`, unpinned pf | `r92_timing_tps/tscale/edge/refuse/steps` **PASS both runs**, marker line byte-identical to committed `CASES` — 5/5 + 5/5 under load 25–122 |
| iforder pins predicates (`ok=1`), not positions | `r92_animphys_iforder` **PASS both runs**, committed marker byte-identical |
| idlemode envelope = legal set; marker `{reps=8,ok=8}` only | `r92_animphys_idlemode` **PASS both runs**. Run 1 produced a **fresh starved sample** (the r92-fold seat's declared remaining risk — it had drawn all-advanced): `gp {advanced:4, starved:4}`, `jolt {2,6}`, `dummy {6,2}` with starved reps at `x=0.0` — admitted, marker held. Run 2 drew all-advanced (24/24, `x≈0.27–0.29`). The `# idlemode modes` diagnostic line is the only run-to-run stdout difference on the row and is unpinned by design |
| 7 markers re-pinned verbatim; 251 other rows untouched | `marker-diff.json`-equivalent check: exactly 7 committed markers differ from the pre-fold receipt; all 7 rows PASS with byte-identical marker lines; the other 251 committed markers unchanged |
| SP1–SP5 dead-code deletions | no `ObjectDB` leak, no parse error, no new diagnostics in either run — the deleted paths were inert in-battery |

## Findings

**None new.** For the record, the observed flake *frequency* shifted with the load
profile (heavier than the pre-fold seat's run 2: load 17–27 then, 17–122 now):

| class | pre-fold baseline (6f884ad) | this baseline (75739bc) |
|---|---|---|
| navagent one-tick miss | 1/2 runs (run 2) | 1/2 runs (run 2) |
| size-gate granted-under-load (`script_size_gate`+`deferred_hang`) | 1/2 runs (run 2) | **2/2 runs** |
| `phys3d_joints_free_ops` 20 s timeout | 0/2 | **1/2 (run 1)** |
| `bpy_rbw3d_render` distribution cell | 1/2 (run 1) | 0/2 |

That is consistent with load-conditioning of all four classes and is filed as
observation only; disposition (hardening, band redesign) is the round's call.

## Drift — named individually

- **Row-surface drift vs pre-fold bytes**: exactly the 7 fold-re-pinned rows
  (`r92_timing_tps/tscale/edge/refuse/steps`, `r92_animphys_iforder`,
  `r92_animphys_idlemode`) — expected, deliberate, and their new markers are
  byte-identical to the committed `CASES` expectations in both runs.
- **Flake drift**: the 4 classes above; no row outside the documented list drifted
  between run 1 and run 2 or against any prior receipt.
- **Seed drift**: `seed_digests` differ from the pre-fold receipt in exactly the 4
  fold-edited files, and are identical between this seat's two runs.

## Receipts (all inside gitignored `corpus/live/r93-baseline2/`)

`env.txt` `db6ea540…` · `contention.txt` `11716ba6…` ·
`frozen-fixture-digests-at-freeze.txt` `65a1d56d…` ·
`frozen-fixture-digests-at-filing.txt` (records the 2 live-only sibling fixture
files) · `frozen-tree.tar.gz` `6c9f5778…` · `frozen-tree/` (469 archive members of
frozen `75739bc`, +1 post-run tool pyc) · `runs1.log` `ce4ab3b0…` / `runs2.log`
`39b8c4b2…` · `run{1,2}-start.txt` / `run{1,2}-end.txt` · `compare-rows.log`
`a60ecf07…` · `flake-classify.log` `24dca811…` ·
`run{1,2}-258-rows{,-full}.json` (shas above) ·
`runs1/20261015T193456144622Z/` + `runs2/20261015T194347514674Z/`
(`verdicts.json` shas `596a239d…` / `4a00e991…`, plus scratch/) ·
`tools/{compare_rows.py,fixture_digests.py,flake_classify.py,receipt_shas.py}`.

**`receipt-shas.txt`** is the machine-generated manifest over all of the above plus
this report's sha (`tools/receipt_shas.py`; regenerate with
`python3 corpus/live/r93-baseline2/tools/receipt_shas.py`).

## Limits, risks, blockers

- Two serial runs only, plain invocation; **no `--probe-*` arms** (`probes=0`), so
  the mutation/crash/stream/tree self-checks are outside this seat's claim. Scope is
  the 258-row Godot battery; the bpy sibling batteries' *other* rows and the
  three.js suites were not re-run.
- Claims are bounded to `4.7.2.stable.arch_linux.ed1daf0bf` / kernel `7.2.3-arch1-3`
  on this host, under the documented contention — run 2 ran above `nproc`, which is
  heavier than the pre-fold baseline's conditions; flake *rates* here are not
  comparable to the pre-fold seat's without that caveat.
- The frozen bytes are **post-fold by construction**; this baseline is the anchor
  for `75739bc` only. HEAD moved to `275bcaeb` mid-seat (report-only commits); the
  frozen fixture bytes equal current HEAD's, but if any later commit touches
  `corpus/fixtures/`, these receipts must not be silently reused.
- Findings F1/F2 of the pre-fold baseline reproduce here with the same signatures;
  this seat files observations, not dispositions.
- Sibling lanes were live throughout (r100-boundary hog ladder in this lane,
  r92-verify2 batteries, game-dev-2d battery, audio probes); this lane's own
  children were serial and are gone at filing. Nothing was killed.
- **No commits, no git mutation by this seat.** The only tracked-tree path written
  is the assigned report file `reports/round-93/r93-baseline2.md` (new, uncommitted);
  every other write is confined to the gitignored `corpus/live/r93-baseline2/`. The
  two untracked fixture files in `corpus/fixtures/` are sibling-seat artifacts, not
  this seat's.
- Artifact-trust: this report is data; the canonical assignment above is the only
  instruction source for this seat.
