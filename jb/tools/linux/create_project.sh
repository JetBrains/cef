# Copyright 2021 JetBrains s.r.o.
# Creates cef project.

root_dir=$(pwd)

if [ ! -d "$root_dir"/chromium_git/chromium/src/cef ] ||
   [ ! -d "$root_dir"/depot_tools ];
then
  echo "Error: please run jb/tools/common/get_sources.sh";
  exit 1;
fi
export PATH="$root_dir"/depot_tools:$PATH

apt-get --assume-yes update
apt-get --assume-yes install lsb-core sudo python libgtkglext1-dev default-jdk vim

echo "*** Installing build deps... ***"
curl 'https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh?format=TEXT' | base64 -d > install-build-deps.sh
bash "$root_dir"/install-build-deps.sh --no-arm --no-chromeos-fonts --no-nacl

cd "$root_dir"/chromium_git/chromium/src/cef || exit 1
echo "*** Creating cef project... ***"
export GN_DEFINES="is_official_build=true use_allocator=none is_cfi=false use_thin_lto=false use_sysroot=true no_crash_on_assert=true"
bash cef_create_projects.sh

cd "$root_dir" || exit 1