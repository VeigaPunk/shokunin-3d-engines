# B2 REPAIR-VERIFY — three

- **Seat:** SEAT-28 REPAIR-VERIFY-THREE · round 103 · lane `game-dev-3d-shokunin`
- **Owned path written:** `reports/round-103/b2/verify-three.md` (only). No tracked file was touched.
- **Repo HEAD at verification:** `c85a816` (`git log --oneline -1`)
- **Date:** 2026-10-18 (verification window `2026-10-18T18:33Z`–`18:37Z`)
- **Subject of verification:** `corpus/fixtures/three/README.md` — SEAT-25's in-place repair of the
  17 dead-root lines (the B2 class-B item routed in `reports/round-102/fold-spec.md:371-423`).
- **VERDICT: PASS — repair verified.** The diff is a pure prefix strip (17 removed / 17 added, zero
  non-command lines), every command in the file now exits `0` from the repo root, the fix reproduces
  on a pristine `git archive HEAD` tree, and the checker still fails when the seeds are perturbed.
  One **routed** residual is recorded in §7 (`scene_graph.mjs` header comment, not this seat's file).

---

## 1. Repair state at verification time

The repair is present in the **working tree, uncommitted** (`git status --porcelain` →
` M corpus/fixtures/three/README.md`). It landed during this seat's polling window (17 → 0 between
`18:33Z` and `18:36Z`). SEAT-22's ruling (`reports/round-103/b2/ruling.md`) was **not yet landed** at
my runtime (`ls reports/round-103/b2/` → `adversary.md`, `postgrep.md`, `repair-glb.md`,
`repair-three.md`, `verify-unity.md`), so this verification is against the tree, not against a landed
rationale. My seat's scope is independent re-run + diff-scope audit; I did not edit the README.

```
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ git status --porcelain | grep -v '^??'
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
```

Hash pair (HEAD blob → worktree blob), and the size change:

```
$ git show HEAD:corpus/fixtures/three/README.md | sha256sum
ebd2d97ef69d0a7c8668c869f1525a312f1fc2541cc30d51522adda0f052ee33  -
$ sha256sum corpus/fixtures/three/README.md
19ad2c8ce1e75efd98577c3267da8afcb3cc77e94f5e2f4415680ab693ca3d30  corpus/fixtures/three/README.md
$ git show HEAD:corpus/fixtures/three/README.md | wc -lc    →  153  8587
$ wc -lc corpus/fixtures/three/README.md                    →  153  8081
```

Line count unchanged (153 → 153); byte size 8587 → 8081 = **−506**. Arithmetic closes exactly: the
removed token is the 22-byte string `.shokunin/game-dev-3d/`, and it occurs **23** times at HEAD
(17 lines, some carrying two — e.g. the `--receipt` lines): `22 × 23 = 506` ✓.

```
$ git show HEAD:corpus/fixtures/three/README.md | grep -o "\.shokunin/game-dev-3d/" | wc -l   →  23
$ printf '%s' '.shokunin/game-dev-3d/' | wc -c                                               →  22
$ echo $((8587 - 8081))                                                                      →  506
```

## 2. BEFORE — the dead root, reproduced

Pre-repair, run verbatim from the repo root (the README's own declared framing is
*"From the repository root"*, `README.md:3`):

```
$ npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
npm error Run "npm help ci" for more info
npm ci dead-root exit=1
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
node dead-root exit=1
```

Both exit non-zero, matching `reports/round-102/fold-spec.md:381-382`'s recorded
`exit=1` for both. The count at HEAD:

```
$ git show HEAD:corpus/fixtures/three/README.md | grep -c "shokunin/game-dev-3d"
17
```

All 17 are command-bearing (fenced `sh` blocks or inline-code commands), **none** in narrative
prose — this is the class-B shape SEAT-11's F1 §5 R2/R3 permits a bounded in-place fix for:

```
$ python3 - (fence/inline classifier over HEAD blob)
   6 FENCE  npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
   7 FENCE  node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
   8 FENCE  node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs --receipt …
   9 FENCE  python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
  19 FENCE  node …/run_camera_cases.mjs
  20 FENCE  node …/run_camera_cases.mjs --receipt …
  41 FENCE  node …/run_ortho_cases.mjs
  42 FENCE  node …/run_ortho_cases.mjs --receipt …
  67 INLINE `node …/run_ortho_cases.mjs`
  78 FENCE  node …/run_ray_cases.mjs
  79 FENCE  node …/run_ray_cases.mjs --receipt …
  92 INLINE `node …/run_ray_cases.mjs`
 104 FENCE  node …/run_order_cases.mjs
 105 FENCE  node …/run_order_cases.mjs --receipt …
 119 INLINE `node …/run_order_cases.mjs`
 142 FENCE  node …/run_layer_cases.mjs
 143 FENCE  node …/run_layer_cases.mjs --receipt …
```

## 3. AFTER — every command in the file, re-run from the repo root

```
$ grep -c "shokunin/game-dev-3d" corpus/fixtures/three/README.md
0
$ npm ci --prefix corpus/fixtures/three
npm-ci exit=0
$ for c in run_cases run_camera_cases run_ortho_cases run_ray_cases run_order_cases run_layer_cases; do
>   out=$(node corpus/fixtures/three/$c.mjs 2>&1); echo "$c exit=$? | $(echo "$out"|tail -1)"; done
run_cases        exit=0 | PASS three battery: 3/3, seeds_unchanged=true
run_camera_cases exit=0 | PASS three camera battery: 5/5, seeds_unchanged=true
run_ortho_cases  exit=0 | PASS three ortho battery: 5/5, seeds_unchanged=true
run_ray_cases    exit=0 | PASS three ray battery: 5/5, seeds_unchanged=true
run_order_cases  exit=0 | PASS three order battery: 9/9, seeds_unchanged=true
run_layer_cases  exit=0 | PASS three layer battery: 4/4, seeds_unchanged=true
```

All six runners — every `node` line in the README, r6/r58/r60/r62/r63/r64/r65/r66/r67/r68 sections —
exit `0` with `seeds_unchanged=true`. `npm ci` (line 6) exits `0`.

**Receipt arm** (README line 8), the literal line piped straight to `bash` (not retyped):

```
$ sed -n '8p' corpus/fixtures/three/README.md
node corpus/fixtures/three/run_cases.mjs --receipt corpus/live/three-r6.json
$ sed -n '8p' corpus/fixtures/three/README.md | bash
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
paste-exit=0
```

The receipt target `corpus/live/` is **gitignored** (`corpus/.gitignore:1: live/`), so the write
touches no tracked path:

```
$ git check-ignore -v corpus/live/three-r6.json
corpus/.gitignore:1:live/	corpus/live/three-r6.json
```

## 4. Reproduction on a pristine export — the fix is self-contained

Method: `git archive HEAD` (no round-103 change in it), then copy in **only** the repaired README.
This proves the green exits come from the README fix and not from any sibling round-103 edit.

```
$ rm -rf /tmp/s28 && mkdir -p /tmp/s28 && git archive HEAD | tar -x -C /tmp/s28
$ cp corpus/fixtures/three/README.md /tmp/s28/corpus/fixtures/three/README.md
$ cd /tmp/s28
$ grep -c "shokunin/game-dev-3d" corpus/fixtures/three/README.md   →  0
$ npm ci --prefix corpus/fixtures/three                            →  exit=0
$ for c in run_cases run_camera_cases run_ortho_cases run_ray_cases run_order_cases run_layer_cases; do
>   out=$(node corpus/fixtures/three/$c.mjs 2>&1); echo "$c exit=$? | $(echo "$out"|tail -1)"; done
run_cases        exit=0 | PASS three battery: 3/3, seeds_unchanged=true
run_camera_cases exit=0 | PASS three camera battery: 5/5, seeds_unchanged=true
run_ortho_cases  exit=0 | PASS three ortho battery: 5/5, seeds_unchanged=true
run_ray_cases    exit=0 | PASS three ray battery: 5/5, seeds_unchanged=true
run_order_cases  exit=0 | PASS three order battery: 9/9, seeds_unchanged=true
run_layer_cases  exit=0 | PASS three layer battery: 4/4, seeds_unchanged=true
```

Six of six green on a tree containing **no other** round-103 modification.

## 5. Diff-scope audit — only the ruled lines changed

```
$ git diff --numstat -- corpus/fixtures/three/README.md
17	17	corpus/fixtures/three/README.md
$ git diff -U0 -- corpus/fixtures/three/README.md | grep -c '^-[^-]'   →  17
$ git diff -U0 -- corpus/fixtures/three/README.md | grep -c '^+[^+]'   →  17
```

