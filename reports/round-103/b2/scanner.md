# SEAT-21 B2-SCANNER — authoritative enumeration of the `shokunin/game-dev-3d` string

**Seat:** SEAT-21 · round 103 · lane `game-dev-3d-shokunin`
**Written:** 2026-10-18, from `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
**HEAD at capture:** `c85a816` (r102 report-last; work `c6f655d`). Working tree carried 6 peer-seat
modifications plus untracked `reports/round-103/`; see §7 for the mid-round collision this caused.
**Evidence rule:** every number below is from a command run in this seat; unrun = not claimed.

---

## 1. The enumeration, and why its raw count is not the defect count

Seat-verbatim command:

```
$ grep -rn 'shokunin/game-dev-3d' corpus/ reports/ --include='*.md' --include='*.py' --include='*.mjs' --include='*.sh' | wc -l
879            # 2026-10-18T~15:31Z
1036           # 2026-10-18T18:36:49Z   ← growth is peers' own new r103 docs, not new defects
```

**The single most important structural finding: this pattern matches two unrelated strings, and
only one of them is a defect.**

| Family | String | Lines (of 879) | Status |
|---|---|---|---|
| **D — dead** | `.shokunin/game-dev-3d/` (relative, leading dot) | **520** | the defect surface |
| **L — live** | `shokunin/game-dev-3d-shokunin` (canonical absolute/`~` path) | **286** | correct today; never a defect |
| **O — other** | bare `shokunin/game-dev-3d` (substring of L, or `craft/game-dev-3d`, or prose) | 83 | context-dependent |

```
$ grep -c '\.shokunin/game-dev-3d/' /tmp/b2_hits.txt          → 520
$ grep -c 'shokunin/game-dev-3d-shokunin' /tmp/b2_hits.txt    → 286
$ grep -v '\.shokunin/game-dev-3d/' /tmp/b2_hits.txt | grep -vc 'shokunin/game-dev-3d-shokunin'  → 83
```

A census that quotes the 879 (or 1036) figure as "occurrences of the bad path" is wrong by ~1.7×.
Any acceptance test must anchor on the **D** family — e.g. the root-anchored
`grep -cE '(^|[^.])\.shokunin/game-dev-3d/'` form — not the bare pattern.

### Corpus-only census (the actionable universe; `reports/**` is history, not shipped surface)

```
$ grep -rl '\.shokunin/game-dev-3d/' corpus/ --include='*.md' --include='*.py' --include='*.mjs' --include='*.sh' | wc -l
81 files
$ grep -rc … | awk -F: '{s+=$2} END{print s}'
328 lines
```

All 81 files are `corpus/lessons/**` (80 files) plus one fixture source, §4. Excluding
`corpus/lessons/` leaves **4 files**, listed in §4.

---

## 2. Classification of all 879 hits

| Class | Rule | Count |
|---|---|---|
| **A** | the dead path sits inside a command that would fail (command position) | 346 |
| **B** | prose / narrative mention, not a runnable invocation | 458 |
| **C** | historical quote inside a dated correction/repair note (keep by discipline) | 75 |

Class A splits by surface, and the split is the whole finding:

| A-subclass | Lines | Disposition |
|---|---|---|
| **A1** — runnable command in a **live, shipped** surface | 29 | 22 repaired this round, 7 kept (§3, §4) |
| **A2** — runnable command inside a **dated historical record** (`corpus/lessons/**`, `reports/round-{69..102}/**`) | 317 | **keep** — rewriting would falsify the record |

Class C = 75 lines, in `reports/round-102/{repairs,before}/**` and equivalent: these quote the dead
prefix *as the defect being corrected*. Removing them would erase the correction. **Keep, all.**

---

## 3. Class A1 — the live-surface runnable hits, each run

### 3.1 The four commands named in the seat brief (repo root as cwd)

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
python3: can't open file '/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/.shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py': [Errno 2] No such file or directory
                                                                                              exit=2

$ uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py
… can't open file '…/.shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py': [Errno 2] …   exit=2

$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs
Error: Cannot find module '…/.shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs'              exit=1

$ python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py
… can't open file '…/.shokunin/game-dev-3d/corpus/fixtures/run_battery.py': [Errno 2] …            exit=2
```

All four reproduce the brief's expected exits **2 / 2 / 1 / 2** exactly.

### 3.2 Every distinct A1 command in the tree — 16 total, all non-zero

```
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py                     exit=2
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py                             exit=2
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs                           exit=1
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs --receipt …               exit=1
node .shokunin/game-dev-3d/corpus/fixtures/three/run_camera_cases.mjs                    exit=1
node .shokunin/game-dev-3d/corpus/fixtures/three/run_ortho_cases.mjs                     exit=1
node .shokunin/game-dev-3d/corpus/fixtures/three/run_ray_cases.mjs                       exit=1
node .shokunin/game-dev-3d/corpus/fixtures/three/run_order_cases.mjs                     exit=1
node .shokunin/game-dev-3d/corpus/fixtures/three/run_layer_cases.mjs                     exit=1
node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs --wrong-order           exit=1
node .shokunin/game-dev-3d/corpus/fixtures/three/scene_graph.mjs --mutate-offset         exit=1
uv run --no-project --with pyyaml python …/unity-r19/verify_scene.py                     exit=2
uv run --no-project --with pyyaml python …/verify_scene.py …Hierarchy.broken-reference.unity --expect-reject  exit=2
npm ci --prefix .shokunin/game-dev-3d/corpus/fixtures/three                               exit=1  (EUSAGE)
npm test --prefix .shokunin/game-dev-3d/corpus/fixtures/three                             exit=254 (ENOENT)
```

Every one fails with a missing-file/module error. `npm test`'s 254 is npm's own ENOENT code, not
the 1/2 the other tools use — worth knowing when writing an acceptance test.

### 3.3 The finding that changes the repair rule: the root is **cwd-conditional**, not dead

```
$ cd /home/vgpnk/Projects/prymeagnt/game-dev-3d && python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py
PASS Godot GLB import: valid/tolerated load, bad magic diagnosed and not loaded; receipt=…      exit=0
```

```
$ readlink -f /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d
/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
```

```
cwd = canonical repo root      → dead-prefix command  exit=2 / 2 / 1     (three commands, §3.1)
cwd = predecessor worktree     → same command         exit=0 / 0 / 0     (same three commands)
cwd = /tmp                     → same command         exit=2
cwd = canonical repo root      → repo-relative form   exit=0 / 0 / 0     (controls)
```

The predecessor worktree still hosts a **live symlink** at `.shokunin/game-dev-3d` pointing at the
canonical repo. So the prefix is not a phantom path — it is a **path that only resolves from one
cwd**. Consequences:

1. Every r69–r78 report that says "canonical reached via its `.shokunin/game-dev-3d` symlink" is
   **accurate and must not be "fixed"** — those seats genuinely worked in that worktree.
2. The r22 fix and this round's three-README fix are correct because a README says *"From the
   repository root"* — the documented cwd is the one where the prefix dies. A seat that "fixed" a
   command block that a worktree-based reader runs would have introduced a regression.
3. The acceptance test must therefore be **cwd-qualified**: `cd <canonical root>` first, or the
   test passes or fails depending on where the runner stands.

---

## 4. The seven surviving runnable hits, and why they must stay

After the three READMEs were repaired (§7), exactly **7 runnable-context lines remain outside
`corpus/lessons/**` and `reports/**`**, in **4 fixture files**:

```
corpus/fixtures/three/scene_graph.mjs:2-5   (4 lines)  // npm ci / npm test / node …--wrong-order / --mutate-offset
corpus/fixtures/crash_exit3d.gd:2           (1)        # python3 …/run_battery.py --probe-crash-exit
corpus/fixtures/timeout_tree3d.gd:2         (1)        # python3 …/run_battery.py --probe-tree-timeout
corpus/fixtures/stream_attribution3d.gd:2   (1)        # python3 …/run_battery.py --probe-stream-attribution
```

These are **comments inside byte-pinned fixture seeds**. Verified independently by this seat:

```
$ sha256sum corpus/fixtures/three/scene_graph.mjs corpus/fixtures/crash_exit3d.gd \
             corpus/fixtures/timeout_tree3d.gd corpus/fixtures/stream_attribution3d.gd
e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af  corpus/fixtures/three/scene_graph.mjs
efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99  corpus/fixtures/crash_exit3d.gd
403a2e3e5f4a49fda283a147fd51577eda18a10a2d791cebb60be8d9d0712210  corpus/fixtures/timeout_tree3d.gd
ab923ceeac3797f1d0fabfd6695238f88529ef69fb9f452c45ec61b76eefa796  corpus/fixtures/stream_attribution3d.gd

$ git grep -l e4bb0a136391cb42baafcbab4905e1c4004d316cec44f5f67519f37a2ab075af HEAD | wc -l   → 6
$ git grep -l efee43b93070f838d4174cfceacec98b056fb34c60525f0479e8e6e1e4c38f99 HEAD | wc -l   → 1
```

`scene_graph.mjs`'s digest is cited in **6** landed files; editing one comment byte makes all six
citations stop resolving. **Disposition: KEEP all 7 lines / 4 files.** SEAT-21's independent
re-derivation agrees with the peer ruling in `reports/round-103/b2/postgrep.md` §K4, reached
separately. The executable contract for these probes is `run_battery.py`'s own invocation and the
(repaired) README, not a source comment.

---

## 5. Class A2 / B / C — the historical surface

317 A2 lines live in `corpus/lessons/**` and `reports/round-{69..102}/**`; 458 B lines are prose;
75 C lines are quotes inside correction notes. **All keep.** These are dated records of commands
that genuinely ran, in a cwd where they genuinely resolved (§3.3), or descriptions of the defect
itself. The lane's discipline — dated correction notes, never silent rewrites of historical claims
— forbids rewriting them, and a rewrite would also destroy the evidence trail that makes this
round's fix auditable.

---

## 6. Investigation (not repair): battery row `phys3d_joints_free_ops`

Receipt: `corpus/live/runs/20261018T181301123479Z/verdicts.json` (851,550 B).
Census: `336 PASS + 14 FAIL = 350` — **confirmed by parsing the JSON**, not by reading the summary.

```
$ python3 -c "…Counter(x['verdict'] for x in d['results'])…"
n=350  {'PASS': 336, 'FAIL': 14}
```

The 14 FAILs are **two unrelated mechanisms**, and only one is named in the brief:

| Mechanism | Rows | Cause |
|---|---|---|
| Wall-clock overrun of the 20 s case bound | `phys3d_joints_free_ops` | §6.1 |
| Expected-marker drift: `node=v24.21.0` recorded, `node=v26.12.0` observed | 13 × `r94_cannon_*` | environment drift, not a fixture defect |

### 6.1 `phys3d_joints_free_ops` — a boundary overrun, not a hang

```
$ python3 -c "…x=results['phys3d_joints_free_ops']…"
elapsed 20.008  flags ['--arm=free_ops']  expected_exit 0  actual_exit None
reasons ['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)', 'exact stdout marker missing']
stdout lines: 1   →  "Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf …"
```

The row is killed by the battery's own bound before the fixture prints anything. Running the arm
directly, with **no battery bound**:

```
$ timeout 300 /usr/bin/godot --headless --path corpus/fixtures --script res://phys3d_joints.gd -- --arm=free_ops
… PASS phys3d_joints free_ops … DONE case=detachb_free engine=Dummy,e=0,w=0}
EXIT=0  WALL=24s        # run 1: exit 1 at 21 s;  run 2: exit 0 at 24 s
```

**The fixture completes and exits 0. It is not hung.** The bound that kills it is the battery's:
`run_battery.py:36` → `CASE_TIMEOUT_SECONDS = 20`. The fixture's own child bound is *also*
`BOUND_S := 20` (`corpus/fixtures/phys3d_joints.gd:29`), so this row sits exactly on a doubled
20 s edge and the two bounds race.

Reproduced deterministically, 3× standalone plus 1× under 4-way CPU load — all `TIMEOUT` at ≈20.0 s:

```
$ python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops
FAIL phys3d_joints_free_ops: exit=None expected=0 reasons=['TIMEOUT after 20 seconds', …]
real 0m20.163s
```

History: the row failed in **every** run of the day — 21 receipts from `20261018T174423Z` to
`20261018T183343Z`, every one at `elapsed ≈ 20.02 s`:

```
20261018T174423377345Z FAIL 20.023   20261018T180352495594Z FAIL 20.023
20261018T174432492194Z FAIL 20.022   20261018T181301123479Z FAIL 20.008   ← the brief's receipt
… (21 total, all FAIL, none between 17.8 and 20.0) …
```

**Reading:** r93 recorded this row as a *load-dependent flake* (`r93-baseline2.md:137`: "PASS
17.802 s" vs "FAIL 20.053 s", "load-dependent", "documented timeout pair"). Today's evidence
**narrows that**: across 21 consecutive runs it never once landed below the bound, and the direct
run takes 21–24 s. The margin is now negative on this host, so it is a **hard boundary row**, not a
flake — r93's characterisation is superseded for this host. Its neighbours behave normally
(`free_pair` 12.08 s, `twopin` 9.40 s, everything else < 7.2 s).

**Disposition: INVESTIGATE ONLY, as instructed — no repair.** The repair is a lane decision with
three live options (raise `CASE_TIMEOUT_SECONDS`, shard the `free_ops` arm, or accept the row as a
declared boundary case); this seat takes no position.

### 6.2 The other 13 FAILs — a different defect, flagged not claimed

`r94_cannon_{det,det2,varstep,bailout,nan,sync,material,friction,parity,parity2,modes,order,backends}`
all have `expected_exit 0`, `actual_exit 0`, and fail **only** `exact stdout marker missing`:

```
expected marker:  PASS r94_cannon det node=v24.21.0 det_base{rc=0,m=M0 …
observed stdout:  PASS r94_cannon det node=v26.12.0 det_base{rc=0,m=M0 …
                                       ^^^^^^^^ host Node version moved
```

The payload after `node=` is byte-identical; only the interpolated `process.version` moved
(v24.21.0 → v26.12.0). So 13 of the 14 FAILs are a **host-toolchain drift** recorded into a pinned
marker, not a physics defect. Outside this seat's ownership — reported, not repaired. Together with
§6.1 this means the receipt's `336/350` understates fixture health: the honest reading is **349/350
on the fixtures' own logic**, with 1 boundary row.

---

## 7. Mid-round collision (disclosure)

The brief asked for a repair of the three READMEs' dead roots. **Between this seat's first
enumeration and its write, peer seats repaired all three**:

```
$ for f in corpus/fixtures/three/README.md corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md; do
    echo -n "$f dead-prefix="; grep -c '\.shokunin/game-dev-3d/' "$f"; done
corpus/fixtures/three/README.md        dead-prefix=0
corpus/artifacts/glb-r12/README.md     dead-prefix=0
corpus/artifacts/unity-r19/README.md   dead-prefix=0
```

`git status --porcelain` at write time shows `M` on exactly those three plus three peer files
(`corpus/knowledge/unreal-mcp/{adaptation-kimi.md,gate/README.md,gate/run_gate.sh}`). This seat
therefore **wrote no repair** — doing so would have collided with in-flight peer work. The
before-state (22 dead-prefix lines across the three files: 17 / 3 / 2) and the four failing exit
codes in §3.1 are recorded here as the **before-evidence** for those peers' verification.
`reports/round-103/b2/{repair-glb,verify-unity,postgrep,adversary}.md` are the peers' own docs.

This seat's **own byproduct was cleaned up**: the direct `godot --path corpus/fixtures` runs in §6.1
made the fixture write 21 `corpus/fixtures/r90bt_free_ops_*/` scratch directories. They were
removed (`rm -rf corpus/fixtures/r90bt_*`; `ls -d corpus/fixtures/r90bt_*` → none), and
`git status` confirms only peer-seat modifications remain. Flagged because it shows the fixture is
not scratch-isolated when run outside the battery's scratch-copy harness.

---

## 8. Reproduction

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# enumeration + family split
grep -rn 'shokunin/game-dev-3d' corpus/ reports/ --include='*.md' --include='*.py' --include='*.mjs' --include='*.sh' | wc -l   # 879 @15:31Z / 1036 @18:36Z
grep -c '\.shokunin/game-dev-3d/' /tmp/b2_hits.txt                     # 520  dead
grep -c 'shokunin/game-dev-3d-shokunin' /tmp/b2_hits.txt               # 286  live

# class A1 exit codes (all non-zero)
python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py ; echo $?                        # 2
uv run --no-project --with pyyaml python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py ; echo $?   # 2
node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs ; echo $?                              # 1
python3 .shokunin/game-dev-3d/corpus/fixtures/run_battery.py ; echo $?                                # 2

# cwd-conditional proof
( cd /home/vgpnk/Projects/prymeagnt/game-dev-3d && python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py ; echo $? )  # 0
readlink -f /home/vgpnk/Projects/prymeagnt/game-dev-3d/.shokunin/game-dev-3d                            # → canonical repo

# phys3d boundary row
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops                                    # FAIL, real 20.16s
timeout 300 /usr/bin/godot --headless --path corpus/fixtures --script res://phys3d_joints.gd -- --arm=free_ops ; echo $?   # 0, 24s
```

## 9. Residual / open

- **`reports/**` was scanned but not classified file-by-file** — 317 A2 + most B/C lines live there.
  They are dated history and out of repair scope, but a future seat wanting a per-file ledger will
  need to enumerate them; the raw hit list is `/tmp/b2_hits.txt` (ephemeral).
- **`CASE_TIMEOUT_SECONDS` repair is undecided** (§6.1) — lane call, not a seat call.
- **13 `r94_cannon_*` marker-drift FAILs are unowned** (§6.2).
- The census is a **moving target** (879 → 1036 in ~3 h) because peers write `reports/round-103/**`
  while the scan runs. Any acceptance test must be scoped to `corpus/`, or pin a HEAD.
