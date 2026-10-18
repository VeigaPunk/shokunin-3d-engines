# SEAT-01 PHYS-DESIGN — r104 minimal wall-cost fix for `phys3d_joints_free_ops`

**Seat:** SEAT-01 PHYS-DESIGN · round 104 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-104/physics/design.md`). Every other path read-only.
`corpus/fixtures/**` was **not written by this seat** — all mutations ran on throwaway copies under
`/home/vgpnk/scratch-r104-s01/`; the repo file was never opened for write.
**Axes served:** depth (the fix's correctness and its cost model), calibration (what the row's class
actually is, and the separation from the 13 `r94_cannon_*` rows).
**No Unreal runtime claim is made here.** The editor is not installed; nothing below touches Unreal.

> **Read this first — the ground moved during the round.** While this seat measured, **SEAT-04 landed
> the R3 rewrite directly in `corpus/fixtures/phys3d_joints.gd`** (its declared scope). `git status`
> shows ` M corpus/fixtures/phys3d_joints.gd`; the file's sha moved from the r103 receipt's
> `88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73` to
> `c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc`. This design was therefore
> re-derived **against SEAT-04's actual patch**, not against the abstract sketch the r103 ledger
> calls for. §3 gives the minimal fix as a diff against the current file, §5 names the one gap the
> patch still has, and §6 is an advisory collision note.

---

## 1. Ruling on the design question

The r103 ledger (`reports/round-103/physics/ledger.md` §4.3 R3) rules that the durable fix is to
**stop serialising the children**, but calls it "a real rewrite of `_run`/`_run_child`" and defers
it. **That estimate is wrong in the lane's favour: the rewrite already exists, twice.**

1. **The shipped precedent is in the same fixture family.** `corpus/fixtures/phys3d_events.gd:615-655`
   (`_spawn_batch`) is a parallel child batch written for *exactly this defect*, and its own comment
   at `:522-529` says so: *"the freed-space matrix spawns one child per method on the real backends,
   and the per-case bound is 20 s — a serial batch of 13 crash children would not fit."* The pattern
   is `_child_prepare` / `_child_scan` split + `OS.create_process` per child + `OS.is_process_running`
   poll + a batch deadline + per-child `timeout -s KILL`. `phys3d_joints.gd` needs only the same shape.
2. **SEAT-04 has already landed it** (§6).

**R3 is therefore the minimal fix, and the byte-identity requirement is satisfiable without any
emission change** — which is the property the ledger's §5.1 warns about. Verified in §4.

The r103 adversary's mechanism claim is **confirmed**; its ruling needs one correction:

- **Confirmed:** 21 serial boots is the binding term. Measured now: 21 serial no-op boots = **15,088 ms**
  (718 ms/child); the same 21 concurrently = **866 ms**. The repair SEAT-33 picks — R3 concurrent
  children — is the one this design also specifies, and this seat's independent measurement agrees it
  is class-eliminating rather than an optimisation (§2.2).
- **Sharpened (new):** SEAT-33 ruled *"on this host the row cannot pass at the shipped bound, at any
  load."* This seat cannot confirm the "at any load" clause, and an early draft of this document
  wrongly claimed to refute it. What the measurements *do* show is that the original's cost is
  **host-state dependent** — the same file costs 23.1 s in this window, 21.2–25.4 s in r103, and
  16.9/17.2 s at r93, and this seat's own early reps could not write scratch at all while the host
  was memory-exhausted. So the row's margin is real but its *size* is not a constant of the fixture.
  See §2.4. **R3 is unaffected either way**, because it removes the margin rather than measuring it.

---

## 2. The measurements this design rests on

All commands were run on this host, 2026-10-18, ~16:20–16:35 local. Load average was **40–65** and
**25 foreign `godot` processes from other lanes** were live throughout; `/tmp` was at 80–100 % of its
16 GB tmpfs quota for part of the window (see §8, last bullets). Trees used:

| tree | bytes | sha256 | source |
|---|---|---|---|
| ORIGINAL | 7,335 | `88be87fa…db4d73` | `git show HEAD:corpus/fixtures/phys3d_joints.gd` |
| CONCURRENT (SEAT-04) | 8,018 | `c7e77638…19ccc` | the working-tree file (26 insertions, 7 deletions) |

### 2.1 The fix, measured

```
$ # each rep on a fresh scratch holding only the two .gd seeds
$ godot --headless --path <scratch> --script res://phys3d_joints.gd -- --arm=free_ops
```

| tree | rep 1 | rep 2 | rep 3 | rc | marker |
|---|---|---|---|---|---|
| ORIGINAL | 23.31 s | 23.22 s | 23.07 s | 0 | exact |
| CONCURRENT | 2.70 s | 2.91 s | 2.81 s | 0 | exact |

**Wall cost falls ~8.2×, and both trees emit the byte-identical pinned marker.** The original's
23.1 s reproduces the r103 ledger's 21.2–25.4 s window exactly, so the comparison is against the same
defect those reports measured.

### 2.2 The mechanism, measured directly

```
$ # 21 no-op boots (extends SceneTree / quit(0)), one project
serial 21:      wall 15,088 ms   (718 ms/child)
concurrent 21:  wall    866 ms
$ # single bare boot, 5 samples
708 / 684 / 761 / 736 / 772 ms, peak RSS ~118 MB each
```

The boot floor is **15.1 s — 75 % of the 20 s cap** — with zero case work. SEAT-33 measured the same
quantity at 19.0 s (95 % of cap) from a 0.90 s/child median; this seat's 0.718 s/child gives 15.1 s.
Both are the same defect, but the *size* of the floor is host-state dependent (§2.4), and that is why
SEAT-33's "95 % of cap before any case work" should be read as a property of its measurement window
rather than of the fixture. Concurrency collapses the floor to 0.87 s in either case, which is why R3
is class-eliminating rather than an optimisation.

### 2.3 The shipped runner, end to end

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs <dir>
PASS     phys3d_joints_free_ops   phys3d_joints.gd   --arm=free_ops   0/0   ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
runner-wall 3.0 s      (x2, both PASS)
```

All eight `phys3d_joints.gd` rows, one run: **8/8 PASS, 19.9 s total** — every other arm's marker
still byte-equal to its pin. (Note: this run, and the two `--only` runs above it, executed against
the working-tree file *after* SEAT-04's edit had landed — i.e. against the concurrent patch, not the
original. That distinction is the subject of §2.4.)

### 2.4 A correction I owe the record: my own "serial" control was contaminated

An earlier draft of this section claimed the **unmodified** fixture passes at the shipped 20 s bound
once host memory recovers. **That claim is withdrawn — the control it rested on was mislabelled.**

The tree I used as the "serial baseline" was copied from the working tree **after** SEAT-04's edit had
landed, so it was a *second copy of the concurrent patch*, not the original:

```
$ diff -q orig/phys3d_joints.gd serial/phys3d_joints.gd
Files … differ                     # orig == git HEAD (88be87fa…); serial was a mid-edit snapshot
$ sha256sum serial/phys3d_joints.gd
c7e77638…19ccc                     # == the SEAT-04 patch
```

So the "8/8 reps at 2.9–4.0 s, all exact" figures were **8 more concurrent reps**, and they agree with
§2.1's concurrent column — they do not bear on the original at all. Against the *true* original,
measured in the same window (§2.1), the row takes **23.1 s and would still overrun the cap**.

**What survives, and what does not:**

- **Survives:** the *concurrent* tree is fast (2.7–3.5 s) and byte-exact — 11 reps across §2.1 and
  this section, zero non-pin markers. That is the fix's evidence.
- **Does not survive:** any claim that the original "can pass at the shipped bound". I have **no**
  measurement of the true original passing, and the r103 reports' "cannot pass at any load" is
  therefore **neither confirmed nor refuted** by this seat.
- **A hypothesis, explicitly unproven.** Early in the round this host had 30 GB of 30 GB RAM
  exhausted and ~25 foreign `godot` processes, and my own scratch copies failed outright
  (`cp: Disk quota exceeded`). Godot's boot cost is known to inflate under that pressure (SEAT-33
  measured start-up at 99.4 % futex). It is therefore *plausible* that the original's 23.1 s is
  partly load-inflated — but **I did not measure the original on a quiet host**, so the honest
  statement is that the row's margin is somewhere between "0.9 s/child intrinsic" and "3.4 s/child
  under this host's load". **R3 does not depend on which it is**, which is precisely why R3 is the
  right fix: it removes the margin rather than trying to measure it accurately.

### 2.5 What this does *not* change

The 13 `r94_cannon_*` failures are untouched and unrelated. Their rows exit 0 and differ from their
pins in exactly one environment token (`node=v24.21.0` → `v26.12.0`, ledger §6). **Do not repair both
in one change** (ledger §6, final bullet).

---

## 3. The minimal fix — exact spec

**Design in one sentence:** spawn all `cases × 3 backends` children first, then collect and emit them
in the *original* nested-loop order, so the emitted stream remains a pure function of the per-child
logs and only the wall clock changes.

**File:** `corpus/fixtures/phys3d_joints.gd`. No other file changes.

### 3.1 Against the current (SEAT-04) file — one addition

The patch at `:85-100`, `:126-175` is already the right shape. The **only** change this design adds is
the batch deadline, because `_collect_child` (`:150-152`) currently waits **unboundedly**:

```gdscript
150 func _collect_child(j: Dictionary) -> Dictionary:
151     while OS.is_process_running(j["pid"]):
152         OS.delay_msec(5)
```

Replace the collection loop at `:95-100` with a deadline-bounded form, and add the constant next to
`BOUND_S` at `:29`:

```gdscript
const BATCH_BOUND_S := 16          # new, beside BOUND_S at :29

    var deadline := Time.get_ticks_msec() + BATCH_BOUND_S * 1000
    for j in jobs:
        while OS.is_process_running(j["pid"]) \
                and Time.get_ticks_msec() < deadline:
            OS.delay_msec(5)
        if OS.is_process_running(j["pid"]):
            OS.kill(j["pid"])
            return _fail("%s@%s batch_timeout" % [j["case"], j["bk"]])
        var d := _collect_child(j)
        if d.has("err"):
            return _fail("%s@%s %s" % [j["case"], j["bk"], d["err"]])
        _emit(j["case"], j["bk"], d)
    _finish()
```

**Why 16 s.** Each child already carries its own `timeout -s KILL 20` (`BOUND_S`, `:29`) inside the
spawned `/bin/sh` (`:140-144`), so no child can exceed 20 s; the batch deadline is a *fail-closed net
on top*, exactly as `phys3d_events.gd:372`/`:618` describes its own `BATCH_BOUND_S = 12`
(`:634`). A batch that outlives 16 s means children were starved of CPU by the host — that is a
**named failure**, not a silent partial row. It must be **below** the runner's per-case bound or it
can never fire.

### 3.2 Against the r103 ORIGINAL (for reference, if SEAT-04's patch is reverted)

| location (original) | change |
|---|---|
| `:85-94` `_run` | two passes: spawn every `(case, bk)` into `jobs`, then `_collect_child` + `_emit` in the same nested-loop order |
| `:117-155` `_run_child` | split at the `OS.execute` seam (`:135`): `_spawn_child` returns `{case, bk, pid, log}`; `_collect_child` polls, reads the exit code, scans the log |
| `:135` | `OS.execute("/bin/sh", ["-c", cmd], [], false)` → `OS.create_process("/bin/sh", ["-c", cmd], false)` |
| `:29` | add `const BATCH_BOUND_S := 16` |
| `:86-87`, `:97-99` | `_fail` must `return` (the deferred-`quit()` trap, ledger §3.3) |

The `cmd` string, the `dirname` namespacing (`:118`), the stale-log unlink (`:130`), the log scan
(`:136-153`) and `_emit` (`:158-180`) are **all unchanged** — that is what makes the marker stable.
(Line numbers in this table are from the ORIGINAL, `git show HEAD:…`; the current file's equivalent
sites are `_spawn_child` `:126-148`, `_collect_child` `:150-175`, `_emit` `:177`.)

### 3.3 What must NOT be done

- **Do not raise `run_battery.py:36`.** R3 removes the margin; a cap raise only hides it, and it
  changes hang-detection latency for all 350 rows. The r103 ledger's R2 map is the conservative
  fallback *only if R3 is reverted*.
- **Do not touch `_emit` or the `CASES` pin.** See §4.
- **Do not reorder emission.** `_run` must walk `ARM_CASES[arm]` × `BACKENDS` in the original order
  after collection (SEAT-04's patch does).

---

## 4. Byte-identical marker and `seeds_unchanged` — why both hold

**Byte-identity is structural, not coincidental.** The emitted line is `" ".join(_parts)`, and
`_parts` is appended by `_emit` in the `_run` loop order. R3 changes *when* a child runs, never *what*
is appended nor in what order, because collection iterates the same `jobs` list that was built in
emission order. **Observed:** all 21 cells equal the pin for the CONCURRENT tree (§2.1), and 8/8 arms
match their pins (§2.3).

**`seeds_unchanged`** is computed by `run_battery.py:1244/1323/1343` from `seed_digests()`
(`:940-946`) over `HERE.rglob("*")` — i.e. over the **seed tree**, not the scratch. R3 writes only
into the scratch copy. So the flag is unaffected. Confirmed by the fact that SEAT-04's working-tree
edit does **not** perturb it: the runner copies the seeds *after* the digest is taken and compares the
*same* tree at the end, so a modified seed is internally consistent (and `f456bd00…`/`84f6241d…` are
unchanged on disk for the other two seeds).

**Residual risk (low, named).** The arm is not reentrant — it writes per-cell child projects into
`res://r90bt_<arm>_<case>_<backend>/` inside the parent project (ledger §3.2). A concurrent second
invocation on the *same* project still degrades cells. R3 does **not** change this and must not be
sold as fixing it. The runner gives each case a fresh scratch per run, so the battery is unaffected
(unless a lane re-points `--runs` at a previously used tree, which the r103 ledger §5.4 records
happening); `phys3d_events.gd:530-553` adds a dirname whitelist for the same hazard, and that
hardening is a
*separate* item, not part of this minimal fix.

---

## 5. The one gap in the current patch — measured

**`_collect_child` (`:150-152`) has no deadline, so a stalled child stalls the whole row.**

Setup: throwaway copies; a child (`r90_child.gd`) with an injected 30 s stall on one case
(`freeb_twice`), spawned through the arm's own `timeout -s KILL 20`:

| tree | rc | wall | verdict line | marker vs pin |
|---|---|---|---|---|
| patch as landed | **0** | **21.03 s** | `PASS phys3d_joints free_ops …` | **3 cells differ** |
| patch + §3.1 deadline | **1** | 17.14 s | `FAIL phys3d_joints free_ops reason=freeb_twice@gp batch_timeout` | n/a (no PASS) |

**The as-landed patch fails open, and it is worse than a cap-timeout.** The injected child's own
`timeout -s KILL 20` fires at 20 s; `_collect_child` then reads whatever the truncated log holds and
`_emit` prints it. Cell-level diff of the as-landed output against the pin:

```
got freeb_twice@gp{mode_ok=0,m4=e3b0c44298fc1c14}      exp …{mode_ok=1,m4=e7c8b9cc20d38b1e}
got freeb_twice@jolt{mode_ok=0,m4=e3b0c44298fc1c14}    exp …{mode_ok=1,m4=c42295756101d8d6}
got freeb_twice@dummy{rc=137,m=,e=0,w=0}               exp …{rc=0,m=M0 case=freeb_twice …}
```

Note `m4=e3b0c44298fc1c14` — that is the sha16 of the **empty string**, i.e. the child log was read
empty; and `freeb_twice@dummy` carries `rc=137` (the SIGKILL the bound delivered) with a **zero-length
`m=`**. So the row emits a *corrupt* marker, prints **`PASS`**, and exits 0. Under the runner that
surfaces as `['exact stdout marker missing']` with `actual_exit: 0` — the same textual class as the 13
`r94_cannon_*` environment-pin failures, i.e. **maximally ambiguous**. (This is the D2 fail-open the
r103 ledger describes at its §3, re-reached through the concurrency path: `_finish` still never
consults the cells it prints.)

The deadline variant's happy path is unaffected: **3.27 s, exact marker** (vs 2.87 s as-landed).
That is the whole case for §3.1: same speed, but a starved batch becomes a **named** `batch_timeout`
failure instead of a silent `PASS` over a corrupt marker.

---

## 6. Collision advisory — SEAT-04 already holds this file

The lane brief scopes `corpus/fixtures/phys3d_joints.gd` to SEAT-04. This seat obeyed that and wrote
no fixture code, but the design was necessarily re-derived against SEAT-04's in-flight bytes. Three
things follow:

1. **The design is not a competing rewrite.** §3.1 is a single-loop addition on top of SEAT-04's own
   patch. If SEAT-04 lands the deadline, this document is satisfied.
2. **`git status` is the only reliable read.** The file's sha changed mid-round (SEAT-04's first
   working-tree snapshot was itself replaced by a later one), so **every number in §2 was taken with
   its sha recorded alongside it**, and only §2.1's ORIGINAL column and the "CONCURRENT" columns are
   attributable to a named tree. Trees this seat built from a mid-edit snapshot are labelled as such
   in §2.4 rather than silently treated as baselines.
3. **The r104 close-out must state the fixture's final sha**, since the r103 receipt's
   `88be87fa…` is no longer the working-tree value. A receipt that reports the old sha for this file
   will look like a seed mutation.

---

## 7. Acceptance commands

### 7.1 A-R3 — the fix

```sh
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs <fresh>
```
must print `PASS phys3d_joints_free_ops: exit=0 expected=0`, `pass=1 fail=0`, and the receipt row
must carry `reasons: []`, `actual_exit: 0`, and a stdout PASS line **byte-equal** to the pin
(`sha256[:16] == 706ad9151452e18d`, 3,921 chars). **Observed: PASS ×2 at 3.0 s wall — run against
SEAT-04's patched file; the same command against the unpatched original is the r103 FAIL.**
Then the whole family:
```sh
python3 corpus/fixtures/run_battery.py --only phys3d_joints_sweep,phys3d_joints_rid,phys3d_joints_api,\
phys3d_joints_free_pair,phys3d_joints_free_ops,phys3d_joints_detach,phys3d_joints_chain3,phys3d_joints_twopin
```
**Observed: 8/8 PASS, 19.9 s — every marker byte-equal to its pin.**

### 7.2 A-DEADLINE — the §3.1 addition

With the injected-stall child: the row must print `FAIL phys3d_joints free_ops reason=freeb_twice@gp
batch_timeout` and `rc=1`, **and** the happy path must still emit the exact marker.
**Observed: 17.14 s / rc=1 / zero PASS lines; happy path 3.27 s / exact.**

### 7.3 A-INTEGRITY — the round's byte-pin discipline

```sh
sha256sum corpus/fixtures/run_battery.py   # f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
sha256sum corpus/fixtures/r90_child.gd    # 84f6241de590b5810357dde7714a19ec37e3072526e165e4c3ac8a8010d9aaa7
sha256sum corpus/fixtures/phys3d_joints.gd # c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc (SEAT-04 r104)
git status --porcelain -- corpus/fixtures/   # only phys3d_joints.gd modified, by SEAT-04
```
**Observed exactly that.** `run_battery.py` (`f456bd00…`) and `r90_child.gd` (`84f6241d…`) are
untouched by this round; `phys3d_joints.gd` is modified by SEAT-04, not by this seat. The fixture sha
must be re-recorded in the r104 close-out: the r103 receipt's `88be87fa…` is no longer the
working-tree value.

---

## 8. Limits of this design

- **Not applied by this seat.** §3.1 is a spec; `corpus/fixtures/**` is SEAT-04's scope and this seat
  wrote none of it. The patch described is SEAT-04's, quoted for design purposes.
- **The flake rate of R3 is not established.** 11 concurrent reps (3 in §2.1 + 8 in §2.4) and 3
  working-tree reps produced the exact marker, but the round's early window was confounded by host
  memory exhaustion and `/tmp` quota, so **no honest R3 flake rate can be quoted from this round.**
  A clean measurement needs a host with the other lanes idle. The one mechanism that *can* produce a
  non-pin marker under R3 is CPU starvation → the runner's cap kill → truncated child logs; the §3.1
  deadline converts that into a named failure, which is the strongest mitigation available without a
  dedicated host.
- **The original's cost is not cleanly established either.** 23.1 s in this window (§2.1), against
  21.2–25.4 s in r103 and 16.9/17.2 s at r93 — see §2.4 for why this seat's earlier "the original
  passes now" reading was wrong. Do not quote 23.1 s as an idle-host figure.
- **Peak memory of 21 concurrent children was not measured cleanly.** `ps`-based RSS sums were
  contaminated by 25 foreign `godot` processes; the only clean number is single-child peak RSS
  **~118 MB**, giving a rough 21 × 118 MB ≈ 2.5 GB concurrent ceiling. On a 30 GB host that is
  acceptable; on a memory-starved host it is an additional reason to prefer a bounded batch (a
  future refinement: spawn in waves of 6–8).
- **`/tmp` is not viable as a scratch root on this host today.** `df /tmp` was at 80 % of a 16 GB
  tmpfs and this seat's own copies failed with `Disk quota exceeded` mid-round. That is SEAT-02's C2
  subject; this design's measurements were moved to `/home/vgpnk/scratch-r104-s01/` for that reason.
- **No Unreal claim.** None is made, and none is possible here (editor not installed).

**Evidence kept:** `/home/vgpnk/scratch-r104-s01/` — `orig/` (the `git show HEAD:` fixture),
`serial/` (the mislabelled mid-edit snapshot of §2.4, kept because it is the evidence *for* that
correction), `seed/` (the concurrent patch copy), `hang/{asis,deadline}/` (the stalled-child trees of
§5), `boot/` (the no-op boot-floor project), `cells.py` (the cell-level marker differ that produced
every "exact"/"ndiff" verdict above), `pair.sh`, `patch.py`, `globcheck.py`, `runs/` (shipped-runner
receipts), `arms/` (the 8-arm receipt), and every `.out` file quoted in §2 and §5.
