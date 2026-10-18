# r104 SEAT-27 — GIT-HYGIENE

**Seat:** SEAT-27 `GIT-HYGIENE` · round r104 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-104/git-hygiene.md`). No other file was written by
this seat. Every command below is read-only; **no `git commit/push/checkout/reset` was run**, and
nothing was deleted or cleaned up.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**HEAD under test:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`r103 report-last`; work
`8c9d9ad`), branch `main`, **`ahead 6`** of `origin/main`. HEAD was re-read at the end of the
audit and is unchanged.
**Snapshot window:** `2026-10-18T16:16:20-03:00` → `2026-10-18T16:22:40-03:00`
(`16:16:20`–`16:22:40` local; `19:16:20`–`19:22:40` UTC).
**No Unreal runtime claim** is made anywhere in this file. The Unreal Editor is not installed on
this host and live-MCP behaviour is unproven by construction. Nothing here promotes an
`unproven-runtime` card.

---

## 0. Verdict

**4 violations — 3 undeclared scratch-tree writes outside a declared seat path (two of them
multi-gigabyte, one recursive) and 1 undeclared repo-root trace pair — plus 1 close-out risk and
5 observations for the L1.**
**Zero unattributable paths. Zero writes to a protected tree by an undeclared seat.**

| class | count | verdict |
|---|---|---|
| untracked path outside every declared seat path | 4 (`scratch/**`, `.r104-seat17/`, the `gate` + `physics` scratch subtrees, `trace.*`) | **VIOLATION — flagged (§3.1–§3.4)** |
| writes into a protected tree (`LOG`/`SCORECARD`/`SHONEN`/`PROVINCE`/`reports/round-101..103`/`upstream`/`.manifest.d`) | 0 | clean |
| tracked modification outside a declared seat path | 0 | clean |
| modified/untracked path with no seat attribution | 0 | clean |
| staged content / stash / lock / rebase state / worktree leak | 0 | clean |
| **untracked bulk that a `git add -A` at close would commit** | **2.0–5.7 GB, 59k–188k files** | **RISK — flagged (§3.5), highest-value item for the L1** |

The **three** tracked modifications (`corpus/fixtures/phys3d_joints.gd`, `gate/run_gate.sh`,
`gate/README.md`) and the one untracked repo-root deliverable (`SKILL.md`) are **authorized** — each
is named in the r104 dispatch roster for the seat that wrote it. Details in §2.

**The tree was mutating continuously throughout this audit** (§5) and the untracked count moved by
three orders of magnitude inside the window. Every number below is a **timestamped snapshot, not a
final state.** The L1 must re-run `git status --porcelain -uall` after the last seat exits, before
any commit.

---

## 1. Method — commands actually run

```sh
git rev-parse HEAD ; git rev-parse --abbrev-ref HEAD ; git rev-list --count origin/main..HEAD
git status --porcelain -uall                       # repeated 24x over 16:16:20–16:22:40
git status -sb
git status --porcelain -uall | grep -v '^??'        # modified/staged set
git status --porcelain -uall | grep -c '^??'        # untracked count
git status --porcelain=v1 --ignored=matching
git status --porcelain --ignored -uall | grep '^!!' | grep -vE 'corpus/(live|fixtures)/'
git diff --stat ; git diff --cached --stat ; git diff --numstat HEAD -- corpus/fixtures
git diff --numstat HEAD -- corpus/knowledge/unreal-mcp
git diff -- corpus/fixtures/phys3d_joints.gd
git diff -- corpus/knowledge/unreal-mcp/gate/run_gate.sh
git ls-files --others --exclude-standard                       # untracked, non-ignored
git ls-files --others --exclude-standard | grep -v '^reports/round-104/'
git ls-files --others --exclude-standard -- corpus/fixtures
git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md ; echo $?
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f"); done   # blob-id comparison
git diff --stat HEAD -- reports/round-101 reports/round-102 reports/round-103
git diff --stat HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
git diff --stat HEAD -- corpus/fixtures
for f in corpus/fixtures/phys3d_joints.gd corpus/fixtures/run_battery.py; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f"); done
git check-ignore -v <each untracked path under corpus/fixtures/>
git stash list ; git worktree list ; git reflog show HEAD
ls .git/index.lock .git/MERGE_HEAD .git/rebase-merge .git/rebase-apply .git/MERGE_RR
stat -c '%y %s %n' .git/index .git/MERGE_RR
find .git -type f -newermt '2026-10-18 16:13:40'      # writes to git metadata after the r103 commit
find .git/objects -type f -newermt '2026-10-18 16:13:40' | wc -l
git log --all --oneline -- SKILL.md                    # is the root SKILL.md ever tracked?
git ls-tree -r HEAD --name-only | grep -x 'SKILL.md'
sha256sum SKILL.md
du -sh reports/round-104 .r104-seat17 reports/round-104/scratch
find reports/round-104/scratch -type d -name 's20-skel*' | awk -F/ '{print NF}' | sort -u
find reports/round-104/gate/scratch -type f | wc -l    # and the same per scratch subtree
git ls-tree -r HEAD --name-only -- corpus/fixtures | wc -l
timeout 120 git fsck --no-progress
df -h /tmp /home /
ps aux | grep -iE 'git|godot|python3|bash' | grep -v grep
```

Attribution source for "which seat owns this path": the r104 dispatch roster, recovered from the
session wire log
`~/.kimi-code/sessions/wd_game-dev-3d-shokunin_1d5718ea9394/session_8fbb88db-7658-45d0-abaa-7216e4581191/agents/main/wire.jsonl`
(each `SEAT-NN ROLE → <path>` line, at wire line 1935), cross-checked against the seat header on
line 1 of each delivered report and against the author's own in-file seat comment. Where a report
names its own seat, that header is the primary evidence.

---

## 2. The authorized write set — full attribution

Three paths outside `reports/round-104/**` changed this round. All three are declared.

### 2.1 Modified — tracked (3)

Three tracked files changed this round, all declared. `gate/README.md` appeared at `16:23:58` —
after the §5 window closed — and is folded in here rather than left out.

| path | seat | role | declared scope in roster | in scope? |
|---|---|---|---|---|
| `corpus/fixtures/phys3d_joints.gd` | **SEAT-04** | `PHYS-AUTHOR` | *"SEAT-04's declared scope is exactly `corpus/fixtures/phys3d_joints.gd`"* (round brief); roster: *"implement the SEAT-01 design on the real files; minimal diff; run the free_ops arm `--only`; run the full phys3d suite"* | **yes — authorized exception** |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | **SEAT-12** | `GATE-WORKDIR-AUTHOR` | C2 = *"GATE_WORKDIR + TMPDIR support on `corpus/knowledge/unreal-mcp/gate/run_gate.sh`"* (round brief) | **yes** |
| `corpus/knowledge/unreal-mcp/gate/README.md` | **SEAT-12** | `GATE-WORKDIR-AUTHOR` | C2; the README is the same seat's documentation leg (*"GATE_WORKDIR + TMPDIR documented, exit codes 0/1/2 declared, hardening history appended"*, `SEAT-17 GATE-DOCS-SYNC`) | **yes — see note below** |

Diff sizes (`git diff --numstat HEAD`), all three verified by reading the hunks:

| path | + | − | shape |
|---|---|---|---|
| `corpus/fixtures/phys3d_joints.gd` | 26 | 7 | R3 concurrent children: `_run_child` split into `_spawn_child`/`_collect_child`, `OS.execute` → `OS.create_process` + `OS.is_process_running`/`get_process_exit_code`; nested-loop *collect* order preserved so the emitted stream is unchanged |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | 97 | 11 | `WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}` + up-front validation; both scratch sites moved under it; exit 0/1/2 vocabulary in the header comment |
| `corpus/knowledge/unreal-mcp/gate/README.md` | 79 | 2 | r104 hardening-history entry signed `SEAT-12 GATE-WORKDIR-AUTHOR`, a new "Running under quota pressure" section, and the re-pinned scanner sha `e5521304…` / `POINTERS=102` |

All three diffs are **in-round deliverables**, not drift:

- `phys3d_joints.gd` — this is claim **C1** itself. Its own new comment names the design:
  `# r104 R3 — spawn every (case, backend) child first, then collect in the original nested-loop
  order.` Only `_run_child` was renamed/split; the `r90bt_%s_%s_%s` dirname pattern, the pinned
  marker strings and the `BOUND_S`/`--` argument vector are untouched. `corpus/fixtures/run_battery.py`
  is **hash-SAME as HEAD** (`dd2d9b74…`), which is the byte-stability condition the brief set.
- `run_gate.sh` — claim **C2**. The in-code comment attributes it: `# Scratch root (r104, SEAT-12
  GATE-WORKDIR-AUTHOR)`, and cites the r103 root cause verbatim (`reports/round-103/gate/close-runs.md`,
  `error: copy-fd: write returned: Disk quota exceeded`).
- `gate/README.md` — the C2 documentation leg, self-attributed in the diff body: `**r104
  (2026-10-18, SEAT-12 GATE-WORKDIR-AUTHOR).** … This seat **reproduced both live** and fixed the
  class.` It also re-pins the gate's expected scanner sha (`577c8b54…` → `e5521304…`) and
  `POINTERS` (`101` → `102`), which is exactly the drift `SEAT-45 GATE-PIN-CHECK` and
  `SEAT-17 GATE-DOCS-SYNC` are charged to detect. **Note for the L1:** the round brief fixes C2's
  scope to `run_gate.sh`, so this README edit is authorized by *seat role* (the same seat owns both
  files' C2 legs) rather than by the brief's literal path list. r103 had an identical
  brief-vs-role tension over `corpus/fixtures/three/README.md` and ruled it "accepted, doc-only";
  the same ruling applies here. `POINTERS=102 ≠ 101` is a **documentation** re-pin, not a corpus
  change — §4.3 shows `upstream/` and `.manifest.d/` byte-stable.

`git check-ignore` confirms **none** of the three paths is ignored — all are real tracked
modifications, not
masked by `.gitignore`.

### 2.2 Untracked, repo root (1)

| path | seat | role | declared scope in roster | in scope? |
|---|---|---|---|---|
| `SKILL.md` | **SEAT-18** | `SKILL-AUTHOR` | *"SKILL-AUTHOR (owns SKILL.md ONLY): land the 'Unreal-content claim discipline' decision table … as a new SKILL.md section"* | **yes** |

```
$ git log --all --oneline -- SKILL.md
(empty)
$ git ls-tree -r HEAD --name-only | grep -x 'SKILL.md'
NOT IN HEAD
$ stat -c '%y %s' SKILL.md
2026-10-18 16:19:31 -0300  18759
$ sha256sum SKILL.md
1055a52f570410e16f35c5d2384a36382e66568964e4d530cce914443e9fb66c  SKILL.md
$ grep -c '^|' SKILL.md ; grep -n 'Unreal-content claim discipline' SKILL.md
29
20:## 1. Unreal-content claim discipline — decision table
```

This is claim **C3**. The file is a **first-add, not an edit** — it has never existed in this
repo's history (`git log --all` empty, not in `HEAD`), which matches the r102 draft's own note
(*"`SKILL.md` does not exist in this lane (shonen seed form, `README.md:10-11`)"*,
`reports/round-102/skill-decision-table-draft.md`). The drafted table landed as §1 with 29 table
rows. **Not gitignored** — the L1 must `git add SKILL.md` explicitly (§3.5).

### 2.3 Untracked, `reports/round-104/**` — seat deliverables

Every untracked file directly under `reports/round-104/**` (i.e. excluding the scratch subtrees
condemned in §3) is a declared seat artifact. Files present at the final frame:

```
freshness-pin.md          gate/final-run.md         gate/flake_harness.sh    gate/pin-check.md
gate/workdir-verify.md    install-recheck.md        kimi-404-carry.md        ledger-check.md
physics/before.md         physics/markers.md        physics/seeds.md         physics/sentinel.md
r104-report.md            seats-ledger.md           skill/author.md          stub-cleanness.md
subtree-integrity.md      lessons-carry-gate-default-tmpdir.out
physics/before-battery.stdout  physics/before-battery-clean.stdout  physics/author-full.stdout
```

Each maps 1:1 to a roster line (`SEAT-43 FRESHNESS-PIN → reports/round-104/freshness-pin.md`,
`SEAT-40 GATE-FINAL-RUN → …/gate/final-run.md`, `SEAT-41 SUBTREE-INTEGRITY → …/subtree-integrity.md`,
and so on). **Zero unattributable paths.** The two seats that were mid-flight at the final frame
(`SEAT-19/20/21 SKILL-*`, `SEAT-22 DISSONANCE`, `SEAT-25 MATH-AUDIT`, `SEAT-28/29/30/31/32`) had
not yet written their files, which is expected and not a defect.

---

## 3. Violations and flags

### 3.1 VIOLATION — `reports/round-104/scratch/**`: undeclared, recursive, multi-gigabyte scratch inside the repo

**Observed.** A `reports/round-104/scratch/` tree that **no r104 roster line declares**. It grew
from nothing to a peak of **5.3 GB / 305,448 files**, then shrank again as the owning seats
cleaned up. Subtrees, largest first:

```
$ du -sh reports/round-104/scratch/*
4.1G  reports/round-104/scratch/s20-skel3        # SEAT-20 SKILL-CRITIC
489M  reports/round-104/scratch/s20-skel2        # SEAT-20
 11M  reports/round-104/scratch/seat37-runs      # SEAT-37
 11M  reports/round-104/scratch/seat37-full      # SEAT-37
 11M  reports/round-104/scratch/seat37-after     # SEAT-37
  0   reports/round-104/scratch/s20-tmp
```

**The `s20-skel3` tree copied itself.** The nesting is the smoking gun:

```
$ find reports/round-104/scratch -type d -name 's20-skel*'
reports/round-104/scratch/s20-skel3
reports/round-104/scratch/s20-skel3/reports/round-104/scratch/s20-skel
reports/round-104/scratch/s20-skel3/reports/round-104/scratch/s20-skel2
reports/round-104/scratch/s20-skel3/reports/round-104/scratch/s20-skel3
$ find reports/round-104/scratch -type d -name 's20-skel*' | awk -F/ '{print NF}' | sort -u
4
8
```

A copy of the repo placed *inside* the tree it was copying — the classic unbounded self-copy. The
depth-8 entry is `s20-skel3/reports/round-104/scratch/s20-skel3/reports/round-104/scratch/…`.
That is what produced the 305k-file peak and the control-character filenames below.

**Control-character filenames** are present inside the same tree (intentional sentinel probes, but
they make any bulk `git add` or `tar` hostile to tooling):

```
?? "reports/round-104/scratch/s20-skel3/corpus/live/r101-sentinel/probes/cc_231731/a\nb.uproject"
?? "reports/round-104/scratch/s20-skel3/corpus/live/r101-sentinel/probes/cc_51d155/a\rb.uproject"
?? "reports/round-104/scratch/s20-skel3/corpus/live/r101-sentinel/probes/cc_610f87/a\tb.uproject"
?? "reports/round-104/scratch/s20-skel3/corpus/live/r101-sentinel/probes/cc_8860db/a\001b.uproject"
?? "reports/round-104/scratch/s20-skel3/corpus/live/r101-sentinel/probes/cc_a6b6e9/a\\x01b.uproject"
```

**Owning seat.** `s20-*` names **SEAT-20 `SKILL-CRITIC`** (roster: *"SKILL-CRITIC → reports/round-104/skill/critic.md"*);
`seat37-*` names **SEAT-37**; `s22tmp/` names **SEAT-22**; `tmp.O08ANPOIb9/` and `.seat44/` are
mktemp-style leftovers from SEAT-08/SEAT-44. Peer transcripts in the wire log confirm the naming
convention (`agents/agent-211`, `agent-218`, `agent-219` all reference `s20-skel`). The seat's
**declared** write target is a single `.md` file; none of these trees is declared.

**Why it matters even though it is "only" scratch.** (a) It sits inside the repo, so it is inside
the blast radius of the close-out commit; (b) it is **not gitignored** (§3.5); (c) r102 and r103
both kept seat scratch in `/tmp` (`/tmp/r102mut`, `/tmp/advgate`, `~/scratch-r104`), so this is a
**new** convention introduced this round without a ruling.

### 3.2 VIOLATION — `.r104-seat17/`: a full lane clone written at the repo root by SEAT-17

**Observed.** At `16:19:03`–`16:19:15` a directory `.r104-seat17/` appeared at the repository root
and grew to **1.3 GB / 92,582 files** — a complete copy of the lane tree plus a fresh upstream
clone:

```
$ du -sh .r104-seat17            # peak
1.3G  .r104-seat17
$ find .r104-seat17 -type f | wc -l
92582
$ ls .r104-seat17/ ; ls .r104-seat17/lane/
clean.out
lane
corpus
reports
$ ls -d .r104-seat17/lane/.git
ls: cannot access '.r104-seat17/lane/.git': No such file or directory
```

The seat's own gate receipt names the working root it built:

```
$ grep -m1 SUBTREE .r104-seat17/clean.out
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.r104-seat17/lane/corpus/knowledge/unreal-mcp
```

**Owning seat.** **SEAT-17 `GATE-DOCS-SYNC`**, whose declared path in the roster is exactly
`reports/round-104/gate/docs-sync.md` — *"README matches reality: GATE_WORKDIR + TMPDIR documented,
exit codes 0/1/2 declared, hardening history appended (r104 entry), expected POINTERS value
current; flag drift."* To diff the gate's behavior on a clean tree, the seat cloned the whole lane
**inside** the lane, at the repo root, under a name that is **not gitignored**. Peer seats saw it
and correctly refused to touch it (`agent-196`: *"`.r104-seat17/` is another seat's workdir. Not
mine."*).

**State at the final frame.** Almost all of it was removed by the owning seat; only one file
survives:

```
$ du -sh .r104-seat17 ; find .r104-seat17 -type f
4.0K  .r104-seat17
.r104-seat17/clean.out
```

That survivor is itself undeclared, non-ignored, and inside the commit's blast radius. It should be
removed (or the whole directory ignored) before the close commit — **not by this seat**, which owns
only this report.

### 3.3 VIOLATION — `trace.out` / `trace.err` at the repo root

**Observed.** For roughly two minutes (`16:20:57`–`16:22:29`) two undeclared files sat at the
repository root, produced by `bash -x` instrumentation of the gate:

```
$ ls -la trace.out trace.err
-rw-r--r-- 1 vgpnk vgpnk 86263 Oct 18 16:20 trace.err
-rw-r--r-- 1 vgpnk vgpnk  2102 Oct 18 16:20 trace.out
$ head -3 trace.out
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
$ sed -n '1,3p' trace.err
+ set -u
+ for _t in git sha256sum grep find sort comm
+ command -v git
```

The `+ set -u` / `+ command -v …` trace lines are `set -x` output from `run_gate.sh` — i.e. a seat
ran the gate under `bash -x` with the trace redirected to **repo-root relative paths** instead of
into its own scratch. Gone by `16:22:40`. Owner not attributable to a single seat number (several
gate seats were active; `agent-211/213/214/218/223` all reference `trace.out`), so this is reported
at **lane level**, same convention r103 used for its unattributable fixtures write.

### 3.4 VIOLATION — `reports/round-104/{gate/scratch,physics/runs*,physics/s06,physics/standalone,lessons-carry-loop,seat33-loop}/**`: undeclared scratch, none of it ignored

Beyond `scratch/` (§3.1), five more scratch subtrees live under the round directory. None is
declared by any roster line, and **none is gitignored**:

```
$ for p in reports/round-104/gate/scratch reports/round-104/physics/runs \
           reports/round-104/physics/s06 reports/round-104/seat33-loop; do
    git check-ignore -v "$p" >/dev/null 2>&1 && echo "IGNORED $p" || echo "NOT-IGNORED $p"; done
NOT-IGNORED reports/round-104/gate/scratch
NOT-IGNORED reports/round-104/physics/runs
NOT-IGNORED reports/round-104/physics/s06
NOT-IGNORED reports/round-104/seat33-loop
```

File counts at the widest frame:

```
    959 reports/round-104/gate/scratch        # gate seats 13/14/15/16/17/40/45/48
    172 reports/round-104/physics/runs        # SEAT-04/05/06
    170 reports/round-104/physics/runs-clean
   1864 reports/round-104/physics/s06         # SEAT-06 DETERMINISM-ADVERSARY
      2 reports/round-104/physics/standalone
      0 reports/round-104/seat33-loop
```

These are *legitimate evidence* — the gate scratch holds the clean-tree clone and attack suites, and
`physics/s06/` holds the serial-vs-concurrent byte comparison. The violation is **placement +
declaration**, not existence: they belong in a declared, ignored scratch root, not in the
committable round directory. See §3.5 for the concrete consequence.

### 3.5 RISK (highest-value item) — the close-out `git add` has a 2–5.7 GB minefield in it

Everything in §3.1–§3.4 is **untracked and not gitignored**. `reports/round-104/` measured
**2.0 GB → 5.7 GB** during the window, and the widest single frame was **188,831 untracked
entries**. A reflexive `git add -A` (or `git add reports/`) at close would stage, among real
deliverables:

- `reports/round-104/gate/scratch/full-c85a816/corpus/fixtures/r95vendor/pybullet.cpython-314-x86_64-linux-gnu.so` — **7,063,864 B**
- the same `.so` again under `physics/{runs,runs-clean,s06/serial,s06/conc,standalone/scratch2}/`
- `r94vendor/three.core.js` (**1,458,113 B**) and `three.module.js` (**662,772 B**), five times each
- a full copy of `reports/round-101|102|103` inside `gate/scratch/full-c85a816/`
- the recursive `s20-skel3` tree and its control-character filenames

`git fsck --no-progress` reported only **3 dangling blobs** (no corruption), so the repo itself is
healthy — but this is the round where a careless add becomes irreversible history. **Recommended
action for the L1:** add `reports/round-104/scratch/` and the `*/scratch/` scratch roots to
`.gitignore` (or delete them) and stage the seat deliverables **explicitly by path** — in
particular `SKILL.md`, which is a first-add and will otherwise be silently left behind if the add
is scoped to `reports/`.

---

## 4. Protected-path verification — PASS

All four protected checks are green at every snapshot in the window.

**4.1 Ledger files unchanged** — blob-identity, not just a clean `git diff`:

```
$ for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f")
    [ "$wt" = "$hb" ] && echo "SAME $f" || echo "DIFF $f"; done
