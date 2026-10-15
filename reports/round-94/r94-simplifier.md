# r94 simplifier — YAGNI/dead-code review of the committed r94 cannon.js landing (`05e72ef`)

Seat: GAME-DEV-3D r94 SIMPLIFIER, read-only. Scope: the committed work commit
`05e72ef` only — `corpus/fixtures/r94_cannon.gd` (+194, new),
`corpus/fixtures/r94_child.mjs` (+1027, new), `corpus/fixtures/r94vendor/`
(`cannon-es.js` +13023, `three.core.js` +60586, `three.module.js` +19719,
`package.json` +1), `corpus/fixtures/run_battery.py` (+38, insertion-only) —
plus its receipts. No fixture edit, no commit; the only **tracked** write this
seat makes anywhere is this report (receipts land under the gitignored
`corpus/live/`). HEAD was `05e72ef968f218fc7c4f8b2e58a190d2eddd63fc`
with `git status --porcelain` **empty** at seat start; mid-seat a sibling scribe
committed `7cd5ec8` (its own report only, +277 lines) and the seven files of the
r94 landing were **re-hashed unchanged** at the new HEAD (§1.1) — every battery
run below executed those bytes. Deletion probes ran on throwaway copies under
`/tmp/r94simp/`; receipts under `corpus/live/r94-simplifier/`.

Godot `4.7.2.stable.arch_linux.ed1daf0bf`, `--headless`; `node v24.21.0` (fnm)
for every battery run, with `node v26.12.0` (mise) used for the §3.5 runtime
cross-check. Every battery run in this report ran at load **73–126** on the
32-core host (§7).

**LSP device: unavailable to this seat.** The only MCP server bound to this
session is `rea` (Ghidra/REA binary analysis), which does not answer
JavaScript or GDScript, and no `lsp`/`references` tool exists in this toolset —
so every call-site claim below is the **literal grep census and is not
presented as semantic proof**. Three facts narrow the gap for this landing:
(a) `r94_child.mjs` is named by exactly one seed (`r94_cannon.gd:166`), and
`r94_cannon.gd` by exactly one battery row group (19 rows, §1.3); (b) the child
has no reflective surface — `eval`, `Function(`, `globalThis`, dynamic `import(`
are all zero hits; the only dynamic-name access in either file is
`CASES[CASE]` / `ARM_CASES[arm]` / `MODES[mode]` / `NANCASES[name]` /
`ORDER_SCENES[scene]` over **literal** tables, all enumerated in §2; (c) every
deletion candidate was *executed*, not just reasoned about (§3): a wrong "dead"
call turns the probe red.

## 0. Verdict

**PASS — no bar-meeting defect; the landing is 1221 new fixture lines whose
legs all fired, with 22 net lines of genuinely removable dead weight (verified
by executed probes, zero marker delta, byte-identical stdout/stderr/rc on all
19 rows) plus one optional 1-line file, and 4 findings that are re-pin,
report-accuracy or corpus-convention questions, not this seat's call.**

| # | fold | weight | proof | call |
|---|------|--------|-------|------|
| **SP-1** | child: `nextUp` (`:64–75`) — 12-line helper, **1 occurrence in the file** (its own definition); a leftover from the "verbatim port of the scout's lib.mjs semantics" | **−12 lines** | census: 1 occurrence; probeA executed | **take** |
| **SP-2** | child: `be_broadphase`'s `variants` array (`:822` decl + `:826` push) — written on every one of the 5 broadphase runs, never read (the `variants=` token in `be_solver`'s summary is a format-string literal) | **−2 lines** | census: 2 occurrences, both writes; probeA executed | **take** |
| **SP-3** | child: `mat_fric_sweep` (`:628–636`) re-implements `fricSlide`'s scene verbatim (same `Material('g')/('b')`, same 200-half-extent ground, same `(0,0.501,0)` ball, `fixedRotation`, `v0=5`, 2400 steps) instead of calling it | **−8 lines** | side-by-side equivalence (§3.3); probeA executed | **take** |
| **SP-4** | 7 same-line edits: write-only return keys (`buildWorld`'s `boxA/boxB/boxC/opts`, `slideScene`'s `world`, `bounceScene`'s `world`+`firstContact`, `orderRun`'s `world`+`dyn`, `simpleScene`'s `ground`, `tumbleScene`'s `ground`) + the never-read `DEFAULTS.dt` entry | **−0 lines** (7 edits) | per-key reader census (§3.4); probeA executed | **take** |
| **SP-5** | `corpus/fixtures/r94vendor/package.json` (the whole file, 1 line) — its documented job (silencing `MODULE_TYPELESS_PACKAGE_JSON`) **does not reproduce** on either runtime installed here, and the r94 markers already pin `node=v24.21.0` | **−1 file** | probeD (19/19 byte-identical) + 66 cases × 2 runtimes (§3.5) | **take-or-drop (weak)** — §3.5 |

