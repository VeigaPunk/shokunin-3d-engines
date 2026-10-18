# r104 SEAT-11 FIX-LEDGER — fold/queue spec for the full regression

**Seat:** SEAT-11 FIX-LEDGER · round 104 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-104/physics/ledger.md`). Every other path was read
only; no fixture, gate, `SKILL.md`, `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, or
`reports/round-10{1,2,3}/**` byte was written. My own scratch runs wrote only under
`/home/vgpnk/scratch-r104/s11/**`.
**Lane HEAD under test:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103 report-last;
work `8c9d9ad`). `git status --porcelain` at my close shows only the round's own edits
(`corpus/fixtures/phys3d_joints.gd`, `corpus/knowledge/unreal-mcp/gate/{README.md,run_gate.sh}`,
`SKILL.md`, `reports/round-104/**`).
**Axes served:** calibration (the *class* of every failure the round surfaces, so a future red is
attributed before it is repaired) and depth (the acceptance command that proves each repair).
**No Unreal runtime claim is made here.** Unreal Editor is not installed on this host; nothing in
this file is evidence about editor or live-MCP behaviour.

---

## 1. Headline

The r102 receipt's 14 failures are **two unrelated classes**, and this seat found **four more row
behaviours** the r103 ledger did not name. The full ledger of everything the r104 regression can
surface, with the repair state and the acceptance command for each:

| class | rows | behaviour | cause | r104 state |
|---|---|---|---|---|
| **D1** per-case budget underrun | 1 | killed at the 20 s cap, no marker | 21 serial Godot boots (7 cases × 3 backends) vs `CASE_TIMEOUT_SECONDS = 20` | **LANDED** (`phys3d_joints.gd` R3 concurrent spawn+collect); full regression 336→**337/350** |
| **D3** pin embeds environment | 13 | exit 0, marker mismatch only | pin carries `node=v24.21.0`; host PATH resolves `node` to `v26.12.0` | **OPEN — routed** (operator decision, not a fixture edit) |
| **D4** load-sensitive witness cell | 1 | exit 0, single token flips | `bpy_rbw3d_render` `stable=False` (pin) vs `stable=True`; green 12/12 isolated | **OPEN — new, this seat** |
| **D5** concurrent seed race | 2 | exit 0, *extra reasons* beyond marker drift | `r98_gltflat_doc` / `_extbin` — `Can't open file at path "UD/R98Scout/…"`; green 10/10 isolated | **OPEN — new, this seat** |
| **D6** host scratch pressure | 0 rows | rows vanish or go red with no tree change | `/tmp` per-user quota (`EDQUOT`) — reproduced live below | **PARTLY CLOSED** (gate side landed; battery side open) |
| **D7** intermittent arm assertion | 1 | **exit 1**, the fixture's *own* `_fail` fires | `navagent3d_detour_mut_ctx_resume` step1 `final=…,4.0` vs expected `…,5.5`; green 20/20 isolated | **OPEN — new, this seat** |

**D1 and D3 must not be conflated**, and neither may be conflated with D4/D5/D6/D7. A single change
that edits the physics fixture *and* the 13 cannon literals would make a future red
unattributable.

### 1.1 The measured after-count (the counting command, run by SEAT-07)

The round's full-regression receipt on the patched tree:

```
$ python3 corpus/fixtures/run_battery.py --runs reports/round-104/physics/author-runs-full
…
totals: cases=350 pass=337 fail=13 ordinary=291 negative_controls=59 probes=0
FAIL battery: …/author-runs-full/20261018T192105574998Z/verdicts.json
```

| | before (r102 receipt `…181301123479Z`) | after (r104 `…192105574998Z`) |
|---|---|---|
| totals | 336 / 350 | **337 / 350** |
| `phys3d_joints_free_ops` | FAIL, `TIMEOUT after 20 seconds`, elapsed 20.008 | **PASS**, `reasons []`, elapsed **2.768** |
| failing classes | 1 D1 + 13 D3 | **13 D3 only** |
| `bpy_rbw3d_render` / `r98_gltflat_*` | PASS | PASS (D4/D5 did not fire this run) |
| `run_battery.py` seed digest | `f456bd00…` | `f456bd00…` (identical) |
| `phys3d_joints.gd` seed digest | `88be87fa…` | `80bf44c5…` (the C1 fix) |
| `seeds_unchanged` | true | true |

The 13 remaining failures are **exactly** the D3 cannon rows, each `exit 0` with the single reason
`['exact stdout marker missing']` — the class §3 describes, unchanged by the D1 repair.

**Read 337 as the D1 fold, not as the ceiling.** §3.3 records a corpus receipt at **349/350** where
the only failure was D1 (the 13 cannon rows passing under a v24-first PATH). So the same patched
tree should score **350/350** under that PATH, and 337 under the default PATH is precisely
"D1 fixed, D3 untouched" — which is the claim this round makes.

---