SAME LOG.md
SAME SCORECARD.md
SAME SHONEN.md
SAME PROVINCE.md
```

No r104 roster line names any of these four paths. The r103 LOG entry (*"ROUTED (r104+): physics
fix R3 concurrent children … gate workdir resilience (GATE_WORKDIR/TMPDIR); flake-reproduction
harness"*) correctly predicted this round's C1/C2 and stayed untouched while they were implemented.

**4.2 Prior rounds untouched:**

```
$ git diff --stat HEAD -- reports/round-101 reports/round-102 reports/round-103
(empty)
```

**4.3 The pinned subtree is byte-stable:**

```
$ git diff --stat HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
(empty)
```

`gate/run_gate.sh` and `gate/README.md` are the only files modified anywhere under
`corpus/knowledge/unreal-mcp/` — both are C2's own deliverable (implementation + documentation),
both signed `SEAT-12`. The pinned `upstream/` tree and the `.manifest.d/` audit reference are
untouched, which is exactly what the round brief requires (*"the physics work must NOT touch the
subtree"*).

**4.4 Fixture code pinned:**

```
$ for f in corpus/fixtures/phys3d_joints.gd corpus/fixtures/run_battery.py; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f"); done
corpus/fixtures/phys3d_joints.gd wt=e9c94b4f608170ce5d1c16b511eff18766ffc6b2 HEAD=3ce066a68d7dc8c6849b7198c19ef368063ad06a DIFF   # SEAT-04, authorized
corpus/fixtures/run_battery.py   wt=dd2d9b74448afddb88dcf2da56008302eba8060d HEAD=dd2d9b74448afddb88dcf2da56008302eba8060d SAME
$ git diff --numstat HEAD -- corpus/fixtures
26      7       corpus/fixtures/phys3d_joints.gd
```

**`run_battery.py` is byte-identical to HEAD** — the 350-row `CASES` table and the pinned marker
strings cannot have moved, which is the invariance SEAT-09 `SEED-CHECK` was charged to prove. The
brief authorized **only** `phys3d_joints.gd` (+ `run_battery.py` *if the design doc named it*); the
design doc did not, and the file is untouched. **No r104 seat wrote into `corpus/fixtures/`
outside that single authorized file.**

**4.5 The r103 fixtures-write class did NOT recur.** r103 §3.1 flagged 42–44 non-ignored
`corpus/fixtures/r90bt_*` files created by pointing Godot's `--path` at the *seed tree* instead of a
scratch copy. This round:

```
$ ls -d corpus/fixtures/r90bt_* 2>/dev/null | wc -l
0
$ git ls-files --others --exclude-standard -- corpus/fixtures | wc -l
0
```

Zero. The runner was driven correctly all round. Worth noting that the C1 patch itself **reduces**
this hazard's blast radius: `_spawn_child` still derives its directory from `res://`, but it now
fails fast (`return {"err": "spawn failed"}` on `pid <= 0`) instead of writing a half-populated
child tree before erroring.

