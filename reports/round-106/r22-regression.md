# r106 · SEAT-93 · R22-REGRESSION — descriptor checker pair

**Seat:** SEAT-93 (R22-REGRESSION) · round 106 · lane `game-dev-3d-shokunin`
**Date:** 2026-10-18 · runtime `2026-10-18T21:20:26Z`–`2026-10-18T21:20:40Z`
**HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`, r105 report-last)
**Python:** `/usr/bin/python3` 3.14.7
**Writes:** this file only. Scratch controls under `reports/round-106/scratch/seat93/` (not `/tmp`). Nothing under `corpus/` was written.

**Question:** after the r106 citation sweep, do both arms of the r22 descriptor checker still exit 0 — accept the authored source, reject the paired bad-Type control?

**Verdict: both arms exit 0.** The checker still discriminates. Artifact bytes are identical to HEAD (`git diff --exit-code` → 0). No Unreal runtime was run; Unreal Editor and UnrealBuildTool are not on `PATH`.

Axes: calibration (exit codes match the lesson's expected accept/reject), coverage (repo-relative commands resolve), depth (receipts on the live tree, not a restatement of r22/r102).

## 1. The pair

Commands are the repo-root form in `corpus/artifacts/unreal-r22/README.md:8-9` and `corpus/lessons/r22-unreal-review.md:23-26`.

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo "accept_exit=$?"
PASS local-static actual=accept expected=accept path=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/artifacts/unreal-r22/Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
accept_exit=0

$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo "reject_exit=$?"
PASS local-static actual=reject expected=reject path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'
reject_exit=0
```

Rejection is the `MODULE_TYPES` membership miss (`unsupported module Type: 'Unknown'`), not a parse error. Crossed expectations fail, so the two exits are not a vacuous 0:

```
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py --expect-reject; echo "accept_as_reject_exit=$?"
FAIL local-static actual=accept expected=reject path=…/Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
accept_as_reject_exit=1

$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin; echo "reject_as_accept_exit=$?"
FAIL local-static actual=reject expected=accept path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'
reject_as_accept_exit=1
```

## 2. Bytes unchanged vs HEAD and vs the lesson table

```
$ git diff --exit-code -- corpus/artifacts/unreal-r22/; echo "diff_exit=$?"
diff_exit=0

$ stat -c '%n %s' corpus/artifacts/unreal-r22/*
corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin 374
corpus/artifacts/unreal-r22/Headless3DFixture.uplugin 374
corpus/artifacts/unreal-r22/README.md 1394
corpus/artifacts/unreal-r22/verify_descriptor.py 3122

$ sha256sum corpus/artifacts/unreal-r22/*
b56a356ef3c47a4880bd22f5dbcbb2ccf43e1cb65d263498674ef9b1c586ccf0  corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin
2543b337f6a63e8827b400939a85b3cc89c192345dcd63a37b96f25b4c89a0f9  corpus/artifacts/unreal-r22/Headless3DFixture.uplugin
1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b  corpus/artifacts/unreal-r22/README.md
ce07e9d5c03e892b0d9847b89ec67cc6b293f0979d2f5be5a99c6a53b21cea76  corpus/artifacts/unreal-r22/verify_descriptor.py
```

`git hash-object` equals `git rev-parse HEAD:<path>` for the checker (`3082ca7f8d52dfe41c0aa6effc29fc357f9db891`), the source (`b24be8cd164c30e8ab1d5ce22c2055e384702246`), and the control (`df56226d4bd872dda14fa86dd077d268d0684fa8`). `git log -1` on the checker is still `8b21cae` (2026-10-13, r22). The sweep did not touch this artifact.

Lesson table (`corpus/lessons/r22-unreal-review.md:13-16`) vs this tree:

| file | lesson | this run | |
|---|---|---|---|
| `Headless3DFixture.uplugin` | 374 / `2543b337…` | 374 / `2543b337…` | match |
| `Headless3DFixture.bad-type.uplugin` | 374 / `b56a356e…` | 374 / `b56a356e…` | match |
| `verify_descriptor.py` | 3122 / `ce07e9d5…` | 3122 / `ce07e9d5…` | match |
| `README.md` | 1460 / `26a12604…` | 1394 / `1c0d3035…` | r22 blob; r102 note already dates the drift (`:54`) |

The control is still the one-token replacement. Diff offsets are 320–326, same as the lesson:

```
token count in src: 1
control == src.replace(token, Unknown): True
len src/bad: 374 374 diff offsets: [320, 321, 322, 323, 324, 325, 326]
```

## 3. Lesson private controls still reject (scratch, not /tmp)

Rebuilt from the lesson's stated transforms into `reports/round-106/scratch/seat93/`. Each SHA matches the lesson table; each `--expect-reject` exits 0.

```
missing-name  sha_match=True 09acc4ce… exit=0  reason=module fields missing or unexpected
duplicate-key sha_match=True f163a3ba… exit=0  reason=invalid JSON: duplicate JSON key: Type
extra-module  sha_match=True e0f73b44… exit=0  reason=expected exactly one module object
editor-type   sha_match=True 4e1bb981… exit=0  reason=authored module type/loading phase mismatch
fv2           sha_match=True f2a88597… exit=0  reason=FileVersion must be 3 for authored sample
```

`editor-type` and `fv2` remain documented-legal Unreal shapes that this fixed-scope checker rejects on purpose. That is local sample enforcement, not Unreal rejection. Not part of the required pair; recorded because the sweep's most-touched artifact is this checker, and these are the lesson's other discriminating arms.

## 4. Boundary

- **No Unreal runtime claim.** `command -v UnrealEditor` and `command -v UnrealBuildTool` both printed "not in PATH". Acceptance is a local static JSON check.
- **Not a general schema validator.** Exact authored field set, one module, `FileVersion == 3`, `Type == "Runtime"`.
- **`--expect-reject` exit 0 is an expected local rejection.**
- A missing path is not a clean reject: `does-not-exist.uplugin --expect-reject` raised `FileNotFoundError` and exited 1. The pair does not exercise that path. Not a regression of the required arms.
- Godot battery and three.js were not re-run. Out of this seat's question.

## 5. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo "accept_exit=$?"
python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo "reject_exit=$?"
```
