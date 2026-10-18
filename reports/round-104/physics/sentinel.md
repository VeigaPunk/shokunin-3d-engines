# r104 SEAT-08 — SCOPE-SENTINEL

**Seat:** SEAT-08 `SCOPE-SENTINEL` · **Round:** 104 · **Lane:** `game-dev-3d-shokunin`
**Owned path written:** this file only (`reports/round-104/physics/sentinel.md`).
Every command below is read-only; my scratch tools live in `~/s08scratch/`, not in the lane.
**Lane HEAD under test:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`88c3b2c`, r103 report-last; work `8c9d9ad`).
**Last sweep:** `2026-10-18T19:33:53Z` — the fixtures answer was identical in **seven** sweeps
between `19:19:48Z` and `19:33:53Z`; only the C2 gate surface moved (see §6.1).
**No Unreal runtime claim is made here** (editor not installed; live-MCP unproven by construction). This seat made no claim about Unreal at all.

## 1. Headline — one admissible fixture write, zero violations

**Exactly one file changed under `corpus/fixtures/`: `phys3d_joints.gd`.** It is SEAT-04's
declared scope. `run_battery.py` — the other conditionally-licensed file — is
**byte-identical to HEAD** and stayed that way through the whole C1 window, which is correct:
**no r104 design doc names it**, so the licensed set is `phys3d_joints.gd` alone. No cannon,
bullet, glTF or runner byte moved. Full `corpus/fixtures/**` walk: **146 tracked blobs,
145 identical, 1 differing, 0 missing, 0 untracked outside `three/node_modules`.**

Verdict: **no protected-path violation, no scope violation, no unlicensed fixture edit.**

**Scope confirmation against the r102 receipt, at row granularity.** The full 350-case after-run
(`reports/round-104/physics/author-runs-full/20261018T192105574998Z/verdicts.json`, §8) reads
**337 pass / 13 fail**, against r102's **336 / 14**. The set difference is one row each way:
`fixed = ['phys3d_joints_free_ops']`, `newly red = []`. The 13 survivors are all `r94_cannon_*`,
which the r103 ledger classified as a separate defect class (D3, node-token pin) and which this
round deliberately did not touch — so the fixtures edit moved exactly the row it was licensed to
move and nothing else.

## 2. `git diff --stat` + file list (the seat's core deliverable)

```
$ git diff --stat -- corpus/fixtures
 corpus/fixtures/phys3d_joints.gd | 33 ++++++++++++++------
 1 file changed, 26 insertions(+), 7 deletions(-)
```

**The file list restricted to the seat's subject — `corpus/fixtures/`:**

```
$ git diff --name-only HEAD -- corpus/fixtures
corpus/fixtures/phys3d_joints.gd
```

One name, and it is the licensed name. `run_battery.py` does **not** appear.

Whole-tree `git diff --stat` at a later instant (`19:25:50Z`) carried two further, non-fixture
entries:

```
 corpus/fixtures/phys3d_joints.gd             |  33 ++++++--
 corpus/knowledge/unreal-mcp/gate/README.md   | 115 ++++++++++++++++++++++++--
 corpus/knowledge/unreal-mcp/gate/run_gate.sh | 123 ++++++++++++++++++++++++---
 3 files changed, 245 insertions(+), 26 deletions(-)
```

Both gate files are C2's declared scope and lie outside `corpus/fixtures/**`, so neither is a
fixtures finding. **They are a moving target and are treated as one** — see §6.1. The fixtures
answer above did not change across any re-sweep in this seat's window.

### 2.1 The C1 diff, verbatim

```
$ git diff -- corpus/fixtures/phys3d_joints.gd        # sha256 9fb0bd9509c25b5f…
```

