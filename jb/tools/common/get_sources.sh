# Copyright 2021 JetBrains s.r.o.

# Retrieves chromium & cef source code of the proper version:
# 1. $ mkdir chromium && cd chromium
# 2. $ git clone https://github.com/JetBrains/cef
# 3. $ bash cef/jb/tools/common/get_sources.sh

root_dir=$(pwd)
cef_branch=jb_master

[ -d depot_tools ] || git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git depot_tools
cd depot_tools || exit 1
git checkout main

cd "$root_dir"/cef || exit 1
git fetch https://github.com/JetBrains/cef master:origin/master
git checkout $cef_branch

cd "$root_dir" || exit 1
export PATH="$root_dir"/depot_tools:$PATH
python "$root_dir"/cef/jb/tools/common/automate-git.py --download-dir="$root_dir"/chromium_git --depot-tools-dir="$root_dir"/depot_tools --branch=$cef_branch --no-depot-tools-update --no-distrib --no-build --x64-build

if [ $? -ne 0 ]; then
	echo "Update sources falied. Checkout correct version of depot tools..."
	cd "$root_dir"/chromium_git/chromium/src || exit 1
	# shellcheck disable=SC2155
	export COMMIT_DATE=$(git log -n 1 --pretty=format:%ci)
	cd "$root_dir"/depot_tools || exit 1
	git checkout "$(git rev-list -n 1 --before="$COMMIT_DATE" main)"
	unset COMMIT_DATE

  echo "Re-update..."
  python "$root_dir"/cef/jb/tools/common/automate-git.py --download-dir="$root_dir"/chromium_git --depot-tools-dir="$root_dir"/depot_tools --branch=$cef_branch --no-depot-tools-update --no-distrib --no-build --x64-build
fi

cd "$root_dir"/chromium_git/chromium/src/cef || exit 1
bash -x cef_create_projects.sh