Bar-meeting total: **−22 net lines** of 1221 added fixture lines (probeA:
20 hunks, −31/+9) plus the optional −1 file (probeD), zero marker delta,
verified by execution on the committed bytes. Everything else in the diff is
retained measurement surface (§4, §5).

## 1. Evidence base (all read-only, recomputed here — nothing taken on the author's word)

### 1.1 Committed bytes

`git status --porcelain` empty at seat start; `git rev-parse HEAD` =
`05e72ef…` then `7cd5ec8…` (sibling scribe report, §0 preamble). sha256 of
every file the landing touches, recomputed at the new HEAD:

```
d40a1f75739626778d13115eced5202bf9bd6ab5643e46e92a8973b495a05c77  r94_cannon.gd
c84a8e8a9bb18af1b1846d367b97d15de8138410180ffb5790a30cee972d7508  r94_child.mjs
f0700cbd3a482954949b9d58c1b0f76dcc74767750297647a39d8c40dd63d37c  r94vendor/cannon-es.js
9edde002b066a9a05676a6127f67735b62baf399bdea529f2f7e31657da769e6  r94vendor/three.core.js
9052042d676cb0fdc1ddfefe193053f34b7ac0513a616fdac4535d49987812ea  r94vendor/three.module.js
75310bff016b194c22167683f733bcd0991ba7d1d2a288c77763698eafecf4e8  r94vendor/package.json
b230d29cc0a2423a29d50788500b9693ac29e8ed4f70b5c56ec9ebfa81736eee  run_battery.py
```

The three vendor sha256s are the ones the author's report pins (`f0700cbd…`,
`9052042d…`, `9edde002…`) — the "byte-identical to the npm pins" claim is
recomputed here, not quoted.

### 1.2 Five executions, two of them of the committed bytes

| run | what | result | seeds_unchanged | sum of case time |
|---|---|---|---|---|
| `battery-r94only` | 19 r94 rows, committed bytes | **19/19 PASS** | **true** | 25.6 s |
| `battery-r94only-rep2` | same, independent second execution | **19/19 PASS**, **byte-identical** | **true** | 28.2 s |
| `probes/probeA-runs` | probeA deletions applied (throwaway copy) | **19/19 PASS**, **byte-identical** | **true** | 27.5 s |
| `probes/probeB-runs` | probeA + a 1e-7 scene mutation (detection control) | **8/19 PASS, 11 FAIL** | **true** | 26.2 s |
| `probes/probeD-runs` | probeA **+ `r94vendor/package.json` deleted** | **19/19 PASS**, **byte-identical** | **true** | 26.5 s |

Byte-comparison (`probes/compare.py`, output `probes/compare-results.txt`),
over `stdout` **and** `stderr` **and** exit code, case by case:

```
reference: battery-r94only/20261015T221148093208Z/verdicts.json  cases=19 seeds_unchanged=True verdict=PASS
compare battery-r94only-rep2/…/verdicts.json : cases=19 stdoutDiff=0 stderrDiff=0 rcDiff=0
compare probes/probeA-runs/verdicts.json     : cases=19 stdoutDiff=0 stderrDiff=0 rcDiff=0
compare probes/probeD-runs/verdicts.json     : cases=19 stdoutDiff=0 stderrDiff=0 rcDiff=0
compare probes/probeB-runs/verdicts.json     : cases=19 stdoutDiff=11 stderrDiff=0 rcDiff=1  verdict=FAIL
```

The r94 rows are therefore **byte-stable across four independent executions**
(two of the committed bytes, two of deleted copies) — and the deletion set is
a **no-op on the pinned surface**, including the parent's `{rc,m,o,d}` digest
cells, the single `#` diagnostic (`mod_fixedstep`, `d=1`) and every
`NEGATIVE REJECTED:` line.

