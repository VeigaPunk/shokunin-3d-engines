#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# flake_harness.sh — repeat-run flake detector for the unreal-mcp close-out gate.
#
# SEAT-14 (r104). The gate's adversarial suites (r102/r103) test whether a
# PLANTED defect is caught. This harness tests the complementary property: that
# the gate returns the SAME verdict, with the SAME exit code, on an UNMODIFIED
# tree, run after run. A gate that flips PASS/FAIL or 0/1/2 between identical
# runs cannot be used as a close-out artifact no matter how many attacks it
# catches — and r103 hit exactly this class of bug (a hardcoded /tmp scratch
# path turned a clean tree into a spurious fail-closed).
#
# It is deliberately dumb: no plants, no scratch copies, no tree mutation. It
# only runs the installed gate N times and tallies what came back.
#
# usage: reports/round-104/gate/flake_harness.sh [N]
#   N                  number of runs (default 10; also FLAKE_N=<n>)
#   GATE=<path>        gate under test
#                      (default <repo>/corpus/knowledge/unreal-mcp/gate/run_gate.sh)
#   FLAKE_LOGDIR=<dir> per-run logs. Default: a directory probed for real-byte
#                      writability, real disk preferred over TMPDIR//tmp — see
#                      the LOGDIR block; a zero-byte or truncated log would make
#                      the harness report its own capture failure as a gate flake.
#   FLAKE_EXPECT=<v>   the verdict EVERY run must return: PASS (default), FAIL
#                      or BLOCKED. Any other verdict is a flake and fails.
#   GATE_WORKDIR=<dir> scratch on real disk. Passed to each run BOTH as the
#                      gate's own GATE_WORKDIR and as TMPDIR (so it works against
#                      a gate revision with or without the native knob), which
#                      lands the gate's mktemp -d and its clone on real disk
#                      instead of /tmp. This matters: /tmp here is a 16G tmpfs
#                      under a PER-USER QUOTA that df does not report — df said
#                      "3.1G available" while `echo hi > /tmp/probe` failed with
#                      "Disk quota exceeded" and git clone died in its own
#                      template copy (rc 128, empty stderr under --quiet) before
#                      reaching the network. Worse, the gate's HARDENING B
#                      redirects into a mktemp file whose write fails, so the
#                      gate prints `FAIL per-seat manifest sweep` and exits 1 on
#                      a BYTE-CLEAN tree. That is host weather, not a gate
#                      verdict, and it is indistinguishable from a real flake
#                      unless the harness says which. Set GATE_WORKDIR to a
#                      real-disk path (e.g. /home/<user>/tmp/gate) for clean
#                      readings; leave it unset to test the gate's DEFAULT host
#                      environment. The path is created if missing.
#   FLAKE_PROBE_TRIES=<n> scratch-probe repetitions (default 20). The failure is
#                      intermittent, so a single probe is not evidence.
#
# SCRATCH_PREFLIGHT=OK|INTERMITTENT|UNWRITABLE in the header is the harness's own
# readiness reading of the work root: it writes real bytes, reads them back, and
# repeats. Non-OK means any BLOCKED/EMPTY/TRUNCATED below is suspect host weather.
#
# Exit 0  iff every run returned the expected verdict with an exit code that
#         AGREES with that run's own `GATE RESULT:` line and a complete 4-STEP
#         tally.
# Exit 1  on any flake — EMPTY output, TRUNCATED log (cut off before the verdict
#         line), exit code outside {0,1,2}, rc/verdict disagreement, missing
#         verdict line, impossible STEP tally, or a verdict != FLAKE_EXPECT.
# Exit 2  on a usage/setup error (no gate, bad N, no writable log dir) —
#         deliberately distinct from "flaked".
#
# No Unreal runtime claim is made or implied. This is a static checker over
# vendored bytes; the editor is not installed on this host, so nothing here is
# evidence about live-MCP or editor behaviour.
# ---------------------------------------------------------------------------
set -u

SELF_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SELF_DIR/../../.." && pwd)
GATE=${GATE:-$REPO_ROOT/corpus/knowledge/unreal-mcp/gate/run_gate.sh}
N=${1:-${FLAKE_N:-10}}
EXPECT=${FLAKE_EXPECT:-PASS}

case "$N" in ''|*[!0-9]*) printf 'HARNESS ERROR: N must be a positive integer, got %q\n' "$N" >&2; exit 2;; esac
[ "$N" -ge 1 ] || { printf 'HARNESS ERROR: N must be >= 1\n' >&2; exit 2; }
case "$EXPECT" in PASS|FAIL|BLOCKED) ;; *) printf 'HARNESS ERROR: FLAKE_EXPECT must be PASS|FAIL|BLOCKED, got %q\n' "$EXPECT" >&2; exit 2;; esac
[ -f "$GATE" ] || { printf 'HARNESS ERROR: no gate at %s\n' "$GATE" >&2; exit 2; }

# Logs must live on a disk that can actually hold bytes. /tmp on this host is a
# 16G tmpfs under a per-user quota that is frequently exhausted. A zero-byte log
# classifies as EMPTY, and — worse — a log truncated MID-WRITE leaves an
# incomplete gate output that can still parse as a verdict, e.g. a `STEP=FAIL`
# and a `GATE RESULT: FAIL (checks failed: 1)` with the failing step's detail
# lines missing. The harness would then report its OWN capture failure as a gate
# flake. So the log dir is probed with a write-then-read of real bytes.
# Preference: FLAKE_LOGDIR (explicit), then real disk (never quota'd like /tmp),
# then GATE_WORKDIR / TMPDIR / /tmp.
logdir_usable() {
  [ -n "$1" ] || return 1
  mkdir -p "$1" 2>/dev/null || return 1
  local p="$1/.flake-probe.$$"
  printf 'flake log probe: real bytes must survive\n' >"$p" 2>/dev/null || return 1
  [ "$(cat "$p" 2>/dev/null)" = 'flake log probe: real bytes must survive' ] || { rm -f "$p"; return 1; }
  rm -f "$p"; return 0
}
LOGDIR=${FLAKE_LOGDIR:-}
if [ -z "$LOGDIR" ]; then
  for _base in "/home/${USER:-user}/tmp" "${GATE_WORKDIR:-}" "${TMPDIR:-}" "/tmp"; do
    if logdir_usable "$_base"; then
      _cand=$(mktemp -d "$_base/flake-harness.XXXXXX" 2>/dev/null) || _cand=
      if [ -n "$_cand" ]; then LOGDIR=$_cand; break; fi
    fi
  done
fi
[ -n "$LOGDIR" ] || { printf 'HARNESS ERROR: no writable directory for per-run logs (tried FLAKE_LOGDIR, ~/tmp, GATE_WORKDIR, TMPDIR, /tmp)\n' >&2; exit 2; }
logdir_usable "$LOGDIR" || { printf 'HARNESS ERROR: log dir is not writable for real bytes: %s\n' "$LOGDIR" >&2; exit 2; }

# GATE_WORKDIR: scratch on real disk. Passed to each run as the GATE'S OWN
# GATE_WORKDIR (the gate resolves ${GATE_WORKDIR:-${TMPDIR:-/tmp}} and validates
# it up front), with TMPDIR exported too so this works against a gate revision
# predating that knob. Unset means "test the gate in its default host
# environment" — the honest reading, and the one that surfaces /tmp weather.
if [ -n "${GATE_WORKDIR:-}" ]; then
  mkdir -p "$GATE_WORKDIR" || { printf 'HARNESS ERROR: cannot create GATE_WORKDIR %s\n' "$GATE_WORKDIR" >&2; exit 2; }
  WORKDIR_NOTE="$GATE_WORKDIR (passed as GATE_WORKDIR and TMPDIR to each run)"
