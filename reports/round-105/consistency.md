# SEAT-38 CONSISTENCY — r105

**Owned path:** `reports/round-105/consistency.md` only. All source and artifact inspection was read-only.
**Evidence frame:** 2026-10-18T21:00:00Z; the worktree is shared and still moving.
**Scope:** account for each numbered open item in r101–r104 and preserve the routed queues already included by the r104 consistency convention. `CLOSED` means a prior round recorded the requested close and the pointer below supports that historical disposition; `CARRY` means unresolved or structurally impossible here; `PARTIAL / CARRY` means a subpart closed but a named residual remains. A prior close is not silently upgraded to a new r105 verification.

**Boundary:** no SHONEN box 1 was checked. No Unreal Editor/runtime claim is made. The static gate and Godot fixture receipts are not evidence of Unreal runtime behavior.

## Accounting

`reports/round-104/consistency.md` counts the r101–r103 rows as `6+9+8+8+12+10 = 53` in its §0 table, but §1 prose calls the same total 51. The table arithmetic is correct. Adding r104 O1–O15 gives **68 accounted entries**: 41 numbered report items plus 27 routed-queue entries. The row-by-row register below preserves all 68; a routed item that was already resolved remains visible as a historical closure rather than disappearing from the count.

| Source | Numbered open items | Routed entries | Total |
|---|---:|---:|---:|
| r101 | 6 | 9 | 15 |
| r102 | 8 | 8 | 16 |
| r103 | 12 | 10 | 22 |
| r104 | 15 | 0 | 15 |
| **Total** | **41** | **27** | **68** |

## r101 — report open items and routed queue (15)

Source items: `reports/round-101/r101-report.md:285-310`; routed queue: `LOG.md:1318-1323`. The historical dispositions are catalogued in `reports/round-104/consistency.md:77-102`.

