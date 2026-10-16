# r97 simplifier — YAGNI/dead-code review of the committed r97 nodelat landing (`ec27b78`)

Seat: **GAME-DEV-3D r97 SIMPLIFIER**, read-only. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r97-simplifier.md`.
Scope: the committed work commit
`ec27b782f8e1ed0337da75e3dcb1338d09241c83` only — `corpus/fixtures/r97_nodelat.gd`
(+847, new), the ten `corpus/fixtures/r97_probe_*.gd` copies (+1 704, new),
`corpus/fixtures/run_battery.py` (+38/−0, insertion-only; `git diff --numstat
eb641c2..ec27b78` recomputed here), `reports/round-97/r97-author.md` (+218) —
plus its receipts. No fixture edit, no commit; the only **tracked** write this
seat makes anywhere is this report (all receipts land under the gitignored
`corpus/live/r97-simplifier/`). HEAD was `ec27b78` at seat start and at seat
end; `git status --porcelain` shows only other lanes' untracked r98 seeds
(`r98_gltflat.gd`, five `r98_probe_*.gd`, `r98assets/`) and the two pre-existing
untracked sibling reports (`reports/round-94/r94-reviewer.md`,
`reports/round-95/r95-reviewer.md`) — untouched.

**LSP device: unavailable to this seat.** The only MCP server bound to this
session is `rea` (Ghidra/REA binary analysis), which does not answer GDScript,
and no `lsp`/`references`/`definition` tool exists in this toolset — so every
call-site claim below is the **literal census, not semantic proof**. The
landing's shape narrows the gap: the parent has no reflective surface (no
`eval`, no dynamic-name access; its tables are the literal
`ARMS`/`ERR_ALLOW`/`PROJECTS`; children are read by literal `res://` path), and
every fold was **executed** (§1.3–§1.7), with a detection control that resolves
*which* cell moved (§1.7).

