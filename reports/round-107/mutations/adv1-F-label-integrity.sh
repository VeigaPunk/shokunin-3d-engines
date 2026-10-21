#!/usr/bin/env bash
# adv1-F-label-integrity.sh — CLASS F: label / evidence incoherence.
#
# ATTACK. Leave the label scan green while the card's content contradicts it:
#   F1 append a live-editor claim ("UnrealEditor was launched on this host and
#      `blueprint_create` returned OK") to a card that declares `static-only`.
#   F2 plant a SECOND, contradictory label declaration deep in the same card
#      (`**Label:** `verified-here`` past line 40). The gate takes the first
#      anchored declaration, so the later one is never read.
#
# WHY IT MATTERS (fresh-pin-specific). This round's deliverable is a refreshed
# executability layer whose cards must stay honest about the host (no editor is
# installed). `verified-here` is the one label the pinned census forbids, and
# F2 shows a card can carry it and still be counted `static-only`. F1 is the
# round's cardinal sin: an unobserved runtime claim riding on a static-only
# card, with the gate's own census line still reading 12/1/0.
#
# FALSIFIABLE ACCEPTANCE. The gate must FAIL when a card's body asserts a
# live-editor observation, and must FAIL when a card carries a second label
# declaration anywhere (not only in its first 40 lines). Expected here: MISSED.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

ensure_refs
MIRROR=$(build_mirror f)
SUB=$MIRROR/corpus/knowledge/unreal-mcp
CARD=$SUB/executability/blueprints.md

baseline_ok f || exit 9
printf 'card declares : %s\n' "$(grep -m1 -E '\*\*(Label|Verdict)' "$CARD")"

printf '\n--- F1: live-editor claim appended to a static-only card ---\n'
printf '\n## Live observation (appended by attacker)\n\nUnrealEditor was launched on this host and `blueprint_create` returned OK.\n' \
  >> "$CARD"
printf 'planted claim present : %s\n' "$(grep -c 'blueprint_create' "$CARD")"
printf 'card lines now        : %s\n' "$(wc -l < "$CARD")"
run_gate "$MIRROR" | grep -E '^(CARDS|CENSUS|GATE RESULT)'
printf 'F1 exit=%s\n' "$GATE_EXIT"

printf '\n--- F2: second, contradictory label declaration past line 40 ---\n'
printf '\n**Label:** `verified-here`\n' >> "$CARD"
printf 'second declaration at line : %s\n' "$(grep -nE '\*\*Label:\*\*' "$CARD" | tail -1)"
run_gate "$MIRROR" | grep -E '^(CARDS|CENSUS|GATE RESULT)'

verdict F "$GATE_EXIT"
exit 0
