#!/usr/bin/env bash
# status.sh — report which tools are installed and where (read-only).
set -uo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
set +e

# command names to probe (visidata -> vd, yazi ships ya too)
tools=(bat eza fd rg sd dust duf procs btop delta hyperfine
       jq yq mlr csvtk seqkit
       fzf zoxide atuin yazi ya broot
       starship direnv
       just chezmoi xh tldr
       gh pandoc viddy ollama
       tmux zsh datamash parallel pv vd llm)

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
