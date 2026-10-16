# r98 scribe — custody + consistency audit of the committed r98 gltflat landing (`b6d60b1`)

Seat: GAME-DEV-3D r98 SCRIBE. Repo `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Audit window: HEAD **`b6d60b113513141aad60c4b2423f7c82d639c5e9`**
(`2026-10-16 04:02:57 -0300` = 07:02:57Z, *"r98 author: 9 gltflat rows (333
total) — 137 cells cold-cache import lattice, 17 vendored assets sha-pinned,
137/137 crosscheck; 333/333 x2"*). `git status --porcelain=v1` at audit start =
**2 lines** (`?? reports/round-94/r94-reviewer.md`,
`?? reports/round-95/r95-reviewer.md` — r94/r95 wave leftovers). Read-only audit
plus **one fresh full battery run of the committed bytes under the ambient
sibling load** (§4), **one r98-only run** and **one doc-row retry** (§5), **two
crosscheck reproductions** (§6.1), **one independent byte-level replay of the
boundary's 159 replay receipts** (§6.2), **one independent re-derivation of the
11 boundary-authored assets** (§1.4), and **one dispatched read-only `labrat`
probe** (§8). No fixture, runner, contract, axis, or route touched; **no tracked
write, no commit**. Receipts: `corpus/live/r98-scribe/` (gitignored,
`corpus/.gitignore:1: live/`). No `lsp` device is exposed to this seat and this
seat made no source edit, so the hand-edit fallback was never in play.

**HEAD never moved during the audit.** The concurrent **r99 author lane** wrote
into `corpus/fixtures/` mid-audit (7 new untracked `r99_*` files; a **+29/−0
insertion-only** hunk at `run_battery.py:845`, after the r98 block). The r98
fixture set is byte-identical to HEAD (`git diff HEAD -- corpus/fixtures/r98_*`
is empty), so every number below is measured on the `b6d60b1` r98 artifact set.

Commit contents (`git show b6d60b1 --stat`): **24 files, 1621 insertions, 0
deletions** — `r98_gltflat.gd` +829, four `r98_probe_*.gd` +560 (188+44+184+144),
17 `r98assets/` (11 binary + 6 text-content files), `run_battery.py` +41, this
round's author report +186.

---

## 1. Custody — manifests, tracked bytes, seed maps, and the clobber chain

### 1.1 Manifests (replayed)

| manifest | entries | OK | FAILED | census |
|---|---|---|---|---|
| `corpus/live/r98-scout/manifest.sha256` | 837 | **837** | 0 | no self-entry |
| `corpus/live/r98-boundary/manifest.sha256` | 4252 | **4252** | 0 | file census: `runs/` 2912, `runs_hogs/` 1113, `proj*` 196, `assets/` 19, `evidence/` 5, `probes/` 4, drivers 2, log 1 |

Both replays `rc=0` (`custody-scout-sha-check.log`,
`custody-boundary-sha-check.log`). This independently re-verifies the author's
§3.8 claim that *all* 4252 + 837 entries byte-match their pins after the repair.

### 1.2 Tracked bytes

```
47998a95bb0401f7f8475bb0baf0828fa8f8559d2b2b3c174eff8221ab2835db  r98_gltflat.gd   (report: same)
18ba68b7065afdce…  r98_probe_gltf.gd     == scout/probes/gltf.gd          (cmp)
4736126f3c148fb2…  r98_probe_gltf_tr.gd  == scout/probes/gltf_tr.gd       (cmp)
31cd69c1988b8cbe…  r98_probe_r98b_inv.gd == boundary/probes/r98b_inv.gd    (cmp)
fadcf86c0c9dbd71…  r98_probe_r98b_mode.gd== boundary/probes/r98b_mode.gd   (cmp)
```

`corpus/live/r98-author/RECEIPTS.md`: **22 rows** (parent + 4 probes + 17
assets), every digest 64-hex and every digest re-verified against the on-disk
bytes — **22/22 OK, 0 malformed** (contrast the r97 receipts' 62-hex row).

### 1.3 Seed custody

Each of the author's three battery runs carries a **116-entry** `seed_digests`
map; this seat re-hashed all 116 files on disk — **0 bad, 0 missing**, and the
current map's key set equals the author's map exactly (no adds/removes/changes
since run 2). `seeds_unchanged=true` in all three author runs; my own runs'
flag is discussed in §4/§7 F6.

### 1.4 The disclosed xxd clobber — asset bytes vs manifest pins (task item)

**The landing passes the byte check, and the clobber's blast radius is wider
than the disclosure says (F1).**

- All **17** vendored fixture assets byte-match their manifest pins: the 6
  scout assets match the scout *and* boundary manifests; the 11
  boundary-authored discriminators match the boundary manifest
  (`ext.bin 8dd47db8…`, `ext_bin.gltf 479676d9…`, `ext_resuri.gltf
  20d04909…`, `glb_as_gltf.gltf 1116006c…`, `glb_version3.glb cc0239db…`,
  `json_as_glb.glb 999e2c08…`, `magic_badjson.glb 35631cf9…`,
  `magic_only.glb 54267b82…`, `magic_truncated.glb 05f153fe…`,
  `tri_upper.GLB 1116006c…`, and the repaired
  **`badmagic_badjson.glb 6e813b4c3cc0afad2a2146ad8c54635ab21f5aa902e9c3e95dc40221e23a1747`**).
- **Independent re-derivation:** the 11 boundary-minted assets were regenerated
  from the boundary's own `assets/gen_assets_r98b.py` into this seat's scratch
  (`asset-regen/`), and **11/11 are byte-identical** to the fixture copies and
  to the manifest pins — including the repaired file.
- The committed blob equals the worktree file
  (`git show b6d60b1:… | sha256sum` = `6e813b4c…`, 52 bytes).
- The six boundary receipts for the clobbered case (`r98b_mode_proj{,_jolt,_dummy}_badmagic_badjson.r{1,2}`)
  show the `XXXX`-magic JSON-parse path (`… got 'XXXX' at line: 0`) with
  `append_err=43` and exactly the two `jsparse`-allowlist ERROR lines; the
  committed fixture's child receipts reproduce them line-for-line.
- **Blast radius:** `corpus/fixtures/r98assets/badmagic_badjson.glb` itself was
  a **260-byte ASCII xxd hexdump of `magic_badjson.glb`** (sha256
  `a8b04e76559235bb…`, byte-equal to `xxd magic_badjson.glb`) from
  **~06:32:46Z to 06:39:28Z**. The witness is the r97 scribe's own battery
  scratch — `corpus/live/r97-scribe/battery-r97-only/20261016T063859679516Z/scratch/r98assets/badmagic_badjson.glb`
  (copied 06:38:59Z from `corpus/fixtures/` with `shutil.copy2`, mtime
  preserved 06:32:46) — and the r97 scribe's own receipt
  (`reports/round-97/r97-scribe.md:206`: *"a sibling r98 file
  (`r98assets/badmagic_badjson.glb`) changed mid-run"*). Both the live copy and
  the fixture copy carry repair mtime **06:39:28Z**; no other copy under
  `corpus/live/` (1223 checked, size-52) carries the hexdump.

So the final bytes are correct and receipt-consistent, but the report's
*"live scratch, not a tracked seed"* and *"(no other file was touched)"*
(§3.8) understate the event — see **F1**.

---

## 2. Claim arithmetic — every author number re-measured

| claim (author report) | measured | verdict |
|---|---|---|
| "Before: 324 (265 ordinary + 59 negative) · After: 333 (274 + 59) = +9 r98 rows" | AST census: `ec27b78` = **324 (265+59)**, committed = **333 (274+59)**; the 324-name list is a strict prefix of the 333 list; the 9 added names are exactly `r98_gltflat_{load,doc,sniff,extbin,cls,write,tr,phys,var}` | **verified** |
| "`run_battery.py` +9 rows, insertion-only" | `git diff --numstat ec27b78 b6d60b1 -- corpus/fixtures/run_battery.py` = **41 + / 0 −**; single hunk after `r97_nodelat_freegrain` (comment block + 9 tuples) | **verified** |
| "9 arms, **137 pinned cells**, **137 bounded children per battery pass**" | cell census from `_arm_cells` + `_run_phys`: 21+36+21+21+12+3+2+6+15 = **137**; children counted in every author scratch (`ftest` 137, `ftest2` 274 = 2×137, 3 battery scratches 137 each) and in **both** of this seat's scratches (137, 36) | **verified** |
| "Authoring sweep … 27/27 arm runs PASS, one distinct PASS line per arm, byte-identical across reps and scratch dirs" | `run1/` = 9 arm runs on `ftest`, `run2/` = 18 arm runs on `ftest2`; per arm **exactly 1 distinct PASS line across all 27**, and each line is **byte-equal to the committed `CASES` marker** (9/9 arms) | **verified** |
| "Crosscheck: 137 checked, 137 identical, 0 differ, 0 missing" | reproduced with the author's tool on the author's `ftest2` **and on this seat's own fresh full-run scratch** (§6.1) | **verified** |
| "r98-only pre-run 9/9; full run 1: 333/333; run 2: 333/333; all `seeds_unchanged=true`" | each `verdicts.json` re-read: 9/9 (only = the 9 r98 names); 333/333 ×2; flag `true` ×3; the two full runs' seed maps are equal | **verified** |
| "battery-row wall times 1.03–3.96 s" | author r98 rows: min **1.028 s** (`tr`), max **3.963 s** (`doc`) across the three runs | **verified** |
| "No documented flake class fired in either full run" | both runs fully green; the only byte-level differences between run 1 and run 2 (329/333 identical) are the unpinned `#` census lines of `r92_animphys_idlemode`, `r96_joltdet_ffps`, `r96_joltdet_nc`, `r97_nodelat_softfloor` — both runs `PASS` | **verified** |
| "the ten probe copies… under their ORIGINAL `res://` names" (r97-style custody) | r98 analogue: `_child_prepare` copies `res://r98_probe_<name>.gd` → `<child>/<name>.gd` and runs `--script res://<name>.gd` (`r98_gltflat.gd:630-640`); a child dir holds exactly `{project.godot, <probe>.gd, assets/, child.log}` | **verified** |
| "post-run census pins `gd=0` on every cell" | 137/137 children `.godot`-absent in all three author battery scratches, `ftest`/`ftest2`, and this seat's two runs | **verified** |

