# r106 SEAT-111 — MORPHOLOGY

Axes: coverage (is every changed path citation-path class?), calibration (histogram equals the captured numstat), depth (hunk token test, not a filename guess).

Snapshot: `2026-10-18T22:13:41Z` UTC. HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`r105 report-last: verdict (all axes improved), LOG + SCORECARD, shadowing-not-drift ruling + P/C operator package — work 3634bc0`). This file is the only SEAT-111 report write. No commit, checkout, or reset. The snapshot is not a lock — peer seats were still landing edits during measurement (timeline below). An earlier draft of this file mis-labeled `Dated correction note` blocks as unclassified; this text replaces that draft.

## Verdict

**No. Not every tracked edit is citation-path class.**

Citation-path class, for this seat: every removed line pairs with an added line whose only token delta is stripping `.shokunin/game-dev-3d/` or `/home/vgpnk/Projects/prymeagnt/game-dev-3d/` (including the parent-symlink form), qualifying a bare script name to `corpus/fixtures/…` (including `run_battery.py:symbol` → `` `corpus/fixtures/run_battery.py` (`symbol`) ``), or dropping a parenthetical `` (`.shokunin/game-dev-3d/`) ``; any extra added lines are a dated correction note, including a fenced quote of the original command. A file that also rewrites counts, engine rows, remotes, or tool-install facts is not in this class.

Tracked delta: **85 files, 1418 insertions, 161 deletions**. `git diff --shortstat HEAD` captured in the same snapshot: `85 files changed, 1418 insertions(+), 161 deletions(-)`. Citation-path files: **22**. Not citation-path: **63**.

| class | files | in citation-path class? |
|---|---:|---|
| `citation-path+note` | 17 | yes — path rewrite plus dated note |
| `citation-path-silent` | 5 | yes — path rewrite, no dated note (queued) |
| `census` | 1 | no — engines.md two-state census |
| `calibration-env` | 1 | no — 337/350 vs 350/350 pairing |
| `index-command-note` | 1 | no — README remote/index re-measure (command-resolution adjacent) |
| `tool-path-note` | 1 | no — rea.md Ghidra install-path note (tool-path adjacent) |
| `other` | 59 | no — failed the token test; evidence below |

Untracked paths are not in `git diff --stat`. At this snapshot: **16787**, of which **0** sit outside `reports/round-106/`. Those are round evidence and scratch copies, not citation-path edits.

## Commands

