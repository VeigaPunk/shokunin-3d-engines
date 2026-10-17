# frontier boundary probe — the bpy render-metadata boundary (seat: g3d-bpy-boundary, host: devin)

Lane `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c28783a`
(r99 adjudicate). Blender **5.2.1 LTS** build `9e2066aef7ef` (`/usr/bin/blender -b -P`),
Godot **4.7.2.stable.arch_linux.ed1daf0bf**, kernel **7.2.3-arch1-3**, AMD Ryzen 9
9950X, Python 3.14.7, GPU present (`/dev/dri/card0,1` + `renderD128,129`).

Assignment (dispatch to this seat, verbatim): *"Blender 5.2.1 boundary probing
(blender --background + timeout-bounded): exercise the assigned API surface,
receipts under corpus/live/bpy-boundary/, report at reports/frontier/bpy-boundary.md.
Zero tracked writes outside that report; commit nothing."* The assigned API surface
is the one the contract names — the `bpy_rbw3d_render` cell (`corpus/fixtures/bpy_rbw3d.gd
--arm=render` → `corpus/fixtures/r91_child.py` cases `shot`/`rdet`), i.e. Blender's
**render-output metadata boundary**.

The r101 dissection (`reports/round-101/bpy-dissection.md`) delivered the mechanism and a
fix spec. **This seat asks the boundary question instead: where does that fix stop working?**
Its headline answer: the fix is byte-exact and battery-faithful on PNG/JPEG/Cycles — and it
is **not** a general render-output determinism claim. Four named boundaries bound it, and the
one experiment r101 left open (never observing `stable=True` on the *unmodified* fixture) is
now closed at 4/30 = 13.3 %.

Every receipt is in gitignored `corpus/live/bpy-boundary/` (`git check-ignore` confirms
`corpus/.gitignore:1:live/`). **Zero tracked writes outside this report; no commits.**
Tags: **[O]** receipt-pinned observation, **[I]** inference, **[?]** unknown.

---

## 0. Viability

| command | exit | wall | evidence |
|---|---|---|---|
| `blender -b -P stamp_matrix.py -- runs/A_r<1..4> <tag>` ×4 | 0 | 10.4–14.1 s | 4× `runs/A_r*/stdout.txt`, 300 lines each, `PROBE_DONE`, stderr **0 bytes** |
| `blender -b -P rdet_legs.py -- runs/B <1..12>` ×12 | 0 | 1.46–1.72 s | `runs/B/rep01..12.{stdout,stderr,}` , `PROBE_DONE`, stderr 0 bytes |
| `blender -b -P gate_extra.py -- runs/D_r<1,2> <tag>` ×2 | 0 | 2.85 / 2.86 s | `runs/D_r*/stdout.txt`, `PROBE_DONE`, stderr 0 bytes |
| `blender -b -P flake_repro.py -- runs/E <1..6>` ×6 | 0 | — | `runs/E/rep1..6.stdout.txt`, `PROBE_DONE`, stderr 0 bytes |
| `godot --headless --path proj --script res://bpy_rbw3d.gd -- --arm=render` ×4 | 0 | 2.6–3.0 s | `runs/parent/fixed_rep1..4.stdout.txt` (real parent, fixed child) |
| same, `--path proj-orig` (unmodified child) ×2 | 0 | — | `runs/parent/orig_rep1,2.stdout.txt` (control) |
| `python3 analyze.py` / `summary.py` / `verify_pin.py` | 0 | — | `a-gate.txt`, `a-engine.txt`, `a-format.txt`, `a-bytpe.txt`, `summary.txt`, `runs/parent/verify-pin.txt` |

All Blender legs are `timeout -s KILL 90…400`-bounded; the parent leg inherits the fixture's
own `BOUND_S = 15` per child. Host loadavg was **54–70** for the whole seat (sibling seats),
i.e. never idle — which matters for §5.

**Method.** Every render is byte-dissected, not just hashed: PNG chunk inventory, per-chunk-type
payload sha, the concatenated-`IDAT` (pixel-payload) sha, and the `tEXt` key→value map. The
analyser reads raw stdout, never the fixture.

