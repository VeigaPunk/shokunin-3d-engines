# r98 critic — adversarial review of the committed gltflat landing (`b6d60b1`)

Seat: **GAME-DEV-3D r98 CRITIC** (frozen `probeParent`). Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r98-critic.md`.
Attacked artifact: commit
`b6d60b113513141aad60c4b2423f7c82d639c5e9` — `corpus/fixtures/r98_gltflat.gd`
(+829, new), four `corpus/fixtures/r98_probe_*.gd` (+560, new),
`corpus/fixtures/r98assets/` (17 vendored assets, new),
`corpus/fixtures/run_battery.py` (+41/−0, insertion-only),
`reports/round-98/r98-author.md` (+186); **24 files, +1621, 0 deletions**;
**333 battery cases** (274 ordinary + 59 negative controls), the nine r98 rows
are the contiguous tail **rows 325–333**. Author/scout/boundary reports and
`corpus/live/r98-{author,scout,boundary}/` receipts were read, never written.

**Committed tree only.** All measurement ran on a frozen `git archive b6d60b1`
tree (`corpus/live/r98-critic/frozen/`, fixture sha identical to the committed
blob). **This seat wrote no tracked file and made no commit**; the only new
tracked-path artifact is this report, left for the operator exactly like the
sibling seats' reports.

Environment (`corpus/live/r98-critic/env.txt`): `/usr/bin/godot`
**4.7.2.stable.arch_linux.ed1daf0bf**, `/usr/bin/python3` **3.14.7**, kernel
7.2.3-arch1-3, 32 threads, 30 GB RAM, `--headless`. The box was loaded for the
whole seat (load1 **52.6 → 57.5**, 63/1982 procs at seat start; sibling lanes
observed live: the r98 **scribe** running its own r98 battery, the r99 author
writing new untracked `corpus/fixtures/r99_*` seeds, plus wave-B report
writers). Every number below is therefore a **loaded-host** measurement.

**No `lsp`/symbol device is exposed to this seat's toolset** (the same recorded
absence as r85–r97). This seat made no source edit, so the hand-edit fallback
was never in play.

**`probeParent` seat:** exactly one read-only `ufo-labrat` was dispatched (the
static marker/key derivability probe over the 137 committed cells). Its report
is folded into §3.4; no other descendants, nothing edited.

---

## 0. Verdict

**PASS — the landing survives attack on the committed bytes, with findings that
are coverage/pin-strength class only; nothing contradicts an authored law.**

- **137/137 cells re-derived byte-identically** to the committed markers by an
  **independent child runner + scanner written from the declared contract**
  (own project dirs, own spawn shape, own exit capture, own normalizer):
  **411/411 over three independent reps**, plus 170 cells in earlier partial
  passes (**581 cell instances total**), with **0 unexpected-ERROR cells, 0 nonzero
  exits, 0 `.godot` caches minted**.
- **137/137 pinned shas reproduce from the scout's/boundary's OWN receipts**
  under my scanner (§3.3) — the pins are the source seats' evidence, not a
  re-measurement substituted by the author.
- **9/9 r98 rows green in every battery run of this seat** (r98-only 9/9;
  full 333-case runs **332/333** and **330/333**, the misses being pre-existing
  `navagent3d_*` load flakes outside r98; §2.3).
- **9 of the 12 mutation probes are rejected** by the pins they target; the 3
  non-detections are bounded and explained (§4: M7, an asset-form swap that
  leaves the receipt identical — finding F1 — plus the two designed negative
  controls M9/M10 that document the var arm's and the Jolt-warning guard's
  blindness).
- **The xxd clobber repair verifies**: the repaired live asset matches a
  manifest pin that **predates the repair by 11 hours**, both manifests verify
  **4252/4252** and **837/837**, the generator re-mints all 17 assets to the
  pins, and the 17 vendored fixture copies byte-match those pins (§1.3).

| # | attack | verdict | anchor |
|---|---|---|---|
| 1 | insertion-only, row arithmetic, custody of the 24 files | **CONFIRMED** | §1.1–1.2 |
| 2 | the disclosed xxd clobber: do the asset bytes match the manifest pins? | **CONFIRMED** (manifests verify; pin predates repair; generator deterministic) | §1.3 |
| 3 | reproduce the 9 rows on the committed bytes (frozen tree) | **CONFIRMED 9/9** | §2.1 |
| 4 | full 333-case battery on the committed bytes | **332/333, 330/333 — all misses pre-existing navagent flakes; 9/9 r98 green in both** | §2.3 |
| 5 | is the evidence real (137 cells from raw child text)? | **CONFIRMED** — 581 cell instances, 0 diffs | §3.1 |
| 6 | are the pins the scout's/boundary's own receipts? | **CONFIRMED 137/137** | §3.3 |
| 7 | are the pins load-bearing? | **CONFIRMED for 9/12 mutants; 3 bounded non-detections (M7 explained; M9/M10 designed controls)** | §4 |
| 8 | is `beq=1` backend-inertness vacuous? | **NO — the three bodies really are three backends (Dummy does not simulate)** | §5.2 |
| 9 | named risk: cold-cache premise | **CONFIRMED** — 0/137 children minted `.godot`; M3 detects a pre-created cache | §5.1 |
| 10 | named risk: var arm / rate-flag invariance | **CONFIRMED inert, but the arm cannot detect a dropped flag (M9); `--time-scale` reachability positively confirmed** | §5.3–5.4 |
| 11 | flake hunt: r98 rows under load | **CONFIRMED stable** — 39 r98 row runs, 0 r98 deviations, 0 flake-class firings | §2.4 |
| 12 | hygiene: tracked writes, strays, cleanup | **CONFIRMED** — zero tracked writes, scratch confined, no orphans | §7 |

---

## 1. Custody and byte-level checks

### 1.1 Insertion-only, row arithmetic

```
git diff --numstat 5ab2c0e b6d60b1 -- corpus/fixtures/run_battery.py   ->  41  0
git diff          5ab2c0e b6d60b1 -- corpus/fixtures/run_battery.py   ->  single hunk @@ -804,6 +804,47 @@
git show --stat b6d60b1                                               ->  24 files changed, 1621 insertions(+)
```
The hunk is appended **after** the r97 tail row (`r97_nodelat_freegrain`); no
pre-existing byte moved. Battery arithmetic re-read from the frozen
`verdicts.json`: **333 cases = 274 ordinary + 59 negative controls**, r98 rows
325–333 (9 rows: 7 ordinary arms + `tr` 2 cells + `phys` 6 cells + `var` 15
cells). At custody-check time `git diff HEAD --stat` was **empty** — the working
tree's r98 files are the committed bytes. (Late in the seat the sibling r99
lane appended its own rows: at filing `git diff HEAD -- corpus/fixtures/run_battery.py`
= **29/0, appended after the r98 tail**, no removed line, no r98 byte touched;
its new untracked `r99_*` seeds are the other drift. The frozen tree insulates
every measurement here from both.)

### 1.2 Fixture / probe custody

| artifact | sha256 (measured here) | vs author's declared value |
|---|---|---|
| `corpus/fixtures/r98_gltflat.gd` | `47998a95bb0401f7f8475bb0baf0828fa8f8559d2b2b3c174eff8221ab2835db` | **equal** (report §0 + `RECEIPTS.md`) |
| `r98_probe_gltf.gd` | `18ba68b7065afdceff51b92a42605696b06662dae5a61e1e7d1320e2c62f29ca` | **equal** |
| `r98_probe_gltf_tr.gd` | `4736126f3c148fb29d9b234400adf27a1d9d1dac63815fc074612977b29f3d5e` | **equal** |
| `r98_probe_r98b_inv.gd` | `31cd69c1988b8cbe4c7d70b3e8ed2aaf2879cfcf9dc53d8b1fa5791bd4b83454` | **equal** |
| `r98_probe_r98b_mode.gd` | `fadcf86c0c9dbd71b23d2e2087c3166e117a9f37f4bad865da97e928102cda60` | **equal** |

`cmp` of each fixture probe against its live source (scout **and** boundary for
`gltf`/`gltf_tr`, boundary for `r98b_*`) is byte-identical in all six
comparisons. The header law comment's "18 classes", "GLTFSkin the 18th",
"`set_root_nodes` lives on `GLTFState`" and "cold premise" statements match the
pinned cells and the boundary's V6/V7 verdicts.

### 1.3 The vendored assets and the disclosed xxd clobber — **verified**

1. **Both live manifests verify in full**: `sha256sum -c` in
   `corpus/live/r98-boundary/` → **4252/4252 OK**; in `corpus/live/r98-scout/`
   → **837/837 OK**. The clobbered path `assets/badmagic_badjson.glb` is pinned
   `6e813b4c3cc0afad2a2146ad8c54635ab21f5aa902e9c3e95dc40221e23a1747` and the
   file now matches it.
2. **The pin predates the repair**: `manifest.sha256` mtime **2026-10-15
   16:41:08**, repaired file mtime **2026-10-16 03:39:28** — the manifest was
   not rewritten at repair time, so the author restored the original bytes to a
   pre-existing pin, exactly as disclosed.
3. **The repair is the recipe's output**: `gen_assets_r98b.py` re-run in a
   scratch copy of `assets/` reproduces **all 17 assets** to their manifest
   pins, `MISMATCH: []` (the clobbered file is `b"XXXX" + version + JSON chunk`
   with a deliberately broken JSON payload — content sanity checked by hand).
4. **The 17 vendored fixture copies byte-match those pins** (each file checked
   against the boundary manifest pin, the live boundary copy, and the scout
   manifest where the asset is shared): **17/17 matched, 0 unmatched**; no live
   boundary asset was left unvendored. `tri.glb` == `glb_as_gltf.gltf` ==
   `tri_upper.GLB` (`1116006c…`) and `tri.gltf` == `json_as_glb.glb`
   (`999e2c08…`) are the intended byte-identical discriminator aliases.

---

## 2. Reproduction on the frozen committed bytes

### 2.1 The nine rows alone — 9/9

`python3 frozen/corpus/fixtures/run_battery.py --only r98_gltflat_{load,doc,sniff,extbin,cls,write,tr,phys,var}`
→ **9/9 PASS**, `seeds_unchanged=true`, row wall times **1.28–4.38 s**
(`corpus/live/r98-critic/battery-r98only-1/20261016T070403596566Z/verdicts.json`).

### 2.2 Full 333-case battery, twice, on the frozen tree

| run | result | misses | r98 rows | wall clock | receipt |
|---|---|---|---|---|---|
| full 1 | **332/333** | `navagent3d_retarget_fixed` (`before=1.754246`) | **9/9 PASS** | 1.70–5.74 s/row | `battery-full-1/20261016T070427543304Z` |
| full 2 | **330/333** | `navagent3d_retarget`, `navagent3d_retarget_fixed`, `navagent3d_follow` (same `1.754246`/`1.659965` signatures) | **9/9 PASS** | 1.10–4.38 s/row | `battery-full-2/20261016T071518942613Z` |

Both runs report `seeds_unchanged=true` and `godot_version=4.7.2.stable…`.
The misses are the **documented navagent one-tick load flake** (r93-verifier
:85 / r94-verifier :84 / r95-critic §1.11 / r96-author §"the documented
navagent one-tick load flake" all record the identical `before=1.754246`
signature); they are outside r98 (the commit touches no navagent byte) and they
fired under a host carrying a sibling lane's r98 battery plus the r99 author.
The author's own two full runs were 333/333 — **my window could not reproduce a
fully green full battery**, the same load-shaped outcome the r97 critic
recorded (322/324, 323/324). **No r98 row ever reddened.**

### 2.3 Child census and the cold premise in the battery shape

Counting the per-cell project dirs left in the battery scratch:
`load 21, doc 36, sniff 21, extbin 21, cls 12, write 3, tr 2, phys 6, var 15`
= **137 children for 137 cells** (phys contributes 3 generate + 3 import
children), and `find <scratch> -maxdepth 2 -name .godot` → **0**. The
"137 cells/137 children per pass" claim is exact.

### 2.4 Flake hunt

39 r98 row executions in this seat (9 + 9 + 9 battery rows, 12 mutation rows),
plus 581 child-cell re-derivations: **zero r98 deviations, zero documented
flake-class firings on r98 rows, zero nonzero exits, zero `.godot` minted, zero
unexpected ERROR-class lines**. The only instability observed anywhere is the
pre-existing navagent class above.

### 2.5 Timing margin (residual risk, §6 F4)

The battery bounds a case at 20 s; the fixture bounds each 8-child batch at
14 s. Measured r98 rows are **1.10–5.74 s** (≈3.5–18× margin). A *hung* child
in a multi-batch arm is the tail case: the doc arm is 5 batches, so a fully
stalled doc row would need 70 s and would surface as a battery-level
`TIMEOUT`, not as the fixture's own per-cell diagnosis. Fail-closed, but coarse.

---

## 3. Evidence integrity — the cells are re-derived, not restated

### 3.1 Independent runner (my own implementation)

`corpus/live/r98-critic/runner.py` re-implements the declared contract from the
fixture header + reports: it builds the 137 cell specs itself, spawns every
child in its own fresh project dir (`timeout -s KILL 14`, stdout+stderr merged
into one stream like the fixture's `> log 2>&1`), scans the raw text with its
own normalizer/allowlist, and formats the digest cell. It reads the committed
markers by `ast`-parsing the frozen `run_battery.py`.

```
--reps 3  (all nine arms, 137 cells per rep):  checked=411 identical=411 differ=0 missing=0
          ue_cells=0  rc_nonzero=0  gd_nonzero=0      (runner-rep3.json)
earlier partial passes: load/tr/cls/write 38/38; doc/sniff/extbin/phys/var 96/99 then doc 36/36
          (the 3 misses were a runner-side relative `--path` bug in my doc_rel cells, fixed and re-run)
```
**581 cell instances, 0 differences, across three independent reps and two
scratch roots.** Because the committed markers are what the fixture's own
scanner emits on these bytes (the frozen battery passes), this is also a
two-implementation agreement on every normalized stream and every sha.

### 3.2 The declared normalizations are load-bearing and host-independent

My runner ran with `XDG_DATA_HOME` pointed at a private tree, so the
`doc_abs`/`doc_user`/`ext_bin_abs` children saw a **different** user-data path
than the author's; their shas still match the committed markers, which is a
direct measurement of the declared "the claim is the path FORM, not the host"
normalization. Mutation M11 (mask disabled) reddens the doc row, so the
normalization is load-bearing, not decorative.

### 3.3 Provenance: 137/137 pins are the scout's/boundary's own receipts

`corpus/live/r98-critic/spotcheck.py` maps every cell to the source seat's
receipt for the same probe+case(+backend/flag variant) — scout
`gl_proj[_jolt|_dummy]_*`, `tr_proj_*`; boundary `r98b_mode_proj*`,
`r98b_inv_proj*`, `r98b_physgen_proj*`, `r98b_tps_proj_tps{30,120,5}_*`,
`r98b_ffps[_jolt|_dummy]_proj_*`, `r98b_ffps120_proj_*`, `r98b_ts_proj_*` —
normalizes the receipt with **my** scanner and compares to the pinned sha:

```
provenance: ok=137 diff=0 no-receipt=0        (spotcheck.json)
```
The phys byte pin is independently confirmed at source: the boundary's own
`evidence/phys_gen_sha.txt` reads
`cb0a74518de94092d9cc281aa0ac1f199f61359b33430be6e4997976922109df  proj|proj_jolt|proj_dummy 612`,
and the fixture's `pgsha=cb0a74518de94092` re-derives it.

### 3.4 Static derivability (the one `labrat` probe)

The dispatched read-only probe parsed the 137 committed cells and checked every
pinned key against the probe sources:

- **137 cells confirmed** from the marker strings alone (21+36+21+21+12+3+2+6+15).
- **Every probe-emitted key traces to a literal ` key=` token** on a line the
  probe can print for that case; fixture-derived fields (`rc, sha, ee, gd, beq,
  eq, pgeq, pgsha`, count-derived `classes`) are exempt and enumerated.
  **No key was found non-derivable** — the hypothesis was not falsified.
- **Both `CLASSES` arrays have 18 entries and are identical** (the corrected
  inventory), matching the pinned `classes=18`/`asked=18,exists=18,refc=1`.
- **Zero empty pinned values** in the 137 cells.
- Caveat recorded by the probe: the doc-arm marker line exceeds its 2000-char
  read window, so its tail was verified by anchored count-mode regexes rather
  than fully eyeballed.

---

## 4. Mutation probes — are the pins load-bearing?

All mutants are scratch copies of the frozen fixtures under
`corpus/live/r98-critic/mut-<name>/` (the frozen tree is never written) and are
judged by the **real** `run_battery.py`, restricted to the targeted row
(`mutations.json`).

| # | mutation | row | expected | battery | result |
|---|---|---|---|---|---|
| M1 | one char of the committed marker (`res=null`→`res=nul`) | load | FAIL | **FAIL** | **DETECTED** (markers compared exactly) |
| M2 | drop the `noload` expected-error allowlist entry | load | FAIL | **FAIL** | **DETECTED** (errors become `ue`) |
| M3 | pre-create `.godot` in every child (breaks the cold premise) | load | FAIL | **FAIL** | **DETECTED** (`gd=1` in the cell) |
| M4 | probe exits 3 for `load_glb` | load | FAIL | **FAIL** | **DETECTED** (`rc=3` + `_cell_ok` rc gate) |
| M5 | one byte of the vendored `tri.glb` scene name | doc | FAIL | **FAIL** | **DETECTED** (asset bytes are the measured input) |
| M6 | OMI payload mass 3.5 → 4.5 | phys | FAIL | **FAIL** | **DETECTED** (`pgsha` + `mass=`) |
| M7 | `glb_as_gltf.gltf` gets JSON text instead of GLB bytes | sniff | FAIL | PASS | **NOT DETECTED — explained, F1** |
| M8 | `ext_resuri.gltf` URI `res://assets/ext.bin` → `ext.bin` | extbin | FAIL | **FAIL** | **DETECTED** (the blind-concat claim is byte-driven) |
| M9 | `--fixed-fps`/`--time-scale` never reach the children | var | PASS | PASS | **NEGATIVE CONTROL — confirms F2** |
| M10 | Jolt-warning text mutated | load | PASS | PASS | **NEGATIVE CONTROL — guard never fires (F3)** |
| M11 | disable the `app_userdata → UD/` normalization | doc | FAIL | **FAIL** | **DETECTED** |
| M12 | one extra stdout line in the vendored probe copy | doc | FAIL | **FAIL** | **DETECTED** |

