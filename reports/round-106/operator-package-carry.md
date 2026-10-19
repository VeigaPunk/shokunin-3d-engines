# SEAT-92 — operator-package carry

Axes: coverage (package bytes and cited paths untouched), depth (live two-state re-run, not only the r105 receipts), calibration (snapshot sentences dated, not rewritten).

Scope: re-verify `reports/round-105/operator-package.md` and the files its three sections cite. This seat wrote only this file. No protected path was edited. No Unreal runtime claim is made. Check window: `2026-10-18T21:37:03Z` through the post-run diff after `2026-10-18T21:50:59Z`. HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`.

Verdict: **untouched, and the durable claims still hold.** Two sentences inside the package are assembly-time snapshots. Read as a current operator brief they understate later r105 evidence. They are queued here. They are not sweep damage, and they are not silently rewritten.

## Untouched

Primary artifact: `reports/round-105/operator-package.md`.

```text
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ git hash-object -- reports/round-105/operator-package.md
d0a6691c3a81bef2654f4d61207db585cafb8790
$ git rev-parse HEAD:reports/round-105/operator-package.md
d0a6691c3a81bef2654f4d61207db585cafb8790
$ git rev-parse 3634bc0:reports/round-105/operator-package.md
d0a6691c3a81bef2654f4d61207db585cafb8790
$ sha256sum reports/round-105/operator-package.md
83124766c85c14c381cb8c41c50fe5c15ce2ea2dfed37658e642c1e97a967d3a
$ wc -c reports/round-105/operator-package.md
5026
$ git diff --quiet HEAD -- reports/round-105/operator-package.md; echo package_diff_rc=$?
package_diff_rc=0
```

That SHA-256 and byte count match the r105 index row for this file (`reports/round-105/reports-index.md`). The same blob is in work commit `3634bc0` and in report-last HEAD.

Cited set also matched HEAD: `reports/round-105/operator-package.md`, `reports/round-105/pc/`, `reports/round-105/n24/`, and `reports/round-101/r101-report.md`. `git ls-tree -r` plus `git hash-object` vs `git rev-parse HEAD:<path>` → `tracked 28 differ 0`. After the live cannon re-run, `git diff --quiet HEAD` on the package, `corpus/knowledge/unreal-mcp/README.md`, `corpus/knowledge/unreal-mcp/executability`, `reports/round-101/r101-report.md`, `corpus/fixtures/run_battery.py`, and `corpus/fixtures/PINNED-ENV.md` returned `post_run_cited_diff_rc=0`.

## P/C — still the unapplied 12/1/0 frame

Re-probed, not copied from the package:

```text
$ sha256sum corpus/knowledge/unreal-mcp/README.md
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721
$ git diff --quiet HEAD -- corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability; echo pc_source_tracked_diff_rc=$?
pc_source_tracked_diff_rc=0
```

Card scan (`executability/*.md`, first `verified-here|static-only|unproven-runtime`, dissent = files containing ``Not `unproven-runtime` ``): `cards 13`, `label_census {'unproven-runtime': 1, 'static-only': 12}`, `dissent 6` (`animation-controlrig.md`, `blueprints.md`, `editor-general.md`, `gameplay-gas.md`, `materials.md`, `meshes-textures.md`), sole `unproven-runtime` card `actors-scene.md`. `test -e corpus/knowledge/unreal-mcp/label-precedence.md` → `label_precedence_exists_rc=1`. No relabel landed.

Dated note, 2026-10-18, not a rewrite: the package says “at this package check … `pc_reviews=0` … not ready to apply.” That zero was true of the check that wrote the file. It is not the closed tree. Same HEAD now has three review files:

- `reports/round-105/pc/review-1.md` — `**REVISE` (line 9)
- `reports/round-105/pc/review-2.md` — `**Verdict: REVISE.`
- `reports/round-105/pc/review-3.md` — `**REVISE`

Current `sha256sum reports/round-105/pc/distiller.md` is `8e714525fa02b65e111e3e24809817eeea1a2f531ca155aa844923c24669c797`. None of the three reviews contain that digest. All three contain the current ruling digest `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30`. The “not applied” conclusion still holds, for a stronger reason than zero reviews: three REVISE reviews, no shared review of the HEAD distiller, no `label-precedence.md`, census still 12/1/0. An operator who reads only the package will miss the reviews. Queue: do not patch `reports/round-105/operator-package.md`; this note is the correction.

## Two-state — selectors and the 13-case split still hold

Package selectors, re-run at `2026-10-18T21:50:34Z`:

```text
default_node v26.12.0 /home/vgpnk/.local/share/mise/installs/node/latest/bin/node
pinned_node v24.21.0 /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

`test -x` on the fnm binary returned `fnm_node_x_rc=0`. `sha256sum corpus/fixtures/run_battery.py` is still `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `corpus/fixtures/PINNED-ENV.md` is tracked. `git diff --quiet HEAD` on it, `corpus/fixtures/README.md`, and `run_battery.py` returned `fixture_docs_and_runner_diff_rc=0`. `git status --short -- corpus/fixtures` was empty. The package’s assembly-time “only `?? corpus/fixtures/PINNED-ENV.md`” line is historical; the file is committed and clean.

Live re-run of the package’s 13 positive cannon cases (scratch, not `/tmp`):

```sh
CASES='r94_cannon_det,r94_cannon_det2,r94_cannon_varstep,r94_cannon_bailout,r94_cannon_nan,r94_cannon_sync,r94_cannon_material,r94_cannon_friction,r94_cannon_parity,r94_cannon_parity2,r94_cannon_modes,r94_cannon_order,r94_cannon_backends'
python3 corpus/fixtures/run_battery.py --only "$CASES" --runs reports/round-106/scratch/seat92/default-runs
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py --only "$CASES" --runs reports/round-106/scratch/seat92/v24-runs
```

Observed (`reports/round-106/scratch/seat92/twostate-rerun.txt`, ended `2026-10-18T21:50:59Z`):

- Default: `totals: cases=13 pass=0 fail=13`, `default_rc=1`, receipt `reports/round-106/scratch/seat92/default-runs/20261018T215034452687Z/verdicts.json`. Parsed: `verdict FAIL`, `seeds_unchanged True`, all 13 reasons `exact stdout marker missing`, node token `v26.12.0`.
- Pinned: `totals: cases=13 pass=13 fail=0`, `pinned_rc=0`, receipt `reports/round-106/scratch/seat92/v24-runs/20261018T215046718436Z/verdicts.json`. Parsed: `verdict PASS`, `seeds_unchanged True`, node token `v24.21.0`.

The package’s cited durable default receipt still parses the same way: `corpus/live/runs/20261018T201215739340Z/verdicts.json` → `pass=337 fail=13`, `seeds_unchanged True`, 13 positive cannon fails, node `v26.12.0`, reason `exact stdout marker missing`.

Dated note, 2026-10-18, not a rewrite: the package says a full Node 24 receipt was not available at assembly and that 350/350 “is not claimed here.” That scoping is still textually true of that file. It is not the current two-state record. Same HEAD already contains the accepted rerun: `corpus/live/runs/20261018T204240718894Z/verdicts.json` and `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` both parse to `cases=350 pass=350 fail=0`, `verdict PASS`, `seeds_unchanged True`, 13 positive cannon passes, node `v24.21.0`. Narrative: `reports/round-105/n24/full-run.md`. This seat did not re-run the 350-case battery. The 13-case split above is the live check; the 350/350 figure is the existing r105 receipt, not a new claim.

## L0 — same three questions

Command the package cites, re-run:

```text
$ python3 -c "p='reports/round-101/r101-report.md'; print(''.join(open(p).readlines()[337:342]), end='')"
**L0 questions for the operator:** (1) link an Epic Games account to GitHub so
`EpicGames/UnrealEngine` source becomes fetchable? (2) authorize pulling the public
`wukakuki/unreal-engine:dev-slim-5.8.3` image (~26.8 GB, contents unverified) as a possible
runtime unlock? (3) prefer the Lutris/Epic-launcher path instead? All three are
operator-owned; the lane proceeds static-only without them.
```

`git diff --quiet HEAD -- reports/round-101/r101-report.md` → `r101_report_diff_rc=0`. The three questions are unchanged: Epic/GitHub link, the `wukakuki/unreal-engine:dev-slim-5.8.3` image (~26.8 GB, contents unverified), Lutris/Epic-launcher path. Static-only work still proceeds without them. The package’s numbered list capitalizes the verbs and writes `GB; contents` where the source has `GB, contents`. That is a paraphrase, not a different question. Not queued.

## Queued, not fixed

Protected `reports/round-105/**` is not this seat’s to edit.

1. Package still tells the operator `pc_reviews=0`. Closed tree has three REVISE reviews and no landing. Correction is this note.
2. Package still reads as if 350/350 under Node 24 were unclaimed. The accepted receipt above already exists in r105. Correction is this note.

No mechanical path fix was available inside this seat’s write boundary. Sweep edits did not move the package, the P/C sources, the L0 source, or the runner.
