# SEAT-34 CENSUS-AREA3D — one r93 row, both Node states

Axes: **depth** (re-probed `r93_areasig_edges`, not inherited from r105), **coverage** (default mise Node and pinned fnm Node, same Godot row), **calibration** (exact marker equals the live `CASES` literal; historical missing receipts are dated, not rewritten).

Result: **PASS / PASS**. One ordinary row. Not a 350-case claim. Not the other six `r93_areasig_*` arms. Not an `area3d_chain` runtime re-run. No `engines.md` edit (that file was already dirty in another seat; this chunk does not own it). No fixture write. No Unreal runtime claim. `which UnrealEditor UnrealEditor-Cmd` printed `no UnrealEditor` and `no UnrealEditor-Cmd`. Pin `a6aa73ada02a9fb1f5415bec491f9942c519b297` is named, not re-cloned here.

HEAD at probe: `git rev-parse --short HEAD` → `0cc3f41` (2026-10-18T21:27:28Z).

## Environment (r105 two-state)

Probed 2026-10-18T21:27:28Z, rechecked 2026-10-18T21:45:38Z. The prefix is command-scoped. After the pinned check, plain `node --version` was still `v26.12.0`.

| State | Command | Observed |
|---|---|---|
| default | `node --version; command -v node` | `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node` |
| pinned | `PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version; command -v node` | `v24.21.0` at `/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node` |
| Godot | `godot --version; command -v godot` | `4.7.2.stable.arch_linux.ed1daf0bf` at `/usr/bin/godot` |

`r93_areasig.gd` does not exec `node`. Child spawn is `OS.create_process("/bin/sh", ["-c", prep["cmd"]])` with `timeout` and `OS.get_executable_path()` (Godot). A Node-token hit in the sources is the comment `Node._physics_process`, not the Node binary. This row is not one of the 13 `r94_cannon_*` marker failures. Both states are expected to match, and they did.

Runner SHA-256 `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` (`sha256sum corpus/fixtures/run_battery.py`). Fixture digests in both receipts: `r93_areasig.gd` `e4b040068a52f55fbcd021c6c58c4f87e4a90e22c17f1e22659158f18e546034`, `r93_child.gd` `fac6b4399e4db1de9d4a316e70e317b249d5860556c6ca1625200915a9fd7d3e`, `area3d_chain.gd` `c9270bea3462a116433bc05db48eb93c01ccda4da43073167360967744ec313c`. `git status --short` on those four fixture paths was empty.

## Commands

Scratch is under `reports/round-106/scratch/seat34-area3d/` (`/tmp` quota is exhausted). The runner copies fixtures into that scratch; the copy is not a fixture edit.

Default, inherited PATH, started `20261018T212930056533Z`:

```sh
python3 corpus/fixtures/run_battery.py --only r93_areasig_edges --godot /usr/bin/godot \
  --runs reports/round-106/scratch/seat34-area3d/default
```

Pinned, same invocation with the fnm prefix, started `20261018T212930062360Z`:

```sh
PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" \
  python3 corpus/fixtures/run_battery.py --only r93_areasig_edges --godot /usr/bin/godot \
  --runs reports/round-106/scratch/seat34-area3d/pinned
```

## Observed

Both terminals (copied to `reports/round-106/census/area3d-default-20261018T212930Z.stdout` sha256 `9aeacc47d9b79d804959a100baaa63ee69baa1b2c6bee4b0ec82bcd043e90452`, and `area3d-pinned-20261018T212930Z.stdout` sha256 `444ac5f9764b13582359dc6a2580f6f87964b53c41361ee2c7eee19f4fed80e6`):

```text
PASS r93_areasig_edges: exit=0 expected=0
totals: cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0
COMMAND_EXIT=0
```

JSON (`seeds_unchanged=true`, `seed_files=131`, `reasons=[]`, stderr 0, `case_timeout_seconds=20`, godot version exit 0):

| state | elapsed | exit | receipt | sha256 |
|---|---:|---|---|---|
| default | 3.041 | 0/0 | `reports/round-106/census/area3d-r93_areasig_edges-default-20261018T212930Z.verdicts.json` | `6046c45cfc45e6a32518588ceccef85c4a824c64f2325b52da89e3a00d0fb44a` |
| pinned | 3.157 | 0/0 | `reports/round-106/census/area3d-r93_areasig_edges-pinned-20261018T212930Z.verdicts.json` | `df28346d392b12a714b730552e2a4076a1ef9809a4153910e5772d94e84ce82a` |

