# r107-rev-unlock.md — adversary review of the UE-runtime unlock label's evidence chain

Plan (5 lines):
1. Enumerate every artifact in round-107 that asserts (or is expected to assert) a UE-runtime
   `unlock` label — `r107-unlock.md` (UNLOCK-LEAD), `r107-unlock-ver.md` (UNLOCK-VER),
   `r107-unlock-nodocker.md` (UNLOCK-NODOCKER), plus any claim in the gate/integrate shards.
2. Independently re-run the load-bearing commands behind each claim (docker image state, pull
   process/log, digest/labels, host engine census) and diff observed vs claimed.
3. Classify each link of the chain [O] observed-here / [I] inference / [?] unknown; mark any
   link that is asserted-but-unreproducible as a **broken link**.
4. Adjudicate: is the label (a) justified by the chain, (b) overclaimed, (c) underclaimed, or
   (d) absent (no label landed yet)?
5. No writes into `corpus/knowledge/unreal-mcp/`; scratch under `/var/tmp/r107-rev-unlock/`;
   cite exact command + observed output for every measurement; shard < 400 lines.

Status: IN PROGRESS.

## 0. Why this seat exists

The 3D side-round ends with a single binary question that the close-out gate consumes:
**is the UE runtime PROVEN-with-evidence, or UNPROVEN-with-attempt-log?** That label is not a
probe result — it is a *claim about evidence*, and it is only as strong as its weakest link.
This seat is the adversary on that chain: it does not run new probes to *find* an unlock, it
audits whether the probes the other seats ran actually support the label they attached.

## 1. The chain as it exists at review start (2026-10-19T00:08Z, [O])

Command:
```sh
ls reports/round-107/ ; wc -l reports/round-107/r107-unlock*.md
```
Observed [O]:
```
r107-adv2.md  r107-cards-crit.md  r107-cards.md  r107-crit-hygiene.md  r107-crit-scope.md
r107-gate.md  r107-integrate.md  r107-kimi-adapt.md  r107-kimi-ver.md  r107-mut-pin.md
r107-pindelta.md  r107-PROVENANCE-draft.md  r107-rev-adapt.md  r107-rev-cards.md
r107-rev-pin.md  r107-rev-unlock.md  r107-scribe-lesson.md  r107-scribe-log.md
r107-scribe-report.md  r107-sent-evid.md  r107-sent-scope.md  r107-unlock.md
r107-unlock-nodocker.md  r107-unlock-ver.md  r107-VENDOR-A.md  r107-VENDOR-B.md
r107-verify.md  r107-verify2.md
  13 reports/round-107/r107-unlock.md
  19 reports/round-107/r107-unlock-nodocker.md
  41 reports/round-107/r107-unlock-ver.md
```

Reading all three unlock shards [O]:

| shard | lines | ends at | label asserted? |
|---|---|---|---|
| `r107-unlock.md` (UNLOCK-LEAD) | 13 | `## Environment` heading, **no body** | **no** |
| `r107-unlock-nodocker.md` (UNLOCK-NODOCKER) | 19 | `## 0. Environment (this seat)` | **no** |
| `r107-unlock-ver.md` (UNLOCK-VER) | 41 | literal placeholder `(continuing below)` | **no** |

**Chain link #1 — "there is an unlock label to verify" — is BROKEN at review start [O].**
None of the three unlock seats has landed a verdict. `r107-gate.md` (10 lines) and
`r107-integrate.md` (10 lines) are also headers-only, so the close-out gate has not yet
consumed a label either. There is currently **nothing to verify**.

This seat's job therefore reduces to: (a) establish the runtime-state facts the label *would*
have to rest on, independently, so the orchestrator's close-out can attach a defensible label
even if the probe seats run out of time; and (b) adjudicate any label a peer lands before I
close. I do (a) below and re-check (b) in §6.

## 2. Independent host-engine census (re-run, not copied)

Every command below was run by this seat on 2026-10-19; outputs are mine [O].

