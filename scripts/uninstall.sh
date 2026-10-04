#!/usr/bin/env bash
# uninstall.sh — remove the ~/bin binaries this repo installed.
# screen, go and the JDK are symlinks into their own prefixes under ~/bin
# (screen-<version>/, go-<version>/, jdk-<release>/), and rig is a wrapper
# around ~/bin/rig-<version>/rig; those trees go too.
# Leaves conda tools (tree, pigz, coreutils among them), pip tools (visidata,
# llm), Miniforge, ~/.oh-my-zsh and rc edits alone, and the R versions rig
# installed: they are rig's, and they run without it.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

bins=(bat eza fd rg sd dust duf procs btop delta hyperfine
      jq yq mlr csvtk seqkit duckdb
      fzf zoxide atuin yazi ya broot
      starship direnv
      just chezmoi xh tldr lazygit
      shellcheck shfmt ruff
      gh tea pandoc viddy ollama sendcb notify notify-hook.sh showimg termcheck trip tt ttyper
      screen go gofmt java javac jar jshell rig)

n=0
for b in "${bins[@]}"; do
  if [[ -e "$BIN/$b" || -L "$BIN/$b" ]]; then rm -f "$BIN/$b"; ok "removed $BIN/$b"; n=$((n+1)); fi
done
for d in "$BIN"/screen-[0-9]*/ "$BIN"/go-[0-9]*/ "$BIN"/jdk-[0-9]*/ "$BIN"/rig-[0-9]*/; do
  if [[ -d "$d" ]]; then rm -rf "$d"; ok "removed ${d%/}"; fi
done
log "removed $n binaries from $BIN"
warn "conda tools, visidata, llm, Miniforge and rc edits were left in place"
warn "oh-my-zsh was left in ${ZSH:-$HOME/.oh-my-zsh} — 'uninstall_oh_my_zsh' removes it and restores ~/.zshrc"
if compgen -G "$HOME/.local/share/rig/r/*" >/dev/null; then
  warn "R, installed by rig, was left in ~/.local/share/rig/r and still runs; to remove it too: rm -rf ~/.local/share/rig $BIN/R $BIN/Rscript $BIN/R-*  (your packages are in ~/R)"
fi
