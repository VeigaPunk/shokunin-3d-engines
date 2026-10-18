# `gate/` — self-contained close-out gate for the r101 unreal-mcp subtree

**Author:** SEAT-17 GATE-AUTHOR · round 102 · lane `game-dev-3d-shokunin`
**Written:** 2026-10-18
**Scope:** `corpus/knowledge/unreal-mcp/` (the r101 subtree, vendored at work commit
`1659c036`, HEAD at authoring `2c99b7b`).
**Run:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`

This gate re-derives its own evidence. It reads nothing from any author's transcript, and it
requires no file outside the subtree except a fresh clone of the pinned upstream repo. Run it
from anywhere; it resolves the subtree relative to its own location.

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
```

**No Unreal runtime claim.** Unreal Editor is not installed on this host, so nothing here can
promote an `unproven-runtime` card to `verified-here`. The strongest statement the gate makes
is: *the vendored bytes are byte-identical to the pinned upstream commit, and these static
checks ran here.* A green gate is not evidence of live-editor behavior and must never be cited
as such.

> **Hardening history (r102 close, 2026-10-18).** The gate as first landed had
> demonstrated false-pass classes (symlinked files, 14th cards via subdir or
> symlink, substring labels, CRLF manifests, unread seat shards, shadowed/absent
> tools, extensionless `upstream/LICENSE`-style pointers) — see
> `reports/round-102/gate/adversary-a.md`, `adversary-b.md` and `fold-spec.md`
> items A1–A9. The r102 close adopted the seat-verified hardened implementation
> plus an L1 tool-requirement guard (`git sha256sum grep find sort comm` absent →
> exit 1) and the extensionless-pointer alternative pattern; the 12-attack suite
> re-ran against the installed script.
>
> **r103 (2026-10-18).** The residual queue routed from r102 was closed in the script:
> **A1** — CHECK 4 now validates *every* endpoint of a `:a-b` range / `:a,b` list and counts
> endpoints (`POINTERS`) alongside the unique strings (`POINTER_STRINGS`); **A2** — CHECK 3's
> declaration rule is now anchored to the five real label shapes, so a prose sentence mentioning a
> token can no longer hijack it; **A3** — the 13 card filenames are compared against a pinned set
> in both directions (`NAME_SET=OK`); **A4** — an unreachable upstream is a distinct `BLOCKED`
> state with exit **2**, not a folded FAIL. The scanner sha256 is now `577c8b54…`; the expected
> values below were re-measured against it (the earlier `POINTERS=87` pin was stale — see the pin
> correction note). The r104 scanner sha256 is `e5521304…` and the current pin is `POINTERS=103`
> (see the r104 note below).
>
> **r103b (2026-10-18, SEAT-09 HARDENING-AUTHOR).** Two host-dependent defects in the script
> itself, both found while running the A4 controls and both fixed in the same pass: (a) the
> per-seat manifest sweep wrote its log to a hardcoded `/tmp/advgate/.h1`, so on any host without
> that directory the redirect failed, `sha256sum` never ran, and a **clean** tree printed
> `FAIL per-seat manifest sweep` and exited 1 — now `mktemp`; (b) the check-4 repo root reused the
> variable name `REPO`, which is also the upstream clone URL at the top of the file, so the
> obvious way to exercise the BLOCKED path (`REPO=<url> run_gate.sh`) silently repointed pass B and
> emitted ~26 spurious `MISSING-PATH-REL` — now a distinct `REPO_ROOT`. Controls A1–A4 (11 rows,
> including a clean control) are recorded in `reports/round-103/gate/hardening.md`.
>
> **r104 (2026-10-18, SEAT-12 GATE-WORKDIR-AUTHOR).** The r103 close window left two unexplained
> anomalies (`reports/round-103/gate/close-runs.md`): one run printed `GATE RESULT: FAIL` with
> CHECK 4 PASS, and one run produced **empty output with exit 1**. Both are the same defect class —
> the gate's two scratch sites were plain `mktemp`, i.e. hardcoded to `/tmp`, a 16G tmpfs shared
> with the user's other sessions under a per-user quota. This seat **reproduced both live** and
> fixed the class. See "Running under quota pressure" below.

