# r103 SEAT-40 — GIT-HYGIENE

**Seat:** SEAT-40 GIT-HYGIENE · round r103 · lane `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-103/git-hygiene.md`). No other file was written by
this seat; every command below is read-only and no `git commit/push/checkout/reset` was run.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**HEAD under test:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (`r102 report-last`; work
`c6f655d`), branch `main`, `ahead 4` of `origin/main`. HEAD was re-read at the end of the audit
and is unchanged.
**Snapshot time:** `2026-10-18T15:37:34-03:00` / `2026-10-18T18:37:34Z` (container clock).
**No Unreal runtime claim** is made anywhere in this file. The Unreal Editor is not installed on
this host and live-MCP behaviour is unproven by construction. Nothing here promotes an
`unproven-runtime` card.

---

## 0. Verdict

**4 violations** — two of them transient scratch that self-cleared before this audit closed, one a
rule conflict for the L1 to rule on, one a declaration-tracking gap — and **6 observations for the
L1**. Zero unattributable paths.

| class | count | verdict |
|---|---|---|
| writes into a protected tree | 1 transient (42 files, self-cleared) | **VIOLATION — flagged (§3.1)** |
| tracked modification inside protected `corpus/fixtures/**` | 1 (declared C3 repair) | **VIOLATION of the protected-path rule as written — flagged (§3.2)** |
| untracked litter at repo root | 1 transient (`B.txt`, self-cleared) | **VIOLATION — flagged (§3.4)** |
| untracked path outside a declared seat path | 1 (`gate/clean.now.txt`) | **VIOLATION (minor) — flagged (§3.3)** |
| modified/untracked path with no seat attribution | 0 | clean |
| staged content / stash / lock / rebase state / worktree leak | 0 | clean |

**All other paths are correctly attributed and in-scope.** The tree was still mutating while this
audit ran (see §5), so the numbers below are a timestamped snapshot, not a final state. The L1
must re-run `git status --porcelain -uall` after the last seat exits, before any commit.

---

## 1. Method — commands actually run

```sh
git status --porcelain -uall                       # repeated 9x over the window 15:31:36–15:37:34
git status -sb
git diff --name-only HEAD ; git diff --numstat HEAD ; git diff --stat HEAD
git diff --cached --name-only                      # staged
git ls-files --others --exclude-standard           # untracked, non-ignored
git ls-files --others --exclude-standard -- corpus/ corpus/fixtures/
git status --porcelain -uall --ignored | grep -c '^!!'
git status --porcelain --ignored -uall | grep '^!!' | grep -vE 'corpus/(live|fixtures)/'
git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md reports/round-101 \
    reports/round-102 corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f"); done   # blob-id comparison
git ls-tree -r HEAD --name-only -- corpus/fixtures | wc -l
git ls-tree HEAD corpus/knowledge/unreal-mcp/gate/
git check-ignore -v <each untracked path under corpus/fixtures/>
git stash list ; git worktree list ; git reflog show HEAD
ls .git/index.lock .git/MERGE_HEAD .git/rebase-merge .git/rebase-apply .git/MERGE_RR
find .git -type f -newermt '2026-10-18 15:31:00'          # writes to git metadata during r103
git fsck --no-progress
readlink /proc/<pid>/cwd                                  # to attribute a live writer
```

Attribution source for "which seat owns this path": the r103 dispatch roster, recovered from the
session wire log
`~/.kimi-code/sessions/wd_game-dev-3d-shokunin_1d5718ea9394/session_8fbb88db-7658-45d0-abaa-7216e4581191/agents/main/wire.jsonl`
(each `SEAT-NN ROLE → <path>` line), cross-checked against the seat header inside each delivered
report. Where a report names its own seat in line 1, that header is the primary evidence.

---

## 2. Full `git status --porcelain -uall` at snapshot

42 lines: **6 modified (tracked) + 36 untracked (non-ignored)**.

### 2.1 Modified — tracked

