#!/usr/bin/env bash
# uninstall.sh — remove the ~/bin binaries this repo installed.
# screen, go and the JDK are symlinks into their own prefixes under ~/bin
# (screen-<version>/, go-<version>/, jdk-<release>/); those trees go too.
# Leaves conda tools (tree, pigz, coreutils among them), pip tools (visidata,
# llm), Miniforge, ~/.oh-my-zsh and rc edits alone.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

bins=(bat eza fd rg sd dust duf procs btop delta hyperfine
      jq yq mlr csvtk seqkit duckdb
      fzf zoxide atuin yazi ya broot
      starship direnv
      just chezmoi xh tldr lazygit
      shellcheck shfmt ruff
      gh tea pandoc viddy ollama sendcb notify notify-hook.sh trip tt ttyper
      screen go gofmt java javac jar jshell)

n=0
for b in "${bins[@]}"; do
  if [[ -e "$BIN/$b" || -L "$BIN/$b" ]]; then rm -f "$BIN/$b"; ok "removed $BIN/$b"; n=$((n+1)); fi
done
for d in "$BIN"/screen-[0-9]*/ "$BIN"/go-[0-9]*/ "$BIN"/jdk-[0-9]*/; do
  if [[ -d "$d" ]]; then rm -rf "$d"; ok "removed ${d%/}"; fi
done
log "removed $n binaries from $BIN"
warn "conda tools, visidata, llm, Miniforge and rc edits were left in place"
warn "oh-my-zsh was left in ${ZSH:-$HOME/.oh-my-zsh} — 'uninstall_oh_my_zsh' removes it and restores ~/.zshrc"
