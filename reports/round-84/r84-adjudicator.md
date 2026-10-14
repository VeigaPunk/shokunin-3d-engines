# R84 adjudicator (Sol) — Jolt backend pinning + write-phase discriminant

Round: 84. Wave: `shokunin-train-20261101-w15`. Work commit `01f7d4f`,
folds commit `a56f683` (post-fold the jolt child.log gains one pinned
`jolt_dss_class` line — documented delta; all 188 case tuples unchanged).

## Declared move

Two r83 corrections as first-class cells: `phase_delta` (the
write-phase latency discriminant measured in one cell — process-phase
write → `body_entered` at delta=2, physics-phase write → delta=1) and
`jolt_edge` (child re-exec under a generated `physics/3d/physics_engine=
"Jolt Physics"` project, pinning the backend split
{same-signature | differs-constants | inverts} across five reduced
parent-cell replays).

## Claim adjudication

- **Both cells CONFIRMED** — 188/188 on the landed tree, verifier
  AGREE 15/15 (case tables byte-identical ×4, results sha
  `73ee6fcb…`; prior-186 normalized prefix `c0c3fcbb…` identical to the
  r83-verifier hash — cross-round zero drift). Insertion-only
  (+617/−6; deletions all doc/dispatch, verified).
- **Backend split CONFIRMED with live witness**: `isect`/
  `contact_stale` keep the DEFAULT signature, `cast`/`btm` keep the
  edge on different solver constants (safe `0.149841/0.150024`,
  travel `-0.998535`), `static_nopair` inverts. The ClassDB-pair
  gate alone was registry-level — fold adds `jolt_dss_class=
  JoltPhysicsDirectSpaceState3D`, the live server object class, pinned
  in the verdict map. Impersonation verified by reviewer: DEFAULT and
  near-miss `"Jolt"` both print `jolt_backend=unexpected` → map
  mismatch; now the dss-class pin double-arms it.
- **`phase_delta` CONFIRMED + premise corrected**: `proc_delta=2
  phys_delta=1` byte-identical across DEFAULT/Jolt (3/3 each).
  **Critic F1 refutes boundary §6b/§8.5/§9 and reviewer F3's premise**:
  the flagged `delta_pf=1` cell was a first-entry artifact — the
  boundary's `d-phase` receipt co-locates 3 areas × 4 bodies and
  `B_proc`'s `logB[0]` is pair A's entry; the critic's keyed
  reproduction (`contam.r1–3`) gives `B_first=1` but `B_own=2`, and the
  boundary's own clean n=1 cells read delta=2 ×8. The landed pin stands
  — the `sig_log.clear()` before the physics-phase contrast is exactly
  the fix this artifact needed (r83 C2 lesson, already folded).
- **Timeout/orphan + log-forgery discipline held**: `timeout -s KILL
  30` bounds both child arms; `DirAccess.remove_absolute(child.log)`
  now precedes each spawn — a stale single-slot log can no longer
  forge a verdict map on re-run.

## Corrections folded (`a56f683`)

- **Critic (dispatch totality)**: bare/unknown `--arm` under `--child`
  printed `CHILD_RESULT pp_edge0=…` (threaded body ran silently —
  exit 0). Dispatch is now a total `match`: unknown/missing arm prints
  `child_arm=unknown` + `quit(2)`; the threaded parent passes
  `--arm=threaded_edge` explicitly. The parent's 6→7-key verdict map
  already rejected the wrong body; now the child itself refuses.
- **Critic (classifier totality)**: `jolt_isect`'s `elif` claimed
  `differs-constants` from zero evidence (all-zero reads on Dummy).
  Now requires `s0==1 and back==1` — the backend must actually answer
  the edge probes before a constants verdict is earned.
- **Critic + reviewer F2 (crash-not-class)**: `cast_motion` index
  reads size-guarded — a size-0 `PackedFloat32Array` backend classified
  `unexpected` instead of aborting at the unguarded `c1[0]` (exit 137
  on Dummy; the abort-without-quit also let the battery's 20 s case
  timeout fire before the inner 30 s — now unreachable on that path).
- **Reviewer F1 (leak invisibility)**: ObjectDB leak WARNINGs now fail
  the parent scan in both child arms — mirrored `LEAKED_OBJECTDB`
  (an unfreed Node previously left `WARNING:` — not an `ERROR:` line —
  invisible to the parent while the row PASSed).
- **Critic (log-forgery)**: `DirAccess.remove_absolute(child.log)`
  before each spawn; the never-unlinked single-slot log could
  otherwise feed a stale verdict map to the parent on re-run.
- **Simplifier V3**: header's stale "unprobed for crashes" clause now
  names the r84 in-battery probe; README case count corrected
  83→188 (carried staleness the reviewer flagged).

## Deferred / noted (not folded)

- **Critic exit-code blindness**: `OS.execute` returns 0 when the
  *shell* itself is SIGKILLed (python reports −9) — engine-level, no
  in-script fix; bounded by timeout-KILL + log-unlink + verdict-map
  exactness. Recorded as residual.
- **Reviewer F3** (`Engine.is_in_physics_frame()` diagnostic witness):
  premise partially refuted by critic F1; pin already keyed by
  `sig_log.clear()`. Deferred — diagnostic nicety, not falsifiability.
- **Simplifier V2** (`_spawn_child` single-sourcing): −318 B, proven
  188/188-identical — deferred until a third spawn site (Jolt×threaded
  arm) justifies rewriting the landed r83 block; the fold would rot the
  `r84-author.md` fixture-sha citation today.
- **Nits**: author-report line cites (`:791-1003` vs actual
  `:791-1001`; scan `:691-709` vs `FileAccess.open` at `:693`) are
  report-text — corrected here, not in the landed artifact.

## Seat accounting

9/9: author `01f7d4f` (+617/−6, two cells, 188/188 ×2, impersonation
guard armed); scout (backend split pre-measured, flag-collision +
counter-stability hazards flagged); boundary (delta=2 replicated from
both idle sub-positions — its `delta_pf=1` premise was later refuted as
a first-entry artifact by critic); critic (5 counterexamples —
dispatch/classifier totality, size guard, stale-log, keyed-delta
refutation — all foldable and folded); reviewer ACCEPT 3-LOW (F1/F2
folded); simplifier (V3 folded; V2 deferred on sha-citation cost; five
armed-witness keeps correctly refused); scribe (child-log mutability +
revision-scoped join hazards recorded); baseline zero-drift pre/post
(`c4b2fa2`→`01f7d4f`, 188/188, seeds unchanged); verifier AGREE 15/15.

## Verdict

**ADMIT-corr** — Jolt backend pinning lands with a live-object witness;
the write-phase discriminant is a first-class cell; dispatch and
classifier totality hardened on the child paths. Bounded: Godot
4.7.2.stable.arch_linux.ed1daf0bf, GodotPhysics3D/Jolt pair, this host.
Work `01f7d4f` + folds `a56f683`; report-last commit follows.

r85 frontier seeds: Jolt × `run_on_separate_thread` cross-product;
Dummy-backend refused-shape cells (now classifiable, not crash);
server-write phase-delta cells; static re-pair mechanism; the
signal-kill exit-code blindness if a third child arm lands.
