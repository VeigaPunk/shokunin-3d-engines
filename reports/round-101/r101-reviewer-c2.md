# SEAT-46 REVIEW — C2 depth, non-author verification

Round: r101 · Lane: game-dev-3d-shokunin · Seat: **SEAT-46 (review)**
Review mode: **non-author, independent.** I authored none of the artifacts below:
not `reports/round-101/probes/prereq-matrix.md`, not
`corpus/knowledge/unreal-mcp/README.md`, not any `executability/*.md` card, not
any `.manifest.d/` manifest. Declared write path: this file only.

Task as dispatched: re-run the prerequisites matrix checks against the host
myself (do not trust the receipts); confirm or refute the engine-install wall
with my own `git ls-remote` attempt; verdict + evidence.

Confidence tags: **[O]** receipt-pinned observation (command + output below),
**[I]** inference, **[?]** unknown / not measurable here.

---

## 0. Verdict

**The prerequisites matrix reproduces. Every row I re-derived came out the same
label. The engine-install wall is CONFIRMED for the source route, with my own
`git ls-remote` failing on both protocols. But the wall as stated is
INCOMPLETE: I found a public, anonymously-pullable Docker image that ships a
built Unreal Engine 5.8.3 editor, which the matrix never enumerated.**

Three findings, ordered by weight:

1. **CONFIRMED — the source route is walled.** `git ls-remote` fails identically
   on HTTPS and SSH from this host, and all four AUR recipes that could build
   the engine gate on exactly that probe and abort. Two further routes
   (`unreal-engine-bin`'s manual download, and the AUR install script's own
   HTTPS fallback) are also closed: I measured HTTP 403 on every Epic download
   endpoint.
2. **EXTENSION — the wall is not total.** `wukakuki/unreal-engine:dev-slim-5.8.3`
   is a public Docker Hub image (37,427 pulls) whose build history shows
   `Build.sh "$EDITOR_TARGET" Linux Development`, i.e. it contains a built
   editor. I obtained an anonymous registry token and read its manifest and
   config blob **without pulling**. 26.8 GB compressed at 12.5 MB/s ≈ 36 min
   against 780 GB free. **Labelled unproven**: I did not pull it, never ran an
   editor, and cannot confirm the plugin's required `ModelContextProtocol` /
   `AllToolsets` plugins are present in that build.
3. **PARTIAL at review time — both gaps closed or clarified during the seat.**
   The card set reached **13/13** when `gameplay-gas.md` landed mid-seat, and
   `PROVENANCE.md` landed too (its 12-row hash table is exactly correct).
   `adaptation-kimi.md` is still absent, so C3's adaptation table is the one
   deliverable I cannot review. The cards that exist carry exactly one label
   each, cite resolvable pointers (every line number I spot-checked was exact),
   and make no runtime assertion.

---

## 1. Host receipts re-derived (not trusted)

The round brief's receipts, re-run by this seat:

```bash
uname -a ; nproc ; free -g ; df -h / ; whoami ; id
```

```
Linux plazir27 7.2.3-arch1-3 #1 SMP PREEMPT_DYNAMIC Sun, 06 Sep 2026 13:01:04 +0000 x86_64 GNU/Linux
32
               total        used        free      shared  buff/cache   available
Mem:              30          13           3           3          16          17
/dev/mapper/root  930G  133G  780G  15% /
vgpnk
uid=1000(vgpnk) gid=1000(vgpnk) groups=1000(vgpnk),967(docker),992(input),998(wheel)
```

```bash
jq --version ; python3 --version ; node --version ; shellcheck --version ; docker --version ; git --version ; gh --version
```

```
jq-1.8.2
Python 3.14.7
v26.12.0
version: 0.11.0
Docker version 29.7.2, build a7dcaa6fdb
git version 2.55.0
gh version 2.102.0 (2026-09-30)
```

Every brief receipt reproduces. The `shellcheck` install is receipt-pinned in
the package log rather than assumed:

```bash
grep -i shellcheck /var/log/pacman.log | tail -1
```

```
[2026-10-18T14:11:04-0300] [ALPM] installed shellcheck (0.11.0-158)
```

Docker is not just present but live, and the daemon answers:

```bash
docker info --format '{{.ServerVersion}} {{.OperatingSystem}} {{.Driver}} root={{.DockerRootDir}}'
```

```
29.7.2 Arch Linux overlayfs root=/var/lib/docker
```

This matters for §3: the container route needs a working daemon, and there is
one. `vgpnk` is in the `docker` group (967), so no privilege escalation is
needed.

`gh` is authenticated as a non-Epic account:

```bash
gh auth status
```

