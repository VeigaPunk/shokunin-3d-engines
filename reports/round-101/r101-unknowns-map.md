# r101 unknowns map — cross-round `[?]` harvest + the top-3 measured headless

Lane: g3d · engine `4.7.2.stable.arch_linux.ed1daf0bf` (`/usr/bin/godot`) ·
`--headless` · tps 30/60/120 · backends GodotPhysics (this round's cells; r100
owns the backend sweep).

Seat: g3d unknowns consolidator (read-execute hybrid). Task: grep every
`reports/round-*/` for `unknown` / `[?]` / `unmeasured` / `risk`, collate the
open set into a ranked falsifiability table, then MEASURE the top 3 falsifiable
ones with bounded probes under the `r101u_*` namespace.

Evidence: `corpus/live/r101-unknowns/` (gitignored) — `probes/` (4), 9 project
variants, `driver.py`, `starve.py`, `sum.py`, `runs/` (**264 children**, 4
sidecars each: `.stdout.txt`/`.exit`/`.ms`/`.cmd`), `*_batch.log`,
`summary.txt`, `manifest.sha256` (850 entries; 1115 files, 4.6 MB). The only
tracked-tree write is this report. No commits, no fixture edits.

Confidence: **[O]** receipt-pinned observation, **[I]** inference, **[?]** unknown.

---

## 0. Method and provenance

- Harvest: one bounded regex pass over all 301 report files (headers matching
  unknown/deferred/remaining/caveat/not-probed/unmeasured/risk + every `[?]`
  line), then per-surface reading of the current rounds (r86–r100) and the
  scribe "Retained UNKNOWNs" blocks (r70–r76) for resolution status. The table
  in §1 is the deduplicated open set; rows closed by later rounds are marked.
- Probes (sha-pinned):
  - `r101u_sched.gd` — **byte-identical copy** of r100-scout `rs_sched.gd`,
    sha `c61025594deff49dfbd7819376a9e6379dca6efb5c6d7b0aa149aa79cbc86849`;
  - `r101u_modes.gd` — **byte-identical copy** of r100-boundary
    `r100b_modes.gd`, sha
    `249c0caf8ac4a1d5270beccadd65d99d0083a1db77264d56958a8ec0ac884896`;
  - `r101u_main.gd` — new: the rs_sched rig as a **project main-scene Node**
    (no `--script`), same RS_* field formats, additive `steps_max` and
    `--block-us=/--block-n=` idle-frame blocker, summary also emitted from
    `_exit_tree()` so `--quit-after` cells still print RS_END;
  - `r101u_block.gd` — new: the same rig as a `SceneTree` script (the
    `--script`-mode control for the blocker arm).
- Faithfulness cross-check **[O]**: in `--script` mode the byte-identical
  probes reproduce r100-scout's published receipts **exactly** for every mode
  they tabulated (5/10/30/60/90/120/240: n_pr, n_ph, fpt histogram, d0, traj
  hash; e.g. ffps60
  `RS_END n_pr=120 n_ph=120 pf=120 ff=120 fpt=[0:1, 1:119] traj=2311ff14cd04c227`
  vs r100-scout's own receipt), and the additional 300/600 cells match
  r100-boundary's published `a(N)`/`d0` values (2/0.008333333 and
  4/0.008333333). The rig is the r100 rig.
- Accounting: **264/264 children rc=0** (236 batch + 16 follow-up + 12 starved;
  no kill, no timeout, no rc=137). Every child `timeout -s KILL`-bounded.
- Rep identity **[O]**: of 110 multi-rep tags, exactly **10 are unstable**, and
  all 10 are the unpinned cells by construction (`base`, `b0`, `b100ms3` in
  both loop modes) — the r92 idle-multiplicity defect. Every tag where the
  pinned rate took effect is byte-identical across reps (core END line **and**
  full receipt after dropping wall-clock lines), in both loop modes, at all
  tps and both jitter settings.

---

## 1. Ranked table of open unknowns

Rank = falsifiability × headless-measurability on this host × blocking effect
on the lane's fixtures. "Meas." = measured this round. Rows R1–R3 are the
measured top 3; the rest are the ranked open set.

