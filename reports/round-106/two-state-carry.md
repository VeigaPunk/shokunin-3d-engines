# SEAT-77 TWOSTATE-CARRY — r106

Axes: calibration (quoted counts and digests vs the live tree and frozen receipts), coverage (every PINNED-ENV and SKILL row F pointer resolves), depth (live two-state node probe, not a battery rerun).

## Verdict

**CONSISTENT. No edit.** At 2026-10-18T18:42:45-03:00, HEAD `0cc3f41`, neither `corpus/fixtures/PINNED-ENV.md` nor `SKILL.md` differs from HEAD. Last touch of both is `3634bc0` (r105 work). No commit in `3634bc0..HEAD` names either path. A concurrent census seat has an uncommitted `corpus/knowledge/engines.md` edit; that edit agrees with this pair and did not touch these two files.

This seat did not rerun the battery. It re-probed Node resolution and re-parsed the receipts the two files cite. No Unreal runtime claim.

## Attribution (no sweep seat touched them)

```text
$ date -Is; git rev-parse --short HEAD
2026-10-18T18:42:45-03:00
0cc3f41

$ git status --short -- corpus/fixtures/PINNED-ENV.md SKILL.md
(empty)

$ git diff --numstat HEAD -- corpus/fixtures/PINNED-ENV.md SKILL.md
(empty)

$ git hash-object corpus/fixtures/PINNED-ENV.md; git rev-parse HEAD:corpus/fixtures/PINNED-ENV.md
d46e31c40e0f36f0a238d30ab1261212f32bd94a
d46e31c40e0f36f0a238d30ab1261212f32bd94a

$ git hash-object SKILL.md; git rev-parse HEAD:SKILL.md
81970105e72856d7c17e83bf95820584883d52f2
81970105e72856d7c17e83bf95820584883d52f2

$ git log -1 --format='%h %ad %s' --date=iso-strict -- corpus/fixtures/PINNED-ENV.md
$ git log -1 --format='%h %ad %s' --date=iso-strict -- SKILL.md
3634bc0 2026-10-18T18:14:40-03:00 r105: lifecycle lesson + node-24 pinned-env matrix (350/350) + P/C ruling package + SKILL row F + kimi-404 fold (64-seat swarm, openai-codex/gpt-6-luna-max)
3634bc0 2026-10-18T18:14:40-03:00 r105: lifecycle lesson + node-24 pinned-env matrix (350/350) + P/C ruling package + SKILL row F + kimi-404 fold (64-seat swarm, openai-codex/gpt-6-luna-max)

$ git log --oneline 3634bc0..HEAD -- corpus/fixtures/PINNED-ENV.md SKILL.md
(empty)

$ git blame -w -L 49,49 --date=iso-strict -- SKILL.md
3634bc07 (game-dev-3d-shokunin 2026-10-18T18:14:40-03:00 49) | **F** | ...

$ stat -c '%n mtime=%y' corpus/fixtures/PINNED-ENV.md SKILL.md
corpus/fixtures/PINNED-ENV.md mtime=2026-10-18 17:35:35.666705142 -0300
SKILL.md mtime=2026-10-18 18:14:21.175616676 -0300
```

`git blame` on every PINNED-ENV line is `3634bc07`. Working-tree sha256:

```text
90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f  corpus/fixtures/PINNED-ENV.md
8ea7ae5c306913d44340454ca242579ff1f6c9ba29007efdb7943757bbf36371  SKILL.md
```