## Running under quota pressure

Both of this gate's scratch sites — the manifest log and CHECK 2's clone workdir — live under

```
WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
```

**The r103 root cause.** On this host `/tmp` is a 16G tmpfs shared with the user's other sessions
under a per-user quota, and it runs near full (observed 77–80% used, ~3 GB free). When it is
exhausted, `git clone` dies with

```
error: copy-fd: write returned: Disk quota exceeded
fatal: cannot copy '…/templates/description' to '…/.git/description': Disk quota exceeded
```

and the consequences were worse than the error:

- **A local disk failure was reported as a network failure.** CHECK 2's clone-failure branch was
  reached identically by "upstream unreachable" and "scratch filesystem full", so a quota-exhausted
  host printed `CHECK 2 BLOCKED (network)` and sent the reader to the wrong subsystem. (r103's
  SEAT-01 recorded exactly this: "CHECK 2 flaky … while the network was demonstrably up".)
- **The diagnostic destroyed itself.** The clone's stderr was redirected to `$WORK/clone.log` — on
  the same full filesystem — so the log was created empty and the `BLOCKED` branch printed no cause
  line at all.
- **A clean tree could flake or print nothing.** Allocation failures under pressure surfaced as
  silent or misleading failures, including the empty-output exit-1 run.

**What to do.** If a run looks wrong — an unexpected `BLOCKED`, an empty output file, a check that
fails on a tree you believe is clean — point the scratch at a filesystem with room and re-run:

```sh
GATE_WORKDIR=/home/you/scratch corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
```

`TMPDIR` is honoured too (this is the POSIX convention most tools already follow), and `GATE_WORKDIR`
takes precedence over it. `/tmp` remains the default, so every existing caller behaves as before.
The gate now prints the choice and the room left on every run:

```
WORK_ROOT=/tmp (from default)
WORK_ROOT_FREE=3.2G of 16G (80% used)
```

and **validates the root before running any check** — a typo'd or non-writable `GATE_WORKDIR` is a
named `FAIL` up front, not an obscure failure later. The value reported in `(from …)` is
`GATE_WORKDIR`, `TMPDIR`, or `default`.

If the clone fails for a **local resource** reason, CHECK 2 now says so instead of blaming the
network:

```
CHECK 2 BLOCKED (local-resource)
BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted
BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream
BLOCKED retry with GATE_WORKDIR (or TMPDIR) on a roomy filesystem — see gate/README.md
```

The exit code is still **2**: this is a cause classification, not a new state — the A4 contract
(`BLOCKED` ⇒ 2) is unchanged, and the header for a genuine network block still reads exactly
`CHECK 2 BLOCKED (network)`.

**Two recorded limits of this fix.** (1) It cannot make a full filesystem work; it makes the
failure *legible and avoidable*. (2) A caller who sets neither variable on a quota-pressured host
still gets the old behaviour — the default is unchanged on purpose, because silently relocating
scratch is a surprise for a close-out artifact. The banner line is the signal to look.


## Pinned constants

