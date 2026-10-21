#!/usr/bin/env bash
# adv2.sh — GATE-ADV2 (r107) runner. Usage: adv2.sh <case>|all
# Cases: control, H1 H1b H2 H3 H4 H5 H6 H14 H20 H21 H22  (r102 11-class suite)
#        A B C D E F                                       (ADV1's 6 new classes)
source /var/tmp/r107-gateadv2/adv2-lib.sh

case_control() { WS0=$(build_ws control); run_case C0 "clean control (must PASS)" "$WS0"; }

# ---- r102 suite (SEAT-20 F1-F6 attack table) -------------------------------
case_H1() {  # substring label: `NOT-static-only`
  ws=$(build_ws H1); f=$ws/corpus/knowledge/unreal-mcp/executability/blueprints.md
  sed -i '4s/.*/**Label:** `NOT-static-only`/' "$f"
  grep -n 'Label' "$f" | head -1
  run_case H1 "r102 F3 substring label (NOT-static-only)" "$ws"; }

case_H1b() {  # substring label: `static-onlyness`
  ws=$(build_ws H1b); f=$ws/corpus/knowledge/unreal-mcp/executability/blueprints.md
  sed -i '4s/.*/**Label:** `static-onlyness`/' "$f"
  grep -n 'Label' "$f" | head -1
  run_case H1b "r102 F3 substring label (static-onlyness)" "$ws"; }

case_H2() {  # symlink planted in upstream/
  ws=$(build_ws H2); sub=$ws/corpus/knowledge/unreal-mcp
  ln -s /etc/hostname "$sub/upstream/EVIL.md"
  ls -l "$sub/upstream/EVIL.md"
  run_case H2 "r102 F1 non-regular file in upstream/" "$ws"; }

case_H3() {  # 14th card as a symlink
  ws=$(build_ws H3); sub=$ws/corpus/knowledge/unreal-mcp
  ln -s "$sub/executability/blueprints.md" "$sub/executability/zzz-extra.md"
  ls -l "$sub/executability/zzz-extra.md"
  run_case H3 "r102 F1 14th card as symlink" "$ws"; }

case_H4() {  # 14th card in a nested dir
  ws=$(build_ws H4); sub=$ws/corpus/knowledge/unreal-mcp
  mkdir -p "$sub/executability/sub"; cp "$sub/executability/blueprints.md" "$sub/executability/sub/extra.md"
  find "$sub/executability" -mindepth 2
  run_case H4 "r102 F2 nested card under executability/" "$ws"; }

case_H5() {  # subtree-relative dangling pointer
  ws=$(build_ws H5); f=$ws/corpus/knowledge/unreal-mcp/README.md
  printf '\nsee `executability/ghost.md:12`\n' >> "$f"
  tail -2 "$f"
  run_case H5 "r102 F6 subtree-relative dangling ptr" "$ws"; }

case_H6() {  # space in pointer filename
  ws=$(build_ws H6); f=$ws/corpus/knowledge/unreal-mcp/README.md
  printf '\nsee upstream/a b.md:5\n' >> "$f"
  tail -2 "$f"
  run_case H6 "r102 F6 space in pointer name" "$ws"; }

case_H14() {  # CRLF manifest
  ws=$(build_ws H14); m=$ws/corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256
  sed -i 's/$/\r/' "$m"
  od -c "$m" | head -1
  run_case H14 "r102 F4 CRLF manifest" "$ws"; }

case_H20() {  # uppercase .MD file with dangling pointer
  ws=$(build_ws H20); sub=$ws/corpus/knowledge/unreal-mcp
  printf 'see upstream/nope-real.md:3\n' > "$sub/NOTES.MD"
  ls "$sub"/NOTES.MD
  run_case H20 "r102 F6 uppercase .MD not scanned" "$ws"; }

case_H21() {  # :0 pointer (below range)
  ws=$(build_ws H21); f=$ws/corpus/knowledge/unreal-mcp/README.md
  printf '\nsee upstream/README.md:0\n' >> "$f"
  tail -2 "$f"
  run_case H21 "r102 F6 :0 pointer passes range test" "$ws"; }

case_H22() {  # empty ALL seat manifests
  ws=$(build_ws H22); sub=$ws/corpus/knowledge/unreal-mcp
  for m in "$sub"/.manifest.d/seat*.sha256; do printf '# cleared\n' > "$m"; done
  wc -l "$sub"/.manifest.d/seat01.sha256
  run_case H22 "r102 F5 per-seat manifests never verified" "$ws"; }

