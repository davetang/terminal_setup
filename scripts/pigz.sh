#!/usr/bin/env bash
# pigz — parallel gzip: the same .gz format, all of your cores.
# Upstream (https://zlib.net/pigz/) is a plain source tarball with no release
# API, so conda-forge. The package ships unpigz alongside pigz, which is the
# half that matters for reading: `tar -I unpigz -xf big.tar.gz`.
# Pinned through versions.lock.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib.sh"
conda_install pigz pigz
