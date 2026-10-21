#!/usr/bin/env bash
# r107 MUT-PIN — negative control for the round's 3-way byte verification.
#
# Question this answers: does the verification protocol actually DETECT a single
# flipped bit in one tracked file, or does it pass vacuously?
#
# Method (paired control, same script both ways):
#   * stage a pristine copy of the vendored tree  -> every leg must PASS
#   * stage the same copy with ONE bit flipped in ONE tracked file
#                                                 -> every leg must FAIL
# A control that cannot pass clean proves nothing; a control that cannot fail
# dirty proves nothing. Both runs are printed.
#
# Legs (four independent detection surfaces, all fed by the same staged tree):
#   L0 manifest   sha256sum -c against a reference manifest pinned from the
#                 pristine staged tree (this is the shape of .manifest.d/*.sha256)
#   LA clone      vs a fresh `git clone` (https smart transport)      -> transport A
#   LB tarball    vs a codeload tarball extract (no git protocol)     -> transport B
#   LC rest       vs GitHub REST `git/trees` + `git/blobs` (base64)   -> transport C
#
# Writes only under $SCRATCH (/var/tmp/r107-mut-pin). Never writes corpus/.
# Read-only over corpus/knowledge/unreal-mcp/.
set -u

REPO=EpicGames/unreal-engine-skills-for-claude-code-plugin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
LANE_ROOT=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
SRC=$LANE_ROOT/corpus/knowledge/unreal-mcp/upstream
SCRATCH=${SCRATCH:-/var/tmp/r107-mut-pin}
CLEAN=$SCRATCH/tree-clean
MUT=$SCRATCH/tree-mut
REF=$SCRATCH/ref-clone
TARX=$SCRATCH/tarx
TARGET_REL=skills/unreal-mcp/SKILL.md          # tracked, text, deterministic byte
NEEDLE='Project skills'                        # unique in this file [checked below]

mkdir -p "$SCRATCH"
FAILS=0
note() { printf '%s\n' "$*"; }
ok()   { printf 'PASS  %s\n' "$*"; }
bad()  { printf 'FAIL  %s\n' "$*"; FAILS=$((FAILS+1)); }

# ---------------------------------------------------------------- 0. provision
# Three transports provisioned independently of each other. Each is fetched once
# and reused for both the clean and the mutated run, so the two runs differ in
# exactly one respect: the staged bytes.
note "== provisioning transports into $SCRATCH =="
if [ ! -d "$REF/.git" ]; then
  git clone --quiet "https://github.com/$REPO" "$REF" || { bad "clone transport A"; exit 3; }
fi
A_PIN=$(git -C "$REF" rev-parse HEAD)
[ "$A_PIN" = "$PIN" ] && ok "LA clone HEAD = $A_PIN" || bad "LA clone HEAD $A_PIN != pin"

if [ ! -d "$TARX" ]; then
  mkdir -p "$TARX"
  curl -sSL -o "$SCRATCH/pin.tar.gz" "https://codeload.github.com/$REPO/tar.gz/$PIN" \
    && tar -xzf "$SCRATCH/pin.tar.gz" -C "$TARX" || { bad "codeload transport B"; exit 3; }
fi
B_DIR=$(find "$TARX" -maxdepth 1 -type d -name 'unreal-engine-skills-*' | head -1)
[ -n "$B_DIR" ] && ok "LB tarball root $(basename "$B_DIR")" || bad "LB tarball missing"

# Transport C: REST tree + blobs, decoded from base64 by this script.
gh api "repos/$REPO/git/trees/$PIN?recursive=1" \
  --jq '.tree[] | select(.type=="blob") | "\(.path)\t\(.sha)\t\(.size)"' \
  | sort > "$SCRATCH/c-tree.tsv"
: > "$SCRATCH/c-rest.txt"
while IFS=$'\t' read -r p s sz; do
  h=$(gh api "repos/$REPO/git/blobs/$s" --jq '.content' | tr -d '\n' | base64 -d | sha256sum | cut -d' ' -f1)
  printf '%s  %s\n' "$h" "$p" >> "$SCRATCH/c-rest.txt"
done < "$SCRATCH/c-tree.tsv"
[ "$(wc -l < "$SCRATCH/c-rest.txt")" -eq 12 ] \
  && ok "LC REST blob rows = 12" || bad "LC REST blob rows != 12"

# ------------------------------------------------------------ 1. stage copies
rm -rf "$CLEAN" "$MUT"
mkdir -p "$CLEAN" "$MUT"
cp -a "$SRC/." "$CLEAN/"
cp -a "$SRC/." "$MUT/"

# Reference manifest, derived from the PRISTINE staged copy (never from corpus/,
# never from a sibling seat's file) — this is the pinned manifest a verifier holds.
( cd "$CLEAN" && find . -type f | sed 's|^\./||' | sort | xargs sha256sum ) > "$SCRATCH/mut-ref.sha256"

