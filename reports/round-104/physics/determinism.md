# SEAT-06 DETERMINISM-ADVERSARY — r104

**Seat:** SEAT-06 DETERMINISM-ADVERSARY · round 104 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-104/physics/determinism.md`). Every other path was
read-only. `corpus/fixtures/**` was **never** written: both fixture trees live under
`reports/round-104/physics/s06/{serial,conc}/` and were materialised from `git archive HEAD`
(a read-only operation — no `git stash`, no worktree checkout).
**Lane HEAD:** `88c3b2c` (r103 report-last; work `8c9d9ad`).
**Subject:** the C1 preferred fix **R3** (r103 `reports/round-103/physics/ledger.md` §4.3) — stop
serialising the 21 `free_ops` children — and whether concurrency changes **any byte** of any arm's
output.
**Axes served:** depth (C1). No Unreal runtime claim is made here (editor not installed; live-MCP
unproven by construction). This seat made no claim about Unreal at all.

---

## 1. Verdict

> **NOT REFUTED.** On this host, the R3 patch changes **no byte** of any arm's output. All 8
> `phys3d_joints` arms emit a byte-identical stdout stream before and after the patch, and both
> streams are byte-equal to the literal pinned in `run_battery.py` for all 8 rows.
>
> The result is established **against SEAT-04's actual landed bytes** (§3.1), not merely against this
> seat's reconstruction: the two implementations differ only in comment wording, and every arm was
> re-run against the worktree patch with the same outcome (8/8 identical).
>
> One **behavioural** side effect exists that is *not* a byte difference and does *not* affect the
> marker — it is reported in §7 rather than buried, because it is the only thing the patch changes
> that a reviewer could care about.

The C1 acceptance criterion (marker identity) is met, and the depth win is large: `free_ops`
**20231 ms → 2501 ms** (8.1×) on the same host, minutes apart; against the landed patch, 3622 ms.

---

## 2. What "pre-patch" means here (no `git stash`)

The brief forbids `git stash`/`checkout`. The pre-patch tree is the exact HEAD blob, extracted
read-only:

```
$ git archive HEAD corpus/fixtures | tar -x -C reports/round-104/physics/s06/
$ mv reports/round-104/physics/s06/corpus/fixtures reports/round-104/physics/s06/serial
$ cp -a serial conc                      # conc then receives the R3 patch

serial sha: 88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73
HEAD   sha: 88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73   <- identical
conc   sha: e79c3180905c1104eccccdc94a29309dd95385347badd2383d48c36f5cb84b67
```

`git status --porcelain` showed the worktree `corpus/fixtures/phys3d_joints.gd` byte-identical to HEAD
at the time this seat started (the SEAT-04 patch landed *during* this seat — see §3.1), so `serial/`
**is** the shipped file, not a reconstruction. This seat implemented R3 on `conc/` from the ledger's
§4.3 description; it turned out to be functionally identical to what SEAT-04 landed, so §3.1 re-runs
every arm against SEAT-04's actual bytes.

**Materialised in this seat's scratch (never written to `corpus/`):** `serial/`, `conc/`, and
`seat04/` (a copy of `serial/` with the worktree patch's `phys3d_joints.gd` dropped in, for §3.1).

### 2.1 The patch (4 hunks; `_emit`/`_finish`/`_fail`/`BIMODAL` untouched)

```
$ diff conc/phys3d_joints.gd serial/phys3d_joints.gd   # 4 hunks, 180 -> 199 lines
```

- `_run()` — builds a `jobs` list by calling `_spawn_child` for every (case, backend) pair, **then**
  walks `jobs` in the original nested-loop order to `_collect_child` + `_emit`. `_parts` ordering is
  therefore order-independent by construction.
- `_run_child` → `_spawn_child`: the blocking `OS.execute(...)` becomes
  `OS.create_process("/bin/sh", ["-c", cmd], false)`; returns `{case, bk, pid, log}`.
- `_spawn_child` → `_collect_child`: spins on `OS.is_process_running(pid)`, takes
  `OS.get_process_exit_code(pid)`, then scans the log with the **byte-identical** 4-branch scanner.

**API precondition verified before relying on it** (the ledger's R3 required a real rewrite, so the
primitives had to be shown to exist on this engine, not assumed):

```
$ godot --headless --path <probe> --script res://api_probe.gd
pid=3088111
rc=7 wall_ms=211
has get_process_exit_code=true
has create_process=true
has is_process_running=true
```
(`Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf`; the probe created `/bin/sh -c "sleep 0.2; exit 7"`
and recovered exit code 7 — so the non-blocking path returns real exit codes, not just 0/1.)

---

## 3. Evidence 1 — full-stream byte identity, all 8 arms

`bytecmp.sh` runs each arm against **both** trees and compares the **entire stdout** (engine banner +
every `M` line + the `PASS` line), byte for byte.

```
$ bash bytecmp.sh
sweep      serial rc=0 wall_ms=2827     conc rc=0 wall_ms=1485    IDENTICAL sha=e174bd3faffefb5c
rid        serial rc=0 wall_ms=2706     conc rc=0 wall_ms=1388    IDENTICAL sha=be8cd5879ee78704
api        serial rc=0 wall_ms=2875     conc rc=0 wall_ms=1443    IDENTICAL sha=40bd27ccbd20d77c
free_pair  serial rc=0 wall_ms=9701     conc rc=0 wall_ms=2344    IDENTICAL sha=d8bf020d37ff6b4c
free_ops   serial rc=0 wall_ms=20231    conc rc=0 wall_ms=2501    IDENTICAL sha=07f72b5beae4a114
detach     serial rc=0 wall_ms=3357     conc rc=0 wall_ms=1610    IDENTICAL sha=d0856064febbee94
chain3     serial rc=0 wall_ms=5417     conc rc=0 wall_ms=2936    IDENTICAL sha=6f5e4d672e84dcd2
twopin     serial rc=0 wall_ms=8394     conc rc=0 wall_ms=2089    IDENTICAL sha=2a3724ef3bfef825
```

8 of 8 identical, 0 differ. Both stderr streams are empty (0 bytes) for every arm, so stderr carries
no byte that could differ either.

`free_ops` is the C1 row: **20231 ms → 2501 ms**, i.e. below the 20 s `CASE_TIMEOUT_SECONDS` for the
first time. The remaining arms also roughly halve (3 children → 2 concurrent boots' worth), which is
the expected shape: cost ≈ one boot + longest child, not `n` boots.

### 3.1 Re-run against SEAT-04's **actual landed bytes**

SEAT-04 landed its R3 implementation into the worktree while this seat was running. It is the **same
algorithm**; comment wording is the only difference:

```
$ strip() { grep -v '^\s*#' "$1" | grep -v '^$'; }
$ diff <(strip conc/phys3d_joints.gd) <(strip seat04/phys3d_joints.gd)
IDENTICAL FUNCTIONAL CODE
seat04 sha: c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc   <- worktree
conc   sha: e79c3180905c1104eccccdc94a29309dd95385347badd2383d48c36f5cb84b67   <- this seat
```

Every arm re-run against the worktree bytes, compared to the same serial reference:

```
$ for arm in sweep rid api free_pair free_ops detach chain3 twopin; do godot --headless --path seat04 --script res://phys3d_joints.gd -- --arm=$arm; done
sweep      rc=0 wall_ms=  1736 IDENTICAL-to-serial
rid        rc=0 wall_ms=  1763 IDENTICAL-to-serial
api        rc=0 wall_ms=  1843 IDENTICAL-to-serial
free_pair  rc=0 wall_ms=  3319 IDENTICAL-to-serial
free_ops   rc=0 wall_ms=  3622 IDENTICAL-to-serial
detach     rc=0 wall_ms=  1684 IDENTICAL-to-serial
chain3     rc=0 wall_ms=  4159 IDENTICAL-to-serial
twopin     rc=0 wall_ms=  2570 IDENTICAL-to-serial
```

8 of 8 identical against the shipped worktree patch, 0 differ. The verdict therefore applies to
SEAT-04's bytes, not merely to a reconstruction. (SEAT-04 additionally changed
`_fail("unknown_arm")` → `return _fail("unknown_arm")` in the unknown-arm guard; that is the §4.3
`return`-after-`quit()` fix and is unreachable on a valid arm, so it cannot affect any of the 8 rows
above.)

## 4. Evidence 2 — anchored to the pin, not just to each other

`serial == conc` alone is weaker than it looks: both could have drifted together. `pinanchor.py`
reads the `CASES` table out of the shipped runner and compares each arm's PASS line against its
**pinned marker literal**, byte for byte:

```
$ python3 pinanchor.py
api        n_serial=1 n_conc=1 serial==pin=True conc==pin=True sha16=fb36001cbe41c661
chain3     n_serial=1 n_conc=1 serial==pin=True conc==pin=True sha16=26912caaa4ee260f
detach     n_serial=1 n_conc=1 serial==pin=True conc==pin=True sha16=fe2743f8a825f289
free_ops   n_serial=1 n_conc=1 serial==pin=True conc==pin=True sha16=706ad9151452e18d
free_pair  n_serial=1 n_conc=1 serial==pin=True conc==pin=True sha16=a8f66074ea928699
rid        n_serial=1 n_conc=1 serial==pin=True conc==pin=True sha16=94a5ddaa4739e3da
sweep      n_serial=1 n_conc=1 serial==pin=True conc==pin=True sha16=84e0a9abe19ffce9
twopin     n_serial=1 n_conc=1 serial==pin=True conc==pin=True sha16=f3a829393a088ab9
```

All 8: exactly one verdict line, equal to the pin, in both trees. The `free_ops` value
`706ad9151452e18d` is **the same 16-hex value the r103 ledger recorded for that pin** (§2.2:
`sha16 pinned 706ad9151452e18d`), which independently confirms the extraction is reading the right
literal.

## 5. Evidence 3 — the decisive, parent-independent concurrency test

The refutation risk for R3 is not parent-side bookkeeping (that is order-independent by
construction). It is that a child **starved past its own inner `timeout -s KILL 20`** (`BOUND_S`)
returns `rc=137` with `sig11=0`, which for a BIMODAL cell is `mode_ok=0` — different bytes.

`r90_child.gd` is copied unchanged and the generated `project.godot` string is identical in both
trees, so the conc parent's workload is *exactly*: launch the arm's 21 child command lines
simultaneously, then read the logs. `child21.py` does that with **no parent involved** and applies the
parent's own projection (first `n_pre` M-lines, `sha256[:16]`) to each log:

```
$ python3 child21.py
arm=free_ops pairs=21 pinned_cells=12
== serial_control concurrent=False wall_ms=23557      matched=12 mismatched=0 of 12
== all21_concurrent concurrent=True  wall_ms=2123     matched=12 mismatched=0 of 12
== conc_rep0       concurrent=True  wall_ms=2187      matched=12 mismatched=0 of 12
== conc_rep1       concurrent=True  wall_ms=1909      matched=12 mismatched=0 of 12
== conc_rep2       concurrent=True  wall_ms=2675      matched=12 mismatched=0 of 12
REPEAT: 3 extra concurrent rounds, total mismatches=0
```

All 12 pinned cells (gp + jolt) match the pin exactly in **every** concurrent round, including the
mid-ops-crash cells (`freeb_ops@*` `n_pre=6`, `chain3`-class) and the `[4,4]` teardown cells. The
`@dummy` cells are not in `BIMODAL` and emit their `M` lines literally; §6 checks those separately.

## 6. Evidence 4 — whole-arm concurrency, and the in-parent `@dummy` cells

`worstcase.sh` gives every parent its **own private tree copy**, so the only shared resource is the
CPU — i.e. up to `21 × M` simultaneous Godot boots, the true worst case R3 introduces.

```
$ bash worstcase.sh free_ops 4
== serial: 4 parents x 21 children, wall_ms=23714 rc=0 0 0 0   identical=4 differs=0 inconclusive=0 of 4
== conc:   4 parents x 21 children, wall_ms=4410  rc=0 0 0 0   identical=4 differs=0 inconclusive=0 of 4

$ bash worstcase.sh free_ops 6
== serial: 6 parents x 21 children, wall_ms=26051 rc=0 0 0 0 0 0   identical=6 differs=0 inconclusive=0 of 6
== conc:   6 parents x 21 children, wall_ms=6394  rc=0 0 0 0 0 0   identical=6 differs=0 inconclusive=0 of 6

$ bash worstcase.sh free_pair 2
== serial: 2 parents x 21 children, wall_ms=11636 rc=0 0   identical=2 differs=0 inconclusive=0 of 2
== conc:   2 parents x 21 children, wall_ms=3029  rc=0 0   identical=2 differs=0 inconclusive=0 of 2
```

**126 concurrent Godot boots** (m=6) and still byte-identical in both trees. Note the conc row holds
at ~4–6 s while serial grows 23.7 s → 26.1 s: the patch absorbs the load instead of queueing it.

The in-parent `@dummy` cells are the part of the stream not covered by §5's projection:

```
$ python3 - <<'PY'   # extract the literal @dummy cells from each tree's free_ops stdout
dummy cells: 7
dummy cells byte-identical: 7 of 7
cell sequence identical: True ( 21 cells )
```

All 7 literal `@dummy` cells are byte-identical, and the 21-cell tag **sequence** is identical — so
R3 preserves the stream's ordering, not merely each cell's projection.

## 7. The one behavioural side effect (not a byte difference)

R3 spawns **all** children before the first collect, so on a row that fails at child *k*, children
`k+1..21` are already running and must run to completion (or to their 20 s inner bound) before the
parent can exit. The serial code had launched none of them.

Measured by forcing a failure (the 7th child's project path replaced by an unwritable **file**):

```
$ for t in serial conc; do godot --headless --path err/$t --script res://phys3d_joints.gd -- --arm=free_ops; echo rc=$?; done
=== serial ===
FAIL phys3d_joints free_ops reason=freeb_make@gp cannot write child project     rc=1
--- child dirs spawned: 6
=== conc ===
FAIL phys3d_joints free_ops reason=freeb_make@gp cannot write child project     rc=1
--- child dirs spawned: 6
```

**The emitted failure is byte-identical** — same line, same rc=1, same `reason`, same child *k*.
The difference is purely in-process: conc's 6 already-launched children (dirs + `child.log` present in
both trees) finish in the background.

Correction to an earlier draft of this section: the child **logs are not** byte-identical between the
two trees, and that is an artifact of the trees' paths, not of the patch:

```
$ for cell in freeb_ops_gp freeb_ops_jolt freeb_twice_gp freeb_twice_jolt freeb_ops_dummy freeb_twice_dummy; do cmp err/serial/r90bt_free_ops_$cell/child.log err/conc/r90bt_free_ops_$cell/child.log; done
freeb_ops_gp DIFFERS:
   [0] on_e (…/s06/err/serial/r90_child.gd:104)
   [0] on_e (…/s06/err/conc/r90_child.gd:104)
freeb_ops_jolt DIFFERS:  … :96
freeb_twice_gp DIFFERS:  … :137
freeb_twice_jolt DIFFERS: … :137
freeb_ops_dummy  IDENTICAL
freeb_twice_dummy IDENTICAL
```

Every differing byte is the **absolute tree path** embedded in a crash backtrace (`err/serial/` vs
`err/conc/`), on the four cells that crash and not on the two that do not. This is the same class as
the ASLR `Load address:` bytes in §8.3, and it is why the parent never hashes a raw log. The
`M`-prefix stream — the only thing `_emit` reads — is unaffected, as §3–§6 establish.

Assessment: this is a **liveness**, not a determinism, change, and it cannot alter a marker (the row
already failed; `classify` reads the FAIL line). It is worth a line in the ledger because it is a real
difference in a failure path, and because it means a failing `free_ops` row can now hold up to
`~20 s` of already-spawned children — bounded, since each child keeps its own `BOUND_S=20`.

## 8. Adversarial controls this seat ran and **discarded**

Both are recorded because a confounded result must not be presented as evidence.

### 8.1 `stress.sh` — mis-designed, replaced

`stress.sh` ran 8 concurrent *parents* against **one shared project dir**. That is the **documented
D2 scratch collision** (ledger §3.2: two arms sharing one scratch rewrite each other's child
projects), not an R3 effect. Both trees degraded equally (8/8 reps differing in each), so the run had
no discriminating power for the patch. It also spawned 168 Godot processes; this seat killed its own
strays afterwards and confirmed `pgrep -af 'physics/s06'` empty. Replaced by `worstcase.sh`
(private tree per parent).

### 8.2 `worstcase.sh free_pair 3` — confounded, harness hardened

```
== serial: 3 parents x 21 children, wall_ms=8393  rc=137 137 137   identical=0 differs=3 of 3
== conc:   3 parents x 21 children, wall_ms=1331  rc=137 137 137   identical=0 differs=3 of 3
```

All three parents in **both** trees were SIGKILLed at ~8 s (co-tenant memory pressure — other seats
were running Godot export jobs; host free RAM was ~0.6 GB, load ~53). Each rep's stdout is only the
101-byte banner, so this run has **zero** discriminating power: "identical" there would have been an
artifact of both sides being empty.

Fix applied to the harness: a rep whose stdout lacks the arm's `PASS` line is now classified
**INCONCLUSIVE**, never "identical". The clean re-run is §6's `free_pair m=2`
(`identical=2 differs=0 inconclusive=0`).

### 8.3 Raw child logs are **not** byte-stable — by design

`childiso.sh` byte-compares raw `child.log` files for one cell and shows them differing:

```
serial rep 1 rc=134  sha=fa5ad6370c46a7cc
serial rep 2 rc=0 DIFFERS      serial rep 3 rc=134 DIFFERS  ...
conc rep 1..5 DIFFERS   19c19  < Load address: 5620a0dc3000  > 55e7486a9000
```

Two causes, both pre-existing and both named in the fixture's own header (`phys3d_joints.gd:12-15`):
ASLR (`Load address:`) and the documented **clean/crash bimodality** of teardown-UAF cells. This is
*why* the parent projects onto the `n_pre`-prefix sha rather than hashing the log. Projecting the same
10 logs the parent's way collapses them to one value:

```
$ # first 6 M-lines, joined by \n, sha256[:16]
serial.1..5  msha16=124dfece8083d80f   (mlines 6,8,6,6,6)
conc.1..5    msha16=124dfece8083d80f   (mlines 6,6,6,6,8)
```

`124dfece8083d80f` is the pin. So the raw-log instability is **not** an R3 finding — it is the
pre-existing bimodality, and R3 does not add to it.

## 9. Limits of this evidence (stated, not hidden)

1. **SEAT-04 landed the patch mid-seat; §3.1 now covers it.** The seat began with the worktree fixture
   byte-identical to HEAD and implemented R3 itself from the ledger's §4.3 description. SEAT-04's
   implementation turned out to be the **same algorithm** (functional-code diff empty), and §3.1
   re-runs all 8 arms against those exact bytes with the same 8/8 result. What does **not** transfer
   is a *different* R3 shape — e.g. a bounded in-flight window instead of all-21-at-once. The harness
   is left in place to re-run §3–§6 against any such change.
2. **Single host, single engine build.** `4.7.2.stable.arch_linux.ed1daf0bf`, 32 cores. A host with
   far fewer cores could starve a child past `BOUND_S=20` — the failure mode §5 tests for. The m=6
   run (126 boots on 32 cores) is the strongest pressure applied; it did not trigger it, but "did not
   trigger here" is not "cannot trigger".
3. **Noise, not silence, on this host.** Co-tenant seats pushed load to ~60 and caused the §8.2
   confound. Every number quoted in §3–§6 comes from a run whose reps all carried the arm's `PASS`
   line (`inconclusive=0`) or whose cells all matched the pin.
4. **`inconclusive` classification is my own.** The `worstcase.sh` hardening is a reviewer-facing
   choice; a stricter reading would also discard any rep whose wall clock is anomalously low. Not
   done — the PASS-line check is the objective part.
5. **"No byte of any arm's output" is scoped to stdout + stderr of the 8 `phys3d_joints` rows.** §7
   shows the failure path *does* leave differently-pathed child logs behind. Those bytes are not
   output (nothing reads them across trees, and the path is the tree's own), but the claim is scoped
   to what §3 measured rather than stated absolutely.

## 10. Acceptance commands (re-runnable)

```
cd reports/round-104/physics/s06
bash bytecmp.sh                 # §3  all 8 arms, full-stream byte compare
python3 pinanchor.py            # §4  both trees == run_battery.py pinned literal
python3 child21.py              # §5  parent-independent 21-way projection test + 3 reps
bash worstcase.sh free_ops 6    # §6  126 concurrent boots, private trees

# §3.1 — against SEAT-04's landed bytes
cp -a serial seat04 && rm -rf seat04/r90bt_* seat04/__pycache__
cp ../../../../corpus/fixtures/phys3d_joints.gd seat04/phys3d_joints.gd
for arm in sweep rid api free_pair free_ops detach chain3 twopin; do
  godot --headless --path seat04 --script res://phys3d_joints.gd -- "--arm=$arm" \
    > runs-seat04/$arm.stdout
  cmp -s runs/$arm.serial.stdout runs-seat04/$arm.stdout \
    && echo "$arm IDENTICAL-to-serial" || echo "$arm DIFFERS"
done

python3 - <<'PY'                # §6  in-parent @dummy cells + tag sequence
import re, pathlib
a = pathlib.Path("runs/free_ops.serial.stdout").read_text()
b = pathlib.Path("runs/free_ops.conc.stdout").read_text()
d = lambda t: {m.group(1): (m.group(2), m.group(3))
               for m in re.finditer(r'([a-z0-9_]+)@dummy\{rc=(\d+),m=([^}]*)\}', t)}
print("dummy identical:", d(a) == d(b), len(d(a)))
print("sequence identical:",
      re.findall(r'([a-z0-9_]+@(?:gp|jolt|dummy))\{', a)
      == re.findall(r'([a-z0-9_]+@(?:gp|jolt|dummy))\{', b))
PY
```

## 11. Artifacts left in this seat's scratch

`reports/round-104/physics/s06/` — `serial/` (HEAD bytes), `conc/` (this seat's R3), `seat04/`
(worktree patch's bytes, §3.1), `bytecmp.{sh,log}`, `pinanchor.{py,log}`, `child21.{py,log}`,
`worstcase.{sh,worstcase-*.log}`, `childiso.{sh,log}`, `stress.{sh,log}` (superseded, §8.1),
`runs/` + `runs-seat04/` (16 arm stdouts each), `child21/` (per-child logs), `err/` (§7
failure-path trees). The bulky `worstcase-*/` private tree copies (~385 MB) were pruned after the
round — the `.log` transcripts of every run are retained and the script recreates the trees.
No file outside `reports/round-104/physics/` was created or modified. `corpus/fixtures/**` was not
written by this seat (the one `git status` entry there is SEAT-04's, per §3.1); `/tmp` was abandoned
after it hit its 16 G quota (§12).

## 12. Incidental finding — the C2 root cause reproduced in this seat

The brief's C2 says r103 root-caused gate failures to `/tmp` tmpfs quota pressure. This seat hit it
independently on its first command:

```
$ git archive HEAD corpus/fixtures | tar -x -C /tmp/s06det
tar: corpus/fixtures/r96_probe_iters.gd: Cannot write: Disk quota exceeded
... (~90 files)
$ df -h /tmp
tmpfs  16G  13G  3.1G  80%  /tmp
```

Scratch was moved to `reports/round-104/physics/s06/` (`/home`, 772 G free) and every subsequent
command succeeded. This is a **reproduction of the C2 defect from a second, independent path**
(not the gate script), and it corroborates that the `/tmp` default is the wrong workdir for this
lane's scratch — relevant to C2's `GATE_WORKDIR`/`TMPDIR` work even though that file is not this
seat's to edit.
