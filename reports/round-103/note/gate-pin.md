# r103 · SEAT-05 GATE-PIN-UPDATER — the `POINTERS` pin re-measured

Round r103 · lane `game-dev-3d-shokunin` · written 2026-10-18.
Seat scope: **`corpus/knowledge/unreal-mcp/gate/README.md` only** (its expected-value text). This
seat did **not** write `run_gate.sh`; the scanner is read-only here.

Every claim carries the command that produced it and the observed output on this host. Labels:
**[O]** observed here, **[I]** inference.

**Final measured state** (all four checks pass, exit 0):

- Lane HEAD: `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
- Scanner: `corpus/knowledge/unreal-mcp/gate/run_gate.sh`
  sha256 `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0` **[O]**
- README (this seat's file, post-edit): sha256
  `834f468ded21fcdf069ab378c2774298158f71a93954aef9ee0df86bd90927d2` **[O]**
- Pinned count: **`POINTERS=101 POINTER_STRINGS=41`**, `UNRESOLVED=0` **[O]**

---

## 1. Verdict

**The r102 pin was stale; it is now corrected to the measured value.** The README's expected-value
blocks pinned `POINTERS=87`. The installed gate prints **`101`**, and printed `88` already on the
r102-close tree — so `87` was one low at commit time, not drift since. **[O]**

**The binding invariant never changed:** `UNRESOLVED=0` and `SKIPPED_CONTROL_SENTINELS=0` in every
clean run below. The advertised count is a measurement, not a contract; `87` was an incorrect
measurement, not a broken gate.

**The pin moved three times during this seat's run**, for three distinct reasons (§3). Because the
file states its own pointer count, **each edit to it moves the number it states** — so the pin is
recorded with a timestamp and a scanner sha256, not as a bare constant. That is the durable part of
this seat's work: the number is now auditable, not just updated.

---

## 2. Measured run — the final pin command

```
$ date -u +'%Y-%m-%dT%H:%M:%SZ'
2026-10-18T18:44:25Z
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "exit=$?"
GATE unreal-mcp subtree
SUBTREE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_HEAD=c85a816e227984272a3c29b58aa7f7c1a76f1e9c

