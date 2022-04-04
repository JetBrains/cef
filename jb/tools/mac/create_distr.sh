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

log "*** Stripping symbols... ***"
strip -x "${root_dir}/chromium_git/chromium/src/out/${conf_dir}/Chromium Embedded Framework.framework/Versions/A/Chromium Embedded Framework"
strip -x "${root_dir}/chromium_git/chromium/src/out/${conf_dir}/cefclient.app/Contents/Frameworks/Chromium Embedded Framework.framework/Versions/A/Chromium Embedded Framework"

log "*** Making distributive... ***"
cd "$root_dir"/chromium_git/chromium/src/cef/tools || exit 1
python make_distrib.py --output-dir=../binary_distrib/ --ninja-build "--${architecture}-build" --no-docs --no-symbols --minimal

cd "$root_dir" || exit 1
