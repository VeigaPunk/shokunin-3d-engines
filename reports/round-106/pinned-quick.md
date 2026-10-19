# SEAT-88 PINNED-QUICK — r106

Axes: depth (one pinned-env cannon rerun), coverage (row identity plus which Node binary actually ran), calibration (observed marker vs the live `CASES` literal, receipt hashes resolvable).

Scope: one positive cannon row, `r94_cannon_nan`, under the fnm Node 24.21.0 PATH prefix. Expect PASS. Not a 350-row recount. No fixture edits. No default-env battery run (that is SEAT-87). HEAD at run time `0cc3f4162f8c319f8d01a69a174fe939f36701bd`.

## Verdict

| Probe | Env | Expected | Observed | Match |
|---|---|---|---|---|
| `r94_cannon_nan` | fnm Node v24.21.0 prefixed on `PATH` | PASS, exit 0, marker token `node=v24.21.0` | battery exit 0; row PASS; marker byte-exact (2546 bytes); `seeds_unchanged=true` | yes |

Spot check holds: the pinned runtime still passes this cannon row. This is not a 350/350 claim.

## Environment actually observed

Preflight, same process tree as the battery, captured in the stdout receipt:

```text
=== preflight 2026-10-18T21:20:35Z ===
HEAD=0cc3f4162f8c319f8d01a69a174fe939f36701bd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
d40a1f75739626778d13115eced5202bf9bd6ab5643e46e92a8973b495a05c77  corpus/fixtures/r94_cannon.gd
default_node=/home/vgpnk/.local/share/mise/installs/node/latest/bin/node v26.12.0
pinned_node_path=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
v24.21.0
```

Default `node` on this host remains mise `v26.12.0`. The case ran only after the fnm `v24.21.0` `bin` was prefixed. Godot, from the verdict JSON: `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` (version exit 0). Scratch was `mktemp -p "$HOME"` then copied; `/tmp` was not used.

## Command run

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
  python3 corpus/fixtures/run_battery.py --only r94_cannon_nan \
  --runs /home/vgpnk/r106-seat88-TxEMRh
```

Observed terminal (also lines 9–16 of the stdout receipt):

```text
=== battery 2026-10-18T21:20:35Z ===
PASS r94_cannon_nan: exit=0 expected=0

VERDICT  CASE                               SCRIPT                     FLAGS              EXIT      KIND
PASS     r94_cannon_nan                     r94_cannon.gd              --arm=nan          0/0       ordinary
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
PASS battery: /home/vgpnk/r106-seat88-TxEMRh/20261018T212035115165Z/verdicts.json
COMMAND_EXIT=0
```

Child elapsed, from the receipt: 0.896 s. `error=None`. `reasons=[]`. Command recorded in the receipt: `['/usr/bin/godot', '--headless', '--path', '/home/vgpnk/r106-seat88-TxEMRh/20261018T212035115165Z/scratch', '--script', 'res://r94_cannon.gd', '--', '--arm=nan']`.

## Receipt readout

Parser (did not rerun the battery), against the durable copy:

```text
$ python3 -c "… load verdicts.json; compare result marker to the live CASES literal for r94_cannon_nan …"
marker_exact True
stdout_line_exact True
n_stdout_pass_lines 1
exp_len 2546 obs_len 2546
node_token True v26_absent True
seeds True n_digests 131 pinned_env_in_map True
verdict PASS {'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
```

Fields read from that JSON: `only=r94_cannon_nan`, `started_utc=20261018T212035115165Z`, `seeds_unchanged=true`, `seed_digests` length 131 including `PINNED-ENV.md`, case `r94_cannon_nan` verdict `PASS` expected_exit 0 actual_exit 0. The observed marker begins `PASS r94_cannon nan node=v24.21.0` and equals the current `CASES` expected string (2546 bytes). No `v26` token in the marker.

## Durable copies and hashes

The runner directory `/home/vgpnk/r106-seat88-TxEMRh` was removed after the verdicts JSON and the combined stdout were copied. That path is in the stdout banner and in the JSON `scratch` field; it is not resolvable now (removed 2026-10-18T21:20Z, same minute as the run). The 11M fixture scratch copy that the runner wrote was not retained. Resolvable receipts:

| File | SHA-256 |
|---|---|
| `reports/round-106/scratch/seat88/seat88-pinned-quick-20261018T212035Z.stdout` | `08c6564a7358f6c8749ce5211519afa22c97f8711b72a5ccff4b257efd0bdd10` |
| `reports/round-106/scratch/seat88/seat88-pinned-quick-20261018T212035Z.verdicts.json` | `2c98d3b805bc8c49d522a8a45aa836745f14add91cf452796d5a223b3ff48e02` |

Those two hashes are also in `reports/round-106/scratch/seat88/SHA256SUMS`. `sha256sum` of the copies matched the table above before this report was written.

## What this does not claim

- Not a full battery. One of 13 positive cannon rows. The other 12 were not executed here.
- Not a default-env result. Default `node` was only version-probed (`v26.12.0`); the case ran under the prefix.
- Not a seed-tree mutation. Receipt has `seeds_unchanged=true`. After the run, `git diff --quiet -- corpus/fixtures/run_battery.py corpus/fixtures/r94_cannon.gd` exited 0. `run_battery.py` sha remained `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`. `r94_cannon.gd` sha `d40a1f75739626778d13115eced5202bf9bd6ab5643e46e92a8973b495a05c77`.
- No Unreal runtime claim. Editor not used. Godot used: `/usr/bin/godot` 4.7.2.stable.arch_linux.ed1daf0bf.

## Blockers

None. The expected pinned-env PASS landed.
