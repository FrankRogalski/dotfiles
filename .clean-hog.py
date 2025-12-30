#!/usr/bin/env python3

import os
from pathlib import Path
import sys

TO_CUT = 1_000_000
path = Path.home() / "mailhog.log"

try:
    size = path.stat().st_size
except FileNotFoundError:
    print("mailhog log not found")
    sys.exit()

if size <= TO_CUT:
    print("mailhog log is in size limits")
    sys.exit()

with open(path, "rb") as file:
    file.seek(max(0, size - TO_CUT))
    chunk = file.read()

index = chunk.find(b"\n")
if index < 0:
    print("mailhog has no linebreaks in the text, wtf")
    sys.exit(1)

trimmed = chunk[index + 1 :]
tmp_path = path.with_suffix(path.suffix + ".tmp")
with open(tmp_path, "wb") as file:
    file.write(trimmed)
os.replace(tmp_path, path)

print("mailhog log cut")
