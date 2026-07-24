#!/usr/bin/env bash
# llm — Simon Willison's CLI for large language models: one-shot prompts, pipes,
# chat, templates, and a SQLite log of everything you asked. Talks to hosted
# APIs (OpenAI out of the box, others via plugins) and to local servers.
# Pure Python, needs >= 3.10. Prefers pipx, then pip --user, then conda-forge.
# Honours the pin in versions.lock (channel: pip).
#
# Optionally install plugins at the same time (works on an existing install too):
#   TS_LLM_PLUGINS='llm-ollama llm-anthropic' make llm
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

ver="$(lock_get llm pip)"
pipspec="llm";        [[ -n "$ver" ]] && pipspec="llm==$ver"
condaspec="llm";      [[ -n "$ver" ]] && condaspec="llm=$ver"

# llm needs Python >= 3.10. On an older interpreter pip either refuses outright
# or quietly resolves to some ancient release, so hand those hosts to
# conda-forge, which brings its own Python.
py_ok() {
  have python3 || return 1
  python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null
}

conda_llm() {
  _conda_setup
  log "conda install -c conda-forge $condaspec"
  "$CONDA" install -y -c conda-forge "$condaspec"
}

# _llm_bin: print the llm executable, including the spots a fresh install lands
# in that aren't on PATH yet in this shell.
_llm_bin() {
  local p
  p="$(command -v llm 2>/dev/null)" && { printf '%s\n' "$p"; return 0; }
  for p in "$BIN/llm" "$HOME/.local/bin/llm" "$HOME/miniforge3/bin/llm"; do
    [[ -x "$p" ]] && { printf '%s\n' "$p"; return 0; }
  done
  return 1
}

if need llm; then
  if ! py_ok; then
    warn "python3 $(python3 -V 2>&1 | awk '{print $2}') is too old for llm (needs >= 3.10) — installing from conda-forge"
    conda_llm
  elif have pipx; then
    log "pipx install $pipspec"
    pipx install "$pipspec"
  elif have pip3 || have pip; then
    pip="$(command -v pip3 || command -v pip)"
    log "$pip install --user $pipspec"
    "$pip" install --user "$pipspec"
  else
    warn "no pipx/pip — installing llm via conda-forge"
    conda_llm
  fi
  ok "llm installed ($(_llm_bin || echo 'restart shell / check ~/.local/bin on PATH'))"
fi

# --- plugins (optional) ------------------------------------------------------
# 'llm install' is pip inside llm's own environment, so it does the right thing
# whether llm came from pipx, pip --user or conda. Runs even when llm was
# already present, so you can add plugins to an existing install.
if [[ -n "${TS_LLM_PLUGINS:-}" ]]; then
  if llmbin="$(_llm_bin)"; then
    for plugin in $TS_LLM_PLUGINS; do
      log "llm install $plugin"
      "$llmbin" install "$plugin"
      ok "plugin $plugin installed"
    done
  else
    warn "llm not found on PATH — skipping plugins ($TS_LLM_PLUGINS)"
  fi
fi

log "llm done — 'llm keys set openai' to add a key, or 'llm install llm-ollama' to use the models on your \$OLLAMA_HOST server"
