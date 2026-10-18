# r103 connector — what r104+ should do with the now-healthy corpus

**Seat:** SEAT-37 CONNECTOR · round 103 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only (`reports/round-103/r103-connector.md`). Every other path is
read-only here. No commit.
**Repo HEAD at write:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`)
**Measurement window:** 2026-10-18, 18:30Z–18:40Z.
**Write-path collision note:** `reports/round-103/gate/` already holds a file literally named
`clean.now.txt`, so this seat deliberately writes only its own seat path and no `gate/` subdirectory.

**No Unreal runtime claim appears anywhere in this file.** Unreal Editor is not installed on this
host (`which UnrealEditor` → rc 2, re-run below); live-MCP behaviour is unproven by construction.
A green gate is static evidence and must never be read as live-editor evidence.

Tags: **[O]** command run by this seat with output pasted · **[I]** labelled inference · **[F]** a
sibling's claim that did **not** reproduce.

**The tree moved under this seat, hard.** The gate took at least seven distinct shas during r103
(`reports/round-103/gate/docs-sync.md` §0 records them), and it kept moving **after this file was
written**: §1.1's `0c1ca3e1…` (341 lines) was `9b4763d9…` (347) a minute later and `577c8b54…` (347)
a minute after that. I re-ran every A1–A4 marker against both later revisions and all four survive
unchanged — `tr ',-'` present, `NAME_SET` present, `LABEL_RE=` present, `exit 2` present, `GATE_REF`
present — and the gate still prints `GATE RESULT: PASS (checks failed: 0)`, `NAME_SET=OK NAME_BAD=0`,
`POINTERS=98`, exit 0. Everything below is bound to the §1.1 snapshot. **Do not cite the sha in §1.1
as current**; cite the four *behaviours* verified in §1.3, which are stable across all three revisions
and are what the r104 recommendations actually depend on.

---

## 0. The one-line integration verdict

**The corpus is healthy now, and the integration gap has changed shape.** The r102 connector named
three gaps: no receipt, no harness, network-dependent. Of those, the *substance* has moved —
A1–A4 landed, B2 is repaired 3/3, C1 landed — but the three integration gaps are **all still open in
the same form**, and the round added two new ones: the gate's `BLOCKED` branch misattributes a *local*
scratch failure to *upstream unreachability*, and its new exit 2 collides with an exit-2 convention the
lane already uses for the opposite meaning. **Recommendation in §4: do option 3 (a ~2-line `engines.md`
census fix) as the cheap coverage move, and make option 2 (run_gate wiring) an L1-ruled decision that
is blocked behind the exit-2 collision — do *not* land option 1 (SKILL.md) this round.**

---

## 1. Snapshot and the receipts this seat ran

### 1.1 The snapshot

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md \
            corpus/knowledge/engines.md
0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e  …/gate/run_gate.sh
27f7d8091a23378d8699cc7bc10a5181ce5683f3611b887db485cb7d1db35720  …/gate/README.md
d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf  corpus/knowledge/engines.md
$ wc -l < corpus/knowledge/unreal-mcp/gate/run_gate.sh
341
$ git rev-parse HEAD
c85a816e227984272a3c29b58aa7f7c1a76f1e9c
```

The gate is **tracked at HEAD** (`git ls-files --error-unmatch` succeeds) and **modified this round**:

```
$ git diff --stat -- corpus/knowledge/unreal-mcp/gate/run_gate.sh
 corpus/knowledge/unreal-mcp/gate/run_gate.sh | 138 ++++++++++++++++++++++-----
 1 file changed, 115 insertions(+), 23 deletions(-)
```

So the r102 `214bf8ef…` / 249-line / untracked artifact named in `fold-spec.md` §1 is now a
**different, committed, 341-line file** at `0c1ca3e1…`. Any r102 citation of the gate's sha is stale.

