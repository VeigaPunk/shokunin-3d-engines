#!/usr/bin/env bash
# r107-REV-PIN — independent pin/verification re-derivation.
# Read-only against the vendored tree. Writes only under /var/tmp/r107-rev-pin/.
# Usage: bash reports/round-107/mutations/rev-pin.sh [REPO_ROOT]
set -uo pipefail

REPO_ROOT="${1:-/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin}"
VEND="$REPO_ROOT/corpus/knowledge/unreal-mcp"
SCRATCH=/var/tmp/r107-rev-pin
EXPECT_PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
EXPECT_TREE=b5b9624b00fc90217240e823406699d0ab78b959
URL=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
rc=0

mkdir -p "$SCRATCH"

echo "== Transport A: fresh git clone =="
rm -rf "$SCRATCH/fresh-clone"
git clone --quiet "$URL" "$SCRATCH/fresh-clone" || { echo "clone FAILED"; exit 1; }
pinA=$(git -C "$SCRATCH/fresh-clone" rev-parse HEAD)
treeA=$(git -C "$SCRATCH/fresh-clone" log -1 --format=%T)
echo "A pin=$pinA tree=$treeA"
[ "$pinA" = "$EXPECT_PIN" ] || { echo "A: pin MISMATCH"; rc=1; }
[ "$treeA" = "$EXPECT_TREE" ] || { echo "A: tree MISMATCH"; rc=1; }

echo "== Transport B: git ls-remote =="
pinB=$(git ls-remote "$URL" refs/heads/main | awk '{print $1}')
echo "B pin=$pinB"
[ "$pinB" = "$EXPECT_PIN" ] || { echo "B: pin MISMATCH"; rc=1; }

echo "== Transport C: codeload tarball at pin =="
rm -rf "$SCRATCH/tarx"; mkdir -p "$SCRATCH/tarx"
curl -sSL -o "$SCRATCH/pin.tar.gz" "https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/$EXPECT_PIN" \
  || { echo "C: fetch FAILED"; rc=1; }
tar xzf "$SCRATCH/pin.tar.gz" -C "$SCRATCH/tarx"
TARDIR="$SCRATCH/tarx/unreal-engine-skills-for-claude-code-plugin-$EXPECT_PIN"
[ -d "$TARDIR" ] || { echo "C: tarball dir name does not carry the pin"; rc=1; }

echo "== Tracked census at the pin (clone) =="
n=$(git -C "$SCRATCH/fresh-clone" ls-tree -r HEAD | wc -l)
echo "tracked=$n (expect 12)"
[ "$n" = "12" ] || rc=1
modes=$(git -C "$SCRATCH/fresh-clone" ls-tree -r HEAD | awk '{print $1}' | sort -u | tr '\n' ' ')
echo "modes=[$modes]"
[ "$modes" = "100644 " ] || { echo "non-100644 mode present"; rc=1; }

echo "== Three-way byte identity: tarball vs clone vs vendored upstream/ =="
git -C "$SCRATCH/fresh-clone" ls-tree -r --name-only HEAD | sort > "$SCRATCH/clone-list.txt"
while read -r p; do
  a=$(sha256sum "$TARDIR/$p" | cut -d' ' -f1)
  b=$(sha256sum "$SCRATCH/fresh-clone/$p" | cut -d' ' -f1)
  c=$(sha256sum "$VEND/upstream/$p" | cut -d' ' -f1)
  if [ "$a" = "$b" ] && [ "$b" = "$c" ]; then
    printf 'OK   %s\n' "$p"
  else
    printf 'DIFF %s\n  tar=%s\n  clone=%s\n  vend=%s\n' "$p" "$a" "$b" "$c"; rc=1
  fi
done < "$SCRATCH/clone-list.txt"

echo "== Both manifest families, read-only, from the vendored tree =="
( cd "$VEND" && sha256sum -c .manifest.d/audit-reference.sha256 ) || rc=1
( cd "$VEND" && sha256sum -c .manifest.d/seat*.sha256 ) || rc=1

echo "== git blob ids vs PROVENANCE §2 =="
git -C "$SCRATCH/fresh-clone" ls-tree -r HEAD | awk '{print substr($3,1,8)" "$4}' | sort -k2

echo
echo "VERDICT: $([ $rc -eq 0 ] && echo PASS || echo FAIL)"
exit $rc
