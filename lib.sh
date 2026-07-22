#!/usr/bin/env bash
# lib.sh — shared helpers for the no-root terminal tool setup.
#
# Everything installs under $HOME (default ~/bin). No root, ever.
# Sourced by every script in scripts/. Honour these env vars:
#   PREFIX  (default $HOME)      install prefix
#   BIN     (default $PREFIX/bin) where binaries land
#   FORCE   (default 0)          set to 1 to reinstall / overwrite
#   GITHUB_TOKEN                  optional, raises the GitHub API rate limit

set -euo pipefail

# Absolute path to the repo root (this file lives there).
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

: "${PREFIX:=$HOME}"
: "${BIN:=$PREFIX/bin}"
: "${FORCE:=0}"
: "${LOCKFILE:=$ROOTDIR/versions.lock}"

# Per-process scratch dir, cleaned up on exit.
TMP="$(mktemp -d "${TMPDIR:-/tmp}/termsetup.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# --- logging -----------------------------------------------------------------
if [[ -t 1 ]]; then
  _c_blue=$'\033[1;34m'; _c_green=$'\033[1;32m'; _c_yellow=$'\033[1;33m'
  _c_red=$'\033[1;31m';  _c_reset=$'\033[0m'
else
  _c_blue=; _c_green=; _c_yellow=; _c_red=; _c_reset=
fi
log()  { printf '%s==>%s %s\n'  "$_c_blue"   "$_c_reset" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$_c_green"  "$_c_reset" "$*"; }
warn() { printf '%swarn%s %s\n' "$_c_yellow" "$_c_reset" "$*" >&2; }
die()  { printf '%serror%s %s\n' "$_c_red"   "$_c_reset" "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }
arch() { uname -m; }   # x86_64 on this host

# --- idempotency -------------------------------------------------------------
# need <bin>: returns 0 if <bin> should be installed, 1 if it can be skipped.
# Skips when the binary already exists in $BIN or on PATH, unless FORCE=1.
need() {
  local bin="$1"
  mkdir -p "$BIN"
  [[ "$FORCE" == 1 ]] && return 0
  if [[ -x "$BIN/$bin" ]]; then
    ok "$bin already in $BIN (FORCE=1 to reinstall)"; return 1
  fi
  if have "$bin"; then
    ok "$bin already on PATH: $(command -v "$bin") (FORCE=1 to shadow it in $BIN)"; return 1
  fi
  return 0
}

# --- downloading -------------------------------------------------------------
fetch() { curl -fL --retry 3 --connect-timeout 20 -o "$2" "$1"; }

# _gh_api <path>: GET the GitHub API and print the JSON body.
_gh_api() {
  local path="$1"; local -a auth=()
  [[ -n "${GITHUB_TOKEN:-}" ]] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
  curl -fsSL "${auth[@]}" "https://api.github.com/$path" \
    || die "GitHub API failed for $path (rate-limited? export GITHUB_TOKEN)"
}

# gh_asset <owner/repo> <regex> [<tag>]: print the browser_download_url of the
# first asset whose URL matches <regex>, from release <tag> (or latest if empty).
gh_asset() {
  local repo="$1" re="$2" tag="${3:-}" ep
  if [[ -n "$tag" ]]; then ep="repos/$repo/releases/tags/$tag"
  else ep="repos/$repo/releases/latest"; fi
  _gh_api "$ep" \
    | grep -oE '"browser_download_url":[[:space:]]*"[^"]+"' \
    | sed -E 's/.*"(https[^"]+)".*/\1/' \
    | grep -E "$re" | head -1
}

# gh_latest_tag <owner/repo>: print the tag_name of the latest release.
gh_latest_tag() {
  _gh_api "repos/$1/releases/latest" \
    | grep -oE '"tag_name":[[:space:]]*"[^"]+"' | head -1 \
    | sed -E 's/.*"([^"]+)".*/\1/'
}

# lock_get <name> <channel>: print the pinned version/tag for <name> in
# <channel> (gh|conda|pip) from versions.lock, or nothing if unpinned.
lock_get() {
  [[ -f "$LOCKFILE" ]] || return 0
  awk -F'\t' -v n="$1" -v c="$2" \
    '!/^[[:space:]]*#/ && NF>=3 && $1==n && $2==c {print $3; exit}' "$LOCKFILE"
}

# --- extraction (no unzip/bzip2/xz needed; Python fills the gaps) ------------
# _extract <file> <destdir>: extract an archive. Returns 1 if <file> is not a
# recognised archive (i.e. it's a raw binary).
_extract() {
  local f="$1" d="$2"; mkdir -p "$d"
  case "$f" in
    *.tar.gz|*.tgz)          tar -xzf "$f" -C "$d" ;;
    *.tar.bz2|*.tbz|*.tbz2)  _untar_via_py bz2  "$f" "$d" ;;
    *.tar.xz|*.txz)          _untar_via_py lzma "$f" "$d" ;;
    *.tar)                   tar -xf "$f" -C "$d" ;;
    *.zip)                   _unzip "$f" "$d" ;;
    *) return 1 ;;
  esac
}

