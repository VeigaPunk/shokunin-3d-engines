# SEAT-04 PHYS-AUTHOR — r104 wall-cost fix landed in `phys3d_joints.gd`

**Seat:** SEAT-04 PHYS-AUTHOR · round 104 · lane `game-dev-3d-shokunin`
**Owned paths written:** `corpus/fixtures/phys3d_joints.gd` (the fix) and this file. Run artifacts
under `reports/round-104/physics/{author-runs,author-runs-all,author-runs-final,author-runs-all-final,author-reps,author-runs-full,author-runs-full-final,nc,nc-orig,hang,hang-asis}`.
`corpus/fixtures/run_battery.py` was **read only** — the shipped 20 s bound is unchanged.
**Claim served:** C1 (depth) — fix the `phys3d_joints_free_ops` wall-cost.
**Axes:** depth (the row now passes inside the shipped bound), calibration (the row's class vs the 13
`r94_cannon_*` rows).

**No Unreal runtime claim is made here.** The editor is not installed on this host; this seat makes no
claim about Unreal at all.

---

## 1. Headline

The r103 ruling's preferred fix — **R3, stop serialising the 21 children** — is **landed and passing
inside the shipped bound**. The row that failed 28/28 receipts at the 20 s cap now passes at **2.3–2.9 s**
with a marker **byte-identical** to SEAT-03's bank.

| | before (r103/r104-before) | after (this seat) |
|---|---|---|
| `phys3d_joints_free_ops` verdict | **FAIL** `TIMEOUT after 20 seconds` | **PASS** |
| elapsed | 20.008 s (pinned to cap) | **2.346 s** (8-arm run) / 2.5–2.9 s (5 isolated reps) |
| `actual_exit` | `None` | **0** |
| `reasons` | 3 (timeout, no exit code, marker missing) | **`[]`** |
| marker | absent | **3921 bytes, sha16 `706ad9151452e18d`** = SEAT-03 bank |
| whole battery | 336 pass / 14 fail | **337 pass / 13 fail** (only `free_ops` flipped; **zero** regressions); the final-bytes run is 336/14, differing from 337/13 **only** by the pre-existing `bpy_rbw3d_render` flake (§3.4.1) |

