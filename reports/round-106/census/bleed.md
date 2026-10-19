# SEAT-104 CENSUS-BLEED — r106

Axes: coverage (census writes vs the allowed set), depth (the landed `engines.md` diff, not a status glance), calibration (state cells vs the prose that moved).

**Seat:** SEAT-104. **Owned write:** this file only. No `engines.md` byte, no lesson, no fixture, no ledger, no other seat report. **HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. **Close:** `2026-10-18T21:57:28Z`. No commit.

**No Unreal runtime claim.** The census edit and this verdict both keep Unreal at installed `no` / executable-headless `no`. Editor not installed.

## Verdict

**PASS.** Census corpus edits stayed inside `corpus/knowledge/engines.md`. Other census byte products are receipts or declared census reports, not source edits.

Predicate: a census edit is a tracked change, or an untracked write outside `reports/round-106/`, made by a census seat (SEAT-25..40) in service of the C2 refresh. Allowed: `engines.md` (SEAT-38 only) plus receipts (`reports/round-106/census/**`, runner `--runs` dirs, including the gitignored default `corpus/live/runs/`). Declared probe reports `reports/round-106/census/*.md` are seat outputs, not corpus edits. Operational scratch under `reports/round-106/scratch/` or `~/` is not a corpus edit (host note). Bleed would be any census-attributable write outside that set.

| check | result |
|---|---|
| tracked files other than `engines.md` that are census edits | **0** |
| `engines.md` vs HEAD | **1 file, +110/−4**, blob `5eef89d4` → `645c929d` |
| executable-headless cells moved | **0 / 4** |
| fixture / artifact / ledger / `reports/round-101..105` / `unreal-mcp` dirty | **0** |
| untracked path outside `reports/round-106/` | **0** |
| lesson diff census tokens | **0** in 40 lesson files |

## Evidence

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:55:15Z
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ sha256sum corpus/knowledge/engines.md
149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba  corpus/knowledge/engines.md
$ git hash-object corpus/knowledge/engines.md
645c929d8d69343f98646151b3ea6147bfbabb86
$ git rev-parse HEAD:corpus/knowledge/engines.md
5eef89d484b60e26ab78c29dd86a64781b0df86f
$ git diff --numstat HEAD -- corpus/knowledge/engines.md
110	4	corpus/knowledge/engines.md
$ git status --porcelain -- corpus/knowledge corpus/fixtures corpus/artifacts \
    LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md \
    reports/round-101 reports/round-102 reports/round-103 reports/round-104 reports/round-105 \
    corpus/knowledge/unreal-mcp
 M corpus/knowledge/engines.md
$ git status --porcelain --untracked-files=all | awk '$1=="??"{print}' | grep -v 'reports/round-106/' || true
(empty, rc 0)
$ sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  corpus/fixtures/phys3d_joints.gd
```

State cells, HEAD table row vs worktree, same command at `21:55:15Z`:

| row | HEAD installed / headless | now | headless same |
|---|---|---|---|
| Godot 4.7.2 | `yes (`/usr/bin/godot`)` / `yes` | same | yes |
| Unity Editor | `no` / `no` | same | yes |
| Unreal Engine | `no` / `no` | same | yes |
| three.js 0.186.1 | pin sentence included `(Node v26.11.1)` / `partial — Object3D … no GL context` | pin sentence points at the two-state table; `v26.11.1` kept as a dated note / **partial unchanged** | yes |

The three.js *installed* prose changed. That change is inside `engines.md`, carries `Correction note (r106, 2026-10-18) — Node v26.11.1`, and does not move executable-headless off `partial`. Not a bleed. Not a promotion.

Reconfirm at close, after `area3d.md` had appeared:

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:57:28Z
$ sha256sum corpus/knowledge/engines.md
149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba  corpus/knowledge/engines.md
$ git diff --name-only HEAD | wc -l ; git diff --name-only HEAD -- corpus/lessons | wc -l
41
40
```