```
github.com
  ✓ Logged in to github.com account VeigaPunk (keyring)
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
```

---

## 2. Upstream pin and byte-identity (independently re-derived)

The pre-existing clone was verified before use, per the lane rule:

```bash
git -C /tmp/ue-skills-ref rev-parse HEAD
```

```
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Equals the pinned SHA → the clone is usable as-is; no fresh clone to
`/tmp/r101work` was required. The pin is the tip of `main` and matches the
remote's own object:

```bash
gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/a6aa73ada02a9fb1f5415bec491f9942c519b297 \
  --jq '{sha:.sha,date:.commit.committer.date,msg:.commit.message}'
```

```
{"date":"2026-09-17T01:28:32Z","msg":"[MCP] Permit safe concurrent tool calls ...","sha":"a6aa73ada02a9fb1f5415bec491f9942c519b297"}
```

Byte-identity, re-run from scratch rather than read off a report:

```bash
# per-file sha256 of every tracked file, upstream vs vendored
cd /tmp/ue-skills-ref && while IFS= read -r f; do
  a=$(sha256sum "$f" | cut -d' ' -f1)
  b=$(sha256sum "/home/.../corpus/knowledge/unreal-mcp/upstream/$f" | cut -d' ' -f1)
  [ "$a" != "$b" ] && echo "DIFF: $f"
done < <(git ls-files) ; echo "fail=$?"
```

```
fail=0
```

Both directions of the path set are equal:

```bash
comm -23 /tmp/vend.txt /tmp/ups.txt     # vendored-but-not-upstream
wc -l < /tmp/ups.txt ; wc -l < /tmp/vend.txt
```

```
                                     # (empty — no extra files)
12
12
```

And the manifest sweep, plus the strongest structural check:

```bash
cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 ; echo "exit=$?"
diff -r /tmp/ue-skills-ref corpus/knowledge/unreal-mcp/upstream ; echo "diff exit=$?"
```

```
upstream/.claude-plugin/plugin.json: OK
upstream/CODEOWNERS: OK
upstream/.gitignore: OK
upstream/hooks/hooks.json: OK
upstream/hooks/unreal-context.sh: OK
upstream/LICENSE: OK
upstream/README.md: OK
upstream/skills/create-toolset/SKILL.md: OK
upstream/skills/unreal-mcp/references/operations.md: OK
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
exit=0
Only in /tmp/ue-skills-ref: .git
diff exit=1
```

The single `diff -r` line is clone metadata, not tracked content. The union of
the eleven per-seat manifests is byte-for-byte the audit reference:

```bash
cat .manifest.d/seat*.sha256 | sort > /tmp/seatunion.txt
grep -v '^#' .manifest.d/audit-reference.sha256 | sort > /tmp/audbody.txt
diff /tmp/seatunion.txt /tmp/audbody.txt && echo IDENTICAL
```

```
IDENTICAL
```

Edge cases the brief's "12 files" claim could hide, all negative: no symlinks
(`find -type l` → empty), no `.gitmodules`, no `.gitattributes`, no `.git/lfs`.
Upstream tracks **12** files, not the brief's 11 — matching the sibling C1
reviewer's finding, independently re-counted here.

---

## 3. The engine-install wall — my own attempt

This is the seat's central assignment. I did not read the wall off the matrix; I
re-ran it.

### 3.1 My own `git ls-remote`, both protocols

```bash
timeout 60 git ls-remote https://github.com/EpicGames/UnrealEngine.git HEAD ; echo "exit=$?"
```

```
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/UnrealEngine.git/' not found
exit=128
```

```bash
GIT_SSH_COMMAND='ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=15' \
  timeout 60 git ls-remote git@github.com:EpicGames/UnrealEngine.git HEAD ; echo "exit=$?"
```

```
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
exit=128
```

Both fail. The SSH failure is a credential failure, not a network one — the host
reaches GitHub and has a key, but the key is not authorized for the Epic org:

```bash
timeout 20 ssh -o BatchMode=yes -T git@github.com ; echo "exit=$?"
```

```
git@github.com: Permission denied (publickey).
exit=255
```

`~/.ssh/` holds `id_ed25519` + `.pub` + `config` + `known_hosts`; the key exists
and is simply not Epic-linked.

### 3.2 The same probe through the GitHub API (not just git)

```bash
gh api repos/EpicGames/UnrealEngine                       # → 404 Not Found
gh api orgs/EpicGames/memberships/VeigaPunk               # → 404, needs admin:org scope
gh api repos/EpicGames/UnrealEngine/releases              # → 404 Not Found
```

```
{"message":"Not Found","documentation_url":"...","status":"404"}
{"message":"Not Found",...}
gh: This API operation needs the "admin:org" scope.
```

A private repo the token *could* see would return the repo object; 404 is the
signature of "exists but you are not a member", which is exactly the Epic-link
wall. All three probes agree.

### 3.3 The AUR recipes gate on that identical probe

The matrix cites line 280 of `unreal-engine`. I fetched the PKGBUILD myself and
read the gate verbatim:

```bash
curl -sL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=unreal-engine" | sed -n '278,284p'
```

```
  # Check access to the repository
  if ! git ls-remote git@github.com:EpicGames/UnrealEngine &>/dev/null; then
    error 'You must register at unrealengine.com and link your github account to access this private repo. See the wiki for more info: https://wiki.archlinux.org/index.php/Unreal_Engine_4'
    exit 1
  fi