`run_battery.py` is untouched: `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`.
`phys3d_joints.gd` moved `88be87fa…` → **`80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6`**
(this sha must be re-recorded in the r104 close-out; the r103 receipt's `88be87fa…` is stale).

---

## 2. The change — minimal diff, 41 lines

`git diff --numstat -- corpus/fixtures/phys3d_joints.gd`: **34 insertions(+), 7 deletions(-)** (the
file is 180 → 207 lines).

Three edits, no other file:

1. **`_run` (`:86-108`) — two passes.** Spawn every `(case, backend)` child into `jobs`, then collect
   and `_emit` them walking the same `ARM_CASES[arm]` × `BACKENDS` order.
2. **`_run_child` → `_spawn_child` + `_collect_child` (`:134-183`).** The split is at the old
   `OS.execute` seam: `OS.execute("/bin/sh", ["-c", cmd], [], false)` (blocking) →
   `OS.create_process("/bin/sh", ["-c", cmd], false)` (non-blocking, returns a pid); `_collect_child`
   polls the pid, reads the exit code, scans the log.
3. **`const BATCH_BOUND_S := 16` (`:30`) + a deadline in the collection loop.** See §4 — this is the
   addition SEAT-01's `design.md` §3.1 specifies, and it closes a fail-open hole in the first cut.

Everything the marker depends on is **unchanged**: the `cmd` string, the `r90bt_<arm>_<case>_<bk>`
dirname namespacing, the stale-log unlink, the log scan, `_emit`, `_finish`, `BIMODAL`, `ARM_CASES`.

### 2.1 Why output cannot reorder

The emitted line is `" ".join(_parts)`; `_parts` is appended by `_emit`, which `_run` calls in the
**original nested-loop order** over the collected results. R3 changes *when* a child runs, never
*what* is appended nor in what order. Byte-identity is therefore structural, not a coincidence of
timing. This is the design's stated invariant (SEAT-01 `design.md` §3, §4) and the r103 ledger's R3
precondition (per-arm scratch) holds because the runner gives every case a fresh scratch.

### 2.2 A latent bug also fixed

The original `_run` called `_fail("unknown_arm")` **without `return`**, and `quit()` is deferred in
this fixture — so the `for case in ARM_CASES[arm]` loop kept running over a missing key. Observed on
`git show HEAD:corpus/fixtures/phys3d_joints.gd` with `--arm=bogus`:

```
FAIL phys3d_joints bogus reason=unknown_arm
SCRIPT ERROR: Invalid access to property or key 'bogus' on a base object of type 'Dictionary'.
          at: _run (res://phys3d_joints.gd:88)
```

Post-fix, same command: `FAIL phys3d_joints bogus reason=unknown_arm`, **rc=1, no SCRIPT ERROR**.
This is the same deferred-`quit()` trap the r103 ledger §3.3 names; no battery row reaches it, so it
is a latent-defect fix, not a behaviour change.

---

## 3. Acceptance — the commands and their observed output

### 3.1 A-D1 / A-R3, the C1 row (shipped bound, unmodified runner)

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops \
      --runs reports/round-104/physics/author-runs-final
PASS phys3d_joints_free_ops: exit=0 expected=0

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
PASS     phys3d_joints_free_ops             phys3d_joints.gd           --arm=free_ops     0/0       ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: …/author-runs-final/20261018T193509710404Z/verdicts.json
```

Receipt row: `verdict PASS`, `actual_exit 0`, `error None`, **`reasons []`**, `elapsed_seconds 2.687`,
`seeds_unchanged True`, and the stdout PASS line is **byte-equal to the pin** (3921 bytes, sha16
`706ad9151452e18d`). Verified by re-parsing the `CASES` table with `ast.literal_eval` and comparing
strings — not by grep.

### 3.2 The whole phys3d family, all 8 arms `--only`

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_sweep,phys3d_joints_rid,phys3d_joints_api,\
phys3d_joints_free_pair,phys3d_joints_free_ops,phys3d_joints_detach,phys3d_joints_chain3,phys3d_joints_twopin \
      --runs reports/round-104/physics/author-runs-all-final
totals: cases=8 pass=8 fail=0 ordinary=8 negative_controls=0 probes=0
```

Every one of the 8 rows' PASS lines is **byte-equal to its own pin** (`==bank 8/8`):

| row | elapsed | sha16 | == pin |
|---|---|---|---|
| `phys3d_joints_sweep` | 1.822 s | `84e0a9abe19ffce9` | yes |
| `phys3d_joints_rid` | 1.752 s | `94a5ddaa4739e3da` | yes |
| `phys3d_joints_api` | 1.723 s | `fb36001cbe41c661` | yes |
| `phys3d_joints_free_pair` | 2.490 s | `a8f66074ea928699` | yes |
| **`phys3d_joints_free_ops`** | **2.346 s** | **`706ad9151452e18d`** | **yes** |
| `phys3d_joints_detach` | 1.967 s | `fe2743f8a825f289` | yes |
| `phys3d_joints_chain3` | 2.613 s | `26912caaa4ee260f` | yes |
| `phys3d_joints_twopin` | 2.291 s | `f3a829393a088ab9` | yes |

### 3.3 Stability — 5 isolated reps

```
PASS elapsed=2.668 ==pin=True
PASS elapsed=2.806 ==pin=True
PASS elapsed=2.824 ==pin=True
PASS elapsed=2.506 ==pin=True
PASS elapsed=2.583 ==pin=True
all 5 PASS and byte-identical: True   elapsed min/max 2.506 / 2.824
```

### 3.4 The full battery — the counting command

```
$ python3 corpus/fixtures/run_battery.py --runs reports/round-104/physics/author-runs-full
totals: cases=350 pass=337 fail=13 ordinary=291 negative_controls=59 probes=0
```

The receipt records `seed_digests['phys3d_joints.gd'] = c7e77638…` — this run was taken **before** the
`BATCH_BOUND_S` deadline was added, i.e. against the R3-only patch. A second full-battery run against
the final `80bf44c5…` bytes is `author-runs-full-final` (§3.4.1).

Set-difference against the r102 receipt `corpus/live/runs/20261018T181301123479Z/verdicts.json`
(336/350, 14 fail):

```
before fails 14   after fails 13
flipped FAIL->PASS: ['phys3d_joints_free_ops']
newly FAILed: []
previously PASS rows that regressed: []
```

**Exactly one row moved, in the right direction.** The 13 remaining fails are all `r94_cannon_*`,
`exit 0`, single reason `exact stdout marker missing` — and for **13/13** the pin and the observation
are equal after normalising only the node token (`node=v…` → `node=vX`), i.e. the D3 environment-pin
class the r103 ledger §6 names. Fixing those is a **separate change by a separate owner** (ledger §6:
"do not repair both in one change").

### 3.4.1 Full battery on the final (deadline) bytes

```
$ python3 corpus/fixtures/run_battery.py --runs reports/round-104/physics/author-runs-full-final
totals: cases=350 pass=336 fail=14 ordinary=291 negative_controls=59 probes=0
```

Receipt `…/author-runs-full-final/20261018T193620808009Z/verdicts.json` records
`seed_digests['phys3d_joints.gd'] = 80bf44c5…` (the final bytes) and `seeds_unchanged: True`. In it,
`phys3d_joints_free_ops` is **PASS, exit 0, elapsed 2.906 s, `reasons []`, marker byte-identical to
the pin**, and all 8 phys3d rows are `==pin`.

**The 336 vs 337 difference between the two full runs is `bpy_rbw3d_render`, not a physics row.** It
is the lane's longest-standing **documented stochastic flake** (`reports/round-101/bpy-dissection.md`;
`reports/round-102/repairs/F3-sha-drift.md:365` calls it "marker flake under load … passes in the
other 3"):

- Its marker differs by exactly **one token**: `rdet same_state stable=True` (observed) vs
  `stable=False` (pin) — a single boolean, no other byte.
- Across the whole receipt corpus that token is `PASS / stable=False` **16×** and
  `FAIL / stable=True` **3×**; my two runs produced one of each (run 1 PASS `stable=False`, run 2
  FAIL `stable=True`), i.e. the flip is the row's own bistability, not my change.
- It is row **#233** in `CASES` against `free_ops` at **#221**, and `bpy_rbw3d.gd` references
  `phys3d_joints.gd` only in a comment (`:8`). No shared code.

So both full runs agree on the C1 row and on all 13 `r94_cannon_*` D3 rows; they differ only by a
pre-existing Blender flake whose value is independent of this change.


### 3.5 The in-family precedent the deadline follows

`corpus/fixtures/phys3d_events.gd` already spawns parallel child batches for this same class of
defect, and it documents the exact semantics my deadline copies:

- `:372` `const BATCH_BOUND_S := 12`, with the comment at `:358-360`: *"BATCH_BOUND_S bounds a whole
  parallel child batch as a fail-closed net on top of each child's own `timeout -s KILL` (a batch
  that outlives it is a named failure, never a silent partial row)."*
