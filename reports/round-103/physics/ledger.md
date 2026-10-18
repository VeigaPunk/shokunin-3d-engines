# SEAT-34 PHYSICS-LEDGER — r104+ fix spec for `phys3d_joints_free_ops`

**Seat:** SEAT-34 PHYSICS-LEDGER · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/physics/ledger.md`). Every other path was
read-only. `corpus/fixtures/**` was never written — every mutation below ran on a throwaway copy
under `/tmp/s34*`, and the scratch trees I exercised were the r102 run's own scratch (a run
artifact, not a seed) plus `/tmp` copies.
**Lane HEAD under test:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work
`c6f655d`). `git status` shows only pre-existing sibling edits plus untracked `reports/round-103/`.
**Subject:** the battery row `phys3d_joints_free_ops` that failed the r102 idle run
(`corpus/live/runs/20261018T181301123479Z/verdicts.json`, 336/350), and the r104+ fix spec for it.
**Axes served:** calibration (the row's class, and the separation from the 13 `r94_cannon_*` rows).
**No Unreal runtime claim is made here** (editor not installed; live-MCP unproven by construction).
This seat made no claim about Unreal at all.

> **Relationship to sibling seats.** `reports/round-103/physics/investigate.md` (SEAT-32) and
> `reports/round-103/physics/adversary.md` (SEAT-33) both classify this row and both propose fixes.
> This seat **re-derived** defect D1 independently (I did not read their files until after my own
> measurements were in hand) and **adds a second defect, D2, that neither reports**: the fixture
> prints `PASS` over cells it has itself marked `mode_ok=0`. Where I differ from them on the *shape*
> of the D1 fix I say so in §4.3.

---

## 1. Headline

The r102 receipt's 14 failures are **two unrelated defect classes**, and `336/350` does not mean
"14 physics defects":

| class | rows | behaviour | cause |
|---|---|---|---|
| **D1 — per-case budget underrun** | 1 (`phys3d_joints_free_ops`) | killed at the cap, no marker | the arm serially spawns 21 Godot children (~21.9 s) against a 20 s per-case cap |
| **D2 — fail-open on degraded cells** | 0 today, latent | prints `PASS` over `mode_ok=0` | `_finish()` never consults `mode_ok`; the fixture is not reentrant |
| **D3 — pin embeds environment** | 13 (`r94_cannon_*`) | exit 0, marker mismatch only | pin contains `node=v24.21.0`; host PATH now resolves `node` to v26.12.0 |

D1 and D2 live in the isolated physics row. D3 lives in the cannon rows. **They must not be
conflated** (§6): fixing the bound does nothing for the cannon rows, and fixing the node pin does
nothing for `free_ops`.

---

## 2. D1 — the budget underrun (reproduced, with a control)

### 2.1 The receipt row

```
$ python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json')); \
  r=[x for x in d['results'] if x['case']=='phys3d_joints_free_ops'][0]; \
  print({k:r[k] for k in ('verdict','actual_exit','expected_exit','error','reasons','elapsed_seconds')})"
{'verdict': 'FAIL', 'actual_exit': None, 'expected_exit': 0,
 'error': 'TIMEOUT after 20 seconds',
 'reasons': ['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)',
             'exact stdout marker missing'],
 'elapsed_seconds': 20.008}
```
stdout is the engine banner alone; stderr is empty. The parent was killed inside its child loop.

**Frequency — 28/28 receipts, every one at the cap:**

```
$ python3 -c "… scan corpus/live/runs/*/verdicts.json for this row …"
free_ops receipts: 28 fails: 28
   ('FAIL', 'TIMEOUT after 20 seconds') 28
