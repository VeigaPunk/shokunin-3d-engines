#!/usr/bin/env bash
# SEAT-45 r104: independent re-implementation of gate CHECK 4's counting
# semantics, written from the spec text in gate/README.md + run_gate.sh,
# NOT by calling run_gate.sh. Purpose: reproduce POINTERS=101 from outside.
set -u
SUB=reports/round-104/gate/scratch/full-c85a816/corpus/knowledge/unreal-mcp
REPO_ROOT=$(cd "$SUB/../../.." && pwd)
SELF=$SUB/gate/README.md
SENTINEL='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'

# ---- pass A: upstream/<path>:<line...> endpoints, self + upstream excluded
A_STR=0; A_END=0; A_SKIP=0; A_BAD=0
while IFS= read -r f; do
  case "$f" in "$SUB"/upstream/*|"$SELF") continue;; esac
  while IFS= read -r ptr; do
    [ -z "$ptr" ] && continue
    if printf '%s' "$ptr" | grep -qE "^($SENTINEL)$"; then A_SKIP=$((A_SKIP+1)); continue; fi
    A_STR=$((A_STR+1))
    p=${ptr%:*}; rest=${ptr#*:}
    if [ ! -f "$SUB/$p" ]; then echo "  IND MISSING-PATH $f :: $ptr"; A_BAD=$((A_BAD+1)); continue; fi
    n=$(wc -l < "$SUB/$p")
    for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
      A_END=$((A_END+1))
      if [ "$ln" -lt 1 ] || [ "$ln" -gt "$n" ]; then
        echo "  IND OOR $f :: $ptr (max $n)"; A_BAD=$((A_BAD+1)); fi
    done
  done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" "$f" | sort -u)
done < <(find "$SUB" -type f \( -iname '*.md' -o -iname '*.txt' -o -iname '*.markdown' \) | sort)

# ---- pass B: backtick repo-relative paths, one increment per unique path
B_TOT=0; B_BAD=0
while IFS= read -r ptr; do
  [ -z "$ptr" ] && continue
  case "$ptr" in http*|*'<'*|*'*'*|*'$'*) continue;; esac
  case "$ptr" in
    corpus/*|reports/*|docs/*) base=$REPO_ROOT ;;
    executability/*|gate/*|upstream/*|.manifest.d/*) base=$SUB ;;
    *) continue ;;
  esac
  B_TOT=$((B_TOT+1))
  [ -e "$base/$ptr" ] || { echo "  IND MISSING-PATH-REL $ptr"; B_BAD=$((B_BAD+1)); }
done < <({ grep -rhoE '[`][A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt)(:[0-9]+)?[`]' --include='*.md' "$SUB" 2>/dev/null; grep -rhoE '[`]upstream/[A-Za-z0-9_./-]+:[0-9]+[`]' --include='*.md' "$SUB" 2>/dev/null; } | tr -d '`' | sed 's/:[0-9]\+$//' | sort -u)

echo "INDEPENDENT passA_strings=$A_STR passA_endpoints=$A_END passA_skipped=$A_SKIP passB_paths=$B_TOT"
echo "INDEPENDENT POINTERS=$((A_END+B_TOT)) POINTER_STRINGS=$A_STR SKIPPED=$A_SKIP UNRESOLVED=$((A_BAD+B_BAD))"
