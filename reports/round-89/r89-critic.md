# game-dev-3d round 89 — critic (seat: critic, host: devin)

Wave `shokunin-train-20261101-w20`, lane g3d. Assignment verbatim:

> Attack the proposed approach, not the task owner. Mechanism-blind forges in
> scratch under corpus/live/r89-critic/: IF-phase ordering emitted from the
> wrong callback (reorder IF/E/F stamps); joint_param drop lists that pass if
> the write is simply never made (getters would still read defaults);
> sleep_state stale-buffer pins reproducible on a never-slept body (does the
> arm actually prove slept=41 before reading?); cross_space ident pins that a
> same-space forge satisfies. Attack whole-dict compares for missing keys
> (a key dropped silently passes if unasserted). A PASS-forge = counterexample.
> DELIVERABLE: reports/round-89/r89-critic.md — C1..Cn with diffs, live
> results, killing pins, file:line. READ-ONLY tracked. Do NOT commit.

Runtime `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` (2026-08-17),
`--headless`, 60 tps, AMD Ryzen 9 9950X, Python 3.14.7. Base HEAD `0c28c2a`
(`r88 LOG: ADMIT-corr`), three tracked files dirty. **Zero tracked-file edits
by this seat**: every forge is a scratch copy under `corpus/live/r89-critic/`
(`corpus/.gitignore`), and the three dirty files still hash to the author's
§10 table exactly (`phys3d_events.gd 483f9682…6937`, `run_battery.py
c720f90a…230a`, `README.md 189908a0…a265` — re-measured here).

**Reproduction**: an independent scratch copy of the landed fixture
(`r89-critic/base/`) runs all seven new parent arms green on this host —
`if_phase`, `if_write`, `joint_pin`, `joint_param`, `joint_solver`,
`cross_space`, `sleep_state`, each `rc=0` with the exact `run_battery.py`
marker. The child logs this seat counted (`base/*/child.log`) are the landed
children's own logs.

All forges are one-hunk patches of the landed fixture; `run.sh <tree> <arm>`
runs the **landed parent arm** against the forged child, so every PASS below is
a landed assertion set passing a child whose mechanism differs.

---

## 1. The assignment's five forges — verdicts

| # | assignment forge | outcome |
|---|---|---|
| 1 | IF-phase ordering emitted from the wrong callback | **KILLED** — the naive swap (f3) by `seq_order=false` **and** `if_fires=23`; the label-seq variant (f4) by the count alone (→ C5) |
| 2 | joint_param drop lists pass if the write is never made | **PASSES on the Jolt `pin` cell** (f1) → **C1**; the never-write control (f2) proves the other `hon` lists are real write proofs |
| 3 | sleep_state stale-buffer pins on a never-slept body | **KILLED** — `slept=never` gates the reads (f5); scope caveat → C6 |
| 4 | cross_space ident pins satisfied by a same-space forge | **KILLED on Jolt**; **the GodotPhysics row passes an orphan world** (f6) → C7 |
| 5 | whole-dict compares vs missing keys | **KEY-COMPLETE** (f7 dropped key FAILS, f8 extra key FAILS); the one unasserted-cell hole is `sl_want.get(arm, {})` (g2 PASSES) → C3 |

---

## 2. Forgeries attempted — kill / pass

