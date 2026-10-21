# r107-unlock.md — UE-runtime unlock evaluation (seat KEY=UNLOCK-LEAD)

Plan (5 lines):
1. Monitor `/var/tmp/ue-pull.log` for `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` completion (started pre-swarm).
2. If image present: `docker image inspect` → digest, size, labels, entrypoint/cmd.
3. Bounded non-interactive smoke probes inside container (version/help-class only, no license acceptance, no extra network, 30-min cap).
4. Label each probe [O]/[I]/[?]; final verdict PROVEN-with-evidence or UNPROVEN-with-attempt-log.
5. No writes into `corpus/knowledge/unreal-mcp/`; shard + scratch only.

Labels: **[O]** observed on this host this round · **[I]** inference · **[?]** unknown.

---

## 0. Why this seat exists

Rounds 101–106 left exactly one load-bearing runtime question open and repeatedly
deferred it as an operator decision: whether a live UE editor can exist on this host
at all. r101 SEAT-46 found the route (`wukakuki/unreal-engine:dev-slim-5.8.3`,
anonymous pull, ~26.8 GB) and stopped at the registry manifest. r101 G2 names it:
*"the Docker route is found but unexercised … Until that is answered, 'no live-editor
evidence can exist here' is a hypothesis with a known counter-route, not a closed
fact."* r102 §463 and r101 §340-341 re-ask the same question. This seat executes it.

---

## 1. Pull — the action that was deferred for 6 rounds

