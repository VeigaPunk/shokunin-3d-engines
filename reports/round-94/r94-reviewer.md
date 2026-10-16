# r94 reviewer — surgical correctness review of the committed cannon.js landing (`05e72ef`)

Seat: **GAME-DEV-3D r94 REVIEWER**. Reviewed artifact:
`05e72ef968f218fc7c4f8b2e58a190d2eddd63fc` ("r94 author: 19 cannon.js rows
(284 total) — boundary corrections folded (internalStep clock, order-neutrality
scoped, mu-v0 grid, fixedStep wall-clock class); 284/284 green") —
`corpus/fixtures/r94_cannon.gd` (+194, new), `corpus/fixtures/r94_child.mjs`
(+1027, new), `corpus/fixtures/r94vendor/` (+4: `cannon-es.js`,
`three.module.js`, `three.core.js`, `package.json`), `corpus/fixtures/run_battery.py`
(+38), `reports/round-94/r94-author.md` (+71). Claim document:
`reports/round-94/r94-author.md`.

**No commits, no tracked writes by this seat.** Receipts live under
`corpus/live/r94-reviewer/**` (gitignored via `corpus/.gitignore: live/`; see
`RECEIPTS.md` there). The only new repo file is this report.

**Byte custody.** At seat start `HEAD = 05e72ef` and `git status --porcelain`
was clean. The measured tree is `git archive 05e72ef` extracted to
`/tmp/r94-reviewer/tree05e72ef`; archive shas == `git show` shas
(`r94_cannon.gd d40a1f75…`, `r94_child.mjs c84a8e8a…`, `run_battery.py
b230d29c…`, `r94vendor/cannon-es.js f0700cbd…`). Every measurement below ran
from that archive (or a /tmp mutant of it); the worktree was never used as a
seed source. **Mid-seat drift (sibling lanes, contained):** the other wave-B
seats committed their reports (`7cd5ec8` scribe, `942f56e` critic, `52b2fbc`
simplifier, `ed8b659` verifier — reports only; the reviewed r94 bytes are
untouched by them) and a concurrent r95 lane added untracked
`corpus/fixtures/r95_{bullet.gd,child.py,vendor/}`; `HEAD` is now `ed8b659`.
No tracked file was modified by this seat; the only new repo file from this
seat is this report (plus gitignored `corpus/live/r94-reviewer/**`).

**Runtime / reroute check.** `which -a godot` → `/usr/bin/godot` only
(`4.7.2.stable.arch_linux.ed1daf0bf`, matching every receipt banner); `node`
resolves via the inherited PATH to `v24.21.0` (fnm), the version pinned in
every r94 PASS line; no `GODOT_*` env vars; no `resume_continuity` surface in
this lane (`grep -rn resume_continuity corpus/fixtures/` = 0). Host load during
this review: 86–126 from concurrent sibling lanes (no seat-owned hogs; the
"load preferred" gate is satisfied by ambient load — recorded per run below).

**LSP note (recorded gap).** MCP inventory on this substrate = the `rea`
server only; no `lsp` device answers these files. This seat made no edits, so
no symbol-level work was required; text/AST checks (`--check-only`,
`node --check`, AST census) are the available substitutes.

**probeParent seat.** Exactly one `ufo-labrat` was dispatched (bounded
read-only pin-provenance audit). It could not see `corpus/live/` (the
gitignored path is absent from its checkout), so it audited the committed
reports only. Its one substantive "contradiction" — `aOverMuG=15.668` in the
r94 marker vs `15.669` in `r94-boundary.md` §10 — was resolved by this seat
against the boundary's own receipts: the boundary logged **m=1 → 15.668** and
**m=0.5 → 15.669**; §10's line labelled "(m=1)" prints the m=0.5 value. The
r94 pin matches the m=1 receipt. The labrat output is advisory only; the
resolution below is this seat's (F4). No other descendants were spawned.

**Method.** (1) Committed-diff shape (numstat + `difflib` opcodes). (2) Parse
checks on the canonical runtime. (3) AST census of `CASES`, `ARM_CASES`,
`NEGATIVE`, and the child's case table. (4) **Fresh arm sweep**: 19 arms × 3
reps from the archive tree at load 86.5–101.9. (5) **`run_battery.py --only`**
on the 19 r94 rows × 3 reps at load 101.7–111.0. (6) **Full 284-case battery ×
2** from the archive tree at load 121.6 and 64.8. (7) Two **mutation probes**
of the digest gate. (8) **Vendor byte-identity** vs the scout's npm install.
(9) **Receipt integrity** of the author's own `/tmp/r94test` + run receipts.
(10) **Citation audit** of the boundary-corrected pins. (11) **Report-claim
audit** value-by-value against the committed markers. (12) A targeted
**flip probe** of the four accumulator-mode cells the critic flagged
(750 + 500 direct child executions).

---

## Verified independently

1. **Diff shape — insertion-only, zero existing bytes touched.**
   `git diff --numstat 7f84e66 05e72ef` = 38/0 for `run_battery.py` and pure
   insertions for every other file. A `difflib.SequenceMatcher` over the
   old/new `run_battery.py` yields exactly one opcode:
   `insert old[660:660] new[660:698]` — no replace/delete anywhere (the
   previous last tuple already carried its trailing comma, so the 19 r94
   tuples could be appended without touching a byte). The r94 block is
   contiguous at CASES indices 265–283, immediately after `r93_areasig_prio`.

2. **Parse.** `node --check corpus/fixtures/r94_child.mjs` → OK;
   `godot --headless --check-only --script res://r94_cannon.gd` → rc 0
   (banner only, no Parse Error).

3. **Census.** CASES = **284 = 231 ordinary + 53 negative**; r94 = 19 rows
   (13 ordinary + 6 negative). `ARM_CASES` = 13 arms → 60 positive case names;
   the child's `CASES` table has 66 keys = those 60 + the 6 negatives, exact
   match in both directions. 66 fresh node children per battery pass, matching
   the report's count.

4. **Fresh arm sweep reproduces the committed markers byte-for-byte, under
   load.** 19 arms × 3 reps (57 runs) at load 86.46 → 101.92:
   **57/57 exact committed stdout line, empty stderr, correct rc**
   (13 arms rc 0, 6 arms rc 2); per-arm stdout is **byte-identical across all
   3 reps** (19/19 arms); the whole sweep took 80 s (~1.4 s/arm). Receipt:
   `corpus/live/r94-reviewer/fresh/` (`verify.txt`).

5. **Battery `--only` on the 19 r94 rows: 3/3 reps 19/19 PASS**, executed
   markers == committed markers 19/19, `seeds_unchanged=true`, load
   101.71/103.83/110.97 (`batt-only/`).

6. **Full 284-case battery from the clean archive, ×2.** Rep 1 (load 121.62):
   **281/284**, `FAIL` rc 1 — `navagent3d_retarget`, `navagent3d_follow` (the
   documented navagent one-tick miss: `before=1.754246`, `first=1.636395`,
   each +√2/60 ≈ +0.02357 over the pin) and
   `phys3d_events_script_size_gate` (documented granted-under-load).
   Rep 2 (load 64.80): **282/284**, `FAIL` rc 1 —
   `phys3d_events_freed_space_methods` (documented Jolt crash envelope,
   `rc=134`, `fm_jolt_pt_post=nil`, `slot >= slot_max` errs) and
   `phys3d_joints_free_ops` (documented 20 s timeout).
   **All 19 r94 rows PASS in both reps**, markers exact 19/19,
   `seeds_unchanged=true`, slowest r94 row 1.79 s against the 20 s case bound;
   every failure is on the on-record flake list (r93-baseline F1/F2,
   r93-baseline2 run 1, r93 critic F1 — all r93 documents). Receipt: `batt-full/`.

7. **Vendor bytes are the scout's npm pins, exactly.** sha256 of
   `r94vendor/cannon-es.js` `f0700cbd3a48…`, `three.module.js` `9052042d676c…`,
   `three.core.js` `9edde002b066…` are equal to
   `corpus/live/r94-scout/proj/node_modules/{cannon-es/dist/cannon-es.js,
   three/build/three.module.js, three/build/three.core.js}`;
   `r94vendor/package.json` is `{"type":"module"}`. All four vendor files are
   in the battery's `seed_digests` map (verified in the run receipt; 71 seeds
   total, before == after in every run by this seat).

