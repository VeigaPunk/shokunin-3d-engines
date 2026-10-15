# r93 reviewer — surgical correctness review of the committed areasig landing (`661749f`)

Seat: **GAME-DEV-3D r93 REVIEWER**. Reviewed artifact:
`661749f2039a4435da6a4cc85c850d829fa10fe6` ("r93 author: 7 areasig rows
(265 total) — in_step signal law, queue_free post-E, monitoring-in-dispatch
refusal, GP/Jolt splits, Dummy vacuity; 265/265 run1") — `corpus/fixtures/r93_areasig.gd`
(+219, new), `corpus/fixtures/r93_child.gd` (+875, new), `corpus/fixtures/run_battery.py`
(+28/−1), `reports/round-93/r93-author.md` (+79). Claim document:
`reports/round-93/r93-author.md`.

**No commits, no tracked writes by this seat.** Scratch is `/tmp/r93-reviewer/`;
receipts under `corpus/live/r93-reviewer/**` (gitignored via
`corpus/.gitignore: live/`). The only new repo file is this report.

**Byte custody.** At seat start `git status --porcelain` was clean except an
untracked `r94vendor/`; the reviewed blobs were sha-verified against the commit
(`r93_areasig.gd e4b04006…`, `r93_child.gd fac6b439…`, `run_battery.py 81fb07ff…`,
`r93-author.md e0e83be3…`). **Mid-seat drift (sibling lanes, contained):** the
r94 lane added untracked seeds and then appended its `r94_cannon_*` rows to the
*worktree* `run_battery.py` (uncommitted `M`, +38) while I worked, and sibling
seats committed `522cef99` (critic/scribe/simplifier/verifier reports) —
`HEAD` moved past the reviewed commit. To keep every measured byte at
`661749f`, the full battery below ran from **`git archive 661749f`** extracted
to `/tmp/r93-reviewer/tree661749f` (archive shas = commit shas), and all
fixture/battery parsing used committed blobs (`git show`) where the worktree
could have drifted. Every r93-armed measurement here is `661749f`'s.

**Runtime / reroute check.** Single canonical runtime: `which -a godot` →
`/usr/bin/godot` only (`4.7.2.stable.arch_linux.ed1daf0bf`, matching every
receipt banner); no `GODOT_*` env vars. No `resume_continuity` surface in this
lane (`grep -rn resume_continuity corpus/fixtures/` = 0). Host load ranged
~60–150 from concurrent sibling batteries; **all runs below were under real
load**, no own hogs except where noted.

**LSP note (recorded gap).** MCP inventory on this substrate = the `rea`
server only; no `lsp` device answers these files. Symbol-aware checks are
therefore text/AST-level (`ast` census of `CASES`, char-level diffs,
`--check-only`), not server-verified semantic proof.

**probeParent seat.** Exactly one `ufo-labrat` was dispatched (bounded
Jolt-order probe). It returned **BLOCKED — its profile exposes no shell/exec
tool**, so it could spawn nothing; it is recorded as an unusable probe, not as
evidence. Its intended measurement was performed by this seat with the exec
tool (the 24-rep order probe below). No other descendants were spawned.

**Method.** (1) Committed-diff shape via char-level comparison of the two
`CASES` bodies. (2) `--check-only` parse on the canonical runtime. (3) Fresh
arm runs in a seat-owned scratch copy of the committed fixtures: **7 arms × 3
reps = 21/21 exact-marker** at load ~100–115, plus **16/16 multi-arm reps** at
load ~121; then `run_battery.py --only` on the 7 r93 rows (7/7 PASS); then a
**full 265-case battery from the clean archive** (262/265). (4) Receipt
integrity: `sha256sum -c SHA256SUMS` (1304 files, rc=0), the author's
`digest.py --check` (54/54 cells, reps=8), 432 child-run count, mirrored
battery-verdict hashes vs the `/tmp` originals. (5) A **mutation probe** of the
expected-error floor gate. (6) A **24-rep emission-order probe** of the Jolt
`multi`/`bodysig` raw order. (7) A **non-fixed-fps drift check**.

---

## Verified independently

1. **Diff shape — insertion-only, one comma append at the splice point.**
   `git diff 661749f^ 661749f -- corpus/fixtures/run_battery.py` = 28 insertions,
   1 deletion. Char-level diff of the two files shows the *only* change to any
   prior line is `insert ','` at the end of the `r92_timing_steps` marker line
   (`...s=0}')` → `...s=0}'),`), required to append the new rows; all other 1104
   old lines appear unchanged and in order. The r93 block is exactly the 10-line
   comment + 7 tuples appended before `]`.

2. **Parse.** Both new fixtures `--check-only` rc=0 on
   `4.7.2.stable.arch_linux.ed1daf0bf` (Godot banner only, no Parse Error).

3. **Census.** `ast` census of the committed `CASES`: **265 = 218 ordinary +
   47 negative**; **7 r93 rows**; parent (661749f^) = 258 = 211+47. The
   fixture's `ARM_CASES` union is **18 cases**, matching the report's "18 cases
   × 3 backends = 54 child cells per battery pass" (54 `r93t_*` child projects
   observed in scratch after one pass).

