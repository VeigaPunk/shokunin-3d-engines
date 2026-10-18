# r103 SEAT-09 HARDENING-AUTHOR — gate A1–A4 receipt

**Seat:** SEAT-09 HARDENING-AUTHOR · round 103 · lane `game-dev-3d-shokunin`
**Date:** 2026-10-18 · **Lane HEAD at authoring:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
**Owned paths written:** `corpus/knowledge/unreal-mcp/gate/run_gate.sh`,
`corpus/knowledge/unreal-mcp/gate/README.md`, this file.
**Axes served:** coverage (the gate is r102's coverage artifact; A1–A4 close four of its routed gaps).

**No Unreal runtime claim appears anywhere in this file.** Unreal Editor is not installed on this
host; live-MCP behaviour is unproven by construction. Nothing below promotes an `unproven-runtime`
card or asserts anything about editor behaviour. Every claim carries a command actually run here.

## 1. What was implemented

The four items routed to this seat by `reports/round-102/fold-spec.md` §2, plus two host-dependent
defects in the same file found while exercising the A4 control. All six changes are in
`gate/run_gate.sh`; `gate/README.md` documents them.

| id | change | location |
|---|---|---|
| **A1** | validate **every** endpoint of `:a-b` / `:a,b`; `POINTERS` counts endpoints, new `POINTER_STRINGS` counts unique strings | CHECK 4 sweep loop + extraction regex |
| **A2** | label rule anchored to the five real declaration shapes, so a prose mention cannot satisfy it | CHECK 3, `LABEL_RE` |
| **A3** | card filenames compared against a pinned 13-name set, both directions; `NAME_SET=OK/BAD` | CHECK 3, `PINNED_CARD_NAMES` |
| **A4** | unreachable upstream is a distinct `BLOCKED` state: `CHECK 2 BLOCKED (network)`, `STEP=BLOCKED`, exit **2**; optional `GATE_REF=<path>` for air-gapped runs | CHECK 2 + exit-code block |
| **E1** | per-seat manifest sweep wrote to a hardcoded `/tmp/advgate/.h1`; now `mktemp` | HARDENING B block |
| **E2** | check 4's repo root reused the variable name `REPO` (also the clone URL); renamed `REPO_ROOT` | HARDENING G block |

E1 and E2 were **not** in the routed queue. They were found by running the A4 control: the control
that overrides `REPO` to an unreachable URL is exactly what exposed E2, and E1 surfaced when
`/tmp/advgate` was absent.

## 2. Clean-tree receipt

Run against the pinned subtree on the real tree (not a copy):

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=c85a816e227984272a3c29b58aa7f7c1a76f1e9c

MANIFEST_FILES=12
CHECK 1 manifest-byte-identity
... 12 x "upstream/<path>: OK"
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
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
OK   static-only      assets-content.md              line 15
OK   static-only      blueprints.md                  line 4
OK   static-only      editor-general.md              line 4
OK   static-only      gameplay-gas.md                line 4
OK   static-only      materials.md                   line 4
OK   static-only      meshes-textures.md             line 4
OK   static-only      scripting-programmatic.md      line 5
OK   static-only      sequencer.md                   line 5
OK   static-only      testing-automation.md          line 5
OK   static-only      ui-umg-slate.md                line 5
OK   static-only      vfx-niagara-dataflow.md        line 6
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

Static properties re-checked on the final file:

```
$ bash -n corpus/knowledge/unreal-mcp/gate/run_gate.sh      # exit 0
$ shellcheck corpus/knowledge/unreal-mcp/gate/run_gate.sh   # exit 0, no output
```

`shellcheck` needed one `# shellcheck disable=SC2016` at the top of the file: check 4's pointer
regexes use **literal** backticks (markdown delimiters), which SC2016 misreads as attempted command
substitution. The directive is file-level because placing it before the loop body broke
shellcheck's own parser (SC1123/SC1072/SC1073).

### Pointer-count decomposition

`POINTERS` counts endpoints; `POINTER_STRINGS` counts unique pointer strings. Measured:

```
pass A (upstream/<path>:<line>, self-file excluded) = 47 endpoints from 41 strings
pass B (backtick repo-relative paths, *.md)         = 54
total                                               = 101
```

The `87` pin in `gate/README.md` was already stale at r102 close; `reports/round-103/note/gate-pin.md`
(SEAT-05) independently proved that. This seat re-measured rather than trusting either number.

## 3. Control matrix — A1–A4

Harness: a **symlink farm** of the whole repo (`cp -as`) with the `unreal-mcp` subtree
**real-copied** on top, so check 4's pass B resolves repo-relative paths while every mutation stays
inside the copy. No mutation touched the pinned tree. The script was re-read from the live tree per
run.

| control | mutation | exit | observed |
|---|---|---|---|
| **C0** | none | **0** | `POINTERS=101 UNRESOLVED=0` — harness is not manufacturing the reds |
| **A1a** | plant `upstream/README.md:1-9999` | 1 | `LINE-OOR … (max 112)`; `UNRESOLVED=1` |
| **A1b** | plant `upstream/hooks/hooks.json:4-99` | 1 | `LINE-OOR … (max 17)`; `UNRESOLVED=1` |
| **A1c** | plant a valid `upstream/README.md:39,45` | **0** | `UNRESOLVED=0` — the range form is not blanket-rejected |
| **A2a** | prose naming a token **above** the declaration | **0** | `BAD=0` — pre-r103 this was `FAIL label-unmarked` |
| **A2b** | anchored line carrying two tokens | 1 | `FAIL multi-label` |
| **A2c** | declaration replaced by prose only | 1 | `FAIL no-label` |
| **A3** | rename `sequencer.md` → `sequence-typo.md` | 1 | `card-name-missing sequencer.md`, `card-name-extra sequence-typo.md`, `NAME_SET=BAD NAME_BAD=2` |
| **A4a** | unreachable `REPO`, no `GATE_REF` | **2** | `CHECK 2 BLOCKED (network)`, `STEP=BLOCKED`, `GATE RESULT: BLOCKED (checks failed: 0; …)` |
| **A4b** | unreachable `REPO`, valid `GATE_REF` | **0** | `GATE_REF=… (offline reference; no clone attempted)`, `BLOB_DIFFS=0`, `STEP=PASS` |

Representative transcripts:

```
=== A1-range-tail-9999                 exit=1 want=1 [OK]
    NAME_SET=OK NAME_BAD=0
    POINTERS=103 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
    GATE RESULT: FAIL (checks failed: 1)

=== A2-prose-hijack                    exit=0 want=0 [OK]
    NAME_SET=OK NAME_BAD=0
    POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
    GATE RESULT: PASS (checks failed: 0)

=== A3-renamed-card                    exit=1 want=1 [OK]
    FAIL card-name-missing sequencer.md
    FAIL card-name-extra sequence-typo.md
    NAME_SET=BAD NAME_BAD=2
    GATE RESULT: FAIL (checks failed: 2)

=== A4-unreachable-no-ref              exit=2 want=2 [OK]
    CHECK 2 BLOCKED (network)
    BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
    BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
    STEP=BLOCKED
    GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)

=== A4-GATE_REF-offline                exit=0 want=0 [OK]
    GATE_REF=/tmp/r103ctl/ref (offline reference; no clone attempted)
    BLOB_DIFFS=0
    GATE RESULT: PASS (checks failed: 0)
```

Notes that matter:

- **A2a is a pass→pass change.** Before A2 the same mutation made the gate *red for the wrong
  reason* — it read the prose sentence as the declaration and failed on `label-unmarked`. That is a
  false positive, not a catch; A2 removes it while A2b/A2c confirm the rule still catches real
  label defects. `reports/round-102/fold-spec.md` §A2 asked for exactly this pair.
- **A1c is the guard against over-correction.** Widening the regex and looping endpoints could have
  broken ordinary `:a,b` citations; it does not — a valid comma pointer stays green.
- **A4a is the only exit 2.** A4b proves `GATE_REF` scores normally offline; a *bad* `GATE_REF`
  (not a git clone) is a genuine FAIL, not BLOCKED, by construction in the script.

### Residual, recorded not hidden

When CHECK 2 is BLOCKED **and** another check also fails, `FAILS > 0`, so the gate prints
`GATE RESULT: FAIL` and exits 1 — the third state is lost in the mixed case. This is stated in
`gate/README.md` §"Exit codes" and in `reports/round-103/gate/exit-codes.md`. It is not fixed here:
choosing between "BLOCKED wins" and "FAIL wins" is a caller-contract decision, and every existing
caller keys on `PASS`/`FAIL` today.

## 4. The two unqueued defects (E1, E2)

**E1 — hardcoded scratch path.** `run_gate.sh` wrote the per-seat manifest sweep log to
`/tmp/advgate/.h1`, a directory created by a *different* seat's r102 test harness. Reproduced by
moving that directory aside:

```
$ mv /tmp/advgate /tmp/advgate.hidden && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
corpus/knowledge/unreal-mcp/gate/run_gate.sh: line 65: /tmp/advgate/.h1: No such file or directory
FAIL per-seat manifest sweep (--strict) failed:
sed: can't read /tmp/advgate/.h1: No such file or directory
...
RC=1
```

A **clean** tree exited 1. The check never ran; only the redirect failed. Fixed with `mktemp`. This
is the same class as the r101 S-5 defect (unqualified/host-dependent assumptions inside a checker),
and it is worse than a missing check: it is a spurious fail-closed on a green tree, which trains a
reader to ignore the gate's red.

**E2 — `REPO` name collision.** Line 31 sets `REPO` to the upstream clone URL; the check-4 pass-B
root was also called `REPO` (line 315). Overriding the clone target — the obvious way to test the
BLOCKED path, and what this seat's own first A4 control did — repointed pass B at a nonexistent
directory:

```
$ REPO=https://github.com/…/nonexistent bash run_gate.sh | grep -c MISSING
26
```

26 spurious `MISSING-PATH-REL` rows on a tree where every path exists (verified individually with
`test -e`). Renamed the check-4 root to `REPO_ROOT`; the collision is gone and A4a now reports
`UNRESOLVED=0` with a clean BLOCKED signal.

## 5. README updates

`gate/README.md` gained: the r103 hardening-history entry and the r103b entry for E1/E2; the
anchored label rule with the five shapes; the pinned card-name set and its "edit both copies"
warning; the `POINTERS` vs `POINTER_STRINGS` distinction; the two-pass sweep explanation; a
three-state exit-code section (0/1/2); the r103 control matrix; and the re-measured pins
(`POINTERS=101 POINTER_STRINGS=41`, scanner sha256 `577c8b54…`).

**Concurrent-editor collision, recorded.** `gate/README.md` is this seat's owned file, but
**SEAT-05 GATE-PIN-UPDATER** was editing it concurrently (its pin-correction note, its exit-codes
residual, its hardening-history paragraph). This seat did **not** revert any of that work: where
SEAT-05's text was already correct it was left verbatim, and only the numbers that the final
scanner sha invalidated were re-measured and updated. The one thing this seat could not reconcile is
that the file states its own pointer count, so **each edit to it moves the number it states** — the
pin is therefore recorded with a timestamp and scanner sha rather than as a constant. This
collision is reported upward; per-file ownership was not honoured by the concurrent seat.

## 6. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# clean receipt
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"

# static properties
bash -n corpus/knowledge/unreal-mcp/gate/run_gate.sh && shellcheck corpus/knowledge/unreal-mcp/gate/run_gate.sh

# the pinned subtrees are untouched by this seat's edits (upstream/ and .manifest.d/ are read-only)
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md
git status --porcelain corpus/knowledge/unreal-mcp/
```

## 7. Limits

- Every control above was run on a **copy** under `/tmp` (symlink farm + real-copied subtree). No
  mutation touched the pinned tree; the pinned `upstream/` and `.manifest.d/` bytes are unmodified
  by this seat, which CHECK 1 and CHECK 2 confirm on every clean run.
- **No Unreal runtime claim is made or implied.** The editor is not installed; `unproven-runtime`
  stays `unproven-runtime`; live-MCP is unproven by construction.
- The gate is still a **manual** artifact — nothing runs it unless a seat remembers to
  (`reports/round-102/fold-spec.md` §C1, still open). A1–A4 make the gate more trustworthy; they do
  not make it automatic.
- The `POINTERS` value in this receipt and in `gate/README.md` is a measurement of *this scanner on
  this tree at this timestamp*, not a contract. The binding invariant is `UNRESOLVED=0`.
