# Copyright 2021 JetBrains s.r.o.
# Creates distributive.

root_dir=$(pwd)
project_conf=${CEF_PROJECT_CONF:=Release}
architecture=$1 # arm64 or x64
if [[ "${architecture}" != *arm64* ]]; then
  architecture="x64"
fi

conf_dir=${project_conf}_GN_${architecture}


if [ ! -d "$root_dir"/chromium_git/chromium/src/cef/tools ] ||
   [ ! -d "$root_dir"/chromium_git/chromium/src/out/${conf_dir} ];
then
  echo "Error: please run jb/tools/mac/build.sh";
  exit 1;
fi

echo "*** Stripping symbols... ***"
strip -x "${root_dir}/chromium_git/chromium/src/out/${conf_dir}/Chromium Embedded Framework.framework/Versions/A/Chromium Embedded Framework"
strip -x "${root_dir}/chromium_git/chromium/src/out/${conf_dir}/cefclient.app/Contents/Frameworks/Chromium Embedded Framework.framework/Versions/A/Chromium Embedded Framework"

echo "*** Making distributive... ***"
cd "$root_dir"/chromium_git/chromium/src/cef/tools || exit 1
python make_distrib.py --output-dir=../binary_distrib/ --ninja-build --${architecture}-build --no-docs --no-symbols --minimal

cd "$root_dir" || exit 1