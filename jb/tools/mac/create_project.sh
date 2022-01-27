# Copyright 2021 JetBrains s.r.o.

architecture=$1 # arm64 or x64
if [[ "${architecture}" != *arm64* ]]; then
  architecture="x64"
else
  export CEF_ENABLE_ARM64=1
fi

[ -d ./chromium_git/chromium/src/cef ] ||  (echo "run jb/tools/common/get_sources.sh"; exit 1)

export PATH=$(pwd)/depot_tools:$PATH
cd ./chromium_git/chromium/src/cef || exit 1
source jb/tools/mac/gn.env
echo "Use GN_DEFINES: ${GN_DEFINES}"
bash -x cef_create_projects.sh
