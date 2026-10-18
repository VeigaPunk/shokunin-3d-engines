# r103 · SEAT-63 BATTERY-CONSISTENCY — 350-row invariant + the 14-FAIL row mapping

Lane: `game-dev-3d-shokunin` · round 103 · base HEAD `c85a816` (`c6f655d` work commit)
Written 2026-10-18. **Owned path: this file only.** No fixture byte, no gate byte, no
`LOG.md`/`SCORECARD.md`/`SHONEN.md`/`SKILL.md`/`PROVINCE.md`, and no `reports/round-10{1,2}/**`
byte was written by this seat. All `/tmp` trees below are private scratch, removed at the end.

Tags: **[O]** observed with the command shown · **[I]** labelled inference · **[?]** unknown.

Subject: confirm that `corpus/fixtures/run_battery.py` still carries **350** `CASES` rows with
sha256 `f456bd00…`, and that the **14 FAIL classes** in the r102 idle receipt
`corpus/live/runs/20261018T181301123479Z/verdicts.json` (336/350) still map onto rows that
exist today.

---

## 0. Verdict

**Both confirmed, with one qualification that matters.** The 350-row invariant holds
(350 rows, 350 unique ids, source sha unchanged, and the receipt's own recorded seed digest
for `run_battery.py` is that same sha). All 14 FAIL names are live rows, present exactly once
each, and the receipt's case sequence is *element-for-element identical* to the current `CASES`
order — so the receipt was produced against exactly this `CASES` list, not an earlier one.

The qualification: the 14 failures are **not** one defect and **not** a fixture-defect class.
13 are expected-marker drift on a pinned `node` version (the r94 class, already routed in r102);
1 (`phys3d_joints_free_ops`) is a **wall-clock budget** failure whose mechanism this seat
measured directly (§4) — the arm needs ~21 s of a 20 s per-case budget, deterministically, on a
loaded host, while the fixture's own declared bound is also 20 s. Neither is "the battery is
corrupt", and the 336/350 figure should not be read as fixture damage.

---

## 1. The 350-row invariant — source side

```
$ wc -l corpus/fixtures/run_battery.py; sha256sum corpus/fixtures/run_battery.py
1387 corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py

$ python3 -c "<load CASES, count>"
CASES rows: 350
unique ids: 350

$ git hash-object corpus/fixtures/run_battery.py; git rev-parse HEAD:corpus/fixtures/run_battery.py
dd2d9b74448afddb88dcf2da56008302eba8060d
dd2d9b74448afddb88dcf2da56008302eba8060d
```

Three independent statements, all **[O]**:

- **sha256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`** — matches
  the sha named in the seat brief and in `reports/round-102/r102-report.md` ("`run_battery.py`
  `f456bd00…` stable"). Line count 1387.
- **`len(CASES) == 350`** and **350 distinct case ids** — no duplicate name can silently
  shadow a row (`grep -oE '^    \("[a-z0-9_]+",' | sort | uniq -d` → no output).
- **Working tree == HEAD blob**: `git hash-object` and `git rev-parse HEAD:<path>` both return
  `dd2d9b74448afddb88dcf2da56008302eba8060d`, so this is the committed source, not a
  working-tree edit. `CASES` spans `:39`–`:916` (AST: `elements=350`), i.e. 350 rows across
  878 lines.

The rows are still AST-parseable (`ast.parse` walked the module and yielded the `CASES`
assignment), which is the same property r102 SEAT-33 proved.

## 2. The 14 FAIL classes — row mapping

The receipt:

```
$ python3 -c "<receipt totals + non-PASS list>"
totals: {"cases": 350, "pass": 336, "fail": 14, "ordinary": 291, "negative_controls": 59}
verdict: FAIL
  FAIL phys3d_joints_free_ops   kind=ordinary        exit=None/0 reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']
  FAIL r94_cannon_det           kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_det2          kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_varstep       kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_bailout       kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_nan           kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_sync          kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_material      kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_friction      kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_parity        kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_parity2       kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_modes         kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_order         kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
  FAIL r94_cannon_backends      kind=ordinary        exit=0/0 reasons=['exact stdout marker missing']
