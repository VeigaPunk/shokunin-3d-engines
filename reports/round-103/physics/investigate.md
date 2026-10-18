# SEAT-32 — physics investigator: `phys3d_joints_free_ops`

Round r103. Seat scope: reproduce the battery row `phys3d_joints_free_ops` in
isolation, capture full output / failure reason / duration, classify the failure
(engine-behavior vs harness-timeout vs host-capability), and **propose (not
apply)** a fix sketch. Reference receipt:
`corpus/live/runs/20261018T181301123479Z/verdicts.json`.

Repo state at start: `c85a816` (r102 report-last; work `c6f655d`). No repo file
was modified by this seat except this report. Every command below was actually
run on this host; output is quoted as observed.

---

## 1. Headline

**Class: harness-timeout (wall-clock starvation), not engine behaviour and not a
fixture defect.** The arm is correct and deterministic — on a clean scratch it
emits the pinned marker **byte-for-byte** (3921 chars) and exits 0 — but it needs
**~21–24 s of wall clock against the runner's hard `CASE_TIMEOUT_SECONDS = 20`**
(`corpus/fixtures/run_battery.py:36`), and it spends only **~3.5 s of CPU** doing
so. Raising only that one constant makes the row **PASS** with an empty reason
list.

| | value | source |
|---|---|---|
| pinned cap | `CASE_TIMEOUT_SECONDS = 20` | `run_battery.py:36` |
| isolated elapsed (my run) | **21.097 s** | `/tmp/r103phys/evidence/t120-verdicts.json` |
| wall / CPU at a clean run | **22.530 s / 3.506 s** (user 2.413 + sys 1.093) | `/tmp/r103phys/evidence/cpu.log` |
| wall−CPU gap | **19.023 s** (≈84 % of wall) | same |
| child processes spawned by the arm | **21** (7 cases × 3 backends) | `phys3d_joints.gd:37-39`, `:88-93` |
| host | 32 cores, load avg 5–18 during this seat | `/proc/loadavg` |

---

## 2. The runner's isolation flag (read from source first)

The seat brief asked for the runner's `--only`/`--case` flag read from source
before use. From `corpus/fixtures/run_battery.py:1229`:

```python
parser.add_argument("--only", default="", help="comma-separated case names to run")
```

There is no `--case`; selection is `--only=<name>` (comma-separated), and an
unknown name is a hard `return 1` (`:1255-1260`). Single-case invocation:

```bash
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs <dir>
```

---

## 3. Reproduction at the shipped bound (the r102 receipt's own configuration)

Reference row from `corpus/live/runs/20261018T181301123479Z/verdicts.json`
(index 221 of 350; sha256 `58f48585ded496945557c3936e38b0c7c26d237d067b50304281cd7be98b4d5e`):

```
elapsed_seconds: 20.008   actual_exit: None   expected_exit: 0   verdict: FAIL
error:   "TIMEOUT after 20 seconds"
reasons: ["TIMEOUT after 20 seconds",
          "no exit code (process killed or timed out)",
          "exact stdout marker missing"]
stdout:  ["Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org"]
stderr:  []
kind:    "ordinary"
```

**Full output.** The parent printed exactly one line — the Godot version banner —
and nothing else, on both streams. No `M`-prefix rows, no `PASS`/`FAIL` line, no
error. The parent was killed by `subprocess.run(..., timeout=20)` while still
inside its child loop; the 20 s budget had already been consumed.

**Isolated reproduction, identical result.** Running the shipped runner with
`--only` on this still-loaded host:

```
FAIL     phys3d_joints_free_ops   phys3d_joints.gd   --arm=free_ops   None/0   ordinary
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
```

**Historical frequency — 26/26 FAIL.** Scanning every stored receipt under
`corpus/live/**/verdicts.json` that contains this row:

```
receipts containing the row: 26
isolated (--only) receipts:  17
Counter({('FAIL', None, 'TIMEOUT after 20 seconds'): 26})
```

