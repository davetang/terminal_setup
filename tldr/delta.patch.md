- terminal-setup extras (davetang/terminal-setup):

- Wire delta into git (the manual step this setup's README calls out):

`git config --global core.pager delta`

- Colour-only diffs for `git add -p` and friends:

`git config --global interactive.diffFilter '{{delta --color-only}}'`

- Declare the background so delta skips its terminal colour probe:

`git config --global delta.dark {{true}}`

- Side-by-side history for one file:

`git log -p {{path/to/file}} | delta --side-by-side`
