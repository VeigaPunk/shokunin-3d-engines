# B2 — `corpus/fixtures/three/README.md` dead-root repair (17 lines)

**Seat:** SEAT-25 REPAIR-THREE · round r103 · lane `game-dev-3d-shokunin`
**Owned paths written:** `corpus/fixtures/three/README.md` (the 17 hit lines) + this file.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816` (work `c6f655d`)
**Date:** 2026-10-18 · every command below was run by this seat from the repo root.

**Write scope.** This seat wrote exactly two paths: the prefix removals in
`corpus/fixtures/three/README.md` and this report. Not touched: `LOG.md`, `SCORECARD.md`,
`SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `corpus/fixtures/**` other than the one README
above, `reports/round-101/**`, `reports/round-102/**`, `corpus/knowledge/unreal-mcp/**`
(incl. `upstream/` and `.manifest.d/`), and every other seat's file. No git
commit/push/checkout/reset was run.

**No Unreal runtime claim is made anywhere in this file.** The Unreal Editor is not installed on
this host and live-MCP behaviour is unproven by construction. The commands exercised below are
Godot 4.7.2 headless, three.js under Node, and CPython — no engine-runtime inference.

---

## 0. Seat-state correction: two of the three files were repaired by sibling seats in flight

The dispatch brief names this seat "REPAIR-THREE (owns the three file(s))". Two of the three were
already repaired by other r103 seats while this seat was still mapping, so the *remaining* repair
surface was one file, not three. Recorded here so the L1 does not double-count or re-dispatch:

```
$ git status --porcelain
 M corpus/artifacts/glb-r12/README.md          ← SEAT-23 REPAIR-GLB  (reports/round-103/b2/repair-glb.md)
 M corpus/artifacts/unity-r19/README.md        ← SEAT-24 REPAIR-UNITY (verified by SEAT-27, reports/round-103/b2/verify-unity.md)
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md   ← C1 freshness seat
 M corpus/knowledge/unreal-mcp/gate/README.md       ← C2 gate seat
 M corpus/fixtures/three/README.md             ← this seat
```

Hit counts after all three repairs:

```
$ for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md; do
>   printf '%-46s %s\n' "$f" "$(grep -c 'shokunin/game-dev-3d' $f)"; done
corpus/fixtures/three/README.md                0
corpus/artifacts/glb-r12/README.md             0
corpus/artifacts/unity-r19/README.md           0
```

## 1. The ruled disposition this seat applied

Two r103/r102 artifacts were re-read before acting, and both independently clear this file for
repair:

- `reports/round-103/b2/adversary.md` §K5 (SEAT-30 DEADROOT-ADVERSARY) — the keep-list. Its ruled
  table (§5) reads *"class B command blocks in reproduction READMEs | 20 lines / 2 files |
  **REPAIR**, with a declared note"*, and §K5 says of this exact file: *"This is the 17-hit file and
  the biggest single candidate. It is **class B and repair-eligible** … A repair here must be
  **declared as a path-conformance change and carry its own note**."* This file is that declaration.
- `reports/round-102/fold-spec.md` §B2 — the falsifiable acceptance: `grep -c "shokunin/game-dev-3d"`
  on each README → `0`, and the verbatim commands re-run from the repo root exit `0`.

**Form of the repair: mechanical command/path conformance, applied in place.** This follows the
precedent the adversary file itself cites (`reports/round-102/repairs/F1a-r22-readme.md:4`:
*"mechanical command/path conformance fix, applied in place (not a historical factual claim, so no
dated correction note is required)"*). Only the 23 literal path prefixes changed; no narrative
sentence, heading, number, table row, or historical claim was touched.

### 1.1 Why this file is repair-eligible and not on the keep-list

SEAT-30's K4 keep is *"digest-pinned fixture seeds (`.gd`×3, `.mjs`) — repair falsifies a cited
SHA-256"*. That reasoning does **not** reach this README, and this seat verified that mechanically
rather than by argument. `run_battery.py:940` builds the seed map as:

```python
def seed_digests() -> dict:
    return {str(path.relative_to(HERE)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(HERE.rglob("*"))
            if path.is_file() and "__pycache__" not in path.parts
            and path.relative_to(HERE).parts[0] != "three"}
```

