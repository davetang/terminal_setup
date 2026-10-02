#!/usr/bin/env bash
# notify.sh — notify (https://github.com/davetang/notify): pop up a desktop
# notification on the machine you are sitting at, over SSH and through tmux or
# screen, as an OSC 9, 777 or 99 escape sequence. Comes with notify-hook.sh,
# which notifies when a command that ran for a minute or more finishes.
#
# Two files with no releases at all, so not a binaries.tsv row (that needs a
# release asset to match) and pinned to a commit, not a tag: channel git in
# versions.lock. Both are fetched from raw.githubusercontent.com at that commit,
# which is not the API and costs nothing against the 60/hour limit; only an
# unpinned install asks the API for the newest commit.
#
# Upstream's setup.sh is NOT run. It would add a PATH line to ~/.bashrc or
# ~/.zshenv, which 'make setup' already covers, and append a line sourcing the
# hook to ~/.bashrc or ~/.zshrc, which shell/init.sh does instead (after
# starship, atuin and direnv, which the hook has to follow).
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

REPO='davetang/notify'

need notify || exit 0

sha="$(lock_get notify git)"
if [[ -n "$sha" ]]; then
  log "installing notify ${sha:0:7}  (github:$REPO, pinned)"
else
  sha="$(forge_latest_commit "$REPO")" || true
  [[ -n "$sha" ]] || die "notify: could not resolve the newest commit of $REPO — rate-limited? export GITHUB_TOKEN, or pin one in versions.lock (notify<TAB>git<TAB><sha>)"
  log "installing notify ${sha:0:7}  (github:$REPO, latest)"
fi

for f in notify notify-hook.sh; do
  fetch "https://raw.githubusercontent.com/$REPO/$sha/$f" "$TMP/$f" \
    || die "notify: no $f at commit $sha — check the SHA in versions.lock"
done

# A raw URL serves whatever file sits at that path, so make sure both still
# parse before they replace a working copy. The hook is sourced, not run, so it
# has no #! line to check.
[[ "$(head -1 "$TMP/notify")" == '#!'*bash* ]] || die "notify: $REPO@${sha:0:7}:notify is not a bash script"
for f in notify notify-hook.sh; do
  bash -n "$TMP/$f" || die "notify: $REPO@${sha:0:7}:$f does not parse"
done

install -m 0755 "$TMP/notify" "$BIN/notify"
ok "notify -> $BIN/notify ($REPO@${sha:0:7})"
install -m 0644 "$TMP/notify-hook.sh" "$BIN/notify-hook.sh"
ok "notify-hook.sh -> $BIN/notify-hook.sh (sourced by shell/init.sh; TS_NOTIFY_HOOK=0 to skip)"
log "notify done — your own terminal has to show notifications (see README.md)"
