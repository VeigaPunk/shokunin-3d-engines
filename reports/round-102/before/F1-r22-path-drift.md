# F1 — r22 README/lesson cite a `.shokunin/game-dev-3d/` repo root that never existed

**Seat:** SEAT-01 (before-capture). **No file edits.** Lane repo `game-dev-3d-shokunin`, HEAD `2c99b7b8155841617d844c609813afcba77aa207` (r101 report-last; work commit `1659c036`). All commands below were run from the lane repo root, 2026-10-18.

## 1. Claim under test

Two r22 files (both from commit `8b21cae13cd1067401a734a198abfd2e47f9b334`, the r22 work commit) instruct the reader to run their commands from a repository root containing a `.shokunin/game-dev-3d/` prefix:

- `corpus/artifacts/unreal-r22/README.md` — "From repo root:" then two `python3 .shokunin/game-dev-3d/...` commands.
- `corpus/lessons/r22-unreal-review.md` — "Exact replay (repository root)" block (two `python3 .shokunin/...` commands), one private-copy command form, the "Existing execution baselines" block (`python3 .shokunin/.../run_battery.py`, `node .shokunin/.../run_cases.mjs`), one inline `node .shokunin/.../scene_graph.mjs`, plus a prose path ``.shokunin/game-dev-3d/LOG.md``.

Occurrence counts of the literal `.shokunin/game-dev-3d` in the **HEAD blobs** (`git show HEAD:<path> | grep -c`): README = **2**, lesson = **7**.

## 2. The cited root does not exist — and never did

```
$ ls -la .shokunin
ls: cannot access '.shokunin': No such file or directory
exit=2
```

Not present in the lane repo, not present in the parent repo `/home/vgpnk/Projects/shokunin` either (`ls -la /home/vgpnk/Projects/shokunin/.shokunin` → `No such file or directory`, exit 2).

No commit in either repository has ever tracked such a path:

```
$ git log --all --oneline --name-only | grep -c '^\.shokunin/game-dev-3d/'
0
$ cd /home/vgpnk/Projects/shokunin && git log --all --oneline --name-only | grep -m5 '^\.shokunin/game-dev-3d/'
grep_exit=1        # no match
$ git ls-files | grep -m5 'shokunin/game-dev-3d'    # parent repo
                   # empty
```

`git show --stat 8b21cae` confirms the r22 commit itself wrote paths rooted at `corpus/...`, never `.shokunin/game-dev-3d/corpus/...`. So the prefix is a citation defect introduced in the r22 text, not a lost directory.

## 3. Before — commands exactly as cited (with `.shokunin/game-dev-3d/` root)

Run verbatim from the lane repo root. Every one fails on path resolution; **none of the failures is a fixture or logic failure**.

| # | Cited in | Command (verbatim) | Exit | stderr (verbatim, first line) |
|---|---|---|---|---|
| C1 | README:8, lesson:23 | `python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py` | **2** | `python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py': [Errno 2] No such file or directory` |
| C2 | README:9, lesson:25 | `python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject` | **2** | same `can't open file '.../.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py'` |
| C3 | lesson:29 (private-copy form) | `python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py /tmp/r22-unreal-review-y5dqvv0d/<name>.uplugin --expect-reject` | **2** | same `can't open file` for the checker path |
| C4 | lesson:42 | `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` | **2** | `python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py': [Errno 2] No such file or directory` |
| C5 | lesson:44 | `node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs` | **1** | `Error: Cannot find module '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs'` + `code: 'MODULE_NOT_FOUND'` (Node.js v26.12.0) |
| C6 | lesson:48 (inline) | `node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs` | **1** | `Error: Cannot find module '.../.shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs'` + `code: 'MODULE_NOT_FOUND'` |

