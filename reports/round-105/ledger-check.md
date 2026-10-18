# r105 SEAT-33 — LEDGER-CHECK

Scope: confirm `LOG.md`, `SCORECARD.md`, `SHONEN.md`, and `PROVINCE.md` are unchanged, and `reports/round-101/` through `reports/round-104/` are untouched, relative to HEAD. Read-only audit; this report is the only path written.

- HEAD: `1eaa5680c22a704ddf05f9b51ff3fcc731b9be8b` (`git rev-parse HEAD`)
- Audit timestamp (UTC): `2026-10-18T20:30:32Z` (`date -u +%Y-%m-%dT%H:%M:%SZ`)

## Ledger files — PASS

Command run:

```
for f in LOG.md SCORECARD.md SHONEN.md PROVINCE.md; do wt=$(git hash-object -- "$f"); hd=$(git rev-parse "HEAD:$f"); printf '%-13s wt=%s head=%s %s\n' "$f" "$wt" "$hd" "$([ "$wt" = "$hd" ] && echo IDENTICAL || echo DIFFER)"; done
```

Observed output:

```
LOG.md        wt=cc39da5c9acb0a6d30db8a4f6d485d28e01dae2c head=cc39da5c9acb0a6d30db8a4f6d485d28e01dae2c IDENTICAL
SCORECARD.md  wt=c7a94c77884f832386d25013682e516f1d9ce1a2 head=c7a94c77884f832386d25013682e516f1d9ce1a2 IDENTICAL
SHONEN.md     wt=8d85902c19010deb4fa154e16a2c12ad56ff10d1 head=8d85902c19010deb4fa154e16a2c12ad56ff10d1 IDENTICAL
PROVINCE.md   wt=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 head=cde5e8f518bb05149ab62e4ea5aa44f547e8aa69 IDENTICAL
```

Corroborating command: `git diff --quiet HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md reports/round-101 reports/round-102 reports/round-103 reports/round-104`; observed `PASS: protected tracked paths match HEAD` (exit 0).

## Reports round-101..104 — PASS

Command run:

```
bad=0; for d in reports/round-101 reports/round-102 reports/round-103 reports/round-104; do ident=0; diff=0; miss=0; while read -r mode type blob path; do [ -n "$path" ] || continue; if [ -f "$path" ]; then wt=$(git hash-object -- "$path"); if [ "$wt" = "$blob" ]; then ident=$((ident+1)); else diff=$((diff+1)); printf 'DIFFER %s\n' "$path"; bad=1; fi; else miss=$((miss+1)); printf 'MISSING %s\n' "$path"; bad=1; fi; done < <(git ls-tree -r HEAD -- "$d"); printf '%s: identical=%s differing=%s missing=%s\n' "$d" "$ident" "$diff" "$miss"; done; exit "$bad"
```

It printed no `DIFFER` or `MISSING` entries and exited 0.

Observed counts:

```
reports/round-101: identical=33 differing=0 missing=0
reports/round-102: identical=61 differing=0 missing=0
reports/round-103: identical=61 differing=0 missing=0
reports/round-104: identical=21950 differing=0 missing=0
```

Untracked/deletion status check run: `git status --short --untracked-files=all -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md reports/round-101 reports/round-102 reports/round-103 reports/round-104`. Observed output was empty; `STATUS_EXIT=0`.

Verdict: PASS. The four ledger blobs match HEAD; all 22,105 tracked files across rounds 101–104 match their HEAD blobs, with no missing files; no untracked entries appeared in the audited paths.