| constant | value |
|---|---|
| upstream repo | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` |
| upstream pin | `a6aa73ada02a9fb1f5415bec491f9942c519b297` (`main`) |
| tracked upstream files | `12` |
| reference manifest | `.manifest.d/audit-reference.sha256` |

## The four checks

### CHECK 1 — manifest byte-identity

`sha256sum -c .manifest.d/audit-reference.sha256`, run with the subtree as cwd. Recomputes
every vendored file's sha256 from its bytes and compares against the committed manifest.

**Expected:** `MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0`, then `STEP=PASS`.

### CHECK 2 — clone equivalence against a fresh clone at the pin

Clones the repo into a `mktemp` directory (removed on exit) and requires:

- `2a` the clone's `HEAD` equals the pin **exactly** — a `main` that has moved past the pin is
  a FAIL, because the subtree's claim is "vendored at this SHA", and re-vendoring against a
  newer commit would be a different claim;
- `2b` the clone worktree is clean (`git status --porcelain` empty);
- `2c` **path-set equality both ways** — vendored `upstream/` files vs `git ls-files`
  (`PATH_EXTRA=0` and `PATH_MISSING=0`). A tree can pass every hash check and still be
  *incomplete* (a file never copied) or *over-full* (a stray file added); only this check
  catches both;
- `2d` **per-file byte-identity against the clone's blobs** — `sha256sum` of the vendored file
  vs `git show <pin>:<path>`. This is the strongest form: a manifest can be regenerated from a
  corrupted tree, this comparison cannot.

**Expected:** `CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297`, `CLONE_DIRTY=0`,
`CLONE_TRACKED=12`, `PATH_EXTRA=0`, `PATH_MISSING=0`, `BLOB_DIFFS=0`, then `STEP=PASS`.

**BLOCKED is a third state, not a flavour of FAIL.** This is the only check needing network. When
the clone cannot complete (upstream unreachable), the gate prints a distinct signal — `CHECK 2
BLOCKED (network)`, `BLOCKED fresh clone could not complete …`, `BLOCKED exit 2 is not a verdict:
the vendored bytes are UNCHECKED, not divergent` — CHECK 2 prints `STEP=BLOCKED`, and the run exits
**2** (see "Exit codes"). A blocked check is deliberately *not* counted in `FAILS`: the exit code,
not the summary line, carries the distinction, so a reader can never mistake "this host had no
network" for "the vendored bytes diverge". `GATE_REF=<path>` names an existing clone at the pin for
air-gapped runs; with it set, no network is touched and the check is scored normally (a *bad*
`GATE_REF` is a genuine FAIL, not BLOCKED). Do not substitute a cached clone for a fresh one
without saying so.

### CHECK 3 — verdict-card scan

Scans `executability/*.md`. The rule (ported from
`reports/round-101/r101-verification-protocol.md` §4, which the cards legitimately vary in
formatting under — the five observed declaration shapes are `**Label:** \`X\``, `**Label:**\`X\`**`,
`**Label:** **\`X\``, `**\`X\`**`, and `# Label: \`X\``, where `Label` may also be `Verdict` and may
carry a ` label` suffix):

1. the **first line that is a declaration** is the declared label — the line must be **anchored**,
   i.e. start (leading whitespace allowed) with one of those five shapes. A prose sentence that
   merely *mentions* a token ("this card is emphatically not `verified-here`") is not a
   declaration and cannot hijack the rule;
2. the declaration must appear within the first **40** lines — a label buried in §7 is not a
   declaration;
3. it must be **bold- or heading-marked** (`**` or `#`) — implied by the anchored shapes above;
4. it must carry **exactly one** allowed token — "not `verified-here`, and not
   `unproven-runtime`" is ambiguous and fails.

**Expected:** `CARDS=13 EXPECTED=13 BAD=0`, `NAME_SET=OK NAME_BAD=0`, census
`static-only=12 unproven-runtime=1 verified-here=0`, then `STEP=PASS`.

**The card-name set is pinned on purpose.** The 13 file stems under `executability/` are compared
against the pinned set below, in both directions (missing and extra). A count-only check let a card
be silently dropped-and-replaced under a typo'd or renamed filename with the gate still green. The
set is the r101 declared 13 (`corpus/knowledge/unreal-mcp/README.md` card table):

```
PINNED_CARD_NAMES='actors-scene animation-controlrig assets-content blueprints editor-general
  gameplay-gas materials meshes-textures scripting-programmatic sequencer testing-automation
  ui-umg-slate vfx-niagara-dataflow'
```

`run_gate.sh` carries the same list as its `PINNED_CARD_NAMES` constant; **the two must be edited
together** — a set that drifts from the script's copy is a silent expectation mismatch.

**The census is pinned on purpose.** `verified-here=0` is not incidental: on a host with no
Unreal Editor, a `verified-here` card is a red flag, and the gate fails rather than let one
through. A census that drifts (e.g. a second `unproven-runtime`) is a **relabel**, which is a
semantic change to the subtree's claims and must be an explicit, reviewed decision — not a
silent edit that leaves the gate green.

### CHECK 4 — pointer sweep

Every `upstream/<path>:<line>` pointer in the subtree's own markdown must resolve against the
subtree root and be in range. Exclusions, all deliberate and all counted so they cannot hide a
real failure:

- anything under `upstream/` — the vendored upstream text is not this round's prose;
- **`gate/README.md` — this file, the gate's own specification.** Its worked examples below
  plant deliberately-broken pointers, and auditing a checker against its own specification is a
  false positive by construction;
- **exact** control sentinels `upstream/nope.md:<N>`, `upstream/README.md:9999`,
  `upstream/README.md:500` — a second line of defence, because peers' reports quote this
  README verbatim and would otherwise re-import its broken strings. This is an **EXACT-match
  filter, NOT a keyword filter**: a real pointer that happens to sit on a line containing the
  word "control" is still counted. `SKIPPED_CONTROL_SENTINELS` is printed and expected to be
  `0` on a clean subtree; a large or growing value means the filter is eating real pointers.

**The sweep is two passes, and the self-exclusion applies to only the first.** Pass A scans
`upstream/<path>:<line>` pointers (self-file excluded, per the second bullet). Pass B scans
backtick-wrapped repo-relative paths (`corpus/…`, `reports/…`, `executability/…`, …) across
`--include='*.md'` with **no self-exclusion**, so this README's own worked examples — including the
control pointers and the paths in its own prose — are counted by pass B. `POINTERS` is the sum of
both. This asymmetry is recorded, not fixed: it is the reason the count is self-referential and
moves on any edit here, and it is queued as a doc-level observation rather than silently changed
(pass B still resolves every path it counts, so a self-inclusion cannot mask a real failure —
`UNRESOLVED` is unaffected). A hardening that applies the self-exclusion to pass B is routed to a
future round; until then, treat `POINTERS` as a measurement of *this scanner on this tree*.

**Expected (re-measured 2026-10-18T19:24Z at lane HEAD `88c3b2c`, scanner `run_gate.sh` sha256 `e5521304…`, subtree `adaptation-kimi.md` sha256 `084a34cd…`):** `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`, then `STEP=PASS` (pass A = 47 endpoints from 41 strings, pass B = 56).

Two numbers are printed, because **A1 (r103) validates every endpoint**. `POINTERS` counts
**endpoints** — one increment per line number, so a `:4-5` range is two and a `:61,70-79` list is
four. `POINTER_STRINGS` counts the unique pointer *strings* those endpoints came from, which is the
number that matched the old, endpoint-blind count. Before A1 the gate read a range as its first
number only, so a planted `upstream/README.md:1-9999` resolved as the in-range `:1`; the reference
sweep (`reports/round-102/reruns/pointer-sweep.sh`) always resolved every endpoint, and this check
now shares its semantics.

The pointer count is **scanner- and tree-relative**, not a constant: it is whatever THIS gate extracts from the subtree *as it stands*, and it moves whenever any prose file under the subtree gains or loses a backtick-wrapped path. Do not compare it across scanners (r101 measured 40 with a narrower regex) or across tree revisions. The binding invariant is `UNRESOLVED=0`; the count is an advertised measurement, not a contract. It is also self-referential — **editing this README's own prose changes it**, because sweep B (below) counts this file. See the pin correction note under "Calibrating the gate".

## Expected output — pinned summary

A clean run prints these seven lines and exits `0` (the banner also carries `WORK_ROOT=…` and
`WORK_ROOT_FREE=…` — see "Running under quota pressure"):

```
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297   (with CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0)
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

| quantity | pinned value |
|---|---|
| manifest lines `OK` | `12` |
| clone HEAD | the pin |
| tracked upstream files | `12` |
| cards | `13` |
| pinned card-name set | the 13 stems above, both directions |
| label census | `12 / 1 / 0` |
| pointer endpoints / strings (scanner-relative, `run_gate.sh` sha256 `e5521304…`) | `103` / `41` |
| pointers unresolved | `0` |

## Exit codes

Exit codes are strict and fail-closed, with a declared third state for a check that **could not
run**:

- **`0`** — every check printed `STEP=PASS`. Clean.
- **`1`** — at least one check printed `STEP=FAIL`. There is no partial-pass state: a missing
  artifact is a FAIL, not a warning.
- **`2`** — CHECK 2 printed `STEP=BLOCKED` (the fresh clone could not complete) and no other check
  failed. This is **not** a pass and **not** a verdict: the vendored bytes are *unchecked*, not
  divergent. The code, not the summary line, carries the distinction. `GATE RESULT` still reads
  `PASS`/`FAIL`/`BLOCKED` so no existing caller keying on that line breaks.

One residual, recorded rather than hidden: when CHECK 2 is BLOCKED **and** another check also
fails, the gate prints `GATE RESULT: FAIL` and exits `1` — the third state is lost in the mixed
case, and a reader cannot tell "check 2 could not run" from "the bytes diverge". Reported by
`reports/round-103/gate/exit-codes.md`; the fix is a future-round decision, not silently applied
here.

## Calibrating the gate (negative controls)

A scan that passes everything is worthless. These mutation controls (C1–C6, plus C7 where listed) must each turn the gate red.
Run them on a **copy** of the subtree, never on the pinned tree itself.

```sh
SUB=corpus/knowledge/unreal-mcp
T=$(mktemp -d); cp -r "$SUB" "$T/sub"

# C1 — flip one vendored byte → CHECK 1 must fail
printf '\n' >> "$T/sub/upstream/README.md"
# C2 — delete a vendored file → CHECK 1 and CHECK 2 must fail
rm "$T/sub/upstream/LICENSE"
# C3 — plant a plausible out-of-range pointer → CHECK 4 must fail
printf '\nsee upstream/README.md:200\n' >> "$T/sub/README.md"
# C4 — duplicate a card label token on its label line → CHECK 3 must fail
sed -i '4s/.*/**Label:** `static-only` and not `verified-here`/' \
    "$T/sub/executability/blueprints.md"
