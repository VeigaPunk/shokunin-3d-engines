# PathCritic — steered round-1 advisory

## Assignment, authority, and limits

Review target: one **calibration** move at the Godot fixture runner's `--runs` boundary. Historical rounds 1–88 are inherited evidence, not rounds to renumber. This report is author-team advisory evidence, not a judgment, admission, external spot-check, promotion, or integration authorization. The canonical Rust judge retains its authority; I did not invoke it or any other runtime.

Read-only source and historical-receipt inspection only. No tests, builds, lint, formatting, fixture execution, negative-case replay, commits, or routing changes were performed. The known relative-path failure was not rerun. Source references below identify the inspected pre-integration sections; line numbers can move during the parent's edit.

**Files changed by PathCritic:** only `reports/round-1-20261015/PathCritic.md`.

## Strongest local counterexample

The strongest available counterexample is already real-engine evidence, not a hypothetical hostile process:

- `corpus/live/r88-baseline/runs/20261014T235009560889Z/tree-timeout-verdicts.json:20-50` records relative `--path ../runs/.../scratch`, a live-setup marker, `timed_out=true`, `actual_exit=null`, `classified=false`, but `witness_verified=false`, `witness_gone=false`, no witness signal, and no cleanup exit. The error adds `Godot cleanup exceeded 3 seconds`.
- `reports/round-88/r88-baseline.md:96-126` records that witness PID 1130413 remained live 18 seconds later and required manual SIGTERM. The normal fixture cases passed; this was not evidence of a changed 3D mechanic.
- `corpus/live/r88-baseline/runs/20261014T235527966109Z/tree-timeout-verdicts.json:20-50` records the absolute-path contrast: verification and disappearance true, SIGTERM to the verified detached witness, cleanup exit -9, while logical timeout still has `actual_exit=null` and `classified=false`.

Thus the old behavior combines a **correct timeout rejection** with a **false probe failure and leaked witness**. Calling the entire old timeout classification wrong would itself be a calibration error.

Mechanism: `timeout_tree3d.gd:18-20` globalizes both helper and pidfile paths before spawning Python. `run_battery.py:692-693,720-721` demands complete argument-string membership using scratch-derived paths. `main:795-798` currently derives scratch from unresolved `args.runs`. The producer and verifier therefore have different spellings of the same intended paths.

**Smallest safe correction:** resolve `args.runs` once, before deriving the timestamp run directory and scratch, and use that single canonical root for creation, commands, witness paths, mutation scratch, and receipts. Do not introduce another path authority inside the identity predicate. Do not replace exact argument matching with substring, basename, broad process search, or filesystem-equivalence matching of an arbitrary process's arguments. Update the obsolete absolute-only warning and the runner instructions, without expanding the move into generic process supervision.

## Falsifiers and impacted axes

