# seqkit

> A cross-platform toolkit for FASTA/FASTQ manipulation.
> Reads plain or gzipped files, and stdin when no file is given.
> More information: <https://bioinf.shenwei.me/seqkit/>.

- Summary statistics for one or more files:

`seqkit stats {{path/to/reads.fq.gz}}`

- Keep only sequences of at least a given length:

`seqkit seq -m {{100}} {{path/to/reads.fq}}`

- Convert FASTQ to FASTA:

`seqkit fq2fa {{path/to/reads.fq.gz}} -o {{path/to/reads.fa.gz}}`

- Extract records whose IDs are listed in a file:

`seqkit grep -f {{path/to/ids.txt}} {{path/to/seqs.fa}}`

- Search by sequence rather than name, allowing degenerate bases:

`seqkit grep -s -d -p {{ACGTNN}} {{path/to/seqs.fa}}`

- Subsample a proportion of records reproducibly:

`seqkit sample -p {{0.1}} -s {{11}} {{path/to/reads.fq.gz}}`

- Split into chunks of a fixed number of records:

`seqkit split2 -s {{1000}} {{path/to/reads.fq.gz}}`

- Name and length of every record, as a table:

`seqkit fx2tab -nl {{path/to/seqs.fa}}`
