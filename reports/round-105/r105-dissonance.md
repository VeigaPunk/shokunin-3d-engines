# r105 dissonance — contradictions and dropped carryovers

**Seat:** SEAT-29 DISSONANCE · **Round:** r105 · **Axes:** depth / coverage / calibration  
**Owned path:** `reports/round-105/r105-dissonance.md` only. No commit, push, checkout, or reset.  
**Evidence frame:** 2026-10-18, `20:53Z–21:00:39Z`; shared worktree at base HEAD `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b`. Files continued moving during the frame; hashes and dated claims below are snapshot-qualified.  
**Tags:** **[O]** this seat's command/output · **[C]** peer artifact or historical report · **[?]** not resolved. No Unreal Editor/runtime claim is made.

## Headline

- **C1 — partial.** The corrected Kimi URL is a verified one-line repair (old URL `404`, `-plugin` URL `200`; `1/1` diff). The current lesson is SHA `d089aae7…`, 162 lines: SEAT-02's critic reviews those exact bytes as **REVISE**, and SEAT-03's verification is **PARTIAL**. SEAT-54's **FAIL** is bound to older bytes `dd9b9ac0…`, 155 lines, so it is a material scope signal, not a final-byte ruling. Row F still lacks the critic's required named non-author replay and durable verifier receipt. **[C]** `kimi404/verify.md:5-28`, `lesson/{bleed,critic,verify}.md`, `skill6/critic.md`.
- **C2 — accepted only for explicit Node 24.21.0.** The first run's 350/350 passing rows do not override its top-level `FAIL` / `seeds_unchanged=false`. The later clean rerun is a separate, valid `PASS` receipt: 350/350, 0 failures, 131 seed files, `seeds_unchanged=true`. Default Node remains v26.12.0 and still misses the v24.21.0 markers. **[O]** Parsed the copied rerun JSON and read stdout through its final line; **[C]** `n24/full-run.md:17-26`.
- **C3 — no adopted precedence rule.** Three r105 review files now exist, but the packet mixes P definitions and census outcomes, review targets are not consistently frozen, and no review gives unconditional acceptance of an implemented ruling. **[O/C]** See §2.
- **Static gate — PASS is narrow.** Peer receipts report 4/4 checks, manifest 12/12, 13 cards, census 12/1/0, `POINTERS=103`, `UNRESOLVED=0`, rc 0. The current script hash is `390a25ae…`; the README's numeric 103 matches, but its cited scanner hash `e5521304…` is stale provenance. This gate does not settle P/C or certify the full attack suite on the current script. **[C]** `gate/final-run.md:3-16,28-80`, `gate/integrity.md:30-46`.

## 1. Node profile: row PASS is not the same as battery PASS

**[O]** The first captured receipt, `n24/runs/node24-full-20261018T202944Z.verdicts.json`, records `cases=350, pass=350, fail=0`, but `verdict=FAIL` and `seeds_unchanged=false`. Its stdout ends `FAIL battery`. The second receipt, `n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`, parses to `verdict=PASS`, `cases=350, pass=350, fail=0, ordinary=291, negative_controls=59`, `seeds_unchanged=true`, `seed_files=131`, `result_count=350`, `failures=[]`; its stdout ends `PASS battery` and cites `corpus/live/runs/20261018T204240718894Z/verdicts.json`. At the last process check the runner PIDs were gone. The two receipts must not be collapsed into one verdict.

The cause of the first receipt is bounded but should not be overstated: its snapshot had 130 seed entries; the later rerun has 131 after `PINNED-ENV.md` was added. The first receipt's own flag is red; the second, taken after the tree stabilized, is the accepted result. **[C]** `n24/full-run.md:11-26`.

**Contradictory close-out text.** `r105-report.md:15` now accepts the clean pinned-profile rerun, but `r105-report.md:128` still says “This report does not claim the pinned Node full battery passed.” These cannot both describe the same current summary. `close-receipt.md` records its earlier `20:52:09Z` snapshot and says the rerun was active; that was before the run completed at `20:54:57Z`, so treat that receipt as **superseded**, not as a current failure verdict. The current `n24/full-run.md` and updated `consistency.md:62,121` recognize the successful rerun. **[O/C]**

## 2. P/C packet: current count, conflicting rule, mixed review targets

**[O]** The current review inventory is `review-1.md`, `review-2.md`, `review-3.md`. At the measured frame, hashes were:

- `ruling-draft.md` `0dc0340a…d582dd30`; `distiller.md` `8e572560…20ac3d36`.
- `review-1.md` `72435018…625316f` reviews ruling `0dc034…` with distiller `d337efd2…` and says **REVISE**.
- `review-2.md` `4f7cfa37…ad98469` reviews ruling `0dc034…` with distiller `7c514008…` and says **REVISE**.
- `review-3.md` `bb3343f4…b9af08cc` has a top-level reviewed-snapshot stamp for the current `0dc034…` / `8e572560…` pair and says **CONDITIONAL ACCEPT for operator discussion; NOT READY for implementation**. But its F3 and “Reviewed artifact identities” sections still name the old `c0d14e2e…` / `890df366…` pair (`review-3.md:5,108-118,128-137`). Its review target is therefore internally mixed; do not count it as an unambiguous same-hash review until reconciled.

**The packet's own inventories disagree.** `consistency.md:50` says only review-3 exists and calls its verdict REVISE; the review-3 text says conditional acceptance, and reviews 1 and 2 are present. The current `pc/distiller.md:5,9` says it has the two r105 reports but lists reviews 1 and 3 and says no review-2; review-2 predates that distiller's current mtime. `r105-report.md:16` correctly counts three reports and their observed verdicts, but its claim that all target older distiller revisions conflicts with review-3's current-hash header; that header/body mismatch is why the current review set still cannot be treated as a coherent approval set. **[O/C]** These stale inventory statements remain in the latest files read in this frame.

