# game-dev-3d round 81 — reviewer (seat: reviewer, host: devin)

Reviewed artifacts: the r81 diff as landed — work commit `65b2f26` (author:
`arm_reorder` + 6 evalcat extension rows) plus simplifier fold `fd75567`
(dead `t0` store, unreachable `_ec_edge1` branches, `und` term removed;
6+/6−). Final tree at review time = HEAD `fd75567`. Blobs reviewed:

- `corpus/fixtures/bpy_sync_probe.py` sha256
  `58ffb9f2b6539e939eebcbd89494ce093cfbabe07d1af2ad29bd1fd03e5b82ab`
  (blob `04d8f6c`, 1262 lines; author blob was `02131534`/`8e63cfb`)
- `corpus/fixtures/bpy_battery.py` sha256
  `111568eec55fe1e489cc8ec6d41b8c2934611466537749d0dace68601fb44e4e`
  (blob `f0803332`, 409 lines — unchanged by the fold)
- `corpus/fixtures/run_battery.py` sha256 `22a1966d…` (blob `92f9c6e`) —
  untouched; `git diff --name-only` lists only the two bpy fixtures.

Repo/runtime: lane root `~/Projects/shokunin/game-dev-3d-shokunin`; single
canonical runtime `/usr/bin/blender` (only one on PATH) = Blender 5.2.1 LTS
(hash `9e2066aef7ef`, built 2026-09-01), embedded CPython 3.14.7
(`io.DEFAULT_BUFFER_SIZE` 131072, `line_buffering=False`,
`write_through=False`, `isatty=False` in the captured path — measured in my
own cells, `corpus/live/r81-reviewer/runs/blender.stdout.txt`).

**LSP note:** no `lsp` device is exposed on this substrate (MCP inventory =
the `rea` binary-analysis server only), so caller/definition/diagnostics
checks are text-level (grep/read/compile), not server-verified semantic
proof — recorded as a verification gap. Affected-caller check: the only
tracked consumer of the probe is `bpy_battery.py:35` (`PROBE = HERE /
"bpy_sync_probe.py"`); no `.gd` or other `.py` references it (grep over the
tree, ignored scratch excluded). Diagnostics: `python3 -m py_compile` clean
on both fixtures; both are exercised end-to-end by the battery run.

**Timeline (why this report spans two blobs):** the wave dispatched seats
concurrently. Author receipts were produced on probe `02131534`
(14:57:25Z/14:58:03Z, cited in `r81-author.md`); my first replay
(15:01:38Z/15:01:44Z) ran on that same blob. Simplifier fold `fd75567`
landed 15:05:20Z (mid-Godot-run, see §7), moving the probe to `58ffb9f2`. I
then re-ran the full replay on the committed blob (15:06:01Z): **byte-identical
stdout sha `947ad726…`**, 74/74, 4/4 order-checks — so every receipt below
resolves on the committed state, not just on the author's pre-fold blob.

## Verified on the committed state (my own runs)

1. **Battery 74/74 ×3 + order checks 4/4, deterministic ×5 receipts.**
   `python3 corpus/fixtures/bpy_battery.py --runs <abs>/corpus/live/r81-reviewer/replay-runs-head`
   → `cases=74 pass=74 fail=0 (signal_fail=0 quirk_drift=0) launch_ok=True
   done_marker=True fatals=0 exit=0`; receipt
   `replay-runs-head/bpy-20261014T150601689078Z/verdicts.json` (probe 4.38 s,
   stderr 0 B). Committed blob stdout sha `947ad726…` is identical to: my two
   author-blob runs (`replay-runs/bpy-20261014T150138386511Z/`,
   `…T150144997871Z/`) and the author's two runs
   (`corpus/live/r81-author/runs/bpy-20261014T145725071084Z/`,
   `…T145803952150Z/`) — byte-identical across two probe blobs. Receipt
   `order_checks` = 4/4 PASS; the gate `not order_failed` is wired into the
   verdict (`bpy_battery.py:388-389`) and the payload (`:397-398`).
2. **Byte-stability of the prior catalogue (the round's declared hard
   requirement) — confirmed four ways.**
   - r79 78-line prefix **byte-identical**: sha `08101bed…` reproduced under
     the author's convention (`"\n".join(lines)+"\n"`), from both my pre-fold
     baseline receipt (`baseline-runs/bpy-20261014T143553498365Z/`, 64/64,
     stdout sha `fb336ae5…`) and the committed-blob receipt.
   - r80 34-line block sha `146af473…` reproduced (same convention).
   - All **112 prior ARM lines byte-identical as an ordered subsequence**
     (0 missing) of the 123 physical ARM lines; the `closed` row keeps its
     content (`violations=0 events=…`) and moves ARM-line index 112 → 118;
     the 6 ext rows land at 112–117 and the reorder rows follow (receipt
     lines 119–124; `head-analysis.json`, `replay-analysis.json`).
   - 64 prior CASES: **0 mismatches** on stable fields (case/arm/point/layer/
     pinned/observed/non_signal/verdict/reasons) between my pre-fold 64/64
     receipt and the committed-blob receipt.
   - Diff is insertion-only: 331 + / 3 −, the three deletions being the
     line-continuation rewrites of the `arm_evalcat` tuple, the runner tuple,
     and the verdict gate (`git diff`; probe `:1182-1189`, `:1254-1256`).
