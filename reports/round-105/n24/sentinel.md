# SEAT-18 — N24 scope sentinel

**Verdict:** Fixture implementation and marker scope PASS; N24 full-run acceptance is **not met**. All 350 case rows passed under the pinned Node 24 process, but the runner's overall verdict is FAIL because `seeds_unchanged=false`.

## Fixture and marker boundary

- `python3 -c` comparing the r104 verdict receipt's `seed_digests` with the current files returned identical hashes: `run_battery.py` `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`; `phys3d_joints.gd` `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6`; `phys3d_equals_r104=True`.
- `git diff --exit-code HEAD -- corpus/fixtures` returned `tracked_fixture_diff_exit=0`. `git status --short --untracked-files=all -- corpus/fixtures` returned only `?? corpus/fixtures/PINNED-ENV.md`, the SEAT-11-declared documentation exception; no fixture implementation or marker file changed.
- Read-only AST census command over `corpus/fixtures/run_battery.py` returned `CASES 350`; `r94_cannon 19 positive_pinned 13 negative_controls 6`. The unchanged runner hash plus empty tracked fixture diff confirms zero marker edits.

## Runtime scope

- `node --version; command -v node; fnm default; git status --short -- .mise.toml mise.toml .tool-versions; stat -c ... ~/.config/mise/config.toml` returned default Node `v26.12.0` from mise, fnm default `v24.21.0`, no repo toolchain-file changes, and mise config mtime `2026-10-15 03:19:53 -0300`.
- While the matrix ran, reading only PID 1447144's `/proc/.../environ` PATH returned `matrix_path_first=/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin`, `matrix_path_has_fnm24=True`; the unprefixed shell still resolves to Node 26.12.0. The override was scoped to the battery process.

## Full-run receipt and blocker

- The observed invocation was `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" python3 corpus/fixtures/run_battery.py`, with stdout saved to `reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout`.
- `Grep` of that stdout found `totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0` followed by `FAIL battery: .../corpus/live/runs/20261018T202944290389Z/verdicts.json`. Parsing the durable report copy `reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json` returned `verdict FAIL`, the same 350/350 totals, and `seeds_unchanged False`. Its SHA-256 is `cca760d3f12d753e126adb759eeefc6923b6c5b80bab91893114c5e28bd5d0d5`; it is byte-identical to the live receipt.
- Compared the receipt's 130-entry pre-run `seed_digests` to the current seed map using the runner's exclusions (`__pycache__`, `three`): `started_utc=20261018T202944290389Z`; `current_seeds=131`; `added=['PINNED-ENV.md']`; `missing=[]`; `changed=[]`; `seeds_unchanged=False`. `stat` showed `PINNED-ENV.md` mtime `2026-10-18 17:35:35 -0300`, after the run began at `17:29:44 -0300`. Thus the sole mutation was the permitted new doc appearing during the run, not fixture-code or marker drift.
- Worktree scope command `git status --short --untracked-files=all` summarized `status_paths=56`, `non_doc_receipt_paths=[]`, `fixture_paths=['corpus/fixtures/PINNED-ENV.md']`; tracked changes were only `SKILL.md` and `corpus/knowledge/unreal-mcp/adaptation-kimi.md` (documentation).

**Follow-up:** Keep the current run as evidence of 350/350 case results, not a green battery verdict. Re-run the full battery under the same command-scoped Node 24 PATH after fixture documentation is stable; accept only a fresh receipt with `seeds_unchanged=true` and 350/350, then retain its stdout and JSON receipt.