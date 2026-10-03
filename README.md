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

Five things sit outside `make install`, because they are large or because they
write outside `~/bin` rather than adding a binary:

```sh
make sdks             # go + openjdk (or: make go / make openjdk)
make rig              # rig, the R version manager; then 'rig add release' for R
make ohmyzsh          # oh-my-zsh into ~/.oh-my-zsh, wired into ~/.zshrc
make tldr-pages       # this repo's tldr pages into tealdeer's custom pages dir
```

Usage examples for every tool live in [`cheatsheet.md`](cheatsheet.md), and in
[`tldr/`](tldr/) as tealdeer custom pages for `tldr <tool>`, which
`make tldr-pages` installs (see [`tldr/README.md`](tldr/README.md)).

## Commands

Every target works with either `make <target>` or `./run.sh <target>`:

| Target | Does |
|--------|------|
| `deps` | read-only preflight (checks prerequisites) |
| `install` | `deps` + everything: binaries, conda tools, pip tools, ollama, sendcb, notify, showimg, screen |
| `binaries` / `conda-tools` / `pip-tools` | install just one group |
| `sdks` | `go` + `openjdk` — language toolchains, **not** in `install` |
| `rig` | rig, the R version manager, in user mode (no R until `rig add`) — **not** in `install` |
| `ohmyzsh` | oh-my-zsh into `~/.oh-my-zsh`, wired into `~/.zshrc` — **not** in `install` |
| `tldr-pages` | copy [`tldr/`](tldr/) into tealdeer's custom pages dir — **not** in `install` |
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

`git` is needed only by `make ohmyzsh`, which is a git clone; nothing in
`make install` uses it.

`make` is optional (use `./run.sh` instead), and a C compiler is not needed,
with one exception: **screen** is built from source, so it needs both `make` and
a C compiler (`gcc` or `cc`). Every other tool is a prebuilt binary or a
conda/pip package, and screen is the last install step, so on a host without a
compiler everything else is already installed when that step fails. `make deps`
reports whether you have them.

> GitHub's API allows 60 unauthenticated requests/hour, and a full install makes
> ~40 (one per binary tool, except `tea`, which asks gitea.com). If you hit the
> limit, `export GITHUB_TOKEN=...` (any classic token, no scopes needed) to
> raise it, then rerun. If `gh` is already set up on this host,
> `export GITHUB_TOKEN=$(gh auth token)` reuses that login.

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
| **duckdb** | in-process SQL over CSV/Parquet/JSON | binary |
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
| **lazygit** | git TUI (stage/commit/branch/rebase) | binary |
| **shellcheck** | lint shell scripts (quoting, globbing, `[ ]` traps) | binary |
| **shfmt** | format shell scripts (`gofmt` for sh/bash) | binary |
| **ruff** | Python linter + formatter, very fast | binary |
| **trippy** (`trip`) | traceroute + ping, in a TUI | binary |
| **tt** | typing speed test / practice drills | binary |
| **ttyper** | typing test with per-key accuracy stats | binary |
| **gh** | GitHub CLI: issues, PRs, releases, Actions | binary |
| **tea** | Gitea CLI: issues, PRs, releases | binary |
| **pandoc** | universal document converter | binary |
| **viddy** | a modern `watch` | binary |
| **ollama** | CLI for an Ollama server (**client only**) | binary |
| **sendcb** | copy to your *own* clipboard from any shell, over SSH too (OSC 52) | script, pinned commit |
| **notify** | desktop notification on your *own* machine from any shell, over SSH too; a hook for long commands | script, pinned commit |
| **showimg** | show a plot or image in your *own* terminal from any shell, over SSH too | script, pinned commit |
| **tmux** | terminal multiplexer | conda-forge |
| **zsh** | the shell | conda-forge |
| **datamash** | group-by statistics | conda-forge |
| **parallel** (GNU) | run jobs across cores | conda-forge |
| **pv** | pipe progress / throughput | conda-forge |
| **goaccess** | real-time web log analyzer (TUI/HTML) | conda-forge |
| **xclip** | pipe to/from the X11 clipboard | conda-forge |
| **ncdu** | interactive disk usage browser (walk it, delete in place) | conda-forge |
| **tree** | the original recursive directory listing | conda-forge |
| **pigz** (+`unpigz`) | `gzip` across every core | conda-forge |
| **coreutils** | GNU coreutils, g-prefixed: `gls`, `gsort`, `gdate` … | conda-forge |
| **visidata** (`vd`) | interactive TUI for tabular data | pipx / pip / conda |
| **llm** | prompt LLMs from the shell, pipe text into them | pipx / pip / conda |
| **screen** (GNU) | terminal multiplexer; 5.x, for 24-bit colour | source (gcc + make) |
| **go** | the Go toolchain | go.dev tarball — `make sdks` |
| **openjdk** | Eclipse Temurin JDK (`java`, `javac`, `jar`, `jshell`) | Adoptium — `make sdks` |
| **rig** | R installation manager: several R versions side by side, no root | binary + wrapper — `make rig` |
| **oh-my-zsh** | zsh configuration framework | git clone — `make ohmyzsh` |

