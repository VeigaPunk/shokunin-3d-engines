#!/usr/bin/env bash
# adv1-D-hashtable-drift.sh — CLASS D: the integrity table itself is unchecked.
#
# ATTACK. Corrupt PROVENANCE.md §2, the per-file hash table a reviewer uses to
# re-check content against the upstream object store:
#   D1 rewrite one per-file sha256 cell to a bogus digest.
#   D2 delete one whole row, so the declared file census drops 12 -> 11.
#
# WHY IT MATTERS (fresh-pin-specific). §2 is the artifact that carries the
# re-vendor's per-file content addresses (and the `git blob` column). The gate
# pins bytes via `.manifest.d/`, but PROVENANCE.md §2 is a SECOND, independent
# statement of the same facts and is never cross-checked against the first.
# After a fresh pin every one of those 12 hashes changes; a transcription error
# in that table is exactly the defect a re-vendor round is meant to catch, and
# it is invisible here.
#
# FALSIFIABLE ACCEPTANCE. The gate must FAIL when a per-file hash cell in
# PROVENANCE.md §2 disagrees with the manifest, and must FAIL when the declared
# row count disagrees with the tracked-file count. Expected here: MISSED.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

ensure_refs
MIRROR=$(build_mirror d)
SUB=$MIRROR/corpus/knowledge/unreal-mcp

baseline_ok d || exit 9

printf '\n--- D1: corrupt one PROVENANCE.md §2 hash cell ---\n'
printf 'real upstream/README.md sha256 : %s\n' "$(sha256sum "$SUB/upstream/README.md" | cut -d' ' -f1)"
sed -i 's|483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e|deadbeef00000000000000000000000000000000000000000000000000000000|' \
  "$SUB/PROVENANCE.md"
printf 'cell now                       : %s\n' "$(grep -o 'deadbeef00[0-9a-f]*' "$SUB/PROVENANCE.md" | head -1)"
printf 'manifest still agrees          : %s\n' "$(cd "$SUB" && sha256sum -c .manifest.d/audit-reference.sha256 >/dev/null 2>&1 && echo YES || echo NO)"
run_gate "$MIRROR" | grep -E '^(MANIFEST_OK|POINTERS|GATE RESULT)'
printf 'D1 exit=%s\n' "$GATE_EXIT"

printf '\n--- D2: delete one PROVENANCE.md §2 row (declared census 12 -> 11) ---\n'
sed -i '/^| 1 | `upstream\/README.md`/d' "$SUB/PROVENANCE.md"
printf 'rows left in §2 table : %s\n' "$(grep -cE '^\| [0-9]+ \| `upstream/' "$SUB/PROVENANCE.md")"
printf 'files on disk         : %s\n' "$(find "$SUB/upstream" -type f | wc -l)"
run_gate "$MIRROR" | grep -E '^(MANIFEST_OK|CARDS|POINTERS|GATE RESULT)'

verdict D "$GATE_EXIT"
exit 0
