# SEAT-09 — SEED-CHECK: CASES-table invariance across the r104 physics patch

**Seat:** SEAT-09 · **Round:** r104 · **Claim:** C1 (depth) — fix
`phys3d_joints_free_ops` wall-cost.
**Mandate:** AST-extract the `CASES` list from the patched
`corpus/fixtures/run_battery.py` and diff it against HEAD's. Required
result: **zero row additions, zero removals, zero expectation edits.**
Paste the diff proof.

**Scope note.** `corpus/fixtures/**` is write-protected this round except
for SEAT-04's declared scope (`phys3d_joints.gd`, and `run_battery.py`
only if the r104 design doc names it). This seat writes **no** fixture
bytes — it reads HEAD's blob and the working tree, and writes only this
file. All tooling lives under `/var/tmp/seat09/` (see §3b: `/tmp` hit its
quota mid-run, so the scratch was relocated).

---

## 1. Method

Two throwaway tools, both written this seat:

| Tool | Path | Job |
|---|---|---|
| extractor | `/var/tmp/seat09/extract_cases.py` | AST-parse the module-level `CASES = [...]`, emit canonical JSON |
| comparator | `/var/tmp/seat09/compare_cases.py` | field-level diff of two extractor outputs; exit 0 iff clean |

**Why AST, not `grep`/`import`.**

- A bare `grep` on `CASES` cannot prove *row identity* — it sees text, not
  table structure, and a reflowed or re-commented table reads identically.
  This is the r102 lesson (a bare grep cannot distinguish "fixed" from
  "fixed and documented") applied to a data table.
- `import run_battery` would **execute** the module. The module is a
  runner whose import-time side effects are not assumed safe, and the
  working tree is mid-edit by a concurrent seat. Parsing is inert.
- `ast.literal_eval` on each element makes the extraction **literal-only**:
  if the patch turns any field into a computed expression, the extractor
  **errors out** (`FATAL: non-literal element at line N`) instead of
  silently coercing it. A silent coercion would be a false-pass class.

Row schema extracted per element: `name`, `script`, `flags`,
`expect_exit`, `marker`, plus `src_line` for traceability. The comparator
reports four independent sections — ADDED, REMOVED, ORDER (LCS of the name
sequence), EDITS (per-field, per-name) — and exits non-zero if any of the
four is dirty.

## 2. Baseline — HEAD (`88c3b2c`)

HEAD's blob and the working tree were byte-identical at the time of
extraction, so the HEAD baseline is the pre-patch truth:

```
$ git show HEAD:corpus/fixtures/run_battery.py | sha256sum
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  -
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

This matches the pinned digest in the round brief exactly, so the baseline
is the same artifact the brief names.

```
$ python3 /tmp/seat09/extract_cases.py /tmp/seat09/head_run_battery.py /tmp/seat09/head_cases.json
[extract_cases] /tmp/seat09/head_run_battery.py: sha=f456bd00a1f7cc6f CASES@line39 rows=350 unique=350 dup_names=none
```

HEAD baseline shape:

| Property | Value |
|---|---|
| `CASES` assignment line | 39 |
| rows | **350** |
| unique names | 350 (0 duplicates) |
| distinct scripts | 53 |
| `expect_exit` distribution | `{0: 291, 2: 59}` |
| first / last row | `navagent3d_retarget` / `r100_fpslat_cls` |

350 rows agrees with the brief's "350 CASES rows". The `phys3d_joints`
block occupies lines 522–536 (`sweep`, `rid`, `api`, `free_pair`,
`free_ops`, `detach`, `chain3`, `twopin`) — `free_ops` is at line 530,
`expect_exit=0`, flags `['--arm=free_ops']`.

## 3. Negative controls — the comparator is falsifiable

An identity diff proving "no change" is worthless unless the comparator
**can** report a change. Five synthetic mutations were applied to copies of
the baseline JSON and run through the comparator:

| Control | Mutation | Comparator output | Exit |
|---|---|---|---|
| NC1 | append `" TAMPER"` to one marker | `edits=1` — `navagent3d_next_alternate.marker` shown before/after | 1 |
| NC2 | duplicate a row under a new name | `added=1` — `seat09_added_row`; ORDER DRIFT | 1 |
| NC3 | delete row 7 | `removed=1` — `navagent3d_distance_wide_reach`; LCS 349/350 | 1 |
| NC4 | swap two adjacent rows (no field change) | `edits=0` but ORDER **DRIFT** (LCS 349/350) | 1 |
| NC5 | flip one `expect_exit` 2 → −1 | `edits=1` — `navagent3d_detour_straight.expect_exit` | 1 |

```
$ python3 /tmp/seat09/compare_cases.py /tmp/seat09/worktree_cases.json /tmp/seat09/nc4_reorder.json
[compare_cases] added=0 removed=0 edits=0 order_lcs=349/350
-- ROW COUNT: 350 -> 350 (delta +0)
-- ADDED   (0): none
-- REMOVED (0): none
-- ORDER   : LCS=349 of 350 (DRIFT)
-- EDITS   (0):
   none