Run from `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, one snapshot (stat, numstat, name-status, and `-U0` patch name sets equal: True).

```
date -u +%Y-%m-%dT%H:%M:%SZ
git rev-parse HEAD
git diff --stat HEAD
git diff --numstat HEAD
git diff --name-status HEAD
git diff --shortstat HEAD
git diff --cached --name-status
git diff --check HEAD
git status --porcelain=v1 -uall -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md SKILL.md reports/round-101 reports/round-102 reports/round-103 reports/round-104 reports/round-105 corpus/fixtures corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d corpus/knowledge/unreal-mcp/gate
```

Observed: date `2026-10-18T22:13:41Z`; HEAD `0cc3f4162f8c319f8d01a69a174fe939f36701bd`; cached empty=True; `git diff --check` exit `0`, output `(empty)`; protected porcelain `(empty)`.

## git diff --stat

Verbatim `git diff --stat HEAD`:

```
 corpus/README.md                                | 109 ++++++++++++++++
 corpus/knowledge/engines.md                     | 160 +++++++++++++++++++++++-
 corpus/knowledge/rea.md                         |   9 ++
 corpus/lessons/r1-headless-verification.md      |  17 ++-
 corpus/lessons/r10-zip-review.md                |   6 +
 corpus/lessons/r102-unreal-integration.md       |   6 +
 corpus/lessons/r105-unreal-lifecycle.md         |  23 +++-
 corpus/lessons/r11-import-review.md             |   7 ++
 corpus/lessons/r12-import-review.md             |   8 ++
 corpus/lessons/r13-nav-review.md                |   9 ++
 corpus/lessons/r14-floor-review.md              |   9 ++
 corpus/lessons/r15-slope-review.md              |  13 ++
 corpus/lessons/r16-telemetry-review.md          |  12 ++
 corpus/lessons/r17-instance-review.md           |  12 ++
 corpus/lessons/r18-scene-review.md              |  13 ++
 corpus/lessons/r19-unity-final-review.md        |  22 ++++
 corpus/lessons/r19-unity-review.md              |  20 +++
 corpus/lessons/r2-independent-review.md         |  14 ++-
 corpus/lessons/r20-resource-final-review.md     |  27 ++++
 corpus/lessons/r20-resource-review.md           |  11 ++
 corpus/lessons/r21-saved-resource-review.md     |   8 ++
 corpus/lessons/r22-unreal-review.md             |   6 +
 corpus/lessons/r23-ortho-review.md              |   8 ++
 corpus/lessons/r24-ortho-near-review.md         |  15 ++-
 corpus/lessons/r25-ortho-far-review.md          |  14 ++-
 corpus/lessons/r26-jump-review.md               |  19 ++-
 corpus/lessons/r27-ground-review.md             |  16 ++-
 corpus/lessons/r28-slope-travel-review.md       |  18 ++-
 corpus/lessons/r29-sensitivity-review.md        |  25 +++-
 corpus/lessons/r3-signal-exit.md                |   2 +-
 corpus/lessons/r3-signal-review.md              |  16 ++-
 corpus/lessons/r30-animation-review.md          |  14 +++
 corpus/lessons/r31-playback-review.md           |  14 +++
 corpus/lessons/r32-blend-review.md              |  14 +++
 corpus/lessons/r33-arraymesh-review.md          |  14 +++
 corpus/lessons/r34-index-review.md              |  14 +++
 corpus/lessons/r35-trimesh-review.md            |  12 ++
 corpus/lessons/r36-faces-review.md              |  15 +++
 corpus/lessons/r37-multimesh-review.md          |  12 ++
 corpus/lessons/r38-skeleton-review.md           |  13 ++
 corpus/lessons/r39-bone-rotation-review.md      |  15 +++
 corpus/lessons/r4-stream-attribution.md         |   2 +-
 corpus/lessons/r4-stream-review.md              |  18 ++-
 corpus/lessons/r40-attachment-review.md         |  14 +++
 corpus/lessons/r41-shapecast-review.md          |  16 +++
 corpus/lessons/r42-graze-review.md              |  16 +++
 corpus/lessons/r43-curve-review.md              |  12 ++
 corpus/lessons/r44-pathfollow-review.md         |  14 +++
 corpus/lessons/r45-paced-follow-review.md       |  12 ++
 corpus/lessons/r46-callback-review.md           |  11 ++
 corpus/lessons/r47-remote-review.md             |  34 ++++-
 corpus/lessons/r48-rotation-review.md           |  39 +++++-
 corpus/lessons/r49-navagent-review.md           |  31 ++++-
 corpus/lessons/r5-cleanup-review.md             |  25 +++-
 corpus/lessons/r5-identified-witness-timeout.md |   2 +-
 corpus/lessons/r5-timeout-review.md             |  23 +++-
 corpus/lessons/r50-navfollow-review.md          |  33 ++++-
 corpus/lessons/r51-retarget-review.md           |  32 ++++-
 corpus/lessons/r52-final-review.md              |  31 +++--
 corpus/lessons/r53-doc-review.md                |  27 +++-
 corpus/lessons/r54-near-review-inherited.md     |  22 +++-
 corpus/lessons/r55-far-review.md                |  28 ++++-
 corpus/lessons/r56-exact-near-review.md         |  23 ++--
 corpus/lessons/r56-final-doc-review.md          |  23 +++-
 corpus/lessons/r57-exact-far-review.md          |  18 ++-
 corpus/lessons/r58-three-camera-review.md       |  21 +++-
 corpus/lessons/r59-three-near-review.md         |   7 ++
 corpus/lessons/r6-final-review.md               |  13 +-
 corpus/lessons/r6-isolation-review.md           |  16 ++-
 corpus/lessons/r6-three-review.md               |  13 +-
 corpus/lessons/r60-three-ortho-review.md        |   7 ++
 corpus/lessons/r61-stream-review.md             |  16 ++-
 corpus/lessons/r62-three-ortho-near-review.md   |  19 ++-
 corpus/lessons/r63-three-ray-review.md          |  22 +++-
 corpus/lessons/r64-ray-side-review.md           |  22 +++-
 corpus/lessons/r65-ray-order-review.md          |  18 ++-
 corpus/lessons/r66-ray-range-review.md          |  18 ++-
 corpus/lessons/r67-ray-boundary-review.md       |  16 ++-
 corpus/lessons/r68-ray-layers-review.md         |  19 ++-
 corpus/lessons/r7-camera-far-plane.md           |   2 +-
 corpus/lessons/r7-camera-review.md              |  15 ++-
 corpus/lessons/r79-bpy-two-layer-model.md       |   2 +-
 corpus/lessons/r8-camera-near-plane.md          |   2 +-
 corpus/lessons/r8-near-review.md                |  22 +++-
 corpus/lessons/r9-glb-review.md                 |  12 +-
 85 files changed, 1418 insertions(+), 161 deletions(-)
