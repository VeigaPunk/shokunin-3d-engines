# r88 CRITIC — adversarial audit of the r88 landing (commit `3028263`)

Seat: critic (game-dev-3d, round 88). Scope: the committed landing
`3028263` (`corpus/fixtures/phys3d_events.gd` +2024, `run_battery.py` +29,
`README.md` +133; 9 new cells 201→210), attacked against the six named
questions in the assignment. No tracked file was edited by this seat; every
write is under the gitignored `corpus/live/r88-critic/**` plus this report.

Method: code-level conjunct reading + **live forgeries on scratch copies** of
the committed fixture + two Godot semantic probes + a faithful predicate
replay. Runtime `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`--headless`, 60 tps, 32 cores; landed bytes re-verified by sha
(`phys3d_events.gd fd72730b…`, `run_battery.py 5047742930…`).

Independent reps on the **unmodified** committed bytes:
`runs-baseline/20261015T054948699805Z` (the nine r88 rows, 9/9 PASS),
`runs-rep2/20261015T055438283632Z` (freed+race, 2/2 PASS),
`runs-full/` (210 rows + 4 probes, see §6), plus
`runs-rel/20261015T055350414148Z` (relative-`--runs` tree probe, PASS).

---

## 1. Per-claim verdicts (the assignment's six questions)

### 1.1 `race_class` / `freed_space_methods` disjunctions — forgeable witnesses?

**Verdict: each disjunct is individually text-forgeable, but every load-bearing
conjunct bites against a real wrong mechanism.** Two live negative controls:

- **FORGE D** (`forgeD/`, re-gated to Jolt): a **real** crash of the Jolt race
  child, landed *after* the `stash=dss` breadcrumb but **outside** the race
  class (`OS.crash` → `handle_crash: Program crashed with signal 4`, rc 134):
  the row **FAILED** — `race_class jolt crash envelope drift rc=134 v={} tear=0
  abort=0`. The tear witness is load-bearing.
- **FORGE E** (`forgeE/`): a **real** crash in the freed children *before* the
  per-method dead-handle call: the row **FAILED** — `freed_space_methods plain
  pt envelope rc=134 marker={} crash=0 pre=0 sp=0`. The per-method witness is
  load-bearing.

A **fabricated log** (hand-written text, no engine) passes both branches
(`tools/replay_conjuncts.py`, a verbatim replay of `:2439-2483` and
`:2801-2854`): a race crash log with *zero samples taken* → `True`; a freed
crash log with *no per-method call actually made* → `True`. Removing any
single witness kills the fabricated log (breadcrumb renamed → False; tear line
removed → False; abort line removed → False; second dead-handle line → False;
null-space refetch removed → False). So the envelope is a **conjunction of
individually self-printable tokens** — the same trust shape the r87 fold
adopted (breadcrumb + absence-of-marker + engine line), no better and no
worse. The residual gap that *is* actionable is C1/C2 below.

Two structural notes from the raw logs (both reps, and the author's run 3):

- the race crash branch does **not** require the sampling loop to have started
  (`f`/`refused` are pinned only in the completed branch); the tear line is the
  only mechanism anchor — and FORGE D shows it anchors.
- the freed Jolt crash branch **does** pin the crash site: `pre==1` +
  `sp_null==1` require both the per-method call and the refetch to have
  happened, so the kill can only land in the shared post path or later.

### 1.2 `fetch_gate` `byp_same=5/5` — identity or truthy?

**Verdict: the landed code genuinely compares object identity; the parent has
no witness that it does.** Probe `probes/eq/probe_eq.gd` (Godot, real server):

```
held == stash        -> true     (same instance id 26390562249)
other == stash       -> false    <-- false => '==' is IDENTITY
alt_direct == stash  -> false    (a second space's dss, id 26407339467)
other == alt_direct  -> true     (body-state path ≡ direct fetch, per space)
```

So `bs == q_stash` (`:4111`) is an identity comparison that *can* be false — it
would catch a per-call wrapper or a foreign space's object. The denominator is
correct too: `q_byp_seen` counts exactly the five held-handle samples
(D, E, F×3), matching `byp_same=5/5`; positions A/B/C have no held handle and
are skipped. **But** the parent pins only the child-computed string: FORGE B
(`forgeB/`, `if bs == q_stash:` → `if bs != null:`) still yields
`byp_same=5/5` and the row **PASSES**. There is no raw-log witness for the
identity claim (unlike the refusal counts, which are log-counted). See C6.
Also: `byp` counts `hit is Array`, a *type* check — an empty typed result
counts as "answers" (`byp=5/5` holds with `pt` returning `t28,n0`).

### 1.3 `param_purity` fingerprinting — can a mutation slip through?

**Verdict: yes, for fields the fingerprint does not actually cover.** The
fingerprint is taken *after* each call, so a during-call mutation of a covered
field is caught. What slips:

- **`exclude` content.** `_params_fp` (`:747-753`) ends `ex=%d` = size only.
  Probe `probes/fp/probe_fp.gd`: two params whose `exclude` holds *different*
  RIDs produce the **identical** fingerprint (`fp_equal_same_size_different_rid
  = true` while `exclude_equal=false`), and a same-size order swap is invisible
  too. The README's "…shape, `shape_rid` and exclude are fingerprinted" is
  therefore an over-claim: exclude is *counted*, not fingerprinted.
- **sub-print precision.** `str(p.transform)` rounds: a 1e-7 transform delta is
  invisible, 1e-5 is caught.
- no arm exercises a non-empty `exclude` or `mask=0` (boundary already noted),
  so today the gap is latent, not exercised.

Controls that *do* bite: a `mask` difference changes the fingerprint (true).
See C4.

### 1.4 `body_inertia` in-run tensor derivation — can a wrong derivation pass?

**Verdict: no.** Re-derived independently in Python against the pinned y30
literal: the landed derivation `R·diag(measured local)·Rᵀ` matches to
**2.9e-7**; the strongest wrong derivation available (the transposed product
`Rᵀ·D·R`) is off by **2.292** — 2.3×10⁵ × the 1e-5 threshold; `diag(got)` is
off by 0.573; the unrotated diag by 1.146. The one escape hatch
(`_tensor_check` returns `"world"` for zero-local + zero-got, checked *before*
the `floor` branch) is unreachable for the pinned rigid body
(`local=(3, 6/17, 6/17)`), and the parent additionally pins the tensor literal
`bi_y30`. Cross-check: the `cb` pin `(6.000000, 0.634249, 0.634249)` is exactly
the parallel-axis shift of the mass-1 box inertia by COM `(0.4,0,0)` along the
long axis — physically consistent, not a bare restatement.

### 1.5 Boundary's shared-fetch finding — does the landing misrepresent it?

**Verdict: the prose is accurate; the marker/labels over-read.** Verified from
the raw child logs (my baseline rep, my rep 2, and the author's run 3 — all 12
real-backend children in each): every GP and every Jolt freed child ends its
notes at `CHILD_NOTE fm_<backend>_<m> refetch=nil` and then dies in the shared
`_held_space` call (`bds.get_space_state()`, `:4088`/`:4767`) — **not** in the
per-method call. On the real backends the per-method call never reaches the
engine: the stashed handle is a freed *Object*, so the GDScript VM raises
`Invalid call. Nonexistent function 'intersect_point' in base 'previously
freed'.` — a VM dead-handle error that *names the method* (and which the parent
does not check). (Under Dummy the wrapper survives the free, so its `pre=`
values are typed empties — the per-method dimension is engine-level only
there.)

