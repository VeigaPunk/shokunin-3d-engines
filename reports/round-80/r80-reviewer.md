# game-dev-3d round 80 — reviewer (seat: reviewer, host: devin)

Reviewed artifacts: the r80 diff as landed — fold `faae4e0` + simplifier fix
`e32e2de` — final tree at HEAD `ae89c13` (report-last). Fixture blobs at
review time: `corpus/fixtures/bpy_sync_probe.py` sha256
`bfa80ed4bd29…` (1041 lines, post-D1) and `corpus/fixtures/bpy_battery.py`
sha256 `ae3b04b1…` (302 lines). I snapshotted the author's working tree
mid-flight (`corpus/live/r80-reviewer/author-snapshot/`, probe
`e9609814…`/battery `ae3b04b1…`, 14:22–14:23 UTC), verified the committed
`faae4e0` blobs byte-identical to that snapshot, and measured the
`e32e2de` delta as exactly the three-line `slept=` removal on the *unpinned*
`walltime_s*` rows (ARM-stream diff below) — so the audit applies to the
final blob with that one measured delta.

Repo/runtime: lane root `~/Projects/shokunin/game-dev-3d-shokunin`; single
canonical runtime `/usr/bin/blender` (only one on PATH) = Blender 5.2.1 LTS
(hash `9e2066aef7ef`, built 2026-09-01), `-b -P` headless — same build as
r79/frontier. Godot side untouched: `git diff --name-only faae4e0~1..HEAD`
lists only the two bpy fixtures, `reports/round-80/`, and the `LOG.md` /
`SCORECARD.md` verdict entries — no `.gd` file, no `run_battery.py`; post-fold
Godot battery 176/176 (below).

**LSP note:** no `lsp` device is exposed on this substrate (MCP inventory =
the `rea` binary-analysis server only), so caller/definition/diagnostics
checks are text-level (grep/read), not server-verified semantic proof —
recorded as a verification gap. Affected-caller check: the only tracked
consumer of the probe is `bpy_battery.py:24` (`PROBE = HERE /
"bpy_sync_probe.py"`); `run_battery.py` carries its own `.gd` CASES list and
does not glob the fixture dir (re-confirmed by the 176/176 run).

**Timeline (why this report covers a moving target):** the wave dispatched
all seats concurrently. At my base audit (battery receipt
`bpy-20261014T141959158926Z`, 14:19:59 UTC) HEAD was `3f9e070` and the tree
was clean. The fold landed in the working tree 14:22:44/14:23:17, committed
`faae4e0` 14:25:02; `e32e2de` 14:27:28; `ae89c13` 14:28:16. All measurements
below are pinned to blob hashes, not to wall-clock.

## Verified on the final committed state (my own runs)

1. **Battery 64/64** — `python3 corpus/fixtures/bpy_battery.py --runs
   <abs>/corpus/live/r80-reviewer/runs` → exit 0, `totals: cases=64 pass=64
   fail=0 (signal_fail=0 quirk_drift=0) launch_ok=True done_marker=True
   fatals=0 exit=0`. Receipts: final blob `bpy-20261014T143027995551Z` +
   `bpy-20261014T143032349167Z`; faae4e0 blob `bpy-20261014T142517587352Z` +
   `…142546950623Z` (64/64); pre-fold base `bpy-20261014T141959158926Z`
   (37/37).
2. **Byte-stability of r79's 37 cases (the round's declared hard
   requirement)** — my final-blob receipt vs the r79 post-correction receipt
   `corpus/live/runs/bpy-20261014T141354732737Z/verdicts.json`: **37 common
   rows, 0 mismatches** on the stable fields (case/arm/point/layer/pinned/
   observed/non_signal/verdict/reasons); r79 case print order preserved; the
   **78 r79 ARM lines byte-identical**; `n_arm_lines` 78→112 (34 new evalcat
   lines, expected). `bpy_battery.py` diff is insertions-only (docstring +
   CASES :81–192); the probe diff's single deletion is the runner-tuple line
   — `:1033-1035` adds `arm_evalcat`; the 9 r79 arms' code is untouched.
