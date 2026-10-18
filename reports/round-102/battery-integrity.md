# r102 SEAT-33 BATTERY-INTEGRITY — byte-stability proof for the round

Runtime: 2026-10-18T17:41:15Z · HEAD `2c99b7b8155841617d844c609813afcba77aa207`
Seat scope: proof only. No file outside this report was written by SEAT-33.

## Claim

Zero bytes of `corpus/fixtures/` changed during round 102, and the 350 `CASES` rows
in `corpus/fixtures/run_battery.py` still AST-parse — in both the worktree and the
committed HEAD blob.

## 1. Working-tree diff vs HEAD over the fixtures tree

```
$ git diff --stat HEAD -- corpus/fixtures/
$ git status --porcelain -- corpus/fixtures/
$ echo $?
0
```

Both commands produced **empty output** (no rows) and exit 0. For contrast, the same
commands over the whole repo:

```
$ git diff --stat HEAD
 corpus/artifacts/unreal-r22/README.md | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

$ git status --porcelain
 M corpus/artifacts/unreal-r22/README.md
?? reports/round-102/
```

The only round-102 working-tree mutation is the SEAT-owned F8 wording fold in
`corpus/artifacts/unreal-r22/README.md` (2 lines) plus the untracked new round
directory `reports/round-102/`. `corpus/fixtures/` appears in neither list.

## 2. Per-file byte proof (not just stat/mtime)

`git status` can in principle miss a same-size same-mtime rewrite; this compares the
actual blob object id of every tracked fixture file on disk against its HEAD entry.

```
$ python3 - <<'EOF'
import subprocess
paths = subprocess.run(['git','ls-tree','-r','HEAD','--name-only','corpus/fixtures/'],
                       capture_output=True,text=True).stdout.split()
mismatch=[]
for p in paths:
    cur = subprocess.run(['git','hash-object',p],capture_output=True,text=True).stdout.strip()
    head = subprocess.run(['git','rev-parse','HEAD:'+p],capture_output=True,text=True).stdout.strip()
    if cur!=head: mismatch.append((p,cur,head))
print("tracked fixture files:",len(paths))
print("byte-mismatch vs HEAD:",len(mismatch))
EOF
tracked fixture files: 146
byte-mismatch vs HEAD: 0
```

Aggregate digest over the same path set, computed two independent ways:

```
$ git ls-files -s corpus/fixtures | awk '{print $2"  "$4}' | sort | sha256sum
827af6c35233bc520d5a797dd650a777df1f18ab9fca9652e5fab0b1e539096d  -
$ git ls-tree -r HEAD corpus/fixtures | awk '{print $3"  "$4}' | sort | sha256sum
827af6c35233bc520d5a797dd650a777df1f18ab9fca9652e5fab0b1e539096d  -
$ git rev-parse HEAD:corpus/fixtures
4ebcc2db628de576904fe54ae1d8037d499b19c1
```

Index-side and HEAD-side aggregates are identical, so even the staged index is
untouched.

Untracked/ignored audit (a round seat could otherwise smuggle new bytes in):

```
$ git status --porcelain --untracked-files=all -- corpus/fixtures/ | wc -l
0
$ git status --porcelain --ignored -- corpus/fixtures/ | head -1
!! corpus/fixtures/three/node_modules/
```

Zero untracked non-ignored files; the only ignored tree is the pre-existing
`three/node_modules/` dependency checkout (1410 files on disk vs 146 tracked).

## 3. `run_battery.py` identity

```
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
$ git hash-object corpus/fixtures/run_battery.py
dd2d9b74448afddb88dcf2da56008302eba8060d
$ git rev-parse HEAD:corpus/fixtures/run_battery.py
dd2d9b74448afddb88dcf2da56008302eba8060d
```

Worktree file == HEAD blob (`dd2d9b74…`). The sha256 `f456bd00a1f7…` agrees with the
C2 claim's corrected value (F3 repair target), i.e. the live file matches the repair
text, not the stale `a065a56d…` citation.

## 4. 350 CASES rows still AST-parse

Worktree parse:

```
$ python3 - <<'EOF'
import ast
tree = ast.parse(open('corpus/fixtures/run_battery.py').read())
cases = [n.value for n in tree.body
         if isinstance(n,ast.Assign) and any(getattr(t,'id',None)=='CASES' for t in n.targets)][0]
rows = ast.literal_eval(cases)
print("AST parse: OK")
print("CASES node type:", type(cases).__name__)
print("CASES rows:", len(rows))
print("all rows are tuples:", all(isinstance(r, tuple) for r in rows))
EOF
AST parse: OK
CASES node type: List
CASES rows: 350
all rows are tuples: True
```

HEAD-blob parse (proves the committed bytes parse, not just the checkout):

```
$ python3 - <<'EOF'
import ast, subprocess, hashlib
blob = subprocess.run(['git','show','HEAD:corpus/fixtures/run_battery.py'],capture_output=True).stdout
print("HEAD blob bytes:", len(blob), "sha256:", hashlib.sha256(blob).hexdigest())
tree = ast.parse(blob.decode())
cases = [ast.literal_eval(n.value) for n in tree.body
         if isinstance(n,ast.Assign) and any(getattr(t,'id',None)=='CASES' for t in n.targets)][0]
print("HEAD CASES rows:", len(cases))
print("worktree bytes == HEAD bytes:", open('corpus/fixtures/run_battery.py','rb').read() == blob)
EOF
HEAD blob bytes: 346248 sha256: f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f
HEAD CASES rows: 350
worktree bytes == HEAD bytes: True
```

`python3 -m py_compile corpus/fixtures/run_battery.py` → `py_compile OK` (exit 0).

Row-shape audit of all 350 rows (confirms no row was truncated or reordered):

```
rows: 350
field-width histogram: {5: 350}
unique names: 350 dupes: []
exit codes: {0: 291, 2: 59}
rows whose fixture file is missing on disk: 0 []
rows with non-list argv: []
rows with empty expected stdout: []
```

## Verdict

| Check | Result |
|---|---|
| `git diff --stat HEAD -- corpus/fixtures/` | empty (0 files, 0 insertions/deletions) |
| `git status --porcelain -- corpus/fixtures/` | empty, exit 0 |
| 146 tracked fixture files blob-id vs HEAD | 0 mismatches |
| index vs HEAD aggregate sha256 over fixture paths | equal (`827af6c3…`) |
| untracked non-ignored files under fixtures | 0 |
| `run_battery.py` worktree vs HEAD blob | identical (`dd2d9b74…`, sha256 `f456bd00…`) |
| CASES rows, worktree and HEAD blob | 350 / 350, all 5-field tuples |
| CASES AST parse | OK both sides |

Battery bytes are byte-stable across round 102; the round's only fixtures-tree
interaction was read-only. No blocker.

Caveat: this is a byte/AST-integrity proof only. No battery *execution* was run in
this seat (no Godot binary invocation), so it asserts nothing about runtime pass/fail
of the 350 rows — only that the inputs are unmodified and structurally intact.