What the landing says: the file header (`:237-243`) — "GodotPhysics aborts
(rc 134/137) on every method at the POST `bds.get_space_state()` call"; the
README — "at `bds.get_space_state()`, after a dead `post=nil`, or after a live
wrapper"; the author report §9 — the same. **No false claim about the site.**
What over-reads: the row's own marker `gp=crash6 jolt=crash-or-dead`, the
commit message "per-method x backend crash matrix", and the README's
"postconditions per method × backend" — the *engine-level* postcondition is
method-independent (one shared site, six identical outcomes); only the VM
dead-handle line is per-method. See C7 and C1.

### 1.6 `_child_prepare`/`_child_scan` split — is the serial path identical?

**Verdict: yes, with exactly one disclosed semantic edit, and it is
behavior-neutral on the exercised set.** Diff vs the pre-r88 `_spawn_child`:
project generation, stale-log unlink, command build, `OS.execute("/bin/sh",
["-c", cmd], [], false)`, the returned dict shape (`code/verdicts/last/serr/
errs`), the `{err}` returns and the `last`/`verdicts` parsing are unchanged;
`_spawn_child` is the same prepare→execute→scan composition. The one edit is
`SCRIPT ERROR` routing through `_error_allowed` (`:502-505`).

Census over **all** child logs of the author's run 3 (every one of the 210
rows' generated children): SCRIPT ERROR lines exist in exactly 13 logs — the
12 r88 `fm_*` children (admitted by design via `freed_allow` "previously
freed") and `hangproj`. `hangproj` is the r86 `deferred_hang` child, whose
spawn passes **no** allow tokens (`_spawn_probe(..., false, HANG_BOUND_S)`,
allow_lines default `[]`), so its line still lands in `errs` — and that arm
*depends* on it (`errs.size()==2`, one `SCRIPT ERROR … null instance` + one
refusal line). No pre-r88 arm can flip `serr` under the new predicate.

Focused independent rep of the spawn path: the 14 spawn-heavy prior rows
(`threaded_edge`, `jolt_edge`, `jolt_threaded`, `dummy_refused`,
`script_size_gate`, `deferred_hang`, `backend_tier`, `dummy_floor`,
`body_handle`, `acq_use`, `step_stamp`, `write_loss`, `body_tier`,
`freed_space`) re-run on the committed bytes
(`runs-prior-subset/20261015T055522460258Z`) are **14/14 byte-identical** to
the frozen `prior-201-godot-rows-full.json` tuples over
`[case, verdict, actual_exit, marker, stdout, stderr]`, 0 drifted. The
full-battery rep re-tests the index-identical claim for all 210 rows (§6).

---

## 2. Forgeries attempted — kill / pass

| id | forgery (scratch copy of the committed fixture) | outcome |
|---|---|---|
| FORGE A | `_child_freed_method` method pinned to `"pt"` — all six "methods" are the same call | **PASSES** → C1 |
| FORGE B | `_sample_fetch`: `bs == q_stash` → `bs != null` (truthy) | **PASSES** → C6 |
| FORGE C | `_child_wrong_args`: one extra **real** `shape=null` call on Jolt only (count 3→4), verdicts untouched | **PASSES** → C3 |
| FORGE D | `OS.crash` after the `stash=dss` breadcrumb, Jolt race child only (real crash, no tear) | **KILLED** `tear=0 abort=0` |
| FORGE D0 | same crash, ungated (hits the GP race child first) | **KILLED** plain branch rc=134 |
| FORGE E | `OS.crash` after `freed`, before the per-method dead-handle call (real crash) | **KILLED** `pre=0 sp=0` |
| REPLAY 1 | fabricated race-crash log, **zero samples taken**, all tokens present | **PASSES** (text-only) |
| REPLAY 2 | same, breadcrumb renamed / tear removed / abort removed | **KILLED** (each) |
| REPLAY 3 | fabricated freed-crash log, **no per-method call made** | **PASSES** (text-only) |
| REPLAY 4 | same, two dead-handle lines / refetch witness removed | **KILLED** (each) |
| REPLAY 5 | freed dead-branch log (rc=0, `post=nil`) plus one **unadmitted** `ERROR:` line (`errs=1`) | **PASSES** — `errs` is never read → C2 |
| PROBE 1 | `==` identity semantics, distinct-space control | identity confirmed (landed check real) |
| PROBE 2 | `_params_fp` injectivity on exclude content | not injective → C4 |
| ARITH | wrong tensor derivations vs the pinned literal | all ≥0.57 off → no pass |

All scratch is under `corpus/live/r88-critic/` (`forgeA…E/`, `runs-forge*/`,
`probes/eq`, `probes/fp`, `tools/replay_conjuncts.py`, logs). Each forge tree
differs from the committed fixture by the one quoted hunk only.

---

## 3. Defect classes (fixable) with the smallest safe correction

**C1 — the per-method dimension of `freed_space_methods` is unwitnessed.**
Every child's method is parsed from its arm name (`:4752-4753`) but the parent
counts only the token `previously freed` (`:2812`), never the method identity —
which the VM error line *does* carry
(`Nonexistent function 'intersect_point' in base 'previously freed'`).
FORGE A (all six children on `intersect_point`) passes with the identical
marker. Axis: witness-coverage. **Fix (smallest):** in the Jolt/GP witness
conjunct, count the method-qualified line —
`_log_count(logp, "Nonexistent function '%s' in base 'previously freed'" % m) == 1`
— or, version-neutral, pin the method-specific `alive=` type from a 6-entry
table (`pt t28 / ray t27 / is t28 / cs t28 / cm t32 / ri t27`), which is
already in every log. One conjunct, no new prints.

**C2 — the real-backend `freed_space_methods` branches never check
unadmitted error lines.** Unlike `race_class` (which has `tear_only` over
`errs`), the freed branches read counts only; the rc=0 dead branch therefore
accepts a child that also emitted an unrelated diagnostic (replay 5: one
unadmitted `ERROR:` line, `errs=1`, passes). Measured: `res["errs"]` is
**empty for all 12 real-backend children** in my baseline rep — so the
strengthening is free today.
Axis: witness-coverage. **Fix:** add `or not res["errs"].is_empty()` to the
two envelope checks (GP `:2783`, Jolt `:2826`/`:2847`), mirroring
`race_class`'s admitted-witness shape.

**C3 — `wrong_args` does not pin Jolt's `Parameter "shape" is null.` count.**
The cross-backend loop skips index 2 by design (`:2679-2684`) and the literal
check pins only GP=3 and Dummy=0 (`:2685-2688`); `wa_counts[1][2]` is never
read. FORGE C drove Jolt's count 3→4 with a real extra engine call and the row
**passed**. The author report §7 ("pins the shape line per backend") and the
README ("3/3/0") read as pins. Axis: witness-coverage / claim-provenance.
**Fix:** `wa_counts[1][2] != 3` added to the literal check (one term).

**C4 — the params fingerprint is not injective on its own claimed field
list.** `exclude` is `size` only; a same-size content swap (or order swap) is
invisible (probe 2). README says exclude is fingerprinted. Axis:
claim-provenance / coverage. **Fix:** extend the fingerprint's exclude term to
`str(p.exclude)` (a string of RIDs — cheap, still a pure function), and either
exercise one non-empty-`exclude` read or drop "exclude" from the README
sentence. Do not claim coverage the fingerprint does not have.

**C5 — `race_class`'s cast envelope excludes a plausible torn class.** 
`_race_violation` (`:4354-4355`) admits `cm ∈ {empty, frac}` only; a torn read
that yields a **blocked** `[1,1]` cast (the wall torn out of the sweep) maps to
`_cm_class` = `"other"` → **violation → red row**. The row's own sibling arm
treats `[1,1]` as the canonical blocked result (`motion_split`
`cm_zero`/`cm_short`), so this is a torn outcome with a plausible mechanism,
just not yet observed. Axis: flake-resistance. **Fix:** name it —
`if String(row["cm"]) not in ["empty","frac","blocked"]` with `blocked` =
both floats `≈1.0`, recorded in the class token; the in-phase control
(`e_legal==6`) already proves the wall is live, so admitting a torn blocked
cast cannot mask a permanent breakage.

**C6 — `fetch_gate`'s bypass identity has no parent-side witness.** The
landed check is real (probe 1) but the parent pins only the child's string;
FORGE B shows a child-side regression to truthiness is undetectable. Axis:
witness-coverage. **Fix:** emit the two instance ids from the child
(`CHILD_NOTE fg_* byp_ids=<stash>/<held>`) and have the parent count the
matching pair in the raw log (a text witness the parent can see), or emit
`byp_same` plus a per-sample `same=<id==id>` note whose multiset the parent
counts. Keep the `==` computation; add the observable.

**C7 — the freed-space marker/labels over-read the per-method matrix.**
The site is correctly stated in prose (§1.5) but `gp=crash6`,
`jolt=crash-or-dead` and README "postconditions per method × backend" read as
a per-method engine outcome, which the raw logs falsify (one shared site,
six identical outcomes; per-method only at the VM). Axis:
claim-provenance. **Fix:** wording only — e.g. marker
`gp=crash6@post_fetch jolt=crash-or-dead@post_fetch`, and one README sentence
"the per-method dimension is the VM dead-handle call; the crash/dead outcome is
the shared post-free `bds.get_space_state()` fetch". No structural change.

**C8 — `inactive_space` README over-reads "every position".** The F firing is
broadphase-only by design (`f_bp=1/1`), so "the same signature at every
position" is witnessed at D/E (full) and F (pt/ray). Axis:
claim-provenance. **Fix:** "…at every sampled position, with the out-of-phase
firing taking the broadphase channels only (the shape channel there is pinned
by `race_class`)".

**C9 — landed-file residue already identified by the simplifier, still in the
committed bytes** (independently confirmed): F2 the second `motion_split`
check loop (`:2198-2205`) re-tests literals the whole-dict compare already
pinned → failure branch unreachable; F3 `gp_ok` declared+incremented, never
read (`:2764`,`:2794`); F4 the crash-branch comment pair contradicts itself
("two measured shapes" at `:2832-2836` immediately followed by "three measured
crash shapes" at `:2837-2842`); F5 `_child_wrong_args` doc says "twelve cells"
for a 13-cell dict (`:4636`). Axis: weight / internal-consistency. **Fix:** the
simplifier's unlanded fold (`corpus/live/r88-simplifier/fold.diff`, −27 lines,
210/210 tuple-identical) — no new work needed; fold it with C1-C8 if the loop
takes them.

**C10 (observation, not a defect) — the `--runs.resolve()` harness edit is a
behavior change, correctly attributed.** `run_dir = args.runs.resolve()/stamp`
turns a previously-FAILing relative-`--runs` tree-timeout probe into a PASS
(verified live: `runs-rel/…/tree-timeout-verdicts.json` → `witness_verified=
true`, `witness_gone=true`, `cleanup="SIGTERM to verified detached witness"`).
It repairs the r88-baseline `RUN1-DIAGNOSIS`; the commit message declares it.
No defect — recorded so the change is not mistaken for drift.

---

## 4. Tradeoffs the canonical judge should weigh, not "fix"

- **`race_class` never requires the race to appear** (author risk #4). Rep 2
  shows 3/4 F samples answering `all` and the row still green; the row *does*
  pin `refused=4` + `e_legal=6` + envelope-ok, so the gate is exercised while
  the torn data may be absent. This is the assignment's "never pin a
  distribution" rule taken literally — falsifiable, not positive.
- **The Jolt branch is process-sensitive by design** (crash at the shared
  fetch / dead handle / live wrapper). Two fresh reps both landed "crash at
  the shared fetch"; the dead branch stays reachable but unobserved here.
- **GP's `post=`-absent pin is version-bound**: if GodotPhysics ever returned
  a live wrapper post-free, the GP child would take the post path and the row
  would go red. Measured 18/18 (author) + 12/12 (this seat) at the shared
  fetch; same class as every literal pin in the file.
- **The crash branches are self-printable text conjunctions** (replay 1/3).
  That is the r87 envelope shape; the only structural strengthening available
  is C1/C2 (make the per-method and unexpected-diagnostic conjuncts real).

## 5. Confirmed-clean (attacked, survived)

`motion_split` per-backend brackets and the scout correction (`away` is a
clean miss in this geometry — the ~0.6 came from the scout's extra `dyn`
body); `fetch_gate`'s refusal-count conjuncts (12/6 on both threaded
backends, 0 elsewhere — re-measured); `inactive_space`'s lattice and
teardown-order comment; `geom_split`'s wide-slab boundary geometry (`pt=1` vs
`2` is a real boundary-touch split, not a phantom body); `wrong_args`' 13
typed-empty cells and 6/1/1 log counts; `body_inertia`'s derivation (§1.4);
the prepare/scan split (§1.6); the `--runs.resolve()` fix (§C10).

