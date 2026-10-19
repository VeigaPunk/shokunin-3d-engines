# r106 SEAT-112 — Scent of stale

**Seat:** SEAT-112 SCENT-OF-STALE. Owned path: this file only. No corpus edit. No git commit, push, checkout, or reset.

**Axes:** coverage (line citations a path sweep marks resolved), depth (open the cited line and the commit where the citation was true), calibration (stale only when the line moved; a loose locator that was always loose is not a move).

**HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd`. Snapshot `2026-10-18T18:51:36-03:00`. Other seats were still writing. Not a close-time lock.

## Verdict

**SCENT CONFIRMED, bounded.** Opened 5 cited files. A path-resolution sweep passes all 5 (file exists, cited line ≤ `wc -l`). Standing line pointers are stale in **2/5** files and still say what they claim in **3/5**.

The miss class is insertion-above: later rows or flag parses were inserted above a symbol, so the old line number still exists and now names different text. Token-on-line: **9 hit / 5 miss** across 14 anchors in those 5 files. The 5 misses are the two stale files. This is not a census and not a battery failure.

Queued, not applied. Historical sentences stay. Dated notes only. Silent line-number swaps would erase receipts that were true on the day they were written.

## Method

A citation "resolves" here if `test -f` succeeds and the cited line number is ≤ the file's line count. That is the check a path sweep can pass while still landing on moved content. The content check is: the cited line contains the symbol or diagnostic the citation names. Where it misses, `git show <introducing-commit>:<path>` shows the same line used to contain that symbol.

Commands run from the lane root. Observed output is below, not reconstructed.

## 1. Path sweep would pass

`2026-10-18T18:48:42-03:00`:

```text
$ git rev-parse --short HEAD
0cc3f41
$ wc -l corpus/fixtures/run_battery.py corpus/fixtures/camera3d_ortho.gd \
        corpus/fixtures/camera3d_project.gd corpus/fixtures/body3d_slide.gd \
        corpus/fixtures/navagent3d_retarget.gd
  1387 corpus/fixtures/run_battery.py
   177 corpus/fixtures/camera3d_ortho.gd
   187 corpus/fixtures/camera3d_project.gd
   163 corpus/fixtures/body3d_slide.gd
    59 corpus/fixtures/navagent3d_retarget.gd
