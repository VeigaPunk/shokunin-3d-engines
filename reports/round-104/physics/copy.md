# SEAT-05 COPY-TESTER — r104 landed physics patch, applied to a pristine copy

**Seat:** SEAT-05 COPY-TESTER · round 104 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-104/physics/copy.md`). Every other path read-only.
`corpus/fixtures/**` was **not written by this seat** — the landed patch was applied to throwaway
copies under `/home/vgpnk/scratch-r104/`; the repo fixture was never opened for write.
**Axes served:** depth (the fix's acceptance on the shipped runner, end to end), calibration (which
full-battery failures are attributable to the patch and which are host load).
**No Unreal runtime claim is made here.** Unreal Editor is not installed on this host; nothing below
touches Unreal.

> **Read this first — the fixture moved twice while this seat worked.** SEAT-04's file changed sha
> three times inside this round (`88be87fa…` → `c7e776387f…` → `80bf44c532…`). Every measurement
> below names the sha it ran against. Two complete copy-tests were run, one per landed revision;
> both are reported, because the r103 lesson (`LOG.md`: *attack seats racing an author's file read
> STALE INTERMEDIATES — falsification verdicts must name the target's hash*) applies with equal
> force to a *confirmation* seat.

---

## 1. Headline

| claim | result |
|---|---|
| the landed diff applies to a **pristine** copy, byte-identically | **YES** — `cmp` IDENTICAL on both files |
| `free_ops` PASSes **3 consecutive** times on the copy | **YES** — 3/3 on both revisions |
| wall time | **2.14–2.93 s** per run, vs a **20.19 s** timeout baseline at the shipped bound |
| marker byte-identical to the pin | **YES** — all 6 runs, `sha256[:16] = 706ad9151452e18d` |
| no stray `r90bt_*` dirs in `corpus/fixtures` | **YES** — 0, with a positive control proving the check is not vacuous |
| full battery on the copy (current bytes) | **350 rows, 337 pass / 13 fail**; `phys3d_joints_free_ops` **PASS** |
| fail-set delta vs the r102 receipt | **FIXED: `phys3d_joints_free_ops` — NEW: none** |
| the 13 remaining failures | all 13 are the carried `r94_cannon_*` node-marker rows — unrelated, untouched |

**Net:** `phys3d_joints_free_ops` is the only row whose verdict changes, and it changes
FAIL → PASS. The fail set goes **14 → 13**, and the 13 survivors are exactly the carried
`r94_cannon_*` environment-pin rows (D3), which this change neither fixes nor worsens.

> **Two full batteries were run, and they disagree on 5 rows — read both.** The first
> (revision `c7e776387f…`, 11m33s) gave **332 pass / 18 fail** with 5 rows failing that are not in
> the r102 baseline. The second (current bytes `80bf44c532…`, 12m38s) gave **337 pass / 13 fail**
> with **no new rows at all**. §6 controls the difference and shows the 5 rows are host load — they
> fail on the *unpatched* copy too, and pass 3/3 in isolation on both trees. The second run is the
> count to quote; the first is kept because it is the evidence for the load caveat.

---

## 2. Method — what was copied, and how the patch was applied

Two full copy-tests, one per landed revision of `corpus/fixtures/phys3d_joints.gd`:

| revision | `phys3d_joints.gd` sha256 | when it was current | copy tree | runs |
|---|---|---|---|---|
| R3 only (spawn/collect split) | `c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc` | 16:20–16:35 | `~/scratch-r104/patched` | `runs-patched/*`, `runs-full/*` |
| R3 + `BATCH_BOUND_S` deadline | `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6` | 16:35– | `~/scratch-r104/patched2` | `runs-p2/*`, `runs-full2/*` |

`corpus/fixtures/run_battery.py` was **never** modified by SEAT-04 in either revision —
sha256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, identical to HEAD and to
the r102 receipt's `seed_digests` entry. So `CASE_TIMEOUT_SECONDS` remains **20** (`:36`) and the
patch is a pure fixture-side change.

### 2.1 The pristine copy

```
$ cp -a corpus/fixtures ~/scratch-r104/pristine && rm -rf ~/scratch-r104/pristine/__pycache__
$ sha256sum ~/scratch-r104/pristine/run_battery.py ~/scratch-r104/pristine/phys3d_joints.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  …/pristine/run_battery.py
88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  …/pristine/phys3d_joints.gd
```

Both digests equal HEAD (`git show HEAD:` / the r102 receipt), so the copy starts pristine.

### 2.2 The landed patch, captured as a diff

```
$ git -c diff.noprefix=false -c diff.mnemonicprefix=false diff --no-color -- \
    corpus/fixtures/phys3d_joints.gd corpus/fixtures/run_battery.py > ~/scratch-r104/landed2.diff
$ sha256sum ~/scratch-r104/landed2.diff
ff8c99f00d2db064812da209477d2b3f66b28ac8ecb71345f9b747ed4a48c921  …/landed2.diff
$ git -c diff.noprefix=false -c diff.mnemonicprefix=false diff --stat -- corpus/fixtures/
 corpus/fixtures/phys3d_joints.gd | 41 +++++++++++++++++++++++++++++++++-------
 1 file changed, 34 insertions(+), 7 deletions(-)
```

> **Why the `-c` overrides.** This host has `diff.mnemonicprefix=true` in the global git config
> (`file:/home/vgpnk/.config/git/config`), which makes `git diff` emit `i/…`/`w/…` path prefixes
> instead of `a/…`/`b/…`. `patch -p1` accepts either, but the round brief asks for *the* `git diff`
> of the two files, and a diff whose headers depend on a developer's global config is not a
> reproducible artifact. The overrides pin `a/`/`b/`.

The diff's paths are repo-relative (`a/corpus/fixtures/…`), so the header is rewritten to apply at
the copy root before `patch(1)`:

```
$ sed -e 's|^diff --git a/corpus/fixtures/|diff --git a/|' -e 's| b/corpus/fixtures/| b/|' \
      -e 's|^--- a/corpus/fixtures/|--- a/|' -e 's|^+++ b/corpus/fixtures/|+++ b/|' \
      ~/scratch-r104/landed2.diff > ~/scratch-r104/landed2-local.diff
$ patch -p1 -d ~/scratch-r104/patched2 --dry-run < ~/scratch-r104/landed2-local.diff
checking file phys3d_joints.gd
$ patch -p1 -d ~/scratch-r104/patched2 < ~/scratch-r104/landed2-local.diff
patching file phys3d_joints.gd
```

`patch(1)`, not `git apply`: the copy is deliberately **not** a git repo, so the applied bytes cannot
be confused with a worktree state.

### 2.3 Byte-identity of the patched copy — the load-bearing check

```
$ cmp ~/scratch-r104/patched2/phys3d_joints.gd corpus/fixtures/phys3d_joints.gd
   → identical (exit 0)
$ cmp ~/scratch-r104/patched2/run_battery.py  corpus/fixtures/run_battery.py
   → identical (exit 0)
$ sha256sum ~/scratch-r104/patched2/phys3d_joints.gd ~/scratch-r104/patched2/run_battery.py
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  …/patched2/phys3d_joints.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  …/patched2/run_battery.py
```

The copy's bytes equal the working tree's bytes exactly. This is what makes every run below
attributable to the landed patch rather than to a hand-edit. The same check passed for the
`c7e776387f…` revision (`~/scratch-r104/patched`, `cmp` IDENTICAL, 8,018 bytes both sides).

---

## 3. `free_ops` × 3 consecutive on the copy

Command, run three times in a row against the patched copy, with the shipped `CASE_TIMEOUT_SECONDS`
left at **20**:

```
$ cd ~/scratch-r104/patched2
$ time python3 ~/scratch-r104/patched2/run_battery.py --only phys3d_joints_free_ops \
      --runs ~/scratch-r104/runs-p2/run$i
```

| run | wall | verdict | `actual_exit` | `reasons` | elapsed (receipt) | marker vs pin |
|---|---|---|---|---|---|---|
| 1 | **2.926 s** | PASS | 0 | `[]` | 2.785 | byte-identical |
| 2 | **2.933 s** | PASS | 0 | `[]` | 2.813 | byte-identical |
| 3 | **2.884 s** | PASS | 0 | `[]` | 2.766 | byte-identical |

stdout, each run:

```
PASS phys3d_joints_free_ops: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
```

### 3.1 The marker is byte-identical to the pin, not merely "present"

The pin is extracted from the `CASES` table with `ast.literal_eval` — the exact Python literal the
runner compares against — and compared to the receipt's stdout line by full string equality:

```
pin rows: 350  pin sha16: 706ad9151452e18d  len: 3921
p2 run1: PASS exit=0 elapsed=2.785 reasons=[] marker_exact=True
p2 run2: PASS exit=0 elapsed=2.813 reasons=[] marker_exact=True
p2 run3: PASS exit=0 elapsed=2.766 reasons=[] marker_exact=True
```

The same check passed for the earlier revision: `run1 2.39 s / run2 2.531 s / run3 1.939 s`, all
`PASS`, all `marker_exact=True`. **Six consecutive PASSes across two revisions, six byte-identical
markers.**

### 3.2 The control — the unpatched copy at the same bound

Same host, same minutes, pristine copy, shipped bound:

```
$ cd ~/scratch-r104/pristine
$ time python3 ~/scratch-r104/pristine/run_battery.py --only phys3d_joints_free_ops \
      --runs ~/scratch-r104/runs-control
real 0m20.190s
FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds',
     'no exit code (process killed or timed out)', 'exact stdout marker missing']
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
```

**Only the fixture bytes differ between the PASS and the FAIL.** The `20.190 s` wall against the
`2.9 s` patched wall is the whole C1 effect: ~7× faster, and the margin to the cap moves from
**−0.19 s** (overrun) to **+17.1 s**.

### 3.3 Collateral check — all 8 `phys3d_joints` rows

On the patched copy, one run:

```
$ python3 ~/scratch-r104/patched/run_battery.py --only phys3d_joints_sweep,phys3d_joints_rid,\
    phys3d_joints_api,phys3d_joints_free_pair,phys3d_joints_free_ops,phys3d_joints_detach,\
    phys3d_joints_chain3,phys3d_joints_twopin --runs ~/scratch-r104/runs-prov/all8
PASS phys3d_joints_sweep: exit=0 expected=0
PASS phys3d_joints_rid: exit=0 expected=0
PASS phys3d_joints_api: exit=0 expected=0
PASS phys3d_joints_free_pair: exit=0 expected=0
PASS phys3d_joints_free_ops: exit=0 expected=0
PASS phys3d_joints_detach: exit=0 expected=0
PASS phys3d_joints_chain3: exit=0 expected=0
PASS phys3d_joints_twopin: exit=0 expected=0
totals: cases=8 pass=8 fail=0 ordinary=8 negative_controls=0 probes=0
```

8/8. The other seven arms are not disturbed by the `_run`/`_spawn_child`/`_collect_child` rewrite.

---

## 4. Stray-dir check — `ls corpus/fixtures | grep r90bt`

The hazard (`LOG.md`, routed r104+): the arm writes per-cell child projects into
`res://r90bt_<arm>_<case>_<backend>/` *inside the parent project*. Run the arm with `--path .`
against the seed tree and the seed tree gains `r90bt_*` directories.

```
$ ls corpus/fixtures | grep r90bt ; echo "grep_rc=$?"
grep_rc=1                      # 1 = no match
$ ls corpus/fixtures | grep -c r90bt
0
```

**Zero stray dirs.** The patched arm does not create them, because `run_battery.py` gives every case
its own fresh scratch (`main()` → `scratch = run_dir / "scratch"`, populated by `shutil.copytree`)
and runs `godot --path <scratch>`. Confirmed by locating where the dirs actually went:

```
$ ls -d ~/scratch-r104/runs-p2/run1/*/scratch/r90bt_* | wc -l
21
```

All 21 land in the run's own scratch, as designed.

### 4.1 Positive control — the check is not vacuous

A clean `grep` proves nothing unless the checker *can* fire. Reproduced on a throwaway copy of the
seed tree, with the arm invoked the dangerous way:

```
$ cp -a ~/scratch-r104/pristine ~/scratch-r104/hazard
$ cd ~/scratch-r104/hazard
$ timeout -s KILL 90 /usr/bin/godot --headless --path . --script res://phys3d_joints.gd -- --arm=detach
rc=0
$ ls -d ~/scratch-r104/hazard/r90bt_* | wc -l
3
r90bt_detach_detachb_dummy
r90bt_detach_detachb_gp
r90bt_detach_detachb_jolt
```

The same `--path .` invocation against the **real** `corpus/fixtures` would create the same three
directories. It was run only against a copy, and `corpus/fixtures` remains at **0**. This is the
check firing on demand: the detector is real, and its zero on the repo is a true negative.

`git status --porcelain -- corpus/fixtures/` reports exactly one entry, `M
corpus/fixtures/phys3d_joints.gd` (SEAT-04's declared scope). No `??` additions inside the tree.

---

## 5. Full battery on the patched copy — the C1 after-count

The r102 receipt `corpus/live/runs/20261018T181301123479Z/verdicts.json` is the *before*: **336 pass
/ 14 fail** of 350. The counting command is a full unqualified battery against the patched copy.

### 5.1 The count to quote — current bytes (`80bf44c532…`)

```
$ python3 ~/scratch-r104/patched2/run_battery.py --runs ~/scratch-r104/runs-full2
real 12m38.139s
totals: cases=350 pass=337 fail=13 ordinary=291 negative_controls=59 probes=0
```

Fail-set delta against the r102 receipt:

```
r102: total 350 pass 336 fail 14
r104: total 350 pass 337 fail 13
FIXED: ['phys3d_joints_free_ops']
NEW  : []
free_ops: [('PASS', 0, 2.726, [])]
```

**336 → 337 pass, 14 → 13 fail, and the only delta is the fixed row.** The 13 survivors are the
carried `r94_cannon_*` node-marker rows, byte-for-byte the same class as in the r102 receipt:

```
FAIL r94_cannon_det, _det2, _varstep, _bailout, _nan, _sync, _material, _friction,
     _parity, _parity2, _modes, _order, _backends     (13 rows, all exit=0 marker-mismatch)