Originals remain at `reports/round-106/scratch/seat34-area3d/{default,pinned}/20261018T212930056533Z` and `…062360Z`. A field walk of the two JSON receipts found **4** diffs, all run identity: `.scratch`, `.started_utc`, `.results[0].command[3]` (scratch `--path`), `.results[0].elapsed_seconds`. Markers are byte-identical.

Stdout is three lines: Godot banner, a blank line, then the marker. The marker is line index 2, length **6166**, sha256 `de1c91c997d0c7a545b97ac618731aa593a0c4eb7ae8913d810420ccadf276ed`, and it equals the live `CASES` literal for `r93_areasig_edges` (`ast` extract of `corpus/fixtures/run_battery.py`). Prefix: `PASS r93_areasig edges enter@gp{rc=0,m=M0 case=enter engine=DEFAULT|…`.

Parsed from that marker (9 cells, all `rc=0`):

| cell | facts entry / exit |
|---|---|
| `enter@gp`, `enter@jolt` | 21 / 35 |
| `enter@dummy` | `-` / `-` |
| `enter0@gp`, `enter0@jolt` | 2 / 25 |
| `enter0@dummy` | `-` / `-` |
| `tele@gp`, `tele@jolt` | 25 / 35 |
| `tele@dummy` | `-` / `-` |

Child logs in the default scratch are not just a parent echo. `r93t_gp_enter/child.log` is 154 lines, 14 `M` lines, including `M enter facts entry=21 exit=35` and `M enter census in_step=4 … nif=43 ne=44 nf=43 nsig=4`. `r93t_dummy_enter/child.log` has `engine=Dummy`, `facts entry=- exit=-`, `in_step=0 nif=0 nsig=0`. Nine child dirs exist (`r93t_{gp,jolt,dummy}_{enter,enter0,tele}`).

The same marker equals the r105 pinned full-run row. `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` has one `r93_areasig_edges` hit, verdict `PASS`, exit 0, and `marker` byte-equals this run. That receipt's battery verdict is `PASS` with `seeds_unchanged=true`. This seat's run is the r106 re-probe; the r105 file is a comparison, not a substitute.

## Citation sweep (this surface only)

Resolved, no rewrite:

- `corpus/fixtures/run_battery.py --only r93_areasig_edges` — case name is a `CASES` row; both runs exited 0.
- `corpus/fixtures/area3d_chain.gd:39` is `const ENTRY_X := 4.0`; `:133` is `func _chain_verdict`; `:154` is `func _absent_verdict`. Those are the lines `corpus/lessons/r1-headless-verification.md` cites.
- Live `sha256sum corpus/fixtures/area3d_chain.gd` is `c9270bea3462a116433bc05db48eb93c01ccda4da43073167360967744ec313c`, matching the digest quoted in `corpus/lessons/r1/clean-verdicts.json`, `corpus/lessons/r1/mutation-verdicts.json`, and `corpus/lessons/r70-navagent-detour-non-author.json`. Byte match is not a runtime pass. `area3d_chain` and `area3d_chain_no_overlap` were **not** executed this seat.
- `reports/round-93/r93-author.md` quotes `r93_child.gd` sha `fac6b439` for its later runs. Live file still hashes to `fac6b4399e4db1de9d4a316e70e317b249d5860556c6ca1625200915a9fd7d3e`.

Queued, not rewritten (not this chunk; historical facts stay in the old files):

- **Dated 2026-10-18.** `reports/round-93/r93-author.md` cites `corpus/live/r93-author/`, `corpus/live/r93-scout/`, `corpus/live/r93-boundary/`, and `/tmp/r93batt`, `/tmp/r93batt_full1`, `/tmp/r93batt_full2`, `/tmp/r93batt_full3`. `ls` on each returned "No such file or directory". `git check-ignore -v corpus/live/r93-author` → `corpus/.gitignore:1:live/`. Those trees are not a fresh-clone citation. The re-derivation command for the edges arm is the `--only` pair above, not those missing trees. Do not silently edit `reports/round-93/`.
- **Dated 2026-10-18.** `corpus/lessons/r1-headless-verification.md` says to run its checker from `.shokunin/game-dev-3d/`. `test -d .shokunin/game-dev-3d` → rc 1. The area3d line cites inside that lesson still resolve. Lesson file is not this chunk.
- Judgment, not a broken path: `corpus/fixtures/area3d_chain.gd` header says `python3 corpus/fixtures/run_battery.py` beside the comment "case area3d_chain". That command is the full battery, not `--only area3d_chain`. Fixture code is protected. Not edited.

No mechanical edit landed outside this report and the four receipt copies under `reports/round-106/census/`. `corpus/knowledge/engines.md` was already `M` when this seat finished; this seat did not write it.