---

## 5. The tree was mutating throughout the audit

`git status --porcelain -uall` returned a different count at almost every read — and unlike r103,
where the peak was 52, this round's peak was **188,831**. Recorded so the L1 can calibrate how stale
any hygiene snapshot is:

| wall clock (`-0300`) | untracked | what appeared |
|---|---|---|
| 16:16:20 | 1 | `reports/round-104/` (empty skeleton) |
| 16:16:33 | 173 | + `physics/runs/2026…Z/scratch/**` (the C1 before-battery seeds) |
| 16:17:45 | 682 | + `gate/scratch/{baseline,seat40-*}`, `scratch/pin-clone` |
| 16:18:05 | 839 | + `gate/scratch/{out,loop,full-c85a816}` |
| 16:18:15 | 1645 | + `full-c85a816/` deep copy (whole lane) |
| 16:18:35 | 1717 | + `physics/s06/{serial,conc}` |
| **16:19:03–15** | — | **`.r104-seat17/` clone appears (92,582 files)** |
| 16:19:55 | 4594 | + `.r104-seat17/lane/**`; `reports/round-104/scratch/` first seen |
| 16:20:16 | 5835 | **`corpus/fixtures/phys3d_joints.gd` modified** (SEAT-04 patch lands) |
| 16:20:24 | 5916 | `gate/run_gate.sh` modified (SEAT-12) |
| 16:20:36 | 4088 | `.r104-seat17/` cleaned by its owner; `SKILL.md` appears (SEAT-18) |
| 16:20:57 | 4705 | + `trace.out` / `trace.err` at repo root |
| **16:21:44** | **188,831** | **peak — `s20-skel3` recursive self-copy (5.7 GB)** |
| 16:22:10 | 166,063 | owner cleaning up; `s20-skel3` shrinking |
| 16:22:29 | 140,913 | `trace.*` gone |
| 16:22:40 | 59,383 | `reports/round-104/scratch` down to 2.0 GB |
| 16:23:58 | 7,868 | scratch fully cleaned; **`gate/README.md` modified** (SEAT-12, C2 docs leg) |