**M7 is the honest coverage limit** and is fully explained: GLB bytes and JSON
text under the same `.gltf` name produce **byte-identical receipts** (verified
directly: `diff` of the two boundary receipts is empty after path substitution,
and my own two-project re-run of the case is line-identical), so the cell pins
the *outcome* while the container-form discriminator lives in the **asset
bytes**, which the tracked lattice does not hash. See F1.

---

## 5. Named risks and encoded laws, measured

### 5.1 Cold-cache premise

Every child ran with a fresh project dir; the post-run census in the cell text
(`gd=0`) is enforced by the marker comparison (M3 reddens the row when a cache
is pre-created). 0/581 of my children minted `.godot`; 0/137 in each battery
pass. The `ResourceLoader` dead-end (`res=null`, `ee=2` allowlisted loader
lines) is pinned on all 7 load cases × 3 backends, and the author's scope note
(warm cache = boundary V12, deliberately not authored) is accurate.

### 5.2 `beq=1` backend-inertness is not vacuous

The lattice pins GP == Jolt == Dummy byte-identical on every case. Control
(`extra.py`): a RigidBody3D dropped over a floor, 40 physics ticks, in the same
three project bodies —

```
FALL gp     FALL y=7.8154 frames=40
FALL jolt   FALL y=7.8154 frames=40
FALL dummy  FALL y=10.0000 frames=40     <- Dummy does not simulate
```
The three bodies really select three different backends, so the cross-backend
equality evidence is a real comparison, not three identical runs.

