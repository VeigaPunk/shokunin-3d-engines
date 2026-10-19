# r106 SEAT-108 — lesson append-only integrity (line counts vs HEAD)

**Seat:** SEAT-108 SWEEP-LESSON-INTEGRITY
**Owned path:** `reports/round-106/sweep/lesson-integrity.md` (this file). This seat edited no `corpus/lessons/**` file.
**HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`)
**Subject:** `r105 report-last: verdict (all axes improved), LOG + SCORECARD, shadowing-not-drift ruling + P/C operator package — work 3634bc0`
**Snapshot:** `2026-10-18T22:15:07Z` start, `2026-10-18T22:15:07Z` end (comparison and numstat in one process). Lane root: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.

Axes: coverage (every file under `corpus/lessons`, tracked and untracked), depth (`wc -l` delta plus `git diff --numstat`), calibration (point-in-time while other seats were still landing lesson edits; `wc -l` counts newline bytes).

**Verdict: PASS on the named criterion.** No lesson file shrank. Worktree `wc -l` is `>=` the HEAD blob `wc -l` for every path. Path sets match. Shrinks = 0. Deleted = 0. New = 0. Totals: HEAD `6961` lines, worktree `8046` lines, delta `+1085`. SAME = 19. GREW = 77.

A stricter `+N/−0` reading is **not** met. Numstat below has deletions. No numstat row has more deletions than insertions (`neg_net_files` = 0), which is why `wc -l` never fell. Those deletions are other seats' in-place path fixes; this seat does not own those lines and does not revert them.

Earlier passes in this seat, same HEAD, also shrink = 0: `2026-10-18T21:27:51Z` (8 GREW, delta +8), `2026-10-18T21:36:47Z` (9 GREW, delta +20), `2026-10-18T21:55:10Z` (9 GREW, delta +20). The GREW set and the delta grew between passes because other seats were appending notes. The paste below is the snapshot named above, not those earlier passes.

---

## 1. Commands

```
$ date -u +%Y-%m-%dT%H:%M:%SZ; git rev-parse HEAD; git log -1 --format=%s HEAD
2026-10-18T22:15:07Z
0cc3f4162f8c319f8d01a69a174fe939f36701bd
r105 report-last: verdict (all axes improved), LOG + SCORECARD, shadowing-not-drift ruling + P/C operator package — work 3634bc0
```

Path set:

```
HEAD files (git ls-tree -r --name-only HEAD -- corpus/lessons): 96
worktree files (find corpus/lessons -type f): 96
only worktree: (empty)
only HEAD: (empty)
```

Per-file count: HEAD side is `git show HEAD:$f | wc -l` (newline count of the blob). Worktree side is `wc -l < $f`. One file lacks a trailing newline on both sides, so both counts under-count the logical last line by 1 and the comparison is still valid:

```
corpus/lessons/r71-navagent-postproc-review.md head_last=2e wt_last=2e
```

`r71-navagent-postproc-review.md` last byte `2e` is `.`. Logical lines = `wc -l + 1` on both sides.

```
TOTALS head=6961 wt=8046 delta=1085 same=19 grew=77 shrink=0 deleted=0 new=0
```

GREW rows only:

| path | HEAD wc | worktree wc | delta |
|---|---:|---:|---:|
| `corpus/lessons/r1-headless-verification.md` | 205 | 218 | +13 |
| `corpus/lessons/r10-zip-review.md` | 24 | 30 | +6 |
| `corpus/lessons/r102-unreal-integration.md` | 217 | 266 | +49 |
| `corpus/lessons/r105-unreal-lifecycle.md` | 162 | 205 | +43 |
| `corpus/lessons/r11-import-review.md` | 19 | 26 | +7 |
| `corpus/lessons/r12-import-review.md` | 29 | 37 | +8 |
| `corpus/lessons/r13-nav-review.md` | 16 | 25 | +9 |
| `corpus/lessons/r14-floor-review.md` | 10 | 19 | +9 |
| `corpus/lessons/r15-slope-review.md` | 35 | 48 | +13 |
| `corpus/lessons/r16-telemetry-review.md` | 33 | 45 | +12 |
| `corpus/lessons/r17-instance-review.md` | 25 | 37 | +12 |
| `corpus/lessons/r18-scene-review.md` | 32 | 45 | +13 |
| `corpus/lessons/r19-unity-final-review.md` | 32 | 54 | +22 |
| `corpus/lessons/r19-unity-review.md` | 40 | 60 | +20 |
| `corpus/lessons/r2-independent-review.md` | 43 | 51 | +8 |
| `corpus/lessons/r20-resource-final-review.md` | 36 | 63 | +27 |
| `corpus/lessons/r20-resource-review.md` | 33 | 44 | +11 |
| `corpus/lessons/r21-saved-resource-review.md` | 31 | 39 | +8 |
| `corpus/lessons/r22-unreal-review.md` | 83 | 89 | +6 |
| `corpus/lessons/r23-ortho-review.md` | 26 | 34 | +8 |
| `corpus/lessons/r24-ortho-near-review.md` | 35 | 44 | +9 |
| `corpus/lessons/r25-ortho-far-review.md` | 34 | 42 | +8 |
| `corpus/lessons/r26-jump-review.md` | 39 | 50 | +11 |
| `corpus/lessons/r27-ground-review.md` | 36 | 46 | +10 |
| `corpus/lessons/r28-slope-travel-review.md` | 43 | 53 | +10 |
| `corpus/lessons/r29-sensitivity-review.md` | 31 | 48 | +17 |
| `corpus/lessons/r3-signal-review.md` | 19 | 27 | +8 |
| `corpus/lessons/r30-animation-review.md` | 33 | 47 | +14 |
| `corpus/lessons/r31-playback-review.md` | 31 | 45 | +14 |
| `corpus/lessons/r32-blend-review.md` | 35 | 49 | +14 |
| `corpus/lessons/r33-arraymesh-review.md` | 52 | 66 | +14 |
| `corpus/lessons/r34-index-review.md` | 45 | 59 | +14 |
| `corpus/lessons/r35-trimesh-review.md` | 32 | 44 | +12 |
| `corpus/lessons/r36-faces-review.md` | 28 | 43 | +15 |
| `corpus/lessons/r37-multimesh-review.md` | 25 | 37 | +12 |
| `corpus/lessons/r38-skeleton-review.md` | 28 | 43 | +15 |
| `corpus/lessons/r39-bone-rotation-review.md` | 33 | 50 | +17 |
| `corpus/lessons/r4-stream-review.md` | 24 | 34 | +10 |
| `corpus/lessons/r40-attachment-review.md` | 35 | 51 | +16 |
| `corpus/lessons/r41-shapecast-review.md` | 39 | 57 | +18 |
| `corpus/lessons/r42-graze-review.md` | 32 | 50 | +18 |
| `corpus/lessons/r43-curve-review.md` | 32 | 46 | +14 |
| `corpus/lessons/r44-pathfollow-review.md` | 38 | 54 | +16 |
| `corpus/lessons/r45-paced-follow-review.md` | 32 | 46 | +14 |
| `corpus/lessons/r46-callback-review.md` | 32 | 45 | +13 |
| `corpus/lessons/r47-remote-review.md` | 32 | 60 | +28 |
| `corpus/lessons/r48-rotation-review.md` | 29 | 60 | +31 |
| `corpus/lessons/r49-navagent-review.md` | 30 | 55 | +25 |
| `corpus/lessons/r5-cleanup-review.md` | 18 | 39 | +21 |
| `corpus/lessons/r5-identified-witness-timeout.md` | 12 | 25 | +13 |
| `corpus/lessons/r5-timeout-review.md` | 15 | 36 | +21 |
| `corpus/lessons/r50-navfollow-review.md` | 30 | 57 | +27 |
| `corpus/lessons/r51-retarget-review.md` | 32 | 58 | +26 |
| `corpus/lessons/r52-final-review.md` | 40 | 57 | +17 |
| `corpus/lessons/r53-doc-review.md` | 19 | 38 | +19 |
| `corpus/lessons/r54-near-review-inherited.md` | 16 | 28 | +12 |
| `corpus/lessons/r55-far-review.md` | 20 | 38 | +18 |
| `corpus/lessons/r56-exact-near-review.md` | 51 | 60 | +9 |
| `corpus/lessons/r56-final-doc-review.md` | 19 | 32 | +13 |
| `corpus/lessons/r57-exact-far-review.md` | 30 | 38 | +8 |
| `corpus/lessons/r58-three-camera-review.md` | 23 | 36 | +13 |
| `corpus/lessons/r59-three-near-review.md` | 11 | 18 | +7 |
| `corpus/lessons/r6-final-review.md` | 10 | 17 | +7 |
| `corpus/lessons/r6-isolation-review.md` | 14 | 22 | +8 |
| `corpus/lessons/r6-three-review.md` | 11 | 18 | +7 |
| `corpus/lessons/r60-three-ortho-review.md` | 21 | 28 | +7 |
| `corpus/lessons/r61-stream-review.md` | 30 | 40 | +10 |
| `corpus/lessons/r62-three-ortho-near-review.md` | 15 | 26 | +11 |
| `corpus/lessons/r63-three-ray-review.md` | 21 | 31 | +10 |
| `corpus/lessons/r64-ray-side-review.md` | 24 | 34 | +10 |
| `corpus/lessons/r65-ray-order-review.md` | 27 | 37 | +10 |
| `corpus/lessons/r66-ray-range-review.md` | 29 | 39 | +10 |
| `corpus/lessons/r67-ray-boundary-review.md` | 24 | 34 | +10 |
| `corpus/lessons/r68-ray-layers-review.md` | 26 | 37 | +11 |
| `corpus/lessons/r7-camera-review.md` | 19 | 28 | +9 |
| `corpus/lessons/r8-near-review.md` | 21 | 35 | +14 |
| `corpus/lessons/r9-glb-review.md` | 21 | 27 | +6 |

---

## 2. Worktree `wc -l` (pasted)

Equivalent of `wc -l` on every worktree lesson file, `LC_ALL=C` sort, at `2026-10-18T22:15:07Z`.

```
    218 corpus/lessons/r1-headless-verification.md
     96 corpus/lessons/r1/adversarial-controls.json
    392 corpus/lessons/r1/clean-verdicts.json
     91 corpus/lessons/r1/mutation-verdicts.json
     14 corpus/lessons/r10-rea-zip-carrier.md
     30 corpus/lessons/r10-zip-review.md
    266 corpus/lessons/r102-unreal-integration.md
    205 corpus/lessons/r105-unreal-lifecycle.md
     26 corpus/lessons/r11-import-review.md
     37 corpus/lessons/r12-import-review.md
     25 corpus/lessons/r13-nav-review.md
     19 corpus/lessons/r14-floor-review.md
     48 corpus/lessons/r15-slope-review.md
     45 corpus/lessons/r16-telemetry-review.md
     37 corpus/lessons/r17-instance-review.md
     45 corpus/lessons/r18-scene-review.md
     54 corpus/lessons/r19-unity-final-review.md
     60 corpus/lessons/r19-unity-review.md
     51 corpus/lessons/r2-independent-review.md
     63 corpus/lessons/r20-resource-final-review.md
     44 corpus/lessons/r20-resource-review.md
     39 corpus/lessons/r21-saved-resource-review.md
     89 corpus/lessons/r22-unreal-review.md
     34 corpus/lessons/r23-ortho-review.md
     44 corpus/lessons/r24-ortho-near-review.md
     42 corpus/lessons/r25-ortho-far-review.md
     50 corpus/lessons/r26-jump-review.md
     46 corpus/lessons/r27-ground-review.md
     53 corpus/lessons/r28-slope-travel-review.md
     48 corpus/lessons/r29-sensitivity-review.md
     10 corpus/lessons/r3-signal-exit.md
     27 corpus/lessons/r3-signal-review.md
     47 corpus/lessons/r30-animation-review.md
     45 corpus/lessons/r31-playback-review.md
     49 corpus/lessons/r32-blend-review.md
     66 corpus/lessons/r33-arraymesh-review.md
     59 corpus/lessons/r34-index-review.md
     44 corpus/lessons/r35-trimesh-review.md
     43 corpus/lessons/r36-faces-review.md
     37 corpus/lessons/r37-multimesh-review.md
     43 corpus/lessons/r38-skeleton-review.md
     50 corpus/lessons/r39-bone-rotation-review.md
     10 corpus/lessons/r4-stream-attribution.md
     34 corpus/lessons/r4-stream-review.md
     51 corpus/lessons/r40-attachment-review.md
     57 corpus/lessons/r41-shapecast-review.md
     50 corpus/lessons/r42-graze-review.md
     46 corpus/lessons/r43-curve-review.md
     54 corpus/lessons/r44-pathfollow-review.md
     46 corpus/lessons/r45-paced-follow-review.md
     45 corpus/lessons/r46-callback-review.md
     60 corpus/lessons/r47-remote-review.md
     60 corpus/lessons/r48-rotation-review.md
     55 corpus/lessons/r49-navagent-review.md
     39 corpus/lessons/r5-cleanup-review.md
     25 corpus/lessons/r5-identified-witness-timeout.md
     36 corpus/lessons/r5-timeout-review.md
     57 corpus/lessons/r50-navfollow-review.md
     58 corpus/lessons/r51-retarget-review.md
     57 corpus/lessons/r52-final-review.md
     38 corpus/lessons/r53-doc-review.md
     28 corpus/lessons/r54-near-review-inherited.md
     38 corpus/lessons/r55-far-review.md
     60 corpus/lessons/r56-exact-near-review.md
     32 corpus/lessons/r56-final-doc-review.md
     38 corpus/lessons/r57-exact-far-review.md
     36 corpus/lessons/r58-three-camera-review.md
     18 corpus/lessons/r59-three-near-review.md
     17 corpus/lessons/r6-final-review.md
     22 corpus/lessons/r6-isolation-review.md
     18 corpus/lessons/r6-three-review.md
     28 corpus/lessons/r60-three-ortho-review.md
     40 corpus/lessons/r61-stream-review.md
     26 corpus/lessons/r62-three-ortho-near-review.md
     31 corpus/lessons/r63-three-ray-review.md
     34 corpus/lessons/r64-ray-side-review.md
     37 corpus/lessons/r65-ray-order-review.md
     39 corpus/lessons/r66-ray-range-review.md
     34 corpus/lessons/r67-ray-boundary-review.md
     37 corpus/lessons/r68-ray-layers-review.md
     10 corpus/lessons/r7-camera-far-plane.md
     28 corpus/lessons/r7-camera-review.md
   2871 corpus/lessons/r70-navagent-detour-non-author.json
     41 corpus/lessons/r70-navagent-detour-review.md
     68 corpus/lessons/r71-navagent-postproc-review.md
     67 corpus/lessons/r72-navagent-pdd-finish-review.md
     96 corpus/lessons/r73-navagent-link-gating-review.md
    104 corpus/lessons/r74-navagent-moving-agent.md
     63 corpus/lessons/r75-navagent-map-mutation.md
     84 corpus/lessons/r76-navagent-sync-window.md
    115 corpus/lessons/r77-mutation-apply-order.md
     68 corpus/lessons/r78-mapoff-permanence-callsite.md
     36 corpus/lessons/r79-bpy-two-layer-model.md
     11 corpus/lessons/r8-camera-near-plane.md
     35 corpus/lessons/r8-near-review.md
     27 corpus/lessons/r9-glb-review.md
   8046 total
