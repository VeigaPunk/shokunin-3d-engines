# r96 author — the Jolt fixed-fps/determinism lattice

Seat: GAME-DEV-3D r96 AUTHOR. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r96-author.md`.
Scout evidence: `reports/round-96/r96-scout.md` + `corpus/live/r96-scout/`; boundary
evidence: `reports/round-96/r96-boundary.md` + `corpus/live/r96-boundary/`. Only
boundary-surviving claims are authored; every refined claim is encoded in its
corrected form (the boundary CONFIRMED the §1–§6 receipt set on 74/74 replayed
cells, and refined the dt-conditional penetration/sleep/e_vel readings, the
`--fixed-fps` warning, `--time-scale`, and the `Dummy` backend).

Landed one parent fixture, eight byte-identical probe copies, and **12 CASES rows**:

- `corpus/fixtures/r96_joltdet.gd` — 12 arms (`--arm=<name>`), spawning one
  fresh Godot child per cell (**160 children per battery pass**) into
  per-cell child projects (pid-namespaced so a concurrent rep sweep cannot
  collide), each child bounded `timeout -s KILL`, and folding the child's
  **normalized** receipt into a digest cell
  `<cell>{rc=0,sha=<16 hex>,<field>=<value>,...}`. Arms: `joint`, `contact`,
  `restkin`, `tps`, `solver`, `mech`, `tscale`, `ffps`, `dummy`, `thread`,
  `knobs`, `nc` (123 cells).
- `corpus/fixtures/r96_probe_{iters,pen,warm,damp,rest,kin,srvjoint,settings}.gd`
  — **byte-identical copies of the r96-scout probes** (sha256 below), copied
  into each child project under their ORIGINAL `res://` names, so a child
  receipt reproduces the scout's receipt byte-for-byte (the boundary §7.1
  rename hazard is avoided by construction).

| probe | sha256 (fixture copy == scout source) |
|---|---|
| iters | `06d80e50ac6fadc2ef73e859ad3d60079d9d8312a15b987bd9887e5200692e15` |
| pen | `762e11b47552aa41d633b957f8de16acd7846165a1beb540af4fd0ef38658857` |
| warm | `4228f7aee4d68cb5138612992e40ddab3c016463b7660835c9098d93184bc47a` |
| damp | `d6ce9067499c1c5f3b5156dab7adeb39bbf2b025b2d7d2e8359dbc4622e32568` |
| rest | `1d7bd6e7e46139162fac418f0919f482bcf8df33ffbd9917272bffbdd5fba981` |
| kin | `ddc50d993d0ca6e56903e1e122c0ac7b15d68dbf61444593fd4c7dd021e375c5` |
| srvjoint | `db3447f6a94c5094a97441893173ce1c5d9d1afe4836634ad5820e35f310ee82` |
| settings | `e190adff97ac1d80612f8b6e932959cc86b0b1f9687f397f8f7bb6876316556e` |

Parent fixture sha256: `8a77ecb4c29ab8b69b7e95efb4f7c9f54bb6edcff333153ba77167589719cf33`.

`run_battery.py`: **insertion-only** — 12 tuples appended after
`r95_bullet_neg_shm_rt`; `git diff` = +30 lines, zero existing bytes touched.

## The three mandated encodings

**1. The Jolt job-system warning is an expected-error class (allowlist exact
text, variable position tolerant).** The scanner drops a line pair only when
the first line equals the full allowlisted text and the next equals its `at:
CreateJob (modules/jolt_physics/spaces/jolt_job_system.cpp:123)` line — at any
position in the stream — and drops nothing else. Authoring census (6-rep
sweep, 6 Jolt `--fixed-fps 60` receipts per parent run): **13/36 receipts
carried the warning** (2,2,2,2,2,3 per parent run) at line positions 16–19;
every normalized receipt is byte-identical to its no-flag twin. Because the
warning is *optional*, its count/positions are `#` diagnostics, never pinned;
what the row pins is `norm_eq=1`, `ref_eq=1` (normalized `--fixed-fps` ==
no-flag reference), `raw_eq=1` for GP (no warning, raw byte-identical), and a
**scanner self-gate**: the exact 2-line text is dropped at the head *and* in
the middle of a stream, while a near-miss (first line without its `at:` line)
is NOT dropped (`allow=1,reject=1`).

**2. `--time-scale` is a tps law.** `--time-scale 0.5` at 60 tps IS the
120-tps project and `--time-scale 2.0` IS the 30-tps project — byte-identical
(normalized) receipts, for a joint-position witness (`iters pin`) and a
dt-scaled damping witness (`damp lin10`), on **both** backends: six `{eq=1}`
cells with both shas pinned. The boundary measured this without the flag; here
both sides run under `--fixed-fps 60` (the round's deterministic arm), so the
`--time-scale` × `--fixed-fps` interaction on the boundary's not-tested list is
now measured for these cells and does not perturb the law.

**3. Dummy vacuity preconditions.** Five cells run **Dummy + GP + Jolt in the
same cell** and pin the three readings side by side:
`it_pin{d=-1.0,gp=0.0,jolt=0.0}` (null transform), `pen_overlap{d=-0.3,
gp=-0.010001,jolt=-0.02}` (no depenetration), `warm_rest{d=0.600000024,
gp=0.290008307,jolt=0.300000012}` (no fall), `damp_lin10{d=10.0,gp=0.0,
jolt=0.0}` (no damping), `kin_kcontact{d=0,gp=1,jolt=0}` (no kinematic contact
reporting). The sixth cell pins the reuse hazard as a **bounded precondition**:
`damp.gd sleep1` under Dummy never reaches its quit —
`sleep1{dummy_rc=137,hang=1,nodsum=1,d0=1,gp_slept=126,jolt_slept=144}` — the
child is bounded at 2 s, its 27 MB error-spam log is read through a 128 KiB cap
and removed after the scan, and the same probe on GP/Jolt still yields the
sleep ticks.

## Cells armed

| # | Row (CASES) | Arm | Cells / children | Boundary-surviving law encoded |
|---|---|---|---|---|
| 1 | `r96_joltdet_joint` | `joint` | 12 / 12 | §1 joint semantics: Jolt `position_steps` owns positional recovery (`p0` leaves `last_gap=0.3` forever, `p1` reaches `0.00001`, default reaches `0.0` with `lv≡0`); GP's pin is a velocity-level impulse (spike `5.399999` at t=2, gap ratio 0.7/tick) and `solver_iterations` is inert for it; chain stretch 0.000163 (GP) vs 0.000031 (Jolt); hinge: GP never reaches the limit (`max_over=-0.050499`), Jolt overshoots `+0.031202` then position-solves back to `0.000004`; the node-body joint trap (GP `space_a=RID(0)`, Jolt binds). |
| 2 | `r96_joltdet_contact` | `contact` | 16 / 16 | §2/§3/§4: depenetration setpoint vs band (`sep_end=-0.010001` GP / `-0.02` Jolt), contact onset (`first_mod_tick=9, gap=-0.005` GP vs `8, gap=0.0` Jolt), steady support impulse `m·g·dt=0.163333` on both, the one-tick break (GP `y_end=0.289999157` re-converges; Jolt rests at `0.297277778`), damping ratio `0.833333302` identical on both backends, COMBINE/REPLACE (`lin0repl lv_end=10.0` vs `lin0comb lv_end=7.175283909`), sleep tick split (GP 126 keeping `lv=0.061173905`, Jolt 144 zeroing it). |
| 3 | `r96_joltdet_restkin` | `restkin` | 15 / 15 | §5/§6: the combine rule is `clamp(A+B,0,1)` — `sum` → `e_vel=0.7`, `mid` → `e_vel=1.0` (max would read 0.4/0.8); Jolt's `bounce_velocity_threshold=1.0` kills the 0.65 m/s bounce (`rest_low@jolt e_vel=0.0` vs GP `0.9`) and the 0.5 m/s head-on pair; the kinematic/static split is in *reporting* (`kin_kcontact@jolt cc_end=0,kin_first_cc=-1`; `@jolt_kinct` → `1,2`); `constant_linear_velocity` is GP-only (`y_end=0.307486, lv=-0.316667` vs Jolt `0.283333, lv=0.0`); a teleported kinematic platform ejects the resting ball on both backends (`y_end≈11.91`, `lv_end≈-3.77`). |
| 4 | `r96_joltdet_tps` | `tps` | 26 / 26 | §4 generalization: damping ratio `1−d·dt` with the actual dt (`0.666666603`/`0.833333302`/`0.916666698`), the `d·dt≥1` clamp (`lin100` → `0.0` at 30 tps, `0.166666627` at 120), the support impulse `m·g·dt` (`0.326667`/`0.163333`/`0.081667`), GP's `1/dt` spike (`2.7`/`10.799998`) with the dt-invariant 0.7/tick gap ratio, Jolt's `lv≡0` with 0.64/tick, the tps-invariant combine rule (`e_vel=0.7`/`1.0` at every rate), GP's dt-conditional setpoint (`-0.010004` at 30 tps vs `-0.010001` at 120) with Jolt's band (`-0.02` at every rate), and sleep as wall-clock (GP `64`/`126`/`−1`, Jolt `73`/`144`/`−1`; both end at `lv_end=0.094568834` at 120 tps). |
| 5 | `r96_joltdet_solver` | `solver` | 17 / 17 | §1 knob lattice: `solver_iterations` 1 → chain `0.045513` (max 0.053731) and a collapsed tower (`last_y4=0.191492`, `last_xz4=0.719894`), 64 → `0.0` / standing (`1.759912`, `0.003035`); `velocity_steps` 1 → `0.00168` and tower `last_pen0=0.011403`, 60 → `0.0` / `0.000056`; `position_steps` 0/1/8 → chain `0.000162`/`0.000077`/`0.000007`; `p0` pin `last_gap=0.3`, hinge `max_over=0.048753`/`last_over=0.048753`; `p8` stack byte-identical to the default. |
| 6 | `r96_joltdet_mech` | `mech` | 7 / 7 | §3/§5 one-knob mechanisms: GP setpoint tracks `contact_max_allowed_penetration` (`-0.200001` at 0.2), `default_contact_bias` inert (`-0.010001`), Jolt band tracks `penetration_slop` (`-0.1`), Baumgarte sets the *rate* (`P t=2 sep=-0.28`, `sep_end=-0.020001`), `speculative_contact_distance=0` does not move the onset (`first_mod_tick=8, gap=0.0`), `contact_max_separation=0` does not move the GP approach onset (`9, -0.005`), `bounce_velocity_threshold=0` restores the bounce (`e_vel=0.9, v_out=0.588`). |
| 7 | `r96_joltdet_tscale` | `tscale` | 6 / 12 | the `--time-scale` tps law (encoding 2). |
| 8 | `r96_joltdet_ffps` | `ffps` | 3 / 10 | the warning expected-error class + normalized identity + scanner self-gate (encoding 1). |
| 9 | `r96_joltdet_dummy` | `dummy` | 6 / 18 | Dummy vacuity preconditions with live controls + the bounded hang (encoding 3). |
| 10 | `r96_joltdet_thread` | `thread` | 10 / 20 | `3d/run_on_separate_thread=true` is receipt-identical to the single-threaded baseline on both backends (`eq=1` in all 10 cells, self-contained: each cell runs both variants). |
| 11 | `r96_joltdet_knobs` | `knobs` | 4 / 3 | the `physics/` key surface is backend-independent: `props=67,keys=67` with an identical key-name hash on GP/Jolt/Dummy (`eq_gp_jolt=1,eq_gp_dummy=1`). |
| 12 | `r96_joltdet_nc` | `nc` | 1 / 4 | the nocache contact-identity class, **pose-only**: the `W t=` surface (impulse column stripped) is byte-identical across 4 concurrent reps (`pose_eq=1,pose_sha=298e8a9a00657651,y0=0.199833333,vmax=0.000093835`); the impulse readback is censused, never pinned. |

## Rep-stability contract

- **Authoring sweep**: 6 parent runs × 12 arms = **72 arm runs**, all `PASS`,
  **one distinct marker per arm** (byte-identical stdout across all 6 reps;
  the `#` diagnostic lines are the only per-run variation).
- **Receipt provenance**: the 160 child receipts left by the full battery run
  were cross-checked against the scout's/boundary's own receipts
  (`crosscheck.py`): **93/93 referenced cells byte-identical (normalized),
  0 differing, 0 missing** — the fixture re-derives the scout's receipts, it
  does not restate them (`corpus/live/r96-author/runs/crosscheck-run1.log`).
- **Child budget**: 160 children per battery pass, each a fresh Godot process
  under `timeout -s KILL` (14 s batch bound; the Dummy hang cell at 2 s).
  Battery-row wall times in full run 1: 1.15–7.75 s (slowest `ffps`), all far
  inside the 20 s per-case bound.
- **Warning census**: 13/36 fixed-fps Jolt receipts carried the allowlisted
  warning in the 6-rep sweep; the normalized sha never moved.
- **Nocache impulse class**: the all-zero readback appeared in 3/6 parent runs
  (39/324 ticks each) and not at all in the other 3 — the pose surface was
  stable in every run. The Jolt 5-cube tower (`warm_stack@jolt`) showed the
  same identity instability (1/3 reps in the first sweep), so its cell pins a
  pose-only sha (`psha`) while GP's keeps the full sha.
- **Not authored (documented non-pinnable)**: the `baumgarte` → rate formula
  (two-point curve only), the ~15 mm GP/Jolt rebound-apex gap, the Dummy
  `sleep1` probe bug as a physics claim, per-body signal ordering (r93's
  surface), and the threaded gate in general (only these 10 cells).
- Load context: the host ran at loadavg 53–73 throughout (sibling lanes); no
  arm marker moved under it.

## Battery

- Before: **304 cases** (245 ordinary + 59 negative controls) · After:
  **316 cases** (257 ordinary + 59 negative) = **+12 r96 rows**.
- r96-only pre-run on the final bytes: **12/12 PASS**
  (`corpus/live/r96-author/battery/20261016T001410168438Z/verdicts.json`).
- Full run 1: **315/316**, `seeds_unchanged=true`
  (`corpus/live/r96-author/battery/20261016T001444183940Z/verdicts.json`).
  The single fail is `navagent3d_retarget_fixed`
  (`before=1.754246` = the documented navagent one-tick load flake: the same
  `before=1.754246` signature that failed r94's run 1 and the r93 baseline
  under load). **All 12 r96 rows PASS.**
- Full run 2 on the same final bytes: **313/316**, `seeds_unchanged=true`
  (`corpus/live/r96-author/battery/20261016T002412448214Z/verdicts.json`),
  under a sibling lane's full battery on the shared host (loadavg ≈ 59). The
  three fails are all in pre-existing rows and all load-shaped:
  `navagent3d_retarget` (the documented one-tick flake, `before=1.754246`),
  `phys3d_joints_free_ops` (a documented 20 s knife-edge row: 15.2–20.0 s
  across ~50 recorded runs, timed out here at 20.03 s), and
  `phys3d_joints_chain3` (4.0–5.8 s in every other recorded run, including
  run 1 at 4.49 s; stalled to 20.03 s here). **All 12 r96 rows PASS.**
- Full run 3 on the same final bytes: **315/316**, `seeds_unchanged=true`
  (`corpus/live/r96-author/battery/20261016T003435704003Z/verdicts.json`),
  under two sibling lanes' full batteries. The single fail is
  `navagent3d_retarget` again — the same documented one-tick signature
  (`before=1.754246`). **All 12 r96 rows PASS.**
- Full run 4 on the same final bytes: **316/316 PASS — fully green**,
  `seeds_unchanged=true`
  (`corpus/live/r96-author/battery/20261016T004506429310Z/verdicts.json`).
- No r96 row ever reddened in any run (pre-run, full runs 1–4, and the
  72-run authoring sweep): the only failures across all four full runs are
  the pre-existing navagent one-tick flake and the pre-existing
  `phys3d_joints_*` 20 s knife-edge rows, all on rows this round did not
  touch.

## Corrections / disclosures vs scout+boundary

1. **The warning is an *optional* allowlisted class, not a pinned count** — it
   fired in 13/36 receipts, so the rows pin the exact text + position
   tolerance + normalized identity, and census the count in `#` diagnostics.
   The scanner self-gate (`reject=1`) proves the allowlist is not a wildcard.
2. **`--time-scale` is authored under `--fixed-fps`** — both sides of every
   equivalence run `--fixed-fps 60`; the boundary measured the law without the
   flag, so the interaction (on its not-tested list) is now measured for these
   cells and is inert.
3. **GP's penetration setpoint and Jolt's resting pose are dt-conditional** —
   authored as measured (`-0.010004` at 30 tps, `-0.010001` at 60/120;
   Jolt `0.29511106` at 30 tps vs `0.300000012` at 60/120 with `lv≡0`), never
   as universal constants.
4. **Sleep is wall-clock** — authored as the three-rate table (GP
   64/126/never, Jolt 73/144/never), with `slept_at=-1` meaning "not inside
   the 200-tick window", not "never sleeps".
5. **`e_vel=0.9` is a 60-tps sampling of a tick-sampled ratio** — the rows pin
   the combine-rule discriminators (`sum`→0.7, `mid`→1.0), which are
   tps-invariant, and the per-rate `v_out`/`apex` values as measured.
6. **The nocache cell is pose-only** — the boundary's batch-shape framing is
   refined: the all-zero impulse readback also fires inside a small
   `--fixed-fps` batch (3/6 runs here), so the cell pins the pose surface and
   censuses the impulse class.
7. **The Jolt 5-cube tower joins the same class** — its contact-0 impulse
   readback flipped 1/3 reps while `cc/y0/vmax` stayed byte-identical; the
   cell pins `psha`.
8. **Dummy vacuity is authored with live controls in-cell** — each vacuity
   cell carries the Dummy, GP and Jolt readings side by side, so a Dummy-only
   degenerate value can never be mistaken for a physics law.
9. **The Dummy `sleep1` hang is a precondition, not a claim** — pinned as
   `rc=137` + no `DSUM` + the `D0` header, with the error spam capped and the
   log removed; it remains a probe bug (boundary §6.4), reported here as a
   reuse hazard.
10. **No Godot-side claim was widened beyond the r96 cells** — the fixture
    drives only the eight scout probes on the scout/boundary project bakes.

## Commands (repro)

    # one arm the way the battery runs it (inside a scratch copy of the seeds)
    godot --headless --path <scratch> --script res://r96_joltdet.gd -- --arm=ffps
    # a single child directly (the scout's own probe, its own res:// name)
    godot --headless --fixed-fps 60 --path <childproj> --script res://iters.gd -- pin
    # rep sweep (6 reps x 12 arms) and the scout/boundary cross-check
    python3 corpus/live/r96-author/armsweep.py <scratch> <out> 6
    python3 corpus/live/r96-author/crosscheck.py <battery-run>/scratch
    # battery (full)
    python3 corpus/fixtures/run_battery.py --runs corpus/live/r96-author/battery

## Receipts pointer

`corpus/live/r96-author/` (gitignored scratch): `driver.py`, `armsweep.py`,
`crosscheck.py`, `RECEIPTS.md`, `manifest.sha256`, `ftest/` (the scratch copy
the sweep ran against), `runs/` (raw cell receipts, `sweep1/`, `sweep2/` =
6 reps x 12 arms, `crosscheck-run1.log`), `battery/` (the r96-only pre-run +
four full battery run dirs), `battery-run{1,2,3,4}.log`. Provenance: this lane
wrote only `corpus/fixtures/r96_joltdet.gd`, the eight
`corpus/fixtures/r96_probe_*.gd` copies, the 12-row insertion in
`corpus/fixtures/run_battery.py`, this report and its scratch tree; it did not
touch any other round's fixtures or receipts.

No commit made, per instruction.
