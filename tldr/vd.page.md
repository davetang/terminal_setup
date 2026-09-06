# vd

> VisiData: an interactive TUI for tabular data, from CSV and TSV to JSON, SQLite and XLSX.
> More information: <https://www.visidata.org/docs/>.

- Open a file, guessing the format from its extension:

`vd {{path/to/data.csv}}`

- Read from a pipe, naming the format explicitly:

`{{command}} | vd -f {{tsv}}`

- Open every table in a SQLite database:

`vd {{path/to/database.db}}`

- Convert between formats without opening the interface:

`vd {{path/to/data.csv}} -b -o {{path/to/data.tsv}}`

- Keys: q close this sheet · gq quit · ? help · [ and ] sort · / search · Shift-F frequency table · Ctrl-S save:
