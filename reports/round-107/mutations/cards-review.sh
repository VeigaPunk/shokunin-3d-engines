#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# reports/round-107/mutations/cards-review.sh — INDEPENDENT executability-card
# review (seat MUT-CARD, round 107). This is the "cards review" half of the
# mutation test: it must catch a corrupted card PATH that the close-out gate may
# or may not catch.
#
# Deliberately NOT a copy of gate/run_gate.sh's regexes. It re-derives its
# checks from what a card CLAIMS about itself:
#   R1  card filename is in the pinned 13-name set
#   R2  every `upstream/<path>:<line>` citation resolves (path exists, line in range)
#   R3a STRICT: every backticked token whose FIRST SEGMENT is a known local root
#       (corpus reports docs executability gate upstream .manifest.d) must resolve
#       against repo root / subtree root / subtree-upstream.
#   R3b ADVISORY: other path-shaped tokens (repo slugs, MCP method names, UE
#       install paths, and each card's documented SHORT FORMS such as
#       `references/setup.md`) are COUNTED AND PRINTED but are not failures —
#       resolving a short form requires parsing that card's own mapping sentence,
#       which this reviewer does not attempt. Reported as an explicit limitation.
#   R4  the `**Vendored at:**` target exists and is a directory
#   R5  exactly one verdict-label token is declared, using the same five anchored
#       declaration shapes the cards actually use (a card may declare on a later
#       line: `## Verdict` then a blank line then `**`static-only`**`).
#
# usage: cards-review.sh <subtree-root>            e.g. <lane>/corpus/knowledge/unreal-mcp
# exit 0 = all cards clean; 1 = at least one FAIL; 2 = usage/environment error
# ---------------------------------------------------------------------------
set -u

SUB=${1:-}
[ -n "$SUB" ] || { printf 'usage: %s <subtree-root>\n' "$0" >&2; exit 2; }
[ -d "$SUB/executability" ] || { printf 'REVIEW FAIL no executability/ under %s\n' "$SUB"; exit 2; }
REPO_ROOT=$(cd "$SUB/../../.." && pwd)   # <lane> — same resolution the gate uses
EX=$SUB/executability

PINNED='actors-scene animation-controlrig assets-content blueprints editor-general gameplay-gas materials meshes-textures scripting-programmatic sequencer testing-automation ui-umg-slate vfx-niagara-dataflow'
LOCAL_ROOTS='corpus|reports|docs|executability|gate|upstream|\.manifest\.d'
TOKENS='verified-here|static-only|unproven-runtime'
LABEL_RE="^[[:space:]]*\\*\\*(Label|Verdict)( label)?:\\*\\*[[:space:]]*\`?($TOKENS)|\
^[[:space:]]*\\*\\*(Label|Verdict)( label)?:[[:space:]]*\`?($TOKENS)\`?\\*\\*|\
^[[:space:]]*(Label|Verdict)( label)?:[[:space:]]*\\*\\*[[:space:]]*\`?($TOKENS)|\
^[[:space:]]*\\*\\*\`($TOKENS)\`\\*\\*|\
^[[:space:]]*#+[[:space:]]*(Label|Verdict)( label)?:[[:space:]]*\`?($TOKENS)"

FAILS=0; ADVISORY=0
note() { printf '%s\n' "$*"; }
fail() { printf 'REVIEW-FAIL %s\n' "$*"; FAILS=$((FAILS+1)); }

note "CARDS-REVIEW subtree=$SUB"
note "CARDS-REVIEW repo_root=$REPO_ROOT"

# ---- R1: filename set -----------------------------------------------------
for n in $PINNED; do
  [ -f "$EX/$n.md" ] || fail "card-name-missing $n.md"
