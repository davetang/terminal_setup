- terminal-setup extras (davetang/terminal-setup):

- Make zsh your login shell; this needs the binary listed in /etc/shells, which needs root:

`chsh -s "$(command -v zsh)"`

- No root? Hand over from bash instead, guarded against loops (end of ~/.bashrc):

`[ -z "$ZSH_VERSION" ] && [ -t 1 ] && exec zsh -l`

- Confirm `make setup` wrote its block into your rc:

`rg 'terminal-setup' {{~/.zshrc}}`
