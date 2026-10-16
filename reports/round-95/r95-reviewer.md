# r95 reviewer — surgical correctness review of the committed Bullet/pybullet landing (`0767b59`)

Seat: **GAME-DEV-3D r95 REVIEWER**. Reviewed artifact:
`0767b5900f38949b6e077b0ab8317480f66166f8` ("r95 author: 20 bullet/pybullet rows
(304 total) — vendored .so byte-pinned, DIRECT-scoped purity + SHM pump-live
class, order non-neutrality; 304/304 x2") — `corpus/fixtures/r95_bullet.gd`
(+196, new), `corpus/fixtures/r95_child.py` (+1673, new),
`corpus/fixtures/r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so`
(new binary, 7 063 864 B), `corpus/fixtures/run_battery.py` (+40),
`reports/round-95/r95-author.md` (+81). Claim document:
`reports/round-95/r95-author.md`; context documents `reports/round-95/r95-scout.md`
and `reports/round-95/r95-boundary.md`.

**No commits, no tracked writes by this seat.** Receipts live under
`corpus/live/r95-reviewer/**` (gitignored via `corpus/.gitignore: live/`; see
`RECEIPTS.md` there). The only new repo file is this report.

**Byte custody.** At seat start `HEAD = 0767b59` and `git status --porcelain`
was clean except untracked `reports/round-94/r94-reviewer.md` (a sibling seat's
file). The measured tree is `git archive 0767b59` extracted to
`/home/vgpnk/.cache/r95-reviewer/tree0767b59`; archive shas == `git show` shas
(`r95_bullet.gd f988ba86…`, `r95_child.py 8821ebd5…`, `run_battery.py 0b9b7035…`,
`r95vendor/…so eca749a0…`, `r95-author.md c2393aaf…`; receipt
`audit/vendor-and-witness.txt`). Every measurement below ran from that archive,
from a scratch copy of it, or from a `/tmp`-free seat-owned mutant of it; the
worktree was never used as a seed source. **`/tmp` is a 16 GiB tmpfs at 80 %
(3.1 GiB free) on this shared host** — the first `git archive` extraction there
died with `Cannot write: Disk quota exceeded`; scratch was moved to
`/home/vgpnk/.cache/r95-reviewer` (793 GiB free) and no /tmp path is used below.

**Mid-seat drift (sibling lanes, contained).** Sibling wave-B seats ran
concurrently throughout (the r95 critic's `corpus/live/r95-critic/rowflip-shm/`
probe was executing **the same `r95_bullet_shm` row** during part of this
review — see F1/R6), and committed their reports during the seat:
`faa5ec8` simplifier, `fa7e951` critic, `fd6db99` verifier — **reports only**:
`git show HEAD:corpus/fixtures/{r95_bullet.gd,r95_child.py,run_battery.py}` are
sha-identical to `0767b59`'s, so the reviewed bytes are still the committed
bytes. The worktree's `run_battery.py` now carries an uncommitted **+30-line
r96 block** appended by the r96 lane (not this seat). No tracked file was
modified by this seat.

**Runtime / reroute check.** `which -a godot` → `/usr/bin/godot` only
(`4.7.2.stable.arch_linux.ed1daf0bf`, matching every receipt banner);
`/usr/bin/python3` → `3.14.7` (the version pinned in every M0/PASS line); no
`GODOT_*` env vars; no `resume_continuity` surface in this lane
(`grep -rn resume_continuity corpus/fixtures/` = 0). Host load during this
review: 49–90 (no seat-owned hogs; the "load preferred" gate is satisfied by
ambient load, recorded per run in the receipts).

**LSP note (recorded gap).** MCP inventory on this substrate = the `rea` server
only; no `lsp` device answers these files. This seat made no edits, so no
symbol-level work was required; text/AST checks (`--check-only`, `py_compile`,
AST census, char-level diff) are the available substitutes.

**probeParent seat.** Exactly one `ufo-labrat` was dispatched (bounded
pin-provenance probe: vendor sha, direct-child witness, `dtBits` arithmetic).
It returned **BLOCKED — its profile exposes no exec/shell tool**, so it measured
nothing; it is recorded as an unusable probe, not as evidence (the third seat in
this train to hit the same blocker: r93 reviewer, r95 boundary §9 note 6). Its
three intended measurements were performed by this seat with the exec tool
(`audit/vendor-and-witness.txt`): (a) the vendored `.so` sha256 is
`eca749a0…be3693` as claimed; (b) `r95_child.py det_base` run directly under
`/usr/bin/python3` prints `h=02309c52da41ef33` 3/3; (c) `1/240` is
`3f71111111111111` as a double and `3f71111120000000` when f32-rounded first,
so the `dtBits` discriminator is arithmetically sound. No other descendants
were spawned.

**Method.** (1) Committed-diff shape (numstat + char-level prefix/suffix +
line-level opcodes). (2) Parse checks on the canonical runtime. (3) AST census
of `CASES`, the fixture's `ARM_CASES`/`NEGATIVE`, and the child's `CASES`.
(4) **Fresh arm sweep**: 20 arms × 3 reps = 60 runs from a scratch copy of the
archive at load 83.8–86.7. (5) **`run_battery.py --only`** on the 20 r95 rows
× 3 reps, plus 6 single-row `--only r95_bullet_shm` reps. (6) **Full 304-case
battery × 2** from the clean archive. (7) **Mutation probes** of the digest gate
(physics constant, stray print, raised exception) run through the battery.
(8) **Vendor provenance**: `strip --strip-debug` of the scout's venv artifact
reproduced the vendored sha byte-exactly; stripped-vs-unstripped contract-line
equivalence re-checked over the author's 52-case receipts. (9) **Receipt
integrity** of the author's own run/rep receipts (`/tmp/r95*`,
`corpus/live/runs/2026101*`). (10) **Claim audit**: every hash and ≥5-char
number in the report's arm table machine-matched against the committed markers.
(11) **SHM flake probe**: 43 standalone arm executions, 11 battery-path
executions, 2 quiet windows (12 reps total), 22 direct-child executions, and a
passive concurrency correlation. (12) Citation audit of the five boundary
corrections.

---

## Verified independently

1. **Diff shape — insertion-only, zero existing bytes touched.**
   `git diff --numstat f8946a8 0767b59` = `196/0`, `1673/0`, `40/0`, `81/0` plus
   the new binary. A linear prefix/suffix comparison of the two
   `run_battery.py` blobs gives **common prefix 226 918 chars, common suffix
   26 317 chars, old middle empty, new middle 21 404 chars**; line-level
   opcodes = exactly one `insert old[698:698] new[698:738]` (the 10-line comment
   + 20 tuples). No replace/delete anywhere, and no existing byte changed.
   The r95 block is contiguous at CASES indices 284–303, immediately after
   `r94_cannon_neg_grid`.

2. **Parse.** `godot --headless --check-only --script res://r95_bullet.gd` →
   rc 0 (banner only, no Parse Error); `/usr/bin/python3 -m py_compile
   corpus/fixtures/r95_child.py` → rc 0.

3. **Census.** CASES = **304 = 245 ordinary + 59 negative**; r95 = **20 rows
   (14 ordinary + 6 negative)**. The fixture declares **14 arms → 46 unique
   positive cases** and 6 negative arms; the child's `CASES` table has **52
   keys = those 46 + the 6 negatives**, bijective in both directions (no
   orphan arm case, no unused child case). 52 fresh `/usr/bin/python3` children
   per battery pass, confirmed by counting 52 `r95ch_*` directories in the
   author's run-2 scratch. All 20 rows carry `o=0` in their committed markers.

4. **Vendor bytes are exactly the scout's build, stripped.** sha256 of
   `r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so` =
   `eca749a0d9b53964dca06764300c3481f328dc4cd1499a60e287393972be3693`, equal to
   the report's claim; `strip --strip-debug` applied by this seat to
   `corpus/live/r95-scout/venv/lib/python3.14/site-packages/pybullet.…so`
   (`c035ebaf…`) reproduces that sha **byte-for-byte** (91 047 408 → 7 063 864 B).
   The author's output-equivalence claim re-verified from their own receipts:
   `/tmp/r95run` (stripped) vs `/tmp/r95orig/out` (unstripped) — contract lines
   identical over **52/52 cases**. The `.so` is in the battery's `seed_digests`
   map.

5. **The author's three receipts verify, and they ran on final bytes.**
   r95-only pre-run `20261015T224412369946Z` = **20/20 PASS**;
   full run 1 `20261015T224443567926Z` = **304/304**; full run 2
   `20261015T232218926492Z` = **304/304**; `seeds_unchanged=true` in all three.
   All **74 seed digests in each receipt match the committed blob content
   exactly** (recomputed with `git show 0767b59:…`), including the vendored
   `.so` — so the runs are receipts for the committed bytes, not for a
   drift-ahead worktree.

6. **Fresh arm sweep reproduces the committed markers byte-for-byte, under
   load — except the `shm` arm.** 20 arms × 3 reps (60 runs) at load 83.8–86.7:
   **57/60 exact committed stdout line, empty stderr, correct rc** (14 arms
   rc 0, 6 arms rc 2). Per-arm stdout is byte-identical across all 3 reps for
   **19/20 arms**; the exception is `r95_bullet_shm` (0/3 — F1). Receipt:
   `corpus/live/r95-reviewer/fresh/` (`sweep-results.json`, 60 `.out`/`.err`).

7. **`--only` on the 20 r95 rows: 3/3 reps 20/20 PASS**, executed markers ==
   committed markers, `seeds_unchanged=true` (`batt-only/`). A further 6
   single-row `--only r95_bullet_shm` reps: **5 PASS / 1 FAIL** (`batt-shm/`,
   the FAIL is rep 5 with `shm_step … d=10`).

8. **Full 304-case battery from the clean archive, ×2.** Run 1
   (`batt-full/20261015T233308509709Z`, load 83→50): **303/304**, the single
   fail being `phys3d_events_deferred_hang` (`exit 1 != expected 0`); run 2
   (`batt-full2/20261016T000216446989Z`): **303/304**, the single fail being
   `phys3d_events_script_size_gate`. Both are on the on-record load-flake list
   (r92-verifier2, r93-baseline F1/F2, r93-baseline2 run 1/2, r93-author run 2
   trio). **All 20 r95 rows PASS in both reps** with markers exact,
   `seeds_unchanged=true`; slowest r95 row 4.12 s against the 20 s case bound.
   Receipts: `batt-full-run{1,2}.log`, `batt-full*/`.

9. **The digest gate is non-vacuous (mutation probes through the battery).**
   In seat-owned mutants of the archive tree:
   - `G = -9.82 → -9.83` in the child: `r95_bullet_det` FAILs (marker mismatch;
     the live hash moves `02309c52da41ef33 → 7b314804ff9dc209`, `z@1`
     `4.99982951 → 4.99982934`) **and** `r95_bullet_neg_dt` FAILs too, because
     the negative marker embeds the hashes it discriminates
     (`02309c52da41ef33->3e5afa1e3405090d`) — the negative rows are
     hash-pinned, not class-pinned.
   - A stray `print("stray-print-probe")` in `c_det_base`: the digest cell moves
     `d=1 → d=2` with `o=0` (see F2), which is a marker mismatch → FAIL.
   - `raise RuntimeError` in `c_det_base`: the child emits its `ERROR:` line,
     the cell becomes `rc=1,o=1` → FAIL.
   Receipts: `mutations/`, `mutantA/…/verdicts.json`.

10. **Claim audit — the report's arm table is value-accurate.** Every 8–16-char
    hex token and every ≥5-char number in the report's 14 ordinary arm rows
    appears in the matching committed marker; **0 unmatched tokens** (the
    reverse direction was spot-checked by hand on ~20 high-risk claims: canon
    pin/`z480`/`cc=13`, order non-neutrality `76988acc55682c1a`, iters lattice
    incl. `iters0 z=-10.6855237`, substeps lattice, `detpairs` scoped pair,
    perturb track `4.466e-14@240`/`6.804e-13@480`, saturated `h960≠h961`,
    freeze `-1`/`80`, rt inert/idle/paced, shm `eqPin`/`fell`, `an=EMPTY` +
    `an=i0/n1/it2` + `iters=2` sleep lattice, dt/field NaN lattices
    (`where=0.p+0.q+1.p+1.q`, `fff8000000000000`), mass/damping gates
    (`dynMass=1`, `d=1.5 → z=4.27577737`), 1-ulp `ulpEq=False` + per-pair
    hashes, `stored=11,1`, `eqBase=9/9` vs 8 loud knobs, SI/PGS/DANTZIG,
    `d=4` solver-switch diagnostic, pile `daf67ba7…`/`a272ef21…`/`38cb1231…`/
    `99d3fdf6…`, `nfields=12`, gravity-write landing step). Receipt:
    `audit/claim-audit.txt`, `audit/committed-markers.txt`.

11. **The five encoded corrections match their boundary sources.**
    `rt_*` DIRECT-scoped inertness + `shm_rtclass`/`neg_shm_rt` pump-liveness
    (boundary §2 table: SHM rt=1, idle 2 s → `z=0.49999` ⇒ `fell=True`) ✓;
    creation-order non-neutrality `eq=False` (boundary §7 "order-probe
    eq=False") ✓; `deterministicOverlappingPairs` 5-body-neutral
    (`daf67ba7…`) vs pile-loud (`a272ef21…`) = boundary §0 row 4 verbatim ✓;
    1-ulp friction `ulpEq=False` with exact commutativity (boundary §7
    "product combine rules with the 1-ulp caveat") ✓; `EMPTY`-analytics
    calibration on maximal coords (`an=EMPTY` + frozen body = boundary §0
    row 6 "sleep-force-max") ✓; `freeze_scene 3000/3000` never fixes
    (boundary's 20 000-step extension) vs `freeze_ball freezeStep=80` ✓.

12. **The child's negative controls prove a live control first and can only
    reject on the intended condition** (`c_neg_dt` compares two hashes;
    `c_neg_order` forward vs reverse; `c_neg_radius` requires all three of
    `{-0.5, 0, NaN}` to throw while `+inf` is accepted; `c_neg_simtime`
    requires `TypeError` ×2 with a legal `numSolverIterations` control;
    `c_neg_badid` requires 3 refusals; `c_neg_shm_rt` contrasts DIRECT-rt=1
    idle-frozen against SHM-rt=1 idle-fallen). A future engine that stopped
    refusing would exit 0 and the parent's `rc == 2` gate would FAIL loudly.

13. **Direct-child, Godot-free reproduction of the witness** (`det_base` ×3 on
    the vendored bytes) prints the pinned `h=02309c52da41ef33` with the pinned
    `M0` header (`api=202010061`, `dtBits=3f71111111111111`,
    `build="Oct 15 2026 03:47:36"`), so the pin is a live engine measurement
    and not a restatement of the child's `PIN_BASE` literal.

---

## Findings (severity order)

**F1 (MEDIUM, artifact robustness — the `r95_bullet_shm` row is a single-value
pin on a racy engine diagnostic count, and the documented flake-class model for
it is falsified).** The row pins `shm_step{…,d=8}` and `shm_rtclass{…,d=44}`.
Measured by this seat: the physics cells were **byte-identical in every
execution** (`h=02309c52da41ef33 eqPin=True`, `rtflag=1 idle2.0s fell=True`),
while the `d` counts moved: `shm_step ∈ {8, 10}`, `shm_rtclass ∈ {42, 44, 46,
48}`. Row-level outcomes:

| path | reps | marker mismatch |
|---|---|---|
| standalone arm runs (fresh + reused scratch, load 52–87) | 43 | **23** |
| battery path (`--only`, full) | 11 | **1** |
| quiet windows (0 concurrent `r95_child` on the host) | 12 | **0** |

Of the 43 standalone reps, **27 are file-backed** (`fresh/sweep-results.json` +
`shm-probe/` `rep*.out`, 18 of them mismatched) and 16 are console-transcribed
loops (5 mismatched; the last 4 are file-backed under `shm-probe/quiet/`). In
**all 43 arm runs and all 22 direct-child runs the `shm_step` physics cell read
exactly `h=02309c52da41ef33 eqPin=True`** — only `d` moved.

The mechanism is **not** the one the report states. `r95-author.md` §"Known
flake classes" says "the total byte count — and thus the line count — is fixed,
and 50 ms settle sleeps after every SHM connect/disconnect land the prints
before the drain". Falsified: the `d=8` runs carry **440** bytes of `#` content
(2 × `removed shared memory`, 3 × `detached shared memory`) and the `d=10` runs
**682** bytes (4 removed, 5 detached) — i.e. **two extra engine
`PosixSharedMemory::releaseSharedMemory` teardown pairs** appear in the larger
payload. So the count is a race in the engine's shared-memory teardown path, not
a fixed-byte-count artifact of the drain. (The sibling critic reads the same
payloads as partial-line writes whose tail lands relative to the child's single
end-of-run drain; both readings agree on the two facts that matter — the byte
count is **not** fixed, and the extra `releaseSharedMemory` output is what moves
`d`.) The author's own nine observations
(3 battery passes, 3 fixture reps in `/tmp/r95marks`, 3 child reps in
`/tmp/r95rep/*_s*`) all read `8`/`44`, so "304/304 ×2" does **not** establish
this row's stability; the pin's observed mismatch rate here is 23/43 (53 %) on
the standalone path and 1/11 (9 %) on the battery path, with 12/12 matches in
the two quiet windows. The row fails **loudly** (exact-marker mismatch), so no
wrong physics can pass — the exposure is row instability under the shared-host
conditions the wave-B gate itself mandates. This is the same class the sibling
wave-B seats filed independently and converged on (critic F1 MEDIUM 8/12 loaded
window; simplifier F-1 MEDIUM 5/11; verifier "SHM d-drift fail-closed"), so it
is a round-level fold, not a claim of this seat alone. Fold candidate for
author/adjudicator (all three seats agree): envelope the `d` pin, drop `d` from
the two `shm` cells while keeping `o=0` + the physics cells, or make the drain
deterministic (drain twice around a longer settle). Receipts:
`fresh/sweep-results.json`, `shm-probe/`.

**F2 (LOW, claim precision — the `o`-surface description is wrong about which
counter a stray print moves).** `r95_bullet.gd:13-16` and `r95_child.py:19-21`
describe `o` as the surface any "python traceback, stray print, or unexpected
warning" moves. Measured (mutant B, through the battery): a stray
`print("stray-print-probe")` inside a case moves **`d` 1 → 2** and leaves
`o=0`, because both fds are captured for the whole process and re-emitted as
`#` lines. `o` is reachable only through the child's own `ERROR:` path (mutant
C: `rc=1,o=1`) or a direct write to the duplicated original stdout. No pinned
byte is wrong and the row still fails loudly; minimal fix is a wording change in
the report/fixture header ("moves the `#` count; `o` is the child's error
surface").

**F3 (NOTE — the flake-class section understates the class and mis-attributes
it; the driver is in-process scheduling pressure, not cross-process SHM
churn).** The class is real and independently convergent across the wave-B
seats: this seat's loaded-window rate is 23/43 standalone reps (53 %) and 1/11
battery-path reps; the r95 critic measured **8/12** row failures in a loaded
window (`shm_step` 8/64, `shm_rtclass` 4/26 child-level off-pin), the r95
simplifier **5/11** reds, and the r95 verifier **2/6** arm-level drift with
78/80 marker-exact standalone — while every one of those seats, like this one,
saw the `m`-surface byte-identical. My own earlier correlation with concurrent
SHM processes is **withdrawn as a driver**: the critic ran a controlled
cross-process-SHM-churn window (0/32 off-pin) and §1.9 confirms the transport is
process-self-contained, so the driver is scheduling pressure inside the child's
own process. My two `ps`-verified quiet windows (12/12 on-pin) and the critic's
quiet window (0/12) are consistent with that reading. The author's nine
observations all landed in calm windows, which is why the class reads as
"pathological" rather than "expected under load".

**F4 (NOTE, artifact strength, recorded) — negative markers are hash-pinned.**
`r95_bullet_neg_dt` fails under the gravity mutation because its marker text
embeds the two hashes it discriminates. That is stronger than a class-only
negative and worth keeping; it also means a physics drift reddens two rows, not
one (mutation receipt `mutantA/`).

**F5 (NOTE, artifact format — `m` cells are comma-delimited but carry commas).**
The `{rc=…,m=…,o=…,d=…}` cells embed commas (`ids1=0,1,2,3,4`,
`stored=0.5,0.5`, `n=[1,0,0/d=-1]`, `where=0.p+0.q+1.p+1.q`). The battery does
exact whole-line matching, so nothing breaks today; any downstream cell parser
must not split on commas (same class as the r93 reviewer's F7 / r94's F5).

**F6 (NOTE, timeout layering).** Each child is bounded by `timeout -s KILL 15`
and each battery case by `CASE_TIMEOUT_SECONDS = 20`, but an arm can spawn 13
children (`det`), so an arm's worst case far exceeds the case bound. A hung
child converts to a loud FAIL (`rc=137`/`rc=None` → digest mismatch), never a
silent pass; observed slowest r95 row is 4.12 s (load 83), so there is ~5×
headroom.

**F7 (NOTE, artifact robustness — `d` is a pinned count, which is what makes
F1 fail).** Recording the deliberate design so the adjudicator can weigh it:
pinning `d` per cell is what catches an unexpected engine print (the desired
direction) and also what turns an engine teardown race into a row failure.

---

## Residual risk / verification gaps

- **No LSP device** (`rea` only): symbol-level checks were unavailable; none
  were needed (this seat made no edits, and both fixtures parse and execute).
- **Cross-build.** Every pin is receipt-derived for
  `4.7.2.stable.arch_linux.ed1daf0bf` + `/usr/bin/python3 3.14.7` +
  `pybullet 3.2.7` (vendored, btScalar=f64, `dtBits=3f71111111111111`). The
  report is honest about this: hashes are build-scoped and `M0` carries the
  discriminator; the float-rebuild hashes are deliberately not authored. No
  tolerance story (inherited from r89–r94).
- **SHM stepped-path non-reproducibility** stays `#`-diagnostic only (correct:
  the boundary's 3-reps-3-hashes did not replay here; this seat's `shm_step`
  physics cell reproduced the pin in every one of 43 arm runs and 22 direct
  child runs, i.e. the *stepped rt=1* divergence was never observed — only the
  teardown print count moved). The negative row therefore rejects via the
  robust pump-liveness contrast, as designed.
- **R6 (disclosure) — the worktree is not frozen and wave-B siblings ran the
  same row concurrently.** `corpus/live/r95-critic/rowflip-shm/**` was executing
  `r95_bullet_shm` while this seat measured it, and this seat's own repeated SHM
  probes ran while the sibling measured theirs. Per F3 that mutual concurrency
  is **not** the driver (the critic's controlled cross-process-churn window was
  0/32 off-pin), so the F1 rates are not inflated by it; they are the rates of
  the loaded windows both seats measured. The three sibling wave-B commits are
  report-only and the r95 fixture bytes are sha-identical at `HEAD` and
  `0767b59`. Every measurement above is pinned to `0767b59` via
  `git archive`/`git show`, so a later HEAD move does not invalidate this
  review.
- **/tmp is a shared 16 GiB tmpfs at 80 %**; sibling batteries write there.
  This seat used no /tmp path for its own work after the first extraction
  failure, and the failure is recorded so a future seat does not mistake it for
  a repo problem.
- **Documented non-pinnables** (fixture header + report, consistent with the
  boundary): SHM stepped hashes, measured idle-fall distances, TCP/UDP
  transports, float-`btScalar` hashes, raw NaN payload bits. All are `#`-only
  or absent from the pins.

## Recommendation (not a judgment — the canonical runtime judges)

**ADMIT-recommend.** The committed landing is sound as scoped: the diff is
insertion-only with zero existing bytes touched; both new fixtures parse and
compile; the vendored engine is provably the scout's build with
`strip --strip-debug` applied; the census is bijective (14 arms → 46 positive
cases → 52 child cells); 19 of the 20 r95 rows reproduce **byte-for-byte** in
60/60 fresh arm runs (the 3 misses are all the `shm` row — F1) and all 20 rows
pass 3/3 twenty-row `--only` battery passes; two full 304-case
battery passes from the clean archive give 303/304 each with every failure on
the documented flake list and r95 20/20 in both; the digest gate is proven
non-vacuous by three mutation probes; and every hash/number in the claim
document matches a committed marker. The findings are one MEDIUM robustness
item (F1: the `shm` row's `d` pin is a race in the engine's SHM teardown, with
the report's byte-count model falsified and its rate optimistic) plus claim
precision (F2) and artifact notes (F3–F7). **No finding touches a physics pin**;
the exposure is row-level stability under shared-host load, and the row fails
loudly rather than silently. The F1 fold (envelope the `d` pin or file the class
with its measured rate) belongs to the author/adjudicator, not to this seat.

**Blockers:** none.

Stopping here.
