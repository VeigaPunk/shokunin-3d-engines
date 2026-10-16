# r99 scribe — custody + consistency audit of the committed r99 animtree landing (`f1ff626`)

Seat: GAME-DEV-3D r99 SCRIBE. Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Audit window: landing HEAD **`f1ff626f4d83e67ab841485a56e972e79869535d`**
(`2026-10-16 04:56:04 -0300` = 07:56:04Z, *"r99 author: 9 animtree rows (342
total) — 183 cells, beq=1 122/122 backends, clsloop td-encoded heap abort;
342/342 x2"*). `git status --porcelain=v1` at audit start = **2 lines**
(`?? reports/round-94/r94-reviewer.md`, `?? reports/round-95/r95-reviewer.md` —
r94/r95 leftovers). Read-only audit plus **one fresh full battery run of the
committed bytes under ambient load** (§4), **one r99-only run** and **six
life-row repeats** (§6), **one independent boundary-provenance crosscheck of
every child my runs spawned** (§7.1), **one independent re-derivation of all
183 pins from all 1281 saved children of the author's seven passes** (§2.7),
**one td/abort replay** (§7.2), **one in-process diagnostic series attributing
the clsloop census flip** (§5.3), and **one dispatched read-only `labrat`
probe** (§8). No fixture, runner, contract, axis, or route touched; **no
tracked write, no commit**. Receipts: `corpus/live/r99-scribe/` (gitignored,
`corpus/.gitignore:1: live/`). No `lsp` device is exposed to this seat and this
seat made no source edit, so the hand-edit fallback was never in play.

