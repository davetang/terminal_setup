- terminal-setup extras (davetang/terminal-setup):

- Simple literal replace on a stream (no regex escaping):

`echo {{hello}} | sd {{l}} {{L}}`

- Replace across every matching file (fd honours .gitignore, find does not):

`fd -e {{md}} -x sd '{{old}}' '{{new}}'`

- Only touch files that match, listed by ripgrep first:

`rg -l '{{old}}' | xargs sd '{{old}}' '{{new}}'`
