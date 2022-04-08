#!/bin/bash
# Copyright 2021-2022 JetBrains s.r.o.
# Builds chromium & cef project.

set -euo pipefail

root_dir=$(pwd)
project_conf=${CEF_PROJECT_CONF:=Release}
architecture=${1:-x64} # arm64 or x64

conf_dir=${project_conf}_GN_${architecture}

script_dir=$(cd -- "$(dirname -- "$0")" &>/dev/null && pwd)

if [ ! -d "$root_dir"/chromium_git/chromium/src/out/"${conf_dir}" ]; then
  echo "Error: not found '$root_dir/chromium_git/chromium/src/out/$conf_dir'"
  echo "please run $script_dir/create_project.sh"
  exit 1
fi
if [ ! -d "$root_dir"/depot_tools ]; then
  echo "Error: not found '$root_dir/depot_tools'"
  echo "please run $script_dir/create_project.sh"
  exit 1
fi

export PATH="$root_dir"/depot_tools:$PATH

function log() {
  echo "$(date +%FT%T%z)  " "$@"
}

# restart sccache server if presented
bash "$script_dir/../common/prepare_sccache.sh" "$script_dir/build.env"

# prepare environment
source "$script_dir/build.env"

# empiric rule: we must build cefsimple at first (otherwise target 'cef' won't be compiled)
log "*** Building cefsimple ${architecture} ... ***"
ninja -C "$root_dir"/chromium_git/chromium/src/out/"${conf_dir}" cefsimple

log "*** Building cef ${architecture} ... ***"
ninja -C "$root_dir"/chromium_git/chromium/src/out/"${conf_dir}" cef

log "*** Creating compilation database... ***"
ninja -C "$root_dir"/chromium_git/chromium/src/out/"${conf_dir}" -t compdb cc cxx >"$root_dir"/chromium_git/chromium/src/out/"${conf_dir}"/compile_commands.json

log "*** Done"
cd "$root_dir" || exit 1
