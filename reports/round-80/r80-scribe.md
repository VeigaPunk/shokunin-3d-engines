# game-dev-3d round 80 — scribe report (seat: scribe, host: devin)

Declared lane axis (from dispatch brief, verbatim): "ROUND 80 — 3d lane. bpy
EVAL-EVENT CATALOGUE (extends r79 lattice). Frontier evidence (READ FIRST):
reports/frontier/fa-bpy-evalcat.md + corpus/live/frontier-bpyeval/ — measured:
bpy.ops mutations auto-evaluate (new eval-event class; held handles see
post-op state at write+0); driver writes edge=1 tagged eval; keyframe_insert
binds ONLY at frame_set (inert through tagged get/view_layer.update);
constraint RNA-add edge=1; depsgraph_update_pre/post fire only on tagged
evals; frame_change_pre/post only on frame_set (incl same-frame — closes r79
unknown); msgbus/undo_post dead headless; wall-time drain CLOSED (0.5/2.0/1.0s
no flush). MOVE (depth): fold the catalogue into `bpy_sync_probe.py` arms
(evalcat arm emitting per-op edge rows) + bpy_battery pins per measured edge.
Claim to test: 'the eval-event set is enumerable and closed' — falsified if
any probed mutation class flushes held handles without one of
{evaluated_depsgraph_get, view_layer.update, frame_set, dg.update, bpy.ops}
firing. Byte-stability of r79's 37 cases required."

Scribe duty per lane practice (r76–r78 precedent, no r80 addendum in the
dispatch): independently re-run the round's declared claim shape under
`corpus/live/r80-scribe/` with this seat's OWN harness — here: a
falsifier sweep over candidate mutation classes plus the in-set controls —
verify byte-stability of r79's 37 cases, draft the lesson + LOG.md entry.
Report-only; not the judge. Leaf lane: no subagents, no git mutations; this
report is the only tracked write (scratch is gitignored, `corpus/.gitignore:1`).

## Landed state at measurement time

- HEAD `3f9e0703ef26b05d90fdf40d2316e79bfcbf337c` (wave-10 report-last);
  `git status --short` clean at 14:19–14:21 UTC.
- Frontier evidence committed at `9afcdc2` (`reports/frontier/fa-bpy-evalcat.md`
  + `corpus/live/frontier-bpyeval/` probes; sha256 verified against the
  report's recorded prefixes: probe1 `c99d8143ae9c2d58…`,
  probe2 `c5b16ba6ac822d19…`, probe3 `014c314f5dba9fc4…`).
- Tracked fixtures unchanged from r79: `bpy_sync_probe.py` sha256
  `740ccdf64c1918b2eb1b3b46746f87f384270827ce7e4c5f8f54d1831d61eec5`,
  `bpy_battery.py` `e107b25152fcc828cf0ce65c8467f50c7001f0fb4851eeab5ec856158a79dc13`
  (37 CASES), `run_battery.py` `22a1966dac431a5dddcd071b990911254ac572f1942dd1d374027529938c8bdb`.
- **The r80 author's tracked evalcat arm + battery pins had NOT landed when
  this seat's measurements ran** — no `corpus/live/r80-author/`, HEAD
  unchanged. What is verified below is the declared claim shape on this
  seat's own harness; the committed-arm replay remains open for the
  verifier lane (same situation r78-scribe recorded).
- Report-finalization note (14:22:33 UTC, after all receipts above were
  taken): the author's edit had just appeared in the working tree —
  `M corpus/fixtures/bpy_sync_probe.py` (1-line insertion at that moment,
  sha256 `52e5a15e33d216a562edd9c98207c69afe58472ee010e6ac51ed22be470b3ed8`,
  no commit; `bpy_battery.py` still at the r79 hash), plus an author
  battery receipt `corpus/live/r80-author/runs/bpy-20261014T142209559394Z/`.
  This seat did not run or verify the in-flight edit (mid-write tree,
  battery not yet updated); all receipts in this report are pinned to the
  pre-landing tree whose fixture hashes are recorded above.