| R | surface | round(s) | unknown | falsifiable | headless now | blocking | status |
|---|---|---|---|---|---|---|---|
| 1 | scheduler | r100-scout §10, r100-boundary §11 | does the `--fixed-fps` rate law hold in a **real main loop** (no `--script`)? rendered/exported/`--write-movie` unmeasured | yes | main-loop half yes; rendered no | high (all future fixtures) | **MEASURED §2** — holds verbatim in the headless main loop; rendered half still [?] |
| 2 | scheduler | r100-scout §10, r100-boundary §11 (also r83/r85/r86 "unmeasured") | is `max_physics_steps_per_frame` live outside `--headless --script`? | yes | yes | high (catch-up safety) | **MEASURED §3** — live on the catch-up path in **both** loop modes; **bypassed by `--fixed-fps`**; rendered context still [?] |
| 3 | scheduler | r100-boundary §3.2/§11, r100-scout §2 | exact closed form of `a(N)` (startup offset) and the N < tps transient | yes | yes | med-high (tick budgets) | **MEASURED §4** — best fit falsified at 10 cells; ramp characterized; exact form still [?] |
| 4 | scheduler | r100-boundary §5/§11 | `--quit-after` tick budget away from N = tps | yes | yes | med | **PARTIAL §4.3** — 9/9 table replicated; model fits 7/7 N > tps, −1 at N < tps |
| 5 | scheduler | r100-scout §10 | `--max-fps` interleave outliers (2:1, 3:1) vs host load | yes | yes | low | open |
| 6 | scheduler | r100-boundary §11 | the 1 µs frame-slice floor: documented clamp or artifact? | weak | no (engine source absent — §6) | low | open |
| 7 | scheduler | r100-scout §10, r92 §7.8 | `--fixed-fps` × `physics_interpolation=true` in a **rendered** context | yes | no (needs renderer) | med | open |
| 8 | scheduler | r100-boundary §7 | `--write-movie` SIGSEGV in headless (rc=134) root cause | yes | repro yes, root cause needs renderer | low | open |
| 9 | scheduler | r96-boundary §9 | `--time-scale` × `--fixed-fps` interaction | yes | yes | low | **closed** by r100-boundary §7 (composition measured) |
| 10 | scheduler | r100-scout §7.5, r100-boundary §6 | Jolt job-system warning trigger mechanism (rate is load-dependent, 38→92 %) | yes | yes | low | open (inference only) |
| 11 | physics | r96-scout §9 | exact `baumgarte_stabilization_factor` → depenetration-rate rule | yes | yes | med | open |
| 12 | physics | r96-scout §9 | Jolt resting-contact offset under gravity (`0.300000012` vs GP `0.290000051`) | yes | yes | med | open |
| 13 | physics | r96-scout §9 | GP/Jolt rebound-apex difference (~15 mm) — contact-tick resolution | yes | yes | med | open |
| 14 | physics | r96-scout §9 | does `generate_all_kinematic_contacts=true` change *solving* (not just reporting)? | yes | yes | low | open |
| 15 | physics | r96-scout §9 | is Jolt `position_steps=0` reachable through a node API? | yes | yes | low | open |
| 16 | physics | r83–r88 | Jolt × `run_on_separate_thread` cross-products (several arms live-only/unprobed) | yes | yes | med | open |
| 17 | physics | r92-boundary §7(d) | `physics_jitter_fix` observable only under a *throttled* render loop? | yes | headless partially (pinned-rate live: r100b §3.3; throttled loop no) | med | partial |
| 18 | physics | r92-scout §7.2 | negative `time_scale`: effect on the solver | yes | yes | low | open |
| 19 | physics | r92-scout §7.3 | `sync_to_physics` kinematic-vs-friction distinction | yes | yes | low | open |
| 20 | physics | r86-boundary §8 | in-integrator event-tier delta (no signal within 9 ticks) | yes | yes | low | open |
| 21 | physics | r85/r86 | *why* the threaded fetch window is script-size-dependent (~475–575-line band) | mechanism only | partial | low | open (inference) |
| 22 | physics | r87 | write-loss class not reproduced (0 lost / 144 out-of-phase writes) | yes (stress form) | yes | low | open |
| 23 | animation | r92-scout §4, r93-scout §7, r100-scout §10 | `PhysicalBoneSimulator3D`: bone poses never follow — needs skinned/imported skeleton + non-`NONE` joint | yes | yes (r98 `GLTFDocument` path) | med-high | open (deferred with named rig defect) |
| 24 | animation | r99-scout/boundary | `AnimationTree`/`AnimationNodeBlendSpace1D/2D`, `OneShot`, `Transition`, `Add2/3`, `Mix*`, `Sync`, `play_mode`/`backward`, `root_motion`, skeleton targets | yes | yes | med | open |
| 25 | animation | r99-scout | what `ADVANCE_MODE_ENABLED` actually requires | yes | yes | low-med | open |
| 26 | animation | r99-scout/boundary | `xfade_time` crossfade (`SWITCH_MODE_AT_END`, `reset=false`, `break_loop_at_end`) | yes | yes | low-med | open |
| 27 | animation | r99-scout | untracked-default mechanism (library-wide path set vs per-path cache) | yes | yes | low | open |
| 28 | glTF | r98-scout | bad-magic → JSON fallback keyed on extension or magic sniff? | yes | yes | med | open |
| 29 | glTF | r98-scout | skins/animations/physics-extension payloads/cameras/lights/textures/external `.bin` | yes | yes | med | open |
| 30 | glTF | r98-scout | `GLTFDocumentExtension`/`GLTFObjectModelProperty` runtime hooks | yes | yes | low | open |
| 31 | glTF | r98-scout | `set_root_nodes`/`root_nodes` via property syntax | yes | yes | low | open |
| 32 | glTF | r98-scout | ResourceLoader recognition in `--editor`/exported-template context | yes | partial (`--editor` maybe) | low | open |
| 33 | scene | r97-boundary | deferred deletion is process-frame or step-granular? | — | — | — | **closed** (step-granular; hypothesis rejected) |
| 34 | nav | r70–r75 | moving-agent locomotion dynamics / repath windows (stationary-agent only so far) | yes | yes | med | open |
| 35 | nav | r75 | multi-agent and node-authored `NavigationLink3D` unexercised | yes | yes | low | open |
| 36 | nav | r75 | server-sync latency ~2–3 frames measured-not-cased | yes | yes | low | open |
| 37 | nav | r71/r72 | ULP float edges; non-corridor geometry | yes | yes | low | open |
| 38 | nav | r76-scout §? | `map_set_active(false)` mid-run (unprobed anywhere) | yes | yes | low | open |
| 39 | frontier | r94-scout | cannon-es: SPOOK restitution mapping (apexes above Coulomb), friction-combine semantics, asymmetric multi-contact add-order bit-invariance | yes | no (node/cannon-es, separate runtime) | low-med | open |
| 40 | frontier | r95-scout | pybullet: `inf-pos` never decays, `inf-mass` poisoning path, multi-body bit stability, multi-link URDF | yes | no (pybullet, separate runtime) | low | open |
| 41 | frontier | r90/r91 | bpy: bake-cache invalidation rule, save/reload round trip, cloth/soft-body caches | yes | no (Blender) | low | open |

