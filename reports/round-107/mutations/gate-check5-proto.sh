#!/usr/bin/env bash
# Prototype v3 — shape-anchored CHECK 5 (kills the FP1/FP2 prose residual).
# A pin declaration is a 40-hex token on a line matching one of the declared
# pin-declaration SHAPES, or a rev-parse/CLONE_HEAD line.
set -u
SUB=${1:?subtree}
PIN=${2:-}
[ -n "$PIN" ] || PIN=$(grep -m1 '^PIN=' "$SUB/gate/run_gate.sh" | cut -d= -f2)
HEX='[0-9a-f]{40}'
# Shapes the subtree actually uses (see r107-gate.md §declaration shapes):
SHAPE='(\|[^|]*[Pp]in[^|]*\|)|(\*\*[^*]*[Pp]in[^*]*\*\*)|(\b[Pp]inned (SHA|commit)\b)|(\bpinned at\b)|(\bPinned SHA:)'
N=0; D=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in "$SUB"/upstream/*|"$SUB"/gate/run_gate.sh) continue;; esac
  prev=''; ln=0
  while IFS= read -r line; do
    ln=$((ln+1))
    hexes=$(printf '%s' "$line" | grep -oE "\b$HEX\b")
    if [ -n "$hexes" ]; then
      decl=0
      printf '%s' "$line" | grep -qE "$SHAPE" && decl=1
      printf '%s' "$line" | grep -qE 'rev-parse HEAD' && decl=1
      printf '%s' "$prev" | grep -qE 'rev-parse HEAD' && printf '%s' "$line" | grep -qE "^[[:space:]]*${HEX}[[:space:]]*$" && decl=1
      printf '%s' "$line" | grep -qE 'CLONE_HEAD=' && decl=1
      printf '%s' "$line" | grep -qE '^#[[:space:]]*pinned SHA:' && decl=1
      if [ "$decl" -eq 1 ]; then
        N=$((N+1))
        bad=0; for h in $hexes; do [ "$h" = "$PIN" ] || bad=1; done
        [ "$bad" -eq 1 ] && { printf 'FAIL pin-drift %s:%s :: %s\n' "${f#"$SUB"/}" "$ln" "$(printf '%s' "$line"|cut -c1-90)"; D=$((D+1)); }
      fi
    fi
    prev=$line
  done < "$f"
done < <(find "$SUB" -type f \( -iname '*.md' -o -iname '*.sha256' -o -iname '*.txt' \) | sort)
echo "PIN_DECL_LINES=$N DRIFT=$D"
[ "$D" -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
