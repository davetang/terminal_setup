- terminal-setup extras (davetang/terminal-setup):

- Quit to the directory you browsed to (what the `y` wrapper in yazi's docs does):

`yazi --cwd-file={{/tmp/yazi-cwd}} && cd "$(cat {{/tmp/yazi-cwd}})"`

- Open with one file already selected:

`yazi {{path/to/file}}`

- Keys: hjkl move · Enter open · Space select · y, x, p copy, cut, paste · . toggle hidden · q quit:
