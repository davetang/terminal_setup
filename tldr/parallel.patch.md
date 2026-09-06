- terminal-setup extras (davetang/terminal-setup):

- Silence the citation notice once; conda-forge's parallel prints it on first run:

`parallel --citation`

- Compress files four at a time:

`parallel -j{{4}} gzip ::: {{*.fastq}}`

- Feed it from fd, which respects .gitignore:

`fd -e {{bam}} | parallel {{samtools index}}`

- Progress bar and an ETA for a long run:

`parallel --bar --eta {{command}} ::: {{arguments}}`
