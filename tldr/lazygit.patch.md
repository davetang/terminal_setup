- terminal-setup extras (davetang/terminal-setup):

- Keys: space stages · c commit · P push · p pull · b branches · 1-5 switch panels · ? help · q quit:

- Open its config, to set delta as the diff pager (git.paging.pager: delta --dark --paging=never):

`vi "$(lazygit -cd)/config.yml"`

- Run it against another clone without cd-ing there:

`lazygit -p {{path/to/repository}}`
