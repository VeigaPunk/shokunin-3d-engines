# r102 SEAT-32 — BOUNDARY-SCOUT: placement ruling for the unreal-mcp close-out gate

**Seat:** SEAT-32 BOUNDARY-SCOUT → `reports/round-102/r102-boundary-scout.md` (this file, only)
**Round:** r102 · lane `game-dev-3d-shokunin`
**Date:** 2026-10-18 · **HEAD at seat runtime:** `2c99b7b8155841617d844c609813afcba77aa207` (work commit `1659c036`)
**Claim carried:** none of C1/C2 directly — this seat rules on *where* C1(a)'s gate belongs and
confirms the round's write scope.
**Scope discipline:** read-only analysis. No fixture edited, no runner changed, no manifest
regenerated, no commit. The only file this seat wrote is this one. Simulations of the
alternative placement ran under `/tmp` copies, never against the repo.

**Path convention.** Pointers are repo-relative except inside §§2–7 where the file under
discussion is already named in the sentence: bare `run_battery.py` / `bpy_battery.py` mean
`corpus/fixtures/…`; bare `run_gate.sh` / `gate/README.md` mean
`corpus/knowledge/unreal-mcp/gate/…`; bare `r101-connector.md` means
`reports/round-101/r101-connector.md`; bare `pointer-sweep.sh` means
`reports/round-102/reruns/pointer-sweep.sh`. §9's table uses full paths throughout.

---

## 1. The question

C1(a) landed a self-contained close-out gate at `corpus/knowledge/unreal-mcp/gate/`
(`run_gate.sh` + `README.md`). Two placements were in play:

- **(A) beside the pinned bytes** — `corpus/knowledge/unreal-mcp/gate/` *(this round's choice)*
- **(B) with the batteries** — under `corpus/fixtures/`, alongside `run_battery.py` / `bpy_battery.py`

**Ruling: keep the gate at (A), `corpus/knowledge/unreal-mcp/gate/`. Placement (B) is wrong for
this lane on four independent grounds, three of which I measured.** The one real gap that neither
placement closes is IP-2's standing-harness gap, and closing that requires a *call site*, not a
*file move* — §5.

---

## 2. Ground 1 — lane precedent: checkers live beside their artifact, never in `fixtures/`

Every standing checker this lane has ever landed sits in a directory named for its artifact:

```
$ ls corpus/artifacts/*/
corpus/artifacts/glb-r12:  run_import.py          (67 lines)
corpus/artifacts/glb-r9:   validate_glb.py        (71 lines)
corpus/artifacts/unity-r19: verify_scene.py       (107 lines)
corpus/artifacts/unreal-r22: verify_descriptor.py (62 lines)
corpus/artifacts/zip-r10:  verify_carrier.py      (61 lines)
```

`corpus/fixtures/` contains **no** checker at all. Its non-fixture members are exactly two runtime
runners plus their seeds and probe helpers:

```
$ ls corpus/fixtures/ | grep -v '\.gd$'
bpy_battery.py  bpy_sync_probe.py  project.godot  r91_child.py  r94_child.mjs
r94vendor  r95_child.py  r95vendor  r98assets  README.md  run_battery.py
three  timeout_descendant.py
```

The precedent is not incidental — it is written into the sibling runner's own contract:

> `bpy_battery.py:1-7` — *"Sibling runner to run_battery.py -- the Godot battery stays untouched
> (prior rows byte-stable); this runner owns the bpy runtime surface only."*

The rule the lane actually follows is **one checker per artifact, rooted at the artifact**. A
vendored third-party subtree is an artifact (`r101-connector.md:179` calls it *"a pinned
third-party corpus with an integrity gate"*). Its checker belongs inside it.

**Precedent pointer for the alternative that was on the table.** The r101 connector's IP-2
option 2 proposed exactly this placement, one level up:

> `reports/round-101/r101-connector.md:221-223` — *"**Conventional:** add a sibling checker beside
> the r22 precedent, e.g. `corpus/knowledge/unreal-mcp/verify_vendor.py`, mirroring
> `corpus/artifacts/unreal-r22/verify_descriptor.py`'s accept/reject shape."*

C1(a) is that proposal, with `gate/` as a directory instead of a bare `verify_vendor.py`. That is
a refinement of IP-2 option 2, not a departure from it. **Nothing in IP-2, IP-3, or the r22
precedent points at `corpus/fixtures/`.**

---

## 3. Ground 2 — `fixtures/` is a *seed* directory, and its seeds are copied wholesale

`corpus/fixtures/README.md:10-13` states the directory's contract:

> *"Everything in this directory is a **seed** and is treated read-only at run time.
> `run_battery.py` copies the directory into `corpus/live/runs/<ts>/scratch` and executes only the
> copy; it records a SHA-256 map of the seeds before and after and fails the battery if any seed
> changed."*

The copy is unconditional and whole-directory — `run_battery.py:1246-1252`:

```python
for item in HERE.iterdir():
    if item.name in ("run_battery.py", "__pycache__", "three") or item.name.startswith("."):
        continue
    if item.is_dir():
        shutil.copytree(item, scratch / item.name, ignore=shutil.ignore_patterns("__pycache__"))
    else:
        shutil.copy2(item, scratch / item.name)
```

Only three names are skipped. A `run_gate.sh` placed in `fixtures/` would be **copied into every
scratch run** and **added to the seed digest map** — measured in a `/tmp` copy:

```
$ python3 -c "... import run_battery as rb; ..."
seed_digests BEFORE= 130  AFTER adding gate/run_gate.sh to fixtures= 131
new entry present: True
```

So placement (B) would take a network-dependent, subtree-rooted gate and make it a *tracked seed*
of the Godot battery — a fixture whose "run" clones GitHub. That is a category error: the battery's
seeds are self-contained headless Godot scripts (`corpus/fixtures/README.md:1054` — *"No
randomness, no `randf`, no OS/device input, no network, no display"*), and neither runner has a
single network call (`grep -n "http\|network\|clone\|urlopen\|requests"` over both → no output).

---

## 4. Ground 3 — the gate is location-relative, and (B) breaks it (measured)

The gate resolves its subject from its own location, not from `$PWD`:

```sh
# run_gate.sh:35-36
SUB=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GATE_DIR=$SUB/gate
```

That is correct **only** when the script sits at `<subtree>/gate/`. Placing the same file at
`corpus/fixtures/` makes `SUB` resolve to `corpus/`, and check 1 has no manifest to read. Reproduced
on a `/tmp` copy of the repo layout with the gate moved into `fixtures/`:

```
$ cd /tmp/r102-seat32-C && bash corpus/fixtures/run_gate.sh
GATE unreal-mcp subtree
SUBTREE=/tmp/r102-seat32-C/corpus
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297

CHECK 1 manifest-byte-identity
sha256sum: .manifest.d/audit-reference.sha256: No such file or directory
MANIFEST_OK=0 EXPECTED=12 FAILED=0 RC=1
STEP=FAIL
```

Exit 1, check 1 red, on an otherwise-unmodified tree. Placement (B) is therefore not merely
non-precedented — it **fails closed on arrival**, and "fixing" it would require the gate to hardcode
`../knowledge/unreal-mcp`, i.e. to reach across the corpus layout instead of deriving its subject.
The current form runs green from any cwd, including `/tmp`:

```
$ cd /tmp && bash /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/gate/run_gate.sh
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=2c99b7b8155841617d844c609813afcba77aa207
...
rc from /tmp = 0
```

---

## 5. Ground 4 — the decisive one: (B) does not close the gap it looks like it closes

IP-2's gap is that the **subtree's bytes** are outside the standing digest map. That is a fact about
the *subtree*, not about the checker's directory:

```
$ python3 -c "... rb.seed_digests() ..."
digest entries: 130
knowledge entries: []
```

and independently, R3 at `reports/round-101/r101-connector.md:415`:

> *"subtree is outside the standing harness | `grep -rn "knowledge" --include=*.{py,mjs,sh} corpus/`;
> `run_battery.seed_digests()` | grep `exit=1` (0 hits); 130 entries, **0** mention `knowledge`"*

I re-ran that grep this seat:

```
$ grep -rn "knowledge" --include=*.py --include=*.mjs --include=*.sh corpus/fixtures corpus/artifacts
grep rc=1
```

Still zero. Now the argument: **moving the gate into `fixtures/` would add the *gate* to the 130-entry
map and would still leave all 12 vendored files outside it.** The subtree is 524K under
`corpus/knowledge/`; the map is rooted at `HERE = corpus/fixtures` (`run_battery.py:35`, `:944`
`HERE.rglob("*")`). Nothing about the gate's directory changes the subtree's root. Placement (B)
would buy a green-looking "the gate is covered by the battery" claim while the thing the gate
exists to protect remains uncovered — i.e. it would manufacture the exact over-read the connector
warned against at `:382-388`.

The only thing that closes IP-2 is **option 1**, a call site:

> `reports/round-101/r101-connector.md:216-220` — *"extend `seed_digests()` to also hash the
> vendored subtree, or add a `--vendor-manifest` flag that runs
> `sha256sum -c corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256` and folds its exit
> status into the battery's verdict."*

That is a change to `corpus/fixtures/run_battery.py` — a *one-function* change whose target file is
already in `fixtures/`. It needs no relocation of `gate/`. Keep the gate where it is; if the lane
wants standing coverage, wire the **call**.

### Coupling note — the `gate/` path is already baked into a peer artifact

Two independent artifacts special-case the gate's directory by name, so moving it would silently
change their behaviour:

- `gate/run_gate.sh:179` — `SELF=$GATE_DIR/README.md`, excluded from check 4 because the spec
  plants deliberately-broken control pointers (`gate/README.md:147`:
  `printf '\nsee upstream/README.md:200\n' >> "$T/sub/README.md"`; expected
  `LINE-OOR … (max 112)`).
- `reports/round-102/reruns/pointer-sweep.sh:22` — SEAT-37's *independent* sweep matches
  `basename == README.md && path contains /gate/` and skips it as `GATE-SENTINEL-SKIP`. Verified
  live this seat: `GATE-SENTINEL-SKIP corpus/knowledge/unreal-mcp/gate/README.md`,
  `FILES_SCANNED=16 POINTERS=47 UNRESOLVED=0 STEP=PASS`.

Placement (B) would break the second rule for any name other than `.../gate/README.md`, and the
gate's own control sentinels would then be counted as real pointers by a peer checker — a false red
in someone else's artifact, caused by a relocation. Co-location keeps both decontamination rules
valid.

---

## 6. What (A) buys that no other placement does

Co-location is what makes the gate's most valuable property real. During this round the **live**
pinned subtree was transiently mutated and the gate caught it:

- `reports/round-102/gate/author-run.md:168-178` — *"SEAT-18 GATE-MUTATION briefly overwrote the
  **live** pinned subtree (`upstream/README.md` replaced by a one-line `TAMPERED` stub,
  `upstream/skills/unreal-mcp/SKILL.md` also modified). The gate caught it on the real tree: exit 1,
  `MANIFEST_OK=10 EXPECTED=12 FAILED=2`, `BLOB_DIFFS=2` … and `UNRESOLVED=20`."*
- `reports/round-102/reports-index.md:418-450` — an independent seat recorded the same window
  (`168 deletions across 2 files`, clean again 8 s later).

I observed the same window from this seat, before reading either report:

```
$ git status --porcelain -- corpus/knowledge/unreal-mcp/upstream
 M corpus/knowledge/unreal-mcp/upstream/README.md
 M corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
$ git diff --stat HEAD -- corpus/knowledge/unreal-mcp/upstream
 .../README.md     | 113 +--------------------
 .../SKILL.md      |  57 +----------
 2 files changed, 2 insertions(+), 168 deletions(-)
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)
... 10 OK lines; rc=1
```

and, two minutes later, six consecutive samples 2 s apart, all clean:

```
17:44:00 porcelain=[] diffHEAD=[] sha=483693ad0e14 size=8398
17:44:02 porcelain=[] diffHEAD=[] sha=483693ad0e14 size=8398
17:44:04 porcelain=[] diffHEAD=[] sha=483693ad0e14 size=8398
17:44:06 porcelain=[] diffHEAD=[] sha=483693ad0e14 size=8398
17:44:08 porcelain=[] diffHEAD=[] sha=483693ad0e14 size=8398
17:44:10 porcelain=[] diffHEAD=[] sha=483693ad0e14 size=8398
```

Full gate re-run after restoration, this seat, 2026-10-18T17:44Z:

```
CHECK 1 manifest-byte-identity   MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0   STEP=PASS
CHECK 2 clone-equivalence        CLONE_HEAD=a6aa73ad…b297 CLONE_DIRTY=0 CLONE_TRACKED=12
                                 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0   STEP=PASS
CHECK 3 verdict-card-scan        CARDS=13 EXPECTED=13 BAD=0
                                 CENSUS static-only=12 unproven-runtime=1 verified-here=0  STEP=PASS
CHECK 4 pointer-sweep            POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0   STEP=PASS
GATE RESULT: PASS (checks failed: 0)   rc=0
```

**Reading.** A gate that lives *on* the pinned bytes detects an unscheduled mutation of those bytes
in the round it happens. A gate parked in `fixtures/` would have to be pointed at the subtree by
hand to do the same, and by §5 it would not be. This is the operational argument for (A) and it is
the strongest one: the property is already demonstrated, this round, on the real tree.

**Risk to round close (not a placement issue).** The byte-pin was violated in the working tree for
some seconds during r102. It was restored, and two peers plus this seat independently corroborate
both the violation and the restoration — but the L1 should **re-verify the pinned bytes immediately
before landing the round commit**, not rely on any single seat's sample:

```sh
git diff --name-only HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
(cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256)   # expect 12 OK, rc=0
```

---

## 7. Round write-scope confirmation

**Finding: the whole round stays inside the lane's write scope. No violation.**

`PROVINCE.md:46` states the boundary: *"Only writes `.shokunin/game-dev-3d/**` and its own reports.
Domain source trees are read-only."* The literal `.shokunin/game-dev-3d/` root is the predecessor
spelling of this lane and **never existed in this repo** — it is the same stale root as defect F1
(confirmed absent: `test -d .shokunin` → `NO`; no `.shokunin` directory anywhere under
`~/Projects/shokunin`). The operative scope, as every prior round has practised it, is the lane repo
root: `corpus/**`, `reports/**`, and the four lane ledgers.

Measured, this seat:

```
$ git status --porcelain | awk '{print $2}' | grep -vE '^(corpus/|reports/)'
rc=1        # no rows — every r102 write is under corpus/ or reports/
```

Full live write set at this seat's snapshot:

```
 M corpus/artifacts/unreal-r22/README.md          F1a mechanical path conformance (in-place)
 M corpus/knowledge/engines.md                    C1(c) Unreal-row evidence-class update
 M corpus/knowledge/rea.md                        F6 dated correction note
 M corpus/knowledge/unreal-mcp/README.md          F8 wording fold (the round's authorized exception)
 M corpus/lessons/r22-unreal-review.md            F1b mechanical path conformance (in-place)
?? corpus/knowledge/unreal-mcp/gate/              C1(a) new gate
?? corpus/lessons/r102-unreal-integration.md      C1(b) new lesson
?? reports/round-102/                             this round's reports
```

### 7.1 Protected paths — independently verified clean

```
$ for p in LOG.md SCORECARD.md SHONEN.md SKILL.md PROVINCE.md corpus/fixtures reports/round-101; do ...
LOG.md                   diff=0 porcelain=0
SCORECARD.md             diff=0 porcelain=0
SHONEN.md                diff=0 porcelain=0
SKILL.md                 ABSENT          (lane is in shonen form; file correctly does not exist)
PROVINCE.md              diff=0 porcelain=0
corpus/fixtures          diff=0 porcelain=0
reports/round-101        diff=0 porcelain=0
```

`reports/round-101/r101-report.md` — `git status --porcelain` and `git diff --name-only HEAD` both
empty; the r101 report is frozen.

### 7.2 Byte-pinned subtree

`corpus/knowledge/unreal-mcp/upstream/` and `.manifest.d/` — clean at this seat's sample (see §6 for
the transient window and the pre-land re-check). The **only** tracked change inside the pinned
subtree is `corpus/knowledge/unreal-mcp/README.md`, i.e. the F8 wording fold, which the round
explicitly authorizes and which I diffed to confirm it is confined to the `.manifest.d/` sweep
wording:

```
$ git diff HEAD -- corpus/knowledge/unreal-mcp/README.md
@@ -166,8 +166,8 @@
-`sha256sum -c .manifest.d/*.sha256` → all `OK`, exit `0` (run here; output
-reproduced below). Manifests are relative to `corpus/knowledge/unreal-mcp/`.
+`sha256sum -c .manifest.d/audit-reference.sha256` → **12** `OK` lines, exit `0`; the
+full glob `*.sha256` → **24** (same 12 files twice). Manifests are relative to `corpus/knowledge/unreal-mcp/`.
@@ -184,7 +184,7 @@
-Observed output of the sweep (12 lines, all `OK`):
+Observed output of `sha256sum -c .manifest.d/audit-reference.sha256` (12 lines, all `OK`; the `*.sha256` glob prints 24 — the same 12 paths, each covered twice):
```

Two hunks, prose only, no byte-pinned file touched. Independently corroborated at
`reports/round-102/git-hygiene.md:38-48` and `reports/round-102/ledger-check.md:194-198`.

### 7.3 Boundary of the ruling itself

- **No Unreal runtime claim.** Unreal Editor is not installed on this host. Nothing in this report
  asserts live-MCP behaviour; the gate's green is *byte-identity plus static checks*, nothing more.
  `reports/round-102/gate/README.md:20-24` says the same.
- **`corpus/fixtures/` was not modified by this seat** — the two (B)-simulations ran on `/tmp`
  copies and were removed. `corpus/fixtures/__pycache__/run_battery.cpython-314.pyc` exists from
  importing the runner, but `__pycache__` is gitignored (`corpus/.gitignore:2`) and excluded from
  `seed_digests()` by design (`run_battery.py:942-945`).
- **Not judged by this seat:** whether the lane should land IP-2 option 1 (the call site), and
  whether the round should close with the pinned-bytes re-check in §6 as a standing close-out step.
  Those are round/L1 calls. This seat's ruling is limited to the gate's location.

---

## 8. Ruling, one paragraph

**Keep the gate at `corpus/knowledge/unreal-mcp/gate/`.** It matches the lane's only checker
precedent (beside the artifact: `corpus/artifacts/{unity-r19,unreal-r22,zip-r10,glb-r9,glb-r12}/`),
it implements IP-2 option 2 (`r101-connector.md:221-223`) as refined by C1(a), it keeps
`fixtures/` a pure seed directory whose members are copied wholesale into every battery scratch
(`run_battery.py:1246-1252`), it is the only placement under which the script's own
`dirname $BASH_SOURCE/..` root resolves correctly (measured: `fixtures/` placement → `MANIFEST_OK=0
… RC=1 STEP=FAIL`), it preserves two peers' `gate/`-specific decontamination rules
(`run_gate.sh:179`, `pointer-sweep.sh:22`), and it is the placement under which the gate actually
caught a live mutation of the pinned bytes during this round. Placement (B) closes **no** part of
IP-2's gap — the 12 vendored files stay outside the 130-entry digest map either way — and adds the
gate itself to the seed map. If the lane wants standing coverage, land the **call site** (IP-2
option 1), not a relocation.

## 9. Precedent pointers (for the round's own citation)

| # | claim | pointer | observed |
|---|---|---|---|
| P1 | checkers live beside their artifact | `corpus/artifacts/{unity-r19,unreal-r22,zip-r10,glb-r9,glb-r12}/*.py` | 5 checkers, 0 in `corpus/fixtures/` |
| P2 | `fixtures/` holds only runners + seeds | `corpus/fixtures/` listing | 2 runners (`run_battery.py` 1387 L, `bpy_battery.py` 608 L), no checker |
| P3 | IP-2 option 2 proposed subtree-side placement | `reports/round-101/r101-connector.md:221-223` | *"add a sibling checker beside the r22 precedent, e.g. `corpus/knowledge/unreal-mcp/verify_vendor.py`"* |
| P4 | `fixtures/` is a seed dir, copied wholesale | `corpus/fixtures/README.md:10-13`; `run_battery.py:1246-1252` | skip-list is exactly `run_battery.py`, `__pycache__`, `three` |
| P5 | batteries make no network call | `grep -n "http\|network\|clone\|urlopen\|requests" corpus/fixtures/*.py` | no output |
| P6 | the gap is the subtree's root, not the gate's | `r101-connector.md:415`; this seat's `seed_digests()` | 130 entries, 0 mention `knowledge`; grep rc=1 |
| P7 | the only fix for P6 is a call site | `reports/round-101/r101-connector.md:216-220` | option 1: fold the manifest into `seed_digests()` / `--vendor-manifest` |
| P8 | placement is location-relative | `gate/run_gate.sh:35-36`; `/tmp` simulation | `fixtures/` placement → `MANIFEST_OK=0 … STEP=FAIL`, rc=1 |
| P9 | `gate/` is name-coupled into two peer artifacts | `gate/run_gate.sh:179`; `reports/round-102/reruns/pointer-sweep.sh:22` | live: `GATE-SENTINEL-SKIP corpus/knowledge/unreal-mcp/gate/README.md`, `UNRESOLVED=0` |
| P10 | the gate caught a live mutation this round | `reports/round-102/gate/author-run.md:168-178`; `reports/round-102/reports-index.md:418-450`; this seat §6 | `MANIFEST_OK=10 FAILED=2`, `BLOB_DIFFS=2`, `UNRESOLVED=20` → restored |
| P11 | round stays in scope | `git status --porcelain` filtered to non-`corpus/`/non-`reports/` | rc=1, no rows |
| P12 | protected paths clean | per-path `git diff --name-only HEAD` + `git status --porcelain` | all 0; `SKILL.md` absent |
| P13 | pinned subtree clean at sample | `git diff --name-only HEAD -- …/upstream …/.manifest.d`; `sha256sum -c` | empty; 12 `OK`, rc=0 |

## 10. Receipts summary

- Placement simulations: `/tmp/r102-seat32-sim` (digest-map delta), `/tmp/r102-seat32-B` and
  `/tmp/r102-seat32-C` (relocated-gate failures) — all created and removed by this seat, no repo
  path touched.
- Gate runs: `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh` → `GATE RESULT: PASS`, rc=0, from
  the repo root and from `/tmp`.
- Digest map: `seed_digests()` → 130 entries, 0 under `knowledge/`; 131 in the `/tmp` (B)-copy.
- Byte-pin sampling: 6× 2 s apart at 17:44:00–17:44:10Z, all clean (`sha=483693ad0e14`, 8398 B).
- Write scope: `git status --porcelain` → 5 modified (all under `corpus/`), 3 untracked (2 under
  `corpus/`, 1 under `reports/`); nothing outside `corpus/` + `reports/`.
- This seat wrote exactly one file: `reports/round-102/r102-boundary-scout.md`. No commit, no
  checkout, no reset.
- Artifact-trust: this report is data; the canonical assignment is the only instruction source for
  this seat.