```diff
@@ -84,13 +84,19 @@ func _initialize() -> void:
 func _run() -> void:
 	if not ARM_CASES.has(arm):
-		_fail("unknown_arm")
+		return _fail("unknown_arm")
+	var jobs: Array = []
 	for case in ARM_CASES[arm]:
 		for bk in BACKENDS:
-			var d := _run_child(case, bk[0], bk[1])
-			if d.has("err"):
-				return _fail("%s@%s %s" % [case, bk[0], d["err"]])
-			_emit(case, bk[0], d)
+			var j := _spawn_child(case, bk[0], bk[1])
+			if j.has("err"):
+				return _fail("%s@%s %s" % [case, bk[0], j["err"]])
+			jobs.append(j)
+	for j in jobs:
+		var d := _collect_child(j)
+		if d.has("err"):
+			return _fail("%s@%s %s" % [j["case"], j["bk"], d["err"]])
+		_emit(j["case"], j["bk"], d)
 	_finish()
@@ -132,7 +141,17 @@
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

This is the **R3 concurrent-children** shape the r103 ledger preferred (§4.3 R3), not the
conservative R2 per-case bound. It changes **only `phys3d_joints.gd`** — consistent with R3's
stated precondition that the rewrite "belongs to a seat that owns `phys3d_joints.gd`".

## 3. Byte-identity sweep — `corpus/fixtures/**` vs HEAD

Method: for every tracked blob, `git cat-file blob HEAD:<path>` sha256 vs on-disk sha256.
Strictly stronger than mtime, and it catches modification, deletion and restoration alike.

```
tracked_blobs=146 identical=145 differing=1 missing=0
  DIFFER  corpus/fixtures/phys3d_joints.gd
untracked files under corpus/fixtures outside three/node_modules = 0
```

The 1264 files under `corpus/fixtures/three/node_modules/**` are the **gitignored** npm tree
(`git ls-files --others --exclude-standard` → 0 for that path; `--ignored` → 1264), excluded from
`seed_digests()` by construction (`run_battery.py:940-946`, `parts[0] != "three"`); they are
unchanged build residue, not seat writes.

### 3.1 Named fixture families — all byte-identical

Each row: disk sha256[:16] = HEAD blob sha256[:16] = r102 receipt `seed_digests` entry.

| fixture | disk | HEAD | r102 receipt | state |
|---|---|---|---|---|
| `run_battery.py` | `f456bd00a1f7cc6f` | `f456bd00a1f7cc6f` | `f456bd00a1f7cc6f` | IDENTICAL |
| `phys3d_joints.gd` | `c7e776387f607f08` | `88be87faee02e6f0` | `88be87faee02e6f0` | **CHANGED (licensed)** |
| `r94_cannon.gd` | `d40a1f7573962677` | `d40a1f7573962677` | `d40a1f7573962677` | IDENTICAL |
| `r94_child.mjs` | `c84a8e8a9bb18af1` | `c84a8e8a9bb18af1` | `c84a8e8a9bb18af1` | IDENTICAL |
| `r95_bullet.gd` | `f988ba86fdef62a0` | `f988ba86fdef62a0` | `f988ba86fdef62a0` | IDENTICAL |
| `r95_child.py` | `8821ebd50459dd13` | `8821ebd50459dd13` | `8821ebd50459dd13` | IDENTICAL |
| `r98_gltflat.gd` | `47998a95bb0401f7` | `47998a95bb0401f7` | `47998a95bb0401f7` | IDENTICAL |
| `r98_probe_gltf.gd` | `18ba68b7065afdce` | `18ba68b7065afdce` | `18ba68b7065afdce` | IDENTICAL |
| `r98_probe_gltf_tr.gd` | `4736126f3c148fb2` | `4736126f3c148fb2` | `4736126f3c148fb2` | IDENTICAL |
| `r100_fpslat.gd` | `da11495de7a24703` | `da11495de7a24703` | `da11495de7a24703` | IDENTICAL |
| `r90_child.gd` | `84f6241de590b581` | `84f6241de590b581` | `84f6241de590b581` | IDENTICAL |
| `project.godot` | `1fda90d46b0529ae` | `1fda90d46b0529ae` | `1fda90d46b0529ae` | IDENTICAL |

**11 of 12 named fixtures are triple-identical** (disk = HEAD = r102). The cannon, bullet and
glTF families — the three families the brief asks to be byte-identical — each sit in that set,
as does the runner itself.

## 4. `seeds_unchanged` machinery — read, not assumed

The runner's own guard is `seed_digests()` (`run_battery.py:940-946`), hashed before the run at
`:1244` and again at `:1343`; a mismatch prints `FAIL seeds were modified during the run` and
forces the battery verdict to FAIL (`:1344-1345`, `:1366`). Its scope is
`HERE.rglob("*")` minus `__pycache__` and minus the `three` subtree — **130 entries**.

```
$ # seed_digests() equivalent, run by this seat against the live tree
seed_map_entries=130 canonical_sha256=7a737c374be61e1eb78b991f8f3858b5d70e944fc062dbbde7ade3a01124bbd6
r102_receipt_entries=130 canonical_sha256=a3d62eb1cdd12cac85332c04fde8ca7a956b96e67199d75085e374804eb8c417
keys_only_now=[]      keys_only_r102=[]
differing_seed_digests_vs_r102=1 ['phys3d_joints.gd']
```

**Read this correctly, because the two numbers say different things and only one is a finding.**

- The **canonical sha moved** (`a3d62eb1…` → `7a737c37…`) and exactly **one** digest differs
  from the r102 receipt: `phys3d_joints.gd`. That is the licensed C1 write, and it is the *only*
  entry in the 130-entry map that moved. If the diff had touched any other fixture, the
  differing list would be longer — this is the machinery **proving** the write's blast radius
  is one file.
- `seeds_unchanged=True` in a receipt is a **within-run** statement: the map at start equals the
  map at end. It is not a statement about HEAD. Every r104 receipt carrying `True` says the run
  did not mutate its own seeds while it ran.

Both r104 baseline receipts carry `seeds_unchanged=True`:

```
$ python3 … scan reports/round-104/physics/{runs,runs-clean}/*/verdicts.json
runs-clean/20261018T191758479619Z/verdicts.json      seeds_unchanged=True  verdict=FAIL  cases=1  seed_entries=130
   free_ops: FAIL None ['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)',
                        'exact stdout marker missing'] elapsed=20.024
