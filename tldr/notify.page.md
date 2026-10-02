# notify

> Pop up a desktop notification on the machine you are sitting at, including over SSH and inside tmux or GNU screen.
> Sends an OSC 9, OSC 777 or OSC 99 escape sequence to your terminal; its shell hook notifies when a long command finishes.
> More information: <https://github.com/davetang/notify>.

- Say whether a command worked when it finishes ("Done: build" or "Failed (exit 2): build"):

`{{make -j8}}; notify -e $? {{build}}`

- Run a command, then notify with its exit status and run time:

`notify -c {{snakemake -j 16}}`

- Send a message with a title of your own (the default title is this machine's name):

`notify -t {{'job 4182'}} {{'merged the BAM files'}}`

- Print which method it used (osc9, osc777, osc99 or bell) and where it sent it:

`notify -v {{hello}}`

- Pick the method yourself, for a terminal that shows no notifications or a mosh session:

`export NOTIFY_METHOD={{bell}}`

- Have the shell hook notify only for commands of 5 minutes or more (set it after the hook is loaded):

`NOTIFY_MIN_SECONDS={{300}}`

- Test the terminal on its own, outside tmux and screen:

`printf '\e]9;{{hello from OSC 9}}\a'`