```

`336/350` is confirmed exactly, as are the ordinary/negative split `291/59` and
`verdict: "FAIL"`. The receipt is gitignored (`corpus/.gitignore:1` → `live/`), so its bytes are
the durable record; sha256 for reference:

```
$ sha256sum corpus/live/runs/20261018T181301123479Z/verdicts.json
58f48585ded496945557c3936e38b0c7c26d237d067b50304281cd7be98b4d5e  …/verdicts.json
```

### 2.1 All 14 names grep to exactly one current row

```
$ for n in <the 14 names>; do printf '%-24s %s\n' "$n" "$(grep -cE "^    \(\"$n\"," corpus/fixtures/run_battery.py)"; done
phys3d_joints_free_ops   1
r94_cannon_det           1
r94_cannon_det2          1
r94_cannon_varstep       1
r94_cannon_bailout       1
r94_cannon_nan           1
r94_cannon_sync          1
r94_cannon_material      1
r94_cannon_friction      1
r94_cannon_parity        1
r94_cannon_parity2       1
r94_cannon_modes         1
r94_cannon_order         1
r94_cannon_backends      1
```

14/14 present, each exactly once, none retired or renamed. Row `phys3d_joints_free_ops` sits at
`:530` (script `phys3d_joints.gd`, flags `["--arm=free_ops"]`, expected exit `0`); the 13
`r94_cannon_*` ordinary rows sit at `:661`–`:685`, all script `r94_cannon.gd`, expected exit `0`,
each a distinct `--arm=`.

### 2.2 The receipt was produced against *this* `CASES` list

This is the part that makes the mapping more than a name-grep:

```
$ python3 -c "<CASES-vs-receipt order/set/diff; node-token normalisation>"
order identical: True
set identical: True
receipt-only: []
cases-only: []
receipt seed_digests['run_battery.py']: f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
seed_digests map == live seed_digests(): True entries: 130
r94_cannon_det marker len exp/act: 3357 3357
  opcode replace '4.21' -> '6.12'
  equal after node-token normalisation: True
```

- `order identical: True` — the receipt's `results[i]['case']` sequence equals
  `[c[0] for c in CASES]` element-for-element, not merely as a set. The receipt therefore
  records a run of the *current* 350-row list.
- The receipt's own `seed_digests["run_battery.py"]` is `f456bd00…` — the same sha measured in
  §1. The runner records this map before the run, so this is the receipt self-attesting to the
  source revision it executed.
- `seed_digests map == live seed_digests(): True` (130 entries both sides) — the 130-entry
  digest map in the receipt still equals the map `seed_digests()` computes today, so no seed
  file has moved since the receipt was written either. `seeds_unchanged` is `true` in the
  receipt.

## 3. FAIL class A — the 13 `r94_cannon_*` rows (marker drift on a pinned `node`)

```
$ grep -o "node=v[0-9.]*" corpus/fixtures/run_battery.py | sort | uniq -c
     13 node=v24.21.0
$ node --version
v26.12.0
```

Exactly **13** version-pinned tokens in the whole file and exactly **13** failing `r94_cannon_*`
rows — a clean 1:1, so this class is fully explained by the pin, with no leftover row to account
for. The comparison of the receipt's expected marker against what the row actually printed:

```
$ python3 -c "<difflib opcodes: expected marker vs printed PASS line>"
r94_cannon_det marker len exp/act: 3357 3357
  opcode replace '4.21' -> '6.12'
  equal after node-token normalisation: True