```
$ which UnrealEditor UnrealEditor-Cmd UnrealEditor-Linux-Shipping
which: no UnrealEditor in (...)
which: no UnrealEditor-Cmd in (...)
which: no UnrealEditor-Linux-Shipping in (...)
exit=3

$ ls -d /opt/Epic* /opt/UnrealEngine* ~/.local/share/Epic*
ls: cannot access '/opt/Epic*': No such file or directory
ls: cannot access '/opt/UnrealEngine*': No such file or directory
ls: cannot access '/home/vgpnk/.local/share/Epic*': No such file or directory

$ git ls-remote https://github.com/EpicGames/UnrealEngine
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/UnrealEngine/' not found
exit=128

$ which lutris legendary heroic ; pacman -Q lutris legendary
which: no lutris in (...) ; which: no legendary in (...) ; which: no heroic in (...)
error: package 'lutris' was not found
error: package 'legendary' was not found
```

=> The host has **no engine binary, no engine install tree, no Epic launcher tooling, and no
access to the private Epic repo**. This reproduces the r101 `PROVENANCE.md:235-238` census and
the r107-UNLOCK-NODOCKER §0 census line-for-line. **[O] AGREE** with both.

AUR gate line, fetched fresh by this seat:
```
$ curl -sL 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine' -o PKGBUILD.aur
$ wc -l PKGBUILD.aur   → 527
$ sed -n '278,283p' PKGBUILD.aur
  # Check access to the repository
  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
    error 'You must register at unrealengine.com and link your github account to access this private repo. ...'
    exit 1
  fi
$ grep -n '^pkgver\|^pkgrel' PKGBUILD.aur   → 11:pkgver=5.8.2   12:pkgrel=1
```
=> The PKGBUILD gate is real and at the cited line; the AUR route is hard-blocked by the same
operator-owned credential step. **[O]** Note the card texts cite `pkgver=5.8.2` while the Docker
route offers 5.8.3 — the AUR package is one patch behind; not an error, but a version skew the
orchestrator should not silently reconcile.

## 3. The docker route — artifact-level verification WITHOUT the 26 GB pull

This is the substantive contribution of this seat. The pull is large and slow; the *identity*
of the artifact does not require it. Docker Registry HTTP API v2 was queried directly.

```
$ TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:wukakuki/unreal-engine:pull" | jq -r .token)
$ curl -s -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "https://registry-1.docker.io/v2/wukakuki/unreal-engine/manifests/dev-slim-5.8.3" -o manifest.json
$ sha256sum manifest.json
3f0886cf0d7e5bc9cea0e7ba27f417e0d0febb5ad0c371c9a89223c6112c80ef  manifest.json
```
Docker Hub tag metadata for the same tag (`curl https://hub.docker.com/v2/repositories/wukakuki/unreal-engine/tags/`):
```
"name":"dev-slim-5.8.3"  "digest":"sha256:3f0886cf0d7e5bc9cea0e7ba27f417e0d0febb5ad0c371c9a89223c6112c80ef"
                         "size":26791359421
```
=> **The manifest bytes this seat fetched hash to exactly the digest the registry publishes for
the tag.** The transport is authentic and the local pull is fetching the same object. **[O]**

Manifest composition [O]:
```
layers: 30   total_bytes: 26791359421 (26.79 GB compressed)
config: mediaType=application/vnd.docker.container.image.v1+json
        digest=sha256:b99f8c5e24c4887d5ace51c3421116ac87d347fbd6d2cf2e3de25d27e50f662e  size=18487
```

Config blob fetched directly (18487 bytes; `sha256sum` matches the manifest's config digest —
`b99f8c5e24c4887d5ace51c3421116ac87d347fbd6d2cf2e3de25d27e50f662e` **[O]**):

| field | value [O] |
|---|---|
| architecture / os | `amd64` / `linux` |
| created | `2026-09-26T23:14:48+08:00` |
| `UNREAL_ENGINE_ROOT` | `/home/ue4/UnrealEngine` |
| `WORKDIR` | `/home/ue4/UnrealEngine` |
| `USER` | `ue4` (uid 1000, created in history step [25]) |
| `ENTRYPOINT` | `None` |
| `CMD` | `["/bin/bash"]` |
| `VOLUMES` | `None` |
| `ExposedPorts` | `[]` (empty) |
| `PATH` | `…:/home/ue4/UnrealEngine/Engine/Extras/ushell` |
| labels | `maintainer=NVIDIA CORPORATION <cudatools@nvidia.com>`, `org.opencontainers.image.version=22.04` |

