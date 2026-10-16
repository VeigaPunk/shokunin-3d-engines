# r98 simplifier — YAGNI/dead-code review of the committed r98 gltflat landing (`b6d60b1`)

Seat: **GAME-DEV-3D r98 SIMPLIFIER**, read-only. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r98-simplifier.md`.
Scope: the committed work commit
`b6d60b113513141aad60c4b2423f7c82d639c5e9` only — `corpus/fixtures/r98_gltflat.gd`
(+829, new), the four `corpus/fixtures/r98_probe_*.gd` copies (+560, new),
`corpus/fixtures/r98assets/` (17 vendored assets), `corpus/fixtures/run_battery.py`
(+41/−0, insertion-only; recomputed here), `reports/round-98/r98-author.md` (+186) —
plus its receipts. **Zero tracked writes; the only tracked write this seat makes is
this report** (all receipts land under the gitignored `corpus/live/r98-simplifier/`).
HEAD was `b6d60b1` at seat start; the orchestrator committed the r98 scribe audit as
`938e4e4` during the seat (`git show --stat 938e4e4` = `reports/round-98/r98-scribe.md`
only; `git diff b6d60b1 938e4e4 -- corpus/fixtures` is empty, so no seed moved).

**The working tree moved under this seat.** A sibling lane (r99 author) is writing
into the same seed directory *while the wave runs*: `M corpus/fixtures/run_battery.py`
(+29, inserting nine `r99_animtree_*` rows — 342 cases in the working tree vs the
committed 333), untracked `r99_animtree.gd` + `r99_probe_r99b_*.gd`, and the
battery's own seed guard fired `seeds were modified during the run` on two of this
seat's early runs because of it. Every claim below is therefore pinned to the
**committed** bytes: the battery was run from
`corpus/live/r98-simplifier/seed-frozen/`, a `git archive b6d60b1 corpus/fixtures`
extraction whose 132 files were re-verified byte-for-byte against
`git show b6d60b1:<path>` blobs (0 mismatches).

**LSP device: unavailable to this seat.** `mcp_list_servers` returns exactly one
server, `rea` (Ghidra/REA binary analysis); there is no `lsp`/`references`/
`definition`/`code-action` tool in this toolset, so no server can answer
`r98_gltflat.gd`. **Recorded as unavailability** (same as r97). The landing's shape
narrows the gap — no reflection, no dynamic-name access, tables are literal
(`ARMS`-equivalent `_arm_cells()`, `ERR_ALLOW`, `PROJECTS`), children are read by
literal `res://` path — and every fold below is *executed*, not merely censused.
No rename was performed by this seat.

Environment: Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`;
`/usr/bin/python3`; 32-core host, **load 53.8–107.2 across the seat's 42 battery
invocations** (no quiet baseline — sibling lanes live; "load preferred" is
satisfied and every pin below was re-measured under it). One `ufo-labrat` probe was
dispatched (frozen probeParent, exactly one) and returned a positive result (§8).

## 0. Verdict

**PASS — no bar-meeting *simplifier* defect. The parent fixture carries 14 net
lines of removable dead weight (SP-1…SP-5), a further 12 lines are one cell
emitter instead of three (SP-6, dedup), and 2 lines are a dead binding in one
frozen probe copy (SP-7 — proven identical, but *take-or-drop*: it changes 1 of
the 4 probe sha256s the landing pins as "byte-identical copy"). Every fold is
proven no-op by two independent 9-row battery runs each (137/137 cells
byte-identical to the committed reference), the author's own crosscheck
(137/137 vs the scout/boundary receipts), and an independent pin audit
(137/137 receipts and 137/137 child logs). The detection control moved exactly
6 cells, reddened exactly 1 row, and the crosscheck flagged exactly the same 6
cells. Five findings are filed; F-1 is a MEDIUM reproducibility finding about
the *new* host-user-dir surface r98 introduces (it can false-FAIL 9 of 137 cells
when a second r98 parent runs on the same host), the rest are LOW/INFO and
none is a behavioral defect. The asset ask is clean: the disclosed xxd-clobber
repair is byte-exact against a manifest written before the clobber, and all
17 vendored assets regenerate deterministically to their pins.**

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **SP-1** | parent `_scan_lines`/`_cell_text`: the `w` counter is a **write-only output** — declared, incremented, returned, read by nobody (the header's "counted in `w`" is prose) | **−2 lines** (2 edits + 2-line header reword) | 2/2 probeA runs 9/9 rows byte-identical; crosscheck 137/137; pin audit 137/137 | **take** |
| **SP-2** | parent: the `lk` counter — declared, returned, and read by a `_cell_text` branch that **can never fire** because nothing ever increments it | **−3 lines** (3 edits) | same probes | **take** |
| **SP-3** | parent `_scan`'s `cap` parameter + truncation branch + `truncated` result key: no spec sets `"cap"`, nothing reads `truncated` | **−7 lines** (3 edits) | same probes | **take** |
| **SP-4** | parent `_child_prepare`'s `bound` override: `spec.get("bound", BOUND_S)` — no spec sets `"bound"`; single use, inline `BOUND_S` | **−1 line** (2 edits) | same probes | **take** |
| **SP-5** | parent `_cell_ok`'s `spec.get("rc", 0)`: no spec sets `"rc"` (all 9 rows expect exit 0) — dead knob | **0 lines** (1 edit) | same probes | **take** |
| **SP-6** | parent: `_run_cells`' emit loop and `_run_phys`' two emit loops are the same 11-line operation; extract `_emit(cells, out)` | **−12 lines** (3 edits) | 2/2 probeB runs 9/9 rows byte-identical; crosscheck 137/137; pin audit 137/137 | **take** (dedup, not dead code) |
| **SP-7** | probe copy `r98_probe_gltf.gd`: `_roundtrip`'s `gerr` is declared/assigned and never read | **−2 lines** (2 edits) | probeC run 9/9 rows byte-identical; crosscheck **137/137** | **take-or-drop (weak)** — changes 1 of the 4 probe shas (§5) |
| **F-1** | the fixture's **new host-user-dir surface** (`_seed_userdir`/`_cleanup_userdir`, fixed `APP="R98Scout"`) is not isolated between concurrent parent instances: a second r98 run's arm-end cleanup deletes the seed out from under the first run's children → `doc_abs@*`, `doc_user@*`, `ext_bin_abs@*` false-FAIL | MEDIUM | §7.1 — observed (this seat + **two sibling seats**), forensically pinned, reproduced 5/6 under controlled 2-parent concurrency, 0/8 under isolation | **file** (adjudicator's call; not a law defect) |
| **F-2** | "counted in `w`" is prose with no consumer: fixture header L22–23 and `run_battery.py` L825 both advertise a census nobody reads (taking SP-1 rewords the fixture line; the runner line is a tracked file this seat may not touch) | LOW | §2, §3 | **file** |
| **F-3** | `lk` is a vestige of r97's leak-counter design: r98 routes leaks to `ue` (never to `lk`), so the counter and its emitter branch are unreachable | LOW | §2 | **file** (fixed by SP-2) |
| **F-4** | the `rc` spec knob is inert on this surface: all 9 rows are ordinary (expected exit 0), no spec sets `"rc"`; the fixture carries no negative-control arm | LOW | §2, §3 | **file** (fixed by SP-5) |
| **F-5** | the four probe copies are pinned as "byte-identical to their scout/boundary source" (author's RECEIPTS.md + header L4–8); SP-7 breaks 1 of those 4 shas | LOW | §1.1, §5 | **file** (take-or-drop) |
| **F-6** | `ud_prefix`/`_id_re`/`_frame_re`/`_load_re` are guard-only on this surface (no crash cells; `<Class#n>` and the Jolt warning never observed) — declared as such in the header; **keep** (removing them changes failure semantics for unforeseen logs) | INFO | §2 | **file** (no action) |

