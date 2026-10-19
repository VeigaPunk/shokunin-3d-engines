# SEAT-58 STUB-CLEANNESS — r106

Axes: coverage (authored r106 surface + lane prose, clones/vendor excluded), depth (literal `TODO` / `{{…}}` / `placeholder` scan), calibration (counts stamped to a command that was actually run).

**Owned path written:** this file only. No git mutating command. No mechanical edit: the scan found no Class D stub in a file this seat may write, and the dirty corpus files are other seats' chunks.

**HEAD at every frame:** `0cc3f4162f8c` (`r105 report-last`). HEAD did not move.

**Primary frame:** `2026-10-18T19:12:08-03:00`. `reports/round-106/` authored files (exclude `scratch/`, `runs/`, `node_modules/`): **100**. Markdown in that set: **61**. Tracked dirty paths: **59**. `corpus/knowledge/engines.md`: **166** lines, sha256 `501b30df1ca3ffc3b4d9239b80ec1ec633c3886188f63412bea0d7f77d21f933`. `reports/round-106/r106-report.md` sha256 `f6e3823d1ecf6ba1a439bfc0d0e13302ebaceb7375f6b9995c17a02b1f0d724b`.

This file quotes the token list and will self-match a rescan. Counts below exclude it.

## 0. Verdict

**No stub defect.** Class D = 0.

- **A — expected close slots.** 11 `{{…}}` tokens, all in `r106-report.md`, whose line 6 states the contract: `L1 fills this at close; this report is intended to land last.`
- **B — prose.** The word `placeholder` names a probe, a close-shape rule, or a citation template. It does not stand in for missing content.
- **C — false positive.** `operator-questions.md:63` is a pasted `docker images --format '{{.Repository}}:{{.Tag}} {{.Size}}'` Go template, not a round slot.

Word-bound `TODO` / `TBD` / `FIXME` / `XXX` / `WIP`: **0** in the authored r106 set. Substring `XXX`: **0**. `{{` in lane prose (`corpus/knowledge`, `lessons`, `artifacts`, `predecessor`, excluding `upstream/`, `.manifest.d/`, `gate/`): **0**. `engines.md` stub tokens: **0**. Dirty tracked files with a stub token: **0 of 59**.

## 1. Primary-frame commands and observed output

Run from the lane root at `2026-10-18T19:12:08-03:00`.

```text
HEAD=0cc3f4162f8c
ENGINES=501b30df1ca3ffc3b4d9239b80ec1ec633c3886188f63412bea0d7f77d21f933 lines=166
MOD=59 AUTH=100 MD=61
REPORT_SHA=f6e3823d1ecf6ba1a439bfc0d0e13302ebaceb7375f6b9995c17a02b1f0d724b
```

Mustache (`rg -n -e '\{\{[^}]*\}\}' reports/round-106` with scratch/runs/node_modules/this file excluded):

| file:line | token | class |
|---|---|---|
| `r106-report.md:6` | `{{R106_COMMIT}}` | A — "L1 fills this at close" |
| `r106-report.md:8` | `{{R106_COMMIT}}` | A — "Re-measure at" |
| `r106-report.md:184` | `{{R106_COMMIT}}` | A |
| `r106-report.md:186` | `{{V_DEPTH}}` `{{V_COVERAGE}}` `{{V_CALIBRATION}}` | A |
| `r106-report.md:188` | `{{RULING_C1}}` | A |
| `r106-report.md:190` | `{{RULING_C2}}` | A |
| `r106-report.md:192` | `{{RULING_C3}}` | A |
| `r106-report.md:194` | `{{R106_ADMISSION}}` `{{R106_COMMIT}}` | A |
| `operator-questions.md:63` | `{{.Repository}}` `{{.Tag}}` `{{.Size}}` | C — docker Go format |

`rg -o '\{\{[^}]*\}\}' reports/round-106/r106-report.md | sort | uniq -c` → `{{R106_COMMIT}}` ×4, and one each of `{{R106_ADMISSION}}` `{{RULING_C1}}` `{{RULING_C2}}` `{{RULING_C3}}` `{{V_CALIBRATION}}` `{{V_COVERAGE}}` `{{V_DEPTH}}`. Sum **11**.

