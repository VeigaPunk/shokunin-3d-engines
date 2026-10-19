# Round 47 independent RemoteTransform3D review

Reviewer: LEAF non-author `game-dev-3d-r47-remote-review`. LOG r47 before-state `7437815a875434258ec821aaec7ef4dd4599a3df`; Godot `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, Linux headless. This is my sole tracked write; no implementation/runner/README/LOG edits, push or merge. Receipts and private project are ignored under `corpus/live/runs/`.

## Replay and previous baseline

Both commands from repository root exited **0**:

```sh
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 corpus/fixtures/run_battery.py --only remote3d_transform,remote3d_transform_unbound
```

Full `.shokunin/game-dev-3d/corpus/live/runs/20261013T075737700845Z/verdicts.json` SHA-256 `3f4b724d9f3ca64c7cfd9e2ce3be01c791cc5fe6a1a1e71d07d6c1aef3e30a5d`: **71/71 PASS** (34 ordinary, 37 negative controls), plus four PASS opt-ins: tree timeout `6ae9cc68ffc6e00aac9e91fb357f64b12f2ab9c2c49a7a3774e10a9ddfcb080a`, crash exit `eadc866d518afee4a6cbd2afce840420a517c12eb11d07db0998a8ab1562c62c`, stream attribution `d66fb6203f7251aac9edb24527b910d2c3c57c11d7d47820b4a9cfacf70d425a`, and existing contact-plane failing mutation `a4c5cecdc1758838c1b44da361678dcc38c9e5cdea207a6e3e4db480b226437c`. The latter is not my private remote mutation. Paired `.shokunin/game-dev-3d/corpus/live/runs/20261013T075737702741Z/verdicts.json` SHA-256 `36237852653568ff8ceaf43c5a80b7c301c0729cd35303766535321dbf34ca2d`: **2/2 PASS**, ordinary exit0 and unbound negative exit2; exact stdout markers `PASS remote3d_transform bound target=2.000,1.000,-3.000 basis_x=0.000,1.000,0.000` and `NEGATIVE REJECTED: remote3d_transform unbound target=0.000,0.000,0.000 source=2.000,1.000,-3.000`. Both case stderr lists and classifier reasons are empty; exact Godot commands and separate streams are in receipts. Both seed maps match one another, each seed-before/after map is unchanged, and case timeout is 20 seconds.

Prior r46 full `.shokunin/game-dev-3d/corpus/live/runs/20261013T075151189704Z/verdicts.json` SHA-256 `6ffbe7bfc4af1fb93a91ca39cfbf9be422c09c37e57b7bbadf7a0efe7eaad881`: **69/69 PASS**. All **69** previous case raw fields `case, script, flags, expected_exit, actual_exit, error, kind, marker, verdict, reasons, stdout, stderr` compare exactly to my full receipt, zero discrepancies. Scratch path and elapsed seconds differ. Prior-to-current SHA-256 seed-map differences only: README `9aa705028a2fb0c6890ef5a1b7b7206952c2d4a27caa6b338c9a3e51a6ebaf02` → `c3080154e73f1f1dbb6ad381018be3999d66674cb7f21f5766330728beef5aa1`; runner `5bbf96bfb345e48d96a7932f8f326af6a691a3f3b123d0bb4652534a3ce4c8e4` → `72a22d7e12895d7ec69c06339969cc102ba4279f8bcd56a7192a40b3f8273113`; added `remote3d_transform.gd` `19db84ebca945b9bfb01589d5cc62ae11168ffa2d5649d4f706c654cbdba98d5`. Every other previous seed hash is identical. `--only` restricts execution, not scratch copy contents.

## Mechanic and discriminating arm

The fixture creates separate `RemoteTransform3D` Source and `Node3D` Target under a live Node3D Stage, rather than directly writing Target. Ordinary arm binds Source's `remote_path` to `../Target`; unbound arm leaves it empty. After one awaited `process_frame`, it assigns Source local position `(2,1,-3)` and Z rotation `PI/2`, then awaits four further process frames. Stage/tree and distinct parents/identities, path and enabled update-position/update-rotation are guarded before outcome assertions. Source global-position magnitude >1 and basis X≈`(0,1,0)` establish that source translation/rotation are live, but the source position setup guard deliberately does not require literal X2. Bound Target global origin matches literal `(2,1,-3)`, global basis X≈`(0,1,0)` and Y≈`(-1,0,0)` within 0.0001; same source assignments leave the intact unbound Target origin≈zero and basis X≈identity. Both arms free Stage before marker/quit, with exact positive/negative marker and exit contract. Bounded observation is this one scene-tree propagation after process frames, **not network replication**, rendered movement, GPU, or cross-scene/general portability. The unbound predicate checks origin and basis X, not every basis component independently.

## Private mutation

Copied only the pair scratch to ignored `.shokunin/game-dev-3d/corpus/live/runs/r47-remote-review-private/source-x3` and changed exactly one source line for the ordinary-arm run `source.position = Vector3(2, 1, -3)` → `source.position = Vector3(3, 1, -3)` using an exact-string edit. Source fixture SHA-256 `19db84ebca945b9bfb01589d5cc62ae11168ffa2d5649d4f706c654cbdba98d5` → `8bfbf4d0343147e6163b7b1d8046c3ca09dafb89aaf1816c34c3474fb22fce73`; the expected target literal `(2,1,-3)`, markers, setup guards, and all other scratch files were untouched. Exact command from repository root, exit **1**:

```sh
godot --headless --path corpus/live/runs/r47-remote-review-private/source-x3 --script res://remote3d_transform.gd > corpus/live/runs/r47-remote-review-private/source-x3/mutation.stdout 2> corpus/live/runs/r47-remote-review-private/source-x3/mutation.stderr
```

Private stdout SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e` contains only Godot banner/blank line, no PASS. Private stderr SHA-256 `eceabec3201d293bdc0a9cf6a196876bb56b1c9ceb4abe384933027ea4e6e616` reports `ERROR: remote3d_transform: remote target propagation mismatch target=[X: (-0.0, 1.0, 0.0), Y: (-1.0, -0.0, 0.0), Z: (0.0, 0.0, 1.0), O: (3.0, 1.0, -3.0)]`; backtrace points to `_run` line37. Source general magnitude/basis and binding guards passed, while measured Target origin X3 differs from the unchanged literal X2. No `Parse Error`, `SCRIPT ERROR`, or ObjectDB leak warning. This one mutation isolates translation propagation rejection, not separate rotation-only assertion sensitivity.