### 5.3 Rate-flag reachability

`--time-scale 0.5` is positively confirmed in the child shape
(`Engine.time_scale=0.5`); `--fixed-fps 60` is accepted by the engine with no
unknown-argument diagnostic, but it is **not observable** from a SceneTree
script that quits immediately (neither argv nor `Engine.time_scale` moves), so
its plumbing rests on the r100 lane's byte-stable evidence rather than on a
positive control in this surface.

### 5.4 The var arm's discriminating power is nil by construction

M9 shows the var arm passes with the rate flags **never passed at all**: the
arm's cells compare a flagged child's receipt to its unflagged twin, and the
surface is inert, so "flag applied and inert" and "flag dropped" are the same
receipt. The invariance claim is therefore supported (and independently
re-derived 45/45 across three reps), but the arm cannot detect a plumbing
failure. See F2.

### 5.5 Strict pins (fail-closed, by design)

`cls` cells pin the engine version string (`eng=4.7.2-stable`) and `recps=tscn,res,scn`;
`phys` pins a 16-hex export sha; every cell pins `rc=0` through `_cell_ok` plus
the cell text. All are strict and will redden on an engine change rather than
adapt — the conservative choice, same as the r97 critic's note on `rc=134`.

### 5.6 The two-vs-one root extraction is complementary, not redundant