- Sibling scratch observed in flight at 14:21 UTC (data, not relied on):
  `r80-scout/` (fixture copies + `bpy_sync_probe_r80.py` draft),
  `r80-boundary/` (`bpy_boundary_probe.py`), `r80-critic/`
  (`evalcat_counter_probe.py`), `r80-reviewer/` (frontier replay),
  `r80-baseline/`, `r80-simplifier/`, `r80-verifier/`.
- Toolchain: `/usr/bin/blender` = Blender 5.2.1 LTS (hash 9e2066aef7ef,
  built 2026-09-01), Python 3.14.7.

## Commands and receipts

| # | command (cwd `~/Projects/shokunin/game-dev-3d-shokunin`) | exit | receipt |
|---|---|---|---|
| 1 | `python3 corpus/fixtures/bpy_battery.py --runs corpus/live/r80-scribe/runs-battery-pre` | 0 | `runs-battery-pre/bpy-20261014T141911691223Z/verdicts.json` (37/37) |
| 2 | same, `--runs …/runs-battery-pre2` | 0 | `runs-battery-pre2/bpy-20261014T142119696394Z/verdicts.json` (37/37) |
| 3 | `blender -b -P scratch/r80s_evalcat.py` (cwd `corpus/live/r80-scribe`) | 0 | `runs/sweep{1,2,3,4}.{stdout,stderr,exit,elapsed_ms}` |
| 4 | `blender -b -P scratch/r80s_frame.py` | 0 | `runs/frame{1,2}.*` |

All six `blender` runs (sweep1–4, frame1–2): stderr byte-empty, `PROBE_DONE`
present, no `FATAL` arm lines; elapsed 0.38–0.96 s. Sweep harness `scratch/r80s_evalcat.py`
sha256 `91c1b4c0499ca85a5b283783a11216f232a756afd90a3a2a4afeaf8d57a2b97f`;
frame probe `scratch/r80s_frame.py` `841616d80981550c4a0451dca898665cbc3328473d370a22bfe97daae3bc268e`.
Method (established lattice method, own implementation): settle → capture
held handle `dg0` → clear handler counters → ONE mutation with **no
eval-event call in the window [mutation → held read]** → held read →
`ROW` line with `w0_changed` value-diff vs pre-mutation baseline → then one
standard tagged eval (`view_layer.update()`) to prove the mutation was a
pending tag, not invisible. Handler counters `h=pre/post/fcpre/fcpost/msg/und`
are on every line, so tagged-path vs frame-path fires are co-witnessed.

## (1) Closure sweep — claim NOT falsified across 19 probed mutation classes

Every mutation-class row below: held handle read at write+0 with **zero of
the five eval-event calls made in the window and zero handler fires**
(`h=pre0/post0/fcpre0/fcpost0/msg0/und0` on the w0 line), witness value
unchanged (`w0_changed=0`), then served by the next tagged eval. Full raw
lines: `runs/sweep3.stdout.txt`.

