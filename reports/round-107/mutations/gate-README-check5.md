## CHECK 5 — pin coherence (r107, GATE-LEAD)

Draft section for `corpus/knowledge/unreal-mcp/gate/README.md`. Orchestrator lands
this alongside the `run_gate.sh` draft; the two are edited together.

### What it checks

The subtree names the upstream commit in prose in ~17 files. Before r107 the gate
compared **none** of them: the pin lived in exactly one machine-checked place (the
`PIN=` constant), while the manifest header, this README's own pin row, the subtree
`README.md`, `PROVENANCE.md`, all 13 verdict cards and `adaptation-kimi.md` each
restated the SHA with nothing tying them together. CHECK 1 hashes only the 12
vendored files; CHECK 2 compares only vendored bytes against the clone. So a tree
that **vendors** pin X while its prose **says** pin Y was a quiet lie the old gate
could not see. CHECK 5 closes it, offline, with no clone.

**Expected:** `MANIFEST_HEADER_PIN=<pin>`, `GATE_README_PIN=<pin>`,
`PIN_DECL_LINES=<n> DRIFT=0`, then `STEP=PASS`.

### What counts as a declaration

A **declaration** is a 40-hex token on a line matching one of the pin-declaration
shapes the subtree actually uses, or on a `rev-parse HEAD` / `CLONE_HEAD=` /
`# pinned SHA:` line:

| anchor | example |
|---|---|
| table row naming a pin | `\| pinned commit \| \`a6aa73ad…\` \| … \|` |
| bolded text naming a pin | `**Upstream pin:** … @ \`a6aa73ad…\`` |
| `Pinned SHA:` / `pinned SHA` / `pinned commit` | `- **Pinned SHA:** \`a6aa73ad…\`` |
| `pinned at` | `pinned at \`a6aa73ad…\` · **Card written:** …` |
| `rev-parse HEAD` (inline or bare hex on the next line) | `git … rev-parse HEAD` → `a6aa73ad…` |
| `CLONE_HEAD=` | `CLONE_HEAD=a6aa73ad…` |
| manifest header | `# pinned SHA: a6aa73ad… (main)` |

The anchor is **deliberate** (the r103 A2 lesson): a line whose *text* merely
contains the letters `pin` is **not** a declaration. The subtree legitimately
carries several history commit/blob SHAs (`be8c183…`, `eaf2e838…`, `5e67bdf9…`),
and a blanket "every 40-hex must equal PIN" would false-positive on all of them.
Both the broad rule and a naive "contains `pin`" rule were measured at r107 to
produce false positives on prose; the shape anchor removes them. See
`reports/round-107/r107-gate.md` §"CHECK 5 false-positive controls".

### Why the two structural anchors are separate

`MANIFEST_HEADER_PIN` and `GATE_README_PIN` are checked **exactly** (not via the
shape scan) because they are the two sites a reader is most likely to trust and the
two a maintainer is most likely to forget. A drift there is reported by name
(`FAIL manifest header pin != PIN`), not folded into the line scan.

### Mode equivalence (CHECK 2e)

Byte-identity is not the whole vendored contract. The upstream tree is all mode
`100644`; a copy whose file was `chmod`'d (e.g. `+x` on a hook) still hashes
identically, so CHECK 1 and CHECK 2a–2d are all blind to it — observed at r107
(`chmod +x` on a vendored file left the gate green). CHECK 2e compares each vendored
file's worktree mode against the mode the clone records (`git ls-files -s`), prints
`MODE_DIFFS=<n>`, and fails on any mismatch. It degrades to `MODE_DIFFS=SKIP
(stat unavailable)` if `stat` is absent, so it never turns a missing tool into a
red gate.

### Control matrix (r107, this host)

Each control was run on a throwaway copy of a minimal workspace; the live subtree
was never mutated. Full transcript: `reports/round-107/r107-gate.md`.

| control | mutation | exit | observed signal |
|---|---|---|---|
| **P0** | none (unmodified copy) | 0 | `PIN_DECL_LINES=38 DRIFT=0`; `STEP=PASS` |
| **D1** | flip the SHA in `PROVENANCE.md` | 1 | `FAIL pin-drift PROVENANCE.md:22` |
| **D2** | flip the SHA in the subtree `README.md` | 1 | `FAIL pin-drift README.md:79` |
| **D3** | flip the SHA in the manifest header | 1 | `FAIL manifest header pin != PIN` |
| **D8** | replace with a *different valid-looking* 40-hex | 1 | `FAIL pin-drift PROVENANCE.md:22` |
| **D9/D13** | flip the SHA on a verdict card | 1 | `FAIL pin-drift executability/<card>.md:…` |
| **D10** | flip the SHA in this README's `upstream pin` row | 1 | `FAIL gate/README upstream-pin row != PIN` |
| **D11** | flip a `CLONE_HEAD=` line | 1 | `FAIL pin-drift gate/README.md:…` |
| **D12** | flip the SHA in `adaptation-kimi.md` | 1 | `FAIL pin-drift adaptation-kimi.md:7` |
| **M1/M2/M3** | `chmod` a vendored file `755` / `600` / `777` | 1 | `MODE-DIFF <path> mode=… expected=644` |
| **N1–N4** | plant a legitimate history/blob SHA in prose (bare, backticked, on a `pin`-word line, in a table) | **0** | `DRIFT=0` — no false positive |
