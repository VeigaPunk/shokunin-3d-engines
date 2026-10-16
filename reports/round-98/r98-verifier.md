# r98 verifier — wave-B gate on committed `b6d60b1`

**VERDICT: VERIFIED.** All 22 assigned checks pass. The committed landing
(`b6d60b1`: `r98_gltflat.gd` + 4 probe copies + 17 vendored assets + 9
insertion-only battery rows, 333 total) reproduces its 137 pinned cells on
the committed bytes under this seat's own harness and its own scanner; every
encoded law was re-measured with this seat's own probe; the disclosed xxd
clobber repair is byte-exact and contained. Findings are LOW/INFO (§7); no
blockers (§8).

Seat: **VERIFIER** (non-author) for `game-dev-3d-shokunin` round 98. Assigned
tree: `b6d60b113513141aad60c4b2423f7c82d639c5e9` ("r98 author: 9 gltflat rows
(333 total) — 137 cells cold-cache import lattice, 17 vendored assets
sha-pinned, 137/137 crosscheck; 333/333 x2"). Task:
`…/tasks/g3d-r98-verifier.md`. Author report `reports/round-98/r98-author.md`;
boundary `r98-boundary.md`; scout `r98-scout.md`.

Environment: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`,
`/usr/bin/python3` `3.14`, 32 threads; **1-min load average 52 → 105 → 77
across the seat** — this host ran 6+ sibling lanes concurrently
(`r95-verifier`/`r95-reviewer`/`r95-scribe` batteries in the 2d province,
`r94-simplifier`, `r98-scribe`'s full battery, `r98-reviewer`'s mutation
runs, `r98-simplifier`'s r98-only battery — the last three all execute
`r98_gltflat.gd` arms against the same `R98Scout` user-data dir). **No `lsp`
device is exposed to this seat's toolset** (same recorded absence as
r85–r97 lanes); this seat made no source edits, so the hand-edit fallback was
never in play. It wrote only `corpus/live/r98-verifier/**` (gitignored via
`corpus/.gitignore: live/`) and this report. No commits, no tracked writes.
The frozen probeParent privilege (one read-only `labrat`) was **not used**:
every assigned claim closed empirically under this seat's own tooling, so
there was no residual falsifiable hypothesis to delegate (§7 F6).

## Byte custody

- At seat start `git rev-parse HEAD` = `b6d60b1`; `git status --porcelain`
  carried only the sibling untracked reports (`r94-reviewer`, `r95-reviewer`).
  At filing the worktree additionally carries a sibling r99 lane's
  **insertion-only** `+29`-line edit to `corpus/fixtures/run_battery.py`
  (9 `r99_animtree_*` rows appended) and 7 untracked `r99_*` fixtures.
  Re-derived at filing: committed CASES **333** is a strict prefix of the
  worktree's 342, and the **9 r98 rows are byte-identical between the
  committed blob and the worktree** (`r98h == r98w`). Nothing of this seat's.
- **Fixture sha matches the author's table**: `r98_gltflat.gd` committed blob
  `47998a95bb0401f7f8475bb0baf0828fa8f8559d2b2b3c174eff8221ab2835db`
  (= claim; worktree copy identical).
- **Probe copies are the sources, not lookalikes**: the four committed
  `r98_probe_*.gd` blobs equal both the scout/boundary probe sources *and* the
  boundary manifest pins — `gltf.gd` `18ba68b7…`, `gltf_tr.gd` `4736126f…`,
  `r98b_inv.gd` `31cd69c1…`, `r98b_mode.gd` `fadcf86c…` (4/4).
- **17 vendored assets: 17/17 match the boundary manifest pins**, and the six
  scout-owned assets also match the scout manifest pins (`badjson.gltf`,
  `badmagic.glb`, `empty.glb`, `nodes_only.glb`, `tri.glb`, `tri.gltf`).
  `ext.bin`, `ext_resuri.gltf`, `tri_upper.GLB` included, as claimed.
- **The disclosed xxd clobber is fully repaired and contained**:
  `r98assets/badmagic_badjson.glb` = `6e813b4c3cc0afad2a2146ad8c54635ab21f5aa902e9c3e95dc40221e23a1747`
  (52 B), content `XXXX` magic + broken JSON chunk — byte-equal to the
  boundary's live copy and to the `gen_assets_r98b.py` recipe
  (`b"XXXX" + struct.pack("<II", 2, 12 + len(chunks)) + chunks`), **not** a
  hexdump. Whole-tree manifests re-verified at filing: **boundary 4252/4252
  and scout 837/837 entries byte-match (0 mismatch, 0 missing)** — no other
  file was touched by the repair.
- **CASES diff is insertion-only**: AST `literal_eval` on the committed blobs
  (`5ab2c0e` → `b6d60b1`): **324 → 333**; `new[:324] == old` tuple-equal;
  removed 0, changed 0, duplicate names 0; composition **274 ordinary + 59
  negative**; the 9 tail rows are `r98_gltflat_{load,doc,sniff,extbin,cls,
  write,tr,phys,var}` on `r98_gltflat.gd` with `expected_exit=0`; marker
  cells across the tail = **137** (21+36+21+21+12+3+2+6+15).
- **137 pinned cells / 137 children per pass** — counted three ways: from the
  fixture's declared spec table (hand-transcribed, `tools/mychild.py`
  `CELLS`), from the pinned markers (137 cell tokens), and dynamically
  (every battery scratch contains exactly 137 `r98t*` child dirs + 137
  `child.log`, **0 `.godot` dirs** — full1 and only2 scratches, §1).

## Per-item verdict table

| # | assigned check | verdict |
|---|---|---|
| 1 | Committed tree loaded; zero tracked writes | **PASS** — HEAD `b6d60b1`; this seat's only writes are gitignored scratch + this report; the one tracked diff is a sibling r99 lane's insertion |
| 2 | Fixture/probe custody (shas, probes = sources) | **PASS** — fixture sha = claim; 4/4 probes byte-identical to scout/boundary sources and boundary manifest pins |
| 3 | 17 vendored assets vs manifest pins (incl. xxd repair) | **PASS** — 17/17 boundary pins, 6/6 scout pins; repaired file byte-exact; live manifests 4255/4255 clean |
| 4 | CASES insertion-only, +9 rows, 333 total (274+59) | **PASS** — strict-prefix tail insert, 0 removed/changed/dups |
| 5 | r98 rows on committed bytes | **PASS** — 9/9 in both full batteries, r98-only 9/9 (race-free), plus 8 direct arm runs of this seat's own (control, three mutants, gd patch, two chunk-bound runs) |
| 6 | Full battery 333 rows on committed bytes | **PASS (r98) / host-limited (overall)** — full1 **330/333**, full2 **330/333**; every failure is a pre-existing non-r98 load flake (§1); 9/9 r98 green in both, observed stdout byte-identical across runs |
| 7 | 137 cells/137 children per pass | **PASS** — static + marker + dynamic counts all 137; 8-way chunk bound observed (max 8 concurrent Godot children); 0 `.godot` in any child |
| 8 | All 137 cells re-derived independently | **PASS** — **137/137 × 4 independent log sources** (author scratch, my rep1, my rep2, battery only2 scratch): rc, gd, `ue`, sha and every field/flag match the pinned markers |
| 9 | Child receipts vs scout/boundary receipts | **PASS** — own crosscheck: **137/137 identical** on the author's scratch and on my own scratch |
| 10 | Scanner fail-closed semantics | **PASS** — the committed fixture's own `_scan_lines` executed on 16 synthetic streams agrees 16/16 with my re-implementation (kept lines, sha, w, lk, ee, ue) |
| 11 | Cold-cache ResourceLoader dead-end | **PASS** — my own probe: `load(tri.glb)=null`, `load(tri.gltf)=null`, `.godot` absent after the run; all 21 load cells `res=null`, `gd=0` |
| 12 | GLTFDocument err=0/7/43 taxonomy | **PASS** — my own probe: ok=0, missing=7, badjson=43, badmagic=43; pinned `err=7,ee=1` vs `err=43,ee=2` separation |
| 13 | Content-sniff both ways; unvalidated length/version | **PASS** — my own probe: GLB-as-`.gltf` 0, JSON-as-`.glb` 0, `magic_truncated` 0, `glb_version3` 0; asset bytes show declared_len 4680 > 584 and version 3 |
| 14 | `res://` blind-concat | **PASS** — observed verbatim in child receipts: `Binary file not found: res://assets/res://assets/ext.bin` (file and buffer paths) |
| 15 | 18-class inventory | **PASS** — my own probe: asked 18, exists 18, instantiable 18, `GLTFSkin` present; pinned `classes=18,asked=18,exists=18,refc=1,srn=false,grn=false,docp=16,stp=40,sup=13` |
| 16 | `write_to_filesystem` byte-equality | **PASS** — my own probe: `gen_bytes=2644`, `file_bytes=2644`, `equal=true`, re-import 0; pinned `gen=fb=2692,eqg=true` |
| 17 | TRS fidelity | **PASS** — my own probe: `PivotB` `(7.0,8.0,9.0)`, `TriMesh` `(1.0,2.0,3.0)`, zero drift |
| 18 | Backend-inert OMI phys | **PASS** — my own runs re-derive `pgsha=cb0a74518de94092`, `bytes=612`, `pgeq=1` on gp/jolt/dummy and identical imports (`body=RigidBody3D,mass=3.5,shape=BoxShape3D`) |
| 19 | tps/ff/ts invariance | **PASS** — all 10 `eq=1` compare cells re-computed from my own runs (tps 30/120/5, `--fixed-fps 60/120`, `--time-scale 0.5`) |
| 20 | Does the gate bite? | **PASS** — control prints the pinned line exactly; probe mutation, observable asset mutation, and a minted `.godot` all move the receipt; a non-observable padding byte does not (§4) |
| 21 | Rep-stability | **PASS** — my two independent 137-child reps: **0 of 137 cells differ** (byte-identical cell values) |
| 22 | Hygiene / red flags | **PASS with LOW findings** — bounded children, validated dirnames, scratch-confined writes, fail-closed cell gate, no dead gates (§6, §7) |

## 1. Batteries executed (all on `b6d60b1` bytes)

| run | dir (`corpus/live/r98-verifier/battery/…`) | context | totals | r98 rows |
|---|---|---|---|---|
| full #1 | `full1/20261016T070331624445Z` | load 52→105; 6+ sibling lanes | **330/333** | **9/9 PASS**, 1.36–5.48 s (Σ25.2 s) |
| full #2 | `full2/20261016T071700244762Z` | load ~100; private `XDG_DATA_HOME` | **330/333** | **9/9 PASS**, 1.12–4.15 s (Σ21.0 s) |
| r98-only #1 | `only1/20261016T071506656185Z` | default env, lanes in r98 arms | 8/9 | `doc` red — **environmental seed race** (§7 F1), 6 cells `err=7` |
| r98-only #2 | `only2/20261016T071605299967Z` | private `XDG_DATA_HOME` | **9/9** | **9/9 PASS** |

- The 9 r98 rows were green in **every** full battery pass, and their observed
  stdout is **byte-identical between full1 and full2 (9/9)** — i.e. both runs
  reproduced the pinned markers exactly.
- Every full-battery failure is a **pre-existing, non-r98 row**: full1 —
  `phys3d_events_freed_space_methods`, `phys3d_joints_free_ops` (20 s
  timeout), `bpy_rbw3d_ops`; full2 — `navagent3d_retarget`,
  `navagent3d_retarget_fixed`, `navagent3d_follow` (the documented navagent
  one-tick load flake, three rows at once under load ~100). No r98 fixture,
  probe or asset is involved in any of them, and the two runs flaked
  *differently*, which is the load-shaped signature the r93–r97 lanes
  recorded.
- `seeds_unchanged=false` in both full runs is **sibling activity**, not
  mutation: full1 saw 7 new `r99_*` fixture files appear mid-run; full2 saw
  the r99 lane's `+29`-line insertion into `run_battery.py`. Reconstructed
  against each run's own before-map: **0 r98/r97 seeds changed, 0 removed**
  in either run; the only deltas are the sibling's additions.
- Per-row wall times (1.1–5.5 s) sit far inside the battery's 20 s per-case
  bound, and match the author's 1.03–3.96 s band once the host load is
  accounted for.
- Children per pass, counted in the scratch: full1 137 dirs / 137 logs /
  0 `.godot`; only2 137 / 137 / 0.

## 2. Independent re-derivation of all 137 cells (four sources)

`tools/vnorm.py` is a **from-contract** re-implementation of the declared
normalization (fixture header lines 15–35) written independently of both the
fixture's GDScript and the author's `crosscheck.py`. `tools/rederive.py`
re-parses each pinned marker out of the **committed** `run_battery.py` blob,
re-reads each child's raw log, and rebuilds `rc`, `sha`, `ee`, `ue`, every
extracted field, and the `beq`/`pgeq`/`eq` comparison flags with its own code
(field extraction hand-written from the probe sources, not parsed from the
fixture).

| log source | result |
|---|---|
| author scratch `corpus/live/r98-author/ftest2` (274 dirs = 137 × 2 reps) | **137/137 fully re-derived, 0 problems** |
| my rep1 (`mine/`, 137 of my own children) | **137/137** |
| my rep2 (`mine_rep2/`, fresh child dirs/pids) | **137/137** |
| battery scratch `only2/…/scratch` (the fixture's own children) | **137/137** |

- Every cell: `rc=0`, `gd=0`, `ue=[]`, `sha` equal to the pin, and every
  pinned field equal to my recomputed value.
- **Rep-stability**: my rep1 vs rep2 cell values are **identical for 137/137
  cells** (no field, sha, or flag moved across processes/child-dir names).
- **Receipt provenance (own implementation)**: `tools/mycrosscheck.py` maps
  each child to the scout/boundary receipt for the same probe+case+backend
  from the receipt naming conventions (not from the author's script) and
  compares raw text after the declared normalizations — **137 checked, 137
  identical, 0 differ, 0 missing** on the author's scratch, and again
  **137/137 identical** on my own scratch. The children reproduce the source
  evidence verbatim.
- **Scanner differential**: the committed fixture's own `_scan_lines()` was
  executed (scratch copy of the committed bytes, `tools/scandiff.gd`) over 16
  synthetic streams covering banner/blank drops, the Jolt warning pair
  (complete, alone, wrong-neighbour), UD prefix masking, `Load address:` /
  frame masking, all 13 allowlist heads, non-allowlisted `ERROR:`,
  `SCRIPT ERROR`/`Parse Error`/`handle_crash`, ObjectDB leak lines, `#N`
  masking and absent allowlists: **16/16 agree** with my scanner on kept
  lines, sha, `w`, `lk`, `ee`, `ue`.

## 3. The encoded laws, re-measured with this seat's own probe

`tools/vprobe.gd` is this seat's own code (not the fixture's probes), run in
a fresh cold project with the 17 vendored assets:

```
V1 load_tri_glb=null            load_tri_gltf=null        (.godot absent after run)
V2 append_ok=0  append_missing=7  append_badjson=43  append_badmagic=43
V3 sniff_glb_as_gltf_err=0  sniff_json_as_glb_err=0  sniff_magic_truncated_err=0  sniff_glb_version3_err=0
V4 append_err=0 gen_bytes=2644 write_err=0 file_bytes=2644 equal=true
V5 nodes err=0 root=NodeScene:Node3D target=PivotB:Node3D pos=(7.0, 8.0, 9.0)
V5 tri   err=0 root=TriScene:Node3D  target=TriMesh:MeshInstance3D pos=(1.0, 2.0, 3.0)
V6 asked=18 exists=18 can_instantiate=18 skin=true
```

Asset byte semantics (parsed directly): `magic_truncated.glb` declares
`length=4680` for a 584-byte file (inflated, unvalidated); `glb_version3.glb`
carries container `version=3` (unvalidated); `glb_as_gltf.gltf` holds GLB
bytes and `json_as_glb.glb` holds JSON text (content sniffing, both
directions); `ext_resuri.gltf` declares `"uri":"res://assets/ext.bin"`, and
the receipts show the engine blind-concatenating it to
`res://assets/res://assets/ext.bin`. Backend-inert physics re-derived from my
own children: `pgsha=cb0a74518de94092` (612 B) on all three backends, equal
to the boundary's own `evidence/phys_gen_sha.txt`, with `pgeq=1` and
identical `imp` cells.

## 4. Does the gate bite?

`tools/sensitivity.py` + `tools/gdtest.py` (scratch copies; committed bytes
never touched):

| experiment | result |
|---|---|
| control: committed fixture, `--arm=doc` | prints the pinned marker **exactly** |
| M1: one byte flipped in `tri.glb`'s BIN-chunk padding | receipt **unchanged** — correct: the cells pin the observable contract, not asset bytes |
| M1b: `"TriScene"` → `"TriScen3"` inside `tri.glb`'s JSON chunk | receipt **differs** (asset-driven movement) |
| M2: probe prints `gen_bytes+1` | receipt **differs** (probe-driven movement) |
| G: scratch-patched fixture mints `.godot` per child | cell text flips to `gd=1` and **differs** from the pinned marker |

So the pinned markers are produced by the measured behavior, not restated.

## 5. The disclosed xxd clobber — verified, not taken on faith

- The committed vendored copy is the *correct* `XXXX`-magic + broken-JSON
  52-byte file (`6e813b4c…`, §Byte custody), not a hexdump of
  `magic_badjson.glb`; the boundary's live scratch copy is repaired to the
  same pin.
- Re-verifying **all** boundary (4252) and scout (837) manifest entries at
  filing: 0 mismatches, 0 missing — the repair touched nothing else, exactly
  as disclosed.
- The author's §3.8 claim that "the crosscheck caught the corruption" is
  structurally true: the corrupted case is `sniff/badmagic_badjson`, whose
  child receipt differs on exactly that asset; the committed fixture's
  crosscheck compares 137/137 receipts (re-verified above).

## 6. Hygiene

`tools/hygiene.py` — 0 failures across: `timeout -s KILL 14` bounds + 8-way
`CHUNK` + batch-deadline kill; dirname rejection of `..`/`/`/`\`/`:` plus a
charset allowlist; fresh per-cell project dirs with the 17 assets copied in;
user-dir seeding limited to 3 files with pre-existing-dir protection;
fail-closed cell gate (`ue` non-empty or `rc` mismatch ⇒ FAIL); battery
rejects any unexpected `ERROR:`/`SCRIPT ERROR`/`Parse Error`/ObjectDB leak
and requires the exact marker; no dead gates (`if false`/`or true`/TODO/
FIXME absent; the single `return true` is the allowlist head match).
Behavioural complements: max **8** concurrent Godot children observed during
an arm; 0 `.godot` minted across this seat's **295 own child dirs** (137 + 137
+ 21 re-runs).

## 7. Findings and remaining risks

- **F1 (LOW, environmental — the only red r98 row this seat ever saw).**
  User-data seeding is not concurrency-isolated: the fixture pins
  `APP="R98Scout"`, seeds `tri.glb`/`ext_bin.gltf`/`ext.bin` into the shared
  `app_userdata/R98Scout` before each child, and `_cleanup_userdir()` removes
  them at arm end. Two fixture instances running concurrently therefore race:
  a foreign cleanup can delete the seeds between prepare and read. Evidence:
  my r98-only #1 `doc` row reddened with 6 cells `err=7`
  (`Can't open file at path "UD/R98Scout/tri.glb"` / `user://tri.glb`) while
  three sibling lanes were executing r98 arms; my own harness hit the same
  race once on `ext_bin_abs` (fixed there with a seed-and-retry). **Not
  reachable inside a single serial battery** (rows run one at a time), which
  is how the committed battery, the author's sweep (driver runs arms
  serially) and my race-free runs all passed. Recommend (operator's call,
  not this seat's): per-run `XDG_DATA_HOME` or a pid-suffixed APP for
  parallel lane hygiene.
- **F2 (LOW).** The cold-premise census `gd` is enforced through the pinned
  marker, not through the fixture's own `_cell_ok()`: a child that minted
  `.godot` still yields the fixture's internal `PASS` (the parent prints
  `gd=1` in the cell), and the *battery* row reds on the marker. Proven by
  the G experiment above. The claim "a child that mints a cache fails the
  row" is true at battery level; the fixture alone would not fail it.
- **F3 (INFO).** Both full runs recorded `seeds_unchanged=false` purely from
  sibling r99 activity (7 new files; a `+29`-line insertion into
  `run_battery.py`). No r98/r97 seed changed or was removed; the committed
  333-row set is what both runs executed.
- **F4 (INFO, host).** The host ran at load 52–105 with 6+ concurrent lanes;
  pre-existing flakes fired in both full batteries (`navagent3d_*` ×3 in
  full2; `phys3d_events_freed_space_methods`, `phys3d_joints_free_ops`,
  `bpy_rbw3d_ops` in full1). None is an r98 row; no r98 row flaked in any of
  the **1117 r98 child logs this seat ran or re-derived** (295 of my own, 548
  from my four battery passes, 274 from the author's scratch).
- **F5 (INFO).** `physgen`'s "612-byte export with one allowlisted
  warning-class line and `err=0`" is pinned as intended (`ee=1` stays in the
  hashed stream); the no-mesh declared-length asymmetry is visible in the
  same stream, so `err=0` is not read as "no diagnostics". Matches the
  author's §3.7.
- **F6 (INFO).** The author's "27/27 arm runs, one distinct PASS line per
  arm" sweep was not re-executed (its receipts are live-scratch); its
  observable consequence — rep-stability of every cell — was re-established
  independently with my own 2×137 children (0/137 cells differ).
- **F7 (INFO).** The warm-cache `PackedScene` flip is explicitly out of
  premise and unpinned; the lattice pins the cold premise only, and the
  census proves coldness per cell.

## 8. Blockers

**None.** No resume mutation was attempted (no `resume_continuity_v1`
preflight was requested or needed); no canonical-runtime judgment was made by
this seat; nothing was committed, pushed or deployed.

## 9. Provenance

This seat wrote only `corpus/live/r98-verifier/**` (gitignored scratch:
`tools/` — `custody.py`, `manifestcheck.py`, `vnorm.py`, `rederive.py`,
`mychild.py`, `mycrosscheck.py`, `scandiff.{py,gd}`, `sensitivity.py`,
`gdtest.py`, `hygiene.py`, `vprobe.gd`; `battery/{full1,full2,only1,only2}`;
`mine/`, `mine_rep2/`, `mine2/`, `vprobe/`, `scandiff/`, `sensitivity/`,
`gdtest/`, `chunk/`, `udhome/`) and this report. No tracked file was created,
modified or deleted by this seat; no commit was made.
