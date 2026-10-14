# R85 adjudicator (Sol) — Jolt×threaded cross-product + Dummy negative control + server-write phase-delta

Round: 85. Wave: `shokunin-train-20261101-w16`. Work commit `f230443`,
folds commit `4e6fbe3`.

## Declared move

Three cells on the generated-project child harness: `jolt_threaded`
(Jolt + `run_on_separate_thread=true` — threading-invariance arm),
`dummy_refused` (Dummy backend negative control — must read
`unexpected`, not a known Jolt class), `srv_phase_delta`
(PhysicsServer3D write path — zero node constructors, 14 server calls).
Total cases 188 → 191. Structural: `_child_split(prefix)` shared sweep
(jolt_edge/jolt_threaded/dummy_refused), `_spawn_child` single-sources
the four child-spawn sites, bounded dss-fetch retry on the threaded
child path, `allow_inaccessible` true exactly on the two threaded arms.

## Recovery note (provenance)

The first author seat died mid-landing on a rate limit with a
parse-broken diff (`_child_jolt_threaded`/`_child_dummy` referenced,
never defined — every phys3d row would have read Parse Error). The
boundary seat caught the dead-on-arrival v1 and re-measured v2 green;
a deepseek completion seat finished the bodies and landed `f230443`.
All wave-B seats ran deepseek-flash.

## Claim adjudication

- **All three cells CONFIRMED.** 191/191 PASS across author×2,
  reviewer, verifier×2, integrator — four independent executions hash
  to the same tuple sha `efb81318…`; prior 188 rows at identical
  positions with stdout+stderr byte-identical (verifier checked wider
  than the author: three frozen receipts).
- **Threading invariance CONFIRMED at map + constant level.** The
  `jolt_threaded` verdict map is byte-equal to `jolt_edge` modulo the
  key prefix plus `jt_threaded=true`; raw constants identical
  (`0.149841/0.150024`, `-0.998535`, `set=0,1 in=0,1,4 out=4,0`).
- **Backend-determinism CONFIRMED.** The same sweep under another real
  backend emits `same-signature ×5`; under Dummy `unexpected ×5` —
  the class is backend state, not a classifier default. Both halves of
  the jolt_threaded pin independently load-bearing (non-threaded Jolt →
  `jt_threaded=false` same map; threaded DEFAULT → `backend=unexpected`).
- **Mutation matrix 6/6 load-bearing** (critic); forged child.log
  destroyed pre-run (verifier property test).
- **Baseline zero-drift both phases**; scribe verified fold deltas
  exact (also caught an r84-scribe 12-vs-11 ERROR-count discrepancy —
  corrected in the fold).

## Corrections landed (fold `4e6fbe3`)

- `LEAKED_OBJECTDB` singular `instance was` accepted (boundary finding;
  masked by the stderr gate, coverage now matches intent).
- Falsified comment counts corrected to measured 11/12 and 10/10
  (simplifier — falsifiability repairs, not weight moves).
- Stale body-diff enumeration reworded; README 191/145.

## Corrections recorded, not folded

- Critic M6: `jt_threaded` is a child self-report — a forced-true print
  defeats it. Real threat model still caught (ablated key → false →
  FAIL; non-threaded Jolt → 0/12 refusals reproduced). Scope noted.
- `dummy_class` CHILD_NOTE key is misnamed (it is actually the Jolt
  ClassDB existence flag); renaming would break the pinned jolt
  child.log sha — deferred to a deliberate next-round rename.
- Reviewer F3: r85-author §5.4's "Dummy silently hangs a threaded
  child" is over-broad — threaded Dummy + `_child_split` exits 0 clean;
  the rc-137 class is `_child_threaded`/`PPQueries`-specific.
- Verifier caveat: `jolt_threaded` child.log is NOT byte-stable
  (refusal-block count varies; 11–12 observed, tolerance ≥8 never
  stressed below 11); the MAP is the stable witness — do not byte-diff
  that log as a regression signal.
- Latent pre-existing: `_child_threaded`/`PPQueries` Dummy-type
  hazards (`:297`, `:944` per boundary) — no Dummy parent arm exists.

## Verdict

**ADMIT-corr** — backend × threading cross-product pinned with a live
`jolt_dss_class` witness, Dummy negative control backend-determined,
server-write tier cell landed, harness hardened (regex singular, counts,
dispatch totality preserved through the `_spawn_child` single-sourcing).
Bounded: Godot 4.7.2.stable.arch_linux.ed1daf0bf, Jolt/GodotPhysics3D/
Dummy, this host. Work `f230443` + folds `4e6fbe3`; report-last follows.

r86 frontier seeds (r86-scout + nas-scout + bpx-scout landed):
threading-invariance extension, Dummy silent-floor semantics,
script-size fetch-gate ladder, deferred-coroutine hang→137 class,
avoidance/lazy-cache nav surface, bpy+three.js cross-runtime lattice.
