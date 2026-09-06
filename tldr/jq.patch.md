- terminal-setup extras (davetang/terminal-setup):

- Turn any JSON into a TSV table and pretty-print it:

`gh issue list --json number,title | jq -r '.[] | [.number,.title] | @tsv' | csvtk pretty -t -H`

- Pull one section out of a goaccess JSON report:

`jq '.general' {{report.json}}`

- Biggest entries in an ncdu export:

`ncdu -o - {{path/to/directory}} | jq -r '..|objects|select(.dsize)|[.dsize,.name]|@tsv' | sort -k1,1nr | head`

- Read the tag of the latest release, the way this repo's installer does:

`xh {{https://api.github.com/repos/sharkdp/bat/releases/latest}} | jq -r '.tag_name'`