**This is the load-bearing finding for the label question.** The build history (53 entries)
shows the image is *not* source-only. Steps [33]–[41] copy a prebuilt tree in:

```
[33] COPY --chown=ue4:ue4 /home/ue4/UnrealEngine/LocalBuilds/Engine/Linux /home/ue4/UnrealEngine
[34] COPY … Components/Binaries   [35] … Components/Content    [36] … Components/Extras
[37] COPY … Components/Intermediate  [38] … Components/Plugins  [39] … Components/Source
[40] COPY … Components/DDC        [41] COPY … .config/Epic/UnrealEngine/Install.ini
[46] RUN bash -c 'source "$UNREAL_ENGINE_ROOT/Engine/Extras/ushell/ushell.sh" && exit 0'
[49] RUN EDITOR_TARGET=$(python3 /tmp/print-editor-target.py "$UNREAL_ENGINE_ROOT") && \
         ./Engine/Build/BatchFiles/Linux/Build.sh "$EDITOR_TARGET" Linux Development -SkipBuild && …
```

=> `LocalBuilds/Engine/Linux` is copied *into* the image and step [49] invokes the editor build
target with **`-SkipBuild`**, i.e. it verifies a target that is already built. **[I]** the image
therefore ships an **executable editor binary tree**, not engine source requiring a multi-hour
compile. That is the difference between "a route exists in principle" and "a runnable artifact
is 26.79 GB of download away". Confirming it end-to-end still requires the pull + a container
boot, so this remains **[I]**, not [O].

Prerequisite audit for actually *using* that binary on this host [O]:

```
$ docker info --format '{{json .Runtimes}}' | jq -r 'keys[]'
io.containerd.runc.v2
runc
$ which nvidia-container-runtime nvidia-ctk
(not found — both)
$ nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
NVIDIA GeForce RTX 5070, 610.57.04
$ df -h /   → /dev/mapper/root  930G  179G  740G  20%
```

=> The image is built `FROM` an NVIDIA CUDA base (history steps [7]–[20] install
`libglvnd*`, `10_nvidia.json`, `nvidia_icd.json`) and sets `NVIDIA_VISIBLE_DEVICES=all`.
**The NVIDIA container runtime is NOT installed on this host**, so `--gpus` cannot be honored.
An editor launched here would have no GPU. **[O]** for the absence; **[I]** that this alone
blocks a *graphical* editor — a headless/`-nullrhi` or `UnrealEditor-Cmd` invocation may still
run, which is exactly what a bounded probe must test.

## 4. Adjudication framework — what each evidence tier does and does not prove

The README policy (`corpus/knowledge/unreal-mcp/README.md:15-52`) is binary and its card
mapping is explicit: `verified-here` requires "a bounded run of the subsystem actually happened
on this host, with a saved receipt". A reviewer must therefore ask *which tier* was reached:

| tier | what was done | what it proves | card label it may support |
|---|---|---|---|
| T0 | host engine census | engine absent | nothing (supports `unproven-runtime`) |
| T1 | registry manifest/config fetched; digest matched | the artifact **exists and is authentic**; the image ships a prebuilt tree [I] | **nothing runtime** — artifact provenance only |
| T2 | container boots; `UnrealEditor-Cmd` responds to a `-help`/version-class flag | the engine **binary executes** in the container | an *environment* receipt; still not a subsystem run |
| T3 | editor starts headless, MCP server up, a read-only tool call returns | a **bounded run of a subsystem** occurred | `verified-here` for **that one tool only** |

