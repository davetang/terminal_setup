- terminal-setup extras (davetang/terminal-setup):

- Jump to a frecent directory (`z` and `zi` come from the init in shell/init.sh):

`z {{proj}}`

- Interactive pick, which needs fzf (this setup installs it):

`zi`

- Two keywords narrow it further:

`z {{src}} {{tool}}`

- Inspect the ranking database:

`zoxide query -l -s`
