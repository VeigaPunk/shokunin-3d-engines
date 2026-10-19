# SEAT-61 CONSISTENCY — r106

**Owned path:** `reports/round-106/consistency.md` only. No other path was written. No commit, push, checkout, or reset.
**Charge:** every open item in the r101–r105 reports and their LOG routed queues is either addressed this round or carried with a pointer. Nothing is dropped.
**Frame:** probes `2026-10-18T21:21:10Z`–`2026-10-18T21:40:08Z`. Lane HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`, r105 report-last; work `3634bc0`) throughout. At `21:21:10Z`, `git status --short` excluding `reports/round-106/` was empty. At `21:40:08Z` nine `corpus/lessons/` files were dirty. Those diffs are peer edits. This seat did not write them. `git diff --name-only HEAD` on fixtures, the unreal-mcp tree, `engines.md`, and the four root ledgers was still empty at `21:40:08Z`.
**Boundary:** no SHONEN box was checked. No Unreal Editor or Unreal runtime claim is made. A static gate receipt is not editor evidence.

**Disposition words.** `CLOSED (historical)` means a prior round recorded the close; this seat does not upgrade that record into a new r106 verification. `CLOSED (reconfirmed)` means a command in the log below shows the surviving fact still holds. `CARRY` means unresolved; the pointer is an r106 artifact when one names the item, otherwise this file. `PARTIAL / CARRY` means a named subpart is closed and a named residual remains. Peer receipts are labeled peer. This seat did not run the gate or the battery.

## Accounting

r105 consistency counted r101–r104 as 15+16+22+15 = **68** (`reports/round-105/consistency.md:13-19`). That arithmetic is kept. r105 has no numbered open-item section of its own. Its close still left five LOG routed items (`LOG.md:1456-1459`) and five further sentences that would drop if only the LOG line were copied: the moving-hash review limit (`reports/round-105/r105-report.md:200`), the `mode_ok` guard (`reports/round-105/r105-dissonance.md:48`), the unruled lesson-scope question on bytes the critics did not review, the template-wording claim, and the disclosed non-final index row for the pinned rerun stdout. Those ten are r105 O1–O5 and R1–R5 below.

r104 consistency's prose said 51 for a table that summed to 53. r105 consistency recorded the correction (`reports/round-105/consistency.md:11`). Not reopened.

| Source | Numbered | Routed | Total |
|---|---:|---:|---:|
| r101 | 6 | 9 | 15 |
| r102 | 8 | 8 | 16 |
| r103 | 12 | 10 | 22 |
| r104 | 15 | 0 | 15 |
| r105 | 5 | 5 | 10 |
| **Total** | **46** | **32** | **78** |

**Addressed this round: 0.** No r101–r105 item changed from open to closed because of an r106 source edit in the fixture, gate, engines, or ledger trees — those diffs were empty at `21:40:08Z`. One peer dated note landed in the worktree copy of `corpus/lessons/r105-unreal-lifecycle.md` (environment pairing of 337/350 vs 350/350). That note does not close the default-path residual. It is recorded under r102 R6, not counted as a close.

## r101 — 15

Source items: `reports/round-101/r101-report.md:285-310`. Routed queue: `LOG.md:1318-1323`. Prior register: `reports/round-105/consistency.md:21-41`.

| ID | Item | r106 disposition and evidence |
|---|---|---|
| r101 O1 | Pre-landing hash and moving close counts | **CLOSED (historical, reconfirmed).** `git log -1 --oneline 1659c03` → `1659c03 r101: vendor EpicGames unreal-engine-skills plugin @ a6aa73ad …`. `grep -c 'ROUND 101' LOG.md` → 1. `grep -c 'Round 101' SCORECARD.md` → 1. |
| r101 O2 | Pointer-checker self-contaminates on protocol negative controls | **CLOSED (historical; scratch not re-run).** Pointer: `reports/round-105/consistency.md:28`. |
| r101 O3 | Stale `(pending: …)` layout labels | **CLOSED (reconfirmed).** `grep -n pending corpus/knowledge/unreal-mcp/README.md` → one hit, line 69, the Epic-account wall, not the layout labels. |
| r101 O4 | C1 scope: all upstream content versus the pinned commit | **CLOSED (historical ruling).** Not re-read this seat. Pointer: `reports/round-105/consistency.md:30`. |
| r101 O5 | `verified-here` adaptation rows are Kimi-side, not Unreal-side | **CARRY (boundary).** `SKILL.md:47` still separates the row-D probe sense from the card sense. This seat makes no Unreal runtime claim. |
| r101 O6 | No live-editor evidence on this host | **CARRY (structural).** `command -v UnrealEditor UnrealEditor-Cmd UnrealBuildTool` printed no path. `ls /opt/UnrealEngine` → `No such file or directory`. Peer: `reports/round-106/engine-count.md:15`, `reports/round-106/gate/final-run.md:22`. |
| r101 R1 | r22 README/lesson path drift | **CLOSED (historical).** Peer r106 re-ran the descriptor pair and recorded both arms exit 0 (`reports/round-106/r22-regression.md:11`). This seat did not re-run it. |
| r101 R2 | r22 lesson cites absent `verdicts.json` | **CLOSED (historical).** Pointer: `reports/round-105/consistency.md:34`. |
| r101 R3 | `run_battery.py` cited-SHA drift | **CLOSED (reconfirmed).** `sha256sum corpus/fixtures/run_battery.py` → `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. |
| r101 R4 | `engines.md` three.js command fails from a clean tree | **CLOSED (historical).** `git diff --name-only HEAD -- corpus/knowledge/engines.md` was empty at `21:40:08Z`. The command was not re-executed. The stale `Node v26.11.1` parenthetical is a separate census queue (`reports/round-106/engine-count.md:18`), not a reopen of this command-failure item. |
| r101 R5 | `rea.md` JADX/Binwalk/Unblob census | **CLOSED (historical).** Pointer: `reports/round-105/consistency.md:37`. |
| r101 R6 | README glob line-count (F8) | **CLOSED (historical).** Pointer: `reports/round-105/consistency.md:38`. |
| r101 R7 | IP-2: digest map omits `corpus/knowledge/` and gate files | **CARRY.** Read-only rglob mirror of `seed_digests()`: `entries=131 knowledge=0 gate=0`. The count moved 130→131 because `PINNED-ENV.md` is now under `corpus/fixtures`; knowledge and gate are still zero. `grep -l run_gate corpus/fixtures/*.py corpus/knowledge/engines.md` → `NO_HARNESS_REFS`. |
| r101 R8 | Sentinel S-5: PATH-shadowed `basename` | **CLOSED (historical).** Not re-probed. Pointer: `reports/round-105/consistency.md:40`. |
| r101 R9 | Sentinel S-8: `.mcp.json` auto-load | **CARRY (not rechecked).** No r106 carrier. Pointer: `reports/round-105/consistency.md:41` and this row. |

