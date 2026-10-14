# game-dev-3d round 80 — simplifier (seat: simplifier, host: devin)

Write scope honored: this report + `corpus/live/r80-simplifier/**` only; no git
mutations; no tracked file was written by this seat. LEAF seat — no subagents,
no judging, no shipping.

**Arrival state / provenance.** Entered with the pre-fold r79 fixtures
(`bpy_sync_probe.py` `740ccdf64c19…`, `bpy_battery.py` `e107b25152fc…`). Mid-seat
the author landed the fold (commit `faae4e0`, blobs `e960981485e7…` /
`ae3b04b12955…`; `git show HEAD:… | sha256sum` == audited working-tree shas, so
everything below audits the committed content verbatim). The MOVE was executed
twice independently: the author's landed EDGE-schema fold, and this seat's
scratch fold (different schema) used as the second, independently-gated claim
test.

**LSP device: unavailable — recorded.** No `lsp` tool is exposed to this seat
(MCP servers: `rea` only, a Ghidra/REA binary-analysis device). Caller checks
below use text grep as the literal fallback, and are not presented as semantic
proof.

## (1) MOVE in scratch — independent second fold + claim gate

Scratch: `corpus/live/r80-simplifier/scratch/bpy_sync_probe.py` sha `f4545a5e8b69…`
(+`arm_evalcat`, 46 per-class rows; r79 arms byte-untouched) and
`bpy_battery.py` sha `38a8d12315ba…` (+46 pins, + battery-side closure guard
that fails any evalcat row with `flushed=True` and an all-zero five-event
vector).

| command | exit | result |
|---|---|---|
| `blender -b -P …/scratch/bpy_sync_probe.py` (×4) | 0 | 124 ARM lines (78 r79 + 46 evalcat), stderr 0 B; probe2/3/4 stdout sha `f191b680a063…` ×3 byte-identical |
| `python3 …/scratch/bpy_battery.py --runs …/runs` (×3) | 0 | **83/83 PASS**, signal_fail=0, quirk_drift=0, `closure_violations=[]`; receipts `runs/bpy-20261014T142316533905Z|142324270147Z|142326351218Z` |
| r79 byte-stability | — | `diff` of the 78 r79 ARM lines vs `corpus/live/runs/bpy-20261014T135140188222Z/probe.stdout.txt` → **identical**; all 37 r79 case observations identical to that receipt's `verdicts.json` |

**Claim test — not falsified.** 12 mutation classes + 2 retrieval paths beyond
the landed tracked catalogue probed (scratch rows + recon receipts
`runs/recon{,_2,_3}.stdout.txt`, shas
`44f5fb09…`/`53d9ec7c…`/`5e5dd320…`): direct `scene.frame_current` write
(+same-frame), `render.fps`, `ob.parent` (discriminating `matrix_world`),
`ob.data=` swap, mesh vertex write (subsurf witness), `ob.update_tag()`,
`objects.remove`, `hide_viewport` (evaluated `hide_viewport` witness),
`keyframe_insert` same-frame bind, `bpy.ops.object.select_all`,
`bpy.ops.ed.undo_push`, `msgbus` publish — every
one stale at write+0 with all five counters 0 and zero handler fires (msgbus
callbacks 0; `undo_post` 0). The two non-frontier op calls flush via the
in-set `bpy.ops` class (dup+2 / dup+1). Two adjacent *retrieval* paths measured
no-eval as well: `C.view_layer.depsgraph` property returns the same graph
object without evaluating; `Object.to_mesh()` (no depsgraph arg) returns the
object's own unmodified mesh with no eval and no handler fire. This
corroborates boundary's 45-class screen (`reports/round-80/r80-boundary.md` §2)
and the critic's 37-class sweep independently.

## (2) Audit of the landed fold — clean

| check | command | result |
|---|---|---|
| battery ×3 (tracked fixture, receipts into scratch) | `python3 corpus/fixtures/bpy_battery.py --runs …/runs` | **64/64 PASS** ×3, fatals=0, `evalcat_closed_set` (violations=0) PASS; receipts `runs/bpy-20261014T142418089187Z|142434823479Z|142439173008Z` |
| r79 byte-stability | 78 r79 ARM lines vs r79 receipt | **identical** (`diff` = 0); 37 r79 observations identical to the r79 `verdicts.json` |
| landed evalcat vs frontier receipts | value cross-check | matches: `evalcat1.stdout.txt:13` (op_apply `verts3 xmax6.000`), `:16` (op_add `Cube|o`), `:20` (op_modapply `verts49`), `:23-25` (mode EDIT/OBJECT/loc-clear), `:29` (driver fresh 7.0), `:41` (con_rna fresh `(3,0,0)`), `:48,51` (walltime stale); `evalcat2.stdout.txt:13` (keyframe f1 `(0,4,0)` rna_y 4.000), `:16` (explicit fresh `(0,0,8.000)`), `:18` (clean update silent) |
| dead-code audit | ref-count of every new helper in `bpy_sync_probe.py` | all referenced (min 1); no dead functions |

