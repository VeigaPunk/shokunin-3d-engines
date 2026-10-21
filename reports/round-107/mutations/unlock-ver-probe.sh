#!/usr/bin/env bash
# r107 UNLOCK-VER — independent unlock probes for wukakuki/unreal-engine:dev-slim-5.8.3
# Bounded, non-interactive, no license acceptance, no engine build.
set -u
IMG="wukakuki/unreal-engine:dev-slim-5.8.3"
LOG=/var/tmp/r107-unlock-ver/probe-transcript.txt
: > "$LOG"
say() { echo "$*" | tee -a "$LOG"; }

say "=== r107-unlock-ver probe transcript $(date -Is) ==="

say ""
say "--- P1: image identity / digest ---"
docker image inspect "$IMG" --format 'Id={{.Id}} Digests={{.RepoDigests}} Size={{.Size}} Created={{.Created}}' 2>&1 | tee -a "$LOG"

say ""
say "--- P2: config (user/workdir/cmd/entrypoint/labels) ---"
docker image inspect "$IMG" --format 'User={{.Config.User}} WorkDir={{.Config.WorkingDir}} Cmd={{json .Config.Cmd}} Entrypoint={{json .Config.Entrypoint}} Labels={{json .Config.Labels}}' 2>&1 | tee -a "$LOG"

say ""
say "--- P3: documented build-history editor-target line (from image) ---"
docker history --no-trunc "$IMG" 2>/dev/null | grep -i -E "Build.sh|print-editor-target" | head -3 | tee -a "$LOG"

say ""
say "--- P4: engine binary presence (filesystem listing only; no execution) ---"
docker run --rm --entrypoint /bin/bash "$IMG" -c '
  set -u
  echo "whoami=$(whoami) pwd=$(pwd)"
  echo "UNREAL_ENGINE_ROOT=$UNREAL_ENGINE_ROOT"
  ls -la "$UNREAL_ENGINE_ROOT/Engine/Binaries/Linux/" 2>&1 | head -40
  echo "--- UnrealEditor-Cmd present? ---"
  ls -la "$UNREAL_ENGINE_ROOT/Engine/Binaries/Linux/UnrealEditor-Cmd" 2>&1
  echo "--- UnrealEditor present? ---"
  ls -la "$UNREAL_ENGINE_ROOT/Engine/Binaries/Linux/UnrealEditor" 2>&1
' 2>&1 | tee -a "$LOG"

say ""
say "--- P5: MCP plugin presence (the r101 open question G2) ---"
docker run --rm --entrypoint /bin/bash "$IMG" -c '
  R="$UNREAL_ENGINE_ROOT"
  echo "--- Plugins dir ---"
  ls "$R/Engine/Plugins/" 2>&1 | head -40
  echo "--- ModelContextProtocol anywhere ---"
  find "$R" -maxdepth 6 -iname "*ModelContextProtocol*" 2>/dev/null | head -20
  echo "--- AllToolsets anywhere ---"
  find "$R" -maxdepth 6 -iname "*AllToolsets*" 2>/dev/null | head -20
  echo "--- MCP dirs ---"
  find "$R/Engine/Plugins" -maxdepth 3 -type d -iname "*mcp*" 2>/dev/null | head -20
' 2>&1 | tee -a "$LOG"

say ""
say "--- P6: DOCUMENTED HEADLESS EDITOR INVOCATION (the seat's key probe) ---"
say "pattern source: upstream/skills/create-toolset/SKILL.md:404 -> UnrealEditor-Cmd <Project>.uproject -ExecCmds=... -Unattended -NullRHI"
say "linux form: \$UNREAL_ENGINE_ROOT/Engine/Binaries/Linux/UnrealEditor-Cmd"
docker run --rm --entrypoint /bin/bash "$IMG" -c '
  set -u
  BIN="$UNREAL_ENGINE_ROOT/Engine/Binaries/Linux/UnrealEditor-Cmd"
  echo "=== P6a: bare --help / -help class probe (bounded 90s) ==="
  timeout 90 "$BIN" -help 2>&1 | head -40
  echo "P6a_exit=$?"
  echo ""
  echo "=== P6b: version probe ==="
  timeout 90 "$BIN" -version 2>&1 | head -20
  echo "P6b_exit=$?"
' 2>&1 | tee -a "$LOG"

say ""
say "=== probe transcript end $(date -Is) ==="