Rows 34–38 are the still-open remnants of the r70–r76 retained-UNKNOWN blocks
(the metadata-flag, latch-release, pop-through, off-mesh, pmd and zombie-window
questions were closed by r73–r75 and are not listed). Rows 39–41 live on other
runtimes (node/pybullet/Blender) and are therefore outside a Godot-headless
probe; they are ranked low for this seat but not dismissed.

---

## 2. R1 measured — the `--fixed-fps` rate law in a real main loop

**Question (r100-scout §10):** "whether the same law holds with a real
`SceneTree` main loop" — every r100 cell was `--headless --script`.

**Rig.** `proj_main` is a normal project with `run/main_scene="res://main.tscn"`;
the scene root runs `r101u_main.gd` (the rs_sched rig: same stage, same
0.5-radius `RigidBody3D` at y=5, same `--ticks=120` self-quit). Script-mode
twins run the byte-identical `r101u_sched.gd`. 3 reps per cell; load recorded
(sibling lanes active throughout).

**[O] Result: the law is loop-mode invariant.** All nine pinned modes have
identical fpt histograms, identical first-frame delta, and the **identical
trajectory hash** in both loops; only `n_pr`/`ff` differ, by exactly 1:

| mode | script `n_pr` | main `n_pr` | fpt (both) | d0 (both) | traj (both) |
|---|---|---|---|---|---|
| base (unpinned) | 288 | 288 | rep-variable | rep-variable | `2311ff14cd04c227` |
| `--fixed-fps 5` | 11 | 10 | `[0:110, 1:10]` | 0.200000000 | `2311ff14cd04c227` |
| `--fixed-fps 10` | 21 | 20 | `[0:100, 1:20]` | 0.100000000 | `2311ff14cd04c227` |
| `--fixed-fps 30` | 61 | 60 | `[0:60, 1:60]` | 0.025000000 | `2311ff14cd04c227` |
| `--fixed-fps 60` | 120 | 119 | `[0:1, 1:119]` | 0.016666667 | `2311ff14cd04c227` |
| `--fixed-fps 90` | 180 | 179 | `[0:1, 1:59, 2:60]` | 0.016666667 | `2311ff14cd04c227` |
| `--fixed-fps 120` | 239 | 238 | `[0:1, 2:119]` | 0.016666667 | `2311ff14cd04c227` |
| `--fixed-fps 240` | 478 | 477 | `[1:1, 4:119]` | 0.008333333 | `2311ff14cd04c227` |
| `--fixed-fps 300` | 598 | 597 | `[2:1, 5:119]` | 0.008333333 | `2311ff14cd04c227` |
| `--fixed-fps 600` | 1195 | 1194 | `[4:1, 10:119]` | 0.008333333 | `2311ff14cd04c227` |

Verbatim, the two `--fixed-fps 60` twins:

```
script  RS_END n_pr=120 n_ph=120 pf=120 ff=120 fpt=[0:1, 1:119] traj=2311ff14cd04c227
main    RS_END n_pr=119 n_ph=120 pf=120 ff=119 fpt=[0:1, 1:119] steps_max=1 traj=2311ff14cd04c227
```

- **[O] The physics is identical**: `traj=2311ff14cd04c227` in every cell of
  every mode — the same hash r100-scout published — including the unpinned
  cells. The main loop does not move a single bit of the trajectory.
- **[O] The interleave is identical**: histogram and d0 match the script twin
  exactly in all nine pinned modes (and d0 matches r100-boundary's two-regime
  law: `1/tps` for N ≤ 2·tps, `1/(2·tps)` for N > 2·tps).
- **[O] The one difference is quit semantics, not scheduling**: `n_pr`/`ff` is
  exactly one less in main mode because the self-`quit()` from
  `_physics_process` ends the run before that iteration's idle callback; the
  script-mode SceneTree still runs the final `_process`. Fixtures that key on
  `n_pr`/`ff` must not share a pin across the two loop modes; fixtures that key
  on `fpt`/`traj` can.
- **[O] The unpinned defect is loop-mode independent**: `base` is the only
  rep-unstable cell in each loop (3/3 differ), i.e. the r92 idle-multiplicity
  defect that `--fixed-fps` removes is present in a real main loop too — the
  remedy transfers.

Scope: `--headless` main loop only. A *rendered* loop, `--write-movie`, and an
exported template remain unmeasured (row 1's residual) — this host cannot
render headlessly (`--write-movie` SIGSEGVs, r100-boundary §7).

---

## 3. R2 measured — `max_physics_steps_per_frame` outside `--script`

**Question (r100-scout §10):** "whether it is live in a rendered / non-`--script`
loop is untested". r100 found it inert in `--script` mode at 12 steps/frame
(`--fixed-fps 5`) and r100-boundary at 60 steps/frame (`--fixed-fps 1`).

**Design.** Two arms in both loop modes, cap 8 (default) vs cap 1 project bake:

1. *fixed-fps arm*: `--fixed-fps {60,5,1}` — the path r100 tested;
2. *catch-up arm*: unpinned, with the first three idle frames blocked 100 ms
   each (`--block-us=100000 --block-n=3`) — the path the cap exists for.

**[O] Results** (`steps_max` = max physics steps executed inside one process
frame; 3 reps each; capped cells 3/3 identical):

| loop | cap | `--fixed-fps 60` | `--fixed-fps 5` | `--fixed-fps 1` | block 100 ms ×3 |
|---|---|---|---|---|---|
| script | 8 | 1 | 12 | 60 | **6** (6/6/6) |
| script | 1 | 1 | 12 | 60 | **1** (3/3) |
| main | 8 | 1 | 12 | 60 | **6–7** (7/7/6) |
| main | 1 | 1 | 12 | 60 | **1** (3/3) |

Verbatim:

```
script cap8 --fixed-fps 1   BM_END n_pr=2 n_ph=120 pf=120 ff=2 fpt=[0:119, 1:1] steps_max=60
script cap1 --fixed-fps 1   BM_END n_pr=2 n_ph=120 pf=120 ff=2 fpt=[0:119, 1:1] steps_max=60
main   cap1 --fixed-fps 1   RS_END n_pr=1 n_ph=120 pf=120 ff=1 fpt=[0:119, 1:1] steps_max=60
script cap8 block100ms3     RS_END n_pr=247 n_ph=120 pf=120 ff=247 fpt=[0:16, 1:5, 2:56, 3:43] steps_max=6
script cap1 block100ms3     RS_END n_pr=282 n_ph=120 pf=120 ff=282 fpt=[0:1, 1:5, 2:66, 3:48] steps_max=1
main   cap1 block100ms3     RS_END n_pr=283 n_ph=120 pf=120 ff=283 fpt=[0:1, 1:4, 2:66, 3:49] steps_max=1
```

- **[O] The cap is live in `--headless`** — on the catch-up path it clamps a
  burst of 6 (script) / 6–7 (main) physics steps to exactly **1** in both loop
  modes. The r100 "inert" reading was an artifact of the fixed-fps path plus
  ambient headless frame rates: an unpinned frame that does not overrun a tick
  never accumulates more than one step, so the cap is invisible without a
  blocking frame.
- **[O] `--fixed-fps` bypasses the cap entirely** — 12 steps/frame at N=5 and
  60 steps/frame at N=1 with cap=1, in both loop modes (the r100-boundary
  result reproduced). The fixed-rate scheduler is not the accumulator.
- **[O] The trajectory is cap-invariant**: `traj=2311ff14cd04c227` in every
  capped and uncapped cell; the cap changes pacing (n_pr 247→282), never the
  physics.
- **[I]** (labelled inference, no source on host) the cap sits on the
  accumulator's catch-up loop, which `--fixed-fps` does not use. This is the
  only reading consistent with all four cells; it is not source-verified (§6).

Fixture consequence: a fixture that asserts *anything* about catch-up behaviour
(e.g. a deliberately slow frame, or a spiral-of-death guard) **must pin
`max_physics_steps_per_frame` explicitly** and must not combine it with a
pinned rate. A rendered/throttled loop is still untested (row 2's residual).

---

## 4. R3 measured — `a(N)`, the startup transient, and the `--quit-after` budget

**Question (r100-boundary §3.2/§11):** the best fit `a = ceil(N/(2·tps)) − 1`
had 20/21 support with one named exception (tps 30, N 240); the exact generating
formula was **[?]**. `a` = number of process frames before tick 1 (= first
bucket of the fpt histogram).

### 4.1 The best fit is falsified on a wider sweep **[O]**

57 script-mode cells in the ambient sweep (49 at jit 0.5 + 8 at jit 0.0, tps
30/60/120, 2 reps, all core-stable; plus 4 starved tags §4.1 bullet 1). At
`physics_jitter_fix=0.5` the fit holds on 39/49 cells and **fails on 10** —
nine of them new:

| tps | N | F = N/tps | measured `a` | `ceil(N/(2·tps))−1` |
|---|---|---|---|---|
| 60 | 480 | 8 | **4** | 3 |
| 60 | 840 | 14 | **7** | 6 |
| 60 | 1920 | 32 | **31** | 15 |
| 60 | 3840 | 64 | **63** | 31 |
| 30 | 240 | 8 | **4** | 3 (r100-boundary's known exception) |
| 30 | 480 | 16 | **8** | 7 |
| 30 | 720 | 24 | **23** | 11 |
| 30 | 960 | 32 | **31** | 15 |
| 120 | 960 | 8 | **4** | 3 |
| 120 | 1920 | 16 | **8** | 7 |

All other measured cells (including every fractional F: 0.75, 0.983, 1.017,
1.25, 1.5, 2.017, 2.05, 2.17, 2.25, 2.33, 2.5, 2.67, 3.33, 3.5, 3.67, 4.17)
match the fit exactly. The anomaly appears at F ∈ {8, 14, 16, 24, 32, 64} and
**not** at F ∈ {2, 3, 4, 5, 6, 10, 12, 20}; for F ∈ {8, 14, 16} the measured
value is `F/2`, for F ∈ {24, 32, 64} it is `F−1`. **[?]** the rule that selects
the anomalous F is still not derived.

- **[O] The anomaly is not host timing.** Under `taskset -c 3` starvation with
  4 pinned hogs, N ∈ {480, 600, 840, 1920} × 3 reps are **byte-identical to the
  ambient receipts** (12/12; `traj` unchanged). The startup phase is a
  deterministic function of (N, tps, jitter fix), not of wall-clock speed.
- **[O] The r100-boundary "corrected arithmetic" also fails at large N**:
  `n_pr = a + (n_ticks−1)·N/tps + 1` gives 1674 for (60, 840) but the receipt
  says **1681**, and 2390 for (60, 1200) but the receipt says **2400**. The
  extra frames are a **single stretched final interval** (the 120th tick's
  bucket is `21` vs the steady `14`, and `30` vs `20`), i.e. an end-of-run
  phase slip the formula does not model.
- **[O] At `physics_jitter_fix=0.0` the clean formula survives**: `a =
  ceil(N/tps) − 1` holds **8/8** (45, 75, 119, 121, 150, 240, 300, 600) — the
  r100-boundary 7/7 extended by N=45 — and `d0 = 1/N` exactly in all 8 cells.

### 4.2 The startup transient is a 2-frame delta ramp **[O]**

In units of the physics step (`d/step`), every N > 2·tps cell measured:

```
frame 1: 0.5            (= 1/(2·tps), the two-regime d0 law, confirmed 49/49)
frame 2: 2/F            (= 2·step/N)
frame 3+: 1/F           (= step/N, steady)
```

Verbatim (N=1920, F=32): `d = 0.008333333, 0.001041667, 0.000520833, …` →
`0.5, 0.0625, 0.03125, …` in step units. This **refines** r100-scout §2's "the
first frame is the only frame that does not carry 1/N" and r100-boundary §3.1:
frames 2 (and for fractional F, frame 3) also deviate, and the deviation is a
halving ramp, not a one-frame artifact.

### 4.3 `--quit-after` away from N = tps — table replicated, model bounded **[O]**

9 cells at tps 60, 2 reps each, all rep-identical; the measured `n_ph` column
**reproduces r100-boundary's published table exactly** (40/24/67/16/61/12/10/8/15):

| N | M | `n_ph` | `a(N)` | `M·60/N` | model `floor((M−1−a)/F)+1` |
|---|---|---|---|---|---|
| 45 | 31 | 40 | 0 | 41.33 | 41 (**−1**) |
| 75 | 31 | 24 | 0 | 24.80 | 25 (**−1**) |
| 90 | 101 | 67 | 0 | 67.33 | 67 |
| 120 | 31 | 16 | 0 | 15.50 | 16 |
| 150 | 31 | 12 | 1 | 12.40 | 12 |
| 180 | 31 | 10 | 1 | 10.33 | 10 |
| 240 | 31 | 8 | 1 | 7.75 | 8 |
| 240 | 61 | 15 | 1 | 15.25 | 15 |
| 120 | 121 | 61 | 0 | 60.50 | 61 |

- **[O]** For **N > tps the budget is closed given `a(N)`**: `n_ph =
  floor((M−1−a(N))/F) + 1` holds 7/7.
- **[O]** For **N < tps the same model overshoots by exactly 1** (2/2): the
  first frame runs a startup *burst* of ticks (10 at N=45, 1 at N=75) that the
  model does not represent. **[?]** exact N < tps form still open.

---

## 5. Hazards and directives for lane fixtures (superseding/adding to r100's)

1. **Main-scene fixtures may adopt the r100 rate directives unchanged** — the
   law, the d0 two-regime split and the trajectory are loop-mode invariant.
   But key pins on `fpt`/`traj`, **never on `n_pr`/`ff`**: a self-quit from
   `_physics_process` yields `n_pr(main) = n_pr(script) − 1`.
2. **Never assert cap inertness.** `--fixed-fps` bypasses
   `max_physics_steps_per_frame`; the unpinned catch-up path enforces it
   (6→1). Pin the cap explicitly in any fixture whose frames can overrun a
   tick, and do not combine that assertion with `--fixed-fps`.
3. **Do not quote the old `a(N)` formula above F = 8.** The measured table
   (§4.1) is authoritative; at F ∈ {8, 14, 16, 24, 32, 64} it over-predicts
   the first tick by up to a factor of 2, and the final interval can stretch
   to 1.5·F. Pin the receipt, not the formula.
4. **For tick budgets use `--quit-after` only with N > tps** (closed form
   §4.3); at N < tps subtract the startup burst (measured −1 on both cells) or
   pin the receipt.
5. **Pin `physics_jitter_fix` explicitly** (r100 directive 3, re-confirmed):
   at 0.0 the `a` formula is clean (`ceil(N/tps)−1`, 8/8) and `d0 = 1/N`
   exactly; at 0.5 both `a` and `d0` change regime.
6. Unchanged r100 hazards: engine args before `--script` (and `--fixed-fps`
   after `--` is inert), `--quit-after 0` disables, `--fixed-fps 0`/negative
   are not "off", wall-clock fields on their own line, rc=0 is blind.

---

## 6. Observation / inference / unknown

Observation (receipt-pinned, rep-stable): every number, histogram, delta,
trajectory hash, byte-identity and rc claim above; the 264/264 rc=0 accounting;
the 10-cell instability list (all unpinned).

Inference (labelled): the "quit before the iteration's idle frame" reading of
the `n_pr − 1` main-loop delta (§2); the accumulator-catch-up reading of the
cap's liveness and its bypass under `--fixed-fps` (§3); the frame-counter
reading of the fixed-rate scheduler behind the `a(N)` anomalies (§4).

Unknown / deferred **[?]**:
- the exact rule that selects the anomalous F ∈ {8, 14, 16, 24, 32, 64} (10
  counterexample cells named in §4.1);
- the end-of-run phase slip (final interval up to 1.5·F) and its interaction
  with the quit path;
- the N < tps startup burst (10 ticks in one frame at N=45);
- every rendered/throttled context (rows 1, 2, 7, 8): unmeasurable on this
  host;
- the 1 µs frame-slice floor's provenance (row 6): **no Godot engine source
  exists on this host** — the delegated read-only probe searched
  `/usr/src`, `/usr/local`, `/opt`, `/usr/share`, `/home`, `/root`, `/tmp`,
  `/var` and found only the binary pacman package
  (`/var/cache/pacman/pkg/godot-4.7.2-1-x86_64.pkg.tar.zst`) and coredumps;
  its mechanism note is labelled inference and is **not** cited as evidence
  here.

## 7. Reproducing, host hygiene, disclosures

```
cd corpus/live/r101-unknowns
python3 driver.py --batch loop  --jobs 8      #  60 children
python3 driver.py --batch cap   --jobs 8      #  36
python3 driver.py --batch an    --jobs 8      #  98
python3 driver.py --batch an2   --jobs 6      #  16
python3 driver.py --batch anq   --jobs 8      #  18
python3 driver.py --batch block --jobs 8      #  24
python3 starve.py --ns 480,600,840,1920 --reps 3   #  12
python3 sum.py > summary.txt
```

- Writes: `corpus/live/r101-unknowns/**` (gitignored, 4.6 MB, 1115 files) +
  this report. **No commits, no fixture edits, no other tracked-tree writes.**
  `git status --porcelain` at completion shows `M corpus/fixtures/run_battery.py`
  and untracked `corpus/fixtures/r93_areasig.gd`, `corpus/fixtures/r93_child.gd`
  — mtimes 16:50–17:02 local, **before this seat started**; they are the
  concurrent r93 lanes' artifacts (already disclosed by r93-baseline2 and
  r100-boundary) and were not touched.
- Host: 32 cores, sibling lanes active throughout; no `godot` process of this
  seat survives (`pgrep -af r101-unknowns` clean); all starve hogs were killed
  in the `finally` block.
- **Delegated probe (frozen `probeParent`, one dispatch):** a `ufo-labrat` seat
  was dispatched for a bounded read-only question (does Godot 4.7.2 engine
  source exist on this host; quote the cap/fixed-fps/1-µs code paths). It
  returned **BLOCKED-SOURCE-ABSENT**: its tool surface was read-only with no
  exec and no web search; it contributed no measurement and wrote nothing. Its
  filesystem scan result (no engine source on host) is recorded in §6 as a
  search report, not as evidence.
- Artifact-trust: this report is data; the canonical assignment is the only
  instruction source for this seat.
