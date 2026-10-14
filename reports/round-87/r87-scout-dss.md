# game-dev-3d round 87 — scout (seat: scout, host: devin)

Wave `shokunin-train-20261101-w18`, lane g3d. Assignment
(`.ufo/waves/shokunin-train-20261101-w18/tasks/g3d-dss-scout.md`, verbatim):
"Map the body-tier surface with independent probes … which body methods are
legal in which phase, does the body-state object have its own
staleness/flush lattice (three.js twin?), refusal classes,
threaded-behavior on body_state vs space_state, the GodotPhysics/Jolt/Dummy
split at body tier."

**Runtime** `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`
(sha256 `3a72f85d53b84d76…`), `--headless`, 60 tps, 32 cores. HEAD
`4e65726`. Scratch `corpus/live/r87-scout-dss/` (`corpus/.gitignore:1`);
**zero tracked-file edits by this seat.** Every child wrapped
`timeout -s KILL`; `rc` raw (`134` = SIGABRT, `-9/137` = kill).

**Evidence**: `corpus/live/r87-scout-dss/` — **67 run groups / 244 receipt
files**, 7 probes, 6 project variants, `manifest.sha256` pins everything.
**Read `corpus/live/r87-scout-dss/RECEIPTS.md` first** — it names the probe
revisions (my own `get_sleep_state`→`is_sleeping` typo hang; the
`BODY_PARAM_CAN_SLEEP` parse error; the missing `max_contacts_reported` opt-in),
the probe-side RID/ObjectDB leak artifacts, and every disclosed confound.

**LSP unavailability recorded.** `mcp_list_servers` exposes no `lsp` device
(same as r85/r86). Every class/method fact is engine-measured via
`ClassDB.class_get_method_list` (`runs/intro_*`), never grep-level proof.

**Determinism**: all 6 `ph_*` cells byte-identical across 2 reps; `st_*`,
`fl_*`, `mm_*` byte-identical on non-threaded variants; threaded cells
differ *only* by the measured race observables (§5).

---

## 1. The body-state object is a per-body SINGLETON live handle — and its `get_space_state()` is literally the space-tier object

Measured on every real-backend cell (`ph_*`, `mm_*`, `st_*`, `xt_*`):

- `body_get_direct_state(rid)` returns the **same instance every time** —
  instance ids identical across all positions (`#1484` at A–F on proj), and
  `SAMEOBJ two_fetches_eq=true`.
- It is **the same object the engine hands the callbacks**: inside
  `_integrate_forces`, `body_get_direct_state(rid) == state` → `same_obj=true`;
  inside `body_set_state_sync_callback`, `same_obj=true` — on GodotPhysics
  AND Jolt. There is no per-fetch object; the API returns the body's one
  persistent direct-state handle.
- **`bds.get_space_state()` is `==` `space_get_direct_state(wspace)` is `==`
  `World3D.direct_space_state`** (`eq_srv=true eq_world=true` in all
  TWIN/XT rows). The "three-tier twin" is literal object identity: the body
  tier exposes the identical space-state singleton through a third accessor.
- The handle **survives detach and reattach**: `body_set_space(RID())` →
  refetch nil but the stashed handle still reads the last transform;
  `body_set_space(wspace)` → refetch returns `same_obj=true`.

ClassDB catalog (`intro_*`): `PhysicsDirectBodyState3D` = **50 methods**,
`can_instantiate=false`. Flags split the surface cleanly: all reads are
`flags=5` (NORMAL|CONST), all mutators `flags=1`. `PhysicsDirectBodyState3DExtension`
exists; `PhysicsDirectJointState3D` does not.

## 2. Legality: the gate is on the FETCH only; every held-handle method is legal in every phase

Phase map `ph_*` (positions A `_initialize`, B deferred `_run`, C
`process_frame`, D `physics_frame`, E `_physics_process`, F `_process`,
IF `_integrate_forces`, SS state-sync callback), merged stream:

| position | `proj` / `proj_jolt` | `proj_thr` / `proj_jolt_thr` | `proj_dummy(_thr)` |
|---|---|---|---|
| A,B,C | fetch ok, **full 50-method battery legal** | fetch → `<Object#null>` + `Body state is inaccessible…` | fetch ok, full battery |
| D,E | legal | legal | legal |
| F | legal | refused + ERROR | legal |
| IF, SS | legal; `state ==` fresh fetch | legal; same | **callbacks never fire** (IF done=false, SS n=0) |

- On non-threaded there is **no phase restriction at all**: position A at
  `pf=0` already returns the live handle and every one of the 50 methods
  works — including all 18 writes, which land immediately (the
  `set_linear_velocity`/`apply_impulse`/`apply_central_impulse` calls in the
  A battery produced `lv.x=0.03` by position D).
- Under threading the **fetch** is gated exactly like the space tier
  (`in_phys` at fetch decides), BUT a handle obtained once is usable
  **ungated at every later position** — reads return live values and writes
  land (`st_proj_thr`: `PROC n=4 stash_lv=50.0` right after an out-of-phase
  `stashed.set_linear_velocity(50)` while `fresh=nil` + ERROR). **The gate
  controls acquisition, not use.**
- Server-tier body calls (`body_get_state`, `body_get_param`) are ungated
  at every position on every variant (`SRV` rows) — the gate exists only
  on the two direct-state fetch accessors.
- Server-created bodies have no `Object`: `get_contact_collider_object` →
  `<Object#null>` even at valid indices on both real backends.

Refused fetch detail: the refused return is a **null-Object Variant** —
`bds == null` is true (so the r86 guard shape `if bds != null` is correct),
`bds is Object` is false, `str(bds)` is `<Object#null>`.

## 3. Refusal classes at the body tier (all measured)

| # | text / behavior | trigger | backends |
|---|---|---|---|
| 1 | `ERROR: Body state is inaccessible right now, wait for iteration or physics process notification.` (`godot_physics_server_3d.cpp:952` / `jolt_physics_server_3d.cpp:969`) | fetch at non-physics phase, threading only | GP, Jolt |
| 2 | `ERROR: Index p_contact_idx = N is out of bounds (body->contact_count = M).` | contact getter with idx ≥ count | GP text vs Jolt `((int)body->get_contact_count() = M)` — **different strings for the same class** |
| 3 | `Parameter "body" is null.` (r86) on never-valid `RID()`; **silent `nil`** on freed or space-detached RID | refetch after `free_rid`/`body_set_space(RID())` — **no ERROR at all** | GP, Jolt |
| 4 | `ERROR: Failed to apply central impulse to '<unknown>'. Doing so without a physics space is not supported when using Jolt Physics.` | impulse write on a space-detached body | **Jolt only** — GP silently no-ops the same call |
| 5 | silent `<null>` returns / void no-op, **no error** | any method on a stashed handle whose body was `free_rid`'d | GP, Jolt |
| 6 | **hard crash** — GodotPhysics `signal 11`, Jolt `std::system_error` abort (rc 134) | `intersect_ray` on the space-state object of a `free_rid`'d space | GP, Jolt |
| 7 | none exists | everything incl. freed-RID calls returns defaults | Dummy |

The one crash surface found is not the *body* handle but the space handle
reached through it: `bds.get_space_state()` on a space-freed body returns a
live space-state object, and querying it segfaults/aborts. Freed-*body*
handles are benign — every method degrades to null/void silently.

## 4. The staleness/flush lattice inside the tier

- **No snapshot semantics on the kinematic surface.** `stash_lv`/`stash_ty`
  track `fresh_lv`/`fresh_ty` every frame (`st_*` LIVE rows), and
  out-of-phase `_process` reads see real current values. Writes are
  same-turn visible through all three views (`fl_*`: `body_set_state`,
  `set_linear_velocity`, `set_transform`, `apply_central_impulse`,
  `integrate_forces` all immediate in-phase AND out-of-phase;
  `body_get_state` and the stashed handle agree to the last digit).