## 1. Evidence base (all read-only, recomputed here — nothing taken on the author's word)

### 1.1 Committed bytes

sha256 recomputed here (all match `reports/round-98/r98-author.md` §3 and
`corpus/live/r98-author/RECEIPTS.md` where they pin them):

```
47998a95bb0401f7f8475bb0baf0828fa8f8559d2b2b3c174eff8221ab2835db  r98_gltflat.gd       (829 lines, 31 411 B)
18ba68b7065afdceff51b92a42605696b06662dae5a61e1e7d1320e2c62f29ca  r98_probe_gltf.gd    (188 lines,  6 615 B)
4736126f3c148fb29d9b234400adf27a1d9d1dac63815fc074612977b29f3d5e  r98_probe_gltf_tr.gd ( 44 lines,  1 325 B)
31cd69c1988b8cbe4c7d70b3e8ed2aaf2879cfcf9dc53d8b1fa5791bd4b83454  r98_probe_r98b_inv.gd(184 lines,  6 444 B)
fadcf86c0c9dbd71b23d2e2087c3166e117a9f37f4bad865da97e928102cda60  r98_probe_r98b_mode.gd(144 lines, 5 228 B)
159ea6ba585e227822d8b494ec26bf2c9f049288b4640c1f4324229b901eca63  run_battery.py
```

`run_battery.py` `--numstat b6d60b1^..b6d60b1` = `41 0`: the 9 r98 tuples (18 lines)
+ a 23-line comment block were appended after `r97_nodelat_freegrain`; no existing byte
moved, so no other round's row can be affected. `CASES` literal length at
`b6d60b1` = **333**, of which **9** name `r98_gltflat.gd` (all `r98_gltflat_*`).
The four probe copies are **byte-identical to their scout/boundary sources**
(`corpus/live/r98-scout/probes/gltf.gd`, `gltf_tr.gd`;
`corpus/live/r98-boundary/probes/r98b_inv.gd`, `r98b_mode.gd`), re-verified by
sha here — which is what makes a child receipt reproduce the source receipt.

### 1.2 Asset pin verification (the task's explicit ask — the xxd clobber)

`scripts/verify_assets.py` (`out/verify_assets.txt`):

- **boundary manifest: 4252 entries, 4252 match, 0 differ, 0 missing** (live
  `corpus/live/r98-boundary/` bytes).
- **scout manifest: 837 entries, 837 match, 0 differ, 0 missing.**
- **17/17 vendored `corpus/fixtures/r98assets/*` match their manifest pins** —
  the scout's six (`badjson.gltf`, `badmagic.glb`, `empty.glb`, `nodes_only.glb`,
  `tri.glb`, `tri.gltf`, present in *both* manifests with the same sha) plus the
  boundary's eleven discriminators (`badmagic_badjson.glb`, `ext.bin`,
  `ext_bin.gltf`, `ext_resuri.gltf`, `glb_as_gltf.gltf`, `glb_version3.glb`,
  `json_as_glb.glb`, `magic_badjson.glb`, `magic_only.glb`, `magic_truncated.glb`,
  `tri_upper.GLB`). No vendored file is unpinned.
