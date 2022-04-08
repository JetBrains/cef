#!/bin/bash
# Copyright 2021-2022 JetBrains s.r.o.
# Creates distributive.

set -euo pipefail

root_dir=$(pwd)
project_conf=${CEF_PROJECT_CONF:=Release}
architecture=${1:-x64} # arm64 or x64

conf_dir=${project_conf}_GN_${architecture}

script_dir=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)

if [ ! -d "$root_dir"/chromium_git/chromium/src/cef/tools ]; then
  echo "Error: not found '$root_dir/chromium_git/chromium/src/cef/tools'"
  echo "please run $script_dir/build.sh"
  exit 1
fi
if [ ! -d "$root_dir"/chromium_git/chromium/src/out/"${conf_dir}" ]; then
  echo "Error: not found '$root_dir/chromium_git/chromium/src/out/$conf_dir'"
  echo "please run $script_dir/build.sh"
  exit 1
fi

function log() {
  echo "$(date --rfc-3339=seconds)  " "$@"
}

strip_cmd="strip"
if [[ "$architecture" == arm64 ]]; then
  echo "*** Installing required tool ... ***"
  if ! where aarch64-linux-gnu-strip &>/dev/null; then
    apt-get --assume-yes update
    apt-get --assume-yes install binutils-aarch64-linux-gnu
  fi
  strip_cmd="aarch64-linux-gnu-strip"
fi

log "*** Stripping symbols... ***"
"$strip_cmd" -x "${root_dir}/chromium_git/chromium/src/out/${conf_dir}/libcef.so"
log "*** Making distributive... ***"
cd "$root_dir"/chromium_git/chromium/src/cef/tools || exit 1
python make_distrib.py --output-dir=../binary_distrib/ --ninja-build "--${architecture}-build" --no-docs --no-symbols --minimal

cd "$root_dir" || exit 1