```

The recipe runs **the exact command that fails on this host** and aborts. My own
failure above is therefore not a side observation — it is the recipe's own abort
branch, reached. The recipe later clones over SSH as well
(`git clone --depth=1 --branch=${pkgver}-release git@github.com:EpicGames/UnrealEngine`, line 327).

Three sibling recipes carry the same gate, so there is no AUR escape hatch:

| recipe | version | gate |
|---|---|---|
| `unreal-engine` | 5.8.2-1 | `PKGBUILD:280` — SSH `ls-remote`, abort |
| `unreal-engine-src-5.8` | 5.8.3-3 | lines 303–311 — probes SSH **then HTTPS**, aborts if both fail |
| `unreal-engine-git` | 5.3.2-4 | line 136 — SSH `ls-remote`, abort |
| `unreal-engine-4` | 4.27.2-15 | line 129 — SSH `ls-remote`, abort |

`unreal-engine-src-5.8` is the most generous of the four and still closes both
doors:

```bash
curl -sL ".../PKGBUILD?h=unreal-engine-src-5.8" | sed -n '303,312p'
```

```
  if git ls-remote "${_ue_remote_ssh}" &>/dev/null; then
    _ue_remote="${_ue_remote_ssh}"
  elif git ls-remote "${_ue_remote_https}" &>/dev/null; then
    _ue_remote="${_ue_remote_https}"
  else
    error "Cannot access EpicGames/UnrealEngine via SSH or HTTPS."
    ...
    exit 1
  fi
```

My two failures land in that `else`. The wall is not SSH-specific.

### 3.4 The non-source routes are also closed

The matrix stops at G3 and does not examine the `-bin` recipe. I did.

**`unreal-engine-bin` (51 votes) does not download anything.** It uses a `manual://`
pseudo-protocol with a `DLAGENT` that only prints a message:

```bash
curl -sL ".../PKGBUILD?h=unreal-engine-bin"
```

```
DLAGENTS+=('manual::/usr/bin/echo \ \ Note: Please download the zip file manually from https://www.unrealengine.com/linux')
source=("manual://Linux_Unreal_Engine_${pkgver}.zip" ...)
```

I ran that agent in isolation to see what it actually does:

```bash
# minimal PKGBUILD carrying the same DLAGENT + source
makepkg -o --nodeps --noconfirm
```

```
==> Retrieving sources...
  -> Downloading Linux_Unreal_Engine_1.zip...
  Note: Please download the zip file manually from https://www.unrealengine.com/linux manual://Linux_Unreal_Engine_1.zip
==> Validating source files with sha256sums...
    Linux_Unreal_Engine_1.zip ... NOT FOUND
==> ERROR: One or more files did not pass the validity check!
exit=1
```

`src/` is left empty. The recipe is a **stub that requires the operator to fetch
the zip by hand from a logged-in Epic session**. So the manual route inherits the
Epic-login wall rather than bypassing it.

And that manual download is itself gated. Every Epic download endpoint I probed
refused an unauthenticated client:

```bash
curl -sI -L "https://download.epicgames.com/Builds/UnrealEngine/5.8.2/Linux_Unreal_Engine_5.8.2.zip"
curl -s -o /dev/null -w '%{http_code}' -L -A 'Mozilla/5.0 ...' "https://www.unrealengine.com/linux"
curl -s -o /dev/null -w '%{http_code}' -L -A 'Mozilla/5.0' "https://store.epicgames.com/en-US/download"
```

```
HTTP/2 403     (download.epicgames.com … Linux_Unreal_Engine_5.8.2.zip)
403            (www.unrealengine.com/linux)
403            (store.epicgames.com/en-US/download)
```

The `unrealengine.com/linux` body is a 25,372-byte Cloudflare challenge page
(`cf_challenge_text_small`), i.e. a bot wall in front of the login wall.
`unreal-engine-bin` is additionally flagged out of date
(`OutOfDate` epoch `1791380211` → **2026-10-07**).

