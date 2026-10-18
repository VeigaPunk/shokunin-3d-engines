# SEAT-37 REPORTS-INDEX — r105 observed SHA-256 frame

Seat: **SEAT-37 REPORTS-INDEX**. Scope: per-file SHA-256 inventory of `reports/round-105/`; this is the only path written by this seat.

## Frame status: not frozen

At `2026-10-18T20:47:59Z`, the non-scratch inventory contained **52 files / 1,233,028 bytes**. The tree hash (SHA-256 of the sorted `sha256sum` listing) was `44e952d839f9e9431c426e1ababa87a64648f9fca61bba6aca1c6733ac992599`.

This is a measured **pre-close snapshot, not a final frame**. The same scan changed from `50 files / 1,218,915 bytes / e359864b9cde5168…` at `20:47:30Z` to `50 / 1,219,264 / e9b85f6c504b5e75…` at `20:47:35Z`; it remained identical at `20:47:40Z`, but the `20:47:59Z` scan had 52 files. Also, the Node 24 rerun receipt `n24/runs/node24-full-rerun-20261018T204240Z.stdout` had grown from 9,881 bytes at `20:47:16Z` to 10,377 bytes at `20:47:59Z`; its last read at `20:47:40Z` ended at output line 202, with no terminal totals. Re-measure this index after the run and peer writes finish; do not treat the table below as round-close evidence.

The inventory excludes files with a `scratch` path component and excludes this index itself. The read-and-hash procedure used for the frame was:

```python
root = Path('reports/round-105')
paths = sorted(p for p in root.rglob('*')
               if p.is_file() and 'scratch' not in p.relative_to(root).parts
               and p.name != 'reports-index.md')
rows = []
for path in paths:
    data = path.read_bytes()
    rows.append((path.as_posix(), len(data), sha256(data).hexdigest()))
listing = ''.join(f'{digest}  {path}\n' for path, _, digest in rows)
sha256(listing.encode()).hexdigest()
```

Observed output summary: `frame_utc=2026-10-18T20:47:59+00:00`, `files=52 bytes=1233028`, `tree_sha256=44e952d839f9e9431c426e1ababa87a64648f9fca61bba6aca1c6733ac992599`.

## Per-file table — observed frame only

