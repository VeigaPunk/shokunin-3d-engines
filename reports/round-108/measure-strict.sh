#!/usr/bin/env bash
# Fail-closed wrapper for reports/round-108/measure.sh (r108 post-review fix).
# measure.sh swallows `git show` errors, so a bad ref or a missing blob reads as
# a zero count. This wrapper validates the ref and every blob measure.sh reads
# before running it, and exits 2 on any missing input. A blob that legitimately
# does not exist at the base (corpus/QUALITY.md, corpus/SOURCES.md,
# corpus/lessons/round-108.md at 7c4e589) must be listed in ALLOW_ABSENT.
# Usage from the lane root: bash reports/round-108/measure-strict.sh <commit> [allowed-absent-path ...]
set -euo pipefail
REF=${1:?commit required}; shift
ALLOW_ABSENT=" $* "
git rev-parse --verify --quiet "$REF^{commit}" >/dev/null || { echo "FAIL ref-unresolved $REF" >&2; exit 2; }
missing=0
for p in SCORECARD.md SKILL.md PROVINCE.md corpus/README.md corpus/fixtures/run_battery.py \
         corpus/QUALITY.md corpus/SOURCES.md corpus/lessons/round-108.md; do
  if ! git cat-file -e "$REF:$p" 2>/dev/null; then
    case "$ALLOW_ABSENT" in
      *" $p "*) echo "absent-allowed $p" ;;
      *) echo "FAIL blob-missing $REF:$p" >&2; missing=1 ;;
    esac
  fi
done
[ "$missing" -eq 0 ] || exit 2
bash "$(dirname "$0")/measure.sh" "$REF"