**HEAD moved mid-audit (disclosed, inert).** Two sibling wave-B seats committed
during the audit — `b3d366e` (*"r99 critic: PASS — 549 cell-instances re-derived
0 diffs, 8/10 mutations detected, beq non-vacuous"*) and `34d3e69` (*"r99
simplifier: PASS — SP1-4 parent folds -9 proven; SP-5 refuted (frozen-probe
line-coupling, 6 cells)"*). `git diff --stat f1ff626 HEAD` = **2 files, +1054**
(`reports/round-99/r99-critic.md`, `reports/round-99/r99-simplifier.md`);
`git diff --numstat f1ff626 HEAD -- corpus/fixtures/` is **empty** and
`r99_animtree.gd` still hashes `75d63cbed8ac76efeafc460deb8c081f62f300f03d1634d9dbcac111877c8bc2`.
The audited artifact set is therefore still exactly the `f1ff626` tree.

Commit contents (`git show f1ff626 --stat`): **9 files, 2757 insertions, 0
deletions** — `r99_animtree.gd` +779, six `r99_probe_r99b_*.gd` +1825
(308+233+248+212+413+411), `run_battery.py` +29, `reports/round-99/r99-author.md`
+124.

---

## 1. Custody — manifests, tracked bytes, seed maps, receipts

### 1.1 Manifests (replayed)

| manifest | entries | OK | FAILED | census |
|---|---|---|---|---|
| `corpus/live/r99-scout/manifest.sha256` | 2162 | **2162** | 0 | `runs/` 2144 files = **536 children**, probes 6, driver/audit/logs 12 |
| `corpus/live/r99-boundary/manifest.sha256` | 3767 | **3767** | 0 | `runs/` 3756 files = **939 children**, probes 6, driver/audit/logs 5 |

Both replays `rc=0` (`custody-scout-sha-check.log`, `custody-boundary-sha-check.log`).
Exit-sidecar censuses re-derived: scout **536/536 `rc=0`**, boundary **939/939
`rc=0`** — both reports' headline rc claims hold.

### 1.2 Tracked bytes

All seven committed fixture files: worktree sha256 **==** committed-blob sha256
(`git show f1ff626:<path> | sha256sum`), 7/7 MATCH. Parent:

```
75d63cbed8ac76efeafc460deb8c081f62f300f03d1634d9dbcac111877c8bc2  r99_animtree.gd
```

All six probe copies are **byte-identical (`cmp`)** to their boundary sources and
their sha256 match the author report's table exactly:

| probe | sha256 | == boundary source |
|---|---|---|
| r99b_core | `6683aba10439885d…` | yes |
| r99b_life | `2eb2e2428a317934…` | yes |
| r99b_modes | `f6d23bb1f69e2c4f…` | yes |
| r99b_silent | `de0fd54e2ed5dbed…` | yes |
| r99b_sm | `a8d41a1b1fd5c624…` | yes |
| r99b_untracked | `5981275d176f1fc0…` | yes |

`run_battery.py` = `ff010bd35004a7377a9135c43a1d21653c2d68cab2e601af3c5df28676fa5335`
in both the worktree and the committed blob, and in every cited run's seed map.

### 1.3 Seed custody

Each of the author's four cited runs carries a **123-entry** `seed_digests` map
(116 r98-era + the 7 new `r99_*` files). This seat re-hashed all 123 files on
disk per run — **0 bad, 0 missing**, in all four; `seeds_unchanged=true` in all
four (and in the two flake-attempt runs too).

### 1.4 Receipts

`corpus/live/r99-author/` has **no `RECEIPTS.md`** (r96/r97/r98 shipped one; r99
does not). Its custody rests on: `ftest/` (the author's arm-level scratch: 8 seed
files + **183 child dirs**, pids 818275/833776/… = nine arm-level parent runs),
`passlines/` (9 one-line PASS captures) and `r99_cases.txt` (the CASES block).
The six cited battery runs all exist and re-read clean (§2.6).

---

## 2. Claim arithmetic — every author number re-measured

| claim (author report / commit) | measured | verdict |
|---|---|---|
| "9 battery rows … 342 total" | AST census of `CASES`: `ba5ab41` = **333 (274 ordinary + 59 negative)**, `f1ff626` = **342 (283 + 59)**; the 333-name list is a strict prefix of the 342 list; added = exactly the 9 `r99_animtree_*` rows | **verified** |
| "`run_battery.py` +29 lines, insertion-only" | `git diff --numstat ba5ab41 f1ff626 -- corpus/fixtures/run_battery.py` = **29 + / 0 −**, single hunk after the r98 block | **verified** |
| "183 cells = 61 logical cells × 3 backends" | parsed from the 9 committed marker strings: **183 cells**, per-arm 21/21/21/27/12/27/21/15/18 — exactly the report's table; 61 distinct `<case>@gp` twins | **verified** |
| "beq=1 … all 122 comparison cells" | 122 non-`@gp` cells, **122 × `beq=1`**, 0 × `beq=0` in the committed markers | **verified** |
| "peq … 1 on PHYSICS, 0 on IDLE" | `phys_f30/f120@*` = 6 cells all `peq=1`; `idle_f30/f120@*` = 6 cells all `peq=0` | **verified** |
| "`mk` would flag a missing end marker (none)" | `mk=0` occurrences: **0**; `err=` occurrences: **0**; `rc=0|134` occurrences: **3** (clsloop × 3) | **verified** |
| "a single `PASS r99_animtree <arm>` marker per arm" | all 9 rows in **all 6** author runs carry a last-stdout line **byte-equal to the committed `CASES` marker** (54/54), `rc=0`, `stderr=[]`, `error=None` | **verified** |
| "183 bounded children per battery pass" | **183** `r99t*` child dirs in each of the six battery scratches and in `ftest`; **0** `.godot` minted anywhere | **verified** |
| "Arm-level scratch runs and child logs" (`ftest`) | per-arm child counts 21/21/21/27/12/27/21/15/18 = 183; `passlines/<arm>.txt` is **byte-identical to the committed marker** for all 9 arms | **verified** |
| probe-copy SHA table | 6/6 match (and `cmp`-identical to the boundary sources, §1.2) | **verified** |
| "r99-only pre-runs … PASS ×2; full runs 342/342 ×2" | `20261016T071708787743Z` PASS 9/9; `20261016T071742046259Z` PASS 9/9; `20261016T073752637660Z` PASS 342/342; `20261016T074637746785Z` PASS 342/342; all four `seeds_unchanged=true` | **verified** |
| "Two earlier attempts failed only on legacy flake class (2) — `…T071812120994Z` (`navagent3d_follow`, `phys3d_events_deferred_hang`), `…T072806927381Z` (`navagent3d_retarget`, `r96_joltdet_thread`); all 9 r99 rows passed on every attempt" | both `verdicts.json` re-read: 340/342 each, failing cases **exactly** the four named, in the named pairing; r99 rows 9/9 in both | **verified** |
| r99 row wall times | author r99 rows 1.70–3.86 s across the six runs (20 s per-case bound) | **verified** |
| "Deliberately not pinned" list | matches the fixture header (`r99_animtree.gd:94-102`) and the markers (no `base`-rate cell anywhere; 0 `base@`/`@base` pins) | **verified** |

**2.7 Independent re-derivation of all pins from all saved children.** This seat
re-implemented the fixture's declared normalizations in Python
(`corpus/live/r99-scribe/normalize.py`: banner/blank drop, exact 2-line Jolt
warning pair, `#N`/`srv=S`/`seq=N`/`idle_rows=N`/`pf_rows=N` masking, per-cell
`ERR_ALLOW`, `done`-truncation) and re-hashed **every child of every saved
pass** — the author's `ftest` plus the six battery scratches —
against the sha pinned in the committed `CASES` marker for its
`(arm, case, backend)` cell:

```
pinned cells in CASES markers: 183
children checked=1281 sha==pin=1281 bad=0
```

(`ftest-sha-check.log`). The 183 pins are therefore re-derived from 1281
independent child executions, not restated.

---

## 3. The corrections vs the scout — all four re-derived from receipts

The committed header claims the scout's falsified forms are encoded in their
**corrected boundary form or not at all**. Verified from the boundary's own
receipts (and independently by the dispatched labrat, §8):

1. **`connect_node` is receiver-first.** `core_proj_wire.r1`: `WIRE_A_CALL
   connect_node("anim", 0, "output")` → `ERROR: Condition "p_output_node ==
   SceneStringNames::get_singleton()->output" is true.` with `WIRE_A_END
   actor=(0.0000,0.0000,0.0000) tp=0.0000` (provider-first never moves the
   actor) vs `WIRE_B_END actor=(0.6000,0.0000,0.0000) tp=0.1500`. The fixture
   pins exactly those numbers with `ee=1`.
2. **The first-frames law is watcher-position dependent.** `ord_proj_ffps60_*`
   (the pinned `--fixed-fps 60` regime): `pre_phys` `lead_zero=2
   pf_first_move=4` ×3, `post_phys` `lead_zero=1 pf_first_move=3` ×3,
   `pre_idle`/`post_idle` `lead_zero=1 pf_first_move=3` ×6 — matching the
   `r99_animtree_order` cells verbatim. The scout's flat "two non-advancing
   physics frames" is **not** pinned (the unthrottled `base` receipts do vary,
   which is why no `base` cell is pinned).
