#!/usr/bin/env bash
# adv1-C-declared-drift.sh — CLASS C: card / PROVENANCE declared-identity drift.
#
# ATTACK. Corrupt the DECLARED identity of the subtree while leaving the bytes
# the gate hashes untouched:
#   C1 PROVENANCE.md §1 "pinned commit" cell rewritten to a bogus SHA.
#   C2 README.md's card index declares a FOURTEENTH card
#      (`executability/extra-domain.md`) that does not exist — in plain text, so
#      the backtick-pointer sweep never sees it.
#
# WHY IT MATTERS (fresh-pin-specific). The re-vendor's whole claim is "this tree
# is upstream at pin X". PROVENANCE.md is the artifact a reviewer reads to learn
# X, and README.md is the artifact that declares the card inventory. Both are
# unchecked: the gate's only pin source is its own PIN constant, and CHECK 3
# counts the executability/ directory, never the README's claim about it.
#
# FALSIFIABLE ACCEPTANCE. The gate must FAIL when the pin declared in
# PROVENANCE.md/README.md differs from its own PIN, and must FAIL when README.md
# declares a card that does not exist. Expected here on the live gate: MISSED.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

ensure_refs
MIRROR=$(build_mirror c)
SUB=$MIRROR/corpus/knowledge/unreal-mcp

baseline_ok c || exit 9

printf '\n--- C1: PROVENANCE.md §1 pinned-commit cell -> bogus SHA ---\n'
sed -i "s|$PIN|0000000000000000000000000000000000000000|g" "$SUB/PROVENANCE.md"
printf 'PROVENANCE.md:22 now : %s\n' "$(sed -n '22p' "$SUB/PROVENANCE.md")"
printf 'occurrences rewritten: %s\n' "$(grep -c '0000000000000000000000000000000000000000' "$SUB/PROVENANCE.md")"
run_gate "$MIRROR" | grep -E '^(MANIFEST_OK|CARDS|POINTERS|GATE RESULT)'
printf 'C1 exit=%s\n' "$GATE_EXIT"

printf '\n--- C2: README.md card index declares a 14th (nonexistent) card ---\n'
printf '\nThe inventory also carries executability/extra-domain.md, labelled static-only.\n' \
  >> "$SUB/README.md"
printf 'planted line present : %s\n' "$(grep -c 'executability/extra-domain.md' "$SUB/README.md")"
printf 'cards on disk        : %s\n' "$(find "$SUB/executability" -maxdepth 1 -name '*.md' | wc -l)"
run_gate "$MIRROR" | grep -E '^(CARDS|POINTERS|UNRESOLVED|GATE RESULT)'

verdict C "$GATE_EXIT"
exit 0
