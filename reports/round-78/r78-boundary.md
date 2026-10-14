# Game-dev-3d round 78 — boundary (revenger): map_set_active(false) permanence ladder, callsite family, off/on cycles

Seat: boundary (role revenger). Scope: scratch-only under
`corpus/live/r78-boundary/`; no tracked edits, no commits, leaf — no
dispatch. The lane's declared axis-move (inactive-map wait ladder
{20,60,120,300}f on link-kill-under-mapoff to bound the "permanent-stale"
claim; callsite-shift paired arms coroutine vs `_physics_process`) is
owned by the author seat. My assigned recon — the four probe edges from
the brief — runs on my own scratch harness:

1. waits beyond 300f — 600f/1200f, where does a real bound live?
2. map_off ladder with a FORCING read mid-wait — does a read at 150f
   perturb the 300f outcome (r77 mark-vs-phase)?
3. callsite from OTHER contexts — idle_frame vs physics_frame vs signal
   callback.
4. multiple inactive cycles — off→on→off, does state accumulate?

**At probe time the tracked fixture carries no r78 code**: canonical HEAD
`71818b7` (r77 report-last), `git status` clean on `corpus/fixtures/`
throughout (verified at report close; `?? reports/round-78/` only —
sibling reports). HEAD CASES = 173 rows.

## Deliverable and method

`corpus/live/r78-boundary/scratch/navagent3d_mapoff.gd` sha256
`e1125e94baaa4eb39bafa5ad302c1f3c16a0e2ead825155efd5c014f7bbb6593` —
SceneTree probe. Geometry verbatim from the r70 L-corridor + r73 island +
r73 server bridge link (identical to r76 `navagent3d_syncwin.gd` /
r77 `navagent3d_applyorder.gd`): A1 x[0,2]z[0,1], A2 x[2,3]z[0,1],
B x[2,3]z[1,4], C x[2,3]z[5,6]; link ls=(2.5,0,3.5)→le=(2.5,0,5.5);
agent S=(0.5,0,0.5)→T=(2.5,0,5.5). Path WITH link
`[S,(2,0,1),ls,le]`, WITHOUT `[S,(2,0,1),(2.5,0,4.0)]`.
`project.godot` byte-identical to the tracked seed (sha256
`1fda90d4…8eac23`). Godot `4.7.2.stable.arch_linux.ed1daf0bf` via
`/usr/bin/godot --headless`, 60 tps, cell_size 0.25, 30-tick settle;
deferred query materialized once before `pre` is captured.

**New instrument this round**: a `NavigationServer3D.map_changed` monitor
(the signal exists on this build — confirmed by `get_signal_list`,
`runs/smoke.stdout.txt`-equivalent smoke run). Every emission is recorded
pf-stamped (`pf=N iter=M mon|other`) — a DIRECT witness of the map
rebuild/sync, one level deeper than the served tuple. A late flush under
`map_set_active(false)` would emit it; the falsification detector for the
declared claim is therefore {zero `map_changed` during off} ∧ {`map_iter`
frozen} ∧ {served tuple unchanged}, not tuple sampling alone. A second
`map` exists in the root world (tagged `other`); only `mon` rows count.

Truth digest per frame: `pf / map_iter / map_active / link valid /
link_iter / link_en / region_iter / region_en / region_x /
agent_layers`. Served signature = stored-path point list; full tuple sig
(idx/next/final/dist/reachable/reached/finished/path) at arm end.

```
timeout 150 /usr/bin/godot --headless --path corpus/live/r78-boundary/scratch \
    --script res://navagent3d_mapoff.gd -- --arm=<name> [--n=N --mode=killed|nokill \
    --read=none|every|at:K --fu=K --w1 --k --w2 --woff --ctx=<ctx>]
```