3. **AUTO timing.** `sm_proj_autocond.r1`: condition written at `pf=6`
   (`COL_SET read=true … cond=true`), first `node=b` at **`S pf=7`** — the
   fixture pins `autocond{… node=b, tp=1.0000, swpf=7}`; `sm_proj_autonocond.r1`
   enters at `node=b` on entry — the fixture pins `autonocond{… node=b,
   swpf=3}`. "Fires at the animation end" is not pinned.
4. **`travel("zzz")` is not silent.** `sil_proj_badstate.r1` carries exactly
   **3 ERROR lines per phase** (6 total) and ends `BS_END node=a ok=true`; the
   fixture pins `badstate{… node=a, ee=6}`. The `ERR_ALLOW` heads are verbatim
   from receipts (`pposerr` → *AnimationPlayer has no current animation.*;
   `dupnode` → *nodes.has(p_name)*; `dupstate` → *states.has(p_name)*;
   `badstate` → the three zzz lines; `wire` → the output-node line).

---

## 4. Fresh full battery on the committed bytes (ambient load)

    python3 corpus/fixtures/run_battery.py \
        --runs corpus/live/r99-scribe/battery-committed     # 07:56:49Z → 08:06:20Z

| measure | value |
|---|---|
| wall / load | **9 m 31 s**; 1-min loadavg 78.4 → 86.3 (24 foreign `yes` hogs + the r99-verifier full1 battery, the r99-critic mutant battery, the r99-simplifier probe battery and a g2d battery in flight) → 59.8 at audit end |
| receipt | `battery-committed/20261016T075649547017Z/verdicts.json` sha256 `4399bfd7da65a5e2fa161876308a4688…` |
| totals | **342 cases, 337 PASS / 5 FAIL** (283 ordinary + 59 negative), `case_timeout_seconds=20` |
| **r99 rows** | **8/9 PASS** — `r99_animtree_life` **FAIL** (`exact stdout marker missing`), see §5 |
| child census | exactly **183** `r99t*` child dirs, **0** `.godot` |
| seed flag | `seeds_unchanged=true`; all 123 seed digests re-verified on disk |
| r99 elapsed | 1.805–3.370 s |