## r102 — 16

Source items: `reports/round-102/r102-report.md:351-395`. Routed queue: `LOG.md:1349-1358`. Prior register: `reports/round-105/consistency.md:43-64`.

| ID | Item | r106 disposition and evidence |
|---|---|---|
| r102 O1 | Pre-landing hash and missing LOG/SCORECARD entry | **CLOSED (historical, reconfirmed).** `git log -1 --oneline c6f655d` → `c6f655d r102: close-out gate …`. `grep -c 'ROUND 102' LOG.md` → 1. `grep -c 'Round 102' SCORECARD.md` → 1. |
| r102 O2 | F7 / P-C label-vocabulary collision | **CARRY (unruled).** Six dissent files still match `Not \`unproven-runtime\``: `animation-controlrig.md`, `blueprints.md`, `editor-general.md`, `gameplay-gas.md`, `materials.md`, `meshes-textures.md`. `sha256sum corpus/knowledge/unreal-mcp/README.md` → `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`. The r105 package is still a proposal (`reports/round-105/operator-package.md:5-11`). No r106 ruling file was in the non-scratch report list at `21:28:18Z`. |
| r102 O3 | Gate missed range-form pointer endpoints | **CLOSED (historical).** Peer clean gate records `POINTERS=103` `UNRESOLVED=0` (`reports/round-106/gate/final-run.md:79`). This seat did not run the gate. |
| r102 O4 | No gate receipt or standing harness integration | **CARRY.** Same probe as r101 R7. `reports/round-106/gate/final-run.md` is a hand transcript of one invocation, not a `--receipt` flag or a battery hook. |
| r102 O5 | Gate requires network and cannot complete offline | **CLOSED as an explicit blocked state, not offline support.** Peer N1 (dead `REPO`, no `GATE_REF`) recorded `RC=2` and `CHECK 2 BLOCKED (network)` (`reports/round-106/gate/blocked-check.md:25`). This seat did not run it. No offline PASS is claimed. |
| r102 O6 | Two math-audit discrepancies: node_modules count and stale F3 frame | **PARTIAL / CARRY.** `find corpus/fixtures/three/node_modules -type f` → 1264. Live `reports/round-102/adversary/F3.md` is `7d37c5f5eaa71eff691474e99f09c891447f6268d81ae4abcf53b1a08baee0b3`, 11702 bytes. Index §1 still prints `11028` / `6a2d297a3379dd7d` (`reports/round-102/reports-index.md:30`). Line 333 records both frames. `reports/round-102/**` is protected this round; not rewritten. |
| r102 O7 | No live-editor evidence | **CARRY (structural).** Same probe as r101 O6. |
| r102 O8 | F3/F5/F6 await L1 accept/overrule | **CARRY (unruled).** No r106 accept/overrule file. Pointer: `reports/round-105/consistency.md:56` and this row. |
| r102 R1 | Fold A1: range-tail-blind regex | **CLOSED (historical).** Same peer pointer as O3. |
| r102 R2 | Fold A2: prose-hijackable first-token rule | **CLOSED (historical).** Not re-attacked. Pointer: `reports/round-105/consistency.md:58`. |
| r102 R3 | Fold A3: card names were not compared | **CLOSED (historical).** Peer clean gate printed `NAME_SET=OK NAME_BAD=0` (`reports/round-106/gate/final-run.md:75`). This seat did not run the gate. |
| r102 R4 | Fold A4: distinguish network block from byte mismatch | **CLOSED (historical).** Peer N1 is `BLOCKED`/`RC=2`; peer N2 (bad `GATE_REF`) is `FAIL`/`RC=1` and not BLOCKED (`reports/round-106/gate/blocked-check.md:23-26`). This seat did not run either path. |
| r102 R5 | Kimi-surface freshness note for `adaptation-kimi.md` | **CLOSED (reconfirmed).** `sed -n '6p'` shows the `-plugin` URL. `curl -sI --max-time 15` → `plugin=200`, `old=404`. |
| r102 R6 | Battery Node marker drift (`r94_cannon`) | **PARTIAL / CARRY (default path still mismatched).** `node --version` → `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`. Prefixed fnm binary → `v24.21.0`. `grep -c v24.21.0 corpus/fixtures/run_battery.py` → 13. Peer default spot check fails `r94_cannon_nan` on the token (`reports/round-106/battery-default-quick.md:11`). Peer pinned row `r94_cannon_det` PASSes (`reports/round-106/census/cannon.md:5`, `reports/round-106/census/n24-state.md:5`). This seat tailed the r105 pinned rerun stdout: `totals: cases=350 pass=350 fail=0` and `PASS battery`. It did not rerun the battery. A peer dated note in the dirty worktree lesson pairs 337/350 (default) with 350/350 (pinned); that is a clarification, not a close. |
| r102 R7 | B2 dead `.shokunin` root in three READMEs | **CLOSED for the three-file repair; CARRY for the systemic ruling.** Peer r106 recorded both chosen README commands exit 0 (`reports/round-106/glb-unity-regression.md:9`). `git grep -l '\.shokunin/game-dev-3d'` → 295 (reports 202, corpus 90, plus `LOG.md`, `SCORECARD.md`, `PROVINCE.md`). No L1 accept/overrule of R4. |
| r102 R8 | Math-audit two wrong rows | **PARTIAL / CARRY.** Same split as O6. |

