#!/usr/bin/env bash
# adv1-G-spec-blind.sh — CLASS G: the gate's OWN pinned expectations are unenforced.
#
# ATTACK. `gate/README.md` is the gate's specification and pins the exact summary
# lines a green run must print (`POINTERS=103 POINTER_STRINGS=41 …`,
# `CARDS=13 EXPECTED=13`, `MANIFEST_OK=12 …`). Rewrite those pinned expected
# values in the spec to values the gate will never print, leaving the tree and
# the gate script untouched.
#
# WHY IT MATTERS (fresh-pin-specific). A fresh pin re-measures every one of these
# numbers — r103 already had to issue a `POINTERS=87 -> 103` pin correction, and
# the README's own note calls the old value stale. The numbers are the round's
# acceptance contract: a reviewer reads `gate/README.md` to learn what green
# means. Nothing checks that the contract and the checker still agree, so a
# re-vendor that updates one and forgets the other lands a spec that documents a
# run which cannot happen.
#
# FALSIFIABLE ACCEPTANCE. The gate must FAIL when its own README's pinned
# expected values disagree with what it measures. Expected here: MISSED.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

ensure_refs
MIRROR=$(build_mirror g)
SUB=$MIRROR/corpus/knowledge/unreal-mcp
SPEC=$SUB/gate/README.md

baseline_ok g || exit 9
printf 'spec sha before : %s\n' "$(sha256sum "$SPEC" | cut -d' ' -f1)"

printf '\n--- APPLYING CLASS G ---\n'
sed -i 's/POINTERS=103/POINTERS=9999/g; s/CARDS=13 EXPECTED=13/CARDS=99 EXPECTED=99/g; s/MANIFEST_OK=12 EXPECTED=12/MANIFEST_OK=99 EXPECTED=99/g' "$SPEC"
printf 'POINTERS=9999 occurrences : %s\n' "$(grep -c 'POINTERS=9999' "$SPEC")"
printf 'CARDS=99 occurrences      : %s\n' "$(grep -c 'CARDS=99' "$SPEC")"
printf 'MANIFEST_OK=99 occurrences: %s\n' "$(grep -c 'MANIFEST_OK=99' "$SPEC")"
printf 'spec sha after  : %s\n' "$(sha256sum "$SPEC" | cut -d' ' -f1)"
printf '=> the spec now pins values the gate cannot print\n'

run_gate "$MIRROR" adv1-G
show '^(MANIFEST_OK|CARDS=|CENSUS|POINTERS=|STEP=|GATE RESULT)'
verdict G "$GATE_EXIT"
exit 0
