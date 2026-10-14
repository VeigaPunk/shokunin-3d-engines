# game-dev-3d round 87 — simplifier (seat: simplifier, host: devin)

Wave `shokunin-train-20261101-w19`, lane g3d. YAGNI audit of **`c57fa40`**
(`r87 work: body-tier direct-state lattice — 6 arms`): `corpus/fixtures/phys3d_events.gd`
+876/−4 (the `--stat` churn figure is +880), `run_battery.py` +14/−0,
`README.md` +90/−0. Assignment
(`.ufo/waves/shokunin-train-20261101-w19/tasks/g3d-r87-simplifier.md`, verbatim):

> Find deletable weight: dead pins restating gate conjuncts, unreachable
> branches, dead params/fields, duplicated emit blocks. Prove each deletion by
> replay (201/201 both phases, prior rows byte-identical) + differential fuzz
> where applicable. Deliver a fold.diff + verified full copies under
> corpus/live/r87-simplifier/vfold/.

**No tracked file was edited by this seat.** Every write is enumerated in §10:
the gitignored `corpus/live/r87-simplifier/**` receipt tree (base/vfold copies,
variants, tools, runs, A/B, mutations) and this report. HEAD was `c57fa40` at
seat start and at seat end; `corpus/fixtures/{phys3d_events.gd,run_battery.py,README.md}`
are byte-unchanged (`0e5e64f4…`, `45b1ea86…`, `45ec89a2…`).

**Runtime** `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`,
60 tps, 32 cores, this host. **LSP unavailability recorded**: no `lsp` device is
exposed in this session (same as every r85/r86/r87 lane); no symbol-aware
`references` operation was available. Every symbol fact below is a **text census
over the committed bytes** (declaration + every occurrence), never presented as
semantic proof. The semantic substitutes are the engine's own GDScript parse
(`--check-only` rc 0 on the folded file) and the battery's `Parse Error` /
`SCRIPT ERROR` scan, both exercised on every replay.

---

## 0. Result

| id | site (committed lines) | change | Δlines | Δbytes | replay | verdict |
|---|---|---|---|---|---|---|
| **P1** | `two_fetch` — field `:2434`, assignment `:2448-2449`, emit `:2463`, note token `:2450`, expect entries `:1450,:1460,:1473`, markers `:1484` + battery | delete the pin whose predicate the retained identity pins already own | **−7** | **−347** | full 201/201; the only row-field diffs are the intended marker edits (§8.1); ablation recorded (§8.4) | **PROPOSE** (see §2) |
| **P2** | `tally` — emit `:2647`, parent conjunct `:1612`, markers `:1617` + battery | delete the child's self-sum token; the parent's own `landed + lost` sum is the retained conjunct | **−2** | **−132** | full 201/201; ablation recorded | **PROPOSE** |
| **P3** | `post_grav` — field `:2557`, assignment `:2563-2564`, note token `:2574` | delete the field read only by its own `CHILD_NOTE` and cited by no report table | **−3** | **−143** | full 201/201; child-log note delta only | **PROPOSE** |
| **G** | 14 `BLOCKED` gates `:1011,1047,1079,1317,1320,1380,1423,1426,1498,1541,1632,1635,1716,1719` | one `_gate(engine, arm, token)` for all 14 (r86 SP2 shape, total) | **−17** | **−515** | 22/22 stub A/B cells byte-identical (§8.3) | **PROPOSE** |
| **E** | 44 emit sites in the six r87 child bodies | one `_emit`/`_note` pair; the r87 arms' emit shape exists once | **−3** | **−292** | static re-expansion 42/42 + child-log maps identical | **PROPOSE** (smallest win) |
| **`vfold`** | P1+P2+P3+G+E | **the fold target** | **−32** | **−1392** (+ battery −23 B) | **201/201 both phases**, prior 195 at identical positions, mutations 6/6, retained-conjunct cells 4/4 | **fold.diff** |

