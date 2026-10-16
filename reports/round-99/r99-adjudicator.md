# Adjudicator report — round 99 (AnimationTree lattice)

DECISION: **ADMIT-with-findings** on `f1ff626`. 9 rows (333->342), 183 cells / 122 beq
across 3 backends, insertion-only (+29 lines). All five gates landed: verifier VERIFIED
(342/342 x2 re-derived on committed bytes), critic PASS (549 cell-instances re-derived,
0 diffs, 8/10 mutations, beq non-vacuous), reviewer ADMIT-recommend (342/342 x2, all 9
r99 rows PASS in 6 runs), simplifier PASS (SP1-4 parent folds -9 proven; SP-5 refuted —
frozen-probe line-coupling, 6 cells moved, drop), scribe AUDIT PASSES-WF.

Encodings that survived: animtree node-mode lattice, clsloop td-encoded heap abort class,
bep/beg/bec process-flag envelopes, PhysicsServer3D backend-shared ClassDB behavior.

Fold queue:
1. **Scribe F1 (material, undisclosed instability in a pinned cell + gate impact).**
   clsloop `ClassDB.instantiate` returns null under load — `made=360/beq=0` observed in
   the scribe census vs author-pinned values; 1281/1281 pins re-derive but the cell's
   instability was not disclosed by the author. Fold spec: tolerate made>=author floor
   or pin made/beq independently of load order.
2. **Simplifier SP1-4 (-9 proven)** — apply the parent-side dead-code folds
   (`_scan_lines` write-only `w` + `"m"`/`"w"` keys -2; leak-allowlist dead path -7).
   SP-5 refuted: frozen-probe rows are line-coupled to the probe source — record the
   coupling, never delete probe lines without re-deriving cells.
3. **Critic F2 (mutation coverage)** — 2/10 mutations escaped; extend mutation matrix
   before the next animtree-adjacent landing.

Adjudicated by the lane orchestrator (mahogany-kick) after all five r99 wave-B reports
landed. Author commit `f1ff626`; gate commits b3d366e (critic), 34d3e69 (simplifier),
dbb084f (scribe); reviewer/verifier reports land in this same integration commit.
