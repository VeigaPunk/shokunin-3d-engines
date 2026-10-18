# SEAT-02 LESSON-CRITIC — r105 Unreal lifecycle

**Subject:** `corpus/lessons/r105-unreal-lifecycle.md`, SHA-256 `d089aae70c0fd251c6c2c9efc7a7c00e28a3c63d792d7a6fef3a92372c0349e6` (162 lines). Command: `sha256sum corpus/lessons/r105-unreal-lifecycle.md; wc -l corpus/lessons/r105-unreal-lifecycle.md` → digest above, `162 corpus/lessons/r105-unreal-lifecycle.md`. **Verdict: REVISE.** Source coverage and pointer resolution pass; one lane-fixture runtime result lacks the required label and evidence binding.

## Source and pointer audit

No source-less principle found: all 5 lifecycle stages, 6 recurring error-pattern classes, and 6 next-iteration hooks contain a source path. Command:

```sh
python3 - <<'PY'
from pathlib import Path
import re
s=Path('corpus/lessons/r105-unreal-lifecycle.md').read_text()
for name, section, pat in [
 ('LIFECYCLE',s,r'^### [1-5]\. '),
 ('ERROR_PATTERNS',s.split('## Recurring error-pattern classes',1)[1].split('## Next-iteration hooks',1)[0],r'^- \*\*'),
 ('HOOKS',s.split('## Next-iteration hooks',1)[1],r'^\d+\. ')]:
 starts=[m.start() for m in re.finditer(pat,section,re.M)]
 good=sum(bool(re.search(r'(?:reports/|corpus/|LOG\.md)',section[a:(starts[i+1] if i+1<len(starts) else len(section))])) for i,a in enumerate(starts))
 print(f'{name}_WITH_SOURCE={good}/{len(starts)}')
PY
```
Observed: `LIFECYCLE_WITH_SOURCE=5/5`, `ERROR_PATTERNS_WITH_SOURCE=6/6`, `HOOKS_WITH_SOURCE=6/6`.

Every explicit path/line citation resolves and its cited range is within the target file. Command:

```sh
python3 - <<'PY'
from pathlib import Path
import re
s=Path('corpus/lessons/r105-unreal-lifecycle.md').read_text()
pat=re.compile(r'(?P<path>(?:reports|corpus)/[A-Za-z0-9_./-]+\.(?:md|sh|py|gd|json|toml|uplugin)|LOG\.md):(?P<loc>\d+(?:-\d+)?(?:,\d+(?:-\d+)?)*)')
hits=list(pat.finditer(s)); missing=[]; bad=[]
for m in hits:
 p=Path(m['path'])
 if not p.is_file(): missing.append(m.group(0)); continue
 n=sum(1 for _ in p.open(errors='replace'))
 for item in m['loc'].split(','):
  a,*b=item.split('-'); lo=int(a); hi=int(b[0]) if b else lo
  if lo<1 or hi<lo or hi>n: bad.append((m.group(0),n))
print(f'LINE_CITATIONS={len(hits)} MISSING={len(missing)} OUT_OF_RANGE={len(bad)}')
for x in missing: print('MISSING',x)
for x in bad: print('OUT_OF_RANGE',x)
PY
```
Observed: `LINE_CITATIONS=40 MISSING=0 OUT_OF_RANGE=0`. The section-only `PROVENANCE.md §8` pointer also exists: `grep -n '^## 8\.' corpus/knowledge/unreal-mcp/PROVENANCE.md` → `340:## 8. Known out-of-pin upstream surface (recorded, not vendored)`. These checks establish path/range resolution, not semantic support of every cited sentence.

## Finding — runtime label required

The serial-spawn paragraph reports lane-fixture execution results: 21 serial launches / ~19 seconds, a 15× wall-time comparison, and a `phys3d_joints` row moving from timeout to **2.9 s PASS** with an unchanged marker. Command: `sed -n '127,135p' corpus/lessons/r105-unreal-lifecycle.md`; observed output includes those results and cites `reports/round-103/r103-report.md:269,484-499`, `reports/round-103/physics/adversary.md:58-69,139-156`, and `reports/round-104/r104-report.md:700-713`.

This is Godot/lane-fixture runtime evidence, not an Unreal runtime claim. Current `SKILL.md` row F (SHA-256 `ae79cab11bbd3ee1e2f0590780d2431c54d8635b8c448a13580eb1c6afc98608`) requires a lane-fixture runtime result to be labeled `verified-here` only with a saved bounded run, exact invocation, receipt path, scope/bound including timeout, and runner/fixture seed digests. Command: `sed -n '49p' SKILL.md`; observed row F states those requirements. The lesson's label sweep, `grep -nE 'verified-here|unproven-runtime|static-only' corpus/lessons/r105-unreal-lifecycle.md`, finds only line 159's `unproven-runtime` mention in the separate P/C hook. A second search for the specific result's receipt/command/digests, `grep -nE 'verdicts\.json|author-runs-final|seed digests|--only phys3d_joints_free_ops' corpus/lessons/r105-unreal-lifecycle.md`, returns `SPECIFIC_ROW_RECEIPT_COMMAND_SEED_HITS=0`. The paragraph does name a 20-second case bound, but does not label the claim or bind it in the lesson to a per-row receipt, exact invocation, and seed digests.

**Required correction:** label the fixture result `verified-here` and include its specific bounded receipt/command/scope/timeout/digests; otherwise remove or qualify the concrete runtime measurements. Do not label it `unproven-runtime`: it is a reported Godot fixture execution, not an Unreal behavior claim.

## Unreal-runtime boundary

The opening correctly says this lesson makes no new Unreal-runtime claim. Independent host check: `which UnrealEditor UnrealEditor-Cmd` returned “no UnrealEditor” and “no UnrealEditor-Cmd”; `which_rc=2`. No live-editor behavior is asserted by this review.