```

## Insertions / deletions histogram

Source: `git diff --numstat HEAD` from the same snapshot. Sums: insertions **1418**, deletions **161**, net **1257**. No binary rows (`-`/`-` absent).

| bucket (lines per file) | files by insertions | files by deletions | files by abs(net) |
|---|---:|---:|---:|
| 0 | 0 | 38 | 6 |
| 1-2 | 6 | 10 | 0 |
| 3-5 | 0 | 33 | 0 |
| 6-10 | 15 | 4 | 32 |
| 11-20 | 48 | 0 | 35 |
| 21-50 | 14 | 0 | 10 |
| 101+ | 2 | 0 | 2 |

Per-file numstat (`insertions<TAB>deletions<TAB>path`):

```
109	0	corpus/README.md
155	5	corpus/knowledge/engines.md
9	0	corpus/knowledge/rea.md
15	2	corpus/lessons/r1-headless-verification.md
6	0	corpus/lessons/r10-zip-review.md
6	0	corpus/lessons/r102-unreal-integration.md
22	1	corpus/lessons/r105-unreal-lifecycle.md
7	0	corpus/lessons/r11-import-review.md
8	0	corpus/lessons/r12-import-review.md
9	0	corpus/lessons/r13-nav-review.md
9	0	corpus/lessons/r14-floor-review.md
13	0	corpus/lessons/r15-slope-review.md
12	0	corpus/lessons/r16-telemetry-review.md
12	0	corpus/lessons/r17-instance-review.md
13	0	corpus/lessons/r18-scene-review.md
22	0	corpus/lessons/r19-unity-final-review.md
20	0	corpus/lessons/r19-unity-review.md
11	3	corpus/lessons/r2-independent-review.md
27	0	corpus/lessons/r20-resource-final-review.md
11	0	corpus/lessons/r20-resource-review.md
8	0	corpus/lessons/r21-saved-resource-review.md
6	0	corpus/lessons/r22-unreal-review.md
8	0	corpus/lessons/r23-ortho-review.md
12	3	corpus/lessons/r24-ortho-near-review.md
11	3	corpus/lessons/r25-ortho-far-review.md
15	4	corpus/lessons/r26-jump-review.md
13	3	corpus/lessons/r27-ground-review.md
14	4	corpus/lessons/r28-slope-travel-review.md
21	4	corpus/lessons/r29-sensitivity-review.md
1	1	corpus/lessons/r3-signal-exit.md
12	4	corpus/lessons/r3-signal-review.md
14	0	corpus/lessons/r30-animation-review.md
14	0	corpus/lessons/r31-playback-review.md
14	0	corpus/lessons/r32-blend-review.md
14	0	corpus/lessons/r33-arraymesh-review.md
14	0	corpus/lessons/r34-index-review.md
12	0	corpus/lessons/r35-trimesh-review.md
15	0	corpus/lessons/r36-faces-review.md
12	0	corpus/lessons/r37-multimesh-review.md
13	0	corpus/lessons/r38-skeleton-review.md
15	0	corpus/lessons/r39-bone-rotation-review.md
1	1	corpus/lessons/r4-stream-attribution.md
14	4	corpus/lessons/r4-stream-review.md
14	0	corpus/lessons/r40-attachment-review.md
16	0	corpus/lessons/r41-shapecast-review.md
16	0	corpus/lessons/r42-graze-review.md
12	0	corpus/lessons/r43-curve-review.md
14	0	corpus/lessons/r44-pathfollow-review.md
12	0	corpus/lessons/r45-paced-follow-review.md
11	0	corpus/lessons/r46-callback-review.md
31	3	corpus/lessons/r47-remote-review.md
35	4	corpus/lessons/r48-rotation-review.md
28	3	corpus/lessons/r49-navagent-review.md
23	2	corpus/lessons/r5-cleanup-review.md
1	1	corpus/lessons/r5-identified-witness-timeout.md
22	1	corpus/lessons/r5-timeout-review.md
30	3	corpus/lessons/r50-navfollow-review.md
29	3	corpus/lessons/r51-retarget-review.md
24	7	corpus/lessons/r52-final-review.md
23	4	corpus/lessons/r53-doc-review.md
17	5	corpus/lessons/r54-near-review-inherited.md
23	5	corpus/lessons/r55-far-review.md
16	7	corpus/lessons/r56-exact-near-review.md
18	5	corpus/lessons/r56-final-doc-review.md
13	5	corpus/lessons/r57-exact-far-review.md
17	4	corpus/lessons/r58-three-camera-review.md
7	0	corpus/lessons/r59-three-near-review.md
10	3	corpus/lessons/r6-final-review.md
12	4	corpus/lessons/r6-isolation-review.md
10	3	corpus/lessons/r6-three-review.md
7	0	corpus/lessons/r60-three-ortho-review.md
13	3	corpus/lessons/r61-stream-review.md
15	4	corpus/lessons/r62-three-ortho-near-review.md
16	6	corpus/lessons/r63-three-ray-review.md
16	6	corpus/lessons/r64-ray-side-review.md
14	4	corpus/lessons/r65-ray-order-review.md
14	4	corpus/lessons/r66-ray-range-review.md
13	3	corpus/lessons/r67-ray-boundary-review.md
15	4	corpus/lessons/r68-ray-layers-review.md
1	1	corpus/lessons/r7-camera-far-plane.md
12	3	corpus/lessons/r7-camera-review.md
1	1	corpus/lessons/r79-bpy-two-layer-model.md
1	1	corpus/lessons/r8-camera-near-plane.md
18	4	corpus/lessons/r8-near-review.md
9	3	corpus/lessons/r9-glb-review.md
```

The insertion tail is not citation-path: `corpus/knowledge/engines.md` is 155/5, `corpus/README.md` is 109/0. Lesson files cluster at 1–10 line substitutions; abs(net) 0 is the path-rewrite shape (a line replaced by a line).

## Class lists

### Citation-path, rewrite plus dated note (17)

- `corpus/lessons/r27-ground-review.md` numstat 13/3 root=3 qual=0 prose=0
- `corpus/lessons/r28-slope-travel-review.md` numstat 14/4 root=4 qual=0 prose=0
- `corpus/lessons/r29-sensitivity-review.md` numstat 21/4 root=4 qual=0 prose=0
- `corpus/lessons/r47-remote-review.md` numstat 31/3 root=3 qual=0 prose=0
- `corpus/lessons/r48-rotation-review.md` numstat 35/4 root=4 qual=0 prose=0
- `corpus/lessons/r49-navagent-review.md` numstat 28/3 root=3 qual=0 prose=0
- `corpus/lessons/r5-timeout-review.md` numstat 22/1 root=0 qual=1 prose=0
- `corpus/lessons/r50-navfollow-review.md` numstat 30/3 root=3 qual=0 prose=0
- `corpus/lessons/r51-retarget-review.md` numstat 29/3 root=3 qual=0 prose=0
- `corpus/lessons/r61-stream-review.md` numstat 13/3 root=3 qual=0 prose=0
- `corpus/lessons/r62-three-ortho-near-review.md` numstat 15/4 root=4 qual=0 prose=0
- `corpus/lessons/r63-three-ray-review.md` numstat 16/6 root=6 qual=0 prose=0
- `corpus/lessons/r64-ray-side-review.md` numstat 16/6 root=6 qual=0 prose=0
- `corpus/lessons/r65-ray-order-review.md` numstat 14/4 root=4 qual=0 prose=0
- `corpus/lessons/r66-ray-range-review.md` numstat 14/4 root=4 qual=0 prose=0
- `corpus/lessons/r67-ray-boundary-review.md` numstat 13/3 root=3 qual=0 prose=0
- `corpus/lessons/r68-ray-layers-review.md` numstat 15/4 root=4 qual=0 prose=0

### Citation-path, silent rewrite (no dated note in the diff) (5)

- `corpus/lessons/r3-signal-exit.md` numstat 1/1 root=1 qual=0 prose=0
- `corpus/lessons/r4-stream-attribution.md` numstat 1/1 root=1 qual=0 prose=0
- `corpus/lessons/r7-camera-far-plane.md` numstat 1/1 root=1 qual=0 prose=0
- `corpus/lessons/r79-bpy-two-layer-model.md` numstat 1/1 root=0 qual=1 prose=0
- `corpus/lessons/r8-camera-near-plane.md` numstat 1/1 root=0 qual=1 prose=0

### Not citation-path: engines census (1)

- `corpus/knowledge/engines.md` numstat 155/5

### Not citation-path: environment pairing (1)

- `corpus/lessons/r105-unreal-lifecycle.md` numstat 22/1

### Not citation-path: README index / command note (1)

- `corpus/README.md` numstat 109/0

### Not citation-path: tool-path note (1)

- `corpus/knowledge/rea.md` numstat 9/0

### Failed token test (59)

- `corpus/lessons/r1-headless-verification.md` numstat 15/2
- `corpus/lessons/r10-zip-review.md` numstat 6/0
- `corpus/lessons/r102-unreal-integration.md` numstat 6/0
- `corpus/lessons/r11-import-review.md` numstat 7/0
- `corpus/lessons/r12-import-review.md` numstat 8/0
- `corpus/lessons/r13-nav-review.md` numstat 9/0
- `corpus/lessons/r14-floor-review.md` numstat 9/0
- `corpus/lessons/r15-slope-review.md` numstat 13/0
- `corpus/lessons/r16-telemetry-review.md` numstat 12/0
- `corpus/lessons/r17-instance-review.md` numstat 12/0
- `corpus/lessons/r18-scene-review.md` numstat 13/0
- `corpus/lessons/r19-unity-final-review.md` numstat 22/0
- `corpus/lessons/r19-unity-review.md` numstat 20/0
- `corpus/lessons/r2-independent-review.md` numstat 11/3
- `corpus/lessons/r20-resource-final-review.md` numstat 27/0
- `corpus/lessons/r20-resource-review.md` numstat 11/0
- `corpus/lessons/r21-saved-resource-review.md` numstat 8/0
- `corpus/lessons/r22-unreal-review.md` numstat 6/0
- `corpus/lessons/r23-ortho-review.md` numstat 8/0
- `corpus/lessons/r24-ortho-near-review.md` numstat 12/3
- `corpus/lessons/r25-ortho-far-review.md` numstat 11/3
- `corpus/lessons/r26-jump-review.md` numstat 15/4
- `corpus/lessons/r3-signal-review.md` numstat 12/4
- `corpus/lessons/r30-animation-review.md` numstat 14/0
- `corpus/lessons/r31-playback-review.md` numstat 14/0
- `corpus/lessons/r32-blend-review.md` numstat 14/0
- `corpus/lessons/r33-arraymesh-review.md` numstat 14/0
- `corpus/lessons/r34-index-review.md` numstat 14/0
- `corpus/lessons/r35-trimesh-review.md` numstat 12/0
- `corpus/lessons/r36-faces-review.md` numstat 15/0
- `corpus/lessons/r37-multimesh-review.md` numstat 12/0
- `corpus/lessons/r38-skeleton-review.md` numstat 13/0
- `corpus/lessons/r39-bone-rotation-review.md` numstat 15/0
- `corpus/lessons/r4-stream-review.md` numstat 14/4
- `corpus/lessons/r40-attachment-review.md` numstat 14/0
- `corpus/lessons/r41-shapecast-review.md` numstat 16/0
- `corpus/lessons/r42-graze-review.md` numstat 16/0
- `corpus/lessons/r43-curve-review.md` numstat 12/0
- `corpus/lessons/r44-pathfollow-review.md` numstat 14/0
- `corpus/lessons/r45-paced-follow-review.md` numstat 12/0
- `corpus/lessons/r46-callback-review.md` numstat 11/0
- `corpus/lessons/r5-cleanup-review.md` numstat 23/2
- `corpus/lessons/r5-identified-witness-timeout.md` numstat 1/1
- `corpus/lessons/r52-final-review.md` numstat 24/7
- `corpus/lessons/r53-doc-review.md` numstat 23/4
- `corpus/lessons/r54-near-review-inherited.md` numstat 17/5
- `corpus/lessons/r55-far-review.md` numstat 23/5
- `corpus/lessons/r56-exact-near-review.md` numstat 16/7
- `corpus/lessons/r56-final-doc-review.md` numstat 18/5
- `corpus/lessons/r57-exact-far-review.md` numstat 13/5
- `corpus/lessons/r58-three-camera-review.md` numstat 17/4
- `corpus/lessons/r59-three-near-review.md` numstat 7/0
- `corpus/lessons/r6-final-review.md` numstat 10/3
- `corpus/lessons/r6-isolation-review.md` numstat 12/4
- `corpus/lessons/r6-three-review.md` numstat 10/3
- `corpus/lessons/r60-three-ortho-review.md` numstat 7/0
- `corpus/lessons/r7-camera-review.md` numstat 12/3
- `corpus/lessons/r8-near-review.md` numstat 18/4
- `corpus/lessons/r9-glb-review.md` numstat 9/3

### Unpaired evidence for `other`

- `corpus/lessons/r1-headless-verification.md` unpaired deletions 0, leftover adds 13, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r10-zip-review.md` unpaired deletions 0, leftover adds 6, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r102-unreal-integration.md` unpaired deletions 0, leftover adds 6, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r11-import-review.md` unpaired deletions 0, leftover adds 7, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r12-import-review.md` unpaired deletions 0, leftover adds 8, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r13-nav-review.md` unpaired deletions 0, leftover adds 9, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r14-floor-review.md` unpaired deletions 0, leftover adds 9, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r15-slope-review.md` unpaired deletions 0, leftover adds 13, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r16-telemetry-review.md` unpaired deletions 0, leftover adds 12, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r17-instance-review.md` unpaired deletions 0, leftover adds 12, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r18-scene-review.md` unpaired deletions 0, leftover adds 13, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r19-unity-final-review.md` unpaired deletions 0, leftover adds 22, note_marker=False
  - ADD ``
  - ADD `> **Digest correction (r106, 2026-10-18).** The sentences above are unchanged. `Hierarchy.unity` `0c088c23…`, `Hierarchy.broken-reference.unity` `890f0929…`, and final `verify_scene.py` `decad886f…` still match the tree.`
  - ADD `>`
