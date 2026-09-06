- terminal-setup extras (davetang/terminal-setup):

- Compare a modern tool against its coreutils counterpart:

`hyperfine 'rg {{foo}}' 'grep -r {{foo}} .'`

- Export results and read them back with this setup's table tools:

`hyperfine --export-csv {{bench.csv}} '{{command1}}' '{{command2}}' && csvtk pretty {{bench.csv}}`

- A Markdown table to paste into a PR:

`hyperfine --export-markdown {{bench.md}} '{{command1}}' '{{command2}}'`
