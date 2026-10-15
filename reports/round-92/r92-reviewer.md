# r92 reviewer — surgical correctness review of work commit `dd32c3c`

Seat: GAME-DEV-3D r92 REVIEWER. Reviewed artifact: work commit `dd32c3c`
("r92 work: RemoteTransform3D frame-boundary + anim×body + timing lattice —
23 rows (235->258), backend splits pinned") plus its accompanying claim
document `b6169f6` (`reports/round-92/r92-author.md`). No commits, no tracked
writes by this seat; scratch confined to `/tmp/r92-reviewer/`.

Tree state at review: HEAD `17dc133` (sibling scribe/simplifier reports landed
during this review). The reviewed blobs are unchanged between `dd32c3c` and
HEAD — `run_battery.py` sha256 `1adb36d6b54b6416268120bd87ff9792a55f1a243ef675706982605c01ded125`
equals `git show dd32c3c:corpus/fixtures/run_battery.py | sha256sum`; the four
fixture shas are `3544c2e4…` (`r92_remote.gd`), `056225b3…` (`r92_animphys.gd`),
`91bf7b12…` (`r92_timing.gd`), `dc7d6de3…` (`r92_child.gd`).

**Runtime / reroute check.** Single canonical runtime: `which -a godot` →
`/usr/bin/godot` only (4.7.2.stable.arch_linux.ed1daf0bf, matching every
receipt banner); no `GODOT_*` env vars (no reroute surface). No
`resume_continuity` surface in this lane: `grep -rn resume_continuity
corpus/fixtures/` = 0; the only 36 matches under `corpus/` are frozen
prior-round artifacts (reviewer reports and tarballs) inside
`corpus/live/r8*-baseline/`.

**LSP note (recorded gap).** MCP inventory on this substrate = the `rea`
server only; no `lsp` device answers these files. Caller/definition/
diagnostics checks are therefore text/AST-level (grep, `ast` census of
`CASES`, Godot `--check-only`), not server-verified semantic proof.

**Method.** Bounded fresh runs of every suspicious cell in seat-owned
`/tmp/r92-reviewer/proj` (a copy of the four fixtures + `project.godot`),
each parent wrapped in `timeout -s KILL 90–120` (`godot --headless`), plus
`--check-only` parse checks. I executed all 23 arms = **123 child processes
= exactly one full r92 battery pass worth of children** (33 remote + 54
animphys + 36 timing), and cross-read every stored receipt: `corpus/live/
r92-author/{battery_run1.log,battery_run2.log}`, `runs/20261015T175025410714Z`
(r92-only 23-row pass), `runs/20261015T175116507786Z` (run 1),
`runs/20261015T175829468804Z` (run 2), `dev/marks`, `dev/marks2`, `dev/out`.

## Verified independently

1. **Diff shape — insertion-only, prior rows byte-identical.** `git diff
   9c6a76b dd32c3c -- corpus/fixtures/run_battery.py` is exactly
   `567a568,624`: 57 added lines at the CASES tail (the r92 comment block +
   23 rows, `run_battery.py:568-624`), **0 content deletions** (`--numstat` =
   `57 0`), the `]` and everything after it byte-identical to the parent
   (`diff` suffix check clean; whole commit = 5 files, 1790 insertions,
   0 deletions). No `,,` exists anywhere in the parent or committed file
   (`grep -n ',,'` empty in both); the reported transient double-comma fix is
   pre-commit and not in git history, but its claimed blast radius — the
   splice point only — is exactly what the committed diff shows: no prior row
   was modified in any way.

2. **Parse.** All four new fixtures `--check-only` rc=0 on the canonical
   runtime: `r92_remote.gd`, `r92_animphys.gd`, `r92_timing.gd`,
   `r92_child.gd` (no Parse Error; Godot 4.7.2 banner only).

3. **23/23 pinned digests reproduce byte-for-byte from my own runs.** For
   every one of the 23 CASES rows, my fresh arm run emitted a stdout line
   **exactly equal** to the pinned `CASES` marker string, including the
   negative control (`r92_animphys_badkey_insert`: exit 2 + exact
   `NEGATIVE REJECTED: … on=gp,jolt,dummy`). This is the strongest available
   rep-stability witness: a complete independent pass, fresh child projects,
   fresh process tree.

4. **Pinned backend splits are real (fresh-run values).**
   - `srv`: gp/jolt `srv_o=(5.0000,0.0000,0.0000)` + `ray=hit@5.000,0.500,0.000`;
     **dummy `srv_o=null`, `ray=miss`** (all four rows).
   - `animatable`: gp/jolt `ab=(0.5000,2.0000,0.0000)` under both
     `sync_to_physics` values; **dummy `sync=true ab=(0.0000,2.0000,0.0000)`
     (no move) vs `sync=false ab=(0.5000,2.0000,0.0000)` (moves)** — the
     claimed inversion; rider settle **2.9973 gp / 3.0000 jolt / 3.0000
     dummy**; dummy ray `miss`.
   - `destroy`: keyless-track rest depth **0.3920 gp / 0.0800 jolt / 0.0000
     dummy**; `badkey` cells `r1=-1 r2=-1 keys=0 type=1`, play still
     teleports to `(0,0,0)` (`playing=true`), cell counters `e=2,w=0,s=0`,
     and the two `ERROR: Condition "(p_key.get_type() != Variant::VECTOR3) …"
     is true. Returning: -1` lines are in the merged child logs.
   - `idlemode` envelope: fresh 24 reps → `idlemode@{gp,jolt,dummy}
     {reps=8,ok=8,xband=0.2-0.5}`; sampled x ∈ [0.2687, 0.2881]; predicate
     also pins `y=2.0000 z=0.0000 playing=true`, `lv=(0,-1.1376,0)` vs
     `(0,0,0)`, `srv=(x,2,0)` vs `nil` — envelope shape is honest and the
     marker never carries a sampled x.
   - timing: `tps30→0.033333`, `tps120→0.008333`; `ts0.5→0.008333`,
     `ts2→0.033333`, `ts10→0.166667`; `ts0→0.000000` (pf advances),
     `ts-1→-0.016667`; `refuse` `tps` reads back 60 with `e=1`
     (`ERROR: Engine iterations per second must be greater than 0.`);
     `steps`: `mps=1`+`ts10` delivers the full `0.166667` (no clamp),
     `interp` reads back `true` with the schedule unchanged, and
     `jitfix0` reads back `jit=0.0000` with `delta=0.016667` unchanged.

5. **Every CASES evidence string appears verbatim in receipts.** All 23
   pinned markers occur as exact stdout lines in `dev/marks/*.txt` **and**
   `dev/marks2/*.txt` (the two final-fixture dev runs are byte-identical,
   23/23 `cmp`) and in all three `runs/*/verdicts.json`; 23/23 were
   additionally reproduced by my fresh runs (item 3).

6. **Claim arithmetic.** Parent `CASES` AST census = **235 = 189 ordinary +
   46 negative**; committed = **258 = 211 ordinary + 47 negative** (+23 = 22
   ordinary + 1 negative, `r92_animphys_badkey_insert` expected exit 2). Run
   counts match the report: run 1 `cases=258 pass=257 fail=1`, sole non-PASS
   `bpy_rbw3d_render` (`M rdet same_state stable=True` vs pinned `False`,
   reasons `['exact stdout marker missing']`); run 2 `258/258`; both
   `seeds_unchanged=true`; prior-row comparison run1↔run2 = **234/235
   identical** on exit+stdout+stderr with the single `bpy_rbw3d_render`
   delta; all 23 r92 rows byte-identical run1↔run2. The pre-full-run
   `runs/20261015T175025410714Z` is a 23-row r92-only pass, 23/23 PASS.

7. **Scout corrections are accurate, with before/after evidence on disk.**
   - `jitfix`: scout §3.3 records the arm wrote the default `0.5` (no-op);
     landed `tm_jitfix0` writes `0.0` and reads back `jit=0.0000` with the
     delta schedule unchanged (fresh run) — first real measurement of the
     axis.
   - `phase` F-arm: the stale pre-fix probe rows (`dev/out/rt_proj_*_phase`,
     14:31–14:32, old `write_pf=…/ox=…` format) differ r1↔r2 on dummy/jolt;
     the landed port (`r92_child.gd:310-345`) guarantees the post-write
     physics tick with explicit `await physics_frame`×2 + `await
     process_frame` and emits `imm/same_f/post_f/next_e` with no pf stamps;
     the landed-format `dev/out/proj_phase.r1.txt` is byte-identical to r2
     and matches the pinned cell — the fix is visible and effective.
   - `-1` refusal: scout §2.4 pins the `track_insert_key` `-1` returns with a
     track that then plays and zeroes; the landed negative control
     (`r92_child.gd:948-973`) honours both returns, refuses play, and my
     fresh run exits 2 with `destroyed=false` on all three backends.
   - Correction 3 (`remote3d_transform` waits 4 frames, left conservative) is
     exact: `corpus/fixtures/remote3d_transform.gd:23-24`. Correction 4 (the
     `bpy_rbw3d_render` distribution flip) matches the r91 author's own
     wording (`reports/round-91/r91-author.md:57,107`).

## Findings (severity order)

**F1 (MEDIUM, coverage / claim scope) — two of the three r92-boundary law
components are not measured by the landed probes, and the fixture header
states the boundary law unqualified.**
The landed RemoteTransform3D cells measure the *global* side well: `sync`/
`lag`/`phase` pin "never synchronous at the write, visible at the next frame
boundary" (`r92_child.gd:226-348`), and `drive` pins the
`set_process(false)`/`set_physics_process(false)` no-gate switch
(`r92_child.gd:594-611`). They do **not** measure (a) local-mode synchronous
delivery at the write — no arm reads immediately after a
`use_global_coordinates=false` write; `c_flags`' local combos and `c_local`
await a frame before reading (`r92_child.gd:365-391, 562-591`); or (b) the
`set_notify_transform(false)` kill — no fixture calls it
(`grep set_notify_transform corpus/fixtures/` = 0 hits; the only
transform-notify-adjacent calls are `force_update_cache()` at
`r92_child.gd:406,424`). The same round's boundary seat pins both surfaces as
`[O]` (`reports/round-92/r92-boundary.md` §0 lines 34-54 and §3 lines
111-137; kill-arm receipts `corpus/live/r92-boundary/probes/rt_stop.gd`),
and its §3 [O] result is that local mode **is** synchronous (`imm=0.0000`)
while only the global notification is deferred. Consequence: the committed
fixture header's law "boundary: writes never propagate synchronously …"
(`r92_remote.gd:17-19`) is true of every cell it runs (default global mode)
but false as a general `RemoteTransform3D` statement, and the battery has no
cell that would catch a regression on either missing surface. The author
report does not claim those two cells, so this is a coverage/claim-scope
gap rather than a wrong measurement; minimal closure is a one-line mode
qualifier on `r92_remote.gd:17-19` (plus, if the round wants the law in the
regression layer, one local-imm cell and one notify-off cell ported from the
boundary receipts).

**F2 (LOW, arithmetic) — "369 child cells per battery pass" is 3× the
measured per-pass count.** `r92-author.md:16`. Measured per battery pass:
**123 children** — the report's own per-row Children column sums to 123
(33 remote + 54 animphys + 36 timing); `ARM_CASES` arithmetic = 33
single-slot cases × 3 backends (99) + 8 idlemode reps × 3 (24) = 123; and
each of the three run scratches contains exactly 123 `r92*/child.log`
(`runs/*/scratch/`). 369 = 3 × 123 = the three battery passes on disk
(r92-only pass + run 1 + run 2). The sibling scribe commit `17dc133` records
the same correction ("369=123/pass x3"); the author report text as landed
still reads "per battery pass".

**F3 (LOW, contract precision) — "`anim_t` … never emitted" is imprecise.**
`r92_child.gd:10-15` and `r92-author.md:46` say the scheduler stamps
`seq/n_e/n_f/anim_t` never cross the child boundary, but the animation
position — the scout's `anim_t` quantity — **is** emitted as `t=%.4f` in the
animatable/reset/manual/badkey/empty cells (e.g. `r92_child.gd:798-802,
825-827, 872-873, 942-944`). It is rep-stable there because those cells pin
`ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS` (my fresh markers and both receipt
sets are byte-identical), so the data is fine; the contract sentence needs
the mode qualification, and the `idlemode` cell correctly withholds `t`.

**F4 (LOW, claim) — "All animation cells pin … PHYSICS except `idlemode`"
omits `manual`.** `r92-author.md:42` and `r92_animphys.gd:7-9`. `manual` is
`ANIMATION_CALLBACK_MODE_PROCESS_MANUAL` by construction
(`r92_child.gd:863`) — the cell table itself says so; only the blanket
sentence is wrong.

**F5 (LOW, artifact hygiene) — the dev receipts directory mixes a stale
pre-fix sweep with the landed sweep.** `dev/out/` holds 105 (case,backend)
pairs × 2 reps: 33 `rt_*` bases from the pre-fix remote probe (14:31–14:32,
old `write_pf=…/ox=…` row format) and 72 `proj_*` bases from the landed
format (24 cases × 3 backends). The stale `rt_proj_dummy_phase` and
`rt_proj_jolt_phase` differ r1↔r2 (duplicated conditional field); the landed
`proj_*` sweep differs on exactly one pair, `proj_idlemode`. So
"only idlemode diffs" (`r92-author.md:77`) is true of the landed sweep and
false of `out/` as left on disk. No landed claim depends on the stale files
(and they are useful before/after evidence for correction 2, F1's sibling
item 7 above). Scribe F4 corroborates.

**F6 (NOTE) — idlemode stated range max is 1e-4 above any stored sample.**
`r92-author.md:48` says 0.2686–0.2895; the stored receipts reach 0.2894
(e.g. `dev/out/proj_idlemode.r1.txt`), my fresh 24 reps reach 0.2881. The
pinned `xband=0.2-0.5` is unaffected. Scribe F3 records the same.

## Residual risk / verification gaps

- **idlemode bucket is a sampled-median statistic (disclosed).** The marker
  pins `xband=0.2-0.5`, a function of the 8 sampled x per backend, while the
  robust predicate is the envelope `[0.05,1.2]`. On this host x clusters at
  0.269–0.289 (scout saw 0.2959), so the bucket has margin, but a materially
  different idle/physics ratio could push the median out of `0.2-0.5` and
  fail the battery while the envelope still holds. This is the round's
  disclosed non-rep-stable cell, not a defect; the failure mode should be
  read as distribution-cell noise, not a split regression.
- **No full-battery rerun by this seat.** Per instruction I ran bounded
  fresh runs of the 23 arms (one full r92 pass of children) rather than a
  258-case battery; the two full passes are covered by receipts plus my
  field-level byte-identity checks (234/235 prior rows, 23/23 r92 rows).
- **Cross-build.** Every pin is receipt-derived for Godot
  `4.7.2.stable.arch_linux.ed1daf0bf` on this host; no tolerance story
  (inherited from r89–r91). The idlemode cell is the most
  scheduler-sensitive pin.
- **`bpy_rbw3d_render` is a pre-existing distribution cell** (r91-documented
  "PNG bytes are not a witness"; the r92 diff touches no bpy fixture): run 1
  sampled `stable=True` (FAIL) and run 2 `stable=False` (PASS). Worth one
  line in the corpus's known-distribution list, as the author suggests.
- **No LSP device** (above): caller/definition/diagnostics checks are
  text-level; affected surfaces here are small and single-consumer (the four
  fixtures parse clean and all 23 arms execute).
- **Structural (already filed by the simplifier, `b6a3e1a`):** the three
  parents triplicate the ~80-line child-spawn machinery
  (`r92_remote.gd:104-183`, `r92_animphys.gd:233-312`,
  `r92_timing.gd:94-173`). Maintainability, not correctness; a corpus
  convention decision.
- Sibling artifacts `reports/round-92/r92-scribe.md` and `r92-simplifier.md`
  landed (commits `17dc133`, `b6a3e1a`) during this review; they are not mine
  and did not influence the measured evidence above.

## Recommendation (not a judgment — the canonical runtime judges)

**ADMIT-recommend.** The committed diff is sound as scoped: insertion-only
(`567a568,624`, 0 prior-line changes), all four fixtures parse, and every one
of the 23 pinned digests — including the three-engine splits and the exit-2
negative control — reproduces byte-for-byte in an independent seat-owned
pass of 123 children, with all 23 evidence strings additionally present
verbatim in both dev receipt sets and all three battery receipts. Claim
arithmetic is exact for 235→258 and the run counts; the only arithmetic
conflict is F2's "per battery pass" label (369 = 3 × 123). The findings are
claim-scope/report-level except F1, which is a coverage gap against the
round's own boundary law (local-sync and notify-off unmeasured, header law
unqualified) that the author never claimed to close — if the judge treats
those two surfaces as required regression coverage, the minimal CHANGES set
is F1 alone: qualify `r92_remote.gd:17-19` and port one local-imm cell plus
one `set_notify_transform(false)` cell from the `r92-boundary` receipts; F2–F5
are text-only fixes that touch no pinned row.

Stopping here.