`_doc_gets()` ends with `_glast("MODESCENE ", "root")` while the third rule
matches `"SCENE root="`: the scout probe prints `DOCSCENE root=…` (rule 3) and
the boundary probes print `MODESCENE <name>:<class>` (rule 4). Each rule is a
no-op on the other probe's stream, so no cell gets a duplicate or stray `root=`
field — confirmed by my re-derivation (all 137 cells field-exact).

---

## 6. Findings

**F1 (NOTE — the content-sniff law's discriminator is not pinned inside the
tracked lattice; my M7).** `glb_as_gltf.gltf` / `json_as_glb.glb` cells pin
`err=0` + the scene, but GLB bytes and JSON text under the same name produce
**identical receipts**, so replacing the vendored asset with the other encoding
leaves the row green (M7). The discriminating artifact is the asset's 4-byte
magic, which is pinned only **outside** the tracked tree (boundary manifest —
live/gitignored — and `RECEIPTS.md`). Impact is bounded (I verified those pins,
and the vendored copies match), but a future seat cannot re-derive the
container-form claim from the committed lattice alone. Cheap fold: one cell
that hashes `res://r98assets/*` (or just the magic of the three aliased
assets), which would make M7 detectable.

**F2 (NOTE — the `var` arm cannot detect dropped flags; my M9).** The arm's
evidence is "flagged receipt == unflagged receipt"; with an inert surface that
is also what a dropped flag produces. `--time-scale` is separately confirmed
reachable (§5.3), but the arm itself has zero discriminating power. Cheap fold:
pin the child's argv/`Engine.time_scale` in one var cell, or add a positive
control where the flag does move output.

