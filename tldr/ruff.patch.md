- terminal-setup extras (davetang/terminal-setup):

- Lint a tree:

`ruff check {{path/to/directory}}`

- Apply the fixes ruff considers safe:

`ruff check --fix {{path/to/directory}}`

- Format, black-compatible:

`ruff format {{path/to/directory}}`

- Sort imports only (the isort rules):

`ruff check --select {{I}} --fix {{path/to/directory}}`

- Count findings by rule, to see what is worth fixing first:

`ruff check --statistics {{path/to/directory}}`
