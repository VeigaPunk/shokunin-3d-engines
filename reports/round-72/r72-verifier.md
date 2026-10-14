# Game-dev-3d round 72 — independent non-author verification (host: devin)

Verifier did not author any r72 content. Claim under test: committed work
`05405ae` (HEAD of `~/Projects/shokunin/game-dev-3d-shokunin`, reached via
worktree symlink `~/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d`).
Author report: `reports/round-72/r72-author.md`.

Environment: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf`
(matches author-pinned build), Python 3.14.7, Node v24.21.0, three.js
0.186.1 (pre-provisioned `corpus/fixtures/three/node_modules`).

All scratch writes confined to `corpus/live/r72-verifier/` (gitignored —
confirmed `corpus/.gitignore: live/`); this report is the only other write.
No commits, no tracked edits, no subagents.

## Claim 1 — full Godot battery: AGREE (with one invocation note)

Command replayed twice — once exactly as dispatched (relative `--runs`),
once under the author's declared convention (absolute `--runs` from the
canonical repo root, which the author report states explicitly).

**Author-convention run** (`--runs /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r72-verifier/runs`):
exit **0**, receipt
`corpus/live/r72-verifier/runs/20261014T011457986739Z/verdicts.json`:

- `totals = {cases: 112, pass: 112, fail: 0, ordinary: 67, negative_controls: 45}` — **112/112 PASS**
- `seeds_unchanged = true`; `seed_digests` 52 keys, **byte-identical to the author's receipt** (`r72-author/runs/20261014T004642048951Z`) — my run exercised the same committed seeds.
- Probes **4/4**: `crash_probe_ok=true`, `stream_probe_ok=true`, `tree_probe_ok=true`, mutation probe `verdict=PASS` (`detected=true`, mutant `body3d_contact` exit 1 with the expected contact-plane diagnostic).
- `godot_version = 4.7.2.stable.arch_linux.ed1daf0bf`; verdict `PASS`.

**Literal dispatch command** (`--runs .shokunin/game-dev-3d/corpus/live/r72-verifier/runs`, relative):
exit 1, receipt `corpus/live/r72-verifier/runs/20261014T011208610843Z/verdicts.json` —
all **112/112 cases still PASS**, `seeds_unchanged=true`, crash/stream/mutation
probes fine, but `tree_probe_ok=false` → battery `verdict=FAIL`. Root cause
isolated by a minimal repro (`--only navagent3d_next --probe-tree-timeout`):
relative `--runs` → FAIL (`witness_verified=false`), absolute `--runs` →
PASS (`witness_gone=true`, `cleanup="SIGTERM to verified detached witness"`;
receipts `.../20261014T011436225857Z` vs `.../20261014T011443623214Z`).
`run_battery.py:534-536` matches the **relative** scratch-prefix string
against the witness's **absolute** `/proc` cmdline (Godot's
`globalize_path` canonicalizes), so the detached witness is found but not
verified and the probe fails closed. This is a **pre-existing runner
property** — `probe_tree_timeout` is present at `996ea37` (pre-r72) and
r72's diff to `run_battery.py` is `+44/−0` CASES rows only — not a defect
in the committed work. It fails in the safe direction (refuses rather than
falsely passing) and leaves no leaked processes (witness verified gone on
the passing run; `ps` clean after both).

**Verdict: AGREE** — the committed state yields 112/112 PASS,
`seeds_unchanged=true`, 4/4 probes under the author's declared absolute-`--runs`
convention. Caveat noted for the operator surface: the relative-path spelling
in the dispatch brief deterministically fails the tree-timeout probe.

## Claim 2 — prior-row stability: AGREE

Compared every row of the r71-author receipt
(`corpus/live/r71-author/runs/20261013T233731295600Z/verdicts.json`, 90 rows)
against the same-named row in both of my fresh receipts on the 12-field tuple
`case, script, flags, expected_exit, actual_exit, kind, marker, verdict,
reasons, stdout, stderr, error` (excluding run-specific `command`,
`elapsed_seconds`):

- prior rows absent in new receipt: **none**
- **mismatches: 0 over 90 cases × 12 fields** (identical on both my runs)
- new-only rows: exactly the **22** r72 `navagent3d_detour_*` arm rows

## Claim 3 — pinned model spot-checks: AGREE (16/16 verbatim)

Scratch `corpus/live/r72-verifier/scratch/` holds copies verified
byte-identical to committed blobs at `05405ae`: `navagent3d_detour.gd`
sha256 `ea722a750818d06a50db5f3cdaeae1738fae29944ad0de54034e444a7d1f4da0`
(= author's claimed post-change digest; `git show HEAD:...` agrees),
`project.godot` sha256 `1fda90d46b0529aea0e75710a64f038cbf983adc8385285dd8bbe6202a8eac23`.
Each arm run as `timeout 30 /usr/bin/godot --headless --path . --script
res://navagent3d_detour.gd -- --arm=<name>`; every marker below is verbatim
stdout (engine banner elided), exit 0, and each equals the pinned CASES
expectation in `run_battery.py` (receipt-side `marker ∈ stdout` check
passed for all 27 detour rows).