min elapsed 20.006  max 20.025          # i.e. all pinned to the cap, never a natural exit
PASS receipts: []                       # not one PASS in the whole corpus
```

This is consistent with `reports/round-103/physics/investigate.md` §3 (26/26 at the time it ran).

### 2.2 The arm is correct — its marker is byte-identical to the pin

```
$ D=…/scratch; /usr/bin/godot --headless --path "$D" --script res://phys3d_joints.gd -- --arm=free_ops
$ # compare against the pinned literal in run_battery.py:530-531, extracted with eval() of the tuple
fixture pinned == verdicts marker: True
sha16 pinned 706ad9151452e18d     len 3921
```
Standalone wall clock, 12 consecutive reps: `22922 22143 22463 23172 23066 24810 24859 24732
24614 24748 25418 24564` ms — **rc=0 every time, marker equal to the pin every time**. So the row is
not slow-and-wrong; it is correct and **late**.

### 2.3 Where the time goes — 21 serial children

`phys3d_joints.gd:37-39` gives `free_ops` seven cases; `:88-93` runs each × 3 backends
(`:30`), each in a **blocking** `OS.execute` (`:131-135`) with `BOUND_S := 20` (`:29`) as the
*inner* per-child bound. Timing the arm's own command line per child:

```
  freeb_ops        gp:1.62s/rc-6  jolt:0.95s/rc0  dummy:1.00s/rc0
  freeb_twice      gp:1.02s/rc0   jolt:0.98s/rc0  dummy:0.97s/rc0
  freeb_make       gp:0.96s/rc0   jolt:0.95s/rc0  dummy:0.86s/rc0
  freeb_world      gp:1.19s/rc0   jolt:1.14s/rc0  dummy:1.00s/rc0
  freeb_afterclear gp:1.07s/rc0   jolt:1.07s/rc0  dummy:1.05s/rc0
  freej_then_b     gp:1.05s/rc0   jolt:1.07s/rc0  dummy:1.05s/rc0
  detachb_free     gp:1.04s/rc0   jolt:0.88s/rc0  dummy:0.98s/rc0
21 real children serial total: 21.94 s
```

The **inner** `BOUND_S=20` never fires (no child approaches 20 s); the **outer**
`CASE_TIMEOUT_SECONDS = 20` (`run_battery.py:36`) is the binding constraint. Raising the inner bound
would change nothing.

### 2.4 The decisive experiment — one constant flips FAIL→PASS

On a **copy** of the seed tree (the repo file is untouched):

```
$ cp -a corpus/fixtures/. /tmp/s34bat/ && rm -rf /tmp/s34bat/__pycache__
$ sed -i 's/^CASE_TIMEOUT_SECONDS = 20$/CASE_TIMEOUT_SECONDS = 60/' /tmp/s34bat/run_battery.py
$ cd /tmp/s34bat && python3 run_battery.py --only phys3d_joints_free_ops --runs /tmp/s34bat-runs
PASS phys3d_joints_free_ops: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: /tmp/s34bat-runs/20261018T184213185940Z/verdicts.json
```
Row fields in that receipt: `verdict PASS`, `actual_exit 0`, `reasons []`, `elapsed 23.325`,
`marker exact match: True`.

**Control, same case, shipped bound, same host, minutes apart:**
```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /tmp/s34ctl-runs
FAIL     phys3d_joints_free_ops   phys3d_joints.gd   --arm=free_ops   None/0   ordinary
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
```

Only the constant differs. This is the acceptance command for D1 (§4.2).

---

## 3. D2 — the fail-open (found by this seat; not in SEAT-32 or SEAT-33)

### 3.1 The code path

`phys3d_joints.gd:158-178` (`_emit`) computes a per-cell mode:

```gdscript
var clean: bool = d["rc"] == 0 and d["sig11"] == 0 and msz == full_msz
var crash: bool = d["sig11"] == 1 and (d["rc"] in [134,137,139]) and msz >= n_pre
var mode_ok := 1 if clean or crash else 0          # :175
_parts.append("%s{mode_ok=%d,m%d=%s}" % [tag, mode_ok, n_pre, pre_sha])
```

and `:104-106` (`_finish`) prints the row verdict **without ever reading `_parts`**:

```gdscript
func _finish() -> void:
	print("PASS phys3d_joints %s %s" % [arm, " ".join(_parts)])
	quit(0)