- **But three sub-fields are step-stamped, not live** — the object's own
  internal flush seams:
  - `get_step()` reads a backend init constant — **0.001** GodotPhysics,
    **0.0** Jolt, **0.0** Dummy — at every position before the first solve
    completes (A–E incl. the pf=1 in-phase reads), and `0.016667` once
    stamped (F at pf=1; inside IF/SS). Within pf=1 the intra-tick order
    (r86: `_physics_process` → sync cb → `_integrate_forces`) puts E's read
    *before* the stamp — the first tick's `get_step` is position-dependent.
  - `get_total_gravity()` / `get_total_linear_damp()` are `(0,0,0)`/`0.0`
    at positions A–C (pre-first-step), real values (`-9.8`/`0.1`) only after
    a step has run.
  - The **contact buffer is last-step data** — the one snapshot-semantics
    field (consistent with the fixture's `contact_stale` 1-step window).
    Contact reporting requires `body_set_max_contacts_reported > 0`
    (default 0 → `get_contact_count()==0` even while resting on a floor —
    the r86 fixture opt-in is load-bearing; this seat's rev-1 probe
    measured an always-zero count without it).
- `set_sleep_state(true)` lands everywhere; after it the body freezes and
  `get_step` reads keep working.

## 5. Threaded behavior: `body_state` vs `space_state`

Both tiers are the same *kind* of object — per-object singleton live
handles behind a fetch gate — and differ only in what their methods do:

| cell | `proj_thr` (GP+thread) | `proj_jolt_thr` (Jolt+thread) |
|---|---|---|
| fresh fetch at `in_phys=false` | nil + ERROR (`:952`/`:194`) | nil + ERROR |
| held bds read out-of-phase | **live values, ungated** | live values, ungated |
| held bds write out-of-phase | lands same-turn | lands same-turn |
| held dss `intersect_ray` out-of-phase | **7 hits, always answers** | **silent-empty when racing the step** — `post_ray_hits=0` in 4/4 runs; one mid-run `stash_ray=0` among 18 out-of-phase queries (r3) |

- **Out-of-phase writes race and can be lost.** `fl_proj_thr` r1 vs r2
  differ: `set_sleep_state(true)` at `in_phys=false` read back
  `srv_sleeping=false` in r1, `true` in r2 — the write was overwritten by a
  concurrent step in one rep. Non-threaded cells are byte-stable; threaded
  cells show ordering jitter (which pf a `_process` observes) plus this
  genuine write-loss class. Ungated and unsynchronized.
- Out-of-phase *reads* were never torn in these probes (velocities moved
  smoothly), but nothing synchronizes them — "no torn read observed" is the
  measured claim, not a guarantee.
- `mm_proj` ≡ `mm_proj_thr` **byte-identical** at legal positions: inside
  the physics phase, threading changes nothing at the body tier.

## 6. GodotPhysics / Jolt / Dummy split at the body tier

| cell | GodotPhysics | Jolt | Dummy |
|---|---|---|---|
| class name | `GodotPhysicsDirectBodyState3D` | `JoltPhysicsDirectBodyState3D` | `PhysicsDirectBodyState3DDummy` |
| methods callable at legal pos | 50/50, errors only on OOB contact idx | 50/50, same class of errors | 50/50, **0 errors anywhere** |
| `get_contact_impulse[0]` at rest (cc=4) | **`(0,0,0)`** | **`(-0.0068, 0.647, 0.013)` — real impulse** | `(0,0,0)` |
| `get_contact_local_shape` out-of-range | `-1` | `0` | `0` |
| `set_sleep_state(true)` side effect | velocity retained (`lv=53.99` after sleep) | **velocity zeroed** (`lv=(0,0,0)`) | no-op |
| `get_step` init constant | 0.001 | 0.0 | 0.0 |
| detached-body impulse write | silent no-op | loud Jolt error (class 4) | silent no-op |
| freed-body handle calls | silent `<null>`s | silent `<null>`s | still returns defaults |
| freed-space `intersect_ray` | SIGSEGV | `std::system_error` abort | `{}` empty dict, rc 0 |
| `_integrate_forces` / sync callback | fire (1×/tick, `same_obj`) | fire (`same_obj`) | **never fire** |
| fetch gate (threaded) | gated | gated | **never gated, any RID** |

Jolt's `get_contact_impulse` returning real per-contact impulses while
GodotPhysics returns zeros at the same resting contact is the strongest new
`inverts`-flavored cell at this tier. `get_contact_local_position[0]` also
mirrors (`(1,…,-1)` GP vs `(-1,…,1)` Jolt) — contact ordering is
backend-specific, so never arm an index-numbered cell across backends.

## 7. Author directives (exact)

1. **Treat `body_get_direct_state`'s result as a process-lifetime handle,
   not a frame object.** One fetch suffices forever — the singleton is the
   same instance `_integrate_forces`/`body_set_state_sync_callback` receive.
   Re-fetching per tick buys nothing and re-arms the fetch gate.
2. **Under threading, fetch once at a legal position, then use the held
   handle anywhere** — the object's methods are ungated at every position.
   The carve-out only needs to cover the two accessor texts
   (`Space state is inaccessible…`, `Body state is inaccessible…`); held-
   handle calls never emit them.
3. **Do not arm out-of-phase body-tier writes under threading.** They land
   unsynchronized — `fl_proj_thr` measured a lost `set_sleep_state` (r1 vs
   r2). In-phase writes are deterministic.
4. **Never query a space-state object whose space may be freed** — that is
   the one crash cell (SIGSEGV/`system_error`). Freed *body* handles are
   safe (silent nulls); freed *space* handles are not.
5. **Contact cells need `body_set_max_contacts_reported > 0`** and are
   last-step data; on Jolt `get_contact_impulse` is real, on GodotPhysics
   it reads `(0,0,0)` — arm the impulse cell as a backend-split row, never
   cross-backend.
6. **`get_step`, `get_total_gravity`, `get_total_linear_damp` are
   step-stamped**: they hold init constants (0.001/0/0, (0,0,0), 0.0) until
   the first solve completes — do not read them as ground truth at pf≤1,
   even at in-phase positions.
7. **A `free_rid`'d or space-detached body refetches `nil` *silently*** —
   a different class from `RID()`'s loud `Parameter "body" is null.`.
   Null-check the refetch; do not rely on the ERROR to notice.
8. **Dummy children cannot witness anything at this tier** — including
   crash cells: freed-space `intersect_ray` under Dummy returns `{}` and
   exits 0. Never arm a body-tier Dummy row as a hazard detector.

## 8. Remaining unknowns

- **Whether held-handle calls under threading hold any lock at all** —
  reads looked untorn and most writes landed, but the measured write-loss
  says at least the write path races the step. Per-field atomicity is
  unmeasured (would need a stress probe watching for torn Transform3D
  reads).
- **Why Jolt zeroes velocity on `set_sleep_state(true)` and GodotPhysics
  doesn't** — measured twice (st_jolt_thr FIN, fl_jolt), mechanism
  inference only (Jolt clears motion on sleep transitions).
- **`integrate_forces()` outside the callback** returned void and applied a
  force-integration step (lv decayed by damp) on both real backends with no
  error — its *exact* semantics out-of-callback (does it run the solver's
  pre-checks?) are unbisected.
- The racy empty-ray window on `proj_jolt_thr` correlates with the step
  lock but the lock predicate wasn't bisected — `post_ray_hits=0` was 4/4
  at the same out-of-phase point, 1 mid-run `stash_ray=0` was racy.
- `get_collision_layer/mask` writes through the handle returned void;
  whether they re-pair the body mid-run is unmeasured.
- `SS` fired 10/10 ticks on a moving rigid on both real backends (r86's
  `0` was static-body-scoped — confirmed); whether it fires during
  deactivation transitions is unmeasured.
- Single-rep cells: `fr_*`, `mm_*`, `xt_*` non-threaded cells; everything
  deterministic-claimed ran ≥2 reps.
- All of the above is scoped to this host, this Godot build, `--headless`,
  60 tps, and the six `proj*` variants.

**Seat output complete.** Evidence: `corpus/live/r87-scout-dss/` (7 probes,
67 run groups / 244 receipts, `manifest.sha256`, `RECEIPTS.md`). No tracked
file was edited; nothing committed.