3. **Reorder arm — topology, attribution, drop-not-misattribute.** Raw
   committed receipt (`probe.stdout.txt`): child rows at 119–120
   (`child_marker who=child`, forged `dup src=child_inj`), the merged
   `REORDERGLUE::ARM reorder | gluevictim | …` line at 121, then the parent's
   withheld rows: `pre_spawn` 122, `dup src=parent` 123, `post_spawn` 124 —
   the parent row emitted before the spawn lands after every child byte
   (prefix reorder fabricated live). Tracked-parser attribution on my receipt:
   `("reorder","child_marker","FD1")→who=child`;
   `("reorder","dup","FD1")→src=parent` (physical last-wins);
   `gluevictim` cell **absent** while its bytes are present (spliced line
   fails `^ARM`, dropped — not misattributed); exactly 4 reorder cells, no
   extras; `PROBE_DONE` remains the last python-level line before blender's
   C-level tail. `post_spawn` pins the preconditions
   `child_rc=0 line_buf=False write_through=False fd1_fifo=True`.
4. **Falsifier liveness — re-run, not trusted.** I re-ran the author's
   collapse mutant myself (`blender -b -P corpus/live/r81-author/probe_collapse_mutant.py`
   → exit 0, stderr 0 B, `collapse-replay.stdout.txt`) and fed it to the
   author's `liveness_check.py`: **5 failures** —
   `reorder_child_before_pre_spawn` FAIL, `reorder_splice_dropped` FAIL,
   `dup src=child_inj` ≠ `parent`, `line_buf=True` ≠ False,
   `fd1_fifo=False` ≠ True. The same checker on the real committed receipt:
   **0 failures**. The pins discriminate; they are not constant-True.
5. **Precondition pins are capture-context facts, verified both ways.**
   Battery capture (pipe) → `fd1_fifo=True`; my own direct file-redirected
   run (`blender -b -P corpus/fixtures/bpy_sync_probe.py >
   direct-replay.stdout.txt`) → `fd1_fifo=False` with the reorder still
   formed (`post_spawn` row) — matching the author's `probe.direct.stdout.txt`.
   The battery contract is the captured path, so the pins hold there; the
   critic's "captured" docstring suggestion is the correct scope guard.
6. **Extension rows — pins match the receipt; under the armed falsifier.**
   All six `ext_*` rows: `held=stale invoked=none dpre=dpost=dfcp=dfc=dund=0`
   with discriminating witnesses (`held_loc/fresh_loc`, `held_names/fresh_names`,
   `held_mesh/fresh_mesh`, `held_mw/fresh_mw`, `purged`/`rna_meshes_*`), and
   `ext_frame_current` additionally pins the lazy-tag mechanism
   (`get_dup=1 get_fc=0`). They run inside `arm_evalcat` **before** `closed`
   (`bpy_sync_probe.py:1182-1197`), so a flush/handler fire on any bare row
   auto-FALSIFIES it and increments `violations`; receipt shows
   `closed | violations=0`. Tracked bare catalogue 8 → 14 (verified count).
7. **Sibling isolation.** Godot side untouched (fixture hash unchanged, no
   `.gd` diff). Clean run on the committed blobs:
   `python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs
   corpus/live/r81-reviewer/godot-runs2` → **176/176 PASS, seeds_unchanged=True**
   (receipt `godot-runs2/20261014T150625120569Z/verdicts.json`, seed map
   carries probe `58ffb9f2`/battery `111568ee`). My first Godot attempt
   (`godot-runs/20261014T150256392095Z`) ran 176/176 cases but verdict FAIL
   with `seeds_unchanged=False`: the simplifier's `fd75567` landed mid-run
   (probe digest `02131534` → `58ffb9f2`) — an environment collision,
   recorded, superseded by the clean run.
8. **One canonical runtime / same identity.** `which -a blender` → only
   `/usr/bin/blender`; version/build consistent with r79/r80. No reroute
   surface exists in this lane; the r79 shared-graph identity row is still
   pinned and re-witnessed (`ev_get … same_obj=True` in the receipt).
   `resume_continuity_v1` has no surface here (grep: no matches outside
   ignored scratch) — the seat-card resume clause does not apply.
9. **Claim wording / honest saturation (spot-checked in the durable drafts).**
   `SCORECARD.md` r81 block: "prior 111 ARM lines byte-identical; r79
   78-line prefix + r80 34-row block preserved in order; deterministic x2" —
   accurate (the 111 are the contiguous prefix; the 112th, `closed`, is
   byte-identical but repositioned). `LOG.md` r81 entry: bounded per-runtime
   wording, "Verifier replay pending at adjudication" disclosed. The author
   report scopes parse survival to "distinct keys + marker presence + the
   explicit physical tie-break" and never claims universal no-misattribution.
   No unqualified saturation claim found.

