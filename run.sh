#!/usr/bin/env bash
# run.sh — make-free entry point. Mirrors the Makefile targets 1:1, for hosts
# without `make`.  Usage:  ./run.sh <target>
#   ./run.sh deps|check|install|setup|uninstall
#   ./run.sh binaries|conda-tools|pip-tools|miniforge
#   ./run.sh bat|fzf|tmux|...        (any single tool)
#   FORCE=1 ./run.sh bat             (reinstall)
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
source "$here/lib.sh"

BINTOOLS=(bat eza fd rg sd dust duf procs btop delta hyperfine
          jq yq mlr csvtk seqkit
          fzf zoxide atuin yazi broot
          starship direnv
          just chezmoi xh tldr
          gh pandoc viddy)
CONDATOOLS=(tmux zsh datamash parallel pv)
PIPTOOLS=(visidata llm)

do_binaries()  { local b; for b in "${BINTOOLS[@]}";  do "$here/scripts/binary.sh" "$b"; done; }
do_conda()     { local c; for c in "${CONDATOOLS[@]}"; do "$here/scripts/$c.sh"; done; }
do_pip()       { local p; for p in "${PIPTOOLS[@]}";  do "$here/scripts/$p.sh"; done; }

t="${1:-help}"
case "$t" in
  help|-h|--help)
    echo "usage: ./run.sh <target>"
    echo "  deps check freeze install setup uninstall"
    echo "  binaries conda-tools pip-tools miniforge"
    echo "  <tool>   any of: ${BINTOOLS[*]} ${CONDATOOLS[*]} ${PIPTOOLS[*]} ollama" ;;
  deps)        "$here/deps.sh" ;;
  check)       "$here/scripts/status.sh" ;;
  freeze)      "$here/scripts/freeze.sh" ;;
  setup)       "$here/scripts/setup_shell.sh" ;;
  uninstall)   "$here/scripts/uninstall.sh" ;;
  miniforge)   "$here/scripts/miniforge.sh" ;;
  binaries)    do_binaries ;;
  conda-tools) do_conda ;;
  pip-tools)   do_pip ;;
  ollama)      "$here/scripts/ollama.sh" ;;
  install)
    "$here/deps.sh"; do_binaries; do_conda; do_pip
    "$here/scripts/ollama.sh"
    echo; ok "Done. Next: ./run.sh setup, then restart your shell." ;;
  *)
    if printf '%s\n' "${BINTOOLS[@]}"  | grep -qx "$t"; then "$here/scripts/binary.sh" "$t"
    elif printf '%s\n' "${CONDATOOLS[@]}" | grep -qx "$t"; then "$here/scripts/$t.sh"
    elif printf '%s\n' "${PIPTOOLS[@]}"   | grep -qx "$t"; then "$here/scripts/$t.sh"
    else die "unknown target '$t' — try ./run.sh help"; fi ;;
esac