### 1.3 The detection control is not vacuous (probeB)

probeB = probeA + `buildWorld`'s ball spawn moved `y 5 → 4.9999999`. **11 of 19
rows FAIL** (marker moved), and the 8 that still pass are exactly the rows whose
scenes do **not** come from `buildWorld` — a mechanistic split, not a partial
detector:

| still PASS (8) | why |
|---|---|
| `det2` (4 cases) | `det_iters_hist` pins iteration **counts**; `det_perturb_track` measures a *difference* between two worlds that both shift; `det_contacts_*` pin contact **ids** |
| `nan` | all 22 cases build their own `simpleScene()`/literals |
| `sync` | `tumbleScene()` |
| `material`, `friction` | `slideScene`/`bounceScene`/`fricSlide` |
| `parity`, `parity2` | `restScene()`/literals |
| `neg_wxyz` | `tumbleScene()` |
| **FAIL (11)** | `det`, `varstep`, `bailout`, `modes`, `order`, `backends`, `neg_dt`, `neg_gravity`, `neg_steps_early`, `neg_elapsed`, `neg_grid` (rc 2→1: its `nx=1` live control `|y−4.997272222| ≤ 1e-9` fires) |

So the byte-identity in §1.2 is a real signal: a 1e-7 scene perturbation is
caught by every row that can see it.

### 1.4 The battery rows

`ast`-parsed `run_battery.py`: **284 CASES** total (265 pre-existing + 19 r94),
**0 duplicate case names**, **0 duplicate markers** (whole battery and r94
subset alike). The 19 r94 rows are 13 ordinary (exit 0) + 6 negative (exit 2),
all on `r94_cannon.gd`, marker lengths 87–6287 chars (32 699 chars of pinned
marker across the 19 rows, 259 distinct `M` lines).

## 2. Arm/leg firing audit — no dead arm, no dead case, no dead leg

**66 CASES keys** in `r94_child.mjs` == **60 `ARM_CASES`** (13+4+6+1+1+9+2+1+4+5+8+4+2)
+ **6 `NEGATIVE`**, computed by extracting both tables and diffing the sets:
`in ARM_CASES but not CASES: []`, `in CASES but not in any arm: []` (after
accounting for the two-line `NEGATIVE` array literal). Each of the 19 rows
therefore spawns exactly its arm's cases, and no case is unreachable.

Independently, the baseline run's scratch tree carries **66 `r94ch_<case>/child.log`
files** — one fresh `node` process per case, exactly as the author claims — and
their content census is:

| quantity | value |
|---|---|
| child logs | 66 |
| `M0`/`M`/`NEGATIVE REJECTED:` lines | **331** |
| `#` diagnostic lines | **1** (`mod_fixedstep`) |
| unclassified non-empty lines (`o`) | **0** |
| `k=v` pairs on `M` lines | 968 |

`o=0` in every one of the 66 logs is the parent's "no unexpected output" gate
(any node warning, stack frame or stray print would move the digest) — it is
exercised, not assumed. The single `#` line is the deliberately unpinned
wall-clock tick count, counted as `d=1` in the `mod_fixedstep` cell.

## 3. Folds with proofs

### 3.1 SP-1 · `nextUp` (12 lines) — dead on arrival

`r94_child.mjs:64–75`. **One occurrence in the file**: its own definition.
Zero callers; no dynamic surface (§LSP note). Provenance: it is part of the
"verbatim port of the scout's `lib.mjs` semantics" (`:40`), and it was already
dead in the scout's library — `corpus/live/r94-scout/proj/probes/scene.mjs:80`
defines and exports it (1 occurrence in that file), `p_det.mjs:5` imports it and
never calls it (1 occurrence: the import). The ULP cell that needed it
(`det_ulp`) uses a plain `ballX` offset instead. Deleting the helper removes 12
lines and changes nothing else: probeA is 19/19 and byte-identical.

### 3.2 SP-2 · `be_broadphase`'s `variants` (2 lines) — write-only accumulator