| Falsifier / attack | Evidence and impact | Smallest safe response |
|---|---|---|
| Only `.absolute()` or lexical normalization is used, leaving a symlink ancestor unresolved. | The requested contract explicitly includes symlink spellings; absolute-string equality alone is not physical-path canonicalization. Symlink failure is an unexecuted counterexample candidate, not an observed baseline failure. Impacts calibration; potentially operability. | Use `Path.resolve()` at the public boundary. Parent must exercise a real symlink-root run before asserting that acceptance condition. Include a not-yet-created suffix beneath an existing root so resolution does not accidentally require the timestamp directory to preexist. |
| Relative roots are interpreted relative to the fixture directory rather than the caller's working directory. | `argparse` supplies a `Path`; current creation follows caller-CWD semantics. Changing its base silently changes the receipt destination and provenance. | Preserve caller-CWD interpretation; resolve once there. Canonicalizing aliases may intentionally change displayed paths, but must not redirect to a different physical target. |
| Parent repairs path mismatches by weakening ownership verification or killing a name-matched process. | Initial verification at `717-721` requires live state, PPID equal to the live Godot child, PGID equal to witness PID, and both complete argv entries. | Preserve every existing identity condition and signal gate. Path spelling, not ownership, is the variable being repaired. |
| Report says PPID/PGID are rechecked before every witness signal. | `same_live_witness:688-693` rechecks live state, captured starttime and both argv entries; PPID/PGID are checked initially, not in this helper. Reparenting after Godot death is expected. | Say exactly: initial PID/PPID/PGID/argv verification followed by starttime-and-argv identity rechecks. Do not add a post-parent-death PPID condition just to satisfy an overbroad sentence. |
| Report claims authenticated original birth time, race-free PID ownership, or hostile-process safety. | Starttime is sampled from `/proc` at verification (`715-716`); the cooperative witness JSON contains PID/PGID/PPID, not a launch-time starttime token (`timeout_descendant.py:9-11`). Receipt booleans do not expose every raw `/proc` observation. | Preserve the existing bounded identity model. State source-preservation evidence separately from dynamic cleanup evidence; do not claim a new adversarial ownership proof or eliminate inherited TOCTOU limitations. |
| Probe returns PASS by making timeout classify as successful, or by replacing logical exit with cleanup exit. | `classify:519-546`, tree probe `761-770`, and the retained PASS receipt require the logical timeout to remain false, with actual exit null. | Leave classification and expected markers/exits untouched. A successful cleanup probe must still contain a rejected timeout arm. |
| Probe passes without a real live setup, without witness cleanup, or only after forced fallback SIGKILL. | Final gate `766-770` requires the normal arm, marker, timeout, verified/gone witness, cleanup exit, and specifically the SIGTERM cleanup string. | Retain the complete conjunction, deadlines, and failure behavior. No special-case PASS for relative paths. |
| “Same witness” means the same numeric PID across separate absolute/relative/symlink runs. | Each invocation creates a fresh timestamped scratch and launches a new witness. | Compare equivalent identity/cleanup behavior and canonical-root semantics, not PID equality across runs. |
| “All bytes/hashes unchanged” includes canonicalized receipt paths or the edited runner seed. | Receipt commands/scratch intentionally become canonical; `seed_digests:495-501` includes the runner file. | Compare behavioral rows and fixture seeds appropriately. Require within-run `seeds_unchanged=true`; separately disclose intended runner hash and path-field changes against baseline. |

## Necessary real-engine evidence after integration

Parent-owned verification should save exact commands, caller CWD, revision, engine version and raw receipts for:

1. Absolute and relative roots: normal timeout-fixture arm classified true; hold-open arm `timed_out=true`, marker present, `actual_exit=null`, `classified=false`, reasons retaining timeout/no-exit, verification and disappearance true, SIGTERM cleanup, no cleanup error, and non-null cleanup exit. Preserve the existing stricter probe verdict rather than inventing a looser success metric.
2. A symlinked runs root resolving to the intended physical destination, with the same real Godot timeout evidence. This is an additional **unscored acceptance sample**, not silently a third member of the fixed two-arm numeric calibration denominator. Absolute+relative receipts alone cannot establish the symlink claim.
3. Direct process-liveness evidence for the recorded witness PID/starttime after cleanup, where available. A receipt's own `witness_gone` is useful but is not an independent OS-level ownership proof.
4. Original `raycast3d_hit` and `raycast3d_miss` through Godot with their authored markers/exits, plus the parent's full regression battery/probes and seed-preservation comparison. Source inspection or synthetic classifier tests cannot replace engine execution for a real-engine claim.
5. If the runtime-readiness sample is scored, an executable bounded fixture receipt for each counted family/tooling row. Blender has historical support in `reports/round-88/r88-baseline.md:128-142` and `SCORECARD.md:91-127`; three.js remains CPU scene/math without GL. Unity/Unreal static samples must not count as runtime execution.

Historical evidence is explicitly historical: do not claim it was freshly replayed. Before assigning baseline numbers to `db6494332231fccf90a8d3e18e9fa5d2e0df9e47`, parent must supply the committed-source/seed-hash provenance bridge to the inherited receipts. I did not establish that bridge in this review.