## r103 — 22

Source items: `reports/round-103/r103-report.md:413-468`. Routed queue: `LOG.md:1385-1392`. Prior register: `reports/round-105/consistency.md:66-93`.

| ID | Item | r106 disposition and evidence |
|---|---|---|
| r103 O1 | Pre-landing hash and missing LOG/SCORECARD entry | **CLOSED (historical, reconfirmed).** `git log -1 --oneline 8c9d9ad` → `8c9d9ad r103: gate hardening A1-A4 …`. `grep -c 'ROUND 103' LOG.md` → 1. `grep -c 'Round 103' SCORECARD.md` → 1. |
| r103 O2 | README contradicted gate exit semantics | **PARTIAL / CARRY.** The residual sentence is still present: `corpus/knowledge/unreal-mcp/gate/README.md:292` says there is no partial-pass state under exit `1`. The original two-line fix is historical (`reports/round-105/consistency.md:73`). This seat did not re-grep the old `exits 1` lines. |
| r103 O3 | Mixed `BLOCKED` plus `FAIL` loses the blocked state | **CARRY (open in code).** `sed -n '420,442p' corpus/knowledge/unreal-mcp/gate/run_gate.sh` shows `exit 2` only when `C2_BLOCKED=1` and `FAILS=0`; otherwise exit `1`. Peer blocked-check ran the two pure paths, not the mix (`reports/round-106/gate/blocked-check.md:12-16`). |
| r103 O4 | Conflicting pointer totals in README | **PARTIAL / CARRY.** README still states `POINTERS=103` and attributes that pin to scanner `e5521304…` (grep hits at lines 42, 248, 283, 440). Live `sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`. Numeric pin matches the peer clean receipt; provenance does not. |
| r103 O5 | Full attack suite not run against r103 final bytes | **CLOSED historically for `e5521304…`, not a current-SHA certification.** Pointer: `reports/round-105/consistency.md:76`. Current SHA is r104 O10. |
| r103 O6 | B2 systemic `.shokunin` scope ruling (R4) | **CARRY (unruled).** Same count as r102 R7. No r106 ruling. |
| r103 O7 | `phys3d_joints_free_ops` timeout classified but not repaired | **CLOSED (historical r104 fix; peer r106 re-ran the row).** Fixture sha `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6`. `CASE_TIMEOUT_SECONDS = 20` at `corpus/fixtures/run_battery.py:36`. Peer default-env row PASS: `reports/round-106/census/phys3d-joints.md:14` and `reports/round-106/battery-default-quick.md:12`. This seat did not run the row. |
| r103 O8 | Node-marker drift for `r94_cannon_*` rows | **PARTIAL / CARRY.** Same residual as r102 R6. |
| r103 O9 | Tracked Kimi URL returns 404 | **CLOSED (reconfirmed).** Same curl as r102 R5: plugin URL `200`, old URL `404`. |
| r103 O10 | Control section says C1–C6; C7 command absent | **CARRY.** `corpus/knowledge/unreal-mcp/gate/README.md:307` still says `C1–C6, plus C7 where listed`. `awk` over fenced `sh` blocks: `C7` count `0`. |
| r103 O11 | `--path .` can write scratch beneath seed fixtures | **CARRY (no guard).** `corpus/fixtures/phys3d_joints.gd:135-136` still builds `r90bt_*` under `res://`. `ls -d corpus/fixtures/r90bt_*` → 0 this frame. Absence is not a guard. |
| r103 O12 | No live-editor evidence | **CARRY (structural).** Same probe as r101 O6. |
| r103 Q1 | Physics fix R3: concurrent children | **CLOSED (historical).** Same evidence as O7. |
| r103 Q2 | R1 global timeout increase 20→60 | **NOT ADOPTED; superseded by R3.** `CASE_TIMEOUT_SECONDS` is still 20 (`run_battery.py:36`). |
| r103 Q3 | R2 proportional per-case timeout | **NOT ADOPTED; superseded by R3.** No r106 change to the runner (`sha256sum` unchanged; protected diff empty). |
| r103 Q4 | R4 re-baseline the marker | **NOT ADOPTED.** `grep -c v24.21.0 corpus/fixtures/run_battery.py` → 13. |
| r103 Q5 | Gate workdir resilience (`GATE_WORKDIR`/`TMPDIR`) | **CLOSED (historical; peer re-exercised).** `grep -c GATE_WORKDIR corpus/knowledge/unreal-mcp/gate/run_gate.sh` → 13. Peer clean run set `GATE_WORKDIR` and recorded rc 0 (`reports/round-106/gate/final-run.md:15-18`). This seat did not run the gate. |
| r103 Q6 | Flake-reproduction harness | **CLOSED (historical).** Pointer: `reports/round-105/consistency.md:89`. The r106 gate transcript does not replace that harness. |
| r103 Q7 | Stray `r90bt_*` dirs / write-isolation proposal | **CARRY (no guard).** Same as O11. Second sighting is the r105 routed item R2. |
| r103 Q8 | Kimi URL 404 | **CLOSED (reconfirmed).** Same as O9. |
| r103 Q9 | Empty jolt cells match the pinned marker; cause unexplained | **CARRY (unexplained).** No r106 investigation report. `reports/round-106/r106-scribe-audit.md:79` uses `jolt` as an empty directory name at `18:22:39`. That is not this curiosity. |
| r103 Q10 | Battery cannon Node markers | **PARTIAL / CARRY.** Same residual as r102 R6. |

