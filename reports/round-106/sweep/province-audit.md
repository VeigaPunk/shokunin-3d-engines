# SEAT-20 SWEEP-AUDIT — PROVINCE.md + SHONEN.md (read-only)

**Seat:** SEAT-20. **Round:** r106. **Lane cwd:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
**HEAD at probe:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (report-last r105; work `3634bc0` was the brief's prior work commit — this seat did not move HEAD).
**Probe window:** 2026-10-18T21:22:18Z–21:40:55Z.
**Owned write:** this file only. Scratch transcripts: `reports/round-106/scratch/seat20/`.
**Protected, not edited:** `PROVINCE.md`, `SHONEN.md`. `git diff --exit-code -- PROVINCE.md SHONEN.md` → `diff_rc=0`. Working-tree blobs equal `HEAD:PROVINCE.md` `cde5e8f518bb05149ab62e4ea5aa44f547e8aa69` and `HEAD:SHONEN.md` `8d85902c19010deb4fa154e16a2c12ad56ff10d1`.

**Axes.** Coverage = path/command resolution of these two files. Calibration = whether the checked SHONEN box's evidence pointer still resolves, and whether quoted counts/digests match the live tree. Depth (engines.md census refresh) is not this seat; cross-notes only, no `engines.md` edit.

**No Unreal runtime claim.** Editor probes below found no editor binary. Static absence is not live-editor evidence.

**Fixes landed:** 0. Mechanical dated notes are queued in §5 because both files are protected. Nothing was silently rewritten.

## 0. Result

| Class | Count | What |
|---|---:|---|
| Backtick citations | 4 | 2 in PROVINCE, 2 in SHONEN |
| Resolve from lane cwd | 8 paths + 1 command | census, seed, fixtures, predecessor tree, lesson, gamez research, REA skill dir, `npx -y rea-agents@6.4.0` |
| Resolve only from parent cwd | 2 | `.shokunin/game-dev-3d/corpus`, write glob `.shokunin/game-dev-3d/**` |
| Command fails from lane cwd | 2 | the two battery lines the SHONEN box depends on, both rc=2 before the script starts |
| Receipt paths missing | 3 | r2 lesson receipts; gitignored `corpus/live/` |
| Quoted digest drift vs live seeds | 2 of 12 | `README.md`, `run_battery.py` (historical r1 map, not a current claim in SHONEN itself) |
| Judgment items queued | 2 | box 2 attestation vs missing receipts; write-root contract wording |
| Files changed by this seat | 1 | this report |

Mint host sentences that are still true on this host: Godot `4.7.2.stable.arch_linux.ed1daf0bf` at `/usr/bin/godot`, headless flag present, `godot --headless --version` rc=0; Unity and Unreal editor binaries not found by the probes in §3. Those sentences did not need a correction note.

## 1. What was audited

`PROVINCE.md` last content commit `82c21b4a357bf42d222c6e2d684447497b696e25` (2026-10-13, r1). SHA-256 `1932f0fd7103dcc33e0b0c9f835adfe681e6ce4d765d4673bcc925c5d8230eac`. 47 lines, 2683 bytes.

`SHONEN.md` last content commit `a6b944dcadd3d246f2e1e5ad87b6fc1a00855083` (2026-10-13, r2; `git show --stat` touches only `SHONEN.md`, 1 insertion, 1 deletion). SHA-256 `b44667ff4f0d4cfd8700eab2523b97ba3b254e440abde06d4214e9834d6a6062`. 9 lines, 561 bytes.

Backtick inventory (extracted, then resolved one by one):

- `PROVINCE.md:31` `npx -y rea-agents@6.4.0`
- `PROVINCE.md:46` `.shokunin/game-dev-3d/**`
- `SHONEN.md:4` `game-dev-3d-r2-review-retry` (reviewer name, not a command)
- `SHONEN.md:4` `corpus/lessons/r2-independent-review.md`

Path tokens treated as citations: `corpus/knowledge/engines.md`, `corpus/knowledge/seed.md`, `corpus/fixtures`, `.shokunin/game-dev-3d/corpus`, `~/Projects/gamez/research/`, `~/.agents/skills/reverse-engineer-anything/`. Slash-compounds that are not paths (`asset/container`, `observation/inference/unknown`, `scene-graph/math`, `engine/editor`, `harness/evidence`, `engines/tooling`, `tables/error`, `patterns/checklists`) were not resolved as files. Refuse-list lane names (`art-east-asian-design`, `harness-integrity`, `gate-evidence`, `rlm-dispatch`, lore, `game-dev-2d`, revenger) are policy tokens, not paths; this seat did not look them up on disk.

## 2. Resolution table

| id | citation | from lane cwd | observed |
|---|---|---|---|
| P1 | `corpus/knowledge/engines.md` | resolves | file exists, 16 lines; Godot row still says 4.7.2 / `/usr/bin/godot` |
| P2 | `corpus/knowledge/seed.md` | resolves | file exists; states predecessor commit `4671a6b53dc4fbb878f477b2c2961305d1d9484c` and `craft/games-r15-toggle` |
| P3 | `corpus/predecessor/` | resolves as a tree, not as a git object | `corpus/predecessor/corpus` exists; `corpus/predecessor/.git` missing. The seed commit is a string in `seed.md`. No local clone at the four guessed paths. This seat did not query GitHub. **Sha unverified as a git object here — not proven false.** |
| P4 | `corpus/fixtures/` | resolves | directory exists; `corpus/fixtures/run_battery.py` isfile True |
| P5 | `.shokunin/game-dev-3d/corpus` (`PROVINCE.md:25-27`) | **does not resolve** | `.shokunin` missing; `glob_count` of `.shokunin/game-dev-3d/**` = 0 |
| P6 | same path from parent cwd | resolves, same inode | parent symlink → this repo; `PROVINCE.md` inode `9813873` both ways |
| P7 | `~/Projects/gamez/research/` | resolves | directory, mtime 2026-10-11; contains the research markdown set |
| P8 | `~/.agents/skills/reverse-engineer-anything/` | resolves | directory; `SKILL.md` present; `references/` present. `~/.kimi-code/skills/reverse-engineer-anything` is a symlink to that dir (not cited by PROVINCE) |
| P9 | `npx -y rea-agents@6.4.0` | **resolves, stale pin** | version print `6.4.0` rc=0 on default node v26.12.0 and pinned node v24.21.0. `npm view rea-agents version` → `6.7.0`. Skill documents `rea-agents@6.7.0` 5 times and `rea-agents@6.4.0` 0 times. No `rea` CLI (`which` rc=1) |
| P10 | write sentence `Only writes .shokunin/game-dev-3d/**` (`PROVINCE.md:46`) | **glob matches nothing here** | `shokunin_exists False`, `glob_count 0`. Parent symlink makes that prefix the name of this whole repo |
| S1 | `corpus/lessons/r2-independent-review.md` | resolves | tracked file, 43 lines. Reviewer string inside it matches the SHONEN backtick |
| S2 | `game-dev-3d-r2-review-retry` | not a command | `command -v` rc=1. It is the reviewer name at `corpus/lessons/r2-independent-review.md:3` |
| S3 | lesson commands `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py` and the same with `--probe-failing` | **fail from lane cwd** | both rc=2, `Errno 2`, stdout empty. Parent path isfile True. This seat did not run the battery |
| S4 | lesson receipts `20261013T030546459582Z/verdicts.json`, `20261013T030602866163Z/verdicts.json`, `…/mutation-verdicts.json` | **missing** | absent both as `corpus/live/runs/…` and via the parent prefix. `git check-ignore -v` → `corpus/.gitignore:1:live/` |
| S5 | lesson source cross-check of `corpus/fixtures/body3d_slide.gd` | source constants still match | `BOX_SIZE (4,4,4)`, `RUNNER_SIZE (1,1,1)`, `START_Z 6.0`, `DRIVE_SPEED 10.0`, `EXPECTED_PLANE_Z 2.5`, `EXPECTED_CONTACT_TICK 21`. Plane 4/2+1/2=2.5 and tick (6−2.5)/(10/60)=21 still follow from those constants. **Not a fresh Godot run** |

## 3. Commands and observed output

Lane identity:

```
$ pwd
/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ git diff --exit-code -- PROVINCE.md SHONEN.md ; echo diff_rc=$?
diff_rc=0
$ sha256sum PROVINCE.md SHONEN.md
1932f0fd7103dcc33e0b0c9f835adfe681e6ce4d765d4673bcc925c5d8230eac  PROVINCE.md
b44667ff4f0d4cfd8700eab2523b97ba3b254e440abde06d4214e9834d6a6062  SHONEN.md
```

Parent-only root (same bytes, different cwd):

```
$ ls -ld /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
lrwxrwxrwx 1 vgpnk vgpnk 38 Oct 13 17:04 … -> ../../../shokunin/game-dev-3d-shokunin
$ readlink -f /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ stat -c '%i %n' PROVINCE.md /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/PROVINCE.md
9813873 PROVINCE.md
9813873 /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d/PROVINCE.md
$ python3 -c 'import glob,os; print("shokunin_exists", os.path.exists(".shokunin")); print("glob_count", len(glob.glob(".shokunin/game-dev-3d/**", recursive=True)))'
shokunin_exists False
glob_count 0
```

From the parent prefix, `.shokunin/game-dev-3d/corpus`, `corpus/fixtures`, `corpus/knowledge/seed.md`, `corpus/knowledge/engines.md`, and `corpus/lessons/r2-independent-review.md` all printed `PARENT_OK`.

SHONEN's two cited commands, from this root (stdout empty, 0 bytes):

```
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py': [Errno 2] No such file or directory
cmd1_rc=2
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-failing
python3: can't open file '…/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py': [Errno 2] No such file or directory
cmd2_rc=2
```

Repo-relative twin `corpus/fixtures/run_battery.py` isfile True. SHA-256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (matches the r106 brief's runner pin). Not executed.

Godot / editors (this seat, not inherited from r105):

```
$ command -v godot ; godot --version ; echo godot_rc=$?
/usr/bin/godot
4.7.2.stable.arch_linux.ed1daf0bf
godot_rc=0
$ godot --headless --version ; echo headless_rc=$?
4.7.2.stable.arch_linux.ed1daf0bf
headless_rc=0
$ pacman -Q godot
godot 4.7.2-1
$ command -v unity Unity UnrealEditor UnrealEditor-Cmd ; echo ue_style_rc=$?
(no paths)
unity_rc=1 Unity_rc=1 ue_rc=1 uecmd_rc=1
$ pacman -Qq | grep -Ei '^(unity|unreal|godot)'
godot
```

Also missing: `$HOME/UnrealEngine`, `$HOME/Unity`, `$HOME/Unity/Hub`, `/opt/unreal-engine`, `/opt/Unity`, `/opt/unity`. No `/opt` or `/usr/share` name match for `unity|unreal`. This is a PATH-plus-package-plus-common-prefix probe, not a full-disk search. `command -v blender` is `/usr/bin/blender`; PROVINCE does not cite Blender, and this seat did not open a Blender census.

Node two-state, used only to resolve the REA command and the three.js module PROVINCE points at via the census:

```
$ command -v node ; node --version ; readlink -f "$(command -v node)"
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
$ /home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node --version
v24.21.0
```

`mise which node` → the same mise `latest` install. `mise ls node` shows `node 26.12.0` from `~/.config/mise/config.toml` as `latest`.

REA command, both states (`reports/round-106/scratch/seat20/rea-default.txt`, `rea-pinned.txt`):

```
$ npx -y rea-agents@6.4.0 --version    # default node v26.12.0, npx 11.20.0
6.4.0
rc=0
$ PATH="$FNM_BIN:$PATH" npx -y rea-agents@6.4.0 --version    # node v24.21.0, npx 11.19.0
6.4.0
rc=0
$ npm view rea-agents@6.4.0 version ; echo view640_rc=$?
6.4.0
view640_rc=0
$ npm view rea-agents version ; echo viewlatest_rc=$?
6.7.0
viewlatest_rc=0
$ command -v rea ; echo which_rea_rc=$?
which_rea_rc=1
```

`--help` on the default-node invocation printed `rea@6.4.0` and a command list (help pipe rc=0). That is package resolution, not an analysis run. No REA inspection was performed.

three.js, module resolution only (case runner not executed; C2 owns that rerun):

```
$ node -e "require.resolve('three')"                         # v26.12.0
Error: Cannot find module 'three'
def_root_rc=1
$ node -e "console.log(require.resolve('three',{paths:['corpus/fixtures/three']}))"
…/corpus/fixtures/three/node_modules/three/build/three.cjs
def_prefix_rc=0
```

The same split (root fail rc=1, prefix hit) occurred under pinned node v24.21.0. Installed and lockfile `three` version both `0.186.1`. `corpus/fixtures/three/run_cases.mjs` exists. PROVINCE's sentence "three.js runs under node … without a GL context" is still the right shape: the module resolves only under the fixture prefix, which is what `engines.md` already says. This seat did not re-run `run_cases.mjs`, so it does not re-certify the census "3/3" line.

`engines.md:11` still says the lockfile pin was taken under Node v26.11.1. Live default is v26.12.0. That row is out of chunk (C2). Not edited here.

## 4. Calibration of the checked SHONEN box

`SHONEN.md:4` is `[x]` and says `game-dev-3d-r2-review-retry` reproduced both battery commands, mutation rejection, and the contact-plane derivation, citing `corpus/lessons/r2-independent-review.md`, round 2. Boxes 1, 3, and 4 are `[ ]`. Box 4 is "No cross-domain bleed; PROVINCE remains accurate." This seat did not check or uncheck any box.

What still holds:

- The evidence file resolves and names that reviewer (2026-10-13T03:06:49Z, working tree `/home/vgpnk/Projects/prymeagnt/game-dev-3d`).
- `corpus/lessons/r1/clean-verdicts.json` resolves. It records `verdict=PASS`, `totals={'cases': 12, 'pass': 12, 'fail': 0, 'ordinary': 6, 'negative_controls': 6}`, `godot_version=4.7.2.stable.arch_linux.ed1daf0bf`, `seeds_unchanged=true`, 12 `seed_digests`. That matches the lesson's 12/12 and 6+6 counts as a historical r1 receipt, not as the current battery.
- Contact-plane constants in the live `body3d_slide.gd` still match the lesson's derivation (§2 S5). Its r1 digest is one of the 10 that still match.

What does not resolve, so the box cannot be re-verified from disk:

- Both commands the box says were reproduced fail from this root (rc=2) and only exist under the parent prefix.
- The three receipt paths were tested and are absent (`corpus/live/runs/20261013T030546459582Z` and `20261013T030602866163Z`, plus the mutation file under the second stamp). An early `ls corpus/live/runs | wc -l` printed 125; a close recount printed `entries=133 dirs=133 files=0`. Both stamps were still absent. The tree is moving because other seats write receipts. `corpus/.gitignore` ignores `live/`, so those r2 receipts were never durable tracked evidence.
- Embedded r1 paths `/tmp/mint-game-dev-3d/.shokunin/game-dev-3d/corpus/fixtures` and the matching scratch path: `test -e /tmp/mint-game-dev-3d` → `MISSING`.

Live seed digests versus the r1 map the lesson says the replay matched (sha256 of `corpus/fixtures/<name>` against `seed_digests`):

```
r1_digest_files 12
match=10 drift=2 absent=0 of 12
DRIFT README.md
  r1  c49da7523d507d5a56352bd40f549fd6b8679fad24a7032091d7c1a8b7e580e7
  now 347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1
DRIFT run_battery.py
  r1  303e4179e1e2238434a510031705b478380a4be576b3db8f9cf57b050bb5a59b
  now f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
```

That drift falsifies a *current-tree* reading of "replay digests match r1". It does not falsify the 2026-10-13 attestation, because the replay receipts that would show the then-current digests are gone. Dated note, not a silent uncheck.

`run_battery.py` current sha is the brief's pin. This seat did not re-run the 337/350 or 350/350 batteries. `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout` exists; citing its pass line would be a second-hand claim, so it is not used as this seat's result.

## 5. Queued mechanical notes (not applied)

Append-only. Do not rewrite the mint sentences. A later round that is allowed to touch these files can paste these; this seat must not.

### M1 — `PROVINCE.md` path root

```
## Correction note (r106, 2026-10-18)

The mint source line "corpus fixtures under .shokunin/game-dev-3d/corpus/" and the
write line "Only writes `.shokunin/game-dev-3d/**`" are parent-repo coordinates.
From this lane root that prefix does not exist (`os.path.exists(".shokunin")` False;
`glob.glob(".shokunin/game-dev-3d/**")` count 0). It resolves only when cwd is
`/home/vgpnk/Projects/prymeagnt/game-dev-3d`, where `.shokunin/game-dev-3d` is a
symlink to this repo (`readlink -f` → `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`;
PROVINCE.md inode 9813873 both ways). Lane-cwd twins: `corpus/`, `reports/`.
```

### M2 — `PROVINCE.md` REA pin

```
## Correction note (r106, 2026-10-18)

`npx -y rea-agents@6.4.0` still resolves: `--version` printed `6.4.0` rc=0 under
default node v26.12.0 (mise) and pinned node v24.21.0 (fnm bin
`/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin`). Left
verbatim. Registry `npm view rea-agents version` is `6.7.0`, which is also what
`~/.agents/skills/reverse-engineer-anything/SKILL.md` documents (5 hits at 6.7.0,
0 at 6.4.0). Same staleness is already noted in `corpus/knowledge/rea.md`
(r102 correction). No REA analysis was run.
```

`corpus/knowledge/rea.md` already carries the r102 dated note. PROVINCE does not. Do not bump the pin in place.

### M3 — `SHONEN.md` evidence pointer

```
## Correction note (r106, 2026-10-18)

Box 2's evidence file `corpus/lessons/r2-independent-review.md` still resolves,
and `body3d_slide.gd` still has the cited plane constants (2.5 / tick 21).
The two commands in that lesson fail from this lane root (python3 rc=2, Errno 2
on `.shokunin/game-dev-3d/corpus/fixtures/run_battery.py`). Their three receipt
paths under `corpus/live/runs/20261013T030546459582Z` and `20261013T030602866163Z`
are absent (`corpus/.gitignore` ignores `live/`). The box is a 2026-10-13
attestation, not a current re-run. Do not uncheck it in silence.
```

The lesson file itself is outside this seat. The same path-root defect is already catalogued for runnable commands in `reports/round-103/pathroot-sweep.md`. Not re-repaired here.

## 6. Judgment queue

**J1 — write-root contract.** M1 is the mechanical annotation. A ruling is needed only if the contract should *change* (lane cwd is the write root, parent prefix is historical) rather than stay as parent coordinates with a note. This seat does not change it. Observed fact: from the cwd this round uses, the written sentence's glob matches nothing.

**J2 — SHONEN box 2.** Two admissible readings. (A) Leave `[x]`: named non-author verifier, evidence file still present, past tense, receipts were gitignored live runs and were never durable. (B) A verifier who requires resolvable receipts marks `[~]` per `SHONEN.md:8-9`, because the commands do not run here and the receipts are gone. This seat recommends (A) plus M3, not a silent flip to `[ ]` or `[~]`. Box 4 stays `[ ]`. The path-root and stale-pin findings are reasons not to check "PROVINCE remains accurate" without the notes above.

No other judgment. Mint Godot / Unity-absent / Unreal-absent sentences were re-probed and still match. They are not defects.

## 7. Out of chunk

- `corpus/knowledge/engines.md` Node v26.11.1 versus live default v26.12.0. C2 census seat.
- Lesson path-root repairs. Not this chunk.
- `run_battery.py` / fixture README digest drift. Fixtures are protected. Recorded in §4 only.
- Battery 337/350 vs 350/350. Not re-run.
- Gate `POINTERS=103`. Not re-run.
- Upstream pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` appears in `engines.md`, not in these two files. Not re-fetched.

## 8. Not claimed

- No Unreal Editor, MCP listener, or engine runtime.
- No fresh battery pass, mutation probe, or three.js case run.
- No proof the predecessor commit object `4671a6b53dc4fbb878f477b2c2961305d1d9484c` exists upstream (local tree has no git object for it; GitHub not queried).
- No claim that Unity/Unreal are absent from every path on the machine — only from PATH, `pacman -Qq` name filter, and the prefixes listed in §3.
- No edit to `PROVINCE.md` or `SHONEN.md`.
