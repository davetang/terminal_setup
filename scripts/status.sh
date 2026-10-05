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
       shellcheck shfmt ruff air jarl
       gh tea pandoc viddy ollama sendcb notify showimg termcheck trip tt ttyper
       tmux zsh datamash parallel pv goaccess xclip ncdu vd llm
       tree pigz gls
       screen)

# Opt-in extras: not part of 'make install', so they are reported separately
# and left out of the count below — otherwise everyone who skipped them reads
# a total that says something is wrong. Each is "command:how to get it". R is
# rig's to install, not this repo's, so its hint is the next step after rig
# (and both steps when rig is missing too).
extras=(go:"make sdks" gofmt:"make sdks" java:"make sdks" javac:"make sdks"
        rig:"make rig" R:"rig add release")

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
rig_ok=
for e in "${extras[@]}"; do
  t="${e%%:*}" hint="${e#*:}"
  p="$(command -v "$t" 2>/dev/null)"
  # Only r-lib's rig counts: Debian's unrelated rig package, a random name and
  # address generator, puts one in /usr/games.
  if [[ "$t" == rig && -n "$p" ]]; then
    if "$p" --version </dev/null 2>/dev/null | grep -q 'R Installation Manager'; then rig_ok=1
    else p=; fi
  fi
  [[ "$t" == R && -z "$rig_ok" ]] && hint="make rig, then rig add release"
  if [[ -n "$p" ]]; then printf '%-12s %s%-8s%s %s\n' "$t" "$_c_green" "ok" "$_c_reset" "$p"
  else printf '%-12s %s%-8s%s %s\n' "$t" "$_c_yellow" "-" "$_c_reset" "$hint"; fi
done
omz="${ZSH:-$HOME/.oh-my-zsh}"
if [[ -r "$omz/oh-my-zsh.sh" ]]; then
  printf '%-12s %s%-8s%s %s\n' "oh-my-zsh" "$_c_green" "ok" "$_c_reset" "$omz"
else
  printf '%-12s %s%-8s%s %s\n' "oh-my-zsh" "$_c_yellow" "-" "$_c_reset" "make ohmyzsh"
fi
