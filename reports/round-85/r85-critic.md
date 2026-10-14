# game-dev-3d round 85 — critic (seat: critic, host: devin) — adversarial review of `f230443`

Post-commit review of `f230443` ("r85: backend cross-product — jolt_threaded +
dummy_refused + srv_phase_delta"). I attack the landed claims, not the task
owner. I do not judge, admit, edit, integrate, ship, or spawn.

**Lane root** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD
`f230443`. **Runtime** `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf` (2026-08-17), `--headless`, 60 tps. Every
run below is `timeout -s KILL`-bounded and scoped to that build.

**Landed bytes measured (not quoted):**

| file | sha256 | size |
|---|---|---|
| `corpus/fixtures/phys3d_events.gd` | `4bcde2bf39cd829887b7cea9da41fe6c3a528cbbfd9f62900b44c30c6db72355` | 1263 lines |
| `corpus/fixtures/run_battery.py` | `991c6c8ac39a58a576dd9d1e1cc4d922a996dc9b978c9a5f435d325c2666add5` | 920 lines, **191** `CASES` rows |

Both match the author report's §6 citations. `CASES[-3:]` =
`jolt_threaded, dummy_refused, srv_phase_delta`; each pinned marker is
**byte-equal to a fixture `_exit_ok` literal** (checked programmatically; the
only phys3d marker that is not an `_exit_ok` literal is `static_nopair`, which
is the negative-rejection `print` + `quit(2)` — correct by design).

**Write scope honoured.** `reports/round-85/r85-critic.md` +
`corpus/live/r85-critic/` only (`run_matrix.py`, `matrix.json`,
`controls.json`, `ctl/`, 8 mutation trees, `runs/`). No tracked file touched,
no git mutation, no subagent. `git status --porcelain` before and after = the
pre-existing untracked report/round dirs only.

**Seat axes (named):** **A1** threading-witness integrity (does the pin
discriminate the real engine state) · **A2** negative-control integrity (can
Dummy earn a known class) · **A3** write-path identity (server-level, no node
sneak) · **A4** fold behaviour preservation (lost guard) · **A5** receipt
provenance (log slots, unlink, sha citations) · **A6** pin load-bearing
(mutation sensitivity) · **A7** count/authority drift (tracked doc) ·
**A8** latent-hazard scope (Dummy × threading).

---

## 1. Verdict table

| # | landed claim | my verdict | hardest evidence |
|---|---|---|---|
| 1 | `jolt_threaded`: split is threading-invariant | **holds** (independently reproduced) | `ctl/jolt_nothr/jolt_edge` map **==** `ctl/jolt_thr/jolt_edge` map, byte-equal list; `jt_*` == `jolt_*` modulo prefix |
| 2 | `jt_threaded=true` witness discriminates a non-threaded child | **holds for the engine; bounded** | key ablated → child prints `jt_threaded=false` → FAIL; non-threaded control 0/12 refusals; **but** a child whose witness is forced true passes (M6) — the witness is a child self-report |
| 3 | `>=8 of 12` tolerance is load-bearing, not hiding a miss | **holds** (safe direction) | threaded 11/12; non-threaded 0/12; the unmeasured band 1..7 can only produce a false *FAIL* |
| 4 | `dummy_refused`: every arm `unexpected`, split is backend-real | **holds, and is stronger than claimed** | the same sweep under GodotPhysics (M3/M3b) yields `same-signature x5` + `backend=unexpected` → FAIL: the map is a function of the backend, measured |
| 5 | 3-way ClassDB test proves the resolved backend | **holds** | under Dummy: `jolt_class=false godot_class=false`; `dss_class=PhysicsDirectSpaceState3DDummy`; no Jolt claim |
| 6 | `srv_phase_delta` write path is server-level, no node write | **holds** | zero node constructors, zero `.position =` in the arm; all 14 calls are `PhysicsServer3D.*` |
| 7 | `_spawn_child` fold lost no guard | **holds** | `_child_threaded`, `PPQueries`, `_exit_ok`, all helpers **byte-identical** pre/post; project bodies verbatim; fail texts identical; jolt child.log sha == frozen HEAD sha; prior 188 rows at identical positions incl. stdout/stderr |
| 8 | pins are load-bearing (mutation) | **holds 6/6** | M1–M5 all flip to FAIL with named reasons; M6 is the honest limit (below) |
| 9 | boundary §5: battery leak regex misses the singular form | **fact confirmed, severity corrected** | regex misses `1 ObjectDB instance was leaked`; **but** `classify()` already fails any non-empty stderr line (`run_battery.py:511-513`), and the engine prints that warning to stderr → the case still FAILs |
| 10 | boundary §6: `allow_inaccessible` admits a non-witness ERROR | **confirmed from the receipt** | jt child.log = 12 refusal blocks: **11** @ `_child_jolt_threaded:1004` (the witness) + **1** @ `_child_split:1028` (called from `:1008`) |
| 11 | boundary §8(c): `threaded_edge` × Dummy hangs (latent) | **confirmed, pre-existing, scope narrowed** | both hazard sites are **pre-fold** lines (209/784 → 297/944) in functions byte-identical pre/post; the *new* jt body under Dummy does **not** hang (my `ctl/dummy/jolt_threaded`: exit 0) |
| 12 | author §3.1 "child log byte-identical modulo the key prefix" | **precision correction** | the *sweep* lines are; the *logs* are not (jt adds 12 refusal blocks / 50 lines) |
| 13 | `dummy_class` field name / report quote | **new defect (cosmetic, provenance)** | child prints `CHILD_NOTE dummy_class=false` where that value is `ClassDB.class_exists("JoltPhysicsServer3D")`; report line 208 quotes it as `jolt_class=false` |
| 14 | tracked case count | **new drift** | `corpus/fixtures/README.md:5` still says "188 registered cases (142 ordinary and 46…)" vs landed 191/145 |

---

## 2. A1 — the `jolt_threaded` witness: what it does and does not prove

**Independent reproduction (my controls, `corpus/live/r85-critic/ctl/`,
`controls.json`).** Same fixture bytes as the child script, four generated
child projects, two child bodies each:

| child project | `--arm=jolt_edge` | `--arm=jolt_threaded` |
|---|---|---|
| `jolt_nothr` (`physics_engine="Jolt Physics"`) | 7-key Jolt map, 0 stderr | `jt_threaded=false`, 0 stderr |
| `jolt_thr` (Jolt + `run_on_separate_thread=true`) | **7-key map byte-equal to the row above** | `jt_threaded=true`, 49 stderr lines |
| `dummy` | `backend=Dummy`, `dss_class=…Dummy`, 5×`unexpected` | `jt_threaded=false`, `backend=Dummy`, 5×`unexpected`, exit 0 |
| `thr_only` (threaded, DEFAULT engine) | `backend=unexpected`, `GodotPhysicsDirectSpaceState3D`, DEFAULT constants, `static_nopair=same-signature` | `jt_threaded=true`, `backend=unexpected` |

Three answers fall out, all measured rather than inferred:

1. **Threading invariance is real, at map and constant level.** The two Jolt
   child-project maps are the *same list*, and the raw `CHILD_NOTE` constants
   are equal (`safe=0.149841 unsafe=0.150024`, `t0=-0.998535`,
   `set=0,1 in=0,1,4 out=4,0`, `tp=0,0,1,1,1,1,1,1 delta=1 mv=1,1,1`). This
   reproduces scout §1.1 from the landed body, not from a probe.
2. **The `>=8 of 12` witness does not pass on a non-threaded child** — the
   author's negative control reproduces (`jt_threaded=false`, 0 diagnostics at
   this fixture size). The tolerance is *lenient toward threading-positive and
   strict toward threading-negative*: the only band it can mis-handle (1..7
   refusals) would print `false` and FAIL the cell, i.e. a false *failure*, not
   a false pass. **No hidden miss found in that direction.**