**Artifacts (sha256[:24]).** `stamp_matrix.py` `d09854ee31e4a50a08c80cb7` ·
`rdet_legs.py` `83915c9012c727306364bc66` · `gate_extra.py` `099a9323e99018c07e086b3b` ·
`flake_repro.py` `067c0a750ed4d2d6b5a3a941` · `analyze.py` `a350cca91e7a4def957e5339` ·
`summary.py` `f19c22308f506a5a04a08053` · `container_diff.py` `3c9f835360f5088947799bbf` ·
`verify_pin.py` `417a050f9f267eff3491601b` · `proj/r91_child.py` (fixed copy)
`49c3d45fa5e7610c3ecb2ff6` · `proj-orig/r91_child.py` (byte-identical to the tracked fixture,
`ab63245b1b29c5c647444ba6f062695679b795383db8b417f08a4df2ba1a6b56`).

---

## 1. The stamp gate, complete (BC-2)

The stamp surface is **16** properties in 5.2.1 (`use_stamp` master + 15 named). Factory state
enables **eight**: `use_stamp_labels`, `date`, `time`, `render_time`, `frame`, `scene`,
`camera`, `filename`. `use_stamp` (master) is **False** at factory. `enum_items`-free:
discovered by scanning `RenderSettings.bl_rna.properties` at runtime.

A1 (CYCLES/PNG, **8 shots over 4 processes** per config). "clean" = exactly **1** distinct
whole-file sha across all 8 shots:

| config (fields enabled) | file classes | tEXt keys written |
|---|---|---|
| `only_labels` / `master_and_labels` / `seven_off_labels_on` | **1** | **zero keys** (`texts=` empty; `tsha=e3b0c44298fc1c14`) |
| `all_off` (incl. labels) | 4 | 4× `cycles.ViewLayer.*` |
| `only_use_stamp` (master only) | 5 | 4× `cycles.ViewLayer.*` |
| each `only_<named field>` (13 cells) | 2–6 | that field + 4× `cycles.ViewLayer.*` |

D (CYCLES/PNG, **8 shots over 2 processes** per config) completes the family A1 could not
reach — **labels ON *plus* one other field**:

| config | file classes | tEXt keys written |
|---|---|---|
| `labels_only` | **1** | **zero keys** (D prints the `texts=(none)` placeholder) |
| `labels_date` | 3 | `Date` + 4× `cycles.ViewLayer.*` |
| `labels_frame` | 2 | `Frame` + 4× `cycles.ViewLayer.*` |
| `labels_scene` | 2 | `Scene` + 4× `cycles.ViewLayer.*` |
| `labels_note` (note is empty) | 4 | 4× `cycles.ViewLayer.*` |
| `labels_render_time` | 4 | `RenderTime` + 4× `cycles.ViewLayer.*` |
| `date_only` | 6 | `Date` + 4× `cycles.ViewLayer.*` |
| `labels_off_control` | 3 | 4× `cycles.ViewLayer.*` |

**Boundary (BC-2) [O].** r101's rule — "leave `use_stamp_labels` at its factory default True" —
is correct but *incomplete as stated*: `use_stamp_labels=True` is **not sufficient**. The clean
state is **`use_stamp_labels` True and no other named stamp field True**. The moment any other
field is enabled alongside labels, the four Cycles wall-clock chunks return and the file sha is
nondeterministic again. The coherent reading **[I]**: the stamp pass writes stamp items *plus*
the Cycles stats; when labels are on but no item exists the whole tEXt write is skipped; when
the stamp pass is disabled (labels off) Cycles writes its own stats unconditionally.

*Trap this creates:* an author who later adds `use_stamp_frame=True` (a reasonable
self-describing-PNG change) silently re-arms the flake. The fix's comment should say
**"labels must be the sole enabled stamp field"**, not "leave labels alone".

---

## 2. Engine axis (BC-3) and the RNA-enum trap (BC-4)

PNG, **16 shots over 4 processes** per cell:

| engine | `defaults` | r101 fix | `all_off` |
|---|---|---|---|
| `CYCLES` | 15 classes | **1** | **6** |
| `BLENDER_EEVEE` | 9 | **1** | **1** |
| `BLENDER_WORKBENCH` | 8 | **1** | **1** |

**BC-3 [O] — the "do not set every flag False" hazard is Cycles-only.** The four
`cycles.ViewLayer.*` chunks are *Cycles'* stats; EEVEE and Workbench write none, so the
`all_off` variant is already deterministic there. The fix itself is engine-uniform (1 class in
all three engines), and both EEVEE and Workbench **render headless on this host** — the engine
axis is fully exercisable, not restricted to Cycles.

**BC-4 [O] — static RNA enum introspection under-reports the live enum.** In a fresh `-b`
session:

```
bpy.types.RenderSettings.bl_rna.properties['engine'].enum_items  ->  ('BLENDER_EEVEE',)
render.engine = "____probe____"  ->  TypeError: enum "____probe____" not found in
                                     ('BLENDER_EEVEE', 'BLENDER_WORKBENCH', 'CYCLES')
```

This seat's first A2 pass derived its engine list from `enum_items` and **silently measured one
engine** (6 rows where 18 were expected; caught by row count, not by a failure). A fixture that
builds an engine axis from `enum_items` tests one engine and reports success. Drive the axis
from literal names, and assert the expected row count. Related: the 5.2.1 EEVEE identifier is
`BLENDER_EEVEE` — the `_NEXT` spelling of 4.2–5.0 raises `TypeError`.

---

## 3. Container axis (BC-5) — the fix is PNG/JPEG-only

CYCLES, **16 shots over 4 processes** per cell:

| container | `defaults` | r101 fix | `all_off` |
|---|---|---|---|
| PNG | 13 classes | **1** | 7 |
| JPEG | 11 | **1** | 7 |
| **OPEN_EXR** | 9 | **4** | 5 |
| **TIFF** | 4 | **5** | 5 |
| BMP | **1** | **1** | **1** |

Byte-diff of the drifting regions (`container_diff.py`):

| container | drifting bytes | what they are |
|---|---|---|
| PNG | inside `tEXt` only | `Date`, `RenderTime`, `cycles.ViewLayer.*_time` |
| JPEG | inside the EXIF/comment stamp block | same stamp block, JPEG-carried: `…ender:RenderTime:00:00.06…$Blender:cycles.View…` |
| OPEN_EXR | offsets 397 / 439 / 580 | EXR **header string attributes** `cycles.ViewLayer.render_time`, `.total_time` — **not gated by any stamp flag** |
| TIFF | 3 bytes at offset ~293 | a **`DateTime` tag**, `2026:10:16 05:46:56` vs `05:47:08` — **not gated by any stamp flag** |
| BMP | **0** | BMP carries no metadata at all |

**BC-5 [O].** "Hash the file" is a valid witness for **PNG and JPEG** after the fix. It is *not*
valid for EXR or TIFF: those two keep a wall-clock source the stamp flags never touch, so the
same fix that makes PNG byte-exact leaves EXR at 4 classes / TIFF at 5. BMP is deterministic in
every configuration because it has no metadata surface — but BMP is also the only container here
with no stamp support at all, so it is a determinism witness for pixels only.

---

## 4. Pixel-payload invariance (BC-6)

Aggregated over every PNG the probe wrote (4 processes × all configs, 3 engines, 5 formats):

| chunk | classes | value |
|---|---|---|
| `IDAT` | 3 — **one per engine** | `5b06fd4243df6e09` (CYCLES) · `d55cfc0bab59f128` (EEVEE) · `b1da534882ce94b8` (WORKBENCH) |
| `IHDR` | 1 | `ee3c8317cdd1cc6f` |
| `sRGB` / `gAMA` / `cHRM` / `oFFs` / `pHYs` / `IEND` | 1 each | `084fed08b978af4d` / `96256bc24f55fcd0` / `b287d3e5cf693bc1` / `3e7077fd2f66d689` / `e12fceb19829f8ca` / `e3b0c44298fc1c14` |
| `eXIf` | 1 | `bac3a1a58a16fd31` |
| `tEXt` | 119 | the metadata chunk |