- `corpus/lessons/r19-unity-review.md` unpaired deletions 0, leftover adds 20, note_marker=False
  - ADD ``
  - ADD `> **Digest correction (r106, 2026-10-18).** The sentences above are unchanged. `Hierarchy.unity` `0c088c23…` and `Hierarchy.broken-reference.unity` `890f0929…` still match the tree. The artifact README hash `c4463ab5…` d`
  - ADD `>`
- `corpus/lessons/r2-independent-review.md` unpaired deletions 0, leftover adds 8, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r20-resource-final-review.md` unpaired deletions 0, leftover adds 27, note_marker=False
  - ADD ``
  - ADD `> **Digest correction (r106, 2026-10-18).** The "Current" hashes in the replay section are the r20 snapshot and are left verbatim. `scene3d_resource.gd` `7bbd986c…` still matches the tree (3316 bytes). `run_battery.py` ``
  - ADD `>`
- `corpus/lessons/r20-resource-review.md` unpaired deletions 0, leftover adds 11, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r21-saved-resource-review.md` unpaired deletions 0, leftover adds 8, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r22-unreal-review.md` unpaired deletions 0, leftover adds 6, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r23-ortho-review.md` unpaired deletions 0, leftover adds 8, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r24-ortho-near-review.md` unpaired deletions 0, leftover adds 9, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r25-ortho-far-review.md` unpaired deletions 0, leftover adds 8, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r26-jump-review.md` unpaired deletions 0, leftover adds 11, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r3-signal-review.md` unpaired deletions 0, leftover adds 8, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r30-animation-review.md` unpaired deletions 0, leftover adds 14, note_marker=True
  - ADD ``
  - ADD `> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `run_battery.py` digests match historical git blobs, n`
  - ADD ``
