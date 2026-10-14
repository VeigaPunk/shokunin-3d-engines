# game-dev-3d round 84 — verifier (seat: verifier; host: devin)

Independent replay on committed HEAD **01f7d4f** (`r84: backend
pinning — jolt_edge child re-exec + phase_delta first-class cell`, ci
2026-10-14 14:50:47 -0300). Commit contents: 4 files — `phys3d_events.gd`
(+396/6), `run_battery.py` (+4/0), `README.md` (+28/0), `r84-author.md`
(+189). Working tree identical to HEAD (`git status` clean on
`corpus/`). Scratch confined to `corpus/live/r84-verifier/`; this report
is the only other write. No git mutations, no subagents (leaf). Godot
`4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`), python3 on this
host — the build the author pinned.

## Item 1 — battery replay ×2 on committed HEAD → **AGREE (188/188 ×2)**

`python3 corpus/fixtures/run_battery.py --runs <abs path>` twice,
independent run dirs:

| run | dir | totals | verdict | seeds_unchanged | battery exit |
|---|---|---|---|---|---|
| V1 | `corpus/live/r84-verifier/runs/20261014T175211547739Z` | 188/188 (142 ord + 46 neg) | PASS | true | 0 |
| V2 | `corpus/live/r84-verifier/runs2/20261014T175525729401Z` | 188/188 | PASS | true | 0 |

(`battery_run{1,2}.log` in `corpus/live/r84-verifier/`.) Reproduces the
author's two clean 188/188 PASS batteries
(`runs/20261014T173849346559Z`, `…174318041429Z`).

## Item 2 — case tables byte-identical ×4 + child.log ×4 → **AGREE**

Normalized per-record `command`/`elapsed_seconds` and top-level
`started_utc`/`scratch` (same contract as the r83 comparator;
`corpus/live/r84-verifier/compare_verdicts.py`):

    results sha256 (all four r84 runs: author×2, verifier×2):
    73ee6fcbfd7781bb5ea6d036f350812120cf024ca0da17a35e38f5f75783efdf

Every case's expected/actual exit, marker, verdict, reasons, and full
stdout/stderr arrays equal across four independent executions. Both new
cells verified classifier-clean in my receipts: exit-0 exact `PASS`
markers, **0 stderr lines, 0 reasons**. New-row elapsed on my runs:
`phase_delta` 0.835 s / 0.660 s, `jolt_edge` 1.376 s / 1.212 s — same
margin class as the author's 0.783 s / 1.419 s vs the 20 s case timeout
(~14× headroom claim holds).

`*/scratch/joltproj/child.log` is **byte-identical in all four r84
runs**, sha256
`4b8c0e881cc70ff5a7f14684853ab0e4fbacb155ecd503fe1b28e564ba76dfbb`:
`CHILD_RESULT jolt_backend=Jolt Physics` + the five-arm verdict map
(`isect=same-signature`, `cast=differs-constants`,
`btm=differs-constants`, `contact_stale=same-signature`,
`static_nopair=inverts`) — verbatim the block quoted at
`r84-author.md:117-130`. Zero `ERROR:`/`SCRIPT ERROR`/`Parse Error`
lines (`grep -c` = 0 on both my copies), so the zero-expected-class
scan is exercised and clean.

## Item 3 — prior 186 byte-compare → **AGREE (three levels)**

- **CASES list level**: AST-parsed `CASES` at `HEAD~1` (`c4b2fa2`) vs
  `HEAD`: 186 → 188, `new[:186] == old` exactly; the diff is a pure
  `+4/0` hunk at `run_battery.py:439-442` (two tuples appended before
  the closing `]`), matching the claim.
- **Results level, within-round**: the first 186 records of all four
  r84 runs are byte-identical to each other.
- **Results level, cross-round**: the first-186 normalized sha of every
  r84 run is `c0c3fcbbd1c797373ebee5232b0f9e627290ece63b925cb4c1f21b42c0719a7e`
  — **exactly the r83-verifier normalized hash** measured on the
  committed r83 receipt (`corpus/live/r83-verifier/runs/
  20261014T165952311674Z/verdicts.json`). Zero drift in the prior
  battery across the r84 insertion.
- **Seed-map level**: `seed_digests` (55 files) identical across all
  four r84 runs; the map records `phys3d_events.gd` at `255dcab5…` —
  the committed file — proving the battery ran against HEAD seeds.
  (r84 vs r83 maps differ, expected: the commit itself edits three
  seed files.)

## Claim-by-claim on `r84-author.md`

