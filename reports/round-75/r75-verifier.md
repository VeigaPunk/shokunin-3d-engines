# Game-dev-3d round 75 — verifier (non-author, committed-tree re-verification)

Named NON-AUTHOR verifier. Leaf worker: no subagent dispatch, no git
commit/push/merge/rebase/stash/checkout. Verified **committed HEAD `cefc821`**
(=`6498973` + wording-only commit: header-comment correction in
`navagent3d_detour.gd`, `--runs` docstring in `run_battery.py`, lesson/author
report wording, plus `r75-reviewer.md`; **zero behavioral change** — diff
inspected, all hunks are comments/docstrings/report text).

A prior verifier instance died mid-run: its partial artifacts under
`corpus/live/r75-verifier/` were kept and extended — `battery-full.out`
truncated at case 105/156 (`mesh3d_indexed_reversed`), `node/` empty. Fresh
evidence below supersedes the partial log.

Host: `/usr/bin/godot` = `4.7.2.stable.arch_linux.ed1daf0bf` (same pin as
author/reviewer), Python 3.14.7, Node v24.21.0, three.js 0.186.1.
No `lsp` device bound on this dispatch; caller/definition checks used the
documented text-grep + direct-read fallback (fixture is a single GDScript
file; semantics verified empirically, not by grep).

## Fresh evidence (all on committed HEAD)

- **Full battery, all four probes, absolute `--runs`**, exit 0:
  `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs
  /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/r75-verifier/runs
  --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing`
  → `corpus/live/r75-verifier/runs/20261014T093010381467Z/verdicts.json`:
  `verdict=PASS`, `totals={cases:156 pass:156 fail:0 ordinary:111
  negative_controls:45}`, `seeds_unchanged=true`,
  `crash_probe_ok/stream_probe_ok/tree_probe_ok=true`, mutant probe
  `detected=true`; tree-timeout receipt `witness_verified=true`,
  `witness_gone=true`, `cleanup_exit=-9`. Log: `battery-full2.out`.
- **Cross-seat receipt compare:** my 156 rows vs r75-author
  `runs/20261014T051912324357Z` — **0 mismatches over 156 cases × 12 fields**
  (case/script/flags/expected_exit/actual_exit/kind/marker/verdict/reasons/
  stdout/stderr/error). Vs r74-author `runs/20261014T041431092173Z` (145-case
  receipt): **0 mismatches over all 145 shared rows × 12 fields**.
- **Byte-exact committed-blob replays** (`scratch-head/` = `git show HEAD:`
  blobs; fixture sha256 `81a8c10a…` matches worktree): `mut_latch_zombie`,
  `mut_link_kill`, `mut_region_move`, `mut_layers_agent`, `mut_lazy` — each
  stdout PASS line byte-identical to the pinned CASES literal, stderr clean.
- **4 independent probe arms** (`scratch/r75v_probe.gd`, re-run on HEAD as
  `v2_*.stdout.txt`): byte-identical to the prior instance's captures.
- **Node suites:** `corpus/live/r75-verifier/node/run_*.json` — run_cases 3/3,
  run_layer_cases 4/4, run_order_cases 9/9, run_camera_cases 5/5,
  run_ortho_cases 5/5, run_ray_cases 5/5 = **31/31**, every suite
  `seeds_unchanged=true`, exit 0.
- **CASES additivity (mechanical):** `fc9915e` (r74) `run_battery.py` vs HEAD
  — **145 → 156 rows; 0 missing, 0 changed; 11 added**, all
  `navagent3d_detour_mut_*`, in order after `mv_bridge_walk`; relative order
  of all old rows preserved.

## Per-claim verdict

### Claim 1 — two-stage gate on server-side mutation — **AGREE**

"gated TWICE: setter→server-sync (~2-3 frames) then sync→first-forcing-call;
same-turn forcing calls can serve dead link data; post-sync lazy requery;
pure readers serve stale stored data." Verified directly:

- `sameturn_zombie` probe (v2, exit 0, byte-identical re-run): after walking
  `idx` onto the gate (`BANK idx=3 next=(2.5,0,5.5)`),
  `link_set_enabled(false)` same-turn reads back `link_get_enabled=true
  iter=1` (server truth stale) and the **same-turn forcing call serves the
  dead link's far endpoint**: `SAMETURN_FORCE idx=3 next=(2.5,0,5.5)` — the
  bounded zombie window, exactly as claimed (critic falsification absorbed).
- Stage timing: `F1` shows `en=false iter=2` yet still serves the stale hop;
  `F2` re-queries `[(2.5,0,3.4),(2.5,0,4.0)]` `finished=true` — consistent
  with "~2 physics frames for link toggles" (header L1124-1127; region
  transform ~3 not re-measured by me — boundary-sourced, consistent).
- Post-sync lazy requery + pure-reader staleness: every `mut_*` arm pins
  `peek_*` (stale stored array after the wait) before the forcing read;
  `mut_lazy` adds `wait=10 peek_only` — stored array/idx **byte-identical**
  with zero forcing calls, then step 2's forcing read re-queries. All PASS
  under byte-exact markers.
- `linkpeek_sync` probe: server-side `link_set_enabled` leaves the same-turn
  non-forcing peek stale (`path=[4 pts]`) — lazy, not eager.

### Claim 2 — latched zombie through transform AND delete — **AGREE**