**The four non-r99 reds are all documented load-class rows** (none r99-scoped):

1. `navagent3d_retarget` — `before=(1.754246, 0.0, 1.754246)`, the exact
   signature the r96/r97/r98 seats filed for the one-tick pre-switch flake.
2. `navagent3d_retarget_fixed` — the same root cause on the negative-control arm
   (both variants red in the same pass; the r98 scribe saw only the `_fixed`
   arm).
3. `phys3d_events_script_size_gate` — `min_thr drift … v={ "sz_fetch":
   "granted" }`, the r93-baseline F2 "size-gate granted-under-load" class.
4. `phys3d_events_deferred_hang` — same class (`refusal=false`, `rc=0` instead
   of `137`).

---

## 5. **F1 — the clsloop census is not stable (the r99 life red), and the td disclosure does not cover it**

`r99_animtree_life` printed its own `PASS …` line, yet the battery's
exact-marker gate failed it: the **`clsloop@jolt` cell differs from the pin**.

| cell | pinned (author, 45/45 prior runs) | my full-battery child |
|---|---|---|
| `clsloop@gp` | `rc=0|134,sha=9251889a008ea983,made=340,skipped=240,rounds=20,names=29` | identical |
| `clsloop@dummy` | same | identical |
| `clsloop@jolt` | `sha=9251889a008ea983,made=340,skipped=240` `beq=1` | **`sha=6934d64c82de4d84,made=360,skipped=220,beq=0`** |

So in that Jolt child one candidate class instantiated in **all 20 rounds**
instead of none (18 made + 11 skipped per round vs 17 + 12). Child log:
`battery-committed/20261016T075649547017Z/scratch/r99t2260174_life_clsloop_jolt/child.log`
(`CLS_LOOP made=360 skipped=220 rounds=20 names=29`). Everything else in the
row (11/12 comparison cells) stayed `beq=1`.

### 5.1 How rare is it, in the fixture's own form?

| source | clsloop children | census 340/240 | flipped |
|---|---|---|---|
| r99-boundary (6 reps × 3 backends, 6 of them under 16–32 hogs) | 24 | 24 | 0 |
| author, 7 saved passes (`ftest` + 6 battery scratches) | 21 | 21 | 0 |
| **this seat**: full battery | 3 | 2 | **1 (jolt, 360/220)** |
| this seat: r99-only run | 3 | 3 | 0 |
| this seat: 6 life-row repeats | 18 | 18 | 0 |

Observed rate: **1 / 69 fixture-form clsloop children** across all corpora this
audit can see; 0 in the 45 prior runs (24 boundary + 21 author).

### 5.2 The disclosed flake reproduced — and the td envelope did its job

The author's disclosed class #1 (post-marker glibc teardown abort) fired **twice
in this seat's six life repeats** (both Jolt):

```
CLS_LOOP made=340 skipped=240 rounds=20 names=29
CLS_LOOP_ALIVE ok=true
LIFE_DONE case=clsloop
corrupted size vs. prev_size while consolidating
timeout: the monitored command dumped core
```

(`life-rep1/…/r99t2380580_life_clsloop_jolt/child.log`, `life-rep5/…/r99t2395590_life_clsloop_jolt/child.log`).
Both rows **PASSED** (marker present, `rc` accepted as `0|134`), i.e. the `td`
encoding works as designed on the abort side. The corpus's only other saved
abort is the same signature in the author's first r99-only pre-run
(`runs/20261016T071708787743Z/scratch/r99t988971_life_clsloop_dummy/child.log`).

