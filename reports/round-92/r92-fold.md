# r92 fold — gate-approved corrections applied to `dd32c3c` + `27fba42`

Seat: **FOLD** (executor) for `game-dev-3d-shokunin` round 92. Base work
commit `dd32c3c` + `27fba42` (fold-a comment); this seat's edits are the five
tracked files listed below, all unstaged — **no commits**.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`--headless`, Python 3.14.7, 32-thread host. Load during this seat's runs was
the corpus's normal multi-seat condition; the loaded repetition additionally
carried 16 pinned `yes` hogs. **No `lsp` device is exposed to this seat's
toolset** (same recorded absence as r85–r92 lanes); all edits were hand edits
against verified output, so the hand-edit fallback applied and is recorded
here.

## Applied items

### C1 (critic F1) — timing arms re-anchored past a forced iteration boundary

`r92_child.gd` `on_tm_tick`/`c_tm`, arms `tps`/`tscale`/`edge`/`refuse`/`steps`:

- The mutation fires inside tick pf=5, but `Main::iteration()` reads the
  delivered step once per iteration — the write only reaches the **next**
  main-loop iteration's tick batch, and how many ticks share the old/new
  boundary batch is the scheduler's. The old `E pf=6..8` pin was a bet on
  that scheduler window (verifier run 1: `E pf=6 delta=0.016667` vs pinned
  `0.166667` on `tm_maxsteps` → 257/258).
- The child now waits for `tm_mutated`, crosses one `process_frame`
  (iteration boundary), then samples **three** physics ticks each sealed by
  an idle boundary — every sample is the settled step. Rows renamed
  `E0/E1/E2` (no pf stamp); `done` loses its pf stamp for the same reason.
- `r92_timing.gd` header law sentences rewritten: "take effect from the
  next main-loop iteration's tick batch"; transient explicitly declared
  scheduler-keyed and unpinned. Settled values unchanged:
  `0.033333`/`0.008333` (tps), `0.008333`/`0.033333`/`0.166667` (tscale),
  `0.000000`/`-0.016667` (edge), `e=1` refuse, `0.166667`/`0.016667` steps.

### C2 (critic F2) — `r92_animphys_iforder` pins predicates, not positions

`r92_child.gd` `c_iforder` rewritten: E/I rows now emit `ok=1` predicates —
E.x `== 0.05 * (pf - pf0)` and I.x `== E.x + 0.05 * dpf` where `dpf >= 1` is
the tick count of the idle-crossed iteration's batch (critic measured dpf up
to 3 under load). `srv`/`playing` predicates retained (dummy `srv=nil`;
gp/jolt `srv` mirrors position). Raw positions ride `# iforder` diagnostic
lines only — the exact-marker contract admits other stdout lines. `post`
row: `ok=1 playing=true`.

### C3 (critic F3) — `r92_animphys_idlemode` admits the starved mode

`r92_animphys.gd` `_env_idlen` widened to the real legal set: x ∈
[−0.0005, 3.0005] (the track's reach), y ∈ [1.8, 2.0005] (2.0000 advanced
**or** bounded free-fall starved, e.g. critic's x=0.0000 y=1.9240), z ≈ 0,
`playing=true`, backend lv/srv constants (srv now mirrors actual x,y rather
than pinning y=2.0000). Each rep classified `advanced`/`starved` for the
`# idlemode modes` diagnostic histogram; the marker pins only
`{reps=8,ok=8}` — `_xband` and the median bucket deleted (a bucket over a
scheduler-dependent sample was the bug).

### SP1–SP5 (simplifier) — dead code in `r92_child.gd`

- **SP-1** `cap_f`, `f_rows`, `Watcher._process`, `cap_f=true`, the `F_post`
  emit loop — all removed. Line-735 `await process_frame` **retained** per
  the simplifier's preserved-contract note (its removal would shift the
  pinned `post` row one tick earlier).
- **SP-2** dead `f4()` helper removed.
- **SP-3** `RB` subclass + write-only `ball.probe` removed; `ball` is now
  `RigidBody3D`.
- **SP-4** `PhaseReader.n_e` counter, its `e_rows` element 0, and both
  resets removed; `c_phase` readers re-indexed `[1]→[0]`, `[2]→[1]`.
- **SP-5** inert `anim_watch()` call in `c_iforder` + write-only `watcher`
  field removed; `anim_watch()` uses a local. The other three arms still
  arm a live watcher (`live_e`/`on_e` are receipt-live).

### Text corrections

- `r92-author.md`: `369 child cells per battery pass` → **123/pass**
  (369 = 3 × 123 across dev+run1+run2), per scribe F2 / reviewer F2 /
  critic F7.