**F3 (NOTE — unexercised guard + dead config; convergent with the r96/r97
"guard-only normalization" class).** The 2-line Jolt-warning normalization is
declared but **never observed** on this surface (M10 is undetectable), and its
`w` counter is not surfaced in any cell; `lk` is initialized and never
incremented; the `cap`/`truncated` scan path and the per-spec `bound` override
are unused by all 137 cells. None affects a pinned claim.

**F4 (NOTE — the doc row's internal bound can exceed the battery's case
timeout; mine).** 5 batches × 14 s = 70 s worst case vs the battery's 20 s
`CASE_TIMEOUT_SECONDS`. Measured 4.4–5.7 s, so the practical margin is ~3.5–4×,
but a hung child in a multi-batch arm degrades from "fixture prints a diagnosis"
to "battery TIMEOUT with no cell text". Fail-closed; worth a per-arm bound
shrink or a shorter batch bound if the host gets busier.

**F5 (INFO — `beq`/`eq`/`pgeq`/`eqg` are in-process booleans).** Backend
equality and the write byte-equality are computed by the child/parent that
produced the compared bytes (`filebytes == buf` inside the probe, sha equality
inside the fixture). My independent re-derivation reproduces all of them from
the raw streams, and §5.2 shows the backends are genuinely distinct, so the
claims hold; the pattern is still self-reported rather than hash-of-both-sides.

**F6 (INFO — engine-version pin in `cls`).** `eng=4.7.2-stable` makes the row
engine-build-specific (fail-closed). Consistent with the lane's practice.

