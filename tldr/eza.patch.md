- terminal-setup extras (davetang/terminal-setup):

- Long listing with git status, all files and group (the `ll` alias in shell/init.sh):

`eza -lag --git`

- Tree view that skips anything gitignored:

`eza --tree --level={{2}} --git-ignore`

- Biggest entries first:

`eza -l --sort=size --reverse`

- Uncomment the ls/ll/tree aliases in shell/init.sh to make this the default:

`vi {{path/to/terminal-setup}}/shell/init.sh`