- `:619-655` `_spawn_batch`: `OS.create_process` per child, `OS.is_process_running` poll against a
  whole-batch deadline, then `OS.kill` any still-running child and scan.

My patch is the same shape, sized for this arm: **16 s** (below the runner's 20 s cap so it can
actually fire; above the worst healthy batch ever measured here, ≈2.9 s). The only deliberate
difference is where the timeout is *reported* — `phys3d_events.gd` records `res["batch_timeout"]`
for the caller to judge, while this fixture's row must be a single line, so it prints the named
`FAIL … batch_timeout` the design's §3.1 specifies.



### 3.6 Reentrancy — the r103 D2 hazard, tested directly

Four arms concurrently on **one** scratch (the exact trigger the r103 ledger §3.2 documents):

```
arm1 PASS=1 FAIL=0  arm2 PASS=1 FAIL=0  arm3 PASS=1 FAIL=0  arm4 PASS=1 FAIL=0
all four ==pin: True (sha16 706ad9151452e18d), mode_ok=0 cells: 0
```

All four emitted the pin byte-for-byte with **zero** degraded cells. R3 does **not** fix the shared-
scratch reentrancy defect and is not sold as doing so; the runner gives each case a fresh scratch.

---

## 4. The gap in the first cut, and why the deadline is in the landed file

The first version of this patch was R3 alone (no deadline). SEAT-01's `design.md` §5 measured that
`_collect_child` polling **unboundedly** fails **open** when a child is starved. I reproduced that
finding independently and it is decisive:

**Attack** — a throwaway copy with a 30 s stall injected into `r90_child.gd` on `freeb_twice` only
(`reports/round-104/physics/hang*/`):

| tree | rc | wall | verdict line | marker vs pin |
|---|---|---|---|---|
| R3 as-landed (no deadline) | **0** | 20.85 s | `PASS phys3d_joints free_ops …` | **3 cells differ** |
| R3 + `BATCH_BOUND_S` deadline (**landed**) | **1** | 16.84 s | `FAIL phys3d_joints free_ops reason=freeb_twice@gp batch_timeout` | n/a (no PASS) |

The as-landed output's differing cells, parsed against the pin:

```
freeb_twice@gp    got mode_ok=0,m4=e3b0c44298fc1c14   exp mode_ok=1,m4=e7c8b9cc20d38b1e
freeb_twice@jolt  got mode_ok=0,m4=e3b0c44298fc1c14   exp mode_ok=1,m4=c42295756101d8d6
freeb_twice@dummy got rc=137,m=,e=0,w=0               exp rc=0,m=M0 case=freeb_twice …
```

`e3b0c44298fc1c14` is the sha16 of the **empty string** — the truncated log was read empty — and the
dummy cell carries `rc=137` (the SIGKILL the inner bound delivered) with a zero-length `m=`. So the
row prints **`PASS`**, exits **0**, over a **corrupt** marker. Under the runner that surfaces as
`['exact stdout marker missing']` with `actual_exit: 0` — textually identical to the 13 cannon
environment-pin failures, i.e. maximally ambiguous.

**This is why the landed file carries the deadline.** 16 s is below the runner's 20 s cap (so it can
actually fire before the runner kills the row) and above every healthy batch ever measured here
(worst healthy 8-arm batch ≈ 2.9 s). It converts CPU starvation into a **named** failure. The happy
path is unaffected: 2.35–2.9 s with the exact marker, same as the deadline-free variant.

---

## 5. Tree hygiene

- `git status --porcelain -- corpus/fixtures/` shows **only** ` M corpus/fixtures/phys3d_joints.gd`
  (this seat). `run_battery.py`, `r90_child.gd` and every other fixture byte are untouched.
- `seeds_unchanged: True` in every receipt (130 seed digests, taken before and after each run).
- No `r90bt_*` child-project directory leaked into `corpus/fixtures/` (`ls corpus/fixtures | grep -c '^r90bt_'` = **0**); all scratch lives under `reports/round-104/physics/**/scratch`.
- **`/tmp` is not usable on this host today**: a plain `cp -a corpus/fixtures/. /tmp/…` failed with
  `Disk quota exceeded` (16 G tmpfs at ~80 %). Every run and scratch in this report is therefore
  rooted on `/home`. This is the same host condition C2's gate-workdir work addresses; it is recorded
  here because it is why no `/tmp` path appears in my evidence.

---

## 6. What this seat did not establish

- **The D2 fail-open root is bounded, not closed.** `_finish` (`:118-120`) still prints
  `PASS … " ".join(_parts)` without consulting `mode_ok`, so a cell that degrades *without* the batch
  deadline firing still prints PASS. My deadline removes the *concurrency-starvation* route into that
  hole (the §4 attack) but not the hole itself; the r103 ledger's R2 (`_finish` honours `mode_ok`) is
  the actual fix for the root and is **not** in this patch — it changes the output shape of a pinned
  row and needs its own dated re-pin decision.
- **No clean R3 flake rate.** The host carried 20+ foreign `godot` processes and `/tmp` was at quota
  for part of the window. 5 isolated reps + 8-arm + full-battery runs all produced the exact marker,
  but that is not a flake rate.
- **The 13 cannon rows are untouched by design** and remain FAIL (D3, node-token pin).
- **The as-landed-vs-deadline attack used an injected stall**, not a naturally starved host. The
  mechanism (starved child → inner bound SIGKILL → truncated log → corrupt marker) is the one SEAT-01
  measured; the injection is the controlled reproduction, not an observed production flake.
- **The `bpy_rbw3d_render` flake was characterized, not fixed.** It is outside this seat's scope and
  has its own dissection (`reports/round-101/bpy-dissection.md`).
- **No Unreal claim.** None is possible here.

---

## 7. Commands run (all from the lane repo root)

```
sha256sum corpus/fixtures/phys3d_joints.gd corpus/fixtures/run_battery.py
git diff -- corpus/fixtures/phys3d_joints.gd
git status --porcelain -- corpus/
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs reports/round-104/physics/author-runs-final
python3 corpus/fixtures/run_battery.py --only phys3d_joints_sweep,phys3d_joints_rid,phys3d_joints_api,phys3d_joints_free_pair,phys3d_joints_free_ops,phys3d_joints_detach,phys3d_joints_chain3,phys3d_joints_twopin --runs reports/round-104/physics/author-runs-all-final
python3 corpus/fixtures/run_battery.py --runs reports/round-104/physics/author-runs-full
for i in 1 2 3 4 5; do python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs reports/round-104/physics/author-reps; done
godot --headless --path reports/round-104/physics/nc-orig --script res://phys3d_joints.gd -- --arm=bogus   # original latent error
godot --headless --path reports/round-104/physics/nc      --script res://phys3d_joints.gd -- --arm=bogus   # post-fix, clean
# 4-arm same-scratch reentrancy; injected-stall attack in hang/ and hang-asis/
```
