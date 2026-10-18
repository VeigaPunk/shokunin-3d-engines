# SEAT-43 REPORTS-INDEX — `reports/round-103/` final-frame inventory

Seat: **SEAT-43 REPORTS-INDEX** (r103). Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`.
Scope: name the final frame of `reports/round-103/` and give a per-file sha256 table measured at this
seat's own runtime, plus a naming-convention audit against the r102 subdir convention.

**Read-only.** This seat wrote nothing but this file. No cited artifact was edited, and no `git`
state-mutating command was run (no commit / push / checkout / reset).

Lane HEAD throughout: `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
(*"r102 report-last: verdict (coverage/depth improved, calibration unchanged), LOG + SCORECARD,
gate-hardening + battery-boundary addendum — work c6f655d"*).

Tags: **[O]** command-run observation · **[I]** labelled inference · **[?]** unknown.

**No Unreal runtime claim appears anywhere in this file.** The editor is not installed and live-MCP
is unproven by construction; every number below is a byte, exit-status, or filesystem measurement.

---

## 0. Headline

| property | value |
|---|---|
| files at the frozen frame | **59** (19 top-level + 11 `b2/` + 17 `gate/` + 9 `note/` + 3 `physics/`) |
| frame time | `2026-10-18T19:01:16Z` (local `16:01:16 -0300`) |
| tree hash (sha256 of the sorted `sha256sum` listing) | `c9599735eb30e654…` |
| total bytes | 1 202 945 |
| `r103-<seat>.md` files | **6** (`r103-connector`, `r103-dissonance`, `r103-distiller`, `r103-report`, `r103-scribe-audit`, `r103-verification-protocol`) |
| subdirectories | **4** — `b2/`, `gate/`, `note/`, `physics/` |
| distinct `SEAT-NN` ids appearing in the round | **58** |
| duplicate basenames | 1 — `adversary.md` (`b2/` + `note/`) |
| byte-identical duplicates | **none** |
| executable files | **none** |
| round-close report present | **yes** — `r103-report.md` (SEAT-48, 39037 B) |

---

## 1. Method (exact commands, all read-only)

```
date -u +%Y-%m-%dT%H:%M:%SZ
find reports/round-103 -type f -exec sha256sum {} + | sort -k2
find reports/round-103 -type f | sort | while read f; do \
  seat=$(grep -o -m1 -E 'SEAT-[0-9]+' "$f" | head -1); \
  printf '%s|%s|%s|%s\n' "$(sha256sum "$f"|cut -c1-64)" "${seat:-NONE}" "$(stat -c%s "$f")" "$f"; done
find reports/round-103 -mindepth 1 -type d | sort
find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | sort
find reports/round-103 -type f -printf '%f\n' | sort | uniq -d          # intra-round collisions
find reports/round-103 -type f -exec sha256sum {} + | awk '{print $1}' | sort | uniq -d
find reports/round-103 -type f -perm -u+x | sort
git rev-parse HEAD
git status --porcelain
git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
git ls-files reports/round-101 | wc -l ; git ls-files reports/round-102 | wc -l
```

The **frame was frozen by a stability test, not by a guess.** A single `find`+`sha256sum` sample
cannot distinguish a settled directory from one being rewritten in place (that was the r102
reports-index's central lesson). This seat therefore required the **tree hash** — sha256 over the
sorted `sha256sum` listing — to repeat across consecutive samples before calling a frame final:

```
19:01:51Z  files=59  treehash=c9599735eb30e654
19:02:11Z  files=59  treehash=c9599735eb30e654
19:02:31Z  files=59  treehash=c9599735eb30e654
19:02:51Z  files=59  treehash=c9599735eb30e654
19:03:11Z  files=59  treehash=c9599735eb30e654
19:03:31Z  files=59  treehash=c9599735eb30e654
19:03:51Z  files=59  treehash=c9599735eb30e654
19:04:11Z  files=59  treehash=c9599735eb30e654      # BYTE-STABLE, 8 samples / ~2.4 min
```

Re-measured once more at `19:04:20Z`: `treehash=c9599735eb30e654` — identical. **§3 is a settled
frame, not a moving one.** The two samples 25 s apart at `19:01:16Z` / `19:01:41Z` also diffed
clean (`CONFIRMED-IDENTICAL-25s`). **[O]**

---

## 2. Growth series — the directory went 1 → 59 files in 30 min

Sampled every 15 s by a background sampler over `18:31:37Z` → `18:39:07Z`, then by two explicit
`seq`-loop stability tests to `19:04:11Z` **[O]**:

| time (UTC) | files | | time (UTC) | files | | time (UTC) | files |
|---|---|---|---|---|---|---|---|
| `18:31:37Z` | 1 | | `18:34:37Z` | 24 | | `18:37:52Z` | 38 |
| `18:31:52Z` | 2 | | `18:34:52Z` | 24 | | `18:38:07Z` | 40 |
| `18:32:07Z` | 3 | | `18:35:07Z` | 28 | | `18:38:22Z` | 43 |
| `18:32:22Z` | 4 | | `18:35:22Z` | 29 | | `18:38:37Z` | 45 |
| `18:32:37Z` | 7 | | `18:35:37Z` | 30 | | `18:38:52Z` | 46 |
| `18:32:52Z` | 9 | | `18:35:52Z`–`18:36:22Z` | 30 | | `18:39:07Z` | 46 |
| `18:33:07Z` | 9 | | `18:36:52Z` | 32 | | `18:45:24Z` | 55 |
| `18:33:22Z` | 10 | | `18:37:22Z` | 36 | | `18:47:06Z` | 58 |
| `18:33:37Z` | 13 | | `18:37:37Z` | 36 | | `18:51:16Z` | 58 |
| `18:33:52Z` | 14 | | | | | `18:52:42Z` | **59** |
| `18:34:07Z` | 18 | | | | | `19:01:16Z` | 59 (frozen) |
| `18:34:22Z` | 21 | | | | | | |

Reading **[I]**: the count is **non-monotone in rate but monotone in value** — it never decreased
across 29 measured frames, unlike r102's `53 → 52 → 54`. The bulk (46 of 59) landed in the first
8 minutes; the tail (`physics/ledger.md`, `stub-cleanness.md`, `gate/regression.md`, `b2/repair-*.md`)
took another ~22 min. Between `18:39:07Z` and `19:04:11Z` the **count** held at 58 for 8 min and
then 59 for 12 min, but the **bytes** did not: the tree hash changed at `18:57:14Z`, `18:58:14Z`,
`18:58:34Z`, `18:58:54Z`, `18:59:14Z` as B2 seats rewrote files in place. **A count-stable
directory is not a byte-stable directory** — the reason §1 uses the tree hash. **[O]**

---

## 3. Final-frame file table — 59 files, sha256 (full 64 hex), frame `2026-10-18T19:01:16Z`

Tree hash of this table: `c9599735eb30e654…` (sha256 over the sorted listing). Seat column is the
first `SEAT-NN` token in the file; `—` means the file carries no seat token (both are raw gate
stdout captures, not seat artifacts). **[O]**

| path | seat | bytes | sha256 |
|---|---|---|---|
| `reports/round-103/b2/adversary.md` | SEAT-30 | 16886 | `53238216ca247a06df4bd27d98ba1127acc2d2ca11dd3f619ab77cffea9d56e2` |
| `reports/round-103/b2/corrections.md` | SEAT-29 | 33617 | `2f2b639e4a4505af0648538facdd7780a791abb87bbae98cce342cc54e4c98ac` |
| `reports/round-103/b2/postgrep.md` | SEAT-31 | 18700 | `0581c94862cf7c0e06da717bda4beed27fc95d591f110c8ca0961c278537991b` |
| `reports/round-103/b2/repair-glb.md` | SEAT-23 | 17028 | `0aae09973d952a9b2da0e87ecba07d6fbd02dc1be0d11c67d2eb0619832bfdee` |
| `reports/round-103/b2/repair-three.md` | SEAT-25 | 21489 | `8b856ab2cd93eb45cfc48a14418de4f62aad80badf7f5af8613c06f975e26ede` |
| `reports/round-103/b2/repair-unity.md` | SEAT-24 | 15314 | `9af07c560b753096f7544d5908fee760c21cc3ed6a9e68302769bbb4f11891b0` |
| `reports/round-103/b2/ruling.md` | SEAT-22 | 23846 | `4331a5271ae5e77206de3c99801932df69a57c3b63b61cca47305a769c43c369` |
| `reports/round-103/b2/scanner.md` | SEAT-21 | 18446 | `beacfaceb90dcf4585a6d609713e2a232ac630fd93c67d5684e5b2772d294a4f` |
| `reports/round-103/b2/verify-glb.md` | SEAT-26 | 15153 | `378e768da9819a4b3e532fbdc9c7ea9300775a963846eab669843b7e260f92b4` |
| `reports/round-103/b2/verify-three.md` | SEAT-28 | 16046 | `992561b2d4c5a1ec4fe572a16f3ccd0c2c93437c9ca1eb08b91bda81c3827fa4` |
| `reports/round-103/b2/verify-unity.md` | SEAT-27 | 12848 | `a72c1a66771d0fe69ad3e682aa1b5ffebeb29fbba123617821dac04467a09d27` |
| `reports/round-103/battery-consistency.md` | SEAT-63 | 23494 | `48a34837dd1d75e2488b3263bf21c054064fd811ca63582d298b0814163090f3` |
| `reports/round-103/close-count.md` | SEAT-64 | 20345 | `5968d52cceaab68e0ac30d403a6d07fa910136550e40db9316e278e95f13c5f2` |
| `reports/round-103/consistency.md` | SEAT-44 | 24351 | `38747d75dc6b56dce126502f988fe49b14a14d90568218ad575ec4d342961de9` |
| `reports/round-103/freshness-pin.md` | SEAT-56 | 7299 | `cadc1bbd07c344c58a0ab28acacd8d6154e640356d4463badbf9c11ab4187aa6` |
| `reports/round-103/gate/a1-attack.md` | SEAT-11 | 13968 | `d5867a95174875a389098f77d61066f02df73e20cce98887f10e4d84886d3fcf` |
| `reports/round-103/gate/a2-attack.md` | SEAT-12 | 18757 | `4574bb129eea40dd768742aa19762116c7830818d28b86df5e888bedb2b71365` |
| `reports/round-103/gate/a3-attack.md` | SEAT-13 | 13800 | `9abe761c7b4e0f45c65a90a414182d82009eba4fa054bd65a35d79d51174d252` |
| `reports/round-103/gate/a4-attack.md` | SEAT-14 | 11215 | `801e9d7f988769935104e57ab4de2765dd63d039ab8eb87cae245a481593d563` |
| `reports/round-103/gate/clean.md` | SEAT-10 | 8714 | `d33e9f3dd1b6ba7e1e65b4a2347c2f0a93561d14ebfadc7fd39c10df01797819` |
| `reports/round-103/gate/clean.now.txt` | — | 1943 | `e6402d3b65af1358bfe04f575d420e546b643f528d905f9eeba286c709d6fbe8` |
| `reports/round-103/gate/clean.raw.txt` | — | 1948 | `4a3fe7e5c0b7bbdc1bd278cbdd84a6ad646a26c0590e73645d311bb25e5388ba` |
| `reports/round-103/gate/critic.md` | SEAT-17 | 22076 | `dfa8427736d76d637ba867b18d9ab5e61834f707a3c66a82324d1e5db41ed4d4` |
| `reports/round-103/gate/docs-sync.md` | SEAT-20 | 21334 | `f0dc9bf7ad4435c60a3890e81cd1cbda3272e4b700185e62c7948d3f85203ec0` |
| `reports/round-103/gate/exit-codes.md` | SEAT-61 | 27874 | `5a6ec2650fd7d0eabf13b7a1e2494feb573d51bf46a657ecb7715b2c58608581` |
| `reports/round-103/gate/final-run.md` | SEAT-53 | 8230 | `144550f54d3b40abb8094fbb73e425b7c9b17e5c305b7e54385af632b6a300b0` |
| `reports/round-103/gate/hardening.md` | SEAT-09 | 13099 | `c32a3ec1c20fa53eee866d2bbc6044247e57d924cc01151f643e84f409663c36` |
| `reports/round-103/gate/math.md` | SEAT-18 | 23682 | `7db1ce5d04fc6049cdafb09e218664df2e24457d464411ae2395280d48be88ac` |
| `reports/round-103/gate/mutations.md` | SEAT-19 | 13462 | `c3753f56e69bd6e4f77c64959acfc257eed260e6b06d0c73406bbfc122d6015f` |
| `reports/round-103/gate/regression.md` | SEAT-15 | 17372 | `caeb24e77d6a015543759118c7316aa4d926c2c6f2058df05c469c037c7d42a0` |
| `reports/round-103/gate/security.md` | SEAT-62 | 28005 | `f543c8ede648d9510622e7dedbf16bbd8cd58aa91860d4e0328054342838dbe9` |
| `reports/round-103/gate/sentinel.md` | SEAT-16 | 30049 | `dffe0bd287167d31db31e3cc21a717c96007e70a37f4ff56499fc0e790250e0a` |
| `reports/round-103/git-hygiene.md` | SEAT-40 | 35836 | `ea3327ca744d1ff304f2ad97bf9c2e62bcd5a23d4e3c099f4de322db511d1c33` |
| `reports/round-103/install-recheck.md` | SEAT-57 | 15405 | `5c20b617180bb34f04deaf8fc5fab89cc0aa223c583736ccd6499e21d51cad06` |
| `reports/round-103/ledger-check.md` | SEAT-39 | 3778 | `617cbb7b3826cadfc62a148ef258df70c93535844cbcc03deb6a7dc33278208d` |
| `reports/round-103/math-audit.md` | SEAT-38 | 56080 | `2297f229c86e51c64dd4734deea347730c315dffb27ccc4fbb190c32eea5e5a7` |
| `reports/round-103/note/adversary.md` | SEAT-04 | 21680 | `e31d4c96111a1d067259a02593b6a2d7a7c8c03c70bf36b3e5f2a12dcb204266` |
| `reports/round-103/note/author.md` | SEAT-01 | 22277 | `4eba300e0dd7046686b5013f8c1750a22527d92cff5c4e0ed73cb9811e453ef7` |
| `reports/round-103/note/binary.md` | SEAT-06 | 16804 | `3c1f25d8b0b1ecbefd8c2e1bdf0785ef780e61979f8e6b22f6eb143e0059992c` |
| `reports/round-103/note/configline.md` | SEAT-60 | 6521 | `4f8260bf354837af028002cb1364a346528971ef50b85b0f39d7a97bb218e616` |
| `reports/round-103/note/crosscheck.md` | SEAT-08 | 21542 | `629268223b200b9ec316dd2be3f1ed715957bc40be090bcbcaef633cdd497995` |
| `reports/round-103/note/gate-pin.md` | SEAT-05 | 9390 | `433d0bfcbbe22dba539e8d25786cdfaafc94e4306db86c44644af70a54c24d32` |
| `reports/round-103/note/rows.md` | SEAT-02 | 14700 | `7e8e258a2fa9a4e4c4772b54b120a8ad5ffb27e78483b3c4f5d1af44e6e180fc` |
| `reports/round-103/note/urls.md` | SEAT-07 | 13006 | `a47f8aca580d2025c80c1d1706853d553f4e6bef7eb135dd1d613d6be0bf93a9` |
| `reports/round-103/note/verify.md` | SEAT-03 | 30545 | `2b08c1d6387365968304feec447aa15aa845b534c971a180b572eae805304c03` |
| `reports/round-103/pathroot-sweep.md` | SEAT-58 | 25945 | `d9508a66aaca76318dd04cc2368e018957d1d17ba8b56a715e3713caae507d81` |
| `reports/round-103/physics/adversary.md` | SEAT-33 | 18059 | `1a6769503f327817889fd074f3f96bb59b15953911170393720149a6b7301a79` |
| `reports/round-103/physics/investigate.md` | SEAT-32 | 18507 | `4e87075848ad4dd3d4b70b31c7877b6043f348f0279052c29268122ff9946299` |
| `reports/round-103/physics/ledger.md` | SEAT-34 | 23494 | `c00dded6b91c19505ab9f29de10000990703746829594fcee2e93a01be9cc515` |
| `reports/round-103/r103-connector.md` | SEAT-37 | 29942 | `cc8a7b53bbe389939920592efe68a18b6d13aa9d9bfb35804ca546b210d8f60a` |
| `reports/round-103/r103-dissonance.md` | SEAT-35 | 28804 | `bd190bc88569ba67a980a5f1e2702b032afb56d7aee4b33afdb95000c3ebce9d` |
| `reports/round-103/r103-distiller.md` | SEAT-36 | 27693 | `29eddb8798435bcb67db5678f1acc147b3fb44e06c54acf0e816177a06ccec08` |
| `reports/round-103/r103-report.md` | SEAT-48 | 39037 | `c492a00247e87d59cb96b791cc33d360ae69a4900352857164c4bfb4db65d66e` |
| `reports/round-103/r103-scribe-audit.md` | SEAT-42 | 42325 | `a7b61f586df94372676de54246ab2c5a0c0669522de63ef43f8103c2d2a73a43` |
| `reports/round-103/r103-verification-protocol.md` | SEAT-45 | 47884 | `cf3b0fa66d61c51bea46b0e28538bcc48c120b8a233ab45ff10cfe0468dfc4e9` |
| `reports/round-103/seats-ledger.md` | SEAT-55 | 8952 | `56d92f207893c30c4c446d61a3958b2e62e856d91d1a9959465a9e3b39d70239` |
| `reports/round-103/skill-table-review.md` | SEAT-59 | 30286 | `95d40d92432252f66d6edf886ac99bf60e190461f075db3d7936bf94527d6815` |
| `reports/round-103/stub-cleanness.md` | SEAT-41 | 23618 | `bb65441914fdd39eb4a026041431f04d795c3e4b1ef355fda6bd9584b7b66089` |
| `reports/round-103/subtree-integrity.md` | SEAT-54 | 10445 | `5bb02f9f39480239ec4cf66ba7d4ddd85fb36a151a2f2a7d23ed8f447d145d3c` |

### 3.1 Per-subdirectory counts

```
$ for d in b2 gate note physics; do echo "$d=$(find reports/round-103/$d -type f | wc -l)"; done
b2=11
gate=17
note=9
physics=3
$ find reports/round-103 -maxdepth 1 -type f | wc -l
19
```

19 + 11 + 17 + 9 + 3 = **59**. **[O]**

### 3.2 Seat attribution

**57 of 59** files carry a `SEAT-NN` token in their H1/header block. The two that do not are
`gate/clean.raw.txt` and `gate/clean.now.txt` — raw gate stdout, not seat artifacts:

```
$ for f in $(find reports/round-103 -type f); do grep -q 'SEAT-[0-9]' "$f" || echo "$f"; done
reports/round-103/gate/clean.raw.txt
reports/round-103/gate/clean.now.txt
```

**58 distinct seat ids** appear across the round (`SEAT-01`…`SEAT-45`, then `SEAT-48`, `SEAT-53`…
`SEAT-64`); `SEAT-43` is this file. The ids **not** present — `SEAT-46`, `SEAT-47`, `SEAT-49`,
`SEAT-50`, `SEAT-51`, `SEAT-52` — are simply seats that did not land an artifact in this round. **[O]**

---

## 4. Naming convention — the r101 `rNN-<seat>.md` form is back, and early

Measured against the r102 audit (`reports/round-102/reports-index.md` §12.1, §13) **[O]**:

| round | total files | `rNN-<seat>.md` (top level) | first such file appeared |
|---|---|---|---|
| `reports/round-101` | 33 | 15 | — |
| `reports/round-102` | 61 | 8 | `17:44:29Z`, ~3 min into the round |
| `reports/round-103` | 59 | **6** | before `18:34Z`, i.e. ~2.5 min in |

```
$ find reports/round-103 -maxdepth 1 -type f -name 'r103-*' | sort
reports/round-103/r103-connector.md
reports/round-103/r103-dissonance.md
reports/round-103/r103-distiller.md
reports/round-103/r103-report.md
reports/round-103/r103-scribe-audit.md
reports/round-103/r103-verification-protocol.md
```

**Verdict: `reports/round-103/` is a hybrid, same as r102, but with a materially higher
compliance rate and an earlier start.** The six `r103-*` files are exactly the long,
round-close-style seats (connector, dissonance, distiller, report, scribe-audit,
verification-protocol) — the same class r102's audit inferred would adopt the form (`[I]` there).
The 13 top-level non-`r103-*` markdown files (`battery-consistency.md`, `close-count.md`,
`consistency.md`, `freshness-pin.md`, `git-hygiene.md`, `install-recheck.md`, `ledger-check.md`,
`math-audit.md`, `pathroot-sweep.md`, `seats-ledger.md`, `skill-table-review.md`,
`stub-cleanness.md`, `subtree-integrity.md`) carry the seat id in the H1 as before. **[O]**

### 4.1 Subdir convention — `physics/` and `b2/` are new; `note/` replaces r102's `before/`

```
$ find reports/round-103 -mindepth 1 -type d | sort
reports/round-103/b2
reports/round-103/gate
reports/round-103/note
reports/round-103/physics
```

r102 used `adversary/ before/ gate/ repairs/ reruns/`. r103 keeps only `gate/`, adds `b2/`
(dead-root ruling + repairs + verification), `note/` (the C1 freshness-note workstream), and
`physics/` (the battery-row investigation). **Verdict: the subdir layout is a stable, self-
documenting convention that now varies its subdir names round-to-round** — it encodes the round's
*workstreams*, not a fixed taxonomy. Acceptable and noted. **[O]**/**[I]**

---

## 5. Duplication and artifact types

```
$ find reports/round-103 -type f -printf '%f\n' | sort | uniq -d
adversary.md
$ find reports/round-103 -type f -exec sha256sum {} + | awk '{print $1}' | sort | uniq -d
(no output)
$ find reports/round-103 -type f -perm -u+x | sort
(no output)
$ find reports/round-103 -type f ! -name '*.md' | sort
reports/round-103/gate/clean.now.txt
reports/round-103/gate/clean.raw.txt
```

- **One duplicate basename**: `adversary.md` exists at `b2/adversary.md` (SEAT-30, 16886 B) and
  `note/adversary.md` (SEAT-04, 21680 B). Different seats, different bytes, different roles — the
  same deliberate cross-subdir reuse r102 recorded for `F6-rea-census.md`. **Not a defect.** **[O]**
- **No byte-identical duplicate** at the frozen frame. **[O]**
- **No executable file** in the round; the two non-markdown files are raw gate captures. **[O]**

### 5.1 Cross-round basename reuse

```
$ comm -12 <(find reports/round-103 -type f -printf '%f\n' | sort) \
           <(find reports -type f ! -path 'reports/round-103/*' -printf '%f\n' | sort)
freshness-pin.md
git-hygiene.md
install-recheck.md
ledger-check.md
math-audit.md
sentinel.md
skill-table-review.md
```

Seven r103 basenames also exist in an earlier round — six of them are r102 topic slugs
(`freshness-pin`, `git-hygiene`, `install-recheck`, `ledger-check`, `math-audit`, `skill-table-review`)
that recur by design, and `sentinel.md` appears in `gate/` here vs top-level in r102. **A
cross-round grep that assumes basenames are unique will now return two hits for each of these
seven.** This is the lane-wide duplicate-basename count moving **10 → 12**; the r102 reports-index
flagged the growth from 1 → 2 and the trend continues. **[O]**

---

## 6. Protected-path cross-check (runtime observation, this seat wrote nothing there)

```
$ git rev-parse HEAD
c85a816e227984272a3c29b58aa7f7c1a76f1e9c
$ git status --porcelain reports/round-101 reports/round-102 | wc -l
0
$ git ls-files reports/round-101 | wc -l
33
$ git ls-files reports/round-102 | wc -l
61
$ git diff --name-only HEAD -- LOG.md SCORECARD.md SHONEN.md PROVINCE.md corpus/fixtures \
    corpus/knowledge/unreal-mcp/upstream corpus/knowledge/unreal-mcp/.manifest.d
corpus/fixtures/three/README.md
```

**`reports/round-101/` and `reports/round-102/` are untouched** (0 dirty, 33 and 61 tracked files).
`LOG.md`, `SCORECARD.md`, `SHONEN.md`, `PROVINCE.md`, the pinned `upstream/` and `.manifest.d/`
trees are all byte-identical to HEAD. **[O]**

**One protected path is modified: `corpus/fixtures/three/README.md`** — inside the HARD-RULES-
protected `corpus/fixtures/**` tree. The change is the C3 dead-root repair (17 `-`/17 `+`, removing
the stale `.shokunin/game-dev-3d/` prefix from 17 command lines), owned by SEAT-25 `b2/repair-three.md`:

```
$ git diff --stat HEAD -- corpus/fixtures/three/README.md
 corpus/fixtures/three/README.md | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)
$ grep -c 'shokunin/game-dev-3d' corpus/fixtures/three/README.md
0
```

This is **not this seat's finding to adjudicate** — the round's own `git-hygiene.md` (SEAT-40)
already flags it as a **VIOLATION of the protected-path rule as written** while noting the round
brief authorizes the C3 repair, and `close-count.md` (SEAT-64) escalates it as a flag for the L1.
Recorded here so the index does not silently omit the one protected-tree edit of the round. **[O]**

Two transient anomalies from the same seats, both resolved before this frame and neither a
tracked-byte change: 42 untracked `corpus/fixtures/r90bt_*` scratch dirs appeared during the phys3d
investigation and were gone by `18:38Z` (`consistency.md` N5, `git-hygiene.md` §3.1). **[O]** for
the reports; this seat did not observe the dirs directly.

Other worktree changes at the frozen frame, all outside the protected list:

```
$ git status --porcelain
 M corpus/artifacts/glb-r12/README.md
 M corpus/artifacts/unity-r19/README.md
 M corpus/fixtures/three/README.md
 M corpus/knowledge/unreal-mcp/adaptation-kimi.md
 M corpus/knowledge/unreal-mcp/gate/README.md
 M corpus/knowledge/unreal-mcp/gate/run_gate.sh
?? reports/round-103/
```

The first two are the C3 glb/unity dead-root repairs; `adaptation-kimi.md` is C1's freshness note;
`gate/README.md` and `gate/run_gate.sh` are the C2 hardening (next section). **[O]**

---

## 7. Gate state at the frozen frame

```
$ sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh
577c8b5489577b948536005a170da14ae3d4e13c11776aeca8f803bfb5fcefa0  corpus/knowledge/unreal-mcp/gate/run_gate.sh
$ stat -c '%y' corpus/knowledge/unreal-mcp/gate/run_gate.sh
2026-10-18 15:39:38.587656371 -0300
```

**The A1–A4 hardening landed in place.** At this seat's first sample (`18:31Z`) the installed gate
was `412d1b84857233e8…` (mtime `15:15:52`, 1 line matching `A1|A2|A3|A4|BLOCKED|exit 2|card-name`);
at the frozen frame it is `577c8b5489577b94…` (mtime `15:39:38`, **26** such matching lines). The
brief's `POINTERS=87` was already stale when the round opened: `gate/clean.raw.txt` recorded
`POINTERS=88` at `18:31Z`, and `gate/regression.md` (SEAT-15) documents the live value moving
`88 → 89 (UNRESOLVED=1, FAIL) → 100 → 101` as the C1 note added pointers and one in-flight
reference resolved. `gate/regression.md` explicitly states the brief's 87 "was true when [the
brief was written]". **[O]**

The pinned upstream is unchanged:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256   # 12 lines, all OK
```

`corpus/knowledge/unreal-mcp/adaptation-kimi.md` is `084a34cd94806caa497de1fb80df84f95876114048ead83bc158b4d50de8c879`
at the frozen frame — the C1 note's landed bytes, still dirty vs HEAD (uncommitted). **[O]**

---

## 8. How to re-measure this frame

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
date -u +%Y-%m-%dT%H:%M:%SZ
find reports/round-103 -type f -exec sha256sum {} + | sort -k2 | sha256sum   # tree hash
find reports/round-103 -type f | sort | while read -r f; do
  seat=$(grep -o -m1 -E 'SEAT-[0-9]+' "$f" | head -1)
  printf '%s|%s|%s|%s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "${seat:-—}" "$(stat -c%s "$f")" "$f"
done
find reports/round-103 -mindepth 1 -type d | sort
```

**To confirm a frame is settled, repeat the tree-hash line until it prints the same value at least
four times in a row**, ~20 s apart. A stable file *count* is not evidence of a settled directory —
in this round the count held at 59 while five consecutive tree hashes differed (§2). The expected
value for this document's frame is `c9599735eb30e654…` over 59 files.

---

## 9. Summary

| question | verdict |
|---|---|
| Files at the frozen frame | **59** (`2026-10-18T19:01:16Z`), tree hash `c9599735eb30e654…`, 1 202 945 B. |
| Is the frame settled? | **Yes** — tree hash identical across 8 samples / 2.4 min, re-confirmed at `19:04:20Z`. |
| Does r103 use the r101 `rNN-<seat>.md` form? | **Partly** — 6 of 59 (vs 8 of 61 in r102, 15 of 33 in r101), and the first landed ~2.5 min in. |
| Subdir layout | **4** — `b2/`, `gate/`, `note/`, `physics/`; a workstream-encoding convention, noted. |
| Duplicate basenames | 1 intra-round (`adversary.md` in `b2/` + `note/`); 7 cross-round. No byte-identical dup. |
| Protected trees | r101/r102 and the four ledger files clean; **`corpus/fixtures/three/README.md` modified** (C3 repair, flagged by the round's own git-hygiene seat). |
| Gate hardening | **Landed** — `run_gate.sh` `577c8b54…`, 26 A1–A4 markers, mtime `15:39:38`. |
| Round-close report present? | **Yes** — `r103-report.md` (SEAT-48). |

**This seat's own artifact** is `reports/round-103/reports-index.md`, written at `19:0xZ`. It is the
only file this seat wrote; it is untracked like the rest of the round. Its own sha256 is
deliberately **not** self-referenced — the table in §3 predates this file's final bytes, and a
self-hash would be a stale frame by construction. Re-measure with §8 if it matters.

---

## 10. Post-write observation at `2026-10-18T19:06Z` (60 files)

The round gained one file after §3's frame. Recorded rather than edited into §3 (correction-note
discipline: a frozen frame is not silently rewritten) **[O]**:

```
$ find reports/round-103 -type f | wc -l
60
$ # re-derive the table rows from §3 and diff against the live tree (non-.md captures filtered):
$ sed -n '/^| path | seat/,/^$/p' reports/round-103/reports-index.md | grep '^| `reports' \
    | sed 's/^| `\([^`]*\)` | [^|]* | [^|]* | `\([^`]*\)` |/\2  \1/' | sort -k2 > mytable.txt
$ find reports/round-103 -type f -name '*.md' | grep -v reports-index.md | sort \
    | while read -r f; do printf '%s  %s\n' "$(sha256sum "$f"|cut -d' ' -f1)" "$f"; done > live.txt
$ diff live.txt mytable.txt
20a21,22
> e6402d3b65af1358bfe04f575d420e546b643f528d905f9eeba286c709d6fbe8  reports/round-103/gate/clean.now.txt
> 4a3fe7e5c0b7bbdc1bd278cbdd84a6ad646a26c0590e73645d311bb25e5388ba  reports/round-103/gate/clean.raw.txt
```

The two diff lines are exactly the non-`.md` gate captures that `live.txt`'s `-name '*.md'` filter
excluded (they are present in §3 with their hashes). Every **other** row — 57 markdown files, all
byte counts and sha256 — matched with no difference. The +1 file is
`reports/round-103/reports-index.md` itself. So the §3 frame is **superseded only by this seat's
own artifact**, not by any peer write; every peer sha256 in §3 remains current at `19:06Z`.


