# r103 SEAT-33 — PHYSICS-ADVERSARY

**Seat:** SEAT-33 PHYSICS-ADVERSARY · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/physics/adversary.md`). Every other path read-only; the pinned tree was never modified (all mutations ran on throwaway copies under `/tmp/s33/`; `git status` shows no tracked path changed by this seat).
**Lane HEAD under test:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`)
**Subject:** the classification of battery row `phys3d_joints_free_ops` in receipt `corpus/live/runs/20261018T181301123479Z/verdicts.json` (336/350).

**Mandate.** Argue the investigator's classification is wrong, with evidence both ways, then deliver the ruled class and the evidence that would settle it.

**Investigator under test — SEAT-32, `reports/round-103/physics/investigate.md`** (landed mid-flight; its headline at `:17`):

> "**Class: harness-timeout (wall-clock starvation), not engine behaviour and not a fixture defect.** … it needs **~21–24 s of wall clock against the runner's hard `CASE_TIMEOUT_SECONDS = 20`**, and it spends only **~3.5 s of CPU** doing so."

with **sub-classification "load-sensitive margin"** (`:282`) and the summary *"the cause is the bound, not the fixture"* (`:286`).

The secondary source is SEAT-36 DISTILLER `reports/round-103/r103-distiller.md` §N3 (heading `:134`; the claim quoted at `:155`), which restates the row as *"it is a hang … the row produced its marker and then did not exit."*

**Ruled class (up front).** The row is **`INTRINSIC_WALL_COST`** — a **serial child-spawn budget overrun**, not "starvation" and not a "load-sensitive margin". The arm spawns **21 child Godot processes serially** (7 cases × 3 backends; `corpus/fixtures/phys3d_joints.gd:37–39` driving `_run_child` at `:88–90`, blocking via `OS.execute(..., false)` at `:135`). On this host a single headless Godot boot costs **0.76–0.94 s, median 0.90 s** (21-sample distribution, §2), so **21 boots × 0.90 s = 19.0 s — 95 % of the 20 s cap — before any case work runs at all.** The row therefore **cannot pass at the shipped bound on this host at any load**, and the binding term is the **fixed spawn count**, which load does not change. The runner's flat per-case constant is mis-scaled for a 21-child arm; that is the defect.

SEAT-32 and I **agree on most of the finding** — engine-behaviour `no`, host-capability `no`, "not a hard hang", and *the bound is the cause, not the fixture*. We disagree on the **mechanism name and the sub-class**, and those two disagreements change which fix is correct. I also **refute the distiller's §N3** outright (§4).

---

## 1. The arm does not hang — it finishes late (agreement with SEAT-32)

Reproduced independently, unmodified fixture, byte copy at `/tmp/s33/scratch`:

```
$ python3 -c "import subprocess,resource,time; t0=time.time(); \
  p=subprocess.run(['godot','--headless','--path','/tmp/s33/scratch','--script',\
  'res://phys3d_joints.gd','--','--arm=free_ops'],capture_output=True,text=True); \
  ru=resource.getrusage(resource.RUSAGE_CHILDREN); \
  print('wall %.2f cpu %.2f rc %d marker %s'%(time.time()-t0, ru.ru_utime+ru.ru_stime, \
  p.returncode, 'PASS phys3d_joints free_ops' in p.stdout))"
wall 22.08 cpu 4.29 rc 0 marker True
```

| run | wall | cpu (user+sys) | rc | marker emitted |
|---|---|---|---|---|
| 1 | 24.63 s | 3.75 s | 0 | yes |
| 2 | 22.08 s | 4.29 s | 0 | yes |
| 3 | 20.55 s | 3.53 s | 0 | yes |
| 4 (`ulimit -c 0`) | 20.55 s | 3.53 s | 0 | yes |

`rc=0` with the exact expected marker every time — matching SEAT-32's `21.097 s / 22.530 s` and its `FAIL→PASS` on raising the cap (`:122`). **A1 ("hang") is false**; SEAT-32 agrees.