## Numeric proposal: bounded split, not expertise saturation

The original bare proposal **depth 10 / coverage 6 / calibration 5→10** is unsafe as a statement about the province. `AXES.md:9-16` defines depth as actionable technical understanding, coverage as the province's real surfaces, and calibration as honest self-assessment. Two raycast controls do not exhaust depth; three tools out of a hand-picked five do not measure production coverage; two cleanup invocations do not exhaust calibration. `PROVINCE.md:3-22` and `SCORECARD.md:13-19` name many unprobed surfaces. `corpus/knowledge/engines.md:6-16` is also an inherited census that does not yet list Blender; do not cite it alone as an up-to-date five-row census.

The parent's clarified split avoids that overclaim if represented literally:

| Finite local subaxis | Fixed observable | Numeric representation |
|---|---|---|
| `depth.raycast-control-readiness` | Successful original Godot hit and miss controls, denominator 2. | `10 × n/2`; 2/2 means 10 only for those controls. |
| `coverage.named-runtime-tooling-readiness` | Executable bounded fixtures for the fixed named sample Godot, three.js, Blender, Unity, Unreal; denominator 5. | `10 × n/5`; 3/5 means 6, not 60% of 3D production expertise. State three.js CPU-only and Unity/Unreal unavailable. |
| `calibration.timeout-path-comparability` | Absolute and relative timeout-cleanup probe successes, denominator 2. | `10 × n/2`; historical 1/2 means 5; after 2/2 means 10 only when actual receipts support both. |

Keep broad depth/coverage/calibration **unscored and unsolved**, not retired or saturated. Carry raw numerator/denominator, fixed sample, formula, commands, receipt pointers and measured revision beside each finite number. Do not average these into a round verdict. The low finite value 5 can motivate the selected calibration move among these declared local readiness samples; it cannot prove calibration is lower than the unknown broad expertise axes. The parent clarified that interpretation during this review, and it is a defensible bounded representation rather than the original broad score claim.

Depth and runtime-tooling readings are baseline bookkeeping, not new depth/coverage improvements. Only timeout-path comparability is the proposed move. Whether integrated evidence meets the canonical judgment remains for the authorized judge; this report issues no verdict.

## Routing, scope, and SHONEN safeguards

- The canonical assignment reports `unknown_role` for the required planner in the UFO validator plan. I did not reproduce that failure. Describe the actual transport as the single host-routed heterogeneous OMP nine-role batch, not a validated UFO wave, validator approval, or 32-lane swarm. Record the mismatch in the operator side channel; do not alter global routing or omit/relabel the planner to manufacture conformance. Fleet `MISSION.md:48-60` explicitly includes planner/connector routing.
- Keep this repair inside the lane's existing fixture/evidence boundary. `PROVINCE.md:33-41` refuses general harness/evidence auditing as a province: the local Godot fixture correction does not confer fleet-wide process-cleanup authority.
- `SHONEN.md:3-9` contains one inherited checked box naming the historical r2 reviewer and evidence. Preserve its historical provenance; I did not revalidate that reviewer or grant new authority. No other boxes become checked because this author-team batch inspected or replayed fixtures.
- Canonical `PROTOCOL.md:63-73` and `LEARNING.md:37-43` explicitly say a lane-dispatched subagent is still the lane. Therefore PathCritic, PathReview and other siblings cannot provide external-review/promotion `[x]` authority. New team assertions may be `[~]` with evidence; untouched boxes remain unchecked. This advisory report does not satisfy the external admit-and-reject spot-check.

**Exact overclaims to forbid:** global depth/coverage/calibration mastery; saturation or retirement at local score 10; full province coverage from 3/5 tools; GPU/browser output from Node math; Unity/Unreal runtime proof from static samples; arbitrary process-tree cleanup; portable non-Linux cleanup; race-free hostile-process ownership; fresh historical replay; symlink acceptance without its engine receipt; same PID across runs; validated UFO routing; externally reviewed or promoted SHONEN status from this batch.
