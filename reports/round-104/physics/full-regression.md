# r104 SEAT-07 — FULL-REGRESSION: the patched tree, whole battery

**Seat:** SEAT-07 FULL-REGRESSION · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only. `corpus/fixtures/**` was read, never written — every
run below executed the battery's own scratch copy of the seeds.
**Claim served:** C1 (depth) — the acceptance evidence for the `phys3d_joints_free_ops`
wall-cost fix. **No Unreal runtime claim is made here**; Unreal Editor is not installed on
this host and this seat says nothing about it.

---

## 1. Headline

On the **patched** tree the full 350-row battery returns **337 pass / 13 fail**, and every
acceptance criterion the seat brief set is met:

| acceptance criterion | required | observed | verdict |
|---|---|---|---|
| `phys3d_joints_free_ops` now PASSes | PASS | PASS, `exit=0`, 2.769 s | **MET** |
| all 336 previously-passing rows still PASS | 336/336 | 336/336 | **MET** |
| the 13 `r94_cannon_*` rows unchanged | same failure class | 13/13 `exit=0` + `exact stdout marker missing` | **MET** |
| `seeds_unchanged` | `true` | `true` | **MET** |
| regressions introduced | 0 | 0 | **MET** |

The 14 → 13 fail count is **one** fixed row and **thirteen** untouched rows. No row changed
class in either direction except `phys3d_joints_free_ops`, which moved FAIL → PASS.

---

## 2. Receipts and tree state

**Post-patch receipt (the deliverable)** — copied into the lane so it is discoverable
alongside this report; the copy is byte-identical (`sha256` re-verified after `cp`):

```
reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json
sha256 5daeb6f9cbb863d26093e9266ab5dcfb2875ee5207af6c2046327dfd147f9293

reports/round-104/physics/full-regression-runs/20261018T194637610772Z-battery.stdout
sha256 c414c3041d5ff081b60be9bc28d274bfcf9c15acf597661ce5f7ee3bb1c6ae38
```

The live original is `/home/vgpnk/.cache/s07/runs-after/20261018T194637610772Z/verdicts.json`;
only `verdicts.json` and the runner's stdout are copied — the 37 M `scratch/` tree stays out
of the repo.

**Command actually run** (the counting command the brief names):

```
$ python3 corpus/fixtures/run_battery.py
```

with `--runs /home/vgpnk/.cache/s07/runs-after`. `/tmp` was unusable for this run — see §5.

**Baseline (r102 lane receipt, the before):**

```
corpus/live/runs/20261018T181301123479Z/verdicts.json     336 pass / 14 fail
```

**Tree digests at the moment of the run** — read back from the receipt's own
`seed_digests`, not re-derived afterwards:

| file | sha256 | note |
|---|---|---|
| `corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | **unchanged** — the pinned `CASES` marker literal never moved |
| `corpus/fixtures/phys3d_joints.gd` | `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6` | SEAT-04's R3 patch |

```
$ python3 -c "import json;d=json.load(open('…/20261018T194637610772Z/verdicts.json'));\
  print(d['seed_digests']['run_battery.py']); print(d['seed_digests']['phys3d_joints.gd'])"
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6
```

Host: `plazir27`, Linux `7.2.3-arch1-3`, `nproc` = 32, `/usr/bin/godot` =
`4.7.2.stable.arch_linux.ed1daf0bf`.

**Patch under test** (`git diff -- corpus/fixtures/phys3d_joints.gd`, 41 lines changed).
R3 — spawn all children first, then collect in the original order:

```gdscript
const BATCH_BOUND_S := 16                       # new, beside BOUND_S at :29
    var jobs: Array = []
    for case in ARM_CASES[arm]:
        for bk in BACKENDS:
            var j := _spawn_child(case, bk[0], bk[1])   # OS.create_process
            …
    var deadline := Time.get_ticks_msec() + BATCH_BOUND_S * 1000
    for j in jobs:
        while OS.is_process_running(j["pid"]) and Time.get_ticks_msec() < deadline:
            OS.delay_msec(5)
        if OS.is_process_running(j["pid"]):
            OS.kill(j["pid"])
            return _fail("%s@%s batch_timeout" % [j["case"], j["bk"]])
        …
        _emit(j["case"], j["bk"], d)
```

`CASE_TIMEOUT_SECONDS` in `run_battery.py:36` is **still 20**. The fix is concurrent
children, not a raised cap — the r103 ruling's preferred branch.

---

## 3. The comparison, row by row

```
$ python3 /home/vgpnk/.cache/s07/compare.py \
      /home/vgpnk/.cache/s07/runs-after/20261018T194637610772Z/verdicts.json
```

```
baseline …/20261018T181301123479Z/verdicts.json  verdict=FAIL totals={'cases': 350, 'pass': 336, 'fail': 14, …} seeds_unchanged=True timeout=20
patched  …/20261018T194637610772Z/verdicts.json  verdict=FAIL totals={'cases': 350, 'pass': 337, 'fail': 13, …} seeds_unchanged=True timeout=20

