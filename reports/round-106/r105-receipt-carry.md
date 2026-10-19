# SEAT-113 R105-RECEIPT-CARRY

Seat: **SEAT-113**. Owned path: this file only. Read-only against `reports/round-105/**`. No commit, push, checkout, or reset. No Unreal runtime claim.

Measured `2026-10-18T21:21:49Z`. `git rev-parse HEAD` → `0cc3f4162f8c319f8d01a69a174fe939f36701bd` (`r105 report-last`; parent `3634bc0748f2ae1e02e20571874b39a3f3705daa`).

## Verdict

The four durable N24 receipt files are still present, tracked, and byte-identical to both `3634bc0` and `0cc3f41`. Three of the four SHA-256 rows in `reports/round-105/reports-index.md` still match those bytes. The fourth does not: the index's rerun-stdout row is the mid-write snapshot the index itself labels non-final. The accepted post-close identity is `n24/receipts.md`, and that identity matches the live file. The accepted rerun JSON was never a row in the index table.

Carry: **files unmodified since land**. Index match: **3/3 present rows exact; 1 present row stale by the index's own frame note; 1 accepted file absent from the table**.

## Commands and observed output

Worktree versus both commits (`git rev-parse HEAD:<path>` and `3634bc0:<path>`, then `git hash-object` on the worktree; `git diff --exit-code HEAD -- reports/round-105/n24/runs reports/round-105/reports-index.md`):

```text
node24-full-20261018T202944Z.stdout          blob 377a9e649198c23aad2b344b5c31d8d6aab14367
node24-full-20261018T202944Z.verdicts.json   blob cb41f3cd4b9e002a9ab408ce2dfc3f1272dca2e8
node24-full-rerun-20261018T204240Z.stdout    blob 35ef93335b0f8c28a0583a450f614dd8200ac162
node24-full-rerun-20261018T204240Z.verdicts.json blob 671172e6e82f17e8bfb33b554b1ac238718be09e
reports-index.md                             blob 4d4b9f554e2d609f2cd0cd8ddbb4f5b5ba22b914
diff_rc=0
git status --porcelain -- reports/round-105/n24/runs reports/round-105/reports-index.md
(empty)
```

`3634bc0` and `0cc3f41` have the same blob ids for all five paths. `git diff --stat 3634bc0 0cc3f41 --` those paths is empty. Report-last did not rewrite the receipts or the index.

`sha256sum` and `stat -c '%s'` at `2026-10-18T21:21:11Z`, compared with the index table (`reports-index.md:53-55`) and with `n24/receipts.md:64-67`:

| file | live bytes | live SHA-256 | index row | receipts.md |
|---|---:|---|---|---|
| `n24/runs/node24-full-20261018T202944Z.stdout` | 55349 | `adf138203fa5898f5e839602ea15812e56f7ff1efcef5968cbf70d92f2793999` | match (55349 / `adf13820…`) | match |
| `n24/runs/node24-full-20261018T202944Z.verdicts.json` | 854742 | `cca760d3f12d753e126adb759eeefc6923b6c5b80bab91893114c5e28bd5d0d5` | match (854742 / `cca760d3…`) | match |
| `n24/runs/node24-full-rerun-20261018T204240Z.stdout` | 55282 | `f80d61001c51e1380ddfdeb66b530bc805c2e5960406f49fe5e87e2934839286` | **mismatch** (10377 / `7f76f1d7…`) | match (`f80d6100…`) |
| `n24/runs/node24-full-rerun-20261018T204240Z.verdicts.json` | 854841 | `54b7140de9a24ab6422e9391376d0134c3bafdc29ff21fa45197afc2338046e5` | **no row** | match (`54b7140d…`) |

Index self-identity, unchanged versus HEAD: 85 lines, 8329 bytes, SHA-256 `f8e2a8758a4842e4faa5b483cf83250cd01e8c38f57f6531808b23f1d98fd715`. Its declared frame is `frame_utc=2026-10-18T20:47:59+00:00`, `files=52 bytes=1233028`, `tree_sha256=44e952d839f9e9431c426e1ababa87a64648f9fca61bba6aca1c6733ac992599` (`reports-index.md:26`). That frame text already says the rerun stdout had grown from 9,881 bytes at `20:47:16Z` to 10,377 bytes at `20:47:59Z`, last read ended at output line 202, and the table is not round-close evidence (`reports-index.md:9`). The landed stdout is 704 lines and ends at the terminal totals; line 202 is `PASS phys3d_events_motion_split: exit=0 expected=0`, which is consistent with that mid-write read. `git cat-file -t 7f76f1d715ffbc18f9b59660d9cd0f7c618c216cd86f6792ddc0e4521319cb0b` → `fatal: Not a valid object name` — the mid-write digest is not a git object. Do not treat `44e952d8…` as the hash of the landed tree.

`cmp -s` of the durable JSON copies against the ignored live sources returned 0 for both:

- `corpus/live/runs/20261018T202944290389Z/verdicts.json` == first durable JSON (SHA `cca760d3…`, 854742 bytes)
- `corpus/live/runs/20261018T204240718894Z/verdicts.json` == rerun durable JSON (SHA `54b7140d…`, 854841 bytes)

`find reports/round-105/n24/runs -type f` returns exactly those four files. No extra receipt, no missing file, no mode other than `644`.

## Parsed verdicts (this seat, read-only)

```text
first  verdict=FAIL totals={'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59} seeds_unchanged=False seed_files=130 result_count=350 nonpass=[] cannon=19 pos=13 pos_pass=True neg=6 neg_pass=True free_ops=[('PASS', 0, 0)] runner=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f PINNED-ENV=None positive_node_tokens=['v24.21.0']
rerun  verdict=PASS totals={'cases': 350, 'pass': 350, 'fail': 0, 'ordinary': 291, 'negative_controls': 59} seeds_unchanged=True seed_files=131 result_count=350 nonpass=[] cannon=19 pos=13 pos_pass=True neg=6 neg_pass=True free_ops=[('PASS', 0, 0)] runner=f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f PINNED-ENV=90b15152654331ee98ef8a7644f8daa2a6363927a386328a16da55b33e22eb9f positive_node_tokens=['v24.21.0']
```

Stdout tails:

```text
first  705 lines; line 704 totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0; line 705 FAIL battery: .../20261018T202944290389Z/verdicts.json
rerun  704 lines; line 703 totals: cases=350 pass=350 fail=0 ordinary=291 negative_controls=59 probes=0; line 704 PASS battery: .../20261018T204240718894Z/verdicts.json
```

Prefix counts: first stdout `PASS` 700 / `FAIL` 2; rerun stdout `PASS` 701 / `FAIL` 0. The first run remains the seed-guard failure (`seeds_unchanged=false`, 130 seed files, no `PINNED-ENV.md`). The rerun remains the accepted receipt (`verdict=PASS`, `seeds_unchanged=true`, 131 seed files). This seat did not rerun the battery.

## Judgment

- **Present and unmodified:** yes, for all four durable files, against both the work commit and the report-last commit.
- **Index match is not a full identity check.** Use `n24/receipts.md` (`f80d6100…` / `54b7140d…` / `adf13820…` / `cca760d3…`) as the post-close receipt identity. The index row `7f76f1d7…` / 10377 bytes is a dated pre-close partial, already disclosed in that file, and it is not the landed stdout.
- **Queued, not rewritten here** (index is protected this round): a later index that claims round-close evidence must include the rerun JSON and the completed stdout digest `f80d6100…`, and must not cite `44e952d8…` as that frame. Dated note only — the historical index text stays as written.
