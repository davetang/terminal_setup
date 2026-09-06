- terminal-setup extras (davetang/terminal-setup):

- Progress and throughput through a decompression pipeline:

`pv {{big.gz}} | gunzip | wc -l`

- Watch a transfer over ssh:

`tar cf - {{path/to/directory}} | pv | ssh {{host}} 'cat > {{dir.tar}}'`

- Rate-limit a copy so it does not saturate a shared filesystem:

`pv -L {{10m}} {{path/to/source}} > {{path/to/destination}}`
