# Copyright 2021 JetBrains s.r.o.
# Retrieves chromium & cef sources.

root_dir=$(pwd)
cef_branch=${CEF_BRANCH:=jb_master}
architecture=$1 # arm64 or x64
clean=$2 # clean or clean-with-deps
if [[ "${architecture}" != *arm64* ]]; then
  architecture="x64"
fi
cleankeys=""
if [[ "${clean}" == "clean" ]]; then
  echo "Will be performed clean checkout of Chromium"
  cleankeys=" --force-clean"
elif [[ "${clean}" == "clean-with-deps" ]]; then
  echo "Will be performed clean checkout of Chromium with deps cleaning"
  cleankeys=" --force-clean --force-clean-deps"
fi

if [ ! -d depot_tools ]; then
    echo "*** Clonning depot_tools... ***"
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools
fi
cd depot_tools || exit 1
git fetch
git checkout main

cd "$root_dir" || exit 1
if [ ! -d cef ]; then
    echo "*** Clonning cef... ***"
    git clone https://github.com/JetBrains/cef
fi
cd "$root_dir"/cef || exit 1
# needed for TeamCity
git fetch https://github.com/JetBrains/cef master:origin/master
echo "*** Checkout cef branch: ${cef_branch} ***"
git checkout $cef_branch

cd "$root_dir" || exit 1
export PATH="$root_dir"/depot_tools:$PATH
echo "*** Downloading chromium... ***"

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)
      source "$root_dir"/cef/jb/tools/linux/build.env
      ;;
    Darwin*)
      source "$root_dir"/cef/jb/tools/mac/build.env
      ;;
    CYGWIN*)
      echo "ERROR: Use get_sources.bat"
      ;;
    MINGW*)
      echo "ERROR: Use get_sources.bat"
      ;;
    *)
      echo "Unknown machine: ${unameOut}"
      exit 1
esac
echo "Use GN_DEFINES: ${GN_DEFINES}"

python "$root_dir"/cef/jb/tools/common/automate-git.py --download-dir="$root_dir"/chromium_git --depot-tools-dir="$root_dir"/depot_tools --branch=$cef_branch --no-depot-tools-update --no-distrib --no-build --${architecture}-build ${cleankeys}

if [ $? -ne 0 ]; then
	echo "*** Update sources failed... ***"
	bash "$root_dir"/cef/jb/tools/common/checkout_depot_tools.sh

  echo "*** Downloading chromium again... ***"
  python "$root_dir"/cef/jb/tools/common/automate-git.py --download-dir="$root_dir"/chromium_git --depot-tools-dir="$root_dir"/depot_tools --branch=$cef_branch --no-depot-tools-update --no-distrib --no-build --${architecture}-build ${cleankeys}
fi

cd "$root_dir" || exit 1
