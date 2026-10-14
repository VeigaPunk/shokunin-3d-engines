# R78 adjudicator (Sol) — map-off permanence ladder + callsite pair

Round: 78. Wave: `shokunin-train-20261014-w9`. Work commit: `efcf33c`
("r78: map-off permanence ladder + callsite pair CASES").

## Declared move (depth)

Extend the r76 `map_set_active(false)` permanent-stale finding with a
longer wait ladder {20,60,120,300}f and pin map/object iteration state +
emissions so "permanent" stays falsifiable; pin the r76-critic
`_physics_process` callsite finding as tracked CASES (coroutine-resume vs
physics-context writes with edge-shift receipts). All 173 prior rows +
probes + Node byte-stable.

## Seat convergence

| seat | landing | contribution |
|---|---|---|
| author | partial | diff landed + committed `efcf33c`; critic verified all 3 arms byte-verbatim + merged 176/176 pre-commit; report seat died to rate limits (2 respawns) |
| scout | yes | fixture map — `_read_srv` lacked `map_iter` (falsifier gap, closed by the landed pin); callsite arm slot + PhysMutator shape |
| critic | yes | landed diff holds on every measurable claim; **sample-base correction**: the callsite pair does NOT isolate an absolute latency difference — both writes apply at the same per-tick sync drain; bound=2 vs bound=1 = drain-await sample-base shift. Two wording defects fixed at integration (`:252` "applies at +1" → "first *observed* applied at +1 — same drain"; `:268` "one queue-stage deeper" → same-drain phrasing). 176/176 merged battery verified. |
| boundary | yes | permanence to **+1200f** (zero map_changed emissions — 80x bound extension); reactivation edge on+2 wait-length-INDEPENDENT; NO mark-vs-phase under inactivity; mid-wait force stamps object iter without publishing + halves post-on edge; callsite two-band model (physics-phase +2 / post-sync +3 serve) |
| reviewer | yes | audit clean; `_final_srv_state` gate + callsite plumbing notes fed the author |
| scribe | yes | own harness 56 receipts: permanence {0..600}f all stale, map_iter frozen; cumulative ≡ fixture-scan (no sync phase to race under inactivity); callsite −1 deterministic; run-1 3-row flakes re-passed standalone ×3 (load jitter, disclosed); lesson+LOG drafts (adopted with the critic's sample-base correction) |
| baseline | yes | frozen `71818b7` archive-only, comm checks empty; 173/173 + 4 probes + Node 31/31, 0 drift over 173×12 fields vs r77 verifier receipt |
| simplifier | in flight | seat alive at closeout write; flags land post-close if warranted |
| verifier | never landed | 3 dispatch/respawn attempts died to free-model rate limits — operator verification below |

## Operator verification (adjudicator own reproduction, committed `efcf33c`)

- Full battery `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot`:
  **176/176 PASS** incl. all 3 new arms (receipt
  `corpus/live/integ-r78/runs/20261014T124222288664Z/verdicts.json`).
- Direct arm replays on a fresh scratch project, byte-verbatim vs the
  CASES pins: `mut_mapoff_ladder` bound=5 groups=2 sizes=5,1;
  `mut_ctx_resume` bound=2; `mut_ctx_phys` bound=1 groups=2 sizes=1,2.
- CASES diff insertion-only (+3 rows); fixture comment corrections are
  comment-only (critic's suggested text).

## Measured headline (multi-seat convergence)

- **Permanence is a measured regime, not a claim**: link-kill under
  map-off stays stale through +1200f — `map_iter` frozen, `link_iter`
  unstamped, zero `map_changed` emissions. The falsifier (any
  rung's map_iter bump or tuple change) is wired into the tracked arm.
- **Reactivation replays the standard window**: on+1 stamp / on+2
  fresh serve, wait-length-independent — queued writes survive
  inactivity; nothing expires or applies early.
- **Callsite pair = sample-base shift**: bound=2 (resume) vs bound=1
  (phys) — same per-tick sync drain for both writes; the phys arm's
  drain-await sees the pending state one await shallower. The full
  callsite boundary remains two-band {pre-sync +2, post-sync +3}
  (boundary) — idle/timer/`map_changed` sit in the deeper band.
- **Under inactivity, read history stops mattering**: no sync phase →
  no mark-vs-phase race — cumulative and fresh-rung protocols agree
  exactly (scribe).

## Bounds

Godot 4.7.2 / 60tps / Linux x86_64. Permanence bound = +1200f measured
(this host/build) — never "never". Callsite constants are
context-specific. The ladder arm's kill+off ordering proven inert by 4
seats (strict kill-under-off refinement open). Verifier-seat
substitution disclosed (rate-limit environment).

## Verdict — **ADMIT**

- depth: improved locally — permanence bound +1200f with wired
  falsifier; callsite pair resolved to sample-base semantics.
- coverage: improved locally — +3 CASES insertion-only + map_iter pin.
- calibration: unchanged — 173 prior rows + probes + Node byte-stable.