## 2. Mechanism: 21 serial boots — not CPU starvation

Attribution by instrumenting a throwaway copy to timestamp each child around the `OS.execute` at `:135`:

```
TOTAL wall 20.95 cpu 3.73
sum child ms = 20225 n= 21        # per-child: 852–1695 ms, median ~910 ms
```

**Σ children = 20,225 ms of a 20,950 ms total (96.5 %).** The arm is nothing but 21 sequential child launches. Only outlier: crash cell `freeb_ops@gp` at 1695 ms `rc=134` SIGABRT — the documented teardown-UAF realization (`phys3d_joints.gd:45–72`, `BIMODAL["freeb_ops@gp"] = [6, 8]` at `:66`).

**The boot floor, 21 samples, no-op script** (`extends SceneTree / func _initialize(): quit(0)`):

```
ordered (s): 0.83 0.93 0.94 0.90 0.90 0.92 0.94 0.86 0.89 0.93 0.91 0.90 0.90
             0.86 0.76 0.91 0.89 0.85 0.81 0.90 0.90
steady samples min 0.758  median 0.903  max 0.941  mean 0.890
21 x steady-median floor = 19.0 s   (cap 20 s -> 95% of cap)
```

**Nineteen of twenty seconds are consumed by process launches alone, before any physics case executes.** This is the number that decides the class.

**Disproof of starvation.** "Starvation" asserts the arm is being denied CPU by competing load. If so, launching the same 21 boots *concurrently* would be **worse** than serially. It is 15× better:

```
PARALLEL 21 no-op: wall  1.00   cpu 4.45   cpu/wall 443%
SERIAL   21 no-op: wall 15.18   cpu 3.09   cpu/wall  20%
```

The cost is **latency**, not compute. `strace -c` on one no-op boot localises it:

```
% time     seconds  usecs/call     calls    errors syscall
 99.43   13.460804       25986       518        24 futex
  0.50    0.067852           1     46524       134 openat
```

**99.43 % of traced time in `futex`** — thread-pool spin-up and join at engine boot. The fixture's header already knows this floor is per-child: `const BOUND_S := 20` (`phys3d_joints.gd:29`) budgets **each child** 20 s while the runner budgets the **whole 21-child case** 20 s.

## 3. The budget is a monotone function of child count — and the margin is gone

From the receipt, every `phys3d_joints.gd` arm:

| arm | children | elapsed (s) | s/child | verdict |
|---|---|---|---|---|
| `sweep` | 3 | 3.64 | 1.21 | PASS |
| `rid` | 3 | 3.69 | 1.23 | PASS |
| `api` | 3 | 3.61 | 1.20 | PASS |
| `detach` | 3 | 4.13 | 1.38 | PASS |
| `chain3` | 3 | 5.75 | 1.92 | PASS |
| `twopin` | 6 | 9.40 | 1.57 | PASS |
| `free_pair` | 9 | 12.08 | 1.34 | PASS |
| **`free_ops`** | **21** | **20.01** | 0.95 | **FAIL** |

Elapsed rises monotonically with child count. `free_ops` is the only arm with ≥ 20 children and the only FAIL — and its own per-child rate (0.95 s) is the **lowest** in the table. The **fastest** per child still overruns, because there are 21 of them. That is a **count** problem, not a slowness problem.

**17 of 17 receipts** on this host that contain the row: all `FAIL`, all at the cap — 20.006, 20.008, 20.022 ×3, 20.023 ×7, 20.024, 20.025 — **never at a natural completion time**. Contrast `free_pair` (9 children): **9 of 9 PASS, 10.15–12.08 s** — same script, same backends, same host, same window. The discriminator is child count.

