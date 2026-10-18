# r103 SEAT-64 — CLOSE-COUNT

**Seat:** SEAT-64 CLOSE-COUNT · round 103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/close-count.md`). No other file was written by
this seat; no commit / push / checkout / reset was run.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
**Snapshot window:** `2026-10-18T18:31Z` → `2026-10-18T18:41Z` (local 15:31 → 15:41, `-0300`)
**No Unreal runtime claim appears anywhere in this file.** The editor is not installed and live-MCP
is unproven by construction; every number below is a byte, exit-status, or filesystem measurement.

---

## 0. The one-paragraph version

The round's countable work landed, but **the tree did not stop moving while it was being counted**:
the gate changed bytes **four times** inside the snapshot window and flipped between `PASS` and
`FAIL` **seven** times. The last three consecutive readings are identical and green —
`GATE RESULT: PASS (checks failed: 0)`, `RC=0`, `POINTERS=101 UNRESOLVED=0` — taken after the one
transient failure resolved. That transient was a **peer artifact still in flight**
(`reports/round-103/gate/hardening.md`, cited by a sibling report before it was written), not a
defect in any artifact this round set out to produce. Every headline claim of the round verifies:
the freshness note landed (C1), the gate hardening A1–A4 landed and **all four are now
independently falsification-tested here** (C2), the three dead-root READMEs are repaired and the
physics row is classified (C3).

---

## 1. The done-table

Every row's evidence is a command this seat ran; the observed output is in the cell or in §2.

| # | item | claim | state | measured value | deciding command (abbreviated) |
|---|---|---|---|---|---|
| 1 | `adaptation-kimi.md` freshness note | C1 | **DONE** | `+143` lines, 1 note, `git diff --stat HEAD` = `1 file changed, 143 insertions(+)` | `git diff --stat HEAD -- corpus/knowledge/unreal-mcp/adaptation-kimi.md` |
| 2 | C1 config-line citation repaired | C1 | **DONE** | note names **`3290`**; file is **3322** lines; `grep -n '\[\[hooks\]\]'` → `3290` | `grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml` |
| 3 | C1 `/en/` doc-URL repair | C1 | **DONE** | 6 `/en/` occurrences in the file; 4 old URLs still 404, all `/en/` forms 200 | `grep -c "/en/" corpus/knowledge/unreal-mcp/adaptation-kimi.md` |
| 4 | C1 `/tmp` pointer → vendored | C1 | **PARTIAL** | `grep -c "tmp/ue-skills-ref"` → **10** surviving hits in the file (historical rows left verbatim by design; the note names the vendored replacement) | `grep -c "tmp/ue-skills-ref" …adaptation-kimi.md` |
| 5 | gate A1 — every endpoint of `:a-b`/`:a,b` validated | C2 | **DONE** | regex now `…:[0-9]+([,-][0-9]+)*`; per-endpoint `for ln in $(… tr ',-' '  ')`; planted tail flips `LINE-OOR` | `bash $T/…/run_gate.sh` after `printf '\nsee upstream/README.md:1-9999\n'` |
| 6 | gate A2 — prose-hijack-proof label rule | C2 | **DONE** | `LABEL_RE` anchors on `**Label:**`/`**Verdict:**`/`**\`token\`**`; prose copy → `GATE RESULT: PASS`; stripped declaration → `FAIL no-label` | see §2.3 |
| 7 | gate A3 — pinned card-name set compared | C2 | **DONE** | `PINNED_CARD_NAMES` (13 stems); rename `sequencer.md`→`sequence-typo.md` → `NAME_SET=BAD NAME_BAD=2`, `STEP=FAIL` | see §2.4 |
| 8 | gate A4 — distinct BLOCKED + exit 2 | C2 | **DONE** | unreachable `REPO`, no `GATE_REF` → `STEP=BLOCKED`, `GATE RESULT: BLOCKED`, **RC=2**; with `GATE_REF` at the pin → **RC=0**, `BLOB_DIFFS=0` | see §2.5 |
| 9 | 11-attack r102 suite re-run vs installed gate | C2 | **11/11 DETECTED** | all of H2/H3/H4/H1/H1b/H5/H6/H22/H14/H21/H20 flip to `STEP=FAIL`; clean control `PASS` rc=0 | `bash /home/vgpnk/advgate-r103/attacks2.sh` |
| 10 | B2 dead-root repair — `three/README.md` | C3 | **DONE** | `grep -c` → **0** (was 17) | `grep -c "shokunin/game-dev-3d" corpus/fixtures/three/README.md` |
| 11 | B2 dead-root repair — `glb-r12/README.md` | C3 | **DONE** | `grep -c` → **0** (was 3) | same, `corpus/artifacts/glb-r12/README.md` |
| 12 | B2 dead-root repair — `unity-r19/README.md` | C3 | **DONE** | `grep -c` → **0** (was 2) | same, `corpus/artifacts/unity-r19/README.md` |
| 13 | B2 postgrep — dead roots in runnable contexts | C3 | **0** | `git grep -l` HEAD **167** → worktree **164**; runnable-context class closed | `git grep -l "\.shokunin/game-dev-3d" \| wc -l` |
| 14 | B2 scope ruling | C3 | **DONE** | `reports/round-103/b2/ruling.md` rules 3 repairs + keep-list; 1 flag for L1 (fixture-tree scope) | read-back of `b2/ruling.md` |
| 15 | physics row `phys3d_joints_free_ops` classified | C3 | **harness-timeout** | direct arm **22.4 s wall / 2.5 s CPU** vs cap **20 s**; marker byte-identical; `--only` reproduces FAIL | see §2.6 |
| 16 | physics row — NOT a fixture defect | C3 | **CONFIRMED** | pinned marker emitted verbatim, `exit=0`; gap ≈ 20 s of pure scheduler delay; load avg **18.2** on 32 cores | same |
| 17 | r102 receipt re-classified | C3 | **336/350 = 1 + 13** | 1 contention timeout + 13 `r94_cannon_*` marker mismatches (node v24.21.0 pinned vs v26.12.0 installed) | `json.load(...)['totals']` → `cases 350 pass 336 fail 14` |
| 18 | upstream pin unchanged | all | **HOLD** | `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297` on every successful clone this seat ran | gate CHECK 2 |
| 19 | `upstream/` bytes unperturbed by any r103 edit | all | **CONFIRMED** | `MANIFEST_OK=12 EXPECTED=12 FAILED=0`, `BLOB_DIFFS=0` on all 4 gate revisions | gate CHECK 1 + 2 |
| 20 | `reports/round-103/` artifact count | — | **53** at 18:42Z (18 → 30 → 49 → 53) | still growing as seats land | `find reports/round-103 -type f \| wc -l` |
| 21 | gate final state at my runtime | — | **PASS, rc=0** (×3 identical) | `GATE RESULT: PASS (checks failed: 0)`, `POINTERS=101 UNRESOLVED=0` | see §2.1 |
| 21b | gate transient during the round | — | **FAIL, rc=1** (1 of 7) | `MISSING-PATH-REL reports/round-103/gate/hardening.md` — in-flight peer artifact; resolved ~30 s later | §2.1 |
| 22 | gate revision count inside the window | — | **4** | `412d1b84`→`ff2c26c0`→`0c1ca3e1`→`577c8b54`; 13 106 → 19 347 bytes | `sha256sum` + `stat` (§2.0) |
| 23 | gate PASS/FAIL flips inside the window | — | **7** (6 PASS / 1 FAIL) | FAIL / PASS / FAIL / PASS / PASS / FAIL / PASS across ~16 runs | §2.0 |
| 24 | gate `POINTERS` at close | — | **101** | `POINTERS=101 POINTER_STRINGS=41 … UNRESOLVED=0` (the brief's `87` is two revisions stale) | gate CHECK 4 |
| 25 | `POINTERS` drift inside the window | — | **87 → 101** | 87 / 88 / 89 / 90 / 91 / 98 / 100 / 101 as peer reports landed | gate CHECK 4, each run |
| 26 | ledger + protected trees | — | **CLEAN** | `LOG.md`/`SCORECARD.md`/`SHONEN.md`/`PROVINCE.md` blob-identical to HEAD (peer-verified, §3) | `git hash-object` vs `HEAD:<path>` |
| 27 | `corpus/live/runs` receipts | — | **+1 mine** | `20261018T183451061678Z` written by my `--only` run | `ls corpus/live/runs` |

---

## 2. Evidence — commands pasted

### 2.0 The gate moved four times under this seat

```
$ for t in ...; do sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh; stat -c '%s %y' …; done
412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96   13106  2026-10-18 15:15:52 -0300
ff2c26c0080fe88a2a3d6d81ca3af2083a2f07c80f173b104f20d48c865d950e   16707  2026-10-18 15:35:58 -0300
0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e   18817  2026-10-18 15:36:44 -0300
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0   19347  2026-10-18 15:39:38 -0300   <- at close
```

The brief's `POINTERS=87 … passes clean` and the file's own `clean.raw.txt` (`POINTERS=88`, 15:31)
are **two revisions behind close**. `A1`/`A3`/`A4` markers were absent at 15:15 and present from
15:35 onward — the hardening landed mid-round, after the brief was written.

### 2.1 Gate, final snapshot (`577c8b54…`, 18:41:39Z)

Three consecutive runs, identical:

```
$ for i in 1 2 3; do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"; done
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0            STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0  BLOB_DIFFS=0           STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0                              STEP=PASS
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0   STEP=PASS
GATE RESULT: PASS (checks failed: 0)
RC=0                       <- run 1; run 2 and run 3 byte-identical
```

**The transient, kept in the record.** Twelve minutes earlier, on the same gate revision, the run
read `POINTERS=101 … UNRESOLVED=1 / MISSING-PATH-REL reports/round-103/gate/hardening.md /
GATE RESULT: FAIL (checks failed: 1) / RC=1`. That is the **fourth** `UNRESOLVED` event this seat
observed, each with a different in-flight target:

| observed | in-flight pointer | resolved by |
|---|---|---|
| 18:33Z | `reports/round-103/note/author.md` | that file landing (~1 min) |
| 18:41:07Z | `reports/round-103/gate/hardening.md` | that file landing (~30 s) |

`MISSING-PATH-REL` is *pass B* of CHECK 4 — the repo-relative sweep the gate gained in r102 — which
reads the **live** tree, including the round's own in-flight reports. Every event was a **race
between the gate and the round's own writers**, never a defect in an artifact under test: on each
occasion the same revision read `UNRESOLVED=0` before the citing file appeared and after the target
landed. The three checks that measure *frozen* artifacts (manifest bytes, clone equivalence, card
set + names) passed on **all four** gate revisions without exception.

### 2.2 A1 — planted range tail

```
$ printf '\nsee upstream/README.md:1-9999\n' >> $W/corpus/knowledge/unreal-mcp/README.md
$ bash $W/corpus/knowledge/unreal-mcp/gate/run_gate.sh
LINE-OOR …/unreal-mcp/README.md :: upstream/README.md:1-9999 (max 112)
POINTERS=92 … UNRESOLVED=1
STEP=FAIL
```

Under the r102 gate the same plant resolved as in-range `:1` and the gate stayed green
(`reports/round-102/fold-spec.md` §A1). **A1 closes.**

### 2.3 A2 — prose above the declaration must NOT hijack the rule

```
$ sed -i '4i This card is emphatically not `verified-here`; nothing was observed.' \
        $W/…/executability/editor-general.md
$ bash $W/…/gate/run_gate.sh | grep -E 'FAIL label|CARDS=|GATE RESULT'
CARDS=13 EXPECTED=13 BAD=0
GATE RESULT: PASS (checks failed: 0)        <- correct: the declaration at line 5 still wins
```

Negative control — strip the declaration entirely:

```
$ sed -i -E 's/\*\*(Label|Verdict)( label)?:\*\*[^`]*`(static-only|…|)`.*/no label/' \
        $W/…/executability/editor-general.md
