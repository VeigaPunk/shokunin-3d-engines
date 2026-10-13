# Round 41 independent ShapeCast3D sphere review

Reviewer: named LEAF non-author `game-dev-3d-r41-shapecast-review`. Base HEAD `703068933ddff24eb51e9cf8e1afff0c9a27099b`; host `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf under `--headless`. I edited no implementation, seed, runner, README or LOG, and did not push/merge. Only tracked reviewer write is this report; private copies and raw receipts are under ignored `corpus/live/runs/`.

## Reproduction and exact receipts

From repository root, executed both (exit 0):

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only shapecast3d_sphere,shapecast3d_sphere_offset
```

Full run: 59/59 cases PASS (28 ordinary, 31 negative), all four opt-ins PASS (tree timeout, crash exit, stream attribution, and the pre-existing body-contact failing mutation); seed digests unchanged. Full `corpus/live/runs/20261013T071906657777Z/verdicts.json` SHA-256 `98d2b72bbe5cc7b9c195ab7b962a47b346264162b564cfe3164aec5ddf3021cd`. Its four opt-in receipts: `tree-timeout-verdicts.json` `e7094abb152a727a2fd09a41e55ec512837670690df54ac98ac6f759e7c3f50e`, `crash-exit-verdicts.json` `1b9158ec13164e04bfec67935a79b7803fdc3e3cab1d19b047fdb8d8477cfc35`, `stream-attribution-verdicts.json` `c533039366a0e0fb049aff51f68abcc2528ed4355d75592ba41f017bb9647a0b`, and `mutation-verdicts.json` `4b094d68a23812973abf70bf6a86785fdae7ad265180011da0b70af4cd342735`. Complete per-case exact commands, flags, exits, stdout, stderr, error and rejection reasons are in `verdicts.json`; `battery-output.txt` accompanies it. Case timeout 20 seconds. The optional failing probe is **not** a ShapeCast3D mutation.

Pair: 2/2 PASS (one ordinary, one negative), seeds unchanged; `corpus/live/runs/20261013T071906657842Z/verdicts.json` SHA-256 `03ed103084e301d1f5825ae2f1893bef0b1bfb175795470545c114e7c91af38f`; same seed map as full. Center exits 0, stdout Godot banner followed by `PASS shapecast3d_sphere radius=0.500 contact_z=1.000 safe=0.414062 unsafe=0.417969 hits=1`; X4 offset exits 2, stdout Godot banner followed by `NEGATIVE REJECTED: shapecast3d_sphere lateral_miss x=4.000 hits=0 safe=1.000`. Both stderr lists and rejection reasons are empty. Full-run new records have the same case fields.

Prior complete 57-case raw `corpus/live/runs/20261013T071241922851Z/verdicts.json` SHA-256 `be60fcdd6c585f12c929d3624f47f0ee824a08ab2f89e1398e16ae1395ee91ba`: PASS 57/57. All 57 old records exactly equal new full records on `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`; only variable scratch command paths and elapsed durations excluded. Prior/new seed maps differ **only** `README.md` `20c2bed374f33dac74c396c8335e0b55a009a96e0046f63d96708cf103f90c78`→`7f8efe603e80c4f4626b258f85ff69a5e9b1c5711ebe71a7e3e4abb1ffba6f02`, `run_battery.py` `a0692cd2d4e3215f22b6033ecd60f604c83bf40e1aaa77fd379a6e7fb39de798`→`7a133b7f8c0ea9a318bf1490e38f63c19c602ee5f0867b0c8585abc4201d9456`, and added `shapecast3d_sphere.gd` SHA-256 `7a9f5f3efeb606501dbc228b43e76b65faa65ed97c0ba171886833c5e0de5ce9`.

## Source, adverse feasibility and bounded claim

The new fixture SHA-256 `7a9f5f3efeb606501dbc228b43e76b65faa65ed97c0ba171886833c5e0de5ce9` sets a static box size `(2,2,2)` centered on origin, a live sphere radius `0.5`, cast initial position `(0,0,4)` and target `(0,0,-6)` (lateral control starts `(4,0,4)` with same target). After four physics frames and `force_shapecast_update()`, setup checks tree presence, shape identity/radius/box size, target and matching mask/layer. Center checks one hit, identical wall object and instance ID, measured contact `(0,0,1)`, +Z normal, and closest safe/unsafe fractions within 0.002 of 0.4140625/0.41796875 before its fixed marker. Lateral arm checks no hit/count zero and safe approximately 1 before negative marker. LOG r41 explicitly records an adverse initial arrangement: center at z0 started inside box and missed, while offset at z4 swept into box and hit; both arms were corrected to initial z4 and the miss changed to lateral X4 before this run. Do not count the adverse trial as a passing admission.

These fractions are numerical swept-shape solver estimates, **not** analytically exact sphere/box contact distance. Observations establish one static-target finite-volume `ShapeCast3D` query versus an X4 miss in this host's headless physics space. They do not show moving-body gameplay, continuous collision guarantees or tunneling prevention, GPU output, rendered pixels or other engines/versions.

## Private two-stage causal control

Copied only fixture project files into `corpus/live/runs/r41-shapecast-review-private/{size-only,adjust-setup}/`; seeds untouched. Ran, separately per arm (both exit 1):

```sh
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r41-shapecast-review-private/size-only --script res://shapecast3d_sphere.gd
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r41-shapecast-review-private/adjust-setup --script res://shapecast3d_sphere.gd
```

`size-only` changed **only** `box_shape.size = Vector3(2, 2, 2)`→`box_shape.size = Vector3(2, 2, 4)`; copied source SHA-256 `80d0dbb11564fc1a07ee27ec00e68aafa6533716fcc7e3fd798b7cb71a2b0b1c`. It exits 1 at line 30's setup guard, stderr `ERROR: shapecast3d_sphere: live shape/target setup absent`. This alone is **not** evidence that measured contact catches displacement.

`adjust-setup` also changed **only** the setup readback expectation `box_shape.size != Vector3(2, 2, 2)`→`box_shape.size != Vector3(2, 2, 4)`; left contact/fraction literals and markers unchanged. Copied source SHA-256 `a1f3fd72def693dfaaa0491d726bea537615dab4d5fa6d474b8ad16dbf39ec82`. It exits 1 at line 44's measured hit assertion, stderr exact diagnostic `ERROR: shapecast3d_sphere: sphere cast hit mismatch point=(0.0, 0.0, 2.0) normal=(0.0, 0.0, 1.0) safe=0.244141 unsafe=0.250000`. This shows live box front contact shifted from z1 to z2, with fraction change from ~0.414062/~0.417969 to ~0.244141/~0.250000; the compound assertion does **not** independently isolate point from fraction predicates. Each stdout contains only the Godot banner and blank line; no PASS/negative marker. Neither stderr contains `SCRIPT ERROR:`, `Parse Error:`, or ObjectDB leak. Raw `mutation.stdout`/`mutation.stderr` are beside each copied script; hashes of stderr size-only `2568e595282e61659c93269e90f2fcce6a70faa78b193d681e6cce19626ced70`, adjusted `91702f1d691696ac593619de8b6c0404af6e4bf6b45cb2f5ab7f83ed6ca59fb8`. The changed setup expectation is required to pass the earlier guard; the second failure is the observed physics result, not setup or a parser/classifier leak.

Verdict for non-author replay: **coverage improved** by a bounded live `ShapeCast3D` finite-volume sweep beyond existing ray/CharacterBody cases; **depth unchanged**, **calibration unchanged**. No observed harm to prior case fields or seed hashes other than the planned three seed-file additions/updates.
