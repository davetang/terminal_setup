- terminal-setup extras (davetang/terminal-setup):

- Interactive dashboard for an Apache or nginx combined log:

`goaccess {{access.log}} --log-format=COMBINED`

- CSV or JSON instead of HTML; the output extension picks the format:

`goaccess {{access.log}} --log-format=COMBINED -o {{report.csv}}`

- Drop the summary rows so the CSV is a plain table:

`goaccess {{access.log}} --log-format=COMBINED --no-csv-summary -o {{report.csv}}`

- Rotated, gzipped logs through stdin:

`zcat {{access.log.*.gz}} | goaccess --log-format=COMBINED -o {{report.csv}} -`

- Read the report back with this setup's tools:

`csvtk pretty {{report.csv}} | bat`
