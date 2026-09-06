- terminal-setup extras (davetang/terminal-setup):

- shell/init.sh runs `starship init` automatically, but skips it when ZSH_THEME is set; override either way:

`export TS_STARSHIP={{1}}`

- Drop in a ready-made preset:

`starship preset {{nerd-font-symbols}} -o {{~/.config/starship.toml}}`

- List the presets:

`starship preset --list`

- Find which module is slowing the prompt down:

`starship timings`
