#!/usr/bin/env bash
# r107 VERIFY-2 transport C: GitHub REST git/blobs (base64) -> sha256 of decoded bytes
# Independent of any local git object store or working tree.
set -u
REPO=EpicGames/unreal-engine-skills-for-claude-code-plugin
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
OUT=${1:-/var/tmp/r107-verify2/c-rest.txt}
: > "$OUT"
# path<TAB>blobsha pairs taken from the REST tree listing (fetched live here)
gh api "repos/$REPO/git/trees/$PIN?recursive=1" \
  --jq '.tree[] | select(.type=="blob") | "\(.path)\t\(.sha)\t\(.size)"' \
  | sort > /var/tmp/r107-verify2/c-tree.tsv
while IFS=$'\t' read -r path sha size; do
  got=$(gh api "repos/$REPO/git/blobs/$sha" --jq '.content' | tr -d '\n' | base64 -d | sha256sum | cut -d' ' -f1)
  nbytes=$(gh api "repos/$REPO/git/blobs/$sha" --jq '.size')
  printf '%s  %s  rest_size=%s declared_size=%s\n' "$got" "$path" "$nbytes" "$size" >> "$OUT"
done < /var/tmp/r107-verify2/c-tree.tsv
cat "$OUT"
echo "rows=$(wc -l < "$OUT")"
