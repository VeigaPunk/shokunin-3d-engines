# r90 boundary — seat output (labrat, devin)

**Provenance:** seat fefa2adb, glm-5.3-flash lane (ufo-labrat), dispatched
post-15:01 window. Seat exposed **read-only tools only** (find/grep/read —
no exec, no write). Probe ran as read-only re-analysis over the existing
evidence corpus (504-run repair matrix + `mx/` logs, verifier
bimodal/crashaudit logs, scout's 1269-run corpus + vendored 4.7.2 source
snapshot, repaired pins, fixture/child source) — which already encodes the
heap-state variance question (the matrix ran `-P8` under parallel load;
cross-lane runs ran sequential — that spread *is* the
environment-sensitivity experiment). Body persisted verbatim by
orchestrator; nothing written or executed by this seat.

**Hypotheses:** (a) the 4 non-BIMODAL endpoint cases (`freeb_world`,
`detachb`, `twopin_hi1/2`) hide bimodality reachable via heap grooming;
(b) Dummy `free_rid` has a real dealloc path that UAFs under pressure;
(c) environment dependence of the clean/crash ratio admits a masked third
mode.

**Scenario:** exhaustive re-derivation over
`corpus/live/r90-repair/mx.csv` (504 rows), `mx/` child.logs,
`r90-verify` crashaudit/bimodal/battery logs, `r90-scout` runs + `src/`
4.7.2 snapshot, `run_battery.py` pins, `phys3d_joints.gd`/`r90_child.gd`.

**Observed (B-classes):**

- **B1 — two probabilistic UAF windows, not one.** Repair prose centers
  the teardown re-free; backtraces show a second window for the
  truncation cells: `freeb_ops@gp` crashes *inside* `joint_clear` (on_e,
  msz=6), `freeb_dyn@gp`/`chain3_freemid@gp` inside the post-free step.
  Scout `jend.gd` (different code shape) crashes at the *same statement*
  (`jend.gd:119` joint_clear) 3/4, survives 1/4 → clean DONE + teardown
  `Invalid ID`. The crash **site is statement-pinned** (first deref of
  the freed object), heap-lottery applies only to whether stale-slot
  validation faults — n_pre encodes this correctly. Prose incomplete,
  pin right.
- **B2 — non-exposed cases: no window by construction.**
  `freeb_world`/`detachb`/`twopin_*` free nothing mid-run → the teardown
  list `[joint,joint2]+joints+bodies+shapes` holds only live RIDs, freed
  joints-before-bodies. RID churn cannot inject a stale entry. 144/144
  matrix + ~96 cross-lane observations, all `rc=0`, incl. `-P8` load.
  **Not falsified**; residual: the literal "churn allocator pre-case"
  variant is unmeasured (no exec here) and would only matter via a
  non-RID server-internal channel — no evidence of one.
- **B3 — Dummy inertness measured at two independent layers.** (i) Dummy
  RIDs are invalid: `EN0 … joint=RID(0)`, pinned `rid@dummy` shows
  `j1_valid=false`, `j2_eq_j1=true` → teardown `is_valid()` guard never
  calls `free_rid`. (ii) unconditional mid-run frees (incl. double-free)
  produce **e=0** in all 168 dummy matrix rows — no error path reached,
  where GP/Jolt log `Invalid ID`/`no owner` on identical sequences. A
  real deleter would error on the second free. **No UAF path exists on
  Dummy under any pressure reachable here.** Residual: Dummy source not
  vendored (snapshot = jolt+godot_physics only); body/shape
  RID-invalidity inferred from `joint=RID(0)` + zero-error, not a direct
  `is_valid` print.
- **B4 — ratio is environment-malleable; envelope is load-bearing and
  holds.** `freeb_twice@gp` crash rate: 3/12 (mx `-P8`), ~4/9 (verifier
  seq), 4/4 (scout jend shape) — 25%→100% swing across setups. Every
  clean row logs the *full* Invalid-ID tally (freeb_twice e=2) and every
  crash e-one-lower — the crash IS the teardown error path faulting
  post-DONE (msz=full). Heap state flips *which named mode* fires; **0
  realizations outside the two named modes** in 504 matrix rows +
  scribe's 726-log simulation.
- **B5 — every plausible third mode refuses honestly.** Hang → rc 137 +
  sig11=0 → `mode_ok=0` (admitted-rc superset harmless — sig11 gates it;
  a 137 hang class exists in corpus: scout `prio_unmade` bug). Non-11
  signals (signal-4 class exists in r88 forge logs) → sig11=0 → refused.
  Crash earlier than n_pre → `msz<n_pre` → refused. Torn line inside
  prefix → sha mismatch → refused. Buffered-DONE loss on post-DONE crash
  → `msz<full` → refused. Zero occurrences in ~1230 logs.
- **B6 — envelope lumping + one theoretical masking channel.** (i) A
  mid-ops crash at `msz∈(n_pre,full)` (e.g. `freeb_ops` dying after
  `cleared`, msz=7) is silently admitted under the same token as
  msz=n_pre — deliberate site-lumping; unobserved (all mid-ops crashes
  logged msz==n_pre). (ii) If a post-free alloc recycled the freed slot
  before teardown, the re-free would free a *live foreign object* →
  clean-admitted, invisible because e/w are dropped — **0 occurrences**
  (every clean row's e equals full Invalid-ID tally). Verdict-neutral
  either way; worth one line in the record.
- **B7 — header wording slip (cosmetic).** Fixture header: "crash
  realized on 10 of those 20 tags inside the 12-rep window" — matrix
  realizes **9**; the 10th (`freeb@gp`, 2 crashes) came from
  simplifier-lane artifacts outside the matrix. Same class as scribe B2.

**Conclusion:** **No repair claim falsified.** (a) non-BIMODAL exclusion
is structurally sound and measured-clean ~240×; (b) Dummy is
measured-inert at two layers, though the claim rests on instrumentation,
not vendored source; (c) environment flips mode *rates* (25→100%) but
never the admission class — all unmeasured third modes fail honestly
rather than mask (B6(ii) theoretical only). Recommend: B7 one-word fix;
optional N-note documenting B1's second window and B6's lumping
semantics.

**Cleanup:** zero writes, zero processes, zero scratch artifacts; repo
untouched (`corpus/live/` untracked regardless). The report file itself
could not be written — this substrate exposes no write/exec tools; the
parent executor must persist this text to
`reports/round-90/r90-boundary.md` if wanted. One probe, done; stopping.
