- terminal-setup extras (davetang/terminal-setup):

- Mean and sum of columns in a comma-separated file:

`datamash -t, mean {{2}} sum {{3}} < {{path/to/data.csv}}`

- Keep the header line and name the output columns after it:

`datamash -H -t, mean {{2}} < {{path/to/data.csv}}`

- Group by a column (input must be sorted, or let datamash sort it):

`datamash -t, --sort -g {{1}} sum {{2}} < {{path/to/data.csv}}`

- Transpose a table:

`datamash -t, transpose < {{path/to/data.csv}}`