44 runs under `corpus/live/r78-boundary/runs/` (`<name>.stdout.txt`,
`.stderr.txt`, `.exit`) via `run_arms.sh` + three follow-up arms.
**Every run exit 0; every stderr empty except the intentional
`pathch_arity` negative receipt** (a 1-arg handler on the 0-ary
`path_changed` → engine `emit_signalp` arity error, write never lands —
proves the emission fires inside the trigger read). All repeat families byte-identical
(md5): `lad_300`/`_r2` `c42d929d…`, `lad_300_read150`/`_r2` `8869ed57…`,
`lad_60_fu30`/`_r2` `140f757f…`, `cyc_double`/`_r2` `a426ba2f…`,
`ctx_{phys,idle,psig,mapch,pathch}`/`_r2` `553ef35d…` / `9c5a6d26…` /
`2e68b0a3…` / `db24657e…` / `54586c25…`. One jitter locus observed:
the SETUP-phase `map_changed` pf tags vary ±1 tick between processes
(`pf=2 iter=1` vs `pf=3 iter=1` in `cyc_stagger_w30` vs `w10` setup) —
world-construction sync scheduling; every post-arm measurement is
byte-stable.

## (1)+(2) Inactive-map wait ladder — permanent-stale NOT falsified out to 1200f; bound extended 15f→1200f; zero mid-wait perturbation

Arm: `map_set_active(false)` + `link_set_enabled(false)` same-turn (the
r77 `mut_map_cycle` shape: kill-under-mapoff), wait n frames with NO
agent reads, truth digest every frame, `map_changed` monitor armed; then
`map_set_active(true)` and a per-frame serve sample.

| rung n | off-period `map_changed` emissions | off-end truth | post-on serve |
|---|---|---|---|
| 20 / 60 / 120 / 300 / 600 / **1200** | **0** at every rung (`*.off map_events[0]=[]`) | `map_iter=2 link_iter=1 link_en=false map_active=false` — ONE distinct digest across all frames (verified by dedup on `lad_{20,300,1200}`) | fresh dead clamp `(2.5,0,4.0)` at **on+2**, identical tuple |

Receipts: `runs/lad_{20,60,120,300,600,1200}.stdout.txt`,
`lad_300_r2.stdout.txt` byte-identical.

- The falsifiable claim survives the ladder: no `map_iter` bump, no
  `map_changed` emission, no tuple change at ANY rung. The r76 "+15f"
  bound extends to **+1200f** (20s of physics) with a direct emission
  witness. "Permanent" remains a bound — now a 1200-frame one, not a
  proof of unboundedness.
- The off-window is a TOTAL freeze, not a slow leak: the queued kill's
  setter stores eagerly (`link_en` reads false from off+1 — the
  object-stored value) while `link_iter` never stamps (stamps need the
  rebuild, which never runs). Object-apply is not gated by `active`; the
  map rebuild is. Same stored-vs-stamped split r77 saw via
  `Loff,Mon,Moff`.
- The post-reactivation edge is **wait-length independent**: on+1 stamps
  `link_iter=2` + emits iter3 (event tagged on+1), serve fresh at on+2 —
  identical at 20f and 1200f. Nothing accumulates, expires, or
  overflows in the queue.

**Forcing read mid-wait — zero perturbation** (`lad_300_read150{,_r2}`
byte-identical, `lad_300_read50`, `lad_60_read30`): a
`get_next_path_position` at off+150 (also 50, 30) serves the COMMITTED
tuple verbatim; zero events; off-end truth identical; post-on lands at
on+2 unchanged. **The r77 mark-vs-phase interaction does not exist under
inactivity** — a forcing read is pure against the frozen map: it neither
forces a server flush nor shifts the reactivation edge. `read=every`
(`lad_60_readall`, `lad_120_readall`): 60/120 consecutive per-frame
forcing reads, committed tuple every frame (62/122 committed-sig lines
incl. pre/post-on-stale rows), zero events, on+2 unchanged.

