# SEAT-74 — INSTALL-RECHECK (round r106)

- Seat: SEAT-74 (three install receipts re-run; no installation attempted)
- Round: r106
- Repo HEAD at capture: `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`r105 report-last`; work `3634bc0`)
- Capture: `2026-10-18T21:21:53Z`–`21:26:43Z`
- Predecessor: `reports/round-105/install-recheck.md` (SEAT-51)
- Owned path: this report only. Probe scratch (not a deliverable): `reports/round-106/scratch/seat74-pkgbuild.stream` (527 lines, 23671 bytes) plus `seat74-gh-engine.out` / `seat74-gh-engine.err`. Nothing was written under `/tmp`. No `git commit/push/checkout/reset`.

**Answer: the three install receipts are unchanged from r105.** R1 remains GitHub 404 for the authenticated `VeigaPunk` account, R2 remains SSH public-key denied, and Lutris remains in repository metadata but absent from the installed package database. No Unreal Editor binary, process, or `:8000` listener appeared, so this recheck makes no Unreal runtime or live MCP claim.

The only measured host-state delta versus the corpus snapshots those receipts are cited from is disk: `df -h /` is now `930G 160G 756G 18% /`, not `780G` free at `15%`. That does not change any install route. Two citation defects are queued in §6; this seat did not edit the cited files.

## 1. The three install receipts

### R1 — HTTPS engine repository: 404

Commands run and observed (`2026-10-18T21:21:53Z`–`21:21:55Z`, then `gh` streams split at `21:24:32Z`):

```
$ git ls-remote https://github.com/EpicGames/unreal-engine
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found
git_rc=128

$ gh api repos/EpicGames/UnrealEngine
stdout: {"message":"Not Found","documentation_url":"https://docs.github.com/rest/repos/repos#get-a-repository","status":"404"}
stderr: gh: Not Found (HTTP 404)
gh_rc=1

$ curl -sS -o /dev/null -w 'engine_api=%{http_code}\n' https://api.github.com/repos/EpicGames/UnrealEngine
engine_api=404
curl_engine_rc=0
$ curl -sS -o /dev/null -w 'bogus_api=%{http_code}\n' https://api.github.com/repos/EpicGames/definitely-not-a-repo-xyz
bogus_api=404
curl_bogus_rc=0
$ curl -sS -o /dev/null -w 'engine_html=%{http_code}\n' https://github.com/EpicGames/UnrealEngine
engine_html=404
curl_html_rc=0

$ gh auth status
github.com
  ✓ Logged in to github.com account VeigaPunk (keyring)
  - Active account: true
  - Git operations protocol: https
  - Token: gho_************************************
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
gh_auth_rc=0
```

The bogus-name control returns the same HTTP status, so the 404 alone does not establish whether the engine repository is absent or private to another account. The token has `repo` scope, and `gh api repos/cli/cli` returned `cli/cli` (rc 0) at `21:22:03Z` in this same capture, so this is not an auth-token failure and not a dead public API. It is the same account-gated wall recorded since r101. No clone was attempted.

### R2 — SSH engine repository: public-key denied

Command run with batch mode, host-key prompts disabled, and a 15-second upper bound (`2026-10-18T21:21:55Z`–`21:21:56Z`):

```
$ GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10' timeout 15 git ls-remote git@github.com:EpicGames/UnrealEngine
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
ssh_rc=128
```

That is the command the current AUR `prepare()` gate runs (recipe line 280, §3). The build would still abort before compiling. No key was added and no engine clone was attempted. **Engine install remains blocked pending operator Epic-account linking.**

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
$ command -v lutris
(no stdout)
lutris_bin_rc=1
$ docker --version
Docker version 29.7.2, build a7dcaa6fdb
docker_rc=0
$ pacman -Q docker
docker 1:29.7.2-1
$ grep -ci lutris /var/log/pacman.log
0
grep_rc=1
```

