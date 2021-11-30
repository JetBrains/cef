# Copyright 2021 JetBrains s.r.o.
# Retrieves chromium & cef sources.

root_dir=$(pwd)
cef_branch=${CEF_BRANCH:=jb_master}
architecture=$1 # arm64 or x64
if [[ "${architecture}" != *arm64* ]]; then
  architecture="x64"
fi


if [ ! -d depot_tools ]; then
    echo "*** Clonning depot_tools... ***"
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools
fi
cd depot_tools || exit 1
git checkout main

cd "$root_dir" || exit 1
if [ ! -d cef ]; then
    echo "*** Clonning cef... ***"
    git clone https://github.com/JetBrains/cef
fi
cd "$root_dir"/cef || exit 1
# needed for TeamCity
git fetch https://github.com/JetBrains/cef master:origin/master
git checkout $cef_branch

cd "$root_dir" || exit 1
export PATH="$root_dir"/depot_tools:$PATH
echo "*** Downloading chromium... ***"
python "$root_dir"/cef/jb/tools/common/automate-git.py --download-dir="$root_dir"/chromium_git --depot-tools-dir="$root_dir"/depot_tools --branch=$cef_branch --no-depot-tools-update --no-distrib --no-build --${architecture}-build

if [ $? -ne 0 ]; then
	echo "*** Update sources failed. Checkout correct version of depot tools... ***"
	cd "$root_dir"/chromium_git/chromium/src || exit 1
	# shellcheck disable=SC2155
	export COMMIT_DATE=$(git log -n 1 --pretty=format:%ci)
	cd "$root_dir"/depot_tools || exit 1
	git checkout "$(git rev-list -n 1 --before="$COMMIT_DATE" main)"
	unset COMMIT_DATE

  echo "*** Downloading chromium... ***"
  python "$root_dir"/cef/jb/tools/common/automate-git.py --download-dir="$root_dir"/chromium_git --depot-tools-dir="$root_dir"/depot_tools --branch=$cef_branch --no-depot-tools-update --no-distrib --no-build --${architecture}-build
fi

cd "$root_dir" || exit 1