done
for f in "$EX"/*.md; do
  [ -e "$f" ] || continue
  b=$(basename "$f" .md)
  case " $PINNED " in *" $b "*) ;; *) fail "card-name-extra $(basename "$f")";; esac
done

# ---- R5: exactly one declared label, within the first 40 lines -------------
N_LABEL=0; N_STATIC=0; N_UNPROVEN=0; N_VERIFIED=0
for f in "$EX"/*.md; do
  [ -e "$f" ] || continue
  b=$(basename "$f")
  rec=$(head -40 "$f" | grep -nE "$LABEL_RE" | head -1)
  if [ -z "$rec" ]; then fail "no-label $b"; continue; fi
  text=${rec#*:}
  cnt=$(printf '%s' "$text" | grep -oE "(^|[^A-Za-z0-9-])($TOKENS)([^A-Za-z0-9-]|$)" | wc -l)
  lab=$(printf '%s' "$text" | grep -oE "$TOKENS" | head -1)
  if [ "$cnt" -ne 1 ]; then fail "multi-label $b :: $text"; continue; fi
  case "$lab" in
    static-only)      N_STATIC=$((N_STATIC+1)) ;;
    unproven-runtime) N_UNPROVEN=$((N_UNPROVEN+1)) ;;
    verified-here)    N_VERIFIED=$((N_VERIFIED+1)) ;;
  esac
  N_LABEL=$((N_LABEL+1))
  note "CARDS-REVIEW label $(printf '%-30s' "$b") $lab"
done
note "CARDS-REVIEW cards_labeled=$N_LABEL expected=13"
# R5b: census — a card that keeps the count at 13 but flips a label token must fail.
if [ "$N_STATIC" -ne 12 ] || [ "$N_UNPROVEN" -ne 1 ] || [ "$N_VERIFIED" -ne 0 ]; then
  fail "label-census static-only=$N_STATIC unproven-runtime=$N_UNPROVEN verified-here=$N_VERIFIED (expected 12/1/0)"
fi

resolves() {
  local t=$1
  case "$t" in
    http*|*'<'*|*'*'*|*'$'*|*'…'*) return 0 ;;
  esac
  [ -e "$REPO_ROOT/$t" ] && return 0
  [ -e "$SUB/$t" ] && return 0
  [ -e "$SUB/upstream/$t" ] && return 0
  return 1
}

for f in "$EX"/*.md; do
  [ -e "$f" ] || continue
  b=$(basename "$f")

  # ---- R2: upstream/<path>:<line> citations ------------------------------
  while IFS= read -r ptr; do
    [ -z "$ptr" ] && continue
    p=${ptr%:*}; rest=${ptr#*:}
    if [ ! -f "$SUB/$p" ]; then fail "$b MISSING-PATH $ptr"; continue; fi
    max=$(wc -l < "$SUB/$p")
    for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
      case "$ln" in ''|*[!0-9]*) continue;; esac
      [ "$ln" -lt 1 ] || [ "$ln" -gt "$max" ] && fail "$b LINE-OOR $ptr (max $max)"
    done
  done < <(grep -ohE 'upstream/[^ `"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*' "$f" | sort -u)

  # ---- R3a STRICT: backticked tokens with a known local first segment -----
  # `path:line` is split BEFORE the filesystem test — an earlier version tested
  # the whole `path:line` string and reported a false UNRESOLVED-LOCAL-PATH.
  while IFS= read -r tok; do
    [ -z "$tok" ] && continue
    p=${tok%:*}; rest=${tok#*:}
    case "$p" in "$tok") rest='';; esac
    if ! resolves "$p"; then fail "$b UNRESOLVED-LOCAL-PATH \`$tok\`"; continue; fi
    if [ -n "$rest" ] && [ -f "$REPO_ROOT/$p" ]; then
      max=$(wc -l < "$REPO_ROOT/$p")
      for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
        case "$ln" in ''|*[!0-9]*) continue;; esac
        [ "$ln" -lt 1 ] || [ "$ln" -gt "$max" ] && fail "$b LINE-OOR \`$tok\` (max $max)"
      done
    fi
  done < <(grep -ohE '`[A-Za-z0-9_.-][A-Za-z0-9_.:/-]*`' "$f" | tr -d '`' \
           | grep -E "^($LOCAL_ROOTS)/" | sort -u)

  # ---- R3b ADVISORY: other path-shaped tokens (not a failure) ------------
  while IFS= read -r tok; do
    [ -z "$tok" ] && continue
    resolves "$tok" || ADVISORY=$((ADVISORY+1))
  done < <(grep -ohE '`[A-Za-z0-9_][A-Za-z0-9_.:/-]*/[A-Za-z0-9_.:/-]*`' "$f" | tr -d '`' \
           | grep -vE "^($LOCAL_ROOTS)/" | sort -u)

  # ---- R4: `**Vendored at:**` target is an existing directory ------------
  while IFS= read -r vend; do
    [ -z "$vend" ] && continue
    [ -d "$REPO_ROOT/$vend" ] || fail "$b VENDORED-AT-NOT-A-DIR \`$vend\`"
  done < <(grep -oE '^\*\*Vendored at:\*\*[[:space:]]*`[^`]+`' "$f" | grep -oE '`[^`]+`' | tr -d '`')
done

note "CARDS-REVIEW FAILS=$FAILS ADVISORY_UNRESOLVED=$ADVISORY"
if [ "$FAILS" -eq 0 ]; then printf 'CARDS-REVIEW RESULT: PASS\n'; exit 0; fi
printf 'CARDS-REVIEW RESULT: FAIL (%s finding(s))\n' "$FAILS"
exit 1