- **The repaired file is the real container, not a hexdump**:
  `badmagic_badjson.glb` = 52 bytes, sha
  `6e813b4c3cc0afad2a2146ad8c54635ab21f5aa902e9c3e95dc40221e23a1747`, head
  `b'XXXX\x02\x00\x00\x004\x00\x00\x00'` (bad magic `XXXX`, container version 2,
  declared length 0x34 = 52) — identical live-scratch and vendored.
- **The pin predates the clobber**: `manifest.sha256` mtime `2026-10-15
  16:41:08` — the boundary manifest was last written ~11 h before the author's
  disclosed repair (`badmagic_badjson.glb` mtime `2026-10-16 03:39:28` local =
  `06:39:28Z`) and ~13 h before the commit. The repair therefore restored bytes
  that the manifest already pinned.
- **Timeline context (sibling audit, independent).** The r98 scribe's F1 records
  that the *tracked* seed was a 260-byte `xxd` hexdump of `magic_badjson.glb`
  from ~`06:32:46Z` to `06:39:28Z` and was repaired at the mtime above; its
  conclusion ("landed bytes are correct") is exactly what this seat re-derived
  here, and the author's §3.8 wording ("live scratch, not a tracked seed") is a
  disclosure-accuracy item the scribe filed. No pinned value is affected.
- **Determinism, independently**: `out/regen/` re-runs the boundary's own
  `gen_assets_r98b.py` (copied, not edited) over the scout's six inputs in a
  throwaway dir; all **17** regenerated files hash to their manifest pins
  (`out/regen_check.txt`, 17 match / 0 differ). The generator itself is pinned
  (`assets/gen_assets_r98b.py` = `ccdebd3d…`, in the 4252).

### 1.3 Battery runs (the 9 r98 rows; 137 cells, 137 children per pass)

Every run below is `run_battery.py --only <9 r98 rows>`; "frozen" = the
`git archive b6d60b1` seed; "private XDG" = `XDG_DATA_HOME` pointed at a
per-seat scratch dir (absolute path — Godot silently ignores a relative one and
warns on stderr, which reddens every case; discovered the hard way, see §9).

| run | seed | XDG | verdict | cells/children | wall | note |
|---|---|---|---|---|---|---|
| `ref1` | working `corpus/fixtures` | shared | **FAIL 8/9** | 137/137 | 23 s | `extbin` red — F-1 first observation (load 73.0) |
| `ref-shared` | frozen | shared | **PASS 9/9** | 137/137 | 25 s | the published repro, on the frozen seed |
| `ref-private1` | frozen | private (fresh) | **PASS 9/9** | 137/137 | 24 s | `seeds_unchanged=true` |
| `ref-private2` | frozen | private (warm) | **PASS 9/9** | 137/137 | 24 s | fresh-vs-warm user-dir invariance |
| `probeA1`, `probeA2` | probeA (−14) | private | **PASS 9/9 ×2** | 137/137 | 22 s, 23 s | SP-1…SP-5 |
| `probeB1`, `probeB2` | probeB (−12) | private | **PASS 9/9 ×2** | 137/137 | 24 s, 26 s | SP-6 |
| `probeC1` | probeC (−2, probe) | private | **PASS 9/9** | 137/137 | 23 s | SP-7 |
| `probeD1` | probeD (mutant) | private | **FAIL 8/9** | 137/137 | 24 s | intended: `r98_gltflat_phys` red |
| `xdg-shared-1..3` | working | shared | **PASS ×3** | 21/21 | 3 s each | `extbin` only |
| `race-A1..6` / `race-B1..6` | working | shared | **PASS ×12** | 21/21 | 3 s each | extbin alone / with a doc partner |
| `race-pair-1..3` (A,B) | working | shared | **4 FAIL / 2 PASS** | 137/137 | 29–33 s | doc and/or extbin red |
| `race-solo-1..3` | working | shared | **1 FAIL / 2 PASS** | 137/137 | 23 s | extbin red |

All **private-XDG** 9-row runs: **8/8 green on the user-dir cells** (probeD's red is
the intended mutation). All **shared-XDG** 9-row runs: **7 of 11 reddened on
user-dir cells** (`doc_abs@*`/`doc_user@*`/`ext_bin_abs@*`). `seeds_unchanged=true`
in every frozen-seed run; the two runs that report `false` are `race-pair-2` A/B,
where the battery's seed guard caught the r99 lane's new `r99_probe_*.gd` files
appearing under `corpus/fixtures/` mid-run (a *new file*, not a mutated seed —
diffed file-by-file here), not a seed mutation.

`gd=0` re-censused here: **137/137 child dirs carry no `.godot`** in every
checked run (`ref-private1`, `probeA1`, `probeB1`, `probeC1`) — the cold premise
holds, and 137 children spawn per pass as declared.

### 1.4 Compare (`scripts/compare.py`: marker line, notes, stderr, rc)

