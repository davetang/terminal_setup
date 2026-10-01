#!/usr/bin/env bash
# sendcb.sh — sendcb (https://github.com/davetang/sendcb): copy to the
# clipboard of the machine you are sitting at, over SSH and through tmux or
# screen, as an OSC 52 escape sequence. Falls back to pbcopy, wl-copy, xclip
# or xsel at a local desktop.
#
# One bash script with no releases at all, so not a binaries.tsv row (that
# needs a release asset to match) and pinned to a commit, not a tag: channel git
# in versions.lock. The script is fetched from raw.githubusercontent.com at that
# commit, which is not the API and costs nothing against the 60/hour limit;
# only an unpinned install asks the API for the newest commit.
#
# Upstream's setup.sh is NOT run. It would add a PATH line to ~/.bashrc, which
# 'make setup' already covers, and edit ~/.tmux.conf, which is yours to change:
# see "After installing" in README.md for the one line sendcb wants there.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

REPO='davetang/sendcb'

need sendcb || exit 0

sha="$(lock_get sendcb git)"
if [[ -n "$sha" ]]; then
  log "installing sendcb ${sha:0:7}  (github:$REPO, pinned)"
else
  sha="$(forge_latest_commit "$REPO")" || true
  [[ -n "$sha" ]] || die "sendcb: could not resolve the newest commit of $REPO — rate-limited? export GITHUB_TOKEN, or pin one in versions.lock (sendcb<TAB>git<TAB><sha>)"
  log "installing sendcb ${sha:0:7}  (github:$REPO, latest)"
fi

f="$TMP/sendcb"
fetch "https://raw.githubusercontent.com/$REPO/$sha/sendcb" "$f" \
  || die "sendcb: no sendcb at commit $sha — check the SHA in versions.lock"

# A raw URL serves whatever file sits at that path, so make sure it is still a
# bash script that parses before it replaces a working copy.
[[ "$(head -1 "$f")" == '#!'*bash* ]] || die "sendcb: $REPO@${sha:0:7}:sendcb is not a bash script"
bash -n "$f" || die "sendcb: $REPO@${sha:0:7}:sendcb does not parse"

install -m 0755 "$f" "$BIN/sendcb"
ok "sendcb -> $BIN/sendcb ($REPO@${sha:0:7})"
log "sendcb done — inside tmux it needs 'set -g set-clipboard on' (see README.md)"