```

NC4 is the important one: it is the only control with **no field change and
no count change**, and the ORDER section still catches it. Without that
section, a pure row reordering would pass as "zero edits". All five
controls exit 1; the unmutated pair exits 0. The comparator therefore
discriminates on every axis the mandate names.

## 3b. Independent cross-check and rehearsal

**Cross-check against a second extraction path.** The AST extraction is
checked against a plain text count of table rows, so a bug in the AST walk
cannot pass unnoticed:

```
$ # regex ^    \(  over the CASES block, vs len(node.value.elts)
CASES spans lines 39..916 (878 lines)
text rows = 350 | AST rows = 350 | MATCH
fields/row: {5: 350}
flags types: {'list': 350}
marker types: {'str': 350}
name types: {'str': 350}
```

Both methods agree at 350 rows, every row is exactly 5 fields, and every
field is the expected type. A type change (e.g. a marker becoming an
f-string) would surface here as a `FATAL` from the extractor, not as a
silent value coercion.

**Rehearsal on a simulated patch.** Because the real patch had not landed,
the end-to-end procedure was rehearsed on copies in `/var/tmp/seat09/`
(never on the protected fixture):

| Rehearsal | Simulated change | File sha | CASES diff | Exit |
|---|---|---|---|---|
| clean | `CASE_TIMEOUT_SECONDS` 20→60 + a new module-level helper function | `6b7b6ce6…` | 0 added / 0 removed / 0 edits | **0** |
| dirty | the same, plus `phys3d_joints_free_ops` `expect_exit` 0→2 | `d79abd5f…` | `phys3d_joints_free_ops.expect_exit: 0 → 2` | **1** |

```
$ python3 /var/tmp/seat09/compare_cases.py /var/tmp/seat09/head_cases.json /var/tmp/seat09/sim_bad_cases.json
[compare_cases] added=0 removed=0 edits=1 order_lcs=350/350
after:  sha256=d79abd5f6dd0c0ce07c0bb23a82e1ad6a95373c068689d326077675d2fd16a9e
-- ROW COUNT: 350 -> 350 (delta +0)
-- EDITS   (1):
   phys3d_joints_free_ops.expect_exit:
     - 0
     + 2
```

The clean rehearsal is the shape the real C1 patch must produce: a **new
file sha** with an **unchanged CASES table**. The dirty rehearsal is
deliberately anchored on the exact row C1 repairs, which is the single most
likely place for an accidental expectation edit — a fix that "makes the row
pass" by loosening `expect_exit` would be caught here.

**Incidental finding — `/tmp` quota is live (corroborates C2).** While
rehearsing, a copy into `/tmp/seat09` failed:

```
$ cp head_run_battery.py sim_r3.py
cp: error copying 'head_run_battery.py' to 'sim_r3.py': Disk quota exceeded
$ df -h /tmp
tmpfs              16G   13G  3.1G  80% /tmp
```

This is the r103 root cause ("`/tmp` is a shared 16G tmpfs near quota —
`mktemp`/clone workdirs there flake silently") reproducing **during r104**,
in this seat's own shell. It is independent, in-round evidence for C2's
gate-workdir resilience work. This seat's scratch was relocated to
`/var/tmp/seat09/` (root filesystem, 772G free) for the rest of the run.

## 4. Post-patch diff proof

**STATUS: LANDED and verified.**

The C1 repair landed **while this seat was running**, and it landed in
`corpus/fixtures/phys3d_joints.gd` — not in `run_battery.py`. SEAT-04's
declared scope was exactly those two files; the fix that shipped is R3
(concurrent children), which is a **fixture-side** change:

```
$ git diff --stat corpus/fixtures/
 corpus/fixtures/phys3d_joints.gd | 33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)
