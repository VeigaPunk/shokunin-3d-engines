# SEAT-40 CENSUS-VERIFY — r106

Axes: **calibration** (re-probe vs published census cells and peer r106 receipts), **coverage** (four probes, not a full battery), **depth** (both Node states on the three.js runner; no inherited version string).

Seat: independent re-run of 4 census probes; compare against `corpus/knowledge/engines.md` and the reports; flag drift. This file is the only write. `engines.md` was not edited (outside this seat's chunk). No fixture code written. No Unreal runtime claim — editor not installed.

**Compared against:**

- `corpus/knowledge/engines.md` sha256 `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` (unchanged since r102 repair; mtime `2026-10-18 14:42:49.295040755 -0300`, 2768 bytes; `git status --porcelain -- corpus/knowledge/engines.md` empty)
- r102 verifier `reports/round-102/engines-verify.md` (already recorded the Node string as stale; file still contains that flag)
- r105 two-state model `reports/round-105/default-state.md` (default mise Node v26.12.0 / pinned fnm Node v24.21.0)
- r106 peer census reports present at comparison time: `reports/round-106/census/three-default.md`, `cannon.md`, `phys3d-joints.md`

HEAD at probe: `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Probe window: `2026-10-18T21:20:40Z`–`2026-10-18T21:22:25Z`.

## Verdict

| # | Probe | engines.md cell | this seat | drift |
|---|---|---|---|---|
| 1 | Godot 4.7.2 installed + headless binary | `yes` `/usr/bin/godot` / `yes` | `/usr/bin/godot`, `4.7.2.stable.arch_linux.ed1daf0bf`, pacman `godot 4.7.2-1`, `--headless` reaches the binary (rc 1 only because the throwaway path is not a project) | **none** |
| 2 | Unity Editor | `no` / `no` | `unity` `UnityHub` `unityhub` all `command -v` rc 1; no editor dirs; pacman name match 0 | **none** |
| 3 | Unreal Engine | `no` / `no` | `UnrealEditor` `UnrealEditor-Cmd` `UE4Editor` `UnrealBuildTool` all rc 1; no editor dirs; `:8000` listeners 0 | **none** — no runtime claim |
| 4 | three.js 0.186.1, partial, Node parenthetical | pin `0.186.1`; headless `partial`; text says **Node v26.11.1** | pin `0.186.1` confirmed; 3/3 exit 0 both states; **default node is v26.12.0**, not v26.11.1 | **DRIFT — host-fact string only.** State column `partial` does not move |

Three state columns did not move. One quoted host fact is stale and was already flagged in r102 and r105; it is still uncorrected. Queued, not fixed.

## Probe 1 — Godot

```text
$ command -v godot; echo which_rc=$?
/usr/bin/godot
which_rc=0
$ godot --version; echo godot_rc=$?
4.7.2.stable.arch_linux.ed1daf0bf
godot_rc=0
$ godot --headless --quit --path /nonexistent-seat40
Invalid project path specified: "/nonexistent-seat40", aborting.
headless_probe_rc=1
$ pacman -Q godot
godot 4.7.2-1
$ stat -c 'path=%n size=%s mtime=%y' /usr/bin/godot; readlink -f /usr/bin/godot
godot path=/usr/bin/godot size=182015704 mtime=2026-08-18 14:19:08.000000000 -0300
/usr/bin/godot
```

Matches `engines.md` row 1 and `reports/round-102/engines-verify.md` §3 row 1 (`4.7.2.stable.arch_linux.ed1daf0bf`). The rc 1 is the missing project path, not a missing binary — headless mode was entered. This seat did not re-run the full battery; headless *execution of a fixture* is corroborated by peer receipts parsed below, not by a new 350-case run.

## Probe 2 — Unity absence

```text
$ command -v unity; echo unity_rc=$?
unity_rc=1
$ command -v UnityHub; echo UnityHub_rc=$?
UnityHub_rc=1
$ command -v unityhub; echo unityhub_rc=$?
unityhub_rc=1
$ ls -d /opt/unity* /opt/Unity* /usr/share/unity* "$HOME/Unity" "$HOME/UnityHub" /opt/unityhub
(all No such file or directory)
$ pacman -Qq | grep -iE 'unity|unreal' || echo pacman_unity_unreal_matches=0
pacman_unity_unreal_matches=0
```

`installed=no`, `executable headless=no` stands. No state move. Static r19 artifact was not re-verified here (not one of the four probes).

## Probe 3 — Unreal absence

```text
$ command -v UnrealEditor; echo UnrealEditor_rc=$?
UnrealEditor_rc=1
$ command -v UnrealEditor-Cmd; echo UnrealEditorCmd_rc=$?
UnrealEditorCmd_rc=1
$ command -v UE4Editor; echo UE4Editor_rc=$?
UE4Editor_rc=1
$ command -v UnrealBuildTool; echo UBT_rc=$?
UBT_rc=1
$ ls -d /opt/unreal* /opt/Unreal* /usr/share/unreal* "$HOME/UnrealEngine"
(all No such file or directory)
$ ss -ltn | awk '/:8000/{c++} END{print "port8000", c+0}'
port8000 0
```

`installed=no`, `executable headless=no` stands. **No Unreal runtime claim.** The pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` and the gate were not re-run by this seat (protected paths; not one of the four probes).

## Probe 4 — three.js pin, both Node states

Two-state resolution (r105 model), observed this seat:

```text
$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ node -p 'process.version + " " + process.execPath'
v26.12.0 /home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
$ sha256sum "$(readlink -f "$(command -v node)")"
caa24debe02770c92a70677e2a62ca98890150e7ac1c17bcfe31bcc98cc89943  /home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node

$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node -p 'process.execPath'
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
$ sha256sum /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
7fde7b8afa198da66257f42ee2001d874c7355631e6d1579a5fb5ef1f246df4c  /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

Lockfile pin (read, not `npm ci`):

```text
$ python3 -c "import json; lock=json.load(open('corpus/fixtures/three/package-lock.json')); three=lock['packages']['node_modules/three']; print(lock['packages']['']['dependencies']['three']); print(three['version']); print(three['resolved']); print(three['integrity'])"
0.186.1
0.186.1
https://registry.npmjs.org/three/-/three-0.186.1.tgz
sha512-blFeqb49wRCSGUGj7gtpfnSGHy2lwDk94RhUmS1c/hTby70kvChbWpkJ4Pm1390LqzzvTmzgXKHPEafJwCb8jA==
```

Installed `corpus/fixtures/three/node_modules/three/package.json` version: `0.186.1`. Same integrity string as `reports/round-102/engines-verify.md` §3 row 4.

Bounded runner, both states, from repo root (existing `node_modules`; `npm ci` not repeated):

```text
$ node corpus/fixtures/three/run_cases.mjs --receipt reports/round-106/scratch/seat40.dMYrxA/three-default-receipt.json
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
default_rc=0

$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node corpus/fixtures/three/run_cases.mjs --receipt reports/round-106/scratch/seat40.dMYrxA/three-pinned-receipt.json
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
pinned_rc=0
```

Receipt fields (`json` load):

| receipt | node | three | verdict | seedsUnchanged | exits |
|---|---|---|---|---|---|
| `reports/round-106/scratch/seat40.dMYrxA/three-default-receipt.json` | v26.12.0 | 0.186.1 | PASS | true | 0, 2, 1 |
| `reports/round-106/scratch/seat40.dMYrxA/three-pinned-receipt.json` | v24.21.0 | 0.186.1 | PASS | true | 0, 2, 1 |

Default-state child `execPath` in the receipt: `/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node`. Pinned-state child `execPath`: `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`. The 3/3 count is not a claim about GL, pixels, or a browser.

**Drift:** `engines.md` line 11 still says `(Node v26.11.1)`. Live default is v26.12.0. The string is a mint-time host fact, not the three.js package pin. r102 already flagged it (`reports/round-102/engines-verify.md` §3 row 4 and §6 item 2) and left it untouched; r102 F5 repair explicitly left it (`reports/round-102/repairs/F5-engines.md`: "The row's parenthetical Node v26.11.1 is a mint-time host fact and was left untouched"). r105 connector told the census to keep v26.11.1 as three.js evidence context rather than a universal host Node (`reports/round-105/r105-connector.md:64-66`). That advice is still on disk, and it is the wrong reading of a parenthetical that sits in the *installed* cell with no date: a reader of `engines.md` alone will take v26.11.1 as the current default. It is not.

Queued for the engines.md owner (dated note, not a silent rewrite): the installed cell should say the lockfile pin is `three@0.186.1` and that the **2026-10-18 default** Node is mise v26.12.0 (`process.execPath` above), with fnm v24.21.0 as the separate pinned state. Do not delete the historical v26.11.1 fact; date it. Do not move `executable headless` off `partial`.

## Comparison to r106 peer census reports

Peer reports were read and their receipts parsed. No peer file was edited.

### `reports/round-106/census/three-default.md` (SEAT-26) — agrees

Parsed `reports/round-106/census/three-run_cases-20261018T212022Z.json` (sha256 `1668bb85c370d6bdfd578981f61a64d78a5cb17bb8ff5f89250aa9f712120611`, matches the digest printed in that report): `node=v26.12.0`, `three=0.186.1`, `verdict=PASS`, `seedsUnchanged=true`, exits `[0, 2, 1]`. Structural compare against this seat's default receipt: top-level `node` / `three` / `verdict` / `seedsUnchanged` / `seedDigests` / `boundedClaim` equal; per-case `verdict`, `actualExit`, `stdout`, and `command[0]` equal. Both receipts record execPath `/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node`. Node binary sha256 in that report (`caa24debe0…`) matches this seat's `sha256sum` of the same path.

SEAT-26 also reports camera suite 5/5. **Not re-run here** — not one of the four probes; not confirmed, not contradicted.

SEAT-26's queued note (v26.11.1 is stale vs v26.12.0) matches this seat's drift flag.

### `reports/round-106/census/cannon.md` (SEAT-28) — agrees on fields checked

Parsed `reports/round-106/census/cannon-r94_cannon_det-20261018T212035Z.verdicts.json`: 20884 bytes, sha256 `11109a3cad610b759974606e7784a5f215332c7d092ab0ead0c514b2fdac344f` (matches the report), `verdict=PASS`, `seeds_unchanged=true`, `only=r94_cannon_det`, totals `cases=1 pass=1 fail=0`, row exit 0 expected 0, stdout token `node=v24.21.0`, `godot=/usr/bin/godot`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf`. Godot identity matches probe 1. Pinned node token matches this seat's fnm resolution. This is one row, not a 350-case confirmation. `engines.md` has no cannon row; nothing to drift against there.

### `reports/round-106/census/phys3d-joints.md` (SEAT-33) — agrees on fields checked

Parsed both receipts named in that report:

| receipt | bytes | verdict | seeds | only | row exit | godot | godot_version |
|---|---:|---|---|---|---|---|---|
| `reports/round-106/census/phys3d-joints/runs/20261018T212035512412Z/verdicts.json` | 17243 | PASS | true | `phys3d_joints_free_pair` | 0/0 | `/usr/bin/godot` | `4.7.2.stable.arch_linux.ed1daf0bf` |
| `reports/round-106/census/phys3d-joints/runs/20261018T212038422172Z/verdicts.json` | 22053 | PASS | true | `phys3d_joints_free_ops` | 0/0 | `/usr/bin/godot` | `4.7.2.stable.arch_linux.ed1daf0bf` |

Byte sizes match the report (17243 / 22053). Godot version matches probe 1. No `node=` token in those rows, as the report says. Not a full-battery claim.

## What did not drift

- Godot path, version string, and package version vs engines.md and vs r102.
- Unity absence vs engines.md and vs r102.
- Unreal editor absence and `:8000` count 0 vs engines.md and vs r102. No runtime claim added.
- three.js package pin `0.186.1`, lock integrity, and the 3/3 exit-0 evidence command (default state). `executable headless` stays `partial`.
- engines.md blob identity vs the r102 repair sha256. The file has not moved since the F5 repair, which is why the stale Node string is still there.

## Queued (not this seat)

1. **engines.md:11 Node parenthetical.** Date-correct `Node v26.11.1` as a historical mint fact. Current default (2026-10-18, this probe) is mise Node **v26.12.0** at `/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node`. Pinned state remains fnm **v24.21.0**. Do not silently replace the old string. Do not treat v26.11.1 as the live default. Owner is whoever holds the engines.md chunk this round — not SEAT-40.
2. r105 connector line that says to keep v26.11.1 as the three.js evidence context should be read with that date, or a later connector should supersede it. Not edited here (r105 reports are protected).

## Not done

- Full battery (337/350 default, 350/350 pinned) was not re-run.
- `npm ci` on a clean `git archive` was not repeated; the working tree already had `node_modules/three@0.186.1`.
- Camera suite 5/5 (SEAT-26) was not re-run.
- Gate / upstream pin was not re-run.
- No write to `corpus/knowledge/engines.md`, fixtures, LOG/SCORECARD/SHONEN/PROVINCE/SKILL, or rounds 101–105.