### 1.2 R1 — the gate is green on the live tree [O]

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "EXIT=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
EXIT=0
```

Two new lines versus r102: `NAME_SET=OK NAME_BAD=0` (A3) and the split
`POINTERS=98 POINTER_STRINGS=41` (A1 — 98 endpoints from 41 unique pointer strings). The r102
connector's `POINTERS=40` is not comparable: it was a different regex **and** a different tree.
`UNRESOLVED=0` remains the binding invariant, exactly as the r102 lesson states.

The gate is also fast and deterministic enough to wire: three consecutive runs took **0.87 / 0.82 /
0.82 s**, and 18 further runs in two loops produced byte-identical stdout.

### 1.3 R2 — A1–A4 are all landed, verified by mutation, not by quotation [O]

The brief asked me to harden A1–A4. **All four were already landed by sibling seats before this seat
ran.** Rather than trust their reports I re-ran each item's own falsification on a scratch copy:

**A1 — range-tail endpoints.** Planted `upstream/README.md:100-9999`:

```
$ cp -a corpus/knowledge/unreal-mcp $T/sub; printf '\nsee upstream/README.md:100-9999\n' >> $T/sub/executability/blueprints.md
$ bash $T/sub/gate/run_gate.sh
LINE-OOR …/sub/executability/blueprints.md :: upstream/README.md:100-9999 (max 112)
POINTERS=100 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=27
GATE RESULT: FAIL (checks failed: 1)
```

The r102 false pass is closed. `run_gate.sh:306` is now
`for ln in $(printf '%s' "$rest" | tr ',-' '  ')` over the regex
`…:[0-9]+([,-][0-9]+)*` — the exact change IP-3 asked for. **Landed.**

**A2 — prose-hijack.** Planted a prose line naming `verified-here` *above* the declaration in
`editor-general.md`:

```
$ sed -n '1,6p' $T/sub/executability/editor-general.md
This card is emphatically not `verified-here`; nothing was observed.
# Editor domain — executability verdict card
…
**Label:** `static-only`
$ bash $T/sub/gate/run_gate.sh
CARDS=13 EXPECTED=13 BAD=0
NAME_SET=OK NAME_BAD=0
GATE RESULT: FAIL (checks failed: 1)      # the FAIL is CHECK 4's pointer sweep, not CHECK 3
```

CHECK 3 stays `BAD=0` — the hijack no longer poisons it. The rule is now anchored
(`LABEL_RE="^[[:space:]]*\*\*(Label|Verdict)( label)?:\*\*…"`, `run_gate.sh:212`) instead of
`grep -nE "$ALLOWED" | head -1`. **Landed.**

**A3 — card-name set.** Renamed `sequencer.md` → `sequence-typo.md`:

```
$ bash $T2/sub/gate/run_gate.sh
CARDS=13 EXPECTED=13 BAD=0
FAIL card-name-missing sequencer.md
FAIL card-name-extra sequence-typo.md
NAME_SET=BAD NAME_BAD=2
GATE RESULT: FAIL (checks failed: 2)
```

The r102 false pass — "a card can be silently dropped-and-replaced under a typo'd name and the gate
stays green" — is closed by an explicit name-set comparison. **Landed.**

**A4 — BLOCKED as a third state.** Offline, on the real tree:

```
$ unshare -rn bash -c 'cd … && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh'; echo "EXIT=$?"
STEP=PASS
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
STEP=PASS
STEP=PASS
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
EXIT=2
```

And the `GATE_REF` escape hatch, with networking unavailable:

```
$ unshare -rn bash -c 'cd … && GATE_REF=/home/vgpnk/r103scratch/clone bash corpus/knowledge/unreal-mcp/gate/run_gate.sh'; echo "EXIT=$?"
GATE_REF=/home/vgpnk/r103scratch/clone (offline reference; no clone attempted)
BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)
EXIT=0
```

Air-gapped close-out is now possible, and a blocked check is no longer indistinguishable from a byte
mismatch on the exit channel. **Landed** — with the two caveats in §2.3 and §3.2.

### 1.4 R3 — the other two claims also landed [O]

**B2 (dead `.shokunin/game-dev-3d/` root) — repaired 3/3.** All three READMEs are now clean and the
commands they document exit 0 from the repo root:

```
$ for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md; do
    printf "%s occ=%s\n" "$f" "$(grep -c 'shokunin/game-dev-3d' $f)"; done