## 2. D1 — the budget underrun (repair landed this round, verified)

### 2.1 Before

r102 lane receipt `corpus/live/runs/20261018T181301123479Z/verdicts.json`:

```
$ python3 -c "import json;d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'));\
r=[x for x in d['results'] if x['case']=='phys3d_joints_free_ops'][0];\
print({k:r[k] for k in ('verdict','actual_exit','expected_exit','error','reasons','elapsed_seconds')})"
{'verdict': 'FAIL', 'actual_exit': None, 'expected_exit': 0,
 'error': 'TIMEOUT after 20 seconds',
 'reasons': ['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)',
             'exact stdout marker missing'],
 'elapsed_seconds': 20.008}
```

Frequency across the corpus — **13 of 14** 350-row receipts, and the 13 are exactly the
pre-patch ones; every one is pinned to the cap, never a natural exit:

```
$ # scan corpus/live/runs/*/verdicts.json for 350-row receipts
phys3d_joints_free_ops         fails=13/14
$ # the single PASS is the 16:32 receipt on the patched tree (…192045623599Z)
$ # pre-patch receipts: 13 of 13 FAIL;  not one PASS on the unpatched tree
```

**Independent before-receipts this round** (SEAT-02, fresh `--runs` roots, no scratch reuse):
`reports/round-104/physics/before-battery.stdout` and `before-battery-clean.stdout` — both
`FAIL … exit=None … ['TIMEOUT after 20 seconds', …]`, elapsed 20.024.

### 2.2 The landed repair

`corpus/fixtures/phys3d_joints.gd` moved `88be87fa…` → **`80bf44c5…`** (34 insertions / 7 deletions;
the sha advanced twice while the round was in flight — `c7e77638…` was the first landed form, then a
hang guard was added; **`80bf44c5…` is the form this seat re-verified last**, see the re-check at the
end of this section). The serial `_run_child` loop is split into `_spawn_child`
(`OS.create_process`) + `_collect_child` (`OS.is_process_running` poll, then
`OS.get_process_exit_code`); all 21 children are spawned first and collected in the original
nested-loop order, so the emitted stream stays a pure function of the per-child logs. The second
edit adds `const BATCH_BOUND_S := 16` and a deadline in the collect loop — if a child is still
running when the deadline passes it is `OS.kill`ed and the row fails with
`batch_timeout` rather than hanging to the runner's 20 s cap. That is a **hang guard for the
batched form**, not a change to the emitted stream. `run_battery.py` is **untouched**
(`f456bd00…`, identical to the r102 `seed_digests` entry), so the 350 CASES rows and the pinned
markers are byte-identical.

### 2.3 After — the acceptance command, run by this seat

```
$ timeout 120 python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops \
      --runs /home/vgpnk/scratch-r104/s11/after
PASS phys3d_joints_free_ops: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: /home/vgpnk/scratch-r104/s11/after/20261018T192036192858Z/verdicts.json
```

Receipt row and marker byte-identity:

```
{'verdict': 'PASS', 'actual_exit': 0, 'expected_exit': 0, 'error': None,
 'reasons': [], 'elapsed_seconds': 1.95}
marker == pin bytes: True   sha16 706ad9151452e18d   len 3921
```

`706ad9151452e18d` is the digest SEAT-03's bank records for this row
(`reports/round-104/physics/markers.md` §1 row 5) and the one the pre-patch standalone control
emitted — the pin did not move.

**Corroborated inside the round's full regression** (SEAT-07 receipt, §1.1) — same verdict, same
empty reasons, same marker, 2.768 s, with all 349 sibling rows running alongside it:

```
$ python3 -c "… load author-runs-full/20261018T192105574998Z/verdicts.json, pick this row …"
free_ops: PASS 0 [] 2.768
marker byte-equal to pin: True   sha16 706ad9151452e18d
```

So the repair holds both in isolation and under a full-battery run, which is the form the claim
needs.

**Re-check on the final bytes (`80bf44c5…`, after the `BATCH_BOUND_S` guard landed):** the row still
passes with the same marker, so the hang guard did not disturb the emitted stream.

```
$ sha256sum corpus/fixtures/phys3d_joints.gd
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  corpus/fixtures/phys3d_joints.gd
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /home/vgpnk/scratch-r104/s11/recheck
PASS phys3d_joints_free_ops: exit=0 expected=0     # elapsed 2.714
{'verdict': 'PASS', 'actual_exit': 0, 'reasons': [], 'elapsed_seconds': 2.714}
marker==pin True   sha16 706ad9151452e18d   len 3921
```

**A caveat the close must carry:** `phys3d_joints.gd` changed **twice** during r104
(`88be87fa…` → `c7e77638…` → `80bf44c5…`). The 337/350 full-regression receipt (§1.1) ran on
`c7e77638…`, and my `--only` re-check above ran on `80bf44c5…`. Both forms pass this row with the
identical marker, but **the round's after-count has not been re-measured on `80bf44c5…`** — the
close should either re-run the counting command on the final bytes or state the sha it counted on.

