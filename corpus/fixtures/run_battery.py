#!/usr/bin/env python3
"""Run the read-only game-dev-3d Godot fixtures serially in an isolated scratch project.

Seeds in this directory are never edited: every case runs against a copy under
corpus/live/runs/<ts>/scratch, and the run records a SHA-256 map of the seeds
before and after so that any mutation of a seed fails the battery.

Exit contract per case (authored in each fixture's header comment):
  exit 0 + exact stdout "PASS ..." marker                        -> positive passes
  exit 2 + exact stdout "NEGATIVE REJECTED: ..." marker          -> intended negative
  exit 1, timeout, crash, missing marker, SCRIPT ERROR/Parse
  Error, any unexpected ERROR: line, or an ObjectDB leak warning -> FAIL

Battery exit code is 0 only when every case passes.

Relative --runs paths are resolved against the current working directory,
including symlinks, before creating scratch. Godot globalizes descendant
paths; using the same canonical root keeps /proc identity checks independent
of the caller's path spelling without relaxing witness ownership checks.
"""
import argparse
import hashlib
import json
import os
import re
import select
import shutil
import signal
import subprocess
import time
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
CASE_TIMEOUT_SECONDS = 20

# (case name, script, flags, expected exit, exact stdout marker line)
CASES = [
    ("navagent3d_retarget", "navagent3d_retarget.gd", [], 0,
     "PASS navagent3d_retarget callbacks=120 before=1.730676,0.000,1.730676 after_end=1.000,0.000,3.000 final=1.000,0.000,3.000"),
    ("navagent3d_retarget_fixed", "navagent3d_retarget.gd", ["--fixed"], 2,
     "NEGATIVE REJECTED: navagent3d_retarget fixed callbacks=120 after_end=3.000,0.000,3.000 final=3.000,0.000,3.000"),
    ("navagent3d_follow", "navagent3d_follow.gd", [], 0,
     "PASS navagent3d_follow callbacks=90 first=1.612825,0.000,1.612825 final=3.000,0.000,3.000 reached=true"),
    ("navagent3d_follow_stationary", "navagent3d_follow.gd", ["--stationary"], 2,
     "NEGATIVE REJECTED: navagent3d_follow stationary callbacks=90 final=1.000,0.000,1.000 reached=false"),
    ("navagent3d_next", "navagent3d_next.gd", [], 0,
     "PASS navagent3d_next path_end=3.000,0.000,3.000 next=3.000,0.000,3.000"),
    ("navagent3d_next_alternate", "navagent3d_next.gd", ["--alternate"], 2,
     "NEGATIVE REJECTED: navagent3d_next alternate path_end=3.000,0.000,1.000 next=3.000,0.000,1.000"),
    ("navagent3d_distance", "navagent3d_distance.gd", [], 0,
     "PASS navagent3d_distance distance=2.828427 final=3.000,0.000,3.000 next=3.000,0.000,3.000 reached=false reachable=true finished=false"),
    ("navagent3d_distance_wide_reach", "navagent3d_distance.gd", ["--wide-reach"], 2,
     "NEGATIVE REJECTED: navagent3d_distance wide_reach distance=2.828427 reached=true finished=true reachable=true"),
    ("navagent3d_detour", "navagent3d_detour.gd", [], 0,
     "PASS navagent3d_detour distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,1.000 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_straight", "navagent3d_detour.gd", ["--straight"], 2,
     "NEGATIVE REJECTED: navagent3d_detour straight distance=2.828427 euclid=2.828427 pathlen=2.828427 discriminates=false"),
    ("navagent3d_detour_assert_pathsum", "navagent3d_detour.gd", ["--assert-pathsum"], 2,
     "NEGATIVE REJECTED: navagent3d_detour assert_pathsum distance=3.605551 expected_pathsum=4.130649 euclid=3.605551"),
    ("navagent3d_detour_post_edgecentered", "navagent3d_detour.gd", ["--post-edgecentered"], 0,
     "PASS navagent3d_detour post_edgecentered distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.707107 reachable=true reached=false finished=false"),
    ("navagent3d_detour_post_none", "navagent3d_detour.gd", ["--post-none"], 0,
     "PASS navagent3d_detour post_none distance=3.605551 semantic=euclidean final=2.500,0.000,3.500 next=2.000,0.000,0.500 pathlen=4.549510 reachable=true reached=false finished=false"),
    ("navagent3d_detour_pop_lo", "navagent3d_detour.gd", ["--arm=pop_lo"], 0,
     "PASS navagent3d_detour pop_lo idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_pop_hi", "navagent3d_detour.gd", ["--arm=pop_hi"], 0,
     "PASS navagent3d_detour pop_hi idx=2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_pop_sat", "navagent3d_detour.gd", ["--arm=pop_sat"], 0,
     "PASS navagent3d_detour pop_sat idx=2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mid_lo", "navagent3d_detour.gd", ["--arm=mid_lo"], 0,
     "PASS navagent3d_detour mid_lo idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.162278 pathlen=3.256617 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mid_hi", "navagent3d_detour.gd", ["--arm=mid_hi"], 0,
     "PASS navagent3d_detour mid_hi idx=2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.162278 pathlen=3.256617 reachable=true reached=false finished=false"),
    ("navagent3d_detour_vert_pop_eq", "navagent3d_detour.gd", ["--arm=vert_pop_eq"], 0,
     "PASS navagent3d_detour vert_pop_eq idx=1 next=2.000000,0.000000,1.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_vert_pop_above", "navagent3d_detour.gd", ["--arm=vert_pop_above"], 0,
     "PASS navagent3d_detour vert_pop_above idx=2 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_tp_mid", "navagent3d_detour.gd", ["--arm=tp_mid"], 0,
     "PASS navagent3d_detour tp_mid before_idx=1 after_idx=2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.036445 reachable=true reached=false finished=false"),
    ("navagent3d_detour_tp_eq", "navagent3d_detour.gd", ["--arm=tp_eq"], 0,
     "PASS navagent3d_detour tp_eq before_idx=1 after_idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.535534 reachable=true reached=false finished=false"),
    ("navagent3d_detour_gap2_pop_basis", "navagent3d_detour.gd", ["--arm=gap2_pop_basis"], 0,
     "PASS navagent3d_detour gap2_pop_basis idx=3 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=false reached=false finished=false"),
    ("navagent3d_detour_fin_unr_lo", "navagent3d_detour.gd", ["--arm=fin_unr_lo"], 0,
     "PASS navagent3d_detour fin_unr_lo idx=3 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=false reached=false finished=false"),
    ("navagent3d_detour_fin_unr_hi", "navagent3d_detour.gd", ["--arm=fin_unr_hi"], 0,
     "PASS navagent3d_detour fin_unr_hi idx=3 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=false reached=false finished=true"),
    ("navagent3d_detour_vert_fin_eq", "navagent3d_detour.gd", ["--arm=vert_fin_eq"], 0,
     "PASS navagent3d_detour vert_fin_eq idx=2 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_vert_fin_above", "navagent3d_detour.gd", ["--arm=vert_fin_above"], 0,
     "PASS navagent3d_detour vert_fin_above idx=2 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=3.354102 pathlen=3.000000 reachable=false reached=false finished=true"),
    ("navagent3d_detour_fin_reach_eq", "navagent3d_detour.gd", ["--arm=fin_reach_eq"], 0,
     "PASS navagent3d_detour fin_reach_eq idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=true reached=false finished=false"),
    ("navagent3d_detour_fin_reach_above", "navagent3d_detour.gd", ["--arm=fin_reach_above"], 0,
     "PASS navagent3d_detour fin_reach_above idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=2.500000 pathlen=4.581139 reachable=true reached=true finished=true"),
    ("navagent3d_detour_edge_unr", "navagent3d_detour.gd", ["--arm=edge_unr"], 0,
     "PASS navagent3d_detour edge_unr idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000 reachable=false reached=false finished=true"),
    ("navagent3d_detour_edge_eq", "navagent3d_detour.gd", ["--arm=edge_eq"], 0,
     "PASS navagent3d_detour edge_eq idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000 reachable=true reached=false finished=false"),
    ("navagent3d_detour_edge_above", "navagent3d_detour.gd", ["--arm=edge_above"], 0,
     "PASS navagent3d_detour edge_above idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000 reachable=true reached=true finished=true"),
    ("navagent3d_detour_fin_idx_gate", "navagent3d_detour.gd", ["--arm=fin_idx_gate"], 0,
     "PASS navagent3d_detour fin_idx_gate before_idx=1 after_idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=1.500000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_fin_wall", "navagent3d_detour.gd", ["--arm=fin_wall"], 0,
     "PASS navagent3d_detour fin_wall before_idx=1 after_idx=1 next=2.000000,0.000000,0.000000 final=2.000000,0.000000,3.000000 dist=0.500000 reachable=false reached=true finished=true"),
    ("navagent3d_detour_fin_latch", "navagent3d_detour.gd", ["--arm=fin_latch"], 0,
     "PASS navagent3d_detour fin_latch before_idx=1 after_idx=1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=2.500000 reachable=true reached=true finished=true"),
    ("navagent3d_detour_link_shortcut", "navagent3d_detour.gd", ["--arm=link_shortcut"], 0,
     "PASS navagent3d_detour link_shortcut idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=server meta=0 types=- ridat=-1 own=-"),
    ("navagent3d_detour_link_meta_types", "navagent3d_detour.gd", ["--arm=link_meta_types"], 0,
     "PASS navagent3d_detour link_meta_types idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=server meta=1 types=0,1,0,0 ridat=-1 own=-"),
    ("navagent3d_detour_link_meta_rids", "navagent3d_detour.gd", ["--arm=link_meta_rids"], 0,
     "PASS navagent3d_detour link_meta_rids idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=server meta=2 types=- ridat=1 own=-"),
    ("navagent3d_detour_link_meta_owners", "navagent3d_detour.gd", ["--arm=link_meta_owners"], 0,
     "PASS navagent3d_detour link_meta_owners idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=node meta=4 types=- ridat=-1 own=NavigationLink3D@1"),
    ("navagent3d_detour_link_meta", "navagent3d_detour.gd", ["--arm=link_meta"], 0,
     "PASS navagent3d_detour link_meta idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=node meta=7 types=0,1,0,0 ridat=1 own=NavigationLink3D@1"),
    ("navagent3d_detour_link_layers_off", "navagent3d_detour.gd", ["--arm=link_layers_off"], 0,
     "PASS navagent3d_detour link_layers_off idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false link=server meta=1 types=0,0,0 ridat=-1 own=-"),
    ("navagent3d_detour_link_layers_on", "navagent3d_detour.gd", ["--arm=link_layers_on"], 0,
     "PASS navagent3d_detour link_layers_on idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=server meta=1 types=0,1,0,0 ridat=-1 own=-"),
    ("navagent3d_detour_link_oneway_fwd", "navagent3d_detour.gd", ["--arm=link_oneway_fwd"], 0,
     "PASS navagent3d_detour link_oneway_fwd idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649 reachable=true reached=false finished=false link=server meta=1 types=0,0,1,0 ridat=-1 own=-"),
    ("navagent3d_detour_link_oneway_rev", "navagent3d_detour.gd", ["--arm=link_oneway_rev"], 0,
     "PASS navagent3d_detour link_oneway_rev idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false link=server meta=1 types=0,0,0 ridat=-1 own=-"),
    ("navagent3d_detour_link_disabled", "navagent3d_detour.gd", ["--arm=link_disabled"], 0,
     "PASS navagent3d_detour link_disabled idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false link=server meta=1 types=0,0,0 ridat=-1 own=-"),
    ("navagent3d_detour_link_travelcost", "navagent3d_detour.gd", ["--arm=link_travelcost"], 0,
     "PASS navagent3d_detour link_travelcost idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false link=server meta=1 types=0,0,0 ridat=-1 own=-"),
    ("navagent3d_detour_link_entercost", "navagent3d_detour.gd", ["--arm=link_entercost"], 0,
     "PASS navagent3d_detour link_entercost idx=1 next=1.500000,0.000000,0.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.192582 reachable=true reached=false finished=false link=server meta=1 types=0,1,0,0 ridat=-1 own=-"),
    ("navagent3d_detour_link_gap", "navagent3d_detour.gd", ["--arm=link_gap"], 0,
     "PASS navagent3d_detour link_gap idx=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false link=none meta=0 types=- ridat=-1 own=-"),
    ("navagent3d_detour_link_pop_bank", "navagent3d_detour.gd", ["--arm=link_pop_bank"], 0,
     "PASS navagent3d_detour link_pop_bank idx=2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649 reachable=true reached=false finished=false link=server meta=0 types=- ridat=-1 own=-"),
    ("navagent3d_detour_link_pop_void", "navagent3d_detour.gd", ["--arm=link_pop_void"], 0,
     "PASS navagent3d_detour link_pop_void idx=3 next=2.500000,0.000000,5.500000 final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649 reachable=true reached=false finished=false link=server meta=0 types=- ridat=-1 own=-"),
    ("navagent3d_detour_mv_walk", "navagent3d_detour.gd", ["--arm=mv_walk"], 0,
     "PASS navagent3d_detour mv_walk steps=3 idxs=1,2,2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=0.500000 pathlen=4.130649 reachable=true reached=true finished=true"),
    ("navagent3d_detour_mv_live", "navagent3d_detour.gd", ["--arm=mv_live"], 0,
     "PASS navagent3d_detour mv_live steps=2 idxs=2,2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=2.692582 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_popback", "navagent3d_detour.gd", ["--arm=mv_popback"], 0,
     "PASS navagent3d_detour mv_popback steps=2 idxs=2,2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_popstrict", "navagent3d_detour.gd", ["--arm=mv_popstrict"], 0,
     "PASS navagent3d_detour mv_popstrict steps=2 idxs=1,2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.525635 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_void", "navagent3d_detour.gd", ["--arm=mv_void"], 0,
     "PASS navagent3d_detour mv_void steps=1 idxs=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=1.000000 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_pmd_edge", "navagent3d_detour.gd", ["--arm=mv_pmd_edge"], 0,
     "PASS navagent3d_detour mv_pmd_edge steps=2 idxs=1,0 next=2.500000,0.000000,4.000000 final=2.500000,0.000000,3.500000 dist=2.500000 pathlen=0.500000 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_pmd_offmesh", "navagent3d_detour.gd", ["--arm=mv_pmd_offmesh"], 0,
     "PASS navagent3d_detour mv_pmd_offmesh steps=2 idxs=0,0 next=3.000000,0.000000,4.000000 final=2.500000,0.000000,3.500000 dist=3.354102 pathlen=0.707107 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_pmd2", "navagent3d_detour.gd", ["--arm=mv_pmd2"], 0,
     "PASS navagent3d_detour mv_pmd2 steps=1 idxs=0 next=2.500000,0.000000,4.000000 final=2.500000,0.000000,3.500000 dist=2.000000 pathlen=0.500000 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_latch", "navagent3d_detour.gd", ["--arm=mv_latch"], 0,
     "PASS navagent3d_detour mv_latch steps=2 idxs=1,1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=11.800424 pathlen=0.000000 reachable=true reached=true finished=true"),
    ("navagent3d_detour_mv_unlatch", "navagent3d_detour.gd", ["--arm=mv_unlatch"], 0,
     "PASS navagent3d_detour mv_unlatch steps=2 idxs=1,0 next=3.000000,0.000000,4.000000 final=2.000000,0.000000,3.000000 dist=11.800424 pathlen=1.414214 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_reanchor", "navagent3d_detour.gd", ["--arm=mv_reanchor"], 0,
     "PASS navagent3d_detour mv_reanchor steps=2 idxs=2,1 next=0.500000,0.000000,0.500000 final=0.500000,0.000000,0.500000 dist=1.000000 pathlen=1.000000 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_reanchor_same", "navagent3d_detour.gd", ["--arm=mv_reanchor_same"], 0,
     "PASS navagent3d_detour mv_reanchor_same steps=2 idxs=2,2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.162278 pathlen=3.256617 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_reanchor_bank", "navagent3d_detour.gd", ["--arm=mv_reanchor_bank"], 0,
     "PASS navagent3d_detour mv_reanchor_bank steps=2 idxs=1,2 next=2.500000,0.000000,5.500000 final=2.500000,0.000000,5.500000 dist=1.600000 pathlen=2.400002 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_reanchor_void", "navagent3d_detour.gd", ["--arm=mv_reanchor_void"], 0,
     "PASS navagent3d_detour mv_reanchor_void steps=2 idxs=1,1 next=2.500000,0.000000,4.000000 final=2.500000,0.000000,4.000000 dist=1.600000 pathlen=0.099998 reachable=false reached=false finished=true"),
    ("navagent3d_detour_mv_popskip", "navagent3d_detour.gd", ["--arm=mv_popskip"], 0,
     "PASS navagent3d_detour mv_popskip steps=1 idxs=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=0.707107 pathlen=4.130649 reachable=true reached=true finished=true"),
    ("navagent3d_detour_mv_reanchor_lazy", "navagent3d_detour.gd", ["--arm=mv_reanchor_lazy"], 0,
     "PASS navagent3d_detour mv_reanchor_lazy steps=2 idxs=2,1 next=2.900000,0.000000,3.900002 final=2.900000,0.000000,3.900002 dist=1.923539 pathlen=1.923540 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_reanchor_force", "navagent3d_detour.gd", ["--arm=mv_reanchor_force"], 0,
     "PASS navagent3d_detour mv_reanchor_force steps=3 idxs=2,2,2 next=2.900000,0.000000,3.900002 final=2.900000,0.000000,3.900002 dist=1.923539 pathlen=3.743553 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mv_bridge_walk", "navagent3d_detour.gd", ["--arm=mv_bridge_walk"], 0,
     "PASS navagent3d_detour mv_bridge_walk steps=3 idxs=2,3,3 next=2.500000,0.000000,5.500000 final=2.500000,0.000000,5.500000 dist=0.100000 pathlen=6.130649 reachable=true reached=true finished=true"),
    ("navagent3d_detour_mut_link_kill", "navagent3d_detour.gd", ["--arm=mut_link_kill"], 0,
     "PASS navagent3d_detour mut_link_kill steps=3 idxs=2,3,1 next=2.500000,0.000000,4.000000 final=2.500000,0.000000,4.000000 dist=2.100000 pathlen=0.600001 reachable=false reached=false finished=true"),
    ("navagent3d_detour_mut_link_drop", "navagent3d_detour.gd", ["--arm=mut_link_drop"], 0,
     "PASS navagent3d_detour mut_link_drop steps=2 idxs=1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=1.600000 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_link_layers", "navagent3d_detour.gd", ["--arm=mut_link_layers"], 0,
     "PASS navagent3d_detour mut_link_layers steps=1 idxs=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_layers_agent", "navagent3d_detour.gd", ["--arm=mut_layers_agent"], 0,
     "PASS navagent3d_detour mut_layers_agent steps=2 idxs=0,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mut_layers_region", "navagent3d_detour.gd", ["--arm=mut_layers_region"], 0,
     "PASS navagent3d_detour mut_layers_region steps=1 idxs=0 next=0.500000,0.000000,0.500000 final=0.000000,0.000000,0.000000 dist=3.605551 pathlen=0.000000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_region_move", "navagent3d_detour.gd", ["--arm=mut_region_move"], 0,
     "PASS navagent3d_detour mut_region_move steps=1 idxs=0 next=5.000000,0.000000,0.500000 final=5.000000,0.000000,1.000000 dist=3.605551 pathlen=0.500000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_region_off", "navagent3d_detour.gd", ["--arm=mut_region_off"], 0,
     "PASS navagent3d_detour mut_region_off steps=2 idxs=0,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mut_region_renew", "navagent3d_detour.gd", ["--arm=mut_region_renew"], 0,
     "PASS navagent3d_detour mut_region_renew steps=2 idxs=0,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mut_link_revive", "navagent3d_detour.gd", ["--arm=mut_link_revive"], 0,
     "PASS navagent3d_detour mut_link_revive steps=2 idxs=1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mut_lazy", "navagent3d_detour.gd", ["--arm=mut_lazy"], 0,
     "PASS navagent3d_detour mut_lazy steps=2 idxs=1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_latch_zombie", "navagent3d_detour.gd", ["--arm=mut_latch_zombie"], 0,
     "PASS navagent3d_detour mut_latch_zombie steps=2 idxs=1,1 next=2.000000,0.000000,3.000000 final=2.000000,0.000000,3.000000 dist=1.500000 pathlen=0.000000 reachable=true reached=true finished=true"),
    ("navagent3d_detour_mut_win_link", "navagent3d_detour.gd", ["--arm=mut_win_link"], 0,
     "PASS navagent3d_detour mut_win_link steps=4 idxs=2,3,3,1 next=2.500000,0.000000,4.000000 final=2.500000,0.000000,4.000000 dist=2.100000 pathlen=0.600001 reachable=false reached=false finished=true"),
    ("navagent3d_detour_mut_win_region", "navagent3d_detour.gd", ["--arm=mut_win_region"], 0,
     "PASS navagent3d_detour mut_win_region steps=4 idxs=1,1,1,0 next=5.000000,0.000000,0.500000 final=5.000000,0.000000,1.000000 dist=3.605551 pathlen=0.500000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_map_off", "navagent3d_detour.gd", ["--arm=mut_map_off"], 0,
     "PASS navagent3d_detour mut_map_off steps=3 idxs=1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,5.500000 dist=5.385165 pathlen=6.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mut_map_cycle", "navagent3d_detour.gd", ["--arm=mut_map_cycle"], 0,
     "PASS navagent3d_detour mut_map_cycle steps=4 idxs=1,1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_same_link", "navagent3d_detour.gd", ["--arm=mut_same_link"], 0,
     "PASS navagent3d_detour mut_same_link steps=3 idxs=2,2,2 next=2.500000,0.000000,4.000000 final=2.500000,0.000000,4.000000 dist=5.099020 pathlen=3.748488 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_same_region", "navagent3d_detour.gd", ["--arm=mut_same_region"], 0,
     "PASS navagent3d_detour mut_same_region steps=3 idxs=2,2,0 next=1.500000,0.000000,0.500000 final=0.000000,0.000000,0.000000 dist=3.162278 pathlen=0.000000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_same_agent", "navagent3d_detour.gd", ["--arm=mut_same_agent"], 0,
     "PASS navagent3d_detour mut_same_agent steps=4 idxs=2,2,0,2 next=2.500000,0.000000,3.500000 final=2.500000,0.000000,3.500000 dist=3.162278 pathlen=3.256617 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mut_ord_renew_xform", "navagent3d_detour.gd", ["--arm=mut_ord_renew_xform"], 0,
     "PASS navagent3d_detour mut_ord_renew_xform steps=1 idxs=0 next=5.000000,0.000000,0.500000 final=5.000000,0.000000,1.000000 dist=3.605551 pathlen=0.500000 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_ord_xform_renew", "navagent3d_detour.gd", ["--arm=mut_ord_xform_renew"], 0,
     "PASS navagent3d_detour mut_ord_xform_renew steps=1 idxs=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,3.500000 dist=3.605551 pathlen=4.130649 reachable=true reached=false finished=false"),
    ("navagent3d_detour_mut_ord_link_offmv", "navagent3d_detour.gd", ["--arm=mut_ord_link_offmv"], 0,
     "PASS navagent3d_detour mut_ord_link_offmv steps=1 idxs=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_ord_link_mvoff", "navagent3d_detour.gd", ["--arm=mut_ord_link_mvoff"], 0,
     "PASS navagent3d_detour mut_ord_link_mvoff steps=1 idxs=1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_ord_kill_mapoff", "navagent3d_detour.gd", ["--arm=mut_ord_kill_mapoff"], 0,
     "PASS navagent3d_detour mut_ord_kill_mapoff steps=3 idxs=1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_ord_mapoff_kill", "navagent3d_detour.gd", ["--arm=mut_ord_mapoff_kill"], 0,
     "PASS navagent3d_detour mut_ord_mapoff_kill steps=3 idxs=1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_force_link", "navagent3d_detour.gd", ["--arm=mut_force_link"], 0,
     "PASS navagent3d_detour mut_force_link steps=2 idxs=1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_force_ctl", "navagent3d_detour.gd", ["--arm=mut_force_ctl"], 0,
     "PASS navagent3d_detour mut_force_ctl steps=3 idxs=1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false"),
    ("navagent3d_detour_mut_ladder_link", "navagent3d_detour.gd", ["--arm=mut_ladder_link"], 0,
     "PASS navagent3d_detour mut_ladder_link steps=4 idxs=1,1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false bound=2 groups=2 sizes=2,2"),
    ("navagent3d_detour_mut_ladder_region", "navagent3d_detour.gd", ["--arm=mut_ladder_region"], 0,
     "PASS navagent3d_detour mut_ladder_region steps=5 idxs=1,1,1,0,0 next=5.000000,0.000000,0.500000 final=5.000000,0.000000,1.000000 dist=3.605551 pathlen=0.500000 reachable=false reached=false finished=false bound=3 groups=2 sizes=3,2"),
    ("navagent3d_detour_mut_mapoff_ladder", "navagent3d_detour.gd", ["--arm=mut_mapoff_ladder"], 0,
     "PASS navagent3d_detour mut_mapoff_ladder steps=6 idxs=1,1,1,1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false bound=5 groups=2 sizes=5,1"),
    ("navagent3d_detour_mut_ctx_resume", "navagent3d_detour.gd", ["--arm=mut_ctx_resume"], 0,
     "PASS navagent3d_detour mut_ctx_resume steps=3 idxs=1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false bound=2 groups=2 sizes=2,1"),
    ("navagent3d_detour_mut_ctx_phys", "navagent3d_detour.gd", ["--arm=mut_ctx_phys"], 0,
     "PASS navagent3d_detour mut_ctx_phys steps=3 idxs=1,1,1 next=2.000000,0.000000,1.000000 final=2.500000,0.000000,4.000000 dist=5.385165 pathlen=4.622520 reachable=false reached=false finished=false bound=1 groups=2 sizes=1,2"),
    ("remote3d_transform", "remote3d_transform.gd", [], 0,
     "PASS remote3d_transform bound target=2.000,1.000,-3.000 basis_x=0.000,1.000,0.000"),
    ("remote3d_transform_unbound", "remote3d_transform.gd", ["--unbound"], 2,
     "NEGATIVE REJECTED: remote3d_transform unbound target=0.000,0.000,0.000 source=2.000,1.000,-3.000"),
    ("pathfollow3d_callback", "pathfollow3d_callback.gd", [], 0,
     "PASS pathfollow3d_callback callbacks=60 delta_sum=1.000 progress=3.000 first_y=1.105767 second_y=1.997535"),
    ("pathfollow3d_callback_stationary", "pathfollow3d_callback.gd", ["--stationary"], 2,
     "NEGATIVE REJECTED: pathfollow3d_callback stationary callbacks=60 progress=0.000"),
    ("pathfollow3d_paced", "pathfollow3d_paced.gd", [], 0,
     "PASS pathfollow3d_paced speed=3.000 progress=3.000 first_y=1.105767 second_y=1.997535"),
    ("pathfollow3d_paced_stationary", "pathfollow3d_paced.gd", ["--stationary"], 2,
     "NEGATIVE REJECTED: pathfollow3d_paced stationary progress=0.000 first_y=0.000 second_y=0.000"),
    ("pathfollow3d_curve", "pathfollow3d_curve.gd", [], 0,
     "PASS pathfollow3d_curve bent first_y=1.118620 second_y=1.118619 marker_offset_z=1.000"),
    ("pathfollow3d_curve_straight", "pathfollow3d_curve.gd", ["--straight"], 2,
     "NEGATIVE REJECTED: pathfollow3d_curve straight first_y=0.000 second_y=0.000 marker_offset_z=1.000"),
    ("curve3d_path", "curve3d_path.gd", [], 0,
     "PASS curve3d_path bent length=6.072724 quarter_y=1.118591 midpoint_y=2.000000"),
    ("curve3d_path_straight", "curve3d_path.gd", ["--straight"], 2,
     "NEGATIVE REJECTED: curve3d_path straight length=4.472136 midpoint=2.000,0.000,1.000"),
    ("shapecast3d_graze", "shapecast3d_graze.gd", [], 0,
     "PASS shapecast3d_graze radius=0.500 sphere_hits=1 ray_hits=0 point=1.000,0.000,1.000 safe=0.425781"),
    ("shapecast3d_graze_small", "shapecast3d_graze.gd", ["--small"], 2,
     "NEGATIVE REJECTED: shapecast3d_graze small_radius=0.100 sphere_hits=0 ray_hits=0"),
    ("shapecast3d_sphere", "shapecast3d_sphere.gd", [], 0,
     "PASS shapecast3d_sphere radius=0.500 contact_z=1.000 safe=0.414062 unsafe=0.417969 hits=1"),
    ("shapecast3d_sphere_offset", "shapecast3d_sphere.gd", ["--offset"], 2,
     "NEGATIVE REJECTED: shapecast3d_sphere lateral_miss x=4.000 hits=0 safe=1.000"),
    ("skeleton3d_attachment", "skeleton3d_attachment.gd", [], 0,
     "PASS skeleton3d_attachment parent_z=90 attached_marker=-3.000,1.000,0.000"),
    ("skeleton3d_attachment_unrotated", "skeleton3d_attachment.gd", ["--unrotated"], 2,
     "NEGATIVE REJECTED: skeleton3d_attachment unrotated attached_marker=1.000,3.000,0.000"),
    ("skeleton3d_rotation", "skeleton3d_rotation.gd", [], 0,
     "PASS skeleton3d_rotation parent_z=90 child_global=-3.000,0.000,0.000 basis_x=0.000,1.000,0.000"),
    ("skeleton3d_unrotated", "skeleton3d_rotation.gd", ["--unrotated"], 2,
     "NEGATIVE REJECTED: skeleton3d_rotation unrotated child_global=0.000,3.000,0.000 basis_x=1.000,0.000,0.000"),
    ("skeleton3d_pose", "skeleton3d_pose.gd", [], 0,
     "PASS skeleton3d_pose parent=0 child_rest=1.000,2.000,0.000 child_pose_y=3.000"),
    ("skeleton3d_rest_only", "skeleton3d_pose.gd", ["--rest-only"], 2,
     "NEGATIVE REJECTED: skeleton3d_pose rest_only child_rest=1.000,2.000,0.000 child_pose_y=0.000"),
    ("mesh3d_faces_hit", "mesh3d_faces_hit.gd", [], 0,
     "PASS mesh3d_faces_hit two_faces face_a=0 face_b=1 outside_hits=0"),
    ("mesh3d_faces_reordered", "mesh3d_faces_hit.gd", ["--reversed"], 2,
     "NEGATIVE REJECTED: mesh3d_faces_hit reordered face_a=1 face_b=0 outside_hits=0"),
    ("mesh3d_trimesh_hit", "mesh3d_trimesh_hit.gd", [], 0,
     "PASS mesh3d_trimesh_hit interior_hit=0.500,0.500,0.000 normal_z=1.000 face_index=0 outside_hits=0"),
    ("mesh3d_trimesh_outside", "mesh3d_trimesh_hit.gd", ["--outside"], 2,
     "NEGATIVE REJECTED: mesh3d_trimesh_hit outside_ray control_hit=0.500,0.500,0.000 outside_hits=0 face_index=0"),
    ("mesh3d_indexed", "mesh3d_indexed.gd", [], 0,
     "PASS mesh3d_indexed forward_indices triangles=2 cross_z=6.000 shared_vertices=4"),
    ("mesh3d_indexed_reversed", "mesh3d_indexed.gd", ["--reversed"], 2,
     "NEGATIVE REJECTED: mesh3d_indexed reversed_indices triangles=2 cross_z=-6.000 shared_vertices=4"),
    ("mesh3d_array", "mesh3d_array.gd", [], 0,
     "PASS mesh3d_array triangle last_z=0.000 aabb_size=2.000,3.000,0.00001"),
    ("mesh3d_array_shifted", "mesh3d_array.gd", ["--shifted"], 2,
     "NEGATIVE REJECTED: mesh3d_array shifted_vertex last_z=1.000 aabb_size=2.000,3.000,1.000"),
    ("animation3d_blend", "animation3d_blend.gd", [], 0,
     "PASS animation3d_blend fade_seconds=0.5 mid_x=1.931 end_x=4.000 physics_frames=15+30"),
    ("animation3d_blend_cut", "animation3d_blend.gd", ["--cut"], 2,
     "NEGATIVE REJECTED: animation3d_blend instant_cut mid_x=4.000 end_x=4.000"),
    ("animation3d_playback", "animation3d_playback.gd", [], 0,
     "PASS animation3d_playback mid_x=0.967 later_x=1.967 physics_frames=60 playing=true"),
    ("animation3d_playback_still", "animation3d_playback.gd", ["--still"], 2,
     "NEGATIVE REJECTED: animation3d_playback constant_track mid_x=0.000 later_x=0.000 physics_frames=60"),
    ("animation3d_keys", "animation3d_keys.gd", [], 0,
     "PASS animation3d_keys position_track mid_x=2.000 end_x=4.000 seek_update=true"),
    ("animation3d_keys_still", "animation3d_keys.gd", ["--still"], 2,
     "NEGATIVE REJECTED: animation3d_keys constant_track mid_x=0.000 end_x=0.000"),
    ("slope3d_travel", "slope3d_travel.gd", [], 0,
     "PASS slope3d_travel downhill_x=-0.0810 y=1.3203 grounded_ticks=52 normal_y=0.866 stop_on_slope=false"),
    ("slope3d_travel_level", "slope3d_travel.gd", ["--level"], 2,
     "NEGATIVE REJECTED: slope3d_travel level_no_downhill x=0.0000 y=1.0001 grounded_ticks=44 normal_y=1.000"),
    ("jump3d_land", "jump3d_gravity.gd", [], 0,
     "PASS jump3d_gravity apex_tick=29 apex_y=2.451 landing_tick=60 final_y=1.001 initially_grounded=true grounded=true"),
    ("jump3d_no_floor", "jump3d_gravity.gd", ["--lower-floor"], 2,
     "NEGATIVE REJECTED: jump3d_gravity no_floor_landing apex_tick=29 apex_y=2.450 final_y=0.900 initially_grounded=false grounded=false floor_intact=true"),
    ("camera3d_ortho_far_boundary_exact", "camera3d_ortho.gd", ["--far-boundary-exact"], 0,
     "PASS camera3d_ortho far_boundary_exact depth=10.000 screen=550.000,225.000 in_frustum=true api_behind=false inside_control=true outside_control=false"),
    ("camera3d_ortho_far_boundary_inside", "camera3d_ortho.gd", ["--far-boundary-inside"], 0,
     "PASS camera3d_ortho far_boundary_inside depth=9.990 screen=550.000,225.000 in_frustum=true outside_control=false"),
    ("camera3d_ortho_far_boundary_outside", "camera3d_ortho.gd", ["--far-boundary-outside"], 2,
     "NEGATIVE REJECTED: camera3d_ortho far_boundary_outside depth=10.010 screen=550.000,225.000 in_frustum=false api_behind=false inside_control=true"),
    ("camera3d_ortho_near_boundary_exact", "camera3d_ortho.gd", ["--near-boundary-exact"], 0,
     "PASS camera3d_ortho near_boundary_exact depth=1.000 screen=550.000,225.000 in_frustum=true api_behind=false inside_control=true outside_control=false"),
    ("camera3d_ortho_near_boundary_inside", "camera3d_ortho.gd", ["--near-boundary-inside"], 0,
     "PASS camera3d_ortho near_boundary_inside depth=1.010 screen=550.000,225.000 in_frustum=true outside_control=false"),
    ("camera3d_ortho_near_boundary_outside", "camera3d_ortho.gd", ["--near-boundary-outside"], 2,
     "NEGATIVE REJECTED: camera3d_ortho near_boundary_outside depth=0.990 screen=550.000,225.000 in_frustum=false api_behind=true inside_control=true"),
    ("camera3d_ortho", "camera3d_ortho.gd", [], 0,
     "PASS camera3d_ortho viewport=800,600 front_screen=550.000,225.000 deep_screen=550.000,225.000 near=1.000 far=10.000"),
    ("camera3d_ortho_outside", "camera3d_ortho.gd", ["--outside"], 2,
     "NEGATIVE REJECTED: camera3d_ortho lateral_outside screen=850.000,225.000 in_frustum=false controls_same_pixel=true"),
    ("camera3d_ortho_near", "camera3d_ortho.gd", ["--near-point"], 2,
     "NEGATIVE REJECTED: camera3d_ortho near_plane_depth=0.500 screen=550.000,225.000 in_frustum=false api_behind=true geometric_front=true controls_same_pixel=true"),
    ("camera3d_ortho_far", "camera3d_ortho.gd", ["--far-point"], 2,
     "NEGATIVE REJECTED: camera3d_ortho far_plane_depth=12.000 screen=550.000,225.000 in_frustum=false api_behind=false geometric_front=true controls_same_pixel=true"),
    ("scene3d_resource_disk_local", "scene3d_resource_disk.gd", [], 0,
     "PASS scene3d_resource_disk local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true"),
    ("scene3d_resource_disk_shared", "scene3d_resource_disk.gd", ["--shared"], 2,
     "NEGATIVE REJECTED: scene3d_resource_disk shared_mesh_mutation second_size=2.000,1.000,1.000 loaded_size=2.000,1.000,1.000 same_resource=true"),
    ("scene3d_resource_local", "scene3d_resource.gd", [], 0,
     "PASS scene3d_resource local_mesh_mutation first_size=2.000,1.000,1.000 second_size=1.000,1.000 distinct_resources=true"),
    ("scene3d_resource_shared", "scene3d_resource.gd", ["--shared"], 2,
     "NEGATIVE REJECTED: scene3d_resource shared_mesh_mutation second_size=2.000,1.000,1.000 source_size=2.000,1.000,1.000 same_resource=true"),
    ("scene3d_disk", "scene3d_disk.gd", [], 0,
     "PASS scene3d_disk loaded_world=11.000,2.000,2.000 source_intact=true mesh_present=true"),
    ("scene3d_disk_wrong_local", "scene3d_disk.gd", ["--wrong-local"], 2,
     "NEGATIVE REJECTED: scene3d_disk loadable_wrong_local source_intact=true loaded_world=12.000,2.000,2.000 expected_world=11.000,2.000,2.000 mesh_present=true"),
    ("scene3d_instances", "scene3d_instance.gd", [], 0,
     "PASS scene3d_instances source_intact=true first_world=11.000,2.000,-3.000 second_world=-9.000,2.000,2.000 distinct_nodes=true"),
    ("scene3d_instances_wrong_local", "scene3d_instance.gd", ["--wrong-local"], 2,
     "NEGATIVE REJECTED: scene3d_instances wrong_second_local source_intact=true first_world=11.000,2.000,-3.000 second_world=-8.000,2.000,2.000 expected_second=-9.000,2.000,2.000"),
    ("slope3d_floor", "slope3d_angle.gd", [], 0,
     "PASS slope3d_floor normal_y=0.866 floor_limit=45.000 on_floor=true on_wall=false live_contact=true"),
    ("slope3d_steep", "slope3d_angle.gd", ["--steep"], 2,
     "NEGATIVE REJECTED: slope3d_angle steep_contact_not_floor normal_y=0.500 floor_limit=45.000 on_floor=false on_wall=true live_contact=true"),
    ("floor3d_ground", "floor3d_ground.gd", [], 0,
     "PASS floor3d_ground final_y=1.000 first_contact_tick=30 normal=0.000,1.000,0.000 on_floor=true ticks=60"),
    ("floor3d_airborne", "floor3d_ground.gd", ["--lower-floor"], 2,
     "NEGATIVE REJECTED: floor3d_ground airborne_with_lower_floor final_y=-2.000 contacts=0 on_floor=false floor_intact=true ticks=60"),
    ("body3d_contact", "body3d_slide.gd", [], 0,
     "PASS body3d_contact start_z=6.000 expected_plane_z=2.500 final_z=2.500 ticks=60 "
     "first_contact_tick=21 on_wall=true normal=0.000,0.000,1.000"),
    ("body3d_contact_far", "body3d_slide.gd", ["--far-body"], 2,
     "NEGATIVE REJECTED: body3d_contact no_contact_at_far_arrangement start_z=40.000 "
     "final_z=30.000 expected_plane_z=2.500 contacts=0 on_wall=false wall_intact=true"),
    ("area3d_chain", "area3d_chain.gd", [], 0,
     "PASS area3d_chain collected=1 entries=1 overlapping=1 body_name=Runner3D "
     "body_layer=2 entry_x=4.200 pickup_x=6.000"),
    ("area3d_chain_no_overlap", "area3d_chain.gd", ["--no-overlap"], 2,
     "NEGATIVE REJECTED: area3d_chain no_overlap_signal_absent collected=0 entries=0 "
     "overlapping=0 runner_x=6.000 pickup_x=40.000 monitoring=true mask_matches_layer=true"),
    ("camera3d_project", "camera3d_project.gd", [], 0,
     "PASS camera3d_project viewport=800,600 fov=90.000 proj_x_scale=0.750 "
     "proj_y_scale=1.000 world=2.000,1.000,-4.000 screen=550.000,225.000 "
     "center_screen=400.000,300.000 mirror_screen=250.000,375.000 behind=false in_frustum=true"),
    ("camera3d_project_behind", "camera3d_project.gd", ["--behind-camera"], 2,
     "NEGATIVE REJECTED: camera3d_project behind_camera_projection_rejected "
     "point=2.000,1.000,4.000 is_position_behind=true in_frustum=false "
     "raw_screen=250.000,375.000 collides_with_mirrored_control=true "
     "lateral_screen=3400.000,300.000 lateral_in_frustum=false in_front_control_accepted=true"),
    ("camera3d_depth", "camera3d_depth.gd", [], 0,
     "PASS camera3d_depth camera=10.000,0.000,0.000 visible=14.000,1.000,2.000 "
     "screen=550.000,225.000 depth=4.000 far=10.000 near=1.000"),
    ("camera3d_depth_far", "camera3d_depth.gd", ["--far-point"], 2,
     "NEGATIVE REJECTED: camera3d_depth far_point_depth=12.000 screen=550.000,225.000 "
     "in_frustum=false behind=false near_control_visible=true"),
    ("camera3d_depth_near", "camera3d_depth.gd", ["--near-point"], 2,
     "NEGATIVE REJECTED: camera3d_depth near_point_depth=0.500 screen=550.000,225.000 "
     "in_frustum=false api_behind=true geometric_front=true near_control_visible=true"),
    ("navigation3d_path", "navigation3d_path.gd", [], 0,
     "PASS navigation3d_path points=2 start=1.000,0.000,1.000 end=3.000,0.000,3.000 region_active=true"),
    ("navigation3d_path_disconnected", "navigation3d_path.gd", ["--disconnected"], 2,
     "NEGATIVE REJECTED: navigation3d_path disconnected_endpoint_rejected "
     "source_end=4.000,0.000,3.000 target_end=23.000,0.000,3.000 "
     "source_control_points=2 target_control_points=2"),
    ("raycast3d_hit", "raycast3d.gd", [], 0,
     "PASS raycast3d hits=1 position=0.000,2.000,0.000 normal=0.000,1.000,0.000 "
     "collider=Wall collider_id_matches=true miss_hits=0"),
    ("raycast3d_miss", "raycast3d.gd", ["--miss-ray"], 2,
     "NEGATIVE REJECTED: raycast3d miss_ray_no_hit control_hits=1 "
     "control_position=0.000,2.000,0.000 miss_from=0.000,6.000,9.000 miss_hits=0 "
     "miss_offset_z=9.000 box_half_depth_z=2.000"),
    ("transform3d_compose", "transform3d_compose.gd", [], 0,
     "PASS transform3d_compose parent_origin=2.000,0.000,0.000 "
     "child_local_origin=0.000,0.000,-3.000 global_origin=-1.000,0.000,0.000 "
     "basis_x=0.000,0.000,-1.000 basis_y=1.000,0.000,0.000 basis_z=0.000,-1.000,0.000 "
     "composition_identity=true determinant=1.000 wrong_order_rejected=true"),
    ("transform3d_compose_wrong_order", "transform3d_compose.gd", ["--wrong-order"], 2,
     "NEGATIVE REJECTED: transform3d_compose wrong_order_composition_rejected "
     "expected_origin=-1.000,0.000,0.000 wrong_order_origin=2.000,0.000,-3.000 "
     "expected_basis_x=0.000,0.000,-1.000 wrong_order_basis_x=0.000,1.000,0.000 "
     "correct_order_matches=true"),
    ("input3d_move", "input3d_move.gd", [], 0,
     "PASS input3d_move key=W receipts=1 releases=1 ticks=10 "
     "displacement=1.000,0.000,0.000 expected_x=1.000 post_release_ticks=5 "
     "post_release_displacement=0.000"),
    ("input3d_move_no_event", "input3d_move.gd", ["--no-input"], 2,
     "NEGATIVE REJECTED: input3d_move no_event_zero_displacement receipts=0 intent=false "
     "ticks=10 displacement=0.000,0.000,0.000 late_control_receipts=1 late_control_ticks=5 "
     "late_control_displacement=0.500"),
    ("phys3d_events_isect", "phys3d_events.gd", ["--arm=isect"], 0,
     "PASS phys3d_events isect settled=1 mask2=0 away_w0=0 away_n1=0 back_w0=1"),
    ("phys3d_events_cast", "phys3d_events.gd", ["--arm=cast"], 0,
     "PASS phys3d_events cast settled_safe=0.144531 settled_unsafe=0.150391 w0=1.000000 n1=1.000000"),
    ("phys3d_events_btm", "phys3d_events.gd", ["--arm=btm"], 0,
     "PASS phys3d_events btm settled_hit=true settled_travel=-0.976562 w0_hit=false w0_travel=-10.000000 n1_hit=false"),
    ("phys3d_events_pp_queries", "phys3d_events.gd", ["--arm=pp_queries"], 0,
     "PASS phys3d_events pp_queries ray_hit=false isect=0 safe=1.000000 btm=false travel=-10.000000"),
    ("phys3d_events_contact_stale", "phys3d_events.gd", ["--arm=contact_stale"], 0,
     "PASS phys3d_events contact_stale in_w0_c=0 in_w0_isect=1 in_n1_c=4 out_w0_c=4 out_n1_c=0"),
    ("phys3d_events_contact_sig", "phys3d_events.gd", ["--arm=contact_sig"], 0,
     "PASS phys3d_events contact_sig w0_fired=false w0_overlaps=0 n1_entered=true delta=1 n1_overlaps=1"),
    ("phys3d_events_sync_cb", "phys3d_events.gd", ["--arm=sync_cb"], 0,
     "PASS phys3d_events sync_cb w0=0 n1=1 n3=3 static_cb=0"),
    ("phys3d_events_srv_area_cb", "phys3d_events.gd", ["--arm=srv_area_cb"], 0,
     "PASS phys3d_events srv_area_cb enter=1 exit=1 reenter=1 all_delta1=true"),
    ("phys3d_events_static_nopair", "phys3d_events.gd", ["--arm=static_nopair"], 2,
     "NEGATIVE REJECTED: phys3d_events static_nopair static_tp_fired=false ticks=3 area_move_delta=1"),
    ("phys3d_events_threaded_edge", "phys3d_events.gd", ["--arm=threaded_edge"], 0,
     "PASS phys3d_events threaded_edge pp_edge0=true proc_dss_refused=true srv_ok=true child_exit=0"),
    ("phys3d_events_phase_delta", "phys3d_events.gd", ["--arm=phase_delta"], 0,
     "PASS phys3d_events phase_delta proc_delta=2 phys_delta=1"),
    ("phys3d_events_jolt_edge", "phys3d_events.gd", ["--arm=jolt_edge"], 0,
     "PASS phys3d_events jolt_edge backend=Jolt isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0"),
    ("phys3d_events_jolt_threaded", "phys3d_events.gd", ["--arm=jolt_threaded"], 0,
     "PASS phys3d_events jolt_threaded backend=Jolt threaded=true isect=same cast=constants btm=constants contact_stale=same static_nopair=inverts child_exit=0"),
    ("phys3d_events_dummy_refused", "phys3d_events.gd", ["--arm=dummy_refused"], 0,
     "PASS phys3d_events dummy_refused backend=Dummy isect=unexpected cast=unexpected btm=unexpected contact_stale=unexpected static_nopair=unexpected child_exit=0"),
    ("phys3d_events_srv_phase_delta", "phys3d_events.gd", ["--arm=srv_phase_delta"], 0,
     "PASS phys3d_events srv_phase_delta srv_proc_delta=2 srv_phys_delta=1"),
    ("phys3d_events_script_size_gate", "phys3d_events.gd", ["--arm=script_size_gate"], 0,
     "PASS phys3d_events script_size_gate min_thr=refused min_plain=granted pad_thr=granted fixture_thr=granted child_exit=0"),
    ("phys3d_events_deferred_hang", "phys3d_events.gd", ["--arm=deferred_hang"], 0,
     "PASS phys3d_events deferred_hang threaded_rc=137 abort=true no_marker=true dummy_rc=0 floor_no_hang=true child_exit=0"),
    ("phys3d_events_backend_tier", "phys3d_events.gd", ["--arm=backend_tier"], 0,
     "PASS phys3d_events backend_tier plain=honors jolt=ignores dummy=floor margin=inert,binds,empty sepray=same,differs,floor child_exit=0"),
    ("phys3d_events_dummy_floor", "phys3d_events.gd", ["--arm=dummy_floor"], 0,
     "PASS phys3d_events dummy_floor dummy=silent-floor dummy_errs=0 real=real-values real_errs=2 child_exit=0"),
    # r87 body-tier deferred-state lattice. Appended at the tail, insertion-only;
    # the crash-class row (`freed_space`) is the last row in the file.
    ("phys3d_events_body_handle", "phys3d_events.gd", ["--arm=body_handle"], 0,
     "PASS phys3d_events body_handle if_same=true ss_same=true detach=nil held_live=true reattach=true twin=true dummy_cb=never child_exit=0"),
    ("phys3d_events_acq_use", "phys3d_events.gd", ["--arm=acq_use"], 0,
     "PASS phys3d_events acq_use gate=refused out_of_phase=8 held_read=live write=ungated reps=8 child_exit=0"),
    ("phys3d_events_step_stamp", "phys3d_events.gd", ["--arm=step_stamp"], 0,
     "PASS phys3d_events step_stamp gp_step_pre=0.001 gp_grav_pre=zero jolt_step_pre=0.0 jolt_grav_pre=real step_post=0.016667 cc_off=0 cc_on=4 last_step=4,0 child_exit=0"),
    ("phys3d_events_write_loss", "phys3d_events.gd", ["--arm=write_loss"], 0,
     "PASS phys3d_events write_loss gate=refused reps=8 same_turn=8 race=bounded child_exit=0"),
    ("phys3d_events_body_tier", "phys3d_events.gd", ["--arm=body_tier"], 0,
     "PASS phys3d_events body_tier gp_impulse=zero jolt_impulse=real gp_lshape=-1 jolt_lshape=0 gp_sleep_lv=kept jolt_sleep_lv=zeroed dummy_cc=0 detach_write=silent,loud,silent child_exit=0"),
    ("phys3d_events_freed_space", "phys3d_events.gd", ["--arm=freed_space"], 0,
     "PASS phys3d_events freed_space gp=crash jolt=crash dummy=empty child_exit=0"),
    # r88 query-tier read family (PhysicsDirectSpaceState3D + the
    # PhysicsDirectBodyState3D inertia getters). Appended at the tail,
    # insertion-only; the two rows whose children can crash
    # (`race_class`, `freed_space_methods`) are last, the freed-space
    # matrix last of all (the r87 freed_space row precedent).
    ("phys3d_events_motion_split", "phys3d_events.gd", ["--arm=motion_split"], 0,
     "PASS phys3d_events motion_split gp=wide jolt=tight dummy=floor split=cm_only child_exit=0"),
    ("phys3d_events_fetch_gate", "phys3d_events.gd", ["--arm=fetch_gate"], 0,
     "PASS phys3d_events fetch_gate plain=open thr=phase jolt_thr=phase dummy=open byp=held_same child_exit=0"),
    ("phys3d_events_inactive_space", "phys3d_events.gd", ["--arm=inactive_space"], 0,
     "PASS phys3d_events inactive_space plain=open thr=phase jolt_thr=phase alts=answered sig=wall_only child_exit=0"),
    ("phys3d_events_param_purity", "phys3d_events.gd", ["--arm=param_purity"], 0,
     "PASS phys3d_events param_purity pure=6/6 prec=rid fresh=3/3 child_exit=0"),
    ("phys3d_events_body_inertia", "phys3d_events.gd", ["--arm=body_inertia"], 0,
     "PASS phys3d_events body_inertia gp=box jolt=box dummy=floor tensor=world st=zeros,placeholders child_exit=0"),
    ("phys3d_events_wrong_args", "phys3d_events.gd", ["--arm=wrong_args"], 0,
     "PASS phys3d_events wrong_args cells=13 typed=empty rc=0 text=same,floor child_exit=0"),
    ("phys3d_events_geom_split", "phys3d_events.gd", ["--arm=geom_split"], 0,
     "PASS phys3d_events geom_split gp=boundary1,wide,tilt jolt=boundary2,tight,up child_exit=0"),
    ("phys3d_events_race_class", "phys3d_events.gd", ["--arm=race_class"], 0,
     "PASS phys3d_events race_class gp=classes jolt=crash-or-classes reps=4 child_exit=0"),
    ("phys3d_events_freed_space_methods", "phys3d_events.gd",
     ["--arm=freed_space_methods"], 0,
     "PASS phys3d_events freed_space_methods gp=crash6@post_fetch jolt=crash-or-dead@post_fetch dummy=empty child_exit=0"),
    # r89 body-state lattice (PhysicsDirectBodyState3D phase order + the
    # contact record's impulse lag, the _integrate_forces interior rules, the
    # joint family's pin witness / per-parameter drop table / solver priority
    # and RID lifecycle, cross-space handles, the sleeping body). Appended at
    # the tail, insertion-only. No row of this block is crash-capable: the one
    # crash class the block met — Jolt aborting inside free_rid when a space is
    # released before the bodies living in it — was fixed in the child's
    # teardown order (the r88 rule), not pinned as an envelope, so the
    # crash-capable rows above keep their tail position among crash rows.
    ("phys3d_events_if_phase", "phys3d_events.gd", ["--arm=if_phase"], 0,
     "PASS phys3d_events if_phase gp=lag jolt=same if_eq_e=true child_exit=0"),
    ("phys3d_events_if_write", "phys3d_events.gd", ["--arm=if_write"], 0,
     "PASS phys3d_events if_write immediate=vel,xform,impulse deferred=force,torque sleep=kept,jolt_zeroed child_exit=0"),
    ("phys3d_events_joint_pin", "phys3d_events.gd", ["--arm=joint_pin"], 0,
     "PASS phys3d_events joint_pin gp=soft jolt=dropped dummy=flat child_exit=0"),
    ("phys3d_events_joint_param", "phys3d_events.gd", ["--arm=joint_param"], 0,
     "PASS phys3d_events joint_param gp=sliderblind jolt=drops dummy=drops child_exit=0"),
    ("phys3d_events_joint_solver", "phys3d_events.gd",
     ["--arm=joint_solver"], 0,
     "PASS phys3d_events joint_solver prio=honored,ignored clear=immediate reuse=true freed=refusal child_exit=0"),
    ("phys3d_events_cross_space", "phys3d_events.gd", ["--arm=cross_space"], 0,
     "PASS phys3d_events cross_space two_world=answers raw=answers ident=per_space box=half,full jolt_raw=frozen child_exit=0"),
    ("phys3d_events_sleep_state", "phys3d_events.gd", ["--arm=sleep_state"], 0,
     "PASS phys3d_events sleep_state stale_buf=retained writes=wake toggle=gp_resleeps,jolt_frozen floor=gp_wakes,jolt_not child_exit=0"),
    # r90 joint lattice (phys3d_joints.gd): backend-select sweeps, RID
    # lifecycle, ClassDB surface, freed-endpoint families, detach, chain,
    # two-pin ordering. Per (case, backend) children under res://r90bt_*.
    ("phys3d_joints_sweep", "phys3d_joints.gd", ["--arm=sweep"], 0,
     'PASS phys3d_joints sweep sweep@gp{rc=0,m=M sweep rt=-2:-2;-1:-1;0:0;1:1;2:2;4:4;8:8;32:32;64:64;65:65;128:128|M unmade get0=1|M unmade set32 get1=32|M unmade setneg get2=-5|M DONE case=sweep engine=DEFAULT|M0 case=sweep engine=DEFAULT,e=3,w=0} sweep@jolt{rc=0,m=M sweep rt=-2:1;-1:1;0:1;1:1;2:1;4:1;8:1;32:1;64:1;65:1;128:1|M unmade get0=1|M unmade set32 get1=1|M unmade setneg get2=1|M DONE case=sweep engine=Jolt Physics|M0 case=sweep engine=Jolt Physics,e=3,w=12} sweep@dummy{rc=0,m=M sweep rt=-2:0;-1:0;0:0;1:0;2:0;4:0;8:0;32:0;64:0;65:0;128:0|M unmade get0=0|M unmade set32 get1=0|M unmade setneg get2=0|M DONE case=sweep engine=Dummy|M0 case=sweep engine=Dummy,e=0,w=0}'),
    ("phys3d_joints_rid", "phys3d_joints.gd", ["--arm=rid"], 0,
     'PASS phys3d_joints rid rid@gp{rc=0,m=M rid j1_valid=true type=5|M rid j1_after_free valid=true type=0|M rid j2_eq_j1=false j2_valid=true type=5|M rid remake_freed type=0|M rid fresh type=0|M rid j1_alias_type=0 j1_eq_j2=false|M rid after j2free j1_type=0|M rid j3_eq=false,false|M DONE case=rid engine=DEFAULT|M0 case=rid engine=DEFAULT,e=8,w=0} rid@jolt{rc=0,m=M rid j1_valid=true type=5|M rid j1_after_free valid=true type=0|M rid j2_eq_j1=false j2_valid=true type=5|M rid remake_freed type=0|M rid fresh type=0|M rid j1_alias_type=0 j1_eq_j2=false|M rid after j2free j1_type=0|M rid j3_eq=false,false|M DONE case=rid engine=Jolt Physics|M0 case=rid engine=Jolt Physics,e=8,w=0} rid@dummy{rc=0,m=M rid j1_valid=false type=0|M rid j1_after_free valid=false type=0|M rid j2_eq_j1=true j2_valid=false type=0|M rid remake_freed type=0|M rid fresh type=0|M rid j1_alias_type=0 j1_eq_j2=true|M rid after j2free j1_type=0|M rid j3_eq=true,true|M DONE case=rid engine=Dummy|M0 case=rid engine=Dummy,e=0,w=0}'),
    ("phys3d_joints_api", "phys3d_joints.gd", ["--arm=api"], 0,
     'PASS phys3d_joints api api@gp{rc=0,m=M api cls JoltPhysicsServer3D exists=false can_inst=false meth=0|M api cls GodotPhysicsServer3D exists=true can_inst=false meth=0|M api cls PhysicsServer3DDummy exists=false can_inst=false meth=0|M api cls PhysicsServer3D exists=true can_inst=false meth=175|M api cls PhysicsDirectBodyState3D exists=true can_inst=false meth=50|M api ps_joint_methods=32|M api has joint_set_enabled=false|M api has joint_get_enabled=false|M api has joint_set_solver_velocity_iterations=false|M api has joint_set_solver_position_iterations=false|M api has pin_joint_get_applied_force=false|M api has hinge_joint_get_jolt_flag=false|M api has generic_6dof_joint_set_jolt_flag=false|M api has joint_set_breakable=false|M api has joint_make_hinge_simple=false|M api callv_guarded=ABSENT|M DONE case=api engine=DEFAULT|M0 case=api engine=DEFAULT,e=2,w=0} api@jolt{rc=0,m=M api cls JoltPhysicsServer3D exists=true can_inst=false meth=0|M api cls GodotPhysicsServer3D exists=false can_inst=false meth=0|M api cls PhysicsServer3DDummy exists=false can_inst=false meth=0|M api cls PhysicsServer3D exists=true can_inst=false meth=175|M api cls PhysicsDirectBodyState3D exists=true can_inst=false meth=50|M api ps_joint_methods=32|M api has joint_set_enabled=false|M api has joint_get_enabled=false|M api has joint_set_solver_velocity_iterations=false|M api has joint_set_solver_position_iterations=false|M api has pin_joint_get_applied_force=false|M api has hinge_joint_get_jolt_flag=false|M api has generic_6dof_joint_set_jolt_flag=false|M api has joint_set_breakable=false|M api has joint_make_hinge_simple=false|M api callv_guarded=ABSENT|M DONE case=api engine=Jolt Physics|M0 case=api engine=Jolt Physics,e=2,w=0} api@dummy{rc=0,m=M api cls JoltPhysicsServer3D exists=false can_inst=false meth=0|M api cls GodotPhysicsServer3D exists=false can_inst=false meth=0|M api cls PhysicsServer3DDummy exists=true can_inst=false meth=0|M api cls PhysicsServer3D exists=true can_inst=false meth=175|M api cls PhysicsDirectBodyState3D exists=true can_inst=false meth=50|M api ps_joint_methods=32|M api has joint_set_enabled=false|M api has joint_get_enabled=false|M api has joint_set_solver_velocity_iterations=false|M api has joint_set_solver_position_iterations=false|M api has pin_joint_get_applied_force=false|M api has hinge_joint_get_jolt_flag=false|M api has generic_6dof_joint_set_jolt_flag=false|M api has joint_set_breakable=false|M api has joint_make_hinge_simple=false|M api callv_guarded=ABSENT|M DONE case=api engine=Dummy|M0 case=api engine=Dummy,e=2,w=0}'),
    ("phys3d_joints_free_pair", "phys3d_joints.gd", ["--arm=free_pair"], 0,
     'PASS phys3d_joints free_pair freeb@gp{mode_ok=1,m11=d42ece23b296d594} freeb@jolt{mode_ok=1,m11=90fa3f626053dcff} freeb@dummy{rc=0,m=M0 case=freeb engine=Dummy|M freeb t=1 b=null lv=null jtype=0|M freeb t=2 b=null lv=null jtype=0|M freeb t=3 b=null lv=null jtype=0|M freeb t=4 b=null lv=null jtype=0|M freeb t=5 b=null lv=null jtype=0|M freeb t=6 b=null lv=null jtype=0|M freeb freed post jtype=0|M freeb t=7 b=null lv=null jtype=0|M freeb t=8 b=null lv=null jtype=0|M DONE case=freeb engine=Dummy,e=0,w=0} freea@gp{mode_ok=1,m11=2b5f33bc87de0b0f} freea@jolt{mode_ok=1,m11=affcca5e5e877587} freea@dummy{rc=0,m=M0 case=freea engine=Dummy|M freea t=1 b=null lv=null jtype=0|M freea t=2 b=null lv=null jtype=0|M freea t=3 b=null lv=null jtype=0|M freea t=4 b=null lv=null jtype=0|M freea t=5 b=null lv=null jtype=0|M freea t=6 b=null lv=null jtype=0|M freea freed post jtype=0|M freea t=7 b=null lv=null jtype=0|M freea t=8 b=null lv=null jtype=0|M DONE case=freea engine=Dummy,e=0,w=0} freeb_dyn@gp{mode_ok=1,m8=c3d61244e5e1dc35} freeb_dyn@jolt{mode_ok=1,m11=ce6c02c7734d56e3} freeb_dyn@dummy{rc=0,m=M0 case=freeb_dyn engine=Dummy|M freeb_dyn t=1 b=null lv=null jtype=0|M freeb_dyn t=2 b=null lv=null jtype=0|M freeb_dyn t=3 b=null lv=null jtype=0|M freeb_dyn t=4 b=null lv=null jtype=0|M freeb_dyn t=5 b=null lv=null jtype=0|M freeb_dyn t=6 b=null lv=null jtype=0|M freeb_dyn freed post jtype=0|M freeb_dyn t=7 b=null lv=null jtype=0|M freeb_dyn t=8 b=null lv=null jtype=0|M DONE case=freeb_dyn engine=Dummy,e=0,w=0}'),
    ("phys3d_joints_free_ops", "phys3d_joints.gd", ["--arm=free_ops"], 0,
     'PASS phys3d_joints free_ops freeb_ops@gp{mode_ok=1,m6=124dfece8083d80f} freeb_ops@jolt{mode_ok=1,m6=0b9af1d2f64aad4a} freeb_ops@dummy{rc=0,m=M0 case=freeb_ops engine=Dummy|M freeb_ops freed|M freeb_ops get_type=0|M freeb_ops get_prio=0|M freeb_ops pin_param=0.0|M freeb_ops isdis=false|M freeb_ops cleared type=0|M DONE case=freeb_ops engine=Dummy,e=0,w=0} freeb_twice@gp{mode_ok=1,m4=e7c8b9cc20d38b1e} freeb_twice@jolt{mode_ok=1,m4=c42295756101d8d6} freeb_twice@dummy{rc=0,m=M0 case=freeb_twice engine=Dummy|M freeb_twice free1 done|M freeb_twice free2 done|M DONE case=freeb_twice engine=Dummy,e=0,w=0} freeb_make@gp{mode_ok=1,m4=5a1b9bded3cbf88b} freeb_make@jolt{mode_ok=1,m4=22e9399210234fe5} freeb_make@dummy{rc=0,m=M0 case=freeb_make engine=Dummy|M freeb_make freed_b|M freeb_make made type=0|M DONE case=freeb_make engine=Dummy,e=0,w=0} freeb_world@gp{rc=0,m=M0 case=freeb_world engine=DEFAULT|M freeb_world t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=5|M freeb_world t=2 b=0.0000,1.9973,0.0000 lv=0.0000,-0.1633,0.0000 jtype=5|M freeb_world t=3 b=0.0000,1.9918,0.0000 lv=0.0000,-0.3264,0.0000 jtype=5|M freeb_world t=4 b=0.0000,1.9837,0.0000 lv=0.0000,-0.4892,0.0000 jtype=5|M freeb_world t=5 b=0.0000,1.9728,0.0000 lv=0.0000,-0.6517,0.0000 jtype=5|M freeb_world made type=0|M freeb_world t=6 b=0.0000,1.9593,0.0000 lv=0.0000,-0.8139,0.0000 jtype=0|M freeb_world t=7 b=0.0000,1.9430,0.0000 lv=0.0000,-0.9759,0.0000 jtype=0|M freeb_world t=8 b=0.0000,1.9240,0.0000 lv=0.0000,-1.1376,0.0000 jtype=0|M freeb_world t=9 b=0.0000,1.9024,0.0000 lv=0.0000,-1.2991,0.0000 jtype=0|M freeb_world t=10 b=0.0000,1.8780,0.0000 lv=0.0000,-1.4602,0.0000 jtype=0|M DONE case=freeb_world engine=DEFAULT,e=0,w=0} freeb_world@jolt{rc=0,m=M0 case=freeb_world engine=Jolt Physics|M freeb_world t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=5|M freeb_world t=2 b=0.0000,1.9973,0.0000 lv=0.0000,-0.1633,0.0000 jtype=5|M freeb_world t=3 b=0.0000,1.9918,0.0000 lv=0.0000,-0.3264,0.0000 jtype=5|M freeb_world t=4 b=0.0000,1.9837,0.0000 lv=0.0000,-0.4892,0.0000 jtype=5|M freeb_world t=5 b=0.0000,1.9728,0.0000 lv=0.0000,-0.6517,0.0000 jtype=5|M freeb_world made type=0|M freeb_world t=6 b=0.0000,1.9593,0.0000 lv=0.0000,-0.8139,0.0000 jtype=0|M freeb_world t=7 b=0.0000,1.9430,0.0000 lv=0.0000,-0.9759,0.0000 jtype=0|M freeb_world t=8 b=0.0000,1.9240,0.0000 lv=0.0000,-1.1376,0.0000 jtype=0|M freeb_world t=9 b=0.0000,1.9024,0.0000 lv=0.0000,-1.2991,0.0000 jtype=0|M freeb_world t=10 b=0.0000,1.8780,0.0000 lv=0.0000,-1.4602,0.0000 jtype=0|M DONE case=freeb_world engine=Jolt Physics,e=0,w=0} freeb_world@dummy{rc=0,m=M0 case=freeb_world engine=Dummy|M freeb_world t=1 b=null lv=null jtype=0|M freeb_world t=2 b=null lv=null jtype=0|M freeb_world t=3 b=null lv=null jtype=0|M freeb_world t=4 b=null lv=null jtype=0|M freeb_world t=5 b=null lv=null jtype=0|M freeb_world made type=0|M freeb_world t=6 b=null lv=null jtype=0|M freeb_world t=7 b=null lv=null jtype=0|M freeb_world t=8 b=null lv=null jtype=0|M freeb_world t=9 b=null lv=null jtype=0|M freeb_world t=10 b=null lv=null jtype=0|M DONE case=freeb_world engine=Dummy,e=0,w=0} freeb_afterclear@gp{mode_ok=1,m4=a31ec35bc29873fb} freeb_afterclear@jolt{mode_ok=1,m4=0aadc67976644396} freeb_afterclear@dummy{rc=0,m=M0 case=freeb_afterclear engine=Dummy|M freeb_afterclear clear type=0|M freeb_afterclear b freed|M DONE case=freeb_afterclear engine=Dummy,e=0,w=0} freej_then_b@gp{mode_ok=1,m4=606a01100dfc83f1} freej_then_b@jolt{mode_ok=1,m4=70d825f7cce91132} freej_then_b@dummy{rc=0,m=M0 case=freej_then_b engine=Dummy|M freej_then_b joint freed|M freej_then_b b freed|M DONE case=freej_then_b engine=Dummy,e=0,w=0} detachb_free@gp{mode_ok=1,m4=c293b8d7f2669a3f} detachb_free@jolt{mode_ok=1,m4=e260e2a3c6282b25} detachb_free@dummy{rc=0,m=M0 case=detachb_free engine=Dummy|M detachb_free detached|M detachb_free freed|M DONE case=detachb_free engine=Dummy,e=0,w=0}'),
    ("phys3d_joints_detach", "phys3d_joints.gd", ["--arm=detach"], 0,
     'PASS phys3d_joints detach detachb@gp{rc=0,m=M0 case=detachb engine=DEFAULT|M detachb t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=2 b=0.0000,2.3000,0.0000 lv=0.0000,18.0000,0.0000 jtype=0|M detachb t=3 b=0.0000,2.1480,0.0000 lv=0.0000,-0.0000,0.0000 jtype=0|M detachb t=4 b=0.0000,2.1176,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=5 b=0.0000,2.1115,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb detached jtype=0|M detachb t=6 b=0.0000,2.1103,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=7 b=0.0000,2.1103,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=8 b=0.0000,2.1103,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=9 b=0.0000,2.1103,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb reattached jtype=0|M detachb t=10 b=0.0000,2.1103,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=11 b=0.0000,2.1073,0.0000 lv=0.0000,-0.1633,0.0000 jtype=0|M detachb t=12 b=0.0000,2.1019,0.0000 lv=0.0000,-0.3264,0.0000 jtype=0|M DONE case=detachb engine=DEFAULT,e=0,w=0} detachb@jolt{rc=0,m=M0 case=detachb engine=Jolt Physics|M detachb t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=2 b=0.0000,2.3600,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=3 b=0.0000,2.5184,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=4 b=0.0000,2.6198,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=5 b=0.0000,2.6847,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb detached jtype=0|M detachb t=6 b=0.0000,2.7262,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=7 b=0.0000,2.7262,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=8 b=0.0000,2.7262,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=9 b=0.0000,2.7262,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb reattached jtype=0|M detachb t=10 b=0.0000,2.7262,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=11 b=0.0000,2.7528,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M detachb t=12 b=0.0000,2.7698,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M DONE case=detachb engine=Jolt Physics,e=0,w=0} detachb@dummy{rc=0,m=M0 case=detachb engine=Dummy|M detachb t=1 b=null lv=null jtype=0|M detachb t=2 b=null lv=null jtype=0|M detachb t=3 b=null lv=null jtype=0|M detachb t=4 b=null lv=null jtype=0|M detachb t=5 b=null lv=null jtype=0|M detachb detached jtype=0|M detachb t=6 b=null lv=null jtype=0|M detachb t=7 b=null lv=null jtype=0|M detachb t=8 b=null lv=null jtype=0|M detachb t=9 b=null lv=null jtype=0|M detachb reattached jtype=0|M detachb t=10 b=null lv=null jtype=0|M detachb t=11 b=null lv=null jtype=0|M detachb t=12 b=null lv=null jtype=0|M DONE case=detachb engine=Dummy,e=0,w=0}'),
    ("phys3d_joints_chain3", "phys3d_joints.gd", ["--arm=chain3"], 0,
     'PASS phys3d_joints chain3 chain3_freemid@gp{mode_ok=1,m2=c1b063fbc58a5718} chain3_freemid@jolt{mode_ok=1,m3=544e2fc5305c356f} chain3_freemid@dummy{rc=0,m=M0 case=chain3_freemid engine=Dummy|M chain3_freemid mid freed type1=0 type2=0|M DONE case=chain3_freemid engine=Dummy,e=0,w=0}'),
    ("phys3d_joints_twopin", "phys3d_joints.gd", ["--arm=twopin"], 0,
     'PASS phys3d_joints twopin twopin_hi1@gp{rc=0,m=M0 case=twopin_hi1 engine=DEFAULT|M twopin_hi1 t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=2 b=-0.1500,2.3000,0.0000 lv=-9.0000,18.0000,0.0000 jtype=0|M twopin_hi1 t=3 b=-0.2550,2.5100,0.0000 lv=-6.3000,12.6000,0.0000 jtype=0|M twopin_hi1 t=4 b=-0.3285,2.6570,0.0000 lv=-4.4100,8.8200,0.0000 jtype=0|M twopin_hi1 t=5 b=-0.3800,2.7599,0.0000 lv=-3.0870,6.1740,0.0000 jtype=0|M twopin_hi1 t=6 b=-0.4160,2.8319,0.0000 lv=-2.1609,4.3218,0.0000 jtype=0|M twopin_hi1 t=7 b=-0.4412,2.8824,0.0000 lv=-1.5126,3.0253,0.0000 jtype=0|M twopin_hi1 t=8 b=-0.4588,2.9176,0.0000 lv=-1.0588,2.1177,0.0000 jtype=0|M twopin_hi1 t=9 b=-0.4712,2.9424,0.0000 lv=-0.7412,1.4824,0.0000 jtype=0|M twopin_hi1 t=10 b=-0.4798,2.9596,0.0000 lv=-0.5188,1.0377,0.0000 jtype=0|M twopin_hi1 t=11 b=-0.4859,2.9718,0.0000 lv=-0.3632,0.7264,0.0000 jtype=0|M twopin_hi1 t=12 b=-0.4901,2.9802,0.0000 lv=-0.2542,0.5085,0.0000 jtype=0|M twopin_hi1 t=13 b=-0.4931,2.9862,0.0000 lv=-0.1780,0.3559,0.0000 jtype=0|M twopin_hi1 t=14 b=-0.4952,2.9903,0.0000 lv=-0.1246,0.2491,0.0000 jtype=0|M twopin_hi1 t=15 b=-0.4966,2.9932,0.0000 lv=-0.0872,0.1744,0.0000 jtype=0|M twopin_hi1 t=16 b=-0.4976,2.9953,0.0000 lv=-0.0610,0.1221,0.0000 jtype=0|M DONE case=twopin_hi1 engine=DEFAULT,e=0,w=0} twopin_hi1@jolt{rc=0,m=M0 case=twopin_hi1 engine=Jolt Physics|M twopin_hi1 t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=2 b=0.0328,2.5904,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=3 b=0.0462,2.8322,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=4 b=0.0517,2.9313,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=5 b=0.0540,2.9719,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=6 b=0.0549,2.9885,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=7 b=0.0553,2.9953,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=8 b=0.0554,2.9981,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=9 b=0.0555,2.9992,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=10 b=0.0555,2.9997,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=11 b=0.0555,2.9999,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=12 b=0.0556,2.9999,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=13 b=0.0556,3.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=14 b=0.0556,3.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=15 b=0.0556,3.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi1 t=16 b=0.0556,3.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M DONE case=twopin_hi1 engine=Jolt Physics,e=0,w=1} twopin_hi1@dummy{rc=0,m=M0 case=twopin_hi1 engine=Dummy|M twopin_hi1 t=1 b=null lv=null jtype=0|M twopin_hi1 t=2 b=null lv=null jtype=0|M twopin_hi1 t=3 b=null lv=null jtype=0|M twopin_hi1 t=4 b=null lv=null jtype=0|M twopin_hi1 t=5 b=null lv=null jtype=0|M twopin_hi1 t=6 b=null lv=null jtype=0|M twopin_hi1 t=7 b=null lv=null jtype=0|M twopin_hi1 t=8 b=null lv=null jtype=0|M twopin_hi1 t=9 b=null lv=null jtype=0|M twopin_hi1 t=10 b=null lv=null jtype=0|M twopin_hi1 t=11 b=null lv=null jtype=0|M twopin_hi1 t=12 b=null lv=null jtype=0|M twopin_hi1 t=13 b=null lv=null jtype=0|M twopin_hi1 t=14 b=null lv=null jtype=0|M twopin_hi1 t=15 b=null lv=null jtype=0|M twopin_hi1 t=16 b=null lv=null jtype=0|M DONE case=twopin_hi1 engine=Dummy,e=0,w=0} twopin_hi2@gp{rc=0,m=M0 case=twopin_hi2 engine=DEFAULT|M twopin_hi2 t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=2 b=0.1500,2.3000,0.0000 lv=9.0000,18.0000,0.0000 jtype=0|M twopin_hi2 t=3 b=0.2550,2.5100,0.0000 lv=6.3000,12.6000,0.0000 jtype=0|M twopin_hi2 t=4 b=0.3285,2.6570,0.0000 lv=4.4100,8.8200,0.0000 jtype=0|M twopin_hi2 t=5 b=0.3800,2.7599,0.0000 lv=3.0870,6.1740,0.0000 jtype=0|M twopin_hi2 t=6 b=0.4160,2.8319,0.0000 lv=2.1609,4.3218,0.0000 jtype=0|M twopin_hi2 t=7 b=0.4412,2.8824,0.0000 lv=1.5126,3.0253,0.0000 jtype=0|M twopin_hi2 t=8 b=0.4588,2.9176,0.0000 lv=1.0588,2.1177,0.0000 jtype=0|M twopin_hi2 t=9 b=0.4712,2.9424,0.0000 lv=0.7412,1.4824,0.0000 jtype=0|M twopin_hi2 t=10 b=0.4798,2.9596,0.0000 lv=0.5188,1.0377,0.0000 jtype=0|M twopin_hi2 t=11 b=0.4859,2.9718,0.0000 lv=0.3632,0.7264,0.0000 jtype=0|M twopin_hi2 t=12 b=0.4901,2.9802,0.0000 lv=0.2542,0.5085,0.0000 jtype=0|M twopin_hi2 t=13 b=0.4931,2.9862,0.0000 lv=0.1780,0.3559,0.0000 jtype=0|M twopin_hi2 t=14 b=0.4952,2.9903,0.0000 lv=0.1246,0.2491,0.0000 jtype=0|M twopin_hi2 t=15 b=0.4966,2.9932,0.0000 lv=0.0872,0.1744,0.0000 jtype=0|M twopin_hi2 t=16 b=0.4976,2.9953,0.0000 lv=0.0610,0.1221,0.0000 jtype=0|M DONE case=twopin_hi2 engine=DEFAULT,e=0,w=0} twopin_hi2@jolt{rc=0,m=M0 case=twopin_hi2 engine=Jolt Physics|M twopin_hi2 t=1 b=0.0000,2.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=2 b=0.0328,2.5904,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=3 b=0.0462,2.8322,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=4 b=0.0517,2.9313,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=5 b=0.0540,2.9719,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=6 b=0.0549,2.9885,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=7 b=0.0553,2.9953,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=8 b=0.0554,2.9981,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=9 b=0.0555,2.9992,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=10 b=0.0555,2.9997,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=11 b=0.0555,2.9999,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=12 b=0.0556,2.9999,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=13 b=0.0556,3.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=14 b=0.0556,3.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=15 b=0.0556,3.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M twopin_hi2 t=16 b=0.0556,3.0000,0.0000 lv=0.0000,0.0000,0.0000 jtype=0|M DONE case=twopin_hi2 engine=Jolt Physics,e=0,w=1} twopin_hi2@dummy{rc=0,m=M0 case=twopin_hi2 engine=Dummy|M twopin_hi2 t=1 b=null lv=null jtype=0|M twopin_hi2 t=2 b=null lv=null jtype=0|M twopin_hi2 t=3 b=null lv=null jtype=0|M twopin_hi2 t=4 b=null lv=null jtype=0|M twopin_hi2 t=5 b=null lv=null jtype=0|M twopin_hi2 t=6 b=null lv=null jtype=0|M twopin_hi2 t=7 b=null lv=null jtype=0|M twopin_hi2 t=8 b=null lv=null jtype=0|M twopin_hi2 t=9 b=null lv=null jtype=0|M twopin_hi2 t=10 b=null lv=null jtype=0|M twopin_hi2 t=11 b=null lv=null jtype=0|M twopin_hi2 t=12 b=null lv=null jtype=0|M twopin_hi2 t=13 b=null lv=null jtype=0|M twopin_hi2 t=14 b=null lv=null jtype=0|M twopin_hi2 t=15 b=null lv=null jtype=0|M twopin_hi2 t=16 b=null lv=null jtype=0|M DONE case=twopin_hi2 engine=Dummy,e=0,w=0}'),
    # r91 bpy rigid-body world + point-cache lattice (bpy_rbw3d.gd):
    # Godot parent spawns `blender -b -P res://r91_child.py -- <case>
    # <dir>` children per case under res://r91bt_*/ (one solver — the
    # per-backend convention maps onto per-case @bpy cells). The parent
    # scans each merged log for M-prefix rows, Error/Traceback lines,
    # warnings, the `bake: frame` flood count (b=), and the
    # blender.crash.txt marker; ptr_stale pins the crash envelope
    # (mode_ok + prefix sha + rc class), never backtrace bytes. PNG/.blend
    # bytes are non-witnesses (drift) — only behaviour booleans pinned.
    # Blender 5.2.1 LTS headless, this host; every value measured here.
    ("bpy_rbw3d_det", "bpy_rbw3d.gd", ["--arm=det"], 0,
     "PASS bpy_rbw3d det free@bpy{rc=0,m=M0 case=free engine=blender-5.2.1|M free sweep1 h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M free cache_after1 info=40 frames in memory (7 KiB). baked=False outdated=False|M free sweep2 eq1=True h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M free sweep3_after_excursion eq1=True h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M free fwd41_60 f45=(0.379696,-0.005126,0.500063) f60=(0.379671,-0.005131,0.500063)|M free cache_after3 info=60 frames in memory (10 KiB). baked=False outdated=False|M DONE case=free,e=0,w=0,b=0} bequiv@bpy{rc=0,m=M0 case=bequiv engine=blender-5.2.1|M bequiv ranges_before pc_fs=1 pc_fe=250 scene_fs=1 scene_fe=60 disk=False|M bequiv free_run h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M bequiv bake_all ret={'FINISHED'} baked=True outdated=False info=250 frames in memory (41 KiB). pc_fe=250|M bequiv baked_run eq_free=True h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M bequiv narrow_range pc_fs=1 pc_fe=20 info=250 frames in memory (41 KiB). baked=False|M bequiv bake_narrow ret={'FINISHED'} info=250 frames in memory (41 KiB). baked=True|M bequiv narrow_readback n=20 eq_free20=True f20=(0.000000,0.000000,1.942529)|M DONE case=bequiv,e=0,w=0,b=290}"),
    ("bpy_rbw3d_bake", "bpy_rbw3d.gd", ["--arm=bake"], 0,
     "PASS bpy_rbw3d bake bake20@bpy{rc=0,m=M0 case=bake20 engine=blender-5.2.1|M bake20 before pc_fs=1 pc_fe=20 scene_fs=1 scene_fe=60 info=|M bake20 after baked=True info=20 frames in memory (3 KiB). outdated=False|M bake20 read f20=(0.000000,0.000000,1.942529) f40=(0.000000,0.000000,1.942529) h=cfb45aff07e749b5|M DONE case=bake20,e=0,w=0,b=20} bake5_30@bpy{rc=0,m=M0 case=bake5_30 engine=blender-5.2.1|M bake5_30 before pc_fs=5 pc_fe=30 scene_fs=1 scene_fe=60 info=|M bake5_30 after baked=True info=26 frames in memory (4 KiB). outdated=False|M bake5_30 read f20=(0.000000,0.000000,3.087401) f40=(0.074437,-0.000000,0.555247) h=716f28903f84bea4|M DONE case=bake5_30,e=0,w=0,b=26} scene20b@bpy{rc=0,m=M0 case=scene20b engine=blender-5.2.1|M scene20b before pc_fs=1 pc_fe=250 scene_fs=1 scene_fe=20 info=|M scene20b after baked=True info=250 frames in memory (41 KiB). outdated=False|M scene20b read f20=(0.000000,0.000000,1.942529) f40=(0.381156,-0.006439,0.500823) h=3302e3c1de9c5dd0|M DONE case=scene20b,e=0,w=0,b=250} presweep20@bpy{rc=0,m=M0 case=presweep20 engine=blender-5.2.1|M presweep20 pre info=40 frames in memory (7 KiB). pc_fe=20|M presweep20 before pc_fs=1 pc_fe=20 scene_fs=1 scene_fe=60 info=40 frames in memory (7 KiB).|M presweep20 after baked=True info=40 frames in memory (7 KiB). outdated=False|M presweep20 read f20=(0.000000,0.000000,1.942529) f40=(0.000000,0.000000,1.942529) h=cfb45aff07e749b5|M DONE case=presweep20,e=0,w=0,b=40}"),
    ("bpy_rbw3d_window", "bpy_rbw3d.gd", ["--arm=window"], 0,
     "PASS bpy_rbw3d window end20@bpy{rc=0,m=M0 case=end20 engine=blender-5.2.1|M end20 setup pc_fs=1 pc_fe=20 scene_fs=1 scene_fe=60|M end20 head20 f20=(0.000000,0.000000,1.942529)|M end20 tail f21=(0.000000,0.000000,1.942529) f25=(0.000000,0.000000,1.942529) f30=(0.000000,0.000000,1.942529) f40=(0.000000,0.000000,1.942529) frozen=True h=6498e1a38a4b7b9f|M DONE case=end20,e=0,w=0,b=0} start20@bpy{rc=0,m=M0 case=start20 engine=blender-5.2.1|M start20 setup pc_fs=20 pc_fe=250 scene_fs=1 scene_fe=60|M start20 head20 f20=(0.000000,0.000000,5.000000)|M start20 tail f21=(0.000000,0.000000,4.990638) f25=(0.000000,0.000000,4.783453) f30=(0.000000,0.000000,4.144729) f40=(0.000000,0.000000,1.615016) frozen=False h=3a72772535e85419|M DONE case=start20,e=0,w=0,b=0} scene20w@bpy{rc=0,m=M0 case=scene20w engine=blender-5.2.1|M scene20w setup pc_fs=1 pc_fe=250 scene_fs=1 scene_fe=20|M scene20w head20 f20=(0.000000,0.000000,1.942529)|M scene20w tail f21=(0.000000,0.000000,1.615016) f25=(0.033111,-0.000000,0.517439) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) frozen=False h=74e6cfb2e009f02f|M DONE case=scene20w,e=0,w=0,b=0}"),
    ("bpy_rbw3d_order", "bpy_rbw3d.gd", ["--arm=order"], 0,
     "PASS bpy_rbw3d order order@bpy{rc=0,m=M0 case=order engine=blender-5.2.1|M order jump40 loc=(0.000000,0.000000,5.000000) fcur=40|M order jump_then_seq40 h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M order backward back1=(0.000000,0.000000,5.000000) back20=(0.000000,0.000000,1.942529) back40=(0.381156,-0.006439,0.500823) fwd60=(0.381156,-0.006439,0.500823) re20=(0.000000,0.000000,1.942529) re1=(0.000000,0.000000,5.000000)|M order subframe f40=(0.381156,-0.006439,0.500823) f40_5=(0.381156,-0.006439,0.500823)|M order subframe_next f41=(0.379702,-0.005126,0.500062)|M order frame0 loc=(0.000000,0.000000,5.000000) fcur=0|M DONE case=order,e=0,w=0,b=0} bjump@bpy{rc=0,m=M0 case=bjump engine=blender-5.2.1|M bjump baked baked=True info=40 frames in memory (7 KiB).|M bjump jump40 loc=(0.381156,-0.006439,0.500823)|M bjump jump60_past_cache loc=(0.381156,-0.006439,0.500823)|M bjump jump40_again loc=(0.381156,-0.006439,0.500823)|M bjump seq40 h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M DONE case=bjump,e=0,w=0,b=40}"),
    ("bpy_rbw3d_resim", "bpy_rbw3d.gd", ["--arm=resim"], 0,
     "PASS bpy_rbw3d resim stale@bpy{rc=0,m=M0 case=stale engine=blender-5.2.1|M stale free_ts1 h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M stale mutate ts=0.25 outdated=True baked=True|M stale baked_ts025 eq_free=True h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M stale freed baked=False outdated=False info=40 frames in memory (7 KiB).|M stale freed_ts025 eq_free=True h=3302e3c1de9c5dd0 n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.306076) f20=(0.000000,0.000000,1.942529) f30=(0.226293,-0.001284,0.612535) f40=(0.381156,-0.006439,0.500823) last=(0.381156,-0.006439,0.500823)|M stale disabled eq_free=False enabled=False h=5c473677cca8d53a n=40 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,5.000000) f20=(0.000000,0.000000,5.000000) f30=(0.000000,0.000000,5.000000) f40=(0.000000,0.000000,5.000000) last=(0.000000,0.000000,5.000000)|M stale beyond_cache f45=(0.381156,-0.006439,0.500823) f60=(0.381156,-0.006439,0.500823) outdated=False|M DONE case=stale,e=0,w=0,b=40} resim@bpy{rc=0,m=M0 case=resim engine=blender-5.2.1|M resim pre_bake f20=(0.000000,0.000000,1.942529)|M resim baked baked=True info=20 frames in memory (3 KiB).|M resim mutate ts=0.25 outdated=True|M resim post_mutation_forward f21=(0.000000,0.000000,1.942529) f30=(0.000000,0.000000,1.942529) f40=(0.000000,0.000000,1.942529) h=6498e1a38a4b7b9f|M resim reread_head eq_pre=True f20=(0.000000,0.000000,1.942529)|M resim after_toggle eq_pre=True f20=(0.000000,0.000000,1.942529) outdated=False|M resim after_free_bake eq_pre=True f20=(0.000000,0.000000,1.942529) info=20 frames in memory (3 KiB). outdated=False|M resim far_forward f45=(0.000000,0.000000,1.942529) f60=(0.000000,0.000000,1.942529)|M DONE case=resim,e=0,w=0,b=20} partial@bpy{rc=0,m=M0 case=partial engine=blender-5.2.1|M partial head20 f20=(0.000000,0.000000,1.942529) h=c3af015e07cdf24e|M partial mutate ts=0.25 outdated=True|M partial tail f21=(0.000000,0.000000,1.862350) f25=(0.000000,0.000000,1.531338) f30=(0.000000,0.000000,1.094436) f40=(0.009188,-0.000000,0.504694) h=393edd37abcaef22|M partial head_reread eq_head=False f20=(0.000000,0.000000,4.807371)|M DONE case=partial,e=0,w=0,b=0} trace@bpy{rc=0,m=M0 case=trace engine=blender-5.2.1|M trace MUT ts=0.25 outdated=True|M trace R5 f05=(0.000000,0.000000,4.860652)|M trace R20 f20=(0.000000,0.000000,4.860652)|M trace T f21=(0.000000,0.000000,4.860652) f30=(0.000000,0.000000,4.860652) f40=(0.000000,0.000000,4.860652) frozen=True|M trace H2 f10=(0.000000,0.000000,4.956466) f20=(0.000000,0.000000,4.807371)|M trace T2 f30=(0.000000,0.000000,4.552688)|M trace T3 f60=(0.000000,0.000000,3.159576)|M trace SUMMARY h1=c3af015e07cdf24e t=d32f1a69ce8ae319 h2=db5a3d0cbf7ef968 t2=4fd4be6202d9e92d t3=0b43f52c0daceded h1_eq_h2=False t_eq_t2=False|M DONE case=trace,e=0,w=0,b=0} ctrl025@bpy{rc=0,m=M0 case=ctrl025 engine=blender-5.2.1|M ctrl025 traj ts=0.25 h=5c2eb7d566c54855 n=60 f1=(0.000000,0.000000,5.000000) f10=(0.000000,0.000000,4.956466) f20=(0.000000,0.000000,4.807371) f30=(0.000000,0.000000,4.552688) f40=(0.000000,0.000000,4.192864) last=(0.000000,0.000000,3.159576)|M DONE case=ctrl025,e=0,w=0,b=0}"),
    ("bpy_rbw3d_knobs", "bpy_rbw3d.gd", ["--arm=knobs"], 0,
     "PASS bpy_rbw3d knobs fps@bpy{rc=0,m=M0 case=fps engine=blender-5.2.1|M fps fps24 fps=24 h=3302e3c1de9c5dd0 last=(0.381156,-0.006439,0.500823)|M fps fps60 fps=60 h=1f12776ddff6285f last=(0.000000,0.000000,2.940532)|M fps fps120 fps=120 h=9c73c3f28300910c last=(0.000000,0.000000,4.482864)|M DONE case=fps,e=0,w=0,b=0} solv@bpy{rc=0,m=M0 case=solv engine=blender-5.2.1|M solv substeps1 substeps=1 iters=10 split=False h=4161bab53d2cbe73 last=(0.773845,0.195946,0.506597)|M solv substeps40 substeps=40 iters=10 split=False h=898e0dd0a6c61fc4 last=(0.370623,-0.000001,0.500063)|M solv iters1 substeps=10 iters=1 split=False h=6eae9b3b9a01a1dd last=(0.243452,0.005565,0.499976)|M solv split1 substeps=10 iters=10 split=True h=a3657c2e88f737c2 last=(0.133979,-0.001840,0.500063)|M DONE case=solv,e=0,w=0,b=0}"),
    ("bpy_rbw3d_ops", "bpy_rbw3d.gd", ["--arm=ops"], 0,
     "PASS bpy_rbw3d ops polls@bpy{rc=0,m=M0 case=polls engine=blender-5.2.1|M polls env background=True version=5.2.1|M polls ptcache_polls bake=False bake_all=True free_bake=False free_bake_all=True bake_from_cache=False|M polls rigidbody_polls bake_to_keyframes=True world_remove=True|M polls bake_call err=RuntimeError msg=Operator bpy.ops.ptcache.bake.poll() failed, context is incorrect|M polls free_call err=RuntimeError msg=Operator bpy.ops.ptcache.free_bake.poll() failed, context is incorrect|M polls from_cache_call err=RuntimeError msg=Operator bpy.ops.ptcache.bake_from_cache.poll() failed, context is incorrect|M DONE case=polls,e=0,w=0,b=0} b2k@bpy{rc=0,m=M0 case=b2k engine=blender-5.2.1|M b2k b2k_call err=RuntimeError pollfail=True kf_op=True|M b2k b2k_state actions=0 anim_data=False|M DONE case=b2k,e=4,w=0,b=0} disk@bpy{rc=0,m=M0 case=disk engine=blender-5.2.1|M disk rbw_set disk=False ext=False filepath=rb_|M disk rbw_external disk=False ext=True|M disk rbw_after_sweep n=0 names= info=No valid data to read!|M disk rbw_after_bake n=0 names= baked=True info=No valid data to read!|M disk cloth_set disk=False ext=False filepath=cl_|M disk cloth_after_sweep n=0 names= info=10 frames in memory (30 KiB).|M DONE case=disk,e=0,w=0,b=250}"),
    ("bpy_rbw3d_io", "bpy_rbw3d.gd", ["--arm=io"], 0,
     "PASS bpy_rbw3d io blend@bpy{rc=0,m=M0 case=blend engine=blender-5.2.1|M blend baked info=40 frames in memory (7 KiB). baked=True|M blend saved exists=True|M blend loaded sc=Scene fs=1 fe=60 rbw=True|M blend loaded_pc info=40 frames in memory (7 KiB). baked=True|M blend jump40 loc=(0.381156,-0.006439,0.500823)|M blend jump20 loc=(0.000000,0.000000,1.942529)|M DONE case=blend,e=0,w=0,b=40}"),
    ("bpy_rbw3d_render", "bpy_rbw3d.gd", ["--arm=render"], 0,
     "PASS bpy_rbw3d render shot@bpy{rc=0,m=M0 case=shot engine=blender-5.2.1|M shot jump40 ret={'FINISHED'} pre=(0.000000,0.000000,5.000000) post=(0.000000,0.000000,5.000000) written=True fcur=40|M shot after_step20 f20=(0.000000,0.000000,1.942529)|M shot jump40_from20 ret={'FINISHED'} pre=(0.000000,0.000000,1.942529) post=(0.000000,0.000000,1.942529) written=True fcur=40|M shot seq40 ret={'FINISHED'} pre=(0.381156,-0.006439,0.500823) post=(0.381156,-0.006439,0.500823) written=True fcur=40|M shot compare h1_eq_h2=False h3_diff=True sim_f40=(0.381156,-0.006439,0.500823)|M DONE case=shot,e=0,w=0,b=0} rdet@bpy{rc=0,m=M0 case=rdet engine=blender-5.2.1|M rdet state f40=(0.381156,-0.006439,0.500823)|M rdet same_state stable=False|M rdet moved_state differs=True|M DONE case=rdet,e=0,w=0,b=0}"),
    ("bpy_rbw3d_ptr", "bpy_rbw3d.gd", ["--arm=ptr"], 0,
     "PASS bpy_rbw3d ptr ptr_stale@bpy{mode_ok=1,m3=b748ab7457574f90,rc=139} ptr_fresh@bpy{rc=0,m=M0 case=ptr_fresh engine=blender-5.2.1|M ptr_fresh reset mode=fresh b_ok=True ts_b=1.0|M ptr_fresh pre_write alive=True|M ptr_fresh post_write ts=0.25|M DONE case=ptr_fresh,e=0,w=0,b=0}"),
]