---

## 3. The author's corrections vs the named reports — all re-derived from receipts

1. **18 classes, not 17.** The scout's own receipt
   `gl_proj_cls.r1.stdout.txt` prints **18** `CLS` lines including
   `GLTFSkin … methods=20` (its §0 table has 17 rows — the correction is
   right); the boundary's `r98b_inv_proj_inv.r1` prints
   `INV n_asked=18 n_exists=18 n_refcounted=1`; the fixture pins
   `classes=18, asked=18, exists=18, refc=1`.
2. **`set_root_nodes` lives on `GLTFState`.** `r98b_inv_proj_props.r1`:
   `has_set_root_nodes=false`, `has_get_root_nodes=false`, `docp=16`,
   `stp=40`, `state_rootlike_methods=get_root_nodes,set_root_nodes`,
   `doc_rootlike_methods=get_root_node_mode,set_root_node_mode`; the fixture
   pins `srn=false,grn=false,docp=16,stp=40`.
3. **Content-sniff, not extension.** Boundary receipts: `glb_as_gltf.gltf`
   (GLB bytes) `err=0`, `json_as_glb.glb` (JSON text) `err=0`,
   `magic_truncated.glb` (+4096 declared length) `err=0`, `glb_version3.glb`
   (version 3) `err=0`, `magic_only`/`magic_badjson`/`badmagic_badjson`
   `err=43` — exactly the fixture's sniff cells.