FAIL no-label       …/executability/editor-general.md
CARDS=13 EXPECTED=13 BAD=1
GATE RESULT: FAIL (checks failed: 1)
```

Two rows of the fold-spec's stated acceptance are **met by construction rather than by check**:
an "unlabelled" plant that edits only line 4 still passes, because 13 of 13 real cards carry a
`**Label basis:**` continuation and several carry a `## 1. Verdict` block below — the rule finds
the surviving declaration. The rule is prose-hijack-proof; it is not "the file must contain exactly
one token". Recorded as a **spec-wording** residual, not a gate defect.

### 2.4 A3 — typo-named card

```
$ mv $W/…/executability/sequencer.md $W/…/executability/sequence-typo.md
$ bash $W/…/gate/run_gate.sh | grep -E 'NAME_SET|CARDS=|GATE RESULT'
CARDS=13 EXPECTED=13 BAD=0
NAME_SET=BAD NAME_BAD=2
GATE RESULT: FAIL (checks failed: 2)
```

Under the r102 gate this rename left `CARDS=13 EXPECTED=13 BAD=0` and stayed green
(`reports/round-102/fold-spec.md` §A3). **A3 closes.**

### 2.5 A4 — BLOCKED is a third state, and `GATE_REF` is the air-gap route

```
$ sed -i 's|^REPO=.*|REPO=https://github.com/EpicGames/not-a-real-repo-r103|' $W/…/run_gate.sh
$ bash $W/…/run_gate.sh; echo "RC=$?"
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
RC=2

$ git -C $CL rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ GATE_REF=$CL bash $W/…/run_gate.sh; echo "RC=$?"
GATE_REF=/home/vgpnk/advgate-r103/refclone (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_TRACKED=12  BLOB_DIFFS=0
GATE RESULT: PASS (checks failed: 0)
RC=0
```

