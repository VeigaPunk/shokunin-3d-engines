# r106 SEAT-67 — SHONEN-DRAFT

Axes: **coverage** (box 1 sources still resolve), **depth** (box 2/3 commands run without oral context), **calibration** (a `[x]` only with a named non-author verifier; this seat is the lane).

**Do not edit `SHONEN.md`.** It is protected. This file is the report-back draft. No new `[x]`.

Frame `2026-10-18T21:38:04Z`. `git rev-parse HEAD` → `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Lesson diffs were still landing; counts are this frame, not close.

## Paste-ready 4-box lines

`SHONEN.md` reads box 2 `[x]` and boxes 1, 3, 4 `[ ]` (`grep -c '^- \[x\]' SHONEN.md` → `1`). Marks below are report-section evidence, not a file flip. `[x]` needs a named non-author verifier. `[~]` is this lane's assessment with a pointer. A dispatched seat cannot be that verifier.

- **Box 1 — real decision tables / error patterns / checklists with cited sources.** `[~]` `SKILL.md` is on HEAD (sha256 `8ea7ae5c306913d44340454ca242579ff1f6c9ba29007efdb7943757bbf36371`; git blob `81970105e72856d7c17e83bf95820584883d52f2` = `HEAD:SKILL.md`). Shape: 6 decision rows (A–F), 8 named error signatures, 12 checklist items, 6 refusals. Eleven §6 stamps re-hashed **MATCH** (gate script, gate README, subtree README, PROVENANCE, adaptation-kimi, r102 lesson, engines.md, `run_battery.py`, `phys3d_joints.gd`, r104 physics author, row-F receipt). This seat re-ran, from the lane root, with no author input: manifest `sha256sum -c` → 12 × `OK`, rc 0; `jq -e .` on the two JSON files → rc 0; `bash -n upstream/hooks/unreal-context.sh` → rc 0; `which UnrealEditor UnrealEditor-Cmd` → rc 2; `ls /opt/UnrealEngine` → rc 2; descriptor accept and `--expect-reject` → both `PASS`, rc 0; `grep -rln 'Not \`unproven-runtime\`'` → 6. Row-F frozen receipt sha256 `17b037d5154b7cf51a55df197a142f09ce3ea0fb9b4471f75a74a028f508397c` parses `verdict=PASS`, `cases=1 pass=1 fail=0`, `seeds_unchanged=true`, row exit 0, timeout 20. **Not `[x]`.** `SKILL.md` §6 says landing the table is only the artifact half and the author cannot close the box. No named non-author accepted the table this round. §4 P/C precedence is still owed. r104 `LOG.md` already routed the missing verifier; r105 folded a replay requirement into row F and did not check the box.
- **Box 2 — end-to-end domain task executed and logged.** `[x]` unchanged from round 2. Verifier `game-dev-3d-r2-review-retry` (not the r1 author), pointer `corpus/lessons/r2-independent-review.md` (git blob `a688da6cddcad531000e38b209cfeade2645911f` = HEAD; absent from the 21:38:04Z lesson-diff list). Contact-plane derivation is still in that file (the mutant `ERROR: body3d_slide: body did not stop at the contact plane…` line, and the source cross-check of plane 2.5 / tick 21). This seat's `godot --headless --version` → `4.7.2.stable.arch_linux.ed1daf0bf`, rc 0, the same binary string the review recorded. **r106 does not add a check.** No Unreal Editor (`which` rc 2). In-flight census probes are not a new end-to-end task and were not re-run here. The review's own commands use the historical `.shokunin/game-dev-3d/` root; that is a sweep citation fact, not a reason to uncheck a named review whose file is intact.
- **Box 3 — instructions executable without oral context.** `[~]` The commands in `SKILL.md` §1 and `corpus/fixtures/PINNED-ENV.md` ran here with no oral context. Default `node --version` → `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`. The documented fnm prefix → `v24.21.0` at `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`. Runner sha256 still `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. **Not `[x]`.** Residuals, all named: P/C ruling still open (`SKILL.md` §4); the pinned total is not the ambient PATH (the doc states this; it is not ambient); `/tmp` per-user quota is exhausted, so a gate run needs `GATE_WORKDIR` (peer `reports/round-106/gate/final-run.md`, SEAT-70, `GATE RESULT: PASS`, `POINTERS=103`, rc 0 — **not re-run by this seat**); `engines.md` three.js `installed` cell still parenthesizes `Node v26.11.1` against live `v26.12.0` (state cell not a promotion; owned by SEAT-38, not edited here).
- **Box 4 — no cross-domain bleed; `PROVINCE.md` still accurate.** `[~]` `PROVINCE.md` sha256 `1932f0fd7103dcc33e0b0c9f835adfe681e6ce4d765d4673bcc925c5d8230eac`; git blob = HEAD. At the stamp check `2026-10-18T21:28:38Z`, `engines.md` sha256 `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` = the `SKILL.md` §6 stamp, and its four state cells were Godot `yes`/`yes`, Unity `no`/`no`, Unreal `no`/`no`, three.js `partial`. No Unreal runtime claim: editor absent (rc 2). Protected roots `LOG.md` `SCORECARD.md` `SHONEN.md` `PROVINCE.md` `SKILL.md` all MATCH HEAD at 21:38:04Z. **Not `[x]`.** The r105 lifecycle lesson still teaches gate/harness auditing (`corpus/lessons/r105-unreal-lifecycle.md:38` “Put the gate in the corpus…”); `reports/round-105/lesson/bleed.md` ruled **FAIL (semantic harness/evidence-audit bleed)**. An r106 edit appended an environment-pairing note (`git diff --stat` → `+13/−1`) and did not remove that section. In-flight lesson diffs at 21:38:04Z: 9 files (`r105` + `r61`–`r68`). The r61 hunk is a path-root rewrite plus a dated correction note, not lore/2D/harness content. An added-line scan of the then-8-file set at 21:28:38Z (`git diff -U0 HEAD -- corpus/lessons`, 43 added lines) found lore 0, `2D` 0, harness-id 0. That scan is a frame. No seat was asked to rule `PROVINCE.md` accuracy, so the box stays `[~]`.