MANIFEST_FILES=12
CHECK 1 manifest-byte-identity
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
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
exit=0
```

**[O]** All four checks `STEP=PASS`, exit `0`, `POINTERS=101 POINTER_STRINGS=41`. The three
non-pointer checks are unchanged from the r102 pin (`MANIFEST_OK=12`, `CLONE_*` at the pin,
`CARDS=13`, census `12/1/0`); `NAME_SET=OK` is new (A3, §3).

---

## 3. Why the pin moved: three independent causes

The count walked `87 → 88 → 90 → 91 → 98 → 101` across the round. The steps group into three
causes, and only the last is a *scanner* change.

### 3.1 `87 → 88` — the pin was already stale at r102 close **[I, exact arithmetic]**

The subtree is byte-identical between the r102-close commit `c6f655d` and HEAD:

```
$ diff -r /tmp/r103_c6/corpus/knowledge/unreal-mcp corpus/knowledge/unreal-mcp && echo TREES_IDENTICAL
TREES_IDENTICAL
$ cd /tmp/r103_c6 && bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep POINTERS
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=10
```

**[O]** `c6f655d` (extracted with `git archive`, read-only) prints `POINTERS=88` on the r102
scanner. (Its `UNRESOLVED=10` is an archive artifact — the extracted tree lacks the repo siblings
that pass B resolves against — not a defect in the committed tree.) So `87` was one low when r102
closed. The delta of one is the README itself: pass B counts this file, so the final wording edit
at close moved the count *after* the number had been written down.

### 3.2 `88 → 91` — prose gains, because the sweep is two passes

CHECK 4 does not have one scanner. `run_gate.sh` runs **two** extraction passes and prints their
sum:

- **Pass A** — `upstream/<path>:<line>` pointers, with `upstream/*` and `gate/README.md`
  **excluded**.
- **Pass B** — a backtick-wrapped repo-relative path sweep over `--include='*.md'`, with **no
  self-exclusion**. It re-reads `gate/README.md` and counts its own worked examples and prose.

Decomposition on the final tree, re-deriving each pass with the gate's own commands **[O]**:

```
PASS_A_ENDPOINTS=47 PASS_A_STRINGS=41 PASS_B=54 TOTAL=101
```

`47 + 54 = 101`, matching the gate's `POINTERS=101` exactly. The two passes are disjoint (pass A
yields `upstream/…:<line>` strings, pass B bare paths), so the sum is a clean union.

Pass B counts every backtick path in the subtree, so each new citation moves the total: the C1
freshness note added two paths in `adaptation-kimi.md`, this seat's own note added one, and the
r103b hardening paragraph plus the control matrix added more. **The last edit is always this
README counting itself** — the self-reference made concrete.

### 3.3 `91 → 98` — a scanner change (A1), not tree drift

**A1** (SEAT-09, r103) made `POINTERS` count **endpoints**, not strings. A `:4-5` range is two; a
`:61,70-79` list is four. Before A1 the extraction regex stopped at the first number, so a planted
`upstream/README.md:1-9999` resolved as the in-range `:1`. Pass A went from 40 strings to 47
endpoints (+7), and `POINTER_STRINGS=41` now carries the old string count. This is why the pin
must be stated with a scanner sha256 — the same tree yields different numbers under different
scanners, and the gate itself now prints both so the two are never confused.

### 3.4 `98 → 101` — this README counting itself again

The r103b hardening-history paragraph and the r103 control matrix name
`reports/round-103/gate/hardening.md`, `adaptation-kimi.md` and the control paths; pass B counts all
of them.

---

## 4. What this seat changed

`corpus/knowledge/unreal-mcp/gate/README.md`, prose only, no scanner logic touched. Final file
sha256 `834f468d…`. The changes:

1. **CHECK 4 expected-value line** — `POINTERS=87` → the measured `POINTERS=101
   POINTER_STRINGS=41`, with timestamp, lane HEAD, scanner sha256, subtree sha256, and the
   pass-A/pass-B decomposition.
2. **CHECK 4 description** — a paragraph stating that the sweep is two passes and that the
   self-exclusion applies to only pass A, so the count is self-referential. Recorded as an
   observation with a routed hardening, **not** silently changed here (this seat does not own
   `run_gate.sh`). Also documents the A1 endpoint semantics.
3. **CHECK 2** — BLOCKED documented as a third state: distinct signal, `STEP=BLOCKED`, exit 2, and
   the `GATE_REF` offline path.
4. **CHECK 3** — the rule rewritten to the anchored five-shape declaration form (A2); the pinned
   card-name set added (A3) with the "edit both copies" warning.
5. **Pinned summary block** — example line and pinned-value table updated to
   `POINTERS=101 POINTER_STRINGS=41` / `101 / 41`, plus the new `NAME_SET=OK` line.
6. **Exit codes** — the two-state contract replaced by the declared **0 PASS / 1 FAIL / 2
   BLOCKED** contract, with the mixed BLOCKED+FAIL residual recorded rather than hidden.
7. **Hardening history** — r103 A1–A4 marked closed with the new scanner sha.
8. **Dated pin-correction note** — the full `87 → 88 → 90 → 91 → 98 → 101` chain, the measured
   command, and a pointer to this file. A **dated correction, not a rewrite**: the old value is
   named as superseded, and the binding invariant never changed.

---

## 5. Concurrent editing — recorded, not hidden

`gate/README.md` was edited concurrently by **SEAT-09 HARDENING-AUTHOR**, whose receipt
(`reports/round-103/gate/hardening.md` §5) declares it as an owned path. Both seats edited the same
file; neither reverted the other's text. SEAT-09 re-measured the pin to `101` at the settled
scanner, which this seat independently reproduced (`PASS_A_ENDPOINTS=47 PASS_B=54 TOTAL=101`), and
this seat corrected the README's measurement timestamp, which read `19:00Z` — a time that had not
yet occurred (the run was at `18:43Z`). The duplication is reported upward as an ownership
collision; per-file ownership was not exclusive in practice.

---

## 6. Discipline notes

- **No Unreal runtime claim.** The editor is not installed on this host and no live MCP call was
  made; every card stays `unproven-runtime` / `static-only`, and the census `12/1/0` is unchanged.
- **No scanner edit.** `run_gate.sh` sha256 is unchanged by this seat:
  `577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0`.
- **Correction-note discipline.** The historical `87` is superseded in place with a dated note; no
  claim about the r102 close was silently rewritten.
- **Owned path only.** Wrote `corpus/knowledge/unreal-mcp/gate/README.md` and this file. No other
  path was written; protected paths (`LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`,
  `PROVINCE.md`, `corpus/fixtures/**`, `reports/round-101/**`, `reports/round-102/**`, the upstream
  vendored tree and `.manifest.d/**`) are untouched.
