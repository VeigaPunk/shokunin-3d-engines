# r96 critic — adversarial review of the committed Jolt fixed-fps/determinism landing (`dd054a2`)

Seat: **GAME-DEV-3D r96 CRITIC** (frozen `probeParent`). Attacked artifact: commit
`dd054a24af91c3cac84826f5df5ce5efa9e88429` — `corpus/fixtures/r96_joltdet.gd` (+873, new),
eight `corpus/fixtures/r96_probe_{iters,pen,warm,damp,rest,kin,srvjoint,settings}.gd`
(new, byte-identical to the r96-scout probes), `corpus/fixtures/run_battery.py` (+30/−0,
insertion-only), `reports/round-96/r96-author.md` (+224); **316 battery rows** (257 ordinary
+ 59 negative controls), the 12 r96 rows are rows **305–316** (contiguous, last). Author,
scout, boundary reports and `corpus/live/r96-{author,scout,boundary}/` receipts were read
(never written). Nothing tracked was written; no commit was made.

Environment (`corpus/live/r96-critic/env.txt`): `/usr/bin/godot`
**4.7.2.stable.arch_linux.ed1daf0bf**, `/usr/bin/python3` **3.14.7**, kernel 7.2.3-arch1-3,
AMD Ryzen 9 9950X (32 threads). The box ran **loaded for the whole seat** — load1 **52.5 →
88.9** (72.0 at report time) — with concurrent sibling lanes observed live: `r96-scribe`
(full battery on the committed tree), `r96-verifier` (full battery), `r96-reviewer`,
`r96-simplifier` (the r96 fixture itself, `probeA2`), plus 2D-lane batteries. Every r96
measurement below is therefore a **loaded-host** measurement; a quiet baseline was not
available (the same caveat the boundary recorded).

**No `lsp`/symbol device is exposed to this seat's toolset** (the same recorded absence as
r85–r95); no source edit was needed or made — the seven mutations ran on **copies under the
gitignored receipt dir**, never on a tracked file.

**probeParent seat:** exactly one read-only `ufo-labrat` was dispatched (static consistency
probe: “every field name and literal in the 12 committed markers is derivable from the
fixture’s own ARMS table/code”). Its report is folded into §1.2/§1.9; no other descendants,
nothing edited.

---

## 0. Verdict

**PASS — the landing survives attack on the committed bytes, with two LOW findings.** Every
r96 row reproduced on the frozen committed tree (full battery **315/316, 12/12 r96**; three
independent r96-only runner passes **12/12 each**, one of them on a frozen copy with
`seeds_unchanged=true`; three direct arm sweeps **36/36 arm runs byte-identical to the
committed markers**), all **93 generic digest cells and all 6 special arms were
independently re-derived from the raw child logs** the fixture leaves behind (not restated
from the PASS line), **6 of 7 mutation probes are rejected by the pins they target**, and the
Dummy hang precondition reproduces independently (rc=137 4/4, 12–21 MB of error spam against
a 128 KiB cap). No r96 row reddened in **108 row executions of mine** (36 sweep + 24 hammer
+ 12 full-battery + 36 runner passes) nor in the author’s 6 runs (72 row executions).

The two LOW findings are coverage/wording, not reproducibility defects: **F1** — the `thread`
row cannot detect a dropped `3d/run_on_separate_thread` line (mutation M8 is *accepted*);
**F2** — the `sj_node_init@*` cells pin `space_a/space_b` values that are *identical* on both
backends, so the drop-vs-bind trap is carried only by the hashed trajectory. The four INFO
observations are pinned below.