```

`run_battery.py` — the file this seat's mandate names — is **untouched**:

```
$ sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc  corpus/fixtures/phys3d_joints.gd
```

What the fix had to move, recorded before the patch landed (SEAT-02's
pre-fix receipt, `reports/round-104/physics/before-battery.stdout`):

```
FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
FAIL     phys3d_joints_free_ops             phys3d_joints.gd           --arm=free_ops     None/0    ordinary
totals: cases=1 pass=0 fail=1 ordinary=1 negative_controls=0 probes=0
```

At HEAD the row fails exactly as the r103 ruling describes — killed at the
20 s cap with no exit code and no marker. The 21-child arithmetic is
verifiable from the fixture's own tables: `free_ops` lists **7** cases
(`phys3d_joints.gd:37-39`) and `BACKENDS` lists **3** (`:30`), so
7 × 3 = 21 blocking children, each paying a ~0.9 s Godot boot floor.

### 4.1 The three-level proof ladder

Because `run_battery.py` is byte-identical, the mandate's result holds at
the **strongest** level available. Three independent levels are given,
strongest first, so the conclusion does not rest on any single method:

**Level 1 — per-blob git object identity (strongest).** This compares the
worktree content hash against the exact committed object, catching
modification, deletion, and restoration alike:

```
$ wt=$(git hash-object -- corpus/fixtures/run_battery.py)
$ hb=$(git rev-parse HEAD:corpus/fixtures/run_battery.py)
$ echo "$wt"; echo "$hb"
dd2d9b74448afddb88dcf2da56008302eba8060d
dd2d9b74448afddb88dcf2da56008302eba8060d
IDENTICAL -> CASES table trivially unchanged
```

If the file object is byte-identical to HEAD's, the `CASES` table inside
it is identical *a fortiori* — zero additions, zero removals, zero
expectation edits, by construction rather than by inspection.

**Level 2 — byte-level comparison of the CASES region.** The table's own
line span (`39..916`, from the AST's `end_lineno`) is extracted from both
revisions and compared byte-for-byte:

```
$ git show HEAD:corpus/fixtures/run_battery.py | sed -n '39,916p' > head_cases_region.txt
$ sed -n '39,916p' corpus/fixtures/run_battery.py                > post_cases_region.txt
$ wc -l head_cases_region.txt post_cases_region.txt
   878 head_cases_region.txt
   878 post_cases_region.txt
$ cmp head_cases_region.txt post_cases_region.txt && echo "CASES REGION BYTE-IDENTICAL"
CASES REGION BYTE-IDENTICAL
$ sha256sum head_cases_region.txt post_cases_region.txt
550f70253d1c287ca54c18cb2451850fd84efe18a3ddefb292611220ca2b2444  head_cases_region.txt
550f70253d1c287ca54c18cb2451850fd84efe18a3ddefb292611220ca2b2444  post_cases_region.txt
```

**Level 3 — AST field-level diff (the mandate's own method).** Extracted
from the live patched tree and diffed against the HEAD extraction:

```
$ python3 extract_cases.py …/corpus/fixtures/run_battery.py post_final_cases.json
[extract_cases] …/run_battery.py: sha=f456bd00a1f7cc6f CASES@line39 rows=350 unique=350 dup_names=none
$ python3 compare_cases.py head_cases.json post_final_cases.json
[compare_cases] added=0 removed=0 edits=0 order_lcs=350/350
== SEAT-09 CASES diff proof ==
before: sha256=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
        CASES@line39 rows=350
after:  sha256=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
        CASES@line39 rows=350

-- ROW COUNT: 350 -> 350 (delta +0)
-- ADDED   (0): none
-- REMOVED (0): none
-- ORDER   : LCS=350 of 350 (stable)
-- EDITS   (0):
   none
