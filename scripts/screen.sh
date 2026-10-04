#!/usr/bin/env bash
# screen.sh — build GNU Screen 5 from source into ~/bin, no root.
#
# The one tool here built from source, so the one that needs a C compiler and
# make. 24-bit colour (`truecolor on`, which Neovim's termguicolors needs)
# arrived in Screen 5.0; distros still ship 4.x, conda-forge stops at 4.8.0,
# and GNU publishes source tarballs only.
#
# configure has to *link* a termcap library (for tgetent) and libcrypt. It never
# includes curses headers, since Screen declares tgetent itself, but -ltinfo
# only resolves libtinfo.so, and without the -dev package a host has just the
# runtime libtinfo.so.6: configure stops at "unable to find tgetent() function".
# So link against Miniforge's ncurses and libxcrypt, located through conda
# itself rather than $CONDA_PREFIX (empty unless the base env happens to be
# active), with an rpath so the binary finds them at run time.
#
# Installs into ~/bin/screen-<version>/ (Screen reads its encodings from a path
# under its prefix, compiled in) and links ~/bin/screen to it. Pinned through
# versions.lock (channel gnu).
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

# screen_version <path>: print the version `screen -v` reports, or nothing.
screen_version() {
  { "$1" -v 2>/dev/null || true; } \
    | sed -nE 's/^Screen version ([0-9][0-9.]*[0-9]).*/\1/p' | head -1
}

# --- already have 5.x? -------------------------------------------------------
# Not need(): most hosts already have a screen on PATH, but it's the distro's
# 4.x, the very thing this replaces. Only 5.0 or newer counts as installed.
mkdir -p "$BIN"
if [[ "$FORCE" != 1 ]]; then
  cands=("$BIN/screen")
  p="$(command -v screen 2>/dev/null || true)"
  [[ -n "$p" && "$p" != "$BIN/screen" ]] && cands+=("$p")
  for s in "${cands[@]}"; do
    [[ -x "$s" ]] || continue
    v="$(screen_version "$s")"
    if [[ "${v%%.*}" =~ ^[0-9]+$ ]] && (( ${v%%.*} >= 5 )); then
      ok "screen $v already at $s (FORCE=1 to rebuild)"; exit 0
    fi
    log "found screen ${v:-of unknown version} at $s — building 5.x to shadow it"
  done
fi

have make || die "screen: 'make' not found — GNU Screen is built from source and needs make and a C compiler (gcc)"
have gcc || have cc || die "screen: no C compiler (gcc or cc) — GNU Screen is built from source and needs one"

ver="$(lock_get screen gnu)"
if [[ -n "$ver" ]]; then
  log "building screen $ver  (ftp.gnu.org source, pinned)"
else
  ver="$(gnu_latest_version screen)" || true
  [[ -n "$ver" ]] || die "screen: could not read the release list at https://ftp.gnu.org/gnu/screen/ — pin one in versions.lock (screen<TAB>gnu<TAB>5.0.2)"
  log "building screen $ver  (ftp.gnu.org source, latest)"
fi

# --- libraries to link against ----------------------------------------------
_conda_setup
cprefix="$("$CONDA" info --base)"
if [[ ! -e "$cprefix/lib/libtinfo.so" || ! -e "$cprefix/lib/libcrypt.so" ]]; then
  log "conda install -c conda-forge ncurses libxcrypt  (for screen to link against; into base env)"
  "$CONDA" install -y -p "$cprefix" -c conda-forge ncurses libxcrypt
fi
for lib in libtinfo.so libcrypt.so; do
  [[ -e "$cprefix/lib/$lib" ]] || die "screen: $cprefix/lib/$lib is still missing after installing ncurses and libxcrypt"
done

# --- build -------------------------------------------------------------------
url="https://ftp.gnu.org/gnu/screen/screen-$ver.tar.gz"
fetch "$url" "$TMP/${url##*/}"
tar -xzf "$TMP/${url##*/}" -C "$TMP"
src="$TMP/screen-$ver"
[[ -x "$src/configure" ]] || die "screen: no configure script inside ${url##*/}"
dest="$BIN/screen-$ver"

# A build is noisy, so each step logs to $TMP and shows the tail on failure
# ($TMP is removed on exit, logs and all).
# --disable-pam: PAM is on by default and needs <security/pam_appl.h>, rarely
# there without root. Screen only uses it to unlock with your login password.
log "configuring  (prefix $dest, libraries from $cprefix/lib)"
if ! ( cd "$src" \
       && CPPFLAGS="-I$cprefix/include ${CPPFLAGS:-}" \
          LDFLAGS="-L$cprefix/lib -Wl,-rpath,$cprefix/lib ${LDFLAGS:-}" \
          ./configure --prefix="$dest" --disable-pam ) > "$TMP/configure.log" 2>&1; then
  tail -n 15 "$TMP/configure.log" >&2
  # configure itself only prints "no"; the compiler/linker error is in config.log.
  grep -E 'cannot find|undefined reference|error:' "$src/config.log" 2>/dev/null | tail -n 5 >&2 || true
  die "screen: configure failed (output above)"
fi

jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
log "compiling  (make -j$jobs)"
make -C "$src" -j"$jobs" > "$TMP/make.log" 2>&1 \
  || { tail -n 20 "$TMP/make.log" >&2; die "screen: make failed (output above)"; }

# make install also tries to setuid-root the binary and to tic its terminfo
# entry into /usr/lib/terminfo; Screen's Makefile prefixes both with '-', so
# without root they fail harmlessly. A non-setuid screen just can't write utmp.
rm -rf "$dest"
make -C "$src" install > "$TMP/install.log" 2>&1 \
  || { tail -n 20 "$TMP/install.log" >&2; die "screen: make install failed (output above)"; }
[[ -x "$dest/bin/screen" ]] || die "screen: make install left no $dest/bin/screen"

ln -sfn "$dest/bin/screen" "$BIN/screen"
_check_libc "$BIN/screen"
ok "screen $(screen_version "$BIN/screen") -> $BIN/screen  (built into $dest)"
record_install screen gnu "$ver"

# shell/init.sh puts ~/miniforge3/bin ahead of ~/bin, so a conda-forge screen
# (4.8.0) left in there would still be the one your shell runs.
if [[ -x "$cprefix/bin/screen" ]]; then
  warn "$cprefix/bin/screen ($(screen_version "$cprefix/bin/screen")) comes before $BIN on PATH once shell/init.sh runs — '$CONDA remove -y -p $cprefix screen' to use this build"
fi
log "screen done — add 'truecolor on' to ~/.screenrc for 24-bit colour (new sessions only)"
