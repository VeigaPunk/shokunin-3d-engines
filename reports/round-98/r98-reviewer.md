# r98 reviewer — surgical correctness review of the committed gltflat landing (`b6d60b1`)

Seat: **GAME-DEV-3D r98 REVIEWER**. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r98-reviewer.md`.
Reviewed artifact: `b6d60b113513141aad60c4b2423f7c82d639c5e9` ("r98 author: 9
gltflat rows (333 total) — 137 cells cold-cache import lattice, 17 vendored
assets sha-pinned, 137/137 crosscheck; 333/333 x2") — 24 paths: the parent
fixture, 4 probe copies, 17 vendored assets, the `run_battery.py` insertion,
and the author report. Claim document: `reports/round-98/r98-author.md`;
context documents `reports/round-98/r98-scout.md`,
`reports/round-98/r98-boundary.md`.

**No commits, no tracked writes by this seat** — the only new tracked file is
this report. Receipts live under `/home/vgpnk/.cache/r98-reviewer/**` with a
gitignored pointer tree at `corpus/live/r98-reviewer/**` (nothing else was
written anywhere in the repo).

**Byte custody.** At seat start `HEAD = b6d60b1`; it moved mid-seat to
`938e4e4` (r98 scribe) and `24e9822` (r98 simplifier) — **both report-only**:
`git diff --name-only b6d60b1..HEAD` = `reports/round-98/r98-scribe.md` and
`reports/round-98/r98-simplifier.md` only, and the r98 seed blobs at HEAD are
sha-identical to `b6d60b1`'s (`r98_gltflat.gd`, `run_battery.py`,
`r98assets/tri.glb` spot-checked). The worktree additionally carries a
concurrent lane's **uncommitted** r99 insertion in `corpus/fixtures/run_battery.py`
(+29 lines, written 04:17 local, after this seat's measurements) and untracked
r99 seeds — not this seat's, and never used as a seed source here (the
measurements ran from `git archive b6d60b1`). The measured tree
is `git archive b6d60b1` extracted to `/home/vgpnk/.cache/r98-reviewer/tree`;
**all 24 changed paths sha256-verify equal to `git show b6d60b1:<path>`**
(including the 17 binary assets and the 6 text seeds; parent fixture
`47998a95bb0401f7…`, probes `18ba68b7065afdce…`/`4736126f3c148fb2…`/
`31cd69c1988b8cbe…`/`fadcf86c0c9dbd71…`, `run_battery.py`
`159ea6ba585e2278…`, `r98-author.md` `a21b21f19398092b…`). Every measurement
below ran from that archive, a scratch copy of it, or a seat-owned mutant of
it; the worktree was never used as a seed source.

**Runtime.** `/usr/bin/godot` only, `4.7.2.stable.arch_linux.ed1daf0bf`;
`/usr/bin/python3` 3.14.7; 32-core host. Load average read **52–73** at this
seat's checkpoints, with the host also carrying four sibling seats' full
333-case batteries (`r98-verifier`, `r98-scribe`, `r98-critic`), the
`r98-simplifier`'s focused runs, and the verifier's own arm re-runs. Per-run conditions are recorded with the receipts.

**LSP note (recorded gap).** MCP inventory on this substrate = the `rea` server
only; no `lsp` device answers these files. This seat made no edits, so no
symbol-level work was required; the substitutes used were `--check-only`,
`py_compile`, an AST census of `CASES`, a from-scratch normalizer/extractor,
and battery-level mutants.

**probeParent seat.** Exactly one `ufo-labrat` was dispatched (bounded
read-only probe: "falsify the cross-parent user-data seed-dir race"). It
returned a **usable static result** — it independently traced `APP`'s double
use, the pid-namespaced child dirs vs the un-namespaced `ud_dir`, the
cleanup-on-every-arm path, and the six-cell failure mode — but **could not
execute** (its tool surface has no exec/write tool; same capability gap as the
r96 train). Its dynamic phase is therefore "could-not-test", covered by this
seat's own repro below (F1). Advisory only, no edits.

**Method.** (1) Committed-diff shape (numstat + char-level prefix/suffix +
line-level opcodes + CASES AST census). (2) Parse checks on the canonical
runtime. (3) Cell/child census by dumping the committed fixture's own cell
tables and cross-counting marker tokens. (4) Probe provenance vs the
scout/boundary sources. (5) **Asset-pin verification**: all 17 vendored assets
against the boundary/scout manifest pins, plus a full-manifest integrity scan
of both live trees, plus raw asset-byte sniffing. (6) **Author-receipt
custody**: the 3 battery `verdicts.json` seed digests recomputed against the
committed blobs, and the 27 arm receipts compared byte-for-byte to the
committed markers. (7) **Fresh arm sweep**: 9 arms × 2 reps from clean scratch
copies of the archive. (8) **Independent normalizer**: a from-scratch
re-implementation of the declared drop rules + extraction semantics,
recomputing every pinned cell from raw child logs over three data sets. (9)
**Independent crosscheck** of this seat's children against the
scout's/boundary's own receipts under this seat's normalizer. (10) **Eleven
battery-level mutation probes** in seat-owned mutant trees (nine detections
across six rows, two by-design non-detections, plus one second-row
non-detection that is the content-blindness by design). (11) **One full
333-case battery** from the clean archive plus a focused `--only` pass of the
9 r98 rows. (12) **Claim audit**: every hex/decimal token in the author report
machine-matched. (13) **Race investigation**: an isolated two-parent repro of
the user-data hazard (below).

---

## Verified independently

1. **Diff shape — insertion-only, zero existing bytes touched.**
   `git diff --numstat b6d60b1^ b6d60b1` = 24 paths, 23 `A` and one `M`
   (`run_battery.py` 41/0), **no deletions anywhere**; every binary asset is
   `-/-` (new). A char-level comparison of the two `run_battery.py` blobs gives
   **common prefix 265 325 chars, common suffix 26 317, old middle 0, new
   middle 14 745**; line-level opcodes = exactly one
   `insert old[806:806] new[806:847]` (the 41-line comment + 9 tuples) placed
   immediately after the r97 block. The r98 block is contiguous at `CASES`
   indices **324–332**.

2. **Parse.** `godot --headless --check-only --script res://<f>` → rc 0 with no
   `Parse Error` for all five r98 fixtures; `python3 -m py_compile
   run_battery.py` → rc 0.

3. **Census — exact, and bijective with the markers.** `CASES` = **333 = 274
   ordinary + 59 negative**; r98 = **9 rows** (`load, doc, sniff, extbin, cls,
   write, tr, phys, var`), indices 324–332, no duplicate case names. Dumping
   the committed fixture's own `_arm_cells()` gives **131 generic cells**
   (load 21, doc 36, sniff 21, extbin 21, cls 12, write 3, tr 2, var 15) plus
   **6 phys cells** = **137 cells = 137 children per pass**; the committed
   markers carry exactly 137 cell tokens, name-for-name and in order (the
   normalizer asserts the bijection per arm, §8). Every cell = one bounded
   child; 8-way chunks; `timeout -s KILL 14` per child.

4. **Probe provenance — the four copies are the scout's/boundary's bytes, run
   under their original names.** `r98_probe_gltf.gd` = `live/r98-scout/probes/
   gltf.gd`, `r98_probe_gltf_tr.gd` = `…/gltf_tr.gd`, `r98_probe_r98b_inv.gd` =
   `live/r98-boundary/probes/r98b_inv.gd`, `r98_probe_r98b_mode.gd` =
   `…/r98b_mode.gd` — sha256-identical in all four cases. The fixture writes
   each copy into the per-cell project under its original `res://<probe>.gd`
   name, so a child receipt reproduces the source receipt (the backtrace-name
   hazard is avoided by construction).

5. **Asset pins — the xxd-clobber repair holds, and both manifests are intact.**
   - All **17/17** vendored `corpus/fixtures/r98assets/*` byte-match the
     boundary manifest pin (`assets/<name>`), and the 6 also present in the
     scout manifest match that pin too; the corresponding live files in
     `live/r98-boundary/assets/` and `live/r98-scout/assets/` are byte-identical
     to the vendored copies. **0 problems.**
   - The disclosed repair target `badmagic_badjson.glb` is
     `6e813b4c3cc0afad2a2146ad8c54635ab21f5aa902e9c3e95dc40221e23a1747` — the
     boundary manifest pin — in both the live tree and the vendored copy, with
     `XXXX` magic + JSON payload as claimed.
   - **Full-manifest integrity**: boundary **4252/4252** and scout **837/837**
     entries byte-match their pins; **0 mismatched, 0 absent**. (The author's
     §3.8 claim is accurate; nothing else drifted.)
   - Raw asset sniffing confirms the container claims are carried by the
     committed bytes: `glb_as_gltf.gltf` starts `glTF` (GLB bytes under a
     `.gltf` name), `json_as_glb.glb` starts `{` (JSON under `.glb`),
     `glb_version3.glb` has version field **3**, `magic_truncated.glb` declares
     length **4680** against 584 actual, `tri_upper.GLB` = `tri.glb` bytes,
     `tri.gltf` = `json_as_glb.glb` bytes.

6. **The author's receipts are receipts for the committed bytes.**
   - All three battery receipts (`20261016T06{4339133449,4400675959,
     5305784772}Z`) recompute their **116 seed digests against the committed
     blobs with 0 mismatches**; `seeds_unchanged=true` in each; totals
     **9/9** (r98-only pre-run), **333/333**, **333/333**; all 9 r98 rows PASS
     in all three.
   - The **27 arm receipts** (`run1` 9 + `run2` 18) are **byte-identical to the
     committed markers** (0 of 27 differ), with one distinct line per arm.

7. **Fresh arm sweep reproduces the committed markers.** 9 arms × 2 reps from
   fresh scratch copies of the archive (seat-owned runner, not the author's):
   **rep 1 = 9/9 exact marker, rc 0, empty stderr**; rep 2 = 8/9 — the `doc`
   arm reddened with exactly the six seed cells at `err=7` (the F1 race, not a
   pin failure; mechanism reproduced in §11). Wall times 1.08–4.33 s against
   the 20 s case bound.

8. **An independent normalizer recomputes every pinned cell from raw child
   logs.** A from-scratch re-implementation of the declared drop rules (banner
   + blank lines, the exact 2-line Jolt warning at any position, `ud_prefix` →
   `UD/`, `Load address:` → `A`, `[n] …0x…` → `[n] F`, `<Class#n>` → `#N`, the
   per-cell error allowlist with `ee`/`ue` routing) plus independent
   re-implementations of the extraction semantics (`_field`/`first_with`/
   `last`/`tok`/`between`/`count`) reproduces **137/137 cells with 0
   mismatches** — including every `sha`, every field value, `ee`, `gd=0`,
   `beq`/`pgeq`/`eq` — on **three independent data sets**: this seat's own
   rep-1 children, and both of the author's `ftest2` rep sets (pids
   3024…–3032… and 3033…–3041…): **411 cell re-derivations, 0 mismatches**.
   The `pgeq` chain re-derives `pgsha=cb0a74518de94092` from the three
   backends' export files, and `imp@*` re-derives
   `body=RigidBody3D,mass=3.5,shape=BoxShape3D` from the raw logs.

9. **Independent crosscheck: 137/137 cells identical to the scout/boundary
   receipts.** Using this seat's own children and this seat's normalizer
   against the author's cell→receipt map (each mapped receipt verified to
   exist): **137 checked, 137 identical, 0 differ, 0 missing**. This
   independently confirms the author's "137 checked, 137 identical" claim.

10. **The pins are live — eleven battery-level mutants, nine detections
    (two by-design non-detections, see F2; `M2` is detected on the `doc` row
    and by-design invisible on the content-blind `load` row).** In seat-owned mutant trees (never the
    worktree), each mutation was judged by the battery's own exact-marker
    assertion:
    - `MB` probe `CLASSES` loses `GLTFSkin`: `inv@*` `asked=18,exists=18` →
      `asked=17,exists=17`, sha moves — the 18-class inventory is measured.
    - `MC` probe `body.mass 3.5 → 4.0`: `pgsha` `cb0a74518de94092` →
      `50c79fda68eba1bf` and `imp@*` `mass=3.5` → `mass=4.0` — the OMI export
      really carries the mass and the import really reads it.
    - `MD` var comparison target moved (`doc_file_t30` case → `doc_gltf`):
      `eq=1` → `eq=0` — the invariance compares are live.
    - `ME` probe `BoxMesh → SphereMesh` in `_roundtrip`: `roundtrip@*`
      `bytes=2696` → `bytes=133084`, sha moves on all three backends.
    - `M1` `nodes_only.glb` matrix translation `7.0 → 9.0`:
      `pbpos=(7.0,8.0,9.0)` → `(9.0,8.0,9.0)`, sha
      `25d59fb13b77cc1d` → `a235cb3ceb661fdc` — TRS fidelity is measured from
      the committed asset bytes.
    - `M2` `tri.glb` truncated to 16 bytes: the **doc** row reddens
      (`err=43`, `doc_buf bytes=16`), while the **load** row stays green — the
      loader dead-end is content-blind by construction, exactly as pinned.
    - `M3` drop the `No loader found` allowlist head: `load_glb@gp`
      `ee=2` → `ee=1` with the line in `ue` — the allowlist is load-bearing in
      the fail-closed direction.
    - `M4` `ext_resuri.gltf` URI `res://assets/ext.bin` → `ext.bin`:
      `ext_resuri_file@*` `err=43` → `err=0` — the res:// blind-concat law is
      measured from the asset bytes.
    - `MW` `write_to_filesystem` `.gltf` target → `.glb`: `write@*` sha moves —
      the sidecar law is measured.
    - **Non-detections (by design, filed as F2):** `glb_version3.glb` version
      3→2 and `magic_truncated.glb` declared length 4680→584 leave the `sniff`
      row green — no cell reads the declared version/length back.

11. **The F1 race, isolated and reproduced.** See Findings. In a seat-owned
    copy of the fixture with exactly one constant renamed (`APP` →
    `R98RevRace`, which only renames the shared dir namespace so the sibling
    batteries were not disturbed), the doc arm passes alone (control 2/2) and
    then **reddens in 3 of 6 concurrent-parent attempts** (`doc` + `load`
    started 0.3–1.0 s apart), always with the identical signature: the six
    cells `doc_abs@gp/jolt/dummy` and `doc_user@gp/jolt/dummy` fail
    `_cell_ok` with `ue=ERROR: Can't open file at path "UD/<APP>/tri.glb"` /
    `"user://tri.glb"` (`err=7`), while the concurrent `load` parent passes.
    The committed-bytes instance of the same collision was observed live in
    §7 rep 2, concurrent with the r98-verifier's own `doc`-arm re-run
    (`corpus/live/r98-verifier/mine/root/m0_doc_*`, same minute); the sibling
    `r98-simplifier` hit the extbin variant in the same minute from its own
    committed-tree pass (`ext_bin_abs@*`, `UD/R98Scout/ext_bin.gltf`).

12. **Battery from the clean archive.** Focused `--only` pass of the 9 r98 rows
    from the archive tree, with four sibling seats' runs in flight: **9/9
    PASS**, and **all 9 r98 rows PASS in the full 333-case run too** (328/333
    overall; the five non-green rows are documented pre-existing load-flake
    families, none r98 — see the §12 addendum at the end of this file).

13. **Claim audit — the report's values are accurate.** Every hex token in
    `r98-author.md` appears in a committed marker or a committed fixture sha;
    the only unmatched tokens are the date `20261015`, the three receipt-path
    timestamps (`4339133449`, `4400675959`, `5305784772`) and the repair sha
    `6e813b4c…` (verified in §5). Of the 55 decimal/int tokens, the 16 not
    present in markers are all explained: wall-clock times (1.03/3.96/3.8),
    the census (137, 265, 274, 324, 333), the manifest counts (837, 4252 —
    both re-verified in §5), the `--time-scale 0.5` flag, the header's
    `<Class#12345>` example, and the timestamps.

---

## Findings (severity order)

**F1 (MEDIUM — new cross-parent race on a fixed shared seed dir; false-red
only).** `r98_gltflat.gd` introduces the lane's first user-data seed dir, and
it is a **single fixed path shared by every concurrent parent**:
`const APP := "R98Scout"` names both the parent's seed target
`ud_dir = <app_userdata>/R98Scout` (L171) and every child project's
`config/name` (L152-153), so all children of all parents read the same dir.
Child dirs are pid-namespaced (L169) but `ud_dir` is not, and
`_cleanup_userdir()` runs at the end of **every** arm — the `ud_pre_existed`
branch deletes the three seeded files, the other branch `_rm_rf`s the whole
dir (L431-438). Any second r98 parent that ends an arm inside another parent's
seed→read window therefore deletes its `tri.glb`/`ext_bin.gltf`/`ext.bin`, and
exactly the six seed-dependent cells (`doc_abs@*`, `doc_user@*`, ×3 backends)
fail with `err=7` (`ERROR: Can't open file at path …`), reddening the whole
`r98_gltflat_doc` row. Evidence: this seat's rep-2 sweep red (§7) concurrent
with the verifier's own doc-arm re-run; the isolated repro **3/6** (§11); the
labrat's independent static trace; and — strongest — an **independent sibling
seat hit the same race in the same minute**: `r98-simplifier/ref1.log`
(committed-tree focused pass, start 07:04:36Z, load 68.5) reddens
`r98_gltflat_extbin` with `ext_bin_abs@gp/jolt/dummy ue=ERROR: Can't open file
at path "UD/R98Scout/ext_bin.gltf"` — the same shared-dir deletion seen from
the other side, in the *other* affected row. **Blast radius: 9 seed-dependent
cells in 2 rows** — `doc_abs@*` + `doc_user@*` (doc) and `ext_bin_abs@*`
(extbin). **Failure direction is fail-closed** (false red, never false green)
and no pinned law is affected, but this is the normal operating mode of wave-B
(verifier + scribe + critic + simplifier + reviewer batteries all in flight —
four were running during this seat), so it will produce spurious r98 `doc` /
`extbin` FAILs.

**Cross-seat convergence:** the sibling `r98-simplifier` files the same hazard
as **F-1** — same 9 cells, "3-seat convergent, 5/6 controlled, 0/8 isolated",
with two further sibling-seat observations (`r98-verifier` `only1` 07:15:06Z and
`r98-scribe` `only1` 07:15:18Z, same `UD/R98Scout/tri.glb` signature) — and the
sibling `r98-scribe` files it as **F2**; both are report-only commits, so the
reviewed bytes are unchanged. The scribe's own **F1** widens the §3.8 clobber
disclosure (the clobbered bytes reached a tracked seed for ~7 min); this seat
reviewed the *landed* bytes and they are at the manifest pins (§5), so that
wording item is the adjudicator's, not a byte defect.

**Fold for the author/adjudicator:** give the filesystem dir
a per-run name *and* mask it to a constant in the stream, e.g. set
`ud_dir = ud_prefix.path_join("R98Scout_%d" % OS.get_process_id())`, have
`_base()` bake the same per-pid name into the child project, and add a
`line.replace(ud_dir, "UD/R98Scout")` rule before the existing `ud_prefix`
rule — that keeps the pinned sha host/run-independent (the current masking
only strips the base) while removing the collision. (Not applied by this
seat: report-only.)

**F2 (NOTE — asset-byte claims are not re-read by any cell).** The
"declared total length and container version are unvalidated" laws rest on the
committed asset bytes (`glb_version3.glb` version 3, `magic_truncated.glb`
declared 4680) plus an `err=0` cell; no cell echoes the declared length or
version, so a same-behavior asset swap would leave the row green. Demonstrated:
`MF` (version 3→2) and `MG` (declared length → actual) both keep the `sniff`
row green. The evidence chain is therefore: repo-committed asset bytes (a diff
guard) + the err=0 cell — which is what the author report says, but the
mechanism deserves the explicit note.

**F3 (NOTE — fixture-level `PASS` is not the pin).** `_cell_ok` checks only
`rc`, the log's presence and `ue`; it does **not** compare `sha`/fields, so a
drifted pin still prints `PASS` from the fixture. Both `M1` and `ME` printed
`PASS r98_gltflat …` with moved shas; only the battery's exact-marker
assertion catches them. Consequence: a direct-arm run (the author's
`driver.py`, or any future seat replaying an arm by hand) is not pin evidence
by itself — the receipts do match the committed markers here (§6/§7), but the
distinction should stay explicit in future reports.

**F4 (NOTE — dead config; convergent with the r97 F2 family).** `w` is counted
and returned but never consumed (no cell or diagnostic surfaces it);
`lk` is declared/returned but never incremented (all leak routing goes to
`ue`); and `cap`/`bound` are never set by any of the 137 specs, so `_scan`'s
truncation branch and the `bound` override are dead. No behavioral effect; the
conservative direction of the unused allowlist/`ue` routing is the safe one.

**F5 (NOTE — timeout layering; same family as r97 F5).** Each child carries
`timeout -s KILL 14` inside a per-chunk 14 s parent deadline, inside the
battery's 20 s per-case bound. The `doc` arm is 36 children in 5 chunks and
runs 4.3 s nominal here; one stalled chunk (14 s) would push the row past the
20 s battery bound into a TIMEOUT fail. Fail-closed, but worth a flake-list
note rather than a change.

**F6 (NOTE — `gd` census is post-hoc only).** The cold-cache premise is
asserted by a `.godot` existence check *after* the child exits; a child that
minted and removed a cache inside its own lifetime would not be seen. No such
behavior exists on this surface (137/137 children re-derived `gd=0` across
three data sets), so this is a statement of the guard's limits, not a defect.

---

## Residual risk / verification gaps

- **No LSP device** (`rea` only): symbol-level checks unavailable; none needed
  (this seat made no edits; all five fixtures parse and execute).
- **Cross-build.** Every pin is receipt-derived for
  `4.7.2.stable.arch_linux.ed1daf0bf` on this host; hashes are build-scoped
  (the corpus convention from r89–r98).
- **F1 timing dependence.** The race needs a second parent's cleanup to land
  inside the ~1 s seed→read window; my repro hit it in 3/6 attempts at 0.3–1.0 s
  offsets and 0/2 at 1.8 s. Under the current four-battery load the window is
  wider, not narrower.
- **Concurrency disclosure.** Three sibling batteries plus the verifier's own
  arm re-runs shared this 32-core host for the whole seat (load 52–101). The
  one non-green r98 observation (rep-2 `doc`) is attributed to F1 with a
  reproduced mechanism; the full-battery non-green rows are the two documented
  pre-existing `navagent3d_retarget*` load flakes.
- **Not re-measured here** (by scope): the scout/boundary cases the author
  declares unpinned — the warm-cache `PackedScene` flip (boundary V12),
  skins/animations/textures/cameras/lights payloads, `GLTFDocumentExtension`
  hooks, exported-template context, whether OMI bodies enter a physics space
  once tree-owned, and every scout/boundary case not replayed in the 137.

## Recommendation (not a judgment — the canonical runtime judges)

**ADMIT-recommend.** The committed landing is sound as scoped. The diff is
insertion-only with zero existing bytes touched and the r98 rows are the last
nine of 333; all five fixtures parse and the runner compiles; the census is
exact (333 = 274+59, 9 rows, 137 cells = 137 children) and the four probe
copies are byte-identical to the scout/boundary sources; **all 17 vendored
assets match the manifest pins and both full manifests (4252 + 837) are
intact**, including the disclosed xxd-clobber repair; the author's three
battery receipts are for the committed bytes (116/116 seed digests each, 9/9 +
333/333 + 333/333, all r98 rows green) and the 27 arm receipts are
byte-identical to the committed markers; an **independent normalizer**
recomputes **411/411 cell instances across three data sets with 0
mismatches** (sha, fields, `ee`, `gd`, `beq`/`pgeq`/`eq`); an **independent
crosscheck** against the scout's/boundary's own receipts is **137/137**; and
the pins are **live** — eleven battery-level mutations with nine mechanistic
detections and two by-design non-detections (plus `M2`'s second-row
content-blind non-detection). The findings are one MEDIUM
false-red race on the shared seed dir (F1, with a concrete fold) and five
NOTEs (F2–F6); **no finding touches a pinned law or the committed behavior**.
The F1 fold and the F2/F3 wording notes belong to the author/adjudicator, not
to this seat.

**Cross-seat convergence (independent).** `r98-simplifier` F-1 = this F1
(5/6 controlled reds, 0/8 under private `XDG_DATA_HOME`); `r98-scribe` F2 = the
same hazard; both landed report-only after the reviewed commit, so the bytes
this report judges are unchanged.

**Blockers:** none. The dispatched `ufo-labrat` was usable but static-only
(no exec tool); its dynamic phase was covered by this seat's own repro.

Stopping here.

---

## §12 addendum — full battery numbers

Full 333-case battery from the clean archive
(`/home/vgpnk/.cache/r98-reviewer/batt/full1/20261016T071000630741Z/`,
run 07:10–07:30Z, load 60–90 with four sibling seats in flight):
**328/333 PASS**, `seeds_unchanged=true`, totals 274 ordinary + 59 negative.
**All 9 r98 rows PASS** (wall times 1.26–5.00 s against the 20 s bound: load
2.92, doc 5.00, sniff 2.89, extbin 2.75, cls 2.15, write 1.26, tr 1.38, phys
2.07, var 2.20). The five non-green rows are all documented pre-existing
load-flake families, none r98: `navagent3d_retarget` +
`navagent3d_retarget_fixed` (the `before=1.754246` one-tick drift),
`phys3d_events_script_size_gate` + `phys3d_events_deferred_hang` (the r86
size-gate race, r93-baseline2 §F), and `phys3d_joints_free_ops` (the 20 s
knife-edge, r93-baseline2 / r97 F5).

Focused pass (`batt/only1/20261016T071218690572Z/`): **9/9 PASS**.

**Cross-seat context (not r98 scope, recorded for the gate):** the sibling
`r98-scribe` and `r98-verifier` full batteries finished **328/333** and
**330/333** with **all 9 r98 rows PASS in both**; their failures are the same
pre-existing families (`phys3d_*`, `bpy_rbw3d_ops`). Both report
`seeds_unchanged=false` — an artifact of a concurrent lane adding new seeds to
`corpus/fixtures` (the r99 author's files) while the runner's whole-directory
digest map was live, not a mutation of the r98 seeds; this seat's own run,
which started before those files landed, recorded `seeds_unchanged=true` and
its 116-digest map is byte-exact against the committed blobs (§6).

## Receipts index

`/home/vgpnk/.cache/r98-reviewer/` (mirrored at the gitignored
`corpus/live/r98-reviewer/`): `tree/` (verified `git archive b6d60b1`),
`tools/` (`census.py`, `assetpins.py`, `sweep.py`, `vnorm.py`, `xcheck.py`,
`mutants.py`, `mutants2.py`, `race.py`, `cells.json`, `r98_markers.json`,
`all_markers.json`, `mutant_results.json`, `mutant2_results.json`),
`sweep/rep{1,2}/` (18 arm runs + 137 child dirs each with `child.log`),
`sweep/*.stdout|.stderr`, `race/` (mutant tree, controls, A/B scratch trees),
`mut/` (mutant trees MB/MC/MD/ME/MF/MG/M1/M2/M3/M4/MW, plus the discarded no-op MA), `batt/full1/` (full battery + `full1.log`),
`dump/` (the cell-table dumper), plus the derived logs
`/tmp/vnorm_rep1.txt`, `/tmp/vnorm_ftest2_r{1,2}.txt`.