`grep` prints a count of zero and exits 1 because no log line matches. Repository version and build date match r105. Lutris is still not installed; Docker is still present and was not used to pull or run anything. The mechanism is one `pacman -S lutris` away; the blocking step remains an operator-owned Epic Games Store login. **OPERATOR-GATED, not host-blocked.** This seat did not install Lutris.

## 2. Package install receipt and functional check

Supporting receipt, not a fourth install route. Observed `2026-10-18T21:21:56Z`:

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

Package version, install entry, last transaction time, log mtime, and clean warning-level lint all match r105. No later transaction is recorded.

## 3. AUR recipe and public controls

Observed `2026-10-18T21:22:03Z`–`21:22:15Z`, with the HEAD line re-run at `21:24:32Z` (`git version 2.55.0`):

```
$ curl -sS 'https://aur.archlinux.org/rpc/v5/info?arg[]=unreal-engine' | jq -c '.resultcount, (.results[] | {Name,Version,LastModified,Maintainer,NumVotes,URL,OutOfDate})'
1
{"Name":"unreal-engine","Version":"5.8.2-1","LastModified":1789249288,"Maintainer":"alexbelm48","NumVotes":75,"URL":"https://www.unrealengine.com/","OutOfDate":null}
$ date -u -d @1789249288 +%Y-%m-%dT%H:%M:%SZ
2026-09-12T21:41:28Z
$ curl -sSL 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine' | sha256sum
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  -
$ curl -sSI 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine' | grep -i '^etag'
etag: "a67109b6f434bcacbfba1714ab2be3f9b7225e95"
$ git ls-remote https://aur.archlinux.org/unreal-engine.git HEAD
3f03886837439aa01211cebeef3d92fa5e38b81a	HEAD
3f03886837439aa01211cebeef3d92fa5e38b81a	HEAD
```

The streamed recipe SHA-256, ETag, AUR version/stamp, and AUR git HEAD match r105. `git ls-remote` printed that same sha on two identical `HEAD` lines (re-run, same shape). r105 recorded one line. The pin did not change; only this client's output shape did. `OutOfDate` is null.

The same blob saved to `reports/round-106/scratch/seat74-pkgbuild.stream` hashes to the same sha and is 527 lines. `pkgver=5.8.2`, `pkgrel=1`. Header comment still says the source is about 200 MiB plus ~11 GiB of dependencies and may take several hours to compile. Line 280 is still the SSH gate:

```
  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
```

Lines 327 and 336 still `git clone --depth=1 --branch=${pkgver}-release git@github.com:EpicGames/UnrealEngine`. Line 341 is `git reset --hard ${pkgver}-release`, not a clone. See §6.

Leftover copies, not created by this seat, still match that sha and line count:

Per-file `wc -l` and `sha256sum` inside the loop that also tested those four paths (`2026-10-18T21:22:14Z`):

```
-- /tmp/aur-r101-copy
527 /tmp/aur-r101-copy
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /tmp/aur-r101-copy
-- /tmp/aur-r102-PKGBUILD
527 /tmp/aur-r102-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /tmp/aur-r102-PKGBUILD
-- /var/tmp/aur-r103-PKGBUILD
527 /var/tmp/aur-r103-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /var/tmp/aur-r103-PKGBUILD
-- /var/tmp/aur-r104-PKGBUILD
527 /var/tmp/aur-r104-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /var/tmp/aur-r104-PKGBUILD
```

