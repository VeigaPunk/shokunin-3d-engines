# r90 verifier — independent verification of 191f131

Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps.
Receipts under `corpus/live/r90-verify/` (run1/, run2/, bimodal/r1-r6/,
crashaudit/, crashaudit2/, forge/). No tracked files touched; no commits.

| # | check | verdict |
|---|-------|---------|
| 1 | Fresh battery ×2, joint signatures vs pins + cross-run | **FAIL** (run1 225/225, run2 224/225) |
| 2 | Prior-217 stability vs r89 fold | **PASS** |
| 3 | Forge-kill (child mutation + pin mutation) | **PASS** |
| 4 | Bimodal cell audit | **FAIL** — second unmodeled bimodal cell + third crash class |
| 5 | Crash-cell honesty | **PASS** |
| | **Round verdict** | **REJECT** |

## 1. Fresh battery ×2 — FAIL

- `run1/20261015T133731595277Z`: **225/225 PASS**, all 8 `phys3d_joints_*`
  PASS lines byte-identical to the CASES pins, seeds_unchanged=true.
- `run2/20261015T133733638160Z`: **224/225 FAIL** —
  `phys3d_joints_free_ops` failed `exact stdout marker missing`.
  Deviating token (single cell, everything else identical):
  - pin: `freeb_twice@gp{rcc=sig,sig11=1,m4=e7c8b9cc20d38b1e,e=1,w=0}`
  - out: `freeb_twice@gp{rcc=0,sig11=0,m4=e7c8b9cc20d38b1e,e=2,w=0}`
- run1↔run2 signatures: identical for 7/8 joint rows; free_ops differs on
  that one token. 7/8 rows are byte-stable across runs and match pins.

## 2. Prior-217 stability — PASS

All 217 pre-r90 cases: verdict AND PASS/NEGATIVE signature identical
across `r89-fold-verify/20261015T083635374793Z`, run1, run2. Zero
mismatches; the only new rows are the 8 `phys3d_joints_*` cases.
No collateral damage from the new fixture.

## 3. Forge-kill — PASS (all three mutations caught)

Scratch-only mutations under `corpus/live/r90-verify/forge/`:

- **sA (emission forge):** `r90_child.gd` `wit()` emits
  `joint_get_type(joint)+9`. `--arm=detach` standalone → all 36
  `jtype=` fields read 9 vs pinned 0 → digest differs → pin catches.
- **sB (semantic forge):** `twopin_hi1` arms the *wrong* pin with
  priority 32 (`joint2` instead of `joint`). `--arm=twopin` → GP trace
  mirror-flips to `b.x=+0.4976` vs pinned `-0.4976` → caught.
  (Note: a `32→8` same-*order* change is an equivalent mutant —
  invisible, as the pin binds winner ordering, not the priority value.
  Expected, not a gap.)
- **batfix (pin forge):** copied `run_battery.py`, one-digit drift in the
  detach marker (`2.1073`→`2.1074`) → `--only phys3d_joints_detach`
  → `FAIL ... exact stdout marker missing`, battery exit 1
  (`forge/batout/`). Marker comparison is exact-match and load-bearing.

## 4. Bimodal cell audit — FAIL

6× standalone `--arm=free_ops` reps (`bimodal/r1-r6/`) + both battery
children. Two distinct PASS lines observed across the 6 standalone reps.

**`freeb_ops@gp` (the declared bimodal) — sound.** Digest byte-identical
in all 8 observations (`mode_ok=1,m6=124dfece8083d80f,w=0`); child.logs
show crash mode in 7 (sig11 + `dumped core`, dies mid-ops window) and
clean mode in r5 (M DONE, rc=0, e=2). Both named realizations admitted —
the mode_ok envelope works as designed.

**`freeb_twice@gp` — UNSOUND, second bimodal cell pinned as
deterministic crash.** Observed across 9 child executions:
- clean (5×): `rcc=0,sig11=0,m4=e7c8b9cc20d38b1e,e=2,w=0` —
  bimodal/r1,r3,r5,r6 + **run2 battery** (this realization failed the row)
- crash (4×): `rcc=sig,sig11=1,m4=e7c8b9cc20d38b1e,e=1,w=0` —
  bimodal/r2,r4 + run1 battery + author battery (their 225/225
  legitimately hit the pinned mode; preserved child.log shows sig11)

Mechanism (child.logs): the t=8 double-free of `b_rid` errors cleanly
(`Invalid ID`); the crash fires at **teardown** (`r90_child.gd:205-207`),
which re-frees `bodies` including the already-freed `b_rid` — UAF that
either returns `Invalid ID` (clean: e=2) or SIGSEGVs (e=1, dies after
M DONE). Same `m4` prefix in both modes; only rc/sig11/e differ.
`~55%` clean in my sample — the pinned crash mode is not even the
majority realization.

**Jolt freed-endpoint cells — third unmodeled crash class.**
`crashaudit/` `--arm=free_pair` run: `freeb@jolt` and `freeb_dyn@jolt`
SIGSEGV'd at teardown (rc=134, sig11 backtrace into `on_e` line 207,
`dumped core`) while pinned `rc=0`. `crashaudit2/` rep: all Jolt cells
clean → lower-frequency but real bimodal teardown UAF on Jolt too.
The same re-free window exists for **every** cell that frees a body/joint
RID mid-run (freeb/freea/freeb_dyn/freeb_ops/freeb_twice/freeb_make/
freeb_afterclear/freej_then_b/detachb_free) on **every** backend — the
pins treat all of them as deterministic.

## 5. Crash-cell honesty — PASS

Every `rcc=sig`/`sig11=1` digest was backed by a real crash in the
corresponding `r90bt_*/child.log`: `handle_crash: Program crashed with
signal 11`, C++ + GDScript backtraces, `timeout: the monitored command
dumped core` (verified for freeb_ops@gp, freeb_twice@gp, freeb_dyn@gp,
chain3_freemid@gp, and the unmodeled freeb@jolt/freeb_dyn@jolt crashes).
Clean realizations honestly show M DONE + `ERROR: Invalid ID.` lines.
No fabricated envelopes; prefix shas (m4/m6/m8/m2) are rep-stable across
modes — the crash-envelope convention itself is sound.

## Verdict: REJECT

The lattice is real and 7/8 rows are byte-stable, but `phys3d_joints_
free_ops` is flaky-by-pin (`freeb_twice@gp` clean mode ~half of
realizations, proved in run2), and `phys3d_joints_free_pair` carries a
latent Jolt teardown-crash class pinned as rc=0. A pinned row that fails
on a legal realization cannot ship.

Suggested repair (author's call):
1. Extend the `GP_BIMODAL`/`mode_ok` treatment to `freeb_twice@gp`
   (clean: `rc=0,sig11=0,e=2`; crash: `rcc=sig,sig11=1,e=1`; m4 shared) —
   and audit every `free*` cell on every backend for the same
   teardown-re-free window, since the class is mechanism-wide.
2. Root-cause alternative: have the child's teardown skip RIDs already
   freed during the run (track them) — eliminates the UAF window and
   makes every cell deterministic, at the cost of no longer measuring
   the teardown double-free class itself.