# ------------------------------------------------------------- 2. the mutation
# Locate the needle, assert it is unique, flip exactly one bit (bit 5 of 'P').
OFF=$(python3 - "$MUT/$TARGET_REL" "$NEEDLE" <<'PY'
import sys
b=open(sys.argv[1],'rb').read(); n=sys.argv[2].encode()
print(b.count(n), b.find(n))
PY
)
COUNT=${OFF%% *}; POS=${OFF##* }
[ "$COUNT" = "1" ] && ok "needle '$NEEDLE' unique in $TARGET_REL (offset $POS)" \
                   || bad "needle occurrences=$COUNT (mutation target ambiguous)"

BEFORE_SHA=$(sha256sum "$MUT/$TARGET_REL" | cut -d' ' -f1)
BEFORE_SZ=$(wc -c < "$MUT/$TARGET_REL")
python3 - "$MUT/$TARGET_REL" "$POS" <<'PY'
import sys
p,o=sys.argv[1],int(sys.argv[2])
b=bytearray(open(p,'rb').read()); b[o]^=0x20      # one bit: 0x50 'P' -> 0x70 'p'
open(p,'wb').write(bytes(b))
PY
AFTER_SHA=$(sha256sum "$MUT/$TARGET_REL" | cut -d' ' -f1)
AFTER_SZ=$(wc -c < "$MUT/$TARGET_REL")
DIFFBYTES=$(cmp -l "$CLEAN/$TARGET_REL" "$MUT/$TARGET_REL" | wc -l)

note "== mutation evidence =="
note "target      : $TARGET_REL"
note "byte offset : $POS  (0-based)"
note "before      : $BEFORE_SHA  ${BEFORE_SZ}B"
note "after       : $AFTER_SHA  ${AFTER_SZ}B"
note "cmp -l      : $(cmp -l "$CLEAN/$TARGET_REL" "$MUT/$TARGET_REL")"
[ "$BEFORE_SHA" != "$AFTER_SHA" ] && [ "$BEFORE_SZ" = "$AFTER_SZ" ] && [ "$DIFFBYTES" -eq 1 ] \
  && ok "mutation landed: 1 differing byte, size unchanged" \
  || bad "mutation did not land cleanly"
# Prove the mutation is invisible to a size-only and a count-only verifier:
SZONLY=$(cmp -s <(wc -c < "$CLEAN/$TARGET_REL") <(wc -c < "$MUT/$TARGET_REL") && echo same || echo differ)
CNTONLY=$(diff -rq "$CLEAN" "$MUT" >/dev/null 2>&1 && echo same || echo differ)
note "size-only verifier   : $SZONLY   [I] blind to this mutation"
note "tree-diff verifier   : $CNTONLY [I] catches it (names the path)"
note "manifest self-check  : (re-derived from the same tree) would PASS on the mutant [I] —"
note "                       hence the reference manifest must be pinned independently"

# ------------------------------------------------------- 3. four detection legs
# Each leg returns 0 iff the staged tree matches the pinned upstream bytes.
leg_manifest() { local T=$1; ( cd "$T" && sha256sum --strict -c "$SCRATCH/mut-ref.sha256" ) >"$SCRATCH/l0.log" 2>&1; }
leg_clone()    { local T=$1 n=0; while IFS= read -r f; do
                   a=$(sha256sum "$T/$f" | cut -d' ' -f1); b=$(sha256sum "$REF/$f" | cut -d' ' -f1)
                   [ "$a" = "$b" ] || n=$((n+1)); done < "$SCRATCH/files.txt"; [ "$n" -eq 0 ]; }
leg_tar()      { local T=$1 n=0; while IFS= read -r f; do
                   a=$(sha256sum "$T/$f" | cut -d' ' -f1); b=$(sha256sum "$B_DIR/$f" | cut -d' ' -f1)
                   [ "$a" = "$b" ] || n=$((n+1)); done < "$SCRATCH/files.txt"; [ "$n" -eq 0 ]; }
leg_rest()     { local T=$1 n=0; while read -r h p; do
                   a=$(sha256sum "$T/$p" | cut -d' ' -f1); [ "$a" = "$h" ] || n=$((n+1))
                 done < "$SCRATCH/c-rest.txt"; [ "$n" -eq 0 ]; }
# Files list = the 12 tracked paths, taken from transport A's index (not from the
# staged tree), so a deleted/added staged file also counts as a mismatch.
git -C "$REF" ls-files | sort > "$SCRATCH/files.txt"

run_all() {
  local T=$1 label=$2 pass=0
  printf '\n--- %s ---\n' "$label"
  for leg in manifest clone tar rest; do
    if "leg_$leg" "$T"; then printf '  %-9s PASS\n' "$leg"; pass=$((pass+1))
    else printf '  %-9s FAIL\n' "$leg"; fi
  done
  printf '  %s\n' "$pass/4 legs pass"
  [ "$pass" -eq 4 ]
}

note ""
if run_all "$CLEAN" "CLEAN staged tree (baseline — must be 4/4 PASS)"; then
  ok "baseline: unmutated tree passes every leg"
else
  bad "baseline: unmutated tree FAILED a leg — the control is not usable"
fi

if run_all "$MUT" "MUTATED staged tree (must be 0/4 PASS)"; then
  bad "mutated tree passed every leg — verification is VACUOUS for this mutation"
else
  ok "mutated tree rejected by every leg"
fi

printf '\n== MUT-PIN verdict: FAILS=%s (0 = control valid) ==\n' "$FAILS"
[ "$FAILS" -eq 0 ] || exit 1
exit 0