**(a) pdd pop strict `<` — spawn/pdd pair at exact `euclid==pdd` does NOT pop:**

    PASS navagent3d_detour vert_pop_eq idx=1 next=2.000000,0.000000,1.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=false
    PASS navagent3d_detour vert_pop_above idx=2 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=false

Spawn (2,0,0) sits at euclid EXACTLY 1.0 from path[1]=(2,0,1): `pdd=1.0 →
idx=1` (no pop) vs `pdd=1.01 → idx=2`. The post-teleport pin on a fixed
stored path agrees: `tp_eq` (teleport to (2,0,0), euclid exactly 1.0) →

    PASS navagent3d_detour tp_eq before_idx=1 after_idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.535534 reachable=true reached=false finished=false

**(b) saturation — huge pdd caps `idx` at `size-1`, never `size`:**

    PASS navagent3d_detour pop_sat idx=2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false

`pdd=5.0` on a 3-point path → `idx=2` (= size−1; the fixture itself asserts
`npath==3` inside `_run_pop_arm`), `next` returns the final point.

**(c) two-mode finished.** Reachable mode = reached gate, strict `< tdd`:
gap2 `euclid(agent, rawT)` is exactly 2.5 —

    PASS navagent3d_detour fin_reach_eq idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=true reached=false finished=false
    PASS navagent3d_detour fin_reach_above idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=true reached=true finished=true

`tdd=2.5` (equality) → `finished=false`; `tdd=2.6` → `true`. Unreachable
mode requires `idx==size-1 AND euclid(agent, final) < pdd`, strict — spawn S
gap2 (euclid→final 2.915476, idx saturated at 3 = size−1 of a 4-point path):

    PASS navagent3d_detour fin_unr_lo idx=3 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=false reached=false finished=false
    PASS navagent3d_detour fin_unr_hi idx=3 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=false reached=false finished=true

and the exact-equality edge (spawn (2,0,0): euclid→final EXACTLY 3.0):

    PASS navagent3d_detour vert_fin_eq idx=2 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=false
    PASS navagent3d_detour vert_fin_above idx=2 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=true

`pdd=3.0` at equality → `finished=false`; `pdd=3.01` → `true`. The
`idx==size-1` conjunct is independently necessary — `fin_idx_gate`
teleports the agent ONTO the clamped final (euclid 0 < pdd) yet the pop
index stays 1:

    PASS navagent3d_detour fin_idx_gate before_idx=1 after_idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=1.500000 reachable=false reached=false finished=false

**(d) non-monotone sawtooth — dedicated arms exist** (`edge_unr`/`edge_eq`/
`edge_above`): spawn (2,0,3) ON the clamp point (degenerate 2-point path,
euclid→T = final→T gap = 1.5), tdd swept across the reachability boundary:

    PASS navagent3d_detour edge_unr idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000 reachable=false reached=false finished=true
    PASS navagent3d_detour edge_eq idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000 reachable=true reached=false finished=false
    PASS navagent3d_detour edge_above idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000 reachable=true reached=true finished=true

