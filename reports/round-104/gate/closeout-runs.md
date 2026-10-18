# r104 close-out gate runs (L1) — 2026-10-18

Host condition during close: the shared /tmp tmpfs (16G) has its per-user quota
exhausted — `df` shows 3.1G free at the filesystem level but a 4KiB write is
refused (`Disk quota exceeded`, observed live). Default-workdir gate runs are
therefore load/quota-sensitive on this host; deterministic close runs use
`GATE_WORKDIR`.

| run | env | result |
|---|---|---|
| 1 | default workdir, battery concurrent | `GATE RESULT: FAIL (checks failed: 1)` — flake class, empty-output sibling run observed |
| 2 | default workdir, battery concurrent | empty output, rc=1 — same flake class |
| 3 | GATE_WORKDIR=reports/round-104/gate/closeout/scratch | **PASS rc=0**, POINTERS=103 UNRESOLVED=0, WORK_ROOT reported, scratch cleaned |
| 4 | GATE_WORKDIR + `REPO=https://127.0.0.1:9/nope` (A4 via the now-implemented override) | `CHECK 2 BLOCKED (network)` + `STEP=BLOCKED` + `GATE RESULT: BLOCKED` + **exit 2** |

Run artifacts: `run3.out`, `run4-blocked.out` in this directory.
Gate sha256 after the REPO-override fold: `390a25ae4e389a00…` (was `e5521304…`).

Full attack regression and flake matrix are the seats' durable records:
`regression.md` (11 content attacks + A1–A4 + comm-absent, all detected),
`close-runs.md` (SEAT-48's 6-run series + raw logs), `pin-check.md` (103=103).
