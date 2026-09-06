- terminal-setup extras (davetang/terminal-setup):

- Print only the matches, without file names or line numbers (mine words for a typing drill):

`rg -oIN '\w{3,}' {{path/to/notes.md}} | sort -u`

- Count matches per file:

`rg -c {{TODO}}`

- Replace across only the files that actually match:

`rg -l '{{old}}' | xargs sd '{{old}}' '{{new}}'`

- Check it really is faster here:

`hyperfine 'rg {{foo}}' 'grep -r {{foo}} .'`
