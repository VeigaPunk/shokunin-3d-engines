# SEAT-15 N24 adversary — r105

**Axes:** coverage (protect the pinned-runtime claim), depth (make environment selection observable), calibration (do not widen a one-case receipt into a full-battery claim).

## Ruling proposal

**Conditionally accept Node 24.21.0 as an explicit battery execution profile; reject any claim that its green result proves the default environment is green.** This is a ruling about evidence and runbook wording, not permission to change the pinned fixtures or host configuration.

The matrix does not invalidate the byte-pinned discipline: it demonstrates why it matters. The cannon fixture invokes `node` via inherited `PATH` and pins the Node version in its exact PASS marker (`corpus/fixtures/r94_cannon.gd:15-16`). The 13 positive cannon rows pin `v24.21.0`; under a PATH resolving `v26.12.0`, the emitted marker differs, so an honest battery run fails closed rather than silently passing. But forcing the expected Node to the front of PATH changes the tested environment. A full pass there would mean “350/350 under Node 24.21.0,” not “350/350 under the host default,” and certainly not portable proof for an arbitrary machine.

Do not erase the distinction by changing markers, the fixture, mise/fnm configuration, or a user's startup files. Keep the default-profile result and the pinned-profile result separate. The r104 default full receipt is **337/350, 13 failed**, with `r94_cannon_nan` outputting `node=v26.12.0` against the `v24.21.0` marker; the fresh pinned receipt here is **only `r94_cannon_nan`, 1/1**, not the required full-matrix proof. The 350/350 acceptance remains unverified by this seat.

## Runbook must neutralize the PATH footgun

1. Name profiles, not a single undifferentiated “battery” result: `default-host` and `pinned-node-v24.21.0`. State plainly that a pinned-profile green run proves behavior only in that selected profile. Preserve and disclose the default profile's status; do not relabel its red rows as green merely because the pinned profile passes.
2. Before the pinned run, assert and print both the resolved executable and version: `command -v node` must equal `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`, and `node --version` must equal `v24.21.0`. Abort before the battery if either differs. The version string in the case marker is an additional check, not a substitute for preflight.
3. Scope the PATH prefix to that one invocation (or a child shell), show the exact command in the receipt, and leave shell/profile/system configuration unchanged. Do not silently persist the override or use an alias/wrapper whose selection is not printed.
4. For the claimed matrix pass, retain a fresh full-run receipt and require `cases=350`, `pass=350`, `fail=0`, `seeds_unchanged=true`, the pinned Node preflight, and the unchanged runner digest. Never infer this from `--only`, a partial log, or a remembered receipt. Report default and pinned outputs side-by-side, with the Node executable/version and receipt path attached to each.
5. Keep the 13 pinned positive cannon rows distinct from the six cannon negative controls: the battery has 19 `r94_cannon_*` rows total, but only 13 positives carry the Node marker. Do not treat the whole prefix as an expected-failure set.

## Evidence run by this seat

- `git status --short && git rev-parse --short HEAD && node --version && command -v node && PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version` → HEAD `1eaa568`; default `v26.12.0`, `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`; prefixed `v24.21.0`.
- `git status --short -- corpus/fixtures reports/round-105/n24/adversary.md corpus/live && node -p 'process.execPath' && PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node -p 'process.execPath'` → default executable `/home/vgpnk/.local/share/mise/installs/node/26.12.0/bin/node`; prefixed executable `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node`; status output was empty before this report was written.
- `sha256sum corpus/fixtures/run_battery.py && python3 - <<'PY' ... ast.literal_eval(CASES) ... PY` → SHA-256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`; `CASES 350`.
- `python3 - <<'PY' ... count r94_cannon rows, expected-exit-0 markers containing node=v24.21.0, expected-exit-2 ... PY` → `r94_cannon rows=19`, `positive pinned node rows=13`, `negative controls=6`.
- `python3 - <<'PY' ... print fixture lines 15–16 and runner lines 1265–1285 ... PY` → fixture states `node` resolves via inherited PATH and marker pins its version; runner records the exact Godot invocation, stdout, stderr, verdict and marker in each receipt.
- `python3 - <<'PY' ... read the two verdicts.json receipts ... PY` → `corpus/live/runs/20261018T202715395926Z/verdicts.json`: PASS, 1 case, `r94_cannon_nan` PASS, output `node=v24.21.0`; `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json`: FAIL, 350 cases, 337 pass/13 fail, `r94_cannon_nan` FAIL with `exact stdout marker missing`, output `node=v26.12.0`, expected marker `v24.21.0`.
- `python3 corpus/fixtures/run_battery.py --help` → runner exposes `--godot`, `--runs`, `--only` and probes; no Node-version selection option. No battery was run by this seat.
