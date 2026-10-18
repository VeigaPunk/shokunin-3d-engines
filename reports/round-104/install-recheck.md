# SEAT-44 — INSTALL-RECHECK (round r104)

- Seat: SEAT-44 (three install receipts re-run; nothing installed, nothing written outside this path)
- Round: r104
- Repo HEAD at capture: `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`r103 report-last`; work `8c9d9ad`)
- Capture time: **2026-10-18T19:16Z**–**19:22Z** (one `date -u` sample per command block; see §6)
- Method: each r103 receipt re-executed verbatim on this host; output pasted unedited, exit codes captured with `set +e`.
- Predecessor: `reports/round-103/install-recheck.md` (SEAT-57), which found zero deltas against r102.
- Owned path: `reports/round-104/install-recheck.md` (the only file this seat wrote). Nothing under
  `corpus/`, `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, `SKILL.md`, `corpus/fixtures/**`,
  `corpus/knowledge/unreal-mcp/upstream/**`, `corpus/knowledge/unreal-mcp/.manifest.d/**`, or
  `reports/round-10{1,2,3}/**` was written. No `git commit/push/checkout/reset` was run.

**Headline answer to the seat question — the three install receipts are unchanged for the third
round running, but two host scratch paths that r103 recorded as live are now gone, and one of them
is a path the pinned subtree tells readers to run a command against.**

R1/R2/R3 reproduce byte-for-byte; `shellcheck` is still installed at the same version with its r101
install entry untouched; the AUR recipe is still the same 527-line, same-hash file. The deltas are
**host-state, not upstream-state**: `/tmp/ue-skills-ref` and `/tmp/r101seat12-aur-PKGBUILD` no longer
exist, and §5 traces the deletion to a specific, timestamped `rm -rf` that this lane itself ran.

---

## 1. The three install receipts, re-run

### R1 — `EpicGames/unreal-engine` over HTTPS: still 404

```
$ git ls-remote https://github.com/EpicGames/unreal-engine
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found
exit=128
```

```
$ gh api repos/EpicGames/UnrealEngine
{"message":"Not Found","documentation_url":"https://docs.github.com/rest/repos/repos#get-a-repository","status":"404"}gh: Not Found (HTTP 404)
exit=1
```

The transport-independent routes r103 added still agree, and the bogus-name control still returns
the same 404:

```
$ curl -sS -o /dev/null -w 'api=%{http_code}\n'   https://api.github.com/repos/EpicGames/UnrealEngine
api=404
$ curl -sS -o /dev/null -w 'web=%{http_code}\n'   https://github.com/EpicGames/UnrealEngine
web=404
$ curl -sS -o /dev/null -w 'bogus=%{http_code}\n' https://api.github.com/repos/EpicGames/definitely-not-a-repo-xyz
bogus=404
```

**[O]** Unchanged. The r103 reading stands: the code alone cannot prove nonexistence, which is why
the authenticated controls below matter.

### R2 — AUR route, SSH form: still publickey-denied

```
$ GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=no' \
    git ls-remote git@github.com:EpicGames/UnrealEngine
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
exit=128
```

This is the exact command the AUR `PKGBUILD:280` gate runs, so the build would still abort in
`prepare()` before compiling anything.

### R3 — Lutris route: still software-present, credential-gated

```
$ pacman -Si lutris
Repository      : extra
Name            : lutris
Version         : 0.5.22-3
...
Packager        : Balló György <bgyorgy@archlinux.org>
Build Date      : Sat 03 Oct 2026 07:03:32 PM -03
Validated By    : SHA-256 Sum  Signature
exit=0

$ pacman -Qi lutris
error: package 'lutris' was not found
exit=1

$ docker --version
Docker version 29.7.2, build a7dcaa6fdb
exit=0

$ grep -ci lutris /var/log/pacman.log
0
```

Same version `0.5.22-3`, same `Build Date` as r103 recorded, still not installed, docker still
present. `lutris` still has **zero** entries in the package log, confirming it was never installed
here. (r103 added `Build Date` as a new data point; it is identical this round, so it stays a data
point and not a delta.)

### R3-control — is the 404 a network problem or an account problem?

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
exit=0

$ gh api repos/cli/cli --jq '.full_name'
cli/cli
exit=0

