# r105 · SEAT-08 SIXTH-ROW-CRITIC

## Verdict

**REVISE unless the fixture-runtime row makes a named non-author replay mandatory.** The row's evidence cannot stop at a green battery run produced by the same lane that authored the case table and fixtures. Require a named verifier, an independent rerun, and a durable verifier-owned report/receipt pointer. That replay establishes reproducibility of the lane-authored checks; it is not an independent oracle for whether their assertions encode engine truth. Keep the claim scoped to what the fixture actually observed, not generalized engine correctness.

## Adversarial finding

The runner's 350 case rows are a literal table in `corpus/fixtures/run_battery.py`; each row includes the case name, fixture script, flags, expected exit, and exact output marker. The battery can therefore pass its own authored expectations without an outside witness. `corpus/knowledge/engines.md` already sets the correct promotion bar: saved bounded-run receipt **and** non-author verifier. The sixth row should say the same for fixture-runtime claims and should not permit the author to satisfy that clause.

A future reader obtains the verifier by having the round lead name a separate verifier seat in the round assignment, then have that seat run the exact reproduction command against the pinned runner/fixture bytes and claimed runtime. The verifier records its identity, command, runtime version/path, target digests, per-row result, unchanged-seed result, and durable receipt pointer in its own report. For the r105 matrix, the verifier must use the claimed Node v24.21.0 PATH when exercising the Node-pinned rows, not silently inherit the host's default Node. An author receipt, a report that only reads the author's receipt, or a passing gate is not a substitute.

This is an established lane workflow, not a hypothetical new resource: r104 records SEAT-04's fixture change and a separate SEAT-07 full-battery run on those same final bytes, with a durable receipt; the L1 then records its own idle-host corroboration. The sixth row should point future readers to that seat-based route rather than leaving “non-author” as an unassigned aspiration.

## Evidence — commands run and observed output

```text
$ python3 -c 'from pathlib import Path; p=Path("corpus/fixtures/run_battery.py"); ls=p.read_text().splitlines(); print("\n".join(f"{i+1}:{ls[i]}" for i in range(37,43)))'
38:# (case name, script, flags, expected exit, exact stdout marker line)
39:CASES = [
40:    ("navagent3d_retarget", "navagent3d_retarget.gd", [], 0,
41:     "PASS navagent3d_retarget callbacks=120 before=1.730676,0.000,1.730676 after_end=1.000,0.000,3.000 final=1.000,0.000,3.000")
42:    ("navagent3d_retarget_fixed", "navagent3d_retarget.gd", ["--fixed"], 2,
43:     "NEGATIVE REJECTED: navagent3d_retarget fixed callbacks=120 after_end=3.000,0.000,3.000 final=3.000,0.000,3.000")

$ python3 -c 'import ast, pathlib; p=pathlib.Path("corpus/fixtures/run_battery.py"); t=ast.parse(p.read_text()); n=next(n for n in t.body if isinstance(n, ast.Assign) and any(isinstance(x, ast.Name) and x.id=="CASES" for x in n.targets)); print(f"CASES rows={len(n.value.elts)} literal_nodes={type(n.value).__name__}"); print(f"source={p}")'
CASES rows=350 literal_nodes=List
source=corpus/fixtures/run_battery.py

$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py

$ python3 -c 'from pathlib import Path; p=Path("corpus/knowledge/engines.md"); ls=p.read_text().splitlines(); print("\n".join(f"{i+1}:{ls[i]}" for i in range(12,16)))'
13:Rules: an engine row may move to "executable headless" only with a saved
14:receipt of a bounded fixture run and a non-author verifier, like any
15:other axis-move. Absence of an engine never authorizes runtime claims;
16:static/format evidence is labeled as such.

$ python3 -c 'from pathlib import Path; p=Path("reports/round-104/r104-report.md"); ls=p.read_text().splitlines(); print("\n".join(f"{i+1}:{ls[i]}" for i in range(699,713)))'
700:**C1 (depth) — the fix and its safety net.** SEAT-04 landed the r103-ruled fix: the seven
701:`phys3d_joints` arms now spawn their children as a concurrent batch (`_spawn_batch`, the
702:pattern `phys3d_events.gd:615-655` already ships), and the collection loop carries the
703:fail-closed deadline SEAT-01 demanded (`BATCH_BOUND_S := 16`, kill + named
704:`batch_timeout` failure — one notch below the per-case `BOUND_S = 20`, mirroring
705:`phys3d_events.gd`'s own bound). Measurements on the final bytes: L1 close run
706:`--only phys3d_joints_free_ops` → **PASS, 2.9 s, exit 0** (r102: killed at 20.008 s);
707:SEAT-07's full battery on the same bytes → **337/350** (`free_ops` PASS at 2.77 s,
708:336/336 previously-passing rows unbroken, the 13 `r94_cannon_*` rows unchanged,
709:`seeds_unchanged=true`; receipt
710:`reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`).
711:Determinism: serial vs concurrent arm outputs byte-identical (SEAT-06). Scope: only
712:`phys3d_joints.gd` changed; `run_battery.py` sha `f456bd00…` and all 350 CASES rows
713:AST-identical (SEAT-08/09).

$ python3 -c 'from pathlib import Path; p=Path("reports/round-104/r104-report.md"); ls=p.read_text().splitlines(); print("\n".join(f"{i+1}:{ls[i]}" for i in range(742,750)))'
743:to the pinned subtree in-file.
744:
745:**Honest limits.** The full-battery number above is SEAT-07's measurement on the final
746:fixture bytes; the L1's idle-host corroborating run (receipt
747:`corpus/live/runs/20261018T201215739340Z/verdicts.json`) **reproduced it exactly:
748:cases=350 pass=337 fail=13** — same classes, no new failures. The default gate run
749:remains load-sensitive while the host /tmp quota is exhausted. No live-editor claim
750:exists anywhere; `verified-here` on Unreal surfaces remains impossible by construction.
```

## Limits

This seat did not rerun the battery; this critic report makes no new runtime verdict.
