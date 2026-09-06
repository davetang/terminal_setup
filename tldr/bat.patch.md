- terminal-setup extras (davetang/terminal-setup):

- Page an aligned CSV/TSV table:

`csvtk pretty {{path/to/data.csv}} | bat`

- Preview files while fuzzy-finding:

`fzf --preview 'bat --color=always {}'`

- Use as the man pager (add to your shell rc):

`export MANPAGER="sh -c 'col -bx | bat -l man -p'"`

- List themes; shell/init.sh pins BAT_THEME so bat never probes the terminal:

`bat --list-themes`