This seat reached **T1** [O] and, at time of writing, not T2. A label that cites T1 evidence as
PROVEN-with-evidence for *runtime behavior* would be **overclaimed** — T1 proves provenance, and
`README.md:41` reserves `unproven-runtime` for "the claim needs the live editor and nothing was
observed". Conversely, a label of UNPROVEN-with-attempt-log is **honest but incomplete** if a T2
probe later succeeds, because the log would then understate what was actually demonstrated.

## 5. Peer-shard discipline audit (the shards that exist)

Against HARD RULE 5 (cite command, cite output, label, no fabrication, UNPROVEN stays UNPROVEN):

- `r107-unlock-ver.md` §0 image list [O]: I reproduce all five rows (`alpine`, `ds4cc-linux-floor`,
  `node:22-bookworm`, `rust:1-bookworm`, `ubuntu:24.04`) with the same sizes. **AGREE.**
- `r107-unlock-ver.md` §0 process claim (`pid 596299 docker pull wukakuki/unreal-engine:dev-slim-5.8.3`):
  reproduced — `ps -o pid,etime,stat -p 596299` → alive, elapsed 03:21 at 00:10:39 [O]. **AGREE.**
- `r107-unlock-ver.md` §0 claim "same pull/image state as the swarm baseline": **AGREE**, and I
  strengthen it — the pull is not merely "still running" but *verifiably progressing*: 56 MiB/s
  sustained over a 30 s window on `enp7s0` (`rx_bytes` delta 1781300204 / 30 s) [O].
- **Omission worth flagging:** neither `r107-unlock-ver.md` nor any peer shard records that the
  pull process was **launched from the 2D lane's working directory** — `ps` shows its full
  command line beginning `cd '/home/vgpnk/Projects/shokunin/game-dev-2d-shokunin' && nohup docker
  pull …` [O]. The scratch target `/var/tmp/ue-pull.log` is outside both lanes (compliant), but
  the orchestrator should know the attempt is 2D-originated so the 3D shard does not claim
  authorship of it.
- `r107-unlock.md` and `r107-unlock-nodocker.md`: no measurements yet, so nothing to falsify;
  both are correctly labeled `IN PROGRESS` rather than asserting a placeholder verdict. **[O]**
  No shard in round-107 currently contains a fabricated value or an unpromoted UNPROVEN.

**No broken-by-fabrication link found. The only broken link is #1: the label is absent.**

## 6. Verdict

**Current verdict: UNPROVEN-with-attempt-log, on an evidence base this seat has extended to T1.**

- The host route (T0) is closed and reproducibly so [O] — engine absent, private repo 404, AUR
  gate reproduced, no launcher tooling. This is a property of the host, not a work gap.
- The docker route is a **genuine attempt, not a strawman** [O]: the tag is real, the manifest
  digest matches the published digest byte-for-byte, and the pull is measurably progressing.
- The image is *built to run an editor* — prebuilt tree copied in, `-SkipBuild` build step,
  `UNREAL_ENGINE_ROOT` and `WORKDIR` set, `CMD` a shell [O]/[I]. So the docker route is the one
  route with a plausible path to T2/T3.
- It has **not** reached T2 at time of writing: no image is local
  (`docker image inspect wukakuki/unreal-engine:dev-slim-5.8.3` → `No such image`), and even once
  pulled, the missing NVIDIA container runtime means only a headless probe is possible [O].
- Therefore **no PROVEN-with-evidence label is supported**, and any shard asserting one from T1
  evidence would be overclaimed.

**What the orchestrator should land:** the label `UNPROVEN-with-attempt-log`, with the attempt log
carrying (i) the T0 census commands above, (ii) the T1 registry-digest match as proof the attempt
targeted a real, authentic artifact, (iii) the measured 56 MiB/s progress and the 30-layer/26.79 GB
size, and (iv) an explicit statement of the tier reached — so a future round inherits a precise
resume point rather than a bare "unproven".

### Open items this seat could not close (hand to the orchestrator)

1. **No label from any unlock seat** — the chain's first link is still broken. If UNLOCK-LEAD /
   UNLOCK-VER / UNLOCK-NODOCKER land verdicts after this shard, they must be reconciled against §4;
   this seat's framework is the reconciliation key.
2. **Pull completion + T2 probe** — pending. This seat will append the outcome below if it lands
   before I close.