`:822` `const variants = [];`, `:826` `variants.push({ label, h });` inside the
`run()` closure. Two occurrences; both writes. The only other `variants` token
in the file is inside a **format-string literal** in a different case
(`be_solver`'s `summary`, `variants=${rows.length}` — that reads `rows`, which
*is* consumed by `rows.length`/`new Set(rows).size`/`rows[0]`). The dead array
is the `be_solver` pattern copied without its summary line. Removing both lines
is byte-identical (probeA).

### 3.3 SP-3 · `mat_fric_sweep` re-implements `fricSlide` (9 → 1 lines)

The sweep (`:627–639`) and the helper (`:296–311`) build the same scene:

| element | `fricSlide(mu, mass, v0)` | `mat_fric_sweep` inline |
|---|---|---|
| world | `gravity (0,−9.82,0)` | `gravity (0,−g,0)`, `g=9.82` |
| materials | `Material('g')`, `Material('b')`, both `.friction = mu` | same names, same |
| ground | `Box(200, 0.5, 200)` @ `(0,−0.5,0)`, static, `material: mg` | identical |
| ball | `mass`, `Sphere(0.5)` @ `(0,0.501,0)`, `fixedRotation: true`, `material: mb` | `mass=1`, identical |
| launch | `velocity.set(v0,0,0)` | `set(5,0,0)` |
| loop | 2400 × `step(DT)` + `fricEqMax = max(…, frictionEquations.length)` | identical |
| printed | `d`, `vx`, `fricEqMax`, `a`, `ratio` | `ball.position.x`, `ball.velocity.x`, `fricEqMax`, `predicted` |

`fricSlide(mu, 1, 5)` returns exactly the three measured quantities the sweep
prints, so lines 628–636 collapse to `const r = fricSlide(mu, 1, 5);` (−8 net
lines); `predicted` stays as-is (it is derived from `mu`, not measured). The
`mu` sweep is pinned in `r94_cannon_material`, so this fold is verified by the
same byte-identical probeA run — the 9 `mu<μ>` rows are unchanged.

### 3.4 SP-4 · write-only return keys + one dead config entry (7 same-line edits, 0 lines)

Reader census over the whole child (grep + the call sites of each producer):

| producer | key | readers | verdict |
|---|---|---|---|
| `buildWorld` `:109` | `boxA`, `boxB`, `boxC` | **0** (`.boxA`/`.boxB`/`.boxC` = 0 hits) | dead |
| `buildWorld` | `opts: o` | **0** (`o.steps` is never read; `steps` is handled by `runScene`/`runSampled` via `opts.steps ?? DEFAULTS.steps`) | dead |
| `buildWorld` | `ground` | 1 (`ORDER_SCENES.canon` re-exports it) | **kept** |
| `slideScene` `:277` | `world` | 0 (`mat_all` reads `x/vx/fricEqMax/cmFriction/cmRestitution/pairCm` only) | dead |
| `bounceScene` `:294` | `world`, `firstContact` | 0 (`mat_all` reads `apex`/`bounces`; the local `firstContact` is still used inside the loop) | dead |
| `orderRun` `:214` | `world`, `dyn` | 0 (`orderCase`/`det_order_probe` read `h/ph/contactRows/sigRows/rawSig/canonSig`) | dead |
| `simpleScene` `:129` | `ground` | 0 (the `{...s, note}` spreads and `nan_all` read `dyn`/`ball`/`note`) | dead |
| `tumbleScene` `:148` | `ground` | 0 (all 7 callers destructure `{world, box}` or `{box}`) | dead |
| `DEFAULTS` `:91` | `dt: DT` | **0** (`runScene`/`runSampled` use `opts.dt ?? DT`, never `DEFAULTS.dt`; `DEFAULTS.` hits are `.steps` ×2, `.iterations` ×3, `.tolerance` ×3 only) | dead |

Seven same-line edits, **0 net lines**; probeA proves the pinned surface does
not move. `restScene`'s `ground` is *not* in this set — `par_contact_rest`
reads `ground.sleepState`, which is what makes the census worth doing per key
rather than per producer.

### 3.5 SP-5 · `r94vendor/package.json` (1 file) — the documented reason does not reproduce

The author's report says the file "silences `MODULE_TYPELESS_PACKAGE_JSON` —
would otherwise be an unexpected-stderr failure". Four measurements say that
does not happen on this host:

1. **probeD** = probeA + the file deleted → the full 19-row surface is
   **19/19 PASS and byte-identical** to the baseline (`stdoutDiff=0
   stderrDiff=0 rcDiff=0`), i.e. the parent's `o` counter stays 0 for all 66
   children.
2. **Direct invocation**, `node r94_child.mjs det_base` with and without the
   file: identical logs, no warning line either way.
3. **Minimal reproduction** of the warning's supposed trigger — a typeless
   `vendor/lib.js` containing `export const x = 1` imported from `main.mjs`,
   *and* the same file as a typeless `.js` **entry point**: `x= 1` with no
   warning in either case, with or without a `vendor/package.json`.
4. **The full 66-case child set on both runtimes installed on this host**, with
   the file deleted, against a pristine copy of the committed bytes
   (`/tmp/r94simp/probeE`, no SP edits): **0 diffs** in output *and* exit code
   vs the scribe's committed-bytes `node-variance` receipt
   (`corpus/live/r94-scribe/node-variance/`, which has the file present) —
   `fnm v24.21.0` and `mise v26.12.0` alike. The aggregate sha256 of the 66
   outputs is the scribe's recorded
   `91e9d5bbc08cae8e2c8527b92288333d3712f621fd6d03d277838fd8a4b1d36e` for both.
   Zero `MODULE_TYPELESS` occurrences and **zero unclassified non-empty lines**
   (so `o=0` on both runtimes, not just v24).

This is also why the claim in §LSP/§1 is stated carefully: my first pass found
only `fnm v24.21.0` because `find -maxdepth 5` missed the mise path
(`~/.local/share/mise/installs/node/26.12.0/bin/node`, depth 7); the sibling
scribe's receipts exposed it, and the check was re-run on both.

Additionally, the pin already carries the runtime: every r94 marker ends in
`node=v24.21.0` (the parent probes `node --version` into the PASS line), so a
battery run under a different node fails the row on the version string before a
warning could matter.

**Why this is ranked weak and marked take-or-drop:** the measurement is solid,
but the file is 1 line of insurance against a node that emits the warning
(Node ≤21 needs no warning at all — a typeless `.js` with ESM syntax is a hard
`SyntaxError` there, so the guard would not help either). A future re-pin to a
different node may want it back. Take it (delete the file) or drop it (keep
1 line); the pinned surface does not move either way.

## 4. Candidates found, below the bar (recorded, not deleted)

**C-1 · `det_order_probe` restates `ord_canon`.** `det_order_probe` (`:347–351`)
runs `orderRun('canon','forward'/'reverse')` and prints `h_forward/h_reverse/eq`
+ the solver signature; `ord_canon` (`orderCase(c,'canon')`) runs the same two
scenes and prints the same two hashes **plus** `ph` and the contact-pair rows,
with the same `rows=99/99 rawSame=false sortedSame=false` solver line. The
`det` cell is a strict subset of the `order` cell.
**Why below bar:** deleting it removes one case from `ARM_CASES` and therefore
changes the `r94_cannon_det` marker in `run_battery.py` — a re-pin, i.e. a
contract change, not a simplification (same ruling as the r93 simplifier's C-2).
The author deliberately put the canon order control in the `det` arm; flagged so
a future re-pin does not re-import the redundancy.

**C-2 · `det_sap`'s axis loop restates `be_broadphase`'s `sap_axis0/1/2`.**
`:357–364` vs `:831`. Same three `SAPBroadphase.axisIndex` runs, same hashes
(`0b0f249979097645`), pinned in two different rows. Below bar for the same
reason (two pinned markers), and the two cells do carry different surrounding
evidence (`det_sap` compares naive-vs-sap; `be_broadphase` compares against
`BASE`).

**C-3 · `nan_payload` ≡ `angdamping_gt1` (byte-identical row).** `:1015` and
`:974` are the same body (`angularDamping = 1.5`, `angularVelocity.set(1,2,3)`,
10 steps) with a different `note`. The pinned `nan` marker confirms it:

```
M nan_all angdamping_gt1  nan=true inf=true where=0.q+0.w h=152fc9d393846ae3 w=NaN,NaN,NaN
M nan_all nan_payload     nan=true inf=true where=0.q+0.w h=152fc9d393846ae3 payload=canonical
```

The "22-row boundary NaN lattice" therefore contains **21 hashed rows** (one
throws) and **16 distinct canonical hashes** — `0d664c54367d5158` appears 4×
(`zero_dt`, `nan_elapsed`, `maxsub0`, `mass0_dynamic`), `cd8e446d27b9f42b` 2×
(`nan_mass`, `damping_gt1`), `152fc9d393846ae3` 2× (`angdamping_gt1`,
`nan_payload`). That is *correct by construction* — `canonHash` is a state
witness, not a case discriminator, and the per-case `note` carries the
discrimination — but it means the lattice's 22 rows are 22 **routes**, not 22
distinct states.
**Why below bar:** the row is pinned, and its documentary value is the boundary
§3 mitigation it encodes ("hash NaN canonically, never by payload"); removing it
is a re-pin. Flagged so a reader does not count 22 distinct witnesses.

**C-4 · duplicated scene literals inside the child.** `restScene`,
`simpleScene`, `sync_interp` (`:562–563`), `par_shared`, `par_multishape`,
`par_sleep_wake` and the `nanCaseTable` literals each re-state ground/ball
construction; `sync_interp` is *exactly* `buildWorld`'s ground+ball (ball at
`y=5`), yet reusing `buildWorld` there is **not** equivalent — it would also add
`boxA/boxB/boxC` at y=4/3/2 into the fall path, which is why the literal stays.
**Why below bar:** extracting a shared builder is a refactor with a real
equivalence obligation per site, not a deletion; the corpus convention is
per-fixture self-containment and the remaining literals are 1–2 lines each.

