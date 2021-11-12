# Copyright 2021 JetBrains s.r.o.

[ -d ./chromium_git/chromium/src/cef ] ||  (echo "run jb/tools/common/get_sources.sh"; exit 1)

cd ./chromium_git/chromium/src/cef || exit 1
bash -x cef_create_projects.sh