**Wall clock, same host, back to back:**

| build | n | wall clock | pass lines |
|---|---|---|---|
| pre-patch (`git show HEAD:corpus/fixtures/phys3d_joints.gd` into a copy) | 3 | 22.173 / 24.712 / 24.534 s | 1/1 each |
| landed patch (`c7e77638…`) | 5 | 2.722 / 2.922 / 3.188 / 3.024 / 2.799 s | 1/1 each |
| landed patch (`80bf44c5…`, `--only` through the runner) | 1 | 2.714 s (row elapsed) | 1/1 |

~8× faster; the 20 s cap now has a ~17 s margin instead of a ~1 s deficit. The new
`BATCH_BOUND_S = 16` guard sits well below the runner's 20 s cap and above every observed child
(≤1.2 s) plus batch total (≈3 s), so it cannot fire on a healthy host.

**Precondition for R3 (per-arm scratch) is satisfied here, not by luck:** each of the 5 patched
reps ran against its own scratch copy, and 4 concurrent patched arms on 4 separate scratches all
returned `rc=0`, 4023 bytes, one PASS line each:

```
conc1 rc=0 out_bytes=4023 pass=1   conc2 rc=0 out_bytes=4023 pass=1
conc3 rc=0 out_bytes=4023 pass=1   conc4 rc=0 out_bytes=4023 pass=1
```

### 2.4 The acceptance command for the close (SEAT-32 should carry this verbatim)

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs <lane-local dir>
# must print: PASS phys3d_joints_free_ops: exit=0 expected=0 ; pass=1 fail=0
```

and the receipt row must carry `reasons: []`, `actual_exit: 0`, and a stdout PASS line whose
sha256[:16] is `706ad9151452e18d`.

**Pass `<lane-local dir>`, never a `/tmp` path** — see §2.5 and §6. If the run root is on the
quota-bound tmpfs the receipt can come back `rc=0` with an empty stdout, which reads like a red.

### 2.5 Residual risk on D1 (not a blocker, but state it)

The patched arm returned **rc=0 with 0 bytes of stdout** in 2 of 3 early reps of mine. That was
**not** a fixture defect — it was D6 (§6): the shell's own redirect into `/tmp` failed with
`echo: write error: Disk quota exceeded`, so Godot's output never landed. Re-run with output on
real disk, 10/10 reps were non-empty. **A D6 empty stdout and a D1 timeout are textually
distinguishable** (D1 has `TIMEOUT after 20 seconds` + `elapsed 20.0xx`; D6 has `rc=0` and an empty
stdout), but only if the reader checks `elapsed_seconds`. Say so in the close report.

---

## 3. D3 — the 13 cannon node markers (still routed; do NOT repair with D1)

### 3.1 The class, re-derived this round

Every one of the 13 `r94_cannon_*` **ordinary** rows embeds `node=v24.21.0` in its pinned marker;
the fixture builds the token from the host's `node` (`corpus/fixtures/r94_cannon.gd:127-132`,
`_node_version_probe()` → `node --version`). The host default is v26.12.0.

```
$ python3 -c "… extract CASES with ast.literal_eval; count env tokens in pins …"
CASES rows: 350
env-derived tokens in pins: {'blender-': 10, 'node=v': 13, 'py=': 14}
```

The 13 are exactly the ordinary rows; the 6 `r94_cannon_neg_*` negative controls carry no node token
and pass. The diff is **one token** for all 13:

```
$ python3 -c "… for each failing cannon row, compare pin vs observed stdout …"
r94_cannon_det        pin=['node=v24.21.0'] obs=['node=v26.12.0'] normalize_eq=True exit=0
r94_cannon_det2       pin=['node=v24.21.0'] obs=['node=v26.12.0'] normalize_eq=True exit=0
… (13/13, all normalize_eq=True) …
```

### 3.2 The control — it is PATH, not load

```
$ which node; node --version
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
v26.12.0

$ python3 corpus/fixtures/run_battery.py --only r94_cannon_det --runs /home/vgpnk/scratch-r104/s11/c
FAIL     r94_cannon_det   r94_cannon.gd   --arm=det   0/0   ordinary

$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
    python3 corpus/fixtures/run_battery.py --only r94_cannon_det --runs /home/vgpnk/scratch-r104/s11/c24
