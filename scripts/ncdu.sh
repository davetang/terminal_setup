#!/usr/bin/env bash
# ncdu — interactive ncurses disk usage browser (https://dev.yorhel.nl/ncdu).
# Upstream does ship a static linux-x86_64 tarball, but only from its own site:
# the source lives on a Gitea instance (code.blicky.net) that publishes no
# releases at all, so there is no release API for binaries.tsv to query.
# Via conda-forge instead. Pinned through versions.lock.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install ncdu ncdu
