# Round 4: real Godot stdout/stderr attribution

Run `python3 corpus/fixtures/run_battery.py --probe-stream-attribution` from repo root. Source: `corpus/fixtures/stream_attribution3d.gd`, `run_battery.py:classify` and `:probe_stream_attribution`. Named independent replay and baseline contrast: `corpus/lessons/r4-stream-review.md`; rerun for ignored fresh raw receipts in `corpus/live/runs/<timestamp>/stream-attribution-verdicts.json`.

| Same script, exact stdout marker, exit 0 | stderr | classifier |
|---|---|---|
| Node3D setup, no extra flag | empty | true |
| Node3D setup, `--emit-stderr` | `STREAM_3D_STDERR` | false: `unexpected stderr line: STREAM_3D_STDERR` |

The pre-r4 classifier accepted the actual reject-arm streams `(True, [])`; all nonempty stderr lines now reject. This intentionally strict stderr policy may reject future benign diagnostics; it does not prove every stderr line is a defect. No other engine, renderer, spontaneous crash, or process-tree timeout is proven. Default twelve cases unchanged.