| # | claim (report line) | verdict | evidence |
|---|---|---|---|
| 1 | `phys3d_events.gd` +396/6, sha256 `255dcab5…`; 6 deletions doc/dispatch-only; every pre-existing arm byte-identical | **AGREE** | `sha256sum` = `255dcab56e5db479aa27e8d0cada0773c8547027cfe7e12464063d3191d536e6`; `git show --numstat` = `396 6`; the six `-` lines are the header Jolt note (:5-9), the `--child` dispatch comment pair, and the `await _child_threaded()` dispatch line — no arm-body line touched |
| 2 | `phase_delta` arm :576-649: proc-phase write → `body_entered` delta=2 vs physics-phase delta=1; `sig_log.clear()` + `left==0` gate :634-635 | **AGREE** | fixture :576 match arm; `await process_frame` write :610-628 pins `proc_delta==2`; `sig_log.clear()`/`left` at :634-635; marker `proc_delta=2 phys_delta=1` at :649 — reproduced in both my battery rows and the `def_phase_delta`/`jolt_phase_delta` probe receipts (`proc w0=0,0 n1=0,0 n2=1,1 delta=2; phys n1=1,1 delta=1`) |
| 3 | `jolt_edge` parent :651-721: hint gate → `BLOCKED … jolt_absent=true` + exit 1 (:660-669); generates `res://joltproj/project.godot` (:670-679); `/bin/sh -c 'timeout -s KILL 30 … > child.log 2>&1'` (:686-690); log scan collects `CHILD_RESULT` + flags any `ERROR:` class (:691-709); requires `child_exit==0` + exact six-entry map (:710-720) | **AGREE** | fixture verified line-by-line at :660-720 (expect dict :710-717, compare :718-720 — see nit below); the generated project and `joltproj/child.log` exist in my own runs' scratch |
| 4 | `_child_jolt()` :791-1003: backend pin `CHILD_RESULT jolt_backend=Jolt Physics` iff `JoltPhysicsServer3D` ∧ ¬`GodotPhysicsServer3D` (:794-803); five reduced arms emit `CHILD_NOTE` + classified `CHILD_RESULT` | **AGREE** (span nit: file ends :1001) | `func _child_jolt()` :791, `quit(0)` :1001; ClassDB pair at :794-803; classifiers at :830-835 (isect), :849-860 (cast), :887-895 (btm), :923-929 (contact_stale), :989-998 (static_nopair inverter: `tp[6]>=1 ∧ tp[7]==1 ∧ tp_delta==1`) |
| 5 | `run_battery.py` +4/0 appended at :439-442; prior 186 rows byte-identical | **AGREE** | Item 3; `git diff` shows the `+`-only hunk; new rows expect exit 0 with the quoted markers |
| 6 | `README.md` +28/0: "PhysicsServer3D backend split + write-phase delta (round 84)" :599-625, ahead of determinism rules | **AGREE** | section spans :599-625 exactly; `## Determinism rules` remains the last section at :627 |
| 7 | Probe table: isect/contact_stale same-signature; cast/btm differs-constants (Jolt `0.14984130859375`/`0.1500244140625`, `-0.99853515625`); static_nopair inverts (Jolt `n1 sig=1 ov=1` delta=1 vs DEFAULT silent); phase_delta identical deltas | **AGREE** | every quoted value present in `corpus/live/r84-author/runs/{def,jolt}_*.{stdout,exit}`: `def_jolt_cast` `0.14453125/0.150390625`, `jolt_jolt_cast` `0.14984130859375/0.1500244140625`; `def_jolt_btm` `-0.9765625`, `jolt_jolt_btm` `-0.99853515625`; `def_jolt_static_nopair` `w0..n3=0,0 delta=-1`, `jolt_jolt_static_nopair` `n1=1,1 delta=1`; both phase_delta probes `delta=2`/`delta=1` — all `.exit=0`, and the five 3-rep probes are byte-identical per arm (1 unique sha each) |
| 8 | Gate: hint `DEFAULT,Jolt Physics,GodotPhysics3D,Dummy` on both projects; class pair swaps exactly one member | **AGREE** | `{jolt,def}_gate.stdout.txt`: identical hint line; `jolt_class=true godot_class=false` under Jolt vs `false/true` under DEFAULT |
| 9 | Battery: subset `--only phys3d_events_phase_delta,phys3d_events_jolt_edge` → 2/2; full 188/188 ×2 `seeds_unchanged=true`; cross-run diff zero; seed digest maps identical | **AGREE** | `…173843058582Z/verdicts.json` `only=<2 names> cases=2 pass=2`; both full verdicts `PASS 188/188 seeds_unchanged=true`; Item 2 — identical normalized sha and seed_digests across all four runs, independently reproduced ×2 |
| 10 | New rows' elapsed 0.783 s / 1.419 s vs 20 s timeout ~14× headroom | **AGREE** | author run1 receipt records exactly 0.783 / 1.419; `CASE_TIMEOUT_SECONDS=20` at `run_battery.py:36`; my runs land the same class (0.66-0.84 / 1.21-1.38) |
| 11 | `jolt_edge` child receipt block (:117-130) verbatim; no error-class lines | **AGREE** | my `runs/*/scratch/joltproj/child.log` is byte-identical to the author's (sha `4b8c0e88…` ×4) — the quoted block is the file content minus the engine banner; `grep -c 'ERROR\|SCRIPT ERROR\|Parse Error'` = 0 |
| 12 | Impersonation witness: DEFAULT-copy child prints `jolt_backend=unexpected` + all-`same-signature`; parent map mismatches on `jolt_backend` + `jolt_static_nopair` — silent fallback cannot fabricate PASS | **AGREE** | `corpus/live/r84-author/scratch_fakechild/child.log` shows exactly `jolt_backend=unexpected` and `jolt_static_nopair=same-signature` (two-entry mismatch vs the pinned map), all other arms `same-signature` |
| 13 | Hazards: `:=` cannot infer through Variant indexing (annotated `: bool`); BLOCKED compile-gated on this host; subset/extra `CHILD_RESULT` fails named; 6 frames suffice for re-pair; `joltproj` inside battery scratch | **AGREE** | `var silent: bool`/`var fired: bool` at :990-991; gate branch :664-669 is `print(BLOCKED)+quit(1)` — on this host the hint always contains `Jolt Physics` (receipts Item 8), so unexecuted here, failure mode is named exit-1; `verdicts != expect` at :718 fails named on subset/extra; fixture `await _frames(6)` :633 with `left==0` gate; my runs' `scratch/joltproj/` confirms scratch-local |
| 14 | Remaining risks disclosed (Jolt-latency re-class → `unexpected`; five-arm minimum only; Jolt×threaded unprobed; server-write phase path unprobed; `body_exited` unmeasured; bounds this host/build/60 tps) | **AGREE** (consistent) | `_child_jolt` covers exactly the five declared arms — `pp_queries`/`contact_sig`/`sync_cb`/`srv_area_cb`/`threaded_edge` have no Jolt cells; `unexpected` class exists and fails the parent's map loudly (:830/:849/:887/:923/:989) |
| 15 | Files changed summary; leaf discipline (no subagents, no git mutation, work left for integrator) | **AGREE** | `git show --stat` = the four files with the quoted numstats; nothing else in the commit; working tree clean |