Everything else measured was rejected with its number (§7), including the wider
`Epre` emit fold (−579 B, delivered as an optional variant and replayed), the
impossible `Eall` fold, the two `bt_dummy_*` pins that *are* forced but share an
emit line with the real split, the `nospace` tail, the acquire bails, the
`_backend_name` floor, three micro-folds that cost more than they save, and the
`_spawn_child` err-check fold (r85 VE attribution).

`corpus/live/r87-simplifier/fold.diff` is the reviewable patch;
`corpus/live/r87-simplifier/vfold/` is the verified full copy (a runnable
fixtures tree); `corpus/live/r87-simplifier/README.md` documents the tree and
the reproduce commands.

---

## 1. Method, controls, byte-identity discipline

- **Trees** (gitignored; 55 seed files each):
  `base/` = `git archive HEAD corpus/fixtures` — byte-equal to the committed
  blobs; `vfold/` = `base/` + the fold (`phys3d_events.gd d6c08908…`,
  `run_battery.py f9e31098…`). Every battery run records its own
  `seed_digests`, so no receipt can be read against the wrong bytes.
- **Phase 1 (control, committed bytes)**: this seat's own run
  `runs-control/20261014T215656944804Z/` (`--godot /usr/bin/godot`, no probe
  flags, all 201 cases) **plus** the independent r87-baseline phase-2 receipt
  `corpus/live/r87-baseline/runs-post/20261014T215119929090Z/` (201/201,
  `seeds_unchanged=true`, `seed_digests.phys3d_events.gd = 0e5e64f4…`).
- **Phase 2 (fold)**: `runs-vfold/20261014T220217401209Z/` on the folded bytes.
- **Rows** compared over the 12 receipt fields the r87 author used (`case,
  script, flags, expected_exit, actual_exit, error, kind, marker, verdict,
  reasons, stdout, stderr`); `command` (per-run scratch path) and
  `elapsed_seconds` are run-scoped by construction.
- **Prior rows**: the r87-baseline's own
  `tools/postcommit_verify_godot_prior.py` against the frozen
  `prior-195-godot-rows.json` (`dd8812be…`).
- **Child logs**: every `<project>/child.log` under both scratch trees, run-dir
  normalized, compared raw, by `.gd:<line>`-normalized text, and as the
  `CHILD_RESULT` map + `CHILD_NOTE` list the parent's own parser reads.
- **Static equivalence**: `tools/verify_fold.py` parses every base emit site
  into `(kind, format-string, args)` and re-expands every folded
  `_emit`/`_note`/`_gate` call into the same tuple, requiring the base sites as
  an **ordered subsequence**. The one normalization (one `str(...)` wrapper) is
  exact on this build, measured not assumed: `"%s" % [x] == str(x)` for
  float/int/bool/Vector3, 13/13 identical (`/tmp/r87sim/probe/eq.gd`).
- **Mutation differential**: the r87 author's 6-arm matrix re-run verbatim
  against the folded bytes, plus two ablations that make the *deleted*
  predicates false (§8.4).

---

## 2. P1 — `two_fetch`, the pin whose predicate the retained pins already own

`_child_bh_identity` pins eight body_handle tokens per backend. Seven compare a
*fetch* against an independently obtained handle: the engine's handed `state`
(`if_same`), the handle the sync callback is handed every tick (`ss_same`), the
handle held across detach/reattach (`held_live`, `reattach`), the three-tier
twin (`twin`), and the detach read (`detach`). The eighth,

```gdscript
	two_fetch = PhysicsServer3D.body_get_direct_state(srig) \
			== PhysicsServer3D.body_get_direct_state(srig)
```

compares two *consecutive calls of the same expression in the same frame*. The
retained pins already establish that this call returns a deterministic per-body
object: `ss_same=true` requires a fetch to return the object the engine itself
handed the callback (4/4 ticks in the receipts) and `reattach=true` requires a
same-frame fetch to return the handle held from six frames earlier. A fetch that
returned a different object per call would fail `ss_same` and `reattach` first;
`two_fetch=false ∧ ss_same=true ∧ reattach=true` is not a reachable engine
state, so the pin restates a conjunct the row already carries.