8. **The author's receipts verify.** `/tmp/r94test/reps/` = 19 arms × 5 reps,
   one stdout hash per arm, all `.err` empty, and **95/95 outputs == the
   committed markers**; `/tmp/r94test/runs/20261015T215209747397Z` = r94-only
   pre-run 19/19 PASS, `seeds_unchanged=true`; run 1 = 280/284 (the four
   documented fails), run 2 = 284/284, both `seeds_unchanged=true`, and run 2's
   executed marker lines == committed markers 19/19.

9. **The digest gate is non-vacuous (mutation probes).** In a scratch copy of
   the archive, mutating the child's `DEFAULTS.gravity` −9.82 → −9.83 makes
   `r94_cannon_det` FAIL (`exact stdout marker missing`) and
   `r94_cannon_neg_gravity` FAIL (`exit 1 != expected 2` — its live control can
   no longer discriminate). Injecting one stray `console.log` into `det_base`
   turns that cell into `…|M DONE case=det_base,o=1,d=0}` against the committed
   `o=0` → marker mismatch. The parent's digest therefore measures the child's
   physics and output surface, not a self-consistency restatement. Receipts:
   `mutant/`, `mutant-o/`.

10. **Every boundary-corrected pin carries its boundary value verbatim.**
    `internalStep` frozen-clock `c882e660f6b85f96` (+`ph=c1365b74ffa49e03`,
    `sleep=1,1,1,1`) and clocked `0e24fb5aca619253`; the three asymmetric
    order scenes' forward/reverse hashes (`2e65cf…/d02da5…`, `4caaad…/d3795d…`,
    `f1a92e…/a8ad93…`) with `rows=106/175` on `stack3`; the eight solver
    variants incl. `SplitSolver` `40aeebd22b384e32`; the ULP fork
    `0c63200d1cbbf34d`; the canonical NaN `152fc9d393846ae3`; the friction grid
    `15.173/15.172/3.053/15.668/9.048/17.273`; and the `fixedStep` class — my 3
    reps' `#` diagnostic read
    `# fixedstep measured stepnumber=1 ph=a3ec872defc812b2`, exactly the
    boundary's tight-loop physics witness, while the count stays a `#`
    diagnostic (`d=1` pinned as a count only, `ticks_lt_calls=true`).