**Engine is not in the official repos, and there is no GitHub release fallback:**

```bash
pacman -Si unreal-engine            # error: package 'unreal-engine' was not found
gh api repos/EpicGames/UnrealEngine/releases   # 404
```

### 3.5 Wall verdict

**CONFIRMED**, and stronger than the matrix states. The matrix says the wall is
"one row, G3". My measurements show it is a *set* of closed routes that all
reduce to the same operator-held identity:

- source build: SSH and HTTPS both fail (§3.1) → all four AUR recipes abort (§3.3);
- binary zip: recipe is a manual stub (§3.4) whose download returns 403 without
  an Epic session (§3.4);
- official repos: absent (§3.4);
- releases: 404 (§3.4);
- Lutris/Epic-login: operator credential, unexamined beyond availability.

`lutris` is available in `extra` (0.5.22-3) but not installed, and `dotnet-sdk`
is missing — both one local install away, neither binding.

---

## 4. Extension: the wall is not total — an unenumerated container route

The matrix's G-section enumerates AUR, official repos, and Lutris. It does not
consider **public container images**, and one exists.

```bash
curl -s "https://hub.docker.com/v2/search/repositories/?query=unreal-engine" | jq -r '.results[] | ...'
```

```
wukakuki/unreal-engine        stars=3  official=false
mcp/unreal-engine-mcp-server  stars=4  official=false
... (8 more, all 0-star)
```

`wukakuki/unreal-engine` is the substantive one — 37,427 pulls, last updated
2026-09-26, described as "unreal engine for Linux/LinuxArm64 client/server
4.27.2 … and from 5.3.2 to last". Its tag list includes editor-capable builds:

| tag | compressed size |
|---|---|
| `dev-5.8.3` | 35.7 GB |
| `dev-slim-5.8.3` | 26.8 GB |
| `runtime-5.8.3` | 0.13 GB |
| `multi-user-server-5.8.3` | 0.15 GB |
| `runtime-pixel-streaming-5.8.3` | 0.23 GB |

**No authentication is required to read it.** I took an anonymous registry token
and pulled the manifest and config blob — metadata only, no layers:

```bash
TOK=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:wukakuki/unreal-engine:pull" | jq -r .token)
# token len=2709
curl -s -H "Authorization: Bearer $TOK" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  "https://registry-1.docker.io/v2/wukakuki/unreal-engine/manifests/dev-slim-5.8.3"
```

The config blob shows a real engine tree, not a stub:

```json
{
  "created": "2026-09-26T23:14:48.164175621+08:00",
  "architecture": "amd64", "os": "linux",
  "env": "PATH=...:/home/ue4/UnrealEngine/Engine/Extras/ushell | ... UNREAL_ENGINE_ROOT=/home/ue4/UnrealEngine | ...",
  "workingdir": "/home/ue4/UnrealEngine"
}
```

And the build history is the decisive evidence — the image **builds the editor
target**:

```
COPY --chown=ue4:ue4 /home/ue4/.config/Epic/UnrealEngine/Install.ini /home/ue4/.config/Epic/UnrealEngine/Install.ini
RUN /bin/sh -c EDITOR_TARGET=$(python3 /tmp/print-editor-target.py "$UNREAL_ENGINE_ROOT") && \
    ./Engine/Build/BatchFiles/Linux/Build.sh "$EDITOR_TARGET" Linux Development -SkipBuild && ...
```

Feasibility on this host, measured rather than assumed:

```bash
# bounded range read of the first layer to measure the link
curl -sL -o /dev/null -w 'http=%{http_code} downloaded=%{size_download} speed=%{speed_download} B/s\n' \
  -r 0-104857600 -H "Authorization: Bearer $TOK" ".../blobs/sha256:d5fd17ec…"
```

```
http=206 downloaded=28566230 bytes speed=12511329 B/s
```

12.5 MB/s against 780 GB free on `/` (overlayfs root `/var/lib/docker`) puts the
26.8 GB `dev-slim` image at roughly **36 minutes** of pull time. No disk or
bandwidth obstacle.

**What this does and does not establish — labelled, per the lane's rule.**

- **[O] Established:** a public, anonymous, no-auth-needed image containing a
  built UE 5.8.3 Linux editor exists and is reachable from this host.
- **[I] Inferred:** that image is the one plausible route to a live editor
  without an Epic account link.
- **[?] NOT established, and I do not assert it:** that the image's engine build
  contains the `ModelContextProtocol` and `AllToolsets` plugins the vendored
  plugin requires. I did not pull it, so I did not inspect its plugin
  directories. `AllToolsets` is documented upstream as an editor-only aggregator
  with `EnabledByDefault` off, and whether a third-party container build enables
  it is unknown.