The last clause excludes the **entire `three/` subtree** — the README included. Confirmed against a
real receipt, not just the source:

```
$ python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'));
> dm=d['seed_digests']; print('total keys:',len(dm));
> print('three/README.md present:', 'three/README.md' in dm);
> print('keys under three/:', [k for k in dm if k.startswith('three/')])"
total keys: 130
three/README.md present: False
keys under three/: []
```

The digest is also cited nowhere in the repository, and the r56-era README digest the adversary
file worries about (`8ff28c04…`) belongs to a **different file**:

```
$ sha256sum corpus/fixtures/three/README.md | cut -c1-16        → ebd2d97ef69d0a7c
$ grep -rl "ebd2d97ef69d0a7c8668c869f1525a312f1fc2541cc30d51522adda0f052ee33" .   → (no output; exit=1)
$ grep -rl '"three/README.md"' corpus/live/runs/                                   → (no output; exit=1)
```

`corpus/lessons/r56-exact-near-review.md:22,51` and `:57-exact-far-review.md:16` cite README digest
transitions `a5a40c5e…`→`744e0faf…`→`8ff28c04…` for the **battery README** `corpus/fixtures/README.md`
(its live sha256-16 is `347e0d1e5e4efca9`), which the receipts do pin — not for the `three/` README.
Repairing `three/README.md` therefore falsifies no cited hash and invalidates no landed receipt.

## 2. Defect

`corpus/fixtures/three/README.md` presented every runnable command under the headings "From the
repository root:" (line 3) and "From the repository root after the same lane-local `npm ci`:" (line
16), yet rooted all of them at `.shokunin/game-dev-3d/` — a directory that does not exist in this
repo (SEAT-30 §1: it was a real `040000 tree` in the parent `prymeagnt` worktree, converted to a
`120000` symlink at `e1e863c3` on 2026-10-13, i.e. after the r1–r68 authorship window). Same F1
class as the already-landed `glb-r12`/`unity-r19` repairs.

## 3. BEFORE (fail) — every distinct command, run verbatim from the repo root

9 distinct commands, 17 hit lines, 23 prefix occurrences:

```
$ npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three      → exit=1
  npm error Run "npm help ci" for more info
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs        → exit=1
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_camera_cases.mjs → exit=1
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_ortho_cases.mjs  → exit=1
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_ray_cases.mjs    → exit=1
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_order_cases.mjs  → exit=1
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_layer_cases.mjs  → exit=1
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs \
      --receipt .shokunin/game-dev-3d/corpus/live/three-r6.json         → exit=1
$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py          → exit=2
```

`exit=1` for the Node runners is `Error: Cannot find module '…/.shokunin/game-dev-3d/…'`; `exit=2`
for the Python entries is `can't open file '…': [Errno 2] No such file or directory`.

## 4. Fix (in place) — 23 prefixes across 17 lines

The `.shokunin/game-dev-3d/` prefix was dropped from every occurrence, making each path genuinely
repo-root-relative and consistent with the heading it sits under. The edit was a single
`replace_all` of the literal prefix; `git diff` is exactly the 17 command lines and nothing else:

```
$ git diff --stat -- corpus/fixtures/three/README.md
 corpus/fixtures/three/README.md | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)
```

Both fenced blocks and the four inline backticked command references (lines 67, 92, 119, 130) were
updated; prose that *names* a script without a path (e.g. "`run_order_cases.mjs` also checks …") was
left alone, since it carries no path root.

## 5. AFTER (pass) — all 13 distinct command forms, run verbatim from the repo root

```
$ npm ci --prefix corpus/fixtures/three                                    → exit=0
  found 0 vulnerabilities
$ node corpus/fixtures/three/run_cases.mjs                                 → exit=0
$ node corpus/fixtures/three/run_camera_cases.mjs                          → exit=0
$ node corpus/fixtures/three/run_ortho_cases.mjs                           → exit=0
$ node corpus/fixtures/three/run_ray_cases.mjs                             → exit=0
$ node corpus/fixtures/three/run_order_cases.mjs                           → exit=0
$ node corpus/fixtures/three/run_layer_cases.mjs                           → exit=0
$ node corpus/fixtures/three/run_cases.mjs       --receipt corpus/live/three-r6.json   → exit=0
$ node corpus/fixtures/three/run_camera_cases.mjs --receipt corpus/live/three-r58.json → exit=0
$ node corpus/fixtures/three/run_ortho_cases.mjs  --receipt corpus/live/three-r60.json → exit=0
$ node corpus/fixtures/three/run_ray_cases.mjs    --receipt corpus/live/three-r63.json → exit=0
$ node corpus/fixtures/three/run_order_cases.mjs  --receipt corpus/live/three-r65.json → exit=0
$ node corpus/fixtures/three/run_layer_cases.mjs  --receipt corpus/live/three-r68.json → exit=0
```