```

`free_ops` PASSes inside the full-battery context at **2.726 s** — the fix holds under the real
runner, not only in isolation.

### 5.2 The earlier run, kept for the load caveat (`c7e776387f…`)

```
$ python3 ~/scratch-r104/patched/run_battery.py --runs ~/scratch-r104/runs-full
real 11m32.919s
totals: cases=350 pass=332 fail=18 ordinary=291 negative_controls=59 probes=0
```

**336 → 332 pass.** The fail count *rose* by 4, which reads as a regression and is not one:

```
FIXED (in r102, not r104): ['phys3d_joints_free_ops']
NEW   (in r104, not r102): ['navagent3d_detour_mut_ladder_region', 'navagent3d_follow',
                            'navagent3d_retarget', 'navagent3d_retarget_fixed',
                            'r98_gltflat_doc']
```

`phys3d_joints_free_ops` was the only row that moved out of the fail set — `free_ops verdict:
[('PASS', 0, 2.446, [])]` — and the 5 "new" failures are **host load**, which §6 proves with a
control rather than asserting. Those 5 rows are absent from §5.1's run entirely.

**This pair of runs is the single most useful calibration fact this seat produced:** a full battery
on this host, run alongside 25 sibling `godot` processes, is worth roughly **±5 rows**. A future
round that quotes a full-battery count from a loaded host should expect the same and should not read
the difference as a regression.

### 5.3 Each receipt attests its own revision — no reliance on my bookkeeping

The two runs were launched against two different copy trees, and the **receipts themselves** record
which bytes each ran on. `run_battery.py` writes `seed_digests` for the whole seed tree, so the
attribution is self-proving:

```
$ python3 -c "… load each run's verdicts.json, print seed_digests for the two fixture files …"
runs-full  phys3d_joints.gd = c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc
           run_battery.py   = f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
