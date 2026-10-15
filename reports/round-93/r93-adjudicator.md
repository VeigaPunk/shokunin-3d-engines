# r93 adjudication — Area3D signal-in-tick ordering lattice

**Verdict: ADMIT** — committed `661749f`, 265 rows (218 ordinary + 47 negative), 7 new `r93_areasig_*` rows.

## Dossier

| seat | verdict | commit |
|---|---|---|
| author | 265/265 run1; r93 rows byte-identical ×3 batteries | `661749f` |
| baseline-r2 (pre-landed, post-r92-fold `75739bc`) | 255+254/258, zero new flakes, 7/7 re-pinned rows PASS | `455d9b1` |
| boundary | ordering law holds; queue_free post-E, in-dispatch refusal, GP/Jolt splits folded | `454aea1` |
| critic | PASS — 7/7 byte-identical, 1136 child execs 0 multi-hash cells, bodysig 90/90/backend | `522cef9` |
| reviewer | ADMIT-recommend — 262/265 committed bytes, r93 7/7 | `75ff16d` |
| simplifier | PASS — 8 net lines proven removable (SP1–SP5), deferred to next fold | `bba7221` |
| verifier | VERIFIED — clean 258→265 insert, 64 execs byte-exact @load127, Jolt flip live | `2b8c71e` |
| scribe | custody intact — all manifests check, pins reconstruct | `88c143e` |

## Laws admitted

- `in_step` signal classification: post-IF/pre-E ordering across falling/spawn/teleport entries; `queue_free` exits post-E with null-body duplicate shape; `free_rid` produces `no_if` exits + backend-specific teardown errors; in-dispatch `monitoring` write refused (exact text, no flush, no redetect).
- GP/Jolt splits: frozen-body teleport `detected` 0/1; monitorable window; `bsi` entry order. Dummy vacuity `nif=0`. Jolt multi-overlap order left deliberately unpinned (`seqeq=-`/`pairs=-`) — live flip evidence captured and reproduced by verifier (2/8, critic 6/64 prio).

## Recorded-not-folded (fold queue)

- Simplifier SP1–SP5 (−8 net lines, verified byte-identical).
- Reviewer F1–F5 report-accuracy nits (arm→case table misstates 3/7 rows — report-only).
- Critic F1: add `phys3d_events_freed_space_methods` segv-lottery class to flake list.
- Navagent family: `navagent3d_detour_mut_ladder_region` observed flaking — same map-publish wall-race class as the dissected `navagent3d_{follow,retarget}` (`fc6d033` fix spec queued: `map_get_iteration_id >= 2` gate + re-pins, prototype green 17/17).
- bpy stamp fix spec (`6421676`): disable 7 `use_stamp_*` fields + `stable=True`, verified 20/20.

## Bounds

Godot 4.7.2.stable.arch_linux headless `--fixed-fps 60`, GodotPhysics/Jolt/Dummy, this host under load 90–149. `bodysig` Jolt order pin: 122/122 observations stable, residual risk recorded. No fully-green 265 rep on committed bytes (foreign load ≥70 entire window; every fail is a documented flake class).
