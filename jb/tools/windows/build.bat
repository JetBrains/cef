@echo off

setlocal

set root_dir=%cd%
if not defined project_conf (
  set project_conf=Release
)

set architecture=x64
set buildtarget=cef
if "%1" == "arm64" (
  echo "use ARM64 build"
  :: arm64 or x64
  set architecture=arm64
  set CEF_ENABLE_ARM64=1
  set buildtarget=cefsimple
)

set conf_dir=%project_conf%_GN_%architecture%
echo "conf_dir=%conf_dir%"

if not exist %root_dir%\chromium_git\chromium\src\out\%conf_dir% (
  echo "Error: can't find %conf_dir%, please run jb/tools/windows/create_project.bat"
  exit \b 1
)

set "PATH=%root_dir%\depot_tools;%PATH%"
echo "use PATH=%PATH%"

:: to avoid problems with long paths
call reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
call reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem"

echo "*** Building %buildtarget% (for %architecture%)... ***"
call ninja -C %root_dir%/chromium_git/chromium/src/out/%conf_dir% %buildtarget%

echo "*** Creating cef_sandbox (for %architecture%)... ***"
:: Generate the cef_sandbox.lib merged library for binary distrib.
:: see make_distrib.py::904
::   A separate *_sandbox build should exist when GN is_official_build=true.
call ninja -C %root_dir%/chromium_git/chromium/src/out/%conf_dir%_sandbox cef_sandbox

echo "*** Creating compilation database... ***"
call ninja -C %root_dir%/chromium_git/chromium/src/out/%conf_dir% -t compdb cc cxx > %root_dir%\chromium_git\chromium\src\out\%conf_dir%\compile_commands.json
