# game-dev-3d round 81 — frozen before-state + battery replay (seat: baseline)

Baseline replay for the r81 move: two arms declared — (1) xconnector
X1 reorder fabrication on `blender -b -P` (spawned descendant inherits
blender's fd1; buffered-python parent → prefix reordering of ARM-stream
bytes; parse-survival cells pinned against misattribution), and
(2) evalcat extension: ~6 representative bare-class rows folded into
the tracked catalogue (critic's list: scene-prop write, hierarchy link,
data swap, parent write, objects.remove, orphans_purge). Declared
claims under test: **reorder topology falsifiable per runtime** and
**catalogue extension byte-stable** (r80's 64-case / 112-ARM-line
surface must not drift).

Timing note: at freeze and again at report time the worktree carried
**zero r81 fixture content** — HEAD is still `ae89c13` (r80
report-last), `git status` clean on `corpus/fixtures/`, `git diff HEAD`
empty there. The r81 arms had not landed when this seat measured;
this report therefore covers the frozen pre-move state only. A sibling
simplifier seat's `corpus/live/r81-simplifier/arrival-shas.txt`
independently records the same three fixture digests measured here —
cross-seat agreement on the pre-move surface.

Environment: `/usr/bin/blender` = Blender 5.2.1 LTS (built 2026-09-01 —
same build as r79/r80), `/usr/bin/godot` =
4.7.2.stable.arch_linux.ed1daf0bf, Python 3.14.7, Node v24.21.0,
three.js 0.186.1 (tracked lockfile).

## Frozen tree (pre-move baseline @ ae89c13)

    git -C ~/Projects/shokunin/game-dev-3d-shokunin archive HEAD \
      --format=tar -o corpus/live/r81-baseline/frozen/frozen-tree.tar

- Frozen commit: `ae89c1308e982538d45b4ffbcb71e48a524b13f4`
  (`ae89c13 r80 report-last: adjudicator + LOG + SCORECARD + 6 landed
  seat reports (bounded-closure wording per critic)`) — the last
  pre-r81 commit; contains the r80 evalcat fold (`faae4e0` +
  `e32e2de`): 64-case bpy battery, 112-line ARM stream.
- Archive sha256
  `4b50a3146a2fc882fd4a7cbe5bd897dd377af135459c38d19f502ac00ef9599c`,
  363 tar members (333 files + 30 dir entries); file-member list
  `comm`-clean vs `git ls-files` — **0 diff lines both directions**
  on the extract at `corpus/live/r81-baseline/frozen-extract/`.
- Frozen fixture digests (pre-move): `bpy_sync_probe.py` sha256
  `bfa80ed4bd296746242d1bd6bdb9cd932b570f632f0bcb06898e6b5a0c746780`
  (1041 lines, evalcat arm present), `bpy_battery.py` sha256
  `ae3b04b129555da72265576f4521c3e07a53ebe87f074cc3713fa702e2e08070`
  (302 lines, 64 CASES), `run_battery.py` sha256
  `22a1966dac431a5dddcd071b990911254ac572f1942dd1d374027529938c8bdb`.
  All three identical to the r81-simplifier seat's recorded arrival
  SHAs — the pre-move fixture surface is corroborated by two seats.
- All writes confined to gitignored `corpus/live/r81-baseline/`
  (`corpus/.gitignore:1` → `live/`; `git check-ignore -v` confirmed for
  both `r81-baseline` and `runs`) plus this report path. No git
  mutations performed by this seat.

## bpy battery — frozen pre-move — 64/64, byte-identical to prior receipt

    cd corpus/live/r81-baseline/frozen-extract
    python3 corpus/fixtures/bpy_battery.py --blender /usr/bin/blender \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r81-baseline/runs

Receipt `runs/bpy-20261014T143624669418Z/verdicts.json`:

- `verdict` **PASS**; `totals: cases=64 pass=64 fail=0 (signal_fail=0
  quirk_drift=0)`; `launch_ok` implied by `probe_exit=0`,
  `done_marker=true`, `fatal_arms=[]`, `n_arm_lines=112`;
  `probe.stderr.txt` 0 bytes.
- `probe.stdout.txt` **byte-identical** (`diff` empty, 9624 bytes) to
  the newest prior 64-case receipt
  `corpus/live/runs/bpy-20261014T142720660404Z` (post-`ae89c13`
  battery). Tuple comparison of all 64 (case → verdict, observed) rows
  vs that receipt: **0 mismatches**; same Blender build string. The
  frozen pre-move surface is exactly the state the r80-verifier-era
  battery pins — the byte-stability bar the evalcat-extension arm must
  clear.

