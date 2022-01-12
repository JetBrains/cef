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
  echo "Error: can't find %conf_dir%, please run jb/tools/windows/create_project.bat"
  exit \b 1
)

set "PATH=%root_dir%\depot_tools;%PATH%"
echo "use PATH=%PATH%"

:: to avoid problems with long paths
call reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
call reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem"

echo "*** Building cef... ***"
call ninja -C %root_dir%/chromium_git/chromium/src/out/%conf_dir% cef

echo "*** Creating compilation database... ***"
call ninja -C %root_dir%/chromium_git/chromium/src/out/%conf_dir% -t compdb cc cxx > %root_dir%\chromium_git\chromium\src\out\%conf_dir%\compile_commands.json
