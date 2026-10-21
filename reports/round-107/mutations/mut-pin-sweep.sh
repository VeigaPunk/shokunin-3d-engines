#!/usr/bin/env bash
# r107 MUT-PIN SWEEP — mutation classes beyond the single canonical byte flip.
#
# mut-pin.sh proves the control is non-vacuous for ONE bit in ONE file. This
# script widens the claim: which mutation CLASSES are caught by which detection
# leg, and which are structurally invisible to a given leg.
#
# Legs (same definitions as mut-pin.sh, plus one demonstrator):
#   manifest  sha256sum -c <pinned reference manifest>
#   clone     per-path sha256 vs fresh `git clone`      (transport A)
#   tar       per-path sha256 vs codeload tarball       (transport B)
#   rest      per-path sha256 vs REST git/blobs base64  (transport C)
#   multiset  sorted-list-of-content-hashes comparison  (a NON-path-aware
#             verifier, included only to show it is blind to M6)
#
# Reuses the transports provisioned by mut-pin.sh under $SCRATCH.
# Writes only under $SCRATCH. Never writes corpus/.
set -u

REPO=EpicGames/unreal-engine-skills-for-claude-code-plugin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
SCRATCH=${SCRATCH:-/var/tmp/r107-mut-pin}
CLEAN=$SCRATCH/sweep-clean
MUT=$SCRATCH/sweep-mut
REF=$SCRATCH/ref-clone
TARX=$SCRATCH/tarx
B_DIR=$(find "$TARX" -maxdepth 1 -type d -name 'unreal-engine-skills-*' | head -1)

for p in "$REF/.git" "$B_DIR" "$SCRATCH/c-rest.txt"; do
  [ -e "$p" ] || { printf 'missing prerequisite %s — run mut-pin.sh first\n' "$p"; exit 3; }
done

git -C "$REF" ls-files | sort > "$SCRATCH/files.txt"
mapfile -t PATHS < "$SCRATCH/files.txt"

stage() {  # stage clean copy, then apply the class mutation via $1
  rm -rf "$CLEAN" "$MUT"; mkdir -p "$CLEAN" "$MUT"
  cp -a /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/upstream/. "$CLEAN/"
  cp -a "$CLEAN/." "$MUT/"
  ( cd "$CLEAN" && find . -type f | sed 's|^\./||' | sort | xargs sha256sum ) > "$SCRATCH/sweep-ref.sha256"
  "$1"
}

# ------------------------------------------------------------------- classes
m_bitsweep() {  # M1: one bit flipped in EACH tracked file in turn
  for f in "${PATHS[@]}"; do
    cp -a "$CLEAN/." "$MUT/"
    python3 - "$MUT/$f" <<'PY'
import sys
p=sys.argv[1]; b=bytearray(open(p,'rb').read())
o=len(b)//2
b[o]^=0x01
open(p,'wb').write(bytes(b))
PY
    ROW="M1 bit-flip in $f"
    run_row "$ROW"
  done
  CLASS_DONE=1
}
m_truncate() { local f=skills/unreal-mcp/references/setup.md
  python3 -c "import sys;p=sys.argv[1];d=open(p,'rb').read();open(p,'wb').write(d[:-1])" "$MUT/$f"
  run_row "M2 truncate 1 byte ($f)"; }
m_append()   { printf 'x' >> "$MUT/LICENSE"; run_row "M3 append 1 byte (LICENSE)"; }
m_selfman()  { # M4: mutate the tree AND regenerate the manifest from the mutant
  local f=README.md
  python3 -c "import sys;p=sys.argv[1];b=bytearray(open(p,'rb').read());b[len(b)//2]^=0x01;open(p,'wb').write(bytes(b))" "$MUT/$f"
  ( cd "$MUT" && find . -type f | sed 's|^\./||' | sort | xargs sha256sum ) > "$SCRATCH/sweep-ref.sha256"
  run_row "M4 self-consistent manifest (tree+manifest agree)"; }
m_extra()    { printf 'planted\n' > "$MUT/skills/unreal-mcp/PLANTED.md"
  run_row "M5 extra file added (not in pin)"; }
m_delete()   { rm -f "$MUT/CODEOWNERS"; run_row "M5b tracked file deleted"; }
m_swap()     { # M6: exchange the bytes of two files — same content multiset, wrong paths
  local a=.claude-plugin/plugin.json b=CODEOWNERS
  cp "$CLEAN/$a" "$SCRATCH/x1"; cp "$CLEAN/$b" "$SCRATCH/x2"
  cp "$SCRATCH/x2" "$MUT/$a"; cp "$SCRATCH/x1" "$MUT/$b"
  run_row "M6 content swap between two paths"; }

