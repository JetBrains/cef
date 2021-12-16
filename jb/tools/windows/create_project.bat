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

set "PATH=%root_dir%\depot_tools;%PATH%"
echo "use PATH=%PATH%"

cd %root_dir%\chromium_git\chromium\src\cef
echo "*** Creating cef project... ***"
:: To avoid generating Debug configuration use: is_asan=true
set GN_DEFINES=symbol_level=1
set GN_ARGUMENTS=--ide=vs2019 --sln=cef --filters=//cef/*
call cef_create_projects.bat

cd %root_dir%