The 41st name is `corpus/knowledge/engines.md`. The other 40 are `corpus/lessons/*`. `git diff HEAD -- corpus/lessons` has **0** matches for `census`, `engines.md`, `SEAT-25`..`SEAT-40`, or `CENSUS`. Added `reports/round-106/` pointers in that diff cite `reports/round-106/sweep/` (8 lines). Those are sweep/consistency edits (path-root notes, environment pairing). Out of this seat's bleed set.

## Where census bytes went

In-bounds receipts and reports observed this seat (existence checked `21:55:15Z` unless noted):

- `reports/round-106/census/*.md` — probe reports. At `21:57:28Z`: `animtree.md`, `area3d.md`, `bpy.md`, `bullet.md`, `cannon.md`, `gltf.md`, `n24-state.md`, `navagent.md`, `phys3d-events.md`, `phys3d-joints.md`, `three-default.md`, `three-pinned.md`, `verify.md`. `godot.md` and `adversary.md` were not on disk yet.
- Durable probe receipts under `reports/round-106/census/` (verdicts, logs, three.js json, `bpy/`). `bpy/census_probe.py` is a probe script in the census report dir, not a fixture edit.
- SEAT-38 Godot receipt: `reports/round-106/scratch/seat38/20261018T213322137930Z/verdicts.json` (22031 bytes). `only=phys3d_joints_free_ops`, totals pass=1, `seeds_unchanged=true`. Scratch, not a source edit. `engines.md` cites it.
- SEAT-25 default-sink receipt: `corpus/live/runs/20261018T212035261095Z/verdicts.json`, named in `reports/round-106/scratch/seat25-r100_fpslat_cls.stdout` (`PASS battery: …/corpus/live/runs/20261018T212035261095Z/verdicts.json`). Parsed: `only=r100_fpslat_cls`, pass=1, `seeds_unchanged=true`. That path is the runner default (`run_battery.py` `--runs` default `corpus/live/runs`). It is a receipt. It is gitignored (`corpus/.gitignore` line 1 is `live/`). Durability copy is SEAT-107's job, not a source bleed.
- Other `corpus/live/runs/` dirs since `18:19` local are not census: `camera3d_depth` (`20261018T212237117242Z`) is named by `reports/round-106/scratch/seat05/battery-only.out`; `floor3d_ground` and one `r12-import` by SEAT-13; the earlier `r12-import-20261018T212038049374Z` by `reports/round-106/glb-unity-regression.md`.
- `~/scratch-r106-seat38/` exists (gate workdir, host probes, a copy of the gate stdout). Outside the repo. `git status` on `corpus/knowledge/unreal-mcp` was empty, so that gate run did not dirty the protected tree.

Cited receipt paths in the `engines.md` diff all existed at `21:55:15Z`, including both full-battery verdict files, the five census reports that write names, and `reports/round-106/gate/scratch/gate-run.stdout` (2137 bytes; the edit says this seat hash-checked it and did not launch it).

`corpus/fixtures/__pycache__/*.pyc` was newer than `18:19` local and is gitignored (`corpus/.gitignore:2:__pycache__/`). Interpreter side effect of importing the runner, not an authored census edit. The `.py` sources are unchanged vs HEAD.

## Not bleed, still owed

- **Read-set gap.** `engines.md` says that at its gate re-run (`2026-10-18T21:38:07Z`) the census markdown set was exactly `cannon.md`, `three-default.md`, `phys3d-joints.md`, `n24-state.md`, `verify.md`. By `21:57:28Z` eight more census reports were on disk (`animtree`, `area3d`, `bpy`, `bullet`, `gltf`, `navagent`, `phys3d-events`, `three-pinned`). They did not cause a second corpus write. Fold should not treat the `engines.md` "read set" as the full r106 census. This seat does not own `engines.md` and did not patch it.
- **SKILL stamp.** The edit queues, and does not apply, the fact that protected `SKILL.md` still stamps the pre-r106 sha `d03907d3…`. Porcelain on `SKILL.md` was empty. Correct non-edit.
- **No cannon-es row.** Queued inside `engines.md`, not added. No extra knowledge file.

Point-in-time: a census seat can still write after `21:57:28Z`. At that instant the containment check above was green.
