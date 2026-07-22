SHELL := /bin/bash
ROOT  := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
.DEFAULT_GOAL := help
.NOTPARALLEL:                 # steps share ~/bin and conda; keep it sequential

# Tools installed as prebuilt binaries into ~/bin (see binaries.tsv).
BINTOOLS := bat eza fd rg sd dust duf procs btop delta hyperfine \
            jq yq mlr csvtk seqkit \
            fzf zoxide atuin yazi broot \
            starship direnv \
            just chezmoi xh tldr \
            gh pandoc viddy

# Tools with no clean static binary — installed from conda-forge.
CONDATOOLS := tmux zsh datamash parallel pv

.PHONY: help deps check install setup uninstall miniforge freeze \
        binaries conda-tools pip-tools visidata \
        $(BINTOOLS) $(CONDATOOLS)

help: ## Show this help
	@echo "no-root terminal setup — installs modern CLI tools under \$$HOME/bin"
	@echo
	@awk 'BEGIN{FS":.*##"} /^[a-zA-Z0-9_-]+:.*##/{printf "  \033[36m%-12s\033[0m %s\n",$$1,$$2}' $(MAKEFILE_LIST)
	@echo
	@echo "  Groups : binaries  conda-tools  pip-tools"
	@echo "  Single : make bat   make fzf   make tmux   ...  (any tool name)"
	@echo "  Reinst.: FORCE=1 make bat"

deps: ## Preflight: check prerequisites (read-only)
	@$(ROOT)deps.sh

check: ## Report install status of every tool
	@$(ROOT)scripts/status.sh

freeze: ## Pin every tool to its current version -> versions.lock
	@$(ROOT)scripts/freeze.sh

install: deps binaries conda-tools pip-tools ## Install the whole curated set
	@echo
	@echo "Done. Next: 'make setup' to wire your shell, then restart it."

binaries: $(BINTOOLS) ## Install every ~/bin release-binary tool

$(BINTOOLS):
	@$(ROOT)scripts/binary.sh $@

conda-tools: $(CONDATOOLS) ## Install conda-forge tools (tmux, zsh, datamash, parallel, pv)

$(CONDATOOLS): miniforge
	@$(ROOT)scripts/$@.sh

pip-tools: visidata ## Install pip/pipx tools (visidata)

visidata:
	@$(ROOT)scripts/visidata.sh

miniforge: ## Bootstrap Miniforge under ~/miniforge3 if no conda is present
	@$(ROOT)scripts/miniforge.sh

setup: ## Wire ~/bin + tool init into your shell rc (idempotent)
	@$(ROOT)scripts/setup_shell.sh

uninstall: ## Remove the ~/bin binaries this repo installed
	@$(ROOT)scripts/uninstall.sh
