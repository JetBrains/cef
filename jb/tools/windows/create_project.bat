@echo off

setlocal

set root_dir=%cd%
if not exist %root_dir%\chromium_git\chromium\src\cef (
  echo "Error: can't find chromium sources, please run jb/tools/common/get_sources.sh"
  exit \b 1
)
if not exist %root_dir%\depot_tools (
  echo "Error: can't find depot_tools, please run jb/tools/common/get_sources.sh"
  exit \b 1
)

set architecture=x64
if "%1" == "arm64" (
  echo "use ARM64 build"
  :: arm64 or x64
  set architecture=arm64
  set CEF_ENABLE_ARM64=1
)

set "PATH=%root_dir%\depot_tools;%PATH%"
echo "use PATH=%PATH%"

cd %root_dir%\chromium_git\chromium\src\cef
echo "*** Creating cef project... ***"
:: To avoid generating Debug configuration use: is_asan=true
set GN_DEFINES=symbol_level=0 is_official_build=true
set GN_ARGUMENTS=--ide=vs2019 --sln=cef --filters=//cef/*
call cef_create_projects.bat

cd %root_dir%
