# r19 final non-author Unity-style static verification — 2026-10-13

Fresh LEAF verification after provisional reviewer found duplicate-key and pre-document-garbage false accepts. Implementation read-only. **Qualified pass for the declared bounded local STATIC artifact**: corrected checker accepts authored source and rejects broken father, duplicate father, garbage prefix, child GameObject back-reference, and extra dangling child component. No Unity Editor import/runtime validation or general UnityYAML parser claim.

## Source, bytes, and citations

Read `.shokunin/game-dev-3d/LOG.md` r19 and `corpus/lessons/r19-unity-review.md`. Final checker `.shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py`: SHA-256 decad886f4018aba13588934058b3be91a1ad71c59839edcc25d92d13015270b (earlier first correction `add73ffa6091e3dd713e9d31389b26a149ac5a859ef51670d46c9b80e60154d7` still false-accepted an extra child component; provisional checker `7ff637017cf1cc76fdec7c58026dab84a703b8c719ae682ce12a7a2c58acf052`). The final source uses a PyYAML `SafeLoader` subclass rejecting duplicate mapping keys, rejects non-whitespace between exact preamble and first document, and requires exactly one shaped component entry per GameObject. It selects four exact tag/ID documents and checks selected fields/literals; it is not a full UnityYAML implementation.

`Hierarchy.unity`: 695 bytes, SHA-256 `0c088c2352d5808150feaae87213a63f1d0fc5820eff1237246107b1143635f7`; `Hierarchy.broken-reference.unity`: 695 bytes, SHA-256 `890f09293fe97f3bf78f2cee173567fb40d23e1e9be64614e1aee9e205c701a7`. Byte diff is **only** zero-index offsets 690–692: `101`→`999` in child `m_Father`; exact one-replacement equality verified. Source has `%YAML 1.1`, `%TAG !u! tag:unity3d.com,2011:`, `!u!1 &100`/`!u!4 &101` Parent3D and `!u!1 &200`/`!u!4 &201` Child3D documents, reciprocal object/Transform references and parent `m_Children` ID 201 to child `m_Father` ID 101. Parent local (10,0,0), child local (1,2,-3), identity rotations and unit scales give hand-derived world (11,2,-3), *not observed Unity execution*. Artifact README SHA-256 `c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660`.

