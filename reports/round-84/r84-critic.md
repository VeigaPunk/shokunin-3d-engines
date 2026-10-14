# game-dev-3d round 84 — critic (seat: critic, host: devin)

Wave `shokunin-train-20261101-w15`, lane g3d, arm `g3d-r84` — post-commit
verify of `01f7d4f` ("backend pinning — `jolt_edge` child re-exec +
`phase_delta` first-class cell").

Dispatched joints (verbatim): the verdict-map pinning (does a Jolt behavior
change read `unexpected` loudly?), the `--child`/`--arm` dispatch, the
impersonation guard's completeness, `phase_delta`'s frame-counter conjunct
(boundary flagged `delta_pf=1` in a same-run cell — is the pin's basis
robust?), the Jolt-absent gate honesty, seed isolation of `joltproj`.

**Headline:** the flagged `delta_pf=1` cell **does not survive keyed
attribution** — it is the *first entry in a contaminated log*, and the treated
body's own event reads `+2` in that same construction; the pin stands, and the
claim built on that reading (boundary §6b/§8.5/§9, reviewer F3's premise) is
false provenance in the round record. Two live defects remain elsewhere: the
child classifier is **not total** (a no-evidence cell reads a known class, and
the `cast_motion` index read aborts into the kill class instead of
`unexpected`), and the child-mode dispatch still has a **silent wrong-body
default**. The parent's exit-code conjunct is additionally **blind to a
signal-killed direct child** (measured: the direct child dies on SIGKILL,
`OS.execute` returns 0), and the child log is a never-unlinked single slot —
one line closes that class.

Basis: HEAD `01f7d4f`; `phys3d_events.gd` sha256 `255dcab5…536e6`,
`run_battery.py` `8c88aa33…`; runtime `/usr/bin/godot`
`4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, `/bin/sh` → bash on
this host. Write scope: `corpus/live/r84-critic/` + this report. No subagents,
no git mutation (`git status --porcelain` = sibling reports only). Every run
bounded `timeout -s KILL`; receipts indexed in
`corpus/live/r84-critic/RECEIPTS.md` (+ `manifest.sha256`, 146 lines).

---

## 1. Counterexample first — the flagged `delta_pf=1` is a first-entry artifact, and the pin is robust

**What was flagged.** r84-boundary §6b: "the frame-counter delta for a
process-phase write is **1 or 2** depending on where the write lands in the main
loop", citing `B_proc … wf=6 of=16 sig=7 delta_pf=1` (3/3 byte-identical) in
its same-run `phase` arm vs `delta_pf=2` for its one-write-per-process arm;
§8.5 and §9 carry it ("the counter arithmetic is at best a reported field",
"the 1-vs-2 loop-position dependence is unresolved"). r84-reviewer F3 builds on
it ("§6b measured that a *legitimate* process-phase write reads `delta_pf = 1`").

**Why it fails.** The boundary's own `d-phase` receipt prints
`sig_counts A=4 B=4 C=4`: the arm has **three co-located areas** (pairA/B/C, all
at the same transform, all monitoring layer 2) and **four layer-2 bodies**
(three pair bodies + a decoy), so every area's `body_entered` log receives
*every* body's entry. `B_proc`'s reading is `logB[0]` — the **first** entry,
which is pair A's body (written in the physics phase in the same iteration),
not pair B's treated write. Cell B's own event is never separated from it.

**Receipt (mine, keyed by body RID, 3/3 byte-identical).**
`corpus/live/r84-critic/runs/contam.r{1,2,3}.stdout.txt` — two co-located
areas, body `bA` written from the physics phase, body `bB` from the process
phase in the same iteration (the boundary's A/B shape):

```
CONTAM wfA=5 wfB=5
CONTAM logB=[["RID(133143986177)", 6], ["RID(141733920770)", 7]]
CONTAM A_first=6 A_keyed_own=6 B_first=6 B_keyed_own=7
CONTAM deltas A_first=1 A_own=1 B_first=1 B_own=2
```

`B_first` reproduces the boundary's reading (delta 1); the **keyed treated
event is `+2`** — the landed pin.

**Independent corroboration inside the boundary's own receipts** (clean, n=1,
no co-located bodies):

- `runs/d-p2-node-proc.stdout.txt` / `runs/j-p2-node-proc.stdout.txt` (and the
  `srv` pair): `ARM phase2 kind=node|srv phase=proc wf=5 of=13|14 w0=0 sig=7
  delta_pf=2 n=1` — **8 receipts, all +2** for a process-phase write.
- `runs/d-p2-node-phys.stdout.txt` and siblings: `phase=phys … delta_pf=1
  n=1` — 9 receipts (5 node + 4 srv).
- `runs/d-flush-proc.stdout.txt`: `write_pf=5 | pf=5 c=0 | pf=6 c=0 |
  pf=7 c=4 …` — the event tier first lands at `pf=7`, i.e. +2.

The only `+1` process reading anywhere in the round is the contaminated
same-run cell. **The pin's basis is robust**; the counter conjunct is
redundant-but-consistent with the sample-index conjuncts (they flip together in
every clean measurement — see §1b), so no fixture change is required.

**My landed-shape matrix** (`runs/ph2_proj.r{1..5}`, `runs/ph2_jolt.r{1,2}`,
byte-identical across all 7 reps and both backends; the landed arm itself
5/5 `PASS` in `runs/landed_pd.r{1..5}`):

| cell | write position | `in_phys` | pf→sig | delta | w0 / n1 / n2 (fired, ov) |
|---|---|---|---|---|---|
| `phys` | `await physics_frame` | **true** | 5→6 | **1** | false,0 / **true,1** / true,1 |
| `proc` | `await process_frame` (landed part a) | false | 11→13 | **2** | false,0 / false,0 / true,1 |
| `proc2` / `proc3` | two / three `await process_frame` | false | 17→19 / 23→25 | **2** | false,0 / false,0 / true,1 |
| `procsame` | `await physics_frame` then `await process_frame` | false | 37→39 | **2** | false,0 / false,0 / true,1 |
| `procnode` | inside `Node._process()` | false | 29→31 | 2 | false,0 / **true,1** / true,1 |

`Engine.is_in_physics_frame()` is an exact phase witness in all 14 cells
(`true` only for the physics-phase write), and the sample-index pattern is what
separates `procnode` (event one sample earlier) from the landed shape. The
landed part (a) conjuncts and the counter agree in every clean construction.

**Smallest safe correction (record, not fixture).** Replace boundary
§6b/§8.5/§9's claim and reviewer F3's premise with the keyed reading: "the
same-run cell's `log[0]` read 1 because *another* body's entry was first
(`sig_counts B=4`); the treated body's keyed event read +2, matching the landed
pin and the boundary's own n=1 `phase=proc` receipts." The pin itself needs no
edit. Separately, on its own merit (scout directive #8), the arm *may* assert
`Engine.is_in_physics_frame()` at each write — measured exact above — which
makes the "process phase" label asserted rather than assumed and gives the
diagnostic the reviewer asked for **without** depending on the refuted claim.

## 2. `--child`/`--arm` dispatch — the silent wrong-body default is still open

`phys3d_events.gd:219-224` dispatches `--child` on one magic string: only
`--arm=jolt_edge` routes to `_child_jolt`; **everything else** falls through to
`_child_threaded`. Receipts (Jolt project, absolute script path, exactly the
parent's spawn shape):

- `runs/child_isect_jolt.*` — `--child --arm=isect` → exit 0,
  `CHILD_NOTE early_null=false` +
  `CHILD_RESULT pp_edge0=true proc_dss_refused=false srv_ok=true`.
- `runs/child_bare_jolt.*` — `--child` → byte-identical.

So a child-mode invocation for any arm but `jolt_edge` runs the **threaded
body** and reports success; under a Jolt project that body's own verdict is
also *wrong* for its own claim (`proc_dss_refused=false` — no threading). It
does not fabricate a landed PASS only because the parent's map is keyed on
`jolt_*` names and the glued `pp_edge0` line parses to a mismatching key
(`verdicts["pp_edge0"] = "true proc_dss_refused=true srv_ok=true"`). Hand-runs
and log readers have no such key.

**Smallest safe correction** (4 lines, mirroring the parent's own `_:` refusal
at `:723-724`): make the child dispatch total —

```gdscript
match _argval("--arm=", ""):
    "jolt_edge": await _child_jolt()
    "":          await _child_threaded()
    _:           push_error("phys3d_events: unknown child arm " + _argval("--arm=", "")); quit(1)
```

## 3. Impersonation guard — selection-complete on this build; basis is a registry pair

Receipts (`runs/child_jolt_default.*`, `runs/child_jolt_bogus.*`): the child
body run under a **DEFAULT** project and under `"Jolt Physics X"` (the measured
silent-fallback string) prints

```
CHILD_NOTE jolt_class=false godot_class=true engine=DEFAULT|Jolt Physics X
CHILD_RESULT jolt_backend=unexpected
… jolt_isect/cast/btm/contact_stale/static_nopair = same-signature
```

exit 0, clean stream — the *only* detector is the parent's map compare, and it
mismatches on `jolt_backend` + `jolt_static_nopair` → FAIL, loudly. The
author's `scratch_fakechild` witness is reproduced. `runs/gate_*` adds the
witness set: the **live space-state class** is the direct selection witness
(`GodotPhysicsDirectSpaceState3D` / `JoltPhysicsDirectSpaceState3D` /
`PhysicsDirectSpaceState3DDummy`), and the ClassDB pair flips exactly with it
on all four variants — but it is a *registry* property, not the live object
(the scout's "compiled-in vs absent is not separable from GDScript" limit).

Residual (defensive; not a defect on this build): a build registering both
server classes would read `unexpected` on a correct Jolt run (false FAIL), and
a build whose registry lags the selection could accept an impersonation.
**Smallest safe hardening:** print and pin `dss.get_class()` in the child
(`CHILD_RESULT jolt_backend=…` keyed on the live object) and keep the ClassDB
pair as a NOTE. One line; no axis regresses.

## 4. Jolt-absent gate — build-level, invariant across selections, unexercised, honest

`runs/gate_*`: the property hint contains `Jolt Physics` in **all four**
project variants (DEFAULT, Jolt, bogus, Dummy). So the parent's `jolt_avail`
loop (`:660-669`) is a **build** gate — it can never detect a mis-selected
project. That is exactly what the arm's comment and the README claim ("if this
build's engine hint lacks `Jolt Physics`"; "a build without Jolt reports
BLOCKED"), so no over-claim in the landed text, and the selection question is
covered by the child's `jolt_backend` (§3).

The BLOCKED branch is compile-gated (unexercised here; author-disclosed). Its
battery semantics, read from `run_battery.py`'s contract (`:8-14`, exit 0/2 or
FAIL): `print("BLOCKED …")` + `quit(1)` → row expects exit 0 and the exact PASS
marker → `exit 1 != expected 0` + `exact stdout marker missing` → **FAIL**. On a
Jolt-less host the suite reads red with a named reason; there is no `blocked`
class to represent it. That is a taxonomy tradeoff for the canonical judge, not
a fabrication risk: a lying hint still falls through to
`jolt_backend=unexpected` → FAIL. No correction required for honesty.

## 5. The child classifier is not total — a no-evidence class and the abort class

Receipt `runs/child_jolt_dummy.*` (the same child body under a `Dummy` project,
`timeout -s KILL 25`):

```
CHILD_NOTE jolt_class=false godot_class=false engine=Dummy
CHILD_RESULT jolt_backend=unexpected
CHILD_NOTE jolt_isect s0=0 m0=0 away=0 n1=0 back=0
CHILD_RESULT jolt_isect=differs-constants        ← known class from zero evidence
SCRIPT ERROR: Out of bounds get index '0' (on base: 'PackedFloat32Array')
          at: _child_jolt (res://phys3d_events.gd:847)
```

exit **137** (killed at 25 s; the child never exits on its own).

Two distinct defects, both one-liners away:

1. **`jolt_isect`'s second branch is a negative-only predicate** (`:833`:
   `m0 == 0 and away == 0 and away_n1 == 0`). A cell that measured *nothing*
   (`s0=0`, `back=0`) prints `differs-constants` — a "real" class. Under the
   landed expect map the mismatch still fails the row, but the class is a
   false-class generator for any future expect that admits it. Correction:
   require the positive fields (`s0 == 1 and back == 1`) in the `elif`, else
   `unexpected` (or a named `unavailable` keyed on the backend pair the child
   already computes).
2. **The six `cast_motion` index reads are unguarded** (`:847-848`,
   `c0[0] … c2[1]`). On a size-0 array the child aborts *before* printing
   `jolt_cast`, never quits, and the parent blocks inside `OS.execute` until the
   inner `timeout -s KILL 30` fires — while the battery's 20 s case timeout
   kills the *parent* first, so the row reads as a **TIMEOUT-class** failure
   rather than the documented `unexpected` (named), and the grandchild is
   orphaned for the remainder of its bound. This is r84-boundary §3's
   recommendation, not folded; r84-reviewer F2 measured the same class
   independently (my receipt corroborates and adds the class-semantics half).
   Correction: size-guard before indexing (`if c0.size() < 2: print
   CHILD_RESULT jolt_cast=unexpected; …`) in `_child_jolt` and in the parent
   `cast` arm (`:266-267`).

## 6. Spawn/lifecycle — the exit-code conjunct is blind to a signal-killed direct child; the log is never unlinked

`runs/exec_proj.*` establishes the rc ladder on this build: `timeout -s KILL 1
sleep 30` → **137** (the landed timeout path *is* correctly observed),
`timeout 1 sleep 30` → 124, missing binary → 127, failed redirect → 1,
`kill -KILL $$` → **0** in 2 ms.

`runs/sh5_proj.*` (one run): `GODOT_PID=3381885`, `self=$$=3381923
ppid=3381885`, and `ps` prints `3381923 3381885 sh` — the process named by `$$`
is `OS.execute`'s **direct child**. `runs/sh3_proj.*`: `kill -9 $$` →
`kill_rc=0` (delivered) and the command list *continues* (`after` printed)
while `OS.execute` returns **0**. `runs/py_parent_kill.txt`: python
`subprocess` on the same command returns **−9**. So: the direct child died on
SIGKILL and the return value was 0 — `WEXITSTATUS`-style masking; the
`code != 0` conjunct in both spawn arms (`:571`, `:718`) cannot see that class.

`runs/sh6_proj.*` shows the command string is **not handed to the shell
verbatim**: a nested `sh -c 'sleep 0.3; kill -9 $PPID' & wait` killed the
*engine process itself* (no probe output; my shell reported the job
signal-killed), i.e. expansions inside nested quoting resolve one level up —
an extra shell level in the spawn. The landed command contains no `$`/quotes,
so it is unaffected, but (a) any future spawn string that does will be mangled
and (b) the process tree is one level deeper than the r83 F2 fold assumed (the
inner `timeout` still bounds the grandchild ✓).

Consequence for the landed arm: for a run whose direct child is killed before
the redirect, the only witness left is `child.log` — never unlinked by the
parent and a single mutable slot (r84-scribe's finding). In the battery's fresh
per-run scratch the log cannot pre-exist (empty map → FAIL), so this is a
re-run/probe-practice + external-signal class (the boundary's own census hazard
showed a `pgrep -f` sweep killing a wrapper), not a battery-reachable
fabrication today. The reviewer's F1 (WARNING-only leak invisible to the scan)
is the adjacent scan-coverage hole; this one is provenance.

**Smallest safe correction** (one line per arm, `threaded_edge` and
`jolt_edge`): `DirAccess.remove_absolute(logpath)` before the spawn (or open
the log with a truncating `WRITE`), so a stale map can never satisfy the
compare regardless of rc semantics.

## 7. Seed isolation of `joltproj` — clean, mechanism verified

`run_battery.py:769-779` creates `runs/<ts>/scratch`, copies every seed item
(except `run_battery.py`, `__pycache__`, `three`, dotfiles), and every case runs
`--path scratch` (`:795-796`) — so `res://joltproj` is written under the
**scratch** (verified: `runs/<ts>/scratch/joltproj/{project.godot,child.log}`
in the landed run, `proj/joltproj/` in mine). `seed_digests()` (`:467-473`)
walks `HERE.rglob("*")`, so any file added under the seed dir *during* a run
flips `seeds_unchanged` → FAIL. `git status --porcelain corpus/fixtures` is
empty; no stray `joltproj/`/`thrproj/` in the seed dir. The fixture's documented
reproduce line uses `--path <scratch>` (`:54`) and the README's command runs the
battery. Residual (inert but sticky): a *pre-existing* stray dir in the seed dir
would be digested into `digests_before` and copied into every scratch
(harmless — the arm rewrites `project.godot`, the redirect truncates
`child.log`). **No correction required.** Optional hardening: refuse to run when
`res://run_battery.py` exists (the seed dir) with a named error.

Bonus reproduction: my fresh parent-arm run's generated `proj/joltproj/child.log`
is **byte-identical** to the landed author receipt (`cmp` clean,
`runs/jolt_parent.r{1,2}` both PASS).

## 8. Verdict-map pinning — loud where it matters; three named windows

*Loud:* every arm classifier's default is `unexpected`, the parent's compare is
an exact 6-key `!=` (`:710-720`), and any `ERROR:`/`SCRIPT ERROR`/`Parse
Error` line, nonzero rc, or missing/extra key fails the row. A class flip
(e.g. `static_nopair` reverting to silent → `same-signature`) fails the map even
though the label is wrong; a constant drift > 1e-4 reads `unexpected` or the
other known class — both mismatch.

*Windows, named:*
1. **Tolerance** — a Jolt constant drift < 1e-4 reads the pinned class
   (`jolt_cast`/`jolt_btm` use `1e-4` at `:854-859`, `:891-894`; the split
   margins are 5.3e-3 and 3.7e-4, i.e. 53×/3.7× tolerance). The claim is the
   *class*, and the raw values are printed as `CHILD_NOTE` data, so this is a
   scoping note, not a defect.
2. **Coverage** — 5 of 10 arms are replayed under Jolt; `pp_queries`,
   `contact_sig`, `sync_cb`, `srv_area_cb`, `threaded_edge` remain
   live-only/unprobed in-battery (author-disclosed, r83 reviewer F1 class).
3. **Totality** — §5: an abort never reaches the map, and a no-evidence cell
   reads a known class. §6 adds the provenance half (stale log + masked rc).

## 9. No-regression / provenance checks

- The commit is insertion-only for prior arms: `git diff --numstat
  c4b2fa2..01f7d4f` = README `28/0`, `phys3d_events.gd` `396/6`,
  `run_battery.py` `4/0`, author report `189/0`; the 6 deleted lines are
  exactly 3 header doc lines + 3 `--child` dispatch lines (re-derived here;
  matches the author's claim and the reviewer's three-level check). No prior
  arm body touched.
- Duplicate-authority scan: README's new section, the arm comment, and the two
  CASES rows agree on the split constants, the gate semantics and the phase
  rule — no contradiction found. The one conflicting claim in the round record
  is boundary §6b/§8.5/§9 (+ reviewer F3's premise), refuted in §1.
- Not duplicated from siblings: reviewer F1 (WARNING-class scan gap) is
  corroborated-but-not-mine; my §6 finding is the stale-slot + masked-rc half.

## 10. Impacted axes and smallest safe corrections

Axes named for this seat: **E1** evidence attribution (keyed vs first-entry),
**E2** pin basis (counter vs phase), **E3** guard totality (child classifier +
dispatch), **E4** spawn/lifecycle honesty (rc semantics, log provenance),
**E5** seed isolation, **E6** record provenance (no false claim in the round
record).

| # | finding | axes | smallest safe correction | owner |
|---|---|---|---|---|
| 1 | boundary §6b/§8.5/§9 + reviewer F3 premise: "a legitimate process-phase write reads delta_pf=1" | **E1 ↑**, **E6 ↑** | replace with the keyed reading (§1); optional: assert `is_in_physics_frame()` at each write | scribe/reviewer record; author if the witness is wanted |
| 2 | child dispatch silent wrong-body default | **E3 ↑** | total `match` with a named refusal for unknown child arms (§2) | author |
| 3 | `jolt_isect` negative-only branch → known class from zero evidence | **E3 ↑** | require `s0 == 1 and back == 1` in the `elif` (§5.1) | author |
| 4 | unguarded `cast_motion` index read → abort/kill class, 20 s timeout footprint | **E3 ↑**, **E4 ↑** | size-guard before indexing in `_child_jolt` and the parent `cast` arm (§5.2) | author |
| 5 | rc blind to a signal-killed direct child + never-unlinked single-slot log | **E4 ↑** | `DirAccess.remove_absolute(logpath)` before each spawn (§6) | author |
| 6 | guard basis is a registry pair (not the live object) | **E3 ↑** (hardening) | print/pin `dss.get_class()`; keep the pair as a NOTE (§3) | author (optional) |
| 7 | Jolt-absent BLOCKED has no battery class | — (tradeoff) | none for honesty; a `blocked` class is an authored contract change | judge/author |
| 8 | seed isolation of `joltproj` | **E5 =** | none required; optional seed-dir refusal (§7) | — |

No listed correction regresses any axis: 1–6 are additive (a named class, a
named refusal, a size guard, an unlink, a stronger witness) and 7–8 change
nothing.

## 11. Bounds / remaining unknowns

- Every value bounded to this host, `/usr/bin/godot
  4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`, 60 tps, `/bin/sh` → bash.
- The `OS.execute` wrapping/extra-shell mechanism is inferred from
  `sh3/sh5/sh6` receipts and not isolated further; the load-bearing facts are
  the rc (0 with the `$$`-named direct child SIGKILLed) and the direct-child
  identity (`ps`, same run).
- The contamination counterexample is demonstrated with two co-located pairs;
  the boundary's 4-body arm reproduces as `n=4` (`sig_counts`), and the keyed
  treated event is `+2` in both my probe and the boundary's clean n=1 cells.
- The BLOCKED branch stays compile-gated/unexercised; the `Dummy` column is a
  boundary construction, off the tracked path; `Jolt × run_on_separate_thread`
  and the five unprobed arms remain unprobed.
- Report only. I do not judge, admit, edit fixtures, commit, or ship. Stopping
  here.

Artifacts: `corpus/live/r84-critic/` — 9 probes, 4 project variants, 127
receipt files, `RECEIPTS.md`, `manifest.sha256` (146 lines); this report.
