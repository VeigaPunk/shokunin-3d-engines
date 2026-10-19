# r106 SEAT-72 — SEATS-LEDGER

Axes: coverage (owner/path boundary of the r106 protected set), calibration (worktree blob vs `HEAD` blob, plus sha256 cross-checks), depth (no battery, no gate re-run, no remote pin fetch — this seat does not validate runtime).

Question: did the r106 worktree touch a protected path outside the declared SEAT-17 doc exception? Answer for tracked bytes: **no**. 22,345/22,345 tracked protected blobs match `HEAD`, zero missing, zero non-ignored untracked additions. Answer for the protected prefix: **a side-effect leak is queued, not a seed edit** — 1,267 gitignored files under `corpus/fixtures/` have filesystem mtimes after the `HEAD` commit (1,264 `three/node_modules` files plus 3 `__pycache__` bytecode files). Named fixture sources, including `phys3d_joints.gd` and `run_battery.py`, still match `HEAD`.

This file is the seat's only write. No protected path was edited. No mechanical rewrite was landed: nothing in this seat's chunk was a broken citation, and deleting the ignored artifacts would itself be a write under `corpus/fixtures/`. Snapshot is not a lock — peers were still editing non-protected `corpus/knowledge/engines.md` and `corpus/lessons/*` while this was written. Rerun `git diff --name-only HEAD -- <protected specs>` and the hash walk after those seats finish for the close-time verdict.

## Protected set and method

`HEAD` under test: `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`git rev-parse HEAD`), commit time `2026-10-18 18:16:01 -0300` (`git log -1 --format=%ci HEAD`), subject `r105 report-last: … — work 3634bc0`. Work commit `3634bc0748f2ae1e02e20571874b39a3f3705daa` is the parent, not the tree under test. Branch at `2026-10-18T21:45:04Z`: `main`, upstream `origin/main`, `# branch.ab +10 -0`.

Protected specs checked: `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `SKILL.md`, `corpus/fixtures`, `corpus/knowledge/unreal-mcp/upstream`, `corpus/knowledge/unreal-mcp/.manifest.d`, `corpus/knowledge/unreal-mcp/gate`, `reports/round-101` through `reports/round-105`. Relative to the r105 ledger, this round adds `gate/` and `reports/round-105`. Declared exception, unused: SEAT-17 may sweep `corpus/fixtures/README.md` and `corpus/fixtures/PINNED-ENV.md` only. Both are byte-identical to `HEAD`, so the exception was not exercised.

Two walks, both zero diffs:

1. `2026-10-18T21:20:51Z` start, per-file `git hash-object -- <path>` vs `git rev-parse HEAD:<path>`, missing-file check included. Observed:

```text
ledger-roots: tracked=4 differ=0 missing=0
skill: tracked=1 differ=0 missing=0
fixtures: tracked=147 differ=0 missing=0
upstream: tracked=12 differ=0 missing=0
manifest: tracked=12 differ=0 missing=0
gate: tracked=2 differ=0 missing=0
reports-101: tracked=33 differ=0 missing=0
reports-102: tracked=61 differ=0 missing=0
reports-103: tracked=61 differ=0 missing=0
reports-104: tracked=21950 differ=0 missing=0
reports-105: tracked=62 differ=0 missing=0
total_tracked=22345 differences_or_missing=0
untracked_protected_additions=0
```

2. Confirming walk `2026-10-18T21:42:00Z`: `git ls-tree -r -z HEAD` blob ids vs one `git hash-object --stdin-paths` batch per spec. Same 22,345 tracked counts, `differences_or_missing=0`. `find -type l` over the protected trees printed nothing (`symlink_count 0`), so the hash-object comparison was not following links. `git diff --quiet HEAD -- <protected specs>` exited 0 at that same timestamp. `git ls-files -v` flagged skip-worktree/assume-unchanged count was 0 (rechecked `2026-10-18T21:45:04Z`).

`git diff --name-only HEAD -- <protected specs>` at `2026-10-18T21:44:02Z` and again at `2026-10-18T21:45:04Z` printed no paths (`protected_names_exit=0`). `git ls-files --others --exclude-standard` on the same specs printed 0 paths at `21:45:04Z`.

## Named files and root digests

At `2026-10-18T21:45:04Z`, `git hash-object` vs `git rev-parse HEAD:<path>` was `MATCH` for every named path below. Blob ids are from the `2026-10-18T21:23:41Z` read (content still matched at 21:45; the later command printed `MATCH`, not the ids again):

| path | HEAD blob | 21:45 |
| --- | --- | --- |
| `LOG.md` | `2c199c6ea630736d4a23753f5892a893e04e5909` | MATCH |
| `SCORECARD.md` | `658afba9a080cf2195b563dfbb9ccdfdfdedc455` | MATCH |
| `SHONEN.md` | `8d85902c19010deb4fa154e16a2c12ad56ff10d1` | MATCH |
| `PROVINCE.md` | `cde5e8f518bb05149ab62e4ea5aa44f547e8aa69` | MATCH |
| `SKILL.md` | `81970105e72856d7c17e83bf95820584883d52f2` | MATCH |
| `corpus/fixtures/phys3d_joints.gd` | `ab0363c7d278166542c40546e95c7d5e5e1114b0` | MATCH |
| `corpus/fixtures/run_battery.py` | `dd2d9b74448afddb88dcf2da56008302eba8060d` | MATCH |
| `corpus/fixtures/README.md` | `255e974746b4c1a16c3ca21fb745068690d8571d` | MATCH |
| `corpus/fixtures/PINNED-ENV.md` | `d46e31c40e0f36f0a238d30ab1261212f32bd94a` | MATCH |
| `corpus/knowledge/unreal-mcp/gate/README.md` | `e003b08813f8f2f40e5daa7fe669eec31021a1ed` | MATCH |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `1a3019f73e48c79cc6e3aad63f81742ed7a6223d` | MATCH |

`sha256sum` at `2026-10-18T21:45:04Z`:

```text
6f9d4c08a156acdf039f0a791504fd2ce155dc6fef57d57604aeae9f9d0a65c7  LOG.md
50adb78d5c41f9eeb3dbe0f839289a2851f4b6b76b06094d1120d6d1470463ce  SCORECARD.md
b44667ff4f0d4cfd8700eab2523b97ba3b254e440abde06d4214e9834d6a6062  SHONEN.md
1932f0fd7103dcc33e0b0c9f835adfe681e6ce4d765d4673bcc925c5d8230eac  PROVINCE.md
8ea7ae5c306913d44340454ca242579ff1f6c9ba29007efdb7943757bbf36371  SKILL.md
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