| path | bytes | sha256 |
|---|---:|---|
| `reports/round-105/freshness-pin.md` | 2047 | `3ad7d62ade425f3dc39df7cac631e02f2fab24f188367427cfdc9643f0c1b3a2` |
| `reports/round-105/gate/final-run.md` | 3298 | `386ce88c7434c62818129b9be87279f5e8a465d2336a2d6146605e0ec1f1750e` |
| `reports/round-105/gate/integrity.md` | 3236 | `85a009baf5a2cf1cf9da78a1a974b2c72e847228ff8caeee80a06916ead5f35d` |
| `reports/round-105/gate/pin-after-edits.md` | 1460 | `7ce6451b3b8b1ff9a4985fb1b7290a49cc40a5554fd0528e4273a0a23113511d` |
| `reports/round-105/git-hygiene.md` | 13943 | `b528792b9a50fd6e5d4ca0ca4f90f20540568895175d263a41af95b8feb784c7` |
| `reports/round-105/install-recheck.md` | 7206 | `b4993865458293cbbf1db2cdc7b0f2d00d31b14d47eb15123854d8105ace479c` |
| `reports/round-105/kimi404/author.md` | 1113 | `d036084e78f90798a9a810983c3d9e60f080b5fc205d2049048a40d8dd4759f6` |
| `reports/round-105/kimi404/verify.md` | 1321 | `4c896021af6742dc63039d420edfee5db8e4821edda8e92531fd00fabdd0002e` |
| `reports/round-105/ledger-check.md` | 2771 | `8a75e4a0976d0fe2937ec81d2b4debc43238a355e35b2822e78d5192b42870f1` |
| `reports/round-105/ledger-math.md` | 6282 | `5c07573b8dd8d6d577da411f55305cf3cb81a2aa60d8f54bc1cbe442d459820d` |
| `reports/round-105/lesson/bleed.md` | 4778 | `36e0e5834b7fb0e0025c90aa1e8624ed4405d29fbfbad21d677378ba1438b90e` |
| `reports/round-105/lesson/critic.md` | 4830 | `cdda21978db33fd3c777415954647c87b2d9a817b5108ddba36389dd24af194b` |
| `reports/round-105/lesson/verify.md` | 5468 | `73df0c76721970db233c300c6134b6645474d826dd5db892342d5f9998e61816` |
| `reports/round-105/math-audit.md` | 10864 | `65a85a704905256a9a12424cfdda2ce234aaed851bf36373d8ec5ff7d8a74578` |
| `reports/round-105/n24/adversary.md` | 5366 | `59e7ff2c5dc4eefa6f245abe1366579e3c3387297647329cccaee5d59546c0c5` |
| `reports/round-105/n24/fingerprint.md` | 5466 | `3e8e7f01cbe9343fd209b99f23b5196643671b96633912091258d79e1d54f061` |
| `reports/round-105/n24/markers.md` | 6251 | `2639553e4de11bea3fe52460568b25b49470a9fccd2126f512e8bdf3f0a5d7ae` |
| `reports/round-105/n24/pre-state.md` | 3159 | `864143188ef06afddad35d6ab70bf3ea22dd70e05168601e5597465a9ee38cb2` |
| `reports/round-105/n24/revert.md` | 2278 | `aa4f06735f756682d776786dbd469d807ef02cc329b128211d227fc2e10557cc` |
| `reports/round-105/n24/runbook-critic.md` | 1633 | `c25c4d8075d97a6479936de16f39cd68d9ab23c52e97e1bbfd70d192ad1ec609` |
| `reports/round-105/n24/runbook.md` | 3184 | `62511ce5678b406f5f67e48cf1f82e80cb86ab14865e14b57dba1d44e694067e` |
| `reports/round-105/n24/runs/node24-full-20261018T202944Z.stdout` | 55349 | `adf138203fa5898f5e839602ea15812e56f7ff1efcef5968cbf70d92f2793999` |
| `reports/round-105/n24/runs/node24-full-20261018T202944Z.verdicts.json` | 854742 | `cca760d3f12d753e126adb759eeefc6923b6c5b80bab91893114c5e28bd5d0d5` |
| `reports/round-105/n24/runs/node24-full-rerun-20261018T204240Z.stdout` | 10377 | `7f76f1d715ffbc18f9b59660d9cd0f7c618c216cd86f6792ddc0e4521319cb0b` |
| `reports/round-105/n24/sentinel.md` | 3642 | `b1240a561d5fcd2697547046c10f9eed9e16b68794cf2b8336288282b8743b3d` |
| `reports/round-105/n24/single-confirm.md` | 2566 | `6eef8f9e1780ca6fd0491d6e5f81d95f0b6cf5df2f90cd4adea6e65e4effa998` |
| `reports/round-105/operator-package.md` | 5026 | `83124766c85c14c381cb8c41c50fe5c15ce2ea2dfed37658e642c1e97a967d3a` |
| `reports/round-105/pc/analyst-1.md` | 8355 | `bb29882b33ed7a1deb42fbf229fa76479d8794ac865c60cec06cdacce3f89733` |
| `reports/round-105/pc/analyst-2.md` | 12872 | `17c5d6550b09e5a16f4d502d986aef13f09ce114e90f5ccb668466ef8540c624` |
| `reports/round-105/pc/cards.md` | 6505 | `268b7e1e13b0c9f2460151c5e96e11636d8e0d33cc4d6b24dd9fae9f0a3f119f` |
| `reports/round-105/pc/distiller.md` | 15650 | `d337efd2dd32bd853e91497b5e08b51ffc48c7ff695a01af9ecec2914df55e24` |
| `reports/round-105/pc/history.md` | 5629 | `53728d6ee565343290db3b3d5e98b9514d947ec2c164dc0a66112b3bf1131ac8` |
| `reports/round-105/pc/impact.md` | 13101 | `dd5c0e9891fc51e10dad869b52bb1f7b45597fbe59d57a55eabd5f73b390501f` |
| `reports/round-105/pc/ledger.md` | 9537 | `84a47a1ff8879638140d89862824862c603d3399f0a597dc3f7fc40275c6e439` |
| `reports/round-105/pc/review-1.md` | 9280 | `e901b7e8ad1d254f8acff8893abb18c5d5d26de25a9018e0d1eacac726a1f713` |
| `reports/round-105/pc/review-3.md` | 11627 | `18dd43ddc193bef42cbd00575eb1c6df41e20c24f00ea4159d650cb764426ded` |
| `reports/round-105/pc/ruling-draft.md` | 16786 | `0dc0340a35a028944765ad855aaf481dc6acb3286565afcd23ebb718d582dd30` |
| `reports/round-105/physics-carry.md` | 1212 | `0f4810b4b26ca7b45a80b69f598c99c570161da450ea2bd37050d40be6f9eb15` |
| `reports/round-105/r105-connector.md` | 5694 | `c7884ded3d1cd40b3c9c00a4545dc7f70218253d70304b0ce8ebccbdea317959` |
| `reports/round-105/r105-distiller.md` | 9945 | `03be6cd3094f51d3c6e5b16b83618bdbac659737c76e245396cb064ff7f81bc1` |
| `reports/round-105/r105-report.md` | 15539 | `d6f79b34923a05383b43f73c59d0c7edd903125cdfa8624ebda9af19ba0dc6b3` |
| `reports/round-105/r105-scribe-audit.md` | 8153 | `6758b55882e0949918a3af596f1e557354772f47fc43c84fed75c3459ffd3969` |
| `reports/round-105/r105-verification-protocol.md` | 18011 | `97526024deb03113030537e56f83b81f24f285238378c84d11dcb80dc55c6b5a` |
| `reports/round-105/scorecard-shape.md` | 2947 | `4e867074fe155486465588023bcdc0561a69d8706715c7b3ef76263ad1416e19` |
| `reports/round-105/seats-ledger.md` | 5447 | `1a1a701f2a5d83138d3f806bae069bbd37d5e31f3e523cc730f2cffe7b1dda1c` |
| `reports/round-105/skill6/author.md` | 4782 | `236ce9256ef809ebb3cc57c878bc89dbdfd9bc00b5ed38baea3afee674a33983` |
| `reports/round-105/skill6/bleed.md` | 3404 | `5f7a85b38289ee0eb5d49d1997adbfa0cd48b3d2bac9b8d2a55176b7ed7297df` |
| `reports/round-105/skill6/critic.md` | 6038 | `4e19bd4a149eb5edec84df690f2a81c20c28f59f8db932cd49100b08283990fb` |
| `reports/round-105/skill6/review.md` | 5317 | `86aadbb92ec15c83c8615b36ad172a402f48c20642d99ba4458a6fe11ca9890e` |
| `reports/round-105/skill6/stamps.md` | 5528 | `f63a9bb356f16dd308322058eea65092a032dc433c648b018aa7b4073355f3c3` |
| `reports/round-105/stub-cleanness.md` | 1517 | `ba60e1bd3c5cfa9e94ac96076c248a1d587de9ae8dc6fce48d6af031f3cdc385` |
| `reports/round-105/subtree-integrity.md` | 2496 | `d5ae31e5d52d99383044451c50180382e60cf8fbe091b75683861c76e2f77ba6` |

This table excludes itself; its own hash is intentionally not self-referenced. The file inventory is explicitly provisional and must be remeasured before any round-close claim.