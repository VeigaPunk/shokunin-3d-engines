# game-dev-3d round 80 — verifier (seat: verifier; host: devin)

Post-landing verification of the committed tree. The author commit DID land
during my poll window: work commit **faae4e0** (probe sha `e9609814…`,
battery `ae3b04b1…`), determinism fix **e32e2de** (drops `slept=` from
walltime rows; probe now `bfa80ed4…`), report-last **ae89c13** — all by
`ci <ci@local>` (operator landing; seat rules forbid author commits).
Verified at HEAD **ae89c13**; working tree `git status --porcelain` shows
zero tracked-file modifications vs HEAD. Verifier authored nothing in the
fixtures. Scratch confined to `corpus/live/r80-verifier/` (gitignored via
`corpus/.gitignore:1`); this report is the only other write. No git
mutations, no subagents (leaf).

Toolchain observed: Blender **5.2.1 LTS** (`/usr/bin/blender`, hash
9e2066aef7ef, built 2026-09-01) — same build as r79/frontier. Godot
**4.7.2.stable.arch_linux.ed1daf0bf** (`/usr/bin/godot`). python3 on PATH.

## Item 1 — `python3 corpus/fixtures/bpy_battery.py` → **AGREE (PASS)**

Run on the committed tree (fixtures at `e32e2de` content). Command
`python3 corpus/fixtures/bpy_battery.py --runs corpus/live/r80-verifier/runs`,
exit **0** (full log `corpus/live/r80-verifier/bpy_run4_head.log`):

    totals: cases=64 pass=64 fail=0 (signal_fail=0 quirk_drift=0) launch_ok=True done_marker=True fatals=0 exit=0

Receipt `corpus/live/r80-verifier/runs/bpy-20261014T143109870686Z/verdicts.json`:
`verdict=PASS`, `n_arm_lines=112` (78 r79 + 34 evalcat: 23 EDGE + 11 DEG
witness rows), `blender_version="Blender 5.2.1 LTS"`, `probe_elapsed_s=4.23`,
`done_marker=true`, `fatal_arms=[]`. `probe.stderr.txt` byte-empty. The 27
new `evalcat_*` CASES (`bpy_battery.py:81-191`, appended after the untouched
r79 block) all PASS, including the closure row `evalcat|closed|EDGE`
`violations=0`.

## Item 2 — byte-stability of r79's 37 cases → **AGREE**

Before the author landed I snapshotted the clean tree at `3f9e070`
(`corpus/live/r80-verifier/runs/bpy-20261014T141938149475Z/`, 37/37 PASS;
ARM-stream sha256 `e989efbc…cb96` — identical to the r79 verifier's
recorded hash, extending the stability chain across the whole round).

At HEAD (`ae89c13`), `diff` of the non-evalcat `^(ARM|PROBE_DONE)` stream
vs that baseline: **byte-identical** (`R79-STREAM-STILL-BYTE-IDENTICAL-AT-HEAD`).
All 37 r79 CASES tuples are untouched in the committed `bpy_battery.py`
(diff `3f9e070..faae4e0` shows only `+` rows after `bpy_battery.py:78`) and
all 37 pass in every run.

## Item 3 — determinism → **AGREE** (zero drift cells)

| fixture state | run dir | cases | ARM-stream sha256 (first 16) |
|---|---|---|---|
| faae4e0 | bpy-20261014T142631319942Z | 64/64 | `01b95fc8d80ad4cf` |
| faae4e0 | bpy-20261014T142656310867Z | 64/64 | `01b95fc8d80ad4cf` (identical) |
| faae4e0 | bpy-20261014T142702868329Z | 64/64 | `01b95fc8d80ad4cf` (identical) |
| e32e2de | bpy-20261014T143109870686Z | 64/64 | `16978267e099ac71` |
| e32e2de | bpy-20261014T143127158894Z | 64/64 | `16978267e099ac71` (identical) |

Author↔verifier: the author's receipt
`corpus/live/r80-author/runs/bpy-20261014T142321446240Z/probe.stdout.txt` is
**byte-identical** to my faae4e0-state run (same `01b95fc8…` hash). The
e32e2de delta is exactly the `slept=` key removal on the three
`walltime_s*` DEG rows (sed-normalized diff of evalcat streams: empty) —
unpinned data, and its removal is what made the stream deterministic.

## Item 4 — independent cross-check of the evalcat pins → **AGREE**

Before the author landed I replayed all three frontier probes
(`blender -b -P corpus/live/frontier-bpyeval/bpy_evalcat_probe{,2,3}.py`,
outputs in `corpus/live/r80-verifier/evalcat{1,2,3}.stdout.txt`). evalcat1
and evalcat3 are **byte-identical** to the frontier receipts
(`corpus/live/frontier-bpyeval/runs/`); evalcat2 differs only in a
`bpy_struct` pointer address. Every pinned evalcat value on the committed
tree reproduces my independent measurement:

