# SEAT-59 — physics carry check

## `free_ops` on the default environment

Command run, without a `--godot` override or environment prefix:

```sh
python3 corpus/fixtures/run_battery.py --only phys3d_joints_free_ops --runs /tmp/r105-seat59-physics
```

Observed: `PASS phys3d_joints_free_ops: exit=0 expected=0`; totals `cases=1 pass=1 fail=0 ordinary=1 negative_controls=0 probes=0`; `PASS battery`. Receipt: `/tmp/r105-seat59-physics/20261018T203107988723Z/verdicts.json`.

Environment check run: `python3 --version && command -v godot || command -v godot4` → `Python 3.14.7`, `/usr/bin/godot`. The runner's default Godot selection therefore resolves to `/usr/bin/godot`.

## `phys3d_joints.gd` carry from r104

Command run: `git log -1 --format=%H -- corpus/fixtures/phys3d_joints.gd` → `2ca87e846981279c3323eec72cb51e081b9c447f` (r104 physics-fix commit).

SHA comparison run:

```sh
git show 2ca87e846981279c3323eec72cb51e081b9c447f:corpus/fixtures/phys3d_joints.gd | sha256sum
sha256sum corpus/fixtures/phys3d_joints.gd
```

Both observed digests: `80bf44c53255a0a33b2282ca4e6278d42d82be4f616252925e128c928eca81e6` (r104 commit blob and current working file). The physics fix is unchanged from r104.