```
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

| path | owning seat | role | declared scope | in scope? |
|---|---|---|---|---|
| `corpus/artifacts/glb-r12/README.md` | **SEAT-23** | `REPAIR-GLB` | "owns the glb-r12 file(s) the ruling names" | yes |
| `corpus/artifacts/unity-r19/README.md` | **SEAT-24** | `REPAIR-UNITY` | "owns the unity-r19 file(s)" | yes |
| `corpus/fixtures/three/README.md` | **SEAT-25** | `REPAIR-THREE` | "owns the three file(s)" | **see §3.2** |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | **SEAT-01** | `NOTE-AUTHOR` | "owns `corpus/knowledge/unreal-mcp/adaptation-kimi.md` ONLY" | yes |
| `corpus/knowledge/unreal-mcp/gate/README.md` | **SEAT-09** | `HARDENING-AUTHOR` | "owns `gate/run_gate.sh` + `gate/README.md`" | yes |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | **SEAT-09** | `HARDENING-AUTHOR` | same seat, same declaration | yes |

Diff sizes (`git diff --numstat HEAD`), all three B2 repairs are pure `.shokunin/game-dev-3d/`
prefix removals — verified by reading each hunk:

| path | + | − | shape |
|---|---|---|---|
| `corpus/artifacts/glb-r12/README.md` | 3 | 3 | prefix removal in 3 command lines |
| `corpus/artifacts/unity-r19/README.md` | 2 | 2 | prefix removal in 2 command lines |
| `corpus/fixtures/three/README.md` | 17 | 17 | prefix removal in 17 command lines |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | 143 | 0 | **additive only** — correction-note form, zero historical line mutated |
| `corpus/knowledge/unreal-mcp/gate/README.md` | 45 | 3 | A1–A4 documentation |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | 115 | 23 | A1–A4 implementation |

`corpus/artifacts/glb-r12/README.md` and `corpus/artifacts/unity-r19/README.md` are the two paths
the round brief names for claim **C3**; `corpus/fixtures/three/README.md` is the third leg of the
same B2 ruling (the brief lists the three runnable contexts as "glb-r12 exit=2, unity-r19 exit=2,
three exit=1"). All three are the *declared* C3 repair targets, so their modification is
authorized **by the round brief** even though `corpus/fixtures/**` is on the protected list — see
§3.2, which is the one place where the brief and the protected-path rule disagree.

### 2.2 Untracked — non-ignored (36 files, all under `reports/round-103/`)

```
reports/round-103/b2/adversary.md            reports/round-103/gate/clean.now.txt
reports/round-103/b2/postgrep.md             reports/round-103/gate/docs-sync.md
reports/round-103/b2/repair-glb.md           reports/round-103/gate/exit-codes.md
reports/round-103/b2/repair-three.md         reports/round-103/gate/final-run.md
reports/round-103/b2/scanner.md              reports/round-103/gate/mutations.md
reports/round-103/b2/verify-three.md         reports/round-103/install-recheck.md
reports/round-103/b2/verify-unity.md         reports/round-103/ledger-check.md
reports/round-103/freshness-pin.md           reports/round-103/note/adversary.md
reports/round-103/gate/a2-attack.md          reports/round-103/note/author.md
reports/round-103/gate/a3-attack.md          reports/round-103/note/binary.md
reports/round-103/gate/a4-attack.md          reports/round-103/note/configline.md
reports/round-103/gate/clean.md              reports/round-103/note/crosscheck.md
reports/round-103/gate/clean.raw.txt         reports/round-103/note/gate-pin.md
reports/round-103/note/rows.md               reports/round-103/note/urls.md
reports/round-103/note/verify.md             reports/round-103/pathroot-sweep.md
reports/round-103/physics/investigate.md     reports/round-103/r103-distiller.md
reports/round-103/r103-scribe-audit.md       reports/round-103/seats-ledger.md
reports/round-103/skill-table-review.md      reports/round-103/subtree-integrity.md
```

Seat attribution, each read off the file's own header line (`head -4`):

| path | seat | declared path in roster |
|---|---|---|
| `b2/scanner.md` | SEAT-21 `B2-SCANNER` | matches |
| `b2/adversary.md` | SEAT-30 `DEADROOT-ADVERSARY` | matches |
| `b2/repair-glb.md` | SEAT-23 `REPAIR-GLB` | matches |
| `b2/repair-three.md` | SEAT-25 `REPAIR-THREE` | matches |
| `b2/verify-glb.md` | SEAT-26 `REPAIR-VERIFY-GLB` | matches (landed after the 15:37:34 snapshot) |
| `b2/verify-unity.md` | SEAT-27 `REPAIR-VERIFY-UNITY` | matches |
| `b2/verify-three.md` | SEAT-28 `REPAIR-VERIFY-THREE` | matches |
| `b2/postgrep.md` | SEAT-31 `B2-POSTGREP` | matches |
| `freshness-pin.md` | SEAT-56 `FRESHNESS-PIN` | matches |
| `gate/a2-attack.md` | SEAT-12 `A2-ATTACK` | matches |
| `gate/a3-attack.md` | SEAT-13 `A3-ATTACK` | matches |
| `gate/a4-attack.md` | SEAT-14 `A4-ATTACK` | matches |
| `gate/clean.md` | SEAT-10 `CLEAN-RUN-VERIFIER` | matches |
| `gate/clean.raw.txt` | SEAT-10 | **not declared** — `clean.md` declares it as an owned path in its own header |
| `gate/clean.now.txt` | SEAT-10 | **not declared anywhere — see §3.3** |
| `gate/docs-sync.md` | SEAT-20 `DOCS-SYNC` | matches |
| `gate/exit-codes.md` | SEAT-61 `EXIT-CODE-REVIEW` | matches |
| `gate/final-run.md` | SEAT-53 `GATE-RERUN-RECEIPT` | matches |
| `gate/mutations.md` | SEAT-19 `MUTATION-CROSS` | matches |
| `install-recheck.md` | SEAT-57 `INSTALL-RECHECK` | matches |
| `ledger-check.md` | SEAT-39 `LEDGER-CHECK` | matches |
| `note/author.md` | SEAT-01 `NOTE-AUTHOR` | supplementary artifact for its owned corpus file |
| `note/rows.md` | SEAT-02 `ROW-REPRODUCER` | matches |
| `note/verify.md` | SEAT-03 `NOTE-VERIFIER` | matches |
| `note/adversary.md` | SEAT-04 `NOTE-ADVERSARY` | matches |
| `note/gate-pin.md` | SEAT-05 `GATE-PIN-UPDATER` | matches |
| `note/binary.md` | SEAT-06 `BINARY-REPROBE` | matches |
| `note/urls.md` | SEAT-07 `URL-RECHECK` | matches |
| `note/crosscheck.md` | SEAT-08 `FRESHNESS-CROSSCHECK` | matches |
| `note/configline.md` | SEAT-60 `CONFIG-LINE-VERIFIER` | matches |
| `pathroot-sweep.md` | SEAT-58 `PATHROOT-SWEEP` | matches |
| `physics/investigate.md` | SEAT-32 `PHYSICS-INVESTIGATOR` | matches |
| `r103-distiller.md` | SEAT-36 `DISTILLER` | matches |
| `r103-scribe-audit.md` | SEAT-42 `SCRIBE-AUDIT` | matches |
| `seats-ledger.md` | SEAT-55 `SEATS-LEDGER` | matches |
| `skill-table-review.md` | SEAT-59 `SKILL-TABLE-REVIEW` | matches |
| `subtree-integrity.md` | SEAT-54 `SUBTREE-INTEGRITY` | matches |

**Zero unattributable paths.** Every untracked file names its seat in its first four lines, and
that name matches the roster. `git ls-files --others --exclude-standard` outside
`reports/round-103/` returned **empty** at every snapshot — no untracked write landed anywhere
else in the repo.

---

## 3. Violations and flags

### 3.1 VIOLATION — 42 untracked, **non-ignored** files were written inside protected `corpus/fixtures/` (transient; gone by the final snapshot)

**Observed.** At `15:35:26`–`15:36:17` the working tree contained 19–21 `corpus/fixtures/r90bt_*`
directories (42–44 files) that were **not** gitignored:

```
$ git ls-files --others --exclude-standard -- corpus/fixtures | wc -l
42
$ git check-ignore -v corpus/fixtures/r90bt_free_ops_freeb_ops_dummy/child.log
check-ignore-rc=1                      # rc=1 = NOT ignored
$ git ls-tree -r HEAD --name-only -- corpus/fixtures | grep r90bt
NONE tracked
```

Sample of the paths and their mtimes (all inside the 15:35:23–15:35:46 window):

```
2026-10-18 15:35:23.671354448 -0300 corpus/fixtures/r90bt_free_ops_freeb_ops_gp/project.godot
2026-10-18 15:35:24.662774038 -0300 corpus/fixtures/r90bt_free_ops_freeb_ops_gp/child.log
2026-10-18 15:35:26.453875783 -0300 corpus/fixtures/r90bt_free_ops_freeb_ops_dummy/project.godot
2026-10-18 15:35:27.516783899 -0300 corpus/fixtures/r90bt_free_ops_freeb_ops_dummy/child.log
   ... 19 dirs total: freeb_{ops,twice,make,world,afterclear}, freej_then_b, detachb_free × {gp,jolt,dummy}
$ stat -c '%y %n' corpus/fixtures
2026-10-18 15:35:45.666846649 -0300 corpus/fixtures          # parent dir mtime moved
```

**Mechanism — why a protected tree was writable at all.** `corpus/fixtures/phys3d_joints.gd`
(unmodified, sha256 `88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73`) creates its
per-child projects *relative to the Godot project root*:

```gdscript
# corpus/fixtures/phys3d_joints.gd:117-119
func _run_child(case: String, bk: String, engine: String) -> Dictionary:
	var dirname := "r90bt_%s_%s_%s" % [arm, case, bk]
	var dir := ProjectSettings.globalize_path("res://" + dirname)
	if DirAccess.make_dir_recursive_absolute(dir) != OK:
```

`res://` is whatever `--path` was passed. The normal runner never hits this: `run_battery.py`
copies the seeds to `corpus/live/runs/<ts>/scratch` first (`scratch.mkdir(parents=True)`,
`shutil.copytree`) and points Godot there. But **any invocation of
`godot --headless --path corpus/fixtures --script res://phys3d_joints.gd`** writes its scratch
children straight into the seed tree. A live process at 15:35:52 confirms exactly that call
pattern was in flight:

```
$ pgrep -f phys3d_joints ; readlink /proc/<pid>/cwd
pid=236715  timeout 120 /usr/bin/godot --headless --path . --script res://phys3d_joints.gd -- --arm=free_ops
            cwd=/…/corpus/live/runs/20261018T181301123479Z/scratch      # correct scratch copy
pid=3958691 bash -c cd '…/corpus/live/runs/20261018T181301123479Z/scratch' && for i in 1..6; do timeout 120 /usr/bin/godot --headless --path . …
```

A sibling seat's own transcript names the class independently:

> "A peer seat was running `timeout 120 /usr/bin/godot --headless --path corpus/fixtures --script
> res://phys3d_joints.gd` — pointing Godot at the seed tree itself."

**Owning seat.** The physics lane is **SEAT-32 PHYSICS-INVESTIGATOR** (roster: *"reproduce
`phys3d_joints_free_ops` in isolation (single-case invocation of run_battery.py …)"*), with
SEAT-33 `PHYSICS-ADVERSARY` and SEAT-34 `PHYSICS-LEDGER` as the sibling seats. All three are
declared to write only `reports/round-103/physics/*.md`. I can attribute the *lane* with certainty
(the paths, the arm names, the `phys3d_joints` script, and the timing all match the C3 physics
investigation) but not a single PID to a single seat number, because the offending process had
already exited before I could read its `/proc/<pid>/cwd`. Reported as a lane-level violation for
that reason.

**State at the final snapshot.** The directories are **gone**:

```
$ ls -d corpus/fixtures/r90bt_* 2>/dev/null | wc -l
0
$ git ls-files --others --exclude-standard -- corpus/fixtures | wc -l
0
$ for p in $(pgrep -f godot); do readlink /proc/$p/cwd; done | grep -i fixtures
(none)
```

So this was self-cleaning scratch, and **no tracked fixture byte was ever disturbed** —
`git diff --name-only HEAD -- corpus/fixtures` returns only the §3.2 README, and the seed
`.gd`/`.mjs`/`run_battery.py` files are all byte-identical to HEAD. The violation is nonetheless
real and worth flagging for three reasons: (a) it was visible in plain `git status --porcelain`,
unlike the other two ignored trees under `corpus/fixtures/`; (b) `corpus/fixtures/**` is on the
round's protected list, so the correct move was to copy the tree to `/tmp` first — which other
seats demonstrably did (`/tmp/r103phys/direct.ORnARK`, `/tmp/r103phys/r103cpu.hiv9mlij`, 61
`r90bt_*` dirs under `/tmp` scratch copies); (c) an untracked file in a protected tree is exactly
the class a tracked-file walk misses — SEAT-55's `seats-ledger.md` §3 walks `git ls-tree -r HEAD`
only and would have reported `corpus/fixtures identical=146 differing=0 missing=0` while 42 stray
files sat in the tree.

**Recommended L1 action:** treat "run a fixture script with `--path` pointed at the seed tree" as a
named hazard in the r103 lesson; the cheap guard is to assert
`git ls-files --others --exclude-standard -- corpus/fixtures` is empty in the close-out protocol.

### 3.2 VIOLATION (rule conflict) — `corpus/fixtures/three/README.md` is modified, and `corpus/fixtures/**` is on the protected list

```
$ git diff --numstat HEAD -- corpus/fixtures/three/README.md
17	17	corpus/fixtures/three/README.md
$ git diff --name-only HEAD -- corpus/fixtures
corpus/fixtures/three/README.md          # and nothing else
$ git ls-tree HEAD corpus/fixtures/three/README.md
100644 blob 9b92ca0acff51eed991aa62d2276b3475a9ac3a4	corpus/fixtures/three/README.md
$ sha256sum corpus/fixtures/three/README.md
19ad2c8ce1e75efd98577c3267da8afcb3cc77e94f5e2f4415680ab693ca3d30  corpus/fixtures/three/README.md
```

**Owning seat: SEAT-25 `REPAIR-THREE`**, declared as *"owns the three file(s)"*. Its own report
`reports/round-103/b2/repair-three.md` is candid about the scope:

> "**Owned paths written:** `corpus/fixtures/three/README.md` (the 17 hit lines) + this file. Not
> touched: … `corpus/fixtures/**` other than the one README above …"

The change is a pure prefix removal (17 lines, all of the form
`… .shokunin/game-dev-3d/corpus/fixtures/three/…` → `… corpus/fixtures/three/…`), i.e. a mechanical
command-conformance fix of exactly the kind the correction-note discipline permits in place. It is
also the third leg of the round brief's own C3 scope, which names `three exit=1` as a dead-root
context to repair.

**Why this is still flagged.** My seat's instruction is explicit: *"Do NOT write … `corpus/fixtures/**`
— those are byte-pinned/protected."* Taken literally, `corpus/fixtures/three/README.md` is inside a
protected tree, so this modification is a protected-path write. The round brief simultaneously
requires the three repair. **The two instructions conflict, and this seat cannot resolve it** — it
is an L1 ruling, not a hygiene finding. I flag it so the conflict is visible rather than silently
absorbed, and I record both readings:

- **Reading A (protected list is per-file):** the protected list names `corpus/fixtures/**` because
  the *fixtures* are the pinned evidence; a README is prose, not a fixture, and the brief's C3
  explicitly routes it. → authorized.
- **Reading B (protected list is per-tree):** `corpus/fixtures/**` means the whole subtree, and the
  C3 repair should have been executed on a copy or deferred to an L1-owned edit. → violation.

Note that SEAT-30's own keep-list report (`reports/round-103/b2/adversary.md` §K5) already
anticipates this: it calls the three README *"repair-eligible, but NOT a clean case"* because the
file *"has been cited in prior lessons (the r56 reviews record `README.md` digest drift as a
load-bearing…"*). **The digest has now drifted again**: `9b92ca0a…` → `19ad2c8c…`. Any r56-era
lesson that pins the old digest will need the same dated correction-note treatment the C1 seat
applied to `adaptation-kimi.md`. I did not sweep for those citations — it is outside my seat's
scope and belongs to SEAT-29 `CORRECTION-AUDITOR`, whose charge is precisely *"any changed
factual/historical claim."*

### 3.3 VIOLATION (minor) — `reports/round-103/gate/clean.now.txt` is undeclared

```
$ git status --porcelain -uall | grep clean
?? reports/round-103/gate/clean.md
?? reports/round-103/gate/clean.now.txt
?? reports/round-103/gate/clean.raw.txt
```

`clean.md` (SEAT-10) declares two owned paths in its header — `gate/clean.raw.txt` and
`gate/clean.now.txt` — and the roster declares only `reports/round-103/gate/clean.md`. So
`clean.now.txt` is authorized by the seat's *own* header but appears in no roster line; and
`clean.raw.txt` is the same shape. Both are gate receipts (raw gate stdout), which is a legitimate
artifact class, and `clean.now.txt` differs from `clean.raw.txt` (the seat re-ran the gate after
the hardening landed). **Flagged as a declaration-tracking gap only** — the content is in scope
for the seat, the path was not pre-declared. No action needed beyond noting that the roster's
`gate/clean.md` line under-specifies the seat's actual write set.

### 3.4 VIOLATION — untracked litter at the repo root: `B.txt` (transient; self-cleared)

**Observed.** At `15:37:58` a 1902-byte file `B.txt` appeared at the repository root — outside
`reports/round-103/`, i.e. outside every seat's declared write path:

```
$ git status --porcelain -uall | grep -v '^?? reports/round-103/'
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? B.txt
$ ls -la B.txt ; wc -lc B.txt
-rw-r--r-- 1 vgpnk vgpnk 1902 Oct 18 15:37 B.txt
     53    1902 B.txt
$ head -3 B.txt
GATE unreal-mcp subtree
SUBTREE=/tmp/s16-adv/repo2/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
```

**What it was.** A full gate transcript whose `SUBTREE=` header names a **scratch copy**
(`/tmp/s16-adv/repo2/…`), not the lane tree — so no repo content was read or written by the gate
itself. It is a stray stdout redirect.

**Mechanism, traced to the command.** The session wire log shows the exact invocation, run with
`cwd` = repo root while the gate target was the `/tmp` copy:

```
TMPDIR=/home/vgpnk/.cache/s16tmp bash $R/corpus/knowledge/unreal-mcp/gate/run_gate.sh > B.txt 2>&1
```

The `> B.txt` is relative to the shell's cwd, which was the lane root — hence the file landed at
the repo root instead of in `/tmp` or the seat's own report directory. The `TMPDIR=` prefix is a
known gate workaround (the gate clones into `mktemp`), and the transcript's `SUBTREE` header
confirms the target was the adversarial copy.

**Owning seat — attribution weakened by a cross-check.** The command appears in the wire log of a
lane that ran `SEAT-16 HARDENING-SENTINEL`, `SEAT-17 GATE-AUTHOR` and `SEAT-09 A4` work, and the
target `/tmp/s16-adv/` is a **SEAT-16 adversarial scratch path** (SEAT-16's own report
`reports/round-103/gate/sentinel.md` uses `/tmp/s16-adv/` throughout — `FROZEN2.sh`, `ctest`,
`refclone`, `sh2/`, `bc/`, `shg2/`). That makes SEAT-16 the most likely author, **but SEAT-16's
report explicitly denies it**: its header says *"**Owned path:** this file only
(`reports/round-103/gate/sentinel.md`). No other file was written by this seat."* — and a `grep` of
that report for `B.txt` returns **no hits**. So either the redirect came from a different agent
sharing the `/tmp/s16-adv/` scratch tree, or SEAT-16's self-report is incomplete.

I therefore report this as **owner UNRESOLVED**, with the scratch-path evidence pointing at the
SEAT-16 lane and the seat's own declaration pointing away from it. I could not settle it: the
command is unambiguous but I read it from the wire log rather than from a live `/proc/<pid>/cwd`,
and the file was gone before I could correlate. **This is itself worth the L1's attention** — a
seat's "no other file was written" claim and the observable filesystem disagree, and only one of
them can be right.

**State at close.** Gone, self-cleared at `15:39:02`:

```
$ date -Is ; ls -la B.txt
2026-10-18T15:39:02-03:00
ls: cannot access 'B.txt': No such file or directory
$ git status --porcelain -uall | grep -v '^?? reports/round-103/'
 M corpus/artifacts/glb-r12/README.md
 … (the 6 authorized modifications, no untracked entry)
```

**Independent corroboration.** SEAT-44's `reports/round-103/consistency.md` §N6 caught the same
file while it existed and recorded it as an open item:

> | **N6** | stray untracked `B.txt` at the repo root (a peer seat's gate transcript) | **OPEN —
> untracked litter** | `git status --porcelain` → `?? B.txt`; content is a gate run against
> `/tmp/s16-adv/repo2/…` |

Two seats independently flagged it; this file adds the owning command and the self-clearing
timestamp. **Recommended L1 action:** none beyond the record — but if `consistency.md` is folded
at close, its N6 row can now be marked RESOLVED-SELF-CLEARED rather than OPEN.

---

## 4. Protected-path verification — PASS

Every protected path is byte-identical to HEAD. Two independent methods agree.

**Method 1 — diff against HEAD (catches modification and deletion):**

```
$ git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md reports/round-101 \
    reports/round-102 corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
protected-diff-exit=0
```

**Method 2 — blob-id comparison of the worktree file against `HEAD:<path>`:**

```
$ for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
    wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f")
    echo "$f wt=$wt head=$hb $([ "$wt" = "$hb" ] && echo MATCH || echo DIFFER)"; done
LOG.md      wt=8e762af047896c727012edf8dc2fb97b7a8506a9 head=8e762af047896c727012edf8dc2fb97b7a8506a9 MATCH
SCORECARD.md wt=d4b73d776da20ae65421b45653a789d49aef8d4c head=d4b73d776da20ae65421b45653a789d49aef8d4c MATCH
SHONEN.md   wt=8d85902c19010deb4fa154e16a2c12ad56ff10d1 head=8d85902c19010deb4fa154e16a2c12ad56ff10d1 MATCH
PROVINCE.md wt=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 head=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 MATCH
```

**Method 3 — addition sweep (the class a tracked walk misses):**

```
$ git ls-files --others --exclude-standard -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md \
    reports/round-101 reports/round-102 corpus/knowledge/unreal-mcp/upstream \
    corpus/knowledge/unreal-mcp/.manifest.d
(none)
$ git status --porcelain -- corpus/knowledge/unreal-mcp/gate
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

| protected path | state vs HEAD | additions | note |
|---|---|---|---|
| `LOG.md` | identical | none | blob `8e762af0…` |
| `SCORECARD.md` | identical | none | blob `d4b73d77…` |
| `SHONEN.md` | identical | none | blob `8d85902c…` |
| `PROVINCE.md` | identical | none | blob `cde5e8f5…` |
| `SKILL.md` | n/a — none exists at lane level | none | only the 3 vendored copies, inside the pinned upstream tree |
| `corpus/fixtures/**` | **1 tracked modification** (`three/README.md`, §3.2); 146 tracked files otherwise identical | **42 transient untracked (§3.1, gone)** | see §3.1, §3.2 |
| `reports/round-101/**` | identical | none | frozen |
| `reports/round-102/**` | identical | none | frozen |
| `corpus/knowledge/unreal-mcp/upstream/**` | identical | none | 12 files, byte-pinned |
| `corpus/knowledge/unreal-mcp/.manifest.d/**` | identical | none | 12 files, byte-pinned |
| `corpus/knowledge/unreal-mcp/gate/**` | **2 tracked modifications** (`run_gate.sh`, `README.md`) | none | **not** on the protected list; declared C2 target of SEAT-09 |

The gate subtree is worth stating explicitly because it is easy to misread: `gate/run_gate.sh` and
`gate/README.md` are **tracked** (`git ls-tree HEAD corpus/knowledge/unreal-mcp/gate/` →
`100755 blob 36e422a7… run_gate.sh`, `100644 blob ee4c58ff… README.md`) and they were **not**
modified when this audit began — the hardening landed mid-audit (`run_gate.sh` sha256 went
`412d1b84…` at 15:15:52 → `0c1ca3e1…`; the diff is +115/−23). They are the declared C2 artifact and
are *not* on the round's protected list, so this is authorized work, not a violation.

---

## 5. The tree was mutating throughout the audit

`git status --porcelain -uall` returned a different count at almost every read. Recorded so the L1
can calibrate how stale any hygiene snapshot is:

| wall clock (`-0300`) | entries | what appeared |
|---|---|---|
| 15:31:36 | 1 | `gate/clean.raw.txt` |
| 15:31:56 | 3 | + `ledger-check.md`, `unity-r19/README.md` |
| 15:32:12 | 5 | + `note/urls.md`, `note/configline.md` |
| 15:32:26 | 6 | + `adaptation-kimi.md` |
| 15:32:57 | 10 | + `freshness-pin.md`, `seats-ledger.md`, `subtree-integrity.md`, `note/binary.md` |
| 15:33:14 | 10 | (stable) |
| 15:33:57 | 18 | + `b2/adversary.md`, `gate/{a4-attack,mutations,final-run}.md`, `note/author.md` |
| 15:34:18 | 21 | + `gate/{a3-attack,clean}.md`, `note/{crosscheck,rows,verify}.md` |
| 15:35:26 | 37 | **+ 6 untracked files under `corpus/fixtures/r90bt_*/`**, + `gate/{run_gate.sh,README.md}` modified |
| 15:35:55 | 52 | fixtures scratch grew to 42 files |
| 15:36:50 | 38 | fixtures scratch gone; + `b2/{postgrep,repair-three}.md`, `three/README.md` modified |
| 15:37:34 | 42 | + `b2/{scanner,verify-three}.md`, `physics/investigate.md`, `note/gate-pin.md` |
| 15:37:58 | 47 | **+ `B.txt` at repo root (§3.4)**; + `b2/verify-glb.md`, `note/adversary.md` |
| 15:39:02 | 46 | `B.txt` self-cleared; back to the 6 modified + `reports/round-103/` only |

Peak observed: **52 entries** (15:35:55). No seat's snapshot can be final; the L1 must re-run
`git status --porcelain -uall` after the last seat exits.

---

## 6. Repo-level state — all clean

```
$ git rev-parse HEAD
c85a816e227984272a3c29b58aa7f7c1a76f1e9c                 # unchanged from the start of the audit
$ git status -sb | head -1
## main...origin/main [ahead 4]
$ git diff --cached --name-only
(empty)                                                   # nothing staged
$ git stash list | wc -l
0
$ git worktree list | wc -l
1                                                         # no stray worktree
$ ls .git/index.lock .git/MERGE_HEAD .git/rebase-merge .git/rebase-apply
(all four: No such file or directory)
$ git reflog show HEAD | head -1
c85a816 HEAD@{0}: commit: r102 report-last: …              # no rewrite, no new commit
$ git config --local --list
core.repositoryformatversion=0 … user.email=game-dev-3d@shokunin.local
```

**Git metadata writes during r103.** `.git/objects`, `.git/index`, `.git/COMMIT_EDITMSG` and
`.git/MERGE_RR` carry mtimes of `15:27`, which is **before** the r103 window opened (`15:31`) and
matches the `c85a816` commit time (`2026-10-18 15:27:40 -0300`). Verified:

```
$ find .git -type f -newermt '2026-10-18 15:31:00' | wc -l
0
$ find .git/objects -type f -newermt '2026-10-18 15:31:00' | wc -l
0
```

So **no r103 seat wrote git metadata** — no `git add`, no commit, no checkout, no stash. The two
dangling blobs `git fsck` reports (`f88943e4…`, mtime 15:20, 17770 B; `0a1f8539…`, mtime 14:31,
11428 B) both predate the round and are ordinary leftovers from the r102 commit, not r103 writes.
`.git/MERGE_RR` is 0 bytes (a `git merge` left it empty at 15:27); it is inert without a
`MERGE_HEAD`, which does not exist.

**Ignored churn is benign and confined to two non-protected trees.**

```
$ git status --porcelain -uall --ignored | grep -c '^!!'
64288
$ git status --porcelain -uall --ignored | grep '^!!' | grep -vE 'corpus/(live|fixtures)/'
(none)
$ git status --porcelain -uall --ignored -- corpus/fixtures | grep '^!!' | cut -d/ -f1-3 | sort -u
corpus/fixtures/__pycache__
corpus/fixtures/three
```

64 288 ignored entries, **all** under `corpus/live/` (`runs/`, `r101-sentinel/`) or
`corpus/fixtures/{__pycache__,three/node_modules}/`. `corpus/.gitignore` is exactly `live/`,
`__pycache__/`, `*.pyc` — so both trees are ignored by design, and neither is a seat write to a
pinned fixture. The battery and import probes are actively appending to
`corpus/live/runs/` (newest: `r12-import-20261018T183304039745Z/`,
`20261018T183303272957Z/`), which is expected for a round that re-runs the battery.

---

## 7. Observations for the L1 (not violations)

1. **`corpus/live/runs/` is growing without bound.** 59 167 ignored entries under `corpus/live/runs/`
   at 15:33, 64 288 total ignored by 15:37. Each battery/probe invocation mints a timestamped run
   directory. Not a hygiene violation (the tree is gitignored), but it is disk growth the L1 may
   want to bound before the next round.
2. **The `r90bt_*` hazard is reusable knowledge.** The mechanism in §3.1 — a fixture script that
   creates `res://`-relative directories, combined with `--path <seed tree>` — will bite any future
   round that runs `phys3d_joints.gd` directly. Worth a line in the r103 lesson and a one-line
   assertion in the close-out protocol.
