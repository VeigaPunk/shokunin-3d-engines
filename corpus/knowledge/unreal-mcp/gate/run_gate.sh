#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# gate/run_gate.sh — self-contained, re-runnable close-out gate for the
# r101 unreal-mcp subtree (corpus/knowledge/unreal-mcp).
#
# Exactly FOUR checks. Each prints one STEP=PASS / STEP=FAIL line.
# Exit 0 only if all four pass; exit 1 otherwise (fail-closed).
#
#   1  manifest byte-identity  sha256sum -c .manifest.d/audit-reference.sha256
#   2  clone equivalence       vendored upstream/ vs a FRESH clone at the pin
#   3  verdict-card scan       exactly 13 cards, exactly one label each
#   4  pointer sweep           every upstream/<path>:<line> resolves
#
# No Unreal runtime claim is made or implied anywhere in this gate: the editor
# is not installed on this host, so the strongest statement available is that
# the vendored bytes are byte-identical to the pinned upstream commit and that
# these static checks ran here.
#
# Expected values are pinned in gate/README.md. Requires: bash, git, sha256sum,
# grep, find, sort, comm, and network access for check 2 (fresh clone).
#
# usage: corpus/knowledge/unreal-mcp/gate/run_gate.sh
# ---------------------------------------------------------------------------
set -u

for _t in git sha256sum grep find sort comm; do
  if ! command -v "$_t" >/dev/null 2>&1; then printf 'FAIL required tool missing: %s\n' "$_t"; exit 1; fi
done

PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
EXPECTED_MANIFEST_OK=12
EXPECTED_TRACKED=12
EXPECTED_CARDS=13
EXPECTED_STATIC=12
EXPECTED_UNPROVEN=1
EXPECTED_VERIFIED=0

SUB=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GATE_DIR=$SUB/gate
FAILS=0

printf 'GATE unreal-mcp subtree\n'
printf 'SUBTREE=%s\n' "$SUB"
printf 'PIN=%s\n' "$PIN"
if command -v git >/dev/null 2>&1 && git -C "$SUB" rev-parse --show-toplevel >/dev/null 2>&1; then
  printf 'LANE_HEAD=%s\n' "$(git -C "$SUB" rev-parse HEAD)"
fi
printf '\n'

# --- HARDENING A (SEAT-20): the pinned trees must contain only regular files.
#     find -type f follows nothing; a symlink in upstream/ is invisible to
#     both the path-set (find -type f) and the blob diff (readlink target).
NONREG=$(find "$SUB/upstream" "$SUB/executability" "$SUB/.manifest.d" ! -type f ! -type d 2>/dev/null)
if [ -n "$NONREG" ]; then
  printf 'FAIL non-regular file in pinned tree:\n%s\n' "$NONREG"
  FAILS=$((FAILS+1))
fi

# --- HARDENING B (SEAT-20): pin the manifest files themselves. ---
#     Check 1 only reads audit-reference.sha256, so seat*.sha256 can be
#     emptied or corrupted with the gate still green.
MANIFEST_COUNT=$(find "$SUB/.manifest.d" -maxdepth 1 -name '*.sha256' | wc -l)
printf 'MANIFEST_FILES=%s\n' "$MANIFEST_COUNT"
if ! (cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >/tmp/advgate/.h1 2>&1); then
  printf 'FAIL per-seat manifest sweep (--strict) failed:\n'
  sed 's/^/  /' /tmp/advgate/.h1
  FAILS=$((FAILS+1))
fi

