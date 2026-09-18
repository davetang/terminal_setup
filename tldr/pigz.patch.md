- terminal-setup extras (davetang/terminal-setup):

- Compress with every core; -k keeps the original:

`pigz -k {{path/to/file}}`

- Choose the trade-off: -1 fastest, -6 default, -9 smallest, --fast/--best:

`pigz -9 {{path/to/file}}`

- Cap the cores, to leave a shared box usable:

`pigz -p {{4}} {{path/to/file}}`

- Tar a directory through pigz (the -I form passes the whole command):

`tar -I {{pigz}} -cf {{archive.tar.gz}} {{path/to/directory}}`

- Untar through unpigz — decompression is the half that gzip can't parallelise much, but this still helps:

`tar -I {{unpigz}} -xf {{archive.tar.gz}}`

- Output is ordinary gzip, so anything can read it back:

`pigz -dc {{file.gz}} | head`

- Check an archive without writing anything:

`pigz -t {{file.gz}}`