### 5.3 Attribution (this seat's own bounded diagnostic, `corpus/live/r99-scribe/diag/`)

A read-only Godot diagnostic replicating the probe's 20×29 loop, run in scratch
projects shaped like the fixture's children:

- **In-process, same class list, same 580 instantiations, three call forms**:
  the fixture's **inlined** form → `made=340 sk1=80 sk2=160`; a **typed-local**
  form (`var nm2: String = nm`) → `made=341`; a **typed-helper** form
  (`_inst(nm: String)`) → `made=500` — in the *same process*, 3/3 runs
  (`clsdiag3.gd`). The 8 classes that return `null` from
  `ClassDB.instantiate(nm)` in the inlined form are `AnimationRootNode`,
  `AnimationNodeBlend3`, `Add2`, `Add3`, `Sub2`, `Sync`, `Output`,
  `AnimationNodeBlendSpace2D`; in the typed-helper form none of them do
  (`AnimationMixer` + the three non-existent `AnimationNodeMix*` are skipped in
  both).
- **The flip is `AnimationNodeBlendSpace2D`**: per-class tallies show it
  skipped 20/20 in the pin state and 19/20 in flipped runs (the +20 case in my
  battery child = 0/20 → 20/20). In isolation (`--mode=only`) it succeeds
  **20/20 in 24/24 processes**; a `BlendSpace1D→BlendSpace2D` pair likewise
  20/20 in 24/24 — the null-return is specific to the inlined-loop call site,
  not to the class or to the backend.
- **Rate**: 4/12 GP and 0/12 Jolt diagnostic processes flipped to `made=341`;
  **0/32 diagnostic logs show the teardown abort**, so the census flip and the
  heap abort are two independent nondeterminisms (the flip is not a
  load-only artifact — it fired at loadavg ≈ 60–70).

**Observation / inference / unknown.** *Observed*: the pinned `made/skipped/sha`
of `clsloop` varies run-to-run and the row can red the exact-marker gate;
`ClassDB.instantiate()` returns `null` for 8 of the 29 candidate classes in the
fixture's call form, and `AnimationNodeBlendSpace2D` is the class that flips.
*Inferred*: the pin is a single-sample of a distribution (a `made=340` mode with
a rarer `made=341/360` mode), and the disclosed flake list is incomplete.
*Unknown*: the engine-internal reason for the null-return/flip (not chased
further by this seat — out of scribe scope).

**Consequences for the canonical judge** (reported, not judged): (a) the row is
not reliably green — any future r99 gate that runs the life arm can red on a
pin value, not on a behaviour; (b) the fixture's own `_cell_ok` **passes** this
child (it checks only `rc`, `ue`, marker presence), so the *battery marker* is
the only gate that catches it — a fail-closed gate, but one that reads as a
fixture regression rather than a census flake; (c) if the census is a real
measurement, the envelope form (mode set `{340,360}` / `beq` relaxed for this
cell) is the corpus's own declared remedy for bimodal cells.

---

## 6. r99-only narrow run + six life repeats

| run | receipt | result |
|---|---|---|
| r99-only (9 rows) | `battery-r99-only/20261016T080747499222Z/verdicts.json` sha `2eae6923fb271978194cab470bbbe4a1…` | **9/9 PASS**, 183 children, 0 `.godot`, `seeds_unchanged=true`, elapsed 1.903–3.417 s |
| life row ×6 | `life-rep{1..6}/20261016T0808*Z/verdicts.json` | **6/6 PASS**; 18 clsloop children all `made=340`; 2 of the 18 aborted post-marker (tolerated, §5.2) |

---

## 7. Provenance — pins re-derived, not restated

**7.1 Boundary crosscheck of every child my runs spawned.** A scribe-side
crosscheck (`crosscheck.py`) indexed all **939** boundary receipts by
`(probe, case, watcher, backend, --fixed-fps)` parsed from their own `.cmd`
files, re-normalized both sides with the fixture's declared rules and compared
normalized sha:

```
boundary receipt index: 263 distinct keys, 939 tags
children checked=474  matched-to-boundary=457  multi-receipt=457
unmatched=17
```

