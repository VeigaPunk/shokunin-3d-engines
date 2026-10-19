# SEAT-46 CONSIST-TWOSTATE — r106

Axes: coverage (every lesson/README quote of `337/350`, `350/350`, `336/350`), depth (each quote paired with default vs pinned), calibration (quoted totals match the cited receipts). Historical wording was kept; the missing environment was added, not substituted.

**Owned writes:** `corpus/lessons/r105-unreal-lifecycle.md` (the quoting line and the dated note under it) and this file. No other file was edited. `corpus/fixtures/PINNED-ENV.md` is SEAT-17's. Reports under `reports/round-101/` … `reports/round-105/` were not written.

## Inventory

Scanned 92 `corpus/lessons/*.md` and 103 `README.md` files outside `.git/` and `reports/round-*`.

| Form | Lessons | READMEs (excl. round reports) | Pairing |
|---|---:|---:|---|
| `337/350` | 2 lines, 1 file | 0 | paired after this seat's edit |
| `350/350` | 0 | 0 | no quote to pair |
| `336/350` | 0 | 0 | no quote to pair |

The two lesson hits are the same claim, not two measurements:

- `corpus/lessons/r105-unreal-lifecycle.md:133` — the r104 corroboration sentence. Before this edit it said `full battery 337/350 corroboration` and named neither default nor pinned. That was the only unpaired quote.
- `corpus/lessons/r105-unreal-lifecycle.md:137` — the dated note added below. It repeats `337/350` and pairs it with the default environment; the pinned total is given as `cases=350 pass=350`, not as a second slash-form quote.

No README quotes any of the three slash forms. `rg -n -g 'README.md' '337/350|350/350|336/350'` over the tree excluding `.git/` and `reports/` returned `README_SLASH=0`.

## Edit

`corpus/lessons/r105-unreal-lifecycle.md` grew `162 → 174` lines (`git diff --stat`: `14 +++++++++++++-`, 13 insertions, 1 deletion). The historical `337/350` and the cited receipt path were not removed.

Before (HEAD `59ead03` line): `full battery 337/350 corroboration`.

After: `full battery 337/350 corroboration under the default environment, mise Node v26.12.0, not the pinned fnm Node v24.21.0 total`.

Dated note added immediately under that bullet (`Environment pairing (r106, 2026-10-18)`). It states:

- `337/350` is the default-environment total. Plain `node` is mise `v26.12.0` at `/home/vgpnk/.local/share/mise/installs/node/latest/bin/node`.
- Cited receipt `corpus/live/runs/20261018T201215739340Z/verdicts.json` is `cases=350 pass=337 fail=13`, `verdict=FAIL`, `seeds_unchanged=true`. All 13 failures are `r94_cannon_*` with observed `node=v26.12.0`.
- That figure is not the pinned-environment result. The clean pinned receipt is `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json`, byte-identical to `corpus/live/runs/20261018T204240718894Z/verdicts.json`: `cases=350 pass=350 fail=0`, `verdict=PASS`, `seeds_unchanged=true`, positive cannon rows `node=v24.21.0`.

`git diff --check -- corpus/lessons/r105-unreal-lifecycle.md` exited 0. The file ends with a newline and has no trailing whitespace on the edited lines.

SEAT-18 (r105 lesson citation sweep) and SEAT-45 (receipt-line notes) also touch this lesson. Preserve the pairing clause on line 133 and the dated note. Do not collapse `337/350` and `350/350` into one environment-free total.

## Adjacent quotes, not edited

