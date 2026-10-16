# Adjudicator report — round 98 (GLTF/GLB runtime-import lattice)

DECISION: **ADMIT-with-findings** on `b6d60b1`. 9 rows (324->333), 137 cells / 137 children,
0 .godot minted. All five gates landed: verifier VERIFIED (22/22 checks, 137/137 x4 re-derived),
critic PASS (581 cells 0 diffs, 9/12 mutations), reviewer ADMIT-recommend (411/411 re-derivations),
simplifier PASS (-25 queued), scribe AUDIT PASSES (17/17 assets at pins).

Encodings that survived: cold-cache ResourceLoader dead-end, GLTFDocument err=0/7/43 taxonomy,
content-sniff both directions, unvalidated length/version, res:// blind-concat, 18-class
inventory, write_to_filesystem byte-equality, TRS fidelity, backend-inert OMI phys, rate
invariance.

Fold queue:
1. User-dir concurrency hazard (4-seat consensus: verifier/scribe/simplifier/reviewer):
   fixed APP="R98Scout" + arm-end cleanup -> concurrent parents delete each other's seeds
   (doc_abs/doc_user/ext_bin_abs false-FAIL, reproduced 5/6 controlled / 0/8 isolated).
   Fold: per-pid dir name + mask normalization back to UD/R98Scout.
2. Critic F1: content-sniff discriminator lives outside the tracked lattice — hash
   res://r98assets/* into a cell.
3. Scribe F1 (disclosure correction): xxd clobber DID reach the tracked seed for ~7 min
   (260B hexdump); landed bytes correct and 3-seat proven. Record stands.
4. Verifier F2: gd=0 enforced by pinned marker, not _cell_ok (fixture prints PASS on gd=1).
5. Simplifier SP1-6 (-25) + probe-copy dead locals — apply decision.
