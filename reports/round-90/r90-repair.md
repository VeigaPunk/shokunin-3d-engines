# r90 verifier-repair — teardown-UAF envelope

Round 90's committed pin (`191f131`) was rejected by the verifier
(`r90-verifier.md`): `freeb_twice@gp` fired its clean realization inside
run2 (224/225), and the teardown re-free UAF window exists for every
freed-RID case on every real backend while only `freeb_ops@gp` carried
mode admission. This is the repair record.

## Mechanism

`r90_child.gd`'s teardown frees `[joint, joint2] + joints + bodies +
shapes` unconditionally at DONE. Any case that mid-run frees one of
those RIDs leaves the teardown re-free a use-after-free: the engine
either returns `Invalid ID` (clean rc=0, error counted) or SIGSEGVs
(rc 134/137/139, `handle_crash … signal 11`), decided per run by heap
state. Cases that quit inside `_initialize` (sweep/rid/api) never reach
the loop; `freeb_world`/`detachb`/`twopin_*` free nothing mid-run.

## Evidence — 504-run matrix

`corpus/live/r90-repair/mx.csv` + `mx/` child logs: every endpoint case
× {DEFAULT(gp), Jolt Physics, Dummy} × 12 reps, capturing
rc/sig11/err/warn/msz/msha. Findings vs the committed pins:

- `freeb@jolt`, `freeb_dyn@jolt`, `freeb_ops@jolt`, `freeb_twice@jolt`:
  12/12 teardown/mid-ops SIGSEGV under parallel load — all four were
  pinned `rc=0`. (Author/battery sequential runs realized the clean
  mode; the window is load-sensitive.)
- `freea@gp`: 11 clean + 1 post-DONE crash, identical m-sha across both
  modes — direct proof the M-stream is mode-stable for teardown windows.
- `freeb_twice@gp`: 9 clean / 3 crash (verifier: 5/4 over 9) — bimodal.
- `freeb_ops@gp`: 12/12 mid-ops crash here; clean observed earlier —
  bimodal, prefix already correct.
- Deterministic mid-ops crash cells: `freeb_dyn@gp` (msz=8),
  `chain3_freemid@gp` (msz=2) — 12/12.
- Dummy: 168/168 clean across every case — `free_rid` is inert; no UAF
  mechanism exists there. Cells stay pinned `rc=0` (a Dummy crash would
  fail the row honestly).
- Non-exposed cells (`sweep`/`rid`/`api`/`freeb_world`/`detachb`/
  `twopin_*`): 12/12 single-mode — untouched.

## Repair

`phys3d_joints.gd`: `GP_CRASH_CASES`/`GP_BIMODAL` replaced by a per-tag
`BIMODAL` envelope: `tag -> [n_pre, full_msz]` for all 20 exposed
(case × {gp,jolt}) cells. Emission `mode_ok=1,m<n>=<sha>` where the sha
covers the first n_pre M-lines — the full stream when every observed
crash lands post-DONE, the shared prefix when mid-ops crashes truncate
(`freeb_ops`@gp/jolt n=6, `freeb_dyn`@gp n=8, `chain3`@gp n=2).
Admission: clean (`rc=0,sig11=0,msz==full`) or crash
(`sig11=1,rc∈{134,137,139},msz>=n_pre`); anything else is mode_ok=0 and
closes the row. e/w are mode-dependent and dropped for these cells.

`run_battery.py`: the 20 exposed cells repinned to the envelope
(prefixes unchanged — `m6=124dfece…`, `m4=e7c8b9cc…`, `m2=c1b063f…`,
`m8=c3d61244…` carry over byte-identically).

## Fold

Simplifier vfold applied (`corpus/live/r90-simplifier/fold.diff` F1–F6:
dead `throw_` scan, unreachable dirname guard, unused `c_rid`/`bpos`,
`jt()` reader dedup, `freeb_dyn` handler merge — −20 lines) + F7 header
doc rewritten to the new envelope. 96 standalone arm runs ×2 variants
byte-identical; both crash modes observed within the proof window.
Scribe blocking fixes: README 217→225; header "reachable" →
mechanism-present/realized-on-10-of-20 wording. Scribe independently
simulated all 726 logged BIMODAL-tag realizations into the repaired
emission — 0 outside the envelope, 0 sha mismatches.

## Verification

- Standalone 8 arms: PASS lines byte-match the repinned literals.
- Battery `corpus/live/runs/20261015T151739410829Z/`: **225/225 PASS**
  (179 ordinary, 46 negative), seeds-unchanged.
- Prior-217 rows: untouched (only the 8 r90 rows' exposed cells changed).

## Held for adjudicator / next wave

- Critic + boundary seats were dispatched twice and died on rate-limit
  sweeps both times (13:01, 15:01 UTC); retries remain queued. The
  verifier's REJECT already produced this repair; scribe's 726-row
  simulation is the strongest available pin-soundness evidence.
- Scribe B3 (non-blocking): r90-scout.md artifact conflicts — its own
  `fl_proj_jolt_hmot.r*` contradict the quoted HM-1 law and PRIO-1's
  quoted warning text exists nowhere; read those cells skeptically.
- `reports/round-1-20261015/` is a foreign-fleet advisory artifact
  (PathCritic, not this lane's numbering) — held out of commits, logged
  in the fleet rogue-edit audit.