The runner digest matches the round's cited prefix `f456bd00…`. An earlier `sha256sum` of the five roots at `2026-10-18T21:21:39Z` equalled `git show HEAD:<file> | sha256sum` for each (all `MATCH`). `SKILL.md` is unchanged this round — unlike r105, there is no owner-exception delta on it.

`corpus/fixtures` at `HEAD` is 147 tracked paths (`git ls-tree -r --name-only HEAD -- corpus/fixtures | wc -l`). Extension census from that listing: 99 `gd`, 13 `mjs`, 10 `glb`, 6 `py`, 5 `gltf`, 3 `md`, 3 `json`, 3 `js`, and one each of `so`, `godot`, `GLB`, `gitignore`, `bin` (sum 147). The r105 ledger recorded 146 tracked fixture paths and an untracked `PINNED-ENV.md`. `git ls-files -- corpus/fixtures/PINNED-ENV.md` now prints that path, so the +1 is consistent with the r105 commit of that doc. This seat did not diff the two name lists, so that consistency is not an independent proof that `PINNED-ENV.md` is the only addition.

## Upstream pin — local bytes only

`corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` header (read, not rewritten) states pinned SHA `a6aa73ada02a9fb1f5415bec491f9942c519b297` and the verify command `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256`. Ran that command at `2026-10-18T21:42:00Z`: 12/12 `OK` (plugin.json, CODEOWNERS, .gitignore, hooks.json, unreal-context.sh, LICENSE, README.md, create-toolset/SKILL.md, operations.md, setup.md, unreal-mcp/SKILL.md, unreal-skill/SKILL.md). Seat manifests `seat01.sha256` through `seat11.sha256` were checked the same way at `2026-10-18T21:51:51Z`: every line `OK` (seat11 covers CODEOWNERS and `.gitignore`; the others are one file each). This does **not** re-fetch the upstream remote. It shows the worktree upstream tree still matches the committed manifests. No Unreal editor/runtime claim is made here.

## Worktree outside the protected set

Not a protected-path finding. Recorded so a later reader does not treat this ledger as "the whole worktree is clean."