corpus/fixtures/three/README.md occ=0
corpus/artifacts/glb-r12/README.md occ=0
corpus/artifacts/unity-r19/README.md occ=0
$ node corpus/fixtures/three/run_cases.mjs >/dev/null 2>&1; echo "three exit=$?"
three exit=0
$ python3 corpus/artifacts/glb-r12/run_import.py >/dev/null 2>&1; echo "glb-r12 exit=$?"
glb-r12 exit=0
```

**C1 (freshness note) — landed**, `adaptation-kimi.md` grew 363 → 506 lines (sibling measurement
`084a34cd…`; the file is still dirty in the worktree while its author finishes).

**`phys3d_joints_free_ops` — root-caused as a harness-timeout, not a fixture defect.** I reproduced
it in isolation and then measured the arm's own wall time against the runner's cap:

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs <scratch>
FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', …]
$ timeout 120 /usr/bin/godot --headless --path <scratch> --script res://phys3d_joints.gd -- --arm=free_ops
… PASS phys3d_joints free_ops freeb_ops@gp{…} … detachb_free@dummy{…}      # full pinned marker
rc=0        real 0m22.4s
$ # two further timed reps of the identical command: 20.28s, 20.20s
```

The arm **passes** and emits the pinned marker; it simply needs ~20.2–22.4 s of wall clock against
`CASE_TIMEOUT_SECONDS = 20`. It is the slowest row in the whole battery — next is 15.98 s, median
1.53 s:

```
case_timeout_seconds = 20
slowest 8 rows:
    20.01s  phys3d_joints_free_ops      <- killed at the cap
    15.98s  r100_fpslat_life
    12.08s  phys3d_joints_free_pair
median elapsed: 1.527
```

**[I]** This is a *margin* problem, not a physics regression, and it is load-sensitive — it will
flip PASS/FAIL with host load. It is a **different class** from the 13 `r94_cannon_*` rows, which fail
on `node=v24.21.0` markers against host `v26.12.0`. I performed **investigation only**; no fixture or
runner byte was touched by this seat.

---

## 2. What the two repair rounds did and did not change about integration

### 2.1 The three r102 integration gaps are all still open, measured again

| r102 gap | r102 measurement | r103 measurement (this seat) | closed? |
|---|---|---|---|
| **no receipt** | gate writes stdout only (`mktemp`+`trap`) | still true; no `--receipt` flag exists | **no** |
| **outside every standing harness** | `grep -rln "run_gate" corpus/fixtures/` → rc 1 | `grep -rn "run_gate" corpus/fixtures/*.py corpus/fixtures/*/*.mjs corpus/knowledge/engines.md` → **0 hits** | **no** |
| **not in the digest map** | `seed_digests()` 130 entries, 0 `knowledge` refs | **identical**: 130 entries, 0 `knowledge` / 0 `unreal-mcp` / 0 `gate` refs | **no** |

```
$ python3 - <<'PY'
import importlib.util
s=importlib.util.spec_from_file_location("rb","corpus/fixtures/run_battery.py")
m=importlib.util.module_from_spec(s); s.loader.exec_module(m)
d=m.seed_digests()
print("entries:",len(d))
print("knowledge refs:",sum('knowledge' in k for k in d))
print("unreal-mcp refs:",sum('unreal-mcp' in k for k in d))
print("gate refs:",sum('gate' in k for k in d))
PY
entries: 130
knowledge refs: 0
unreal-mcp refs: 0
gate refs: 0
```

**This is the load-bearing fact for the r104 decision.** Two repair rounds made the corpus
*healthier*; neither made the gate *automatic*. The gate is still invoked by humans and by nothing
else — `git grep -n "run_gate"` over the tracked tree outside the gate's own directory returns hits
only in prose (`LOG.md:1329`, `SCORECARD.md:301`, the r102 lesson, and r102 seat reports). The only
executable reference to the gate anywhere is a *proposal* (`reports/round-102/battery-relation.md`).

**[I]** The consequence is the one the r102 connector named and it still holds one round later:
nothing in the lane's standing machinery fails if a vendored byte is edited next round. The gate
catches it only if a human remembers to type the command. **A gate that only ever runs by hand is an
artifact, not a gate.**

### 2.2 The gate is now cheaper to wire than it was — the r102 blocker has partly dissolved

The r102 connector's IP-2 caveat was: *"folding the gate into the battery would make the battery
network-dependent for the first time."* A4 changes that arithmetic:

- `GATE_REF=<path>` gives a **full green run with no network** (R2), so a wiring seat can pass a
  caller-supplied reference clone and keep the battery hermetic.
