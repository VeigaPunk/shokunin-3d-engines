#!/usr/bin/env bash
# SEAT-48 CLOSE-FLAKE-RERUN: 6 consecutive gate runs at the close of r104.
# Records per-run: gate sha256, /tmp free, rc, verdict, POINTERS, wall time,
# and a structural check (4 STEP lines). Never mutates the tree.
set -u
REPO=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
GATE=$REPO/corpus/knowledge/unreal-mcp/gate/run_gate.sh
SUB=$REPO/corpus/knowledge/unreal-mcp
OUT=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/reports/round-104/gate/scratch/seat48
mkdir -p "$OUT"

printf 'run\tts_utc\tgate_sha12\ttmp_avail\trc\tverdict\tstep_pass\tstep_bad\tpointers\tunresolved\tsecs\n' > "$OUT/table.tsv"

for i in 1 2 3 4 5 6; do
  sha=$(sha256sum "$GATE" | cut -c1-12)
  tmpavail=$(df -h --output=avail /tmp | tail -1 | tr -d ' ')
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  start=$(date +%s.%N)
  ( cd "$REPO" && bash "$GATE" ) > "$OUT/run-$i.log" 2>&1
  rc=$?
  end=$(date +%s.%N)
  secs=$(awk -v a="$start" -v b="$end" 'BEGIN{printf "%.2f", b-a}')
  verdict=$(grep -E '^GATE RESULT:' "$OUT/run-$i.log" | tail -1 | sed 's/^GATE RESULT: //')
  npass=$(grep -cE '^STEP=PASS$' "$OUT/run-$i.log")
  nbad=$(grep -cE '^STEP=(FAIL|BLOCKED)$' "$OUT/run-$i.log")
  ptr=$(grep -oE '^POINTERS=[0-9]+ POINTER_STRINGS=[0-9]+ SKIPPED_CONTROL_SENTINELS=[0-9]+ UNRESOLVED=[0-9]+' "$OUT/run-$i.log" | tail -1)
  pcount=$(printf '%s' "$ptr" | grep -oE '^POINTERS=[0-9]+' | cut -d= -f2)
  unres=$(printf '%s' "$ptr" | grep -oE 'UNRESOLVED=[0-9]+$' | cut -d= -f2)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$i" "$ts" "$sha" "$tmpavail" "$rc" "$verdict" "$npass" "$nbad" "${pcount:-?}" "${unres:-?}" "$secs" >> "$OUT/table.tsv"
  printf 'run %s rc=%s verdict=%s steps=%s/%s POINTERS=%s UNRESOLVED=%s %ss\n' \
    "$i" "$rc" "$verdict" "$npass" "$nbad" "${pcount:-?}" "${unres:-?}" "$secs"
done

echo "--- per-run stdout sha256 (identity check) ---"
for i in 1 2 3 4 5 6; do printf '%s  run-%s.log\n' "$(sha256sum "$OUT/run-$i.log" | cut -d' ' -f1)" "$i"; done
echo "--- tree hash after window ---"
(cd "$SUB" && find upstream executability .manifest.d -type f | sort | xargs sha256sum) | sha256sum
echo "--- final table ---"
cat "$OUT/table.tsv"
