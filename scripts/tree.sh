#!/usr/bin/env bash
# tree — recursive directory listing, drawn as an indented tree.
# Upstream (https://gitlab.com/OldManProgrammer/unix-tree) publishes source
# tarballs on GitLab and fossies.org with no release API for binaries.tsv to
# query, so this comes from conda-forge. `eza --tree` covers most of the same
# ground and is already installed here, but tree is what scripts, documentation
# and muscle memory reach for. Pinned through versions.lock.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install tree tree
