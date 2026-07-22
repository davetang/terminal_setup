#!/usr/bin/env bash
# uninstall.sh — remove the ~/bin binaries this repo installed.
# Leaves conda tools, pip (visidata), Miniforge and rc edits alone.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

bins=(bat eza fd rg sd dust duf procs btop delta hyperfine
      jq yq mlr csvtk seqkit
      fzf zoxide atuin yazi ya broot
      starship direnv
      just chezmoi xh tldr
      gh pandoc viddy)

n=0
for b in "${bins[@]}"; do
  if [[ -e "$BIN/$b" ]]; then rm -f "$BIN/$b"; ok "removed $BIN/$b"; n=$((n+1)); fi
done
log "removed $n binaries from $BIN"
warn "conda tools, visidata, Miniforge and rc edits were left in place"
