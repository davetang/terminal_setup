#!/usr/bin/env bash
# datamash — GNU group-by statistics. No static binary release; via conda-forge.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install datamash datamash
