# r107-unlock-nodocker.md — non-docker UE-runtime unlock evaluation (seat KEY=UNLOCK-NODOCKER)

Plan (5 lines):
1. Establish the credential/account gate state for every non-docker route (Epic account, Epic-linked GitHub, legendary/heroic CLI) — read-only, no login attempts, no license acceptance.
2. Check local package availability for Lutris (repo + AUR) and record whether an install path even exists without credentials.
3. Check AUR `unreal-engine` / `-bin` / `-git` / `-src-*` PKGBUILD gate lines via the AUR RPC/cgit API (network read only, no build, no `makepkg`).
4. Record the docker fallback state (pull log tail, image list) for the L0 record; this seat does not run probes.
5. Label every line [O]/[I]/[?]; verdict UNPROVEN-with-attempt-log unless a route genuinely succeeds.

Status: **COMPLETE**. Verdict: **UNPROVEN-with-attempt-log** (no non-docker route opened; all four are credential-gated).

---

## 0. Environment (this seat) — [O]

```
$ cat /etc/os-release | head -3
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
$ which docker ; docker --version
/usr/bin/docker
Docker version 29.7.2, build a7dcaa6fdb
$ which yay paru ; which lutris ; pacman -Q lutris
/usr/bin/yay
(no paru)
(no lutris)
error: package 'lutris' was not found
$ which legendary heroic ; ls ~/.local/share/Epic*
(no legendary) (no heroic)
ls: cannot access '/home/vgpnk/.local/share/Epic*': No such file or directory
$ df -h / ; nproc ; free -g
/dev/mapper/root  930G  168G  750G  19% /
32
Mem: 30 Gi total, 25 Gi available
```

[O] `ls ~/.config/{Epic,legendary,heroic,lutris}` and `~/.local/share/{legendary,heroic,lutris}` and `~/.var/app` → **all absent**. `which wine wine64 proton` → none. `ls ~/.wine` → absent. No Epic Store / legendary / heroic state exists on this host.

---

## 1. ROUTE A — Epic Games account (direct download)

### A1. Account artifacts: none on host [O]
See §0. No Epic Launcher, no `legendary`/`heroic` CLI, no wine prefix, no `.var/app` Flatpak sandbox. There is nothing to log into even if a credential existed.

### A2. Download endpoints are gated (fresh re-derivation, 2026-10-19) [O]

```
$ curl -sS -o /dev/null -w 'http=%{http_code}\n' -L https://www.unrealengine.com/linux
http=403
$ curl -sS -L https://www.unrealengine.com/linux | head -c 400
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>.cf_challenge_text_small { font-size: 11px; ... }
$ curl -sS -o /dev/null -w 'http=%{http_code}\n' -L -A 'Mozilla/5.0 (X11; Linux x86_64) ... Chrome/131.0 ...' \
    https://www.unrealengine.com/en-US/linux
http=403
$ curl -sS -o /dev/null -w 'http=%{http_code} size=%{size_download} type=%{content_type}\n' \
    -r 0-2047 -L https://download.epicgames.com/Builds/UnrealEngine/5.8.2/Linux_Unreal_Engine_5.8.2.zip
http=403 size=111 type=application/xml
```

**[O] Disambiguation of the 403:** the `/linux` body is a **Cloudflare challenge page** (`cf_challenge_text_small`, `<meta name="viewport">`, styled body) — so that specific 403 is a bot wall, *not* proof of a credential gate, and I will not claim otherwise. The decisive receipt is the **CDN** one: `download.epicgames.com/.../Linux_Unreal_Engine_5.8.2.zip` returns `403` with a **111-byte `application/xml` body** (an S3/CloudFront-style access-denied document), unauthenticated, range request or HEAD alike. That endpoint is the actual artifact host and it refuses an anonymous client. **[I]** the CDN 403 is the credential/EULA gate; the web-page 403 is Cloudflare.

### A3. Token canary — Epic's CDN does not read GitHub tokens [O]
`gh auth status` shows a live `gho_…` token with `repo` scope, and `gh api user` → `VeigaPunk`. Sending that bearer to Epic's CDN would be a **pointless credential leak** (Epic's CDN is not GitHub), so this seat did **not** attempt it. Recorded as a deliberate non-attempt, not a failed attempt.

