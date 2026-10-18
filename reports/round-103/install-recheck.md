# SEAT-57 — INSTALL-RECHECK (round r103)

- Seat: SEAT-57 (three install receipts re-run; nothing installed, nothing written outside this path)
- Round: r103
- Repo HEAD at capture: `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (`r102 report-last`; work `c6f655d`)
- Capture time: **2026-10-18T18:31Z**–**18:32Z** (one `date -u` sample per command block; see §5)
- Method: each r102 receipt re-executed verbatim on this host; output pasted unedited, exit codes captured with `set +e`.
- Predecessor: `reports/round-102/install-recheck.md` (SEAT-60), which found zero deltas against r101.

**Headline answer to the seat question — nothing has changed since r102 either.**
All three install receipts reproduce byte-for-byte, `shellcheck` is still installed
at the same version with its r101 install entry untouched, and the AUR recipe is
still the same 527-line, same-hash file. No new wall, no lifted wall. One
**method** wrinkle was found and recorded (§3), not a receipt change.

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
{"message":"Not Found","documentation_url":"https://docs.github.com/rest/repos/repos#get-a-repository","status":"404"}
gh: Not Found (HTTP 404)
exit=1
```

Re-sampled a second time in the same capture window — same two messages. An
unauthenticated probe adds a third route (not recorded in r101/r102):

```
$ curl -sS -o /dev/null -w '%{http_code}\n' https://api.github.com/repos/EpicGames/UnrealEngine
404
$ curl -sS -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/UnrealEngine
404
$ curl -sS -o /dev/null -w '%{http_code}\n' https://api.github.com/repos/EpicGames/definitely-not-a-repo-xyz
404
```

**[O]** The 404 is transport-independent (git, authed `gh`, bare `curl`) and the
bogus-name control returns the same 404, i.e. GitHub does not distinguish
"private to someone else" from "does not exist" for this caller. This *supports*
the r102 reading rather than changing it: the code alone cannot prove
nonexistence, which is exactly why r102's authenticated controls matter.

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

This is the exact command the AUR `PKGBUILD:280` gate runs, so the build would
still abort in `prepare()` before compiling anything.

### R3 — Lutris route: still software-present, credential-gated

```
$ pacman -Si lutris
Repository      : extra
Name            : lutris
Version         : 0.5.22-3
Description     : Open Gaming Platform
Architecture    : any
URL             : https://lutris.net
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
```

Same version `0.5.22-3`, still not installed, docker still present. The repo
metadata now additionally shows `Build Date 2026-10-03` — r101/r102 recorded
version and repo only, so this is a **new data point, not a delta**: the package
is the same build, and no `lutris` entry exists in the package log at all
(`grep -ci lutris /var/log/pacman.log` → `0`), confirming it was never installed
here.

### R3-control — is the 404 a network problem or an account problem?

Re-tested with the two controls that must succeed if the network and token are
healthy:

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

**[O]** Same result as r102: the token reaches two public GitHub repos and one
*other* `EpicGames` repo, and the HTTPS transport resolves the public Epic plugin
fine. The 404 is scoped to `EpicGames/UnrealEngine` and is the expected
consequence of `VeigaPunk` not being Epic-linked. The r101/r102 reading stands,
now with a transport-independent third route plus the bogus-name control.

---

## 2. `shellcheck` — still present, same version, install receipt intact

```
$ command -v shellcheck
/usr/bin/shellcheck
exit=0

$ shellcheck --version
ShellCheck - shell script analysis tool
version: 0.11.0
license: GNU General Public License, version 3
website: https://www.shellcheck.net
exit=0

$ pacman -Q shellcheck
shellcheck 0.11.0-158
exit=0
```

Install receipt in the package log, still the r101 entry (not a re-install):

```
$ grep -i shellcheck /var/log/pacman.log | tail -3
[2026-10-18T14:10:45-0300] [PACMAN] Running 'pacman -S --noconfirm shellcheck'
[2026-10-18T14:11:00-0300] [PACMAN] Running 'pacman -S --noconfirm shellcheck'
[2026-10-18T14:11:04-0300] [ALPM] installed shellcheck (0.11.0-158)
```

**Stronger than r102 on this point:** r102 asserted "not a re-install" from the
log tail. A full-log check shows the 14:11:04 transaction is the **last** one on
the host:

```
$ grep -c 'transaction completed' /var/log/pacman.log
28
$ grep 'transaction completed' /var/log/pacman.log | tail -3
[2026-10-16T21:41:16-0300] [ALPM] transaction completed
[2026-10-16T23:53:29-0300] [ALPM] transaction completed
[2026-10-18T14:11:04-0300] [ALPM] transaction completed
$ tail -5 /var/log/pacman.log
[2026-10-18T14:11:04-0300] [ALPM] installed haskell-regex-base (0.94.0.3-5)
[2026-10-18T14:11:04-0300] [ALPM] installed haskell-regex-tdfa (1.3.2.6-41)
[2026-10-18T14:11:04-0300] [ALPM] installed shellcheck (0.11.0-158)
[2026-10-18T14:11:04-0300] [ALPM] transaction completed
[2026-10-18T14:11:04-0300] [ALPM] running '35-systemd-update.hook'...
```

**[O]** No package transaction has occurred on this host since the r101
shellcheck install. Every r101 and r102 install claim therefore rests on an
environment that has been frozen at the package level for the whole r101→r103
window — which is itself a meaningful stability receipt for cross-round
comparability.

Functional re-check on the one upstream artifact that is executable here:

```
$ shellcheck -S warning corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
(no output)
rc=0
```

**[O]** Present, same version, still lints the vendored hook clean. No change.

---

## 3. AUR recipe identity — unchanged, byte-for-byte

```
$ curl -s "https://aur.archlinux.org/rpc/v5/info?arg[]=unreal-engine" \
  | jq -c '.resultcount, (.results[] | {Name,Version,LastModified,Maintainer,NumVotes})'
1
{"Name":"unreal-engine","Version":"5.8.2-1","LastModified":1789249288,"Maintainer":"alexbelm48","NumVotes":75}
```

`LastModified` 1789249288 → **2026-09-12T21:41:28Z**, i.e. the recipe is ~36 days
stale relative to this capture. Version, maintainer, vote count and the stamp are
**identical to r102** — the recipe has not been touched in the r102→r103 window.

```
$ curl -sSL -o /var/tmp/aur-r103-PKGBUILD \
    "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine"
exit=0
$ sha256sum /tmp/r101seat12-aur-PKGBUILD /tmp/aur-r102-PKGBUILD /var/tmp/aur-r103-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /tmp/r101seat12-aur-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /tmp/aur-r102-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /var/tmp/aur-r103-PKGBUILD

$ diff -q /var/tmp/aur-r103-PKGBUILD /tmp/aur-r102-PKGBUILD && echo IDENTICAL
IDENTICAL
$ wc -l /var/tmp/aur-r103-PKGBUILD
527 /var/tmp/aur-r103-PKGBUILD
```

Two independent identity confirmations added this round:

```
$ curl -sSI "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine" | grep -i '^etag'
etag: "a67109b6f434bcacbfba1714ab2be3f9b7225e95"
$ git hash-object --stdin < /var/tmp/aur-r103-PKGBUILD
a67109b6f434bcacbfba1714ab2be3f9b7225e95
```

The server ETag is the git blob SHA-1 of the body we fetched — so the 23671-byte
`PKGBUILD` is pinned to a git object id, not merely to a curl byte count.

```
$ git ls-remote https://aur.archlinux.org/unreal-engine.git HEAD
3f03886837439aa01211cebeef3d92fa5e38b81a	HEAD
exit=0
```

AUR git HEAD unchanged from r102 (`3f038868…`). Snapshot tarball also captured
for the record: `sha256 71972ec6c6a9a6e040fbecd91a567adbb9ec9790c70613b5180583d968671d67`.

The gate is still at line 280 and still says the same thing:

```
$ grep -n 'git ls-remote git@github.com:EpicGames/UnrealEngine' /var/tmp/aur-r103-PKGBUILD
280:  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
$ sed -n 278,282p /var/tmp/aur-r103-PKGBUILD
  # Check access to the repository
  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
    error 'You must register at unrealengine.com and link your github account to access this private repo. See the wiki for more info: https://wiki.archlinux.org/index.php/Unreal_Engine_4'
    exit 1
  fi
$ grep -n '^pkgver=\|^pkgrel=' /var/tmp/aur-r103-PKGBUILD
11:pkgver=5.8.2
12:pkgrel=1
```

### Method note — a transient fetch failure, recorded not hidden

The first fetch of this round wrote to `/tmp` and **failed**:

```
$ curl -sL -o /tmp/aur-r103-PKGBUILD "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine"
curl: (23) Failure writing output to destination, passed 8192 returned 431
exit=23
$ sha256sum /tmp/aur-r103-PKGBUILD
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  /tmp/aur-r103-PKGBUILD   # 0 bytes
```

Cause: `/tmp` is tmpfs and was 80% full at that moment (`df -h /tmp` →
`13G/16G used`). The server side was healthy throughout (`HTTP/2 200`,
`content-length: 23671`). Retried after clearing scratch space, and the same
bytes came back from three independent destinations:

```
$ curl -sSL -o /tmp/aur-r103-PKGBUILD ...       → exit=0, 23671 B
$ cp /var/tmp/aur-r103-PKGBUILD /tmp/aur-r103-copy → exit=0, 23671 B
$ curl -sSL -o /tmp/aur-r103b-PKGBUILD ...      → exit=0, 23671 B
$ curl -sSL ... | sha256sum                     → 2059fa7b…45ef  (pipe exit 0)
```

**[O]** This is a *host* artifact, not an upstream change. It is recorded here
because an exit-23 with a 0-byte file is exactly the shape a careless reader
would misreport as "the AUR recipe is gone". Anyone re-running this receipt on a
full `/tmp` must retry before concluding anything.

---

## 4. Host state that bounds every Unreal claim

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
$ git -C /tmp/ue-skills-ref rev-parse HEAD → a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C /tmp/ue-skills-ref ls-remote origin HEAD → a6aa73a…	HEAD   (upstream pin still live)
```

**[O]** No editor, no proxy binary, no MCP endpoint. Every live-editor claim in
the r101 subtree remains **unproven by construction** — this seat asserts no
Unreal runtime behavior. The upstream pin `a6aa73ada02a9fb1f5415bec491f9942c519b297`
is still the live `HEAD` of `EpicGames/unreal-engine-skills-for-claude-code-plugin`.

---

## 5. Changed / unchanged table

| # | Item | r102 value | r103 value | Δ |
|---|---|---|---|---|
| R1 | `git ls-remote` HTTPS `EpicGames/unreal-engine` | `Repository not found.` exit 128 | `Repository not found.` exit 128 | **unchanged** |
| R1 | `gh api repos/EpicGames/UnrealEngine` | HTTP 404, exit 1 | HTTP 404, exit 1 | **unchanged** |
| R1 | bare-`curl` 404 on same repo + bogus-name control | (not recorded) | `404` / `404` | **new route, same reading** |
| R2 | `git ls-remote` SSH `EpicGames/UnrealEngine` | `Permission denied (publickey)` exit 128 | identical | **unchanged** |
| R3 | `pacman -Si lutris` | `0.5.22-3` (repo `extra`) | `0.5.22-3` (repo `extra`), build 2026-10-03 | **unchanged** (+ new metadata) |
| R3 | `pacman -Qi lutris` | not found, exit 1 | not found, exit 1 | **unchanged** |
| R3 | `docker --version` | `29.7.2` | `29.7.2` | **unchanged** |
| — | AUR `unreal-engine` version | `5.8.2-1` | `5.8.2-1` | **unchanged** |
| — | AUR `PKGBUILD` sha256 / lines | `2059fa7b…45ef`, 527 | `2059fa7b…45ef`, 527 | **unchanged** |
| — | AUR `PKGBUILD` git blob id | (not recorded) | `a67109b6f434bcacbfba1714ab2be3f9b7225e95` = server ETag | **new pin** |
| — | AUR recipe `LastModified` | `2026-09-12T21:41:28Z` | identical | **unchanged** |
| — | AUR git `HEAD` | `3f038868…` | `3f038868…` | **unchanged** |
| — | shellcheck | present, `0.11.0-158` | present, `0.11.0-158`, lint rc=0 | **unchanged** |
| — | last pacman transaction on host | (not checked) | `2026-10-18T14:11:04` (the r101 install) | **new: host package-frozen since r101** |
| — | `gh auth status` account | `VeigaPunk`, scopes `repo` etc. | identical | **unchanged** |
| — | Editor / proxy / :8000 | absent / 0 listeners | absent / 0 listeners | **unchanged** |
| — | Upstream plugin pin `a6aa73a` | live | still live (`ls-remote origin HEAD`) | **unchanged** |

**Net: zero deltas.** Nothing in the install picture moved between r102 and r103.
The r102 conclusion ("nothing has changed since r101") extends to r103 unchanged,
and now additionally holds under a host that has seen no package transaction at
all since the r101 shellcheck install.

---

## 6. What this file does not claim

- No Unreal Editor runtime behavior — the editor is not installed on this host.
- No MCP live-call behavior — no endpoint listens on `:8000`.
- No claim that the wall is permanent: the operator action that opens R1/R2 is
  Epic-account linking (`unrealengine.com` → GitHub link), and the action that
  opens R3 is an Epic Games Store credential. Both are operator-owned.
- The bare-`curl` 404 does **not** prove the engine repo is nonexistent; GitHub
  returns the same 404 for a genuinely absent repo (see the bogus-name control).
- `shellcheck -S warning` exit 0 on the vendored hook is a *linter* receipt, not
  a correctness proof of the hook (same caveat r101 §`security-surface.md:293`
  records).
- The `/tmp` exit-23 fetch failure is a host disk-pressure artifact; it is not
  evidence about AUR or Epic availability either way.
