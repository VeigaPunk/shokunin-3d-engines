#!/usr/bin/env bash
# adv1-A-wrong-pin.sh — CLASS A: wrong-pin acceptance.
#
# ATTACK. Re-vendor the subtree from a DIFFERENT upstream commit (the parent
# `d1b0580`, 12 tracked files), regenerate every manifest and every seat shard
# from those fresh bytes, and repoint the gate's PIN constant at that commit.
# PROVENANCE.md and README.md are left declaring the ORIGINAL pin a6aa73ad.
# Everything the gate can see is self-consistent — it is consistent with the
# WRONG commit.
#
# WHY IT MATTERS (fresh-pin-specific). The r107 side-round re-vendors at a NEW
# pin. If the tree is vendored from a different commit than the prose declares —
# or the prose and the gate's PIN constant drift apart — the gate must say so.
# It cannot: its only pin source is its own PIN constant, and nothing in the
# gate compares that constant against the pin PROVENANCE.md/README.md declare.
#
# FALSIFIABLE ACCEPTANCE. A gate that closes this class prints a pin-agreement
# token (e.g. `PIN_DECLARED=OK`) comparing its PIN constant against the pin in
# PROVENANCE.md/README.md, and FAILS when they differ. Expected here: MISSED.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

pin_of() { grep -m1 '| pinned commit |' "$1" | sed -nE 's/.*`([0-9a-f]{40})`.*/\1/p'; }

ensure_refs
MIRROR=$(build_mirror a)
SUB=$MIRROR/corpus/knowledge/unreal-mcp

baseline_ok a || exit 9
printf 'baseline declared pin (PROVENANCE) : %s\n' "$(pin_of "$SUB/PROVENANCE.md")"

printf '\n--- APPLYING CLASS A ---\n'
printf 'alt commit   : %s\n' "$PIN_ALT"
printf 'declared pin : %s\n' "$PIN"

rm -rf "$SUB/upstream"; mkdir -p "$SUB/upstream"
(cd "$REF_OLD" && git archive HEAD) | tar -x -C "$SUB/upstream"

# regenerate the audit reference AND the per-seat shards from the new bytes, so
# the hardened --strict sweep is satisfied and the attack is not caught by an
# unrelated staleness check.
rm -f "$SUB"/.manifest.d/seat*.sha256 "$SUB"/.manifest.d/_seat*
(cd "$SUB" && find upstream -type f | sort | while read -r f; do sha256sum "$f"; done) \
  > "$SUB/.manifest.d/audit-reference.sha256"
(cd "$SUB" && find upstream -type f | sort | while read -r f; do sha256sum "$f"; done) \
  | split -l 1 - "$SUB/.manifest.d/_seat"
i=1; for p in "$SUB"/.manifest.d/_seat*; do mv "$p" "$(printf '%s/.manifest.d/seat%02d.sha256' "$SUB" "$i")"; i=$((i+1)); done

sed -i "s|^PIN=$PIN\$|PIN=$PIN_ALT|" "$SUB/gate/run_gate.sh"

printf '\n--- CONFIRM THE MUTATION LANDED ---\n'
printf 'vendored files from alt commit : %s\n' "$(find "$SUB/upstream" -type f | wc -l)"
printf 'gate PIN constant              : %s\n' "$(grep -m1 '^PIN=' "$SUB/gate/run_gate.sh")"
printf 'manifest files                 : %s\n' "$(ls "$SUB"/.manifest.d/*.sha256 | wc -l)"
printf 'PROVENANCE.md declares         : %s\n' "$(pin_of "$SUB/PROVENANCE.md")"
printf 'README.md declares             : %s\n' "$(pin_of "$SUB/README.md")"
printf '=> the gate now checks a pin the prose contradicts\n'

GATE_REF_OVERRIDE=$REF_OLD run_gate "$MIRROR" adv1-A
show '^(MANIFEST_OK|MANIFEST_FILES|CLONE_HEAD|CLONE_DIRTY|PATH_|BLOB_DIFFS|CARDS=|CENSUS|POINTERS=|STEP=|GATE RESULT)'
verdict A "$GATE_EXIT"
exit 0
