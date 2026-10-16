# r98 author — the GLTF/GLB runtime-import lattice

Seat: **GAME-DEV-3D r98 AUTHOR**. Task:
`/home/vgpnk/Projects/shokunin/.ufo/waves/shokunin-train-20261015-w22/tasks/g3d-r98-author.md`.
Sources read, never written (except the disclosed repair in §3): the r98
scout report + probes/assets, the r98 boundary report + probes/assets +
named falsifications/supplements (`corpus/live/r98-scout/**`,
`corpus/live/r98-boundary/**`). **No commit, no tracked-tree write other
than the files this seat owns.**

Landed (all tracked seeds):

- `corpus/fixtures/r98_gltflat.gd` — the parent fixture, 9 arms, **137
  pinned cells**, **137 bounded children per battery pass**. sha256
  `47998a95bb0401f7f8475bb0baf0828fa8f8559d2b2b3c174eff8221ab2835db`.
- `corpus/fixtures/r98_probe_*.gd` — **4 byte-identical copies** of the
  scout probes (`gltf.gd`, `gltf_tr.gd`) and boundary probes
  (`r98b_inv.gd`, `r98b_mode.gd`), copied into each child project under
  their ORIGINAL `res://` names so a child receipt reproduces the source
  receipt byte-for-byte (sha table: `corpus/live/r98-author/RECEIPTS.md`).
- `corpus/fixtures/r98assets/` — **17 vendored assets**, every one
  byte-matching the boundary manifest pin (scout's six + the boundary's
  eleven discriminators, `ext.bin`/`ext_resuri.gltf`/`tri_upper.GLB`
  included).
- `corpus/fixtures/run_battery.py` — **+9 rows, insertion-only** (`git
  diff --numstat` = 41 insertions, 0 deletions, after
  `r97_nodelat_freegrain`): `r98_gltflat_{load,doc,sniff,extbin,cls,write,
  tr,phys,var}`.
- this report.

The premise the lattice pins is the cold one: every child runs in a fresh
per-cell project with the vendored assets copied under `res://assets/`, so
no `.godot` import cache can pre-exist it. A post-run census pins `gd=0`
(cache absent) on every cell; a child that mints a cache fails the row.
The warm-cache `ResourceLoader → PackedScene` flip (boundary V12) is the
editor-pipeline surface and is **not** authored.

## 0. The nine rows and what each pins

Every cell's receipt was re-derived: a full pass spawns 137 fresh Godot
children (`timeout -s KILL 14` bounded, 8-way chunks), each running the
scout's/boundary's own probe out of a per-cell project, and folds the
child's normalized contract stream into
`<cell>{rc=<n>,sha=<16 hex>,<field>=<value>,...}`.