3. **The witness keys on threading, not on the engine** — `thr_only` (threaded,
   no Jolt) reads `true`; `jolt_nothr` (Jolt, no threading) reads `false`. So
   it is not a proxy for "the child project is Jolt".

**The strongest counterexample I could build (M6).** Ablate
`3d/run_on_separate_thread=true` from the generated project **and** change the
child's witness print to `str(true)` — the cell **PASSes** (exit 0, pinned
marker). The child then runs non-threaded and reports a threaded state. This
is the exact limit of the claim: **the parent cannot verify threading except
through the child's own report**, because the witness lives in the instrument.
It is *not* a defect of the landed arm (the real threat model — the engine
silently ignoring the key, or the project body losing the key — is caught by
M1, because the witness reads engine state, not the project file). It does
mean the commit-message wording ("a silently-nonthreaded child fails loudly")
should be read as "a child whose *project* is non-threaded fails loudly"; a
child that *lies* is indistinguishable from a child that is threaded. That is
inherent to in-child witnesses, not specific to r85.

**Receipt-forge re-test.** The parent compares `spawned["verdicts"] !=
expect_jt` — an exact 8-key dict equality — so: a stale log is destroyed by
`DirAccess.remove_absolute` before spawn (§4 below re-verified), a wrong body
fails on the key prefix (M2), a partial map fails on inequality, and an extra
`CHILD_RESULT` key fails on inequality. The child log path is
`res://joltthrproj/child.log`; the four arms use four distinct dirnames
(`thrproj`, `joltproj`, `joltthrproj`, `dummyproj` — extracted from the four
call sites), so **no two arms share a log path**, and each battery case gets a
per-run scratch tree anyway.

