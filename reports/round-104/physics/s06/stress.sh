#!/usr/bin/env bash
# r104 SEAT-06 — load-stress adversary probe.
#
# The refutation risk for R3 is not "does the parent stream stay ordered" (it is
# order-independent by construction: _parts is appended in the original loop
# order). It is that under 21-way concurrency a child is starved past its own
# inner `timeout -s KILL 20` (BOUND_S), yielding rc=137 + sig11=0, which for a
# BIMODAL cell is mode_ok=0 -> a DIFFERENT byte than the serial reference.
#
# This probe runs the free_ops arm N times CONCURRENTLY in each tree and diffs
# every rep against the tree's own solo reference. A single differing byte in
# any rep is a refutation.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
GODOT=/usr/bin/godot
ARM="${1:-free_ops}"
N="${2:-8}"
OUT="$HERE/stress-$ARM"
mkdir -p "$OUT"

for tree in serial conc; do
  ref="$HERE/runs/$ARM.$tree.stdout"
  [ -s "$ref" ] || { echo "no reference for $tree"; continue; }
  pids=()
  t0=$(date +%s%N)
  for i in $(seq 1 "$N"); do
    timeout -s KILL 300 "$GODOT" --headless --path "$HERE/$tree" \
        --script res://phys3d_joints.gd -- "--arm=$ARM" \
        > "$OUT/$tree.$i.stdout" 2> "$OUT/$tree.$i.stderr" &
    pids+=($!)
  done
  rcs=()
  for p in "${pids[@]}"; do wait "$p"; rcs+=($?); done
  t1=$(date +%s%N)
  echo "== $tree: $N concurrent reps, wall_ms=$(( (t1 - t0) / 1000000 )) rc=${rcs[*]}"
  same=0; diff=0
  for i in $(seq 1 "$N"); do
    if cmp -s "$ref" "$OUT/$tree.$i.stdout"; then
      same=$((same + 1))
    else
      diff=$((diff + 1))
      echo "   REP $i DIFFERS vs solo reference"
      diff <(cat "$ref") <(cat "$OUT/$tree.$i.stdout") | head -4
    fi
  done
  echo "   identical=$same differs=$diff of $N"
done