**BC-6 [O].** The pixel payload never drifts within an engine, and every non-`tEXt` container
block is a single class. `eXIf` is one class over the entire probe, extending r101's
`bac3a1a58a16…` across 3 engines / 5 formats / 4 processes.

*Consequence for the belt-and-braces variant (r101 §5.4):* a pixel digest is **engine-scoped**.
A digest constant pinned for CYCLES is not the EEVEE constant — pin it per engine, or pin only
its invariance.

---

## 5. The flake, reproduced on the unmodified path (BC-7)

r101 §7 left exactly one experiment open: *"I did not personally observe `stable=True` on the
unmodified fixture (0/140); the two on-record receipt FAILs plus §3.3–§3.5 carry that leg. A
quiet-host replay of the unmodified fixture is the one experiment still open."* This seat closes
it — **without a quiet host** (loadavg 69–70), by attacking the coincidence instead of waiting
for one.

`flake_repro.py`: the unmodified rdet scene, 5 resolutions × 6 processes = **30 cells**:

| measure | value |
|---|---|
| `stable=True` (the row's FAIL condition) | **4 / 30 = 13.3 %** |
| on-record rate (r101 §2, 17 receipts) | 2 / 17 = 11.8 % |
| `tsha_same == stable` | **30 / 30** |
| `idat_same` (pixels identical) | **30 / 30** |
| fixed control at res 64 | **6 / 6** `stable=True`, **1** file class |

Firing cells: `rep1res16`, `rep3res8`, `rep4res64`, `rep6res64`.

**BC-7 [O].** The flake reproduces on the shipped fixture at a rate statistically consistent
with the on-record 11.8 %, on a **busy** host. `tsha_same == stable` in 30/30 cells is the
cell-level form of r101's pairwise equivalence: *file-sha equality ⇔ metadata-tuple equality*,
exactly, with no counterexample. So the correct reading is not "load-inverted" but **"a
coincidence rate"**: three consecutive renders of one state land on the same `Date` second and
the same centisecond duration strings with probability ≈10–15 % per rep on this host; host load
moves that probability, it does not gate the outcome. The pin asserts `stable=False`, so the
cell FAILs at that rate and PASSes otherwise — a coin-flip row whose payload was never
stochastic.

---

## 6. Fix legs and the battery-faithful pin (BC-8, BC-1)

`rdet_legs.py` mirrors the `rdet` case verbatim (same build, same 1..40 sweep, three same-state
shots + the frame-1 moved shot), 3 variants × **12 processes**:

| variant | `abc` `stable` | `abc` file classes | `abc` idat classes | `moved` `differs` | `moved` file classes | `mw_stable` |
|---|---|---|---|---|---|---|
| unmodified | 0/12 | 33 over 36 files | 1 (`643bd7b946568b50`) | 12/12 | 12 | all True |
| **fixed** | **12/12** | **1** (`327681bf8345f8f3`) | 1 (`643bd7b946568b50`) | 12/12 | **1** (`e48f66abbe196687`) | all True |
| `all_off` | 2/12 | 7 | 1 | 12/12 | 4 | all True |

The `moved` shot's idat is `5b06fd4243df6e09` in all 36 variant-runs — one class, differing from
the settled state's — so `differs=True` is a genuine **pixel** claim after the fix, not a
metadata-satisfiable one. `mw_stable=True` on every shot re-confirms *render does not step the
sim*.

Battery-faithful leg — the real parent, fixed child, 4 reps:

| leg | reps | distinct markers | `stable=True` | `stable=False` | pin check |
|---|---|---|---|---|---|
| fixed (`proj/`) | 4 | **1** (byte-identical) | present | absent | `flipped == emitted` → **True** |
| orig control (`proj-orig/`) | 2 | 1 | absent | present | `pin == emitted` → **True** |

`verify_pin.py` reads the marker literal out of the tracked `run_battery.py` and compares:
the emitted marker and the shipped pin differ at **exactly one byte offset** (723), the single
token `same_state stable=False` → `same_state stable=True`. The `shot` half of the marker
(`h1_eq_h2=False h3_diff=True`) is unchanged and now pixel-backed. **BC-8 [O] — the fix is
byte-exact and the pin flip is the whole change.** Marker shas: fixed
`e6406643db5dbabd`, unmodified control `01f86ffefa3844f7`.

**BC-1 [O] — ordering boundary: `wm.read_factory_settings` resets the stamp flags.** This
seat's first patch placed `disable_render_metadata(sc)` at the top of each render arm, before
`build()`. The battery-faithful parent then emitted `stable=False` **3/3** (`runs/parent/
mislabeled-preorder/`, kept as a receipt) — the fix had been silently undone by the
`read_factory_settings(use_empty=True)` inside `build()`. Those three markers are
byte-identical to the *unmodified* control's, i.e. the misplaced fix is behaviourally
indistinguishable from no fix. The fix must be applied **after** the scene build; r101's
"immediately before `sc.render.engine = "CYCLES"`" is a hard requirement, not style.
*(This seat's own harness bug, of the same class as r101's `driver.py --child` bug; it is
reported as the boundary it revealed.)*

---

## 7. Boundary classes found (the deliverable)

| # | boundary | where the fix/claim stops working | evidence |
|---|---|---|---|
| BC-1 | **ordering** | fix placed before `build()` → `read_factory_settings` resets stamps; row reverts to `stable=False` | 3/3 `mislabeled-preorder` |
| BC-2 | **gate** | `use_stamp_labels=True` is necessary but not sufficient — any *other* enabled field re-admits the Cycles wall-clock chunks | A1 20 cells + D 8 cells |
| BC-3 | **engine** | the `all_off` hazard is Cycles-only; EEVEE/Workbench are clean either way | 9 cells × 16 shots |
| BC-4 | **introspection** | `bl_rna … enum_items` under-reports the live enum (1 of 3 engines) — a derived axis silently tests one engine | `M ENGINES rna_static=BLENDER_EEVEE dynamic=(EEVEE,WORKBENCH,CYCLES)` |
| BC-5 | **container** | fix is PNG/JPEG-only; EXR keeps `cycles.ViewLayer.*_time` header attributes, TIFF keeps an ungated `DateTime` tag | 15 cells × 16 shots + byte-diff |
| BC-6 | **payload scope** | the pixel digest is engine-scoped (1 class per engine, 3 engines) | whole-probe `bytype` |
| BC-7 | **flake rate** | unmodified fixture fires `stable=True` at 13.3 % on a busy host — a coincidence rate, not a load threshold | 30 cells × 6 processes |
| BC-8 | **sufficiency** | on PNG/Cycles the fix is byte-exact end-to-end; one token flips the pin | 4 parent reps + 12 process reps |

---

## 8. Confidence, limits, unknowns

**Independent re-derivation.** The one permitted read-only probe (bounded, no shell, no writes)
was given 8 headline claims and asked to re-derive each from the raw `runs/` receipts without
trusting `summary.txt` or `analyze.py`. Result: **8/8 AGREE** (gate cells 1–3, rdet legs 4–5,
flake cells 6–7, parent markers 8), with two corrections folded into this report — the A1
`texts=` field for the clean cells is *empty*, not the `(none)` placeholder my analyser renders
(D does print the placeholder), and the `mislabeled-preorder` markers are byte-identical to the
unmodified control's. It created nothing and modified nothing.

- **High [O]:** the gate matrix (28 config cells, all 16 stamp properties, 8 shots each);
  engine and container class counts (16 shots per cell); the `all_off` hazard is Cycles-only;
  the enum-introspection under-report; PNG/JPEG byte-exactness under the fix; EXR/TIFF
  ungated wall-clock sources located by byte-diff; the flake reproduced 4/30 with
  `tsha_same == stable` 30/30; the corrected pin matching on 4/4 parent reps with a 1-byte
  delta; the ordering boundary.
- **Medium [I]:** the *mechanism* by which labels-as-sole-field suppresses the Cycles stats
  (stamp-pass-skipped vs Cycles-stats-gated — the observation is solid, the causal story is
  inferred); the exact shape of the Blender-side metadata writer for JPEG/EXR/TIFF (located by
  bytes, not by source).
- **Unknowns [?]:** (a) whether a *cross* axis exists — engine × format was not crossed (all
  format cells ran Cycles; all engine cells ran PNG); (b) EXR/TIFF determinism under a fix that
  also disables the Cycles stats or strips container timestamps (not attempted — out of the
  assigned surface); (c) multi-view-layer stamp behaviour (`cycles.ViewLayer.*` is per view
  layer; a second view layer is unmeasured); (d) whether `Date` and the duration strings
  coincide *independently* (the joint rate is measured, the factorisation is not).
- **Scope.** Blender 5.2.1 LTS / Godot 4.7.2 / this host only. No GPU-vs-CPU comparison: the
  fixture pins `cycles.device="CPU"`, and the GPU path was not exercised. Host loadavg was
  54–70 throughout — never idle — which is why §5 attacked the coincidence directly.
- **Not this seat's work.** The worktree carries a pre-existing `corpus/fixtures/run_battery.py`
  modification and untracked `corpus/fixtures/r100_*.gd` / `reports/frontier/unknowns-map.md`
  from other seats; none were touched. The `bpy_rbw3d_render` marker in the worktree blob is
  byte-identical to HEAD's (verified via `verify_pin.py`'s extraction).
