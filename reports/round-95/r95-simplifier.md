# r95 simplifier — YAGNI/dead-code review of the committed r95 bullet/pybullet landing (`0767b59`)

Seat: GAME-DEV-3D r95 SIMPLIFIER, read-only. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r95-simplifier.md`.
Scope: the committed work commit
`0767b5900f38949b6e077b0ab8317480f66166f8` only — `corpus/fixtures/r95_bullet.gd`
(+196, new), `corpus/fixtures/r95_child.py` (+1673, new),
`corpus/fixtures/r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so`
(+7 063 864 B, new), `corpus/fixtures/run_battery.py` (+40, insertion-only) —
plus its receipts. No fixture edit, no commit; the only **tracked** write this
seat makes anywhere is this report (receipts land under the gitignored
`corpus/live/`). HEAD was `0767b59…` with `git status --porcelain` showing one
pre-existing untracked sibling file (`reports/round-94/r94-reviewer.md`) at seat
start; mid-seat (near the end of the probe runs) a sibling scribe committed
`a042e49` — `reports/round-95/r95-scribe.md` only, +296 lines, no fixture — and
the four committed files of this landing were **re-hashed unchanged** at the new
HEAD (§1.1), so every battery run below executed those bytes either way. Seat end:
HEAD `a042e49`; `git status` shows this report plus other seats' untracked
reports/fixtures (sibling scribe/critic/verifier and an r96 author were working
in parallel — none of them touch the r95 bytes re-hashed here).
Deletion probes ran on throwaway copies of the seed under
`corpus/live/r95-simplifier/trees/`, deleted after the runs and
**byte-reproducible** from `scripts/prepare_trees.sh` (§7.3); the exact edited
children that ran are kept as `probes/probe{A,B,C}_child.py`.

Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`; `/usr/bin/python3`
`3.14.7`; 32-core host, ambient load 52–87 across the runs (§7). A sibling
round's battery (`game-dev-2d-shokunin`) was running on the same host during
part of the window, so "load" here is ambient, not induced.

**LSP device: unavailable to this seat.** The only MCP server bound to this
session is `rea` (Ghidra/REA binary analysis), which does not answer Python or
GDScript, and no `lsp`/`references`/`definition` tool exists in this toolset —
so every call-site claim below is the **literal census, not semantic proof**.
Two facts narrow the gap for this landing: (a) the child has no reflective
surface — no `eval`, no `importlib`, no dynamic-name access; its only
name-indexed tables are `CASES[CASE]` (52 literal keys) and the parent's
`ARM_CASES[arm]` / `NEGATIVE.has(arm)` over literal tables; (b) every deletion
candidate was **executed**, not merely reasoned about (§1.3–§1.4): a wrong "dead"
call turns a probe red, and the detection control proves the comparator catches
a one-constant mutation.

## 0. Verdict