Word-bound `TODO|TBD|FIXME|XXX|WIP|PLACEHOLDER` on the same r106 set returned only:

| file:line | class | what the line is |
|---|---|---|
| `battery-default-quick.md:88` | B | token-swap probe: one placeholder made two cannon markers equal |
| `scorecard-shape.md:69` | B | rule: a close placeholder is allowed only if marked unfilled |
| `sweep/chunk-05.md:72` | B | "Placeholder forms (`<runner>`, …) were not expanded" |
| `sweep/chunk-05.md:104` | B | "Placeholder command templates were not expanded into invented paths" |

`rg -n -i -e 'TODO|TBD|FIXME|placeholder|\{\{' corpus/knowledge/engines.md` → rc=1 (`NONE_ENGINES`).

Dirty-tree loop (`git diff --name-only`, then the same stub pattern per file) → `modified_stub_files=0`.

`rg -l -e '\{\{'` on corpus prose excluding upstream/manifest/gate → `NONE`.

`rg -l XXX` on authored r106 → `NONE_XXX`.

## 2. Earlier frames (same HEAD, tree still landing)

| frame | what was measured |
|---|---|
| `18:32:40-03:00` | `engines.md` still the HEAD blob: 16 lines, sha256 `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`. Stub pattern rc=1. |
| `18:44:46-03:00` | Census refresh had landed: 122 lines, sha256 `149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba`. Still no stub token. |
| `18:52:48-03:00` | Authored r106 **83** files. Mustache only the 11 report slots (then at lines 6, 8, 162, 186, 188, 190, 192, 194). `modified_with_stub=0 of 41`. Word `pending`: 2 hits, both B — `consistency.md:35` (closed `(pending: …)` labels) and `install-recheck.md:67` (Epic-account wall). |
| `18:54:58-03:00` | Plural/angle scan, not repeated at 19:12: `sweep/chunk-13.md:49` "Placeholders `<scratch>` and `<timestamp>` are templates"; `:56` cites the corpus's own `r12-import-<timestamp>` pattern; `census/navagent.md:72` records a child argv shape `--path <scratch>`; `two-state-carry.md:82` cites `corpus/live/runs/<timestamp>/`. Class B. |

The 19:12 report draft is the same 11 slots at shifted lines (`162→184`). Later landings are outside this snapshot.

## 3. Excluded, measured, not defects

Protected or vendored. Not edited.

- Lane fixture scripts excluding `r94vendor/` and `node_modules/`: word-bound `TODO|TBD|FIXME|XXX|WIP` rc=1 at `18:52:48`. `placeholder` there is physics vocabulary (`phys3d_events.gd`, the expected PASS string in `run_battery.py:485`, `corpus/fixtures/README.md:861`), not an unfinished seat artifact.
- Vendored `corpus/fixtures/r94vendor/` at `18:52:48`: `cannon-es.js` `@todo` **33** lines, `WIP` **1**; `three.module.js` word `TODO` **10**; `three.core.js` word `TODO` **4** and `{{` **15** (JSDoc `@type {{…}}`, sampled at `three.core.js:9685`). Third-party comments. Do not "fix" them.
- `corpus/knowledge/unreal-mcp/gate`: word-bound strict six rc=1 at `18:52:48`. Upstream and `.manifest.d` were not rewritten and were not treated as r106 artifacts.
- Root `README.md` `SKILL.md` `LOG.md` `SCORECARD.md` `PROVINCE.md` `SHONEN.md`: `{{` rc=1 at `18:52:48`. The one historical `placeholder` is `LOG.md:1299` (r-era saturation scaffold prose), protected, class B.

## 4. Queue

Judgment defects queued: **none**.

No Class D line to hand to another seat. The 11 close slots are the scribe draft's declared contract, not a sweep miss. Vendor `@todo` is out of scope.

## 5. Boundaries

Text scan only. No Unreal runtime claim; the editor is not installed. Scratch stayed under `~/.cache/s58` (`TMPDIR` set there). `/tmp` was not used. This seat did not commit, push, checkout, or reset.
