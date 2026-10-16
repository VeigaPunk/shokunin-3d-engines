# r96 reviewer — surgical correctness review of the committed joltdet landing (`dd054a2`)

Seat: **GAME-DEV-3D r96 REVIEWER**. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r96-reviewer.md`.
Reviewed artifact: `dd054a24af91c3cac84826f5df5ce5efa9e88429` ("r96 author: 12
joltdet rows (316 total) — Jolt warning expected-error class, ts=tps law both
backends, Dummy vacuity w/ live controls; 316/316 green") — `corpus/fixtures/
r96_joltdet.gd` (+873, new), eight `corpus/fixtures/r96_probe_{iters,pen,warm,
damp,rest,kin,srvjoint,settings}.gd` (new, byte-identical copies of the r96-scout
probes), `corpus/fixtures/run_battery.py` (+30), `reports/round-96/r96-author.md`
(+224). Claim document: `reports/round-96/r96-author.md`; context documents
`reports/round-96/r96-scout.md` and `reports/round-96/r96-boundary.md`.

**No commits, no tracked writes by this seat.** Receipts live under
`corpus/live/r96-reviewer/**` (gitignored via `corpus/.gitignore: live/`; see
`RECEIPTS.md` there). The only new repo file is this report.

**Byte custody.** At seat start `HEAD = dd054a2`; `git status --porcelain` was
clean except untracked sibling reports (`reports/round-94/r94-reviewer.md`,
`reports/round-95/r95-reviewer.md`). The measured tree is `git archive dd054a2`
extracted to `/home/vgpnk/.cache/r96-reviewer/tree`; every sha256 in the
archive equals `git show dd054a2:<path>` for all ten changed fixture files plus
the report, and the author's own probe shas match the archive bytes exactly
(`r96_joltdet.gd 8a77ecb4…`, `iters 06d80e50…`, `pen 762e11b4…`, `warm
4228f7ae…`, `damp d6ce9067…`, `rest 1d7bd6e7…`, `kin ddc50d99…`, `srvjoint
db3447f6…`, `settings e190adff…`, `run_battery.py 935ed912…`). Every measurement
below ran from that archive, from a scratch copy of it, or from a seat-owned
mutant of it; the worktree was never used as a seed source. **`/tmp` was not
used at all** (scratch under `/home/vgpnk/.cache/r96-reviewer`, 791 GiB free).

**Mid-seat drift (sibling lanes, contained).** HEAD moved during the seat to
`dda3e7e` ("r96 simplifier: PASS — SP1-4 −14 proven …") — a **report-only**
commit: `git show HEAD:corpus/fixtures/{r96_joltdet.gd,r96_probe_iters.gd,
run_battery.py}` are sha-identical to `dd054a2`'s, so the reviewed bytes are
still the committed bytes. The r97 lane's ten `corpus/fixtures/r97_probe_*.gd`
seeds appeared untracked; sibling wave-B seats (critic, simplifier, verifier,
scribe) ran their own full batteries throughout, so all rates below are
**loaded-window rates** (loadavg 55–86; `nproc` 32). This seat made no tracked
write.

**Runtime.** `which -a godot` → `/usr/bin/godot` only,
`4.7.2.stable.arch_linux.ed1daf0bf` (matching every receipt banner);
`/usr/bin/python3` → 3.14.7; no `GODOT_*` env vars; no `resume_continuity`
surface in this lane (`grep -rn resume_continuity corpus/fixtures/` = 0).

**LSP note (recorded gap).** MCP inventory on this substrate = the `rea` server
only; no `lsp` device answers these files. This seat made no edits, so no
symbol-level work was required; the available substitutes used were
`--check-only`, `py_compile`, an AST census of `CASES`/`ARMS`, char-level diff,
and an independent re-implementation of the fixture's normalizer.

**probeParent seat.** Exactly one `ufo-labrat` was dispatched (bounded probe:
"does the threaded GodotPhysics `iters stack` child stall standalone?"). It
returned **BLOCKED — its profile exposes no exec/shell tool** (tools:
`find_file_by_name`, `grep`, `read`), so it measured nothing; it is recorded as
an unusable probe, not as evidence — the fourth seat in this train to hit the
same blocker (r93 reviewer, r95 boundary §9 note 6, r95 reviewer). Its intended
measurement was performed by this seat with the exec tool
(`direct/thread-probe.txt`, §7). No other descendants were spawned.

**Method.** (1) Committed-diff shape (numstat + char-level prefix/suffix +
line-level opcodes). (2) Parse checks on the canonical runtime. (3) AST census
of `CASES`, `ARMS`, and the child budget. (4) **Probe provenance**: the eight
`r96_probe_*.gd` sha256 vs the scout's probe sources. (5) **Fresh arm sweep**:
12 arms × 3 reps = 36 runs from a clean scratch copy of the archive at load
58–79. (6) **Battery `--only`** on the 12 r96 rows × 2 reps. (7) **Full 316-case
battery × 4** from the clean archive (two of them concurrent by accident —
recorded below) at load 55–85. (8) **Independent normalizer** (Python
re-implementation of the fixture's documented drop rules) recomputing every
pinned cell sha from the raw child logs. (9) **Mutation probes** at arm level (7)
and at battery level (4). (10) **Direct-child probes** of the Dummy `sleep1`
hang (with and without `--fixed-fps`) and of the threaded `iters stack` cell.
(11) **Receipt integrity** of the author's own runs (markers, seed digests,
sweeps, crosscheck). (12) **Claim audit**: every hex and ≥5-char number in the
report machine-matched against committed markers. (13) **Cross-row consistency**
between the tscale/ffps/thread/dummy cells and the independently pinned
joint/contact/tps cells.

---

## Verified independently

1. **Diff shape — insertion-only, zero existing bytes touched.**
   `git diff --numstat dd054a2^ dd054a2` = 873/0, 143/0, 283/0, 184/0, 186/0,
   165/0, 40/0, 98/0, 176/0, 30/0, 224/0 — ten `A` and one `M`, no deletions.
   A linear prefix/suffix comparison of the two `run_battery.py` blobs gives
   **common prefix 248 322 chars, common suffix 26 317 chars, old middle empty,
   new middle 9 663 chars**; line-level opcodes = exactly one
   `insert old[738:738] new[738:768]` (the 6-line comment + 12 tuples). No
   replace/delete anywhere. The r96 block is contiguous at CASES indices
   **304–315**, immediately after `r95_bullet_neg_shm_rt`.

2. **Parse.** `godot --headless --check-only --script res://<f>` → rc 0 with no
   `Parse Error` for all nine r96 fixtures; `python3 -m py_compile
   run_battery.py` → rc 0.

3. **Census.** `CASES` = **316 = 257 ordinary + 59 negative**; r96 = **12 rows
   (12 ordinary, 0 negative)**. The six generic arms declare **93 cells**
   (joint 12, contact 16, restkin 15, tps 26, solver 17, mech 7); the six
   special arms spawn **61 children** (tscale 12, ffps 10, dummy 18, thread 20,
   knobs 3, nc 4) → **160 children per battery pass**, exactly as claimed. The
   r96 arm list is bijective with the 12 CASES tuples.

4. **Probe provenance — the eight copies are the scout's bytes, run under the
   scout's names.** Every `corpus/fixtures/r96_probe_<n>.gd` sha256 equals
   `corpus/live/r96-scout/probes/<n>.gd` for all eight probes (`iters pen warm
   damp rest kin srvjoint settings`), so the boundary §7.1 rename hazard is
   avoided by construction; the fixture copies each probe into the child project
   as `res://<probe>.gd` under its **original** name (verified in the seat's own
   scratch dirs: `iters.gd`, `damp.gd`, … and in the archived hang cell, where
   the child `damp.gd` sha == `d6ce9067…` == the committed probe).

5. **The author's six battery receipts verify, and they ran on final bytes.**
   r96-only pre-runs `20261016T001054599566Z` and `20261016T001410168438Z` =
   **12/12 PASS**; full runs = **315/316** (`navagent3d_retarget_fixed`),
   **313/316** (`navagent3d_retarget`, `phys3d_joints_free_ops`,
   `phys3d_joints_chain3`), **315/316** (`navagent3d_retarget`), **316/316
   PASS**. All six carry `seeds_unchanged=true` and **83 seed digests each that
   equal the committed blob content exactly** (recomputed from `git show`), so
   the runs are receipts for the committed bytes, not for a drift-ahead
   worktree. Every r96 marker in every receipt is byte-equal to the committed
   marker; all 12 r96 rows PASS in all six runs; slowest r96 row 7.75 s against
   the 20 s case bound.

6. **The author's sweep is marker-stable on the final bytes, and its earlier
   sweep is honestly superseded.** `runs/sweep2` = **6 reps × 12 arms = 72
   runs**, every arm's PASS line **byte-equal to the committed marker**, one
   distinct marker per arm; the only per-run variation is in `#` diagnostic
   lines (ffps `warn=`/`pos=`, nc `zero-read ticks=`, both documented as
   unpinned). `runs/sweep1` (3 reps × 12 arms) is a **pre-encoding revision**:
   its `contact` markers read `warm_stack@jolt{sha=f07717cee9da1846}` (reps 1–2)
   and `{sha=567e8d885de7408c}` (rep 3) where the committed row pins
   `psha=fbab7c7a665083e3` — i.e. sweep1's own 1/3 instability is the evidence
   behind the author's correction #7 (see F3).

7. **The scout/boundary cross-check reproduces from live children.** The
   author's `crosscheck-run1.log` reads `match=93 missing=0 differing=0`; this
   seat independently re-ran three of those cells from **its own** child logs
   (different parent process, `--fixed-fps 60`, load 58–79) through its own
   normalizer: `it_pin@gp` 46/46 lines, `pen_overlap@jolt` 33/33,
   `warm_rest@gp` 83/83, all three shas equal (`581274d6aaf4b04c`,
   `78ba5ab0fa213a8d`, `01b77b49cb036f42`) to the scout's receipts. The fixture
   re-derives the scout's receipts; it does not restate them.

8. **Fresh arm sweep reproduces the committed markers byte-for-byte under load.**
   12 arms × 3 reps = **36/36 runs rc=0, stdout marker == committed marker,
   one distinct marker per arm, stderr empty**, at load 58.2–79.0. Slowest arm
   7.87 s (`ffps`), 4.40 s (`tps`), all far inside the 20 s bound. Receipts:
   `fresh/` (`results.json`, 36 `.out`/`.err`, archived child logs).

9. **The ffps encoding is an allowlist that does real work, and its pinned sha
   is reproducible without the fixture.** The Jolt `--fixed-fps` warning fires
   as an exactly-2-line block (verified byte-exact, including the five-space
   `     at: CreateJob …` line) at a variable stream position. In this seat's
   three `ffps` runs the census was **1/6, 1/6, 3/6** receipts; one such
   receipt (`ff_jolt_r1.log`, warning at line 18) normalizes to the **same**
   `4492126fd9b2b3f3` as the other five and as the **no-flag reference** — and
   that sha is the `it_pin@jolt` sha pinned independently in the `joint` and
   `tps` rows (no flag). The three GP receipts are **raw byte-identical** to
   each other (`cmp` r1==r2==ref) with `warn=0`. Combined census across the
   author's 15 parent runs and this seat's 3: **34/108 Jolt fixed-fps receipts
   carried the warning (~31 %)**; one of the author's six-receipt runs had
   **0/6**, which is why the class is pinned as optional + self-gated rather
   than as a count.

10. **An independent normalizer reproduces every pinned cell sha from raw child
    logs.** A Python re-implementation of the documented drop rules
    (banner/empty, the exact 2-line warning at any position, the
    `!is_inside_tree()` benign block, the RID-leak lines; `ERROR:`/SCRIPT
    ERROR/Parse Error/handle_crash routed to `ue`, never to the digest) gives
    **93/93 pinned cell shas exactly, in each of 3 reps (279/279), with zero
    unexpected-error lines** — including the pose-only `psha` cell. Receipt:
    `audit/verify-shas.txt`.

11. **The digest gate is non-vacuous, at the layer that owns it (battery
    mutation probes).** In seat-owned mutants of the archive tree:
    - `A2` — make the scanner drop any `WARNING:` line: the arm's **self-gate
      rejects it** (`allowlist{allow=1,reject=0}` → FAIL). The near-miss check
      is load-bearing.
    - `A1` — mutate the allowlist text so the real warning no longer matches:
      the `ffps` **battery row FAILs in 3/3 reps**; this seat's normalizer
      reproduces the arm's observed shas (`2949a9daa0413e05`, `aad88523face5de5`)
      from the raw logs under the mutated rule and collapses all six receipts to
      `4492126fd9b2b3f3` under the committed rule — so the failure is exactly
      "the warning was not dropped" (it fired 1/6, 1/6, 2/6 in those runs).
    - `C1` — change `--time-scale 0.5` → `1.0` in the `pin_ts05` pair: the
      `tscale` row FAILs with `eq=0` and the mutated receipt's sha equals the
      **60-tps project's** sha (`581274d6aaf4b04c`) — the law is measured, not
      restated.
    - `D1` — run the `dummy` slot's project as GP: the `dummy` **battery row
      FAILs** (the `d=-1.0/0.0/…` vacuity values become live GP values), proving
      the vacuity pins are live measurements; the arm alone still prints PASS
      (the value pins live in the battery — see F8).
    - `E1` — run the hang cell's project as GP: the `dummy` **battery row FAILs**
      (`hang=0`), proving the `rc=137` hang gate is live and cannot pass when the
      child terminates.
    - `G1` — `penetration_slop=0.1 → 0.2`: the `mech` **battery row FAILs**
      (`pen_jolt_slop sep_end` moves), proving the knob pin measures the engine.
    - mutant `F1-injected-error` — inject an `ERROR:` line into a probe: the
      `joint` **battery row FAILs** (`ue` non-empty), proving unexpected
      diagnostics are not swallowed.
    Receipts: `mutants/mutants.json`, `mutants-batt/mutants-batt.json`, logs.
    (Mutant labels are the harness names; they are unrelated to the finding
    labels below.)

12. **The `sleep1` hang is a real, bounded, correctly-gated child — measured
    outside the fixture.** Direct child (committed probe, Dummy project,
    `--fixed-fps 60`, `timeout -s KILL 2`): **rc=137 in 4/4 runs**, log
    **10 102 856–20 527 016 bytes** (5.0–10.2 MB/s of repeated
    `SCRIPT ERROR: Invalid call. Nonexistent 'bool' constructor. at: on_e
    (res://damp.gd:136)` — 442 occurrences inside the first 128 KiB), the `D0
    case=sleep1 engine=Dummy` header present, no `DSUM`; the same probe on
    GP/Jolt exits **rc=0 in 0.64 s / 0.76 s** with 11.3 KB / 11.1 KB logs. The
    hang cell therefore exercises the fixture's 128 KiB cap (`truncated` is
    required by the gate), and the hang child's log is **removed after the scan**
    (no `child.log` in `r96t*_d_sleep1_dummy/`, and none archived in
    `fresh/childlogs/repN-dummy/`). Receipts: `direct/hang-*`.

13. **Cross-row consistency — the encodings agree with the independently pinned
    cells.** 16/16 machine checks pass (`audit/claim-audit.txt`): all six
    `tscale` sha/ref pairs equal the matching `tps`-row shas
    (`pin_ts05==it_pin@gp120==d24077db012d9045`, `pin_ts20==it_pin@gp30`,
    `jpin_ts05==it_pin@jolt120==4492126fd9b2b3f3`, `jpin_ts20==it_pin@jolt30`,
    `lin10_ts05==lin10@gp120`, `lin10_ts20==lin10@gp30`); the `ffps` shas equal
    the no-flag `joint`/`tps` shas; the ten `thread` cells equal the matching
    unthreaded cells; the three `knobs` key-name hashes are identical
    (`874d8759ff135309`). The Dummy cells' **live controls agree with the
    independently pinned rows in 10/10 fields** (`pen_overlap gp/jolt`,
    `warm_rest gp/jolt`, `kin_kcontact gp/jolt`, `it_pin gp/jolt`,
    `damp_lin10 gp/jolt`), so a Dummy-only degenerate value cannot be mistaken
    for a law.

14. **`--time-scale` is compared across genuinely different projects.** In this
    seat's scratch, the `ts` side of `pin_ts05` runs a 60-tps project with
    `--fixed-fps 60 --time-scale 0.5` and the `ref` side a **120-tps project**
    with `--fixed-fps 60`; the byte-identity is therefore a cross-project
    measurement, and the mutant C1 above shows the comparison discriminates. The
    same child-project census shows the `thread` arm's `thr` bakes carry
    `3d/run_on_separate_thread=true` while every `ref` bake omits it (this seat
    verified the pair it ran; the sibling critic checked all 20 child projects).

15. **Full 316-case batteries from the clean archive ×4, r96 rows green in all.**
    Two run-1 batteries ran **concurrently** (an accidental double-start of the
    same wrapper; both receipt sets are kept): **313/316**
    (`navagent3d_retarget`, `_fixed`, `navagent3d_follow`) and **314/316**
    (`navagent3d_follow`, `phys3d_events_script_size_gate`); run 2 and its
    duplicate: **316/316** and **316/316**. Every failure is on the documented
    pre-existing load-flake list (`navagent3d_*` one-tick miss `before=1.754246`
    / `first=1.636395`, r92-verifier2 F1, r93-baseline F1/F2;
    `phys3d_events_script_size_gate` granted-under-load, r93-baseline F2). **All
    12 r96 rows PASS in all four runs**, `seeds_unchanged=true` in all four, r96
    row wall time 1.0–7.8 s, load 55–85.

16. **Claim audit — the report's values are accurate.** Every hex token in
    `r96-author.md` appears in a committed marker or a committed fixture sha
    (the only unmatched token is the date `20261015`); of the 52 numeric tokens,
    three unmatched values are explained and one is verified from a child log:
    `1.754246` / `20.03` belong to the pre-existing failing rows,
    `20261015` is a date, and **`5.399999`** (GP's t=2 velocity spike) is
    present in this seat's own `it_pin@gp` child log (`IT t=2 gap=0.21
    lv=5.399999 y=1.79`) though it is not itself a pinned cell field. The
    report's warning census (13/36, positions 16–19), nc census (3/6 runs at
    39/324), and sweep1 tower instability (1/3 reps) all match the receipts.

---

## Findings (severity order)

**F1 (LOW–MEDIUM, row stability under load — one `thread` cell can stall in a
child and redden the row; fail-closed, rate ≈1/13 row executions).** In
`batt-only/run1` (load 79.5→86.1) the `r96_joltdet_thread` row FAILed with
`it_stack@gp{eq=0,…}`. The cause is a **stalled child, not a physics change**:
`r96t2553002_th_it_stack_gp_thr/child.log` froze after `IT t=30` (14 tick lines,
1 231 B) **0.46 s** after its project was created, then produced nothing until
the fixture's `timeout -s KILL 14` killed it; its reference twin and the other
19 children of the arm finished (4 105 B, 44 tick lines, terminal summaries).
Standalone the same cell is fine: **6/6 direct-child reps complete 180 ticks in
0.63–0.84 s at load 82–84, byte-identical to the reference**, and a focused
8-rep thread sweep is **8/8 marker-exact** at load 84–86 (2.98–3.70 s); the four
full batteries also pass the row. So the author's "`eq=1` in all 10 cells" and
the boundary's "14/14 byte-identical" are **true modulo a rare batch+load
stall** of a threaded GodotPhysics child. The row fails **loudly** (exact-marker
mismatch on a truncated receipt), never silently, and the stall is not
attributable to the fixture's own logic (the threaded variant is a *second
child* of the same cell, and the unthreaded twin is unaffected). Fold candidate
for the author/adjudicator: file the class with this rate (one receipt), and/or
make the row re-run a cell whose child exits `rc=137`, and/or widen the child
bound for the threaded cell. Receipts:
`batt-only/run1/20261016T005853536119Z/`, `audit/thread-run1-scratch.txt`,
`direct/thread-probe.txt`, `thread-sweep/`. The sibling critic filed a
**different** LOW on the same row (M8: the row cannot detect a *dropped*
`3d/run_on_separate_thread` line, since both children would become the
baseline) — complementary coverage finding, not the same mechanism; both are
row-level folds for the author/adjudicator.

**F2 (LOW, claim precision — the Dummy hang log's size is overstated).** The
report says the `sleep1` child's "27 MB error-spam log is read through a 128 KiB
cap". Measured at the fixture's own settings (Dummy project, `--fixed-fps 60`,
2 s bound), four direct runs gave **10.1, 18.0, 18.1, 20.5 MB** (5.0–10.2 MB/s)
— the qualitative claim (a huge log, cap exercised, log removed) is **verified**,
the specific figure is **not reproduced** by this seat or by two sibling seats
(critic: 12.2/17.3/19.7/21.0 MB in 4/4; scribe: 16.56 MB) — three independent
seats land in **10–21 MB**, none at 27 MB. Related mechanism note (worth
recording because it reconciles two documents): **without** `--fixed-fps` the
child's loop is wall-clock-throttled and every case (including GP/Jolt) is still
running at a 2 s bound — the same child then produces ~27 KB in 2 s, which is
how the boundary's `rc=137` / "431 KB" reading at a 25 s KILL was produced. The
2 s bound is only meaningful because the round's deterministic arm
(`--fixed-fps 60`) makes the loop unthrottled; the fixture does pass
`--fixed-fps 60` to the hang cell. Receipts: `direct/hang-*`.

**F3 (LOW, receipts hygiene — the earlier 3-rep sweep is a superseded fixture
revision whose markers do not match the committed row).** `corpus/live/r96-
author/runs/sweep1/` holds 3 reps × 12 arms run against a **pre-pose-only**
fixture: its `contact` PASS lines pin `warm_stack@jolt{sha=f07717cee9da1846}`
(reps 1–2) / `{sha=567e8d885de7408c}` (rep 3), while the committed row pins
`psha=fbab7c7a665083e3`. `RECEIPTS.md` describes `sweep1/, sweep2/` together as
"6-rep markers + logs" (sweep1 is 3-rep). The underlying instability **is**
disclosed as correction #7 ("1/3 reps in the first sweep"), and the 72-run
stability claim is about `sweep2` (which does match). The hazard is audit-side:
a future reviewer reading `sweep1/contact.r*.txt` can mistake a superseded
revision's marker for live instability of the committed row (this seat did,
until the `sha`→`psha` key change identified the revision). Fold: one line in
`RECEIPTS.md` labelling `sweep1/` as pre-encoding.

**F4 (NOTE, claim wording — "byte-identical stdout across all 6 reps").** The
`#` diagnostic lines are the only variation (ffps `warn=`/`pos=`, nc `zero-read
ticks=`), which the same sentence states; the **marker** lines are identical in
72/72 sweep-2 runs (verified). No pinned byte is affected.

**F5 (NOTE, marker readability — the node-body joint trap's discriminating
evidence is behind the sha).** `sj_node_init@gp` and `sj_node_init@jolt` both pin
`space_a=RID(0),space_b=RID(0)`, so the marker alone cannot show that GP drops
the joint and Jolt binds it. The behavior is real and verified from this seat's
child logs (GP: `y` falls 2.0 → 1.821 over 12 ticks; Jolt: `y` **rises** 2.0 →
2.796 toward the anchor), and a future engine that bound the joint on GP would
still redden the row via the sha. The report's parenthetical is accurate
behaviorally; the pin surface is simply weaker than the prose. Convergent: the
sibling critic filed the same observation as its F2 (independently, from its own
re-derived logs).

**F6 (NOTE, timeout layering — a stall costs 14 s inside a 20 s case bound).**
The stalled `thread` row still completed at **16.57 s** (vs ~3.3 s nominal), so
it fit inside `CASE_TIMEOUT_SECONDS = 20`; **two** stalled children in one row
would exceed the bound and turn the row into a battery-level TIMEOUT. Same
family as r95 reviewer F6 (child bounds do not scale with host load); worth a
flake-list note rather than a change.

**F7 (NOTE, precision of `raw_eq`) — the GP `raw_eq=1` claim is cross-receipt
raw byte-identity plus `warn=0`, while the digest input is normalized.**
Verified true as measured (`cmp` r1==r2==ref on the raw GP logs), but "raw"
should not be read as "digest input == raw file" — the digest drops the banner
and the RID-leak lines in every receipt.

**F8 (NOTE, where the gate lives — recorded so the next auditor is not misled,
and convergent with the sibling simplifier's F-2).** The arm's own PASS/FAIL
gate is **child health + the arm's internal equivalences**; the *value* pins are
enforced by the battery's exact-marker comparison. Measured: `D1` (dummy slot
runs GP) and `G1` (slop 0.1→0.2) print `PASS` at arm level but **FAIL** in the
battery, and a non-allowlisted `WARNING:` line does not fail the arm (it changes
the sha; only the battery row catches it), whereas an `ERROR:`/SCRIPT ERROR line
does fail the arm (`ue`). This is the same layering as r93–r95 and is not a
defect; the fixture header's sentence "anything else … fails the arm" is
imprecise for the plain-warning class (the sibling simplifier filed the same
observation as F-2 in `dda3e7e`, independently, with the same mechanism).

---

## Residual risk / verification gaps

- **No LSP device** (`rea` only): symbol-level checks unavailable; none needed
  (this seat made no edits; all nine fixtures parse and execute).
- **Cross-build.** Every pin is receipt-derived for
  `4.7.2.stable.arch_linux.ed1daf0bf` on this host; the report is honest that
  hashes are build-scoped (the corpus convention from r89–r95). No tolerance
  story, inherited.
- **F1's rate is one observation.** This seat saw the threaded-child stall
  **once in 13 row executions** (1 of 4 full batteries + 1 of 2 `--only` runs +
  8 focused reps + 3 fresh-sweep reps) and **0 times** in 6 standalone child
  reps; the author saw it **0 times** in 7 battery runs and 108 arm runs. The
  class is therefore real but rare, and its rate is a loaded-window estimate,
  not a bound. It is fail-closed.
- **Unpinned run-variable surfaces** (by design, documented): the Jolt warning
  count/positions, the nc impulse zero-read ticks, and the `#` diagnostic lines
  generally. Verified non-pinned: my runs show 0/324 zero-read ticks in 3/3
  fresh reps and 39/324 in one sibling simplifier probe — the pose surface never
  moved.
- **Not re-measured here:** the eight probes' internal physics cases beyond the
  cells the fixture pins (the probes are byte-identical to the scout's, whose
  receipts the boundary falsified; this seat verified the *fixture's* use of
  them, not every probe case in isolation), and the ~15 mm GP/Jolt rebound-apex
  gap / baumgarte rate formula that the author explicitly did **not** author.
- **Concurrency disclosure.** Four to five batteries (mine plus the sibling
  wave-B seats' full batteries) ran on the same 32-core host throughout; the
  loadavg range 55–86 is recorded per run in the receipts. F1 was observed in
  that window; the fresh arm sweep, the 8-rep thread sweep, and all four full
  batteries were also run in it and passed.

## Recommendation (not a judgment — the canonical runtime judges)

**ADMIT-recommend.** The committed landing is sound as scoped. The diff is
insertion-only with zero existing bytes touched; all nine fixtures parse and the
runner compiles; the eight probe copies are byte-identical to the scout's
sources and are run under their original `res://` names; the census is exact
(316 = 257+59, 12 r96 rows at CASES 304–315, 160 children/pass); the author's
six battery receipts are for the committed bytes (83/83 seed digests each) with
all 12 r96 rows green in every one; the committed markers reproduce byte-for-byte
in **36/36** fresh arm runs, in **8/8** focused thread reps, in the r96
`--only` rows (**11/12** then **12/12** — the single miss is F1), and in **four
full 316-case batteries** (r96 rows green in all four); an **independent normalizer** recomputes **279/279** pinned cell shas from
raw child logs; and the three mandated encodings are each falsifiable and
falsified-by-mutation — the warning allowlist is load-bearing in vivo (A1/A2,
with the drop independently reproduced), the `--time-scale` law is a measured
cross-project identity (C1, plus six cross-row sha equalities), and the Dummy
vacuity/hang pins are live (D1/E1, plus a direct-child hang measured at
`rc=137` with a 10–21 MB log). The findings are one LOW–MEDIUM row-stability
item (F1: a rare threaded-child stall under batch spawn + heavy load, fail-closed
and unobserved standalone), one claim-precision item (F2: "27 MB" → 10–21 MB
measured), one receipts-hygiene item (F3: the superseded 3-rep sweep1), and
five notes. **No finding touches a physics pin.** The F1 fold (file the class
with its rate, and/or re-run a cell whose child exits `rc=137`) belongs to the
author/adjudicator, not to this seat.

**Blockers:** none (the dispatched `ufo-labrat` probe was unusable — no exec
tool — and is recorded as such, not as evidence).

Stopping here.

---

## Receipts index

`corpus/live/r96-reviewer/` (gitignored; 837 MB): `RECEIPTS.md` (index),
`audit/` (diff shape, census, custody, claim audit, verify-shas, normalizer
transcripts, thread-run1 scratch census), `fresh/` (36 arm runs ×3 reps with
archived child logs), `thread-sweep/` (8 focused reps), `batt-only/` (2 × 12-row
`--only`), `batt-full/` (4 full 316-case runs), `mutants/` + `mutants-batt/`
(arm- and battery-level mutation probes with logs), `direct/` (Dummy hang with
and without `--fixed-fps`; threaded `iters stack` standalone), and the seat's
tooling (`driver.py`, `normalize.py`, `verify_shas.py`, `mutants*.py`,
`hang_probe.py`, `thread_probe.py`, `audit_claims.py`, `run_batt.sh`).
