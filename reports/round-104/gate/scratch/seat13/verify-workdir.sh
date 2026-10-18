#!/usr/bin/env bash
# SEAT-13 WORKDIR-VERIFIER — evidence harness for the r104 GATE_WORKDIR change.
# Writes raw evidence into ./out/ and never mutates the gate or the subtree.
#
#   verify-workdir.sh baseline   capture default-run stdout+rc (pre-change "before")
#   verify-workdir.sh after      re-run default + GATE_WORKDIR + TMPDIR probes
#   verify-workdir.sh compare    byte-compare after vs baseline
#
# Every assertion below prints the command it ran and its observed output, so the
# report can quote real receipts rather than paraphrase them.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=$(cd "$HERE/../../../.." && pwd)
GATE=$REPO/corpus/knowledge/unreal-mcp/gate/run_gate.sh
OUT=$HERE/out
mkdir -p "$OUT"

run_gate() {  # $1 = label, rest = env assignments already exported by caller
  local label=$1; shift
  "$@" bash "$GATE" >"$OUT/$label.stdout" 2>"$OUT/$label.stderr"
  echo "$?" >"$OUT/$label.rc"
}

# Watch a directory for the lifetime of one gate run and record every path that
# appears under it. The gate's scratch dir exists only between mktemp and the EXIT
# trap, so a poller is the only way to prove CREATED-and-REMOVED rather than just
# "absent now". 20 ms poll vs a ~1 s run => ~45 samples, comfortably enough.
watch_dir() {  # $1 = dir to watch, $2 = file to log paths into
  local d=$1 log=$2
  : >"$log"
  while :; do
    [ -d "$d" ] && find "$d" -mindepth 1 -maxdepth 2 2>/dev/null >>"$log"
    sleep 0.02
  done
}

case "${1:-}" in
baseline)
  run_gate before
  printf 'BEFORE rc=%s stdout_sha=%s\n' "$(cat "$OUT/before.rc")" \
    "$(sha256sum <"$OUT/before.stdout" | cut -d' ' -f1)"
  ;;
after)
  # --- default run (no env): must stay byte-identical to the pre-change baseline
  run_gate after-default
  printf 'AFTER-DEFAULT rc=%s stdout_sha=%s\n' "$(cat "$OUT/after-default.rc")" \
    "$(sha256sum <"$OUT/after-default.stdout" | cut -d' ' -f1)"

  # --- GATE_WORKDIR probe: repo-local scratch dir
  GW=$HERE/gate-workdir-probe
  rm -rf "$GW"; mkdir -p "$GW"
  watch_dir "$GW" "$OUT/gate-workdir.seen" &
  WATCH=$!
  GATE_WORKDIR="$GW" bash "$GATE" >"$OUT/gate-workdir.stdout" 2>&1
  echo "$?" >"$OUT/gate-workdir.rc"
  kill "$WATCH" 2>/dev/null; wait "$WATCH" 2>/dev/null
  sort -u "$OUT/gate-workdir.seen" >"$OUT/gate-workdir.seen.uniq"
  printf 'GATE_WORKDIR rc=%s seen_paths=%s residual_after=%s\n' \
    "$(cat "$OUT/gate-workdir.rc")" "$(wc -l <"$OUT/gate-workdir.seen.uniq")" \
    "$(find "$GW" -mindepth 1 2>/dev/null | wc -l)"

  # --- TMPDIR probe: workdir must land under TMPDIR when GATE_WORKDIR is unset
  TD=$HERE/tmpdir-probe
  rm -rf "$TD"; mkdir -p "$TD"
  watch_dir "$TD" "$OUT/tmpdir.seen" &
  WATCH=$!
  TMPDIR="$TD" bash "$GATE" >"$OUT/tmpdir.stdout" 2>&1
  echo "$?" >"$OUT/tmpdir.rc"
  kill "$WATCH" 2>/dev/null; wait "$WATCH" 2>/dev/null
  sort -u "$OUT/tmpdir.seen" >"$OUT/tmpdir.seen.uniq"
  printf 'TMPDIR rc=%s seen_paths=%s residual_after=%s\n' \
    "$(cat "$OUT/tmpdir.rc")" "$(wc -l <"$OUT/tmpdir.seen.uniq")" \
    "$(find "$TD" -mindepth 1 2>/dev/null | wc -l)"
  ;;
compare)
  if cmp -s "$OUT/before.stdout" "$OUT/after-default.stdout"; then
    echo "BYTE-IDENTICAL: before.stdout == after-default.stdout"
  else
    echo "DIFFERS:"; diff "$OUT/before.stdout" "$OUT/after-default.stdout" | head -40
  fi
  echo "before rc=$(cat "$OUT/before.rc") after-default rc=$(cat "$OUT/after-default.rc")"
  ;;
*) echo "usage: $0 baseline|after|compare" >&2; exit 2;;
esac