**Blockers: none.** The one permitted `labrat` probe returned a static reading (its profile
has no shell/exec — the same limitation the r94/r95 critics recorded); it found no marker
inconsistency, and no evidence gate is left open.

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | insertion-only, prior rows untouched | **CONFIRMED** (byte level) | §1.1: one `insert` opcode, 30 lines, 0 modified/0 deleted; old CASES block is an exact prefix |
| 2 | row/cell arithmetic vs the reports | **CONFIRMED** | §1.2: 316 rows, 12 r96 at the tail, 123 cells, 160 children/pass |
| 3 | reproduce the 12 rows on the committed bytes | **CONFIRMED** | §1.3: full battery 12/12 r96; 3 × r96-only 12/12 (one frozen, verdict PASS); 3 × 12-arm sweeps 0 diffs |
| 4 | is the evidence real (cells = child logs)? | **CONFIRMED** | §1.4: 93/93 digest cells + 6/6 special arms re-derived from raw logs with an independent Python scanner |
| 5 | are the pins load-bearing? | **CONFIRMED for 6/7** | §1.5: M1/M2/M3/M4/M6/M7 rejected; **M8 accepted** (F1) |
| 6 | mandated encoding 1: warning expected-error class | **CONFIRMED** | §1.6a: optional class (0–3 of 6 per run, positions 16–19), normalized identity holds, wildcard mutation rejected |
| 7 | mandated encoding 2: `--time-scale` = tps law | **CONFIRMED** | §1.6b: 6/6 pairs sha-equal, ts side at 60 tps vs the 120/30-tps bakes, both under `--fixed-fps 60` |
| 8 | mandated encoding 3: Dummy vacuity + hang | **CONFIRMED** | §1.6c: 5/5 live in-cell triples; hang rc=137 reproduced 4/4 with ≥100× margin over the cap |
| 9 | report-accuracy spot checks | **CONFIRMED** | §1.7: all 9 hashes, the 13/36 warning census, the 3/6 nc class, the sweep1 `warm_stack@jolt` 1/3 instability, the four battery runs |
| 10 | flake hunt on the load-shaped arms | **CONFIRMED stable** | §1.8: dummy/nc/ffps hammered; 0 marker deviations |
| 11 | FAILs outside the documented flake list | **one, pre-existing, non-causal** | §1.8: `navagent3d_detour_mut_ladder_region` (passes in isolation) |
| 12 | hygiene: seeds, strays, tracked writes | **CONFIRMED** | §1.9: no tracked write; no orphan of this lane; the one seed-guard trip is a sibling lane’s r97 fixtures |

---

## 1. What I verified (and how)

### 1.1 Byte-level insertion-only

`git diff dd054a2^ dd054a2 -- corpus/fixtures/run_battery.py` is a **single `insert`
opcode** `old[738:738] → new[738:768]` — 30 new lines, **0 modified, 0 deleted** — and the
old `CASES` block (304 tuples) is an **exact prefix** of the new one. The 11-file
commit is 9 new fixtures + the insertion + the report; no other file in the commit is a
modification. The 12 r96 rows are the last 12 entries of `CASES`, in the order the fixture
emits them.

### 1.2 Row/cell arithmetic (report claim vs artifact)

`import run_battery` on the committed bytes: **316 CASES = 257 ordinary + 59 negative**;
`r96_joltdet_{joint,contact,restkin,tps,solver,mech,tscale,ffps,dummy,thread,knobs,nc}` are
the final 12. The fixture’s ARMS table plus the six special arms produce **123 digest cells**
(12+16+15+26+17+7+6+3+6+10+4+1) and **160 children per battery pass**
(12+16+15+26+17+7+12+10+18+20+3+4) — both matching the author report. My own child-dir
census per arm reproduced the per-arm child counts exactly (12, 16, 15, 26, 17, 7, 12, 10,
18, 20, 3, 4), each arm under a single parent pid.

### 1.3 Reproduction on the committed bytes

- **Full battery, live tree** (`corpus/live/r96-critic/battery/20261016T005555517691Z`):
  **315/316 case-level, all 12 r96 rows PASS** (elapsed 1.27–7.82 s each, all far inside the
  20 s bound; total case wall 549.7 s). The single red is **pre-existing**
  (`navagent3d_detour_mut_ladder_region`, a r93-era navagent row: `step2 idx=0 expected=1`);
  it **passes in isolation** (3-case re-run, §1.8) — a load-shaped flake on a row this round
  did not touch. The run-level verdict is `FAIL` **only** because the seed-integrity guard
  fired: a sibling lane added **11 `r97_*.gd` files to `corpus/fixtures` mid-run** (22:00:46,
  i.e. inside my run window; 0 changed, 0 removed — the guard is behaving correctly, the
  event is cross-lane, not r96).
