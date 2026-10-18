# SEAT-60 — INSTALL-RECHECK (round r102)

- Seat: SEAT-60 (install receipts re-run; no install attempted, no file written outside this path)
- Round: r102
- Repo HEAD at capture: `2c99b7b8155841617d844c609813afcba77aa207` (`r101 report-last`; work commit `1659c036`)
- Capture time: **2026-10-18T17:42Z**. r101's own timestamps put its receipts ~25–30 minutes earlier: `PROVENANCE.md:28` records its clone/verify run at `2026-10-18T17:17:31Z`, `PROVENANCE.md:251` a snapshot at `17:18:24Z`, and the AUR `PKGBUILD` it quotes was fetched to `/tmp/r101seat12-aur-PKGBUILD` at `14:14:15-03:00` = `17:14:15Z`.
- Method: each receipt re-executed verbatim on this host; output pasted unedited, exit codes captured with `set +e`.

**Headline answer to the seat question — nothing has changed since r101.**
All three install receipts reproduce byte-for-byte, the one already-installed
tool is still installed at the same version, and the AUR recipe is still the
same 527-line, same-hash file. No new wall, no lifted wall.

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

Identical to r101 (`PROVENANCE.md` §5 R1): same message, same 404, same exit
codes. (The r101 copy printed `exit 128` without a code capture; captured
explicitly here.)

### R2 — AUR route, SSH form: still publickey-denied

```
$ git ls-remote git@github.com:EpicGames/UnrealEngine
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

$ pacman -Qi lutris
error: package 'lutris' was not found
exit=1

$ docker --version
Docker version 29.7.2, build a7dcaa6fdb
```

Same version `0.5.22-3`, still not installed, docker still present.

### R3-control — is the 404 a network problem or an account problem?

r101 asserted the 404 means "not Epic-linked" rather than "network down". That
assertion is re-tested here with two controls that must succeed if the network
and token are healthy:

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

**[O]** The same token reaches two public GitHub repos and one *other* EpicGames
repo, and the HTTPS transport resolves the public Epic plugin fine. So the 404
is scoped to `EpicGames/UnrealEngine` (the private engine repo) and is the
expected consequence of `VeigaPunk` not being Epic-linked — the r101 reading
stands, now with a control rather than an inference.

---

## 2. `shellcheck` — still present, same version, install receipt intact

The round brief asks specifically whether shellcheck is still present (r101
installed it mid-round).

```
$ command -v shellcheck
/usr/bin/shellcheck

$ shellcheck --version
ShellCheck - shell script analysis tool
version: 0.11.0
license: GNU General Public License, version 3
website: https://www.shellcheck.net

$ pacman -Q shellcheck
shellcheck 0.11.0-158
```

Install receipt in the package log, still the r101 entry (not a re-install):

```
$ grep -i shellcheck /var/log/pacman.log | tail -3
[2026-10-18T14:10:45-0300] [PACMAN] Running 'pacman -S --noconfirm shellcheck'
[2026-10-18T14:11:00-0300] [PACMAN] Running 'pacman -S --noconfirm shellcheck'
[2026-10-18T14:11:04-0300] [ALPM] installed shellcheck (0.11.0-158)
```

Functional re-check on the one upstream artifact that is executable here (r101
§`probes/hook-shellcheck.md`):

```
$ shellcheck -S warning corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
(no output)
rc=0
```

**[O]** Present, same version, still lints the vendored hook clean. No change.

---

## 3. AUR recipe identity — unchanged, byte-for-byte

r101 fetched the recipe to `/tmp/r101seat12-aur-PKGBUILD`. That copy still
exists, so the fetch can be *diffed* rather than merely re-observed:

```
$ sha256sum /tmp/r101seat12-aur-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /tmp/r101seat12-aur-PKGBUILD

$ curl -sL -o /tmp/aur-r102-PKGBUILD \
    "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine"
$ sha256sum /tmp/aur-r102-PKGBUILD
2059fa7b5b00be5542137719868c777cd8eb2c3309989dd6010811b7488145ef  /tmp/aur-r102-PKGBUILD

$ diff -u /tmp/aur-r101-copy /tmp/aur-r102-PKGBUILD && echo IDENTICAL
IDENTICAL
```

The gate is still at line 280 and still says the same thing:

```
$ wc -l /tmp/aur-r102-PKGBUILD
527 /tmp/aur-r102-PKGBUILD

$ sed -n 278,282p /tmp/aur-r102-PKGBUILD
  # Check access to the repository
  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
    error 'You must register at unrealengine.com and link your github account to access this private repo. See the wiki for more info: https://wiki.archlinux.org/index.php/Unreal_Engine_4'
    exit 1
  fi

$ grep -n '^pkgver=\|^pkgrel=' /tmp/aur-r102-PKGBUILD
11:pkgver=5.8.2
12:pkgrel=1
```

AUR RPC, for the version and the freshness stamp:

```
$ curl -s "https://aur.archlinux.org/rpc/v5/info?arg[]=unreal-engine" \
  | jq -c '.resultcount, (.results[] | {Name,Version,LastModified,Maintainer,NumVotes})'
1
{"Name":"unreal-engine","Version":"5.8.2-1","LastModified":1789249288,"Maintainer":"alexbelm48","NumVotes":75}
```

`LastModified` 1789249288 → **2026-09-12T21:41:28Z**, i.e. the recipe is ~36 days
stale relative to this capture and has not been touched since well before r101.
Version, maintainer and vote count all match r101 §G1 exactly.

AUR git ref (new data point not recorded in r101):

```
$ git ls-remote https://aur.archlinux.org/unreal-engine.git HEAD
3f03886837439aa01211cebeef3d92fa5e38b81a	HEAD
exit=0
```

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
$ claude --version → 2.1.302 (Claude Code)
$ git -C /tmp/ue-skills-ref rev-parse HEAD → a6aa73ada02a9fb1f5415bec491f9942c519b297
$ git -C /tmp/ue-skills-ref ls-remote origin HEAD → a6aa73a…	HEAD   (upstream pin still live)
```

**[O]** No editor, no proxy binary, no MCP endpoint. Every live-editor claim in
the r101 subtree remains **unproven by construction** — this seat asserts no
Unreal runtime behavior.

---

## 5. Changed / unchanged table

| # | Item | r101 value | r102 value | Δ |
|---|---|---|---|---|
| R1 | `git ls-remote` HTTPS `EpicGames/unreal-engine` | `Repository not found.` exit 128 | `Repository not found.` exit 128 | **unchanged** |
| R1 | `gh api repos/EpicGames/UnrealEngine` | HTTP 404 | HTTP 404, exit 1 | **unchanged** |
| R2 | `git ls-remote` SSH `EpicGames/UnrealEngine` | `Permission denied (publickey)` exit 128 | `Permission denied (publickey)` exit 128 | **unchanged** |
| R3 | `pacman -Si lutris` | `0.5.22-3` (repo `extra`) | `0.5.22-3` (repo `extra`) | **unchanged** |
| R3 | `pacman -Qi lutris` | not found | not found | **unchanged** |
| R3 | `docker --version` | `29.7.2` | `29.7.2` | **unchanged** |
| — | AUR `unreal-engine` version | `5.8.2-1` | `5.8.2-1` | **unchanged** |
| — | AUR `PKGBUILD` sha256 | (not recorded in r101) | `2059fa7b…45ef`, 527 lines | **new pin, byte-identical to the r101 fetch** |
| — | AUR recipe `LastModified` | (not recorded) | `2026-09-12T21:41:28Z` | **new** — stale, not updated during r102 |
| — | shellcheck | installed `0.11.0-158` (14:11 local) | present, `0.11.0-158`, pacman.log entry unchanged | **unchanged** |
| — | `gh auth status` account | `VeigaPunk`, scopes `repo` etc. | identical | **unchanged** |
| — | Editor / proxy / :8000 | absent / 0 listeners | absent / 0 listeners | **unchanged** |
| — | Upstream plugin pin `a6aa73a` | live at r101 | still live (`ls-remote origin HEAD`) | **unchanged** |

**Net: zero deltas.** Nothing in the install picture moved between r101 and
r102, and no new evidence weakens or strengthens the r101 conclusion.

---

## 6. What this file does not claim

- No Unreal Editor runtime behavior — the editor is not installed on this host.
- No MCP live-call behavior — no endpoint listens on `:8000`.
- No claim that the wall is permanent: the operator action that opens R1/R2 is
  Epic-account linking (`unrealengine.com` → GitHub link), and the action that
  opens R3 is an Epic Games Store credential. Both are operator-owned.
- `shellcheck -S warning` exit 0 on the vendored hook is a *linter* receipt, not
  a correctness proof of the hook (same caveat r101 §`security-surface.md:293`
  records).
