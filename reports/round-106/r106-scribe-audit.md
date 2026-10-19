# r106 scribe-audit — inventory and live frames

Seat: **SEAT-59 SCRIBE-AUDIT**. Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Scope: inventory `reports/round-106/` while it is still being written — file counts, naming, workstream shape, and a custody check that `reports/round-101/` through `reports/round-105/` and the other protected trees stayed byte-identical to HEAD. This seat wrote only this file. No git commit, push, checkout, or reset.

**Axes:** coverage (round-tree inventory), depth (naming and workstream shape), calibration (frame-bounded claims).

Lane HEAD throughout: `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`, r105 report-last; work `3634bc0`). `git rev-parse HEAD` at the open (`2026-10-18T18:20:18-03:00`) and again at `18:22:30-03:00`.

Tags: **[O]** command-run observation · **[I]** labelled inference.

**No Unreal runtime claim is made anywhere in this document.** `command -v UnrealEditor` and `command -v UnrealBuildTool` both printed not-in-PATH. The gate numbers below are the static gate's own stdout, not editor behavior.

**Status: AUDIT OF A MOVING TREE.** `reports/round-106/` went **941 → 2,419 files** in this seat's window (`2026-10-18T18:20:40-03:00` → `18:22:39-03:00`, about two minutes). No two size-trees matched. Every count below is a snapshot. This file is excluded from those snapshots because it is written after them.

## Headline

At the last pre-write count, `2026-10-18T18:22:39-03:00`, the directory held **2,419 files / 149,824,980 bytes**. Of those, the report set that is not inside a `scratch/` or `runs/` component was **10 Markdown files**. Zero top-level files use the `r106-` prefix (this audit is the first, and it lands after the count). The static gate receipt already on disk is `GATE RESULT: PASS` with `POINTERS=103` and `gate-run.rc` = `0`. That is presence of a receipt, not a content adjudication of C1–C3.

## 1. Frames

Sampler: walk `reports/round-106`, record relative path and byte size, SHA-256 the sorted `size<TAB>path` listing. Two frames five seconds apart, plus bookend counts.

```text
FRAME 2026-10-18T18:20:40-03:00  files=941    bytes=66,260,071   tree=1f28b6e532e96aa9285c609b04665b97a1a7f8b5452bec8a242122a9958da79e
FRAME 2026-10-18T18:20:52-03:00  files=993    bytes=66,447,351
FRAME 2026-10-18T18:21:19-03:00  files=1,073  bytes=67,044,324   tree_size=756d13943fad2dd57edb33c053d964749842acbcdedda5f89c24828bb221d68a
FRAME 2026-10-18T18:21:24-03:00  files=1,091  bytes=67,095,542   tree_size=81eb48a366f3c5e3f389f62fc5f7eb276a4eed52a9810c7f5d6bf8632347e76f
FRAME 2026-10-18T18:21:47-03:00  files=2,208  bytes=138,581,358
FRAME 2026-10-18T18:22:30-03:00  files=2,259  bytes=138,755,499  tree_size=0b66608e4d6496c2f89477eab2db467f2e92af67548c795730bfb4e8182700ba
FRAME 2026-10-18T18:22:39-03:00  files=2,419  bytes=149,824,980
```

The 18:21:19 and 18:21:24 size-trees differ (`STABLE_SIZE_TREE False`). The r103 index's "tree hash repeats" standard was not met. Do not quote a single file count as the round close.

Top-level composition at `18:22:30` (2,259 files): `scratch` 1,579, `census` 468, `n24` 134, `gate` 59, `glb-unity` 7, `battery-default-quick-receipts` 7, plus five root files. Paths with a `scratch` or `runs` component: **2,228 files / 138,610,268 bytes**. Paths with neither: **31 files / 145,231 bytes**. **[O]**

## 2. Protected custody

Hash walk at `2026-10-18T18:21:47-03:00`: `git ls-tree -r -z HEAD` against the worktree via `git hash-object` / `git rev-parse HEAD:<path>`.

```text
ledger:   tracked=5     differ=0 missing=0     # LOG SCORECARD SHONEN PROVINCE SKILL
fixtures: tracked=147   differ=0 missing=0
upstream: tracked=12    differ=0 missing=0
manifest: tracked=12    differ=0 missing=0
gate:     tracked=2     differ=0 missing=0
r101:     tracked=33    differ=0 missing=0
r102:     tracked=61    differ=0 missing=0
r103:     tracked=61    differ=0 missing=0
r104:     tracked=21950 differ=0 missing=0
r105:     tracked=62    differ=0 missing=0
total_diffs 0
untracked_protected 0
```