| mutation class | witness at write+0 | after `view_layer.update()` | flush? |
|---|---|---|---|
| `bpy.data.objects.new` + `collection.link` | `names=keep` (RNA `n=2`) | `keep\|o2` | no |
| `ob.data = <new mesh>` | `xmax1.000` (RNA `data=m2`) | `xmax9.000` | no |
| `mesh.vertices[].co` write | `xmax1.000` (RNA `x=5.000`) | `xmax5.000` | no |
| mesh write + `me.update()` | `xmax1.000` | `xmax6.000` | no |
| `scene.frame_current = N` (RNA) | `loc=(0,0,0)`, `frame=2` | (see §2) | no |
| `scene.render.engine` switch (EEVEE→CYCLES) | `loc=(0,0,0)`, `after=CYCLES` | `(7,0,0)` | no |
| `scene.render.resolution_x` write | `loc=(0,0,0)` | `(7,0,0)` | no |
| `scene.frame_end` write | `loc=(0,0,0)` | `(7,0,0)` | no |
| `ob.modifiers.new` + levels (re-verify) | `verts16` | `verts49` | no |
| `ob.modifiers.remove` | `verts49` | `verts16` | no |
| `constraints.new` + `target=` (re-verify) | `mw=(0,0,0)` (RNA mw `(0,0,0)`) | `mw=(3,0,0)` | no |
| `driver_add` + `expression=` (re-verify) | `loc=(0,0,0)`, RNA `x=0.000` | `loc=(7,0,0)`, RNA `x=7.000` | no |
| `keyframe_insert` (re-verify) | `loc=(0,0,0)`, RNA `y=0.000` | `wU=(0,0,0)` `wG=(0,0,0)`; binds at `frame_set` (§ below) | no |
| `ob.parent = tgt` | `mw=(0,0,0)` (RNA mw `(0,0,0)`) | `mw=(3,0,0)` | no |
| `ob.matrix_world = M` | `loc=(0,0,0)` (RNA loc `(2,0,0)`) | `(2,0,0)` | no |
| collection unlink+link | `names=keep\|mover` | `keep` | no |
| `ob.hide_viewport = True` | `names=hider\|keep` | `keep` | no |
| `collection.children.link(sub)` (sub holds mover) | `names=keep` | `keep\|mover` | no |
| `bpy.data.objects.remove` (data-block deletion) | `names=keep\|victim` | `keep` | no |

**Falsifier verdict: no probed mutation class flushed held handles without
an in-set event.** 19/19 candidate classes are tagged-not-evaluated (or
pure value writes). `scene.update()` does not exist on this build
(`has_update=False`) — the API-surface enumeration adds no sixth event.
msgbus re-probed with the 5.x surface: `subscribe_rna` accepted
(`MSGBUS_ERR=ok:subscribe_rna`), **callbacks never fired** (msg0 on every
line of every arm); `undo_post` never fired (und0 everywhere).

### In-set controls (the five events DO flush; discriminating witnesses)

| control | held at write+0 | handler fires | verdict |
|---|---|---|---|
| `bpy.ops.object.transform_apply` | `xmax1.000 → xmax6.000` | `pre2/post2` | flush (op class re-verified; ×2) |
| `bpy.ops.mesh.primitive_cube_add` | `names=o → Cube\|o` | `pre1/post1` | flush (op class re-verified; ×1) |
| `view_layer.update()` | `(5,0,0)` | `pre1/post1` | flush |
| `dg.update()` on held handle | `(5,0,0)` | `pre1/post1` | flush |
| `frame_set(+1)` | `(5,0,0)` | `fcpre1/fcpost1`, dup 0 | flush, frame path |
| `frame_set(same)` | `(6,0,0)` | `fcpre1/fcpost1`, dup 0 | flush, frame path (r79 unknown (c) re-closed) |
| `evaluated_depsgraph_get()` dirty | `(5,0,0)` | `pre1/post1` | flush |
| `evaluated_depsgraph_get()` clean | `(5,0,0)` | `pre0/post0` | **conditional** — clean get evaluates nothing |
| unrelated reads / `select_set` / active set | stale | 0 | no drain (r79 draincheck re-verified) |

Keyframe row (re-verify + extension): `w0=(0,0,0)` stale; `view_layer.update()`
fires `pre1/post1` but the fcurve stays inert (`wU=(0,0,0)`); fresh get adds
no fire (`wG=(0,0,0)`); **`frame_set(same)` binds — `(0,4,0)`, RNA `y=4.000`
copyback**; `frame_set(2)`/`frame_set(1)` same value. This independently
reproduces the frontier's "binds only at frame_set" and extends it to the
same-frame `frame_set` (the frontier measured f2/f1).

### Honest record: first-pass witness defect (sweep1)

Sweep1's `transform_apply` control used the held `location` as witness — a
degenerate witness (post-op RNA loc is `(0,0,0)` whether stale or flushed,
since the op clears loc and bakes it into the mesh). That row is
uninformative; sweep2 replaced it with the geometry-bake witness
(`xmax1→6`), which is discriminating. Sweep1's msgbus call also used the
renamed-away `subscribe_rkey` (`AttributeError`), fixed in sweep2 to
`subscribe_rna`. All other shared sweep1 lines are byte-identical to
sweep2/3 — the only shared-line changes are the `ctl_op` witness and the
`MSGBUS_ERR` trailer (`diff sweep1 sweep2`: 26 lines, all accounted for).