else
  WORKDIR_NOTE="${TMPDIR:-/tmp} (inherited; GATE_WORKDIR unset)"
fi

# PREFLIGHT: prove the effective scratch dir can actually hold a file BEFORE
# blaming the gate for a BLOCKED or a FAIL. Two traps this guards against, both
# observed on this host:
#   1. df reports "3.1G available" on a tmpfs whose PER-USER QUOTA is exhausted,
#      so df is not a readiness check;
#   2. `mktemp` SUCCEEDS and creates a zero-byte file while the subsequent WRITE
#      fails with "Disk quota exceeded". A probe that only does `: >file` writes
#      zero bytes, succeeds, and reports OK — the gate's own scratch redirect
#      then fails, sha256sum never runs, and the gate prints a spurious
#      `FAIL per-seat manifest sweep` (exit 1) on a byte-clean tree.
# So the probe must write real bytes and read them back — and it must try more
# than once, because the failure is INTERMITTENT: a single small probe passed
# while 4 of the next 20 gate runs blocked on the same directory.
# The probe targets the WORK ROOT the gate will actually use — not this shell's
# TMPDIR — otherwise a healthy GATE_WORKDIR gets reported UNWRITABLE purely
# because the harness inherited a bad /tmp.
PROBE_ROOT=${GATE_WORKDIR:-${TMPDIR:-/tmp}}
PROBE_BYTES='flake-harness scratch probe: this text must survive the round trip'
PROBE_TRIES=${FLAKE_PROBE_TRIES:-20}
WORKDIR_HEALTH=OK; PROBE_FAILS=0
for _i in $(seq 1 "$PROBE_TRIES"); do
  _probe=$(mktemp "$PROBE_ROOT/probe.XXXXXX" 2>/dev/null) || _probe=
  if [ -z "$_probe" ] || ! printf '%s\n' "$PROBE_BYTES" >"$_probe" 2>/dev/null || \
     [ "$(cat "$_probe" 2>/dev/null)" != "$PROBE_BYTES" ]; then
    PROBE_FAILS=$((PROBE_FAILS+1))
  fi
  [ -n "$_probe" ] && rm -f "$_probe"
done
if [ "$PROBE_FAILS" -gt 0 ]; then
  if [ "$PROBE_FAILS" -eq "$PROBE_TRIES" ]; then WORKDIR_HEALTH=UNWRITABLE
  else WORKDIR_HEALTH=INTERMITTENT; fi
fi

printf 'FLAKE HARNESS unreal-mcp gate\n'
printf 'GATE=%s\n' "$GATE"
printf 'GATE_SHA256=%s\n' "$(sha256sum "$GATE" | cut -d' ' -f1)"
printf 'REPO_ROOT=%s\n' "$REPO_ROOT"
printf 'RUNS=%s EXPECT=%s\n' "$N" "$EXPECT"
printf 'GATE_WORKDIR=%s\n' "$WORKDIR_NOTE"
printf 'SCRATCH_PREFLIGHT=%s (%s/%s probe writes failed in %s)\n' "$WORKDIR_HEALTH" "$PROBE_FAILS" "$PROBE_TRIES" "$PROBE_ROOT"
printf 'LOGDIR=%s\n' "$LOGDIR"
if [ "$WORKDIR_HEALTH" != OK ]; then
  printf 'PREFLIGHT WARNING: scratch dir is unreliable: %s\n' "$WORKDIR_NOTE"
  printf 'PREFLIGHT WARNING: a BLOCKED below is host scratch exhaustion (the gate copies a clone into TMPDIR), not a gate defect; a FAIL below may be the same quota failure landing on the gate own scratch redirect.\n'
  printf 'PREFLIGHT WARNING: re-run with GATE_WORKDIR=<path on real disk> for a meaningful reading.\n'
fi
printf '\n'

