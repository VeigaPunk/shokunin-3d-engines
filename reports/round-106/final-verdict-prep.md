# SEAT-124 FINAL-VERDICT-PREP — r106

Axes named: **coverage** (every round claim has a row), **calibration** (a number is green only if this seat ran the counting command), **depth** (receipts re-parsed, not inherited from peer prose).

This file is the only write. No commit, push, checkout, or reset. Protected ledgers were not written.

**Not a freeze.** Peer seats were still editing `corpus/` through this seat's last probe. Counts below are stamped to the command that produced them. A claim whose artifact was still moving has **no green close command**. Re-run every NOT-GREEN row after writers stop before admitting the round.

HEAD throughout: `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`git rev-parse`, 2026-10-18T21:20:44Z and again 21:52:19Z). Work commit `3634bc0748f2ae1e02e20571874b39a3f3705daa` is an ancestor (`git merge-base --is-ancestor`, rc 0, 21:20).

Tags: **GREEN** = this seat ran the command and the observed value matches the claim. **NOT-GREEN** = command not run, command failed the claim, or the artifact moved after the count.

## Close flags

| claim | green? | why |
|---|---|---|
| C1 corpus-wide citation sweep, mechanical fixes landed | **NOT-GREEN** | no corpus-wide command-resolution count; `.shokunin/game-dev-3d` still in 54 files at 22:06:28Z; 49 corpus paths dirty vs HEAD at that stamp; sweep reports are 5 files, not a closed index |
| C2 engines.md census refresh, every row re-probed with durable receipts | **NOT-GREEN** | refresh exists in the worktree and the cells this seat re-probed agree, but this seat did not re-execute every row's fixture, and no r106 350-case battery receipt was found |
| C3 lesson sha/count consistency, receipts resolvable-or-dated-note | **NOT-GREEN** | slash-form `337/350` pairing was read once; no trustworthy corpus-wide sha-equality command; 181 `corpus/live/` citations do not resolve and dated-note coverage of them was not counted |

## Evidence table

### Key facts (brief)

| claim | counting command (this seat) | observed | stamp | green? |
|---|---|---|---|---|
| runner sha `f456bd00…` | `sha256sum corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | 21:20:44Z, rechecked 22:06:28Z | **GREEN** |
| CASES = 350 | AST: `Assign` target `CASES` is a list, `len(elts)` | `assigns [('CASES', 350, 39)]` | 21:21 | **GREEN** |
| default-env battery 337/350 | `json` load of `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json` | `verdict=FAIL` `seeds_unchanged=true` `totals={cases:350, pass:337, fail:13, ordinary:291, negative_controls:59}` | 21:21 parse; token split 22:01:39Z | **GREEN as a receipt fact. Not a fresh r106 run.** |
| those 13 fails are cannon marker mismatches under default node | same JSON, `results` where `verdict!=PASS` | 13/13 cases `r94_cannon_{det,det2,varstep,bailout,nan,sync,material,friction,parity,parity2,modes,order,backends}`; each `reasons=['exact stdout marker missing']`; stdout contains `node=v26.12.0` and not `node=v24.21.0`; marker contains `node=v24.21.0` | 22:01:39Z | **GREEN** |
| pinned-env battery 350/350 clean PASS | `json` load of `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`; `sha256sum`; `cmp -s` against `corpus/live/runs/20261018T204240718894Z/verdicts.json` | `verdict=PASS` `seeds_unchanged=true` `totals={cases:350, pass:350, fail:0, ordinary:291, negative_controls:59}` `seed_files=131` runner digest `f456bd00…1ef69f`; file sha `54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5`; `cmp` rc 0. 13 non-negative `r94_cannon_*` rows all carry `node=v24.21.0` | parse 21:21; token split 22:01:39Z | **GREEN as that receipt. Not a fresh r106 run.** |
| first pinned launch is not the accepted PASS | `json` load of `reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json` | `verdict=FAIL` `seeds_unchanged=false` `seed_files=130` row passes 350/350; sha `cca760d3f12d753e126adb759eeefc6923b6c5b80bab91893114c5e28bd5d0d5`. Stdout tail: `FAIL battery:` | 21:21 | **GREEN** (do not cite this file as the clean PASS) |
| r106 full battery re-run | `rglob *verdicts.json` under `reports/round-106` and keep files whose text contains `"cases": 350` | `receipts_with_350 0` | 21:41:02Z | **NOT-GREEN** for any claim that r106 re-ran the 350-case battery. Not re-scanned after 21:41 |
| gate PASS `POINTERS=103` | `GATE_WORKDIR=$HOME/.cache/r106-seat124/gate corpus/knowledge/unreal-mcp/gate/run_gate.sh`; rc file; script `sha256sum` | rc 0, stderr empty. `MANIFEST_OK=12 EXPECTED=12 FAILED=0`. `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297` `BLOB_DIFFS=0`. Census `static-only=12 unproven-runtime=1 verified-here=0`. `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`. `GATE RESULT: PASS (checks failed: 0)`. Script sha `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`. Transcript: `$HOME/.cache/r106-seat124/gate-run.stdout` | after 21:20:44Z (wall ~0.8s; clone of the 12-file pin) | **GREEN** |
| upstream pin | same gate stdout `PIN=` and `CLONE_HEAD=` | both `a6aa73ada02a9fb1f5415bec491f9942c519b297` | same | **GREEN** |
| no Unreal editor / no runtime claim from this seat | `command -v UnrealEditor`; `command -v UnrealEditor-Cmd`; `ss -ltn` `:8000`; gate CHECK 3 | all `command -v` rc 1; `port8000 0`; gate `verified-here=0`. This seat asserts no editor run | 21:44:51Z plus gate | **GREEN** for absence. Does not prove a peer report is free of a runtime sentence |
| default node v26.12.0 via mise | `node --version`; `command -v node` | `v26.12.0` `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node` | 21:20:44Z and 21:44:51Z (still v26 after the pinned probe) | **GREEN** |
| pinned node v24.21.0 via fnm | `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version` and `command -v node` | `v24.21.0` at that `bin/node` | 21:20:44Z | **GREEN** |
| node pin rows in the runner | `node=v24.21.0` count in `corpus/fixtures/run_battery.py` | 13 occurrences, no other `node=v*` string | 21:22 | **GREEN** |
| protected ledgers byte-identical to HEAD | `git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md` | rc 0 (`LEDGERS_CLEAN`) | 22:06:28Z | **GREEN** at that stamp. `SKILL.md` is clean *and* its engines stamp is stale — see C2 |

