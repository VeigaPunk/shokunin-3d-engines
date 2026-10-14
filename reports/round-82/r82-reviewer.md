# game-dev-3d round 82 — reviewer (seat: reviewer, host: devin)

Reviewed artifacts: the r82 diff as landed — work commit `0619300`
(author: evalcat residual fold + parser-hazard cells + critic fold),
refinement `7b4615b` (pre-redirect `fflush` preserving the startup banner),
simplifier fold `e79e004` (dead `held` param off `_ec_edge1` ×16 call
sites, dead `dg0` binding, stale line-refs). **Final tree at review time =
HEAD `e79e004`.** Blobs reviewed:

- `corpus/fixtures/bpy_sync_probe.py` sha256
  `07ec83e33512b6430b085dee9029163b41594b4e6e8608aab8b98d6c6c483a48`
  (blob `527d524`, 1611 lines)
- `corpus/fixtures/bpy_battery.py` sha256
  `045102a8514df96bda0c2268841ec0751de87f678f34cbdf981c3a7c6ff882ec`
  (blob `e421499`, 608 lines)
- `corpus/fixtures/run_battery.py` sha256 `22a1966d…` — untouched
  (`git diff --name-only 31cf56a..HEAD` lists only the two bpy fixtures).

Repo/runtime: lane root `~/Projects/shokunin/game-dev-3d-shokunin`; single
canonical runtime `/usr/bin/blender` (only one on PATH) = Blender 5.2.1 LTS
(banner hash `9e2066aef7ef`, file sha256 `fd7c5e44…`), embedded CPython
3.14.7; sibling `/usr/bin/godot` = 4.7.2.stable.arch_linux.ed1d0bf; no
`BLENDER_*`/`GODOT_*` env vars (no reroute surface); the battery's
`--blender`/`--godot` overrides are explicit and receipt-recorded.

**LSP note:** no `lsp` device on this substrate (MCP inventory = the `rea`
server only), so caller/definition/diagnostics checks are text-level
(grep/read/compile), not server-verified semantic proof — recorded as a
verification gap. Caller check: `_ec_edge1` has 1 def + 16 call sites, all
2-arg after the fold (0 stale 3-arg calls); the three new helpers
`_ec_all_names/_ec_inst_count/_ec_in_dg` each have live consumers
(`bpy_sync_probe.py:1189-1203` → `:1310-1322`, `:1441-1442`); the battery's
only probe consumer is `PROBE = HERE / "bpy_sync_probe.py"`. Diagnostics:
`python3 -m py_compile` clean on both fixtures.

**Timeline.** Author commit `0619300` landed 15:38:26Z; my first full
replay ran on it (15:39:13Z, stdout sha `3f82eb52…`). The author's report
then disclosed one uncommitted refinement (pre-redirect `fflush`); it was
committed as `7b4615b` (15:48:49Z) and the simplifier fold `e79e004`
landed 15:49:30Z. I re-ran everything on the final tree (15:50:13Z /
15:50:20Z): **byte-identical stdout sha `6a98c570…` across the pre-fold
working tree, the final tree ×2, and the author's cited ×3** — so every
receipt below resolves on the committed state.

## Verified on the committed final state (my own runs)

1. **Battery 83/83 ×2 + 4/4 order-checks + 7/7 hazard-checks,
   deterministic.** `python3 corpus/fixtures/bpy_battery.py --runs
   corpus/live/r82-reviewer/final-runs` → `cases=83 pass=83 fail=0
   (signal_fail=0 quirk_drift=0) launch_ok=True done_marker=True fatals=0
   exit=0`; receipts `…/bpy-20261014T155013126014Z/`,
   `…T155020802137Z/` — both stdout sha
   `6a98c570dbaec6f33f23c684ae2938470a251c229cb50d4451c23eb1d07defc3`,
   identical to the author's `…154116`/`…154123`/`…154404` and to my
   pre-fold working-tree run `replay-wt/…154708`. stderr 0 B; probe 4.54 s.
   `n_arm_lines` = 131 (134 physical ARM lines − 3 same-key overwrites:
   reorder `dup`, hazard `dup_flush`, forged/genuine `closed`), matching
   the author's 122 → 131 census.
2. **Prior-118 ARM rows byte-stable, insertion-only.** My comparator
   (`tools/compare_receipts.py`): prior 118 rows (all rows before the
   reorder arm, incl. the genuine `closed`) are a **byte-exact ordered
   subsequence of the final stream, 0 missing**; prior 74 CASES **0 field
   mismatches**; 11 inserted ARM lines; **0 removed/changed**; the r80
   34-row block sha `146af473…` and 78-line prefix sha `08101bed…`
   reproduce. A raw `difflib` diff of baseline → final streams shows the
   complete r82 delta: 11 inserted ARM rows + the banner line relocating
   head (below) — nothing else touched.