4. **Cold ≠ warm.** The fixture pins `gd=0` per cell and the warm-cache
   `PackedScene` flip is explicitly out of premise (boundary V12); no r98 cell
   depends on a cache.
5. **`ee` counts are diagnostics, not failures.** Spot-checked ERROR-line
   counts equal the pinned `ee` on every sampled cell: load 2, `doc_missing`
   1, `magic_only` 2, `magic_badjson` 2, `badmagic_badjson` 2,
   `ext_*` 4, `phys_import` 1 — all at `rc=0`.
6. **`ResourceLoader.exists()` falsified both ways.** `r98b_inv_proj_exts.r1`:
   `res_exists_glb=false`, `…gltf=false`, `…upper=false`, `…absent=false`;
   fixture pins `exglb=exgltf=exup=exabs=false` with `sup=13`.
7. **`physgen` asymmetry.** `evidence/phys_gen_sha.txt` =
   `cb0a74518de94092… proj 612` ×3 backends; fixture pins
   `pgsha=cb0a74518de94092, bytes=612` and `imp` =
   `body=RigidBody3D,mass=3.5,shape=BoxShape3D` with `ee=1`
   (`Buffer 0 has no data…`) at `err=0`.
8. **The xxd clobber.** Bytes verified (§1.4); the disclosure's blast-radius
   wording is corrected by **F1**.
