# r102 SEAT-03 BEFORE — F3 `run_battery.py` seed-SHA drift

Scope: capture evidence only. **No edits to any cited file** (`corpus/lessons/r22-unreal-review.md`,
`reports/round-101/r101-critic-c3.md`) — both are read-only to this seat. HEAD at capture: `2c99b7b`.

## 1. Every stale-digest citation in the tree

```
$ grep -rn 'a065a56d' corpus/ reports/ --include='*.md' | head -20
corpus/lessons/r22-unreal-review.md:48:Godot receipt `corpus/live/runs/20261013T053632289732Z/verdicts.json`, SHA-256 `a806b9e4d2928ac2c01ba463804ad55f7e14086b72d7846a458f91e271e3d8fc`; fixture `run_battery.py` seed SHA `a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570`. Three.js runner SHA `f9f40d4763748223a40e761c09c01e4762f21218744f09aeefe74f069a547d7f`, scene source SHA `e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af`, pinned package lock SHA `1a8e6ee2341eb4e3bcf764ad0c14973c89afee0a613bb14d41ea2fa5851c19b8`. A separate direct `node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs` exited 0 and printed its positive case only; the three-case runner above is the actual 3/3 evidence.
reports/round-101/r101-critic-c3.md:201:`a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570`. The current file is
exit=0
```

```
$ grep -rn 'a065a56d' . --exclude-dir=.git | wc -l
2
$ grep -rln 'a065a56d' . --exclude-dir=.git
./corpus/lessons/r22-unreal-review.md
./reports/round-101/r101-critic-c3.md
```

Exactly **two** hits repo-wide, one occurrence each (`grep -c` = 1 in both files):

| # | Path:line | Class | Role |
|---|---|---|---|
| 1 | `corpus/lessons/r22-unreal-review.md:48` | lesson, live-sounding | **the defect** — cited as a current seed digest in a block that also cites a live run command |
| 2 | `reports/round-101/r101-critic-c3.md:201` | historical r101 report | already *discusses* the digest as superseded; quoted prose, not a fresh claim |

`reports/round-101/**` is owned by another seat and is frozen; it is listed for completeness only.

## 2. Current digest of the file in the tree

```
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
exit=0
$ wc -c corpus/fixtures/run_battery.py
346248 corpus/fixtures/run_battery.py
```

Current: `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, 346248 bytes.

## 3. The cited digest is real, but only in history

```
$ git cat-file blob 490e710d:corpus/fixtures/run_battery.py | sha256sum
a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570  -
exit=0
$ git cat-file -s 490e710d:corpus/fixtures/run_battery.py
34239
exit=0
```

Cited: `a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570`, 34239 bytes.

Resolution of the r22-era citation:

```
$ for c in 490e710d 8b21cae 7804a69; do printf '%s -> ' "$c"; git show "$c:corpus/fixtures/run_battery.py" | sha256sum; done
490e710d -> a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570  -
8b21cae -> a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570  -
7804a69 -> a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570  -
$ git log --format='%h %ad %s' --date=iso -1 490e710d
490e710 2026-10-13 02:34:06 -0300 game-dev-3d r21: verify saved-scene BoxMesh locality
$ git log --format='%h %ad %s' --date=iso -1 8b21cae
8b21cae 2026-10-13 02:38:13 -0300 game-dev-3d r22: verify Unreal-style static descriptor
```

So the r22 lesson's number is **historically accurate for the moment of writing**: the blob at r22
(`8b21cae`, and the r22 record commit `7804a69` 27s later) hashes to `a065a56d…` exactly. The r21
commit `490e710d` carries the identical blob, so the digest was unchanged r21→r22.

The first rewrite after the r22 window:

```
$ git log --format='%h %ad %s' --date=iso -1 d5feae8
d5feae8 2026-10-13 02:42:16 -0300 game-dev-3d r23: verify orthographic Camera3D projection
$ git cat-file blob d5feae8:corpus/fixtures/run_battery.py | sha256sum
52e7aedea1aaf4bbcf834a5552ab3b0b455dc49ece342e57f46fd78c27fd7434  -
$ git cat-file -s d5feae8:corpus/fixtures/run_battery.py
34609
```

Drift volume since:

```
$ git log --oneline 490e710d..HEAD -- corpus/fixtures/run_battery.py | wc -l
64
$ git log --oneline -- corpus/fixtures/run_battery.py | wc -l
78
$ while read c; do git cat-file blob "$c:corpus/fixtures/run_battery.py" | sha256sum; done < <(git log --format='%H' -- corpus/fixtures/run_battery.py) | cut -d' ' -f1 | sort -u | wc -l
78
```

78 commits touch the file; 64 of them landed after the r22 window; the blob was rewritten every
time (78 commits → 78 distinct digests). Only **one** commit in history (`490e710d`) still carries
the cited `a065a56d…` blob, and it is an ancestor of HEAD, not any tree path.

## 4. Failure mode, stated precisely

- **Not a fabrication.** The digest is exact for the r22-era blob; the r22 lesson was not wrong when written.
- **Not reproducible from the tree.** No tracked path currently hashes to `a065a56d…`; a fresh
  clone cannot verify it. The lesson presents it in the same breath as a live command
  (`python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py`, line 42) with no "as of r22"
  qualifier, so a reader cannot tell the claim is historical.
- **Also present in that line:** the `.shokunin/game-dev-3d/` path prefix (defect F1) and the
  `corpus/live/runs/…/verdicts.json` receipt (defect F2). This seat's before-artifact covers F3
  only; the other two are other seats' / other checks' before-state.
- The r22 lesson is the only *lesson* carrying this digest; other lessons cite their own r-era
  digests and are historical by construction (each names its round).

## 5. Required repair, for the C2 lattice (not executed here)

Per the correction-note discipline, the fix for `corpus/lessons/r22-unreal-review.md:48` is **not**
a silent rewrite to `f456bd00…` — that would swap one unreproducible number for another that is
itself guaranteed to drift again. It is a dated note that (a) keeps the r22 digest as the historical
record, and (b) states the current digest with an as-of date, or replaces the digest with a
re-derivable command (`git cat-file blob <r22-commit>:corpus/fixtures/run_battery.py | sha256sum`).
The mechanical `.shokunin/game-dev-3d/` path-prefix fix on line 42 is in-place per the same
discipline.

## 6. Reproduction

All commands above were run from the repo root at HEAD `2c99b7b`; every block is verbatim
stdout. Nothing was edited by this seat.
