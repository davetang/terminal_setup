- terminal-setup extras (davetang/terminal-setup):

- Query a TSV (the delimiter has to be spelled out):

`duckdb -c "SELECT * FROM read_csv('{{path/to/data.tsv}}', delim='\t', header=true) LIMIT 5"`

- Convert CSV to Parquet with no import step:

`duckdb -c "COPY (SELECT * FROM '{{data.csv}}') TO '{{out.parquet}}'"`

- Count rows in a Parquet file:

`duckdb -c "SELECT count(*) FROM '{{reads.parquet}}'"`

- CSV output, straight into the rest of this setup:

`duckdb -csv -c "SELECT * FROM '{{data.parquet}}'" | vd -f csv`