4. **Fresh runs reproduce the committed markers byte-for-byte, under load.**
   - 7 arms × 3 reps (21 parent runs = 63 children): **21/21 exact stdout
     marker**, exit 0, empty stderr; load 100.8 → 114.9
     (`fresh/20261015T213657396655Z`).
   - `multi` arm × 16 extra reps: **16/16 exact**, load ~121
     (`fresh/20261015T214504337161Z`).
   - `run_battery.py --only <7 r93 rows>` on committed bytes: **7/7 PASS**,
     `seeds_unchanged=true` (`batt-only/20261015T214659406472Z`).

5. **Full battery from the clean `661749f` archive: 262/265, r93 7/7 PASS,
   `seeds_unchanged=true`** (`batt-archive/20261015T215805351730Z`). The 3
   fails are `navagent3d_retarget`, `navagent3d_retarget_fixed`,
   `navagent3d_follow` — the documented navagent 1-tick-miss flake class
   (r93-baseline2 run 2, r92-verifier2 F1, r101 navagent dissection). **No r93
   row failed in any run by this seat.**

6. **Author receipts verify.** `sha256sum -c SHA256SUMS` rc=0 over 1304 files;
   `digest.py --check` = **54/54 cells `reps=8` OK** (each cell's digest,
   including `e/et/w/s`, byte-identical across 8 reps); 432 `*.stdout.txt` =
   8 reps × 18 cases × 3 backends as claimed; mirrored
   `battery/verdicts-run{1,2,3}.json` hash-match the `/tmp` originals.

7. **Battery-receipt arithmetic.** run1 **265/265 PASS**; run2 **262/265**
   (fails = the documented phys3d trio); run3 **260/265** (trio + the navagent
   pair). All seven r93 rows are **byte-identical (exit+stdout+stderr) across
   all three runs**; run1↔run2 deltas = exactly the trio + `r92_animphys_idlemode`;
   run1↔run3 = trio + navagent pair + `idlemode`. `seeds_unchanged=true` in all
   three.

8. **The "run 1 was a different child sha" disclosure is exact.** The run-1
   scratch child (`610905a0…`) vs committed (`fac6b439…`) diff is **one hunk**:
   the `#` order-diagnostic now appends `@<target>` (`by_pf[p].append("%s.%s%s" …)`).
   Diagnostics never enter M cells (parent `_scan` collects only `M0`/`M ` lines,
   verified in the committed source), and the 7 r93 battery rows are byte-identical
   across run 1 (610905a0) and runs 2/3 (fac6b439) — the surface-equivalence
   claim is sound.

9. **Expected-error floor gate is real (mutation).** Removing the monsig
   refusal write (`area_a.monitoring = false` in the `body_shape_entered`
   handler) in a `/tmp` copy flips the cell tail from
   `…e=1,et=Function blocked during in/out signal. Use set_deferred("monitoring", true/false).,w=0,s=0`
   to `…e=0,w=0,s=0` — the pinned marker rejects it. The `et=` field therefore
   enforces "the pinned refusal must fire, with the pinned text, and only that
   text" (counts 30/24/116/1/3/6 and texts reproduced verbatim in the markers).

10. **Backend splits reproduced from the committed markers** (and re-observed
    in fresh runs): `telefr` gp detected=0 vs jolt `detected=1 cls=no_if`;
    `monitoff` gp keeps the pair through the window vs jolt drops at pf=21 and
    re-detects at pf=27 (`# monitoff order` diagnostic); `freerid` `et` split
    gp `Invalid ID.` vs jolt `Failed to free RID: The specified RID has no owner.`;
    `bodysig` entry `bsi=0,1` gp vs `bsi=1,0` jolt; `moncycle` gp redetect=25 /
    jolt none; `monoff0` redetect=31 on **both** real backends. Dummy: every
    cell `nif=0`, `nsig=0` (vacuity pinned).