Two consequences the L1 must internalise:

1. **No point-in-time count from this round is meaningful.** The numbers span four orders of
   magnitude *for the same repo* inside six minutes. Report the range.
2. **Modified-file count was stable at 0 → 1 → 2 → 3 and never higher.** The only tracked
   modifications all round were `phys3d_joints.gd`, `run_gate.sh` and `gate/README.md`, all
   authorized. Everything else was untracked scratch churn.

The scratch actually did get cleaned up by its owners — by `16:23:58` the untracked count was back
to **7,868** and `reports/round-104/scratch/` was gone. That does **not** retire §3.5: the peak was
real, it lasted minutes, and the L1's `git add` happens after the last seat exits, so a
careless add executed during a *future* peak is the same hazard. The `.gitignore` hardening in §3.5
is still the recommendation.

---

## 6. Repo-level state — all clean

```
$ git rev-parse HEAD
88c3b2ca70fc83ec47a931d7b6dcff85a111c04e                 # unchanged from the start of the audit
$ git status -sb | head -1
## main...origin/main [ahead 6]
$ git diff --cached --name-only
(empty)                                                   # nothing staged
$ git stash list
(empty)
$ git worktree list
/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin 88c3b2c [main]      # single worktree, no leak
$ ls .git/index.lock .git/MERGE_HEAD .git/rebase-merge .git/rebase-apply
ls: cannot access '.git/index.lock': No such file or directory
ls: cannot access '.git/MERGE_HEAD': No such file or directory
ls: cannot access '.git/rebase-merge': No such file or directory
ls: cannot access '.git/rebase-apply': No such file or directory
$ find .git/objects -type f -newermt '2026-10-18 16:13:40' | wc -l
0                                                         # no git writes after the r103 commit
$ timeout 120 git fsck --no-progress
dangling blob f88943e4a9af5bcdcd5aa4b2e7627cc48349e628
dangling blob 82f4c3d57d79b6327a81e1f2a298f5e6197bdf13
dangling blob 0a1f853902a0b30ba72bb044a25b6cee93c76992
```

