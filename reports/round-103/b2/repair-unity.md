# r103 SEAT-24 — REPAIR-UNITY (B2, unity-r19 slice)

Owned path: `corpus/artifacts/unity-r19/README.md` (only tracked file written by this seat).
Written by this seat: that README + this report.

- Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
- Probe date: **2026-10-18**
- Discipline: mechanical command/path conformance fix applied in place (F1a precedent,
  `reports/round-102/repairs/F1a-r22-readme.md`). This is not a historical factual claim, so no
  dated correction note is required for the command lines themselves. One **consequential** digest
  drift is reported in §4, not repaired (the affected files are not this seat's).
- Not touched: `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`,
  `corpus/fixtures/**`, `reports/round-101/**`, `reports/round-102/**`,
  `corpus/knowledge/unreal-mcp/**` (incl. `upstream/` and `.manifest.d/`), any lesson file.
  No `git commit`/`push`/`checkout`/`reset` was run.
- No Unreal runtime claim is made anywhere here; Unreal Editor is not installed and live-MCP
  behavior remains unproven by construction. Unity Editor is likewise not installed: everything
  below exercises a local static YAML checker, never an engine.

---

## 1. Defect (reproduced BEFORE, verbatim from the repo root)

`corpus/artifacts/unity-r19/README.md` framed its commands under "From repository root" but rooted
both paths at `.shokunin/game-dev-3d/`, a directory that never existed in this repo. It is the F1
class (`reports/round-102/adversary/F1.md`), on the third of the three runnable READMEs named by
fold-spec B2 (`reports/round-102/fold-spec.md:380-397`).

```
$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py
/home/vgpnk/.cache/uv/builds-v0/.tmpDHsIG7/bin/python: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py': [Errno 2] No such file or directory
exit=2

$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py .shokunin/game-dev-3d/corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
/home/vgpnk/.cache/uv/builds-v0/.tmpYI5Zb6/bin/python: can't open file '.../.shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py': [Errno 2] No such file or directory
exit=2
```

Both arms exit **2**, matching the routed report (`glb-r12 exit=2, unity-r19 exit=2, three exit=1`).

## 2. Fix (in place, 2 lines)

```diff
--- i/corpus/artifacts/unity-r19/README.md
+++ w/corpus/artifacts/unity-r19/README.md
@@ -7,8 +7,8 @@ From repository root, use the declared isolated Python package environment:
 ```sh
-uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py
-uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py .shokunin/game-dev-3d/corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
+uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
+uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
 ```

$ git diff --stat -- corpus/artifacts/unity-r19/README.md
 corpus/artifacts/unity-r19/README.md | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
```

Only the two command lines changed; the heading, the two reference bullets, and the scoping
paragraph are byte-identical. No prose was reworded.

## 3. AFTER — both documented commands, re-run from the repo root

```
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
PASS local-static actual=accept expected=accept path=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/artifacts/unity-r19/Hierarchy.unity reason=two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)
exit=0

$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
PASS local-static actual=reject expected=reject path=corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity reason=child father reference broken: {'fileID': 999}
exit=0
```

**The pair still discriminates** — the negative control is not vacuously green (cross-armed):

```
$ ... verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity          # broken file, no flag
FAIL local-static actual=reject expected=accept ... reason=child father reference broken: {'fileID': 999}
exit=1

$ ... verify_scene.py corpus/artifacts/unity-r19/Hierarchy.unity --expect-reject            # valid file, wrong flag
FAIL local-static actual=accept expected=reject ... reason=two GameObjects and two Transforms; ...
exit=1
```

Each arm fails when handed the other's input, so `exit=0` on both documented arms is a real
discrimination and not a checker that always passes.

**Residual scan (acceptance criterion):**

```
$ grep -c "shokunin/game-dev-3d" corpus/artifacts/unity-r19/README.md
0
(grep exit 1)

$ git grep -c "shokunin/game-dev-3d" -- corpus/artifacts/unity-r19/
(git grep exit 1)          # zero hits across the whole directory, not just the README
```

The checker (`verify_scene.py`) and both `.unity` fixtures never contained the prefix. Repo-wide the
live count moves **167 → 166** (`git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l` = 167,
worktree = 166), i.e. exactly this one file — the other 165 files are the pending L1 systemic
ruling's scope, untouched.

**Digests:**

| state | bytes | sha256 |
|---|---:|---|
| before (HEAD `c85a816`) | 1579 | `c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660` |
| after (worktree) | 1513 | `12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c` |

## 4. Consequential digest drift — reported, NOT repaired (outside this seat)

The pre-fix README digest `c4463ab5…` is **cited as a live fact in two r19 lesson files**, so this
repair stales them:

```
$ git grep -n "c4463ab5" -- .
corpus/lessons/r19-unity-final-review.md:9:  ... Artifact README SHA-256 `c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660`.
corpus/lessons/r19-unity-review.md:9:        ... Artifact README SHA-256 `c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660`.
```

This is precisely the r22 precedent: the r102 r22 README repair invalidated that README's digest row
and a dated correction note recorded both values (`corpus/lessons/r22-unreal-review.md:54`,
`reports/round-102/repairs/F1b-F2-r22-lesson.md`). Here the stale claim is a **bare digest string**
with no byte size, in the two r19 lessons' §"digests" narrative.

**Neither lesson is this seat's to edit** (ownership: this seat owns the unity-r19 README only;
`PROTOCOL.md:123` / `CORPUS.md:52` bind in-place narrative rewrites). So this is reported for the
L1/owning seat, with the reproduction the note will need:

```
$ git cat-file blob HEAD:corpus/artifacts/unity-r19/README.md | sha256sum
c4463ab5ef137acc54fb0c56023f8f37f23afbce21dda992fdd5a268a10a8660  -      # old digest re-derivable
$ sha256sum corpus/artifacts/unity-r19/README.md
12c4abd106b3e5a341fbede8c54563b9332a16ec6b805258788704934d608b4c  corpus/artifacts/unity-r19/README.md
```

The old value stays re-derivable from history, so a one-bullet dated correction note in each lesson
can carry both digests without rewriting the r19 record — same shape as the r22 F1b note.

Note also that both lessons carry the dead `.shokunin/game-dev-3d/` root in their **narrative**
(`r19-unity-review.md` 12 lines, `r19-unity-final-review.md` 4 lines: 7, 15, 20, 28). Per F1's
R2/R3 those are class-A historical narrative + class-B command lines under the **deferred systemic
ruling**; this seat did not touch them and takes no position on the R4 option choice.

## 5. `phys3d_joints_free_ops` — investigation only (NOT repaired)

Task framing said the row "failed the r102 idle run … failure class uninvestigated." It is now
investigated, and the class is **neither fixture corruption nor marker drift** — it is a
**case-level wall-clock cap that this row exceeds on this host**.

**r102 receipt facts** (`corpus/live/runs/20261018T181301123479Z/verdicts.json`, gitignored):

```
case              = phys3d_joints_free_ops
command           = /usr/bin/godot --headless --path .../scratch --script res://phys3d_joints.gd -- --arm=free_ops
expected_exit=0   actual_exit=None
error             = TIMEOUT after 20 seconds
elapsed_seconds   = 20.008
case_timeout_seconds = 20        (run_battery.py:36 CASE_TIMEOUT_SECONDS = 20)
stdout            = ['Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf ...']     # boot banner only
stderr            = []
reasons           = ['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']
totals            = {'cases': 350, 'pass': 336, 'fail': 14, ...}    # the other 13 = r94_cannon marker drift
```

**Mechanism — the arm is 21 sequential engine boots and takes ~21–22 s idle:**

```
$ timeout 120 godot --headless --path <copy of corpus/fixtures> --script res://phys3d_joints.gd -- --arm=free_ops
PASS phys3d_joints free_ops freeb_ops@gp{mode_ok=1,m6=124dfece8083d80f} freeb_ops@jolt{mode_ok=1,m6=0b9af1d2f64aad4a} ... (full expected marker)
rc=0  wall_ms=21362

# two further idle re-runs of the same arm, same tree:
trial1 rc=0 wall_ms=21830
trial2 rc=0 wall_ms=21981
```

The arm is `free_ops` = 7 sub-cases × 3 backends (`gp`/`jolt`/`dummy`) = **21 child processes**
(`corpus/fixtures/phys3d_joints.gd:37-39`; `BOUND_S := 20` is the *child* bound, and the parent
boots each child serially via `OS.execute("/bin/sh", ...)`, `:135`). Measured child-boot cost is
~0.8 s and the whole arm lands at 21.4–22.0 s — consistently **just over the 20 s case cap** and
nowhere near it under a larger cap. The r102 receipt's `user`+`sys` CPU for the arm was ~3.7 s of a
25 s wall, i.e. the time is dominated by process spawn/teardown, not by computation.

**Reproduced deterministically through the battery's own path** (not only by hand):

