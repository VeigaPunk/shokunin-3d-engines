# game-dev-3d r101 — bpy dissection: the documented `bpy_rbw3d_render` flake

Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · seat: `g3d-bpy-boundary`
(dissection). Measured on Blender **5.2.1 LTS** (`/usr/bin/blender -b -P`), Godot
**4.7.2.stable.arch_linux.ed1daf0bf**, kernel **7.2.3-arch1-3**, AMD Ryzen 9
9950X (32 threads), Python 3.14.7.

Assignment (dispatch to this seat, verbatim):

> The `bpy_rbw3d_render` row is the lane's longest-standing documented stochastic
> cell. Dissect it: read its fixture + every receipt mentioning it (grep
> corpus/live), reproduce under quiet/load/fixed conditions, identify the
> mechanism (Blender version? render device? scene nondeterminism? contention?).
> Deliver a verdict: pinnable-deterministic vs genuine-stochastic vs envelope;
> if fixable, specify the fix. reports/round-93-adjacent/bpy-dissection.md (or
> reports/round-101/bpy-dissection.md). gitignored corpus/live/bpy-dissection/.
> No tracked writes, no commits.

Artifact bytes measured (worktree = HEAD for both fixture files; `run_battery.py`
has an unrelated uncommitted r93-row edit, and the `bpy_rbw3d_render` marker is
byte-identical in the worktree blob and the HEAD blob — verified):

| file | blob |
|---|---|
| `corpus/fixtures/bpy_rbw3d.gd` | `617de8966517bf903b617f1a3b2d6f72087ed16b` |
| `corpus/fixtures/r91_child.py` | `fe9108713326041cc2f7558749f778a7674f0666` |
| `corpus/fixtures/run_battery.py` (worktree) | `90305332d94a096368d910ed633c8e1e6f88ff8a` |
| `corpus/fixtures/run_battery.py` (HEAD) | `eba69cb880c810dc6db5c17758812906787dbf7c` |

HEAD at filing `3c7b460b3abc963438aa800e06955290d78add6b` (it moved twice during
this seat — `bc6670a`, `3c7b460`; **no fixture byte moved**, checked by blob
identity). Confidence tags: **[O]** receipt-pinned observation, **[I]** inference,
**[?]** unknown. All receipts in gitignored `corpus/live/bpy-dissection/`; no
tracked writes, no commits.

---

## 0. Verdict

**Pinnable-deterministic.** The render is deterministic; the cell hashes a value
that is not.

`rdet same_state stable=` is `sha256(a) == sha256(b) == sha256(c)` over the three
PNG **files** of the same scene state. The **pixels are byte-identical** — the
concatenated `IDAT` payload has exactly one sha per scene state across 160 `rdet`
processes (five receipt directories, host loadavg 61 → 151) and both fixture
variants. The whole-file sha differs **only** because Blender stamps wall-clock
metadata into the PNG `tEXt` chunks (`Date`, `RenderTime`,
`cycles.ViewLayer.total_time`, `cycles.ViewLayer.render_time`). `stable` is
therefore a **wall-clock coincidence detector**: `False` whenever the three
renders' duration strings jitter apart (every run on a busy host), `True` when
they coincide (quiet host). The pin asserts `stable=False`, so the cell FAILs
precisely when the host is quiet and self-consistent — the opposite of a
load-driven flake.

| candidate mechanism | verdict |
|---|---|
| Blender version | **no** — one version on this host; the varying bytes are Blender's stamp metadata write path, not a version-specific render bug. The *fix* is version-sensitive (see §5.4), the *flake* is not. |
| render device | **no** — the fixture pins `sc.cycles.device = "CPU"`, `samples = 1`; no GPU path in play; pixels deterministic. |
| scene nondeterminism | **FALSIFIED** — the ball's full `matrix_world` (rotation included) is identical before/after every render, and the pixel payload is identical across all 160 processes. |
| contention | **partial** — it changes only the *rate* (duration jitter ⇒ `stable=False`), never the truth of the pin. Quiet ⇒ coincidence ⇒ `stable=True` ⇒ FAIL. |

**Fix (spec in §5):** suppress the render metadata in both render arms of
`r91_child.py` (turn the seven factory-enabled `use_stamp_*` fields off; leave
`use_stamp_labels` alone) and flip the pinned token `stable=False → stable=True`.
Then the cell becomes a *witness*: PNG bytes identical across processes (measured
20/20 reps, one sha, at host load 76–145), full row matches the corrected pin 3/3.
A version-proof belt-and-braces variant hashes the pixel payload instead.

---

## 1. The cell as authored

