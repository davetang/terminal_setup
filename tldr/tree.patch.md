- terminal-setup extras (davetang/terminal-setup):

- Directories only, which is usually what you wanted:

`tree -d {{path/to/directory}}`

- Stop at a depth, so a deep repo stays readable:

`tree -L {{2}} {{path/to/directory}}`

- Include dotfiles, but never .git:

`tree -a -I {{.git}} {{path/to/directory}}`

- Human-readable sizes, with a total at the bottom:

`tree -h --du {{path/to/directory}}`

- Newest files last, to see what a build just wrote:

`tree -t {{path/to/directory}}`

- JSON out, for the rest of this setup to read:

`tree -J {{path/to/directory}} | jq -r '..|objects|select(.type=="file")|.name'`

- Plain paths instead of the drawing, to pipe into fzf or xargs:

`tree -fi --noreport {{path/to/directory}}`
