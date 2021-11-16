# Copyright 2021 JetBrains s.r.o.
# Creates distributive.

root_dir=$(pwd)
project_conf=${CEF_PROJECT_CONF:=Release}

if [ ! -d "$root_dir"/chromium_git/chromium/src/cef/tools ] ||
   [ ! -d "$root_dir"/chromium_git/chromium/src/out/${project_conf}_GN_x64 ] ||
   [ ! -d "$root_dir"/depot_tools ];
then
  echo "Error: please run jb/tools/linux/build.sh";
  exit 1;
fi
export PATH="$root_dir"/depot_tools:$PATH

echo "*** Stripping symbols... ***"
strip -x "$root_dir"/chromium_git/chromium/src/out/${project_conf}_GN_x64/libcef.so

echo "*** Making distributive... ***"
cd "$root_dir"/chromium_git/chromium/src/cef/tools || exit 1
python make_distrib.py --output-dir=../binary_distrib/ --ninja-build --x64-build --no-docs --no-symbols --minimal

cd "$root_dir" || exit 1