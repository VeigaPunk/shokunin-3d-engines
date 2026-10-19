# SEAT-39 CENSUS-ADVERSARY — r106

**Seat:** SEAT-39 `CENSUS-ADVERSARY` · **Round:** 106 · **Lane:** `game-dev-3d-shokunin`
**Owned path:** this file only (`reports/round-106/census/adversary.md`). `corpus/knowledge/engines.md` was not edited by this seat.
**Lane HEAD:** `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`0cc3f41`).
**Bytes judged:** `corpus/knowledge/engines.md` sha256 `149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba`, 11555 bytes, 122 lines, mtime `2026-10-18 18:44:28.659390607 -0300`. That sha was stable across reads at `2026-10-18T21:46:59Z` and `2026-10-18T21:55:27Z`. A mid-write sha `62a70d04…` was observed once before it; a later write is outside this ruling.
**Axes:** calibration (what a swarm receipt may support), coverage (a partial probe is not a full re-probe), depth (evidence class versus the r94–r100 receipts, not a vibe about busyness).
**No Unreal runtime claim.** This seat's own absence probe: `command -v UnrealEditor` and `command -v UnrealEditor-Cmd` both rc 1; `ss -ltn` `:8000` count 0 (`2026-10-18T21:46:59Z`). The editor is not installed. The gate line in `engines.md` was not re-run here and is not confirmed or denied.

---

## 0. Ruling

**Do not admit "Last full re-probe" or "r106 re-probed every row under the r105 two-state model" as standing claims.** State cells may stay where they already were. Dated host-fact notes may stand. An r106 receipt may be cited only as a named, bounded observation whose load was not recorded. It is not an r94–r100-class census proof, and it does not refresh the battery totals.

The advertised argument — receipts from a contended host are weaker than the r94–r100 era's — splits:

| # | claim | status |
|---|---|---|
| F1 | r106 is a busier host than r94–r100, so its receipts are weaker on load magnitude | **REFUTED** by this seat's samples versus the era's own load lines |
| F2 | r106 census receipts are a weaker *evidence class* than r94–r100 receipts (load omitted, partial scope, swarm file set, stale completeness list) | **SUBSTANTIATED** |
| F3 | The landed header ("full re-probe" / "every row" / "two-state") overclaims the receipts it cites | **SUBSTANTIATED** on sha `149e61cf…` |
| F4 | This seat reproduced `/tmp` `Disk quota exceeded` | **NOT SHOWN** — 0-byte touch and a 64 KiB write succeeded; do not cite this seat for ENOSPC |

What the census **may** claim is in §4. What it **may not** claim is in §5. Queued wording for the owner of `engines.md` is in §6. This seat did not apply it.

---

## 1. F1 — load magnitude, refuted

32-core host (`nproc` → `32`). This seat's `/proc/loadavg` samples:

| utc | load 1/5/15 | running/total |
|---|---|---|
| 2026-10-18T21:22:14Z | 12.01 / 8.84 / 8.95 | 7/2326 |
| 2026-10-18T21:37:27Z | 11.35 / 4.60 / 5.50 | 2/2255 |
| 2026-10-18T21:41:36Z | 2.14 / 2.92 / 4.57 | 3/2310 |
| 2026-10-18T21:46:59Z | 5.02 / 3.88 / 4.44 | 6/2258 |
| 2026-10-18T21:55:27Z | 3.15 / 4.38 / 4.46 | 4/2368 |

`vmstat 1 3` at 21:37Z: `wa` 0, `procs_blocked` 0, idle 96–98. Swap was in use (`SwapFree` 25604480 kB of 35917176 kB) but that is not a 1-minute load above `nproc`.

Era receipts, read here, name higher loads on this same 32-core host:

- `reports/round-93/r93-baseline2.md` load table: run 2 start **122.61 / 79.17 / 47.53**; run 1 end 111.42 / 75.59 / 46.04. Same file: `phys3d_joints_free_ops` **TIMEOUT 20.053 s** on run 1 and **PASS 17.802 s** on run 2.
- `reports/round-96/r96-critic.md`: every measurement is a loaded-host measurement; quiet baseline not available; load1 52–89.
- `reports/round-96/r96-boundary.md`: "unloaded" means loadavg ≈ 27–58, not zero.
- `reports/round-97/r97-boundary.md`: 1-min load 84–120; "There is no quiet baseline on this host."
- `reports/round-97/r97-verifier.md`: load 52 → 90.
- `reports/round-98/r98-verifier.md`: load 52 → 105 → 77.
- `reports/round-99/r99-verifier.md`: load 52 → 83 → 60.
- `reports/round-100/r100-author.md`: full runs at ~55-load; 10 `bpy_rbw3d_*` arms timed out at the 20 s cap and re-passed when contention cleared.
- `reports/round-100/r100-reviewer.md`: seat-close load 5.5–8.6, and that reviewer called *that* the quieter host.

r94–r100 was not a quiet era. A census that apologizes by saying "weaker because busier than r94–r100" is itself an overclaim. At this seat's samples the 1-minute load was **below** the era's recorded floors, and at 21:41Z–21:55Z it was a calm window (load1 2–5), the class r95 already showed can hide a load-dependent miss (`reports/round-95/r95-critic.md`: `r95_bullet_shm` 8/12 FAIL in a loaded window, 0/12 in a quieter one).

---

## 2. F2 — evidence class, substantiated

r94–r100 reports are 9 markdown files per round (`glob reports/round-{94..100}/**/*.md` → 9 each). They name load. Several run a second pass or an explicit load arm (`reports/round-94/r94-boundary.md`: idle vs load16, 49 arms, drift=0).

r106 is a different artifact shape:

- `glob reports/round-106/**/*.md` at the receipt-parse run → **416** markdown files.
- Census markdown at `2026-10-18T21:55:27Z`: **12 files**, and **zero** of them contain `load average`, `loadavg`, or `/proc/loadavg`. Names: `animtree.md`, `bpy.md`, `bullet.md`, `cannon.md`, `gltf.md`, `n24-state.md`, `navagent.md`, `phys3d-events.md`, `phys3d-joints.md`, `three-default.md`, `three-pinned.md`, `verify.md`.
- During the 21:37Z sample a sibling lane was in a Godot battery: `godot --headless …/game-dev-2d-shokunin/…/r88_surfaces.gd`. `pgrep -c -x godot` was 1; `run_battery.py` argument count was 2–3. Contention here is a writer swarm plus an unrecorded load, not a saturated run queue at the moment of the samples.
- The seat38 verdict JSON (`reports/round-106/scratch/seat38/20261018T213322137930Z/verdicts.json`, 22031 bytes) has no load field. Top keys include `verdict`, `totals`, `elapsed` only inside the row, `seeds_unchanged`, `godot_version`. Parsed: `only=phys3d_joints_free_ops`, totals cases=1 pass=1 fail=0, row PASS, elapsed **1.884 s**, reasons `[]`, exit 0/0, godot `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf`, `seeds_unchanged=true`, timeout 20.
- Peer rows, parsed the same way: `phys3d_joints_free_pair` elapsed 2.765 s and `phys3d_joints_free_ops` elapsed 2.774 s, both PASS / seeds true (`reports/round-106/census/phys3d-joints/runs/20261018T212035512412Z/verdicts.json`, `…/20261018T212038422172Z/verdicts.json`). `r94_cannon_det` elapsed 1.68 s, PASS, seeds true (`reports/round-106/census/cannon-r94_cannon_det-20261018T212035Z.verdicts.json`).

Those elapsed numbers are calm-window observations. They are not comparable to r93's 17.802 s PASS / 20.053 s TIMEOUT on the same `free_ops` row under load 122, and they do not retire that class. r100's bpy timeouts re-passing after the load dropped is the same warning: a green window is not a load-invariant census.

`/tmp` is pressured but this seat did not fail a write. `df -h /tmp` at 21:37Z: tmpfs 16G used 13G avail 3.1G, 80%. `mktemp -d -p /tmp` succeeded; `touch` succeeded; `dd` of 64 KiB succeeded. The round brief's exhausted per-user quota was **not** reproduced here. Historical `Disk quota exceeded` on `/tmp` is in r103/r104 reports, not in this seat's probes. Receipts under `reports/` sit on `/home` (`df` 756G free). A census receipt that lives only in `/tmp` is still a known-fragile class; the paths judged above are not that class.

---

## 3. F3 — the landed header overclaims the citations under it

Quoted from sha `149e61cf…` (section headings, not a promise that line numbers survive the next edit):

> Last full re-probe: r106, 2026-10-18. … r106 re-probed every row under the r105 two-state model. No state cell moved.

The last sentence of that pair is the one that holds. The first two do not.

**Battery totals were not re-probed.** The two-state table's own column header says `full-battery receipt (parsed, not re-run)`. This seat re-parsed those files:

| receipt | top verdict | seeds | totals | non-PASS |
|---|---|---|---|---|
| `reports/round-104/physics/full-regression-runs/20261018T194637610772Z-verdicts.json` (843391 bytes) | FAIL | true | 350 / 337 / 13 | 13, all `r94_cannon_*`, reason `exact stdout marker missing` |
| `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` (854841 bytes) | PASS | true | 350 / 350 / 0 | 0 |
| `reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json` (854742 bytes) | FAIL | false | 350 / 350 / 0 | 0 row fails; the FAIL is `seeds_unchanged=false` |

The 13 default fails are a Node-marker class, not a load flake. Do not reattribute 337/350 to contention. Do not describe the first pinned capture as a clean PASS. The table already says this. The heading "re-probed r106" erases the table's own label.

**Godot was not re-probed under both states, and two-state does not apply to that row.** The evidence cell cites one default-env command: `python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs reports/round-106/scratch/seat38`. Parsed above: 1 case, elapsed 1.884 s, no `node=` token, no load. Peer citations are also default-env. A two-state model is a PATH selection for Node. This marker does not read Node. Calling that row a two-state re-probe is a category error, and calling one `--only` case a full re-probe is a scope error. Headless `yes` was already the cell. Keeping `yes` is not a refresh of the r1 matrix, and the cell's own note that this is not a 350/350 claim is the part that may stand.

**The census-file list was already stale at the sha being judged.** The section "r106 census files this seat read" says that at the gate re-run `2026-10-18T21:38:07Z` the markdown set was exactly five files (`cannon.md`, `three-default.md`, `phys3d-joints.md`, `n24-state.md`, `verify.md`), and that none of them warrants a state-cell move. At `2026-10-18T21:55:27Z` this seat listed **12** census markdown files, including `animtree.md`, `bpy.md`, `bullet.md`, `gltf.md`, `navagent.md`, `phys3d-events.md`, `three-pinned.md`. "None warrants a move" does not cover files the census had not read. "Every row" cannot close on a snapshot that was already incomplete.

**three.js both-state 3/3 and 5/5 is supportable from peer receipts, not from the paths the cell cites.** Parsed this seat:

| receipt | node | cases | verdict | seedsUnchanged |
|---|---|---:|---|---|
| `reports/round-106/census/three-run_cases-20261018T212022Z.json` | v26.12.0 | 3 | PASS | true |
| `reports/round-106/census/three-run_camera_cases-20261018T212022Z.json` | v26.12.0 | 5 | PASS | true |
| `reports/round-106/scratch/seat27/pinned/run_cases.json` | v24.21.0 | 3 | PASS | true |
| `reports/round-106/scratch/seat27/pinned/run_camera_cases.json` | v24.21.0 | 5 | PASS | true |

`engines.md` at this sha contains `seat27` **0** times and `three-pinned` **0** times. The three.js evidence cell names `run_camera_cases.mjs` once and cites one peer path, the default `run_cases` receipt. `seat38` appears 3 times, all the Godot `--only` run. There is no three.js receipt under `reports/round-106/scratch/seat38/`. A reader of the cell cannot re-derive the pinned camera 5/5. The fact may be cited **if the peer paths above are named**. Attributed as "this re-probe, both states" with only the default scene-graph path, it overclaims. `executable headless` stays `partial`. Each receipt's `boundedClaim` denies GL, pixels, and a browser. `npm ci` was not repeated; the cell says so. That limit may stand.

**Absence probes are not a two-state re-probe either.** This seat, 21:46:59Z: `command -v unity` rc 1, `command -v UnityHub` rc 1, `command -v UnrealEditor` rc 1, `command -v UnrealEditor-Cmd` rc 1, `:8000` count 0, `godot --version` → `4.7.2.stable.arch_linux.ed1daf0bf` rc 0, default `node` → `v26.12.0` at the mise `latest` path, PATH-prefixed fnm `node --version` → `v24.21.0`. Those are load-insensitive host facts. They support keeping Unity `no`/`no` and Unreal `no`/`no`. They do not support "every row under the two-state model." This seat did not re-run the Unity checker, the Unreal descriptor checker, or the gate. `POINTERS=103` in the Unreal cell is not this seat's measurement.

The dated `Node v26.11.1` correction note is the right shape: historical string kept, labeled mint-time, not presented as the live default. That note may stand. `SKILL.md` §6 still stamps the pre-edit sha `d03907d3d63771c10558a2bc276d62c50bcdea1d02150d78e6d1a720a0c3bddf`; `engines.md` already says that stamp is stale. Agree. `SKILL.md` is protected this round; this seat did not touch it.

---

## 4. What the census may claim

On sha `149e61cf…`, and on any later edit that does not widen these sentences:

1. **State cells do not move.** Godot `yes`/`yes`, Unity `no`/`no`, Unreal `no`/`no`, three.js `partial`. Promotions: 0. No new engine row.
2. **Host facts, load-insensitive, with the command pasted.** Binary presence or absence, version strings, `:8000` count, Node `execPath` of each state, lockfile pin `three@0.186.1`. This seat's 21:46:59Z probes above are enough for Godot version, both Node versions, and Unity/Unreal absence. They are not a fixture run.
3. **Inherited battery totals, labeled parsed-not-rerun.** Default 337/350 is 13 cannon marker misses, not a missing Godot and not a load flake. Pinned acceptance is the rerun receipt with `seeds_unchanged=true`. The earlier pinned capture is 350 row-passes and a FAIL on seeds. Do not collapse the two states.
4. **A saved r106 receipt, scoped to its `only` and its env.** Example that may be cited: seat38 `phys3d_joints_free_ops` PASS, 1 case, elapsed 1.884 s, seeds true, default env, **load unmeasured**. Not a matrix. Not a timing improvement over r93.
5. **three.js fixture results, only with paths.** Default 3/3 and 5/5 at the two `reports/round-106/census/three-run_*-20261018T212022Z.json` files (node v26.12.0). Pinned 3/3 and 5/5 at `reports/round-106/scratch/seat27/pinned/run_cases.json` and `…/run_camera_cases.json` (node v24.21.0). `partial` stays `partial`. No GL.
6. **The dated `v26.11.1` note.** Keep the historical string. Do not put it back as the live default.
7. **Unreal stays unproven-runtime / static-only.** A green gate, if someone else re-ran it, is not a live editor. This seat does not add a gate confirmation.

---

## 5. What the census may not claim

1. "Last full re-probe" or "every row re-probed under the two-state model."
2. That r106 receipts are r94–r100-durable because the host was quiet, or weaker because it was busier. Magnitude does not go that way (§1). Class does (§2).
3. That a 1.884 s or 2.774 s `free_ops` PASS closes the r93 timeout pair (20.053 s FAIL / 17.802 s PASS under named load 122).
4. That 337/350 is contention. It is 13 `exact stdout marker missing` on `r94_cannon_*`.
5. That one `--only` row replaces the r1 battery pointer as a matrix receipt. The r1 directory not resolving is a real, already-known fact. The replacement evidence is one row.
6. That peer agreement in the same wave is the non-author verifier the promotion rule requires. The rule is unchanged in the file: a cell moves only with a saved bounded-fixture receipt **and** a non-author verifier. No cell moved. Do not spend that rule on a same-wave citation.
7. A Blender / `bpy` row from `reports/round-106/census/bpy.md`. That report's own result line is "installed, background launch works, battery not run." An import is not executable-headless for the 10 `bpy_rbw3d_*` rows. r100 already showed those rows time out under ~55-load.
8. An engine row for cannon-es, bullet, gltf, navagent, or animtree. Those are lane fixtures. `engines.md` already refuses a cannon-es row. The same refusal covers the later census files the header had not read.
9. Any wall time without either a load sample in the same receipt or the label "load unmeasured — not comparable to r93–r100 named-load receipts."
10. An Unreal runtime claim, a `verified-here` card label, or a reading of gate `POINTERS=` as a constant. This seat did not run the gate.

---

## 6. Queued for the engines.md owner — not applied here

If that file is edited again, the header should say: r106 partial re-probe; state cells unchanged; full-battery totals are the r104/r105 receipts, parsed not re-run; Godot evidence is one default-env `--only` row, load unmeasured; three.js both-state counts cite the four receipt paths in §4.5; the census markdown list is a snapshot (five files at 21:38:07Z; twelve at 21:55:27Z) and later files are not inputs to sha `149e61cf…`.

Do not silently rewrite the historical `v26.11.1` sentence. The dated note already does this correctly.

---

## 7. Commands this seat actually ran

Host and identity (repo root):

```text
$ date -u +%Y-%m-%dT%H:%M:%SZ; cat /proc/loadavg; nproc
2026-10-18T21:22:14Z
12.01 8.84 8.95 7/2326 3013997
32
# later samples in §1
$ sha256sum corpus/knowledge/engines.md   # at 21:46:59Z and again at 21:55:27Z
149e61cfe3608b53a444e7b046204478931f1033dbd4c8db08bab542c37bffba  corpus/knowledge/engines.md
$ stat -c 'mtime=%y size=%s' corpus/knowledge/engines.md; wc -l corpus/knowledge/engines.md
mtime=2026-10-18 18:44:28.659390607 -0300 size=11555
122 corpus/knowledge/engines.md
$ git rev-parse HEAD
0cc3f4162f8c319f8d01a69a174fe939f36701bd
```

Absence and Node (21:46:59Z): `unity_rc=1`, `UnityHub_rc=1`, `UnrealEditor_rc=1`, `UnrealEditorCmd_rc=1`, `port8000 0`, godot `/usr/bin/godot` `4.7.2.stable.arch_linux.ed1daf0bf` rc 0, default node `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`, prefixed fnm node `v24.21.0`.

Receipt parse: the Python `json.load` summarized in §2 and §3. Census load scan: 12 markdown files, `census_md_with_load []`, at 21:55:27Z.

`/tmp` write probe at 21:37Z–21:41Z: `mktemp -d -p /tmp` ok; `TOUCH_OK`; `WRITE64K_OK`. `df -h /tmp` → 16G, 13G used, 3.1G avail, 80%.

No battery was run by this seat. No fixture file was written. No path outside this report was written.