- **r96-only through the real runner**, twice on the live tree
  (`r96only/20261016T005930084832Z`, `...T010621357946Z`): **12/12 PASS** each (the same
  cross-lane seed guard trips the run-level verdict there too).
- **r96-only on a frozen copy of the committed bytes**
  (`frozen-runs/20261016T010704718044Z`): **12/12 PASS, verdict PASS,
  `seeds_unchanged=true`** — the clean, self-contained pass.
- **Three direct 12-arm sweeps** (`arms/`, `arms2/`, `arms3/`): **36/36 arm runs rc=0 and
  every `PASS r96_joltdet …` line byte-identical to the committed `CASES` marker** (0 diffs).
- The working-tree r96 files are **byte-identical to the `dd054a2` blobs** (9/9, sha256 of
  `git show dd054a2:<path>` vs the file).

### 1.4 Evidence integrity — the cells are re-derived, not restated

I mirrored the fixture’s scanner (`_scan_lines`/`_field`/`_sum_line`/pose-hash) in Python and
recomputed every cell **from the raw `child.log` files the fixture left in its scratch**:

- **93/93 generic-arm cells** (`joint` 12, `contact` 16, `restkin` 15, `tps` 26, `solver` 17,
  `mech` 7): the printed `sha` is exactly `sha256("\n".join(normalized_stream))[:16]` of that
  child’s log, and **every printed field value** sits on the exact line the fixture says it
  reads (the first SUM-prefix line / the extra line) — including the comma-valued `imp=…`
  triple. Zero problems.
- **Special arms, all re-derived**: `tscale` 6/6 pairs sha-equal with the ts child project at
  60 tps and the ref at 120/30 tps; `ffps` 6/6 jolt reps share one normalized sha and equal
  the **no-flag** twin, GP’s two reps + twin raw-identical with 0 warnings; `dummy` 5/5
  `d/gp/jolt` triples live and non-empty (the hang child’s log is removed after the capped
  scan, as designed, and the GP/Jolt controls still quit with `slept_at=126/144`); `thread`
  10/10 sha-equal with `run_on_separate_thread=true` present in every `thr` child
  `project.godot` and absent in every `ref`; `knobs` 67 keys with one name-hash on all three
  backends (`874d8759ff135309`); `nc` 4/4 reps share one pose sha (`298e8a9a00657651`,
  324 W-lines).
- The probe copies are **byte-identical to the scout’s** probes and to the `proj/` copies
  that actually ran (`cmp` 8/8 vs both), which is what makes the child receipts reproduce
  the scout’s.

### 1.5 Pin sensitivity (mutation battery, copies only)

Seven mutations, each applied to a scratch **copy** of `corpus/fixtures` and run for one arm
(`corpus/live/r96-critic/mutations.log`):

| mutation | defect it simulates | arm | result |
|---|---|---|---|
| M1 | the `gp120` bake is really 60 tps | `tps`, `tscale` | **rejected** (both) |
| M2 | `position_steps=0` → `8` on `jolt_p0` | `solver` | **rejected** |
| M3 | hang cap 128 KiB → 100 MB | `dummy` | **rejected** (`truncated=0`) |
| M4 | warning allowlist becomes a wildcard for `WARN1` | `ffps` | **rejected** (`reject=0`) |
| M6 | the Dummy column runs the GP bake | `dummy` | **rejected** (`d=` values move) |
| M7 | the `--time-scale` flag is dropped | `tscale` | **rejected** (`eq=0`) |
| M8 | the thread knob is **not set** in the `gp_thr` bake | `thread` | **ACCEPTED → F1** |

### 1.6 The three mandated encodings