## Minor nits (non-blocking)

- `r84-author.md:56` cites `_child_jolt()` as `:791-1003` — the file is
  1001 lines; the body is **:791-1001** (`quit(0)` at :1001). If the
  :782-790 comment block is counted, the span is :782-1001.
- `r84-author.md:51-55` cites the log scan as `:691-709` — the
  `FileAccess.open` is at :693; :691-692 are the `verdicts`/`script_err`
  declarations. Content correct in both cases.

## Remaining risks (bounded, shared with author)

- The `BLOCKED`/`jolt_absent=true` path is compile-gated on this host —
  reviewed, unexecuted; its failure mode is a named FAIL row, not a
  fabricated PASS.
- `static_nopair` is pinned `inverts` at exactly delta=1/ov=1; a Jolt
  build firing at a different latency classifies `unexpected` — loud,
  needs re-measure to re-pin.
- Jolt coverage is the five reduced arms; the remaining lattice cells
  and the `Jolt × threaded` cross-product stay unprobed — disclosed.

**Bottom line: AGREE on all 15 claims.** The committed tree reproduces
188/188 twice with `seeds_unchanged=true`; all four r84 case tables are
byte-identical (`73ee6fcb…`); the prior-186 prefix hashes to the
r83-verifier value `c0c3fcbb…` exactly; the `jolt_edge` child receipt
is byte-identical across four runs (`4b8c0e88…`) with zero error-class
lines; and the impersonation witness proves the split cannot be
fabricated by a silent GodotPhysics fallback. Two line-ref nits; no
substantive discrepancies.

Receipt paths: `corpus/live/r84-verifier/runs/20261014T175211547739Z/`,
`corpus/live/r84-verifier/runs2/20261014T175525729401Z/` (each with
`verdicts.json`, `scratch/joltproj/child.log`), logs
`corpus/live/r84-verifier/battery_run{1,2}.log`, comparator
`corpus/live/r84-verifier/compare_verdicts.py`, CASES checker
`corpus/live/r84-verifier/check_cases.py`. Stopping here — leaf.