```
reference: runs/ref-private1/…/verdicts.json  cases=9 seeds_unchanged=True verdict=PASS
compare probeA1 : markerDiff=0 noteDiff=0 stderrDiff=0 rcDiff=0
compare probeA2 : markerDiff=0 noteDiff=0 stderrDiff=0 rcDiff=0
compare probeB1 : markerDiff=0 noteDiff=0 stderrDiff=0 rcDiff=0
compare probeB2 : markerDiff=0 noteDiff=0 stderrDiff=0 rcDiff=0
compare probeC1 : markerDiff=0 noteDiff=0 stderrDiff=0 rcDiff=0
compare probeD1 : markerDiff=1 noteDiff=0 stderrDiff=0 rcDiff=0
  cells moved (6): r98_gltflat_phys/imp@dummy, imp@gp, imp@jolt,
                   physgen@dummy, physgen@gp, physgen@jolt
TOTAL marker/stderr/rc diffs: 1
```

and against the *published* reference (`ref-shared`, shared XDG, frozen seed):

```
compare ref-private1 : markerDiff=0 noteDiff=0 stderrDiff=0 rcDiff=0
compare ref-private2 : markerDiff=0 noteDiff=0 stderrDiff=0 rcDiff=0
TOTAL marker/stderr/rc diffs: 0
```

So **63/63 non-mutant case comparisons (7 comparison runs × 9 rows) are
byte-identical**, and every one of those marker lines equals the committed
`run_battery.py` expectation (the battery's own exact-marker check is the
authority and it passes 9/9 in each). No `#` note ever fired on a non-mutant run.

### 1.5 Crosscheck — the author's own tool, re-run on every tree

`corpus/live/r98-author/crosscheck.py` (child logs vs the scout's/boundary's own
receipts; declared normalizations only). Because a private-XDG child log embeds
the *private* prefix in the six absolute-path cells while the receipt embeds the
host prefix, the child logs are copied and their private prefix is textually
rewritten to the host prefix first (`scripts/crosscheck98.sh`) — exactly the
substitution the fixture's own scanner performs (`ud_prefix` → `UD/`), applied to
the host spelling; 6 of 137 child logs are touched, no other byte.

```
ref-private1   137 checked, 137 identical, 0 differ, 0 missing   (after the rewrite)
   (as-is, without the rewrite: 131/137 — the 6 differing cells are exactly
    doc_abs@* and ext_bin_abs@*, i.e. the absolute-path cells)
probeA1        137 checked, 137 identical, 0 differ, 0 missing
probeB1        137 checked, 137 identical, 0 differ, 0 missing
probeC1        137 checked, 137 identical, 0 differ, 0 missing
probeD1        137 checked, 131 identical, 6 differ  ← exactly imp@{gp,jolt,dummy}
                                                    and physgen@{gp,jolt,dummy}
```

This is stronger than the marker comparison: the folded trees reproduce the
*scout's/boundary's own receipts* byte-for-byte, not merely the fixture's pins.
(The control's physgen cells differ because the `PHYSGEN_SCENE` walk prints
`mass=`, so the child receipt moves too — the crosscheck and the marker agree on
the same 6 cells.)

### 1.6 Pin-vs-receipt audit — independent of the author's crosscheck

`scripts/verify_pins98.py` re-implements the fixture's normalization
(banner/empty drop, WARN1+WARN2 drop, `UD/` prefix, `Load address:` mask, `[n] 0x…`
frame mask, `#<n>` id mask, per-cell allowlist and leak routing — the allowlist
classes and heads are re-derived from the fixture text, including the
`\"`-escaped quotes) and recomputes sha256-16 of each mapped source receipt and of
each child log:

```
ref-private1 : pin-vs-receipt 137 checked, 137 identical, 0 differ, 0 missing
               pin-vs-childlog 137 checked, 137 identical, 0 differ, 0 missing
probeA1      : pin-vs-receipt 137/137 · pin-vs-childlog 137/137
probeB1      : pin-vs-receipt 137/137 · pin-vs-childlog 137/137
probeC1      : pin-vs-receipt 137/137 · pin-vs-childlog 137/137
```

The author's report claims 137/137 crosscheck; this closes the other half —
`sha16(normalize(receipt)) == the pinned sha` — under an implementation that shares
no code with the fixture's scanner.

### 1.7 The detection control is not vacuous (probeD)

