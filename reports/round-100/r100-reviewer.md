# r100 reviewer — adversarial re-derivation of the fixed-fps lattice landing (`8183191`)

Seat: **GAME-DEV-3D r100 REVIEWER**. Reviewed artifact:
`8183191f789acca8f3f0292392a1ee84fe317a50` ("r100 author:
fixed-fps/quit-after/render-target/Area3D lattice (8 rows/142 cells, +39/-0)") —
**3 paths, +1064/−0**:

| path | lines | sha256 (16) |
|---|---|---|
| `corpus/fixtures/r100_fpslat.gd` (new) | +892 | `da11495de7a24703` |
| `corpus/fixtures/run_battery.py` (insertion-only) | +39/−0 | `f456bd00a1f7cc6f` |
| `reports/round-100/r100-author.md` | +133 | `881aa7f7077286b3` |

Claim document `reports/round-100/r100-author.md`; context `r100-scout.md`,
`r100-boundary.md`; receipts `corpus/live/r100-author/**`.

**No commits, no tracked writes by this seat.** This report is left untracked
for the operator. The only scratch this seat wrote is
`corpus/live/r100-reviewer/**` (gitignored).

**Byte custody.** `HEAD = 8183191` at seat start and at seat close;
`git diff 8183191 -- <the three landed paths>` is empty (worktree bytes ==
committed bytes). Sibling lanes wrote untracked reports during the seat
(`reports/round-100/r100-scribe.md`, `reports/frontier/*.md` appeared); none is
in the reviewed paths, and no reviewed byte moved.

**Runtime.** `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`;
`/usr/bin/python3` 3.14.7; 32-core host, load average 5.5–8.6 at seat close
(the author's full runs were taken at the ~55-load ambient the report names;
my re-derivation ran on a quieter host).

**LSP note (recorded gap).** This substrate exposes no `lsp` device for these
files (same recorded absence as r85–r99). No source edit was made, so the
substitutes used were: full-file reads of the parent fixture, all six probes
and the battery; an AST parse of the committed `CASES`; a fresh
`git archive 8183191` checkout; and live battery re-derivation. No grep output
is presented as semantic proof anywhere below.

---

## 1. Method — independent re-derivation, not a re-read

1. **Expected bytes.** Parsed the committed `run_battery.py` with `ast`
   (350 cases, 8 `r100_*` rows) and extracted the eight expected markers
   verbatim to compare against live output.
2. **Live re-run.** Ran the eight rows myself on the worktree bytes
   (`run_battery.py --only r100_fpslat_{sched,qa,modes,compose,rt,area,life,cls}`
   → `corpus/live/r100-reviewer/20261016T100152076348Z/verdicts.json`,
   `reviewer_run1.log`): **8/8 PASS**, and every live aggregate line is
   **byte-identical** to the committed expected string (lengths 2620 / 1291 /
   2271 / 4096 / 939 / 553 / 1141 / 1333 — all exact matches).
3. **Receipt-vs-committed diff, every author run.** For all seven author runs
   with verdicts, each stored expected marker was compared to the committed
   one, and each stored live stdout line to it. B, C, run 5, GREEN RUN 1 and
   GREEN RUN 2: all eight markers == committed bytes. Targeted (084437) and A
   (084518) differ from the committed bytes **only** by the two disclosed
   `,beq=0` tokens on the `noquit_unbound@jolt/@dummy` env cells; A's live
   stream emitted `beq=1` there (the racy comparison), which is exactly the
   failure the report §2/§4 describes.
4. **Driver custody.** sha256 of each run's `scratch/r100_fpslat.gd`: targeted
   and A ran `1ff5988e…`; B/C/GREEN1/GREEN2/run5 and `derive-scratch` ran
   `da11495d…` == the committed file. Diff of the pre-fix vs committed driver
   is a single hunk: `and env.is_empty()` plus a three-line comment — the
   disclosed env-`beq` fix, nothing else.
5. **Fresh-checkout test.** `git archive 8183191` extracted to `/tmp/r100-fresh`
   (finding F1 below).
6. **Provenance.** `cmp` of the six `corpus/fixtures/r100_probe_r100b_*.gd`
   seeds against `corpus/live/r100-boundary/probes/r100b_*.gd`; and a
   from-scratch normalizer (banner/blank/wall-clock/Jolt-pair drops, id mask)
   that compared my 142 child streams against the boundary's 350 r1 receipts.
7. **Law checks from live child logs** — the interleave, quit-after cutoffs,
   flag traps, rt rows, area rows, lifecycle rows were each read out of my own
   children, not out of the author's text.

---

## 2. Claims verified (all positive)

**Fixed-fps interleave — envelope pins, not the falsified formula.** The scout
formula `n_pr = 120·N/60 + 1` would give 121/181/241/481 at N = 60/90/120/240;
the committed pins are 120/180/239/478 — it fails at every pinned N ≥ 60 and
is not encoded anywhere in the fixture (the header explicitly excludes it). The
pins are per-cell measured `n_pr`/`n_ph`/`fpt` plus the trajectory hash; all
eight sched cells I re-ran reproduce byte-for-byte, including the Dummy
non-integrating `traj=a2d4de09…` divergence and `beq=1` GP↔Jolt. The tps30/120
cross-rate cells match the boundary's own tps table (`c9625c56…`/`c20df6e2…`),
and the bake cells behave as claimed (cap inert: 11/61 frames unchanged; jit0
shifts the N<tps phase by one frame: 11→10, 61→60; ds=false changes only the
readback).

**`--quit-after` is a frame bound.** All eight cutoffs pin `n_pr == M` exactly
(1/7/30/100 at fps60; 31/61/101/121 at fps120/240/90/120) and the tick counts
are the boundary's phase-dependent `M·tps/N ± phase` values (16/15/67/61),
cross-consistent with `r100-boundary.md` §5. `--quit-after 0` ran the probe's
full 4000-tick target on GP and Jolt with `beq=1`; `-1` ran the full 2000. The
probe self-bound (`--ticks=`) is what ends the run in both cases, i.e. the flag
did not cut it short.

**Flag-form traps.** Verified live: `--fixed-fps=60` is in argv
(`engine=--fixed-fps=60|--script|res://…`, `argz=3 userz=1`) but inert
(`inert=1`); `--fixed-fps` after `--` lands in user args
(`user=--fixed-fps|60|--ticks=120`, `argz=2 userz=3`) and is inert; duplicate
flag last-wins (`eq=1` against the ffps60 sha); 59.94 → `n_pr=118`,
`fpt=[0:3, 1:117]`; degenerate rates `d=inf/-nan` (N=0), the 1 µs floor
(N<0), 8.333 ms then floor (N=999999999); `--quit` = one iteration (1 tick at
fps60, 11 at fps5); `--quiet` 0-byte receipt, `--check-only` 101-byte receipt
(both sha `e3b0c442…`); `--write-movie` rc=134 with the `wm` ERROR head and the
stream truncated at the deterministic `at: texture_2d_get` line — byte-identical
to the boundary's own receipt under the same truncation. `renderthread` /
`mainloop` `eq=0` is explained by a benign extra line (experimental-thread
WARNING / argv registration) with identical scheduler fields; all other
inert-flag cells are `eq=1`.

**rt write visibility.** Live rows show the write at `pf=3` is not visible to
the IMM read or the later `R_E` in the same tick (not synchronous), and is
visible to the first `R_F` at the write's `pf` with the same `ff` at fps30/60/120
(`rf_O=(1.0000,0.0000,0.0000)`, `rf_ff == w_ff`). The pin is falsifiable: if
propagation slipped one frame the selected row would read `(0.0000,…)`. The lag
law (`imm=3.0 → after1=4.0`, `ff1=7`) and the server ray (`hit@5.000,0.500,0.000`
GP/Jolt, `miss` Dummy with `beq=0`) reproduce live.

**Area3D / arerr class.** The diagnostic is a real inherited probe defect — the
signal emits `(RID, Node3D, int, int)` while `_on_shape_enter` declares
`(Node3D, …)`, so the callback never runs — and it is classified, not hidden:
the exact ERROR line stays in the hashed stream, counted `ee=1`, once per
non-dummy receipt (6/6 area cells), while Dummy emits no signals
(`e_first=-1`, `beq=0`). Enter at pf=29, exit at 35 with the teleport written at
34, verified in the child logs. Nuance F7 below.

**Lifecycle envelopes.** All 24 cells re-derived live: clean/quit_idle/freetree/
quit_double rc=0 `beq=1` across backends; `err` (`lerr`) and `finalize_touch`
(`lfin`) keep their SCRIPT ERROR lines in-hash with `ee=1` at rc=0 (the
rc=0-is-blind hazard); `noquit_bound` ends at exactly 20 ticks under
`--quit-after 20`; `noquit_unbound` is killed by the outer
`timeout -s KILL` at rc=137 with `boot=1` and ≥1 tick, and its `beq` is
suppressed because the racy stream proves nothing — the envelope is the claim,
as disclosed.

**Provenance.** The six seeds are `cmp`-identical to
`corpus/live/r100-boundary/probes/r100b_*.gd` (and sched/rt/area/cls/life are
in turn byte-identical to the scout's `rs_*.gd`; the modes probe is the
boundary's own). 121 of my 142 child streams are byte-identical to a boundary
r1 receipt under the same probe+args (`qa30_ffps60` matches the boundary's
`RS_*` `quit30_ffps60` byte-for-byte; the `writemovie` stream also matches once
the same `done`-truncation is applied). The remaining 20 non-matches are all
explained: cells whose receipt surface the boundary never ran — the boundary
measured qa1/7/100 and the qa31/61/101/121 triples on the `BM_*` modes probe
while the parent re-derives them on the `RS_*` sched probe, and `ts0_qa20`,
census cap1/jit0/dsf, dsf sched are new cells — plus one deliberate
re-parameterization (`quit0` 4k vs the boundary's 20k ticks, for the 20 s cap)
and the disclosed nondeterministic envelopes (`ffpseq60`, `afterdashes_ffps60`,
the three `noquit_unbound`). This is evidence of fresh derivation rather than
copying.

**Run-level claims.** Targeted 8/8; A 348/350 (`phys3d_events_script_size_gate`
+ the in-diff life racy-beq fail); B/C 340/350 each (10 `bpy_rbw3d_*`); run 5
349/350 (`phys3d_events_freed_space_methods`); GREEN 1/2 350/350 with
`full_run4.log`/`full_run6.log` PASS lines that map 1:1 to the run dirs; all
eight r100 rows green in the 5 full runs after the fix. The two flake classes
are pre-existing and documented: history counts 51 PASS/3 FAIL
(`script_size_gate`) and 38 PASS/1 FAIL (`freed_space_methods`), with the r86
band / r88 FATAL TAIL comments in `phys3d_events.gd`.

---

## 3. Findings

### F1 — HIGH, actionable: the landing is not self-contained; the six probe seeds are not in `8183191`

The parent fixture reads `res://r100_probe_r100b_{sched,qa→sched,modes,rt,area,life,cls}.gd`
(`_child_prepare`, `r100_fpslat.gd:795`). Those six files exist in the worktree
but are **untracked** and **not gitignored** (`git check-ignore` exits 1), and
they are **not in the commit** (`git ls-tree -r 8183191 corpus/fixtures` returns
only `r100_fpslat.gd` among r100 files). Demonstrated on a pristine checkout:

```
git archive 8183191 | tar -x -C /tmp/r100-fresh
python3 corpus/fixtures/run_battery.py --only r100_fpslat_cls --runs /tmp/r100-fresh-runs
→ FAIL r100_fpslat_cls  reasons=['exact stdout marker missing']
  live: FAIL r100_fpslat cls census@gp{err=probe source missing} … (all 9 cells)
```

From the committed bytes alone **all eight r100 rows fail** with
`err=probe source missing`. The report §6 does disclose "six inherited
uncommitted `r100_probe_r100b_*.gd` seeds", and the r99 landing committed its
six probes (`f1ff626`: `r99_probe_r99b_*` +1825), so this is an incomplete
landing rather than a hidden defect — but the capstone commit cannot reproduce
its own receipts. Fix: land the six seeds (they are already byte-identical to
the boundary probes; hashes recorded in §5).

### F2 — LOW, documentation: stale line count in §1

§1 says the parent fixture is "879 lines". The committed file is **892 lines**
(889 pre-fix; `git show --numstat` = 892/0). The number matches no version of
the file.

### F3 — LOW, documentation: "the driver's `EXPECTED` table"

§3 names "the driver's `EXPECTED` table"; no such identifier exists in
`r100_fpslat.gd`. The expected-error table is `ERR_ALLOW` (the `CASES` comment
block in `run_battery.py` does name the classes, so half the claim holds).

### F4 — LOW, documentation: the qa arm's cited derive pair is not on final bytes

§4 claims "each arm run ≥2× with byte-identical aggregate output … (… `c_*.log`/
`b_*.log`/`d_life*.log`)". For qa, `a_qa.log` is a stale variant from a
pre-battery sizing change (`quit0` `--ticks` 20000 → 4000: `n_pr=20000`,
`sha=2220fe03…`, `traj=1653f54d…` vs the final `n_pr=4000`, `sha=a67de47f…`,
`traj=a2be11de…`), so only `c_qa.log` is on the final bytes. The ≥2× property
does hold across the battery receipts (targeted + five full runs) and my
re-run, so the substance is verified; the cited evidence is one short, and the
qa re-sizing is not mentioned in the report.

### F5 — LOW, documentation: `bpy_rbw3d_io` did not time out

§4 says "the 10 `bpy_rbw3d_*` arms timed out at the fixed 20 s case cap". In
both B and C, nine timed out; `bpy_rbw3d_io` exited 0 at ~15.6 s with a degraded
inner receipt (`rc=137,m=,e=0,w=0,b=0`) → "exact stdout marker missing" (its own
blender child was killed). The ambient-load attribution stands; the mechanism
differs for that one arm.

### F6 — INFO: fixture header's d0 parenthetical omits its scope

The header says "d0 is the two-regime startup delta (1/tps for N<=2tps else
1/(2tps))". Per `r100-boundary.md` §3.1 that law is stated for **N ≥ tps**; for
N < tps the measured d0 is `1/N` (ffps5 pins `p1_d=0.200000000`, ffps10
`0.100000000`, ffps30 `0.025000000`). The pins are measured values and are
unaffected; only the comment's scope is loose.

### F7 — INFO: the area ordering claim rests on the failed-call diagnostic

"`body_entered` precedes `body_shape_entered`" is pinned only through stream
order/hash, because the shape callback is dead by signature defect (the
`arerr` line is the engine's failed call attempt). The fixture discloses this
("a real signature defect of the inherited probe, classified not hidden"); a
future probe that fixes the signature would make the ordering a direct
observation instead of a diagnostic position.

### F8 — INFO: "no pin was authored from scout/boundary text" is a process claim

It is not directly provable from the artifacts. What is verifiable was verified:
every pin is live-reproducible on the committed bytes, the falsified formula is
absent, and several cells are deliberately re-parameterized away from the
boundary (`quit0` 4k vs 20k, the qa surface on `RS_*` rather than `BM_*`),
which is evidence of fresh derivation rather than copying.

---

## 4. Residual risk and verification gaps

- **F1 is the only functional risk.** Everything else verified reproduces the
  committed claims byte-for-byte in this worktree. A landing that adds the six
  seeds closes it; nothing else in the diff needs to change.
- **Full-battery claims rest on author receipts.** I re-ran only the eight r100
  rows (8/8) plus the fresh-checkout single-row test, not the six 350-case
  batteries end-to-end. The author's receipts are internally consistent, map
  1:1 to their claims (run dirs ↔ `full_run*.log` ↔ totals), and the r100 rows
  are byte-stable across five post-fix runs and my own.
- **Load claims are not retroactively verifiable.** The "48 foreign `yes` hogs"
  contention story and the exact load levels cannot be re-observed; the
  degraded receipts (`rc=137` inner children, 20 s timeouts) are consistent
  with it, and the same arms pass in the green runs.
- **Envelope cells assert envelopes.** `noquit_unbound` (`boot=1,tickge1=1`) and
  the two inert-flag cells assert predicates, not hashes, by design; a
  future change could satisfy them with a very different stream. That is the
  declared contract for racy/unpinned surfaces, not a defect.
- **`arerr` is a diagnostic-position pin**, not a callback observation (F7).
- **`corpus/live/r100-author/runs/20261016T093136961416Z/` has `scratch/` only,
  no `verdicts.json`** — an aborted run dir not mentioned in the report. It
  changes nothing (its driver copy is the committed `da11495d…`), but the
  receipt map in §4 is seven runs plus one unexplained scratch dir.

## 5. Receipt map used by this seat

- Live re-derivation: `corpus/live/r100-reviewer/20261016T100152076348Z/verdicts.json`,
  `corpus/live/r100-reviewer/reviewer_run1.log`.
- Fresh-checkout failure: `/tmp/r100-fresh-runs/20261016T100442749094Z/verdicts.json`.
- Seed hashes (untracked, must land): area `a577d6265f78f1ff`, cls
  `0adf98aadd38cdc6`, life `427fc7d159f524da`, modes `249c0caf8ac4a1d5`, rt
  `8bfd76adf5ae5551`, sched `c61025594deff49d`.
- Boundary byte-identity: `cmp` vs `corpus/live/r100-boundary/probes/r100b_*.gd`
  (all six identical).

*Recommendation (advisory only, this seat does not admit): the lattice is
correct and live-reproducible; land the six probe seeds so the committed
capstone can reproduce its own receipts, and correct the four documentation
nits (F2–F5).*