# classify <rc> <logfile> -> one token on stdout:
#   PASS|FAIL|BLOCKED   rc in {0,1,2} and agrees with the run's own GATE RESULT line
#   EMPTY               no output at all
#   UNEXPECTED          rc outside {0,1,2}, no GATE RESULT line, a STEP tally that
#                       the verdict cannot be produced by, or an rc/verdict pair
#                       that is structurally impossible
#   MISMATCH            rc and GATE RESULT disagree (the A4 contract broken)
#   TRUNCATED           the log's last line is not the `GATE RESULT:` line, so
#                       the capture was cut off mid-write and no verdict can be
#                       read from it. Without this test a truncated log whose
#                       surviving tail happened to contain one `STEP=FAIL` and a
#                       `GATE RESULT: FAIL` line would be reported as a real gate
#                       FAIL — the harness blaming the gate for its own failed
#                       log write.
#
# The STEP tally is checked PER VERDICT, because "4 PASS" is only the shape of a
# PASS run. The gate scores exactly four steps and exits 0 only with all four
# PASS, 1 with >=1 FAIL, and 2 only when CHECK 2 BLOCKED and nothing else failed
# — so a BLOCKED run is one STEP=BLOCKED plus three STEP=PASS. An earlier
# revision of this harness required four PASS steps unconditionally, which made
# every genuinely-blocked run classify as UNEXPECTED and made FLAKE_EXPECT=BLOCKED
# unusable; caught by negative control NC5 before this file was reported.
classify() {
  local rc=$1 f=$2 verdict n_total n_bad last
  if [ ! -s "$f" ]; then printf 'EMPTY'; return; fi
  last=$(tail -1 "$f")
  case "$last" in
    'GATE RESULT:'*) ;;
    *) printf 'TRUNCATED'; return ;;
  esac
  verdict=$last
  case "$rc" in 0|1|2) ;; *) printf 'UNEXPECTED'; return;; esac
  n_total=$(grep -cE '^STEP=(PASS|FAIL|BLOCKED)$' "$f" || true)
  n_bad=$(grep -cE '^STEP=(FAIL|BLOCKED)$' "$f" || true)
  [ "$n_total" -eq 4 ] || { printf 'UNEXPECTED'; return; }
  case "$rc:$verdict" in
    0:*'PASS'*)    if [ "$n_bad" -eq 0 ]; then printf 'PASS';    else printf 'UNEXPECTED'; fi ;;
    1:*'FAIL'*)    if [ "$n_bad" -ge 1 ]; then printf 'FAIL';    else printf 'UNEXPECTED'; fi ;;
    2:*'BLOCKED'*) if [ "$n_bad" -eq 1 ]; then printf 'BLOCKED'; else printf 'UNEXPECTED'; fi ;;
    *)             printf 'MISMATCH' ;;
  esac
}