```

Same length (3357 chars), a single `replace` opcode covering `4.21`→`6.12`, and byte-identical
once `node=v24.21.0` is rewritten to `node=v26.12.0`. The fixture prints the host's node version
by design (`r94_cannon.gd:127` probes `node --version`, `:139` prints it into the PASS line), so
this is **environment-marker drift on a pinned row**, exactly as r102 routed it — not fixture
corruption, and not something this seat may fix (a fixture byte is protected).

Reproduced independently, not just read off the receipt:

```
$ python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs /tmp/r103-seat63 --only r94_cannon_det
FAIL r94_cannon_det: exit=0 expected=0 reasons=['exact stdout marker missing']
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
```

with the printed line reading `node=v26.12.0` where the row pins `node=v24.21.0`.

**The negative controls are unaffected.** All six `r94_cannon_neg_*` rows PASS in the receipt
(`exit=2/2` each) because their markers do not carry a version token — the drift hits only the
13 positive rows. That is a useful discriminant: a reader seeing "13 r94_cannon failures" should
not conclude the cannon backend verification is broken; its negative controls are green. The
claim is checked on the rows, not inferred from the receipt:

```
$ python3 -c "<does each r94_cannon_neg_* marker carry a version token?>"
r94_cannon_neg_dt version-token-in-marker: False | exp exit 2
r94_cannon_neg_gravity version-token-in-marker: False | exp exit 2
r94_cannon_neg_steps_early version-token-in-marker: False | exp exit 2
r94_cannon_neg_elapsed version-token-in-marker: False | exp exit 2
r94_cannon_neg_wxyz version-token-in-marker: False | exp exit 2
r94_cannon_neg_grid version-token-in-marker: False | exp exit 2
```

## 4. FAIL class B — `phys3d_joints_free_ops` (wall-clock budget, investigation only)

This seat was asked to **investigate, not repair**. What follows is measurement.

**4.1 The row is slow by construction, and a timeout can only ever capture a prefix.**

`corpus/fixtures/run_battery.py:949` `run_process()` calls
`subprocess.run(..., timeout=timeout_seconds)`. On `TimeoutExpired` it returns the *partial*
stdout plus `code=None` and `"TIMEOUT after N seconds"`; since `subprocess.run` kills the child
and the fixture prints its one PASS digest only at the very end, the captured stdout is the
engine banner and nothing else. The battery passes `CASE_TIMEOUT_SECONDS` (`:36` = **20**; used
at `:1271`). That produces precisely the three reasons the receipt records (`TIMEOUT after 20
seconds` + `no exit code` + `marker missing`) and the single captured stdout line. In the
receipt the row's `elapsed_seconds` is **20.008** — the deadline itself, not a measured
completion.

**4.2 Run standalone it completes, with the exact pinned marker.**

```
$ time /usr/bin/godot --headless --path <scratch> --script res://phys3d_joints.gd -- --arm=free_ops
real	0m21.599s
exit=0
PASS-marker lines: 1
stderr bytes: 0
```

and the marker is not merely similar, it is the pinned row's literal string:

```
$ python3 -c "<is the CASES marker an exact stdout line?>"
expected marker present as exact line: True
```

Three more back-to-back standalone runs (python-timed, 120 s ceiling, reusing one scratch):

```
run1: exit=0 elapsed=20.851s marker_present=True
run2: exit=0 elapsed=22.737s marker_present=True
run3: exit=0 elapsed=21.122s marker_present=True
```

So the row is **correct and green**; it simply needs ~21 s where the battery allows 20. The
byte-exactness claim above rests on the fresh-scratch runs; these three reused a scratch and are
prefix-checked only — see the caveat in §4.4.

**4.3 Mechanism: 21 sequential child Godot processes in one arm.**

`phys3d_joints.gd` runs each (case, backend) measurement as a spawned child Godot in a
generated minimal project under `res://r90bt_*` (`_run_child`, `:117`–`:155`), then merges the
child log. Measured on a fresh scratch copy:

```
standalone: exit=0 elapsed=20.902s marker_present=True
child project dirs created: 21
child-dir mtime span: 19.160 s
loadavg: ['18.85', '15.21', '13.31']
```

21 child projects, first→last creation spanning **19.160 s** — i.e. the arm's own sequential
loop consumes essentially the entire 20 s budget before the parent can print anything. The
fixture's declared bound is the same number as the battery's deadline:
```
$ grep -n BOUND_S corpus/fixtures/phys3d_joints.gd
29:const BOUND_S := 20
133:			BOUND_S, OS.get_executable_path(), dir, script_path, case,
```

`BOUND_S` is handed to each child's `timeout -s KILL` (`:132`–`:133`), so both layers are
independently set to 20 s and there is **zero margin** between the fixture's self-declared
budget and the harness deadline. A ~1 s host-side overrun therefore flips the row — which is
why the r102 seats variously saw it fail (this host, loaded) and pass (idle host, standalone).

**4.4 Corroboration from a peer r103 seat.** `/tmp/r103phys` (SEAT-32, investigating the same
row) independently measured 21 `r90bt_*` children with a first→last span of **19.237 s**,
a single-child cost of ~1.75 s, and a direct invocation at `rc=0 wall_ms=22165`. That is the
same three numbers as §4.3 to within host noise. Its classification is the same as this
section's — *harness-timeout, not engine behaviour and not a fixture defect* — and it adds the
decisive discrimination that the arm spends only **~3.5 s of CPU** against ~22.5 s of wall
clock, so the cost is serial process spawn + I/O, not physics work. It also reports that
raising **only** `CASE_TIMEOUT_SECONDS` to 120 makes the row PASS with an empty reason list
(`reports/round-103/physics/investigate.md`).

One caveat it raises that qualifies §4.2 above: on a scratch **reused** from an earlier
`phys3d_joints` run (child dirs already present), a re-run can emit a *different* marker while
still exiting 0 — three cells differed in its sample. My own marker-equality check was run on a
scratch created fresh by the preceding `--only` run and a further fresh copy in §4.3, both of
which matched the pin exactly; the three python-timed repeats reused one scratch and are only
prefix-checked (`marker_present=True`). So §4.2's byte-exact claim rests on fresh-scratch runs,
which is the state the battery itself creates per run.