### C1 — coverage: corpus-wide citation sweep

Acceptance this seat used: every backtick repo-path in `corpus/**/*.md` except `unreal-mcp/upstream` resolves, every cited command was executed or queued, mechanical path fixes landed, judgment defects queued, historical facts kept behind dated notes.

| subclaim | command | observed | stamp | green? |
|---|---|---|---|---|
| path citations that exist | python: backtick tokens normalized to `corpus/…` or `reports/…` (line suffix stripped; globs/braces skipped); `Path.exists()` | `CORPUS_MD=227` `PATH_OK=783` `MISSING_LIVE=181` `MISSING_OTHER=10` | ~21:44 | partial count only |
| the 10 non-live misses | same run, unique list | 8 were `reports/round-106/sweep/chunk-05.md` from lessons r61–r68; 2 were ellipsis examples `corpus/…` and `reports/…` in `corpus/knowledge/unreal-mcp/gate/README.md:239` | ~21:44 | the chunk-05 eight were a real miss **then** |
| chunk-05 later landed | `test -f reports/round-106/sweep/chunk-05.md`; python recount of cites | file present (10862 bytes at 22:06:28Z); 8 cites, `all_exist True` | 22:01:39Z present; 22:06:28Z cites resolve | **the dangling cite cleared**. Not a current defect. It was a race: lessons cited the report before the report existed |
| old parent-repo prefix still present | python substring `.shokunin/game-dev-3d` in corpus md excl. upstream and `node_modules` | `SHOK_FILES=54` `SHOK_LINES=296` | 22:06:28Z | **NOT-GREEN** as "mechanical path fixes landed". The count includes notes that quote the old path; it is not a count of still-broken commands. An earlier `rg -l` at 21:52:19Z was 75 files / a line-sum of 265 — different tool, do not diff the two numbers |
| sweep reports closed | `find reports/round-106/sweep -maxdepth 1 -name '*.md'` | `chunk-05.md` `chunk-13.md` `hygiene.md` `lesson-integrity.md` `province-audit.md` | 22:06:28Z | **NOT-GREEN**. Five files, no index this seat could check against an expected chunk set. Command resolution (run each cited command) was **not** done corpus-wide |
| fixes landed vs still in flight | `git diff --name-only HEAD -- corpus \| wc -l` | 49 paths, including `corpus/knowledge/engines.md`, `corpus/knowledge/rea.md`, `corpus/README.md`, and lessons. `git diff --stat` on engines.md at that stamp: `147 insertions, 5 deletions` | 22:06:28Z | **NOT-GREEN** for "landed". Worktree only; writers had not stopped |

