#!/usr/bin/env bash
# setup_shell.sh — wire ~/bin and tool init into the user's shell rc.
# Idempotent: adds a single guarded block that sources shell/init.sh.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

mkdir -p "$BIN"
init="$ROOTDIR/shell/init.sh"
begin="# >>> terminal-setup >>>"
end="# <<< terminal-setup <<<"

wire() {
  local rc="$1"
  [[ -f "$rc" ]] || { warn "skipping $rc (does not exist — create it, then re-run 'make setup')"; return; }
  if grep -qF "$begin" "$rc"; then ok "already wired: $rc"; return; fi
  {
    printf '\n%s\n' "$begin"
    printf '[ -f %q ] && source %q\n' "$init" "$init"
    printf '%s\n' "$end"
  } >> "$rc"
  ok "wired terminal-setup into $rc"
}

wire "$HOME/.bashrc"
wire "$HOME/.zshrc"     # created after you install zsh; re-run 'make setup' then
echo
ok "setup complete — restart your shell or:  source ~/.bashrc"