All 26 show the same triple (`FAIL`, `actual_exit=None`, `TIMEOUT after 20
seconds`); all 17 single-case attempts (r102 seats + r103 seats, timestamps
`175115…`→`183504…`) show it too. **On this host, isolated execution has never
once passed at the shipped bound** — including the r102 run that
`reports/round-102/r102-report.md:449` records as an *"Idle-host close-out run
(2026-10-18T18:13Z)"*. Two observations weaken that reading. (a) That scratch has
been reused by later lanes: its `free_ops` child logs now carry mtimes
`15:34:21`–`15:34:32` local while its `verdicts.json` was written at `15:26:08`
local (= `18:26:08Z`, 13 min after the `18:13:01Z` start) — so the tree as it
stands today is not a witness to that run. (b) Stronger: the 17 isolated
`--only` attempts across r102 and r103 all failed at the 20 s bound, so the
receipt is not a reproduction of an idle-host pass either way.

---

## 4. Reproduction with the bound raised — the decisive experiment

Copy the seed tree to `/tmp`, raise **only** line 36, and prove the patch is a
one-token change:

```bash
mkdir -p /tmp/r103phys/seeds && cp -a corpus/fixtures/. /tmp/r103phys/seeds/
rm -rf /tmp/r103phys/seeds/__pycache__
sed -i 's/^CASE_TIMEOUT_SECONDS = 20$/CASE_TIMEOUT_SECONDS = 120/' /tmp/r103phys/seeds/run_battery.py
diff -q <(sed 's/CASE_TIMEOUT_SECONDS = 120/CASE_TIMEOUT_SECONDS = 20/' /tmp/r103phys/seeds/run_battery.py) \
        corpus/fixtures/run_battery.py
# -> no output; the patched tree differs from the seed ONLY in that constant
python3 /tmp/r103phys/seeds/run_battery.py --only phys3d_joints_free_ops --runs /tmp/r103phys/t120
```

Result (receipt `/tmp/r103phys/evidence/t120-verdicts.json`, sha256
`3318c5d3bc30a866e1c7512b20d2e0aa1bba10dd130d14ffd1575bf4bff803bd`):

```
PASS phys3d_joints_free_ops: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: /tmp/r103phys/t120/20261018T183537019909Z/verdicts.json
real 0m21.221s   user 0m2.684s   sys 0m1.225s
```

Row fields from that receipt:

```
case_timeout_seconds: 120
elapsed_seconds:      21.097
actual_exit:          0
verdict:              PASS
reasons:              []
stdout lines:         3      stderr lines: 0
pinned marker present verbatim in stdout: True
seeds_unchanged:      True
```

**The only difference between FAIL and PASS is the timeout constant.** Nothing in
the fixture changed; the marker matched exactly. The 21.097 s elapsed sits
**1.1 s above the 20 s cap** — a ~5 % margin.

---

## 5. The arm is correct: marker byte-equality on a clean scratch

To rule out the possibility that a *slow but wrong* arm would "pass" under a
longer bound, the arm was run directly on a fresh copy and its stdout compared
byte-for-byte against the marker pinned in `CASES` (`run_battery.py:530-531`):

```bash
D=$(mktemp -d /tmp/r103phys/direct.XXXXXX); cp -a corpus/fixtures/. "$D"/
/usr/bin/godot --headless --path "$D" --script res://phys3d_joints.gd -- --arm=free_ops
```

```
scratch /tmp/r103phys/direct.ORnARK   PASS lines 1
MARKER EQUAL TO PINNED: True   len 3921 3921
rc=0   stderr 0 bytes   child logs: 21
```

So on a **clean** scratch the parent emits the exact pinned 3921-char marker and
exits 0. (A re-run against the *already-used* r102 scratch — which contains the
`r90bt_*` child dirs left by earlier seats' runs — produced the same rc=0 but a
*different* marker: three cells differed (`freeb_world@jolt` empty, two Dummy
cells reporting `engine=DEFAULT`). That is scratch-reuse noise in the child
project files, not a second defect class; it is why every measurement in §4–§6
uses a fresh copy.)

