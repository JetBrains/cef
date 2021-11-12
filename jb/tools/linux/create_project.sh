# Copyright 2021 JetBrains s.r.o.

[ -d ./chromium_git/chromium/src/cef ] || (echo "run jb/tools/common/get_sources.sh"; exit 1)

apt-get --assume-yes update
apt-get --assume-yes install lsb-core sudo python libgtkglext1-dev default-jdk vim

curl 'https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh?format=TEXT' | base64 -d > install-build-deps.sh
bash ./install-build-deps.sh --no-arm --no-chromeos-fonts --no-nacl

cd ./chromium_git/chromium/src/cef || exit 1
export GN_DEFINES="is_official_build=true use_allocator=none is_cfi=false use_thin_lto=false use_sysroot=true no_crash_on_assert=true"
bash cef_create_projects.sh
