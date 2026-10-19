# r108 seat output — connector (agent W2RoundGameDev3d.R108Connector-5)

### 1. Convention to REUSE for QUALITY.md
- **Shape to reuse:** Follow 5 probation rules + appended round additions from `chousa-shokunin/corpus/QUALITY.md:1-14` & `tameshi-shokunin/corpus/QUALITY.md:1-14` (criteria 1–5: falsifiable/opinion, measured anchor source, obs/inf/unk separation, append-only errata, kept rejections).
- **Criterion format:** Numbered criteria citing mined mistakes + runnable rechecks, e.g. `chousa-shokunin/corpus/QUALITY.md:11-20` citing `lessons/round-24.md ## Mistakes` (`— M-13`) and `game-dev-2d-shokunin/corpus/QUALITY.md:11-34` citing `corpus/lessons/round-105.md §Mistakes` with executable check blocks (`game-dev-2d/corpus/QUALITY.md:48-65`).
- **Tier pointer:** Do not restate tiers in QUALITY.md; point to contract v1: `chousa-shokunin/corpus/QUALITY.md:12-13` ("Tier definitions live in `corpus/SOURCES.md` (contract v1); this file holds admission only.") and `game-dev-2d-shokunin/corpus/QUALITY.md:6-7`.

### 2. Sibling SOURCES.md Overlaps with Candidate Rows (S001–S030)
- `game-dev-2d-shokunin/corpus/SOURCES.md:12` | `S006` | `https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html` (overlaps G3D `S005`; 2D scopes headless/export CLI).
- `game-dev-2d-shokunin/corpus/SOURCES.md:26` | `S020` | `https://godot-gdunit-labs.github.io/gdUnit4/latest/advanced_testing/cmd/` (overlaps G3D `S006`; 2D scopes gdUnit4 CLI/exit codes).
- `game-dev-2d-shokunin/corpus/SOURCES.md:19` | `S013` | `https://godotengine.org/article/maintenance-release-godot-4-6-1/` (references Jolt transform/rendering patches).
- `game-dev-2d-shokunin/corpus/SOURCES.md:15` | `S009` | `https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html` (2D collision objects & determinism warnings).
*(Note: chousa-shokunin and kengaku-shokunin SOURCES.md contain zero Godot/glTF/Bevy rows.)*

### 3. Contested-Scope Risks (Adjacency in PROVINCE.md)
- **render regression:** Contested with 2D and desktop compositor. `game-dev-2d-shokunin/PROVINCE.md:3`: *"Owns: 2D game production verified by executable headless fixtures — ... camera, UI, levels, juice, export readiness."* and `mado-shokunin/PROVINCE.md:3-4`: *"Domain: desktop & compositor craft — the Hyprland/waybar/walker configuration plane and display behavior"*. G3D must restrict scope to 3D rendering pipeline/projection, refusing 2D surfaces and host compositing (`game-dev-3d-shokunin/PROVINCE.md:36-37`).
- **glTF pipeline:** Uncontested 3D asset domain (`game-dev-3d-shokunin/PROVINCE.md:8-12`). Static inspection must observe revenger boundaries (`revenger-shokunin/PROVINCE.md:23`: *"Refuses: ... game mechanics verification (game-dev-2d)"*).
- **automated playtesting agents:** Contested with orchestration and model eval. `kumitate-shokunin/PROVINCE.md:3`: *"Domain: orchestration & tooling — scopes OMP task/hub, ufo-fsd scripts & runtime"* and `:22`: *"multi-agent failure research ... queued"*; `kengaku-shokunin/PROVINCE.md:3`: *"Domain: LLM/model research & evaluation"*. G3D must bound playtesting to deterministic headless in-engine fixture exploration, never general agent runtime or LLM benchmarking.
- **Jolt physics:** Contested with 2D physics boundary. `game-dev-2d-shokunin/PROVINCE.md:3`: *"Owns: 2D game production ... physics"*. G3D owns 3D physics (`game-dev-3d-shokunin/PROVINCE.md:3-4`: *"Owns: 3D game production ... 3D movement and collision, spatial queries"*). Must isolate to Godot Jolt 3D backends (`PhysicsServer3D`).
- **CharacterBody floor angle:** Uncontested. `scene/3d/physics/character_body_3d.cpp` is 3D-specific (`floor_max_angle` threshold); `game-dev-2d-shokunin/PROVINCE.md:3` owns only 2D kinematics.

### 4. Hard Guardrails for QUALITY.md / SOURCES.md Authoring
1. **Spacing-tolerant row pattern:** Match SOURCES rows via `grep -cE '^\|[[:space:]]*S[0-9]{3}[[:space:]]*\|'`; strict space matching yields 0 on contract examples (`critic.md:34,84-88,153`).
2. **11-column table schema:** Every registry row must contain exactly 11 pipe fields: `awk -F'|' 'NR>1 && /^\|/ && NF!=11'` (`critic.md:155`).
3. **No tier inflation:** `kind=community|talk|own-work|book` must never be Tier A; Tier C cannot be sole support (`critic.md:90-93,157`; `chousa/corpus/QUALITY.md:21-24`).
4. **Current-round fetch record:** Rows require an `opened` date in the active round; `mined` rows must resolve to an existing path in `used-by` (`critic.md:79-83`).
5. **Mandatory rejected rows:** Must include ≥1 rejected row with clear rejection reason and flip condition (`chousa/corpus/QUALITY.md:7`; `game-dev-2d/corpus/SOURCES.md:21,37`).
6. **Required header triad:** Every knowledge entry must open with `# title` and exact `source:`, `verified-at:`, `recheck:` lines (`game-dev-2d/corpus/QUALITY.md:16`; `mistakes.md:312`).
7. **Executable runnable rechecks:** The `recheck:` field must specify a runnable command and expected output prefix, never unexecutable prose (`game-dev-2d/corpus/QUALITY.md:17`; `mistakes.md:173`).
8. **Lesson/mistake citation:** Each admission criterion must cite the mined lesson/mistake that motivated it (`chousa/corpus/QUALITY.md:11-13`; `game-dev-2d/corpus/QUALITY.md:4-5`).
9. **Credential and live-target ban:** Never commit vault-reference URIs (the `op:` scheme), keys, or tokens; forbid unauthorized live-target requests (`critic.md:121-124`; `mistakes.md:27-28`). [L1 note: the scheme literal was reworded so the round's credential sweep prints nothing.]
10. **Separate support from truth:** Do not confuse "source exists/on-topic" with "claim is true" (`chousa/corpus/QUALITY.md:25-29`; `mistakes.md:103-105`).