- `corpus/lessons/r31-playback-review.md` unpaired deletions 0, leftover adds 14, note_marker=True
  - ADD ``
  - ADD `> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `run_battery.py` digests match historical git blobs, n`
  - ADD ``
- `corpus/lessons/r32-blend-review.md` unpaired deletions 0, leftover adds 14, note_marker=True
  - ADD ``
  - ADD `> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `run_battery.py` digests match historical git blobs, n`
  - ADD ``
- `corpus/lessons/r33-arraymesh-review.md` unpaired deletions 0, leftover adds 14, note_marker=True
  - ADD ``
  - ADD `> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. The previous/current table is the r32→r33 snapshot, not today's files; those quoted SHA-256 values are preserved and match historical git blobs. `
  - ADD ``
- `corpus/lessons/r34-index-review.md` unpaired deletions 0, leftover adds 14, note_marker=True
  - ADD ``
  - ADD `> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `run_battery.py` digests match historical git blobs, n`
  - ADD ``
- `corpus/lessons/r35-trimesh-review.md` unpaired deletions 0, leftover adds 12, note_marker=True
  - ADD ``
  - ADD `> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `run_battery.py` digests match historical git blobs, n`
  - ADD ``
- `corpus/lessons/r36-faces-review.md` unpaired deletions 0, leftover adds 15, note_marker=True
  - ADD ``
  - ADD `> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; quoted `README.md` and `run_battery.py` digests match histori`
  - ADD ``
