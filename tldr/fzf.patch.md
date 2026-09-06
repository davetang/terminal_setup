- terminal-setup extras (davetang/terminal-setup):

- shell/init.sh evaluates fzf's shell integration, so Ctrl-T (paths) and Alt-C (cd) are already bound; atuin owns Ctrl-R:

- Preview with syntax highlighting:

`fzf --preview 'bat --color=always {}'`

- Make fd the default source (add to your shell rc):

`export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'`

- Pick a file and open it:

`vi "$(fzf)"`

- Browse this setup's own tool docs:

`tldr --list | fzf --preview 'tldr {}' | xargs tldr`