| pinned row | committed-tree stdout (verbatim) | vs my frontier replay |
|---|---|---|
| `op_apply` | `held=flushed invoked=bpy.ops dpost=2 … held_mesh=verts3:xmax6.000` | frontier `verts3 xmax6.000`, dup×2 — match |
| `op_add` | `held_names=Cube|o dpost=1` | `Cube|o`, dup×1 — match |
| `op_modapply` | `held_mesh=verts49:xmax1.000 dpost=2 rna_verts=49` | `verts49 xmax1.000`, dup×2 — match |
| `op_mode_edit`/`op_mode_object` | `held_loc=(5.000,0.000,0.000)` dpost 2 then 1 | asymmetric ×2/×1 — match |
| `driver`/`driver_expr` | `edge=1 fresh=(7.000…)` / `fresh=(9.000…)` rna copyback | `(7,0,0)`/`(9,0,0)` — match |
| `keyframe` | `edge=frame tagged_fresh=(0,0,0) f1=(0,4,0) rna_y=4.000`; `keyframe_wU upd_dup=1` proves a tagged update ran and stayed inert | probe2/3 keydiag/key_wu — match |
| `key_explicit` | `edge=1 build=layered fresh=(0,0,8)` | `explicit-fresh z=8.0` — match |
| `con_rna`/`conadd_target` | `edge=1 fresh=(3,0,0)` | match; post-op RNA write still edge=1 (op eval doesn't leave graph live) |
| `ev_framesame` | `held=flushed fc_fired=True dup_fired=False dpost=0 frame=2 held_loc=(4,0,0)` | same-frame eval, fc-only path — match (r79 unknown stays closed) |
| `walltime` | `edge=absent` all handler deltas 0 after 0.5/2.0/1.0s + re-touch | no wall-time drain — match |
| `ev_getclean`/`ev_vlclean` | `edge=cond` zero deltas | conditional eval — match |
| `closed` | `violations=0` | consistent with all of the above |

## Item 5 — the closure falsifier is mechanical and live → **AGREE**

`bpy_sync_probe.py:581-589` — `_ec_edge()` forces `edge=FALSIFIED` and
increments `EVALCAT_VIOLATIONS` whenever an `invoked=None` (bare-mutation)
row shows `held=="flushed"` OR any watched-handler delta
(`dpre/dpost/dfcp/dfc/dund`); the closing row (`:1029`) emits the counter
and the battery pins `violations=0` as a signal case — a falsified row
fails its own pin AND the closure pin. Coverage is the 8 bare
mutation-class rows (rna_write, driver, driver_expr, keyframe,
key_explicit, con_rna, conadd_target, walltime); invoked rows are in-set
by definition and their unexpected-handler fires are caught by per-row
`dpost=0`/`fc_fired=False` pins.

Liveness: `blender -b -P corpus/live/r80-author/falsify_check.py` (log
`corpus/live/r80-verifier/falsify_check.stdout.txt`, exit 0, stderr empty):
`violations_start 0` (in-process re-confirmation — exec_module runs the
full probe), synthetic bare flush+dup → `edge=FALSIFIED` (0→1), bare quiet
stale → edge kept `1` (1→1), `invoked=bpy.ops` flush → explained (1→1),
bare handler-fire with unmoved held → `edge=FALSIFIED` (1→2). The checker
discriminates; it is not a constant.

**Claim disposition**: "the eval-event set is enumerable and closed" —
**supported, not falsified**, on the probed surface: all 8 bare mutation
classes returned `held=stale` with zero handler deltas; every flush
observed coincided with an enumerated event (5 events + 6 bpy.ops rows).
Per the adjudicator's correction the claim is *bounded* — the falsifier
itself covers the 8 bare rows; the ~100-class figure is the union of
other seats' sweeps, and the `faae4e0` subject line over-attributes it.

## Item 6 — sibling Godot battery untouched → **AGREE**

`git show ae89c13 --name-status`: only `bpy_sync_probe.py`,
`bpy_battery.py`, and reports changed — `run_battery.py` and all Godot
seeds untouched. `python3 corpus/fixtures/run_battery.py --godot
/usr/bin/godot --runs corpus/live/r80-verifier/runs` → exit **0**,
`cases=176 pass=176 fail=0` (2m52s), receipt
`corpus/live/r80-verifier/runs/20261014T142745827958Z/verdicts.json`:
`seeds_unchanged=true` (digest map covers both bpy fixtures — run-internal
consistency, confirming the battery mutates no seeds), `crash_probe_ok=
stream_probe_ok=tree_probe_ok=true`.

## Defects / nits

- **None blocking.** Commit-subject over-attribution ("45+ probed classes")
  already corrected by the adjudicator to bounded-closure wording.
- `held=na` rows (`op_mode_object`, `op_conadd`) pin eval only via
  `dup_fired` — the held witness can't discriminate there; bounded by the
  other ops' discriminating rows (author-disclosed, battery-commented).
- Probe module docstring still describes only the r79 arm set; the evalcat
  block carries its own 30-line header (`bpy_sync_probe.py:417-444`) —
  cosmetic.
- Probe wall ~4.3s vs r79's ~0.5s (the 3.5s walltime sleeps); well inside
  `TIMEOUT_S=60`.

## Remaining risks

- Closure is bounded to the probed surface; unprobed classes (library
  linking, node-tree sockets, 5.x slot assignment beyond the one explicit
  build, edit-mode `bpy.ops.mesh.*`, render-engine writes) stay open by
  the author's own disclosure — the armed falsifier is the early-warning
  surface for extensions.
- `edge=frame` rests on frontier's tag-vs-rebuild inference (medium
  confidence there); the pinned row records only the observable.
- Pins are receipt-derived to this host's Blender 5.2.1 build; no
  cross-build tolerance (by design).

## Verdict

**6/6 AGREE** — r80 verified at ae89c13 (fixtures e32e2de): 64/64 pinned
cases green, r79's 37-case stream byte-identical, evalcat values
reproduced against independent frontier replays, closure falsifier
mechanical + live with `violations=0`, determinism restored post-e32e2de,
Godot sibling battery 176/176 untouched.
