# Copyright 2021 JetBrains s.r.o.

In order to retrieve sources, create project and build, execute the following scripts (default ARCH is 'x64', also it can be 'arm64'):

$ jb/tools/common/get_sources.sh ARCH
$ jb/tools/mac/create_project.sh ARCH
$ jb/tools/mac/build.sh ARCH
$ jb/tools/mac/create_distr.sh ARCH
