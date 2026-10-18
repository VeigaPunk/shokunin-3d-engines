# r104 SEAT-42 — SEATS-LEDGER

Question put to this seat: **did any r104 seat write a protected path?** Protected set as
declared for r104: `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `SKILL.md`,
anything under `corpus/fixtures/` (**except** SEAT-04's two declared files,
`corpus/fixtures/phys3d_joints.gd` and `corpus/fixtures/run_battery.py`),
`corpus/knowledge/unreal-mcp/upstream/**`,
`corpus/knowledge/unreal-mcp/.manifest.d/**`, `reports/round-101/**`,
`reports/round-102/**`, `reports/round-103/**`.

Answer: **no. Every protected path is byte-identical to HEAD, and no r104 seat has yet
modified SEAT-04's two files either.** All r104 work observed sits inside the untracked
`reports/round-104/` round directory.

- HEAD under test: `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e`
  (`r103 report-last: verdict … — work 8c9d9ad`; committed `2026-10-18T16:13:38-03:00`)
- Snapshot timestamps (UTC): `2026-10-18T19:17:00Z` (first walk),
  `2026-10-18T19:17:34Z` (confirming walk), `2026-10-18T19:17:52Z` /
  `19:18:05Z` (final re-check after peer seats landed more work — verdict unchanged)
- Method: **per-blob comparison.** For every tracked file in every protected tree,
  `git hash-object -- <path>` on the worktree vs `git rev-parse HEAD:<path>`. Strictly
  stronger than mtime or `git diff --name-only`: it catches modification, deletion *and*
  restoration (an edit that puts a file back the way it was, or an edit that preserves
  size, cannot hide). Supplemented by `git diff --quiet`, an untracked/ignored addition
  sweep, and an independent `sha256sum -c` against the committed upstream manifest.
- No writes by this seat outside `reports/round-104/seats-ledger.md`. Every command below
  is read-only.

## 1. Protected root files — PASS

```
$ for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f")
    printf '%-14s %s\n' "$f" "$([ "$wt" = "$hb" ] && echo MATCH || echo "DIFFER wt=$wt head=$hb")"
  done
LOG.md         MATCH
SCORECARD.md   MATCH
SHONEN.md      MATCH
PROVINCE.md    MATCH
```

Independent sha256 of the worktree copies, for cross-seat reproduction, plus the
proof that each equals the committed blob rather than merely *some* stable value:

```
$ sha256sum LOG.md SCORECARD.md SHONEN.md PROVINCE.md
033ec85fe536a7586d36b76432c85da85972d92bf04bc75bcce11c35257e7462  LOG.md
5083eee2040d72c2acfb11eebc77d4e9dc97b5246582a731bef272e347df5cc4  SCORECARD.md
b44667ff4f0d4cfd8700eab2523b97ba3b254e440abde06d4214e9834d6a6062  SHONEN.md
1932f0fd7103dcc33e0b0c9f835adfe681e6ce4d765d4673bcc925c5d8230eac  PROVINCE.md

$ git show HEAD:LOG.md | sha256sum
033ec85fe536a7586d36b76432c85da85972d92bf04bc75bcce11c35257e7462  -
$ git show HEAD:SCORECARD.md | sha256sum
5083eee2040d72c2acfb11eebc77d4e9dc97b5246582a731bef272e347df5cc4  -
```

`LOG.md` / `SCORECARD.md` were last written by `88c3b2c` itself (worktree mtime
`2026-10-18 16:13:01 -0300`, one second before that commit's `16:13:38`). `SHONEN.md` /
`PROVINCE.md` date to `a6b944d` (2026-10-13) with worktree mtime `2026-10-13 16:40:46
-0300`; both predate the r104 start. mtime is context only — the blob ids are the
evidence.

`SHONEN.md` box 1 remains `[ ]` (verified in this sweep's read of the file), consistent
with the r104 C3 claim landing the decision table *into* `SKILL.md` rather than ticking
the box.

## 2. `SKILL.md` — PASS (no lane-level file exists; the claim's target is still absent)

```
$ ls SKILL.md
ls: cannot access 'SKILL.md': No such file or directory

$ find . -path ./.git -prune -o -name 'SKILL.md' -print \
    | grep -v 'corpus/knowledge/unreal-mcp/upstream' \
    | grep -v 'reports/round-104/gate/scratch'
(no output)
```

Every other `SKILL.md` on disk is a copy, not a lane artifact:

- 3 vendored files under the pinned upstream tree (§3 covers them) —
  `upstream/skills/{unreal-mcp,unreal-skill,create-toolset}/SKILL.md`;
- 3 more inside this round's own untracked scratch clone
  `reports/round-104/gate/scratch/c85a816/corpus/knowledge/unreal-mcp/upstream/skills/*/SKILL.md`
  (a seat-40 snapshot of the same upstream tree).

**Hazard note for whoever verifies C3.** A bare `find . -name SKILL.md` now returns hits
from untracked round scratch, and during this sweep a further 60-file untracked clone
`.r104seat43/` (its own `fresh.git/`, `tree/`, and `skills/*/SKILL.md` copies) existed at
the repo root and was removed again mid-sweep. Any future "no `SKILL.md` outside upstream"
check must either anchor to `git ls-files` or exclude `reports/round-104/**` and
dot-directories; a naive filename walk will read a scratch copy as a lane write.

## 3. Protected subtrees — PASS, zero differing, zero missing

```
$ for d in corpus/fixtures corpus/knowledge/unreal-mcp/upstream \
           corpus/knowledge/unreal-mcp/.manifest.d \
           reports/round-101 reports/round-102 reports/round-103; do
    # walk every blob in `git ls-tree -r HEAD -- "$d"`, compare worktree blob id
  done
corpus/fixtures                            identical=146   differing=0   missing=0
corpus/knowledge/unreal-mcp/upstream       identical=12    differing=0   missing=0
corpus/knowledge/unreal-mcp/.manifest.d    identical=12    differing=0   missing=0
reports/round-101                          identical=33    differing=0   missing=0
reports/round-102                          identical=61    differing=0   missing=0
reports/round-103                          identical=61    differing=0   missing=0
```

No `DIFFER` and no `MISSING` line was emitted in any walk. The single `git diff` form
agrees:

```
$ git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
    reports/round-101 reports/round-102 reports/round-103
protected-diff-exit=0
```

Subtree object ids under HEAD, so a later re-run can be anchored to the same values:

```
corpus/fixtures                            88ed60d3d97526941b2cc9c6ea23a02cd98ed507
corpus/knowledge/unreal-mcp/upstream       b5b9624b00fc90217240e823406699d0ab78b959
corpus/knowledge/unreal-mcp/.manifest.d    87bde5b7bc9517664cfbdae46d3cfeaded62e3e2
reports/round-101                          a28869fcf749c34fbd91edc485afde86fae37841
reports/round-102                          92d4dc84dd979ecff01fe050436811c43453ada8
reports/round-103                          739f668f55316ac36c5c04487a20a3e5f8b789f5
```

Note that `corpus/fixtures` object id moved from r103's ledger value
(`4ebcc2db628de576904fe54ae1d8037d499b19c1`) — that is the **r103 B2 conformance
repair** to `corpus/fixtures/three/README.md` (doc-only, `17 insertions/17 deletions`),
which `88c3b2c` recorded in `LOG.md` as a ruled-accepted defect. It is inside HEAD, not
an r104 write, and the r104 worktree matches it byte for byte.

The upstream pin is unchanged and verifies against the vendored bytes independently of
git:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
manifest-rc=0        # 12/12 OK, rc 0
```

`audit-reference.sha256` header still records `pinned SHA:
a6aa73ada02a9fb1f5415bec491f9942c519b297 (main)`, matching the round's declared pin.

## 4. No additions smuggled into a protected tree

A tracked-file walk would miss a *new* file dropped into a pinned directory, so untracked
and gitignored files were enumerated there explicitly:

```
$ git ls-files --others --exclude-standard -- \
    LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
    reports/round-101 reports/round-102 reports/round-103
(none — rc 0, no output)

$ git ls-files --others --exclude-standard -- corpus/
(none — rc 0, no output)

$ git status --porcelain=v1 --untracked-files=all | grep -v '^?? reports/round-104/'
(none — count 0)
```

Ignored-but-present files inside `corpus/fixtures/` are unchanged build/test residue and
predate r104; they are not seat writes to pinned fixtures:

```
$ git ls-files --others --ignored --exclude-standard -- corpus/fixtures | head -3
corpus/fixtures/__pycache__/run_battery.cpython-314.pyc
corpus/fixtures/three/node_modules/.package-lock.json
corpus/fixtures/three/node_modules/three/LICENSE
```

The newest non-ignored tracked file in `corpus/fixtures/` is `three/README.md` at
`2026-10-18 15:35:34 -0300` (the r103 B2 repair, pre-r104 and byte-identical to HEAD);
everything else there is `2026-10-16` or older.

## 5. Whole-worktree surface — the only delta vs HEAD is untracked `reports/round-104/`

```
$ git status --porcelain=v1 --untracked-files=no
(empty)

$ git diff --cached --quiet HEAD ; echo staged-exit=$?
staged-exit=0

$ git status --porcelain=v1 --untracked-files=no | grep -cE '^( ?D|D )'
0
```

So: **no modified tracked file, no staged change, no deletion, anywhere in the lane.**
The entire non-clean surface is untracked files under `reports/round-104/`:

```
$ git status --porcelain=v1 --untracked-files=all | awk '{print $2}' | cut -d/ -f1-2 | sort | uniq -c
    817 reports/round-104
```

That count grew during this sweep (199 → 502 → 817 untracked paths) as peer seats ran the
full battery, the concurrency probes and the gate attacks. Growth is confined to
`reports/round-104/`, which is the round's declared scratch space. Observed in-round
subdirectories at the last snapshot: `gate/` (incl. `gate/scratch/`, `flake_harness.sh`),
`physics/` (incl. `runs/`, `runs-clean/`, `s06/{serial,conc}/`, `standalone/`),
plus top-level `freshness-pin.md`, `ledger-check.md`, `kimi-404-carry.md`. `git check-ignore`
returns rc 1 for these, i.e. they are genuinely untracked and visible to `git status` —
not hidden behind an ignore rule.

Also observed and outside every protected tree: a transient root-level dot-directory
`.r104seat43/` (60 untracked files: `fresh.git/`, `tree/`, `hooks/`, `skills/*/SKILL.md`,
`README.md`, `LICENSE`, `CODEOWNERS`, `.claude-plugin/plugin.json`) belonging to another
r104 seat's fresh-clone sandbox. It touched no tracked path and was gone by the final
snapshot. `.gitignore` does not cover it (`check-ignore` rc 1).

## 6. SEAT-04's declared scope — untouched at sweep time (expected)

C1 is a `corpus/fixtures/` code change, the round's only licensed fixture write. At every
snapshot of this sweep the two declared files still matched HEAD byte for byte:

```
$ for f in corpus/fixtures/phys3d_joints.gd corpus/fixtures/run_battery.py; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f")
    printf '%s wt=%s head=%s %s\n' "$f" "$wt" "$hb" "$([ "$wt" = "$hb" ] && echo MATCH || echo DIFFER)"
  done
