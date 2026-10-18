# B2 REPAIR-VERIFY — unity-r19

- **Seat:** SEAT-27 REPAIR-VERIFY-UNITY · round 103 · lane `game-dev-3d-shokunin`
- **Owned path written:** `reports/round-103/b2/verify-unity.md` (only). No tracked file was touched.
- **Repo HEAD at verification:** `c85a816` (`git log --oneline -1`)
- **Date:** 2026-10-18 (verification window closed `2026-10-18T18:34:10Z`)
- **Subject of verification:** `corpus/artifacts/unity-r19/README.md` — SEAT-24's in-place repair
  of the two dead-root `uv run` lines (the B2 class-B item routed in `reports/round-102/fold-spec.md:371-423`).
- **VERDICT: PASS — repair verified.** Both repaired commands exit `0` on a pristine export, the
  diff touches only the two command lines, and every non-command byte (narrative, hashes, checker,
  scene artifacts) is identical to HEAD. One **new** stale-citation drift is routed below (§6).

---

## 1. Repair state at verification time

The repair is present in the **working tree, uncommitted** (`git status --porcelain` shows
` M corpus/artifacts/unity-r19/README.md`). SEAT-24's own report (`reports/round-103/b2/repair-unity.md`)
and SEAT-22's ruling (`reports/round-103/b2/ruling.md`) were **not yet landed** at my runtime
(`ls reports/round-103/b2/` → `adversary.md` only), so this verification is against the tree, not
against a landed rationale. My seat's scope is independent re-run + diff-scope audit; I did not
edit the README.

```
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ git status --porcelain
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
?? reports/round-103/
```

Hash pair (HEAD blob → worktree blob):

```
$ sha256sum corpus/artifacts/unity-r19/README.md
12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c  corpus/artifacts/unity-r19/README.md
$ git show HEAD:corpus/artifacts/unity-r19/README.md | sha256sum
c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660  -
```

Line count unchanged (20 → 20); byte size 1579 → 1513 (`stat -c %s` / `wc -c`).

## 2. BEFORE — the dead root, reproduced on a pristine export of HEAD

Method: read-only `git archive HEAD`, run from that tree's root. No mutation of the lane tree.

```
$ rm -rf /tmp/s27 && mkdir -p /tmp/s27
$ git archive HEAD corpus/artifacts/unity-r19 | tar -x -C /tmp/s27
$ cd /tmp/s27
$ grep -n "shokunin/game-dev-3d" corpus/artifacts/unity-r19/README.md
10:uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py
11:uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py .shokunin/game-dev-3d/corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py
/home/vgpnk/.cache/uv/builds-v0/.tmp6o6poi/bin/python: can't open file '/tmp/s27/.shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py': [Errno 2] No such file or directory
line10-deadroot-exit=2
$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py .shokunin/game-dev-3d/corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
… can't open file '/tmp/s27/.shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py': [Errno 2] No such file or directory
line11-deadroot-exit=2
```

Both lines exit **2** — matching `reports/round-102/fold-spec.md:380`'s recorded `exit=2`.

## 3. AFTER — the repaired lines, exact paste, on a pristine export

Method: `git archive HEAD` (pristine) + the worktree README copied in — i.e. the repaired
README against a tree containing no other round-103 change.

```
$ rm -rf /tmp/s27fresh && mkdir -p /tmp/s27fresh && git archive HEAD | tar -x -C /tmp/s27fresh
$ cp corpus/artifacts/unity-r19/README.md /tmp/s27fresh/corpus/artifacts/unity-r19/README.md
$ cd /tmp/s27fresh
$ grep -c "shokunin/game-dev-3d" corpus/artifacts/unity-r19/README.md
0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
PASS local-static actual=accept expected=accept path=/tmp/s27fresh/corpus/artifacts/unity-r19/Hierarchy.unity reason=two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)
fresh-rel-exit=0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
PASS local-static actual=reject expected=reject path=corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity reason=child father reference broken: {'fileID': 999}
fresh-rel-reject-exit=0
```

The literal README lines were then piped straight to `bash` from the lane repo root (not retyped):

```
$ sed -n '10p' corpus/artifacts/unity-r19/README.md | bash
PASS local-static actual=accept expected=accept path=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/artifacts/unity-r19/Hierarchy.unity reason=two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)
paste-exit=0
$ sed -n '11p' corpus/artifacts/unity-r19/README.md | bash
PASS local-static actual=reject expected=reject path=corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity reason=child father reference broken: {'fileID': 999}
paste11-exit=0
```

Accept arm and reject arm both green, both exit `0`.

## 4. Discriminating controls — the repair did not neuter the checker

A green exit code is only evidence if the checker can still fail. Two controls, both on the
repaired invocation shape:

```
$ rm -rf /tmp/s27mut && cp -r corpus/artifacts/unity-r19 /tmp/s27mut
$ sed -i 's/{fileID: 101}$/{fileID: 999}/' /tmp/s27mut/Hierarchy.unity
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py /tmp/s27mut/Hierarchy.unity
FAIL local-static actual=reject expected=accept path=/tmp/s27mut/Hierarchy.unity reason=GameObject component references broken
mut-exit=1
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.unity --expect-reject
FAIL local-static actual=accept expected=reject path=corpus/artifacts/unity-r19/Hierarchy.unity reason=two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)
wrong-expect-exit=1
```

Mutated-good-scene-without-flag → `1`; good-scene-with-wrong-expectation → `1`. The checker
discriminates in both directions, so the §3 greens are load-bearing.

**Limit recorded.** The README's own framing is *"From repository root"*; the commands are
repo-root-relative and therefore cwd-dependent by construction. From a different cwd they still
resolved here only because the relative path happened to match the deeper directory (`cd corpus &&
… artifacts/unity-r19/verify_scene.py` → exit 0). This is not a defect of the repair — it is the
same convention the README declares — but it is why the fix is a *path* fix, not a
cwd-independence fix.

