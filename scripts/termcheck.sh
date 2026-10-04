#!/usr/bin/env bash
# termcheck.sh — termcheck (https://github.com/davetang/termcheck): report what
# a shell can send to the terminal you are sitting at (clipboard copies,
# notifications, images, links, 24-bit colour) over SSH and mosh, through tmux
# and screen, and what to change where something doesn't get through. Needs
# bash 4 and coreutils; changes nothing itself.
#
# One bash script with no releases at all, so not a binaries.tsv row (that
# needs a release asset to match) and pinned to a commit, not a tag: channel git
# in versions.lock. The script is fetched from raw.githubusercontent.com at that
# commit, which is not the API and costs nothing against the 60/hour limit;
# only an unpinned install asks the API for the newest commit.
#
# Upstream's setup.sh is NOT run. It would add a PATH line to ~/.bashrc or
# ~/.zshenv, which 'make setup' already covers; the rest of it only checks for
# bash 4, coreutils, infocmp and /proc.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

REPO='davetang/termcheck'

need termcheck || exit 0

sha="$(lock_get termcheck git)"
if [[ -n "$sha" ]]; then
  log "installing termcheck ${sha:0:7}  (github:$REPO, pinned)"
else
  sha="$(forge_latest_commit "$REPO")" || true
  [[ -n "$sha" ]] || die "termcheck: could not resolve the newest commit of $REPO — rate-limited? export GITHUB_TOKEN, or pin one in versions.lock (termcheck<TAB>git<TAB><sha>)"
  log "installing termcheck ${sha:0:7}  (github:$REPO, latest)"
fi

f="$TMP/termcheck"
fetch "https://raw.githubusercontent.com/$REPO/$sha/termcheck" "$f" \
  || die "termcheck: no termcheck at commit $sha — check the SHA in versions.lock"

# A raw URL serves whatever file sits at that path, so make sure it is still a
# bash script that parses before it replaces a working copy.
[[ "$(head -1 "$f")" == '#!'*bash* ]] || die "termcheck: $REPO@${sha:0:7}:termcheck is not a bash script"
bash -n "$f" || die "termcheck: $REPO@${sha:0:7}:termcheck does not parse"

install -m 0755 "$f" "$BIN/termcheck"
ok "termcheck -> $BIN/termcheck ($REPO@${sha:0:7})"
log "termcheck done — run it outside tmux, inside tmux and inside screen: each has its own answers"