474 = my three scratch sets (183 + 183 + 108). **Every exception is accounted
for**:

- **16** = the `order` arm's **jolt/dummy** cells (8 per battery pass × 2
  passes): the boundary's `order` batch is **GP-only** (24 receipts,
  `ord_proj_*` only) — so those 8 non-GP cells per pass have **no boundary
  receipt at all**; their `beq=1` is the fixture's own twin comparison, not a
  boundary replay (**F2**).
- **1** = `clsloop@jolt` in the full battery — the census flip of **F1**
  (6 boundary tags exist for the key; none matches the flipped stream).

**7.2 td replay.** The `td` claim ("the hashed stream is truncated at the arm
marker, so both outcomes pin the same sha; `rc` accepts `0|134`") was re-derived
independently: **33/33** logs hash to `9251889a008ea983` under the declared
truncation — the 24 boundary clsloop receipts (all `rc=0`), the author's three
`ftest` children, clean children from four battery scratches, **and the one
aborting child** (which carries the glibc line *after* the marker). The two
aborting children of §5.2 are the 2/6 repeats that still hashed and passed.

---

## 8. Dispatched labrat probe (probeParent allowance: 1 of 1)

One read-only `labrat` probe was dispatched with the falsifiable hypothesis
*"every form of the r99-scout's four falsified claims is absent from the pinned
lattice and the corrected boundary form is what is pinned instead"*. It returned
**CONFIRMED on 4/4 sub-claims, with no refutation**, from the files alone:

- (1) `lead_zero`: pinned `phys_pre=2 / phys_post=1 / idle=1 both`, matching
  `ord_proj_ffps60_{pre,post}_{phys,idle}.r{1,2,3}` (`MODE_SUM` line 53); no
  cell pins `lead_zero=2` for a post watcher or for idle.
- (2) AUTO: `autocond` pins `swpf=7` (condition written `pf=6`, switch at
  `pf=7` while `tp=0.05`), `autonocond` enters at `node=b`; no at-end pin.
- (3) `travel("zzz")`: `badstate` pins `ee=6` with `node=a`; the receipt carries
  exactly 6 ERROR lines (3 per phase) and `BS_END node=a`.
- (4) no base-rate pin: `_spread` hardcodes `--fixed-fps 60`, the only other
  `eargs` site is the `--fixed-fps %d` rate loop, and `base@`/`@base` has 0
  matches in `run_battery.py`.

It also noted the one thing it did not do (independently enumerate the 183
cells), which this seat did in §2.

---

## 9. Findings (ranked, for the canonical judge)

- **F1 (material, undisclosed instability in a pinned cell + gate impact).** The
  `clsloop` cell pins `made=340, skipped=240, sha=9251889a008ea983, beq=1` as a
  cross-backend constant; it is not stable. This seat's full battery run
  produced `clsloop@jolt{…sha=6934d64c82de4d84,made=360,skipped=220…,beq=0}` and
  **`r99_animtree_life` red on the exact-marker gate** (§5). Attribution:
  `ClassDB.instantiate("AnimationNodeBlendSpace2D")` returns `null` in the
  fixture's inlined call form and occasionally does not; the same loop through a
  typed helper returns objects for all 8 affected classes (`made=500`), and in
  isolation the class succeeds 20/20 in 24/24 processes (§5.3). The author's
  §"Known flake classes" discloses only the teardown abort. **No pinned *value*
  is wrong in the sense of a bad measurement** — the pin is a single sample of a
  distribution — but the row cannot be relied on to stay green, and the battery
  gate that catches it reports it as a fixture mismatch, not as a flake.
- **F2 (low-medium, provenance scope).** The `order` arm's **8 non-GP cells**
  (jolt/dummy × 4 watcher/case combinations) are pinned without a boundary
  replay: the boundary's `order` batch ran **GP only** (`ord_proj_*`, 24
  receipts). Their `beq=1` is the fixture's own cross-backend twin comparison
  (still a real measurement — the same class of gap the r97 scribe filed as
  F3). All other 175 non-GP cells of the landing have a boundary receipt that
  byte-matches under the declared normalizations (§7.1).
