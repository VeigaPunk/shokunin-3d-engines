# r88 SENTINEL — security review of the r88 delta

Scope: `corpus/fixtures/phys3d_events.gd` r88 delta (`_spawn_batch`, the
`_child_prepare`/`_child_scan` split, nine new arms 201–210) +
`run_battery.py`'s `--runs.resolve()` change. All exploits were executed live
on this host's Godot 4.7.2 against `corpus/live/r88-sentinel/proj/` — a
scratch project whose `phys3d_events.gd` is a byte copy of the fixture plus
one added `sentinel_batch` arm, so the exercised `_child_prepare` /
`_spawn_batch` / `_child_scan` / `_error_allowed` code paths are the shipped
ones verbatim. Evidence dir: `corpus/live/r88-sentinel/` (untracked scratch;
no tracked edits made by this seat — the `M corpus/fixtures/*` entries in
`git status` are the r88-critic wave's in-flight edits, not mine).

Environment note: `/bin/sh` -> `bash` on this host.

---

## S1 — Sibling log forgery: any batch child can rewrite another child's
##     verdict file (verdict integrity) — HIGH

**Exploit path.** `_spawn_batch` gives every child the same project tree:
child dirs are siblings under the parent's `res://` (`fmplain<m>`,
`fmjolt<m>`, `fmdummy` — all predictable names). A child's `FileAccess`
relative path resolves against *its own* `res://` root and `..` traverses
freely: from `svictim`'s sibling `sforger`, opening
`../svictim/child.log` in `WRITE` mode truncates and replaces the victim's
already-written log. Because `_spawn_batch` scans every log only *after* the
batch-wide wait loop exits, any child that outlives a sibling has a clean
window to rewrite that sibling's evidence.

**Live repro (real `_spawn_batch`).** Spec list: `svictim` (prints the
drifted verdict `CHILD_RESULT svictim_post=drifted_garbage`, exits 0),
`sforger` (sleeps 2.5 s, writes `../svictim/child.log` =
`CHILD_RESULT svictim_post=nil\nCHILD_RESULT injected=1\n`), `swedge`
(wedged, see S2). Run output:

    SENTINEL_B res0={ "code": 0, "verdicts": { "svictim_post": "nil",
        "injected": "1" }, "last": "CHILD_RESULT injected=1",
        "serr": false, ... }
    sforger/child.log: FORGE_OK wrote ../svictim/child.log

`svictim/child.log` on disk afterward contains *only* the forger's two
lines — the real `drifted_garbage` line is gone, and the forged file carries
no `ERROR:`/`SCRIPT ERROR`/`ObjectDB` lines, so `serr` reads `false`. The
fabrication is total: verdicts, `last`, `_log_count` witnesses (crash,
`previously freed`, refusal counts) and `serr` are all re-writable.

**Impact.** Two directions, both live:

- *Fail injection (DoS):* exact-dict cells (`freed_space_methods`'s
  `dmy["verdicts"] != want_dmy`, `fetch_gate`, `inactive_space`,
  `race_class`, `geom_split`) fail on one injected key — a buggy or hostile
  spec-probe child can kill the whole arm.