- `BLOCKED`/exit 2 now exists as a distinct state, so a wiring seat **can** classify "could not
  evaluate" separately from "bytes diverge" — which is exactly what `battery-relation.md` §4's sketch
  needed and could not have, since that sketch was written against the pre-A4 gate and therefore
  invents its own `STEP=SKIP`/`PARTIAL` vocabulary.

**[I]** So the gate-side prerequisites for IP-2 option 1 are now largely in place. What blocks it is
no longer the gate — it is the **exit-code collision in §2.3**, which is a lane-convention problem.

### 2.3 The r103 round added two new integration hazards

**H1 — the `BLOCKED` branch misattributes a local failure to a remote one [O].** A4's message
asserts a cause it has not established. When the clone fails for a purely local reason, the gate still
says "upstream unreachable":

```
$ TMPDIR=/nonexistent-dir-xyz bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
mktemp: failed to create directory via template '/nonexistent-dir-xyz/tmp.XXXXXXXXXX': No such file or directory
…/gate/run_gate.sh: line 146: /clone.log: Permission denied
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
sed: can't read /clone.log: No such file or directory
STEP=BLOCKED
GATE RESULT: FAIL (checks failed: 1)
```

Note the **contradiction inside one run**: `STEP=BLOCKED` but `GATE RESULT: FAIL`. That is because
`$WORK` is empty, so `clone.log` cannot be written, so `sed -n '1,5p' "$WORK/clone.log"` errors — and
with no `set -e` the script continues past the `exit 2` guard into the FAIL path. Exit was **1**, not 2.

I hit the *benign* form of this live, before I understood it: two consecutive runs of the unmodified
gate returned `GATE RESULT: BLOCKED … EXIT=2` while `git ls-remote` and a plain `git clone` both
returned rc 0 in the same window, and 20 s later the identical command returned `PASS … EXIT=0`. The
cause was `/tmp` quota pressure (tmpfs, `13G` used of `16G`, 80 %) — `mktemp -d` failed, not the
network. **[I]** So `BLOCKED (network)` currently means *"the clone did not complete"*, and the word
`(network)` in the label is a guess the gate cannot support. Under load, a wiring seat would record a
local scratch failure as a network outage.

**H2 — the new exit 2 collides with the lane's existing exit-2 convention [O].** The lane already
defines exit 2, and it means the **opposite** of "could not evaluate":

```
$ sed -n '44,50p' corpus/fixtures/README.md
| positive holds | 0 | one exact `PASS <case> ...` line | PASS |
| negative control rejects as intended | 2 | one exact `NEGATIVE REJECTED: <case> <reason>` line | PASS |
| setup/script error, … | 1 | no `ERROR:` marker | FAIL |
Exit 2 is a *passing* negative control, not a failure: …
```

In this lane **exit 2 means a *passing* negative control.** The gate's `exit 2` means *"nothing was
compared."* A wrapper that folds the gate's status into a battery verdict using the lane's own
convention would read a blocked gate as **green**. `reports/round-103/gate/exit-codes.md` reaches the
same conclusion independently (`reject the exit-2 variant … adopt the GATE_REF variant`), and I
re-derived the collision from `corpus/fixtures/README.md` rather than quoting it.

**H3 (documentation, minor) — `gate/README.md` now contradicts the script.** A4 landed in the script
but not in the README:

```
$ sed -n '73,74p' corpus/knowledge/unreal-mcp/gate/README.md
**BLOCKED, not PASS.** This is the only check needing network. If the clone fails, the gate
prints `FAIL fresh clone failed … BLOCKED, not PASS`, the check fails, and the run exits 1.
```

The README says **exits 1**; the script exits **2**, and it no longer prints the string the README
quotes. The README is also silent on `NAME_SET`, `GATE_REF`, and the new `POINTERS/POINTER_STRINGS`
split. **[I]** This is a *doc/code contradiction created by the repair round itself* — the same class
the lane has been repairing all along (prose citing bytes that no longer match), now inside the
artifact that exists to catch that class.

---

## 3. The three candidate options, measured

### 3.1 Option 1 — land the SKILL.md decision table

