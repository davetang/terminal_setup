#!/usr/bin/env bash
# visidata — interactive TUI for tabular data. Pure Python.
# Prefers pipx, then uv tool, then pip --user, then falls back to conda-forge.
# Honours the pin in versions.lock (channel: pip).
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

need vd || exit 0

ver="$(lock_get visidata pip)"
pipspec="visidata";        [[ -n "$ver" ]] && pipspec="visidata==$ver"
condaspec="visidata";      [[ -n "$ver" ]] && condaspec="visidata=$ver"

if use_pipx; then
  pipx_args=(install)
  [[ "$FORCE" == 1 ]] && pipx_args+=(--force)
  log "pipx ${pipx_args[*]} $pipspec"
  pipx "${pipx_args[@]}" "$pipspec"
elif uv="$(uv_bin)"; then
  uv_args=(tool install)
  [[ "$FORCE" == 1 ]] && uv_args+=(--force)
  log "uv ${uv_args[*]} $pipspec"
  "$uv" "${uv_args[@]}" "$pipspec"
elif have pip3 || have pip; then
  pip="$(command -v pip3 || command -v pip)"
  log "$pip install --user $pipspec"
  "$pip" install --user "$pipspec"
else
  warn "no pipx, uv or pip — installing visidata via conda-forge"
  _conda_setup
  log "conda install -n base -c conda-forge $condaspec"
  "$CONDA" install -y -n base -c conda-forge "$condaspec"
fi
ok "visidata installed ($(command -v vd 2>/dev/null || echo 'restart shell / check ~/.local/bin on PATH'))"
