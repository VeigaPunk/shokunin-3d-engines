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

## Round 2 — declared before dispatch — calibration: independent r1 replay

- Before-state: r1 report and LOG explicitly say every battery receipt is author-run; zero named non-author verifier has reproduced either the 12-case battery or the scratch mutation. This is an evidence-authorship gap, not an extra 3D mechanic.
- Falsifiable move: a named reviewer who did not author r1 independently runs `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` and `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-failing`, checks full `verdicts.json` and `mutation-verdicts.json`, verifies 6 ordinary + 6 intended negatives, exact stdout markers, distinct stderr, seed digests, and checks at least one r1 claim against source. Calibration improves only if the reviewer independently records reproducible receipts and finds no unsupported claim; coverage and depth are expected unchanged. A failed replay or contradicted r1 claim falsifies this move and stops admission.
- Pre-dispatch wave: one necessary **non-author verifier**, `game-dev-3d-r2-verifier`, economy `openai-codex/gpt-5.1-codex-mini`, `thinking=low`; read-only inspection of r1 and fixture seeds, executable replay permitted under ignored `corpus/live/runs/`, one write target `.shokunin/game-dev-3d/corpus/lessons/r2-independent-review.md`. No implementation sub-lanes are warranted for an independent replay; do not treat this reviewer as the author or create eight redundant reviews. Reviewer must send explicit result to parent.

- Dispatch correction (before evidence): `game-dev-3d-r2-verifier` on `openai-codex/gpt-5.1-codex-mini` exited without reply or file: provider said “The 'gpt-5.1-codex-mini' model is not supported when using Codex with a ChatGPT account.” This dispatch proves nothing. Replacement wave is one non-author verifier `game-dev-3d-r2-review-retry` with inherited supported parent model, same read-only fixture/replay scope and same review path. No r1 check is claimed from failed dispatch.

- Reviewer result: `game-dev-3d-r2-review-retry` (not r1 author) independently ran both r1 commands on Godot 4.7.2, inspected full per-case streams and seed digests, and independently derived `body3d_slide.gd` contact plane/tick; reproducible receipts and limits are in `corpus/lessons/r2-independent-review.md`. Local cross-check at closure: both `verdicts.json` show PASS, `cases=12 pass=12 fail=0 ordinary=6 negative_controls=6`, `seeds_unchanged=true`; scratch mutant `detected=true`, actual exit 1, intended diagnostic on stderr. Ignored `live/runs/` directories are not durable evidence; committed review and reproduction commands are the pointer.
- Per-axis verdicts: **calibration improved** (r1 moves from author-only evidence to named independent replay with checked source and explicit limits); **depth unchanged** (no new mechanics/assertions); **coverage unchanged** (same 12 cases on the same host and engine). Admission: one improved and none harmed. SHONEN end-to-end task box can be checked with the named reviewer and committed review pointer; other boxes remain unverified, not self-attested.
- Next move: port crash-exit classification with an independently checked fault injection; keep process-tree timeout and stream-attribution as separate axis moves rather than bundling them.