- **F3 (low, gate-mechanism precision).** The fixture's `_cell_ok` validates
  only `rc`, unexpected-error lines and marker presence; the cell's *values*
  (`sha`, `made/skipped`, `beq`, `peq`, extracted fields) are enforced solely by
  the battery's exact-marker string. This is fail-closed at the battery level
  (F1 was caught this way) but means a parent run's own `PASS` line is not
  evidence that the pins held.
- **F4 (low, td disclosure precision).** For `clsloop`, the hashed stream stops
  **at** `CLS_LOOP_ALIVE`, so the probe's `LIFE_DONE` line, the engine teardown
  and any post-marker ERROR/SCRIPT ERROR line are neither hashed nor scanned for
  `ue`; the cell text also renders a constant `rc=0|134`, so the marker does not
  record which outcome occurred (the child log does). An abort *before* the
  marker still fails the cell (marker required) — the envelope is fail-closed in
  the direction that matters, and the window it leaves open is a single print
  statement plus teardown.
- **F5 (expected, freshness).** `LOG.md`/`SCORECARD.md` still end at **Round 98**
  (no r99 block/row) — pre-adjudication, same class as the r97/r98 F5/F6.
- **F6 (environmental).** My full run's four non-r99 reds are documented
  load-class rows (§4), and the run's `seeds_unchanged=true` is clean because
  the concurrent siblings committed only *reports* during the audit. HEAD moved
  from `f1ff626` to `34d3e69` with zero fixture bytes changed.

---

## 10. Not tested / remaining risks

- The boundary's own still-open list is unchanged by this landing: `xfade_time`
  crossfade, what ENABLED is *for*, BlendSpace1D/2D, OneShot/Transition/Add2-3/
  Mix*/Sync, play_mode/backward, root_motion, skeleton targets, the
  `(path, type)` cache's type granularity beyond position/scale/rotation.
- The `phys_f30/f120`/`idle_f30/f120` rate cells are pinned through the
  ffps60-anchored `peq` tuple plus their own hashed stream; I verified the
  markers and the boundary `mo_*_ffps{30,60,120}` receipts, but did not
  re-run the boundary's rate matrix.
- The `.godot` census is post-hoc (a child that minted *and* removed a cache
  would be invisible); no such behaviour is expected on this surface.
- Hash pins are build-scoped to `4.7.2.stable.arch_linux.ed1daf0bf` on this host
  (corpus convention).
- **F1 means any future r99 gate can red `r99_animtree_life`**: my run is the
  only observed instance, but 4/12 GP diagnostic processes reproduced the same
  +1-per-round flip, and nothing in the fixture bounds it.
- The full run was not on a quiet host (loadavg 78→86→60; four sibling wave-B
  batteries in flight), so a "load vs idle" split for the r99 rows is not
  isolated — 8/9 rows passed under it.

**Verdict: AUDIT PASSES-WITH-FINDINGS (F1 material).** Custody is intact
(2162/2162 + 3767/3767 manifest entries, 7/7 tracked bytes == committed blobs,
6/6 probe copies `cmp`-identical to their boundary sources, 123/123 seed digests
per cited run, 536/536 + 939/939 rc=0 child censuses), every author number is
re-measured (333→342 = +9, 283+59, +29/−0 insertion-only, 183 = 61×3 cells with
the report's per-arm table, `beq=1` ×122, `peq` 6/6 and 6/6, 183 children per
pass, 1281/1281 pins re-derived from all saved children, 54/54 exact markers),
the four scout corrections are re-derived from receipts and confirmed by the
labrat probe, and the committed bytes reproduce the surface on this seat's own
runs — **8/9 r99 rows PASS in the fresh full battery, 9/9 in the r99-only run
and 6/6 in the life repeats** — with **457/474 children byte-matching a boundary
receipt** under the declared normalizations. The one red is **F1**: the
`clsloop` census the author pinned as a constant is a single sample of a
distribution (`ClassDB.instantiate` returns `null` for 8 of the 29 classes in
the fixture's call form; `AnimationNodeBlendSpace2D` flips), so the life row can
red the exact-marker gate; F2–F6 are provenance-scope, gate-mechanism,
disclosure-precision, freshness, and environmental items. No commit made, per
instruction.
