#!/usr/bin/env bash
# miniforge.sh — install Miniforge (conda) under ~/miniforge3, no root.
# Idempotent: does nothing if a conda is already available.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

if have conda || have mamba; then
  ok "conda already available: $(command -v conda mamba 2>/dev/null | head -1)"; exit 0
fi
if [[ -x "$HOME/miniforge3/bin/conda" ]]; then
  ok "Miniforge already installed at ~/miniforge3"; exit 0
fi

log "installing Miniforge under ~/miniforge3 (no root)"
url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(arch).sh"
fetch "$url" "$TMP/miniforge.sh"
bash "$TMP/miniforge.sh" -b -p "$HOME/miniforge3"
ok "Miniforge installed to ~/miniforge3"
warn "add to your shell rc:  source ~/miniforge3/etc/profile.d/conda.sh  (or run 'make setup')"