3. **Determinism** — final-blob runs 1 vs 2: ARM streams byte-identical
   (112 lines). faae4e0-era runs likewise. The `e32e2de` delta between eras
   is exactly:
   `- slept=0.50 / - slept=2.00 / - slept=1.00` on `walltime_s0/1/2`
   (unpinned rows) — the D1 fix is real and sufficient.
4. **Frontier-input replay (the artifact the move folds in)** — re-ran the
   three committed probes on this host: `timeout 60 blender -b -P
   corpus/live/frontier-bpyeval/bpy_evalcat_probe{,.2,.3}.py` → exits
   0/0/0, stderr 0 bytes each, elapsed 4092/463/432 ms (report: 4066/458/
   417). stdout **byte-identical** to `corpus/live/frontier-bpyeval/runs/
   evalcat{1,2,3}.stdout.txt` except `evalcat2.stdout.txt:8` — the
   ActionSlot repr pointer (`0x7f1e7994ce18` vs my `0x7f3b1654ce18`); that
   is the one nondeterministic field in the frontier corpus — never pin
   `slot=`. Probe sha256s match the report's pins (`c99d8143…`,
   `c5b16ba6…`, `014c314f…`). Receipts:
   `corpus/live/r80-reviewer/frontier-replay/`.
5. **Handler lifecycle (load-bearing for the arm's design)** —
   `blender -b -P corpus/live/r80-reviewer/handler_lifecycle.py` → exit 0:
   `read_factory_settings` clears python handlers and fires none
   (`after_reset_count=0 calls=0`); a cleared handler cannot fire on a dirty
   update (`calls=0`); a freshly installed handler fires on a dirty update
   (`calls=1`); reset-with-installed → `reset_calls=0`. The fold's
   `_ec_register()`-inside-`_ec_reset()` pattern (per sub-probe) is correct
   and necessary; a module-level registration would have been silently dead
   from the first reset.
6. **Falsifier liveness (re-ran the author's scratch check)** —
   `blender -b -P corpus/live/r80-author/falsify_check.py` → exit 0,
   `violations 0→1→1→1→2`; `edge=FALSIFIED` on synthetic bare flush and
   synthetic bare handler-fire; quiet bare stays `edge=1`; `invoked=bpy.ops`
   flush stays `edge=0` (receipt
   `corpus/live/r80-reviewer/falsify_check.stdout.txt`). The closed-set
   check discriminates; it is not a constant.
7. **Falsifier wiring (read of the final blob)** — `_ec_edge` (probe
   :581-593) forces FALSIFIED and increments `EVALCAT_VIOLATIONS` whenever
   `invoked is None` and (held moved OR any watched-handler delta); the
   `closed|violations=N` row (probe :1028-1030; battery :190-191) gates it.
   A bare class that flushes or fires fails both its own edge pin and
   `closed`. No false-PASS path found.
8. **No-self-flush ordering (r79-critic's invariant)** — on all 8 bare rows
   and all 7 op rows the pinned held read precedes the fresh get in its
   window (e.g. driver held :714-715 before fresh :716; op_apply held read
   :860 before the row emit :862). The three exceptions are labeling-only
   (LOW-1).
9. **Parser/pin hazards** — demonstrated on the real parser (`importlib`
   load of `bpy_battery.py`, `parse_arms` :211-220): multi-token values
   truncate (`held_mesh=verts3 xmax6.000` → `verts3`), duplicate
   `(arm,point,layer)` tuples last-wins, pins are exact-string only. The
   fold avoids all three: unique tuples, space-free witnesses
   (`verts3:xmax6.000`, probe :541-549), derived booleans
   `dup_fired`/`fc_fired` for the ×1/×2 counts (probe :591-592).
10. **Sibling isolation** — post-fold `python3 corpus/fixtures/run_battery.py
    --godot /usr/bin/godot` → `176/176`, `seeds_unchanged=true`, receipt
    `corpus/live/r80-reviewer/runs/20261014T142720186120Z/verdicts.json`
    (seed map now carries both new fixture hashes). My pre-fold attempt
    (`…T142144294364Z`) shows 176/176 cases but `seeds_unchanged=false` —
    the author's fixture writes landed mid-run (14:22:44/14:23:17); recorded
    as an environment collision, superseded by the post-fold run.
11. **Same-identity graph** — the new rows re-witness the shared-graph
    identity: `ev_get` pins `same_obj=True` (receipt line), consistent with
    r79's `shared_same_graph` and the frontier's `dgident dg0_is_dg1=True`
    (evalcat2 receipt). One graph, evaluated in place; ops do not reroute.

## Findings (severity order)

**LOW-1 — three DEG rows label a post-flush read as `held=`.** `driver_wU`
(probe :722), `keyframe_wU` (:763-764), `con_rna_wU` (:838) emit a
`held=`/`held_mw=` value read *after* a fresh `evaluated_depsgraph_get()`
already flushed the shared handle (driver/con_rna: the fresh read inside the
preceding `_ec_edge` row; keyframe: `tagged` at :762). No pinned value is
wrong — the receipts (`held=(7,0,0)`, `(3,0,0)`, `(0,0,0)`) are true
post-eval states, and a bound fcurve at the tagged eval would change the
value and fail the pin (no false PASS). But the field name implies a
held-stale witness the row does not have; the r79 arms keep the
held-before-fresh order (e.g. `transform` wU-held before wU-fresh). Smallest
fix: rename the key (e.g. `post=`) or move the read before the fresh get
(driver/con_rna); for keyframe_wU the fresh get *is* the row's instrument,
so a rename is the only option. Actionable-lite, hygiene only.

**LOW-2 — `_ec_edge`'s violation predicate counts a bare `dund` fire as
FALSIFIED.** probe :585-586 includes `d["und"]`; an `undo_post` fire is not
an eval event (frontier §3(d); `dund=0` on every row that carries it — 22/23
EDGE rows, the `closed` row emits none — and no row shows a nonzero value).
On any runtime where undo_post fires without an eval (e.g. interactive), a
bare row would be flagged FALSIFIED with no flush — a false falsification.
Unreachable under `-b -P` today. Drop the term or document it as a
conservative guard.

**LOW-3 — module docstring is still the r79 nine-arm description.** probe
:1-38 documents the r79 lattice; the file now carries a 10th arm and the
619-line r80 section (:417+). The battery docstring got a 3-line r80 pointer;
one matching line in the probe suffices. Documentation-only.

**NOTE-1 — `evalcat_keyframe_wU_inert` pins `upd_dup=1` (battery :137-139),
the only exact handler count among the r80 rows** — against the battery's own
comment (:89) "op eval counts pinned as dup_fired (>=1), never exact". Stable
across frontier probe3, the author's run, and all four of my post-fold battery
runs (`upd_dup=1` in every receipt; ARM streams byte-identical within each
era). Cross-build risk only; it is load-bearing for the tagged-path witness,
so keep it with a comment or emit `upd_dup_fired=True`.

**NOTE-2 — `held=na` rows pin eval only via `dup_fired`** (`op_mode_object`
:167-169, `op_conadd` :175-177): structurally non-discriminating witnesses
(`held_mw` is (0,0,0) pre and post because the constraint is inert without a
target). Disclosed in `r80-author.md` §Remaining unknowns; bounded by the 5
discriminating op rows.

**NOTE-3 — the pinned bare catalogue (8 classes) is narrower than the
round's measured inert surface** (scribe 19-class sweep, boundary 45-class
screen, critic 37-class sweep — all scratch). The adjudicator already
deferred ~6 representative bare rows to r81
(`r80-adjudicator.md`, "critic fold-guidance … deferred to r81"), which is
the correct disposition; no action this round.

**NOTE-4 — label fidelity, both directions, worth recording.** The frontier
table's `location_clear` "n/a (value undiscriminating)"
(`fa-bpy-evalcat.md:38`) is *contradicted by its own receipt* (held 5→0 at
`op_misc loc-clear`, evalcat1:24-25) — the fold correctly pins
`held=flushed` (battery :170-173, probe :937-944). The `constraint_add` n/a
(`:39`) *is* genuinely non-discriminating (held_mw unchanged; dup×2 is the
witness). The two n/a labels are not the same case; the fold treats them
correctly and differently.

**NOTE-5 — one nondeterministic field in the frontier corpus**: the
ActionSlot pointer repr in `evalcat2.stdout.txt:8` (my replay differs only
there). Never pin `slot=`; normalize if the frontier probe is ever promoted
to a tracked fixture.

## Claim wording / honest saturation (verified)

- The durable verdict artifacts carry bounded wording: `LOG.md:979-982`
  ("bounded over ~100 probed classes, four independent sweeps"),
  `SCORECARD.md:106` ("bounded closure confirmed — ~100 probed mutation
  classes, 0 falsifiers across 4 independent sweeps"), and the adjudicator
  discloses the `faae4e0` subject's "45+ classes" over-attribution
  (`r80-adjudicator.md`). The critic's scope correction was folded before
  report-last. The in-fixture comment (battery :83-84) states the claim as
  declared ("enumerable and CLOSED") — acceptable as a claim statement; the
  evidence row is scoped by construction (8 bare rows + event axis; ops
  in-set by call). No unqualified saturation claim survives in the verdict
  artifacts.
- Wall-time axis: pinned `edge=absent`, held stale, zero deltas (battery
  :183-186, probe :991-1012) — bounded to 0.5/2.0/1.0 s sleeps + context
  re-touch; "no eval event on the time axis" is a mechanism inference from
  three samples plus the absent headless pump, not an unbounded proof.

## Residual risk / verification gaps

- No `lsp` device (above): cross-references are text-level only. The
  fixture's consumer surface is one line (`bpy_battery.py:24`); no other
  tracked caller exists (grep over the tree, ignored scratch excluded).
- Cross-build: every pin is receipt-derived for Blender 5.2.1 LTS
  (`9e2066aef7ef`), `-b -P`, this host; no tolerance story (inherited from
  r79). The only exact handler-count pin is `upd_dup=1`; op multiplicity is
  pinned as booleans.
- The falsifier is bounded to the arm's probed rows; unprobed surfaces are
  explicit in the adjudicator/scribe lists (library linking, node trees, 5.x
  action/slot paths beyond the measured one, render-engine paths, edit-mode
  mesh ops, timers, interactive msgbus). A counterexample there is a
  legitimate r81+ result, not a defect here.
- Op-eval multiplicity ×1/×2 mechanism unmeasured (booleans pinned; raw
  counts remain in receipts for drift).
- `resume_continuity_v1` has no surface in this lane (grep: no matches
  outside ignored scratch) — the seat-card resume clause does not apply to
  these fixtures.
- My pre-fold Godot run was invalidated mid-run by the author's edit
  (recorded above); the post-fold run is the valid receipt.
- Reviewer-seat timeline: this report lands after `ae89c13` report-last
  (the wave ran seats concurrently and the round closed quickly). It is a
  late-seat audit pinned to blob hashes; it does not reopen the verdict.

## Recommendation (not a judgment — the canonical runtime judges)

The committed fold is sound. Every contract row I re-measured holds:
r79's 37 cases byte-stable (0 mismatches, 78 ARM lines byte-identical), the
9 r79 arms untouched, 64/64 with byte-identical replays, the falsifier live
and correctly wired, sibling isolation intact (176/176, seeds unchanged),
one canonical runtime, shared-graph identity re-witnessed. The LOW findings
are labeling/latent-hygiene (LOW-1 three field names; LOW-2 one predicate
term; LOW-3 one docstring line) and do not affect any pinned value or the
verdict gate. Findings reported; no tracked edits by this seat — writes
confined to `reports/round-80/r80-reviewer.md` + `corpus/live/r80-reviewer/`.
Stopping here.