Deleted: the field, the assignment, the emit, the note token, the three
`*_two_fetch` expect entries, and the `two_fetch=true` token in the fixture's
marker and in `run_battery.py`'s expected marker (a claim the fold can no longer
earn may not stay in the marker).

**The counter-read, disclosed.** `reports/round-87/r87-critic.md` F5 lists
`if_same, ss_same, reattach, twin, two_fetch` together as "strict instance
identity — a different object cannot satisfy them". That is consistent with this
deletion: the family fails *together* on a non-singleton, and four of its
members remain. The critic's sentence is about the family's strictness, not
about `two_fetch` carrying a class of its own. This is the one candidate where
this seat's read and a sibling seat's wording can be read as differing; both
arguments are in this report and the adjudicator has them.

**What the deletion gives up, measured, not argued** (ablation A1, §8.4): the
base row catches a child that *prints* `two_fetch=false` while printing
`reattach=true`; the folded row does not. That is a child-side inconsistency,
not an engine state — an adversarial child prints the expected value in either
tree — and the whole-dict gate still forces every retained token.

---

## 3. P2 — `tally`, the child's own sum restated

`_child_write_loss` emits `wl_plain_tally=landed + lost`; the parent asserts

```gdscript
					and int(wl_v.get("wl_plain_tally", "-1")) == BODY_REPS \
					and wl_landed >= 1 and wl_landed + wl_lost == BODY_REPS
```

i.e. the same arithmetic twice: once as the child's own sum of two *retained*
tokens, once as the parent's sum of the same two fields. The parent's sum is
strictly stronger (it does not trust the child's arithmetic), so the child's
token restates a conjunct the gate already owns — the g2d r77 P3 "derived
restatement" tier, on the same two operands.

**Two sibling seats reached the same finding independently.**
`r87-reviewer.md` §11.2: "`landed + lost == BODY_REPS` is true **by
construction** (each rep increments exactly one of the two counters), so that
conjunct is a bookkeeping identity, not an independent witness … a future fold
should label the tally as bookkeeping rather than a gate".
`r87-critic.md` F4: "`tally=8` is near-tautological (each rep increments exactly
one counter — it pins loop completion only)". Loop completion is independently
pinned by `gate=refused` (`refused == BODY_REPS`) and `same_turn == BODY_REPS`.
This fold takes the *child-side* token (the one that is a sum of two retained
fields) and leaves the parent's own sum in place, which is the "accounted tally"
the reviewer asks to keep visible; the marker keeps `race=bounded`, `reps=8`,
`same_turn=8`.

**Ablation A2** (§8.4): the base catches a child whose self-sum disagrees with
the parent's sum (a child arithmetic bug); the folded row does not.

---

## 4. P3 — `post_grav`, a field no pin and no report reads

`_child_step_stamp` computes `post_grav` (`"real"`/`"other"`) and prints it in
its own `CHILD_NOTE`. It appears in **no** `CHILD_RESULT` token, **no** parent
expect dict, and **no** table of `reports/round-87/r87-author.md` §3 (whose
token table is `step_pre, grav_pre, damp_pre, step_post, damp_post, cc_off,
cc_on, last_step`). The step-stamped claim's pinned witnesses are `grav_pre`
(zero on GodotPhysics / real on Jolt), `damp_pre` and the pinned `post_damp`;
the uncited field is the only thing deleted, and the note keeps its
`post=<step>/<damp>` shape. No marker and no battery row moves.

---

## 5. G — the BLOCKED gate fold (total, 14/14)

Every gated arm carries the same three-line exit:

```gdscript
			if not _engine_hint_has("Jolt Physics"):
				_quit_clean(1, "BLOCKED phys3d_events body_handle jolt_absent=true")
				return
```