PASS     r94_cannon_det   r94_cannon.gd   --arm=det   0/0   ordinary
```

Same fixture bytes, same host, same minute; only `PATH` differs.

### 3.3 The class is 100 % PATH-dependent, and the pre-fix ceiling is 349/350

One corpus receipt already ran with the v24 pin first on PATH:

```
$ # per-receipt census, corpus/live/runs/*/verdicts.json
14:56 336/350  D1=1 marker_missing=13     16:01 349/350  D1=1 marker_missing=0
… (13 receipts at 334–336: one 334, five 335, seven 336) …
```

**Time bases, so the numbers reconcile:** the receipt *ids* are UTC start stamps
(`20261018T184812159114Z` = 18:48:12 UTC) while the clock labels in this census are **local file
mtimes** (UTC−3 on this host), i.e. completion times. The 349/350 receipt started 18:48:12 UTC
(15:48 local) and its `verdicts.json` was written 16:01 local — a ~13 min full-battery run, which
matches the ~13 min total the r102 receipt records for 350 rows.

`corpus/live/runs/20261018T184812159114Z/verdicts.json` (16:01 local) carries **all 19 cannon rows
PASS** with the observed token `node=v24.21.0` — so D1 is the only failure left once the node pin is
satisfied. That is the number the r104 after-count should be compared against, **not** 336.

**The round's own full regression confirms the mechanism from the other side.** Its receipt
(`reports/round-104/physics/author-runs-full/20261018T192105574998Z`, default PATH) shows the
cannon row still failing on exactly that token while D1 is green:

```
$ python3 -c "… cannon_det from the r104 full receipt …"
r104 full receipt cannon_det observed node token: ['node=v26.12.0']
pin token:                                       ['node=v24.21.0']
verdict FAIL ['exact stdout marker missing']
```

So the r104 after-count of 337/350 is **D1-fixed, D3-untouched** — one failure class removed and
none added, which is exactly the claim the round makes.

### 3.4 Queue item — and why it is not a fixture edit

**D3-Q1 (operator).** Make the cannon pin environment-independent. Three shapes, in increasing
scope:

- **D3-Q1a (recommended, cheapest, reversible):** side-by-side `node` v24.21.0 on PATH for battery
  runs — already proven by the 16:01 receipt. Cost: one operator PATH pin. It is the only option
  that changes **no** pinned byte, so no historical receipt is invalidated.
- **D3-Q1b:** drop the version token from the `r94_cannon.gd` PASS line and re-pin the 13 literals.
  Requires a dated correction note; it rewrites a historical pin and invalidates the r102 receipt's
  comparison for those rows.
- **D3-Q1c:** have the child report its own `process.version` through a value the pin normalizes
  (e.g. pin a class token `node=present`). Broader fixture change; touches `r94_cannon.gd`, which
  no seat owned this round.

**Do not** fold any of these into the D1 commit.

**Acceptance command (any shape):**

```
python3 corpus/fixtures/run_battery.py --only r94_cannon_det,r94_cannon_det2,r94_cannon_varstep,\
r94_cannon_bailout,r94_cannon_nan,r94_cannon_sync,r94_cannon_material,r94_cannon_friction,\
r94_cannon_parity,r94_cannon_parity2,r94_cannon_modes,r94_cannon_order,r94_cannon_backends \
  --runs <lane-local dir>
# must print: totals: cases=13 pass=13 fail=0
```

### 3.5 Latent siblings of the same defect (all green today — do not touch)

```
13 rows embed node=v24.21.0   (r94_cannon.gd)
14 rows embed py=3.14.7       (r95_bullet.gd)      host python3 = 3.14.7  -> matches today
10 rows embed blender-5.2.1   (bpy_rbw3d.gd)      host blender = 5.2.1 LTS -> matches today
```

`which python3` → `/usr/bin/python3`, `python3 --version` → `3.14.7`; `blender --version` →
`Blender 5.2.1 LTS`. Any environment-derived token in a pin is the same latent class; the cannon
rows are simply the ones whose environment moved. **A future red on a `r95_bullet_*` or
`bpy_rbw3d_*` row should be read as D3 first, not as a physics regression.**

---

## 4. D4 — `bpy_rbw3d_render`: a load-sensitive witness cell (NEW, this seat)

Fails **3 of 14** 350-row receipts; passes the other 11. `exit 0`, `reasons` is exactly
`['exact stdout marker missing']` — the D3 shape, but the token that differs is **not**
environmental:

```
$ # pin vs observed, first differing cell, receipt 20261018T174635717082Z
pin: …|M rdet same_state stable=False|M rdet moved_state differs=True|M DONE case=rdet,e=0,w=0,b=0}
obs: …|M rdet same_state stable=True |M rdet moved_state differs=True|M DONE case=rdet,e=0,w=0,b=0}
replace ['stable=False'] -> ['stable=True']     # 790 bytes both sides, one token
```

`corpus/fixtures/bpy_rbw3d.gd:47` documents the intent: *"a stable witness (`stable=False` pinned,
never a sha)"*. The pin asserts the witness is **not** stable; on 3 of 14 runs it **was**.

**Falsification run by this seat — 12 consecutive isolated reps, all PASS with the pinned token:**

```
$ for i in $(seq 1 12); do python3 corpus/fixtures/run_battery.py --only bpy_rbw3d_render \
      --runs /home/vgpnk/scratch-r104/s11/d4-$i >/dev/null 2>&1; done
