# BEFORE — game-dev-3d round 108

Base commit: `7c4e5897d900ef8af0a826fa8c786e7cf32ea08f` (committed 2026-10-19T00:33:08-03:00, `r107-aborted: stray shards from the cancelled side-round swarm (wrong-cwd spawn; relocated, unvalidated, content not admitted)`); date of measurement: 2026-10-19. Worktree: `/home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/game-dev-3d-shokunin`. Every read targets the commit object `7c4e589`, never the working tree. Newlines inside outputs are encoded as `\n`.

## exists?

- `git cat-file -e 7c4e589:corpus/QUALITY.md; echo "QUALITY rc=$?"` → `fatal: path 'corpus/QUALITY.md' does not exist in '7c4e589'\nQUALITY rc=128`
- `git cat-file -e 7c4e589:corpus/SOURCES.md; echo "SOURCES rc=$?"` → `fatal: path 'corpus/SOURCES.md' does not exist in '7c4e589'\nSOURCES rc=128`
- `git cat-file -e 7c4e589:corpus/lessons/round-108.md; echo "ROUND108 rc=$?"` → `fatal: path 'corpus/lessons/round-108.md' does not exist in '7c4e589'\nROUND108 rc=128`

## SCORECARD.md

- `git show 7c4e589:SCORECARD.md | grep -cE '^\| (depth|coverage|calibration) \| unscored \|'` → `3`
- `git show 7c4e589:SCORECARD.md | grep -cE '^\| (depth|coverage|calibration) \| [0-9]+/10 \|'` → `0`
- `git show 7c4e589:SCORECARD.md | grep -c '^Saturation line:'` → `0` (`rc=1`)
- `git show 7c4e589:SCORECARD.md | grep -cE '^## Round [0-9]+ verdict'` → `30`
- `git show 7c4e589:SCORECARD.md | awk '/^## Capabilities$/{f=1;next} /^## Saturation$/{f=0} f && /^\|/ && !/^\| Capability \|/ && !/^\|[-| ]+\|$/{print; n++} END{print "COUNT=" n+0}'` → `| — none yet — | | | |\nCOUNT=1`
- `git show 7c4e589:SCORECARD.md | grep -c '<WORK>'` → `2`

## corpus/README.md

- `git show 7c4e589:corpus/README.md | grep -cE '^## (Coverage map|Frontier)'` → `0` (`rc=1`)

## PROVINCE.md

- `git show 7c4e589:PROVINCE.md | grep -cE '^## (Core|Frontier|Adjacent)'` → `0` (`rc=1`)

## corpus/fixtures/run_battery.py

- `git show 7c4e589:corpus/fixtures/run_battery.py | grep -cE '^\s+\("'` → `350`
- `git show 7c4e589:corpus/fixtures/run_battery.py | grep -cE '^\s+\("slope3d_'` → `4`
- `git rev-parse 7c4e589:corpus/fixtures/run_battery.py` → `dd2d9b74448afddb88dcf2da56008302eba8060d`
- `git show 7c4e589:corpus/fixtures/run_battery.py | sha256sum` → `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  -`

## corpus/knowledge

- `git ls-tree -r --name-only 7c4e589 -- corpus/knowledge | grep -cE '^corpus/knowledge/[^/]+\.md$'` → `3`
- `git ls-tree -r --name-only 7c4e589 -- corpus/knowledge | grep -E '^corpus/knowledge/[^/]+\.md$' | while read -r f; do git show "7c4e589:$f" | sed -n '1p'; done | grep -c '^source:'` → `0`
- `git ls-tree -r --name-only 7c4e589 -- corpus/knowledge | grep -E '^corpus/knowledge/[^/]+\.md$' | while read -r f; do printf '%s: ' "$f"; git show "7c4e589:$f" | sed -n '1p'; done` → `corpus/knowledge/engines.md: # Engine census — maintained by the lane\ncorpus/knowledge/rea.md: # REA tooling reference (static inspection only)\ncorpus/knowledge/seed.md: # Seed provenance`

## corpus/lessons

- `git ls-tree -r --name-only 7c4e589 -- corpus/lessons | grep -cE '^corpus/lessons/[^/]+\.md$'` → `92`
- `git ls-tree -r --name-only 7c4e589 -- corpus/lessons | grep -E '^corpus/lessons/[^/]+\.md$' | while read -r f; do n=$(git show "7c4e589:$f" | grep -c '^## Gate'); if [ "$n" -gt 0 ]; then echo "$f"; fi; done | wc -l` → `0`
- `git ls-tree -r --name-only 7c4e589 -- corpus/lessons | grep -cE '^corpus/lessons/round-[^/]+\.md$'` → `0`

## SKILL.md

- `git show 7c4e589:SKILL.md | grep -c 'SOURCES.md'` → `0` (`rc=1`)
- `git show 7c4e589:SKILL.md | grep -c 'QUALITY.md'` → `0` (`rc=1`)

## git grep

- `git grep -c '\.shokunin/game-dev-3d' 7c4e589 -- PROVINCE.md` → `7c4e589:PROVINCE.md:2` (`rc=0`)