```
$ timeout 280 python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops
FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', ...]
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
exit=1
```

So on this host the row is a **deterministic timeout under the default cap** and a **deterministic
pass under a ~30 s cap** — a margin problem, not flakiness and not a broken assertion. Every one of
the 49 `phys3d_*` rows passes except this one; the arm's own marker matches the pinned expectation
exactly when it is allowed to finish.

**Why the r102 idle run was the first to catch it:** the sibling arm `phys3d_joints_free_pair` is
the next-slowest row at **12.08 s** (9 children), and `r100_fpslat_life` at **15.98 s**. `free_ops`
is the only row whose serial-boot cost crosses the cap, so it is the only one exposed by the cap;
the 13 `r94_cannon_*` failures are a *different* class (node-marker drift) and are correctly
separated in the r102 record.

**Disposition — investigated, not repaired** (per this seat's brief). The bytes of
`corpus/fixtures/**` are byte-pinned and untouched (`git status --porcelain -- corpus/fixtures`
empty; tracked-file count still 146 = HEAD). The two candidate fixes — raise the case cap, or split
the arm — are battery-boundary decisions for the operator/L1, not a seat's silent edit. Recorded
here so the routed queue carries the *class* rather than "failure class uninvestigated."

**Side observation (conformance, transient):** while this probe ran, concurrent peer seats
(`--path .` from a shell whose cwd was `corpus/fixtures/`, plus a `cp -a corpus/fixtures/. /tmp/...`
probe) materialized `r90bt_*` scratch directories **inside the protected `corpus/fixtures/` path**.
They are untracked and not gitignored (`git check-ignore` rc=1), and they inflate the runner's seed
map: the r102 receipt has 130 seed digests, my `--only` receipt has 166, and the 36 extras are all
`r90bt_*/{project.godot,child.log}`. That is why my `--only` run printed
`FAIL seeds were modified during the run` while the r102 idle receipt has `seeds_unchanged: True`.
The residue was already gone by the confirming sweep (`ls -d corpus/fixtures/r90bt_*` → none;
tracked count back to 146), so no cleanup was needed and none was performed. Flagged because a
peer seat's probe placing scratch inside a byte-pinned tree is itself the F5/B2 class, and because
it can perturb any concurrent battery run's seed check.

## 6. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# 1. the two documented arms now pass, and the pair discriminates
uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py; echo "exit=$?"                       # 0
uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject; echo "exit=$?"   # 0

# 2. residual scan and diff scope
grep -c "shokunin/game-dev-3d" corpus/artifacts/unity-r19/README.md          # 0, grep exit 1
git diff --stat -- corpus/artifacts/unity-r19/README.md                      # 1 file, 2(+/-)

# 3. digest drift, both values
git cat-file blob HEAD:corpus/artifacts/unity-r19/README.md | sha256sum      # c4463ab5…
sha256sum corpus/artifacts/unity-r19/README.md                               # 12c4abd1…
git grep -n "c4463ab5" -- .                                                  # 2 lesson citations

# 4. the physics row: cap-exceeded, not broken (isolated copy; leaves the tree clean)
T=$(mktemp -d); (cd corpus/fixtures && tar cf - --exclude=three --exclude=__pycache__ .) | (cd "$T" && tar xf -)
time timeout 120 godot --headless --path "$T" --script res://phys3d_joints.gd -- --arm=free_ops; echo "exit=$?"   # ~21-22s, 0, full marker

# 5. and the battery's own path reproduces the timeout at the default 20s cap
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops; echo "exit=$?"     # FAIL, TIMEOUT after 20 seconds
```

## 7. Seat conclusion

The unity-r19 README defect is repaired and verified: both documented commands go 2 → **0**, the
positive/negative pair still discriminates in both cross-armed directions, and the dead root is gone
from the file (and the directory) entirely. The fix costs one stale citation elsewhere — the
README's own digest, cited in two r19 lessons — which is reported with its re-derivation command and
deliberately left to the owning seat under the r22 correction-note precedent.

On the physics row: the r102 idle failure is a **wall-clock cap margin** issue (21 serial engine
boots ≈ 21–22 s vs a 20 s cap), reproduced through the battery's own `--only` path and
deterministically passing under a larger cap. Not repaired — `corpus/fixtures/**` is byte-pinned
and the remedy is a battery-boundary decision. No Unreal or Unity runtime claim is made: every
`exit=0` above comes from a local static checker or a headless Godot fixture, never an engine that
is installed as a product.