$ grep -h -o 'stable=[A-Za-z]*' /home/vgpnk/scratch-r104/s11/d4-*/*/verdicts.json | sort | uniq -c
     24 stable=False                     # 12 receipts x 2 cells, no stable=True anywhere
$ # every receipt: verdict PASS, reasons []
```

So the witness is **not** intrinsically random: isolated, it reproduces the pinned
`stable=False` 12/12. Every observed `stable=True` landed in a *full 350-row* receipt — i.e. the
trigger is host load / concurrency, the same family as D5 and D6, not a physics difference. The row
is a **load-sensitive witness**, and the pin is a correct pin of the idle-host outcome.

**Queue item D4-Q1 (needs a seat that owns `bpy_rbw3d.gd` — nobody did this round).** Either accept
the row as load-sensitive and say so in the battery README (cheap, no byte change), or make the
witness load-independent. Acceptance either way:

```
# 12 isolated reps must all PASS with stable=False  (already observed: 12/12)
# AND the same must hold with a deliberate concurrent load, e.g.
for i in 1 2 3 4; do python3 corpus/fixtures/run_battery.py --only bpy_rbw3d_render \
    --runs /home/vgpnk/scratch-r104/s11/d4load-$i >/dev/null 2>&1 & done; wait
grep -h -o 'stable=[A-Za-z]*' /home/vgpnk/scratch-r104/s11/d4load-*/*/verdicts.json | sort | uniq -c
```

If the concurrent run reproduces `stable=True`, the row's claim must be narrowed and the pin
re-issued with a dated correction note. **Do not** silently re-pin to `stable=True` — that would
erase the only evidence the witness was ever unstable.

---

## 5. D5 — `r98_gltflat_doc` / `r98_gltflat_extbin`: a seed race (NEW, this seat)

Fails **3 of 14** receipts (doc alone in two, extbin alone in one, both together in one — so
`r98_gltflat_doc` fails 2/14 and `r98_gltflat_extbin` fails 2/14). Unlike D3/D4 the `reasons` list
is **longer than marker-drift**: the runner also records `unexpected diagnostic` entries, and the
observed marker is **shorter** than the pin:

```
20261018T175032933066Z r98_gltflat_doc FAIL len obs 3255 len pin 3467
   reasons: ['exact stdout marker missing',
             'unexpected diagnostic: # r98_gltflat doc doc_abs@gp ue=ERROR: Can\'t open file at path "UD/R98Scout/tri.glb"',
             'unexpected diagnostic: # r98_gltflat doc doc_abs@dummy ue=ERROR: …',
             'unexpected diagnostic: # r98_gltflat doc doc_user@jolt ue=ERROR: Can\'t open file at path "user://tri.glb"',
             …]
```

The failing cell is the **absolute/user-data** one (`doc_abs`, `doc_user`, `ext_bin_abs`); the
`@gp` / `@jolt` / `@dummy` spread within a single receipt is **incomplete** in some receipts and
complete in others, which is the signature of a race, not of a fixed broken cell. The fixture's own
header (`corpus/fixtures/r98_gltflat.gd:172`, `:406-437`) shows it *seeds* `app_userdata/<APP>` and
then cleans up, and `ud_pre_existed` is captured at start — so two concurrent runs of this fixture
(or a leftover `~/.local/share/godot/app_userdata/R98Scout` from a sibling lane) can see the seed
directory in the wrong state.

Observed on this host right now:

```
$ ls -la ~/.local/share/godot/app_userdata/R98Scout
drwxr-xr-x … logs          # the dir exists; its contents are the fixture's seed state
```

**Falsification run by this seat — 10 consecutive isolated reps, all PASS with `reasons: []`:**

```
$ for i in $(seq 1 10); do python3 corpus/fixtures/run_battery.py \
      --only r98_gltflat_doc,r98_gltflat_extbin --runs /home/vgpnk/scratch-r104/s11/d5-$i >/dev/null 2>&1; done
$ python3 -c "… tally (case, verdict, n_unexpected_diagnostic) over the 10 receipts …"
('r98_gltflat_doc',    'PASS', 0) 10
('r98_gltflat_extbin', 'PASS', 0) 10
```

So the row is **deterministic in isolation** and the failure needs a concurrent writer — the
`app_userdata/R98Scout` dir is shared host state, so two batteries in flight (or a sibling lane's
leftover) collide on it. That is the same load/concurrency family as D4 and D6.

**Queue item D5-Q1.** Make the doc/extbin arms independent of a shared `user://` app dir, or make
the row declare the pre-existing-dir case as an expected cell. Falsification for the *repair* (the
isolated half is already green, so only the loaded half is open):

```
# concurrent load must not produce an 'unexpected diagnostic' reason
for i in 1 2 3 4; do python3 corpus/fixtures/run_battery.py \
    --only r98_gltflat_doc,r98_gltflat_extbin --runs /home/vgpnk/scratch-r104/s11/d5load-$i \
    >/dev/null 2>&1 & done; wait
python3 -c "… tally (case, verdict, n_unexpected_diagnostic) over the 4 receipts …"
```

**Attempted by this seat and NOT reproduced:** the 4-way concurrent probe above ran 4/4 receipts
with `reasons: []` (8/8 rows PASS). The same holds for D4 (`stable=False` 8/8 under the same
4-way load). So neither trigger is "any two concurrent batteries" — both need something my probe
did not supply. **The D4/D5 queue items are therefore evidence-backed but not yet trigger-reproduced
by this seat**; whoever takes them must find the actual trigger before designing a repair.

What the corpus *does* pin down about the trigger, from the 13 full-350 receipts:

| receipt | D4 `bpy_rbw3d_render` | D5 rows failing |
|---|---|---|
| `…174432492194Z` | PASS | 1 (`doc`) |
| `…174509076978Z` | PASS | 1 (`extbin`) |
| `…174635717082Z` | FAIL | 0 |
| `…175032933066Z` | PASS | 2 (both) |
| `…183757977812Z` | FAIL | 0 |
| `…184232181419Z` | FAIL | 0 |

D4 and D5 **never co-occur** in the same receipt, and D4 fires only in the 15:48–15:55 window
(three consecutive receipts) while D5 fires only in the 14:56–15:03 window. That is the signature of
**two different external pressures**, not one shared cause — most likely the sibling lanes' load
profile changing across the round, with the `r98_gltflat` app-dir collision needing a *concurrent
same-fixture* writer rather than mere CPU pressure.

Acceptance for the repair: 4/4 loaded receipts carry `reasons: []` **and** the 10/10 isolated result
above still holds. If it cannot be made deterministic, the row's claim must be narrowed and the
`ue=` counter taught about the expected-diagnostic class — with a dated correction note.

---

## 6. D6 — host scratch pressure (C2's root cause, reproduced live by this seat)

`/tmp` is a 16 G tmpfs under a **per-user quota**. `df` reports free space while writes fail:

```
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G  80% /tmp
$ touch /tmp/s11-quota-test && echo "write ok" || echo "write FAILED"
write ok                     # small file still fits
$ echo "rc=$?" > /tmp/s11-c.rc
/bin/bash: line 1: echo: write error: Disk quota exceeded
```

Reproduced consequences, all mine, all this round:

- A battery invocation with `--runs /tmp/s11-cannon24` died in `shutil.copyfile`:
  `OSError: [Errno 122] Disk quota exceeded`.
- Four concurrent patched arms whose stdout went to `/tmp` returned **0 bytes each except one**;
  the same four with output on real disk returned 4023 bytes and one PASS line each. **This is the
  trap that can make a green arm look red** — see §2.5.

### 6.1 C2 state

The **gate side is landed**: `corpus/knowledge/unreal-mcp/gate/run_gate.sh` now validates
`WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` up front and routes both scratch sites through it
(`MANLOG`, `WORK`), with a distinct BLOCKED-retry hint at `:271`. Current sha
`e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08`. The flake harness
(`reports/round-104/gate/flake_harness.sh`) reports 10/10 STABLE at `POINTERS=101 UNRESOLVED=0`.

**Queue item D6-Q1 (battery side — OPEN).** `run_battery.py` still writes its scratch under the
`--runs` root, which every seat defaults into `/tmp`. Nothing in the runner validates the root or
reports `EDQUOT` distinctly. Two shapes:

- **D6-Q1a (cheap):** document in `corpus/fixtures/README.md` that `--runs` must point at real disk
  on a quota-pressured host, and have the close protocol pass a lane-local `--runs`.
- **D6-Q1b:** a preflight in `run_battery.py` that writes a 1 MiB probe into the run root and exits
  with a distinct message when it fails — so a quota-starved run can never be misread as a physics
  red. This edits a pinned fixture file and needs its own seat.

**Acceptance for D6-Q1b:**

```
python3 corpus/fixtures/run_battery.py --runs /tmp/definitely-quota-bound
# must exit non-zero with an explicit quota/scratch message, NOT a per-row physics FAIL
```

---

## 7. D7 — `navagent3d_detour_mut_ctx_resume`: an intermittent arm assertion (NEW, this seat)

This one is different in kind from D3/D4/D5: the row **exits 1**, and the failure comes from the
fixture's **own** `_fail`, not from a marker comparison. It surfaced in the 16:32 corpus receipt
`corpus/live/runs/20261018T192045623599Z/verdicts.json`:

```
$ python3 -c "… that receipt's failing rows …"
navagent3d_detour_mut_ctx_resume  exit=1
  reasons=['exit 1 != expected 0', 'exact stdout marker missing',
           'unexpected stderr line: ERROR: navagent3d_detour: mut_ctx_resume step1
              final=2.500000,0.000000,4.000000 expected=2.500000,0.000000,5.500000',
           'unexpected stderr line: at: push_error (core/variant/variant_utility.cpp:1023)',
           'unexpected stderr line: GDScript backtrace (most recent call first):',
           'unexpected stderr line: [0] _fail (res://navagent3d_detour.gd:564)', …]
  elapsed=1.34
```