## r104 — 15

Source: `reports/round-104/r104-report.md:570-651`. Close-out: `:695-750`. Prior register: `reports/round-105/consistency.md:95-115`.

| ID | Item | r106 disposition and evidence |
|---|---|---|
| r104 O1 | Pre-landing hash; LOG/SCORECARD r104 entries absent | **CLOSED (historical, reconfirmed).** `git log -1 --oneline 2ca87e8` → `2ca87e8 r104: phys3d_joints concurrent child batch …`. `grep -c 'ROUND 104' LOG.md` → 1. `grep -c 'Round 104' SCORECARD.md` → 1. Current HEAD is the later r105 report-last commit. |
| r104 O2 | C1 fix, full battery 337/13, non-author reproduction | **CLOSED for the r104 claim.** Peer r106 free_ops PASS is a later spot check, not a new 350-row recount (`reports/round-106/census/phys3d-joints.md:14`). The pinned 350/350 receipt is the r105 rerun this seat tailed, not an r106 full run. |
| r104 O3 | Workdir knob; residual partial-pass text and TMPDIR ruling | **PARTIAL / CARRY.** `GATE_WORKDIR` still present (count 13) and the peer clean run used it. Residual README sentence: line 292. No r106 ruling that `TMPDIR` alone suffices. |
| r104 O4 | `BLOCKED (network)` mislabel | **CLOSED (historical; peer re-exercised the network branch).** `reports/round-106/gate/blocked-check.md:25`. This seat did not run it. |
| r104 O5 | Mixed `BLOCKED+FAIL` loses the third state | **CARRY.** Same code read as r103 O3. |
| r104 O6 | Gate cannot scan root `SKILL.md` | **PARTIAL / CARRY (unruled).** `corpus/knowledge/unreal-mcp/gate/run_gate.sh:86` sets `SUB` to the parent of `gate/`. Peer clean run prints `SUBTREE=…/corpus/knowledge/unreal-mcp` (`reports/round-106/gate/final-run.md:28`). `SKILL.md` is outside that root. No scan-scope ruling. |
| r104 O7 | C3 author receipt still needs a named non-author verifier | **CARRY.** `grep -n '^- \[' SHONEN.md` shows box 1 still `- [ ]` and only box 2 checked. This seat did not check a box. |
| r104 O8 | P/C precedence ruling | **CARRY (no ruling).** Same evidence as r102 O2. `reports/round-105/operator-package.md` is the decision draft, not an applied ruling. |
| r104 O9 | Decide whether `SKILL.md` is inside gate scope | **CARRY (unruled).** Same design question as O6, counted separately because r104 numbered it separately. |
| r104 O10 | Full attack suite bound to final gate bytes | **CARRY (not verified at `390a25ae…`).** Live script sha is `390a25ae…`. `find reports/round-106 -name '*attack*' -o -name '*regression.md'` returned only `r22-regression.md` and `glb-unity-regression.md`. Those are not the gate attack suite. Peer `gate/final-run.md` is a clean path. |
| r104 O11 | Consolidate every suite on one final gate revision | **CARRY (partial consolidation only).** Peer clean run and peer N1/N2 cite the same `390a25ae…` (`reports/round-106/gate/blocked-check.md:8`). The full attack suite is still unbound. |
| r104 O12 | Thirteen `r94_cannon_*` marker failures on default Node | **PARTIAL / CARRY.** Same residual as r102 R6. Peer default spot check matches the class; it is not a 337/350 recount (`reports/round-106/battery-default-quick.md:14`). |
| r104 O13 | `--path .` fixture-write hazard | **CARRY (no guard).** Same as r103 O11. |
| r104 O14 | Repo-root scratch dirs; convention needed | **PARTIAL / CARRY.** `ls -d .r10* .r104*` → `NO_ROOT_SCRATCH_GLOBS` this frame. A quiet snapshot is not a convention. r106 practice, not a standing rule, is `reports/round-106/scratch/` (scribe-audit counted scratch as the bulk of the moving tree). |
| r104 O15 | No live-editor evidence | **CARRY (structural).** Same probe as r101 O6. |