| # | row (CASES) | arm | cells | boundary-surviving law encoded |
|---|---|---|---|---|
| 1 | `r98_gltflat_load` | `load` | 21 (7 cases × 3 backends) | The `ResourceLoader` dead-end under the cold premise: every load returns `res=null` — valid `.glb`/`.gltf`, corrupt, empty, missing, upper-case `.GLB` alike — each with exactly 2 allowlisted error lines (`ee=2`), byte-identical across GodotPhysics/Jolt/Dummy (`beq=1`). |
| 2 | `r98_gltflat_doc` | `doc` | 36 (12 × 3) | The `GLTFDocument` door: `append_from_file` on res://, absolute, `user://`, and cwd-relative paths and `append_from_buffer` all import with `err=0`; `doc_missing` separates `err=7` (`ERR_FILE_CANT_OPEN`, `ee=1`) from the `err=43` parse family (`doc_badmagic`/`doc_badjson`, `ee=2`); the structurally-empty GLB imports `err=0` to an unnamed `Node3D`; `generate_scene` roots at `TriScene:Node3D`; the scene→GLB→scene round-trip keeps 2 nodes/1 mesh at 2696 bytes and re-imports to `RTSource:Node3D`. |
| 3 | `r98_gltflat_sniff` | `sniff` | 21 (7 × 3) | The container is **content-sniffed on the 4-byte magic, not the extension**: `glb_as_gltf` (GLB bytes under `.gltf`) and `json_as_glb` (JSON text under `.glb`) both import `err=0`; `magic_truncated` (inflated declared length) and `glb_version3` (version field = 3) also import `err=0` — declared total length and container version are unvalidated; `magic_only`, `magic_badjson`, `badmagic_badjson` all land `err=43` with `ee=2`. |
| 4 | `r98_gltflat_extbin` | `extbin` | 21 (7 × 3) | External-buffer URIs resolve against the file's own directory (`ext_bin_file` `err=0`) and the `append_from_buffer` base (`ext_bin_abs`/`ext_bin_buf_good` `err=0`); empty base + relative URI, and the `res://assets/ext.bin` URI in both file and buffer paths, all fail `err=43` with `ee=4` — the `res://` URI is blind-concatenated, never res-rooted. |
| 5 | `r98_gltflat_cls` | `cls` | 12 (4 × 3) | The corrected inventory: **18** GLTF-domain classes exist (`classes=18` — `GLTFSkin` is the 18th), all instantiate (`asked=18,exists=18`), `GLTFObjectModelProperty` the lone plain RefCounted (`refc=1`); `set_root_nodes`/`get_root_nodes` are **absent on GLTFDocument** (`srn=false,grn=false`, `docp=16` props) and live on `GLTFState` (`stp=40` props) — the probe's property census pins the API surface, `root_node_mode`/`root_nodes` included via the hashed stream; 13 supported extensions (`sup=13`); `ResourceLoader.exists()` is `false` for the existing `.glb`/`.gltf`/`.GLB`/absent set (`exglb=exgltf=exup=exabs=false`); recognized formats `tscn,res,scn` carry no GLTF. |
| 6 | `r98_gltflat_write` | `write` | 3 (1 × 3) | `write_to_filesystem` works cold: the written `.glb` is **byte-identical** to `generate_buffer` (`gen=2692,fb=2692,eqg=true`), re-imports `rerr=0`; `.gltf` writes a sidecar `.bin` (`w2=0,gb=1500`). |
| 7 | `r98_gltflat_tr` | `tr` | 2 | Transform fidelity on both encodings: TRS `nodes_only.glb` reproduces `PivotB` at `(7.0,8.0,9.0)` (matrix-encoded form) and `tri.glb` reproduces `TriMesh` at `(1.0,2.0,3.0)` with zero drift. |
| 8 | `r98_gltflat_phys` | `phys` | 6 | An engine-authored OMI-physics payload exports **byte-identically on all three backends** (`pgsha=cb0a74518de94092` — the boundary's pinned sha, re-derived; `pgeq=1`) and imports identically (`body=RigidBody3D,mass=3.5,shape=BoxShape3D`, `beq=1`): backend-inert even with a physics extension present. The no-mesh export's declared-length asymmetry stays in the hashed stream (`ee=1`, `physbuf` class) — `err=0` is not "no diagnostics". |
| 9 | `r98_gltflat_var` | `var` | 15 | The whole surface is rate-inert: `doc_file`/`doc_empty`/`load_glb`/`roundtrip` at tps 30/120/5, `--fixed-fps 60/120`, and `--time-scale 0.5` all equal their 60-tps twins (`eq=1` on every compare cell, `beq`-style equality across all four `--fixed-fps 60` backends). |

Not pinned anywhere: the warm-cache `PackedScene` flip (explicitly out of
premise), skins/animations/textures/cameras/lights payloads,
`GLTFDocumentExtension` runtime hooks, exported-template context, whether
OMI bodies enter a physics space once tree-owned, and every scout/boundary
case not replayed above.

## 1. Rep-stability contract

- **Authoring sweep** (`corpus/live/r98-author/driver.py`, 2 reps × 9
  arms over two independent scratch roots + 1 rep on a third):
  **27/27 arm runs PASS** and **one distinct PASS line per arm** —
  byte-identical across reps and across scratch dirs, including every
  `sha` digest (child-dir names are pid-namespaced, so this also proves
  the receipts carry no path dependence).
- **Crosscheck** (`corpus/live/r98-author/crosscheck.py`): every child
  receipt vs the scout's/boundary's own receipt —
  `137 checked, 137 identical, 0 differ, 0 missing`. The fixture's
  children reproduce the source evidence verbatim before normalization.
- **Declared normalizations** (applied before hashing, mirrored in the
  crosscheck): the engine banner and blank lines; the allowlisted 2-line
  Jolt job-system warning (any position, counted in `w`, never observed
  on this surface); runtime object ids `<Class#12345>` → `<Class#N>`
  (never observed); the `app_userdata` absolute prefix → `UD/` — the
  `doc_abs`/`ext_bin_abs` receipts are `$HOME`-pinned, so the claim is
  the path FORM, not the host; crash-ASLR fields (`Load address:` → `A`,
  `[n] 0x…` → `[n] F`) — no crash cells exist on this surface, the
  rules are guard-only.
- **Expected-error classes** stay in the hashed stream and are counted in
  `ee` (`noload`, `cantopen`, `jsparse`, `glbparse`, `chunk`, `extbuf`,
  `physbuf`); any other ERROR-class line — `SCRIPT ERROR`, `Parse
  Error`, `handle_crash`, ObjectDB leak — lands in `ue` and fails the
  cell. `rc=0` is never sufficient evidence of cleanliness on this
  surface (malformed imports print `ERROR:` and still return 0).
- **Child budget**: 137 children per pass, 8-way chunks, each `timeout
  -s KILL 14`; battery-row wall times **1.03–3.96 s** (20 s per-case
  bound) across the three battery runs.

## 2. Battery

- Before: **324 cases** (265 ordinary + 59 negative) · After: **333
  cases** (274 ordinary + 59 negative) = **+9 r98 rows**.
- r98-only pre-run on the final bytes: **9/9 PASS**
  (`corpus/live/runs/20261016T064339133449Z/verdicts.json`).
- Full run 1: **333/333 PASS — fully green**, `seeds_unchanged=true`
  (`corpus/live/runs/20261016T064400675959Z/verdicts.json`).
- Full run 2 on the same final bytes: **333/333 PASS — fully green**,
  `seeds_unchanged=true`
  (`corpus/live/runs/20261016T065305784772Z/verdicts.json`).
- No r98 row ever reddened (pre-run, both full runs, and the 27-run
  sweep). No documented flake class fired in either full run — the
  known `phys3d_events_race_class` drift, the navagent one-tick load
  flake, and the `phys3d_joints_*` knife-edge rows all stayed green.

## 3. Corrections / disclosures vs scout+boundary

1. **18 classes, not 17.** The scout's inventory missed `GLTFSkin`; the
   boundary corrected it. The fixture counts `classes=18` and the
   instantiate census `asked=18,exists=18,refc=1`.
2. **`set_root_nodes` lives on `GLTFState`, not `GLTFDocument`.** The
   `props` cells pin `srn=false,grn=false` on the document (16 props) vs
   the state's 40-prop surface; the hashed stream carries the
   `root_node_mode`/`root_nodes` evidence.
3. **Content-sniff, not extension.** Both directions pinned
   (`glb_as_gltf`, `json_as_glb` `err=0`); `magic_truncated` and
   `glb_version3` prove declared length/version are unvalidated.
4. **Cold ≠ warm.** The `load` arm pins `res=null` only under the wiped
   `.godot` premise (post-run census `gd=0` per cell); the boundary's
   warm-cache `PackedScene` flip is documented as out-of-scope.
5. **`ee` counts are diagnostics, not failures.** `err=43`/`err=7` cells
   exit `rc=0` with allowlisted error lines kept in the hashed stream —
   the fixture encodes the boundary's "rc=0 does not mean quiet" verdict
   structurally.
6. **`ResourceLoader.exists()` falsified both ways.** `exglb/exgltf/exup/
   exabs=false` for existing GLB/GLTF/upper-case/absent paths alike —
   `exists` answers "is there a loader", not "does the file exist".
7. **`physgen`'s no-mesh export keeps its declared asymmetry**: 612-byte
   file with an inflated declared length imports `err=0` behind one
   allowlisted warning-class line (`physbuf`, `ee=1`). The pinned
   `pgsha=cb0a74518de94092` re-derives the boundary's export sha exactly.
8. **Repair disclosure (my own clobber).** During earlier evidence
   inspection this seat ran `xxd <infile> <outfile>` — `xxd`'s second
   positional is the OUTPUT file — which overwrote
   `corpus/live/r98-boundary/assets/badmagic_badjson.glb` (live scratch,
   not a tracked seed) with the hexdump of `magic_badjson.glb`. The file
   was regenerated deterministically from the boundary's own
   `gen_assets_r98b.py` recipe to the manifest-pinned sha
   `6e813b4c3cc0afad2a2146ad8c54635ab21f5aa902e9c3e95dc40221e23a1747` and
   verified: **all 4252 boundary manifest entries and all 837 scout
   manifest entries byte-match** their pins after the repair (no other
   file was touched). The vendored fixture copy carries the correct
   `XXXX`-magic bytes. The crosscheck caught the corruption — the child
   receipt differed on exactly the clobbered case — which is what the
   mechanism is for.
9. **Dummy cells are inert twins, never laws.** `beq=1`/`pgeq=1`/`eq=1`
   flags are emitted only where the boundary measured byte-identical
   backend output; Dummy contributes equality evidence, not physics.

## 4. Commands (repro)

```bash
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# authoring sweep (writes only corpus/live/r98-author/**)
python3 corpus/live/r98-author/driver.py --scratch corpus/live/r98-author/ftest2 \
        --out corpus/live/r98-author/run2 --reps 2
# child receipts vs scout/boundary receipts
python3 corpus/live/r98-author/crosscheck.py --scratch corpus/live/r98-author/ftest2
# the nine rows alone, then the full battery (twice)
python3 corpus/fixtures/run_battery.py --only r98_gltflat_load,r98_gltflat_doc,r98_gltflat_sniff,r98_gltflat_extbin,r98_gltflat_cls,r98_gltflat_write,r98_gltflat_tr,r98_gltflat_phys,r98_gltflat_var
python3 corpus/fixtures/run_battery.py
python3 corpus/fixtures/run_battery.py
# one arm directly (the battery's own shape)
godot --headless --path <scratch> --script res://r98_gltflat.gd -- --arm=sniff
```

## 5. Receipts pointer

`corpus/live/r98-author/` (gitignored scratch): `driver.py`,
`crosscheck.py`, `RECEIPTS.md` (seed sha table), `run1/` (9 arm runs),
`run2/` (18 arm runs), `ftest/`, `ftest2/` (per-cell `child.log`,
`project.godot`, probe copy for all 137 children). Battery verdicts under
`corpus/live/runs/20261016T06{4339133449,4400675959,5305784772}Z/`.

Provenance: this seat wrote only `corpus/fixtures/r98_gltflat.gd`,
`corpus/fixtures/r98_probe_*.gd` (4 byte-identical copies),
`corpus/fixtures/r98assets/` (17 byte-identical assets), the 9-row
insertion in `corpus/fixtures/run_battery.py`, this report and its
scratch tree, and the disclosed §3.8 repair of one live-scratch asset it
clobbered. No other round's fixtures or receipts were touched.
**No commit made, per instruction.**