corpus/fixtures/phys3d_joints.gd wt=3ce066a68d7dc8c6849b7198c19ef368063ad06a head=3ce066a68d7dc8c6849b7198c19ef368063ad06a MATCH
corpus/fixtures/run_battery.py   wt=dd2d9b74448afddb88dcf2da56008302eba8060d head=dd2d9b74448afddb88dcf2da56008302eba8060d MATCH
```

Pre-change sha256 anchors, so the post-change state can be diffed against them:

```
$ sha256sum corpus/fixtures/run_battery.py corpus/fixtures/phys3d_joints.gd \
            corpus/knowledge/unreal-mcp/gate/run_gate.sh \
            corpus/knowledge/unreal-mcp/gate/README.md
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73  corpus/fixtures/phys3d_joints.gd
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0  corpus/knowledge/unreal-mcp/gate/run_gate.sh
834f468ded21fcdf069ab378c2774298158f71a93954aef9ee0df86bd90927d2  corpus/knowledge/unreal-mcp/gate/README.md
```

`run_battery.py` sha `f456bd00…` matches the round's declared pre-change value; the CASES
table still holds **350 rows** (`len(re.findall(r'\n\s*\(\s*"', src))` → 350), and
`CASE_TIMEOUT_SECONDS = 20` is still the bound at `corpus/fixtures/run_battery.py:36`.
`run_gate.sh` sha `577c8b54…` matches the scanner id `gate/README.md:171` pinned for
`POINTERS=101`, so the gate is at its pre-C2 state and its documented pin is still
accurate. Both are consistent with C1/C2/C3 not having landed yet at the time of this
sweep.

SEAT-04's own before-run evidence lives inside its declared scratch
(`reports/round-104/physics/before-battery.{stdout,stderr}`, `physics/runs/…`), which is
the correct place for it — no pre-change copy was written over a fixture. One artifact
worth a glance during C1 verification: the scratch copies under
`reports/round-104/physics/s06/conc/` already carry a **changed** `phys3d_joints.gd`
(blob `13c9b1aa3123f08db2c79cfe1d47dcc7ae896309`, differing from HEAD's `3ce066a6…`),
i.e. a concurrent-arm experiment is in flight there. It is an untracked scratch copy, not
a write to `corpus/fixtures/`.

## 7. Verdict

| Protected path | Files walked | Differing | Missing | Additions | Verdict |
|---|---|---|---|---|---|
| `LOG.md` | 1 | 0 | 0 | 0 | clean |
| `SCORECARD.md` | 1 | 0 | 0 | 0 | clean |
| `SHONEN.md` | 1 | 0 | 0 | 0 | clean |
| `PROVINCE.md` | 1 | 0 | 0 | 0 | clean |
| `SKILL.md` (lane-level) | 0 exist | — | — | 0 | clean (none exists; C3 target still absent) |
| `corpus/fixtures/` | 146 | 0 | 0 | 0 | clean |
| ↳ SEAT-04 licensed files | 2 | 0 | 0 | — | untouched at sweep time |
| `corpus/knowledge/unreal-mcp/upstream/` | 12 | 0 | 0 | 0 | clean |
| `corpus/knowledge/unreal-mcp/.manifest.d/` | 12 | 0 | 0 | 0 | clean |
| `reports/round-101/` | 33 | 0 | 0 | 0 | clean |
| `reports/round-102/` | 61 | 0 | 0 | 0 | clean |
| `reports/round-103/` | 61 | 0 | 0 | 0 | clean |

**No r104 seat wrote a protected path.** The only r104 surface is the untracked
`reports/round-104/` round directory (§5) plus the transient `.r104seat43/` scratch clone.
No tracked file anywhere in the lane is modified, and no staged change or deletion exists.

## 8. Scope, overlap and point-in-time caveat

- Overlap: SEAT-26's `reports/round-104/ledger-check.md` covers `LOG.md` / `SCORECARD.md` /
  `SHONEN.md` / `PROVINCE.md` and the whole-tree tracked sweep, and records the same
  `SHONEN.md` blob `8d85902c19010deb4fa154e16a2c12ad56ff10d1` and `PROVINCE.md` blob
  `cde5e8f518bb05149ab62e4ea5aa44f547e8aa69` as this sweep (and as the r102 ledger-check).
  This seat adds `SKILL.md`, `corpus/fixtures/`, the upstream + manifest trees, rounds
  101/102/**103**, the addition/ignored sweep, and the licensed-scope check for SEAT-04.
  Both agree on every path they share.
- **Point-in-time caveat.** These are snapshots, not a lock. C1 (SEAT-04) is *supposed*
  to modify its two declared files after this seat's last walk, and C2/C3 are supposed to
  land `gate/` and a new `SKILL.md`. The authoritative close-time check is therefore the
  cheap pair below, run after the last work seat stops, expected to show **only** those
  declared deltas and nothing else:

```
$ git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d \
    reports/round-101 reports/round-102 reports/round-103 ; echo rc=$?
rc=0                                  # must stay 0

$ git diff --name-only HEAD -- corpus/fixtures
corpus/fixtures/phys3d_joints.gd      # and, only if the r104 design doc names it,
corpus/fixtures/run_battery.py        # are the ONLY admissible names here
```

If the second command ever prints a name outside those two, the round has a protected-path
violation regardless of how the file changed.