### Repeatability

- `sweep3` vs `sweep4` (same code, consecutive runs): **byte-identical
  except the `elapsed_ms` field** on `PROBE_DONE` (diff: one line).
- `sweep2` vs `sweep3`: only the intentionally-changed `collection_child`
  arm differs; every other line byte-identical.

## (2) Frame-edge probe — `frame_current = N` is a TAG, not an event

Surfaced by the sweep (a frame-position mutation that is not an eval event);
the follow-up probe pins the mechanism with a two-keyframe animation
(y=4@f1, y=9@f3), `runs/frame2.stdout.txt`:

| point | frame | held y | handlers |
|---|---|---|---|
| `frame_set(1)` bind (control) | 1 | 4.000 | fc fires |
| `frame_set(3)` bind (control) | 3 | 9.000 | fc fires |
| `frame_set(1)` back | 1 | 4.000 | fc fires |
| **clean-check** `view_layer.update()` | 1 | 4.000 | `pre0/post0` — graph clean |
| **`frame_current = 3`** (RNA write) | 3 | **4.000** (RNA y=4.000) | **0 fires** — no eval, no tag-serve |
| forced `view_layer.update()` after it | 3 | **9.000** (RNA y=9.000) | `pre1/post1` — pending tag served by the tagged path |
| `frame_set(3)` at frame already 3 | 3 | 9.000 | `fcpre1/fcpost1` — same-frame frame event still fires |
| `frame_set(1)` | 1 | 4.000 | fc fires |

Reading: the RNA frame setter leaves the graph **dirty** (the clean-check
proves the dirt is attributable to it) but does not evaluate and fires no
frame handlers; the animation applies at the next tagged eval. So the
frame event's trigger is `frame_set` — the `frame_current` RNA write is a
tagging write like the driver/keyframe classes. No closure falsification
(it does not flush held handles), but the catalogue should not list
"frame RNA write" as a frame-path trigger.

## (3) Byte-stability of r79's 37 cases — PASS, hash-identical to r79's verified stream

Both battery runs on the pre-landing tree: `cases=37 pass=37 fail=0
signal_fail=0 quirk_drift=0 launch_ok=True done_marker=True fatals=0 exit=0`
(`n_arm_lines=78`, Blender 5.2.1 LTS). The `^(ARM |PROBE_DONE)` stream
sha256 from both runs is
`e989efbc2f598aaa700fac94d429152572e355ecab4ebe2dbc96f7e44bcfcb96` —
**byte-identical to the hash the r79-verifier recorded across its three
post-landing runs** (`reports/round-79/r79-verifier.md` item 3). The r79
lattice is byte-stable across the r79 verification window and this r80
pre-landing measurement (~3.5 h apart, same build).

## (4) Provenance check on the frontier evidence (cited verbatim)

Frontier receipts exist and match the report's quoted numbers:
`corpus/live/frontier-bpyeval/runs/evalcat1.stdout.txt` — `frame-set-same`
`held_loc=(4.000,0.000,0.000)` `h=…fc2…` (same-frame flush);
`get-clean` counters unchanged vs `get-dirty` (conditional get);
`op_apply` `held_mesh=verts3 xmax6.000` (op auto-eval, ×2 fires);
`op_add` `held_names=Cube|o` (×1); `con_rna` held `(0,0,0)` → fresh `(3,0,0)`
(edge=1); `keyframe` inert through `wU`; `walltime` held `(0,0,0)` across
0.5/2.0/1.0 s sleeps. evalcat1 exit 0, 4066 ms (3.5 s of it arm sleeps).

## Findings