## r105 — 10

r105's report has no numbered open-item list. These ten are the close sentences that would otherwise drop. R1–R5 are the LOG routed queue (`LOG.md:1456-1459`). O1–O5 are the honest-limit, dissonance, and receipt-identity sentences.

| ID | Item | r106 disposition and evidence |
|---|---|---|
| r105 R1 | P/C operator ruling | **CARRY (package not applied).** README sha unchanged (`c79d8dd1…`). Six dissent files remain. `reports/round-105/operator-package.md:11` still says proposed, not ready to apply. No r106 `pc/` ruling file at `21:28:18Z`. |
| r105 R2 | Fixture write-isolation (second sighting) | **CARRY (no guard).** `phys3d_joints.gd:135-136` still creates `r90bt_*` under `res://`. Live count 0. |
| r105 R3 | Row-F non-author replay precedent | **CARRY (standing rule, in force; not a new 350-row replay).** `SKILL.md:49` requires a named non-author replay for a row-F `verified-here`. r106 peers published single-row receipts (`census/phys3d-joints.md`, `census/cannon.md`, `battery-default-quick.md`). This seat does not treat those as a new full-battery non-author run. |
| r105 R4 | Empty-jolt-cells curiosity | **CARRY (unexplained).** Same as r103 Q9. |
| r105 R5 | Operator L0 package | **CARRY (unchanged, operator-owned).** `reports/round-105/operator-package.md:28-34` still lists Epic-account link, the unverified container image, and Lutris. Peer engine census: Unreal `installed=no` (`reports/round-106/engine-count.md:15`). |
| r105 O1 | Reviews scored against moving proposal hashes | **CARRY.** The limit is `reports/round-105/r105-report.md:200`. No r106 same-hash P/C review was in the non-scratch markdown list at `21:28:18Z`. |
| r105 O2 | `mode_ok` guard never landed | **CARRY (still unimplemented).** `phys3d_joints.gd:119-120` prints `PASS` then `quit(0)`. `mode_ok` is appended into `_parts` at lines 202-204 and is not checked before that quit. Named in `reports/round-105/r105-dissonance.md:48`. No r106 fix; fixture diff vs HEAD was empty. |
| r105 O3 | Lesson semantic-bleed ruling does not transfer to landed bytes | **CARRY.** At `21:21:10Z`, with a clean worktree, `sha256sum corpus/lessons/r105-unreal-lifecycle.md` → `c7f6a27f0cc71b56bff875a1ffdd3c1c32761d7bf00ba9f48ef8351942d82729`, 162 lines. Critic targets cited by r105 dissonance (`dd9b9ac0…`, `d089aae7…`) match neither that sha nor the later worktree sha. No r106 bleed review was found. The worktree edit below is an environment note, not a scope ruling. |
| r105 O4 | "templates now say no checkout anywhere" | **CARRY (not verified in a living template).** `reports/round-105/r105-report.md:202` states the templates now say it. `LOG.md:1462` says future templates should say it. A content search for the exact phrase found those two lines, this file, and a scratch copy of the LOG line (`reports/round-106/scratch/seat102/log-routed.txt`). No corpus file and no root instruction file contained it. External templates were not searched. An earlier shell `rg` that printed no hits is withdrawn; it did not list `LOG.md`. |
| r105 O5 | r105 reports-index rerun-stdout row is a mid-write frame | **CLOSED (disclosed; do not cite the partial).** Peer `reports/round-106/r105-receipt-carry.md:36-39` records the index row `7f76f1d7…` / 10377 bytes as the index's own non-final frame, and `n24/receipts.md` as the post-close identity. This seat tailed the landed stdout and observed the terminal `PASS battery` line. The index is protected; not rewritten here. |

