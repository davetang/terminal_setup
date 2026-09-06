- terminal-setup extras (davetang/terminal-setup):

- Check the filesystems this setup installs into:

`duf {{~/bin}} {{~/miniforge3}} {{~/.local}}`

- Machine-readable output, for jq:

`duf --json | jq '.[0]'`

- Hide the noise of container and pseudo filesystems:

`duf --hide-fs {{tmpfs,squashfs,overlay}}`