Environment: Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`;
`/usr/bin/python3`; 32-core host, **load 72.8–87.1 across every one of the eight
runs** (no quiet baseline on this host — sibling lanes were live; "load
preferred" is satisfied, and every pin below was re-measured under it). One
`ufo-labrat` probe was dispatched (frozen probeParent, exactly one): its file
view did not contain the gitignored `corpus/live/` tree at all and it had no
exec tool, so it returned **UNTESTABLE**; the experiment it was given was run by
this seat instead (§7).

## 0. Verdict

**PASS — no bar-meeting *simplifier* defect. The parent fixture carries 34 net
lines of removable dead weight (SP-1…SP-5), proven at 8/8 battery rows
byte-identical across 7 non-mutant runs *and* 79/79 child receipts byte-identical
to the scout/boundary receipts; a further 6 lines are a pure cell-emitter
deduplication (SP-6, proven the same way); 5 lines of dead bindings live in
three of the ten frozen probe copies (SP-7…SP-9 — proven identical, but
*take-or-drop*: they change 3 of the 10 probe sha256s the landing pins as
"byte-identical copy"). The detection control (probeD1) moved exactly one cell
and reddened exactly one row. Three findings are filed (F-1 fixture header says
44 classes vs the pinned 45; F-2 the `w` census has no consumer; F-3 the xr
"envelope" wording vs the strict `rc=134` pin — re-measured 32/32), none
behavioral.**

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **SP-1** | parent `_scan_lines`: the `w` counter is a **write-only output** — declared, incremented, returned, read by nobody (`\bw\b` hits: the header prose, the decl, the increment, the return literal); drop it and reword the header line that advertised it | **−2 lines** (4 edits) | 2/2 probeA runs 8/8 rows byte-identical; crosscheck 79/79 | **take** |
| **SP-2** | parent `ERR_ALLOW["jolt_soft"]` (4 allowlist lines): no spec ever passes the class (`"e": [... "jolt_soft" ...]` occurs 0×) — unreachable config | **−6 lines** (1 edit) | same probes | **take** |
| **SP-3** | parent `_scan`'s `cap` parameter + `truncated` result key: no spec sets `"cap"`, no caller reads `res["truncated"]`; the whole truncation branch is dead | **−7 lines** (2 edits) | same probes | **take** |
| **SP-4** | parent SUM surface: no spec sets a top-level `"f"` (brace-aware census: 0 of 85 spec literals), so `_cell_text`'s `f`-loop never runs, `sum`/`_sum_line` have no live caller and `SUM_PREFIX` no live reader | **−18 lines** (3 edits) | same probes | **take** |
| **SP-5** | parent `_child_prepare`'s `bound` override: `spec.get("bound", BOUND_S)` — no spec sets `"bound"`; use `BOUND_S` | **−1 line** (1 edit) | same probes | **take** |
| **SP-6** | parent `_run_cells` and `_run_softfloor`'s pinned block are the same 11-line operation; extract `_emit(cells, out)` | **−6 lines** (3 edits) | 2/2 probeB runs 8/8 rows byte-identical; crosscheck 79/79 | **take** (dedup, not dead code) |
| **SP-7** | probes `dssparam.gd`: `_ray`'s `id` is declared/assigned but never printed (the print uses case/size/col/pos/nrm) | **−2 lines** | probeC run 8/8 rows byte-identical; crosscheck **79/79** | **take-or-drop (weak)** — changes 1 of the 10 probe shas (§5) |
| **SP-8** | probes `njoint.gd`: `LA`/`LB` assigned only in the unexercised `prio_l/prio_r` case, never read; `slab()` adds to the tree itself | **−2 lines** | same probeC run | **take-or-drop (weak)** — changes 1 of the 10 probe shas (§5) |
| **SP-9** | probes `r97b_free.gd`: `A` assigned from `_ball()` (which adds to the tree itself), never read | **−1 line** | same probeC run | **take-or-drop (weak)** — changes 1 of the 10 probe shas (§5) |
| **F-1** | parent header (line 71): "all **44** classes exist" vs the pinned `cls` cell `classes=45` (author correction #2 landed in the report, not in the fixture comment) | LOW | code census + marker | **file** (comment accuracy) |
| **F-2** | the `w` census has **no consumer**; the parent header (line 18) and `run_battery.py` (lines 785–786) both advertise "counted in `w`" — taking SP-1 requires a 1-line reword of the tracked runner comment | LOW | code census (§SP-1) | **file** (report accuracy / follow-up) |
| **F-3** | the xr "envelope" wording vs the strict `rc=134` pin: the fixture *requires* the teardown crash (`"rc": 134` on 4 cells); re-measured 8/8 runs, **32/32 crash children, 0 escapes** — the observed distribution is degenerate, exactly as the boundary's "keep the envelope phrasing" note and the author's correction #7 say | LOW | 8-run census (§1.8) | **file** (wording risk, disclosed) |

## 1. Evidence base (all read-only, recomputed here — nothing taken on the author's word)

### 1.1 Committed bytes

sha256 recomputed here (all match `reports/round-97/r97-author.md` where it
pins them):

```
c30aca993686733f43b4b0088f3613131cc25f2c65c7157bd6da3011907b36c5  r97_nodelat.gd
3a2697d97cbd52d49877a0cf86e8fb51f8680e437af03ad1e11153e6bb7e7488  r97_probe_cbedge.gd
61a0a7028a5420e1ebe4e1d6420868eac6c14cb9e170e3753fabac4f3100f188  r97_probe_classdb.gd
89bc3a7f586d82a75ab4cc53d21503377b0c7220104b3100bacad636d057aa1e  r97_probe_crashiso.gd
9a7e61f1dfa62dca6029657435a28561f0251bae53e9d3396f47fdf42de1523e  r97_probe_dssparam.gd
3df22045c2e67d28580c9d98cbd91818cabe2c7804e5444daf239619dbabf7bd  r97_probe_njoint.gd
3fa05680ebbff930eca265ebe840954681f481288e074c00f2ff97ed814d1ef4  r97_probe_r97b_free.gd
d6988ea7ce55865e4f40a7fb7cbf47dc81393b74d98fdb10481430a3d5cac82d  r97_probe_r97b_softfloor.gd
0a2625455d6b1cb79966e4aade59e7ed9f797526804eb6c9842b0287bb830255  r97_probe_soft.gd
9c190acea4e13acdf4d0015266af341fbc7494ee94b972c820751307165b87b4  r97_probe_vehicle.gd
487ca4d375d8d11701889e46b7216d3eb94a3a1117a879b91a1ef4984200652b  r97_probe_xrkeep.gd
0db6f9229307efd7b7c815f2a76b6c5cdc023e4ce7f2eb8526446e6a6dc4fb4f  run_battery.py
```

`run_battery.py` `--numstat` = `38 0`: the 8 r97 tuples + a 14-line comment
block were appended after `r96_joltdet_nc`; no existing byte moved, so no other
round's row can be affected by the insertion. `grep -c '^    ("'` = **324**
cases total, of which **8** name `r97_nodelat.gd` (all `r97_nodelat_*`).

### 1.2 The ten probe copies are byte-identical to their sources

sha256 of every fixture copy equals the matching scout/boundary source
(`corpus/live/r97-scout/probes/*.gd` for the eight scout probes,
`corpus/live/r97-boundary/probes/r97b_{softfloor,free}.gd` for the two boundary
probes; the boundary's own `r97b_*` copies hash the same again) — the
"byte-identical copies" claim holds at this HEAD, and is what makes the child
receipts reproduce the scout's receipts by construction.

### 1.3 Battery runs (the 8 r97 rows each, `--only r97_nodelat_*`)

| run | tree | load start→end | verdict | cells | children | elapsed |
|---|---|---|---|---|---|---|
| `ref1` | committed | 72.8→75.7 | **8/8 PASS** | 79 | 83 | 32 s |
| `ref2` | committed | 75.7→74.3 | **8/8 PASS** | 79 | 83 | 31 s |
| `probeA1` | probeA (−34) | 74.3→75.2 | **8/8 PASS** | 79 | 83 | 33 s |
| `probeA2` | probeA (−34) | 75.2→78.2 | **8/8 PASS** | 79 | 83 | 32 s |
| `probeB1` | probeB (−6) | 78.2→78.0 | **8/8 PASS** | 79 | 83 | 33 s |
| `probeB2` | probeB (−6) | 78.0→86.8 | **8/8 PASS** | 79 | 83 | 34 s |
| `probeC1` | probeC (−5, probes) | 86.8→86.5 | **8/8 PASS** | 79 | 83 | 33 s |
| `probeD1` | probeD (mutant) | 86.5→87.1 | **7/8** (mech red) | 79 | 83 | 34 s |

`seeds_unchanged=true` in **every** run (the battery's own seed-digest guard).
The per-row cell counts are exactly as declared: 24/7/6/11/6/13/8/4 = **79
cells**, and each pass spawns **83** children (79 + the 4 deferred-pin census
children, which are counted in `#` diagnostics and never pinned).

### 1.4 Compare (`scripts/compare.py`: marker line, notes, stderr, rc)

```
reference: runs/ref1/…/verdicts.json  cases=8 seeds_unchanged=True verdict=PASS
compare ref2    : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare probeA1 : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare probeA2 : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare probeB1 : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare probeB2 : markerDiff=0 noteDiff=0 stderrDiff=0 rcDiff=0
compare probeC1 : markerDiff=0 noteDiff=1 stderrDiff=0 rcDiff=0
compare probeD1 : markerDiff=1 noteDiff=0 stderrDiff=0 rcDiff=0
  cells moved (1): r97_nodelat_joint/clampbig@gp
TOTAL marker/stderr/rc diffs: 1
```

So the marker lines are byte-identical across all **6 non-mutant comparison
runs (48/48 case comparisons vs ref1)**, and probeD1's 7 non-mutated rows are
byte-identical as well — **55/56** comparisons in total. The only run-variable
surface anywhere is the softfloor deferred-pin census note — `pf0/pf1` = 1/3,
2/2, 0/4×4, 1/3 across the runs (the author saw 0/4…3/1 over 6 reps) — exactly
the declared two-valued startup race, never pinned, and it never moved a pinned
cell. No `rc` or stderr ever moved.

### 1.5 Receipt provenance — the author's own crosscheck, re-run on every tree

`corpus/live/r97-author/crosscheck.py --scratch <run>/scratch` (child logs vs
the scout's/boundary's own receipts, declared normalizations only):

```
ref1    (committed)     79 checked, 79 identical (10 setup-extension), 0 differ, 0 missing
probeA1 (parent −34)    79 checked, 79 identical (10 setup-extension), 0 differ, 0 missing
probeB1 (parent −6)     79 checked, 79 identical (10 setup-extension), 0 differ, 0 missing
probeC1 (probes −5)     79 checked, 79 identical (10 setup-extension), 0 differ, 0 missing
probeD1 (mutant)        79 checked, 78 identical (10 setup-extension), 1 differ, 0 missing
   DIFFER joint clampbig@gp <- njx_proj_clampbig.r1.stdout.txt
```

This is stronger than the marker comparison: the edited trees reproduce the
*scout's own receipts* byte-for-byte, not just the fixture's pinned shas. The
"setup-extension" cells are the boundary's 10 early `sf_*`/`pp_*` receipts whose
`SF setup` line predates the final `r97b_softfloor.gd` (which prints
`pins=`/`pin=`) — re-verified here as exactly the 10 softfloor cells, physics
rows byte-identical.

### 1.6 Pin-vs-receipt audit (independent of the author's crosscheck)

`scripts/verify_pins.py` re-implements the fixture's normalization (banner/empty
drop, WARN1+WARN2 drop, `Load address:` mask, `[n] <hex>` frame mask, `<Class#n>`
→ `<Class#N>`, per-cell allowlist and leak routing) and recomputes the sha256-16
of each mapped source receipt:

- **69/79 pinned shas equal the receipt's sha exactly**; the remaining **10**
  are the declared softfloor setup-line-extension cells (the receipt predates the
  `pins=`/`pin=` fields), and those 10 are byte-identical to their child logs
  under the declared extension (§1.5).
- **pin-vs-childlog: 79/79 in every run, including probeD1** — i.e. the pinned
  digest is exactly the normalized stream of the child that produced it, under
  an implementation independent of the fixture's own scanner.

### 1.7 The detection control is not vacuous (probeD1)

probeD1 = committed + one authored constant in the `njoint` probe copy
(`clampbig` case's `impulse_clamp` `0.1 → 0.2`; the fixture pins the resulting
`clampbig@gp` avb). Result: exactly one cell moved and exactly one row reddened,
mechanistically:

```
FAIL r97_nodelat_joint: exit=0 expected=0 reasons=['exact stdout marker missing']
  ref1   clampbig@gp{rc=0,sha=8ea4d558815717a0,avb=0.0,0.0,-20.0715}
  probeD1 clampbig@gp{rc=0,sha=f1acacab33cb557e,avb=0.0,0.0,-5.5569}
```

All 23 other joint cells and all seven other rows are byte-identical to ref1,
`seeds_unchanged=true`, and the crosscheck flags the same single cell. The
comparator therefore resolves *which* cell moved, not just "stdout differs" — a
"0 diffs" result from probeA/probeB/probeC means what it says. (Note the fixture
itself still prints `PASS` for that arm: the knob mutation changes a pinned
*value*, and the battery's exact-marker check is the layer that catches it — the
same structure as r96's F-2.)

### 1.8 The known-risk surfaces, re-measured

- **xr (`rc=134` distribution).** 8/8 runs, all markers identical: 4 cells pin
  `rc=134` (`cls@gp`, `cls@jolt`, `iso_xrs@gp`, `iso_xrs@jolt`) and 4 pin
  `rc=0` (`iso_clean@gp`, `xr_same`, `xr_keep`, `xr_dbl`); 4 child logs per run
  carry `handle_crash` → **32/32 crash children, 0 escapes** across this seat's
  runs (boundary: 66/66; author: 48-run sweep + 3 batteries green). The pinned
  class is the observed degenerate distribution; the "envelope" wording is the
  header's, and the author discloses it (F-3).
- **softfloor two-valued census.** Only `pf0/pf1` notes vary; no pinned cell
  ever moved (§1.4), and `--pins=now` (`pf=0`) cells are pinned
  (`collide_now@gp/@jolt`, `pinmid_now@gp`).
- **ClassDB census 44→45.** The pinned cell says `classes=45,noinst=5` on both
  backends; the fixture's own header still says 44 (F-1). The author's report
  carries the correction; the cell is right.
- **Boundary-surviving claims.** All 79 pinned cells' child receipts are
  byte-identical to the scout/boundary receipts (§1.5) and 79/79 pinned digests
  re-derive from them (§1.6) — the landing pins the replayed surface only.

## 2. Census: what in the landing is dead

`scripts/census97.py` (textual), `scripts/speckeys.py` (brace-aware spec-literal
scanner), `scripts/deadvars.py` (read/write census), outputs under
`corpus/live/r97-simplifier/`:

- **Parent `r97_nodelat.gd`: 42 top-level declarations, zero unused.** Every
  const/var/func has ≥1 use outside its definition (the only zero-use hit is
  `_initialize`, the engine lifecycle callback — false positive); no
  function-scope local is write-only.
- **Spec-key surface (85 dict literals, 79 cells):** keys read but never set at
  spec top level: **`f`, `bound`, `cap`** (all three: 0 spec literals) — dead
  knobs. All other read keys (`n p pr c rpre req rdiff feq x e rc tag at eargs
  dir body probe case`) are set by at least one spec; `arm`/`parts`/`notes`/
  `run_prefix`/regex members all live.
- **`ERR_ALLOW` classes:** `gp_soft` (1 cell), `xr` (3), `crash` (4) used;
  **`jolt_soft` unreachable** (0 cells pass it).
- **`SUM_PREFIX` (10 keys) ↔ spec probes (10): exact** — but the only reader is
  the dead `f`-loop chain, so the whole surface is dead together.
- **`PROJECTS` (5 bodies) ↔ spec bodies: exact.** All 5 bakes referenced.
- **ARMS (5 arms, 54 cells) + softfloor (13) + xr (8) + freegrain (4) = 79 cells
  ↔ the 8 battery rows: exact.** Every arm has a row, every row's arm is
  handled, no duplicate row name; 324 battery rows total, 8 r97.
- **Probe copies:** 10/10 referenced and byte-identical to their sources; no
  unreferenced function in any of them; 3 files carry 4 dead bindings
  (SP-7…SP-9).
- **Duplicated logic (taken):** the `_run_cells`/`_run_softfloor` emitter block
  (SP-6). **Seen, not taken:** `_run_xr` (and, post-SP-6, `_run_softfloor`)
  builds a `byname` map that no cell of those arms can read (their specs have no
  `req`/`rdiff`/`feq`) — a 2-line win that would break the uniformity of the
  emitters; filed COSMETIC, not taken.

## 3. Taken folds — SP-1…SP-5 (−34 lines, probeA, parent only)

`scripts/apply_probeA.py` (every anchor asserted unique/counted, aborts
otherwise); diff `probes/probeA.diff` (+6/−40, net **−34**, 847 → 813); sha256
of the edited fixture
`ff1bba64097f74e986c024f86c3bcc013526cee23cf5363baa7cecc1917520d1`.

| edit | committed lines | Δ | what |
|---|---|---|---|
| SP-1 counter | 399 | −1 | `var w := 0` |
| SP-1 increment | 410 | −1 | `w += 1` (the WARN1+WARN2 skip stays) |
| SP-1 return key | 443 | 0 | `"w": w, ` out of the dict |
| SP-1 header | 18 | 0 | "— counted in `w`;" → "— dropped before hashing;" |
| SP-2 class | 130–135 | −6 | the unreachable `jolt_soft` allowlist entry |
| SP-3 `_scan` | 446–458 | −6 | `cap` param + truncation branch + `truncated` key → `var txt := f.get_as_text()` |
| SP-3 call site | 603–604 | −1 | drop `specs[i].get("cap", 0)` |
| SP-4 f-loop | 500–502 | −3 | `var sum := _sum_line(...)` + the never-run `f` loop |
| SP-4 `_sum_line` | 472–477 | −8 | the function + its 2 blank separators |
| SP-4 `SUM_PREFIX` | 114–119 | −7 | the const block |
| SP-5 `bound` | 566/569 | −1 | use `BOUND_S` directly |

**Proof:** probeA1 + probeA2 = 8/8 rows PASS, marker lines byte-identical to
ref1 (0 diffs), stderr/rc identical, `seeds_unchanged=true`, **and** the
author's crosscheck 79/79 against the scout/boundary receipts. SP-1 is exercised
by every row (the scanner runs on every child, and the Jolt warning still gets
dropped from the hash — the drop is load-bearing, the count was not); SP-2/3/4
are exercised by the absence of any behaviour change on every row; SP-5 by every
child spawn. Residual risk of SP-3: with the truncation branch gone a runaway
child's log is read whole — every child log in ref1 is ≤ **4 669 bytes** (the
crash dumps), so the facility was never engaged.

## 4. Dedup fold — SP-6 (−6 lines, probeB, parent only)

`scripts/apply_probeB.py`; diff `probes/probeB.diff` (+12/−18, net **−6**,
847 → 841); sha256
`259d32fb0062923763d48984c6504431405a13da08f4ed00cd3b4cbc433d781a`.

`_run_cells`' 19-line body and `_run_softfloor`'s 11-line pinned block are the
same operation (build `byname` → `_cell_text` → `_cell_ok` → `notes`). The fold
extracts `_emit(cells, out) -> bool` and both call sites delegate. **Proof:**
probeB1 + probeB2 = 8/8 rows PASS, 0 marker/stderr/rc diffs vs ref1,
crosscheck 79/79.

## 5. Probe copies — SP-7…SP-9 (−5 lines, probeC) — take-or-drop

`scripts/apply_probeC.py`; diffs `probes/probeC/*.diff` (+3/−8, net **−5**,
3 files):

| file | dead binding | Δ |
|---|---|---|
| `r97_probe_dssparam.gd` | `_ray`'s `id` — declared `"-"`, assigned `collider_id`, never printed | −2 (2 edits) |
| `r97_probe_njoint.gd` | `LA`/`LB` — assigned only in the unexercised `prio_l/prio_r` case; `slab()` adds to the tree itself | −2 (2 edits) |
| `r97_probe_r97b_free.gd` | `A` — assigned from `_ball()` (which adds to the tree itself), never read | −1 (2 edits) |

**Proof:** probeC1 = 8/8 rows PASS with 0 marker diffs **and** crosscheck
**79/79** — the child receipts are byte-identical to the scout's even after the
deletions, i.e. the bindings are dead in the executed surface, not just
textually.

**Call: take-or-drop (weak).** The deletions are proven no-ops, but they change
3 of the 10 probe sha256s that `reports/round-97/r97-author.md` pins as
"fixture copy == scout source" (§1.2) and that the child-project byte-identity
story rests on. The *receipts* (the actual contract) are unaffected; the
*file-level provenance table* would need a three-line update. Unlike SP-1…SP-6
this is not dead weight the fixture can observe — the copies are deliberately
frozen, and `r97_probe_dssparam.gd:12`'s own stale claim (it says the query
helper prints `ids=<collider_id list>`, which is exactly why `id` is dead) is
inherited from the scout's source, not introduced here.

## 6. Findings (filed, not this seat's call)

### 6.1 F-1 (LOW) — the fixture header's ClassDB census contradicts its own pinned cell

`r97_nodelat.gd` lines 71–72:

```
#   xr        the ClassDB instantiate+free teardown envelope: all 44
#             classes exist, can_instantiate=false only for the 5 named,
```

The pinned cell reads `cls@gp{…,classes=45,noinst=5,fatal=1}` (and the `@jolt`
twin). The author's correction #2 records the 44→45 fix, and `run_battery.py`'s
r97 comment does not carry the count — the fixture's own header is the one place
still saying 44. Comment-only; the cell is right.

### 6.2 F-2 (LOW) — the `w` census has no consumer, and two comments advertise it

`_scan_lines` increments `w` and returns it; nothing reads the key (SP-1). The
fixture header line 18 ("counted in `w`") and `run_battery.py` lines 785–786
("counted in `w`") both describe a census surface with no reader. Taking SP-1
rewords the fixture line (done in the probe tree); the runner's comment is a
**tracked** file this seat may not touch, so the taker owns that 1-line reword.
If SP-1 is dropped instead, the counter is dead weight whose only mention is
prose — either way the claim "counted in `w`" describes a value nobody consumes.

### 6.3 F-3 (LOW) — "envelope" wording vs a strict `rc=134` pin (re-measured, disclosed)

The header calls the XRServer teardown crash an "rc=134 envelope, pinned as
crash-class not text", while the specs pin `"rc": 134` as the expected exit for
4 cells — i.e. the crash is *required*, not tolerated. Re-measured here: 8/8
runs, 32/32 crash children at `rc=134`, 0 escapes, 0 `rc=0` in the crash set
(and the boundary measured 66/66 with the same degenerate split). This matches
the boundary's instruction to keep the envelope phrasing while recording that
the observed distribution is degenerate, and the author's correction #7
discloses it; filed as a wording risk for the adjudicator, not a defect.

## 7. Labrat probe status (frozen probeParent, exactly one)

One `ufo-labrat` was dispatched with a bounded, read-only, falsifiable
hypothesis (the 8-run marker/note/rc stability claim of §1.3–§1.4). Its return:
**UNTESTABLE** — its file view did not contain the gitignored `corpus/live/`
tree at all (so none of the eight `verdicts.json` trees or the pre-computed
census files were visible), and it had no exec tool. It wrote nothing. The
experiment was therefore run by this seat (§1.3–§1.4), and the labrat's
observation that the evidence lives only in a gitignored scratch is itself
consistent with the task card ("corpus/live is gitignored here").

## 8. Commands (repro)

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
bash corpus/live/r97-simplifier/scripts/prepare_trees.sh     # rebuild probeA–D from committed seeds
bash corpus/live/r97-simplifier/scripts/run_sequence.sh      # ref2, probeA1/2, probeB1/2, probeC1, probeD1
# (ref1 was run first via scripts/run_all.sh ref1 <seed> <runs/ref1>)
REC=corpus/live/r97-simplifier
REF=$(ls $REC/runs/ref1/*/verdicts.json)
python3 $REC/scripts/compare.py "$REF" \
  $(ls $REC/runs/ref2/*/verdicts.json) $(ls $REC/runs/probeA1/*/verdicts.json) \
  $(ls $REC/runs/probeA2/*/verdicts.json) $(ls $REC/runs/probeB1/*/verdicts.json) \
  $(ls $REC/runs/probeB2/*/verdicts.json) $(ls $REC/runs/probeC1/*/verdicts.json) \
  $(ls $REC/runs/probeD1/*/verdicts.json)
for r in ref1 probeA1 probeB1 probeC1 probeD1; do
  python3 corpus/live/r97-author/crosscheck.py --scratch $(ls -d $REC/runs/$r/*/scratch) --verbose
  python3 $REC/scripts/verify_pins.py $(ls $REC/runs/$r/*/verdicts.json) $(ls -d $REC/runs/$r/*/scratch)
