#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# mut-gate.sh — r107 MUT-GATE: run the REFRESHED gate against the OLD pin's tree.
#               The refreshed gate MUST REJECT it (pin-mismatch class).
#
# Seat KEY=MUT-GATE · lane game-dev-3d-shokunin · round 107 (3D side-round).
#
# WHAT IS MUTATED. The gate's own claim is "the vendored bytes are byte-identical
# to upstream commit $PIN". CHECK 2 is the check that carries it, in two parts:
#   2a  the clone's HEAD must equal $PIN exactly; and
#   2d  each vendored file's sha256 must equal `git show $PIN:<path>`.
# The r107 round re-vendors at a FRESH pin, so the refreshed gate asserts a NEW
# $PIN while the old tree still holds the OLD pin's bytes. That mismatch is the
# class under test: the tree is internally consistent (its manifests match its
# bytes) and only the pin comparison can catch it.
#
# CONSTRUCTED "MOVED PIN" (honest construction, no fabricated content).
# Observed [O]: upstream `main` is STILL a6aa73ad (git ls-remote, this round), so
# a real re-vendor yields no content delta. The "new pin" is therefore taken from
# a REAL upstream object that is a descendant of the old pin and a plausible next
# `main`: PR #9's head, a5180ccd, whose 12-file path set is IDENTICAL to the old
# pin's (only 3 file bodies differ). Two of the cases below build an upstream
# DOUBLE (a local mirror with main forced to that commit) so the network clone
# path can be exercised; the input is labelled [I] there, the gate's behaviour on
# it is [O].
#
# Cases (all staged under $WORK; NOTHING is written into corpus/):
#   M-G0  refreshed gate @ OLD pin + old tree      -> expect PASS  (harness control)
#   M-G1  refreshed gate @ NEW pin + old tree + GATE_REF@new -> expect FAIL (BLOB_DIFFS)
#   M-G2  refreshed gate @ NEW pin + old tree + GATE_REF@old -> expect FAIL (2a: HEAD != pin)
#   M-G3  refreshed gate @ NEW pin + old tree + network clone of a moved-main double -> expect FAIL (BLOB_DIFFS)
#   M-G4  refreshed gate @ NEW pin + NEW tree (+ regenerated manifests) -> expect CHECK 2 PASS
#
# usage: reports/round-107/mutations/mut-gate.sh
# ---------------------------------------------------------------------------
set -u

REPO_DIR=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
SUB_SRC=$REPO_DIR/corpus/knowledge/unreal-mcp
OLD_PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
NEW_PIN=a5180ccd03c2813682a7fa19ca25ee9967bfe1de
WORK=/var/tmp/r107-mut-gate
OUT=$WORK/out
STAGE=$WORK/stage
GATE_DRAFT=$REPO_DIR/reports/round-107/mutations/gate-draft.sh

# Report files the subtree's prose points at (CHECK 4 pass B resolves these
# against REPO_ROOT=staged/). Copied, never symlinked, so the harness is hermetic.
REPORT_PATHS="
reports/round-101/bpy-dissection.md
reports/round-101/navagent-dissection.md
reports/round-101/probes/license-audit.md
reports/round-101/probes/toolset-census.md
reports/round-101/r101-critic-c1.md
reports/round-101/r101-unknowns-map.md
reports/round-101/r101-verification-protocol.md
reports/round-102/gate/adversary-a.md
reports/round-102/reruns/pointer-sweep.sh
reports/round-103/gate/close-runs.md
reports/round-103/gate/exit-codes.md
reports/round-103/gate/hardening.md
reports/round-103/note/author.md
reports/round-103/note/gate-pin.md
reports/round-103/note/urls.md
reports/round-104/gate/workdir.md
corpus/knowledge/engines.md
corpus/artifacts/unreal-r22/README.md
"

rm -rf "$OUT" "$STAGE"
mkdir -p "$OUT" "$STAGE" || exit 1

say() { printf '%s\n' "$*"; }

# ---------------------------------------------------------------------------
# Gate source: prefer the r107 refreshed draft if a sibling seat has landed it,
# else derive the refreshed gate from the installed one by rewriting its PIN
# constant (a one-line, mechanical, reproducible transform). Either way the
# resulting script is recorded by sha256 so the run names exactly what it gated.
# ---------------------------------------------------------------------------
if [ -f "$GATE_DRAFT" ]; then
  GATE_SRC=$GATE_DRAFT; GATE_SRC_KIND='r107-draft'
else
  GATE_SRC=$SUB_SRC/gate/run_gate.sh; GATE_SRC_KIND='installed+pin-rewrite'
fi
# Freeze the gate into the scratch area so a sibling seat editing the draft
# mid-run cannot change the revision under test between cases; the run names
# exactly one sha256.
GATE_FROZEN=$WORK/gate-frozen.sh
cp "$GATE_SRC" "$GATE_FROZEN" || exit 1
GATE_SRC=$GATE_FROZEN
say "GATE_SRC=$GATE_SRC ($GATE_SRC_KIND; frozen copy of the source)"
say "GATE_SRC_SHA256=$(sha256sum "$GATE_SRC" | cut -d' ' -f1)"
say "OLD_PIN=$OLD_PIN"
say "NEW_PIN=$NEW_PIN"