**The proposed outcomes also conflict.** `pc/impact.md` describes literal-P as flipping the six dissenting cards to **6/7/0**; `pc/ruling-draft.md`'s policy-first P retains **12/1/0**; `pc/distiller.md`'s narrower P-narrow proposes **13/0/0** if the actor path fails its test. Review-2 independently identifies these as materially different branches (`review-2.md:12-18,41`). The README and cards remain unmodified; a gate census cannot choose the semantic rule. No operator ruling or 13-card evidence audit is recorded. **[C]**

**Verdict:** the F7/P-C collision remains open from r101–r104. Three files are not three approvals: two REVISE, one conditional discussion-only recommendation, and no consistent three-review sign-off on the current proposal/diff.

## 3. Lesson and gate evidence boundaries

**Lesson review frame.** Current lesson bytes are `d089aae70c0f…`, 162 lines. The bleed report's `dd9b9ac0…`, 155-line target is stale; it cannot by itself rule the current lesson out of province. The current-hash critic independently finds the concrete Godot fixture result lacks its `verified-here` label and a bound command/receipt/seed digests; verification marks historical scanner, attack, and serial/concurrent metrics **not repeated**. Keep the lesson scope unresolved pending a final-byte scope review and the row-F evidence repair/replay. This is Godot fixture evidence, not an Unreal-runtime claim. **[C]** `lesson/bleed.md:1-3`, `lesson/critic.md:1-4,48-54`, `lesson/verify.md:20-26`.

**Gate pin.** Current `run_gate.sh` SHA-256 is `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`; current `gate/README.md` still attributes the active `POINTERS=103` measurement to `e5521304…` (`README.md:248,283`). `pin-after-edits.md` is right that the number matches; `integrity.md` is right that the provenance hash does not. Preserve both facts rather than calling either the whole pin “clean” or the numeric gate result “failed.” **[O/C]**

The current-SHA attack suite is still open: r104's 30/30 result is bound to `e5521304…`; r105 integrity supplies only network-block and copied byte-flip spot tests, not the complete suite on `390a25ae…`. The r103/README 12-versus-11 attack-count discrepancy and the lesson's historical attack claim were not re-run by `lesson/verify.md:22-24`. **[C]** `consistency.md:76,110-111`, `lesson/verify.md:22-24`.

## 4. Cross-round contradictions and dropped/open items

1. **`mode_ok` guard — omitted from r105; r104's “zero carriers” was too broad.** The r103 physics ledger's R2 (D2) explicitly requires `_finish()` to fail on `mode_ok=0` (`reports/round-103/physics/ledger.md:294-298`). r104's `physics/adversary.md:259,264,317` explicitly says the guard was not landed and names it as an open repair. That contradicts `r104-dissonance.md:376-403`'s “zero r104 carriers” claim (its `degraded_cell`-only grep missed the `mode_ok` wording); it does **not** contradict that the code fix was absent. Current `phys3d_joints.gd:118-120` still prints PASS then `quit(0)` without checking `_parts`. **[O]** No `mode_ok` or `degraded_cell` occurrence was found in r105 Markdown during this review, and `physics-carry.md` only confirms the fixture is unchanged. This guard remains an unimplemented carry.
2. **Gate receipt / standing harness (r101 R7/IP-2; r102 O4) — still open.** r105 has a manual stdout/stderr/rc transcript, but no standing integration is shown. `run_battery.py`'s `seed_digests()` is rooted at fixture `HERE.rglob`, not the Unreal-MCP knowledge subtree or gate; `Grep` found no `run_gate` in `corpus/knowledge/engines.md`. A manual receipt is useful evidence, not the missing durable harness/receipt path. **[O/C]** `consistency.md:39,52`.
3. **Unruled decisions still carried:** F3/F5/F6 accept-or-overrule (r102 O8), systemic `.shokunin`-root scope (r103 O6 / r102 R7 residual), P/C precedence (r101 F7), and the C7 control-count/command gap (r103 O10) have no recorded ruling/fix in the current register (`consistency.md:50,56,63,77,81`). Do not mark them closed because a gate or report count is green.
4. **Mixed BLOCKED+FAIL (r103 O3 / r104 O5) remains live.** Current code returns exit 2 only when `C2_BLOCKED=1 && FAILS=0`; with another failing check it falls through to generic FAIL/exit 1 (`run_gate.sh:436-442`). The r105 green gate does not exercise this branch. **[O/C]**
5. **`--path .` fixture-write isolation (r103 O11 / r104 O13) remains unguarded.** `phys3d_joints.gd:135-137` creates each child below `res://r90bt_*`; an empty scratch-directory snapshot would not prove a prevention mechanism. **[O/C]**
6. **Node markers are profile-specific, not erased:** the v24.21.0 clean full rerun closes the explicit profile, but default v26.12.0 still mismatches the 13 pinned positive markers (`consistency.md:62,79,112`).
7. **Other named carries in the r105 register:** stale math-audit F3 frame, unexplained empty-jolt curiosity, SKILL scan-scope/non-author verification, repo-root scratch convention, no Unreal Editor, and the complete current-SHA attack suite (`consistency.md:54,76,81,83,106-115,167`). The r105 register also catches r104's own accounting mismatch: its row arithmetic is 53, while its prose says 51 (`consistency.md:11`).

## 5. Limits

This is a dissonance report, not an axis verdict or operator ruling. The green gate establishes static checks only; the Node 24 run establishes only its bounded fixture outcomes. No Unreal Editor/runtime evidence exists. The cited reports and source files were read-only for this seat; this report is the only path written here.
