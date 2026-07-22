# shell/init.sh — terminal-setup shell integration.
# Sourced from ~/.bashrc / ~/.zshrc by 'make setup'. Safe for bash and zsh.

# Put our no-root install dirs first on PATH.
case ":$PATH:" in *":$HOME/bin:"*) ;; *) export PATH="$HOME/bin:$PATH" ;; esac
[ -d "$HOME/.local/bin" ] && case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
[ -d "$HOME/miniforge3/bin" ] && case ":$PATH:" in *":$HOME/miniforge3/bin:"*) ;; *) export PATH="$HOME/miniforge3/bin:$PATH" ;; esac

# Which shell are we in?
if [ -n "${ZSH_VERSION:-}" ]; then _ts_sh=zsh
elif [ -n "${BASH_VERSION:-}" ]; then _ts_sh=bash
else _ts_sh=; fi

if [ -n "$_ts_sh" ]; then
  command -v starship >/dev/null 2>&1 && eval "$(starship init $_ts_sh)"
  command -v zoxide   >/dev/null 2>&1 && eval "$(zoxide init $_ts_sh)"
  command -v atuin    >/dev/null 2>&1 && eval "$(atuin init $_ts_sh)"
  command -v direnv   >/dev/null 2>&1 && eval "$(direnv hook $_ts_sh)"
  command -v fzf      >/dev/null 2>&1 && eval "$(fzf --$_ts_sh 2>/dev/null)"
fi
unset _ts_sh

# --- optional aliases (uncomment the ones you want) ---
# command -v bat  >/dev/null 2>&1 && alias cat='bat --paging=never'
# command -v eza  >/dev/null 2>&1 && { alias ls='eza --group-directories-first'; alias ll='eza -lag --git'; alias tree='eza --tree'; }
# command -v fd   >/dev/null 2>&1 && alias find='fd'
# command -v rg   >/dev/null 2>&1 && alias grep='rg'
# command -v dust >/dev/null 2>&1 && alias du='dust'
# command -v duf  >/dev/null 2>&1 && alias df='duf'
# command -v procs>/dev/null 2>&1 && alias ps='procs'
# command -v btop >/dev/null 2>&1 && alias top='btop'