runs/20261018T191620117114Z/verdicts.json            seeds_unchanged=True  verdict=FAIL  cases=1  seed_entries=130
   free_ops: FAIL None [same three reasons] elapsed=20.024
```

## 5. CASES rows — 350 in, 350 out, zero edits

The runner's `CASES` table is the round's second invariance surface: a fixture edit that
reached `run_battery.py` would be visible as a row delta even if no fixture byte moved.

```
$ # AST-extract CASES from HEAD blob and from the live tree, canonical-JSON sha256 each
HEAD   CASES line=39 rows=350 unique_names=350  canonical_sha256=4401f367ab7c698f574a17453078e23c303a4eb5b48d7d052ee8e62f5ca926e9
LIVE   CASES line=39 rows=350 unique_names=350  canonical_sha256=4401f367ab7c698f574a17453078e23c303a4eb5b48d7d052ee8e62f5ca926e9
head rows 350 live rows 350 equal: True
```

**Row-level equality, not just count equality** — the extractor's canonical sha is identical
across HEAD and the worktree, so no row was added, removed, reordered, or had a field
(`script` / `flags` / `expect_exit` / `marker`) edited. Supporting shape, both revisions:
`distinct_scripts=53`, `expect_exit_dist={0: 291, 2: 59}`, first row `navagent3d_retarget`,
last row `r100_fpslat_cls`. The 8 `phys3d_joints` rows are present and named
(`sweep, rid, api, free_pair, free_ops, detach, chain3, twopin`).

This is the machine-readable form of "`run_battery.py` was not edited": its bytes match HEAD
(§3.1) *and* its data table is field-identical.

## 6. Protected-path sweep — the whole declared set

Per-blob comparison (`git cat-file blob HEAD:<path>` vs on-disk sha256) over every declared
protected path. Directory rows count tracked blobs; untracked counts exclude
`three/node_modules`.

```
LOG.md                                        MATCH   head=033ec85fe536 disk=033ec85fe536
SCORECARD.md                                  MATCH   head=5083eee2040d disk=5083eee2040d
SHONEN.md                                     MATCH   head=b44667ff4f0d disk=b44667ff4f0d
PROVINCE.md                                   MATCH   head=1932f0fd7103 disk=1932f0fd7103
SKILL.md                                      NEW     head=None         disk=1055a52f5704
corpus/fixtures                               tracked=146 differing=1 missing=0 untracked_outside_nm=0
     DIFFER    corpus/fixtures/phys3d_joints.gd          # licensed
