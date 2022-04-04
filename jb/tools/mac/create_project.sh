#!/bin/bash
# Copyright 2021-2022 JetBrains s.r.o.
# Creates cef project.

set -euo pipefail

root_dir=$(pwd)
architecture=${1:-x64} # arm64 or x64

script_dir=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)

if [[ "$architecture" == arm64 ]]; then
  export CEF_ENABLE_ARM64=1
fi

if [ ! -d "$root_dir"/chromium_git/chromium/src/cef ]; then
  echo "Error: not found '$root_dir/chromium_git/chromium/src/cef'"
  echo "please run $script_dir/../common/get_sources.sh"
  exit 1
fi
if [ ! -d "$root_dir"/depot_tools ]; then
  echo "Error: not found '$root_dir/depot_tools'"
  echo "please run $script_dir/../common/get_sources.sh"
  exit 1
fi

export PATH="$root_dir"/depot_tools:$PATH

cd "$root_dir"/chromium_git/chromium/src/cef || exit 1
echo "*** Creating cef project... ***"
source "$script_dir/build.env"

if which sccache &>/dev/null; then
  echo "Sccache is enabled"
  export GN_DEFINES="${GN_DEFINES} cc_wrapper=sccache"
fi

echo "Use GN_DEFINES: ${GN_DEFINES}"
bash -x cef_create_projects.sh

echo "*** Done $0 ***"

cd "$root_dir" || exit 1
