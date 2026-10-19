# Lane operations — Cursor provider (Kimi Code CLI)

How Kimi Code CLI reaches Cursor models on this host, and what to do when the
lane misbehaves. Persisted 2026-10-18 after a production wedge during a fleet
round. The authoritative mechanism for every lane is systemd user services;
this file is the cursor lane's runbook.

## Request path (how a `cursor/*` model call flows)

1. Kimi config `~/.kimi-code/config.toml` maps `cursor/*` model entries to
   `[providers.cursor]`: `base_url = "http://127.0.0.1:8788/v1"`,
   `api_key = "cursor-local"` — the key is a placeholder; **OAuth is not
   Kimi's business**.
2. Port 8788 is `cursor-shim.service` (systemd user):
   `~/.local/share/cursor-shim/shim.py` — an OpenAI-compatible translation
   layer over Cursor's native agent backend (`ExecStart` in the unit; env
   `CURSOR_SHIM_PORT=8788`, `CURSOR_SHIM_MAX_CONCURRENT=128`).
3. The shim drives the `cursor-agent` CLI (`~/.local/bin/cursor-agent`).
   Cursor OAuth lives in the CLI's own state: `~/.config/cursor/auth.json`
   and `~/.cursor/agent-cli-state.json`. Never copy cursor tokens into
   `config.toml`; never touch the CLI's auth files — renew/login is
   operator-owned (`cursor-agent` handles it).
4. Model id mapping (config entries → wire ids): `cursor/grok-4.7-xhigh-fast`
   → `grok-4.7-xhigh-fast` (500k ctx), `cursor/opus-5.5` →
   `claude-opus-5-5-high`, `cursor/composer-2.5-fast` → `composer-2.5-fast`.

## Failure mode: the wedge (observed 2026-10-18)

Symptom: every `cursor/*` subagent hangs and eventually fails; direct
`cursor-agent -p PONG` works fine. Cause: the shim **process stays alive and
keeps answering `/health`, but chat completions hang past 60 s** — stuck
backend sessions pile up (visible as many `CLOSE_WAIT` sockets on :8788).
`Restart=on-failure` does not save you: a wedged process is not a failure to
systemd. Do not trust the shim's `/health` — it is a static handler and
cannot detect this class.

## Recovery (in order)

```sh
# 1. Confirm the wedge: chat probe must hang or fail while /health answers
timeout 60 curl -s http://127.0.0.1:8788/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"grok-4.7-xhigh-fast","messages":[{"role":"user","content":"PONG"}],"max_tokens":8}'
# 2. Restart the shim
systemctl --user restart cursor-shim
# 3. Verify both seats answer (grok + opus)
timeout 90 curl -s http://127.0.0.1:8788/v1/chat/completions -H 'Content-Type: application/json' \
  -d '{"model":"claude-opus-5-5-high","messages":[{"role":"user","content":"PONG"}],"max_tokens":16}'
# 4. Check the healthcheck timer is running
systemctl --user list-timers cursor-shim-healthcheck.timer
```

## Persistence (already in place — do not duplicate)

`cursor-shim-healthcheck.timer` (systemd user, 60 s) runs
`~/.local/share/cursor-shim/healthcheck.sh`: cheap `/health` probe every
minute; real chat-completion probe every 10 min (the only probe class that
catches a wedge); restarts the shim, rate-limited to 1 per 10 min (state in
`~/.local/state/cursor-shim/`). If a future wedge persists past a healthcheck
cycle, restart the shim manually and check `journalctl --user -u
cursor-shim-healthcheck.service` for why the probe missed it.

## Operating rules for fleet rounds

- Before dispatching a big swarm on `cursor/*`: `systemctl --user is-active
  cursor-shim` and one PONG probe. A hung probe = wedge; restart first.
- Do not edit the `[providers.cursor]` block or model entries while the shim
  is running; restart the shim after any such edit.
- The shim caps at `CURSOR_SHIM_MAX_CONCURRENT=128` concurrent requests;
  a 128-seat swarm saturates it — expect queueing, and treat mass
  hangs (not slow streams) as the wedge signal, not as model latency.
- If the CLI itself breaks (auth errors in shim logs, `cursor-agent` fails
  standalone): that is operator territory — surface it, do not improvise
  around OAuth.
