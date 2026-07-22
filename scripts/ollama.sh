#!/usr/bin/env bash
# ollama.sh — install the ollama CLI *client only*: no model runners, no server.
#
# Upstream ships one 1.4 GB bundle per platform:
#   bin/ollama          the CLI  (~39 MB)  <- all we want
#   lib/ollama/*        the CUDA/ROCm/CPU inference runners (~1.4 GB)
# Every subcommand except `ollama serve` is just an HTTP client for the API at
# $OLLAMA_HOST, so the runners are dead weight unless you host models yourself.
#
# bin/ollama happens to be the *first* member of the tarball, so we stream the
# release, take it, and let the download die: ~12 MB over the wire, not 1.4 GB.
#
# Point the client at a server (default http://127.0.0.1:11434):
#   export OLLAMA_HOST=http://gpu-box:11434
#   ollama list; ollama run qwen3 'hello'
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

REPO='ollama/ollama'
ASSET_RE='ollama-linux-amd64\.tar\.zst$'   # x86_64 Linux; edit for another arch
MEMBER='bin/ollama'

# --- a zstd decompressor (stdin -> stdout) -----------------------------------
# The release is zstd-compressed and neither tar nor Python 3.13 and older can
# read that, so find a decompressor. Tries, in order: the zstd CLI, python3
# (3.14's compression.zstd, or the zstandard/pyzstd modules), conda-forge zstd.
ZDEC=()
find_zstd() {
  local z
  for z in "$BIN/zstd" "$BIN/unzstd"; do
    [[ -x "$z" ]] && { ZDEC=("$z" -dc); return 0; }
  done
  have zstd   && { ZDEC=(zstd -dc);  return 0; }
  have unzstd && { ZDEC=(unzstd -c); return 0; }

  if python3 -c 'import compression.zstd' 2>/dev/null \
  || python3 -c 'import zstandard'       2>/dev/null \
  || python3 -c 'import pyzstd'          2>/dev/null; then
    cat > "$TMP/zstdcat.py" <<'PY'
import sys
src, dst = sys.stdin.buffer, sys.stdout.buffer
try:
    from compression.zstd import ZstdFile              # Python >= 3.14
    def run():
        with ZstdFile(src) as f:
            while (chunk := f.read(1 << 20)):
                dst.write(chunk)
except ImportError:
    try:
        import zstandard                               # pip install zstandard
        def run(): zstandard.ZstdDecompressor().copy_stream(src, dst)
    except ImportError:
        import pyzstd                                  # pip install pyzstd
        def run(): pyzstd.decompress_stream(src, dst)
try:
    run()
except (BrokenPipeError, OSError):
    pass   # tar got what it wanted and closed the pipe — that's the happy path
PY
    ZDEC=(python3 "$TMP/zstdcat.py"); return 0
  fi

  warn "no zstd found — installing zstd from conda-forge to unpack the release"
  conda_install zstd
  for z in "$HOME/miniforge3/bin/zstd" "${CONDA:+$(dirname "$CONDA")/zstd}"; do
    [[ -n "$z" && -x "$z" ]] && { ZDEC=("$z" -dc); return 0; }
  done
  have zstd && { ZDEC=(zstd -dc); return 0; }
  return 1
}

# --- tar flags that make it stop reading once it has our member --------------
early_exit_flags() {
  local help; help="$(tar --help 2>&1)"
  case "$help" in
    *--occurrence*) printf '%s\n' --occurrence=1 ;;   # GNU tar
    *--fast-read*)  printf '%s\n' --fast-read ;;      # bsdtar
    *) warn "this tar cannot stop early — the full 1.4 GB will stream past (only $MEMBER is kept)" ;;
  esac
}

# --- install -----------------------------------------------------------------
need ollama || exit 0

tag="$(lock_get ollama gh)"
if [[ -n "$tag" ]]; then log "installing ollama $tag  (github:$REPO, pinned, client only)"
else log "installing ollama  (github:$REPO, latest, client only)"; fi

url="$(gh_asset "$REPO" "$ASSET_RE" "$tag")" || true
[[ -n "${url:-}" ]] || die "ollama: no asset matched /$ASSET_RE/ in $REPO — the release naming may have changed, or you hit the GitHub API rate limit (60/hr). Set GITHUB_TOKEN to raise it, or wait and retry."

find_zstd || die "ollama: no way to decompress zstd. Install zstd (apt/dnf install zstd), or 'pip install zstandard', then retry."

log "streaming $MEMBER out of ${url##*/}  (~12 MB of a 1.4 GB asset)"
d="$TMP/ollama.d"; mkdir -p "$d"
mapfile -t early < <(early_exit_flags)

# tar exits the moment it has the member; that SIGPIPEs the decompressor and
# curl, which is exactly how the download stops early. Their non-zero exits are
# expected, so run the pipeline unguarded and judge it by the extracted file.
set +o pipefail
curl -fsSL --retry 3 --connect-timeout 20 "$url" 2>/dev/null \
  | "${ZDEC[@]}" 2>/dev/null \
  | tar -x -C "$d" "${early[@]}" "$MEMBER" 2>/dev/null || true
set -o pipefail

[[ -s "$d/$MEMBER" ]] || die "ollama: could not extract $MEMBER from ${url##*/} (download interrupted, or the bundle layout changed)"
install -m 0755 "$d/$MEMBER" "$BIN/ollama"
ok "ollama -> $BIN/ollama ($(du -h "$BIN/ollama" | cut -f1), client only — no serve runners)"

ver="$("$BIN/ollama" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)" || true
[[ -n "${ver:-}" ]] && ok "client version $ver"
log "ollama done — set OLLAMA_HOST to your server, e.g. export OLLAMA_HOST=http://gpu-box:11434"