# C5 — census drift: relabel a card → CHECK 3 must fail
sed -i '4s/.*/**Label:** `unproven-runtime`/' "$T/sub/executability/blueprints.md"
# C6 — remove a card → CHECK 3 must fail (count 12 != 13)
rm "$T/sub/executability/sequencer.md"
```

Because `run_gate.sh` resolves the subtree from its own location, a copied tree is gated by
copying `gate/` with it (`cp -r` above does that). The mutation must be *inside* `$T/sub` for
the gate to see it.

**Observed control matrix (2026-10-18, this host).** Every control was actually run on a
throwaway copy; the exit code and the failing check are as recorded:

| control | mutation | exit | failing checks | observed signal |
|---|---|---|---|---|
| C1 | append a byte to `upstream/README.md` | 1 | 1, 2 | `MANIFEST_OK=11 … FAILED=1`; `BLOB-DIFF README.md` |
| C2 | delete `upstream/LICENSE` | 1 | 1, 2 | `RC=1`; `PATH_MISSING=1`; `BLOB-DIFF LICENSE` |
| C3 | plant `upstream/README.md:200` | 1 | 4 | `LINE-OOR … (max 112)`; `UNRESOLVED=1` |
| C4 | duplicate a label token | 1 | 3 | `FAIL multi-label`; `BAD=1` |
| C5 | relabel a card `unproven-runtime` | 1 | 3 | census `11 / 2 / 0` vs expected `12 / 1 / 0` |
| C6 | remove `executability/sequencer.md` | 1 | 3 | `CARDS=12 EXPECTED=13` |
| **C7** | plant **only** the exact sentinels | **0** | none | `SKIPPED_CONTROL_SENTINELS=2`, `UNRESOLVED=0` — the exclusion is exact and stays green |

C7 is the filter's own positive control: it proves the sentinel rule skips *only* the exact
control strings and does not mask real pointers. C5 and C6 are the two controls that catch a
*censored* rather than *corrupted* tree — the failure mode a count-only check would miss.

**r103 control matrix — the four routed hardenings (A1–A4), run by SEAT-09 on 2026-10-18
against the installed script.** Each row was run on a copy of the whole repo (check 4's pass B
needs repo-relative paths to resolve) with the subtree real-copied, so no mutation touched the
pinned tree. Full transcript: `reports/round-103/gate/hardening.md`.

| control | mutation | exit | observed signal |
|---|---|---|---|
| **C0** | none (unmodified copy) | **0** | `POINTERS=101 … UNRESOLVED=0` — the harness itself is not producing the reds |
| **A1a** | plant `upstream/README.md:1-9999` | 1 | `LINE-OOR … (max 112)`; `UNRESOLVED=1` — the **tail** is now validated |
| **A1b** | plant `upstream/hooks/hooks.json:4-99` | 1 | `LINE-OOR … (max 17)`; `UNRESOLVED=1` |
| **A1c** | plant a *valid* `upstream/README.md:39,45` | 0 | `UNRESOLVED=0` — the range form is not simply rejected |
| **A2a** | prose line naming a token **above** the declaration | **0** | `BAD=0` — the hijack no longer satisfies the rule (was `FAIL label-unmarked` before r103) |
| **A2b** | anchored line with two tokens | 1 | `FAIL multi-label` |
| **A2c** | prose-only, declaration removed | 1 | `FAIL no-label` |
| **A3** | rename `sequencer.md` → `sequence-typo.md` | 1 | `FAIL card-name-missing sequencer.md` + `card-name-extra sequence-typo.md`; `NAME_SET=BAD NAME_BAD=2` |
| **A4a** | unreachable `REPO`, no `GATE_REF` | **2** | `CHECK 2 BLOCKED (network)`; `STEP=BLOCKED`; `GATE RESULT: BLOCKED (checks failed: 0; …)` |
| **A4b** | unreachable `REPO`, valid `GATE_REF` | **0** | `GATE_REF=… (offline reference; no clone attempted)`; `BLOB_DIFFS=0`; `STEP=PASS` |

A2a is the one row that changes a *pass* into a *pass*: before A2 the same mutation made the gate
red for the wrong reason (it misread prose as the declaration), which is a false positive, not a
catch. A4a is the only row whose exit code is `2`.

**r104 control matrix — the scratch-root change, run by SEAT-12 on 2026-10-18 against the installed
script (`run_gate.sh` sha256 `e5521304…`).** Full transcript: `reports/round-104/gate/workdir.md`.

| control | setup | exit | observed signal |
|---|---|---|---|
| **W0** | none (default `/tmp`) | **0** | `WORK_ROOT=/tmp (from default)`; `POINTERS=103 … UNRESOLVED=0`; `STEP=PASS` — the default path is unchanged |
| **W1** | `GATE_WORKDIR=<roomy dir>` | **0** | `WORK_ROOT=… (from GATE_WORKDIR)`; a 20 ms poller saw the scratch dir **created and removed** (`seen_paths=5`, `residual_after=0`) |
| **W2** | `TMPDIR=<roomy dir>`, `GATE_WORKDIR` unset | **0** | `WORK_ROOT=… (from TMPDIR)`; `residual_after=0` — the POSIX convention is honoured |
| **W3** | `GATE_WORKDIR=<nonexistent>` | **1** | `FAIL scratch root is not a directory: …` — named up front, before any check runs |
| **W4** | `GATE_WORKDIR=<full tmpfs>` | **2** | `CHECK 2 BLOCKED (local-resource)` + `BLOCKED … this is a DISK failure, not an unreachable upstream`; rc still `2` |
| **W5** | dead proxy, roomy `GATE_WORKDIR` | **2** | `CHECK 2 BLOCKED (network)` — the A4 network branch is unchanged verbatim |
| **W6** | `GATE_REF=<roomy clone>` + roomy workdir | **0** | `GATE_REF=… (offline reference; no clone attempted)`; `BLOB_DIFFS=0`; `STEP=PASS` |
| **W7** | `kill -TERM` / `kill -INT` mid-run | 143 / 130 | signal traps ran `cleanup`; `residual_after=0` in both cases |

W4 is the row this seat exists for: the same filesystem condition that r103 recorded as an
unexplained `GATE RESULT: FAIL` / empty-output flake is now a **named** cause, and W5 proves the
classification did not swallow the genuine network case. W0 is the control that the change is
inert for every existing caller.

The gate is also **cwd-independent**: running it from `/tmp` printed the same
`GATE RESULT: PASS (checks failed: 0)`.

**Pin correction note — 2026-10-18 (r103, SEAT-05 GATE-PIN-UPDATER).** The `POINTERS` pin in the
expected-value blocks above previously read `87`. Re-measured against the installed gate, the
correct values are the ones now printed above, and `87` was already stale when r102 closed — not
drift since. Evidence at the settled scanner (`run_gate.sh` sha256 `577c8b54…`):

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
exit=0
```