```

Every cited line in the table below is inside that range. `test -f` is true for all five. Full HEAD at `2026-10-18T18:51:36-03:00`: `0cc3f4162f8c319f8d01a69a174fe939f36701bd`.

## 2. The five files

| # | Cited from | File | Claimed line | Live line says | Class |
|---|---|---|---|---|---|
| 1 | `corpus/lessons/r1-headless-verification.md:41,51,126` | `corpus/fixtures/run_battery.py` | `:30` `CASES`, `:84` `MUTATION`, `:101` `seed_digests`, `:124` `classify` | `import time`; a detour case row; another detour case row; another detour case row | **STALE** |
| 2 | `corpus/lessons/r23-ortho-review.md:24` | `corpus/fixtures/camera3d_ortho.gd` | `_run` line 38 is `viewport/projection setting mismatch` | `var far_outside := "--far-boundary-outside" in OS.get_cmdline_user_args()` | **STALE** |
| 3 | `corpus/lessons/r1-headless-verification.md:89,90,100,113` | `corpus/fixtures/camera3d_project.gd` | `:51` `EXPECTED_SCREEN`, `:58` `FRUSTUM_EPSILON`, `:126` `_setup_intact`, `:145` `_behind_verdict` | those four symbols, same text as at r1 | **FRESH** |
| 4 | `corpus/lessons/r1-headless-verification.md:85,86,99` | `corpus/fixtures/body3d_slide.gd` | `:37` `EXPECTED_PLANE_Z`, `:118` `_contact_verdict`, `:139` `_far_verdict` | those three symbols, same text as at r1 | **FRESH** |
| 5 | `corpus/lessons/r52-final-review.md:34,35,38` | `corpus/fixtures/navagent3d_retarget.gd` | line 40 actor-endpoint mismatch; line 57 `push_error` inside `_fail` | both strings present | **FRESH** |

Token recount at `2026-10-18T18:51:36-03:00` (`token in splitlines()[line-1]`):

```text
MISS run_battery.py:30          CASES
MISS run_battery.py:84          MUTATION
MISS run_battery.py:101         def seed_digests
MISS run_battery.py:124         def classify
MISS camera3d_ortho.gd:38       viewport/projection setting mismatch
HIT  camera3d_project.gd:51     EXPECTED_SCREEN
HIT  camera3d_project.gd:58     FRUSTUM_EPSILON
HIT  camera3d_project.gd:126    _setup_intact
HIT  camera3d_project.gd:145    _behind_verdict
HIT  body3d_slide.gd:37         EXPECTED_PLANE_Z
HIT  body3d_slide.gd:118        _contact_verdict
HIT  body3d_slide.gd:139        _far_verdict
HIT  navagent3d_retarget.gd:40  agent-guided actor endpoint mismatch
HIT  navagent3d_retarget.gd:57  push_error("navagent3d_retarget: "
anchors=14 hit=9 miss=5
```

Where the moved symbols live now (same run, `startswith` scan):

```text
run_battery.py:39:   CASES = [
run_battery.py:923:  MUTATION = {
run_battery.py:940:  def seed_digests() -> dict:
run_battery.py:964:  def classify(stdout, stderr, code, error, expected_exit, marker):
camera3d_ortho.gd:54: return _fail("viewport/projection setting mismatch")
```

`run_battery.py` grew from 294 lines at r1 to 1387 now (`git show 82c21b4:corpus/fixtures/run_battery.py | wc -l` → 294; `wc -l` now → 1387). The functions did not get renamed. The case table was inserted above them.

### File 1 — was exact, then the table grew

`git show 82c21b4:corpus/fixtures/run_battery.py | nl -ba` (r1 commit `82c21b4`, `game-dev-3d r1: headless 3D battery`):

```text
    30	CASES = [
    84	MUTATION = {
   101	def seed_digests() -> dict:
   124	def classify(stdout, stderr, code, error, expected_exit, marker):
```

Those are the four symbols the lesson still names at those lines. Live lines 30/84/101/124 do not contain them (`git blame -L 30,30` → `fe39a09f` `import time`; `git blame -L 124,124` → `b41fb33b` `2026-10-13 23:08:37 -0300` a `navagent3d_detour_link_oneway_fwd` row).

The lesson sentences are current-tense sources, not a pasted backtrace: "Sources: `corpus/fixtures/run_battery.py:124` (`classify`)" and "(`run_battery.py:84`)" for the `Vector3(4.0, 4.0, 6.0)` mutation. A reader who opens those lines today does not find `classify` or `MUTATION`.

### File 2 — was the mismatch, then flag parses were inserted

At r23 commit `d5feae8` (`2026-10-13 02:42:16 -0300`, same commit as the lesson), `git show d5feae8:corpus/fixtures/camera3d_ortho.gd | nl -ba | sed -n '37,38p'`:

```text
    37		if viewport.size != VIEWPORT or camera.projection != Camera3D.PROJECTION_ORTHOGONAL or absf(camera.size - 8.0) > 0.000001 or absf(camera.near - 1.0) > 0.000001 or absf(camera.far - 10.0) > 0.000001:
    38			return _fail("viewport/projection setting mismatch")
```

The lesson's "at `_run` line 38" was true that day. `git log -S 'far-boundary-outside' --oneline -- corpus/fixtures/camera3d_ortho.gd` → `deae894 game-dev-3d r55: sample orthographic far-plane pair`. At that commit the mismatch return is already at line 50, and line 38 is `active_viewport = viewport`. Live line 38 is the far-boundary flag parse (`git blame -L 38,38` → `deae894f` `2026-10-13 09:00:49 -0300`). Live mismatch return is line 54 (`git blame -L 54,54` still attributes the text to `d5feae8b`). Further insertions after r55 moved 50 → 54. Not chased; the live line is 54.

Do not rewrite the historical sentence. The private-run receipt really did fail at line 38 of the then-current file.

### Files 3–5 — not moves

`camera3d_project.gd` cited lines are byte-identical to `82c21b4` (`nl -ba` of `git show` vs the working tree, lines 51, 58, 126, 145). `:51` is `const EXPECTED_SCREEN := Vector2(550.0, 225.0)`, not the `unproject_position` call (live line 107). That was already true at r1. It is a constant locator, not drifted content. Do not "fix" it.

`body3d_slide.gd` lines 37, 118, 139 are the same text at `82c21b4` and now.

`navagent3d_retarget.gd` last commit is `b214575` `2026-10-13 05:35:29 -0300`, the same commit as `corpus/lessons/r52-final-review.md` (`git log -1` on each). The file is 59 lines. Line 40 is the endpoint `return _fail`. Line 57 is `push_error("navagent3d_retarget: " + reason)`, which is what the pasted backtrace names as `_fail` line 57.

## 3. The sweep does not catch this

At `2026-10-18T18:48:42-03:00`, `git diff --stat -- corpus/lessons/r1-headless-verification.md` was `1 file changed, 1 insertion(+), 1 deletion(-)`. The only hunk was a path-root fix, not a line-anchor fix:

```text
-python3 run_battery.py --godot /usr/bin/godot --runs corpus/live/runs
+python3 corpus/fixtures/run_battery.py --godot /usr/bin/godot --runs corpus/live/runs
```

After that edit, `rg -n` still found `run_battery.py:124`, `:30`, and `:84` in the working tree. That edit is another seat's (chunk A owns this lesson). This seat did not touch it. A later sweep edit may add a note; this snapshot did not have one. `rg` for a correction note on these anchors in `r1-headless-verification.md` and `r23-ortho-review.md` hit only the original claims.

`git status --porcelain` on the five fixtures was empty. They are not mid-edit.

## 4. Queue (do not apply from this seat)

| ID | Owner | File | Repair | Do not |
|---|---|---|---|---|
| Q1 | SEAT-01 (lessons chunk A, index 0) | `corpus/lessons/r1-headless-verification.md` | Dated note, 2026-10-18: `:30/:84/:101/:124` were exact at `82c21b4` and now live at 39 / 923 / 940 / 964. Current-tense "Sources" pointers. | Silent number swap. That hides that the r1 numbers were once exact. |
| Q2 | SEAT-03 (lessons chunk C, index 20) | `corpus/lessons/r23-ortho-review.md:24` | Dated note: the mismatch return is at line 54 as of this snapshot; line 38 is an r55 flag parse (`deae894`). Leave "line 38" in the historical sentence. | Rewrite line 38 → 54 inside the review receipt. That receipt was true at `d5feae8`. |

Severity: reader-facing, not a battery break. Not a mechanical path defect. Not in the path-sweep's fix class, as §3 shows.

Chunk index: `sorted(corpus/lessons)` file index `// 8`, 93 lesson files, seats 01–12. r1 is index 0, r23 is index 20, r52 is index 56.

## 5. What this does not claim

- Not a corpus-wide rate. Five files, chosen because lessons name a line in them. Other lessons may be clean or worse.
- Not a claim that `:51` on `camera3d_project.gd` should be moved to the `unproject_position` call. It was a constant locator at authorship.
- No fixture, lesson, or knowledge file was edited by this seat.
- No Unreal runtime claim. No battery was run.
