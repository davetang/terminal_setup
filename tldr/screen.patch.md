- terminal-setup extras (davetang/terminal-setup):

- Attach to a session, detaching it elsewhere first, or create it if it does not exist:

`screen -d -R -S {{session_name}}`

- Turn on 24-bit colour (Screen 5 only) for every session started afterwards:

`echo 'truecolor on' >> ~/.screenrc`

- Screen is built from source into ~/bin here; check which one PATH finds first, and its version:

`command -v screen && screen -v`

- Keys after the Ctrl-a prefix: c new window · n/p next/previous · " window list · S split · Tab next region · X close region · d detach · ? list all keys:
