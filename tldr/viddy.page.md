# viddy

> A modern `watch`: re-runs a command periodically, with a pager, diffs and a time machine.
> More information: <https://github.com/sachaos/viddy>.

- Re-run a command every 2 seconds:

`viddy -n {{2}} {{kubectl get pods}}`

- Highlight what changed between runs:

`viddy -d {{free -h}}`

- Sub-second interval, scheduled precisely rather than after each run:

`viddy -n {{0.5}} -p {{command}}`

- Run through a shell, so pipes and redirects work:

`viddy --shell {{bash}} '{{ls | wc -l}}'`

- Do not record runs whose output did not change:

`viddy -s -d {{command}}`

- Save a session, and replay it later:

`viddy --save {{path/to/session}} {{command}}`

- Replay a saved session:

`viddy --load {{path/to/session}}`

- Keys: SPACE time machine · Shift-J and Shift-K past and future · d diff · t title · / search · ? help:
