# Copyright 2022 JetBrains s.r.o.

In order to retrieve sources, create project and build, execute the following (default ARCH is 'x64', also it can be 'arm64'):

$ mkdir chromium
$ mv cef chromium
$ cd chromium

# for debug
$ export project_conf=Debug

$ cef/jb/tools/common/get_sources.sh ARCH
$ cef/jb/tools/mac/create_project.sh ARCH
$ cef/jb/tools/mac/build.sh ARCH
$ cef/jb/tools/mac/create_distr.sh ARCH
