#!/usr/bin/env bash
# ohmyzsh.sh — Oh My Zsh (https://ohmyz.sh), the zsh configuration framework.
#
# A git clone into ~/.oh-my-zsh plus five lines in ~/.zshrc. No root.
# Upstream's install.sh does the clone; it is run unattended, with the two
# things it would otherwise do to your account switched off:
#   CHSH=no        don't run chsh. Changing your login shell is not this repo's
#                  business, and the zsh here may be conda's, which is not in
#                  /etc/shells. Start it with `exec zsh` instead.
#   RUNZSH=no      don't drop into a new zsh at the end; there is more to do.
#   KEEP_ZSHRC=yes never replace an existing ~/.zshrc — 'make setup' put a
#                  terminal-setup block in there.
#
# That last flag has a catch worth knowing: when ~/.zshrc already exists,
# install.sh keeps it *and skips wiring oh-my-zsh into it entirely*, so the
# clone would sit there doing nothing. This script adds the block itself, in a
# guarded form it can recognise again, and puts it BEFORE the terminal-setup
# block: shell/init.sh checks ZSH_THEME to decide whether to start starship
# (the two both own the prompt and cannot share it), and sourcing oh-my-zsh.sh
# afterwards would reset the prompt regardless of what that check decided.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
zshrc="$HOME/.zshrc"
ts_begin="# >>> terminal-setup >>>"   # the marker scripts/setup_shell.sh writes

# --- prerequisites ------------------------------------------------------------
have git || die "ohmyzsh: 'git' not found — Oh My Zsh is a git clone and needs it (apt/dnf install git)"

# install.sh refuses to run without a zsh on PATH. A conda zsh is in
# ~/miniforge3/bin, which is only on PATH after 'make setup' and a new shell,
# so find it and put it there for the length of this script.
if ! have zsh; then
  for z in "$BIN/zsh" "$HOME/miniforge3/bin/zsh"; do
    [[ -x "$z" ]] && { PATH="$(dirname "$z"):$PATH"; export PATH; break; }
  done
fi
have zsh || die "ohmyzsh: no zsh on PATH — run 'make zsh' first (Oh My Zsh configures zsh; it does not install it)"

# --- clone --------------------------------------------------------------------
if [[ -d "$ZSH_DIR" ]]; then
  if [[ "$FORCE" != 1 ]]; then
    ok "oh-my-zsh already at $ZSH_DIR (FORCE=1 to reinstall)"
  else
    # Moved aside, not deleted: custom themes and plugins live under here.
    aside="$ZSH_DIR.pre-$(date +%Y%m%d%H%M%S)"
    mv "$ZSH_DIR" "$aside"
    warn "moved the old install to $aside (custom themes and plugins are in it)"
  fi
fi

if [[ ! -d "$ZSH_DIR" ]]; then
  log "installing oh-my-zsh into $ZSH_DIR  (github:ohmyzsh/ohmyzsh, master)"
  fetch https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh "$TMP/omz.sh"
  CHSH=no RUNZSH=no KEEP_ZSHRC=yes ZSH="$ZSH_DIR" sh "$TMP/omz.sh" --unattended \
    || die "ohmyzsh: upstream install.sh failed (output above)"
  [[ -r "$ZSH_DIR/oh-my-zsh.sh" ]] || die "ohmyzsh: $ZSH_DIR/oh-my-zsh.sh is missing after install"
  ok "cloned to $ZSH_DIR"
fi

# --- wire it into ~/.zshrc ----------------------------------------------------
if [[ ! -f "$zshrc" ]]; then
  # No ~/.zshrc existed, so install.sh wrote one from its own template and
  # oh-my-zsh is already sourced there. But that file is new, so the
  # terminal-setup block is not in it.
  warn "$zshrc did not exist — install.sh created one from the oh-my-zsh template; re-run 'make setup' to add this repo's block to it"
elif grep -q 'oh-my-zsh\.sh' "$zshrc"; then
  ok "oh-my-zsh already sourced from $zshrc"
else
  cat > "$TMP/omz-block" <<'BLOCK'
# >>> oh-my-zsh >>>
export ZSH="$HOME/.oh-my-zsh"
# Any theme in ~/.oh-my-zsh/themes. While ZSH_THEME is set, shell/init.sh
# leaves starship alone — set TS_STARSHIP=1 there to override that.
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
# <<< oh-my-zsh <<<
BLOCK

  if grep -qF "$ts_begin" "$zshrc"; then
    # Insert above the terminal-setup block so init.sh is sourced last.
    # Built in $TMP and copied over afterwards, never generated straight into
    # $zshrc: a redirect truncates the file before awk writes a byte, so any
    # failure there would leave your shell config empty.
    cp "$zshrc" "$TMP/zshrc.bak"
    awk -v blockfile="$TMP/omz-block" -v marker="$ts_begin" '
      index($0, marker) && !done {
        while ((getline line < blockfile) > 0) print line
        print ""
        done = 1
      }
      { print }
    ' "$TMP/zshrc.bak" > "$TMP/zshrc.new"

    # This rewrite only ever inserts, so anything shorter than the original
    # means awk went wrong. Leave the file alone and say so.
    if [[ ! -s "$TMP/zshrc.new" ]] \
       || (( $(wc -l < "$TMP/zshrc.new") <= $(wc -l < "$TMP/zshrc.bak") )); then
      die "ohmyzsh: the rewrite of $zshrc came out wrong, so it was left untouched — add the block from scripts/ohmyzsh.sh by hand, above the terminal-setup block"
    fi
    # cat, not mv: keeps the inode, the mode, and any symlink $zshrc may be.
    cat "$TMP/zshrc.new" > "$zshrc"
    ok "added the oh-my-zsh block to $zshrc, above the terminal-setup block"
  else
    { printf '\n'; cat "$TMP/omz-block"; } >> "$zshrc"
    ok "added the oh-my-zsh block to $zshrc"
  fi
fi

log "oh-my-zsh done — 'exec zsh' to try it; put your own aliases in \${ZSH_CUSTOM:-\$ZSH/custom}/*.zsh"