`mut_latch_zombie` (committed-blob replay, exit 0, byte-exact): `steps=2
idxs=1,1 next=2.000000,0.000000,3.000000 … reachable=true reached=true
finished=true` — a `finished`-latched agent keeps serving the pre-mutation
waypoint through `region_transform +5x` (wait 10) AND `region_delete`.
Independent `latch_zombie` probe confirms with `map_get_regions=0` at the
DELETED read — served zombie on an empty map. Early-return mechanism matches
header L93-94/L160-163; unlatch-by-`target_position`-reassignment is the r74
`mv_unlatch` arm (still passing in the 145).

### Claim 3 — agent-side `navigation_layers` synchronous; all RID mutations lazy — **AGREE**

`agentlayers_sync` probe: `agent.navigation_layers = 2` → same-turn
non-forcing peek already reads `path=[]` with `peek_idx=1` readable-stale;
same-turn forcing read yields the empty-path tuple (`idx=0`, `next=agent
pos`, `final=(0,0,0)`, `reachable=false`). `mut_layers_agent` arm pins the
same at CASES level plus re-layer rematerialization. Every server-side RID
mutation (link enabled/layers, region layers/enabled/transform/
delete/recreate) is pinned lazy via `peek_*` keys — 13 mutate steps show
stale pre-mutation peeks, zero eager clears.

### Claim 4 — battery 156/156, probes, Node 31/31, additive wait≥1 — **AGREE**

- Battery **156/156 PASS** + `probes=4` all PASS (fresh run above); every row
  carries its exact marker in stdout; zero cases with stderr noise.
- "Four standalone probes": read as the battery's four probes — PASS; the 4
  independent scratch probes also PASS byte-identically (both senses hold).
- Node **31/31** PASS, receipts under `node/`.
- Additivity: 11 `mut_*` rows appended, all 145 prior rows untouched (above).
- `wait>=1` for sync-blind readback: 16 mutate steps total — 13 use the
  runner default `wait=5`, 3 explicit (`10/10/5`); **zero** `wait:0` mutate
  steps (`_run_steps` L1562 default verified). The `_final_srv_state`
  readback gate (L322-359) asserts every authored setter read back applied —
  a no-op mutation fails the arm rather than passing silently.

### Claim 5 — prior 145 r74 rows re-run, 0 mismatches — **AGREE**

CASES diff: 145 old rows byte-identical (name/script/flags/exit/marker), 0
missing/reordered. Empirically: my fresh run's 145 shared rows match the
r74-author receipt on all 12 record fields, **0 mismatches** — and the full
156 match the r75-author receipt on all 12 fields, 0 mismatches.

## Findings by severity

1. **Cosmetic — lesson citation still mis-groups `fw_mapedit` (post-`cefc821`
   residue).** `corpus/lessons/r74-navagent-moving-agent.md` now reads
   "EMPTY path + `final=(0,0,0)` on total severance (critic
   `fw_mapedit`/`fw_layermask`); clamped partial when a mainland stays
   on-mask" — but `fw_mapedit`'s receipt
   (`corpus/live/r74-critic/runs/fw_mapedit.stdout.txt`) shows the *clamped
   partial* outcome `[(5,0,0.5),(5,0,1.0)]` reachable=false, not EMPTY.
   `fw_mapedit` belongs under the second clause (or `fw_layermask`/
   `fw_al_mid` under the first). Wording only; no CASES/claim affected —
   r75 `mut_layers_region`/`mut_region_move` pin both outcomes correctly.
2. **Info — sync-blind readback gate bound (documented, unchanged).**
   A terminal `wait:0` mutate step cannot be authored (gate reads pre-sync
   truth); the committed header now documents `wait>=1`. Reviewer's
   repro stands; the machinery is intentionally unchanged and all 16
   authored mutate steps comply. Also: a `peek_only` *last* step would
   KeyError on `stf` (malformed-config class, simplifier-flagged).
3. **Info — unpinned sibling-measured regimes** (consistent, out of CASES
   scope): `map_set_active(false)` produces no iteration bump → unlatched
   agent serves stale path indefinitely (arguably the starkest zombie);
   map-wide eager dirty incl. same-value-write suppression; the multi-agent
   half of map-wide invalidation is structurally beyond the single-agent
   CASES surface; link-disable-under-latch unarmed (author-flagged open
   edge — same early-return path).

## Residual risk / verification gaps

- My battery ran on HEAD `cefc821`; the only fixture delta vs `6498973` is
  a header comment (verified diff) — results carry across both commits.
- Region-transform sync latency (~3 frames) and the multi-agent/map-wide
  dirty claims are sibling-measured; I re-derived the load-bearing parts
  (same-turn serve, sync boundary, lazy requery, latch zombie, sync clear)
  independently but did not re-bisect the 3-frame transform latency.
- `timeout_descendant.py` witness cleanup was verified via the probe receipt
  (`witness_gone=true`, SIGKILL after verified SIGTERM); no stray witness
  observed post-run.
- Prior verifier's `spot/` mut_* + mv_* captures predate `cefc821` by
  comment-only drift; my `scratch-head/` replays on committed blobs cover
  the load-bearing arms (5/11 sampled, incl. both falsification arms).
- No `lsp` device on this dispatch — literal-fallback checks only;
  all behavioral claims rest on executed receipts, not static proof.
- Compared receipts (`r74-author`, `r75-author`) are gitignored on-disk
  artifacts — carried-forward caveat, standard for this corpus.

**Summary: 5/5 claims AGREE.** The committed state matches every declared
clause including the bounded same-turn zombie and the latch-gated served
zombie. This report is a recommendation; admission belongs to the canonical
judge. Stopping here.
