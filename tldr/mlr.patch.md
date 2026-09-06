- terminal-setup extras (davetang/terminal-setup):

- CSV straight to a pretty table (the --c2p shorthand):

`mlr --c2p cat {{path/to/data.csv}}`

- Group-by statistics in one pass:

`mlr --icsv --opprint stats1 -a {{mean,sum}} -f {{x}} -g {{grp}} {{path/to/data.csv}}`

- CSV to TSV for csvtk or visidata:

`mlr --c2t cat {{path/to/data.csv}} | csvtk pretty -t`