1. **Closure claim survives this round's falsifier sweep.** 19 mutation
   classes probed with no in-set call in the window — none flushed held
   handles; every one was served by the next tagged eval. The in-set five
   all flush with the frontier's handler signature split (tagged path vs
   frame path) and the `get` conditional reproduced.
2. The catalogue's mutation side is now explicitly enumerated as
   **tagged-not-evaluated**: plain RNA writes (location/flags/frame/render
   settings), derived-RNA writes (`matrix_world`), relations writes
   (parent, constraint target), animation writes (driver, keyframe),
   data-block create/swap/remove, geometry data writes (+ `me.update()`),
   modifier add/remove, membership/hierarchy links, `hide_viewport`. Each
   needs exactly one tagged eval (get-dirty / update / dg.update / an op) to
   become visible; none needs the frame path.
3. **New measured edge: `frame_current = N` ≠ `frame_set`.** The RNA frame
   write tags but does not evaluate and fires no handlers; `frame_set` fires
   `frame_change_pre/post` (incl. same-frame) and flushes. The r79/frontier
   "frame event" should be phrased as `frame_set`, not "frame change".
4. `scene.update()` is absent on 5.2.1 (`has_update=False`) — no sixth
   eval-event candidate on the Scene object. msgbus (`subscribe_rna`)
   accepted-but-silent and `undo_post` silent re-confirmed — do not pin
   them (frontier dispatch hint stands).
5. Op-class re-verification with discriminating witnesses: transform_apply
   ×2 tagged fires, primitive_cube_add ×1 — the frontier's "≥1, not exact"
   guidance reproduces on this seat's harness.

## Conflicts / disagreements with sibling evidence

- None found against the frontier's measured facts (all re-verified points
  above reproduce). One wording refinement (finding 3) and one scope note:
  the frontier's "no wall-time drain" was not re-probed by this seat (its
  receipts were checked instead) — not rerun merely to decorate.

## Known limits

- "Closed" is a bounded claim: it is closed **over the probed class set**,
  which this round extended by 19 classes; unprobed surfaces remain (edit-mode
  `bpy.ops.mesh.*` eval counts, render-engine render paths, `bpy.app.timers`,
  library append/link, undo stack internals). Falsifiers stay open there by
  construction, same as r78's bounded-permanence phrasing.
- The author's tracked evalcat arm + battery pins had not landed; the
  committed-tree replay of the new rows is the verifier lane's check. My
  byte-stability receipt covers the pre-landing r79 37-case lattice.
- All pins are receipt-derived for this host's Blender 5.2.1 build; no
  cross-build tolerance story (inherited from r79).

## Draft: `corpus/lessons/r80-eval-event-catalogue-closure.md`

```markdown
# R80 — the bpy eval-event set is closed over a 19-class mutation sweep: mutations tag, the five events serve; `frame_current=` is a tag, not a frame event (Blender 5.2.1 headless)

## Decision and evidence

Claim tested: "the eval-event set is enumerable and closed" — falsified if
any probed mutation class flushes held handles without one of
{evaluated_depsgraph_get, view_layer.update, frame_set, dg.update, bpy.ops}
firing. On `blender -b -P` (Blender 5.2.1 LTS), 19 candidate mutation
classes were probed with a held depsgraph handle captured pre-mutation and
NO eval-event call in the window [mutation → held read]: none flushed
(0/19), all were served by the next tagged eval, and every mutation window
had zero handler fires. In-set controls all flush with the frontier's
handler split: tagged path (get-dirty / view_layer.update / dg.update /
bpy.ops) fires `depsgraph_update_pre/post`; `frame_set` (incl. same-frame)
fires `frame_change_pre/post` and no dup; a get on a clean graph fires
nothing.

- Mutation classes are **tagged-not-evaluated**: RNA writes (plain,
  derived, relations, animation, frame, render settings), data-block
  create/swap/remove, geometry writes (+ `me.update()`), modifier add/remove,
  membership/hierarchy links, `hide_viewport`. Each needs exactly one tagged
  eval to become visible; none needs the frame path.
- **`scene.frame_current = N` is not a frame event.** With a two-keyframe
  animation, the RNA frame write leaves the graph dirty (clean-check
  proves attribution) but evaluates nothing, fires no handlers, and the
  animation applies only at the next tagged eval. `frame_set` is the
  frame-event trigger, including same-frame.
- `bpy.ops` mutation is an eval event class of its own: held handles see
  post-op state at write+0 (transform_apply xmax 1→6 ×2 fires;
  primitive_cube_add instances gain `Cube` ×1). Pin ≥1 fire, not exact.
- `keyframe_insert` binds only at `frame_set` (inert through tagged get and
  view_layer.update; same-frame frame_set binds) — re-verified independently.
- Dead surfaces headless: msgbus (`subscribe_rna` accepted, callbacks never
  fire), `undo_post`, wall-time (no drain). Do not pin them.
- `scene.update()` does not exist on 5.2.1.

## Authoring consequences

- An evalcat arm that watches only `depsgraph_update_post` will call
  frame_set evals "absent" — the frame path must be watched via
  `frame_change_*`. Two witnesses, not one.
- Held-handle staleness ends only at an in-set eval event; there is no
  implicit drain (no wall-time, no read, no context touch).
- For rows pinning "binds at frame_set", use the same-frame `frame_set` as
  the minimal binder (measured).

## Recheck conditions

Engine rebuild or depsgraph refactor re-runs the sweep; the closure claim
is bounded to the probed class set and phrased as such. Unprobed:
edit-mode mesh ops, render paths, timers, library link.
```

