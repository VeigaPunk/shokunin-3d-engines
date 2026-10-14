# Game-dev-3d round 73 — reviewer (non-author audit of round 72 committed state)

Reviewer did not author r72. Audited committed state: r72 work `05405ae`
plus adjudication `f95a16e` (post-work landing `3f6a03d` = HEAD at audit
time) in canonical repo `~/Projects/shokunin/game-dev-3d-shokunin`, reached
via worktree symlink `~/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d`.
Scratch confined to gitignored `corpus/live/r73-reviewer/`; this report is
the only tracked write. No commits, no subagents, LEAF.

Host: devin; `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(matches r72 pin), Python 3.14.7, Node v24.21.0, three.js 0.186.1
(pre-provisioned `corpus/fixtures/three/node_modules`).

## 1 — Fresh full battery re-execution: reproduced (112/112 + 4 probes)

Command (from canonical repo root, absolute `--runs` per the documented
convention):

```
python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
  --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r73-reviewer/runs \
  --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
```

Exit 0, `PASS battery`. Receipt
`corpus/live/r73-reviewer/runs/20261014T013323569334Z/verdicts.json`:

- `totals = {cases: 112, pass: 112, fail: 0, ordinary: 67, negative_controls: 45}` — **112/112 PASS**.
- `seeds_unchanged = true`; `seed_digests` 52 keys, **byte-identical to the
  r72-author receipt** (`corpus/live/r72-author/runs/20261014T004642048951Z/verdicts.json`) — same committed seeds exercised.
- Probes **4/4**: `crash_probe_ok=true`, `stream_probe_ok=true`,
  `tree_probe_ok=true`, mutation probe `verdict=PASS` (`detected=true`,
  `mutant_body3d_contact` exit 1 with the authored contact-plane diagnostic —
  `mutation-verdicts.json`).
- `godot_version = 4.7.2.stable.arch_linux.ed1daf0bf`; `verdict = PASS`.
- All 27 detour rows PASS with `marker ∈ stdout` (exact-line membership
  verified receipt-side, not just exit codes).

## 2 — Byte-exact spot-checks (3 pdd/finished arms): verbatim

Scratch `corpus/live/r73-reviewer/scratch/` holds copies verified
byte-identical to committed blobs at HEAD: `navagent3d_detour.gd` sha256
`ea722a750818d06a50db5f3cdaeae1738fae29944ad0de54034e444a7d1f4da0` (=
r72-author's claimed post-change digest; `git show HEAD:` agrees),
`project.godot` sha256 `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`.
Each arm run as `timeout 30 /usr/bin/godot --headless --path <scratch>
--script res://navagent3d_detour.gd -- --arm=<name>`; programmatic compare
of the stdout marker line against the CASES-pinned literal in
`run_battery.py`:

| arm | exit | byte-exact vs CASES |
|---|---|---|
| `vert_pop_eq` (strict pop at euclid==pdd==1.0) | 0 | **True** |
| `fin_idx_gate` (idx==size−1 conjunct) | 0 | **True** |
| `edge_eq` (inclusive reachable at tdd==gap) | 0 | **True** |

Observed markers (verbatim stdout lines):

    PASS navagent3d_detour vert_pop_eq idx=1 next=2.000000,0.000000,1.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=false
    PASS navagent3d_detour fin_idx_gate before_idx=1 after_idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=1.500000 reachable=false reached=false finished=false
    PASS navagent3d_detour edge_eq idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000 reachable=true reached=false finished=false

## 3 — r72 model's five clauses: all hold on my fresh receipt

From `20261014T013323569334Z/verdicts.json` measured rows:

1. **Strict pop `<`** — `vert_pop_eq` idx=1 at exact euclid==pdd==1.0 (no
   pop) vs `vert_pop_above` pdd=1.01 → idx=2; `tp_eq` post-teleport at
   exact 1.0 → `after_idx=1` on the fixed stored path.
2. **Saturation at size−1** — `pop_sat` pdd=5.0 → idx=2 = size−1 on the
   3-point path; `next` returns the final point, `finished=false`.
3. **idx==size−1 conjunct** — `fin_idx_gate`: agent teleported ONTO the
   clamped final (euclid→final = 0 < pdd=1.0) yet `finished=false`
   because idx stayed 1.
4. **Reachable-selector inclusive** — `edge_eq`: euclid(final→T)=1.5 ==
   tdd=1.5 → `reachable=true` while strict `reached` fails →
   `finished=false`.
5. **Sawtooth (non-monotone finished)** — `edge_unr` (tdd=1.4)
   `finished=true` → `edge_eq` (tdd=1.5) `finished=false` →
   `edge_above` (tdd=1.6) `finished=true`: T,F,T across the boundary.

Fixture mechanism re-inspected (`navagent3d_detour.gd:246-407,421-478`):
`_arm_cfg` authors each arm's spawn/target/pdd/tdd/tp AND expected tuple;
`_run_pop_arm` fails exit 1 with a named diagnostic on any tuple mismatch —
per-clause falsification paths are live; rows cannot self-tune.

## 4 — Prior-row stability: reproduced

My receipt vs r71-author receipt
(`corpus/live/r71-author/runs/20261013T233731295600Z/verdicts.json`) on the
12-field tuple (case, script, flags, expected/actual exit, kind, marker,
verdict, reasons, stdout, stderr, error):

- prior rows absent in mine: **none**; new-only rows: exactly the **22**
  r72 `navagent3d_detour_*` arms; **0 mismatches over 90 cases × 12 fields**.
