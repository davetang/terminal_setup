# cheatsheet

Quick, practical usage for the tools installed by this repo. Run `tldr <tool>`
for more examples once installed.

- [Coreutils replacements](#coreutils-replacements)
- [git + benchmarking](#git--benchmarking)
- [Linting & formatting (shellcheck, shfmt, ruff)](#linting--formatting-shellcheck-shfmt-ruff)
- [Data wrangling](#data-wrangling)
- [Throughput & parallelism](#throughput--parallelism)
- [Docs & watching](#docs--watching)
- [GitHub (gh)](#github-gh)
- [Gitea (tea)](#gitea-tea)
- [Web log analysis (goaccess)](#web-log-analysis-goaccess)
- [Network](#network)
- [Typing practice (tt, ttyper)](#typing-practice-tt-ttyper)
- [LLM queries (llm)](#llm-queries-llm)
- [LLM queries (ollama, client only)](#llm-queries-ollama-client-only)
- [LLM queries (llm + ollama)](#llm-queries-llm--ollama)
- [Navigation & finding](#navigation--finding)
- [Prompt, env, HTTP, docs](#prompt-env-http-docs)
- [Project tasks & dotfiles](#project-tasks--dotfiles)
- [Shell & multiplexer](#shell--multiplexer)
- [Clipboard (sendcb, xclip)](#clipboard-sendcb-xclip)
- [Notifications (notify)](#notifications-notify)
- [Disk usage (ncdu)](#disk-usage-ncdu)
- [GNU coreutils, g-prefixed](#gnu-coreutils-g-prefixed)
- [Language toolchains (go, openjdk)](#language-toolchains-go-openjdk)
- [Housekeeping](#housekeeping)

## Coreutils replacements

```sh
bat file.rs                 # cat + syntax highlighting + line numbers
bat -p file                 # plain (no decorations), good for piping
eza -lag --git              # ls: long, all, group, git status
eza --tree --level=2        # tree view
fd pattern                  # find files by name (respects .gitignore)
fd -e py -x wc -l           # find *.py, run wc -l on each
rg pattern                  # recursive grep, fast, .gitignore-aware
rg -l TODO                  # list files containing TODO
sd 'foo' 'bar' file.txt     # in-place find/replace (no regex escaping pain)
echo hello | sd l L         # heLLo
dust                        # disk usage as a tree, biggest first
duf                         # df: mounted filesystems, coloured
procs                       # ps: colourised, tree with --tree
procs firefox               # filter by name
btop                        # top/htop TUI; q to quit
tree -L 2 -d               # the original: directories only, two levels deep
tree -a -I .git            # dotfiles included, .git never
```

`eza --tree` and `tree` overlap, and both are here on purpose: eza knows about
git and .gitignore, tree draws what is actually on disk and speaks `-J` (JSON).

## git + benchmarking

```sh
# delta: add to ~/.gitconfig
#   [core] pager = delta
#   [interactive] diffFilter = delta --color-only
#   [delta] dark = true   # or light; skips delta's terminal colour probe (see README)
git diff                    # now syntax-highlighted, side-by-side with -s
lazygit                     # full-screen git TUI for this repo; ? shows keys, q quits
#   space stages · c commit · P push · p pull · b branches · digits switch panels
hyperfine 'rg foo' 'grep -r foo .'   # benchmark & compare commands
hyperfine --warmup 3 './build.sh'
```

## Linting & formatting (shellcheck, shfmt, ruff)

```sh
shellcheck script.sh        # lint one script; non-zero exit if anything is flagged
fd -e sh -x shellcheck      # lint every shell script in the tree
shellcheck -x script.sh     # follow `source`d files instead of skipping them
shellcheck -S warning *.sh  # floor the severity: error > warning > info > style
# every finding carries an SC code; shellcheck.net/wiki/SC2086 explains each one
shellcheck -f json script.sh | jq -r '.[] | [.line,.code,.message] | @tsv'
shfmt -d script.sh          # diff what formatting would change (exit 1 if any)
shfmt -w script.sh          # rewrite in place
shfmt -l .                  # list only the files needing a format (CI-friendly)
shfmt -i 2 -ci -w *.sh      # 2-space indent, indent switch cases
ruff check .                # lint Python
ruff check --fix .          # apply the fixes ruff considers safe
ruff format .               # format (black-compatible)
ruff check --select I --fix .   # sort imports (the isort rules)
ruff check --statistics .   # findings counted by rule — tells you what to fix first
```

## Data wrangling

```sh
jq '.items[] | .name' data.json
yq '.services.web.image' docker-compose.yml
yq -o=json '.' file.yaml            # convert YAML -> JSON
mlr --c2p cat data.csv              # CSV -> pretty table
mlr --icsv --opprint stats1 -a mean,sum -f x -g grp data.csv
csvtk headers -t data.tsv
csvtk cut -f name,score data.csv | csvtk sort -k score:nr
duckdb -c "SELECT * FROM 'data.csv' LIMIT 5"    # run SQL straight over a CSV/Parquet/JSON file
duckdb -c "SELECT count(*) FROM 'reads.parquet'"        # no import step; queries the file in place
duckdb -c "COPY (SELECT * FROM 'data.csv') TO 'out.parquet'"    # convert between formats
duckdb mydb.ddb                     # open a persistent database; REPL, .quit to exit
seqkit stats reads.fq.gz            # FASTA/FASTQ summary
seqkit seq -m 100 reads.fq          # filter by length
datamash -t, mean 2 sum 3 < data.csv
vd data.csv                         # VisiData: interactive; q quits, ? for help
```

## Throughput & parallelism

```sh
pv big.gz | gunzip | wc -l          # progress bar + throughput on the pipe
tar cf - dir | pv | ssh host 'cat > dir.tar'
parallel -j4 gzip ::: *.fastq       # gzip files, 4 at a time
parallel 'echo {} ; grep -c foo {}' ::: *.txt
find . -name '*.bam' | parallel samtools index   # feed a pipeline into parallel
pigz -k big.fastq                   # gzip, but on every core; -k keeps the input
pigz -p 4 -9 big.fastq              # 4 cores, smallest output
tar -I pigz -cf dir.tar.gz dir/     # -I passes the whole compressor command
tar -I unpigz -xf dir.tar.gz        # and back out again
```

pigz writes ordinary gzip, so anything can read it back. Compression is what
parallelises; decompression is mostly serial in the format itself, so `unpigz`
helps but not nearly as much.

## Docs & watching

```sh
pandoc README.md -o readme.pdf      # convert Markdown -> PDF
pandoc page.html -t gfm -o page.md  # HTML -> GitHub-flavoured Markdown
viddy -n 2 kubectl get pods         # a modern `watch`: re-run every 2s
viddy -d 'date; free -h'            # -d highlights what changed between runs
```

## GitHub (gh)

```sh
gh auth login                       # interactive: host, protocol, then browser or token
gh auth login --with-token < tok    # non-interactive
gh auth status                      # the active account on each known host
gh auth setup-git                   # make gh a git credential helper for HTTPS push/clone
gh config set editor vi             # gh opens $EDITOR for issue/PR bodies (gh issue create -e)

# inside a clone, gh reads the git remote for owner/repo context
gh issue list                       # open issues; `gh issue view 42` prints one in full
gh issue create -t 'segfault on load' -b 'steps to reproduce...' -l bug
gh pr list                          # open pull requests
gh pr checkout 42                   # fetch PR 42 into a local branch (aliased: gh co 42)
gh pr create --fill                 # open a PR, title/body taken from the commits
gh pr checks                        # CI status for the current PR
gh pr merge 42 --squash
gh release create v1.2.0 ./dist/tool-linux-amd64    # assets are positional after the tag
gh browse                           # this repo in a browser; `gh browse 42` an issue or PR
gh repo clone owner/name
gh run list                         # recent Actions runs
gh run watch                        # follow a run live, exits when it finishes
gh run view --log-failed            # only the failing steps' logs
```

`gh` and [`tea`](#gitea-tea) are the two forge CLIs this setup installs, and they
divide the same job differently. `tea` is multi-server, picking one per command
with `-l <login>`; `gh` keeps one *active* account per host and you move between
them with `gh auth switch`, so the target comes from context rather than a flag.
Outside a clone, `-R [HOST/]OWNER/REPO` names the repo (tea's `-r`), and `GH_REPO`
sets it for a whole shell. Where no system keyring is available — the usual case
on a headless box — the token is written in plain text to
`${XDG_CONFIG_HOME:-~/.config}/gh/hosts.yml`, so `chmod 600` it, the same care
`tea`'s `config.yml` needs.

`gh` also reads `GITHUB_TOKEN` (and `GH_TOKEN`, which takes precedence) instead of
a stored login — the same variable this repo's installer wants for the GitHub API
rate limit, so one login can serve both:

```sh
export GITHUB_TOKEN=$(gh auth token)   # let `make install` reuse gh's credentials
```

```sh
# --json feeds the rest of this setup; --json with no fields lists what's available
gh issue list --json number,title,state
gh issue list --json number,title --jq '.[] | [.number,.title] | @tsv' | csvtk pretty -t -H
gh pr list --json number,title,state --jq '.[] | [.number,.title,.state] | @tsv' | vd -f tsv
gh pr list --json number,title -t '{{range .}}{{tablerow .number .title}}{{end}}'
gh api repos/{owner}/{repo}/issues | jq '.[].title'   # anything with no subcommand
gh api --paginate /user/repos --jq '.[].full_name'    # every page, one name per line
```

`gh api` is the escape hatch, and it works like `tea api`: it signs the request
with the stored token and expands `{owner}`, `{repo}` and `{branch}` from the
current repo. The built-in `--jq` (short `-q`) is jq syntax evaluated in-process,
so it works on a host without `jq` — this setup installs `jq` anyway, and a real
`| jq` pipe is easier to iterate on, but `--jq` is what keeps `--paginate`
streaming page by page.

## Gitea (tea)

```sh
tea logins add                      # interactive: name, URL, token (default gitea.com)
tea logins add -n work -u https://git.example.org -t <token>   # or non-interactive
tea logins list                     # every server tea knows; `default` picks one
tea whoami

# inside a clone, tea reads the git remote for owner/repo context
tea issues                          # open issues; `tea issues 42` prints one in full
tea issues create -t 'segfault on load' -d 'steps to reproduce...' -L bug
tea pr                              # open pull requests
tea pr checkout 42                  # fetch PR 42 into a local branch
tea pr create -t 'fix parser' --head my-branch -b main
tea pr merge 42
tea releases create --tag v1.2.0 -t v1.2.0 -a ./dist/tool-linux-amd64
tea open                            # this repo in a browser
tea clone owner/repo
```

`tea` is `gh` for Gitea, and unlike `gh` it is multi-server: `-l <login>` picks
which one a command talks to, `-r owner/repo` works outside a clone, and
`-R <remote>` infers the login from a git remote. Log in once per server before
anything else works; tokens are stored in plain text in
`${XDG_CONFIG_HOME:-~/.config}/tea/config.yml`, so `chmod 600` it. Add
`--git-credentials` to `logins add` to make `tea` a git credential helper too,
and HTTPS `git push`/`git clone` stop asking for a password.

```sh
# -o feeds the rest of this setup: simple, table, csv, tsv, yaml, json
tea issues ls -o csv | csvtk pretty                      # readable table
tea issues ls -o tsv --state all | vd -f tsv             # explore in visidata
tea issues ls -o json | jq -r '.[] | [.index,.title] | @tsv'
tea pr ls -f index,title,ci -o table                     # pick your own columns
tea api /repos/{owner}/{repo}/issues | jq '.[].title'    # anything with no subcommand
```

`tea api` is the escape hatch: it signs the request with the stored token and
expands `{owner}`/`{repo}` from the current repo, so any endpoint the CLI does
not wrap is still one line.

## Web log analysis (goaccess)

```sh
goaccess access.log --log-format=COMBINED           # interactive TUI dashboard; q quits
goaccess access.log --log-format=COMBINED -o report.html    # static HTML report
goaccess access.log --log-format=COMBINED \
  -o report.html --real-time-html                   # live HTML, updates over a websocket
goaccess access.log --log-format=CLF                # common log format; also VCOMBINED, W3C, …

# text output (not HTML): CSV or JSON — format is chosen by the -o extension
goaccess access.log --log-format=COMBINED -o report.csv     # tabular, greppable
goaccess access.log --log-format=COMBINED --no-csv-summary -o report.csv   # drop the summary rows
goaccess access.log --log-format=COMBINED -o report.json    # structured, for post-processing
zcat access.log.*.gz | goaccess --log-format=COMBINED -o report.csv -      # rotated/gz logs via stdin

# read the text output back with tools this setup installs
vd report.csv                       # visidata: interactive table, q quits
csvtk pretty report.csv | bat       # aligned table, paged
jq '.general' report.json           # pull one section out of the JSON
```

## Network

```sh
sudo trip example.com       # traceroute + live ping stats in a TUI; q quits
trip -m 30 1.1.1.1          # cap the max number of hops
trip --udp example.com      # use UDP probes instead of the default ICMP
```

`trip` opens raw sockets, so run it with `sudo`, or grant the binary the
capability once (needs root that single time): `sudo setcap cap_net_raw+ep ~/bin/trip`.

## Typing practice (tt, ttyper)

Two typing tests with different strengths: `tt` is the flexible one (any text,
scriptable, logs results), `ttyper` is the one that tells you *which keys* you
keep getting wrong. Use them together — see the loop at the end.

### tt

```sh
tt                                  # 50 words from the 1000 commonest; same as -n 50
tt -t 60 -showwpm                   # 60-second test with a live WPM counter
tt -n 10 -g 5                       # still 50 words, split into 5 groups of 10
tt -quotes en                       # type real quotes rather than random words
tt -words 200en                     # smaller list: the 200 commonest words
tt -list words                      # what's built in (12 lists, en/de/fr/es/...)
tt -list themes                     # 180 colour themes; use with -theme NAME
```

Everything above is embedded in the binary — no word list or theme files to
fetch. During a test: `escape` restarts it, `right`/`left` move to the next and
previous test, `ctrl-c` exits. Your own lists and themes can live in
`~/.tt/words` and `~/.tt/themes`, where `-words`/`-theme` find them by name.

Drill your weak spots by feeding `tt` your own text — any file, or stdin:

```sh
tt notes.md                         # type a real file, one paragraph at a time
tt -start 0 notes.md                # reset saved progress on that file
printf 'plaque quartz jinx vex\n' | tt   # ad-hoc drill from stdin
tt -words ~/weak.txt -n 5 -g 10     # a list of words heavy in the keys you fumble
```

Two switches make practice noticeably harder, and are the ones worth reaching
for once raw speed plateaus: `-nobackspace` (no correcting mistakes) and
`-noskip` (space won't jump past a word you got wrong).

Track progress over time with the machine-readable output:

```sh
tt -oneshot -t 60 -csv >> ~/typing.csv    # type,wpm,cpm,accuracy,timestamp
tt -oneshot -t 60 -json | jq '.wpm'
csvtk -H pretty ~/typing.csv              # read the log back
```

### ttyper

```sh
ttyper                              # 50 words; the results screen is the point
ttyper -w 100                       # longer test
ttyper -l english1000               # bigger vocabulary than the default 200
ttyper -l english-ngrams            # common letter pairs/triples, not real words
ttyper -l rust                      # 12 of the 29 languages are programming ones
ttyper --list-languages             # all 29
ttyper notes.md                     # type a file; "-" reads stdin
```

The results screen is why it's here: an overview, a WPM-over-time chart, and a
**worst keys** panel — the per-key breakdown `tt` won't give you. Two modes make
it bite: `--no-backtrack` (can't return to a finished word) and `--sudden-death`
(one mistake restarts the test).

Languages are embedded in the binary, so `--list-languages` works with no
`~/.config/ttyper` present. Add your own as a word-per-line file at
`~/.config/ttyper/language/<name>`, or skip naming it with `--language-file
<path>`. `~/.config/ttyper/config.toml` sets `default_language` (`english200`
out of the box) and the colours.

### The loop worth running

```sh
ttyper -w 200                             # read the worst-keys panel; say it's j/q/z
rg -oIN '\w{3,}' ~/notes.md ~/*.R |        # mine words from prose or code you have
  rg -i '[jqz]' | sort -u > ~/weak.txt     # ...keeping the ones with those keys
                                           # -I matters: without it rg prefixes paths
tt -words ~/weak.txt -n 5 -g 10 -nobackspace   # drill them, no correcting
tt -oneshot -t 60 -csv >> ~/typing.csv         # log the retest and compare
```

`ttyper` diagnoses, `tt` drills the diagnosis, the CSV shows whether it worked.
The one `weak.txt` feeds both — `ttyper --language-file ~/weak.txt` retests the
same words with a fresh worst-keys panel. No system word list needed:
`/usr/share/dict/words` isn't installed by default on Debian/Ubuntu, so mine
your own text instead.

## LLM queries (llm)

```sh
llm keys set openai                 # store a key once (~/.config/io.datasette.llm)
llm 'ten names for a pet lobster'   # one-shot prompt, streams the answer
llm 'more names' -c                 # -c continues the previous conversation
llm -m gpt-4o 'harder question'     # pick a model; llm models lists them
cat script.py | llm -s 'explain this code'      # -s is the system prompt
git diff | llm -s 'write a commit message'
llm -f README.md 'summarise this'   # -f takes a file path or a URL
llm -a diagram.png 'describe this'  # -a attaches an image (multi-modal models)
llm chat -m gpt-4o                  # interactive session; 'exit' quits
llm -s 'write pytest tests for this code' --save pytest   # save a template
cat utils.py | llm -t pytest        # ...and reuse it with -t
llm logs -n 3                       # last 3 prompts+responses (SQLite-backed)
llm logs -r                         # just the most recent response, plain text
llm logs -q docker                  # search past prompts
llm install llm-ollama              # plugins add providers: ollama, anthropic, gemini
llm models                          # every model available to you right now
```

## LLM queries (ollama, client only)

```sh
export OLLAMA_HOST=http://gpu-box:11434   # default http://127.0.0.1:11434
ollama list                         # models available on that server
ollama ps                           # what's loaded in memory right now
ollama run qwen3 'one-line summary'         # one-shot prompt, prints and exits
ollama run qwen3 < prompt.txt               # prompt from a file
cat notes.md | ollama run qwen3 'summarise' # or from a pipe
ollama run qwen3                    # interactive chat; /bye quits
ollama show qwen3                   # model params, context length, licence
ollama pull qwen3                   # tell the server to fetch a model
ollama --version                    # client version (warns if no server)
# no `ollama serve` — this install has the CLI, not the inference runners
```

## LLM queries (llm + ollama)

The `llm-ollama` plugin registers every model on your Ollama server with
`llm`, so the whole `llm` toolkit above — templates, fragments, logs — works
against local models with no API key and nothing leaving your network.

```sh
llm install llm-ollama              # one-off; adds the server's models to llm
export OLLAMA_HOST=http://gpu-box:11434   # same var the ollama client reads
llm ollama models                   # what's on the server, + capabilities
llm models                          # ...listed with every other provider
llm -m qwen3 'explain this error'   # ':latest' models also get a short alias
llm -m qwen3:4b 'pin the tag when you need a specific one'
cat notes.md | llm -m qwen3 -s 'summarise in five bullets'
llm 'and shorter' -c                # -c continues, keeping the same model
llm chat -m qwen3                   # interactive session; 'exit' quits
llm models default qwen3            # make it the default: plain `llm '...'`
llm -m llava 'describe this' -a shot.png        # vision models take -a
llm -m llama3.2 --schema 'name, age int, bio' 'invent a dog'   # JSON out
llm embed -m mxbai-embed-large -i README.md     # embeddings, same server
llm logs -n 1 -r                    # local prompts are logged like any other
```

## Navigation & finding

```sh
z proj                      # zoxide: jump to a frecent dir matching "proj"
zi                          # zoxide interactive pick (needs fzf)
fzf                         # fuzzy-find a file under cwd
vim "$(fzf)"                # open the chosen file
Ctrl-R                      # atuin: searchable shell history
Ctrl-T                      # fzf: paste a chosen path onto the command line
yazi                        # TUI file manager; q quits, arrows/hjkl move
broot                       # fuzzy tree; type to filter, Enter to cd
```

## Prompt, env, HTTP, docs

```sh
starship                    # prompt is auto-enabled by shell/init.sh
echo 'export API_KEY=xxx' > .envrc && direnv allow   # per-dir env
xh GET httpbin.org/get      # ergonomic HTTP client
xh POST httpbin.org/post name=dave                   # JSON body by default
tldr tar                    # example-first help for any command
```

## Project tasks & dotfiles

```sh
# justfile in your repo:
#   build:
#       cargo build --release
just                        # run the default recipe
just build                  # run a named recipe
chezmoi init                # start managing dotfiles
chezmoi add ~/.bashrc       # track a file
chezmoi apply               # sync changes to $HOME
```

## Shell & multiplexer

```sh
tmux                        # new session; prefix Ctrl-b then " or % to split
tmux ls                     # list sessions
tmux attach -t 0            # reattach
screen -d -R -S work        # GNU Screen 5: attach to "work", creating it if needed
screen -ls                  # list sessions; inside one, Ctrl-a d detaches
screen -S work -X quit      # end a session from outside it
echo 'truecolor on' >> ~/.screenrc   # 24-bit colour, in sessions started after this
chsh -s "$(command -v zsh)" # make zsh your login shell (optional)
```

## Clipboard (sendcb, xclip)

Two ways to reach a clipboard, and which one works depends on where you are.
`sendcb` copies to the machine you are *sitting at*, over SSH and through
tmux or screen. `xclip` talks to an X server, so it copies to the machine it
*runs on*, and needs `$DISPLAY`. Over plain SSH, reach for `sendcb`.

### sendcb

```sh
git rev-parse HEAD | sendcb           # then Cmd-V / Ctrl-V on your own machine
sendcb ~/.ssh/id_ed25519.pub          # copy a file
pwd | sendcb -n                       # no trailing newline
history | tail -n 20 | sendcb
sendcb -v results.tsv                 # say which method: osc52, via tmux, wrapped for screen

# pairs with the rest of the setup
jq -r '.[].name' data.json | sendcb
git diff | llm -s 'write a commit message' | sendcb

# inside tmux it needs set-clipboard on, or tmux drops the sequence (it warns)
tmux set -g set-clipboard on          # running server; keep it in ~/.tmux.conf
# a screen/tmux session started at the desktop, reattached over SSH, has no
# $SSH_CONNECTION, so sendcb uses the desktop clipboard; -o forces OSC 52
some_command | sendcb -o
# copy only: terminals refuse OSC 52 reads, so paste with Cmd-V / Ctrl-V.
# iTerm2 has OSC 52 off: Settings > General > Selection > "Applications in
# terminal may access clipboard". GNOME Terminal and other VTE ones can't.
```

### xclip

```sh
# X has three selections; CLIPBOARD is the one Ctrl-V pastes from.
# xclip defaults to PRIMARY (middle-click), so pass -selection clipboard.
pwd | xclip -selection clipboard      # -sel c works, prefixes are matched
xclip -sel c < results.tsv            # copy a file in
xclip -sel c -o > pasted.txt          # paste back out
xclip -sel c -o | wc -l               # ...or straight into a pipe

# trailing newlines come along for the ride; drop it when pasting into a form
git rev-parse HEAD | tr -d '\n' | xclip -sel c

# pairs with the rest of the setup
jq -r '.[].name' data.json | xclip -sel c
xclip -sel c -o | csvtk pretty -t     # eyeball a table copied from a browser
xclip -sel c -o | llm 'summarise this'

# needs a live X server: $DISPLAY must be set (ssh -X), else
#   Error: Can't open display: (null)
# after a copy, xclip forks and stays running — that process *is* the
# selection owner; kill it and the clipboard content goes with it.
```

## Notifications (notify)

`notify` pops up a desktop notification on the machine you are *sitting at*,
over SSH and through tmux or screen, the way `sendcb` reaches its clipboard.
`make setup` also loads its hook, so anything that runs for a minute or more
notifies you when it finishes, without typing `notify` at all.

```sh
make -j8; notify -e $? build          # "Done: build" or "Failed (exit 2): build"
notify -c snakemake -j 16             # run it, then "Done in 2h 14m: snakemake -j 16"
notify 'alignment finished'
notify -t 'job 4182' 'merged the BAM files'   # title defaults to the hostname
notify -v hello                       # say which method: osc9, osc777, osc99, bell

# pairs with the rest of the setup
notify -c hyperfine 'sort big.tsv' 'gsort --parallel=8 big.tsv'
# from a tmux pane: still notifies after you close the pane, if you're attached
nohup sh -c 'make -j8; notify -e $? build' > make.log 2>&1 &

# the hook: tune it below the terminal-setup block in ~/.bashrc or ~/.zshrc
NOTIFY_MIN_SECONDS=300                # only for commands of 5 minutes or more
NOTIFY_IGNORE+=':radian:k9s'          # += ; NOTIFY_IGNORE="$NOTIFY_IGNORE:x" breaks zsh
export NOTIFY_METHOD=auto,bell        # also ring the bell (screen background windows)
export NOTIFY_METHOD=bell             # Alacritty, Terminal.app, GNOME Terminal, mosh
declare -p PS0 PROMPT_COMMAND         # bash: both mention _notify if the hook loaded

# test the terminal on its own, outside tmux and screen
printf '\e]9;hello from OSC 9\a'
printf '\e]777;notify;notify;hello from OSC 777\a'
# needs a terminal attached: nothing reaches you from cron, sbatch or a
# detached tmux session. iTerm2 and Warp have notifications off by default.
```

## Disk usage (ncdu)

```sh
ncdu                        # scan the current directory, then browse it
ncdu -x /                   # a whole filesystem, without crossing mount points
ncdu --color dark ~         # colours are off by default (dark-bg for light terminals)
ncdu --exclude .git repo/   # still listed, just not counted towards the totals

# in the browser
#   j/k or arrows move · l/Enter descend · h/left go up · i info on the item
#   s size sort · n name sort · C item-count sort · t dirs before files
#   a apparent size vs disk usage · g cycle percent/graph · e show hidden
#   r recalculate this dir · d delete (asks first) · b shell here · q quit

# scan once, browse as often as you like — worth it over NFS or on spinning disks
ncdu -1xo scan.json /data   # -1: progress only, no full-screen UI (-0 from cron)
ncdu -f scan.json           # browse that scan; delete/refresh/shell are disabled
ncdu -r /srv/data           # read-only: no delete (-rr also drops the shell)

# -e records mtime as well, so M sorts by it and m shows the column
ncdu -e ~/projects

# the export is JSON, so the rest of this setup can read it
# every file and dir is an object with name/asize/dsize; a directory's own dsize
# is just its inode, not the recursive total the browser shows
ncdu -o - ~/data | jq -r '..|objects|select(.dsize)|[.dsize,.name]|@tsv' \
  | sort -k1,1nr | head

# dust prints a tree and exits; ncdu keeps the scan in memory so you can walk
# into it, recalculate, and delete what you find without leaving the tool.
```

## GNU coreutils, g-prefixed

`make coreutils` installs conda-forge's **gnu-coreutils**: the same programs
your system already has, one version newer, every name prefixed with `g`. The
prefix is the point — `~/miniforge3/bin` sits ahead of `/usr/bin` on PATH, so
an unprefixed build would silently replace `ls`, `cp`, `mv` and `rm` for every
shell and every script. Same convention Homebrew uses on macOS.

```sh
gls --version | head -1     # confirm which one you're getting
ls  --version | head -1     # ... versus the system's
gsort --parallel=4 -T /scratch -k2,2n big.tsv   # sort on 4 cores
gls --hyperlink=auto -l     # clickable paths, if the terminal supports it
gcp --reflink=auto src dst  # share blocks instead of copying (btrfs, XFS, ZFS)
gdate -d '2 weeks ago' +%Y-%m-%d
ls ~/miniforge3/bin/g*      # everything the package installed
```

## Language toolchains (go, openjdk)

Not part of `make install` — `make sdks`, or `make go` / `make openjdk`. Each
unpacks into its own `~/bin/<name>-<version>/` with symlinks in `~/bin`.

```sh
go env GOROOT               # ~/bin/go-<ver>; go resolves its own symlink
go install github.com/owner/tool@latest   # lands in ~/go/bin, NOT ~/bin
CGO_ENABLED=0 go build -ldflags '-s -w'   # a static binary, like most tools here
GOOS=linux GOARCH=arm64 go build          # cross-compile, no cross toolchain
gofmt -w main.go && go mod tidy

java -version && echo $JAVA_HOME          # JAVA_HOME is set by shell/init.sh
java Main.java                            # run a source file, no compile step
java -Xmx2g -jar app.jar
$JAVA_HOME/bin/jshell                     # the rest of the JDK lives here
```

`~/go/bin` is appended to PATH by `shell/init.sh`, so things you build yourself
never shadow the curated set. `java` finds its own JDK; `JAVA_HOME` exists for
Maven, Gradle and sbt, which look it up instead of asking `java`.

## Housekeeping

```sh
make check        # what's installed and where (extras listed separately)
FORCE=1 make eza  # reinstall / upgrade a single tool to latest
make sdks         # go + openjdk, the opt-in toolchains
make ohmyzsh      # oh-my-zsh into ~/.oh-my-zsh, wired into ~/.zshrc
make tldr-pages   # this repo's examples into tldr: tldr ncdu, tldr csvtk
make uninstall    # remove the ~/bin binaries this repo installed
```
