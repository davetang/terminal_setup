- terminal-setup extras (davetang/terminal-setup):

- Where custom pages and patches live on this machine:

`tldr --show-paths`

- Add your own examples to an existing page (appended to the upstream one):

`vi {{~/.local/share/tealdeer/pages/}}{{command}}.patch.md`

- Replace or create a page outright (a .page.md hides any .patch.md of the same name):

`vi {{~/.local/share/tealdeer/pages/}}{{command}}.page.md`

- Install this repo's pages and patches:

`cp {{path/to/terminal-setup}}/tldr/*.page.md {{path/to/terminal-setup}}/tldr/*.patch.md {{~/.local/share/tealdeer/pages/}}`

- Refresh the upstream cache; a patch needs a cached page to attach to:

`tldr --update`