Independently retrieved Unity 6.6 Manual [Format of text serialized files](https://docs.unity3d.com/Manual/FormatDescription.html), HTTP 200 SHA-256 `1f41a6492c3e256233f1b557597f01daa991a956af3235cb6805cdff91e3b4aa`, and [UnityYAML](https://docs.unity3d.com/Manual/UnityYAML.html), HTTP 200 SHA-256 `75588728d559efe0cc06b294f74b92136f185c732b8638a8aa5e0f7bc3d8b8d9`. The first illustrates document class/ID tags and object links; the second describes restricted/specialized serialization and warns against direct creation/edit. Documentation supports style, **not import compatibility**.

## Exact replay (repository root)

Checker invocation prefix: `uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py`. Each row invokes that exact prefix plus the shown arguments; exit codes are from the *final* checker hash above. Private copies live under `/tmp/game-dev-3d-r19-final-048yzsqh/` and do not alter tracked fixtures.

| Arguments | Exit | Output result / reason |
| --- | ---: | --- |
| *(none)* | 0 | `PASS local-static actual=accept expected=accept`; two GameObjects/Transforms, reciprocal fileIDs, static world=(11,2,-3) |
| `.shokunin/game-dev-3d/corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject` | 0 | `PASS local-static actual=reject expected=reject`; `child father reference broken: {'fileID': 999}` |
| `/tmp/game-dev-3d-r19-final-048yzsqh/duplicate-father.unity --expect-reject` | 0 | `PASS local-static actual=reject expected=reject`; `invalid document YAML: duplicate mapping key: m_Father` |
| `/tmp/game-dev-3d-r19-final-048yzsqh/leading-garbage.unity --expect-reject` | 0 | `PASS local-static actual=reject expected=reject`; `unexpected text before first document` |
| `/tmp/game-dev-3d-r19-final-048yzsqh/child-go.unity --expect-reject` | 0 | `PASS local-static actual=reject expected=reject`; `Transform GameObject back-references broken` |
| `/tmp/game-dev-3d-r19-final-048yzsqh/extra-child-component.unity --expect-reject` | 0 | `PASS local-static actual=reject expected=reject`; `unexpected GameObject component references` |

Private copies were independently generated from source using exactly one replacement/insertion each: duplicate-father inserts `m_Father: {fileID: 999}` immediately before original `m_Father: {fileID: 101}` in child Transform (721 bytes, SHA-256 `92bc1516b703185a156baa7281100b0de529ebad403ea9a9c6bc5987d46b5947`); leading-garbage inserts `THIS IS UNPARSED GARBAGE` immediately after `%TAG` before first header (720 bytes, SHA-256 `59666c26135af084812ef5f0f9a6e7cebe34aba52fa31980a7ba9e6a3a8c2ef8`); child-go changes child Transform `m_GameObject: {fileID: 200}` to `999` (695 bytes, SHA-256 `f88b4193b947545bf3e1cc24dd90c2b0f1eaab99b50dba93555575bdc9922464`); extra-child-component adds `- component: {fileID: 999}` after the existing child's valid component entry (SHA-256 `0ca209485a3db58b79eeab7898642553dcdb432ba8189a93878ac8ac8635ea8e`). On the *intermediate* checker hash `add73ffa...`, the latter `--expect-reject` exited **1**, `FAIL local-static actual=accept expected=reject`, because only `m_Component[0]` was checked. Retested all six rows against final hash; all now exit 0.

Regression commands on this working tree: `python .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` → exit 0, `totals: cases=25 pass=25 fail=0 ordinary=12 negative_controls=13 probes=0`, receipt `.shokunin/game-dev-3d/corpus/live/runs/20261013T052155276140Z/verdicts.json`; `node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs` → exit 0, `PASS three battery: 3/3, seeds_unchanged=true` (positive exit0, negative exit2, mutation exit1). No four opt-in Godot probes rerun. These regressions ran before the final checker-only edit; their case files were unchanged by the checker correction.

## Boundary and remaining unknowns

Provisional two false accepts and intermediate extra-component false accept were real and are preserved above, not treated as passing tests retroactively. The final static check validates **selected authored graph and literals**, not arbitrary scene files. Unchecked extra mapping fields or fileID-like references outside inspected fields may still be accepted; no general all-reference census, UnityYAML conformance, editor import, scene execution, serialization round trip, or rendering is established. A Unity importer may reject this self-authored minimal sample even though the local checker passes. On bounded source/controls and unchanged regressions, coverage improves only as local static Unity-style structure evidence; depth/calibration not shown to improve.

> **Digest correction (r106, 2026-10-18).** The sentences above are unchanged. `Hierarchy.unity` `0c088c23…`, `Hierarchy.broken-reference.unity` `890f0929…`, and final `verify_scene.py` `decad886f…` still match the tree. The artifact README hash `c4463ab5…` does not: it is the blob at `6b24261c` (1579 bytes). Live `corpus/artifacts/unity-r19/README.md` is 1513 bytes, `12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c`.
>
> ```
> $ sha256sum corpus/artifacts/unity-r19/README.md corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.unity corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity
> 12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c  corpus/artifacts/unity-r19/README.md
> decad886f4018aba13588934058b3be91a1ad71c59839edcc25d92d13015270b  corpus/artifacts/unity-r19/verify_scene.py
> 0c088c2352d5808150feaae87213a63f1d0fc5820eff1237246107b1143635f7  corpus/artifacts/unity-r19/Hierarchy.unity
> 890f09293fe97f3bf78f2cee173567fb40d23e1e9be64614e1aee9e205c701a7  corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity
> $ git show 6b24261c677e:corpus/artifacts/unity-r19/README.md | sha256sum
> c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660  -
> $ git show 6b24261c677e:corpus/artifacts/unity-r19/README.md | wc -c
> 1579
> $ wc -c corpus/artifacts/unity-r19/README.md
> 1513 corpus/artifacts/unity-r19/README.md
> ```

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T052155276140Z/verdicts.json`
