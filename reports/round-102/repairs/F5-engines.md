# F5 — repair: `engines.md` three.js evidence command made re-runnable from a clean tree

- Seat: SEAT-26 ENGINES-AUTHOR
- Round: r102
- Owned path written: `corpus/knowledge/engines.md` (only). This report is the second file.
- Repo HEAD at work: `2c99b7b8155841617d844c609813afcba77aa207`
- Working dir: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`
- Date: 2026-10-18
- Before-capture this repair answers: `reports/round-102/before/F5-engines-threejs.md` (SEAT-04), verdict **CONFIRMED**.
- Discipline: the `→ 3/3` in the evidence cell is a historical factual claim tied to an r6 work commit and was **not**
  rewritten; the defective part was a **missing precondition in a mechanical evidence command**, so the fix is an
  in-place command-conformance edit. No dated correction note is required. The r101 byte-pinned subtree
  `corpus/knowledge/unreal-mcp/` was read-only to this seat — no file under it was modified.

## 1. Defect restated

`corpus/knowledge/engines.md:11` (old sha256 `b20e5a9b3b964bf5d8bd8fdba6f0349cf1c9fc30d949d8432e10a111a85cd06e`)
presented the bare invocation

```
node corpus/fixtures/three/run_cases.mjs
```

as its evidence, with no install step. `corpus/fixtures/three/node_modules/` is gitignored
(`corpus/fixtures/three/.gitignore:1: node_modules/`), so on the committed tree the package is absent and every
arm of the runner dies with `ERR_MODULE_NOT_FOUND`.

## 2. BEFORE (fail) — pristine export of HEAD, run from that tree's root

Method: read-only `git archive`, no mutation of the lane working tree.

```
$ rm -rf /tmp/f5off && mkdir -p /tmp/f5off
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ git archive HEAD corpus/fixtures/three | tar -x -C /tmp/f5off
$ cd /tmp/f5off
$ node corpus/fixtures/three/run_cases.mjs
FAIL positive: exit=1 expected=0
FAIL negative_wrong_order: exit=1 expected=2
FAIL mutation: exit=1 expected=1
FAIL three battery: 3/3, seeds_unchanged=true
exit=1
```

Observed: `before-exit=1`. This reproduces the before-capture exactly (same four `FAIL` lines, empty stderr).

## 3. AFTER (pass) — the repaired evidence cell, same pristine tree

The repair chosen is option (i) from the before-capture §5: state the install step **in** the evidence cell so the
cited command is genuinely re-runnable. The cell now reads, verbatim (new sha256
`d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`):

> `npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs` → 3/3, `seeds_unchanged=true`, exit 0 …

Run from the repository root on the pristine export:

```
$ cd /tmp/f5off
$ npm ci --offline --prefix corpus/fixtures/three
added 1 package, and audited 2 packages in 239ms
found 0 vulnerabilities
npm-exit=0
$ node corpus/fixtures/three/run_cases.mjs
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
after-exit=0
```

Observed: `after-exit=0`, 3/3 PASS, `seeds_unchanged=true`.

The exact cell command was then run as written (online form, no `--offline`) from the lane repo root:

```
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ npm ci --prefix corpus/fixtures/three && node corpus/fixtures/three/run_cases.mjs
added 1 package, and audited 2 packages in 392ms
found 0 vulnerabilities
PASS positive: exit=0 expected=0
PASS negative_wrong_order: exit=2 expected=2
PASS mutation: exit=1 expected=1
PASS three battery: 3/3, seeds_unchanged=true
exit=0
```

Observed: **exit=0**. The counting command in the row runs green.

Notes cell addition records the precondition explicitly: the dir is gitignored, the bare `node …` exits 1 on a fresh
`git archive HEAD corpus/fixtures/three` tree, and `npm ci --prefix` restores it from the committed lockfile.
`installed` / `executable headless` are unchanged (`yes`-family columns untouched; still `partial` for headless).

Seed digests unchanged by this repair (verify against before-capture §6):

| file | sha256 |
|---|---|
| `corpus/fixtures/three/run_cases.mjs` | `97eca1b2e26db106e5ab7efe71767b533d99abdc1ee9ff80156ac402e11458e5` |
| `corpus/fixtures/three/package-lock.json` | `1a8e6ee2341eb4e3bcf764ad0c14973c89afee0a613bb14d41ea2fa5851c19b8` |

Toolchain at repair: `node v26.12.0`. The row's parenthetical "Node v26.11.1" is a mint-time host fact and was
left untouched (not this defect).

## 4. Second change in the same file — Unreal row evidence class (connector IP-1)

Per connector IP-1 (`reports/round-101/r101-connector.md:150-190`), the Unreal row's `evidence` cell cited only one
artifact class: r22's lane-authored `.uplugin` sample. It now names **two categorically different static classes**:

- **(a)** r22 self-authored `corpus/artifacts/unreal-r22/` sample + non-author review — lane-authored, so it can
  only prove the lane can write a descriptor its own checker accepts;
- **(b)** r101 third-party pinned tree `corpus/knowledge/unreal-mcp/` — Epic
  `unreal-engine-skills-for-claude-code-plugin` @ `a6aa73ad`, MIT, 12/12 tracked files byte-identical, 13
  `executability/` cards (12 `static-only` / 1 `unproven-runtime` / 0 `verified-here`) — someone else's bytes at a
  pinned upstream commit, carrying an authority (a) structurally lacks.

The row's three-state columns are **not** moved toward `yes` on any column: Unreal Editor is still not installed
and the engine install is still operator-gated. Label vocabulary follows the lane's `verified-here` |
`static-only` | `unproven-runtime` set; the row states explicitly that no runtime claim on it is
`verified-here`.

### Evidence for the Unreal-row counts, run by this seat

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | tail -3
upstream/skills/unreal-mcp/references/setup.md: OK
upstream/skills/unreal-mcp/SKILL.md: OK
upstream/skills/unreal-skill/SKILL.md: OK
rc=0
$ wc -l .manifest.d/audit-reference.sha256
18 .manifest.d/audit-reference.sha256   # 6 header lines + 12 file lines
$ find upstream -type f | wc -l
12
$ ls corpus/knowledge/unreal-mcp/executability/*.md | wc -l
13
$ for f in corpus/knowledge/unreal-mcp/executability/*.md; do grep -m1 -oE "`(static-only|unproven-runtime|verified-here)`" "$f"; done | sort | uniq -c
     12 `static-only`
      1 `unproven-runtime`
```

Observed: manifest `rc=0` over 12/12 tracked files; 13 cards; 12 `static-only` / 1 `unproven-runtime` / 0
`verified-here` (the single `unproven-runtime` card is `actors-scene.md`). The card-level label of one card is
`unproven-runtime` because that surface has an identified runtime path that went untested; the row-level evidence
class remains `static-only` throughout, which is why the cell's leading label is `static-only` and not
`unproven-runtime`.

## 5. Boundary notes

- **No Unreal runtime claim** is made anywhere in this report or in the edited file. Unreal Editor is not installed;
  every live-editor statement is `unproven by construction`.
- The r101 subtree was read (`sha256sum -c`, `grep`, `ls`) and not written. `git status --porcelain
  corpus/knowledge/unreal-mcp` attributable to this seat is empty.
- Files written by this seat: `corpus/knowledge/engines.md` and this report. No other path.
- Not fixed here, reported for routing: `corpus/fixtures/three/README.md:7-8` and `corpus/artifacts/glb-r12/README.md:8`
  cite the same command through a `.shokunin/game-dev-3d/` prefix (F1's subject) and carry the same missing
  install precondition.
