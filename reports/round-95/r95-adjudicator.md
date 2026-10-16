# r95 adjudication — Bullet/PyBullet physics lattice

**Verdict: ADMIT-with-findings** — committed `0767b59`, 304 rows (245 ordinary + 59 negative), 20 new `r95_bullet_*` rows, vendored `pybullet` `.so` byte-pinned (reproduced exactly via `strip --strip-debug`).

## Dossier

| seat | verdict | commit |
|---|---|---|
| author | 304/304 ×2 fully green; vendor equivalence 52/52 | `0767b59` |
| boundary (pre-landed) | SHM+rt=1 pump-live; DIRECT-scoped purity; order non-neutrality; float-btScalar hash-shift | `92949e3` |
| critic | PASS w/ F1 MEDIUM — SHM `d`-count race, 8/24 via real runner | `fa7e951` |
| reviewer | ADMIT-recommend — 303/304 ×2, F1 convergent (23/43) | this round |
| simplifier | PASS — SP1–SP6 net −42 proven; F-1 same SHM race (5/11) | `faa5ec8` |
| verifier | VERIFIED — 304/304, 208 dual-build execs byte-identical | `fd6db99` |
| scribe | AUDIT PASSES — 11768+1847 manifests, F1 `sl_force_mb` rest-pin precision | `a042e49` |

## Laws admitted

Bit-exact Float64 physics witnesses; DIRECT-scoped wall-clock inertness; SHM `rt=1` pump-live `fell` class; creation-order non-neutrality (permutation-invariant re-test); scene-scoped detpairs; 1-ulp friction; ≥0-gate NaN filter; EMPTY-sleep calibration; six negative controls with in-child live checks.

## Recorded-not-folded

- **F1 (4-seat consensus):** `r95_bullet_shm` pins `d` on a racy teardown diagnostic count (`shm_step {8,10}`, `shm_rtclass {42,44,46,48}`) — `releaseSharedMemory` partial-line prints land pre/post single-drain. Physics M-surface is byte-stable always (`h=02309c52da41ef33`); row fails closed. Fold spec agreed by two seats: envelope `d` sets or deterministic drain. Queued behind r96 author's `run_battery.py` custody.
- Simplifier SP1–SP6 (−42 net, all proven byte-identical).
- Scribe F1: `sl_force_mb` rest pin differs from scout's same-scenario cell — resting state not a pure own-history function (record correction, pin reproduces).

## Bounds

Godot 4.7.2 headless parent + python 3.14.7 children, vendored `.so` (f64 build `dtBits=3f71…`), load 50–87. SHM stepped-hash race correctly authored `#`-only.
