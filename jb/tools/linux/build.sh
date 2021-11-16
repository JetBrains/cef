# Copyright 2021 JetBrains s.r.o.
# Builds chromium & cef project.

root_dir=$(pwd)
project_conf=${CEF_PROJECT_CONF:=Release}

if [ ! -d chromium_git/chromium/src/out/${project_conf}_GN_x64 ] || [ ! -d ./depot_tools ]; then
  echo "Error: please run jb/tools/linux/create_project.sh";
  exit 1;
fi
export PATH="$root_dir"/depot_tools:$PATH

echo "*** Building cef... ***"
ninja -C "$root_dir"/chromium_git/chromium/src/out/${project_conf}_GN_x64 cefsimple chrome_sandbox

echo "*** Creating compilation database... ***"
ninja -C "$root_dir"/chromium_git/chromium/src/out/${project_conf}_GN_x64 -t compdb cc cxx > "$root_dir"/chromium_git/chromium/src/out/${project_conf}_GN_x64/compile_commands.json

cd "$root_dir" || exit 1