**C-5 · `stateBits(_w, bodies)` ignores `_w`, and `worldHash(w, bodies)` threads
it through 30 call sites.** The underscore already marks it deliberate, and
"fixing" it is a 30-site edit that saves 0 lines and removes a parameter whose
absence would have to be re-argued per call. Retained.

**C-6 · derived summaries restate lower-level rows.** `mat_all`'s four
`sum_*` rows, `det2`'s `max`, `be_solver`'s `summary`, `var_sleep_phase`'s three
time lines. **Why below bar:** the summary is the readable contract (a
per-mode renumbering must not silently move the semantic pin), ~1 line each
(r93 C-6 precedent).

## 5. Checked and deliberately retained (not dead)

**5.1 The vendored engine trio is load-bearing, including the 60 586-line
`three.core.js`.** `three.module.js` imports from `./three.core.js` on **two**
lines (`:6` the symbol import, `:7` the re-export) — deleting `three.core.js`
would break every `sync*` case at `import`. `cannon-es.js` is the engine under
test. All three are sha256-pinned by the battery's `seed_digests()` (§1.1), so
"simplifying" them would also falsify the author's byte-identity claim.
`r94vendor/package.json` is the fourth file and is **not** in this set — see
SP-5 (§3.5): its documented job does not reproduce on either node installed
here, and deleting it moves nothing on any of the 66 cases under either.

**5.2 The `#` diagnostic in `mod_fixedstep` (`:812`).** One line, deliberately
unpinned content, but its **count** is pinned (`d=1` in the `mod_fixedstep`
cell). It is the only visible evidence for the wall-clock tick count the
boundary measured to be non-rep-stable — keeping an unpinned axis observable is
the point of leaving it observable. Retained.

**5.3 fail-closed guards, all deliberate, most never fired:**
`fail()`/`reject()` themselves, `nan_all`'s `catch (err)` branch (**the one that
does fire** — `neg_radius` throws and is pinned as `threw="The sphere radius
cannot be negative."`), `neg_dt/neg_gravity/neg_steps_early/neg_elapsed`'s
`if (ha === hb) fail(…)` self-checks (never fired — the negatives really move
the hash), `neg_grid`'s `refused`/live-control checks, the child's
`if (!CASE || !CASES[CASE]) fail(…)` and top-level `try/catch` (`:1020–1027`),
and the parent's `unknown_arm`/`mkdir failed`/`child log missing` branches
(`:114`, `:165`, `:175`). The r89/r90/r93 simplifier precedent keeps these.

**5.4 the empty-on-this-surface classification buckets.** `nan_all`'s
`inf_only` list is empty in every run (`inf_only=0 []`) — it is the falsification
surface for "infinite but not NaN", so it stays named rather than folded into
`nan`. Same for the parent's `o`/`d` counters.

