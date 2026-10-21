#!/usr/bin/env bash
# rev-gate-discriminate.sh — REV-GATE seat, round 107 (3D side-round).
#
# Independent discrimination suite for the close-out gate
# `corpus/knowledge/unreal-mcp/gate/run_gate.sh`.
#
# ACCEPT controls: benign variants that MUST stay green (false-positive guards).
# ATTACK classes: corruptions that MUST be rejected, each with its detector line.
# Every case is run on a throwaway skeleton repo root holding a REAL copy of the
# subtree; the mutation is applied there, its landing is CONFIRMED, then the
# UNMODIFIED gate runs from the copy. Nothing is written into the real repo.
#
# The skeleton root exists because CHECK 4 pass B resolves `corpus/...` and
# `reports/...` pointers against REPO_ROOT=$SUB/../../.. ; the subtree is a real
# copy, the siblings are symlinks (read-only resolution).
#
# usage: reports/round-107/mutations/rev-gate-discriminate.sh
set -u

R=/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
SUB=$R/corpus/knowledge/unreal-mcp
ROOT=/var/tmp/r107-rev-gate
CASES=$ROOT/cases
LOGS=$ROOT/logs
WORK=$ROOT/work
rm -rf "$CASES" "$LOGS"; mkdir -p "$CASES" "$LOGS" "$WORK"