3. **`corpus/fixtures/three/README.md` digest drift is now load-bearing twice over.** Old
   `9b92ca0a…` → new `19ad2c8c…`. SEAT-30 flagged that r56-era lessons cite this file; SEAT-29
   owns the correction-note audit. Not my scope, but it should not be lost.
4. **Two seats independently produced overlapping protected-path evidence** (SEAT-39
   `ledger-check.md`, SEAT-55 `seats-ledger.md`) and this seat produced a third. All three agree on
   every shared path and on the blob ids. That is useful redundancy, not duplication — but the L1
   should read this file as the *widest* of the three, since only it enumerates the untracked
   surface and the transient `corpus/fixtures/` additions.
5. **Both transient violations had the same root cause: a shell redirect or `--path` anchored to
   the wrong cwd.** §3.1 wrote into a protected tree because `--path corpus/fixtures` resolved
   `res://` to the seed tree; §3.4 dropped a transcript at the repo root because `> B.txt` was
   relative to the lane root. Neither seat intended to write there. A one-line convention for r104 —
   *every scratch path and every redirect is absolute or under `/tmp`* — would have prevented both,
   and is cheaper than auditing for them afterwards.
6. **A tracked-file walk is not sufficient evidence that a protected tree is untouched.** SEAT-55's
   `seats-ledger.md` §3 walked `git ls-tree -r HEAD` and correctly reported `corpus/fixtures
   identical=146 differing=0 missing=0` — while 42 untracked files sat in that same tree (§3.1).
   Both statements are true; only the addition sweep in this file's §4 Method 3 catches the second.
   The close-out protocol should require `git ls-files --others --exclude-standard -- <protected
   tree>` to be empty, not just the blob walk to be clean.