**5.5 `DEFAULTS.steps`, `DEFAULTS.order`, `DEFAULTS.broadphase`,
`DEFAULTS.iterations`, `DEFAULTS.tolerance`, `DEFAULTS.allowSleep`,
`DEFAULTS.ballX`, `DEFAULTS.gravity`.** All read (`.steps` by
`runScene`/`runSampled`, the rest inside `buildWorld`); only `dt` is dead
(SP-4). `runScene`'s `steps` parameter is exercised (`runScene({}, 239)` in
`det_steps_saturated`, `runScene({}, 120)` in `neg_steps_early`).
`fricSlide`'s `steps = 2400` default is never overridden (8/8 call sites pass
three arguments) — a never-overridden *optional* parameter, not dead code: it
is read on every iteration and documents the 2400-step contract. Retained.

**5.6 both `runSampled`/`runScene` paths and all 15 `MODES` entries.**
`runSampled` is used by `det_base`/`det_order_swap`/`det_ulp`/`be_broadphase`;
`mat_all` iterates `Object.keys(MODES)` so every mode fires (30 pinned `M`
lines: 15 × 2); `fric_corrected` reads all five `fricSlide` fields.

**5.7 the parent's `d` counter and `_parts` digest.** `d` counts `#` lines and
is printed per cell; `_parts` is joined into the single `PASS …` line the
battery pins. Both are the contract.

## 6. Weight summary, tradeoff, stop condition

Bar-meeting deletions: **22 net lines** (SP-1 12, SP-2 2, SP-3 8, SP-4 0 lines
across 7 same-line edits) out of **1221 added fixture lines**, plus the optional
**1 file** (SP-5), all with zero marker delta *verified by execution* on the
committed bytes (probeA: 20 hunks, −31/+9, 19/19 PASS, stdout/stderr/rc
byte-identical; probeD: the same plus the vendor `package.json` deleted, also
19/19 byte-identical). The remaining ~1199 lines are new measurement surface
whose 66 legs all fired (§2), whose pins are byte-stable across four independent
executions (§1.2), and whose detection sensitivity is demonstrated (§1.3).

The next candidates are re-pin questions (C-1, C-2, C-3), a refactor with
per-site equivalence obligations (C-4), a 30-site parameter removal that saves
nothing (C-5), or the readable contract (C-6). **Stop here.**

## 7. Load observations, receipts, residual risks

Receipts: `corpus/live/r94-simplifier/{battery-r94only,battery-r94only-rep2,battery-full,probes,load-*.txt}`.

| run | when (UTC) | load 1/5/15 | result |
|---|---|---|---|
| `battery-r94only` | 22:11:48 | 73.15/71.21/85.21 (start), 95.99/78.58/86.61 (end) | **19/19 PASS**, `seeds_unchanged=true` |
| `probes/probeA-runs` | 22:13:08 | ~95 | **19/19 PASS**, byte-identical |
| `probes/probeB-runs` | 22:13:47 | ~100 | **8/19** (detection control, §1.3) |
| `battery-r94only-rep2` | 22:14:19 | ~103 | **19/19 PASS**, byte-identical |
| `probes/probeD-runs` | 22:17:02 | ~120 | **19/19 PASS**, byte-identical, vendor `package.json` deleted |
| `battery-full` | 22:13:44 → 22:49 | 103–126 | **280/284**, `seeds_unchanged=true`, **19/19 r94** (§7.1) |

### 7.1 full-battery corroboration

`battery-full` ran all 284 rows on the committed bytes at load 103–126,
concurrently with this seat's own probe runs (548 s of case time, `EXIT=1`):

```
totals: cases=284 pass=280 fail=4 ordinary=231 negative_controls=53
seeds_unchanged: True
```

**All 19 r94 rows PASS**, and their stdout/stderr/rc are **byte-identical to the
`battery-r94only` baseline** (`stdoutDiff=0 stderrDiff=0 rcDiff=0`, recomputed
here) — the r94 surface does not move when the rest of the battery runs around
it. The four FAILs are exactly the documented load-flake families, and the
pattern reproduces the author's own run 1 (`280/284`, same rows):