# Adversarial self-check, run only with --probe-failing. Exactly one authored
# constant of one fixture is mutated in a scratch copy: the wall box depth. The
# expected contact plane stays the hand-authored literal 2.5, so the engine stop
# at 3.5 must be rejected. A self-consistent re-derivation would have hidden
# this, which is the point of the probe.
MUTATION = {
    "case": "body3d_contact",
    "script": "body3d_slide.gd",
    "flags": [],
    "old": "const BOX_SIZE := Vector3(4.0, 4.0, 4.0)",
    "new": "const BOX_SIZE := Vector3(4.0, 4.0, 6.0)",
    "expected_exit": 1,
    "forbidden_stdout": "PASS body3d_contact",
    "expected_diagnostic": ("ERROR: body3d_slide: body did not stop at the contact "
                            "plane final_z=3.500 expected=2.500"),
}

LEAKED_OBJECTDB = re.compile(
    r"^WARNING: [1-9][0-9]* ObjectDB instances? (?:were|was) leaked at exit"
    r"(?: \(run with `--verbose` for details\)\.)?$")


def seed_digests() -> dict:
    # __pycache__ is tooling residue (importing this runner creates it), not a
    # seed, so it is excluded from both the digest map and the scratch copy.
    return {str(path.relative_to(HERE)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(HERE.rglob("*"))
            if path.is_file() and "__pycache__" not in path.parts
            and path.relative_to(HERE).parts[0] != "three"}


def run_process(command, timeout_seconds):
    try:
        proc = subprocess.run(command, capture_output=True, text=True, timeout=timeout_seconds)
        return proc.stdout, proc.stderr, proc.returncode, None
    except subprocess.TimeoutExpired as exc:
        def text(value):
            if isinstance(value, bytes):
                return value.decode(errors="replace")
            return value or ""
        return (text(exc.stdout), text(exc.stderr), None,
                f"TIMEOUT after {timeout_seconds} seconds")
    except OSError as exc:
        return "", str(exc), None, f"launch error: {exc}"


def classify(stdout, stderr, code, error, expected_exit, marker):
    """Return (passed, reasons). The marker must be an exact stdout line."""
    reasons = []
    if error is not None:
        reasons.append(error)
    if code is None:
        reasons.append("no exit code (process killed or timed out)")
    elif code < 0:
        reasons.append(f"process died on signal {-code}")
    elif code != expected_exit:
        reasons.append(f"exit {code} != expected {expected_exit}")
    lines = [line.strip() for line in stdout.splitlines()]
    if marker not in lines:
        reasons.append("exact stdout marker missing")
    for line in stderr.splitlines():
        if line.strip():
            reasons.append(f"unexpected stderr line: {line.strip()}")
    for stream_name, stream in (("stdout", stdout), ("stderr", stderr)):
        if "SCRIPT ERROR:" in stream:
            reasons.append(f"SCRIPT ERROR on {stream_name}")
        if "Parse Error:" in stream:
            reasons.append(f"Parse Error on {stream_name}")
    for line in [line.strip() for line in (stdout + stderr).splitlines()]:
        if "ERROR:" in line:
            reasons.append(f"unexpected diagnostic: {line}")
        elif LEAKED_OBJECTDB.match(line):
            reasons.append(f"unexpected leak warning: {line}")
    return (not reasons, reasons)


def probe_crash_exit(godot, scratch, run_dir):
    marker = "CRASH_EXIT_3D: spatial node ready"
    script = "res://crash_exit3d.gd"
    normal_command = [godot, "--headless", "--path", str(scratch), "--script", script, "--"]
    normal_out, normal_err, normal_code, normal_error = run_process(normal_command, 8)
    normal_pass, normal_reasons = classify(normal_out, normal_err, normal_code, normal_error, 1, marker)
    normal = {"command": normal_command, "actual_exit": normal_code, "stdout": normal_out,
              "stderr": normal_err, "error": normal_error, "classified_normal": normal_pass,
              "reasons": normal_reasons}

    signal_command = normal_command + ["--hold-open"]
    signaled = {"command": signal_command, "actual_exit": None, "stdout": "", "stderr": "",
                "error": None, "marker_observed_while_live": False, "signal_sent": False,
                "classified_normal": None, "reasons": []}
    process = None
    try:
        if os.name != "posix":
            signaled["error"] = "POSIX SIGTERM unavailable"
        else:
            process = subprocess.Popen(signal_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            deadline = time.monotonic() + 8
            pending = b""
            while time.monotonic() < deadline:
                readable, _, _ = select.select([process.stdout], [], [],
                                                min(0.1, max(0, deadline - time.monotonic())))
                if readable:
                    chunk = os.read(process.stdout.fileno(), 4096)
                    pending += chunk
                    if any(line.strip() == marker.encode() for line in pending.split(b"\n")[:-1]):
                        signaled["marker_observed_while_live"] = process.poll() is None
                        break
                    if not chunk:
                        break
                if process.poll() is not None:
                    break
            if signaled["marker_observed_while_live"]:
                process.send_signal(signal.SIGTERM)
                signaled["signal_sent"] = True
            else:
                signaled["error"] = "exact marker not observed while child live before 8s deadline"
            try:
                remainder, stderr = process.communicate(timeout=3)
            except subprocess.TimeoutExpired:
                signaled["error"] = "cleanup exceeded 3s; child killed"
                process.kill()
                remainder, stderr = process.communicate(timeout=3)
            signaled["stdout"] = (pending + remainder).decode(errors="replace")
            signaled["stderr"] = stderr.decode(errors="replace")
            signaled["actual_exit"] = process.returncode
            classified, reasons = classify(signaled["stdout"], signaled["stderr"],
                                           process.returncode, signaled["error"], 1, marker)
            signaled["classified_normal"] = classified
            signaled["reasons"] = reasons
    except (OSError, ValueError) as exc:
        signaled["error"] = f"signal probe failed: {exc}"
    finally:
        if process is not None and process.poll() is None:
            process.kill()
            try:
                process.communicate(timeout=3)
            except subprocess.TimeoutExpired:
                signaled["error"] = "forced cleanup exceeded 3s"

    verdict = (normal_pass and normal_err == "" and signaled["error"] is None
               and signaled["marker_observed_while_live"] and signaled["signal_sent"]
               and signaled["actual_exit"] == -signal.SIGTERM
               and signaled["classified_normal"] is False
               and f"process died on signal {signal.SIGTERM}" in signaled["reasons"]
               and signaled["stderr"] == "")
    result = {"verdict": "PASS" if verdict else "FAIL", "marker": marker,
              "normal": normal, "signaled": signaled, "bounded_claim":
              "One Godot 4.7.2 Node3D setup and direct-child normal exit versus POSIX SIGTERM; "
              "not a spontaneous crash, process-tree timeout, or rendered output."}
    (run_dir / "crash-exit-verdicts.json").write_text(json.dumps(result, indent=2) + "\n")
    print(f"{result['verdict']} crash-exit probe: {run_dir / 'crash-exit-verdicts.json'}", flush=True)
    return verdict


def probe_stream_attribution(godot, scratch, run_dir):
    marker = "STREAM_3D_STDOUT: spatial node ready"
    diagnostic = "STREAM_3D_STDERR"
    script = "res://stream_attribution3d.gd"
    results = []
    for name, flags in (("accept", []), ("reject", ["--emit-stderr"])):
        command = [godot, "--headless", "--path", str(scratch), "--script", script, "--", *flags]
        stdout, stderr, code, error = run_process(command, 8)
        classified, reasons = classify(stdout, stderr, code, error, 0, marker)
        results.append({"case": name, "command": command, "stdout": stdout, "stderr": stderr,
                        "actual_exit": code, "error": error, "classified": classified,
                        "reasons": reasons})
    accept, reject = results
    marker_once = all(r["stdout"].splitlines().count(marker) == 1 for r in results)
    verdict = (marker_once and accept["stdout"] == reject["stdout"]
               and all(r["actual_exit"] == 0 and r["error"] is None for r in results)
               and accept["stderr"] == "" and accept["classified"] is True
               and reject["stderr"].strip() == diagnostic and reject["classified"] is False
               and reject["reasons"] == [f"unexpected stderr line: {diagnostic}"])
    payload = {"verdict": "PASS" if verdict else "FAIL", "marker": marker,
               "diagnostic": diagnostic, "results": results, "bounded_claim":
               "One Godot 4.7.2 Node3D fixture, same exit/stdout, unexpected stderr line; "
               "not general logging policy or other-engine behavior."}
    (run_dir / "stream-attribution-verdicts.json").write_text(json.dumps(payload, indent=2) + "\n")
    print(f"{payload['verdict']} stream-attribution probe: "
          f"{run_dir / 'stream-attribution-verdicts.json'}", flush=True)
    return verdict


def probe_tree_timeout(godot, scratch, run_dir):
    marker = "TREE_TIMEOUT_3D: spatial node ready"
    script = "res://timeout_tree3d.gd"
    normal_command = [godot, "--headless", "--path", str(scratch), "--script", script, "--"]
    normal_out, normal_err, normal_code, normal_error = run_process(normal_command, 8)
    normal_ok, normal_reasons = classify(normal_out, normal_err, normal_code, normal_error, 0, marker)
    normal = {"command": normal_command, "actual_exit": normal_code, "stdout": normal_out,
              "stderr": normal_err, "error": normal_error, "classified": normal_ok,
              "reasons": normal_reasons}

    command = normal_command + ["--hold-open"]
    record = {"command": command, "actual_exit": None, "cleanup_exit": None,
              "stdout": "", "stderr": "", "error": None, "timed_out": False,
              "marker_observed": False, "witness": None, "witness_verified": False,
              "witness_gone": False, "witness_cleanup": None, "classified": None, "reasons": []}
    process = None
    witness_pid = None
    witness_start = None
    witness_path = scratch / "timeout-descendant.json"

    def proc_identity(pid):
        proc = Path(f"/proc/{pid}")
        try:
            cmdline = (proc / "cmdline").read_bytes().split(b"\0")
            stat = (proc / "stat").read_text()
            fields = stat[stat.rfind(")") + 2:].split()
            return {"cmdline": [c.decode(errors="replace") for c in cmdline if c],
                    "state": fields[0], "ppid": int(fields[1]), "pgid": int(fields[2]),
                    "starttime": int(fields[19])}
        except (FileNotFoundError, ProcessLookupError):
            return None

    def same_live_witness():
        found = proc_identity(witness_pid) if witness_pid is not None else None
        return (found is not None and found["state"] not in ("Z", "X")
                and found["starttime"] == witness_start
                and str(scratch / "timeout_descendant.py") in found["cmdline"]
                and str(witness_path) in found["cmdline"])

    try:
        if os.name != "posix" or not Path("/proc/self/stat").exists():
            record["error"] = "Linux /proc and POSIX signals required"
        else:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                       start_new_session=True)
            try:
                raw_out, raw_err = process.communicate(timeout=3)
                record["actual_exit"] = process.returncode
            except subprocess.TimeoutExpired as exc:
                record["timed_out"] = True
                record["error"] = "TIMEOUT after 3 seconds"
                record["actual_exit"] = None
                raw_out = exc.stdout or b""
                raw_err = exc.stderr or b""
                record["marker_observed"] = marker.encode() in raw_out.splitlines()
                if witness_path.is_file():
                    witness = json.loads(witness_path.read_text())
                    record["witness"] = witness
                    witness_pid = int(witness["pid"])
                    found = proc_identity(witness_pid)
                    witness_start = found["starttime"] if found else None
                    record["witness_verified"] = bool(
                        found and found["state"] not in ("Z", "X")
                        and found["ppid"] == process.pid and found["pgid"] == witness_pid
                        and str(scratch / "timeout_descendant.py") in found["cmdline"]
                        and str(witness_path) in found["cmdline"])
                if process.poll() is None:
                    os.killpg(process.pid, signal.SIGKILL)
                if record["witness_verified"] and same_live_witness():
                    os.kill(witness_pid, signal.SIGTERM)
                    record["witness_cleanup"] = "SIGTERM to verified detached witness"
                    deadline = time.monotonic() + 3
                    while time.monotonic() < deadline and same_live_witness():
                        time.sleep(0.02)
                    if same_live_witness():
                        os.kill(witness_pid, signal.SIGKILL)
                        record["witness_cleanup"] = "SIGKILL after 3s grace"
                        deadline = time.monotonic() + 3
                        while time.monotonic() < deadline and same_live_witness():
                            time.sleep(0.02)
                record["witness_gone"] = record["witness_verified"] and not same_live_witness()
                try:
                    raw_out, raw_err = process.communicate(timeout=3)
                    record["cleanup_exit"] = process.returncode
                except subprocess.TimeoutExpired:
                    record["error"] += "; Godot cleanup exceeded 3 seconds"
                record["stdout"] = raw_out.decode(errors="replace")
                record["stderr"] = raw_err.decode(errors="replace")
            else:
                record["stdout"] = raw_out.decode(errors="replace")
                record["stderr"] = raw_err.decode(errors="replace")
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        record["error"] = f"timeout probe failed: {exc}"
    finally:
        if process is not None and process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
            try:
                process.communicate(timeout=3)
            except subprocess.TimeoutExpired:
                record["error"] = (record["error"] or "") + "; final Godot cleanup timed out"
        if record["witness_verified"] and same_live_witness():
            os.kill(witness_pid, signal.SIGKILL)
            record["witness_cleanup"] = "forced final SIGKILL to verified identity"
            record["witness_gone"] = not same_live_witness()

    record["marker_observed"] = record["stdout"].splitlines().count(marker) == 1
    classified, reasons = classify(record["stdout"], record["stderr"],
                                   record["actual_exit"], record["error"], 0, marker)
    record["classified"] = classified
    record["reasons"] = reasons
    verdict = (normal_ok and normal_err == "" and record["timed_out"]
               and record["actual_exit"] is None and record["cleanup_exit"] is not None
               and record["marker_observed"] and record["classified"] is False
               and record["witness_verified"] and record["witness_gone"]
               and record["witness_cleanup"] == "SIGTERM to verified detached witness")
    payload = {"verdict": "PASS" if verdict else "FAIL", "normal": normal,
               "timeout": record, "bounded_claim": "One identified detached Godot-spawned "
               "witness terminated after direct-child timeout; not arbitrary process-tree cleanup."}
    (run_dir / "tree-timeout-verdicts.json").write_text(json.dumps(payload, indent=2) + "\n")
    print(f"{payload['verdict']} tree-timeout probe: {run_dir / 'tree-timeout-verdicts.json'}", flush=True)
    return verdict


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--godot", default="/usr/bin/godot" if Path("/usr/bin/godot").exists() else "godot")
    parser.add_argument("--runs", type=Path, default=HERE.parent / "live" / "runs")
    parser.add_argument("--only", default="", help="comma-separated case names to run")
    parser.add_argument("--probe-failing", action="store_true",
                        help="also mutate one authored constant in a scratch copy and prove detection")
    parser.add_argument("--probe-crash-exit", action="store_true",
                        help="compare a normal Godot exit to a SIGTERM-terminated live Godot child")
    parser.add_argument("--probe-stream-attribution", action="store_true",
                        help="compare identical stdout/exit with and without unexpected stderr")
    parser.add_argument("--probe-tree-timeout", action="store_true",
                        help="time out Godot and explicitly clean one identified detached witness")
    args = parser.parse_args()

    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    run_dir = args.runs.resolve() / stamp
    scratch = run_dir / "scratch"
    scratch.mkdir(parents=True)
    digests_before = seed_digests()
    for item in HERE.iterdir():
        if item.name in ("run_battery.py", "__pycache__", "three") or item.name.startswith("."):
            continue
        if item.is_dir():
            shutil.copytree(item, scratch / item.name,
                            ignore=shutil.ignore_patterns("__pycache__"))
        else:
            shutil.copy2(item, scratch / item.name)

    selected = CASES
    if args.only:
        wanted = {name.strip() for name in args.only.split(",") if name.strip()}
        selected = [case for case in CASES if case[0] in wanted]
        unknown = wanted - {case[0] for case in CASES}
        if unknown or not selected:
            print(f"FAIL unknown case names: {sorted(unknown)}")
            return 1

    version_out, version_err, version_code, version_error = run_process([args.godot, "--version"], 20)
    godot_version = version_out.strip().splitlines()[0] if version_out.strip() else ""
    results = []

    def execute(name, script, flags, expected_exit, marker, project):
        command = [args.godot, "--headless", "--path", str(project),
                   "--script", "res://" + script, "--", *flags]
        started = datetime.now(timezone.utc)
        stdout, stderr, code, error = run_process(command, CASE_TIMEOUT_SECONDS)
        elapsed = (datetime.now(timezone.utc) - started).total_seconds()
        passed, reasons = classify(stdout, stderr, code, error, expected_exit, marker)
        record = {"case": name, "script": script, "flags": flags, "command": command,
                  "expected_exit": expected_exit, "actual_exit": code, "error": error,
                  "kind": "negative_control" if expected_exit == 2 else "ordinary",
                  "marker": marker, "verdict": "PASS" if passed else "FAIL",
                  "reasons": reasons, "elapsed_seconds": round(elapsed, 3),
                  "stdout": stdout.strip().splitlines(), "stderr": stderr.strip().splitlines()}
        results.append(record)
        print(f"{record['verdict']} {name}: exit={code} expected={expected_exit}"
              + (f" reasons={reasons}" if reasons else ""), flush=True)
        return record

    for case in selected:
        execute(*case, scratch)

    crash_probe_ok = True
    if args.probe_crash_exit:
        crash_probe_ok = probe_crash_exit(args.godot, scratch, run_dir)
    stream_probe_ok = True
    if args.probe_stream_attribution:
        stream_probe_ok = probe_stream_attribution(args.godot, scratch, run_dir)
    tree_probe_ok = True
    if args.probe_tree_timeout:
        tree_probe_ok = probe_tree_timeout(args.godot, scratch, run_dir)

    probe = None
    if args.probe_failing:
        mutation_scratch = run_dir / "mutation-scratch"
        shutil.copytree(scratch, mutation_scratch, ignore=shutil.ignore_patterns(".godot"))
        target = mutation_scratch / MUTATION["script"]
        text = target.read_text()
        if MUTATION["old"] not in text:
            print(f"FAIL probe: mutation anchor absent from {MUTATION['script']}")
            return 1
        target.write_text(text.replace(MUTATION["old"], MUTATION["new"], 1))
        # The mutant is judged with the seeded case's own expectation: the same
        # exit code and marker that the unmutated fixture satisfies. Detection
        # means that classifier now rejects it, for the authored reason.
        seeded = next(case for case in CASES if case[0] == MUTATION["case"])
        mutated = execute("mutant_" + MUTATION["case"], seeded[1], seeded[2],
                          seeded[3], seeded[4], mutation_scratch)
        diagnostic_lines = [line.strip() for line in mutated["stderr"]
                            if line.strip() == MUTATION["expected_diagnostic"]]
        detected = (mutated["verdict"] == "FAIL"
                    and mutated["actual_exit"] == MUTATION["expected_exit"]
                    and not any(line.strip().startswith(MUTATION["forbidden_stdout"])
                                for line in mutated["stdout"])
                    and len(diagnostic_lines) == 1
                    and not any("SCRIPT ERROR:" in line or "Parse Error:" in line
                                for line in mutated["stdout"] + mutated["stderr"]))
        seeds_unchanged = seed_digests() == digests_before
        probe = {"mutation": MUTATION, "detected": detected, "seeds_unchanged": seeds_unchanged,
                 "seeded_expectation": {"case": seeded[0], "script": seeded[1],
                                        "expected_exit": seeded[3], "marker": seeded[4]},
                 "record": mutated,
                 "seed_digests_before": digests_before,
                 "seed_digests_after": seed_digests(),
                 "mutation_scratch": str(mutation_scratch),
                 "expected_diagnostic_lines": diagnostic_lines,
                 "verdict": "PASS" if detected and seeds_unchanged else "FAIL",
                 "bounded_claim": ("one authored constant (wall box depth 4.0 -> 6.0) mutated in a "
                                   "scratch copy of body3d_slide.gd; proves the contact-plane "
                                   "assertion measures engine geometry instead of restating it. "
                                   "Not a general mutation-coverage claim.")}
        # The probe case itself must not be counted as a seeded battery case.
        results.pop()
        (run_dir / "mutation-verdicts.json").write_text(json.dumps(probe, indent=2) + "\n")
        print(f"{probe['verdict']} adversarial mutation: detected={detected} "
              f"seeds_unchanged={seeds_unchanged} -> {run_dir / 'mutation-verdicts.json'}", flush=True)

    seeds_unchanged = seed_digests() == digests_before
    if not seeds_unchanged:
        print("FAIL seeds were modified during the run; seeds must stay read-only")
    ordinary = sum(1 for r in results if r["kind"] == "ordinary")
    negative = sum(1 for r in results if r["kind"] == "negative_control")
    passed = sum(1 for r in results if r["verdict"] == "PASS")
    failed = len(results) - passed

    print()
    print(f"{'VERDICT':8} {'CASE':34} {'SCRIPT':26} {'FLAGS':18} {'EXIT':9} KIND")
    for record in results:
        flags = ",".join(record["flags"]) or "-"
        exit_text = f"{record['actual_exit']}/{record['expected_exit']}"
        kind = "negative" if record["kind"] == "negative_control" else "ordinary"
        print(f"{record['verdict']:8} {record['case']:34} {record['script']:26} "
              f"{flags:18} {exit_text:9} {kind}")
    if probe is not None:
        print(f"{probe['verdict']:8} {'mutant_' + MUTATION['case']:34} {MUTATION['script']:26} "
              f"{'(scratch mutation)':18} {'-/1':9} probe")
    print(f"totals: cases={len(results)} pass={passed} fail={failed} "
          f"ordinary={ordinary} negative_controls={negative} "
          f"probes={(1 if probe is not None else 0) + (1 if args.probe_crash_exit else 0) + (1 if args.probe_stream_attribution else 0) + (1 if args.probe_tree_timeout else 0)}")

    verdict = ("PASS" if failed == 0 and seeds_unchanged and crash_probe_ok
               and stream_probe_ok and tree_probe_ok
               and (probe is None or probe["verdict"] == "PASS") else "FAIL")
    payload = {"godot": args.godot, "godot_version": godot_version,
               "godot_version_exit": version_code, "godot_version_error": version_error,
               "started_utc": stamp, "seed": str(HERE), "scratch": str(scratch),
               "case_timeout_seconds": CASE_TIMEOUT_SECONDS, "only": args.only or None,
               "probe_failing": args.probe_failing, "probe_crash_exit": args.probe_crash_exit,
               "crash_probe_ok": crash_probe_ok, "probe_stream_attribution": args.probe_stream_attribution,
               "stream_probe_ok": stream_probe_ok, "probe_tree_timeout": args.probe_tree_timeout,
               "tree_probe_ok": tree_probe_ok, "seeds_unchanged": seeds_unchanged,
               "seed_digests": digests_before, "results": results, "probe": probe,
               "totals": {"cases": len(results), "pass": passed, "fail": failed,
                          "ordinary": ordinary, "negative_controls": negative},
               "verdict": verdict}
    (run_dir / "verdicts.json").write_text(json.dumps(payload, indent=2) + "\n")
    print(f"{verdict} battery: {run_dir / 'verdicts.json'}")
    return 0 if verdict == "PASS" else 1


if __name__ == "__main__":
    sys.exit(main())
