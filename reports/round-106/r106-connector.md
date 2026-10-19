# r106 connector — the corpus is executable-healthy; the rot is citation roots

**Seat:** SEAT-54 CONNECTOR · round 106 · lane `game-dev-3d-shokunin`
**Owned path written:** this file only (`reports/round-106/r106-connector.md`). No commit.
**Repo HEAD at write:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (r105 report-last; work `3634bc0`)
**Measurement window:** 2026-10-18, 21:20Z–21:49Z.
**Tag key:** **[O]** command run by this seat with output pasted · **[I]** labelled inference ·
**[F]** a claim that did not reproduce here.

**No Unreal runtime claim appears in this file.** Unreal Editor is not installed on this host.
A green gate is static evidence over vendored bytes. Upstream pin
`a6aa73ada02a9fb1f5415bec491f9942c519b297`.

---

## 0. The one-line verdict

**The executable corpus is healthy, and the r103/r104 census gap closed during this window.
What the sweep is actually finding is citation-root rot, and nothing in the standing harness
fails if that rot comes back.** r107 is a small flash swarm (16–32). Its integration move is a
**citation-conformance checker that lives outside `corpus/fixtures/`**, plus a gate JSON receipt.
Do not wire `run_gate` into the battery. Do not schedule another 128-seat human sweep.

---

## 1. The frame moved — bind every number to the time beside it

`engines.md` was byte-identical to HEAD at open and was rewritten under this seat. Three
identities, one window:

| time (UTC) | `corpus/knowledge/engines.md` sha256 | what this seat saw |
|---|---|---|
| 21:20:48Z | `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf` | 16 lines, `== HEAD`, `run_gate` count 0, parenthetical `Node v26.11.1` |
| 21:42:28Z | `62a70d045d5f55712e316054583bdb5974f02d2a3ecbbe5de3a3dd05023af19d` | census refresh in progress (SEAT-38) |
| 21:49:45Z | `149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba` | 122 lines, `grep -c run_gate` = **1** |

```
$ date -u +%Y-%m-%dT%H:%M:%SZ; git rev-parse HEAD
2026-10-18T21:49:45Z
0cc3f4162f8c319f8d01a69a174fe939f36701bd
$ sha256sum corpus/knowledge/engines.md corpus/fixtures/run_battery.py \
            corpus/knowledge/unreal-mcp/gate/run_gate.sh
149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba  corpus/knowledge/engines.md
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf  corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

The runner and the gate did **not** move. The census did. **Re-hash `engines.md` before quoting
it.** This is the r103 law again: a connector that reads the tree once is reading a tree that
no longer exists. Behaviors below are what the recommendations depend on, not the intermediate
sha `62a70d04…`.

Lesson fences moved the other way, which is the sweep working: **42 lesson files / 141 fenced
dead-root lines** at 21:35Z, **31 files / 98 lines** at 21:49:45Z. `git status --short -- corpus`
named **41** dirty paths at that second read. Those counts are a frame.

---

## 2. What is healthy — re-measured, not inherited

### 2.1 Two Node states still resolve, and the durable totals still parse [O]

```
$ node --version; node -p 'process.execPath'; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
v24.21.0
```

Pinned-path lookup (21:27:16Z):
`/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`.

The two full-battery receipts the census now cites both exist. Parsed by this seat, not re-run:

```
reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json
  verdict=FAIL totals={cases:350, pass:337, fail:13} seeds_unchanged=true
  all 13 fails start with r94_cannon_
reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json
  sha256 54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5
  verdict=PASS totals={cases:350, pass:350, fail:0} seeds_unchanged=true
  runner digest f456bd00a1f7…  (matches live run_battery.py)
