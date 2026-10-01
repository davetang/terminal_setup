#!/usr/bin/env bash
# tldr_pages.sh — copy this repo's tldr/ pages into tealdeer's custom pages dir,
# so `tldr <tool>` shows the examples this setup adds. The steps in
# tldr/README.md, plus the checks that README says to do by hand:
#   tldr --update        patches only show when their upstream page is cached
#   tldr --show-paths    the "Custom pages dir:" line, which a custom_pages_dir
#                        in ~/.config/tealdeer/config.toml overrides
#   cp tldr/*.page.md tldr/*.patch.md <that dir>
#
# Overwrites only files of the same name, so pages you wrote yourself stay. Not
# part of 'make install': it writes into tealdeer's data dir, not ~/bin.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

# ~/bin first: right after 'make tldr' it may not be on PATH yet.
if [[ -x "$BIN/tldr" ]]; then TLDR="$BIN/tldr"
elif have tldr; then TLDR="$(command -v tldr)"
else die "tldr not found — 'make tldr' installs tealdeer"; fi

# need() treats any tldr on PATH as installed, and the npm and pip clients are
# also called tldr. Neither has --show-paths or reads custom pages.
[[ "$("$TLDR" --version 2>/dev/null)" == tealdeer* ]] \
  || die "$TLDR is not tealdeer — 'FORCE=1 make tldr' installs tealdeer into $BIN"

log "updating the tldr-pages cache  ($TLDR --update)"
"$TLDR" --update || warn "cache update failed — patches can only attach to pages already cached"

# "Custom pages dir: <path> (OS convention)" or "... <path> (config file)". The
# path itself may contain parentheses, so strip only the final annotation.
dir="$("$TLDR" --show-paths | sed -nE 's/^Custom pages dir:[[:space:]]+//p' | sed -E 's/ \([^()]*\)$//')"
[[ -n "$dir" ]] || die "no 'Custom pages dir:' line in '$TLDR --show-paths' — tealdeer's output may have changed"
dir="${dir%/}"

mkdir -p "$dir"
shopt -s nullglob
pages=("$ROOTDIR"/tldr/*.page.md "$ROOTDIR"/tldr/*.patch.md)
(( ${#pages[@]} )) || die "no *.page.md or *.patch.md files in $ROOTDIR/tldr"
cp -- "${pages[@]}" "$dir/"
ok "copied ${#pages[@]} pages to $dir"

# A patch is appended to the upstream page, and tealdeer shows nothing at all
# when there isn't one: `tldr <cmd>` says "page not found". A <cmd>.page.md in
# the same dir replaces the upstream page and silently drops the patch.
bad=0
for f in "$ROOTDIR"/tldr/*.patch.md; do
  cmd="$(basename "$f" .patch.md)"
  if [[ -e "$dir/$cmd.page.md" ]]; then
    warn "$dir/$cmd.page.md replaces the upstream page, so tealdeer ignores $cmd.patch.md"; bad=1
  elif ! "$TLDR" --raw "$cmd" >/dev/null 2>&1; then
    warn "no upstream page for '$cmd' in the cache, so $cmd.patch.md never shows (rename it $cmd.page.md and make it a full page)"; bad=1
  fi
done
(( bad )) || ok "every patch has an upstream page to attach to"
log "tldr pages done — try: tldr ncdu (patched), tldr csvtk (this repo's own page)"