## Findings (severity order)

**LOW-1 — the author report's blob citation and its "one-line mutant" claim
are one commit stale.** `r81-author.md:25,113` cites probe `02131534` and a
mutant that is one line away from it; the committed probe is `58ffb9f2`
after simplifier fold `fd75567`. The mutant
(`corpus/live/r81-author/probe_collapse_mutant.py`, gitignored scratch) is
exactly the author blob + one `sys.stdout.reconfigure(line_buffering=True)`
line — verified by diff against my snapshot — but against HEAD it now shows
four hunks (the three folded dead sites + the reconfigure). No functional
impact: I re-ran the battery on the committed blob (74/74, stdout sha
`947ad726…` unchanged), so every receipt resolves on HEAD; the mutant's
liveness conclusion also holds (my re-run: 5 failures). Fix is report-level
only: cite `58ffb9f2`/`fd75567` in report-last wording.

**LOW-2 — probe module docstring is still the r79 nine-arm description.**
`bpy_sync_probe.py:1-38` documents only the r79 lattice; the file now carries
11 arms and ~840 lines of r80/r81 sections. The r81 sections do carry their
own header comments (and the reorder header at `:1200-1226` is exemplary);
this is the r80 reviewer's LOW-3 nit, unfixed. Documentation-only.

**NOTE-1 — `reorder_splice_dropped` is construction-coupled** (critic's nit,
confirmed): it requires the child's unterminated tail to merge with the first
buffered parent row. A future child edit adding a trailing newline would turn
the check into a conservative false-FAIL (never a silent pass). No action for
this round; the coupling is visible in the check comment (`bpy_battery.py:361-366`).

**NOTE-2 — one exact handler-count pin added**: `ext_frame_current` pins
`get_dup=1` (`bpy_battery.py:211`). It was stable across five identical
receipts here, but it is an exact count, same class as r80's `upd_dup=1`
(cross-build risk only; the r80 reviewer's NOTE-1 disposition applies).

**NOTE-3 — parse-survival scope is bounded, and honestly so.** The tracked
fixture pins survival for the arm's own fabricated topology (distinct-key
attribution, marker position, drop-not-misattribute, physical tie-break).
The wider hazards measured in sibling scratch — forged tracked-namespace rows
(e.g. `evalcat|closed|EDGE`), non-UTF-8 capture crash, total-prefix reorder
without the sealing flush — are **not** pinned. The author report discloses
the scope and the critic's G1/G2 bound it; the code comment (`:1211-1213`)
records why the sealing flush exists. Residual surface, not a defect.

## Residual risk / verification gaps

- No `lsp` device (above): caller/definition checks are text-level; single
  consumer surface (`bpy_battery.py:35`).
- Cross-build: every pin is receipt-derived for Blender 5.2.1 LTS
  (`9e2066aef7ef`), CPython 3.14.7 embed, pipe capture, this host; no
  tolerance story (inherited from r79/r80).
- The tracked reorder arm pins the reorder *within* the r81 section (prior
  prefix sealed by an explicit flush to keep prior rows byte-stable). The
  total-prefix variant (child bytes at stream byte 0) is measured in
  sibling scratch and documented in the arm comment, but not pinned.
- Interactive / tty / `--python` regimes unmeasured; the pins would falsify
  there by design (`fd1_fifo`, `line_buf` witnesses).
- The author report's evidence was written against `65b2f26`; the fold
  `fd75567` landed during this review. I re-proved byte-identity on HEAD,
  but report-last wording should cite the committed blobs (LOW-1).
- `ext_obj_remove`'s `held_names=keep|o` rides a freed-ID read (author- and
  scout-disclosed fragility; a build refusing it fails the pin, never
  silently passes). `edge=absent` on `ext_orphan_purge` is a disclosed
  label extension to the data-layer axis; the falsifier still catches a
  flush via the handler-delta predicate.

## Recommendation (not a judgment — the canonical runtime judges)

The committed r81 diff is sound and the round's two claims hold as scoped:
(1) the reorder topology is fabricated live on `blender -b -P` and the
parse-survival cells discriminate — falsifier demonstrated by my own mutant
re-run (5 failures) against 0 on the real receipt; (2) the catalogue
extension is byte-stable — r79 prefix and r80 block hashes reproduced, all
112 prior ARM lines an ordered subsequence, 64 prior cases 0 mismatches,
insertion-only diff, 74/74 with four live order checks on the committed
blob. Findings are documentation-level (LOW-1/LOW-2) plus disclosed scope
notes. No tracked edits by this seat — writes confined to
`reports/round-81/r81-reviewer.md` + `corpus/live/r81-reviewer/`.

Stopping here.
