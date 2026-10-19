# r106 · SEAT-69 OPERATOR-QUESTIONS — L0 list, P/C ruling carry

**Seat:** SEAT-69 · **Axes:** calibration (what is still operator-owned), coverage (which open questions are actually on the fleet L0 file).
**Write boundary:** this file only. Did not append `.ufo/l0-questions.md` (integrator owns L0 durability; this seat's declared path is the report). Did not edit `SKILL.md`, the P/C package, cards, fixtures, or protected roots. No commit, push, checkout, or reset. No Unreal runtime claim.

**Frame:** `2026-10-18T21:23:07Z` through `2026-10-18T21:33:28Z`. `git rev-parse HEAD` → `0cc3f4162f8c319f8d01a69a174fe939f36701bd` at both ends.

This list is a carry, not a ruling. The lane proceeds without an answer.

## 1. Commands this seat ran

```text
$ wc -l /home/vgpnk/Projects/shokunin/.ufo/l0-questions.md
49
$ sha256sum /home/vgpnk/Projects/shokunin/.ufo/l0-questions.md
60ccdc9e9a0a7179d97d82349a34e0cc53f1520c6f69c6db624f4f72beac51a6
$ grep -cE '^[a-z0-9-]+ \| round-' /home/vgpnk/Projects/shokunin/.ufo/l0-questions.md
45
$ grep -c '^game-dev-3d |' /home/vgpnk/Projects/shokunin/.ufo/l0-questions.md
1
$ grep -cEi '^\s*(answer|ruled|operator decision):' /home/vgpnk/Projects/shokunin/.ufo/l0-questions.md
0
$ stat -c '%n %s %y' /home/vgpnk/Projects/shokunin/.ufo/l0-questions.md
/home/vgpnk/Projects/shokunin/.ufo/l0-questions.md 38356 2026-10-18 17:14:10.592827730 -0300
```

The single `game-dev-3d` row is line 29 (relaunch counter / craft-dispatch contract, fleet round-1). No answer marker exists anywhere in the file. The r101 Epic/Lutris/image questions and the r105 P/C question are in `LOG.md` and `reports/round-105/operator-package.md`. They were never appended to the fleet L0 file.

```text
$ git diff --quiet HEAD -- reports/round-105/operator-package.md reports/round-105/pc \
    SKILL.md corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability
pc_source_tracked_diff_rc=0
$ sha256sum corpus/knowledge/unreal-mcp/README.md reports/round-105/operator-package.md \
    reports/round-105/pc/ruling-draft.md reports/round-105/pc/ledger.md reports/round-105/pc/distiller.md
c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721  README.md
83124766c85c14c381cb8c41c50fe5c15ce2ea2dfed37658e642c1e97a967d3a  operator-package.md
0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30  ruling-draft.md
84a47a1ff8879638140d89862824862c603d3399f0a597dc3f7fc40275c6e439  ledger.md
8e714525fa02b65e111e3e24809817eeea1a2f531ca155aa844923c24669c797  distiller.md
$ test -e corpus/knowledge/unreal-mcp/label-precedence.md; echo rc=$?
rc=1
$ grep -n 'P/C precedence ruling is still owed' SKILL.md
135:persists). **The P/C precedence ruling is still owed** and is not this file's to
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
```

Card-label scan (same five declaration patterns as the r105 ruling draft) printed 13 cards: `static-only=12`, `unproven-runtime=1` (`actors-scene.md`), `verified-here=0`, `missing=[]`. The six dissent files are `animation-controlrig`, `blueprints`, `editor-general`, `gameplay-gas`, `materials`, `meshes-textures`.

Install wall, this seat only (no pull, no clone, no install):

```text
$ curl -sI --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/UnrealEngine
404
$ curl -sI --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
200
$ command -v UnrealEditor; echo ue_rc=$?
ue_rc=1
$ ss -ltn | grep -c ':8000'
0
$ command -v docker
/usr/bin/docker
$ docker images --format '{{.Repository}}:{{.Tag}} {{.Size}}' | grep -i unreal
(no match; echo no_local_unreal_image)
$ pacman -Q lutris
error: package 'lutris' was not found
pacman_rc=1
```

Peer receipt read, not re-run: `reports/round-106/install-recheck.md` (SEAT-74, capture `2026-10-18T21:21:53Z`–`21:26:43Z`) records the same three walls — GitHub 404 for account `VeigaPunk`, SSH `Permission denied (publickey)`, Lutris in `extra` `0.5.22-3` but not installed. This seat did not run `gh`, `git ls-remote`, or SSH.

`python3` print of `reports/round-101/r101-report.md` lines 338–342 still contains the three r101 questions. `reports/round-105/operator-package.md` lines 28–34 still carry them and add no answer.

## 2. Already on the fleet L0 file — do not duplicate

| id | row | status |
|---|---|---|
| L0-0 | `game-dev-3d \| round-1` — relaunch counter and craft-dispatch contract (`l0-questions.md:29`) | OPEN. No answer marker. Work has continued under the explicit steer through r105. Do not re-append. |

Adjacent rows that name this lane but are not this lane's to refile: `aggregator | round-10` (corpus-review custody, line 43); `game-dev-2d | round-101` (side-round deferred because r104 was live, line 49). The deferral is stale relative to this tree (r104 and r105 have since landed). Answering it belongs to game-dev-2d, not this seat.

## 3. Ready to append — integrator only

Protocol shape is one line: `<lane> | round-<N> | <question>`. These four were recorded in lane `LOG.md` (r101 lines 1324–1325; r105 lines 1463–1464) and never reached the fleet file (`grep -c '^game-dev-3d |'` = 1). Append these; do not rewrite line 29.

```text
game-dev-3d | round-106 | CARRY r101 L0-1, never previously appended: link an Epic Games account to GitHub so EpicGames/UnrealEngine source becomes fetchable? r106 recheck: curl -sI https://github.com/EpicGames/UnrealEngine → 404; skills-plugin control → 200; UnrealEditor not on PATH; ss :8000 count 0. Static-only work continues. Evidence: reports/round-106/operator-questions.md.
game-dev-3d | round-106 | CARRY r101 L0-2: authorize pulling public wukakuki/unreal-engine:dev-slim-5.8.3 (size ~26.8 GB is the r101 recorded figure, not re-measured; contents unverified)? r106: docker is installed and no local image name matches unreal. Do not pull without this authorization.
game-dev-3d | round-106 | CARRY r101 L0-3: prefer the Lutris/Epic-launcher path instead of L0-1 or L0-2? r106: pacman -Q lutris → package not found (rc=1). Lane will not install Lutris or log into the Epic launcher.
game-dev-3d | round-106 | CARRY r105 P/C: which rule binds when corpus/knowledge/unreal-mcp/README.md and a card disagree on unproven-runtime — P (shared policy-first semantics) or C (card-first)? Package reports/round-105/pc/ and operator-package.md match HEAD (git diff --quiet rc=0). Census 12 static-only / 1 unproven-runtime / 0 verified-here; six cards still reject the label; README sha c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721; label-precedence.md absent; SKILL.md §4 still says the ruling is owed. Three reviews are REVISE and do not share the current distiller sha 8e714525fa02b65e111e3e24809817eeea1a2f531ca155aa844923c24669c797 (review-1 cited d337efd2…, review-2 cited 7c514008…, review-3 header cites 498fd04e…). Choose P, C, or hold. Do not apply either branch until you rule; a same-hash review set is still required before any byte-pinned edit.
```

## 4. P/C ruling carry — why it stays open

The question is label precedence, not a runtime claim. Binary `proven`/`unproven` is unchanged either way. No card is `verified-here`.

Current proposal artifacts disagree with each other, which is why this seat does not recommend applying a branch:

- `ruling-draft.md` (`0dc0340a…`) recommends policy-first and keeps the six cards `static-only` (census stays 12/1/0).
- `ledger.md` (`84a47a1…`, same hash review-2 recorded) keeps both P and C visible and requires three reviews of one proposal/diff hash.
- `distiller.md` is now `8e714525…`. Review-2's own text says it reviewed distiller `7c514008…`. Review-1's header reviews distiller `d337efd2…` and ruling `0dc0340a…`, verdict REVISE. Review-3's header reviews distiller `498fd04e…` and the same ruling hash, verdict REVISE. Review-2 has no frozen-hash match to the current distiller.

So the r105 close line "three independent strong reviews landed" is historically true as three REVISE reports, and false as a same-hash gate. `LOG.md:1456-1464` already routed the ruling to the operator and said nothing was applied. That routing is still correct. `SKILL.md:119-141` still says the ruling is owed and gives only an interim rule.

Acceptance that would close this item (not run; not passed): operator names P or C in the fleet L0 file or a dated ruling note; a later owner lands `corpus/knowledge/unreal-mcp/label-precedence.md` only after that; three non-author reviews cite one frozen proposal hash; gate census is re-measured rather than assumed. Until then, census stays 12/1/0 and no card label moves.

## 5. Do not re-ask

**Node v24 pin vs re-baseline** (L0 in `LOG.md` r102–r104, lines 1399–1400 and 1432–1433) is closed by measurement, not by an operator sentence. r105 found fnm `v24.21.0` present and mise `v26` shadowing PATH; pinned battery 350/350 with `seeds_unchanged=true` at `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`; default-env comparator remains 337/350. `PINNED-ENV.md` is the runbook. Re-appending it as open would contradict the admitted r105 law. An operator override of the two-state model would be a new decision; none is requested.

**Not L0** (lane-routed; do not paste into the fleet file from this list): fixture write-isolation; empty-jolt-cells class (SEAT-49/50 this round); row-F non-author replay precedent; SHONEN box 1 verifier. Those need a lane owner, not an Epic/account or label-precedence decision.

## 6. Blockers

None for producing the list. The four questions stay open by design. This seat did not append them: `.ufo/l0-questions.md` is outside the declared report path, and the protocol assigns L0 durability to the integrator. Parent/L1 should append the four lines in §3 and leave line 29 untouched.
