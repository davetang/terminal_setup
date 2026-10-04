#!/usr/bin/env bash
# rig.sh — rig (https://github.com/r-lib/rig), Posit's R installation manager:
# installs several R versions side by side and switches between them.
#
# Not a binaries.tsv row, although the release is one static binary, because it
# needs two things a row can't give it:
#
#   1. Configuration. rig defaults to admin mode, which installs R under /opt/R
#      and needs sudo. User mode (new in 0.10.0) installs R under
#      ~/.local/share/rig/r and never asks for root; binary-dir puts its R,
#      Rscript and R-<version> links in ~/bin with everything else.
#
#   2. A wrapper. In user mode, every rig command that makes links (add, rm,
#      default, alias, system make-links) appends `. "$HOME/.local/bin/rigenv"`
#      to ~/.profile, ~/.bash_profile, ~/.bashrc, ~/.zprofile and ~/.zshrc,
#      unless ~/.local/bin is on PATH ahead of /usr/local/bin. Its docs say a
#      binary-dir stops that; the code (check_local_bin_path in src/utils.rs)
#      never looks at it. So the real binary lives in ~/bin/rig-<version>/ and
#      ~/bin/rig is a one-command sh script that satisfies that check for
#      rig's own process only. Your shell's PATH and rc files are left alone.
#
# Upstream's install.sh is NOT used either: it installs into ~/.local and edits
# PATH in your shell profiles. Without it `rig self update` refuses (it only
# updates install.sh installs), so upgrade by moving rig's pin in versions.lock
# and running FORCE=1 make rig.
#
# R itself is not installed: `rig add release` is ~280 MB and a choice of its
# own. User mode installs Posit's portable R builds (manylinux_2_34), which need
# glibc 2.34 or newer; rig itself is static and runs anywhere.
#
# Opt-in, not part of 'make install'. Pinned through versions.lock (channel gh).
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

REPO='r-lib/rig'
# Digits only: the repo also has a 2022 release tagged 'latest' whose assets are
# named rig-linux-x86_64-latest.tar.gz.
ASSET_RE='rig-linux-x86_64-[0-9.]+\.tar\.gz$'   # x86_64 Linux; aarch64 has its own

# The comment line the wrapper carries; it's how this script knows ~/bin/rig is
# its own.
MARKER='terminal-setup (scripts/rig.sh)'

# rig strips trailing slashes from its binary dir; strip them here too, so the
# two compare equal below.
while [[ "$BIN" == */ ]]; do BIN="${BIN%/}"; done

# is_rlib_rig <path>: true if <path> runs and is r-lib's rig (it says so in its
# --version). stdin is closed in case <path> is something that reads it.
is_rlib_rig() { "$1" --version </dev/null 2>/dev/null | grep -q 'R Installation Manager'; }

# read_dirs <rig>: set mode, bdir and rroot from what `rig system dirs` reports.
# Off a terminal rig logs [INFO] lines to stderr, so its output only shows if
# the command fails.
read_dirs() {
  local out
  out="$("$1" system dirs 2>&1)" || { printf '%s\n' "$out" >&2; return 1; }
  mode="$(sed -nE 's/^Mode[[:space:]]+//p' <<<"$out")"
  bdir="$(sed -nE 's/^Binary dir[[:space:]]+//p' <<<"$out")"
  rroot="$(sed -nE 's/^R root[[:space:]]+//p' <<<"$out")"
}

# settings_problem: after read_dirs, print how rig's settings differ from the
# ones this script makes, or nothing if they match.
settings_problem() {
  local d=
  [[ "$mode" == user ]] || d="mode '$mode', not user"
  [[ "$bdir" == "$BIN" ]] || d="${d:+$d; }binary dir '$bdir', not $BIN"
  [[ -z "$d" ]] || echo "$d"
}

# env_override: name RIG_MODE and RIG_BINARY_DIR if either is set. They take
# precedence over rig's config file, so setting the config again can't help.
env_override() {
  local e=
  [[ -z "${RIG_MODE:-}" ]] || e="RIG_MODE=$RIG_MODE"
  [[ -z "${RIG_BINARY_DIR:-}" ]] || e="${e:+$e and }RIG_BINARY_DIR=$RIG_BINARY_DIR"
  [[ -z "$e" ]] || echo "$e in your environment overrides rig's config; unset it"
}

# --- already installed? ------------------------------------------------------
# Only this script's own wrapper counts, and only if it still runs. Not need(),
# which takes any rig on PATH as installed: Debian's unrelated `rig` package (a
# random name and address generator) in /usr/games, or an r-lib rig that isn't
# behind the wrapper and so edits your rc files. ~/bin/rig shadows both once
# ~/bin is first on PATH, which 'make setup' arranges.
mkdir -p "$BIN"
if [[ -e "$BIN/rig" || -L "$BIN/rig" ]]; then
  if grep -qs "$MARKER" "$BIN/rig"; then
    if ! is_rlib_rig "$BIN/rig"; then
      log "$BIN/rig no longer runs (was its rig-<version>/ removed?) — reinstalling"
    elif [[ "$FORCE" != 1 ]]; then
      ok "rig already at $BIN/rig (FORCE=1 to reinstall)"
      # Check the settings this script made are still there: without them rig
      # is back in admin mode and the next 'rig add' asks for sudo to install
      # into /opt/R. Warn rather than re-set them, because a
      # 'rig config set mode=admin' may be deliberate.
      if read_dirs "$BIN/rig"; then
        problem="$(settings_problem)"
        hint="$(env_override)"
        [[ -n "$problem" ]] \
          && warn "rig's settings have changed: $problem — ${hint:-FORCE=1 make rig puts them back}"
      fi
      exit 0
    fi
  elif is_rlib_rig "$BIN/rig"; then
    log "$BIN/rig is r-lib's rig without this repo's wrapper — installing the wrapper"
  elif [[ "$FORCE" != 1 ]]; then
    die "rig: $BIN/rig is something else, not r-lib's rig — move it aside, or FORCE=1 make rig to replace it"
  else
    log "$BIN/rig is not r-lib's rig — replacing it (FORCE=1)"
  fi
