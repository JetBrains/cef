# Copyright 2021 JetBrains s.r.o.
# Builds chromium & cef project.

root_dir=$(pwd)
project_conf=${CEF_PROJECT_CONF:=Release}
architecture=$1 # arm64 or x64
if [[ "${architecture}" != *arm64* ]]; then
  architecture="x64"
fi

conf_dir=${project_conf}_GN_${architecture}

if [ ! -d chromium_git/chromium/src/out/${conf_dir} ] || [ ! -d ./depot_tools ]; then
  echo "Error: please run jb/tools/mac/create_project.sh";
  exit 1;
fi
export PATH="$root_dir"/depot_tools:$PATH

echo "*** Building cef ${architecture} ... ***"
# empiric rule: we must build cefsimple at first (otherwise tagret 'cef' won't be compiled)
ninja -C "$root_dir"/chromium_git/chromium/src/out/${conf_dir} cefsimple
ninja -C "$root_dir"/chromium_git/chromium/src/out/${conf_dir} cef

echo "*** Creating compilation database... ***"
ninja -C "$root_dir"/chromium_git/chromium/src/out/${conf_dir} -t compdb cc cxx > "$root_dir"/chromium_git/chromium/src/out/${conf_dir}/compile_commands.json

cd "$root_dir" || exit 1