11. **The author report's arm table and corrections list are value-accurate**
    against the committed markers (spot-checked exhaustively: every hash,
    `ball.y`, sleep step, contact count, `aOverMuG`, `maxN`, `dPos`,
    `naiveErr`, `cC`, `y=-72.845`, `detScale`, `maxStaleGap`, negative-arm
    hashes), with the three prose exceptions in Findings F1–F3.

12. **The report's repro command works as written.**
    `node corpus/fixtures/r94_child.mjs det_base` from the repo root prints the
    pinned `M` lines and exits 0.

13. **Independent flip probe corroborates the r94 critic's F1 (the round's one
    MEDIUM finding) at the cell level.** The critic measured 13 flips in 1340
    targeted executions of four accumulator-mode cells at load1 90–135
    (wall-clock bail-out inside `step(dt, elapsed, maxSubSteps)`). This seat's
    own probe (committed child, direct `node` runs, full M-surface hashes;
    receipts `flip-probe/`, `flip-probe-load/`) saw: pass 1 at ambient load
    ~52–60 — **0 flips in 750 executions** (300 `mod_two_arg`, 150 each of
    `var_maxsub`/`var_interp`/`var_sleep_phase`); pass 2 with 8 seat-owned
    spinners + 16-way parallel children — **1 flip in 200 `mod_two_arg`**
    executions: normal `stepnumber=10 … ball.y=4.850047582 h=4c92fce24d8d7f58`
    vs flipped `stepnumber=5 … accumulator=2.42861286636752993e-17
    ball.y=4.959092470 h=f3477448686eddb3`, i.e. the substep loop broke early —
    the same mechanism, at a lower rate for this load class. A flipped surface
    cannot match the committed marker, so the affected row FAILs by
    construction. No r94 row failed in any of this seat's **152 row
    executions** (57 fresh arm runs + 57 `--only` row runs + 38 full-battery
    row runs), consistent with the measured ≈1 %/child-execution event rate.

---

## Findings (severity order)