9. **Dummy cells are inert twins.** `beq=1`/`pgeq=1`/`eq=1` are emitted only
   on non-GP cells against a GP twin, and the boundary's `audit.json`
   `cross_backend` is identical throughout; the fixture never claims physics
   from Dummy.

Also re-derived: `load` dead-end (`No loader found … -> null`, missing file
takes `Resource file not found`), `doc` taxonomy (`err=0` file/gltf/nodes/empty/
buf/abs/user/rel/roundtrip; `err=7` missing; `err=43` badmagic/badjson), the
`res://` blind concat (`Binary file not found: res://assets/res://assets/ext.bin`),
`write_to_filesystem` (`gen=2692, fb=2692, eqg=true, rerr=0, gb=1500`), TRS
fidelity (`PivotB (7,8,9)`, `TriMesh (1,2,3)`), and the `var` baselines.

---

## 4. Fresh full battery on the committed bytes (ambient sibling load)

    python3 corpus/fixtures/run_battery.py \
        --runs corpus/live/r98-scribe/battery-committed      # 07:04:11Z → 07:14:39Z

| measure | value |
|---|---|
| wall / load | **10 m 28 s**; ambient loadavg 73 → 104 (four sibling wave-B batteries in flight: r98-verifier `full1/full2`, r98-critic `battery-full-1`, r98-reviewer sweep, r98-simplifier probes) |
| receipt | `battery-committed/20261016T070411393160Z/verdicts.json` sha `8652e42206fe52ff…` |
| totals | **333 cases, 328 PASS / 5 FAIL** (274 ordinary + 59 negative), `case_timeout_seconds=20` |
| **r98 rows** | **9/9 PASS**, exact `CASES` marker; **9/9 stdout byte-identical to the author's run 1**; elapsed 1.403–4.461 s |
| child census | exactly **137** `r98t*` child dirs, 137 `child.log`, **0** `.godot` |
| seed flag | `seeds_unchanged=false` — **solely** the concurrent **r99 author lane** (7 `r99_*` files added to `corpus/fixtures/`; **0 of the 116 r98-era seeds** changed, all re-verified on disk) |

**The five failures are all outside r98 and all on documented load lists:**

1. `navagent3d_retarget_fixed` — the documented one-tick pre-switch flake;
   this run's signature `before=(1.777816, 0, 1.777816)` is the same family the
   r92-verifier2/r93-baseline/r97 seats filed (1.707105/1.730676/1.754246).
2. `phys3d_events_script_size_gate` — `min_thr drift … v={ "sz_fetch": "granted" }`,
   the r93-baseline F2 "size-gate granted-under-load" class.
3. `phys3d_events_deferred_hang` — same root cause (`refusal=false`, `rc=0`
   instead of the expected `137`), same r93-baseline F2 class.