# Decompress a bzip2/xz tarball with Python, then untar (tools not installed).
_untar_via_py() {
  local mod="$1" f="$2" d="$3"
  python3 - "$mod" "$f" > "$TMP/_decomp.tar" <<'PY'
import importlib, sys
mod, path = sys.argv[1], sys.argv[2]
data = importlib.import_module(mod).open(path, 'rb').read()
sys.stdout.buffer.write(data)
PY
  tar -xf "$TMP/_decomp.tar" -C "$d"
  rm -f "$TMP/_decomp.tar"
}

_unzip() {
  local f="$1" d="$2"
  if have unzip; then unzip -q -o "$f" -d "$d"
  else python3 -m zipfile -e "$f" "$d"; fi
}

# --- the main installer ------------------------------------------------------
# install_binary <tool>: look <tool> up in binaries.tsv, download its release
# asset, extract it, and drop the named binary/binaries into $BIN.
install_binary() {
  local want="$1" name repo re bins
  local row; row="$(_tsv_row "$want")" || die "no entry for '$want' in binaries.tsv"
  IFS=$'\t' read -r name repo re bins <<<"$row"
  bins="${bins:-$name}"
  local first="${bins%% *}"

  need "$first" || return 0
  local tag; tag="$(lock_get "$name" gh)"
  if [[ -n "$tag" ]]; then log "installing $name $tag  (github:$repo, pinned)"
  else log "installing $name  (github:$repo, latest)"; fi

  local url; url="$(gh_asset "$repo" "$re" "$tag")" || true
  [[ -n "${url:-}" ]] || die "$name: no asset matched /$re/ in $repo — the release naming may have changed, or you hit the GitHub API rate limit (60/hr). Set GITHUB_TOKEN to raise it, or wait and retry."

  local file="$TMP/${url##*/}"
  fetch "$url" "$file"

  local d="$TMP/$name.d" b src
  if _extract "$file" "$d"; then
    for b in $bins; do
      src="$(_find_bin "$d" "$b")" || die "$name: binary '$b' not found inside ${url##*/}"
      install -m 0755 "$src" "$BIN/$b"
      ok "$b -> $BIN/$b"
    done
  else
    # Raw (uncompressed) binary asset.
    install -m 0755 "$file" "$BIN/$first"
    ok "$first -> $BIN/$first"
  fi
  log "$name done  (${url##*/})"
}

# _find_bin <dir> <name>: locate the right executable named <name> in an
# extracted archive. Some archives (e.g. broot) ship binaries for many targets,
# so prefer our x86_64 Linux build; fall back to the sole match otherwise.
_find_bin() {
  local d="$1" b="$2" f pat
  for pat in 'x86_64-unknown-linux-musl' 'x86_64-unknown-linux-gnu' \
             'x86_64.*linux' 'linux.*x86_64' 'x86_64' 'amd64'; do
    f="$(find "$d" -type f -name "$b" 2>/dev/null \
          | grep -E "$pat" | grep -Eiv 'android|windows|darwin|\.exe' | head -1)" || true
    [[ -n "$f" ]] && { printf '%s\n' "$f"; return 0; }
  done
  f="$(find "$d" -type f -name "$b" 2>/dev/null \
        | grep -Eiv 'android|windows|darwin|\.exe' | head -1)" || true
  [[ -n "$f" ]] && { printf '%s\n' "$f"; return 0; }
  return 1
}

# _tsv_row <name>: emit the matching, non-comment row from binaries.tsv.
_tsv_row() {
  awk -F'\t' -v n="$1" \
    '!/^[[:space:]]*#/ && NF && $1==n {print; found=1; exit} END{exit !found}' \
    "$ROOTDIR/binaries.tsv"
}

# --- conda helpers (for tools with no clean static binary) -------------------
# _conda_setup: ensure a conda is available, bootstrapping Miniforge if needed.
# Sets the global CONDA to the conda executable to use.
_conda_setup() {
  if have conda;  then CONDA="$(command -v conda)"; return; fi
  if [[ -x "$HOME/miniforge3/bin/conda" ]]; then CONDA="$HOME/miniforge3/bin/conda"; return; fi
  warn "no conda found — bootstrapping Miniforge under ~/miniforge3"
  "$ROOTDIR/scripts/miniforge.sh"
  CONDA="$HOME/miniforge3/bin/conda"
  [[ -x "$CONDA" ]] || die "Miniforge bootstrap failed"
}

# conda_install <pkg> [<bin>]: install <pkg> from conda-forge into the base env.
conda_install() {
  local pkg="$1" bin="${2:-$1}"
  need "$bin" || return 0
  _conda_setup
  local ver spec="$pkg"; ver="$(lock_get "$pkg" conda)"
  [[ -n "$ver" ]] && spec="$pkg=$ver"
  log "conda install -c conda-forge $spec  (into base env)"
  "$CONDA" install -y -c conda-forge "$spec"
  ok "$pkg installed via conda ($($CONDA run which "$bin" 2>/dev/null || echo "$HOME/miniforge3/bin/$bin"))"
}
