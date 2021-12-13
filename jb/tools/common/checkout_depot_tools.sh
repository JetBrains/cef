root_dir=$(pwd)

echo "*** Checkout the closest revision of depot tools... ***"
cd "$root_dir"/chromium_git/chromium/src || exit 1
export COMMIT_DATE=$(git log -n 1 --pretty=format:%ci)
echo "use date: ${COMMIT_DATE}"
cd "$root_dir"/depot_tools || exit 1
git checkout "$(git rev-list -n 1 --before="$COMMIT_DATE" main)"
git status
unset COMMIT_DATE
cd "$root_dir" || exit 1
