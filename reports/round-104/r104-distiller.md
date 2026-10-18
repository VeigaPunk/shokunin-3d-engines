# r104 SEAT-23 — DISTILLER (mid-flight synthesis)

**Seat:** SEAT-23 DISTILLER · round 104 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only (`reports/round-104/r104-distiller.md`). No other path was
written by this seat; every probe below is read-only or writes only to `/dev/shm` and `/tmp` scratch
outside the repo.
**Lane HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103 report-last; work `8c9d9ad`).
HEAD did not move during this seat's window — all movement below is **worktree** movement.
**Probe window:** 2026-10-18 ~19:16Z → ~19:29Z (host local 16:16 → 16:29, UTC−3).
**This is a mid-flight document.** Sibling seats were landing writes the whole time; §0 and §5 record
what moved under this seat. Every claim below carries the command run and the output observed.

**Axes.** depth · coverage · calibration. No Unreal runtime claim is made anywhere — Unreal Editor is
not installed on this host, and nothing below asserts live-editor behaviour.

---

## 0. Bottom line

All three claims **landed mid-flight**, and every one of them moved **while this seat measured it** —
which is itself the round's most important process fact.

| claim | state at 19:16Z (probe start) | state at ~19:29Z (probe end) | evidence |
|---|---|---|---|
| **C1** physics wall-cost | **unlanded** — `run_battery.py` `f456bd00…`, `CASE_TIMEOUT_SECONDS = 20` at `:36`; the row reproduces the r103 FAIL | **LANDED mid-flight** — `phys3d_joints.gd` `c7e77638…` (`M`), R3 concurrent children; row PASSes, all 8 arms PASS | §1 |
| **C2** gate workdir resilience | **unlanded** — `run_gate.sh` `577c8b54…`, bare `mktemp` at `:74`/`:86`, no `GATE_WORKDIR`/`TMPDIR` anywhere | **PARTIALLY landed mid-flight** — `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}`, validated; the `mktemp`-failure and clone branches guarded, **the write-failure branch is not** | §2 |
| **C3** SKILL decision table | **absent** — no lane-level `SKILL.md` exists (seed form, `README.md:10-11`) | **LANDED mid-flight** — `SKILL.md` 174→182 lines (`1055a52f…` → `de8ada36…`), table at `:20`, rows A–E; box 1 still `[ ]` pending a non-author verifier | §3 |

**The headline finding of this round is C2's, and it is not the one the brief anticipated.** The
brief said `/tmp` pressure *silently breaks* `mktemp`/`clone`. Measured directly: `mktemp` **does not
fail** — it succeeds and returns a **0-byte file**. What fails is the *write into it*, and the gate's
code could not tell that from a genuine manifest divergence. This seat reproduced the flake
**10/10 times** on the shipped bytes (§2.2) and isolated the mechanism (§2.3). The landed fix closes
the *mktemp-failure* and *clone-failure* branches but **not** the *write-failure* branch that actually
fires — reproduced **6 more times** on the newest revision (§2.5). That residual is the highest-value
item in this report.

**Nothing here is a full-battery result.** Every receipt on disk at probe end is narrow; the
post-patch `336/350 → ?` count does **not exist yet** (§1.5, §6 A1).

**And at probe end the gate was flaky again — with `POINTERS` moving a third time.** A late
`gate/README.md` rewrite briefly cited `reports/round-104/gate/workdir.md` before that file existed,
which turned the gate RED even on roomy scratch (`MISSING-PATH-REL`, 3/3 runs); the file landed
~2 minutes later and the gate went green again (§2.5a). `POINTERS` moved `101 → 102 → 103` across the
round and the README is now **internally inconsistent about it** (103 at `:42`/`:248`, 102 at
`:271`/`:283`/`:377`/`:440`, 101 quoted at `:357`/`:401`). The binding invariant, `UNRESOLVED=0`, is
what holds.

---

## 1. C1 — physics wall-cost: the defect, the fix, and what the fix costs

### 1.1 The defect is real and reproduces on the unpatched tree

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /dev/shm/…  (pre-patch)
FAIL phys3d_joints_free_ops: exit=None expected=0
     reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']
```

This is byte-identical to the r103 receipt's row and to SEAT-02's `physics/before.md` §1. The
defect is a **budget underrun**, not a physics regression: uncapped, the arm returns `rc=0` with a
3921-byte PASS marker whose sha256[:16] is `706ad9151452e18d` — the pin in SEAT-03's
`physics/markers.md` §1 row 5. SEAT-02 and SEAT-03 both re-derived that independently.

### 1.2 The landed fix is R3 (concurrent children), applied to `phys3d_joints.gd` only

```
$ git diff --stat HEAD -- corpus/fixtures/
 corpus/fixtures/phys3d_joints.gd | 33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)