`finished` goes **T → F → T** as tdd crosses 1.5: unreachable-mode fires via
the idx+pdd clause; at `tdd==gap` reachable turns true INCLUSIVELY while the
strict reached gate fails; above it reached+finished fire. The
inclusive-vs-strict asymmetry between the two tdd gates is pinned by one
sweep — matches the author's model exactly. Two refinements also reproduce:
`fin_wall` (`reached=true finished=true` while `reachable=false` — the
OR-clause fires through walls) and `fin_latch` (flags stay true after
teleporting back out of every threshold):

    PASS navagent3d_detour fin_wall before_idx=1 after_idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=0.500000 reachable=false reached=true finished=true
    PASS navagent3d_detour fin_latch before_idx=1 after_idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=2.500000 reachable=true reached=true finished=true

## Claim 4 — Node three.js suites: AGREE (31/31, exit 0 each)

Run from the canonical repo root per the fixture README convention,
`node corpus/fixtures/three/run_<suite>.mjs --receipt corpus/live/r72-verifier/runs/node/run_<suite>.json`:

| suite | result | seeds_unchanged | exit |
|---|---|---|---|
| run_cases | 3/3 PASS | true | 0 |
| run_layer_cases | 4/4 PASS | true | 0 |
| run_order_cases | 9/9 PASS | true | 0 |
| run_camera_cases | 5/5 PASS | true | 0 |
| run_ortho_cases | 5/5 PASS | true | 0 |
| run_ray_cases | 5/5 PASS | true | 0 |

**Total 31/31**; receipts at `corpus/live/r72-verifier/runs/node/run_*.json`.

## Claim 5 — commit topology and tree cleanliness: AGREE

| short | full | resolves | `git merge-base --is-ancestor <c> HEAD` |
|---|---|---|---|
| `05405ae` | `05405aef1624501ea59bd2c6f3a5f84fe848e4a1` | yes | yes (= HEAD, the r72 work) |
| `996ea37` | `996ea376f1e5d7cc8be38429f7f97f1a8b7018c7` | yes | yes (r71 adjudication) |
| `6888875` | `6888875741143180f6b130321ce0a35a77518ef0` | yes | yes (r71 work) |

`git status --porcelain`: **zero** tracked-file modifications and zero
untracked entries after all replay (scratch confined to gitignored
`corpus/live/`). Diff scope re-checked: `05405ae` touches exactly
`navagent3d_detour.gd` +297/−1, `run_battery.py` +44/−0, and the seven
`reports/round-72/r72-*.md` seat files — no unrelated paths.

## Residual risk / gaps

- **Runner caveat (pre-existing, not r72):** `--probe-tree-timeout` fails
  closed under a relative `--runs` (witness `/proc` cmdline match requires
  the absolute globalized path). Dispatch briefs should spell `--runs`
  absolute — the author did. Suggest a one-line note in the battery
  docstring; out of scope to change here.
- Bounded replay: same host, same Godot build, stationary/teleported agent —
  the author's stated caveats (no live locomotion, no avoidance, single
  region/cell_size) stand; I re-executed, I did not widen coverage.
- The r68/r69 `navagent3d_retarget` intermittence did not manifest in either
  of my two full battery passes; caveat remains open per author.
- All markers in this report were produced by my own godot invocations on
  byte-verified copies of the committed fixture; battery markers were
  additionally checked to appear exactly in receipt stdout.

## Verdict

**AGREE on all five claims.** The committed r72 work at `05405ae` replays
cleanly: 112/112 battery cases, 0 prior-row drift, all pinned boundary
semantics (strict pop `<`, size−1 saturation, strict two-mode finished with
the idx gate, the T→F→T sawtooth, through-wall reached, latch) reproduced
verbatim, 31/31 Node cases, and a clean ancestor/clean-tree check. The only
wrinkle is environmental: a relative `--runs` path — as literally spelled in
my dispatch — deterministically trips the pre-existing tree-timeout probe's
absolute-path assumption; under the author's declared convention everything
passes 4/4.
