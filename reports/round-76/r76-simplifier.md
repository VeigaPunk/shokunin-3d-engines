# Game-dev-3d round 76 — simplifier report (minimal-design critique, report-only)

Seat: simplifier. Judged the landed r76 diff — the setter→server-sync WINDOW
pinned as 7 tracked CASES arms on the detour fixture (`mut_win_link`,
`mut_win_region`, `mut_map_off`, `mut_map_cycle`, `mut_same_link`,
`mut_same_region`, `mut_same_agent`), new `map_active` mutate key + `fs` fold,
and the setup gate re-keyed to `fs["map_active"]`. Author landed mid-review;
diff observed growing +29 → +298 across polls, then stable 180s and committed
as `3ab09fd`. The snapshot critiqued is fixture sha256
`066a06d290c27c870a1e411dace586d961282099b7ac2b8a740da35cb39a19e4`, battery
`6faa83560ac2ba69cc7032c899134ef33e32a497e3c1941a921e9d61a9b5cba1` —
byte-identical to the committed blobs (verified via `git show HEAD:`).
All work inside own scope (`corpus/live/r76-simplifier/`, gitignored —
`git check-ignore` verified). Host devin, `/usr/bin/godot`
4.7.2.stable.arch_linux.ed1daf0bf, physics 60 tps. Repo reached via the
`.shokunin/game-dev-3d` symlink → `~/Projects/shokunin/game-dev-3d-shokunin`
(canonical, per r76-baseline).

**LSP note (seat rule):** a GDScript-capable LSP server answers on this host
(`godot --headless --editor --path <proj> --lsp-port <p>` serves
`textDocument/references` over TCP — driver `lsp_refs.py`). Semantic reference
checks below used the real server; grep is the literal cross-check only.

Landed diff at critique: `M corpus/fixtures/navagent3d_detour.gd` +290/−5
content lines (r76 header model block +29; setup-gate re-key
`map_is_active(map) != fs["map_active"]`; r75 comment refreshed with exact
edges; 7 arm dicts ~237 lines; `_apply_mutation` +`map_active` last; `fs`
+`map_active` field+fold), `M corpus/fixtures/run_battery.py` +14/−0 = 7
CASES tuples, insertions-only (156 prior rows byte-preserved → 163).

## Verdict

**7/7 new arms load-bearing; zero drops. No new arm re-runs a stationary
cell — every arm authors its mutation via `mutate` steps after the base
tuple materializes, and the pinned fact is the per-frame window position
(stale at +0..+k-1, fresh at +k), which no setup-flag arm can express. The
r75 `_check_tuple` extraction still holds and is re-demonstrated
byte-identical on the landed file (−53 lines, 78/78 cases equal, 19/19
fail-path mutants equal) — the r76 diff added zero new copies of the
chain, keeping the consumer count at 4 full + 2 partial. The `st2` dead
store survives at line 331 — re-proven deletable via real LSP references
on the landed file. Honesty check: the r75-flagged "no dead-hop point is
ever SERVED" overclaim is now RESOLVED in-place — `mut_win_link` step1
pins the served-and-pop-traversed zombie inside the window, and the
header was rewritten to say exactly that.**

## Per-arm discrimination lattice

Declared axis: pin the same-turn setter→server-sync window — a forcing call
on the same tick serves the pre-mutation path; wait>=edge serves post-sync;
the edge is a stable per-setter constant. Landed edges: link toggle 2f,
region transform 3f, map deactivate ∞ (map leaves the iteration), agent
layers 0 (synchronous), same-value writes suppressed (never dirty).

