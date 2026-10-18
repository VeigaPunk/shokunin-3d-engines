# SEAT-30 REPORTS-INDEX — `reports/round-104/` final-frame inventory

Seat: **SEAT-30 REPORTS-INDEX** (r104). Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Scope: name the final frame of `reports/round-104/` and give a per-file sha256 table measured at this
seat's own runtime, plus the naming-convention / subdir / duplication / protected-path audit the r102
and r103 indexes established.

**Read-only.** This seat wrote nothing but this file. No cited artifact was edited, and no `git`
state-mutating command was run (no commit / push / checkout / reset).

Lane HEAD throughout: `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` (*"r103 report-last: verdict (all
axes improved), LOG + SCORECARD, A4 timeline ruling + physics ruling + fixtures conformance ruling —
work `8c9d9ad`"*).

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.

**No Unreal runtime claim appears anywhere in this file.** Unreal Editor is not installed
(`which UnrealEditor` → rc 2, re-run by `reports/round-104/skill/author.md` §2) and live-MCP is
unproven by construction; every number below is a byte, exit-status, or filesystem measurement.

---

## 0. Headline — and the one structural difference from every prior round

| property | value |
|---|---|
| **durable artifact set at the frozen frame** | **65 files**, 1 275 496 B |
| durable tree hash (sha256 of the sorted `sha256sum` listing) | `2f8588cf9b2d61cb41739bf4dc58d619d92d723290e55d19c83a9ce14f7aab8b` |
| frame time | `2026-10-18T20:07:58Z` (local `17:07:58 -0300`) |
| **whole round (durable + scratch)** | **21 945 files**, 361 469 779 B (~345 MiB) — *[moving]*, measured `20:08:50Z` |
| **scratch share** | **21 880 files = 99.70 %** of the round by file count |
| top-level `*.md` + non-md artifacts | 19 files |
| `r104-<seat>.md` files (top level) | **7** (r103 had 6, r102 had 7, r101 had 15) |
| subdirectories (maxdepth 1) | **6** — `gate/`, `lessons-carry-loop/`, `physics/`, `scratch/`, `skill/`, `tmp.O08ANPOIb9/` |
| distinct `SEAT-NN` ids appearing in the durable set | **42** (excluding this index file, which is SEAT-30) |
| duplicate basenames inside the durable set | 1 — `author.md` (`physics/` + `skill/`) |
| byte-identical duplicates inside the durable set | 2 groups (see §5) |
| executable files | **1** — `gate/flake_harness.sh` |
| round-close report present | **yes** — `r104-report.md` (SEAT-35, 60 124 B) |

**The r103 reports-index's central lesson was "a count-stable directory is not a byte-stable
directory." This round adds a harder one: a directory can be 99.7 % scratch, and the count can swing
by two orders of magnitude while the durable artifact set is untouched.** At `19:21:40Z` this round
held **266 896 files** because a single seat had made a 247 314-file copy of the whole repository
under `scratch/s20-skel3/`; that tree was deleted, and the round fell back to ~6 000 files before
climbing again. **No index that measures "the round" by whole-tree count is measuring the round's
artifacts.** §3 therefore freezes and hashes an explicit **durable allowlist**, and §6 accounts for
the scratch separately. **[O]**

---

## 1. Method (exact commands, all read-only)

```
date -u +%Y-%m-%dT%H:%M:%SZ
git rev-parse HEAD
git status --porcelain
git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
# durable allowlist (a path list, NOT a set of exclusions — see §0)
{ find reports/round-104 -maxdepth 1 -type f
  find reports/round-104/gate -maxdepth 1 -type f
  find reports/round-104/physics -maxdepth 1 -type f
  find reports/round-104/physics/standalone -type f
  find reports/round-104/skill -type f
  find reports/round-104/lessons-carry-loop -type f
} | sort -u
# per-file row
<allowlist> | while read -r f; do \
  seat=$(grep -o -m1 -E 'SEAT-[0-9]+' "$f" | head -1); \
  printf '%s|%s|%s|%s\n' "$(sha256sum "$f"|cut -d' ' -f1)" "${seat:-—}" "$(stat -c%s "$f")" "$f"; done
# durable tree hash (stability test)
<allowlist> | xargs sha256sum | sort -k2 | sha256sum
# transient accounting
find reports/round-104 -type f | wc -l ; find reports/round-104 -type f -printf '%s\n' | awk '{s+=$1}END{print s}'
find reports/round-104 -mindepth 1 -maxdepth 1 -type d | sort
find reports/round-104 -type f -printf '%f\n' | sort | uniq -d
find reports/round-104 -type f -exec sha256sum {} + | awk '{print $1}' | sort | uniq -d
```

### 1.1 Why an allowlist, not exclusions

The r103 index defined its frame by *excluding* scratch subdirs. That fails in r104: new
fixture-copy trees appeared faster than an exclusion list could name them. Measured directly —
a sampler that excluded `*/scratch/*`, `*/runs*`, `*/s06/*`, `*/author-runs*`, `*/nc*` still saw its
"durable" count jump **58 → 1 511 → 2 967** between `19:35:25Z` and `19:36:25Z` because two new
copies of the fixture tree (`physics/hang/`, `physics/hang-asis/`, then `physics/author-bpyreps/`)
landed under names the exclusions did not cover. **[O]**

