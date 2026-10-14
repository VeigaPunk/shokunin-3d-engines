# game-dev-3d round 83 — verifier (seat: verifier; host: devin)

Independent replay on committed HEAD **e9145d9** (`r83: PhysicsServer3D
two-tier lattice — queries edge-0 vs events tick-bound; Jolt gate + ST
access-window`, ci 2026-10-14 13:57:26 -0300). Commit contents: 4 files,
867 insertions, no deletions — `phys3d_events.gd` (new, +597),
`run_battery.py` (+20 = 10 CASES rows), `README.md` (+28 = 1 section +
restored heading), `r83-author.md` (+222). Working tree identical to HEAD
(`git status` clean on `corpus/fixtures/`). Scratch confined to
`corpus/live/r83-verifier/`; this report is the only other write. No git
mutations, no subagents (leaf). Godot `4.7.2.stable.arch_linux.ed1daf0bf`
(`/usr/bin/godot`), python3 on this host — same build the author pinned.

## Item 1 — battery replay ×2 on committed HEAD → **AGREE (186/186 ×2)**

`python3 corpus/fixtures/run_battery.py --runs <abs path>` twice,
independent run dirs (absolute path per the runner's own docstring; the
tree-timeout probe needs it):

| run | dir | totals | verdict | seeds_unchanged |
|---|---|---|---|---|
| V1 | `corpus/live/r83-verifier/runs/20261014T165952311674Z` | 186/186 (140 ord + 46 neg) | PASS | true |
| V2 | `corpus/live/r83-verifier/runs2/20261014T165952317655Z` | 186/186 | PASS | true |

Battery exit 0 both times (`battery_run1.log`, `battery_run2.log` in
`corpus/live/r83-verifier/`). Reproduces the author's claim of two clean
186/186 PASS batteries (`runs/20261014T164612500349Z`,
`…165207093423Z`).

## Item 2 — verdicts.json case tables byte-identical ×4 → **AGREE**

Normalized the volatile per-record fields (`command` embeds the per-run
scratch path; `elapsed_seconds` is wall clock) and top-level
`started_utc`/`scratch`, then byte-compared the serialized `results`
arrays across all four receipts (`corpus/live/r83-verifier/
compare_verdicts.py`):

    results sha256 (all four runs):
    c0c3fcbbd1c797373ebee5232b0f9e627290ece63b925cb4c1f21b42c0719a7e

author×2 and verifier×2 produce a **byte-identical 186-record case
table** — every case's expected/actual exit, marker, verdict, reasons,
and full stdout/stderr line arrays equal. Both new-case cells verified
classifier-clean in my receipts: 9× exit-0 `PASS` markers + 1× exit-2
`NEGATIVE REJECTED` marker, **0 stderr lines, 0 reasons** on all 10.

`phys3d_events_threaded_edge` child evidence reproduced:
`*/scratch/thrproj/child.log` carries `CHILD_RESULT pp_edge0=true
proc_dss_refused=true srv_ok=true` + `CHILD_NOTE early_null=false` +
**11** `Space state is inaccessible right now` ERRORs in both my runs —
matching the author's 11/12 ×3 and the ≥8/12 pinned threshold (the pin
is `nulls >= 8` at `phys3d_events.gd:576`, a threshold not an exact
count, consistent with the report's majority-refused framing).

## Item 3 — prior 176 CASES byte-compare → **AGREE (three levels)**

- **CASES list level**: AST-parsed `CASES` from `f8a088c` (parent) vs
  `e9145d9` (HEAD): 176 → 186, `new[:176] == old` exactly; sha256 of the
  literal list `b8ba801b8778cc52db5673e29ad8777406a54e922bd307eab378a67a6afa9b6e`
  on both revisions. The diff is pure insertion at `run_battery.py:419-438`
  as claimed.
- **Results level, within-round**: the first 176 records of all four r83
  runs are byte-identical to each other.
- **Results level, cross-round**: my r83 first-176 records are
  byte-identical to the r82-verifier receipt
  (`corpus/live/r82-verifier/runs/20261014T154155913808Z/verdicts.json`,
  176/176 PASS on the pre-r83 tree) — normalized sha
  `e2fcba9d00acdc6c1541d01fbeebf0dad6b55200cf6f5b151eb632e43725d3b2` on
  both. Zero drift in the prior battery across the r83 insertion.

## Claim-by-claim on `r83-author.md`

| # | claim (report line) | verdict | evidence |
|---|---|---|---|
| 1 | Jolt gate: `JoltPhysicsServer3D` false under DEFAULT, classes swap under `"Jolt Physics"`; build `4.7.2.stable.arch_linux.ed1daf0bf`, engine unset → DEFAULT | **AGREE** | `r83-author/runs/probe1.stdout.txt:4,8`; `r83-boundary/runs/inventory.stdout.txt:16-17` (Jolt=false, GodotPhys=true under DEFAULT) vs `jolt-inventory.stdout.txt:16-17` (swapped). `godot --version` on this host prints the same build string. |
| 2 | hint string `DEFAULT,Jolt Physics,GodotPhysics3D,Dummy` | **AGREE** (line-ref nit: at `probe1.stdout.txt:13`, report says :16) | `probe1.stdout.txt:13`; boundary `jolt-inventory.stdout.txt:14` identical |
| 3 | `PhysicsServer3DManager` exposes exactly `{register_server, set_default_server}` — no enumeration API | **AGREE** (refs :10-11/:14, report says :11-15) | `probe1.stdout.txt:10-11`; boundary `inventory.stdout.txt:23` `METHODS PhysicsServer3DManager ["register_server", "set_default_server"]` |
| 4 | fixture sha256 `6ddf4aef…` new at HEAD | **AGREE** | `sha256sum corpus/fixtures/phys3d_events.gd` = `6ddf4aefde97d31673f337699ba1dedbe9e6caf4226917225577a36b8ac4fab3`; file is 597 lines, `extends SceneTree` at :36 |
| 5 | `PPQueries` inner class at :141-194; `_child_threaded` at :546 | **AGREE** | `phys3d_events.gd:141` `class PPQueries extends Node:` (body ends :194); `:546` `func _child_threaded()` |
| 6 | run_battery.py +10 rows at :419-438, pure insertion | **AGREE** | Item 3; `git diff f8a088c e9145d9` shows `+`-only hunk |
| 7 | README +1 section :561-587, "Determinism rules" heading restored | **AGREE** | `README.md:561` `## PhysicsServer3D two-tier lattice (round 83)` … `:587`; `## Determinism rules` intact at :589 |
| 8 | two full batteries 186/186 PASS, `seeds_unchanged=true` | **AGREE** | author verdicts.json ×2 both `verdict=PASS pass=186 seeds_unchanged=True`; independently reproduced (Item 1) |
| 9 | intermediate `…164857262617Z` FAIL = self-inflicted mid-run README edit | **AGREE** | that verdicts.json has `verdict=FAIL, seeds_unchanged=false, pass=186/186` — case-pass with tripped seed digest, exactly the described mechanism. Confirmed forensically: run1's `seed_digests` show `README.md` at pre-edit `130c7bcc…` vs committed `20115e92…` (see nuance below) |
| 10 | `--only` subset run 10/10 PASS (`…164604096927Z`) | **AGREE** | verdicts.json `only=<10 phys3d_events names>, cases=10 pass=10 verdict=PASS` |
| 11 | query tier edge-0 witnesses (isect/cast/btm, both directions, both callsites) | **AGREE** | `p2_isect.stdout.txt`: `settled hits=1 → w0_sameturn hits=0 → back_w0 hits=1`; `p2_cast`: `settled safe=0.14453125 unsafe=0.150390625 → w0 [1.0,1.0]`; `p2_btm`: `settled hit=true travel -0.976562 → w0 hit=false -10.0`; `p4_pp_*` + `p6_pp_contacts` (`pre_c=4 w0_c=4`) for in-callback callsite |
| 12 | event tier binds at tick: contact_count stale both directions; body_entered/monitor cb delta=1; sync_cb per-tick, static never fires | **AGREE** | `p6_contact_stale` (`in_w0 c=0 isect=1 → in_n1 c=4`; `out_w0 c=4 → out_n1 c=0`); `p3_tp_rigid` (`w0 log=[] → enter@f5 delta=1`); `p4_srv_area` (`cb status=0@f5`, `1@f9`, `0@f10`); `p2_sync_cb` (`count 0→1→3`, frames [5],[5,6,7]); battery marker `static_cb=0` |
| 13 | pair-scope rule: teleported STATIC never re-pairs, moving the area fires next tick | **AGREE** | `p3_tp_static`/`p3_add_inside` silent through 4 ticks; `p4_static_pair` server-level (`tp_in n2 log=[]`, `area_back n5 enter`); negative case `phys3d_events_static_nopair` exit 2 PASS |
| 14 | threaded cell: pp queries still edge-0; process DSS refused; srv calls answer mid-frame; `p5_thr` ×3 byte-identical | **AGREE** | `p5_thr{,.r2,.r3}.stdout.txt` sha `5eba2b8212e7…` all three; `:4` `THR pp frame=4 ray_hit=false isect=0 safe=1.0 btm=false`; `:7` `proc_get_state wall_z=(0,0,-30) proc_btm hit=false`; my battery child.logs reproduce (Item 2) |
| 15 | `p2_*` arms byte-identical ×2 reps | **AGREE** | sha-equal pairs confirmed for all six p2 arms (`p2_{isect,cast,btm,sync_cb,contact_count,contact_sig}`) |
| 16 | Jolt replication live-only, same lattice, different constants | **AGREE** (as live evidence; battery pins stay DEFAULT as stated) | 9× `jolt_*` receipts all `.exit=0`; `jolt_cast` `0.149841/0.150024`, `jolt_btm` `-0.998535`, `jolt_contact_count` `w0 c=4 → n1 c=0`, `jolt_sync_cb` `[5,6,7]`, `jolt_srv_area` `@f5/@f9/@f10` — every claimed value present |
| 17 | `early_null` racy, reported as CHILD_NOTE, never pinned | **AGREE** | unpinned in fixture (`:592` `prints("CHILD_NOTE …")`, not asserted); observed `false` in author ×3 + mine ×2 |
| 18 | hazards (dead-seat probe1 `get_server_count` bug; OS.execute output-array unusable; %-precedence; seed-digest window; await-leak; RID prints) | **AGREE** (receipts consistent) | dead-seat probe1 SIGKILL story corroborated by scribe §4 (`probe1` SCRIPT ERROR at :26, no `.exit`); OS.execute avoidance visible in fixture (`:514-518` `/bin/sh -c '… > child.log 2>&1'`); seed-digest mechanism reproduced by the failed intermediate run (claim 9) |

