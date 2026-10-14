# game-dev-3d round 79 — critic (seat: critic, host: devin)

Post-landing adversarial audit of `08d1b10` (bpy fixture + 37-case sibling
battery, operator-substituted author) + `9a2e7b1` (report-last). Same host,
same build (`Blender 5.2.1 LTS, hash 9e2066aef7ef`), so all cells below are
measured, not argued. Scratch + receipts: `corpus/live/r79-critic/` —
`critic_cells.py`, `critic_cells2.py`, `runs/cells.stdout.txt`,
`runs/cells2.stdout.txt`, `runs/bpy-20261014T140628029690Z/` (replay A),
`runs/bpy-20261014T140628681483Z/` (replay B),
`runs/bpy-20261014T140651733701Z/` (mutated-quirk verdict demo).

**Net: the measured lattice is sound and three audit probes strengthen it
(drain survives wall-time; `==` is pointer identity; receipt byte-stable).
One real defect in the battery: `non_signal` is cosmetic — quirk rows gate
the verdict exactly like signal rows, and 2 of the 6 flagged rows are
mislabeled base-RNA witnesses. Fixable; does not void the claim.**

## VERIFIED — audit cell 1: 'No implicit drain' survives a real wall-time gap

The landed `draincheck` arm only did back-to-back reads (~µs). Constructed
the missing cell (`cell_drain`): held `dg0` captured pre-write,
`ob.location=(4,0,0)`, then `time.sleep(0.5)` → read → `time.sleep(0.5)` →
unrelated `frame_current` read → read.

Receipt `runs/cells.stdout.txt`:
```
ARM drain | w0-held        | DEG | loc=(0.000,0.000,0.000)
ARM drain | w+0.5s-held    | DEG | loc=(0.000,0.000,0.000)
ARM drain | w+1.0s-held    | DEG | loc=(0.000,0.000,0.000)
ARM drain | timer-registered | META | note=fires only if a main loop runs
```
Held handle stayed stale across 1.0s of wall time. Stronger: a
`bpy.app.timers` callback registered at script end **never fired** — the
process printed `Blender quit` and exited (total 1.4s wall, exit 0). In
`blender -b -P` there is no post-script event-loop regime at all, so no
timer-driven or loop-driven eval machinery exists in the claimed runtime.
The claim "no implicit drain" does **not** overreach — verified, scope
intact (synchronous `-b -P` statement stream).

## VERIFIED — audit cell 2: `dgf == dg0` is pointer identity, not value equality

`cell_identity` receipt (`runs/cells.stdout.txt`):
```
ARM identity | dg            | META | eq=True is_py=False ptr0=0x7f5cda08b060 ptrf=0x7f5cda08b060 ptr_eq=True
ARM identity | obj-same-data | META | eq=True is_py=True ptr_eq=True
ARM identity | obj-diff-data | META | eq=False is_py=False ptr_eq=False
ARM identity | dg-v2         | META | eq=False ptr_eq=False ptr2=0x7f5cda08a0a0
```
Two `evaluated_depsgraph_get()` calls return **different Python wrappers**
(`is_py=False`) wrapping the **same C Depsgraph** (`as_pointer()` identical,
`==` True). Negative control: a second view layer's depsgraph
(`vl2.depsgraph`) has a different pointer and compares `==` False — so `==`
is not "always-True for same-type structs"; it is data-pointer equality on
bpy_struct. The fixture's `is_same=True` is load-bearing and correct: the
shared-graph claim holds at pointer level. (Had the fixture used `is`, it
would have read False — `==` was the right instrument.)

## FINDING (medium) — audit cell 3: `non_signal=True` is cosmetic; quirk rows gate the verdict

`bpy_battery.py:153-165`: `failed = len(results) - passed`;
`verdict = "PASS" if (failed == 0 and ...)`. The `non_signal` field only
adds a ` (non-signal)` print suffix (line 156) and a JSON field — it does
not exempt a row from `failed` or from the verdict. So a flip in the
evaluated-visibility quirk — which the docstring (lines 11-12) calls
"observations, never staleness witnesses" — produces a battery `FAIL`
indistinguishable from a lattice break.

Reproduction (real verdict path, not a re-implementation): imported
`bpy_battery`, patched `run_process` to return replay-A stdout with exactly
one quirk-row value flipped (`vis|relinked|DEG vis=False→True`, simulating
a Blender minor-build fix):
```
FAIL     vis_relinked_deg_nonsignal           vis|relinked|DEG (non-signal)
totals: cases=37 pass=36 fail=1 ... exit=0
FAIL battery: .../bpy-20261014T140651733701Z/verdicts.json
battery_returncode_for_quirk_flip = 1
```
All 30 staleness-signal rows PASS; battery exits 1.

