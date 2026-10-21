# adv1-patch-E.py — assert the manifest-file COUNT against the pinned 12.
#
# The gate prints MANIFEST_FILES but never compares it, so deleting a seat shard
# (12 -> 11) leaves the strict sweep green over a smaller glob. Comparing the
# count closes the set-identity half of the r102 F5 class.
import sys

src, dst = sys.argv[1], sys.argv[2]
s = open(src).read()
old = """printf 'MANIFEST_FILES=%s\\n' "$MANIFEST_COUNT"
"""
new = """printf 'MANIFEST_FILES=%s\\n' "$MANIFEST_COUNT"
if [ "$MANIFEST_COUNT" -ne 12 ]; then
  printf 'FAIL manifest-file count %s != pinned 12\\n' "$MANIFEST_COUNT"; FAILS=$((FAILS+1))
fi
"""
assert old in s, "MANIFEST_FILES print line not found"
s = s.replace(old, new, 1)
open(dst, "w").write(s)
print("patch E applied")