**Anchor.** `reports/round-102/skill-decision-table-draft.md` (373 lines, `fa360bde…`), reviewed in
`reports/round-103/skill-table-review.md`.

**Measured state.** `SKILL.md` does not exist (`ls SKILL.md` → `No such file or directory`), so
landing the table means **creating the lane's skill file**, which is a promotion action, not a repair.
`SHONEN.md:1` still reads `- [ ] Real decision tables/error patterns/checklists with cited sources.`
and `SHONEN.md:7` requires *"a named non-author verifier with an evidence pointer"* for every box.

**Blocking defects — four of four rows still REVISE [O, re-derived].** The r103 reviewer found all
four rows non-executable as written; the sharpest one is mechanical and I confirmed its shape:
`gate/README.md`'s `CHECK 2` contract, which the draft's row A cites, changed under it this round
(`214bf8ef…` → `27f7d809…`). The draft's own §6 citation rule — *"cite a mutable artifact by section
heading plus a sha256 stamp, never by bare line number"* — is violated by its own gate citations.
Additionally the F7 label collision is **still open**: the subtree `README.md` hash is unchanged
(`c79d8dd1…`), so `README.md:41` and the six dissenting cards still disagree, and the draft's §3 P/C
precedence ruling is still owed.

**Verdict: do not land.** **[I]** The blocker is not the table's content — the four rows are the right
four rows — it is that the table's provenance column decays faster than the table can be verified, and
the round has now demonstrated that decay twice. Landing it would create a new artifact with exactly
the defect class the round spent two rounds repairing. This is a **promotion decision for the L1**,
and it should be gated on the P/C ruling landing first.

### 3.2 Option 2 — wire `run_gate` into the battery

**Anchor.** `run_battery.py:1227-1237` (the `--probe-*` flags) and `:1374-1376` (the verdict
expression) — the lane's own established extension point, which `battery-relation.md` §4 already
sketched in full (~35 lines, no new idiom).

**Measured state.** Gap unchanged: 0 references to `run_gate` in `corpus/fixtures/`, 0 gate entries in
`seed_digests()`. The gate is fast (0.82–0.87 s, §1.2) against the sketch's 300 s budget, so cost is
not the objection.

**Two real blockers, both new this round.**
1. **The exit-2 collision (§2.3 H2).** A wiring seat must *not* use the lane's own convention, or a
   blocked gate reads as green. This is a **ruling**, not an implementation detail — and the r102
   fold-spec is explicit that C1 *"needs an L1 ruling, then one implementation seat; must not be split
   across seats."*
2. **`phys3d_joints_free_ops` shows the battery already has a load-sensitive red row (§1.4).** A
   gate folded into `verdict` (`run_battery.py:1374-1376`) would turn any transient `BLOCKED` into a
   battery FAIL — and §2.3 H1 shows transient BLOCKED is *reachable today* from `/tmp` pressure alone.
   **[I]** Wiring a flaky-in-the-presence-of-local-IO-failure check into a verdict that has no
   `BLOCKED` channel would import a new false-red class into the lane's primary harness.

**Verdict: right move, wrong round to rush.** The gate-side prerequisites are now in place (§2.2),
which is real progress. But it must be sequenced *after* the exit-2 ruling and it should adopt A4's
`GATE_REF` for hermeticity rather than inventing `STEP=SKIP`/`PARTIAL` as the r102 sketch proposed —
that sketch predates A4 and is now partly obsolete.

### 3.3 Option 3 — `PROVINCE.md` / `engines.md` census cadence

**Anchor.** `PROVINCE.md:14` — *"Engine census and execution reality live in corpus/knowledge/engines.md
and are maintained by the lane"* — and `engines.md:13-16`, the no-promotion rule.

**Measured state: this is where the round left a concrete, cheap, unfixed defect [O].** The Unreal
row's evidence cell (`engines.md:10`) cites the manifest command as a bare relative path:

```
| Unreal Engine | no | no | … 12/12 tracked files byte-identical
  (`sha256sum -c .manifest.d/audit-reference.sha256` → rc=0), 13 `executability/` cards … |
```

Run **verbatim from the repo root** — which is where a reader of the census will be — it fails:

```
$ sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo "from_root_exit=$?"
from_root_exit=1
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1); echo "from_subtree_exit=$?"
from_subtree_exit=0
```