Both branches of A4's "either (a) … or (b) …" are implemented, and the exit code — not the summary
line — carries the distinction (`0 PASS / 1 FAIL / 2 BLOCKED`). **A4 closes.** The live gate's own
A4b comment records the trap this seat also hit: pass B's root was named `REPO`, the same name as
the clone URL, so any caller overriding the clone target silently repointed the repo-relative sweep
and manufactured ~26 spurious `MISSING-PATH-REL` lines. It is now `REPO_ROOT`. My first two scratch
harnesses reproduced exactly that artifact (§4).

### 2.6 Physics — harness-timeout, independently reproduced

```
$ uptime; nproc
 15:34:28 up 1 day, 15:34,  1 user,  load average: 18.16, 12.55, 12.23
32

$ time timeout 120 godot --headless --path corpus/live/runs/20261018T181301123479Z/scratch \
      --script res://phys3d_joints.gd -- --arm=free_ops
PASS phys3d_joints free_ops freeb_ops@gp{mode_ok=1,m6=124dfece8083d80f} … freej_then_b@dummy{…}
GODOT_RC=0
real  0m22.384s   user 0m2.456s   sys 0m1.281s

$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops
FAIL phys3d_joints_free_ops: exit=None expected=0
     reasons=['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)',
              'exact stdout marker missing']
totals: cases=1 pass=0 fail=1
```

