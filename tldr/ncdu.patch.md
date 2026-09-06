- terminal-setup extras (davetang/terminal-setup):

- Scan once, browse the export later (worth it over NFS or on spinning disks):

`ncdu -1xo {{scan.json}} {{path/to/directory}}`

- Browse a saved scan; delete, refresh and shell are disabled for it:

`ncdu -f {{scan.json}}`

- Read-only on a shared box; -rr also drops the shell:

`ncdu -r {{path/to/directory}}`

- Record mtimes too, so M sorts by them and m shows the column:

`ncdu -e {{path/to/directory}}`

- Mine the JSON export (a directory's own dsize is its inode, not the recursive total):

`ncdu -o - {{path/to/directory}} | jq -r '..|objects|select(.dsize)|[.dsize,.name]|@tsv' | sort -k1,1nr | head`

- Keys: s size sort · a apparent size · g percent or graph · e hidden · r recalculate · d delete · q quit:
