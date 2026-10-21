#!/usr/bin/env bash
# adv1-H-unrangechecked.sh — CLASS H: an out-of-range line number is never checked
# for extensionless `upstream/` pointers (a CLAIMED FIX THAT IS NOT IN THE SCRIPT).
#
# ATTACK. Plant a dangling pointer to an extensionless upstream file:
#
#     See `upstream/LICENSE:99999` for the license.
#
# `upstream/LICENSE` has 21 lines, so `:99999` is out of range. The gate passes.
#
# WHY IT MATTERS (and why it is the sharpest row in this suite). This exact
# attack was found in r102 (`reports/round-102/fold-spec.md` A6) and the round's
# close note says the fix was ADOPTED:
#
#   reports/round-102/r102-report.md:428
#     "... plus an L1 fix: a tool-requirement guard ... and an extensionless
#      `upstream/<name>:<line>` pointer pattern."
#   reports/round-102/r102-report.md:430
#     "planted `upstream/LICENSE:99999` -> exit 1 (UNRESOLVED)."
#
#   corpus/knowledge/unreal-mcp/gate/README.md:31
#     "... plus an L1 tool-requirement guard (`git sha256sum grep find sort comm`
#      absent -> exit 1) and the extensionless-pointer alternative pattern"
#
# None of that is in the installed script. Verified against git history:
#
#   $ git log -L 405,410:corpus/knowledge/unreal-mcp/gate/run_gate.sh
#   de4e0f2 (r103) ... +  done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" "$f" | sort -u)
#   492dcf2 (r102) ... +  done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+" "$f" | sort -u)
#
# The `\.` is mandatory at BOTH revisions: the "alternative pattern" was never
# landed. So the documented behaviour (`exit 1`) and the observed behaviour
# (`exit 0`) disagree — a documented-but-absent check, which is worse than an
# undocumented gap because a reviewer reading gate/README.md believes it is closed.
#
# MECHANISM (two sweeps, neither covers it).
#   pass A (the only range-checking sweep, run_gate.sh:407) requires a dot in the
#     path segment, so `upstream/LICENSE:99999` does not match at all:
#       $ printf 'upstream/LICENSE:99999' | grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+..."
#       (no match)
#   pass B (run_gate.sh:427) does match the backtick-wrapped form, but its
#     post-processing DISCARDS the line number before the existence test:
#       $ grep -ohE '[`]upstream/[A-Za-z0-9_./-]+:[0-9]+[`]'  -> `upstream/LICENSE:99999`
#       $ ... | tr -d '`' | sed 's/:[0-9]\+$//'               -> upstream/LICENSE
#     `upstream/LICENSE` exists, so pass B's `[ -e ]` test passes. The line number
#     was counted (POINTERS 103 -> 104) and never range-checked.
#
# FALSIFIABLE ACCEPTANCE. With the widened pass A regex
#   upstream/[A-Za-z0-9_./-]+(\.[A-Za-z0-9]+)?:[0-9]+
# the planted pointer must produce `UNRESOLVED=1` / `STEP=FAIL` / exit 1, while
# the unmodified tree must still print `POINTERS=103` / `STEP=PASS`.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$HERE/adv1-lib.sh"

ensure_refs
MIRROR=$(build_mirror h)
SUB=$MIRROR/corpus/knowledge/unreal-mcp

baseline_ok h || exit 9
printf 'live pointer regex (run_gate.sh:407) :\n  %s\n' \
  "$(grep -m1 -oE 'upstream/\[\^.*sort -u' "$SUB/gate/run_gate.sh")"

printf '\n--- APPLYING CLASS H ---\n'
printf 'upstream/LICENSE has %s lines\n' "$(wc -l < "$SUB/upstream/LICENSE")"
printf '\nSee `upstream/LICENSE:99999` for the license.\n' >> "$SUB/README.md"

printf '\n--- CONFIRM THE MUTATION LANDED ---\n'
printf 'planted line            : %s\n' "$(tail -1 "$SUB/README.md")"
printf 'is a control sentinel?  : %s\n' \
  "$(printf 'upstream/LICENSE:99999' | grep -qE '^(upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500))$' && echo YES || echo NO)"
printf 'pass A regex matches it : %s\n' \
  "$(printf 'upstream/LICENSE:99999' | grep -qohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" && echo YES || echo NO)"
printf 'pass B strips it to     : %s (which EXISTS)\n' \
  "$(printf '`upstream/LICENSE:99999`' | tr -d '`' | sed 's/:[0-9]\+$//')"

run_gate "$MIRROR" adv1-H
show '^(POINTERS=|UNRESOLVED=|STEP=|GATE RESULT)'
verdict H "$GATE_EXIT"
exit 0