`87` was off by one because the r102 close measured before this README's final wording edit added
one backtick path, and pass B counts this file (see CHECK 4). Independently confirmed: the r102
close tree (`c6f655d`, extracted with `git archive` and byte-identical to HEAD under `diff -r`)
prints `88` on the r102 scanner — so the pin was already one low at commit time. The count then
walked `88 → 90 → 91 → 98 → 101` across r103, through three independent causes:

- **prose gains (88 → 91).** Pass B counts every backtick path in the subtree, so each new citation
  moves it: the C1 freshness note added two paths in `adaptation-kimi.md`, and this seat's own note
  added one more. **The last step is this README counting itself** — the self-reference made
  concrete.
- **semantics change (91 → 98).** A1 made `POINTERS` count *endpoints*, so the six range/list
  pointers in the subtree (`upstream/README.md:50-57`, `upstream/hooks/hooks.json:4-5`,
  `upstream/hooks/unreal-context.sh:5,8`, `upstream/skills/unreal-mcp/references/setup.md:61,70-79`,
  …) each expanded: pass A went from 40 strings to 47 endpoints (+7), with `POINTER_STRINGS=41`
  now carrying the old string count. This is a **scanner change**, not tree drift — which is why
  the pin is stated with a scanner sha256 rather than as a bare number.
