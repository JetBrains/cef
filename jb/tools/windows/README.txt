# Copyright 2022 JetBrains s.r.o.

In order to retrieve sources, create project and build, execute the following (default ARCH is 'x64', also it can be 'arm64'):

mkdir chromium
move cef chromium
cd chromium

# for debug:
set project_conf=Debug

cef\jb\tools\windows\get_sources.bat ARCH
cef\jb\tools\windows\create_project.bat ARCH
cef\jb\tools\windows\build.bat ARCH
cef\jb\tools\windows\create_distr.bat ARCH
