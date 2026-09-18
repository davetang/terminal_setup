# gls

> GNU coreutils installed g-prefixed by terminal-setup: gls, gcat, gsort, gdate, gwc, gln...
> A newer coreutils than the host's, which cannot shadow it. Same options as the unprefixed tool.
> More information: <https://www.gnu.org/software/coreutils/>.

- List a directory, long and human-readable (every option is the GNU one you already know):

`gls -lh {{path/to/directory}}`

- Everything the package installed, g-prefixed:

`ls ~/miniforge3/bin/g* | head -40`

- Confirm you are getting the new one, not the system's:

`gls --version | head -1 && ls --version | head -1`

- Sort a big file using several cores and a scratch directory:

`gsort --parallel={{4}} -T {{/scratch}} -k{{2,2n}} {{path/to/file}}`

- Clickable paths in a terminal that supports them:

`gls --hyperlink=auto -l`

- Copy sharing blocks on a filesystem that can (btrfs, XFS, ZFS):

`gcp --reflink=auto {{path/to/source}} {{path/to/destination}}`

- Date arithmetic the BSD tools spell differently:

`gdate -d {{'2 weeks ago'}} +{{%Y-%m-%d}}`
