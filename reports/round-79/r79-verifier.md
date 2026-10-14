# game-dev-3d round 79 — verifier (seat: verifier; host: devin)

Post-landing verification of the committed tree at **9a2e7b1** (r79
report-last) on top of **08d1b10** (r79 work: `bpy_sync_probe.py` +
`bpy_battery.py`, 37 pinned cases). Verifier authored nothing in r79.
All commands run from repo root on the committed tree; `git status
--porcelain` = 0 changes (clean). Scratch confined to
`corpus/live/r79-verifier/` (gitignored, `corpus/.gitignore:1`); this
report is the only other write. No git mutations, no subagents (leaf).

Toolchain observed: Blender **5.2.1 LTS** (`/usr/bin/blender`, hash
9e2066aef7ef, built 2026-09-01), Godot **4.7.2.stable.arch_linux.ed1daf0bf**
(`/usr/bin/godot`), python3 on PATH.

## Item 1 — `python3 corpus/fixtures/bpy_battery.py` → **PASS**

Command exited **0**. Tail of stdout (full log:
`corpus/live/r79-verifier/bpy_run1.log`):

    totals: cases=37 pass=37 fail=0 launch_ok=True done_marker=True fatals=0 exit=0
    PASS battery: .../corpus/live/runs/bpy-20261014T140250167571Z/verdicts.json

Receipt `corpus/live/runs/bpy-20261014T140250167571Z/verdicts.json`:
`verdict=PASS`, `n_arm_lines=78`, `blender_version="Blender 5.2.1 LTS"`,
`probe_elapsed_s=0.52`, `done_marker=true`, `fatal_arms=[]`. All 37 CASES
rows printed `PASS` (6 flagged `(non-signal)` per the evaluated-visibility
quirk contract). `probe.stdout.txt` = 82 lines: 78 ARM + `PROBE_DONE` +
Blender banner + `Blender quit`; `probe.stderr.txt` empty.

## Item 2 — `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot` → **PASS**

Exit **0**; all **176** prior rows green. Totals line:

    totals: cases=176 pass=176 fail=0 ordinary=131 negative_controls=45 probes=0
    PASS battery: .../corpus/live/runs/20261014T140309552103Z/verdicts.json

Receipt `corpus/live/runs/20261014T140309552103Z/verdicts.json`:
`seeds_unchanged=true` (SHA-256 map covers both new .py fixtures — the bpy
additions are inside the hashed seed dir), `crash_probe_ok=true`,
`stream_probe_ok=true`, `tree_probe_ok=true`. Sibling-runner claim holds:
the Godot battery is byte-stable, untouched by the bpy landing.

## Item 3 — determinism, bpy_battery ×3 → **PASS** (zero drift cells)

Three consecutive invocations (default `--blender` → `/usr/bin/blender`):

| run dir | cases | ARM lines | sha256 of `^(ARM \|PROBE_DONE)` stream |
|---|---|---|---|
| bpy-20261014T140250167571Z | 37/37 | 78 | `e989efbc2f598aaa700fac94d429152572e355ecab4ebe2dbc96f7e44bcfcb96` |
| bpy-20261014T140255960819Z | 37/37 | 78 | `e989efbc…cb96` (identical) |
| bpy-20261014T140259126674Z | 37/37 | 78 | `e989efbc…cb96` (identical) |

`diff` of the ARM stream against the author's own pinned receipt
`bpy-20261014T135140188222Z/probe.stdout.txt`: **byte-identical** — the
lattice is stable across author and verifier runs, ~25 min apart.
Drift cells: **none**.

## Item 4 — independent cross-check of 3 pinned values → **PASS**

Read directly from `bpy-20261014T140250167571Z/probe.stdout.txt` (my own
grep of the receipt, not the battery's JSON):

| case | pinned | observed stdout (verbatim) | match |
|---|---|---|---|
| `transform_w0held_stale` | `loc=(0.000,0.000,0.000)` | `ARM transform \| w0-held \| DEG \| loc=(0.000,0.000,0.000) mw_t=(0.000,0.000,0.000) orig=True` | yes — held handle stale at w0 |
| `modifier_w0held_stale` / `modifier_w0fresh_evaluated` | `eval_verts=16` / `eval_verts=49` | `ARM modifier \| w0-held \| DEG \| eval_verts=16 base_verts=16` … `ARM modifier \| w0-fresh \| DEG \| eval_verts=49 base_verts=16` | yes — SUBSURF 49-vs-16 discriminator confirmed |
| `membership_w0held_stale` | `names=keep|mover` | `ARM membership \| w0-held \| DEG \| names=keep|mover` (and `w0-fresh` → `names=keep`) | yes — `object_instances` staleness witness holds |

## Defects / nits

- **Doc nit (non-blocking)**: `reports/round-79/r79-author.md:66` claims
  "79 ARM lines parsed"; the author's own receipt
  `bpy-20261014T135140188222Z/verdicts.json` records `n_arm_lines=78`,
  matching all three verifier runs. Receipt is ground truth; prose is
  off by one. No fixture defect.
- No defective behavior found in the landed work. The two-layer lattice
  (write-through RNA vs eval-gated held handles, absent drain, shared
  graph flush) reproduces exactly as pinned.

## Remaining risks

- Determinism pinned to this host's Blender 5.2.1 build; the battery
  carries no cross-build tolerance story (by design — pins are
  receipt-derived).
- Probe surface covers direct RNA writes + modifier add only; author's
  own unknowns (bpy.ops paths, drivers, same-frame `frame_set`, EEVEE
  triggers) remain open for boundary seats.

## Verdict

**4/4 PASS** — landed r79 state verified at 9a2e7b1+08d1b10.
