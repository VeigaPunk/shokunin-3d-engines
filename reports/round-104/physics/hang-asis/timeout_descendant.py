#!/usr/bin/env python3
"""Cooperative process-group witness; executable only inside runner scratch."""
import json
import os
import sys
import time
from pathlib import Path

pidfile = Path(sys.argv[1])
pidfile.write_text(json.dumps({"pid": os.getpid(), "pgid": os.getpgid(0), "ppid": os.getppid()}) + "\n")
time.sleep(30)
