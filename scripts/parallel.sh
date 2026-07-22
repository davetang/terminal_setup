#!/usr/bin/env bash
# GNU parallel — run jobs in parallel across cores. Built from source upstream;
# here it comes from conda-forge (no compiler needed). Pinned via versions.lock.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install parallel parallel