The three `mode_ok`/`sha` cells that carry the physics content (`freeb_ops@gp`,
`@jolt`, `@dummy` in the Dummy row above) are pinned in the marker itself, so a
physics drift would show as a marker mismatch, not as a timeout.

### 5.1 A weaker secondary observation (recorded, not promoted)

One direct clean run emitted a marker in which `freeb_world@jolt` and
`detachb_free@jolt` were **empty** (`rc=0,m=`) and three Dummy cells reported
`engine=DEFAULT` instead of `engine=Dummy`; that run still **matched the pinned
marker exactly** (3921 chars). The 21-child timeline for it shows a regular
~0.9 s cadence with no child truncating:

```
r90bt_free_ops_freeb_ops_gp    3001 bytes    0 ms
r90bt_free_ops_freeb_ops_jolt  1798 bytes  893 ms
... (21 children, regular ~0.9 s spacing)
r90bt_free_ops_detachb_free_dummy 218 bytes 19237 ms
span first->last child.log mtime: 19.237 s
```

Because the pinned marker is the authority and it matched, I treat this as
**unconfirmed** — a single sample of an output that the pin nevertheless
accepts. I flag it only because the *same* cells are the ones that differed on
the reused scratch, which hints the per-child `project.godot` write
(`phys3d_joints.gd:122-127`) can occasionally be read empty by the child. **This
is not part of the r103 classification** and needs its own seat if anyone wants
to chase it; it does not affect the timeout verdict, which reproduces with the
pinned marker intact.

---

## 6. Starvation accounting — where the 20 s goes

The arm is a **serial spawner of 21 full Godot processes**. From
`corpus/fixtures/phys3d_joints.gd`:

```gdscript
const BOUND_S := 20                       # :29  per-child bound
const BACKENDS := [["gp", ""], ["jolt", "Jolt Physics"], ["dummy", "Dummy"]]   # :30
"free_ops": ["freeb_ops", "freeb_twice", "freeb_make",
             "freeb_world", "freeb_afterclear", "freej_then_b",
             "detachb_free"],            # :37-39  seven cases
...
for case in ARM_CASES[arm]:
    for bk in BACKENDS:
        var d := _run_child(case, bk[0], bk[1])      # :88-90  blocking, serial
```

and `_run_child` shells out per cell (`:131-135`):

```gdscript
var cmd := ("timeout -s KILL %d \"%s\" --headless --path \"%s\""
        + " --script \"%s\" -- %s > \"%s\" 2>&1") % [BOUND_S, ...]
var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
```

`OS.execute(..., blocking=true)` serialises all 21 children inside the **single**
parent that the runner bounds at 20 s. The arithmetic is therefore 21 × (cost of
one headless Godot boot + ~12 physics ticks + teardown) ≤ 20 s, i.e. **≤ 0.95 s
per child on average**.

Measured per-child boot cost on this loaded host:

```
bare_boot_1 = 3489 ms
bare_boot_2 = 1437 ms
bare_boot_3 =  872 ms
```

A bare `godot --headless --quit` on an empty project costs **0.9–3.5 s** here
before any fixture work happens. Twenty-one of those do not fit in 20 s.

Measured CPU vs wall for the whole arm (`resource.getrusage(RUSAGE_CHILDREN)`):

```
rc 0   wall 22.530   user 2.413   sys 1.093   cpu_total 3.506   wall-cpu gap 19.023
stdout lines 3   marker line startswith PASS: True   stderr bytes 0   n children 21
loadavg 18.33 13.37 12.52   nproc 32
CAP = 20.000 s (run_battery.py:36)
```