- `2026-10-18T21:21:48Z`: `git diff --name-only HEAD` count 0; `git status --porcelain=v2 --branch` showed only `? reports/round-106/`.
- `2026-10-18T21:44:02Z`: `git diff --name-status HEAD` listed tracked modifications only under `corpus/knowledge/engines.md` and `corpus/lessons/` (32 paths by `2026-10-18T21:45:04Z`). Porcelain paths outside `reports/round-106/` were those same modifications. No staged paths (`git diff --cached --name-status` empty).
- Those paths are other seats' chunks. This seat did not read them for authorship and did not edit them.

## Queued judgment defect — JD-72-1

Gitignored code artifacts were written under `corpus/fixtures/` after `HEAD` (`git log -1 --format=%ct` = `1792358161` / `2026-10-18T21:16:01Z`). An mtime walk of the protected trees found 1,267 files newer than that commit, and nothing else: 1,264 under `corpus/fixtures/three/node_modules`, 3 under `corpus/fixtures/__pycache__`. Tracked seeds were not among them.

Dated observations, not a silent rewrite of any historical file:

- `2026-10-18T21:21:39Z` `stat` of `corpus/fixtures/__pycache__/run_battery.cpython-314.pyc`: mtime `2026-10-18 14:41:15.006253254 -0300`, size 351833. Source `corpus/fixtures/run_battery.py` mtime stayed `2026-10-16 05:56:29.388113651 -0300`.
- `2026-10-18T21:23:41Z` the same pyc mtime had moved to `2026-10-18 18:22:45.274771102 -0300`, size still 351833. Python header (flags 0) embedded mtime `1792140989` and size `346248`, both equal to the source. So the bytecode file was rewritten during this sweep; the source was not.
- By `2026-10-18T21:32:38Z`, two further pycs existed, absent from the `21:21` ignored sample: `bpy_battery.cpython-314.pyc` (mtime `2026-10-18T18:31:40.945984775-0300`, size 29325) and `bpy_sync_probe.cpython-314.pyc` (mtime `2026-10-18T18:31:40.951964354-0300`, size 92613). Headers checked at `21:42:00Z`: both timestamp-and-size consistent with their sources (`bpy_battery.py` size 36577, `bpy_sync_probe.py` size 63726). Still the only three pycs at `21:45:04Z`.
- `corpus/fixtures/three/node_modules`: 1,264 files, uniform mtime `2026-10-18T18:21:16-0300` (`21:21:16Z`, five minutes after `HEAD`). `node_modules/three/package.json` version `0.186.1`, matching tracked `corpus/fixtures/three/package.json` dependency `three: 0.186.1` and `package-lock.json` lockfileVersion 3. Identical mtimes mean a write-at-now (install or extract), not a read. This seat did not identify the process.

`git check-ignore -v` at `21:21:39Z`:

```text
corpus/fixtures/three/.gitignore:1:node_modules/    corpus/fixtures/three/node_modules/three/LICENSE
corpus/.gitignore:2:__pycache__/    corpus/fixtures/__pycache__/run_battery.cpython-314.pyc
```

`git status --short --ignored --untracked-files=all -- corpus/fixtures` at `21:45:04Z`: `1267 !!` and no other status class. They do not show up in `git status` without `--ignored`, which is why a porcelain-only sweep would miss them.

Classification: not a tracked-seed mutation, not the SEAT-17 README/PINNED-ENV exception, and not process-level authorship. It is a write of code artifacts inside a prefix the round marked protected. Queued for close. Not deleted here — deletion would be a protected-prefix write and can race a live importer. Close recommendation, not applied: importers should set `PYTHONDONTWRITEBYTECODE=1` (or cache outside the seed tree); `npm` materialization belongs in round scratch, not `corpus/fixtures/three/node_modules`.

## Fixes

None landed. Coverage of the tracked protected set is already clean, so a rewrite would not improve an axis. The ignored-artifact finding is a judgment defect, not a mechanical citation repair this seat can make without writing a protected path.

## Post-write confirm

`2026-10-18T21:58:32Z`: `git diff --name-only HEAD -- <protected specs>` printed 0 paths. `find corpus/fixtures -name '*.pyc' | wc -l` was 3. `git status --short --ignored --untracked-files=all -- corpus/fixtures` was still `1267 !!`. This seat's file was the untracked path `reports/round-106/seats-ledger.md`. Verdict unchanged from the 21:45 close.