## Draft: LOG.md round-80 entry

    ## Round 80 — devin host — bpy eval-event closure sweep: 19 mutation classes probed, 0 falsifiers; mutations tag / the five events serve; frame_current= is a tag not a frame event
    - Declared (dispatch brief): fold the frontier eval-event catalogue into
      `bpy_sync_probe.py` arms + `bpy_battery.py` pins; claim "the
      eval-event set is enumerable and closed", falsified by any probed
      mutation class flushing held handles without one of
      {evaluated_depsgraph_get, view_layer.update, frame_set, dg.update,
      bpy.ops} firing; r79's 37 cases byte-stable. Wave
      `shokunin-train-20261101-w11`.
    - At scribe-measurement time HEAD was 3f9e070 (wave-10 report-last);
      the author's tracked evalcat arm had NOT landed (no r80-author
      scratch) — committed-arm replay deferred to the verifier lane.
    - Scribe independent harness (corpus/live/r80-scribe/, sweep1–4,
      frame1–2; all exit 0, stderr-empty; sweep3≡sweep4 byte-identical):
      closure NOT falsified — 19/19 probed mutation classes stale at
      write+0 with zero handler fires and no in-set call in the window;
      all served by one tagged eval. Controls: op auto-eval re-verified
      with discriminating witnesses (xmax1→6 ×2; Cube instances ×1);
      frame_set same-frame flush + fc-path only; get conditional (clean
      get fires nothing); no drain.
    - New measured edge: `scene.frame_current = N` tags (dirty, provable
      via clean-check) but never evaluates/fires; animation applies at
      next tagged eval; `frame_set` (incl. same-frame) is the frame event.
    - Byte-stability: bpy_battery ×2 on pre-landing tree, 37/37 both,
      `^(ARM |PROBE_DONE)` stream sha256 e989efbc…cb96 — identical to the
      r79-verifier's three-run hash. msgbus subscribe_rna silent; undo_post
      silent; scene.update() absent.

## Residual risks / recheck conditions

- The author's landed evalcat rows could not be replayed by this seat
  (not landed). If the author's pins disagree with the frontier tables or
  with the sweep above, the conflict is reportable verbatim for the
  canonical judge — the receipts here are the independent baseline.
- "Closed" remains bounded to the probed set; the unprobed list is explicit
  above. A future falsifier (e.g., an edit-mode op path that serves without
  any in-set call) would become the measured counterexample.
- Sweep1's degenerate transform_apply witness and the `subscribe_rkey`
  AttributeError are recorded, superseded by sweep2/3; do not cite sweep1
  for those two rows.