**3.5 s of CPU inside 22.5 s of wall.** The arm is ~84 % blocked waiting on
process spawn + scheduler, not computing. That is the definition of a
wall-clock-starved harness row, and it is why the result is load-sensitive:
r92/r93 recorded 16.94 s / 17.22 s for the same row, i.e. it has *always* been
the slowest row in the corpus and *always* within a second or two of the cap
(`reports/round-93/r93-baseline.md:147`, `reports/round-92/r92-critic.md:54`).

### 6.1 Why "host-capability" is the wrong label

The host is not incapable: 32 cores, and the children are serial by construction,
so extra cores cannot help. The 19 s gap is *self-inflicted serialisation* plus a
hard-coded 20 s ceiling, not a missing capability (no GPU/editor needed — the
fixture is headless and every child is a plain `SceneTree` script). The failure
mode is a **harness budget** problem.

---

## 7. Classification

| candidate | verdict | evidence |
|---|---|---|
| **engine-behaviour** | **no** | clean-scratch run emits the pinned marker byte-for-byte (3921/3921) and exits 0; a physics drift would appear as a marker mismatch, and the `mode_ok`/`sha` cells are pinned inside the marker (§5) |
| **harness-timeout** | **yes** | FAIL→PASS flips on raising `CASE_TIMEOUT_SECONDS` 20→120 alone, with `reasons: []` (§4); failure is `actual_exit=None` + `TIMEOUT after 20 seconds` with only the version banner on stdout (§3) |
| **host-capability** | **no** | 32 cores; children are serial (`OS.execute(..., blocking=true)`); 3.5 s CPU vs 22.5 s wall — starvation, not missing capability (§6) |

**Sub-classification: load-sensitive margin.** The row is not a hard hang — it
completes in 21.1 s when allowed to. It is a ~1 s margin against a 20 s cap on a
host whose bare Godot boot alone costs 0.9–3.5 s. r93 saw it pass at 16.9 s and
17.2 s; every r102/r103 attempt on the current load saw it fail. The honest
statement is: **on this host today the row cannot pass at the shipped bound**,
and the cause is the bound, not the fixture.

---

## 8. Fix sketch — PROPOSED, NOT APPLIED

Nothing below was applied. `corpus/fixtures/**` is not this seat's to edit (the
r102 round context also routes battery edits to an operator queue rather than a
silent mid-round change).

**R1 (primary, one token) — raise the case bound above the arm's real cost.**
`corpus/fixtures/run_battery.py:36`: `CASE_TIMEOUT_SECONDS = 20` → **`= 60`**.
Justification: the measured need is 21.1 s here and 17.2 s at r93, so 60 s gives
~3× headroom over the worst observed value while staying far below any hang
signature (the corpus's documented hang rows are bounded at 8 s and its
crash-child probes at 6–15 s inside their own fixtures, so a 60 s cap does not
mask them — they fail on their own internal bounds first).
**Caveat:** this is a *global* constant shared by all 350 rows; raising it also
raises the ceiling for every other row, so it changes the failure semantics of
the whole battery. That is why it belongs to the operator, not to a lane seat.

**R2 (targeted, preferred if R1 is judged too broad) — give the parent a bound
proportional to its child count.** The defect is structural: a fixture whose
runtime is `n_children × child_cost` is compared against a constant that was
authored for a single-process fixture. Sketch (design only, not written):

- add an optional per-case timeout override to the `CASES` tuple, or a small
  `CASE_BOUNDS = {"phys3d_joints_free_ops": 90}` map consulted by `execute()`;
- set it only for the arm-spawning rows (`phys3d_joints_free_ops` = 21 children;
  `phys3d_joints_free_pair` = 9; `phys3d_joints_twopin` = 6) using the measured
  0.9 s/child figure × 3 headroom.
This keeps every other row's semantics untouched and makes the fix proportional
to the actual cost model.