## Seed-digest nuance (disclosed; not a defect)

`seed_digests` inside `verdicts.json` is the seed map itself, not just a
boolean. The author's **first** battery (`…164612500349Z`, 16:46:12Z —
*before* the 16:57:26Z commit) recorded `README.md` at `130c7bcc…`; the
committed file is `20115e92…`. That run's own `seeds_unchanged=true`
(before==after within the run), and its 186-record case table is
byte-identical to the three runs on the committed map — the drift was the
documented in-flight README edit, a doc file, not a runnable seed.
Author run2 (`…165207093423Z`) and **both my runs share the committed
seed map exactly** (`seed_digests` equal). The committed tree is what my
two independent batteries measured; the claim survives on HEAD.

## The 39/342 sibling-stream finding — distinguished

The scribe's §3 scan (`r83-scribe.md:274-301`) found **39 of 342 landed
r83 sibling streams dirty under the tracked classifier** — SIGSEGV exits
134/137 (`jolt-multi_space`, `jolt-space_free_order`,
`jolt-space_off.crash-forward-cleanup`, `space_precond`, `thread-*`),
SCRIPT ERRORs (dead-seat `probe1`, `dummy-sleep`, `thread-space_precond`),
intentional `ERROR:` negatives (`fps_*`, DSS-refusal arms), ObjectDB
leaks, `RID()`/object-handle tokens. **All 39 are live-scratch receipts**
under `corpus/live/r83-{author,boundary,scout,critic}/runs/` — probe
output of seats' own `.gd` drafts, never committed and never folded into
`CASES`. The committed tree contains exactly the 10 new
`phys3d_events_*` rows, all of which I measured clean under the same
classifier on HEAD ×2 (0 stderr lines, exact markers, expected exits —
Item 1/2). The dirty-scratch population is real and correctly named, but
it is disjoint from what e9145d9 lands; the two sigsegv classes (134/137)
exist only in `r83-boundary/runs/*.exit` scratch files. Nothing in the
committed battery carries a crash, a SCRIPT ERROR, a stray `ERROR:` line,
a leak warning, or a `RID()` token — confirmed by byte-identical case
tables across four independent runs.

## Minor nits (non-blocking)

- `r83-author.md:44` cites `probe1.stdout.txt:16` for the hint string —
  the landed receipt has it at **:13** (file is 14 lines).
- `r83-author.md:47` cites `probe1.stdout.txt:11-15` for the PSM method
  list — actual lines are **:10-11** (`:12` singleton class, `:14`
  singletons list). Content correct in both cases; refs likely drafted
  against the dead-seat probe1's longer stdout.

## Remaining risks (bounded, shared with author)

- `proc_dss_refused` is a ≥8/12 threshold pin; observed 11/12 ×5
  (author×3, mine×2) + boundary's 149/150. A scheduler regime landing >4
  fetches in the race window would flip it — flagged by the author, the
  report's "majority-refused" wording is accurate.
- Jolt is live-only corroboration; pinned cells run DEFAULT
  (GodotPhysics3D). `Jolt + threaded` cross-product unprobed — disclosed.
- One `static_nopair` unprobed extension (body-body pairs) — disclosed as
  inference, correctly unpinned.

**Bottom line: AGREE on all 18 claims.** The committed tree reproduces
186/186 twice with byte-identical case tables to the author's committed-map
receipt, the insertion is clean, every quoted witness line exists in the
receipts, and the dirty sibling streams are scratch-only. Two line-ref
nits in the report; no substantive discrepancies.

Receipt paths: `corpus/live/r83-verifier/runs/20261014T165952311674Z/`,
`corpus/live/r83-verifier/runs2/20261014T165952317655Z/` (each with
`verdicts.json`, `scratch/thrproj/child.log`), logs
`corpus/live/r83-verifier/battery_run{1,2}.log`, comparator
`corpus/live/r83-verifier/compare_verdicts.py`. Stopping here — leaf.