$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin --jq '.full_name + " " + .visibility'
EpicGames/unreal-engine-skills-for-claude-code-plugin public
exit=0

$ gh auth status
github.com
  ✓ Logged in to github.com account VeigaPunk (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
exit=0
```

**[O]** Identical to r103. The token reaches two public GitHub repos and one *other* `EpicGames`
repo; the 404 is scoped to `EpicGames/UnrealEngine` and is the expected consequence of `VeigaPunk`
not being Epic-linked.

---

## 2. `shellcheck` — still present, same version, install receipt intact

```
$ command -v shellcheck        → /usr/bin/shellcheck          exit=0
$ shellcheck --version         → version: 0.11.0              exit=0
$ pacman -Q shellcheck         → shellcheck 0.11.0-158        exit=0

$ grep -i shellcheck /var/log/pacman.log | tail -3
[2026-10-18T14:10:45-0300] [PACMAN] Running 'pacman -S --noconfirm shellcheck'
[2026-10-18T14:11:00-0300] [PACMAN] Running 'pacman -S --noconfirm shellcheck'
[2026-10-18T14:11:04-0300] [ALPM] installed shellcheck (0.11.0-158)
```

The host is still package-frozen at the r101 install — the r103 finding carries forward:

```
$ grep -c 'transaction completed' /var/log/pacman.log
28
$ grep 'transaction completed' /var/log/pacman.log | tail -1
[2026-10-18T14:11:04-0300] [ALPM] transaction completed
$ stat -c '%y' /var/log/pacman.log
2026-10-18 14:11:04.863114934 -0300
$ pacman -Qi shellcheck | grep 'Install Date'
Install Date    : Sun 18 Oct 2026 02:11:04 PM -03
```

**[O]** The log's mtime *is* the last transaction time, and the shellcheck install date matches it.
No package transaction has occurred on this host across the whole r101→r104 window. Cross-round
comparability of every install claim still rests on that freeze.

Functional re-check on the one upstream artifact that is executable here:

```
$ shellcheck -S warning corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
(no output)
rc=0
```

---

## 3. AUR recipe identity — unchanged, byte-for-byte

```
$ curl -s "https://aur.archlinux.org/rpc/v5/info?arg[]=unreal-engine" \
  | jq -c '.resultcount, (.results[] | {Name,Version,LastModified,Maintainer,NumVotes})'
1
{"Name":"unreal-engine","Version":"5.8.2-1","LastModified":1789249288,"Maintainer":"alexbelm48","NumVotes":75}
```

`LastModified` 1789249288 → **2026-09-12T21:41:28Z** — identical to r102 and r103. The recipe has
not been touched in three rounds.

```
$ curl -sSL -o /var/tmp/aur-r104-PKGBUILD \
    "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine"
exit=0
$ wc -l /var/tmp/aur-r104-PKGBUILD
527 /var/tmp/aur-r104-PKGBUILD

$ sha256sum /var/tmp/aur-r104-PKGBUILD /tmp/aur-r101-copy /tmp/aur-r102-PKGBUILD /var/tmp/aur-r103-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /var/tmp/aur-r104-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /tmp/aur-r101-copy
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /tmp/aur-r102-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /var/tmp/aur-r103-PKGBUILD

$ diff -q /var/tmp/aur-r104-PKGBUILD /var/tmp/aur-r103-PKGBUILD && echo IDENTICAL
IDENTICAL
```

Note the first `sha256sum` operand in the r103 report, `/tmp/r101seat12-aur-PKGBUILD`, is now gone
(§5); the r101-era copy `/tmp/aur-r101-copy` is the surviving substitute and carries the same
digest, so the four-round chain is still closed.

Both independent identity confirmations re-run:

```
$ curl -sSI "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine" | grep -i '^etag'
etag: "a67109b6f434bcacbfba1714ab2be3f9b7225e95"
$ git hash-object --stdin < /var/tmp/aur-r104-PKGBUILD
a67109b6f434bcacbfba1714ab2be3f9b7225e95

$ git ls-remote https://aur.archlinux.org/unreal-engine.git HEAD
3f03886837439aa01211cebeef3d92fa5e38b81a	HEAD
exit=0
```

Server ETag still equals the git blob SHA-1 of the body; AUR git HEAD unchanged from r102/r103.

The gate is still at line 280 and still says the same thing:

```
$ grep -n 'git ls-remote git@github.com:EpicGames/UnrealEngine' /var/tmp/aur-r104-PKGBUILD
280:  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
$ grep -n '^pkgver=\|^pkgrel=' /var/tmp/aur-r104-PKGBUILD
11:pkgver=5.8.2
12:pkgrel=1
```

---

## 4. The upstream pin — re-verified from a fresh clone (the cited clone is gone)

The r101/r102/r103 receipts verified the pin by running a command against the **pre-existing**
`/tmp/ue-skills-ref` clone. That path no longer exists (§5), so this seat rebuilt the check
independently instead of quoting a stale result:

```
$ git clone -q --depth 1 https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin \
    /tmp/ue-skills-r104-ref
exit=0
$ git -C /tmp/ue-skills-r104-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
exit=0
$ git -C /tmp/ue-skills-r104-ref ls-remote origin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
exit=0

$ diff -r --brief /tmp/ue-skills-r104-ref corpus/knowledge/unreal-mcp/upstream --exclude=.git
(no output)
exit=0
$ find /tmp/ue-skills-r104-ref -type f -not -path '*/.git/*' | wc -l
12
```

A fourth, non-git route confirms the same commit object:

```
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/HEAD --jq '.sha + " " + .commit.committer.date'
a6aa73ada02a9fb1f5415bec491f9942c519b297 2026-09-17T01:28:32Z
exit=0
```

**[O]** The pin is still live and the vendored tree is still byte-identical to it (12/12 files,
`diff -r` clean). The pin claim itself is unchanged; only *which clone* proves it has changed.

---

## 5. NEW — host scratch attrition, and the root cause of it

This is the one substantive delta of the round, and it is host-state, not upstream-state.

### 5.1 Two cited paths are gone

r103's `reports/round-103/pathroot-sweep.md:178-183` recorded both of these as `EXISTS`, and
`:242-244` used the second one to argue a class of citations was "not a defect today":

```
$ ls -d /tmp/ue-skills-ref
ls: cannot access '/tmp/ue-skills-ref': No such file or directory

$ ls -d /tmp/r101seat12-aur-PKGBUILD
ls: cannot access '/tmp/r101seat12-aur-PKGBUILD': No such file or directory

$ git -C /tmp/ue-skills-ref rev-parse HEAD
fatal: cannot change to '/tmp/ue-skills-ref': No such file or directory
exit=128
```

The first of these is not merely a lost scratch file — it is a **documented command that now fails**.
`corpus/knowledge/unreal-mcp/README.md:91-92` and `PROVENANCE.md:36,94-95` instruct a reader to run
exactly `git -C /tmp/ue-skills-ref rev-parse HEAD`, and `PROVENANCE.md:40` names a *second*
independent clone at `/tmp/r101-audit` as the corroboration that "the pin is not an artifact of one
clone". Both are now absent, so neither corroboration is re-runnable as written:

```
$ ls -d /tmp/r101-audit
ls: cannot access '/tmp/r101-audit': No such file or directory
```

`reports/round-104/freshness-pin.md:119-148` (SEAT-43, same round) independently found the same
missing clone and reached the same conclusion. Two seats, same observation.

### 5.2 Root cause — a lane-run `rm -rf`, not the OS

This is not a scheduled clean and not a reboot. The boot is from the previous day and the tmpfiles
timer has not fired since before the paths were created:

```
$ uptime
 16:17:58 up 1 day, 16:18,  1 user,  load average: 13.81, 9.44, 9.18

$ systemctl list-timers --all | grep tmpfiles
Mon 2026-10-19 00:15:01 -03     7h Sun 2026-10-18 00:15:01 -03   16h ago systemd-tmpfiles-clean.timer

$ grep -rn 'tmp' /usr/lib/tmpfiles.d/tmp.conf
11:q /tmp 1777 root root 10d
12:q /var/tmp 1777 root root 30d
```

A 10-day age rule cannot remove files created hours earlier, and the timer last ran at 00:15 —
before the 14:14 creation times of the deleted files. The deletion is in this lane's own session log,
timestamped, as a disk-pressure cleanup:

```
$ (main agent session wire.jsonl, event time 1792350641525 = 2026-10-18T19:10:41.525Z)
rm -rf /tmp/ue-skills-ref /tmp/r101* /tmp/r102* /tmp/r103* /tmp/advgate /tmp/adv* /tmp/nocomm \
       /tmp/gatetest /tmp/seat51-fresh /tmp/empty-path /tmp/u.txt /tmp/v.txt \
       /tmp/r101-claimed.txt /tmp/r101-paths.txt /tmp/r101-audit.txt /tmp/r101-seats.txt \
       /tmp/r101-upstream-files.txt /tmp/r101-vendored-files.txt 2>/dev/null; echo "cleaned"
```

No *scheduled cleaner* exists in this repository — no cron entry, no timer, and no script that runs
one. What a whole-tree sweep does find is only *receipts of past one-off invocations* inside
markdown, i.e. the lane's own habit of wiping its `/tmp` scratch by hand:

```
$ grep -rn 'rm -rf /tmp/r101' reports corpus 2>/dev/null
reports/round-101/probes/byte-identity-reference.md:30:$ rm -rf /tmp/r101-audit && git clone --quiet \
reports/round-101/r101-reviewer-c1.md:48:cd /tmp && rm -rf /tmp/r101review && \
reports/round-101/r101-reviewer-c1.md:413:rm -rf /tmp/r101review && git clone \

$ grep -rn --include='*.sh' --include='*.py' 'rm -rf /tmp/r101\|rm -rf /tmp/ue-skills' . | grep -v '^./.git/'
(no output, 0.465s)
$ command -v tmpreaper tmpwatch crontab atq
(none present)
```

**[O]** There is no script and no scheduled job that would have removed these paths. The removal is
an ad-hoc shell command, which is exactly why the session log is the only surviving account of it —
and why the same thing can happen again on any round.

The shell globs explain the pattern exactly. Everything r103 listed as newly missing matches one of
them; everything that survived does not:

| path | r103 | r104 | matched by |
|---|---|---|---|
| `/tmp/ue-skills-ref` | EXISTS | **MISSING** | literal `/tmp/ue-skills-ref` |
| `/tmp/r101-audit` | EXISTS | **MISSING** | `/tmp/r101*` |
| `/tmp/r101-closeout` | EXISTS | **MISSING** | `/tmp/r101*` |
| `/tmp/r101sentinel` | EXISTS | **MISSING** | `/tmp/r101*` |
| `/tmp/r101work` | EXISTS | **MISSING** | `/tmp/r101*` |
| `/tmp/r101seat12-aur-PKGBUILD` | EXISTS | **MISSING** | `/tmp/r101*` |
| `/tmp/advgate` | (cited) | **MISSING** | `/tmp/adv*` |
| `/tmp/aur-r101-copy` | — | survives | not matched (`r101` is not a prefix) |
| `/tmp/aur-r102-PKGBUILD` | — | survives | not matched |
| `/tmp/aur-r103-PKGBUILD` | — | survives | not matched |
| `/tmp/ue-pkgbuild`, `/tmp/ue_pkgbuild` | EXISTS | survives | not matched |
| `/tmp/up.list`, `/tmp/vend.list` | EXISTS | survives | not matched |
| `/tmp/kimi_strings.txt` | EXISTS | survives | not matched |

The glob hypothesis is testable and it holds: **zero** surviving paths are matched by the globs, and
**every** newly-missing path is. `/tmp/r101-baseline.log` survives precisely because it was created
at 16:18, *after* the 19:10Z (=16:10 local) cleanup.

**[O]** The r103→r104 `/tmp` census therefore moved from **12 EXISTS / 14 MISSING** to
**6 EXISTS / 21 MISSING** — the 6 that went missing are the ones the globs matched, plus
`/tmp/r101seat31` (a path cited by `corpus/`, not listed by r103 because it was already gone then).
The counting command, run verbatim:

```
$ grep -rhoE '/tmp/[A-Za-z0-9._@+-]+' corpus --include='*.md' | sort -u | wc -l
27
$ … | while read p; do [ -e "$p" ] && echo "EXISTS $p"; done
EXISTS /tmp/kimi_strings.txt
EXISTS /tmp/rb_r22.py
EXISTS /tmp/ue-pkgbuild
EXISTS /tmp/ue_pkgbuild
EXISTS /tmp/up.list
EXISTS /tmp/vend.list
EXISTS=6 MISSING=21
```

Note r103 measured 26 distinct paths; the count is now 27 because
`corpus/knowledge/unreal-mcp/gate/README.md` (touched 15:44, i.e. inside the r103 window) cites
`/tmp/advgate`. That is a *new citation appearing in the corpus*, not a change in the world.

### 5.3 The pressure that motivated the cleanup is still present

The cleanup was triggered by `/tmp` exhaustion. That condition has not gone away, and this seat
reproduced it live:

```
$ df -h /tmp | tail -1
tmpfs            16G   13G  3.1G  80% /tmp
$ df -i /tmp | tail -1
tmpfs          1048576 654425 394151   63% /tmp
```

Note the contradiction: `df` reports **3.1G free**, yet writes still fail. `/tmp` is mounted with
`usrquota`, so the binding limit is a per-user quota that `df` does not show:

```
$ mount | grep ' /tmp '
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,nr_inodes=1048576,inode64,huge=advise,usrquota)
```

```
$ dd if=/dev/zero of=/tmp/r104seat44-q1 bs=1M count=200
118304768 bytes (118 MB, 113 MiB) copied, 0.0270268 s, 4.4 GB/s
exit=1                       ← partial write, EDQUOT
$ dd if=/dev/zero of=/tmp/r104seat44-q2 bs=1M count=200
0 bytes copied
exit=1                       ← now zero bytes get through
$ printf 'x' > /tmp/r104seat44-tiny
bash: printf: write error: Disk quota exceeded
$ mktemp -d
/tmp/tmp.4Th4sUPn9V          ← but mktemp still succeeds (dir entry, no data)
```

**[O]** This is the same failure shape r103 recorded for its AUR fetch (`curl: (23) Failure writing
output to destination`, exit 23, 0-byte file) and the same shape that made r103's gate runs return
`rc=1` with empty output. It is **live on this host right now**, and `df -h /tmp` is not a sufficient
health check — a seat that reads only `df` will conclude `/tmp` is fine while `mktemp`+write fails.
The correct probe is an actual write, not a free-space read. (Scratch files this seat created for the
probe were removed; `/tmp` write health was re-confirmed afterwards:
`echo hello > /tmp/r104seat44-ok.txt` → `hello`, and a fresh `git clone` into `/tmp` → `exit=0`,
`a6aa73ad…`.)

This directly substantiates the round's C2 subject: the gate's `mktemp` scratch (lines 74 and 86 of
`run_gate.sh`) lives in exactly this directory.

---

## 6. Host state that bounds every Unreal claim

```
$ ss -ltn | grep -c ':8000'      → 0        # nothing listening on the MCP port
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor
(none on PATH)                                # exit=1
$ find / -xdev -name 'unreal_mcp_proxy*'
(nothing)
$ ls -d /opt/unreal* /usr/share/unreal*
ls: cannot access '/opt/unreal*': No such file or directory
ls: cannot access '/usr/share/unreal*': No such file or directory
```

```
$ git --version    → git version 2.55.0
$ gh --version     → gh version 2.102.0 (2026-09-30)
$ jq --version     → jq-1.8.2
$ python3 -V       → Python 3.14.7
$ node -v          → v26.12.0
$ claude --version → 2.1.302 (Claude Code)
$ godot --version  → 4.7.2.stable.arch_linux.ed1daf0bf
```

**[O]** No editor, no proxy binary, no MCP endpoint. Every live-editor claim in the r101 subtree
remains **unproven by construction** — this seat asserts no Unreal runtime behavior. The r101
Claude-marketplace route is still exercisable on this host (`claude 2.1.302` present) but this seat
did not re-drive it; the r101 §3.1 byte-identity receipts and the `/tmp/fakehome2` cache are intact
on disk (`installed_plugins.json` still records `gitCommitSha a6aa73ad…`).

---

## 7. Changed / unchanged table

| # | Item | r103 value | r104 value | Δ |
|---|---|---|---|---|
| R1 | `git ls-remote` HTTPS `EpicGames/unreal-engine` | `Repository not found.` exit 128 | identical | **unchanged** |
| R1 | `gh api repos/EpicGames/UnrealEngine` | HTTP 404, exit 1 | identical | **unchanged** |
| R1 | bare-`curl` 404 + bogus-name control | `404`/`404` | `404`/`404` | **unchanged** |
| R2 | `git ls-remote` SSH `EpicGames/UnrealEngine` | `Permission denied (publickey)` exit 128 | identical | **unchanged** |
| R3 | `pacman -Si lutris` | `0.5.22-3`, build 2026-10-03 | identical | **unchanged** |
| R3 | `pacman -Qi lutris` | not found, exit 1 | not found, exit 1 | **unchanged** |
| R3 | `docker --version` | `29.7.2` | `29.7.2` | **unchanged** |
| — | AUR `unreal-engine` version | `5.8.2-1` | `5.8.2-1` | **unchanged** |
| — | AUR `PKGBUILD` sha256 / lines | `2059fa7b…45ef`, 527 | `2059fa7b…45ef`, 527 | **unchanged** |
| — | AUR `PKGBUILD` ETag == git blob | `a67109b6…` | `a67109b6…` | **unchanged** |
| — | AUR `LastModified` / git HEAD | `2026-09-12T21:41:28Z` / `3f038868…` | identical | **unchanged** |
| — | shellcheck | present, `0.11.0-158`, lint rc=0 | identical | **unchanged** |
| — | last pacman transaction | `2026-10-18T14:11:04` | same (log mtime == that instant) | **unchanged** |
| — | upstream pin `a6aa73a` | live | still live (fresh clone + REST) | **unchanged** |
| — | Editor / proxy / :8000 | absent / 0 listeners | absent / 0 listeners | **unchanged** |
| **—** | **`/tmp/ue-skills-ref`** | **EXISTS** | **MISSING** — cited command exits 128 | **Δ CHANGED** |
| **—** | **`/tmp/r101-audit`** | **EXISTS** | **MISSING** — PROVENANCE's 2nd clone gone | **Δ CHANGED** |
| **—** | **`/tmp` census (cited paths)** | **12 EXISTS / 14 MISSING** | **6 EXISTS / 21 MISSING** | **Δ CHANGED** |
| **—** | **`/tmp` write health** | EDQUOT seen at 18:31Z | EDQUOT reproduced, **still failing at 19:21Z** | **Δ persistent** |
| — | `/tmp` tmpfs fill | 80% (13G/16G) | 80% (13G/16G) | **unchanged** |
| — | `/tmp` mount options | — | `usrquota` (quota binds before `df` shows full) | **new: explains the gap** |
| — | root cause of the missing paths | — | lane-run `rm -rf /tmp/r101* /tmp/ue-skills-ref` @ `19:10:41Z` | **new** |

**Net: the install picture is unchanged for the third consecutive round; the host scratch picture is
not.** No upstream wall moved. What moved is this lane's own `/tmp` scratch — and one casualty is a
command the pinned subtree tells a reader to run.

---

## 8. What this file does not claim

- No Unreal Editor runtime behavior — the editor is not installed on this host.
- No MCP live-call behavior — no endpoint listens on `:8000`.
- No claim that the wall is permanent: the operator action that opens R1/R2 is Epic-account linking
  (`unrealengine.com` → GitHub link), and the action that opens R3 is an Epic Games Store credential.
  Both are operator-owned.
- The bare-`curl` 404 does **not** prove the engine repo is nonexistent (see the bogus-name control).
- `shellcheck -S warning` exit 0 on the vendored hook is a *linter* receipt, not a correctness proof.
- **The missing `/tmp/ue-skills-ref` says nothing about the pin.** The pin was re-verified this round
  from a fresh clone (§4); what is falsified is only the *durability of a `/tmp`-rooted citation*.
- The `rm -rf` attribution in §5.2 is read from this lane's own session log, which records the exact
  command and its timestamp. It is **[O]** for the command text; the mapping of every individual
  missing path to a specific glob is **[I]** by pattern, supported by the fact that no surviving path
  matches and no matched path survives.
- The `/tmp` write failures in §5.3 are a host disk/quota artifact. They are **not** evidence about
  AUR or Epic availability in either direction.
- The per-user quota limit itself is **not** measurable here — `quota`, `repquota` and `xfs_quota`
  are all absent from this host, so `usrquota` is inferred from the mount options plus the
  `EDQUOT` errno, not read from a quota table.
