# SEAT-13 — sweep chunk `corpus/artifacts/**`

**Date:** 2026-10-18. **HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`).
**Contract:** SEAT-01 — extract every path/command citation; test each (exists from repo root / command rc); fix mechanical path-root defects in this chunk only, with before→after evidence; queue judgment defects. Dated notes for historical facts; no silent rewrites.
**Axes:** coverage = citation resolution in this chunk. Depth (engine census) is not this seat. Calibration = do not rewrite a historical receipt, and do not print a battery total this seat did not run.
**Writes:** this file only, plus scratch under `reports/round-106/scratch/seat13/` (host `/tmp` quota note). No chunk file edited. No git commit/push/checkout/reset.

No Unreal runtime claim. `which UnrealEditor UnrealEditor-Cmd` → both absent (rc 2). `which UnrealBuildTool` → absent (rc 1). The unreal-r22 commands below are the lane's local JSON checker.

## Counts

| item | n |
|---|---:|
| files in `corpus/artifacts/**` | 22 |
| README citation rows tested (C1–C12) | 12 |
| of which runnable commands | 7 |
| runnable commands with observed rc 0 | 6 |
| runnable commands whose verbatim form was not run | 1 (C2 full battery) |
| unique historical absolute paths in REA JSON | 3 (5 string hits) |
| mechanical path-root defects fixed | 0 |
| chunk files edited | 0 |

`find corpus/artifacts -type f | wc -l` → `22`.
`git status --porcelain -- corpus/artifacts` → empty.
`git show HEAD:<readme> | sha256sum` equals the worktree for all three READMEs (below). Dead-root scan of the three READMEs: `grep -n "shokunin/game-dev-3d" corpus/artifacts/{glb-r12,unity-r19,unreal-r22}/README.md` → no hits, shell printed `README dead-root hits=0`.

## README identity (unchanged vs HEAD)

```
$ sha256sum corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md corpus/artifacts/unreal-r22/README.md
d87774dcfc3c6265957e2850b4fc2f29a72eabef9697424009d6355d05b8582b  corpus/artifacts/glb-r12/README.md
12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c  corpus/artifacts/unity-r19/README.md
1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b  corpus/artifacts/unreal-r22/README.md

$ git show HEAD:corpus/artifacts/glb-r12/README.md | sha256sum
d87774dcfc3c6265957e2850b4fc2f29a72eabef9697424009d6355d05b8582b  -
$ git show HEAD:corpus/artifacts/unity-r19/README.md | sha256sum
12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c  -
$ git show HEAD:corpus/artifacts/unreal-r22/README.md | sha256sum
1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b  -
```

Those three digests are the r103/r102 after-repair blobs already recorded in `reports/round-103/b2/repair-glb.md`, `reports/round-103/b2/repair-unity.md`, and `corpus/lessons/r22-unreal-review.md` (correction note). Left untouched: another edit would move a digest the r19 lessons still quote as `c4463ab5…` (pre-r103) without fixing a broken path.

`wc -c -l`: glb-r12 README 19 lines / 1627 bytes; unity-r19 20 / 1513; unreal-r22 12 / 1394.

## Citation ledger

Placeholders `<scratch>` and `<timestamp>` are templates, not literal paths. Basename mentions (`project.godot`, `inspect_import.gd`, `triangle.glb`, `Hierarchy.unity`) are not repo-root paths; the commands that copy or open them exited 0.

| id | cite | test | result |
|---|---|---|---|
| C1 | `corpus/artifacts/glb-r12/README.md:6` `python3 corpus/artifacts/glb-r12/run_import.py` | exists + rc | EXISTS; rc 0 |
| C2 | `:7` `python3 corpus/fixtures/run_battery.py` | exists; verbatim rc **unrun** | EXISTS; `--help` rc 0; `--only floor3d_ground` rc 0. Full battery not run |
| C3 | `:8` `node corpus/fixtures/three/run_cases.mjs` | exists + rc | EXISTS; rc 0 (node v26.12.0, 3/3) |
| C4 | `:11` `corpus/live/runs/r12-import-<timestamp>/verdicts.json` | prefix exists | `corpus/live/runs` EXISTS; this seat wrote one instance (gitignored) |
| C5 | `:19` `corpus/lessons/r12-import-review.md` | exists | EXISTS (29 lines) |
| C6 | `unity-r19/README.md:4` FormatDescription.html | HTTP | 200, no redirect |
| C7 | `:5` UnityYAML.html | HTTP | 200, no redirect |
| C8 | `:10` `uv run … verify_scene.py` | exists + rc | EXISTS; rc 0 PASS accept |
| C9 | `:11` same + broken scene `--expect-reject` | exists + rc | both paths EXIST; rc 0 PASS reject |
| C10 | `unreal-r22/README.md:3` Epic plugins URL | HTTP | 200, no redirect |
| C11 | `:8` `python3 …/verify_descriptor.py` | exists + rc | EXISTS; rc 0 PASS accept |
| C12 | `:9` bad-type `--expect-reject` | exists + rc | both paths EXIST; rc 0 PASS reject |
| J-REA | 3 unique absolute paths in REA JSON (5 hits) | `test -e` | EXISTS on this host; not rewritten |

### C1 — import runner

```
$ godot --version
4.7.2.stable.arch_linux.ed1daf0bf
$ python3 corpus/artifacts/glb-r12/run_import.py
PASS Godot GLB import: valid/tolerated load, bad magic diagnosed and not loaded; receipt=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/r12-import-20261018T212310413727Z/verdicts.json
exit=0
```

Receipt copy (live path is gitignored — `corpus/.gitignore:1` is `live/`; `git check-ignore -v` named that line): `reports/round-106/scratch/seat13/r12-import-verdicts.json` sha256 `32b5c2a01132680d3241c608efcc94d0a5579050f6e2155683599c989daa183a`. Parsed verdict `PASS`, `positive_and_tolerated_control_same_scene=True`, `bad_magic_rejected=True`, `source_digests_unchanged=True`. valid/tolerated_header: editor exit 0, empty stderr, script exit 0, `.scn` present. bad_magic: editor exit 0, stderr contains `Error importing 'res://triangle.glb'` and `glTF: Error parsing`, script exit 2, `.scn` absent.

Table claims re-measured, not assumed:

```
valid     physical=532 magic=b'glTF' declared=532 sha256=78f51afa040c1066f10c47f22bd4ea9c812005351493acda3f62cae9eec65fbc
invalid   physical=532 magic=b'glTF' declared=531 sha256=dad26ba782d5977d8179edfa8bd78904ced9c71342f8b67205cd8cc89e7c144b
badmagic  physical=532 magic=b'BAD!' declared=532 sha256=beef50211ceacdff74e1dd20f6191e2ddf1ae217b5f7e5c995559c366a36a517
diff offsets bad vs valid: [0, 1, 2, 3]
diff offsets invalid vs valid: [8]  (byte 20 → 19)
```

`truth.json` sha256 equals `triangle.glb`. Matches the README table (532 B; header length 531; offsets 0–3 only on the bad-magic file).

Runner parent walk is not a prose citation, but it was checked because a wrong `parents[n]` would make C1 a false green: `HERE.parents[1]` is `corpus/`, and `corpus/artifacts/glb-r9` and `corpus/fixtures` both exist. C1's rc 0 is the behavioral check.

### C2 — battery command (path resolves; verbatim rc unrun)

```
$ python3 corpus/fixtures/run_battery.py --help
usage: run_battery.py [-h] [--godot GODOT] [--runs RUNS] [--only ONLY] ...
help_exit=0

$ python3 corpus/fixtures/run_battery.py --only floor3d_ground
PASS floor3d_ground: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: .../corpus/live/runs/20261018T213019580231Z/verdicts.json
exit=0
```

Receipt copy: `reports/round-106/scratch/seat13/floor3d-verdicts.json` sha256 `00d239f8701049a067fd0ca490896230081d2af472c883d80e75f3770d9d6ca8`.

The verbatim command `python3 corpus/fixtures/run_battery.py` (no `--only`) was **not run**. Unrun check = not passed for that rc. Not a path-root defect: the script exists and a one-row invocation exits 0. The README does not claim a battery total or an exit code. Env pairing of 337/350 vs 350/350 is not measured here and is not written as a fact. Queued as J-BATTERY.

### C3 — three.js runner (default node)

```
$ node --version
v26.12.0
$ node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0
```

`node` resolved to `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node` (default env, not the fnm v24 pin). This 3-case runner is not the r94 cannon marker set.

### C5 — lesson pointer

`corpus/lessons/r12-import-review.md` exists (`wc -l` → 29). It still names the r12 runner and the 532-byte controls. Its own command line still contains `.shokunin/game-dev-3d/` (lesson line 11). That file is not this chunk. Queued as J-LESSON-CROSS for the lesson seats. Not edited.

### C8–C9 — unity checker

```
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
PASS local-static actual=accept expected=accept path=.../Hierarchy.unity reason=two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)
exit=0

$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
PASS local-static actual=reject expected=reject path=corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity reason=child father reference broken: {'fileID': 999}
exit=0
```

`uv` 0.13.0. README prose (IDs 100/200, 101/201, world (11,2,-3), dangling 999) matches the checker's PASS lines. Unity Editor was not invoked; the README already says the sample was not imported by Unity.

### C6–C7 — Unity URLs

```
$ curl -sI -o /dev/null -w "%{http_code} %{url_effective}\n" -L --max-time 25 https://docs.unity3d.com/Manual/FormatDescription.html
200 https://docs.unity3d.com/Manual/FormatDescription.html
$ curl -sI -o /dev/null -w "%{http_code} %{url_effective}\n" -L --max-time 25 https://docs.unity3d.com/Manual/UnityYAML.html
200 https://docs.unity3d.com/Manual/UnityYAML.html
```

FetchURL main-text extract, 2026-10-18 (not a byte-faithful page dump): FormatDescription.html extract contains `!u!1`, `!u!4`, `m_GameObject`, `m_Children`, `m_Father`, `m_LocalPosition`, and `{fileID: …}`. UnityYAML.html extract contains `Avoid generating or editing Unity YAML files directly.` Both match the claims the README attributes to those URLs. No path defect.

### C11–C12 — unreal descriptor checker

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py
PASS local-static actual=accept expected=accept path=.../Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
exit=0

$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
PASS local-static actual=reject expected=reject path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'
exit=0
```

C10 FetchURL extract of the Epic page (HTTP 200) still has the headings the README names (*Plugin Descriptor Files*, *Descriptor File Format*, *Module Descriptors*), states FileVersion is the only required field and the current documented value is 3, and lists module types Runtime, RuntimeNoCommandlet, Developer, Editor, EditorNoCommandlet, Program. The example shows `LoadingPhase` `Default`. That is a doc-text extract, not an Unreal Editor load.

## Extra chunk scripts (no README citation; run so a hidden path break would show)

```
$ python3 corpus/artifacts/zip-r10/verify_carrier.py
{"verdict": "PASS", ... "positive_member_sha256": "78f51afa…eec65fbc", "negative_member_sha256": "dad26ba7…7c144b", "rea_does_not_parse_glb": true}
exit=0

$ python3 corpus/artifacts/glb-r9/validate_glb.py
PASS local GLB static: positive truth matches; length-control rejected=True
exit=0
```

ZIP root digests in the REA JSON match the files: positive `6fdb94824b19113213504d8bfff78812ccc95622c6df995bb34dedae937cff10`, negative `5fd00882486089d13e1c2a361b2207e73a02bfff932b91a8d851b5f172108e43`.

## Fixes landed

None. No before→after diff. `git status --porcelain -- corpus/artifacts` was empty after the sweep. Runnable repo-relative paths in the three READMEs already resolve (r103 re-root). Editing a README to add a note would move `d87774dc…` / `12c4abd1…` / `1c0d3035…` without repairing a failing path, and would add a second digest drift on top of the r19 lessons' still-quoted `c4463ab5…`. That harms calibration and improves no failing citation. Not done.

## Judgment queue (unfixed; not path-root)

**J-BATTERY.** `corpus/artifacts/glb-r12/README.md:7` cites `python3 corpus/fixtures/run_battery.py` with no environment pairing. Path resolves. Verbatim full-battery rc is **unrun** this seat (contended host, minutes, not required to prove the path). Do not treat this report as a 337/350 or 350/350 measurement. Suggested owner: whoever pairs battery commands with the r105 two-state model. Not a mechanical prefix fix.

**J-REA-ABS.** Frozen receipts embed absolute predecessor paths. Hits: `rea-positive.json` 2, `rea-negative.json` 2, `glb-r9/rea-inspect-error.json` 1. Unique paths:

- `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/artifacts/glb-r9/triangle.glb`
- `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/artifacts/zip-r10/triangle-carrier.zip`
- `/home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/corpus/artifacts/zip-r10/triangle-invalid-carrier.zip`

`test -e` → EXISTS on this host. `sha256sum` of the predecessor `triangle.glb` equals the lane copy (`78f51afa…`). These are historical `local_path` / `details.path` fields inside evidence blobs, not commands the READMEs tell a reader to run. Rewriting them would falsify the inspected-path record. `verify_carrier.py` keys off member digests, not these paths, and already exits 0. A clone without the predecessor tree would see them missing. No README exists in `zip-r10/` or `glb-r9/` to hang a dated note on, and this seat's declared new path is this report. Left byte-identical.

**J-LIVE-PATTERN.** C4's receipt class is gitignored (`corpus/.gitignore:1`). The README already says the scratch is ignored. This seat's instance exists and is copied under `reports/round-106/scratch/seat13/r12-import-verdicts.json`. Not a broken citation. Not rewritten into the README (a timestamp baked into prose would rot).

**J-LESSON-CROSS.** C5 resolves, but `corpus/lessons/r12-import-review.md:11` still quotes `python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py` and an absolute predecessor receipt path. Out of chunk. Lesson seats own that file. Not edited here.

**J-UNITY-MULTIDOC.** UnityYAML.html extract (2026-10-18) still has the cited "avoid generating or editing" sentence, and also says the reader does not handle YAML input that consists of multiple documents. The README's 2026-10-13 note does not claim UnityYAML accepts multi-document input, and it already says Unity Editor did not validate the sample. Not a contradiction of a quoted sentence. Not edited (would move `12c4abd1…` for no path fix).

## Scratch

`reports/round-106/scratch/seat13/inventory.txt`, `commands-static.txt`, `commands-node.txt`, `commands-import.txt`, `bytes-and-receipt.txt`, `probes2.txt`, `identity.txt`, `r12-import-verdicts.json`, `floor3d-verdicts.json`.
