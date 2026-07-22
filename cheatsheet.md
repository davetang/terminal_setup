# cheatsheet

Quick, practical usage for the tools installed by this repo. Run `tldr <tool>`
for more examples once installed.

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
```

## git + benchmarking

```sh
# delta: add to ~/.gitconfig
#   [core] pager = delta
#   [interactive] diffFilter = delta --color-only
git diff                    # now syntax-highlighted, side-by-side with -s
hyperfine 'rg foo' 'grep -r foo .'   # benchmark & compare commands
hyperfine --warmup 3 './build.sh'
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
```

## GitHub, docs & watching

```sh
gh auth login                       # authenticate the GitHub CLI once
gh repo clone owner/name
gh pr create --fill                 # open a PR from the current branch
gh pr checks                        # CI status for the current PR
pandoc README.md -o readme.pdf      # convert Markdown -> PDF
pandoc page.html -t gfm -o page.md  # HTML -> GitHub-flavoured Markdown
viddy -n 2 kubectl get pods         # a modern `watch`: re-run every 2s
viddy -d 'date; free -h'            # -d highlights what changed between runs
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
chsh -s "$(command -v zsh)" # make zsh your login shell (optional)
```

## Housekeeping

```sh
make check        # what's installed and where
FORCE=1 make eza  # reinstall / upgrade a single tool to latest
make uninstall    # remove the ~/bin binaries this repo installed
```