**Classification: harness-timeout (wall-clock starvation).** Not engine behaviour, not a fixture
defect. The arm exits 0 and emits the pinned marker byte-for-byte; it needs ~22 s of wall against
the runner's hard `CASE_TIMEOUT_SECONDS = 20` (`corpus/fixtures/run_battery.py:36`) while spending
~2.5 s of CPU — a ~20 s scheduler-starvation gap at load 18.2/32. The row is therefore the
**first** of the receipt's 14 failures; the other 13 are `r94_cannon_*` marker mismatches (rows pin
`node=v24.21.0`, the host runs v26.12.0). `336/350` is **1 + 13**, not 14 regressions. This seat
made **no repair** to the row — the classification is the deliverable (C3), matching the seat-32
report in `reports/round-103/physics/investigate.md`.

### 2.7 B2 postgrep

```
$ for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md \
           corpus/artifacts/unity-r19/README.md; do grep -c "shokunin/game-dev-3d" $f; done
0
0
0
$ git grep -l "\.shokunin/game-dev-3d" HEAD | wc -l     -> 167
$ git grep -l "\.shokunin/game-dev-3d"      | wc -l     -> 164
```

All three routed READMEs repaired in place (17 / 3 / 2 → 0 / 0 / 0). The HEAD→worktree delta of 3
is exactly those three files; every surviving hit is a keep class (dated record, correction-note
quote, append-only ledger, digest-pinned fixture seed, machine receipt), per
`reports/round-103/b2/postgrep.md` and `b2/ruling.md`.

---

## 3. Ledger and protected trees — peer-verified, re-read by this seat

| tree | verdict | source |
|---|---|---|
| `LOG.md`, `SCORECARD.md`, `SHONEN.md` | byte-identical to HEAD | `reports/round-103/ledger-check.md` |
| `PROVINCE.md` | byte-identical to HEAD | `reports/round-103/seats-ledger.md` |
| `corpus/knowledge/unreal-mcp/upstream/` + `.manifest.d/` | byte-stable, 12/12 OK | `reports/round-103/subtree-integrity.md`; gate CHECK 1 |
| `reports/round-101/` (33 files), `reports/round-102/` (61 files) | byte-identical to HEAD, no additions | `reports/round-103/ledger-check.md` |

