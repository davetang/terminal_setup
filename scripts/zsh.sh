#!/usr/bin/env bash
# zsh — the shell. No official static binary; via conda-forge.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install zsh zsh
