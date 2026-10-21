#!/usr/bin/env bash
# adv1-verify-fixes.sh — verify the proposed hardening for classes A, E, H.
#
# For each fix: patch a SCRATCH copy of the gate, re-run the corresponding attack
# against the patched copy, and confirm (a) the attack flips to DETECTED and
# (b) the unmodified tree still prints the pinned green values. A recommendation
# that has not been executed is an assertion; this script makes each a measurement.
#
# The live gate is never touched: every patch is applied to a copy under $SCR.
# Patch programs live in separate files (adv1-patch-*.py) so bash never re-parses
# the shell text being inserted — an inline version of this script wrote a
# backtick into the generated shell and turned it into command substitution.
# Each program asserts its target line was found, so a stale pattern fails loudly.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

ensure_refs
GATE=$LIVE/corpus/knowledge/unreal-mcp/gate/run_gate.sh

apply_patch() {   # apply_patch <program.py> <outfile>
  python3 "$HERE/$1" "$GATE" "$2" || exit 9
  bash -n "$2" || { printf 'PATCHED GATE HAS A SYNTAX ERROR\n'; exit 9; }
}

run_with() {      # run_with <mirror> <tag> <gate-copy>
  cp "$3" "$1/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
  run_gate "$1" "$2"
}

printf '=== FIX H (class H): widen pass A so extensionless targets are range-checked ===\n'
printf 'live pass A: %s\n' "$(grep -m1 -oE 'upstream/\[\^.*sort -u' "$GATE")"
apply_patch adv1-patch-H.py "$SCR/gate-H.sh"
printf 'patched    : %s\n' "$(grep -m1 -oE 'upstream/\[\^.*sort -u' "$SCR/gate-H.sh")"
CLEAN=$(build_mirror vh-clean); run_with "$CLEAN" vh-clean "$SCR/gate-H.sh"
printf '  clean tree : '; show '^POINTERS=|^GATE RESULT' | tr '\n' ' '; printf '(exit %s)\n' "$GATE_EXIT"
HM=$(build_mirror vh-attack)
printf '\nSee `upstream/LICENSE:99999` for the license.\n' >> "$HM/corpus/knowledge/unreal-mcp/README.md"
run_with "$HM" vh-attack "$SCR/gate-H.sh"
printf '  attack tree: '; show '^LINE-OOR|^POINTERS=|^UNRESOLVED=|^GATE RESULT' | tr '\n' ' '; printf '(exit %s)\n' "$GATE_EXIT"

printf '\n=== FIX E (class E): assert the manifest-file count against the pinned 12 ===\n'
apply_patch adv1-patch-E.py "$SCR/gate-E.sh"
printf 'patched assertion: %s\n' "$(grep -m1 'pinned 12' "$SCR/gate-E.sh")"
EC=$(build_mirror ve-clean); run_with "$EC" ve-clean "$SCR/gate-E.sh"
printf '  clean tree : '; show '^MANIFEST_FILES=|^GATE RESULT' | tr '\n' ' '; printf '(exit %s)\n' "$GATE_EXIT"
EM=$(build_mirror ve-attack); rm -f "$EM/corpus/knowledge/unreal-mcp/.manifest.d/seat07.sha256"
run_with "$EM" ve-attack "$SCR/gate-E.sh"
printf '  attack tree: '; show '^MANIFEST_FILES=|^FAIL manifest|^GATE RESULT' | tr '\n' ' '; printf '(exit %s)\n' "$GATE_EXIT"

printf '\n=== FIX A (classes A, C1): cross-check the PIN constant against PROVENANCE.md ===\n'
apply_patch adv1-patch-A.py "$SCR/gate-A.sh"
printf 'patched assertion: %s\n' "$(grep -m1 'declared pin' "$SCR/gate-A.sh")"
AC=$(build_mirror va-clean); run_with "$AC" va-clean "$SCR/gate-A.sh"
printf '  clean tree : '; show '^PIN_DECLARED|^FAIL declared|^GATE RESULT' | tr '\n' ' '; printf '(exit %s)\n' "$GATE_EXIT"
AM=$(build_mirror va-attack); ASUB=$AM/corpus/knowledge/unreal-mcp
rm -rf "$ASUB/upstream"; mkdir -p "$ASUB/upstream"
(cd "$REF_OLD" && git archive HEAD) | tar -x -C "$ASUB/upstream"
rm -f "$ASUB"/.manifest.d/seat*.sha256
(cd "$ASUB" && find upstream -type f | sort | while read -r f; do sha256sum "$f"; done) \
  > "$ASUB/.manifest.d/audit-reference.sha256"
run_with "$AM" va-attack "$SCR/gate-A.sh"
printf '  attack tree: '; show '^PIN_DECLARED|^FAIL declared|^GATE RESULT' | tr '\n' ' '; printf '(exit %s)\n' "$GATE_EXIT"

printf '\n=== SUMMARY: clean rows must stay green; attack rows must flip to FAIL ===\n'