Bounded assessment: **coverage improved** over 69 previous cases for path-bound live scene-tree `RemoteTransform3D` propagation versus intact unbound source; **depth unchanged** (one translation/rotation and one target); **calibration unchanged** (existing runner/classifier and four probes). One axis improved, none harmed in independent replay; no network or rendered-output claim.

## Correction note — 2026-10-18 (r106)

Dated correction note, not a rewrite of the findings above. Runnable command lines cited `.shokunin/game-dev-3d/`, which does not exist at this repo root. Those lines only were rewritten to repo-relative paths. Prose receipt paths, exits, markers, and SHA-256 values are unchanged.

Original commands at HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`:

```
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only remote3d_transform,remote3d_transform_unbound
godot --headless --path .shokunin/game-dev-3d/corpus/live/runs/r47-remote-review-private/source-x3 --script res://remote3d_transform.gd > .shokunin/game-dev-3d/corpus/live/runs/r47-remote-review-private/source-x3/mutation.stdout 2> .shokunin/game-dev-3d/corpus/live/runs/r47-remote-review-private/source-x3/mutation.stderr
```

Measured from this root the same day: `ls -ld .shokunin` → No such file or directory. Dead-root `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --only remote3d_transform` → rc 2, `can't open file '…/.shokunin/…/run_battery.py'`. Repo-relative `--only remote3d_transform,remote3d_transform_unbound` → rc 0, `PASS battery`, `seeds_unchanged=true` (durable copy `reports/round-106/scratch/seat07/only/remote-pair.verdicts.json`, sha256 `19c2a38827bbc7b4e32c1e4dde80f5e4d968f9a7461fa44feb156a067f88cf2e`). The full probe-battery command was not re-run. Cited `20261013T075737700845Z`, `20261013T075737702741Z`, and `20261013T075151189704Z` receipts, and `corpus/live/runs/r47-remote-review-private/`, are absent (`corpus/.gitignore:1` is `live/`). Rewritten `godot --path corpus/live/runs/r47-remote-review-private/source-x3` still exits 1: `Invalid project path specified: "corpus/live/runs/r47-remote-review-private/source-x3"`. Before the rewrite the same command named `.shokunin/…` and also exited 1. The remaining failure is the absent scratch, queued, not restored. Godot pin re-checked: `/usr/bin/godot --version` → `4.7.2.stable.arch_linux.ed1daf0bf`.

LOG before-state `7437815a875434258ec821aaec7ef4dd4599a3df` does not resolve in this repo (`git cat-file -t` → fatal). It resolves in `/home/vgpnk/Projects/prymeagnt` as `7437815a game-dev-3d r46: callback follower evidence report`. Quoted `remote3d_transform.gd` `19db84eb…` is the pre-r48 seed; the live file is `65422bef734af4f8f50dc269c09853f3e7c9c8aa74225ecf4d3fe853f4b9fed4`, the hash r48 records. Quoted runner/README digests are review-day seed-map rows; live `run_battery.py` is `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` and live `corpus/fixtures/README.md` is `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1`. Those historical sentences were not rewritten. Ledger: `reports/round-106/sweep/chunk-07.md`.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T075737700845Z/verdicts.json`
> - `corpus/live/runs/20261013T075737702741Z/verdicts.json`
> - `corpus/live/runs/20261013T075151189704Z/verdicts.json`
> - `corpus/live/runs/r47-remote-review-private/source-x3`
> - `corpus/live/runs/r47-remote-review-private/source-x3/mutation.stdout`
> - `corpus/live/runs/r47-remote-review-private/source-x3/mutation.stderr`
> - `corpus/live/runs/r47-remote-review-private/`