$ sha256sum corpus/fixtures/phys3d_joints.gd
c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f     ← unchanged
```

`_run_child` was split into `_spawn_child` (`OS.create_process`, non-blocking) + `_collect_child`
(`OS.is_process_running` poll loop), with the emit loop walking `jobs` in the **original nested-loop
order** so the stdout stream stays a pure function of the per-child logs. `_finish()` is untouched
(`print(...)`; `quit(0)`). `run_battery.py` is **not** modified — `CASE_TIMEOUT_SECONDS = 20` still
stands at `:36`, and the CASES table is still **350 rows** at `:39`.

**This is the right choice of the two r103-ruled options.** R3 leaves every other row's failure
semantics byte-identical; R1's global 20→60 would have moved all 350 rows' hang-detection latency at
once (`reports/round-103/physics/ledger.md` §4.3 R1 says exactly this).

### 1.3 The fix works, and the marker survives — measured

```
$ for i in 1 2 3 4; do python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /dev/shm/dz$i; done
PASS phys3d_joints_free_ops: exit=0 expected=0     (×4, no FAIL, no reasons)
```

The r104 receipt `reports/round-104/scratch/seat37-after/20261018T192026083002Z/verdicts.json`
records the post-patch row as `verdict=PASS`, `reasons=[]`, `actual_exit=0`, `elapsed_seconds=2.992`
— down from a 20 s cap. SEAT-06's `physics/s06/bytecmp.log` shows the wall-clock collapse per arm
with the **whole stdout byte-identical**:

| arm | serial wall (ms) | conc wall (ms) | stdout |
|---|---|---|---|
| `free_ops` | 20231 | **2501** | IDENTICAL `sha=07f72b5beae4a114` |
| `free_pair` | 9701 | 2344 | IDENTICAL |
| `twopin` | 8394 | 2089 | IDENTICAL |
| `api` | 2875 | 1443 | IDENTICAL |
| `sweep` / `rid` / `detach` / `chain3` | 2827 / 2706 / 3357 / 5417 | 1485 / 1388 / 1610 / 2936 | IDENTICAL |

SEAT-06's `pinanchor.log` additionally confirms all **8** `phys3d_joints` arms' conc output equals the
pinned marker (`serial==pin=True conc==pin=True`), including `free_ops sha16=706ad9151452e18d`. So
the fix is marker-neutral across the whole arm family, not just the repaired row.

A late-landing receipt corroborates this through the **real** invocation path — the battery, at the
**shipped** 20 s bound, with no `--only`:

```
$ python3 -c "…Counter(…)"
physics/author-runs-all/20261018T192041290482Z/verdicts.json   8 {'PASS': 8}
$ … d['only'], d['case_timeout_seconds']
only = phys3d_joints_sweep,phys3d_joints_rid,phys3d_joints_api,phys3d_joints_free_pair,phys3d_joints_free_ops,phys3d_joints_detach,phys3d_joints_chain3,phys3d_joints_twopin
timeout = 20
```

**8/8 arms PASS with the global 20 s cap untouched.** That is the cleanest single piece of C1
evidence this round produced: it shows R3 fixed the row without needing R1's global bound change.

### 1.4 The one adversarial result, and why it does not refute R3

SEAT-06's `stress.sh` runs the arm N times **concurrently** and diffs each rep against a solo
reference. Its log shows `identical=0 differs=8 of 8` for **both** the serial and the conc tree, with
the diffs being `mode_ok=1` → `mode_ok=0` on `freeb_ops@gp`. This looks alarming and is worth
stating plainly, but it is **not** a refutation of R3:

- The **serial (unpatched) tree differs too** — 8/8. The parent-spawning code is not what makes the
  cell bimodal; the *outer* 8-way load is. Both trees are run under the same artificial 8-way
  concurrency, so the probe measures the harness, not the diff.
- The affected cell is `mode_ok`, which per the fixture's own comment (`phys3d_joints.gd:184`) is `0`
  when a child lands *outside* both the clean and crash windows — i.e. a child starved past its inner
  `timeout -s KILL 20` under 8-way load on a 32-core host also running two full batteries.
- SEAT-06's `childiso` probe ran a single child cell 5× serially and 5× concurrently and got
  `identical=0 differs=5 of 5`, but the diffs there are **`Load address: …` lines and a crash
  backtrace** — ASLR, exactly the class the fixture header (`:13`) says it excludes from the marker.
  A `Load address` difference is not a marker difference.
- Under the **real** invocation path (one parent, patched tree) this seat measured
  `mode_ok=0` **0 times** in a clean run (§2.6 of this file's probe log, `grep -c mode_ok=0` → `0`).

**Conclusion:** R3 is sound on the evidence. The bimodality is a load-sensitivity of the fixture's
`mode_ok` cell that predates the patch, and it is the *same* phenomenon `ledger.md` §4.2 R2 named as
the fail-open the row should close. It is worth an r105 adversarial seat, not an r104 rollback.

### 1.5 C1 gap — the counting command the brief names has not been run at the required scope

The brief defines C1's acceptance as **full-battery before → after**: r102's receipt is
`336 pass / 13 cannon node-marker fails / 1 free_ops`. Measured directly on that receipt:

```
$ python3 -c "…Counter(x['verdict'] for x in json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'))['results'])"
total 350 {'PASS': 336, 'FAIL': 14}
free_ops fails: ['phys3d_joints_free_ops']
cannon fails: 13
```

So the brief's arithmetic is exactly right: **14 = 1 + 13**, and the 13 are all `r94_cannon_*` with
`reasons=['exact stdout marker missing']`. At probe end, **three** full batteries were still
running (`reports/round-104/physics/author-runs-full/`, `reports/round-104/scratch/seat37-full/`,
`~/.cache/seat31work/full` — `ps aux` counted three live `run_battery.py --runs` processes) and
**none had produced a receipt**. Every receipt on disk at probe end is a **narrow** run, not the
counting command:

```
$ for f in $(find reports/round-104 -name verdicts.json | sort); do … len, Counter … done
physics/author-runs/20261018T192031033448Z/verdicts.json   1 {'PASS': 1}
physics/author-runs-all/20261018T192041290482Z/verdicts.json  8 {'PASS': 8}   ← all 8 phys3d_joints arms
physics/runs/20261018T191620117114Z/verdicts.json          1 {'FAIL': 1}   ← pre-patch free_ops
physics/runs-clean/20261018T191758479619Z/verdicts.json    1 {'FAIL': 1}   ← pre-patch free_ops
s22runs/20261018T192231060122Z/verdicts.json               1 {'PASS': 1}
scratch/seat37-after/20261018T192026083002Z/verdicts.json  1 {'PASS': 1}
scratch/seat37-runs/20261018T191942297230Z/verdicts.json   1 {'FAIL': 1}
```

The `author-runs-all` receipt is worth naming explicitly: it is **all 8 `phys3d_joints` arms at
`CASE_TIMEOUT_SECONDS = 20`, 8/8 PASS** — the strongest per-row evidence that the R3 fix did not
regress the arm family while leaving the global bound untouched. But it is **8 rows, not 350**.
**The post-patch full-battery count is therefore not yet an available number**, and this seat does
not report one. See §6 A1.

### 1.6 C1 gap — the 13 cannon rows are an environmental pin, not a code defect

This seat re-tested the `ledger.md` §4.2 A-D3 claim independently, on the **unmodified** fixture:

```
$ node --version
v26.12.0
$ python3 corpus/fixtures/run_battery.py --only r94_cannon_det --runs /dev/shm/cn1
FAIL r94_cannon_det: exit=0 expected=0 reasons=['exact stdout marker missing']
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
    python3 corpus/fixtures/run_battery.py --only r94_cannon_det --runs /dev/shm/cn2
