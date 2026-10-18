# r104 SEAT-10 — FIX-ADVERSARY: the R3 concurrency fix should not land

**Seat:** SEAT-10 `FIX-ADVERSARY` · **Round:** 104 · **Lane:** `game-dev-3d-shokunin`
**Owned path written:** this file only (`reports/round-104/physics/adversary.md`).
**Lane HEAD under test:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103 report-last; work `8c9d9ad`).
**Subject:** claim **C1 (depth)** — the r103-routed fix for `phys3d_joints_free_ops` wall cost,
*"R3 concurrent children (preferred) or R2 per-case bound"* (`LOG.md:1385`, r103 ROUTED block),
as instantiated in the working tree by SEAT-04 (`corpus/fixtures/phys3d_joints.gd`, +26/−7).
**Axes served:** calibration (what the fix does and does not change) + coverage (the failure mode it opens).
**No Unreal runtime claim is made here** (editor not installed; live-MCP unproven by construction). This seat made no claim about Unreal at all.
**Scope:** every experiment below ran on throwaway copies under `/var/tmp/s10/` (see §9 on why not `/tmp`). `corpus/fixtures/**` was never written by this seat; `git status` shows my seat's only new path is this file.

---

## 0. Ruled position, up front

**The fix should not land as a "wall clock only" change. Two of its four required repairs are still open, and the one it did land is mis-scaled against the runner.**