rows baseline=350 patched=350 missing_from_patched=[] added=[]

baseline FAIL (14): ['phys3d_joints_free_ops', 'r94_cannon_backends', 'r94_cannon_bailout',
                     'r94_cannon_det', 'r94_cannon_det2', 'r94_cannon_friction',
                     'r94_cannon_material', 'r94_cannon_modes', 'r94_cannon_nan',
                     'r94_cannon_order', 'r94_cannon_parity', 'r94_cannon_parity2',
                     'r94_cannon_sync', 'r94_cannon_varstep']
patched  FAIL (13): ['r94_cannon_backends', 'r94_cannon_bailout', 'r94_cannon_det',
                     'r94_cannon_det2', 'r94_cannon_friction', 'r94_cannon_material',
                     'r94_cannon_modes', 'r94_cannon_nan', 'r94_cannon_order',
                     'r94_cannon_parity', 'r94_cannon_parity2', 'r94_cannon_sync',
                     'r94_cannon_varstep']

NEWLY PASSING (fixed) [1]: ['phys3d_joints_free_ops']
NEWLY FAILING (regressed) [0]: []
```

### 3.1 Acceptance block, verbatim from the tool

```
=== ACCEPTANCE ===
  free_ops_now_PASS = True
  all_prev_pass_still_pass = True
  prev_pass_that_broke = []
  cannon_baseline_fail_count = 13
  cannon_patched_fail_count = 13
  cannon_same_class = True
  cannon_class_diffs = []
  seeds_unchanged = True
  non_cannon_other_fails = []