PASS r94_cannon_det: exit=0 expected=0
```

**Confirmed on both sides.** The same fixture bytes flip verdict on `PATH` alone. The default `node`
is now **v26.12.0** (mise), not the v24.21.0 the markers were baselined under. This is a host-state
defect with a one-line workaround, and it is **13 of the 14** non-passing rows — larger than C1
itself. It is carried in the r103 LOG as "battery cannon node markers (carried)"; §6 A2 makes it the
second-ranked L1 action because a green C1 with a red D3 still leaves the battery at 337/350.

---

## 2. C2 — gate workdir resilience: the flake is real, and the landed fix is incomplete

### 2.1 The defect as measured on the shipped bytes

At probe start `run_gate.sh` was `577c8b54…` (the README pin) with two bare scratch allocations:

```
$ grep -n "mktemp" corpus/knowledge/unreal-mcp/gate/run_gate.sh    (pre-fix)
74:MANLOG=$(mktemp)
86:WORK=$(mktemp -d)
$ grep -c "TMPDIR\|GATE_WORKDIR" corpus/knowledge/unreal-mcp/gate/run_gate.sh
0
```

Host state during the whole window: `/tmp` is a **16 G tmpfs at 80 % used (13 G / 3.1 G free)**, and
it is **hard quota-capped**:

```
$ echo hello > /tmp/probe.out
/bin/bash: line 5: echo: write error: Disk quota exceeded
$ dd if=/dev/zero of=/tmp/probe/big bs=1M count=1
630784 bytes copied, 0.0 s …        ← short write, EDQUOT
$ df -h /tmp | tail -1
tmpfs  16G  13G  3.1G  80% /tmp
```

### 2.2 The flake is reproducible, and it is bimodal — 10/10 non-PASS

Ten consecutive runs of the **unmodified** gate, output redirected to `/dev/shm` (so the harness's own
capture cannot be blamed), `TMPDIR` left at its default:

```
$ for i in $(seq 1 10); do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /dev/shm/P/r$i.out 2>&1; done
$ grep -h '^GATE RESULT' /dev/shm/P/*.out | sort | uniq -c
      5 GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
      5 GATE RESULT: FAIL (checks failed: 1)
```

**Zero PASS in ten runs.** The same binary run with `TMPDIR=/dev/shm`:

```
$ for i in $(seq 1 10); do TMPDIR=/dev/shm bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > …; done
      10 GATE RESULT: PASS (checks failed: 0)
```

**10/10 PASS.** The only difference is which filesystem the scratch lands on. A second independent
pair of sweeps (5 default / 5 `TMPDIR=/dev/shm`) reproduced the split once the pressure returned:
`default → 5× BLOCKED, 5× FAIL`; `TMPDIR=/dev/shm → 10/10 PASS`.

Sibling **SEAT-48** reached the same result independently, with a receipt this seat did not write:
`reports/round-104/gate/scratch/seat48/close.tsv` shows runs 1–6 as
`2 BLOCKED / 0 PASS / 2 BLOCKED / 0 PASS / 2 BLOCKED` — the same alternating bimodality — and
`paired.tsv` is a default-vs-`TMPDIR` pairing where **12 of 12 default runs are non-PASS (11 FAIL, 1
BLOCKED) and 11 of 12 `TMPDIR` runs are PASS**. Two seats, two harnesses, one verdict.

### 2.3 The mechanism — `mktemp` succeeds; the *write* fails

The brief's root cause ("quota pressure silently breaking `mktemp`/clone") is **not what happens**.
Measured:

```
$ mktemp -p /tmp ; echo rc=$?
/tmp/tmp.…        rc=0        ← mktemp SUCCEEDS, 0-byte file
$ (cd corpus/knowledge/unreal-mcp && sha256sum --strict -c .manifest.d/*.sha256 > "$M" 2>&1)
File size limit exceeded (core dumped)     rc=153     size=0
```

`mktemp` only creates a 0-byte file — it needs no quota. The gate's next line, `>"$MANLOG"`, is the
first real allocation, and *that* is what EDQUOT kills. The old code could not distinguish the two:

```sh
MANLOG=$(mktemp)                                   # rc 0, file exists, empty
if ! (cd "$SUB" && sha256sum --strict -c … >"$MANLOG" 2>&1); then
  printf 'FAIL per-seat manifest sweep (--strict) failed:\n'   # ← fires on a CLEAN tree
  sed 's/^/  /' "$MANLOG"                                     # ← prints nothing
  FAILS=$((FAILS+1))
fi
```

The redirect fails, `sha256sum` never runs, `if !` sees rc 1, and the gate reports a **manifest sweep
failure on a tree whose manifests are perfect**. `sed` on the empty file prints nothing, which is why
the observed output is the bare line `FAIL per-seat manifest sweep (--strict) failed:` with no
detail. The FAIL run reproduces exactly that shape:

```
$ sed -n '1,12p' /dev/shm/P/r4.out
…
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.1G of 16G (80% used)
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:
CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: OK      ← CHECK 1 is GREEN in the same output
```

The second failure mode is the same allocation, one step later: the clone into `$WORK/clone` also
needs space, its `git clone` fails, and CHECK 2 took the A4 BLOCKED branch → **exit 2**:

```
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
```

**Mid-flight update (~19:28Z):** a later revision of `run_gate.sh` (`e5521304…`) added a
`local-resource` discrimination on that same branch, so the clone failure is now correctly *named*
rather than reported as a network problem:

```
CHECK 2 BLOCKED (local-resource)
BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted
BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream
BLOCKED retry with GATE_WORKDIR (or TMPDIR) on a roomy filesystem — see gate/README.md
```

That is a real calibration gain — the failure is now truthful about its cause. **The `MANLOG` branch
was not given the same treatment**; see §2.5.

**Both reds are false, and both name a check that is green in the same run.** A direct
`git clone` from a shell (whose stdout goes to a pipe, not to `/tmp`) succeeds in **0.63 s** and
returns the pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` — the network is fine; only the
`/tmp`-backed workdir is not. This is the strongest form of the r103 finding: not "at risk", but
**currently broken, and mislabeling a green tree**.

### 2.4 The landed fix

`run_gate.sh` is now `M`, and it grew in two steps while this seat watched: `+97 −11`
(`abebee5c…`) then `+109 −14` (`e5521304…`).

```
$ grep -n "GATE_WORKDIR\|TMPDIR" corpus/knowledge/unreal-mcp/gate/run_gate.sh | head
23:# ${GATE_WORKDIR:-${TMPDIR:-/tmp}} — see the WORK_ROOT block below and the …
27:#        GATE_WORKDIR=/some/roomy/dir corpus/knowledge/unreal-mcp/gate/run_gate.sh
59:WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
124:MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''
145:WORK=$(mktemp -d -p "$WORK_ROOT" 2>/dev/null) || WORK=''
```

Precedence is `GATE_WORKDIR > TMPDIR > /tmp`; the root is validated up front (a typo'd root now
prints a named failure instead of an obscure one); the scratch dirs are rooted at `WORK_ROOT`; a
failed allocation prints a loud `FAIL cannot create scratch file under <root>` with the remedy; and
the clone's `cleanup` is now wired to `EXIT`, `INT`, `TERM` and `HUP` so a killed gate cannot leave a
clone behind to deepen the pressure. **Verified working:**

```
$ GATE_WORKDIR=/dev/shm/gw1 bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
WORK_ROOT=/dev/shm/gw1 (from GATE_WORKDIR)
WORK_ROOT_FREE=15G of 16G (6% used)
GATE RESULT: PASS (checks failed: 0)          rc=0
```

### 2.5 The residual — the fix closes the branch that does *not* fire

This is the most important thing in this report. **`mktemp` failing is not the observed failure
mode.** The observed mode is `mktemp` *succeeding* (0-byte file) and the subsequent **write** failing.
The landed guard is:

```sh
MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''
if [ -z "$MANLOG" ]; then
  printf 'FAIL cannot create scratch file under %s (quota? permissions?)\n' …   # ← this branch
  …
```

That branch fires only when `mktemp` itself fails. Under the pressure this round actually measured,
`mktemp` returns 0 and `MANLOG` is a valid non-empty **path**, so the guard is skipped and control
falls straight into the old `if ! (… >"$MANLOG" 2>&1)` — the misleading `FAIL per-seat manifest
sweep` path. **Confirmed empirically, twice, on two different post-fix revisions:** under the live
pressure the gate still prints

```
$ grep -c "cannot create scratch file" /dev/shm/gd4.out     # gate abebee5c…
0
$ grep -E '^FAIL|^GATE RESULT' /dev/shm/gd4.out
FAIL per-seat manifest sweep (--strict) failed:
GATE RESULT: FAIL (checks failed: 1)
```

and again on the later revision `e5521304…`:

```
$ for i in 1 2 3 4 5 6; do bash …/run_gate.sh > /dev/shm/final6/r$i.out 2>&1; done
r1 rc=1 GATE RESULT: FAIL          ← the MANLOG branch, unchanged
r2 rc=2 GATE RESULT: BLOCKED       ← now correctly labelled (local-resource)
r3 rc=2 GATE RESULT: BLOCKED
r4 rc=2 GATE RESULT: BLOCKED
r5 rc=2 GATE RESULT: BLOCKED
r6 rc=2 GATE RESULT: BLOCKED
$ grep -l "cannot create scratch" /dev/shm/final6/*.out
(no output — the loud message never appears)
$ sed -n '5,10p' /dev/shm/final6/r1.out
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.1G of 16G (80% used)
MANIFEST_FILES=12
FAIL per-seat manifest sweep (--strict) failed:
CHECK 1 manifest-byte-identity
upstream/.claude-plugin/plugin.json: OK        ← CHECK 1 green in the same output
```

— the new loud message never appears, and the misleading one still does. The fix is a genuine and
correct improvement (the *hardcoded-`/tmp`* defect is closed, `WORK_ROOT` is selectable and
validated, the traps are right, and CHECK 2's clone failure is now labelled `local-resource` rather
than blamed on the network), but the `MANLOG` branch **still does not close the defect C2 was
chartered to close.** §6 A3 ranks the completion.

### 2.5a A *new* red, self-inflicted — and it resolved while this seat watched

Late in the window `gate/README.md` was rewritten (`834f468d…` → `66bce160…` → `f84a580e…`) to
document the new interface, and in doing so it **broke the gate it documents**. `gate/README.md:373`
and `:441` cited `reports/round-104/gate/workdir.md` as the full transcript of the workdir evidence —
and that file did not exist:

```
$ ls -la reports/round-104/gate/workdir.md
ls: cannot access 'reports/round-104/gate/workdir.md': No such file or directory
$ grep -n "workdir.md" corpus/knowledge/unreal-mcp/gate/README.md
373:script (`run_gate.sh` sha256 `e5521304…`).** Full transcript: `reports/round-104/gate/workdir.md`.
441:receipt is `reports/round-104/gate/workdir.md`.
```

CHECK 4's relative sweep resolves `reports/…` backticks against the repo root and correctly reported
it missing, so the gate was RED **even with roomy scratch** — not a `/tmp` artifact:

```
$ for i in 1 2 3; do TMPDIR=/dev/shm bash corpus/knowledge/unreal-mcp/gate/run_gate.sh > /dev/shm/q$i.out 2>&1; done
q1 rc=1 POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1 GATE RESULT: FAIL
q2 rc=1 … UNRESOLVED=1 GATE RESULT: FAIL
q3 rc=1 … UNRESOLVED=1 GATE RESULT: FAIL
$ sed -n '52,56p' /dev/shm/q1.out
CHECK 4 pointer-sweep
MISSING-PATH-REL reports/round-104/gate/workdir.md
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
```

**It resolved ~2 minutes later**: `reports/round-104/gate/workdir.md` landed (13645 bytes), and the
gate returned to green on roomy scratch, 4/4:

```
$ for i in 1 2 3 4; do TMPDIR=/dev/shm bash …/run_gate.sh > /dev/shm/f$i.out 2>&1; done
f1 rc=0 POINTERS=103 UNRESOLVED=0 GATE RESULT: PASS
f2 rc=0 POINTERS=103 UNRESOLVED=0 GATE RESULT: PASS
f3 rc=0 POINTERS=103 UNRESOLVED=0 GATE RESULT: PASS
f4 rc=0 POINTERS=103 UNRESOLVED=0 GATE RESULT: PASS
```

The README was then reconciled while this seat watched: `POINTERS=103` now appears 4× and
`e5521304…` 5×, with `577c8b54…` down from 4 to **2** and `101` down to 2 (both inside explicitly
historical passages). So the count/pin drift narrowed as the round closed — but the two stale
`577c8b54…` references and the two `101` quotes are still present, and §6 A0/A4 keep them open.

Two things the L1 should still take from this episode, because both are live:

- **The advertised pointer count moved `101 → 102 → 103` inside one round**, and the README was
  briefly **internally inconsistent about it** (`103` at `:42`/`:248`, `102` at `:271`/`:283`/`:377`/
  `:440`, `101` quoted at `:357`/`:401`), before being reconciled to `103` ×4 / `101` ×2 at probe
  end. This is the `scanner-relative datum` error pattern `SKILL.md` §2 names — reproduced inside the
  file that names it. The binding invariant (`UNRESOLVED=0`) is what should be quoted; the count
  should be stated once, with its scanner sha, or not at all.
- **The mechanism was the same class the gate exists to catch**: prose citing a path that does not
  exist. The gate caught its own README's defect, which is the system working — but it also means a
  documentation edit can redden the close-out gate, and the round's own seats must expect that.

### 2.5b `gate/README.md` — A4 mostly landed, two stale refs and two stale quotes remain

The README now documents the interface (`grep -c 'TMPDIR\|GATE_WORKDIR'` → **6**, was 0) and
re-pins the scanner to `e5521304…` (5 occurrences, incl. `:42`, `:248`, `:373`, `:377`). **Two stale
`577c8b54…` references remain** (`:40`, and one reading *"Evidence at the settled scanner
(`run_gate.sh` sha256 `577c8b54…`)"* about a scanner two revisions old), and two `POINTERS=101`
quotes survive inside historical passages — both acceptable if the surrounding text is explicitly
historical, and worth a read either way. §6 A4.

### 2.6 The flake harness exists and does catch it

`reports/round-104/gate/flake_harness.sh` (SEAT-14, executable, `bash -n` clean) runs the installed
gate N times on an unmodified tree and classifies each run `PASS`/`FAIL`/`BLOCKED`/`EMPTY`/
`UNEXPECTED`/`MISMATCH`, cross-checking the exit code against the run's own `GATE RESULT:` line and
the STEP tally. Its first runs on this host returned:

```
TALLY runs=3 pass=0 fail=0 blocked=3 empty=0 unexpected=0
FLAKE verdict: expected PASS on all 3 runs, got pass=0 fail=0 blocked=3
HARNESS RESULT: FLAKY (1 distinct flake class(es) above; per-run logs in /tmp/flake-harness.…)
```

**It caught the defect on its first use**, which is the strongest possible evidence for the harness
itself. One caveat for the L1: its `classify()` requires exactly 4 `STEP=` lines and treats a
BLOCKED run as 1 `STEP=BLOCKED` + 3 `STEP=PASS` — correct for the A4 contract, and the header
records that an earlier revision wrongly demanded 4 PASS and was caught by its own negative control
NC5. That is the right shape for a checker.

---

## 3. C3 — the decision table landed into a new `SKILL.md`

### 3.1 The artifact

At probe start, **no lane-level `SKILL.md` existed** — the lane was in shonen seed form
(`README.md:10-11`: *"absent on lanes still in shonen seed form"*), and the draft lived only at
`reports/round-102/skill-decision-table-draft.md`. SEAT-42's `seats-ledger.md` §2 independently
confirmed the absence at `19:17Z` and warned that a bare `find . -name SKILL.md` now returns hits
from untracked round scratch (this seat's own check saw the same: 3 vendored upstream copies + a
full-clone scratch tree).

By probe end `SKILL.md` exists at the lane root: **174 lines, 18759 bytes,
`sha256 1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c`**, front-matter
`name: game-dev-3d-shokunin`, and the table is §1 at `:20` (*"Unreal-content claim discipline —
decision table"*).

**It then self-corrected again** while this seat wrote, to **182 lines,
`sha256 de8ada369bf8bb1e7108a624b5dbb6ec46242ecf7a09b4755d65debfbacb9903`** — rows A–E intact (5
rows), the `reports/round-104/skill/author.md` citations up from 5 to **7**, and one correction worth
naming: the §6 artifact table now describes the gate as *"**worktree, uncommitted** (HEAD still
carries `577c8b54…`)"*. That is exactly the distinction §2.5b found the README failing to make, and
`SKILL.md` caught it about itself before the README did. The §3 analysis below applies to both
revisions; re-hash before quoting a line number.

**The r103 review's landing conditions were met, not merely cited.** SEAT-59's
`reports/round-103/skill-table-review.md` §3.1 flagged the draft's missing row for lane-authored
static artifacts; the landed file has **rows A–E**, with **E** = *"Lane-authored static descriptor —
'the lane wrote a `.uplugin` its own checker accepts'"*, `static-only`, with both the `PASS
local-static actual=accept` command and its paired `--expect-reject` control. The r103 review also
required that no gate line number be carried (all ten of the draft's `gate/run_gate.sh:NN`
citations had rotted); the landed file states this explicitly at `:57` — *"No gate line number is
carried into this file — the gate is cited by `CHECK n <name>` and by its sha."* It also carries a
**§4 that states the open P/C precedence ruling and refuses to resolve it**, and a **§6 re-derivation
table** stamping every artifact with its sha256.

### 3.2 What this does and does not close

The file says so itself at `:170-174`: landing the table satisfies the **artifact half** of
`SHONEN.md` box 1, and does **not** close the box, which requires a **named non-author verifier**.
SEAT-42's ledger independently confirms `SHONEN.md` box 1 is still `[ ]` and `SHONEN.md` is
byte-identical to HEAD (`8d85902c…`). **So C3's honest verdict is "landed, box still open by
design"** — and the file's own §6 table names `reports/round-104/skill/author.md` §2 as the
re-derivation receipt, which **does now exist** (357 lines) but which this seat did not author or
verify.

### 3.3 C3 gap — the table's own citations are unverified by this seat

`SKILL.md` cites `reports/round-104/skill/author.md` **5 times**. That file exists, but it is a
**same-round, self-referential** receipt for a file that is itself a round artifact. The r101 close-out
left box 1 open for exactly this reason (*"until a non-author verifier accepts them as the skill's own
tables rather than round artifacts"*). **No non-author verification of `SKILL.md`'s rows has landed
at probe end.** §6 A5.

---

## 4. Deduplication — what the round actually has, by claim

Seats whose work this report *consumed and did not duplicate*: SEAT-02/03/06 (C1 before/markers/
determinism), SEAT-09 (CASES invariance), SEAT-12 (C2 implementation), SEAT-14 (flake harness),
SEAT-26/41/42 (ledger, subtree integrity, seats ledger), SEAT-28 (stub cleanness), SEAT-40
(gate final run), SEAT-43 (freshness pin), SEAT-47 (404 carry), SEAT-48 (C2 independent repro).

**Convergent findings — two or more independent derivations agree:**

| finding | derivations | agreement |
|---|---|---|
| C1 defect is `INTRINSIC_WALL_COST`, arm correct | SEAT-02 (before), SEAT-03 (markers), SEAT-06 (bytecmp), this seat | 4/4 — marker `706ad9151452e18d` byte-identical |
| r102 baseline is 336/350 with 14 FAILs = 1 + 13 | brief, this seat, SEAT-02 (`before.md` §1) | 3/3 — `Counter({'PASS': 336, 'FAIL': 14})` |
| 13 cannon rows are a `node` version pin | SEAT-32 (ledger §4.2 A-D3), this seat | 2/2 — `v24.21.0` PASS vs default `v26.12.0` FAIL |
| gate flakes on default `TMPDIR` and is stable under `TMPDIR=/dev/shm` | SEAT-01 (mid-round), SEAT-40 (final-run §2 note), SEAT-48 (`close.tsv`/`paired.tsv`), this seat | 4/4 — this seat 10/10 vs 10/10 |
| the gate's `577c8b54…` pin is now stale | SEAT-40 §Notes 1 (predicted), this seat (measured) | 2/2 — script has moved through `abebee5c…`/`e5521304…`, README still `577c8b54…` ×4 |
| `POINTERS=101` is an advertised measurement, not a contract | SEAT-40 §"does not claim", SEAT-43, `SKILL.md` §2 `scanner-relative datum`, this seat | 4/4 — all four runs print `101`/`UNRESOLVED=0` |
| `POINTERS=101` holds on the post-fix scanner | this seat | 5/5 runs — `POINTERS=101 … UNRESOLVED=0`, `STEP=PASS` |
| the R3 fix leaves all 8 `phys3d_joints` arms passing at the shipped 20 s bound | SEAT-06 (`pinanchor.log`), `physics/author-runs-all` receipt, this seat | 3/3 — 8/8 PASS, markers equal the pin |

**Divergent / contested — recorded, not resolved:**

| item | position A | position B | status |
|---|---|---|---|
| `stress.sh` `mode_ok=0` under 8-way load | SEAT-06: refutation risk for R3 | this seat: **both** trees differ 8/8, so it measures the load, not the patch; `childiso` diffs are ASLR | **resolved in R3's favour** by the serial-tree control; residual load-sensitivity is real and predates the patch (§1.4) |
| C2 root cause | brief: "quota pressure silently breaking `mktemp`/clone" | this seat: `mktemp` **succeeds**; the **write** fails | **position B is measured** (§2.3) and it changes which branch the fix must cover |
| C2 completeness | landed `WORK_ROOT` + loud guard | this seat: guard covers `mktemp`-failure, not `write`-failure | **open** — §2.5, §6 A3 |
| `SKILL.md` box 1 | landed (artifact) | still `[ ]` (needs non-author verifier) | both true; the file says so itself |

**Findings unique to this seat:** the `mktemp`-succeeds/write-fails mechanism (§2.3); the
demonstration that the landed C2 guard does not fire on the actual failure mode (§2.5); the
self-inflicted `MISSING-PATH-REL` red and its resolution (§2.5a); the `mode_ok=0` stress result read
against its own serial-tree control (§1.4); the stale-pin and `POINTERS`-inconsistency counts
(§2.5b); and the independent `r94_cannon_det` node flip (§1.6).

---

## 5. State that moved under this seat (point-in-time caveat)

This is a mid-flight document and the worktree changed while it was written. Frames observed:

| time (Z) | `phys3d_joints.gd` | `run_battery.py` | `run_gate.sh` | `SKILL.md` | `git status --short` (tracked) |
|---|---|---|---|---|---|
| ~19:16 | `88be87fa…` | `f456bd00…` | `577c8b54…` | absent | clean |
| ~19:20 | `c7e77638…` (**M**) | `f456bd00…` | `577c8b54…` | present | ` M corpus/fixtures/phys3d_joints.gd` |
| ~19:24 | `c7e77638…` | `f456bd00…` | `abebee5c…` (**M**) | `1055a52f…` | `+ M …gate/run_gate.sh`, `?? SKILL.md` |
| ~19:26 | `c7e77638…` | `f456bd00…` | `b6d8c61a…` (**M**) | `1055a52f…` | same |
| ~19:28 | `c7e77638…` | `f456bd00…` | `e5521304…` (**M**) | `1055a52f…` | same |
| ~19:29 | `c7e77638…` | `f456bd00…` | `e5521304…` | `de8ada36…` | `+ M …gate/README.md` |

`run_gate.sh` changed identity **four times** in twelve minutes while this seat probed it
(`577c8b54 → abebee5c → b6d8c61a → e5521304`), `gate/README.md` **four** times
(`834f468d → 66bce160 → f84a580e → e3bc66b7`), and `SKILL.md` twice
(`1055a52f → de8ada36`) — the same churn the r103 review documented (four gate identities in one
round) and the reason `SKILL.md` §1 refuses to carry gate line numbers. **Any number in §2 is tied
to the sha it names; re-hash before acting.** Note `b6d8c61a…` was observed only in a single
measurement and may have been a mid-write read; treat the frames captured more than once
(`abebee5c…`, `e5521304…`, `e3bc66b7…`) as the settled ones.

At probe end: `run_battery.py` is still `f456bd00…` (unchanged, as required — the fix is
fixture-only), `phys3d_joints.gd` is `c7e77638…` and is the **only** modified fixture, `run_gate.sh`
is `e5521304…`, `gate/README.md` is `e3bc66b7…`, `SKILL.md` is `de8ada36…`, and `reports/round-104/`
plus `SKILL.md` plus transient scratch dot-dirs (`.r104seat17/`, `.r104-seat17/`) are the untracked
surface. Sibling full batteries were still **running** at probe end (`ps aux` counted **18** matching
processes, including several `run_battery.py --runs` parents) — so the worktree may move again after
this document. **Re-verify every hash in this file against the final tree before folding.**

---

## 6. Ranked L1 actions

Ranked by (defect severity) × (whether the round's own acceptance evidence exists yet).

**A0 — keep the gate GREEN, and reconcile its advertised pointer count.** §2.5a. The `workdir.md`
citation that briefly reddened the gate has resolved (the file landed), so this is now a
**verification** action rather than a repair: re-run the gate on roomy scratch and confirm `PASS`
before the round closes, because a documentation edit reddened it once already inside this round and
could do so again. Then fix the README's self-contradiction: it advertises `POINTERS=103` at
`:42`/`:248`, `102` at `:271`/`:283`/`:377`/`:440`, and quotes `101` at `:357`/`:401` — one file,
three counts, all under the same `e5521304…` scanner sha. Quote `UNRESOLVED=0` as the invariant and
state the count once, with its scanner sha.

**A1 — obtain the post-patch full-battery count; C1 is otherwise unproven.** C1's acceptance is
`336/350 → after`. **Three** full batteries were in flight at probe end and none had a receipt; every
receipt on disk is narrow (§1.5). The counting command is
`python3 -c "…Counter(x['verdict'] for x in json.load(open(<receipt>))['results'])"` against the new
receipt, and the expected shape is `FAIL` dropping from 14 to 13 (free_ops fixed, 13 cannon rows
carried). **Do not close C1 without it** — the per-row evidence (§1.3, including an 8/8
`author-runs-all` pass at the shipped 20 s bound) is strong but it is not the command the brief names.

**A2 — resolve the 13 cannon rows, or state them as an environment pin.** Independently confirmed
(§1.6): the same fixture bytes PASS under `node v24.21.0` and FAIL under the default `v26.12.0`. This
is **13 of the 14** non-passing rows — a larger block than C1. Either re-baseline the markers against
the current `node`, or pin the battery's `PATH` in its own runner, or record a dated environment note
in `corpus/lessons/`. Any of the three closes it; leaving it carried a fourth round does not.

**A3 — complete C2 by guarding the write, not just `mktemp`.** §2.5: the landed guard fires only on
`mktemp` failure, but the measured failure is `mktemp` succeeding and the **redirect write** failing.
Minimal correct shape: after the redirect, test `[ -s "$MANLOG" ]` (or capture the redirect's rc
separately) and route a 0-byte/empty log into the same loud `cannot create scratch file` branch;
equivalently, pre-flight the free space on `WORK_ROOT` against a floor before CHECK 1. Until then the
gate still prints `FAIL per-seat manifest sweep` on a clean tree. **This is the one action that
closes the defect the round was chartered to close.**

**A4 — finish the `gate/README.md` re-pin.** The interface is now documented (`grep -c` → 6) and the
scanner re-pinned to `e5521304…` at `:42, :248, :283, :373, :377, :421` — a real A4 gain. **Two stale
`577c8b54…` references remain** (`:40`, and `:397` which reads *"Evidence at the settled scanner
(`577c8b54…`)"* about a scanner two revisions old), plus the `102`/`103` split covered in A0.
SEAT-40's `gate/final-run.md` §Notes 1 predicted this exact churn ("if C2 lands an edit to
`run_gate.sh`, the sha256 changes and this run must be redone"). Sweep the remaining two and re-run
against the settled bytes.

**A5 — get a non-author verifier onto `SKILL.md`.** C3 landed the artifact but box 1 needs a **named
non-author verifier** (`SHONEN.md`; `SKILL.md:170-174` says so itself). Its 5 citations of
`reports/round-104/skill/author.md` are same-round and self-referential. A verifier should re-run
§1's canonical commands from the stated cwd and check the two claims most likely to rot: row B's
`jq -e .` rc (the dot is load-bearing — without it `jq` exits 3) and row D's `strings`-based
re-derivation (which dies on a CLI upgrade by design).

**A6 — note the `mode_ok` load-sensitivity as an r105 adversarial target.** §1.4: `mode_ok=0`
appears under 8-way outer load in **both** the patched and unpatched trees, so it is not an R3
artifact — but it *is* the fail-open `ledger.md` §4.2 R2 named, and the row can currently print PASS
over a degraded cell. An r105 seat should test whether R2's guard is worth applying, with the
serial-tree control this round established as the baseline.

---

## 7. What this seat did not do

- **No repair.** No file outside `reports/round-104/r104-distiller.md` was written. No `git` mutating
  command was run. No fixture, gate, or `SKILL.md` byte was touched.
- **No full battery.** §1.5 — the counting command was not run by this seat; two were in flight from
  sibling seats. The number is not reported because it was not observed.
- **No verification of `SKILL.md`'s rows.** §3.3 — this seat read the table and its landing
  conditions; it did not re-run its canonical commands, and it is not the non-author verifier box 1
  requires.
- **No Unreal runtime claim, anywhere.** Unreal Editor is not installed on this host. Every claim
  above is a filesystem, hash, process, or HTTP observation.
- **No claim that the C2 fix is wrong.** §2.4 — it is correct and verified working. §2.5 is a claim
  that it is **incomplete**, with the reproduction pasted.
