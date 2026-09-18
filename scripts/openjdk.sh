#!/usr/bin/env bash
# openjdk.sh — an Eclipse Temurin JDK (https://adoptium.net), no root.
#
# Like Go, a JDK is a directory tree rather than a binary, so it installs into
# ~/bin/jdk-<release>/ with symlinks in ~/bin for the handful of commands you
# actually type. The launcher resolves its own path to find the rest of the
# JDK, so the symlinks work; JAVA_HOME is still worth exporting because build
# tools (Maven, Gradle, sbt) look it up rather than asking `java`.
#
# Temurin over the alternatives: jdk.java.net serves only the current release,
# Oracle's own builds carry licence conditions, and conda-forge's openjdk would
# put a JDK in the base environment. Adoptium publishes an API with a SHA-256
# for every asset, which this verifies.
#
# Which JDK: JDK_VERSION (a feature release — 8, 11, 17, 21, 25) or, unset, the
# most recent LTS Adoptium lists. versions.lock pins that feature release
# (channel adoptium) and NOT the exact patch: Temurin ships patch releases on a
# quarterly security cycle, and pinning past them would leave you on a JDK with
# known CVEs. `java -version` tells you what you have.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

API=https://api.adoptium.net/v3
JDK_OS=linux JDK_ARCH=x64   # x86_64 Linux; edit both for another platform
BINS=(java javac jar jshell)   # symlinked into $BIN; the rest live in $JAVA_HOME/bin

need java || exit 0

# --- which feature release ----------------------------------------------------
feature="${JDK_VERSION:-$(lock_get openjdk adoptium)}"
if [[ -z "$feature" ]]; then
  feature="$(curl -fsSL --retry 3 --connect-timeout 20 "$API/info/available_releases" \
    | python3 -c 'import sys,json; print(json.load(sys.stdin)["most_recent_lts"])')" \
    || die "openjdk: could not reach $API/info/available_releases to find the current LTS — set JDK_VERSION=21 to skip the lookup"
  log "no JDK_VERSION set and none pinned — using the current LTS, Java $feature"
fi
[[ "$feature" =~ ^[0-9]+$ ]] || die "openjdk: JDK_VERSION must be a feature release number like 21, got '$feature'"

# --- resolve the asset --------------------------------------------------------
cat > "$TMP/pick_jdk.py" <<'PY'
import json, sys
rels = json.load(sys.stdin)
if not rels:
    raise SystemExit(1)
b = rels[0]["binary"]["package"]
print("\t".join([rels[0]["release_name"], b["link"], b.get("checksum", "")]))
PY

row="$(curl -fsSL --retry 3 --connect-timeout 20 \
        "$API/assets/latest/$feature/hotspot?os=$JDK_OS&architecture=$JDK_ARCH&image_type=jdk" \
        | python3 "$TMP/pick_jdk.py")" \
  || die "openjdk: Adoptium lists no $JDK_OS/$JDK_ARCH JDK for Java $feature — see $API/info/available_releases for what it builds"
IFS=$'\t' read -r release url sha <<<"$row"

log "installing $release  (adoptium temurin $feature, latest patch)"

# --- download and verify ------------------------------------------------------
file="${url##*/}"
fetch "$url" "$TMP/$file"

if [[ -n "$sha" ]]; then
  got="$(python3 -c '
import hashlib, sys
h = hashlib.sha256()
with open(sys.argv[1], "rb") as fh:
    for chunk in iter(lambda: fh.read(1 << 20), b""):
        h.update(chunk)
print(h.hexdigest())' "$TMP/$file")"
  [[ "$got" == "$sha" ]] || die "openjdk: SHA-256 mismatch on $file
  expected $sha
  got      $got
the download was corrupted or tampered with — delete it and retry"
  ok "SHA-256 verified"
else
  warn "Adoptium published no checksum for $file — installing unverified"
fi

# --- install ------------------------------------------------------------------
# The tarball unpacks to one top-level directory named for the release, but the
# name carries a '+' that varies by build, so find it rather than assume it.
d="$TMP/jdk.d"; mkdir -p "$d"
tar -xzf "$TMP/$file" -C "$d"
top="$(find "$d" -mindepth 1 -maxdepth 1 -type d | head -1)"
[[ -n "$top" && -x "$top/bin/java" ]] || die "openjdk: no bin/java inside $file — the tarball layout changed"

# Temurin names releases two ways: 'jdk-21.0.12.1+1' for Java 9 and up, but
# 'jdk8u504-b01' for Java 8. Normalise both to one jdk-<version> directory, so
# the layout (and uninstall's jdk-[0-9]* glob) holds for either.
ver="${release#jdk-}"   # 21.0.12.1+1  |  jdk8u504-b01
ver="${ver#jdk}"        # 21.0.12.1+1  |  8u504-b01
dest="$BIN/jdk-$ver"
rm -rf "$dest"
mv "$top" "$dest"

for b in "${BINS[@]}"; do
  if [[ -x "$dest/bin/$b" ]]; then
    ln -sfn "$dest/bin/$b" "$BIN/$b"
    ok "$b -> $BIN/$b"
  else
    warn "$b is not in this JDK ($release) — skipped"   # jshell arrived in Java 9
  fi
done
_check_libc "$BIN/java"

ok "$("$BIN/java" -version 2>&1 | head -1)  (JAVA_HOME $dest)"
log "openjdk done — export JAVA_HOME=$dest for Maven/Gradle; see shell/init.sh"
