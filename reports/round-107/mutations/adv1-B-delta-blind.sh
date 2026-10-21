#!/usr/bin/env bash
# adv1-B-delta-blind.sh — CLASS B: delta-blindness — CONTROL ROW (gate already closes it).
#
# ATTACK. Run the gate against a reference that is NOT at the pinned commit.
#   B1 offline: `GATE_REF` names a clone whose HEAD is the parent commit.
#   B2 network: `REPO` names a remote whose `main` has moved off the pin.
#
# RESULT: the gate DETECTS both. This class is carried in the suite deliberately
# as a CONTROL — it is the only row expected to be DETECTED, and it is what
# proves the harness can observe a non-zero exit rather than reporting MISSED
# for everything (an always-MISSED harness would make the other six rows
# worthless).
#
# MECHANISM OBSERVED. CHECK 2 asserts `C2_HEAD = PIN` in BOTH paths
# (`gate/run_gate.sh`, the `[ "$C2_HEAD" = "$PIN" ]` test), so a reference at a
# different commit prints `CLONE_HEAD=<other>` and fails the check. The r102-era
# A4 BLOCKED work (r103) is what makes this reachable at all: before it, an
# unreachable/garbled reference was folded into the same FAIL path.
#
# NOTE. In B2 the FIRST line of the captured log is the tail of CHECK 1's
# transcript, so read `CHECK 2 clone-equivalence` as the block header.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

ensure_refs
MIRROR=$(build_mirror b)
SUB=$MIRROR/corpus/knowledge/unreal-mcp

baseline_ok b || exit 9

printf '\n--- B1: GATE_REF at the WRONG commit (offline path) ---\n'
printf 'reference HEAD : %s\n' "$(git -C "$REF_OLD" rev-parse HEAD)"
printf 'gate PIN       : %s\n' "$(grep -m1 '^PIN=' "$SUB/gate/run_gate.sh")"
GATE_REF_OVERRIDE=$REF_OLD run_gate "$MIRROR" adv1-B1
show '^(GATE_REF|CLONE_HEAD|CLONE_TRACKED|PATH_|BLOB_DIFFS|STEP=|GATE RESULT|FAIL )'
printf 'B1 exit=%s\n' "$GATE_EXIT"

printf '\n--- B2: upstream main MOVED off the pin (network path, no GATE_REF) ---\n'
rm -rf "$SCR/bare"; git init --bare -q -b main "$SCR/bare"
git -C "$REF"     push -q "$SCR/bare" "$PIN:refs/heads/main"
git -C "$REF_OLD" push -q "$SCR/bare" "$PIN_ALT:refs/heads/main" --force
printf 'bare main now  : %s\n' "$(git -C "$SCR/bare" rev-parse main)"
printf 'gate PIN       : %s\n' "$PIN"
GATE_REF_OVERRIDE=NONE run_gate "$MIRROR" adv1-B2 REPO="$SCR/bare"
show '^(CHECK 2|GATE_REF|CLONE_HEAD|CLONE_TRACKED|PATH_|BLOB_DIFFS|STEP=|GATE RESULT|FAIL )'
printf 'B2 exit=%s\n' "$GATE_EXIT"

verdict B "$GATE_EXIT"
exit 0
