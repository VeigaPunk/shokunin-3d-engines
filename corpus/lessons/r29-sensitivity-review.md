# Round 29 — independent slope assertion sensitivity review

**Verdict:** Calibration improves narrowly: copied 40° slope with rotation expectation adjusted fails the separate measured X assertion, and with copied X/Y/grounded expectations additionally adjusted it fails the separate first-normal assertion. Depth and coverage unchanged. This proves only two downstream checks under these scratch changes, not every downstream predicate or general slope sensitivity. No implementation edits, push, or merge. Tested headless Godot `4.7.2.stable.arch_linux.ed1daf0bf` on this host.

## Commands, receipts and preservation

From repository root:

```sh
python3 corpus/fixtures/run_battery.py --probe-tree-timeout --probe-crash-exit --probe-stream-attribution --probe-failing
# exit 0; 37/37 (17 ordinary, 20 negative), four probes PASS, seeds_unchanged=true
python3 corpus/fixtures/run_battery.py --only slope3d_travel,slope3d_travel_level
# exit 0; 2/2 (one ordinary, one negative), seeds_unchanged=true
```

Full receipt `corpus/live/runs/20261013T060936691334Z/verdicts.json` SHA-256 `499795216eb13b73e99298f45a95d94043e69e3d1f5ac8a8c3e7140ea698b839`; pair `corpus/live/runs/20261013T060936691923Z/verdicts.json` SHA-256 `f2cd5d2d0728f2d6ecb6c063316fdb325c7fa61cfabeab3874117f36e731ec9f`. Full probe receipts in full-run directory: tree-timeout `59be00b967df76f6298201a5e49d1f0d4c912e249da18746e6e4a776a7b4ad4b`, crash-exit `ab96487326c08d18d87518212441999ed63ccc5b235f632dfde8a529df535990`, stream-attribution `494644b362b60b12869c90ea3b37746e6edd4b1633059898de47d174c542c4b7`, built-in body3d mutation `358b5fc422fc522816f63238705d61a666bf46ffc0f89d73c32c61a33b62419c`. All opt-ins PASS.

Versus prior r28 full `corpus/live/runs/20261013T060433692579Z/verdicts.json`, all 37 cases preserve order, script, flags, expected/actual exit, error, kind, marker, verdict, reasons and exact stdout/stderr arrays. Run-specific commands/timings/paths differ. Full and paired seed maps exactly agree. Compared with r28 seeds, all digests remain identical except documented README `b3b87e1e2c8cf1044f53d0b88643824d5763ac21a5ea5f0fa8e33d09f2c25dcd` → `e2ae8435e6f167771ac84972711c32ee159ff31518b058215296115aa60ace7f` and slope source `ad553688c2213e2a64a3296051fe5b51d5cdcb40f0a5b8059a4de32d24b78e5c` → `c18a285ec1b30edddc2fa524c8d560c76c1282241a21bdf42942467aef47ef44`. The latter splits the former single short-circuit `or` expression into rotation, X, Y/count, and normal diagnostic branches without changing original literals or both baseline markers. Full/pair slope records agree: slope exits 0, `PASS slope3d_travel downhill_x=-0.0810 y=1.3203 grounded_ticks=52 normal_y=0.866 stop_on_slope=false`; intact level exits intended negative 2, `NEGATIVE REJECTED: slope3d_travel level_no_downhill x=0.0000 y=1.0001 grounded_ticks=44 normal_y=1.000`. These fixed marker values print after assertions, not direct raw measurement telemetry.

## Private copied controls and exact source deltas

Ignored copies `corpus/live/runs/r29-private-sensitivity-review/{A,B}` contain the copied project and slope script only. Relative to seeded `slope3d_travel.gd`, **A** changes exactly `const SLOPE_ANGLE := 30.0` → `40.0` and the *rotation expression* `rad_to_deg(slab.rotation.z) - 30.0` → `- 40.0` (script SHA-256 `f2a686299bfb306a5408a79c1a2509bedabba5b902fd88cf72160c1725520cd7`). The rotation error text still says `expected=30.000` but is unreachable here; normal literal unchanged. **B** starts with A and changes exactly three additional assertion expressions: `actor.position.x + 0.0810` → `+ 0.1347`, `actor.position.y - 1.3203` → `- 1.4605`, `grounded_ticks != 52` → `!= 60` (script SHA-256 `c7cbbaab320396fe1c07941c613f372a7c05825fa56b74167d51a463beab0e4d`). No other code, diagnostic strings, normal literal `Vector3(-0.5, 0.8660254, 0)`, or fixed PASS marker changed. Hence diagnostic expected X text in B remains stale but X branch passes and is never printed.