# ---------------------------------------------------------------------- legs
leg_manifest() { local T=$1; ( cd "$T" && sha256sum --strict -c "$SCRATCH/sweep-ref.sha256" ) >/dev/null 2>&1; }
paths_of()     { ( cd "$1" && find . -type f | sed 's|^\./||' | sort ); }
leg_clone()    { local T=$1; diff -q <(paths_of "$T") "$SCRATCH/files.txt" >/dev/null || return 1
                 while IFS= read -r f; do
                   [ "$(sha256sum "$T/$f" | cut -d' ' -f1)" = "$(sha256sum "$REF/$f" | cut -d' ' -f1)" ] || return 1
                 done < "$SCRATCH/files.txt"; }
leg_tar()      { local T=$1; diff -q <(paths_of "$T") "$SCRATCH/files.txt" >/dev/null || return 1
                 while IFS= read -r f; do
                   [ "$(sha256sum "$T/$f" | cut -d' ' -f1)" = "$(sha256sum "$B_DIR/$f" | cut -d' ' -f1)" ] || return 1
                 done < "$SCRATCH/files.txt"; }
leg_rest()     { local T=$1; diff -q <(paths_of "$T") <(cut -f2 "$SCRATCH/c-rest.txt" | sort) >/dev/null || return 1
                 while read -r h p; do
                   [ "$(sha256sum "$T/$p" | cut -d' ' -f1)" = "$h" ] || return 1
                 done < "$SCRATCH/c-rest.txt"; }
leg_multiset() { local T=$1; diff -q \
                   <( cd "$T" && find . -type f -exec sha256sum {} + | awk '{print $1}' | sort ) \
                   <( cd "$CLEAN" && find . -type f -exec sha256sum {} + | awk '{print $1}' | sort ) >/dev/null; }

declare -a TABLE
run_row() {
  local label=$1 r=""
  for leg in manifest clone tar rest multiset; do
    if "leg_$leg" "$MUT"; then r="$r  ."; else r="$r  X"; fi   # X = detected
  done
  printf '%-58s |%s\n' "$label" "$r"
  TABLE+=("$label|$r")
}

printf '%-58s |  man  cln  tar  rst  mset   (X = mutation DETECTED)\n' "mutation class"
printf '%s\n' "-------------------------------------------------------------------------"
stage m_bitsweep
stage m_truncate
stage m_append
stage m_selfman
stage m_extra
stage m_delete
stage m_swap

printf '\n== sweep verdict ==\n'
transport_blind=0      # rows where a transport leg (clone/tar/rest) missed
manifest_blind=0      # rows where the manifest leg missed
multiset_blind=0      # rows where the non-path-aware multiset leg missed
for row in "${TABLE[@]}"; do
  read -r m c t r s <<< "${row##*|}"
  [ "$c" = X ] && [ "$t" = X ] && [ "$r" = X ] || transport_blind=$((transport_blind+1))
  [ "$m" = X ] || manifest_blind=$((manifest_blind+1))
  [ "$s" = X ] || multiset_blind=$((multiset_blind+1))
done
printf 'rows=%s\n' "${#TABLE[@]}"
printf 'transport blind spots  (clone+tar+rest all failed to catch): %s  [want 0]\n' "$transport_blind"
printf 'manifest blind spots   (sha256sum -c against the pinned manifest missed): %s\n' "$manifest_blind"
printf 'multiset blind spots   (path-blind verifier missed): %s\n' "$multiset_blind"
printf 'CLAIM: no mutation class in this sweep escapes all three byte transports.\n'
[ "$transport_blind" -eq 0 ] || { printf 'REFUTED — a class escaped every transport.\n'; exit 1; }
printf 'CONFIRMED.\n'
# The two known manifest-only blind spots must be exactly the two predicted:
printf 'expected manifest blind spots: M4 (self-consistent manifest), M5 (extra file)\n'
[ "$manifest_blind" -eq 2 ] || { printf 'unexpected manifest blind-spot count %s\n' "$manifest_blind"; exit 1; }
printf 'expected multiset blind spot: M6 (content swap — same multiset, wrong paths)\n'
[ "$multiset_blind" -eq 1 ] || { printf 'unexpected multiset blind-spot count %s\n' "$multiset_blind"; exit 1; }
exit 0