`ahead 6` is the same distance r103 closed at — the r104 work commit has not been made yet, as
expected. Three dangling blobs are inert (normal for a repo with `git hash-object` comparisons in
its audit history); no corruption.

**`.git/MERGE_RR`** exists but is a **0-byte file dated `16:13:38.879`, the same second as the r103
commit** (`git log -1 --format=%cd HEAD` → `16:13:38`). It is a leftover of the merge/rerere
machinery from the *r103* commit, **not** r104 activity, and it carries no conflict state.
Observation, not a violation.

---

## 7. Observations for the L1 (not violations)

1. **`.gitignore` has no entry for round scratch.** `corpus/.gitignore` covers `live/`,
   `__pycache__/`, `*.pyc`; there is no root `.gitignore` at all. Every scratch root this round
   (§3.1–§3.4) landed in committable space. A one-line `reports/round-*/scratch/` (plus
   `**/gate/scratch/`) entry would have prevented the entire §3.5 risk. This is the single cheapest
   hardening available next round.
2. **A new scratch convention appeared without a ruling.** r102 used `/tmp/r102mut`, r103 used
   `/tmp/advgate` and `~/scratch-r104`; r104 put scratch **inside the repo** in five different
   ad-hoc names (`.r104-seat17/`, `.r104-seat43/`, `.r104-seat44/`, `reports/round-104/scratch/`,
   `reports/round-104/{gate,physics}/*/`). Two of those were full lane clones. The C2 work is
   *itself* about scratch placement — the irony is worth a LOG LAW.