14 copies (6 landed r83–r86, 8 added by r87). `variants/v_G.gd` folds only the
8 r87 copies (−101 B); **the proposed fold is the total one** — the helper
serves all 14 identically, so the "two conventions" objection that limits the
emit fold does not apply here. The r85 seat measured this same fold at 3 sites
and rejected it *only* because the 5-line helper cost more than the 3 sites
saved (VA: +1 line / +147 B); at 14 sites the arithmetic inverts, and r86 SP2
folded 17 exits the same way.

**Proof.** The battery never exercises a `BLOCKED` gate on this host (Jolt and
Dummy are both present), so `tools/ab_gates.py` stubs `_engine_hint_has` in
*both* trees — `absent_all` (exercises the Jolt/Dummy-only gates) and
`dummy_absent` (exercises the Dummy gates) — and runs all 11 gated arms: 22/22
cells identical in stdout, rc and `.gd:<line>`-normalized stderr (§8.3), with
the BLOCKED lines verbatim (`BLOCKED phys3d_events body_handle jolt_absent=true`
etc.). The fold's own expansion is checked statically (GATE 14/14, §1).

---

## 6. E — the emit-block fold (r87 scope)

The six r87 child bodies emit 44 `CHILD_RESULT`/`CHILD_NOTE` lines, every one
the shape `prints("CHILD_RESULT %s_<key>=<fmt>" % [prefix, …])`. The fold
replaces them with one `_emit(prefix, key, value)` / `_note(prefix, text)` pair,
so that shape exists once in the arms the round added.

**Text-identity is proven twice.** Statically: 42/42 folded calls in `vfold`
re-expand to base sites in order (44/44 for `v_E` alone; the two fewer are
exactly P1's and P2's deleted emits). Dynamically: every child's `CHILD_RESULT`
map and `CHILD_NOTE` list is byte-identical between the two runs except the six
logs whose *tokens* P1/P2/P3 delete (§8.2) — i.e. the folded emitter produced
byte-identical text for all 29 child logs.

