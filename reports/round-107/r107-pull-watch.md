# r107-pull-watch — W-CRON seat (3D side-round, round 107)

Plan (5 lines):
1. Attach read-only to the already-running `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` (pid 596299, log `/var/tmp/ue-pull.log`, started ~00:07 by a pre-existing unlock attempt).
2. Snapshot every ~120s: wall clock, log bytes, layer counts, **byte-accurate downloaded bytes** (log layer prefixes resolved against the registry manifest's per-layer sizes), free space, process liveness, image presence.
3. Record each snapshot as one table row with the exact command that produced it.
4. Stop at image completion, pull failure, or the 40-min cap from pull start (~00:47), whichever first.
5. Emit final verdict: docker-unlock PROVEN (image present + bounded probe runnable) or UNPROVEN-with-attempt-log (this file is that attempt log).

STATUS: **DONE** — pull completed 00:18:10; image present; bounded probe booted the engine; verdict = **PROVEN-with-evidence** (see §VERDICT).

## [O] Setup facts (baseline)

Commands:
```
ps aux | grep -E "docker pull" | grep -v grep
docker images
docker system df
docker info --format '{{.DockerRootDir}}'
stat -c '%s %y' /var/tmp/ue-pull.log
date -Is
```
Observed 2026-10-19T00:08:53-03:00:
- `vgpnk 596299 ... docker pull wukakuki/unreal-engine:dev-slim-5.8.3` — **alive**, started 00:07.
- Wrapper shell 596297 has cwd `/home/vgpnk/Projects/shokunin/game-dev-2d-shokunin` → the pull was launched from the 2D lane as the pre-existing unlock attempt. This seat observes read-only; no writes to that lane.
- `docker images`: alpine:latest, ds4cc-linux-floor:22.04, node:22-bookworm, rust:1-bookworm, ubuntu:24.04 → **no unreal-engine image yet** (pull incomplete).
- `docker system df`: 5 images, 4.656GB total, 0 containers, 0 build cache.
- Docker root `/var/lib/docker` is **0700 root** → `du` as non-root fails (Permission denied). Byte proxy = `df -B1 avail` on that filesystem.

## [O] Ground truth for bytes (registry manifest)

`docker pull` without a TTY prints only discrete `Download complete` / `Pull complete` lines — no byte counters. So byte progress is derived from the registry manifest.

Command (registry API v2, anonymous pull token):
```
TOK=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:wukakuki/unreal-engine:pull" | python3 -c 'import sys,json;print(json.load(sys.stdin)["token"])')
curl -s -H "Authorization: Bearer $TOK" \
  -H 'Accept: application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.docker.distribution.manifest.v2+json' \
  "https://registry-1.docker.io/v2/wukakuki/unreal-engine/manifests/dev-slim-5.8.3" -o manifest.json -D headers.txt
```
Observed: `HTTP/2 200`, `content-type: application/vnd.docker.distribution.manifest.v2+json`, `content-length: 6636`,
`docker-content-digest: sha256:3f0886cf0d7e5bc9cea0e7ba27f417e0d0febb5ad0c371c9a89223c6112c80ef`,
`ratelimit-remaining: 98;w=3600`.
Manifest parse: `schemaVersion 2`, single-platform (v2 manifest, not a list), **layers=30, total_bytes=26791359421 (24.95 GiB)**.

The manifest is cached at `/var/tmp/r107-w-cron/manifest.json`; per-layer sizes at `layermap.tsv`
(shortid → bytes, all 30 rows). The log's 12-hex prefixes are exactly the manifest digests' first 12 hex chars,
so `Download complete` / `Pull complete` sets can be summed into real bytes.

Probe: `reports/round-107/mutations/w-cron-snapshot.sh` (read-only; emits one line per snapshot to `/var/tmp/r107-w-cron/csv.txt`).

## [O] Snapshot log

Byte columns: `dl_MiB` = Σ sizes of layers logged `Download complete`; `pull_MiB` = Σ sizes of layers logged `Pull complete`.
`avail_GiB` = free space on the docker-root filesystem (byte proxy; decreases as layers land).

| # | t (local) | elapsed | log_B | dl_MiB | pull_MiB | dl_layers | pull_layers | avail_GiB | alive | ue_img |
|---|-----------|---------|-------|--------|----------|-----------|-------------|-----------|-------|--------|
| 0 | 00:08:53 | +1:5x | 2142 | — | — | 24 | 11 | — | yes | 0 |
| 1 | 00:09:40 | +2:4x | 2326 | 4718.6 | 388.7 | 25 | 14 | 747.8 | yes | 0 |
| 2 | 00:09:51 | +2:5x | 2326 | 6852.8 | 459.2 | 28 | 16 | 744.3 | yes | 0 |
| 3 | 00:11:39 | +4:4x | 2414 | 12495.2 | 6709.6 | 29 | 18 | 728.7 | yes | 0 |
| 4 | 00:13:54 | +6:5x | 2470 | 12495.2 | 9683.0 | 29 | 20 | 737.6 | yes | 0 |
| 5 | 00:15:54 | +8:5x | 2470 | 12495.2 | 9683.0 | 29 | 20 | 742.8 | yes | 0 |
| 6 | 00:16:29 | +9:3x | 2502 | 25550.1 | 9683.0 | **30** | 20 | 741.5 | yes | 0 |
| 7 | 00:17:54 | +10:5x | 2530 | 25550.1 | 22738.0 | 30 | 21 | 726.4 | yes | 0 |
| 8 | 00:18:10 | +11:1x | 2983 | 25550.1 | 26791.4 | 30 | 30 | — | **done** | **1** |

Commands per row: rows 0–5,7 from `mutations/w-cron-snapshot.sh` (probe above); row 6 same probe
(`t=2026-10-19T00:16:29 ... dl_bytes=26791359421 pull_bytes=10153464904 dl_layers=30 pull_layers=20`).
MiB columns are the raw byte fields / 2^20. Row 8 is the completion transition (below), not a probe line.

Note the `dl_MiB` plateau at 12,495.2 for snapshots 3–5: the client was streaming the 12.75 GiB layer
`7a31e2ef5f97`, which only flips to `Download complete` once fully received — so the discrete-log byte
metric steps, it does not ramp. Snapshot 6 (`dl_layers=30`) is the moment that layer landed.

## [O] Completion (final state)

Watch loop (10 s poll, exits on image presence or pull-process exit):
```
for i in $(seq 1 28); do
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q 'unreal-engine'; then echo "IMAGE PRESENT at $(date -Is)"; break; fi
  if ! pgrep -f '^docker pull wukakuki/unreal-engine' >/dev/null; then echo "PULL PROCESS GONE at $(date -Is)"; break; fi
  sleep 10
done
```
Observed: `IMAGE PRESENT at 2026-10-19T00:18:10-03:00`. Log tail:
```
be14838c5a11: Pull complete
Digest: sha256:3f0886cf0d7e5bc9cea0e7ba27f417e0d0febb5ad0c371c9a89223c6112c80ef
Status: Downloaded newer image for wukakuki/unreal-engine:dev-slim-5.8.3
docker.io/wukakuki/unreal-engine:dev-slim-5.8.3
```
[O] `docker images --format '{{.Repository}}:{{.Tag}} | id={{.ID}} | size={{.Size}}'` →
`wukakuki/unreal-engine:dev-slim-5.8.3 | id=3f0886cf0d7e | size=97.9GB` (97.9 GB = uncompressed on-disk; manifest's 24.95 GiB is the compressed transfer size).
[O] `docker image inspect` (via `/var/tmp/r107-w-cron/inspect.py`): `Id sha256:3f0886cf0d7e5bc9cea0e7ba27f417e0d0febb5ad0c371c9a89223c6112c80ef`, `RepoDigests ['wukakuki/unreal-engine@sha256:3f0886cf…c80ef']`, `Arch amd64 linux`, `Size_bytes 26791384544`, `RootFS_layers 30`.
**The pulled digest is byte-for-byte the manifest digest fetched independently at 00:09** — the image the registry advertised is the image that landed.

[O] `docker pull` process exited (`pgrep -f '^docker pull wukakuki/unreal-engine'` → no match).
[O] Total wall clock: 00:07 (start, from ps) → 00:18:10 ≈ **11 min**, well inside the 40-min cap.
[O] Free space after: 706 GiB (`df -h --output=avail /var/lib/docker`); `docker system df` → Images 102.5GB total, 1 active.

## [O] Bounded smoke probe — engine boots, version 5.8.3 (probe B)

No license acceptance, no engine build, no GUI, no extra network; bounded with `timeout`. Probe A (tree) confirmed layout; probe B is the load-bearing one:

```
timeout 160 docker run --rm --entrypoint /bin/bash wukakuki/unreal-engine:dev-slim-5.8.3 -lc '
cd "$UNREAL_ENGINE_ROOT"
sha256sum Engine/Binaries/Linux/UnrealEditor-Cmd
timeout 60 ./Engine/Binaries/Linux/UnrealEditor-Cmd -version -unattended -nopause -nullrhi -nosplash
'
```
Observed [O]:
- `sha256(bin)=2f1f54de5d9857cd329232a997ed20cd454d05e8d580f94ac0bf2f7d7c44084c`
- The editor **started** and emitted engine metadata before the inner 60 s timeout:
  `LogCsvProfiler: Display: Metadata set : engineversion="5.8.3-58210709+++UE5+Release-5.8"`
  `... buildversion="++UE5+Release-5.8-CL-58210709"` / `enginereleaseversion="5.8.3"`
  `... os="Ubuntu 22.04.2 LTS"`, `LogInit: Display: Running engine without a game`,
  `LogCore: UTS: Unreal Trace Server launched successfully`.
- `PROBE_B_EXIT=124` → the inner `timeout` killed it after 60 s (the editor does not exit on `-version`
  alone; it keeps running headless). That is an expected bounded termination, not a crash.
- `Engine/Build/Build.version`: `{"MajorVersion":5,"MinorVersion":8,"PatchVersion":3,"Changelist":58210709,"IsPromotedBuild":1,"BranchName":"++UE5+Release-5.8"}`.
- `UNREAL_ENGINE_ROOT=/home/ue4/UnrealEngine`; binaries present: `UnrealEditor`, `UnrealEditor-Cmd`,
  `ShaderCompileWorker`, `UnrealPak`-class tools; `Engine/Extras/ushell/ushell.sh` present.
- Container user `ue4`, hostname `18759821c403`.

## [O] VERDICT: docker-unlock PROVEN-with-evidence

The docker route to a UE 5.8.3 runtime is **proven**:
1. `wukakuki/unreal-engine:dev-slim-5.8.3` is present locally, id `3f0886cf0d7e`, digest
   `sha256:3f0886cf0d7e5bc9cea0e7ba27f417e0d0febb5ad0c371c9a89223c6112c80ef`, matching the registry manifest
   fetched independently before the pull finished.
2. A bounded, non-interactive container probe ran the editor binary, which reported
   `engineversion="5.8.3-58210709+++UE5+Release-5.8"` and `os="Ubuntu 22.04.2 LTS"`.
3. No license acceptance, no login, no engine build was needed for the probe; the only network use was
   the anonymous registry pull.

Scope limits [I]: this proves the *image is present and the editor process starts headless*. It does NOT
prove a full editor UI session, project compile, or GPU rendering — no such claim is made here. The
verdict above is deliberately limited to "image present + editor boots + version reported".

## [O] Hygiene

- This seat wrote only to `/var/tmp/r107-w-cron/` (scratch) and
  `reports/round-107/{r107-pull-watch.md,mutations/w-cron-snapshot.sh}` — **no writes to
  `corpus/knowledge/unreal-mcp/`** and none to the 2D lane.
- Two containers `magical_austin` / `funny_moore` (both `wukakuki/unreal-engine:dev-slim-5.8.3`, created
  00:18:23/00:18:26) belong to **peer unlock seats** (my probes used `--rm` and exited). Left untouched.
- The sampler background loop was stopped once the image landed; no orphaned samplers remain.
- Incident (disclosed): the Bash tool's cwd is the **2D lane**, so three initial relative-path writes
  (`reports/round-107/r107-pull-watch.md`, `mutations/snapshot.sh`, `mutations/snapshot2.sh`) landed in
  `game-dev-2d-shokunin`. All three were removed; the one other file there (`r107-planner.md`, another
  seat's) was left untouched. All subsequent writes used absolute 3D paths.

## [O] Throughput measurement (free-space proxy, 5 s resolution)

The pull log emits no byte counters mid-layer, so instantaneous throughput was measured as the
rate of `df -B1 avail /var/lib/docker` decrease (layers land uncompressed into the store).

Command:
```
for i in $(seq 1 13); do printf '%s %s\n' "$(date +%H:%M:%S)" "$(df -B1 --output=avail /var/lib/docker | tail -1 | tr -d ' ')"; sleep 5; done
```
Observed series (`burst.txt`), bytes avail:
```
00:10:08 798337183744   00:10:33 796668477440   00:10:53 792707239936
00:10:13 798337183744   00:10:38 796631314432   00:10:58 791884607488
00:10:18 798337183744   00:10:43 795720511488   00:11:03 791340032000
00:10:23 798337183744   00:10:48 793469669376   00:11:08 789634551808
00:10:28 798337183744
```
Derived [O]:
- 60 s window (00:10:08→00:11:08): consumed 8,702,631,936 B → **145.0 MB/s (138.3 MiB/s)**.
- Steady segment (00:10:33→00:11:08, 35 s): **201.0 MB/s**.
- 00:10:08–00:10:28 shows zero consumption → the client was finishing an earlier layer / opening the
  next one, not stalled (log advanced at 00:10:32 with `3fc5ed8760e3: Download complete`).

## [I] Reading

- At snapshot 3, 29 of 30 layers are downloaded (12,495 MiB of 24,953 MiB = **50.1 % by bytes**)
  and 18 are unpacked (6,710 MiB). The image is not yet in `docker images` (`ue_img=0`), so the pull
  is genuinely incomplete, not merely unlisted.
- The only layer never seen as downloaded is `7a31e2ef5f97` (13,689,053,562 B = 12.75 GiB) — the
  dominant layer. The 5.9 GiB layer `3fc5ed8760e3` completed at 00:10:32; since then consumption
  is the big layer streaming in.
- Projection [I, not a guarantee]: at the observed 145–201 MB/s, the remaining ~13.7 GiB needs roughly
  **70–95 s** of steady transfer, plus unpack time for the large layers. That lands well inside the
  40-min cap (≈00:47); the pull should complete around 00:13–00:16 if throughput holds.
- Free space is not a constraint (≈729 GiB avail; image needs ≈25 GiB).

## [O] Liveness check

- `pgrep -f '^docker pull wukakuki/unreal-engine'` → `596299` at every snapshot (alive).
- No error/denied/unauthorized lines in the log at any snapshot (`grep -icE 'error|denied|unauthorized|not found'` → 0).
- No `wukakuki/unreal-engine` image in `docker images` yet.