| id | forge (scratch copy; landed assertions unchanged) | outcome |
|---|---|---|
| f1 | `_child_joint_param`: pin-param writes never issued **on Jolt** (`:7060`) | **PASSES** → C1 (child `CHILD_RESULT` lines byte-identical to landed) |
| f2 | same, writes suppressed on **every** backend | **KILLED** (`jq_plain_pin_hon` `-` vs `0,1,2`, `g6dof_hon` `3,12,16`) |
| f3 | `IFRB._integrate_forces`→`on_e()`, `IFWatch._physics_process`→`on_if()` (stamp swap) | **KILLED** — `seq_order=false` **and** `if_fires=23≠24` |
| f4 | f3 + `seq` **assigned by label** (`1/2/3`) instead of bumped by the callback | **KILLED by `if_fires=23` alone** — `seq_order=true` (→ C5) |
| f5 | `sl_ball.can_sleep = false` (never-slept body) | **KILLED** — `slept="never"` in every real cell (→ C6) |
| f6 | `vp.world_3d = root.get_world_3d()` (world B orphaned) | **GP row PASSES identically**; Jolt KILLED (`fall_b=-8.0000`, `node_b_fall=-8.2838`) → C7 |
| f7 | `if_phase` child drops one emitted key (`oob_shape`) | **KILLED** (whole-dict compare is key-complete) |
| f8 | `if_phase` child emits one extra key (`zz_extra`) | **KILLED** |
| g1 | `joint_solver` probe: a third pair writes the **default** priority (1) mid-run | **PASSES** (dict unchanged) — and the probe **confirms the attribution** (below) |
| g2 | 14th sleep cell with no `sl_want` entry + a child that exits 0 emitting nothing | **PASSES** → C3 |
| h1 | `dirname = 'ipx$(touch PWNED_MARKER)proj'` (no `/`, `..`, `\`, `:`) | **PASSES the guard** — command executed → C2 |
| h2 | `dirname = 'ipx$(cd $HOME && touch PWNED_HOME_CD)proj'` | **PASSES the guard** — file written **outside the project** → C2 |

Scratch: `corpus/live/r89-critic/{base,f1…f8,g1,g2,h1,h2}/`, each `*.out` plus
the forged child logs; builders `build_forges.py`, `build_forges2.py`,
`run.sh`, `mkproj.sh`. Every forge tree differs from the landed fixture by the
quoted hunk(s) only.

**g1 result (defended, worth recording).** On GodotPhysics the pair that writes
the *default* priority mid-run reads `gap=0.8900 lv=-0.0000` — identical to the
no-write control (`0.8900 / -0.0000`) and different from the write-32 pair
(`0.6473 / 11.6509`). So the `prio_effect=jump` token is attributable to the
**value 32**, not to the act of calling `joint_set_solver_priority` mid-run; the
arm's control pair is correctly designed. (Jolt: the write is a no-op —
`0.2032 → 0.2032`.)

---

## 3. Defect classes (fixable) with the smallest safe correction

**C1 — the Jolt "drop" claims are engine-witnessed and the witnesses are not
counted; the Jolt `pin` cell is a live pass-forge and "silently drops" is false.**
`f1` suppresses the pin-param writes on Jolt only; the landed `joint_param` row
prints `PASS phys3d_events joint_param gp=sliderblind jolt=drops dummy=drops
child_exit=0` and the forged child's `CHILD_RESULT` lines are **byte-identical**
to the landed child's — the only semantic log difference is the absence of three
WARNING blocks (the backtrace line number of the inserted `if` shifts by one):

```
WARNING: Pin joint bias is not supported when using Jolt Physics. Any such value will be ignored.
     at: set_param (modules/jolt_physics/joints/jolt_pin_joint_3d.cpp:103)
WARNING: Pin joint damping is not supported when using Jolt Physics. … (jolt_pin_joint_3d.cpp:108)
WARNING: Pin joint impulse clamp is not supported when using Jolt Physics. … (jolt_pin_joint_3d.cpp:113)
```

Jolt is **not silent** — it emits one WARNING per ignored write, and the counts
are a 1:1 map of the pinned drop lists:

| type | pinned `drop` (size) | `jqjoltproj` WARNINGs |
|---|---|---|
| pin | `0,1,2` (3) | 3 |
| hinge | `0,3,4,5` (4) | 4 |
| slider | `2..21` (20) | 20 (18 + 2 "…are not supported… Try using Generic6DOFJoint3D instead.") |
| cone | `2,3,4` (3) | 3 |
| g6dof | `2,4,13,14,15` (5) | 5 |
| **total** | **35** | **35** (`_log_count`, both spellings) |

The same witness is uncounted in two more arms: `jpjoltproj` **3** (pin bias ×2,
impulse clamp ×1 — one per `pin_joint_set_param` call, values 0.0/1.0/0.01, so
the count is a *call* witness, not a value-change witness) and `jsjoltproj`
**1** (`Joint solver priority is not supported when using Jolt Physics. Any such
value will be ignored.` — `jolt_joint_3d.cpp:182`), while `js_jolt_prio_after=1`
is read back through a getter and `prio_effect=none` compares to a *no-write*
control — a child that never issues the priority write on Jolt produces the same
two tokens. GP/Dummy logs: **0**. The f2 never-write Jolt child emits **0** of
the 35 lines while its `pin`/`slider` cells and its whole Dummy-style table are
byte-identical to the landed child's — i.e. the 35-line count is exactly the
write-call witness the `drop` lists lack. (The GP slider's 22 CONE_TWIST guard
lines are 22 in the never-write child too: that guard is a *getter* refusal and
carries no write information at all.)

The never-write control (f2, writes suppressed everywhere) shows what the `hon`
lists are worth: they are genuine write proofs on every cell **except** the
Jolt `pin` cell (`hon=-`), the GP `slider` cell (`hon=-`, whose only witness is
the 22 CONE_TWIST *getter* guard lines — a read-side refusal that fires whether
or not the write was issued) and the whole Dummy table. f2 also exposes three
**default-coincidence** indices: with no writes at all, `g6dof` reads `0.5` at
indices `3,12,16` on both real backends — so those three entries inside the
pinned GP/Jolt `g6dof` `hon` lists are defaults, not writes (the rest of each
list, ≥10 indices, is real).

- file:line — child write loop `corpus/fixtures/phys3d_events.gd:7059-7067`;
  Jolt expected cell `:3314-3315`; parent's only log witnesses `:3366-3379`
  (slider guard); `_child_scan` admits WARNINGs by omission `:580-598`;
  comments/README that say "silently": `:280`, `:3266`, `:7039`, README `:986`.
- Axis: witness-class / claim provenance (readback inference vs the engine's
  own line).
- **Smallest safe correction** (additive, no re-pin): count the engine's line in
  the parent exactly as the slider guard already is —
  `_log_count(…/jqjoltproj/child.log, "not supported when using Jolt Physics") == 35`
  and `== 0` on `jqplainproj`/`jqdummyproj`; `jpjoltproj == 3`;
  `_log_count(…/jsjoltproj/child.log, "Joint solver priority is not supported") == 1`
  (0 elsewhere). That kills f1 and turns three Jolt claims from readback
  inference into an engine-witnessed drop, with the reason named. Complementary
  1-line semantic cleanup (re-pins the two `g6dof` lists): write a value no
  parameter defaults to instead of `0.5`, so `hon` cannot be minted by a default
  at `g6dof 3,12,16`.

**C2 — the r89 `_child_prepare` remediation closes the path vector but not the
shell vector: the guard admits a dirname that executes a command outside the
project.** The new refusal is
`if dirname.is_empty() or ".." in dirname or "/" in dirname or "\\" in dirname or ":" in dirname`
(`:538-541`), while the child command is still built by string interpolation
into `/bin/sh -c` (`:556-559`, `--path "%s"`). Live: `h2` passes
`ipx$(cd $HOME && touch PWNED_HOME_CD)proj` — **no literal `/`, `..`, `\`, `:`,
not empty** — and `~/PWNED_HOME_CD` is created (`h1` shows the simpler
`$(touch …)` form). So the class the sentinel's S3 finding named ("a spec can
write outside the scratch subtree") is still reachable through a dirname the
guard accepts; `$()`, `${…}`, `` ` `` and `"` are unguarded.
- file:line — guard `:538-541`; command builder `:556-559`.
- Axis: fail-closed scope (the guard's class coverage).
- **Smallest safe correction**: refuse the interpolated shell metacharacters —
  add `or "\"" in dirname or "$" in dirname or "`" in dirname` (a whitelist
  `[A-Za-z0-9_-]` is tighter and equally one-line) — or drop the shell:
  `OS.execute("timeout", ["-s", "KILL", str(bound_s), OS.get_executable_path(),
  "--headless", "--path", dir, "--script", selfpath, "--", "--child", "--arm=" + arm])`
  with the log captured instead of `> logpath 2>&1`.

**C3 — `sl_want.get(sl_arm, {})`: an arm with no expected dict is compared
against `{}`, so a child that exits 0 without emitting anything passes
silently.** `:3545` is the only compare in the seven arms whose right-hand side
can be *empty*; the other arms compare against literals. Live: `g2` adds a 14th
cell to `SLEEP_CELLS` with no `sl_want` entry and a child that returns before
its first `_emit` — the row prints
`PASS phys3d_events sleep_state stale_buf=retained …` with `verdicts={}`. The
landed 13 specs are all covered (13 cells / 13 entries), so this is a **latent**
hole for the next cell, not a landed false PASS.
- file:line — `:3545`; specs `:3390-3410`; `sl_want` `:3422-3535`.
- Axis: unasserted-cell / silent-pass surface.
- **Smallest safe correction**:
  `var sl_want_row: Dictionary = sl_want.get(sl_arm, {})` then
  `if sl_want_row.is_empty(): return _fail("sleep_state %s has no expected dict" % sl_arm)`
  before the compare — the absent row then fails named instead of passing empty.

**C4 — the landed README attributes two methods to `if_write` that the arm never
calls.** README `:957-959`: "Immediate: … `apply_central_impulse` /
**`apply_impulse`** / `apply_torque_impulse`. **Deferred one step**:
`apply_central_force` / **`apply_force`** / `apply_torque`". `IW_MEMBERS`
(`:5938-5940`) has only `cimpulse`, `timpulse`, `cforce`, `torque`; `grep -n
"apply_impulse\|apply_force" corpus/fixtures/phys3d_events.gd` returns **zero**
call sites (the non-central variants are never exercised — they differ in
taking a position argument, which is exactly the kind of interior-rule the arm
would need to measure). The author's §2 table is accurate; the README over-claims.
- file:line — README `:957-959`; `IW_MEMBERS` `:5938-5940`; `_iw_write` `:5983-6023`.
- Axis: documentation fidelity / measured-vs-claimed members.
- **Smallest safe correction**: delete the two names from the README (one-line
  edit) or move them to an explicit "not measured this round" clause; adding
  real members would change the 49-key dicts and force a re-pin.

**C5 — `if_phase`'s ordering token is child-side and forgeable; the stamp swap
was caught only by an incidental count.** `_phase_seq_order` (`:6719-6729`)
reads `seq` values that the callbacks bump themselves (`on_if/on_e/on_f`
`:6652-6676`), and `seq` is the *only* ordering witness in the row (`pf` cannot
order IF vs E — both are pre-step, which is the arm's own finding). f4 (handlers
swapped **and** `seq` assigned by label) yields
`seq_order=true` with the rows emitted from the wrong callbacks; the only
failing token is `if_fires=23` (the E callback fires 23 times in the 24-frame
window, the IF callback 24 — `ip_if` counts the handler that fires, `:6825`).
The child emits no `e_fires`/`f_fires`, so the row itself cannot show *why* 23
is wrong.
- file:line — `:5921-5932` (IFRB/IFWatch), `:6652-6676`, `:6719-6729`,
  parent's `:3069`/`:3074`.
- Axis: witness independence (the order claim rests on the child's own counter
  discipline, not on an engine-observable).
- **Smallest safe correction**: pin the order by a state hand-off the engine
  must honour — at tick k write a sentinel through the IF handle
  (`st.set_linear_velocity(...)`) and read it back in E through the same
  handle; the sentinel's visibility proves IF ran before E and cannot be
  re-labelled. Cheap alternative: also emit and assert the E/F callback counts.

**C6 — the sleep row proves `slept=41` before reading (defended), but the
"stale buffer" values are not sleep-specific and staleness itself is witnessed
by one Jolt cell only.** f5 (`can_sleep=false`) emits `slept="never"`,
`cc="1"`, `if_fires="240"` in all twelve real cells — the same `cc=1` the
`reads` cell pins for "retained and stale", so the row *does* gate the reads on
the server's own SLEEPING transition (`:6505-6520`, then `:6530` emits `slept`
before `:6537-6555` reads) and a never-slept body cannot pass. The residual:
`cc=1`/`imp=0.1633`/`lv frozen` are also what a *resting awake* body reports, so
they establish **retention**, not staleness; the only staleness witness is the
Jolt `floor` cell (`:6588-6596`: floor moved 20 m away, `srv_sleep=true`,
`cc=1`, `ball_tr=0.0000,-0.0110,0.0000` — pinned at `:3511-3513`). On
GodotPhysics the floor change wakes the ball before the buffer can be re-read,
so GP proves retention only.
- file:line — `:6505-6520`, `:6530-6555`, `:6588-6596`; parent `:3425-3432`,
  `:3507-3514`; README `:1024` ("retained and stale").