**Route A verdict: BLOCKED-without-credentials [O/I]. No login attempted. No EULA accepted.**

---

## 2. ROUTE B — AUR source recipes (`unreal-engine`, `-git`, `-src-*`)

### B1. Recipe census (AUR RPC v5, 2026-10-19) [O]

```
$ curl -s 'https://aur.archlinux.org/rpc/v5/search/unreal-engine?by=name'
unreal-engine            5.8.2-1   maint alexbelm48   lastmod 2026-09-12
unreal-engine-4          4.27.2-15 maint Neko-san     lastmod 2023-11-19
unreal-engine-bin        5.8.2-1   maint ttc0419      lastmod 2026-09-06   OutOfDate 2026-10-07
unreal-engine-git        5.3.2-4   maint VitalyR      lastmod 2023-11-18   OutOfDate 2024-05-05
unreal-engine-manager    0.0.3-1   maint matheusvilano lastmod 2026-09-08
unreal-engine-src-5.4    5.4.4-3   maint FinleyLaempe lastmod 2026-10-06
unreal-engine-src-5.5    5.5.4-3   maint FinleyLaempe lastmod 2026-10-06
unreal-engine-src-5.6    5.6.1-3   maint FinleyLaempe lastmod 2026-10-06
unreal-engine-src-5.7    5.7.4-3   maint FinleyLaempe lastmod 2026-10-06
unreal-engine-src-5.8    5.8.3-3   maint FinleyLaempe lastmod 2026-10-06
```

**[I] Freshness:** r101 surveyed `unreal-engine` / `-bin` / `-git` only. This round adds three recipes **not previously in the census**: `unreal-engine-src-5.4…5.8` (maintained, updated 2026-10-06, `src-5.8` tracks **5.8.3** — the same engine line the docker image claims) and `unreal-engine-manager`. All still gate identically (§B2), so the new recipes widen the census without opening a route.

### B2. Every source recipe gates on the same GitHub probe — in `prepare()`, before any compile [O]

`unreal-engine` 5.8.2-1 (fetched to `unreal-engine.PKGBUILD`, 527 lines), lines 280-282:

```bash
  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
    error 'You must register at unrealengine.com and link your github account to access this private repo. ...'
    exit 1
  fi
```

`unreal-engine-git` 5.3.2-4, lines 136-139 — byte-same gate. `unreal-engine-src-5.8` 5.8.3-3 (678 lines) is the newest and most explicit, lines 299-320:

```bash
  local _ue_remote_ssh="git@github.com:EpicGames/UnrealEngine.git"
  local _ue_remote_https="https://github.com/EpicGames/UnrealEngine.git"
  msg "Probing GitHub access to EpicGames/UnrealEngine..."
  if git ls-remote "${_ue_remote_ssh}" &>/dev/null; then ... elif git ls-remote "${_ue_remote_https}" &>/dev/null; then ...
  else
    error "Cannot access EpicGames/UnrealEngine via SSH or HTTPS."
    error "You must:"
    error "  1. Have a GitHub account linked to your Epic Games account: https://www.unrealengine.com/en-US/ue-on-github"
    error "  2. Accept the @EpicGames org invitation in your GitHub inbox."
    error "  3. Configure either: SSH ... or HTTPS: 'gh auth login' or git credential helper with PAT (repo scope)"
    exit 1
  fi
```

**[O] The recipe names the requirement itself:** an Epic-linked GitHub account *plus* accepting the `@EpicGames` org invitation. That is a human/legal act (EULA acceptance), not something this seat may perform. `unreal-engine-src-5.8` also downloads its Linux SDK toolchain from `https://cdn.unrealengine.com/Toolchain_Linux/${_sdk_basename}.tar.gz` (line 475) — the **same 403-gated CDN host** as Route A §A2.

### B3. Gate re-derived live, both transports [O]

```
$ git ls-remote https://github.com/EpicGames/unreal-engine
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found
$ GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=10' git ls-remote git@github.com:EpicGames/UnrealEngine
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
$ gh api repos/EpicGames/UnrealEngine
{"message":"Not Found", ... "status":"404"}
$ gh api user --jq .login
VeigaPunk
$ gh api user/orgs --jq '.[].login'
vgpnk-holdings-llc
$ gh api orgs/EpicGames --jq .login
EpicGames
```

