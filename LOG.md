# game-dev-3d LOG — append-only

Campaign: prymeagnt shokunin fleet. Lane: game-dev-3d (3D game production
verified by executable headless fixtures; engine-neutral: Godot, Unity,
Unreal, three.js, and discovered tooling; engine census in
corpus/knowledge/engines.md). Minted 2026-10-13 by operator directive.
Predecessor art: games-engine-mechanics r15 (corpus seed, provenance in
corpus/knowledge/seed.md).

## Round 1 — 2026-10-13 — depth + coverage + calibration (mint seed)

- Claim: a headless Godot 4.7.2 3D battery exists and discriminates causal
  positives from intended negatives across six mechanic classes:
  CharacterBody3D contact, Area3D signal chain, Camera3D projection,
  raycast hit/miss, Transform3D composition, synthetic-input movement.
- Evidence: 12 cases (6 ordinary exit-0 + 6 negative controls exit-2),
  battery exit 0, three determinism replays with one stdout-marker digest;
  receipts copied to corpus/lessons/r1/{clean-verdicts.json,
  adversarial-controls.json, mutation-verdicts.json}. Exit contract:
  intended negatives print `NEGATIVE REJECTED: <case> <reason>` on stdout,
  exit 2, silent stderr; any `ERROR:` line on either stream fails the
  case; crash and silent-run controls both reject with exit 1.
- Adversarial calibration: one authored constant mutated in scratch
  (`body3d_slide.gd` `BOX_SIZE` depth 4.0→6.0) rejected — exit 1, exact
  `ERROR:` diagnostic, seeds unchanged.
- Verdicts (author, mint round — non-author verification of r1 is a
  standing-loop backlog item): depth improved (six 3D mechanic classes
  with hand-derived anchors, discriminating negatives), coverage improved
  (12-case battery + inherited predecessor suite), calibration improved
  (exit-code/marker contract + one mutation-probe class). Limits: no
  non-author verifier yet; rendering/GPU, other engines, export, and the
  game-dev-2d fault-injection/stream-attribution/timeout probes unported.
- Identity: commits as `game-dev-3d-shokunin <game-dev-3d@shokunin.local>`.