```

The comment at `:164-165` says "anything outside both is `mode_ok=0` **and closes the row**" — the
value is computed, but nothing acts on it. So a cell that is neither a clean completion nor a named
crash is reported, and the row still claims PASS.

### 3.2 Reproduction — the fixture is not reentrant

The trigger is **two arms sharing one scratch**. The arm writes per-cell child projects into
`res://r90bt_<arm>_<case>_<backend>/` (`:118-127`) inside the *parent's* project, so a second arm
launched against the same project rewrites the first arm's child projects and logs.

```
$ # same scratch, 2 arms concurrently      -> degraded
$ # separate scratch copies, 2 concurrently -> clean
same scratch, 2 concurrent:   sx_1 deg=10  sx_2 deg=0
separate scratches, 2 concurrent: sp_1 deg=0  sp_2 deg=0
```

Both arms printed PASS. Escalating to four arms on one scratch (unpatched fixture): `arm1..arm4`
each printed `PASS=1` — the row **never** reddens, at any concurrency.

Distinct degraded cells in the 2-arm controlled run (`/tmp/sx_1.out`, exactly 10, single PASS line):

```
mode_ok=0 : freeb_ops@jolt  freeb_twice@jolt  freeb_make@gp  freeb_make@jolt
            freeb_afterclear@gp  freeb_afterclear@jolt  freej_then_b@gp  freej_then_b@jolt
            detachb_free@gp  detachb_free@jolt
empty cell: freeb_make@dummy  freeb_world@{gp,jolt,dummy}  freeb_afterclear@dummy
            freej_then_b@dummy  detachb_free@dummy        # rc=0,m=,e=0,w=0
```
The degraded set is **not fixed** across trials (with 2 arms earlier I saw `freeb_ops@jolt`,
`freeb_twice@gp`, `freeb_ops@dummy`; the empty-stream `@dummy` cells appear only in some runs). The
child log for a degraded cell shows the arm's project file was overwritten mid-flight.

`run_battery.py` **cannot** see this: `classify` (`:964-977`) requires an exact stdout line, and
`mode_ok=0` changes that line, so the only symptom is `exact stdout marker missing` — textually
indistinguishable from the D1 timeout class.

### 3.3 A second trap inside the guard

`quit()` is **deferred** in this fixture, so a naive guard falls through:

```
$ # patch: if "mode_ok=0" in p: print("FAIL …"); quit(1)     # NO return
FAIL phys3d_joints free_ops reason=degraded_cell …     (x10, one per iteration)
PASS phys3d_joints free_ops …                          <- still printed, rc=0
```
Any implementation must `return` after `quit(1)`, or the FAIL is printed and then the PASS overrides
the verdict. This is worth carrying into the patch itself.

### 3.4 The guard works — with its control

Patched `_finish()` (throwaway copy `/tmp/s34g`), guard with the explicit `return`:

```
control — one arm alone:                rc=0  PASS=1 FAIL=0  (3 stdout lines, unchanged)
attack  — 4 arms on one scratch:        arm1..arm4 rc=1 each; PASS=0 FAIL=1 each
```
All four attackers now emit `FAIL phys3d_joints free_ops reason=degraded_cell …` and **zero** PASS
lines, where the unpatched fixture in the same setup printed PASS over 10 distinct degraded cells.

---

## 4. The r104+ fix spec

Nothing below is applied. `corpus/fixtures/**` is not this seat's to edit; the lane's r102 routing
sent battery edits to an operator queue rather than a silent mid-round change.

### 4.1 Measured cost model (the numbers the bounds must be derived from)

Children per arm = cases × 3 backends (`:37-42`), each child ≈ 0.9–1.2 s of boot + work on this host:

| row | children | measured elapsed (n=9 receipts each) | verdict |
|---|---|---|---|
| `phys3d_joints_free_ops` | 7×3 = **21** | 20.006–20.025 (all capped) | FAIL ×28 |
| `phys3d_joints_free_pair` | 3×3 = 9 | 10.149–12.078 | PASS |
| `phys3d_joints_twopin` | 2×3 = 6 | 8.837–9.457 | PASS |
| `phys3d_joints_chain3` | 1×3 = 3 | 4.859–5.753 | PASS |
| `phys3d_joints_detach` | 1×3 = 3 | 3.394–4.133 | PASS |
| `phys3d_joints_sweep` / `_rid` / `_api` | 1×3 = 3 | 3.026–3.685 | PASS |