**[O] This is the sharpest single receipt in the shard:** the token is live and has `repo` scope; the account's org list is `vgpnk-holdings-llc` only — **no `EpicGames` membership**; yet the org `EpicGames` *is* publicly visible. So the repo 404 is not "org doesn't exist" and not "token broken" — it is exactly the Epic-link gate the recipes describe. `[I]` The user's GitHub account is not linked to an Epic account (or the org invitation was never accepted).

**Route B verdict: BLOCKED-without-credentials [O]. No build attempted (no `makepkg` run). No EULA accepted.**

---

## 3. ROUTE C — AUR `unreal-engine-bin` (manual:// stub)

`unreal-engine-bin` 5.8.2-1 (51 lines) has **no git gate** — it is the only recipe that avoids the GitHub probe. Instead:

```bash
DLAGENTS+=('manual::/usr/bin/echo \ \ Note: Please download the zip file manually from https://www.unrealengine.com/linux')
source=("manual://Linux_Unreal_Engine_${pkgver}.zip" 'unreal-engine.desktop' ...)
sha256sums=('4bc938a3c34ae7305e9dff7b3be381a43ca4b942348e90102885f4bcab7e9575' ...)
```

**[O]** The `manual://` DLAGENT only *prints a message*; it downloads nothing. The build therefore depends on an operator placing `Linux_Unreal_Engine_5.8.2.zip` in `srcdir` **by hand**, fetched from the account-gated page in §A2. **[I]** Route C does not bypass Route A — it *delegates* to it and adds a sha256 check. Its `OutOfDate` stamp (2026-10-07) also means the AUR web UI flags it as stale.

`unreal-engine-manager` (Route C adjacent) is only a **GUI/Tk front-end** (`pkgdesc="A Python-based Linux application for managing Unreal Engine installations."`, `source=git+https://github.com/matheusvilano/unreal-engine-manager.git`) — it installs no engine and inherits whatever gate its backend uses. **[I]**

**Route C verdict: BLOCKED-without-credentials [O/I].**

---

## 4. ROUTE D — Lutris (+ Epic Games Store login)

```
$ pacman -Ss '^lutris'
extra/lutris 0.5.22-3
    Open Gaming Platform
$ pacman -Qi lutris
error: package 'lutris' was not found      # not installed
$ cat lutris.PKGBUILD   # fetched from AUR for completeness; version 0.4.18.1, older than repo
```

**[O]** Lutris is available in the **`extra` repo** (0.5.22-3), so `pacman -S lutris` would install the *launcher* without credentials. **[I] However Lutris is a wrapper, not an engine:** the only way it yields an Unreal Engine is by running the **Windows Epic Games Launcher** inside a wine prefix and logging into an Epic account to download the engine. That is Route A's credential gate, reached through an extra wine layer — and no wine prefix exists here (§0). **Route D verdict: BLOCKED-without-credentials [O/I]. The install step is one command; the login step is the wall.**

---

## 5. ROUTE E (observed, not evaluated by this seat) — docker image

This seat's remit is the *non-docker* paths; recorded here only for the L0 record, **[O]**.

```
$ grep -c 'Pull complete' /var/tmp/ue-pull.log ; grep -c 'Pulling fs layer' /var/tmp/ue-pull.log
20                                             ; 30 announced
$ ps -p 596299 -o etime=,stat=,wchan=
  04:47 Sl  futex_do_wait        # running, parked on a futex — not D/zombie
$ docker images wukakuki/unreal-engine
IMAGE   ID   DISK USAGE   CONTENT SIZE   EXTRA     # no rows — image not yet present
$ docker system df
Images 5  ACTIVE 0  4.656GB   3.302GB (70%) reclaimable
```

**[O] Progress proof (the log is buffered — do not use it as the liveness signal).** The pull log file stalls for tens of seconds at a time because `docker pull` writes progress in blocks when stdout is not a TTY, so a static log is a **false negative**. The real signal is the content store on disk:

```
$ sudo -n du -sb /var/lib/containerd    # t0 / t20
54551925210  ->  55734675887          # +1.18 GB in 20 s ≈ 59 MB/s
$ grep -c 'Pull complete' /var/tmp/ue-pull.log   # 19 -> 20 in the same window
```

