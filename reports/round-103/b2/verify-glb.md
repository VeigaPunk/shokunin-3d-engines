# B2 REPAIR-VERIFY — glb-r12

- **Seat:** SEAT-26 REPAIR-VERIFY-GLB · round 103 · lane `game-dev-3d-shokunin`
- **Owned path written:** `reports/round-103/b2/verify-glb.md` (only). No tracked file was touched.
- **Repo HEAD at verification:** `c85a816` (`git log --oneline -1`)
- **Date:** 2026-10-18 (verification window closed `2026-10-18T18:52:17Z`)
- **Subject of verification:** `corpus/artifacts/glb-r12/README.md` — SEAT-23's in-place repair of
  the three dead-root command lines (the B2 class-B item routed in
  `reports/round-102/fold-spec.md:371-423`).
- **VERDICT: PASS on the two commands the fold-spec accepts as exit-0 (lines 6 and 8); PASS on the
  diff-scope audit. Line 7 (the full battery) now *resolves and runs* — the path defect is gone —
  but exits `1` for pre-existing, path-independent reasons, reproduced here rather than papered over.
  One **new** flaky row is routed in §6.**

---

## 1. Repair state at verification time

The repair is present in the **working tree, uncommitted** (`git status --porcelain` shows
` M corpus/artifacts/glb-r12/README.md`). SEAT-23's own report
(`reports/round-103/b2/repair-glb.md`) landed while this seat was verifying; this verification is
against the tree, and its numbers were re-derived independently rather than quoted from that file.
My seat's scope is independent re-run + diff-scope audit; I did not edit the README.

```
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ git status --porcelain
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? reports/round-103/
```

Blob identity before → after (object id and sha256 both agree with SEAT-23):

```
$ git rev-parse HEAD:corpus/artifacts/glb-r12/README.md
660fb2fb337c8df445fd59881975e3717b7aa762
$ git hash-object corpus/artifacts/glb-r12/README.md
d70045de8b47f7bb5aff82c5dcba8ea47f6a38c3
$ git show HEAD:corpus/artifacts/glb-r12/README.md | sha256sum
0af4f3691e19f8588c54ceb494802dae7bd8e937e03c1bc121de071ca871dbe1  -
$ sha256sum corpus/artifacts/glb-r12/README.md
d87774dcfc3c6265957e2850b4fc2f29a72eabef9697424009d6355d05b8582b  corpus/artifacts/glb-r12/README.md
```

Line count unchanged (19 → 19); byte size 1693 → 1627. The 66-byte drop is exactly
`3 × len('.shokunin/game-dev-3d/')`:

```
$ python3 -c "print(3*len('.shokunin/game-dev-3d/'))"
66
$ python3 -c "print(1693-1627)"
66
```

## 2. BEFORE — the dead root, reproduced on the repaired file's pre-image

Method: the defective lines run verbatim from the repo root against `HEAD`'s path spelling (the
worktree README is already repaired, so the dead-root form is taken from `git show HEAD:`).

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py': [Errno 2] No such file or directory
exit=2
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py': [Errno 2] No such file or directory
exit=2
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
node:internal/modules/cjs/loader:1607
  throw err;
exit=1
```

Exit codes `2 / 2 / 1` — matching `reports/round-102/fold-spec.md:379-382`'s recorded
`glb-r12 exit=2`, `unity-r19 exit=2`, `three exit=1` triple.

## 3. AFTER — the repaired lines, re-run from the repo root

Lines piped straight out of the worktree README (not retyped), so the evidence is the shipped text:

```
$ sed -n '6p' corpus/artifacts/glb-r12/README.md | bash
PASS Godot GLB import: valid/tolerated load, bad magic diagnosed and not loaded; receipt=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/r12-import-20261018T185205893275Z/verdicts.json
paste6-exit=0