| ID | Item | r105 disposition and evidence |
|---|---|---|
| r101 O1 | Pre-landing hash and moving close counts | **CLOSED (historical).** r101 close records the committed hash and ledger entries: `reports/round-101/r101-report.md:314-328`; r104 consistency rechecks the record at `reports/round-104/consistency.md:81`. |
| r101 O2 | Pointer checker self-contaminates on protocol negative controls | **CLOSED (historical; exact scratch probe no longer reproducible).** The old scratch script is gone; do not claim a fresh rerun. See `reports/round-104/consistency.md:82` and r101 protocol/close. |
| r101 O3 | Stale `(pending: …)` labels in subtree README | **CLOSED (historical).** r101 close removed the labels; recheck recorded at `reports/round-104/consistency.md:83`. |
| r101 O4 | C1 claim scope: all upstream content versus pinned commit | **CLOSED (historical ruling).** Adopted scope is “all files tracked at the pinned commit”; out-of-pin surface is documented in `corpus/knowledge/unreal-mcp/PROVENANCE.md:340`; see `reports/round-104/consistency.md:84`. |
| r101 O5 | `verified-here` adaptation rows are Kimi-side, not Unreal-side | **CARRY (boundary).** The label distinction is documented at `SKILL.md` §1 and `reports/round-104/consistency.md:85`; r105 still makes no Unreal runtime claim. The separate fixture-label review is `reports/round-105/lesson/critic.md:48-54`. |
| r101 O6 | No live-editor evidence on this host | **CARRY (structural).** Installation remains unavailable; see `reports/round-105/install-recheck.md` and `reports/round-104/consistency.md:86`. |
| r101 R1 | r22 README/lesson path drift | **CLOSED (r102).** Repairs and verification: `reports/round-103/b2/repair-glb.md`, `reports/round-103/b2/verify-unity.md`, `reports/round-103/b2/verify-three.md`; historical carry pointer `reports/round-104/consistency.md:94`. |
| r101 R2 | r22 lesson cites absent `verdicts.json` | **CLOSED (r102).** `reports/round-103/b2/corrections.md`; indexed at `reports/round-104/consistency.md:95`. |
| r101 R3 | `run_battery.py` cited-SHA drift | **CLOSED (r102).** r104 re-derived the runner digest in `reports/round-104/physics/markers.md`; current `sha256sum` again gives `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (command/output below). |
| r101 R4 | `engines.md` three.js command fails from clean tree | **CLOSED (r102).** `reports/round-103/b2/repair-three.md`; prior index `reports/round-104/consistency.md:97`. |
| r101 R5 | `rea.md` JADX/Binwalk/Unblob tool census | **CLOSED (r102).** `reports/round-103/b2/corrections.md`; prior index `reports/round-104/consistency.md:98`. |
| r101 R6 | README glob line-count (F8) | **CLOSED (r102).** `reports/round-102/repairs/F8-readme-lines.md`; prior index `reports/round-104/consistency.md:99`. |
| r101 R7 | IP-2: digest map omits `corpus/knowledge/` and gate files | **CARRY (open).** r104 independently measured `entries: 130 knowledge: 0 gate: 0` (`reports/round-104/r104-connector.md:331-339`; summarized at `reports/round-104/consistency.md:100`). No r105 evidence integrates the gate into the seed map. |
| r101 R8 | Sentinel S-5: PATH-shadowed `basename` | **CLOSED (historical absorbed fix).** Gate tool guard and regression evidence are indexed at `reports/round-104/consistency.md:101`; no regression reported in r105 gate receipts. |
| r101 R9 | Sentinel S-8: `.mcp.json` auto-load behavior | **CARRY (not rechecked here).** Kimi trust boundary is in `reports/round-102/sentinel-mcp.md:2`; r104 recorded no operational carrier (`reports/round-104/consistency.md:102`). |

## r102 — report open items and routed queue (16)

Source items: `reports/round-102/r102-report.md:351-395`; routed queue: `LOG.md:1349-1358`. Prior accounting: `reports/round-104/consistency.md:106-130`.

| ID | Item | r105 disposition and evidence |
|---|---|---|
| r102 O1 | Pre-landing hash, moving counts, missing LOG/SCORECARD entry | **CLOSED (historical).** r102 close and current history are indexed at `reports/round-104/consistency.md:110`; r105 did not amend those ledgers. |
| r102 O2 | F7/P-C label-vocabulary collision | **CARRY (unruled).** Only `reports/round-105/pc/review-3.md` exists among `review-*.md`; it recommends REVISE and explicitly says no ruling was made (`:5-12, 124-126`). README/cards remain unchanged at the reviewed hash (`:24-32, 74-80`). |
| r102 O3 | Gate missed range-form pointer endpoints | **CLOSED (r103).** Hardened range endpoint validation and current final gate output are recorded in `reports/round-103/gate/exit-codes.md` and `reports/round-105/gate/final-run.md:72-75` (`POINTERS=103`, `UNRESOLVED=0`). |
| r102 O4 | No gate receipt or standing harness integration | **CARRY (open).** r105 preserves manual gate stdout/stderr/rc, but no built-in receipt or standing battery integration is demonstrated; see `reports/round-105/gate/final-run.md:82-88` and prior negative integration check `reports/round-104/consistency.md:113`. |
| r102 O5 | Gate requires network and cannot complete offline | **CLOSED as an explicit blocked state, not offline support.** r103 A4/GATE_REF documented the blocked result; current REPO override test returns `BLOCKED (network)`/rc 2 (`reports/round-105/gate/integrity.md:36-40`). No offline PASS is claimed. |
| r102 O6 | Two math-audit discrepancies: node_modules count and stale F3 frame | **PARTIAL / CARRY.** The 1264 node_modules count was corrected; stale `adversary/F3.md` archival frame remains without a fresh reconciliation (`reports/round-104/consistency.md:115,130`). r105 numeric audit is in `reports/round-105/math-audit.md`, but does not close that historical frame issue. |
| r102 O7 | No live-editor evidence | **CARRY (structural).** `reports/round-105/install-recheck.md`; prior disposition `reports/round-104/consistency.md:116`. |
| r102 O8 | F3/F5/F6 adversarial findings await L1 accept/overrule | **CARRY (unruled).** Draft/dissonance records name the findings, but no ruling is recorded: `reports/round-104/r104-adjudicator-draft.md:§5.3-§5.6`, `reports/round-104/r104-dissonance.md`, and `reports/round-104/consistency.md:117`. |
| r102 R1 | Fold A1: range-tail-blind regex | **CLOSED (r103).** Current pointer sweep confirms `POINTERS=103 … UNRESOLVED=0`: `reports/round-105/gate/final-run.md:72-75`. |
| r102 R2 | Fold A2: prose-hijackable first-token rule | **CLOSED (r103).** Anchored label validation and attack evidence: `reports/round-103/gate/a2-attack.md`; current card scan passes in `reports/round-105/gate/final-run.md:53-70`. |
| r102 R3 | Fold A3: card names were not compared | **CLOSED (r103).** Pinned card-name set; current `NAME_SET=OK NAME_BAD=0` at `reports/round-105/gate/final-run.md:67-70`. |
| r102 R4 | Fold A4: distinguish network block from byte mismatch | **CLOSED (r103/r104).** Current network branch and copied byte-flip both distinguish outcomes: `reports/round-105/gate/integrity.md:36-46`. |
| r102 R5 | Kimi-surface freshness note for `adaptation-kimi.md` | **CLOSED (r103; URL corrected in r105).** `reports/round-105/kimi404/verify.md:5-28` verifies old URL 404, corrected `-plugin` URL 200, one-line diff and clean `git diff --check`. |
| r102 R6 | Battery Node marker drift (`r94_cannon`) | **PARTIAL / CARRY (default path still mismatched).** Default Node 26 row fails against pinned v24 marker (`reports/round-105/n24/pre-state.md:30-56`). Explicit Node 24.21.0 rerun passed the full battery, 350/350, with top-level `PASS` and `seeds_unchanged=True` (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout:703-704`; receipt `corpus/live/runs/20261018T204240718894Z/verdicts.json`). The explicit profile works; default Node resolution still selects v26.12.0, so the host-default mismatch remains. |
| r102 R7 | B2 dead `.shokunin` root in three READMEs | **CLOSED (three-file repair); CARRY (systemic scope ruling).** Repairs are recorded in `reports/round-103/b2/repair-glb.md`, `repair-three.md`, `verify-unity.md`; broader R4 scope remains unruled (`reports/round-103/r103-report.md:437-442`, `reports/round-104/consistency.md:243-260`). |
| r102 R8 | Math-audit two wrong rows | **PARTIAL / CARRY.** Corrected 1264 count, but stale F3 archival-frame discrepancy remains; see O6 above and `reports/round-104/consistency.md:115,130`. |