## (3) Deletions / deletion candidates (measured)

No deletions made in the shared tree (write scope). Candidates, strongest first:

**D1 — `slept=` field in `walltime_s*` rows (`bpy_sync_probe.py:1002-1003`):
nondeterministic, unpinned, and it breaks the receipt byte-stability the
pre-fold fixture had.**
- Measured: landed battery runs 1/2/3 `probe.stdout.txt` shas `c4de106b16c3…` /
  `70944761ddd8…` / `70944761ddd8…`; the **only** inter-run diff in the whole
  stdout is `walltime_s0 … slept=0.51` vs `slept=0.50` — so `cmp` across these
  three runs already fails (run 1 vs runs 2/3). Pre-fold the whole stdout was
  stable (`69b512cb3855…` on the r79 receipt and boundary's battery-a/b), so
  the byte-wise replay convention of boundary §4 is now exposed.
- The field is unpinned (`grep -c slept corpus/fixtures/bpy_battery.py` → 0)
  and carries no signal: `dt=` already states the sleep input; `held=` states
  the observation.
- Minimal deletion: drop the `slept=…` kwarg (and its `t0`). Larger deletion
  (also reclaims ~3.5 s probe wall; frontier's dispatch hint and the critic's
  §6 nit both favor it): drop the three `walltime_s0/1/2` rows — the axis stays
  pinned by the `walltime` edge row + `walltime_fresh`.

**D2 — `_ec_edge1()` dead branches (`bpy_sync_probe.py:595-599`).** All five
call sites (`:718, :735, :812, :835, :986`) pass `invoked=None`, and
`_ec_edge()` (`:581-593`) forces `edge=FALSIFIED` whenever a bare row shows a
moved held read or any watched-handler delta — so the `"0"` and `"na"` returns
of `_ec_edge1` can never survive into an emitted row. Reachable labels are
`"1"` and `"unbound"` only. Candidate: collapse the helper to those two
outcomes; low priority (the branches are defensive totality, not a second
authority).

**D3 — unpinned emitted rows (7).** `keyframe_ins` (`:756`, `ret` duplicated by
the pinned `keyframe` row), `op_add_fresh` (`:882`, duplicates pinned `op_add`
`held_names`), `op_modapply_w0` (`:894`, duplicates r79 pin
`modifier_w0held_stale`), `walltime_s0/1/2` (`:1002`, see D1), `keyframe_f`
(`:770`, `f1` duplicated by pinned `keyframe`; only `f2` is unique). These are
receipt weight, not authority; trimming loses no pinned fact.

**D4 — frontier scratch probes superseded (ignored scratch).**
`corpus/live/frontier-bpyeval/bpy_evalcat_probe{1,2,3}.py` are now duplicated
by the tracked fold. Caller check (grep fallback; LSP unavailable as recorded):
`evalcat_probe|frontier-bpyeval` hits only reports and the fixture's provenance
comment (`bpy_sync_probe.py:419`) — no code caller, no import. They are
gitignored, so no tracked deletion is required; provenance stays in
`reports/frontier/fa-bpy-evalcat.md` (historical — never delete). Same for the
two scratch schemas (scout's `bpy_*_r80.py`, this seat's scratch fold): the
tracked fixture is the single authority; do not mix pins across schemas.

## (4) Preserved contract

- r79's 37 cases and 78 ARM lines: byte-identical in **both** folds (verified
  by diff against `corpus/live/runs/bpy-20261014T135140188222Z/`).
- Landed battery verdict determinism: 3/3 runs identical results, 64/64 PASS.
- Receipt byte-stability: pre-fold whole-stdout sha stable (`69b512cb…`); the
  landed fold breaks it **only** via D1; this seat's scratch fold keeps it
  (`f191b680…` ×3, no `slept` field).

## (5) Tradeoffs

- My scratch fold pins exact handler counts (`hx=…`) because they were stable
  3/3 on this host; the landed convention (`dup_fired`/`fc_fired` booleans,
  "pin ≥1, never exact") is the better one — if any extension row from §1 is
  ever folded, express it in the landed EDGE schema; my schema is not proposed
  for landing (it would create a second convention).
- The landed closure guard is in-probe (`_ec_edge` + `violations` counter); my
  guard is battery-side parsing. One convention is enough — the landed one is
  the authority; no change proposed.
- D1's larger variant (drop the sleep rows) trades the per-sleep `dt=` receipt
  evidence for ~3.5 s wall; the minimal variant keeps everything and restores
  byte-stability.

## (6) Confidence and stop point

High (measured): all audit and stability results above. Medium: D1 recurrence —
measured 1/3 runs; it is a wall-clock field with 2-decimal rounding, so a
byte-wise replay is inherently exposed. Untouched unknowns (op ×1/×2 mechanism,
keyframe tag-vs-rebuild, render triggers) are outside this seat's axis.

Stopping: the next deletion (r79 arms, or de-duplicating the forced r79↔evalcat
overlap rows) would harm the byte-stability axis; no further weight can be
removed without breaking a preserved contract.
