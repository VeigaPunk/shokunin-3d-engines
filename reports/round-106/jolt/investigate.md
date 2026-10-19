# SEAT-49 JOLT-INVESTIGATE — r106

Axes: calibration (is the r103 empty-cell note a real defect), coverage (5× default-env reproduction plus the serial parent the note was written against), depth (discriminate jolt behavior vs log-capture race vs marker-read artifact from raw child logs).

Subject: r103 `reports/round-103/physics/investigate.md` §5.1 — one clean `phys3d_joints --arm=free_ops` run was recorded as emitting empty `freeb_world@jolt` and `detachb_free@jolt` cells (`rc=0,m=`) plus three Dummy cells at `engine=DEFAULT`, while still matching the pinned 3921-char marker. That sample was flagged unconfirmed. This seat re-ran the arm and read the child logs.

**Verdict: (c) benign marker artifact.** Not (a) a real Jolt behavior. Not (b) a log-capture race observed on this host. A cell that is actually empty cannot be byte-equal to the pin, and every run below was byte-equal to the pin with a full Jolt child log.

No fixture was edited. No Unreal runtime claim: the editor is not installed and this arm does not touch it.

## Environment (default state, no PATH prefix)

```text
$ node -v; command -v node; /usr/bin/godot --version | head -1; command -v godot; python3 --version; git rev-parse --short HEAD
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
4.7.2.stable.arch_linux.ed1daf0bf
/usr/bin/godot
Python 3.14.7
0cc3f41
```

Measured `2026-10-18T21:51:48Z`. Node is the default mise v26.12.0. This arm does not invoke Node; the pin is a Godot stdout line. Fixture shas, untouched:

```text
80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6  corpus/fixtures/phys3d_joints.gd
84f6241de590b5810357dde7714a19ec37e3072526e165e4c3ac8a8010d9aaa7  corpus/fixtures/r90_child.gd
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

The r103-era serial parent (`git show b6ba234:corpus/fixtures/phys3d_joints.gd`, the blob §5.1 was written against) is `88be87faee02e6f0afb7d4d93036c5c98755e5daa3ed63e6d361ed0189db4d73`. `r90_child.gd` is unchanged since that blob. Current `phys3d_joints.gd` is the r104 concurrent parent (`2ca87e8`).

Pinned marker, parsed with `ast.literal_eval` from the live `CASES` table (not a grep): 3921 bytes, sha256 `706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74`. The `freeb_world@jolt` cell inside it is 882 bytes and begins:

```text
freeb_world@jolt{rc=0,m=M0 case=freeb_world engine=Jolt Physics|M freeb_world t=1 b=0.0000,2.0000,0.0000 ...
```

`detachb_free@jolt` in that same pin is `detachb_free@jolt{mode_ok=1,m4=e260e2a3c6282b25}` — the BIMODAL form, not `rc=0,m=`.

## Why §5.1's two clauses cannot both be true

A true-empty non-bimodal cell is the 33-byte string `freeb_world@jolt{rc=0,m=,e=0,w=0}`. Replacing only the pinned 882-byte cell with that string yields a marker of **3072** bytes, not 3921. An exact match to the 3921-char pin therefore excludes an empty `freeb_world@jolt` cell. The same arithmetic excludes an `engine=DEFAULT` substitution in any Dummy cell: those substitutions change bytes, and the pin's Dummy cells say `engine=Dummy`.

The token §5.1 quoted is the prefix of the populated cell. The pin cell literally starts `freeb_world@jolt{rc=0,m=` and the value continues `M0 case=...` (849 bytes of M-lines). A hex-only capture `m=([0-9a-f]*)` returns `''` because the value starts with `M`, not a digit. Stopping at `m=` records "empty" while the full line still matches the pin.

`detachb_free@jolt` cannot emit `rc=0,m=` at all. Both the r103-era parent and the current parent list it in `BIMODAL` (`detachb_free@jolt: [4, 4]`), so `_emit` always prints `mode_ok=…,m4=<hex>`. §5.1's claim that this cell was `rc=0,m=` is a format impossibility against the fixture that was current then (sha `88be87fa…`).

`freeb_world@gp` in the pin does say `engine=DEFAULT`. That is the gp backend: `_project_body` omits `3d/physics_engine` when the engine argument is `""`. A scan for `engine=DEFAULT` finds that gp cell, not a Dummy cell.

## 1. Required reproduction — 5× current fixture, default env

Command (the first attempt used `/usr/bin/time`, which is not installed, and exited 127 before Godot ran; those five are not samples). The runs that actually executed:

```text
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --godot /usr/bin/godot \
  --runs reports/round-106/scratch/seat49/repN
```

Started `2026-10-18T21:21:39Z`, load 13.20. Each run is a fresh scratch copy. Runner verdict and the `freeb_world@jolt` child log:

| rep | runner | elapsed s | PASS line vs pin | cell diffs | empty cells | jolt log bytes | jolt M-lines | jolt log sha256 |
|-----|--------|----------:|------------------|------------|-------------|----------------|-------------:|-----------------|
| 1 | PASS exit 0 | 2.797 | equal, 3921 | none | none | 951 | 13 | `4a5250a2f8bd5ab7ea255f324438a82b3bb8c7ff14703d3417dbc34bf66097d2` |
| 2 | PASS exit 0 | 2.638 | equal, 3921 | none | none | 951 | 13 | same |
| 3 | PASS exit 0 | 2.857 | equal, 3921 | none | none | 951 | 13 | same |
| 4 | PASS exit 0 | 2.582 | equal, 3921 | none | none | 951 | 13 | same |
| 5 | PASS exit 0 | 2.675 | equal, 3921 | none | none | 951 | 13 | same |

Receipts: `reports/round-106/scratch/seat49/repN/20261018T2121*/verdicts.json`. Each scratch held 21 `r90bt_free_ops_*` child dirs. `project.godot` for the jolt cell contained `3d/physics_engine="Jolt Physics"`. Marker M-lines for `freeb_world@jolt` equalled the on-disk log M-lines in every rep (no "marker empty, log full" split).

`detachb_free@jolt` in all five was `detachb_free@jolt{mode_ok=1,m4=e260e2a3c6282b25}`, equal to the pin. Dummy cells said `engine=Dummy`.

## 2. The parent §5.1 actually ran — serial `OS.execute`, 5×

The r104 concurrent rewrite post-dates the note. The serial parent was extracted with `git show` into scratch (not into `corpus/fixtures/`) and run directly:

```text
/usr/bin/godot --headless --path <fresh copy> --script res://phys3d_joints.gd -- --arm=free_ops
```

Parent sha in each copy: `88be87faee02e6f0`. Started `2026-10-18T21:23:59Z`.

| rep | exit | wall s | PASS line vs pin | empty cells | jolt log sha16 | marker vs log |
|-----|------|-------:|------------------|-------------|----------------|---------------|
| 1 | 0 | 20.278 | equal, 3921 | none | `4a5250a2f8bd5ab7` | match |
| 2 | 0 | 18.273 | equal, 3921 | none | same | match |
| 3 | 0 | 18.843 | equal, 3921 | none | same | match |
| 4 | 0 | 21.421 | equal, 3921 | none | same | match |
| 5 | 0 | 20.702 | equal, 3921 | none | same | match |

Stdout was the Godot banner plus the PASS line (4023 bytes on disk; the PASS line alone is 3921). Same jolt log digest as the concurrent runs.

## 3. Race stress — 5 concurrent parents, plus scratch reuse

Five copies of the **current** concurrent parent were started together (`2026-10-18T21:37:16Z`, load 2.21, 105 child Godot processes). All five exited 0 in 2.7–3.1 s. All five PASS lines equalled the pin. All five `freeb_world@jolt` logs were the same 951-byte digest. Marker M-lines matched the final logs. No empty cell.

Scratch reuse, the other §5.1 anecdote (a re-run in an already-used scratch): a second serial run in `serial5/rep1` (wall 19.224 s, exit 0) and a concurrent parent dropped onto that dirty tree both emitted the pin byte-for-byte. `project.godot` was rewritten before spawn, as the fixture does. Reuse did not empty the cell.

Archived receipts: 74 `*verdicts.json` files under the repo that mention `phys3d_joints_free_ops` or `freeb_world@jolt` contain zero occurrences of `freeb_world@jolt{rc=0,m=,`. `/tmp/r103phys` is gone, so the original §5.1 stdout cannot be re-read.

## 4. Raw child log (representative)

Every `freeb_world@jolt` log in the 5 battery runs, the 5 serial runs, and the 5 burst runs is this file (951 bytes, sha256 `4a5250a2f8bd5ab7ea255f324438a82b3bb8c7ff14703d3417dbc34bf66097d2`):

```text
Godot Engine v4.7.2.stable.arch_linux.ed1daf0bf (2026-08-17 01:18:38 UTC) - https://godotengine.org

M0 case=freeb_world engine=Jolt Physics
M freeb_world t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=5
M freeb_world t=2 b=0.0000,1.9973,0.0000 lv=0.0000,-0.1633,0.0000 jtype=5
M freeb_world t=3 b=0.0000,1.9918,0.0000 lv=0.0000,-0.3264,0.0000 jtype=5
M freeb_world t=4 b=0.0000,1.9837,0.0000 lv=0.0000,-0.4892,0.0000 jtype=5
M freeb_world t=5 b=0.0000,1.9728,0.0000 lv=0.0000,-0.6517,0.0000 jtype=5
M freeb_world made type=0
M freeb_world t=6 b=0.0000,1.9593,0.0000 lv=0.0000,-0.8139,0.0000 jtype=0
M freeb_world t=7 b=0.0000,1.9430,0.0000 lv=0.0000,-0.9759,0.0000 jtype=0
M freeb_world t=8 b=0.0000,1.9240,0.0000 lv=0.0000,-1.1376,0.0000 jtype=0
M freeb_world t=9 b=0.0000,1.9024,0.0000 lv=0.0000,-1.2991,0.0000 jtype=0
M freeb_world t=10 b=0.0000,1.8780,0.0000 lv=0.0000,-1.4602,0.0000 jtype=0
M DONE case=freeb_world engine=Jolt Physics
```

That trajectory is what the pin cell stores after `m=`. Jolt is stepping the body; the cell is not an empty physics result.

Collection order does not explain an empty read that still matches the pin. Serial `_run_child` calls blocking `OS.execute` and only then opens `child.log`. Concurrent `_collect_child` waits until `OS.is_process_running` is false, then reads. A race that returned `m=` empty would shorten the PASS line and fail the pin compare. That split (empty marker, full log, or the reverse) did not occur in these 17 runs.

## 5. Classification

| candidate | verdict | why |
|-----------|---------|-----|
| (a) real Jolt behavior | no | 17/17 child logs are the same 13-line Jolt trajectory, `engine=Jolt Physics`, digest above. Identical to the pin cell. |
| (b) log-capture race from concurrency | not observed | 5 serial, 5 battery, 5 simultaneous parents, plus a dirty-scratch rerun: marker M-lines equal the final log, PASS line equals the pin. A race that emptied `m` would fail that compare. |
| (c) benign marker artifact | yes | The populated cell begins `rc=0,m=`. A truncated or hex-only read of `m=` records empty while the 3921-char line still matches. `detachb_free@jolt` as `rc=0,m=` is not a form this fixture can emit. Empty-and-3921 is arithmetically impossible (3072 if only that cell were empty). |

§5.1 stays an unconfirmed single sample whose own "matched the pin exactly" clause contradicts the emptiness it reports. Nothing in these runs promotes it to a defect. No judgment defect is queued for this cell: the pin is the behavior the engine emitted.

## Limits

- The original §5.1 stdout is not on disk (`/tmp/r103phys` absent). Classification of that sample is by contradiction with the pin plus non-reproduction, not by re-reading their bytes.
- 17 runs on one host is not a proof that a flush race can never happen. It is enough to reject it as the explanation of a pin-matching run, because a pin-matching run cannot contain the empty cell.
- Bimodal cells (`freeb_ops@gp` and similar) vary in raw log size across runs because teardown ERROR lines differ. Their emitted `mode_ok` prefix still matched the pin. That size variation is not an empty `freeb_world@jolt` cell.