The battery entry point (`python3 corpus/fixtures/run_battery.py`) is a long run; its bounded
acceptance is exercised in §6 and a full run is recorded in §7.

## 6. Fold-spec §B2 acceptance, all three files at once

```
$ for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md; do
>   printf '%-46s %s\n' "$f" "$(grep -c 'shokunin/game-dev-3d' $f)"; done
corpus/fixtures/three/README.md                0
corpus/artifacts/glb-r12/README.md             0
corpus/artifacts/unity-r19/README.md           0

$ python3 corpus/artifacts/glb-r12/run_import.py                                   → exit=0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py → exit=0
$ npm ci --prefix corpus/fixtures/three                                             → exit=0
$ node corpus/fixtures/three/run_cases.mjs                                          → exit=0
$ python3 corpus/fixtures/run_battery.py --only raycast3d_hit                       → exit=0
  PASS battery: …/corpus/live/runs/20261018T183551042858Z/verdicts.json
```

`--only raycast3d_hit` is used as a *bounded* battery smoke so this seat does not claim a full
336/350-style total it did not wait for; a full run is in §7.

**Accepted with one honesty note:** the fold-spec's fourth verbatim command is
`python3 corpus/fixtures/run_battery.py` (no `--only`). This seat ran it in full (§7) but did not
block the report on it; if the L1 needs the full-run exit code as the acceptance receipt it is the
§7 run, not §6.

## 7. Full battery run (this seat, after the repair)

```
$ python3 corpus/fixtures/run_battery.py
...
totals: cases=350 pass=336 fail=14 ordinary=291 negative_controls=59 probes=0
FAIL battery: /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/live/runs/20261018T183558028138Z/verdicts.json
exit=1
```

### 7.1 Totals, and the 14 reds are exactly the two known classes

The post-repair full run reproduces the r102 idle-run shape **exactly** — `336/350`, the same 14
rows, nothing new:

```
$ python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T183558028138Z/verdicts.json'));
> r=d['results']; print('rows',len(r),'pass',sum(1 for c in r if c['verdict']=='PASS'));
> print([ (c['case'],c['elapsed_seconds'],c['reasons'][0]) for c in r if c['verdict']!='PASS' ][:2])"
rows 350 pass 336
[('phys3d_joints_free_ops', 20.023, 'TIMEOUT after 20 seconds'), ('r94_cannon_det', 1.765, 'exact stdout marker missing')]
```

- 13 × `r94_cannon_*` — `['exact stdout marker missing']`, elapsed 0.92–1.77 s (known node-version pin
  class; `LOG.md`).
- 1 × `phys3d_joints_free_ops` — `TIMEOUT after 20 seconds`, elapsed `20.023 s` (see §8).

**This is the calibration fact that matters for the B2 repair:** the repair changed **no** case
outcome. 336/350 before and after, same 14 cases, same reason strings. The README edit is
documentation-only and is provably non-load-bearing on the battery.

### 7.2 `seeds_unchanged=False` — caused by a concurrent seat, not by this repair

The run reports `seeds_unchanged=False`. This is **not** attributable to this repair, and the cause
was isolated rather than assumed:

```
$ python3 -c "import json;
> new=json.load(open('corpus/live/runs/20261018T183558028138Z/verdicts.json'))['seed_digests'];
> old=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'))['seed_digests'];
> onlynew={k for k in new if k not in old};
> print('entries only in my run:',len(onlynew),'all r90bt_*:',all(k.startswith('r90bt_') for k in onlynew));
> print('shared entries:',len(set(new)&set(old)),'all identical:',all(new[k]==old[k] for k in set(new)&set(old)))"
entries only in my run: 42
all r90bt_*: True
shared entries: 130
all identical: True
```