Uncapped arm wall clock: **26 clean samples, min 21.166 s, max 25.418 s** (single-arm runs; the 12
standalone reps + 4 separate-scratch concurrent arms + the earlier singles). r93's history records
one PASS at **17.802 s** — so the true cost straddles 20 s and the row's verdict is a coin-flip on
host load, not a hard failure. I observed **zero** degraded cells in any of those 26 single-arm runs,
which is what makes the D2 trigger specifically concurrency.

### 4.2 Acceptance commands (falsifiable, not judgement calls)

**A-D1 — the bound.** On a copy of the tree with `run_battery.py:36` set to the proposed value:

```
python3 <copy>/run_battery.py --only phys3d_joints_free_ops --runs /tmp/acc
```
must print `PASS phys3d_joints_free_ops: exit=0 expected=0`, `pass=1 fail=0`, and the receipt row
must carry `reasons: []`, `actual_exit: 0`, and a stdout PASS line byte-equal to the pin
(`sha256[:16] == 706ad9151452e18d`). **Observed today with 60 s: PASS, `reasons []`, elapsed 23.325,
marker exact match True.** Control at 20 s on the same host: FAIL `None/0`.

**A-D2 — the fail-open.** With the `_finish()` guard applied (and `return` after `quit(1)`):

```
# control — must not regress
cd <copy> && godot --headless --path . --script res://phys3d_joints.gd -- --arm=free_ops
   -> rc=0, exactly one `PASS phys3d_joints free_ops` line, no `FAIL`
# attack — must now be caught
cd <copy> && for i in 1 2 3 4; do godot … --arm=free_ops & done; wait
   -> every arm rc=1, `FAIL … reason=degraded_cell`, zero `PASS` lines
```
**Observed exactly that** (§3.4). The negative direction is also required: a fixture run *alone* must
never emit `degraded_cell`, which the control establishes.

**A-D3 — the node pin (cannon rows; separate owner).** Same runner, `PATH` with node v24.21.0 first:

```
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
  python3 corpus/fixtures/run_battery.py --only r94_cannon_det --runs /tmp/acc-node
```
**Observed: `PASS r94_cannon_det … 0/0`, `pass=1 fail=0`** — with the identical fixture bytes that
FAIL under the default PATH. That is the whole of D3 in one command.

### 4.3 R-items

**R1 (D1, recommended shape) — a per-case bound, not a new global.** Add an override map consulted by
`execute()` (`run_battery.py:1267-1277`), keyed by the arm-spawning rows, using the §4.1 cost model:

```
CASE_BOUNDS = {"phys3d_joints_free_ops": 90,   # 21 children; worst observed 25.4 s; ~3.5x
               "phys3d_joints_free_pair": 45,  #  9 children; worst observed 12.1 s
               "phys3d_joints_twopin":    45}  #  6 children; worst observed  9.5 s
```
**Bound choice.** 90 s for `free_ops` is ~3.5× the worst wall clock ever observed (25.418 s) and ~5×
the r93 pass (17.802 s). It cannot mask a hang: each child is still capped by the fixture's own
`BOUND_S=20` (`:29`), and `_run_child` (`:91-92`) turns a child `err` into `FAIL … quit(1)`, so a
hung child costs at most 20 s and then fails the row. A ceiling of 90 s therefore leaves the parent
room for 21 children × ≤20 s only in the pathological case, and in that case the row is already
FAIL by its own internal bound.

*Divergence from SEAT-32:* `investigate.md` R1 proposes raising the **global**
`CASE_TIMEOUT_SECONDS` 20→60. That works (I verified the 60 s flip) but it changes the failure
semantics of all 350 rows — every row's hang-detection latency moves at once. The per-case map keeps
every other row byte-for-byte identical, which is the property the r102 ledger discipline asks for.
If the operator prefers the one-token global change, it should be recorded as a dated correction
against the constant, with the per-row cost model above as the justification.