- **this README counting itself again (98 → 101).** The r103b hardening-history paragraph and the
  r103 control matrix below name `reports/round-103/gate/hardening.md`, `adaptation-kimi.md` and the
  control paths; pass B counts all of them. Editing the pin in this file therefore moves the number
  the pin states — the same self-reference, which is why the pinned value is timestamped and
  scanner-sha'd rather than treated as a constant.

This is a **dated correction, not a rewrite**: the `87` values are superseded here with the
measured command, timestamp, and scanner sha, and the binding invariant — `UNRESOLVED=0` — never
changed. Full derivation, decomposition (pass A = 47 endpoints / 41 strings, pass B = 54), and the
off-by-one proof are in `reports/round-103/note/gate-pin.md`; the A1–A4 controls are in
`reports/round-103/gate/hardening.md`.

**Pin continuation — 2026-10-18 (r104, SEAT-12 GATE-WORKDIR-AUTHOR).** The count walked two more
steps, `101 → 103`, for the reason this section predicts: the r104 "Running under quota pressure"
section and the r104 control matrix above add backtick-wrapped paths, and **pass B counts this
file**. No tree content and no counting semantics changed — only this README's own prose. The r103
`101` rows above (the C0 control row and the r103 pin-correction block) are left as the dated r103
measurements they are; the current pin is `103` at scanner sha256 `e5521304…`, and the binding
invariant is still `UNRESOLVED=0`. The receipt is `reports/round-104/gate/workdir.md`.

**Worked example — why the pointer filter is exact, not keyword-based.** A naive keyword filter
(`control|expect|plant`) was rejected during authoring of the r101 protocol: it would have
silently skipped a **real** pointer in `executability/` whose line happens to contain the word
"control". The rule is therefore the checker's own spec file plus an exact sentinel match, and
the skip count is printed so a regression is visible.

## What this gate does not do

- It does not run Unreal Editor, the MCP server, or any live tool call. `unproven-runtime`
  stays `unproven-runtime`.
- It does not judge whether a card's label is *consistent with its evidence*. Check 3 enforces
  one-label-per-card mechanically; the semantic question — does this `static-only` card
  actually rest on a static check that ran here? — is a read-the-cards judgement that no script
  can make. `reports/round-101/r101-verification-protocol.md` §4 states the criterion; a
  verifier must apply it by hand.
- It does not check markdown links inside the vendored tree, JSON well-formedness of
  `plugin.json` / `hooks.json`, or `shellcheck` cleanliness of `unreal-context.sh`. Those are
  useful supporting checks (r101 protocol steps 6 and 9) but they are not among this gate's
  four, and their absence here must not be read as their having passed.