11. **Jolt order instability is handled honestly (independent 24-rep probe).**
    Raw `# multi order` at pf=21 on Jolt: **22/24 b1-first, 2/24 b2-first**
    (author receipts: 2/8 flipped; boundary: 7/57 ≈ 12%) — while the pinned
    `seqeq=-`/`pairs=-` surface stayed byte-identical. `bodysig` per-shape
    entry order (`1,0`) and exit sequence held **24/24** on Jolt, consistent
    with the author's 8/8 and the critic's 90/90. GP `seqeq=0 pairs=1` held
    8/8 + 19/19 fresh.

12. **`--fixed-fps 60` is load-bearing (verified).** Jolt `enter` children run
    without the flag drift `nf` = 104/105 vs the fixed `nf=43`, and their
    M-surfaces differ rep-to-rep (sha `6f6d8b…` vs `4c11d3…` vs `0f075b…`);
    with the flag the M-surface is byte-identical across reps. The pinned
    anchors (`pf=21/35`, `nf=43`) depend on the flag as claimed.

13. **Error floor counts reproduced verbatim:** `monoff0@dummy e=116`,
    `monoff@dummy e=24`, `monsig@dummy e=0`, `freerid@dummy e=0`,
    `moncycle@dummy e=0` — all match the report and the committed markers.

---

## Findings (severity order)

**F1 (LOW–MEDIUM, report accuracy) — the author report's arm→case table does
not match the committed `ARM_CASES`, and one row's prose describes a different
case's law.** `reports/round-93/r93-author.md:19-21` vs
`corpus/fixtures/r93_areasig.gd:66-68`:
- `writes` listed as `tif`, `tsig`; committed arm = `tif, tsig, monoff, monif`.
- `exits` listed as `freeq`, `freerid`, `moncycle`; committed arm = `freeq, freerid`.
- `dispatch` listed as `monsig`, `monif`, `monoff`; committed arm = `monsig, moncycle, monoff0`.
- Consequently `monoff0` never appears in the report table, and line 26's
  "18 cases total (the union above)" is false for its own table (union = 17).
- The exits-row sentence "`moncycle`: monitoring off→on cycle — cross-tick
  re-enable re-detects on both real backends" describes `monoff0` (off from
  init, re-enable at E(30) → redetect 31 on both). The landed `moncycle` is a
  **same-tick** off→on at E(24): GP redetects pf=25, Jolt never
  (`M moncycle facts … redetect=25` / `redetect=none`). The fixture header
  (`r93_areasig.gd:33-37`) has this right; the report table does not.
  The fixture and battery are self-consistent (battery cell counts confirm:
  writes 12 = 4×3, exits 6 = 2×3, dispatch 9 = 3×3), so this is report-only.
  Minimal fix: correct the three table rows and the count.

**F2 (LOW, fixture header claim) — `r93_areasig.gd:45` says the multi arm pins
"the per-backend entry_eq_exit boolean (GP=0, Jolt=1)", but the landed Jolt
cell carries `seqeq=- pairs=-` (deliberately unpinned; the child comment
`r93_child.gd:592-596` and the author report both say so).** The committed pin
is GP=0 only; Jolt's raw `1` is not in the battery. Minimal fix: reword to
"(GP=0; Jolt left free — order-unstable)". Text-only; touching the fixture
would change its sha and require an orchestrator commit.

**F3 (LOW, report accuracy) — correction #5 mislabels the second large Dummy
count.** `r93-author.md:65` says "`monoff0`/`monsig` Dummy diagnostic counts
are large (`e=116`, `e=24`)"; `e=24` is **`monoff@dummy`**; `monsig@dummy` is
`e=0`. The report's own line 44 has it right ("`monoff@dummy e=24`"). Fix: s/`monsig`/`monoff`/.

**F4 (LOW, report accuracy) — the "Resting heights" sentence conflates
case-specific fall samples with a GP/Jolt split.** `r93-author.md:45`:
"`by=3.9842` gp vs `by=4.8510`-family jolt". Verified: `by=3.9842` appears at
`enter` e44 on **both** gp and jolt; `by=4.8510` at `enter0` e34 on **both**.
The actual gp/jolt resting split pinned in the e-rows is `-0.0100` (gp) vs
`-0.0110` (jolt) in `areasig`/`monitoff`/`monoff`. Fix: state the −0.0100/−0.0110
split.