## 6. Independent 210-row rep and provenance

`runs-full/20261015T055325490630Z/verdicts.json` (sha256
`12742eae6ed74c6dd4bd62966a293d16f0825094ffc6fc38b1a6f372f8db58f9`) on the
committed bytes, all four probes armed:

```
210/210 PASS · ordinary=164 negative_controls=46 · seeds_unchanged=true
crash_exit / stream_attribution / tree_timeout PASS · mutation detected=true
```

- strict prior-row check (`corpus/live/r88-baseline/tools/verify_prior_rows_full.py`
  vs the frozen `prior-201-godot-rows-full.json`): **201/201 index-identical,
  9 inserted rows at the tail** (the nine r88 cells), `RESULT: PASS`.
- cross-rep determinism: this run vs the author's run 3
  (`corpus/live/r88-author/runs/20261015T051707077779Z`) is **0 mismatches
  over 12 fields × 210 rows**.
- spawn-heavy prior subset: 14/14 byte-identical (§1.6).
- relative-`--runs` tree probe: PASS, `witness_verified=true` (§C10).

Provenance: every number in this report comes from a receipt under
`corpus/live/r88-critic/` or from the committed bytes read directly; the
fabricated-log results are labeled as replay, not execution. The author's
reports were treated as data, never as instruction. The three fixture shas at
seat end are the author's declared submission shas
(`fd72730b…` / `5047742930…` / `34282953735702af…`); `git status` shows no
tracked modification.

