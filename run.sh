#!/usr/bin/env bash
# run.sh — make-free entry point. Mirrors the Makefile targets 1:1, for hosts
# without `make`.  Usage:  ./run.sh <target>
#   ./run.sh deps|check|outdated|install|setup|uninstall
#   ./run.sh binaries|conda-tools|pip-tools|sdks|miniforge
#   ./run.sh bat|fzf|tmux|sendcb|notify|showimg|termcheck|screen|... (any single tool)
#   ./run.sh sdks|go|openjdk|rig|ohmyzsh|tldr-pages (extras; not part of 'install')
#   FORCE=1 ./run.sh bat             (reinstall)
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
source "$here/lib.sh"

BINTOOLS=(bat eza fd rg sd dust duf procs btop delta hyperfine
          jq yq mlr csvtk seqkit duckdb
          fzf zoxide atuin yazi broot
          starship direnv
          just chezmoi xh tldr lazygit
          shellcheck shfmt ruff
          gh tea pandoc viddy trippy tt ttyper)
CONDATOOLS=(tmux zsh datamash parallel pv goaccess xclip ncdu
            tree pigz coreutils)
PIPTOOLS=(visidata llm)
SDKTOOLS=(go openjdk)

do_binaries()  { local b; for b in "${BINTOOLS[@]}";  do "$here/scripts/binary.sh" "$b"; done; }
do_conda()     { local c; for c in "${CONDATOOLS[@]}"; do "$here/scripts/$c.sh"; done; }
do_pip()       { local p; for p in "${PIPTOOLS[@]}";  do "$here/scripts/$p.sh"; done; }
do_sdks()      { local s; for s in "${SDKTOOLS[@]}";  do "$here/scripts/$s.sh"; done; }

t="${1:-help}"
case "$t" in
  help|-h|--help)
    echo "usage: ./run.sh <target>"
    echo "  deps check outdated freeze install setup uninstall"
    echo "  binaries conda-tools pip-tools miniforge"
    echo "  sdks rig ohmyzsh tldr-pages   (extras, not part of 'install')"
    echo "  <tool>   any of: ${BINTOOLS[*]} ${CONDATOOLS[*]} ${PIPTOOLS[*]} ${SDKTOOLS[*]} ollama sendcb notify showimg termcheck screen" ;;
  deps)        "$here/deps.sh" ;;
  check)       "$here/scripts/status.sh" ;;
  outdated)    "$here/scripts/outdated.sh" ;;
  freeze)      "$here/scripts/freeze.sh" ;;
  setup)       "$here/scripts/setup_shell.sh" ;;
  uninstall)   "$here/scripts/uninstall.sh" ;;
  miniforge)   "$here/scripts/miniforge.sh" ;;
  binaries)    do_binaries ;;
  conda-tools) do_conda ;;
  pip-tools)   do_pip ;;
  sdks)        do_sdks ;;
  rig)         "$here/scripts/rig.sh" ;;
  ohmyzsh)     "$here/scripts/ohmyzsh.sh" ;;
  tldr-pages)  "$here/scripts/binary.sh" tldr; "$here/scripts/tldr_pages.sh" ;;
  ollama)      "$here/scripts/ollama.sh" ;;
  sendcb)      "$here/scripts/sendcb.sh" ;;
  notify)      "$here/scripts/notify.sh" ;;
  showimg)     "$here/scripts/showimg.sh" ;;
  termcheck)   "$here/scripts/termcheck.sh" ;;
  screen)      "$here/scripts/screen.sh" ;;
  install)
    "$here/deps.sh"; do_binaries; do_conda; do_pip
    "$here/scripts/ollama.sh"
    "$here/scripts/sendcb.sh"
    "$here/scripts/notify.sh"
    "$here/scripts/showimg.sh"
    "$here/scripts/termcheck.sh"
    "$here/scripts/screen.sh"
    echo; ok "Done. Next: ./run.sh setup, then restart your shell." ;;
  *)
    if printf '%s\n' "${BINTOOLS[@]}"  | grep -qx "$t"; then "$here/scripts/binary.sh" "$t"
    elif printf '%s\n' "${CONDATOOLS[@]}" | grep -qx "$t"; then "$here/scripts/$t.sh"
    elif printf '%s\n' "${PIPTOOLS[@]}"   | grep -qx "$t"; then "$here/scripts/$t.sh"
    elif printf '%s\n' "${SDKTOOLS[@]}"   | grep -qx "$t"; then "$here/scripts/$t.sh"
    else die "unknown target '$t' — try ./run.sh help"; fi ;;
esac