# ---------------------------------------------------------------------------
# stage_tree DEST UPSTREAM_SRC
#   Build a self-contained stand-in repo root: the subtree (prose + gate +
#   manifests + executability) with its upstream/ replaced by UPSTREAM_SRC, plus
#   the external paths CHECK 4 resolves.
# ---------------------------------------------------------------------------
stage_tree() {
  local dest=$1 upstream_src=$2 p
  rm -rf "$dest"
  mkdir -p "$dest/corpus/knowledge/unreal-mcp" "$dest/reports" || return 1
  cp -r "$SUB_SRC/." "$dest/corpus/knowledge/unreal-mcp/" || return 1
  rm -rf "$dest/corpus/knowledge/unreal-mcp/upstream"
  mkdir -p "$dest/corpus/knowledge/unreal-mcp/upstream"
  cp -r "$upstream_src/." "$dest/corpus/knowledge/unreal-mcp/upstream/" || return 1
  for p in $REPORT_PATHS; do
    mkdir -p "$dest/$(dirname "$p")" && cp "$REPO_DIR/$p" "$dest/$p" || return 1
  done
}

# refresh_pin GATE_FILE PIN — rewrite the `PIN=` constant (mechanical).
refresh_pin() {
  local gate=$1 pin=$2
  sed -i "s|^PIN=.*|PIN=$pin|" "$gate" || return 1
  grep -n '^PIN=' "$gate"
}

