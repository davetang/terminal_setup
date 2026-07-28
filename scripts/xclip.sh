#!/usr/bin/env bash
# xclip — pipe stdin/stdout to and from the X11 clipboard. C program with no
# binary release upstream; via conda-forge, which pulls its libX11/libXmu deps
# in as conda packages, so still no root. Needs a reachable X server at
# $DISPLAY at *run* time (locally, or over `ssh -X`); it installs fine without.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install xclip xclip
