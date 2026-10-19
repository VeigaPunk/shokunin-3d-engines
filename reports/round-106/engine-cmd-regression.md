# r106 · SEAT-109 · ENGINE-CMD-REGRESSION

**Seat:** SEAT-109 (ENGINE-CMD-REGRESSION) · round 106 · lane `game-dev-3d-shokunin`
**Date:** 2026-10-18 · runtime `2026-10-18T21:20:45Z`–`2026-10-18T21:38:45Z`
**HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`, r105 report-last)
**cwd:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**Writes:** this file, plus raw logs under `reports/round-106/scratch/seat109/` (not `/tmp`). Nothing under `corpus/` was written by this seat. `engines.md` was not edited (SEAT-38 owns it).

**Question:** does every command the on-disk `corpus/knowledge/engines.md` cites re-run green at this runtime, under the r105 two-state Node model (default mise Node v26.12.0 / pinned fnm Node v24.21.0 at `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin`)?

**Verdict: one named failure.** The Unreal-row command `sha256sum -c .manifest.d/audit-reference.sha256`, cited as `→ rc=0` with no cwd, exits **1** from the repo root and **0** only from `corpus/knowledge/unreal-mcp` (12/12 `OK`). Every other cited command re-ran as the cell claims, including the three.js command on both Node states and on a clean `git archive` tree. No state column moved. No Unreal runtime claim — editor not installed.

Axes: **coverage** (every backtick command in the file, not a sample), **calibration** (observed exit vs the cell's claimed exit), **depth** (both Node states, clean archive, not a restatement of the r102 verifier).

## File under test

No r106 rewrite of `engines.md` had landed by close. The bytes judged are the r102 repair, equal to the `HEAD` blob.

```text
$ sha256sum corpus/knowledge/engines.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  corpus/knowledge/engines.md
$ git hash-object corpus/knowledge/engines.md; git rev-parse HEAD:corpus/knowledge/engines.md
5eef89d484b60e26ab78c29dd86a64781b0df86f
5eef89d484b60e26ab78c29dd86a64781b0df86f
$ stat -c 'mtime=%y size=%s' corpus/knowledge/engines.md
mtime=2026-10-18 14:42:49.295040755 -0300 size=2768
$ git status --porcelain -- corpus/knowledge/engines.md
(empty)
```

Rechecked at `2026-10-18T21:38:45Z`: same sha, same mtime. A snapshot taken at `2026-10-18T21:20:54Z` (`reports/round-106/scratch/seat109/engines.md.snapshot`) diffs clean against the file (`diff_rc=0`). If SEAT-38 lands new commands after that timestamp, they are outside this receipt.

Host at probe start (`reports/round-106/scratch/seat109/host.txt`):

```text
$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version; PATH=… command -v node
v24.21.0
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
$ npm --version
11.20.0
$ PATH=fnm-v24.21.0:$PATH npm --version
11.19.0
$ godot --version
4.7.2.stable.arch_linux.ed1daf0bf
```

## Command inventory

Backtick tokens in `engines.md` that are commands, classified against the cell's claim:

| # | cited command | cell claim | observed | verdict |
|---|---|---|---|---|
| 1 | `/usr/bin/godot` (the installed path) | present, headless yes | `/usr/bin/godot`, version `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless --quit` rc=0 | **GREEN** |
| 2 | `sha256sum -c .manifest.d/audit-reference.sha256` | `→ rc=0` | repo root rc=1; subtree rc=0, 12 `OK` | **FAIL as written** |
| 3 | `npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs` | 3/3, `seeds_unchanged=true`, exit 0 | exit 0 both Node states, working tree and clean archive; installed `three` `0.186.1` | **GREEN** |
| 4 | `node corpus/fixtures/three/run_cases.mjs` alone on `git archive HEAD corpus/fixtures/three` | exits 1 | `bare_rc=1` | **GREEN** (negative claim holds) |
| 5 | `git archive HEAD corpus/fixtures/three` | the clean tree the note describes | `archive_only_rc=0` | **GREEN** |
| 6 | `require.resolve('three')` from repo root | failed | `MODULE_NOT_FOUND`, rc=1 | **GREEN** (negative claim holds) |

Positive claims expected to exit 0: 4. Of those, 3 green, 1 fail (row 2). Negative claims expected to fail: 2, both reproduced.

## 1. Named failure — Unreal evidence command is cwd-dependent

The cell (`engines.md` Unreal row) writes the command with no working directory and claims `→ rc=0`. The file's other runnable command is repo-root-relative (`corpus/fixtures/three/…`) and its note says "from repo root". Run that way, the Unreal command does not re-run green:

```text
$ sha256sum -c .manifest.d/audit-reference.sha256
sha256sum: .manifest.d/audit-reference.sha256: No such file or directory
rc=1
```

The bytes the cell is pointing at are intact. The same command from the subtree the relative path implies:

```text
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
rc=0
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | grep -c ': OK$')
12
```

**12/12 `OK`, 0 `FAILED`, exit 0 from the subtree; exit 1 from the repo root.** The pin is not broken. The citation is not re-runnable as written. This is the same defect the r102 verifier flagged (`reports/round-102/engines-verify.md` §3 row 3 / §6 item 1) and it is still unfixed: the file sha is the r102 repair sha. Not a new byte regression. Queued for SEAT-38 — minimum honest fix is a dated note or an in-place command prefix `cd corpus/knowledge/unreal-mcp &&`, not a silent rewrite of the historical `rc=0` claim (that claim is true at the implied cwd).

Counts the same cell states, re-derived here (not cited as shell, recorded because the command's `→ rc=0` is what those counts hang on):

```text
CARDS 13
COUNTS {'static-only': 12, 'unproven-runtime': 1, 'verified-here': 0, 'OTHER': 0}
```

`actors-scene.md` is the single `unproven-runtime` card. `head -5 corpus/knowledge/unreal-mcp/upstream/LICENSE` begins `MIT License` / `Copyright (c) 2026 Epic Games, Inc.` The short pin `a6aa73ad` appears in `PROVENANCE.md` as `a6aa73ada02a9fb1f5415bec491f9942c519b297`. This seat did not clone upstream and makes no fresh-clone claim.

**No Unreal runtime claim.** Editor binaries are absent (below). `verified-here` stays 0.

## 2. three.js cited command — green on both Node states

Working tree, default mise Node v26.12.0, command as written from the repo root (`reports/round-106/scratch/seat109/three-default.txt`, sha256 `5ef654f1c35c0f51d0a0548ea75fee62709e63d7c678eb7786f4d0971afb669d`):

```text
$ npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs
added 1 package, and audited 2 packages in 448ms
found 0 vulnerabilities
npm_rc=0
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
node_rc=0
```

Working tree, pinned fnm Node v24.21.0 (`three-pinned.txt`, sha256 `4bc47bc41ab31967260b464d28787ed5d5a4a55d0945d79caedabb3a82ce6374`):

```text
node=v24.21.0 which=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
npm=11.19.0
added 1 package, and audited 2 packages in 429ms
found 0 vulnerabilities
npm_rc=0
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
node_rc=0
```

Clean tree (the note's `git archive` claim), not the working tree's already-installed `node_modules`. Extracted under `reports/round-106/scratch/seat109/` (not `/tmp`); `node_modules` was absent before `npm ci`. Install trees were removed after the logs were captured.

```text
$ git archive HEAD corpus/fixtures/three >/dev/null
archive_only_rc=0
```

Bare `node` on that clean tree, default Node (`three-clean-bare.txt`, sha256 `0b016ca16fb27eeef82c65c46fcd3cf7f158bbeb27571c9a99e6ac2e32d405a6`):

```text
$ node corpus/fixtures/three/run_cases.mjs
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=1 expected=1
FAIL three battery: 3/3, seeds_unchanged=true
bare_rc=1
```

The note's "exits 1" holds. The printed `3/3` on a failing run is why the evidence cell's `exit 0` is the discriminating token; this re-run shows that split again.

Cited command on a clean tree, default Node (`three-clean-default.txt`, sha256 `af2aa75490f9cb042f02379be4ed91c5670a11f9d9135daf50d99e9b06edb43f`):

```text
node=v26.12.0 npm=11.20.0
added 1 package, and audited 2 packages in 365ms
found 0 vulnerabilities
npm_rc=0
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
node_rc=0
installed three version: 0.186.1
```

Same command, clean tree, pinned Node v24.21.0 (`three-clean-pinned.txt`, sha256 `353994bdad993f142a065b6fcac039e5944edd8baaf00243425a160bcb2d669f`): `npm_rc=0`, `node_rc=0`, same four `PASS` lines, `seeds_unchanged=true`, installed `three` `0.186.1`.

`require.resolve('three')` from the repo root, after the scoped install existed under `corpus/fixtures/three/` (`remaining.txt`):

```text
$ node -e "console.log(require.resolve('three'))"
Error: Cannot find module 'three'
code: 'MODULE_NOT_FOUND'
Node.js v26.12.0
rc=1
```

Same `MODULE_NOT_FOUND` / rc=1 from a fresh archive tree that had never had `node_modules`. The note's "failed from repo root" still holds. Lockfile pin, read not executed: `package-lock.json` `node_modules/three` version `0.186.1`, `package.json` dependency `0.186.1`.

**The three.js command is green. The row's Node parenthetical is not.** The installed cell says `(Node v26.11.1)`. Live default is `v26.12.0`. That string is a host fact, not a command, so it is not scored as a command failure. It is still wrong, and the row does not mention the pinned v24.21.0 state even though the cited command is green there too. Queued for SEAT-38 as a dated correction note. State column stays `partial`: Object3D math under Node, no GL context, no rendering claim. This seat did not open a browser or a GL context.

## 3. Godot cited path — green

The row cites the executable path, not `run_battery.py`. This seat did not re-run the 350-case battery.

```text
$ command -v godot
/usr/bin/godot
rc=0
$ godot --version
4.7.2.stable.arch_linux.ed1daf0bf
rc=0
$ ls -l /usr/bin/godot
-rwxr-xr-x 1 root root 182015704 Aug 18 14:19 /usr/bin/godot
rc=0
$ /usr/bin/godot --headless --quit
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org
rc=0
```

Version string matches the row's `Godot 4.7.2`. Headless quit entered the binary and exited 0. That is the cited executable, not a fixture battery.

The evidence cell's path `corpus/live/runs/` is not a command. Resolution, so it is not silent:

```text
$ test -d corpus/live/runs; echo dir_rc=$?
dir_rc=0
$ find corpus/live/runs -name verdicts.json | wc -l
107
$ git check-ignore -v corpus/live/runs
corpus/.gitignore:1:live/	corpus/live/runs
$ find corpus/live/runs -maxdepth 1 -type d -name '20261013*' | wc -l
0
$ ls -d corpus/live/runs/20261013T053632289732Z
ls: cannot access 'corpus/live/runs/20261013T053632289732Z': No such file or directory
rc=2
```

The directory exists on this host and is gitignored. The row does not name a receipt file. No mint-day (`20261013*`) run directory is present. Not a command failure. Queued as a citation-resolution note for the census owner: the pointer resolves to a gitignored directory, not to a durable in-tree receipt.

## 4. Absence claims — hold (not command failures)

These are the state cells, not backtick commands. Recorded so a green command table is not read as "engines appeared."

```text
$ command -v unity Unity UnityHub unityhub
rc=1
$ ls -d /opt/unity* /usr/share/unity* $HOME/Unity*
ls: cannot access … No such file or directory
rc=2
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor UnrealBuildTool
rc=1
$ ls -d /opt/unreal* /usr/share/unreal* $HOME/UnrealEngine*
ls: cannot access … No such file or directory
rc=2
$ ss -ltn | grep -c ':8000'
0
```

Unity `no`/`no` and Unreal `no`/`no` stand. No state move. No Unreal editor, no UBT, no listener on `:8000`. No runtime claim.

## 5. Supporting probes — not cited by `engines.md`

The Unity and Unreal rows name the artifact directories and "local static" checks. They do not quote the checker commands (those live in the artifact READMEs). Run anyway, so a reader does not have to infer them. Both pairs exit 0. They do not promote either row.

```text
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py
PASS local-static actual=accept expected=accept … reason=two GameObjects and two Transforms; reciprocal fileIDs; parent-child world=(11,2,-3) (local static derivation)
rc=0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py corpus/artifacts/unity-r19/Hierarchy.broken-reference.unity --expect-reject
PASS local-static actual=reject expected=reject … reason=child father reference broken: {'fileID': 999}
rc=0
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py
PASS local-static actual=accept expected=accept … reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
rc=0
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
PASS local-static actual=reject expected=reject … reason=unsupported module Type: 'Unknown'
rc=0
```

Full text: `reports/round-106/scratch/seat109/static-verifiers.txt` (sha256 `7edf4f1ba20fa6aa7911b2dfaccc3624ca67bce8c55804ad7c1471d6f47912d9`). These checks are static. They do not prove Unity import or Unreal plugin load.

## 6. Queued, not fixed

This seat does not own `engines.md`.

1. **Command failure:** `sha256sum -c .manifest.d/audit-reference.sha256` exits 1 from the repo root, 0 from `corpus/knowledge/unreal-mcp` (12/12). Open since r102. Prefix the cwd, or cite `gate/run_gate.sh` (not re-run here; not cited by `engines.md`; gate tree is protected). Do not silently rewrite the historical `rc=0`.
2. **Stale host fact, not a command fail:** installed-cell parenthetical `Node v26.11.1`; live default is `v26.12.0`. The cited three.js command is also green under pinned `v24.21.0`, which the row does not mention. Dated correction note, not a state-column move.
3. **Citation resolution, not a command fail:** Godot evidence "r1 battery receipts under corpus/live/runs/" resolves to a gitignored directory (`corpus/.gitignore:1`). 107 `verdicts.json` on this host; 0 mint-day `20261013*` directories. The row names no receipt file.

## 7. Not run

- Full `python3 corpus/fixtures/run_battery.py`. Not cited by `engines.md`. Godot headless proof is `--headless --quit` rc=0, not a 350-case receipt.
- `corpus/knowledge/unreal-mcp/gate/run_gate.sh`. Not cited. Gate tree is protected. Not claimed green or red by this seat.
- Fresh upstream clone of `a6aa73ad`. Not cited as a command. `/tmp` quota is exhausted; no clone was attempted. The sha256 sweep above is the cited check.
- Any Unreal Editor or MCP tool call. Editor is not installed.

## Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
sha256sum corpus/knowledge/engines.md   # expect d03907d3… unless SEAT-38 has rewritten it
godot --version
/usr/bin/godot --headless --quit
sha256sum -c .manifest.d/audit-reference.sha256; echo rc=$?          # expect rc=1 from repo root
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256); echo rc=$?  # expect rc=0, 12 OK
npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs  # expect exit 0
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
  node corpus/fixtures/three/run_cases.mjs   # expect exit 0, node v24.21.0
```

Raw logs: `reports/round-106/scratch/seat109/`. Probe block sha256 `a82fbf1116f00df5f064c8014f91a705c2b226b4599830595109baffeabba224` (`cmd-probes.txt`).
