- terminal-setup extras (davetang/terminal-setup):

- Run a tool from PyPI without installing it (fetched once, then cached):

`uvx {{tool}} {{arguments}}`

- Run a command whose package has a different name:

`uvx --from {{csvkit}} {{csvlook}} {{path/to/file.csv}}`

- Run a specific version of a tool:

`uvx {{tool}}@{{version}} {{arguments}}`

- Make an extra package available to the tool:

`uvx --with {{package}} {{tool}} {{arguments}}`

- Run the tool on a particular Python:

`uvx --python {{3.12}} {{tool}} {{arguments}}`
