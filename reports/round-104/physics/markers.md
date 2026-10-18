# r104 SEAT-03 — marker bank: `phys3d_joints` arms + `free_ops` CASES row

Byte-identity reference for the post-change comparison of the r104 C1 fix
(`phys3d_joints_free_ops` wall-cost; r103 ruling: 21 serial Godot boots x ~0.9 s
floor > `CASE_TIMEOUT_SECONDS = 20`). The arm is correct and its marker is
byte-identical at a 120 s bound, so the fix must not move a single byte pinned here.

Source of truth is the `CASES` table in `corpus/fixtures/run_battery.py`, parsed with
`ast.literal_eval` — not a text grep — so every string below is the exact Python
literal the runner compares against.

**Count note.** The seat brief says "all 7 phys3d_joints arms + the free_ops row".
Measured: the `CASES` table holds **8** rows whose script is `phys3d_joints.gd`, and
`free_ops` is one of them. The fixture header (`corpus/fixtures/phys3d_joints.gd:17-26`)
also names **8** arms. The bank therefore covers all 8 rows, satisfying both readings
(7 non-`free_ops` rows + the `free_ops` row = 8). Nothing was omitted.

| fact | value |
|------|-------|
| source file | `corpus/fixtures/run_battery.py` |
| source sha256 (measured now) | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` |
| source sha256 (r102 receipt `seed_digests`) | `f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f` |
| source git blob (`git hash-object`) | `dd2d9b74448afddb88dcf2da56008302eba8060d` |
| `CASES` rows in table | **350** (r103 pin: 350) |
| rows with script `phys3d_joints.gd` | **8** |
| `CASE_TIMEOUT_SECONDS` | 20 (`corpus/fixtures/run_battery.py:36`) |
| digest algorithm | sha256 over the UTF-8 bytes of the exact literal; no newline appended |
| bank generated (UTC) | `2026-10-18T19:17:41Z` |
| scope | this seat edited nothing; `reports/round-104/physics/markers.md` is the only path written |

## 1. Whole-marker digest (CASES order)

| # | case name | flags | exp. exit | marker bytes | sha256 |
|---|-----------|-------|-----------|--------------|--------|
| 1 | `phys3d_joints_sweep` | `--arm=sweep` | 0 | 675 | `84e0a9abe19ffce99934bcf44512ff74b1e9503f34d22f1a0550f3bd55315793` |
| 2 | `phys3d_joints_rid` | `--arm=rid` | 0 | 1001 | `94a5ddaa4739e3daa287401cc5cecaa2e5e2c3a03a5c19566ca2d3d4f23c79a2` |
| 3 | `phys3d_joints_api` | `--arm=api` | 0 | 2574 | `fb36001cbe41c661d3113aad515d0d025754f7f0668b3ba281d178437a70e606` |
| 4 | `phys3d_joints_free_pair` | `--arm=free_pair` | 0 | 1514 | `a8f66074ea92869971a7ab4a0eceb18806a55cfffae6b8888cda9a362a37f1f6` |
| 5 | `phys3d_joints_free_ops` | `--arm=free_ops` | 0 | 3921 | `706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74` |
| 6 | `phys3d_joints_detach` | `--arm=detach` | 0 | 2596 | `fe2743f8a825f289f55088fd716503603b058d3d4dda642cd0851030abffe8e7` |
| 7 | `phys3d_joints_chain3` | `--arm=chain3` | 0 | 281 | `26912caaa4ee260fc89394ddf62afc8edfe853beb705a72a26cff32697b35158` |
| 8 | `phys3d_joints_twopin` | `--arm=twopin` | 0 | 6623 | `f3a829393a088ab9312978682016080cc7b4602dc7c8f93c5829c5a09c6cb445` |

Combined payload: 19185 bytes over 8 rows.
sha256 of the concatenation in table order = `acabe35fbbc8676e0efb1ec2f35f4bd13501457d6f19a0572f8b1b0afec358ab`

## 2. Per-cell digests

The parent fixture prints one `name@backend{...}` cell per (case, backend). The
battery compares the whole parent stdout line, so each cell is also pinned
individually — a cell-level diff localizes a byte break faster than the row sha.
Cell text is the byte-exact `name@backend{...}` block; sha256 is over that block alone.

### `phys3d_joints_sweep` (`--arm=sweep`) — 3 cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `sweep` | gp | 218 | `e9a968c2bb17b8f5e7925ecb361f62b1a2a93f79ed3e80813272fc416d3fb860` |
| 2 | `sweep` | jolt | 222 | `ab2e578a5795ef6248aaf917f439b4ad8f2afd71cee7784ad2f18eea9ef03893` |
| 3 | `sweep` | dummy | 208 | `1fcc03cf337e947a5b467f65a98f4a2ff10b5963e13aa94f2341f89c8a28dd01` |

cell-concat sha256: `1138ce3d42f46befbb40cd41d998c8d64b706470c71d1bd606fb8e7920b0e86d`

### `phys3d_joints_rid` (`--arm=rid`) — 3 cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `rid` | gp | 322 | `fa44e13dbd974df2ffcff876379572e2d8c3a8389910ee5c231885ae0bc7abbe` |
| 2 | `rid` | jolt | 334 | `b14c4764b33b2fcd615d6711e589e2845cbc2abcdc79b2343af515ca81e442e4` |
| 3 | `rid` | dummy | 320 | `4e4eeb10df3b2595177057fcef92820f9949d62032189a0ac66242effd83ffc5` |

cell-concat sha256: `a51a9571dba02f0ab5be8a5b084a432b580235e7701382b07d1808f77978d41b`

### `phys3d_joints_api` (`--arm=api`) — 3 cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `api` | gp | 846 | `c8ee490ae5da3b95f19c14200d8f58540870a0b46b25089d98d9b00abbe08c76` |
| 2 | `api` | jolt | 858 | `175dc25a6094c4c811458208cd0e09599d9268ab75e5833aa88e3923d60c370d` |
| 3 | `api` | dummy | 845 | `df39577a69c0716f339f6d5b510529d6e1f0bece8d24bcc97c7f29d7ac4d2796` |

cell-concat sha256: `e5f3a6f822f5156adaee3e7b440c092244864c55c182e5a99fe5d29598362656`

### `phys3d_joints_free_pair` (`--arm=free_pair`) — 9 cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `freeb` | gp | 40 | `71b3eea1c1c9fea1dda24355eac2ec67d7b2b0a4aff85f5df505111240bb640c` |
| 2 | `freeb` | jolt | 42 | `b6f7028580cd1848b767ab85de859a50f3e184dfa69b742c7c9178bc9c7cb592` |
| 3 | `freeb` | dummy | 392 | `fa950cea11192a20b6c4f5337bac92326ea96a5d1eb1265ddd14add315fdbeb0` |
| 4 | `freea` | gp | 40 | `8a492e6d172137ffbf866f486ea227802e048232fde5636127a3bd450bd790ee` |
| 5 | `freea` | jolt | 42 | `73976d40f9646814bf36123907a0dec13e724a0921ffc0be2b64e80fd55b93fa` |
| 6 | `freea` | dummy | 392 | `918405f7efc7c6927ef671501676d1f5ebac7f5ea67a8f629e56ae898090c8e6` |
| 7 | `freeb_dyn` | gp | 43 | `a1f9a3d7dc6a6cae40de1ba05de9592b9e2e58dda19fcd1702b71001a2e16fc6` |
| 8 | `freeb_dyn` | jolt | 46 | `825a78b5205db114303515b5117dc94ae3a05f42656e545a561bab5646a97ac0` |
| 9 | `freeb_dyn` | dummy | 440 | `fd2b2c4a5edacb8262543496973b36f31e932b77a95f900a7d284c75b266c50e` |

cell-concat sha256: `c02d87ac31cc691bc01cc384641bb033ee336d46edb7ab9331b241c1c7dc188d`

### `phys3d_joints_free_ops` (`--arm=free_ops`) — 21 cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `freeb_ops` | gp | 43 | `59ef5fa1a22455e8e2e454f55e68500394491e9ba614c9045393a35d370ff178` |
| 2 | `freeb_ops` | jolt | 45 | `b520a7ea2ffa67621792fc7b719adf36129d939e90a81c0bca76a278c72b60bb` |
| 3 | `freeb_ops` | dummy | 238 | `548819eceff6dcd7c7a8812444945607ce90fffca43d433ba51bb90c3e80a974` |
| 4 | `freeb_twice` | gp | 45 | `0136124b8e2a2148e355393db76cdf97a75660ea8f14bc87ec528abd3489cfd7` |
| 5 | `freeb_twice` | jolt | 47 | `61e4e6409bba5f48650d17d2c3cc21bb453a9b43032152f740bd218114efc2bc` |
| 6 | `freeb_twice` | dummy | 153 | `e2c1dc7fe046263c9e914ddaca5836c5a862aaf6ff85b756ca75d96d5fcb724e` |
| 7 | `freeb_make` | gp | 44 | `007c8c079b509cf7d938fbf45f00e52fb2b65dd1affe940ccbb43e4b745c0d19` |
| 8 | `freeb_make` | jolt | 46 | `710579f08a9b54dd68debdde9956ddce192ffd60b3c512e303e048531f42052c` |
| 9 | `freeb_make` | dummy | 146 | `a3307f2ddf7e1ed37171da1db6527e4535d01285f8d409bb7abf476bdbd31f83` |
| 10 | `freeb_world` | gp | 870 | `eb3081194ff94d09ec12c802aa1d79d04ce1e08a4e9292ea738e15cdd0f0ead8` |
| 11 | `freeb_world` | jolt | 882 | `708e89f775775e1d8ffe1a5c483d6d730f075aedda8432b9f95cadfebd248510` |
| 12 | `freeb_world` | dummy | 540 | `9d4a0f06983baa88f04272444751cb2aa7e735bf1873e2822d30fe7efd7a42ca` |
| 13 | `freeb_afterclear` | gp | 50 | `55dd22e152480eff0393fb843a92442737f12696bab9e9e74bf5db7dad87ffa5` |
| 14 | `freeb_afterclear` | jolt | 52 | `729da43918eb24a051262f026e3389b0690c574f58f7b800f1675b745e9d9ac8` |
| 15 | `freeb_afterclear` | dummy | 177 | `d6dc80477429f3cd3c962ce4ef76b07e865bf56a747744933c4b8c90e72f9c5a` |
| 16 | `freej_then_b` | gp | 46 | `3e79d3bd7566d05b2db4660c66dabffa9ea61fe4b87c4af5b0c5dd06ee4be585` |
| 17 | `freej_then_b` | jolt | 48 | `b04a30406f5b8ad099ed02007aac4e97220cb130bbd87c2656197be210b0a4d4` |
| 18 | `freej_then_b` | dummy | 156 | `dccd3911b2168a6022795bd61512aa431dfb9c9bd389d450b179e49300ccf444` |
| 19 | `detachb_free` | gp | 46 | `e7a0e358a8ad03cf27ff219d5cf6a8227be00300852c348429fff589e5584f97` |
| 20 | `detachb_free` | jolt | 48 | `95f63501e8cd4eca5f22e1d51b58218c0d1d26135d58a83cd4146cdd169c4839` |
| 21 | `detachb_free` | dummy | 151 | `429a0059ce8440352096aef8cf216cbf71a207a2470d3141c245bba32d1b1b92` |

cell-concat sha256: `e6c028fef5dcb8061a1a26cd24bf5bf63f2c8812baa610b07638336b7c2fb379`

### `phys3d_joints_detach` (`--arm=detach`) — 3 cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `detachb` | gp | 983 | `409b190536e2690c37986ffeef4d01989896230b717421945280b78f110e92ea` |
| 2 | `detachb` | jolt | 991 | `6830cd0015726e106feab96cdbf971a1fe2153b56ae6a4ac408b75a44cab12b1` |
| 3 | `detachb` | dummy | 594 | `ea4eb28a82284367f0bf8bdb45a5e2c5dd11c5071d74252215ad3a0bb4f13850` |

cell-concat sha256: `699d0812598acf582f339cf93841df884b58718c863f41f7b25c09a6d2236923`

### `phys3d_joints_chain3` (`--arm=chain3`) — 3 cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `chain3_freemid` | gp | 48 | `33bf5c32f8dd30ab4d916f5b88d079c4832b82f99e66d42e2079d349c6fcc3b9` |
| 2 | `chain3_freemid` | jolt | 50 | `9fe07eeae6e0e39ffff1a5414e21681a1a034339cb3a99fb044bf0af56ff1408` |
| 3 | `chain3_freemid` | dummy | 155 | `ea8c5b9f750b911cbed284cae45fbe135dff5edeb3e038a6d220e8ddfffaed12` |

cell-concat sha256: `9117dc70853f3fa327ac9da6b671384d55b89a51f58d6c2376c589b694be489e`

### `phys3d_joints_twopin` (`--arm=twopin`) — 6 cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `twopin_hi1` | gp | 1292 | `f65e1f71276ecd73a68c0434ba6c1d3992a992eda449aa958f9d63e718672feb` |
| 2 | `twopin_hi1` | jolt | 1272 | `8455333da8158b6af015cc751cea7451160c044d79b32c14ac5364f33757ae51` |
| 3 | `twopin_hi1` | dummy | 747 | `ae1907d61131e1844ec7998a8231e4dba459d4b7e65b452c0b58bee0955b3c73` |
| 4 | `twopin_hi2` | gp | 1262 | `58c766395fd503499f056aed853e0dabf92e782e24eb12fe8eb4cb089f9f3977` |
| 5 | `twopin_hi2` | jolt | 1272 | `aa8f262661b24ad742605a044a6e0f131209951eff92fda215fbd29fc27a0434` |
| 6 | `twopin_hi2` | dummy | 747 | `f8ee6e26d10e3b455b6dc27d0e3ed832293a516380dcd12eb365c827ee9a51b7` |

cell-concat sha256: `2582ffa33258c802a26a1d79cd51244cbbba88e50d5769eaffe2b88c3f7147a1`

## 3. `phys3d_joints_free_ops` — the C1 row, verbatim

The C1 fix must leave this row byte-identical. `classify()` in
`corpus/fixtures/run_battery.py` compares the child's stdout line to this literal
exactly, so any whitespace, cell-ordering or digit change here is the failure signal.

```
name    = phys3d_joints_free_ops
script  = phys3d_joints.gd
flags   = ['--arm=free_ops']
exit    = 0
bytes   = 3921
sha256  = 706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74
```

```text
PASS phys3d_joints free_ops freeb_ops@gp{mode_ok=1,m6=124dfece8083d80f} freeb_ops@jolt{mode_ok=1,m6=0b9af1d2f64aad4a} freeb_ops@dummy{rc=0,m=M0 case=freeb_ops engine=Dummy|M freeb_ops freed|M freeb_ops get_type=0|M freeb_ops get_prio=0|M freeb_ops pin_param=0.0|M freeb_ops isdis=false|M freeb_ops cleared type=0|M DONE case=freeb_ops engine=Dummy,e=0,w=0} freeb_twice@gp{mode_ok=1,m4=e7c8b9cc20d38b1e} freeb_twice@jolt{mode_ok=1,m4=c42295756101d8d6} freeb_twice@dummy{rc=0,m=M0 case=freeb_twice engine=Dummy|M freeb_twice free1 done|M freeb_twice free2 done|M DONE case=freeb_twice engine=Dummy,e=0,w=0} freeb_make@gp{mode_ok=1,m4=5a1b9bded3cbf88b} freeb_make@jolt{mode_ok=1,m4=22e9399210234fe5} freeb_make@dummy{rc=0,m=M0 case=freeb_make engine=Dummy|M freeb_make freed_b|M freeb_make made type=0|M DONE case=freeb_make engine=Dummy,e=0,w=0} freeb_world@gp{rc=0,m=M0 case=freeb_world engine=DEFAULT|M freeb_world t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=5|M freeb_world t=2 b=0.0000,1.9973,0.0000 lv=0.0000,-0.1633,0.0000 jtype=5|M freeb_world t=3 b=0.0000,1.9918,0.0000 lv=0.0000,-0.3264,0.0000 jtype=5|M freeb_world t=4 b=0.0000,1.9837,0.0000 lv=0.0000,-0.4892,0.0000 jtype=5|M freeb_world t=5 b=0.0000,1.9728,0.0000 lv=0.0000,-0.6517,0.0000 jtype=5|M freeb_world made type=0|M freeb_world t=6 b=0.0000,1.9593,0.0000 lv=0.0000,-0.8139,0.0000 jtype=0|M freeb_world t=7 b=0.0000,1.9430,0.0000 lv=0.0000,-0.9759,0.0000 jtype=0|M freeb_world t=8 b=0.0000,1.9240,0.0000 lv=0.0000,-1.1376,0.0000 jtype=0|M freeb_world t=9 b=0.0000,1.9024,0.0000 lv=0.0000,-1.2991,0.0000 jtype=0|M freeb_world t=10 b=0.0000,1.8780,0.0000 lv=0.0000,-1.4602,0.0000 jtype=0|M DONE case=freeb_world engine=DEFAULT,e=0,w=0} freeb_world@jolt{rc=0,m=M0 case=freeb_world engine=Jolt Physics|M freeb_world t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=5|M freeb_world t=2 b=0.0000,1.9973,0.0000 lv=0.0000,-0.1633,0.0000 jtype=5|M freeb_world t=3 b=0.0000,1.9918,0.0000 lv=0.0000,-0.3264,0.0000 jtype=5|M freeb_world t=4 b=0.0000,1.9837,0.0000 lv=0.0000,-0.4892,0.0000 jtype=5|M freeb_world t=5 b=0.0000,1.9728,0.0000 lv=0.0000,-0.6517,0.0000 jtype=5|M freeb_world made type=0|M freeb_world t=6 b=0.0000,1.9593,0.0000 lv=0.0000,-0.8139,0.0000 jtype=0|M freeb_world t=7 b=0.0000,1.9430,0.0000 lv=0.0000,-0.9759,0.0000 jtype=0|M freeb_world t=8 b=0.0000,1.9240,0.0000 lv=0.0000,-1.1376,0.0000 jtype=0|M freeb_world t=9 b=0.0000,1.9024,0.0000 lv=0.0000,-1.2991,0.0000 jtype=0|M freeb_world t=10 b=0.0000,1.8780,0.0000 lv=0.0000,-1.4602,0.0000 jtype=0|M DONE case=freeb_world engine=Jolt Physics,e=0,w=0} freeb_world@dummy{rc=0,m=M0 case=freeb_world engine=Dummy|M freeb_world t=1 b=null lv=null jtype=0|M freeb_world t=2 b=null lv=null jtype=0|M freeb_world t=3 b=null lv=null jtype=0|M freeb_world t=4 b=null lv=null jtype=0|M freeb_world t=5 b=null lv=null jtype=0|M freeb_world made type=0|M freeb_world t=6 b=null lv=null jtype=0|M freeb_world t=7 b=null lv=null jtype=0|M freeb_world t=8 b=null lv=null jtype=0|M freeb_world t=9 b=null lv=null jtype=0|M freeb_world t=10 b=null lv=null jtype=0|M DONE case=freeb_world engine=Dummy,e=0,w=0} freeb_afterclear@gp{mode_ok=1,m4=a31ec35bc29873fb} freeb_afterclear@jolt{mode_ok=1,m4=0aadc67976644396} freeb_afterclear@dummy{rc=0,m=M0 case=freeb_afterclear engine=Dummy|M freeb_afterclear clear type=0|M freeb_afterclear b freed|M DONE case=freeb_afterclear engine=Dummy,e=0,w=0} freej_then_b@gp{mode_ok=1,m4=606a01100dfc83f1} freej_then_b@jolt{mode_ok=1,m4=70d825f7cce91132} freej_then_b@dummy{rc=0,m=M0 case=freej_then_b engine=Dummy|M freej_then_b joint freed|M freej_then_b b freed|M DONE case=freej_then_b engine=Dummy,e=0,w=0} detachb_free@gp{mode_ok=1,m4=c293b8d7f2669a3f} detachb_free@jolt{mode_ok=1,m4=e260e2a3c6282b25} detachb_free@dummy{rc=0,m=M0 case=detachb_free engine=Dummy|M detachb_free detached|M detachb_free freed|M DONE case=detachb_free engine=Dummy,e=0,w=0}
```

### 3.1 free_ops cells

| # | cell | backend | bytes | sha256 |
|---|------|---------|-------|--------|
| 1 | `freeb_ops` | gp | 43 | `59ef5fa1a22455e8e2e454f55e68500394491e9ba614c9045393a35d370ff178` |
| 2 | `freeb_ops` | jolt | 45 | `b520a7ea2ffa67621792fc7b719adf36129d939e90a81c0bca76a278c72b60bb` |
| 3 | `freeb_ops` | dummy | 238 | `548819eceff6dcd7c7a8812444945607ce90fffca43d433ba51bb90c3e80a974` |
| 4 | `freeb_twice` | gp | 45 | `0136124b8e2a2148e355393db76cdf97a75660ea8f14bc87ec528abd3489cfd7` |
| 5 | `freeb_twice` | jolt | 47 | `61e4e6409bba5f48650d17d2c3cc21bb453a9b43032152f740bd218114efc2bc` |
| 6 | `freeb_twice` | dummy | 153 | `e2c1dc7fe046263c9e914ddaca5836c5a862aaf6ff85b756ca75d96d5fcb724e` |
| 7 | `freeb_make` | gp | 44 | `007c8c079b509cf7d938fbf45f00e52fb2b65dd1affe940ccbb43e4b745c0d19` |
| 8 | `freeb_make` | jolt | 46 | `710579f08a9b54dd68debdde9956ddce192ffd60b3c512e303e048531f42052c` |
| 9 | `freeb_make` | dummy | 146 | `a3307f2ddf7e1ed37171da1db6527e4535d01285f8d409bb7abf476bdbd31f83` |
| 10 | `freeb_world` | gp | 870 | `eb3081194ff94d09ec12c802aa1d79d04ce1e08a4e9292ea738e15cdd0f0ead8` |
| 11 | `freeb_world` | jolt | 882 | `708e89f775775e1d8ffe1a5c483d6d730f075aedda8432b9f95cadfebd248510` |
| 12 | `freeb_world` | dummy | 540 | `9d4a0f06983baa88f04272444751cb2aa7e735bf1873e2822d30fe7efd7a42ca` |
| 13 | `freeb_afterclear` | gp | 50 | `55dd22e152480eff0393fb843a92442737f12696bab9e9e74bf5db7dad87ffa5` |
| 14 | `freeb_afterclear` | jolt | 52 | `729da43918eb24a051262f026e3389b0690c574f58f7b800f1675b745e9d9ac8` |
| 15 | `freeb_afterclear` | dummy | 177 | `d6dc80477429f3cd3c962ce4ef76b07e865bf56a747744933c4b8c90e72f9c5a` |
| 16 | `freej_then_b` | gp | 46 | `3e79d3bd7566d05b2db4660c66dabffa9ea61fe4b87c4af5b0c5dd06ee4be585` |
| 17 | `freej_then_b` | jolt | 48 | `b04a30406f5b8ad099ed02007aac4e97220cb130bbd87c2656197be210b0a4d4` |
| 18 | `freej_then_b` | dummy | 156 | `dccd3911b2168a6022795bd61512aa431dfb9c9bd389d450b179e49300ccf444` |
| 19 | `detachb_free` | gp | 46 | `e7a0e358a8ad03cf27ff219d5cf6a8227be00300852c348429fff589e5584f97` |
| 20 | `detachb_free` | jolt | 48 | `95f63501e8cd4eca5f22e1d51b58218c0d1d26135d58a83cd4146cdd169c4839` |
| 21 | `detachb_free` | dummy | 151 | `429a0059ce8440352096aef8cf216cbf71a207a2470d3141c245bba32d1b1b92` |

cell-concat sha256: `e6c028fef5dcb8061a1a26cd24bf5bf63f2c8812baa610b07638336b7c2fb379`

### 3.2 Embedded `m<N>=<hex>` pins inside free_ops

These 16-hex values are produced by the fixture (M-prefix sha over the child's
stable rows) and are part of the pinned marker. The bank quotes them, never
re-derives them — re-derivation is the fixture's own job, and it is why `mode_ok=1`
is the admission predicate for the crash cells rather than a fixed digest.

| cell | pin |
|------|-----|
| `freeb_ops@gp` | m6=`124dfece8083d80f` |
| `freeb_ops@jolt` | m6=`0b9af1d2f64aad4a` |
| `freeb_twice@gp` | m4=`e7c8b9cc20d38b1e` |
| `freeb_twice@jolt` | m4=`c42295756101d8d6` |
| `freeb_make@gp` | m4=`5a1b9bded3cbf88b` |
| `freeb_make@jolt` | m4=`22e9399210234fe5` |
| `freeb_afterclear@gp` | m4=`a31ec35bc29873fb` |
| `freeb_afterclear@jolt` | m4=`0aadc67976644396` |
| `freej_then_b@gp` | m4=`606a01100dfc83f1` |
| `freej_then_b@jolt` | m4=`70d825f7cce91132` |
| `detachb_free@gp` | m4=`c293b8d7f2669a3f` |
| `detachb_free@jolt` | m4=`e260e2a3c6282b25` |

## 4. Recompute + diff recipe for the post-change seat

Run this against the **post-fix** `run_battery.py`; it re-derives the same table and
prints `OK`/`BREAK` per row against the digests in §1. A `BREAK` on any row means the
C1 fix moved a pinned marker byte and the row is not byte-identical.

```bash
python3 - <<'EOF'
import ast, hashlib
EXPECTED = {
  'phys3d_joints_sweep': '84e0a9abe19ffce99934bcf44512ff74b1e9503f34d22f1a0550f3bd55315793',
  'phys3d_joints_rid': '94a5ddaa4739e3daa287401cc5cecaa2e5e2c3a03a5c19566ca2d3d4f23c79a2',
  'phys3d_joints_api': 'fb36001cbe41c661d3113aad515d0d025754f7f0668b3ba281d178437a70e606',
  'phys3d_joints_free_pair': 'a8f66074ea92869971a7ab4a0eceb18806a55cfffae6b8888cda9a362a37f1f6',
  'phys3d_joints_free_ops': '706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74',
  'phys3d_joints_detach': 'fe2743f8a825f289f55088fd716503603b058d3d4dda642cd0851030abffe8e7',
  'phys3d_joints_chain3': '26912caaa4ee260fc89394ddf62afc8edfe853beb705a72a26cff32697b35158',
  'phys3d_joints_twopin': 'f3a829393a088ab9312978682016080cc7b4602dc7c8f93c5829c5a09c6cb445',
}
src = open('corpus/fixtures/run_battery.py').read()
rows = [n for n in ast.parse(src).body
        if isinstance(n, ast.Assign) and getattr(n.targets[0], 'id', None) == 'CASES'][0]