The manifest stores **relative** paths, so it verifies only with the subtree as cwd — the exact
implicit-cwd precondition the r102 connector identified and the gate wrapper now removes. The census
row still carries it. **This is a live, reproducible prose-cites-a-command defect in the census**, and
it is in the same class as the five F-routed defects r102 repaired.

**Two further cadence facts.**
- `engines.md` has **0 references to `run_gate`**: the census cites the manifest directly and does not
  point at the gate that now performs the check correctly. So the census under-describes its own
  strongest evidence.
- `engines.md` is byte-unchanged this round (`git diff --stat` → empty, `d03907d3…`), i.e. the census
  did **not** move despite the gate, the subtree, and two README repairs all moving around it. **[I]**
  A census that only moves when a probe lands will drift from the artifacts it describes.

**Verdict: do this one.** It is the only option that is cheap, unblocked, purely mechanical, and
fixes a *currently failing* command. It is a ~2-line evidence-cell edit.

---

## 4. Recommendation for r104+

**Primary — take option 3, in its narrow form (coverage).**
1. Fix `engines.md:10`'s Unreal-row evidence cell to a **repo-root-runnable** command — either the
   `(cd corpus/knowledge/unreal-mcp && sha256sum -c …)` form or, better, a pointer to
   `bash corpus/knowledge/unreal-mcp/gate/run_gate.sh`, which already resolves its own cwd. Cite the
   gate's sha (`0c1ca3e1…`) alongside it, per the r102 lesson's citation rule.
2. Add a `run_gate.sh` reference to the census **rules** block (`engines.md:13-16`) so the census names
   the gate as the standing check for the pinned-subtree row.
   *Acceptance:* the cited command exits 0 verbatim from the repo root, and
   `grep -c run_gate corpus/knowledge/engines.md` ≥ 1.
   *Owner:* one seat owning `corpus/knowledge/engines.md`.

**Second — rule the exit-2 collision before any wiring (calibration).** This is the highest-value
*unblocking* move and it is an L1 decision, not a repair. Either (a) declare the gate's exit 2 as a
lane-wide third state and update `corpus/fixtures/README.md:44-50` to reconcile it with the
negative-control meaning, or (b) **reject exit 2 for the gate** and keep 0/1 only, letting the
`BLOCKED` *stdout token* (which is unambiguous) carry the distinction. Option (b) is cheaper and
collides with nothing. *Acceptance:* the chosen convention is written in `LOG.md`, and
`corpus/fixtures/README.md` and `gate/README.md:73-74` no longer contradict each other or the script.

**Third — wire the gate only after the ruling, and hermetic-by-default (depth).** One implementation
seat on `corpus/fixtures/run_battery.py`, using the `--probe-*` extension point, with three
requirements that the round's measurements now justify: (i) classify via the `BLOCKED` token, never
the bare exit code; (ii) prefer `GATE_REF` so the battery stays network-free; (iii) treat
`BLOCKED` as **not-a-verdict**, never as a battery FAIL — §2.3 H1 shows BLOCKED is reachable from
local scratch failure. *Acceptance:* flipping one byte in a private copy of `upstream/README.md`
flips the battery verdict to non-zero while the unmodified tree stays green, and the 350 `CASES` rows
stay AST-parseable.

**Defer — the SKILL.md landing.** Promote only after (a) the F7 P/C precedence ruling lands and (b)
the table's four rows pass a re-review against a *frozen* gate sha. Do not let a healthy corpus talk
the lane into creating its skill file on a table whose provenance column has decayed twice.

**Queue as small repairs (no ruling needed):**
- `gate/README.md:73-74` → update the exit-1 text to A4's exit-2 semantics, and document `NAME_SET`,
  `GATE_REF`, and the `POINTERS/POINTER_STRINGS` split. (§2.3 H3.)
- The `BLOCKED` branch's message and its `$WORK`-dependent `sed` → either establish the cause before
  naming it, or soften the label from `BLOCKED (network)` to `BLOCKED (clone did not complete)`, and
  guard the `clone.log` read so a failed `mktemp` cannot produce a self-contradictory
  `STEP=BLOCKED` + `GATE RESULT: FAIL` run. (§2.3 H1.)
