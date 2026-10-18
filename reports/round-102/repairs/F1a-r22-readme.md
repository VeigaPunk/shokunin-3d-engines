# F1a — r22 artifact README path-root repair

Seat: SEAT-07 REPAIR. Owned path: `corpus/artifacts/unreal-r22/README.md` (only).
Discipline: mechanical command/path conformance fix, applied in place (not a historical factual claim, so no dated correction note is required). The r101 byte-pinned subtree `corpus/knowledge/unreal-mcp/` was not touched. No lesson file was touched.

## Defect

`corpus/artifacts/unreal-r22/README.md` presented its runnable commands under the heading "From repo root:" but rooted both paths at `.shokunin/game-dev-3d/`, a directory that never existed in this repo. The real repo root is `game-dev-3d-shokunin/`, so the repo-relative path is `corpus/artifacts/unreal-r22/`.

Defective lines (original README lines 8–9):

```sh
python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py
python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
```

## BEFORE (fail) — run from repo root `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py': [Errno 2] No such file or directory
exit=2

$ python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py': [Errno 2] No such file or directory
exit=2
```

Both commands exit 2 (file not found), matching the routed F1 report.

## Fix (in place)

Two lines changed, prefix `.shokunin/game-dev-3d/` dropped so the commands are genuinely repo-relative and consistent with the "From repo root:" heading:

```sh
python3 corpus/artifacts/unreal-r22/verify_descriptor.py
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
```

No other content of the README was modified.

## AFTER (pass) — re-run from repo root

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py
PASS local-static actual=accept expected=accept path=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/artifacts/unreal-r22/Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
exit=0

$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
PASS local-static actual=reject expected=reject path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'
exit=0
```

Both commands exit 0. The positive case accepts `Headless3DFixture.uplugin`; the negative control rejects the `Type: Unknown` variant, so the pair still discriminates.

## Residual scan

```
$ grep -n "shokunin/game-dev-3d" corpus/artifacts/unreal-r22/README.md
(no output; grep exit 1)
```

No `.shokunin/game-dev-3d/` path root remains in the owned README.

## Scope note

The same stale path root also appears in `corpus/lessons/r22-unreal-review.md` (lines 7, 23, 25, 29, 42, 44, 48) — that file is not owned by this seat (explicitly: do not touch any lesson file) and is left for the seat that owns the F1b lesson repair. `corpus/artifacts/unreal-r22/` contains no other file referencing the bad root.