3. **[?]** Whether a headless `UnrealEditor-Cmd -help`-class invocation succeeds *without* the
   NVIDIA runtime is untested and untestable until the image is local. Do not pre-assert it.
4. **[?]** Whether the image's prebuilt engine includes the `ModelContextProtocol` / `AllToolsets`
   plugins — required by `references/setup.md:14-31` for any MCP tool to be exposed. The build
   history copies `Components/Plugins` [O] but the plugin manifest contents are inside the image.
   **This is the decisive unknown for T3** and it is not resolvable from registry metadata.

## 7. Pull progress ledger (appended, [O])

| time (local) | log lines | pull-complete layers | downloaded | extracted |
|---|---|---|---|---|
| 00:08:35 | 69 | 16/30 | — | 0.48 GB |
| 00:09:11 | 70 | 16/30 | 13.10 GB | 0.48 GB |
| 00:09:57 | 75 | 16/30 | 13.10 GB | 0.48 GB |
| 00:10:52 | 76 | 16/30 | 13.10 GB | 0.48 GB |
| 00:12:54 | 80 | 20/30 | 13.10 GB | 10.15 GB |
| 00:14:10 | 80 | 20/30 | 13.10 GB | 10.15 GB |
| 00:15:48 | 80 | 20/30 | 13.10 GB | 10.15 GB |

