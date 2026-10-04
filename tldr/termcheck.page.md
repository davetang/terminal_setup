# termcheck

> Report what a shell can send to the terminal you are sitting at, over SSH and mosh and through tmux or GNU screen.
> Checks clipboard copies, notifications, images, links and 24-bit colour, and says what to change; changes nothing itself.
> More information: <https://github.com/davetang/termcheck>.

- Report each feature as ok, fix, no or ?, with the lines to add where something needs fixing:

`termcheck`

- Also send a test of each feature, to see which arrive (copies a line of text to your clipboard):

`termcheck -t`

- Also show the terminal's answers, byte by byte:

`termcheck -v`

- Run a command only when something needs fixing (exit status 1):

`termcheck || {{echo 'something to fix'}}`

- After adding the fixes to ~/.tmux.conf, load them, then detach and reattach before checking again:

`tmux source-file ~/.tmux.conf`