- `run_battery.py` r92 comment block rewritten to state the new contract:
  settled timing pins, iforder predicates, `{reps=8,ok=8}`-only idlemode
  signature with `#` diagnostics.
- Fixture header comments (F4-adjacent wording, touched sections only):
  `r92_child.gd` contract comment now names the three scheduler-shaped
  windows; `r92_animphys.gd` documents manual-mode + idlemode distributions
  and the iforder phase predicate.

### `run_battery.py` marker splices

All seven touched rows re-pinned verbatim from fresh direct-arm output
(`corpus/live/r92-fold/mark_*.txt`, captured pre-battery): `r92_timing_tps`,
`_tscale`, `_edge`, `_refuse`, `_steps`, `r92_animphys_iforder`,
`_idlemode`. Edge/refuse markers changed only by the shared E-row format
(E0/E1/E2, unpinned pf) — their values were never fragile (critic F4).
The 258-row table round-trips via `ast.literal_eval`: all 7 spliced markers
byte-equal their capture files; all 251 other rows untouched.

## Evidence

| check | result |
|---|---|
| `godot --headless --path corpus/fixtures --check-only --script` ×3 modified `.gd` | rc=0 each, no diagnostics |
| `ast.parse(run_battery.py)` | clean |
| Full battery `timeout 1500 python3 corpus/fixtures/run_battery.py --runs corpus/live/r92-fold/runs1` | **258/258 PASS** (`verdicts.json` `cases=258 pass=258 fail=0`, ordinary=211, negative_controls=47); `bpy_rbw3d_render` held its pin this run |
| Loaded repetition: 16 `yes` hogs + `--only r92_timing_tps,r92_timing_tscale,r92_timing_steps,r92_animphys_iforder,r92_animphys_idlemode` → `corpus/live/r92-fold/runs_loaded` | **5/5 PASS** — all three previously-failing classes green under contention; hogs killed (`pgrep -c yes` → 0) |
| Loaded timing samples | every E0/E1/E2 settled delta on-pin across all 3 backends (e.g. `tm_tps30 0.033333` ×3, `tm_maxsteps 0.166667` ×3) — no transient leaked into a pinned row |
| Loaded iforder raw (`#` lines) | `dpf=1` on all 12 I-rows this run; predicates `ok=1` regardless — the pin no longer breaks when dpf>1 |
| Loaded idlemode | all 24 reps drew `advanced` (x≈0.23–0.29); mode histogram on `#` line; envelope admits `starved` when the scheduler produces it — the marker is mode-independent |

Receipts: `corpus/live/r92-fold/{runs1,runs_loaded}/<ts>/verdicts.json`,
`{runs1,loaded}_console.log`, `mark_*.txt` (7 marker captures).

## Before / after (the three failing classes)

| arm | before (observed under load) | after |
|---|---|---|
| timing `steps` | `E pf=6 delta=0.016667` vs pinned `0.166667` → FAIL (verifier run 1) | `E0/E1/E2 delta=0.166667` sampled past forced boundary → PASS ×2 runs |
| `iforder` | I-row absolute `x` legal under dpf≥1 batching → marker miss | `ok=1` predicate `I.x == E.x + 0.05·dpf` → PASS under load |
| `idlemode` | starved rep `x=0.0000 y=1.9240` outside `xband` envelope → FAIL-able | `x∈[0,3] y∈[1.8,2.0005]` admits both legal modes; `{reps=8,ok=8}` → PASS |

## Declined / out of scope

- **Duplicated child-spawn machinery across the three parent fixtures**
  (reviewer/simplifier note): not round-local cleanup — a corpus-wide
  convention decision; left for a dedicated round.
- **Line-735 `await process_frame`**: retained per SP-1's preserved-contract
  note — removing it shifts the pinned `post` row.
- **`manual` arm marker** and all non-r92 CASES rows: untouched.
- **Reclassifying idlemode as a distribution cell** (critic's alternative):
  the widened-envelope + count-only signature was chosen instead — it keeps
  the arm an ordinary exact-marker row while making the signature
  mode-independent.

## Remaining risks

- The starved idlemode realization did not occur in this seat's loaded run
  (all 24 reps advanced) — its admission is proven by envelope logic +
  critic's field observation, not by a fresh starved sample here.
- `bpy_rbw3d_render` remains the documented stochastic cell (held this run).
- 16 hogs on a 32-thread shared host is a moderate load; heavier contention
  could still produce dpf>3 batches — the predicates are count-independent
  by construction, so this affects diagnostics, not the signature.

## Blockers

None.