**R2 (D2) — make `_finish()` honour `mode_ok`.** Fail the row when any cell reports `mode_ok=0`:
print `FAIL phys3d_joints <arm> reason=degraded_cell …` and `quit(1)`, **with an explicit `return`**
(§3.3). Direction of change: this can only turn PASS→FAIL, never FAIL→PASS, so it cannot create a
false green. It *can* newly redden a row under host contention — which is the correct behaviour, and
the reason this needs its own dated entry rather than a silent fold.

**R3 (D1, durable) — stop serialising the children.** `OS.execute(…, blocking=true)` (`:131-135`) pays
21 sequential boots. Concurrent children would collapse the wall cost to roughly one boot plus the
longest child. **Precondition: each arm must own its scratch.** D2 proves the arm is not reentrant, so
R3 is only safe with per-arm scratch isolation (the child dirs are already namespaced by
`arm_case_backend` at `:118`, but the *parent project* is shared — that is the collision). This is a
real rewrite of `_run`/`_run_child` and belongs to a seat that owns `phys3d_joints.gd`.

**R4 (do not do) — re-pin or drop the row.** The pin is byte-stable and the marker carries real
physics content (7 freed-endpoint families × 3 backends). Weakening it would trade coverage for a
budget bug.

---

## 5. Risks of changing a pinned row

1. **The pin is a literal in the runner, not a hash.** `run_battery.py:530-531` holds the 3921-char
   marker as a string; I verified it equals the receipt's recorded marker by `eval`-ing the tuple
   (`fixture pinned == verdicts marker: True`). Any change to the fixture's *output shape* — e.g.
   appending a `degraded` token to the PASS line — invalidates the literal and every historical
   receipt at once. If the D2 fix changes output text, it must be a **re-pin with a dated correction
   note**, never a silent rewrite; the pre-change literal must stay quoted in the report.
2. **A previously-green row can go red.** The D2 guard makes the row strictly stricter. It has never
   once exited 1 in the corpus (0 PASS, 28 FAIL, all timeouts), so there is no green baseline to
   protect — but the *class* of change is "row may now fail under host contention", and that must be
   announced, not discovered.
3. **Raising a bound weakens hang detection.** Quantified in R1: the inner `BOUND_S=20` still bounds
   every child, and a child error fails the row at `:91-92`. The outer bound must stay well under
   `21 × 20 = 420 s`; 90 s is comfortably below.
4. **Scratch reuse is itself a live hazard — and this seat contributed to it.** The r102 receipt's
   scratch has been reused by later lanes (its `free_ops` child logs carried mtimes 15:34:21–15:34:32
   local when SEAT-32 read them, while `verdicts.json` was written at 15:26:08 local), **and by this
   seat**: my 12 standalone reps ran in that same tree from 15:38–15:43 local, so its child-log
   mtimes are now ~15:42:35. I did **not** modify any seed (`seed digest mismatches vs r102 receipt:
   0`), and the scratch is a run artifact, not a pinned path — but the disclosure matters because a
   reused scratch is a reentrancy attack against this arm by construction (§3.2), and any future
   re-run of this row must use a **fresh** scratch. A lane that reuses one should say so, or a D2
   degraded run can be mistaken for a D1 timeout and vice versa.

---

## 6. The node-marker drift interaction — keep the physics row isolated

The brief asks that the isolated physics row not be conflated with the 13 cannon rows. They are
separable by one command and they are separable in kind:

**In kind.** `free_ops` fails because it is killed at the cap and never prints its marker; its marker
is byte-identical whenever it *is* allowed to run. The 13 `r94_cannon_*` rows fail with `exit 0` and
the single reason `['exact stdout marker missing']` — they *ran to completion* and printed a marker
that differs from the pin in exactly one token:

```
$ python3 … diff pin vs observed for each of the 13 …
r94_cannon_det        node_token_only_diff=True
… (all 13) …
r94_cannon_backends   node_token_only_diff=True
$ # the opcode is a single replace, and it is the node version token
replace '4.21' -> '6.12'        # i.e. node=v24.21.0 -> node=v26.12.0
```
Normalising that one token makes pin and observation **equal for 13/13** rows.

**By control.** Same fixture bytes, same runner, only `PATH` differs:

```
$ which node; node --version
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
v26.12.0                                   # default -> 13 FAILs
$ PATH="…/fnm/node-versions/v24.21.0/installation/bin:$PATH" … --only r94_cannon_det
PASS     r94_cannon_det   r94_cannon.gd   --arm=det   0/0   ordinary      # -> PASS
```

**Why the other 6 rows of that script stay green.** All 6 `r94_cannon_neg_*` negative controls PASS
because their markers carry no node token (`'node=' in marker` is `False` for all 6 — verified). So
the failure is specific to the *ordinary* rows of that one script, which are exactly the rows whose
pin embeds the version.

**Is it actually load, or really the version?** Ruled on the version, by control: `r94_cannon_det`
FAILed in a `--only` run under the default PATH (v26.12.0, `reasons ['exact stdout marker missing']`)
and PASSed under a v24.21.0-first PATH, same fixture bytes, same host, same minute. Load cannot
explain a marker-text match: the row exits 0 either way and the only textual difference is the token.

**It is a class, not a one-off.** Of 350 pins, **13 embed `node=v`**, **60 embed `py=`**, and
**25 embed `blender-`**. Any environment-derived token in a pin is the same latent defect; the cannon
rows are simply the ones whose environment moved.

**Consequences for the ledger.**

- The r102 receipt's 14 failures = **1 D1 + 13 D3**. `336/350` is not a physics regression, and the
  `FAIL` battery verdict does not date the physics rows.
- The D1/D2 fix (bound + guard) **does nothing** for the 13 cannon rows; the D3 fix (de-normalise the
  version token out of the pin, or pin it via the child's reported version instead of the host's
  PATH) **does nothing** for `free_ops`.
- **Do not** repair both in one change. A single commit that edits `run_battery.py:36` *and* the 13
  cannon literals would make it impossible to attribute a future red, and the D3 fix needs a dated
  correction note because it rewrites a historical pin.

---

## 7. What this seat established, and what it did not

**Established, each with a command run on this host:**
- D1 reproduces 28/28 receipts at the cap; the arm's PASS line is byte-equal to the pin
  (sha16 `706ad9151452e18d`, 3921 chars) in every standalone rep at 21.17–25.42 s (26 clean samples).
- 21 serial children cost 21.94 s measured; the binding bound is `run_battery.py:36`, not
  `phys3d_joints.gd:29`.
- FAIL→PASS flips on that one constant alone, with `reasons []` and an exact marker match; control at
  the shipped bound fails.
- D2 reproduces on demand (same scratch + ≥2 concurrent arms → 10 distinct degraded cells, still
  `PASS`); separate scratches → 0 degraded; 26/26 single-arm runs → 0 degraded.
- The D2 guard works with its control (alone PASS rc=0; 4 attackers rc=1, zero PASS lines), and the
  `quit()`-is-deferred trap is documented.
- D3's diff is exactly the node token for 13/13 rows, and flips to PASS under a v24.21.0 PATH.

**Not established / left open:**
- I did not apply anything; the spec in §4 is unapplied by construction.
- I did not chase *why* a shared scratch yields `mode_ok=0` rather than a named crash — the mechanism
  is consistent with the child reading a mid-write `project.godot` / truncated log, but I only proved
  the trigger, not the exact race.
- I did not test R3 (concurrent children); its safety precondition (per-arm scratch) is inferred from
  D2, not measured.
- Whether the 60 embed-`py=` and 25 embed-`blender-` pins are *currently* drifting is untested here —
  those rows pass today, so the pins match today; the risk is the token, not an observed failure.
- **Side effect to disclose:** 12 of my standalone reps ran inside the r102 run's own scratch
  (`corpus/live/runs/20261018T181301123479Z/scratch`), rewriting its `r90bt_free_ops_*` child logs.
  No seed changed (`seed digest mismatches vs r102 receipt: 0` across all 87 seed digests) and no
  pinned path was touched, but the scratch is no longer a byte-faithful witness to the r102 run.
- `corpus/fixtures/**`, `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`,
  `reports/round-101/**`, `reports/round-102/**`, and the pinned Unreal subtree were not written by
  this seat.
