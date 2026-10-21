#!/usr/bin/env bash
# r107 pull-watch snapshot probe — byte-accurate, read-only.
# Resolves the docker pull log's 12-hex layer prefixes against the registry
# manifest (fetched once into $WORK/manifest.json, sizes cached in layermap.tsv)
# to compute real downloaded bytes. Usage: snapshot2.sh
set -u
WORK=/var/tmp/r107-w-cron
LOG=/var/tmp/ue-pull.log
MAP=$WORK/layermap.tsv
DR=$(docker info --format '{{.DockerRootDir}}' 2>/dev/null)
T=$(date -Is)
LOG_BYTES=$(stat -c '%s' "$LOG" 2>/dev/null || echo NA)
DL=$(grep -c 'Download complete' "$LOG" 2>/dev/null || echo 0)
PC=$(grep -c 'Pull complete' "$LOG" 2>/dev/null || echo 0)
AVAIL=$(df -B1 --output=avail "$DR" 2>/dev/null | tail -1 | tr -d ' ')
# actual docker pull process (exclude the wrapper shell)
PID=$(pgrep -f '^docker pull wukakuki/unreal-engine' | head -1)
ALIVE=$([ -n "$PID" ] && echo yes || echo no)
IMGS=$(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -c unreal-engine || true)
BYTES=$(python3 - "$LOG" "$MAP" <<'PY'
import re,sys
log=open(sys.argv[1]).read()
sizes={}
for line in open(sys.argv[2]):
    a,b=line.split()
    sizes[a]=int(b)
done=set(re.findall(r'^([0-9a-f]{12}): Download complete',log,re.M))
pulled=set(re.findall(r'^([0-9a-f]{12}): Pull complete',log,re.M))
db=sum(sizes[s] for s in done if s in sizes)
pb=sum(sizes[s] for s in pulled if s in sizes)
print(f"dl_bytes={db} pull_bytes={pb} dl_layers={len(done)} pull_layers={len(pulled)}")
PY
)
echo "t=$T alive=$ALIVE pid=${PID:-none} ue_images=$IMGS log_bytes=$LOG_BYTES dl_done=$DL pull_done=$PC avail_bytes=$AVAIL $BYTES"