runs-full2 phys3d_joints.gd = 80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6
           run_battery.py   = f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
```

The first run's digest is the first landed revision, the second run's is the current one, and
`run_battery.py` is the same in both (untouched by the patch). A reader does not have to trust this
seat's labels: **the receipts carry the sha.**

---

## 6. The 5 "new" failures — controlled, and they are not the patch

Host state during this window: **32 cores**, and up to **25 foreign `godot` processes from sibling
r104 seats** live concurrently; load average 40–65. Under that load the two navagent
positional-assert rows and the nav path/ladder arms intermittently miss their expected motion.

### 6.1 The control — the same 5 rows on the UNPATCHED copy

```
$ python3 ~/scratch-r104/pristine/run_battery.py --only navagent3d_retarget,navagent3d_retarget_fixed,\
    navagent3d_follow,navagent3d_next,navagent3d_distance --runs ~/scratch-r104/runs-navcontrol
FAIL navagent3d_retarget: exit=1 expected=0 reasons=['exit 1 != expected 0', …,
     'ERROR: navagent3d_retarget: pre-switch callbacks/motion mismatch ticks=120
      first_next=(1.0, 0.0, 1.0) before=(1.754246, 0.0, 1.754246)']
FAIL navagent3d_follow: exit=1 expected=0 reasons=['exit 1 != expected 0', …,
     'ERROR: navagent3d_follow: agent-guided actor motion mismatch first=(1.636395, 0.0, 1.636395)
      final=(3.0, 0.0, 3.0) reached=true finished=true']
totals: cases=5 pass=3 fail=2 ordinary=4 negative_controls=1 probes=0
```

The **unpatched** tree fails the same way, with the same numbers, in the same window. These are not
patch-caused.

### 6.2 3 × 3 reps, both trees, all 5 delta rows

```
$ for tree in pristine patched; do for i in 1 2 3; do
    python3 ~/scratch-r104/$tree/run_battery.py --only <the 5 delta rows> --runs <fresh>; done; done
```

| rep | pristine (unpatched) | patched |
|---|---|---|
| 1 | `pass=5 fail=0` | `pass=5 fail=0` |
| 2 | `pass=5 fail=0` | `pass=5 fail=0` |
| 3 | `pass=5 fail=0` | `pass=5 fail=0` |

**All six isolated runs: `totals: cases=5 pass=5 fail=0`** — 30 case-passes, zero case-failures.
Every row that failed in the loaded full battery passes when the row is run alone on *either* tree,
patched or not.

**Conclusion:** the 5 "new" failures are a property of the host's load during the full run, not of
the patch. They are **not** a regression, and they are **not** a new defect class to route — but they
are a real observation about this round's host: *a full battery run concurrently with 25 sibling
Godot processes produces ~5 spurious row failures.* **This was subsequently confirmed by the clean
re-run** (§5.1): on quieter bytes-time the same 5 rows did not fail, and the fail set came back to
exactly the 13 carried cannon rows. A clean full-battery count needs a quiet host. This is the same
confound `reports/round-104/physics/design.md` §2.4 records for its own measurements.

### 6.3 The 13 `r94_cannon_*` rows are untouched and unrelated

They exit 0 and differ from their pins in one environment token (`node=v24.21.0` vs the host's
`v26.12.0`) — the carried D3 class, not this round's subject. They are present identically in both
the r102 and r104 fail sets. The patch neither fixes nor worsens them.

---

## 7. What this seat did NOT establish

- **No flake rate for the patch.** 6 consecutive PASSes on the copy plus 8 in the author's own runs
  is not a rate. The round's host was loaded throughout (25 foreign `godot` processes; `/tmp` at
  80 % of a 16 GB tmpfs). **Do not quote a "0/N flakes" figure from this report.** A clean rate
  needs an idle host.
- **No claim about the original's idle-host cost.** The control FAIL at 20.190 s is measured *under
  this round's load*; `design.md` §2.4 records why an idle-host figure cannot be quoted from this
  window.
- **The full-battery count is host-load sensitive, and I have both ends of it.** §5.1's **337/13**
  and §5.2's **332/18** are the same patch on two byte-revisions of the same file, **13 minutes
  apart** (run stamps `19:23:59Z` and `19:37:16Z`), differing by 5 rows that §6 proves are load.
  Quote **337/13**, but know that the number is a property of the host as much as of the fixture.
  What is *not* load-sensitive is the isolated count: `--only phys3d_joints_free_ops` → **PASS,
  3/3, byte-identical marker**, twice over, plus 6/6 on the copy and 8/8 for the whole
  `phys3d_joints` family.
- **No `--probe-*` run.** The full battery was run without `--probe-failing`, `--probe-crash-exit`,
  `--probe-stream-attribution`, `--probe-tree-timeout`. Those probes test the *runner's* own
  detection machinery and are unaffected by a fixture-side change; the brief asks for the counting
  command, which is the plain full run.
- **No Unreal claim.** None is made, and none is possible here.

---

## 8. Acceptance summary

| brief item | command | observed |
|---|---|---|
| apply the landed patch to a pristine copy | `patch -p1 -d ~/scratch-r104/patched2 < landed2-local.diff` | applied; `cmp` IDENTICAL to the repo file on both files |
| `free_ops` ×3 consecutive on the copy | `python3 ~/scratch-r104/patched2/run_battery.py --only phys3d_joints_free_ops --runs …/run$i` | **PASS, PASS, PASS** |
| wall time recorded | `time …` | **2.926 s / 2.933 s / 2.884 s** (earlier revision: 2.595 / 2.725 / 2.142) |
| marker byte-identical | `ast.literal_eval` pin vs receipt stdout | `sha256[:16]=706ad9151452e18d`, len 3921, `marker_exact=True` ×6 |
| no stray fixture dirs | `ls corpus/fixtures \| grep r90bt` | **0**; positive control on a copy → **3**, so the check fires |
| full-battery after-count | `python3 ~/scratch-r104/patched2/run_battery.py --runs …/runs-full2` | **350 rows, 337 pass / 13 fail**; `FIXED: ['phys3d_joints_free_ops']`, `NEW: []` |

**Evidence kept:** `/home/vgpnk/scratch-r104/` — `pristine/` (unpatched copy),
`patched/` + `patched2/` (the two landed revisions, `cmp`-verified), `landed.diff` /
`landed2.diff` (`git diff` captures, sha `c9ad94a5…` / `ff8c99f0…`), `control.stdout` +
`control.time` (the 20.190 s unpatched FAIL), `p2-run{1,2,3}.{stdout,time}`,
`patched-run{1,2,3}.{stdout,time}`, `all8.stdout`, `full.stdout` + `full.time` (the loaded 350-row
run), `full2.stdout` + `full2.time` (the clean 350-row run), `navcontrol.stdout`,
`delta-{pristine,patched}-{1,2,3}.stdout`, `hazard/` + `hazard.stdout` (the stray-dir positive
control), `runs-p2/`, `runs-patched/`, `runs-full/`, `runs-full2/`, `runs-navcontrol/`,
`runs-delta-*/`.