- `phys3d_joints_free_ops`: an operator/L1 decision between raising `CASE_TIMEOUT_SECONDS` for that
  row or re-baselining it. It is a margin problem (20.2–22.4 s vs 20 s), not a physics defect.
  **Do not** raise the global cap silently — it is a battery-contract change.

---

## 5. What a later seat must not assume

- **A green gate is not a clean bill, and the gate says so itself.** It proves the 12 vendored files
  equal a manifest and a fresh clone at the pin, and that four static checks ran. It says nothing
  about plugin load, UBT compilation, or editor behaviour. `gate/README.md:18-22` states this.
- **`POINTERS=98` is scanner-relative.** r103 measured 87 → 88 → 90 → 98 across concurrent edits; the
  r102 connector measured 40/47 for two *other* regexes; the r102 report recorded 40/41/43 for three
  *other* scanners on one tree. **Never cite a bare `POINTERS=` without naming the scanner and the
  tree state.** `UNRESOLVED=0` is the invariant that matters.
- **`NAME_SET=OK` does not close F7.** Check 3 enforces one *allowed* label per card and now the card
  *name* set; it still cannot judge whether a `static-only` card actually rests on a static check that
  ran here. The six-card label collision is untouched.
- **A `BLOCKED` result is not a pass and not a fail.** Exit 2 means CHECK 2 could not run; the
  vendored bytes are **UNCHECKED**. In this lane exit 2 also means a *passing negative control* — read
  the token, not the code.
- **This report's numbers are a frame, not a constant.** The gate took ≥7 shas during r103 and the
  subtree prose moved under every seat. Re-read the target before editing it.
- **The transient `corpus/fixtures/r90bt_*` directories were generated artifacts, not a defect — and
  they are now gone.** Mid-window I observed 21 untracked `r90bt_<arm>_<case>_<backend>/` dirs in the
  seed tree; a later `ls -d corpus/fixtures/r90bt_* | wc -l` → **0**, removed by another seat.
  Controlled before/after: running the `free_ops` arm against a **copy** of `corpus/fixtures/` creates
  them in the *copy* and does **not** modify the seed tree (`diff` of the before/after listing →
  `NO_CHANGE_IN_SEED_TREE`), and `seed_digests()` has 0 `r90bt` entries. `corpus/fixtures/**` was not
  written by this seat (`git status --porcelain -uall -- corpus/fixtures/` → only the peer seat's
  ` M corpus/fixtures/three/README.md`).
  **[I]** Worth one r104 look: these dirs are **not gitignored** (`git check-ignore` → rc 1) and the
  runner only excludes its own `__pycache__`/`three`, so a battery run that writes into the *seed*
  tree would pollute a protected path and be caught only by `seed_digests()`. That they appeared at
  all is evidence some invocation path can do so.

---

## 6. Limits of this report

- **Read-only except this file.** No commit. I wrote no `corpus/` byte, no `LOG.md`/`SCORECARD.md`/
  `SHONEN.md`/`SKILL.md`/`PROVINCE.md` byte, no fixture, no manifest, no other seat's report. Every
  mutation test ran on a copy under `/tmp` or `/home/vgpnk/r103scratch`.
- **All four hardening items were already landed when I ran.** My contribution is independent
  re-verification (§1.3) plus the two new hazards (§2.3), not the landing.
- **I did not run the full 350-case battery.** I ran `--only phys3d_joints_free_ops` (1 row) to
  root-cause that row, and relied on the r102 idle-run receipt for the other 349. I therefore assert
  nothing new about the 13 `r94_cannon_*` rows beyond what the receipt and `r102-report.md:450` say.
- **`/tmp` was under quota pressure throughout this seat** (`13G` of `16G`, 80 %), which both limited
  my scratch copies and — usefully — surfaced H1. Scratch copies were made under `/home/vgpnk/r103scratch`
  where the copy would not fit in `/tmp`.
- **The BLOCKED flake I observed was transient and I could not reproduce it on demand.** I report the
  two runs I actually saw (exit 2, then PASS 20 s later) and the deterministic cause I could
  reproduce (`TMPDIR` unwritable → `BLOCKED (network)` + exit 1), and I distinguish the two.
- **No Unreal runtime claim appears in this file.** The editor is not installed; live-MCP behaviour is
  unproven by construction.
