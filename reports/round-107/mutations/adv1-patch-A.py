# adv1-patch-A.py — cross-check the gate's PIN constant against PROVENANCE.md.
#
# The gate's only pin source is its own PIN constant, so a tree vendored from a
# different commit (or a PROVENANCE.md whose declared pin has drifted) is
# self-consistent and green. Reading the declared pin out of PROVENANCE.md and
# comparing it to PIN closes classes A and C1.
#
# The extraction deliberately uses `grep -oE '[0-9a-f]{40}'` rather than a
# backtick-delimited sed expression: written into a shell script, a bare
# backtick inside a double-quoted string is command substitution.
import sys

src, dst = sys.argv[1], sys.argv[2]
s = open(src).read()
old = "FAILS=0\n"
new = """FAILS=0
DECL=$(grep -m1 '| pinned commit |' "$SUB/PROVENANCE.md" 2>/dev/null | grep -oE '[0-9a-f]{40}' | head -1)
if [ -z "$DECL" ]; then
  printf 'FAIL PROVENANCE.md declares no pinned commit\\n'; FAILS=$((FAILS+1))
elif [ "$DECL" != "$PIN" ]; then
  printf 'FAIL declared pin %s != gate PIN %s\\n' "$DECL" "$PIN"; FAILS=$((FAILS+1))
else
  printf 'PIN_DECLARED=OK %s\\n' "$DECL"
fi
"""
assert old in s, "FAILS=0 line not found"
s = s.replace(old, new, 1)
open(dst, "w").write(s)
print("patch A applied")