**Why this scope.** A *total* fold is impossible with one helper: 4 sites carry
no prefix argument (`_child_threaded`'s `early_null`, `PPQueries`' two sites,
`_child_jolt_threaded`'s `jt_threaded`) and 11 further notes are
`CHILD_NOTE %s_<key>=…` rather than `CHILD_NOTE %s <text>`; expressing those
needs a second helper, and the arithmetic is a wash (~+130 B of helper against
~−130 B of sites). Since *every* scope is therefore partial, the scope is a
blast-radius question, and the fold takes the smallest radius that removes the
duplication inside the audited arm. `variants/v_Epre.gd` (all 60 prefixed sites,
−579 B) is delivered as the measured wider option and replayed on all 25
`phys3d_events_*` rows: **25/25 PASS, 0 diffs over 300 fields** against the
control run.

---

## 7. Rejected with measurement

| candidate | measurement | why rejected |
|---|---|---|
| `Epre` (60 sites, all prefixed) | −4 lines / −579 B | Optional wider fold: +287 B over `E` for 16 pinned r83–r86 sites and backtrace line shifts in 6 further child logs (auplain, aujolt, btplain, btjolt, floorreal, wl). Delivered as a variant + a 25/25 focused replay, not folded. |
| `Eall` (all 75 sites) | impossible | 4 sites carry no prefix argument and 11 notes are `%s_key=` shaped; a second helper is a wash. |
| `bt_dummy_impulse`, `bt_dummy_lshape_oob` | forced by `bt_dummy_cc="0"` | They *are* dead pins (the child initializes `"nil"`/`"absent"` and only overwrites inside `if cc > 0`), but the parent compares the whole verdict dict and the emit line is shared by the three body_tier rows: deleting the Dummy pins would delete the real split's emit. |
| `_child_freed_space` `ray=nospace` tail `:2751-2752` | unreachable on this build (all three spawned backends take the ray path) | It is the guard that keeps a null `sp` from becoming an unguarded deref — the r86 hang class — and a named refusal instead of a silent zero. Same ruling as r86's `_child_tier` retry bail ("unexercised but not dead"). |
| 24-frame acquire loop + `held == null` bail ×2 (`:2480-2488`, `:2604-2613`) | unexercised on this build | Named bail; r84 V4/V5 + r85 VC + r86 rulings. |
| `_backend_name()` `"unexpected"` floor `:2167` | 1 line | Total-function floor of a three-way ClassDB gate (r86 ruling). |
| two `*_allow := ["Body state is inaccessible"]` literals → one `const` | +18 B / +1 line | Weight up: the const (54 B) costs more than the two sites save (36 B). |
| two `"refused" if … else "granted"` predicates → helper | +25 B / +4 lines | Weight up: the helper (91 B incl. its two blank separators) against 66 B of sites. |
| `_spawn_child` err-check fold (14 r87 sites) | — | `_fail` must stay in the arm's frame (r85 VE: the failure backtrace gains a frame). |
| `first_i`, `impulse_raw` (body_tier), `rows` (write_loss) | 0 lines | Note-only like P3, but each is *cited* as evidence by `r87-author.md` (§4, §5). Kept. |
| the r87 header-comment block (`:121-158`) | −37 lines / ~−2.6 KB | It is the file's own arm enumeration (every arm since r83 is listed); a complete enumeration is the convention, and the r85 VS deletion targeted an *incomplete* one. |
| explicit default args at 7 r87 `_spawn_child` sites | ~−100 B | Forced by GDScript's positional-only default parameters; reordering would break the r83–r86 call sites. |
| `dummy_cb=never` (critic F5: "the marker's `never` outruns the gate") | 1 token / ~−16 B | **Not folded.** It is the Dummy floor's only marker-level claim; the critic's finding is that it is unearned, and the fix is to *pin* the fired count (an addition), not to delete the floor's claim. Recorded here as an open item for the fold lane. |
| `held_live` (critic F5: "stale-satisfiable") | — | A distinct measurement (transform equality across detach) with a naming weakness, not a redundant predicate. Not weight. |

---

## 8. Behavioral evidence

### 8.1 Phase 1 / Phase 2 — 201/201 both phases

```
phase 1 (control, committed bytes)   runs-control/20261014T215656944804Z/verdicts.json
  verdict PASS  totals cases=201 pass=201 fail=0 ordinary=155 negative_controls=46
  seeds_unchanged=true  seed_digests.phys3d_events.gd=0e5e64f4…  run_battery.py=45b1ea86…
phase 2 (fold, folded bytes)         runs-vfold/20261014T220217401209Z/verdicts.json
  verdict PASS  totals cases=201 pass=201 fail=0 ordinary=155 negative_controls=46
  seeds_unchanged=true  seed_digests.phys3d_events.gd=d6c08908…  run_battery.py=f9e31098…
independent cross-check (r87-baseline phase 2, committed bytes):
  corpus/live/r87-baseline/runs-post/20261014T215119929090Z  verdict PASS 201/201,
  same seed shas, seeds_unchanged=true
12-field row comparison (cmp_rows.txt): 4 diffs over 2412 fields (201 rows) —
exactly the two intended marker changes, each in `marker` and in `stdout`:
  phys3d_events_body_handle  … twin=true dummy_cb=never …   (two_fetch=true removed)
  phys3d_events_write_loss   … same_turn=8 race=bounded …   (tally=8 removed)
no other row moved. `command` differs on all 201 rows (per-run scratch path).
```

### 8.2 Prior 195 rows and child logs

```
prior rows (r87-baseline tools/postcommit_verify_godot_prior.py vs
prior-195-godot-rows.json, sha dd8812be…):
  ordered-subsequence: PASS (195/195 matched)
  identical positions: 195/195
  inserted/new rows: 6 — exactly the r87 cells, in order, all PASS
child logs: 29 per tree, identical names.
  CHILD_RESULT map + CHILD_NOTE list identical in 23/29. The six that move are
  exactly the folded tokens:
    bhplainproj / bhjoltproj / bhdummyproj  (- two_fetch, map + note)
    ssplainproj / ssjoltproj                (- the post_grav field of the note)
    wlproj                                  (- tally, map)
  the remaining two content diffs are fsplainproj / fsjoltproj — the crash
  children, whose logs ALSO differ between two runs of the IDENTICAL bytes
  (control vs baseline-post: the same two logs; ASLR load address + backtrace
  addresses), i.e. run-variable, not fold-caused (childlog_variability.txt).
  .gd:<line> backtrace numbers shift in 7 logs (thrproj, joltthrproj,
  floorrealproj, auplain, aujolt, btplain, btjolt) because every folded gate
  block and every deleted pin line sits above them — the r84 V2 / r85 / r86
  normalization class. Every map is otherwise identical, so the folded emitter
  is proven byte-identical at runtime.
```

### 8.3 BLOCKED-path A/B (`ab/`, `ab_verdict.txt`)

```
mode absent_all  : _engine_hint_has -> false      (Jolt/Dummy-only gates)
mode dummy_absent: _engine_hint_has -> engine != "Dummy"   (Dummy gates)
11 gated arms × 2 modes = 22 cells, base tree vs fold tree:
  22/22 IDENTICAL in stdout, rc and .gd:<line>-normalized stderr
  BLOCKED lines verbatim, e.g. BLOCKED phys3d_events body_handle jolt_absent=true,
                              BLOCKED phys3d_events dummy_refused dummy_absent=true
  the only raw stdout difference is write_loss's marker token in both modes
  (that arm has no gate; the difference is the intended P2 marker edit)
AB VERDICT: PASS
```

### 8.4 Mutation differential (`mutations.txt`)

```
author's 6-arm matrix, re-run against the FOLDED bytes:
  M1-reps (acq_use)            detected  (acq_use plain drift)
  M2-live-space (freed_space)  detected  (freed_space plain rc=0 not signal-class)
  M3-late-impulse (body_tier)  detected  (body_tier plain drift)
  M4-no-contact-optin (step_stamp) detected (step_stamp plain drift)
  M5-no-detach (body_handle)   detected  (body_handle plain drift)
  M6-in-phase-write (write_loss) detected (write_loss drift)
  → 6/6: the fold preserved every row's detection power.
deleted-pin ablations (applied to the BASE tree, where the pins still exist):
  A1-two_fetch: force two_fetch=false -> base row FAILS (caught by the pin)
  A2-tally    : make the child's self-sum disagree -> base row FAILS
  in the folded tree both anchors are ABSENT (the predicate is not measured at
  all) — the disclosed residual of P1/P2, not a hidden one.
```

### 8.5 Retained-conjunct survival (4 cells) — and the probe seat's outcome

The frozen `probeParent` seat's single read-only `labrat` probe was dispatched
for this hypothesis and **returned no evidence**: that seat's toolset exposes
`read`/`grep`/`glob` only (no shell, no write), so it answered with a *static
trace* and left every cell unexecuted. The trace is recorded here as inference,
never as evidence; the four cells were then run by this seat
(`tools/retained_probe.py`, scratch `retained-probe/`):

```
H: after the fold, each deleted pin's class is still caught by a retained conjunct.
base/A arm=body_handle exit=1 caught=yes  ERROR: … body_handle plain drift …
     v={ … "bh_plain_reattach": "false", "bh_plain_two_fetch": "true" }
fold/A arm=body_handle exit=1 caught=yes  ERROR: … body_handle plain drift …
     v={ … "bh_plain_reattach": "false" }            (two_fetch token absent)
base/B arm=write_loss  exit=1 caught=yes  ERROR: … write_loss drift …
     v={ … "wl_plain_landed": "0", "wl_plain_lost": "8", "wl_plain_tally": "8" }
fold/B arm=write_loss  exit=1 caught=yes  ERROR: … write_loss drift …
     v={ … "wl_plain_landed": "0", "wl_plain_lost": "8" }
H: CONFIRMED — 4/4 cells caught
```

Two facts in that raw output matter. (1) The folded rows fail for the *same*
reason as the base rows (`body_handle plain drift`, `write_loss drift`), so the
identity law and the non-drop witness survive P1/P2 with a retained conjunct
doing the catching. (2) In **base** cell B the deleted `tally` pin *passes*
(`"wl_plain_tally": "8"`) while `landed >= 1` fails — the tally pin never caught
this class in the first place, which is the reviewer's §11.2 "bookkeeping
identity" finding reproduced at runtime. Each cell's mutated source sha256 and
scratch path is in `retained-probe/retained_probe.txt`.

---

## 9. Preserved contract

Under `vfold`: all 201 markers and exit codes, every child verdict map, the
prior 195 rows at identical positions, the four probe surfaces' shapes, the
BLOCKED text verbatim, the crash classes and rc disjunctions, the Dummy floor
signature, every `CHILD_NOTE` field except `post_grav`, and every provenance
comment. The two marker strings that change (`body_handle`, `write_loss`) lose
exactly the tokens P1/P2 delete and are updated in `run_battery.py` in the same
diff; **no prior row's marker changes** and the six r87 rows keep their
insertion-only positions.

## 10. Receipts

`corpus/live/r87-simplifier/` (gitignored), documented in its own `README.md`:
`base/`, `vfold/`, `tree-Epre/` (55 files each), `fold.diff`, `variants/`,
`variants.json`, `tools/` (`mkfold.py`, `mkfold_bat.py`, `emitlib.py`,
`verify_fold.py`, `mkvariants.py`, `compare_runs.py`, `ab_gates.py`,
`mutations_fold.py`, `retained_probe.py`), `runs-control/`, `runs-vfold/`, `runs-epre/`, `ab/`,
`mutation-scratch/`, `cmp_rows.txt`, `cmp_epre.txt`, `prior_rows.txt`,
`childlog_variability.txt`, `ab_verdict.txt`, `mutations.txt`, `retained-probe/`, `control.log`,
`vfold.log`, `epre.log`.

## 11. Risks, provenance, blockers

1. **Two marker strings change** (`body_handle`, `write_loss`). They are r87
   rows, not prior rows; `run_battery.py` is updated in the same diff. The r87
   author's report §9.2 and the reviewer/scribe reports quote the *old* strings
   — after a fold those quotes are historical, and the fold lane's own receipt
   is the one that carries the new markers. No README text quotes them.
2. **P1 and P2 give up a child-side cross-check** (ablations §8.4). The
   engine-state claims are unchanged; an inconsistent *child print* is no longer
   caught by those two tokens. P2 is independently supported by the reviewer's
   §11.2 and the critic's F4; P1 is the one candidate where a sibling seat's
   wording (critic F5) can be read against the deletion.
3. **Backtrace line numbers shift in 7 child logs** (and the two `fs*` crash
   logs are run-variable between *any* two runs, measured). Every child verdict
   map is identical; a downstream comparison must normalize `.gd:<line>`.
4. **The BLOCKED path is proven under a stubbed hint**, not by the battery (this
   host has Jolt and Dummy). The A/B is the r86 SP2 §4.3 shape.
5. **No probe flags were run by this seat** (`--probe-failing` etc.); the folded
   `run_battery.py` differs only in the two marker strings, and the baseline's
   phase-2 receipt carries the probe evidence for the committed bytes.
6. **One host, one build** (`4.7.2.stable.arch_linux.ed1daf0bf`), `--headless`,
   60 tps, no display.
7. **The fold is a proposal.** This seat made no tracked edit, no commit, no
   push; the fold lane applies `fold.diff` (or not) and owns the commit.
8. **Blockers: none.** The batteries are green in both phases, the prior rows
   are untouched, and the two optional shapes (`v_Epre`, `v_G`-only) are
   measured and replayable from the receipt tree.
