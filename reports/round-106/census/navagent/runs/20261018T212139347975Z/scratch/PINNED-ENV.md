# Pinned Node runtime for the fixture battery

Thirteen `r94_cannon_*` case markers pin the Node version token to `v24.21.0`. The fixture reads `node --version` through its inherited `PATH`, and the battery compares the resulting output with the literal marker. Keep the fixtures and marker literals unchanged; select the pinned runtime for the invocation instead.

From the repository root, run the full battery with the fnm Node 24.21.0 installation first on `PATH`:

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py
```

This is a command-scoped `PATH` override: it applies to Python and the child processes it launches, without changing the shell's persistent environment or fnm/mise configuration. To check the selected executable before running:

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
# v24.21.0
```

## Interpreting the default-environment result

On this host, plain `node` resolves to `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node` (`v26.12.0`). The r104 default-environment full-battery report records 337/350 passing and 13 `r94_cannon_*` rows rejected for `exact stdout marker missing`: their expected markers say `node=v24.21.0`, while the observed output says `node=v26.12.0`. This is `PATH` shadowing, not fixture drift; see `reports/round-104/physics/full-regression.md` §3.3.

The L1 probe receipt `corpus/live/runs/20261018T202715395926Z/verdicts.json` records `r94_cannon_nan` as PASS with exit 0, the `node=v24.21.0` marker and `seeds_unchanged=true`. That receipt covers one case only; it is not evidence that a complete 350-case run passed. A full run writes its receipts under `corpus/live/runs/<timestamp>/` by default, as described in `README.md`.
