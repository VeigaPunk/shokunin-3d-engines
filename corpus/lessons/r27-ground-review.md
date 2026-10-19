# Round 27 — independent pre-impulse grounded-state review

**Finding:** The new probe samples a grounded flag **after one downward `move_and_slide()` and before the upward impulse**, true on the normal floor and false on the displaced floor. This closes r26's unsampled *pre-impulse* precondition, not the stricter claim that `is_on_floor()` was true before any move. Calibration improves narrowly; depth and coverage unchanged. Godot `4.7.2.stable.arch_linux.ed1daf0bf`, headless Linux. No implementation edits, push or merge.

## Independent runs

From repository root:

```sh
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0, 35/35 (16 ordinary, 19 negative), all four opt-in probes PASS, seeds_unchanged=true
python3 corpus/fixtures/run_battery.py --only jump3d_land,jump3d_no_floor
# exit 0, 2/2 (one ordinary, one negative), seeds_unchanged=true
```

Full receipt `corpus/live/runs/20261013T055914266533Z/verdicts.json` SHA-256 `e0cfee0a698199084f7bff550851aa8dffa3b9fc45f34d624e7841dc9a2d4d1f`; pair `corpus/live/runs/20261013T055922914638Z/verdicts.json` SHA-256 `6e7e57cc761d79cfc0e02dab8d18f82a07b87950ae21d1f699717624ccc79a3c`. Four full-run auxiliary SHA-256 receipts: `tree-timeout-verdicts.json` `eb486b21b3b82b76e3ad4301e61b934e1e3a8bc053b61037714e6cc4a6e63fa1`, `crash-exit-verdicts.json` `15f3c0838ea28217603929994f289d017760dbe9a0dbfa9bcf603f28aae59c92`, `stream-attribution-verdicts.json` `653fcbdd4ba026f65ad9270e9cc1ddef445749a5f631e03a2804355a7f7828a6`, `mutation-verdicts.json` `cf790d9454718eb186998cfeaf60d309ee557a7cb420f5a573ff2978b4501a5f`. The built-in mutation still targets *body3d_contact*, not this new precondition.

Against r26 full `corpus/live/runs/20261013T055425026403Z/verdicts.json` SHA-256 `4234d6098ffde37214527c38dcb66e15ab1c7495b307a16e5d0009e78c0f9e8b`, all previous **33 non-jump** raw case records agree in case/order, script, flags, expected/actual exit, error, kind, marker, verdict, reasons, and complete stdout/stderr arrays (excluding only run-specific commands, scratch paths and elapsed seconds). In the jump pair the only record differences are exact `marker` and stdout marker lines inserting `initially_grounded=true` or `initially_grounded=false`; exits, apex/landing/final numbers and other fields stay identical. Normal remains apex tick29/y2.451, landing tick60/final center y1.001, `grounded=true`. Displaced remains apex tick29/y2.450, final center y0.900, `grounded=false`. Both stderr arrays empty. Thus the sampled endpoint numbers remain the same to their displayed 0.001 precision; this does **not** show every intermediate position/velocity or the contact solver's trajectory was unchanged exactly.

The two runs' seed maps agree and independently attest unchanged pre/post seed hashes. Relative to r26, only `README.md` (`7dbd1c6950e530c43a81b1f00ed707647716890fb978b29674dde1246489900a` → `f9c95665ba4fc662ca608e1a386dda2d85cd39a7170e696a3cfb0498a8721a61`), `jump3d_gravity.gd` (`a2dbe8ddfa0a7af3f38d1cd61b2de55b23c9402f7d8ba4d85908f27b5a3cca00` → `27730ed5c9c63bc9b1495807159db8c1e280de0bdeb22627052411876a0a48d0`), and `run_battery.py` (`fe81c3d3d45ea8edb5f0a3c8cb121202a7928059ff6be60e24251ae9cbdade91` → `f3ded050f5fa2f7ea36e857e522e62ebe6bffbc63dd652f54accff349eab5333`) changed; all other prior seed digests agree.

## Mechanics and negative control

`jump3d_gravity.gd` creates an 8×1×8 static box **centered at y=0** (top y=0.5), or at y=-20 (top y=-19.5) for `--lower-floor`. The unit actor box is centered at y=1 (bottom y=0.5), so only the normal arm geometrically contacts the top at setup. This is not a floor *top* at y=0. Actor `collision_mask=1` matches floor `collision_layer=1`; actor uses `MOTION_MODE_GROUNDED`. Following one `await physics_frame`, a single velocity `(0,-0.01,0)` and `move_and_slide()` precede the new `initially_grounded := actor.is_on_floor()` read. The immediate assertion requires that flag true in normal and false in lower-floor, plus `abs(actor.position.y-1.0) <= 0.002`; it fails **before** assigning the +6 impulse or entering the 60-call loop. This precondition is measured after the downward probe, not on pristine initial scene insertion. The probe may change solver contact state and actor position within tolerance; its vertical velocity is overwritten by +6 before the jump, but no exact no-perturbation claim follows. After that, the familiar -12/60 gravity integration, frame-paced explicit `move_and_slide` calls, authored apex/landing checks and exact fixed output markers remain. `initially_grounded=` in those markers is a constant label printed only after the predicate, not direct formatting of telemetry.

A **private ignored scratch copy only** changed `floor_body.position.y = -20 if lower else 0` → `floor_body.position.y = -20 if lower else -1` in the normal arm; this puts the intact floor center at -1 (top -0.5), so the actor bottom 0.5 has a unit gap. Seed SHA-256 `27730ed5c9c63bc9b1495807159db8c1e280de0bdeb22627052411876a0a48d0`, mutant SHA-256 `2d422a8a54a3c39f4fe6e47c6100173fa42cf00cda04eed3e75bf1ab06ce5589`. Reproduction and captured streams:

```sh
/usr/bin/godot --headless --path corpus/live/r27-private-ground-review/scratch --script res://jump3d_gravity.gd
# exit 1; stdout Godot banner only; stderr ERROR: jump3d_gravity: initial floor probe failed grounded=false y=0.9998 lower=false
# streams: corpus/live/r27-private-ground-review/mutant.stdout and mutant.stderr
```

No PASS marker, apex or landing assertion, Parse Error, SCRIPT ERROR, or ObjectDB leak appears. The error backtrace points to `_run` at its precondition (line49), before the impulse. This tests one normal-arm floor relocation, not sensitivity to every possible floor change or solver revision.

**Scope:** One engine version, grounded mode, this box arrangement, one -0.01 downward contact probe and +6 impulse at fixed 60 Hz. The normal and displaced arms prove opposite **post-probe, pre-impulse** floor flags, not initial unprobed flags, callback-driven physics, all trajectory samples, rendered motion, or general jump-controller behavior. Reviewer changed only the ignored mutant floor constant 0→-1; no tracked authored constant or implementation was edited.

> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten; each drifted digest matches a historical git blob of the named path. Live `sha256sum` differs for `corpus/fixtures/README.md` `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1` and `corpus/fixtures/run_battery.py` `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. The r26-side `jump3d_gravity.gd` digest differs from live; the r27-side digest `27730ed5c9c63bc9b1495807159db8c1e280de0bdeb22627052411876a0a48d0` still matches. Absent `corpus/live/runs/` receipts and private mutant copies were not re-hashed.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T055914266533Z/verdicts.json`
> - `corpus/live/runs/20261013T055922914638Z/verdicts.json`
> - `corpus/live/runs/20261013T055425026403Z/verdicts.json`