| FAIL | reason | family |
|---|---|---|
| `navagent3d_follow` | `first=1.636395` vs pinned `1.612825` = `+0.023570 = √2/60` — one tick | r93-baseline F1 |
| `phys3d_events_script_size_gate` | `script_size_gate min_thr drift … sz_fetch: granted` | r93-baseline F2 (granted-under-load) |
| `phys3d_events_deferred_hang` | same `granted` signature | r93-baseline F2 |
| `phys3d_joints_free_ops` | `TIMEOUT after 20 seconds` | r93 simplifier finding 1 |

None of them is on the r94 surface, and none is in the assigned diff. The
receipt to cite for the r94 surface remains `battery-r94only` (clean
`seeds_unchanged=true`, byte-identical rep2) — this full pass is the
under-load corroboration, not a re-adjudication of the other 265 rows.

### 7.2 Findings ranked

1. **[MEDIUM — outside the assigned diff, for the L1]** The `nan` arm's
   "22-row lattice" is 21 hashed rows / **16 distinct canonical hashes**:
   `nan_payload` is byte-identical to `angdamping_gt1`, and three more hash
   values are shared by 2–4 rows (§C-3). Correct by construction (`canonHash` is
   a state witness and the `note` field carries the discrimination), but any
   downstream reader counting "22 witnesses" is over-counting. The row is
   pinned, so it is a re-pin decision, not a deletion.
2. **[MEDIUM — report accuracy + weak fold]** `r94-author.md`'s rationale for
   `r94vendor/package.json` ("silences `MODULE_TYPELESS_PACKAGE_JSON` — would
   otherwise be an unexpected-stderr failure") **does not reproduce**: with the
   file deleted, all 19 battery rows are byte-identical (probeD) and all 66
   child cases are byte-identical on **both** runtimes installed here
   (`fnm v24.21.0`, `mise v26.12.0`), with zero `MODULE_TYPELESS` occurrences
   and zero unclassified output lines (§3.5). Either the file is 1 line of
   unneeded insurance (delete it) or the report's sentence should be corrected —
   both are one-line changes, and the second is the cheaper of the two.
3. **[LOW]** `det_order_probe` (`det` arm) is a strict subset of `ord_canon`
   (`order` arm) — same scenes, same hashes, same solver line (§C-1). Two
   pinned markers; flagged for a future re-pin.
4. **[LOW]** `r94_cannon.gd:33` says "Arms (the `match` dispatch is the sole
   index)" — there is no `match`; the index is the `ARM_CASES` dict plus the
   `NEGATIVE` array (`:113`). Doc-only, no behavior.
5. **[LOW]** No r94-specific mutation anchor: `run_battery.py`'s
   `--probe-failing` mutation is still `body3d_contact` / `BOX_SIZE 4→6`
   (`:706`). This seat's probeB supplies round-equivalent detection evidence for
   the new rows (§1.3) — same posture as every row added since that anchor was
   chosen.
6. **[LOW]** r94 rows' wall time under load ~100 is 0.78–3.77 s
   (max `det` 3.77 s) against the parent's `timeout -s KILL 15` per child and
   the battery's 20 s per case — ≈4–5× margin on the slowest row; the failure
   mode beyond that is a kill, a *new* flake class for these rows. No such event
   in 5 battery runs plus 132 direct child runs (§3.5).
7. **[INFO]** The child's "verbatim port" note (`:40`) is literal: `nextUp`
   was already dead in the scout's own `scene.mjs`/`p_det.mjs` (§3.1). The port
   inherited the deadness, not just the semantics.

### 7.3 Blockers

**None for the assigned implementation.** Two caveats for whoever consumes the
receipts: (a) this seat could not use the `lsp` device (only `rea` is bound), so
every call-site claim is a grep census plus an executed probe, not semantic
proof; (b) the full-battery run (§7.1) is concurrent with sibling lanes and with
this seat's own probes, so its non-r94 FAILs are load-conditional by
construction — the receipt to cite for the r94 surface is
`battery-r94only` (clean `seeds_unchanged=true`) and its byte-identical rep2.

No fixture was edited, nothing was committed, and no descendant was spawned: the
seat's one read-only `labrat` allowance was not used, because every deletion
candidate in §3 was settled by *executing* it against the committed bytes rather
than by a further advisory probe. Stopping here.