Public controls, same window:

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297	HEAD
$ gh api repos/cli/cli --jq '.full_name'
cli/cli
$ gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin --jq '.full_name + " " + .visibility'
EpicGames/unreal-engine-skills-for-claude-code-plugin public
```

The plugin pin still resolves and is public. These responses are controls, not proof of access to the Unreal Engine repository.

`PROVINCE.md:42-44` was re-read. The standing install directive quoted in `corpus/knowledge/unreal-mcp/PROVENANCE.md` §4 still matches those lines: installs only inside a declared round scope, with operator-visible receipts, and no silent unrelated installs. This seat stayed inside that rule.

## 4. Runtime boundary and previously cited scratch paths

Observed `2026-10-18T21:22:09Z`–`21:22:21Z`:

```
$ ss -ltn | grep -c ':8000'
0
ss_grep_rc=1
$ ss -ltnp | grep 8000 || echo no_8000_line
no_8000_line
$ command -v UnrealEditor UnrealEditor-Cmd UE4Editor
(no stdout)
cmd_rc=1
$ which UnrealEditor UnrealEditor-Cmd
which: no UnrealEditor in (/home/vgpnk/.grok/bin:/home/vgpnk/.kimi-code/bin:/home/vgpnk/.local/share/mise/installs/node/latest/bin:/home/vgpnk/.local/share/mise/shims:/run/user/1000/fnm_multishells/1974941_1792342566751/bin:/home/vgpnk/.local/share/fnm:/home/vgpnk/.local/share/omarchy/bin:/home/vgpnk/.opencode/bin:/home/vgpnk/.local/bin:/run/user/1000/fnm_multishells/1630_1792206008234/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/run/user/1000/fnm_multishells/1981442_1792342591527/bin)
which: no UnrealEditor-Cmd in (/home/vgpnk/.grok/bin:/home/vgpnk/.kimi-code/bin:/home/vgpnk/.local/share/mise/installs/node/latest/bin:/home/vgpnk/.local/share/mise/shims:/run/user/1000/fnm_multishells/1974941_1792342566751/bin:/home/vgpnk/.local/share/fnm:/home/vgpnk/.local/share/omarchy/bin:/home/vgpnk/.opencode/bin:/home/vgpnk/.local/bin:/run/user/1000/fnm_multishells/1630_1792206008234/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/run/user/1000/fnm_multishells/1981442_1792342591527/bin)
which_rc=2
$ pgrep -a UnrealEditor || echo no UnrealEditor
no UnrealEditor
$ pgrep -a UE4Editor || echo no UE4Editor
no UE4Editor
$ ls -d /opt/unreal* /usr/share/unreal* /opt/UnrealEngine
ls: cannot access '/opt/unreal*': No such file or directory
ls: cannot access '/usr/share/unreal*': No such file or directory
ls: cannot access '/opt/UnrealEngine': No such file or directory
ls_rc=2
$ for p in /tmp/ue-skills-ref /tmp/r101-audit /tmp/r101seat12-aur-PKGBUILD /tmp/aur-r101-copy /tmp/aur-r102-PKGBUILD /var/tmp/aur-r103-PKGBUILD /var/tmp/aur-r104-PKGBUILD /var/tmp/aur-r105-PKGBUILD; do test -e "$p" && echo "EXISTS $p" || echo "MISSING $p"; done
MISSING /tmp/ue-skills-ref
MISSING /tmp/r101-audit
MISSING /tmp/r101seat12-aur-PKGBUILD
EXISTS /tmp/aur-r101-copy
EXISTS /tmp/aur-r102-PKGBUILD
EXISTS /var/tmp/aur-r103-PKGBUILD
EXISTS /var/tmp/aur-r104-PKGBUILD
MISSING /var/tmp/aur-r105-PKGBUILD
```

`grep -c` prints 0 and exits 1 when nothing matches. `/var/tmp/aur-r105-PKGBUILD` was not expected: r105 streamed the recipe and recorded no scratch file. The first three missing paths were already missing in r105; their absence is not evidence about upstream availability. No Unreal Editor executable is on `PATH`, no editor process is running, and nothing is listening on `:8000`.

Host snapshot at `2026-10-18T21:22:21Z`, for the dated note in §6 only:

```
$ uname -r
7.2.3-arch1-3
$ nproc
32
$ free -g
               total        used        free      shared  buff/cache   available