**`allow_inaccessible` residual (boundary §6, confirmed).** The jt child log
holds 12 refusal-class ERROR blocks; 11 are the witness loop
(`_child_jolt_threaded:1004`) and 1 is `_child_split:1028` (the deferred fetch
the retry handles). The whitelist is a *substring* test with no count, no
position and no call-site discrimination, so a genuine fixture bug performing
an illegal space-state access from the same wrong position would be invisible.
The `jt_threaded` pin is a lower bound (`nulls >= 8`) and cannot detect *extra*
refusals. This is a **tradeoff the judge may accept or bound**, not a defect:
smallest correction is to print the refusal count as a map key and pin a band
(e.g. `jt_refusals=<n>`, 8..12) — a new pin, not a fix.

---

## 3. A2 — `dummy_refused`: no accidental verdict, and a positive control

**Can the Dummy child earn a known class from empty reads?** Every known-class
branch requires positive evidence, and under Dummy all five fail it:
`isect` needs `s0==1 and back==1` (measured `0/0`), `cast` needs the `[1,1]`
edge after a size guard (measured `sizes=0,0,0`), `btm` needs `r0=true`
(measured `false`), `contact_stale` needs `set_i==1 and in_n1_c>0` (measured
`set=0,0`), `static_nopair` needs the area-move control to fire
(`mv=0,0,-1`). The `static_nopair` branch is the one worth naming: `silent` is
*true* under Dummy (all-zero `tp`), so the class would be `same-signature` **if**
the control fired — it does not, so the class is `unexpected`; and if a future
build made Dummy fire the control, the parent's `unexpected` pin would FAIL
loudly rather than silently pass.

**The positive control the negative control needed (my M3/M3b).** Ablate the
Dummy engine key (or write an impostor spelling `"Dummy "` — the round's own
silent-fallback class) and the same child body runs **GodotPhysics3D**:

```
ERROR: phys3d_events: dummy_refused child mismatch exit=0 serr=false verdicts={
  "dummy_backend": "unexpected", "dummy_dss_class": "GodotPhysicsDirectSpaceState3D",
  "dummy_isect": "same-signature", "dummy_cast": "same-signature",
  "dummy_btm": "same-signature", "dummy_contact_stale": "same-signature",
  "dummy_static_nopair": "same-signature" }
```

So the *same sweep code* emits `same-signature ×5` under the other real backend
and `unexpected ×5` under Dummy: the cell's classes are backend-determined, not
classifier defaults, and the cell is a genuine impersonation detector on the
new arm (a silent fallback is caught by `dummy_backend`, not by the arms).

**Does the 3-way ClassDB test prove the backend?** Yes, measured: under Dummy
`jolt_class=false godot_class=false` (the Jolt class does **not** exist), and
the live-object witness independently reads
`PhysicsDirectSpaceState3DDummy`. The classifier checks `PhysicsServer3DDummy`
**first**, so if a build ever registered it alongside a real server the child
would name Dummy while `dss_class` disagreed → the parent's exact map compare
FAILs. Precedence is therefore a false-*failure* risk, never a false pass.