mk_tree() { # $1 = case name -> prints skeleton root
  local c sk b e
  c=$1; sk=$CASES/$c
  rm -rf "$sk"; mkdir -p "$sk/corpus/knowledge"
  for e in "$R"/*; do b=$(basename "$e"); case $b in corpus|reports|.git) continue;; esac; ln -s "$e" "$sk/$b"; done
  ln -s "$R/reports" "$sk/reports"
  for e in "$R"/corpus/*; do b=$(basename "$e"); [ "$b" = knowledge ] && continue; ln -s "$e" "$sk/corpus/$b"; done
  for e in "$R"/corpus/knowledge/*; do b=$(basename "$e"); [ "$b" = unreal-mcp ] && continue; ln -s "$e" "$sk/corpus/knowledge/$b"; done
  cp -r "$SUB" "$sk/corpus/knowledge/unreal-mcp"
  printf '%s' "$sk"
}

gate() { # $1 = skeleton root; GATE_ENV (optional) holds extra env assignments
  local sk=$1
  ( cd "$sk" && env GATE_WORKDIR="$WORK" ${GATE_ENV:-} \
      "$sk/corpus/knowledge/unreal-mcp/gate/run_gate.sh" ) >"$LOGS/$CASE.txt" 2>&1
  printf '%s' "$?"
}

report() { # $1 = expected exit, $2 = actual exit
  local verdict=OK
  [ "$1" = "$2" ] || verdict=MISMATCH
  printf 'CASE=%-30s EXPECT_EXIT=%s EXIT=%s %s\n' "$CASE" "$1" "$2" "$verdict"
  grep -E '^(MANIFEST_FILES=|MANIFEST_OK=|PATH_EXTRA=|PATH_MISSING=|BLOB_DIFFS=|CARDS=|CENSUS |NAME_SET=|POINTERS=|STEP=|GATE RESULT:|FAIL |FAIL$|non-regular|nested entry|CR byte|per-seat manifest|CHECK 2 BLOCKED|LINE-OOR|LINE-ZERO|MISSING-PATH|card-name|BLOB-DIFF)' \
    "$LOGS/$CASE.txt" | sed 's/^/  /' | head -12
  printf '\n'
}

one() { # $1 name, $2 expected exit, $3 mutation fn, $4 confirm fn
  CASE=$1
  local sk rc; sk=$(mk_tree "$CASE"); "$3" "$sk"
  printf 'LANDED[%s] %s\n' "$CASE" "$("$4" "$sk")"
  rc=$(gate "$sk"); report "$2" "$rc"
  printf '%s %s %s\n' "$CASE" "$2" "$rc" >> "$ROOT/summary.txt"
}

one_env() { # $1 name, $2 expected exit, $3 mutation fn, $4 confirm fn, $5 env assignments
  CASE=$1
  local sk rc; sk=$(mk_tree "$CASE"); "$3" "$sk"
  printf 'LANDED[%s] %s\n' "$CASE" "$("$4" "$sk")"
  GATE_ENV=$5 rc=$(gate "$sk"); GATE_ENV=
  report "$2" "$rc"
  printf '%s %s %s\n' "$CASE" "$2" "$rc" >> "$ROOT/summary.txt"
}

# ---------------- mutations ----------------
mut_clean()      { :; }
mut_byteflip()   { printf '\n' >> "$1/corpus/knowledge/unreal-mcp/upstream/README.md"; }
mut_strayfile()  { printf 'ATTACKER\n' > "$1/corpus/knowledge/unreal-mcp/upstream/PLANTED-EXTRA.md"; }
mut_delfile()    { rm "$1/corpus/knowledge/unreal-mcp/upstream/LICENSE"; }
mut_delcard()    { rm "$1/corpus/knowledge/unreal-mcp/executability/sequencer.md"; }
mut_relabel()    { sed -i '4s/.*/**Label:** `unproven-runtime`/' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
mut_multilabel() { sed -i '4s/.*/**Label:** `static-only` and not `verified-here`/' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
mut_oor()        { printf '\nsee upstream/README.md:200\n' >> "$1/corpus/knowledge/unreal-mcp/README.md"; }
mut_manicorrupt(){ sed -i 's|^[0-9a-f]\{64\}\(  upstream/README\.md\)$|0000000000000000000000000000000000000000000000000000000000000000\1|' "$1/corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256"; }
mut_manidrop()   { sed -i '\|  upstream/README\.md$|d' "$1/corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256"; }
mut_renamecard() { mv "$1/corpus/knowledge/unreal-mcp/executability/sequencer.md" "$1/corpus/knowledge/unreal-mcp/executability/sequence-typo.md"; }
mut_symlink()    { ln -s /etc/hostname "$1/corpus/knowledge/unreal-mcp/upstream/backdoor.md"; }
mut_nested()     { mkdir -p "$1/corpus/knowledge/unreal-mcp/executability/sub"; printf 'x\n' > "$1/corpus/knowledge/unreal-mcp/executability/sub/extra.md"; }
mut_crlf()       { sed -i 's/$/\r/' "$1/corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256"; }
mut_seatman()    { printf '0000000000000000000000000000000000000000000000000000000000000000  upstream/README.md\n' > "$1/corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256"; }
mut_oorrange()   { printf '\nsee upstream/README.md:1-9999\n' >> "$1/corpus/knowledge/unreal-mcp/README.md"; }
mut_wrongpin()   { sed -i 's/^PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297$/PIN=435522c0c66685049ac624fef04568ec313bebe7/' "$1/corpus/knowledge/unreal-mcp/gate/run_gate.sh"; }
mut_sentinel()   { printf '\nsee `upstream/nope.md:3`\nsee `upstream/README.md:9999`\n' >> "$1/corpus/knowledge/unreal-mcp/README.md"; }
mut_prose()      { sed -i '4i this card is emphatically not `verified-here`' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
mut_validrange() { printf '\nsee upstream/README.md:39,45\n' >> "$1/corpus/knowledge/unreal-mcp/README.md"; }
mut_card14()     { printf '# Extra\n\n**Label:** `static-only`\n' > "$1/corpus/knowledge/unreal-mcp/executability/zz-extra.md"; }
mut_nonmd()      { printf 'not markdown\n' > "$1/corpus/knowledge/unreal-mcp/executability/notes.txt"; }
mut_deeplabel()  { sed -i '4s/.*/prose filler/' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; for i in $(seq 1 40); do printf 'filler line %s\n' "$i" >> "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; done; printf '**Label:** `static-only`\n' >> "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
mut_unmarked()   { sed -i '4s/.*/Label: static-only/' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
mut_nolabel()    { sed -i '4s/.*/prose with no token/' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
mut_ptrpath()    { printf '\nsee upstream/DOES-NOT-EXIST.md:3\n' >> "$1/corpus/knowledge/unreal-mcp/README.md"; }
mut_refbad()     { :; }

# ---------------- landed confirmations ----------------
c_clean()      { echo "no mutation by design"; }
c_byteflip()   { printf 'size=%s tail=%s' "$(wc -c < "$1/corpus/knowledge/unreal-mcp/upstream/README.md")" "$(tail -c 1 "$1/corpus/knowledge/unreal-mcp/upstream/README.md" | od -An -c | tr -s ' ')"; }
c_strayfile()  { ls "$1/corpus/knowledge/unreal-mcp/upstream/PLANTED-EXTRA.md"; }
c_delfile()    { test ! -e "$1/corpus/knowledge/unreal-mcp/upstream/LICENSE" && echo "LICENSE gone"; }
c_delcard()    { test ! -e "$1/corpus/knowledge/unreal-mcp/executability/sequencer.md" && echo "sequencer.md gone"; }
c_relabel()    { sed -n '4p' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
c_multilabel() { sed -n '4p' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
c_oor()        { tail -1 "$1/corpus/knowledge/unreal-mcp/README.md"; }
c_manicorrupt(){ printf 'zeroed-lines=%s' "$(grep -c '^0000000000000000000000000000000000000000000000000000000000000000' "$1/corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256")"; }
c_manidrop()   { printf 'readme-lines=%s' "$(grep -c '  upstream/README.md$' "$1/corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256")"; }
c_renamecard() { printf 'typo-names=%s' "$(ls "$1/corpus/knowledge/unreal-mcp/executability/" | grep -c typo)"; }
c_symlink()    { printf 'symlinks=%s' "$(find "$1/corpus/knowledge/unreal-mcp/upstream" -type l | wc -l)"; }
c_nested()     { find "$1/corpus/knowledge/unreal-mcp/executability" -mindepth 2 | sed 's/^/nested=/'; }
c_crlf()       { printf 'cr-lines=%s' "$(grep -cU $'\r' "$1/corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256")"; }
c_seatman()    { head -1 "$1/corpus/knowledge/unreal-mcp/.manifest.d/seat01.sha256"; }
c_oorrange()   { tail -1 "$1/corpus/knowledge/unreal-mcp/README.md"; }
c_wrongpin()   { grep '^PIN=' "$1/corpus/knowledge/unreal-mcp/gate/run_gate.sh"; }
c_sentinel()   { tail -2 "$1/corpus/knowledge/unreal-mcp/README.md" | tr '\n' ' '; }
c_prose()      { sed -n '4p' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
c_validrange() { tail -1 "$1/corpus/knowledge/unreal-mcp/README.md"; }
c_card14()     { printf 'cardfiles=%s' "$(ls "$1/corpus/knowledge/unreal-mcp/executability/" | wc -l)"; }
c_nonmd()      { ls "$1/corpus/knowledge/unreal-mcp/executability/notes.txt"; }
c_deeplabel()  { grep -n 'Label' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
c_unmarked()   { sed -n '4p' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
c_nolabel()    { sed -n '4p' "$1/corpus/knowledge/unreal-mcp/executability/blueprints.md"; }
c_ptrpath()    { tail -1 "$1/corpus/knowledge/unreal-mcp/README.md"; }
c_refbad()     { echo "GATE_REF=not-a-clone"; }

: > "$ROOT/summary.txt"
echo "=== REV-GATE discrimination suite — $(date -Is) ==="
echo "gate sha256=$(sha256sum "$SUB/gate/run_gate.sh" | cut -d' ' -f1)"
echo "skeleton root: $CASES/<case>  (real subtree copy + symlinked siblings)"
echo

echo "--- ACCEPT CONTROLS (expect exit 0) ---"
one accept-clean              0 mut_clean     c_clean
one accept-sentinel-only      0 mut_sentinel  c_sentinel
one accept-prose-above-label  0 mut_prose     c_prose
one accept-valid-range        0 mut_validrange c_validrange

echo "--- ATTACK CLASSES (expect exit 1) ---"
one reject-byteflip            1 mut_byteflip    c_byteflip
one reject-strayfile           1 mut_strayfile   c_strayfile
one reject-delfile             1 mut_delfile     c_delfile
one reject-delcard             1 mut_delcard     c_delcard
one reject-relabel-census      1 mut_relabel     c_relabel
one reject-multilabel          1 mut_multilabel  c_multilabel
one reject-oor-pointer         1 mut_oor         c_oor
one reject-manifest-corrupt    1 mut_manicorrupt c_manicorrupt
one reject-manifest-drop-line  1 mut_manidrop    c_manidrop
one reject-card-rename         1 mut_renamecard  c_renamecard
one reject-symlink-in-upstream 1 mut_symlink     c_symlink
one reject-nested-card         1 mut_nested      c_nested
one reject-crlf-manifest       1 mut_crlf        c_crlf
one reject-per-seat-manifest   1 mut_seatman     c_seatman
one reject-oor-range           1 mut_oorrange    c_oorrange
one reject-wrong-pin-constant  1 mut_wrongpin    c_wrongpin
one reject-14th-card           1 mut_card14      c_card14
one reject-nonmd-card          1 mut_nonmd       c_nonmd
one reject-label-too-deep      1 mut_deeplabel   c_deeplabel
one reject-label-unmarked      1 mut_unmarked    c_unmarked
one reject-no-label            1 mut_nolabel     c_nolabel
one reject-missing-ptr-path    1 mut_ptrpath     c_ptrpath

echo "--- BLOCKED / ENV STATES ---"
one_env blocked-unreachable-repo  2 mut_clean  c_clean  'REPO=https://127.0.0.1:9/nope.git'
one_env reject-bad-gate-ref       1 mut_refbad c_refbad 'GATE_REF=/var/tmp/r107-rev-gate/work/not-a-clone'

echo
echo "=== SUMMARY (case expected_exit actual_exit) ==="
awk '{v=($2==$3)?"OK":"MISMATCH"; printf "%-30s exp=%s act=%s %s\n",$1,$2,$3,v}' "$ROOT/summary.txt"
printf 'cases=%s mismatches=%s\n' "$(wc -l < "$ROOT/summary.txt")" "$(awk '$2!=$3' "$ROOT/summary.txt" | wc -l)"
