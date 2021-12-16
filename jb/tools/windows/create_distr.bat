@echo off

setlocal

set root_dir=%cd%
if not defined project_conf (
  set project_conf=Release
)

set architecture=x64
if "%1" == "arm64" (
  echo "use ARM64 build"
  :: arm64 or x64
  set architecture=arm64
)

set conf_dir=%project_conf%_GN_%architecture%
echo "conf_dir=%conf_dir%"

if not exist %root_dir%\chromium_git\chromium\src\out\%conf_dir% (
  echo "Error: can't find %conf_dir%, please run jb/tools/windows/build.bat"
  exit \b 1
)

set "PATH=%root_dir%\depot_tools;%PATH%"
echo "use PATH=%PATH%"

echo "*** Making distributive... ***"
cd %root_dir%\chromium_git\chromium\src\cef\tools
python.bat make_distrib.py --output-dir=../binary_distrib/ --ninja-build --%architecture%-build --no-docs --no-symbols --minimal

cd %root_dir%