**F7 (INFO — full-battery greenness is load-shaped; convergent with the r97
critic's window).** My two full runs were 332/333 and 330/333 on the frozen
committed tree, all misses being the pre-existing navagent load flake class,
with zero r98 involvement. The author's 333/333 ×2 stands as their window's
measurement; a future verifier should not treat "fully green" as the pass
criterion for this lane under load.

---

## 7. Hygiene, writes, cleanup

- **Zero tracked writes by this seat.** `git status --short` shows the
  pre-existing untracked r94/r95 reviewer reports, the sibling r99 lane's new
  `corpus/fixtures/r99_*` seeds **and its 29-line append to
  `corpus/fixtures/run_battery.py`** (29/0, after the r98 tail — the r99 author
  lane, not this seat), the sibling r98 reviewer/scribe/simplifier reports, and
  (after this seat) this report. No r98 or other committed byte was moved by
  this seat: the frozen `git archive` tree was the only fixture source used for
  measurement, and every mutation edit happened on scratch copies under
  `corpus/live/r98-critic/mut-*/`.
- Scratch is confined to `corpus/live/r98-critic/**` (**281 MB**, gitignored via
  `corpus/.gitignore:1 live/`): `frozen/` (the `git archive` tree), `work/` +
  `work3/` (per-child `child.log` + `project.godot` for every rep), `mut-*/`
  (mutant runs, fixture copies deleted after judging), `battery-*/`,
  `xdg-rep*/` (private user-data trees), `genrepro/`, `m7check/`, `udtest/`,
  `env.txt`, `runner.py`, `mutate.py`, `extra.py`, `spotcheck.py`,
  `*.json` receipts. Disk: 147 GB used / 777 GB free.
- **No orphan processes from this seat**: every child was `timeout -s KILL 14`
  bounded and every `Popen` reaped; the only processes I left are none. The
  r98-scribe lane's and other lanes' Godot children were observed live and left
  untouched.
- The shared `~/.local/share/godot/app_userdata/R98Scout` used by the battery's
  children was **never used by my runner** (private `XDG_DATA_HOME`), so my
  independent runs cannot have raced the sibling lanes' seeds.

---

## 8. Remaining risks / verification gaps

1. **F1** — the container-sniff discriminator lives outside the tracked lattice
   (M7 undetectable); the pins exist and verify today.
2. **F2/F3** — two declared normalizations/arms are guard-only: the var arm's
   flag plumbing and the Jolt-warning tolerance cannot be mutation-tested
   deterministically in this surface.
3. **F4** — a stalled multi-batch row degrades to a battery timeout; the
   measured margin is ~3.5–4× on a host already at load ~57.
4. **F7** — full-battery greenness is load-shaped; r98 rows were green in every
   run, but a future gate should expect the navagent class to fire under load.
5. **Engine-version coupling** — `cls` pins `eng=4.7.2-stable`, `phys` pins an
   export sha; an engine bump reddens rows rather than re-baselining them
   (intended, but it is the next friction point).
6. The author's own two full runs and the sibling r98-scribe battery were not
   re-derived by this seat; my statements about them are limited to the
   receipts I read (`verdicts.json`, manifests).

---

## 9. Receipts and repro

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# frozen committed tree
mkdir -p corpus/live/r98-critic/frozen && git archive b6d60b1 | tar -x -C corpus/live/r98-critic/frozen
# r98-only, then two full 333-case batteries (frozen tree)
python3 corpus/live/r98-critic/frozen/corpus/fixtures/run_battery.py \
    --runs $PWD/corpus/live/r98-critic/battery-r98only-1 --only \
    r98_gltflat_load,r98_gltflat_doc,r98_gltflat_sniff,r98_gltflat_extbin,r98_gltflat_cls,r98_gltflat_write,r98_gltflat_tr,r98_gltflat_phys,r98_gltflat_var
python3 corpus/live/r98-critic/frozen/corpus/fixtures/run_battery.py --runs $PWD/corpus/live/r98-critic/battery-full-1
python3 corpus/live/r98-critic/frozen/corpus/fixtures/run_battery.py --runs $PWD/corpus/live/r98-critic/battery-full-2
# independent runner + scanner: 137 cells x 3 reps vs the committed markers
python3 corpus/live/r98-critic/runner.py --reps 3 --work corpus/live/r98-critic/work3 \
        --json corpus/live/r98-critic/runner-rep3.json
# provenance: 137 pinned shas vs the scout's/boundary's own receipts
python3 corpus/live/r98-critic/spotcheck.py
# mutation suite (12 mutants, real battery as judge)
python3 corpus/live/r98-critic/mutate.py
# controls: backend effectiveness + rate-flag reachability
python3 corpus/live/r98-critic/extra.py
# asset custody
(cd corpus/live/r98-boundary && sha256sum -c manifest.sha256 | grep -vc ': OK$')   # 0
(cd corpus/live/r98-scout    && sha256sum -c manifest.sha256 | grep -vc ': OK$')   # 0
```

Receipts (all gitignored, under `corpus/live/r98-critic/`): `env.txt`,
`frozen/`, `battery-{r98only-1,full-1,full-2}/` (+ their `verdicts.json`),
`runner.py` + `runner-{rep3,doc,batch1,batch2,load}.json`, `spotcheck.py` +
`spotcheck.json`, `mutate.py` + `mutations.json` + `mut-*/`, `extra.py` +
`extra.json`, `work/`, `work3/`, `xdg-rep*/`, `genrepro/`, `m7check/`,
`udtest/`.

Provenance: this seat wrote only `corpus/live/r98-critic/**` (gitignored
scratch) and this report. No fixture, probe, asset, runner, contract, axis, or
route was touched; no commit was made. The one `labrat` descendant was
read-only and edited nothing.