```

---

## 3. Joined comparison (all files)

`path head_wc wt_wc delta tag`

```
corpus/lessons/r1-headless-verification.md 205 218 +13 GREW
corpus/lessons/r1/adversarial-controls.json 96 96 +0 SAME
corpus/lessons/r1/clean-verdicts.json 392 392 +0 SAME
corpus/lessons/r1/mutation-verdicts.json 91 91 +0 SAME
corpus/lessons/r10-rea-zip-carrier.md 14 14 +0 SAME
corpus/lessons/r10-zip-review.md 24 30 +6 GREW
corpus/lessons/r102-unreal-integration.md 217 266 +49 GREW
corpus/lessons/r105-unreal-lifecycle.md 162 205 +43 GREW
corpus/lessons/r11-import-review.md 19 26 +7 GREW
corpus/lessons/r12-import-review.md 29 37 +8 GREW
corpus/lessons/r13-nav-review.md 16 25 +9 GREW
corpus/lessons/r14-floor-review.md 10 19 +9 GREW
corpus/lessons/r15-slope-review.md 35 48 +13 GREW
corpus/lessons/r16-telemetry-review.md 33 45 +12 GREW
corpus/lessons/r17-instance-review.md 25 37 +12 GREW
corpus/lessons/r18-scene-review.md 32 45 +13 GREW
corpus/lessons/r19-unity-final-review.md 32 54 +22 GREW
corpus/lessons/r19-unity-review.md 40 60 +20 GREW
corpus/lessons/r2-independent-review.md 43 51 +8 GREW
corpus/lessons/r20-resource-final-review.md 36 63 +27 GREW
corpus/lessons/r20-resource-review.md 33 44 +11 GREW
corpus/lessons/r21-saved-resource-review.md 31 39 +8 GREW
corpus/lessons/r22-unreal-review.md 83 89 +6 GREW
corpus/lessons/r23-ortho-review.md 26 34 +8 GREW
corpus/lessons/r24-ortho-near-review.md 35 44 +9 GREW
corpus/lessons/r25-ortho-far-review.md 34 42 +8 GREW
corpus/lessons/r26-jump-review.md 39 50 +11 GREW
corpus/lessons/r27-ground-review.md 36 46 +10 GREW
corpus/lessons/r28-slope-travel-review.md 43 53 +10 GREW
corpus/lessons/r29-sensitivity-review.md 31 48 +17 GREW
corpus/lessons/r3-signal-exit.md 10 10 +0 SAME
corpus/lessons/r3-signal-review.md 19 27 +8 GREW
corpus/lessons/r30-animation-review.md 33 47 +14 GREW
corpus/lessons/r31-playback-review.md 31 45 +14 GREW
corpus/lessons/r32-blend-review.md 35 49 +14 GREW
corpus/lessons/r33-arraymesh-review.md 52 66 +14 GREW
corpus/lessons/r34-index-review.md 45 59 +14 GREW
corpus/lessons/r35-trimesh-review.md 32 44 +12 GREW
corpus/lessons/r36-faces-review.md 28 43 +15 GREW
corpus/lessons/r37-multimesh-review.md 25 37 +12 GREW
corpus/lessons/r38-skeleton-review.md 28 43 +15 GREW
corpus/lessons/r39-bone-rotation-review.md 33 50 +17 GREW
corpus/lessons/r4-stream-attribution.md 10 10 +0 SAME
corpus/lessons/r4-stream-review.md 24 34 +10 GREW
corpus/lessons/r40-attachment-review.md 35 51 +16 GREW
corpus/lessons/r41-shapecast-review.md 39 57 +18 GREW
corpus/lessons/r42-graze-review.md 32 50 +18 GREW
corpus/lessons/r43-curve-review.md 32 46 +14 GREW
corpus/lessons/r44-pathfollow-review.md 38 54 +16 GREW
corpus/lessons/r45-paced-follow-review.md 32 46 +14 GREW
corpus/lessons/r46-callback-review.md 32 45 +13 GREW
corpus/lessons/r47-remote-review.md 32 60 +28 GREW
corpus/lessons/r48-rotation-review.md 29 60 +31 GREW
corpus/lessons/r49-navagent-review.md 30 55 +25 GREW
corpus/lessons/r5-cleanup-review.md 18 39 +21 GREW
corpus/lessons/r5-identified-witness-timeout.md 12 25 +13 GREW
corpus/lessons/r5-timeout-review.md 15 36 +21 GREW
corpus/lessons/r50-navfollow-review.md 30 57 +27 GREW
corpus/lessons/r51-retarget-review.md 32 58 +26 GREW
corpus/lessons/r52-final-review.md 40 57 +17 GREW
corpus/lessons/r53-doc-review.md 19 38 +19 GREW
corpus/lessons/r54-near-review-inherited.md 16 28 +12 GREW
corpus/lessons/r55-far-review.md 20 38 +18 GREW
corpus/lessons/r56-exact-near-review.md 51 60 +9 GREW
corpus/lessons/r56-final-doc-review.md 19 32 +13 GREW
corpus/lessons/r57-exact-far-review.md 30 38 +8 GREW
corpus/lessons/r58-three-camera-review.md 23 36 +13 GREW
corpus/lessons/r59-three-near-review.md 11 18 +7 GREW
corpus/lessons/r6-final-review.md 10 17 +7 GREW
corpus/lessons/r6-isolation-review.md 14 22 +8 GREW
corpus/lessons/r6-three-review.md 11 18 +7 GREW
corpus/lessons/r60-three-ortho-review.md 21 28 +7 GREW
corpus/lessons/r61-stream-review.md 30 40 +10 GREW
corpus/lessons/r62-three-ortho-near-review.md 15 26 +11 GREW
corpus/lessons/r63-three-ray-review.md 21 31 +10 GREW
corpus/lessons/r64-ray-side-review.md 24 34 +10 GREW
corpus/lessons/r65-ray-order-review.md 27 37 +10 GREW
corpus/lessons/r66-ray-range-review.md 29 39 +10 GREW
corpus/lessons/r67-ray-boundary-review.md 24 34 +10 GREW
corpus/lessons/r68-ray-layers-review.md 26 37 +11 GREW
corpus/lessons/r7-camera-far-plane.md 10 10 +0 SAME
corpus/lessons/r7-camera-review.md 19 28 +9 GREW
corpus/lessons/r70-navagent-detour-non-author.json 2871 2871 +0 SAME
corpus/lessons/r70-navagent-detour-review.md 41 41 +0 SAME
corpus/lessons/r71-navagent-postproc-review.md 68 68 +0 SAME
corpus/lessons/r72-navagent-pdd-finish-review.md 67 67 +0 SAME
corpus/lessons/r73-navagent-link-gating-review.md 96 96 +0 SAME
corpus/lessons/r74-navagent-moving-agent.md 104 104 +0 SAME
corpus/lessons/r75-navagent-map-mutation.md 63 63 +0 SAME
corpus/lessons/r76-navagent-sync-window.md 84 84 +0 SAME
corpus/lessons/r77-mutation-apply-order.md 115 115 +0 SAME
corpus/lessons/r78-mapoff-permanence-callsite.md 68 68 +0 SAME
corpus/lessons/r79-bpy-two-layer-model.md 36 36 +0 SAME
corpus/lessons/r8-camera-near-plane.md 11 11 +0 SAME
corpus/lessons/r8-near-review.md 21 35 +14 GREW
corpus/lessons/r9-glb-review.md 21 27 +6 GREW
```

`git status --porcelain=v1 --untracked-files=all -- corpus/lessons` at the same pass:

```
 M corpus/lessons/r1-headless-verification.md
 M corpus/lessons/r10-zip-review.md
 M corpus/lessons/r102-unreal-integration.md
 M corpus/lessons/r105-unreal-lifecycle.md
 M corpus/lessons/r11-import-review.md
 M corpus/lessons/r12-import-review.md
 M corpus/lessons/r13-nav-review.md
 M corpus/lessons/r14-floor-review.md
 M corpus/lessons/r15-slope-review.md
 M corpus/lessons/r16-telemetry-review.md
 M corpus/lessons/r17-instance-review.md
 M corpus/lessons/r18-scene-review.md
 M corpus/lessons/r19-unity-final-review.md
 M corpus/lessons/r19-unity-review.md
 M corpus/lessons/r2-independent-review.md
 M corpus/lessons/r20-resource-final-review.md
 M corpus/lessons/r20-resource-review.md
 M corpus/lessons/r21-saved-resource-review.md
 M corpus/lessons/r22-unreal-review.md
 M corpus/lessons/r23-ortho-review.md
 M corpus/lessons/r24-ortho-near-review.md
 M corpus/lessons/r25-ortho-far-review.md
 M corpus/lessons/r26-jump-review.md
 M corpus/lessons/r27-ground-review.md
 M corpus/lessons/r28-slope-travel-review.md
 M corpus/lessons/r29-sensitivity-review.md
 M corpus/lessons/r3-signal-exit.md
 M corpus/lessons/r3-signal-review.md
 M corpus/lessons/r30-animation-review.md
 M corpus/lessons/r31-playback-review.md
 M corpus/lessons/r32-blend-review.md
 M corpus/lessons/r33-arraymesh-review.md
 M corpus/lessons/r34-index-review.md
 M corpus/lessons/r35-trimesh-review.md
 M corpus/lessons/r36-faces-review.md
 M corpus/lessons/r37-multimesh-review.md
 M corpus/lessons/r38-skeleton-review.md
 M corpus/lessons/r39-bone-rotation-review.md
 M corpus/lessons/r4-stream-attribution.md
 M corpus/lessons/r4-stream-review.md
 M corpus/lessons/r40-attachment-review.md
 M corpus/lessons/r41-shapecast-review.md
 M corpus/lessons/r42-graze-review.md
 M corpus/lessons/r43-curve-review.md
 M corpus/lessons/r44-pathfollow-review.md
 M corpus/lessons/r45-paced-follow-review.md
 M corpus/lessons/r46-callback-review.md
 M corpus/lessons/r47-remote-review.md
 M corpus/lessons/r48-rotation-review.md
 M corpus/lessons/r49-navagent-review.md
 M corpus/lessons/r5-cleanup-review.md
 M corpus/lessons/r5-identified-witness-timeout.md
 M corpus/lessons/r5-timeout-review.md
 M corpus/lessons/r50-navfollow-review.md
 M corpus/lessons/r51-retarget-review.md
 M corpus/lessons/r52-final-review.md
 M corpus/lessons/r53-doc-review.md
 M corpus/lessons/r54-near-review-inherited.md
 M corpus/lessons/r55-far-review.md
 M corpus/lessons/r56-exact-near-review.md
 M corpus/lessons/r56-final-doc-review.md
 M corpus/lessons/r57-exact-far-review.md
 M corpus/lessons/r58-three-camera-review.md
 M corpus/lessons/r59-three-near-review.md
 M corpus/lessons/r6-final-review.md
 M corpus/lessons/r6-isolation-review.md
 M corpus/lessons/r6-three-review.md
 M corpus/lessons/r60-three-ortho-review.md
 M corpus/lessons/r61-stream-review.md
 M corpus/lessons/r62-three-ortho-near-review.md
 M corpus/lessons/r63-three-ray-review.md
 M corpus/lessons/r64-ray-side-review.md
 M corpus/lessons/r65-ray-order-review.md
 M corpus/lessons/r66-ray-range-review.md
 M corpus/lessons/r67-ray-boundary-review.md
 M corpus/lessons/r68-ray-layers-review.md
 M corpus/lessons/r7-camera-far-plane.md
 M corpus/lessons/r7-camera-review.md
 M corpus/lessons/r79-bpy-two-layer-model.md
 M corpus/lessons/r8-camera-near-plane.md
 M corpus/lessons/r8-near-review.md
 M corpus/lessons/r9-glb-review.md
