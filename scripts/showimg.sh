#!/usr/bin/env bash
# showimg.sh — showimg (https://github.com/davetang/showimg): show an image in
# the terminal you are sitting at, over SSH and through tmux or screen, as a
# kitty graphics, iTerm2 inline image or sixel escape sequence. PNG needs only
# coreutils and awk; PDF, SVG, JPEG and the rest need a converter such as
# pdftoppm or ImageMagick, which this repo does not install.
#
# One bash script with no releases at all, so not a binaries.tsv row (that
# needs a release asset to match) and pinned to a commit, not a tag: channel git
# in versions.lock. The script is fetched from raw.githubusercontent.com at that
# commit, which is not the API and costs nothing against the 60/hour limit;
# only an unpinned install asks the API for the newest commit.
#
# Upstream's setup.sh is NOT run. It would add a PATH line to ~/.bashrc or
# ~/.zshenv, which 'make setup' already covers, and edit ~/.tmux.conf, which is
# yours to change: see "After installing" in README.md for the one line
# showimg wants there. The rest of it only reports (converters, screen, mosh).
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

REPO='davetang/showimg'

need showimg || exit 0

sha="$(lock_get showimg git)"
if [[ -n "$sha" ]]; then
  log "installing showimg ${sha:0:7}  (github:$REPO, pinned)"
else
  sha="$(forge_latest_commit "$REPO")" || true
  [[ -n "$sha" ]] || die "showimg: could not resolve the newest commit of $REPO — rate-limited? export GITHUB_TOKEN, or pin one in versions.lock (showimg<TAB>git<TAB><sha>)"
  log "installing showimg ${sha:0:7}  (github:$REPO, latest)"
fi

f="$TMP/showimg"
fetch "https://raw.githubusercontent.com/$REPO/$sha/showimg" "$f" \
  || die "showimg: no showimg at commit $sha — check the SHA in versions.lock"

# A raw URL serves whatever file sits at that path, so make sure it is still a
# bash script that parses before it replaces a working copy.
[[ "$(head -1 "$f")" == '#!'*bash* ]] || die "showimg: $REPO@${sha:0:7}:showimg is not a bash script"
bash -n "$f" || die "showimg: $REPO@${sha:0:7}:showimg does not parse"

install -m 0755 "$f" "$BIN/showimg"
ok "showimg -> $BIN/showimg ($REPO@${sha:0:7})"
record_install showimg git "$sha"
log "showimg done — inside tmux it needs 'set -gq allow-passthrough on' (see README.md)"
