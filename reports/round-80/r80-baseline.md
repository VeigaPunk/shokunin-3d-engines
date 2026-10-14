# game-dev-3d round 80 — frozen before-state + post-move replay (seat: baseline)

Baseline replay for the r80 move: fold the frontier bpy eval-event
catalogue (`reports/frontier/fa-bpy-evalcat.md`, probes in
`corpus/live/frontier-bpyeval/`) into `bpy_sync_probe.py` as an
`evalcat` arm emitting per-mutation-class EDGE rows, plus
`bpy_battery.py` pins per measured edge. Declared claim under test:
**the eval-event set {evaluated_depsgraph_get, view_layer.update,
frame_set, dg.update, bpy.ops} is enumerable and closed** — falsified
if any probed mutation class flushes a held depsgraph handle without
one of those events firing. Byte-stability of r79's 37 cases required.

Timing note (concurrency): while this seat ran, sibling seats landed
the move in the working tree and committed it — HEAD moved
`3f9e070 → faae4e0 → e32e2de → ae89c13` during the session. This
report therefore measures BOTH states: the frozen pre-move tree at
`3f9e070` and the landed fold at `ae89c13` (probe sha256 `bfa80ed4…`,
battery `ae3b04b1…`), plus one intermediate worktree state caught
mid-edit (sha256 `e9609814…`, pre-simplifier `slept=` field, snapshot
kept at `corpus/live/r80-baseline/fixture-stage/`).

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (hash 9e2066aef7ef,
built 2026-09-01 — same build as frontier + r79), `/usr/bin/godot` =
4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7, Node v24.21.0,
three.js 0.186.1.

## Frozen tree (pre-move baseline @ 3f9e070)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r80-baseline/frozen/frozen-tree.tar

- Frozen commit: `3f9e0703ef26b05d90fdf40d2316e79bfcbf337c`
  (`3f9e070 wave-10 report-last: final verdicts (verifier AGREE +
  critic corrections folded)`) — the last pre-r80 commit; contains the
  r79 37-case bpy battery (`08d1b10`) and the `9afcdc2` non-signal
  split. Zero r80 content at freeze time.
- Archive sha256
  `0bd70ea24246be4c1947ee3b17cc72c1bda1c61300e85f3ddc775ea56ef66f4a`,
  355 tar members; member list `diff`-identical to `git ls-files`
  (comm check EMPTY both directions on the extract —
  `corpus/live/r80-baseline/frozen-extract/`).
- Frozen fixture digests (pre-move): `bpy_sync_probe.py` sha256
  `740ccdf64c1918b2eb1b3b46746f87f384270827ce7e4c5f8f54d1831d61eec5`
  (424 lines, no evalcat arm), `bpy_battery.py` sha256
  `e107b25152fcc828cf0ce65c8467f50c7001f0fb4851eeab5ec856158a79dc13`
  (37 CASES).
- All writes confined to gitignored `corpus/live/r80-baseline/`
  (`corpus/.gitignore:1` → `live/`, `git check-ignore` confirmed) plus
  this report path. No git mutations performed by this seat.

## bpy battery — frozen pre-move — 37/37, byte-identical to prior receipt

    cd corpus/live/r80-baseline/frozen-extract
    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r80-baseline/runs

Receipt `runs/bpy-20261014T142033285237Z/verdicts.json`:

- `verdict` **PASS**; `totals: cases=37 pass=37 fail=0 (signal_fail=0
  quirk_drift=0)`; launch_ok=True, done_marker=True, fatals=0, exit=0;
  `probe.stderr.txt` 0 bytes.
- `probe.stdout.txt` **byte-identical** (`diff` empty) to the newest
  committed receipt `corpus/live/runs/bpy-20261014T141354732737Z`
  (post-`9afcdc2` battery, 37/37). Tuple comparison of all 37
  (case → verdict, observed) rows vs that receipt: **0 mismatches**;
  same Blender build string. The frozen pre-move surface is the exact
  state the r79-verifier-era battery pins.