Judgment defects this seat queues, does not fix (not this chunk):

- Any remaining `.shokunin/game-dev-3d` command that is not inside a dated note still fails from this repo root. This seat did not separate note-quotes from live commands.
- Eight r61–r68 notes pointed at `reports/round-106/sweep/chunk-05.md` before that file existed (observed missing at 21:52:19Z, present at 22:01:39Z). Re-check the cite after the sweep seat stops editing the note.

### C2 — depth: engines.md census refresh

`corpus/knowledge/engines.md` was clean at HEAD sha `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` at 21:20 (`git diff --quiet`, and that sha). It then moved under another seat: `149e61cf…` (21:44), `055ea7df…` 158 lines (22:06), **`501b30df1ca3ffc3b4d9239b80ec1ec633c3886188f63412bea0d7f77d21f933` 166 lines at 22:11:41Z**. That last sha is the one this table judges. If `sha256sum corpus/knowledge/engines.md` differs now, this C2 section is stale.

At 22:11:41Z the file has **5** data rows (header excluded): Godot 4.7.2 `yes`/`yes`; Unity Editor `no`/`no`; Unreal Engine `no`/`no`; three.js 0.186.1 / `partial`; Blender 5.2.1 LTS / `partial`. The two-state table still says default 337/350 and pinned 350/350 parsed-not-rerun, which matches this seat's receipt parses above. Dated note keeps historical `Node v26.11.1`. A Blender row was added; its headless cell is `partial`, not `yes`.

| row | this seat's command | observed | agrees with engines.md cell? | green for "re-probed"? |
|---|---|---|---|---|
| node two-state | `node --version` / fnm `PATH` prefix | `v26.12.0` mise; `v24.21.0` fnm; default unchanged after prefix | yes, against the 22:11 text | **GREEN** for the version strings. Node binary shas in the file (`caa24debe0…`, `7fde7b8a…`) were **not** re-hashed by this seat |
| Godot | `command -v godot`; `godot --version` | `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` | version string agrees | **partial**. This seat did not re-run `phys3d_joints_free_ops`. The cited receipt `reports/round-106/scratch/seat38/20261018T213322137930Z/verdicts.json` was not parsed (an earlier attempt to parse it was not completed before the file moved) |
| Unity | `command -v unity` | rc 1 | `installed=no` agrees | **partial**. Static `verify_scene.py` was not re-run |
| Unreal | `command -v UnrealEditor` / `UnrealEditor-Cmd`; `ss -ltn`; this seat's gate | absent; port 8000 count 0; gate PASS `verified-here=0` `POINTERS=103` | absence and gate summary agree | **GREEN** for absence + this seat's gate. Descriptor checker and manifest `sha256sum -c` were not re-run outside the gate |
| three.js | `node corpus/fixtures/three/run_cases.mjs --receipt $HOME/.cache/r106-seat124/three-default.json` and the same under the fnm PATH | both rc 0, `PASS three battery: 3/3, seeds_unchanged=true`. Receipts: default node `v26.12.0` three `0.186.1` verdict PASS seeds true, sha `1668bb85c370d6bdfd578981f61a64d78a5cb17bb8ff5f89250aa9f712120611`; pinned node `v24.21.0` three `0.186.1` verdict PASS seeds true, sha `46bb981a37fd6d1ecfdfd38ebe7fabf8be2b64144fe0140b932a74792f4ddfcd`. Lockfile `node_modules/three` version `0.186.1` | `partial` and pin `0.186.1` agree. File also claims `run_camera_cases.mjs` 5/5 both states | **partial**. Camera runner and `npm ci` were **not** run. Do not treat the camera claim as green from this seat |
| Blender 5.2.1 LTS | `command -v blender`; `blender --version` | `/usr/bin/blender`; `Blender 5.2.1 LTS`; rc 0 | version string agrees; headless cell says `partial` via `blender -b` | **NOT-GREEN** for the headless cell. `blender -b` was not run |