Mem:              30          20           0           9          18           9
Swap:             34          10          23
$ df -h /
Filesystem        Size  Used Avail Use% Mounted on
/dev/mapper/root  930G  160G  756G  18% /
$ jq --version
jq-1.8.2
$ python3 --version
Python 3.14.7
$ node --version
v26.12.0
```

`node` resolved to `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`. Cores, RAM total, jq, Python, and node match the corpus host lines. Disk does not.

## 5. Changed / unchanged

| Item | r105 | r106 observed | Result |
|---|---|---|---|
| R1 HTTPS Git / `gh` / API | 404, rc 128 / 1 / 404 | same messages and statuses; account still `VeigaPunk` with `repo` scope | unchanged |
| R2 SSH Git | public-key denied, rc 128 | same, rc 128 | unchanged |
| R3 Lutris / Docker | repo `0.5.22-3`; absent; Docker `29.7.2` | same; `lutris` binary also absent; `docker 1:29.7.2-1` | unchanged |
| `shellcheck` | `0.11.0-158`, lint rc 0 | same; last package transaction still `14:11:04 -0300` | unchanged |
| AUR recipe | version `5.8.2-1`; SHA `2059fa7b…45ef`; ETag `a67109b6…`; HEAD `3f038868…` | same sha/ETag/version/HEAD; `git ls-remote` printed the sha twice | pin unchanged |
| Public plugin pin | `a6aa73ada02a9fb1f5415bec491f9942c519b297` | same live HEAD, visibility `public` | unchanged |
| Unreal runtime boundary | editor absent; `:8000` count 0 | editor absent (PATH, `which`, `pgrep`, `/opt`); `:8000` count 0 | unchanged |
| `/tmp/ue-skills-ref`, `/tmp/r101-audit`, `/tmp/r101seat12-aur-PKGBUILD` | missing | missing | unchanged |
| Disk free on `/` | not re-measured in r105; corpus still says 780G / 15% | `756G` avail, `18%` used | host-state delta, not an install-route delta |

**Net: zero install-route or package-state deltas from r105.** No Unreal installation was attempted. The editor remains absent and no live-engine behavior is asserted.

## 6. Queued defects (not edited)

This seat's chunk is this report. The files below were not modified. Corrections, if landed, should be dated notes, not silent rewrites of historical receipts.

1. **`corpus/knowledge/unreal-mcp/PROVENANCE.md:203` — wrong line.** It says lines 327/336/341 of the AUR PKGBUILD clone `git@github.com:EpicGames/UnrealEngine`. On the live blob (sha `2059fa7b…45ef`, same sha r105 recorded), lines 327 and 336 do clone that remote. Line 341 is `git reset --hard ${pkgver}-release`. The defect is in the citation, not in the wall: the SSH gate at line 280 and the two clones are still there.
2. **Disk snapshot cited as host reality is stale as of `2026-10-18T21:22:21Z`.** `df -h /` observed `/dev/mapper/root  930G  160G  756G  18% /`. These lines still say 780G free / 15% used: `corpus/knowledge/unreal-mcp/README.md:63`, `PROVENANCE.md:238`, `adaptation-kimi.md:15`, and the host-capacity rows in `executability/actors-scene.md:286`, `animation-controlrig.md:185`, `assets-content.md:372`, `blueprints.md:127`, `gameplay-gas.md:174`, `materials.md:207` (that one even quotes `930G 133G 780G 15%`), `meshes-textures.md:270`, `sequencer.md:287` and `:296`, `testing-automation.md:266`. Treat those as r101-era snapshots. Cores (32), RAM total (30 GB), and the install-wall classification are still what this seat measured. Do not rewrite the old receipts in place.
3. **`PROVENANCE.md:183` names `/tmp/r101seat12-aur-PKGBUILD` as the fetched recipe.** That path is missing, as it already was in r104 and r105. The 527-line / `pkgver=5.8.2` claim still matches the live AUR blob verified above. The path citation is historical, not a live file.