3. **SEAT-17's clone was motivated by the right instinct, executed in the wrong place.** The seat
   needed a clean-tree baseline to verify the README's pinned `POINTERS=101`. `git clone` into the
   repo root is the one way to do that which also contaminates the repo. `/tmp` or
   `$GATE_WORKDIR` — the very variable C2 added — was the correct target.
4. **The control-character probe filenames are intentional but hazardous.** `a\nb.uproject`,
   `a\rb.uproject`, `a\tb.uproject`, `a\001b.uproject`, `a\x01b.uproject` inside `s20-skel3` are
   sentinel probes for path-handling attacks. They are legitimate test inputs, but they break
   `tar`, naive `git add -A`, and most shell loops. Keep them under a declared, ignored scratch
   root.
5. **`/tmp` is still at 80% (13 GB of 16 GB).** The C2 root cause is live and unchanged:
   `df -h /tmp` → `tmpfs 16G 13G 3.1G 80% /tmp`. Independent of this round's hygiene verdict, the
   gate's new `GATE_WORKDIR` escape hatch is still needed, and the *other* tools on this host that
   use bare `mktemp` are still exposed. Worth carrying as a routed item.

---

## 8. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# 0. identity
git rev-parse HEAD ; git rev-parse --abbrev-ref HEAD ; git rev-list --count origin/main..HEAD