`python3` resolves the missing file itself (exit 2 is CPython's "can't open file"); `node` reports `MODULE_NOT_FOUND` (exit 1). Both are pure path-resolution failures — the cited scripts exist and are executable at their `corpus/...` locations (§4).

## 4. After-equivalent — the same commands with the `corpus/...` root

Same shell, same repo root, only the `.shokunin/game-dev-3d/` prefix dropped:

| # | Command | Exit | stdout |
|---|---|---|---|
| C1' | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py` | **0** | `PASS local-static actual=accept expected=accept path=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/artifacts/unreal-r22/Headless3DFixture.uplugin reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)` |
| C2' | `python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject` | **0** | `PASS local-static actual=reject expected=reject path=corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin reason=unsupported module Type: 'Unknown'` |
| C4' | `python3 corpus/fixtures/run_battery.py` | **not observed** (see §5) | path resolves and the battery starts all 354 registered cases; full-run exit code was not captured — see §5 |
| C5' | `node corpus/fixtures/three/run_cases.mjs` | **0** | `PASS positive: exit=0 expected=0` / `PASS negative_wrong_order: exit=2 expected=2` / `PASS mutation: exit=1 expected=1` / `PASS three battery: 3/3, seeds_unchanged=true` |
| C6' | `node corpus/fixtures/three/scene_graph.mjs` | **0** | `PASS three3d scene_graph world=-1.000,0.000,0.000 parent_intact=true reverse_rejected=true` |

Artifact integrity checks (the cited files are real and byte-identical to their r22 commit):

```
$ sha256sum corpus/artifacts/unreal-r22/verify_descriptor.py
ce07e9d5c03e892b0d9847b89ec67cc6b293f0979d2f5be5a99c6a53b21cea76   # matches lesson:15 table
$ sha256sum corpus/artifacts/unreal-r22/Headless3DFixture.uplugin corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin
2543b337f6a63e8827b400939a85b3cc89c192345dcd63a37b96f25b4c89a0f9   # matches lesson:13
b56a356ef3c47a4880bd22f5dbcbb2ccf43e1cb65d263498674ef9b1c586ccf0   # matches lesson:14
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f   # ≠ lesson's cited a065a56d… (F3)
```

`verify_descriptor.py` and both `.uplugin` files match the r22 SHA table exactly, so the r22 static claims survive; only the root prefix is wrong.

## 5. Baseline-output drift seen while replaying (context, not this defect)

- `corpus/fixtures/run_battery.py` no longer emits the lesson's `29/29 PASS (14 ordinary, 15 negative)` line. `CASES` now holds 354 entries (the r96–r100 probe families are registered) and the script prints a `totals: cases=… pass=… fail=… ordinary=… negative_controls=… probes=…` line followed by `PASS battery: <run_dir>/verdicts.json` (or `FAIL battery:` when any case fails). So the cited `29/29` summary text is stale — **F3-class drift, not a path defect**. A targeted control proves the corpus-equivalent path resolves and the exit contract works: `python3 corpus/fixtures/run_battery.py --only navagent3d_retarget,navagent3d_retarget_fixed` → `totals: cases=2 pass=2 fail=0 ordinary=1 negative_controls=1 probes=0`, `PASS battery: corpus/live/runs/20261018T175051745977Z/verdicts.json`, **exit=0**.
- The Godot receipt the lesson cites, `corpus/live/runs/20261013T053632289732Z/verdicts.json`, is absent (F2 — captured separately in `reports/round-102/before/F2-verdicts-json.md`).
- Full-run outcome, observed mid-flight on two independent full serial runs left on disk by concurrent seats: both reached the `phys3d_*` / `bpy_*` families and both logged the same first failure — `FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']` (both at line 222). One of the two later also logged `FAIL r94_cannon_det`, `FAIL r94_cannon_det2`, `FAIL r94_cannon_varstep`, all `exit=0 expected=0 reasons=['exact stdout marker missing']`. Both logs were still being appended to when this seat stopped reading them, so their tallies are **not** final and are not this seat's evidence. All of this is **outside F1's scope** (none of it is a path-resolution failure); it is recorded only as host-contention context: at capture time the host ran 21 concurrent `run_battery.py` processes and 18 Godot processes (`nproc`=32, load average 12.65), and `phys3d_joints_free_ops` still hit its 20 s per-case budget when re-run alone under that load (`--only phys3d_joints_free_ops` → `totals: cases=1 pass=0 fail=1`, exit 1, three consecutive attempts). Whether these cases pass on an idle host is **not established by this seat** and must not be asserted either way. Other seats own them.
- Working-tree state at capture: `git status --porcelain` shows `M corpus/artifacts/unreal-r22/README.md`, `M corpus/lessons/r22-unreal-review.md` (plus `M corpus/knowledge/engines.md`, `M corpus/knowledge/rea.md`, `M corpus/knowledge/unreal-mcp/README.md`, `?? corpus/knowledge/unreal-mcp/gate/`, `?? corpus/lessons/r102-unreal-integration.md`, `?? reports/round-102/` — all other seats' work). The in-progress worktree edits to the r22 pair are mechanical prefix fixes (`git diff` shows `.shokunin/game-dev-3d/corpus/…` → `corpus/…`, 2 hunks README / 5 hunks lesson). **The before-evidence above is pinned to the HEAD blob**, whose README blob SHA is `26a126047b7fb7671f5216313ee8938a6076a4c3de5cfd06fb11b4338c751cba` (matches the lesson:16 table, 1460 bytes) and whose lesson blob SHA is `4253a0afe91d92a72d850816e7431fc579834be81187195a03ea5cacef6ed881`; the worktree README is now 1394 bytes / `1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b`.

## 6. Verdict

**F1 confirmed.** Exit-2/exit-1 path-resolution failures reproduce on all six cited command forms; the cited `.shokunin/game-dev-3d/` root is absent from the lane repo, absent from the parent repo, and never appears in either repository's git history. Dropping the prefix resolves every one of them — C1', C2', C5', C6' exit 0 with the expected `PASS` output, and C4' loads and begins executing the 354-case battery instead of failing to open the file. This is a mechanical path-conformance defect (in-place fix eligible under the correction-note discipline), not a claim about Unreal behavior; no Unreal runtime claim is made or implied here — the editor is not installed.
