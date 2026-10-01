SHELL := /bin/bash
ROOT  := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
.DEFAULT_GOAL := help
.NOTPARALLEL:                 # steps share ~/bin and conda; keep it sequential

# Tools installed as prebuilt binaries into ~/bin (see binaries.tsv).
BINTOOLS := bat eza fd rg sd dust duf procs btop delta hyperfine \
            jq yq mlr csvtk seqkit duckdb \
            fzf zoxide atuin yazi broot \
            starship direnv \
            just chezmoi xh tldr lazygit \
            shellcheck shfmt ruff \
            gh tea pandoc viddy trippy tt ttyper

# Tools with no clean static binary — installed from conda-forge.
# coreutils is conda-forge's gnu-coreutils: gls, gcat, gsort — g-prefixed, so
# it cannot shadow the system's (see scripts/coreutils.sh).
CONDATOOLS := tmux zsh datamash parallel pv goaccess xclip ncdu \
              tree pigz coreutils

# Pure-Python tools — installed with pipx/pip (conda-forge as a fallback).
PIPTOOLS := visidata llm

# Language toolchains, from each vendor's own tarball into ~/bin/<name>-<ver>/.
# Hundreds of MB each and useful to far fewer people than the tools above, so
# they are NOT part of 'make install' — ask for them by name.
SDKTOOLS := go openjdk

.PHONY: help deps check install setup uninstall miniforge freeze \
        binaries conda-tools pip-tools sdks ollama sendcb screen ohmyzsh tldr-pages \
        $(BINTOOLS) $(CONDATOOLS) $(PIPTOOLS) $(SDKTOOLS)

help: ## Show this help
	@echo "no-root terminal setup — installs modern CLI tools under \$$HOME/bin"
	@echo
	@awk 'BEGIN{FS":.*##"} /^[a-zA-Z0-9_-]+:.*##/{printf "  \033[36m%-12s\033[0m %s\n",$$1,$$2}' $(MAKEFILE_LIST)
	@echo
	@echo "  Groups : binaries  conda-tools  pip-tools  sdks"
	@echo "  Single : make bat   make fzf   make tmux   ...  (any tool name)"
	@echo "  Extras : make sdks (go, openjdk)   make ohmyzsh   make tldr-pages   — not in 'make install'"
	@echo "  Reinst.: FORCE=1 make bat"

deps: ## Preflight: check prerequisites (read-only)
	@$(ROOT)deps.sh

check: ## Report install status of every tool
	@$(ROOT)scripts/status.sh

freeze: ## Pin every tool to its current version -> versions.lock
	@$(ROOT)scripts/freeze.sh

install: deps binaries conda-tools pip-tools ollama sendcb screen ## Install the whole curated set
	@echo
	@echo "Done. Next: 'make setup' to wire your shell, then restart it."

binaries: $(BINTOOLS) ## Install every ~/bin release-binary tool

$(BINTOOLS):
	@$(ROOT)scripts/binary.sh $@

conda-tools: $(CONDATOOLS) ## Install the conda-forge tools (tmux, zsh, tree, pigz, coreutils, ...)

$(CONDATOOLS): miniforge
	@$(ROOT)scripts/$@.sh

pip-tools: $(PIPTOOLS) ## Install pip/pipx tools (visidata, llm)

$(PIPTOOLS):
	@$(ROOT)scripts/$@.sh

sdks: $(SDKTOOLS) ## Install the language toolchains (go, openjdk) — not in 'make install'

$(SDKTOOLS):
	@$(ROOT)scripts/$@.sh

ohmyzsh: ## Install Oh My Zsh into ~/.oh-my-zsh and wire it into ~/.zshrc
	@$(ROOT)scripts/ohmyzsh.sh

tldr-pages: tldr ## Copy tldr/ into tealdeer's custom pages dir (installs tealdeer first)
	@$(ROOT)scripts/tldr_pages.sh

ollama: ## Install the ollama CLI, client only (queries a server, can't serve)
	@$(ROOT)scripts/ollama.sh

sendcb: ## Install sendcb: copy to your local clipboard, over SSH too (OSC 52)
	@$(ROOT)scripts/sendcb.sh

screen: ## Build GNU Screen 5 from source (24-bit colour; needs gcc + make)
	@$(ROOT)scripts/screen.sh

miniforge: ## Bootstrap Miniforge under ~/miniforge3 if no conda is present
	@$(ROOT)scripts/miniforge.sh

setup: ## Wire ~/bin + tool init into your shell rc (idempotent)
	@$(ROOT)scripts/setup_shell.sh

uninstall: ## Remove the ~/bin binaries this repo installed
	@$(ROOT)scripts/uninstall.sh