**Why "load-sensitive margin" is backwards.** SEAT-32's sub-class implies the row would pass on an idle host and fails only under load. But the floor is **19.0 s of a 20 s cap** measured on a load-12 host (§2), and the whole arm measured **20.55 s** in its best of four runs — the best case *clears the cap by 0.55 s*. r93's quiet-host figures (16.939 / 17.222 s, `r93-baseline.md:111`) are the only evidence the row can pass, and that was a host ~2 s faster per 21 boots. The honest statement is stronger than SEAT-32's: **on this host the row cannot pass at the shipped bound, at any load**, because its spawn floor alone consumes 95 % of the budget. Load moves it across the line only because the line was already inside the floor's error bar.

## 4. SEAT-32 got the field semantics right; the distiller's §N3 is false

Worth separating, because the distiller's restatement is the one that would propagate as the round's record.

`run_battery.py:1277–1278` stores two different things:

```
record = {"case": name, ..., "marker": marker, ...}   # :1277  <-- EXPECTED string, from CASES
"stdout": stdout.strip().splitlines(),                # :1278  <-- what was ACTUALLY observed
```

```
$ python3 -c "... fo=free_ops row; ok=free_pair row ..."
free_ops  stdout_lines 1   marker_in_stdout False   marker_len 3921
free_pair stdout_lines 3   marker_in_stdout True
```

The row's observed stdout is **one line** — the engine banner. `marker in stdout` → **False** (passing `free_pair` → True). So:

- **SEAT-32 is correct** (`:279`): the failure is `actual_exit=None` + `TIMEOUT after 20 seconds` *"with only the version banner on stdout"*.
- **SEAT-36 §N3 is false** on two counts: *"its captured marker text is present and well-formed"* — it is the **expected** string from `CASES:530–531`, never captured; and *"the row produced its marker and then did not exit"* — it produced **nothing but the banner** and was killed at 20.008 s. The runner's own reasons say so: `['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']`, and `classify()` (`:964–977`) raises `"exact stdout marker missing"` exactly when `marker not in lines`.
- The distiller's proposed cross-check — *"check whether the `e=`/`w=` counters in its marker show it stuck in the dummy-backend sweep"* — **cannot run**: those counters exist only inside the `CASES` expectation (9 `e=,w=` occurrences, 7 `@dummy` cells, all from expected text); the observed stdout has none. Same field-confusion, twice.

I flag this as a **correction to the round record**, not a defect in SEAT-32's work.

## 5. The strongest evidence *for* the investigator

On the record, since my ruling is the minority one:

1. **"The bound is the cause, not the fixture" is right**, and it is the finding that matters. `FAIL→PASS` on raising only `CASE_TIMEOUT_SECONDS` (`:122`), with `reasons: []`, is decisive that the fixture's *output* is correct. My ruling differs only in *which* part of the bound is wrong.
2. **"Not a hard hang" is right**, and it is the correction the row needed. Against the distiller's "it is a hang", SEAT-32 measured the completion. That is a genuine save.
3. **SEAT-32's §6 states my law in its own words** — *"21 × (cost of one headless Godot boot + ~12 physics ticks + teardown) ≤ 20 s, i.e. ≤ 0.95 s per child on average"*. That **is** the spawn-budget ruling. My disagreement is that the text then names the row "starvation"/"load-sensitive margin" rather than "a per-case constant mis-scaled for a 21-child arm", and picks R1 (a global cap raise) as the primary fix for a defect its own arithmetic locates in the scaling.
4. **Against myself.** My first working hypothesis was plain CPU starvation (from r102 `lesson-verify`'s 23.5 s-wall/2.7 s-CPU note). The parallel-vs-serial test (§2: 1.00 s vs 15.18 s) **refutes that** and refutes SEAT-32's "starvation" label with it: contention cannot make 21 serial boots 15× slower than 21 concurrent ones at 20 % CPU. I record this because it is the distinction the ruling turns on.
5. **Also against SEAT-32's own R3 estimate.** SEAT-32 predicts concurrent children give *"~5× wall reduction"* (`:325`). I measure **15×** (15.18 s → 1.00 s). Its R3 is **stronger than it claims** — it is not an optimisation but a class-eliminating fix (§6).

## 6. Ruled class, and what would settle it

**Ruled class: `INTRINSIC_WALL_COST` — serial child-spawn budget overrun.** Not `HANG` (A1 false: `rc=0` + exact marker at 20.9–24.6 s, §1). Not `ENGINE_BEHAVIOUR` (agreed). Not `HOST_CAPABILITY` (agreed). Not `STARVATION` (disproved: parallel 21 boots are 15× *faster* than serial, §2). The mechanism is **21 serial engine launches against a flat 20 s per-case constant**, a floor of 19.0 s measured before any case work.

**What would settle it (falsifiable, strongest first):**

1. **The scaling test — decisive.** Re-run the same arm with its child count reduced to 9 (the 3 non-crash cases × 3 backends, matching passing `free_pair`). Prediction under my ruling: **PASS at ~9–12 s**. Under "starvation"/"load-sensitive" the row should fail regardless of child count at equal load. Cheap: `ARM_CASES` (`phys3d_joints.gd:35–43`) is a table.
2. **The concurrency test.** Run the 21 children concurrently (SEAT-32's R3). Prediction: **~1.0 s** (§2 measured), i.e. a >10× margin — and a `PASS` inside the *existing* cap, which no cap-raise can demonstrate.
3. **The floor test.** 21 no-op boots on an idle host (load < 2). Prediction: still ≳ 12–16 s, i.e. still 60–80 % of cap with **zero** case work. If instead it collapses to ~2 s, my "intrinsic floor" reading is wrong and SEAT-32's margin reading stands.
4. **Counter-evidence that would overturn me:** a run of this exact arm on an idle host that **passes** with a floor-plus-work total well under 20 s, **and** a concurrent-child variant that is *not* faster than serial. That would restore either intrinsic CPU cost or a true hang.
5. **The nested-timeout confound — excluded.** The arm's `BOUND_S = 20` kills any single child at 20 s while the runner kills the whole case at 20 s. Measured per-child max is 1695 ms (§2), so no child approaches either bound. The two budgets do not fight here.

**Repair (not this seat's to apply — `corpus/fixtures/**` is protected and the brief scopes this row to investigation).** SEAT-32's R1/R2/R3 map onto my ruling as follows: **R3 (concurrent children) is the correct fix**, and my measurement strengthens it from "~5× optimisation" to "class-eliminating" (§5.5). **R2 (per-case bound proportional to child count)** is the correct conservative shape. **R1 (raise `CASE_TIMEOUT_SECONDS` 20→60 globally)** should **not** be the primary — it encodes the wrong model: it makes every row wait longer to mask a defect that only exists for arms whose cost scales with child count, and SEAT-32 itself flags the over-broadness (`:317`–`:320`). If R1 ships as a stopgap it must be dated and paired with R2/R3, not treated as the fix.

**One-line consequence for the ledger.** The row is a **spawn-budget overrun**: `n_children × ~0.9 s` against a constant authored for single-process fixtures. It is not a hang (distiller §N3, false on the receipt's own fields), not engine behaviour, not host capability, and not CPU starvation (15× faster when the children run concurrently). The class name matters because R1 and R3 are not interchangeable: one hides the overrun, the other removes it.

---

## 7. Reproduction

```sh
# §1 the arm finishes (unmodified fixture copy; ~21-25 s each)
mkdir -p /tmp/s33/scratch && cp -a corpus/fixtures/. /tmp/s33/scratch/
python3 -c "import subprocess,resource,time; t0=time.time(); \
  p=subprocess.run(['godot','--headless','--path','/tmp/s33/scratch','--script',\
  'res://phys3d_joints.gd','--','--arm=free_ops'],capture_output=True,text=True); \
  ru=resource.getrusage(resource.RUSAGE_CHILDREN); \
  print('wall %.2f cpu %.2f rc %d marker %s'%(time.time()-t0, ru.ru_utime+ru.ru_stime, \
  p.returncode, 'PASS phys3d_joints free_ops' in p.stdout))"

# §2 the boot floor (21 samples) and the parallel/serial disproof of starvation
printf 'extends SceneTree\nfunc _initialize():\n\tquit(0)\n' > /tmp/s33/scratch/noop.gd
mkdir -p /tmp/s33/scratch/c0 && printf '[application]\n\nconfig/name="c0"\n' > /tmp/s33/scratch/c0/project.godot
#   serial 21 no-op boots -> ~15-16 s (~20% CPU);  parallel 21 -> ~1.0 s (443% CPU)
timeout 30 strace -f -c -e trace=futex,openat,read godot --headless \
  --path /tmp/s33/scratch/c0 --script /tmp/s33/scratch/noop.gd   # 99.4% futex

# §3 child counts vs elapsed, straight from the receipt
python3 -c "import json,re; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json')); \
  src=open('corpus/fixtures/phys3d_joints.gd').read(); \
  arms={m.group(1):len(re.findall(r'\"(\w+)\"',m.group(2)))*3 \
  for m in re.finditer(r'\"(\w+)\":\s*\[([^\]]*)\]',src)}; \
  [print(a, arms.get(a), r['elapsed_seconds'], r['verdict']) for r in d['results'] \
   if r['script']=='phys3d_joints.gd' for a in [r['flags'][0].split('=')[1]]]"
for f in corpus/live/runs/*/verdicts.json; do python3 - "$f" <<'EOF'
import json,sys
d=json.load(open(sys.argv[1]))
for r in d.get('results',[]):
    if r.get('case')=='phys3d_joints_free_ops':
        print(sys.argv[1].split('/')[2], r['verdict'], r.get('elapsed_seconds'), r.get('error'))
EOF
done

# §4 the field confusion: marker is the EXPECTATION, stdout is the OBSERVATION
python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json')); \
  fo=[r for r in d['results'] if r['case']=='phys3d_joints_free_ops'][0]; \
  ok=[r for r in d['results'] if r['case']=='phys3d_joints_free_pair'][0]; \
  print('free_ops  stdout_lines', len(fo['stdout']), 'marker_in_stdout', fo['marker'] in fo['stdout'], 'marker_len', len(fo['marker'])); \
  print('free_pair stdout_lines', len(ok['stdout']), 'marker_in_stdout', ok['marker'] in ok['stdout'])"
sed -n '1277,1278p' corpus/fixtures/run_battery.py   # marker=expectation, stdout=observation
sed -n '36p' corpus/fixtures/run_battery.py          # CASE_TIMEOUT_SECONDS = 20
sed -n '29p' corpus/fixtures/phys3d_joints.gd        # BOUND_S := 20  (per CHILD)
sed -n '37,39p' corpus/fixtures/phys3d_joints.gd     # free_ops -> 7 cases x 3 backends

# §5 provenance: fixture bytes unchanged; host boot cost moved
git log --oneline -2 -- corpus/fixtures/phys3d_joints.gd    # b6ba234 (r91), 6420dc7 (r90)
git log --oneline -2 -- corpus/fixtures/r90_child.gd        # 6420dc7 (r90)
sha256sum corpus/fixtures/run_battery.py                    # f456bd00... unchanged since r100
```

**Provenance note.** The row passed at r100 (LOG `350/350`). It is a regression in *outcome*, not in bytes: `phys3d_joints.gd` and `r90_child.gd` are unchanged since r91/r90 and `run_battery.py`'s sha is still `f456bd00…`. What moved is the host's boot cost, which pushed a marginal row past a cap it had been within 3 s of since r93.

**Files written by this seat:** `reports/round-103/physics/adversary.md` (this file). Nothing else; no tracked path was modified.