**(a) The Jolt `--fixed-fps` warning is an expected-error class, not a pinned count.** Eleven
direct observations (3 sweep arms + 8 hammer runs) saw it **0–3 times per 6 reps**
(1/6 pos 17; 3/6 pos 16,17,17; 1/6 pos 16; hammer 2,1,2,1,3,3,0,2 — every position 16–19),
and the normalized sha never moved (`4492126fd9b2b3f3` in every run, equal to the no-flag
twin). The scanner self-gate is a deterministic unit test (`allow=1,reject=1`) and M4 shows it
is load-bearing: widening the allowlist to the warning *head alone* turns the row red. The
class is honestly optional — the row pins the *normalized identity* and censuses the count in
`#` diagnostics.

**(b) `--time-scale` is the tps law, measured under `--fixed-fps 60` on both sides.** All six
pairs sha-equal (e.g. `pin_ts05 sha = d24077db012d9045 =` the `it_pin@gp120` cell of the tps
row), the ts side runs in the 60-tps bake with the flag and the ref side in the 120/30-tps
bake without it, and the equivalence is non-trivial (M7 → `eq=0`; M1 → `eq=0`). This closes
the boundary’s “`--time-scale` × `--fixed-fps` not tested” item for these cells.

**(c) Dummy vacuity with live in-cell controls, plus the bounded hang.** Five cells carry the
Dummy/GP/Jolt readings side by side from the same cell (all re-derived above); the sixth pins
the reuse hazard as a precondition: `sleep1{dummy_rc=137,hang=1,nodsum=1,d0=1,gp_slept=126,jolt_slept=144}`.
Independently reproduced 4/4: `timeout -s KILL 2` on the fixture’s own dummy child project
gives rc=137 and a **12.2/17.3/19.7/21.0 MB** error-spam log (`SCRIPT ERROR: Invalid call.
Nonexistent 'bool' constructor.`, no `DSUM`, `D0` present) — ~100× the 128 KiB cap. M3 shows
the cap/truncation term is load-bearing (a 100 MB cap → red).

### 1.7 Report-accuracy reconciliation (author receipts re-read, never trusted)

- All 9 fixture hashes in `r96-author.md` match the committed files; the 8 probe copies
  `cmp`-identical to the scout’s.
- The warning census **“13/36 receipts (2,2,2,2,2,3 per parent run) at positions 16–19”**
  reproduces **exactly** from `runs/sweep2/ffps.r*.txt` (2+2+3+2+2+2 = 13, positions 16–19).
- The nocache class **“3/6 parent runs, 39/324 ticks each”** reproduces exactly from
  `runs/sweep2/nc.r*.txt` (39/324 in r1, r2, r5; 0/324 otherwise). My own direct runs saw
  the same class at the same amplitude: 39/324 in 2 of 8 hammer runs, 0/324 in the other 6
  and in all 3 sweeps — consistent with a censused, unpinned class (§1.8).
- The `warm_stack@jolt` story checks out in the receipts: **sweep1 (full-sha encoding) was
  1/3 unstable** (`f07717cee9da1846` ×2, `567e8d885de7408c` ×1), after which the pose-only
  `psha` was **6/6 stable in sweep2** and in all my runs — the author’s fix is the thing that
  made it stable, and the report says so.
- The author’s four full battery runs are `315/316, 313/316, 315/316, 316/316` with **12/12
  r96 in every one**, and the `crosscheck-run1.log` is `match=93 missing=0 differing=0` —
  the report’s numbers are traceable to receipts.
- The `runs/fps{1,2,5,10,30}.r*` receipts corroborate “the warning is a `--fixed-fps`
  artifact, not an fps-value artifact” (0–3 warnings per 4 receipts at every rate, never
  without the flag).

### 1.8 Flake hunt (load-shaped arms) and the one pre-existing red

