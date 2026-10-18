# r104 SEAT-26 — LEDGER-CHECK

Scope: verify (a) `LOG.md` / `SCORECARD.md` / `SHONEN.md` unchanged vs HEAD, (b) `reports/round-101/`, `reports/round-102/`, `reports/round-103/` untouched vs HEAD. All checks read-only; no writes outside this file.

- HEAD under test: `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (`r103 report-last: verdict (all axes improved), LOG + SCORECARD, A4 timeline ruling + physics ruling + fixtures conformance ruling — work 8c9d9ad`)
- Check timestamp (UTC): `2026-10-18T19:16:43Z`
- Method note: `git diff` is the authoritative whole-file check; blob-hash equality via `git hash-object` (worktree) vs `git rev-parse HEAD:<path>` is independent of diff and catches whitespace/mode-agnostic content drift. A per-file walk over `git ls-tree -r HEAD` catches modification **and** deletion of tracked files.

## 1. Ledger files unchanged vs HEAD — PASS

Blob-hash equality (worktree blob object vs `HEAD:<path>`):

```
$ for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do wt=$(git hash-object -- "$f"); hd=$(git rev-parse "HEAD:$f"); \
    printf '%-13s wt=%s head=%s %s\n' "$f" "$wt" "$hd" "$([ "$wt" = "$hd" ] && echo IDENTICAL || echo DIFFER)"; done
LOG.md        wt=c0904c98e7818ee3a442da28f4b15012ebce2850 head=c0904c98e7818ee3a442da28f4b15012ebce2850 IDENTICAL
SCORECARD.md  wt=3403589a4a005ac2f970ea04228149f34ffa578d head=3403589a4a005ac2f970ea04228149f34ffa578d IDENTICAL
SHONEN.md     wt=8d85902c19010deb4fa154e16a2c12ad56ff10d1 head=8d85902c19010deb4fa154e16a2c12ad56ff10d1 IDENTICAL
PROVINCE.md   wt=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 head=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 IDENTICAL
```

Corroborating `git diff` over the same paths (empty output, exit 0):

```
$ git diff --stat HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md README.md; echo "EXIT=$?"
EXIT=0
```

`SHONEN.md` blob `8d85902c19010deb4fa154e16a2c12ad56ff10d1` and `PROVINCE.md` blob `cde5e8f518bb05149ab62e4ea5aa44f547e8aa69` match the r102 ledger-check's recorded values exactly — the byte-pinned surfaces have not moved across r102→r103→r104.

## 2. reports/round-101, round-102, round-103 untouched vs HEAD — PASS

Per-file blob walk over each committed subtree (catches modification and deletion of tracked files):

```
$ for d in reports/round-101 reports/round-102 reports/round-103; do ident=0; diff=0; miss=0; \
    while read -r mode type blob path; do if [ -f "$path" ]; then wt=$(git hash-object -- "$path"); \
    if [ "$wt" = "$blob" ]; then ident=$((ident+1)); else diff=$((diff+1)); echo "DIFFER $path"; fi; \
    else miss=$((miss+1)); echo "MISSING $path"; fi; done < <(git ls-tree -r HEAD -- "$d"); \
    printf '%s: identical=%s differing=%s missing=%s\n' "$d" "$ident" "$diff" "$miss"; done
reports/round-101: identical=33 differing=0 missing=0
reports/round-102: identical=61 differing=0 missing=0
reports/round-103: identical=61 differing=0 missing=0
```

No `DIFFER` or `MISSING` line was emitted. Whole-`reports/` diff vs HEAD is empty:

```
$ git diff --name-status HEAD -- reports/; echo "(end)"
(end)
```

HEAD subtree object ids (the immutable snapshots):

```
$ git ls-tree HEAD reports/round-101 reports/round-102 reports/round-103
040000 tree a28869fcf749c34fbd91edc485afde86fae37841	reports/round-101
040000 tree 92d4dc84dd979ecff01fe050436811c43453ada8	reports/round-102
040000 tree 739f668f55316ac36c5c04487a20a3e5f8b789f5	reports/round-103
```

`round-101` = `a28869fcf749c34fbd91edc485afde86fae37841` and `round-102` = `92d4dc84dd979ecff01fe050436811c43453ada8` are byte-identical to the subtree ids recorded in the r103 ledger-check — no drift.

## 3. Whole-tree tracked sweep — zero differences

```
$ n=0; for f in $(git ls-files); do wt=$(git hash-object -- "$f" 2>/dev/null); hd=$(git rev-parse "HEAD:$f"); \
    [ "$wt" = "$hd" ] || { echo "DIFFER $f"; n=$((n+1)); }; done; echo "WHOLE_TREE_DIFFER=$n"
WHOLE_TREE_DIFFER=0
```

Every tracked file in the lane hashes to its HEAD blob. At this pass no other r104 seat had landed a modification to a tracked path — all in-flight work sits under the untracked `reports/round-104/` round directory.

## 4. Worktree status — only round-104 is new

```
$ git status --porcelain
?? reports/round-104/
$ git diff --cached --stat
(empty)
$ git status --porcelain --untracked-files=all -- reports/ | grep '^??' | cut -d/ -f1-3 | sort -u
?? reports/round-104/gate
?? reports/round-104/physics
```

No staged changes, no unstaged tracked changes, no deletions (`git status --porcelain | grep -cE '^ ?D'` = 0). The sole delta vs HEAD is the untracked `reports/round-104/` directory — expected and in-bounds. The untracked subdirectories observed at this pass (`gate`, `physics`) belong to other r104 seats' declared paths.

### Concurrency disclosure

A second untracked path, `.r104seat43/`, appeared between the first and last pass of this audit (another r104 seat's scratch clone of the plugin tree — it contains a `fresh.git` sandbox and `tree/`, all untracked):

```
$ ls -la .r104seat43/
drwxr-xr-x  ...  fresh.git
drwxr-xr-x  ...  skills
drwxr-xr-x  ...  tree
$ git status --porcelain --untracked-files=all | grep -v 'round-104'
?? .r104seat43/.claude-plugin/plugin.json
?? .r104seat43/.gitignore
?? .r104seat43/CODEOWNERS
?? .r104seat43/LICENSE
?? .r104seat43/README.md
?? .r104seat43/fresh.git/HEAD
... (all entries `??`, i.e. untracked)
```

Every entry under `.r104seat43/` is untracked (`??`) — it touches **no** tracked path, so it cannot alter `LOG.md`, `SCORECARD.md`, `SHONEN.md`, or any `reports/` round. The audited invariants held across every pass taken, and the whole-tree tracked sweep (§3) reported `WHOLE_TREE_DIFFER=0` after this directory appeared.

## Verdict

PASS. `LOG.md` (blob `c0904c98…`), `SCORECARD.md` (`3403589a…`), `SHONEN.md` (`8d85902c…`), and `PROVINCE.md` (`cde5e8f5…`) are byte-identical to HEAD `88c3b2c`. `reports/round-101` (33 files), `reports/round-102` (61 files), and `reports/round-103` (61 files) are byte-identical to HEAD with no added or deleted files. `git diff HEAD -- reports/` is empty. The whole tracked tree hashes clean (WHOLE_TREE_DIFFER=0). The only working-tree change is the untracked `reports/round-104/` round directory. No blockers.

Point-in-time caveat: other r104 seats may write after this pass; the authoritative close-time check is `git diff -- LOG.md SCORECARD.md SHONEN.md && git diff --stat -- reports/` (both expected empty).