corpus/knowledge/unreal-mcp/upstream          tracked= 12 differing=0 missing=0 untracked_outside_nm=0
corpus/knowledge/unreal-mcp/.manifest.d       tracked= 12 differing=0 missing=0 untracked_outside_nm=0
reports/round-101                             tracked= 33 differing=0 missing=0 untracked_outside_nm=0
reports/round-102                             tracked= 61 differing=0 missing=0 untracked_outside_nm=0
reports/round-103                             tracked= 61 differing=0 missing=0 untracked_outside_nm=0
```

**One `DIFFER` line in the entire protected set, and it is the licensed file.** The four root
protection files are byte-identical to HEAD. The pinned upstream subtree (12 blobs), the
manifest directory (12 blobs), and rounds 101/102/103 (33 + 61 + 61 blobs) are all
byte-identical with zero untracked additions inside them.

### 6.1 Two additions outside the protected set — named, not violations

- **`SKILL.md` (new, untracked, 174 lines, sha256 `1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c`).**
  `git rev-parse HEAD:SKILL.md` → *"fatal: path 'SKILL.md' exists on disk, but not in 'HEAD'"*,
  and `git log --all -- SKILL.md` is empty: the lane had no `SKILL.md` before r104, so this is a
  **new-file addition**, not a modification. It is the C3 target (§1 decision table) and is
  outside `corpus/fixtures/**`.
- **`corpus/knowledge/unreal-mcp/gate/run_gate.sh` (sha256 `e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08` at the last observation, `19:23:23Z`; +109/−14).**
  C2's declared scope; outside `corpus/fixtures/**`, so not a fixtures finding. **This file moved
  three times during this seat's window and is still moving**, so the sentinel treats it as
  point-in-time and quotes the hash it actually observed rather than a "final" one:
  `7404998e…` (+2/−2, comment-only) at `19:20:47Z` → `b6d8c61a…` (+97/−11) at `19:22:02Z` →
  `e5521304…` (+109/−14) at `19:23:23Z`. Every gate statement below is true of the hash named in
  the sentence; the authoritative close-time value is whatever `git hash-object
  corpus/knowledge/unreal-mcp/gate/run_gate.sh` returns after the last work seat stops.
  At the earliest frame `grep -c 'GATE_WORKDIR\|TMPDIR' run_gate.sh` was `0`; from the second
  frame on, the resilience layer is in the script itself:
  `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` (precedence `GATE_WORKDIR` > `TMPDIR` > `/tmp`),
  with the root validated up front (`not a directory` / `not writable` → `FAIL` + `exit 1`), and
  both scratch allocations rooted there and made loud on failure:
  `MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''` and
  `WORK=$(mktemp -d -p "$WORK_ROOT" 2>/dev/null) || WORK=''`.
  The exit-code contract is `0` PASS / `1` FAIL / `2` BLOCKED (`:429` `exit 2`, `:433`
  `[ "$FAILS" -eq 0 ] && exit 0 || exit 1`). Whether the C2 attack regression and the flake
  harness both pass against the final hash is C2's claim to make, not mine — I record only the
  observed script state and its sha.

  - **`corpus/knowledge/unreal-mcp/gate/README.md` (+115/−19, sha256 `e3bc66b7f5d981a1…`)**
  also changed in C2's scope: it re-pins the expected scanner values and adds the workdir rows
  (`+> correction note). The r104 scanner sha256 is `e5521304…` and the current pin is
  `POINTERS=103``; the expected-values line moves to `POINTERS=103 POINTER_STRINGS=41
  SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` re-measured `2026-10-18T19:24Z`). That `101 → 103`
  move is exactly the **scanner-relative datum** the r103 lesson records (`SKILL.md:70`): a bare
  `POINTERS` number is a measurement of one scanner on one tree, and the invariant to quote is
  `UNRESOLVED=0`. Not a fixtures finding; named for completeness.

  **One independent A/B of that fix, run by this seat at `19:23Z`–`19:26Z`** (the gate is a static
  checker over vendored bytes; this is not an Unreal runtime claim). Same tree, same script, only
  `GATE_WORKDIR` differing. Both halves were re-run against gate sha `e5521304…`:

  ```
  $ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
  WORK_ROOT=/tmp (from default)
  WORK_ROOT_FREE=3.1G of 16G (80% used)
  CHECK 2 BLOCKED (network)
  BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
  GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)      RC=2

  $ GATE_WORKDIR=$HOME/s08scratch/gatework bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
  WORK_ROOT=/home/vgpnk/s08scratch/gatework (from GATE_WORKDIR)
  WORK_ROOT_FREE=771G of 930G (16% used)
  GATE RESULT: PASS (checks failed: 0)                               RC=0
  ```

  Both runs print `POINTERS … POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`
  and `STEP=PASS` on checks 1/3/4; only CHECK 2 differs, and only because its scratch root moved
  off the quota-starved tmpfs. (The `POINTERS` count itself moved `101 → 103` between the r103
  scanner and this one — the scanner-relative datum `SKILL.md:70` warns about; `UNRESOLVED=0` is
  the invariant and it holds in both runs.) The `WORK_ROOT=… (from default|GATE_WORKDIR)` line is
  the new provenance the fix added — the earlier script did not say where its scratch went, which
  is why r103's failure was silent. **Caveat:** this does not prove the network is down; it proves
  the clone could not complete from `/tmp` while it completed from real disk, which is the exact
  distinction A4 was built to make visible.

## 7. Violations named

**None.** Specifically:

| check | result |
|---|---|
| any `corpus/fixtures/**` name other than `phys3d_joints.gd` changed | **no** — the name list has exactly one entry |
| `run_battery.py` changed without a design doc naming it | **no** — byte-identical to HEAD; no design doc exists |
| cannon / bullet / glTF fixture byte moved | **no** — all triple-identical (disk = HEAD = r102) |
| any seed digest other than `phys3d_joints.gd` moved | **no** — 1 of 130 differs |
| CASES row added / removed / edited | **no** — canonical sha identical |
| protected root file modified | **no** — 4/4 MATCH |
| pinned subtree / manifest / rounds 101-103 touched | **no** — 0 differing, 0 missing, 0 untracked |
| staged change or deletion | **no** — `git diff --cached --stat` empty |
| r103's `r90bt_*` seed-tree pollution recurring | **no** — `ls -d corpus/fixtures/r90bt_*` → 0 matches |

### 7.1 A different violation class, found by a sibling seat — cross-referenced, not adjudicated

`reports/round-104/git-hygiene.md` (SEAT-17) reports **5 violations of a class outside this seat's
scope**: undeclared multi-gigabyte scratch trees written *inside* the repo
(`reports/round-104/scratch/s20-skel3` peaked at 5.3 GB / 305,448 files and contained a nested
self-copy), a full lane clone `.r104-seat17/` at the repo root, and `trace.out`/`trace.err`. None
of those paths is under `corpus/fixtures/**` and none is a protected path, so they do not fall to
this seat. **The two audits agree on everything we both measured**: zero writes into any protected
tree, zero tracked modifications outside a declared seat path, and the same three authorized
non-clean entries (`phys3d_joints.gd`, `run_gate.sh`, new `SKILL.md`). SEAT-17 independently
reached this seat's headline finding — `run_battery.py` byte-identical, no design doc naming it,
only `phys3d_joints.gd` authorized — and confirms the r103 fixtures-write class did not recur.
The scratch-placement ruling is the L1's; I name it so the two reports are not read as one claim.

## 8. Corroborating C1 evidence (peer receipts, not this seat's runs)

Cited for the sentinel's context only — this seat ran none of them.

- **Baseline reproduces at HEAD** (`reports/round-104/physics/before.md` SEAT-02): two
  independent fresh-scratch runs, both `FAIL … TIMEOUT after 20 seconds`, `elapsed=20.024`.
- **After the patch, the row passes** (`reports/round-104/physics/author-runs/20261018T192031033448Z/verdicts.json`):
  `verdict=PASS`, `actual_exit=0`, `reasons=[]`, `elapsed=2.687` (was capped at 20.0),
  `seeds_unchanged=True`, `tree_probe_ok=True`, `case_timeout_seconds=20` **unchanged** — i.e.
  the fix works without touching the global bound.
- **The marker is unchanged by the rewrite.** The pinned literal (3921 chars,
  sha16 `706ad9151452e18d`) is present **byte-exact** as a stdout line in that receipt
  (`marker exact in stdout: True`), so R3 changed wall clock only, as its own comment claims.
- **All 8 `phys3d_joints` rows pass after the patch**
  (`author-runs-all/20261018T192041290482Z`: 8 cases, 0 fails, `seeds_unchanged=True`).
- **The full 350-case after-battery landed — this is C1's counting command**
  (`reports/round-104/physics/author-runs-full/20261018T192105574998Z/verdicts.json`):

  ```
  totals: cases=350 pass=337 fail=13 ordinary=291 negative_controls=59 probes=0
  seeds_unchanged=True   tree_probe_ok=True   crash_probe_ok=True   case_timeout_seconds=20
  free_ops: PASS  actual_exit=0  reasons=[]  elapsed=2.768
  FAILS: 13 — all `r94_cannon_*`, all `exit=0 … reasons=['exact stdout marker missing']`
  ```

  **Delta against the r102 receipt (`336 pass / 14 fail`):** the set difference is exactly one
  row in each direction —

  ```
  fixed by r104   : ['phys3d_joints_free_ops']
  newly red       : []
  ```

  So `336/350 → 337/350`, one row repaired, **zero regressions**, and the battery-level `FAIL`
  verdict is unchanged because the 13 surviving reds are the D3 node-token rows the r103 ledger
  explicitly separated from the physics row (§6 of that file). `case_timeout_seconds` is still
  **20** in the receipt, which is the machine-readable confirmation that the fix is in the fixture
  and not in the bound.
- **An earlier full-battery attempt was a casualty of the very defect C2 fixes.** Two runs were
  started: `reports/round-104/scratch/seat37-full/` (`19:20:34Z`) and the one above (`19:21Z`).
  The first redirected its stdout to `/tmp` and is truncated at exactly `4096` bytes with no
  `EXIT=` line (`/tmp/seat37-full.out`, 4096 B) — `/tmp` on this host is a 16G tmpfs under a
  per-user quota, which this seat independently confirmed at `19:22Z`: `df -h /tmp` → `3.1G avail`
  while `echo hi > /tmp/s08probe2` → **Disk quota exceeded**. The receipt above writes inside the
  lane and completed normally. That contrast is a live, independent reproduction of the r103
  root cause C2 exists to fix — which is why the C2 A/B in §6.1 matters.

## 9. Method, and what this seat did not do

- **Tools:** `~/s08scratch/sweep.py` (one read-only script: diff-stat, per-blob sweep,
  seed-map comparison, named-fixture table, AST CASES extract, scope checks) plus
  `git cat-file` / `git ls-files` invocations quoted inline. Nothing was written under
  `corpus/fixtures/**`; the only path this seat wrote is this file.
- **Why blob comparison and not `git diff --name-only` alone:** a name list shows *which* files
  moved but not whether a file was modified-and-restored, and it cannot see an addition inside
  an ignored-but-pinned directory. The per-blob sweep plus the explicit untracked walk close both.
- **Why AST and not `grep`/`import` for CASES:** `grep` cannot prove row identity (a reflowed
  table reads identically) and `import` would execute the runner mid-edit by a concurrent seat.
  `ast.literal_eval` is inert and fails loudly on a non-literal element.
- **Snapshot caveat.** This is a snapshot, not a lock. The C1 file was still being written when
  I began (`git diff --stat` moved 11/5 → 26/7 within ~4 s, landing at sha `c7e77638…`), and the
  gate surface moved repeatedly during the window (`7404998e…` → `b6d8c61a…` → `e5521304…`, plus
  `gate/README.md`, §6.1). **The fixtures claim did not move at all**: seven sweeps from
  `19:19:48Z` to `19:33:53Z` returned the same single name and the same 145/146 identity count.
  The authoritative close-time check is the two commands in §2 re-run after the last work seat
  stops.
- **Not done:** I did not run the 350-case battery (peer receipts in §8 stand in), did not
  evaluate the C1 physics result, did not run C2's attack regression or its flake harness, and did
  not review the C3 table's content. I did not write `LOG.md`, `SCORECARD.md`, `SHONEN.md`,
  `PROVINCE.md`, `SKILL.md`, or anything under `reports/round-101/**`, `reports/round-102/**`,
  `reports/round-103/**`, or the pinned Unreal subtree.
- **Scope boundary.** The `reports/round-104/scratch/**` placement violations SEAT-17 reports
  (§7.1) are outside this seat's mandate — this seat's subject is `corpus/fixtures/**` and the
  declared protected set. I neither adjudicate them nor rely on them.