# 1. the two authorized modifications
git status --porcelain -uall | grep -v '^??'
git diff --numstat HEAD -- corpus/fixtures corpus/knowledge/unreal-mcp
git hash-object corpus/fixtures/run_battery.py ; git rev-parse HEAD:corpus/fixtures/run_battery.py

# 2. the third authorized write (first-add)
git log --all --oneline -- SKILL.md            # empty => never tracked
git ls-tree -r HEAD --name-only | grep -x 'SKILL.md' || echo "NOT IN HEAD"
sha256sum SKILL.md

# 3. protected paths
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
    [ "$(git hash-object -- $f)" = "$(git rev-parse HEAD:$f)" ] && echo "SAME $f" || echo "DIFF $f"; done
git diff --stat HEAD -- reports/round-101 reports/round-102 reports/round-103
git diff --stat HEAD -- corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d

# 4. the violations
git status --porcelain -uall | grep -v '^?? reports/round-104/'
ls -d .r104-seat17 .r104-seat43 .r104-seat44 trace.out trace.err 2>/dev/null
du -sh reports/round-104/scratch 2>/dev/null
find reports/round-104/scratch -type d -name 's20-skel*' | awk -F/ '{print NF}' | sort -u
for p in reports/round-104/scratch reports/round-104/gate/scratch reports/round-104/physics/runs \
         reports/round-104/physics/s06 .r104-seat17 SKILL.md; do
    git check-ignore -v "$p" >/dev/null 2>&1 && echo "IGNORED $p" || echo "NOT-IGNORED $p"; done