## Godot battery — frozen — 176/176 + 4 probes

    python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot \
      --runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r81-baseline/runs \
      --probe-failing --probe-crash-exit --probe-stream-attribution --probe-tree-timeout

Receipt `runs/20261014T143659306553Z/verdicts.json`: `verdict` PASS;
`totals: cases=176 pass=176 fail=0 ordinary=131 negative_controls=45
probes=4`; `seeds_unchanged=true`. Mutation probe
`mutant_body3d_contact` rejected as pinned (exit 1, expected stdout
marker absent — the harness's own negative control). Tuple comparison
of all 176 (case → verdict, exit, observed) rows vs the r80-baseline
run `corpus/live/r80-baseline/runs/20261014T142507821230Z`: **0
mismatches**; same Godot build string.

## Node three.js suites — frozen — 31/31

Post `npm ci` (three@0.186.1 per tracked lockfile; 1 package added, 0
vulnerabilities) inside `frozen-extract/corpus/fixtures/three`;
receipts under `corpus/live/r81-baseline/receipts/run_*.json` via
`--receipt`:

    run_cases 3/3 · run_layer_cases 4/4 · run_order_cases 9/9 ·
    run_camera_cases 5/5 · run_ortho_cases 5/5 · run_ray_cases 5/5
    all PASS, seeds_unchanged=true — total 31/31

## Byte-stability summary (the bar for arm 2)

| surface | frozen result | drift vs prior receipt |
|---|---|---|
| bpy battery @ `ae89c13` | 64/64 PASS | stdout byte-identical to `bpy-20261014T142720660404Z`; 0/64 tuple mismatches |
| Godot battery @ `ae89c13` | 176/176 + 4 probes PASS | 0/176 tuple mismatches vs r80-baseline run |
| Node six suites @ `ae89c13` | 31/31 PASS | seeds_unchanged=true on every suite |

The r81 evalcat-extension arm's "byte-stable" claim is therefore
pinned against a measured 112-line ARM stream whose first-order
receipt is reproduced exactly from a clean `git archive` extract; any
post-move diff in the 78 r79-era ARM lines or the 34 r80 evalcat lines
is attributable to the fold, not to environment drift. The X1 reorder
arm inherits a parser whose input (fd1 ARM stream) is deterministic on
this build — reorder fabrication has a stable byte-baseline to
perturb.

## Receipts / scratch (all inside write scope)

- `corpus/live/r81-baseline/frozen/frozen-tree.tar` — `git archive
  HEAD` @ `ae89c13`, sha256 `4b50a314…` (363 members / 333 files,
  comm-clean)
- `corpus/live/r81-baseline/frozen-extract/` — replay scratch tree
  (gitignored; + gitignored `node_modules` via `npm ci`)
- `corpus/live/r81-baseline/runs/` —
  `bpy-20261014T143624669418Z` (frozen bpy 64/64),
  `20261014T143659306553Z` (frozen godot 176/176 + 4 probe verdicts
  files); each with `verdicts.json`, `probe.stdout.txt`,
  `probe.stderr.txt`
- `corpus/live/r81-baseline/receipts/run_{cases,layer_cases,
  order_cases,camera_cases,ortho_cases,ray_cases}.json` — six Node
  suite receipts

## Limits

- Single host, single Blender/Godot/Node build; one replay per
  surface — zero failures, no flake-retry needed.
- No r81 content existed in the worktree at measure time; unlike r80
  there is no landed fold to post-measure. If siblings land mid-round,
  the frozen digests above (`bfa80ed4…`/`ae3b04b1…`/`22a1966d…`) are
  the diff anchors.
- The X1 reorder arm's hazard (fd1 inheritance + buffered-parent
  prefix reordering) is a claim about the probe's *spawn topology*,
  not about the current 64-case surface — this baseline does not
  exercise it; it only guarantees the parser's unperturbed stream is
  byte-reproducible (`n_arm_lines=112`, deterministic across the r80
  runs and this replay).
- `corpus/live/` is gitignored; "prior receipt" comparisons are
  against on-disk runs retained under `corpus/live/runs/` and
  `corpus/live/r80-baseline/runs/`, not committed blobs.
