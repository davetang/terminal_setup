# csvtk

> A cross-platform, efficient and practical CSV/TSV toolkit.
> Every subcommand takes -t for tab-separated input and -H for headerless input.
> More information: <https://bioinf.shenwei.me/csvtk/>.

- List the column names of a file:

`csvtk headers -t {{path/to/data.tsv}}`

- Print an aligned, readable table:

`csvtk pretty {{path/to/data.csv}}`

- Pretty-print a headerless TSV (what most piped output looks like):

`csvtk pretty -t -H {{path/to/data.tsv}}`

- Select columns by name, then sort by one numerically and in reverse:

`csvtk cut -f {{name,score}} {{path/to/data.csv}} | csvtk sort -k {{score:nr}}`

- Keep rows matching an expression:

`csvtk filter2 -f '{{$score > 90}}' {{path/to/data.csv}}`

- Count how often each value appears in a column:

`csvtk freq -f {{gene}} {{path/to/data.csv}}`

- Join two files on a shared column:

`csvtk join -f {{id}} {{path/to/left.csv}} {{path/to/right.csv}}`

- Convert CSV to TSV:

`csvtk csv2tab {{path/to/data.csv}}`
