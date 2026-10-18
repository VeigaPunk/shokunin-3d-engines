# r105 · SEAT-54 LESSON-BLEED

**Subject:** `corpus/lessons/r105-unreal-lifecycle.md` — SHA-256 `dd9b9ac064511b9cbc95cd4ebed6d62b995606dd3db069453f0ff653afefe758`, 155 lines. **Verdict: FAIL (semantic harness/evidence-audit bleed).** The lesson has no literal lore, 2D, or harness/audit identifier hits, but its substance repeatedly teaches gate and evidence-harness auditing, which `PROVINCE.md` explicitly refuses. No lesson bytes were changed by this seat.

**Lexical scan [O]:**

```text
$ python3 - <<'PY'
import re
from pathlib import Path
p = Path('corpus/lessons/r105-unreal-lifecycle.md')
text = p.read_text()
checks = {
    'lore/narrative/canon': r'\b(lore|narrative|canon|fictional)\b',
    '2D': r'\b2D\b',
    'harness/audit identifiers': r'\b(harness|harness-integrity|gate-evidence|rlm-dispatch)\b',
}
for label, pattern in checks.items():
    hits = [(n, line.strip()) for n, line in enumerate(text.splitlines(), 1) if re.search(pattern, line, re.I)]
    print(f'{label}: {len(hits)}')
PY
lore/narrative/canon: 0
2D: 0
harness/audit identifiers: 0
```

**Boundary comparison [O]:**

```text
$ python3 - <<'PY'
from pathlib import Path
selected = {'PROVINCE.md': [34, 35], 'corpus/lessons/r105-unreal-lifecycle.md': [38, 49, 51, 53, 58, 60, 78, 82, 83, 97, 103, 110, 112, 119, 120, 142, 149]}
for name, numbers in selected.items():
    lines = Path(name).read_text().splitlines()
    for n in numbers:
        print(f'{name}:{n}: {lines[n - 1]}')
PY
PROVINCE.md:34: asset rights clearance (art-east-asian-design); harness/evidence auditing
PROVINCE.md:35: (harness-integrity, gate-evidence, rlm-dispatch); narrative canon (lore
corpus/lessons/r105-unreal-lifecycle.md:38: ### 3. Put the gate in the corpus and run it from outside its directory (r102)
corpus/lessons/r105-unreal-lifecycle.md:49: ### 4. Harden against attacks, then bind the verdict to final bytes (r102–r103)
corpus/lessons/r105-unreal-lifecycle.md:51: A gate is not trustworthy merely because its positive path passes. r102's first
corpus/lessons/r105-unreal-lifecycle.md:53: close adopted hardened checks, and the report records **11/11 attacks detected**
corpus/lessons/r105-unreal-lifecycle.md:58: Every attack or review verdict must name the exact target bytes. SEAT-14's r103
corpus/lessons/r105-unreal-lifecycle.md:60: gate was a different target, and the L1 re-ran the attack against the installed
corpus/lessons/r105-unreal-lifecycle.md:78: Repairs also have to change behavior, not only the message. r104's workdir fix
corpus/lessons/r105-unreal-lifecycle.md:82: documented `REPO` override that the code had not implemented; the L1 wired it
corpus/lessons/r105-unreal-lifecycle.md:83: and tested both directions: a bad URL produced BLOCKED/exit 2, while the clean
corpus/lessons/r105-unreal-lifecycle.md:97: - **Scanner-relative datum — earned r102.** `POINTERS=N` is a scanner's output,
corpus/lessons/r105-unreal-lifecycle.md:103: - **Stale-intermediate falsification — earned r103, reinforced r104.** A failing
corpus/lessons/r105-unreal-lifecycle.md:110: - **Temp-dir-dependent gate — earned r103, diagnosed and repaired r104.** A
corpus/lessons/r105-unreal-lifecycle.md:112:   space; the gate could misreport a local resource failure as network trouble
corpus/lessons/r105-unreal-lifecycle.md:119: - **Documented-but-unimplemented override — earned r104.** A knob in the README
corpus/lessons/r105-unreal-lifecycle.md:120:   is not implemented until the executable consumes it and its branch is tested.
corpus/lessons/r105-unreal-lifecycle.md:142: 2. Keep the gate in-repo. After each change, run positive and adversarial controls
corpus/lessons/r105-unreal-lifecycle.md:149: 4. For every documented environment knob, inspect the implementation and run
```

Those cited sections concern the Unreal-MCP gate, its manifest/scanners, adversarial attack suite, falsification verdicts, scratch path and override branches—not this province's 3D production domain. The lesson's own title and progression are “Unreal lifecycle: pin, vendor, gate, harden, repair” (`:1,10`). Thus **no lore or 2D product-surface bleed is found; the gate-audit subject is out of province**, even though those terms are absent. The lesson disclaims a new Unreal-runtime claim (`:3-8`); that does not change the scope verdict.

**Reproduce subject stamp [O]:**

```text
$ sha256sum corpus/lessons/r105-unreal-lifecycle.md && wc -l corpus/lessons/r105-unreal-lifecycle.md
dd9b9ac064511b9cbc95cd4ebed6d62b995606dd3db069453f0ff653afefe758  corpus/lessons/r105-unreal-lifecycle.md
155 corpus/lessons/r105-unreal-lifecycle.md
```

**Disposition:** route or re-scope the gate/harness-audit material; do not call the lesson boundary-clean based on keyword absence. This seat wrote only this report.