`dummy`, `nc` and `ffps` — the three arms with timing/batch-shaped surfaces — were hammered
**8× each** (`hammer/`, `hammer/wall.txt`, `check_hammer.py`): **24/24 runs rc=0 with the
committed marker, 0 deviations**. The hammer notes are the decisive load evidence for the
two *censused* classes: the Jolt warning appeared **0–3 times per 6 reps (2,1,2,1,3,3,0,2)
always at positions 16–19** while the normalized sha and the no-flag twin stayed
`4492126fd9b2b3f3` in all 8 runs, and the nocache all-zero impulse class fired
**39/324 ticks in 2 of 8** runs (0/324 in the other 6) while `pose_eq` stayed 1 in all 8.
Combined with §1.3 that is **108 green r96 row executions of mine under loadavg 52–89**, and
the two quantities that *do* drift are exactly the ones the rows census instead of pin.

The only red row I produced anywhere is **pre-existing**:
`navagent3d_detour_mut_ladder_region` failed inside the loaded full battery with a *semantic*
assertion (`step2 idx=0 expected=1`, not the documented `before=1.754246` one-tick
signature) and **passed when re-run in isolation** (3-case run; in the same window
`navagent3d_retarget_fixed` failed with the documented `before=1.754246` signature — the
known load flake). Neither row is touched by this round.

### 1.9 Hygiene, seeds, and the labrat

No tracked file was written by this seat (`git status` shows only the sibling r97 fixtures
and two pre-existing untracked reviewer reports). No godot/`timeout` child of this lane
survives; the fixture’s child processes are correctly parented (`sh → timeout → godot`) and
each is bounded. The fixture writes only inside the battery’s per-run scratch (pid-namespaced
child dirs) and removes the one capped hang log after scanning it. The single
`seeds_unchanged=false` in my runs is the **sibling lane’s r97 fixture additions** (11 files,
0 changed, 0 removed) — a cross-lane event the guard caught correctly. The one permitted
`labrat` (static, read-only) walked all 12 markers cell-by-cell against the fixture’s ARMS
table and the six special-arm code paths and returned **CONSISTENT — no inconsistency**: no
typo’d/extra field, no wrong `@`-suffix, no missing or extra cell, no literal the code cannot
produce (it independently confirmed `reps=6/2/4`, `keys=67`, `dummy_rc=137` from the code
paths, that `tps/warm_rest` pins only `imp` (not `lv`), and that the contact arm’s `psha` and
the `nc` arm’s `pose_sha` are two different code paths both correctly named). Caveat it
recorded: sha digests and measured floats are runtime outputs, so it plausibility-checked
them statically only — my §1.4 re-derivation is the runtime half. Its profile has no
shell/exec, recorded as in r94/r95.

---

## 2. Findings (ranked)

**F1 — LOW (a coverage blind spot in the `thread` row).** `r96_joltdet_thread` pins
`eq=1` for ten ref-vs-threaded pairs, but the *row itself* never verifies that the threaded
bake actually carries `3d/run_on_separate_thread=true`; it only proves “the `gp_thr`/`jolt_thr`
child is receipt-identical to the baseline child”. Mutation **M8** (drop `THR` from the
`gp_thr` project string) is **accepted** — both children become the baseline and `eq=1`
still holds. Mitigations (verified, not assumed): the bake is built from `PROJECTS[...] + THR`
by construction, the settings dump lists `physics/3d/run_on_separate_thread` as a real bool
setting, and I checked all 20 child projects directly — the knob is present in every `thr`
bake and absent in every `ref`. So the *landing* is sound; the residual risk is a future
refactor that silently drops the knob line and keeps a green row. **Recommended fold
(author’s call):** print the effective value in the cell (the `settings` probe already
reads it) or add a `# thr_knob=1` diagnostic. Non-impact: the receipt-identity claim the
report actually makes is unaffected.

**F2 — LOW (a pinned field that does not discriminate).** The `joint` row’s node-body-joint
trap cells pin `space_a`/`space_b`, which are **identical on both backends** for
`node_init` (`RID(0)` on GP *and* Jolt — my re-derived logs), so the drop-vs-bind difference
lives **only in the hashed trajectory** (`J t=12 y=1.821328` on GP, i.e. dropped, vs
`y=2.796224` on Jolt, i.e. bound; `srv` binds on both). The report’s compressed phrasing
“the node-body joint trap (GP `space_a=RID(0)`, Jolt binds)” can be misread as the field
being the discriminator. The pin is real (the sha covers the whole stream and differs), so
this is a wording/reader-risk finding, not a defect. **Recommended fold:** state that the
readback is `RID(0)` on both and the trap is carried by the trajectory.

