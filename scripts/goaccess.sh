#!/usr/bin/env bash
# goaccess — real-time web log analyzer (https://goaccess.io/). C program with
# no static binary release upstream; via conda-forge.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install goaccess goaccess