- *Pass fabrication:* the same rewrite can produce *exactly* `want_dmy` and
  scrub the real child's crash/`previously-freed`/`ERROR` evidence — the
  only unforgeable signals are `code` (real exit status) and
  `batch_timeout`. A cell whose real child exited 0 with drifted output
  becomes a clean pass. The r87 corroboration design ("count the engine's
  own lines in the log") corroborates a forgeable artifact: sibling-writable
  evidence is not evidence.

Today every spawned payload is authored in-repo, so this is a trust-boundary
defect rather than a live adversary — but `freed_space_methods` is a
13-process crash matrix precisely because its children are *expected* to
die in undefined ways, and the batch design invites spec-driven probes
(`script_res`, S3). The boundary the code assumes (child logs are the
child's private channel to the parent) does not exist.

**Smallest remediation.**
1. Scan each child *at exit* inside the wait loop (per-child, the moment
   `is_process_running` goes false), not once after the batch — shrinks the
   forge window to a race.
2. Reject `..`, `/`, `\`, and empty `dirname`/`script_name` (see S3) —
   removes the trivial `../sibling` spelling; children could still reach
   siblings via `DirAccess.open("..")` enumeration, so combine with (1).
3. Parser: refuse duplicate `CHILD_RESULT` keys (see S4).

---

## S2 — `OS.kill(pid)` kills the `/bin/sh` wrapper, not the wedged child —
##     deadline does NOT SIGKILL stragglers (MEDIUM)

The `_spawn_batch` comment claims "stragglers are SIGKILLed". They are not.

**Mechanism (live).** `OS.create_process("/bin/sh", ["-c", cmd])` returns
the **sh wrapper's** pid; on this host the shell stays as `timeout`'s
parent (observed: `sh` pid 3406165 -> `timeout` pid 3406166 -> godot).
`OS.kill(pid)` SIGKILLs only the shell. `timeout` is **reparented**
(post-kill ps shows `timeout 3406166 ppid=1203171`, alive) and keeps
enforcing `bound_s`; the wedged godot grandchild is untouched. Then
`OS.get_process_exit_code(pid)` hits `ECHILD`:

    ERROR: The process 3406165 does not exist or is not a child of the
    calling process.  (drivers/unix/os_unix.cpp:863)

and reports `code = 0` for the killed wrapper — the real batch run shows
`res2={ "code": 0, ... }` for the wedged child that was deadline-killed.

**Consequences.**

- The arm itself cannot hang past `BATCH_BOUND_S + ~40 ms` — the poll loop
  is deadline-bounded (measured `elapsed_ms=12007`). *That part holds.*
- But the "killed" payload survives the kill as an orphan and runs until
  its own `timeout` fires — up to `bound_s`, and `bound_s` defaults to
  **30** (`spec.get("bound_s", 30)`) while `BATCH_BOUND_S` is 12. A spec
  with `bound_s > 12` produces a child that outlives the declared batch
  bound by 18 s, still running, still able to write scratch (S1 forge, or
  the S3 selfpath trojan) while the parent has already moved on or exited.
  The battery's own per-case timeout (`subprocess.run(timeout=20)`)
  SIGKILLs only the *direct* parent godot — the reparented grandchild
  survives even that.
- The `ECHILD` engine error lands on the *parent's* stderr, which
  `run_battery.classify` counts as `unexpected diagnostic` — fail-closed,
  but the noise is incidental, not designed.
- `batch_timeout = running` is stamped on **all** rows — one wedged spec
  fails 12 healthy siblings. Intended ("never a silent partial row") but
  worth naming as DoS amplification when combined with S1.

**Smallest remediation.** Put each child in its own process group and kill
the group: prefix the command with `setsid` (`setsid /bin/sh -c '...'` —
the shell becomes group leader, `pgid == pid`), then replace
`OS.kill(pid)` with `OS.execute("kill", ["-KILL", "--", "-" + str(pid)])`.
Cap `bound_s <= BATCH_BOUND_S` (or compute the deadline as
`max(bound_s) + slack`), and treat a post-kill `get_process_exit_code`
`ECHILD`/`<=0` as 137 rather than reporting `code=0`.

---

## S3 — `dirname` traversal + shared-script trojan (HIGH)

- `_child_prepare` does `globalize_path("res://" + dirname)` with no
  sanitization. Live: spec `dirname="../escapeprobe"` produced
  `dir=.../proj/../escapeprobe`, `err=<null>` — `project.godot` written
  *outside* the intended subtree (dir now exists at
  `corpus/live/r88-sentinel/escapeprobe/`). The same `..` primitive is what
  S1's forger used from inside a child.
- Trojan escalation: the child argv literally contains
  `--script <abs>/phys3d_events.gd` (`selfpath`, the parent's running
  script), and `run_battery.py` reuses **one scratch dir for every case**.
  A child writing `../phys3d_events.gd` (one `..` hop from any child dir,
  same write primitive the forger used for `child.log`) replaces the script
  every *subsequent case* executes as its SceneTree main — arbitrary code
  plus fabricated `PASS` markers — while the battery's `seed_digests`
  integrity check stays green (it digests `corpus/fixtures/` only; the
  scratch copy is unprotected).
- `script_res` in a batch spec is globalized against the *parent's*
  project with no validation — any `res://` file, and absolute paths pass
  `globalize_path` through unchanged, so `--script /abs/x.gd` is accepted.
- `project_body` is written verbatim into `project.godot`; a spec controls
  the child's whole project config (engine, threading, autoloads).

All spec fields are authored in-repo today — this is the machinery
permitting escape, not an active exploit — but it means any future spec or
probe payload is unconstrained by design.

**Smallest remediation.** Validate `dirname`/`script_name`/`script_res`
in `_child_prepare`/`_spawn_probe`: reject empty, `..`, `/`, `\`, `:` and
absolute paths (`name.is_valid_filename()`-style); keep child dirs under
one dedicated subtree. Defense-in-depth: `run_battery` could copy the
fixture fresh per case (or hash `scratch/phys3d_events.gd` between cases)
so a trojaned script can't chain across cases.

---

## S4 — `CHILD_RESULT` parser is last-match-wins with no duplicate
##     detection (LOW-MEDIUM)

`_child_scan` sets `res["last"] = line` and `res["verdicts"][kv[0]] = kv[1]`
on **every** matching line — last match silently overwrites, duplicate keys
aren't flagged, and the pinned consumer (`threaded_edge`:
`spawned["last"] != expect`) trusts exactly that last line.

Live: a crafted log `CHILD_RESULT cell_k=first` … `CHILD_RESULT
cell_k=second` scanned to `verdicts={cell_k:"second"}` with `last` =
the final line; `serr` stayed `true` for the interleaved `ERROR:` (the
error channel is append-only — forging can't *remove* serr via more
`CHILD_RESULT` lines, only via S1's whole-file rewrite).

The r87 question — first, last, or all — is answered: **last, silently**.

Related rot: `freed_allow` includes `"were leaked at exit"` /
`"was leaked at exit"`, but the `ObjectDB … leaked` scan branch is
unconditional (not routed through `_error_allowed`), so those tokens can
never admit anything — dead allows that *look* like leak tolerance.

Injection surface inside a single child: `prints` emits embedded `\n`, so
any interpolated value containing `"\nCHILD_RESULT k=v"` forges a line.
All current values are engine scalars/class names — safe today, fragile by
construction.

**Smallest remediation.** In `_child_scan`, record a `dups` count (or set
`serr`) when a verdict key repeats; keep `last` semantics only where an arm
pins it. Drop or wire the dead leak tokens.

---

## S5 — kill-by-pid without identity check (LOW)

`OS.is_process_running`/`OS.kill` act on a bare pid: if the wrapper exits
and its pid is recycled before the deadline check, `OS.kill` SIGKILLs an
unrelated foreign process. The battery's own tree-timeout probe verifies
`/proc` starttime+cmdline before signaling; the fixture does not. Narrow
window on this workload; worth a comment or a `/proc/<pid>` identity check
alongside the S2 group-kill fix.

---

## (c) Freed-RID / node type-confusion across arms — checked, no defect

- Arms are one-per-process; children are separate processes. No cross-arm
  RID state exists. The only cross-lifetime channel is the filesystem
  (S1/S3), not RIDs.
- `owned`/`owned_nodes` are append-only and fully released on every exit
  via `_quit_clean` (nodes then RIDs). No parent arm frees `wspace`; the
  world-space `free_rid` exists only in child bodies (`fm_*`, `fd_dummy`,
  `fs_*`), where the resulting crashes are the pinned measurement and the
  dead-space cleanup errors are explicitly allowed via `freed_allow`.
- Dead-handle handling is guarded correctly: `_dss_live` uses
  `is_instance_valid` before `is` (which raises on freed objects), and
  `_fmt_read` dispatches on `typeof` first. The r88-scout hang class is
  handled by isolating each risky call in `_call_read`/`_held_space`
  helper frames.
- `inactive_space`'s teardown order (space registered **last** in `owned`,
  so contents free first) is the documented Jolt requirement — correct.
- Residual nit: `owned` never removes entries, so a RID freed mid-arm and
  reissued by the server would be double-freed at cleanup; nothing creates
  after `free_rid(wspace)` in the current arms, so it's latent only.

## Positive verifications

Stale-log unlink before spawn is intact; `allow_lines` is per-child in
batch specs; the child `match` is total (`var bad` → named rc 2);
`batch_timeout` fails closed across all rows; `Parse Error` stays
unconditional in the scan. The `run_battery.py` `--runs.resolve()` change
is a path canonicalization for the `/proc` cmdline witness — no new trust
surface found (scratch creation is unchanged; `seeds_unchanged` still
verifies the seed tree, though it deliberately does not cover scratch —
see S3).

## Repro artifacts

`corpus/live/r88-sentinel/proj/` — `sprobe.gd` (victim/forger payloads),
`swedge.gd` (wedged child), `tree_probe2.gd` (kill-semantics capture),
`phys3d_events.gd` (fixture copy + `sentinel_batch` arm), `run1.log`
(captured run: `SENTINEL_A/D/B` lines), plus the generated child dirs
(`svictim/` forged log, `sforger/`, `swedge/`) and `../escapeprobe/`
(traversal landing site).