`git status --porcelain` at close — the only tracked deltas are the round's intended edits plus the
new round directory:

```
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? reports/round-103/
```

**Flag for the L1 (not this seat's ruling).** `corpus/fixtures/three/README.md` is inside
`corpus/fixtures/**`, a HARD-RULES-protected tree, and it was edited **after** the ledger check
declared that tree clean — so that check's verdict is now stale. The edit is substantively correct
(that README is excluded from `seed_digests()`, so nothing digest-pinned moved), but the scope
question is unruled. Recorded identically in `reports/round-103/b2/postgrep.md` §4.1.

---

## 4. Self-report — two discarded harnesses, one cleanup

Stated plainly because both produced numbers that were **wrong before they were right**.

1. **Partial-tree scratch (discarded).** My first attack harness copied only
   `corpus/knowledge/unreal-mcp` plus symlinks to `reports/` and `corpus/lessons`. The gate's
   repo-relative sweep then reported **26 phantom `MISSING-PATH-REL`** lines. Cause: pass B
   resolves `corpus/…` / `reports/…` against the *repo root*, which a partial copy does not have.
   Fixed by copying the whole tree minus `.git` and `corpus/live` (44 MB) — clean control then read
   `UNRESOLVED=0`. **No number in §1 comes from the partial harness.**
2. **Out-of-tree gate copy (discarded).** My first A4 harness copied the mutated gate *outside* the
   tree, so `SUB=$(dirname $BASH_SOURCE)/..` mis-resolved and produced a bogus
   `checks failed: 3` with 26 spurious `MISSING-PATH-REL`. Fixed by mutating the gate **in place**
   inside a full-tree copy. The gate's own A4b comment documents this exact trap; it is why the
   variable is now `REPO_ROOT` and not `REPO`.
3. **Scratch cleanup (done).** My `--only phys3d_joints_free_ops` run caused 21 `r90bt_free_ops_*`
   directories to appear under `corpus/fixtures/` — a protected tree. I removed them; the 19
   correct copies live inside the run's own `scratch/`. Verified:
   `git status --porcelain corpus/fixtures/` → only the peer's intended `three/README.md` edit,
   `find corpus/fixtures -maxdepth 1 -name 'r90bt*'` → **0**. **No tracked file under
   `corpus/fixtures/` was modified by this seat.** Note the same class of stray dirs appeared
   again at 15:35 from a *concurrent* peer probe — the fixture tree is not write-isolated while the
   round is live, which is itself worth the L1's attention.

Scratch artifacts live outside the repo at `/home/vgpnk/advgate-r103/` (45 MB at close, down from
154 MB after pruning the per-attack copies) because `/tmp` hit ENOSPC (3.5 G free on a 16 G tmpfs)
and a peer seat wiped `/tmp/advgate` mid-round, taking `verify_installed.sh` with it. The 11-attack
suite was **rebuilt** from the method in `reports/round-102/gate/adversary-a.md` §"The hardened
variant" rather than reused. Nothing in this directory is a repo file and no finding depends on it
surviving.

---

## 5. What this table does **not** claim

- **No Unreal runtime claim.** The editor is not installed; `verified-here=0` in the census is
  correct and no row above moves it.
- **The gate verdict is a snapshot, not a certificate.** `GATE RESULT: PASS` at 18:41:39Z is three
  identical consecutive readings of revision `577c8b54…`. During the window the same gate read
  `FAIL` once, over a peer artifact that had not been written yet. The three checks that measure
  *frozen* artifacts (manifest bytes, clone equivalence, card set + names) passed on **all four**
  gate revisions; only the check that reads the round's own in-flight prose moved.
- **`POINTERS` is scanner-relative.** The count is 87 → 101 across the window because both the
  scanner and the tree changed. `UNRESOLVED=0` at a quiesced tree is the binding invariant
  (r102's own recorded calibration datum); a bare `POINTERS=` number is under-specified.
- **Item 4 is marked PARTIAL, not DONE.** The `/tmp` → vendored pointer repair is a *note* over 10
  surviving historical hits, which is the round's stated discipline, not an in-place sweep. Whether
  that satisfies C1 is the adjudicator's call.
