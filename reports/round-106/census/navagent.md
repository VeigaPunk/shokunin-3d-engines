# SEAT-31 CENSUS-NAVAGENT — r106

Axes: depth (one `--only` re-probe of the navagent fixture row), calibration (marker and seed pins vs the live tree and the r105 pinned-env receipt). Coverage: no citation edit in this chunk.

Scope: default environment only. No PATH prefix, no `--godot` override. Fixture sources were not written. Navagent is a Godot headless fixture family, not a separate engine. No Unreal runtime claim.

The row is the 99 `navagent3d_*` cases in `corpus/fixtures/run_battery.py` (93 ordinary, 6 negative controls, 5 scripts). One invocation, comma-separated `--only`, not 99 separate batteries.

## Result

**PASS.** `cases=99 pass=99 fail=0 ordinary=93 negative_controls=6 probes=0`. Runner exit 0. `seeds_unchanged=true`. `case_timeout_seconds=20`. Wall 145.352 s (2026-10-18T21:21:39Z–21:24:04Z). Stderr empty.

| | |
|---|---|
| Receipt | `reports/round-106/census/navagent/runs/20261018T212139347975Z/verdicts.json` |
| Receipt sha256 | `a53e771a99bb5ad14aad594dbfc79b83c4b5503705eba2726d0ab4c4e6f84e7e` (138322 bytes) |
| Stdout copy | `reports/round-106/census/navagent/runs/battery.stdout` sha256 `285b9acd03cad65c23646f388a3e6cd45839da10b79fea81332d81c78a510761` (16713 bytes) |
| Stderr copy | `reports/round-106/census/navagent/runs/battery.stderr` sha256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (0 bytes) |
| Case list | `reports/round-106/census/navagent/only-names.txt` (99 lines; `--only` bytes 3043) |

Exits: 93 `0/0`, 6 `2/2`. Reasons `[]` on every case. Each stdout has the Godot banner plus exactly one line equal to the seeded marker (`exact_marker_line=99/99`). No `node=` token in any navagent stdout or stderr.

Elapsed: 82 cases &lt;1.5 s, 16 in 1.5–3 s, one ≥5 s. Slowest `navagent3d_detour_mut_mapoff_ladder` 6.503 s, still under the 20 s pin. Not a timeout knife-edge.

## Environment (default state)

Probed from the repo root before the run, no PATH prefix:

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:20:38Z
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ command -v godot; godot --version
/usr/bin/godot
4.7.2.stable.arch_linux.ed1daf0bf
$ sha256sum /usr/bin/godot
3a72f85d53b84d7656ad8a633b06b019a11ad170a5718ff50bacc1c83cd4e72b  /usr/bin/godot
$ node --version; command -v node; readlink -f "$(command -v node)"
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
$ sha256sum "$(readlink -f "$(command -v node)")"
caa24debe02770c92a70677e2a62ca98890150e7ac1c17bcfe31bcc98cc89943  /home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
$ python3 --version; command -v python3
Python 3.14.7
/usr/bin/python3
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

AST count of `CASES` in that runner: 350. Navagent subset: 99. After the run, `node --version` was still `v26.12.0` at the mise path, and `git status --porcelain` on the runner and the five navagent scripts was empty.

The pinned fnm binary exists and was **not** selected. These markers do not read `node --version`. Node identity is environment context, not a marker input.

## Command and observed output

```text
$ ONLY=$(paste -sd, reports/round-106/census/navagent/only-names.txt)
$ python3 corpus/fixtures/run_battery.py --only "$ONLY" --runs reports/round-106/census/navagent/runs
PASS navagent3d_retarget: exit=0 expected=0
... 97 PASS lines omitted; full text is battery.stdout ...
PASS navagent3d_detour_mut_ctx_phys: exit=0 expected=0
totals: cases=99 pass=99 fail=0 ordinary=93 negative_controls=6 probes=0
PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-106/census/navagent/runs/20261018T212139347975Z/verdicts.json
BATTERY_EXIT=0
WALL_SEC=145.352
```

Receipt fields (parser on the file above; not a second run): `verdict=PASS`, `seeds_unchanged=True`, `only` length 3043 (99 names), `godot=/usr/bin/godot`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf`, `godot_version_exit=0`, `started_utc=20261018T212139347975Z`, `seed_paths=131`, `case_timeout_seconds=20`. Child shape recorded in the receipt: `/usr/bin/godot --headless --path <scratch> --script res://<fixture>.gd -- [flags]`.

## Pins

Receipt `seed_digests` vs `sha256sum` of the live files, checked after the run:

| path | sha256 | receipt match |
|---|---|---|
| `corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | yes |
| `corpus/fixtures/navagent3d_retarget.gd` | `6ad8584642edf8b1c41fb7116f39bf0e2d9513a2d73a99f0ea83d5cd4e1059d0` | yes |
| `corpus/fixtures/navagent3d_follow.gd` | `2bdcca4a08bd290bdcb097155c2299ae0fa6b5ac4893f68c2a04b073b782830c` | yes |
| `corpus/fixtures/navagent3d_next.gd` | `f0ea0fbb0c8400b7b6fd4b5e5139ae02d0487a1ddedfe483e1fd3c3f6ac5e94f` | yes |
| `corpus/fixtures/navagent3d_distance.gd` | `b820e469c35e68cf60d3f87bda94c1968cbc9b943b78513a6bf61bd0761c803a` | yes |
| `corpus/fixtures/navagent3d_detour.gd` | `66c097e4e5398481bbc9956038e8bd83b32fd879e8ee7071490f4c4ff34d2cec` | yes |
| `corpus/fixtures/navfollow3d_driver.gd` | `ec094e7f7baa317636b093d622687cae4f30928df417a547900406f759d28bbf` | yes |
| `corpus/fixtures/navretarget3d_driver.gd` | `310a1419c878f13b973b7fff895f5f1d536c7d69bcfb6e5faab98a9f2e7b0102` | yes |
| `corpus/fixtures/project.godot` | `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23` | yes |
| `corpus/fixtures/PINNED-ENV.md` | `90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f` | yes |

Those seven fixture prefixes are the same prefixes quoted in `reports/frontier/navagent-dissection.md` (r101 dissection, historical). They still match the live tree on 2026-10-18. That file was not rewritten.

Against `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` (pinned-env full battery, `PASS`, 350/350, runner sha `f456bd00…`, Godot `4.7.2.stable.arch_linux.ed1daf0bf`): all 99 navagent names are present; verdict, exit, marker literal, and stdout lines are identical (`stdout_drift=0`, `marker_literal_drift=0`, `verdict_drift=0`). This seat did not re-run under the fnm PATH. The match is a parse of that existing receipt, not a new pinned invocation.

## Census note for engines.md (not edited here)

`corpus/knowledge/engines.md` is outside this seat's write set. Queue for the engines census owner, dated 2026-10-18:

Godot row remains executable-headless. Fresh default-env receipt for the navagent row is the path above (`PASS battery`, 99/99, `seeds_unchanged=true`, Godot `4.7.2.stable.arch_linux.ed1daf0bf` at `/usr/bin/godot`, binary sha `3a72f85d…`). Do not add a navagent engine row. Do not treat this 99/99 as the 350/350 pinned-env battery count. No Unreal runtime claim.

## Not done

- Pinned-env (fnm Node v24.21.0) rerun of this row. Not run, so not claimed. The r105 pinned receipt already has identical stdout for these 99 cases.
- Full 350-case battery. Not this seat.
- No edits to `corpus/knowledge/engines.md`, fixtures, lessons, or rounds 101–105.