**R3 (orthogonal, removes the failure mode entirely) — stop serialising the
children.** `OS.execute("/bin/sh", ["-c", cmd], [], false)` is blocking, so the
parent pays 21 sequential boots. Launching the children concurrently (background
`OS.create_process` per cell, then poll the logs and join) would collapse the
21 × boot cost to roughly one boot plus the longest child — an expected ~5× wall
reduction — and would put the row comfortably inside the *existing* 20 s cap.
Cost: a real rewrite of `_run_child`/`_run` in `phys3d_joints.gd` (the file is
not this seat's to edit), plus new determinism reasoning for the per-child
`res://r90bt_*` scratch dirs (they are already namespaced by
`arm_case_backend`, so they do not collide — `phys3d_joints.gd:118`).

**R4 (do not do this) — re-baseline the marker or drop the row.** The marker is
correct and byte-stable; deleting or weakening it would discard real physics
coverage (7 freed-endpoint families × 3 backends) to hide a budget bug. Explicitly
not recommended.

**Recommendation:** R1 as the operator-level stopgap (documented, dated), R2 as
the correct shape, R3 as the durable fix. R2+R3 together would let the row keep a
bound near its peers'.

---

## 9. What this seat did and did not establish

**Established (each with a command run here):**
- the row reproduces at the shipped bound in isolation (`--only`), and has
  **never** passed on this host: 26/26 stored receipts FAIL (§3);
- raising only `CASE_TIMEOUT_SECONDS` makes it PASS with `reasons: []`, marker
  verbatim, `seeds_unchanged: true` (§4);
- on a clean scratch the arm emits the pinned 3921-char marker and exits 0 (§5);
- the arm spawns 21 serial children inside one 20 s bound, and burns 3.5 s CPU
  inside 22.5 s wall (§6);
- bare Godot boot on this host is 0.9–3.5 s, so 21 boots cannot fit in 20 s (§6).

**Not established / limits:**
- I did **not** observe a pass at the shipped 20 s bound on any host; the
  "idle host would pass it" reading (r93's 16.9/17.2 s, r102 peer reports) is
  consistent with my measurements but is *their* datum, not mine — this seat's
  own 20 s runs all failed;
- the R1/R2/R3 sketches are **design only**; none was implemented, so their
  effect sizes (especially R3's "~5×") are estimates from the measured boot cost,
  not measurements;
- no claim is made about any Unreal runtime, editor, or live MCP behaviour —
  none is involved here and the editor is not installed;
- §5.1's empty-cell observation is a single sample that the pin nevertheless
  accepts; it is recorded as an unconfirmed curiosity, not a finding.

**Evidence kept:** `/tmp/r103phys/evidence/` — `t120-verdicts.json` (the PASS
receipt at bound 120), `t120.log`, `direct-clean.out` (the clean-scratch marker),
`cpu.log`, `measure.log`, `shas.txt`.

**Seed integrity (for the round's byte-pin discipline):**

```
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  corpus/fixtures/phys3d_joints.gd
84f6241de590b5810357dde7714a19ec37e3072526e165e4c3ac8a8010d9aaa7  corpus/fixtures/r90_child.gd
```

`git diff -- corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
corpus/fixtures/r90_child.gd` is empty — the seeds are byte-untouched by this
seat; the only patched copy lives in `/tmp`.

**One operational hazard observed (not caused by this seat).** During this seat
another lane ran `godot --headless --path . --script res://phys3d_joints.gd --
--arm=free_ops` with `--path .` pointing at the **repo root**. That briefly wrote
`corpus/fixtures/r90bt_free_ops_*/` (21 untracked dirs, seen in `git status` at
15:36:40). The dirs vanished within seconds when that run's scratch `project.godot`
took effect, and `corpus/fixtures/` is clean again now (`git status --porcelain --
corpus/fixtures/` → only another seat's `three/README.md`). Recording it because a
`--path .` invocation against the seed tree is exactly the shape that would mutate
byte-pinned fixtures if its scratch write ever failed.