```
D2 19:35:25 n=58    tree=d04bf0ddfef9f14b
D2 19:35:45 n=1511  tree=79c817e72cd99891      # physics/hang* copies appeared
D2 19:36:05 n=2964  tree=7f77cc45246d7121
```

An allowlist of the six paths that actually hold artifacts is stable against this, and its
membership is checkable by eye. **[O]**

### 1.2 The frame was frozen by a stability test

A single sample cannot distinguish a settled directory from one being rewritten in place. This seat
therefore required the **durable tree hash** to repeat across consecutive samples before calling the
frame final:

```
19:50:16Z  n=64  tree=173aad033ad8e293
19:50:36Z  n=64  tree=173aad033ad8e293
19:50:56Z  n=64  tree=173aad033ad8e293
19:51:16Z  n=64  tree=173aad033ad8e293
19:51:36Z  n=64  tree=173aad033ad8e293
19:51:56Z  n=64  tree=173aad033ad8e293
19:52:16Z  n=64  tree=173aad033ad8e293      # 7 samples
19:52:36Z  n=64  tree=0ac0d5908e38e35c      # moved: physics/copy.md rewritten
...
19:53:36Z  n=64  tree=ee2fe07e9582d15a
19:53:56Z  n=64  tree=ee2fe07e9582d15a
  ... (28 consecutive identical samples) ...
20:01:17Z  n=64  tree=ee2fe07e9582d15a      # first freeze candidate
```

**The first candidate was WRONG, and re-measuring caught it.** That frame was written at
`20:01:28Z`; at `17:02:43` local (`20:02:43Z`) a **new durable artifact**
`physics/full-regression.md` (SEAT-07) landed, moving the durable set to 65 files. A 28-sample
stable window was still not proof that the round had stopped producing artifacts. The seat
therefore re-ran the whole stability test on the new set:

```
20:02:52Z  n=65  tree=2f8588cf9b2d61cb
20:03:12Z  n=65  tree=2f8588cf9b2d61cb
  ... (16 consecutive identical samples) ...
20:07:52Z  n=65  tree=2f8588cf9b2d61cb      # BYTE-STABLE, 16 samples / ~5.3 min
```

Re-measured once more at `20:07:58Z` for §3: `2f8588cf9b2d61cb…` — identical. **§3 is a settled
frame, not a moving one.** Two lessons are recorded rather than smoothed over:

1. **A stable window proves the past, not the future.** The seat that writes the round's last
   artifact is by construction still active while the index is being written; re-measuring *after*
   the draft, and again before declaring done, is the only defence. The r103 index's §10 correction
   note made the same point in the opposite direction (it saw a file *appear* after its frame).
2. **The first near-miss inside a window:** the hash held 7 samples at `173aad03…` and then moved
   when `physics/copy.md` (SEAT-05) was rewritten — a 3-minute window would have frozen a stale
   frame. **[O]**

---

## 2. Growth series

The count is dominated by scratch, so it is reported in two columns: whole-round file count and the
durable allowlist count. Sampled by background `seq` loops at 15–20 s; the sampler's own log lived on
the shared `/tmp` tmpfs and died twice on quota (§7). **[O]**

| time (UTC) | all files | durable | note |
|---|---|---|---|
| `19:16:39Z` | 168 | — | round 23 s old |
| `19:16:54Z` | 175 | — | |
| `19:17:09Z` | 181 | — | |
| `19:17:24Z` | 227 | — | `physics/s06/` copies appear |
| `19:17:39Z` | 575 | — | |
| `19:18:09Z` | 1 603 | — | `gate/scratch/` clones |
| `19:20:24Z` | 3 357 | — | |
| `19:21:25Z` | 6 861 | — | **/tmp quota error begins** |
| `19:21:40Z` | **266 896** | — | `scratch/s20-skel3/` = 247 314-file repo copy |
| `19:22:49Z` | 7 915 | 16 | skel3 deleted |
| `19:24:09Z` | 10 504 | 22 | |
| `19:26:29Z` | 11 618 | 31 | |
| `19:27:30Z` | 6 141 | 33 | second big tree deleted |
| `19:32:30Z` | 11 990 | 39 | |
| `19:35:45Z` | — | 58 | allowlist introduced |
| `19:38:25Z` | — | 63 | |
| `19:40:25Z` | — | 64 | count reaches 64 |
| `19:53:36Z` | — | 64 | hash settles at `ee2fe07e…` |
| `20:01:28Z` | 21 941 | 64 | first freeze candidate (superseded) |
| `20:02:43Z` | — | **65** | **SEAT-07 `physics/full-regression.md` lands** |
| `20:07:58Z` | 21 945 | 65 | **frozen frame**, tree `2f8588cf…` |

