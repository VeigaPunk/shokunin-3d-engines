# Round 40 independent BoneAttachment3D follower review

Reviewer: named non-author `game-dev-3d-r40-attachment-review`; no seed, implementation, runner, README, LOG, push, or merge edits. Host Godot `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf, headless. Only tracked reviewer write is this report; private mutants and raw receipts live in ignored `corpus/live/runs/`.

## Reproduction and complete raw receipts

From repository root:

```sh
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only skeleton3d_attachment,skeleton3d_attachment_unrotated
```

Full command exit 0, 57/57 seeded cases (27 ordinary, 30 negative controls), four uncounted opt-ins PASS; seed map unchanged. Complete raw `corpus/live/runs/20261013T071241922851Z/verdicts.json` SHA-256 `be60fcdd6c585f12c929d3624f47f0ee824a08ab2f89e1398e16ae1395ee91ba`. Four probes `tree-timeout-verdicts.json` SHA `bb59207e7b8ee7372653d67ca7768113746d69741b2719f2bb1e893dca1993d0`, `crash-exit-verdicts.json` SHA `0a3b459c42830d99f3f6facff446f7c565595d0b7ce547e60c44b6047988df94`, `stream-attribution-verdicts.json` SHA `cdcd67060105ddded5c9577cbde87441391fc005f30bdd7ca0596d4fd6fb06de`, `mutation-verdicts.json` SHA `a17f03bd1efa39f9a83461f2c815e625b30c8afbe954fdad5a952ae2a2701bd9`. Full `battery-output.txt` and per-case exact command/exit/stdout/stderr/reasons are beside the JSON. Optional `--probe-failing` remains the existing body-contact geometry mutant, not an attachment mutant.

Pair command exit 0, 2/2 (one ordinary/one negative), seed unchanged; raw `corpus/live/runs/20261013T071241923315Z/verdicts.json` SHA `efd0efa4b68f3a080b4ffc8ad20b9e91678aab79956d85338d58b4708d23d973`. Ordinary exit 0, stdout Godot banner then exact `PASS skeleton3d_attachment parent_z=90 attached_marker=-3.000,1.000,0.000`; negative exit 2, stdout Godot banner then exact `NEGATIVE REJECTED: skeleton3d_attachment unrotated attached_marker=1.000,3.000,0.000`. Both have empty stderr and empty rejection reasons. Full run's two new records match those fields.

Previous complete 55-case raw `corpus/live/runs/20261013T070607019182Z/verdicts.json` SHA `03a4733dfdcc888c80eb668b8d517645f00ee92df3e34de2f392dd5be54dc84a`: PASS 55/55, seed unchanged. All 55 old case records in the new full run exactly match old `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr`; variable scratch command path and elapsed time were excluded. Prior/new seed maps differ **only** `README.md` SHA `cb0144332a01a7caaffc3c70be8724d6c10ed8b4936d939da04a027d0725517c`→`20c2bed374f33dac74c396c8335e0b55a009a96e0046f63d96708cf103f90c78`, `run_battery.py` `52c66f9c51552efd2be10ec9546ab23955293b8c7de6cdd04a2ce4396212e84c`→`a0692cd2d4e3215f22b6033ecd60f604c83bf40e1aaa77fd379a6e7fb39de798`, and new `skeleton3d_attachment.gd` SHA `25851f8ccd4711c0e5be848716211c7c52ed19f0d00ba888ef5d96fcc5125cb5`. Full and pair seed maps match exactly.

## Source and measured behavior

`Skeleton3D` Root/Tip parent 0, local rests `(1,0,0)` and `(0,2,0)`, Tip global **rest** `(1,2,0)`. `BoneAttachment3D.bone_name="Tip"`, `get_bone_idx()==1`, direct skeleton child; `Node3D` marker is its child with fixed attachment-local `(1,0,0)`. Following one initial and four post-setter process frames, Root pose Z +90°, Tip pose `(0,3,0)` yield measured Tip global **pose** and attachment local origin `(-3,0,0)`, attachment basis X `(0,1,0)`, marker global position `(-3,1,0)` and global basis X `(0,1,0)`. The unchanged-rest unrotated Root control yields attachment `(0,3,0)` with X `(1,0,0)` and marker global `(1,3,0)` with X `(1,0,0)`. The fixture checks setup/rest/binding before node transforms. Its marker is a live node position in skeleton scene-tree coordinates, **not** a skinned mesh vertex or rest-combined vertex coordinate. The markers are fixed strings printed only after assertions, not dynamic transform logs; mutation stderr supplies sampled adverse values.

## Private copied causal controls

Exact copied files are `corpus/live/runs/r40-attachment-review-private/{angle-only,adjust-attachment}/skeleton3d_attachment.gd`; only copied seed files changed. Execute either with `godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r40-attachment-review-private/<name> --script res://skeleton3d_attachment.gd` (no `--unrotated`). Stdout/stderr separately captured there as `mutation.stdout` and `mutation.stderr`.

1. `angle-only`: replace **only** setter `0 if unrotated else PI / 2`→`0 if unrotated else PI / 3`, source SHA `97187c535d754ee83a8ca3572c2ed839bef3e6c1fa926e45212743c3f59891e8`. Exit 1; stdout contains only Godot banner (no PASS/negative marker), stderr first diagnostic `ERROR: skeleton3d_attachment: attachment follow mismatch pose=(-2.598076, 1.5, 0.0) attachment=(-2.598076, 1.5, 0.0) basis_x=(0.5, 0.866025, 0.0)` at `_run` line 34. Setup/rest/binding check passed before failure; this is measured attachment position/basis, not an angle-constant echo.
2. `adjust-attachment`: same setter edit, change **only** rotated `expected_attachment` `Vector3(-3, 0, 0)`→`Vector3(-2.598076, 1.5, 0)` and rotated `expected_x` `Vector3(0, 1, 0)`→`Vector3(0.5, 0.866025, 0)`; `expected_marker=Vector3(-3,1,0)` remains untouched. SHA `5307e0e52d2126865b0e5708a332f042a87ea003046df850bf01e5a5bcab6462`. Exit 1 after attachment assertion, stderr first diagnostic `ERROR: skeleton3d_attachment: attached marker mismatch global=(-2.098076, 2.366025, 0.0) basis_x=(0.5, 0.866025, 0.0)` at `_run` line 36. This samples actual marker global transform rather than merely the skeleton pose; marker-position and basis subpredicates share a compound check, though the adjusted basis X agrees with observed X while unchanged marker position differs.

Both private executions: stdout SHA `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`; stderr SHA respectively `546105055083d6b8a6c80e7446fc868d9e6bec1bc088ff8ee47bab0e79db0bb2` and `1bed8f519bc05c6a10a46ae6ecfb87642b49b1a54de10c8acef57b460e96c093`. No `Parse Error:`, `SCRIPT ERROR:`, ObjectDB leak warning or success marker in either. The intended `ERROR:` is the measured rejection, not a normal-case PASS.

## Independent verdict and limits

**Depth improved**: an attached live Node3D and offset marker follow the bone pose under root rotation, beyond r39's skeletal pose-only readback. **Coverage unchanged** (same skeletal family); **calibration unchanged** (existing battery classification and four probes). Evidence is bounded to one two-bone headless Godot setup and sampled frames; no mesh deformation, skinned vertex, GPU rendering/pixels, arbitrary animation, other driver or other-engine generalization. The negative arm is the fixture's intact unrotated control (exit 2); private angle changes deliberately reject (exit 1), never count as passing cases.