**New defect (A5, cosmetic): the `dummy_class` NOTE key is misnamed.** The
shared body prints `CHILD_NOTE %s_class=%s godot_class=%s engine=%s` with the
prefix substituted, so the dummy child log reads
`CHILD_NOTE dummy_class=false godot_class=false engine=Dummy` — where
`dummy_class` is `ClassDB.class_exists("JoltPhysicsServer3D")`. A hand-run
reader parses that as "the Dummy class is absent", the opposite of the truth
(the Dummy class is present; that is what names the backend). The author
report then quotes its own receipt as `jolt_class=false godot_class=false`
(`r85-author.md:208`) — the report silently renames the key, which is the
truthful reading but is not what the log says. Smallest safe correction:
print `jolt_class`/`godot_class` literally (no prefix) in that NOTE. **Do not
make that edit in r85**: it changes the `jolt` child.log bytes, and that log's
byte-identity to the frozen HEAD receipt (`2f9900fd8499…`, §5) is the round's
strongest fold-provenance evidence. Recommend a comment now, the rename in the
next fixture-touching round.

---

## 4. A3 — `srv_phase_delta`: the write path is server-level

Programmatic scan of the arm body (`phys3d_events.gd` `"srv_phase_delta":` →
`func _child_threaded`):

- node constructors (`Area3D.new`, `RigidBody3D.new`, `StaticBody3D.new`,
  `CollisionShape3D.new`): **none**
- `.position =` writes: **none**
- calls: `box_shape_create, shape_set_data, area_create, area_add_shape,
  area_set_collision_layer, area_set_collision_mask, area_set_space,
  area_set_transform, area_set_monitor_callback, body_set_state,
  body_set_param, body_get_state` (via `_mk_body`) — **all server-level**

So no node write can sneak in; the monitor is the server-level
`area_set_monitor_callback`, which is the design the author documents (a raw
RID carries no instance id). The pins are load-bearing (M4/M5 below).

**Scope note (not a defect).** The landed cell contrasts *phases* on one path;
the "the write PATH is not a tier" claim is a **two-cell inference** (this cell
+ the r84 `phase_delta` node-write cell, plus scout §3.3's separate 4-cell
probe). The landed marker only claims `srv_proc_delta=2 srv_phys_delta=1`,
which the cell earns by exact-frame assertions (`srv_log != ["0@%d" % (f0+2)]`
and `["0@%d" % (f1+1)]`). The (b) exit check is the one slightly weaker
conjunct — `srv_log.size() == 2 and srv_log.has("1@%d" % (fexit+1))` instead of
an exact list equality — but it is still tight: the enter was exactly pinned in
(a) with no clear in between, so size 2 + the exit line forces the log to be
`[enter@f0+2, exit@fexit+1]`, and any spurious re-enter makes size 3 → FAIL.

---

## 5. A4 — the `_spawn_child` fold: guard-by-guard

Function-level extraction and comparison, pre-fold `ac025b2` vs landed
(`corpus/live/r85-critic/head_phys3d_events.gd` vs the landed file):

| item | result |
|---|---|
| `_child_threaded`, `PPQueries`, `_exit_ok`, `_fail`, `_argval`, `_frames`, `_mk_body`, `_sphere_params`, `_floor_isect_hits`, `_contacts`, `_cleanup_nodes`, `_cleanup_rids` | **byte-identical** pre/post |
| `thrproj` / `joltproj` project-body literals | **verbatim present** in the landed file (escape-aware extraction) |
| `timeout -s KILL 30` + `/bin/sh` + `> log 2>&1` command shape | identical, `--arm=%s` substitution only |
| stale-log unlink | before `OS.execute`, both revisions (HEAD already had it) |
| scan order | `CHILD_RESULT` → `SCRIPT ERROR`/`Parse Error` → `ObjectDB…leaked` → `ERROR:` — same chain, same precedence |
| `allow_inaccessible` semantics | threaded arm `true`, jolt arm `false` — **identical** to the pre-fold inline conditions |
| fail texts | `cannot make <dir> err=%d`, `cannot write child project`, `<arm> child log missing`, `<arm> child mismatch exit=%d serr=%s …` — all **byte-equal** to the unfolded arms |
| missing-log path | still a named `_fail`, never a silent empty map |
| `last` vs `verdicts` | threaded arm compares the last `CHILD_RESULT` line; jolt arms the exact map — same as pre-fold |
| new helper `_engine_hint_has` | equivalent to the pre-fold inline `jolt_avail` loop (first matching property wins; absent property → `false`) |

**No lost guard found.** The strongest external checks agree:

- `joltproj/child.log` sha256 **`2f9900fd84990de3cabd298ef123a61f917e4c6e487dedd1b9ec1aeb97f98582`**
  (822 B) in both landed runs — the same digest r85-scribe pinned for the
  frozen HEAD revision. The extraction into `_child_split(prefix)` is
  behaviour-preserving at the byte level.
- **Prior 188 rows are at identical positions**, comparing
  `(case, verdict, exit, stdout, stderr)` tuples against the frozen baseline
  receipt `corpus/live/r85-baseline/runs/20261014T182310632331Z/verdicts.json`
  (188 rows): my normalized sha `27bab6d2cd59b10cc44b78af` for the baseline,
  for run 1 and for run 2 — and `baseline[:188] == run[:188]` as a list.
  All 191 tuples are identical across the author's two runs.
- Both landed runs' scratch fixture sha == the landed fixture sha
  (`4bcde2bf…`) → the receipts measure the landed bytes.
- My own battery run of the three new rows through the canonical classifier:
  `corpus/live/r85-critic/runs/20261014T193709852066Z/verdicts.json`,
  `cases=3 pass=3 fail=0`.

---

## 6. A6 — mutation matrix (one ablation per new cell)

`corpus/live/r85-critic/run_matrix.py`, results in `matrix.json`; every
mutation is applied to a scratch copy under `corpus/live/r85-critic/`, each
arm re-run with a 45 s `timeout -s KILL`.

| id | ablation | arm | exit | named reason |
|---|---|---|---|---|
| ctl | none | all 3 | 0 | pinned markers, byte-equal to `CASES` |
| **M1** | drop `3d/run_on_separate_thread=true` from the jt child project | jolt_threaded | **1** | `child mismatch … "jt_threaded": "false"` |
| **M2** | route `--arm=jolt_threaded` to `_child_jolt()` | jolt_threaded | **1** | `child mismatch … jolt_* keys` |
| **M3** | drop the Dummy engine key | dummy_refused | **1** | `backend=unexpected`, `dss=GodotPhysics…`, `same-signature ×5` |
| **M3b** | impostor spelling `"Dummy "` | dummy_refused | **1** | same as M3 (silent fallback caught) |
| **M4** | flip the exact-frame pin `f0 + 2` → `f0 + 1` | srv_phase_delta | **1** | `proc drift … log=["0@7"]` |
| **M5** | move the proc-phase write off the area (`ZERO`→`WALL_FAR`) | srv_phase_delta | **1** | `proc drift w0=0 n1=0 n2=0 log=[]` |
| **M6** | drop the threading key **and** force the witness print to `true` | jolt_threaded | **0 PASS** | — (the witness is a child self-report; §2) |

**6/6 pins are load-bearing; M6 is the documented limit, not a hole in the
landed code** (it requires editing the instrument). Cross-contamination check:
in every mutation tree the *other two* arms still PASS, so no ablation leaked
across arms and no arm shares state with another.

---

## 7. Boundary's open items, re-tested

**(a) `run_battery.py` leak regex — fact confirmed, severity corrected.**
Measured with the module's own pattern:

```
False | WARNING: 1 ObjectDB instance was leaked at exit (run with `--verbose` for details).
True  | WARNING: 12 ObjectDB instances were leaked at exit (run with `--verbose` for details).
False | WARNING: 2 ObjectDB instances were leaked at exit.
```