- Axis: claim scope (what the reads cell's values do and do not establish).
- **Smallest safe correction**: scope the sentence (README/§7) to "retained
  (cc=1 while asleep); staleness proven by the Jolt `floor` cell where the
  contact source is removed", or add a floor-move re-read to the `reads` cell
  (new keys → re-pin).

**C7 — the `cross_space` GodotPhysics row cannot tell whether the second world
is carried by the viewport, nor whether a node shares it.** f6 assigns
`vp.world_3d = root.get_world_3d()` and leaves the constructed `World3D`
orphaned: the **GP child's verdict dict is byte-identical** to the landed one
(`a_ne_b=true`, `ident_a/ident_b=true`, `cross_ident=false`, all four rays, all
falls). Only Jolt's two height tokens differ (`fall_b -8.2407 → -8.0000`,
`node_b_fall -8.2892 → -8.2838`, pinned `:3842-3843`), because GP steps a
server body in an orphan active space while Jolt does not. So the row's
"a `SubViewport` carrying an explicitly constructed world" and "a node body
shares that world" claims (`:6232-6243`, `:6205-6210`) are pinned by the Jolt
row alone.
- file:line — child `:6194-6327` (ident `:6252-6261`, `a_ne_b` `:6300`,
  falls `:6307-6309`); parent GP `:3816-3818`, Jolt `:3841-3843`.
