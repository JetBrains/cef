#!/bin/bash
set -euo pipefail

if ! which sccache &>/dev/null; then
    echo "sccache isn't installed, nothing to do"
    exit 0
fi

env_location="${1}"

# shellcheck disable=SC1090
source "$env_location"

# Uncomment for debug logging
# export SCCACHE_ERROR_LOG="$(pwd)/sccache_log.txt"
# export SCCACHE_LOG=trace
# echo "sccache log located at $SCCACHE_ERROR_LOG"

echo "Restarting sccache server in environment:"
cat "$env_location"

sccache --stop-server
sccache --start-server
sccache -s
