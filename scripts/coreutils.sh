#!/usr/bin/env bash
# coreutils — a current GNU coreutils, installed g-prefixed: gls, gcat, gsort…
#
# The point is a *newer* coreutils than the host ships (for `sort --parallel`,
# `ls --hyperlink`, `cp --reflink`, a `date` that knows about your timezone
# database) without replacing the one everything else depends on.
#
# conda-forge builds the same source twice from one feedstock:
#   coreutils      ./configure --prefix=$PREFIX                     -> ls,  cat,  sort
#   gnu-coreutils  ./configure --prefix=$PREFIX --program-prefix=g  -> gls, gcat, gsort
#
# This installs gnu-coreutils, deliberately. The unprefixed package lands in
# ~/miniforge3/bin, which shell/init.sh puts *ahead* of /usr/bin: every ls, cp,
# mv and rm in every shell would silently become conda's build, including the
# ones inside other people's scripts. The g-prefix is the same convention
# Homebrew uses on macOS, for the same reason.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"

conda_install gnu-coreutils gls
log "g-prefixed: gls, gcat, gsort, gdate, gwc, gln … — your system coreutils are untouched"