# 5. repo state
git status -sb | head -1 ; git diff --cached --name-only ; git stash list ; git worktree list
ls .git/index.lock .git/MERGE_HEAD .git/rebase-merge .git/rebase-apply 2>&1
stat -c '%y %s %n' .git/MERGE_RR
find .git/objects -type f -newermt '2026-10-18 16:13:40' | wc -l
timeout 120 git fsck --no-progress
```

---

## 9. Amendments to this file

- **`16:22:40`** — final snapshot of the §5 window written. §0 verdict, §3.1–§3.5, §5 table and
  §6 state reflect the last read in that window.
- **`16:23:58`** — one post-window read, after §5 closed. It found a **third** authorized
  modification (`gate/README.md`, SEAT-12) and that the scratch had been fully cleaned by its
  owners (untracked back to 7,868). §2.1, §0's attribution sentence and §5's closing paragraph were
  amended to match. **No further reads were taken after this point**; the tree continued to mutate
  (several seats were still mid-flight) and the L1 must re-run §8 before the close commit.

---

## 10. Seat-scope statement

This seat wrote **`reports/round-104/git-hygiene.md` and nothing else.** No file was created,
modified, moved or deleted by this seat; no cleanup was performed (the `.r104-seat17/` survivor,
`trace.*` and the scratch trees were all left exactly as found, for the L1 to rule on). No
`git commit`, `git push`, `git checkout`, `git reset`, `git stash`, `git add` or `git clean` was
run at any point. Every command in §1 and §8 is read-only. **No Unreal runtime claim is made in
this file.**