## Worktree move inside this window

At `21:40:08Z`, `git status --short` excluding `reports/round-106/` was no longer empty:

```text
 M corpus/lessons/r105-unreal-lifecycle.md
 M corpus/lessons/r61-stream-review.md
 M corpus/lessons/r62-three-ortho-near-review.md
 M corpus/lessons/r63-three-ray-review.md
 M corpus/lessons/r64-ray-side-review.md
 M corpus/lessons/r65-ray-order-review.md
 M corpus/lessons/r66-ray-range-review.md
 M corpus/lessons/r67-ray-boundary-review.md
 M corpus/lessons/r68-ray-layers-review.md
```

`git diff --stat -- corpus/lessons/` → 9 files, 55 insertions, 35 deletions. The lifecycle diff is `13 1`: a dated **Environment pairing (r106, 2026-10-18)** note. It keeps the 337/350 sentence and states that figure is the default-environment total (mise `v26.12.0`), not the pinned fnm `v24.21.0` 350/350. Worktree sha at `21:40:08Z`: `c4aa80ec883e5118017bd6f3953e2c881bdaa0024c79e2a048189c85b450304c`, 174 lines. HEAD was still `0cc3f41`. This seat did not write that note and did not re-parse the 337/350 receipt the note cites. The r61–r68 diffs were not reviewed; they are other seats' chunks.

