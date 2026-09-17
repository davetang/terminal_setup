#!/usr/bin/env bash
# uninstall.sh — remove the ~/bin binaries this repo installed.
# screen is a symlink into its own build prefix, ~/bin/screen-<version>/.
# Leaves conda tools, pip tools (visidata, llm), Miniforge and rc edits alone.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

bins=(bat eza fd rg sd dust duf procs btop delta hyperfine
      jq yq mlr csvtk seqkit duckdb
      fzf zoxide atuin yazi ya broot
      starship direnv
      just chezmoi xh tldr lazygit
      gh tea pandoc viddy ollama trip tt ttyper
      screen)

n=0
for b in "${bins[@]}"; do
  if [[ -e "$BIN/$b" || -L "$BIN/$b" ]]; then rm -f "$BIN/$b"; ok "removed $BIN/$b"; n=$((n+1)); fi
done
for d in "$BIN"/screen-[0-9]*/; do
  if [[ -d "$d" ]]; then rm -rf "$d"; ok "removed ${d%/}"; fi
done
log "removed $n binaries from $BIN"
warn "conda tools, visidata, llm, Miniforge and rc edits were left in place"
