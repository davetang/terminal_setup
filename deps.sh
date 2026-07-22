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
  ok "pip/pipx available (for visidata)"
else
  warn "no pip/pipx — visidata will fall back to conda-forge"
fi

echo
if [[ $missing -ne 0 ]]; then
  die "missing required tools above — install curl, tar, gzip, python3 first"
fi
ok "preflight OK — ready for 'make install'"