n_pass=0; n_fail=0; n_blocked=0; n_empty=0; n_bad=0; n_trunc=0
for i in $(seq 1 "$N"); do
  log=$LOGDIR/run-$i.log
  start=$(date +%s.%N 2>/dev/null || date +%s)
  if [ -n "${GATE_WORKDIR:-}" ]; then
    ( cd "$REPO_ROOT" && GATE_WORKDIR="$GATE_WORKDIR" TMPDIR="$GATE_WORKDIR" bash "$GATE" ) >"$log" 2>&1
  else
    ( cd "$REPO_ROOT" && bash "$GATE" ) >"$log" 2>&1
  fi
  rc=$?
  end=$(date +%s.%N 2>/dev/null || date +%s)
  secs=$(awk -v a="$start" -v b="$end" 'BEGIN{printf "%.2f", b-a}' 2>/dev/null || printf '?')
  v=$(classify "$rc" "$log")
  case "$v" in
    PASS)      n_pass=$((n_pass+1)) ;;
    FAIL)      n_fail=$((n_fail+1)) ;;
    BLOCKED)   n_blocked=$((n_blocked+1)) ;;
    EMPTY)     n_empty=$((n_empty+1)) ;;
    TRUNCATED) n_trunc=$((n_trunc+1)) ;;
    *)         n_bad=$((n_bad+1)) ;;
  esac
  pointers=$(grep -oE '^POINTERS=[0-9]+' "$log" | tail -1 || true)
  printf 'run %2d/%s  rc=%s  verdict=%-10s %-8s %6ss  %s\n' \
    "$i" "$N" "$rc" "$v" "${pointers:-POINTERS=?}" "$secs" "$(basename "$log")"
  # A capture-side failure did not execute far enough to be judged: bash writes
  # the redirect before it runs the script, so EMPTY/TRUNCATED mean the SHELL or
  # the log write failed, not the gate. Re-run uncaptured so the real diagnostic
  # reaches this harness's stderr instead of being swallowed by the same failure.
  case "$v" in
    EMPTY|TRUNCATED)
      printf '  %s capture failure; re-running uncaptured to surface the diagnostic:\n' "$v"
      ( cd "$REPO_ROOT" && bash "$GATE" ) 2>&1 | sed 's/^/  ! /' | head -12
      printf '  (end uncaptured diagnostic)\n' ;;
  esac
  if [ "$v" != "$EXPECT" ]; then
    printf '  --- output of the offending run (%s) ---\n' "$v"
    sed 's/^/  | /' "$log"
    printf '  --- end %s ---\n' "$(basename "$log")"
  fi
done

printf '\nTALLY runs=%s pass=%s fail=%s blocked=%s empty=%s truncated=%s unexpected=%s\n' \
  "$N" "$n_pass" "$n_fail" "$n_blocked" "$n_empty" "$n_trunc" "$n_bad"

flakes=0
[ "$n_empty" -gt 0 ] && { printf 'FLAKE empty-output: %s run(s) produced no output at all\n' "$n_empty"; flakes=$((flakes+1)); }
[ "$n_trunc" -gt 0 ] && { printf 'FLAKE truncated-log: %s run(s) had a log cut off before the GATE RESULT line — a CAPTURE failure (usually the log disk), not a gate verdict\n' "$n_trunc"; flakes=$((flakes+1)); }
[ "$n_bad" -gt 0 ]   && { printf 'FLAKE unexpected: %s run(s) had a bad exit code, no GATE RESULT line, or an impossible STEP tally\n' "$n_bad"; flakes=$((flakes+1)); }
case "$EXPECT" in
  PASS)    [ "$n_pass" -eq "$N" ]    || { printf 'FLAKE verdict: expected PASS on all %s runs, got pass=%s fail=%s blocked=%s\n' "$N" "$n_pass" "$n_fail" "$n_blocked"; flakes=$((flakes+1)); } ;;
  FAIL)    [ "$n_fail" -eq "$N" ]    || { printf 'FLAKE verdict: expected FAIL on all %s runs, got pass=%s fail=%s blocked=%s\n' "$N" "$n_pass" "$n_fail" "$n_blocked"; flakes=$((flakes+1)); } ;;
  BLOCKED) [ "$n_blocked" -eq "$N" ] || { printf 'FLAKE verdict: expected BLOCKED on all %s runs, got pass=%s fail=%s blocked=%s\n' "$N" "$n_pass" "$n_fail" "$n_blocked"; flakes=$((flakes+1)); } ;;
esac

if [ "$flakes" -eq 0 ]; then
  printf 'HARNESS RESULT: STABLE (%s/%s runs returned %s with a matching exit code)\n' "$N" "$N" "$EXPECT"
  printf 'NOTE: stability of a static gate is not evidence about Unreal Editor behaviour — the editor is not installed here.\n'
  exit 0
fi
printf 'HARNESS RESULT: FLAKY (%s distinct flake class(es) above; per-run logs in %s)\n' "$flakes" "$LOGDIR"
exit 1