- **[?] Also unknown:** whether the editor can be driven headlessly in that
  container to a point where an MCP tool call succeeds — which is the only thing
  that would upgrade any card from `static-only` to `verified-here`.

I made **no attempt** to pull the image. That is a 27 GB, ~36-minute,
outward-facing action that changes host state, and whether to spend it is an
operator decision, not a reviewer's. I am reporting the route, not taking it.

---

## 5. Prerequisites matrix — independent re-run, row by row

I re-ran the matrix's checks myself. Every row reproduced its label. Below are my
own commands and outputs, grouped as the matrix groups them; where a row's
observation is a one-liner I give the output inline.

### A. Client / plugin layer

| # | Matrix label | My check | My observed | Agrees |
|---|---|---|---|---|
| A1 | PRESENT | `claude --version` | `2.1.302 (Claude Code)` | ✓ |
| A2 | MISSING | `ls -la ~/.claude/plugins` | dir exists, holds only `data`; no plugin installed | ✓ |
| A3 | MISSING | `ls -la ~/.claude/` | `agents backups debug plugins projects session-env sessions skills` — no marketplace cache | ✓ |
| A4 | PRESENT | vendored `skills/*/SKILL.md` present with frontmatter | 3/3, `---`-opened, `name:`/`description:` intact | ✓ |

### B. Shell / hook layer

| # | Matrix label | My check | My observed | Agrees |
|---|---|---|---|---|
| B1 | PRESENT | `command -v bash`; `bash --version` | `/usr/bin/bash`; `GNU bash, version 5.3.15(1)-release (x86_64-pc-linux-gnu)` | ✓ |
| B2 | PRESENT | `shellcheck -x` + `bash -n` + 4 branch drives | see below | ✓ |
| B3 | MISSING | `env \| grep -i CLAUDE` | empty — `CLAUDE_PLUGIN_ROOT` unset | ✓ |
| B4 | PRESENT | `jq --version` | `jq-1.8.2` | ✓ |

**B2 is the lane's only `verified-here`-class artifact**, so I exercised it
myself rather than trusting the matrix's transcript. Static checks first:

```bash
shellcheck -x corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh ; echo "exit=$?"
bash -n      corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh ; echo "exit=$?"
```

```
exit=0
exit=0
```

Then all four behavioural branches, in synthetic trees under `/tmp/hooktest`:

```
A: no UE project (cwd=plain/sub)          → (silent)                exit=0
B: .uproject marker present               → {"hookSpecificOutput":… "The project is `MyGame.uproject` … No `.mcp.json` is present …"}   exit=0
C: .uproject + .mcp.json, cwd=Content/    → "… An `.mcp.json` is already present at the project root."      (upward walk worked)
D: Engine dir + GenerateProjectFiles.sh   → "… It is an Engine source tree. …"
E: CLAUDE_UE_HOOK_DEBUG=1                 → unreal-context.sh: project root: /tmp/hooktest/proj (type=game, uproject=MyGame.uproject, mcp_json=true)
```

Branch C was run from `Content/`, one level below the root, which exercises the
upward walk the script's own comment warns about. Output is valid JSON
(`jq -r '.hookSpecificOutput.additionalContext'` parsed it). The file mode is
`644` on both sides, so the vendored copy is byte-identical *and* mode-identical
to upstream.

### C. Engine layer

| # | Matrix label | My check | My observed | Agrees |
|---|---|---|---|---|
| C1 | MISSING | `which UnrealEditor UnrealEditor-Cmd UE4Editor`; `find / -xdev -maxdepth 6 -name 'UnrealEditor*' -type f` | all three `no … in (…)`; `find` empty | ✓ |
| C2 | MISSING | `find / -xdev -maxdepth 7 -type d -name ModelContextProtocol` | empty | ✓ |
| C3 | MISSING | same for `AllToolsets` | empty | ✓ |
| C5 | MISSING | `python3 -c "import unreal"` | `ModuleNotFoundError: No module named 'unreal'` | ✓ |
| C7 | MISSING | `find /home/vgpnk -maxdepth 5 -name '*.uproject'` | empty | ✓ |

### D. Project config layer

| # | Matrix label | My check | My observed | Agrees |
|---|---|---|---|---|
| D1–D3 | MISSING | no `.uproject` exists (C7) → nothing to edit | n/a | ✓ |
| D4 | PRESENT | `ss -ltn \| grep -c ':8000'`; then bind test | `0`; `bind 127.0.0.1:8000 OK` | ✓ |

D4 is worth its own receipt, since "nothing is listening" and "the port is
bindable" are different claims:

```bash
ss -ltn | grep -c ':8000'          # 0
python3 -c "import socket; s=socket.socket(); s.bind(('127.0.0.1',8000)); print('bind 127.0.0.1:8000 OK')"
```

```
0
bind 127.0.0.1:8000 OK
```

### E / F / H — client config, proxy, verification gates

E1 MISSING, E2/E4 OPERATOR-WALL, F1–F3 MISSING, H1–H4 OPERATOR-WALL: all
reproduce. Each is either downstream of C1/C7 (nothing to configure) or requires
a live editor process. I confirmed the process-side absence independently:

```bash
ps aux | grep -i -E 'unreal|UE4|UE5|epic' | grep -v grep    # only 1Password/Grok/ZCode noise, no engine
ss -ltn                                                      # no :8000 listener
```

No editor process, no MCP port. The `OPERATOR-WALL` labels are correct, and
H4 in particular — a successful read-only Unreal tool call — is precisely the
claim this round must never assert. It is not asserted anywhere.

### G. Engine acquisition

| # | Matrix label | My check | My observed | Agrees |
|---|---|---|---|---|
| G1 | PRESENT | AUR RPC `info?arg[]=unreal-engine` | `resultcount 1`, `unreal-engine 5.8.2-1`, maintainer `alexbelm48`, 75 votes | ✓ |
| G2 | MISSING | `pacman -Si unreal-engine` | `error: package 'unreal-engine' was not found` | ✓ |
| G3 | OPERATOR-WALL | `git ls-remote` ×2, `gh api` ×3 | see §3 | ✓ |
| G4b | MISSING | `pacman -Q dotnet-sdk`; `dotnet --list-sdks` | not found; empty | ✓ |
| G5 | PRESENT | `which vulkaninfo`; `ls /usr/share/vulkan/icd.d/`; `lspci` | `/usr/bin/vulkaninfo`; `lvp_icd.json nvidia_icd.json radeon_icd.json`; `NVIDIA GB205 [GeForce RTX 5070]`, `AMD Granite Ridge [Radeon Graphics]` | ✓ |
| G6 | MISSING | `pacman -Si lutris`; `pacman -Qi lutris` | `extra 0.5.22-3`; not installed | ✓ |
| G8 | PRESENT | `uname -m`; `nproc`; `free -h`; `df -h /` | `x86_64`; 32; 30 GiB; `780G avail (15%)` | ✓ |

**Matrix tally reproduced exactly: PRESENT 10, MISSING 21, OPERATOR-WALL 8, total
39.** I found no row where the matrix overstates availability. Where I differ
from the matrix it is by *extension*, not correction: the G-section is missing
the `-bin` recipe, the 403 measurement, and the container route (§4).

---

## 6. C2 verdict-card review

Claim under review: *13 subsystem verdict cards, each labeled exactly one of
`verified-here` | `static-only` | `unproven-runtime`, with its evidence.*

### 6.1 Completeness

Cards are authored concurrently by other seats and **one landed during this
seat**, so the count is time-dependent. Both observations are recorded.

At my first census (14:16:44 -03:00):

```bash
ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l     # 12
```

```
present: 12  expected: 13
MISSING: ['gameplay-gas']
EXTRA:   []
```

At my final census (14:18:32 -03:00), after `gameplay-gas.md` landed:

```bash
ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l     # 13
```

```
missing: []
```

**C2's "13 cards" is met as of the final census**, and the 13th card carries a
correct single label (`static-only`) with the standard label-basis line. The
corpus README anticipates exactly this race — "a card may be absent at the
moment you read this index" — so the transient 12/13 was a landing-time
artifact, not a defect. No card is extra and none is mislabeled.

### 6.2 Labels — exactly one per card, no `verified-here`

Machine-extracted binding label from each card's own declaration line:

```
actors-scene.md                  unproven-runtime
animation-controlrig.md          static-only
assets-content.md                static-only
blueprints.md                    static-only
editor-general.md                static-only
materials.md                     static-only
meshes-textures.md               static-only
scripting-programmatic.md        static-only
sequencer.md                     static-only
testing-automation.md            static-only
ui-umg-slate.md                  static-only
vfx-niagara-dataflow.md          static-only
```

Every card names its label once, up front, in a `**Label:**` / `**Verdict:**`
line, and each card carries a "why this label and not the other two" section.
**No card claims `verified-here`** — correct, since a `verified-here` label would
require a bounded run on this host and no editor exists. This satisfies the
corpus README's own policy, which states that on this host "every card is
expected to resolve to `static-only` or `unproven-runtime`".

