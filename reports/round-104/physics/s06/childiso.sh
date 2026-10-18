#!/usr/bin/env bash
# r104 SEAT-06 — child-level isolation probe.
#
# Parent-independent evidence: take ONE child project that already exists in the
# serial tree, run its exact command line N times SERIALLY, then N times
# CONCURRENTLY, and byte-compare every child.log against the serial reference.
# This isolates the child's determinism from any parent-side bookkeeping, so a
# difference here is a genuine child-side nondeterminism (the only way R3 could
# refute the marker).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
GODOT=/usr/bin/godot
CELL="${1:-freeb_ops_gp}"
N="${2:-5}"
SRC="$HERE/serial/r90bt_free_ops_$CELL"
[ -d "$SRC" ] || { echo "no such cell: $SRC"; exit 1; }
SCRIPT="$HERE/serial/r90_child.gd"
CASE="${CELL%_*}"
OUT="$HERE/childiso-$CELL"
mkdir -p "$OUT"
run() { timeout -s KILL 60 "$GODOT" --headless --path "$SRC" \
          --script "$SCRIPT" -- "$CASE" > "$1" 2>&1; echo $?; }

rc=$(run "$OUT/serial.1.log")
cp "$OUT/serial.1.log" "$OUT/ref.log"
echo "serial rep 1 rc=$rc  sha=$(sha256sum < "$OUT/ref.log" | cut -c1-16)"
for i in 2 3 4 5; do
  rc=$(run "$OUT/serial.$i.log")
  cmp -s "$OUT/ref.log" "$OUT/serial.$i.log" \
    && echo "serial rep $i rc=$rc identical" \
    || echo "serial rep $i rc=$rc DIFFERS"
done

t0=$(date +%s%N)
pids=(); for i in $(seq 1 "$N"); do
  timeout -s KILL 60 "$GODOT" --headless --path "$SRC" \
    --script "$SCRIPT" -- "$CASE" > "$OUT/conc.$i.log" 2>&1 &
  pids+=($!)
done
for p in "${pids[@]}"; do wait "$p"; done
t1=$(date +%s%N)
echo "concurrent $N reps wall_ms=$(( (t1 - t0) / 1000000 ))"
same=0
for i in $(seq 1 "$N"); do
  if cmp -s "$OUT/ref.log" "$OUT/conc.$i.log"; then same=$((same+1));
  else echo "  conc rep $i DIFFERS"; diff "$OUT/ref.log" "$OUT/conc.$i.log" | head -4; fi
done
echo "child-level: identical=$same differs=$((N-same)) of $N"