**Pairing test** — strip the prefix from every `-` line and every `+` line; each must appear exactly
twice (once removed, once added). Non-zero output below would mean a line changed for any reason
other than the prefix:

```
$ git diff -U0 -- corpus/fixtures/three/README.md | grep -E '^[-+][^-+]' \
>   | sed 's|\.shokunin/game-dev-3d/||g' | sed 's/^-//;s/^+//' | sort | uniq -c | awk '$1!=2 {print "NOT-PAIRED:",$0}'
(no output)
```

Every removed line has an identical counterpart after prefix-strip → the mutation is **prefix-only**.

**Prose test** — no changed line is outside a command invocation:

```
$ git diff -U0 -- corpus/fixtures/three/README.md | grep -E '^[+-][^+-]' \
>   | grep -vE '(npm ci|node |python3 |uv run)'
(no output)
```

**Only the README changed in this directory** — the fixture sources, seeds and lockfile are
byte-identical to HEAD:

```
$ git diff --stat -- corpus/fixtures/three/
 corpus/fixtures/three/README.md | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

$ for f in scene_graph.mjs run_cases.mjs package.json package-lock.json; do
>   a=$(git show HEAD:corpus/fixtures/three/$f | sha256sum | cut -c1-16)
>   b=$(sha256sum corpus/fixtures/three/$f | cut -c1-16); echo "$f HEAD=$a work=$b $([ "$a" = "$b" ] && echo SAME || echo DIFF)"; done
scene_graph.mjs  HEAD=e4bb0a136391cb42 work=e4bb0a136391cb42 SAME
run_cases.mjs    HEAD=97eca1b2e26db106 work=97eca1b2e26db106 SAME
package.json     HEAD=799216c1e1574c14 work=799216c1e1574c14 SAME
package-lock.json HEAD=1a8e6ee2341eb4e3 work=1a8e6ee2341eb4e3 SAME
```

These four are exactly the runner's own `seedDigests` (`three-r6.json`), so the repair did not move
a hashed seed.

- **Class-B only.** All 17 changed lines are command lines (10 fenced-block + 3 inline in the
  README; the remaining 4 are the second line of each `--receipt` pair). Zero narrative lines.
- **Narrative preserved.** The r6/r58/r60/r62/r63/r64/r65/r66/r67/r68 scope disclaimers, the
  "no WebGL renderer", "no Unity/Unreal runtime inference" sentences, and every `--receipt` filename
  are byte-identical to HEAD.
- **Not byte-pinned.** `grep -rn "fixtures/three" corpus/knowledge/unreal-mcp/` → no hits; the file
  is outside the pinned subtree, so no manifest/gate obligation attaches to it.

## 6. Discriminating controls — the repair did not neuter the checker

A green exit is only evidence if the checker can still fail. Two targeted mutations on a scratch
copy (seeds perturbed, repo untouched):

```
$ cp -r corpus/fixtures/three /home/vgpnk/.s28m1      # M1: mutate the seed child Z (line 14)
$ sed -i '14s/: -3)/: -5)/' /home/vgpnk/.s28m1/scene_graph.mjs
$ (cd /home/vgpnk/.s28m1 && node run_cases.mjs); echo exit=$?
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
PASS mutation: exit=1 expected=1
M1 exit=1

$ cp -r corpus/fixtures/three /home/vgpnk/.s28m2      # M2: mutate the literal expectation (line 20)
$ sed -i '20s/\[-1, 0, 0\]/[-2, 0, 0]/' /home/vgpnk/.s28m2/scene_graph.mjs
$ (cd /home/vgpnk/.s28m2 && node run_cases.mjs); echo exit=$?
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=0 expected=1
M2 exit=1
```

Perturbing the geometric seed → `exit=1`; perturbing the hand-authored expectation → `exit=1`.
The checker discriminates, so the §3/§4 greens are load-bearing. The runner's own `--mutate-offset`
arm also still fires (`PASS mutation: exit=1 expected=1` inside every green run above).

**Battery subset** (README line 9), run from the repo root against a home-disk scratch:

```
$ timeout 100 python3 corpus/fixtures/run_battery.py --runs /home/vgpnk/.s28runs \
>   --only transform3d_compose,transform3d_compose_wrong_order,raycast3d_hit,raycast3d_miss
PASS  raycast3d_hit                    raycast3d.gd    -                0/0  ordinary
PASS  raycast3d_miss                   raycast3d.gd    --miss-ray       2/2  negative
PASS  transform3d_compose              …               -                0/0  ordinary
PASS  transform3d_compose_wrong_order  …               --wrong-order    2/2  negative
totals: cases=4 pass=4 fail=0 ordinary=2 negative_controls=2 probes=0
PASS battery: /home/vgpnk/.s28runs/20261018T183642535823Z/verdicts.json
battery-subset rc=0
```

`run_battery.py` from the repo root works on the repaired path (4/4, including both negative
controls). **Bounded limit, recorded:** the *full* 350-case sweep could not be completed in this
window — copying seeds to a tmpfs scratch failed with
`OSError: [Errno 122] Disk quota exceeded` (`/tmp` was 80% full, 3.1 G free; I did not delete other
seats' scratch). The subset run against a `/home` scratch (774 G free) is the substitute evidence.
This is a resource limit of the verification host, **not** a defect of the repair, and it is **not**
recorded as a pass of the full battery.

## 7. ROUTED (not mine to fix)

**(a) `corpus/fixtures/three/scene_graph.mjs` still carries 4 dead-root lines.** These are inside
the file's header *comment* (`// npm ci --prefix …` etc.), i.e. prose/comment context, not a runnable
command — class-A/C under SEAT-11 F1 §5 R2/R3, so they take a dated correction note rather than an
in-place rewrite, and the systemic scope is the L1's ruling:

```
$ grep -rln "shokunin/game-dev-3d" corpus/fixtures/three/
corpus/fixtures/three/scene_graph.mjs
$ grep -c "shokunin/game-dev-3d" corpus/fixtures/three/scene_graph.mjs
4
$ grep -n "shokunin/game-dev-3d" corpus/fixtures/three/scene_graph.mjs
2:// npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three
3:// npm test --prefix .shokunin/game-dev-3d/corpus/fixtures/three
4:// node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs --wrong-order
5:// node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs --mutate-offset
```

I did **not** touch it (not my seat's file, and the header comment is not a runnable surface — the
runner is invoked via the README, which is now correct).

**(b) No stale sibling citation of the old README sha.** Unlike the unity case, the superseded
`three/README.md` sha `ebd2d97e…` is cited nowhere in the tracked tree, so the repair creates no
dangling hash reference:

```
$ git grep -n "ebd2d97ef69d0a7c"        →  (no output)
$ git grep -n "19ad2c8ce1e75efd"        →  (no output)
```

**(c) The systemic 142-file scope** is the L1's ruling (SEAT-11 F1 §5 R4); this seat verifies only
the three-README instance. `reports/round-103/b2/postgrep.md` (SEAT-31) owns the final lane-wide
count.

## 8. Cross-check at verification time

- Sibling class-B repairs, at my runtime: `glb-r12/README.md` **0** (SEAT-23 landed),
  `unity-r19/README.md` **0** (SEAT-24 landed), `fixtures/three/README.md` **0** (SEAT-25 landed).
  All three of the B2 runnable READMEs are repaired and this seat independently confirms the third.
- No Unreal/Unity runtime claim is made here. Every green above exercises Node CPU math under the
  pinned three.js 0.186.1 package — no `WebGLRenderer`, no GL context, no pixels, no browser. The
  Unreal editor is not installed on this host and live MCP is unproven by construction; nothing in
  this report asserts otherwise.

## 9. Reproduce

```
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
git status --porcelain | grep -v '^??'                       # three README ' M'
git diff --numstat -- corpus/fixtures/three/README.md        # 17  17
grep -c "shokunin/game-dev-3d" corpus/fixtures/three/README.md   # 0
npm ci --prefix corpus/fixtures/three; echo "npm-ci exit=$?"     # 0
for c in run_cases run_camera_cases run_ortho_cases run_ray_cases run_order_cases run_layer_cases; do
  node corpus/fixtures/three/$c.mjs >/dev/null 2>&1; echo "$c exit=$?"; done   # all 0
sed -n '8p' corpus/fixtures/three/README.md | bash            # receipt arm, exit 0
```
