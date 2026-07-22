#!/usr/bin/env bash
# tmux — terminal multiplexer. No official static binary; via conda-forge.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install tmux tmux
