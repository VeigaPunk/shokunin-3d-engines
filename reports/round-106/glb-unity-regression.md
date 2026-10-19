# r106 SEAT-94 — GLB-UNITY-REGRESSION

Axes: coverage (README command paths still resolve from the repo root), depth (one live re-run per README, not a citation), calibration (exit codes and receipt fields match the README's stated contract).

- **Seat:** SEAT-94 GLB-UNITY-REGRESSION · round 106 · lane `game-dev-3d-shokunin`
- **Owned path written:** `reports/round-106/glb-unity-regression.md`, plus raw captures under `reports/round-106/glb-unity/`. No tracked file was edited. No protected path was written.
- **HEAD at run:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`git rev-parse HEAD`, 2026-10-18T21:20:24Z). Short: `0cc3f4162f8c`.
- **Closed:** 2026-10-18T21:20:53Z (`date -u`).
- **VERDICT: PASS.** Both chosen README commands exited 0. Judgment defects queued: none.

## Commands chosen

One runnable command from each README, piped from the worktree line (not retyped) and run from the repo root `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.

| README | line | exact text | why this one |
|---|---:|---|---|
| `corpus/artifacts/glb-r12/README.md` | 6 | `python3 corpus/artifacts/glb-r12/run_import.py` | The artifact's own contrast. Line 7 is the full battery (not this seat; r105 default-env was 337/350). Line 8 is the three.js fixture runner. |
| `corpus/artifacts/unity-r19/README.md` | 10 | `uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py` | Default accept path. Line 11 is the sibling `--expect-reject` case, not re-run. |

Host at run (read, not assumed): `godot --version` → `4.7.2.stable.arch_linux.ed1daf0bf`; `uv --version` → `uv 0.13.0 (x86_64-unknown-linux-gnu)`; `python3 --version` → `Python 3.14.7`; `node --version` → `v26.12.0` (default mise node; this seat did not switch to the pinned fnm v24.21.0). Neither command invokes Node.

## glb-r12 — exit 0

```
$ sed -n '6p' corpus/artifacts/glb-r12/README.md | bash
PASS Godot GLB import: valid/tolerated load, bad magic diagnosed and not loaded; receipt=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/r12-import-20261018T212038049374Z/verdicts.json
GLB_EXIT=0
```

Stderr capture is 0 bytes. Stdout sha256 `7160256bca2aa62588688458bec2b51a89b354d42a971327c62069731be14a84` (205 bytes). Capture: `reports/round-106/glb-unity/glb-r12-20261018T212038Z.stdout`.

Receipt `corpus/live/runs/r12-import-20261018T212038049374Z/verdicts.json` exists (12192 bytes) and is gitignored (`corpus/.gitignore:1:live/`). Parsed fields:

| case | editor exit | scene exit | imported `.scn` | source sha256 prefix |
|---|---:|---:|---|---|
| valid | 0 | 0 | true | `78f51afa040c1066` |
| tolerated_header | 0 | 0 | true | `dad26ba782d5977d` |
| bad_magic | 0 | 2 | false | `beef50211ceacdff` |

Top-level: `verdict=PASS`, `positive_and_tolerated_control_same_scene=true`, `bad_magic_rejected=true`, `source_digests_unchanged=true`. Valid and tolerated scene stdout ended in the three `IMPORT_*` lines the runner requires (root `triangle`, child `TriangleNode` MeshInstance3D at `(2.0, 0.0, -3.0)`, 1 surface / 3 vertices). Bad-magic scene stderr contained `IMPORT_REJECTED: no PackedScene` and scene exit was 2. That matches the README table (editor 0 / script 0 for the two loadable GLBs; editor 0 with import errors / script 2 and no PackedScene for the four-byte magic swap). This run does not prove rendered output, other-engine import, or a specific magic-header branch.

## unity-r19 — exit 0

```
$ sed -n '10p' corpus/artifacts/unity-r19/README.md | bash
PASS local-static actual=accept expected=accept path=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/artifacts/unity-r19/Hierarchy.unity reason=two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)
UNITY_EXIT=0
```

Stderr capture is 0 bytes. Stdout sha256 `0857378a497210a4b59b6306ab97d6680871bfffaf1856dd1d007ece392bf283` (265 bytes). Capture: `reports/round-106/glb-unity/unity-r19-20261018T212038Z.stdout`.

The checker accepted `Hierarchy.unity` under the local static derivation the README states (parent local `(10,0,0)` + child local `(1,2,-3)` → `(11,2,-3)` assuming identity rotation and unit scale). This is not a Unity Editor import. Unity Editor is not installed; no Unreal or Unity runtime claim is made.

## Path resolution (post-sweep)

Both command paths resolve as files from the repo root: `corpus/artifacts/glb-r12/run_import.py`, `corpus/artifacts/unity-r19/verify_scene.py`, `corpus/artifacts/unity-r19/Hierarchy.unity`. Neither README line still contains the dead `.shokunin/game-dev-3d/` root that round 103 repaired. Worktree README sha256 matches the round-103 post-repair digests (`d87774dc…` glb, `12c4abd1…` unity). Git blob ids: `d70045de8b47f7bb5aff82c5dcba8ea47f6a38c3` (glb README), `aa36350a7c9b095a2987ca23ff5b0752d62e8318` (unity README). Runner blobs: `run_import.py` sha256 `4b891657b2013585a31efa8f7f65850072d9a140d367bca31a3a811aa3ee9f85`; `verify_scene.py` sha256 `decad886f4018aba13588934058b3be91a1ad71c59839edcc25d92d13015270b`.

No citation in either README failed to resolve under this seat's re-run, so no dated correction note was required and no README byte was rewritten.

## Writes

- `reports/round-106/glb-unity-regression.md` (this file)
- `reports/round-106/glb-unity/glb-r12-20261018T212038Z.{stdout,stderr,exit}`
- `reports/round-106/glb-unity/unity-r19-20261018T212038Z.{stdout,stderr,exit}`
- `reports/round-106/glb-unity/.stamp`
- ignored side effect of the glb command itself: `corpus/live/runs/r12-import-20261018T212038049374Z/` (gitignored; not a seat edit)

`git status --short -- reports/round-106/glb-unity corpus/artifacts/glb-r12 corpus/artifacts/unity-r19` showed only `?? reports/round-106/glb-unity/`. Artifact trees were not modified.
