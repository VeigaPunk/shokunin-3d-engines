# SEAT-51 — INSTALL-RECHECK (round r105)

- Seat: SEAT-51 (three install routes re-run; no installation attempted)
- Round: r105
- Repo HEAD at capture: `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b`
- Capture: `2026-10-18T20:31:11Z`–`20:31:38Z`
- Predecessor: `reports/round-104/install-recheck.md` (SEAT-44)
- Owned path: this report only. Network response bodies were streamed to stdout/hash tools; no scratch file was created.

**Answer: the three install-route receipts are unchanged from r104.** R1 remains GitHub 404, R2 remains SSH public-key denied, and Lutris remains available in repository metadata but absent from the installed package database. The package, AUR recipe, and runtime-boundary checks below also match r104. The two `/tmp` clone/source paths already reported missing in r104 remain missing; no Unreal Editor or MCP listener appeared.

## 1. The three install routes

### R1 — HTTPS engine repository: 404

Commands run and observed:

```
$ git ls-remote https://github.com/EpicGames/unreal-engine
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found
git_rc=128

$ gh api repos/EpicGames/UnrealEngine
a JSON Not Found response; gh: Not Found (HTTP 404)
gh_rc=1

$ curl -sS -o /dev/null -w 'engine_api=%{http_code}\\n' https://api.github.com/repos/EpicGames/UnrealEngine
engine_api=404
curl_engine_rc=0
$ curl -sS -o /dev/null -w 'bogus_api=%{http_code}\\n' https://api.github.com/repos/EpicGames/definitely-not-a-repo-xyz
bogus_api=404
curl_bogus_rc=0
```

The bogus-name control returns the same HTTP status; the 404 alone does not establish whether the engine repository is absent or private to another account. The `gh api` request and public controls establish that the public GitHub API is responding, not that the caller has Epic engine access.

### R2 — SSH engine repository: public-key denied

Command run with batch mode, host-key prompts disabled, and a 15-second upper bound:

```
$ GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10' timeout 15 git ls-remote git@github.com:EpicGames/UnrealEngine
 git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
Please make sure you have the correct access rights
and the repository exists.
ssh_rc=128
```

### R3 — Lutris route: package metadata present, not installed

```
$ pacman -Si lutris
Repository      : extra
Name            : lutris
Version         : 0.5.22-3
Build Date      : Sat 03 Oct 2026 07:03:32 PM -03
Validated By    : SHA-256 Sum  Signature
pacman_Si_rc=0

$ pacman -Qi lutris
error: package 'lutris' was not found
pacman_Qi_rc=1
$ docker --version
docker version 29.7.2, build a7dcaa6fdb
docker_rc=0
$ grep -ci lutris /var/log/pacman.log
0
grep_rc=1
```

`grep` prints a count of zero and exits 1 because no log line matches. The repository version/build date match r104; Lutris is still not installed and Docker is still present.

## 2. Package install receipt and functional check

```
$ command -v shellcheck
/usr/bin/shellcheck
$ shellcheck --version
version: 0.11.0
$ pacman -Q shellcheck
shellcheck 0.11.0-158
$ grep -i shellcheck /var/log/pacman.log | tail -3
[2026-10-18T14:10:45-0300] [PACMAN] Running 'pacman -S --noconfirm shellcheck'
[2026-10-18T14:11:00-0300] [PACMAN] Running 'pacman -S --noconfirm shellcheck'
[2026-10-18T14:11:04-0300] [ALPM] installed shellcheck (0.11.0-158)
$ grep 'transaction completed' /var/log/pacman.log | tail -1
[2026-10-18T14:11:04-0300] [ALPM] transaction completed
$ stat -c '%y' /var/log/pacman.log
2026-10-18 14:11:04.863114934 -0300
$ shellcheck -S warning corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
(no output)
lint_rc=0
```

Observed package version, install entry, last transaction time, and clean lint result all match r104. The last transaction entry and log mtime are both `2026-10-18T14:11:04`; no later transaction is recorded.

## 3. AUR recipe and public controls

```
$ curl -sS 'https://aur.archlinux.org/rpc/v5/info?arg[]=unreal-engine' | jq -c '.resultcount, (.results[] | {Name,Version,LastModified,Maintainer,NumVotes})'
1
{"Name":"unreal-engine","Version":"5.8.2-1","LastModified":1789249288,"Maintainer":"alexbelm48","NumVotes":75}
$ curl -sSL 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine' | sha256sum
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  -
$ curl -sSI 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine' | grep -i '^etag'
etag: "a67109b6f434bcacbfba1714ab2be3f9b7225e95"
$ git ls-remote https://aur.archlinux.org/unreal-engine.git HEAD
3f03886837439aa01211cebeef3d92fa5e38b81a HEAD
```

The streamed recipe SHA-256, ETag/blob id, AUR version/stamp, and AUR git HEAD match the r104 values. No file was written for the fetch.

Public controls:

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297 HEAD
$ gh api repos/cli/cli --jq '.full_name'
cli/cli
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin --jq '.full_name + " " + .visibility'
EpicGames/unreal-engine-skills-for-claude-code-plugin public
```

The plugin's pinned upstream commit still resolves; these public-repository responses are controls, not proof of access to the Unreal Engine repository.

## 4. Runtime boundary and previously cited scratch paths

```
$ ss -ltn | grep -c ':8000'
0
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor
(no paths; exit 1)
$ for p in /tmp/ue-skills-ref /tmp/r101-audit /tmp/r101seat12-aur-PKGBUILD /tmp/aur-r101-copy /tmp/aur-r102-PKGBUILD /var/tmp/aur-r103-PKGBUILD /var/tmp/aur-r104-PKGBUILD; do test -e "$p" && echo "EXISTS $p" || echo "MISSING $p"; done
MISSING /tmp/ue-skills-ref
MISSING /tmp/r101-audit
MISSING /tmp/r101seat12-aur-PKGBUILD
EXISTS /tmp/aur-r101-copy
EXISTS /tmp/aur-r102-PKGBUILD
EXISTS /var/tmp/aur-r103-PKGBUILD
EXISTS /var/tmp/aur-r104-PKGBUILD
```

The first two missing paths were already recorded in r104; their absence is not evidence about upstream availability. No Unreal Editor executable is on `PATH`, and the `:8000` listener count is zero, so this recheck makes no Unreal runtime or live MCP claim.

## 5. Changed / unchanged

| Item | r104 | r105 observed | Result |
|---|---|---|---|
| R1 HTTPS Git / `gh` / API | 404 | same messages/statuses | unchanged |
| R2 SSH Git | public-key denied, rc 128 | same, rc 128 | unchanged |
| R3 Lutris / Docker | repo `0.5.22-3`; absent; Docker `29.7.2` | same | unchanged |
| `shellcheck` | `0.11.0-158`, lint rc 0 | same; last package transaction still `14:11:04 -0300` | unchanged |
| AUR recipe | version `5.8.2-1`; SHA `2059fa7b…45ef`; ETag `a67109b6…`; HEAD `3f038868…` | same | unchanged |
| Public plugin pin | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | same live HEAD | unchanged |
| Unreal runtime boundary | editor absent; `:8000` count 0 | same | unchanged |
| `/tmp/ue-skills-ref`, `/tmp/r101-audit` | missing | missing | unchanged from r104 |

**Net: zero install-route or package-state deltas from r104.** No Unreal installation was attempted; the editor remains absent and no live-engine behavior is asserted.