Re-checked at `18:22:30-03:00`: `git status --porcelain` on `reports/round-101` … `reports/round-105` printed nothing (count 0). The five ledger files each compared `git hash-object` = `HEAD:<file>` and printed `IDENTICAL`. `sha256sum corpus/fixtures/run_battery.py` printed `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, matching the round pin; `git hash-object` equals `HEAD:corpus/fixtures/run_battery.py` (`dd2d9b74448afddb88dcf2da56008302eba8060d`). `git status --porcelain -- corpus/fixtures` was empty. **[O]**

`corpus/knowledge/unreal-mcp/upstream/` is a vendored tree inside the lane repo, not its own git checkout (`NO_DOTGIT`; `git -C` that path resolves to the lane toplevel and therefore prints lane HEAD `0cc3f41`, which is **not** the upstream pin). The pin lives in the gate script: `sed -n '73p' corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297`. Gate script SHA-256: `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`. Upstream tracked count 12, porcelain 0. **[O]**

`git status --porcelain --untracked-files=normal` outside `reports/round-106/` was empty at `18:22:30`. `git check-ignore -v reports/round-106/gate/final-run.md` exited 1 (not ignored), so the round tree is tracked-visible for a later close commit. This seat did not stage it. **[O]**

Host scratch outside the repo, observed `ls -ld /home/vgpnk/r106*` at `18:22:30`: `r106-s01`, `r106-scratch`, `r106-seat53`, `r106-seat60`, `r106-seat72`, `r106-seat73`. `du -sh` a minute earlier: seat53 4.0K, seat72 0, seat73 280K. Recorded, not adjudicated. `/tmp` was `tmpfs 16G 13G 3.1G 80%` with 675,867 of 1,048,576 inodes used; this seat wrote no scratch there. **[O]**

## 3. Naming

At `18:22:39` the top-level files were:

```text
battery-default-quick.md
engine-count.md
glb-unity-regression.md
r105-receipt-carry.md
r22-regression.md
```

`r106-*` count among them: **0**. The standing lane form for round-close artifacts is `rNN-*.md` (r105's root set included `r105-connector.md`, `r105-distiller.md`, `r105-report.md`, `r105-verification-protocol.md`). Those close seats had not landed in this window. `r105-receipt-carry.md` and `r22-regression.md` are subject names that happen to contain another round number; they are not the `r106-` form. **[O]** / **[I]**

Top-level directories at `18:22:39`: `battery-default-quick-receipts`, `census`, `consistency`, `gate`, `glb-unity`, `jolt`, `n24`, `scratch`, `sweep`. Empty at that frame: `consistency`, `jolt`, `sweep`. Max relative file depth: **9** (r105's scribe tree was shallow; r104 reached 13 because of vendored clones). **[O]**

Report Markdown outside any `scratch` or `runs` path, hashed at `18:22:30` (UTF-8, zero NULs):

| path | bytes | sha256 | seat marker |
|---|---:|---|---|
| `battery-default-quick.md` | 7065 | `986fcf69348f047094fd564e5a124265fa2fd3e5023ded7235fd1f9536831907` | SEAT-87, SEAT-88 |
| `census/cannon.md` | 4252 | `9ffc1e9181b107c4c23ec173d61ecb0e9aa10982bb2f79ae6870dc95dd479cc3` | SEAT-28 |
| `census/phys3d-joints.md` | 6074 | `a0d1ac95ac30ddc0aa668cfb10af7fadf345d1809cafb9ed357e0635a2caeb96` | SEAT-33 |
| `census/three-default.md` | 7037 | `d91400b3821c26549f8c4045ef7f50c12da111af01ecf728d6c685737b4c22c0` | SEAT-26 |
| `engine-count.md` | 10638 | `0f7c73300c8a00b6bcd8a87e71c9f973502d286d1d42e8828e650b36318ae3d1` | SEAT-27, SEAT-38, SEAT-98 |
| `gate/blocked-check.md` | 10108 | `5c632d05c661baa11869a437ea74f0233999324b6103c86cd9d943047ba376fb` | SEAT-110, SEAT-70 |
| `gate/final-run.md` | 4488 | `fcaaa7b3a033d4fabe3983e4e91c946e0229e0fe0ceebe4dbe22c5f2580e8152` | SEAT-70 |
| `glb-unity-regression.md` | 5790 | `d968b645f13c1198b01e3be811b315f5b0e01ab6314be90534c206d350fb29da` | SEAT-94 |
| `r105-receipt-carry.md` | 6698 | `71c99812c825e685bdf3f78bfed40a00d58c67b33327fd885a988f0af96a1df5` | SEAT-113 |
| `r22-regression.md` | 6684 | `f7352f0e906944152a985740eaef9cd29da7157e19e967b34ebef44725451ee5` | SEAT-93 |

Every one of those ten carries a `SEAT-NN` marker. A UTF-8/NUL scan of the 12 Markdown files present at `18:20:52` printed `readability_issues 0`; the ten above were re-decoded at `18:22:30` with the same result. **[O]**

Intra-tree basename collisions at `18:22:30`: **153** duplicate names, led by `child.log` ×171 and `project.godot` ×168. Those are per-scenario battery stubs copied into run scratch, the same class r104 recorded, not report-name reuse. **[O]** / **[I]**

`scratch/` had **89** immediate entries at `18:22:30` (seat-numbered directories plus loose tsv/txt/json). Naming encodes who ran the job (`seat45-cites.tsv`, `seat88-pinned-quick-…`) more often than a fixed role vocabulary. `gate/` is the one name carried from r102–r105. **[O]** / **[I]**

No path outside `reports/round-106/` cited `reports/round-106` (`rg -l`, excluding this tree and `.git`): **none**. **[O]**

## 4. Receipts present — not adjudicated

Read, not re-run. These are inventory facts about files that existed in the window. They do not settle C1, C2, or C3.

- `reports/round-106/gate/scratch/gate-run.stdout` ends `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`, `STEP=PASS`, `GATE RESULT: PASS (checks failed: 0)`. `gate-run.rc` is the single byte `0` plus newline. The same stdout prints `PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297` and `LANE_HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd`. `gate/final-run.md` (SEAT-70) records that invocation. `gate/blocked-check.md` (SEAT-110) records two negative paths (dead `REPO` → RC 2 BLOCKED; bad `GATE_REF` → RC 1 FAIL) and points at `gate/scratch/a4-dead-repo.*` and `bad-gate-ref.*`, which were present at `18:22:39`. **[O]**
- `n24/runs/seat88-pinned-quick-20261018T212035Z.verdicts.json` parsed as `verdict=PASS`, `totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}`, `seeds_unchanged=True`. The matching stdout says the row is `r94_cannon_nan` and the receipt path printed by the runner is `/home/vgpnk/r106-seat88-TxEMRh/20261018T212035115165Z/verdicts.json`, not the copy under `reports/round-106/`. One row, not 350. **[O]**
- `glb-unity/glb-r12-20261018T212038Z.exit` is `GLB_EXIT=0`; stdout is one PASS line for the Godot GLB import. `unity-r19-20261018T212038Z.exit` is `UNITY_EXIT=0`; stdout is one `PASS local-static` line. Both stderr files are 0 bytes (`e3b0c442…`, the empty SHA-256). `glb-unity/.stamp` is `STAMP=20261018T212038Z`. **[O]**
- `census/.stamp` is `STAMP=20261018T212022Z`. `census/three-default.md` claims 3/3 and 5/5 under mise Node v26.12.0. This seat's own probes: `node --version` → `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`; the fnm pin binary `--version` → `v24.21.0`. **[O]**
- `census/phys3d-events-inactive-space-20261018T212230Z.stdout` is one line: `/bin/bash: line 13: /usr/bin/time: No such file or directory`. That is a failed wrapper, not a physics verdict. A sibling meta file sits beside it. **[O]**

Executable bits at `18:21:04`: 20 files, all either `pybullet…so` copies inside run scratch or `*.sample` hooks inside `scratch/seat71/pin-clone/.git/hooks/`. No seat-authored `*.sh` in the round tree at that frame. A `pin-clone` with a `.git` inside `reports/round-106/scratch/` is the same containment class r104 warned about; this seat did not hash it against the lane. **[O]**

## 5. What this seat did not do

- Did not modify, stage, commit, or delete any path except this audit.
- Did not verify citation-sweep fixes, engines.md census rows, or lesson digest consistency. Those are other seats. Section 4 records receipts that were already on disk.
- Did not obtain a settled frame. Re-run the commands in section 6 before quoting a file count.
- Did not claim Unreal Editor or UnrealBuildTool behavior. Neither binary is on PATH.

## 6. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git rev-parse HEAD                                          # 0cc3f4162f8c319f8d01a69a174fe939f36701bd
git status --porcelain -- reports/round-101 reports/round-102 reports/round-103 reports/round-104 reports/round-105
sha256sum corpus/fixtures/run_battery.py                    # f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
sed -n '73p' corpus/knowledge/unreal-mcp/gate/run_gate.sh   # PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
find reports/round-106 -type f | wc -l                      # moving; 2419 at 18:22:39
find reports/round-106 -maxdepth 1 -type f -name 'r106-*'
tail -5 reports/round-106/gate/scratch/gate-run.stdout      # POINTERS=103 … GATE RESULT: PASS
cat reports/round-106/gate/scratch/gate-run.rc              # 0
```

The file count will not reproduce. The custody result (prior rounds and pins identical to HEAD) is the part that held at every sample in this window.

## 7. Post-write frame — dated correction, not a replacement

Measured after this file existed, `2026-10-18T18:27:09-03:00`: `find`-equivalent walk printed **7,160 files / 238,896,673 bytes**. The only `r106-*` file was this audit (12,869 bytes at that instant). Root files were the five named in section 3 plus `r106-scribe-audit.md`. `git status --porcelain` on `reports/round-101` … `reports/round-105` was still empty (count 0).

The worktree outside this round was no longer empty. `git status --porcelain --untracked-files=normal` showed modifications under `corpus/lessons/` (first lines: `r61-stream-review.md` through `r68-ray-layers-review.md`, and the listing was truncated). Those paths are not in this seat's protected set and were not written by this seat. The section 2 claim "outside `reports/round-106/` was empty" is true only for the `18:22:30` frame. **[O]**
