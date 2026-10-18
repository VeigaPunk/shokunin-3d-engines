# r103 close-out gate runs (L1)

Six consecutive runs on the final installed gate (post all seats), idle host, TMPDIR default:

Two anomalies earlier in the close window: (1) one run printed GATE RESULT: FAIL (checks failed: 1) with CHECK 4 PASS — a check 1-3 flake; (2) one run produced EMPTY output with exit 1. Root cause class: /tmp is a 16G tmpfs shared with the user's other sessions (observed 77-80% used; 'Disk quota exceeded' on cp during the round) and the gate's mktemp + git clone workdir lives in /tmp — allocation/clone failures under pressure surface as silent or misleading failures. SEAT-01 observed the same class mid-round ('CHECK 2 flaky ... while the network was demonstrably up'). Routed to r104: gate workdir resilience (honor TMPDIR in docs; optional GATE_WORKDIR), plus a flake-reproduction harness. The A4 BLOCKED path (exit 2) was verified against a live proxy attack at close: STEP=BLOCKED / GATE RESULT: BLOCKED / rc=2.
