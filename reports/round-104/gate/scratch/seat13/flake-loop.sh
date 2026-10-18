#!/usr/bin/env bash
# Flake-reproduction loop: N clone attempts into /tmp, logging df/quota state at
# each attempt. On failure, immediately retry a RAW write of the same size to
# distinguish ENOSPC/EDQUOT from a network fault. Read-only w.r.t. the gate.
set -u
REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
OUT=$HERE/out
mkdir -p "$OUT"
N=${1:-20}
ok=0; fail=0

for i in $(seq 1 "$N"); do
  avail=$(df -Pk /tmp | awk 'NR==2{print $4}')
  inodes=$(df -Pi /tmp | awk 'NR==2{print $4}')
  w=$(mktemp -d)
  timeout 180 git clone --quiet "$REPO" "$w/clone" >"$w/log" 2>&1
  rc=$?
  if [ "$rc" -eq 0 ]; then
    ok=$((ok+1)); printf 'attempt=%s rc=0 availKB=%s inodes=%s\n' "$i" "$avail" "$inodes"
  else
    fail=$((fail+1))
    printf 'attempt=%s rc=%s availKB=%s inodes=%s ERR="%s"\n' "$i" "$rc" "$avail" "$inodes" \
      "$(head -1 "$w/log")"
    # raw-write probe: can we still write a 64 MiB file to /tmp right now?
    if dd if=/dev/zero of="$w/probe.bin" bs=1M count=64 status=none 2>"$w/dd.err"; then
      printf '   raw-write-64MiB=OK (disk writable; clone fault was not ENOSPC)\n'
    else
      printf '   raw-write-64MiB=FAIL :: %s\n' "$(head -1 "$w/dd.err")"
    fi
    # network probe: is upstream reachable right now?
    if timeout 30 git ls-remote "$REPO" HEAD >/dev/null 2>&1; then
      printf '   ls-remote=OK (network up; BLOCKED label is a MISDIAGNOSIS)\n'
    else
      printf '   ls-remote=FAIL (network genuinely down)\n'
    fi
  fi
  rm -rf "$w"
done
printf '\nTOTALS attempts=%s ok=%s fail=%s\n' "$N" "$ok" "$fail"