## 5. Diff-scope audit — only the ruled lines changed

```
$ git diff --numstat -- corpus/artifacts/unity-r19/README.md
2	2	corpus/artifacts/unity-r19/README.md
$ git diff -U0 -- corpus/artifacts/unity-r19/README.md | grep -E '^[+-]' | grep -vE '^(\+\+\+|---)' | grep -v 'uv run' | wc -l
0
```

Word-diff shows the exact token change — the `-.shokunin/game-dev-3d/` prefix deleted twice, and
nothing else:

```
uv run --no-project --with pyyaml python [-.shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py-]{+corpus/artifacts/unity-r19/verify_scene.py+}
uv run --no-project --with pyyaml python [-.shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py .shokunin/game-dev-3d/corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity-]{+corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity+} --expect-reject
```

- **Class-B only.** Both changed lines are inside the fenced `sh` command block (README lines 10–11).
  Zero non-command lines changed (§ above, count `0`).
- **Narrative preserved.** Lines 3 and 7 (`References read 2026-10-13:` … `From repository root, …`)
  are byte-identical to HEAD (`sed -n '3p;7p'` on both sides, compared).
- **No historical claim rewritten.** The two Unity Manual references, the "not been imported or
  validated by Unity Editor" disclaimer, and the trailing scope paragraph are untouched. This
  respects the SEAT-11 F1 §5 R2/R3 discipline (correction-note for narrative, bounded in-place fix
  permitted for class-B command blocks only).
- **Not byte-pinned.** `grep -rn "unity-r19" corpus/knowledge/unreal-mcp/` → no hits; the file is
  outside the pinned subtree, so no manifest/gate obligation attaches to it.

**Untouched siblings, proven:**

```
$ git diff --stat -- corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.unity corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity
(empty)
$ sha256sum corpus/artifacts/unity-r19/verify_scene.py
decad886f4018aba13588934058b3be91a1ad71c59839edcc25d92d13015270b   # == r19 lesson's final-checker hash
$ sha256sum corpus/artifacts/unity-r19/Hierarchy.unity corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity
0c088c2352d5808150feaae87213a63f1d0fc5820eff1237246107b1143635f7
890f09293fe97f3bf78f2cee173567fb40d23e1e9be64614e1aee9e205c701a7
```

All three match the hashes the r19 lessons pin. The repair touched no evidence artifact.

## 6. ROUTED (not mine to fix) — the repair creates one stale sibling citation

Two committed lessons cite the **old** README sha, which the repair has now superseded:

```
$ git grep -n "c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660"
corpus/lessons/r19-unity-final-review.md:9:… Artifact README SHA-256 `c4463ab5…`.
corpus/lessons/r19-unity-review.md:9:… Artifact README SHA-256 `c4463ab5…`.
$ git grep -n "12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c"
(no output)
```

Both lessons also still carry the dead `.shokunin/game-dev-3d/` root
(`grep -c` → `4` in `r19-unity-final-review.md`, `12` in `r19-unity-review.md`). Those are
**class-A/C historical narrative** — per SEAT-11 F1 §5 R2/R3 they take a dated correction note,
not an in-place rewrite, and the systemic scope is the L1's ruling (R4). The new sha is not yet
recorded anywhere; whichever seat lands the correction note should carry both facts
(root convention + superseded README sha `c4463ab5…` → `12c4abd1…`). **No Unreal/Unity runtime
claim is made here:** no Unity Editor is installed on this host
(`command -v Unity unity-editor UnityHub unityhub` → `rc=1`); every green above exercises a local
static YAML checker, not an engine.

## 7. Cross-check at verification time

- Repo-wide dead-root census: `glb-r12/README.md` **0** (SEAT-23's repair also landed),
  `unity-r19/README.md` **0**, `fixtures/three/README.md` **17** (SEAT-25 not yet landed at my
  runtime — `git diff --stat -- corpus/fixtures/three/README.md` empty). The class-B sweep is
  therefore 2 of 3 complete at this frame; `reports/round-103/b2/postgrep.md` (SEAT-31) owns the
  final count.
- Subtree gate re-run unchanged and green:
  `MANIFEST_OK=12 EXPECTED=12 FAILED=0` · `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`
  · `CARDS=13 EXPECTED=13 BAD=0` · `CENSUS static-only=12 unproven-runtime=1 verified-here=0`
  · `POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` · `GATE RESULT: PASS (checks failed: 0)` · `GATE_RC=0`.

## 8. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# hashes
sha256sum corpus/artifacts/unity-r19/README.md
git show HEAD:corpus/artifacts/unity-r19/README.md | sha256sum

# BEFORE: dead root on a pristine export
rm -rf /tmp/s27 && mkdir -p /tmp/s27
git archive HEAD corpus/artifacts/unity-r19 | tar -x -C /tmp/s27
(cd /tmp/s27 && uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py); echo "exit=$?"   # 2

# AFTER: repaired lines, exact paste
sed -n '10p' corpus/artifacts/unity-r19/README.md | bash; echo "exit=$?"   # 0
sed -n '11p' corpus/artifacts/unity-r19/README.md | bash; echo "exit=$?"   # 0

# diff scope: only the two command lines
git diff --numstat -- corpus/artifacts/unity-r19/README.md                     # 2 2
git diff --word-diff=plain -- corpus/artifacts/unity-r19/README.md

# untouched siblings
git diff --stat -- corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy*.unity   # empty

# the routed drift
git grep -n "c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660"
grep -c "shokunin/game-dev-3d" corpus/lessons/r19-unity-review.md corpus/lessons/r19-unity-final-review.md   # 12, 4
```
