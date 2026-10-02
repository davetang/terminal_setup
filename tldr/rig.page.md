# rig

> The R Installation Manager: install several R versions side by side and switch between them.
> Set up in user mode, so R goes under ~/.local/share/rig with no sudo, and R and Rscript are linked into ~/bin.
> More information: <https://github.com/r-lib/rig>.

- Install the current R release (about 280 MB, with pak):

`rig add release`

- Install another version: the latest of a minor branch, the previous minor, or R-devel:

`rig add {{4.5|oldrel|devel}}`

- List the installed versions (the default is starred):

`rig list`

- Switch R and Rscript to another installed version (its exact name, as rig list shows it):

`rig default {{4.5.3}}`

- Run one version without switching the default:

`R-{{4.5.3}}`

- Remove a version:

`rig rm {{4.5.3}}`

- Show the mode and every directory rig uses (expect "Mode user"):

`rig system dirs`

- Install BiocManager into a new R (rig installs only pak):

`Rscript -e 'install.packages("BiocManager")'`

- Install Bioconductor packages as binaries rather than from source:

`Rscript -e 'options(BioC_mirror = "https://packagemanager.posit.co/bioconductor/__linux__/manylinux_2_28/latest"); BiocManager::install("{{DESeq2}}")'`
