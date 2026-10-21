#!/usr/bin/env bash
# adv1-E-manifest-set.sh — CLASS E: the manifest SET is not pinned.
#
# ATTACK.
#   E1 delete `.manifest.d/seat07.sha256` — the gate prints `MANIFEST_FILES=11`
#      and passes, because the count is printed and never compared.
#   E2 plant a comment-only `.manifest.d/seat99.sha256` — a manifest file that
#      carries no checksum at all.
#
# Each sub-attack gets its OWN mirror: the E2 mirror is rebuilt from the live
# tree, so it starts at 12 files rather than inheriting E1's deletion.
#
# WHY IT MATTERS (fresh-pin-specific). The round-107 re-vendor rebuilds all 12
# manifest files for the new pin. A seat shard dropped or left stale in that
# rebuild is invisible: `--strict` over a *smaller* glob is still green. This is
# the r102 F5 class one layer up — F5 ("seat shards are never verified") was
# closed by adding the strict glob; the SET IDENTITY of that glob was not closed
# with it.
#
# FALSIFIABLE ACCEPTANCE. The gate must FAIL when the manifest-file count differs
# from the pinned count (12), and must FAIL when a manifest file contains no
# checksum line. Expected here on the live gate: MISSED (exit 0).
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

ensure_refs
MIRROR=$(build_mirror e1)
SUB=$MIRROR/corpus/knowledge/unreal-mcp
baseline_ok e1 || exit 9
printf 'baseline manifest files : %s\n' "$(ls "$SUB"/.manifest.d/*.sha256 | wc -l)"

printf '\n--- E1: delete a per-seat manifest (12 -> 11) ---\n'
rm -f "$SUB/.manifest.d/seat07.sha256"
printf 'manifest files now : %s\n' "$(ls "$SUB"/.manifest.d/*.sha256 | wc -l)"
run_gate "$MIRROR" adv1-E1
E1_EXIT=$GATE_EXIT
show '^(MANIFEST_FILES|MANIFEST_OK|STEP=|GATE RESULT)'
printf 'E1 exit=%s\n' "$E1_EXIT"

printf '\n--- E2: comment-only manifest (fresh mirror, 12 -> 13 files) ---\n'
MIRROR2=$(build_mirror e2)
SUB2=$MIRROR2/corpus/knowledge/unreal-mcp
printf '# cleared by attacker\n' > "$SUB2/.manifest.d/seat99.sha256"
printf 'manifest files now : %s\n' "$(ls "$SUB2"/.manifest.d/*.sha256 | wc -l)"
printf 'checksum lines in planted file : %s\n' "$(grep -c '[0-9a-f]\{64\}' "$SUB2/.manifest.d/seat99.sha256")"
run_gate "$MIRROR2" adv1-E2
show '^(MANIFEST_FILES|MANIFEST_OK|STEP=|GATE RESULT|FAIL |  sha256sum)'
printf 'E2 exit=%s\n' "$GATE_EXIT"
printf 'NOTE: E2 is DETECTED, but by --strict'"'"'s FORMAT rule ("no properly formatted\n'
printf '      checksum lines found"), not by any set-identity check. E1 is the MISSED row.\n'

if [ "$E1_EXIT" -eq 0 ]; then
  printf '\n==> CLASS E (E1 seat-manifest deletion): MISSED (gate exit 0 — false-pass)\n'
else
  printf '\n==> CLASS E (E1 seat-manifest deletion): DETECTED (gate exit %s)\n' "$E1_EXIT"
fi
printf '    E2 comment-only manifest: DETECTED (exit %s) via --strict format rule\n' "$GATE_EXIT"
exit 0
