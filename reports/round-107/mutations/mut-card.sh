#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# reports/round-107/mutations/mut-card.sh — MUT-CARD harness (round 107).
#
# Question this answers: if ONE executability card's PATH is corrupted, does the
# cards review (and/or the close-out gate) CATCH it? A harness only counts if
# the same runner is GREEN on the clean tree and RED on every mutation.
#
# Two reviewers are exercised, independently:
#   G = corpus/knowledge/unreal-mcp/gate/run_gate.sh   (the close-out gate, copied bytes)
#   R = reports/round-107/mutations/cards-review.sh    (this seat's card reviewer)
#
# The tree under test is a hardlink clone of a staged full lane copy, so the
# gate's REPO_ROOT (= SUB/../../..) resolves exactly as it does in production,
# and each variant starts from pristine bytes.
#
# LINK DISCIPLINE (this bit the harness once — kept as a warning): `cp -al`
# gives the variant tree and the staged source SHARED INODES. Rewriting a file
# in place (`python write_text`, `sed -i`, `tee`) writes THROUGH the hardlink
# and silently corrupts the staged source for every later variant. Every
# mutation here therefore goes through `edit_file()`, which removes the variant's
# link first so the replacement gets a private inode. Each variant's landing is
# confirmed with sha256sum against the staged source afterwards.
#
# usage: mut-card.sh <workdir> <lane-copy> <review-script> <outdir>
# ---------------------------------------------------------------------------
set -u
WORK=${1:?usage: mut-card.sh <workdir> <lane-copy> <review-script> <outdir>}
LANE=${2:?}
REVIEW=${3:?}
OUT=${4:?}
mkdir -p "$WORK" "$OUT"
# absolute: run_both() cds into each variant tree before invoking the reviewers
REVIEW=$(cd "$(dirname "$REVIEW")" && pwd)/$(basename "$REVIEW")
LANE=$(cd "$LANE" && pwd)
SUB_REL=corpus/knowledge/unreal-mcp

# --- build one variant tree (hardlink clone; mutations replace, never edit) --
mkvariant() { # $1 = variant id
  local v=$1
  local t="$WORK/$v"
  rm -rf "$t"
  cp -al "$LANE" "$t" || { printf 'HARNESS-FAIL cp -al %s\n' "$t"; return 1; }
  printf '%s' "$t"
}

# --- break the hardlink, then replace an exact anchor (asserted unique) -----
edit_file() { # $1 = variant tree  $2 = repo-relative path  $3 = old  $4 = new  $5 = label
  local t=$1 rel=$2 old=$3 new=$4 label=$5
  rm -f "$t/$rel"
  python3 - "$LANE/$rel" "$t/$rel" "$old" "$new" <<'PY'
import sys, pathlib
src, dst, old, new = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3], sys.argv[4]
s = src.read_text()
assert s.count(old) == 1, f"anchor count {s.count(old)}"
dst.write_text(s.replace(old, new, 1))
PY
  local rc=$?
  if [ "$rc" -ne 0 ]; then printf 'HARNESS-FAIL edit %s (%s)\n' "$label" "$rel"; return 1; fi
  local a b
  a=$(sha256sum "$LANE/$rel" | cut -d' ' -f1); b=$(sha256sum "$t/$rel" | cut -d' ' -f1)
  [ "$a" != "$b" ] || { printf 'HARNESS-FAIL mutation did not land %s (%s)\n' "$label" "$rel"; return 1; }
  printf '  landed %s: %s\n' "$label" "$rel" >> "$OUT/matrix.txt"
}

# --- confirm a mutation target really differs from the pristine source ------
# (the earlier version warned for every *unmutated* file too — noise, removed)
verify_landed() { # $1 = variant tree  $2 = repo-relative path
  local t=$1 rel=$2 a b
  a=$(sha256sum "$LANE/$rel" | cut -d' ' -f1)
  b=$(sha256sum "$t/$rel" 2>/dev/null | cut -d' ' -f1)
  if [ "$a" = "$b" ]; then printf 'HARNESS-FAIL mutation did not land: %s\n' "$rel"; return 1; fi
  return 0
}