**F5 (LOW, report wording) — disclosure #4's `w` claim contradicts the pinned
cells.** `r93-author.md:64` says "the battery markers do not pin `w=0` for jolt
children", but every jolt cell in the committed markers ends
`…,w=0,s=0}` and is exact-line matched. What is true is that the job-system
warning is **excluded from the `w` counter** (`r93_areasig.gd:173-179`), so it
cannot violate the `w=0` pin. The same paragraph's "absent in serial/non-fixed
runs" also conflicts with the fixture's own "~25% of serial child runs; never
without the flag": my serial (one-child-at-a-time) probe saw the warning in
**9/48 = 18.8%** of `--fixed-fps` children and 0/3 without the flag. Fix:
"excluded from the count; fires intermittently in serial `--fixed-fps` runs,
never without the flag".

**F6 (NOTE, artifact precision) — `in_write` duplicates `flush_sigs`.**
`r93_child.gd:527-529` and `553-555` pass `flush_n` twice
(`flush_sigs=%d in_write=%d`), so the marker's `flush_sigs=2 in_write=2` is one
counter under two names, not two independent measurements. No wrong claim is
pinned, but a reader could take them as independent facts.

**F7 (NOTE, artifact format) — `et` values are not comma-safe.** The monsig
refusal text (`Function blocked during in/out signal. Use set_deferred("monitoring", true/false).`)
contains commas and quotes inside the comma-delimited cell
`{rc=..,m=..,e=..,et=..,w=..,s=..}`. The battery does exact whole-line matching,
so nothing breaks today; any downstream cell parser must not split on commas.

**F8 (NOTE, robustness) — `monif`'s `redetect` field can report the initial
entry.** `r93_child.gd:525-529` takes the last `body_entered` with `pf > 20`;
for `monif` the *initial* entry is at pf=21, so a failed re-detection would
print `redetect=21` rather than `none`. The pin (31) still fails on that
value, so detection is not weakened — only the field's label would mislead in
a failure mode.

---

## Residual risk / verification gaps

- **Order-dependent Jolt pins remain, with strong evidence.** `bodysig@jolt`
  (`bsi=1,0` + the exit sequence) is an emission-order pin on the backend whose
  per-body order is documented unstable (~12%). Independent observations:
  author 8/8, critic 90/90, this seat 24/24 — so it is filed as residual risk,
  not a defect. Likewise GP `multi` `seqeq=0 pairs=1` (order-dependent but
  GP-stable across every sweep: boundary 33/33, author 8/8, this seat 19/19).
  If Jolt's shape order ever flips, the `r93_areasig_multi` row fails loudly.
- **The job-system warning is invisible to `w` by construction.** The exclusion
  is documented and justified (engine-internal, load-shaped), but it means a
  future Jolt warning-text change would count as `w>0` and fail loudly — the
  desired direction. No other warning class appeared in any run by this seat.
- **Cross-build.** Every pin is receipt-derived for
  `4.7.2.stable.arch_linux.ed1daf0bf`; no tolerance story (inherited from
  r89–r92). The `nf=43` idle-frame pin and the `e=` counts are the most
  scheduler-sensitive cells, and both depend on the parent's hard-coded
  `--fixed-fps 60` child spawn.
- **"Twice green on final bytes" is met as run 1 (green, child 610905a0) +
  runs 2/3 (final bytes, documented flakes), not as two fully green runs on
  final bytes.** The author discloses this; the surface-equivalence argument is
  verified (item 8 above), and this seat's independent archive run on final
  bytes is 262/265 with only documented navagent flakes and r93 7/7 PASS.
- **No LSP device** (above): caller/definition checks are text/AST-level; the
  affected surface is small and both fixtures parse and execute.
- **The worktree is not frozen.** Sibling lanes edited `run_battery.py`
  (uncommitted r94 rows) and committed sibling reports (`522cef99`) during this
  review; every measurement above is pinned to `661749f` via `git show` /
  `git archive`. A later reviewer should re-pin to the new HEAD if the r94 rows
  are committed before adjudication.

## Recommendation (not a judgment — the canonical runtime judges)

**ADMIT-recommend.** The committed landing is sound as scoped: the diff is
insertion-only apart from the required comma, both fixtures parse, and all
seven r93 markers reproduce **byte-for-byte** in 37 fresh arm runs plus a full
265-case battery from the clean archive — under load, on the canonical
runtime — with the expected-error floor gate proven non-vacuous by mutation.
The findings are report/comment claim-precision (F1–F5) and artifact notes
(F6–F8); none touches a pinned byte. The minimal CHANGES set, if the judge
wants the claim documents exact, is F1–F5 text edits (report, plus the one
fixture comment in F2 that would re-sha `r93_areasig.gd`).

Stopping here.