**F1 (LOW–MEDIUM, report accuracy — a law sentence is false as stated).**
`reports/round-94/r94-author.md` (parity2 row) says "vel-write to a sleeping
body wakes it (`state=2→v=4.999163`)". Measured directly on the vendored bytes
(`/tmp/r94-reviewer/probes/sleepwrite.mjs`, the same `restScene(true)` scene,
sleep `@62`): the write tick leaves `sleepState=2` and the position **frozen**
(`y=0.499997533` unchanged; the stored velocity is damped `5 → 4.999162542`),
and two further steps without a wake call leave the position frozen (the
velocity keeps damping: `4.998325225 → 4.997488047`). Only the fixture's
explicit `ball.wakeUp()` moves it. The committed marker is honest — it labels
the second half `thenWakeUp` — so no pinned byte is wrong; the report's law
sentence overstates. Minimal fix: reword to "a velocity write reaches a
sleeping body's stored velocity but does not wake it (state stays 2, position
frozen until `wakeUp()`/impact wake)".

**F2 (LOW, report accuracy — run-1 failure timing).** The report says run 1's
four fails all "failed inside the first ~60 s while the sweep was running".
The receipts contradict this. Cumulative serial time of the four fails in
`corpus/live/runs/20261015T215239880004Z` = **2.8 s, 7.9 s, 232.8 s, 235.3 s**
from the run stamp `21:52:39.88Z` (so the size-gate pair ran at ≈21:56:33),
while the author's rep sweep's own files bracket its activity at
**21:52:56–21:55:06Z** (`.err` creation times mark each arm's start; 95 runs,
~130 s). On those numbers the two navagent fails precede the sweep's first arm
(≈21:52:43/48) and the size-gate pair lands **~87 s after the sweep's last
output** — none of the four falls inside the sweep's window. (The cumulative
reconstruction is the battery's own serial `elapsed_seconds` sum; per-case
overhead can shift it by tens of seconds late in the run, which cannot move
the size-gate pair back before 21:55:06.) My own full run at load 121.6
reproduces the same class pattern with the size-gate fail at cumulative 262 s
and **no sweep at all**, so the flake classes (r93-baseline F1/F2) stand —
only the timing/attribution sentence is unsupported. Minimal fix: drop
"inside the first ~60 s while the sweep was running" or restate the measured
cumulative times.

**F3 (LOW, report accuracy — mode count).** The material row says "14-mode
material/contact-material lattice". The committed child has **15** `MODES`
keys, and the executed marker carries 15 distinct modes (30 `M mat_all` rows,
plus the four summaries). The fixture header comment (`r94_cannon.gd:47`)
repeats "14-mode". Minimal fix: `s/14-mode/15-mode/` in the report (the
fixture-header occurrence would re-sha `r94_cannon.gd` if edited).

