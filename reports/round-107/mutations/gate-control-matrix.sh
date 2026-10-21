#!/usr/bin/env bash
# r107 GATE-LEAD — control matrix against the DRAFT gate (CHECK 5 + 2e added).
# Runs each mutation on a throwaway copy; never touches the pinned tree.
set -u
LANE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
BASE=/var/tmp/r107-gatelead/draftws/ws
AW=/var/tmp/r107-gatelead/caw
SCRATCH=/var/tmp/r107-gatelead/cscratch
GATE=corpus/knowledge/unreal-mcp/gate/run_gate.sh
SUB=corpus/knowledge/unreal-mcp
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
mkdir -p "$SCRATCH"
ROWS=/var/tmp/r107-gatelead/matrix-rows.txt
: > "$ROWS"

fresh(){ rm -rf "$AW"; cp -a "$BASE" "$AW"; }
emit(){ local lbl=$1 expect=$2 rc=$3 reason=${4:-}
  local v; if [ "$expect" = "$rc" ]; then v="OK"; else v="**MISMATCH**"; fi
  printf '%-26s expect=%-3s rc=%-3s %-12s %s\n' "$lbl" "$expect" "$rc" "$v" "$reason" >> "$ROWS"
  printf '%-26s expect=%-3s rc=%-3s %-12s\n' "$lbl" "$expect" "$rc" "$v"; }
run(){ local lbl=$1 expect=$2; shift 2
  local out=$AW/.gate.out
  ( cd "$AW" && env GATE_WORKDIR="$SCRATCH" "$@" bash "$GATE" ) > "$out" 2>&1
  local rc=$?
  local reason; reason=$(grep -E '^(FAIL|BLOB-DIFF|MODE-DIFF|pin-drift|GATE RESULT|STEP=BLOCKED|CHECK 2 BLOCKED)' "$out" | head -2 | tr '\n' ';')
  emit "$lbl" "$expect" "$rc" "$reason"; }

M=$SUB; U=$SUB/upstream; E=$SUB/executability

echo "== A: regression — old checks must still behave =="
fresh; run A0-clean 0
fresh; printf '\n' >> "$AW/$U/README.md"; run C1-byteflip 1
fresh; rm "$AW/$U/LICENSE"; run C2-delete 1
fresh; printf '\nsee upstream/README.md:200\n' >> "$AW/$M/README.md"; run C3-oor-pointer 1
fresh; sed -i '4s/.*/**Label:** `static-only` and not `verified-here`/' "$AW/$E/blueprints.md"; run C4-multilabel 1
fresh; sed -i '4s/.*/**Label:** `unproven-runtime`/' "$AW/$E/blueprints.md"; run C5-census 1
fresh; rm "$AW/$E/sequencer.md"; run C6-carddrop 1
# C7 positive control: plant ONLY the exact sentinels, in a .txt (pass A scans
# .txt, pass B greps .md only) so they are extracted as the sentinel strings and
# skipped — the filter's own control that it skips only those and stays green.
fresh; printf 'see upstream/nope.md:1\nand upstream/README.md:9999\n' > "$AW/$M/zz-sentinel.txt"; run C7-sentinels 0

echo "== B: NEW — CHECK 5 pin coherence (expect 1) =="
fresh; sed -i "s/$PIN/deadbeefdeadbeefdeadbeefdeadbeefdeadbeef/" "$AW/$M/PROVENANCE.md"; run D1-provenance 1
fresh; sed -i "s/$PIN/deadbeefdeadbeefdeadbeefdeadbeefdeadbeef/" "$AW/$M/README.md"; run D2-subtree-readme 1
fresh; sed -i "s/$PIN/deadbeefdeadbeefdeadbeefdeadbeefdeadbeef/" "$AW/$M/.manifest.d/audit-reference.sha256"; run D3-manifest-hdr 1
fresh; sed -i "s/$PIN/1111111111111111111111111111111111111111/" "$AW/$M/PROVENANCE.md"; run D8-other-40hex 1
fresh; sed -i "s/$PIN/deadbeefdeadbeefdeadbeefdeadbeefdeadbeef/" "$AW/$E/blueprints.md"; run D9-card 1
fresh; sed -i "s/$PIN/deadbeefdeadbeefdeadbeefdeadbeefdeadbeef/" "$AW/$M/gate/README.md"; run D10-gate-readme-row 1
fresh; sed -i 's/CLONE_HEAD=a6aa73ad/CLONE_HEAD=deadbeef/' "$AW/$M/gate/README.md"; run D11-clonehead-line 1
fresh; sed -i "s/$PIN/deadbeefdeadbeefdeadbeefdeadbeefdeadbeef/" "$AW/$M/adaptation-kimi.md"; run D12-adaptation 1
fresh; sed -i "s/$PIN/deadbeefdeadbeefdeadbeefdeadbeefdeadbeef/" "$AW/$E/vfx-niagara-dataflow.md"; run D13-vfx-card 1

echo "== C: NEW — CHECK 2e mode equivalence (expect 1) =="
fresh; chmod +x "$AW/$U/hooks/hooks.json"; run M1-mode-755 1
fresh; chmod 600 "$AW/$U/README.md"; run M2-mode-600 1
fresh; chmod 777 "$AW/$U/skills/unreal-mcp/SKILL.md"; run M3-mode-777 1

echo "== D: CHECK 5 false-positive controls (expect 0) =="
fresh; printf '\nsee commit be8c1833d4e3b8412c5dfde9d0a1e67bb2a671d1 for history\n' >> "$AW/$M/PROVENANCE.md"; run N1-history-sha 0
fresh; printf '\nthe pin moved and old commit be8c1833d4e3b8412c5dfde9d0a1e67bb2a671d1 was superseded\n' >> "$AW/$M/PROVENANCE.md"; run N2-prose-pin-history 0
fresh; printf '\n| F99 | blob `eaf2e838a259fb41be10309f9373bca8778607c5` history-only |\n' >> "$AW/$M/PROVENANCE.md"; run N3-history-blob 0
fresh; printf '\nBuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19` is unrelated\n' >> "$AW/$M/adaptation-kimi.md"; run N4-kimi-buildid 0

echo "== E: determinism =="
for i in 1 2 3; do fresh; run "E1-det-$i" 0; done

echo
echo "== SUMMARY =="
total=$(wc -l < "$ROWS"); bad=$(grep -c 'MISMATCH' "$ROWS")
echo "rows=$total mismatches=$bad"
grep 'MISMATCH' "$ROWS" || echo "(no mismatches)"