EXIT=0
```

The `before`/`after` digests are **equal**, which is the machine-readable
statement of the whole result: the extraction was run against the patched
tree and returned the same 350-row table.

### 4.2 What the fixture-side patch changed (context, not this seat's claim)

For completeness, so a reader can see that the landed fix is the
harness-only shape §3b rehearsed — the emitted stream is preserved and only
the wall clock moves:

```diff
-func _run_child(case: String, bk: String, engine: String) -> Dictionary:
+# r104 R3 — spawn every (case, backend) child first, then collect in the
+# original nested-loop order. The emitted stream stays a pure function of the
+# per-child logs; only the wall clock changes.
+func _spawn_child(case: String, bk: String, engine: String) -> Dictionary:
 …
-	var code := OS.execute("/bin/sh", ["-c", cmd], [], false)
+	var pid := OS.create_process("/bin/sh", ["-c", cmd], false)
+	if pid <= 0:
+		return {"err": "spawn failed"}
+	return {"case": case, "bk": bk, "pid": pid, "log": logpath}
+
+
+func _collect_child(j: Dictionary) -> Dictionary:
+	while OS.is_process_running(j["pid"]):
+		OS.delay_msec(5)
+	var code := OS.get_process_exit_code(j["pid"])
```

The blocking `OS.execute(…, false)` is replaced by `OS.create_process` plus
a collect loop that walks `jobs` in the **original nested-loop order**, so
`_parts` is assembled in the same sequence as before. That is what makes the
PASS marker order-stable under concurrency, and it is why the CASES table
needed no edit: the fix removes the 21-boot serial floor without touching
any expectation. This seat makes **no** runtime claim about the fix's effect
— that is SEAT-04's after-receipt, and Unreal is not involved at any point.

## 5. Verdict

**PASS — zero row additions, zero removals, zero expectation edits.**

- `run_battery.py` is byte-identical to HEAD (blob `dd2d9b74…`, sha256
  `f456bd00…`), so the 350-row `CASES` table is unchanged at the strongest
  level of proof; the AST diff independently re-derives the same result
  (`added=0 removed=0 edits=0 order_lcs=350/350`, exit 0).
- The C1 fix landed entirely in `corpus/fixtures/phys3d_joints.gd`
  (`88be87fa…` → `c7e77638…`, 26 insertions / 7 deletions) as R3.
- The comparator is falsifiable: five synthetic mutations — including a
  reorder-only change with no field or count delta — all exit 1 (§3), and a
  rehearsal anchored on the very row C1 repairs caught a tampered
  `expect_exit` (§3b).

### Residual / caveats

- **`phys3d_joints.gd` was still being written while this seat ran.** Three
  distinct digests were observed in sequence: `88be87fa…` (HEAD),
  `0cd74715…` (intermediate, 11 insertions / 5 deletions), `c7e77638…`
  (final, 26 insertions / 7 deletions). The verdict above is anchored to
  `c7e77638…`, which was confirmed settled by three reads two seconds apart:

```
c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc  corpus/fixtures/phys3d_joints.gd  f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc  corpus/fixtures/phys3d_joints.gd  f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
c7e776387f607f084379ace95cd44987518cc6e5bb1b9b5376b27e1ece919ccc  corpus/fixtures/phys3d_joints.gd  f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

  `run_battery.py` did **not** move at any point (`f456bd00…` throughout,
  from the first poll to the last), so this seat's own result is unaffected
  by the fixture churn. A final re-extraction at the end of the run returned
  the same clean diff (`compare EXIT=0`).
- **Method scope.** Level 3 (AST) proves the `CASES` *table*. It does not
  and cannot prove anything about code outside the table — the harness
  functions, `CASE_TIMEOUT_SECONDS`, the probes, or `_finish`. Those are
  covered here only incidentally, by Level 1/2 byte-identity of the whole
  file. This is the correct division: a table diff is not a whole-file diff,
  and the report should not be read as the latter.
- **Unreal.** No Unreal runtime claim is made anywhere in this file. Unreal
  Editor is not installed on this host.