# refresh_manifests SUB — re-emit both manifest families from the tree's bytes,
# preserving each manifest's path list and order (a complete re-vendor).
refresh_manifests() {
  local sub=$1 m tmp
  for m in "$sub"/.manifest.d/*.sha256; do
    tmp=$m.tmp
    while IFS= read -r line; do
      case "$line" in
        \#*|'') printf '%s\n' "$line" ;;
        *) set -- $line; printf '%s  %s\n' "$(sha256sum "$sub/$2" | cut -d' ' -f1)" "$2" ;;
      esac
    done < "$m" > "$tmp" && mv "$tmp" "$m"
  done
}

# refresh_pins SUB OLD NEW — rewrite every prose declaration of the pin to NEW,
# so a byte-correct new tree is also prose-coherent (CHECK 5). Mechanical
# substitution of the literal 40-hex SHA across the subtree's prose/manifests;
# upstream/ is excluded because it is vendored upstream text.
refresh_pins() {
  local sub=$1 old=$2 new=$3 f
  find "$sub" -type f \( -iname '*.md' -o -iname '*.sha256' -o -iname '*.txt' \) \
    -not -path "$sub/upstream/*" -print0 |
    while IFS= read -r -d '' f; do
      grep -q "$old" "$f" 2>/dev/null && sed -i "s/$old/$new/g" "$f"
    done
}

# run_case NAME GATE SUB [ENV=VAL ...]
run_case() {
  local name=$1 gate=$2 sub=$3; shift 3
  local f=$OUT/$name.out
  ( export GATE_WORKDIR=$WORK/scratch; mkdir -p "$GATE_WORKDIR"
    if [ $# -gt 0 ]; then export "$@"; fi
    timeout 300 bash "$gate" ) >"$f" 2>&1
  local rc=$?
  say ""
  say "===== CASE $name  rc=$rc  env: ${*:-<none>}"
  grep -E '^(CLONE_HEAD|CLONE_DIRTY|CLONE_TRACKED|PATH_EXTRA|PATH_MISSING|BLOB_DIFFS|MANIFEST_OK|CARDS=|POINTERS=|FAIL |STEP=|GATE RESULT:)' "$f" | sed 's/^/  /'
  say "  [full: $f]"
  return $rc
}

# ---------------------------------------------------------------------------
# Staging
# ---------------------------------------------------------------------------
stage_tree "$STAGE/old" "$SUB_SRC/upstream" || { say "STAGE FAILED"; exit 1; }
say "staged old tree: $(find "$STAGE/old/corpus/knowledge/unreal-mcp/upstream" -type f | wc -l) upstream files"

REF_NEW=$WORK/ref-new
REF_OLD=$WORK/ref
if [ ! -d "$REF_NEW" ]; then say "MISSING $REF_NEW (run: git -C $REF_OLD worktree add --detach $REF_NEW $NEW_PIN)"; exit 1; fi
if [ "$(git -C "$REF_NEW" rev-parse HEAD)" != "$NEW_PIN" ]; then say "REF_NEW HEAD != NEW_PIN"; exit 1; fi
if [ "$(git -C "$REF_OLD" rev-parse HEAD)" != "$OLD_PIN" ]; then say "REF_OLD HEAD != OLD_PIN"; exit 1; fi
say "REF_OLD=$REF_OLD @ $(git -C "$REF_OLD" rev-parse HEAD)"
say "REF_NEW=$REF_NEW @ $(git -C "$REF_NEW" rev-parse HEAD)"

# new-pin upstream source (tracked files only, at NEW_PIN)
NEWUP=$STAGE/newupstream
rm -rf "$NEWUP"; mkdir -p "$NEWUP"
(cd "$REF_NEW" && git ls-files -z | while IFS= read -r -d '' f; do
   mkdir -p "$NEWUP/$(dirname "$f")" && cp "$f" "$NEWUP/$f"
 done) || exit 1
say "new-pin upstream files: $(find "$NEWUP" -type f | wc -l)"

# Case M-G0: refreshed gate @ OLD pin (harness control)
cp "$GATE_SRC" "$STAGE/old/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
refresh_pin "$STAGE/old/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$OLD_PIN"
run_case M-G0-oldpin-baseline "$STAGE/old/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$STAGE/old" GATE_REF=$REF_OLD

# Case M-G1: refreshed gate @ NEW pin, OLD tree, ref at NEW pin -> 2d must red
cp "$GATE_SRC" "$STAGE/old/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
refresh_pin "$STAGE/old/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$NEW_PIN"
run_case M-G1-newpin-oldtree-refnew "$STAGE/old/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$STAGE/old" GATE_REF=$REF_NEW

# Case M-G2: refreshed gate @ NEW pin, OLD tree, ref at OLD pin -> 2a must red
run_case M-G2-newpin-oldtree-refold "$STAGE/old/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$STAGE/old" GATE_REF=$REF_OLD

# Case M-G3: refreshed gate @ NEW pin, OLD tree, NETWORK clone of a moved-main
# upstream double ([I] constructed input; the gate behaviour is [O]).
MIRROR=$WORK/mirror-new.git
if [ ! -d "$MIRROR" ]; then
  git clone --quiet --bare "$REF_OLD" "$MIRROR" && git -C "$MIRROR" update-ref refs/heads/main "$NEW_PIN"
fi
say "MIRROR main -> $(git -C "$MIRROR" rev-parse refs/heads/main)  [I] constructed upstream double"
run_case M-G3-newpin-oldtree-clone "$STAGE/old/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$STAGE/old" REPO=$MIRROR

# Case M-G4: refreshed gate @ NEW pin, NEW tree + regenerated manifests + prose
# refreshed to NEW pin -> the gate must be SATISFIABLE (all five checks PASS).
# This is the control that proves the reds above are pin-mismatch, not a gate
# that is red by construction.
stage_tree "$STAGE/new" "$NEWUP" || exit 1
cp "$GATE_SRC" "$STAGE/new/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
refresh_pin "$STAGE/new/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$NEW_PIN"
refresh_pins "$STAGE/new/corpus/knowledge/unreal-mcp" "$OLD_PIN" "$NEW_PIN"
refresh_manifests "$STAGE/new/corpus/knowledge/unreal-mcp"
run_case M-G4-newpin-newtree-coherent "$STAGE/new/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$STAGE/new" GATE_REF=$REF_NEW

# Case M-G6: NEW tree BYTES (correct at the new pin), manifests regenerated, but
# the PROSE left at the old pin. CHECK 2 passes on bytes; only the refreshed
# gate's new CHECK 5 (pin coherence) can reject — the discriminating control for
# the second, independent rejection channel the r107 refresh added.
stage_tree "$STAGE/prose-stale" "$NEWUP" || exit 1
cp "$GATE_SRC" "$STAGE/prose-stale/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
refresh_pin "$STAGE/prose-stale/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$NEW_PIN"
refresh_manifests "$STAGE/prose-stale/corpus/knowledge/unreal-mcp"
run_case M-G6-newbytes-staleprose "$STAGE/prose-stale/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$STAGE/prose-stale" GATE_REF=$REF_NEW

# Case M-G5: the SAME prose-stale tree under the INSTALLED (r102..r106, 4-check)
# gate, pin-rewritten to NEW. It has no CHECK 5, so it must PASS — the blind spot
# the r107 refresh closes. Same input as M-G6, only the gate revision differs.
stage_tree "$STAGE/blind" "$NEWUP" || exit 1
cp "$SUB_SRC/gate/run_gate.sh" "$STAGE/blind/corpus/knowledge/unreal-mcp/gate/run_gate.sh"
refresh_pin "$STAGE/blind/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$NEW_PIN"
refresh_manifests "$STAGE/blind/corpus/knowledge/unreal-mcp"
say "BLIND_GATE_SHA256=$(sha256sum "$SUB_SRC/gate/run_gate.sh" | cut -d' ' -f1) (installed 4-check gate)"
run_case M-G5-staleprose-installedgate "$STAGE/blind/corpus/knowledge/unreal-mcp/gate/run_gate.sh" "$STAGE/blind" GATE_REF=$REF_NEW

say ""
say "MATRIX DONE — outputs in $OUT"