**F4 (NOTE, cross-document — the boundary report's §10 mu=0.9 value is
mislabelled).** `r94-boundary.md` §10 prints `mu=0.9 -> a/mu*g = 15.669` under
the heading `mu (m=1)`, but the boundary's own receipts
(`corpus/live/r94-boundary/logs/friction-idle.log`, `runs/r94b-friction-idle/`)
show **m=1 → 15.668** and **m=0.5 → 15.669**. The r94 pin (`15.668`, the
fixture's own m=1 scene) matches the boundary's m=1 receipt exactly. (The
critic's report reads the 15.669/15.668 pair as a 3-dp rounding of one
measurement; the receipts show it is instead the m=0.5 row's value under an
`(m=1)` label.) This is a boundary-report typo, not an r94 defect; fold-queue
candidate. (The labrat surfaced it; this seat resolved it against the
receipts.)

**F5 (NOTE, artifact robustness — digest cells are comma-delimited but carry
commas).** The `{rc=…,m=…,o=…,d=…}` cells embed commas (`sleep=2,2,2,2`,
`q=…,`, `w=NaN,NaN,NaN`, `ni=0,0,0`, `time=4.000000000`). The battery does
exact whole-line matching, so nothing breaks today; any downstream cell parser
must not split on commas (same class as the r93 reviewer's F7).

**F6 (NOTE, residual risk — cross-V8 robustness of the new cells is
unmeasured).** The boundary's node-26 (V8 14.6) sweep covered the scout's 49
arms, not r94's new scenes/lattices; the r94 pins are receipts for
`node v24.21.0` (V8 13.6) on this host. The mitigation is structural: the node
version is pinned in every PASS line (`node=v24.21.0`), so a different runtime
fails loudly instead of drifting silently.

**F7 (NOTE — the `bailout` pin sits on the wall-clock budget boundary).** The
report acknowledges this and isolates the row; `stepnumber=1` held in the
author's 5 reps, this seat's 3 reps, and 5 battery passes (3 × `--only` +
2 full, including load 121.6). No action; recorded so a future drift surfaces
alone.

---

## Residual risk / verification gaps

- **No LSP device** (`rea` only): symbol-level checks were unavailable; none
  were needed (this seat made no edits, and both fixtures parse and execute).
- **Cross-build.** Every pin is receipt-derived for
  `4.7.2.stable.arch_linux.ed1daf0bf` + `node v24.21.0`; no tolerance story
  (inherited from r89–r93). The new r94 cells' V8-robustness is unmeasured
  (F6).
- **Documented non-pinnables** (fixture header, consistent with the boundary):
  the accumulator substep spread (1…222 on this host), the `GridBroadphase
  nx=10` hang/`RangeError` class, and the `--no-opt` NaN-payload flip
  (~34 %/process) are reported, not authored; the NaN arm hashes canonically
  only.
- **Timeout layering.** Each child is bounded by `timeout -s KILL 15` and each
  arm by the battery's 20 s case bound; a hung child converts to a loud FAIL
  (rc 137 → digest mismatch), never a silent pass. No r94 row came near either
  bound (slowest observed 2.6 s under load 121).
- **Corroborated sibling finding (critic F1, MEDIUM) — four accumulator-mode
  cells are contention-sensitive single-value pins.** `var_maxsub`,
  `var_interp`, `var_sleep_phase` (row `r94_cannon_varstep`) and `mod_two_arg`
  (row `r94_cannon_modes`) sit on the engine's `performance.now()` bail-out;
  under heavy contention the substep loop breaks early and the pinned
  `stepnumber`/`ball.y`/`interpPos`/`h` fields move, which FAILs the row by
  construction. The r94 critic measured 13 flips in 1340 targeted executions at
  load 90–135; this seat independently reproduced one flip in 200 `mod_two_arg`
  executions under 8 spinners + 16-way parallelism (0/750 at ambient load
  ~55). The authored values are the un-preempted-path values and every pinned
  byte is correct for that path; the risk is the single-value pin (and the
  report's "load-invariant" claim) on a wall-clock-bounded code path. The
  critic's recommended fold — envelope-pin the multi-substep calls or add the
  class to the round's flake list — is the author/adjudicator call, not this
  seat's.
- **The battery's scratch copy excludes the pre-existing `corpus/fixtures/three/`
  tree** (23 MB of unrelated node_modules); the r94 fixture does not depend on
  it (it imports only `res://r94vendor/`), and its four vendor files are in the
  seed-digest map.
- **The worktree is not frozen** for sibling lanes; every measurement above is
  pinned to `05e72ef` via `git archive`/`git show`, so a later HEAD move does
  not invalidate this review.

## Recommendation (not a judgment — the canonical runtime judges)

**ADMIT-recommend.** The committed landing is sound as scoped: the diff is
insertion-only with zero existing bytes touched, both new fixtures parse on the
canonical runtime, and all 19 r94 markers reproduce **byte-for-byte** in 57
fresh arm runs (3 reps, load 86–102), three `--only` battery passes, and two
full 284-case passes from the clean archive under load (281/284 and 282/284,
every failure on the documented flake list) — with the digest gate proven
non-vacuous by mutation and the vendored engine bytes sha-identical to the
scout's npm pins. The findings of this seat are claim-precision in the report
(F1–F3) plus cross-document/robustness notes (F4–F7); none touches a pinned
byte. **One round-level item remains open and is not this seat's to fold:** the
critic's F1 (MEDIUM) — four accumulator-mode cells are single-value pins on a
wall-clock-bounded code path and can FAIL their rows under heavy contention
(critic 13/1340 targeted executions at load 90–135; this seat independently
reproduced 1/200 on `mod_two_arg`; 0/750 at ambient load). The authored values
are correct for the un-preempted path; the fix (envelope pin or flake-list
entry) belongs to the author/adjudicator. The minimal CHANGES set for this
seat's findings, if the judge wants the claim documents exact, is the F1–F3
text edits (report only; the F3 fixture-header occurrence would re-sha
`r94_cannon.gd`).

**Blockers:** none.

Stopping here.