**PASS — no bar-meeting *simplifier* defect. The 1 673-line child carries
42 net lines of removable dead weight — 33 (SP-1…SP-5) proven at 20/20 battery
rows byte-identical *and* 52/52 direct child cells contract-identical, a further
9 (SP-6) proven 52/52 contract-identical — and every leg of the landing fired in
this seat's runs. One MEDIUM landing finding (F-1) and four low findings are
filed for the adjudicator; F-1 is not caused by this seat's probes — it fires on
the committed bytes (§5.1).**

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **SP-1** | child: the slide scene is re-implemented **four times** (`_slide`, `_slide_hash`, `c_fr_gate`'s neg-mu loop, `c_fr_gate`'s inner `slide()`); collapse to one `_slide_launch(cid, mu_g, mu_b, damp=None, grav=G)` helper that owns the scene + 30-step settle + 5 m/s launch, and let callers own the 600-step run (fr_gate samples `vx` inside it) | **−22 lines** (5 edits) | 20/20 rows byte-identical + 52/52 direct contract cells identical (probeA) | **take** |
| **SP-2** | child: `c_det_perturb` hand-builds the canonical scene a second time with one 1e-9 offset instead of calling `scene()`; add `dz=0.0` to `scene()` and call `scene(cid2, dz=1e-9)` | **−8 lines** (3 edits) | same probes; the `perturb-track` cell (`1.000e-09` … `heq=False`) is byte-identical | **take** |
| **SP-3** | child: `_freeze_step` counts `changes` on every non-fixpoint step and returns it — **no caller reads it** (`fz, ch = …` / `fz2, ch2 = …` both discard) | **−2 lines** (4 edits) | same probes | **take** |
| **SP-4** | child: `c_det_restore` computes `h_mid = state_hash(cid)` at the post-240 step and never emits it — a dead measurement on the restored-away state | **−1 line** | same probes | **take** |
| **SP-5** | child: 10 write-only bindings (`nan, inf, wh = nan_scan(cid)` ×2, `lv, av = body_vel(...)`, `pos, orn = getBasePositionAndOrientation(...)` ×2, `for i in range(…)` ×2) — same-line edits | **−0 lines** (10 edits) | same probes | **take** |
| **SP-6** | child: `ball_only(cid, z=5.0)` is `_ball(cid, z0, mx=False)` with the kwarg omitted instead of passed explicitly — a duplicate helper; delete `ball_only`, rewrite its 29 call sites onto `_ball` | **−9 lines** (29 hunks) | direct 52/52 identical incl. `d`; battery rep1 red only on the F-1 flake cell | **take-or-drop (weak)** — §4: byte-neutral, but a 29-site mechanical edit for 9 lines |
| **F-1** | the pinned `d` cells of the two SHM cases are a **thread-print race**, not a measurement: `shm_step.d ∈ {8,10}`, `shm_rtclass.d ∈ {42,44,46,48}`; the `shm` row passed **6 of 11** non-mutant runs, every red on `d` alone | MEDIUM | 11 battery runs + 10-rep direct census (§5.1) | **file** — re-pin / row-scoping decision is the adjudicator's |
| **F-2** | child docstring + parent header say the SHM correction is "pinned as CLASSES `fell`/`distinct`/`pinFree`" — only `fell` is pinned; `distinct`/`pinFree` are `#`-only (count-pinned) | LOW | code census + `shm_rtclass` cells (§5.2) | **file** (report accuracy) |
| **F-3** | parent header calls the `#` stream "the child's captured fd-2 stream" — the child captures **both** fds (`b3Warning` writes fd 1); the child's own docstring and the author's correction #8 say so | LOW | code census (§5.3) | **file** (report accuracy) |
| **F-4** | `det_saturated`'s `h960≠h961` is *implied* by `freeze_scene`'s `changes=3000` on the same scene+params; it is redundant evidence but a distinct pin, so removal is not this seat's call | LOW | code census (§5.4) | **file** |
| **F-5** | child docstring pins the M0 field order as `…py=.. build=".." dtBits=..`; the emitted order is `…py=.. dtBits=.. build=".."` | COSMETIC | code census (§5.5) | **file** |

## 1. Evidence base (all read-only, recomputed here — nothing taken on the author's word)

### 1.1 Committed bytes