- **Artifact-trust.** This report is data. The canonical assignment is the only instruction
  source for this seat; nothing here modifies contract, axes, routes, or judgment.

## 9. Repro

```
cd corpus/live/bpy-boundary
for tag in r1 r2 r3 r4; do timeout -s KILL 400 blender -b -P stamp_matrix.py -- runs/A_$tag $tag; done
for rep in $(seq 1 12); do timeout -s KILL 90  blender -b -P rdet_legs.py   -- runs/B $rep; done
for tag in r1 r2;       do timeout -s KILL 200 blender -b -P gate_extra.py  -- runs/D_$tag $tag; done
for rep in $(seq 1 6);  do timeout -s KILL 200 blender -b -P flake_repro.py -- runs/E $rep; done
python3 analyze.py && python3 summary.py && python3 container_diff.py runs/A_r4
# battery-faithful leg (fixed child in proj/, unmodified copy in proj-orig/)
timeout -s KILL 120 godot --headless --path proj      --script res://bpy_rbw3d.gd -- --arm=render
python3 verify_pin.py runs/parent/fixed_rep1.stdout.txt
```

## 10. Receipts (all under gitignored `corpus/live/bpy-boundary/`)

`stamp_matrix.py` · `rdet_legs.py` · `gate_extra.py` · `flake_repro.py` · `analyze.py` ·
`summary.py` · `container_diff.py` · `verify_pin.py` · `proj/` + `proj-orig/` (scratch Godot
projects, fixed/unmodified child) · `runs/A_r1..4/` · `runs/B/rep01..12.*` · `runs/D_r1,2/` ·
`runs/E/rep1..6.*` · `runs/parent/{fixed_rep1..4,orig_rep1,2}.stdout.txt` ·
`runs/parent/mislabeled-preorder/` · `runs/parent/verify-pin.txt` · `a-gate.txt` ·
`a-engine.txt` · `a-format.txt` · `a-bytpe.txt` · `summary.txt` (aggregate + sha256[:16]
manifest of every text receipt) · render binaries (`*.png/.jpg/.exr/.tif/.bmp`, 638 files)
retained in `runs/`.

Leaf seat: no dispatch beyond the single read-only probe, no tracked writes outside this
report, no commits.