Reading **[I]**: the durable set grew monotonically **16 → 65** over 51 minutes; the last artifact
(SEAT-07's full-regression write-up) landed **19 minutes after** the run it reports on, and 1 minute
*after* the first freeze candidate. The whole-round count is **non-monotone and effectively
meaningless** — it swung 168 → 266 896 → 6 141 → 21 945 with no correlation to artifact production.
The two large deletions are the round cleaning up its own scratch trees. **The growth series is
evidence for §0's claim, not for the round's size.**

---

## 3. Final-frame durable table — 65 files, sha256 (full 64 hex), frame `2026-10-18T20:07:58Z`

Durable tree hash of this table: `2f8588cf9b2d61cb41739bf4dc58d619d92d723290e55d19c83a9ce14f7aab8b`.
Seat column is the **first** `SEAT-NN` token in the file — a first-token heuristic, not an
authorship claim: `physics/ledger.md` also mentions SEAT-02/03/07/32 in its prose but is credited to
SEAT-11, its H1 owner. `—` means the file carries no seat token at all (captured stdout/stderr
receipts, not seat artifacts). **[O]**

| path | seat | bytes | sha256 |
|---|---|---|---|
| `reports/round-104/consistency.md` | SEAT-31 | 41551 | `ae7fd854abfcc0a71b1725f72df6178ba52db15d45010bfc81feb55fdec63cdd` |
| `reports/round-104/freshness-pin.md` | SEAT-43 | 12183 | `74731f47f03e2192763fa4a4792e590b234a2069e41e886177047332551e13fb` |
| `reports/round-104/gate/close-runs.md` | SEAT-48 | 13005 | `24d861ddab26e63fb9acf58f0040c496dc901136f788889d57fb6a04977cacfc` |
| `reports/round-104/gate/diff-sentinel.md` | SEAT-16 | 23252 | `17567dfa0eb9f9f4bb3660ea906e67413c32d1e9330055cb8beed78eb9f71585` |
| `reports/round-104/gate/docs-sync.md` | SEAT-17 | 17576 | `50aa4d9ad6fa832c47445931e4e2fb2317bcd93314e16b605bb10a18ddeb4aef` |
| `reports/round-104/gate/final-run.md` | SEAT-40 | 14004 | `e4d53bea7e9c9a9b9ac2a587227ea79ebea7f0212cd122e2cc2f741184f1a757` |
| `reports/round-104/gate/flake-harness.md` | SEAT-14 | 18163 | `1a60688440e6371e9165bbfcb3bf93a56c65b76f4d076f298b7447e0e388a5f7` |
| `reports/round-104/gate/flake_harness.sh` | SEAT-14 | 15680 | `1aeec7000878b4ebcb1f61069202405766dff6b201194267360e68b78dd25bb2` |
| `reports/round-104/gate/pin-check.md` | SEAT-45 | 27049 | `021a6994a143fd63ef3d13d3d2afbdb12da20e101882bbc5d88d8ef550142275` |
| `reports/round-104/gate/regression.md` | SEAT-15 | 20245 | `cbd1ee15005e8f9848925bfa785b79e8c3354360a33f57ef931b3dab937f974e` |
| `reports/round-104/gate/workdir.md` | SEAT-12 | 13744 | `8c70daa84e1fcb512d5f45cc6932b23b8f61e55530e2105546186d4738128c55` |
| `reports/round-104/gate/workdir-verify.md` | SEAT-13 | 13508 | `ce27b3dd2bf2d10775f43d7fbdb6efc6f8173387d12dd371dd29007686359333` |
| `reports/round-104/git-hygiene.md` | SEAT-27 | 33431 | `85159280b2ac263a7f43c13a7be7160e0af7c999bcd8d21d0791d0b5f35b5cab` |
| `reports/round-104/install-recheck.md` | SEAT-44 | 23436 | `3403ff8ebf4afab33b5ef5a2737b66543f7f98e0dfc87fd9c6679046b46be00b` |
| `reports/round-104/kimi-404-carry.md` | SEAT-47 | 12412 | `63b9f0767651dc313e6d0d2ace68af01b327d45a1869bc82d54957ca5c1f283c` |
| `reports/round-104/ledger-check.md` | SEAT-26 | 6438 | `2360e3225216958f8220891150076149b9f14a8757d1fda53b95763821ee7953` |
| `reports/round-104/lessons-carry-gate-default-tmpdir.out` | — | 2080 | `703b6c28496ddb464dca81257a46848d66c18d2a3e150b99b7d4355e7927a7c9` |
| `reports/round-104/lessons-carry-loop/run10.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run1.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run2.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run3.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run4.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run5.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run6.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run7.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run8.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry-loop/run9.out` | — | 2102 | `a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31` |
| `reports/round-104/lessons-carry.md` | SEAT-46 | 41037 | `678c005aa648f354de7d7b893ed3dfec03a0e14a5b0e40bed98cc4b8db16fc8e` |
| `reports/round-104/math-audit.md` | SEAT-25 | 39860 | `818ebbc10a930a60b42ded619e570eaba6c00802939c0cbf73d2e7233aa25339` |
| `reports/round-104/physics/adversary.md` | SEAT-10 | 40711 | `9881f1aebe9e7500a618cf981c8cb6cd76fcf4bc81cb0213350c29c791e42128` |
| `reports/round-104/physics/author-full-final.stderr` | — | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reports/round-104/physics/author-full-final.stdout` | — | 55875 | `d391c3861a9a63025ca228abb012c59d8b9e182a6e0c6f0bb8d07c058664b0dc` |
| `reports/round-104/physics/author-full.stderr` | — | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reports/round-104/physics/author-full.stdout` | — | 55829 | `d5975de0c26740527ab50eb27ca2d178e719554727e269777a5928d3e82318fe` |
| `reports/round-104/physics/author.md` | SEAT-04 | 16765 | `4b3cbbf04ec35960b5d4a4362d596eb4c3c3ab291a9e2ea6c32749a637f02b81` |
| `reports/round-104/physics/before-battery-clean.stdout` | — | 588 | `d753c5f2d1f93ffb5e0c556e815902436b08d9ac1950f5d27e5129571b542352` |
| `reports/round-104/physics/before-battery.stderr` | — | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reports/round-104/physics/before-battery.stdout` | — | 582 | `e63b1ac5dad00f19592dea910fd26f4e1b9a88f5490b5255c25675aec33aeb5c` |
| `reports/round-104/physics/before.md` | SEAT-02 | 12327 | `026ebb816e7d74193b1b771b2df1dab7d8dfeb819967057dc2f878ce09083859` |
| `reports/round-104/physics/copy.md` | SEAT-05 | 21796 | `5281d117f40da9a30ad500bd4a0abbd66915d43c1f78ad309d7d2689e096bf55` |
| `reports/round-104/physics/design.md` | SEAT-01 | 21960 | `5f5596eca1642b811aef74f52a18da293dd44974231fa61026f3fdea138f7313` |
| `reports/round-104/physics/determinism.md` | SEAT-06 | 22109 | `a7807f7e267d9f01310993daba539fb3cd25665a005549e214c5fa336c7a519f` |
| `reports/round-104/physics/full-regression.md` | SEAT-07 | 14310 | `c139b3ebdd9f3ed0f8d09959ebf66068460539e732c8d391de11e7d8686e90b0` |
| `reports/round-104/physics/hang-asis.out` | — | 3906 | `f52e15d71b1562aa5aacd8ed6dbc8179d5fe77dad840885b23c0a5a6e645819c` |
| `reports/round-104/physics/hang-deadline.out` | — | 165 | `c5df2ef70932658438964a4d36d06f34f550943f8c71352fd397482ee029a474` |
| `reports/round-104/physics/ledger.md` | SEAT-11 | 37002 | `a6f1e98c9eba79f025085132d1fb5a69bcb5a0fd79874d16049b4b4b86e8f215` |
| `reports/round-104/physics/markers.md` | SEAT-03 | 21140 | `5d0768f0b4ffbf1eb697f5446a234cc07bc1f7036fb811921d20a55d003f5f3c` |
| `reports/round-104/physics/seeds.md` | SEAT-09 | 16440 | `d315f1bb0b4c0562c3306deeec73a6f57a268dda98096c45e1bffeefcad4c3c8` |
| `reports/round-104/physics/sentinel.md` | SEAT-08 | 24007 | `0ea87bcf4e6c84b17d9ef76e590513647db1db18be01220a599bc6ceabd8f381` |
| `reports/round-104/physics/standalone/free_ops-uncapped.stderr` | — | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reports/round-104/physics/standalone/free_ops-uncapped.stdout` | — | 4023 | `07f72b5beae4a1149c07a775b63c48e28fe0b6b838a52d439d1d01f6698c56ab` |
| `reports/round-104/r104-adjudicator-draft.md` | SEAT-36 | 45993 | `162555ccc305a2fdb83312d9ac9d7ed4a6b59f0fe6a1afdbce086c8d445fd23f` |
| `reports/round-104/r104-connector.md` | SEAT-24 | 31646 | `b56339bfa123cabb4cfafd80ad7f49cf06708557444d923cba82ee421c3ac17f` |
| `reports/round-104/r104-dissonance.md` | SEAT-22 | 29121 | `ab1c4b724b07c247493aee357c9490c8285175d22dffa8e22f5d1f2cd9dc6f75` |
| `reports/round-104/r104-distiller.md` | SEAT-23 | 41145 | `61209f055bfc4e4627f959b7d7dc8efe985ec0cdc8f0e7d1e61df2c7a7a0b0dd` |
| `reports/round-104/r104-report.md` | SEAT-35 | 60124 | `0b99f7f1b908e808139a466a4602092c0e5e77f9240378481a59110eadad67a6` |
| `reports/round-104/r104-scribe-audit.md` | SEAT-29 | 47751 | `2b012b3838ca113b819b029d7d80041812b8763b8b9af9eb6813261c80913a4b` |
| `reports/round-104/r104-verification-protocol.md` | SEAT-32 | 65624 | `2f0bb8bb0a68b2695d149c1a1be791cf13e015da9a9a6746acc4551f732da61c` |
| `reports/round-104/seats-ledger.md` | SEAT-42 | 15651 | `42bf488709add8b92d15e497100b956770a02c92a949206f41289a6b5e191cc7` |
| `reports/round-104/skill/author.md` | SEAT-18 | 20222 | `454ad5b6a215ea5ddfe01b8a6ebc69d91cc9c34c72e79f4fead8cc9e01ae5933` |
| `reports/round-104/skill/bleed.md` | SEAT-21 | 27967 | `53ce48abeaad0cdb3e24e9e5ebe95cadcc4b9b953772722ed984665c26ffbce2` |
| `reports/round-104/skill/critic.md` | SEAT-20 | 34310 | `f80cc144c1eaeba1dffb94e6c3244f4e2b6c4e642631d09fa87cfe6a15ba49ad` |
| `reports/round-104/skill/review.md` | SEAT-19 | 33541 | `8511e1188964795a3b6faf3e9c57444cb9a43fa2002bf5ccc0dee62180ece75b` |
| `reports/round-104/stub-cleanness.md` | SEAT-28 | 25274 | `c4d1c304040aa08555a5c92782a0ee8cf11e369e921b189260ad05c252e7ca55` |
| `reports/round-104/subtree-integrity.md` | SEAT-41 | 17918 | `a37c7c1a3b6394c32a9df946fb538075a83c8a758183257906c4e7b21412b011` |

### 3.1 Per-subdirectory counts (durable allowlist)

```
$ for spec in TOPLEVEL:reports/round-104:1 gate:reports/round-104/gate:1 \
    physics:reports/round-104/physics:1 physics/standalone:reports/round-104/physics/standalone:0 \
    skill:reports/round-104/skill:0 lessons-carry-loop:reports/round-104/lessons-carry-loop:0; do
  name=${spec%%:*}; rest=${spec#*:}; p=${rest%:*}; md=${rest##*:}
  if [ "$md" = 1 ]; then n=$(find "$p" -maxdepth 1 -type f | grep -v reports-index.md | wc -l)
  else n=$(find "$p" -type f | wc -l); fi; printf '%-22s %s\n' "$name" "$n"; done
TOPLEVEL               19
gate                   10
physics                20
physics/standalone     2
skill                  4
lessons-carry-loop     10
```

19 + 10 + 20 + 2 + 4 + 10 = **65**, exactly the row count of §3. The `TOPLEVEL` figure of 19 is the
19 rows of §3 that sit directly under `reports/round-104/`; this index file itself is a 20th
top-level file and is deliberately excluded (§12). **[O]**

### 3.2 Seat attribution

**43 of 65** durable files carry a `SEAT-NN` token; the **22** that do not are captured run receipts,
not seat artifacts:

```
$ <allowlist> | while read -r f; do grep -q 'SEAT-[0-9]' "$f" || echo "$f"; done
reports/round-104/lessons-carry-gate-default-tmpdir.out
reports/round-104/lessons-carry-loop/run{1..10}.out
reports/round-104/physics/author-full{,-final}.{stdout,stderr}
reports/round-104/physics/before-battery{,-clean}.stdout
reports/round-104/physics/before-battery.stderr
reports/round-104/physics/hang-{asis,deadline}.out
reports/round-104/physics/standalone/free_ops-uncapped.{stdout,stderr}
```

**43 distinct seat ids** appear across the durable set (the count includes SEAT-30, this file's own
seat, when the allowlist is taken whole; **42** excluding this index): `SEAT-01`…`SEAT-29`,
`SEAT-31`, `SEAT-32`, `SEAT-35`, `SEAT-36`, `SEAT-40`…`SEAT-48`. The ids **not** present in a
durable artifact — `SEAT-33`, `SEAT-34`, `SEAT-37`…`SEAT-39` — are seats visible only in the scratch
trees. **[O]**

---

## 4. Naming convention — `rNN-<seat>.md` usage held roughly flat

Measured against the r102 and r103 audits **[O]**:

| round | total durable files | `rNN-<seat>.md` (top level) | first such file appeared |
|---|---|---|---|
| `reports/round-101` | 33 | 15 | — |
| `reports/round-102` | 61 | 7 | `17:44:29Z`, ~3 min in |
| `reports/round-103` | 59 (frozen) / 61 (final) | 6 | ~2.5 min in |
| `reports/round-104` | **65** (durable) | **7** | `19:25:27Z` (earliest `r104-*` mtime), ~9 min in |

```
$ find reports/round-104 -maxdepth 1 -type f -name 'r104-*' | sort
reports/round-104/r104-adjudicator-draft.md
reports/round-104/r104-connector.md
reports/round-104/r104-dissonance.md
reports/round-104/r104-distiller.md
reports/round-104/r104-report.md
reports/round-104/r104-scribe-audit.md
reports/round-104/r104-verification-protocol.md
```

**Verdict: the convention is stable at ~6–7 files per round and now names a recognisable
long-form class** (connector, dissonance, distiller, report, scribe-audit, verification-protocol)
plus, this round, `r104-adjudicator-draft`. The 12 top-level non-`r104-*` markdown files carry the
seat id in the H1 as before. **[O]**

### 4.1 Subdir convention — a `skill/` workstream and a `scratch/` tree are new

```
$ find reports/round-104 -mindepth 1 -maxdepth 1 -type d | sort
reports/round-104/gate
reports/round-104/lessons-carry-loop
reports/round-104/physics
reports/round-104/scratch
reports/round-104/skill
reports/round-104/tmp.O08ANPOIb9
```

r103 used `b2/ gate/ note/ physics/`. r104 keeps `gate/` and `physics/`, adds `skill/` (the C3
decision-table review workstream — 4 files), `lessons-carry-loop/` (SEAT-46's probe receipts) and
`scratch/` (a round-level scratch tree, 6 041 files). **Verdict: the subdir layout continues to
encode the round's workstreams, and now also carries the round's own scratch — which is the reason
§0's headline matters. `tmp.O08ANPOIb9/` is an empty leftover directory** (0 files) from a `mktemp`
that was cleaned; it is recorded here so the tree is not silently incomplete. **[O]**

---

## 5. Duplication and artifact types

```
$ <allowlist> | xargs -n1 basename | sort | uniq -d
author.md
$ <allowlist> | xargs sha256sum | awk '{print $1}' | sort | uniq -d
a9c76caf6aa37d524e89be0a15ec960c27a1a26b8150181fef826b7b019f3f31
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
$ <allowlist> | xargs ls -l | grep '^-rwx'
-rwxr-xr-x 1 vgpnk vgpnk 15680 Oct 18 16:24 reports/round-104/gate/flake_harness.sh
```

- **One duplicate basename in the durable set**: `author.md` exists at `physics/author.md` (SEAT-04,
  16 765 B) and `skill/author.md` (SEAT-18, 20 222 B) — different seats, different bytes, different
  roles. Same deliberate cross-subdir reuse r102 and r103 recorded. **Not a defect.** **[O]**
- **Two byte-identical groups**, both benign and both expected:
  - the ten `lessons-carry-loop/run{1..10}.out` files are **all identical**
    (`a9c76caf…`, 2 102 B each) — that is the *finding* of SEAT-46's probe: ten repeat runs of the
    gate at the default workdir produced byte-identical output. Their sameness is the evidence, not
    a copy defect. **[O]**
  - four **zero-byte** `*.stderr` captures share the empty-file hash `e3b0c442…`.
    **Note:** `e3b0c442…` is the sha256 of the empty string; a zero-byte file hashing to it is a
    correct measurement, not a broken hash. **[O]**
- **One executable**: `gate/flake_harness.sh` (mode `755`). It passes `bash -n` (rc 0) at this frame
  — the r104 report records that an *intermediate* revision failed `bash -n` at line 115/128 and the
  landed one does not. This index measures the landed bytes. **[O]**

### 5.1 Cross-round basename reuse

```
$ comm -12 <( <allowlist> | xargs -n1 basename | sort -u ) \
           <( find reports -type f -not -path 'reports/round-104/*' -printf '%f\n' | sort -u )
adversary.md author.md close-runs.md consistency.md critic.md docs-sync.md final-run.md
freshness-pin.md git-hygiene.md install-recheck.md ledger-check.md ledger.md math-audit.md
regression.md review.md seats-ledger.md sentinel.md stub-cleanness.md subtree-integrity.md
```

**19 durable r104 basenames also exist in an earlier round**, up from 7 in r103. The lane-wide
duplicate-basename count (whole `reports/` tree, all rounds, scratch included) is now **284**, but
that figure is inflated by the fixture copies (a single vendored `three.js` file name repeats across
every scratch tree). **The durable cross-round figure is the meaningful one: 7 → 19.** A cross-round
grep that assumes basenames are unique will return two or more hits for each of these. **[O]**

---

## 6. Transient accounting — where the other 21 880 files went

The durable set is **65 files / 1 275 496 B**. The whole round measured at `20:08:50Z` is
**21 945 files / 361 469 779 B** — *[moving]*, since scratch is still being created and deleted.
The difference is scratch, and it is not close. **[O]**

| tree | files | bytes | what it is |
|---|---|---|---|
| `physics/` (total) | 15 495 | 294 772 897 | fixture-copy run trees |
| `physics/author-runs-full{,-final}/` | 5 399 each | — | full-battery scratch copies |
| `physics/s06/` | 1 234 | — | serial-vs-concurrent experiment |
| `physics/author-reps/` | 860 | — | |
| `physics/author-bpyreps/` | 695 | — | |
| `scratch/` (round-level) | 6 041 | 64 580 127 | SEAT-37 / skeleton copies |
| `gate/scratch/` | 365 | 1 351 236 | gate clone/workdir probes |
| `lessons-carry-loop/` | 10 | 21 020 | **durable** (counted in §3) |
| `skill/` | 4 | 116 040 | **durable** |
| `tmp.O08ANPOIb9/` | 0 | 0 | empty leftover dir |

Each of these is a copy of `corpus/fixtures/` (1 411 files) plus the `r90bt_*` child dirs the C1
concurrency experiment produces. **The largest single transient event of the round** was
`scratch/s20-skel3/`: 247 314 files / 2.3 GiB, a copy of the *entire repository*, present at
`19:21:40Z` and deleted by `19:22:49Z`. It briefly made this round the largest `reports/` subtree in
the lane's history by two orders of magnitude. **[O]**

**These trees are not part of the final frame and must not be counted as round artifacts.** They are
also the reason §1 uses an allowlist. **[I]**

---

## 7. The `/tmp` quota incident — reproduced live by this seat

The C2 claim of this round is gate-workdir resilience against `/tmp` quota pressure. **This seat hit
that failure independently, three times, while merely trying to sample the round** — which is
first-hand evidence that the defect is real and not a single seat's misconfiguration. **[O]**

```
$ find reports/round-104 -type f -exec sha256sum {} + | sort -k2 | sha256sum
sort: write failed: /tmp/sortBaRBmf: Disk quota exceeded
19:21:40Z files=287093 bytes=4813050848 tree=e3b0c44298fc1c14   # e3b0c442… = sha256 of EMPTY
$ df -h /tmp
tmpfs  16G  13G  3.1G  80% /tmp
$ echo hi > /tmp/r104idx/probe
bash: /tmp/r104idx/probe: Disk quota exceeded
```

Three observations worth carrying:

1. **`/tmp` is a shared 16 GiB tmpfs and the failure is a per-user quota, not a full disk.** `df`
   reported **3.1 G free** while every write failed. This matches SEAT-13's `gate/workdir-verify.md`
   root-cause finding exactly. **[O]**
2. **The failure is silent in the worst way.** The `sort` step of a pipeline that computes a tree
   hash died mid-stream, so the pipeline still printed a hash —
   `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`, the sha256 of the **empty
   string**. **A quota failure can therefore masquerade as a valid, stable tree hash.** Anyone
   freezing a frame this way would pin the empty hash. This index's stability test (§1.2) would have
   been fooled if it had not also carried the file count in the same sample. **[O]**
3. **The gate's own fix is the remedy.** Running the gate with `GATE_WORKDIR` pointed at real disk
   works from this seat's own shell (§8). **[O]**

---

## 8. Gate state at the frozen frame

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
e55213049db7538d2c126f02b7e6d91bfb38af77ff5f8b375b521b400d7b9c08  corpus/knowledge/unreal-mcp/gate/run_gate.sh
$ wc -l corpus/knowledge/unreal-mcp/gate/run_gate.sh
442
$ grep -c GATE_WORKDIR corpus/knowledge/unreal-mcp/gate/run_gate.sh
13
```

**The C2 fix landed and this seat re-ran it end-to-end, not merely read it:**

```
$ GATE_WORKDIR=$HOME/.cache/r104idx/gatework bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
WORK_ROOT=/home/vgpnk/.cache/r104idx/gatework (from GATE_WORKDIR)
WORK_ROOT_FREE=768G of 930G (17% used)
CHECK 1 manifest-byte-identity      STEP=PASS
CHECK 2 clone-equivalence           STEP=PASS
CHECK 3 verdict-card-scan           STEP=PASS
CHECK 4 pointer-sweep
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
GATE RESULT: PASS (checks failed: 0)
rc=0
```

The `WORK_ROOT` line is the gate printing its own provenance; `WORK_ROOT_FREE` is the load-bearing
number, because it is what the r103 incident lacked. The scanner hash is `e5521304…` and the pinned
expectation in `gate/README.md` is `POINTERS=103 … UNRESOLVED=0` (moved `101 → 102 → 103` during this
round). **[O]**

---

## 9. Protected-path cross-check

```
$ git rev-parse HEAD
88c3b2ca70fc83ec47a931d7b6dcff85a111c04e
$ git status --porcelain
 M corpus/fixtures/phys3d_joints.gd
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? SKILL.md
?? reports/round-104/
$ git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
corpus/fixtures/phys3d_joints.gd
$ git status --porcelain reports/round-101 reports/round-102 reports/round-103 | wc -l
0
```

- **`LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md` are byte-identical to HEAD** (no diff).
  This is correct: the round is not yet report-last, so the ledgers must not have moved. **[O]**
- **`reports/round-101/`, `reports/round-102/`, `reports/round-103/` are untouched** (0 dirty). **[O]**
- **One protected path is modified: `corpus/fixtures/phys3d_joints.gd`.** This is the round's
  **licensed C1 edit** — the r104 template declares SEAT-04's scope as exactly this path, and
  `physics/sentinel.md` (SEAT-08) rules that no r104 design doc names `run_battery.py`, so the
  licensed edit set is this file alone. It is **not** an unlicensed edit; it is recorded here because
  it is a write into the `corpus/fixtures/**` tree. At this frame it is
  `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6`. **[O]**
- **`run_battery.py` is byte-identical to its r102 pin**:
  `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f`, 350 `CASES` rows. **[O]**
- **`SKILL.md` is a new untracked top-level file** (20 192 B, `de8ada36…` at this frame; it was
  18 759 B when first observed at `19:19Z`, so the C3 landing was still being revised during the
  round). It is outside every protected tree. **[O]**
- The pinned upstream tree and `.manifest.d/` are clean (`git diff --name-only HEAD` reports no path
  under them). **[O]**

---

## 10. C1 outcome, for the record (not this seat's claim to adjudicate)

The r103 ruling was that `phys3d_joints_free_ops` fails because 21 serial Godot boots × ~0.9 s
exceeds `CASE_TIMEOUT_SECONDS=20`. The r104 fix is R3 (concurrent children). This seat did not run
the battery, but the round's own receipt is present in the frame it froze:

```
$ tail -2 reports/round-104/physics/author-full-final.stdout
totals: cases=350 pass=336 fail=14 ordinary=291 negative_controls=59 probes=0
FAIL battery: …/physics/author-runs-full-final/20261018T193620808009Z/verdicts.json
$ grep -c '^FAIL r94_cannon' reports/round-104/physics/author-full-final.stdout
13
$ grep -c '^FAIL phys3d_joints_free_ops' reports/round-104/physics/author-full-final.stdout
0
```

The **before** side was re-read from the r102 receipt this seat's brief names, not taken on trust:

```
$ python3 -c "import json;d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'));\
print(d['totals']);print([x['case'] for x in d['results'] if x['verdict']!='PASS'])"
{'cases': 350, 'pass': 336, 'fail': 14, 'ordinary': 291, 'negative_controls': 59}
['phys3d_joints_free_ops', 'r94_cannon_det', 'r94_cannon_det2', 'r94_cannon_varstep',
 'r94_cannon_bailout', 'r94_cannon_nan', 'r94_cannon_sync', 'r94_cannon_material',
 'r94_cannon_friction', 'r94_cannon_parity', 'r94_cannon_parity2', 'r94_cannon_modes',
 'r94_cannon_order', 'r94_cannon_backends']
$ # the r102 free_ops row itself:
phys3d_joints_free_ops  FAIL  ['TIMEOUT after 20 seconds', 'no exit code (process killed or timed out)',
                                'exact stdout marker missing']  elapsed=20.008
```

**before `336 pass / 14 fail` → after `336 pass / 14 fail`** — the *same* totals, and the
**membership changed by exactly one swap**: `phys3d_joints_free_ops` (the r103 ruling's subject,
timed out at `elapsed=20.008 s`) left the fail list, and `bpy_rbw3d_render` entered it. The 13
`r94_cannon_*` node-marker misses are present in **both** lists — they are the carried defect, not a
regression. The counting command named in the round brief is exactly the `totals:` line above. **[O]**

---

## 11. How to re-measure this frame

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
date -u +%Y-%m-%dT%H:%M:%SZ
D=$( { find reports/round-104 -maxdepth 1 -type f
       find reports/round-104/gate -maxdepth 1 -type f
       find reports/round-104/physics -maxdepth 1 -type f
       find reports/round-104/physics/standalone -type f
       find reports/round-104/skill -type f
       find reports/round-104/lessons-carry-loop -type f; } | sort -u )
echo "$D" | grep -v 'reports-index.md' | wc -l       # expect 65 (this index file is a 66th)
echo "$D" | grep -v 'reports-index.md' | xargs sha256sum | sort -k2 | sha256sum   # expect 2f8588cf9b2d61cb…
echo "$D" | while read -r f; do
  seat=$(grep -o -m1 -E 'SEAT-[0-9]+' "$f" | head -1)
  printf '%s|%s|%s|%s\n' "$(sha256sum "$f"|cut -d' ' -f1)" "${seat:-—}" "$(stat -c%s "$f")" "$f"
done
```

**To confirm a frame is settled, repeat the durable tree-hash line until it prints the same value at
least four times in a row**, ~20 s apart. **Carry the file count in the same sample** — §7 shows a
`/tmp` quota failure can make the hash print the empty-string hash and look stable. **Then re-measure
once more *after* writing your draft**: §1.2's first freeze was 28 samples stable and still wrong,
because SEAT-07 landed a new artifact a minute later. The expected values for this document's frame
are `n=65` and `2f8588cf9b2d61cb…` over 1 275 496 B.

---

## 12. Summary

| question | verdict |
|---|---|
| Durable files at the frozen frame | **65** (`2026-10-18T20:07:58Z`), tree hash `2f8588cf9b2d61cb…`, 1 275 496 B. |
| Whole round | 21 945 files / 361 469 779 B — **99.70 % scratch** *[moving]*. |
| Is the frame settled? | **Yes** — tree hash identical across 16 samples / ~5.3 min, **after a superseded first freeze** (see §1.2). |
| Largest transient event | `scratch/s20-skel3/` = 247 314 files / 2.3 GiB, present `19:21:40Z`–`19:22:49Z`. |
| `rNN-<seat>.md` usage | **7** of 65 (r103: 6, r102: 7, r101: 15). Convention stable. |
| Subdir layout | **6** maxdepth-1 dirs; `skill/`, `lessons-carry-loop/`, `scratch/` are new. |
| Duplicate basenames (durable) | 1 intra-round (`author.md`); **19 cross-round** (r103: 7). |
| Byte-identical dups | 2 groups, both benign: ten identical `lessons-carry-loop/run*.out`; four empty `*.stderr`. |
| Executables | 1 — `gate/flake_harness.sh` (`bash -n` rc 0). |
| Protected trees | r101/r102/r103 and the four ledger files clean; **`corpus/fixtures/phys3d_joints.gd` modified — the licensed C1 edit**; `run_battery.py` at its r102 pin. |
| Gate | **verified by this seat** — `GATE_WORKDIR` honored, 4/4 `STEP=PASS`, `POINTERS=103`, rc 0. |
| `/tmp` quota | **reproduced live** by this seat's own sampler, 3×; can make a tree hash print the empty-string hash. |
| Round-close report present? | **Yes** — `r104-report.md` (SEAT-35, 60 124 B). |

**This seat's own artifact** is `reports/round-104/reports-index.md`. It is the only file this seat
wrote; it is untracked like the rest of the round. Its own sha256 is deliberately **not**
self-referenced — the table in §3 predates this file's final bytes, and a self-hash would be a stale
frame by construction. Re-measure with §11 if it matters.
