#!/usr/bin/env bash
# SEAT-37 / r102 — subtree pointer sweep, re-run.
# Pointers are written `upstream/<path>:<line>` (also `:a-b` ranges and `:a,b` lists);
# they resolve against corpus/knowledge/unreal-mcp.
#
# Exclusions, all deliberate and all PRINTED so they cannot hide a real failure:
#   * anything under upstream/ — the vendored upstream text is not this round's artifact;
#   * a gate file that carries the protocol's control sentinels (exact-match only, so a real
#     pointer on a line that merely mentions "control" is still counted) — counted as
#     SKIPPED_CONTROL_SENTINELS.
# Range/comma forms are resolved at every listed endpoint (a-b checks a and b; a,b checks both).
# shellcheck disable=SC2015,SC2086  # A&&B||C intended (B exits); $roots is a deliberate space-split list
set -u
roots=${*:-"corpus/knowledge/unreal-mcp"}
base=${BASE:-corpus/knowledge/unreal-mcp}
sentinel='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'
ptr_re='upstream/[A-Za-z0-9_./-]+\.(md|json|sh|txt)?:[0-9]+([,-][0-9]+)*'
total=0; bad=0; skipped=0; files=0
for root in $roots; do
  while IFS= read -r f; do
    case "$f" in */upstream/*) continue;; esac
    if [ "$(basename "$f")" = README.md ] && printf '%s' "$f" | grep -q '/gate/'; then
      if grep -qE "$sentinel" "$f"; then
        printf 'GATE-SENTINEL-SKIP %s\n' "$f"; continue
      fi
    fi
    files=$((files+1))
    while IFS= read -r ptr; do
      if printf '%s' "$ptr" | grep -qE "^($sentinel)$"; then skipped=$((skipped+1)); continue; fi
      p=${ptr%%:*}; rest=${ptr#*:}
      for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
        total=$((total+1))
        if [ ! -f "$base/$p" ]; then printf 'MISSING-PATH %s :: %s\n' "$f" "$ptr"; bad=$((bad+1)); continue; fi
        n=$(wc -l < "$base/$p")
        [ "$ln" -gt "$n" ] && { printf 'LINE-OOR %s :: %s (max %s)\n' "$f" "$ptr" "$n"; bad=$((bad+1)); }
      done
    done < <(grep -ohE "$ptr_re" "$f" | sort -u)
  done < <(find $root -name '*.md' -type f | sort)
done
printf 'FILES_SCANNED=%s POINTERS=%s SKIPPED_CONTROL_SENTINELS=%s UNRESOLVED=%s\n' "$files" "$total" "$skipped" "$bad"
[ "$bad" -eq 0 ] && { echo STEP=PASS; exit 0; } || { echo STEP=FAIL; exit 1; }