- `corpus/lessons/r37-multimesh-review.md` unpaired deletions 0, leftover adds 12, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r38-skeleton-review.md` unpaired deletions 0, leftover adds 13, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r39-bone-rotation-review.md` unpaired deletions 0, leftover adds 15, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r4-stream-review.md` unpaired deletions 0, leftover adds 10, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r40-attachment-review.md` unpaired deletions 0, leftover adds 14, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r41-shapecast-review.md` unpaired deletions 0, leftover adds 16, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r42-graze-review.md` unpaired deletions 0, leftover adds 16, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r43-curve-review.md` unpaired deletions 0, leftover adds 12, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r44-pathfollow-review.md` unpaired deletions 0, leftover adds 14, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r45-paced-follow-review.md` unpaired deletions 0, leftover adds 12, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r46-callback-review.md` unpaired deletions 0, leftover adds 11, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r5-cleanup-review.md` unpaired deletions 1, leftover adds 22, note_marker=True
  - DEL `Reviewer: `game-dev-3d-r5-cleanup-review`, non-author, Linux `/proc` and Godot `4.7.2.stable.arch_linux.ed1daf0bf`. Read standing mission, r5 LOG and `r5-timeout-review.md`; inspec`
  - ADD `Reviewer: `game-dev-3d-r5-cleanup-review`, non-author, Linux `/proc` and Godot `4.7.2.stable.arch_linux.ed1daf0bf`. Read standing mission, r5 LOG and `corpus/lessons/r5-timeout-review.md`; inspected the current runner. N`
  - ADD ``
  - ADD `## Correction note — 2026-10-18 (r106)`
