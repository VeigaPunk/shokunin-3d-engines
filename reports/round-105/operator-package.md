# r105 operator package — decision draft

**Axes:** depth · coverage · calibration. This is a one-read proposal, not a ruling. No byte-pinned source is edited here; no Unreal runtime claim is made.

## 1. P/C label precedence — decision requested

- **P — policy-first:** the shared README definition controls runtime-capability claims. If a claim needs the editor and was not observed, it is `unproven-runtime`, even when the call path is not yet identified; static document facts remain separately evidenced. This is analyst-1’s argument: avoid author-local vocabularies and compare runtime uncertainty consistently.
- **C — card-first:** a whole card remains `static-only` when its checked evidence is documentary and no executable path/signature is identified; the behavior claim remains binary `unproven`. Reserve `unproven-runtime` for an identified path without a runtime receipt. This is analyst-2’s argument: do not imply “just run it” when the call surface is still unknown.
- **Recommendation (hybrid proposal):** use P’s shared-policy authority, but make it claim-granular: binary `proven`/`unproven` attaches to each claim, while the ternary label describes the card’s evidence scope. `static-only` means checked static documentation with behavior still unproven; `unproven-runtime` means a specific identified runtime path has no receipt. This intentionally narrows analyst-1’s path-independent threshold while retaining P’s common vocabulary. Keep the six current labels (`animation-controlrig`, `blueprints`, `editor-general`, `gameplay-gas`, `materials`, `meshes-textures`) unless a separately reviewed amendment justifies changes. Proposal only: no relabel or pinned-byte edit.

**Amendment set if approved:** clarify the shared authority boundary and these predicates; remove any unqualified binary↔ternary equivalence; audit all 13 cards against the rule; keep gate PASS separate from semantic approval. At this package check, `python3` card scan observed `cards=13 label_census={'unproven-runtime': 1, 'static-only': 12}` and `dissent=6`; `sha256sum corpus/knowledge/unreal-mcp/README.md` returned `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721`. The P/C source tree had no tracked diff (`git diff --quiet HEAD -- corpus/knowledge/unreal-mcp/README.md corpus/knowledge/unreal-mcp/executability` → `pc_source_tracked_diff_rc=0`). The r105 PC ledger requires three independent reviews of the same proposal/diff hash before landing; current scan `python3` → `pc_reviews=0`. Therefore this remains proposed, not ready to apply.

## 2. Node 24 — two execution profiles, not a fixture drift

- **Default host:** `node --version` / `command -v node` → `v26.12.0` via mise. The 13 pinned cannon cases under this state produced `totals: cases=13 pass=0 fail=13`; each failed with `exact stdout marker missing`.
- **Pinned profile:** process-scoped `PATH=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH` → `node v24.21.0`; the same 13 cases produced `totals: cases=13 pass=13 fail=0`. This is a PATH-selected host state, not a fixture edit.

Commands actually run (same `CASES` value for both):

```sh
CASES='r94_cannon_det,r94_cannon_det2,r94_cannon_varstep,r94_cannon_bailout,r94_cannon_nan,r94_cannon_sync,r94_cannon_material,r94_cannon_friction,r94_cannon_parity,r94_cannon_parity2,r94_cannon_modes,r94_cannon_order,r94_cannon_backends'
python3 corpus/fixtures/run_battery.py --only "$CASES" --runs /dev/shm/r105-seat63-default
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py --only "$CASES" --runs /dev/shm/r105-seat63-v24
```

These subset receipts are in `/dev/shm`, not durable full-battery receipts. The runbook is `reports/round-105/n24/runbook.md`; **350/350 under Node 24 remains the acceptance bar and is not claimed here**. At package assembly, the full-run stdout scan returned `node24_stdout_lines=286 pass_rows=286 fail_rows=0`, and the newest durable 350-row receipt found was the default profile, `corpus/live/runs/20261018T201215739340Z/verdicts.json`: `pass=337 fail=13`. No full Node-24 receipt was available in that scan. The selection command is process-scoped; `git diff --name-only -- corpus/fixtures` was empty, and `git status --short -- corpus/fixtures` showed only the SEAT-11 documentation exception `?? corpus/fixtures/PINNED-ENV.md`.

## 3. Three L0 questions for the operator

1. Link an Epic Games account to GitHub so `EpicGames/UnrealEngine` source becomes fetchable?
2. Authorize pulling the public `wukakuki/unreal-engine:dev-slim-5.8.3` image (~26.8 GB; contents unverified) as a possible runtime unlock?
3. Prefer the Lutris/Epic-launcher path instead?

These are unchanged operator-owned questions from r101; static-only work proceeds without them. Command actually run: `python3 -c "p='reports/round-101/r101-report.md'; print(''.join(open(p).readlines()[337:342]), end='')"` → printed all three questions above.