**Calibration note (not a defect).** The set is split 11 / 1: `actors-scene`
alone is `unproven-runtime`, on the stated ground that actor capability is
"a mutation or read of *live editor session state*" with no on-disk artifact to
inspect statically, whereas the others can be reasoned about from vendored
document bytes. Both labels are legitimate under the policy, and the reasoning
is explicit and checkable. The consequence is simply that the card set does not
resolve to a single label, so a downstream consumer cannot assume uniformity —
it must read each card, which is exactly what the corpus README instructs.

### 6.3 Source pointers resolve

Every upstream path cited across all cards, resolved against the vendored tree:

```bash
grep -oh -E 'upstream/[A-Za-z0-9._/-]+\.(md|json|sh)' *.md | sort -u | while read -r p; do
  [ -e "../$p" ] && echo "OK   $p" || echo "MISS $p"
done
```

```
OK   upstream/.claude-plugin/plugin.json
OK   upstream/hooks/hooks.json
OK   upstream/hooks/unreal-context.sh
OK   upstream/README.md
OK   upstream/skills/create-toolset/SKILL.md
OK   upstream/skills/unreal-mcp/references/operations.md
OK   upstream/skills/unreal-mcp/references/setup.md
OK   upstream/skills/unreal-mcp/SKILL.md
OK   upstream/skills/unreal-skill/SKILL.md
```

9 distinct paths, 0 misses. Three cards (`blueprints`, `editor-general`,
`meshes-textures`) cite with bare relative paths (`README.md:101`) rather than
the `upstream/` prefix; those resolve to the same files and every one I checked
was exact (§6.4). All paths are repo-relative, so the pointers survive `/tmp`
being wiped — a real durability property, not just correctness.

### 6.4 Line-number pointers are exact

I spot-checked cited line numbers against the vendored bytes rather than
accepting them:

| cited | observed |
|---|---|
| `README.md:101` = the Blueprints bullet | `- **Blueprints** - create, edit graphs, add nodes, connect pins, manage variables, compile` ✓ |
| `README.md:102` = the Assets bullet | `- **Assets and Content** - find, load, save, move, duplicate assets; …` ✓ |
| `README.md:104` = the Meshes bullet | `- **Meshes and Textures** - inspect/edit static and skeletal meshes, LODs, collisions, Nanite, sockets, bones` ✓ |
| `README.md:111` = the Editor bullet | `- **Editor** - screenshots, camera control, actor/asset selection, content browser, log inspection` ✓ |
| `README.md:3` = the top-level inventory | `Control Unreal Editor directly from Claude Code via MCP. Hundreds of tools …` ✓ |
| `grep -n '^- \*\*Editor\*\*' README.md` → `111` | `111:- **Editor** - …` ✓ |
| 13 bullets in `README.md:96–112` | `13` ✓ |
| `README.md` total lines = 112 | `112` ✓ |
| `skills/unreal-mcp/SKILL.md:16` = the `BlueprintTools.create` mention | ✓ |
| `.claude-plugin/plugin.json:3` = `"version": "3.1.1"` | ✓ |
| `create-toolset/SKILL.md:144`, `:153–173` | sync-tools prose; `CaptureThingImage` UFUNCTION block ✓ |
| `unreal-skill/SKILL.md:35`, `:90`, `:97` | UAsset guidance; Content Browser asset; `FolderPath` example ✓ |

I also re-verified the corpus README's own per-file table (bytes and lines) for
all 12 files — every figure matches the actual vendored file:

```
README.md 112/8398 · LICENSE 21/1073 · CODEOWNERS 2/64 · .gitignore 4/203
plugin.json 10/487 · hooks.json 17/357 · unreal-context.sh 84/3101
unreal-mcp/SKILL.md 56/7098 · setup.md 133/6065 · operations.md 51/6497
create-toolset/SKILL.md 420/23258 · unreal-skill/SKILL.md 112/6955
```

### 6.5 No card asserts a runtime claim

The lane's hard rule is that live-editor claims are labelled, never asserted. I
swept all cards for bare runtime assertions:

```bash
grep -n -i -E 'we ran the editor|executed in the editor|confirmed at runtime|observed at runtime|verified at runtime|tool call succeeded|we called .*Tools\.' *.md \
  | grep -v -i -E 'never|not |no |cannot|would|absent|unproven|without|unless'
```

```
                                     # (empty)
```

No bare assertion. Every card that does reference runtime behaviour frames it as
absent, unproven, or conditional. **This is the single most important property
of the card set and it holds.**

One consistency nit: 6 of 12 cards (`assets-content`, `scripting-programmatic`,
`sequencer`, `testing-automation`, `ui-umg-slate`, `vfx-niagara-dataflow`) do
**not** carry an explicit "Unreal Editor is not installed on this host" sentence
in their body, though they label correctly and their content is consistent with
it. The corpus README's policy section states that host reality centrally, so
this is a per-card redundancy gap, not a false claim.