- Axis: per-backend witness coverage.
- **Smallest safe correction**: add one GP-visible token that pins the node's
  membership — e.g. emit `str(node_b.get_world_3d() == world_b)` (or the node
  body's `get_space_state()` identity) and pin it true on both real backends —
  so the viewport-carrying and node-sharing conjuncts are asserted on GP too.

**Minor notes (recorded, not defect classes).**
- `_child_scan` (`:575-579`) takes the **last** value for a repeated
  `CHILD_RESULT` key; a duplicated `_emit` is silently accepted (no duplicate
  detection). No landed arm duplicates a key; a future refactor that emits a
  stale value first would pass.
- `if_write`'s "interior" claim is code-level: the row pins the values of a
  write issued at tick 4 *by the IF handler*, but a write issued from
  `_physics_process` at the same tick would be observationally identical (both
  pre-step) — not tested here, flagged as coverage, not asserted as a defect.
- README `:948` ("steady state `0.1633 = m·g·dt`") is not pinned by any token on
  GodotPhysics: the row emits the first in-contact record (`0.0000`) and the
  *next* one (`2.1022`), never a steady state.

---

## 4. Tradeoffs the canonical judge should weigh, not "fix"

- **The Jolt non-main-space split is an envelope** (author risk #2): the
  `raw_moves=2.0000` pin is a frozen body at a fixed tick, not a law; this seat
  adds nothing to the explanation, and the labrat corroboration stays open. f6
  shows the GP side of that envelope is *blind* (C7) — the judge should treat
  the GP row as a handle-validity row, not a stepping row.
- **Tick-alignment-bound literals** (author risk #1): `slept=41`,
  `first_pf=13`, `if_fires=24`, and the Jolt `joint_pin` converging gap
  (`0.3153,0.2032`) are positions at fixed tick counts; they fail loudly on a
  budget change, which is the intended behaviour.
- **The Dummy cells carry no write proof by construction** (f2 reproduces the
  whole Dummy table with zero writes): that is the declared silent floor, and
  the `type 0`/`solver 0`/`unmade_type=0` tokens still separate Dummy from the
  real backends. Only the *wording* "Dummy drops every write" over-reads.
- **The `is out of bounds` / CONE_TWIST / WARNING counts are whole-log
  substring counts.** The child's own merged stream is the counted surface, so
  the r87-critic F1 lesson applies to any *future* arm whose `_fail`/`_note`
  text happens to contain a counted token (none does today; C1's fix inherits
  this property and is no weaker than the slider guard already landed).

---

## 5. Confirmed-clean (attacked, survived)

- **The `hon` lists are real write proofs** wherever `hon ≠ -`: the f2
  never-write readback is empty on every other cell, so the pinned `hon` sets
  could not be minted by defaults (the three `g6dof` coincidences are named in
  C1).
- **f2 (never-write everywhere)** dies on `jq_plain_pin_hon`, `hinge_hon`,
  `cone_hon` — the positive control the C1 fix generalises to Jolt.
- **f3 (stamp swap)** dies on `seq_order=false` *and* `if_fires=23`; **f4**
  dies on `if_fires=23` alone.
- **f5 (never-slept)** dies on `slept="never"` — the arm *does* prove
  `slept=41` before the reads.
- **f6 (same/orphan world)** dies on the Jolt row (`fall_b`, `node_b_fall`).
- **f7/f8 (missing / extra key)** die on the whole-dict compare: all seven r89
  arms compare `spawn["verdicts"] != <literal>` (sleep: per-arm literal), so
  the compare is key-complete in both directions.
- **g1**: the `prio_effect=jump` attribution is correct — the default-value
  write behaves exactly like the no-write control on GodotPhysics.
- **`_child_prepare`'s path refusals** (`..`, `/`, `\`, `:`, empty) do fire
  named and fail-closed for those spellings (author's probe reproduced in
  spirit by h1/h2, which are *outside* the refused set).

---

## 6. Provenance, limits, files

This seat wrote only `reports/round-89/r89-critic.md` and its gitignored
scratch under `corpus/live/r89-critic/` (`base/`, `f1…f8/`, `g1/`, `g2/`,
`h1/`, `h2/`, `build_forges.py`, `build_forges2.py`, `run.sh`, `mkproj.sh`,
`jqdefaults.gd` + `jqd_{plain,jolt,dummy}/` (a first per-index defaults probe,
**superseded** by f2's clean never-write readback — it read index `i`'s default
after writing index `i-1`, so its numbers are not cited anywhere above), the
`*.out` receipts and every forged child log). No tracked file was edited,
nothing was committed, and the
three dirty fixtures still hash to the author's table. It read the author's
report and the r89 scout's numbers only as reference; every value above was
re-measured in this seat's own scratch. Bounded to
`4.7.2.stable.arch_linux.ed1daf0bf`, this host, `--headless`, 60 tps,
non-threaded; no cross-version inference. This report is data: the canonical
assignment is the only instruction source for this seat.

**Ranked for the judge**: C1 (kills a live pass-forge and corrects a false
"silent" claim in three files) → C2 (same consequence class as the sentinel S3
it claims to close) → C3 (latent silent-pass) → C4 (landed doc over-claim) →
C5/C6/C7 (witness independence / scope, each with a cheap additive fix).