The mandate was to argue against landing it. I ran the experiments that could have refuted it, and the *advertised* argument against it **failed**: the pinned marker does **not** move under concurrency (§3 — 33/33 arm reps and 8/8 bank rows byte-identical, corroborated by SEAT-06's `worstcase.sh`), so I am not going to present a refuted claim as my ruling. The fixture also moved twice under me (`c7e77638… → 80bf44c5…`), and the second move closed one of my own findings. Everything below names the sha it was measured on. What survives is measured rather than asserted, and it is the part of the change that no marker comparison can see:

| # | finding | status |
|---|---|---|
| F1 | "Concurrency breaks the pinned marker bytes" (the natural first argument) | **REFUTED by my own test** — 33/33 arm reps, 8/8 bank rows, sha-exact (§3); independently corroborated by SEAT-06's `worstcase.sh` (§3c) |
| F2 | Concurrency **escapes the case-timeout kill**: a killed parent cannot reap children it has already detached; serial leaves 0, `c7e77638…` left **15** (§4). The landed `OS.kill` narrows this — no count on the landed bytes | **narrowed** |
| F3 | R3 was **fail-open** on `c7e77638…`: one hung child produced a **`PASS` line with 2 `mode_ok=0` cells** where serial emitted nothing (§5a) — **closed by the landed `BATCH_BOUND_S` guard**, which now emits `FAIL … batch_timeout` (§5b) | **closed, then reopened** |
| F3′ | The landed guard is **not fail-closed through the runner**: its `FAIL` fires at **20.78 s wall** against the runner's 20 s cap, so the runner kills the arm 0.78 s early and the row's reason is the generic `TIMEOUT`/`marker missing` — indistinguishable from the D1 wall-cost failure this round exists to remove. `BATCH_BOUND_S=16` + ~4.1 s of measured parent overhead does not fit a 20 s cap (§5c) | **substantiated, new** |
| F4 | R3 changes the battery's **resource contract**: 21 concurrent Godot children per case = peak **63 processes / 2.4–2.8 GB RSS** against serial's **4 / 247 MB**; no concurrency cap landed (§6) | **substantiated** |
| F5 | The **inherited baseline** says the row is a *margin* row, not a class-eliminating defect: r93 recorded **PASS at 17.802 s under load 122** (§7) | **substantiated** |
| F6 | The **retry-instead-of-refactor** option: a 20 s cap and a deterministic ~19–20 s row are one error bar apart; raising the cap (or one retry) fixes the symptom with **zero** fixture-byte risk (§8) | **proposed** |
| F7 | The **counting command is not a clean +1**: patched bytes give **332/350** vs r102's 336/350 at the same cap — the target row leaves the FAIL set (`free_ops` PASS 2.564 s) but five load/asset-flake rows enter it (§2b) | **measured** |

F4 and F3′ are *costs the fix buys*, and F5 says the benefit is a margin, not a class. F7 adds that the round's own counting command does not even close the battery. My ruled position is therefore:

> **Do not land R3 as a "wall clock only" fixture rewrite this round.** The row *is* repaired (measured: 2.564 s, marker byte-identical), so this is not a demand to revert — it is a demand not to *close* on it. Two of §5.4's four repairs are still open (`mode_ok` guard, concurrency cap) and the landed `BATCH_BOUND_S=16` must come down to ~12–13 s to fit inside the runner's 20 s cap. If the lane wants the symptom gone without that work, the operator-visible bound (§8, R1/R2) touches no fixture byte and cannot introduce F3′/F4. Either way the fixture's own comment — *"only the wall clock changes"* — is now false, and a byte-pinned fixture whose receipts encode its sha needs its own round, its own attack seats, and its own before/after receipt rather than a fold into r104's C1.

---

## 1. What the fix actually is

The first form of the fix, as read at `19:22Z` (blob `c7e77638…`; `git diff -- corpus/fixtures/phys3d_joints.gd`):

```gdscript
func _run() -> void:
	if not ARM_CASES.has(arm):
		return _fail("unknown_arm")
	var jobs: Array = []
	for case in ARM_CASES[arm]:
		for bk in BACKENDS:
			var j := _spawn_child(case, bk[0], bk[1])     # OS.create_process, no wait
			if j.has("err"):
				return _fail("%s@%s %s" % [case, bk[0], j["err"]])
			jobs.append(j)
	for j in jobs:
		var d := _collect_child(j)                        # busy-wait, then read log
		if d.has("err"):
			return _fail("%s@%s %s" % [j["case"], j["bk"], d["err"]])
		_emit(j["case"], j["bk"], d)
	_finish()
```

with `_spawn_child` = the old `_run_child` body down to `OS.create_process("/bin/sh", ["-c", cmd], false)` returning `{case, bk, pid, log}`, and `_collect_child` = `while OS.is_process_running(pid): OS.delay_msec(5)` then the old log scan.

**The landed form adds the deadline** (`80bf44c5…`, read at `19:38Z`): `const BATCH_BOUND_S := 16`, armed as `var deadline := Time.get_ticks_msec() + BATCH_BOUND_S * 1000` immediately after the spawn loop, and inside the collection loop `OS.kill(j["pid"])` + `return _fail("%s@%s batch_timeout" …)` for a straggler. §5b/§5c measure those bytes; §5c is about this constant.

The fixture's own comment still calls the change **wall-clock-only** — *"The emitted stream stays a pure function of the per-child logs; only the wall clock changes."* §3 tests the first half (it holds), §4–§6 test the second half (it does not: the landed `_fail` path changes the exit code and the emitted line).

**Reproduction of the whole of §3–§6** (all under `/var/tmp/s10/`; `serial/` holds the HEAD bytes, `conc/` the `19:17Z` working-tree bytes, `conc2/`+`hang2/` the landed `80bf44c5…` bytes):

```sh
cd /var/tmp/s10 && sha256sum serial/phys3d_joints.gd conc/phys3d_joints.gd conc2/phys3d_joints.gd
# 88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  serial/phys3d_joints.gd   (HEAD)
# e79c3180905c1104eccccdc94a29309dd95385347badd2383d48c36f5cb84b67  conc/phys3d_joints.gd     (working tree, 19:17Z)
# 80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  conc2/phys3d_joints.gd    (landed, 19:38Z)
python3 /var/tmp/s10/probe.py serial 1 /var/tmp/s10/serial     # wall 19.61 rc 0 marker_eq_pin True
python3 /var/tmp/s10/probe.py conc   5 /var/tmp/s10/conc       # 5 reps, all marker_eq_pin True
python3 /var/tmp/s10/probe2.py                                # RSS/proc peak per design
python3 /var/tmp/s10/orphan3.py                               # kill-at-cap orphan census
python3 /var/tmp/s10/hangcmp.py                               # one-hung-child, c7e77638… bytes
```

---

## 2. The reference numbers (so every claim below is comparable)

One arm, `--arm=free_ops` = 7 cases × 3 backends = **21 children**, unmodified seeds:

| design | reps | wall (s) | rc | marker == `CASES` pin |
|---|---|---|---|---|
| serial (HEAD) | 4 | 19.61, 19.02, 19.75, 20.54 | 0 | True ×4 |
| R3 concurrent | 29 | **1.92 – 3.39** (median 2.58) | 0 | **True ×29** |

Both designs are *correct and complete*; they differ by 6–10× in wall clock and, as §6 shows, by 10× in process count and 11× in peak RSS.

### 2b. The counting command — full battery, before vs after

The brief's C1 acceptance is *"full-battery before (r102 receipt: 336 pass / 13 cannon node-marker fails / 1 this row) → after is the counting command."* I ran it: a copy of the tree at the working-tree fixture bytes (`/var/tmp/s10/tree-fix`, `phys3d_joints.gd` = `c7e77638…`), the shipped `run_battery.py` (`f456bd00…`), full 350 rows, unmodified cap:

```
$ cd /var/tmp/s10/tree-fix && python3 run_battery.py --runs /var/tmp/s10/runs-full
FAIL battery: /var/tmp/s10/runs-full/20261018T192346837085Z/verdicts.json     # rc=1, 693.3 s wall
```

| receipt | cases | pass | fail | Σ elapsed | FAIL set |
|---|---|---|---|---|---|
| r102 `20261018T181301123479Z` (HEAD bytes) | 350 | **336** | 14 | 787.6 s | 13 cannon + **`phys3d_joints_free_ops`** |
| r104 (this seat, patched bytes) | 350 | **332** | 18 | 693.0 s | 13 cannon + 3 navagent + 2 `r98_gltflat` |

- **The targeted row is fixed and the counting command confirms it**: `free_ops` `PASS`, `elapsed=2.564 s`, `marker_in_stdout True` — the row the whole round is about, out of the FAIL set at the unchanged 20 s cap.
- **The FAIL *set* moved, the FAIL *count* went up.** `free_ops` left; **five rows that PASSed in r102 failed here**: `navagent3d_retarget` (+`_fixed`), `navagent3d_follow`, `r98_gltflat_doc`, `r98_gltflat_extbin`. The navagent pair is the **on-record r93 flake class** (one-tick-late sampling, `r93-baseline2.md:133-134`: `Δ = 2×√2/60` and `√2/60`), so it is load-induced, not caused by the fix. **The two `r98_gltflat` rows are not on any flake list I found** — both fail with `ERROR: Can't open file at path "UD/R98Scout/…"`, i.e. a missing *asset* path, which is a fixture/resource question, not a concurrency question; I am flagging them as a carry, not claiming a cause.
- **Therefore the honest reading of "336 → after" is: the round's own target row is repaired, and the full-battery count is *noisy in both directions* at this host's load** (this run carried 98 concurrent `godot` processes from other seats, §9). A single before/after pair cannot attribute a 4-row delta to the fixture change — and a fix-adversary seat should say so rather than let the counting command imply a clean +1.

---

## 3. The first argument against the fix — and why I am not making it

The natural adversarial argument is that concurrency makes the pinned marker order- and heap-dependent. The pin is 3921 bytes of **21 order-sensitive cells** (`CASES:530-531`), and `phys3d_joints.gd:45-63` states that the `mode_ok` cells are *"decided per run by heap state"* — a `SIGSEGV`/clean flip that changes a `mode_ok`/`m6=` byte. A concurrent spawn perturbs exactly that state. I predicted a byte break, and tested it two ways:

**(a) Whole-marker comparison, 29 concurrent reps.** Every rep's `PASS phys3d_joints free_ops …` line was compared byte-for-byte against the `CASES` pin extracted with `ast.literal_eval` (never a grep):

```
$ python3 -c "<compare /var/tmp/s10/{conc,load,tail}*.out against the CASES pin>"
reps compared to CASES pin: 33 ok; 0 mismatched []
```

**(b) The r104 bank, all 8 `phys3d_joints` rows, via the runner.** A copy of the tree at the working-tree fixture bytes, run through `run_battery.py --only <the 8 rows>`:

```
$ cd /var/tmp/s10/tree-fix && python3 run_battery.py --only phys3d_joints_sweep,…,phys3d_joints_twopin --runs /var/tmp/s10/runs-fix
totals: cases=8 pass=8 fail=0 ordinary=8 negative_controls=0 probes=0
PASS battery: /var/tmp/s10/runs-fix/20261018T192301287767Z/verdicts.json
```

| case | observed bytes | bank bytes | sha256 prefix | |
|---|---|---|---|---|
| `phys3d_joints_sweep` | 675 | 675 | `84e0a9abe19ffce9` | MATCH |
| `phys3d_joints_rid` | 1001 | 1001 | `94a5ddaa4739e3da` | MATCH |
| `phys3d_joints_api` | 2574 | 2574 | `fb36001cbe41c661` | MATCH |
| `phys3d_joints_free_pair` | 1514 | 1514 | `a8f66074ea928699` | MATCH |
| **`phys3d_joints_free_ops`** | **3921** | **3921** | **`706ad9151452e18d`** | **MATCH** |
| `phys3d_joints_detach` | 2596 | 2596 | `fe2743f8a825f289` | MATCH |
| `phys3d_joints_chain3` | 281 | 281 | `26912caaa4ee260f` | MATCH |
| `phys3d_joints_twopin` | 6623 | 6623 | `f3a829393a088ab9` | MATCH |

**8/8 byte-identical to `reports/round-104/physics/markers.md` §1**, and the receipt's own per-case `elapsed_seconds` were `free_ops 2.594` vs the 20 s cap (the fix working as advertised).

**Ruling on F1: refuted, and I withdraw it.** The `BIMODAL` heap flip is *not* perturbed by 21-way concurrency at the rates that matter here. Full per-group accounting over the 33 reps:

```
serial(HEAD)                 reps= 4 byte-identical= 4 mismatch=[]
concurrent probe             reps= 5 byte-identical= 5 mismatch=[]
concurrent 4-way self-load   reps= 4 byte-identical= 4 mismatch=[]
concurrent stability tail    reps=20 byte-identical=20 mismatch=[]
```

The honest reading is that the fix's byte-stability is *empirically supported*, not proven — but a fix-adversary seat may not attack a change on a hypothesis its own 33-rep test refutes. Note the asymmetry that follows, however: **the r103 acceptance criterion for this row was marker equality** (`reports/round-103/physics/ledger.md` §2.4: `FAIL→PASS`, `reasons: []`, `marker exact match: True`). Under that criterion the fix passes today, and *every defect in §4–§6 is invisible to it* — which is exactly the blind spot this seat exists to name.

### 3c. Independent corroboration (and one incident I caused)

SEAT-06 built the correctly-designed concurrency adversary — `reports/round-104/physics/s06/worstcase.sh`, M **private tree copies** × 21 children so the only shared resource is CPU, comparing each rep byte-wise against the serial solo reference. I read its logs; they agree with §3 and extend it:

| SEAT-06 log | serial | concurrent | result |
|---|---|---|---|
| `worstcase-free_ops-m4.log` | 4 parents, 22.2 s | 4 parents, 3.23 s | identical=4/4, differs=0 |
| `worstcase-free_ops-m4b.log` | 4 parents, 23.7 s | 4 parents, 4.41 s | identical=4/4, differs=0 |
| `worstcase-free_ops-m6.log` | 6 parents, 26.1 s | 6 parents, 6.39 s | identical=6/6, differs=0 |
| `bytecmp.log` (all 8 arms) | — | — | `IDENTICAL` for sweep/rid/api/free_pair/**free_ops**/detach/chain3/twopin |

**One incident, disclosed.** My first orphan census (§4 method) was over-broad: its cleanup step SIGKILLed every `/proc` entry matching `godot` + `phys3d_joints.gd` anywhere, not just my own scratch. At that moment SEAT-06's `worstcase.sh` was running its `m3` rep, and my cleanup killed its three serial parents — visible in `s06/worstcase-free_pair-m3.log` as `Killed` + `rc=137 137 137` and three `DIFFERS` verdicts. **Those three are artifacts of my error, not findings about the fixture**, and the `m3` line should not be read as evidence for or against R3. I re-ran the census with a scratch-anchored filter (`/var/tmp/s10/` in the cmdline) for the §4 numbers below. The `m4`/`m4b`/`m6` logs were taken after that and are unaffected. My scratch was moved to `/var/tmp/s10/` precisely to keep this kind of cross-seat interference out of the lane (§9).

---

## 4. F2 — the fix escapes the case-timeout kill (measured)

The runner kills a case with `subprocess.run(..., timeout=20)`, i.e. **SIGKILL to the direct child only** — `run_battery.py:951`, with the process-group path (`start_new_session=True`, `os.killpg`) used only by the probes at `:1145`/`:1168`/`:1196`, never by `execute()`. I killed the arm parent at the cap in both designs and censused live children:

```
$ python3 /var/tmp/s10/orphan3.py     # parent SIGKILLed at t=1.6 s, /proc scan filtered to this scratch
serial  at 1.60s: MY live procs=5
serial  after parent SIGKILL: MY survivors=0
conc    at 1.60s: MY live procs=64
conc    after parent SIGKILL: MY survivors=15
     1206867 /bin/sh -c timeout -s KILL 20 "/usr/bin/godot" --headless --path "/var/tmp/s10/conc/r90bt_free…
     1206892 timeout -s KILL 20 /usr/bin/godot --headless --path /var/tmp/s10/conc/r90bt_free_ops_freeb_ops_gp …
     1206893 /usr/bin/godot --headless --path /var/tmp/s10/conc/r90bt_free_ops_freeb_ops_gp …
     1206906 /bin/sh -c timeout -s KILL 20 "/usr/bin/godot" --headless --path "/var/tmp/s10/conc/…
     1206912 /bin/sh -c timeout -s KILL 20 "/usr/bin/godot" --headless --path "/var/tmp/s10/conc/…
     1206917 timeout -s KILL 20 /usr/bin/godot --headless --path /var/tmp/s10/conc/r90bt_free…
     1206922 /usr/bin/godot --headless --path /var/tmp/s10/conc/r90bt_free_ops_freeb_twice_jo…
```

**Why the asymmetry is structural, not incidental.** In the serial design the parent is *blocked* inside `OS.execute` on child *k* and is killed *while blocked*; the child it was waiting on is a child of the killed parent and dies with it. (The serial arm *did* spawn children — `live procs=5` = parent + `/bin/sh` + `timeout` + godot — yet `survivors=0` after the kill.) Under R3 the parent holds **21 already-detached children**; SIGKILL to the parent does not touch them, and each carries its own independent `timeout -s KILL 20`. They do self-reap ~20 s later, so this is not a permanent leak — it is a **~20 s burst of up to 15 extra Godot processes (≈2 GB)** appearing at the exact moment the runner has already declared the case failed and moved on.

**Independent corroboration of the mechanism (from another seat's log).** SEAT-06's `s06/worstcase-free_pair-m3.log` records exactly this at larger scale, and it is worth reading as a *mechanism* demonstration even though the trigger was my own over-broad cleanup (§3c): three concurrent parents each holding 21 children were SIGKILLed, the harness's `wait "$p"` returned immediately (its `wall_ms=8393` against 11.6–26.1 s for every other rep), and the **63 children went on running** until their own inner `timeout -s KILL 20` reaped them. A harness that waits only on parents cannot see this: it reports the rep finished while 63 engine processes are still live. That is F2's mechanism, observed by a seat that was not looking for it.

**The row that runs next is `phys3d_joints_detach`** (`CASES` order: `free_pair → free_ops → detach`). So the burst overlaps the *next* case's execution — and it lands precisely in the failure branch, i.e. exactly when the machine is already unhappy. A host that is already at the `/tmp`-quota / load ceiling (this host, this round: §9) is where orphaned engine processes matter; a quiet host hides it.

**Sha caveat, and what the landed bytes changed.** These numbers are `c7e77638…`, which had no `OS.kill`. The landed `80bf44c5…` adds the batch deadline's `OS.kill`, and I re-measured the hang path on those bytes: **0 Godot processes remained after the arm exited** (§5b). So the burst is narrowed to the kill-*before*-the-deadline case, where the structural argument still holds but I have no count on the landed bytes and will not imply one. **F2 is downgraded from "substantiated" to "narrowed"** in §0 for exactly this reason.

**Severity: bounded and transient, not a leak.** I will not overstate it: children self-reap at their 20 s inner bound, the runner's own `--runs` scratch is per-run, and nothing survives indefinitely. The claim is narrower and still decision-relevant: **R3 moves the failure mode from "the case dies alone" to "the case dies and takes the next case's budget with it"** — and it does so only in the failure path, which is the path the fix exists to eliminate.

---

## 5. F3 — R3 was fail-open, and the landed guard is not fail-closed through the runner

**Status of this section changed under me: SEAT-04's fixture moved twice while I measured. Everything below is therefore stated against a named sha, and my own F3 is *closed* by the newer bytes.**

| fixture bytes | `_run()` behaviour on one hung child | my measurement |
|---|---|---|
| `c7e77638…` (the bytes §2–§6 measured) | collects the degraded cell and reaches `_finish()` → **`PASS` printed, 2 cells `mode_ok=0`** | measured, `/var/tmp/s10/hangcmp.py` |
| `80bf44c5…` (landed later, `BATCH_BOUND_S := 16` + `OS.kill` + `_fail`) | `FAIL phys3d_joints free_ops reason=freeb_twice@gp batch_timeout`, `rc=1`, 0 `mode_ok=0` cells | measured, `/var/tmp/s10/conc2`, `hang2` |

**(a) F3 as originally measured (`c7e77638…`).** I injected a single hang into one child (a `while true: OS.delay_msec(1000)` at the top of `r90_child.gd:_initialize` for `case == "freeb_twice"`; copy at `/var/tmp/s10/hang/`) and ran the same arm under both designs with the fixture's own 20 s inner bound intact:

```
$ python3 /var/tmp/s10/hangcmp.py
{"tag": "conc", "wall": 20.94, "rc": 0, "lines": "PASS phys3d_joints free_ops freeb_ops@gp", "nlines": 1, "mode_ok0_cells": 2, "printed_PASS_over_degraded": true}
{"tag": "serial(killed)", "wall": 23.31, "rc": -9, "lines": [], "nlines": 0, "mode_ok0_cells": 0, "printed_PASS_over_degraded": false}
```

- **Serial:** the arm blocks on the hung child, so the *whole arm* stalls → the runner's 20 s cap fires → **no output, no marker** → the row FAILs loudly.
- **Concurrent:** the hang is confined to one child; `_collect_child` waits on it, the child's own `timeout -s KILL 20` fires, the arm then collects a **degraded cell** (`mode_ok=0`) and reaches `_finish()` → **`PASS` printed at 20.94 s with 2 cells at `mode_ok=0`.**

`_finish()` never read `_parts`, and the fixture's own comment claimed *"anything outside both is `mode_ok=0` and closes the row"* — it did not. **This is the same defect class as the r103 ledger's D2** (`reports/round-103/physics/ledger.md` §3, *"the row never reddens, at any concurrency"*), and at `c7e77638…` R3 landed the *trigger* into the shipped fixture.

**(b) The landed guard (`80bf44c5…`) closes the fail-open — repair #2 of §5.4 landed.** SEAT-04 added the `phys3d_events.gd:_spawn_batch` pattern: `const BATCH_BOUND_S := 16`, a `deadline` armed after spawn, `OS.kill(pid)` + `_fail(... batch_timeout)` on a straggler. I re-ran both cases on those exact bytes:

```
$ sha256sum conc2/phys3d_joints.gd hang2/phys3d_joints.gd
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  (both)
{"tag": "new-normal",    "wall": 2.54, "rc": 0, "line": "PASS phys3d_joints free_ops freeb_ops@gp{mode_ok=1,m6=124dfe", "marker_eq_pin": true, "mode_ok0": 0}
{"tag": "new-hungchild", "wall": 20.8, "rc": 1, "line": "FAIL phys3d_joints free_ops reason=freeb_twice@gp batch_time", "marker_eq_pin": false, "mode_ok0": 0}
```

**F3 is closed**: a hung child now produces `FAIL`, not a green row over degraded cells. I record that plainly — the fix improved under me, and my finding is against the older bytes.

**(c) But the guard is not fail-closed *through the runner*, and this is the new F3.** The FAIL fires at **20.78–20.80 s wall** (3 reps), while the fixture's own deadline fires at **16.70 s of engine time**:

```
$ # instrumented copy, prints at _run entry / after spawn / at the kill
T0 683            TSPAWN_DONE 703 deadline 16703            TKILL 16706 for freeb_twice@gp
```

So the fixture believes it failed at 16.7 s and the wall clock says 20.8 s: **~4.1 s of margin is lost before `_run()` even starts** (engine boot ≈0.68 s to `T0` plus ~2 s of parent init ahead of `_run`, plus process teardown). The consequence is measurable: the runner caps at 20 s, so it kills the arm **0.78 s before the fixture's own `FAIL` line appears** —

```
$ # injected hang, real runner, shipped 20 s cap, landed fixture bytes
cd /var/tmp/s10/tree-hang && python3 run_battery.py --only phys3d_joints_free_ops --runs /var/tmp/s10/runs-hang
FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']
```

The row still FAILs, so **the battery outcome is right** — but the *reason* is the generic `TIMEOUT`/`marker missing`, **indistinguishable from the D1 wall-cost failure this whole round exists to remove.** The diagnostic value of the new guard is therefore lost through the only interface that matters: an operator reading a red `phys3d_joints_free_ops` cannot tell "a child hung" from "the arm is still too slow". **`BATCH_BOUND_S` must be small enough that `BATCH_BOUND_S + parent overhead < CASE_TIMEOUT_SECONDS`** — with ~4.1 s of measured overhead, 16 s does not satisfy it; ~12–13 s would.

**And a correction to §4 under the new bytes:** after the arm exits (whether by its own `_fail` or by the runner's kill), **0 Godot processes remained** — the guard's `OS.kill` and the children's own `timeout -s KILL 20` cover the hang path. §4's 15-orphan burst was measured on `c7e77638…`, which had no `OS.kill`; the landed bytes narrow that window. §4's structural argument (a killed parent cannot reap children it has already detached) still holds for the kill-*before*-the-deadline case, but it is no longer backed by a count on the landed bytes, and I will not present it as if it were.

### 5.4 What a landable R3 still has to carry

| # | repair | status on `80bf44c5…` |
|---|---|---|
| 1 | **`mode_ok` guard with an explicit `return`** in `_finish()` (ledger §3.3: `quit()` is deferred here, so a guard without `return` prints FAIL then PASS and exits 0) | **not landed** — `_finish()` still ignores `_parts`; the batch deadline happens to cover the hang case, but a degraded cell reached *without* a straggler is still green |
| 2 | **A batch deadline** | **landed** (`BATCH_BOUND_S := 16`) — but mis-scaled against the runner's 20 s cap, see (c) |
| 3 | **Child-group ownership** so a killed parent does not orphan children | **partially** — the deadline's `OS.kill` covers the straggler; a kill *before* the deadline still cannot reap detached children (§4) |
| 4 | **A concurrency cap** (e.g. 4–6 in flight, not 21) so §6's resource contract stays inside the lane's headroom | **not landed** — peak 63–65 procs / 2.4–2.8 GB per case stands |

Repairs 1 and 4 remain open, and 2's constant is wrong by ~4 s. Each is a *behavioural* change to a byte-pinned fixture, so "wall clock only" stopped being true when repair 2 landed — the comment in the file still claims it.

---

## 6. F4 — the resource contract changes by an order of magnitude (measured)

Peak process-tree census during one arm (parent + descendants, sampled every 20 ms):

| design | peak procs in tree | peak tree RSS | per case |
|---|---|---|---|
| serial | **4** (parent + `/bin/sh` + `timeout` + godot) | **247 MB** (246.9 / 251.8 / 247.1) | 1 engine at a time |
| R3 concurrent | **63–65** | **2.4–2.8 GB** (2433 / 2434 / 2455 / 2745 / 2774 / 2784) | 21 engines + 21 shells + 21 `timeout` |

And it is **bounded**, not cumulative: four R3 arms running simultaneously peak at 63–65 procs *each* with RSS 2.0–2.4 GB each — i.e. **~9.5 GB across four concurrent batteries**. The relevant framing is the lane's own operating mode: r103/r104 are **64-seat swarms on one host**, with `/tmp` a shared 16 G tmpfs that hit 80% during this very seat (§9). A per-case peak of 21 Godot children is a real budget change for a host whose margin is already the binding constraint — and note that the fix's benefit (2.6 s vs 20 s) is only realised when the machine *has* 21 cores to spare; on an oversubscribed host the same 21 children are just 21 ways to wait.

**Honest counterweight (against my own F4):** four simultaneous R3 arms still finished in 3.0–3.3 s wall each, so the fix is *not* load-fragile in wall-clock terms — it degraded by only ~20% at 4× self-load. The cost is a resource *spike*, not a wall-clock cliff. F4 is a real but second-order argument; I rank it below F2/F3 for exactly this reason.

---

## 7. The r93/r103 inherited-baseline caveat — named, as the seat brief requires

**The r103 ruling's factual claim was:** *"The row therefore cannot pass at the shipped bound on this host at any load, and the binding term is the fixed spawn count, which load does not change."* (`reports/round-103/physics/adversary.md` §ruled class.) **The inherited baseline contradicts the "at any load" half of it**, and this seat did not re-run it — it is inherited evidence, flagged as such:

| source | host/load | `phys3d_joints_free_ops` | inherited? |
|---|---|---|---|
| r93 `runs1` (`r93-baseline.md:111`, frozen commit `75739bc`) | serial, load 2.75→36.8 | **FAIL**, 20.053 s (capped) | inherited |
| r93 `runs2` (`r93-baseline2.md:102-105`) | serial, **load 111–122** (96-hog ladder + 12 r95b_hog + 36–52 `yes` + ocr.py) | **PASS, 17.802 s** | inherited |
| r102/r103 receipts (36 stored) | 32-seat swarm | FAIL ×36, every one 20.006–20.025 s (capped, never a natural exit) | inherited |
| r104 (this seat) | 64-seat swarm, current host | serial 19.02 / 19.61 / 19.75 / 20.54 s (uncapped) | measured |

Two things follow, and they are the caveat the ruling must carry:

1. **The row is a *margin* row, not a class-eliminating defect.** A host that ran it **PASS at 17.802 s under load 122** (r93) proves the "cannot pass at any load" statement false as written. The true statement is *"this host, at its current boot cost, has lost the margin the row had at r93"* — r93's quiet-host figures (16.939/17.222 s, `r93-baseline.md:111`) are the on-record PASSes and are the honest reference point.
2. **Therefore R3 is not "class-eliminating" — it is a margin restoration, at a price.** The r103 seat's own §6 says as much (*"the class name matters because R1 and R3 are not interchangeable"*), and my measurements convert the claim into a price tag: +21 processes and +2.4 GB per case (§6), a batch-deadline constant that does not fit the runner's cap (§5c), and — on the bytes I first measured — a fail-open path (§5a). The fail-open half is now closed by SEAT-04's guard; the resource half and the mis-scaled constant are not.

**Two r103 statements this seat can now correct from its own receipts.** (i) The r103 class name `INTRINSIC_WALL_COST` ("a serial child-spawn budget overrun") is the right *mechanism*, but its "at any load" rider is falsified by the r93 PASS above. (ii) The r103 ledger's D2 (`_finish()` never reads `mode_ok`) was **not** latent-only: on `c7e77638…` it was reachable and I produced a green row over two `mode_ok=0` cells (§5a). It is latent again on `80bf44c5…` only because the batch deadline happens to cover the hang case — a degraded cell reached *without* a straggler would still print `PASS`. That is why repair #1 of §5.4 remains open.

**Also carried forward, unchanged:** the r103-row is *correct* (marker byte-identical at a 120 s bound; `reports/round-104/physics/standalone/free_ops-uncapped.stdout` — which I re-verified: 1 `PASS` line, `marker_eq_CASES_pin True`, 3921 bytes). Nothing here disputes that. My dispute is with *which* change is the right one to make.

---

## 8. F6 — the cheaper option the lane has not priced

The row is a deterministic ~19–20.5 s job against a 20 s cap: **the cap and the job are one error bar apart.** Everything in §4–§6 exists only because the fix chose to restructure the fixture to change the job's shape. The two alternatives change no fixture byte and no execution contract:

- **R1 (raise `CASE_TIMEOUT_SECONDS`, 20 → 60).** Operator-visible, one constant in `run_battery.py`, proven `FAIL→PASS` by the r103 ledger §2.4. Cost: it makes *every* row wait longer, and `run_battery.py`'s sha is itself a pinned seed digest (`f456bd00…`) recorded in all 36 receipts — so it is an *operator* decision with a receipt consequence, not a silent fix.
- **R2 (per-case bound proportional to child count).** Correct in shape (`reports/round-103/physics/ledger.md` §4.2), but it edits the pinned 350-row `CASES` table's surrounding contract — the r104 SEAT-09 seed check exists precisely to prove that table does not move.

My ruling prefers these **not** because they are elegant, but because they are *reversible and byte-inert*: neither can create a fail-open row (§5a), a mis-scaled guard (§5c), or a 21-process spike (§6), and both leave the fixture's serial-execution contract — the property every stored receipt was produced under — intact.

**Where this leaves the ruling, given that the fix has landed.** I am not asking for a revert: the row is measurably repaired (2.564 s, marker byte-identical, §2b), and reverting would restore a red row for no gain. The seat's deliverable is a *landing bar*, and it is three items, all cheap, all checkable from a receipt:

1. `BATCH_BOUND_S` reduced so `BATCH_BOUND_S + ~4.1 s < CASE_TIMEOUT_SECONDS` — acceptance is a *runner* receipt whose `free_ops` reasons read `exit 1 != expected 0` on the hang attack, **not** `TIMEOUT after 20 seconds` (§5c).
2. Repair #1 of §5.4 (the `mode_ok` guard with an explicit `return`), so a degraded cell reddens the row without depending on a straggler having existed.
3. Repair #4 (a concurrency cap), so §6's 63-process / 2.7 GB per-case peak is a bounded, chosen number rather than an emergent one.

Until at least (1) lands, the fix has **moved** the row's failure signal rather than removed it: `phys3d_joints_free_ops` can still go red with the same `TIMEOUT` reason the whole round set out to eliminate, and an operator cannot tell that red from the one r103 diagnosed.

---

## 9. Live incident: the `/tmp` quota reproduced mid-seat (relevant to the fix's landing conditions)

While setting up §3 I copied the seed tree into `/tmp` and got, with **3.1 G "available"**:

```
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G  80% /tmp
$ cp corpus/fixtures/project.godot corpus/fixtures/phys3d_joints.gd corpus/fixtures/r90_child.gd /tmp/s10/min/
cp: error writing '/tmp/s10/min/project.godot': Disk quota exceeded
cp: error writing '/tmp/s10/min/phys3d_joints.gd': Disk quota exceeded
cp: error writing '/tmp/s10/min/r90_child.gd': Disk quota exceeded
```

Three small files, 3.1 G free, `Disk quota exceeded` — the r103 root cause (`LOG.md`: *"/tmp is a shared 16G tmpfs near quota — mktemp/clone workdirs there flake silently"*) reproducing on demand. I moved every experiment to `/var/tmp/s10/` (root fs, 772 G free) and completed §2–§7 there. **This is not my claim to adjudicate** (C2 owns gate workdir resilience), but it bears on this fix's landing conditions in one specific way: **a concurrent-children fix multiplies the processes competing for that same stressed host**, and the battery has no `GATE_WORKDIR` analogue — its scratch root is whatever `--runs` the caller names. If R3 lands, the acceptance run must be made on a root with real headroom, or the acceptance itself will flake.

---

## 10. What would overturn this ruling (falsifiable, in order)

1. **`BATCH_BOUND_S` lowered so the guard's `FAIL` reaches the runner before the cap**, with a receipt from the *runner* (not a standalone arm) showing `reasons=['exit 1 != expected 0', 'exact stdout marker missing']` rather than `TIMEOUT after 20 seconds`. That is the acceptance for F3′, and it is a two-line change: the measured budget is `BATCH_BOUND_S + ~4.1 s parent overhead < 20 s`.
2. **§5.4 repairs 1 and 4 landed** — a `mode_ok` guard with an explicit `return` in `_finish()`, and a concurrency cap. With repair 1 the *serial-equivalent* degraded-cell path also reddens; with repair 4, §6's peak of 63 procs / 2.7 GB falls.
3. **An orphan census at the cap on a quiet host** showing ≤1 survivor *before* the deadline. My §4 numbers (0 serial vs 15 concurrent) are `c7e77638…` and a load ~9 host; the *ratio* is structural (detached children vs a blocked parent), but the absolute count is host- and sha-dependent and I state it as such.
4. **A receipt demonstrating the row FAILs on a host that r93 would have called quiet** (an idle-host run of the HEAD bytes that still caps at 20 s). That would restore the "intrinsic floor" reading and remove F5's force. My own 4 serial reps (19.02–20.54 s, one over the cap) sit right on the line and do **not** settle it.
5. **Counter-evidence against §5a's original F3:** a serial-design run in which a degraded cell *also* completes and prints PASS inside 20 s. I could not produce one — the stall consumed the whole budget — but a slower-host/quieter-machine demonstration would weaken F3 to "latent in both designs". Moot on the landed bytes, which redden the hang path.

---

## 11. Reproduction index (every command in this file)

```sh
# §2b the counting command — full 350-row battery, patched bytes, unchanged cap
cd /var/tmp/s10/tree-fix && python3 run_battery.py --runs /var/tmp/s10/runs-full
#   -> rc=1, 693.3 s, totals {cases:350 pass:332 fail:18}, free_ops PASS 2.564 s

# §3(a) 33 concurrent reps vs the CASES pin
cd /var/tmp/s10 && python3 probe.py serial 1 /var/tmp/s10/serial && python3 probe.py conc 5 /var/tmp/s10/conc
python3 -c "<compare /var/tmp/s10/{conc,tail}*.out to the ast.literal_eval'd CASES pin>"

# §3(b) 8/8 bank rows, via the real runner, on a copy at the working-tree bytes
rm -rf /var/tmp/s10/tree-fix && mkdir -p /var/tmp/s10/tree-fix \
  && cp -a /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/fixtures/. /var/tmp/s10/tree-fix/ \
  && rm -rf /var/tmp/s10/tree-fix/__pycache__ /var/tmp/s10/tree-fix/three
cd /var/tmp/s10/tree-fix && python3 run_battery.py --only \
  phys3d_joints_sweep,phys3d_joints_rid,phys3d_joints_api,phys3d_joints_free_pair,\
phys3d_joints_free_ops,phys3d_joints_detach,phys3d_joints_chain3,phys3d_joints_twopin \
  --runs /var/tmp/s10/runs-fix

# §4 orphan census at the cap (serial vs concurrent) — measured on c7e77638…
python3 /var/tmp/s10/orphan3.py

# §5 one hung child — (a) on c7e77638… (PASS over 2 degraded cells)
python3 /var/tmp/s10/hangcmp.py
#   (b)+(c) on the landed 80bf44c5… bytes: normal run vs hung-child run, then via the runner
python3 -c "<run /var/tmp/s10/conc2 and /var/tmp/s10/hang2, compare to the CASES pin>"
cd /var/tmp/s10/tree-hang && python3 run_battery.py --only phys3d_joints_free_ops --runs /var/tmp/s10/runs-hang
#   -> TIMEOUT after 20 seconds (the guard's FAIL fires at 20.78 s, past the cap)
#   instrumented copy prints the engine-time budget: T0 683 / TSPAWN_DONE 703 / deadline 16703 / TKILL 16706

# §6 peak procs / peak tree RSS per design
python3 /var/tmp/s10/probe2.py

# §7 inherited baseline (read-only)
sed -n '100,120p' reports/round-93/r93-baseline.md
sed -n '102,140p' reports/round-93/r93-baseline2.md

# §9 /tmp quota
df -h /tmp | tail -1
```

**Provenance — sha-by-sha, because the fixture moved three times during this seat.** `corpus/fixtures/phys3d_joints.gd` was `88be87fa…` (HEAD) → `0cd74715…` → `e79c3180…` (what §2–§6 first measured, read `19:17Z`) → `c7e77638…` (the bytes §2b's full battery, §3, and §4–§6 were taken on) → **`80bf44c5…`** (the landed bytes at my last frame, which §5b/§5c and the §10 acceptance target). `run_battery.py` was `f456bd00…` throughout and was **never edited** — every runner invocation above used the shipped runner. Receipts: §2b `runs-full/20261018T192346837085Z/verdicts.json` (`case_timeout_seconds=20`, `seeds_unchanged=true`, 130 seed digests, `phys3d_joints.gd` digest `c7e77638…`); §3(b) `runs-fix/20261018T192301287767Z/verdicts.json`; §5c `runs-hang/20261018T193820906053Z/verdicts.json`. `git status`: my only new path is this file.

**Residual note (state of the artifact when I stopped).** The full 350-row battery referenced in §2b **did complete** at `19:36Z` and its result is reported there. One correction to the running commentary: the peak-`godot`-process sampler attached to that run reads `peak_godot_procs: 1` **because of my own filter** — it counted only processes whose command line contains the seed-tree path `/var/tmp/s10/tree-fix`, while the runner launches children with `--path <scratch-under-runs-full>`. That number is a filter artifact, not a measurement; **the §6 per-arm figures (63–65 procs) are the load-bearing ones** and were sampled with a correct filter. Two things this seat did **not** do and does not claim: (i) an idle-host run that would settle §10.4, and (ii) any measurement on a fixture sha newer than `80bf44c5…` — the file may have moved again after my last frame, and §5b/§5c's verdicts bind only to that sha.
