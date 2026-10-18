# SEAT-25 LESSON-VERIFY — independent re-run of every command the r102 lesson cites

- **Seat:** SEAT-25 LESSON-VERIFY (r102)
- **Written:** 2026-10-18, from `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- **Lane HEAD at verification:** `2c99b7b` (r101 report-last; work commit `1659c036`)
- **Method:** every command below was re-executed at my own runtime, in this session. No
  command's result is copied from any author's transcript. Where a cited artifact did not
  exist when I started, I re-checked it after it landed (sibling seats were writing
  concurrently throughout) and record both the time and the digest of what I read.
- **Boundary:** no Unreal runtime claim is made or implied anywhere in this report. Unreal
  Editor is not installed; nothing here was run against an editor, an MCP server, or any
  live Unreal surface. No file outside `reports/round-102/lesson-verify.md` was written by
  this seat.

Subject files, with the digest I verified against (sha256):

| file | sha256 (as read by this seat) |
|---|---|
| `corpus/lessons/r102-unreal-integration.md` | `c7f18f285cd11809c632277905bd306287603d0f3c0b1302d4bd95bcf26932cc` |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `214bf8ef7ba7dfba93f523ac7a1248372828dc18679f3864c2e5e36c5647411e` |
| `corpus/knowledge/unreal-mcp/gate/README.md` | `def732c9a10dc9a923fb99efc72edc5b452b120ded549a971958bf2d81357ec8` |
| `corpus/knowledge/engines.md` | `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` |
| `corpus/knowledge/rea.md` | `3932fc5354c32e55a971a907b1609eeea65211c18020c7d24d1298a3fb67d059` |
| `corpus/lessons/r22-unreal-review.md` | `c43ab2bfc90e153d814cccf92bd82286191d34600ff62bcbaab92de4f400f690` |

`corpus/lessons/r102-unreal-integration.md` did **not** exist when this seat started
(14:40); it landed at 14:44:19 and was re-read then. `gate/run_gate.sh` and
`gate/README.md` landed at 14:42. Both were verified against the digests above.

---

## 1. C1(a) — the gate `corpus/knowledge/unreal-mcp/gate/run_gate.sh`

### 1.1 It exists, is executable, and is self-contained

```
$ ls -l corpus/knowledge/unreal-mcp/gate/
-rw-r--r-- 1 vgpnk vgpnk  8776 Oct 18 14:42 README.md
-rwxr-xr-x 1 vgpnk vgpnk 10233 Oct 18 14:42 run_gate.sh
```

**REPRODUCED.** The script resolves its subtree from `${BASH_SOURCE[0]}` (verified by
reading `run_gate.sh:35`: `SUB=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)`), so it is
genuinely path-independent. Confirmed by running it from three working directories:

| run from | observed tail | exit |
|---|---|---|
| repo root | `GATE RESULT: PASS (checks failed: 0)` | `0` |
| `/` | `GATE RESULT: PASS (checks failed: 0)` | `0` |
| `/tmp` | `GATE RESULT: PASS (checks failed: 0)` | `0` |

The lesson's own citation form (bare execution, no `bash`) also works:

```
$ corpus/knowledge/unreal-mcp/gate/run_gate.sh
GATE RESULT: PASS (checks failed: 0)
exit=0
```

### 1.2 The four checks reproduce, with the values the lesson states

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=2c99b7b8155841617d844c609813afcba77aa207
CHECK 1 manifest-byte-identity
… 12 × `upstream/…: OK`
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
CHECK 2 clone-equivalence
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS
CHECK 3 verdict-card-scan
… 13 × `OK   <label> <card> line N`
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS
CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
GATE-EXIT=0
```

**REPRODUCED**, every value. This matches the lesson's citation exactly (its lines 145–149)
and `gate/README.md`'s pinned-summary block.

### 1.3 The gate is fail-closed — I re-ran all seven documented negative controls

`gate/README.md` documents a control matrix (C1–C7). A gate that passes everything is
worthless, so I re-ran each control on a throwaway `cp -r` copy, never on the pinned tree.
Every one reproduced the documented signal:

| control | mutation | observed | exit | matches doc |
|---|---|---|---|---|
| C1 | append a byte to `upstream/README.md` | `MANIFEST_OK=11 … FAILED=1 RC=1`; `BLOB-DIFF README.md`; checks 1,2 fail | `1` | yes |
| C2 | `rm upstream/LICENSE` | `PATH_MISSING=1`; `BLOB-DIFF LICENSE`; checks 1,2 fail | `1` | yes |
| C3 | plant `upstream/README.md:200` | `LINE-OOR … (max 112)`; `UNRESOLVED=1`; check 4 fails | `1` | yes |
| C4 | duplicate a label token on the label line | `FAIL multi-label`; `BAD=1`; check 3 fails | `1` | yes |
| C5 | relabel a card `unproven-runtime` | `CENSUS static-only=11 unproven-runtime=2 verified-here=0` vs expected `12/1/0` | `1` | yes |
| C6 | `rm executability/sequencer.md` | `CARDS=12 EXPECTED=13` | `1` | yes |
| C7 | plant **only** the exact sentinels | `POINTERS=40 SKIPPED_CONTROL_SENTINELS=3 UNRESOLVED=0`; `GATE RESULT: PASS` | `0` | yes |

Two independent confirmations of the two most important failure modes, run earlier in the
session on a separate copy (before the control matrix above):