---

## 7. C3 status

C3's deliverables are landing concurrently. Both observations are recorded,
because one landed during this seat.

At my first check (14:16):

```bash
for p in PROVENANCE.md adaptation-kimi.md; do
  test -e "corpus/knowledge/unreal-mcp/$p" && echo "PRESENT $p" || echo "ABSENT  $p"
done
```

```
ABSENT  PROVENANCE.md
ABSENT  adaptation-kimi.md
```

At my final check (14:18):

```
PRESENT PROVENANCE.md
ABSENT  adaptation-kimi.md
```

The corpus README discloses this state ("Both are authored by other seats and are
forward references from this index; if either is absent when you read this, the
seat has not landed it yet"), so the index made no false claim at either moment.

**`PROVENANCE.md` reviewed on arrival.** Its 12-row hash table is exactly
correct — I recomputed every vendored file's digest and compared both directions:

```bash
grep -o -E '[0-9a-f]{64}' PROVENANCE.md | sort -u > /tmp/prov.txt
find upstream -type f -exec sha256sum {} \; | awk '{print $1}' | sort -u > /tmp/real.txt
comm -23 /tmp/prov.txt /tmp/real.txt   # in PROVENANCE, not a real file
comm -13 /tmp/prov.txt /tmp/real.txt   # real file, not in PROVENANCE
```

```
                                     # (both empty)
PROVENANCE-unique=12 real-unique=12
```

It also records the pin, the remote's agreement on the pin, the commit metadata,
the plugin version, and the fetch date, each with the command that produced it.
Its counts and digests match my own independent measurements in §2.

**`adaptation-kimi.md` remains absent, so I make no verdict on it.** C3's
adaptation table and its per-row source pointers are therefore not reviewable
from this seat.

---

## 8. Defects and gaps found

| # | Finding | Severity | Status |
|---|---|---|---|
| R1 | **The wall statement is incomplete.** `README.md` says "engine install is **blocked** pending operator Epic-account linking". True for the source route (I confirmed it), but a public anonymous Docker image with a built UE 5.8.3 editor exists and was never enumerated. | **Material** — the wall is narrower than the corpus asserts | Reported; route not taken |
| R2 | `gameplay-gas.md` absent at my first census (12/13); C2's "13 cards" not met at that instant | Moderate | **Resolved mid-seat** — landed at 14:18, now 13/13 |
| R3 | C3 `adaptation-kimi.md` absent | Moderate | Still absent; forward-referenced honestly. `PROVENANCE.md` landed and verified correct |
| R4 | Label set split 11 `static-only` / 1 `unproven-runtime`; defensible but non-uniform | Low (calibration) | Note |
| R5 | 6 cards lack the explicit host-reality sentence | Low | Note |
| R6 | Round brief says "11 vendored paths"; upstream tracks 12 | Low (brief, not artifact) | Already caught by C1 reviewer; re-confirmed here |

R1 is the one that should change a document. The corpus README's *Host reality*
section and the matrix's G-section both reduce the wall to a single operator
identity. My measurements agree that **every source-based route** reduces to
that identity, but the correct statement is "blocked for the source-build route",
not "blocked". Suggested wording for the operator's judgement:

> Engine install is blocked for **source-build routes** (AUR `unreal-engine`,
> `-src-*`, `-git`, `-4`, and the `-bin` manual-zip route), all of which require
> an Epic-linked GitHub account or an Epic login. A community Docker image
> (`wukakuki/unreal-engine:dev-slim-5.8.3`, 26.8 GB, anonymous pull) ships a
> built 5.8.3 editor and is reachable from this host; **not pulled, not run, and
> the presence of the `ModelContextProtocol` / `AllToolsets` plugins in that
> build is unverified.**

---

## 9. Reproduction

Every command above is re-runnable. No repo state was mutated by this seat; the
only tracked-tree write is this report (left untracked for the operator). Scratch
state was confined to `/tmp` (`/tmp/aur-ue.pkgbuild`, `/tmp/ue-bin.pkgbuild`,
`/tmp/ue-src58.pkgbuild`, `/tmp/dlagent/`, `/tmp/binbuild/`, `/tmp/hooktest/`).

Nothing was committed, pushed, or reset. `LOG.md`, `SCORECARD.md`, `SHONEN.md`,
`SKILL.md`, `PROVINCE.md` and the three pre-existing `reports/round-101/` files
were not touched. No image was pulled; no editor was run; **no runtime claim is
made anywhere in this report.**