`git status --porcelain` = one pre-existing untracked sibling report at seat
start; HEAD `0767b5900f38949b6e077b0ab8317480f66166f8` at seat start and
`a042e49` (the sibling scribe's report-only commit, §preamble) at seat end. sha256
of the four files the landing touches, recomputed here — identical at both HEADs:

```
f988ba86fdef62a03a59c91e000a94288a4610f9ef9c92c5e56db967515f1447  r95_bullet.gd
8821ebd50459dd1371a6484a68abc79e0decb8aa50a8c416636f644baddf5b6b  r95_child.py
0b9b7035cc0af0a1f6fae6b1272dbe5d108f8542d6da272d3a05784f04ca3786  run_battery.py
eca749a0d9b53964dca06764300c3481f328dc4cd1499a60e287393972be3693  r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so
```

The vendor sha256 is the one the author's report pins (`eca749a0…`) — the
"byte-pinned vendored `.so`" claim is recomputed, not quoted. `r95vendor/`
contains that one file.

### 1.2 Battery runs (20 r95 rows each, `--only` on the committed row names)

| run | tree | load | rows | red row | cells moved vs baseline |
|---|---|---|---|---|---|
| `battery-r95only` | committed | 79.2 | **20/20 PASS** | — | *reference* |
| `battery-r95only-rep2` | committed | 86.5 | 19/20 | `r95_bullet_shm` | `shm_step:d` |
| `probes/probeA-runs` | probeA (−33) | 86.1 | **20/20 PASS** | — | **none** (0/0/0) |
| `probes/probeA-runs-rep2` | probeA (−33) | 57.2 | 19/20 | `r95_bullet_shm` | `shm_step:d, shm_rtclass:d` |
| `probes/probeB-runs` | probeB (−42) | 86.7 | 19/20 | `r95_bullet_shm` | `shm_step:d, shm_rtclass:d` |
| `probes/probeB-runs-rep2` | probeB (−42) | 59.3 | 19/20 | `r95_bullet_shm` | `shm_step:d, shm_rtclass:d` |
| `probes/probeC-runs` | probeC (mutant) | 85.7 | **12/20** (8 red) | 8 rows | 22 cells (detection control, §1.3) |
| `probes/shm-row-rep1..5` | committed, `--only r95_bullet_shm` | 57.5–58.2 | 4 PASS / 1 red | `r95_bullet_shm` (rep4) | `shm_rtclass:d` |

Byte-comparison (`scripts/compare.py`, output `probes/compare-results.txt`), over
`stdout` **and** `stderr` **and** exit code, case by case:

```
reference: battery-r95only/20261015T233328271094Z/verdicts.json  cases=20 seeds_unchanged=True verdict=PASS
compare battery-r95only-rep2/…/verdicts.json : stdoutDiff=1 stderrDiff=0 rcDiff=0  cells moved (1): shm_step:d
compare probes/probeA-runs/…/verdicts.json   : stdoutDiff=0 stderrDiff=0 rcDiff=0  PASS
compare probes/probeA-runs-rep2/…/verdicts.json : stdoutDiff=1 stderrDiff=0 rcDiff=0  cells moved (2): shm_rtclass:d, shm_step:d
compare probes/probeB-runs/…/verdicts.json   : stdoutDiff=1 stderrDiff=0 rcDiff=0  cells moved (2): shm_rtclass:d, shm_step:d
compare probes/probeB-runs-rep2/…/verdicts.json : stdoutDiff=1 stderrDiff=0 rcDiff=0  cells moved (2): shm_rtclass:d, shm_step:d
compare probes/probeC-runs/…/verdicts.json   : stdoutDiff=8 stderrDiff=0 rcDiff=0  cells moved (22)
```

**probeA is byte-identical to the committed bytes on all 20 rows** (the one run
in which the F-1 flake did not fire); probeB differs only on the flaky `d` cells.
No `m`/`rc`/`o` cell ever moved in a probe run.

### 1.3 The detection control is not vacuous (probeC)

probeC = probeA + `scene()`'s ball z `5 → 4.9999999` (one constant). **8 of 20
rows FAIL**, and the split is mechanistic — exactly the rows whose arms build
their scene through `scene()`:

| red (8) | why | still PASS (12) | why |
|---|---|---|---|
| `det`, `freeze`, `rt`, `shm`, `knobs`, `solver` | every case in the arm calls `scene()` | `sleep`, `sleep2`, `nan`, `nan2`, `misc`, `neg_radius`, `neg_simtime`, `neg_badid`, `neg_shm_rt` | built on `ball_only`/`_ball`/own literals |
| `neg_dt`, `neg_order` | live control *is* the scene hash — the rejection line moves | `fric`, `rest` | own slide/bounce scenes |
| | | `pile` | `_pile` scene |

The 22 moved cells are `m` cells (the pinned hashes) plus `shm_step:m/d` — i.e.
the comparator resolves *which* cell moved, not just "stdout differs". A "0
diffs" result from probeA therefore means what it says.

### 1.4 Direct child-vs-child comparison (52 cases, both probes)

`scripts/direct_compare.py` runs **every one of the 52 child cases directly**
(committed child vs probe child, same vendor bytes) and compares `rc`, the
verbatim `M0`/`M`/`M DONE`/`NEGATIVE REJECTED:` contract lines, and the `o`
count; `d` is reported separately because §5.1 shows it is flaky.

```
probeA: cases=52 contract/rc/o diffs=0 d-count diffs=1  (shm_rtclass 44 -> 48)
probeB: cases=52 contract/rc/o diffs=0 d-count diffs=0
```

Receipts: `probes/direct-compare-probe{A,B}.txt`. The one `d` drift landed on
the *probe* side in probeA and on the *committed* side in the battery rep2 — the
flake is direction-independent, i.e. not an artifact of the edits.

## 2. Census: what in the landing is dead

`scripts/census.py` (AST) over the committed child, output `census.txt`:

- **A. module-level defs: 80 (52 `c_*` cases + 28 helpers/`main`), unused: none.**
  Every helper and every `c_*` case function has ≥1 `Load` site; the 52 case
  functions each have exactly 1 (the `CASES` table).
- **A2. module-level assignments:** `CASE`, `VENDOR`, `_errbuf`, `_real`, `G`,
  `DT`, `NBASE`, `PIN_BASE`, `CASES` — all read; no dead constant.
- **B. write-only locals: 12** — `h_mid` (`c_det_restore`), `inf`/`wh`
  (`c_det_saturated`), `av` (`c_sl_velwrite`), `ch`/`ch2` (`c_sl_disable_pair`),
  `pos` ×2 (`c_nan_fields`), `wh` (`c_nan_damp`), `i` ×2 (`c_rt_paced`,
  `c_rest_all`), `_` (`run`, idiomatic). SP-3/SP-4/SP-5 remove 10 of them; the
  two `_` loop variables are idiomatic and stay.
- **D. case-table cross-check: exact.** 52 child cases ↔ 46 parent arm cases + 6
  negative arms; zero child cases unreachable from the parent, zero parent
  entries missing from the child, zero duplicates. The landing has no dead case
  and no unreachable arm.
- **Parent (`r95_bullet.gd`, textual census):** every declaration (`arm`,
  `BOUND_S`, `ARM_CASES`, `NEGATIVE`, `_parts`, `_py_version`, and all 8
  functions) has ≥2 occurrences; no dead declaration, no dead branch (the
  `d.has("err")`, `lf == null` and unknown-arm paths are all reachable guards).

## 3. Taken deletions — SP-1…SP-5 (−33 lines, 16 hunks, 20 edits)

`scripts/apply_probeA.py` (each anchor asserted unique/counted, aborts
otherwise), diff `probes/probeA.diff` (−65/+32, net **−33**, 1673 → 1640 lines),
per-edit deltas `probes/edit-deltas.txt`:

| edit | Δ | what |
|---|---|---|
| SP-1 `_slide_launch` | −3 | one shared slide scene+launch; `_slide` deleted, `_slide_hash` rebuilt on it |
| SP-1 `c_fr_gate` neg-mu loop | −8 | 4th copy of the scene → one call |
| SP-1 `c_fr_gate` `slide()` | −11 | 3rd copy of the scene → one call |
| SP-2 `c_det_perturb` | −8 | hand-built scene → `scene(cid2, dz=1e-9)` |
| SP-3 `_freeze_step` | −2 | dead `changes` counter + return |
| SP-4 `h_mid` | −1 | dead measurement in `c_det_restore` |
| SP-5 ×10 | −0 | write-only bindings / loop variables |

Two subtleties the probes *prove* rather than assume:

1. `c_fr_gate`'s neg-mu loop reads `getDynamicsInfo` **after** the 30-step
   settle + velocity write once it calls the helper (it read them before, at the
   same tick boundary). Friction is a stored field, so the two reads are the
   same value — the byte-identical `fric-neg … stored=0.5,0.5,x=4.08354903 …`
   cell is the proof.
2. `scene(cid2, dz=1e-9)` reproduces the hand-built scene **including creation
   order** (the corpus's own order-sensitivity law): ground, ball(+dz), 3 boxes,
   same shape creation order — the `perturb-track` cell (`20:1.000e-09 …
   480:6.804e-13 heq=False`) is byte-identical.

## 4. SP-6 — duplicate helper `ball_only` ≡ `_ball(…, mx=False)` (−9 lines)

`ball_only(cid, z=5.0)` and `_ball(cid, z0=5.0, mx=False)` are the same scene;
the only difference is that `ball_only` omits `useMaximalCoordinates` while
`_ball` passes `False` explicitly. Probe B deletes `ball_only` and rewrites its
29 call sites (`probes/probeB.diff`, −39/+30 relative to probeA, 29 hunks,
1640 → 1631).

**Proof:** direct 52/52 contract-identical **and** `d`-identical
(`probes/direct-compare-probeB.txt`); the battery run reddened only on the F-1
flake cells (`shm_step:d`, `shm_rtclass:d`), which also redden on the committed
bytes (rep2). So the omitted-vs-explicit `useMaximalCoordinates=False` call is
byte-neutral **on this build** — whether the binding resolves the omitted kwarg
to `false` or to the world default, the two calls produce the same bodies here
(and the 10/10-identical direct comparison covers the maximal-coordinate cases
too).

**Call: take-or-drop (weak).** It is a genuine duplicate-helper deletion with a
proven no-op, but it is a 29-site mechanical edit for 9 lines, and the
`ball_only` name carries the "ground + one ball" intent that `_ball`'s
`z0/mx` signature does not. The adjudicator can take it or leave it; unlike
SP-1…SP-5 it is not dead weight in the same sense (both names are live).

## 5. Findings (filed, not this seat's call)

### 5.1 F-1 (MEDIUM) — the pinned `d` cells of the SHM cases are a thread-print race

*(this seat's F-1; the sibling scribe's "F1 `sl_force_mb` rest-pin" in `a042e49`
is a different item)*

The parent pins the `#`-diagnostic **count** in every cell (`d=%d`), and the
author's flake class 1 documents that this count can drift ("the total byte
count — and thus the line count — is fixed, and 50 ms settle sleeps … land the
prints before the drain"). Measured on the **committed bytes**:

- 11 non-mutant battery runs (6 × 20-row + 5 single-row): `shm_step.d` = 8 in 7
  runs, 10 in 4; `shm_rtclass.d` = 44 in 7, 42 in 2, 46 in 1, 48 in 1. The `shm`
  row **passed 6, reddened 5** — every red on `d` alone; `rc`/`m`/`o` never
  moved (`probes/compare-results.txt`).
- 10 direct reps of the committed child (`probes/shm-census/`): `shm_step.d` =
  8 ×9, 10 ×1; `shm_rtclass.d` = 44 ×7, 46 ×2, 42 ×1; `sv_backends.d` = 4 ×10
  (deterministic — the only other multi-line `d`).
- Mechanism (from the same 10 reps, `probes/shm-census-analysis.txt`): the
  *contract* lines are identical in 10/10 reps, `o`=0 in 10/10, and the varying
  lines are pump-thread lifecycle prints whose **multiplicity** varies inside the
  capture window — `# PosixSharedMemory::releaseSharedMemory removed shared
  memoryPosixSharedMemory::releaseSharedMemory…` appears 2–4× in `shm_step`
  (up to 10× in `shm_rtclass`, which opens 3 SHM clients), `started thread 0` /
  `MotionThreadFunc thread started` up to 3×, `Thread TERMINATED` / semaphore
  destroys up to 2×. The measured `# shm-rt measured z0=…` value also varies
  (`5` in 8/10 reps, `4.99948857` / `4.99982951` in 1/10 each) — correctly
  non-pinned.

Consequence: a red `shm` row carries **no information about the physics** — it
is a scheduling artifact of the SHM pump thread, and it is not rare (≈1 in 2 row
runs here; the pinned values reproduce only sometimes). Two consequences for the
round: (a) a verifier's "rep-stable" claim must exclude the `d` cell of the two
SHM cases (or be stated as load-conditional); (b) if the landing keeps `d` in
the digest for SHM rows, the row will keep reddening at random. The fix
(scope `d` out of the SHM digest, drain later, or stop capturing the pump
prints) is a re-pin decision and is not this seat's call. **Not caused by this
seat's edits**: the red fires on the committed bytes (`battery-r95only-rep2`,
`shm-row-rep4`) as well as on the probe trees, and the direct comparison shows
the drift on both sides of the edit.

### 5.2 F-2 (LOW) — "pinned as CLASSES `fell`/`distinct`/`pinFree`" overstates the pin

`r95_child.py`'s docstring (and `r95_bullet.gd`'s header, lines 26–28) say the
SHM correction is "pinned as CLASSES `fell`/`distinct`/`pinFree`". In the code,
`c_shm_rtclass` **emits** only `rtflag` and `fell`; `distinct` and `pinFree` go
through `diag()` and therefore land on the `#` surface, where only their *count*
is pinned. The author's report is accurate ("stepped hashes stay `#`
diagnostics"), so this is a fixture-comment overstatement, not a behavioral
one — but the comment claims a pin that does not exist.