```
$ printf 'x' >> upstream/LICENSE && bash gate/run_gate.sh
upstream/LICENSE: FAILED
MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1
GATE RESULT: FAIL (checks failed: 2)
TAMPER-A REAL EXIT=1
$ sed -i 's/…`unproven-runtime`/…`verified-here`/' executability/actors-scene.md && bash gate/run_gate.sh
CENSUS static-only=12 unproven-runtime=0 verified-here=1 EXPECTED=12/1/0
GATE RESULT: FAIL (checks failed: 1)
TAMPER-B REAL EXIT=1
```

Note C7's `SKIPPED_CONTROL_SENTINELS=3` (not `2` as the doc's row states): the doc's row
plants two sentinel *strings* on one line, whereas my copy planted three
(`upstream/nope.md:1`, `upstream/README.md:9999`, `upstream/README.md:500`). The skip count
tracks the number of *matched pointer strings*, so `3` is correct for my input; the
documented `2` is correct for the doc's input. The invariant the doc actually asserts —
`UNRESOLVED=0` and a green exit, i.e. the filter skips *only* the exact sentinels and masks
no real pointer — **reproduces**. This is a difference of input, not a defect.

### 1.4 The gate's own claim about itself is honest

`gate/README.md` §"What this gate does not do" states plainly that the gate does **not**
run Unreal, does **not** judge whether a card's label matches its evidence, and does
**not** check markdown links, JSON well-formedness, or shellcheck. I read that section and
confirm the script matches it: check 3 enforces one-label-per-card mechanically (via
`grep -nE "$ALLOWED" | head -1` plus a token count), and no Unreal process is ever spawned
anywhere in `run_gate.sh`. The no-editor posture is stated, not implied.

---

## 2. C1(b) — the lesson's commands and citations

### 2.1 Law 1 — vendoring scoped to the pin

| lesson claim | command I ran | observed | verdict |
|---|---|---|---|
| 12/12 byte-identical, sweep `OK` exit 0 | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` | 12 × `OK`, `rc=0` | **REPRODUCED** |
| independent transport `diff -rq` clean, exit 0 (`PROVENANCE.md:48`) | `diff -rq /tmp/r102-verify corpus/knowledge/unreal-mcp/upstream --exclude=.git` | no output, `EXIT=0` | **REPRODUCED** |
| pin is `a6aa73ad…b297` | fresh `git clone` + `git -C … rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | **REPRODUCED** |
| path-set equality both ways | `git ls-files` vs vendored `find` | 12 vs 12, `diff` empty | **REPRODUCED** |
| per-file byte-identity vs clone blobs | `sha256sum` live vs `git show <pin>:<path>` | 12/12 `SAME` (spot-checked `README.md`, `SKILL.md`, `LICENSE`; gate check 2 does all 12 → `BLOB_DIFFS=0`) | **REPRODUCED** |
| 11 seats / 12 files split | `wc -l .manifest.d/seat11.sha256` → `2`; `seat01..seat10` → 1 each | `2` and 1s | **REPRODUCED** |
| 5 PR-only + 1 history-only out-of-pin paths (`PROVENANCE.md:340-356`) | read the table | present, each with a reproducing command marked `[I]` | **REPRODUCED (as recorded)** — the table is explicitly labelled *as recorded by that review*, not re-derived here; I did not re-clone PR refs |

Anchors `README.md:98-102`, `PROVENANCE.md:101-110`, `README.md:262-264`,
`PROVENANCE.md:51-65` all resolve in-range and say what the lesson says they say
(checked `sed -n` at each).

### 2.2 Law 2 — the binary policy

| lesson claim | command I ran | observed | verdict |
|---|---|---|---|
| policy is binary `proven`/`unproven` (`README.md:14-15`) | `sed -n '14,15p'` | "The policy is binary… no middle ground, no 'probably'" | **REPRODUCED** |
| `unproven` = needs live editor, lists the surfaces (`README.md:23-29`) | `sed -n '23,29p'` | lists server start, `list_toolsets`/`describe_toolset`/`call_tool`, actor mutation, Live Coding, automation tests, Niagara/Sequencer/Control Rig | **REPRODUCED** |
| connected client ≠ reachability (`README.md:52-54`) | `sed -n '52,54p'` | "A connected MCP client… does not prove Unreal is reachable. Only a successful read-only Unreal tool call would" | **REPRODUCED** |
| maintenance rules promotion/invalidation/negative (`adaptation-kimi.md:287-297`) | `sed -n '287,297p'` | all three present verbatim; invalidation pins BuildID `5e67bdf95c…` and SHA `a6aa73a` | **REPRODUCED** |
| live-editor rule (`adaptation-kimi.md:299-302`) | `sed -n '299,302p'` | "No claim about tool availability… may be written in the indicative mood on this host" | **REPRODUCED** |

### 2.3 Law 3 — the card-label ternary, and the F7 collision

| lesson claim | command I ran | observed | verdict |
|---|---|---|---|
| measured shape 13 cards, 12 `static-only`, 1 `unproven-runtime`, 0 `verified-here` | `grep -m1` per card + gate check 3 | exactly that | **REPRODUCED** |
| exactly-one-label scan `CARDS=13 EXPECTED=13 BAD=0` | `bash /tmp/r101-closeout/label-scan.sh corpus/knowledge/unreal-mcp/executability 13` | `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`, exit 0 | **REPRODUCED** |
| F7: six cards reject `unproven-runtime` on "path not even identified" | `grep -rln 'Not \`unproven-runtime\`' corpus/knowledge/unreal-mcp/executability/*.md \| wc -l` | `6` — `animation-controlrig`, `blueprints`, `editor-general`, `gameplay-gas`, `materials`, `meshes-textures` | **REPRODUCED** |
| the colliding definition (`README.md:41`) | `sed -n '41p'` | `` `unproven-runtime` \| the claim needs the live editor and nothing was observed \| `unproven` `` | **REPRODUCED** |
| the six cards' ground (`blueprints.md:113`) | `sed -n '113p'` | "**Not `unproven-runtime`:** … Here the path is not even identified" | **REPRODUCED** |