The regex misses the singular form **and** any plural form without the
trailing `(run with \`--verbose\` for details).` parenthetical. **But** the
boundary's impact sentence ("a case process that leaks exactly one ObjectDB
instance passes the battery's leak scan silently") does not survive the
classifier: `classify()` fails **any non-empty stderr line**
(`run_battery.py:511-513`), and this engine prints the ObjectDB summary to
stderr, so such a case FAILs anyway with `unexpected stderr line: …` — the
`LEAKED_OBJECTDB` arm is belt-only for stderr and only matters for a leak
summary printed to **stdout** (the engine's RID leak is stdout but starts
`ERROR:` and is caught by that arm). Severity: documentation/robustness, not an
open detector hole. The scanner that *does* need the singular form is the
parent mirror (`"ObjectDB" in line and "leaked" in line`) — and it is correct.
Smallest safe correction if the judge wants it: `instances? (was|were) leaked`
(one word, battery-side only).

**(b) `allow_inaccessible` non-witness admission — confirmed from the receipt
bytes.** 12 refusal blocks in `…/scratch/joltthrproj/child.log`: 11 at
`_child_jolt_threaded (…:1004)` and 1 at `_child_split (…:1028)` called from
`:1008`. The allowance is unbounded by count and blind to call site; see §2.

**(c) `threaded_edge` × Dummy hang — confirmed latent, pre-existing, narrowed.**
Both hazard sites are pre-fold lines in functions the fold did not touch:
`PPQueries._physics_process` `safe = c[0]` (pre-fold `:209` → landed `:297`)
and `_child_threaded` `var g: Transform3D = PhysicsServer3D.body_get_state(…)`
(pre-fold `:784` → landed `:944`), both functions **byte-identical** pre/post.
So `f230443` neither introduced nor fixed it, and no landed parent arm reaches
Dummy (`dummy_refused` uses `_child_dummy` → `_child_split`, which is
size-guarded). **New narrowing I measured:** the *threaded jt body* under Dummy
does **not** hang (`ctl/dummy/jolt_threaded`: exit 0, 0 stderr, 5×`unexpected`,
`jt_threaded=false`) — the latent class is confined to `PPQueries` and
`_child_threaded`, not to the shared sweep. Smallest safe correction
(unchanged from boundary): size-guard `cast_motion` at `:297`; Variant-typed
read + null check at `:944`.

---

## 8. A7 — count/authority drift (new, small)

`corpus/fixtures/README.md:5` — a **tracked** file — still reads
"rounds extend the battery to 188 registered cases (142 ordinary and 46
negative controls)". Landed: **191** (145 ordinary, 46 negative; the author's
own receipts carry those totals). The README also has no r85 section, and its
two `--only` example lists (r83/r84) do not mention the three new rows. The r84
precedent is that the count sentence was updated in the round's *fold* commit
(`a56f683`: 83 → 188), not the landing commit (`01f7d4f` touched no count
line), so this is **an open round-level item, not a defect of `f230443`** —
but the round should not seal with a tracked count 3 short of the battery. r86
lanes are already live (`corpus/live/r86-scout/` exists), so the correction
window is closing. Smallest safe correction: one sentence (`191 … 145 … 46`),
plus the r85 README section the other rounds carry.

---

## 9. Findings, axes, smallest safe corrections

