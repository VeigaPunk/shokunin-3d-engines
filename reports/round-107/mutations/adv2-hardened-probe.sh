#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# gate/run_gate.sh — self-contained, re-runnable close-out gate for the
# r101 unreal-mcp subtree (corpus/knowledge/unreal-mcp).
#
# Exactly FOUR checks. Each prints one STEP=PASS / STEP=FAIL / STEP=BLOCKED line.
# Exit 0 PASS · 1 FAIL · 2 BLOCKED (CHECK 2 could not run) — see gate/README.md.
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
# Scratch location (r104, SEAT-12): both scratch sites live under
# ${GATE_WORKDIR:-${TMPDIR:-/tmp}} — see the WORK_ROOT block below and the
# "Running under quota pressure" section of gate/README.md.
#
# usage: corpus/knowledge/unreal-mcp/gate/run_gate.sh
#        GATE_WORKDIR=/some/roomy/dir corpus/knowledge/unreal-mcp/gate/run_gate.sh
# ---------------------------------------------------------------------------
# shellcheck disable=SC2016  # check 4's pointer regexes use LITERAL backticks (markdown delimiters), not substitution
set -u

for _t in git sha256sum grep find sort comm; do
  if ! command -v "$_t" >/dev/null 2>&1; then printf 'FAIL required tool missing: %s\n' "$_t"; exit 1; fi
done

# ---------------------------------------------------------------------------
# Scratch root (r104, SEAT-12 GATE-WORKDIR-AUTHOR)
#
# ROOT CAUSE this exists for (r103 close, `reports/round-103/gate/close-runs.md`):
# both of this gate's scratch sites — the manifest log and CHECK 2's clone
# workdir — were plain `mktemp`, i.e. hardcoded to /tmp. On this host /tmp is a
# 16G tmpfs shared with the user's other sessions under a per-user quota, and
# under pressure `git clone` fails with `error: copy-fd: write returned: Disk
# quota exceeded`. That failure used to be INDISTINGUISHABLE from an unreachable
# upstream: CHECK 2 printed `BLOCKED (network)` and the run exited 2. A local
# disk problem was reported as a network problem — the reader is sent to the
# wrong subsystem, and a green gate becomes a coin flip.
#
# WORK_ROOT is the fix: scratch goes to ${GATE_WORKDIR:-${TMPDIR:-/tmp}}, so a
# caller under quota pressure points the gate at a roomy filesystem without
# editing it. Precedence is GATE_WORKDIR > TMPDIR > /tmp; /tmp stays the default
# so every existing caller behaves exactly as before.
#
# The chosen root is VALIDATED up front: an unset/typo'd GATE_WORKDIR used to
# fail later and obscurely (mktemp prints to stderr and $WORK stays empty, so
# every downstream "$WORK/..." path silently names the root). Here it is a hard,
# named error before any check runs. Nothing is written into the root itself.
# ---------------------------------------------------------------------------
WORK_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
if [ ! -d "$WORK_ROOT" ]; then
  printf 'FAIL scratch root is not a directory: %s\n' "$WORK_ROOT"
  printf '     set GATE_WORKDIR (or TMPDIR) to an existing writable directory\n'
  exit 1
fi
if [ ! -w "$WORK_ROOT" ]; then
  printf 'FAIL scratch root is not writable: %s\n' "$WORK_ROOT"
  printf '     set GATE_WORKDIR (or TMPDIR) to an existing writable directory\n'
  exit 1
fi
WORK_SRC=GATE_WORKDIR
[ -n "${GATE_WORKDIR:-}" ] || { WORK_SRC=TMPDIR; [ -n "${TMPDIR:-}" ] || WORK_SRC=default; }

PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
REPO=${REPO:-https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin}
EXPECTED_MANIFEST_OK=12
EXPECTED_TRACKED=12
EXPECTED_CARDS=13
EXPECTED_STATIC=12
EXPECTED_UNPROVEN=1
EXPECTED_VERIFIED=0
# A3 (SEAT-09, r103): the pinned 13 domain names, sorted file stems. Mirrored in
# gate/README.md ("Pinned card-name set"); both must be edited together. The set
# is the r101 declared 13 (`corpus/knowledge/unreal-mcp/README.md` card table).
PINNED_CARD_NAMES='actors-scene animation-controlrig assets-content blueprints editor-general gameplay-gas materials meshes-textures scripting-programmatic sequencer testing-automation ui-umg-slate vfx-niagara-dataflow'

SUB=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
GATE_DIR=$SUB/gate
FAILS=0

printf 'GATE unreal-mcp subtree\n'
printf 'SUBTREE=%s\n' "$SUB"
printf 'PIN=%s\n' "$PIN"
printf 'WORK_ROOT=%s (from %s)\n' "$WORK_ROOT" "$WORK_SRC"
if command -v df >/dev/null 2>&1; then
  printf 'WORK_ROOT_FREE=%s\n' "$(df -Ph "$WORK_ROOT" 2>/dev/null | awk 'NR==2{print $4" of "$2" ("$5" used)"}')"
fi
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
# r103 (SEAT-09): this used a hardcoded /tmp/advgate/.h1 scratch file. On any host
# without that directory the redirect failed, sha256sum never ran, and the gate
# printed `FAIL per-seat manifest sweep` + exit 1 on a CLEAN tree — a spurious
# fail-closed, not a real one. mktemp keeps the check host-independent.
# r104 (SEAT-12): mktemp is rooted at WORK_ROOT, and its failure is now LOUD. A
# bare `MANLOG=$(mktemp)` under quota pressure leaves MANLOG empty, the redirect
# `>"$MANLOG"` then fails, and the check silently reports the manifest sweep as
# broken — the same misleading-failure class this seat exists to close.
MANLOG=$(mktemp -p "$WORK_ROOT" 2>/dev/null) || MANLOG=''
if [ -z "$MANLOG" ]; then
  printf 'FAIL cannot create scratch file under %s (quota? permissions?)\n' "$WORK_ROOT"
  printf '     set GATE_WORKDIR (or TMPDIR) to a writable directory with room\n'
  FAILS=$((FAILS+1))