| arm | distinct cell killed | marginal note |
|---|---|---|
| `mut_win_link` | "link-toggle invalidation is synchronous or 1-frame" | step1 = tp+mutate+wait:0 in ONE step — the same-turn forcing read pops idx 2→3 ACROSS the killed gate (next=(2.5,0,5.5) = the dead far endpoint). The only same-turn-zombie-pop-traverse cell in the suite; the r75-critic `zw_popgate_sameturn` falsification made durable. s2 pins still-stale at +1f, s3 fresh at +2f — edge=2 exactly. s3 tuple ≡ `mut_link_kill` s2 (author-documented landmark); earned cells are s1/s2 |
| `mut_win_region` | "region_transform shares the 2f edge" | edge=3: stale at +0/+1/+2 (three identical stale tuples — each is REQUIRED: dropping any leaves that frame unpinned inside the window), fresh at +3. One frame deeper than the link channel. s3 tuple ≡ `mut_region_move` s0 |
| `mut_map_off` | "map deactivation is just another queued mutation" | NO edge exists: identical committed tuple (reachable=true!) served at +0/+10/+15 with no latch — the map leaves the iteration, iter never bumps, no dirty flag surfaces. Distinct mechanism from `mut_latch_zombie` (whose array survives because the agent's update early-returns while the server still syncs; here the server never syncs). The 3 identical-tuple samples are the edge-absence evidence shape, not redundancy |
| `mut_map_cycle` | "pending writes under an inactive map are lost / apply early" | link write while off queues (getter applied, tuple still served for 5f), reactivation re-arms the normal 2f edge — fresh at +2 post-reactivate. s3 tuple ≡ `mut_link_drop` s0 shape but arrived via queued-write provenance; earned cells s0–s2 |
| `mut_same_link` | "every setter write dirties the stored path" | M-witness: tp to M pops idx but never re-queries, so path[0] stays S — same-value `link_enabled=true`+5f leaves it at S (suppressed), effective `false`+5f re-anchors at M (s2 contrast). Needs all 3 steps |
| `mut_same_region` | "suppression is a bitmask-only shortcut" | TWO same-value setters in one mutate dict — `region_layers:1` AND `region_transform:IDENTITY` (a Transform3D value compare, not a bitmask) — both must suppress for the tuple to stay S-anchored; contrast layers 1→2 empties |
| `mut_same_agent` | "the agent channel dirties like the RID channels" | dedup BEFORE the synchronous clear: same-value `agent_layers:1` at wait:0 leaves the stored array same-turn (peek npath=3), effective `2` at wait:0 clears to [] instantly (peek=[] — the only same-turn sync-clear pin; `mut_layers_agent` used wait:5), restore+5f re-materializes anchored at M |

Cross-round subsumption check: `mut_link_kill` retains its distinct cell
(mutation lands while the agent already sits post-traversal at the bank —
its s2 peek pins stale idx=3 vs `mut_win_link`'s pre-traversal stale
idx=2). `mut_region_move`, `mut_link_drop`, `mut_lazy`, `mut_latch_zombie`
all retain distinct provenance. No old arm becomes droppable.

## Weight item — `_check_tuple(obs,want,prefix)`: still warranted (re-demonstrated on the landed file)

Post-landing copy census is UNCHANGED: **4 identical full copies + 2
prefixed partial variants** — `_run_pop_arm` (1664–1683) ≡ `_run_link_arm`
(1731–1750) byte-identical; `_run_motion_arm` pre-motion (1950–1969) ≡
modulo `st`→`st2`; step-loop full variant (1993–2013) prefixed `step%d `;
plus the `peek_only` branch and pre-read peek block partials. The r76 diff
extended arm DATA only — zero new chain consumers.

Demonstrated extraction (`landed_cons/navagent3d_detour.gd`, built on the
committed file): the same `_check_tuple` helper (28 lines incl. comment)
replaces the 4 full copies at 4 call sites; peek/pre-read/pos/pre-teleport/
metadata checks stay in callers. 2045 → 1992 lines (**−53**, same delta as
r75). Verified:

- **PASS path**: all 78 detour cases (71 prior + 7 new) run on `landed/`
  vs `landed_cons/` — (exit, stdout, stderr) tuples equal pairwise, every
  landed exit == CASES expectation, every exact marker present, stderr
  empty. Driver `compare_detour.py`; receipt `runs_compare_landed.json`
  (156 run records). Independently re-verified at pre-r76 HEAD too:
  `runs_compare_head.json` (71/71 equal on sha `81a8c10a`).
- **Fail path**: 19 forced mutants on the landed pair — every chain branch
  (idx/next/final/dist/flags/npath/path-element, pre-teleport, link copy,
  step idx/flags, peek_only, pre-read) plus **6 mutants firing inside the
  new arms** (`w_serve_pop` → `mut_win_link step1 idx=3 expected=9`;
  `w_edge_region` → `mut_win_region step3 final=…`; `w_mapoff` →
  `mut_map_off step1 flags reachable=true…`; `w_cycle` → `mut_map_cycle
  step3 final=…`; `w_same_supp` → `mut_same_link step1 pre-read idx=2`;
  `w_same_clear` → `mut_same_agent step2 pre-read idx=2`) — diagnostic
  text byte-identical; only GDScript-backtrace LINE NUMBERS differ
  (inherent to any line-shifting refactor; the battery never matches
  backtrace lines). Driver `run_mutants.py`; receipt
  `mut_compare_landed.json`.

Verdict: **keep recommendation — land the extraction.** It shrinks the very
surface this round extended (each new arm is already a `_check_tuple`
consumer via the step loop; any future same-turn arm is one more).
Optional further −~15: `_check_stored(idx,path,want_idx,want_path,prefix)`
folds the two peek tails (differ only in observed-key names) — unchanged
from r75.

## Deletion candidate — `st2` dead store (line 331), re-proven on landed file

`st2 = states[states.size() - 1]` inside `if arm_cfg.has("steps"):`.
LSP `textDocument/references` on `var st2` (file line 319, 0-idx 318:6)
returns exactly {318 decl; 330, 335, 337 writes; 393, 394 reads} —
transcript `lsp_st2_landed.json`. The only readers are the
`_run_link_arm`/`_run_pop_arm` dispatch args (394/395), and the steps path
`return _run_motion_arm(…, st, states)` at line 392 precedes both — on the
steps path the store is never consumed. Identical proof shape to r75.
**Trivially safe — delete 1 line.** Malformed-config edge unchanged:
`states[states.size()-1]` at ~2084 (`var stf`) raises the same index-error
class.

## Considered-and-rejected

- **Drop `mut_win_link` as subsumed by `mut_link_kill`** (same final
  tuple): rejected — the earned cells are the in-window serves (the
  same-turn zombie pop-traverse exists nowhere else); the final tuple is a
  shared landmark, not the arm's content.
- **Drop `mut_map_off` steps 2–3 as identical-tuple repetition**: rejected
  — for an "edge never fires" claim the samples ARE the evidence; one
  wait:15 read would leave +10 unmeasured. 3 samples is minimal-enough.
- **Fuse `mut_win_link` + `mut_win_region`** (both pin an edge): rejected —
  couples two constants (2f link / 3f region) and two geometries into one
  red; the round's claim is precisely that the edge is per-setter-class.
- **Fuse the three `mut_same_*` arms**: rejected — link flag, region
  layers+Transform3D value-compare, and agent-mask channels dedup through
  different code paths; the agent one additionally pins same-turn
  dedup-before-sync-clear. Same rejection as r75's empty-tuple fold.
- **Fold `elif diag == ""` tails / `elif not es.get("peek_only")` guard**:
  subsumed by the helper; cosmetic either way.

## Nits and honesty flags

- **`fs` readback timing is gate-safe**: every new arm's LAST mutate sits
  ≥1 frame before arm end (mut_win_link +2f, mut_map_cycle +2f post-
  reactivate, mut_same_* +5f) — object-level getters read post-setter
  truth from ~1f, so the honesty fold sees the applied state. Verified:
  all 7 arms PASS live and their PASS markers byte-match the CASES rows.
- **`_apply_mutation` ordering caveat (coverage gap, not weight)**: the
  `map_active` write is applied last with the comment "a queued RID write
  in the same dict stays invisible regardless of setter order" — but no
  landed arm mixes `map_active` with another key in ONE step dict, so that
  ordering claim is currently unexercised by tracked arms (the author's
  own probe covered the multi-step shape only). Noted for the record;
  both arms are order-insensitive as authored.
- **`mut_map_off` keeps `reachable=true` served on a permanently-stale
  map** — the author header correctly distinguishes this from the latch
  mechanism; consistent with the probe (`active=false`, iter frozen).
- Setup-gate re-key `map_is_active(map) != fs["map_active"]` is
  load-bearing (without it `mut_map_off` fails the gate on a correct
  run). All `fs` keys consumed; all `mutate` keys exercised by ≥1 arm.

## Contract preserved

`call_deferred`/`_run` shape, 30-frame settle, exact-match flags,
`_argval` unknown-`--arm` fail-closed, `_fail`/`_cleanup` teardown
(`map_active` touches no owned-RID bookkeeping; `region_recreate` still
owns the fresh RID). `_run_steps` ordering unchanged: set_target → tp →
mutate → wait → peek capture → forcing read — the r76 arms exploit
wait:0 = same-tick read, which the machinery already expressed
(`range(0)`). PASS grammar `steps=%d idxs=%s` reused verbatim by the new
arms. Battery diff insertions-only; the 5 content deletions on the
fixture diff are the gate re-key, the comment refresh, and the `any_mut`
dict line — generalizations verified by the 78/78 replay (71 prior detour
rows byte-identical; 156-row battery unchanged by my analysis, author's
own run pending in their report).

## Evidence index

- Landed snapshot: `landed/navagent3d_detour.gd` sha256 `066a06d2…`,
  `landed/run_battery.py` `6faa8356…` — byte-identical to `git show HEAD:`
  blobs at `3ab09fd` (receipt `landed_sha.txt`).
- 78/78 replay: `runs_compare_landed.json` — (exit,stdout,stderr) equal
  pairwise, exits == CASES, markers exact, stderr empty.
- Consolidation artifact: `landed_cons/navagent3d_detour.gd` (−53 lines);
  fail-path receipt `mut_compare_landed.json` (19 mutants, 6 inside new
  arms); pre-r76 HEAD corroboration `runs_compare_head.json` (71/71) +
  `mut_compare_head.json` (13 mutants).
- LSP: Godot headless editor `textDocument/references` — `st2` refs
  {318 decl; 330,335,337 writes; 393,394 reads}, transcript
  `lsp_st2_landed.json` (driver `lsp_refs.py`); pre-r76 HEAD run
  `lsp_st2_head.json`.
- New-arm live runs: all 7 `--arm=mut_*` PASS markers byte-match CASES
  (verbatim in report lattice; re-runnable via `compare_detour.py`).
- Author's own spike corroborated: `corpus/live/r76-author/runs/
  probe_win_*.stdout.txt` edges (link stale through +1f, fresh +2f;
  region stale through +2f, fresh +3f) match the landed step tuples.

## Scope notes

- Sibling reports read for consistency (r76-critic probe taxonomy, r76-
  boundary semantics). Semantic verdicts on the model itself are
  critic/adjudicator scope; this report judges only minimal expression,
  duplication, and deletability.
- Semantic context for this build/geometry/host: bridge island fixture +
  corridor, corridorfunnel, cell 0.25, 60 tps, scripted teleports.
- Next deletion would remove a truth-table cell: remaining slack is the
  `_check_tuple` extraction (−53 demonstrated, −~68 with the peek-tail
  fold) and the 1-line `st2` store — both carried over from r75, both
  re-demonstrated on the landed file. Stopping.
