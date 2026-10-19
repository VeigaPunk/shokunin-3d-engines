# r106 SEAT-56 — LEDGER-CHECK

Scope: confirm `LOG.md`, `SCORECARD.md`, `SHONEN.md`, and `PROVINCE.md` are unchanged, and `reports/round-101/` through `reports/round-105/` are untouched, relative to HEAD. Read-only audit. This report is the only path written.

- HEAD: `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`git rev-parse HEAD`). Subject: `r105 report-last: verdict (all axes improved), LOG + SCORECARD, shadowing-not-drift ruling + P/C operator package — work 3634bc0`. Committer time: `2026-10-18T18:16:01-03:00` (`2026-10-18T21:16:01Z`).
- Work commit `3634bc0748f2ae1e02e20571874b39a3f3705daa` is an ancestor of HEAD (`git merge-base --is-ancestor 3634bc0 HEAD` → `3634bc0 is ancestor of HEAD`).
- Audit timestamp (UTC): `2026-10-18T21:26:14Z` (`date -u +%Y-%m-%dT%H:%M:%SZ`), reconfirmed immediately before this write. HEAD still `0cc3f4162f8c319f8d01a69a174fe939f36701bd`.
- Index flags on the four ledgers (and `SKILL.md`, extra): all `H` (cached). None are `S` (skip-worktree) or `h` (assume-unchanged), so `git diff` is not hiding them.

## Ledger files — PASS

Command run:

```
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do wt=$(git hash-object -- "$f"); hd=$(git rev-parse "HEAD:$f"); st=$(stat -c '%s %Y' -- "$f"); printf '%-13s wt=%s head=%s bytes_mtime=%s %s\n' "$f" "$wt" "$hd" "$st" "$([ "$wt" = "$hd" ] && echo IDENTICAL || echo DIFFER)"; done
```

Observed output:

```
LOG.md        wt=2c199c6ea630736d4a23753f5892a893e04e5909 head=2c199c6ea630736d4a23753f5892a893e04e5909 bytes_mtime=282360 1792358123 IDENTICAL
SCORECARD.md  wt=658afba9a080cf2195b563dfbb9ccdfdfdedc455 head=658afba9a080cf2195b563dfbb9ccdfdfdedc455 bytes_mtime=51554 1792358123 IDENTICAL
SHONEN.md     wt=8d85902c19010deb4fa154e16a2c12ad56ff10d1 head=8d85902c19010deb4fa154e16a2c12ad56ff10d1 bytes_mtime=561 1791920446 IDENTICAL
PROVINCE.md   wt=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 head=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 bytes_mtime=2683 1791920446 IDENTICAL
```

Re-run of the same hash compare immediately before this write printed `IDENTICAL` for all four. These blobs are not the r105 ledger-check blobs (`LOG.md` was `cc39da5c…`, `SCORECARD.md` was `c7a94c77…` at HEAD `1eaa568`). That shift is the r105 report-last commit itself, not a worktree edit: worktree equals this HEAD.

Corroborating command: `git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md reports/round-101 reports/round-102 reports/round-103 reports/round-104 reports/round-105`; observed `DIFF_QUIET_PASS` (exit 0) both in the first pass and at `2026-10-18T21:26:14Z`. `git diff --name-status --find-renames=0 HEAD --` the same paths printed nothing (`NAMESTATUS_EXIT=0`). `git diff --cached --stat HEAD --` the same paths printed nothing (`cached_exit=0`). `git ls-files -d --` the same paths printed nothing.

Untracked/deletion status: `git status --short --untracked-files=all -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md reports/round-101 reports/round-102 reports/round-103 reports/round-104 reports/round-105`. Observed output empty; `STATUS_EXIT=0`. Same command with `--ignored` also empty (`IGNORED_STATUS_EXIT=0`).

## Reports round-101..105 — PASS

Tracked blobs were hashed in-process with the git blob formula (`sha1("blob <len>\0" + bytes)`) and compared to `git ls-tree -r HEAD`. A spot check of `reports/round-104/consistency.md` via `git hash-object` matched both the tree blob and the formula: `7bf14fc29637f93cac62a034530232badbdc4b28`.

Observed counts (`BLOB_SCAN_EXIT=0`):

```
reports/round-101: identical=33 differing=0 missing=0 extra_files=0 tracked=33
reports/round-102: identical=61 differing=0 missing=0 extra_files=0 tracked=61
reports/round-103: identical=61 differing=0 missing=0 extra_files=0 tracked=61
reports/round-104: identical=21950 differing=0 missing=0 extra_files=0 tracked=21950
reports/round-105: identical=62 differing=0 missing=0 extra_files=0 tracked=62
TOTAL identical=22167 differing=0 missing=0 extra_files=0
```

`git ls-tree -r HEAD` type counts: every entry is a `blob` (101: 33, 102: 61, 103: 61, 104: 21950, 105: 62). Mode/type scan: `mode_or_type_bad=0` and `missing=0` in each of the five trees (`MODE_SCAN_BAD 0`). `find` for symlinks, fifos, sockets, and device nodes under those five trees: `special_count=0`. Rounds 101, 102, 103, and 105 have `extra_dirs=0`.

## Residue — not drift

`reports/round-104` has 27 empty directories that git does not track (empty dirs are invisible to `git status` and to `git ls-tree`). Walk found `untracked_files 0` and `orphan_dirs 27`, each with `immediate_entries=[]` and `files_under=0`. They are not an r106 touch: every directory mtime is before HEAD (`2026-10-18T21:16:01Z`). Latest observed mtime is `2026-10-18T19:43:21Z` (`reports/round-104/physics/author-runs-full-final/20261018T193620808009Z/scratch/r91bt_ops_disk/cache`). `stat` birth times on the four sampled dirs are also before HEAD (example: `reports/round-104/tmp.O08ANPOIb9` birth `2026-10-18 16:19:08 -0300`). Not deleted: `reports/round-104/` is protected.

Paths:

```
reports/round-104/gate/scratch/gate-workdir-probe          mtime 2026-10-18T19:17:13Z
reports/round-104/gate/scratch/tmpdir-probe                mtime 2026-10-18T19:17:15Z
reports/round-104/gate/scratch/localtmp                    mtime 2026-10-18T19:18:53Z
reports/round-104/gate/scratch/seat48/tmpwork              mtime 2026-10-18T19:19:26Z
reports/round-104/gate/scratch/seat48/tmpwork2             mtime 2026-10-18T19:20:52Z
reports/round-104/gate/scratch/seat48/gw                   mtime 2026-10-18T19:22:23Z
reports/round-104/gate/scratch/seat48/harness-gw-work      mtime 2026-10-18T19:22:40Z
reports/round-104/gate/scratch/seat48/gw2                  mtime 2026-10-18T19:24:27Z
reports/round-104/gate/scratch/seat48/hgw                  mtime 2026-10-18T19:25:14Z
reports/round-104/gate/scratch/seat13/tmpdir-probe         mtime 2026-10-18T19:19:02Z
reports/round-104/gate/scratch/seat13/gate-workdir-probe   mtime 2026-10-18T19:19:19Z
reports/round-104/gate/scratch/seat13/gate-workdir-10      mtime 2026-10-18T19:21:06Z
reports/round-104/gate/scratch/seat13/tdrun                mtime 2026-10-18T19:20:00Z
reports/round-104/gate/scratch/seat13/ro                   mtime 2026-10-18T19:22:14Z
reports/round-104/gate/scratch/seat13/tdnew                mtime 2026-10-18T19:22:22Z
reports/round-104/gate/scratch/seat13/gw-new               mtime 2026-10-18T19:22:31Z
reports/round-104/gate/scratch/seat13/gw-stab              mtime 2026-10-18T19:22:44Z
reports/round-104/gate/scratch/seat13/final-gw             mtime 2026-10-18T19:23:42Z
reports/round-104/gate/scratch/seat13/ro2                  mtime 2026-10-18T19:23:49Z
reports/round-104/gate/scratch/seat13/final-td             mtime 2026-10-18T19:24:08Z
reports/round-104/gate/scratch/localwork                   mtime 2026-10-18T19:27:26Z
reports/round-104/gate/scratch/s45work                     mtime 2026-10-18T19:28:59Z
reports/round-104/physics/author-runs-full/20261018T192105574998Z/scratch/r91bt_ops_disk/cache  mtime 2026-10-18T19:28:01Z
reports/round-104/physics/author-runs-full-final/20261018T193620808009Z/scratch/r91bt_ops_disk/cache  mtime 2026-10-18T19:43:21Z
reports/round-104/tmp.O08ANPOIb9                           mtime 2026-10-18T19:19:08Z
reports/round-104/scratch/seat37-full/20261018T192336521667Z/scratch/r91bt_ops_disk/cache  mtime 2026-10-18T19:30:16Z
reports/round-104/scratch/seat37-gw                        mtime 2026-10-18T19:24:43Z
```

## Extra corroboration (not in the seat's required four)

`SKILL.md` worktree blob `81970105e72856d7c17e83bf95820584883d52f2` equals `HEAD:SKILL.md`. Same `git diff --quiet` set. Not written.

`git update-index --refresh -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md` was run (`refresh_exit=0`). It refreshes index stat cache only. After it, `git diff --cached --stat` was empty and `git diff-index --quiet HEAD --` the protected paths exited 0. No content staged. No commit, push, checkout, or reset.

## Verdict

PASS. The four ledger blobs match HEAD. All 22,167 tracked files across rounds 101–105 match their HEAD blobs (0 differing, 0 missing, 0 extra files, 0 mode/type mismatches, 0 special files). `git status` (including ignored) is empty on those paths. The 27 empty directories under `reports/round-104` are pre-HEAD residue git cannot represent; their mtimes are older than HEAD, so they are not an r106 touch. No blockers.