4. `phys3d_joints_free_ops` — the documented **20 s knife-edge** row
   (16.6 s / 17.5 s in the author's two runs; timed out at 20.037 s here).
5. `navagent3d_detour_mut_ctx_phys` — `step0 final=2.5,0,4.0 expected=2.5,0,5.5`,
   the navagent motion-drift family; **not previously filed** (F7b), non-r98.

**Conclusion (full run):** the committed tree reproduces the whole r98 surface
under load — 9/9 rows green and byte-identical to the author's run 1 — while
the five red rows are pre-existing load-class rows this change did not touch.

---

## 5. Fresh r98-only run (narrow behavioral check) — and a live race hit

| measure | value |
|---|---|
| command | `run_battery.py --only r98_gltflat_{load,doc,sniff,extbin,cls,write,tr,phys,var} --runs …/battery-r98-only` |
| receipt | `battery-r98-only/20261016T071518926880Z/verdicts.json` sha `60ac70a9297cb2cb…` |
| totals | **8/9 PASS, 1 FAIL** — `r98_gltflat_doc`; `seeds_unchanged=true`; 137 children, 0 `.godot` |
| doc failure | `ue=ERROR: Can't open file at path "UD/R98Scout/tri.glb"` on `doc_abs@gp/jolt/dummy` + `doc_user@jolt` — 4 of the 6 user-data cells, `err=7` instead of `err=0` |
| retry | `run_battery.py --only r98_gltflat_doc` at 07:15:50Z: **PASS** (4.533 s); run-level FAIL only from the seed flag (`r99_animtree.gd` changed mid-run) |

The doc failure is **not** an r98 pin defect: it is the fixture's shared
host-global user-data dir (`~/.local/share/godot/app_userdata/R98Scout`) being
cleaned by a *concurrent sibling parent* while this seat's `doc_abs`/`doc_user`
children were importing `user://` — the same collision the in-flight
`reports/round-98/r98-reviewer.md` reproduces (3/6 attempts at 0.3–1.0 s
offsets; the sibling r98-simplifier hit the `ext_bin_abs` variant in the same
minutes). The same row passed in the full run above and in the retry; the
mechanism and its code path are filed as **F2**. Nine isolated two-parent
repro attempts by this seat (`corpus/live/r98-scribe/race/`, with the app name
renamed to `R98ScribeRace` so sibling gates were not perturbed) did **not**
re-hit it — the window is narrow, which is consistent with a rare-but-real
flake, not a deterministic failure.

---

## 6. Provenance — the pins were re-derived, not restated

**6.1 Crosscheck on this seat's own scratch.** The author's crosscheck re-run
against the children **this seat's own full run spawned**:
`== crosscheck: 137 checked, 137 identical, 0 differ, 0 missing`
(`crosscheck-my-scratch.log`). The same tool on the author's `ftest2`
reproduces their number exactly (`crosscheck-author-scratch.log`). So the
137/137 provenance premise holds on a second, independent execution.

**6.2 Independent boundary replay.** Byte-comparing every boundary `r98b_gl_*`/
`r98b_tr_*` receipt against its scout `gl_*`/`tr_*` source: **159/159
byte-identical, 0 differ**. Exit sidecars recount: boundary `runs/` **416/416
rc=0**, `runs_hogs/` **159/159 rc=0**, scout `runs/` **159/159 rc=0** —
matching the boundary report's headline.

**6.3 Clobber-chain forensics.** Manifest replays (§1.1), deterministic
regeneration (§1.4), the boundary receipts' `XXXX` text, and the absence of any
clobbered-hexdump signature in every r98 receipt (labrat, §8) all agree.

---

## 7. Findings (ranked, for the canonical judge)

- **F1 (medium, disclosure / custody accounting — no pinned value affected).**
  The §3.8 disclosure places the xxd clobber in live scratch only ("live
  scratch, not a tracked seed") and says the repair touched no other file, but
  the **tracked seed `corpus/fixtures/r98assets/badmagic_badjson.glb` was a
  260-byte `xxd` hexdump of `magic_badjson.glb` from ~06:32:46Z to 06:39:28Z**
  (witness: the r97 scribe's battery-r97-only scratch copy, sha `a8b04e76…`,
  byte-equal to `xxd magic_badjson.glb`; repair mtimes identical on the live and
  fixture copies at 06:39:28Z). The report is also internally inconsistent on
  this point: the crosscheck could only have caught the corruption if the
  fixture copy the children read was the clobbered one. The **landed bytes are
  correct** (committed blob = `6e813b4c…` = manifest pin; 11/11 regenerated;
  17/17 assets match; 4252/4252 + 837/837 manifests replay), so this is a
  report-accuracy/custody-accounting item, not a defect in the artifact.
- **F2 (medium, concurrency hazard in the fixture's design — gate-pattern
  risk).** The 9 user-data cells (`doc_abs@*`, `doc_user@*`, `ext_bin_abs@*`)
  share one host-global dir keyed by `APP="R98Scout"`; `_child_prepare` seeds it
  and `_run`'s single `_cleanup_userdir()` (line 395) deletes it (or its three
  seeded files, per the one-shot `ud_pre_existed` snapshot at parent init) at
  the end of **every arm**. Any concurrent r98 parent — exactly what the wave's
  parallel wave-B gate pattern produces (verifier/critic/reviewer/simplifier/
  scribe batteries all running the same fixture) — can delete the dir inside
  another parent's seed→read window and spuriously redden those cells with
  `err=7`. **Observed live by this seat** (r98-only `doc` row, §5) and
  independently by the r98-reviewer (3/6 repro) and r98-simplifier (extbin
  variant). No wrong pin: the same row passes serially. The canonical judge may
  want r98 gates serialized, or the fixture's user dir keyed per-pid.
- **F3 (low, gate-mechanism note).** `gd=0` (cold-cache census) and the
  `beq`/`eq`/`pgeq` equality flags are pinned only through the exact-marker
  text; `_cell_ok` itself checks `rc`/`ue`. A child that minted `.godot` or
  diverged across backends would change the text and fail the marker gate, so
  the gate is fail-closed — but the fixture's own comment ("fails the row")
  should be read as marker-level, not `_cell_ok`-level.
- **F4 (low, receipts-doc precision).** §1 says the sweep is "2 reps × 9 arms
  over two independent scratch roots + 1 rep on a third"; measured: `run1` (9
  arms) on `ftest`, `run2` (18 = 2 reps) on `ftest2`, plus one extra `tr` arm in
  `verify1` (a scratch dir not listed in §5). All 27 counted runs are green with
  one distinct PASS line per arm; the "third root" is `verify1`, which carries
  no counted run.