## Godot battery — frozen — 176/176 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r80-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T142507821230Z/verdicts.json`: `verdict` PASS;
`totals: cases=176 pass=176 fail=0 ordinary=131 negative_controls=45
probes=4` (173→176 growth since r78 is r79-era case additions, not
drift — rows are this commit's own lattice). Mutation probe
`mutant_body3d_contact` rejected as pinned.

## Node three.js suites — frozen — 31/31

Post `npm ci` (three@0.186.1 per tracked lockfile) inside
`frozen-extract/corpus/fixtures/three`; receipts under
`corpus/live/r80-baseline/receipts/run_*.json`:

    run_cases 3/3 · layer 4/4 · order 9/9 · camera 5/5 · ortho 5/5 · ray 5/5
    all PASS, seeds_unchanged=true — total 31/31

## Post-move replay — landed fold @ ae89c13 — 64/64 ×3

The sibling-authored fold was measured in three states, all green:

| state | probe sha256 | battery run | result |
|---|---|---|---|
| worktree 11:23 (`faae4e0` content pre-commit) | `e9609814…` | `bpy-20261014T142437736570Z` | 64/64 PASS |
| worktree 11:27 (`e32e2de` content: `slept=` dropped) | `bfa80ed4…` | `bpy-20261014T142823546039Z` | 64/64 PASS |
| committed `ae89c13` | `bfa80ed4…` | `bpy-20261014T142911832718Z` | 64/64 PASS |

`git diff` at measure time: probe +619/−1 (append-only: evalcat block +
runner tuple adds `arm_evalcat` LAST), battery +114/−0 (27 new CASES
appended after `vis_relinked_deg_nonsignal`; all 37 original tuples
untouched, docstring addendum only). Committed digests verified
(`git show HEAD:` sha256 = `bfa80ed4…`/`ae3b04b1…`).

- `totals: cases=64 pass=64 fail=0 (signal_fail=0 quirk_drift=0)
  launch_ok=True done_marker=True fatals=0 exit=0`, every run.
- Determinism: runs 2 and 3 `probe.stdout.txt` **byte-identical**
  (116 lines). Run 1 differed only in the `slept=` diagnostic on
  `walltime_s*` DEG detail lines — the sibling's own `e32e2de`
  simplifier fix removed exactly that field; my two runs bracket the
  fix and independently reproduce the "only inter-run diff" claim in
  that commit message.
- **r79 byte-stability**: all 78 r79 `ARM` lines form a byte-identical
  PREFIX of the post-move stdout in every run (programmatic check:
  old[0:78] == new_arm_lines[0:78] → True); all 37 original cases PASS
  with observed tuples equal to the frozen run. The new arm cannot
  perturb earlier output — every arm opens with
  `read_factory_settings(use_empty=True)` and evalcat additionally
  re-installs its handler counters per sub-probe.

## Claim verdict: 'enumerable and closed' — HOLDS (not falsified)

The fold's own falsifier is mechanical: `_ec_edge()` forces
`edge=FALSIFIED` on any bare (`invoked=none`) row whose held read moved
or which fired a watched handler, and `evalcat|closed|EDGE` aggregates
`violations=N`. Measured on all three runs:

    ARM evalcat | closed | EDGE | violations=0 \
      events=evaluated_depsgraph_get|view_layer.update|frame_set|dg.update|bpy.ops

**violations=0, zero FALSIFIED rows, 34 evalcat ARM lines (23 EDGE +
11 DEG detail).** Every
observed held-handle flush is attributed to a set member; no bare
mutation class flushed or fired a handler:

| class | measured edge | evidence (post-move run 3) |
|---|---|---|
| bare RNA write / driver_add / driver_expr / key_explicit (layered action) / con_rna / conadd_target | `edge=1` held=stale invoked=none, all d=0 | one tagged eval binds: `fresh=(7.000/9.000/(0,0,8)/(3.000…)`; `rna_x=7.000` copyback |
| `keyframe_insert` | `edge=frame` | inert through a tagged eval that DID fire (`keyframe_wU upd_dup=1` held=(0,0,0)); binds only at frame_set `f1=(0.000,4.000,0.000) rna_y=4.000` — frontier "no relations tag" finding re-pinned at handler level |
| six bpy.ops (apply/cube_add/modapply/mode_edit/mode_object/locclear/conadd) | `edge=0` held=flushed (or `na` when the witness can't discriminate) invoked=bpy.ops dup_fired=True | dup deltas match frontier exactly: ×2/×1/×2/×2/×1/×1/×2 — auto-eval on the same shared graph |
| wall-time axis (0.5+2.0+1.0s + context re-touch) | `edge=absent` held=stale all d=0 | `walltime_fresh loc=(6.000,0.000,0.000)` — handle still flushable, drain confirmed absent on the time axis |
| four enumerated events on a dirty graph | `edge=0` held=flushed | tagged path (get/vlu/dgu) fires dup; frame path (frame_set +Δ AND same-frame) fires fc only, `dpost=0` — the two-handler-path split re-measured |
| get/vlu on a CLEAN graph | `edge=cond` | zero handler fires — conditional-eval property pinned |

`dund=0` on every row (undo_post dead headless, per frontier; emitted
for the receipt but never pinned — correct per the frontier dispatch
hint).

## Before/after summary

| surface | result |
|---|---|
| bpy battery, frozen `3f9e070` | 37/37 PASS; stdout byte-identical to `bpy-20261014T141354732737Z`; 0 row drift |
| bpy battery, landed `ae89c13` | 64/64 PASS ×3 runs (2 worktree + committed); r79 78 ARM lines byte-identical prefix; stderr empty; deterministic post-`e32e2de` |
| claim: eval-event set enumerable+closed | **HOLDS** — `violations=0`, 0 FALSIFIED rows; every probed flush attributed to {get, vlu, frame_set, dg.update, bpy.ops} |
| Godot battery, frozen | 176/176 + 4 probes PASS, seeds_unchanged |
| Node six suites, frozen | 31/31 PASS, seeds_unchanged |

## Receipts / scratch (all inside write scope)

- `corpus/live/r80-baseline/frozen/frozen-tree.tar` — `git archive
  HEAD` @ `3f9e070`, sha256 `0bd70ea2…` (355 members, comm-clean)
- `corpus/live/r80-baseline/frozen-extract/` — replay scratch tree
  (gitignored; + gitignored `node_modules` via `npm ci`)
- `corpus/live/r80-baseline/runs/` —
  `bpy-20261014T142033285237Z` (frozen 37/37),
  `bpy-20261014T142437736570Z` + `bpy-20261014T142823546039Z` +
  `bpy-20261014T142911832718Z` (fold 64/64 ×3),
  `20261014T142507821230Z` (godot 176/176); each with
  `verdicts.json`, `probe.stdout.txt`, `probe.stderr.txt`
- `corpus/live/r80-baseline/receipts/run_{cases,layer_cases,
  order_cases,camera_cases,ortho_cases,ray_cases}.json` — six Node
  suite receipts
- `corpus/live/r80-baseline/fixture-stage/` — content snapshots of the
  two measured worktree probe states (`*.worktree-1123` = e9609814,
  `*.worktree-1127` = bfa80ed4 = committed content) and the worktree
  battery (`ae3b04b1`); kept for receipt provenance — NOT fixture
  writes (fixtures are outside this seat's scope)

## Limits

- Single host, single Blender/Godot build; three bpy replays of the
  fold, one each of frozen bpy/godot/three — zero failures, no
  flake-retry needed.
- The fold was authored by sibling seats mid-session; this report
  measures it but does not author it. Both measured worktree states
  and the committed state are green; snapshots pinned above.
- `dund`/`msgbus` remain dead surfaces headless (frontier-closed);
  edit-mode `bpy.ops.mesh.*` eval counts and msgbus under interactive
  `-b --python` remain frontier unknowns — no probe here adds coverage
  there.
- The evalcat fold's `violations` counter only watches the mutation
  classes it probes (22 EDGE rows before the `closed` aggregate):
  "closed" is bounded-closed over the enumerated probe set, matching
  the adjudicator's wording — not a proof over unprobed bpy surface.
