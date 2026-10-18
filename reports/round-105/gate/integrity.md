# SEAT-58 — GATE-INTEGRITY-POST

All commands below ran against the post-round-104 tree observed at lane HEAD `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b`. Scratch roots and the mutation copy were under `/var/tmp`; no gate, fixture, or environment file was edited.

## Live gate under `GATE_WORKDIR`

Command: create `d=$(mktemp -d /var/tmp/r105-gate.XXXXXX)`, run `GATE_WORKDIR="$d" corpus/knowledge/unreal-mcp/gate/run_gate.sh >"$d/out" 2>&1`, capture `$?`, print the gate summary with `grep`, then `rm -rf "$d"`.

Observed:

```text
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
WORK_ROOT=/var/tmp/r105-gate.M1TUW5 (from GATE_WORKDIR)
LANE_HEAD=1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
STEP=PASS  (four occurrences)
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
RUN_RC=0
```

## `POINTERS` vs README pin

Command: `sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md; grep -nE 'POINTERS=103|POINTERS=|EXPECTED \(re-measured' corpus/knowledge/unreal-mcp/gate/README.md | tail -8`.

Observed hashes: gate `390a25ae4e389a00c4c5147efd451e21303ae501abe2523ad713b6d88e57b2cf`; README `e3bc66b7f5d981a1128dc60ae910ec7c53dac85107c67802134e32bc7c0e98bf`. README lines 42, 248, 271 carry pin `POINTERS=103`; live gate printed `POINTERS=103`, so the numeric pin matches. **Provenance caveat:** README line 248 still attributes that measurement to scanner `e5521304…`, not the current script hash above. Gate README is SEAT-10-owned; no pin text changed here.

## A4 spot with `REPO` override

Command: create `d=$(mktemp -d /var/tmp/r105-a4.XXXXXX)`, run `REPO=https://127.0.0.1:1/unreachable GATE_WORKDIR="$d" corpus/knowledge/unreal-mcp/gate/run_gate.sh`, capture output/exit, then remove `d`.

Observed: CHECK 2 printed `BLOCKED (network)`, `STEP=BLOCKED`; CHECK 1, 3 and 4 printed `STEP=PASS`; CHECK 4 remained `POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0` (no `MISSING-PATH-REL`); result `GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)`, `A4_RC=2`. This confirms the REPO override did not shadow the repo root used by CHECK 4.

## Classic byte-flip control on a copy

Command: create `/var/tmp/r105-byteflip.*`; copy `corpus/knowledge/unreal-mcp` to a matching `copy/corpus/knowledge/unreal-mcp` tree; link the original `reports/` and non-target `corpus/` entries into the temporary repo root for CHECK 4; append one newline to the **copied** `upstream/README.md`; run the copied `gate/run_gate.sh` with an existing `GATE_WORKDIR`; remove the temporary tree.

Observed: copied manifest check `MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1`, `upstream/README.md: FAILED`; CHECK 2 also printed `BLOB-DIFF README.md`; CHECK 3 and 4 passed, with `POINTERS=103 … UNRESOLVED=0`; final `GATE RESULT: FAIL (checks failed: 3)`, `BYTE_FLIP_GATE_RC=1`. The unmodified source tree was not the mutation target.
