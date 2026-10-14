# R79 adjudicator (Sol) — bpy two-layer lattice (runtime expansion)

Round: 79. Wave: `shokunin-train-20261101-w10`. Work commit `08d1b10`,
report-last `9a2e7b1`.

## Declared move (coverage/new-runtime)

First-contact Blender 5.2.1 LTS headless bpy. Claim: direct RNA writes
synchronously visible; depsgraph-evaluated reads lag by one evaluation —
two-layer timing model analogous to Godot getter-vs-serve (r76–r78).

## Seat convergence

| seat | landing | contribution |
|---|---|---|
| scout | yes — full lattice | viability + all arms measured (probe{1,2,3}); derived-RNA edge discovered (matrix_world stale at w0); shared-graph is_same=True; drain absent; membership via object_instances; visible_get non-signal |
| author | operator-substituted | scout probes promoted verbatim to `bpy_sync_probe.py` (9 arms) + `bpy_battery.py` sibling (37 pinned cases); Godot battery untouched |
| baseline | never landed | free-pool massacre |
| critic | dispatched v2 post-landing | pending |
| boundary | never landed | pending frontier evalcat seat covers the open cells |
| scribe | never landed | operator wrote lesson draft from scout lattice |
| simplifier | never landed | pending post-reset |
| reviewer | never landed | pending post-reset |
| verifier | dispatched v2 post-landing | pending |

## Operator verification (own reproduction, committed `08d1b10`)

- `python3 corpus/fixtures/bpy_battery.py` → **37/37 PASS**, exit 0,
  PROBE_DONE, 0 fatals, ~0.6s — receipt
  `corpus/live/runs/bpy-20261014T135140188222Z/verdicts.json`
  (79 ARM lines parsed).
- Byte-stability: `run_battery.py` untouched — 176 prior rows stable
  by construction; the bpy arm is a NEW sibling runner.
- Independence: scout's receipts (probe{1,2,3}.stdout) reproduced
  verbatim on the tracked fixture — the operator did not re-derive the
  lattice, the scout did; the operator's role was promotion+pinning.

## Measured headline

The claim half-confirmed/half-narrowed: the split is write-through vs
evaluation-gated (RNA itself carries an eval edge on derived props);
evaluated_depsgraph_get is itself the eval event (shared graph flushes
held handles); NO implicit drain (unlike Godot per-tick serve);
held-handle staleness unbounded (map_off-analogue).

## Per-axis verdicts

- coverage: improved — first non-Godot runtime; full pinned lattice.
- depth: improved — cross-runtime twin for the r76–r78 model;
  generalization boundary mapped (drain absent here).
- calibration: unchanged — additive sibling only.

**Verdict: provisional ADMIT.** Bounded: Blender 5.2.1 LTS
`blender -b -P`, this host. Post-landing verifier/critic pending
free-pool reset; falsifications land on this record if warranted.