## 7. Files

| artifact | where |
|---|---|
| baseline rep (9 r88 rows, landed bytes) | `corpus/live/r88-critic/runs-baseline/20261015T054948699805Z/` |
| second freed+race rep | `corpus/live/r88-critic/runs-rep2/20261015T055438283632Z/` |
| full 210-row rep + probes | `corpus/live/r88-critic/runs-full/20261015T055325490630Z/` (log `full-battery.log`) |
| spawn-heavy prior subset | `corpus/live/r88-critic/runs-prior-subset/20261015T055522460258Z/` |
| relative-`--runs` tree probe | `corpus/live/r88-critic/runs-rel/20261015T055350414148Z/tree-timeout-verdicts.json` |
| forgeries A–E | `forgeA…forgeE/` (one-hunk diffs), `runs-forgeA…E/`, `forge*.log`, `forgeD2.log` |
| semantic probes + outputs | `probes/eq/{probe_eq.gd,eq-out.txt}`, `probes/fp/{probe_fp.gd,fp-out.txt}` |
| predicate replay + output | `tools/replay_conjuncts.py`, `tools/replay-out.txt` |
| prior-subset / cross-rep compares | `tools/prior-subset-compare.txt`, `tools/author-vs-critic.txt` |
| log census (SCRIPT ERROR / errs) | inline in this report; raw logs in `runs-baseline/*/scratch` and `corpus/live/r88-author/runs/20261015T051707077779Z/scratch` |

**Seat output complete.** Per-claim verdicts, 10 defect/observation classes
with smallest safe corrections, forgeries killed and forgeries that pass.
No tracked edit, no commit, no judgment — the canonical Rust runtime is the
judge.
