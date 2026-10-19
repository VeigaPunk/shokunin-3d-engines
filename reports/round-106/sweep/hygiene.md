# r106 SEAT-120 — Sweep hygiene

**Seat:** SEAT-120 SWEEP-HYGIENE. Owned path: this file only. No git commit, push, checkout, or reset. No protected path written. One accidental scratch file this seat created under `reports/round-106/scratch/seat120-tmp-window.txt` was removed in the same turn (`rm` exit 0; later `ls` of that path: no such file).

**Axes:** coverage (repo-root and `corpus/fixtures` listings), depth (what each extra directory is, and whether `/tmp` leftovers are this sweep), calibration (timestamped counts; no cleanup claimed that was not run).

**HEAD at every frame below:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Local offset is `-0300`. Sweep-start marker used below: `reports/round-106` directory birth `2026-10-18 18:19` local (`ls -ld` on the first root listing). This is a live snapshot while other seats are still writing, not a close-time lock.

## Verdict

**PASS on the declared locations.** No stray scratch directory in the repo root or in `corpus/fixtures` from this sweep.

**`/tmp` was not cleaned.** That is a prior-round leftover plus other lanes still writing during this window. It is not an r106 leak into this repo. Not deleted here: the files are cross-lane and some are live. Queued, not fixed.

**Host note “/tmp per-user quota is exhausted” was not reproduced.** A 1-byte write to `/tmp` succeeded and was removed. `df` showed 3.1G free (80% used) and 65% inodes used. `quota` is not installed, so a hidden user quota was not measured.

## 1. Repo root — no stray scratch

Command, `2026-10-18T21:37:32Z`: `ls -A1 | grep -vE '^(corpus|reports|\.git|README\.md|LOG\.md|SCORECARD\.md|SHONEN\.md|PROVINCE\.md|SKILL\.md)$' || echo ROOT_UNEXPECTED_NONE`

Observed: `ROOT_UNEXPECTED_NONE`.

