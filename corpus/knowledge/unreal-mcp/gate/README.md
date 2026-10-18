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
> re-ran against the installed script. Residual queue routed to r103 (fold-spec
> A1 range-tail blindness, A2 prose-hijackable first-token rule, A3 card-name
> comparison, A4 network-blocked vs mismatch distinction).

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

**BLOCKED, not PASS.** This is the only check needing network. If the clone fails, the gate
prints `FAIL fresh clone failed … BLOCKED, not PASS`, the check fails, and the run exits 1.
Do not substitute a cached clone for a fresh one without saying so.

### CHECK 3 — verdict-card scan

Scans `executability/*.md`. The rule (ported verbatim from
`reports/round-101/r101-verification-protocol.md` §4, which the cards legitimately vary in
formatting under — observed forms include `**Label:** \`static-only\``,
`**Verdict:** \`static-only\``, `**Verdict label: \`static-only\`**`,
`Verdict: **\`static-only\`**`):

1. the **first line containing any allowed token** is the declared label;
2. it must appear within the first **40** lines — a label buried in §7 is not a declaration;
3. it must be **bold- or heading-marked** (`**` or `#`), so a prose sentence like "this is not
   `verified-here`" is not mistaken for a declaration;
4. it must carry **exactly one** allowed token — "not `verified-here`, and not
   `unproven-runtime`" is ambiguous and fails.

**Expected:** `CARDS=13 EXPECTED=13 BAD=0`, census
`static-only=12 unproven-runtime=1 verified-here=0`, then `STEP=PASS`.

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

**Expected (as measured at r102 close, 2026-10-18, on commit-to-be):** `POINTERS=87 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0`, then `STEP=PASS`. The pointer count is scanner-relative — it is whatever THIS gate extracts (`grep -rhoE` union documented in run_gate.sh check 4); do not compare it across scanners (r101 measured 40 with a narrower regex; the r102 hardening widened extraction and de-duplicates by path after stripping `:line`). The gate printing a different count than an older transcript is not drift; the binding invariant is `UNRESOLVED=0`.

## Expected output — pinned summary

A clean run prints these five lines and exits `0`:

```
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297   (with CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0)
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
POINTERS=87 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

| quantity | pinned value |
|---|---|
| manifest lines `OK` | `12` |
| clone HEAD | the pin |
| tracked upstream files | `12` |
| cards | `13` |
| label census | `12 / 1 / 0` |
| pointers unresolved | `0` |

Exit codes are strict and fail-closed: **`0`** iff all four checks print `STEP=PASS`; **`1`**
otherwise. There is no partial-pass state — a missing artifact is a FAIL, not a warning.

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

The gate is also **cwd-independent**: running it from `/tmp` printed the same
`GATE RESULT: PASS (checks failed: 0)`.

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
