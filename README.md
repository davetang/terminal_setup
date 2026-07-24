# terminal setup

A self-contained, **no-root** setup for a modern terminal. Everything installs
under `$HOME` (`~/bin` for release binaries, `~/miniforge3` for the conda tools,
`~/.local/bin` for the pip tools) and nothing outside this directory is needed. Built
the same way as
[`nvim_setup`](https://github.com/davetang/nvim_setup): a `Makefile` that
delegates to small, idempotent shell scripts.

## Quick start

```sh
make deps       # read-only preflight: check prerequisites
make install    # install everything under ~/bin (+ Miniforge for a few tools)
make setup      # wire ~/bin and tool init into your shell rc
exec $SHELL -l  # restart your shell
```

No `make`? Use the identical make-free entry point:

```sh
./run.sh deps
./run.sh install
./run.sh setup
```

Install or reinstall a single tool:

```sh
make bat              # or: ./run.sh bat
FORCE=1 make bat      # overwrite an existing copy
make check            # report what is / isn't installed
```

Usage examples for every tool live in [`cheatsheet.md`](cheatsheet.md).

## Commands

Every target works with either `make <target>` or `./run.sh <target>`:

| Target | Does |
|--------|------|
| `deps` | read-only preflight (checks prerequisites) |
| `install` | `deps` + everything: binaries, conda tools, pip tools, ollama |
| `binaries` / `conda-tools` / `pip-tools` | install just one group |
| `<tool>` | install a single tool (e.g. `make fzf`); prefix `FORCE=1` to reinstall |
| `freeze` | pin every tool's current version → `versions.lock` |
| `setup` | wire `~/bin` + tool init into your shell rc |
| `check` | report what's installed and where |
| `uninstall` | remove the `~/bin` binaries this repo installed |
| `miniforge` | bootstrap Miniforge under `~/miniforge3` |
| `help` | list all targets |

## Prerequisites

Required (all present on a stock Debian/Ubuntu): `curl`, `tar`, `gzip`,
`python3`. `unzip`/`bzip2`/`xz` are **not** required — Python's `zipfile`/`bz2`/
`lzma` modules cover those archive formats so nothing extra needs installing.
Any `python3` will do; `llm` alone wants ≥ 3.10 and falls back to conda-forge
below that.

`make` is optional (use `./run.sh` instead). A C compiler is **not** needed —
every tool is a prebuilt binary or a conda/pip package.

> GitHub's API allows 60 unauthenticated requests/hour, and a full install makes
> ~30 (one per binary tool). If you hit the limit, `export GITHUB_TOKEN=...`
> (any classic token, no scopes needed) to raise it, then rerun.

## What gets installed

| Tool | Replaces / does | Method |
|------|-----------------|--------|
| **bat** | `cat` with syntax highlighting | binary |
| **eza** | `ls` with colours, git, tree | binary |
| **fd** | `find`, saner + faster | binary |
| **rg** (ripgrep) | recursive `grep` | binary |
| **sd** | `sed` for simple substitutions | binary |
| **dust** | `du` as a tree | binary |
| **duf** | `df`, friendlier | binary |
| **procs** | `ps`, structured | binary |
| **btop** | `top`/`htop` TUI monitor | binary |
| **delta** | `git diff` pager | binary |
| **hyperfine** | command-line benchmarking | binary |
| **jq** | JSON query/transform | binary |
| **yq** | YAML query/transform | binary |
| **mlr** (Miller) | awk/cut for CSV/TSV/JSON | binary |
| **csvtk** | CSV/TSV toolkit | binary |
| **seqkit** | FASTA/FASTQ toolkit | binary |
| **fzf** | fuzzy finder | binary |
| **zoxide** | smarter `cd` | binary |
| **atuin** | searchable shell history (`Ctrl-R`) | binary |
| **yazi** (+`ya`) | TUI file manager | binary |
| **broot** | fuzzy tree navigation | binary |
| **starship** | cross-shell prompt | binary |
| **direnv** | per-directory environments | binary |
| **just** | friendlier `make` for tasks | binary |
| **chezmoi** | dotfile manager | binary |
| **xh** | ergonomic HTTP client (curl alt) | binary |
| **tldr** (tealdeer) | example-first man pages | binary |
| **gh** | GitHub CLI | binary |
| **pandoc** | universal document converter | binary |
| **viddy** | a modern `watch` | binary |
| **ollama** | CLI for an Ollama server (**client only**) | binary |
| **tmux** | terminal multiplexer | conda-forge |
| **zsh** | the shell | conda-forge |
| **datamash** | group-by statistics | conda-forge |
| **parallel** (GNU) | run jobs across cores | conda-forge |
| **pv** | pipe progress / throughput | conda-forge |
| **visidata** (`vd`) | interactive TUI for tabular data | pipx / pip / conda |
| **llm** | prompt LLMs from the shell, pipe text into them | pipx / pip / conda |

Binaries download straight from GitHub releases into `~/bin`, pinned to the
versions in `versions.lock` (see [Reproducibility](#reproducibility-version-pinning)).
`ollama` is the odd one out — see [ollama, client only](#ollama-client-only).
`tmux`, `zsh`, `datamash`, `parallel`, and `pv` have no clean static binary
upstream, so they come from conda-forge — if no `conda` is found, `make install`
bootstraps Miniforge under `~/miniforge3` automatically. `visidata` and `llm`
are pure Python (`pipx` → `pip --user` → conda fallback).

## ollama, client only

Yes — you can install just the `ollama` command and skip the model-serving half
entirely. Every subcommand except `ollama serve` is an HTTP client for the API
at `$OLLAMA_HOST`, so the CLI binary on its own is enough to talk to a server
someone else is running:

```sh
export OLLAMA_HOST=http://gpu-box:11434   # default is http://127.0.0.1:11434
ollama list
ollama run qwen3 'summarise this in one line' < notes.txt
```

Upstream doesn't publish a client-only asset — the Linux release is a single
**1.4 GB** `.tar.zst` holding `bin/ollama` (the 39 MB CLI) plus `lib/ollama/*`,
the CUDA/ROCm/CPU inference runners that only `ollama serve` ever loads. But
`bin/ollama` is the *first* member of the tarball, so `scripts/ollama.sh`
streams the release, extracts that one file, and lets the rest of the download
die on a broken pipe: **~12 MB over the wire, ~39 MB on disk**, no runners, no
GPU libraries, no service, nothing listening.

```sh
make ollama            # or: ./run.sh ollama
FORCE=1 make ollama    # upgrade the client in place
```

What you give up: `ollama serve` will start (it's the same binary) but has no
runners to load models with, so hosting models locally needs the full upstream
install from [ollama.com](https://ollama.com/download). Everything else —
`run`, `list`, `ps`, `pull`, `push`, `show`, `cp`, `rm`, `create` — is a plain
API call and works against any reachable server.

The release is zstd-compressed, which `tar` and Python ≤ 3.13 can't read, so the
script finds a decompressor in this order: the `zstd`/`unzstd` CLI → `python3`
(3.14's `compression.zstd`, or the `zstandard`/`pyzstd` modules) → `zstd` from
conda-forge. `make deps` reports which one you have.

## llm

[Simon Willison's `llm`](https://llm.datasette.io/) is the other half of the
LLM story here: `ollama` speaks to one Ollama server, `llm` speaks to whatever
you have — hosted APIs, local servers, or both — with the same syntax, and logs
every prompt and response to SQLite so you can go back and find them.

```sh
make llm                          # or: ./run.sh llm
llm keys set openai               # stored in ~/.config/io.datasette.llm/keys.json
llm 'explain awk in three lines'
git diff | llm -s 'write a commit message for these changes'
llm logs -n 3                     # the last three prompts + responses
```

It's pure Python, so it installs the same way visidata does: `pipx` →
`pip --user` → conda-forge. `llm` needs **Python ≥ 3.10**; on an older
interpreter `make llm` skips pip and takes it from conda-forge, which brings its
own Python. `make deps` tells you which way it'll go.

**Other providers are plugins.** Only OpenAI works out of the box; everything
else is `llm install <plugin>`, which pip-installs into llm's own environment
regardless of how llm itself got there:

```sh
llm install llm-anthropic         # Claude models   (ANTHROPIC_API_KEY)
llm install llm-gemini            # Gemini models   (llm keys set gemini)
llm install llm-ollama            # every model on your Ollama server
llm models                        # what's available now
```

`llm-ollama` reads the same `$OLLAMA_HOST` as the `ollama` client above, so
pointing that one variable at your server gives you both the `ollama` CLI and
`llm -m <model>` against it — no API key, nothing leaving your network:

```sh
export OLLAMA_HOST=http://gpu-box:11434
llm -m qwen3 'summarise this' < notes.md
llm chat -m qwen3                 # interactive; 'exit' quits
```

To install plugins as part of the install itself — handy when rebuilding a
machine — list them in `TS_LLM_PLUGINS`. This works on an existing `llm` too:

```sh
TS_LLM_PLUGINS='llm-ollama llm-anthropic' make llm
```

## How it works

```
Makefile / run.sh              entry points (identical targets; run.sh needs no make)
lib.sh                         shared helpers: download, extract, idempotency, pins, conda
binaries.tsv                   manifest: tool → repo → asset regex → binaries
versions.lock                  pinned version/tag per tool (generated by make freeze)
deps.sh                        read-only preflight
scripts/binary.sh              install one binary tool from binaries.tsv
scripts/freeze.sh              resolve current versions → versions.lock
scripts/miniforge.sh           bootstrap Miniforge (no-root)
scripts/{tmux,zsh,datamash,parallel,pv}.sh   conda-forge installs
scripts/{visidata,llm}.sh      pipx / pip / conda installs
scripts/ollama.sh              stream the ollama CLI out of upstream's bundle
scripts/setup_shell.sh         wire the shell rc
scripts/status.sh              back the check target
scripts/uninstall.sh           remove installed ~/bin binaries
shell/init.sh                  PATH + tool init, sourced by your shell rc
README.md · cheatsheet.md      this guide + per-tool usage examples
```

Binaries are picked by matching a regex against each release asset's URL, so the
asset name is never hard-coded even when a version is pinned. It's built for
**x86_64 Linux**; to target another arch, edit the regexes in `binaries.tsv`.

When a regex matches both a **musl** and a **glibc** build, the musl one wins.
Upstream links its glibc builds against whatever libc the CI runner had — often
newer than an LTS distro's — and the binary then fails at startup with
``version `GLIBC_2.xx' not found``. The musl builds are static and always run.
After each install the binary is checked with `ldd`, so a tool that ships no
static build is flagged straight away rather than at first use.

## Reproducibility (version pinning)

Every tool is pinned in `versions.lock` — a small, git-tracked lockfile:

```
name        channel        version-or-tag
bat         gh             v0.26.1
delta       gh             0.19.2
tmux        conda          3.7b_
visidata    pip            3.4
llm         pip            0.31.1
```

- **GitHub tools** install from `releases/tags/<tag>` (the exact tag), not
  `latest`. **conda/pip tools** install `pkg=version`.
- **Refresh the pins** to current upstream at any time:

  ```sh
  make freeze     # or: ./run.sh freeze  — rewrites versions.lock
  ```

- **Unpin** one tool by deleting its line (it falls back to latest); delete the
  whole file to unpin everything.
- **Commit `versions.lock`** to reproduce the exact same tool set on another
  machine or later in time.

Because a full install (or freeze) makes ~30 GitHub API calls and the
unauthenticated limit is 60/hour, `export GITHUB_TOKEN=...` if you hit it.

**Adding a tool** is one line in `binaries.tsv`:

```
name<TAB>owner/repo<TAB>asset-regex<TAB>[binaries]
```

then add `name` to `BINTOOLS` in the `Makefile` (and `run.sh`).

## Shell integration

`make setup` appends a small guarded block to `~/.bashrc` (and `~/.zshrc` if it
exists) that sources `shell/init.sh`. That file:

- puts `~/bin`, `~/.local/bin`, and `~/miniforge3/bin` on `PATH`;
- initialises `starship`, `zoxide`, `atuin`, `direnv`, and `fzf` for bash/zsh;
- pins `BAT_THEME` so `bat` doesn't probe the terminal for its colours.

**starship and oh-my-zsh themes are mutually exclusive.** starship assigns
`PROMPT`/`RPROMPT` itself, and this block is sourced last, so it would always
win. It is therefore skipped whenever `ZSH_THEME` is set — your theme stays,
and bash (where oh-my-zsh doesn't apply) still gets starship. Override with
`TS_STARSHIP=1` to always use starship, or `TS_STARSHIP=0` to never use it;
set it above the `terminal-setup` block in your rc.

`BAT_THEME` is pinned to `Monokai Extended` because `bat`'s default
(`--theme=auto`) asks the terminal for its background colour, and the reply is
delivered as *input* — under screen/tmux it can arrive after `bat` exits, where
a vi-mode line editor reads the leading `ESC` as a mode switch and the rest as
typed keys. Any name from `bat --list-themes` avoids the probe; export your own
`BAT_THEME` and this file leaves it alone.

Optional aliases (`cat`→`bat`, `ls`→`eza`, …) are included but **commented out**
in `shell/init.sh` — uncomment the ones you want. Because `zsh` is installed
later, re-run `make setup` after it exists to wire your `~/.zshrc`.

## After installing

`make setup` handles `PATH` and auto-initialises starship/zoxide/atuin/direnv/fzf.
Four tools need one manual step:

- **delta** does nothing until git is told to use it — add to `~/.gitconfig`:

  ```ini
  [core]
      pager = delta
  [interactive]
      diffFilter = delta --color-only
  [delta]
      navigate = true
      dark = true
  ```

  `dark = true` (use `light` on a light terminal) is the delta counterpart of
  the pinned `BAT_THEME` above, and fixes the same bug. Left unset, delta
  auto-detects light/dark by *querying* the terminal — an `OSC 11` + `DA1`
  escape sequence, via the `terminal-colorsaurus` library — and the reply is
  delivered as **input**. Under screen/tmux that reply can arrive after delta
  has handed off to `less`, which then reads the stray `rgb:…` bytes as
  keypresses (delta's docs note the query "causes race conditions with pagers
  such as less"). Telling delta the mode up front skips the probe entirely;
  pinning `syntax-theme` alone does **not** — only `dark`/`light` short-circuits
  the detection.

- **zsh** (optional) — make it your login shell with
  `chsh -s "$(command -v zsh)"` (the shell must be listed in `/etc/shells`;
  otherwise just run `exec zsh`, or add the path to `/etc/shells` first).

- **ollama** needs a server to talk to — uncomment and edit the `OLLAMA_HOST`
  line in `shell/init.sh` (it defaults to `http://127.0.0.1:11434`).

- **llm** needs a model to talk to — either a key (`llm keys set openai`) or a
  plugin for something local (`llm install llm-ollama`, which reuses the same
  `OLLAMA_HOST`). See [llm](#llm).

Everything else works the moment it's on `PATH`. Run `make check` to confirm.

## Uninstall

```sh
make uninstall   # removes the ~/bin binaries this repo installed
```

Conda tools, `visidata`, `llm`, Miniforge, and your rc edits are left untouched
(`pipx uninstall llm`, remove `~/miniforge3`, and drop the
`# >>> terminal-setup >>>` block by hand if you want).

## Intentionally omitted

The talk lists many competing alternatives; this setup keeps one per category.
Deliberately **not** installed:

- **GUI terminal emulators** (Warp, Ghostty, kitty, WezTerm, Alacritty, foot,
  iTerm2) — these are graphical apps, not CLI tools, and iTerm2 is macOS-only.
- **Category alternatives** — fish/nushell (vs zsh), zellij (vs tmux),
  bottom/`btm` (vs btop), ranger/nnn/lf (vs yazi), w3m/lynx/browsh (text
  browsers), mutt/aerc/himalaya (email), pixi/mamba (vs the Miniforge base).

To add any of them, drop a row in `binaries.tsv` (if it ships a Linux binary) or
`conda install -c conda-forge <pkg>`.
