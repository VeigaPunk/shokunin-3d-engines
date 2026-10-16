# r97 author — the gameplay node-class lattice

Seat: **GAME-DEV-3D r97 AUTHOR**. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r97-author.md`.
Sources read, never written: `reports/round-97/r97-scout.md` +
`corpus/live/r97-scout/**`, `reports/round-97/r97-boundary.md` +
`corpus/live/r97-boundary/**`. Custody entered at HEAD `dda3e7e` (*r96
simplifier*, after the r96 author's `dd054a2`); HEAD is `eb641c2` (*r96
verifier + adjudicated ADMIT*) at seat end — the four r96 wave-B commits that
landed mid-seat touch only `LOG.md`, `SCORECARD.md` and `reports/round-96/**`
(`git diff --name-only dda3e7e..HEAD`), no `corpus/fixtures/**` byte.
**No commit, no tracked-tree write other than the files this seat owns.**

Landed (all tracked seeds):

- `corpus/fixtures/r97_nodelat.gd` — the parent fixture, 8 arms, **79 pinned
  cells**, **83 bounded children per battery pass** (79 + 4 deferred-pin
  census children that are counted in `#` diagnostics and never pinned).
  sha256 `c30aca993686733f43b4b0088f3613131cc25f2c65c7157bd6da3011907b36c5`.
- `corpus/fixtures/r97_probe_*.gd` — **10 byte-identical copies** of the
  scout/boundary probes (sha table in `corpus/live/r97-author/RECEIPTS.md`),
  copied into each child project under their ORIGINAL `res://` names so a
  child receipt reproduces the source receipt byte-for-byte (the boundary §1
  rename hazard is avoided by construction).
- `corpus/fixtures/run_battery.py` — **+8 rows, insertion-only** (`git diff
  --numstat` = 38 insertions, 0 deletions, after `r96_joltdet_nc`):
  `r97_nodelat_{joint,soft,dss,cb,vehicle,softfloor,xr,freegrain}`.
- this report.

**Contract note (recorded, not reinterpreted).** The assignment's parenthetical
headline — *"rc=1 is a fresh-allocate property; deferred free survives ONLY
without load; decode non-zero DOES wait; pin the three-guard witness"* — does
not occur in the named boundary report, in the named scout report, in either
evidence tree, or anywhere else in this lane (`grep -rn` over `.ufo/` and all
lane reports: the phrase `three-guard` occurs only in the assignment file
itself; `fresh-allocate` nowhere). The boundary report's actual headline is the
64/67 verbatim-replay result, the deferred-pin-phase race, and the re-scoped
GP soft-body contact law. The seat therefore authored **the boundary-surviving
claims the named reports actually contain** and did not invent cells for the
unmatched headline. (The same mismatch covers the "RID/refcounting" task
title: the r97 scout/boundary surface is the gameplay node-class lattice;
`RID`s appear in it only as the joint-node `get_rid()` / ClassDB evidence
already covered below.)

---

## 0. The eight rows and what each pins

Every cell's receipt was re-derived, not restated: a full pass spawns 83 fresh
Godot children (`timeout -s KILL 14` bounded, 8-way chunks), each running the
scout's/boundary's own probe out of a per-cell project, and folds the child's
normalized contract stream into a digest cell
`<cell>{rc=<n>,sha=<16 hex>,<field>=<value>,...}`.

| # | row (CASES) | arm | cells / children | boundary-surviving law encoded |
|---|---|---|---|---|
| 1 | `r97_nodelat_joint` | `joint` | 24 / 24 | Joint3D node lattice: binding order is free (`bind` == `bindpre` physics rows, `req=1`); `get_rid()` valid at construction on GP+Jolt (`prerid=true`) and invalid on Dummy (`false`); a bad path (`badpath`) and an unset `node_b` (`nob`) are the same silent world-pin (`req=1`); a non-body `node_a` is silently inert (`bindnode`); node-level teardown (`freerj`/`freeb`/`readd`/`repath`/`dupclaim`) is clean on both backends — the r90 server UAF does not reproduce at node level; hinge motor `hmot` (−2.5 on each body GP, −2.5019 Jolt), `hlim` caps the spin (0.0618), the exclusion (`exclx_on/off`, `rdiff=1`) and `clampbig` supplements discriminate. |
| 2 | `r97_nodelat_soft` | `soft` | 7 / 7 | SoftBody3D contract: an unindexed mesh is rejected on GodotPhysics (`godot_soft_body_3d.cpp:148`, 9 allowlisted error lines, `v4≡0`); an indexed patch on the 0.1 m slab tunnels on GP (−10.83421) but rests on Jolt (0.05); Jolt's `mass=10` / `precision=50` fall through the same thin slab (−16.18); `queue_free` mid-run is clean (`v4=-`). |
| 3 | `r97_nodelat_dss` | `dss` | 6 / 6 | `collide_with_areas` defaults FALSE for rays (`n=0`; explicit true → hit at 2.75); `hit_from_inside` sees the sphere's inner surface from inside (`pos=origin, nrm=0`); trimesh `hit_back_faces=true` on the up-ray stays a miss (`n=0`, a measured null); `max_results=2` survivors are backend-ordered (GP `tri,wall2` / Jolt `tri,sph`). |
| 4 | `r97_nodelat_cb` | `cb` | 11 / 11 | `motion_mode=FLOATING` never reports floor while resting (`fl=0 wlo=1`, `v.y=-19.6` — the probe's own 60-tps scripted dt); `floor_constant_speed` holds 1.8794,−0.684 on the 20° slope on GP and FAILS on Jolt (3.3011,3.2221); `up_direction=+Z` reclassifies floor as wall; the `plat_ride` split is the reported slide count (GP `n=1` / Jolt `n=0` while carried at rv=2.0); `safe_margin=0.1` is a hover height (GP 0.5919 / Jolt 0.5969); `max_slides=1` in the V-groove jitters on GP and settles quiet on Jolt. |
| 5 | `r97_nodelat_vehicle` | `vehicle` | 6 / 6 | The raycast-vehicle drop is backend-invariant (GP == Jolt byte-for-byte, `feq=1`, settle 0.7299, `contact=4`); `engine_force=400` tumbles on both and diverges in the chaotic tail (`rdiff=1` — a divergence witness, not a value pin); `suspension_stiffness` 5 → 0.4566 / 0 → 0.3383 are the still-sinking 2 s readings. |
| 6 | `r97_nodelat_softfloor` | `softfloor` | 13 / 13 (+4 census) | The re-scoped GP law: soft-body/box contact is **thickness-selective**, not absent — tunnel at 0.1 (−10.83421), REST at 0.2 (0.1018), sideways ejection at 0.4 (−4.26994,−0.96678, below), REST at 0.5 (0.09762) and 2.0 (0.1018); Jolt rests at 0.05 on 0.1 and 2.0, and its `mass=10`/`prec=50` failures are thin-slab-only (both rest at 0.05 on 2.0); Dummy is fully inert (`0,0,0`, below=1); the pinned-cloth **phase law**: with `--pins=now` (pf=0) GP's 2 kg ball passes the cloth and rests on the floor while Jolt's bounces off; `--pin=mid` hangs the mid vertex. The deferred branch is censused only. |
| 7 | `r97_nodelat_xr` | `xr` | 8 / 8 | The ClassDB/XR envelope: all **45** candidates exist, `can_instantiate=false` for exactly 5 (`Joint3D`, `XRInterface`, `WebXRInterface`, `PhysicsServer3D`, `PhysicsDirectSpaceState3D`); `instantiate("XRServer")` + `free()` → teardown crash (`rc=134`, allowlisted `handle_crash` line, ASLR masked); the other 39 instantiable classes exit clean (`iso_clean`, `done=1`); `xr_same`/`xr_keep`/`xr_dbl` return a DISTINCT second XRServer (`identical=false`, `same=false`) and leak cleanly (`rc=0`, 2 allowlisted error lines + 1 ObjectDB-leak notice each). |
| 8 | `r97_nodelat_freegrain` | `freegrain` | 4 / 4 | Deferred deletion is **step-granular**: a `queue_free` issued at tick t is gone on tick t+1 even when both ticks share one process frame (`same_frame=1`, `gone_next=1`) — pinned under `--fixed-fps 10/60/30` batching on GP and at 60 on Jolt, i.e. the boundary §7 hypothesis is rejected and the scout's free-at-tick cells are interleave-invariant, not lucky. |

Not pinned anywhere: every scout cell the boundary did not replay
(`methods.gd`, `slider`/`cone`/`g6`/`prio_*`/`clampbig0`, the DSS
`pt_*`/`is_*`/`cs_*`/`cm_*`/`ri_mask`/`excl_mut`/`excl_id`/`ray_mask*`/
`ray_bf_*off` set, the CB `snap_*`/`ceil_*`/`blockwall*`/`realvel`/
`recovery`/`stop_on_ceil`/`constspd_off`/`wallslide` set, `sbx_*_impulse`/
`pt_impulse`/`ray`, vehicle `brake`/`steer`/`skid`/`nowheel`/`noroll`,
`cls_proj_dummy`, `iso_xrs_dummy`) and the boundary's still-not-armable list
(`solver_priority` dominance, trimesh `hit_back_faces` semantics,
`floor_snap_length`, `recovery_as_collision=false`, the GP
thickness-selection rule).

## 1. Rep-stability contract

- **Authoring sweep** (`corpus/live/r97-author/driver.py`, 6 reps × 8 arms =
  **48 parent runs / 498 children**): **48/48 PASS**, and **one distinct
  `PASS` line per arm** (6/6 byte-identical) — including the `sha` digests,
  which are the row markers the battery pins. The only per-rep variation is
  the softfloor deferred-pin census `#` line (`pf0/pf1` = 0/4, 1/3, 2/2×3,
  3/1) — exactly the declared two-valued startup race, never pinned.
- **Crosscheck** (`corpus/live/r97-author/crosscheck.py`): every child
  receipt vs the scout's/boundary's own receipt —
  `79 checked, 79 identical (10 via the declared setup-line extension),
  0 differ, 0 missing`. The 10 "extension" cells are the boundary's early
  `sf_*`/`pp_*` receipts whose `SF setup` line predates the final
  `r97b_softfloor.gd` (which prints `pins=`/`pin=`); the physics rows were
  verified byte-identical line-by-line, so the extension is a receipt-shape
  normalization, not a physics claim.
- **Declared normalizations** (applied before hashing, mirrored in
  `crosscheck.py`): the allowlisted 2-line Jolt job-system warning (any
  position, counted in `w`), runtime object ids `<Class#12345>` → `<Class#N>`,
  and crash dumps' ASLR fields (`Load address:` → `A`, `[n] <hex> …` →
  `[n] F`, frame count preserved). Allowed engine errors stay in the hashed
  stream and are counted in `ee`; any other ERROR-class line lands in `ue`
  and fails the cell.
- **Child budget**: 83 children per pass, 8-way chunks, each `timeout -s KILL
  14` inside the fixture; battery-row wall times **1.05–8.18 s** (20 s
  per-case bound) in run 1.

## 2. Battery

- Before: **316 cases** (257 ordinary + 59 negative) · After: **324 cases**
  (265 ordinary + 59 negative) = **+8 r97 rows**.
- r97-only pre-run on the final bytes: **8/8 PASS**
  (`corpus/live/r97-author/battery-pre/20261016T060000632128Z/verdicts.json`).
- Full run 1: **324/324 PASS — fully green**, `seeds_unchanged=true`
  (`corpus/live/r97-author/battery1/20261016T060034341712Z/verdicts.json`,
  `battery1.log`). No documented flake fired in this run.
- Full run 2 on the same final bytes: **323/324 PASS**,
  `seeds_unchanged=true`
  (`corpus/live/r97-author/battery2/20261016T060927458121Z/verdicts.json`,
  `battery2.log`). The single failure is the pre-existing, documented
  `phys3d_events_race_class` flake on an r88-era row this change did not
  touch — `race_class jolt crash envelope drift rc=134 v={} tear=0 abort=2`
  — the **byte-identical signature** recorded by r92-verifier2 (run B,
  ~load-100) and entered by the r92 adjudicator as "same-class pre-existing
  flake, not r92 scope". The row is deliberately disjunctive over a
  heap-layout-keyed Jolt crash; the Jolt child aborted without logging its
  tear witness. All 8 r97 rows PASS in this run (1.0–8.2 s).
- Full run 3 on the same final bytes: **324/324 PASS — fully green**,
  `seeds_unchanged=true`
  (`corpus/live/r97-author/battery3/20261016T061912493914Z/verdicts.json`,
  `battery3.log`).
- No r97 row ever reddened (pre-run, three full runs, and the 48-run sweep).
  The only non-r97 failure across the three full runs is the documented
  `race_class` drift above; the other documented flake classes (navagent
  retarget one-tick load flake, `phys3d_joints_*` 20 s knife-edge rows) did
  not fire.

## 3. Corrections / disclosures vs scout+boundary

1. **`plat_ride` Jolt is `fl=1`, not `fl=0`.** The boundary §5 table (and §8
   prose) says "Jolt: carried but `fl=0`, `n=0`". The boundary's own replayed
   receipt `r97b_replay_cb_proj_jolt_plat_ride.r1.stdout.txt` — and the
   scout's `cb_proj_jolt_plat_ride.r1.stdout.txt` — both read `fl=1` on every
   tick through t=120. The fixture pins the receipts (`plat_ride@jolt{fl=1,
   n=0,…}`): the surviving GP/Jolt split is the **reported slide count**
   (`n=1` vs `n=0` while carried at `rv=2.0`), not `is_on_floor`. The
   boundary's own `n=0` half survives verbatim.
2. **The ClassDB census is 45 candidates, not 44.** The scout prose says
   "44 candidates"; `classdb.gd`'s `CANDIDATES` list is 45 entries and the
   fixture's `cls` cell counts `classes=45,noinst=5` on both backends. The
   non-instantiable five and the "everything else is instantiable" law are
   unchanged.
3. **The 10 softfloor setup-line extensions are a probe-revision artifact.**
   The stored `r97b_softfloor.gd` (byte-identical to the fixture's copy)
   prints `pins=`/`pin=` in its setup line; the boundary's early
   `softfloor`/`pinphase` receipts were written by an earlier revision
   without them. Physics rows byte-identical; declared as a normalization,
   never as a claim.
4. **Two-valued cells are never pinned.** The deferred-pin branch
   (`pf=1`) is deterministic but a startup race; the fixture pins only
   `--pins=now` (pf=0, the branch the scout's receipts recorded) and
   censuses the branch split in `#` diagnostics. `sbx_proj_pin_top`/
   `pin_mid`/`collide` deferred values appear in no row.
5. **tps-scoped values are pinned as 60-tps values.** `margin_hi` hover
   (GP 0.5919 / Jolt 0.5969 at 60 tps; ±3 mm across 30/60/120) and the
   vehicle `susp5`/`susp0` 2 s readings (0.4566/0.3383; both sunk to ≈0.2985
   by 4 s at 30 tps) are snapshots, not equilibria. The battery always runs
   the fixture's own 60-tps project bake; the rows carry the values as
   measured at that bake.
6. **The CB scripted forcing is 60-tps-scaled by the probe**
   (`cbedge.gd:187` hardcodes `dt = 1/60`), so `float@jolt{v=0,-19.6,0}` is
   that constant, not an engine-integration law; the pinned law is the
   `fl=0 wlo=1`-while-resting classification.
7. **The XR crash is pinned as the observed degenerate distribution, with
   the envelope phrasing in the row comment.** The boundary censused
   `rc=134` in 66/66 crash children across replay/load16/load32/ffps60 and
   `rc=0` in every leak arm; the fixture pins that split
   (`cls`/`iso_xrs` rc=134 vs `iso_clean`/`xr_*` rc=0). The r90
   bimodality lesson is kept in the row comment ("envelope, not a value
   invariant") because it is a teardown-ordering destructor crash class —
   no escape was observed under 32 hogs, and none in this seat's 48-run
   sweep or three full batteries (the `xr` row is green in all of them).
8. **Dummy cells are vacuity controls, never physics laws.** The Dummy
   readings are pinned only next to their GP/Jolt twins in the same cell
   (`getrid@dummy{prerid=false}`, `drop_t20@dummy{v4=0,0,0,below=1}`).
9. **Nothing was widened beyond the replayed cells.** The fixture drives
   only the ten probe copies and the boundary's own project bakes; the
   deferred-census children are diagnostics, not cells.

## 4. Commands (repro)

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# 6-rep authoring sweep (writes only corpus/live/r97-author/**)
python3 corpus/live/r97-author/driver.py --scratch corpus/live/r97-author/sweep1/scratch \
        --out corpus/live/r97-author/sweep1 --reps 6
# child receipts vs scout/boundary receipts
python3 corpus/live/r97-author/crosscheck.py --scratch corpus/live/r97-author/sweep1/scratch --verbose
# the eight rows alone, then the full battery (three times)
python3 corpus/fixtures/run_battery.py --only r97_nodelat_joint,r97_nodelat_soft,r97_nodelat_dss,r97_nodelat_cb,r97_nodelat_vehicle,r97_nodelat_softfloor,r97_nodelat_xr,r97_nodelat_freegrain --runs corpus/live/r97-author/battery-pre
python3 corpus/fixtures/run_battery.py --runs corpus/live/r97-author/battery1
python3 corpus/fixtures/run_battery.py --runs corpus/live/r97-author/battery2
python3 corpus/fixtures/run_battery.py --runs corpus/live/r97-author/battery3
# one arm directly (the battery's own shape)
godot --headless --path <scratch> --script res://r97_nodelat.gd -- --arm=softfloor
```

## 5. Receipts pointer

`corpus/live/r97-author/` (gitignored scratch): `driver.py`, `crosscheck.py`,
`RECEIPTS.md` (seed sha table, arm/cell/children census, sweep + crosscheck
summaries), `run1/`, `sweep1/` (48 arm runs + 498 child receipts with
per-cell `child.log`, `project.godot`, probe copy), `verify1/` (first smoke
pass), `battery-pre/`, `battery1/`, `battery2/`, `battery3/`,
`battery{1,2,3}.log`. The dead-seat scratch that preceded this seat
(`ftest/` + 5 manual arm logs) was left untouched as found.

Provenance: this seat wrote only `corpus/fixtures/r97_nodelat.gd`,
`corpus/fixtures/r97_probe_*.gd` (10 copies, byte-identical to their
sources), the 8-row insertion in `corpus/fixtures/run_battery.py`, this
report and its scratch tree. No other round's fixtures or receipts were
touched. **No commit made, per instruction.**
