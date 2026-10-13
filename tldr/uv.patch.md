- terminal-setup extras (davetang/terminal-setup):

- Create a virtual environment in `.venv`, which uv's own commands use without activating it:

`uv venv`

- Install packages into it with pip's interface:

`uv pip install {{package1 package2 ...}}`

- Install a Python interpreter, no root needed (`python3.13` lands in `~/.local/bin`):

`uv python install {{3.13}}`

- Run a script with an extra package, for this run only:

`uv run --with {{package}} {{path/to/script.py}}`

- Record a script's dependencies inside the script itself (PEP 723), for `uv run` to read:

`uv add --script {{path/to/script.py}} {{package}}`

- Install a PyPI tool for good, into `~/.local/bin`:

`uv tool install {{package}}`

- Upgrade uv itself after moving its pin in versions.lock (`uv self update` refuses here):

`FORCE=1 make uv`