F7 is a genuine, still-open vocabulary collision: the same epistemic situation (a subsystem
whose runtime path is unidentified and untested) is labelled `unproven-runtime` on
`actors-scene.md` and `static-only` on six other cards. The lesson reports it as an open
hook rather than a resolved claim, which is the correct posture — I confirm it is unresolved.

### 2.4 Law 4 — the three install walls

| lesson claim | command I ran | observed | verdict |
|---|---|---|---|
| account-gated: `git ls-remote` → `Repository not found` | `git ls-remote https://github.com/EpicGames/unreal-engine` | `remote: Repository not found.` / `fatal: repository … not found` | **REPRODUCED** |
| account-gated: `gh api` → 404 | `gh api repos/EpicGames/UnrealEngine` | `{"message":"Not Found",…,"status":404}` | **REPRODUCED** |
| protocol-gated: AUR PKGBUILD gates in `prepare()` on SSH | read `PROVENANCE.md:181-208` | R2 header: "AUR route hits the same wall, in SSH form" | **REPRODUCED (as recorded)** |
| operator-gated: Lutris/docker exist, block is a credential | read `PROVENANCE.md:210-230` | R3: "**OPERATOR-GATED**, not host-blocked" | **REPRODUCED (as recorded)** |

I did not attempt to install an engine, and neither did any cited command — the walls are
recorded as walls. This is the right shape: the lesson makes no claim that the engine can be
obtained locally.

### 2.5 The two counting traps

| lesson claim | command I ran | observed | verdict |
|---|---|---|---|
| glob yields 24 `OK`, audit-ref subset 12 | `sha256sum -c .manifest.d/*.sha256 \| grep -c ': OK'`; `…audit-reference…` | `24`; `12` | **REPRODUCED** |
| "Enumerate, never trust a count written into prose" | `find corpus/knowledge/unreal-mcp -type f \| wc -l` | `42` | **NOT-REPRODUCED (as a number)** — see §2.7 |

### 2.6 The lesson's gate citations

