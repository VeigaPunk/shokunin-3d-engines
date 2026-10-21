# adv1-patch-H.py — make pass A's pointer pattern admit extensionless targets.
#
# The live regex requires a dot in the path segment (`\.`), so a pointer into
# upstream/LICENSE, upstream/CODEOWNERS or upstream/.gitignore is never matched
# and therefore never range-checked. Making the dot-and-extension group optional
# lets pass A see them.
#
# Behaviour-neutral on the current tree is a CLAIM, not an assumption: the
# verification script re-measures POINTERS on a clean mirror with this patch
# applied and requires it to stay 103.
import sys

src, dst = sys.argv[1], sys.argv[2]
s = open(src).read()
old = 'upstream/[^\\`\\"|)]+\\.[A-Za-z0-9]+:[0-9]+'
new = 'upstream/[^\\`\\"|)]+(\\.[A-Za-z0-9]+)?:[0-9]+'
assert old in s, "pass A regex not found"
s = s.replace(old, new)
open(dst, "w").write(s)
print("patch H applied")
