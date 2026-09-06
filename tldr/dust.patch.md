- terminal-setup extras (davetang/terminal-setup):

- Two levels deep, ignoring .git:

`dust -d {{2}} -X {{.git}} {{path/to/directory}}`

- What this setup put on disk:

`dust {{~/bin}} {{~/miniforge3}} {{~/.local}}`

- dust prints and exits; hand the same directory to ncdu to walk into it and delete:

`ncdu {{path/to/directory}}`
