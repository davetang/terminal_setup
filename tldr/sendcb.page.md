# sendcb

> Copy text to the clipboard of the machine you are sitting at, including over SSH and inside tmux or GNU screen.
> Sends an OSC 52 escape sequence to your terminal; uses pbcopy, wl-copy, xclip or xsel at a local desktop.
> More information: <https://github.com/davetang/sendcb>.

- Copy a command's output, then paste with Cmd-V or Ctrl-V on your own machine:

`{{git rev-parse HEAD}} | sendcb`

- Copy a file:

`sendcb {{~/.ssh/id_ed25519.pub}}`

- Drop the trailing newline, for forms and chat boxes:

`pwd | sendcb -n`

- Print which method it picked (osc52, and whether via tmux or wrapped for screen):

`{{command}} | sendcb -v`

- Force OSC 52, in a tmux or screen session started at the desktop and reattached over SSH:

`{{command}} | sendcb -o`

- Inside tmux, let programs set the clipboard, or tmux drops the sequence (put the same line in ~/.tmux.conf to keep it):

`tmux set -g set-clipboard on`

- Test the terminal on its own, outside tmux and screen, then paste locally:

`printf '\e]52;c;%s\a' "$(printf 'hello' | base64 | tr -d '\n')"`