## What `SHONEN.md` should remain

Leave the file byte-identical to HEAD. Current text:

```text
- [ ] Real decision tables/error patterns/checklists with cited sources.
- [x] End-to-end domain task executed and logged; `game-dev-3d-r2-review-retry` independently reproduced both battery commands, mutation rejection and source contact-plane derivation (`corpus/lessons/r2-independent-review.md`, round 2).
- [ ] Instructions executable without oral context.
- [ ] No cross-domain bleed; PROVINCE remains accurate.
```

`git hash-object SHONEN.md` and `git rev-parse HEAD:SHONEN.md` both `8d85902c19010deb4fa154e16a2c12ad56ff10d1` at 21:38:04Z. A close-time flip of box 1, 3, or 4 to `[x]` is **not supported**. The report section may carry the `[~]` lines above. Flipping the file itself is an L1 ledger action and still needs a named non-author who is not a dispatched seat.

## Commands this seat ran

Receipts: `reports/round-106/scratch/seat67/`. Unrun checks are not passed. The full battery and the gate were not re-run here.

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ; git rev-parse HEAD
2026-10-18T21:21:09Z
0cc3f4162f8c319f8d01a69a174fe939f36701bd

$ git hash-object SHONEN.md; git rev-parse HEAD:SHONEN.md; grep -c '^- \[x\]' SHONEN.md
8d85902c19010deb4fa154e16a2c12ad56ff10d1
8d85902c19010deb4fa154e16a2c12ad56ff10d1
1

$ sha256sum SKILL.md PROVINCE.md
8ea7ae5c306913d44340454ca242579ff1f6c9ba29007efdb7943757bbf36371  SKILL.md
1932f0fd7103dcc33e0b0c9f835adfe681e6ce4d765d4673bcc925c5d8230eac  PROVINCE.md