The assertion is a **measured geometry mismatch inside the arm's own step ladder**: step 1's
`final` came back `(2.5, 0, 4.0)` where the arm expects `(2.5, 0, 5.5)`. `corpus/fixtures/navagent3d_detour.gd:2128`
defines the arm; `:2216-2232` is the comparator that produced the message; `:564` is the `_fail`
callsite. The pin itself is unaffected — this is the fixture disagreeing with *itself*, which is a
stronger signal than a pin drift.

**Frequency and the negative control — 1 of 14 receipts, 0 of 20 isolated reps:**

```
$ # census over corpus/live/runs/*/verdicts.json (350-row receipts only)
16:32 20261018T192045623599Z  FAIL 1 0   # the only occurrence
$ # 14 receipts carry this row; fails = 1
$ # 20 consecutive isolated reps, --only navagent3d_detour_mut_ctx_resume
20 isolated reps: {'PASS': 20}
$ # and 6 concurrent reps of the same row
6 concurrent reps: {'PASS': 6}
```

The r102 lane receipt itself has this row **PASS** (`0`, `[]`, 1.371 s), so it is not a regression
introduced by r104 and not one of the 14 original failures.

**Queue item D7-Q1.** This is the highest-value open item in this ledger, because it is the only
class that can produce a **genuine red** rather than a pin/marker artifact. The trigger is not
reproduced (20 isolated + 6 concurrent all green), so the first task is reproduction, not repair:

```
# hunt the trigger: repeat the full battery and watch only this row
for i in $(seq 1 6); do python3 corpus/fixtures/run_battery.py \
    --runs <lane-local>/d7full-$i >/dev/null 2>&1; done
python3 -c "… list failing rows per receipt; look for navagent3d_detour_mut_ctx_resume …"
```

**Attempted by this seat and inconclusive.** I started this hunt (three consecutive full batteries
into `/home/vgpnk/scratch-r104/s11/d7full-*`) but stopped it after the first battery had not
completed in the time available; **it produced no receipt, so the hunt neither reproduced nor
exonerated D7.** Treat the trigger as unknown.

Acceptance for the repair: 6/6 full batteries with the row PASS, **and** a stated mechanism for the
`final` mismatch (the arm's step ladder vs the engine's served path). If the mismatch is real
engine behaviour rather than a flake, the arm's expected `final` must be corrected with a dated
correction note — this is the one class where "re-pin" may be the *correct* action, because the
assertion is the fixture's claim about the engine, not an environment token.

**Interaction with D1's repair:** none. The D7 receipt (`…192045623599Z`, 16:32) has
`phys3d_joints_free_ops` **PASS** and `phys3d_joints.gd` digest `c7e77638…`, so D7 fired on a
patched form of the tree (the pre-`BATCH_BOUND_S` one). It is not caused by, and does not mask, the
D1 fix — but it *is* the reason that receipt reads 336 rather than 337.

---

## 8. Fold rules for the close (what the after-count means)

1. **The measured after-count is 337/350** (`reports/round-104/physics/author-runs-full/20261018T192105574998Z`),
   with exactly the 13 D3 cannon rows failing. That is the number the round reports: D1 folded
   (336→337), D3 untouched.
2. **337 is not the ceiling.** The 16:01 corpus receipt
   (`corpus/live/runs/20261018T184812159114Z`) scored **349/350** with D1 the only failure and all 19
   cannon rows passing under a v24-first PATH. The same patched tree should therefore reach
   **350/350** under that PATH. Compare the after-count against *both* numbers, and say which PATH
   the receipt ran under.
3. **Never quote a single receipt as "the" full-battery number.** Across 14 corpus receipts the
   same rows scored 334–349 (one 334, five 335, seven 336, one 349). Report the receipt id, the
   totals line, the PATH, and the failing-row list.
4. **Attribute before repairing.** For any red row, first classify by `reasons`:
   `TIMEOUT after 20 seconds` + `elapsed ≈ 20.0` → D1/D6; `exit 1 != expected 0` with a
   `res://<fixture>.gd` backtrace → **D7** (the fixture's own assertion — the only genuine red
   class); `['exact stdout marker missing']` alone with a version-shaped token diff → D3;
   `['exact stdout marker missing']` with a one-token boolean/state diff → D4; any
   `unexpected diagnostic:` entry → D5.
5. **A red row in this battery is usually not a physics regression.** Of the seven classes, only D7
   is the fixture disagreeing with itself; D1 was a budget underrun, D3/D4 are pins encoding an
   environment or a load outcome, D5/D6 are shared-host artifacts. Check the class before touching
   a fixture.
6. **Do not fold D3 into any fixture commit.** D3-Q1a changes no pinned byte and is the only option
   that keeps the r102 receipt comparable.