- **F5 (expected, freshness).** `LOG.md`/`SCORECARD.md` still end at **Round
  97** (no r98 block/row) — pre-adjudication, same class as r95/r96/r97 F5/F6.
- **F6 (environmental / custody semantics).** My full run and doc retry report
  `seeds_unchanged=false`, caused **not** by r98: the concurrent **r99 author
  lane** added 7 `r99_*` files to `corpus/fixtures/` and changed
  `r99_animtree.gd` mid-run (and inserted +29 lines into `run_battery.py` at
  line 845). **0 of the 116 r98-era seeds** were added, removed, or modified;
  all 116 digests verify on disk. The r98-only run's flag was `true`. Same class
  as the r97 scribe's F1 and the r98-reviewer's note.
- **F7 (medium-low, environment; two parts).** (a) All five of my full run's
  failures are pre-existing load-class rows outside r98 (navagent one-tick
  `retarget_fixed`; the r93-era `script_size_gate` + `deferred_hang`
  granted-under-load pair; the 20 s knife-edge `joints_free_ops`), reddened by
  ambient load 73→104 from four sibling batteries. (b) **New observation, not
  r98-scoped:** `navagent3d_detour_mut_ctx_phys` failed with
  `step0 final=2.5,0,4.0 expected=2.5,0,5.5` — a navagent motion-drift signature
  I could not find filed in any prior report; it passed in both author runs
  (1.05–1.07 s). File for the flake list; disposition: pre-existing row,
  outside r98 scope.

