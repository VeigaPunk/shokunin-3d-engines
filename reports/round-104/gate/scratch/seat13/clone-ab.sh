#!/usr/bin/env bash
# Non-invasive clone-location A/B: same git command, two destinations.
# Proves whether the gate's CHECK 2 flake is a /tmp (tmpfs) write failure
# misreported by the gate as "upstream unreachable".
set -u
REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
OUT=$HERE/out
mkdir -p "$OUT"

trial() {  # $1=label $2=parent dir
  local label=$1 parent=$2 ok=0 fail=0 i rc
  for i in 1 2 3 4 5 6; do
    local w; w=$(mktemp -d "$parent/trial.XXXXXX")
    timeout 180 git clone --quiet "$REPO" "$w/clone" >"$w/log" 2>&1
    rc=$?
    if [ "$rc" -eq 0 ]; then ok=$((ok+1)); else
      fail=$((fail+1)); printf '%s trial%s rc=%s :: %s\n' "$label" "$i" "$rc" \
        "$(head -1 "$w/log")" >>"$OUT/clone-ab.errors"
    fi
    rm -rf "$w"
  done
  printf '%s: ok=%s fail=%s\n' "$label" "$ok" "$fail"
}

: >"$OUT/clone-ab.errors"
echo "df /tmp: $(df -h /tmp | tail -1)"
mkdir -p "$HERE/localtmp"
printf 'TMPDIR=/tmp        '; trial "/tmp" /tmp
printf 'repo-local scratch '; trial "local" "$HERE/localtmp"
echo "--- errors ---"; cat "$OUT/clone-ab.errors"
