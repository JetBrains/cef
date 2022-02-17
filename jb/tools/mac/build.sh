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

# restart sccache server if presented
bash "$root_dir"/cef/jb/tools/mac/prepare_sccache.sh

# prepare environment
source "$root_dir"/cef/jb/tools/mac/build.env

# empiric rule: we must build cefsimple at first (otherwise tagret 'cef' won't be compiled)
echo "*** Building cefsimple ${architecture} ... ***"
python -c 'import datetime; print datetime.datetime.now()'
ninja -C "$root_dir"/chromium_git/chromium/src/out/${conf_dir} cefsimple

echo "*** Building cef ${architecture} ... ***"
python -c 'import datetime; print datetime.datetime.now()'
ninja -C "$root_dir"/chromium_git/chromium/src/out/${conf_dir} cef

echo "*** Creating compilation database... ***"
python -c 'import datetime; print datetime.datetime.now()'
ninja -C "$root_dir"/chromium_git/chromium/src/out/${conf_dir} -t compdb cc cxx > "$root_dir"/chromium_git/chromium/src/out/${conf_dir}/compile_commands.json

cd "$root_dir" || exit 1