```

`cannon_same_class` is computed as equality of the `(actual_exit, reasons)` tuple per row,
not merely of the verdict string — so "same class" means `exit 0` **and** the identical
reason list `['exact stdout marker missing']`, row for row.

### 3.2 The fixed row

```
free_ops: PASS exit=0 elapsed=2.769 reasons=[]
```

The row's stdout carries exactly one `PASS phys3d_joints free_ops …` line, **3921 bytes**,
and it is byte-identical to the pinned literal:

```
$ python3 -c "…print(line==r['marker'], sha256(line).hexdigest())"
stdout line == marker literal: True
706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74
```

That digest equals the r104 SEAT-03 marker bank's pin for this row
(`reports/round-104/physics/markers.md`: `phys3d_joints_free_ops`, 3921 bytes,
`706ad9151452e18d…`). The fix therefore moved the **wall clock only**; not one byte of the
marker changed. The same literal is byte-identical between the baseline and patched
receipts:

```
baseline marker sha: 706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74
patched  marker sha: 706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74
marker identical: True
```

### 3.3 The 13 cannon rows — unchanged, and unchanged for a known reason

All 13 fail identically in both receipts: `exit 0` with
`reasons=['exact stdout marker missing']`. The divergence is the **node version token** the
fixture interpolates into its PASS line:

```
patched  stdout: PASS r94_cannon det node=v26.12.0 det_base{rc=0,m=M0 case=det_base …
baseline stdout: PASS r94_cannon det node=v26.12.0 det_base{rc=0,m=M0 case=det_base …
```

`corpus/fixtures/r94_cannon.gd:127` probes `node --version` through the inherited `PATH`
and prints the result into the marker, while the `CASES` literal pins `node=v24.21.0`. Both
versions are live on this host — mise `latest` → `v26.12.0`, fnm multishells →
`v24.21.0` — and PATH order decides. This is **environment drift, not a fixture defect**,
and it is orthogonal to C1: the physics fix neither causes nor cures it. Observed live
during this round: a peer run at `19:05` passed all 13 (PATH resolved `v24.21.0`), the next
at `19:06` failed all 13. The class is unchanged from the r102 baseline, which is what the
acceptance asks for.

### 3.4 Wall clock

| row | baseline (s) | patched (s) |
|---|---|---|
| `phys3d_joints_sweep` | 3.636 | 1.978 |
| `phys3d_joints_rid` | 3.685 | 1.962 |
| `phys3d_joints_api` | 3.607 | 1.909 |
| `phys3d_joints_free_pair` | 12.078 | 2.786 |
| **`phys3d_joints_free_ops`** | **20.008 (cap, killed)** | **2.769** |
| `phys3d_joints_detach` | 4.133 | 2.073 |
| `phys3d_joints_chain3` | 5.753 | 2.922 |
| `phys3d_joints_twopin` | 9.403 | 2.513 |

The 8 `phys3d_joints` rows together fall from **62.303 s to 18.912 s — a 3.29× reduction**.
Whole-battery elapsed 787.63 s → 769.41 s; the modest total movement is expected, since the
physics block is 8 of 350 rows. `free_ops` now sits at 13.8 % of its 20 s bound, restoring
the ~7× margin the row had in r93 (17.802 s) and better.

---

## 4. What this receipt does and does not establish

- **Establishes:** on this host, with these exact seed digests, the concurrent-children
  fix removes the `free_ops` budget underrun while leaving every other row's verdict, every
  cannon failure class, and the pinned marker byte-identical. `seeds_unchanged=true` with a
  130-entry digest map taken before and after the run.
- **Does not establish:** anything about Unreal Engine (editor not installed). Nothing about
  other hosts' CPU counts — the win is a function of spare cores; on a 1-core host R3 would
  not help, though `BATCH_BOUND_S` would then fail closed with a named `batch_timeout`
  rather than a silent timeout.
- **Not a determinism claim.** Byte-identity of the marker is asserted here as *observed* on
  this run. The independent pre/post byte-identity probe is SEAT-06's
  (`reports/round-104/physics/determinism.md`); this seat did not re-run it.

### 4.1 The patch moved under this run — recorded, and the row is not affected

The fixture changed **twice** while this seat's runs were in flight:

| time (local) | `phys3d_joints.gd` | change |
|---|---|---|
| 16:20:21 | `c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc` | R3 spawn/collect |
| 16:35:06 | `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6` | `+ BATCH_BOUND_S := 16` |

The **authoritative run reported above is on the final digest `80bf44c5…`** — the receipt's
own `seed_digests` entry proves it, and the digest was re-checked after the run and was
unchanged. `phys3d_joints_free_ops` is row 222 of 350 and is the fifth of the eight
`phys3d_joints` rows, so it executed under the final bytes. An earlier attempt that died
(§5) had started on `c7e77638…`; it produced no receipt and is not reported as evidence.

---

## 5. Two environment findings the round should carry (C2 evidence, not a claim of mine)

This seat set out to run one battery and instead reproduced the C2 defect class twice.
Both are recorded here because they are *observed*, with commands, and because they cost
this seat three failed attempts.

### 5.1 `/tmp` is quota-exhausted — writes fail while `df` reports space

```
$ echo hi > /tmp/s07/x.out
/bin/bash: line 1: echo: write error: Disk quota exceeded
EXIT=1

$ python3 -c "print('hello')" > /tmp/s07/y.out ; echo $?
120
$ python3 -c "print('hello')" > /home/vgpnk/.cache/s07/y.out ; echo $?
0
```

`/tmp` is mounted `rw,nosuid,nodev,nr_inodes=1048576,inode64,huge=advise,usrquota` — a
**per-user quota** on a shared 16 G tmpfs. At the time of writing `df -h /tmp` reports
`16G … 3.1G Avail 80%` and `df -i` reports 64 % inodes used, i.e. **the failure is
invisible to both `df` invocations**. A trivial 1 KiB write still fails:

```
$ python3 -c "open('/tmp/s07/big.bin','wb').write(b'x'*1024)"
OSError: [Errno 122] Disk quota exceeded
```

The battery's own scratch copy is what trips it — `shutil.copytree` of the seed dir copies
23 M `three/` + 6.8 M `r95vendor/` per run:

```
$ python3 corpus/fixtures/run_battery.py --runs /tmp/s07/dbg --only phys3d_joints_rid
shutil.Error: […/r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so, …, "[Errno 122]
  Disk quota exceeded: …"]
EXIT=1
```

This is the terminal form of the r103 root cause ("`/tmp` 16 G tmpfs quota pressure silently
breaking `mktemp`/clone"), now reproduced with a one-line reproducer. **Workaround used by
this seat:** every path under `$HOME` (769 G free) plus `TMPDIR` exported there. The
unmodified runner needs no change for this — `--runs` already accepts an absolute path
outside `/tmp`, and the receipt records the scratch location.

### 5.2 A killed attempt exits 120 with no receipt and no message

Three attempts died at **exit 120** producing neither a receipt nor anything on stderr —
the first after 7 minutes under host contention (load average 59 on 32 cores, 20 peer
`run_battery.py` processes), the second and third within seconds once `/tmp` was exhausted.
Exit 120 is what Python reports when the interpreter cannot flush stdout at exit; combined
with §5.1 that fully explains it (stdout was redirected into `/tmp`). A re-run via `runpy`
with stdout inherited completed the row normally, which is how the runner was cleared of
suspicion. **A battery invocation that redirects stdout into an exhausted filesystem can
therefore fail with no diagnostic at all** — worth a line in whatever flake harness C2
lands, since it is indistinguishable from a crash without the reproducer above.

---

## 6. Reproduction

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
mkdir -p "$HOME/.cache/s07/runs"
TMPDIR="$HOME/.cache/s07/tmp" python3 corpus/fixtures/run_battery.py \
    --runs "$HOME/.cache/s07/runs"
# -> FAIL battery: …/verdicts.json   (totals: cases=350 pass=337 fail=13)
#    the FAIL is the 13 node-pin cannon rows; free_ops is PASS.
```

The comparison tool used for §3 is `/home/vgpnk/.cache/s07/compare.py`; it reads the r102
baseline path directly and prints the acceptance block verbatim. It was validated against
the baseline receipt against itself first (self-diff: 0 fixed, 0 regressed, all criteria
consistent), so a clean diff is meaningful rather than vacuous.