**F3 — INFO (`props=67` is the `physics/` surface, not all settings).** The knobs cell prints
`props=67,keys=67`; `props` is the probe’s `physics_props` count while
`ST total_props=949`. Correct as measured, easy to misread. The row’s actual claim (the 67
`physics/` key **names** are backend-independent) is verified.

**F4 — INFO (the hang pin’s `truncated` term is arm-shape dependent — and fails closed).**
Under the fixture’s `--fixed-fps 60` arm the spam is 12–21 MB per 2 s window (n=4) ⇒ ~100×
margin over the 128 KiB cap; the boundary’s own no-flag receipt is **431 KB / 25 s ≈ 17 KB/s**
(real-time pacing), which in a 2 s window would be ~34 KB — below the cap, i.e. the row
would go **red**, not vacuous, if the flag were ever dropped. The author’s “27 MB” and the
boundary’s “431 KB” are both explained by the arm shape (fixed-fps runs unthrottled).

**F5 — INFO (the run-level FAIL in my full battery is cross-lane).** `seeds_unchanged=false`
is 11 `r97_*.gd` files added to `corpus/fixtures` **mid-run** by a sibling lane (22:00:46;
0 changed, 0 removed). Case-level 315/316 with 12/12 r96. The guard firing is correct
behaviour; the event is not attributable to this landing.

---

## 3. Residual risks (bounded, not findings)

- **No quiet-host baseline.** Every measurement here (and the boundary’s) is on a loaded
  host (load1 52–89). The r96 pins are tick-indexed and the boundary measured 58/58
  byte-identical under 14 hogs, so load-invariance is the best-supported reading; a
  truly-idle comparison remains untaken.
- **The `nc` zero-impulse class** is censused, never pinned: it fired **39/324 in 2 of my 8
  hammer runs** (0/324 in the other 6 hammer runs and in all 3 sweeps) and in 3/6 of the
  author’s sweep2 runs (39/324) — consistent with the disclosed class, and the pose-only pin
  stayed stable in every observation (11 direct of mine + the author’s 6-rep sweep + their
  full-run cells). The hammer is the load evidence the class needed: the row is green
  whether the class fires or not.
- **Engine-version brittleness.** Several pinned fields are implementation readbacks
  (`RID(94489280512)`, `slept_at`, exact `imp` triples) rather than laws; they are
  deterministic under `4.7.2.stable.arch_linux.ed1daf0bf` and would move on an engine change
  — the same property the whole battery already has.
- **Threaded gate in general** (r87/r88’s surface): only the 10 cells here are covered, and
  only under load, not under a thread-race amplifier.

## 4. Receipts

`corpus/live/r96-critic/` (gitignored): `env.txt`, `evidence.md` (command index),
`arms{,2,3}/` (3 × 12 raw arm receipts + markers), `hammer/` (24 runs), `battery/`
(full run), `r96only/` (2 runner passes), `frozen-runs/` (clean frozen-copy pass),
`muts/` (7 mutated scratch trees + outputs), `ftest/` (the scratch project the sweeps ran
against, with all child logs), `hang/` (4 raw hang reproductions), `navagent/` (the isolated
3-case re-run), `audit_cells.py`, `audit_special.py`, `mutations.py`, `check_markers.py`,
`check_hammer.py`, `armrun.sh`, `hammer.sh`, `audit-generic.log`, `audit-special.log`,
`mutations.log`, `sweep23.log`, `battery-run1.log`, `r96only-run1.log`, `navagent-run1.log`,
`knobs-1.out`.

Provenance: this lane wrote **only** `corpus/live/r96-critic/**` and this report. It read
`corpus/fixtures/**`, `corpus/live/r96-{author,scout,boundary}/**` and
`reports/round-96/r96-{author,scout,boundary}.md`; none was modified. No commit was made.
