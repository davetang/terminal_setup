#!/usr/bin/env bash
# pv (pipe viewer) — progress bar / throughput for pipes. Built from source
# upstream; here it comes from conda-forge. Pinned via versions.lock.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install pv pv