Not in the r101–r105 queue, so not absorbed into a row: `reports/round-106/engine-count.md:18` queues a dated correction for the `engines.md` parenthetical `Node v26.11.1` versus live `v26.12.0`. This seat's `git diff` of `engines.md` was empty. Do not treat that stale host string as a reopen of r101 R4.

## Still open

P/C precedence (six dissent cards, README `c79d8dd1…`). Mixed BLOCKED+FAIL (`run_gate.sh:436-442`). Full attack suite unbound to `390a25ae…`, and README scanner attribution still `e5521304…`. Gate harness / IP-2 (`entries=131 knowledge=0 gate=0`). C7 command absent; partial-pass sentence at README line 292. Fixture write-isolation (`r90bt_*` under `res://`). `mode_ok` not checked before `quit(0)`. Empty-jolt curiosity unexplained. Default Node v26.12.0 still mismatches the 13 pinned markers; the explicit v24.21.0 profile's 350/350 is the r105 receipt this seat tailed, not a new full run. `SKILL.md` scan scope unruled. Systemic `.shokunin` ruling unruled (295 / corpus 90). F3 index §1 row still the 11028 / `6a2d297a` frame. No Unreal Editor. Lesson bleed not ruled on `c7f6a27f…` or on the dirty worktree sha. Repo-root scratch convention unwritten. Row-F precedent standing, not newly satisfied by a 350-row non-author replay. Operator L0 unchanged. Checkout-template wording not verified in this repo.

## Commands this seat ran

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ
2026-10-18T21:21:10Z
$ git log -1 --oneline
0cc3f41 r105 report-last: verdict (all axes improved), LOG + SCORECARD, shadowing-not-drift ruling + P/C operator package — work 3634bc0
$ git status --short -- . ':(exclude)reports/round-106'
(empty at 21:21:10Z)

$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0

$ sha256sum corpus/fixtures/run_battery.py corpus/knowledge/unreal-mcp/README.md \
    corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/fixtures/phys3d_joints.gd \
    corpus/lessons/r105-unreal-lifecycle.md
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721  corpus/knowledge/unreal-mcp/README.md
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf  corpus/knowledge/unreal-mcp/gate/run_gate.sh
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  corpus/fixtures/phys3d_joints.gd
c7f6a27f0cc71b56bff875a1ffdd3c1c32761d7bf00ba9f48ef8351942d82729  corpus/lessons/r105-unreal-lifecycle.md
```

The lesson sha above is the clean-tree measurement at `21:21:10Z`. The `21:40:08Z` worktree sha is `c4aa80ec…` (174 lines), recorded in the move section.

```text
$ grep -c 'ROUND 101' LOG.md; grep -c 'ROUND 102' LOG.md; grep -c 'ROUND 103' LOG.md
1 / 1 / 1
$ grep -c 'ROUND 104' LOG.md; grep -c 'ROUND 105' LOG.md
1 / 1
$ grep -c 'Round 101' SCORECARD.md; grep -c 'Round 102' SCORECARD.md; grep -c 'Round 103' SCORECARD.md
1 / 1 / 1
$ grep -c 'Round 104' SCORECARD.md; grep -c 'Round 105' SCORECARD.md
1 / 1

$ python3 - <<'PY'
from pathlib import Path
HERE = Path('corpus/fixtures')
entries = [p for p in sorted(HERE.rglob('*')) if p.is_file() and '__pycache__' not in p.parts and p.relative_to(HERE).parts[0] != 'three']
print(f'entries={len(entries)} knowledge={sum("knowledge" in p.parts for p in entries)} gate={sum("gate" in p.parts for p in entries)}')
PY
entries=131 knowledge=0 gate=0