```sh
/usr/bin/godot --headless --path corpus/live/runs/r29-private-sensitivity-review/A --script res://slope3d_travel.gd > corpus/live/runs/r29-private-sensitivity-review/A.stdout 2> corpus/live/runs/r29-private-sensitivity-review/A.stderr
# exit 1; ERROR: slope3d_travel: slope displacement mismatch x=-0.1347 expected=-0.0810
/usr/bin/godot --headless --path corpus/live/runs/r29-private-sensitivity-review/B --script res://slope3d_travel.gd > corpus/live/runs/r29-private-sensitivity-review/B.stdout 2> corpus/live/runs/r29-private-sensitivity-review/B.stderr
# exit 1; ERROR: slope3d_travel: slope normal mismatch normal=(-0.642788, 0.766044, 0.0)
```

Both stdout files have only Godot banner and blank line, SHA-256 `1fb0f12cefe41f881cb436e6731d981084b95f8db9b1d6f3e25ac930f360a32e`; A stderr SHA-256 `1a71b05b1d611d681ca73e086d716826c0b6bf76b8ef2ed4156823db0588a418`, B stderr `0dba5e190c9de1c5ebf3205bb0a5b8aa85137ee5379509d156b06df7bbb846d2`. Each includes its stated ERROR with `_run` branch backtrace, no PASS marker, `SCRIPT ERROR`, `Parse Error`, or ObjectDB leak. The X offset exceeds the original 0.003 tolerance by about 0.0537. B reaches the normal check because the adjusted rotation, X, and combined Y/count checks pass; normal differs visibly from the original `(-0.5,0.8660254,0)` and exceeds the original 0.0001 distance tolerance. The Y/count checks were adjusted together and not independently mutation-isolated; scratch constants derive from prior measured 40° values and do not establish all-regime or all-predicate sensitivity.

> **Correction note (r106, 2026-10-18, SEAT-42).** Live-tree digest check. Quoted SHA-256 values above are the 2026-10-13 review record and are not rewritten. The prior `slope3d_travel.gd` digest `ad553688c221…` matches a historical blob and does not match live; the r29-side digest `c18a285ec1b30edddc2fa524c8d560c76c1282241a21bdf42942467aef47ef44` still matches `sha256sum corpus/fixtures/slope3d_travel.gd`. README digests on the comparison line likewise match historical blobs, not live `corpus/fixtures/README.md` `347e0d1e5e4efca9c6f8b93440370352278bb30f3c1f62cee19edd3704619cb1`. Absent `corpus/live/runs/` receipts and private mutant copies were not re-hashed.

<!-- r106-seat45-receipt-note -->

> **Non-resolvable receipt note (r106, 2026-10-18, SEAT-45).** Re-checked 2026-10-18: each path below is a concrete `corpus/live/runs` receipt cited in this lesson. The cited path is absent (`test -e` failed) and no durable copy exists under `reports/` (no receipt artifact whose path or `started_utc` is that run id; a prose mention is not a copy). Quoted receipt SHA-256 values on these lines do not match any tracked file or any `reports/` receipt artifact. `corpus/.gitignore` ignores `live/`, so these paths were never tracked. Historical sentences above are unchanged. Register: `reports/round-106/consistency/receipts.md`.
>
> - `corpus/live/runs/20261013T060936691334Z/verdicts.json`
> - `corpus/live/runs/20261013T060936691923Z/verdicts.json`
> - `corpus/live/runs/20261013T060433692579Z/verdicts.json`
> - `corpus/live/runs/r29-private-sensitivity-review/{A`
> - `corpus/live/runs/r29-private-sensitivity-review/A`
> - `corpus/live/runs/r29-private-sensitivity-review/A.stdout`
> - `corpus/live/runs/r29-private-sensitivity-review/A.stderr`
> - `corpus/live/runs/r29-private-sensitivity-review/B`
> - `corpus/live/runs/r29-private-sensitivity-review/B.stdout`
> - `corpus/live/runs/r29-private-sensitivity-review/B.stderr`