$ git hash-object SKILL.md; git rev-parse HEAD:SKILL.md
81970105e72856d7c17e83bf95820584883d52f2
81970105e72856d7c17e83bf95820584883d52f2
```

`SKILL.md` section parse (same file): `decision_rows 6`, `error_pattern_rows 8`, `checklist_items 12`, `refusals 6`.

```text
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null; echo rc=$?)
rc=0
# 12 lines, each `OK`

$ (cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null; echo rc=$?)
rc=0

$ (cd corpus/knowledge/unreal-mcp && bash -n upstream/hooks/unreal-context.sh; echo rc=$?)
rc=0

$ which UnrealEditor UnrealEditor-Cmd; echo rc=$?
which: no UnrealEditor in (…)
which: no UnrealEditor-Cmd in (…)
rc=2

$ ls /opt/UnrealEngine; echo rc=$?
ls: cannot access '/opt/UnrealEngine': No such file or directory
rc=2

$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6

$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py; echo rc=$?
PASS local-static actual=accept … reason=one fixed-scope Unreal-style Runtime module descriptor (local static JSON)
rc=0

$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject; echo rc=$?
PASS local-static actual=reject … reason=unsupported module Type: 'Unknown'
rc=0

$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node

$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0

$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py

$ godot --headless --version; echo rc=$?
4.7.2.stable.arch_linux.ed1daf0bf
rc=0

$ sha256sum reports/round-104/physics/author-runs-final/20261018T193509710404Z/verdicts.json
17b037d5154b7cf51a55df197a142f09ce3ea0fb9b4471f75a74a028f508397c  …
# parsed: verdict PASS totals cases=1 pass=1 fail=0 seeds True row PASS exit 0 reasons [] timeout 20
```

§6 stamp re-hash at `2026-10-18T21:28:38Z`: `stamp_match=11 stamp_stale=0` on the eleven paths listed in box 1. `engines.md` rows 8–11 at that read: Godot `yes`/`yes`, Unity `no`/`no`, Unreal `no`/`no`, three.js `partial` with parenthetical `Node v26.11.1`. **[moving]** SEAT-38 owns `engines.md`; re-hash at close before treating the census cells as frozen.

Box 2 pointer: `git hash-object corpus/lessons/r2-independent-review.md` = `git rev-parse HEAD:…` = `a688da6cddcad531000e38b209cfeade2645911f`. `grep -n 'contact plane'` hits lines 37 and 41.

Bleed frame `2026-10-18T21:28:38Z`: `git diff --stat HEAD -- corpus/lessons` → 8 files, `43 insertions, 35 deletions` (`r61`–`r68` only). Added-line scan: lore 0, `2D` 0, harness-id 0. Later frame `2026-10-18T21:38:04Z`: those 8 plus `corpus/lessons/r105-unreal-lifecycle.md` (`+13/−1`), an environment-pairing note under the 2.9 s bullet; heading at line 38 unchanged. r61 hunk observed: historical `.shokunin/game-dev-3d/` command lines re-rooted, plus a `Correction note (r106, 2026-10-18)` paragraph. Not re-classified after 21:38:04Z.

## Queued, not applied

1. Box 1 still has no named non-author verifier. Carried from r104 `LOG.md` (“SHONEN box 1 needs a named non-author verifier”). Acceptance: a reviewer who did not author `SKILL.md` and is not a dispatched seat of this lane records a pointer after re-running the §1 commands. Until then the file stays `[ ]` and the report line stays `[~]`.
2. Box 4 carried defect: `reports/round-105/lesson/bleed.md` FAIL still describes the live lesson (gate section still at `:38` after the r106 note). Acceptance: re-scope or route the gate-audit material, then a non-author bleed review on the new bytes. Keyword absence is not a pass — r105 already showed that.
3. `engines.md` three.js parenthetical `Node v26.11.1` vs live `v26.12.0`. Already queued by SEAT-98. Not a state-cell promotion. Owner: SEAT-38.

## Not claimed

- No full battery, no gate re-run, no Unreal runtime, no `SHONEN.md` / `PROVINCE.md` / `SKILL.md` / `LOG.md` / `SCORECARD.md` write.
- Peer gate PASS is SEAT-70's receipt, not this seat's.
- Lesson-diff counts are a moving frame. Re-count at close before citing them as the round total.