- `corpus/fixtures/PINNED-ENV.md:20` quotes `337/350` and already pairs it: heading `Interpreting the default-environment result`, mise path, `v26.12.0`, markers `node=v24.21.0` vs observed `node=v26.12.0`. It does not quote `350/350` or `336/350`. Not a lesson or README, and SEAT-17 owns it. Not edited. Carry, not a defect in this seat's quote set: the file still does not cite the later clean pinned `pass=350` receipt. Its one-case disclaimer (`corpus/live/runs/20261018T202715395926Z`) remains true of that receipt.
- `corpus/lessons/r22-unreal-review.md:55` quotes `cases=350 pass=335 fail=15`, not a named total. It already pairs the 13 cannon failures with markers `node=v24.21.0` against host `node v26.12.0`. Left as the r102 record.
- `corpus/knowledge/engines.md` has no `337`, `336`, or `350` (SEAT-38 owns that file). Not edited.
- Slash forms in `reports/round-100/` … `reports/round-105/` and in other `reports/round-106/` files are outside this seat's write set. r100's `350/350` is that round's green runs, not the r105 pinned-env total. Not edited.

## Commands run and observed output

Node resolution (command-scoped PATH; shell default unchanged):

```text
$ node --version; command -v node
v26.12.0
/home/vgpnk/.local/share/mise/installs/node/latest/bin/node
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" node --version
$ PATH="/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin:$PATH" command -v node
v24.21.0
/home/vgpnk/.local/share/fnm/node-versions/v24.21.0/installation/bin/node
```

Runner pin, unchanged by this seat:

```text
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
```

Quote census (lessons and READMEs only):

```text
LESSON_FILES 92
README_FILES_EXCL_ROUNDS 103
LESSON 337/350 2
LESSON 350/350 0
LESSON 336/350 0
README 337/350 0
README 350/350 0
README 336/350 0
LINE 133 default=True pinned=True
```

`rg -n -g '*.md' '337/350|350/350|336/350' corpus/lessons` after the edit returned only `r105-unreal-lifecycle.md:133` and `:137`. `rg` of `README.md` excluding `.git/` and `reports/` printed `README_SLASH=0`.

Receipt parse (read-only; this seat did not rerun the battery):

```text
cited-default corpus/live/runs/20261018T201215739340Z/verdicts.json
  sha256=47ab8ccfc897c8c12c6efb542a9eb1524dc8959f732235a205c43acab97c78ff
  totals={'cases': 350, 'pass': 337, 'fail': 13, 'ordinary': 291, 'negative_controls': 59}
  verdict=FAIL seeds_unchanged=True
  fail_n=13 fail_cases=[r94_cannon_det, r94_cannon_det2, r94_cannon_varstep, r94_cannon_bailout, r94_cannon_nan, r94_cannon_sync, r94_cannon_material, r94_cannon_friction, r94_cannon_parity, r94_cannon_parity2, r94_cannon_modes, r94_cannon_order, r94_cannon_backends]
  fail_node_tokens=['v26.12.0'] positive_cannon_node_tokens=['v26.12.0']
pinned-copy reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json
  sha256=54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5
  totals={'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59}
  verdict=PASS seeds_unchanged=True
  fail_n=0 positive_cannon_node_tokens=['v24.21.0']
pinned-live corpus/live/runs/20261018T204240718894Z/verdicts.json
  sha256=54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5
pinned_copy_byte_identical_to_live True
```

One-case receipt named by `corpus/fixtures/PINNED-ENV.md` (not edited; confirms that file's disclaimer is still about a single case):

```text
corpus/live/runs/20261018T202715395926Z/verdicts.json exists size=19132
totals={'cases': 1, 'pass': 1, 'fail': 0, 'ordinary': 1, 'negative_controls': 0}
verdict=PASS seeds_unchanged=True
cases=['r94_cannon_nan']
```

Lesson size versus HEAD:

```text
$ wc -l corpus/lessons/r105-unreal-lifecycle.md
174
$ git show HEAD:corpus/lessons/r105-unreal-lifecycle.md | wc -l
162
$ git diff --stat -- corpus/lessons/r105-unreal-lifecycle.md
 corpus/lessons/r105-unreal-lifecycle.md | 14 +++++++++++++-
$ git diff --check -- corpus/lessons/r105-unreal-lifecycle.md
DIFF_CHECK_RC=0
```

No Unreal runtime claim is made. The battery numbers above are fixture-receipt parses, not editor evidence.