---

## 8. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# full surface
git status --porcelain -uall
git diff --name-only HEAD ; git diff --numstat HEAD
git ls-files --others --exclude-standard
git ls-files --others --exclude-standard -- corpus/            # expect empty

# protected paths
git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md reports/round-101 \
    reports/round-102 corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d; echo $?
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do
  wt=$(git hash-object -- "$f"); hb=$(git rev-parse "HEAD:$f"); echo "$f $([ "$wt" = "$hb" ] && echo MATCH)"; done

# the §3.1 hazard, if it recurs
git ls-files --others --exclude-standard -- corpus/fixtures | wc -l     # expect 0
git check-ignore -v corpus/fixtures/r90bt_*/child.log                   # expect rc=1 (not ignored)

# the §3.4 hazard, if it recurs: any untracked path outside the round's report dir
git ls-files --others --exclude-standard | grep -v '^reports/round-103/'   # expect empty

# repo-level state
git diff --cached --name-only ; git stash list ; git worktree list ; git reflog show HEAD | head -1
find .git -type f -newermt '2026-10-18 15:31:00' | wc -l                # expect 0
git status --porcelain -uall --ignored | grep '^!!' | grep -vE 'corpus/(live|fixtures)/'   # expect empty
```

---

## 9. Amendments to this file

- **2026-10-18T15:39 — `B.txt` (§3.4) added after the first draft.** The file appeared at the repo
  root at `15:37:58`, four minutes after this seat's first snapshot, and self-cleared at `15:39:02`.
  §0, §5 and §7 were amended to match. The first draft's verdict was "3 violations"; it is now 4.
  Nothing in the first draft was rewritten or retracted — this is an additive amendment, per the
  round's correction-note discipline. The §3.1, §3.2 and §3.3 findings are unchanged.