done
python3 $REC/scripts/census97.py
python3 $REC/scripts/speckeys.py corpus/fixtures/r97_nodelat.gd
```

Not re-run: the full 324-row battery (the author ran it three times, 2× fully
green + 1 documented pre-existing `phys3d_events_race_class` flake on an
r88-era row this change does not touch). The folds touch only
`r97_nodelat.gd` / the ten `r97_probe_*.gd`, so the 8 r97 rows + the 79-cell
crosscheck + the 79-cell pin audit are the complete behavioral surface of this
change; no other round's fixture is reachable from it.

## 9. Receipts pointer

`corpus/live/r97-simplifier/` (gitignored scratch): `scripts/` (`census97.py`,
`speckeys.py`, `deadvars.py`, `verify_pins.py`, `compare.py`, `apply_probe{A,B,C,D}.py`,
`prepare_trees.sh`, `run_all.sh`, `run_sequence.sh`), `trees/probe{A,B,C,D}/`
(throwaway, byte-reproducible from `prepare_trees.sh`), `probes/` (the edited
fixtures kept as receipt artifacts + diffs), `runs/<label>/<UTCstamp>/`
(`verdicts.json` + `scratch/` with per-cell `child.log`, `project.godot`, probe
copy), `*.log` (per-run wall time + load), `compare.txt`,
`crosscheck.txt`, `pin-vs-receipt.txt`, `runs-census.txt`, `census.txt`,
`speckeys.txt`, `deadvars.txt`, `prepare-trees.txt`.

Provenance: this seat wrote only this report and its scratch tree. No committed
fixture, probe, battery row or report was modified; **no commit made, per
instruction.**