run_both() { # $1 = variant id  $2 = tree  $3 = mutation description
  local v=$1 t=$2 desc=$3 rc_g rc_r
  {
    printf '### variant %s — %s\n' "$v" "$desc"
    printf '$ GATE_WORKDIR=%s bash %s/gate/run_gate.sh\n' "$WORK" "$SUB_REL"
  } >> "$OUT/matrix.txt"
  ( cd "$t" && GATE_WORKDIR="$WORK" bash "$t/$SUB_REL/gate/run_gate.sh" ) \
      > "$OUT/$v.gate.txt" 2>&1
  rc_g=$?
  ( cd "$t" && bash "$REVIEW" "$SUB_REL" ) > "$OUT/$v.review.txt" 2>&1
  rc_r=$?
  printf '  gate exit=%s  %s\n' "$rc_g" "$(grep -m1 'GATE RESULT' "$OUT/$v.gate.txt")" >> "$OUT/matrix.txt"
  printf '  gate check3=%s check4=%s\n' \
    "$(awk '/CHECK 3/{f=1} f&&/^STEP=/{print;exit}' "$OUT/$v.gate.txt")" \
    "$(awk '/CHECK 4/{f=1} f&&/^STEP=/{print;exit}' "$OUT/$v.gate.txt")" >> "$OUT/matrix.txt"
  printf '  review exit=%s  %s\n' "$rc_r" "$(grep -m1 'CARDS-REVIEW RESULT' "$OUT/$v.review.txt")" >> "$OUT/matrix.txt"
  printf '  gate FAIL lines:\n' >> "$OUT/matrix.txt"
  grep -E '^(FAIL|MISSING-PATH|LINE-OOR|LINE-ZERO|MISSING-PATH-REL|CARDS=|NAME_SET|POINTERS=|CENSUS)' \
    "$OUT/$v.gate.txt" | sed 's/^/    G| /' >> "$OUT/matrix.txt"
  printf '  review FAIL lines:\n' >> "$OUT/matrix.txt"
  grep -E '^REVIEW-FAIL|^CARDS-REVIEW (FAILS|cards_labeled|RESULT)' \
    "$OUT/$v.review.txt" | sed 's/^/    R| /' >> "$OUT/matrix.txt"
  printf '\n' >> "$OUT/matrix.txt"
  printf '%-16s gate_exit=%s review_exit=%s\n' "$v" "$rc_g" "$rc_r"
}

: > "$OUT/matrix.txt"
printf 'MUT-CARD harness · lane copy=%s · reviewers: gate + cards-review\n\n' "$LANE" >> "$OUT/matrix.txt"

# =========================== M0 BASELINE (clean) ===========================
T=$(mkvariant M0-clean) || exit 1
run_both M0-clean "$T" "no mutation (control) — must be GREEN on both reviewers"

# ============ M1 filename corruption: rename a card (typo'd stem) ==========
T=$(mkvariant M1-filename) || exit 1
rm -f "$T/$SUB_REL/executability/blueprint.md"
mv "$T/$SUB_REL/executability/blueprints.md" "$T/$SUB_REL/executability/blueprint.md"
printf '  landed M1: executability/blueprints.md -> blueprint.md\n' >> "$OUT/matrix.txt"
run_both M1-filename "$T" "card filename typo (blueprints.md -> blueprint.md)"

# ============ M2 pointer PATH corruption inside a card ====================
T=$(mkvariant M2-pointer-path) || exit 1
edit_file "$T" "$SUB_REL/executability/sequencer.md" \
  '| 2 | `upstream/README.md:106` | `Sequencer`' \
  '| 2 | `upstream/READMEE.md:106` | `Sequencer`' M2
run_both M2-pointer-path "$T" "cited upstream path renamed (READMEE.md) in sequencer.md"

# ============ M3 pointer LINE out of range ================================
# NOTE: NOT `upstream/README.md:9999` — that is one of the gate's own documented
# control sentinels (deliberately skipped by CHECK 4), so it would prove nothing.
# 4242 is out of range (README.md is 112 lines) and is not a sentinel.
T=$(mkvariant M3-line-oor) || exit 1
edit_file "$T" "$SUB_REL/executability/sequencer.md" \
  '| 2 | `upstream/README.md:106` | `Sequencer`' \
  '| 2 | `upstream/README.md:4242` | `Sequencer`' M3
run_both M3-line-oor "$T" "cited line beyond EOF (README.md:4242) in sequencer.md"

