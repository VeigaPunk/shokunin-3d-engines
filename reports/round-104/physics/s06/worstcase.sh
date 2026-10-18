#!/usr/bin/env bash
# r104 SEAT-06 — R3 worst-case concurrency adversary (correctly designed).
#
# The previous stress.sh shared ONE project dir across N parents, which is the
# documented D2 collision (parent-side scratch reuse) and says nothing about R3.
# This probe instead gives every parent its OWN tree copy, so the only shared
# resource is the CPU. M parents x 21 children = 21M simultaneous Godot boots —
# the exact worst case the R3 patch introduces.
#
# Reference: the serial tree's own solo stdout (runs/$ARM.serial.stdout), which
# is byte-equal to the runner's pinned literal (pinanchor.py).
#
# Any byte differing in any rep, in either tree, is a refutation for that tree.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
GODOT=/usr/bin/godot
ARM="${1:-free_ops}"
M="${2:-4}"
OUT="$HERE/worstcase-$ARM-m$M"
mkdir -p "$OUT"

for tree in serial conc; do
  # M private copies so parents never share a project dir
  for i in $(seq 1 "$M"); do
    rm -rf "$OUT/$tree$i"
    cp -a "$HERE/$tree" "$OUT/$tree$i"
    rm -rf "$OUT/$tree$i/__pycache__" "$OUT/$tree$i"/r90bt_*
  done
done

for tree in serial conc; do
  ref="$HERE/runs/$ARM.serial.stdout"
  [ -s "$ref" ] || { echo "no serial reference"; exit 1; }
  t0=$(date +%s%N)
  pids=()
  for i in $(seq 1 "$M"); do
    timeout -s KILL 300 "$GODOT" --headless --path "$OUT/$tree$i" \
        --script res://phys3d_joints.gd -- "--arm=$ARM" \
        > "$OUT/$tree$i.stdout" 2> "$OUT/$tree$i.stderr" &
    pids+=($!)
  done
  rcs=(); for p in "${pids[@]}"; do wait "$p"; rcs+=($?); done
  t1=$(date +%s%N)
  echo "== $tree: $M parents x 21 children, wall_ms=$(( (t1 - t0) / 1000000 )) rc=${rcs[*]}"
  same=0; diff=0; incon=0
  for i in $(seq 1 "$M"); do
    # A rep that did not itself produce the arm's PASS line is INCONCLUSIVE,
    # not "identical" — an all-killed run would otherwise read as agreement.
    if ! grep -q "^PASS phys3d_joints $ARM " "$OUT/$tree$i.stdout"; then
      incon=$((incon + 1))
      echo "   REP $i INCONCLUSIVE (rc=${rcs[$((i-1))]}, no PASS line; $(wc -c < "$OUT/$tree$i.stdout") bytes)"
      continue
    fi
    if cmp -s "$ref" "$OUT/$tree$i.stdout"; then
      same=$((same + 1))
    else
      diff=$((diff + 1))
      echo "   REP $i DIFFERS vs serial solo reference:"
      diff "$ref" "$OUT/$tree$i.stdout" \
        | grep -o 'mode_ok=[01][^}]*}' | head -6
    fi
  done
  echo "   identical=$same differs=$diff inconclusive=$incon of $M"
done

# NOTE: this script copies M full trees per run (M x 2 x ~12 MB). Those
# worstcase-*/ scratch trees were pruned after r104 to keep the lane checkout
# small; only the .log transcripts above are retained. Re-running the script
# recreates them.
