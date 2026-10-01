#!/usr/bin/env bash
# status.sh — report which tools are installed and where (read-only).
set -uo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
set +e

# command names to probe (visidata -> vd, yazi ships ya too)
tools=(bat eza fd rg sd dust duf procs btop delta hyperfine
       jq yq mlr csvtk seqkit duckdb
       fzf zoxide atuin yazi ya broot
       starship direnv
       just chezmoi xh tldr lazygit
       shellcheck shfmt ruff
       gh tea pandoc viddy ollama sendcb trip tt ttyper
       tmux zsh datamash parallel pv goaccess xclip ncdu vd llm
       tree pigz gls
       screen)

# Opt-in extras: not part of 'make install', so they are reported separately
# and left out of the count below — otherwise everyone who skipped them reads
# a total that says something is wrong.
extras=(go gofmt java javac)

printf '%-12s %-8s %s\n' TOOL STATUS LOCATION
printf '%-12s %-8s %s\n' ---- ------ --------
present=0; total=0
for t in "${tools[@]}"; do
  total=$((total+1))
  p="$(command -v "$t" 2>/dev/null)"
  if [[ -n "$p" ]]; then
    present=$((present+1))
    printf '%-12s %s%-8s%s %s\n' "$t" "$_c_green" "ok" "$_c_reset" "$p"
  else
    printf '%-12s %s%-8s%s %s\n' "$t" "$_c_yellow" "missing" "$_c_reset" "-"
  fi
done
echo
ok "$present / $total installed"

echo
printf '%-12s %-8s %s\n' EXTRA STATUS LOCATION
printf '%-12s %-8s %s\n' ----- ------ --------
for t in "${extras[@]}"; do
  p="$(command -v "$t" 2>/dev/null)"
  if [[ -n "$p" ]]; then printf '%-12s %s%-8s%s %s\n' "$t" "$_c_green" "ok" "$_c_reset" "$p"
  else printf '%-12s %s%-8s%s %s\n' "$t" "$_c_yellow" "-" "$_c_reset" "make sdks"; fi
done
omz="${ZSH:-$HOME/.oh-my-zsh}"
if [[ -r "$omz/oh-my-zsh.sh" ]]; then
  printf '%-12s %s%-8s%s %s\n' "oh-my-zsh" "$_c_green" "ok" "$_c_reset" "$omz"
else
  printf '%-12s %s%-8s%s %s\n' "oh-my-zsh" "$_c_yellow" "-" "$_c_reset" "make ohmyzsh"
fi
