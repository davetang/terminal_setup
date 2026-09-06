- terminal-setup extras (davetang/terminal-setup):

- `tldr just` is a disambiguation page; this setup installs the command runner (`tldr just.1` for the full page):

`just --list`

- Pick a recipe interactively (uses fzf):

`just --choose`

- Format the justfile in place:

`just --fmt --unstable`

- Run a recipe from anywhere:

`just -f {{path/to/justfile}} {{recipe}} {{argument}}`