### 5.3 F-3 (LOW) — parent header calls the `#` stream "the child's captured fd-2 stream"

`r95_bullet.gd` lines 12–15 say the `#` diagnostics are "the child's captured
fd-2 stream — pybullet build banner, b3Warning refusals, solver-switch notices,
SHM pump thread logs". The child captures **both** fds for the whole process
(its own docstring lines 20–23, and the author's correction #8: "b3Warning rides
stdout (fd 1)"). The parent's own example list (`b3Warning`) is the fd-1 writer,
so the comment contradicts itself.

### 5.4 F-4 (LOW) — `det_saturated`'s non-fixpoint cell is implied by `freeze_scene`

Both use a fresh DIRECT client with `scene(cid)` and default parameters.
`freeze_scene` steps 3000× hashing `state_hash` each step and pins
`changes=3000, freezeStep=-1`; that implies `h960 ≠ h961`, which is what
`det_saturated` pins (plus `nan=False` and the concrete `h960`/`h961` values).
The cell is therefore redundant *evidence*, but it is a distinct *pin* (those
hashes appear nowhere else) — removing it is an author/adjudicator call, not
YAGNI dead code.

### 5.5 F-5 (COSMETIC) — M0 field order in the child docstring

Docstring: `M0 case=<c> engine=.. api=.. py=.. build=".." dtBits=..`; emitted:
`case=… engine=… api=… py=… dtBits=… build="…"`. The `build`/`dtBits` pair is
swapped in the documentation only.

### 5.6 Out of scope — a pre-existing corpus row reddens under load (not an r95 finding)

While checking the landing in the **full** battery (started, then abandoned at
29/304 rows — out of this seat's scope, §7.2) the committed tree reddened on a
**pre-existing, non-r95** row:

```
FAIL navagent3d_retarget_fixed: exit=1 expected=2
  ERROR: navagent3d_retarget: pre-switch callbacks/motion mismatch
         ticks=120 first_next=(1.0, 0.0, 1.0) before=(1.754246, 0.0, 1.754246)
```

`navagent3d_retarget.gd:33` fails its own live-control self-check, which
tolerates 0.004 on `before_switch.distance_to(Vector3(1.730676, 0, 1.730676))`
(observed deviation 0.033). Re-running the pair 3×: rep1 both PASS, **rep2
`navagent3d_retarget` (the positive row) FAIL** with the same
`before=(1.754246…)`, rep3 both PASS — i.e. ~2 reds in 4 executions, on rows
this landing does not touch. Recorded here only as context for the "304/304"
rep-stability claim; it is not an r95 finding and not this seat's call.

## 6. Considered and retained (no action)

- **`VENDOR` argv fallback** (`sys.argv[2] … else <dir>/r95vendor`): unused by the
  battery (the parent always passes the vendor dir) but documented as the
  standalone CLI and used by this seat's direct comparisons — retained.
- **`if VENDOR:` guard**: defensive against an empty `argv[2]`; 1 line.
- **`DirAccess.remove_absolute(logpath)`** in the parent: a no-op on a fresh
  scratch copy, but hygiene if the fixture is run twice against one project —
  retained.
- **`_pile`'s `nx/ny/nz` parameters**: never varied (always 4/4/2); they are the
  boundary cell's shape documentation rather than dead flexibility — retained.
- **`c_fr_gate`'s inner `slide()`** keeps its own 600-step `vx` sampling loop
  after SP-1 (the helper cannot own a sampled run) — retained.
- **`c_rest_all`'s two loops** (apex tracking over 600 steps; z+hash at 300):
  near-duplicate scene construction, but the two loops differ in
  `changeDynamics` interleaving and sampling; merging them is a behavior-risky
  refactor for ~15 lines — **not taken**, flagged as a candidate only.
- **`c_kn_neutral` / `c_kn_loud`** share a sweep *shape* (fresh client → set
  param → scene → 480 steps → hash); a shared `_knob_sweep` would delete ~9
  lines. Not a verbatim duplication of a scene, and it would hide the
  neutral/loud contrast in one helper — **not taken**.
- **The 7 MB vendored `.so`**: load-bearing (it *is* the engine under test),
  already `strip --strip-debug`, sha-pinned, and output-equivalence-proven by the
  author. Not removable; further stripping would be a re-pin, not a
  simplification.
- **The 20 battery rows' full-marker strings**: each is the exact expected
  stdout; a row per arm is the corpus convention (r94 identical).

## 7. Load, timing, repro

### 7.1 Load

`load-start.txt` 79.21/75.28/64.84; per-run start/end loads in each `*.log`
(86.5 → 57.2 as the ambient load fell). Every run above was **sequential** — the
abandoned full-battery run (§7.2) was killed before the `*-rep2` runs and the
single-row reps. The only concurrency in the window is a sibling round's battery
(`game-dev-2d-shokunin`) on the same host, which is what the ambient load
reflects; that is the load regime the task asked for ("load preferred"), and it
is the regime in which F-1 fires.

### 7.2 Runs started and abandoned

`battery-full` (all 304 rows, committed tree, load 52.9) was started as an
out-of-scope extra, reached 29/304 rows (1 red, §5.6) and was **killed** — the
narrow r95 set is this seat's required check and was run 12× (7 × the full
20-row set + 5 × the `shm` row alone). The partial log is kept
(`battery-full.log`); no `verdicts.json` was produced, and a partial run is
**not** evidence about the full battery either way.

### 7.3 Repro

```
# rebuild the throwaway probe trees byte-for-byte (verified: sha256 of the
# rebuilt children equals probes/probe{A,B,C}_child.py)
corpus/live/r95-simplifier/scripts/prepare_trees.sh
# one probe run (20 r95 rows)
corpus/live/r95-simplifier/scripts/run_all.sh <label> <tree> <runs-dir>
# byte-compare against the reference
/usr/bin/python3 scripts/compare.py battery-r95only/*/verdicts.json <other>/*/verdicts.json
# direct 52-case child comparison
/usr/bin/python3 scripts/direct_compare.py <tree> <label>
# F-1 census
/usr/bin/python3 scripts/shm_census.py 10 shm_step shm_rtclass sv_backends
```

Timing: the 20-row set is ~32 s wall (sum of per-case times), slowest row
`r95_bullet_rt` 4.22 s vs the battery's 20 s per-case timeout → ≥15.7 s margin
on every row; per-child bound `BOUND_S=15` never approached (slowest child
~4.5 s).

## 8. Bounded claims

- **What is proven:** SP-1…SP-5 (−33 lines) leave the pinned surface
  byte-identical on all 20 battery rows *and* contract-identical on all 52 direct
  cells (one F-1 `d` drift on the probe side of the direct comparison); SP-6
  (−9 lines) leaves all 52 direct cells identical including `d` (its two battery
  reds are F-1's cells, which also redden on the committed bytes). "Behavior
  preserved" means exactly that — no `rc`/`m`/`o` cell moved in any probe run and
  `d` moved only in the SHM cells — and is
  **not** a general mutation-coverage or semantic-equivalence claim: a deletion
  that changed something no pin observes would be invisible here (the §1.3
  control bounds this: a one-constant mutation moves 8 rows / 22 cells).
- **What is not proven:** that the pinned `d` cell of the SHM cases is
  reproducible (§5.1 — it is not, on this host), that the landing is stable in
  the *full* 304-row battery (§7.2), or anything about rows this commit does not
  touch (§5.6 is context only).
- The 42 lines are removable **dead weight in the committed landing**, not a
  defect of it: every leg of the 52-cell lattice fired in this seat's runs, and
  the corrections the task card names (DIRECT-scoped purity, SHM rt=1 pump-live
  class, order non-neutrality, 1-ulp friction, EMPTY-sleep calibration) are all
  present and pinned in the cells this seat re-ran.