probeD = committed + one authored constant in the `r98b_mode` probe copy
(`body.mass = 3.5 → 3.25`; the fixture pins the imported mass and the exported
payload's sha). Result: exactly **6 of 137 cells moved**, exactly **1 of 9 rows
reddened**, `seeds_unchanged=true`, and the crosscheck flagged exactly the same
**6** cells. The comparator therefore resolves *which* cell moved, not just
"stdout differs" — a "0 diffs" result from probeA/B/C means what it says.

### 1.8 The r98 laws, as re-derived here (spot values from `ref-private1`)

The nine rows' pinned cells were reproduced byte-for-byte; the law-bearing cells
read (abridged):

| law | cell (gp unless noted) | re-derived value |
|---|---|---|
| cold-cache `ResourceLoader` dead-end | `load/load_glb`, `load/load_missing`, `load/load_upper@dummy` | `res=null, ee=2, beq=1` |
| `GLTFDocument` door + error taxonomy | `doc/doc_file` `err=0,nodes=2,meshes=1,root=TriScene:Node3D`; `doc/doc_missing` `err=7,ee=1`; `doc/doc_badmagic` `err=43,ee=2`; `doc/doc_empty` `err=0,nodes=0,root=:Node3D` | as pinned |
| round-trip | `doc/roundtrip` | `serr=0,nodes=2,meshes=1,bytes=2696,rerr=0,rtroot=RTSource:Node3D` |
| content sniff both ways + unvalidated length/version | `sniff/glb_as_gltf` `err=0`; `sniff/json_as_glb` `err=0`; `sniff/magic_truncated` `err=0`; `sniff/glb_version3` `err=0`; `sniff/magic_only` `err=43,ee=2`; `sniff/badmagic_badjson` `err=43,ee=2` | as pinned |
| external buffer URIs | `extbin/ext_bin_file` `err=0`; `ext_bin_abs` `err=0`; `ext_bin_buf_good` `err=0`; `ext_bin_buf_wrong` `err=43,ee=4`; `ext_resuri_file` `err=43,ee=4` | as pinned |
| 18-class inventory | `cls/cls` `classes=18,srn=-,recps=tscn,res,scn`; `cls/inv` `asked=18,exists=18,refc=1`; `cls/props` `srn=false,grn=false,docp=16,stp=40`; `cls/exts` `sup=13,exglb=exgltf=exup=exabs=false` | as pinned |
| `write_to_filesystem` byte-equality | `write/write` | `gen=2692,werr=0,fb=2692,eqg=true,rerr=0,w2=0,gb=1500` |
| TRS fidelity | `tr/nodes` `pbpos=(7.0,8.0,9.0)`; `tr/tri` `tmpos=(1.0,2.0,3.0)` | as pinned |
| backend-inert OMI phys | `phys/physgen@gp` `bytes=612,ee=1,pgsha=cb0a74518de94092`; `phys/imp@gp` `body=RigidBody3D,mass=3.5,shape=BoxShape3D,ee=1`; `pgeq=1`, `beq=1` | as pinned |
| tps/ff/ts invariance | `var/doc_file_{t30,t120,t5}` and `{ff60g,ff60j,ff60d,ff120,ts}` | `eq=1` on every compare cell |

## 2. Census: what in the landing is dead

`scripts/census98.py` (`out/census98.txt`) — textual, but every claim is executed:

- **Parent `r98_gltflat.gd`: 51 top-level declarations, zero unused** (the only
  zero-use hit is `_initialize`, the engine lifecycle callback — false positive).
  `CHUNK`/`BOUND_S`/`JOLT`/`DUMMY`/`APP`/`WARN1`/`WARN2` all live; `PROJECTS`'
  six bakes each back ≥1 spec (`gp60` 10, `gp30`/`gp120` 2 each, `jolt60`/
  `dummy60`/`gp5` 1 each); `ERR_ALLOW`'s seven classes are each passed by ≥1 spec
  literal (`noload` 9, `extbuf` 4, `jsparse` 3, `physbuf` 2, `cantopen`/
  `glbparse`/`chunk` 1 each) — **no unreachable allowlist class** (unlike r97's
  `jolt_soft`).
- **Spec keys read but never set at any spec literal: `cap` (1), `bound` (1),
  `rc` (4)**, plus the never-read result key `truncated` — the four dead knobs.
  Every other read key is set somewhere (`cmpsrc`, `pg`, `cmp`, `cmpf`, `eargs`,
  `seedu`, `cwdp`, `e`, `gets`, `last`, `tok`, `between`, `as2`, `count`, `has`,
  `f`, `as`, `sub`, `dir`, `body`, `probe`, `case`, `n`, `p`, `pr`, `c`).
  (`body_class`/`equal_to_gen`/`file_bytes`/`n_asked`/`n_exists`/`n_refcounted`
  are *remap values*, not spec keys — regex false positives, checked by hand.)
- **`w` is write-only**: decl L464, increment L475, return L506, and the only other
  occurrence is the header prose L23. No consumer anywhere.
- **`lk` is never incremented**: decl L465, return L506, and the only readers are
  `_cell_text` L588–589 (`if res.get("lk", 0) > 0: …`) — unreachable, because r98
  routes leaks to `ue` (L500–503) instead of counting them. A vestige of r97's
  leak counter.
- **Probe copies**: 4/4 referenced and byte-identical to their sources; no
  unreferenced function in any of them; one dead local — `gerr` in
  `r98_probe_gltf.gd` (`_roundtrip`, L175 decl / L179 assignment, never read;
  inherited verbatim from the scout's `gltf.gd`).
- **Seen, not taken:** `_run_cells` builds a `byname` map that the `tr` arm cannot
  read (its two cells have no `cmp`) — a ~3-line win that would break the
  uniformity of the emitter and is covered by SP-6's extraction anyway;
  `_extract`'s five rule kinds are all exercised by at least one cell.

## 3. Taken folds — SP-1…SP-5 (−14 lines, probeA, parent only)

`scripts/apply_probeA.py` (every anchor asserted unique/counted, aborts otherwise);
diff `out/probeA.diff` (+9/−23, net **−14**, 829 → 815); sha256 of the edited
fixture `3acaff849187c2bafbcfdcdcc4ca6408409d9f1cb69c140b93cf686ecddf22b4`.

| edit | committed lines | Δ | what |
|---|---|---|---|
| SP-1 decl | 464 | −1 | `var w := 0` |
| SP-1 increment | 475 | −1 | `w += 1` (the WARN1+WARN2 skip itself stays — it is load-bearing) |
| SP-1/2 result keys | 506 | 0 | drop `"w": w, "lk": lk, ` from the returned dict |
| SP-1 header | 22–23 | 0 | "counted in `w` as a guard" → "dropped before hashing" |
| SP-2 decl | 465 | −1 | `var lk := 0` |
| SP-2 branch | 588–589 | −2 | the unreachable `lk` emitter in `_cell_text` |
| SP-3 signature | 509 | 0 | drop `cap := 0` |
| SP-3 branch | 513–518 | −5 | `if cap > 0 … else …` → `var txt := f.get_as_text()` |
| SP-3 result key | 521 | −1 | `res["truncated"] = …` |
| SP-3 call site | 715–716 | −1 | `_scan(logpath, e)` |
| SP-4 | 659/663 | −1 | drop the `bound` override; inline `BOUND_S` |
| SP-5 | 605 | 0 | `== spec.get("rc", 0)` → `== 0` |

**Proof:** probeA1 + probeA2 = 9/9 rows PASS each, marker lines byte-identical to
the committed reference (0 diffs), stderr/rc identical, `seeds_unchanged=true`,
**and** the author's crosscheck 137/137 against the scout/boundary receipts,
**and** the independent pin audit 137/137 (receipt and childlog). SP-1/SP-2 are
exercised by every row (the scanner runs on every child and the Jolt-warning skip
still drops the two lines from the hash — the *drop* is load-bearing, the *count*
was not); SP-3/SP-4/SP-5 are exercised by the absence of any behavior change on
every row. Residual risk of SP-3: with the truncation branch gone, a runaway
child's log is read whole — every child log in `ref-private1` is ≤ **1 974 bytes**
(the `cls/inv` logs), so the facility was never engaged.

## 4. Dedup fold — SP-6 (−12 lines, probeB, parent only)

`scripts/apply_probeB.py`; diff `out/probeB.diff` (+15/−27, net **−12**, 829 →
820); sha256 `375eeb8f6f941852ee7f4d6ffaa65928dd25a46ed2273214ad53ab3dc048626c`.

`_run_cells`' 11-line tail and `_run_phys`' two 8-line emit loops are the same
operation (build `byname` → `_cell_text` → `_cell_ok` → `notes`). The fold extracts
`_emit(cells, out) -> bool` and all three call sites delegate; the phys arm keeps
its two groups (its `cmp` targets are intra-group: `physgen@*` → `physgen@gp`,
`imp@*` → `imp@gp`), and `parts`/`notes` keep their original order. **Proof:**
probeB1 + probeB2 = 9/9 rows PASS each, 0 marker/stderr/rc diffs, crosscheck
137/137, pin audit 137/137.

## 5. Probe copies — SP-7 (−2 lines, probeC) — take-or-drop

`scripts/apply_probeC.py`; sha256 of the edited copy
`6b7b53e6df602d319d127d9e2c1fe16d3bc15db65dc6f4bde4ab7e08c44e6694` (188 → 186
lines):

| file | dead binding | Δ |
|---|---|---|
| `r98_probe_gltf.gd` | `_roundtrip`'s `gerr` — declared `-1`, assigned `0` in the `err == OK` branch, never read (the print uses `bytes.size()`) | −2 |

**Proof:** probeC1 = 9/9 rows PASS, 0 marker diffs, crosscheck **137/137**, pin
audit 137/137 — the child receipts are byte-identical to the scout's even after the
deletion, i.e. the binding is dead in the executed surface, not just textually.

**Call: take-or-drop (weak).** The deletion is a proven no-op, but the four probe
copies are *deliberately frozen*: the fixture header (L4–8) and
`corpus/live/r98-author/RECEIPTS.md` pin them as "byte-identical to their
scout/boundary source", and that identity is what makes a child receipt reproduce
the source receipt by construction. Taking SP-7 changes 1 of the 4 shas and costs a
one-line update to the receipts table (the *receipts* themselves are unaffected).
The binding is inherited from the scout's source, not introduced here.

## 6. Detection control — probeD (mutant, one authored constant)

`scripts/apply_probeD.py`: `r98_probe_r98b_mode.gd`'s `_phys_gen()` authors
`body.mass = 3.5`; mutated to `3.25`. Result: `r98_gltflat_phys` reddens, exactly
6 cells move (`imp@{gp,jolt,dummy}` `mass=3.5→3.25`, `physgen@{gp,jolt,dummy}`
`bytes`/`pgsha`), all 8 other rows byte-identical, crosscheck flags exactly those 6
child receipts, and `seeds_unchanged=true`. The detector chain (exact-marker
battery check → per-cell comparator → receipt crosscheck) is therefore live at
cell granularity in both directions.

## 7. Findings (filed, not this seat's call)

### 7.1 F-1 (MEDIUM) — the new host-user-dir surface is not isolated between concurrent parents

r98 is the **first fixture in this corpus to read/write/delete host user-data
state**: `_seed_userdir()` copies `tri.glb`/`ext_bin.gltf`/`ext.bin` into
`<XDG_DATA_HOME>/godot/app_userdata/R98Scout/` (fixed `const APP := "R98Scout"`,
not pid-namespaced) and `_cleanup_userdir()` deletes those three files — or the
whole dir — at the end of **every** arm run. The fixture's own comment claims
concurrent parents are safe ("child dirs are namespaced by pid so two concurrent
parent instances … can never share a child dir"), but `_d()` namespaces only
*child dirs*; the user dir is shared. Nine of 137 cells read it: `doc_abs@*`,
`doc_user@*`, `ext_bin_abs@*`.

Observed (this seat, `ref1`, 07:04:47Z): `r98_gltflat_extbin` red with
`ext_bin_abs@{gp,jolt,dummy} ue=ERROR: Can't open file at path
"UD/R98Scout/ext_bin.gltf"`. The three failing cells are in chunk 1, whose prep
seeds the file immediately before the children launch (`_child_prepare` →
`_seed_userdir`), so the file was deleted inside the launch→read window.

Corroborated by two sibling seats at 07:15:06Z/07:15:18Z, same signature:

```
r98-verifier/battery/only1/20261016T071506656185Z : FAIL r98_gltflat_doc
  doc_abs@gp ue=ERROR: Can't open file at path "UD/R98Scout/tri.glb"
r98-scribe/battery-r98-only/20261016T071518926880Z : FAIL r98_gltflat_doc
  doc_abs@gp ue=ERROR: Can't open file at path "UD/R98Scout/tri.glb"
```

Forensically pinned (my `race-solo-1`): a 5 ms watcher on the seeded path recorded
all three files `PRESENT` at 07:09:51.996Z (my extbin arm's own seeding) and
`ABSENT` at **07:09:52.320Z**, while my `ext_bin_abs` children were booting
(child.log written 07:09:52.4–52.6) — the res:// cases in the same chunk were
unaffected. The only in-tree actor that deletes exactly those three paths is a
parent's `_cleanup_userdir` (re-checked: no other file in `corpus/fixtures/`
removes those three names). The nearest such event by timestamp is the
r98-reviewer's `mut/M4_ctl_iso` `doc`-row run, whose last children completed
07:09:51.15 and whose arm-end cleanup therefore fires at ~07:09:52.3 — a
timestamp correlation, not a strace; what is proven is (i) the paths were removed
at that instant, (ii) the only in-tree deleter is a parent's arm-end cleanup, and
(iii) several seats were running r98 arms in that window. Sibling seats were live
throughout: a `ps` snapshot at 07:05Z shows r98-verifier's, r98-scribe's and
r98-critic's batteries running, the r99 author's writes land in `corpus/fixtures/`
during the seat, and r98-reviewer's mutation runs occupy the same window.

**Independently filed.** The r98-scribe filed the same hazard as its F2 in
`938e4e4` (observed live on its own `doc` row; nine isolated two-parent attempts
by that seat did not re-hit it), and the r98-reviewer's report records 3/6 repro
attempts at 0.3–1.0 s offsets — the wave converged on this hazard from three
independent directions.

Reproduced and bounded:

- controlled 2-parent concurrency (two 9-row batteries, one host):
  **5 of 6 runs reddened** on `doc`/`extbin`;
- 3 solo runs while siblings were still active: **1 reddened**;
- **private `XDG_DATA_HOME` (isolation): 0 of 8 nine-row runs reddened** on any
  user-dir cell, and 12 extbin-only runs green.

Severity: it reddens pinned cells **non-deterministically** and can only produce a
**false FAIL** (never a false PASS — a race can only remove the file). It does not
make any pinned law false, but under this wave's operating mode (4+ seats, one
host) it is a reproducibility hazard for the verifier/scribe gates. Mitigations for
the taker/operator, in increasing scope: (a) run r98 batteries with a per-seat
absolute `XDG_DATA_HOME` (what this seat did — the pins are XDG-invariant, proven
by `ref-shared` vs `ref-private1/2` marker equality); (b) serialize r98 battery
runs per host; (c) make the surface concurrency-safe in the fixture (e.g. a
per-process subdir or a lock) — note this changes the `UD/R98Scout/...` cell text
and therefore re-pins 9 cells. This seat takes no position beyond disclosure.

### 7.2 F-2 (LOW) — "counted in `w`" describes a census with no consumer

`r98_gltflat.gd` L22–23 and `run_battery.py` L825 both advertise the Jolt warning
as "counted in `w`". Nothing reads `w` (§2). Taking SP-1 rewords the fixture line;
the runner's comment is a **tracked** file this seat may not touch, so the taker
owns that one-line reword. If SP-1 is dropped instead, the counter is dead weight
whose only mention is prose.

### 7.3 F-3 (LOW) — `lk` is a vestige of r97's leak counter

r98's `_scan_lines` routes ObjectDB-leak warnings to `ue` (L500–503) instead of
counting them, so `lk` is never incremented and the `,lk=` emitter in `_cell_text`
can never fire. SP-2 removes all three pieces. Filed for the record because the
dead branch would otherwise look like live output on first read.

### 7.4 F-4 (LOW) — the `rc` spec knob is inert on this surface

All 9 rows are ordinary (expected exit 0) and no spec literal sets `"rc"`, so
`_cell_ok`'s `spec.get("rc", 0)` can only ever compare against 0. Other fixtures in
the corpus do use the knob for negative-control arms; if r98 ever grows one, SP-5
should be dropped. Filed, with SP-5 taken.

### 7.5 F-5 (LOW) — probe-copy provenance vs SP-7

See §5. The four copies are frozen provenance artifacts; SP-7 breaks 1 of 4 shas.
The receipts are unaffected; the file-level sha table needs a one-line update.

### 7.6 F-6 (INFO) — guard-only normalizations, kept

`ud_prefix` masking (live for the 9 user-dir cells), `_id_re` (`<Class#n>`), the
`Load address:`/`[n] 0x…` crash masks and the WARN1+WARN2 skip are declared
guard-only on this surface (no crash cells exist; `<Class#n>` and the Jolt warning
were never observed in any run here). Kept: they are the declared normalization
surface, and removing them would change failure semantics for unforeseen engine
output — the opposite of a simplification.

## 8. Labrat probe status (frozen probeParent, exactly one)

One `ufo-labrat` was dispatched (read-only, no exec) with a bounded falsifiable
hypothesis: *in the committed `r98_gltflat.gd`, `"cap"` and `"bound"` are read but
never set by any spec literal, `lk` is never incremented, and `w` is never read.*
Its return: **all four parts CONFIRMED from the file text** (829 lines readable),
with the literal lines — `specs[i].get("cap", 0)` L716; `spec.get("bound", BOUND_S)`
L659; `var lk := 0` L465 → returned L506 with no increment anywhere; `var w := 0`
L464 → `w += 1` L475 → returned L506 with no consumer. It wrote nothing. Unlike
r97's labrat (which could not see the gitignored tree and had no exec), this probe
was answerable from the tracked fixture alone and returned a positive result.

## 9. Commands (repro)

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
REC=corpus/live/r98-simplifier

# 1. asset pins (manifest coverage, vendored assets, the repaired file, regen)
python3 $REC/scripts/verify_assets.py                    # 4252/4252, 837/837, 17/17
(cd $REC/out/regen && python3 gen_assets_r98b.py)        # 17 regenerated shas = pins

# 2. frozen committed seed (immune to the r99 lane's concurrent fixtures writes)
mkdir -p $REC/seed-frozen && git archive b6d60b1 corpus/fixtures | tar -x -C $REC/seed-frozen --strip-components=2

# 3. runs — shared-XDG published repro, then isolated private-XDG runs
bash $REC/scripts/run98.sh ref-shared   $REC/seed-frozen $REC/runs/ref-shared
bash $REC/scripts/run98.sh ref-private1 $REC/seed-frozen $REC/runs/ref-private1 $REC/xdg
bash $REC/scripts/run98.sh ref-private2 $REC/seed-frozen $REC/runs/ref-private2 $REC/xdg
bash $REC/scripts/prepare_trees.sh                       # probeA..D from the frozen seed
bash $REC/scripts/run_sequence.sh                        # probeA1/2, probeB1/2, probeC1, probeD1

# 4. comparisons, crosscheck, independent pin audit
python3 $REC/scripts/compare.py $(ls $REC/runs/ref-private1/*/verdicts.json) \
    $(ls $REC/runs/probe{A1,A2,B1,B2,C1,D1}/*/verdicts.json)
bash $REC/scripts/crosscheck98.sh $REC/runs/probeA1 probeA1
python3 $REC/scripts/verify_pins98.py $(ls $REC/runs/probeA1/*/verdicts.json) \
    --scratch $(ls -d $REC/runs/probeA1/*/scratch) \
    --xdg-prefix "$REC/xdg/godot/app_userdata/"

# 5. the F-1 race (evidence, not part of the fold proof)
bash $REC/scripts/race_repro.sh          # extbin x6 with a doc partner, x6 alone
python3 $REC/scripts/race_pairs.py --trials 3 --mode both
```

Notes learned the hard way, recorded for the next seat: `XDG_DATA_HOME` must be an
**absolute** path (Godot ignores a relative one and prints a stderr warning, which
the battery classifies as a failure and which perturbs every cell's hash); and the
battery's seed guard fires on *any* new file appearing under `corpus/fixtures/`
during a run, which the r99 lane's uncommitted writes do by design.

## 10. Receipts pointer

`corpus/live/r98-simplifier/` (gitignored scratch): `seed-frozen/` (the
`git archive b6d60b1` seed, 132 files re-verified against `git show` blobs),
`scripts/` (`verify_assets.py`, `census98.py`, `verify_pins98.py`,
`crosscheck98.sh`, `compare.py`, `run98.sh`, `prepare_trees.sh`,
`run_sequence.sh`, `apply_probe{A,B,C,D}.py`, `race_repro.sh`, `race_pairs.py`),
`trees/probe{A,B,C,D}/` (throwaway, byte-reproducible from `prepare_trees.sh`),
`probes/<tree>/` (the edited fixtures kept as receipt artifacts; shas in §3–§5),
`runs/<label>/<UTCstamp>/` (`verdicts.json` + `scratch/` holding the 137 per-cell
`child.log` receipts — 3 408 logs across the 42 runs; the per-cell `project.godot`
/ probe / `assets/` copies and the top-level scratch seed copies were pruned after
the crosschecks to keep this seat's footprint off a host shared with four other
battery-running seats, 891 MB → 241 MB; **the prune was verified harmless by
re-running `crosscheck98.sh` on a pruned scratch → `137 checked, 137 identical`**,
and the `out/*-scratch-udfix/` copies are regenerable by that script), `out/`
(`verify_assets.txt`, `regen_check.txt`, `census98.txt`, `prepare-trees.txt`,
`probeA.diff`, `compare-ref.txt`, `compare-probes.txt`,
`crosscheck-probes.txt`, `pin-audit-*.txt`, `race_*.txt`, `race-*.watch`,
`regen/`), and `*.log` (per-run wall time + load).

Provenance: this seat wrote only this report and its scratch tree. No committed
fixture, probe, asset, battery row or report was modified; **no commit made, per
instruction.**
