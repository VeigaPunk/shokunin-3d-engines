# r103 · SEAT-11 A1-ATTACK — range/comma pointer-tail blindness

Round r103 · lane `game-dev-3d-shokunin` · written 2026-10-18.
Seat scope: attack the CHECK 4 pointer sweep (fold-spec **A1**) on a `/tmp` copy of the repo
and decide whether the range/comma tail of a multi-endpoint pointer is validated. Every claim
carries the command that produced it and the verbatim output observed on this host.

- Repo under test: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD
  `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (worktree; gate dir is untracked).
- Scratch copy: `/tmp/r103-a1/repo` (`rsync -a --exclude .git --exclude node_modules`).
  No repository file was modified by this seat.
- **No Unreal runtime claim appears anywhere in this file.** The editor is not installed;
  live-MCP behaviour is unproven by construction. A green gate is never evidence of live-editor
  behaviour.

## 0. Verdict

**A1 was LIVE when this seat started, and is CLOSED as of the gate bytes frozen at
`0c1ca3e1…`.** Both accepted attacks (`:1-99999`, `:50-99999`) flip CHECK 4 to `STEP=FAIL` /
`exit 1`; the unmodified tree stays `UNRESOLVED=0` / `exit 0`.

**The third attack named in the seat brief — `upstream/README.md:20,15` — does NOT fail, and that
is CORRECT behaviour, not a residual.** Both endpoints of `:20,15` are `15` and `20`, both `≤ 112`
(`upstream/README.md` has 112 lines), so a per-endpoint range check passes it correctly. This seat
falsified the real comma-form defect instead: `:20,99999` and `:99999,20` are both **DETECTED**.
See §3 for the adjudication.

## 1. Method

The gate must not be edited to test it, and a plant inside `upstream/` would be caught by CHECK 1/2
before CHECK 4 is reached. The plant therefore goes into a prose file that is **(a)** inside the
swept set and **(b)** outside every manifest and the fresh-clone comparison:

```
$ cat corpus/knowledge/unreal-mcp/.manifest.d/*.sha256 | grep -oE '  .*' | sort -u
  upstream/.claude-plugin/plugin.json
  upstream/CODEOWNERS
  upstream/.gitignore
  upstream/hooks/hooks.json
  upstream/hooks/unreal-context.sh
  upstream/LICENSE
  upstream/README.md
  upstream/skills/create-toolset/SKILL.md
  upstream/skills/unreal-mcp/references/operations.md
  upstream/skills/unreal-mcp/references/setup.md
  upstream/skills/unreal-mcp/SKILL.md
  upstream/skills/unreal-skill/SKILL.md
```

Every manifest target is under `upstream/`; `upstream/README.md` has **112** lines. The subtree's
own `README.md` is untracked and in no manifest, so a plant there isolates CHECK 4 exactly —
checks 1–3 stay green and the only signal is CHECK 4. `upstream/README.md` was restored to its
pristine sha256 (`c79d8dd1d7c0c7bc…`, matching the pristine copy) after every run.

Both gate revisions were frozen into the copy by copying the *installed* `run_gate.sh` byte-for-byte
(never a rewrite), so each run below is against exactly the sha named.

## 2. Pre-A1 baseline — gate `412d1b84…` (A1 not yet landed): three attacks STILL PASS

The gate at this seat's start was sha
`412d1b84857233e8992b7da4888a61faae6832bffe0b7c70f962b21febf5ea96`, mtime `2026-10-18 15:15:52`.
Its CHECK 4 extraction regex matched only the **first** number of a range:

```
$ grep -n 'done < <(grep -ohE "upstream' corpus/knowledge/unreal-mcp/gate/run_gate.sh   # at 412d1b84
227:  done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+" "$f" | sort -u)
```

Regex truncation, demonstrated on each planted line:

```
--- input: A1a: `upstream/README.md:1-99999`
  gate regex (line 227)       -> upstream/README.md:1
  sweep regex (pointer-sweep) -> upstream/README.md:1-99999
--- input: A1b: `upstream/README.md:50-99999`
  gate regex (line 227)       -> upstream/README.md:50
  sweep regex (pointer-sweep) -> upstream/README.md:50-99999
--- input: A1c: `upstream/README.md:20,15`
  gate regex (line 227)       -> upstream/README.md:20
  sweep regex (pointer-sweep) -> upstream/README.md:20,15
```

Gate runs against the copy, `412d1b84…` (each block is the tail of that run's stdout; `RC=` is the
process exit code):

```
===== baseline-clean =====
CHECK 4 pointer-sweep
POINTERS=88 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
RC=0

===== A1a-range-1-99999   (plant: `upstream/README.md:1-99999`) =====
CHECK 4 pointer-sweep
POINTERS=89 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
RC=0

===== A1b-range-50-99999  (plant: `upstream/README.md:50-99999`) =====
CHECK 4 pointer-sweep
POINTERS=89 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
RC=0

===== A1c-reversed-20-15  (plant: `upstream/README.md:20,15`) =====
CHECK 4 pointer-sweep
POINTERS=89 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
RC=0

===== ctrl-single-oor     (plant: `upstream/README.md:99999`) =====
CHECK 4 pointer-sweep
LINE-OOR /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/README.md :: upstream/README.md:99999 (max 112)
POINTERS=89 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
RC=1
```

**Read: A1 is a live false-green pre-hardening.** All three multi-endpoint attacks read as `:1` /
`:50` / `:20`, all in range against `max=112`, so the gate printed `GATE RESULT: PASS` and exited 0
over a pointer whose tail (`99999`) does not exist. The single-endpoint control is caught, isolating
the blind spot to the multi-endpoint form — exactly as fold-spec §A1 predicted.

## 3. Post-A1 — gate `0c1ca3e1…` (A1 landed): attacks 1 and 2 DETECTED

The gate changed under this seat while it ran (A1 landed as part of a multi-seat hardening pass; A4
and the HARDENING-B `/tmp` fix also landed in the same window). The revision frozen for the decisive
run is sha
`0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e`, whose CHECK 4 now carries the
widened regex **and** a per-endpoint loop:

```
$ grep -n 'for ln in .*tr\|done < <(grep -ohE "upstream' corpus/knowledge/unreal-mcp/gate/run_gate.sh
304:  done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" "$f" | sort -u)
306:    for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
```

Gate runs against the copy, `0c1ca3e1…`:

```
===== 00-baseline =====
CHECK 4 pointer-sweep
POINTERS=95 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
RC=0

===== 01-A1a-1-99999   (plant: `upstream/README.md:1-99999`) =====
CHECK 4 pointer-sweep
LINE-OOR /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/README.md :: upstream/README.md:1-99999 (max 112)
POINTERS=97 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
RC=1

===== 02-A1b-50-99999  (plant: `upstream/README.md:50-99999`) =====
CHECK 4 pointer-sweep
LINE-OOR /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/README.md :: upstream/README.md:50-99999 (max 112)
POINTERS=97 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
RC=1

===== 03-A1c-20-15      (plant: `upstream/README.md:20,15`) =====
CHECK 4 pointer-sweep
POINTERS=97 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
RC=0

===== 04-ctrl-single     (plant: `upstream/README.md:99999`) =====
CHECK 4 pointer-sweep
LINE-OOR /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/README.md :: upstream/README.md:99999 (max 112)
POINTERS=96 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
RC=1

===== 05-comma-2nd-oor   (plant: `upstream/README.md:20,99999`) =====
CHECK 4 pointer-sweep
LINE-OOR /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/README.md :: upstream/README.md:20,99999 (max 112)
POINTERS=97 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
RC=1

===== 06-comma-1st-oor   (plant: `upstream/README.md:99999,20`) =====
CHECK 4 pointer-sweep
LINE-OOR /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/README.md :: upstream/README.md:99999,20 (max 112)
POINTERS=97 POINTER_STRINGS=42 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL
GATE RESULT: FAIL (checks failed: 1)
RC=1
```

**Read: A1 is closed.** The two accepted attacks and the single-endpoint control all fail-closed;
`05`/`06` prove the comma form is validated at *both* endpoints (first and second position).
`POINTER_STRINGS` stays `42` while `POINTERS` moves (`95→97`): the planted pointer is one *string*
whose *two* endpoints are each counted — the per-endpoint loop is doing real work, not merely
re-parsing.

### 3a. The `:20,15` adjudication — PASS is correct, the brief's expectation is wrong

The seat brief states `upstream/README.md:20,15` "must FAIL (post-A1)". It does not, and it should
not. The gate's rule is a **line-range** check (`ln -lt 1` → `LINE-ZERO`; `ln -gt n` → `LINE-OOR`),
not a monotonicity check: a `:a,b` pointer is a *list of lines*, and both listed lines are `15` and
`20`, both `≤ 112`. There is no reversed-range defect for the comma form to expose.

To make sure "PASS" here is not masking a real comma bug, this seat attacked the comma branch with an
out-of-range endpoint in each position (runs `05`, `06` above): **both DETECTED.** So `:20,15`
passes because it is genuinely in range, and `:a,b` is genuinely validated.

The reversed-range case only has a failure mode for the **hyphen** form, and it too is correctly a
PASS:

```
===== P3-reversed-hyphen (plant: `upstream/README.md:20-15`) =====
STEP=PASS
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

A `:20-15` pointer still *resolves* both endpoints `15` and `20`; it is in range. Rejecting it would
be a semantic decision (`a-b` requires `a ≤ b`) that the fold-spec does **not** ask for and the gate
does not implement. **This seat's ruling: no repair is owed for the reversed form.** If a future
round wants reversed ranges rejected, that is a new rule with its own acceptance, not a residue of
A1.

## 4. Real tree, current bytes (for the record)

The gate is untracked and was changing under this seat. The final installed revision observed is
`0c1ca3e1…`; run from the repo root it is green:

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e  corpus/knowledge/unreal-mcp/gate/run_gate.sh
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "RC=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
CHECK 4 pointer-sweep
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
RC=0
```

**Scope caveat (not a defect).** Absolute `POINTERS` values differ between the copy and the real
tree (`95` vs `98` baseline) because the `/tmp` copy froze the subtree at the moment of copy
(`15:31`) and the subtree's prose was edited by concurrent seats afterwards. The **decisive signal
is the per-attack flip** (`UNRESOLVED=0`/rc0 → `UNRESOLVED=1`/rc1 with a `LINE-OOR` naming the
planted tail), which is unaffected by the snapshot's absolute count.

## 5. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# fresh scratch copy (no repo file is touched)
rm -rf /tmp/r103-a1 && mkdir -p /tmp/r103-a1/repo
rsync -a --exclude .git --exclude node_modules ./ /tmp/r103-a1/repo/

# freeze the installed gate into the copy (test the bytes that ship, not a rewrite)
cp corpus/knowledge/unreal-mcp/gate/run_gate.sh /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/gate/run_gate.sh
sha256sum /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/gate/run_gate.sh    # 0c1ca3e1… now

R=/tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/README.md
cp "$R" /tmp/pristine.md

# accepted attack 1 — must be FAIL/exit 1 post-A1 (was PASS/exit 0 pre-A1)
printf '\nA1a: `upstream/README.md:1-99999`\n'  >> "$R"
bash /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
#   LINE-OOR … :: upstream/README.md:1-99999 (max 112) / UNRESOLVED=1 / rc=1
cp /tmp/pristine.md "$R"

# accepted attack 2
printf '\nA1b: `upstream/README.md:50-99999`\n' >> "$R"
bash /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"
#   LINE-OOR … :: upstream/README.md:50-99999 (max 112) / UNRESOLVED=1 / rc=1
cp /tmp/pristine.md "$R"

# brief's third attack — in range, correctly PASS (see §3a)
printf '\nA1c: `upstream/README.md:20,15`\n' >> "$R"
bash /tmp/r103-a1/repo/corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "rc=$?"   # rc=0, UNRESOLVED=0
cp /tmp/pristine.md "$R"

# comma form is validated at BOTH positions
printf '\nx: `upstream/README.md:20,99999`\n'  >> "$R"; bash …/run_gate.sh | grep LINE-OOR   # 2nd endpoint
cp /tmp/pristine.md "$R"
printf '\nx: `upstream/README.md:99999,20`\n'  >> "$R"; bash …/run_gate.sh | grep LINE-OOR   # 1st endpoint
cp /tmp/pristine.md "$R"
```

## 6. Limits

- This seat wrote **only** `reports/round-103/gate/a1-attack.md`. No source file, gate file,
  manifest, fixture, lesson, or other seat's report was touched; the plants live only under
  `/tmp/r103-a1`. `git status --porcelain` over `corpus/knowledge/unreal-mcp` is clean apart from
  peer seats' own concurrent edits.
- The gate is **untracked and was mutating under this seat**. The shas quoted (`412d1b84…` pre-A1,
  `0c1ca3e1…` post-A1) are the revisions actually frozen and run; a later revision may print
  different absolute counts. Re-read the file before acting on any number here.
- No finding depends on a `/tmp` path surviving.
- **No Unreal runtime claim is made anywhere in this file.** A green gate attests only that the
  vendored bytes match the pin and that these static checks ran on this host.