```

---

## 4. Numstat (not a shrink; not +N/−0)

```
$ git diff --numstat -- corpus/lessons
15	2	corpus/lessons/r1-headless-verification.md
6	0	corpus/lessons/r10-zip-review.md
49	0	corpus/lessons/r102-unreal-integration.md
44	1	corpus/lessons/r105-unreal-lifecycle.md
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
15	0	corpus/lessons/r38-skeleton-review.md
17	0	corpus/lessons/r39-bone-rotation-review.md
1	1	corpus/lessons/r4-stream-attribution.md
14	4	corpus/lessons/r4-stream-review.md
16	0	corpus/lessons/r40-attachment-review.md
18	0	corpus/lessons/r41-shapecast-review.md
18	0	corpus/lessons/r42-graze-review.md
14	0	corpus/lessons/r43-curve-review.md
16	0	corpus/lessons/r44-pathfollow-review.md
14	0	corpus/lessons/r45-paced-follow-review.md
13	0	corpus/lessons/r46-callback-review.md
31	3	corpus/lessons/r47-remote-review.md
35	4	corpus/lessons/r48-rotation-review.md
28	3	corpus/lessons/r49-navagent-review.md
23	2	corpus/lessons/r5-cleanup-review.md
14	1	corpus/lessons/r5-identified-witness-timeout.md
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

```
files 82 ins 1241 del 156 net 1085 neg_net_files 0
```

Net 1085 matches the `wc` delta 1085. Yes.

Sampled diffs (not every hunk): `r1-headless-verification.md`, `r9-glb-review.md`, `r47-remote-review.md`, `r61-stream-review.md`, `r63-three-ray-review.md`, `r67-ray-boundary-review.md`, `r79-bpy-two-layer-model.md`, `r105-unreal-lifecycle.md`. Observed class is in-place replacement of `.shokunin/game-dev-3d/` (and one bare `run_battery.py` / `bpy_battery.py`) with a repo-relative path, and/or an appended dated r106 note. Historical counts in the sampled files were left in the text. This seat did not classify the other hunks.

Queued for SEAT-86 / SEAT-81, not fixed here: line counts did not shrink, but the modified set is not strict append-only (`+N/−0`). Notes are dated where this seat read them. Whether every replaced token is only a path root is the sweep seats' claim, not this check.

---

## 5. What this seat did not do

- No lesson file written. No commit, push, checkout, or reset.
- Did not re-run battery, gate, or citation resolution.
- Scratch lists under `reports/round-106/scratch/seat108/` were intermediate. This file is the deliverable.
