:: Copyright 2021 JetBrains s.r.o.
:: Retrieves chromium & cef sources.
@echo off

setlocal

set root_dir=%cd%
if not defined cef_branch (
  set cef_branch=jb_master
)

set architecture=x64
if "%1" == "arm64" (
  echo "use ARM64 build"
  :: arm64 or x64
  set architecture=arm64
)

:: clean or clean-with-deps
if "%2" == "clean" (
  echo "Will be performed clean checkout of Chromium"
  set cleankeys=" --force-clean"
) else if "%2" == "clean-with-deps" (
  echo "Will be performed clean checkout of Chromium with deps cleaning"
  set cleankeys=" --force-clean --force-clean-deps"
)

if not exist depot_tools (
    echo "*** Clonning depot_tools... ***"
    call git clone https://chromium.googlesource.com/chromium/tools/depot_tools
)

set "PATH=%root_dir%\depot_tools;%PATH%"

cd depot_tools
echo "*** Update depot_tools... ***"
call update_depot_tools.bat

cd %root_dir%
if not exist cef (
  echo "*** Clonning cef... ***"
  call git clone https://github.com/JetBrains/cef
)

cd %root_dir%\cef
:: needed for TeamCity
call git fetch https://github.com/JetBrains/cef master:origin/master
echo "*** Checkout cef branch: %cef_branch% ***"
call git checkout %cef_branch%

cd %root_dir%
call git config --system core.longpaths true
echo "*** Downloading chromium... ***"
call python %root_dir%/cef/jb/tools/common/automate-git.py --download-dir=%root_dir%/chromium_git --depot-tools-dir=%root_dir%/depot_tools --branch=%cef_branch% --no-depot-tools-update --no-distrib --no-build --no-debug-tests --no-release-tests --%architecture%-build %cleankeys%

cd %root_dir%

