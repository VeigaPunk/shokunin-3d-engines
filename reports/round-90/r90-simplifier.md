# game-dev-3d round 90 — simplifier (seat: simplifier, host: devin) — the repaired tree's own weight: −20 lines, 8 arms × 6 reps byte-identical, 8/8 pins intact

Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps. Receipts
under `corpus/live/r90-simplifier/` (layout + stale-artifact note in its
`README.md`). No tracked file touched; no commit. Baseline is the **repaired
working tree** (`git diff HEAD` on `phys3d_joints.gd` + `run_battery.py`),
not `191f131`.

## 0. Verdict

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **F1** | parent `_run_child`: `std::system_error` counter (`throw_`) + its dict key — write-only | **−3 lines** | census: the 3 lines are the only `throw` occurrences in the fixture dir; `_emit` reads rc/m/ne/nw/sig11 only; control C4 (injected `std::system_error` line: instrumented base parent reads 1×3, digest unchanged) | **take** |
| **F2** | parent `_run_child`: dirname sanitizer + `if dirname.length() > 0:` guard — unreachable for every declared arm | **−7 lines** | 51 dirname instances (8 arms × 17 cases × 3 backends), 0 unsafe chars (`guard-census.py`); control C3 forces the branch | **take with tradeoff** (drops a fail-closed refusal for *future* table edits — see §4) |
| **F3** | child `var c_rid: RID` — never read or written | **−1 line** | `dead-census.py`: 1 occurrence, 0 uses | **take** |
| **F4** | child `func bpos()` — no caller | **−5 lines** | `dead-census.py`: 1 occurrence, 0 call sites; `st()` stays (used by `wit()`) | **take** |
| **F5** | child: 19× `fmt(PhysicsServer3D.joint_get_type(x))` → one `jt(x)` reader | **+4 lines / −449 B** | all 19 sites are the same expression; every arm prints `jtype=`; 6-rep byte-identity | **take** |
| **F6** | child: `freeb_dyn` shares the `freeb`/`freea` handler (the dynamic-A distinction lives in `_initialize`'s `dyn_a`) | **−8 lines** | `free_pair` pins the freed endpoint in the t=7/t=8 traces; 6-rep byte-identity | **take** |
| **F7** | parent header paragraph still describes the pre-repair envelope (GP-only, `rcc`/`sig11` as emitted fields, "6-line prefix") | **−2 lines**, accuracy | reading the emitted token + the `BIMODAL` table; doc-exempt (arm bytes cannot discriminate a comment) | **candidate — separate patch `fold-doc.diff`** |

Totals: parent 189 → 179 lines (−358 B), child 356 → 346 lines (−838 B);
**−20 lines / −1196 B**, zero arm-output deltas. `fold.diff` and
`fold-doc.diff` both pass `git apply --check` against the repaired tree and
were **not** applied to it.

## 1. Baseline and the fold's proof protocol

- The repair (BIMODAL `mode_ok` envelopes replacing `GP_CRASH_CASES` /
  `GP_BIMODAL`) is in the working tree: parent `cd9f05fb…`, battery
  `be5663f7…`, child `05b2380b…` (child untouched by the repair).
- Vfold per the tasking: `cp phys3d_joints.gd + r90_child.gd` into a scratch
  dir with the minimal `project.godot`, then
  `godot --headless --path <scratch> --script res://phys3d_joints.gd -- --arm=<arm>`.
  Six scratch reps per variant (`vf-scratch-*/r1-r3`, `vf-extra-*/r4-r6`).
- **8 arms × 6 reps × 2 variants = 96 standalone arm runs.** Every arm: rc=0,
  exactly one distinct PASS line across its 6 reps, byte-identical base vs
  fold, and equal to the repaired `run_battery.py` pin:

  | arm | PASS-line sha256 (first 16) | arm | PASS-line sha256 (first 16) |
  |---|---|---|---|
  | sweep | `84e0a9abe19ffce9` | free_ops | `706ad9151452e18d` |
  | rid | `94a5ddaa4739e3da` | detach | `fe2743f8a825f289` |
  | api | `fb36001cbe41c661` | chain3 | `26912caaa4ee260f` |
  | free_pair | `a8f66074ea928699` | twopin | `f3a829393a088ab9` |

- **Battery end-to-end**: `run_battery.py --only <the 8 r90 rows>` on a full
  fixtures copy — base **8/8 PASS** (rc=0) and fold **8/8 PASS** (rc=0),
  `seeds_unchanged=true` (`bat-runs-base/`, `bat-runs-fold/`). No pin edit was
  needed for the fold.
- **Mode coverage**: the digest is byte-stable across realizations; both modes
  were *observed* on `freeb@gp` (base 1 crash / 5 clean, fold 1 crash / 5
  clean) and `freeb_twice@gp` (base 4 crash / 2 clean, fold 3 crash / 3 clean)
  — the two cells the verifier's reject turned on. In my 6 reps the other
  exposed gp cells realized crash-only (`freeb_ops@gp`, `freeb_dyn@gp`,
  `chain3_freemid@gp` 6/6 both variants) and `freea@gp` + every jolt cell
  clean-only (6/6); each still emitted the same digest in every rep.
- **LSP status**: no GDScript LSP server is configured on this host — the only
  MCP server (`rea`) is a binary-analysis server with no `references` device.
  Reference censuses here are therefore **textual** (`dead-census.py`,
  `guard-census.py`, `case-census.py`) and are never presented as semantic
  proof; the executable proof is the vfold plus the controls in §4.

## 2. The folds

**F1 — parent dead writer (−3 lines).** `var throw_ := 0`, the
`elif "std::system_error" in line: throw_ += 1` branch, and `"throw": throw_`
in the returned dict. The dict key is read by nobody: `_emit` consumes
`rc/m/ne/nw/sig11` only. Control C4: an injected
`print("std::system_error injected")` in the child makes the instrumented base
parent read `THROWDBG=1` three times (three backends), while the base+injected
and fold+injected detach PASS lines are byte-identical to their un-injected
counterparts (`6b928afb56080146`) — the counter was live but unobservable.

**F2 — parent unreachable guard (−7 lines).** `dirname` is
`"r90bt_%s_%s_%s" % [arm, case, bk]`, and its three inputs are the literal
tables `ARM_CASES` keys, `ARM_CASES` values, `BACKENDS` keys. Census: 51
instances, 0 characters outside `[0-9A-Za-z_]`, so the
`{"err": "unsafe dirname char U+%04X"}` return cannot fire for any arm the
fixture declares. Control C3 injects `"zz-unsafe": ["sweep"]`: the base refuses
(`FAIL phys3d_joints zz-unsafe reason=sweep@gp unsafe dirname char U+002D`,
rc=1), the fold proceeds and passes (rc=0). Tradeoff: the fold deletes the only
fail-closed refusal for a *future* table entry with a hostile character. The
other 17 lines of the fold do not depend on F2; the L1 can drop this hunk
alone.

**F3/F4 — child dead declaration and function (−6 lines).** `c_rid` (1
occurrence, 0 uses) and `bpos()` (1 occurrence, 0 call sites). The textual
census also flags the parent's `_initialize`/`_run`, which are **false
positives** — engine entry point and `call_deferred("_run")` (a string), and
are *not* touched.

**F5 — one joint-type reader (−449 B, +4 lines).** 19 call sites of
`fmt(PhysicsServer3D.joint_get_type(x))` (two spellings: `PhysicsServer3D.` and
the local alias `P.`) become `jt(x)`. The helper is the single place that names
the server call; it is the same convention the file already uses for repeated
reads (`v3`, `fmt`, `st`, `wit`), not a second one. The +4 lines buy 449 bytes;
every arm prints `jtype=`/`type=` through it, so the vfold covers it densely.

**F6 — `freeb_dyn` shares the freed-endpoint handler (−8 lines).** The split
branch's body was identical to `freeb`'s (the dynamic-A distinction is
`dyn_a` in `_initialize`); the merge rewrites the conditional to
`a_rid if case == "freea" else b_rid`, which is equivalent on all three cases
(freeb/freeb_dyn → `b_rid`, freea → `a_rid`). `free_pair` pins the freed
endpoint's motion at t=7/t=8, so an inversion is caught by the vfold — the 6
reps agree byte-for-byte.

## 3. The dead-case question, answered

The tasking's hypothesis — child per-case handlers in cases `ARM_CASES` never
reaches — is **not present**:

- `ARM_CASES` maps 8 arms / 17 cases. The child's dispatch surface is exactly
  those 17 names (14 `match case` labels in `on_e` + `sweep`/`rid`/`api` in
  `_initialize`), and it names no case that no arm reaches
  (`case-census.py`). `twopin` shows up only as a `case.begins_with("twopin")`
  prefix test, not as a case name.
- The child's `_:` default branch is the only adapter for an undeclared case;
  no arm can reach it, because the parent validates `arm` against `ARM_CASES`
  and is the only caller (the r89 finding class — not a fold target).
- Therefore the child's dead weight was declarations/functions (F3/F4), not
  handlers. No dead-case deletion exists to make.

## 4. Discriminating controls

| control | mutation | result | what it proves |
|---|---|---|---|
| **C1** emission forge | folded child's `jt()` reads `joint_get_type + 9` | rc=0, PASS line differs from the pin (`jtype=9` everywhere) | the comparator is sensitive to child output changes |
| **C2** pin drift | folded battery, detach marker `2.1073` → `2.1074` | battery **FAIL**, reason `exact stdout marker missing` | the pins are load-bearing exact stdout matches |
| **C3** guard force | inject `"zz-unsafe": ["sweep"]` | base **FAIL** `unsafe dirname char U+002D`; fold rc=0 PASS | the F2 guard was the sole refusal; the fold removes it |
| **C4** dead-writer probe | child prints `std::system_error`; base parent instrumented | `THROWDBG=1` ×3 in base-dbg; PASS lines identical with/without the line (both variants) | F1's counter was live but unobservable |

## 5. Candidates examined and **not** folded

| candidate | measured weight | why not |
|---|---|---|
| child `done = true` after `quit(0)` ×3 (sweep/rid/api) | −3 lines | not unreachable in the strict sense: `quit()` ends the loop at the end of the current iteration, but Godot's physics catch-up runs 12+ ticks inside one iteration after a ≥200 ms stall — without `done` the child would print a second `M DONE` and the row would fail. Cheap insurance; deleting trades a real fail-closed property for 3 lines. |
| child `joint2 = P.joint_create()` for the 11 endpoint cells that never use it (twopin/chain3 do) | −11 lines | the uniform prologue is the shared RID/heap allocation shape of every endpoint cell — and heap state is exactly what decides the teardown-UAF realization. Narrowing it per case is a second convention *and* moves the measured mechanism. |
| parent `BOUND_S := 20` vs battery `CASE_TIMEOUT_SECONDS = 20` | 0 | two independent bounds at different levels (per child vs per arm); the coupling is real but each file owns its own value. Observation only. |
| `BIMODAL` table (20 tags) and the 8 battery pins | 0 | measurement, not weight — a generated expectation would let a wrong-but-consistent child pass (r89's rule). |
| `_emit`'s `clean`/`crash` predicates | 0 | both are admission predicates, neither is redundant: `clean` needs `msz == full_msz`, `crash` admits truncation at `>= n_pre`. |
| `ARM_CASES` ↔ child `match` duplication | 0 | parent validates, child dispatches; generating one from the other is a second convention. |
| parent `_fail`/`_finish`/`_project_body`/`BACKENDS`/`BOUND_S` | 0 | all read (census in `receipts-summary.txt`). |

## 6. Doc candidates and findings

- **F7 (doc, separate patch).** The header paragraph still says the pin is
  "signal-class rc, M-prefix content/count, crash marker" for **GP** cells and
  "the stable 6-line prefix sha" — all three claims are pre-repair: the emitted
  token is `mode_ok` + the prefix sha, the rc class / sig11 / msz bounds are
  *admission predicates*, the envelope covers gp+jolt, and `n_pre ∈
  {2,3,4,6,8,11}`. Proposed 4-line replacement in `fold-doc.diff` (applies
  clean); the dropped rate sentence (~2/3 vs 1/3) lives on in
  `corpus/live/r90-repair/mx.csv`, and the structural fact (which cells
  truncate) is in the `BIMODAL` block.
- **Finding, comment-only (not folded).** `# Arms (the `match` dispatch is the
  sole index)` — the parent's sole index is `ARM_CASES`; the `match case`
  dispatch is the *child's*. Ambiguous, left to the author.
- **Finding, comment-only (not folded).** child line 335: "B(0,3.2) C(0,2.4)
  spheres r=0.3" contradicts `mk_body(..., sphere=true)`, which sets sphere
  radius **0.5**. The pins measure the r=0.5 geometry; the 0.3 is stale.
- **Finding.** `freeb_ops@gp` "crash … ~2/3": my 6 reps realized 6/6 crash
  (the verifier saw 7/8). The rate is realization frequency, not a structural
  claim; the envelope admits both, and the digest never depends on which.

## 7. Receipts

`corpus/live/r90-simplifier/`: `README.md` (layout + stale-dir note),
`fold.diff` (`17ec4df8…`), `fold-doc.diff`, `vf/{base,fold,doc}/`,
`vf-scratch-*` + `vf-extra-*` (96 arm runs with every `child.log`),
`runs-*/` (arm logs + rc), `bat-base/`, `bat-fold/`, `bat-runs-*/` (battery
verdicts), `controls/` + `controls/out/`, `receipts-summary.txt` (sha table +
all censuses), and the drivers (`run-arms.sh`, `mk-scratch.sh`,
`apply-fold.py`, `make-controls.py`, `controls.sh`, `check-arms.py`,
`modes.py`, `guard-census.py`, `case-census.py`, `dead-census.py`).

| artifact | sha256 |
|---|---|
| `corpus/fixtures/phys3d_joints.gd` (base = repaired) | `cd9f05fb8a797ed0ac026d6a30085948759ee3ad510c5005c48169556e00dadf` |
| `corpus/fixtures/r90_child.gd` | `05b2380b1fc41f1ecb8bbcb0de4509205dca29c1e6ab0b7e2e9d3538fa8321f7` |
| `corpus/fixtures/run_battery.py` (repaired pins) | `be5663f7767332b160338b87aee3f8501467779112e2aedca5c7de0a28ed6d47` |
| `vf/fold/phys3d_joints.gd` | `6e06a1db264fb28cea35a54cddf8ddeed4b1732d4f9f3c4ff296e8d97f4557c4` |
| `vf/fold/r90_child.gd` | `84f6241de590b5810357dde7714a19ec37e3072526e165e4c3ac8a8010d9aaa7` |
| `fold.diff` | `17ec4df8e69fcbf953bea8c12492c51cb75be6f19eba65525eb60b2481026ca9` |

Per-fold attribution (child): base 356 lines/12356 B → +F3+F4 350/12188 →
+F5 354/11739 → +F6 346/11518. Parent: 189/7636 → 179/7278 (F1 −3 lines,
F2 −7 lines).

## 8. Shared-tree byte-identity and scope

- `git status --short` is exactly the pre-task state; `git diff HEAD --stat`
  is still `2 files changed, 46 insertions(+), 37 deletions(-)`; the three
  tracked fixture files keep their starting shas and mtimes
  (`phys3d_joints.gd` 11:12:48, `run_battery.py` 11:14:31, `r90_child.gd`
  10:16:06). Every write this seat made is under
  `corpus/live/r90-simplifier/` plus this report; no commit.
- The earlier interrupted attempt's receipts (`scratch-base/`, `scratch-fold/`,
  `runs-base/`, `runs-fold/`) are pre-repair (parent `c7be2d63…` = committed,
  child `ef6ff9e9…` ≠ current) and are marked in the receipts `README.md`.
- The fold patches are candidates only: `fold.diff` (F1–F6) and
  `fold-doc.diff` (F7) apply clean to the repaired tree but were never applied
  to it, so the working tree the verifier sees is untouched.

## 9. Stop condition

The next deletion candidates all harm an axis: `done = true` guards a
duplicate-DONE failure mode; `joint2`'s uniform prologue is the measured heap
shape; the remaining prose is the mechanism explanation. F2 is the one hunk
that trades a fail-closed guarantee for 7 lines and is flagged for the L1's
call. Stopping here.