The PINNED-ENV digest equals the seed digest stored in the accepted pinned receipt (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`, key `PINNED-ENV.md`).

## Live two-state probe

```text
$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node

$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" command -v node
v24.21.0
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

Both binaries exist (`ls -l` on each path, rc 0). This matches PINNED-ENV's command-scoped `PATH` prefix and its default-resolution sentence. It also matches the two-state table the census seat wrote into the uncommitted `engines.md` (default mise `v26.12.0`, pinned fnm `v24.21.0`).

## PINNED-ENV claims vs the tree

| Claim in `corpus/fixtures/PINNED-ENV.md` | Observed | Match |
|---|---|---|
| Thirteen `r94_cannon_*` markers pin `node=v24.21.0` | `run_battery.py` lines 662–686: exactly 13 literals, cases `det det2 varstep bailout nan sync material friction parity parity2 modes order backends` | yes |
| Fixture reads `node --version` via inherited PATH | `corpus/fixtures/r94_cannon.gd:127` `OS.execute("/bin/sh", ["-c", "node --version"], out, true)` | yes |
| Default full battery 337/350, 13 marker misses, observed `v26.12.0` vs pin `v24.21.0` | Parsed `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`: totals `cases=350 pass=337 fail=13`, verdict FAIL, `seeds_unchanged=true`. Fail set is exactly those 13 cases, each `reasons=('exact stdout marker missing',)`, token `v26.12.0` | yes |
| See `reports/round-104/physics/full-regression.md` §3.3 | Heading at line 179: 13 rows, `exit 0`, `exact stdout marker missing`, PATH order, mise `v26.12.0` vs fnm `v24.21.0`, not a fixture defect | yes |
| L1 probe `corpus/live/runs/20261018T202715395926Z/verdicts.json` is one-case `r94_cannon_nan` PASS, exit 0, `node=v24.21.0`, `seeds_unchanged=true` | Parsed: `only=r94_cannon_nan`, totals `cases=1 pass=1 fail=0`, verdict PASS, `seeds_unchanged=true`, `actual_exit=0`, `reasons=[]`, stdout token `v24.21.0` | yes |
| That one-case receipt is not a 350-case pass | Same file, `cases=1`. The accepted 350/350 is a different receipt (below). The sentence stays true of the file it names | yes |
| Full run default dir `corpus/live/runs/<timestamp>/` | `run_battery.py:1228` `default=HERE.parent / "live" / "runs"` | yes |
| Runner unchanged | `sha256sum corpus/fixtures/run_battery.py` → `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | yes |

Accepted pinned full run, parsed, not re-run: `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` totals `cases=350 pass=350 fail=0`, verdict PASS, `seeds_unchanged=true`; 13 positive `r94_cannon_*` rows all PASS with token `v24.21.0`. PINNED-ENV does not cite that file. That is an omission, not a contradiction: its L1 sentence is scoped to the one-case receipt. Dated note, not a rewrite (SEAT-17 owns PINNED-ENV sweeps; this seat does not edit it).

## SKILL row F vs the tree

Row F is the lane-fixture row (`SKILL.md` §1, line 49), last written in `3634bc0`. It is not a Node-token row. `phys3d_joints_free_ops` PASSes under both states with the same marker, so the row's command correctly omits the fnm `PATH` prefix. That does not collide with PINNED-ENV: the 13 default-env fails are only the cannon marker rows.

| Row F quote | Observed | Match |
|---|---|---|
| Frozen receipt `reports/round-104/physics/author-runs-final/20261018T193509710404Z/verdicts.json` sha `17b037d5154b7cf51a55df197a142f09ce3ea0fb9b4471f75a74a028f508397c` | `sha256sum` of that file equals the stamp | yes |
| `cases=1 pass=1 fail=0`, row PASS, `actual_exit=0`, `reasons=[]`, `seeds_unchanged=true`, `--only` one row, `case_timeout_seconds=20` | Parsed: `only=phys3d_joints_free_ops`, those totals, verdict PASS, `seeds_unchanged=true`, timeout 20, row exit 0, `reasons=[]` | yes |
| `corpus/fixtures/run_battery.py` sha `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | live `sha256sum` equals the stamp; receipt `seed_digests['run_battery.py']` equals it | yes |
| `corpus/fixtures/phys3d_joints.gd` sha `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6` | live `sha256sum` equals the stamp; receipt seed digest equals it | yes |
| `reports/round-104/physics/author.md` sha `4b3cbbf04ec35960b5d4a4362d596eb4c3c3ab291a9e2ea6c32749a637f02b81`; §§3.1 and 7 exist | `sha256sum` equals the stamp. §3.1 at line 84 quotes the `--only phys3d_joints_free_ops` command, `cases=1 pass=1 fail=0`, `PASS battery`. §7 at line 293 lists that command | yes |
| Named non-author replay (r104 full-regression) | Parsed `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`: `phys3d_joints_free_ops` PASS, exit 0, `reasons=[]`. Marker sha `706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74` (3921 bytes) equals the author receipt and the r105 pinned full receipt | yes |
| Label does not promote an engine-census row | Row text says so. Unreal row in the concurrent `engines.md` edit remains installed no / executable headless no. This seat makes no Unreal runtime claim | yes |

Seed map vs the row F receipt: 130 digests then, 0 changed, 0 removed, 1 added (`PINNED-ENV.md`, which did not exist at that r104 run). The disposable live dir `corpus/live/runs/20261018T193509710404Z` is gone; the frozen copy row F names is the durable receipt. That matches the cell's "never write new receipts into a frozen round directory" rule.

§6 also stamps `corpus/knowledge/engines.md` at `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`. At 18:42:45 the working tree file was `62a70d045d5f55712e316054583bdb5974f02d2a3ecbbe5de3a3dd05023af19d` (`git status`: `M corpus/knowledge/engines.md`, +110/−4). SKILL.md already says re-hash before acting on any stamp. The drift is the census seat's uncommitted edit, not a sweep of SKILL.md. Row F's four artifact stamps above are unchanged. Not edited here: `SKILL.md` is protected.

## Queued judgment defects (not fixed)

1. **Ambiguous `README.md` pointer** in PINNED-ENV's last sentence. Repo-root `README.md` (sha `5e3f6710dd44bb574ebb326338fa7a91759581971be9a796a26f2fff4a87f7b0`, 22 lines) has no `corpus/live/runs` and no `run_battery`. The description is in sibling `corpus/fixtures/README.md` line 27 ("Receipts land in `corpus/live/runs/<ts>/`") and in `run_battery.py:1228`. The operational claim is true; the unqualified name is an implicit-cwd citation. Owner: SEAT-17. This seat did not edit PINNED-ENV.
2. **Frozen elapsed mismatch, does not move row F's quoted fields.** `reports/round-104/physics/author.md` §3.1 says `elapsed_seconds 2.687`. The stamped receipt field is `2.669`. Exit, reasons, seeds, totals, timeout, and marker sha still match what row F quotes. Round-104 is protected; dated note only.
3. **PINNED-ENV does not point at the accepted 350/350 receipt.** Not a false claim. A reader can over-read the L1 disclaimer as "no full pinned pass exists." The durable pointer is `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`. Queue for SEAT-17 if a later sweep adds a dated note; do not silently rewrite.

## Not done

No battery rerun. No write to `SKILL.md`, `PINNED-ENV.md`, fixtures code, or rounds 101–105. `engines.md` was read only.
