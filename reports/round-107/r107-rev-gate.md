# r107-REV-GATE — independent verification of the close-out gate draft

Seat KEY=REV-GATE · round 107 (3D side-round) · lane game-dev-3d-shokunin · 2026-10-19.
Target: `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
`sha256=390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf` (442 lines),
spec `gate/README.md` `sha256=e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`.
Harness: `reports/round-107/mutations/rev-gate-discriminate.sh` (28 cases + probes).
Scratch: `/var/tmp/r107-rev-gate/`. Labels: [O] observed here w/ command, [I] inference, [?] unknown.

## Verdict

**The gate is a real discriminator, with one class of documented behaviour it does not actually
have and one enumeration gap.** On a clean tree it accepts, and every corruption I planted in an
enumerated location is rejected with the intended exit code and detector line. But:

- **F-A (false positive, contradicting its own spec).** The control-sentinel exclusion applies to
  CHECK 4 **pass A only**; pass B counts the same sentinel and turns the gate **red**. The
  backticked form `upstream/nope.md:3` — *the form `gate/README.md`'s own prose uses* — exits **1**
  with `MISSING-PATH-REL upstream/nope.md`. Planted inside `gate/README.md` itself, the gate still
  exits **1**. This directly contradicts the documented positive control C7.
- **F-B (false negative, enumeration gap).** A stray file at the **subtree root**
  (`corpus/knowledge/unreal-mcp/EXTRA.md`, `NOTES.txt`) is **invisible** — the gate prints
  `GATE RESULT: PASS` and exits **0**. The gate enumerates `upstream/`, `executability/` and
  `.manifest.d/`, but never the subtree root.
- **F-C (stale pin in the spec).** `gate/README.md` pins the scanner sha256 as `e5521304…` in five
  places; the installed `run_gate.sh` is `390a25ae…`. [O]
- **F-D (unreproducible control).** C7's stated command (one line, `… :3 and … :9999`) exits **1**,
  not the documented 0, because pass A sees the two sentinels as one merged pointer string.

F-A and F-B are the ones that matter for a close-out gate: F-A is a spurious red (a clean tree can
be made to fail by quoting the gate's own control), F-B is a spurious green (arbitrary content at
the subtree root passes). Everything else in the matrix behaved exactly as designed.

## 1. Accept control — clean tree is green and matches the pin

**[O]** `GATE_WORKDIR=/var/tmp/r107-rev-gate/work corpus/knowledge/unreal-mcp/gate/run_gate.sh`
from the real repo, lane HEAD `3ea02ff`:

```
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=3ea02ffaafc6c618bb97a19f103a3d28ecdc2638
MANIFEST_FILES=12
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0   STEP=PASS
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0   STEP=PASS
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0                      STEP=PASS
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0   STEP=PASS
GATE RESULT: PASS (checks failed: 0)        exit=0
```

Every value matches the README's pinned summary block exactly, including `POINTERS=103/41`.
This is the accept-clean control: the harness (skeleton root + real subtree copy) is not itself
producing reds, and the gate does not spuriously fail on the delivered tree. [O]

## 2. Discrimination matrix — 28 cases

Method: for each case a **throwaway skeleton repo root** is built under
`/var/tmp/r107-rev-gate/cases/<case>/` holding a **real copy** of the subtree plus symlinked
siblings (CHECK 4 pass B resolves `corpus/…`/`reports/…` against `REPO_ROOT=$SUB/../../..`, so the
skeleton is required for pass B to resolve, not to weaken the gate). The mutation is applied there,
its landing is **confirmed** by a per-case `LANDED[…]` probe, then the **unmodified** gate runs from
the copy. The pinned tree is never touched.

| # | case | expected | actual | detector that fired |
|---|---|---|---|---|
| 1 | accept-clean | 0 | **0** | all four `STEP=PASS` |
| 2 | accept-sentinel-only | 0 | **1** | **F-A** — see §3 |
| 3 | accept-prose-above-label | 0 | **0** | prose mention does not hijack (A2 closed) |
| 4 | accept-valid-range | 0 | **0** | `:39,45` in range, `UNRESOLVED=0` |
| 5 | reject-byteflip | 1 | 1 | `MANIFEST_OK=11 FAILED=1`; `BLOB-DIFF README.md` |
| 6 | reject-strayfile (`upstream/PLANTED-EXTRA.md`) | 1 | 1 | `PATH_EXTRA=1` |
| 7 | reject-delfile (`upstream/LICENSE`) | 1 | 1 | `PATH_MISSING=1`; `BLOB-DIFF LICENSE` |
| 8 | reject-delcard (`sequencer.md`) | 1 | 1 | `CARDS=12 EXPECTED=13`; `card-name-missing` |
| 9 | reject-relabel-census | 1 | 1 | `CENSUS 11/2/0` vs `12/1/0` |
| 10 | reject-multilabel | 1 | 1 | `FAIL multi-label`; `BAD=1` |
| 11 | reject-oor-pointer (`:200`) | 1 | 1 | `LINE-OOR … (max 112)`; `UNRESOLVED=1` |
| 12 | reject-manifest-corrupt | 1 | 1 | `MANIFEST_OK=11 FAILED=1` |
| 13 | reject-manifest-drop-line | 1 | 1 | `MANIFEST_OK=11 EXPECTED=12 FAILED=0 RC=0` → `STEP=FAIL` |
| 14 | reject-card-rename (`sequence-typo.md`) | 1 | 1 | `card-name-missing` + `card-name-extra`; `NAME_SET=BAD` |
| 15 | reject-symlink-in-upstream | 1 | 1 | `FAIL non-regular file in pinned tree` (r102 F1 closed) |
| 16 | reject-nested-card (`executability/sub/`) | 1 | 1 | `FAIL nested entry under executability/` (F2 closed) |
| 17 | reject-crlf-manifest | 1 | 1 | `FAIL CR byte in manifest` (F4 closed) |
| 18 | reject-per-seat-manifest (`seat01` zeroed) | 1 | 1 | `FAIL per-seat manifest sweep (--strict)` (F5 closed) |
| 19 | reject-oor-range (`:1-9999`) | 1 | 1 | `LINE-OOR`; `UNRESOLVED=1` (A1 tail validated) |
| 20 | reject-wrong-pin-constant | 1 | 1 | `FAIL clone HEAD != pin`; `BLOB_DIFFS=12` |
| 21 | reject-14th-card (`zz-extra.md`) | 1 | 1 | `CARDS=14 EXPECTED=13`; `card-name-extra` |
| 22 | reject-nonmd-card (`notes.txt`) | 1 | 1 | `FAIL non-markdown file in executability/` |
| 23 | reject-label-too-deep (line 196) | 1 | 1 | `FAIL label-too-deep`; `BAD=1` |
| 24 | reject-label-unmarked (`Label: static-only`) | 1 | 1 | `FAIL no-label` — unanchored line is not a declaration (A2 closed) |
| 25 | reject-no-label | 1 | 1 | `FAIL no-label`; `BAD=1` |
| 26 | reject-missing-ptr-path (`upstream/DOES-NOT-EXIST.md:3`) | 1 | 1 | `MISSING-PATH`; `UNRESOLVED=1` |
| 27 | blocked-unreachable-repo (`REPO=127.0.0.1:9`) | 2 | **2** | `CHECK 2 BLOCKED (network)`; `STEP=BLOCKED` |
| 28 | reject-bad-gate-ref (`GATE_REF=<non-clone>`) | 1 | 1 | `FAIL GATE_REF is not a git clone` |

Suite receipt: `cases=28 mismatches=1`, the single mismatch being case 2 (F-A). Raw transcript
`/var/tmp/r107-rev-gate/run-full.txt`; per-case logs `/var/tmp/r107-rev-gate/logs/<case>.txt`.
**[O]** All r102 attack classes F1–F6 that I re-planted are now closed: F1 symlink (row 15),
F2 nested card (row 16), F3 substring label (rows 3, 10, 24), F4 CRLF manifest (row 17),
F5 per-seat manifest (row 18), F6 pointer gaps (rows 11, 19, 26) — matching the r103/r104
hardening history.

## 3. F-A — the control-sentinel exclusion is pass-A-only (false positive)

CHECK 4's control-sentinel filter (`SENTINEL='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'`)
is applied **only in pass A**. Pass B (the repo-relative sweep added as r102 HARDENING G) has no
such filter, and its regex `[\`]upstream/[A-Za-z0-9_./-]+:[0-9]+[\`]` extracts any **backticked**
upstream pointer — sentinel or not — then resolves it against `$SUB`, where `upstream/nope.md` does
not exist → `MISSING-PATH-REL`.

**[O] Sentinel-form probe** (`/var/tmp/r107-rev-gate/logs/sent-*.txt`), one line appended to
`README.md` per case:

| form appended to README.md | exit | POINTERS | SKIPPED | UNRESOLVED | signal |
|---|---|---|---|---|---|
| ``see `upstream/nope.md:3` `` | **1** | 104 | 1 | 1 | `MISSING-PATH-REL upstream/nope.md` |
| ``see `upstream/nope.md:<N>` `` | 0 | 103 | 0 | 0 | pass B regex needs digits; not matched |
| `see upstream/nope.md:3` (plain) | 0 | 103 | 1 | 0 | skipped by pass A, invisible to pass B |
| ``see `upstream/README.md:9999` `` | 0 | 103 | 1 | 0 | sentinel form is fine when path exists |
| ``see `upstream/README.md:500` `` | 0 | 103 | 1 | 0 | same |

**[O] The strongest form — plant the sentinel in the gate's own spec file.** Appending
`` Example (backticked, as this file writes them): `upstream/nope.md:3` `` to `gate/README.md`:

```
MISSING-PATH-REL upstream/nope.md
POINTERS=104 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)   exit=1
```

The spec file is *self-excluded from pass A* by design (`case "$f" in "$SUB"/upstream/*|"$SELF") continue;;`)
but **not** from pass B (`--include='*.md' "$SUB"`, no self-exclusion). So the gate fails on a
citation of its own control pointer. This is exactly the asymmetry the README already *documents*
("the self-exclusion applies to only the first [pass]") — but the README documents it as a
*measurement* artefact (`POINTERS` moves), whereas the observable consequence is a **spurious
exit 1**, which the README's C7 row contradicts. [O]

## 4. F-B — the subtree root is not enumerated (false negative)

**[O]** `corpus/knowledge/unreal-mcp/EXTRA.md` containing a valid card label, and
`corpus/knowledge/unreal-mcp/NOTES.txt`, both planted in the copy → gate prints
`GATE RESULT: PASS (checks failed: 0)` and exits **0**. Landing confirmed (`ls` shows both files).
The gate's enumerations are `find "$SUB/upstream" "$SUB/executability" "$SUB/.manifest.d"`
(line 105), `find "$SUB/executability" -maxdepth 1` (313), `find "$SUB" -type f` **restricted to
`*.md|*.txt|*.markdown` for pointer extraction only** (408) — nothing asserts *what files exist at
the subtree root*. `PATH_EXTRA` only compares `upstream/` against the clone. So arbitrary content
can sit beside `PROVENANCE.md`/`README.md`/`adaptation-kimi.md` with the gate green.

This is the same *class* as r102 F1/F2 (enumerations with holes) but at a level the r103/r104
hardenings did not cover. **Severity: medium** — it is a container for unsanctioned claims, not a
corruption of the vendored bytes (those stay byte-verified). [O]

Contrast — an extra file in an **enumerated** location **is** caught: an added
`.manifest.d/seat99.sha256` (referencing a nonexistent path) → `MANIFEST_FILES=13`,
`FAIL per-seat manifest sweep (--strict)`, `upstream/X.md: FAILED open or read`, exit 1. [O]

## 5. F-C — the scanner-sha pin in `gate/README.md` is stale

**[O]**

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf
$ git -C <lane> show 77811e1:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum
390a25ae…            # r104 commit == working tree == HEAD
$ git -C <lane> show de4e0f2:…/run_gate.sh | sha256sum
577c8b54…            # r103 scanner — the README's *older* pin, correct
```

`gate/README.md` names `run_gate.sh` sha256 `e5521304…` in five places (lines 42, 248, 283, 373,
440) as "the current scanner"; the installed file has always been `390a25ae…` at the r104 commit
that landed it. `reports/round-104/gate/workdir.md:7` also states the target as `e5521304…`. The
`577c8b54…` (r103) pin in the same file **is** correct. So one pin is right and one is wrong —
the wrong one is the "current" one, i.e. the one a reader would trust. [O]

Note this does **not** make the gate's *output* wrong: `POINTERS=103/41` measures correctly on the
installed scanner. The defect is a provenance/provenance-pin error in the spec, exactly the class
this side-round exists to catch (a claim of byte-identity/measurement against the wrong artefact).

## 6. F-D — C7's documented command is not reproducible as written

`gate/README.md` and `reports/round-102/gate/controls.txt:97` both record C7 as
`printf "\nsee upstream/nope.md:3 and upstream/README.md:9999\n" >> README.md` → **exit 0**.

**[O]** Reproduced here:

| appended form | exit | SKIPPED | UNRESOLVED |
|---|---|---|---|
| `see upstream/nope.md:3 and upstream/README.md:9999` (one line, as documented) | **1** | 0 | 1 |
| `see upstream/nope.md:1` + `see upstream/README.md:9999` (two separate lines) | **0** | 2 | 0 |
| ``see `upstream/nope.md:3` and `upstream/README.md:9999` `` (backticked) | **1** | 2 | 1 |

On one line the pass-A regex greedily extracts the merged string
`upstream/nope.md:3 and upstream/README.md:9999`, which is not an exact sentinel match, so the
filter does not fire and the pointer is counted → `UNRESOLVED=1`. The documented C7 therefore only
passes if the two sentinels sit on **separate lines** (or are un-backticked and separately
resolved). The README's claim "**C7** … plant **only** the exact sentinels → exit 0" is
under-specified: the reproduced counterexample is one line away. [O]

## 7. What is NOT proven (honest limits)

- **[?] Gate behaviour against a fresh-pin tree.** The pin is unchanged this round (`a6aa73ad` ==
  r101 pin; VERIFY-LEAD §0 [O]), so I could not exercise a *moved* pin except by mutating the
  `PIN=` constant (case 20), which is the constant, not a re-vendored tree. MUT-GATE owns that.
- **[?] Cross-host reproducibility.** All cases ran on this host, cwd `$R`, `GATE_WORKDIR` on
  `/var/tmp` (748G free). The r104 quota-pressure classes (W4/W5) were **not** re-run; I did not
  create a full tmpfs. The `CHECK 2 BLOCKED (network)` branch **was** exercised (case 27) and the
  bad-`GATE_REF` branch (case 28), but `BLOCKED (local-resource)` is unverified here.
- **[?] Semantic card↔evidence consistency.** The gate enforces one-label-per-card mechanically;
  whether a `static-only` card actually rests on a static check is a hand judgement, out of scope
  for both this seat and the script (the README says so too).
- **[?] My skeleton-root harness** uses symlinks for siblings. All 4 checks passed on the clean
  skeleton (case 1), so pass B resolves through them here; but I did not prove the skeleton is
  *equivalent* to the real root for every pointer form.
- **Not run / not claimed:** Unreal Editor, the MCP server, any live tool call. `unproven-runtime`
  stays `unproven-runtime`. The UE-runtime question is UNLOCK's seat; the docker pull
  (`wukakuki/unreal-engine:dev-slim-5.8.3`) was still **ALIVE** at my last check with **no image
  present** — `pgrep -f 'docker pull wukakuki'` matched, `docker images | grep -i unreal` empty,
  pull log size static (2470 B) across 20 s. So from this seat the UE runtime is
  **unproven-with-attempt-log**, not disproven. [O]

## 8. Recommendation to the orchestrator

F-A and F-B are **draft-stage defects in the gate**, and HARD RULE 3 says the orchestrator lands;
this seat produces evidence only. Suggested dispositions (not applied here):

1. **F-A (highest priority).** Apply the sentinel/self exclusion to pass B as well, or skip
   `upstream/…:N` strings in pass B that pass A already skipped. Until then, do **not** cite C7 as
   a green control, and do **not** let any landed prose quote a backticked control sentinel outside
   `gate/README.md` (and note the README itself is unsafe for it).
2. **F-B.** Add a subtree-root inventory assertion (the pinned set `PROVENANCE.md README.md
   adaptation-kimi.md gate/ executability/ upstream/ .manifest.d/`) so a stray root file is a FAIL.
3. **F-C.** Correct the `e5521304…` occurrences in `gate/README.md` to `390a25ae…` as a **dated
   correction**, or drop the sha and cite the commit — either way do not leave a "current scanner"
   pin that names a file that never existed at that sha.
4. **F-D.** Rewrite C7's command to the two-line form (verified exit 0 here) and state the
   one-line caveat.

## 9. Axes served (Godspeed)

- **Falsifiability** — every claim is a run with an exit code; the accept-clean control proves the
  harness is not the cause of any red.
- **Independence** — cases are built and confirmed by this seat; no value was read from another
  seat's manifest or `.manifest.d/` for the *expectations*.
- **Non-harm** — all writes under `/var/tmp/r107-rev-gate/` and `reports/round-107/`; the pinned
  tree and `corpus/` were never modified (verified: gate sha `390a25ae…` unchanged, and the clean
  control still exits 0 after the whole suite).