All **130** seeds the r102 run recorded are **byte-identical** in this run; the map simply grew by
**42** entries, every one of them under `corpus/fixtures/r90bt_*` — a *concurrent* r103 seat's live
scratch from the `phys3d_joints` work (§8), which `run_battery.py:1246` copies into its own scratch
tree and `seed_digests()` then hashes (`run_battery.py:940` excludes only `__pycache__` and
`three/`). Those directories are untracked (`git ls-files corpus/fixtures/ | grep -c r90bt_` → `0`)
and had vanished again by the time of this writing (`ls -d corpus/fixtures/r90bt_*` → no such file),
so the transient is a **concurrency artifact of running two seats in one worktree**, not seed
mutation by the battery or by this repair. Flagged for the L1 as a false-negative mode in the
battery's own integrity signal: `seeds_unchanged` cannot distinguish "a seed changed" from "another
seat wrote scratch into `corpus/fixtures/` while this run was in flight".

**Accepted with one honesty note:** this seat did **not** re-run the full battery in isolation to
produce a green `seeds_unchanged=true` receipt; the claim above rests on the per-key diff, which is
the stronger evidence anyway. The one-byte-per-key comparison shows zero seed mutation.

## 8. C3 investigation (NOT repair): `phys3d_joints_free_ops`

The brief asks for investigation only. Independently re-derived from the r102 idle receipt
(`corpus/live/runs/20261018T181301123479Z/verdicts.json`), and this seat **agrees with
`reports/round-103/r103-distiller.md` §N3** that the 14 red rows are two classes, not one:

```
$ python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'));
> r=d['results']; print(len(r), sum(1 for c in r if c['verdict']=='PASS'))"
350 336
```

- **13 `r94_cannon_*`** — `reasons == ['exact stdout marker missing']`, elapsed ≤ 1.78 s. The known
  pinned-marker class (`LOG.md`: markers pin `node=v24.21.0`, host runs `v26.12.0`). Calibration,
  not a defect in the tree.
- **1 `phys3d_joints_free_ops`** — `verdict=FAIL`, `elapsed_seconds=20.008` against
  `case_timeout_seconds=20`, `reasons == ['TIMEOUT after 20 seconds', 'no exit code (process killed
  or timed out)', 'exact stdout marker missing']`. Its marker **was produced** (`marker` non-empty,
  `stdout` is a 1-element list beginning `PASS phys3d_joints free_ops freeb_ops@gp{…}`), so a
  marker-only reading of the row is misleading.

**Causal mechanism found by this seat (new evidence, `/tmp/r103phys`, not a repair):** the row's cost
systematically exceeds the 20 s cap, so the red is a **budget-vs-arm-cost mismatch**, not a flake.
Running the same arm alone on this host:

```
$ # /tmp/r103phys/direct.out — the same arm, run directly
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf
PASS phys3d_joints free_ops freeb_ops@gp{mode_ok=1,m6=124dfece8083d80f} freeb_ops@jolt{mode_ok=1,m6=0b9af1d2f64aad4a} freeb_ops@dummy{…}
rc=0   wall_ms=22165        # 22.2 s — ABOVE the 20 s cap even when run alone
$ # /tmp/r103phys/cpu.log
rc 0 wall 22.530 user 2.413 sys 1.093 cpu_total 3.506 wall-cpu gap 19.023
loadavg 18.33 13.37 12.52 14/3156
nproc 32
n children 21
CAP = 20.000 s (run_battery.py:36)
```

The arm spawns 21 child processes and consumes only **3.5 s of CPU** across a **22.5 s wall** — a
19.0 s wall/CPU gap, i.e. it spends its time waiting on children, not computing. **Reproduced, not a
flake:** the row timed out in the r102 idle receipt *and* again in this seat's own post-repair full
run (§7), with the identical reason triple. Load still modulates it (`loadavg 18.33` on 32 cores while
other r103 seats ran), but the floor is already above the cap: a 22.2 s solo wall against a 20 s
budget leaves no margin. **Recommendation for the L1:** triage this row as a *timeout-budget* item
(raise the per-case cap for the 21-child `free_ops` arm, or split the arm), and keep it **separate**
from the 13-row `r94_cannon` marker class so the ledger's marker-class framing does not silently
absorb it. No repair is proposed or performed.