$ find corpus/fixtures/three/node_modules -type f | wc -l
1264
$ grep -c 'v24.21.0' corpus/fixtures/run_battery.py
13
$ grep -n 'CASE_TIMEOUT_SECONDS' corpus/fixtures/run_battery.py | head -1
36:CASE_TIMEOUT_SECONDS = 20
$ grep -c 'GATE_WORKDIR' corpus/knowledge/unreal-mcp/gate/run_gate.sh
13
$ awk '/^```sh$/,/^```$/' corpus/knowledge/unreal-mcp/gate/README.md | grep -c 'C7'
0
$ ls -d corpus/fixtures/r90bt_* | wc -l
0
$ git grep -l '\.shokunin/game-dev-3d' | wc -l
295
$ git grep -l '\.shokunin/game-dev-3d' -- corpus | wc -l
90

$ curl -sI --max-time 15 -o /dev/null -w 'plugin=%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
plugin=200
$ curl -sI --max-time 15 -o /dev/null -w 'old=%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code
old=404

$ sha256sum reports/round-102/adversary/F3.md; wc -c reports/round-102/adversary/F3.md
7d37c5f5eaa71eff691474e99f09c891447f6268d81ae4abcf53b1a08baee0b3  reports/round-102/adversary/F3.md
11702 reports/round-102/adversary/F3.md

$ tail -n 3 reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout
PASS     r100_fpslat_cls                    r100_fpslat.gd             --arm=cls          0/0       ordinary
totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0
PASS battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T204240718894Z/verdicts.json

$ git diff --name-only HEAD -- corpus/fixtures corpus/knowledge/unreal-mcp \
    corpus/knowledge/engines.md LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md
(empty at 21:40:08Z)
```

Peer files read, not re-executed: `reports/round-106/gate/final-run.md`, `reports/round-106/gate/blocked-check.md`, `reports/round-106/battery-default-quick.md`, `reports/round-106/census/cannon.md`, `reports/round-106/census/n24-state.md`, `reports/round-106/census/phys3d-joints.md`, `reports/round-106/census/three-default.md`, `reports/round-106/engine-count.md`, `reports/round-106/glb-unity-regression.md`, `reports/round-106/r22-regression.md`, `reports/round-106/r105-receipt-carry.md`, `reports/round-106/r106-scribe-audit.md`, `reports/round-106/consistency/adversary.md` (dated-note ruling; not this register), `reports/round-105/operator-package.md`.

## Report checks

Run after the register was written, then again after the r105 O4 cell was corrected (`2026-10-18T21:47:54Z` whitespace probe; row/path probe re-run after the cell edit). No project build or test command was run by this seat.

```text
$ python3 -c 'row counter over reports/round-106/consistency.md'
r101 15
r102 16
r103 22
r104 15
r105 10
ACCOUNTED_ROWS=78
UNIQUE 78
```

The counter matched every expected id (`r101 O1–O6`, `R1–R9`; `r102 O1–O8`, `R1–R8`; `r103 O1–O12`, `Q1–Q10`; `r104 O1–O15`; `r105 O1–O5`, `R1–R5`). No missing id. No extra id.

```text
$ python3 -c 'path existence over cited reports/ and corpus/ files'
PATH_REFERENCES=41
MISSING=[]
```

That 41 was before this appendix and before the O4 cell named `reports/round-106/scratch/seat102/log-routed.txt`. Recount at `2026-10-18T22:09:04Z`, after both edits: `ACCOUNTED_ROWS=78`, `PATH_REFERENCES=42`, `MISSING=[]`. `test -f reports/round-106/scratch/seat102/log-routed.txt` → `SCRATCH_LOG_COPY=yes`. Same-minute `git diff --no-index --check` again printed no whitespace diagnostics and exited 1.

```text
$ git diff --no-index --check /dev/null reports/round-106/consistency.md
(no whitespace diagnostics)
DIFF_CHECK_RC=1
```

`DIFF_CHECK_RC=1` is the new-file difference from `/dev/null`, not a whitespace finding. `git status --short -- reports/round-106/consistency.md` → `?? reports/round-106/consistency.md`.