**[O]** So `docker pull wukakuki/unreal-engine:dev-slim-5.8.3` (PID 596299) is **live and healthy**: 20 of 30 layers complete at ~04:47 elapsed, content store growing ~59 MB/s. A separate 12 s sample showed `+5.4 GB`, i.e. the rate is bursty but sustained. Docker Hub is reachable anonymously: `registry-1.docker.io/v2/` → `401` (expected, needs token), `auth.docker.io/token?…scope=repository:wukakuki/unreal-engine:pull` → `200`. **[I]** the docker route is the only one that has *not* hit a credential wall — consistent with r101's G2 finding. **This seat ran no container probes**; UNLOCK-LEAD owns that.

> **Handoff note for UNLOCK-LEAD:** to watch this pull, sample `du -sb /var/lib/containerd` (or `grep -c 'Pull complete'`) on a timer. Watching `/var/tmp/ue-pull.log` alone will look stalled. At the observed rate the remaining 10 layers may still be several minutes to tens of minutes; the image is ~27 GB compressed (r101 estimate), so do not conclude failure from log silence.

---

## 6. Summary table — non-docker routes

| # | route | gate | verdict | evidence |
|---|---|---|---|---|
| A | Epic account / direct download | Epic login + EULA; CDN `403` xml | **BLOCKED** [O/I] | §A2, §A3 |
| B | AUR source (`unreal-engine`, `-git`, `-src-5.4…5.8`) | `git ls-remote git@github.com:EpicGames/UnrealEngine` in `prepare()` | **BLOCKED** [O] | §B2, §B3 |
| C | AUR `unreal-engine-bin` | `manual://` stub → operator hand-fetch from A | **BLOCKED** [O/I] | §3 |
| D | Lutris + Epic Store login | Launcher installs freely; engine needs Epic login via wine | **BLOCKED** [O/I] | §4 |
| E | docker `wukakuki/unreal-engine` | none observed; pull in flight | **not this seat's** | §5 |

**Verdict: UNPROVEN-with-attempt-log.** Every non-docker route is credential-gated and no credential was supplied. **No login was attempted on any service; no EULA or license was accepted; no engine was built; no `makepkg` was run.** The routes are blocked *by construction*, not by this seat's unwillingness to try.

---

## 7. What would change the verdict (operator-only actions)

1. **Epic-link the GitHub account** — link `VeigaPunk` at `https://www.unrealengine.com/en-US/ue-on-github`, accept the `@EpicGames` org invite. Re-run: `gh api repos/EpicGames/UnrealEngine --jq .full_name` should stop returning 404. *[I] this is the single unlock for routes A, B, C.*
2. **Accept Epic's EULA** (required for the manual zip and for engine use) — operator-owned, cannot be automated here.
3. **Route D** additionally needs a wine prefix + the Windows Epic Launcher; strictly more work than (1) for the same credential wall.
4. **Route E** needs nothing further beyond the in-flight pull; the image's *contents* (does it ship `ModelContextProtocol`/`AllToolsets`?) remain unestablished until UNLOCK-LEAD probes it.

---

## 8. Provenance / scope notes

- All commands run on this host 2026-10-19 (UTC); shard written by seat **KEY=UNLOCK-NODOCKER**, round 107.
- Read-only: network reads (AUR RPC/cgit, GitHub API, Epic endpoints), local filesystem reads, `pacman -Ss/-Q`. **No** install, **no** login, **no** EULA, **no** build, **no** container.
- Consistent with prior records: `reports/round-101/probes/prereq-matrix.md:186-187` (G6 lutris in `extra`, not installed; G7 Epic login = OPERATOR-WALL) and `reports/round-101/r101-reviewer-c2.md:341-375` (`unreal-engine-bin` `manual://` stub). This shard **extends** them with (a) three new `-src-*` recipes, (b) the CDN-403-vs-Cloudflare-403 disambiguation, and (c) the org-membership receipt.
- No files were written into `corpus/knowledge/unreal-mcp/`. Scratch: `/var/tmp/r107-unlock-nodocker/` (PKGBUILDs + `aur.json`). No mutation scripts were needed for this seat.