**4.5 The slowest rows, for context.** The row is not a wild outlier so much as the worst of a
slow tail; ten rows in this receipt exceed 6 s against the same 20 s ceiling:

```
    20.008s FAIL phys3d_joints_free_ops      <- the one that crossed
    15.985s PASS r100_fpslat_life
    12.078s PASS phys3d_joints_free_pair
     9.918s PASS r97_nodelat_softfloor
     9.847s PASS phys3d_events_deferred_hang
     9.403s PASS phys3d_joints_twopin
     8.749s PASS r96_joltdet_ffps
     7.177s PASS phys3d_events_joint_pin
     7.019s PASS r97_nodelat_joint
     6.983s PASS r97_nodelat_cb
  case_timeout_seconds = 20
```

**4.6 Observation flagged, not repaired — `r90bt_*` directories appear in the seed tree.**
`phys3d_joints.gd` builds its child projects under `res://r90bt_<arm>_<case>_<backend>`, so the
directory location follows whatever `--path` the caller used. While running §4 this seat saw
**21 untracked `corpus/fixtures/r90bt_free_ops_*` directories** appear with mtimes
`15:35:23`–`15:35:45` and later disappear (`ls -d corpus/fixtures/r90bt_*` → none). My own runs
were all `--path /tmp/...` and wrote their children into that scratch (30 dirs there; the r102
idle run's scratch holds 51), so I **cannot attribute** those 21 to my own commands — some other
process was running with `--path corpus/fixtures` at that moment **[I]**.

Why it is worth a ruling rather than silence: `seed_digests()` (`:940`–`:946`) hashes every file
under `HERE` except `three/**` and `__pycache__`, so a `r90bt_*` directory present at run start
is folded into the seed map and copied into the scratch. That does not by itself trip
`seeds_unchanged` (the map is taken before and after), but it does mean the seed set is
non-deterministic in size depending on who else ran the battery concurrently, and r102's
IP-2 wiring work (`reports/round-102/battery-relation.md`) cares about exactly this boundary.
Today's live map is still 130 entries and still equal to the receipt's, so nothing is wrong right
now. **This seat made no change** — fixture bytes are protected and the row is investigation-only.

The mechanism by which a sibling arm can be affected is worth naming, because it is not only a
seed-count concern: the child's physics engine is a per-project constant written into the
generated `project.godot` (`phys3d_joints.gd:122`–`:127`, `_project_body`). A concurrently
spawned child that reads a *different* run's `r90bt_<arm>_<case>_<backend>/project.godot` — same
`res://` path because both runs used the same `--path` — would report the wrong engine in its
`engine=` field. SEAT-32 recorded exactly that signature in
`reports/round-103/physics/investigate.md` §5.1 (three Dummy cells reporting `engine=DEFAULT`,
`freeb_world@jolt` empty) when re-running against an already-used scratch. Its sample still
matched the pinned marker, so it is **[?]** unconfirmed — but it is the same collision channel
as the directory observation above, and it means two concurrent `phys3d_joints` runs sharing a
`--path` can perturb each other's child projects.

## 5. The 14 is not the only number this host produces

For honesty about what "the 14 FAIL classes" does and does not denote: across the r102 full runs
still on disk, the FAIL count varied 14–16, with the *extra* names being transient `r98_gltflat`
rows failing on a missing asset path, not on any pinned constant:

```
20261018T174423377345Z  cases=350 pass=336 fail=14  extra=[]
20261018T174432492194Z  cases=350 pass=335 fail=15  extra=['r98_gltflat_doc']
20261018T174509076978Z  cases=350 pass=335 fail=15  extra=['r98_gltflat_extbin']
20261018T174521611949Z  cases=350 pass=336 fail=14  extra=[]
20261018T174635717082Z  cases=350 pass=335 fail=15  extra=['bpy_rbw3d_render']
20261018T175023461328Z  cases=350 pass=336 fail=14  extra=[]
20261018T175032933066Z  cases=350 pass=334 fail=16  extra=['r98_gltflat_doc','r98_gltflat_extbin']
20261018T175622725474Z  cases=350 pass=336 fail=14  extra=[]
20261018T181301123479Z  cases=350 pass=336 fail=14  extra=[]     <- the r102 idle receipt
```

The `r98_gltflat_doc` / `_extbin` rows fail with
`unexpected diagnostic: # r98_gltflat doc doc_abs@gp ue=ERROR: Can't open file at path "UD/R98Scout/tri.glb"`,
i.e. a cross-run asset-visibility effect on rows that write into `user://` / an absolute dir —
the same shape of concurrency hazard as §4.6. The mechanism is in the fixture's own cleanup
policy: it records whether the user-data dir already existed (`r98_gltflat.gd:172`) and, if it
did, removes only its three seeded files rather than the directory (`:432`–`:438`). Two runs
sharing that app name can therefore interleave a seed against a cleanup. **The stable,
reproducible subset is exactly the 14**: the 13 node-pinned `r94_cannon_*` rows plus
`phys3d_joints_free_ops`. Five of the nine full runs on disk land on 336/350 with no extra
names, which is why the r102 receipt is the right reference point — but a reader should treat
"14" as "the reproducible core", not as a constant of the battery.

## 6. What this seat did not do

- **No repair.** No fixture byte, no `run_battery.py` byte, no gate byte changed. `phys3d_joints_free_ops`
  was investigation-only per the seat brief; the two repairs it implies (raise
  `CASE_TIMEOUT_SECONDS` for this row, and/or raise/parameterise `BOUND_S`, and/or make the
  runner preserve partial stdout on timeout) are the operator's call and are routed, not taken.
- **No silent rewrite of any historical claim.** The r102 texts that record `336/350` are left
  byte-intact; §5 records the run-to-run variation as an addendum rather than editing them.
- **No Unreal runtime claim.** Nothing here touches the editor or live MCP; upstream plugin pin
  `a6aa73ada02a9fb1f5415bec491f9942c519b297` is unaffected.
- **No write outside this file.** `git status --porcelain` at end of seat shows only
  `?? reports/round-103/` from this seat; the six modified tracked files
  (`corpus/artifacts/glb-r12/README.md`, `corpus/artifacts/unity-r19/README.md`,
  `corpus/fixtures/three/README.md`, `corpus/knowledge/unreal-mcp/adaptation-kimi.md`,
  `corpus/knowledge/unreal-mcp/gate/README.md`,
  `corpus/knowledge/unreal-mcp/gate/run_gate.sh`) belong to the C1/C2/C3 seats, not to this one.

## 7. Routed forward (r103+)

1. **`r94_cannon` node pin** — the 13 rows pin `node=v24.21.0`; host is `v26.12.0`. Either pin
   the node used for the battery side-by-side, or re-baseline the 13 markers. A fixture byte is
   protected, so this needs an owning seat.
2. **`phys3d_joints_free_ops` budget** — measured at 20.85–22.74 s against a 20 s deadline, with
   the fixture's own `BOUND_S := 20`. Options: raise the harness deadline for this row, raise
   `BOUND_S`/parameterise it, or have `run_process` keep partial stdout so a timeout is
   distinguishable from a marker mismatch in the receipt.
3. **`r90bt_*` seed-tree contamination** — a `--path corpus/fixtures` run of any `phys3d_joints`
   arm writes 21 child projects into the protected seed tree, changing the seed-digest map size
   for anyone running concurrently. Ruling needed.
4. **`r98_gltflat_*` cross-run asset visibility** — the 15th/16th failure in some full runs;
   same class of hazard, unrelated to the 14.

---

### Command index (every number above traces to one of these)

`wc -l` · `sha256sum` · `git hash-object` / `git rev-parse HEAD:<path>` · `ast.parse` walk ·
`grep -cE '^    \("<name>",'` ×14 · `grep -o 'node=v[0-9.]*'` · `node --version` ·
`python3` receipt reader (totals / non-PASS list / order-set diff / seed_digests equality /
difflib opcodes) · `python3 corpus/fixtures/run_battery.py --only <name>` ×2 ·
`time /usr/bin/godot --headless --path <scratch> --script res://phys3d_joints.gd -- --arm=free_ops`
×4 (plus one `--arm=free_pair`) · fresh-scratch child-dir count + mtime span ·
`grep -n BOUND_S` / `CASE_TIMEOUT_SECONDS` / `run_process` / `seed_digests` ·
`ls -d corpus/fixtures/r90bt_*` · `sha256sum` receipt · `git status --porcelain`.

### End-of-seat state

```
$ git status --porcelain -uall | grep -v reports/round-103
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

No untracked path outside `reports/round-103/`; `corpus/fixtures/` shows only the
`three/README.md` edit owned by another seat, and `ls -d corpus/fixtures/r90bt_*` → none. The
six modified files are the C1/C2/C3 seats' targets. `__pycache__/run_battery.cpython-314.pyc` is
created by importing the runner to count `CASES`; it is gitignored (`corpus/.gitignore:2`) and
excluded from `seed_digests()` by name, so it neither shows in `git status` nor perturbs the
130-entry map (verified equal to the receipt's).
