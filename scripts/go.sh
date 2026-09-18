#!/usr/bin/env bash
# go.sh — the Go toolchain (https://go.dev), from the official tarball.
#
# Not a single binary, so not a binaries.tsv row: Go ships a whole GOROOT
# (bin/, pkg/, src/, lib/ — ~75 MB compressed, ~250 MB unpacked). It installs
# into ~/bin/go-<version>/ and ~/bin/go and ~/bin/gofmt become symlinks into
# that tree, the same shape scripts/screen.sh uses. cmd/go finds GOROOT by
# resolving its own symlink, so nothing needs GOROOT exported — and an
# inherited GOROOT pointing somewhere else will break it, which this checks.
#
# The Go repo's git tags are not the downloads, so there is no release API
# here; go.dev/dl publishes the same list as JSON with a SHA-256 for every
# file, which this verifies before unpacking.
#
# `go install` writes to $GOPATH/bin — ~/go/bin by default, a different
# directory from the ~/bin this repo owns. See shell/init.sh.
# Pinned through versions.lock (channel go).
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

GO_OS=linux GO_ARCH=amd64   # x86_64 Linux; edit both for another platform

need go || exit 0

# --- resolve the release ------------------------------------------------------
# go.dev/dl lists only current releases by default; &include=all reaches back
# far enough to honour a pin in versions.lock.
pin="$(lock_get go go)"
url="https://go.dev/dl/?mode=json"
[[ -n "$pin" ]] && url="$url&include=all"

cat > "$TMP/pick_go.py" <<'PY'
import json, sys
want, goos, goarch = sys.argv[1], sys.argv[2], sys.argv[3]
for rel in json.load(sys.stdin):
    if want:
        if rel.get("version") != want:
            continue
    elif not rel.get("stable"):
        continue
    for f in rel.get("files", []):
        if (f.get("os"), f.get("arch"), f.get("kind")) == (goos, goarch, "archive"):
            print("\t".join([rel["version"], f["filename"], f.get("sha256", "")]))
            raise SystemExit(0)
raise SystemExit(1)
PY

row="$(curl -fsSL --retry 3 --connect-timeout 20 "$url" \
        | python3 "$TMP/pick_go.py" "$pin" "$GO_OS" "$GO_ARCH")" \
  || die "go: no $GO_OS/$GO_ARCH archive for ${pin:-the latest stable release} at go.dev/dl — if you pinned one, check the spelling in versions.lock (it looks like 'go1.25.1')"
IFS=$'\t' read -r ver file sha <<<"$row"

if [[ -n "$pin" ]]; then log "installing $ver  (go.dev, pinned)"
else log "installing $ver  (go.dev, latest stable)"; fi

# --- download and verify ------------------------------------------------------
src="https://go.dev/dl/$file"
fetch "$src" "$TMP/$file"

if [[ -n "$sha" ]]; then
  got="$(python3 -c '
import hashlib, sys
h = hashlib.sha256()
with open(sys.argv[1], "rb") as fh:
    for chunk in iter(lambda: fh.read(1 << 20), b""):
        h.update(chunk)
print(h.hexdigest())' "$TMP/$file")"
  [[ "$got" == "$sha" ]] || die "go: SHA-256 mismatch on $file
  expected $sha
  got      $got
the download was corrupted or tampered with — delete it and retry"
  ok "SHA-256 verified"
else
  warn "go.dev published no SHA-256 for $file — installing unverified"
fi

# --- install ------------------------------------------------------------------
# The tarball unpacks to a single top-level 'go/' directory.
tar -xzf "$TMP/$file" -C "$TMP"
[[ -x "$TMP/go/bin/go" ]] || die "go: no go/bin/go inside $file — the tarball layout changed"

dest="$BIN/go-${ver#go}"
rm -rf "$dest"
mv "$TMP/go" "$dest"

for b in go gofmt; do
  [[ -x "$dest/bin/$b" ]] || die "go: $dest/bin/$b is missing after unpacking $file"
  ln -sfn "$dest/bin/$b" "$BIN/$b"
  ok "$b -> $BIN/$b"
done
_check_libc "$BIN/go"

ok "$("$BIN/go" version)  (GOROOT $dest)"

# An inherited GOROOT overrides the symlink resolution above and points the
# toolchain at whatever used to be installed — a confusing failure later.
if [[ -n "${GOROOT:-}" && "$GOROOT" != "$dest" ]]; then
  warn "GOROOT is set to $GOROOT in this environment, which overrides this install — unset it (this repo's Go needs no GOROOT)"
fi
log "go done — 'go install' puts binaries in ${GOPATH:-$HOME/go}/bin, not $BIN"
