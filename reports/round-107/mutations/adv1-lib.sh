#!/usr/bin/env bash
# adv1-lib.sh — shared harness for the r107 GATE-ADV1 attack suite.
#
# Builds a SCRATCH MIRROR of corpus/knowledge/unreal-mcp/ under
# /var/tmp/r107-gate-adv1/scratch/<key>/ so that mutations are applied to a copy
# and the live lane tree is never touched (HARD RULE 1/3). The mirror is a real
# tree plus symlinks for the repo-relative pointer roots CHECK 4 pass B needs
# (reports/, corpus/lessons/, corpus/artifacts/, corpus/knowledge/engines.md).
#
# run_gate captures the transcript to a log file and returns the gate's exit code
# in $GATE_EXIT. It must NOT be piped — a pipeline would report the last
# command's status, not the gate's (an early draft of this harness made exactly
# that mistake and read every attack as MISSED). Use `show <regex>` to print
# selected lines from $GATE_LOG afterwards.
set -u

LIVE=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
SCR=/var/tmp/r107-gate-adv1
REF=$SCR/ref                      # clone at the pinned commit a6aa73ad
REF_OLD=$SCR/ref-old              # clone at the PARENT commit d1b0580 (class A)
PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
PIN_ALT=d1b05809e4f089bd0ef174532c692fbcf1562eb7
mkdir -p "$SCR/logs"

build_mirror() {                  # $1 = key -> prints mirror dir
  local key=$1 d=$SCR/scratch/$1
  rm -rf "$d"; mkdir -p "$d/corpus/knowledge"
  cp -a "$LIVE/corpus/knowledge/unreal-mcp" "$d/corpus/knowledge/unreal-mcp"
  ln -s "$LIVE/reports"                     "$d/reports"
  ln -s "$LIVE/corpus/lessons"              "$d/corpus/lessons"
  ln -s "$LIVE/corpus/artifacts"            "$d/corpus/artifacts"
  ln -s "$LIVE/corpus/knowledge/engines.md" "$d/corpus/knowledge/engines.md"
  printf '%s\n' "$d"
}

ensure_refs() {
  [ -d "$REF/.git" ] || git clone --quiet \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin "$REF"
  if [ ! -d "$REF_OLD/.git" ]; then
    git clone --quiet \
      https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin "$REF_OLD"
    git -C "$REF_OLD" checkout --quiet "$PIN_ALT"
  fi
}

# run_gate <mirror> <tag> [ENV=VAL ...]
#   GATE_REF_OVERRIDE may be set by the caller to point the gate at another
#   reference clone. Pass GATE_REF_OVERRIDE=NONE to run the gate with GATE_REF
#   UNSET, which forces CHECK 2 down the network path against $REPO — the only
#   way to exercise the clone path at all.
run_gate() {
  local d=$1 tag=$2; shift 2
  local ref=${GATE_REF_OVERRIDE:-$REF}
  GATE_LOG=$SCR/logs/$tag.txt
  if [ "$ref" = NONE ]; then
    env "$@" GATE_WORKDIR="$SCR" \
        bash "$d/corpus/knowledge/unreal-mcp/gate/run_gate.sh" >"$GATE_LOG" 2>&1
  else
    env "$@" GATE_WORKDIR="$SCR" GATE_REF="$ref" \
        bash "$d/corpus/knowledge/unreal-mcp/gate/run_gate.sh" >"$GATE_LOG" 2>&1
  fi
  GATE_EXIT=$?
  return 0
}

show() { grep -E "$1" "$GATE_LOG" || true; }

baseline_ok() {                   # $1 = key
  local d=$SCR/scratch/$1
  run_gate "$d" "baseline-$1"
  if [ "$GATE_EXIT" -ne 0 ]; then
    printf 'HARNESS-ERROR baseline of %s is not green (exit %s)\n' "$1" "$GATE_EXIT"
    return 1
  fi
  printf 'HARNESS-OK baseline green (exit 0)\n'
}

verdict() {                       # $1 = class, $2 = exit code
  if [ "$2" -eq 0 ]; then
    printf '\n==> CLASS %s: MISSED (gate exit 0 — false-pass)\n' "$1"
  else
    printf '\n==> CLASS %s: DETECTED (gate exit %s)\n' "$1" "$2"
  fi
}