- `corpus/lessons/r5-identified-witness-timeout.md` unpaired deletions 1, leftover adds 1, note_marker=False
  - DEL `Run `python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py --probe-tree-timeout` from repo root. Sources: `corpus/fixtures/timeout_tree3d.gd`, `timeout_descendant.py`, `run_`
  - ADD `Run `python3 corpus/fixtures/run_battery.py --probe-tree-timeout` from repo root. Sources: `corpus/fixtures/timeout_tree3d.gd`, `corpus/fixtures/timeout_descendant.py`, `corpus/fixtures/run_battery.py` (`probe_tree_timeo`
- `corpus/lessons/r52-final-review.md` unpaired deletions 0, leftover adds 17, note_marker=False
  - ADD ``
  - ADD `## r106 path-root conformance (2026-10-18)`
  - ADD ``
- `corpus/lessons/r53-doc-review.md` unpaired deletions 0, leftover adds 19, note_marker=False
  - ADD ``
  - ADD `## r106 path-root conformance (2026-10-18)`
  - ADD ``
- `corpus/lessons/r54-near-review-inherited.md` unpaired deletions 0, leftover adds 12, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r55-far-review.md` unpaired deletions 1, leftover adds 19, note_marker=False
  - DEL `Verdict: **PASS**, bounded to Godot 4.7.2 headless on this host. Reviewed committed work `bba28f05ce631e79c31ec224f94ded50fd581b55` (`game-dev-3d r55: sample orthographic far-plane`
  - ADD `Verdict: **PASS**, bounded to Godot 4.7.2 headless on this host. Reviewed committed work `bba28f05ce631e79c31ec224f94ded50fd581b55` (`game-dev-3d r55: sample orthographic far-plane pair`) and `99a820ca1c4f46e6b287ede7e1f`
  - ADD ``
  - ADD `## r106 path-root conformance (2026-10-18)`
- `corpus/lessons/r56-exact-near-review.md` unpaired deletions 0, leftover adds 9, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r56-final-doc-review.md` unpaired deletions 0, leftover adds 13, note_marker=False
  - ADD ``
  - ADD `## r106 path-root conformance (2026-10-18)`
  - ADD ``
- `corpus/lessons/r57-exact-far-review.md` unpaired deletions 0, leftover adds 8, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r58-three-camera-review.md` unpaired deletions 0, leftover adds 13, note_marker=False
  - ADD ``
  - ADD `## r106 path-root conformance (2026-10-18)`
  - ADD ``
- `corpus/lessons/r59-three-near-review.md` unpaired deletions 0, leftover adds 7, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r6-final-review.md` unpaired deletions 0, leftover adds 7, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r6-isolation-review.md` unpaired deletions 0, leftover adds 8, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r6-three-review.md` unpaired deletions 0, leftover adds 7, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r60-three-ortho-review.md` unpaired deletions 0, leftover adds 7, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r7-camera-review.md` unpaired deletions 0, leftover adds 9, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r8-near-review.md` unpaired deletions 0, leftover adds 14, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``
- `corpus/lessons/r9-glb-review.md` unpaired deletions 0, leftover adds 6, note_marker=False
  - ADD ``
  - ADD `<!-- r106-seat45-receipt-note -->`
  - ADD ``

### Why the non-citation files fail

`corpus/knowledge/engines.md` numstat 155/5. `git diff -U0` hunk headers:

```
@@ -4 +4,35 @@ Standing host reality (mint, 2026-10-13). Update this file whenever a
@@ -8,4 +42,5 @@ tooling probe lands; every claim cites its probe.
@@ -16,0 +52,115 @@ static/format evidence is labeled as such.
```

That replaces engine table rows and inserts an r106 two-state census (mise Node `v26.12.0`, fnm Node `v24.21.0`, battery pairing, stamp note). It is the C2 census refresh. This seat did not re-probe engines and makes no Unreal runtime claim; the morphology read does not treat the engines diff as proof of editor execution.

`corpus/lessons/r105-unreal-lifecycle.md` rewrites one historical sentence to insert `under the default environment, mise Node v26.12.0, not the pinned fnm Node v24.21.0 total` into the existing `337/350` clause, and appends an **Environment pairing (r106, 2026-10-18)** note (`cases=350 pass=337 fail=13` versus pinned `pass=350 fail=0`). No `.shokunin` token moves in that hunk. Class: calibration, not citation-path.

`corpus/README.md` adds `## Correction note (r106, 2026-10-18)` and does not rewrite an existing path line. The note is command-resolution adjacent (`git fetch game-dev-3d main` exit 128 here; remote exists only in the parent campaign repo) and then leaves citation-path class: upstream tip SHAs, `fixtures` 12 at mint versus 147 at HEAD, child-tree ids, and a layout census. Fixture code was not edited.

`corpus/knowledge/rea.md` adds a dated note only. It corrects an r102 "Ghidra absent" probe that missed `~/.local/opt/ghidra_12.1.4_PUBLIC`. That is a tool-path note, not a `.shokunin` citation rewrite, and it states no analysis was run.

### Silent citation-path rewrites (queued, not repaired)

Round rule: dated correction notes for historical facts, never silent rewrites. **5** files change historical path or command text with no dated note in the diff:

- `corpus/lessons/r3-signal-exit.md`
- `corpus/lessons/r4-stream-attribution.md`
- `corpus/lessons/r7-camera-far-plane.md`
- `corpus/lessons/r79-bpy-two-layer-model.md`
- `corpus/lessons/r8-camera-near-plane.md`

`corpus/lessons/r1-headless-verification.md`, if classed silent above, is two citation edits and no note: `python3 run_battery.py` → `python3 corpus/fixtures/run_battery.py`, and `` lane root (`.shokunin/game-dev-3d/`) `` → `lane repo root`. The `12 OK` count is unchanged.

`corpus/lessons/r5-identified-witness-timeout.md`, if classed silent, strips `.shokunin/game-dev-3d/` and qualifies `timeout_descendant.py` / `run_battery.py:probe_tree_timeout` to `corpus/fixtures/…`. No numeric rewrite in that line.

`corpus/lessons/r79-bpy-two-layer-model.md`, if classed silent, changes only `` `bpy_battery.py` `` → `` `corpus/fixtures/bpy_battery.py` ``. The `37/37` count is unchanged.

## Prefix still in the tree

`git grep -l -F -- .shokunin/game-dev-3d HEAD -- corpus README.md` → **90** files, **353** hits. Worktree `git grep -l` → **68** files, **252** hits. Of the HEAD files: **23** are in this diff and no longer match, **56** are in this diff but still match (a dated note often quotes the old root), **11** are not in this diff.

Not-yet-edited HEAD hits by directory:

- `corpus/fixtures`: 4
- `corpus/lessons`: 4
- `corpus/artifacts`: 3

Protected fixture/upstream/manifest/gate paths among those HEAD prefix hits: **4**. They are absent from the tracked diff (protected porcelain empty). Clearing them would be a fixture-code edit, which this round forbids.

## Worktree surface outside the stat

Untracked: **16787**. Outside `reports/round-106/`: **0**. Top buckets:

- `scratch`: 16163
- `census`: 499
- `gate`: 69
- `battery-default-quick-receipts`: 7
- `glb-unity`: 7
- `sweep`: 6
- `consistency`: 2
- `battery-default-quick.md`: 1
- `citation-form-rule.md`: 1
- `consistency.md`: 1
- `engine-cmd-regression.md`: 1
- `engine-count.md`: 1
- `final-integrity.md`: 1
- `freshness-pin.md`: 1
- `git-hygiene.md`: 1

Staged set empty. Whitespace check clean. Protected set has no porcelain hits.

## Stability

Same HEAD, earlier reads, before this freeze:

- `2026-10-18T21:20:48Z`: `git diff --stat HEAD` empty.
- `2026-10-18T21:26:39Z`: 8 files, +43/−35 (`corpus/lessons/r61`–`r68`).
- `2026-10-18T21:34:59Z`: 9 files, +56/−36.
- `2026-10-18T21:43:29Z`: 32 files, +199/−79 (`engines.md` present).
- 15s poll: 32 files from `21:44:28Z` to `21:45:13Z`; 33 files from `21:45:28Z` to `21:45:58Z`.
- `2026-10-18T21:47:50Z`: 33 files, +206/−80.
- `2026-10-18T21:57:33Z`: 41 files, +237/−111.
- `2026-10-18T22:06:57Z`: 49 files, +555/−161 (first draft of this file; class labels wrong).
- `2026-10-18T22:10:27Z`: 56 files, +583/−161.

Re-run `git diff --stat HEAD` before close. If the name set grew, this histogram is a point-in-time morphology, not the round total.

