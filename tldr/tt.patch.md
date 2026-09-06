- terminal-setup extras (davetang/terminal-setup):

- Log every test to a CSV you can track over time:

`tt -oneshot -t {{60}} -csv >> {{~/typing.csv}}`

- Read that log back:

`csvtk -H pretty {{~/typing.csv}}`

- Drill a word list of your weak keys, with no correcting:

`tt -words {{~/weak.txt}} -n {{5}} -g {{10}} -nobackspace`

- Type a real file, one paragraph at a time:

`tt {{path/to/notes.md}}`

- What is built in (12 word lists, 180 themes, all embedded in the binary):

`tt -list {{words}}`