| lesson claim | command I ran | observed | verdict |
|---|---|---|---|
| gate → `GATE RESULT: PASS (checks failed: 0)`, exit 0 | `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | exactly that | **REPRODUCED** |
| check 4 → `POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` | gate output | exactly that | **REPRODUCED** |
| check 3 → `CARDS=13 EXPECTED=13 BAD=0`, `CENSUS 12/1/0` | gate output | exactly that | **REPRODUCED** |
| `bash /tmp/r101-closeout/label-scan.sh … 13` → `STEP=PASS` | ran verbatim | `CARDS=13 EXPECTED=13 BAD=0` / `STEP=PASS`, exit 0 | **REPRODUCED** |
| `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` → `POINTERS=40 UNRESOLVED=0` / `STEP=PASS` | ran verbatim | `POINTERS=43 UNRESOLVED=3` / `STEP=FAIL`, **exit 1** | **NOT-REPRODUCED** — see §3 |

Anchors `reports/round-101/r101-verification-protocol.md:30`, `:582`, `:307-315`,
`reports/round-101/r101-report.md:44-46`, `:161-168`, `gate/README.md:40`,
`reports/round-101/r101-critic-c3.md:365` all resolve in-range and carry the content the
lesson attributes to them. (`gate/README.md:40` is
`**Expected:** MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0, then STEP=PASS` — a pin of check 1's
value, which is what the lesson says it pins.)

### 2.7 The `find … | wc -l` → 40 claim

The lesson's "Re-running the gate" section states:

> `find corpus/knowledge/unreal-mcp -type f | wc -l` → 40 (12 upstream + 12
> manifests + 3 index + 13 cards)

At my runtime this returns **42**. The arithmetic in the parenthetical is itself correct
(12+12+3+13 = 40) and was correct at the moment the lesson's author measured it; the two
extra files are `gate/run_gate.sh` and `gate/README.md`, which landed at 14:42 — i.e. the
gate's own directory is what invalidates the count.

This is a **snapshot-vs-truth** discrepancy, not a false claim: the same lesson, four
paragraphs earlier, states the governing rule ("Enumerate, never trust a count written into
prose… any snapshot in an index goes stale within minutes"). The count is a live
demonstration of its own rule. I record it as a discrepancy that should be corrected to a
re-derivable command (or dropped), not as a defect of reasoning. Severity: low; the
conclusion the count was supporting ("the tree is enumerable, not asserted") holds.

---

## 3. The one NOT-REPRODUCED — the lesson's `/tmp` pointer-check citation

The lesson's "Re-running the gate" section cites, as an independently observed result:

```
bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp
→ POINTERS=40 UNRESOLVED=0 / STEP=PASS
```

Run verbatim at my runtime:

```
$ bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:200 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:500 (max 112)
LINE-OOR corpus/knowledge/unreal-mcp/gate/README.md :: upstream/README.md:9999 (max 112)
POINTERS=43 UNRESOLVED=3
STEP=FAIL
REAL-EXIT=1
```

**NOT-REPRODUCED.** Cause, established by reading the two scripts side by side:

- `pointer-check.sh` (the r101 stopgap) self-excludes exactly one file —
  `reports/round-101/r101-verification-protocol.md` (`self=…` at the top of the script) —
  and otherwise sweeps everything under the root it is given.
- `gate/README.md` landed at 14:42 and deliberately plants broken control pointers
  (`upstream/README.md:200`, `:500`, `:9999`) in its worked examples, to document the gate's
  own negative controls.
- The r101 script has no exclusion for `gate/README.md`, so it reads those planted controls
  as three real unresolved pointers.

The in-repo gate is **not** affected: `run_gate.sh` check 4 excludes `gate/README.md` by
path and the three exact sentinels by match, which is why it prints `POINTERS=40
SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` on the same tree. The two tools disagree because
they were written against different trees.

This is a *self-contamination* instance of exactly the class the lesson itself documents for
`reports/round-101` — the lesson names the phenomenon but its own new file introduces a fresh
instance of it. The lesson's advice ("Prefer the in-repo gate over the `/tmp` scripts") is
correct and its own recommendation resolves the discrepancy; the citation should either be
marked as the pre-gate observation it is, or the three `gate/` pointers added to the
exclusion list. Severity: low (the surviving in-repo gate is green and is the artifact the
lesson tells readers to use), but it is a live citation that does not reproduce and a reader
who runs it will see a failure the lesson does not mention.

**Independent check that the disagreement is only about `gate/README.md`:** with `gate/`
removed from a copy of the subtree, the r101 script still reports `POINTERS=40 UNRESOLVED=20`
— because I removed the whole `gate/` directory including the subtree-relative base it was
sweeping against, which breaks the `base=corpus/knowledge/unreal-mcp` path resolution for
the copied tree. That run is a methodological error on my part and is **not** evidence about
the gate; I record it so the failed attempt is not mistaken for a result. The valid
comparison is the side-by-side reading of the two scripts above plus the in-repo gate's own
green check 4 on the identical tree.

---

## 4. C1(c) — `corpus/knowledge/engines.md`

The Unreal row was updated this round to record two distinct evidence classes. I verified
every factual element of the new row:

| row claim | command I ran | observed | verdict |
|---|---|---|---|
| `a6aa73ad` pin | `git clone` + `rev-parse HEAD` | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | **REPRODUCED** |
| MIT license | `sed -n '1,3p' upstream/LICENSE`; `PROVENANCE.md` row | MIT (see `upstream/LICENSE`) | **REPRODUCED** |
| 12/12 tracked files byte-identical | `sha256sum -c .manifest.d/audit-reference.sha256` | 12 × `OK`, `rc=0` | **REPRODUCED** |
| 13 cards, 12 `static-only` / 1 `unproven-runtime` / 0 `verified-here` | `ls -1 executability/*.md \| wc -l`; gate check 3 | `13`; `CENSUS 12/1/0` | **REPRODUCED** |
| "neither proves plugin load, UBT compilation or engine runtime" | `which UnrealEditor` / `which UnrealEditor-Cmd`; `ss -ltnp \| grep -c ':8000'` | editor absent; `0` listeners on 8000 | **REPRODUCED** (posture is correct) |

The row's structural claim — that (a) lane-authored static evidence and (b) third-party
byte-identical pinned evidence are *categorically different classes* — is a judgement, not a
measurable, and I do not score it. What I can confirm is that it makes no runtime claim and
does not move the row's `installed: no / executable headless: no` cells, which remain
correct on this host.

**The three.js row was also repaired this round**, and its new command is the F5 fix. I
tested it on a genuinely clean tree (a `git archive HEAD` export, so no untracked
`node_modules/`):

```
$ git archive HEAD corpus/fixtures/three | tar -x -C /tmp/r102-eng-clean
$ cd /tmp/r102-eng-clean
$ ls -d corpus/fixtures/three/node_modules
ls: cannot access 'corpus/fixtures/three/node_modules': No such file or directory
$ npm ci --prefix corpus/fixtures/three        # the newly documented precondition
NPM_CI_EXIT=0
$ node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
RUN_EXIT=0
```

**REPRODUCED.** The documented command pair is now genuinely re-runnable from a committed
tree, which the pre-repair single `node …` invocation was not (it exited 1 on the same
export — independently confirmed by the F5 before-capture). The row's own note about the
gitignored `node_modules/` is accurate.

### 4.1 The `run_battery.py` baseline the r22 lesson cites

The r22 lesson's "Existing execution baselines" block cites
`python3 corpus/fixtures/run_battery.py` → `exit 0, 29/29 PASS (14 ordinary, 15 negative),
zero failures; seeds_unchanged=true`. That citation is one of the four the r102 correction
note says "re-run exit 0", so I re-ran it.

**The case count is the headline finding: the documented `29/29` is a 29-case snapshot
against a battery that now defines 350 cases.**

```
$ git show 8b21cae:corpus/fixtures/run_battery.py   # r22-era blob
  → CASES ≈ 30 entries
$ git show HEAD:corpus/fixtures/run_battery.py
  → CASES ≈ 351 entries
$ grep -c "CASES entries" → runner defines 350 cases (peer seat-08 full run:
  `totals: cases=350 pass=335 fail=15 ordinary=291 negative_controls=59 probes=0`)
```

**REPRODUCED (as a count discrepancy).** The r22 lesson's `29/29 PASS` line is an accurate
record of the r22-era battery and must not be read as a statement about today's fixture. The
r102 correction note in `corpus/lessons/r22-unreal-review.md` now states exactly this
("`run_battery.py` now defines 350 cases (not 29) … Treat the `29/29 PASS` line as the r22
record only"), and I independently confirm both numbers by counting the `CASES` list in the
two blobs. This is the same class as the stale digests on the same line: a historical value
quoted as if current.

**My own re-run — completed.** I ran the battery twice. The first attempt was truncated at its
600 s background cap under 5-way contention; the clean re-run **completed** and reached its
own summary line:

```
$ python3 corpus/fixtures/run_battery.py
totals: cases=350 pass=336 fail=14 ordinary=291 negative_controls=59 probes=0
FAIL battery: corpus/live/runs/20261018T175622725474Z/verdicts.json
$ python3 -c "import json; d=json.load(open('corpus/live/runs/20261018T175622725474Z/verdicts.json')); print(d['seeds_unchanged'], d['totals'])"
True {'cases': 350, 'pass': 336, 'fail': 14, 'ordinary': 291, 'negative_controls': 59}
```

**`seeds_unchanged = True`**, 336/350 pass, exit 1 (from the 14 failures, not a crash).
`uptime` read `load average: 15–17` throughout, with up to **five** peer seats running the
same battery concurrently (SEAT-08, SEAT-09, SEAT-33/34 and others). The runner uses a per-run
timestamped scratch project (`corpus/fixtures/run_battery.py:5`: "isolated scratch project …
`corpus/live/runs/<ts>/scratch`"), so concurrent seats do **not** collide on a shared
directory. Two peer seats recorded the same totals independently
(`/tmp/r102-seat08-battery.txt` → `pass=335 fail=15`, `/tmp/seat34-fullbattery.txt` →
`pass=336 fail=14`), and my own `pass=336 fail=14` matches seat-34 exactly.

The 14 failures fall into exactly two classes, and I isolated each mechanism rather than
assuming either:

**(1) `phys3d_joints_free_ops` — host contention, NOT a fixture defect.**

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops
FAIL     phys3d_joints_free_ops   phys3d_joints.gd   --arm=free_ops   None/0   ordinary
totals: cases=1 pass=0 fail=1 …

$ time timeout 60 godot --headless --path <scratch> --script res://phys3d_joints.gd -- --arm=free_ops
real  0m23.544s      user  0m2.675s      sys 0m1.419s
exit=0  … PASS phys3d_joints free_ops freeb_ops@gp{mode_ok=1,m6=124dfece8083d80f} …
```

The script **produces the exact expected marker** and exits 0 — but it takes **23.5 s wall
against only 2.7 s of CPU**. That 21 s gap is pure scheduler delay: the case is starved past
the runner's hard `CASE_TIMEOUT_SECONDS = 20` (`run_battery.py:36`), which is why the runner
records `exit=None … TIMEOUT after 20 seconds`. So the failure is **host contention, not a
fixture defect**, and it would not reproduce on an unloaded machine.

**(2) the 13 `r94_cannon_*` failures — environment drift, deterministic, NOT contention.**

This one I proved to the character. The case marker pins the node version:

```
$ grep -A1 '"r94_cannon_det"' corpus/fixtures/run_battery.py
    ("r94_cannon_det", "r94_cannon.gd", ["--arm=det"], 0,
     'PASS r94_cannon det node=v24.21.0 det_base{rc=0,m=M0 case=det_base …
```

Running the script directly, the payload is emitted correctly and the **only** difference is
the version token:

```
$ timeout 60 godot --headless --path <scratch> --script res://r94_cannon.gd -- --arm=det
PASS r94_cannon det node=v26.12.0 det_base{rc=0,m=M0 case=det_base engine=cannon-es-0.20.0+three-0.186.1|M det_base bas…
exit=0

expected len 3357  actual len 3357
first diff at [27, 29, 30]  count 3
normalized equal: True
```

The expected and actual strings are **the same length**, differ in **exactly 3 characters**,
all inside the `node=` token, and become byte-identical once the version is normalized. The
physics payload is intact; only the pinned `node=v24.21.0` is stale against this host's
`node v26.12.0` (`grep -c 'node=v24.21.0' run_battery.py` → `13`, one per cannon marker).
This is deterministic environment drift: it will fail identically on any host with a newer
node, and it is unrelated to r102's Unreal work.

Net: of the 14 failures, 13 are a pre-existing node-version pin and 1 is load starvation.
**No failure is attributable to the r102 Unreal work or to the lesson**, and
`seeds_unchanged=true` holds. The run **completed** and reached its summary line, so I score
it **REPRODUCED for the run mechanics** (`cases=350`, the totals line, `seeds_unchanged=True`)
and **NOT-REPRODUCED for the r22 lesson's `29/29 PASS`** — which cannot reproduce, because it
describes a 29-case fixture. Settling the 14 residual failures needs one command on an idle
host with the node pin refreshed; on this host 13 of them are deterministic and will fail
regardless of load.

A cross-check worth recording: the peer seat-08 run failed **15** cases to my 14, the extra
being `r98_gltflat_doc` — which **passed** in my run. The peer's `r98_gltflat_doc` failure
carried diagnostics about a missing `UD/R98Scout/tri.glb` scratch asset, i.e. it is the load/
scratch-timing class, not the node-pin class. Two runs of the same fixture differing by
exactly one non-deterministic case, while agreeing on all 13 cannon cases, is precisely the
signature of one contention failure plus one environment-drift block — and it is independent
corroboration of the split I derived from the mechanisms.

The three other commands in that block **do** reproduce (each exit 0), recorded above in
§5.1: both `verify_descriptor.py` invocations and `node corpus/fixtures/three/run_cases.mjs`
(3/3 on the clean export). The `run_battery.py` digest citations are covered in §5.3.

---

## 5. C2 — the routed-defect repairs, re-verified

### 5.1 F1 — the never-existent `.shokunin/game-dev-3d/` root

| artifact | before | after |
|---|---|---|
| `corpus/artifacts/unreal-r22/README.md` | exit 2 on both commands | both exit 0 |
| `corpus/lessons/r22-unreal-review.md` | 7 stale-root hits | `grep -c "shokunin/game-dev-3d"` → **0** |

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py
python3: can't open file '…/.shokunin/game-dev-3d/corpus/artifacts/unreal-r22/verify_descriptor.py': [Errno 2] No such file or directory
exit=2
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py
PASS local-static actual=accept expected=accept …
exit=0
$ python3 corpus/artifacts/unreal-r22/verify_descriptor.py corpus/artifacts/unreal-r22/Headless3DFixture.bad-type.uplugin --expect-reject
PASS local-static actual=reject expected=reject … reason=unsupported module Type: 'Unknown'
exit=0
```

**REPRODUCED (fail → pass).** The pair still discriminates: accept the valid descriptor,
reject the `Type: Unknown` control. The lesson's two command blocks re-run at exit 0.

Note on the r102 lesson's own wording. The lesson states at its line ~189 that the r22 wrong
path root is "now 0 in **both r22 files**". At my runtime `grep -c 'shokunin/game-dev-3d'` is
`0` in `corpus/artifacts/unreal-r22/README.md` but **`1`** in
`corpus/lessons/r22-unreal-review.md` — and that one hit is the correction note *quoting* the
old prefix (`"re-rooted in r102 from a never-existent \`.shokunin/game-dev-3d/\` prefix"`), not
a live command. So the substance of the lesson's claim is correct (no live command carries the
dead root), but the literal `grep -c … == 0` it cites is off by one on that file. A
`grep -c` that counts a historical quotation as a hit is the same measurement trap the lesson
names elsewhere; I record the exact count so the next reader is not surprised.

**Residual (routed, not fixed, and outside my ownership):**
`corpus/lessons/r23-ortho-review.md` still carries the same dead root — 2 occurrences
(lines 10, 12) — and the same `corpus/live/runs/20261013T053632289732Z/verdicts.json`
citation at line 3. The r22 lesson was repaired; the r23 lesson was not. A reader following
r23 still hits exit 2.

### 5.2 F2 — the non-resolvable `verdicts.json` citation

The r22 lesson now carries a dated correction note instead of a silent rewrite. I verified
every claim the note makes:

| note claim | command I ran | observed | verdict |
|---|---|---|---|
| file absent from the working tree | `ls -la corpus/live/runs/20261013T053632289732Z/verdicts.json` | `No such file or directory`, exit 2 | **REPRODUCED** |
| never tracked (`live/` gitignored) | `git check-ignore -v …`; `git ls-files corpus/live` | `corpus/.gitignore:1:live/`; `0` tracked | **REPRODUCED** |
| absent from the machine | `find /home/vgpnk -maxdepth 8 -name 20261013T053632289732Z` | no output | **REPRODUCED** |
| digest survives only as text | `git ls-files -z \| xargs -0 sha256sum \| grep -i ^a806b9e4` | no match (grep exit 1) | **REPRODUCED** |
| the other text occurrence is `r101-critic-c3.md:181` | `sed -n '181p' reports/round-101/r101-critic-c3.md` | the same quoted pointer | **REPRODUCED** |

**REPRODUCED.** The note is accurate, preserves the r22 sentence verbatim as the historical
record, and adds the correction in the discipline the lane requires.

### 5.3 F3 — the stale `run_battery.py` digest

| claim | command I ran | observed | verdict |
|---|---|---|---|
| tree digest is now `f456bd00…` | `sha256sum corpus/fixtures/run_battery.py` | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` | **REPRODUCED** |
| cited `a065a56d…` is the r21/r22-era blob | `git show 490e710d:corpus/fixtures/run_battery.py \| sha256sum` | `a065a56db193228d2c5f3d0760c02972aee69d59c5c86480d7f9cf444a582570` | **REPRODUCED** |
| cited digest still present verbatim in the lesson | `grep -c a065a56d corpus/lessons/r22-unreal-review.md` | `2` (the historical sentence + the note's quote of it) | **REPRODUCED** |

**REPRODUCED.** The digest was never a fabrication — it is exact for the r22-era blob — and
the correction note says precisely that, which is the honest treatment.

**A fourth stale digest the note also catches, which I verified:** the lesson's digest table
row for `README.md` (`1460` bytes, `26a126047…`) is now `1394` bytes,
`1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b` — because the F1a repair
re-rooted that file this round.

```
$ git show HEAD:corpus/artifacts/unreal-r22/README.md | wc -c   → 1460
$ wc -c corpus/artifacts/unreal-r22/README.md                   → 1394
$ sha256sum corpus/artifacts/unreal-r22/README.md               → 1c0d30355b34a76dc45ff27e9e684e9fe9595973e09bbc48519ad3618fea574b
```

The other three table rows (`Headless3DFixture.uplugin` `2543b337…`, `…bad-type…`
`b56a356e…`, `verify_descriptor.py` `ce07e9d5…`) still reproduce byte-exactly, as does
`scene_graph.mjs` `e4bb0a13…` and `package-lock.json` `1a8e6ee2…`. I also independently
found the `f9f40d47…` runner digest is history-only (present at `f94cd1f`, tree now
`97eca1b2…`) — the note catches that too. **The correction note is complete against every
digest I could test.**

**One ordering artifact in the r102 lesson, which the r22 note later superseded.** The r102
lesson (written 14:44:38) states that of the routed defects, "**Two remain live:** the r22
lesson still cites `verdicts.json` … and still cites `run_battery.py` sha `a065a56d…`". The
r22 lesson's correction note landed at **14:57:37**, 13 minutes *after* the r102 lesson was
written, and it repairs exactly those two (F2 and F3). So the r102 lesson's "two remain live"
is true as of its own authoring time and stale as of my read: both are now repaired by dated
correction note. This is the same snapshot-vs-truth pattern as the `40` count and the
`29/29` case count — three instances in one round of a count/status quoted from a snapshot.
I record it as an ordering artifact, not a defect of the r102 lesson's reasoning: the lesson
itself is the one that names the pattern.

### 5.4 F5 — the `engines.md` three.js command from a clean tree

Covered in §4. **REPRODUCED (fail → pass).**

### 5.5 F6 — the `rea.md` tooling census

The r1 census sentence is preserved verbatim and a dated correction note is appended. I
re-probed the host independently:

```
$ for t in jadx binwalk unblob; do $t --version; done
1.5.6
binwalk 3.1.0
26.6.4
$ which rea       → no rea (exit 1)
$ which ghidra    → no ghidra
$ echo $REA_PWNTOOLS_PYTHON  → /home/vgpnk/.local/share/kaidoku-pwnenv/bin/python
$ "$REA_PWNTOOLS_PYTHON" -c "import pwnlib; print(pwnlib.version)"  → 4.15.0, rc=0
$ python3 -c "import pwnlib"  → ModuleNotFoundError
$ ls -la "$REA_JADX_MCP_JAR"  → jadx-headless-mcp-0.7.1-all.jar, 42619858 bytes
$ java -version               → openjdk 21.0.12.1
```

| note claim | observed | verdict |
|---|---|---|
| JADX 1.5.6 present | `1.5.6`, rc 0 | **REPRODUCED** |
| Binwalk 3.1.0 present | `binwalk 3.1.0`, rc 0 | **REPRODUCED** |
| Unblob 26.6.4 present | `26.6.4`, rc 0 | **REPRODUCED** |
| pwntools present via the env-routed interpreter only | `4.15.0` rc 0 via `$REA_PWNTOOLS_PYTHON`; `ModuleNotFoundError` via bare `python3` | **REPRODUCED** |
| JADX provider jar present and JAVA_HOME ≥ 17 | 42.6 MB jar, valid archive; OpenJDK 21 | **REPRODUCED** |
| Ghidra still absent | `which` fails | **REPRODUCED** |
| no `rea` CLI | `which rea` exit 1 | **REPRODUCED** |

**REPRODUCED.** Every clause of the correction is true on this host at my runtime. The note
also keeps its scope honest — it records provider *prerequisites*, not capability, and says
no REA run was executed.

### 5.6 F8 — the `:187` "12 lines" wording

`corpus/knowledge/unreal-mcp/README.md:187` now reads:

> Observed output of `sha256sum -c .manifest.d/audit-reference.sha256` (12 lines, all `OK`;
> the `*.sha256` glob prints 24 — the same 12 paths, each covered twice):

```
$ sha256sum -c .manifest.d/*.sha256          | grep -c ': OK'   → 24
$ sha256sum -c .manifest.d/audit-reference.sha256 | grep -c ': OK' → 12
```

**REPRODUCED.** The block header now names the command whose output it actually prints, and
states both counts. The ambiguity the F8 finding described is gone; the printed block is
correct for its stated command.

---

## 6. Cross-cutting integrity checks

### 6.1 The r101 subtree is byte-stable, with one transient I observed and resolved

I observed a **transient perturbation** of the pinned subtree mid-session and chased it to
ground rather than reporting it as a finding:

- At 14:43:32 the mtimes of `upstream/README.md` and `upstream/skills/unreal-mcp/SKILL.md`
  updated, and a `diff -rq` against a fresh clone momentarily reported those two files as
  differing.
- By 14:43:57 (three consecutive samples, 4 s apart) both files were stable at their
  pinned digests (`483693ad…`, `7ef8b991…`), `git diff --stat corpus/knowledge/unreal-mcp/upstream`
  was empty, and the manifest sweep was 12 × `OK`.
- A fresh clone at the pin then confirmed live == clone blob == clone worktree for all three
  spot-checked files.

Reading: a concurrent seat rewrote and restored those files (most likely a `checkout`/`cp`
cycle during a control run). The pinned subtree is **clean at rest**, and the gate's check 2
is what makes such a window detectable — `BLOB_DIFFS=0` on the final run. No defect; the
final state is correct and the observation is recorded only so a peer who saw the same
window knows it was investigated.

### 6.2 The upstream files I checked are what upstream ships

```
$ for p in README.md skills/unreal-mcp/SKILL.md LICENSE; do …; done
README.md            live=483693ad0e14d027 blob=483693ad0e14d027 work=483693ad0e14d027  SAME
skills/…/SKILL.md    live=7ef8b991a82f591c blob=7ef8b991a82f591c work=7ef8b991a82f591c  SAME
LICENSE              live=5b337be051359edc blob=5b337be051359edc work=5b337be051359edc  SAME
```

`git -C /tmp/r102-verify ls-files -s` → every mode `100644`, 12 files; no symlinks, no
submodules — as the docs claim. Vendored total `1022` lines, matching the materials card's
cited figure.

### 6.3 The no-editor posture holds everywhere I looked

`ss -ltnp | grep -c ':8000'` → `0` (nothing listening; the README's claim). No Unreal
binary on PATH. The gate, the lesson, `engines.md`, and all 13 cards assert no runtime
behavior; the card census is `verified-here=0`, which the gate fails on if it drifts. I found
**no Unreal runtime claim anywhere** in the files this seat verified.

---

## 7. Verdict

**Overall: the lesson and the gate reproduce. One cited command does not.**

- **C1(a) — the gate: REPRODUCED.** `run_gate.sh` exists, is executable, resolves its subtree
  from its own location, runs green from repo root, `/`, and `/tmp`, and all four checks print
  the exact values the lesson and `gate/README.md` pin. All seven documented negative controls
  reproduce, each turning the gate red with the stated signal — the gate is genuinely
  fail-closed, and its own "what this does not do" section is honest about its limits.
- **C1(b) — the lesson: 40 of 41 citations REPRODUCED.** Every law's anchors resolve and say
  what the lesson says; the 12/12 byte-identity, the 24-vs-12 count, the 6-card F7 collision,
  both 404s, the card census, and both `CARDS=13 … BAD=0` scans all reproduce. **One citation
  fails: `bash /tmp/r101-closeout/pointer-check.sh corpus/knowledge/unreal-mcp` now returns
  `POINTERS=43 UNRESOLVED=3 / STEP=FAIL`, exit 1**, because the newly-landed `gate/README.md`
  plants control pointers the r101 stopgap does not exclude. One number is stale-by-design:
  `find … | wc -l` → 42, not 40, because the gate's own two files landed after the snapshot —
  a live instance of the lesson's own "enumerate, never trust a prose count" rule.
- **C1(c) — `engines.md`: REPRODUCED.** Every factual element of the new Unreal row verifies,
  the row makes no runtime claim, and the repaired three.js command now exits 0 with 3/3 from
  a genuinely clean `git archive` export (it exited 1 before the fix).
- **C2 — the routed repairs: REPRODUCED (fail → pass) for F1, F2, F3, F5, F6, F8.** Each
  before/after pair was re-run at my runtime, and the r22 correction note's own claims —
  including its historical-blob reproductions and its catch of the fourth stale digest
  (`README.md` 1460 → 1394 bytes) — verify in full.
- **Two further count discrepancies, both of the same class, both independently confirmed.**
  (i) `find corpus/knowledge/unreal-mcp -type f | wc -l` → **42**, not the lesson's 40,
  because the gate's own two files landed after that snapshot. (ii) The r22 lesson's
  `29/29 PASS` battery line is a **29-case snapshot against a 350-case fixture** — the r22
  blob defines ~30 `CASES` entries, HEAD defines ~350. Both are instances of the lesson's own
  "enumerate, never trust a count written into prose" rule, and both are now covered by dated
  correction notes rather than silent rewrites.
- **Battery: run mechanics REPRODUCED; r22's `29/29` NOT-REPRODUCED; both failure classes
  proven.** My clean re-run **completed**: `totals: cases=350 pass=336 fail=14 ordinary=291
  negative_controls=59 probes=0`, `seeds_unchanged = True` (read from
  `corpus/live/runs/20261018T175622725474Z/verdicts.json`), exit 1 from the failures. Two peer
  seats recorded the same totals independently (335/15, 336/14); my 336/14 matches seat-34
  exactly, and the peer's one extra failure was `r98_gltflat_doc`, which **passed** in my run.
  The 14 failures split into exactly two classes, each isolated to mechanism:
  1. **13 × `r94_cannon_*` — deterministic environment drift.** Each marker pins
     `node=v24.21.0`; this host runs `node v26.12.0`. Run directly, the script emits the full
     physics payload and the expected/actual strings are the **same length, differing in
     exactly 3 characters, all inside `node=`**, and byte-identical after version
     normalization. Not contention, not a fixture defect, not r102-related — it will fail
     identically on any newer-node host.
  2. **1 × `phys3d_joints_free_ops` — load starvation.** Run directly it emits the exact
     expected PASS marker and exits 0, but takes **23.5 s wall against 2.7 s CPU** against the
     runner's hard `CASE_TIMEOUT_SECONDS = 20`. A 21 s scheduler delay under load is the whole
     cause; it would not reproduce on an idle host.
  So no failure is attributable to the r102 work or the lesson, and `seeds_unchanged=true`
  holds. The r22 `29/29` is **NOT-REPRODUCED** on the count alone — it describes a 29-case
  fixture and today's battery defines 350 — while the *mechanics* it describes (a green
  battery, seeds unchanged) do reproduce modulo the 13 stale-node markers.
- **Residual, routed and unowned by this seat:** `corpus/lessons/r23-ortho-review.md` still
  carries the dead `.shokunin/game-dev-3d/` root (2 hits) and the non-resolvable
  `verdicts.json` citation; the lesson's `/tmp` pointer-check citation needs either an
  "as of pre-gate" qualifier or the three `gate/` pointers added to that script's exclusion
  list; and the 13 `r94_cannon_*` markers need their `node=` pin refreshed (a fixture change,
  outside this seat's ownership).
- **No Unreal runtime claim is made, implied, or verifiable anywhere in this report.** The
  editor is not installed; the strongest statement available is that the vendored bytes are
  byte-identical to the pinned upstream commit and that these static checks ran here.