# ---- ADV1's 6 new classes --------------------------------------------------
case_A() {  # wrong-pin acceptance: gate PIN + all pins changed to a bogus SHA
  ws=$(build_ws A); sub=$ws/corpus/knowledge/unreal-mcp
  BAD=0000000000000000000000000000000000000000
  sed -i "s|^PIN=a6aa73ad.*|PIN=$BAD|" "$sub/gate/run_gate.sh"
  sed -i "s|a6aa73ada02a9fb1f5415bec491f9942c519b297|$BAD|g" "$sub/PROVENANCE.md" "$sub/README.md"
  sed -i "s|a6aa73ada02a9fb1f5415bec491f9942c519b297|$BAD|g" "$sub"/executability/*.md
  grep -n "^PIN=" "$sub/gate/run_gate.sh"
  run_case A "ADV1-A wrong-pin acceptance" "$ws"; }

case_B() {  # delta-blindness: content edit + regenerated manifests (internally consistent)
  ws=$(build_ws B); sub=$ws/corpus/knowledge/unreal-mcp
  printf '\n<!-- delta -->\n' >> "$sub/upstream/README.md"
  regen_manifests "$sub" upstream/README.md
  sha256sum "$sub/upstream/README.md"; grep "upstream/README.md" "$sub/.manifest.d/audit-reference.sha256"
  run_case B "ADV1-B delta-blindness (manifests regenerated)" "$ws"; }

case_C() {  # card <-> PROVENANCE census inconsistency (runtime claim)
  ws=$(build_ws C); sub=$ws/corpus/knowledge/unreal-mcp
  sed -i '4s/.*/**Label:** `verified-here`/' "$sub/executability/blueprints.md"
  sed -i 's|^EXPTECTED_STATIC|X|' "$sub/gate/run_gate.sh" 2>/dev/null
  grep -n 'Label' "$sub/executability/blueprints.md" | head -1
  run_case C "ADV1-C card claims verified-here (runtime)" "$ws"; }

case_D() {  # pin-constant/tree divergence: pin -> r101 pin's PARENT, manifests regenerated
  ws=$(build_ws D); sub=$ws/corpus/knowledge/unreal-mcp
  OLDPIN=$(git -C "$REF" rev-parse "$(git -C "$REF" rev-parse HEAD)^" 2>/dev/null || echo none)
  sed -i "s|^PIN=a6aa73ad.*|PIN=$OLDPIN|" "$sub/gate/run_gate.sh"
  grep -n "^PIN=" "$sub/gate/run_gate.sh"; echo "parent=$OLDPIN"
  run_case D "ADV1-D pin-constant/tree divergence" "$ws"; }

case_E() {  # manifest-superset blindness: planted extra line in a seat manifest
  ws=$(build_ws E); sub=$ws/corpus/knowledge/unreal-mcp
  printf '%s  upstream/GHOST.md\n' "$(sha256sum "$sub/upstream/README.md" | cut -d' ' -f1)" >> "$sub/.manifest.d/seat01.sha256"
  tail -1 "$sub/.manifest.d/seat01.sha256"
  run_case E "ADV1-E manifest-superset blindness" "$ws"; }

case_F() {  # PROVENANCE pin-prose drift (prose SHA != gate PIN)
  ws=$(build_ws F); sub=$ws/corpus/knowledge/unreal-mcp
  sed -i "s|a6aa73ada02a9fb1f5415bec491f9942c519b297|deadbeefdeadbeefdeadbeefdeadbeefdeadbeef|g" "$sub/PROVENANCE.md"
  grep -c 'deadbeef' "$sub/PROVENANCE.md"
  run_case F "ADV1-F PROVENANCE pin-prose drift" "$ws"; }

ALL="control H1 H1b H2 H3 H4 H5 H6 H14 H20 H21 H22 A B C D E F"
R102="control H1 H1b H2 H3 H4 H5 H6 H14 H20 H21 H22"
if [ "${1:-all}" = all ] || [ "${1:-all}" = r102 ]; then
  : > "$ROOT/matrix.txt"
  SEL="$ALL"; [ "$1" = r102 ] && SEL="$R102"
  printf '== ADV2 matrix (%s) | gate sha=%s | ref=%s ==\n' "${1:-all}" "$(sha256sum "$GATE" | cut -c1-16)" "$REF"
  for c in $SEL; do "case_$c"; echo; done
  printf '== matrix.txt ==\n'; cat "$ROOT/matrix.txt"
else
  "case_$1"
fi