Binaries download straight from their upstream release page into `~/bin` — GitHub
for all but `tea`, which Gitea develops on gitea.com (see
[Tools not on GitHub](#tools-not-on-github)) — pinned to the versions in
`versions.lock` (see [Reproducibility](#reproducibility-version-pinning)).
`ollama` is the odd one out — see [ollama, client only](#ollama-client-only).
`sendcb`, `notify` and `showimg` are bash scripts with no releases, so they are
fetched at a pinned commit — see [sendcb](#sendcb), [notify](#notify) and
[showimg](#showimg).
`tmux`, `zsh`, `datamash`, `parallel`, `pv`, `goaccess`, `xclip`, `ncdu`,
`tree`, `pigz` and `coreutils` have no static binary this setup can fetch (see
[Tools not on GitHub](#tools-not-on-github) for `ncdu`), so they come from
conda-forge — if no `conda` is found, `make install`
bootstraps Miniforge under `~/miniforge3` automatically. `visidata` and `llm`
are pure Python (`pipx` → `pip --user` → conda fallback). `screen` is the one
source build — see [GNU Screen 5, built from source](#gnu-screen-5-built-from-source).

The last four rows are opt-in and deliberately outside `make install` — see
[Language toolchains](#language-toolchains-go-openjdk),
[R, through rig](#r-through-rig) and [oh-my-zsh](#oh-my-zsh). `coreutils` is worth a word too: it installs
conda-forge's **gnu-coreutils**, which is the same source built with
`--program-prefix=g`. The unprefixed package would land in `~/miniforge3/bin`,
which `shell/init.sh` puts ahead of `/usr/bin`, so every `ls`, `cp`, `mv` and
`rm` in every shell — including the ones inside other people's scripts — would
quietly become conda's build. `gls`, `gsort` and `gdate` cannot do that.

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

## sendcb

[`sendcb`](https://github.com/davetang/sendcb) copies to the clipboard of the
machine you're **sitting at**, from a shell on any machine you've SSHed into,
tmux and GNU screen included:

```sh
git rev-parse HEAD | sendcb   # on the remote machine
                              # then Cmd-V / Ctrl-V on your own
```

It sends the text to your terminal as an **OSC 52** escape sequence, which
travels back over the SSH connection you already have: no X11 forwarding, no
extra ports, nothing installed on your own machine. At a local desktop it uses
`pbcopy`, `wl-copy`, `xclip` or `xsel` instead. That fills the gap `xclip`
leaves: `xclip` copies to the clipboard of the machine it *runs on*, and over
plain SSH that machine has none.

```sh
make sendcb            # or: ./run.sh sendcb (also run by make install)
FORCE=1 make sendcb    # reinstall at the pinned commit
```

**Pinned to a commit.** sendcb publishes no releases, so `binaries.tsv` has no
asset to match and there is no tag to pin. `versions.lock` holds a commit SHA
instead, under a `git` channel of its own, and `scripts/sendcb.sh` fetches the
script from that commit on raw.githubusercontent.com, which doesn't count
against the GitHub API limit. `make freeze` moves the pin to the newest commit;
with no pin, the install asks the API for it.

**Upstream's `setup.sh` is not run.** It copies `sendcb` to `~/bin`, which this
does too; adds `~/bin` to `PATH`, which `make setup` already does; and edits
`~/.tmux.conf`, which is left to you. sendcb needs one line there: see
[After installing](#after-installing).

## notify

[`notify`](https://github.com/davetang/notify) is sendcb's sibling for
notifications: it pops one up on the machine you're **sitting at**, from a
shell on any machine you've SSHed into, tmux and GNU screen included:

```sh
make -j8; notify -e $? build   # on the remote machine
                               # "Done: build", or "Failed (exit 2): build"
```

It sends an **OSC 9**, **OSC 777** or kitty's **OSC 99** escape sequence to your
terminal, which shows it as a desktop notification. Like sendcb's OSC 52, it
travels back over the SSH connection you already have. Inside tmux it writes to
the attached terminals directly, so tmux needs no configuration.

It comes with a **shell hook**, `notify-hook.sh`: once it's loaded, any command
that runs for a minute or more notifies you when it finishes, with its exit
status, run time and command line.

```sh
make notify            # or: ./run.sh notify (also run by make install)
FORCE=1 make notify    # reinstall both files at the pinned commit
```

**Pinned to a commit**, the same way as [sendcb](#sendcb): no releases, so
`versions.lock` holds a commit SHA under `git`, and `scripts/notify.sh` fetches
`notify` and `notify-hook.sh` from that commit on raw.githubusercontent.com.

**Upstream's `setup.sh` is not run.** It copies both files to `~/bin`, which
this does too; adds `~/bin` to `PATH`, which `make setup` already does; and
appends a line sourcing the hook to `~/.bashrc` or `~/.zshrc`, which
`shell/init.sh` does instead. The hook loads after starship, atuin and direnv,
because in bash it has to be first in `PROMPT_COMMAND` to see each command's
exit status, and they put themselves at the front too. Anything later in
`~/.bashrc` that does the same makes every notification say "Done", even for
failures: put it above the `terminal-setup` block.

| Variable | Default | Meaning |
| --- | --- | --- |
| `TS_NOTIFY_HOOK` | `1` | `0` leaves the hook out. Set it above the `terminal-setup` block |
| `NOTIFY_MIN_SECONDS` | `60` | Notify for commands that ran at least this long |
| `NOTIFY_IGNORE` | editors, pagers, REPLs, `ssh`, `tmux`, … | Commands that never notify; add with `NOTIFY_IGNORE+=':radian'` |
| `NOTIFY_METHOD` | `auto` | `osc9`, `osc777`, `osc99` or `bell`, if `auto` picks wrong. `export` it |

Set the last three below the `terminal-setup` block. The hook needs bash 4.4 or
later (RHEL 7's 4.2 doesn't qualify) and skips itself in older bash; `notify`
itself still works there. Your own terminal has to show the notifications: see
[After installing](#after-installing).

## showimg

[`showimg`](https://github.com/davetang/showimg) is the third of the set: it
shows an image in the terminal you're **sitting at**, from a shell on any
machine you've SSHed into, tmux and GNU screen included:

```sh
showimg plot.png   # on the remote machine
                   # the plot appears in your terminal, below the command
```

It sends the image as an escape sequence, in whichever of the **kitty graphics
protocol**, **iTerm2 inline images** or **sixel** your terminal understands.
Like sendcb's OSC 52, it travels over the SSH connection you already have: no
`scp`, no X11 forwarding, nothing installed on your own machine. It asks the
terminal which one it speaks; where it can't ask, inside GNU screen or tmux
older than 3.3, it tries kitty's, which kitty, Ghostty and Warp use.

PNG needs nothing but coreutils and awk. PDF, SVG, JPEG and other formats need
a converter where `showimg` runs (`pdftoppm`, `rsvg-convert` or ImageMagick),
and `showimg -p text`, for terminals that can't show images, needs `chafa`.
This repo installs none of them, and `showimg` names the one it's missing.

```sh
make showimg            # or: ./run.sh showimg (also run by make install)
FORCE=1 make showimg    # reinstall at the pinned commit
```

**Pinned to a commit**, the same way as [sendcb](#sendcb): no releases, so
`versions.lock` holds a commit SHA under `git`, and `scripts/showimg.sh`
fetches the script from that commit on raw.githubusercontent.com.

**Upstream's `setup.sh` is not run.** It copies `showimg` to `~/bin`, which
this does too; adds `~/bin` to `PATH`, which `make setup` already does; and
edits `~/.tmux.conf`, which is left to you. showimg needs one line there: see
[After installing](#after-installing). The rest of `setup.sh` only reports on
screen, mosh and the converters it finds.

## GNU Screen 5, built from source

`screen` is here for one feature: **24-bit colour**. The `truecolor on` command
arrived in Screen 5.0; the 4.x that distros ship, and 4.8.0, the newest on
conda-forge, round 24-bit colours down to the 256-colour palette, so Neovim with
`termguicolors` looks wrong inside them. GNU publishes Screen only as source
tarballs, so `scripts/screen.sh` compiles it, which makes it the one tool here
that needs a C compiler and `make`.

```sh
make screen                          # or: ./run.sh screen (also run by make install)
FORCE=1 make screen                  # rebuild
echo 'truecolor on' >> ~/.screenrc   # then start a new session
```

`~/.screenrc` is read when a session starts, so reattaching to an old session
won't pick up `truecolor on`; start a fresh one.

The build fetches `screen-<version>.tar.gz` from ftp.gnu.org (pinned in
`versions.lock` under the `gnu` channel), installs it into
`~/bin/screen-<version>/`, and points `~/bin/screen` at it. It gets a directory
of its own because Screen compiles in the path to its encoding tables. A
`screen` already on `PATH` only counts as installed if it is 5.0 or newer:
shadowing the distro's 4.x is the point.

**Why it links against Miniforge.** Screen's `configure` has to *link* a termcap
library (for `tgetent`) and `libcrypt`. No curses headers are involved, but
`-ltinfo` only finds a file named `libtinfo.so`, and hosts without root rarely
have one. The system carries the runtime `libtinfo.so.6`; the unversioned name
comes with the `-dev` package. Without it, configure stops at
`unable to find tgetent() function`. So the script links against `ncurses` and
`libxcrypt` in the Miniforge base env, installing them there if they are
missing, and bakes in an rpath to its `lib/` so the binary finds them at run
time. It locates that env through `conda` itself, not `$CONDA_PREFIX`, which is
empty whenever the base env isn't active in the shell running the build.

Two consequences:

- **Keep Miniforge.** This `screen` loads its libraries from `~/miniforge3/lib`.
- **A conda-forge `screen` would shadow it.** `shell/init.sh` puts
  `~/miniforge3/bin` ahead of `~/bin`, so a `screen` 4.8.0 installed there wins.
  The build warns if it finds one; `conda remove screen` clears it.

## Language toolchains (go, openjdk)

Opt-in, and left out of `make install` on purpose: 67 MB and 134 MB to download
respectively, considerably more once unpacked, and most people who want a
terminal do not want a JDK with it.

```sh
make sdks          # both
make go            # or one at a time
make openjdk
```

Neither is a single binary, so neither is a `binaries.tsv` row. Each unpacks
into its own prefix — `~/bin/go-<version>/`, `~/bin/jdk-<release>/` — and only
the commands you actually type are symlinked into `~/bin`: `go` and `gofmt`,
`java`, `javac`, `jar` and `jshell`. The rest of the JDK stays in
`$JAVA_HOME/bin`. Both resolve their own symlink to find their home, so nothing
breaks by being linked this way, and `GOROOT` never needs setting. `shell/init.sh`
does set `JAVA_HOME`, because Maven, Gradle and sbt read it rather than asking
`java` where it lives.

**Where each comes from, and why.** Go's git tags are not its downloads, so
there is no release API to query; `go.dev/dl/?mode=json` is the same list the
download page renders, and it carries a SHA-256 for every file, which the
install verifies. For Java, `jdk.java.net` serves only the current release,
Oracle's own builds carry licence conditions, and conda-forge's `openjdk` would
put a JDK in the base environment — so it is Eclipse Temurin, through the
Adoptium API, checksum and all.

**Which Java.** `versions.lock` pins **21**, so `make openjdk` installs the
newest Temurin 21. The precedence is `JDK_VERSION` → the lockfile → the most
recent LTS Adoptium lists, so `JDK_VERSION=17 make openjdk` overrides for one
run without editing anything.

21 rather than the newest LTS because of what actually consumes it here.
Nextflow wants "Java 17 (or later, up to 26)", so 25 would do — but GATK and
Picard officially support **Java 17 only**, and JDK 24 permanently disabled the
Security Manager ([JEP 486](https://openjdk.org/jeps/486)), which is where
older JVM-based bioinformatics tooling starts to fall over. 21 clears
Nextflow's bar, stays well short of that cliff, and has a longer runway than
17. Drop to 17 if you run GATK or Picard on the host rather than in a
container.

Note that the lockfile pins that *feature release* and not the exact build,
unlike every other row in the file: Temurin ships security patches on a
quarterly cycle, and pinning past them would leave you sitting on a JDK with
known CVEs. A reproducible Java 21 is the useful promise; a frozen
`21.0.12.1+1` is a liability. For the same reason `make freeze` **keeps**
whatever feature release is already pinned instead of moving you to the newest
LTS — that row is a choice, not a version to look up.

One thing worth knowing about Go: `go install` writes to `$GOPATH/bin` — `~/go/bin`
by default — which is **not** the `~/bin` this repo owns. `shell/init.sh` appends
it to PATH rather than prepending, so a tool you built yourself never silently
shadows the curated set.

## R, through rig

[rig](https://github.com/r-lib/rig) is Posit's R installation manager: it
installs several R versions side by side and switches between them. Opt-in, and
in two steps, because the second is about 280 MB and a choice of its own:

```sh
make rig             # or: ./run.sh rig — rig itself, configured; no R yet
rig add release      # the current R; R and Rscript appear in ~/bin
rig add 4.5          # the latest 4.5.x, alongside it
rig default 4.5.3    # switch R and Rscript to it (the exact name 'rig list' shows)
```

**User mode, so no sudo.** rig defaults to admin mode, which installs into
`/opt/R` and links into `/usr/local/bin`. `make rig` switches it to user mode
(new in rig 0.10.0) and sets its `binary-dir` to `~/bin`, so:

| What | Where |
|------|-------|
| R versions | `~/.local/share/rig/r/<version>/` |
| `R`, `Rscript` (the default version), `R-<version>`, `R-release` | symlinks in `~/bin` |
| packages | `~/R/x86_64-pc-linux-gnu-library/<minor>/` (R's usual user library) |
| rig's settings | `~/.local/share/rig/config.json` |

`rig system dirs` prints all of it; `Mode user` and `Binary dir ~/bin` are the
two lines to check. `make check` lists `rig` and `R` among the extras.

**Why `~/bin/rig` is a script.** In user mode, every rig command that makes
links (`add`, `rm`, `default`, aliases) appends `. "$HOME/.local/bin/rigenv"` to
whichever of `~/.profile`, `~/.bash_profile`, `~/.bashrc`, `~/.zprofile` and
`~/.zshrc` exist, writes that `rigenv` file, and, if `~/.config/fish` exists,
adds a snippet to fish's `conf.d`. It does this unless `~/.local/bin` is on
`PATH` ahead of `/usr/local/bin`. rig's docs say setting `binary-dir` stops it,
but the check (`check_local_bin_path` in rig's `src/utils.rs`) never looks at
`binary-dir`. So the real binary lives in `~/bin/rig-<version>/`, and
`~/bin/rig` is a wrapper that puts `~/.local/bin` first on `PATH` for rig's own
process only. That passes rig's check, your shell's `PATH` stays as it was, and
no rc file is touched. Upstream's `install.sh` isn't used for the same reason: it edits your
profiles too.

**It needs glibc 2.34 or newer for R.** User mode installs Posit's portable R
builds (`manylinux_2_34`); `rig` itself is static and runs anywhere. On an older
host `make rig` still installs rig, but warns, and `rig add` refuses. Run R from
a container there instead (Apptainer with a `rocker/r-ver` image).

**Packages come as binaries, so no compiler.** rig points R at Posit Package
Manager's portable Linux binaries, so `install.packages()` unpacks CRAN builds,
system libraries and all (sf brings its own GEOS, GDAL and PROJ). Bioconductor
is the exception: rig's default Bioconductor repositories are source-only. Add
this to `~/.Rprofile` and `BiocManager::install()` gets binaries too:

```r
options(BioC_mirror = "https://packagemanager.posit.co/bioconductor/__linux__/manylinux_2_28/latest")
```

rig installs pak into each new R, but not BiocManager, so the first time round
it's `install.packages("BiocManager")`.

Two things still want build tools. `install.packages(..., Ncpus = 4)` runs its
installs through `make -j`, so it fails with `make: not found` on a host with
no `make`. And a package that only comes as source needs `gcc`, `g++` and
`gfortran`.

A few other things to know:

- **Upgrading rig**: `versions.lock` pins it (channel `gh`) like any other
  release, so move the pin (edit the `rig` line, or `make freeze`), then
  `FORCE=1 make rig`. `rig self update` refuses, because it only replaces
  copies that rig's own install script put there. Your R versions are rig's to
  manage and are not pinned here.
- **Downloads** go to `/tmp/rig-<uid>`. On a shared host with a small `/tmp`,
  `rig config set download-dir=$HOME/.cache/rig/downloads`.
- **A rig you already have** doesn't stop `make rig`: only its own wrapper in
  `~/bin` counts as installed. `~/bin/rig` then shadows a system rig such as
  `/usr/local/bin/rig`, and Debian's unrelated `/usr/games/rig` (a random name
  generator). User mode is a per-user setting, so a system rig you run by its
  full path uses it too. A `~/.local/bin/rig` from upstream's `install.sh` would
  still win, because `shell/init.sh` puts `~/.local/bin` first; `make rig`
  warns if it finds one.
- **Uninstalling** removes rig and leaves R in place, still working. `rig rm
  <version>` removes one version while rig is still installed.

## oh-my-zsh

```sh
make zsh           # if you don't have one already
make ohmyzsh
exec zsh
```

A git clone into `~/.oh-my-zsh` plus a handful of lines in `~/.zshrc`. Upstream's
`install.sh` does the clone, run unattended with the two things it would
otherwise do to your account switched off: no `chsh` (changing your login shell
is not this repo's business, and a conda `zsh` is not in `/etc/shells` anyway)
and no replacing an existing `~/.zshrc`.

That second flag has a catch this repo works around. When `~/.zshrc` already
exists, `KEEP_ZSHRC=yes` makes the installer keep it **and skip wiring oh-my-zsh
into it entirely** — the clone would sit there doing nothing. So `scripts/ohmyzsh.sh`
adds the block itself, guarded the same way `make setup`'s block is, and inserts
it *above* that block:

```sh
# >>> oh-my-zsh >>>
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
# <<< oh-my-zsh <<<

# >>> terminal-setup >>>
...
```

The order matters. `shell/init.sh` reads `ZSH_THEME` to decide whether to start
starship — the two both own the prompt and cannot share it — and sourcing
`oh-my-zsh.sh` afterwards would reset the prompt no matter what that check
decided. Set `TS_STARSHIP=1` to force starship anyway, or `0` to never use it.

`FORCE=1 make ohmyzsh` reinstalls; the old `~/.oh-my-zsh` is **moved aside**
rather than deleted, because custom themes and plugins live in it.

## How it works

```
Makefile / run.sh              entry points (identical targets; run.sh needs no make)
lib.sh                         shared helpers: download, extract, idempotency, pins, conda
binaries.tsv                   manifest: tool → forge repo → asset regex → binaries
versions.lock                  pinned version/tag per tool (generated by make freeze)
deps.sh                        read-only preflight
scripts/binary.sh              install one binary tool from binaries.tsv
scripts/freeze.sh              resolve current versions → versions.lock
scripts/miniforge.sh           bootstrap Miniforge (no-root)
scripts/{tmux,zsh,…,tree,pigz,coreutils}.sh   conda-forge installs (one per CONDATOOLS entry)
scripts/{visidata,llm}.sh      pipx / pip / conda installs
scripts/ollama.sh              stream the ollama CLI out of upstream's bundle
scripts/sendcb.sh              fetch the sendcb script at its pinned commit
scripts/notify.sh              fetch notify and its shell hook at their pinned commit
scripts/showimg.sh             fetch the showimg script at its pinned commit
scripts/screen.sh              build GNU Screen 5 from source, linked against Miniforge
scripts/{go,openjdk}.sh        vendor tarballs → ~/bin/<name>-<version>/ (make sdks)
scripts/rig.sh                 rig in user mode, behind a wrapper that keeps it out of your rc files
scripts/ohmyzsh.sh             clone oh-my-zsh and wire it into ~/.zshrc
scripts/tldr_pages.sh          copy tldr/ into tealdeer's custom pages dir
scripts/setup_shell.sh         wire the shell rc
scripts/status.sh              back the check target
scripts/uninstall.sh           remove installed ~/bin binaries
shell/init.sh                  PATH + tool init, sourced by your shell rc
README.md · cheatsheet.md      this guide + per-tool usage examples
tldr/                          the same examples as tealdeer custom pages
```

Binaries are picked by matching a regex against each release asset's URL, so the
asset name is never hard-coded even when a version is pinned. It's built for
**x86_64 Linux**; to target another arch, edit the regexes in `binaries.tsv`.

When a regex matches both a **musl** and a **glibc** build, the musl one wins.
Upstream links its glibc builds against whatever libc the CI runner had — often
newer than an LTS distro's — and the binary then fails at startup with
``version `GLIBC_2.xx' not found``. The musl builds are static and always run.
After each install the binary is checked with `ldd`, so a tool that ships no
static build is flagged straight away rather than at first use. That check
resolves the symlink first: a binary whose RPATH is `$ORIGIN`-relative (the JDK
launcher finding its `libjli.so`) would otherwise have `$ORIGIN` expanded to
`~/bin` by `ldd` and be reported broken while running perfectly.

### Tools not on GitHub

Not every tool lives on GitHub. `tea`, the Gitea CLI, is developed on
**gitea.com** — the GitHub repo `go-gitea/tea` is an archived mirror that
publishes no releases at all, so querying it finds nothing.

A Gitea instance serves the same release JSON GitHub does (`tag_name`,
`browser_download_url`) under `/api/v1/repos/...`, so the manifest just takes a
host in front of the repo and the rest of the machinery — asset regex, pinning,
`make freeze`, the `ldd` check — is unchanged:

```
tea<TAB>gitea.com/gitea/tea<TAB>tea-[0-9.]+-linux-amd64$
```

Two slashes means GitHub, three means that host's Gitea API. The same row shape
works for any Gitea or Forgejo host, codeberg.org included. Only GitHub gets the
`GITHUB_TOKEN` header, and only GitHub imposes the 60/hour limit.

`ncdu` is the case that host prefix can't rescue. Its source is on a Gitea
instance too (**code.blicky.net**), but that instance publishes **no releases**:
the API answers `[]`, and the static `linux-x86_64` tarball is posted on the
author's own site (`dev.yorhel.nl`), which serves plain files with no release
API to query. A `binaries.tsv` row would have nothing to match, so `ncdu` comes
from conda-forge — the same escape hatch as `tmux` and `goaccess`.

## Reproducibility (version pinning)

Every tool is pinned in `versions.lock` — a small, git-tracked lockfile:

```
name        channel        version-or-tag
bat         gh             v0.26.1
delta       gh             0.19.2
sendcb      git            47de976ade1bca10a5a1fd0d4bf1104c68b0bed5
notify      git            1d37c3ea2841612a661efc6f83e5f18b007fc9e0
showimg     git            b98fdd27c839e6e54fb22467413687be48abc51d
tmux        conda          3.7b_
visidata    pip            3.4
llm         pip            0.31.1
screen      gnu            5.0.2
go          go             go1.27.1
openjdk     adoptium       21
```

- **Forge tools** (GitHub or Gitea) install from `releases/tags/<tag>` (the
  exact tag), not `latest`; the `gh` channel in the lockfile means "a release
  tag", not necessarily github.com. **sendcb**, **notify** and **showimg**
  have no releases, so `git` holds a commit SHA and their files are fetched
  from that commit. **conda/pip tools** install `pkg=version`.
  **screen** builds that version's source tarball from ftp.gnu.org (`gnu`).
  **go** takes that exact release from go.dev. **openjdk** is the one loose
  pin in the file — `adoptium` holds a feature release (`21`), and the newest
  patch of it is installed; `make freeze` leaves that choice alone. See
  [Language toolchains](#language-toolchains-go-openjdk) for why.
- **Refresh the pins** to current upstream at any time:

  ```sh
  make freeze     # or: ./run.sh freeze  — rewrites versions.lock
  ```

- **Unpin** one tool by deleting its line (it falls back to latest); delete the
  whole file to unpin everything.
- **Commit `versions.lock`** to reproduce the exact same tool set on another
  machine or later in time.

Because a full install (or freeze) makes ~40 GitHub API calls and the
unauthenticated limit is 60/hour, `export GITHUB_TOKEN=...` if you hit it.

**Adding a tool** is one line in `binaries.tsv`:

```
name<TAB>owner/repo<TAB>asset-regex<TAB>[binaries]         # GitHub
name<TAB>host/owner/repo<TAB>asset-regex<TAB>[binaries]    # Gitea host
```

then add `name` to `BINTOOLS` in the `Makefile` (and `run.sh`), and to the lists
in `scripts/status.sh` and `scripts/uninstall.sh` so `make check` and
`make uninstall` know about it.

## Shell integration

`make setup` appends a small guarded block to `~/.bashrc` (and `~/.zshrc` if it
exists) that sources `shell/init.sh`. That file:

- puts `~/bin`, `~/.local/bin`, and `~/miniforge3/bin` on `PATH`;
- initialises `starship`, `zoxide`, `atuin`, `direnv`, and `fzf` for bash/zsh;
- loads notify's hook, so long commands notify when they finish (see
  [notify](#notify); `TS_NOTIFY_HOOK=0` turns it off);
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

`make setup` handles `PATH`, auto-initialises starship/zoxide/atuin/direnv/fzf
and loads notify's hook. Nine tools need one manual step:

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

- **screen** leaves 24-bit colour off until told otherwise — add
  `truecolor on` to `~/.screenrc` and start a new session. See
  [GNU Screen 5, built from source](#gnu-screen-5-built-from-source).

- **xclip** talks to an X server, so it needs `$DISPLAY` pointing at a live one.
  It installs anywhere, but on a headless box or a plain `ssh` session it exits
  with `Error: Can't open display: (null)`. Connect with `ssh -X` (or `-Y`) and
  a local X server, and `echo $DISPLAY` should show something like
  `localhost:10.0`. Nothing else in this setup needs it: `sendcb` uses it only
  at a local X desktop, and over SSH reaches your own clipboard without X.

- **sendcb** inside tmux needs `set -g set-clipboard on` in `~/.tmux.conf`.
  tmux's default, `external`, drops the sequence, and sendcb warns when it
  would; `tmux set -g set-clipboard on` applies it to a running server. On your
  own machine the terminal has to accept OSC 52: most do by default, iTerm2
  needs Settings → General → Selection → "Applications in terminal may access
  clipboard", and GNOME Terminal and other VTE terminals can't. Over mosh, both
  ends need 1.4.0 or later.

- **notify** needs your own terminal to show the notifications. Ghostty,
  kitty, WezTerm and foot do by default. iTerm2 needs Settings → Profiles →
  Terminal → "Send Notification Center alerts", then "Filter Alerts" → "Send
  escape sequence-generated alerts"; Warp needs Settings → Features →
  Notifications. Alacritty and Terminal.app show none, nor do most GNOME
  Terminal builds, so set `export NOTIFY_METHOD=bell` on the remote machine;
  do the same over mosh, which drops the sequences. Over plain SSH most terminals look alike, so
  `auto` sends OSC 9; if nothing pops up, find the `printf` test in
  [notify's README](https://github.com/davetang/notify#your-terminal) that
  works and set `NOTIFY_METHOD` to match. `notify -v hello` says which method
  it used.

- **showimg** inside tmux needs `set -gq allow-passthrough on` in
  `~/.tmux.conf` (the `-q` keeps tmux older than 3.3, which has no such option,
  from complaining). tmux's default, `off`, drops the image, and showimg stops
  with the fix; `tmux set -g allow-passthrough on` applies it to a running
  server. It also lets any program in the pane you're looking at send your
  terminal sequences tmux would otherwise filter, as it could without tmux.
  On your own machine the terminal has to show images: Warp, kitty, Ghostty,
  iTerm2 and WezTerm do as they are, and VS Code needs
  `terminal.integrated.enableImages` on. Alacritty, Terminal.app and GNOME
  Terminal can't, and mosh can't carry images, so use `showimg -p text` there
  (needs `chafa`). Inside GNU screen showimg can't ask the terminal and tries
  kitty's protocol, so for iTerm2 or WezTerm set `SHOWIMG_PROTOCOL=iterm`
  inside screen only, as
  [showimg's README](https://github.com/davetang/showimg#gnu-screen) shows.
  `showimg -v plot.png` says which protocol and size it used.

Everything else works the moment it's on `PATH`. Run `make check` to confirm.

## Uninstall

```sh
make uninstall   # removes the ~/bin binaries this repo installed
```

That includes `screen`, `go`, the JDK and `rig`, along with their
`~/bin/screen-<version>/`, `~/bin/go-<version>/`, `~/bin/jdk-<release>/` and
`~/bin/rig-<version>/` trees. R itself stays: it is rig's, it runs without rig,
and the uninstall prints the one `rm -rf` that removes it, should you want that
too.

Conda tools (`tree`, `pigz` and `coreutils` among them), `visidata`, `llm`,
Miniforge, `~/.oh-my-zsh` and your rc edits are left untouched (`pipx uninstall
llm`, remove `~/miniforge3`, run oh-my-zsh's own `uninstall_oh_my_zsh`, and drop
the `# >>> terminal-setup >>>` block by hand if you want).

## Intentionally omitted

The talk lists many competing alternatives; this setup keeps one per category.
Deliberately **not** installed:

- **GUI terminal emulators** (Warp, Ghostty, kitty, WezTerm, Alacritty, foot,
  iTerm2) — these are graphical apps, not CLI tools, and iTerm2 is macOS-only.
- **Category alternatives** — fish/nushell (vs zsh), zellij (vs tmux),
  bottom/`btm` (vs btop), ranger/nnn/lf (vs yazi), w3m/lynx/browsh (text
  browsers), mutt/aerc/himalaya (email), pixi/mamba (vs the Miniforge base).
- **Other language runtimes** — `node` and the Neovim language servers live in
  [`nvim_setup`](https://github.com/davetang/nvim_setup), which is where they
  are actually used; `nvm`, `lua` and `luarocks` are still in
  [`install_scripts`](https://github.com/davetang/install_scripts). `go` and
  `openjdk` are here because they are general toolchains rather than editor
  plumbing, and even they are opt-in. So is R, through [rig](#r-through-rig).

To add any of them, drop a row in `binaries.tsv` (if it ships a Linux binary) or
`conda install -c conda-forge <pkg>`.