## r103 — report open items and routed queue (22)

Source items: `reports/round-103/r103-report.md:413-468`; routed queue: `LOG.md:1385-1392`. Prior detailed accounting: `reports/round-104/consistency.md:134-366`.

| ID | Item | r105 disposition and evidence |
|---|---|---|
| r103 O1 | Pre-landing hash, moving counts, missing LOG/SCORECARD entry | **CLOSED (r103).** Close record at `reports/round-103/r103-report.md:479-483`; current HEAD is the r104 report-last line shown below. |
| r103 O2 | README contradicted gate exit semantics | **CLOSED for the original two lines (r104); residual contradiction remains.** r104’s close check records the fix (`reports/round-104/consistency.md:150-167`), but r104 also records `corpus/knowledge/unreal-mcp/gate/README.md:292` still claiming “There is no partial-pass state” (`reports/round-104/r104-report.md:590-593`). Do not treat the entire exit-semantics topic as clean. |
| r103 O3 | Mixed `BLOCKED` plus `FAIL` loses the blocked state | **CARRY (open in code).** The r104 close still identifies the branch at `corpus/knowledge/unreal-mcp/gate/run_gate.sh:436-442`; the current gate PASS does not exercise the mixed case (`reports/round-104/r104-report.md:600-606`, `reports/round-105/gate/final-run.md:72-77`). |
| r103 O4 | Conflicting pointer totals in README | **CLOSED for numeric pin; CARRY for provenance.** Current gate and README agree on 103, but README still attributes the count to scanner `e5521304…`, not current gate SHA `390a25ae…` (`reports/round-105/gate/integrity.md:30-35`). |
| r103 O5 | Full attack suite not run against r103 final bytes | **CLOSED historically in r104, not a current-gate certification.** r104 consistency found 30 rows/0 mismatches bound to `e5521304…` (`reports/round-104/consistency.md:214-241`). That does not close r104 O10 for current SHA `390a25ae…` (see below). |
| r103 O6 | B2 systemic `.shokunin` scope ruling (R4) | **CARRY (unruled).** r104 notes the broad count and label collision but no L1 accept/overrule (`reports/round-104/consistency.md:243-260`). No r105 ruling appears in the reviewed artifacts. |
| r103 O7 | `phys3d_joints_free_ops` timeout classified but not repaired | **CLOSED (r104 fix).** r104 close records concurrent spawn, unchanged CASES, full 337/350 receipt and non-author corroboration (`reports/round-104/r104-report.md:700-713,745-749`); r105 rerun of the single row passes (`reports/round-105/physics-carry.md:3-13`). |
| r103 O8 | Node-marker drift for `r94_cannon_*` rows | **PARTIAL / CARRY (default path still mismatched).** Full explicit Node 24 rerun now passes 350/350 with clean seed integrity (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout:703-704`; receipt `corpus/live/runs/20261018T204240718894Z/verdicts.json`); default Node 26 still fails the pinned marker (`reports/round-105/n24/pre-state.md:30-56`). |
| r103 O9 | Tracked Kimi URL returns 404 | **CLOSED in r105.** The one-line corrected URL is verified at `reports/round-105/kimi404/verify.md:5-28`. |
| r103 O10 | Control section count says C1–C6; C7 command absent | **CARRY (open).** r104 re-derived both residuals (`reports/round-104/consistency.md:318-329`); no r105 doc repair is recorded. |
| r103 O11 | `--path .` can write scratch beneath seed fixtures | **CARRY (no guard).** r104 routed fixture write-isolation; r105’s only fixture-tree addition is the peer-owned `PINNED-ENV.md` documentation, not a guard (`reports/round-104/consistency.md:331-345`, `reports/round-105/git-hygiene.md:74-77,100-102`). |
| r103 O12 | No live-editor evidence | **CARRY (structural).** `reports/round-105/install-recheck.md`; prior record `reports/round-104/consistency.md:347-351`. |
| r103 Q1 | Physics fix R3: concurrent children | **CLOSED (r104).** See O7 and the passing independent row receipt `reports/round-105/physics-carry.md:7-13`. |
| r103 Q2 | R1 global timeout increase 20→60 | **NOT ADOPTED; superseded by selected R3.** r104 preserved `CASE_TIMEOUT_SECONDS=20` while implementing R3 (`reports/round-104/consistency.md:357-360`); no unresolved request to raise it. |
| r103 Q3 | R2 proportional per-case timeout | **NOT ADOPTED; superseded by selected R3.** r104 selected the concurrent-spawn fix; see `reports/round-104/consistency.md:358-360`. |
| r103 Q4 | R4 re-baseline the marker | **NOT ADOPTED (as intended).** Marker was preserved under the R3 fix; evidence and explicit condition at `reports/round-104/consistency.md:359-360`. |
| r103 Q5 | Gate workdir resilience (`GATE_WORKDIR`/`TMPDIR`) | **CLOSED (r104; re-exercised r105).** Current gate ran with repo-local `GATE_WORKDIR` and returned rc 0, four `STEP=PASS` (`reports/round-105/gate/final-run.md:8-16,28-76`). |
| r103 Q6 | Flake-reproduction harness | **CLOSED (r104).** Harness and stable result are indexed at `reports/round-104/consistency.md:361-362`; r105 gate has durable stdout/stderr/rc but does not replace that harness. |
| r103 Q7 | Stray `r90bt_*` fixture directories / write-isolation proposal | **CARRY (no guard).** `reports/round-104/consistency.md:363` and r104 report O13 route it; r105 `git-hygiene.md:65,100` only establishes a point-in-time snapshot, not a guard. |
| r103 Q8 | Kimi URL 404 | **CLOSED in r105.** `reports/round-105/kimi404/verify.md:14-28`. |
| r103 Q9 | Empty jolt cells match pinned marker; cause unexplained | **CARRY (unexplained).** Prior stress/digest evidence is listed at `reports/round-104/consistency.md:365`; r105 `physics-carry.md` verifies the fixture fix, not the empty-cell question. |
| r103 Q10 | Battery cannon Node markers | **PARTIAL / CARRY (default path still mismatched).** Explicit Node 24 rerun is a clean 350/350 battery PASS with unchanged seeds (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout:703-704`; receipt `corpus/live/runs/20261018T204240718894Z/verdicts.json`); default Node 26 marker mismatch remains (`reports/round-105/n24/pre-state.md:30-56`). |

## r104 — numbered open items (15)

Source: `reports/round-104/r104-report.md:570-651`. Its close-out is `:695-750`; r104’s contemporaneous consistency map is `reports/round-104/consistency.md:370-390`.

| ID | Item | r105 disposition and evidence |
|---|---|---|
| r104 O1 | Pre-landing hash and moving numbers; LOG/SCORECARD r104 entries absent | **CLOSED.** HEAD is `1eaa568` with the r104 report-last verdict; command/output below. Close verdict and work hash are in `reports/round-104/r104-report.md:695-698`. |
| r104 O2 | C1 fix, full battery 337/13, non-author reproduction and R3 adversary | **CLOSED for r104 claim; r105 now adds a clean pinned-profile full run.** r104 close records the fix and requested reproductions (`reports/round-104/r104-report.md:700-713,745-749`). The first r105 Node-24 run had a seed-integrity failure, but the follow-up is 350/350, top-level `PASS`, `seeds_unchanged=True` (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout:703-704`; receipt `corpus/live/runs/20261018T204240718894Z/verdicts.json`). |
| r104 O3 | Workdir knob and documentation; residual partial-pass text and TMPDIR ruling | **PARTIAL / CARRY.** `GATE_WORKDIR` is wired/documented and r105 final gate passes with it (`reports/round-105/gate/final-run.md:10-16,24-26`); the residual README statement is recorded at `reports/round-104/r104-report.md:590-593`, and no ruling on TMPDIR-only sufficiency is evidenced. |
| r104 O4 | `BLOCKED (network)` mislabel | **CLOSED.** The r105 `REPO` control produces `BLOCKED (network)`, while the clean gate passes (`reports/round-105/gate/integrity.md:36-40`, `reports/round-105/gate/final-run.md:45-51`). |
| r104 O5 | Mixed `BLOCKED+FAIL` result loses third state | **CARRY (open).** Code path remains identified at `reports/round-104/r104-report.md:600-606` and `corpus/knowledge/unreal-mcp/gate/run_gate.sh:436-442`; no r105 mixed-case test or fix is reported. |
| r104 O6 | SKILL citations self-healed; gate cannot scan root SKILL.md | **PARTIAL / CARRY (scope question).** Citation race self-healed, but no accepted scan-scope ruling is recorded; r104 defines the design question at `reports/round-104/r104-report.md:607-621`. Current gate receipt scopes its checks to the subtree (`reports/round-105/gate/final-run.md:28-75`). |
| r104 O7 | C3 author receipt still needs named non-author verification | **CARRY.** r104 close says the non-author-verifier half of SHONEN box 1 remains open (`reports/round-104/r104-report.md:727-735`). r105 reviews do not supply that specific independent C3 verification; box 1 was not checked. |
| r104 O8 | P/C precedence ruling | **CARRY (no ruling; package requires revision).** `reports/round-105/pc/review-3.md:8-12,82-126` recommends REVISE; it explicitly does not apply a ruling. |
| r104 O9 | Decide whether SKILL.md is inside gate scope or seat-verified only | **CARRY (unruled).** Same unresolved design question as `reports/round-104/r104-report.md:619-621`; current gate receipt is subtree-only (`reports/round-105/gate/final-run.md:28-75`). Counted separately from O6 because r104 numbered it separately. |
| r104 O10 | Full attack-suite result bound to final gate bytes | **CARRY (not verified at current SHA).** Current gate SHA is `390a25ae…` (`reports/round-105/gate/final-run.md:3-6`). r105 integrity supplies only a network-block and copied byte-flip spot test (`reports/round-105/gate/integrity.md:36-46`), not the complete attack suite bound to that digest. |
| r104 O11 | Gate changed repeatedly; consolidate every suite on one final revision | **CARRY (partial consolidation only).** Current ordinary gate run is pinned to `390a25ae…`, but O10’s full suite remains unbound; see `reports/round-105/gate/final-run.md:3-16` and `reports/round-105/gate/integrity.md:30-46`. |
| r104 O12 | Thirteen `r94_cannon_*` marker failures on default Node | **PARTIAL / CARRY (default path remains mismatched).** The explicit Node 24.21.0 full rerun passed all 350 rows with `seeds_unchanged=True` (`reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout:703-704`; receipt `corpus/live/runs/20261018T204240718894Z/verdicts.json`). Default resolution remains v26.12.0 and the representative row still mismatches the pinned v24 marker (`reports/round-105/n24/pre-state.md:9-27,30-56`). |
| r104 O13 | `--path .` fixture-write hazard | **CARRY (no guard).** `reports/round-104/r104-report.md:639-643`; r105 hygiene confirms only a peer documentation addition under fixtures at its snapshot, not a prevention mechanism (`reports/round-105/git-hygiene.md:65,74-77,100`). |
| r104 O14 | Transient untracked scratch dirs at repo root; convention needed | **PARTIAL / CARRY.** No root scratch path appeared in this seat’s `git status --short` snapshot below, but a quiet snapshot does not establish the missing convention. Original observation and requested convention: `reports/round-104/r104-report.md:644-647`. |
| r104 O15 | No live-editor evidence | **CARRY (structural).** `reports/round-105/install-recheck.md`; r104 written boundary at `reports/round-104/r104-report.md:648-651`. |

## Current evidence and provenance limits

### Node 24 battery

The first pinned-Node full run is durable at `reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout` and its verdict JSON is `reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json`. It recorded **350 PASS / 0 FAIL** rows but top-level `FAIL`, `seeds_unchanged=False`; `reports/round-105/math-audit.md:135-201` compares 130 recorded seed entries with 131 current entries, with only `PINNED-ENV.md` added and no removed or changed entries. That difference alone does not prove cause. A peer rerun then completed from the explicit Node 24.21.0 PATH (`PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py`): `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout` ends `totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0` and `PASS battery`; receipt `corpus/live/runs/20261018T204240718894Z/verdicts.json` says `VERDICT=PASS`, `seeds_unchanged=True`. A read-only parse found 19/19 `r94_cannon_*` rows PASS and all 13 recorded positive-row markers `v24.21.0`; the receipt's `PINNED-ENV.md` digest matches the current digest (`90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f`). This resolves the full battery under the explicit pinned profile. Default Node resolution still selects v26.12.0, so the default-path marker mismatch remains an operator/environment carry. This seat did not start or stop the peer rerun.

### Commands run by this seat and observed output

The following are SEAT-38 read-only probes, not copied peer commands:

```text
$ git log -1 --oneline
1eaa568 r104 report-last: verdict (all axes improved), LOG + SCORECARD, adjudication with L1-corroborated 337/350 — work 2ca87e8

$ git diff --name-only HEAD -- corpus/fixtures corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability
[no output]

$ git diff --check -- reports/round-105
[no output]

$ git status --short
 M SKILL.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
?? corpus/fixtures/PINNED-ENV.md
?? corpus/lessons/r105-unreal-lifecycle.md
?? reports/round-105/

$ printf 'DEFAULT_NODE='; node --version; printf 'DEFAULT_NODE_PATH='; command -v node; printf 'PINNED_NODE='; PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
DEFAULT_NODE=v26.12.0
DEFAULT_NODE_PATH=/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
PINNED_NODE=v24.21.0

$ sha256sum corpus/fixtures/run_battery.py corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/gate/run_gate.sh
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721  corpus/knowledge/unreal-mcp/README.md
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf  corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

`git status` was captured before this file was created. The `M`/`??` paths in that output pre-existed this seat’s write. The protected-path diff was empty; no fixture, upstream, manifest, or card source was modified by this seat.

### Peer receipts, not SEAT-38 executions

- `reports/round-105/gate/final-run.md:3-16,28-80` records current gate SHA `390a25ae…`, four `STEP=PASS`, manifest 12/12, pinned clone equivalence, 13-card census 12/1/0, `POINTERS=103`, `UNRESOLVED=0`, rc 0. This is a static gate result, not an Unreal runtime result.
- `reports/round-105/gate/integrity.md:30-46` confirms README numeric pin 103 but stale scanner provenance (`e5521304…`); its network override returns rc 2, and a copied byte-flip fails. It is not the complete final-SHA attack-suite run.
- `reports/round-105/kimi404/verify.md:5-28` independently verifies the URL repair; it is a peer-owned source change.
- `reports/round-105/pc/review-3.md:124-126` leaves P/C for operator adjudication; proposal is not a ruling.
- `reports/round-105/lesson/critic.md:1-4,48-54` reviews current lesson SHA `d089aae7…` and says REVISE because the Godot fixture result lacks a `verified-here` row label and bound receipt/command/digests. The older `lesson/bleed.md` verdict is for SHA `dd9b9ac…` and 155 lines (`reports/round-105/lesson/bleed.md:1-3`), so it is not a review of current `d089aae7…` bytes. This is not an Unreal runtime finding.

## Remaining live carries

Still open: P/C precedence; gate receipt/harness integration; mixed BLOCKED+FAIL semantics; current-SHA full attack-suite provenance and stale README scanner attribution; math-audit stale F3 frame; systemic `.shokunin` scope ruling; C7 control recipe/count; fixture write-isolation; unexplained empty-jolt curiosity; default Node 26 marker mismatch (the explicit Node 24 profile passes all 350 rows); SKILL scan-scope/non-author verification questions; repo-root scratch convention; and the structural absence of Unreal Editor evidence. The detailed source mapping is in the 68-row register above.

## Report checks

Commands run by SEAT-38 after writing; outputs are for this report, not project build/test suites:

```sh
python3 - <<'PY'
from pathlib import Path
import re
lines=Path('reports/round-105/consistency.md').read_text().splitlines()
rows=[line for line in lines if re.match(r'^\| r(?:101|102|103|104) (?:O|R|Q)\d+ ',line)]
for round_id in ('r101','r102','r103','r104'):
    print(round_id, sum(line.startswith('| '+round_id+' ') for line in rows))
print('ACCOUNTED_ROWS='+str(len(rows)))
PY
```

```text
r101 15
r102 16
r103 22
r104 15
ACCOUNTED_ROWS=68
```

```sh
python3 - <<'PY'
from pathlib import Path
import re
s=Path('reports/round-105/consistency.md').read_text()
refs=sorted(set(re.findall(r'(?<![A-Za-z0-9_])((?:reports|corpus)/[A-Za-z0-9_./-]+\.[A-Za-z0-9_-]+)',s)))
missing=[p for p in refs if not Path(p).exists()]
print('PATH_REFERENCES='+str(len(refs)))
print('MISSING='+str(missing))
PY
```

```text
PATH_REFERENCES=43
MISSING=[]
```

```sh
git diff --no-index --check /dev/null reports/round-105/consistency.md 2>&1
rc=$?
printf 'DIFF_CHECK_RC=%s\n' "$rc"
git status --short -- reports/round-105/consistency.md
```

Observed: no whitespace diagnostics; `DIFF_CHECK_RC=1` because the new file differs from `/dev/null`; status `?? reports/round-105/consistency.md`. The final `--no-index --check` and citation checks are rerun after this appendix is added. No project build or test command was run by this seat; the Node-24 full-run evidence above is a peer's receipt.
