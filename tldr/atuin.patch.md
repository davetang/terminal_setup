- terminal-setup extras (davetang/terminal-setup):

- shell/init.sh binds Ctrl-R to atuin; the history stays local unless you register a sync account:

- Search history from the command line:

`atuin search {{docker}}`

- What you actually run, counted:

`atuin stats`

- The last commands as plain text, for piping:

`atuin history list --cmd-only | tail -n {{20}}`

- Import the shell history you already had:

`atuin import auto`