`SKILL.md:184` still stamps engines.md at `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` (`rg -n`, 21:52:19Z). `git diff --quiet HEAD -- SKILL.md` was rc 0 at 22:06:28Z, so the stamp was not updated. The live file at 22:11:41Z is `501b30df…`. **NOT-GREEN** to cite the SKILL stamp as the current census bytes. `SKILL.md` is protected this round; the defect is queued, not fixed. engines.md itself already says the stamp is stale — that sentence was true of `d03907d3` vs whatever sha the census seat had written; re-hash before acting.

No r106 350-case receipt at 21:41:02Z. engines.md correctly labels the 337/350 and 350/350 figures as parsed, not re-run. A claim that r106 re-ran the full battery has **no green command**.

### C3 — calibration: lesson numbers and digests

| subclaim | command | observed | stamp | green? |
|---|---|---|---|---|
| `337/350` paired with an environment | python scan of `corpus/lessons/*.md` for `337/350` `350/350` `336/350`, then Read of the hits | 2 hits, both in `corpus/lessons/r105-unreal-lifecycle.md` (then lines 133 and 137). Line 133 says the 337/350 is the default environment, mise Node v26.12.0, not the pinned total. Line 137 is `Environment pairing (r106, 2026-10-18)` and names the r104 receipt and the clean pinned receipt. `350/350` slash-form count 0; `336/350` count 0 | scan ~21:44; Read of those lines after the edit | **GREEN for those two lines at that read**. The lesson is dirty and has moved since. Not re-scanned at 22:11. Not a corpus-wide close |
| quoted sha256 equals the named live file | naive same-line join of every 64-hex token to every backtick path on that line | `SHA_PATH_CHECKS=143` `MISMATCH=141` | ~21:44 | **NOT a green command**. It compares unrelated hashes on the same line (README.md vs several digests). Do not cite 141 as a defect count |
| a trustworthy sha-equality pass | — | not run | — | **NOT-GREEN**. No command this seat trusts says "quoted shas match the live tree" |
| receipt citations resolve or carry a dated note | path counter above | 181 `corpus/live/…` backtick paths missing. `corpus/.gitignore:1` is `live/` (`rg -n '^live/'`) | ~21:44 | **NOT-GREEN**. Missing is established. Dated-note coverage of those 181 was not counted, so "resolvable-or-dated-note" is not passed |

## What must not be admitted from this frame

- C1 as closed. Sweep chunk set is incomplete; old-root string still widespread; corpus diff still open at 22:06:28Z.
- C2 as "every row re-probed by an independent counter." Version/absence cells this seat ran agree with engines.md sha `501b30df…` at 22:11:41Z. Camera 5/5, `blender -b`, Unity/Unreal static checkers, the phys3d bounded row, and both full batteries were not re-executed here.
- C3 as digest-consistent. Only the two `337/350` lines were checked by reading them. The sha matcher is invalid. Live receipts are absent and note coverage is uncounted.
- The first pinned launch (`cca760d3…`, `seeds_unchanged=false`) as the 350/350 PASS. The accepted receipt is `54b7140d…`.
- `SKILL.md:184` engines stamp `d03907d3…` as the current census hash.
- Any Unreal editor or live-MCP result. This seat's gate is a static byte/pointer gate. `verified-here=0`.

## Re-count before close

```sh
sha256sum corpus/knowledge/engines.md corpus/fixtures/run_battery.py
git diff --name-only HEAD -- corpus
git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md
# C1: remaining old-root cites, and whether sweep/chunk-*.md cites resolve
# C2: if engines.md sha != 501b30df1ca3ffc3b4d9239b80ec1ec633c3886188f63412bea0d7f77d21f933, re-read the rows
# C3: do not reuse the same-line sha join
```
