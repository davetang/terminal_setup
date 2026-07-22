#!/usr/bin/env bash
# binary.sh <tool> — install one prebuilt-binary tool listed in binaries.tsv.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
[[ $# -ge 1 ]] || die "usage: binary.sh <tool>"
install_binary "$1"