$ sed -n '8p' corpus/artifacts/glb-r12/README.md | bash
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
paste8-exit=0
```

Both exit `0`. These are the two glb commands the fold-spec lists among its "exit 0" forms
(`reports/round-102/fold-spec.md:385-391` names `glb-r12/run_import.py` and `three/run_cases.mjs`;
the unity one is the sibling seat's subject, `reports/round-103/b2/verify-unity.md`).

Host toolchain (read, not assumed):

```
$ godot --version        → 4.7.2.stable.arch_linux.ed1daf0bf
$ node --version         → v26.12.0
$ blender --version      → Blender 5.2.1 LTS
```

## 4. Command 2 — the full battery: resolves now, still red for pre-existing reasons

Line 7 (`python3 corpus/fixtures/run_battery.py`) is **not** in the fold-spec's exit-0 list; the
B2 acceptance is that the commands *resolve and run* from the repo root. Re-run in full, it does:

```
$ python3 corpus/fixtures/run_battery.py   (from the repo root)
… 350 rows …
totals: cases=350 pass=335 fail=15 ordinary=291 negative_controls=59 probes=0
FAIL battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T183757977812Z/verdicts.json
BATTERY_EXIT=1
```

Full receipt: `corpus/live/runs/20261018T183757977812Z/verdicts.json`
(sha256 `b6e8d5978b52e2a0a8428d5adafa6d618fa5fa4a77e2897f597b6cf2e98e44c9`),
`seeds_unchanged: true`. The 15 non-PASS rows are the r102 failure set **plus one**:

| row class | count | actual/expected exit | cause |
|---|---:|---|---|
| `r94_cannon_*` | 13 | `0 / 0` | stdout marker pins `node=v24.21.0`; host runs `v26.12.0` |
| `phys3d_joints_free_ops` | 1 | `None / 0` | `TIMEOUT after 20 seconds` |
| `bpy_rbw3d_render` | 1 | `0 / 0` | **new this run** — flaky, see §6 |

This reproduces r102's receipt exactly for 14 of 15 rows (`corpus/live/runs/20261018T181301123479Z`
had `phys3d_joints_free_ops` + 13 `r94_cannon_*` = 14 non-PASS of 350). The marker drift is baked
into the battery source, not the path:

```
$ grep -c "node=v24.21.0" corpus/fixtures/run_battery.py
13
$ node --version
v26.12.0
```

`phys3d_joints_free_ops` is the exact row this round routes to **investigation, not repair**; this
seat does not touch it and makes no claim about its cause beyond the observed 20-second timeout,
which it reproduced independently (r102 `None`, this run `None`). **No fixture was modified** by the
repair or by this verification (`git status` shows `corpus/fixtures/**` clean apart from the sibling
three-README repair), and the battery's own `seeds_unchanged: true` is the guard.

## 5. Diff-scope audit — only the ruled lines changed

```
$ git diff --stat -- corpus/artifacts/glb-r12/README.md
 corpus/artifacts/glb-r12/README.md | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

$ git diff -U0 -- corpus/artifacts/glb-r12/README.md
@@ -6,3 +6,3 @@ From the repo root run:
-python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
-python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
-node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
+python3 corpus/artifacts/glb-r12/run_import.py
+python3 corpus/fixtures/run_battery.py
+node corpus/fixtures/three/run_cases.mjs
```

Word-diff shows the token change is exactly the `-.shokunin/game-dev-3d/` prefix, three times, and
nothing else:

```
$ git diff --word-diff=plain -- corpus/artifacts/glb-r12/README.md
python3 [-.shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py-]{+corpus/artifacts/glb-r12/run_import.py+}
python3 [-.shokunin/game-dev-3d/corpus/fixtures/run_battery.py-]{+corpus/fixtures/run_battery.py+}
node [-.shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs-]{+corpus/fixtures/three/run_cases.mjs+}
```

Independent scope proofs, stronger than the diff itself:

```
# no non-command line changed
$ git diff -U0 -- corpus/artifacts/glb-r12/README.md | grep -E '^[+-]' \
    | grep -vE '^(\+\+\+|---)' | grep -vE 'run_import|run_battery|run_cases' | wc -l
0

# every non-command line byte-identical to HEAD (lines 1-5 and 9-19)
$ diff <(git show HEAD:corpus/artifacts/glb-r12/README.md | sed -n '1,5p;9,19p') \
       <(sed -n '1,5p;9,19p' corpus/artifacts/glb-r12/README.md)
IDENTICAL

# reconstruct-by-strip: removing only the literal prefix from HEAD reproduces the worktree byte-for-byte
$ git show HEAD:corpus/artifacts/glb-r12/README.md | sed 's#\.shokunin/game-dev-3d/##g' | sha256sum
d87774dcfc3c6265957e2850b4fc2f29a72eabef9697424009d6355d05b8582b  -
$ sha256sum corpus/artifacts/glb-r12/README.md
d87774dcfc3c6265957e2850b4fc2f29a72eabef9697424009d6355d05b8582b  corpus/artifacts/glb-r12/README.md
```

The reconstruct-by-strip equality is the decisive scope proof: it is impossible for any other byte
to have changed. The prose, the three-row GLB contrast table, the heading "From the repo root run:"
and the limits paragraph are all preserved.

**Not byte-pinned.** `corpus/artifacts/glb-r12/` is outside the pinned subtree
(`corpus/knowledge/unreal-mcp/`); no manifest or gate obligation attaches to the file. **No stale
citation is invalidated by the edit** — neither the pre-repair blob sha (`0af4f369…`) nor the path
`glb-r12/README` is cited as evidence anywhere:

```
$ git grep -l "0af4f3691e19f8588c54ceb494802dae7bd8e937e03c1bc121de071ca871dbe1" HEAD
(no output; exit=1)
$ grep -rl "d87774dcfc3c6265957e2850b4fc2f29a72eabef9697424009d6355d05b8582b" .
(no output; exit=1)
```

This is why the keep-list's decisive K4 harm mode (repair falsifies a cited digest) does **not**
apply to this file — unlike the unity-r19 repair, which superseded a README sha that two lessons
cite (`reports/round-103/b2/verify-unity.md` §6). The `README.md` entry in `run_battery.seed_digests()`
is `corpus/fixtures/README.md` (digest `347e0d1e…`), not this artifact README.

## 6. ROUTED (not mine to fix) — one new flaky row, and the marker-drift class

**`bpy_rbw3d_render` is flaky under load.** It passed in r102's receipt and failed in this run's,
with `actual_exit=0 / expected_exit=0` — only the exact stdout marker differs, at a behavioural
token, not a version token:

```
$ python3 -c "…compare pinned marker to this run's stdout…"
first diff at 723
EXP … 'M rdet same_state stable=False|M rdet moved_state differs=True|M DONE case=rdet…'
ACT … 'M rdet same_state stable=True|M rdet moved_state differs=True|M DONE case=rdet…'
```

Isolated re-runs pass every time (4/4), each reproducing the pinned `stable=False`:

```
$ for i in 1 2 3; do python3 corpus/fixtures/run_battery.py --only bpy_rbw3d_render; done
PASS bpy_rbw3d_render: exit=0 expected=0   (×3)
$ python3 corpus/fixtures/run_battery.py --only bpy_rbw3d_render   # logged receipt
PASS bpy_rbw3d_render: exit=0 expected=0
receipt corpus/live/runs/20261018T185145770540Z/verdicts.json → stable=False (matches pin)
```

So the row is **timing/load sensitive, not a hard failure** — a load-induced `stable=True` variant
exists that the pinned marker does not admit. This is a **new routed item** (r102 saw it PASS); it
belongs to whoever owns the `bpy_*` marker baseline, alongside the already-routed
`node=v24.21.0` drift. It is **not** a consequence of the glb path repair — the repaired line 7 and
the pre-repair path never reached this row differently; the row's own script is unchanged and
`seeds_unchanged: true`.

## 7. Cross-check at verification time

- Class-B sweep state: `glb-r12/README.md` **0** hits, `unity-r19/README.md` **0**,
  `corpus/fixtures/three/README.md` **0** (the sibling SEAT-25 repair also landed —
  `reports/round-103/b2/repair-three.md`). The three-file class-B repair is complete at this frame.
- The three REA receipts under `corpus/artifacts/` that still carry the prefix
  (`glb-r9/rea-inspect-error.json`, `zip-r10/rea-positive.json`, `zip-r10/rea-negative.json`) are
  keep-list K5 (raw machine-printed tool output) — untouched by construction.
- Subtree gate re-run at this frame is green and unchanged (`reports/round-103/gate/clean.now.txt`:
  `MANIFEST_OK=12 EXPECTED=12 FAILED=0` · `CARDS=13 EXPECTED=13 BAD=0` ·
  `GATE RESULT: PASS (checks failed: 0)`). This seat did not touch the pinned subtree.

## 8. Limits of this file

- **No Unreal runtime claim appears in this file.** The Unreal Editor is not installed on this host
  and live-MCP behaviour is unproven by construction; nothing here is evidence of engine behaviour.
  The commands exercised are Godot 4.7.2 headless, Blender 5.2.1 batch, three.js under Node, and
  CPython — no Unreal, no rendered output, no pixels read.
- Every number was measured on the r103 working tree at HEAD `c85a816` with the command shown. The
  tree mutates under concurrent seats (six tracked files were modified by sibling seats while this
  seat ran), so a folding seat must re-read the target before acting; treat §1's hashes as a frame
  with a timestamp.
- The full-battery run's **first** attempt died at case 158/350 on `echo: write error: Disk quota
  exceeded` — root cause `/tmp` being a 16G tmpfs at 80% full, not a battery or path defect. It was
  re-run with its log under the gitignored `corpus/live/` and completed 350/350. Recorded so the
  abort is not mistaken for a result.
- This seat wrote **only** `reports/round-103/b2/verify-glb.md`. No source file, lesson, fixture,
  manifest, receipt, or other seat's report was modified; no commit, push, checkout, or reset was run.

## 9. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# §1 hashes
git rev-parse HEAD:corpus/artifacts/glb-r12/README.md        # 660fb2f…
git hash-object corpus/artifacts/glb-r12/README.md          # d70045d…
git show HEAD:corpus/artifacts/glb-r12/README.md | sha256sum # 0af4f369…
sha256sum corpus/artifacts/glb-r12/README.md                # d87774dc…

# §2 BEFORE: the dead root (exit 2 / 2 / 1)
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py;   echo "exit=$?"   # 2
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py;           echo "exit=$?"   # 2
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs;         echo "exit=$?"   # 1

# §3 AFTER: the repaired lines, piped from the README (exit 0)
sed -n '6p' corpus/artifacts/glb-r12/README.md | bash; echo "exit=$?"   # 0
sed -n '8p' corpus/artifacts/glb-r12/README.md | bash; echo "exit=$?"   # 0

# §4 the battery resolves and runs (exit 1 — pre-existing rows)
python3 corpus/fixtures/run_battery.py; echo "exit=$?"                  # see §4

# §5 diff scope — only lines 6-8
git diff --stat -- corpus/artifacts/glb-r12/README.md                   # 1 file, 3 insertions(+), 3 deletions(-)
git diff -U0 -- corpus/artifacts/glb-r12/README.md | grep -E '^[+-]' \
  | grep -vE '^(\+\+\+|---)' | grep -vE 'run_import|run_battery|run_cases' | wc -l   # 0
git show HEAD:corpus/artifacts/glb-r12/README.md | sed 's#\.shokunin/game-dev-3d/##g' | sha256sum  # d87774dc…

# §6 the flaky row
python3 corpus/fixtures/run_battery.py --only bpy_rbw3d_render; echo "exit=$?"   # 0, stable=False
```