Aggravating detail: 2 of the 6 `non_signal=True` rows are mislabeled —
`vis_hidden_rna` (pins base `vis=False, hide=True` after `hide_set`) and
`vis_relinked_rna` (pins base `vis=True` after relink) are ordinary RNA
witnesses that verify the mutation actually fired; they are the *most*
signal-bearing rows in the `vis` arm. The flag is wrong in both directions:
quirk rows gate like law, witness rows are marked non-signal.

For the record the quirk itself is stable *within* this build — my
`visflip`/`cells2` arms could not flip evaluated `visible_get`/`hide_get`
under: never-hidden object, `view_layer=` kwarg, second view layer,
`hide_viewport` direct write, `hide_set`, collection holdout, collection
exclude (object leaves `object_instances` entirely — `in_inst=False`),
`hide_render`, orphaned object. Evaluated `hide_get`/`visible_get` are
constant-False while the *properties* `hide_viewport`/`hide_render` do
mirror on the evaluated wrapper — i.e., dead methods, not lag. That is a
cross-build hazard only: a 5.2.x/5.3 fix flipping them FAILs this battery
with the lattice intact.

Smallest safe correction (two parts): (a) relabel `vis_hidden_rna` /
`vis_relinked_rna` to `non_signal=False` — they are witnesses; (b) compute
the PASS/FAIL verdict over signal rows only and report quirk drift as a
separate `quirk_drift` count in `totals` — matching the docstring's stated
intent. Alternative if the intent is build-level determinism pinning: keep
gating but rename the field `build_pin` and state that it gates — the
current `non_signal` name implies an exemption that does not exist.

## VERIFIED — audit cell 4: receipt byte-stability

Two back-to-back `bpy_battery.py` runs into scratch
(`runs/bpy-20261014T140628029690Z`, `...681483Z`):
- `probe.stdout.txt` — byte-identical (78 ARM lines + PROBE_DONE + banner).
- `probe.stderr.txt` — byte-identical (empty).
- `verdicts.json` — identical except `started_utc` and `probe_elapsed_s`
  (intended per-run volatile). Dict order is insertion-ordered throughout;
  no hash-seed dependence; `sorted()` used for collection names.

Benign-by-design host coupling in the receipt: `"probe"` and `"blender"`
embed absolute paths; `blender_version` captures only `blender --version`
line 1 (`"Blender 5.2.1 LTS"`) — the build hash `9e2066aef7ef` appears in
the probe stdout banner but is not copied into `verdicts.json`. Deterministic
per host; worth a hash field next time the battery is touched (nit).

## Other checks (clean)

- Sibling isolation real: `run_battery.py` carries an explicit `.gd` CASES
  list, no fixture-dir glob — the two new `.py` files cannot leak into the
  176-row Godot battery. `git show --stat 08d1b10`: only 2 new files.
- Held-stale pin ordering uncontaminated: everywhere a held-stale value is
  pinned, the held read is emitted **before** the fresh get that flushes
  the shared graph (membership `w0-held`→`w0-fresh`, `relink-w0-held`→
  `relink-w0-fresh`, draincheck 3×held). No self-induced false PASS.
- `dg.update()`, `view_layer.update()`, `frame_set` confirmed as eval
  events on this build (transform wD/wU/wF receipts).
- `Object.visible_get` signature on 5.2.1 is `visible_get(*,
  view_layer=None)` — `depsgraph=` kwarg does not exist (`TypeError`,
  `runs/cells.stdout.txt`); positional args rejected (`cells2`). Facts-add
  for the next bpy lane.

## Nits (no action required)

- `r79-author.md` says probe is "~330 lines"; landed file is 424.
- Evaluated-flag quirk mechanism remains unpinned (dead methods on
  evaluated wrappers, properties mirror) — consistent with author's
  declared open unknown.

## Impacted axes

- **Correctness of the claim**: unaffected — verified/strengthened on all
  three adversarial cells (drain, identity, stability).
- **Battery as regression instrument**: F1 — the verdict function cannot
  distinguish quirk drift from lattice break; plus 2 mislabeled rows.
  Judge-level question: whether a cosmetic-but-load-bearing label +
  cross-build false-FAIL risk blocks ADMIT or lands as a next-round fix.
- **Coverage/depth**: no impact; sibling isolation confirmed.

Correction scope if taken: ≤10 lines in `bpy_battery.py` (verdict math or
two CASES flags + field rename). I do not edit, integrate, or admit.
Report only; stopping here.