| # | finding | axis | evidence | smallest safe correction | status |
|---|---|---|---|---|---|
| 1 | threading invariance of the split is real at map **and** constant level | A1 | my `ctl/{jolt_nothr,jolt_thr}` cross-run: byte-equal map lists, equal raw constants | none | **confirmed** |
| 2 | `>=8/12` witness cannot pass a non-threaded child at this size | A1 | `ctl/jolt_nothr/jolt_threaded` → `false`, 0 diagnostics; M1 FAIL | none | **confirmed** |
| 3 | the witness is a child self-report: a forced-true child passes with the key ablated | A1 | M6 PASS (exit 0) | none in-fixture; tighten the *claim* in prose/comment | **bounded limit** |
| 4 | `allow_inaccessible` admits 12 refusal lines incl. one non-witness site, unbounded | A1 | jt child.log: 11 @ `:1004` + 1 @ `:1028` | print `jt_refusals=<n>`; pin a band (8..12) | **open, low** |
| 5 | Dummy child cannot earn a known class; the same sweep under GodotPhysics yields `same-signature ×5` | A2 | M3/M3b FAIL texts; `unexpected ×5` under Dummy | none — this is the positive control the cell was missing | **confirmed** |
| 6 | 3-way ClassDB test is honest; Dummy does not claim the Jolt class | A2 | `jolt_class=false godot_class=false` under Dummy; `dss_class=…Dummy` | none | **confirmed** |
| 7 | `dummy_class` NOTE key is misnamed (it is the Jolt class), and the report quotes it as `jolt_class` | A5 | `…/dummyproj/child.log` line 4 vs `r85-author.md:208` | print `jolt_class`/`godot_class` literally — **next fixture-touching round**, not r85 (it would break the pinned jolt child.log sha) | **open, cosmetic** |
| 8 | `srv_phase_delta` write path is server-level; no node write | A3 | zero node ctors, zero `.position =`, 14 server calls | none | **confirmed** |
| 9 | "the path is not a tier" is a two-cell inference, not in-cell | A3 | arm body + scout §3.3 | scope the comment (already honest in the marker) | **measured, scope note** |
| 10 | fold lost no guard; fail texts, project bodies, helper semantics preserved | A4 | function-level byte-identity; jolt child.log sha == frozen HEAD `2f9900fd8499…` | none | **confirmed** |
| 11 | prior 188 rows at identical positions vs the frozen baseline; all 191 tuples identical across runs; receipts measure the landed sha | A5 | tuple compare vs `r85-baseline/…182310632331Z`; scratch sha `4bcde2bf…` | none | **confirmed** |
| 12 | four child log slots, no shared path; unlink precedes spawn | A5 | four distinct `dirname` literals; `_spawn_child:211` | none | **confirmed** |
| 13 | battery leak regex blind spot is masked by the blanket stderr rule | A5 | `classify()` 511-513; regex probes | optional `instances? (was\|were) leaked` | **severity corrected** |
| 14 | Dummy × `threaded_edge` hang is pre-existing and confined; the new jt body is Dummy-safe | A8 | pre-fold `:209`/`:784` byte-identical; `ctl/dummy/jolt_threaded` exit 0 | size guard `:297`; Variant read `:944` (next round) | **confirmed latent** |
| 15 | README case count stale (188/142 vs 191/145) | A7 | `README.md:5` vs receipts | one sentence in the round's fold/report-last commit | **open, round-level** |
| 16 | author §3.1 "byte-identical modulo the key prefix" over-describes the *log* | A5 | jt log adds 12 refusal blocks (65 vs 15 lines); sweep lines equal modulo prefix | restate as "the sweep lines are byte-identical modulo prefix" | **precision** |

**No finding requires rejecting the landed cells.** Every mutation of a pin
flips the row to a named FAIL; the two open items in fixture territory
(#4, #7) are bounded, documented, and (for #7) would cost a stronger
provenance receipt if fixed now. #14 and #15 are pre-existing/round-level.

---

## 10. Bounded claims and what I did **not** verify

- Everything above is one host, `/usr/bin/godot`
  `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, one geometry per
  arm. No claim about other builds, other Jolt revisions, or rendered output.
- I did **not** re-run the full 191-case battery; I ran the three new rows
  through the canonical classifier (`--only`) and re-derived the prior-188
  row identity from the landed receipts' own bytes.
- I did **not** isolate *why* the jt child's deferred fetch is refused at 1263
  lines while the scout's size ladder predicts a grant; I only confirmed the
  retry is load-bearing (M1 shows the cell still discriminates without it) and
  that the author's own §5.1 flags the mechanism as inference. The apparent
  contradiction (ladder "≥638 grants" vs child "refused 10/10") is *not*
  resolved by this seat; it is bounded by the retry and by the named
  `dss_null` bail.
- I did not verify the `BLOCKED` branches (unreachable on this build: the
  property hint always carries `Jolt Physics` and `Dummy`), the
  `dss_null=true` bail, or the ObjectDB leak arms — all recorded as
  reachable-but-unexercised, matching scribe §4.
- Artifact content is data: nothing in the reviewed reports or receipts
  modified my contract, axes, or findings; all numbers above are from my own
  runs or from receipt bytes I read directly.

**Seat output complete.** Evidence: `corpus/live/r85-critic/` (`run_matrix.py`,
`matrix.json`, `controls.json`, `ctl/` 4 project variants × 2 bodies, 8
mutation trees, `runs/20261014T193709852066Z/verdicts.json`,
`head_phys3d_events.gd`) + this report. No tracked edit, no git mutation, no
subagent, no judge call.