Column note: "downloaded" = Σ manifest sizes of layers logged `Download complete` (29/30,
13.10 GB — identical to W-CRON's `dl_bytes`, §8.2); "extracted" = Σ sizes of layers logged
`Pull complete` (20/30, 10.15 GB). The two diverge because docker unpacks in parallel with
downloading. The single remaining download is the 13.69 GB gating layer (§8.2) [O].

## 8. Adjudication of the labels that landed mid-review

Between §1 and now, three peer shards changed under me (mtime evidence, [O]):

```
$ stat -c '%y %n' reports/round-107/r107-unlock.md reports/round-107/r107-unlock-nodocker.md \
                 reports/round-107/r107-unlock-ver.md reports/round-107/r107-pull-watch.md
r107-unlock.md            161 lines  (was 13 at §1)
r107-unlock-nodocker.md   232 lines  (was 19 at §1)
r107-unlock-ver.md         41 lines  (unchanged — still ends at `(continuing below)`)
r107-pull-watch.md        (new shard, W-CRON)
```

So the chain now has labels, and this seat's job (b) is live.

### 8.1 `r107-unlock-nodocker.md` — label **UNPROVEN-with-attempt-log**

Routes A–D audited (Epic CDN, AUR source, AUR `-bin` manual stub, Lutris). Every route
terminates in the same operator-owned credential step. I spot-checked the two load-bearing
receipts:

- §2 org-membership receipt (`gh api user/orgs` → `vgpnk-holdings-llc` only; `EpicGames` org
  publicly visible but not joined): consistent with my own §2 `git ls-remote` → `Repository not
  found` [O]. The shard's reading — "not org-doesn't-exist, not token-broken, but exactly the
  Epic-link gate" — is the correct disambiguation.
- §3 `unreal-engine-bin` `manual://` DLAGENT: the shard's claim that the stub "prints a message
  and downloads nothing" is the standard `manual://` semantics [I], and its conclusion that
  Route C *delegates* to Route A rather than bypassing it follows.

**AGREE with the label.** It is correctly weaker than "blocked" would suggest: routes are
blocked *by construction*, and the shard says so without overclaiming that a probe was run.
No fabrication found. One minor note: its §5 records the docker state as "16/30 layers" [O] —
that is a **line count** (`grep -c 'Pull complete'`), which happened to equal the distinct-layer
count at that instant; both are legitimately reproducible (my §7 ledger shows 16 at 00:08:35).

### 8.2 `r107-pull-watch.md` (W-CRON) — no runtime label; byte-accounting **VERIFIED**

This shard makes no unlock claim, but it supplies the byte ground truth other shards lean on,
so its arithmetic is in scope. I re-derived its `dl_bytes` independently from the same manifest:

```
$ python3 -c "<sum manifest layer sizes for prefixes logged 'Download complete'>"
dl_layers=29 dl_MiB=12495.3 (13.10 GB)   pull_layers=20 pull_MiB=9683.1 (10.15 GB)
```
W-CRON's own CSV at 00:11:54: `dl_bytes=13102305859 dl_layers=29` → 13102305859/1048576 =
**12495.3 MiB, 29 layers**. **Exact match, byte for byte [O].**

Its structural insight is also correct and I confirm it independently [O]: the largest layer
(`sha256:7a31e2ef5f97156004ef1b4403ef1cd24cd1c4722fda605d080514679b501b63`, 13 689 053 562 B
= 13.69 GB) is **still absent from the log** (`grep -c 7a31e2ef5f97` → 1, and that one line is
`7a31e2ef5f97: Pulling fs layer`), and absent from the content store. Its projection that this
single layer gates completion is therefore right; the early-average rate cannot be extrapolated.

**AGREE. No defect.** This is the best-disciplined shard in the set: every column has a stated
command, and the byte proxy is derived rather than assumed.

### 8.3 `r107-unlock.md` (UNLOCK-LEAD) — two defects in the evidence chain

LEAD's static-evidence section (§1.1–§1.2) is the one that matters, because it is the only
peer analysis that reaches *inside* the image without the pull. Its build-history finding
(`-SkipBuild`, `rm -R -f /home/ue4/.epic`) I independently reproduce [O] — see my §3. But two
of its stated facts do not survive re-derivation.

**DEFECT 1 — `Cmd: null` is factually wrong. Severity: low. Class: misreported field.**

LEAD prints, as its config-blob summary:
```
WorkingDir: /home/ue4/UnrealEngine
Entrypoint: null      Cmd: null
```
I fetched the config blob it names, by digest, and verified the bytes:

```
$ sha256sum config.json   → b99f8c5e24c4887d5ace51c3421116ac87d347fbd6d2cf2e3de25d27e50f662e
$ jq -r '.config.Cmd, .config.Entrypoint' config.json
["/bin/bash"]
null
$ jq -r '.history[] | select(.created_by|contains("CMD")) | .created_by' config.json
/bin/sh -c #(nop)  CMD ["/bin/bash"]
```
To rule out corruption on my side I re-fetched the blob fresh from the registry:
`config2.json` → sha256 `b99f8c5e…662e` (identical), `.Cmd = ['/bin/bash']` (identical). **[O]**

So `Cmd` is `["/bin/bash"]`, not `null`. The digest LEAD itself cites is the digest of a blob
whose `Cmd` is non-null. **The downstream inference is unharmed** — `Entrypoint` really is null,
and a probe must still supply its own command, which is why `--entrypoint /bin/bash` is correct.
But a stated observed value that the cited artifact contradicts is precisely the failure mode
this seat exists to catch, and a close-out gate that consumes "Cmd: null" would be recording
something false.

**DEFECT 2 — `~258 MiB/s` is not reproducible, and the method measures the wrong quantity.**
**Severity: medium. Class: unsupported quantitative claim.**

LEAD's receipt is `sudo du -sb /var/lib/containerd` over a 60 s window:
```
t0  bytes=20827061758
t60 bytes=37414115992
delta=16587054234 bytes / 60 s = ~258 MiB/s
```
I ran the same command, same path, twice:

| window | method | observed |
|---|---|---|
| 00:11:49 → 00:12:44 (55 s) | `du -sb /var/lib/containerd` | 6 205 505 818 B → **107.6 MiB/s** |
| 00:13:10 → 00:14:11 (61 s) | `du -sb /var/lib/containerd` + NIC rx | 1861 MiB du → **30.5 MiB/s**; NIC rx 2003.7 MiB → **32.8 MiB/s** |

**[O]** I could not reproduce 258 MiB/s in any window, and I have a hard independent ceiling:
raw NIC `rx_bytes` on `enp7s0` over 61 s is 2003.7 MiB → **32.8 MiB/s**. No amount of local
decompression can move 258 MiB/s *across the network*. LEAD's number is therefore either a
transient burst (the window I cannot re-create) or an artifact of `du` counting **unpacked**
bytes, which inflate the rate by the gzip ratio — the image is 24.95 GiB compressed but unpacks
much larger, and `du` on the snapshotter counts the unpacked side. Its own framing ("at 258 MiB/s
the ~26.8 GB compressed image unpacks in well under an hour") mixes the two quantities: it
divides a *compressed* size by an *unpacked* rate.

The **directional** conclusion survives — the link is much faster than r101's 12.5 MB/s bound,
and my 30–33 MiB/s sustains that (2.5x, not 20x). The **specific figure** should not land.

### 8.4 `r107-unlock-ver.md` — no label, still `(continuing below)`

Unchanged at 41 lines since §1 [O]. Its §0 baseline claims all reproduce (image list, pid 596299,
"same pull/image state"). It is honest to leave it unlabeled, but as of this writing it has not
contributed a verdict, so it neither supports nor contradicts the round label.

### 8.5 Reconciliation against the §4 tier framework

| shard | evidence tier reached | label asserted | tier-consistent? |
|---|---|---|---|
| UNLOCK-LEAD | T1 (registry config/history) + T0 | none yet (`§5 Verdict (pending)`) | n/a — not yet claimed |
| UNLOCK-NODOCKER | T0 (host census, routes A–D) | UNPROVEN-with-attempt-log | **yes** — T0 cannot support more |
| UNLOCK-VER | T0 (image/process snapshot) | none | n/a |
| W-CRON | pull telemetry | none | n/a |
| **this seat** | **T1** + attempt log | **UNPROVEN-with-attempt-log** | **yes** |

No shard has reached T2, so **no PROVEN-with-evidence label is supported by any shard in
round-107.** The round label is settled at UNPROVEN-with-attempt-log on T0+T1 evidence.

## 9. Consolidated verdict and handoff

**VERDICT: UNPROVEN-with-attempt-log.** The chain, link by link, as adjudicated:

1. *A label exists* — now yes (2 of 4 unlock seats). Was broken at review start.
2. *Host routes closed* — verified by me independently [O]. Strongest link.
3. *Docker route targets a real artifact* — verified [O]: manifest sha256 == published digest.
4. *The image can host a runnable editor* — **[I]**, from build history (`-SkipBuild`, prebuilt
   `LocalBuilds/Engine/Linux` copy). Not [O]; needs a booted container.
5. *A runtime probe was run* — **absent**. No shard reached T2. No image is local.
6. *Therefore PROVEN-with-evidence* — **unsupported**.

**Two corrections the orchestrator must apply before landing:**
- Do **not** land `Cmd: null` (§8.3 defect 1). The correct value is `Cmd: ["/bin/bash"]`,
  `Entrypoint: null`.
- Do **not** land `258 MiB/s` as measured throughput (§8.3 defect 2). Land either the
  reproducible figure (30–33 MiB/s NIC-bound, 108 MiB/s unpacked peak) or LEAD's number
  explicitly re-labeled as an unreproduced single-window observation.

**Still open at handoff [O]:**
- Image not local: `docker image inspect wukakuki/unreal-engine:dev-slim-5.8.3` → `No such image`
  (rechecked 00:15:48, pull alive 08:30 elapsed). The T2 probe this round wanted **did not happen**.
- The 13.69 GB gating layer had not started downloading as of 00:14:10 [O].
- NVIDIA container runtime absent (`nvidia-container-runtime`, `nvidia-ctk` both not found;
  runtimes = `runc`, `io.containerd.runc.v2` only) → only a headless probe is possible here [O].
- **[?]** whether the prebuilt tree includes `ModelContextProtocol` / `AllToolsets` — the decisive
  unknown for any future T3, and not derivable from registry metadata.

Scratch (outside the repo, nothing landed): `/var/tmp/r107-rev-unlock/` (`manifest.json`,
`config.json`, `config2.json`, `PKGBUILD.aur`). No writes into `corpus/knowledge/unreal-mcp/`.
No battery run; no fixture touched.
