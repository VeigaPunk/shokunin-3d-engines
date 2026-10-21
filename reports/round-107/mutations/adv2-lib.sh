#!/usr/bin/env bash
# adv2-lib.sh — GATE-ADV2 (r107) shared library. Sourced by adv2.sh. No `set -u`
# (several helpers take optional args). Writes only under /var/tmp/r107-gateadv2.
REPO=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
SUBREL=corpus/knowledge/unreal-mcp
GATE=${GATE_SRC:-$REPO/$SUBREL/gate/run_gate.sh}
REF=${GATE_REF:-/var/tmp/r104suite/ref}
ROOT=/var/tmp/r107-gateadv2
WS=$ROOT/ws
mkdir -p "$ROOT/work" "$WS"

build_ws() {
  local name="$1" ws="$WS/$1" b cb c e
  rm -rf "$ws"; mkdir -p "$ws/corpus/knowledge"
  cp -a "$REPO/$SUBREL" "$ws/corpus/knowledge/unreal-mcp"
  for e in "$REPO"/*; do
    b=$(basename "$e"); [ "$b" = corpus ] && continue
    ln -sfn "$e" "$ws/$b"
  done
  for c in "$REPO"/corpus/*; do
    cb=$(basename "$c"); [ "$cb" = knowledge ] && continue
    ln -sfn "$c" "$ws/corpus/$cb"
  done
  for c in "$REPO"/corpus/knowledge/*; do
    cb=$(basename "$c"); [ "$cb" = unreal-mcp ] && continue
    ln -sfn "$c" "$ws/corpus/knowledge/$cb"
  done
  # optional: install a candidate gate (must live inside the ws so $SUB resolves)
  if [ -n "${GATE_OVERRIDE:-}" ]; then
    cp "$GATE_OVERRIDE" "$ws/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
    chmod +x "$ws/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
  fi
  echo "$ws"
}

run_case() {
  local id="$1" class="$2" ws="$3" g
  g=${CASE_GATE:-$ws/corpus/knowledge/unreal-mcp/gate/run_gate.sh}
  ( cd "$ws" && env GATE_REF="$REF" GATE_WORKDIR="$ROOT/work" /usr/bin/bash "$g" ) >"$ws/gate.out" 2>&1
  local rc=$? v=MISSED
  [ "$rc" -eq 1 ] && v=DETECTED; [ "$rc" -eq 2 ] && v=BLOCKED
  local steps why
  steps=$(grep -E '^STEP=' "$ws/gate.out" | tr '\n' ' ')
  why=$(grep -E '^FAIL |^BLOB-DIFF |^MISSING-PATH|^LINE-|^FAIL non' "$ws/gate.out" | head -2 | tr '\n' ';')
  printf '%-5s | %-8s | rc=%s | %s\n' "$id" "$v" "$rc" "$class"
  printf '        STEPs: %s\n        evidence: %s\n' "$steps" "${why:-<none>}"
  printf '%-5s %-8s rc=%s %s\n' "$id" "$v" "$rc" "$class" >> "$ROOT/matrix.txt"
}

regen_manifests() {   # $1=subtree  $2=relpath
  local sub="$1" rel="$2" h m
  h=$(sha256sum "$sub/$rel" | cut -d' ' -f1)
  for m in "$sub"/.manifest.d/*.sha256; do
    grep -q "  $rel\$" "$m" || continue
    sed -i "s|^[0-9a-f]\{64\}  $rel\$|$h  $rel|" "$m"
  done
}