3. **Falsifier liveness re-proved on the final tree with my own mutants.**
   - `mutA2` (one injected `C.view_layer.update()` inside
     `_ec_x2_instance_empty`'s window): the row auto-emits
     `held=flushed … edge=FALSIFIED` with the **instance-aware witness
     moving** (`held_inst_pre=0 → held_inst_post=1`), `closed` carries
     `violations=1`, battery FAIL (2 cases + 1 hazard check). The new fold
     rows are armed, not decoration.
   - `mutB2` (the H1 forged `violations=0` row moved physically **last**):
     the case layer reports **83/83 PASS with the real violation on the
     wire** — the mask is real — but `hazard_forge_closed_cell_genuine`
     evaluates False → verdict FAIL. The split invariant is load-bearing
     end-to-end; this is the author's critic-folded correction doing work.
4. **Hazard lattice re-measured independently through the tracked
   module.** `tools/hz_measure.py` on the committed battery (receipt
   `hazards/post-move.json`, identical to `hazards/pre-move.json` — the
   diff changed no capture/parse behavior): H1 `real_only` → 3/FAIL,
   `forge_first` → 3, `forge_mid` → 3, `forge_last` → **0/PASS (the
   demonstrated mask — the parser detects nothing)**; H2 synthetic +
   live dup = **physical last-wins both directions** (flush → forged wins,
   noflush → parent wins); H3 binjunk → `UnicodeDecodeError` propagates
   unhandled out of `run_process`; H4 detach-EOF through tracked
   `run_process(timeout=3)` returns at **3.003 s**, `rc=None`,
   `error="TIMEOUT after 3 seconds"`, parent bytes captured, bounded
   within 1 s; raw `communicate()` on the same topology blocks until the
   holder exits (6.019 s). Every `hazard_checks` pin matches its measured
   resolution.
5. **Godot sibling clean on the final tree.** `python3
   corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs
   corpus/live/r82-reviewer/godot-runs3` → **176/176 PASS,
   seeds_unchanged=True**, seed map carries final bpy shas
   (`07ec83e3`/`045102a8`), receipt `godot-runs3/20261014T155033907367Z/`.
   Two earlier attempts were invalidated by mid-run tracked-file edits
   (`seeds_unchanged=False`; probe `061cc21e`→`33091ec1`→`07ec83e3`) —
   environment collisions recorded, superseded by the clean run.
6. **Simplifier fold is byte-identical (independently re-proved).** Final
   tree ×2 sha `6a98c570…` = pre-fold sha; `_ec_edge1` signature/16 call
   sites consistent; the battery comment's corrected refs are exact
   (`run_process` `:358-369`, `parse_arms` `:372-381`).
7. **Claim-vs-implementation spot checks.** The folded ext2 pins are
   byte-identical to the r82-scout's independent 14-class run
   (`runs/classes/classes-a.stdout.txt`, a/b identical) — e.g.
   `ext2_update_tag_obj` `fresh_loc=(5,0,0) get_dup=1 get_fc=0`,
   `ext2_instance_empty` `held_inst_pre=0 held_inst_post=0 fresh_inst=1`,
   `ext2_batch_remove` `ret_type=NoneType pre_names=ctl|o|o2
   fresh_names=ctl`; the author's cited receipts resolve on the final tree
   (same sha); battery wall ≈ 7.7 s (probe 4.54 s + 3.0 s bounded hazard
   cell + version call), stderr 0 B, `closed | violations=0`.
8. **One canonical runtime / same identity.** `which -a blender`/`godot`
   → one each; no env reroute; `resume_continuity_v1` has no surface in
   this lane (grep: no matches outside reports).

## Findings (severity order)

**LOW-1 — the `0619300` receipt silently lost Blender's C-level startup
banner; fixed by `7b4615b`, which relocates rather than restores it.**
On `0619300`, `_ec_x2_instance_refused`'s fd1→devnull redirect swallowed
the pending C-stdio buffer: the enum `TypeError` triggers Blender's report
path, whose C-stdio write/flush happens while fd1 is redirected (the
pre-redirect receipts show the banner and the report line landing together
at lines 1–2), so the buffered banner — plus the jitter
`reports | ERROR` line — went to `/dev/null`. Evidence: every pre-move
receipt carries 1 banner line (my `baseline-runs/…151951`, author
`…153315`), while six `0619300` receipts from four seats carry 0 (mine
`…153913`, author `…153825`/`…153837`, verifier `…154046`/`…154106`,
baseline `…153853`); the pre-redirect intermediates (author
`…153611`/`…153631`, critic `landedA/…153444`, `landedC/…153628`) show the
banner **and** the uptime-stamped `00:04.3xx reports | ERROR` line at
lines 1–2. The `fflush(NULL)` fix (`7b4615b`) restores the banner at
**byte 0** (deterministic; no report line; my ×2 + author ×3 all
`6a98c570…`), but the banner's position now differs from every prior
round's tail placement — a receipt-shape change in the non-ARM tail. The
brief's binding requirement (prior 118 ARM rows byte-identical) holds
(0 missing), so this is receipt fidelity, not pin damage; flagging because
the r81 byte-stability convention included the non-ARM banner line.

**LOW-2 — the author report's byte-stability citation is not green.**
`r82-author.md:136-142` cites `corpus/live/r82-author/bytestab.py` for
"all 123 baseline ARM lines … ordered subsequence … non-ARM lines
identical in content". Measured: the checker's non-ARM clause is
order-sensitive list equality (`bytestab.py:47,51`) and it **exits 1 on
every cited receipt** — post-fix `…154404`, pre-fix `…153837`,
intermediate `…153631` (exit codes 1/1/1). The ARM-subsequence half passes
(0 unmatched); the prose "identical in content" is accurate as a multiset
(only the banner moves), but a reader running the cited checker gets a
non-zero exit. Report-level fix only.

**LOW-3 — author report blob citations are one to two commits stale.**
`r82-author.md:28-30` cites `0619300` + "one uncommitted refinement"; the
final tree is `e79e004` (`7b4615b` + simplifier fold). No functional
impact: the cited receipts' stdout sha `6a98c570…` is byte-identical on
the final tree (verified ×2), so every number resolves on HEAD; fix is
report-last wording.

**NOTE-1 — the forge invariant's limit is real and disclosed.** A forgery
landing physically last that copies the genuine key set is undetectable:
predicate evaluation (marker present + `violations=0 events=…` forgery
last) yields both checks True → no hazard failure. The check comment
(`bpy_battery.py:522-528`) and the author report state this boundary; the
boundary seat's `forge_full_keys` cell measured the same. Documented
boundary, not a defect.

**NOTE-2 — the detach cell pins the timeout *branch* at 3 s, not
`TIMEOUT_S=60`.** `hazard_detach_eof_hold` uses a bounded 3 s
`run_process` call (harness behavior); the probe-level 60 s detach is
measured by the boundary seat (`d2_s75b`: battery FAIL, cases 74/74, no
silent truncation). The battery wall grows ~4.4 s → ~7.7 s; the `sleep 8`
holder self-terminates (no strays after any of my runs). Bounded, worth
one report sentence.

**NOTE-3 — per-run temp-dir litter.** `_ec_x2_libraries_load` creates a
`tempfile.mkdtemp()` + ~140 KB `.blend` per run and never cleans up
(author-disclosed; one dir per battery run in `/tmp`). Bounded litter.

**NOTE-4 — `ctypes.CDLL("libc.so.6")` is glibc-name-specific.** Guarded by
`try/except`; on a host without that soname the fix degrades to the
pre-fix banner-swallow (still deterministic). `fflush(NULL)` flushes all C
streams — no other C writers are active at that point in the probe.

**NOTE-5 — six new exact-count pins** (`get_dup=1 get_fc=0`) — same class
as r80 NOTE-1 / r81 NOTE-2: stable ×3 here, cross-build risk only.

## Residual risk / verification gaps

- No `lsp` device (above): caller/definition checks are text-level; the
  affected surfaces are single-consumer and small.
- Cross-build: every pin is receipt-derived for Blender 5.2.1 LTS
  (`9e2066aef7ef` banner token), embedded CPython 3.14.7, pipe capture,
  this host; no tolerance story (inherited r79–r81).
- The key-copy forge-accept boundary (NOTE-1) and the body-splice
  misattribution boundary (critic F4) remain documented, not closed. F4 is
  **not reachable in the landed arm** — the probe contains no mid-line
  flush (no `sys.stdout.write`, no `print(end=…)`; grep-verified).
- The banner relocation means full-stdout shas are not comparable across
  the r81→r82 boundary in the non-ARM tail; the r82 delta is exactly 11
  ARM rows + banner move (verified by difflib).
- `hazard_detail.eof_hold_wall_s` is timing jitter (3.003/3.004) — the
  payload-identity-modulo-wall-time convention now extends to this field.
- `ext2_batch_remove`/`ext_obj_remove` ride freed-ID enumeration on the
  held dg0 (stable here; the critic's SEGFAULT class applies only to
  stale-reference *removals*, which the landed code does not perform).

## Recommendation (not a judgment — the canonical runtime judges)

The committed r82 diff is sound as scoped: (1) the residual fold adds 6
bare classes + 2 documentary DEG cells under a live closed-set falsifier
(my mutA2 flips a row to FALSIFIED and `closed` to violations=1); (2) the
parser-hazard pins document measured resolutions honestly, and the
critic-folded split invariant catches the physically-last forgery the case
layer cannot (my mutB2: 83/83 case PASS, hazard check FAIL → verdict FAIL);
(3) prior 118 ARM rows byte-stable, insertion-only, 0 CASES mismatches;
(4) the simplifier fold is byte-identical (`6a98c570…`); (5) Godot
sibling 176/176 `seeds_unchanged=True`. Findings are LOW/report-level
(banner relocation now fixed in-tree, checker exit, stale citations) plus
disclosed boundaries. No tracked edits by this seat — writes confined to
`reports/round-82/r82-reviewer.md` + `corpus/live/r82-reviewer/`.

Stopping here.