---

## 8. Dispatched labrat probe (probeParent allowance: 1 of 1)

One read-only `labrat` probe was dispatched with the falsifiable hypothesis
*"the repaired bytes are the original boundary bytes and the r98 evidence chain
for the clobbered case is internally consistent"*. It returned **CONFIRMED** on
all sub-claims, from the files alone:

- (a) all six boundary `badmagic_badjson` receipts (r1+r2 × three backends) are
  identical 13-line files carrying exactly the two `jsparse`-allowlist ERROR
  heads and `append_err=43` (it read all six in full);
- (b) all six fixture child receipts (`ftest2` and the author's run-1 scratch)
  are **line-for-line identical** to those receipts — stronger than the
  declared normalization requires;
- (c) no receipt in `r98-boundary/`, `r98-scout/`, `r98-author/`, or
  `corpus/live/runs/20261016T06*` carries a clobbered-hexdump signature —
  **but it flagged the one hexdump-bodied copy outside those dirs** (the
  r97-scribe scratch), which this seat then ran down into **F1**;
- (d) the sibling `magic_badjson.glb` shows the `glbparse` class while
  `badmagic_badjson.glb` shows `jsparse`, i.e. the classes track the magic
  bytes; the pinned cell `badmagic_badjson@gp{…,sha=f5f63042f1a53cdf,…}` is
  present verbatim in `run1/sniff.r1.stdout.txt`.

It declared one limit: without execution it could not itself hash the live file
— this seat's manifest replays and regeneration (§1.4) close that gap. The
allowance was not re-spent.

---

## 9. Not tested / remaining risks

- **F2 is live.** Any future parallel wave-B gate on this fixture can redden the
  9 user-data cells spuriously; this seat's own full-run doc row passed while
  its r98-only doc row failed in the same minutes.
- The boundary's still-open list is unchanged by this landing: the warm-cache
  `PackedScene` flip (V12, out of premise), skins/animations/textures/cameras/
  lights payloads, `GLTFDocumentExtension` runtime hooks, exported-template
  context, whether OMI bodies enter a physics space once tree-owned, and every
  scout/boundary case not replayed in the 137.
- The `.godot` census is post-hoc: a child that minted *and removed* a cache in
  its own lifetime would not be seen (no such behavior on this surface).
- Hash pins are build-scoped to `4.7.2.stable.arch_linux.ed1daf0bf` on this host
  (corpus convention).
- The full run was not on a quiet host (load 73–104; four sibling batteries +
  the r99 author lane), so the "load vs idle" split for the r98 rows is not
  isolated — though 9/9 passed under it.

**Verdict: AUDIT PASSES.** Custody is intact (837/837 + 4252/4252 manifest
entries, parent + 4/4 probe copies byte-identical to their sources, 22/22
receipt digests, 17/17 assets at manifest pins with the repaired one
independently regenerated, 116/116 seed digests in each author run and on
disk), every author number re-measured (324→333 = +9, 274+59, +41/−0
insertion-only, 137 cells/137 children, 27-run sweep with one distinct
marker-identical PASS line per arm, 1.03–3.96 s rows), all nine corrections
confirmed against the scout/boundary receipts, the boundary headline re-derived
(159/159 replay, 416/416 + 159/159 + 159/159 rc=0), and the committed bytes
reproduce the r98 surface on this seat's own runs: **9/9 r98 rows PASS in the
fresh full battery, byte-identical to the author's run 1**, with **137/137
provenance on this seat's own scratch**. The r98-only doc red and the five
full-run reds are attributed to the shared-user-data concurrency hazard (F2)
and documented non-r98 load flakes (F7) — none changes a pinned r98 value.
Findings F1–F7 are disclosure-accuracy, concurrency-design, gate-mechanism,
receipt-precision, expected-freshness, environment, or pre-existing-flake
items. No commit made, per instruction.
