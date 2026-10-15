# r94 adjudication — cannon.js (PyBullet-style) physics lattice

**Verdict: ADMIT-with-findings** — committed `05e72ef`, 284 rows (231 ordinary + 53 negative), 19 new `r94_cannon_*` rows, vendored `cannon-es@0.20.0` + three.js pinned by seed digests.

## Dossier

| seat | verdict | commit |
|---|---|---|
| author | 284/284 fully green on final bytes; boundary corrections encoded | `05e72ef` |
| boundary (pre-landed) | internalStep impure; order-neutrality scoped; μ/v₀ grid; fixedStep wall-clock; GridBroadphase refused | `275bcae` |
| critic | PASS w/ F1 MEDIUM — 4 accumulator cells flip ~1% (16.67 ms wall-bail in cannon stepper) | `942f56e` |
| reviewer | ADMIT-recommend — 57/57 fresh exact; corroborated F1 (1/200) | this round |
| simplifier | PASS — SP1–SP4 net −22 proven byte-identical; nan-hash over-count | `52b2fbc` |
| verifier | VERIFIED — clean insert, 19/19 @load123, 114/114 rep-stable, F1 0/1160 | `ed8b659` |
| scribe | AUDIT PASSES — custody 456/456 + 2888/2888; v24↔v26 node byte-identical | `7cd5ec8` |

## Laws admitted

Determinism pins (`det`/`det2` bit-exact Float64 witnesses), varstep accumulator mechanics, wall-clock bail-out class, `internalStep` clock dependence, scoped add-order neutrality, friction/material grid, sync lattice, six negative controls (dt/gravity/early-steps/elapsed/wxyz/grid).

## Recorded-not-folded

- **F1 (critic MEDIUM, corroborated by reviewer):** `var_interp`/`var_sleep_phase`/`var_maxsub`/`mod_two_arg` flip ~1% under heavy contention — the 16.67 ms `performance.now()` substep bail in `cannon-es.js`. Joins the documented flake list (same class as navagent/map-publish); envelope-pining deferred — every flip fails loudly by construction.
- Simplifier SP1–SP4 (−22 net) + nan-hash recount queued for next fold.
- `package.json` conflict resolved in the critic's favour: load-bearing in the battery's own layout (removal → `o=4` warns → FAIL). Scribe/simplifier's counter-measurement used a different layout.
- Reviewer F1–F4 report-accuracy nits; `node=v24.21.0` is a host pin (v26 identical).

## Bounds

Godot 4.7.2 headless parent + node v24.21.0/v26.12.0 children, load 55–135. `var_bailout` `stepnumber=1` held 7/7 (measured wall-budget edge).