- Row: `run_battery.py:564-565` → `("bpy_rbw3d_render", "bpy_rbw3d.gd",
  ["--arm=render"], 0, "PASS bpy_rbw3d render shot@bpy{…} rdet@bpy{…M rdet
  same_state stable=False|M rdet moved_state differs=True…}")` — the marker pins
  `stable=False` as an exact stdout byte string (verdict rule: "exit 0 + exact
  stdout marker"; a missing marker is FAIL even with `rc=0`).
- Arm: `bpy_rbw3d.gd --arm=render` → cases `shot` then `rdet`, each a
  `timeout -s KILL 15 /usr/bin/blender -b -P r91_child.py -- <case> <dir>`
  child; the parent greps the child log for `M`-lines.
- Child `rdet`: factory-empty scene, size-1 cube `ball` ACTIVE at (0,0,5),
  20×20 plane `floor` PASSIVE, RBW add, frames 1..60, then sweep frames 1..40,
  then **three renders of the same state** at 64×64 / CYCLES / samples 1 /
  device CPU / PNG, hashing each written file, then `frame_set(1)` and a fourth
  render. It emits `stable=(h1==h2==h3)` and `moved_state differs=(h4!=h1)` —
  booleans only, never a digest (fixture header: "PNG bytes are not a stable
  witness (stable=False pinned, never a sha)").

So the row's own documentation says the boolean is *supposed* to be a
non-witness. The dissection below shows it is instead a clock reading.

## 2. Receipt corpus (every receipt mentioning the row)

`corpus/live/**/verdicts.json` sweep (`receipt_scan.py` → `receipts-scan.txt`):

| receipts | PASS | FAIL | FAIL reason | FAIL payload |
|---|---|---|---|---|
| **17** (r91-author ×2, r92-baseline ×2, r92-author ×2, r92-critic ×1, r92-fold ×1, r92-verifier ×2, r92-verify2 ×3, r93-baseline ×2, r93-baseline2 ×2) | 15 (`stable=False`) | **2** | `exact stdout marker missing` (rc 0) | both emitted `M rdet same_state stable=True` |

- `r92-author/runs/20261015T175116507786Z` — FAIL, 1.719 s.
- `r93-baseline/runs1/20261015T185851206462Z` — FAIL, 1.966 s; the baseline report
  records loadavg **2.75** at that run's start, i.e. the FAIL fired in a *quiet*
  window, and classifies it as "r91-documented Blender-render distribution cell".

On-record rate **2/17 = 11.8 %**. The two FAILs are the only deviations; the
r93 baseline's own drift section attributes every other row difference elsewhere.

This seat's own reproduction of the **unmodified** fixture: **140 reps, 0
`stable=True`** — but the host was never quiet (see §4).

## 3. Mechanism

### 3.1 The file diff is 20 bytes, all inside four `tEXt` chunks [O]

`pngforensics.py` on `a/b/c` of a differing rep: 20 chunks, same layout, 20
differing bytes, all inside four `tEXt` payloads (+ their CRCs):

| chunk | payload bytes | sample value | nature |
|---|---|---|---|
| `Date` | 24 | `2026/10/15 17:06:45` | wall clock, second resolution |
| `RenderTime` | 19 | `00:00.16` | elapsed render time, centiseconds |
| `cycles.ViewLayer.total_time` | 36 | `00:00.16` | Cycles stat, centiseconds |
| `cycles.ViewLayer.render_time` | 37 | `00:00.16` | Cycles stat, centiseconds |

`eXIf` (54 B) is a constant block — **one** sha class (`bac3a1a58a16`) across all
160 reps × 4 shots in all five conditions. `IHDR/IDAT/IEND` never differ.

### 3.2 The pixels are deterministic [O]

- Concatenated-`IDAT` sha has **one class per scene state**: `643bd7b946568b50`
  for the frame-40 resting state, `5b06fd4243df6e09` for the frame-1 `moved`
  shot — identical across all 160 reps, across the unmodified fixture, the
  failed fix candidate and the working fix, and across load 61 → 151.
- `pixdiff.py`: 0 differing pixels between `a/b/c` within a rep and between
  `a.png` of two different reps (same state); the `moved` shot differs in
  898/4096 px (a real state witness).
- `probe_stamp.py`: the ball's full `matrix_world` is identical before and after
  every render (`same_mw_before_after=True`, `mw0=(0.99926,-0.03846,0.000714,
  0.381156)`) — render does not step the sim, as the arm claims.

### 3.3 Byte-patch proof: the variance is *exactly* the metadata [O]

`patchcheck.py` copies the four differing chunks (payload + CRC) from file A into
file B, then compares byte-for-byte:

| pair | chunks patched | patched_B == A |
|---|---|---|
| rep16 a vs b (same process) | 4 | **True** (4270 B) |
| rep16 a vs c (same process) | 4 | **True** |
| rep15 a vs rep16 a (different processes) | 4 | **True** |
| rep15 a vs c (Date coincided) | 3 | **True** |
| loaded32 a vs b (load 146) | 4 | **True** |
| quiet-watch a vs c (load 122) | 3 | **True** |

### 3.4 Pairwise predictor test: `file_sha equal ⇔ metadata tuple equal` [O]

`pairwise_check.py` over all `(a,b) (a,c) (b,c)` pairs of 160 reps
(unmodified fixture under four conditions + fixed variant), comparing
whole-file sha equality against equality of the 4-key metadata tuple:

| | count |
|---|---|
| tuple equal **and** file equal | 62 |
| tuple differs **and** file differs | 418 |
| **counterexample** (tuple equal, file differs) | **0** |
| **counterexample** (file equal, tuple differs) | **0** |
| pairs whose `IDAT` differed | **0** |

The 62 coincidences are the two-sided evidence inside my own receipts — e.g.
rep015 `RT=[14,14,13] cs` → `a==b`, `c` differs; rep017 `RT=[6,6,7] cs` →
`a==b`, `c` differs. Partial coincidence gives partial byte equality.

### 3.5 Why quiet flips it: coincidence statistics [O]/[I]

`coincidence_stats.py` (per rep: do the three shots' metadata tuples all agree?):

| condition (this seat) | reps | host load | P(three `Date` equal) | P(three `RenderTime` equal) | P(joint) | observed `stable=True` | RT spread within rep (cs, mean) |
|---|---|---|---|---|---|---|---|
| quiet (no synthetic load) | 40 | 61–69 | 0.300 | 0.000 | 0.000 | 0/40 | 4.05 |
| quiet, second sample | 20 | 68–72 | 0.700 | 0.000 | 0.000 | 0/20 | 5.80 |
| loaded (32 own `yes` hogs) | 20 | 146–151 | 0.050 | 0.000 | 0.000 | 0/20 | 14.50 |
| quiet watch (60-rep campaign) | 60 | 96–129 | — | — | 0.000 | 0/60 | 9.12 |
| fixed (metadata off, §5) | 20 | 76–145 | 1.000 (absent) | 1.000 (absent) | 1.000 | **20/20** | n/a |

**[I]** The binding constraint is the centisecond duration strings, not the
second-resolution `Date`: `P(Date equal)` is 0.30–0.70 even at load ~65, while
`P(RenderTime equal)` was 0 in all 140 busy-host reps. On a quiet host the three
consecutive renders of one process take nearly the same time, so the strings
coincide — the on-record 2/17 rate — and the pin breaks. **The flake is
load-*inverted*.**

### 3.6 The metadata write path has a counter-intuitive gate [O]/[?]

`probe_gate.py` / `probe_labels.py` / `probe_order.py` (child-exact scene, one
variable at a time):

| stamp flag state | tEXt chunks in the file |
|---|---|
| factory defaults (date, time, render_time, frame, scene, camera, filename, labels) | 11 stamp chunks + 4 `cycles.ViewLayer.*` |
| **any one** stamp field on (all others off) | that field's chunk + the 4 `cycles.ViewLayer.*` |
| all `use_stamp_*` off **including** `use_stamp_labels` | **the 4 `cycles.ViewLayer.*` remain** (wall-clock `total_time`/`render_time`) |
| `use_stamp_labels` True, **every other** stamp field off | **no `tEXt` at all** — 9 chunks, byte-stable |

**[?]** The internal reason is not source-verified here; the rule is measured
(3 independent probes). It matters twice: (a) it explains why the obvious
"turn all stamp flags off" fix *fails* (it re-admits the Cycles timing chunks —
measured, `scratch/r91_child_fixed.py` → `stable=False` 20/20 in `dbg/`), and
(b) it gives the minimal fix — disable the seven factory-enabled fields and
leave `use_stamp_labels` at its default `True`.

## 4. Reproduction legs (quiet / loaded / fixed)

Exact child command per rep (identical to the battery's child invocation):

    timeout -s KILL 15 /usr/bin/blender -b -P <r91_child.py> -- rdet <repdir>
    # battery-faithful end-to-end leg:
    /usr/bin/godot --headless --path <scratch> --script res://bpy_rbw3d.gd -- --arm=render

| leg | fixture | reps | host load (loadavg 1 m) | `stable=True` | file sha across reps | IDAT |
|---|---|---|---|---|---|---|
| quiet | unmodified | 40 + 20 + 60 | 61–69, 68–72, 96–129 | 0 | all differ | 1 class |
| loaded | unmodified | 20 (+32 own `yes` hogs) | 146–151 | 0 | all differ | 1 class |
| fixed | `disable_render_metadata` patch | 20 | 76–145 | **20** | **1 sha** (`327681bf8345f8f3`, 3887 B) | 1 class, unchanged |

The **quiet** leg is honestly bounded: this seat could not obtain an idle host —
90 foreign `/usr/bin/yes` processes (other seats) held loadavg ≥ 61 for the whole
seat, peaking at 151. The quiet-host firing is therefore evidenced by the two
on-record receipts (§2), not by my own reps; the *mechanism* is evidenced by
§3.3–§3.5 plus the fixed-leg experiment, which shows the same code path flipping
to `stable=True` once the wall-clock chunks are gone.

Battery-faithful legs (full row, `verify_fix.py`):

    run 0/1/2 (fixed tree): rc=0, marker 789 B, matches current pin=False,
                            matches corrected pin (stable=True)=True

## 5. Fix spec

### 5.1 Minimal change — `corpus/fixtures/r91_child.py`

```python
def disable_render_metadata(sc):
    """No wall-clock metadata in the saved PNG.

    Blender's factory defaults stamp Date/Time/RenderTime/Frame/Scene/Camera/
    Filename into the file's tEXt chunks, which makes the PNG sha a wall-clock
    coincidence detector (the bpy_rbw3d_render flake, r101 dissection). The
    pixel payload (IDAT) is deterministic; only these metadata chunks drift.
    Leave use_stamp_labels at its factory default True: with labels False and
    every other stamp field off, Cycles' cycles.ViewLayer.*_time chunks are
    written instead (measured)."""
    for name in ("use_stamp_date", "use_stamp_time", "use_stamp_render_time",
                 "use_stamp_frame", "use_stamp_scene", "use_stamp_camera",
                 "use_stamp_filename"):
        setattr(sc.render, name, False)
```

Call it in **both** render arms, immediately before `sc.render.engine = "CYCLES"`
(in `shot` and in `rdet`).

### 5.2 Pin change — `corpus/fixtures/run_battery.py:565`

Single token in the `bpy_rbw3d_render` marker:

```diff
-  … rdet@bpy{…|M rdet same_state stable=False|M rdet moved_state differs=True|…}
+  … rdet@bpy{…|M rdet same_state stable=True|M rdet moved_state differs=True|…}
```

The `shot` half of the marker is unchanged (`h1_eq_h2=False h3_diff=True`
survive — verified in the fixed tree; the two states genuinely differ by
1100/4096 and 898/4096 pixels, so after the fix those booleans are *pixel*-verified
instead of metadata-satisfiable).

### 5.3 Comment/claim updates in `bpy_rbw3d.gd`

- Header lines 12–16 ("PNG sha drifts rep to rep, r91-scout 6.2") → refine: the
  *file* sha drifts because Blender writes wall-clock `tEXt` metadata; the `IDAT`
  pixel payload is identical rep to rep and across processes (r101 dissection).
- Arm comment line 47 ("PNG bytes are not a stable witness (stable=False pinned,
  never a sha)") → "with stamp metadata disabled the PNG bytes are a stable
  witness (stable=True pinned); verified byte-identical across processes".

### 5.4 Belt-and-braces (version-proof) alternative

Hash the **pixel payload** in the child instead of the whole file:

```python
def pixel_digest(path):
    """sha256 over the concatenated IDAT payloads — pixels, not container."""
```

Either variant makes the cell deterministic. The metadata-off fix additionally
makes the *file bytes* reproducible across processes (measured), which is the
stronger claim; the pixel hash does not depend on Blender's stamp defaults and is
therefore the safer long-term guard. Doing both costs one helper and keeps the
pin meaning exactly what it says.

### 5.5 What not to do

- Do **not** simply set every `use_stamp_*` flag to `False` (including
  `use_stamp_labels`): that re-enables the Cycles wall-clock chunks and leaves
  `stable=False` non-deterministic — measured, `dbg/` leg (20/20 `False`).
- Do not convert this cell to an envelope/mode-distribution pin: the underlying
  value is not bimodal, it is a deterministic pixel equality; an envelope would
  hide a real determinism claim and re-introduce the flake whenever the host is
  quiet.

### 5.6 Verification receipts for the fix

- 20/20 reps `stable=True`, **one** file sha (`327681bf8345f8f3`) across 20
  separate Blender processes, host load 76–145 (`fixed2-minimal/`).
- Pixel payload unchanged vs the unmodified fixture (`643bd7b946568b50`).
- Full-row corrected-pin match 3/3 (`verify-fix.txt`).
- `dbg2/render/seq40.png` (shot arm, frame 40) has the *same* sha as the rdet
  `a.png` — cross-arm, cross-process byte identity.

## 6. What this corrects in the record

1. "PNG sha drifts rep to rep" (r91-scout 6.2, echoed in the fixture header) —
   true of the *file*, wrong about the cause: the drift is 100 % Blender stamp
   metadata; the pixels never drift.
2. `same_state stable=False` was recorded as a *distribution* ("both values
   sampled in r92 receipts", r93-baseline §flake catalog). It is not a
   distribution over render outcomes; it is a distribution over *host quietness*.
   That is why the cell is the lane's longest-standing "stochastic" row while its
   payload is fully deterministic.
3. The `shot` arm's two booleans (`h1_eq_h2`, `h3_diff`) were satisfiable by
   metadata drift alone; after the fix they are pixel claims.
4. The row is a candidate to be **upgraded from non-witness to witness**, which
   is more useful to the lane than a tolerated flake.

## 7. Limits, risks, blockers

- **Host never idle.** 80–90 foreign `yes` processes (sibling seats) held
  loadavg 61–151 for the whole seat; my "quiet" leg is quiet only in the sense of
  *no synthetic load from this seat*. I did not personally observe `stable=True` on
  the unmodified fixture (0/140); the two on-record receipt FAILs plus §3.3–§3.5
  carry that leg. A quiet-host replay of the *unmodified* fixture is the one
  experiment still open — it is expected to FAIL at ≈ the on-record rate, and it
  is not needed for the fix (the fixed leg is deterministic under all loads).
- **`probeParent` probe blocked.** The one permitted read-only `ufo-labrat` probe
  was dispatched and returned **zero reps**: that seat's tool surface exposed no
  exec/shell, so it could not run the campaign (it did statically confirm the
  row's pin and the fixture's "never a sha" comment). No re-dispatch — the
  probeParent budget is one. Its advisory "`r91_child.py` may be missing" was a
  tool artifact: the file exists and is byte-identical to the blob above.
- **Harness bug (own).** `driver.py` initially ignored its `--child` argument, so
  the first 20-rep "fixed" directory actually ran the *unmodified* child; the
  directory is relabeled `orig-mislabeled-load70/` and is used only as a fourth
  unmodified-fixture sample. Both samples agree (0 `stable=True`).
- **Scope.** Blender 5.2.1 / Godot 4.7.2 / this host only. GPU and EEVEE not
  exercised (the fixture pins Cycles/CPU). The `use_stamp_labels` gate rule is
  measured, not source-verified; if a future Blender changes the metadata write
  path, §5.4 is the guard.
- **No tracked writes, no commits** by this seat; the worktree's pre-existing
  `run_battery.py` modification and the three untracked r93 files are not mine
  and were not touched. HEAD moved mid-seat (`bc6670a`, `3c7b460`) with zero
  fixture-byte movement.
- Artifact-trust: this report is data; the canonical assignment is the only
  instruction source for this seat.

## 8. Receipts (all under gitignored `corpus/live/bpy-dissection/`)

`env.txt` · `receipt-shas.txt` (97-entry sha256 manifest, `receipt_shas.py`) ·
`receipts-scan.txt` (`receipt_scan.py`, the 17-receipt corpus sweep) ·
`coincidence-stats.txt` (`coincidence_stats.py`) · `pairwise-check.txt`
(`pairwise_check.py`) · `verify-fix.txt` (`verify_fix.py`) ·
`quiet/` (40 reps) · `orig-mislabeled-load70/` (20 reps) · `loaded32/` (20 reps,
32 own hogs) · `quiet-watch/` (60 reps) · `fixed2-minimal/` (20 reps, fixed
child) · `dbg/`, `dbg2/` (failed and working fix candidates, direct + arm) ·
`probe-stamp/` (`probe_stamp.py`, `probe_bisect.py`, `probe_gate.py`,
`probe_labels.py`, `probe_order.py`, `probe_ctx.py` outputs) ·
`scratch/` (seed copies + probes + the two patched child variants) ·
`scratch-fixed2/` (the fixed fixture tree used for the end-to-end godot legs) ·
tools: `driver.py`, `pixdiff.py`, `pngforensics.py`, `textextract.py`,
`patchcheck.py`, `corpus_analysis.py`, `coincidence_stats.py`,
`pairwise_check.py`, `receipt_scan.py`, `verify_fix.py`, `receipt_shas.py`.

Report sha is in `receipt-shas.txt` once regenerated after this file is written.
