# air

> Fast R formatter and language server, from Posit.
> Settings come from an air.toml or .air.toml found above the files formatted.
> More information: <https://posit-dev.github.io/air/>.

- Format every R file in a directory tree, in place:

`air format {{path/to/directory}}`

- Format specific files:

`air format {{path/to/file1.R path/to/file2.R}}`

- Report what would change without writing (exit 1 if anything would), for CI:

`air format --check {{path/to/directory}}`

- Format from stdin to stdout, looking up settings as if it were the given file:

`air format --stdin-file-path {{path/to/file.R}} < {{path/to/file.R}}`

- Ignore any air.toml and use the default style:

`air format --no-configuration {{path/to/directory}}`

- Format a file that an exclude pattern would skip:

`air format --force {{path/to/file.R}}`

- Start the language server, for an editor to talk to:

`air language-server`