**Mid-wait `map_force_update`** (`lad_300_fu150`, `lad_60_fu30{,_r2}`):
force at off+150/off+30 stamps `link_iter` 1→2 same-turn WHILE off
(`fu_at` line: `link_iter=2 link_en=false`, `map_iter` stays 2, no
emission) — replicates r77 `fu_off_queue` at depth: force runs the
setter stage on an inactive map, never the rebuild. Post-on consequence:
serve fresh at **on+1** (`fstar=1`, iter3 event tagged on+0's next sync)
vs +2 unforced — reactivation then owes only the rebuild. Consistent at
150f depth, not just the r77 3f depth.

**No-kill reactivation control** (`lad_60_nokill`, `lad_300_nokill`):
off→on with no queued write is a PURE no-op — `map_iter` stays 2 across
the whole cycle, `map_events[0]` (not even one emission), committed
tuple served at every frame incl. post-on (`fstar=-1`). The iter3/event
after `Mon` in kill arms is the QUEUED WRITE's rebuild, not a
reactivation cost — `map_set_active` itself dirty-marks nothing on this
build.

## (3) Callsite contexts — the queue cut sits between the deferred flush and the idle phase; two absolute latency bands

Same `Loff` issued from nine contexts; coroutine resumes at the first
`physics_frame` after `fired`, prints getter truth at resume, samples
f=0..6 (`runs/ctx_*.stdout.txt`).

| ctx | context | fire pf | `link_iter=2` visible | iter3 stamp/emission | serve fresh | abs. write→serve | fstar (await-count) |
|---|---|---|---|---|---|---|---|
| `co` | coroutine / `await physics_frame` resume | 31 | 32 | 32 (ev@32) | 33 | **+2** | 2 |
| `psig` | `physics_frame` signal callback | 32 | 33 | 33 (ev@33) | 34 | **+2** | 2 |
| `phys` | `_physics_process` virtual | 32 | ≤33 (applied by resume) | 33 (ev@33) | 34 | **+2** | 1 |
| `defer` | `call_deferred` flush | 31 | 32 | 32 (ev@32) | 33 | **+2** | 1 |
| `idle` | `_process` virtual | ~31.5 | 33 | 33 (ev@33) | 34 | **+3** | 2 |
| `isig` | `process_frame` signal callback | ~31.5 | 33 | 33 (ev@33) | 34 | **+3** | 2 |
| `tmr` | `SceneTreeTimer.timeout` | ~31.5 | 33 | 33 (ev@33) | 34 | **+3** | 2 |
| `mapch` | inside `map_changed` emission (write during sync) | 32 | 34 | 34 (iter4 ev@34) | 35 | **+3** | 2 |
| `pathch2` | inside `agent.path_changed` emission (inside the forcing read's path replacement) | 35 | 36 | 36 (iter4 ev@36) | 37 | **+2** | 2 |

**`phase_probe`** (`runs/phase_probe.stdout.txt`) pins the intra-tick
order that produces the split — three phases reading the same digest
after a `co`-context Loff@pf31:

- C@31 (`_physics_process`): `link_iter=1` — still queued.
- F@31 (`_process`, same iteration): `link_iter=2` — **the setter-apply
  stage runs between `_physics_process` and the idle `_process` of the
  same tick.**
- B@32/C@32: `map_iter=2`; F@32: `map_iter=3` — **the rebuild stage runs
  in the same sync slot one tick later** (emission tagged pf=32).
- B@33: serve fresh — agent requery lands one tick after the rebuild
  tick.

Model (all nine rows fit): per physics tick — [B: `physics_frame`
emission incl. coroutine resumes and signal callbacks] → [C:
`_physics_process`] → [D: deferred/message-queue flush] → [SYNC: apply
queued setters (stamp object iters) + rebuild maps dirtied by prior
syncs (stamp `map_iter`, emit `map_changed`)] → [F: idle —
`_process`/`process_frame`/timers]. A write in B/C/D of tick t applies
at sync(t), rebuilds at sync(t+1), serves at reads of t+2. A write in
F(t) or INSIDE the sync's own emission (`map_changed`) misses sync(t)'s
apply → applies at sync(t+1) → serves at t+3 — **one tick deeper in
absolute latency**. The `pf` counter does not advance during idle, so
idle writes at "pf=31" land a full tick behind coroutine writes at
"pf=31".

Corollaries for the tracked pair:
- The r76-critic `bb_physmut` +1 shift replicates (`phys` fstar=1, getter
  applied at resume) but is **observational**: in absolute ticks the
  `_physics_process` write lands serve at write+2 identically to `co` —
  the coroutine just cannot observe until the next `physics_frame`
  resume, which is already +1 deep. `defer` shows the same signature
  (fstar=1, applied at resume).
- The genuinely DIFFERENT regime is idle-phase: `_process`,
  `process_frame`, and `SceneTreeTimer.timeout` all cost +3 absolute —
  one tick deeper than every physics-side context. A tracked arm that
  pins only {coroutine, `_physics_process`} understates the family: the
  interesting boundary is pre-sync vs post-sync, and `idle`-context
  writes are the post-sync side.
- `mapch` is the deepest measured context (+3): a write issued inside
  the `map_changed` emission queues for the NEXT sync's apply — the
  in-emission write misses the sync it was emitted from (apply@33 →
  link_iter=3@34; rebuild@34 → iter4 ev@34; serve@35).
- `path_changed` notes (`ctx_pathch`, `pathch2`): the signal is 0-ary
  and emits only inside the path-REPLACING call — a bare
  `target_position` retarget produced zero emissions in a 30f wait
  (`ctx_pathch` `fired pf=-1`); triggered properly (Lmv lands, then a
  forcing read re-queries and the stored array is replaced —
  `pathch2`), the emission fires inside `get_next_path_position`'s
  internal update. A write inside it lands in the **+2 band** like
  physics-phase writes (the emission executes inside the caller's
  B-phase read): apply@36, iter4 rebuild ev@36, serve@37. The 0-arity is
  pinned by `runs/pathch_arity.*` — a 1-arg handler produces an engine
  `emit_signalp` error on stderr and the write never lands
  (`fired pf=-1`, `link_en=true` throughout, no iter4 rebuild —
  fstar=-1).

## (4) Multiple inactive cycles — pipeline progress persists BY STAGE across an off-flicker; nothing accumulates

`cyc_quick` (`runs/cyc_quick_k{0,1,2,3,10}.stdout.txt`): off1 → kill →
wait 5 → **on for k frames** → off2 → wait 5 → on2 → serve sample:

| on-window k | state entering off2 | on2 landing |
|---|---|---|
| 0 | `link_iter=1` (never applied) | fresh at **on2+2** — full window owed |
| 1 | `link_iter=2` (setter stage banked), `map_iter=2` | fresh at **on2+1** — owes rebuild only |
| 2, 3, 10 | `link_iter=2`, `map_iter=3` (rebuild done) | fresh at **on2+0** (fstar=0) — fully landed during the 2-frame on-window |

A single active frame banks exactly one pipeline stage; the second off
freezes progress mid-flight without rolling it back; the second on
resumes the pending stage. Iter stamps are monotone across the flicker
(no re-stamp, no re-queue, no double-apply).

`cyc_double` (`_r2` byte-identical): full round trip twice —
off→kill→on lands the dead clamp at on+2; `Lon` restore lands the
committed route at +2 (`link_iter` 2→3, `map_iter` 3→4); second
off→kill→on lands at on+2 again (`link_iter` 4, `map_iter` 5). **The
second cycle reproduces the first verbatim** — only the monotone
iteration counters advance; no behavioral state accumulates.

`cyc_stagger` (woff=10 and 30): two DISTINCT writes at different points
of one off-window (kill at off+0, link-end move at off+w) coalesce into
ONE landing — `link_iter` 1→2 at on+1, iter3 event at on+1, single dead
clamp at on+2. Queued writes under a shared freeze merge; the freeze
does not stagger them.

## Reconstructed contract (evidence chain)

1. `map_set_active(false)` removes the map from the sync iteration
   ENTIRELY — zero `map_changed` emissions at 6 rungs to 1200f, frozen
   `map_iter`/`link_iter`, committed tuple served through arbitrary
   forcing reads. The r76 "never transitions" is now bounded at 1200f
   with a direct emission witness. Setter object-state still applies
   (`link_en` false from off+1); stamps and rebuilds do not.
2. Reads against an inactive map are pure — no mark-vs-phase: mid-wait
   and every-frame forcing reads change nothing server-side and leave
   the on+2 reactivation edge identical.
3. `map_force_update` under inactivity runs the pending setter stage
   only (`link_iter` stamps, `map_iter` frozen, no emission) and halves
   the post-reactivation edge to on+1 — at any depth.
4. `map_set_active(true)` itself is a no-op with respect to sync: no
   dirty, no iter bump, no emission. The post-on rebuild is the queued
   write's, charged at its normal window.
5. Callsite latency = position vs the per-tick sync point: pre-sync
   phases (physics_frame emit / `_physics_process` / deferred flush /
   inside-`path_changed`, which runs inside the caller's own
   physics-phase read) → serve at write+2; post-sync phases (idle
   `_process`, `process_frame`, `SceneTreeTimer`) and
   inside-`map_changed` writes → write+3. The r76 await-count "+1" for
   `_physics_process` is a resume-observation artifact; absolute
   latencies are {+2,+3}.
6. Off/on flicker preserves pipeline progress by stage (k-frame
   on-window banks k stages: apply≥1, rebuild≥2); cycles neither
   accumulate nor corrupt; distinct queued writes coalesce.

## Suggested battery surface (for the author / verifier)

- The ladder arm's falsification witness should pin `map_iter`
  (srv_get) AND/OR a zero-transition signature — my `map_changed`
  monitor is scratch-level; in-fixture the equivalent pin is
  `map_iter` unchanged at every rung plus the committed tuple. If the
  tracked arm asserts an iter bump or tuple change at any of
  {20,60,120,300}f it falsifies on this build (6/6 rungs frozen,
  byte-identical repeats).
- Post-reactivation pin: dead-clamp serve at **on+2** regardless of
  wait depth — a `{1,3}` pin would falsify here. With a mid-wait
  `map_force_update` it is **on+1**.
- Paired callsite arms: coroutine-context kill pins serve edge 2;
  `_physics_process`-context pins await-count 1 with getter-applied at
  resume. If the author wants the deeper truth: idle-context
  (`_process`/`process_frame`/timer) writes land **one tick deeper**
  than physics-context writes at the same nominal pf — an arm pinning
  parity there falsifies. The discriminating observable is
  `link_iter`/`map_iter` stamp timing, not only the served tuple.
- `map_set_active(true)` contributes nothing by itself — a
  reactivation-only arm must expect fstar=-1 / iter unchanged.

## Divergences and honest caveats

- `path_changed` reached only via path-replacing reads: it emits inside
  `get_next_path_position`'s internal update (0-arg), not on a bare
  retarget — `ctx_pathch` waited 30f post-retarget with no emission;
  `pathch2` triggered via requery and measured the write landing in the
  +2 band. The emission context is therefore "inside the caller's own
  read", not an engine-side async phase.
- The intra-tick phase model is reconstructed from stamp-visibility
  ordering (B/C/F reads + emission pf tags); engine queue internals
  unprobed — mechanism marked inference; every LATENCY number above is
  direct measurement.
- `map_changed` pf tags during world-construction jitter ±1 tick
  across processes (setup-phase sync scheduling); post-arm-start
  measurements are byte-identical across all repeats — the jitter does
  not reach the measured axes.
- One engine build (`4.7.2.stable.arch_linux.ed1daf0bf`), one host,
  60 tps, 30-tick settle, teleport-motion only, single region/link/map —
  same bounds as r72–r77. Off-wait bound is 1200f, not unbounded.
- The author's tracked diff had NOT landed at probe time or at report
  close (HEAD `71818b7`, fixtures clean); all edges measured on the
  committed r77 surface. Post-cutoff verification therefore covers the
  authored landing only if it arrives after this report — receipts
  stand on the frozen HEAD.

## Evidence index

- Probe: `corpus/live/r78-boundary/scratch/navagent3d_mapoff.gd` sha256
  `e1125e94…b6593`; `project.godot` sha256 `1fda90d4…8eac23`
  (byte-identical to tracked seed).
- 44 runs, `corpus/live/r78-boundary/runs/<name>.{stdout.txt,stderr.txt,
  exit}` — all exit 0; all stderr empty except the intentional
  `pathch_arity` negative receipt (engine `emit_signalp` arity error).
- Determinism: 8 repeat pairs byte-identical (md5s in method section).
- Driver: `corpus/live/r78-boundary/run_arms.sh`.
