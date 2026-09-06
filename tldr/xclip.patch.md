- terminal-setup extras (davetang/terminal-setup):

- Copy a command's output to the CLIPBOARD selection that Ctrl-V pastes from:

`{{pwd}} | xclip -sel c`

- Paste back into a pipe:

`xclip -sel c -o | csvtk pretty -t`

- Drop the trailing newline, for forms and chat boxes:

`git rev-parse HEAD | tr -d '\n' | xclip -sel c`

- It needs a live X server; with no $DISPLAY it exits with "Can't open display":

`echo $DISPLAY`