# HARDENING H (SEAT-20): CRLF in a manifest is accepted silently by sha256sum -c.
CRFILES=$(grep -lU $'\r' "$SUB"/.manifest.d/*.sha256 2>/dev/null)
[ -n "$CRFILES" ] && { printf 'FAIL CR byte in manifest:\n%s\n' "$CRFILES"; FAILS=$((FAILS+1)); }

WORK=$(mktemp -d)
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# ---------------------------------------------------------------------------
# CHECK 1 — manifest byte-identity
#   Recompute every vendored file's sha256 from its bytes and compare against
#   the committed reference manifest. Expected: 12 lines, all OK, exit 0,
#   and no FAILED line.
# ---------------------------------------------------------------------------
printf 'CHECK 1 manifest-byte-identity\n'
C1_OUT=$(cd "$SUB" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1)
C1_RC=$?
printf '%s\n' "$C1_OUT"
C1_OK=$(printf '%s\n' "$C1_OUT" | grep -c ': OK$' || true)
C1_FAILED=$(printf '%s\n' "$C1_OUT" | grep -c ': FAILED$' || true)
printf 'MANIFEST_OK=%s EXPECTED=%s FAILED=%s RC=%s\n' \
  "$C1_OK" "$EXPECTED_MANIFEST_OK" "$C1_FAILED" "$C1_RC"
if [ "$C1_RC" -eq 0 ] && [ "$C1_OK" -eq "$EXPECTED_MANIFEST_OK" ] && [ "$C1_FAILED" -eq 0 ]; then
  printf 'STEP=PASS\n\n'
else
  printf 'STEP=FAIL\n\n'; FAILS=$((FAILS+1))
fi

# ---------------------------------------------------------------------------
# CHECK 2 — clone equivalence against a FRESH clone at the pin
#   2a the clone's HEAD must equal the pin exactly (a moved `main` is a FAIL);
#   2b the worktree must be clean;
#   2c path-set equality both ways: vendored upstream/ files vs `git ls-files`;
#   2d byte-identity per file against the clone's blobs — a manifest can be
#      regenerated from a corrupted tree, this comparison cannot.
# ---------------------------------------------------------------------------
printf 'CHECK 2 clone-equivalence\n'
C2_PASS=1
if ! command -v git >/dev/null 2>&1; then
  printf 'FAIL git not available (check 2 requires git)\n'
  C2_PASS=0
else
  CLONE=$WORK/clone
  if timeout 180 git clone --quiet "$REPO" "$CLONE" >"$WORK/clone.log" 2>&1; then
    C2_HEAD=$(git -C "$CLONE" rev-parse HEAD)
    C2_DIRTY=$(git -C "$CLONE" status --porcelain | wc -l)
    git -C "$CLONE" ls-files | sort > "$WORK/clone-files.txt"
    C2_TRACKED=$(wc -l < "$WORK/clone-files.txt")
    printf 'CLONE_HEAD=%s\nCLONE_DIRTY=%s\nCLONE_TRACKED=%s\n' "$C2_HEAD" "$C2_DIRTY" "$C2_TRACKED"
    [ "$C2_HEAD" = "$PIN" ] || { printf 'FAIL clone HEAD != pin\n'; C2_PASS=0; }
    [ "$C2_DIRTY" -eq 0 ] || { printf 'FAIL clone worktree dirty\n'; C2_PASS=0; }
    [ "$C2_TRACKED" -eq "$EXPECTED_TRACKED" ] || { printf 'FAIL tracked count %s != %s\n' "$C2_TRACKED" "$EXPECTED_TRACKED"; C2_PASS=0; }

    (cd "$SUB/upstream" && find . -type f | sed 's|^\./||' | sort) > "$WORK/vendored-files.txt"
    C2_EXTRA=$(comm -23 "$WORK/vendored-files.txt" "$WORK/clone-files.txt" | wc -l)
    C2_MISSING=$(comm -13 "$WORK/vendored-files.txt" "$WORK/clone-files.txt" | wc -l)
    printf 'PATH_EXTRA=%s PATH_MISSING=%s\n' "$C2_EXTRA" "$C2_MISSING"
    [ "$C2_EXTRA" -eq 0 ] || { printf 'FAIL vendored file not tracked upstream (see above)\n'; C2_PASS=0; }
    [ "$C2_MISSING" -eq 0 ] || { printf 'FAIL upstream file not vendored\n'; C2_PASS=0; }

    C2_BLOBDIFF=0
    while IFS= read -r f; do
      a=$(sha256sum "$SUB/upstream/$f" | cut -d' ' -f1)
      b=$(git -C "$CLONE" show "$PIN:$f" | sha256sum | cut -d' ' -f1)
      [ "$a" = "$b" ] || { printf 'BLOB-DIFF %s\n' "$f"; C2_BLOBDIFF=$((C2_BLOBDIFF+1)); }
    done < "$WORK/clone-files.txt"
    printf 'BLOB_DIFFS=%s\n' "$C2_BLOBDIFF"
    [ "$C2_BLOBDIFF" -eq 0 ] || C2_PASS=0
  else
    printf 'FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS\n'
    sed -n '1,5p' "$WORK/clone.log"
    C2_PASS=0
  fi
fi
if [ "$C2_PASS" -eq 1 ]; then printf 'STEP=PASS\n\n'; else printf 'STEP=FAIL\n\n'; FAILS=$((FAILS+1)); fi

# ---------------------------------------------------------------------------
# CHECK 3 — verdict-card inventory and label scan
#   Rule (ported from reports/round-101/r101-verification-protocol.md §4): the
#   DECLARED label is the token on the FIRST line of the card that contains any
#   allowed token. That line must (a) appear within the first 40 lines,
#   (b) be bold- or heading-marked, (c) carry exactly ONE allowed token.
#   Expected: 13 cards, BAD=0, census 12 static-only / 1 unproven-runtime / 0
#   verified-here.
# ---------------------------------------------------------------------------
printf 'CHECK 3 verdict-card-scan\n'
ALLOWED='(^|[^A-Za-z0-9-])(verified-here|static-only|unproven-runtime)([^A-Za-z0-9-]|$)'
TOKENS='verified-here|static-only|unproven-runtime'
CARDS=$(find "$SUB/executability" -maxdepth 1 -type f 2>/dev/null | sort)
NONMD=$(find "$SUB/executability" -maxdepth 1 -type f ! -iname '*.md' 2>/dev/null)
[ -n "$NONMD" ] && { printf 'FAIL non-markdown file in executability/:\n%s\n' "$NONMD"; FAILS=$((FAILS+1)); }
# HARDENING F (SEAT-20): no nested dirs/files under executability/ (find -maxdepth 1 misses them)
NESTED=$(find "$SUB/executability" -mindepth 2 2>/dev/null)
[ -n "$NESTED" ] && { printf 'FAIL nested entry under executability/:\n%s\n' "$NESTED"; FAILS=$((FAILS+1)); }
C3_N=$(printf '%s' "$CARDS" | grep -c . || true)
C3_BAD=0; N_STATIC=0; N_UNPROVEN=0; N_VERIFIED=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  rec=$(grep -nE "$ALLOWED" "$f" | head -1)
  if [ -z "$rec" ]; then printf 'FAIL no-label       %s\n' "$f"; C3_BAD=$((C3_BAD+1)); continue; fi
  ln=${rec%%:*}; text=${rec#*:}
  cnt=$(printf '%s' "$text" | grep -oE "$ALLOWED" | wc -l)
  lab=$(printf '%s' "$text" | grep -oE "$TOKENS" | head -1)
  if [ "$ln" -gt 40 ]; then printf 'FAIL label-too-deep %s (line %s)\n' "$f" "$ln"; C3_BAD=$((C3_BAD+1)); continue; fi
  case "$text" in *'**'*|*'#'*) ;; *) printf 'FAIL label-unmarked %s :: %s\n' "$f" "$text"; C3_BAD=$((C3_BAD+1)); continue;; esac
  if [ "$cnt" -ne 1 ]; then printf 'FAIL multi-label    %s :: %s\n' "$f" "$text"; C3_BAD=$((C3_BAD+1)); continue; fi
  case "$lab" in
    static-only)     N_STATIC=$((N_STATIC+1)) ;;
    unproven-runtime) N_UNPROVEN=$((N_UNPROVEN+1)) ;;
    verified-here)   N_VERIFIED=$((N_VERIFIED+1)) ;;
  esac
  printf 'OK   %-16s %-30s line %s\n' "$lab" "$(basename "$f")" "$ln"
done <<< "$CARDS"
printf 'CARDS=%s EXPECTED=%s BAD=%s\n' "$C3_N" "$EXPECTED_CARDS" "$C3_BAD"
printf 'CENSUS static-only=%s unproven-runtime=%s verified-here=%s EXPECTED=%s/%s/%s\n' \
  "$N_STATIC" "$N_UNPROVEN" "$N_VERIFIED" "$EXPECTED_STATIC" "$EXPECTED_UNPROVEN" "$EXPECTED_VERIFIED"
if [ "$C3_N" -eq "$EXPECTED_CARDS" ] && [ "$C3_BAD" -eq 0 ] && \
   [ "$N_STATIC" -eq "$EXPECTED_STATIC" ] && [ "$N_UNPROVEN" -eq "$EXPECTED_UNPROVEN" ] && \
   [ "$N_VERIFIED" -eq "$EXPECTED_VERIFIED" ]; then
  printf 'STEP=PASS\n\n'
else
  printf 'STEP=FAIL\n\n'; FAILS=$((FAILS+1))
fi

# ---------------------------------------------------------------------------
# CHECK 4 — pointer sweep
#   Pointers are written `upstream/<path>:<line>` and resolve against the
#   subtree root. EXCLUSIONS, all deliberate and all counted so they cannot
#   hide a real failure:
#     * upstream/       — the vendored upstream text is not this round's prose;
#     * gate/README.md  — the gate's OWN specification, whose worked examples
#                         quote deliberately-broken control pointers. Auditing a
#                         checker against its own specification is a false
#                         positive by construction.
#     * EXACT control sentinels (upstream/nope.md:N, upstream/README.md:9999,
#       upstream/README.md:500) — second line of defence for peers' reports that
#       quote this README verbatim. EXACT match, NOT a keyword filter: a real
#       pointer on a line that happens to say "control" is still counted.
#   Expected: UNRESOLVED=0.
# ---------------------------------------------------------------------------
printf 'CHECK 4 pointer-sweep\n'
BASE=$SUB
SELF=$GATE_DIR/README.md
SENTINEL='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'
P_TOTAL=0; P_BAD=0; P_SKIPPED=0
while IFS= read -r f; do
  case "$f" in "$SUB"/upstream/*|"$SELF") continue;; esac
  while IFS= read -r ptr; do
    [ -z "$ptr" ] && continue
    if printf '%s' "$ptr" | grep -qE "^($SENTINEL)$"; then P_SKIPPED=$((P_SKIPPED+1)); continue; fi
    p=${ptr%:*}; ln=${ptr##*:}
    P_TOTAL=$((P_TOTAL+1))
    if [ ! -f "$BASE/$p" ]; then printf 'MISSING-PATH %s :: %s\n' "$f" "$ptr"; P_BAD=$((P_BAD+1)); continue; fi
    n=$(wc -l < "$BASE/$p")
    [ "$ln" -lt 1 ] && { printf 'LINE-ZERO %s :: %s\n' "$f" "$ptr"; P_BAD=$((P_BAD+1)); }
    [ "$ln" -gt "$n" ] && { printf 'LINE-OOR %s :: %s (max %s)\n' "$f" "$ptr" "$n"; P_BAD=$((P_BAD+1)); }
  done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+" "$f" | sort -u)
done < <(find "$SUB" -type f \( -iname '*.md' -o -iname '*.txt' -o -iname '*.markdown' \) | sort)
# HARDENING G (SEAT-20): the upstream/-only sweep cannot see dangling
# corpus/... or reports/... pointers. Sweep backtick-wrapped repo-relative paths.
REPO=$(cd "$SUB/../../.." && pwd)
while IFS= read -r ptr; do
  [ -z "$ptr" ] && continue
  case "$ptr" in http*|*'<'*|*'*'*|*'$'*) continue;; esac
  case "$ptr" in
    corpus/*|reports/*|docs/*) base=$REPO ;;
    executability/*|gate/*|upstream/*|.manifest.d/*) base=$SUB ;;
    *) continue ;;
  esac
  P_TOTAL=$((P_TOTAL+1))
  [ -e "$base/$ptr" ] || { printf 'MISSING-PATH-REL %s\n' "$ptr"; P_BAD=$((P_BAD+1)); }
done < <({ grep -rhoE '[`][A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt)(:[0-9]+)?[`]' --include='*.md' "$SUB" 2>/dev/null; grep -rhoE '[`]upstream/[A-Za-z0-9_./-]+:[0-9]+[`]' --include='*.md' "$SUB" 2>/dev/null; } | tr -d '`' | sed 's/:[0-9]\+$//' | sort -u)
printf 'POINTERS=%s SKIPPED_CONTROL_SENTINELS=%s UNRESOLVED=%s\n' "$P_TOTAL" "$P_SKIPPED" "$P_BAD"
if [ "$P_BAD" -eq 0 ]; then printf 'STEP=PASS\n\n'; else printf 'STEP=FAIL\n\n'; FAILS=$((FAILS+1)); fi

# ---------------------------------------------------------------------------
printf 'GATE RESULT: %s (checks failed: %s)\n' \
  "$([ "$FAILS" -eq 0 ] && echo PASS || echo FAIL)" "$FAILS"
[ "$FAILS" -eq 0 ] && exit 0 || exit 1
