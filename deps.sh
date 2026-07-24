#!/usr/bin/env bash
# deps.sh — read-only preflight. Verifies prerequisites; installs nothing.
set -uo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib.sh"
set +e   # this script only reports; don't abort on a failed check

log "preflight checks"
missing=0

for c in curl tar gzip python3; do
  if have "$c"; then ok "$c"; else warn "$c MISSING (required)"; missing=1; fi
done

# unzip/bzip2/xz are optional: Python covers zip/bz2/xz extraction if absent.
for c in unzip bzip2 xz; do
  if have "$c"; then ok "$c"; else warn "$c not found — Python fallback will handle it"; fi
done

# zstd is only needed to unpack the ollama release; Python 3.14+ or the
# zstandard/pyzstd modules also do, else scripts/ollama.sh pulls zstd from conda.
if have zstd; then ok "zstd (for the ollama client)"
elif python3 -c 'import compression.zstd' 2>/dev/null \
  || python3 -c 'import zstandard'       2>/dev/null \
  || python3 -c 'import pyzstd'          2>/dev/null; then ok "zstd via python3 (for the ollama client)"
else warn "no zstd — 'make ollama' will install it from conda-forge"; fi

case ":$PATH:" in
  *":$HOME/bin:"*) ok "\$HOME/bin is on PATH" ;;
  *) warn "\$HOME/bin not on PATH — run 'make setup' or add it yourself" ;;
esac

if have conda || have mamba || [[ -x "$HOME/miniforge3/bin/conda" ]]; then
  ok "conda available (for the conda-forge tools)"
else
  warn "no conda — 'make install' will bootstrap Miniforge for the conda-forge tools"
fi

if have pipx || have pip3 || have pip; then
  ok "pip/pipx available (for visidata and llm)"
else
  warn "no pip/pipx — visidata and llm will fall back to conda-forge"
fi

# llm needs Python >= 3.10; older interpreters get it from conda-forge instead.
if python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
  ok "python3 $(python3 -V 2>&1 | awk '{print $2}') (>= 3.10, for llm)"
else
  warn "python3 older than 3.10 — llm will be installed from conda-forge instead"
fi

echo
if [[ $missing -ne 0 ]]; then
  die "missing required tools above — install curl, tar, gzip, python3 first"
fi
ok "preflight OK — ready for 'make install'"