fi

# --- resolve the release -----------------------------------------------------
tag="$(lock_get rig gh)"
if [[ -n "$tag" ]]; then log "installing rig $tag  (github:$REPO, pinned)"
else log "installing rig  (github:$REPO, latest)"; fi

url="$(forge_asset "$REPO" "$ASSET_RE" "$tag")" || true
[[ -n "${url:-}" ]] || die "rig: no asset matched /$ASSET_RE/ in $REPO — the release naming may have changed, or you hit the GitHub API rate limit (60/hr). Set GITHUB_TOKEN to raise it, or wait and retry."

# --- install the binary and the wrapper --------------------------------------
file="$TMP/${url##*/}"
fetch "$url" "$file"
tar -xzf "$file" -C "$TMP"
[[ -x "$TMP/bin/rig" ]] || die "rig: no bin/rig inside ${url##*/} — the tarball layout changed"

# The version is the last '-' field of the file name, whatever the arch:
# rig-linux-x86_64-0.10.0.tar.gz and rig-linux-aarch64-0.10.0.tar.gz -> 0.10.0
ver="${url##*/}"; ver="${ver%.tar.gz}"; ver="${ver##*-}"
[[ "$ver" =~ ^[0-9][0-9.]*$ ]] || die "rig: could not read a version from ${url##*/}"
dest="$BIN/rig-$ver"
rm -rf "$dest"
mkdir -p "$dest"
install -m 0755 "$TMP/bin/rig" "$dest/rig"
_check_libc "$dest/rig"

# rm first: writing to a symlink would overwrite whatever it points at.
rm -f "$BIN/rig"
cat > "$BIN/rig" <<EOF
#!/bin/sh
# Installed by terminal-setup (scripts/rig.sh). In user mode rig appends a
# rigenv line to ~/.profile, ~/.bashrc and ~/.zshrc unless ~/.local/bin is on
# PATH ahead of /usr/local/bin, and it ignores binary-dir when deciding.
# Satisfy that check for rig's own process only.
PATH="\$HOME/.local/bin:\$PATH" exec "$dest/rig" "\$@"
EOF
chmod 0755 "$BIN/rig"
ok "rig -> $BIN/rig  (a wrapper around $dest/rig)"
record_install rig gh "${tag:-$(_release_tag "$url")}"

# The wrapper points at this version only; older ones are dead weight.
for d in "$BIN"/rig-[0-9]*/; do
  [[ -d "$d" && "${d%/}" != "$dest" ]] || continue
  rm -rf "$d"; ok "removed the previous ${d%/}"
done

# --- configure ---------------------------------------------------------------
# Both are idempotent; the config lives in ~/.local/share/rig/config.json. Off a
# terminal rig logs [INFO] lines to stderr, so show its output only on failure.
for kv in mode=user "binary-dir=$BIN"; do
  out="$("$BIN/rig" config set "$kv" 2>&1)" \
    || { printf '%s\n' "$out" >&2; die "rig: 'rig config set $kv' failed (output above)"; }
done

read_dirs "$BIN/rig" || die "rig: 'rig system dirs' failed (output above)"
problem="$(settings_problem)"
hint="$(env_override)"
[[ -z "$problem" ]] \
  || die "rig: after 'rig config set', 'rig system dirs' still reports $problem — ${hint:-see 'rig config list'}"
ok "$("$BIN/rig" --version)  (user mode: R into $rroot, links into $BIN)"

# Another rig that comes first on PATH would still be the one your shell runs.
# shell/init.sh puts ~/.local/bin ahead of ~/bin, so upstream's install.sh
# location wins even after 'make setup'.
if [[ -x "$HOME/.local/bin/rig" ]]; then
  warn "$HOME/.local/bin/rig comes before $BIN once shell/init.sh runs, so 'rig' still means that one — '$HOME/.local/bin/rig self uninstall --force' removes it, or delete it"
fi
p="$(command -v rig 2>/dev/null || true)"
if [[ -n "$p" && "$p" != "$BIN/rig" && "$p" != "$HOME/.local/bin/rig" ]]; then
  warn "'rig' on this PATH is $p, not $BIN/rig — $BIN has to come first ('make setup' arranges it)"
fi

# --- can this host run the R builds? -----------------------------------------
# rig itself runs anywhere, but `rig add` refuses below glibc 2.34. musl hosts
# get musllinux builds and getconf has nothing to say there, so they pass.
glibc="$(getconf GNU_LIBC_VERSION 2>/dev/null | awk '{print $2}')" || true
if [[ -n "$glibc" && "$(printf '%s\n' 2.34 "$glibc" | sort -V | head -1)" != 2.34 ]]; then
  warn "glibc $glibc is older than 2.34, so 'rig add' cannot install R on this host — run R in a container instead (e.g. apptainer with a rocker/r-ver image)"
fi

log "rig done — next: 'rig add release' installs the current R (~280 MB) and links R and Rscript into $BIN"