for name, script, flags, exit_, marker in ast.literal_eval(rows.value):
    if script != 'phys3d_joints.gd':
        continue
    got = hashlib.sha256(marker.encode()).hexdigest()
    print('OK  ' if got == EXPECTED[name] else 'BREAK', name, got)
EOF
```

For the `free_ops` row alone (the C1 target), the equivalent one-liner is:

```bash
python3 - <<'EOF'
import ast, hashlib
src = open('corpus/fixtures/run_battery.py').read()
rows = [n for n in ast.parse(src).body
        if isinstance(n, ast.Assign) and getattr(n.targets[0], 'id', None) == 'CASES'][0]
m = [c[4] for c in ast.literal_eval(rows.value) if c[0] == 'phys3d_joints_free_ops'][0]
print(len(m), hashlib.sha256(m.encode()).hexdigest())
EOF
# expected: 3921 706ad9151452e18dde6766998f93c8580251c0533aad44022e18c2cad6c28c74
```

## 5. Verification commands actually run for this bank

```
$ python3 - <<'EOF'  # ast.literal_eval on the CASES assignment
len(CASES) -> 350 ; rows with script phys3d_joints.gd -> 8
EOF
$ sha256sum corpus/fixtures/run_battery.py
f456bd00a1f7cc6f68d0dd64ff0994d354a7568ef5f34d0cb044209dab1ef69f  corpus/fixtures/run_battery.py
$ git hash-object corpus/fixtures/run_battery.py ; git rev-parse HEAD:corpus/fixtures/run_battery.py
dd2d9b74448afddb88dcf2da56008302eba8060d  (both — file matches HEAD)
$ git diff --stat HEAD -- corpus/fixtures/
(empty)
```

Second, independent parse: a raw-text regex over the source lines (not `ast`)
re-read each `phys3d_joints` marker literal and reproduced the same 8 byte-counts
and shas — `ALL 8 ROWS MATCH (independent raw-text parse vs ast-parse bank)`.