# ============ M4 header path: `**Vendored at:**` target ===================
T=$(mkvariant M4-vendored-at) || exit 1
edit_file "$T" "$SUB_REL/executability/blueprints.md" \
  '**Vendored at:** `corpus/knowledge/unreal-mcp/upstream/`' \
  '**Vendored at:** `corpus/knowledge/unreal-mcp/upstreme/`' M4
run_both M4-vendored-at "$T" "Vendored-at header path corrupted in blueprints.md"

# ============ M5 label token flip ========================================
T=$(mkvariant M5-label) || exit 1
edit_file "$T" "$SUB_REL/executability/materials.md" \
  '**Label:** `static-only`' '**Label:** `verified-here`' M5
run_both M5-label "$T" "label token flipped static-only -> verified-here in materials.md"

# ============ M6 backtick repo-relative path (nested prefix) ==============
T=$(mkvariant M6-relpath) || exit 1
edit_file "$T" "$SUB_REL/executability/meshes-textures.md" \
  '`corpus/knowledge/unreal-mcp/executability/blueprints.md`' \
  '`corpus/knowledge/unreal-mcp/executability/blueprints-typo.md`' M6
run_both M6-relpath "$T" "backticked repo-relative path corrupted in meshes-textures.md"

# ============ M7 backticked path:line, line out of range ==================
# Targets the `path:line` form the gate's backtick sweep strips via `sed 's/:[0-9]\+$//'`.
# Two SEPARATE variants: edit_file() always rewrites from the pristine source, so
# two sequential edits to one file would silently discard the first (observed once).
# M7a changes only the line of an existing citation; M7b appends a line to a path
# that previously carried none.
T=$(mkvariant M7a-relpath-line) || exit 1
edit_file "$T" "$SUB_REL/executability/meshes-textures.md" \
  '`corpus/knowledge/unreal-mcp/README.md:213-227`' \
  '`corpus/knowledge/unreal-mcp/README.md:9999`' M7a
run_both M7a-relpath-line "$T" "backticked repo-relative path:line out of range (README.md:9999, max 278)"

T=$(mkvariant M7b-relpath-line) || exit 1
edit_file "$T" "$SUB_REL/executability/meshes-textures.md" \
  '`corpus/knowledge/unreal-mcp/executability/blueprints.md`' \
  '`corpus/knowledge/unreal-mcp/executability/blueprints.md:5000`' M7b
run_both M7b-relpath-line "$T" "backticked repo-relative path:line out of range (blueprints.md:5000, max 155)"

# ============ M8 upstream/<path>:<line> WITHOUT backticks =================
# The gate's CHECK 4 upstream-pointer regex requires a BACKTICK immediately before
# `upstream/` (`[^`"|)]+` cannot cross one), so a bare in-table citation may be
# invisible to it. This variant measures exactly that blind spot.
T=$(mkvariant M8-bare-ptr) || exit 1
edit_file "$T" "$SUB_REL/executability/sequencer.md" \
  '| 2 | `upstream/README.md:106` | `Sequencer` | the **only capability sentence** (§3.1) |' \
  '| 2 | upstream/README.md:4242 | `Sequencer` | the **only capability sentence** (§3.1) |' M8
run_both M8-bare-ptr "$T" "bare (un-backticked) upstream/<path>:<line> out of range in sequencer.md"

# ============ post-run: the staged source must still be pristine ==========
# Strongest available statement: every file in the staged copy still hashes equal
# to the live lane tree, i.e. no mutation wrote through a hardlink.
printf '=== post-run source integrity (staged copy vs live lane) ===\n' >> "$OUT/matrix.txt"
LIVE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
SAME=0; DIFF=0
while IFS= read -r rel; do
  a=$(sha256sum "$LANE/$rel" | cut -d' ' -f1)
  b=$(sha256sum "$LIVE/$rel" 2>/dev/null | cut -d' ' -f1)
  if [ "$a" = "$b" ]; then SAME=$((SAME+1)); else DIFF=$((DIFF+1)); printf '  DIFF %s\n' "$rel" >> "$OUT/matrix.txt"; fi
done < <(cd "$LANE" && find corpus/knowledge/unreal-mcp -type f | sort)
printf '  STAGED_SOURCE_IDENTICAL=%s DIFFERENT=%s\n' "$SAME" "$DIFF" >> "$OUT/matrix.txt"
printf 'MATRIX WRITTEN %s\n' "$OUT/matrix.txt"
