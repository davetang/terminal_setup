- terminal-setup extras (davetang/terminal-setup):

- Diff what formatting would change, writing nothing (exits 1 if any):

`shfmt -d {{path/to/script.sh}}`

- List only the files that need formatting, for CI:

`shfmt -l {{path/to/directory}}`

- Rewrite with a 2-space indent and indented switch cases:

`shfmt -i {{2}} -ci -w {{path/to/script.sh}}`

- Format every shell script in the tree:

`fd -e sh -x shfmt -w`