- r72 diff scope re-verified: `git diff 996ea37..05405ae` on
  `corpus/fixtures/` = `navagent3d_detour.gd` +297/−1, `run_battery.py`
  +44/−0 (22 additive CASES rows, zero prior rows touched);
  `git diff 05405ae..HEAD` on `corpus/fixtures/` is **empty** (f95a16e and
  3f6a03d are reports/LOG/SCORECARD/lesson only).

## 5 — Node three.js suites: reproduced (31/31)

From canonical repo root, `node corpus/fixtures/three/run_<s>.mjs --receipt
corpus/live/r73-reviewer/node/run_<s>.json` → run_cases 3/3,
run_layer_cases 4/4, run_order_cases 9/9, run_camera_cases 5/5,
run_ortho_cases 5/5, run_ray_cases 5/5 = **31/31 PASS**, every suite
`seedsUnchanged=true`, every exit 0. Receipts
`corpus/live/r73-reviewer/node/run_*.json`.

## 6 — The r72-verifier's `--runs` trap: reproduces exactly, fails closed

Same battery re-run with **relative** `--runs`
(`--runs corpus/live/r73-reviewer/runs-rel`):

- exit 1, `FAIL battery` — receipt
  `corpus/live/r73-reviewer/runs-rel/20261014T013323581786Z/verdicts.json`:
  all **112/112 cases still PASS**, `seeds_unchanged=true`, crash/stream/
  mutation probes fine, but **`tree_probe_ok=false`** → battery `verdict=FAIL`.
- `tree-timeout-verdicts.json` (REL): `timed_out=true`,
  `marker_observed=true`, witness found (pid/pgid/ppid recorded) but
  **`witness_verified=false`, `witness_gone=false`, `cleanup_exit=null`**,
  error `TIMEOUT after 3 seconds; Godot cleanup exceeded 3 seconds`.
- ABS counterpart: `witness_verified=true`, `witness_gone=true`,
  `witness_cleanup="SIGTERM to verified detached witness"`,
  `cleanup_exit=-9` — the passing path verifies and signals the witness.
- No leaked process after either run: `/proc/1243766` absent and
  `pgrep -fa timeout_descendant` clean — the unverifiable witness
  self-terminates via `timeout_descendant.py`'s `time.sleep(30)`, so the
  REL failure mode is a bounded (~30 s) self-reaping orphan, not a
  permanent leak. Consistent with the r69-author diagnosis.

**Documentation pin — the trap IS documented in tracked files, but NOT in
the runner's own doc surfaces:**

- Tracked evidence/ledger: `SCORECARD.md:27` (r72 calibration row),
  `LOG.md:772` (r72 entry) and `LOG.md:744` (r69 entry),
  `reports/round-69/r69-author.md:57-61` ("Rule for reviewers: always pass
  absolute `--runs`"), `reports/round-69/r69-verifier.md`,
  `reports/round-72/r72-verifier.md:31-52` + `:175-179`,
  `reports/round-72/r72-adjudicator.md:46`.
- Absent from operational surfaces a fresh dispatch reads first:
  `corpus/fixtures/README.md` run section (line 23 documents the `--runs`
  override with no absolute-path requirement), `run_battery.py` docstring
  (lines 1-15), and no `corpus/lessons/*` file records it (grep over the
  tracked tree — the r72 lesson `r72-navagent-pdd-finish-review.md` does
  not mention it). The adjudicator deferred it as "docstring-note
  candidate for a future round"; **that note never landed** — r73's own
  seat briefs still carry the risk unless they spell `--runs` absolute.

## 7 — r73-author diff check

No r73 author diff touching prior arms exists at audit time: canonical
repo HEAD is `3f6a03d`, `git status --porcelain` empty, fixtures unchanged
since `05405ae`. Sibling r73 seats (baseline/scout/boundary/simplifier)
have gitignored scratch under `corpus/live/r73-*` only; `reports/round-73/`
held no tracked files when checked. If the r73 author lands its declared
NavigationLink3D gating arms after this audit, the byte-stability of the
existing 112 CASES rows (this report's §4 comparison is the reference) is
the drift check to re-run.

## Findings by severity

- **No defect in the audited r72 committed state.** Every claim
  re-executed clean: 112/112 + 4/4 probes + Node 31/31, 0-mismatch prior
  rows, byte-exact arms, all five model clauses holding.
- **Minor / documentation gap (pre-existing, non-blocking):** the
  relative-`--runs` tree-timeout trap is recorded in tracked ledger/report
  files but remains absent from `corpus/fixtures/README.md`, the
  `run_battery.py` docstring, and `corpus/lessons/*` — the surfaces a
  fresh seat reads. Any dispatch spelling `--runs` relative
  deterministically burns a full battery into FAIL. Recommend the
  one-line docstring/README note the r72-verifier and adjudicator both
  flagged; not this seat's write scope.

## Residual risk / verification gaps

- Bounded replay: same host, same Godot build, stationary/teleported agent,
  single authored L-corridor — the r72 author's stated bounds (no live
  locomotion, avoidance, mid-path updates, other builds) stand; I
  re-executed, did not widen coverage.
- The compared battery receipts are gitignored on-disk artifacts
  (carried-forward caveat from r72-reviewer §residual).
- The r68/r69 `navagent3d_retarget` intermittence did not manifest in
  either of my two full passes; caveat remains open, not refuted. Note: a
  sibling lane (`game-dev-2d` r64-baseline) battery ran concurrently on
  this host during my runs — shared-host load existed and both my passes
  still returned 112/112.
- This report is a recommendation; admission belongs to the canonical
  judge.