else
  if ! (cd "$SUB" && sha256sum --strict -c .manifest.d/*.sha256 >"$MANLOG" 2>&1); then
    printf 'FAIL per-seat manifest sweep (--strict) failed:\n'
    sed 's/^/  /' "$MANLOG"
    FAILS=$((FAILS+1))
  fi
  rm -f "$MANLOG"
fi

# HARDENING H (SEAT-20): CRLF in a manifest is accepted silently by sha256sum -c.
CRFILES=$(grep -lU $'\r' "$SUB"/.manifest.d/*.sha256 2>/dev/null)
[ -n "$CRFILES" ] && { printf 'FAIL CR byte in manifest:\n%s\n' "$CRFILES"; FAILS=$((FAILS+1)); }

# HARDENING ADV2 (r107, GATE-ADV2): the gate had NO check on the subtree's prose
# pin. `grep -n PROVENANCE gate/run_gate.sh` was empty, so PROVENANCE.md could
# carry a wrong pin with the gate green (ADV1 class F). Rule: every 40-hex token
# on a line of the subtree's prose that names a pin (line matches -i 'pin') must
# equal $PIN. On the r107 tree exactly ONE such token exists and it is the pin,
# so the rule is false-positive-free by measurement; an unrelated 40-hex token
# elsewhere in prose (5 such tokens exist) is not swept in. Reports the count so
# a silent removal of the pin from prose is visible.
PP_BAD=0; PP_N=0
while IFS= read -r line; do
  tok=$(printf '%s' "$line" | grep -oE '\b[0-9a-f]{40}\b' | head -1)
  [ -z "$tok" ] && continue
  PP_N=$((PP_N+1))
  if [ "$tok" != "$PIN" ]; then
    printf 'FAIL pin-prose-drift  %s  (%s:%s)\n' "$tok" "$(printf '%s' "$line" | cut -d: -f1)" "$(printf '%s' "$line" | cut -d: -f2)"
    PP_BAD=$((PP_BAD+1))
  fi
done < <(grep -rniE '[0-9a-f]{40}' "$SUB"/PROVENANCE.md "$SUB"/README.md "$SUB"/adaptation-kimi.md \
         "$SUB"/executability 2>/dev/null | grep -i 'pin')
printf 'PIN_PROSE lines-with-pin=%s bad=%s\n' "$PP_N" "$PP_BAD"
[ "$PP_BAD" -eq 0 ] || FAILS=$((FAILS+1))

# Scratch dir for CHECK 2's clone (the gate's largest scratch consumer: ~1 MB of
# git objects). Rooted at WORK_ROOT; a failure here is reported by name rather
# than surfacing later as an unexplained BLOCKED clone.
WORK=$(mktemp -d -p "$WORK_ROOT" 2>/dev/null) || WORK=''
cleanup() { [ -n "$WORK" ] && rm -rf "$WORK"; return 0; }
# EXIT covers every exit path (0 PASS / 1 FAIL / 2 BLOCKED); the signal traps make
# the same guarantee when the run is interrupted, so a killed gate cannot leave a
# clone behind to deepen the very quota pressure that broke it.
trap cleanup EXIT
trap 'cleanup; trap - EXIT; exit 130' INT
trap 'cleanup; trap - EXIT; exit 143' TERM
trap 'cleanup; trap - EXIT; exit 129' HUP
if [ -z "$WORK" ]; then
  printf 'FAIL cannot create scratch dir under %s (quota? permissions?)\n' "$WORK_ROOT"
  printf '     set GATE_WORKDIR (or TMPDIR) to a writable directory with room\n'
  printf 'GATE RESULT: FAIL (checks failed: 1)\n'
  exit 1
fi

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
#
#   A4 (SEAT-09, r103) — BLOCKED is a THIRD state, not a flavour of FAIL.
#     Until r103 an unreachable upstream printed `STEP=FAIL` and the run exited 1,
#     so a reader of `GATE RESULT: FAIL` could not tell "this host had no network"
#     from "the vendored bytes diverge". Now the clone-failure branch prints a
#     distinct `CHECK 2 BLOCKED (network)` signal and the gate exits 2 — declared
#     in gate/README.md alongside the other codes. It is deliberately NOT counted
#     in FAILS: a blocked check is not a failed check, and the exit code is what
#     carries the distinction (0 PASS / 1 FAIL / 2 BLOCKED).
#     GATE_REF=<path> names an existing clone at the pin for air-gapped runs; with
#     it set no network is touched and the check is scored normally.
# ---------------------------------------------------------------------------
printf 'CHECK 2 clone-equivalence\n'
C2_PASS=1; C2_BLOCKED=0; C2_LOG=''
C2_REF=${GATE_REF:-}
[ -n "$C2_REF" ] && printf 'GATE_REF=%s (offline reference; no clone attempted)\n' "$C2_REF"
if ! command -v git >/dev/null 2>&1; then
  printf 'FAIL git not available (check 2 requires git)\n'
  C2_PASS=0
else
  CLONE=$WORK/clone
  if [ -n "$C2_REF" ]; then
    if git -C "$C2_REF" rev-parse HEAD >/dev/null 2>&1; then
      CLONE=$C2_REF
      C2_CLONE_RC=0
    else
      printf 'FAIL GATE_REF is not a git clone: %s\n' "$C2_REF"
      C2_PASS=0; C2_CLONE_RC=1
    fi
  else
    # r104 (SEAT-12): capture the clone's stderr IN MEMORY first. Writing it
    # straight to "$WORK/clone.log" put the diagnostic on the same filesystem
    # that just filled up, so under quota pressure the log was created empty and
    # the gate printed `BLOCKED (network)` with no cause line at all — the
    # evidence destroyed precisely when it was needed. The variable survives the
    # full filesystem; the on-disk copy is best-effort only.
    C2_LOG=$(timeout 180 git clone --quiet "$REPO" "$CLONE" 2>&1)
    C2_CLONE_RC=$?
    printf '%s\n' "$C2_LOG" >"$WORK/clone.log" 2>/dev/null || true
  fi
  if [ "$C2_PASS" -eq 1 ] && [ "$C2_CLONE_RC" -eq 0 ]; then
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
  elif [ "$C2_PASS" -eq 1 ]; then
    # A4: unreachable upstream — a distinct BLOCKED state, exit 2, never folded
    # into FAILS. (Reached only when no GATE_REF was supplied; a bad GATE_REF
    # has already set C2_PASS=0 and is a genuine FAIL.)
    #
    # r104 (SEAT-12): classify the cause before printing the header. The r103 root
    # cause was a LOCAL disk failure (scratch quota) being reported as a NETWORK
    # failure, sending the reader to the wrong subsystem. When the clone log shows
    # a local resource error the header says so and names the fix; the A4 contract
    # string `CHECK 2 BLOCKED (network)` is unchanged for a genuine network block,
    # so the r103 A4a control still matches verbatim. Exit code is 2 either way —
    # the A4 contract (BLOCKED ⇒ 2) is not renegotiated here.
    # Matched against the in-memory $C2_LOG: the on-disk copy can be truncated or
    # absent exactly when the cause is a full filesystem.
    if printf '%s' "$C2_LOG" | grep -qiE 'disk quota exceeded|no space left|out of diskspace|write error|quota exceeded'; then
      printf 'CHECK 2 BLOCKED (local-resource)\n'
      printf 'BLOCKED fresh clone could not complete — scratch filesystem full or quota-exhausted\n'
      printf 'BLOCKED the network may be fine: this is a DISK failure, not an unreachable upstream\n'
      printf 'BLOCKED retry with GATE_WORKDIR (or TMPDIR) on a roomy filesystem — see gate/README.md\n'
    else
      printf 'CHECK 2 BLOCKED (network)\n'
      printf 'BLOCKED fresh clone could not complete — upstream unreachable, nothing compared\n'
    fi
    printf 'BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent\n'
    printf '%s\n' "$C2_LOG" | sed -n '1,5p'
    C2_BLOCKED=1; C2_PASS=0
  fi
fi
if [ "$C2_BLOCKED" -eq 1 ]; then
  printf 'STEP=BLOCKED\n\n'
elif [ "$C2_PASS" -eq 1 ]; then printf 'STEP=PASS\n\n'; else printf 'STEP=FAIL\n\n'; FAILS=$((FAILS+1)); fi

# ---------------------------------------------------------------------------
# CHECK 3 — verdict-card inventory, name set, and label scan
#   Rule (ported from reports/round-101/r101-verification-protocol.md §4): the
#   DECLARED label is the token on the first line that is a DECLARATION, not the
#   first line that merely mentions a token. A declaration is anchored: the line
#   must start (leading whitespace allowed) with one of the five label shapes the
#   13 cards actually use — `**Label:** \`X\``, `**Label:**\`X\`**`,
#   `**Label:** **\`X\``, `**\`X\`**`, `# Label: \`X\`` — where Label may also be
#   `Verdict` and may carry a ` label` suffix. A2 (SEAT-09, r103): the old rule
#   took the first token-bearing line, so a prose sentence above the declaration
#   ("this card is emphatically not `verified-here`") hijacked it. Anchoring the
#   match makes such a line not-a-declaration, exactly as intended.
#   The declaration line must (a) appear within the first 40 lines,
#   (b) be bold- or heading-marked, (c) carry exactly ONE allowed token.
#   A3 (SEAT-09, r103): the 13 card FILENAMES are compared against the pinned set
#   (PINNED_CARD_NAMES, mirrored in gate/README.md) — a renamed/typo'd card that
#   keeps the count at 13 is a FAIL.
#   Expected: 13 cards, BAD=0, NAME_SET=OK, census 12 static-only / 1
#   unproven-runtime / 0 verified-here.
# ---------------------------------------------------------------------------
printf 'CHECK 3 verdict-card-scan\n'
ALLOWED='(^|[^A-Za-z0-9-])(verified-here|static-only|unproven-runtime)([^A-Za-z0-9-]|$)'
TOKENS='verified-here|static-only|unproven-runtime'
LABEL_RE="^[[:space:]]*\\*\\*(Label|Verdict)( label)?:\\*\\*[[:space:]]*\`?($TOKENS)|\
^[[:space:]]*\\*\\*(Label|Verdict)( label)?:[[:space:]]*\`?($TOKENS)\`?\\*\\*|\
^[[:space:]]*(Label|Verdict)( label)?:[[:space:]]*\\*\\*[[:space:]]*\`?($TOKENS)|\
^[[:space:]]*\\*\\*\`($TOKENS)\`\\*\\*|\
^[[:space:]]*#+[[:space:]]*(Label|Verdict)( label)?:[[:space:]]*\`?($TOKENS)"
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
  rec=$(grep -nE "$LABEL_RE" "$f" | head -1)
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
# A3 (SEAT-09, r103): the 13 domain names are pinned. A count-only check let a card
# be silently dropped-and-replaced under a typo'd or renamed filename with the gate
# still green. Names are the file stems, sorted; both directions are reported.
NAME_BAD=0
for n in $PINNED_CARD_NAMES; do
  [ -f "$SUB/executability/$n.md" ] || { printf 'FAIL card-name-missing %s.md\n' "$n"; NAME_BAD=$((NAME_BAD+1)); }
done
for f in $CARDS; do
  b=$(basename "$f" .md)
  case " $PINNED_CARD_NAMES " in *" $b "*) ;; *) printf 'FAIL card-name-extra %s\n' "$(basename "$f")"; NAME_BAD=$((NAME_BAD+1));; esac
done
printf 'NAME_SET=%s NAME_BAD=%s\n' "$([ "$NAME_BAD" -eq 0 ] && echo OK || echo BAD)" "$NAME_BAD"
if [ "$C3_N" -eq "$EXPECTED_CARDS" ] && [ "$C3_BAD" -eq 0 ] && [ "$NAME_BAD" -eq 0 ] && \
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
#   A1 (SEAT-09, r103): every ENDPOINT of a `:a-b` range or `:a,b` list is validated,
#   and POINTERS counts endpoints (the reference sweep's semantics); POINTER_STRINGS
#   counts the unique pointer strings those endpoints came from.
#   Expected: UNRESOLVED=0.
# ---------------------------------------------------------------------------
printf 'CHECK 4 pointer-sweep\n'
BASE=$SUB
SELF=$GATE_DIR/README.md
SENTINEL='upstream/nope\.md:[0-9]+|upstream/README\.md:(9999|500)'
P_TOTAL=0; P_BAD=0; P_SKIPPED=0; P_STRINGS=0
while IFS= read -r f; do
  case "$f" in "$SUB"/upstream/*|"$SELF") continue;; esac
  while IFS= read -r ptr; do
    [ -z "$ptr" ] && continue
    if printf '%s' "$ptr" | grep -qE "^($SENTINEL)$"; then P_SKIPPED=$((P_SKIPPED+1)); continue; fi
    P_STRINGS=$((P_STRINGS+1))
    p=${ptr%:*}; rest=${ptr#*:}
    if [ ! -f "$BASE/$p" ]; then
      printf 'MISSING-PATH %s :: %s\n' "$f" "$ptr"; P_BAD=$((P_BAD+1)); continue
    fi
    n=$(wc -l < "$BASE/$p")
    # A1 (SEAT-09, r103): validate EVERY endpoint, and count every endpoint. `:a-b`
    # ranges and `:a,b` lists were previously read as `:a` only, because the old
    # extraction regex stopped at the first number while ${ptr##*:} still kept the
    # tail — so a planted `upstream/README.md:1-9999` resolved as in-range `:1`.
    # P_TOTAL now has the same semantics as the round's reference sweep
    # (reports/round-102/reruns/pointer-sweep.sh): one increment per endpoint.
    for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
      P_TOTAL=$((P_TOTAL+1))
      [ "$ln" -lt 1 ] && { printf 'LINE-ZERO %s :: %s\n' "$f" "$ptr"; P_BAD=$((P_BAD+1)); continue; }
      [ "$ln" -gt "$n" ] && { printf 'LINE-OOR %s :: %s (max %s)\n' "$f" "$ptr" "$n"; P_BAD=$((P_BAD+1)); }
    done
  done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" "$f" | sort -u)
done < <(find "$SUB" -type f \( -iname '*.md' -o -iname '*.txt' -o -iname '*.markdown' \) | sort)
# HARDENING G (SEAT-20): the upstream/-only sweep cannot see dangling
# corpus/... or reports/... pointers. Sweep backtick-wrapped repo-relative paths.
# A4b (SEAT-09, r103): this root is named REPO_ROOT, not REPO. It previously
# reused REPO — the same name as the upstream clone URL at the top of the file —
# so any caller overriding the clone target (`REPO=<url> run_gate.sh`, the obvious
# way to test the BLOCKED path) silently repointed pass B at a nonexistent
# directory and produced ~26 spurious MISSING-PATH-REL failures. Distinct names.
REPO_ROOT=$(cd "$SUB/../../.." && pwd)
while IFS= read -r ptr; do
  [ -z "$ptr" ] && continue
  case "$ptr" in http*|*'<'*|*'*'*|*'$'*) continue;; esac
  case "$ptr" in
    corpus/*|reports/*|docs/*) base=$REPO_ROOT ;;
    executability/*|gate/*|upstream/*|.manifest.d/*) base=$SUB ;;
    *) continue ;;
  esac
  P_TOTAL=$((P_TOTAL+1))
  [ -e "$base/$ptr" ] || { printf 'MISSING-PATH-REL %s\n' "$ptr"; P_BAD=$((P_BAD+1)); }
done < <({ grep -rhoE '[`][A-Za-z0-9_./-]+\.(md|sh|json|sha256|py|txt)(:[0-9]+)?[`]' --include='*.md' "$SUB" 2>/dev/null; grep -rhoE '[`]upstream/[A-Za-z0-9_./-]+:[0-9]+[`]' --include='*.md' "$SUB" 2>/dev/null; } | tr -d '`' | sed 's/:[0-9]\+$//' | sort -u)
printf 'POINTERS=%s POINTER_STRINGS=%s SKIPPED_CONTROL_SENTINELS=%s UNRESOLVED=%s\n' \
  "$P_TOTAL" "$P_STRINGS" "$P_SKIPPED" "$P_BAD"
if [ "$P_BAD" -eq 0 ]; then printf 'STEP=PASS\n\n'; else printf 'STEP=FAIL\n\n'; FAILS=$((FAILS+1)); fi

# ---------------------------------------------------------------------------
# Exit codes (A4, SEAT-09, r103): 0 PASS · 1 FAIL · 2 BLOCKED (CHECK 2 only).
# The code, not the summary line, is what distinguishes a blocked check from a
# failed one; GATE RESULT still reads PASS/FAIL so no existing caller breaks.
if [ "$C2_BLOCKED" -eq 1 ] && [ "$FAILS" -eq 0 ]; then
  printf 'GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)\n'
  exit 2
fi
printf 'GATE RESULT: %s (checks failed: %s)\n' \
  "$([ "$FAILS" -eq 0 ] && echo PASS || echo FAIL)" "$FAILS"
[ "$FAILS" -eq 0 ] && exit 0 || exit 1