```

The earlier pinned capture `node24-full-20261018T202944Z.verdicts.json` is still
`verdict=FAIL` with `pass=350` and `seeds_unchanged=false`. It is not a clean PASS. [O]

`python3` import of `run_battery.py` at 21:49:45Z: **CASES 350**, `seed_digests()` **131**
entries, **`PINNED-ENV.md` is one of them**, **0** keys contain `knowledge` or `gate`.

### 2.2 Gate is green on this host, and the editor is absent [O]

```
$ GATE_WORKDIR=/home/vgpnk/scratch-r106-s54/gw bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
  # 2026-10-18T21:35:01Z, gate sha 390a25ae4e38…
WORK_ROOT=/home/vgpnk/scratch-r106-s54/gw (from GATE_WORKDIR)
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
gate_exit=0
stderr bytes=0
```

`POINTERS=103` is this scanner on this tree at that sha. `UNRESOLVED=0` is the invariant.
The subtree and the gate script are protected this round; this seat did not edit them.

```
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor UnrealBuildTool; echo rc=$?
unreal_rc=1
$ ls /opt/UnrealEngine
ls: cannot access '/opt/UnrealEngine': No such file or directory
```

`which UnrealEditor` earlier in the window returned rc 2. Both mean absent. No editor, no
live-MCP claim.

### 2.3 Godot and three.js still run from the repo root [O]

`/usr/bin/godot --version` → `4.7.2.stable.arch_linux.ed1daf0bf` (21:27:16Z).

Bound to the default Node in one shell (21:49:45Z):

```
$ node --version; node -p 'process.execPath'; node corpus/fixtures/three/run_cases.mjs
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node
PASS three battery: 3/3, seeds_unchanged=true
three_rc=0
```

That is one runner under the default state. It is not the pinned-state 5/5 camera run, and it
is not a battery total.

### 2.4 The census gap the last three connectors named has closed — as a behavior [O]

At 21:20Z the Unreal evidence cell's manifest command failed from the repo root:

```
$ sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1; echo from_root_exit=$?
from_root_exit=1
sha256sum: .manifest.d/audit-reference.sha256: No such file or directory
$ (cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1); echo from_subtree_exit=$?
from_subtree_exit=0
# 12 × OK
```

At 21:49:45Z `engines.md` contains **1** `run_gate` reference and a dated correction note for
the old `Node v26.11.1` parenthetical (the note string is in the file; this seat read the
116-line intermediate and then re-counted on the 122-line `149e61cf…` file). State cells did
not promote: Godot headless stays yes, Unity/Unreal stay no, three.js stays partial. This seat
did not author that edit. **[I]** The r103 option-3 / r104 "do the census" recommendation is
done at this frame, provided a later seat re-hashes before citing it.

`SKILL.md` §6 still stamps the pre-edit digest. Confirmed at 21:49:45Z: live sha
`149e61cf…` is **not** in `SKILL.md`; `d03907d3d637…` **is** (one hit). `SKILL.md` sha is still
`8ea7ae5c3069…` and the file is protected this round. The stamp is stale by construction the
moment the census lands. That is a one-line calibration fix for a round where `SKILL.md` is
writable — not a reason to reopen the census.

---

## 3. What the sweep reveals

### 3.1 The runnable defect is one prefix, and it is concentrated in lessons [O]

A path-existence probe over 223 `corpus/**/*.md` files (upstream excluded) at ~21:27Z
classified unique path-like citations as: templates 623, globs 665, dead predecessor root 283,
`corpus/live` absent 168, `corpus/live` present 11, tracked-and-existing 121, tracked-missing
12. The "tracked-missing" bucket was almost entirely truncated tokens (`README.md:N`,
`corpus/artifacts/zip-r10/rea-`) and one sweep note citing a chunk report that did not exist
yet. **Do not quote "364 missing paths" from a raw exists-check.** Most non-existence is
templates, the dead root, or gitignored receipts.

The load-bearing count is fenced commands. At 21:49:45Z, **31** files under `corpus/lessons/`
still contain `.shokunin/game-dev-3d` inside a fenced block, **98** such lines. At 21:35Z the
same scan was 42 files / 141 lines, and two extra hits lived in `corpus/predecessor/` (historical
layout; a checker must not fail those). `corpus/.gitignore` line 1 is `live/`, so a lesson that
cites `corpus/live/runs/<old-timestamp>/verdicts.json` is citing a path this tree is not allowed
to keep.

`reports/round-106/sweep/chunk-13.md` (sibling, artifacts chunk) records **0** mechanical
path-root fixes and an empty `git status --porcelain -- corpus/artifacts`. **[I]** The rot the
sweep was convened to find is not in the artifact READMEs (those were repaired in r102/r103).
It is in the lesson fences that still tell a reader to run a command from a root this repo has
never contained.

### 3.2 The sweep's own first landings are the right class, and one of them already rotted [O]

`git diff` on `corpus/lessons/r61-stream-review.md` (read 21:27Z) re-rooted
`node .shokunin/game-dev-3d/corpus/fixtures/three/…` to `node corpus/fixtures/three/…` and
appended a `Correction note (r106, 2026-10-18)` that preserves the r61 counts and digests.
That is the mechanical fix the round asked for.

The same note cites `reports/round-106/sweep/chunk-05.md` as its evidence. At 21:35Z
`reports/round-106/sweep/` had **0** markdown files. At 21:49:45Z `chunk-05.md` was **still
absent** (`chunk05=no`), while `chunk-13.md`, `hygiene.md`, `lesson-integrity.md`, and
`province-audit.md` had landed. **[O]** The fix introduced a prose-cites-bytes defect in the
same breath as it removed a path-root defect. The note is also an essay, not a line. SEAT-47's
`reports/round-106/consistency/adversary.md` rules that path conformance may be silent in the
living file when the round report holds the before/after, and that a factual correction keeps
one line, not a second essay. **[I]** Agree with that placement rule. The r61 note is the
example of why: it cites a report that the sweep had not written.

`corpus/lessons/r105-unreal-lifecycle.md` gained an environment-pairing note (diff read
21:42Z): `337/350` is named as the default-env total, and the pinned `350/350` receipt is
named beside it. That is the calibration move, and it does not rewrite the 2.9 s physics
claim. [O, the diff; this seat did not re-time the physics row.]

### 3.3 The integration gaps from r102–r104 are still open, measured again [O]

| gap | r104 measurement | this seat, 21:27Z–21:49Z | closed? |
|---|---|---|---|
| gate not in the digest map | `seed_digests()` 130 entries, 0 `gate` | **131** entries (PINNED-ENV.md added in r105), **0** `gate`, **0** `knowledge` | no |
| no runner-of-runners | no `check_all.sh` | `ls check_all.sh corpus/check_all.sh` → both absent | no |
| gate writes stdout only | no `--receipt` | `grep -c -- '--receipt' gate/run_gate.sh` → **0** | no |
| exit-2 collision | fixtures README exit 2 = passing negative control; gate exit 2 = BLOCKED | still both. `corpus/fixtures/README.md` "Exit 2 is a *passing* negative control"; gate README "BLOCKED exit 2 is not a verdict" | no |
| census ignores the gate | `run_gate` count 0 | **1** at 21:49:45Z | **yes, this window** |

`git grep -l run_gate -- corpus` outside `gate/` still hits only the two lessons
(`r102-unreal-integration.md`, `r105-unreal-lifecycle.md`) plus, after 21:42Z, `engines.md`.
Zero hits in `corpus/fixtures/`. The gate is still invoked by humans and by prose.

The exit-2 collision is unchanged and still blocks battery wiring. A wrapper that reads the
lane's own exit table treats gate exit 2 as a passing negative control. This seat did not
re-execute the mixed BLOCKED+FAIL case; the README texts are the live contract, and r103/r104
already executed the collision. **[I]** Wiring remains the wrong round, for the same reason
plus a new one in §4.1: r107 is a 16–32 flash swarm, and a battery-contract change is not a
flash claim.

---

## 4. The next integration frontier

### 4.1 A citation-conformance checker — do this, and do not put it in `corpus/fixtures/`

**Anchor.** The 98 fenced dead-root lines at 21:49:45Z, and the r105 fact that
`seed_digests()` includes every file under `corpus/fixtures/` except `__pycache__` and `three`.
`PINNED-ENV.md` is in that map. The first pinned full run of r105 failed
`seeds_unchanged` because that file appeared mid-run. **[O]** A checker dropped into
`corpus/fixtures/` becomes the next seed-guard failure the moment a battery is in flight.

**Measured state.** No such checker exists (`ls corpus/fixtures/check_citations.py` → absent;
`git grep` for the dead prefix in `*.py`/`*.sh` hit only a round-104 scratch script). The
human sweep is the third repair of this class (r102 routed defects, r103 README re-roots,
r106 lesson fences) and it is already citing reports it has not written.

**Verdict: this is the frontier the sweep walked into.** A repo-root script, living under
`corpus/knowledge/` or the repo root — **not** `corpus/fixtures/` — that exits 1 when a fenced
command outside `corpus/predecessor/` and outside a `Correction note` block contains
`.shokunin/game-dev-3d`. Historical `corpus/live/` citations are a **warning**, not a hard
fail: 168 of them were already absent, `live/` is gitignored, and failing the tree forever on
historical `20261013T…` receipts would make the checker unusable. Dated notes cover those; the hard fail
is the command a reader can copy.

**Acceptance:** on a copy, planting one fenced `.shokunin/game-dev-3d` line exits 1; the
predecessor round-reports do not; `seed_digests()` length stays 131; the checker is not
imported by `run_battery.py`. **Owner:** one seat. A second seat clears whatever fence lines
r106 leaves, using the checker's own red list — not a new 12-chunk swarm.

### 4.2 Gate `--receipt` — do this, do not fold it into the battery

**Anchor.** `grep -c -- '--receipt' corpus/knowledge/unreal-mcp/gate/run_gate.sh` → 0
(21:47:12Z). The census now transcribes gate stdout into `engines.md`. That transcription is
how `POINTERS=` and shas rot between rounds.

**Verdict.** A `--receipt=<path>` writing `{verdict, exit, work_root, pin, pointers, unresolved, gate_sha}`
makes the next census quote a file. It does not require the exit-2 ruling. It must not change
exit codes. **Acceptance:** two `GATE_WORKDIR` runs produce receipts whose `verdict` matches
the `GATE RESULT:` line and the exit code; `UNRESOLVED` is in the receipt; no fixture digest
moves. **Owner:** one seat, next round (the gate script is protected this round).

### 4.3 Battery wiring — still the wrong move

Unchanged from r104, re-measured in §3.3. Exit 2 means opposite things in
`corpus/fixtures/README.md` and `gate/README.md`. `seed_digests()` has no gate entry. A
blocked gate is reachable from scratch failure (r103/r104) and from a network cut. Folding
that into `verdict = PASS if failed == 0` imports a third state the battery cannot name.
**Do not schedule it for the flash swarm.** It needs an L1 ruling first. Cheaper ruling, still
true: keep the gate's exit 2, and never read it with the fixture table; the `BLOCKED` token
is the distinction.

### 4.4 What not to aim at

- **Another citation swarm.** The class is now countable (98 fence lines, one prefix). A
  checker plus a short cleanup beats 128 seats.
- **Re-doing the census.** It landed this window. Re-hash, don't rewrite, unless a cited
  command fails from the repo root. This seat's root-manifest failure was the *old* command;
  the replacement form `(cd corpus/knowledge/unreal-mcp && sha256sum -c …)` exited 0.
- **P/C precedence.** Still an operator ruling. The gate census this seat ran is still
  `12/1/0`. A green gate does not decide it.
- **Jolt empty cells.** SEAT-49 owns that investigation this round. This seat did not re-run
  `free_ops` and asserts nothing about jolt cells.
- **Write-isolation inside `run_battery.py`.** The runner sha is unchanged
  (`f456bd00…`), so the r105 stray-writer hazard is unfixed. Touching the runner is a
  contract change and a seed-identity change. Queue it. Do not make it the flash primary.
- **`SKILL.md` stamp refresh** until `engines.md` stops moving. Then it is one cell:
  replace `d03907d3…` with the frozen sha. Protected this round.

---

## 5. Recommendation for r107 (16–32 flash seats)

**Primary — citation-conformance checker (coverage).** One implementation seat, file outside
`corpus/fixtures/`, acceptance in §4.1. One cleanup seat for whatever fenced dead-root lines
survive r106 close, evidence = the checker's output, dated one-line notes only where a
historical fact changes. No essay notes that cite unlanded chunk reports.

**Second — gate `--receipt` (depth).** One seat, §4.2. Does not touch the battery verdict.

**Third — freeze and re-stamp (calibration).** After `engines.md` is stable, one seat updates
the `SKILL.md` §6 stamp from `d03907d3…` to the live sha and re-runs the table's
`sha256sum` check. Do not do this against a moving file. This seat already saw three shas.

**Carry, do not swarm:** P/C ruling; exit-2 ruling before any battery wiring; jolt class
(whatever r106 rules); write-isolation of battery scratch vs the seed tree; the 13 default-env
cannon failures stay a PATH fact, not a fixture defect (`337/350` default, `350/350` pinned).

**Explicit non-goals:** no Unreal install, no state-cell promotion, no silent marker rebaseline,
no checker under `corpus/fixtures/`.

---

## 6. What a later seat must not assume

- **`engines.md` sha `149e61cf…` is a 21:49:45Z frame.** It was `d03907d3…` twenty-nine
  minutes earlier. Re-hash.
- **Fence counts are a frame.** 42/141 → 31/98 inside fourteen minutes. Re-count before
  editing a lesson.
- **`POINTERS=103` names this gate sha and this tree.** Quote `UNRESOLVED=0` as the invariant.
- **A green gate is not a live editor.** `verified-here=0`. Editor absent.
- **`350/350` is the pinned-env clean rerun only.** Default-env durable receipt is `337/350`,
  all 13 fails `r94_cannon_*`. The first pinned run is `pass=350` and `verdict=FAIL`
  (`seeds_unchanged=false`).
- **Exit 2 is not one meaning.** Fixture README: passing negative control. Gate README:
  BLOCKED, bytes unchecked.
- **Do not add files under `corpus/fixtures/` to "improve hygiene."** They enter
  `seed_digests()` and fail the next in-flight battery.
- **No Unreal runtime claim can be added on this host.**

---

## 7. Limits of this report

- **Read-only except this file.** No commit. No `corpus/` write, no fixture, no gate, no
  `LOG.md` / `SCORECARD.md` / `SHONEN.md` / `PROVINCE.md` / `SKILL.md` write, no other seat's
  report. Scratch for the gate and the three.js transcript is under
  `/home/vgpnk/scratch-r106-s54/` because `/tmp` per-user quota is exhausted.
- **The sweep was in flight the whole window.** This file does not total "files swept" or
  "defects fixed." Those numbers belong to the chunk reports, most of which had not landed
  (`chunk-05.md` absent at 21:49:45Z). The fence recount is this seat's, not a sibling's.
- **This seat did not run the 350-case battery.** It parsed the r104 default and r105 pinned
  receipts, ran one three.js runner (3/3, default Node), and ran the gate once.
- **`engines.md` was authored by another seat.** This seat verified the root-vs-subtree
  manifest commands, the two-state binaries, the two full receipts, `run_gate` count 1, and
  the stale `SKILL.md` stamp. It did not re-run every command the new census cites.
- **Gate scratch was `$HOME`, not `/tmp`.** A default-`/tmp` gate run was not attempted.
