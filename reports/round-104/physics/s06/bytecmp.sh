#!/usr/bin/env bash
# r104 SEAT-06 determinism-adversary — pre/post byte-identity probe.
#
# Runs each phys3d_joints arm against TWO byte-different copies of the fixture
# tree (serial = HEAD bytes, conc = HEAD + R3 spawn/collect) and compares the
# FULL stdout (banner, M-lines, PASS line) byte for byte.
#
# The parent reads only files on disk, so the identity claim must hold for the
# whole stdout stream, not just the PASS line.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
GODOT=/usr/bin/godot
ARMS="sweep rid api free_pair free_ops detach chain3 twopin"
OUT="$HERE/runs"
mkdir -p "$OUT"

for arm in $ARMS; do
  for tree in serial conc; do
    d="$HERE/$tree"
    t0=$(date +%s%N)
    timeout -s KILL 300 "$GODOT" --headless --path "$d" \
        --script res://phys3d_joints.gd -- "--arm=$arm" \
        > "$OUT/$arm.$tree.stdout" 2> "$OUT/$arm.$tree.stderr"
    rc=$?
    t1=$(date +%s%N)
    echo "$arm $tree rc=$rc wall_ms=$(( (t1 - t0) / 1000000 ))"
  done
  if cmp -s "$OUT/$arm.serial.stdout" "$OUT/$arm.conc.stdout"; then
    echo "IDENTICAL $arm sha=$(sha256sum < "$OUT/$arm.serial.stdout" | cut -c1-16)"
  else
    echo "DIFFERS   $arm serial=$(sha256sum < "$OUT/$arm.serial.stdout" | cut -c1-16) conc=$(sha256sum < "$OUT/$arm.conc.stdout" | cut -c1-16)"
  fi
done