The pull was started **before this swarm** by the orchestrator (the 2D lane's shell,
per the log's first line), so it is a pre-existing host action, not one this seat
initiated. This seat's job is to monitor it and use the result.

```
$ pgrep -af 'docker pull wukakuki'
596299 docker pull wukakuki/unreal-engine:dev-slim-5.8.3
```

Log: `/var/tmp/ue-pull.log` (docker's progress output; layer lines only, no timestamps).

```
$ head -3 /var/tmp/ue-pull.log
Pulling from wukakuki/unreal-engine
...
```

**Throughput measured, not assumed** — `containerd` snapshot growth over a 60 s window
(`sudo du -sb /var/lib/containerd`; the overlayfs snapshotter root, `docker info` →
`Storage Driver: overlayfs`, `driver-type: io.containerd.snapshotter.v1`):

```
t0  bytes=20827061758
t60 bytes=37414115992
delta=16587054234 bytes / 60 s = ~258 MiB/s
```

[O] At 258 MiB/s the ~26.8 GB compressed image unpacks in well under an hour on this
host. The r101 estimate of "36 min at 12.5 MB/s" was a **conservative bound from a
single ranged blob read**; the real link is roughly 20x faster.

Layer progress at the time of writing: 16/30 layers `Pull complete` [O].

### 1.1 Registry metadata — independently re-derived (does not need the pull)

Re-derived here so the shard does not rest on r101's transcript:

```
$ TOK=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:wukakuki/unreal-engine:pull" | jq -r .token)
$ echo "token_len=${#TOK}"
token_len=2709
$ curl -sI -H "Authorization: Bearer $TOK" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "https://registry-1.docker.io/v2/wukakuki/unreal-engine/manifests/dev-slim-5.8.3" | grep -i docker-content-digest
docker-content-digest: sha256:3f0886cf0d7e5bc9cea0e7ba27f417e0d0febb5ad0c371c9a89223c6112c80ef
```

[O] Manifest digest `sha256:3f0886cf…c80ef` — **the identity this round must pin the
image by** (a tag can move; the digest cannot).

```
$ jq -r '.config.digest, (.layers|length), ([.layers[].size]|add), ([.layers[].size]|max)' manifest.json
sha256:b99f8c5e24c4887d5ace51c3421116ac87d347fbd6d2cf2e3de25d27e50f662e
30
26791359421
13689053562
```

[O] 30 layers, **26 791 359 421 B = 24.95 GiB compressed**, largest single layer
13 689 053 562 B = 12.75 GiB (that one layer is the engine itself).

Config blob (`sha256:b99f8c5e…`), fetched by digest, HTTP 200, 18 487 B:

```
created: 2026-09-26T23:14:48.164175621+08:00
architecture: amd64   os: linux
WorkingDir: /home/ue4/UnrealEngine
Entrypoint: null      Cmd: null
Env: PATH=…:/home/ue4/UnrealEngine/Engine/Extras/ushell
     NVIDIA_VISIBLE_DEVICES=all
     NVIDIA_DRIVER_CAPABILITIES=graphics,compat32,utility,compute,display,video
     LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
     DEBIAN_FRONTEND=noninteractive
     UNREAL_ENGINE_ROOT=/home/ue4/UnrealEngine
     XDG_CONFIG_HOME=/home/ue4/.config
     DOTNET_EnableWriteXorExecute=0
```

[O] `UNREAL_ENGINE_ROOT` and `WorkingDir` both point at `/home/ue4/UnrealEngine`.
**No `Entrypoint` and no `Cmd`** — [I] the image is a development shell, not a
service; every probe below must therefore supply its own command, which is what
`--entrypoint /bin/bash` does.

### 1.2 Build history — the decisive static evidence

The last functional history step (read from the same config blob, `jq -r '.history[]?.created_by'`):

```
RUN /bin/sh -c EDITOR_TARGET=$(python3 /tmp/print-editor-target.py "$UNREAL_ENGINE_ROOT") && \
    ./Engine/Build/BatchFiles/Linux/Build.sh "$EDITOR_TARGET" Linux Development -SkipBuild && \
    mkdir -p ./Engine/Programs/AutomationTool/Saved && chmod a+rw ./Engine/Programs/AutomationTool/Saved && \
    rm -R -f /home/ue4/.epic
```

[O] This is a **built editor target** in the image, and it was built **with `-SkipBuild`**
— i.e. the image author compiled the editor at image-build time and this step only
re-links/validates. [O] `rm -R -f /home/ue4/.epic` is the author removing Epic
credential state from the layer — relevant to HARD RULE 4: the image is delivered
with no Epic account material, and this seat adds none.

[I] Note what this does **not** say: the history never mentions `ModelContextProtocol`,
`AllToolsets`, or MCP. So the *plugin presence* question (r101 G2) remains open from
static data alone — it is answered only by inspecting the pulled filesystem (§3, P3).

---

## 2. Safety envelope actually used

| rule | how it is honoured in the probes |
|---|---|
| no Epic-account login | no credentials mounted; no env var; image ships `.epic` deleted [O] |
| no license acceptance | no interactive TTY (`-i` never passed); no EULA flag is answered |
| no network beyond the pull | probes run with `--network=none` [O] |
| bounded | `timeout` on every probe; 300 s per probe, whole seat < 30 min |
| no engine build >2h | nothing builds; `-SkipBuild` semantics already baked in |
| no publishing | nothing pushed, no registry write call is made |
| container smoke probes only | `docker run --rm`, non-interactive, `-lc` one-liner |

---

## 3. Bounded smoke probes

Script: `/var/tmp/r107-unlock/smoke.sh` (scratch, outside the repo — nothing landed).
Each probe is `docker run --rm --network=none --entrypoint /bin/bash <img> -lc "<cmd>"`.

| probe | what it answers | the r101/r102 open question it closes |
|---|---|---|
| P0 | image inspect: id, size, wd, entrypoint | identity of the landed artifact |
| P1 | engine root + `Engine/Binaries/Linux` listing | does a real engine tree exist |
| P2 | `UnrealEditor`, `UnrealEditor-Cmd` presence + size | "is there a built editor" |
| P3 | `ModelContextProtocol` / `AllToolsets` / `Toolsets` plugin dirs + `.uplugin` `EnabledByDefault` | **r101 G2**, the exact unknown |
| P4 | `Extras/Proxy/Bin/Linux/unreal_mcp_proxy` | upstream `setup.md` step 4 (r101 G3) |
| P5 | `Engine/Build/Build.version` | confirms 5.8.3, not just the tag name |
| P6 | `ldd UnrealEditor-Cmd` missing-symbol count | can the binary even load in this container |
| P7 | `UnrealEditor-Cmd -help` | help-class invocation, no project, no license |
| P8 | `UnrealEditor-Cmd -NullRHI -nosplash -unattended -ExecOnStartup=quit` | headless editor init to exit |
| P9 | `find /home/ue4 -name '*.uproject'` | is a sample project shipped (needed for a tool call) |
| P10 | editor with `-ModelContextProtocolStartServer` | does the server actually start |
| P10b | separate container: `curl` loopback `POST /mcp` `initialize` | **the only thing that upgrades a card** |

P10b deliberately keeps `--network=none` (loopback still works) so the probe never
reaches outward; it starts the editor in the background, polls
`http://127.0.0.1:8000/mcp` with a JSON-RPC `initialize`, and kills the editor.

## 4. Results

(appended when the pull completes — the 12.75 GiB engine layer is the long pole)

## 5. Verdict

(pending §4)