7. **The D1 repair changed no pin.** `run_battery.py` sha is `f456bd00…`, byte-identical to the
   r102 `seed_digests` entry, and the row's marker is `706ad9151452e18d` before and after. If the
   close reports a different `run_battery.py` sha, the D1 claim no longer holds as stated.
8. **Pin the sha you counted on.** `phys3d_joints.gd` moved twice this round
   (`88be87fa…` → `c7e77638…` → `80bf44c5…`). The 337/350 receipt ran on `c7e77638…`; the final
   worktree is `80bf44c5…` and this seat re-verified only this row on it (PASS, same marker). **The
   close must re-run the counting command on the final sha, or quote the sha it counted on** — a
   totals line without a fixture sha is not attributable.
9. **`POINTERS` is tree-wide, not gate-bound.** The flake harness's `POINTERS=101` reads every
   `.md`/`.txt` in the subtree, so it moves with sibling seats' reports, not with the gate's sha.
10. **A 337/350 close is not a regression against 336/350.** The classes are disjoint and
   attributable: the r104 receipt's 13 failures are all D3, and D7 fired in a *different* receipt
   (`…192045623599Z`, 16:32) which has `free_ops` PASS. If a future close sees 336, check whether
   D7 fired — the D1 fix does not protect against it.

---

## 9. What this seat established, and what it did not

**Established, each with a command run on this host:**
- D1 before: 13/13 pre-patch receipts at the cap, 0 PASS on the unpatched tree; the 20 s bound is
  the binding constraint, not the fixture's inner `BOUND_S`. After: 2/2 post-patch receipts
  (`…192036192858Z` isolated, `…192045623599Z` full) PASS.
- D1 after: `PASS … exit=0`, `reasons []`, elapsed **1.95 s** in my first isolated receipt, **2.768 s**
  in the round's full-regression receipt (`c7e77638…`), and **2.714 s** re-checked on the final bytes
  (`80bf44c5…`); marker byte-equal to the pin (`706ad9151452e18d`, 3921 bytes) in all three;
  2.7–3.2 s standalone vs 22.2–24.7 s pre-patch; 4 concurrent arms on separate scratches all PASS.
- The **full-regression after-count: 337/350**, the 13 failures being exactly the D3 cannon rows
  (§1.1) — with `run_battery.py` byte-identical (`f456bd00…`) and `seeds_unchanged: true`. The
  receipt ran on `phys3d_joints.gd` = `c7e77638…`; the final worktree is `80bf44c5…` (see fold
  rule 8).
- D3: 13/13 `normalize_eq=True` on the node token; FAIL↔PASS flips on `PATH` alone; one corpus
  receipt already scored **349/350** with the v24 pin first on PATH.
- Token audit over the 350 pins: 13 `node=v`, 14 `py=`, 10 `blender-`, all currently matching the
  host.
- D4 and D5: two flaky rows not in any prior report, each with the exact token/reason signature —
  and each **green in 12/12 and 10/10 isolated reps**, so both are load/concurrency-triggered.
- D7: a third flaky row, but the only one that produces a **genuine exit-1 red** — the fixture's own
  assertion (`navagent3d_detour.gd:564` via the `:2216-2232` comparator) fired once in 14 receipts
  and never in 20 isolated or 6 concurrent reps.
- D6: `EDQUOT` reproduced live on `/tmp`; the same four arms that read as empty under `/tmp`
  redirects read as 4023-byte PASSes on real disk.

**Not established / left open:**
- **I did not reproduce the D4/D5/D7 triggers.** My 4-way concurrent probe left D4/D5 green
  (`stable=False` 8/8; `reasons: []` 8/8), and D7 was green 20/20 isolated and 6/6 concurrent, so
  "any concurrency" is not the trigger. The receipts show D4 and D5 never co-occur and fire in
  different time windows (§5 table); the actual triggers are r105 tasks, not solved ones.
- D3-Q1, D4-Q1, D5-Q1, D6-Q1, D7-Q1 are **unapplied**. Nothing in §3–§7 was repaired by this seat.
- I did not chase D5's exact race mechanism (seed cleanup vs a concurrent reader) or D7's `final`
  mismatch mechanism; I proved the trigger signatures, the affected cells, and the negative
  (isolated/concurrent) controls, not the interleavings.
- **Disclosure:** my scratch runs wrote only under `/home/vgpnk/scratch-r104/s11/**`; the
  lane-local `reports/round-104/physics/**` run artifacts were written by SEAT-02/SEAT-07, not by
  me, and I only read them. One battery invocation of mine was pointed at `/tmp/s11-cannon24` and
  failed on quota before writing a receipt; the equivalent run was then re-issued to
  `/home/vgpnk/scratch-r104/s11/c24` and is the one quoted in §3.2. Two of my early patched-arm reps
  returned 0-byte stdout for the same `/tmp` reason and are disclosed in §2.5 rather than quoted.