Same shape at `2026-10-18T21:21:16Z` and `2026-10-18T21:31:52Z`: root entries were only `corpus`, `.git`, `LOG.md`, `PROVINCE.md`, `README.md`, `reports`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`. No `scratch`, `tmp`, core, or editor-swap name at depth 1. The only root paths newer than `18:19` local at `21:26:25Z` were `./.git` and `./reports`.

## 2. `corpus/fixtures` — no stray scratch dir

Command, `2026-10-18T21:37:32Z`: `find corpus/fixtures -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort`

Observed:

```text
__pycache__
r94vendor
r95vendor
r98assets
three
```

Name scan at `2026-10-18T21:31:52Z` (`find corpus/fixtures -maxdepth 1` for `*scratch*`, `*tmp*`, `*.log`, `*.swp`, `*~`, `core`, `.DS_Store`) printed nothing.

`git status --porcelain=v1 -- corpus/fixtures` at `2026-10-18T21:35:52Z`: empty. `git ls-files --others --exclude-standard -- corpus/fixtures`: empty. Ignored-only extras (`git status --porcelain=v1 --ignored -- corpus/fixtures` at `21:31:52Z`): `!! corpus/fixtures/__pycache__/` and `!! corpus/fixtures/three/node_modules/`. `git check-ignore -v` attributes `__pycache__` to `corpus/.gitignore:2`. `three/node_modules` is the existing vendored tree, not a sweep drop.

`__pycache__` is gitignored bytecode, not a scratch directory. It was refreshed during the window (import side effect). At `2026-10-18T21:37:32Z`:

```text
2026-10-18T18:22:45 351833 run_battery.cpython-314.pyc
2026-10-18T18:31:40  29325 bpy_battery.cpython-314.pyc
2026-10-18T18:31:40  92613 bpy_sync_probe.cpython-314.pyc
```

Earlier frame `2026-10-18T21:22:22Z` had only `run_battery.cpython-314.pyc` dated `14:41:15` local. The two `bpy_*.pyc` files appeared by `18:31:40` local. Left in place: deleting them races a live importer and they are not scratch dirs. No fixture source path was newer than `18:19` local once `node_modules` and `__pycache__` are excluded (`find` at `21:26:25Z` printed nothing).

## 3. `/tmp` sample — not cleaned; not this lane’s r106 scratch

Depth-1 census, command at `2026-10-18T21:31:52Z`:

| check | observed |
| --- | --- |
| `find /tmp -maxdepth 1 -mindepth 1 \| wc -l` | 8369 |
| same, `-user vgpnk` | 8357 |
| vgpnk and `-newermt '2026-10-18 00:00:00'` | 6496 |
| name match `*r106*`, `*round-106*`, `*round106*`, `*game-dev-3d*` | 0 |
| vgpnk and `-newermt '2026-10-18 18:19:00'` | 4 |

That window count is not stable. Re-list at `2026-10-18T21:37:32Z` was **28** entries, and the r106-name count was still **0**. The 24 additions after the first window sample are other lanes, sampled by reading heads:

- `/tmp/s23-sample-paths.txt` and `/tmp/s17-dryrun-96.tsv` name `/home/vgpnk/Projects/shokunin/.ufo/...`, not this repo.
- `/tmp/s19-lane-before.txt` is a `git status` of `results/crun-*` / kotodama paths.
- `/tmp/s24-tool-verdicts.json` (in the first window of 4) names audio-publish and `.ufo` paths.
- `/tmp/tracked-tools.txt` and `/tmp/disk-tools.txt` are `tools/impl-*.sh` lists.
- `/tmp/hsperfdata_vgpnk` is a JVM directory.

Newest `/tmp/seat*` mtime at `2026-10-18T21:35:52Z`: `seat37-full2.out` at `2026-10-18T16:35:11-0300`, before the sweep marker. This sweep has not added `seat*`-named `/tmp` files.

Overlapping name classes for vgpnk `/tmp` entries with mtime today, `2026-10-18T21:35:52Z` (a name can hit more than one class; `unclassified` is the residual): `today_vgpnk_depth1=6510 seatish=221 r106=0 r105=2 r104=25 scratch=39 sweep=10 kimi=21 shokunin=9 unclassified=6195`. The r104/r105/seatish hits are leftovers, not this sweep.

`df -h /tmp` at `21:31:52Z`: `tmpfs 16G 13G 3.1G 80%`. `df -i /tmp`: `1048576` inodes, `675886` used, `65%`. `quota` → `command not found`. Probe: `printf x > /tmp/seat120-quota-probe-$$` printed `WRITE_OK`, then `rm` and `probe_gone`.

## 4. Where this sweep’s scratch actually is

Outside the declared locations, so not a fail, and not deleted (other seats, still live). Sample at `2026-10-18T21:31:52Z`, `find /home/vgpnk -maxdepth 1 -name 'r106*'`:

```text
r106-seat72   d 0
r106-seat73   d 26
r106-scratch  d 0
r106-s01      d 0
r106-seat60   d 42
r106-seat53   d 292
```

`reports/round-106/scratch` is the in-repo designated scratch tree (86 depth-1 entries at `21:22:22Z`). That is the host-note location, not a root or fixtures leak.

Adjacent, out of this seat’s locations: `corpus/.gitignore` line 1 ignores `live/`. `find` at `2026-10-18T21:24:14Z` showed harness `scratch/` copies under `corpus/live/runs/`, including two inside the r106 UTC window: `corpus/live/runs/20261018T212035261095Z/scratch` and `corpus/live/runs/20261018T212237117242Z/scratch` (fixture-script copies, not new dirs in `corpus/fixtures` or the repo root). Not moved or deleted.

## 5. Queued, not fixed

- **Judgment defect, not a mechanical citation fix:** historical `/tmp` scratch (6496–6510 vgpnk entries dated today; 221 `seat*`-ish; 25 `r104`; 2 `r105`; 0 `r106`) was not cleaned by this sweep’s seats. Deleting it from this seat would destroy other lanes’ live files (`s10`/`s13`/`s17`/`s19`–`s24` writes landed during this check). Needs an owner who can tell live files from leftovers.
- No dated correction note inside `corpus/fixtures` or the repo root: there was no stray scratch path to rewrite.

## Limits

Rerun the root `ls -A1` and the fixtures `find -type d` after peer work stops. The `/tmp` window count moved from 4 to 28 in about six minutes; only the r106-name count (0) and the root/fixtures listings were stable across frames.
