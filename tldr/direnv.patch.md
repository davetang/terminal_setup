- terminal-setup extras (davetang/terminal-setup):

- Per-directory environment (the hook is wired by `make setup`):

`echo 'export {{API_KEY=xxx}}' > .envrc && direnv allow`

- Put a project's scripts on PATH only inside that project:

`echo 'PATH_add {{./scripts}}' >> .envrc && direnv allow`

- Run one command with a directory's environment without cd-ing there:

`direnv exec {{path/to/directory}} {{command}}`