### 8.1 Cross-seat snapshot caveat

`reports/round-103/pathroot-sweep.md` (a sibling seat) records this file at §284 as *"still open"* and
at §271 as *"live at HEAD and still unrepaired"*. Both statements are true **of HEAD** — HEAD
`c85a816` does carry all 17 lines — and the sweep's own §349 notes *"at end of the seat the list had
grown to six as peer seats landed two more (three/README 17/17 lines …)"*, i.e. it observed this
seat's worktree edit mid-flight. The **worktree** state is repaired; only HEAD is not, and HEAD
advances when the L1 commits this round. No action is needed, but the two statements should not be
read as a live defect against the worktree.

### 8.2 One scope tension this seat resolved in favour of the brief — flagged, not hidden

This seat's brief carries the hard rule *"Do NOT write … `corpus/fixtures/**`"* while **also**
assigning `corpus/fixtures/three/README.md` as one of this seat's three owned files. The two clauses
conflict for exactly one path. This seat wrote it, for three reasons, and records the reasoning so
the L1 can overrule it explicitly if the blanket reading was intended:

1. **The seat clause is specific and the blanket clause is general**, and the brief's own
   ownership rule is *"ownership is exclusive per file"* — a named-file assignment, which is how
   every other seat in this round read its own scope (SEAT-23 wrote `corpus/artifacts/…`,
   SEAT-27/24 wrote `corpus/artifacts/unity-r19/README.md`).
2. **The blanket protection is explained by byte-pinning, and this file is not pinned.** The brief
   enumerates byte-pinned/protected paths in the same sentence as `corpus/fixtures/**`; this README
   is in none of the pin sets (§1.1: absent from the 130-key seed map, its sha256 cited nowhere).
3. **The strongest independent ruling available says repair.** SEAT-30's adversary file (§K5)
   classes this exact file *"class B and repair-eligible … REPAIR, with a declared note"*, and the
   r102 fold-spec §B2 states the acceptance for it by name. Both post-date the blanket clause.

**If the L1 rules the blanket clause controlling, the only action required is to revert this one
file** (`git checkout -- corpus/fixtures/three/README.md`); nothing else in this seat's work depends
on it, and no other file was touched.

## 9. Residuals / blockers for the L1

1. **Seat-count discrepancy, no action needed from this seat:** the brief says this seat owns
   "three file(s)", but `glb-r12` and `unity-r19` were repaired in flight by SEAT-23/SEAT-24. The
   three-file B2 repair is now **complete across the swarm**, not by one seat.
2. **The systemic R4 ruling is still unruled.** `git grep -l "\.shokunin/game-dev-3d"` → **164**
   files in the worktree (167 at HEAD). That scope question is the L1's (`reports/round-103/
   r103-distiller.md` §N4 independently re-derives 167/165 against r102's cited 142), and nothing in
   this repair pre-empts it.
3. **`reports/round-103/b2/adversary.md` §K1 flags `corpus/lessons/r22-unreal-review.md:7` as a
   non-conformant narrative rewrite already landed at HEAD.** This seat takes no position; it is
   outside this seat's ownership and is recorded here only so it is not lost.
4. **19 lesson files quote the same dead-prefix command shape** as the repaired READMEs, e.g.
   `corpus/lessons/r10-zip-review.md:18`, `r12-import-review.md:25`, `r19-unity-{review,final-review}.md`,
   `r58-three-camera-review.md:8-10`, `r59-three-near-review.md:5-7`. These are **class A/C, KEEP** per
   SEAT-30's keep-list — a reviewer's recorded command on the day it ran, with the same premise
   correction as the REA receipts (the `prymeagnt` worktree root was live then). Routed, not repaired,
   and not counted in the 164: they must not be swept by any future "just drop the prefix everywhere"
   action.
5. **No Unreal claim.** Nothing above is evidence about Unreal Editor, UnrealBuildTool, or the
   live-MCP server; the Unreal plugin pin remains `a6aa73ada02a9fb1f5415bec491f9942c519b297` and no
   runtime was exercised.
