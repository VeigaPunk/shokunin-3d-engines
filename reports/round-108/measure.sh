#!/usr/bin/env bash
# r108 counting commands. Usage from the lane root: bash reports/round-108/measure.sh <commit>
# Reads committed blobs only (git show <commit>:<path>), so a dirty tree cannot move the numbers.
set -u
REF=${1:?commit required}
f() { git show "$REF:$1" 2>/dev/null; }
c() { local n; n=$(f "$1" | grep -cE "$2"); echo "${n:-0}"; }
echo "ref=$(git rev-parse --short "$REF")"
echo "C1 calibration"
echo "  QUALITY.md criteria rows        $(c corpus/QUALITY.md '^\| Q[0-9]+ \|')"
echo "  round-108 lesson mistake rows   $(c corpus/lessons/round-108.md '^\| M[0-9]+ \|')"
echo "  mistakes captured by a Q        $(f corpus/lessons/round-108.md | grep -E '^\| M[0-9]+ \|' | awk -F'|' '$5 ~ /Q[0-9]/' | wc -l)"
echo "  scored axis rows (n/10)         $(c SCORECARD.md '^\| (depth|coverage|calibration) \| [0-9]+/10 \|')"
echo "  Saturation line declared        $(c SCORECARD.md '^Saturation line:')"
echo "  verdict blocks                  $(c SCORECARD.md '^## Round [0-9]+ verdict')"
echo "  capabilities rows (excl. none)  $(f SCORECARD.md | sed -n '/^## Capabilities/,/^## Saturation/p' | grep -E '^\| [a-z]' | grep -vc '^| Capability')"
echo "C2 coverage"
echo "  SOURCES rows                    $(c corpus/SOURCES.md '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|')"
echo "  README Coverage map/Frontier    $(c corpus/README.md '^## (Coverage map|Frontier)')"
echo "  coverage-map surface rows       $(f corpus/README.md | sed -n '/^## Coverage map/,/^## Frontier/p' | grep -E '^\| ' | grep -vcE '^\| (surface|---)')"
echo "  PROVINCE Core/Frontier/Adjacent $(c PROVINCE.md '^## (Core|Frontier|Adjacent)')"
echo "C3 depth"
echo "  CASES rows                      $(c corpus/fixtures/run_battery.py '^\s+\("')"
echo "  slope3d rows                    $(c corpus/fixtures/run_battery.py '^\s+\("slope3d_')"
echo "  rows within 1 deg of 45 limit   $(c corpus/fixtures/run_battery.py '^\s+\("slope3d_bound_')"
echo "  SKILL nominal-threshold row     $(c SKILL.md 'nominal-threshold read')"
echo "expansion"
echo "  knowledge entries with source:  $(for p in $(git ls-tree --name-only "$REF" corpus/knowledge/ | grep '\.md$'); do f "$p" | head -1 | grep -q '^source:' && echo "$p"; done | wc -l)"
